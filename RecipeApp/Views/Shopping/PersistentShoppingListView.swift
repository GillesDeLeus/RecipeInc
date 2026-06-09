import SwiftUI
import SwiftData

struct PersistentShoppingListView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \ShoppingListItem.name) private var items: [ShoppingListItem]

    @State private var vm = ShoppingListViewModel()


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
            .navigationTitle(String(localized: "Shopping List"))
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button { vm.showAddSheet = true } label: {
                        Label(String(localized: "Add"), systemImage: "plus")
                    }
                }
                ToolbarItemGroup(placement: .secondaryAction) {
                    Button {
                        vm.isGrouped.toggle()
                    } label: {
                        Label(String(localized: "Group by Category"),
                              systemImage: vm.isGrouped ? "rectangle.3.group.fill" : "rectangle.3.group")
                    }
                    if items.contains(where: { $0.isChecked }) {
                        Button(role: .destructive) {
                            vm.clearChecked(from: items, in: modelContext)
                        } label: {
                            Label(String(localized: "Clear Checked"), systemImage: "trash")
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
                    Label(category.localizedName, systemImage: category.icon)
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
            Label(String(localized: "Shopping List"), systemImage: "checklist")
        } description: {
            Text(String(localized: "Add items manually or tap \"Add All to My List\" from a meal plan."))
        } actions: {
            Button(String(localized: "Add Item")) { vm.showAddSheet = true }
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


    private var suggestions: [Ingredient] {
        guard !name.isEmpty else { return [] }
        return allIngredients.filter { $0.name.localizedCaseInsensitiveContains(name) }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Name")) {
                    TextField(String(localized: "e.g. flour, butter, milk…"), text: $name)
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
                        Text(String(localized: "Amount"))
                        Spacer()
                        TextField("1", text: $amountText)
                            .multilineTextAlignment(.trailing)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .frame(width: 80)
                    }
                    HStack {
                        Text(String(localized: "Unit"))
                        Spacer()
                        TextField(String(localized: "Unit"), text: $unit)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 120)
                    }
                }

                Section(String(localized: "Category")) {
                    Picker(String(localized: "Category"), selection: $category) {
                        ForEach(ShoppingCategory.allCases) { cat in
                            Label(cat.localizedName, systemImage: cat.icon).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(String(localized: "Add Item"))
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) { save() }
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
