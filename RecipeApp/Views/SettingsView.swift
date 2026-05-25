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

    private struct ImportAlertState: Identifiable {
        let id = UUID()
        let title: String
        let message: String
    }

    var body: some View {
        @Bindable var settings = appSettings
        let lang = appSettings.language

        NavigationStack {
            Form {
                // ── Language ──────────────────────────────────────
                Section(lang.languageLabel) {
                    Picker(lang.languageLabel, selection: $settings.language) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }

                // ── Features ─────────────────────────────────────
                Section {
                    NavigationLink(lang.featuresTitle) {
                        FeaturesView()
                    }
                }

                // ── Manage ────────────────────────────────────────
                Section {
                    NavigationLink(lang.manageCategories) {
                        CategoryManagementView()
                    }
                    NavigationLink(lang.manageTags) {
                        TagManagementView()
                    }
                }

                // ── Legal ────────────────────────────────────────
                Section {
                    NavigationLink(lang.privacyPolicy) {
                        PrivacyPolicyView()
                    }
                }

                // ── Notifications ────────────────────────────────
                if appSettings.featureStorage {
                    Section(lang.notificationTimeSection) {
                        DatePicker(
                            lang.notificationTimeLabel,
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
                Section(lang.dataLabel) {
                    Button {
                        exportData(lang: lang)
                    } label: {
                        Label(lang.exportData, systemImage: "square.and.arrow.up")
                    }

                    Button {
                        showImporter = true
                    } label: {
                        Label(lang.importData, systemImage: "square.and.arrow.down")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(lang.settingsTitle)
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
                handleImport(result: result, lang: lang)
            }
            .alert(item: $importAlert) { state in
                Alert(title: Text(state.title), message: Text(state.message))
            }
            .sheet(isPresented: $showConflictSheet) {
                ConflictResolutionView(
                    conflicts: $pendingConflicts,
                    lang: appSettings.language
                ) { resolved in
                    for conflict in resolved where conflict.useImported {
                        conflict.applyImported()
                    }
                    showConflictSheet = false
                }
            }
        }
    }

    // MARK: - Actions

    private func exportData(lang: AppLanguage) {
        do {
            let data = try DataExportService.export(from: modelContext)
            exportFile = JSONFile(data: data)
            showExporter = true
        } catch {
            importAlert = ImportAlertState(
                title: lang.exportFailedTitle,
                message: error.localizedDescription
            )
        }
    }

    private func handleImport(result: Result<URL, Error>, lang: AppLanguage) {
        do {
            let url = try result.get()
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }

            let data = try Data(contentsOf: url)
            let outcome = try DataExportService.import(from: data, into: modelContext)

            if outcome.conflicts.isEmpty {
                importAlert = ImportAlertState(
                    title: lang.importSuccessTitle,
                    message: outcome.result.summary(in: lang)
                )
            } else {
                pendingConflicts = outcome.conflicts
                showConflictSheet = true
            }
        } catch {
            importAlert = ImportAlertState(
                title: lang.importFailedTitle,
                message: error.localizedDescription
            )
        }
    }
}

// MARK: - Conflict resolution sheet

private struct ConflictResolutionView: View {

    @Binding var conflicts: [ImportConflict]
    let lang: AppLanguage
    let onApply: ([ImportConflict]) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(lang.conflictSubtitle(conflicts.count))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                ForEach($conflicts) { $conflict in
                    ConflictRowView(conflict: $conflict, lang: lang)
                }
            }
            .navigationTitle(lang.resolveConflictsTitle)
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.applyConflictsAction) { onApply(conflicts) }
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.cancel) { onApply([]) }
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
    let lang: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("\(conflict.kind) · \(conflict.name)", systemImage: icon(for: conflict.kind))
                .font(.headline)

            HStack(alignment: .top, spacing: 12) {
                detailBox(label: lang.conflictExistingLabel,
                          text: conflict.existingDetail,
                          highlighted: !conflict.useImported)
                detailBox(label: lang.conflictImportedLabel,
                          text: conflict.importedDetail,
                          highlighted: conflict.useImported)
            }

            Picker("", selection: $conflict.useImported) {
                Text(lang.keepExistingAction).tag(false)
                Text(lang.useImportedAction).tag(true)
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
