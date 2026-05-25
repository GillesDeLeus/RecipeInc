import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings

    var body: some View {
        let lang = appSettings.language
        TabView {
            RecipeListView()
                .tabItem { Label(lang.tabRecipes, systemImage: "fork.knife") }

            IngredientListView()
                .tabItem { Label(lang.tabIngredients, systemImage: "carrot") }

            if appSettings.featureStorage {
                StorageListView()
                    .tabItem { Label(lang.tabStorage, systemImage: "cart") }
            }

            if appSettings.featureCalendar {
                CalendarView()
                    .tabItem { Label(lang.tabCalendar, systemImage: "calendar") }
            }

            SettingsView()
                .tabItem { Label(lang.tabSettings, systemImage: "gear") }
        }
        .onAppear(perform: seedDefaultData)
    }

    // MARK: - Seed standard categories and tags on first launch

    private func seedDefaultData() {
        let categoryCount = (try? modelContext.fetchCount(FetchDescriptor<RecipeCategory>())) ?? 0
        guard categoryCount == 0 else { return }

        let categories = [
            "Breakfast", "Lunch", "Dinner", "Dessert",
            "Snack", "Soup", "Salad", "Appetizer", "Side Dish", "Drink"
        ]
        for name in categories {
            modelContext.insert(RecipeCategory(name: name, isCustom: false))
        }

        let tags: [(String, String)] = [
            ("Quick",        "#34C759"),
            ("Vegetarian",   "#30B050"),
            ("Vegan",        "#00C7BE"),
            ("Gluten-free",  "#FF9500"),
            ("Dairy-free",   "#32ADE6"),
            ("Spicy",        "#FF3B30"),
            ("Kid-friendly", "#FFD60A"),
            ("Healthy",      "#5AC8FA"),
            ("One-pot",      "#BF5AF2"),
            ("Make-ahead",   "#5E5CE6"),
        ]
        for (name, color) in tags {
            modelContext.insert(RecipeTag(name: name, colorHex: color, isCustom: false))
        }
    }
}

#Preview {
    ContentView()
        .environment(AppSettings())
}
