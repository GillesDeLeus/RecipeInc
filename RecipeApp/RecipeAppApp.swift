import SwiftUI
import SwiftData
import TipKit

@main
struct RecipeAppApp: App {

    @State private var appSettings = AppSettings()

    init() {
        try? Tips.configure([
            .displayFrequency(.immediate)
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appSettings)
        }
        .modelContainer(for: [
            Recipe.self,
            Ingredient.self,
            RecipeIngredient.self,
            RecipePhoto.self,
            StorageItem.self,
            RecipeCategory.self,
            RecipeTag.self,
            MealPlan.self,
            ShoppingListItem.self
        ])
    }
}
