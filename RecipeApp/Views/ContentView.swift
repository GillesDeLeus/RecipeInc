import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(AppSettings.self) private var appSettings
    @Query(filter: #Predicate<ShoppingListItem> { item in !item.isChecked })
    private var uncheckedShoppingItems: [ShoppingListItem]

    @State private var pendingImport: PendingImport?
    @State private var pendingImportImageData: Data?

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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active, let item = PendingImportStore.loadAndClear() {
                if item.kind == .image {
                    // Load (and delete) the image file once, outside the sheet
                    // builder — sheet content closures can be re-evaluated.
                    guard let data = PendingImportStore.loadAndClearImageData() else { return }
                    pendingImportImageData = data
                }
                pendingImport = item
            }
        }
        .sheet(item: $pendingImport) { item in
            switch item.kind {
            case .url:
                RecipeImportView(prefilledURL: item.content)
                    .environment(appSettings)
            case .text:
                RecipeImportView(prefilledText: item.content)
                    .environment(appSettings)
            case .image:
                RecipeImportView(prefilledImageData: pendingImportImageData)
                    .environment(appSettings)
            }
        }
    }

    // MARK: - Seed standard categories and tags on first launch

    private func seedDefaultData() {
        let categoryCount = (try? modelContext.fetchCount(FetchDescriptor<RecipeCategory>())) ?? 0
        guard categoryCount == 0 else { return }

        let lang = appSettings.language
        let categories = [
            lang.t("Breakfast", "Ontbijt"),
            lang.t("Lunch", "Lunch"),
            lang.t("Dinner", "Avondeten"),
            lang.t("Dessert", "Dessert"),
            lang.t("Snack", "Snack"),
            lang.t("Soup", "Soep"),
            lang.t("Salad", "Salade"),
            lang.t("Appetizer", "Voorgerecht"),
            lang.t("Side Dish", "Bijgerecht"),
            lang.t("Drink", "Drank")
        ]
        for name in categories {
            modelContext.insert(RecipeCategory(name: name, isCustom: false))
        }

        let tags: [(String, String)] = [
            (lang.t("Quick",        "Snel"),             "#34C759"),
            (lang.t("Vegetarian",   "Vegetarisch"),      "#30B050"),
            (lang.t("Vegan",        "Veganistisch"),     "#00C7BE"),
            (lang.t("Gluten-free",  "Glutenvrij"),       "#FF9500"),
            (lang.t("Dairy-free",   "Lactosevrij"),      "#32ADE6"),
            (lang.t("Spicy",        "Pittig"),           "#FF3B30"),
            (lang.t("Kid-friendly", "Kindvriendelijk"),  "#FFD60A"),
            (lang.t("Healthy",      "Gezond"),           "#5AC8FA"),
            (lang.t("One-pot",      "Eenpansgerecht"),   "#BF5AF2"),
            (lang.t("Make-ahead",   "Voor te bereiden"), "#5E5CE6"),
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
