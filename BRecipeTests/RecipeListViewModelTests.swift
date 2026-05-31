import Testing
import SwiftData
@testable import BRecipe

@MainActor
struct RecipeListViewModelTests {

    // MARK: - inStockIDs

    @Test func inStockIDsEmptyForNoStorageItems() {
        let vm = RecipeListViewModel()
        #expect(vm.inStockIDs(from: []).isEmpty)
    }

    @Test func inStockIDsExcludesItemsWithNoIngredient() throws {
        let c = try makeTestContainer()
        let item = StorageItem(ingredient: nil, amount: 1, location: .foodCloset)
        c.mainContext.insert(item)

        #expect(RecipeListViewModel().inStockIDs(from: [item]).isEmpty)
    }

    @Test func inStockIDsIncludesIngredientIDs() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let ing = Ingredient(name: "Kip", unit: "g", shoppingCategory: .meat)
        ctx.insert(ing)
        let item = StorageItem(ingredient: ing, amount: 200, location: .refrigerator)
        ctx.insert(item)

        let ids = RecipeListViewModel().inStockIDs(from: [item])
        #expect(ids.contains(ing.persistentModelID))
    }

    // MARK: - missingCount

    @Test func missingCountZeroForRecipeWithNoIngredients() throws {
        let c = try makeTestContainer()
        let recipe = Recipe(name: "Leeg", instructions: "", prepTimeMinutes: 0)
        c.mainContext.insert(recipe)

        #expect(RecipeListViewModel().missingCount(for: recipe, inStockIDs: []) == 0)
    }

    @Test func missingCountCorrectWhenIngredientInStock() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let ing = Ingredient(name: "Boter", unit: "g", shoppingCategory: .dairy)
        ctx.insert(ing)
        let ri = RecipeIngredient(ingredient: ing, amount: 50)
        ctx.insert(ri)
        let recipe = Recipe(name: "Toast", instructions: "", prepTimeMinutes: 5)
        ctx.insert(recipe)
        ri.recipe = recipe
        recipe.recipeIngredients.append(ri)

        let inStock: Set<PersistentIdentifier> = [ing.persistentModelID]
        #expect(RecipeListViewModel().missingCount(for: recipe, inStockIDs: inStock) == 0)
    }

    @Test func missingCountCorrectWhenIngredientMissing() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let ing = Ingredient(name: "Truffel", unit: "g", shoppingCategory: .pantry)
        ctx.insert(ing)
        let ri = RecipeIngredient(ingredient: ing, amount: 5)
        ctx.insert(ri)
        let recipe = Recipe(name: "Luxe gerecht", instructions: "", prepTimeMinutes: 30)
        ctx.insert(recipe)
        ri.recipe = recipe
        recipe.recipeIngredients.append(ri)

        // Nothing in stock
        #expect(RecipeListViewModel().missingCount(for: recipe, inStockIDs: []) == 1)
    }

    // MARK: - filtered: search text

    @Test func filterBySearchTextIncludesMatch() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let r1 = Recipe(name: "Spaghetti Bolognese", instructions: "", prepTimeMinutes: 40)
        let r2 = Recipe(name: "Pizza Margherita", instructions: "", prepTimeMinutes: 20)
        ctx.insert(r1); ctx.insert(r2)

        let vm = RecipeListViewModel()
        vm.searchText = "spag"
        let result = vm.filtered(recipes: [r1, r2], storageItems: [])

        #expect(result.count == 1)
        #expect(result[0].name == "Spaghetti Bolognese")
    }

    @Test func filterBySearchTextIsCaseInsensitive() throws {
        let c = try makeTestContainer()
        let recipe = Recipe(name: "Risotto", instructions: "", prepTimeMinutes: 35)
        c.mainContext.insert(recipe)

        let vm = RecipeListViewModel()
        vm.searchText = "RISOTTO"
        let result = vm.filtered(recipes: [recipe], storageItems: [])

        #expect(result.count == 1)
    }

    @Test func filterBySearchTextExcludesNonMatch() throws {
        let c = try makeTestContainer()
        let recipe = Recipe(name: "Soep", instructions: "", prepTimeMinutes: 25)
        c.mainContext.insert(recipe)

        let vm = RecipeListViewModel()
        vm.searchText = "pasta"
        #expect(vm.filtered(recipes: [recipe], storageItems: []).isEmpty)
    }

    // MARK: - filtered: favorites

    @Test func filterByFavoritesOnlyKeepsOnlyFavorites() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let fav = Recipe(name: "Favoriet", instructions: "", prepTimeMinutes: 15)
        fav.isFavorite = true
        let notFav = Recipe(name: "Normaal", instructions: "", prepTimeMinutes: 15)
        ctx.insert(fav); ctx.insert(notFav)

        let vm = RecipeListViewModel()
        vm.filter.favoritesOnly = true
        let result = vm.filtered(recipes: [fav, notFav], storageItems: [])

        #expect(result.count == 1)
        #expect(result[0].name == "Favoriet")
    }

    // MARK: - filtered: rating

    @Test func filterByMinRatingExcludesBelowThreshold() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let high = Recipe(name: "Top", instructions: "", prepTimeMinutes: 20)
        high.rating = 4
        let low = Recipe(name: "Matig", instructions: "", prepTimeMinutes: 20)
        low.rating = 2
        ctx.insert(high); ctx.insert(low)

        let vm = RecipeListViewModel()
        vm.filter.minRating = 3
        let result = vm.filtered(recipes: [high, low], storageItems: [])

        #expect(result.count == 1)
        #expect(result[0].name == "Top")
    }

    // MARK: - filtered: prep time

    @Test func filterByMaxPrepTimeExcludesSlowRecipes() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let quick = Recipe(name: "Snel", instructions: "", prepTimeMinutes: 10)
        let slow  = Recipe(name: "Langzaam", instructions: "", prepTimeMinutes: 90)
        ctx.insert(quick); ctx.insert(slow)

        let vm = RecipeListViewModel()
        vm.filter.maxMinutes = 30
        let result = vm.filtered(recipes: [quick, slow], storageItems: [])

        #expect(result.count == 1)
        #expect(result[0].name == "Snel")
    }

    @Test func filterByMinPrepTimeExcludesQuickRecipes() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let quick = Recipe(name: "Snel", instructions: "", prepTimeMinutes: 10)
        let slow  = Recipe(name: "Uitgebreid", instructions: "", prepTimeMinutes: 60)
        ctx.insert(quick); ctx.insert(slow)

        let vm = RecipeListViewModel()
        vm.filter.minMinutes = 45
        let result = vm.filtered(recipes: [quick, slow], storageItems: [])

        #expect(result.count == 1)
        #expect(result[0].name == "Uitgebreid")
    }

    // MARK: - filtered: stock mode

    @Test func filterStockModeCanCookExcludesMissingIngredients() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext

        let ing = Ingredient(name: "Kip", unit: "g", shoppingCategory: .meat)
        ctx.insert(ing)
        let storage = StorageItem(ingredient: ing, amount: 200, location: .refrigerator)
        ctx.insert(storage)

        let ri1 = RecipeIngredient(ingredient: ing, amount: 150)
        ctx.insert(ri1)
        let canCook = Recipe(name: "Kipschotel", instructions: "", prepTimeMinutes: 30)
        ctx.insert(canCook)
        ri1.recipe = canCook
        canCook.recipeIngredients.append(ri1)

        let missing = Ingredient(name: "Truffel", unit: "g", shoppingCategory: .pantry)
        ctx.insert(missing)
        let ri2 = RecipeIngredient(ingredient: missing, amount: 5)
        ctx.insert(ri2)
        let cannotCook = Recipe(name: "Luxe gerecht", instructions: "", prepTimeMinutes: 45)
        ctx.insert(cannotCook)
        ri2.recipe = cannotCook
        cannotCook.recipeIngredients.append(ri2)

        let vm = RecipeListViewModel()
        vm.filter.stockMode = .canCook
        let result = vm.filtered(recipes: [canCook, cannotCook], storageItems: [storage])

        #expect(result.count == 1)
        #expect(result[0].name == "Kipschotel")
    }

    // MARK: - Sort orders

    @Test func sortByNameAscending() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let b = Recipe(name: "Boerenkool", instructions: "", prepTimeMinutes: 30)
        let a = Recipe(name: "Asperges", instructions: "", prepTimeMinutes: 20)
        ctx.insert(b); ctx.insert(a)

        let vm = RecipeListViewModel()
        vm.sortOrder = .nameAsc
        let result = vm.filtered(recipes: [b, a], storageItems: [])

        #expect(result.map(\.name) == ["Asperges", "Boerenkool"])
    }

    @Test func sortByNameDescending() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let b = Recipe(name: "Boerenkool", instructions: "", prepTimeMinutes: 30)
        let a = Recipe(name: "Asperges", instructions: "", prepTimeMinutes: 20)
        ctx.insert(b); ctx.insert(a)

        let vm = RecipeListViewModel()
        vm.sortOrder = .nameDesc
        let result = vm.filtered(recipes: [b, a], storageItems: [])

        #expect(result.map(\.name) == ["Boerenkool", "Asperges"])
    }

    @Test func sortByPrepTimeAscending() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let slow  = Recipe(name: "Langzaam", instructions: "", prepTimeMinutes: 60)
        let quick = Recipe(name: "Snel", instructions: "", prepTimeMinutes: 15)
        ctx.insert(slow); ctx.insert(quick)

        let vm = RecipeListViewModel()
        vm.sortOrder = .prepAsc
        let result = vm.filtered(recipes: [slow, quick], storageItems: [])

        #expect(result[0].prepTimeMinutes < result[1].prepTimeMinutes)
    }

    @Test func noFilterReturnsAllRecipes() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let r1 = Recipe(name: "A", instructions: "", prepTimeMinutes: 10)
        let r2 = Recipe(name: "B", instructions: "", prepTimeMinutes: 20)
        let r3 = Recipe(name: "C", instructions: "", prepTimeMinutes: 30)
        ctx.insert(r1); ctx.insert(r2); ctx.insert(r3)

        let result = RecipeListViewModel().filtered(recipes: [r1, r2, r3], storageItems: [])
        #expect(result.count == 3)
    }
}
