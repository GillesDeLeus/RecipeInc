import SwiftUI
import SwiftData

// MARK: - NEVO picker sheet

private struct NevoPickerSheet: View {
    let candidates: [(entry: NevoEntry, score: Double)]
    let lang: AppLanguage
    let onSelect: (NevoEntry) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(candidates.enumerated()), id: \.offset) { _, match in
                    Button {
                        onSelect(match.entry)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(match.entry.name)
                                .font(.body).foregroundStyle(.primary)
                            if let english = match.entry.aliases.first, !english.isEmpty {
                                Text(english)
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            HStack(spacing: 10) {
                                macroLabel("\(Int(match.entry.kcal.rounded())) kcal")
                                macroLabel("P \(String(format: "%.1f", match.entry.protein))g")
                                macroLabel("F \(String(format: "%.1f", match.entry.fat))g")
                                macroLabel("K \(String(format: "%.1f", match.entry.carbs))g")
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .navigationTitle(lang.lookupNutrition)
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.cancel) { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func macroLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(Color.secondary.opacity(0.12))
            .clipShape(Capsule())
            .foregroundStyle(.secondary)
    }
}

// MARK: - Main form

struct IngredientFormView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings

    var ingredient: Ingredient?

    @State private var name = ""
    @State private var unit = ""
    @State private var shoppingCategory: ShoppingCategory = .other

    // Macronutrients
    @State private var caloriesText  = ""
    @State private var proteinText   = ""
    @State private var fatText       = ""
    @State private var satFatText    = ""
    @State private var carbsText     = ""
    @State private var sugarsText    = ""
    @State private var fiberText     = ""
    // Minerals
    @State private var sodiumText    = ""
    @State private var potassiumText = ""
    @State private var calciumText   = ""
    @State private var ironText      = ""
    // Vitamins
    @State private var vitCText      = ""
    @State private var vitDText      = ""

    @State private var lookupError: String?               = nil
    @State private var nevoSuggestions: [NevoEntry]       = []
    @State private var nevoSheetCandidates: [(entry: NevoEntry, score: Double)] = []
    @State private var showNevoSheet                       = false

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
                // ── Name ─────────────────────────────────────────────────
                Section(lang.nameLabel) {
                    TextField(lang.namePlaceholder, text: $name)
                        .autocorrectionDisabled()
                        .onChange(of: name) { updateNevoSuggestions() }

                    if appSettings.featureNutrition && !nevoSuggestions.isEmpty {
                        ForEach(Array(nevoSuggestions.enumerated()), id: \.offset) { _, entry in
                            Button { applyNevoEntry(entry) } label: {
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(entry.name)
                                            .font(.subheadline).foregroundStyle(.primary)
                                        if let english = entry.aliases.first, !english.isEmpty {
                                            Text(english)
                                                .font(.caption).foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Text("\(Int(entry.kcal.rounded())) kcal")
                                        .font(.caption).foregroundStyle(.secondary)
                                    Image(systemName: "arrow.down.circle")
                                        .font(.caption).foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                    }
                }

                // ── Unit ─────────────────────────────────────────────────
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

                // ── Shopping category ─────────────────────────────────────
                Section(lang.shoppingCategoryLabel) {
                    Picker(lang.shoppingCategoryLabel, selection: $shoppingCategory) {
                        ForEach(ShoppingCategory.allCases) { cat in
                            Label(cat.localizedName(in: lang), systemImage: cat.icon).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // ── Macronutrients ────────────────────────────────────────
                if appSettings.featureNutrition {
                    Section {
                        nutritionInputRow(lang.nutritionCalories, text: $caloriesText, unit: "kcal")
                        nutritionInputRow(lang.nutritionProtein,  text: $proteinText,  unit: "g")
                        nutritionInputRow(lang.nutritionFat,      text: $fatText,      unit: "g")
                        nutritionInputRow(lang.nutritionSatFat,   text: $satFatText,   unit: "g")
                        nutritionInputRow(lang.nutritionCarbs,    text: $carbsText,    unit: "g")
                        nutritionInputRow(lang.nutritionSugars,   text: $sugarsText,   unit: "g")
                        nutritionInputRow(lang.nutritionFiber,    text: $fiberText,    unit: "g")
                    } header: {
                        Text(lang.nutritionTitle + " (\(lang.nutritionPer100g))")
                    }

                    // ── Minerals ──────────────────────────────────────────
                    Section(lang.nutritionMinerals) {
                        nutritionInputRow(lang.nutritionSodium,    text: $sodiumText,    unit: "mg")
                        nutritionInputRow(lang.nutritionPotassium, text: $potassiumText, unit: "mg")
                        nutritionInputRow(lang.nutritionCalcium,   text: $calciumText,   unit: "mg")
                        nutritionInputRow(lang.nutritionIron,      text: $ironText,      unit: "mg")
                    }

                    // ── Vitamins ──────────────────────────────────────────
                    Section {
                        nutritionInputRow(lang.nutritionVitC, text: $vitCText, unit: "mg")
                        nutritionInputRow(lang.nutritionVitD, text: $vitDText, unit: "µg")

                        Button { manualLookup() } label: {
                            Label(lang.lookupNutrition, systemImage: "magnifyingglass")
                        }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)

                        if let error = lookupError {
                            Text(error).font(.caption).foregroundStyle(.red)
                        }
                    } header: {
                        Text(lang.nutritionVitamins)
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
                guard let ingredient else { return }
                name             = ingredient.name
                unit             = ingredient.unit
                shoppingCategory = ingredient.shoppingCategory
                if let v = ingredient.caloriesPer100g  { caloriesText  = formatNutrition(v, isCalories: true) }
                if let v = ingredient.proteinPer100g   { proteinText   = formatNutrition(v) }
                if let v = ingredient.fatPer100g       { fatText       = formatNutrition(v) }
                if let v = ingredient.satFatPer100g    { satFatText    = formatNutrition(v) }
                if let v = ingredient.carbsPer100g     { carbsText     = formatNutrition(v) }
                if let v = ingredient.sugarsPer100g    { sugarsText    = formatNutrition(v) }
                if let v = ingredient.fiberPer100g     { fiberText     = formatNutrition(v) }
                if let v = ingredient.sodiumPer100g    { sodiumText    = formatNutrition(v, decimals: 0) }
                if let v = ingredient.potassiumPer100g { potassiumText = formatNutrition(v, decimals: 0) }
                if let v = ingredient.calciumPer100g   { calciumText   = formatNutrition(v, decimals: 0) }
                if let v = ingredient.ironPer100g      { ironText      = formatNutrition(v) }
                if let v = ingredient.vitCPer100g      { vitCText      = formatNutrition(v) }
                if let v = ingredient.vitDPer100g      { vitDText      = formatNutrition(v) }
            }
            .sheet(isPresented: $showNevoSheet) {
                NevoPickerSheet(candidates: nevoSheetCandidates, lang: lang) { entry in
                    applyNevoEntry(entry)
                }
                .environment(appSettings)
            }
        }
    }

    // MARK: - Nutrition input row

    @ViewBuilder
    private func nutritionInputRow(_ label: String, text: Binding<String>, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("–", text: text)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
            Text(unit)
                .foregroundStyle(.secondary)
                .frame(width: 36, alignment: .leading)
        }
    }

    // MARK: - NEVO suggestions

    private func updateNevoSuggestions() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            nevoSuggestions = []
            return
        }
        nevoSuggestions = NutritionService.topMatches(for: trimmed, n: 3).map { $0.entry }
    }

    private func applyNevoEntry(_ entry: NevoEntry) {
        let info = NutritionService.nutritionInfo(for: entry)
        caloriesText  = "\(Int(info.caloriesPer100g.rounded()))"
        proteinText   = String(format: "%.1f", info.proteinPer100g)
        fatText       = String(format: "%.1f", info.fatPer100g)
        satFatText    = info.satFatPer100g.map    { String(format: "%.1f", $0) } ?? ""
        carbsText     = String(format: "%.1f", info.carbsPer100g)
        sugarsText    = info.sugarsPer100g.map    { String(format: "%.1f", $0) } ?? ""
        fiberText     = String(format: "%.1f", info.fiberPer100g)
        sodiumText    = info.sodiumPer100g.map    { "\(Int($0.rounded()))" } ?? ""
        potassiumText = info.potassiumPer100g.map { "\(Int($0.rounded()))" } ?? ""
        calciumText   = info.calciumPer100g.map   { "\(Int($0.rounded()))" } ?? ""
        ironText      = info.ironPer100g.map      { String(format: "%.1f", $0) } ?? ""
        vitCText      = info.vitCPer100g.map      { String(format: "%.1f", $0) } ?? ""
        vitDText      = info.vitDPer100g.map      { String(format: "%.1f", $0) } ?? ""
        lookupError   = nil
        nevoSuggestions = []
    }

    // MARK: - Helpers

    private func formatNutrition(_ val: Double, isCalories: Bool = false, decimals: Int = 1) -> String {
        if isCalories || decimals == 0 { return "\(Int(val.rounded()))" }
        return String(format: "%.\(decimals)f", val)
    }

    private func parseNutrition(_ text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: ",", with: ".")
        guard !trimmed.isEmpty, let val = Double(trimmed) else { return nil }
        return max(0, val)
    }

    // MARK: - Actions

    private func manualLookup() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        lookupError = nil

        let matches = NutritionService.topMatches(for: trimmedName, n: 8)
        guard !matches.isEmpty else {
            lookupError = NutritionServiceError.noResults.errorDescription
            return
        }

        // Auto-fill if there is a clear single best match
        let top = matches[0]
        let isUnambiguous = top.score >= 0.85 &&
            (matches.count == 1 || top.score - matches[1].score >= 0.20)

        if isUnambiguous {
            applyNevoEntry(top.entry)
        } else {
            nevoSheetCandidates = matches
            showNevoSheet = true
        }
    }

    private func saveAndDismiss() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedUnit = unit.trimmingCharacters(in: .whitespaces)

        let calories  = parseNutrition(caloriesText)
        let protein   = parseNutrition(proteinText)
        let fat       = parseNutrition(fatText)
        let satFat    = parseNutrition(satFatText)
        let carbs     = parseNutrition(carbsText)
        let sugars    = parseNutrition(sugarsText)
        let fiber     = parseNutrition(fiberText)
        let sodium    = parseNutrition(sodiumText)
        let potassium = parseNutrition(potassiumText)
        let calcium   = parseNutrition(calciumText)
        let iron      = parseNutrition(ironText)
        let vitC      = parseNutrition(vitCText)
        let vitD      = parseNutrition(vitDText)

        func apply(to ing: Ingredient) {
            ing.name             = trimmedName
            ing.unit             = trimmedUnit
            ing.shoppingCategory = shoppingCategory
            ing.caloriesPer100g  = calories
            ing.proteinPer100g   = protein
            ing.fatPer100g       = fat
            ing.satFatPer100g    = satFat
            ing.carbsPer100g     = carbs
            ing.sugarsPer100g    = sugars
            ing.fiberPer100g     = fiber
            ing.sodiumPer100g    = sodium
            ing.potassiumPer100g = potassium
            ing.calciumPer100g   = calcium
            ing.ironPer100g      = iron
            ing.vitCPer100g      = vitC
            ing.vitDPer100g      = vitD
        }

        if let ingredient {
            apply(to: ingredient)
        } else {
            let newIngredient = Ingredient(name: trimmedName, unit: trimmedUnit,
                                           shoppingCategory: shoppingCategory)
            apply(to: newIngredient)
            modelContext.insert(newIngredient)

            // Auto-lookup only if user left nutrition fields empty
            if appSettings.featureNutrition && calories == nil,
               let info = try? NutritionService.lookup(ingredientName: trimmedName) {
                newIngredient.caloriesPer100g  = info.caloriesPer100g
                newIngredient.proteinPer100g   = info.proteinPer100g
                newIngredient.fatPer100g       = info.fatPer100g
                newIngredient.satFatPer100g    = info.satFatPer100g
                newIngredient.carbsPer100g     = info.carbsPer100g
                newIngredient.sugarsPer100g    = info.sugarsPer100g
                newIngredient.fiberPer100g     = info.fiberPer100g
                newIngredient.sodiumPer100g    = info.sodiumPer100g
                newIngredient.potassiumPer100g = info.potassiumPer100g
                newIngredient.calciumPer100g   = info.calciumPer100g
                newIngredient.ironPer100g      = info.ironPer100g
                newIngredient.vitCPer100g      = info.vitCPer100g
                newIngredient.vitDPer100g      = info.vitDPer100g
            }
        }
        dismiss()
    }
}

#Preview("New") {
    IngredientFormView()
        .environment(AppSettings())
        .modelContainer(for: [Ingredient.self, RecipeIngredient.self, Recipe.self],
                        inMemory: true)
}
