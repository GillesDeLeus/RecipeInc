import SwiftUI
import SwiftData

struct PersistentShoppingListView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \ShoppingListItem.name) private var items: [ShoppingListItem]

    @State private var showAddSheet = false
    @State private var isGrouped = true

    private var lang: AppLanguage { appSettings.language }

    private var groupedItems: [(ShoppingCategory, [ShoppingListItem])] {
        appSettings.aisleOrder.compactMap { cat in
            let catItems = items
                .filter { $0.category == cat }
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            return catItems.isEmpty ? nil : (cat, catItems)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Group {
                    if items.isEmpty {
                        emptyState
                    } else if isGrouped {
                        groupedList
                    } else {
                        flatList
                    }
                }
            }
            .navigationTitle(lang.shoppingList)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button { showAddSheet = true } label: {
                        Label(lang.addItem, systemImage: "plus")
                    }
                }
                ToolbarItemGroup(placement: .secondaryAction) {
                    Button {
                        isGrouped.toggle()
                    } label: {
                        Label(lang.groupByCategory,
                              systemImage: isGrouped ? "rectangle.3.group.fill" : "rectangle.3.group")
                    }
                    if items.contains(where: { $0.isChecked }) {
                        Button(role: .destructive) {
                            clearChecked()
                        } label: {
                            Label(lang.clearChecked, systemImage: "trash")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
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
                        deleteItems(catItems, at: offsets)
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
                deleteItems(items, at: offsets)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(lang.shoppingList, systemImage: "checklist")
        } description: {
            Text(lang.myListEmptyHint)
        } actions: {
            Button(lang.addShoppingItemTitle) { showAddSheet = true }
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
                    Text(formattedItem(item))
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

    // MARK: - Helpers

    private func formattedItem(_ item: ShoppingListItem) -> String {
        let amt = item.amount.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(item.amount))
            : String(format: "%.1f", item.amount)
        let amtStr = item.unit.isEmpty ? amt : "\(amt) \(item.unit)"
        return "\(amtStr) \(item.name)"
    }

    private func clearChecked() {
        let checked = items.filter { $0.isChecked }
        let allIngredients = (try? modelContext.fetch(FetchDescriptor<Ingredient>())) ?? []
        let allStorage = (try? modelContext.fetch(FetchDescriptor<StorageItem>())) ?? []
        for shoppingItem in checked {
            let location = defaultLocation(for: shoppingItem.category)
            let ingredient: Ingredient
            let isNew: Bool
            if let existing = allIngredients.first(where: {
                $0.name.localizedCaseInsensitiveCompare(shoppingItem.name) == .orderedSame
            }) {
                ingredient = existing
                isNew = false
            } else {
                let newIng = Ingredient(name: shoppingItem.name, unit: shoppingItem.unit, shoppingCategory: shoppingItem.category)
                modelContext.insert(newIng)
                ingredient = newIng
                isNew = true
            }
            if !isNew, let existing = allStorage.first(where: { $0.ingredient === ingredient && $0.location == location }) {
                existing.amount += shoppingItem.amount
            } else {
                modelContext.insert(StorageItem(ingredient: ingredient, amount: shoppingItem.amount, location: location))
            }
            modelContext.delete(shoppingItem)
        }
    }

    private func defaultLocation(for category: ShoppingCategory) -> StorageLocation {
        switch category {
        case .frozen:                  return .freezer
        case .dairy, .meat, .produce:  return .refrigerator
        default:                       return .foodCloset
        }
    }

    private func deleteItems(_ source: [ShoppingListItem], at offsets: IndexSet) {
        offsets.map { source[$0] }.forEach { modelContext.delete($0) }
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
