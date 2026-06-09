import Foundation
import SwiftData
import Observation

// MARK: - Nutrition result (moved from private struct in RecipeDetailView)

struct RecipeNutrition {
    var calories:  Double = 0
    var protein:   Double = 0
    var fat:       Double = 0
    var satFat:    Double = 0
    var carbs:     Double = 0
    var sugars:    Double = 0
    var fiber:     Double = 0
    var sodium:    Double = 0
    var potassium: Double = 0
    var calcium:   Double = 0
    var iron:      Double = 0
    var vitC:      Double = 0
    var vitD:      Double = 0
    var includedCount: Int = 0
    var totalCount:    Int = 0
}

// MARK: - ViewModel

@Observable
final class RecipeDetailViewModel {

    let recipe: Recipe

    // MARK: UI State
    var portions: Int = 1
    var showEditSheet = false
    var showDeleteConfirmation = false
    var showCookMode = false
    var showFutureScheduledAlert = false
    var showDeleteWithPastPlans = false
    var pastPlanCount = 0
    var futureBlockCount = 0

    init(recipe: Recipe) {
        self.recipe = recipe
    }

    // MARK: - Nutrition

    var ingredientsMissingNutrition: Bool {
        recipe.recipeIngredients.contains { $0.ingredient?.caloriesPer100g == nil }
    }

    func computeNutrition() -> RecipeNutrition? {
        var result = RecipeNutrition()
        result.totalCount = recipe.recipeIngredients.count
        for ri in recipe.recipeIngredients {
            guard let ing = ri.ingredient, let kcal = ing.caloriesPer100g else { continue }
            let scale: Double
            switch ing.unit.lowercased() {
            case "g", "ml": scale = ri.amount / 100.0
            case "kg", "l": scale = ri.amount * 10.0
            case "cl":      scale = ri.amount / 10.0
            default:        continue
            }
            result.calories  += kcal                           * scale
            result.protein   += (ing.proteinPer100g   ?? 0)   * scale
            result.fat       += (ing.fatPer100g       ?? 0)   * scale
            result.satFat    += (ing.satFatPer100g    ?? 0)   * scale
            result.carbs     += (ing.carbsPer100g     ?? 0)   * scale
            result.sugars    += (ing.sugarsPer100g    ?? 0)   * scale
            result.fiber     += (ing.fiberPer100g     ?? 0)   * scale
            result.sodium    += (ing.sodiumPer100g    ?? 0)   * scale
            result.potassium += (ing.potassiumPer100g ?? 0)   * scale
            result.calcium   += (ing.calciumPer100g   ?? 0)   * scale
            result.iron      += (ing.ironPer100g      ?? 0)   * scale
            result.vitC      += (ing.vitCPer100g      ?? 0)   * scale
            result.vitD      += (ing.vitDPer100g      ?? 0)   * scale
            result.includedCount += 1
        }
        guard result.includedCount > 0 else { return nil }
        let p = Double(portions)
        result.calories  *= p; result.protein   *= p; result.fat       *= p
        result.satFat    *= p; result.carbs      *= p; result.sugars    *= p
        result.fiber     *= p; result.sodium     *= p; result.potassium *= p
        result.calcium   *= p; result.iron       *= p
        result.vitC      *= p; result.vitD       *= p
        return result
    }

    func lookupAllMissingNutrition() {
        for ri in recipe.recipeIngredients {
            guard let ingredient = ri.ingredient, ingredient.caloriesPer100g == nil else { continue }
            guard let info = try? NutritionService.lookup(ingredientName: ingredient.name) else { continue }
            ingredient.caloriesPer100g  = info.caloriesPer100g
            ingredient.proteinPer100g   = info.proteinPer100g
            ingredient.fatPer100g       = info.fatPer100g
            ingredient.satFatPer100g    = info.satFatPer100g
            ingredient.carbsPer100g     = info.carbsPer100g
            ingredient.sugarsPer100g    = info.sugarsPer100g
            ingredient.fiberPer100g     = info.fiberPer100g
            ingredient.sodiumPer100g    = info.sodiumPer100g
            ingredient.potassiumPer100g = info.potassiumPer100g
            ingredient.calciumPer100g   = info.calciumPer100g
            ingredient.ironPer100g      = info.ironPer100g
            ingredient.vitCPer100g      = info.vitCPer100g
            ingredient.vitDPer100g      = info.vitDPer100g
        }
    }

    // MARK: - Scaled ingredient display

    func scaledDisplay(_ line: RecipeIngredient) -> String {
        guard let ingredient = line.ingredient else { return "–" }
        let scaled = line.amount * Double(portions)
        let amtStr = scaled.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(scaled))
            : String(format: "%.1f", scaled)
        return ingredient.unit.isEmpty
            ? "\(amtStr) \(ingredient.name)"
            : "\(amtStr) \(ingredient.unit) \(ingredient.name)"
    }

    // MARK: - Share text

    func shareText() -> String {
        var lines: [String] = [recipe.name, ""]
        lines.append(TimeFormat.prepTime(recipe.prepTimeMinutes))

        if let cat = recipe.category { lines.append(cat.name) }

        if !recipe.tags.isEmpty {
            let tagList = recipe.tags.sorted { $0.name < $1.name }.map { $0.name }.joined(separator: ", ")
            lines.append(tagList)
        }

        if !recipe.recipeIngredients.isEmpty {
            lines.append("")
            lines.append(String(localized: "Ingredients") + ":")
            let sorted = recipe.recipeIngredients
                .sorted { ($0.ingredient?.name ?? "") < ($1.ingredient?.name ?? "") }
            for ri in sorted {
                guard let ing = ri.ingredient else { continue }
                let amt = ri.amount.truncatingRemainder(dividingBy: 1) == 0
                    ? String(Int(ri.amount))
                    : String(format: "%.1f", ri.amount)
                let entry = ing.unit.isEmpty
                    ? "• \(amt) \(ing.name)"
                    : "• \(amt) \(ing.unit) \(ing.name)"
                lines.append(entry)
            }
        }

        let instructions = recipe.instructions.trimmingCharacters(in: .whitespacesAndNewlines)
        if !instructions.isEmpty {
            lines.append("")
            lines.append(String(localized: "Preparation") + ":")
            lines.append(instructions)
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Duplication

    func duplicateRecipe(in context: ModelContext) {
        let copy = Recipe(
            name: String(localized: "Copy of \(recipe.name)"),
            instructions: recipe.instructions,
            prepTimeMinutes: recipe.prepTimeMinutes
        )
        copy.category = recipe.category
        copy.tags = recipe.tags
        context.insert(copy)
        for ri in recipe.recipeIngredients {
            guard let ing = ri.ingredient else { continue }
            let newLine = RecipeIngredient(ingredient: ing, amount: ri.amount)
            newLine.recipe = copy
            copy.recipeIngredients.append(newLine)
            context.insert(newLine)
        }
    }

    // MARK: - Deletion

    func requestDelete(in context: ModelContext) {
        let today = Calendar.current.startOfDay(for: Date())
        let plans = mealPlansForThisRecipe(in: context)
        let future = plans.filter { $0.date >= today }
        let past   = plans.filter { $0.date <  today }

        if !future.isEmpty {
            futureBlockCount = future.count
            showFutureScheduledAlert = true
        } else if !past.isEmpty {
            pastPlanCount = past.count
            showDeleteWithPastPlans = true
        } else {
            showDeleteConfirmation = true
        }
    }

    func executeDelete(removePastPlans: Bool, in context: ModelContext, onDismiss: () -> Void) {
        if removePastPlans {
            let today = Calendar.current.startOfDay(for: Date())
            for plan in mealPlansForThisRecipe(in: context) where plan.date < today {
                context.delete(plan)
            }
        }
        context.delete(recipe)
        onDismiss()
    }

    func mealPlansForThisRecipe(in context: ModelContext) -> [MealPlan] {
        let id = recipe.persistentModelID
        let descriptor = FetchDescriptor<MealPlan>(
            predicate: #Predicate { $0.recipe?.persistentModelID == id }
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}
