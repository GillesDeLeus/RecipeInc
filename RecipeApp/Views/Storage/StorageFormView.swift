import SwiftUI
import SwiftData
#if os(iOS)
import VisionKit
import AVFoundation
#endif

struct StorageFormView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \Ingredient.name) private var allIngredients: [Ingredient]

    var item: StorageItem?

    private var isEditing: Bool { item != nil }

    // MARK: - Form state

    @State private var selectedIngredient: Ingredient?
    @State private var amount: Double = 1
    @State private var location: StorageLocation = .foodCloset
    @State private var hasExpiry = false
    @State private var expiryDate = Date()

    // MARK: - Barcode state

    @State private var showScanner = false
    @State private var isLookingUp = false
    @State private var scanResult: ScanResult? = nil
    @State private var showCameraAccessAlert = false

    private enum ScanResult {
        case found(String)
        case notFound
    }

    private var scannerAvailable: Bool {
        #if os(iOS)
        return DataScannerViewController.isSupported
        #else
        return false
        #endif
    }

    private var isValid: Bool { selectedIngredient != nil }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // ── Ingredient ────────────────────────────────────
                Section(String(localized: "Ingredient")) {
                    Picker(String(localized: "Ingredient"), selection: $selectedIngredient) {
                        Text(String(localized: "Choose an ingredient"))
                            .tag(nil as Ingredient?)
                        ForEach(allIngredients) { ingredient in
                            Text(ingredient.name)
                                .tag(ingredient as Ingredient?)
                        }
                    }

                    #if os(iOS)
                    if scannerAvailable {
                        if isLookingUp {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text(String(localized: "Looking up product…"))
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            }
                        } else {
                            Button {
                                scanResult = nil
                                requestCameraAndScan()
                            } label: {
                                Label(String(localized: "Scan Barcode"), systemImage: "barcode.viewfinder")
                            }
                        }

                        if let result = scanResult {
                            switch result {
                            case .found(let name):
                                Label(String(localized: "Found: \(name)"), systemImage: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            case .notFound:
                                Label(String(localized: "Product not found. Select manually."), systemImage: "exclamationmark.triangle")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                    #endif
                }

                // ── Amount ────────────────────────────────────────
                Section(String(localized: "Amount")) {
                    HStack {
                        TextField("0", value: $amount, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                            .multilineTextAlignment(.trailing)
                        if let unit = selectedIngredient?.unit, !unit.isEmpty {
                            Text(unit)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }

                // ── Location ──────────────────────────────────────
                Section(String(localized: "Location")) {
                    Picker(String(localized: "Location"), selection: $location) {
                        ForEach(StorageLocation.allCases, id: \.self) { loc in
                            Label(loc.localizedName, systemImage: loc.icon)
                                .tag(loc)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // ── Expiry date ───────────────────────────────────
                Section(String(localized: "Expiry Date")) {
                    Toggle(String(localized: "Has expiry date"), isOn: $hasExpiry.animation())
                    if hasExpiry {
                        DatePicker(
                            String(localized: "Date"),
                            selection: $expiryDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isEditing ? String(localized: "Edit Storage Item") : String(localized: "New Storage Item"))
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? String(localized: "Save") : String(localized: "Add")) {
                        save()
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear(perform: loadExisting)
            #if os(iOS)
            .fullScreenCover(isPresented: $showScanner) {
                BarcodeScannerSheet { code in handleBarcode(code) }
            }
            .alert("Camera Access Required", isPresented: $showCameraAccessAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button(String(localized: "Cancel"), role: .cancel) {}
            } message: {
                Text("Please allow camera access in Settings to scan barcodes.")
            }
            #endif
        }
    }

    // MARK: - Barcode handling

    #if os(iOS)
    private func requestCameraAndScan() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showScanner = true
        case .notDetermined:
            Task {
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                await MainActor.run {
                    if granted { showScanner = true }
                    else { showCameraAccessAlert = true }
                }
            }
        case .denied, .restricted:
            showCameraAccessAlert = true
        @unknown default:
            showScanner = true
        }
    }
    #endif

    private func handleBarcode(_ code: String) {
        isLookingUp = true
        scanResult = nil
        Task {
            do {
                let product = try await BarcodeService.lookup(barcode: code)
                await MainActor.run {
                    let lower = product.name.lowercased()
                    if let existing = allIngredients.first(where: {
                        $0.name.lowercased() == lower
                    }) {
                        selectedIngredient = existing
                    } else {
                        let new = Ingredient(
                            name: product.name,
                            unit: product.unit,
                            shoppingCategory: product.category
                        )
                        new.caloriesPer100g = product.caloriesPer100g
                        new.proteinPer100g  = product.proteinPer100g
                        new.fatPer100g      = product.fatPer100g
                        new.carbsPer100g    = product.carbsPer100g
                        new.fiberPer100g    = product.fiberPer100g
                        modelContext.insert(new)
                        selectedIngredient = new
                    }
                    scanResult = .found(product.name)
                    isLookingUp = false
                }
            } catch {
                await MainActor.run {
                    scanResult = .notFound
                    isLookingUp = false
                }
            }
        }
    }

    // MARK: - Load existing

    private func loadExisting() {
        guard let item else { return }
        selectedIngredient = item.ingredient
        amount = item.amount
        location = item.location
        if let expiry = item.expiryDate {
            hasExpiry = true
            expiryDate = expiry
        }
    }

    // MARK: - Save

    private func save() {
        if let item {
            item.ingredient = selectedIngredient
            item.amount = amount
            item.location = location
            item.expiryDate = hasExpiry ? expiryDate : nil
            NotificationManager.shared.updateNotifications(for: item)
        } else {
            let newItem = StorageItem(
                ingredient: selectedIngredient,
                amount: amount,
                location: location,
                expiryDate: hasExpiry ? expiryDate : nil
            )
            modelContext.insert(newItem)
            NotificationManager.shared.updateNotifications(for: newItem)
        }
    }
}

#Preview {
    StorageFormView()
        .environment(AppSettings())
        .modelContainer(for: [StorageItem.self, Ingredient.self], inMemory: true)
}
