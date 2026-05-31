import Foundation
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "RecipeApp", category: "Barcode")

private let barcodeSession: URLSession = {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 10
    config.timeoutIntervalForResource = 15
    return URLSession(configuration: config)
}()

struct BarcodeProduct {
    let name: String
    let unit: String
    let category: ShoppingCategory
    let caloriesPer100g: Double?
    let proteinPer100g:  Double?
    let fatPer100g:      Double?
    let carbsPer100g:    Double?
    let fiberPer100g:    Double?
}

enum BarcodeServiceError: LocalizedError {
    case notFound
    var errorDescription: String? { "Product not found in database." }
}

enum BarcodeService {

    static func lookup(barcode: String) async throws -> BarcodeProduct {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        guard let url = URL(string: urlString) else { throw BarcodeServiceError.notFound }

        logger.debug("Looking up barcode: \(barcode)")
        let (data, _) = try await barcodeSession.data(from: url)

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              (json["status"] as? Int) == 1,
              let product = json["product"] as? [String: Any]
        else {
            logger.notice("Barcode not found: \(barcode)")
            throw BarcodeServiceError.notFound
        }

        // Prefer Dutch name, fall back to generic product name
        let nameCandidates = [product["product_name_nl"], product["product_name"]]
            .compactMap { ($0 as? String)?.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard let name = nameCandidates.first else { throw BarcodeServiceError.notFound }

        let unit     = deriveUnit(from: product["quantity"] as? String)
        let category = mapCategory(from: product["categories_tags"] as? [String] ?? [])

        let nutriments = product["nutriments"] as? [String: Any]
        return BarcodeProduct(
            name:           name,
            unit:           unit,
            category:       category,
            caloriesPer100g: doubleValue(nutriments, key: "energy-kcal_100g"),
            proteinPer100g:  doubleValue(nutriments, key: "proteins_100g"),
            fatPer100g:      doubleValue(nutriments, key: "fat_100g"),
            carbsPer100g:    doubleValue(nutriments, key: "carbohydrates_100g"),
            fiberPer100g:    doubleValue(nutriments, key: "fiber_100g")
        )
    }

    // MARK: - Helpers

    private static func doubleValue(_ dict: [String: Any]?, key: String) -> Double? {
        guard let dict else { return nil }
        if let d = dict[key] as? Double { return d }
        if let i = dict[key] as? Int    { return Double(i) }
        if let s = dict[key] as? String { return Double(s) }
        return nil
    }

    private static func deriveUnit(from quantity: String?) -> String {
        guard let q = quantity?.lowercased() else { return "" }
        if q.contains("kg")                                    { return "kg" }
        if q.contains("g"), !q.contains("mg")                 { return "g" }
        if q.contains("cl")                                    { return "cl" }
        if q.contains("ml")                                    { return "ml" }
        if q.contains("l"), !q.contains("cl"), !q.contains("ml") { return "l" }
        return ""
    }

    private static func mapCategory(from tags: [String]) -> ShoppingCategory {
        let s = tags.joined(separator: " ")
        if s.contains("dairy") || s.contains("milk") || s.contains("cheese") || s.contains("egg") {
            return .dairy
        }
        if s.contains("meat") || s.contains("fish") || s.contains("seafood") || s.contains("poultry") {
            return .meat
        }
        if s.contains("frozen") { return .frozen }
        if s.contains("beverage") || s.contains("drink") || s.contains("juice") || s.contains("water") {
            return .beverages
        }
        if s.contains("herb") || s.contains("spice") || s.contains("seasoning") { return .herbs }
        if s.contains("bread") || s.contains("bakery") || s.contains("pastry")  { return .bakery }
        if s.contains("vegetable") || s.contains("fruit") || s.contains("produce") || s.contains("fresh") {
            return .produce
        }
        if s.contains("pasta") || s.contains("cereal") || s.contains("flour") ||
           s.contains("rice")  || s.contains("grain")  || s.contains("dry") {
            return .pantry
        }
        return .other
    }
}
