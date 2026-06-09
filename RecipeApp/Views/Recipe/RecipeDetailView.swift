import SwiftUI
import SwiftData
import TipKit

struct RecipeDetailView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings

    let recipe: Recipe

    private let cookModeTip = CookModeTip()

    @State private var vm: RecipeDetailViewModel

    init(recipe: Recipe) {
        self.recipe = recipe
        self._vm = State(initialValue: RecipeDetailViewModel(recipe: recipe))
    }


    // MARK: - Body

    var body: some View {
        @Bindable var vm = vm
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                if !recipe.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    TipView(cookModeTip, arrowEdge: .top)
                }

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
                    Label(TimeFormat.prepTime(recipe.prepTimeMinutes), systemImage: "clock")
                    Label(String(localized: "\(recipe.recipeIngredients.count) ingredients"), systemImage: "list.bullet")
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
                        Text(String(localized: "Ingredients"))
                            .font(.title2).fontWeight(.semibold)
                        Spacer()
                        Stepper(value: $vm.portions, in: 1...20) {
                            HStack(spacing: 4) {
                                Text(String(localized: "Servings"))
                                    .font(.subheadline).foregroundStyle(.secondary)
                                Text("\(vm.portions)")
                                    .font(.subheadline).fontWeight(.semibold).monospacedDigit()
                            }
                        }
                    }

                    if recipe.recipeIngredients.isEmpty {
                        Text(String(localized: "No ingredients added.")).foregroundStyle(.secondary).italic()
                    } else {
                        let sorted = recipe.recipeIngredients
                            .sorted { ($0.ingredient?.name ?? "") < ($1.ingredient?.name ?? "") }
                        ForEach(sorted) { line in
                            HStack {
                                Circle().fill(Color.accentColor).frame(width: 6, height: 6)
                                Text(vm.scaledDisplay(line)).font(.body)
                            }
                        }
                    }
                }

                if appSettings.featureNutrition, !recipe.recipeIngredients.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 8) {
                        if let nutrition = vm.computeNutrition() {
                            nutritionSection(nutrition)
                        }
                        if vm.ingredientsMissingNutrition {
                            Button { vm.lookupAllMissingNutrition() } label: {
                                Label(String(localized: "Look Up Nutrition"), systemImage: "magnifyingglass")
                            }
                            .font(.subheadline)
                        }
                    }
                }

                Divider()

                // ── Instructions ─────────────────────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "Preparation")).font(.title2).fontWeight(.semibold)
                    if recipe.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(String(localized: "No preparation instructions added.")).foregroundStyle(.secondary).italic()
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
                        vm.showCookMode = true
                        cookModeTip.invalidate(reason: .actionPerformed)
                    } label: {
                        Label(String(localized: "Cook Mode"), systemImage: "flame")
                    }
                }
                Menu {
                    ShareLink(item: vm.shareText()) {
                        Label(String(localized: "Share Recipe"), systemImage: "square.and.arrow.up")
                    }
                    Divider()
                    Button { vm.showEditSheet = true } label: {
                        Label(String(localized: "Edit"), systemImage: "pencil")
                    }
                    Button { vm.duplicateRecipe(in: modelContext) } label: {
                        Label(String(localized: "Duplicate Recipe"), systemImage: "doc.on.doc")
                    }
                    Button(role: .destructive) {
                        vm.requestDelete(in: modelContext)
                    } label: {
                        Label(String(localized: "Delete"), systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $vm.showEditSheet) {
            RecipeFormView(recipe: recipe)
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $vm.showCookMode) {
            CookModeView(recipe: recipe, portions: vm.portions)
                .environment(appSettings)
        }
        #else
        .sheet(isPresented: $vm.showCookMode) {
            CookModeView(recipe: recipe, portions: vm.portions)
                .environment(appSettings)
                .frame(minWidth: 620, minHeight: 520)
        }
        #endif
        .alert(String(localized: "Recipe Is Scheduled"), isPresented: $vm.showFutureScheduledAlert) {
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "\"\(recipe.name)\" is planned \(vm.futureBlockCount) times in the future. Remove it from the calendar first."))
        }
        .confirmationDialog(String(localized: "Delete Recipe?"),
                            isPresented: $vm.showDeleteWithPastPlans,
                            titleVisibility: .visible) {
            Button(String(localized: "Delete"), role: .destructive) {
                vm.executeDelete(removePastPlans: true, in: modelContext) { dismiss() }
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "\"\(recipe.name)\" was planned \(vm.pastPlanCount) times in the past. Those calendar entries will also be deleted."))
        }
        .confirmationDialog(String(localized: "Delete Recipe?"),
                            isPresented: $vm.showDeleteConfirmation,
                            titleVisibility: .visible) {
            Button(String(localized: "Delete"), role: .destructive) {
                vm.executeDelete(removePastPlans: false, in: modelContext) { dismiss() }
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "\u{201C}\(recipe.name)\u{201D} will be permanently deleted."))
        }
    }

    // MARK: - Nutrition display

    @ViewBuilder
    private func nutritionSection(_ n: RecipeNutrition) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(localized: "Nutrition"))
                .font(.title2).fontWeight(.semibold)

            HStack(spacing: 0) {
                nutritionCell(String(localized: "Calories"), value: n.calories, unit: "kcal", color: .orange)
                nutritionCell(String(localized: "Protein"),  value: n.protein,  unit: "g",    color: .blue)
                nutritionCell(String(localized: "Fat"),      value: n.fat,      unit: "g",    color: .yellow)
                nutritionCell(String(localized: "Carbs"),    value: n.carbs,    unit: "g",    color: .green)
                nutritionCell(String(localized: "Fiber"),    value: n.fiber,    unit: "g",    color: .brown)
            }
            .padding(12)
            .background(Color.secondary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(spacing: 6) {
                nutritionDetailRow(String(localized: "of which Saturated Fat"),    value: n.satFat,    unit: "g")
                nutritionDetailRow(String(localized: "of which Sugars"),    value: n.sugars,    unit: "g")
                Divider()
                nutritionDetailRow(String(localized: "Sodium"),    value: n.sodium,    unit: "mg", decimals: 0)
                nutritionDetailRow(String(localized: "Potassium"), value: n.potassium, unit: "mg", decimals: 0)
                nutritionDetailRow(String(localized: "Calcium"),   value: n.calcium,   unit: "mg", decimals: 0)
                nutritionDetailRow(String(localized: "Iron"),      value: n.iron,      unit: "mg")
                Divider()
                nutritionDetailRow(String(localized: "Vitamin C"),      value: n.vitC,      unit: "mg")
                nutritionDetailRow(String(localized: "Vitamin D"),      value: n.vitD,      unit: "µg")
            }
            .padding(12)
            .background(Color.secondary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if n.includedCount < n.totalCount {
                Text(String(localized: "Based on \(n.includedCount)/\(n.totalCount) ingredients (g/ml units only)"))
                    .font(.caption).foregroundStyle(.secondary)
            }
            Text(String(localized: "Based on data from NEVO online version 2025/9.0, RIVM, Bilthoven"))
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

    @ViewBuilder
    private func nutritionDetailRow(_ label: String, value: Double, unit: String, decimals: Int = 1) -> some View {
        HStack {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Spacer()
            Text(decimals == 0 ? "\(Int(value.rounded()))" : String(format: "%.\(decimals)f", value))
                .font(.caption).fontWeight(.medium)
            Text(unit).font(.caption).foregroundStyle(.secondary).frame(width: 28, alignment: .leading)
        }
    }
}
