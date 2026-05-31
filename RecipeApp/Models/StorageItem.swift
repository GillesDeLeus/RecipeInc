import Foundation
import SwiftData

enum StorageLocation: String, Codable, CaseIterable {
    case freezer
    case refrigerator
    case foodCloset

    var icon: String {
        switch self {
        case .freezer:      return "snowflake"
        case .refrigerator: return "refrigerator"
        case .foodCloset:   return "cabinet"
        }
    }

    func localizedName(in language: AppLanguage) -> String {
        switch self {
        case .freezer:      return language.freezerName
        case .refrigerator: return language.refrigeratorName
        case .foodCloset:   return language.foodClosetName
        }
    }
}

@Model
final class StorageItem {
    @Relationship(deleteRule: .nullify) var ingredient: Ingredient?
    var amount: Double = 1
    var location: StorageLocation
    var expiryDate: Date?
    var createdAt: Date = Date()
    var notificationToken: String = UUID().uuidString

    init(ingredient: Ingredient? = nil,
         amount: Double = 1,
         location: StorageLocation = .foodCloset,
         expiryDate: Date? = nil) {
        self.ingredient = ingredient
        self.amount = amount
        self.location = location
        self.expiryDate = expiryDate
        self.createdAt = Date()
        self.notificationToken = UUID().uuidString
    }
}
