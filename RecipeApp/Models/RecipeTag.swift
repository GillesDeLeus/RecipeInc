import Foundation
import SwiftData

@Model
final class RecipeTag {
    var name: String = ""
    var colorHex: String = "#007AFF"
    var isCustom: Bool = false

    var recipes: [Recipe] = []

    static let presetColors = [
        "#FF3B30", "#FF9500", "#FFCC00", "#34C759", "#00C7BE",
        "#007AFF", "#5856D6", "#BF5AF2", "#FF2D55", "#8E8E93"
    ]

    init(name: String, colorHex: String = "#007AFF", isCustom: Bool = false) {
        self.name = name
        self.colorHex = colorHex
        self.isCustom = isCustom
    }
}
