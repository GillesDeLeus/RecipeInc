import Testing
@testable import KoensKitchen

struct NutritionServiceTests {

    // MARK: - normalize

    @Test func normalizeLowercases() {
        #expect(NutritionService.normalize("KIP") == "kip")
        #expect(NutritionService.normalize("Boter") == "boter")
    }

    @Test func normalizeStripsDigitsAndPunctuation() {
        // Only letters and whitespace survive
        #expect(NutritionService.normalize("100g") == "g")
        #expect(NutritionService.normalize("3.5%") == "")
    }

    @Test func normalizeTrimsWhitespace() {
        #expect(NutritionService.normalize("  kip  ") == "kip")
    }

    @Test func normalizePreservesInternalSpaces() {
        #expect(NutritionService.normalize("volle melk") == "volle melk")
    }

    @Test func normalizeEmptyStringReturnsEmpty() {
        #expect(NutritionService.normalize("") == "")
    }

    @Test func normalizeStripsAccents() {
        // Diacritics should be folded away
        let result = NutritionService.normalize("crème")
        #expect(!result.contains("è"))
    }

    // MARK: - topMatches

    @Test func topMatchesFindsResultsForKnownIngredient() {
        let results = NutritionService.topMatches(for: "kip", n: 5)
        #expect(!results.isEmpty)
    }

    @Test func topMatchesResultsAreSortedByScoreDescending() {
        let results = NutritionService.topMatches(for: "melk", n: 5)
        guard results.count > 1 else { return }
        for i in 0..<results.count - 1 {
            #expect(results[i].score >= results[i + 1].score)
        }
    }

    @Test func topMatchesRespectsNLimit() {
        let results = NutritionService.topMatches(for: "boter", n: 2)
        #expect(results.count <= 2)
    }

    @Test func topMatchesReturnsEmptyForBlankQuery() {
        #expect(NutritionService.topMatches(for: "", n: 5).isEmpty)
    }

    @Test func topMatchesScoresAreBetweenZeroAndOne() {
        let results = NutritionService.topMatches(for: "ei", n: 5)
        for match in results {
            #expect(match.score >= 0.0)
            #expect(match.score <= 1.0)
        }
    }

    @Test func exactMatchScoresHighest() {
        // A query that exactly matches an entry name should come back first
        let results = NutritionService.topMatches(for: "melk", n: 10)
        guard let top = results.first else { return }
        // The top score should be notably good (>= 0.8)
        #expect(top.score >= 0.8)
    }

    // MARK: - lookup

    @Test func lookupReturnsResultForKnownIngredient() throws {
        let info = try NutritionService.lookup(ingredientName: "kip")
        #expect(info.caloriesPer100g > 0)
        #expect(info.proteinPer100g > 0)
    }

    @Test func lookupThrowsForUnknownIngredient() {
        #expect(throws: (any Error).self) {
            try NutritionService.lookup(ingredientName: "xyzzy_nonexistent_12345")
        }
    }

    @Test func nutritionInfoCaloriesMatchEntry() throws {
        let results = NutritionService.topMatches(for: "boter", n: 1)
        guard let top = results.first else { return }
        let info = NutritionService.nutritionInfo(for: top.entry)
        #expect(info.caloriesPer100g == top.entry.kcal)
    }
}
