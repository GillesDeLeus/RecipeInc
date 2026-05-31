import Foundation

// Shared between the main app and BRecipeShare extension via App Group UserDefaults.
// IMPORTANT: appGroupID must exactly match the App Group configured in both targets'
// Signing & Capabilities → App Groups settings in Xcode.

struct PendingImport: Codable, Identifiable {
    enum Kind: String, Codable { case url, text }
    var id: String = UUID().uuidString
    var kind: Kind
    var content: String
    var addedAt: Date = Date()
}

enum PendingImportStore {
    static let appGroupID = "group.brecipe.BRecipe"
    private static let key = "pendingImport"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func save(_ item: PendingImport) {
        guard let data = try? JSONEncoder().encode(item) else { return }
        defaults?.set(data, forKey: key)
    }

    /// Returns the stored item and clears it atomically.
    static func loadAndClear() -> PendingImport? {
        guard let data = defaults?.data(forKey: key),
              let item = try? JSONDecoder().decode(PendingImport.self, from: data) else {
            return nil
        }
        defaults?.removeObject(forKey: key)
        return item
    }
}
