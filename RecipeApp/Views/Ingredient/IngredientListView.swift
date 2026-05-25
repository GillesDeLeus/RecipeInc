import SwiftUI
import SwiftData

struct IngredientListView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \Ingredient.name) private var ingredients: [Ingredient]
    @Query private var allStorageItems: [StorageItem]

    @State private var searchText = ""
    @State private var showAddSheet = false
    @State private var ingredientToEdit: Ingredient?
    @State private var inUseAlert: InUseAlert?

    private struct InUseAlert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    private var lang: AppLanguage { appSettings.language }

    private var filtered: [Ingredient] {
        guard !searchText.isEmpty else { return ingredients }
        return ingredients.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if ingredients.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle(lang.tabIngredients)
            .searchable(text: $searchText, prompt: lang.searchIngredient)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Label(lang.addItem, systemImage: "plus")
                    }
                }
            }
            .sheet(item: $ingredientToEdit) { ingredient in
                IngredientFormView(ingredient: ingredient)
            }
            .alert(item: $inUseAlert) { alert in
                Alert(title: Text(alert.title), message: Text(alert.message))
            }
        }
        .sheet(isPresented: $showAddSheet) {
            IngredientFormView()
        }
    }

    // MARK: - Subviews

    private var list: some View {
        List {
            ForEach(filtered) { ingredient in
                Button {
                    ingredientToEdit = ingredient
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ingredient.name)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text(ingredient.unit)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .onDelete(perform: delete)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(lang.noIngredientsTitle, systemImage: "carrot")
        } description: {
            Text(lang.addFirstIngredient)
        } actions: {
            Button(lang.addIngredientBtn) { showAddSheet = true }
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Actions

    private func delete(at offsets: IndexSet) {
        let toDelete = offsets.map { filtered[$0] }
        for ingredient in toDelete {
            let recipeCount  = ingredient.recipeIngredients.count
            let storageCount = allStorageItems.filter {
                $0.ingredient?.persistentModelID == ingredient.persistentModelID
            }.count

            if recipeCount > 0 || storageCount > 0 {
                inUseAlert = InUseAlert(
                    title: lang.ingredientInUseTitle,
                    message: lang.ingredientInUseMessage(ingredient.name,
                                                         recipes: recipeCount,
                                                         storage: storageCount)
                )
            } else {
                modelContext.delete(ingredient)
            }
        }
    }
}

#Preview {
    IngredientListView()
        .environment(AppSettings())
        .modelContainer(for: [Ingredient.self, RecipeIngredient.self, Recipe.self],
                        inMemory: true)
}
