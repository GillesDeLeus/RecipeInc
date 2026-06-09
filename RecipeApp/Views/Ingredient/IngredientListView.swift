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
            .navigationTitle(String(localized: "Ingredients"))
            .searchable(text: $vm.searchText, prompt: String(localized: "Search ingredient…"))
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
                        Label(String(localized: "Sort"), systemImage: "arrow.up.arrow.down")
                    }

                    Button { vm.showFilterSheet = true } label: {
                        Label(String(localized: "Filter"), systemImage: vm.isFiltering
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                    }

                    Button { vm.showAddSheet = true } label: {
                        Label(String(localized: "Add"), systemImage: "plus")
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
                                 ? ingredient.shoppingCategory.localizedName
                                 : "\(ingredient.unit) · \(ingredient.shoppingCategory.localizedName)")
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
            Label(String(localized: "No Ingredients"), systemImage: "carrot")
        } description: {
            Text(String(localized: "Add your first ingredient with the + button."))
        } actions: {
            Button(String(localized: "Add Ingredient")) { vm.showAddSheet = true }
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Helpers

    private func sortLabel(for order: IngredientSortOrder) -> String {
        switch order {
        case .nameAsc:    return String(localized: "Name A–Z")
        case .nameDesc:   return String(localized: "Name Z–A")
        case .byCategory: return String(localized: "Category")
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
            vm.delete(ingredient: ingredient, storageItems: allStorageItems, in: modelContext)
        }
    }
}

// MARK: - Filter sheet

private struct IngredientFilterView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings
    @Binding var selectedCategories: Set<ShoppingCategory>


    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Category")) {
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
                                Text(category.localizedName)
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
            .navigationTitle(String(localized: "Filter"))
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Reset")) { selectedCategories = [] }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { dismiss() }
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
