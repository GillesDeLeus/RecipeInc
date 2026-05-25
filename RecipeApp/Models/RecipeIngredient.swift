import Foundation
import SwiftData

/// Junction model linking a `Recipe` to an `Ingredient` with a specific amount
/// calculated for **1 portion** in EU metrics.
@Model
final class RecipeIngredient {

    // MARK: - Properties

    /// Amount needed for 1 portion, expressed in the unit defined on `Ingredient`.
    var amount: Double = 0

    // MARK: - Relationships

    /// The base ingredient from the shared ingredient database.
    var ingredient: Ingredient?

    /// The recipe this line belongs to (set automatically by the Recipe relationship).
    var recipe: Recipe?

    // MARK: - Init

    init(ingredient: Ingredient, amount: Double) {
        self.ingredient = ingredient
        self.amount = amount
    }

    // MARK: - Computed helpers

    /// Human-readable display string, e.g. "200 g flour"
    var displayString: String {
        guard let ingredient else { return "Unknown ingredient" }
        let formattedAmount = amount.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(amount))
            : String(format: "%.1f", amount)
        return "\(formattedAmount) \(ingredient.unit) \(ingredient.name)"
    }
}
