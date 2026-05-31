import SwiftUI
import SwiftData
import TipKit

struct IngredientListView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query private var ingredients: [Ingredient]
    @Query private var allStorageItems: [StorageItem]

    private let addIngredientTip = AddIngredientTip()

    @State private var vm = IngredientListViewModel()

    private var lang: AppLanguage { appSettings.language }

    private var filtered: [Ingredient] { vm.filtered(ingredients: ingredients) }

    // MARK: - Body

    var body: some View {
        @Bindable var vm = vm
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
            .searchable(text: $vm.searchText, prompt: lang.searchIngredient)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu {
                        ForEach(IngredientSortOrder.allCases, id: \.self) { order in
                            Button {
                                vm.sortOrder = order
                            } label: {
                                HStack {
                                    Text(sortLabel(for: order))
                                    if vm.sortOrder == order {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label(lang.sortLabel, systemImage: "arrow.up.arrow.down")
                    }

                    Button { vm.showFilterSheet = true } label: {
                        Label(lang.filterTitle, systemImage: vm.isFiltering
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                    }

                    Button { vm.showAddSheet = true } label: {
                        Label(lang.addItem, systemImage: "plus")
                    }
                }
            }
            .sheet(item: $vm.ingredientToEdit) { ingredient in
                IngredientFormView(ingredient: ingredient)
            }
            .alert(item: $vm.inUseAlert) { alert in
                Alert(title: Text(alert.title), message: Text(alert.message))
            }
        }
        .sheet(isPresented: $vm.showAddSheet) {
            IngredientFormView()
        }
        .sheet(isPresented: $vm.showFilterSheet) {
            IngredientFilterView(selectedCategories: $vm.filterCategories)
        }
    }

    // MARK: - Subviews

    private var list: some View {
        List {
            ForEach(filtered) { ingredient in
                Button {
                    vm.ingredientToEdit = ingredient
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
            Button(lang.addIngredientBtn) { vm.showAddSheet = true }
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

    private func delete(at offsets: IndexSet) {
        let toDelete = offsets.map { filtered[$0] }
        for ingredient in toDelete {
            vm.delete(ingredient: ingredient, storageItems: allStorageItems, in: modelContext, lang: lang)
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
