import SwiftUI
import SwiftData

struct ShoppingListView: View {

    let selectedDates: Set<Date>

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \MealPlan.date) private var allMealPlans: [MealPlan]
    @Query private var allStorageItems: [StorageItem]


    private struct ShoppingItem: Identifiable {
        let id: String   // "name|unit"
        let name: String
        let unit: String
        var amount: Double
        let category: ShoppingCategory
    }

    @State private var checkedIDs: Set<String> = []
    @State private var isGrouped = false
    @State private var deductStorage = false
    @State private var showShareSheet = false
    @State private var showAisleOrder = false

    // MARK: - Computed lists

    private var mealPlans: [MealPlan] {
        allMealPlans.filter { meal in
            selectedDates.contains { selected in
                Calendar.current.isDate(meal.date, inSameDayAs: selected)
            }
        }
    }

    private var shoppingItems: [ShoppingItem] {
        var accumulated: [String: ShoppingItem] = [:]
        for meal in mealPlans {
            guard let recipe = meal.recipe else { continue }
            for ri in recipe.recipeIngredients {
                guard let ingredient = ri.ingredient else { continue }
                let key = "\(ingredient.name)|\(ingredient.unit)"
                let scaled = ri.amount * Double(meal.portions)
                if var existing = accumulated[key] {
                    existing.amount += scaled
                    accumulated[key] = existing
                } else {
                    accumulated[key] = ShoppingItem(
                        id: key,
                        name: ingredient.name,
                        unit: ingredient.unit,
                        amount: scaled,
                        category: ingredient.shoppingCategory
                    )
                }
            }
        }
        return accumulated.values.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    private var itemsByCategory: [(ShoppingCategory, [ShoppingItem])] {
        appSettings.aisleOrder.compactMap { cat in
            let items = shoppingItems.filter { $0.category == cat }
            return items.isEmpty ? nil : (cat, items)
        }
    }

    private var recipeMeals: [MealPlan]  { mealPlans.filter { $0.recipe != nil } }
    private var customMeals: [MealPlan]  { mealPlans.filter { $0.recipe == nil } }
    private var sortedDates: [Date]      { selectedDates.sorted() }

    /// Total stored amount keyed by "name|unit" — mirrors ShoppingItem.id.
    private var storageByKey: [String: Double] {
        var result: [String: Double] = [:]
        for item in allStorageItems {
            guard let ingredient = item.ingredient else { continue }
            let key = "\(ingredient.name)|\(ingredient.unit)"
            result[key, default: 0] += item.amount
        }
        return result
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if shoppingItems.isEmpty {
                    ContentUnavailableView {
                        Label(String(localized: "Shopping List"), systemImage: "cart")
                    } description: {
                        Text(String(localized: "No recipe ingredients for the selected meals."))
                    }
                } else {
                    List {
                        // ── Selected dates ────────────────────────
                        Section(String(localized: "Selected Dates")) {
                            ForEach(sortedDates, id: \.self) { date in
                                Text(date, style: .date)
                                    .font(.subheadline)
                            }
                        }

                        // ── Recipes / portions ────────────────────
                        if !recipeMeals.isEmpty {
                            Section(String(localized: "Recipes")) {
                                ForEach(recipeMeals) { meal in
                                    HStack {
                                        Text(meal.recipe?.name ?? "")
                                        Spacer()
                                        let p = meal.portions
                                        Text("\(p) \(p == 1 ? String(localized: "portion") : String(localized: "portions"))")
                                            .foregroundStyle(.secondary)
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }

                        // ── Custom meals ──────────────────────────
                        if !customMeals.isEmpty {
                            Section(String(localized: "Custom Meals (no ingredients)")) {
                                ForEach(customMeals) { meal in
                                    Text(meal.displayName)
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                }
                            }
                        }

                        // ── Ingredient checklist ──────────────────
                        if isGrouped {
                            ForEach(itemsByCategory, id: \.0) { category, items in
                                Section {
                                    ForEach(items) { item in
                                        itemRow(item)
                                    }
                                } header: {
                                    Label(category.localizedName,
                                          systemImage: category.icon)
                                }
                            }
                        } else {
                            Section(String(localized: "Ingredients")) {
                                ForEach(shoppingItems) { item in
                                    itemRow(item)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "Shopping List"))
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                }
                ToolbarItem(placement: .secondaryAction) {
                    #if os(iOS)
                    Button { showShareSheet = true } label: {
                        Label(String(localized: "Share List"), systemImage: "square.and.arrow.up")
                    }
                    .disabled(shoppingItems.isEmpty)
                    #else
                    ShareLink(item: shareText) {
                        Label(String(localized: "Share List"), systemImage: "square.and.arrow.up")
                    }
                    .disabled(shoppingItems.isEmpty)
                    #endif
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        isGrouped.toggle()
                    } label: {
                        Label(String(localized: "Group by Category"),
                              systemImage: isGrouped ? "rectangle.3.group.fill" : "rectangle.3.group")
                    }
                    .disabled(shoppingItems.isEmpty)
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        deductStorage.toggle()
                    } label: {
                        Label(String(localized: "Deduct from storage"),
                              systemImage: deductStorage ? "house.fill" : "house")
                    }
                    .disabled(shoppingItems.isEmpty)
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        showAisleOrder = true
                    } label: {
                        Label(String(localized: "Aisle Order"), systemImage: "arrow.up.arrow.down.square")
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        addAllToMyList()
                    } label: {
                        Label(String(localized: "Add All to My List"), systemImage: "checklist.checked")
                    }
                    .disabled(shoppingItems.isEmpty)
                }
            }
            .navigationDestination(isPresented: $showAisleOrder) {
                AisleOrderView()
            }
        }
        #if os(iOS)
        .sheet(isPresented: $showShareSheet) {
            ActivityShareView(text: shareText)
        }
        #endif
        #if os(macOS)
        .frame(minWidth: 460, minHeight: 520)
        #endif
    }

    // MARK: - Share text

    private var shareText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        var lines: [String] = [String(localized: "Shopping List"), ""]

        lines.append(sortedDates.map { formatter.string(from: $0) }.joined(separator: " · "))

        if !recipeMeals.isEmpty {
            lines.append("")
            lines.append(String(localized: "Recipes") + ":")
            for meal in recipeMeals {
                let p = meal.portions
                let portionStr = "\(p) \(p == 1 ? String(localized: "portion") : String(localized: "portions"))"
                lines.append("• \(meal.recipe?.name ?? "") (\(portionStr))")
            }
        }

        lines.append("")
        lines.append(String(localized: "Ingredients") + ":")
        for item in shoppingItems {
            let stored = deductStorage ? (storageByKey[item.id] ?? 0) : 0
            let needed = max(0, item.amount - stored)
            let isFullyCovered = deductStorage && needed == 0
            let prefix = (checkedIDs.contains(item.id) || isFullyCovered) ? "✓" : "•"
            let suffix = isFullyCovered
                ? " (\(String(localized: "In storage").lowercased()))"
                : (stored > 0 && needed > 0 ? " (\(String(localized: "have \(formatAmount(stored, unit: item.unit)) in storage")))" : "")
            lines.append("\(prefix) \(formattedItem(item, amount: isFullyCovered ? item.amount : needed))\(suffix)")
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Add all to persistent list

    private func addAllToMyList() {
        let existing = (try? modelContext.fetch(FetchDescriptor<ShoppingListItem>())) ?? []
        for item in shoppingItems {
            let stored = deductStorage ? (storageByKey[item.id] ?? 0) : 0
            let needed = max(0, item.amount - stored)
            guard needed > 0 else { continue }
            if let match = existing.first(where: { $0.name == item.name && $0.unit == item.unit }) {
                match.amount += needed
            } else {
                modelContext.insert(ShoppingListItem(
                    name: item.name,
                    unit: item.unit,
                    amount: needed,
                    category: item.category
                ))
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func itemRow(_ item: ShoppingItem) -> some View {
        let stored = deductStorage ? (storageByKey[item.id] ?? 0) : 0
        let needed = max(0, item.amount - stored)
        let isFullyCovered = deductStorage && needed == 0
        let isPartiallyCovered = deductStorage && stored > 0 && needed > 0
        let isChecked = checkedIDs.contains(item.id)

        Button {
            if isChecked { checkedIDs.remove(item.id) } else { checkedIDs.insert(item.id) }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isFullyCovered
                      ? "checkmark.seal.fill"
                      : (isChecked ? "checkmark.circle.fill" : "circle"))
                    .foregroundStyle(isFullyCovered || isChecked ? Color.green : Color.secondary)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(formattedItem(item, amount: isFullyCovered ? item.amount : needed))
                        .strikethrough(isChecked || isFullyCovered)
                        .foregroundStyle(isChecked || isFullyCovered ? Color.secondary : Color.primary)

                    if isFullyCovered {
                        Text(String(localized: "In storage"))
                            .font(.caption)
                            .foregroundStyle(.green)
                    } else if isPartiallyCovered {
                        Text(String(localized: "have \(formatAmount(stored, unit: item.unit)) in storage"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func formatAmount(_ amount: Double, unit: String) -> String {
        let s = amount.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(amount))
            : String(format: "%.1f", amount)
        return unit.isEmpty ? s : "\(s) \(unit)"
    }

    private func formattedItem(_ item: ShoppingItem, amount: Double? = nil) -> String {
        formatAmount(amount ?? item.amount, unit: item.unit) + " \(item.name)"
    }
}

// MARK: - iOS share sheet wrapper

#if os(iOS)
private struct ActivityShareView: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

#Preview {
    ShoppingListView(selectedDates: [Calendar.current.startOfDay(for: Date())])
        .environment(AppSettings())
        .modelContainer(for: [MealPlan.self, Recipe.self, Ingredient.self, RecipeIngredient.self,
                               StorageItem.self],
                        inMemory: true)
}
