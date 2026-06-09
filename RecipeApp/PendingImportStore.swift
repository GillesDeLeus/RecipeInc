import Foundation

// Shared between the main app and BRecipeShare extension via App Group UserDefaults.
// IMPORTANT: appGroupID must exactly match the App Group configured in both targets'
// Signing & Capabilities → App Groups settings in Xcode.
// NOTE: this file exists as an identical copy in both targets — keep them in sync.

struct PendingImport: Codable, Identifiable {
    enum Kind: String, Codable { case url, text, image }
    var id: String = UUID().uuidString
    var kind: Kind
    var content: String
    var addedAt: Date = Date()
}

enum PendingImportStore {
    static let appGroupID = "group.brecipe.BRecipe"
    private static let key = "pendingImport"
    private static let imageFilename = "pending-import-image"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    private static var imageFileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent(imageFilename)
    }

    static func save(_ item: PendingImport) {
        guard let data = try? JSONEncoder().encode(item) else { return }
        defaults?.set(data, forKey: key)
    }

    /// Saves a shared image (e.g. a screenshot of a recipe). The bytes go to a
    /// file in the shared container — too large for UserDefaults — and a marker
    /// item is stored so the app knows to pick it up.
    static func saveImage(_ data: Data) {
        guard let fileURL = imageFileURL else { return }
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            return
        }
        save(PendingImport(kind: .image, content: imageFilename))
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

    /// Returns the shared image bytes and deletes the file.
    static func loadAndClearImageData() -> Data? {
        guard let fileURL = imageFileURL,
              let data = try? Data(contentsOf: fileURL) else { return nil }
        try? FileManager.default.removeItem(at: fileURL)
        return data
    }
}
