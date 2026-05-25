import SwiftUI
import SwiftData

struct RecipeDetailView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings

    let recipe: Recipe

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showCookMode = false
    @State private var portions: Int = 1
    @State private var showFutureScheduledAlert = false
    @State private var showDeleteWithPastPlans = false
    @State private var pastPlanCount = 0
    @State private var futureBlockCount = 0

    private var lang: AppLanguage { appSettings.language }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // ── Photo gallery ─────────────────────────────────────
                if !recipe.photos.isEmpty {
                    let sorted = recipe.photos.sorted { $0.sortOrder < $1.sortOrder }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(sorted) { photo in
                                if let image = Image(data: photo.imageData) {
                                    image.resizable().scaledToFill()
                                        .containerRelativeFrame(.horizontal)
                                        .frame(height: 260).clipped()
                                }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .frame(height: 260)
                    .padding(.horizontal, -16)
                }

                // ── Meta row ─────────────────────────────────────────
                HStack(spacing: 16) {
                    Label(lang.formattedPrepTime(recipe.prepTimeMinutes), systemImage: "clock")
                    Label(lang.ingredientCount(recipe.recipeIngredients.count), systemImage: "list.bullet")
                    Spacer()
                    StarRatingView(rating: recipe.rating) { recipe.rating = $0 }
                        .font(.subheadline)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                // ── Category + Tags ───────────────────────────────────
                if recipe.category != nil || !recipe.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            if let cat = recipe.category {
                                Text(cat.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 10).padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.15))
                                    .foregroundStyle(Color.accentColor)
                                    .clipShape(Capsule())
                            }
                            ForEach(recipe.tags.sorted { $0.name < $1.name }) { tag in
                                Text(tag.name)
                                    .font(.caption)
                                    .padding(.horizontal, 10).padding(.vertical, 4)
                                    .background(Color(hex: tag.colorHex).opacity(0.15))
                                    .foregroundStyle(Color(hex: tag.colorHex))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                Divider()

                // ── Ingredients ──────────────────────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(lang.ingredientsTitle)
                            .font(.title2).fontWeight(.semibold)
                        Spacer()
                        Stepper(value: $portions, in: 1...20) {
                            HStack(spacing: 4) {
                                Text(lang.servingsLabel)
                                    .font(.subheadline).foregroundStyle(.secondary)
                                Text("\(portions)")
                                    .font(.subheadline).fontWeight(.semibold).monospacedDigit()
                            }
                        }
                    }

                    if recipe.recipeIngredients.isEmpty {
                        Text(lang.noIngredientsAdded).foregroundStyle(.secondary).italic()
                    } else {
                        let sorted = recipe.recipeIngredients
                            .sorted { ($0.ingredient?.name ?? "") < ($1.ingredient?.name ?? "") }
                        ForEach(sorted) { line in
                            HStack {
                                Circle().fill(Color.accentColor).frame(width: 6, height: 6)
                                Text(scaledDisplay(line)).font(.body)
                            }
                        }
                    }
                }

                if appSettings.featureNutrition, !recipe.recipeIngredients.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 8) {
                        if let nutrition = computeNutrition(portions: portions) {
                            nutritionSection(nutrition)
                        }
                        if ingredientsMissingNutrition {
                            Button { lookupAllMissingNutrition() } label: {
                                Label(lang.lookupNutrition, systemImage: "magnifyingglass")
                            }
                            .font(.subheadline)
                        }
                    }
                }

                Divider()

                // ── Instructions ─────────────────────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    Text(lang.preparation).font(.title2).fontWeight(.semibold)
                    if recipe.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(lang.noPreparation).foregroundStyle(.secondary).italic()
                    } else {
                        Text(recipe.instructions).font(.body).lineSpacing(4)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        .navigationTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if !recipe.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button {
                        showCookMode = true
                    } label: {
                        Label(lang.cookMode, systemImage: "flame")
                    }
                }
                Menu {
                    ShareLink(item: shareText) {
                        Label(lang.shareRecipe, systemImage: "square.and.arrow.up")
                    }
                    Divider()
                    Button { showEditSheet = true } label: {
                        Label(lang.editAction, systemImage: "pencil")
                    }
                    Button { duplicateRecipe() } label: {
                        Label(lang.duplicateRecipe, systemImage: "doc.on.doc")
                    }
                    Button(role: .destructive) {
                        requestDelete()
                    } label: {
                        Label(lang.delete, systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            RecipeFormView(recipe: recipe)
        }
        .sheet(isPresented: $showCookMode) {
            CookModeView(recipe: recipe, portions: portions)
                .environment(appSettings)
                .frame(minWidth: 620, minHeight: 520)
        }
        // Block: recipe has future calendar entries
        .alert(lang.recipeFutureScheduledTitle, isPresented: $showFutureScheduledAlert) {
            Button(lang.cancel, role: .cancel) {}
        } message: {
            Text(lang.recipeFutureScheduledMessage(recipe.name, futureBlockCount))
        }
        // Confirm: recipe has past calendar entries that will also be removed
        .confirmationDialog(lang.deleteRecipeTitle,
                            isPresented: $showDeleteWithPastPlans,
                            titleVisibility: .visible) {
            Button(lang.delete, role: .destructive) { executeDelete(removePastPlans: true) }
            Button(lang.cancel, role: .cancel) {}
        } message: {
            Text(lang.deleteRecipeWithPastPlansMessage(recipe.name, pastPlanCount))
        }
        // Confirm: no calendar entries at all
        .confirmationDialog(lang.deleteRecipeTitle,
                            isPresented: $showDeleteConfirmation,
                            titleVisibility: .visible) {
            Button(lang.delete, role: .destructive) { executeDelete(removePastPlans: false) }
            Button(lang.cancel, role: .cancel) {}
        } message: {
            Text(lang.deleteRecipeMessage(recipe.name))
        }
    }

    // MARK: - Nutrition

    private struct RecipeNutrition {
        var calories: Double = 0
        var protein:  Double = 0
        var fat:      Double = 0
        var carbs:    Double = 0
        var fiber:    Double = 0
        var includedCount: Int = 0
        var totalCount:    Int = 0
    }

    private var ingredientsMissingNutrition: Bool {
        recipe.recipeIngredients.contains { $0.ingredient?.caloriesPer100g == nil }
    }

    private func lookupAllMissingNutrition() {
        for ri in recipe.recipeIngredients {
            guard let ingredient = ri.ingredient, ingredient.caloriesPer100g == nil else { continue }
            if let info = try? NutritionService.lookup(ingredientName: ingredient.name) {
                ingredient.caloriesPer100g = info.caloriesPer100g
                ingredient.proteinPer100g  = info.proteinPer100g
                ingredient.fatPer100g      = info.fatPer100g
                ingredient.carbsPer100g    = info.carbsPer100g
                ingredient.fiberPer100g    = info.fiberPer100g
            }
        }
    }

    private func computeNutrition(portions: Int) -> RecipeNutrition? {
        var result = RecipeNutrition()
        result.totalCount = recipe.recipeIngredients.count
        for ri in recipe.recipeIngredients {
            guard let ing = ri.ingredient, let kcal = ing.caloriesPer100g else { continue }
            let u = ing.unit.lowercased()
            let scale: Double
            switch u {
            case "g", "ml": scale = ri.amount / 100.0
            case "kg", "l": scale = ri.amount * 10.0
            case "cl":      scale = ri.amount / 10.0
            default:        continue
            }
            result.calories += kcal                      * scale
            result.protein  += (ing.proteinPer100g ?? 0) * scale
            result.fat      += (ing.fatPer100g     ?? 0) * scale
            result.carbs    += (ing.carbsPer100g   ?? 0) * scale
            result.fiber    += (ing.fiberPer100g   ?? 0) * scale
            result.includedCount += 1
        }
        guard result.includedCount > 0 else { return nil }
        let p = Double(portions)
        result.calories *= p; result.protein *= p
        result.fat      *= p; result.carbs   *= p; result.fiber *= p
        return result
    }

    @ViewBuilder
    private func nutritionSection(_ n: RecipeNutrition) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(lang.nutritionTitle)
                .font(.title2).fontWeight(.semibold)
            HStack(spacing: 0) {
                nutritionCell(lang.nutritionCalories, value: n.calories, unit: "kcal", color: .orange)
                nutritionCell(lang.nutritionProtein,  value: n.protein,  unit: "g",    color: .blue)
                nutritionCell(lang.nutritionFat,      value: n.fat,      unit: "g",    color: .yellow)
                nutritionCell(lang.nutritionCarbs,    value: n.carbs,    unit: "g",    color: .green)
                nutritionCell(lang.nutritionFiber,    value: n.fiber,    unit: "g",    color: .brown)
            }
            .padding(12)
            .background(Color.secondary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            if n.includedCount < n.totalCount {
                Text(lang.nutritionIngredientNote(n.includedCount, n.totalCount))
                    .font(.caption).foregroundStyle(.secondary)
            }
            Text(lang.nutritionSource)
                .font(.caption2).foregroundStyle(.tertiary)
        }
    }

    @ViewBuilder
    private func nutritionCell(_ label: String, value: Double, unit: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(unit == "kcal" ? "\(Int(value.rounded()))" : String(format: "%.1f", value))
                .font(.subheadline).fontWeight(.semibold).foregroundStyle(color)
            Text(unit).font(.caption2).foregroundStyle(.secondary)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Share text

    private var shareText: String {
        var lines: [String] = [recipe.name, ""]
        lines.append(lang.formattedPrepTime(recipe.prepTimeMinutes))

        if let cat = recipe.category {
            lines.append(cat.name)
        }

        if !recipe.tags.isEmpty {
            let tagList = recipe.tags.sorted { $0.name < $1.name }.map { $0.name }.joined(separator: ", ")
            lines.append(tagList)
        }

        if !recipe.recipeIngredients.isEmpty {
            lines.append("")
            lines.append(lang.ingredientsTitle + ":")
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
            lines.append(lang.preparation + ":")
            lines.append(instructions)
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Duplication

    private func duplicateRecipe() {
        let copy = Recipe(
            name: lang.duplicateRecipeName(recipe.name),
            instructions: recipe.instructions,
            prepTimeMinutes: recipe.prepTimeMinutes
        )
        copy.category = recipe.category
        copy.tags = recipe.tags
        modelContext.insert(copy)
        for ri in recipe.recipeIngredients {
            guard let ing = ri.ingredient else { continue }
            let newLine = RecipeIngredient(ingredient: ing, amount: ri.amount)
            newLine.recipe = copy
            copy.recipeIngredients.append(newLine)
            modelContext.insert(newLine)
        }
    }

    // MARK: - Deletion logic

    private func requestDelete() {
        let today = Calendar.current.startOfDay(for: Date())
        let plans = mealPlansForThisRecipe()
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

    private func executeDelete(removePastPlans: Bool) {
        if removePastPlans {
            let today = Calendar.current.startOfDay(for: Date())
            for plan in mealPlansForThisRecipe() where plan.date < today {
                modelContext.delete(plan)
            }
        }
        modelContext.delete(recipe)
        dismiss()
    }

    private func mealPlansForThisRecipe() -> [MealPlan] {
        let all = (try? modelContext.fetch(FetchDescriptor<MealPlan>())) ?? []
        return all.filter { $0.recipe?.persistentModelID == recipe.persistentModelID }
    }

    // MARK: - Scaled ingredient display

    private func scaledDisplay(_ line: RecipeIngredient) -> String {
        guard let ingredient = line.ingredient else { return "–" }
        let scaled = line.amount * Double(portions)
        let amtStr = scaled.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(scaled))
            : String(format: "%.1f", scaled)
        return ingredient.unit.isEmpty
            ? "\(amtStr) \(ingredient.name)"
            : "\(amtStr) \(ingredient.unit) \(ingredient.name)"
    }
}
