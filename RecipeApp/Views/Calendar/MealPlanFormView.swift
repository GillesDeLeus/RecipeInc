import SwiftUI
import SwiftData

struct MealPlanFormView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings

    @Query(sort: \Recipe.name) private var allRecipes: [Recipe]

    // Pass existing plan to edit, or nil + initialDate to create
    var existingMealPlan: MealPlan? = nil
    var initialDate: Date = Date()

    private var isEditing: Bool { existingMealPlan != nil }
    private var lang: AppLanguage { appSettings.language }

    // MARK: - Form state (initialised in init)

    @State private var selectedDate: Date
    @State private var mealType: MealType
    @State private var portions: Int
    @State private var notes: String
    @State private var selectedRecipe: Recipe?
    @State private var customName: String
    @State private var useCustomName: Bool

    init(existingMealPlan: MealPlan? = nil, initialDate: Date = Date()) {
        self.existingMealPlan = existingMealPlan
        self.initialDate = initialDate

        let cal = Calendar.current
        if let meal = existingMealPlan {
            _selectedDate    = State(initialValue: meal.date)
            _mealType        = State(initialValue: meal.mealType)
            _portions        = State(initialValue: meal.portions)
            _notes           = State(initialValue: meal.notes)
            _selectedRecipe  = State(initialValue: meal.recipe)
            _customName      = State(initialValue: meal.customName)
            _useCustomName   = State(initialValue: meal.recipe == nil)
        } else {
            _selectedDate    = State(initialValue: cal.startOfDay(for: initialDate))
            _mealType        = State(initialValue: .dinner)
            _portions        = State(initialValue: 1)
            _notes           = State(initialValue: "")
            _selectedRecipe  = State(initialValue: nil)
            _customName      = State(initialValue: "")
            _useCustomName   = State(initialValue: false)
        }
    }

    private var isValid: Bool {
        useCustomName
            ? !customName.trimmingCharacters(in: .whitespaces).isEmpty
            : selectedRecipe != nil
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // ── Date ─────────────────────────────────────────
                Section(lang.dateLabel) {
                    DatePicker(lang.dateLabel,
                               selection: $selectedDate,
                               displayedComponents: .date)
                    .labelsHidden()
                }

                // ── Meal type ─────────────────────────────────────
                Section(lang.mealTypeLabel) {
                    Picker(lang.mealTypeLabel, selection: $mealType) {
                        ForEach(MealType.allCases, id: \.self) { type in
                            Label(type.localizedName(in: lang), systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // ── Recipe ────────────────────────────────────────
                Section(lang.recipeLabel) {
                    Toggle(lang.customMeal, isOn: $useCustomName)
                    if useCustomName {
                        TextField(lang.mealName, text: $customName)
                    } else {
                        Picker(lang.recipeLabel, selection: $selectedRecipe) {
                            Text(lang.noCategoryOption).tag(nil as Recipe?)
                            ForEach(allRecipes) { recipe in
                                Text(recipe.name).tag(recipe as Recipe?)
                            }
                        }
                    }
                }

                // ── Portions ──────────────────────────────────────
                Section(lang.servingsLabel) {
                    Stepper(value: $portions, in: 1...20) {
                        HStack {
                            Text(lang.servingsLabel)
                            Spacer()
                            Text("\(portions)").foregroundStyle(.secondary)
                        }
                    }
                }

                // ── Notes ─────────────────────────────────────────
                Section(lang.notesLabel) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isEditing ? lang.editMeal : lang.newMeal)
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? lang.save : lang.addItem) {
                        save(); dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    // MARK: - Save

    private func save() {
        let normDate = Calendar.current.startOfDay(for: selectedDate)
        let chosenRecipe = useCustomName ? nil : selectedRecipe
        let name = useCustomName ? customName.trimmingCharacters(in: .whitespaces) : ""

        if let meal = existingMealPlan {
            meal.date       = normDate
            meal.mealType   = mealType
            meal.portions   = portions
            meal.notes      = notes
            meal.recipe     = chosenRecipe
            meal.customName = name
        } else {
            let newMeal = MealPlan(date: normDate,
                                   mealType: mealType,
                                   portions: portions,
                                   notes: notes,
                                   recipe: chosenRecipe,
                                   customName: name)
            modelContext.insert(newMeal)
        }
    }
}

#Preview {
    MealPlanFormView()
        .environment(AppSettings())
        .modelContainer(for: [MealPlan.self, Recipe.self], inMemory: true)
}
