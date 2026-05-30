import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers
#if canImport(UIKit)
import UIKit
#endif

struct RecipeImportView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \Ingredient.name) private var allIngredients: [Ingredient]

    private var lang: AppLanguage { appSettings.language }

    // MARK: - State

    enum ImportMode: String, CaseIterable { case url, photo }

    @State private var mode: ImportMode = .url
    @State private var urlText = ""
    @State private var selectedImage: CGImage?

    // iOS pickers
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var showCamera = false

    // macOS picker
    @State private var showFilePicker = false

    enum LoadState {
        case idle
        case loading(String)
        case success(ImportedRecipeData)
        case failure(String)
    }
    @State private var loadState: LoadState = .idle

    // Editable preview fields
    @State private var editedName = ""
    @State private var editedPrepHours = 0
    @State private var editedPrepMinutes = 0
    @State private var editedInstructions = ""
    @State private var editedIngredients: [ImportedIngredientData] = []

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // ── Mode picker ───────────────────────────────────
                Section {
                    Picker("", selection: $mode) {
                        Text(lang.importFromURL).tag(ImportMode.url)
                        Text(lang.importFromPhoto).tag(ImportMode.photo)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: mode) { _, _ in loadState = .idle }
                }

                // ── AI disclaimer ─────────────────────────────────
                Section {
                    Label {
                        Text(lang.aiImportDisclaimer)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.tint)
                    }
                }

                // ── Input ─────────────────────────────────────────
                if mode == .url {
                    urlInputSection
                } else {
                    photoInputSection
                }

                // ── Result ────────────────────────────────────────
                switch loadState {
                case .idle:
                    EmptyView()
                case .loading(let msg):
                    Section {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text(msg).foregroundStyle(.secondary)
                        }
                    }
                case .failure(let msg):
                    Section {
                        Label(msg, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                case .success:
                    previewSection
                }
            }
            .formStyle(.grouped)
            .navigationTitle(lang.importRecipeTitle)
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.cancel) { dismiss() }
                }
                if case .success = loadState {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(lang.addToRecipes) { saveRecipe(); dismiss() }
                            .fontWeight(.semibold)
                    }
                }
            }
            // macOS: file importer
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.jpeg, .png, .heic, .tiff, .bmp, .image]
            ) { handleFilePicked($0) }
            // iOS: camera sheet
            #if os(iOS)
            .fullScreenCover(isPresented: $showCamera) {
                CameraPickerView { cgImage in
                    showCamera = false
                    if let img = cgImage {
                        selectedImage = img
                        loadState = .idle
                    }
                }
                .ignoresSafeArea()
            }
            #endif
            // iOS: photo library changes
            .onChange(of: photoPickerItem) { _, item in
                guard let item else { return }
                Task { await loadPhotoPickerItem(item) }
            }
        }
        #if os(macOS)
        .frame(minWidth: 520, minHeight: 480)
        #endif
    }

    // MARK: - URL Section

    private var urlInputSection: some View {
        Section(lang.importFromURL) {
            TextField(lang.urlPlaceholder, text: $urlText)
                #if os(iOS)
                .keyboardType(.URL)
                .autocapitalization(.none)
                #endif
                .autocorrectionDisabled()
            Button(lang.fetchButton) {
                Task { await fetchURL() }
            }
            .disabled(urlText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    // MARK: - Photo Section

    private var photoInputSection: some View {
        Section(lang.importFromPhoto) {
            // Selected image preview + Analyze button
            if let img = selectedImage {
                HStack(spacing: 12) {
                    Image(img, scale: 1, label: Text(""))
                        .resizable().scaledToFill()
                        .frame(width: 80, height: 60).clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Spacer()
                    if #available(iOS 26, macOS 26, *) {
                        Button(lang.analyzeButton) {
                            Task { await analyzeImage(img) }
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Text(lang.aiRequiresiOS26)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 160)
                    }
                }
            }

            #if os(iOS)
            // Camera button (real device only)
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button {
                    showCamera = true
                } label: {
                    Label(lang.takePhoto, systemImage: "camera")
                }
            }
            // Photo library via PhotosPicker
            PhotosPicker(selection: $photoPickerItem, matching: .images) {
                Label(lang.choosePhoto, systemImage: "photo.on.rectangle")
            }
            #else
            // macOS: file picker
            Button(lang.choosePhoto) {
                showFilePicker = true
            }
            #endif
        }
    }

    // MARK: - Preview / Edit Section

    private var previewSection: some View {
        Group {
            Section(lang.recipeName) {
                TextField(lang.recipeName, text: $editedName)
            }

            Section(lang.prepTime) {
                Stepper(value: $editedPrepHours, in: 0...24) {
                    Text("\(editedPrepHours) \(lang.hoursLabel)")
                }
                Stepper(value: $editedPrepMinutes, in: 0...59, step: 5) {
                    Text("\(editedPrepMinutes) \(lang.minutesLabel)")
                }
            }

            Section(lang.ingredientsTitle) {
                ForEach($editedIngredients, id: \.name) { $ing in
                    HStack(spacing: 6) {
                        TextField("1", value: $ing.amount, format: .number)
                            .frame(width: 44)
                            .multilineTextAlignment(.trailing)
                        TextField(lang.unitLabel, text: $ing.unit)
                            .frame(width: 52)
                        TextField(lang.nameLabel, text: $ing.name)
                    }
                }
                .onDelete { editedIngredients.remove(atOffsets: $0) }
                Button(lang.addIngredient) {
                    editedIngredients.append(ImportedIngredientData(name: "", amount: 1, unit: ""))
                }
            }

            Section(lang.preparation) {
                TextEditor(text: $editedInstructions)
                    .frame(minHeight: 120)
            }
        }
    }

    // MARK: - Image loading

    private func loadPhotoPickerItem(_ item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let src = CGImageSourceCreateWithData(data as CFData, nil),
              let raw = CGImageSourceCreateImageAtIndex(src, 0, nil),
              let img = normalizeImage(raw) else { return }
        await MainActor.run {
            selectedImage = img
            loadState = .idle
        }
    }

    private func handleFilePicked(_ result: Result<URL, Error>) {
        guard case .success(let url) = result else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        // Read raw bytes while the security scope is still open (CGImageSource is lazy)
        let data = try? Data(contentsOf: url)
        url.stopAccessingSecurityScopedResource()
        guard let data,
              let src = CGImageSourceCreateWithData(data as CFData, nil),
              let raw = CGImageSourceCreateImageAtIndex(src, 0, nil),
              let img = normalizeImage(raw) else { return }
        selectedImage = img
        loadState = .idle
    }

    /// Redraws the image into a plain sRGB bitmap context, materialising all pixels
    /// and converting any unusual color space (e.g. CMYK, P3) to sRGB.
    private func normalizeImage(_ source: CGImage) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let ctx = CGContext(
            data: nil,
            width: source.width,
            height: source.height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }
        ctx.draw(source, in: CGRect(x: 0, y: 0, width: source.width, height: source.height))
        return ctx.makeImage()
    }

    // MARK: - Fetch / Analyze

    private func fetchURL() async {
        loadState = .loading(lang.fetchingURL)
        do {
            let parsed = try await RecipeImportService.importFromURL(urlText)
            loadState = .success(parsed)
            populate(from: parsed)
        } catch {
            loadState = .failure(error.localizedDescription)
        }
    }

    private func analyzeImage(_ image: CGImage) async {
        loadState = .loading(lang.analyzingRecipe)
        do {
            let parsed = try await RecipeImportService.importFromImage(image)
            loadState = .success(parsed)
            populate(from: parsed)
        } catch {
            loadState = .failure(error.localizedDescription)
        }
    }

    private func populate(from data: ImportedRecipeData) {
        editedName = data.name
        editedPrepHours = data.prepTimeMinutes / 60
        editedPrepMinutes = data.prepTimeMinutes % 60
        editedInstructions = data.instructions
        editedIngredients = data.ingredients
    }

    // MARK: - Save

    private func saveRecipe() {
        let recipe = Recipe(
            name: editedName.isEmpty ? "Imported Recipe" : editedName,
            instructions: editedInstructions,
            prepTimeMinutes: editedPrepHours * 60 + editedPrepMinutes
        )
        modelContext.insert(recipe)

        for ing in editedIngredients where !ing.name.trimmingCharacters(in: .whitespaces).isEmpty {
            let (ingredient, isNew) = findOrCreateIngredient(name: ing.name, unit: ing.unit)
            if isNew && appSettings.featureNutrition,
               let info = try? NutritionService.lookup(ingredientName: ing.name) {
                ingredient.caloriesPer100g = info.caloriesPer100g
                ingredient.proteinPer100g  = info.proteinPer100g
                ingredient.fatPer100g      = info.fatPer100g
                ingredient.carbsPer100g    = info.carbsPer100g
                ingredient.fiberPer100g    = info.fiberPer100g
            }
            let line = RecipeIngredient(ingredient: ingredient, amount: max(ing.amount, 0.1))
            line.recipe = recipe
            modelContext.insert(line)
        }
    }

    private func findOrCreateIngredient(name: String, unit: String) -> (Ingredient, Bool) {
        let lower = name.lowercased()
        if let existing = allIngredients.first(where: { $0.name.lowercased() == lower }) {
            return (existing, false)
        }
        let new = Ingredient(name: name, unit: unit)
        modelContext.insert(new)
        return (new, true)
    }
}

// MARK: - Camera picker (iOS only)

#if canImport(UIKit)
struct CameraPickerView: UIViewControllerRepresentable {
    let onImage: (CGImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onImage: onImage) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImage: (CGImage?) -> Void
        init(onImage: @escaping (CGImage?) -> Void) { self.onImage = onImage }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let uiImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            onImage(uiImage?.cgImage)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onImage(nil)
        }
    }
}
#endif

#Preview {
    RecipeImportView()
        .environment(AppSettings())
        .modelContainer(for: [Recipe.self, Ingredient.self, RecipeIngredient.self], inMemory: true)
}
