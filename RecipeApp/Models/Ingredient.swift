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

    func localizedName(in lang: AppLanguage) -> String {
        switch self {
        case .produce:   return lang.categoryProduce
        case .dairy:     return lang.categoryDairy
        case .meat:      return lang.categoryMeat
        case .frozen:    return lang.categoryFrozen
        case .pantry:    return lang.categoryPantry
        case .bakery:    return lang.categoryBakery
        case .beverages: return lang.categoryBeverages
        case .herbs:     return lang.categoryHerbs
        case .other:     return lang.categoryOther
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
