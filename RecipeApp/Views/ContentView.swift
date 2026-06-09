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
        TabView {
            RecipeListView()
                .tabItem { Label(String(localized: "Recipes"), systemImage: "fork.knife") }

            // Calendar is a core daily-use feature and must stay in the first 5
            // slots. With all three optional features on (Calendar + Shopping +
            // Storage), Settings is the 6th tab and moves to "More". SettingsView
            // owns its own NavigationStack, so it works correctly in the overflow.
            if appSettings.featureCalendar {
                CalendarView()
                    .tabItem { Label(String(localized: "Calendar"), systemImage: "calendar") }
            }

            if appSettings.featureShopping {
                PersistentShoppingListView()
                    .tabItem { Label(String(localized: "Shopping"), systemImage: "checklist") }
                    .badge(uncheckedShoppingItems.count > 0 ? uncheckedShoppingItems.count : 0)
            }

            if appSettings.featureStorage {
                StorageListView()
                    .tabItem { Label(String(localized: "Storage"), systemImage: "cart") }
            }

            IngredientListView()
                .tabItem { Label(String(localized: "Ingredients"), systemImage: "carrot") }

            SettingsView()
                .tabItem { Label(String(localized: "Settings"), systemImage: "gear") }
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

        let categories = [
            String(localized: "Breakfast"),
            String(localized: "Lunch"),
            String(localized: "Dinner"),
            String(localized: "Dessert"),
            String(localized: "Snack"),
            String(localized: "Soup"),
            String(localized: "Salad"),
            String(localized: "Appetizer"),
            String(localized: "Side Dish"),
            String(localized: "Drink")
        ]
        for name in categories {
            modelContext.insert(RecipeCategory(name: name, isCustom: false))
        }

        let tags: [(String, String)] = [
            (String(localized: "Quick"),             "#34C759"),
            (String(localized: "Vegetarian"),      "#30B050"),
            (String(localized: "Vegan"),     "#00C7BE"),
            (String(localized: "Gluten-free"),       "#FF9500"),
            (String(localized: "Dairy-free"),      "#32ADE6"),
            (String(localized: "Spicy"),           "#FF3B30"),
            (String(localized: "Kid-friendly"),  "#FFD60A"),
            (String(localized: "Healthy"),           "#5AC8FA"),
            (String(localized: "One-pot"),   "#BF5AF2"),
            (String(localized: "Make-ahead"), "#5E5CE6"),
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
