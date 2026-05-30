import Foundation

struct PeriodNutrition {
    var calories:  Double = 0
    var protein:   Double = 0
    var fat:       Double = 0
    var carbs:     Double = 0
    var fiber:     Double = 0
    var mealsWithData: Int = 0
    var totalMeals:    Int = 0

    var hasData: Bool { mealsWithData > 0 }

    // Caloric energy per macro (for proportion bar)
    var proteinKcal: Double { protein * 4 }
    var fatKcal:     Double { fat     * 9 }
    var carbsKcal:   Double { carbs   * 4 }
    var macroKcalTotal: Double { proteinKcal + fatKcal + carbsKcal }
}

enum NutritionCalculator {

    static func nutrition(for meals: [MealPlan]) -> PeriodNutrition {
        var result = PeriodNutrition()
        result.totalMeals = meals.count

        for meal in meals {
            guard let recipe = meal.recipe else { continue }
            let portions = Double(meal.portions)
            var contributed = false

            for ri in recipe.recipeIngredients {
                guard let ing = ri.ingredient, let kcal = ing.caloriesPer100g else { continue }
                let unitScale = scale(for: ing.unit)
                guard unitScale > 0 else { continue }
                let s = ri.amount * unitScale * portions
                result.calories += kcal                        * s
                result.protein  += (ing.proteinPer100g  ?? 0) * s
                result.fat      += (ing.fatPer100g      ?? 0) * s
                result.carbs    += (ing.carbsPer100g    ?? 0) * s
                result.fiber    += (ing.fiberPer100g    ?? 0) * s
                contributed = true
            }
            if contributed { result.mealsWithData += 1 }
        }
        return result
    }

    // Divides into per-day averages (for weekly summaries)
    static func average(_ n: PeriodNutrition, days: Int) -> PeriodNutrition {
        guard days > 0 else { return n }
        let d = Double(days)
        var avg = n
        avg.calories = n.calories / d
        avg.protein  = n.protein  / d
        avg.fat      = n.fat      / d
        avg.carbs    = n.carbs    / d
        avg.fiber    = n.fiber    / d
        return avg
    }

    private static func scale(for unit: String) -> Double {
        switch unit.lowercased() {
        case "g", "ml": return 1.0 / 100.0
        case "kg", "l": return 10.0
        case "cl":      return 1.0 / 10.0
        default:        return 0
        }
    }
}
