import Foundation
import SwiftData
import Observation

// MARK: - Enums (moved from RecipeListView)

enum StockFilterMode: String, CaseIterable {
    case all
    case canCook
    case almostCanCook
}

enum RecipeSortOrder: String, CaseIterable {
    case nameAsc, nameDesc, prepAsc, prepDesc, newest, oldest
}

// MARK: - Filter state

struct RecipeFilter {
    var minMinutes: Double = 0
    var maxMinutes: Double = 240
    var includedIngredientIDs: Set<PersistentIdentifier> = []
    var excludedIngredientIDs: Set<PersistentIdentifier> = []
    var favoritesOnly = false
    var categoryIDs: Set<PersistentIdentifier> = []
    var tagIDs: Set<PersistentIdentifier> = []
    var stockMode: StockFilterMode = .all
    var minRating: Int = 0

    var isActive: Bool {
        minMinutes > 0 || maxMinutes < 240
            || !includedIngredientIDs.isEmpty || !excludedIngredientIDs.isEmpty
            || favoritesOnly
            || !categoryIDs.isEmpty || !tagIDs.isEmpty
            || stockMode != .all
            || minRating > 0
    }

    mutating func reset() { self = RecipeFilter() }
}

// MARK: - ViewModel

@Observable
final class RecipeListViewModel {

    // MARK: UI State
    var searchText = ""
    var showAddSheet = false
    var showImportSheet = false
    var showFilterPanel = false
    var sortOrder: RecipeSortOrder = .nameAsc
    var filter = RecipeFilter()
    var deletionAlert: DeletionAlert?

    struct DeletionAlert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    var isFiltering: Bool { filter.isActive }

    // MARK: - Pure helpers

    func inStockIDs(from storageItems: [StorageItem]) -> Set<PersistentIdentifier> {
        Set(storageItems.compactMap { $0.ingredient?.persistentModelID })
    }

    func missingCount(for recipe: Recipe, inStockIDs: Set<PersistentIdentifier>) -> Int {
        let inStock = recipe.recipeIngredients.filter {
            guard let ing = $0.ingredient else { return false }
            return inStockIDs.contains(ing.persistentModelID)
        }.count
        return recipe.recipeIngredients.count - inStock
    }

    func filtered(recipes: [Recipe], storageItems: [StorageItem]) -> [Recipe] {
        let stockIDs = inStockIDs(from: storageItems)
        var result = recipes.filter { recipe in
            if !searchText.isEmpty,
               !recipe.name.localizedCaseInsensitiveContains(searchText) { return false }

            if filter.favoritesOnly && !recipe.isFavorite { return false }

            let mins = Double(recipe.prepTimeMinutes)
            if filter.minMinutes > 0 && mins < filter.minMinutes { return false }
            if filter.maxMinutes < 240 && mins > filter.maxMinutes { return false }

            if !filter.categoryIDs.isEmpty {
                guard let catID = recipe.category?.persistentModelID,
                      filter.categoryIDs.contains(catID) else { return false }
            }

            if !filter.tagIDs.isEmpty {
                let recipeTagIDs = Set(recipe.tags.map { $0.persistentModelID })
                if filter.tagIDs.isDisjoint(with: recipeTagIDs) { return false }
            }

            if !filter.includedIngredientIDs.isEmpty {
                let ids = Set(recipe.recipeIngredients.compactMap { $0.ingredient?.persistentModelID })
                if !filter.includedIngredientIDs.isSubset(of: ids) { return false }
            }

            if !filter.excludedIngredientIDs.isEmpty {
                let ids = Set(recipe.recipeIngredients.compactMap { $0.ingredient?.persistentModelID })
                if !filter.excludedIngredientIDs.isDisjoint(with: ids) { return false }
            }

            if filter.stockMode != .all {
                let missing = missingCount(for: recipe, inStockIDs: stockIDs)
                switch filter.stockMode {
                case .canCook:       if missing > 0 { return false }
                case .almostCanCook: if missing > 2 { return false }
                case .all: break
                }
            }

            if filter.minRating > 0 && recipe.rating < filter.minRating { return false }

            return true
        }

        switch sortOrder {
        case .nameAsc:  result.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .nameDesc: result.sort { $0.name.localizedCompare($1.name) == .orderedDescending }
        case .prepAsc:  result.sort { $0.prepTimeMinutes < $1.prepTimeMinutes }
        case .prepDesc: result.sort { $0.prepTimeMinutes > $1.prepTimeMinutes }
        case .newest:   result.sort { $0.createdAt > $1.createdAt }
        case .oldest:   result.sort { $0.createdAt < $1.createdAt }
        }
        return result
    }

    // MARK: - Mutations

    func mealPlans(for recipe: Recipe, in context: ModelContext) -> [MealPlan] {
        let id = recipe.persistentModelID
        let descriptor = FetchDescriptor<MealPlan>(
            predicate: #Predicate { $0.recipe?.persistentModelID == id }
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func delete(recipe: Recipe, in context: ModelContext, lang: AppLanguage) {
        let today = Calendar.current.startOfDay(for: Date())
        let plans = mealPlans(for: recipe, in: context)
        let futurePlans = plans.filter { $0.date >= today }
        if !futurePlans.isEmpty {
            deletionAlert = DeletionAlert(
                title: lang.recipeFutureScheduledTitle,
                message: lang.recipeFutureScheduledMessage(recipe.name, futurePlans.count)
            )
        } else {
            for plan in plans where plan.date < today { context.delete(plan) }
            context.delete(recipe)
        }
    }
}
