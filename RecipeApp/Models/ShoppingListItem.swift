import Foundation
import SwiftData

@Model
final class ShoppingListItem {

    var name: String
    var unit: String
    var amount: Double
    var category: ShoppingCategory
    var isChecked: Bool
    var addedAt: Date

    init(name: String,
         unit: String = "",
         amount: Double = 1,
         category: ShoppingCategory = .other) {
        self.name = name
        self.unit = unit
        self.amount = amount
        self.category = category
        self.isChecked = false
        self.addedAt = Date()
    }
}
