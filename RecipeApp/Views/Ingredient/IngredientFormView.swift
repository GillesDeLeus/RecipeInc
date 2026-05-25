import SwiftUI
import SwiftData

struct IngredientFormView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings

    var ingredient: Ingredient?

    @State private var name = ""
    @State private var unit = ""
    @State private var shoppingCategory: ShoppingCategory = .other

    // Nutrition state
    @State private var caloriesPer100g: Double? = nil
    @State private var proteinPer100g:  Double? = nil
    @State private var fatPer100g:      Double? = nil
    @State private var carbsPer100g:    Double? = nil
    @State private var fiberPer100g:    Double? = nil
    @State private var lookupError: String? = nil

    private var isEditing: Bool { ingredient != nil }
    private var lang: AppLanguage { appSettings.language }

    private let commonUnits = ["g", "kg", "ml", "cl", "l", "stuk", "el", "tl",
                                "snuf", "takje", "blaadje", "teen"]

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !unit.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section(lang.nameLabel) {
                    TextField(lang.namePlaceholder, text: $name)
                        .autocorrectionDisabled()
                }

                Section(lang.unitLabel) {
                    TextField(lang.unitPlaceholder, text: $unit)
                        .autocorrectionDisabled()

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(commonUnits, id: \.self) { suggestion in
                                Button(suggestion) { unit = suggestion }
                                    .buttonStyle(.bordered)
                                    .tint(unit == suggestion ? .accentColor : .secondary)
                                    .controlSize(.small)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section(lang.shoppingCategoryLabel) {
                    Picker(lang.shoppingCategoryLabel, selection: $shoppingCategory) {
                        ForEach(ShoppingCategory.allCases) { cat in
                            Label(cat.localizedName(in: lang), systemImage: cat.icon).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // ── Nutrition ────────────────────────────────────────────────
                if appSettings.featureNutrition {
                    Section {
                        if caloriesPer100g != nil {
                            nutritionRow(lang.nutritionCalories, value: caloriesPer100g, unit: "kcal")
                            nutritionRow(lang.nutritionProtein,  value: proteinPer100g,  unit: "g")
                            nutritionRow(lang.nutritionFat,      value: fatPer100g,      unit: "g")
                            nutritionRow(lang.nutritionCarbs,    value: carbsPer100g,    unit: "g")
                            nutritionRow(lang.nutritionFiber,    value: fiberPer100g,    unit: "g")
                        }

                        Button {
                            manualLookup()
                        } label: {
                            Label(
                                caloriesPer100g == nil ? lang.lookupNutrition : lang.refreshNutrition,
                                systemImage: "magnifyingglass"
                            )
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)

                        if let error = lookupError {
                            Text(error).font(.caption).foregroundStyle(.red)
                        }
                    } header: {
                        Text(lang.nutritionTitle + " (\(lang.nutritionPer100g))")
                    } footer: {
                        Text(lang.nutritionSource).font(.caption2)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isEditing ? lang.editIngredient : lang.newIngredient)
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? lang.save : lang.addItem) {
                        saveAndDismiss()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                if let ingredient {
                    name             = ingredient.name
                    unit             = ingredient.unit
                    shoppingCategory = ingredient.shoppingCategory
                    caloriesPer100g  = ingredient.caloriesPer100g
                    proteinPer100g   = ingredient.proteinPer100g
                    fatPer100g       = ingredient.fatPer100g
                    carbsPer100g     = ingredient.carbsPer100g
                    fiberPer100g     = ingredient.fiberPer100g
                }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func nutritionRow(_ label: String, value: Double?, unit: String) -> some View {
        if let value {
            HStack {
                Text(label).foregroundStyle(.secondary)
                Spacer()
                Text(unit == "kcal"
                     ? "\(Int(value.rounded())) \(unit)"
                     : "\(String(format: "%.1f", value)) \(unit)")
                    .fontWeight(.medium)
            }
        }
    }

    // MARK: - Actions

    private func saveAndDismiss() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedUnit = unit.trimmingCharacters(in: .whitespaces)

        if let ingredient {
            ingredient.name             = trimmedName
            ingredient.unit             = trimmedUnit
            ingredient.shoppingCategory = shoppingCategory
            ingredient.caloriesPer100g  = caloriesPer100g
            ingredient.proteinPer100g   = proteinPer100g
            ingredient.fatPer100g       = fatPer100g
            ingredient.carbsPer100g     = carbsPer100g
            ingredient.fiberPer100g     = fiberPer100g
        } else {
            let newIngredient = Ingredient(name: trimmedName, unit: trimmedUnit,
                                           shoppingCategory: shoppingCategory)
            modelContext.insert(newIngredient)

            if appSettings.featureNutrition,
               let info = try? NutritionService.lookup(ingredientName: trimmedName) {
                newIngredient.caloriesPer100g = info.caloriesPer100g
                newIngredient.proteinPer100g  = info.proteinPer100g
                newIngredient.fatPer100g      = info.fatPer100g
                newIngredient.carbsPer100g    = info.carbsPer100g
                newIngredient.fiberPer100g    = info.fiberPer100g
            }
        }
        dismiss()
    }

    private func manualLookup() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        lookupError = nil
        do {
            let info = try NutritionService.lookup(ingredientName: trimmedName)
            caloriesPer100g = info.caloriesPer100g
            proteinPer100g  = info.proteinPer100g
            fatPer100g      = info.fatPer100g
            carbsPer100g    = info.carbsPer100g
            fiberPer100g    = info.fiberPer100g
        } catch {
            lookupError = error.localizedDescription
        }
    }
}

#Preview("New") {
    IngredientFormView()
        .environment(AppSettings())
        .modelContainer(for: [Ingredient.self, RecipeIngredient.self, Recipe.self],
                        inMemory: true)
}
