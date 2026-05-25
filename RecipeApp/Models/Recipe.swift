import Foundation
import SwiftData

/// A recipe with a list of ingredients (1-portion amounts), step-by-step
/// instructions, and a preparation time.
@Model
final class Recipe {

    // MARK: - Properties

    var name: String = ""
    /// Step-by-step instructions as free-form text.
    var instructions: String = ""
    /// Total preparation time in minutes.
    var prepTimeMinutes: Int = 0
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var isFavorite: Bool = false
    var rating: Int = 0   // 0 = unrated, 1–5

    // MARK: - Relationships

    /// Ordered ingredient lines; cascade-deleted when the recipe is removed.
    @Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.recipe)
    var recipeIngredients: [RecipeIngredient] = []

    /// Photos; cascade-deleted when the recipe is removed.
    @Relationship(deleteRule: .cascade, inverse: \RecipePhoto.recipe)
    var photos: [RecipePhoto] = []

    var category: RecipeCategory?

    @Relationship(deleteRule: .nullify, inverse: \RecipeTag.recipes)
    var tags: [RecipeTag] = []

    // MARK: - Init

    init(name: String, instructions: String = "", prepTimeMinutes: Int = 0) {
        self.name = name
        self.instructions = instructions
        self.prepTimeMinutes = prepTimeMinutes
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed helpers

    /// Formatted prep time, e.g. "1 u 30 min" or "45 min".
    var formattedPrepTime: String {
        guard prepTimeMinutes > 0 else { return "–" }
        let hours = prepTimeMinutes / 60
        let minutes = prepTimeMinutes % 60
        if hours > 0 && minutes > 0 {
            return "\(hours) u \(minutes) min"
        } else if hours > 0 {
            return "\(hours) u"
        } else {
            return "\(minutes) min"
        }
    }
}
