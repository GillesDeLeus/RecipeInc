import Testing
import SwiftData
@testable import KoensKitchen

// MARK: - Shared helper

@MainActor
func makeTestContainer() throws -> ModelContainer {
    let schema = Schema([
        Recipe.self, Ingredient.self, RecipeIngredient.self,
        RecipeCategory.self, RecipeTag.self, RecipePhoto.self,
        MealPlan.self, StorageItem.self, ShoppingListItem.self
    ])
    return try ModelContainer(for: schema,
                              configurations: ModelConfiguration(isStoredInMemoryOnly: true))
}
