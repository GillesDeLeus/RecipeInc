import Foundation
import SwiftData

enum MealType: String, Codable, CaseIterable {
    case breakfast, lunch, dinner, snack, other

    var sortOrder: Int {
        switch self {
        case .breakfast: return 0
        case .lunch:     return 1
        case .dinner:    return 2
        case .snack:     return 3
        case .other:     return 4
        }
    }

    var icon: String {
        switch self {
        case .breakfast: return "sunrise"
        case .lunch:     return "sun.max"
        case .dinner:    return "moon.stars"
        case .snack:     return "cup.and.saucer"
        case .other:     return "fork.knife"
        }
    }

    var localizedName: String {
        switch self {
        case .breakfast: return String(localized: "Breakfast")
        case .lunch:     return String(localized: "Lunch")
        case .dinner:    return String(localized: "Dinner")
        case .snack:     return String(localized: "Snack")
        case .other:     return String(localized: "Other")
        }
    }
}

@Model
final class MealPlan {
    var date: Date = Date()
    var mealType: MealType
    var portions: Int = 1
    var notes: String = ""
    var customName: String = ""

    @Relationship(deleteRule: .nullify)
    var recipe: Recipe?

    var createdAt: Date = Date()

    var displayName: String {
        if let recipe { return recipe.name }
        return customName.isEmpty ? String(localized: "Meal") : customName
    }

    init(date: Date,
         mealType: MealType = .dinner,
         portions: Int = 1,
         notes: String = "",
         recipe: Recipe? = nil,
         customName: String = "") {
        self.date = Calendar.current.startOfDay(for: date)
        self.mealType = mealType
        self.portions = portions
        self.notes = notes
        self.recipe = recipe
        self.customName = customName
        self.createdAt = Date()
    }
}
