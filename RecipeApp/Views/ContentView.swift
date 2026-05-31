import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query(filter: #Predicate<ShoppingListItem> { item in !item.isChecked })
    private var uncheckedShoppingItems: [ShoppingListItem]

    var body: some View {
        let lang = appSettings.language
        TabView {
            RecipeListView()
                .tabItem { Label(lang.tabRecipes, systemImage: "fork.knife") }

            // Calendar is a core daily-use feature and must stay in the first 5
            // slots. With all three optional features on (Calendar + Shopping +
            // Storage), Settings is the 6th tab and moves to "More". SettingsView
            // owns its own NavigationStack, so it works correctly in the overflow.
            if appSettings.featureCalendar {
                CalendarView()
                    .tabItem { Label(lang.tabCalendar, systemImage: "calendar") }
            }

            if appSettings.featureShopping {
                PersistentShoppingListView()
                    .tabItem { Label(lang.tabShoppingList, systemImage: "checklist") }
                    .badge(uncheckedShoppingItems.count > 0 ? uncheckedShoppingItems.count : 0)
            }

            if appSettings.featureStorage {
                StorageListView()
                    .tabItem { Label(lang.tabStorage, systemImage: "cart") }
            }

            IngredientListView()
                .tabItem { Label(lang.tabIngredients, systemImage: "carrot") }

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
