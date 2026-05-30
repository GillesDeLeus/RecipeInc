import SwiftUI
import SwiftData
import TipKit

enum IngredientSortOrder: String, CaseIterable {
    case nameAsc, nameDesc, byCategory
}

struct IngredientListView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query private var ingredients: [Ingredient]
    @Query private var allStorageItems: [StorageItem]

    private let addIngredientTip = AddIngredientTip()

    @State private var searchText = ""
    @State private var showAddSheet = false
    @State private var ingredientToEdit: Ingredient?
    @State private var inUseAlert: InUseAlert?
    @State private var sortOrder: IngredientSortOrder = .nameAsc
    @State private var filterCategories: Set<ShoppingCategory> = []
    @State private var showFilterSheet = false

    private struct InUseAlert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    private var lang: AppLanguage { appSettings.language }

    private var isFiltering: Bool { !filterCategories.isEmpty }

    private var filtered: [Ingredient] {
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

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TipView(addIngredientTip)
                    .padding(.horizontal)
                    .padding(.top, 4)
                Group {
                    if ingredients.isEmpty {
                        emptyState
                    } else {
                        list
                    }
                }
            }
            .navigationTitle(lang.tabIngredients)
            .searchable(text: $searchText, prompt: lang.searchIngredient)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu {
                        ForEach(IngredientSortOrder.allCases, id: \.self) { order in
                            Button {
                                sortOrder = order
                            } label: {
                                HStack {
                                    Text(sortLabel(for: order))
                                    if sortOrder == order {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label(lang.sortLabel, systemImage: "arrow.up.arrow.down")
                    }

                    Button { showFilterSheet = true } label: {
                        Label(lang.filterTitle, systemImage: isFiltering
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                    }

                    Button { showAddSheet = true } label: {
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
        .sheet(isPresented: $showFilterSheet) {
            IngredientFilterView(selectedCategories: $filterCategories)
        }
    }

    // MARK: - Subviews

    private var list: some View {
        List {
            ForEach(filtered) { ingredient in
                Button {
                    ingredientToEdit = ingredient
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(categoryColor(ingredient.shoppingCategory).opacity(0.15))
                                .frame(width: 30, height: 30)
                            Image(systemName: ingredient.shoppingCategory.icon)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(categoryColor(ingredient.shoppingCategory))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ingredient.name)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text(ingredient.unit.isEmpty
                                 ? ingredient.shoppingCategory.localizedName(in: lang)
                                 : "\(ingredient.unit) · \(ingredient.shoppingCategory.localizedName(in: lang))")
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

    // MARK: - Helpers

    private func sortLabel(for order: IngredientSortOrder) -> String {
        switch order {
        case .nameAsc:    return lang.sortByNameAZ
        case .nameDesc:   return lang.sortByNameZA
        case .byCategory: return lang.sortByCategory
        }
    }

    private func categoryColor(_ category: ShoppingCategory) -> Color {
        switch category {
        case .produce:   return .green
        case .dairy:     return .blue
        case .meat:      return .red
        case .frozen:    return .cyan
        case .pantry:    return .brown
        case .bakery:    return .orange
        case .beverages: return .teal
        case .herbs:     return .mint
        case .other:     return .secondary
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

// MARK: - Filter sheet

private struct IngredientFilterView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings
    @Binding var selectedCategories: Set<ShoppingCategory>

    private var lang: AppLanguage { appSettings.language }

    var body: some View {
        NavigationStack {
            Form {
                Section(lang.shoppingCategoryLabel) {
                    ForEach(ShoppingCategory.allCases) { category in
                        Button {
                            if selectedCategories.contains(category) {
                                selectedCategories.remove(category)
                            } else {
                                selectedCategories.insert(category)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: category.icon)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20)
                                Text(category.localizedName(in: lang))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedCategories.contains(category) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(lang.filterTitle)
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.reset) { selectedCategories = [] }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.done) { dismiss() }
                }
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
