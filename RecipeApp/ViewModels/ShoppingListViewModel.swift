import Foundation
import SwiftData
import Observation

@Observable
final class ShoppingListViewModel {

    // MARK: UI State
    var showAddSheet = false
    var isGrouped = true

    // MARK: - Pure helpers

    func groupedItems(
        from items: [ShoppingListItem],
        aisleOrder: [ShoppingCategory]
    ) -> [(ShoppingCategory, [ShoppingListItem])] {
        aisleOrder.compactMap { cat in
            let catItems = items
                .filter { $0.category == cat }
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            return catItems.isEmpty ? nil : (cat, catItems)
        }
    }

    func formattedItem(_ item: ShoppingListItem) -> String {
        let amt = item.amount.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(item.amount))
            : String(format: "%.1f", item.amount)
        let amtStr = item.unit.isEmpty ? amt : "\(amt) \(item.unit)"
        return "\(amtStr) \(item.name)"
    }

    // MARK: - Mutations

    func clearChecked(from items: [ShoppingListItem], in context: ModelContext) {
        let checked = items.filter { $0.isChecked }
        let allIngredients = (try? context.fetch(FetchDescriptor<Ingredient>())) ?? []
        let allStorage = (try? context.fetch(FetchDescriptor<StorageItem>())) ?? []

        for shoppingItem in checked {
            let location = defaultStorageLocation(for: shoppingItem.category)
            let ingredient: Ingredient
            let isNew: Bool

            if let existing = allIngredients.first(where: {
                $0.name.localizedCaseInsensitiveCompare(shoppingItem.name) == .orderedSame
            }) {
                ingredient = existing
                isNew = false
            } else {
                let newIng = Ingredient(
                    name: shoppingItem.name,
                    unit: shoppingItem.unit,
                    shoppingCategory: shoppingItem.category
                )
                context.insert(newIng)
                ingredient = newIng
                isNew = true
            }

            if !isNew,
               let existing = allStorage.first(where: {
                   $0.ingredient === ingredient && $0.location == location
               }) {
                existing.amount += shoppingItem.amount
            } else {
                context.insert(StorageItem(
                    ingredient: ingredient,
                    amount: shoppingItem.amount,
                    location: location
                ))
            }
            context.delete(shoppingItem)
        }
    }

    func deleteItems(_ source: [ShoppingListItem], at offsets: IndexSet, in context: ModelContext) {
        offsets.map { source[$0] }.forEach { context.delete($0) }
    }

    private func defaultStorageLocation(for category: ShoppingCategory) -> StorageLocation {
        switch category {
        case .frozen:                  return .freezer
        case .dairy, .meat, .produce:  return .refrigerator
        default:                       return .foodCloset
        }
    }
}
