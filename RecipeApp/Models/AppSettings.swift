import Foundation
import Observation

/// App-wide user settings persisted in UserDefaults.
/// Language is no longer managed here — the app follows the system/per-app
/// language (iOS Settings → Koen’s Kitchen → Language) via String Catalogs.
@Observable
final class AppSettings {

    // Feature flags — default ON on first launch
    var featureStorage: Bool {
        didSet { UserDefaults.standard.set(featureStorage, forKey: "featureStorage") }
    }
    var featureCalendar: Bool {
        didSet { UserDefaults.standard.set(featureCalendar, forKey: "featureCalendar") }
    }
    var featureAIImport: Bool {
        didSet { UserDefaults.standard.set(featureAIImport, forKey: "featureAIImport") }
    }
    var featureNutrition: Bool {
        didSet { UserDefaults.standard.set(featureNutrition, forKey: "featureNutrition") }
    }
    var featureShopping: Bool {
        didSet { UserDefaults.standard.set(featureShopping, forKey: "featureShopping") }
    }
    var notificationHour: Int {
        didSet { UserDefaults.standard.set(notificationHour, forKey: "notificationHour") }
    }
    var notificationMinute: Int {
        didSet { UserDefaults.standard.set(notificationMinute, forKey: "notificationMinute") }
    }
    var aisleOrder: [ShoppingCategory] {
        didSet {
            if let data = try? JSONEncoder().encode(aisleOrder) {
                UserDefaults.standard.set(data, forKey: "aisleOrder")
            }
        }
    }

    init() {
        Self.migrateLegacyLanguageChoice()
        // Use object(forKey:) so missing key → nil → default true (not false)
        self.featureStorage   = UserDefaults.standard.object(forKey: "featureStorage")   as? Bool ?? true
        self.featureCalendar  = UserDefaults.standard.object(forKey: "featureCalendar")  as? Bool ?? true
        self.featureAIImport  = UserDefaults.standard.object(forKey: "featureAIImport")  as? Bool ?? true
        self.featureNutrition = UserDefaults.standard.object(forKey: "featureNutrition") as? Bool ?? true
        self.featureShopping  = UserDefaults.standard.object(forKey: "featureShopping")  as? Bool ?? true
        self.notificationHour   = UserDefaults.standard.object(forKey: "notificationHour")   as? Int ?? 9
        self.notificationMinute = UserDefaults.standard.object(forKey: "notificationMinute") as? Int ?? 0
        // Restore saved order; append any categories added in future app updates
        if let data = UserDefaults.standard.data(forKey: "aisleOrder"),
           let order = try? JSONDecoder().decode([ShoppingCategory].self, from: data) {
            let missing = ShoppingCategory.allCases.filter { !order.contains($0) }
            self.aisleOrder = order + missing
        } else {
            self.aisleOrder = ShoppingCategory.allCases
        }
    }

    /// One-time: users who picked Dutch in the old in-app switcher keep Dutch
    /// by carrying the choice over to the system per-app language setting.
    /// (Takes effect on the next launch, like any AppleLanguages change.)
    private static func migrateLegacyLanguageChoice() {
        let defaults = UserDefaults.standard
        guard let legacy = defaults.string(forKey: "appLanguage") else { return }
        if legacy == "nl", defaults.array(forKey: "AppleLanguages") == nil {
            defaults.set(["nl"], forKey: "AppleLanguages")
        }
        defaults.removeObject(forKey: "appLanguage")
    }
}
