import Foundation
import SwiftData
import Observation

// MARK: - Enum (moved from IngredientListView)

enum IngredientSortOrder: String, CaseIterable {
    case nameAsc, nameDesc, byCategory
}

// MARK: - ViewModel

@Observable
final class IngredientListViewModel {

    // MARK: UI State
    var searchText = ""
    var showAddSheet = false
    var ingredientToEdit: Ingredient?
    var inUseAlert: InUseAlert?
    var sortOrder: IngredientSortOrder = .nameAsc
    var filterCategories: Set<ShoppingCategory> = []
    var showFilterSheet = false

    struct InUseAlert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    var isFiltering: Bool { !filterCategories.isEmpty }

    // MARK: - Pure helpers

    func filtered(ingredients: [Ingredient]) -> [Ingredient] {
        var result = ingredients.filter { ingredient in
            if !searchText.isEmpty,
               !ingredient.name.localizedCaseInsensitiveContains(searchText) { return false }
            if !filterCategories.isEmpty,
               !filterCategories.contains(ingredient.shoppingCategory) { return false }
            return true
        }
        switch sortOrder {
        case .nameAsc:
            result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameDesc:
            result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        case .byCategory:
            result.sort {
                let c = $0.shoppingCategory.rawValue.localizedCompare($1.shoppingCategory.rawValue)
                return c == .orderedAscending ||
                    (c == .orderedSame &&
                     $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending)
            }
        }
        return result
    }

    // MARK: - Mutations

    func delete(ingredient: Ingredient, storageItems: [StorageItem], in context: ModelContext) {
        let recipeCount  = ingredient.recipeIngredients.count
        let storageCount = storageItems.filter {
            $0.ingredient?.persistentModelID == ingredient.persistentModelID
        }.count

        if recipeCount > 0 || storageCount > 0 {
            var parts: [String] = []
            if recipeCount > 0  { parts.append(String(localized: "\(recipeCount) recipes")) }
            if storageCount > 0 { parts.append(String(localized: "\(storageCount) storage items")) }
            let usage = parts.formatted(.list(type: .and))
            inUseAlert = InUseAlert(
                title: String(localized: "Cannot Delete Ingredient"),
                message: String(localized: "\"\(ingredient.name)\" is used in \(usage). Remove those references first.")
            )
        } else {
            context.delete(ingredient)
        }
    }
}
