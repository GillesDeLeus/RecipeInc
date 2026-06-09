import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers
import OSLog

nonisolated private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "RecipeApp", category: "DataExport")

// MARK: - Codable transfer types

nonisolated private struct AppExportData: Codable {
    let version: Int
    let exportDate: Date
    let ingredients: [IngredientRecord]
    let categories: [CategoryRecord]
    let tags: [TagRecord]
    let recipes: [RecipeRecord]
    let storageItems: [StorageItemRecord]
    let mealPlans: [MealPlanRecord]
}

nonisolated private struct IngredientRecord: Codable {
    let name: String
    let unit: String
    let shoppingCategory: String
    let caloriesPer100g: Double?
    let proteinPer100g:  Double?
    let fatPer100g:      Double?
    let carbsPer100g:    Double?
    let fiberPer100g:    Double?
}

nonisolated private struct CategoryRecord: Codable {
    let name: String
    let isCustom: Bool
}

nonisolated private struct TagRecord: Codable {
    let name: String
    let colorHex: String
    let isCustom: Bool
}

nonisolated private struct RecipeIngredientRecord: Codable {
    let ingredientName: String
    let amount: Double
}

nonisolated private struct RecipeRecord: Codable {
    let name: String
    let prepTimeMinutes: Int
    let instructions: String
    let isFavorite: Bool
    let categoryName: String?
    let tagNames: [String]
    let ingredients: [RecipeIngredientRecord]
    let photos: [String]
}

nonisolated private struct StorageItemRecord: Codable {
    let ingredientName: String
    let amount: Double
    let location: String
    let expiryDate: Date?
}

nonisolated private struct MealPlanRecord: Codable {
    let date: Date
    let mealType: String
    let recipeName: String?
    let customName: String
    let portions: Int
    let notes: String
}

// MARK: - FileDocument wrapper

struct JSONFile: FileDocument {
    static let readableContentTypes: [UTType] = [.json]
    var data: Data

    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - Import conflict

struct ImportConflict: Identifiable {
    let id = UUID()
    let kind: String
    let name: String
    let existingDetail: String
    let importedDetail: String
    var useImported: Bool = false
    let applyImported: () -> Void
}

// MARK: - Import result / outcome

struct ImportResult {
    let ingredientsAdded: Int
    let categoriesAdded: Int
    let tagsAdded: Int
    let recipesAdded: Int
    let storageItemsAdded: Int
    let mealPlansAdded: Int

    func summary() -> String {
        var parts: [String] = []
        if recipesAdded > 0      { parts.append(String(localized: "\(recipesAdded) recipes")) }
        if ingredientsAdded > 0  { parts.append(String(localized: "\(ingredientsAdded) ingredients")) }
        if storageItemsAdded > 0 { parts.append(String(localized: "\(storageItemsAdded) storage items")) }
        if mealPlansAdded > 0    { parts.append(String(localized: "\(mealPlansAdded) meals")) }
        if categoriesAdded > 0   { parts.append(String(localized: "\(categoriesAdded) categories")) }
        if tagsAdded > 0         { parts.append(String(localized: "\(tagsAdded) tags")) }
        return parts.isEmpty ? String(localized: "Nothing new to import.") : parts.joined(separator: "\n")
    }
}

struct ImportOutcome {
    let result: ImportResult
    let conflicts: [ImportConflict]
}

// MARK: - Service

enum DataExportService {

    // MARK: Export

    /// Safe to run on a background ModelContext; operates only on the context it is given.
    nonisolated static func export(from context: ModelContext) throws -> Data {
        logger.info("Starting export")
        let ingredients  = try context.fetch(FetchDescriptor<Ingredient>())
        let categories   = try context.fetch(FetchDescriptor<RecipeCategory>())
        let tags         = try context.fetch(FetchDescriptor<RecipeTag>())
        let recipes      = try context.fetch(FetchDescriptor<Recipe>())
        let storageItems = try context.fetch(FetchDescriptor<StorageItem>())
        let mealPlans    = try context.fetch(FetchDescriptor<MealPlan>())

        let ingredientRecords = ingredients.map {
            IngredientRecord(name: $0.name, unit: $0.unit,
                             shoppingCategory: $0.shoppingCategory.rawValue,
                             caloriesPer100g: $0.caloriesPer100g,
                             proteinPer100g:  $0.proteinPer100g,
                             fatPer100g:      $0.fatPer100g,
                             carbsPer100g:    $0.carbsPer100g,
                             fiberPer100g:    $0.fiberPer100g)
        }
        let categoryRecords = categories.map {
            CategoryRecord(name: $0.name, isCustom: $0.isCustom)
        }
        let tagRecords = tags.map {
            TagRecord(name: $0.name, colorHex: $0.colorHex, isCustom: $0.isCustom)
        }
        let recipeRecords = recipes.map { recipe -> RecipeRecord in
            let riRecords = recipe.recipeIngredients.compactMap { ri -> RecipeIngredientRecord? in
                guard let ing = ri.ingredient else { return nil }
                return RecipeIngredientRecord(ingredientName: ing.name, amount: ri.amount)
            }
            let photoStrings = recipe.photos
                .sorted { $0.sortOrder < $1.sortOrder }
                .map { $0.imageData.base64EncodedString() }
            return RecipeRecord(
                name: recipe.name,
                prepTimeMinutes: recipe.prepTimeMinutes,
                instructions: recipe.instructions,
                isFavorite: recipe.isFavorite,
                categoryName: recipe.category?.name,
                tagNames: recipe.tags.map { $0.name },
                ingredients: riRecords,
                photos: photoStrings
            )
        }
        let storageRecords = storageItems.compactMap { item -> StorageItemRecord? in
            guard let ing = item.ingredient else { return nil }
            return StorageItemRecord(
                ingredientName: ing.name,
                amount: item.amount,
                location: item.location.rawValue,
                expiryDate: item.expiryDate
            )
        }
        let mealRecords = mealPlans.map { meal in
            MealPlanRecord(
                date: meal.date,
                mealType: meal.mealType.rawValue,
                recipeName: meal.recipe?.name,
                customName: meal.customName,
                portions: meal.portions,
                notes: meal.notes
            )
        }

        let payload = AppExportData(
            version: 1,
            exportDate: Date(),
            ingredients: ingredientRecords,
            categories: categoryRecords,
            tags: tagRecords,
            recipes: recipeRecords,
            storageItems: storageRecords,
            mealPlans: mealRecords
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        logger.info("Export complete: \(recipes.count) recipes, \(ingredients.count) ingredients")
        return data
    }

    // MARK: Import

    static func `import`(from data: Data, into context: ModelContext) throws -> ImportOutcome {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(AppExportData.self, from: data)

        // uniquingKeysWith keeps the first when the local DB has duplicate-named rows
        var knownIngredients  = try nameLookup(Ingredient.self,     context: context) { $0.name }
        var knownCategories   = try nameLookup(RecipeCategory.self,  context: context) { $0.name }
        var knownTags         = try nameLookup(RecipeTag.self,        context: context) { $0.name }
        var knownRecipes      = try nameLookup(Recipe.self,           context: context) { $0.name }

        var conflicts: [ImportConflict] = []
        var ingredientsAdded = 0, categoriesAdded = 0, tagsAdded = 0
        var recipesAdded = 0, storageItemsAdded = 0, mealPlansAdded = 0

        // ── Ingredients ──────────────────────────────────────────
        for r in payload.ingredients {
            let key = r.name.lowercased()
            let importedCategory = ShoppingCategory(rawValue: r.shoppingCategory) ?? .other
            if let existing = knownIngredients[key] {
                let identical = existing.unit == r.unit && existing.shoppingCategory == importedCategory
                if !identical {
                    let cap     = existing
                    let capUnit = r.unit
                    let capCat  = importedCategory
                    let capCal  = r.caloriesPer100g
                    let capPro  = r.proteinPer100g
                    let capFat  = r.fatPer100g
                    let capCarb = r.carbsPer100g
                    let capFib  = r.fiberPer100g
                    conflicts.append(ImportConflict(
                        kind: "Ingredient",
                        name: r.name,
                        existingDetail: "Unit: \(existing.unit) · \(existing.shoppingCategory.rawValue)",
                        importedDetail: "Unit: \(r.unit) · \(importedCategory.rawValue)",
                        applyImported: {
                            cap.unit             = capUnit
                            cap.shoppingCategory = capCat
                            cap.caloriesPer100g  = capCal
                            cap.proteinPer100g   = capPro
                            cap.fatPer100g       = capFat
                            cap.carbsPer100g     = capCarb
                            cap.fiberPer100g     = capFib
                        }
                    ))
                }
                // identical → skip silently
            } else {
                let ing = Ingredient(name: r.name, unit: r.unit, shoppingCategory: importedCategory)
                ing.caloriesPer100g = r.caloriesPer100g
                ing.proteinPer100g  = r.proteinPer100g
                ing.fatPer100g      = r.fatPer100g
                ing.carbsPer100g    = r.carbsPer100g
                ing.fiberPer100g    = r.fiberPer100g
                context.insert(ing)
                knownIngredients[key] = ing
                ingredientsAdded += 1
            }
        }

        // ── Categories ───────────────────────────────────────────
        for r in payload.categories {
            let key = r.name.lowercased()
            if knownCategories[key] == nil {
                let cat = RecipeCategory(name: r.name, isCustom: r.isCustom)
                context.insert(cat)
                knownCategories[key] = cat
                categoriesAdded += 1
            }
            // existing category → skip (name match is sufficient)
        }

        // ── Tags ─────────────────────────────────────────────────
        for r in payload.tags {
            let key = r.name.lowercased()
            if let existing = knownTags[key] {
                if existing.colorHex != r.colorHex {
                    let cap      = existing
                    let capColor = r.colorHex
                    conflicts.append(ImportConflict(
                        kind: "Tag",
                        name: r.name,
                        existingDetail: "Color: \(existing.colorHex)",
                        importedDetail: "Color: \(r.colorHex)",
                        applyImported: { cap.colorHex = capColor }
                    ))
                }
            } else {
                let tag = RecipeTag(name: r.name, colorHex: r.colorHex, isCustom: r.isCustom)
                context.insert(tag)
                knownTags[key] = tag
                tagsAdded += 1
            }
        }

        // ── Recipes ──────────────────────────────────────────────
        for r in payload.recipes {
            let key = r.name.lowercased()
            if let existing = knownRecipes[key] {
                let identical = existing.instructions == r.instructions
                    && existing.prepTimeMinutes == r.prepTimeMinutes
                    && existing.isFavorite == r.isFavorite
                    && existing.recipeIngredients.count == r.ingredients.count
                if !identical {
                    let cap = existing
                    let capRecord = r
                    conflicts.append(ImportConflict(
                        kind: "Recipe",
                        name: r.name,
                        existingDetail: "Prep: \(formatMinutes(existing.prepTimeMinutes)) · \(existing.recipeIngredients.count) ingredients",
                        importedDetail: "Prep: \(formatMinutes(r.prepTimeMinutes)) · \(r.ingredients.count) ingredients",
                        applyImported: {
                            cap.instructions    = capRecord.instructions
                            cap.prepTimeMinutes = capRecord.prepTimeMinutes
                            cap.isFavorite      = capRecord.isFavorite
                        }
                    ))
                }
            } else {
                let recipe = Recipe(name: r.name, instructions: r.instructions,
                                    prepTimeMinutes: r.prepTimeMinutes)
                recipe.isFavorite = r.isFavorite
                recipe.category = r.categoryName.flatMap { knownCategories[$0.lowercased()] }
                recipe.tags = r.tagNames.compactMap { knownTags[$0.lowercased()] }
                context.insert(recipe)

                for ri in r.ingredients {
                    if let ing = knownIngredients[ri.ingredientName.lowercased()] {
                        let line = RecipeIngredient(ingredient: ing, amount: ri.amount)
                        line.recipe = recipe
                        context.insert(line)
                    }
                }
                for (idx, b64) in r.photos.enumerated() {
                    if let imgData = Data(base64Encoded: b64) {
                        let photo = RecipePhoto(imageData: imgData, sortOrder: idx)
                        photo.recipe = recipe
                        context.insert(photo)
                    }
                }
                knownRecipes[key] = recipe
                recipesAdded += 1
            }
        }

        // ── Storage items (always add; duplicates are legitimate) ─
        for r in payload.storageItems {
            guard let ing = knownIngredients[r.ingredientName.lowercased()] else { continue }
            let item = StorageItem(
                ingredient: ing,
                amount: r.amount,
                location: StorageLocation(rawValue: r.location) ?? .foodCloset,
                expiryDate: r.expiryDate
            )
            context.insert(item)
            storageItemsAdded += 1
        }

        // ── Meal plans (always add) ───────────────────────────────
        for r in payload.mealPlans {
            let meal = MealPlan(
                date: r.date,
                mealType: MealType(rawValue: r.mealType) ?? .other,
                portions: r.portions,
                notes: r.notes,
                recipe: r.recipeName.flatMap { knownRecipes[$0.lowercased()] },
                customName: r.customName
            )
            context.insert(meal)
            mealPlansAdded += 1
        }

        let result = ImportResult(
            ingredientsAdded: ingredientsAdded,
            categoriesAdded: categoriesAdded,
            tagsAdded: tagsAdded,
            recipesAdded: recipesAdded,
            storageItemsAdded: storageItemsAdded,
            mealPlansAdded: mealPlansAdded
        )
        return ImportOutcome(result: result, conflicts: conflicts)
    }

    // MARK: - Helpers

    private static func nameLookup<T: PersistentModel>(
        _ type: T.Type,
        context: ModelContext,
        key: (T) -> String
    ) throws -> [String: T] {
        let all = try context.fetch(FetchDescriptor<T>())
        // uniquingKeysWith prevents a crash when the DB already has duplicate-named rows
        return Dictionary(all.map { (key($0).lowercased(), $0) },
                          uniquingKeysWith: { first, _ in first })
    }

    private static func formatMinutes(_ m: Int) -> String {
        guard m > 0 else { return "0 min" }
        let h = m / 60, min = m % 60
        if h > 0 && min > 0 { return "\(h)h \(min)m" }
        return h > 0 ? "\(h)h" : "\(min)m"
    }
}
