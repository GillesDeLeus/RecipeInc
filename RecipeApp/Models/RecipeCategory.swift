import Foundation
import SwiftData

@Model
final class RecipeCategory {
    var name: String = ""
    var isCustom: Bool = false

    @Relationship(deleteRule: .nullify, inverse: \Recipe.category)
    var recipes: [Recipe] = []

    init(name: String, isCustom: Bool = false) {
        self.name = name
        self.isCustom = isCustom
    }
}
