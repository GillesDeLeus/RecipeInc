import Foundation
import SwiftData

/// A single photo belonging to a recipe, stored outside the SQLite file.
@Model
final class RecipePhoto {
    @Attribute(.externalStorage) var imageData: Data = Data()
    var sortOrder: Int = 0
    var recipe: Recipe?

    init(imageData: Data, sortOrder: Int = 0) {
        self.imageData = imageData
        self.sortOrder = sortOrder
    }
}
