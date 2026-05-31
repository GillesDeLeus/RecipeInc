import Foundation
import Vision
import FoundationModels
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "RecipeApp", category: "RecipeImport")

// MARK: - Plain data types (used by the view on all OS versions)

struct ImportedRecipeData {
    var name: String
    var prepTimeMinutes: Int
    var instructions: String
    var ingredients: [ImportedIngredientData]
}

struct ImportedIngredientData {
    var name: String
    var amount: Double
    var unit: String
}

// MARK: - Errors

enum RecipeImportError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case noRecipeFound
    case ocrFailed
    case aiNotEnabled
    case aiModelNotReady
    case aiUnavailable
    case aiError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:        return "The URL is not valid."
        case .networkError(let e): return "Network error: \(e.localizedDescription)"
        case .noRecipeFound:     return "No recipe data could be found on that page. Try pasting the URL of a recipe page directly."
        case .ocrFailed:         return "Could not read text from the image."
        case .aiNotEnabled:      return "Apple Intelligence is not enabled. Go to System Settings → Apple Intelligence & Siri and turn it on."
        case .aiModelNotReady:   return "The Apple Intelligence model is still downloading. Try again in a few minutes."
        case .aiUnavailable:     return "On-device AI is not available on this device or OS version."
        case .aiError(let e):    return "AI parsing failed: \(e.localizedDescription)"
        }
    }
}

// MARK: - Service

enum RecipeImportService {

    // MARK: Public entry points

    static func importFromURL(_ urlString: String) async throws -> ImportedRecipeData {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed), url.scheme != nil else {
            throw RecipeImportError.invalidURL
        }
        logger.info("Importing recipe from URL: \(url.host ?? urlString)")
        let html: String
        do {
            var req = URLRequest(url: url, timeoutInterval: 15)
            req.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
            let (data, _) = try await URLSession.shared.data(for: req)
            html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) ?? ""
        } catch {
            logger.error("Network error fetching \(url.host ?? urlString): \(error.localizedDescription)")
            throw RecipeImportError.networkError(error)
        }

        // Try structured JSON-LD first (fast, no AI needed)
        if let parsed = parseJSONLD(html) {
            logger.info("Recipe parsed via JSON-LD: \(parsed.name)")
            return parsed
        }

        // Fall back to LLM parsing on macOS 26+
        if #available(macOS 26.0, iOS 26.0, *) {
            let plainText = stripHTML(html)
            let truncated = String(plainText.prefix(5000))
            guard !truncated.trimmingCharacters(in: .whitespaces).isEmpty else {
                throw RecipeImportError.noRecipeFound
            }
            do {
                return try await parseWithLLM(truncated)
            } catch let e as RecipeImportError {
                throw e
            } catch {
                throw RecipeImportError.aiError(error)
            }
        } else {
            throw RecipeImportError.noRecipeFound
        }
    }

    static func importFromImage(_ cgImage: CGImage) async throws -> ImportedRecipeData {
        let text = try await recognizeText(in: cgImage)
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw RecipeImportError.ocrFailed
        }
        if #available(macOS 26.0, iOS 26.0, *) {
            // Let RecipeImportError subtypes propagate directly; only wrap unexpected errors
            do {
                return try await parseWithLLM(String(text.prefix(5000)))
            } catch let e as RecipeImportError {
                throw e
            } catch {
                throw RecipeImportError.aiError(error)
            }
        } else {
            throw RecipeImportError.aiUnavailable
        }
    }

    // MARK: JSON-LD parsing

    private static func parseJSONLD(_ html: String) -> ImportedRecipeData? {
        guard let regex = try? NSRegularExpression(
            pattern: "<script[^>]+type=[\"']application/ld\\+json[\"'][^>]*>(.*?)</script>",
            options: [.caseInsensitive, .dotMatchesLineSeparators]
        ) else { return nil }

        let nsHtml = html as NSString
        let matches = regex.matches(in: html, range: NSRange(location: 0, length: nsHtml.length))

        for match in matches {
            guard match.numberOfRanges > 1 else { continue }
            let range = match.range(at: 1)
            guard range.location != NSNotFound else { continue }
            let jsonStr = nsHtml.substring(with: range)
            guard let data = jsonStr.data(using: .utf8),
                  let raw = try? JSONSerialization.jsonObject(with: data) else { continue }

            if let result = findRecipeInJSON(raw) { return result }
        }
        return nil
    }

    private static func findRecipeInJSON(_ raw: Any) -> ImportedRecipeData? {
        if let dict = raw as? [String: Any] {
            // Handle @graph
            if let graph = dict["@graph"] as? [Any] {
                for item in graph {
                    if let r = findRecipeInJSON(item) { return r }
                }
            }
            let type = (dict["@type"] as? String ?? "").lowercased()
            if type.contains("recipe") { return mapSchemaRecipe(dict) }
        }
        if let arr = raw as? [Any] {
            for item in arr {
                if let r = findRecipeInJSON(item) { return r }
            }
        }
        return nil
    }

    private static func mapSchemaRecipe(_ d: [String: Any]) -> ImportedRecipeData {
        let name = d["name"] as? String ?? "Imported Recipe"

        let timeStr = (d["totalTime"] as? String)
            ?? (d["cookTime"] as? String)
            ?? (d["prepTime"] as? String)
            ?? ""
        let minutes = parseDuration(timeStr)

        var instructions = ""
        if let arr = d["recipeInstructions"] as? [[String: Any]] {
            instructions = arr.compactMap { $0["text"] as? String }.joined(separator: "\n\n")
        } else if let arr = d["recipeInstructions"] as? [String] {
            instructions = arr.joined(separator: "\n\n")
        } else if let str = d["recipeInstructions"] as? String {
            instructions = str
        }

        let rawIngredients = d["recipeIngredient"] as? [String] ?? []
        let ingredients = rawIngredients.map { parseIngredientString($0) }

        return ImportedRecipeData(name: name, prepTimeMinutes: minutes,
                                  instructions: instructions, ingredients: ingredients)
    }

    // Parse ISO 8601 duration like "PT1H30M" → 90 minutes
    private static func parseDuration(_ iso: String) -> Int {
        guard !iso.isEmpty else { return 0 }
        var minutes = 0
        var buf = ""
        var inTimePart = false
        for ch in iso.uppercased() {
            if ch == "P" { continue }
            if ch == "T" { inTimePart = true; buf = ""; continue }
            if ch.isNumber { buf.append(ch); continue }
            if let val = Int(buf) {
                switch ch {
                case "H": minutes += val * 60
                case "M" where inTimePart: minutes += val
                case "D": minutes += val * 1440
                default: break
                }
            }
            buf = ""
        }
        return minutes
    }

    // Parse ingredient strings like "200 g flour" or "2 tablespoons butter"
    private static func parseIngredientString(_ raw: String) -> ImportedIngredientData {
        let s = raw.trimmingCharacters(in: .whitespaces)
        // Match: optional amount, optional unit word, rest is name
        let pattern = #"^([\d.,/]+)\s*([a-zA-Zäöüÿëïéàè]{0,10})\.?\s+(.+)$"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let m = regex.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)) {
            let amountStr = capture(m, 1, in: s).replacingOccurrences(of: ",", with: ".")
            let unit     = capture(m, 2, in: s)
            let name     = capture(m, 3, in: s)
            let amount   = parseAmount(amountStr)
            return ImportedIngredientData(name: name, amount: amount, unit: unit)
        }
        return ImportedIngredientData(name: s, amount: 1.0, unit: "")
    }

    // Handle fractions like "1/2" or "1 1/2"
    private static func parseAmount(_ s: String) -> Double {
        let parts = s.split(separator: "/")
        if parts.count == 2, let num = Double(parts[0]), let den = Double(parts[1]) {
            return num / den
        }
        return Double(s) ?? 1.0
    }

    private static func capture(_ m: NSTextCheckingResult, _ i: Int, in s: String) -> String {
        guard m.numberOfRanges > i,
              let r = Range(m.range(at: i), in: s) else { return "" }
        return String(s[r])
    }

    // MARK: HTML → plain text

    private static func stripHTML(_ html: String) -> String {
        var text = html
        // Remove script / style blocks
        for pattern in ["<script[\\s\\S]*?</script>", "<style[\\s\\S]*?</style>"] {
            if let re = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                text = re.stringByReplacingMatches(in: text,
                    range: NSRange(text.startIndex..., in: text), withTemplate: " ")
            }
        }
        // Replace block-level elements with newlines so paragraph structure is preserved
        let blockPatterns = ["</p>", "</div>", "</li>", "</h[1-6]>", "<br\\s*/?>"]
        for pattern in blockPatterns {
            if let re = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                text = re.stringByReplacingMatches(in: text,
                    range: NSRange(text.startIndex..., in: text), withTemplate: "\n")
            }
        }
        // Strip remaining tags
        if let re = try? NSRegularExpression(pattern: "<[^>]+>") {
            text = re.stringByReplacingMatches(in: text,
                range: NSRange(text.startIndex..., in: text), withTemplate: " ")
        }
        // Decode common HTML entities
        text = text
            .replacingOccurrences(of: "&amp;",  with: "&")
            .replacingOccurrences(of: "&lt;",   with: "<")
            .replacingOccurrences(of: "&gt;",   with: ">")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&#39;",  with: "'")
            .replacingOccurrences(of: "&quot;", with: "\"")
        // Collapse runs of spaces within each line, drop blank lines
        let lines = text.components(separatedBy: "\n").compactMap { line -> String? in
            let trimmed = line.components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            return trimmed.isEmpty ? nil : trimmed
        }
        return lines.joined(separator: "\n")
    }

    // MARK: Vision OCR

    static func recognizeText(in image: CGImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { req, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let observations = req.results as? [VNRecognizedTextObservation] ?? []
                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: lines.joined(separator: "\n"))
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            let handler = VNImageRequestHandler(cgImage: image)
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: LLM parsing (macOS 26+)

    @available(macOS 26.0, iOS 26.0, *)
    private static func parseWithLLM(_ text: String) async throws -> ImportedRecipeData {
        let model = SystemLanguageModel.default
        switch model.availability {
        case .available:
            break
        case .unavailable(.appleIntelligenceNotEnabled):
            throw RecipeImportError.aiNotEnabled
        case .unavailable(.modelNotReady):
            throw RecipeImportError.aiModelNotReady
        case .unavailable:
            throw RecipeImportError.aiUnavailable
        }

        let session = LanguageModelSession(instructions: """
            You are a recipe extraction assistant. \
            Extract the recipe from the provided text and return it in the requested structure. \
            If a field is missing, use a sensible default (empty string for text, 0 for numbers, empty array for lists). \
            For ingredients, split combined ingredient strings into name, numeric amount, and unit. \
            For steps, output each distinct preparation step as a separate array entry — do not merge steps \
            into one string and do not include step numbers or bullet characters in the text itself.
            """)

        let response = try await session.respond(to: text, generating: LLMRecipe.self)
        let r = response.content
        return ImportedRecipeData(
            name: r.name,
            prepTimeMinutes: r.prepTimeMinutes,
            instructions: r.steps.joined(separator: "\n\n"),
            ingredients: r.ingredients.map {
                ImportedIngredientData(name: $0.name, amount: $0.amount, unit: $0.unit)
            }
        )
    }
}

// MARK: - LLM Generable types (macOS 26+)

@available(macOS 26.0, iOS 26.0, *)
@Generable(description: "A cooking recipe")
private struct LLMRecipe {
    @Guide(description: "Recipe name")
    var name: String

    @Guide(description: "Total preparation and cooking time in minutes as an integer, e.g. 45")
    var prepTimeMinutes: Int

    @Guide(description: "Each preparation step as a separate string in order, without step numbers or bullet characters")
    var steps: [String]

    @Guide(description: "All ingredients needed")
    var ingredients: [LLMIngredient]
}

@available(macOS 26.0, iOS 26.0, *)
@Generable(description: "One ingredient with quantity")
private struct LLMIngredient {
    @Guide(description: "Ingredient name, e.g. flour, butter, onion")
    var name: String

    @Guide(description: "Numeric amount per serving, e.g. 200.0")
    var amount: Double

    @Guide(description: "Unit like g, ml, piece, tbsp, tsp. Empty string if no unit.")
    var unit: String
}
