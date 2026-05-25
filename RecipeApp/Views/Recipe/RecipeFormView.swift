import SwiftUI
import SwiftData
import PhotosUI
import ImageIO

struct RecipeFormView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings

    var recipe: Recipe?

    private var isEditing: Bool { recipe != nil }
    private var lang: AppLanguage { appSettings.language }

    // MARK: - Queries

    @Query(sort: \Ingredient.name) private var allIngredients: [Ingredient]
    @Query(sort: \RecipeCategory.name) private var allCategories: [RecipeCategory]
    @Query(sort: \RecipeTag.name) private var allTags: [RecipeTag]

    // MARK: - Form state

    @State private var name = ""
    @State private var instructions = ""
    @State private var prepHours = 0
    @State private var prepMinutes = 0
    @State private var lines: [IngredientLine] = []
    @State private var selectedCategory: RecipeCategory?
    @State private var selectedTagIDs: Set<PersistentIdentifier> = []
    @State private var showIngredientPicker = false
    @State private var pendingPhotos: [PhotosPickerItem] = []
    @State private var photoDatas: [Data] = []

    // Inline creation
    @State private var showAddCategoryAlert = false
    @State private var newCategoryName = ""
    @State private var showAddTagSheet = false
    @State private var newTagName = ""
    @State private var newTagColorHex = RecipeTag.presetColors[5]

    private var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // ── Photos ────────────────────────────────────────
                Section {
                    if !photoDatas.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(photoDatas.indices, id: \.self) { index in
                                    if let image = Image(data: photoDatas[index]) {
                                        ZStack(alignment: .topTrailing) {
                                            image.resizable().scaledToFill()
                                                .frame(width: 120, height: 120)
                                                .clipped().cornerRadius(8)
                                            Button { photoDatas.remove(at: index) } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .symbolRenderingMode(.palette)
                                                    .foregroundStyle(.white, Color.black.opacity(0.55))
                                                    .font(.title3)
                                            }
                                            .buttonStyle(.plain).padding(4)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                    }
                    PhotosPicker(selection: $pendingPhotos, maxSelectionCount: 10, matching: .images) {
                        Label(lang.addPhotos, systemImage: "photo.badge.plus")
                    }
                } header: { Text(lang.photosLabel) }

                // ── Basic info ────────────────────────────────────
                Section(lang.nameLabel) {
                    TextField(lang.recipeName, text: $name)
                }

                Section(lang.prepTime) {
                    Stepper(value: $prepHours, in: 0...24) {
                        HStack {
                            Text(lang.hoursLabel); Spacer()
                            Text("\(prepHours)").foregroundStyle(.secondary)
                        }
                    }
                    Stepper(value: $prepMinutes, in: 0...55, step: 5) {
                        HStack {
                            Text(lang.minutesLabel); Spacer()
                            Text("\(prepMinutes)").foregroundStyle(.secondary)
                        }
                    }
                }

                // ── Category ──────────────────────────────────────
                Section(lang.categoryLabel) {
                    Picker(lang.categoryLabel, selection: $selectedCategory) {
                        Text(lang.noCategoryOption).tag(nil as RecipeCategory?)
                        ForEach(allCategories) { cat in
                            Text(cat.name).tag(cat as RecipeCategory?)
                        }
                    }
                    Button { showAddCategoryAlert = true } label: {
                        Label(lang.addNewCategory, systemImage: "plus.circle")
                    }
                }

                // ── Tags ──────────────────────────────────────────
                Section(lang.tagsLabel) {
                    ForEach(allTags) { tag in
                        Button { toggleTag(tag) } label: {
                            HStack(spacing: 10) {
                                Circle().fill(Color(hex: tag.colorHex)).frame(width: 12, height: 12)
                                Text(tag.name).foregroundStyle(.primary)
                                Spacer()
                                if selectedTagIDs.contains(tag.persistentModelID) {
                                    Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                    }
                    Button { showAddTagSheet = true } label: {
                        Label(lang.addNewTag, systemImage: "plus.circle")
                    }
                }

                // ── Ingredients ───────────────────────────────────
                Section {
                    ForEach($lines) { $line in IngredientLineRow(line: $line) }
                        .onDelete { offsets in lines.remove(atOffsets: offsets) }
                    Button { showIngredientPicker = true } label: {
                        Label(lang.addIngredient, systemImage: "plus.circle.fill")
                    }
                    .popover(isPresented: $showIngredientPicker) {
                        IngredientPickerView(
                            ingredients: allIngredients,
                            selectedIDs: Set(lines.map { $0.ingredient.persistentModelID })
                        ) { ingredient in
                            if let idx = lines.firstIndex(where: { $0.ingredient.persistentModelID == ingredient.persistentModelID }) {
                                lines.remove(at: idx)
                            } else {
                                lines.append(IngredientLine(ingredient: ingredient, amount: 1))
                            }
                        }
                        .frame(minWidth: 280, minHeight: 380)
                    }
                } header: { Text(lang.ingredientsPerServing) } footer: { Text(lang.amountsNote) }

                // ── Instructions ──────────────────────────────────
                Section(lang.preparation) {
                    TextEditor(text: $instructions).frame(minHeight: 160)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isEditing ? lang.editRecipe : lang.newRecipe)
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? lang.save : lang.addItem) { save(); dismiss() }
                        .disabled(!isValid)
                }
            }
            .onAppear(perform: loadExisting)
            .onChange(of: pendingPhotos) { _, newItems in
                Task {
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            photoDatas.append(compressPhoto(data))
                        }
                    }
                    pendingPhotos = []
                }
            }
            .alert(lang.newCategoryTitle, isPresented: $showAddCategoryAlert) {
                TextField(lang.categoryNamePlaceholder, text: $newCategoryName)
                Button(lang.addItem) {
                    let trimmed = newCategoryName.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty {
                        let cat = RecipeCategory(name: trimmed, isCustom: true)
                        modelContext.insert(cat)
                        selectedCategory = cat
                    }
                    newCategoryName = ""
                }
                Button(lang.cancel, role: .cancel) { newCategoryName = "" }
            }
            .sheet(isPresented: $showAddTagSheet) {
                InlineAddTagSheet(selectedTagIDs: $selectedTagIDs)
            }
        }
    }

    // MARK: - Helpers

    private func toggleTag(_ tag: RecipeTag) {
        let id = tag.persistentModelID
        if selectedTagIDs.contains(id) { selectedTagIDs.remove(id) } else { selectedTagIDs.insert(id) }
    }

    // MARK: - Load / Save

    private func loadExisting() {
        guard let recipe else { return }
        name = recipe.name
        instructions = recipe.instructions
        prepHours = recipe.prepTimeMinutes / 60
        prepMinutes = recipe.prepTimeMinutes % 60
        photoDatas = recipe.photos.sorted { $0.sortOrder < $1.sortOrder }.map { $0.imageData }
        lines = recipe.recipeIngredients.compactMap { ri in
            guard let ing = ri.ingredient else { return nil }
            return IngredientLine(ingredient: ing, amount: ri.amount)
        }
        selectedCategory = recipe.category
        selectedTagIDs = Set(recipe.tags.map { $0.persistentModelID })
    }

    private func save() {
        let totalMinutes = prepHours * 60 + prepMinutes
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let chosenTags = allTags.filter { selectedTagIDs.contains($0.persistentModelID) }

        if let recipe {
            recipe.name = trimmedName
            recipe.instructions = instructions
            recipe.prepTimeMinutes = totalMinutes
            recipe.updatedAt = Date()
            recipe.category = selectedCategory
            recipe.tags = chosenTags

            for old in recipe.recipeIngredients { modelContext.delete(old) }
            recipe.recipeIngredients = []
            addLines(to: recipe)

            for old in recipe.photos { modelContext.delete(old) }
            recipe.photos = []
            savePhotos(to: recipe)
        } else {
            let newRecipe = Recipe(name: trimmedName, instructions: instructions, prepTimeMinutes: totalMinutes)
            newRecipe.category = selectedCategory
            newRecipe.tags = chosenTags
            modelContext.insert(newRecipe)
            addLines(to: newRecipe)
            savePhotos(to: newRecipe)
        }
    }

    private func addLines(to recipe: Recipe) {
        for line in lines {
            let ri = RecipeIngredient(ingredient: line.ingredient, amount: line.amount)
            recipe.recipeIngredients.append(ri)
            modelContext.insert(ri)
        }
    }

    private func savePhotos(to recipe: Recipe) {
        for (index, data) in photoDatas.enumerated() {
            let photo = RecipePhoto(imageData: data, sortOrder: index)
            recipe.photos.append(photo)
            modelContext.insert(photo)
        }
    }
}

// MARK: - Photo compression

private func compressPhoto(_ data: Data, maxDimension: CGFloat = 1200) -> Data {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil),
          let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return data }
    let w = CGFloat(cgImage.width), h = CGFloat(cgImage.height)
    let scale = min(maxDimension / max(w, h), 1.0)
    guard scale < 1.0 else { return data }
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(
        data: nil,
        width: Int(w * scale), height: Int(h * scale),
        bitsPerComponent: 8, bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ), let resized = { ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: Int(w * scale), height: Int(h * scale))); return ctx.makeImage() }()
    else { return data }
    let output = NSMutableData()
    guard let dest = CGImageDestinationCreateWithData(output, "public.jpeg" as CFString, 1, nil) else { return data }
    CGImageDestinationAddImage(dest, resized, [kCGImageDestinationLossyCompressionQuality: 0.82] as CFDictionary)
    return CGImageDestinationFinalize(dest) ? (output as Data) : data
}

// MARK: - Inline add-tag sheet (inside form)

private struct InlineAddTagSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings

    @Binding var selectedTagIDs: Set<PersistentIdentifier>
    @State private var name = ""
    @State private var colorHex = RecipeTag.presetColors[5]

    private var lang: AppLanguage { appSettings.language }

    var body: some View {
        NavigationStack {
            Form {
                Section(lang.nameLabel) {
                    TextField(lang.tagNamePlaceholder, text: $name)
                }
                Section(lang.tagColor) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(RecipeTag.presetColors, id: \.self) { hex in
                            Button { colorHex = hex } label: {
                                ZStack {
                                    Circle().fill(Color(hex: hex)).frame(width: 36, height: 36)
                                    if colorHex == hex {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white).font(.caption.bold())
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(lang.newTagTitle)
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.addItem) {
                        let trimmed = name.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            let tag = RecipeTag(name: trimmed, colorHex: colorHex, isCustom: true)
                            modelContext.insert(tag)
                            selectedTagIDs.insert(tag.persistentModelID)
                        }
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Working model

struct IngredientLine: Identifiable {
    let id = UUID()
    var ingredient: Ingredient
    var amount: Double
}

// MARK: - Ingredient line row

private struct IngredientLineRow: View {
    @Binding var line: IngredientLine

    var body: some View {
        HStack {
            Text(line.ingredient.name).font(.body)
            Spacer()
            TextField("0", value: $line.amount, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 80)
                .multilineTextAlignment(.trailing)
            Text(line.ingredient.unit)
                .font(.body).foregroundStyle(.secondary)
                .frame(minWidth: 28, alignment: .leading)
        }
    }
}

// MARK: - Ingredient picker

private struct IngredientPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings

    let ingredients: [Ingredient]
    let selectedIDs: Set<PersistentIdentifier>
    let onToggle: (Ingredient) -> Void
    @State private var searchText = ""

    private var lang: AppLanguage { appSettings.language }
    private var filtered: [Ingredient] {
        guard !searchText.isEmpty else { return ingredients }
        return ingredients.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if ingredients.isEmpty {
                    ContentUnavailableView {
                        Label(lang.noIngredientsTitle, systemImage: "carrot")
                    } description: { Text(lang.noIngredientsHint) }
                } else {
                    List(filtered) { ingredient in
                        Button { onToggle(ingredient) } label: {
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
            .navigationTitle(lang.chooseIngredients)
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.done) { dismiss() }
                }
            }
        }
    }
}

#Preview("New Recipe") {
    RecipeFormView()
        .environment(AppSettings())
        .modelContainer(for: [Recipe.self, Ingredient.self, RecipeIngredient.self,
                               RecipeCategory.self, RecipeTag.self], inMemory: true)
}
