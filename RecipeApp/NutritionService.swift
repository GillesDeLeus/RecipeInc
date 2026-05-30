import Foundation

struct NutritionInfo {
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let fatPer100g: Double
    let satFatPer100g: Double?
    let carbsPer100g: Double
    let sugarsPer100g: Double?
    let fiberPer100g: Double
    let sodiumPer100g: Double?
    let potassiumPer100g: Double?
    let calciumPer100g: Double?
    let ironPer100g: Double?
    let vitCPer100g: Double?
    let vitDPer100g: Double?
}

enum NutritionServiceError: LocalizedError {
    case noResults

    var errorDescription: String? {
        "Ingredient not found in the local database. Try a more common or Dutch name."
    }
}

enum NutritionService {

    // MARK: - Public

    /// Returns the best single match, or throws if none found above threshold.
    static func lookup(ingredientName: String) throws -> NutritionInfo {
        guard let best = topMatches(for: ingredientName, n: 1).first else {
            throw NutritionServiceError.noResults
        }
        return nutritionInfo(for: best.entry)
    }

    /// Returns the top N NEVO matches above the score threshold, sorted by score descending.
    static func topMatches(for ingredientName: String, n: Int = 8) -> [(entry: NevoEntry, score: Double)] {
        let query = normalize(ingredientName)
        guard !query.isEmpty else { return [] }
        var scored: [(NevoEntry, Double)] = []
        for entry in nevoDatabase {
            let s = matchScore(query: query, entry: entry)
            if s >= 0.25 { scored.append((entry, s)) }
        }
        return Array(scored.sorted { $0.1 > $1.1 }.prefix(n))
    }

    /// Builds a NutritionInfo from a specific NevoEntry plus any supplement data.
    static func nutritionInfo(for entry: NevoEntry) -> NutritionInfo {
        let supplement = nevoSupplementData[normalize(entry.name)]
        return NutritionInfo(
            caloriesPer100g:  entry.kcal,
            proteinPer100g:   entry.protein,
            fatPer100g:       entry.fat,
            satFatPer100g:    supplement?.satFat,
            carbsPer100g:     entry.carbs,
            sugarsPer100g:    supplement?.sugars,
            fiberPer100g:     entry.fiber,
            sodiumPer100g:    supplement?.sodium,
            potassiumPer100g: supplement?.potassium,
            calciumPer100g:   supplement?.calcium,
            ironPer100g:      supplement?.iron,
            vitCPer100g:      supplement?.vitC,
            vitDPer100g:      supplement?.vitD
        )
    }

    // MARK: - Fuzzy matching

    private static func matchScore(query: String, entry: NevoEntry) -> Double {
        let candidates = [normalize(entry.name)] + entry.aliases.map { normalize($0) }
        return candidates.map { score(query, $0) }.max() ?? 0.0
    }

    // Prefix-aware word coverage scoring.
    //
    // The old Jaccard approach had two fatal flaws:
    //   1. `contains` produced too many false positives (score 0.85 for anything
    //      that happened to contain the query as a substring).
    //   2. The union denominator penalised *longer* entries, so a 6-word entry
    //      that was a perfect match scored *lower* than a 2-word entry with
    //      a single matching word.
    //
    // This function instead asks: "for each query word, how well does the best
    // matching entry word cover it?" — using exact or prefix matching, then
    // averages across query words. Entries with extra words are not penalised.
    private static func score(_ a: String, _ b: String) -> Double {
        if a == b { return 1.0 }

        let aWords = a.split(separator: " ").map(String.init).filter { $0.count > 1 }
        let bWords = b.split(separator: " ").map(String.init).filter { $0.count > 1 }
        guard !aWords.isEmpty, !bWords.isEmpty else { return 0.0 }

        var totalScore = 0.0
        for aw in aWords {
            var best = 0.0
            for bw in bWords {
                if aw == bw {
                    best = 1.0; break
                } else if bw.hasPrefix(aw) {
                    // User is mid-word: "kippe" → "kippen". Score by how much of the entry word is covered.
                    best = max(best, Double(aw.count) / Double(bw.count))
                } else if aw.hasPrefix(bw) {
                    best = max(best, Double(bw.count) / Double(aw.count))
                }
            }
            totalScore += best
        }

        // Score = average per-query-word coverage (0–1).
        // Extra words in the entry don't reduce the score.
        return totalScore / Double(aWords.count)
    }

    static func normalize(_ s: String) -> String {
        let base = s.lowercased()
                    .folding(options: .diacriticInsensitive, locale: Locale(identifier: "nl_BE"))
        return base.filter { $0.isLetter || $0.isWhitespace }
                   .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
