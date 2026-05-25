import SwiftUI
import SwiftData

@main
struct RecipeAppApp: App {

    @State private var appSettings = AppSettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appSettings)
                .task { NotificationManager.shared.requestAuthorization() }
        }
        .modelContainer(for: [
            Recipe.self,
            Ingredient.self,
            RecipeIngredient.self,
            RecipePhoto.self,
            StorageItem.self,
            RecipeCategory.self,
            RecipeTag.self,
            MealPlan.self
        ])
    }
}
