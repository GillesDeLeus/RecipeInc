import SwiftUI
import SwiftData

struct PersistentShoppingListView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \ShoppingListItem.name) private var items: [ShoppingListItem]

    @State private var vm = ShoppingListViewModel()

    private var lang: AppLanguage { appSettings.language }

    private var groupedItems: [(ShoppingCategory, [ShoppingListItem])] {
        vm.groupedItems(from: items, aisleOrder: appSettings.aisleOrder)
    }

    var body: some View {
        @Bindable var vm = vm
        NavigationStack {
            VStack(spacing: 0) {
                Group {
                    if items.isEmpty {
                        emptyState
                    } else if vm.isGrouped {
                        groupedList
                    } else {
                        flatList
                    }
                }
            }
            .navigationTitle(lang.shoppingList)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button { vm.showAddSheet = true } label: {
                        Label(lang.addItem, systemImage: "plus")
                    }
                }
                ToolbarItemGroup(placement: .secondaryAction) {
                    Button {
                        vm.isGrouped.toggle()
                    } label: {
                        Label(lang.groupByCategory,
                              systemImage: vm.isGrouped ? "rectangle.3.group.fill" : "rectangle.3.group")
                    }
                    if items.contains(where: { $0.isChecked }) {
                        Button(role: .destructive) {
                            vm.clearChecked(from: items, in: modelContext)
                        } label: {
                            Label(lang.clearChecked, systemImage: "trash")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $vm.showAddSheet) {
            AddShoppingItemSheet()
                .environment(appSettings)
        }
    }

    // MARK: - Subviews

    private var groupedList: some View {
        List {
            ForEach(groupedItems, id: \.0) { category, catItems in
                Section {
                    ForEach(catItems) { item in
                        itemRow(item)
                    }
                    .onDelete { offsets in
                        vm.deleteItems(catItems, at: offsets, in: modelContext)
                    }
                } header: {
                    Label(category.localizedName(in: lang), systemImage: category.icon)
                }
            }
        }
    }

    private var flatList: some View {
        List {
            ForEach(items) { item in
                itemRow(item)
            }
            .onDelete { offsets in
                vm.deleteItems(items, at: offsets, in: modelContext)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(lang.shoppingList, systemImage: "checklist")
        } description: {
            Text(lang.myListEmptyHint)
        } actions: {
            Button(lang.addShoppingItemTitle) { vm.showAddSheet = true }
                .buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    private func itemRow(_ item: ShoppingListItem) -> some View {
        Button {
            item.isChecked.toggle()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isChecked ? Color.green : Color.secondary)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.formattedItem(item))
                        .strikethrough(item.isChecked)
                        .foregroundStyle(item.isChecked ? Color.secondary : Color.primary)
                }

                Spacer()

                Image(systemName: item.category.icon)
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add item sheet

private struct AddShoppingItemSheet: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Ingredient.name) private var allIngredients: [Ingredient]

    @State private var name = ""
    @State private var amountText = "1"
    @State private var unit = ""
    @State private var category: ShoppingCategory = .other

    private var lang: AppLanguage { appSettings.language }

    private var suggestions: [Ingredient] {
        guard !name.isEmpty else { return [] }
        return allIngredients.filter { $0.name.localizedCaseInsensitiveContains(name) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(lang.nameLabel) {
                    TextField(lang.namePlaceholder, text: $name)
                        .autocorrectionDisabled()

                    ForEach(suggestions) { ingredient in
                        Button {
                            name = ingredient.name
                            unit = ingredient.unit
                            category = ingredient.shoppingCategory
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: ingredient.shoppingCategory.icon)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 22)
                                Text(ingredient.name)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if !ingredient.unit.isEmpty {
                                    Text(ingredient.unit)
                                        .foregroundStyle(.secondary)
                                        .font(.caption)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section {
                    HStack {
                        Text(lang.amountLabel)
                        Spacer()
                        TextField("1", text: $amountText)
                            .multilineTextAlignment(.trailing)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .frame(width: 80)
                    }
                    HStack {
                        Text(lang.unitLabel)
                        Spacer()
                        TextField(lang.unitLabel, text: $unit)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                }

                Section(lang.shoppingCategoryLabel) {
                    Picker(lang.shoppingCategoryLabel, selection: $category) {
                        ForEach(ShoppingCategory.allCases) { cat in
                            Label(cat.localizedName(in: lang), systemImage: cat.icon).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(lang.addShoppingItemTitle)
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.save) { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 1.0
        modelContext.insert(ShoppingListItem(
            name: name.trimmingCharacters(in: .whitespaces),
            unit: unit.trimmingCharacters(in: .whitespaces),
            amount: max(0.01, amount),
            category: category
        ))
        dismiss()
    }
}

#Preview {
    PersistentShoppingListView()
        .environment(AppSettings())
        .modelContainer(for: [ShoppingListItem.self, Ingredient.self], inMemory: true)
}
