import SwiftUI
import SwiftData
import TipKit

// Three-tier stock filter — defined at file scope so both structs can reference it
enum StockFilterMode: String, CaseIterable {
    case all           // no filter
    case canCook       // 0 ingredients missing from storage
    case almostCanCook // ≤2 ingredients missing from storage
}

enum RecipeSortOrder: String, CaseIterable {
    case nameAsc, nameDesc, prepAsc, prepDesc, newest, oldest
}

struct RecipeListView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query private var recipes: [Recipe]
    @Query(sort: \Ingredient.name) private var allIngredients: [Ingredient]
    @Query(sort: \RecipeCategory.name) private var allCategories: [RecipeCategory]
    @Query(sort: \RecipeTag.name) private var allTags: [RecipeTag]
    @Query private var allStorageItems: [StorageItem]

    private let addRecipeTip = AddRecipeTip()
    private let filterRecipeTip = FilterRecipeTip()

    @State private var searchText = ""
    @State private var showAddSheet = false
    @State private var showImportSheet = false
    @State private var showFilterPanel = false
    @State private var deletionAlert: DeletionAlert?
    @State private var sortOrder: RecipeSortOrder = .nameAsc

    private struct DeletionAlert: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    // MARK: - Filter state

    @State private var filterMinMinutes: Double = 0
    @State private var filterMaxMinutes: Double = 240
    @State private var includedIngredientIDs: Set<PersistentIdentifier> = []
    @State private var excludedIngredientIDs: Set<PersistentIdentifier> = []
    @State private var filterFavoritesOnly = false
    @State private var filterCategoryIDs: Set<PersistentIdentifier> = []
    @State private var filterTagIDs: Set<PersistentIdentifier> = []
    @State private var filterStockMode: StockFilterMode = .all
    @State private var filterMinRating: Int = 0

    // MARK: - Stock helpers

    /// IDs of ingredients that are currently in storage (any amount, any location).
    private var inStockIDs: Set<PersistentIdentifier> {
        Set(allStorageItems.compactMap { $0.ingredient?.persistentModelID })
    }

    private var hasStorageData: Bool { !allStorageItems.isEmpty }

    // MARK: - Active-filter indicator

    private var isFiltering: Bool {
        filterMinMinutes > 0 || filterMaxMinutes < 240
            || !includedIngredientIDs.isEmpty || !excludedIngredientIDs.isEmpty
            || filterFavoritesOnly
            || !filterCategoryIDs.isEmpty || !filterTagIDs.isEmpty
            || filterStockMode != .all
            || filterMinRating > 0
    }

    // MARK: - Filtered list

    private var filtered: [Recipe] {
        let stockIDs = inStockIDs
        var result = recipes.filter { recipe in
            if !searchText.isEmpty,
               !recipe.name.localizedCaseInsensitiveContains(searchText) { return false }

            if filterFavoritesOnly && !recipe.isFavorite { return false }

            let mins = Double(recipe.prepTimeMinutes)
            if filterMinMinutes > 0 && mins < filterMinMinutes { return false }
            if filterMaxMinutes < 240 && mins > filterMaxMinutes { return false }

            if !filterCategoryIDs.isEmpty {
                guard let catID = recipe.category?.persistentModelID,
                      filterCategoryIDs.contains(catID) else { return false }
            }

            if !filterTagIDs.isEmpty {
                let recipeTagIDs = Set(recipe.tags.map { $0.persistentModelID })
                if filterTagIDs.isDisjoint(with: recipeTagIDs) { return false }
            }

            if !includedIngredientIDs.isEmpty {
                let ids = Set(recipe.recipeIngredients.compactMap { $0.ingredient?.persistentModelID })
                if !includedIngredientIDs.isSubset(of: ids) { return false }
            }

            if !excludedIngredientIDs.isEmpty {
                let ids = Set(recipe.recipeIngredients.compactMap { $0.ingredient?.persistentModelID })
                if !excludedIngredientIDs.isDisjoint(with: ids) { return false }
            }

            if filterStockMode != .all {
                let missing = missingCount(for: recipe, inStockIDs: stockIDs)
                switch filterStockMode {
                case .canCook:       if missing > 0 { return false }
                case .almostCanCook: if missing > 2 { return false }
                case .all: break
                }
            }

            if filterMinRating > 0 && recipe.rating < filterMinRating { return false }

            return true
        }

        switch sortOrder {
        case .nameAsc:  result.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .nameDesc: result.sort { $0.name.localizedCompare($1.name) == .orderedDescending }
        case .prepAsc:  result.sort { $0.prepTimeMinutes < $1.prepTimeMinutes }
        case .prepDesc: result.sort { $0.prepTimeMinutes > $1.prepTimeMinutes }
        case .newest:   result.sort { $0.createdAt > $1.createdAt }
        case .oldest:   result.sort { $0.createdAt < $1.createdAt }
        }
        return result
    }

    private var lang: AppLanguage { appSettings.language }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TipView(addRecipeTip)
                    .padding(.horizontal)
                    .padding(.top, 4)
                TipView(filterRecipeTip)
                    .padding(.horizontal)
                Group {
                    if recipes.isEmpty { emptyState } else { list }
                }
            }
            .navigationTitle(lang.tabRecipes)
            .searchable(text: $searchText, prompt: lang.searchRecipe)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu {
                        ForEach(RecipeSortOrder.allCases, id: \.self) { order in
                            Button {
                                sortOrder = order
                            } label: {
                                HStack {
                                    Text(sortLabel(for: order))
                                    if sortOrder == order {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label(lang.sortLabel, systemImage: "arrow.up.arrow.down")
                    }
                    Button { showFilterPanel = true } label: {
                        Label(lang.filterTitle, systemImage: isFiltering
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                    }
                    Menu {
                        Button { showAddSheet = true } label: {
                            Label(lang.newRecipe, systemImage: "square.and.pencil")
                        }
                        if appSettings.featureAIImport {
                            Button { showImportSheet = true } label: {
                                Label(lang.importRecipeBtn, systemImage: "square.and.arrow.down")
                            }
                        }
                    } label: {
                        Label(lang.newRecipe, systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) { RecipeFormView() }
            .sheet(isPresented: $showImportSheet) { RecipeImportView() }
            .alert(item: $deletionAlert) { alert in
                Alert(title: Text(alert.title), message: Text(alert.message))
            }
        }
        .sheet(isPresented: $showFilterPanel) {
            RecipeFilterView(
                allIngredients: allIngredients,
                allCategories: allCategories,
                allTags: allTags,
                minMinutes: $filterMinMinutes,
                maxMinutes: $filterMaxMinutes,
                includedIDs: $includedIngredientIDs,
                excludedIDs: $excludedIngredientIDs,
                favoritesOnly: $filterFavoritesOnly,
                categoryIDs: $filterCategoryIDs,
                tagIDs: $filterTagIDs,
                stockMode: $filterStockMode,
                minRating: $filterMinRating
            )
        }
    }

    // MARK: - Subviews

    private var list: some View {
        List {
            ForEach(filtered) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeRowView(
                        recipe: recipe,
                        inStockIDs: inStockIDs,
                        hasStorageData: hasStorageData
                    )
                }
            }
            .onDelete(perform: delete)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(lang.noRecipes, systemImage: "fork.knife")
        } description: {
            Text(lang.addFirstRecipe)
        } actions: {
            Button(lang.addRecipeBtn) { showAddSheet = true }
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Helpers

    private func sortLabel(for order: RecipeSortOrder) -> String {
        switch order {
        case .nameAsc:  return lang.sortByNameAZ
        case .nameDesc: return lang.sortByNameZA
        case .prepAsc:  return lang.sortByPrepAsc
        case .prepDesc: return lang.sortByPrepDesc
        case .newest:   return lang.sortNewest
        case .oldest:   return lang.sortOldest
        }
    }

    private func delete(at offsets: IndexSet) {
        let today = Calendar.current.startOfDay(for: Date())
        let toDelete = offsets.map { filtered[$0] }
        for recipe in toDelete {
            let plans = mealPlansFor(recipe: recipe)
            let futurePlans = plans.filter { $0.date >= today }
            if !futurePlans.isEmpty {
                deletionAlert = DeletionAlert(
                    title: lang.recipeFutureScheduledTitle,
                    message: lang.recipeFutureScheduledMessage(recipe.name, futurePlans.count)
                )
            } else {
                for plan in plans where plan.date < today { modelContext.delete(plan) }
                modelContext.delete(recipe)
            }
        }
    }

    private func mealPlansFor(recipe: Recipe) -> [MealPlan] {
        let all = (try? modelContext.fetch(FetchDescriptor<MealPlan>())) ?? []
        return all.filter { $0.recipe?.persistentModelID == recipe.persistentModelID }
    }

    private func missingCount(for recipe: Recipe, inStockIDs: Set<PersistentIdentifier>) -> Int {
        let total = recipe.recipeIngredients.count
        let inStock = recipe.recipeIngredients.filter {
            guard let ing = $0.ingredient else { return false }
            return inStockIDs.contains(ing.persistentModelID)
        }.count
        return total - inStock
    }
}

// MARK: - Row

private struct RecipeRowView: View {

    @Environment(AppSettings.self) private var appSettings
    let recipe: Recipe
    let inStockIDs: Set<PersistentIdentifier>
    let hasStorageData: Bool

    private var lang: AppLanguage { appSettings.language }

    private var stockCoverage: (inStock: Int, total: Int) {
        let total = recipe.recipeIngredients.count
        guard total > 0 else { return (0, 0) }
        let inStock = recipe.recipeIngredients.filter {
            guard let ing = $0.ingredient else { return false }
            return inStockIDs.contains(ing.persistentModelID)
        }.count
        return (inStock, total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(recipe.name).font(.headline)
                Spacer()
                Button {
                    recipe.isFavorite.toggle()
                } label: {
                    Image(systemName: recipe.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(recipe.isFavorite ? .yellow : .secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 12) {
                Label(lang.formattedPrepTime(recipe.prepTimeMinutes), systemImage: "clock")
                Label(lang.ingredientCount(recipe.recipeIngredients.count), systemImage: "list.bullet")
                stockBadge
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if recipe.rating > 0 {
                StarRatingView(rating: recipe.rating, interactive: false)
                    .font(.caption)
            }

            if recipe.category != nil || !recipe.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        if let cat = recipe.category {
                            Text(cat.name)
                                .font(.caption2)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Color.accentColor.opacity(0.15))
                                .foregroundStyle(Color.accentColor)
                                .clipShape(Capsule())
                        }
                        ForEach(recipe.tags.sorted { $0.name < $1.name }.prefix(4), id: \.persistentModelID) { tag in
                            Text(tag.name)
                                .font(.caption2)
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Color(hex: tag.colorHex).opacity(0.15))
                                .foregroundStyle(Color(hex: tag.colorHex))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var stockBadge: some View {
        if hasStorageData {
            let coverage = stockCoverage
            if coverage.total > 0 {
                let missing = coverage.total - coverage.inStock
                if missing == 0 {
                    Label(lang.allInStock, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else if missing <= 2 {
                    Label(lang.missingCount(missing), systemImage: "cart.badge.minus")
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}

// MARK: - Filter panel

private struct RecipeFilterView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings

    let allIngredients: [Ingredient]
    let allCategories: [RecipeCategory]
    let allTags: [RecipeTag]
    @Binding var minMinutes: Double
    @Binding var maxMinutes: Double
    @Binding var includedIDs: Set<PersistentIdentifier>
    @Binding var excludedIDs: Set<PersistentIdentifier>
    @Binding var favoritesOnly: Bool
    @Binding var categoryIDs: Set<PersistentIdentifier>
    @Binding var tagIDs: Set<PersistentIdentifier>
    @Binding var stockMode: StockFilterMode
    @Binding var minRating: Int

    @State private var showIncludedPicker = false
    @State private var showExcludedPicker = false
    @State private var showCategoryPicker = false
    @State private var showTagPicker = false

    private var lang: AppLanguage { appSettings.language }

    var body: some View {
        NavigationStack {
            Form {
                // ── What Can I Cook? ───────────────────────────────
                Section(lang.whatCanICook) {
                    stockModeRow(.all,           label: lang.stockModeAll,      icon: "line.3.horizontal.decrease")
                    stockModeRow(.canCook,        label: lang.stockModeCanCook,  icon: "checkmark.circle.fill",   color: .green)
                    stockModeRow(.almostCanCook,  label: lang.stockModeAlmost,   icon: "cart.badge.minus",        color: .orange)
                }

                // ── Favourites ────────────────────────────────────
                Section {
                    Toggle(lang.favoritesOnly, isOn: $favoritesOnly)
                }

                // ── Rating ────────────────────────────────────────
                Section(lang.filterByRating) {
                    Button { minRating = 0 } label: {
                        HStack {
                            Text(lang.ratingAny).foregroundStyle(.primary)
                            Spacer()
                            if minRating == 0 {
                                Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    ForEach(1...5, id: \.self) { stars in
                        Button { minRating = stars } label: {
                            HStack {
                                StarRatingView(rating: stars, interactive: false)
                                    .font(.subheadline)
                                Text("& up").font(.subheadline).foregroundStyle(.secondary)
                                Spacer()
                                if minRating == stars {
                                    Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                    }
                }

                // ── Prep time ─────────────────────────────────────
                Section(lang.prepTimeRange) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(lang.minimumLabel(lang.formattedFilterTime(minMinutes))).font(.subheadline)
                        Slider(value: $minMinutes, in: 0...240, step: 5)
                            .onChange(of: minMinutes) { _, val in if val > maxMinutes { maxMinutes = val } }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(lang.maximumLabel(lang.formattedFilterTime(maxMinutes, isMax: true))).font(.subheadline)
                        Slider(value: $maxMinutes, in: 0...240, step: 5)
                            .onChange(of: maxMinutes) { _, val in if val < minMinutes { minMinutes = val } }
                    }
                }

                // ── Categories ────────────────────────────────────
                Section(lang.filterByCategory) {
                    ForEach(allCategories.filter { categoryIDs.contains($0.persistentModelID) }) { cat in
                        HStack {
                            Text(cat.name)
                            Spacer()
                            Button { categoryIDs.remove(cat.persistentModelID) } label: {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Button { showCategoryPicker = true } label: {
                        Label(lang.filterByCategory, systemImage: "plus.circle")
                    }
                }

                // ── Tags ──────────────────────────────────────────
                Section(lang.filterByTags) {
                    ForEach(allTags.filter { tagIDs.contains($0.persistentModelID) }) { tag in
                        HStack(spacing: 10) {
                            Circle().fill(Color(hex: tag.colorHex)).frame(width: 10, height: 10)
                            Text(tag.name)
                            Spacer()
                            Button { tagIDs.remove(tag.persistentModelID) } label: {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Button { showTagPicker = true } label: {
                        Label(lang.filterByTags, systemImage: "plus.circle")
                    }
                }

                // ── Included ingredients ──────────────────────────
                Section(lang.includedIngredients) {
                    ForEach(allIngredients.filter { includedIDs.contains($0.persistentModelID) }) { ingredient in
                        HStack {
                            Text(ingredient.name)
                            Spacer()
                            Button {
                                includedIDs.remove(ingredient.persistentModelID)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Button { showIncludedPicker = true } label: {
                        Label(lang.addIngredient, systemImage: "plus.circle")
                    }
                }

                // ── Excluded ingredients ──────────────────────────
                Section(lang.excludedIngredients) {
                    ForEach(allIngredients.filter { excludedIDs.contains($0.persistentModelID) }) { ingredient in
                        HStack {
                            Text(ingredient.name)
                            Spacer()
                            Button {
                                excludedIDs.remove(ingredient.persistentModelID)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Button { showExcludedPicker = true } label: {
                        Label(lang.addIngredient, systemImage: "plus.circle")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(lang.filterTitle)
            .navigationTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showIncludedPicker) {
                IngredientPickerNavView(
                    allIngredients: allIngredients,
                    selectedIDs: $includedIDs,
                    conflictIDs: $excludedIDs,
                    title: lang.includedIngredients
                )
            }
            .navigationDestination(isPresented: $showExcludedPicker) {
                IngredientPickerNavView(
                    allIngredients: allIngredients,
                    selectedIDs: $excludedIDs,
                    conflictIDs: $includedIDs,
                    title: lang.excludedIngredients
                )
            }
            .navigationDestination(isPresented: $showCategoryPicker) {
                CategoryPickerNavView(
                    allCategories: allCategories,
                    selectedIDs: $categoryIDs,
                    title: lang.filterByCategory
                )
            }
            .navigationDestination(isPresented: $showTagPicker) {
                TagPickerNavView(
                    allTags: allTags,
                    selectedIDs: $tagIDs,
                    title: lang.filterByTags
                )
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.reset) {
                        minMinutes = 0; maxMinutes = 240
                        includedIDs = []; excludedIDs = []
                        favoritesOnly = false
                        categoryIDs = []; tagIDs = []
                        stockMode = .all
                        minRating = 0
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.done) { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func stockModeRow(_ mode: StockFilterMode, label: String, icon: String, color: Color = .secondary) -> some View {
        Button { stockMode = mode } label: {
            HStack(spacing: 10) {
                Image(systemName: icon).foregroundStyle(color)
                Text(label).foregroundStyle(.primary)
                Spacer()
                if stockMode == mode {
                    Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                }
            }
        }
    }

    private func toggle(_ id: PersistentIdentifier, in target: inout Set<PersistentIdentifier>) {
        if target.contains(id) { target.remove(id) } else { target.insert(id) }
    }

    private func toggle(_ id: PersistentIdentifier,
                        in target: inout Set<PersistentIdentifier>,
                        removing other: inout Set<PersistentIdentifier>) {
        if target.contains(id) { target.remove(id) } else { target.insert(id); other.remove(id) }
    }
}

// MARK: - Category picker (used by filter)

private struct CategoryPickerNavView: View {

    @Environment(AppSettings.self) private var appSettings

    let allCategories: [RecipeCategory]
    @Binding var selectedIDs: Set<PersistentIdentifier>
    let title: String

    @State private var searchText = ""

    private var lang: AppLanguage { appSettings.language }

    private var filtered: [RecipeCategory] {
        guard !searchText.isEmpty else { return allCategories }
        return allCategories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List(filtered) { cat in
            Button {
                let id = cat.persistentModelID
                if selectedIDs.contains(id) { selectedIDs.remove(id) } else { selectedIDs.insert(id) }
            } label: {
                HStack {
                    Text(cat.name).foregroundStyle(.primary)
                    Spacer()
                    if selectedIDs.contains(cat.persistentModelID) {
                        Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: lang.searchCategory)
        .navigationTitle(title)
        .navigationTitleDisplayMode(.inline)
    }
}

// MARK: - Tag picker (used by filter)

private struct TagPickerNavView: View {

    @Environment(AppSettings.self) private var appSettings

    let allTags: [RecipeTag]
    @Binding var selectedIDs: Set<PersistentIdentifier>
    let title: String

    @State private var searchText = ""

    private var lang: AppLanguage { appSettings.language }

    private var filtered: [RecipeTag] {
        guard !searchText.isEmpty else { return allTags }
        return allTags.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List(filtered) { tag in
            Button {
                let id = tag.persistentModelID
                if selectedIDs.contains(id) { selectedIDs.remove(id) } else { selectedIDs.insert(id) }
            } label: {
                HStack(spacing: 10) {
                    Circle().fill(Color(hex: tag.colorHex)).frame(width: 12, height: 12)
                    Text(tag.name).foregroundStyle(.primary)
                    Spacer()
                    if selectedIDs.contains(tag.persistentModelID) {
                        Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: lang.searchTag)
        .navigationTitle(title)
        .navigationTitleDisplayMode(.inline)
    }
}

// MARK: - Ingredient picker (used by filter include/exclude)

private struct IngredientPickerNavView: View {

    @Environment(AppSettings.self) private var appSettings

    let allIngredients: [Ingredient]
    @Binding var selectedIDs: Set<PersistentIdentifier>
    @Binding var conflictIDs: Set<PersistentIdentifier>
    let title: String

    @State private var searchText = ""

    private var lang: AppLanguage { appSettings.language }

    private var filtered: [Ingredient] {
        guard !searchText.isEmpty else { return allIngredients }
        return allIngredients.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        Group {
            if allIngredients.isEmpty {
                ContentUnavailableView {
                    Label(lang.noIngredientsTitle, systemImage: "carrot")
                } description: { Text(lang.noIngredientsHint) }
            } else {
                List(filtered) { ingredient in
                    Button {
                        let id = ingredient.persistentModelID
                        if selectedIDs.contains(id) {
                            selectedIDs.remove(id)
                        } else {
                            selectedIDs.insert(id)
                            conflictIDs.remove(id)
                        }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ingredient.name).foregroundStyle(.primary)
                                Text(ingredient.unit).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if selectedIDs.contains(ingredient.persistentModelID) {
                                Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: lang.searchIngredient)
            }
        }
        .navigationTitle(title)
        .navigationTitleDisplayMode(.inline)
    }
}

#Preview {
    RecipeListView()
        .environment(AppSettings())
        .modelContainer(for: [Recipe.self, Ingredient.self, RecipeIngredient.self,
                               RecipePhoto.self, RecipeCategory.self, RecipeTag.self,
                               StorageItem.self],
                        inMemory: true)
}
