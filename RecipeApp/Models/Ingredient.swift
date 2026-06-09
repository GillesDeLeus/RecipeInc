import Foundation
import SwiftData

enum ShoppingCategory: String, Codable, CaseIterable, Identifiable {
    case produce
    case dairy
    case meat
    case frozen
    case pantry
    case bakery
    case beverages
    case herbs
    case other

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .produce:   return "leaf"
        case .dairy:     return "drop.fill"
        case .meat:      return "fork.knife"
        case .frozen:    return "snowflake"
        case .pantry:    return "shippingbox"
        case .bakery:    return "birthday.cake"
        case .beverages: return "cup.and.saucer"
        case .herbs:     return "sparkles"
        case .other:     return "ellipsis.circle"
        }
    }

    var localizedName: String {
        switch self {
        case .produce:   return String(localized: "Produce")
        case .dairy:     return String(localized: "Dairy & Eggs")
        case .meat:      return String(localized: "Meat & Fish")
        case .frozen:    return String(localized: "Frozen")
        case .pantry:    return String(localized: "Pantry")
        case .bakery:    return String(localized: "Bakery")
        case .beverages: return String(localized: "Beverages")
        case .herbs:     return String(localized: "Herbs & Spices")
        case .other:     return String(localized: "Other")
        }
    }
}

/// A reusable ingredient stored in the shared ingredient database.
/// Recipes reference these ingredients via `RecipeIngredient`.
@Model
final class Ingredient {

    // MARK: - Properties

    var name: String = ""
    /// EU-metric unit label, e.g. "g", "ml", "stuk", "el", "tl"
    var unit: String = ""
    var createdAt: Date = Date()
    var shoppingCategory: ShoppingCategory

    // Nutritional values per 100 g (NEVO database)
    var caloriesPer100g:  Double? = nil
    var proteinPer100g:   Double? = nil
    var fatPer100g:       Double? = nil
    var satFatPer100g:    Double? = nil
    var carbsPer100g:     Double? = nil
    var sugarsPer100g:    Double? = nil
    var fiberPer100g:     Double? = nil
    var sodiumPer100g:    Double? = nil
    var potassiumPer100g: Double? = nil
    var calciumPer100g:   Double? = nil
    var ironPer100g:      Double? = nil
    var vitCPer100g:      Double? = nil
    var vitDPer100g:      Double? = nil

    // MARK: - Relationships

    /// All recipe-uses that reference this ingredient.
    /// Cascade-nullify: removing an ingredient sets the reference to nil
    /// in every RecipeIngredient that used it (handled in UI).
    @Relationship(deleteRule: .nullify, inverse: \RecipeIngredient.ingredient)
    var recipeIngredients: [RecipeIngredient] = []

    // MARK: - Init

    init(name: String, unit: String, shoppingCategory: ShoppingCategory = .other) {
        self.name = name
        self.unit = unit
        self.shoppingCategory = shoppingCategory
        self.createdAt = Date()
    }
}
