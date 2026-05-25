import Foundation

struct NutritionInfo {
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let fatPer100g: Double
    let carbsPer100g: Double
    let fiberPer100g: Double
}

enum NutritionServiceError: LocalizedError {
    case noResults

    var errorDescription: String? {
        "Ingredient not found in the local database. Try a more common or Dutch name."
    }
}

enum NutritionService {

    // MARK: - Public

    static func lookup(ingredientName: String) throws -> NutritionInfo {
        let query = normalize(ingredientName)
        guard !query.isEmpty else { throw NutritionServiceError.noResults }

        var bestScore = 0.0
        var bestEntry: NevoEntry?

        for entry in nevoDatabase {
            let s = matchScore(query: query, entry: entry)
            if s > bestScore {
                bestScore = s
                bestEntry = entry
            }
        }

        guard let entry = bestEntry, bestScore >= 0.25 else {
            throw NutritionServiceError.noResults
        }

        return NutritionInfo(
            caloriesPer100g: entry.kcal,
            proteinPer100g:  entry.protein,
            fatPer100g:      entry.fat,
            carbsPer100g:    entry.carbs,
            fiberPer100g:    entry.fiber
        )
    }

    // MARK: - Fuzzy matching

    private static func matchScore(query: String, entry: NevoEntry) -> Double {
        let candidates = [normalize(entry.name)] + entry.aliases.map { normalize($0) }
        return candidates.map { score(query, $0) }.max() ?? 0.0
    }

    private static func score(_ a: String, _ b: String) -> Double {
        if a == b { return 1.0 }
        if a.contains(b) || b.contains(a) { return 0.85 }

        let aWords = Set(a.split(separator: " ").map(String.init).filter { $0.count > 1 })
        let bWords = Set(b.split(separator: " ").map(String.init).filter { $0.count > 1 })
        guard !aWords.isEmpty, !bWords.isEmpty else { return 0.0 }

        let intersection = Double(aWords.intersection(bWords).count)
        let union        = Double(aWords.union(bWords).count)
        return intersection / union
    }

    private static func normalize(_ s: String) -> String {
        let base = s.lowercased()
                    .folding(options: .diacriticInsensitive, locale: Locale(identifier: "nl_BE"))
        return base.filter { $0.isLetter || $0.isWhitespace }
                   .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
