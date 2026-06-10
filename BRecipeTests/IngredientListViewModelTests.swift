import Testing
import SwiftData
@testable import KoensKitchen

@MainActor
struct IngredientListViewModelTests {

    // MARK: - isFiltering (pure state, no SwiftData)

    @Test func isFilteringFalseByDefault() {
        #expect(!IngredientListViewModel().isFiltering)
    }

    @Test func isFilteringTrueWhenCategorySet() {
        let vm = IngredientListViewModel()
        vm.filterCategories = [.dairy]
        #expect(vm.isFiltering)
    }

    @Test func isFilteringFalseAfterCategoryCleared() {
        let vm = IngredientListViewModel()
        vm.filterCategories = [.dairy]
        vm.filterCategories = []
        #expect(!vm.isFiltering)
    }

    // MARK: - filtered: search text

    @Test func filterBySearchTextIncludesMatch() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let boter = Ingredient(name: "Boter", unit: "g", shoppingCategory: .dairy)
        let melk  = Ingredient(name: "Melk",  unit: "ml", shoppingCategory: .dairy)
        ctx.insert(boter); ctx.insert(melk)

        let vm = IngredientListViewModel()
        vm.searchText = "bot"
        let result = vm.filtered(ingredients: [boter, melk])

        #expect(result.count == 1)
        #expect(result[0].name == "Boter")
    }

    @Test func filterBySearchTextIsCaseInsensitive() throws {
        let c = try makeTestContainer()
        let ing = Ingredient(name: "Azijn", unit: "ml", shoppingCategory: .pantry)
        c.mainContext.insert(ing)

        let vm = IngredientListViewModel()
        vm.searchText = "AZIJN"
        #expect(vm.filtered(ingredients: [ing]).count == 1)
    }

    @Test func filterBySearchTextExcludesNonMatch() throws {
        let c = try makeTestContainer()
        let ing = Ingredient(name: "Zout", unit: "g", shoppingCategory: .pantry)
        c.mainContext.insert(ing)

        let vm = IngredientListViewModel()
        vm.searchText = "suiker"
        #expect(vm.filtered(ingredients: [ing]).isEmpty)
    }

    @Test func emptySearchTextReturnsAll() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let a = Ingredient(name: "Azijn", unit: "ml", shoppingCategory: .pantry)
        let b = Ingredient(name: "Boter", unit: "g",  shoppingCategory: .dairy)
        ctx.insert(a); ctx.insert(b)

        let vm = IngredientListViewModel()
        #expect(vm.filtered(ingredients: [a, b]).count == 2)
    }

    // MARK: - filtered: category

    @Test func filterByCategoryKeepsOnlyMatchingCategory() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let dairy = Ingredient(name: "Boter", unit: "g",  shoppingCategory: .dairy)
        let meat  = Ingredient(name: "Kip",   unit: "g",  shoppingCategory: .meat)
        let pantry = Ingredient(name: "Zout", unit: "g",  shoppingCategory: .pantry)
        ctx.insert(dairy); ctx.insert(meat); ctx.insert(pantry)

        let vm = IngredientListViewModel()
        vm.filterCategories = [.dairy]
        let result = vm.filtered(ingredients: [dairy, meat, pantry])

        #expect(result.count == 1)
        #expect(result[0].shoppingCategory == .dairy)
    }

    @Test func filterByMultipleCategoriesKeepsAll() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let dairy  = Ingredient(name: "Boter", unit: "g", shoppingCategory: .dairy)
        let meat   = Ingredient(name: "Kip",   unit: "g", shoppingCategory: .meat)
        let pantry = Ingredient(name: "Zout",  unit: "g", shoppingCategory: .pantry)
        ctx.insert(dairy); ctx.insert(meat); ctx.insert(pantry)

        let vm = IngredientListViewModel()
        vm.filterCategories = [.dairy, .meat]
        let result = vm.filtered(ingredients: [dairy, meat, pantry])

        #expect(result.count == 2)
    }

    // MARK: - Sort orders

    @Test func sortByNameAscending() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let z = Ingredient(name: "Zout",  unit: "g",  shoppingCategory: .pantry)
        let a = Ingredient(name: "Azijn", unit: "ml", shoppingCategory: .pantry)
        ctx.insert(z); ctx.insert(a)

        let vm = IngredientListViewModel()
        vm.sortOrder = .nameAsc
        let result = vm.filtered(ingredients: [z, a])

        #expect(result.map(\.name) == ["Azijn", "Zout"])
    }

    @Test func sortByNameDescending() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let z = Ingredient(name: "Zout",  unit: "g",  shoppingCategory: .pantry)
        let a = Ingredient(name: "Azijn", unit: "ml", shoppingCategory: .pantry)
        ctx.insert(z); ctx.insert(a)

        let vm = IngredientListViewModel()
        vm.sortOrder = .nameDesc
        let result = vm.filtered(ingredients: [z, a])

        #expect(result.map(\.name) == ["Zout", "Azijn"])
    }

    @Test func sortByCategoryGroupsTogether() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let dairy  = Ingredient(name: "Melk",  unit: "ml", shoppingCategory: .dairy)
        let pantry = Ingredient(name: "Zout",  unit: "g",  shoppingCategory: .pantry)
        let dairy2 = Ingredient(name: "Boter", unit: "g",  shoppingCategory: .dairy)
        ctx.insert(dairy); ctx.insert(pantry); ctx.insert(dairy2)

        let vm = IngredientListViewModel()
        vm.sortOrder = .byCategory
        let result = vm.filtered(ingredients: [dairy, pantry, dairy2])

        // All dairy items should be adjacent
        let categories = result.map { $0.shoppingCategory }
        let dairyIndices = categories.enumerated().filter { $0.element == .dairy }.map { $0.offset }
        if dairyIndices.count == 2 {
            #expect(dairyIndices[1] - dairyIndices[0] == 1)
        }
    }
}
