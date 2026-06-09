import SwiftUI
import SwiftData
import TipKit

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

    @State private var vm = RecipeListViewModel()


    private var filtered: [Recipe] {
        vm.filtered(recipes: recipes, storageItems: allStorageItems)
    }

    private var inStockIDs: Set<PersistentIdentifier> {
        vm.inStockIDs(from: allStorageItems)
    }

    private var hasStorageData: Bool { !allStorageItems.isEmpty }

    // MARK: - Body

    var body: some View {
        @Bindable var vm = vm
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
            .navigationTitle(String(localized: "Recipes"))
            .searchable(text: $vm.searchText, prompt: String(localized: "Search recipe…"))
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu {
                        ForEach(RecipeSortOrder.allCases, id: \.self) { order in
                            Button {
                                vm.sortOrder = order
                            } label: {
                                HStack {
                                    Text(sortLabel(for: order))
                                    if vm.sortOrder == order {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label(String(localized: "Sort"), systemImage: "arrow.up.arrow.down")
                    }
                    Button { vm.showFilterPanel = true } label: {
                        Label(String(localized: "Filter"), systemImage: vm.isFiltering
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                    }
                    Menu {
                        Button { vm.showAddSheet = true } label: {
                            Label(String(localized: "New Recipe"), systemImage: "square.and.pencil")
                        }
                        if appSettings.featureAIImport {
                            Button { vm.showImportSheet = true } label: {
                                Label(String(localized: "Import Recipe"), systemImage: "square.and.arrow.down")
                            }
                        }
                    } label: {
                        Label(String(localized: "New Recipe"), systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $vm.showAddSheet) { RecipeFormView() }
            .sheet(isPresented: $vm.showImportSheet) { RecipeImportView() }
            .alert(item: $vm.deletionAlert) { alert in
                Alert(title: Text(alert.title), message: Text(alert.message))
            }
        }
        .sheet(isPresented: $vm.showFilterPanel) {
            RecipeFilterView(
                allIngredients: allIngredients,
                allCategories: allCategories,
                allTags: allTags,
                filter: $vm.filter
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
            Label(String(localized: "No Recipes"), systemImage: "fork.knife")
        } description: {
            Text(String(localized: "Add your first recipe with the + button."))
        } actions: {
            Button(String(localized: "Add Recipe")) { vm.showAddSheet = true }
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Helpers

    private func sortLabel(for order: RecipeSortOrder) -> String {
        switch order {
        case .nameAsc:  return String(localized: "Name A–Z")
        case .nameDesc: return String(localized: "Name Z–A")
        case .prepAsc:  return String(localized: "Quickest First")
        case .prepDesc: return String(localized: "Longest First")
        case .newest:   return String(localized: "Newest First")
        case .oldest:   return String(localized: "Oldest First")
        }
    }

    private func delete(at offsets: IndexSet) {
        let toDelete = offsets.map { filtered[$0] }
        for recipe in toDelete {
            vm.delete(recipe: recipe, in: modelContext)
        }
    }
}

// MARK: - Row

private struct RecipeRowView: View {

    @Environment(AppSettings.self) private var appSettings
    let recipe: Recipe
    let inStockIDs: Set<PersistentIdentifier>
    let hasStorageData: Bool


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
                Label(TimeFormat.prepTime(recipe.prepTimeMinutes), systemImage: "clock")
                Label(String(localized: "\(recipe.recipeIngredients.count) ingredients"), systemImage: "list.bullet")
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
                    Label(String(localized: "All in stock"), systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else if missing <= 2 {
                    Label(String(localized: "Missing \(missing)"), systemImage: "cart.badge.minus")
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
    @Binding var filter: RecipeFilter

    @State private var showIncludedPicker = false
    @State private var showExcludedPicker = false
    @State private var showCategoryPicker = false
    @State private var showTagPicker = false


    var body: some View {
        NavigationStack {
            Form {
                // ── What Can I Cook? ───────────────────────────────
                Section(String(localized: "What Can I Cook?")) {
                    stockModeRow(.all,           label: String(localized: "All Recipes"),      icon: "line.3.horizontal.decrease")
                    stockModeRow(.canCook,        label: String(localized: "Can Cook Now"),  icon: "checkmark.circle.fill",   color: .green)
                    stockModeRow(.almostCanCook,  label: String(localized: "Almost Ready"),   icon: "cart.badge.minus",        color: .orange)
                }

                // ── Favourites ────────────────────────────────────
                Section {
                    Toggle(String(localized: "Favorites only"), isOn: $filter.favoritesOnly)
                }

                // ── Rating ────────────────────────────────────────
                Section(String(localized: "Minimum Rating")) {
                    Button { filter.minRating = 0 } label: {
                        HStack {
                            Text(String(localized: "Any")).foregroundStyle(.primary)
                            Spacer()
                            if filter.minRating == 0 {
                                Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                    ForEach(1...5, id: \.self) { stars in
                        Button { filter.minRating = stars } label: {
                            HStack {
                                StarRatingView(rating: stars, interactive: false)
                                    .font(.subheadline)
                                Text("& up").font(.subheadline).foregroundStyle(.secondary)
                                Spacer()
                                if filter.minRating == stars {
                                    Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                    }
                }

                // ── Prep time ─────────────────────────────────────
                Section(String(localized: "Preparation Time")) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: "Minimum: \(TimeFormat.filterTime(filter.minMinutes))")).font(.subheadline)
                        Slider(value: $filter.minMinutes, in: 0...240, step: 5)
                            .onChange(of: filter.minMinutes) { _, val in
                                if val > filter.maxMinutes { filter.maxMinutes = val }
                            }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: "Maximum: \(TimeFormat.filterTime(filter.maxMinutes, isMax: true))")).font(.subheadline)
                        Slider(value: $filter.maxMinutes, in: 0...240, step: 5)
                            .onChange(of: filter.maxMinutes) { _, val in
                                if val < filter.minMinutes { filter.minMinutes = val }
                            }
                    }
                }

                // ── Categories ────────────────────────────────────
                Section(String(localized: "Category")) {
                    ForEach(allCategories.filter { filter.categoryIDs.contains($0.persistentModelID) }) { cat in
                        HStack {
                            Text(cat.name)
                            Spacer()
                            Button { filter.categoryIDs.remove(cat.persistentModelID) } label: {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Button { showCategoryPicker = true } label: {
                        Label(String(localized: "Category"), systemImage: "plus.circle")
                    }
                }

                // ── Tags ──────────────────────────────────────────
                Section(String(localized: "Tags")) {
                    ForEach(allTags.filter { filter.tagIDs.contains($0.persistentModelID) }) { tag in
                        HStack(spacing: 10) {
                            Circle().fill(Color(hex: tag.colorHex)).frame(width: 10, height: 10)
                            Text(tag.name)
                            Spacer()
                            Button { filter.tagIDs.remove(tag.persistentModelID) } label: {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Button { showTagPicker = true } label: {
                        Label(String(localized: "Tags"), systemImage: "plus.circle")
                    }
                }

                // ── Included ingredients ──────────────────────────
                Section(String(localized: "Included Ingredients")) {
                    ForEach(allIngredients.filter { filter.includedIngredientIDs.contains($0.persistentModelID) }) { ingredient in
                        HStack {
                            Text(ingredient.name)
                            Spacer()
                            Button {
                                filter.includedIngredientIDs.remove(ingredient.persistentModelID)
                            } label: {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Button { showIncludedPicker = true } label: {
                        Label(String(localized: "Add Ingredient"), systemImage: "plus.circle")
                    }
                }

                // ── Excluded ingredients ──────────────────────────
                Section(String(localized: "Excluded Ingredients")) {
                    ForEach(allIngredients.filter { filter.excludedIngredientIDs.contains($0.persistentModelID) }) { ingredient in
                        HStack {
                            Text(ingredient.name)
                            Spacer()
                            Button {
                                filter.excludedIngredientIDs.remove(ingredient.persistentModelID)
                            } label: {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Button { showExcludedPicker = true } label: {
                        Label(String(localized: "Add Ingredient"), systemImage: "plus.circle")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(String(localized: "Filter"))
            .navigationTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showIncludedPicker) {
                IngredientPickerNavView(
                    allIngredients: allIngredients,
                    selectedIDs: $filter.includedIngredientIDs,
                    conflictIDs: $filter.excludedIngredientIDs,
                    title: String(localized: "Included Ingredients")
                )
            }
            .navigationDestination(isPresented: $showExcludedPicker) {
                IngredientPickerNavView(
                    allIngredients: allIngredients,
                    selectedIDs: $filter.excludedIngredientIDs,
                    conflictIDs: $filter.includedIngredientIDs,
                    title: String(localized: "Excluded Ingredients")
                )
            }
            .navigationDestination(isPresented: $showCategoryPicker) {
                CategoryPickerNavView(
                    allCategories: allCategories,
                    selectedIDs: $filter.categoryIDs,
                    title: String(localized: "Category")
                )
            }
            .navigationDestination(isPresented: $showTagPicker) {
                TagPickerNavView(
                    allTags: allTags,
                    selectedIDs: $filter.tagIDs,
                    title: String(localized: "Tags")
                )
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Reset")) { filter.reset() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func stockModeRow(_ mode: StockFilterMode, label: String, icon: String, color: Color = .secondary) -> some View {
        Button { filter.stockMode = mode } label: {
            HStack(spacing: 10) {
                Image(systemName: icon).foregroundStyle(color)
                Text(label).foregroundStyle(.primary)
                Spacer()
                if filter.stockMode == mode {
                    Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                }
            }
        }
    }
}

// MARK: - Category picker (used by filter)

private struct CategoryPickerNavView: View {

    @Environment(AppSettings.self) private var appSettings

    let allCategories: [RecipeCategory]
    @Binding var selectedIDs: Set<PersistentIdentifier>
    let title: String

    @State private var searchText = ""


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
        .searchable(text: $searchText, prompt: String(localized: "Search category…"))
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
        .searchable(text: $searchText, prompt: String(localized: "Search tag…"))
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


    private var filtered: [Ingredient] {
        guard !searchText.isEmpty else { return allIngredients }
        return allIngredients.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        Group {
            if allIngredients.isEmpty {
                ContentUnavailableView {
                    Label(String(localized: "No Ingredients"), systemImage: "carrot")
                } description: { Text(String(localized: "First add ingredients via the Ingredients tab.")) }
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
                .searchable(text: $searchText, prompt: String(localized: "Search ingredient…"))
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
