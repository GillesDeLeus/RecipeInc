import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {

    @Environment(AppSettings.self) private var appSettings
    @Environment(\.modelContext) private var modelContext

    @State private var showExporter   = false
    @State private var exportFile: JSONFile?
    @State private var showImporter   = false
    @State private var importAlert: ImportAlertState?
    @State private var pendingConflicts: [ImportConflict] = []
    @State private var showConflictSheet = false

    @State private var showFeaturesSheet    = false
    @State private var showCategoriesSheet  = false
    @State private var showTagsSheet        = false
    @State private var showAisleOrderSheet  = false
    @State private var showPrivacySheet     = false

    private struct ImportAlertState: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    var body: some View {
        Form {
                // ── Language ──────────────────────────────────────
                Section {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Text(String(localized: "Language"))
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "arrow.up.forward.app")
                                .foregroundStyle(.secondary)
                                .font(.footnote.weight(.semibold))
                        }
                    }
                } footer: {
                    Text(String(localized: "App language can be changed in the iOS Settings app."))
                }

                // ── Features ─────────────────────────────────────
                Section {
                    Button { showFeaturesSheet = true } label: {
                        HStack {
                            Text(String(localized: "Features"))
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.footnote.weight(.semibold))
                        }
                    }
                }

                // ── Manage ────────────────────────────────────────
                Section {
                    Button { showCategoriesSheet = true } label: {
                        HStack {
                            Text(String(localized: "Manage Categories"))
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.footnote.weight(.semibold))
                        }
                    }
                    Button { showTagsSheet = true } label: {
                        HStack {
                            Text(String(localized: "Manage Tags"))
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.footnote.weight(.semibold))
                        }
                    }
                    Button { showAisleOrderSheet = true } label: {
                        HStack {
                            Text(String(localized: "Aisle Order"))
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.footnote.weight(.semibold))
                        }
                    }
                }

                // ── Legal ────────────────────────────────────────
                Section {
                    Button { showPrivacySheet = true } label: {
                        HStack {
                            Text(String(localized: "Privacy Policy"))
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.footnote.weight(.semibold))
                        }
                    }
                } footer: {
                    // ODbL (Open Food Facts) requires attribution; NEVO/RIVM requests it.
                    Text("\(String(localized: "Data Sources")): \(String(localized: "Nutritional values are based on NEVO (RIVM, the Netherlands). Barcode product data is provided by Open Food Facts and available under the Open Database License (ODbL)."))")
                        .font(.footnote)
                }

                // ── Notifications ────────────────────────────────
                if appSettings.featureStorage {
                    Section(String(localized: "Expiry Notifications")) {
                        DatePicker(
                            String(localized: "Notify at"),
                            selection: Binding(
                                get: {
                                    Calendar.current.date(
                                        bySettingHour: appSettings.notificationHour,
                                        minute: appSettings.notificationMinute,
                                        second: 0,
                                        of: Date()
                                    ) ?? Date()
                                },
                                set: { date in
                                    let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                                    appSettings.notificationHour   = comps.hour   ?? 9
                                    appSettings.notificationMinute = comps.minute ?? 0
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                    }
                }

                // ── Data ─────────────────────────────────────────
                Section(String(localized: "Data")) {
                    Button {
                        exportData()
                    } label: {
                        Label(String(localized: "Export Data…"), systemImage: "square.and.arrow.up")
                    }

                    Button {
                        showImporter = true
                    } label: {
                        Label(String(localized: "Import Data…"), systemImage: "square.and.arrow.down")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(String(localized: "Settings"))
            .navigationTitleDisplayMode(.inline)
            .fileExporter(
                isPresented: $showExporter,
                document: exportFile,
                contentType: .json,
                defaultFilename: "RecipeApp-Export"
            ) { _ in }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.json]
            ) { result in
                handleImport(result: result)
            }
            .alert(item: $importAlert) { state in
                Alert(title: Text(state.title), message: Text(state.message))
            }
            .sheet(isPresented: $showConflictSheet) {
                ConflictResolutionView(
                    conflicts: $pendingConflicts
                ) { resolved in
                    for conflict in resolved where conflict.useImported {
                        conflict.applyImported()
                    }
                    showConflictSheet = false
                }
            }
            .sheet(isPresented: $showFeaturesSheet) {
                NavigationStack {
                    FeaturesView()
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button(String(localized: "Done")) { showFeaturesSheet = false }
                            }
                        }
                }
                .environment(appSettings)
            }
            .sheet(isPresented: $showCategoriesSheet) {
                NavigationStack {
                    CategoryManagementView()
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button(String(localized: "Done")) { showCategoriesSheet = false }
                            }
                        }
                }
                .environment(appSettings)
            }
            .sheet(isPresented: $showTagsSheet) {
                NavigationStack {
                    TagManagementView()
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button(String(localized: "Done")) { showTagsSheet = false }
                            }
                        }
                }
                .environment(appSettings)
            }
            .sheet(isPresented: $showAisleOrderSheet) {
                NavigationStack {
                    AisleOrderView()
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button(String(localized: "Done")) { showAisleOrderSheet = false }
                            }
                        }
                }
                .environment(appSettings)
            }
            .sheet(isPresented: $showPrivacySheet) {
                NavigationStack {
                    PrivacyPolicyView()
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button(String(localized: "Done")) { showPrivacySheet = false }
                            }
                        }
                }
            }
    }

    // MARK: - Actions

    private func exportData() {
        let container = modelContext.container
        Task {
            do {
                // Fetching and base64-encoding photos can be heavy with large
                // libraries — run it on a background context off the main thread.
                let data = try await Task.detached(priority: .userInitiated) {
                    let backgroundContext = ModelContext(container)
                    return try DataExportService.export(from: backgroundContext)
                }.value
                exportFile = JSONFile(data: data)
                showExporter = true
            } catch {
                importAlert = ImportAlertState(
                    title: String(localized: "Export Failed"),
                    message: error.localizedDescription
                )
            }
        }
    }

    private func handleImport(result: Result<URL, Error>) {
        Task {
            do {
                let url = try result.get()
                guard url.startAccessingSecurityScopedResource() else { return }
                // Read file bytes off the main thread to avoid blocking the UI.
                let data = try await Task.detached(priority: .userInitiated) {
                    defer { url.stopAccessingSecurityScopedResource() }
                    return try Data(contentsOf: url)
                }.value
                // ModelContext mutations must stay on the main actor.
                let outcome = try DataExportService.import(from: data, into: modelContext)
                if outcome.conflicts.isEmpty {
                    importAlert = ImportAlertState(
                        title: String(localized: "Import Complete"),
                        message: outcome.result.summary()
                    )
                } else {
                    pendingConflicts = outcome.conflicts
                    showConflictSheet = true
                }
            } catch {
                importAlert = ImportAlertState(
                    title: String(localized: "Import Failed"),
                    message: error.localizedDescription
                )
            }
        }
    }
}

// MARK: - Conflict resolution sheet

private struct ConflictResolutionView: View {

    @Binding var conflicts: [ImportConflict]
    let onApply: ([ImportConflict]) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(String(localized: "\(conflicts.count) items differ from your existing data."))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                ForEach($conflicts) { $conflict in
                    ConflictRowView(conflict: $conflict)
                }
            }
            .navigationTitle(String(localized: "Import Conflicts"))
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Apply")) { onApply(conflicts) }
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { onApply([]) }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 480, minHeight: 360)
        #endif
    }
}

private struct ConflictRowView: View {

    @Binding var conflict: ImportConflict

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("\(conflict.kind) · \(conflict.name)", systemImage: icon(for: conflict.kind))
                .font(.headline)

            HStack(alignment: .top, spacing: 12) {
                detailBox(label: String(localized: "Existing"),
                          text: conflict.existingDetail,
                          highlighted: !conflict.useImported)
                detailBox(label: String(localized: "Imported"),
                          text: conflict.importedDetail,
                          highlighted: conflict.useImported)
            }

            Picker("", selection: $conflict.useImported) {
                Text(String(localized: "Keep Existing")).tag(false)
                Text(String(localized: "Use Imported")).tag(true)
            }
            .pickerStyle(.segmented)
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private func detailBox(label: String, text: String, highlighted: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(text)
                .font(.subheadline)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(highlighted ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(highlighted ? Color.accentColor.opacity(0.4) : Color.clear, lineWidth: 1)
                )
        }
        .frame(maxWidth: .infinity)
    }

    private func icon(for kind: String) -> String {
        switch kind {
        case "Ingredient": return "carrot"
        case "Recipe":     return "fork.knife"
        case "Tag":        return "tag"
        default:           return "questionmark.circle"
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppSettings())
        .modelContainer(for: [RecipeCategory.self, RecipeTag.self, Recipe.self], inMemory: true)
}
