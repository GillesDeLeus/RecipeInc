import SwiftUI
import SwiftData

// MARK: - Category management

struct CategoryManagementView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \RecipeCategory.name) private var categories: [RecipeCategory]

    @State private var showAddAlert = false
    @State private var newName = ""


    var body: some View {
        List {
            ForEach(categories) { cat in
                HStack {
                    Text(cat.name)
                    Spacer()
                    if !cat.isCustom {
                        Text(String(localized: "Standard"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { offsets in
                for idx in offsets {
                    modelContext.delete(categories[idx])
                }
            }
        }
        .navigationTitle(String(localized: "Manage Categories"))
        .navigationTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showAddAlert = true } label: {
                    Label(String(localized: "Add"), systemImage: "plus")
                }
            }
        }
        .alert(String(localized: "New Category"), isPresented: $showAddAlert) {
            TextField(String(localized: "Category name"), text: $newName)
            Button(String(localized: "Add")) {
                let trimmed = newName.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    modelContext.insert(RecipeCategory(name: trimmed, isCustom: true))
                }
                newName = ""
            }
            Button(String(localized: "Cancel"), role: .cancel) { newName = "" }
        }
    }
}

// MARK: - Tag management

struct TagManagementView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \RecipeTag.name) private var tags: [RecipeTag]

    @State private var showAddSheet = false


    var body: some View {
        List {
            ForEach(tags) { tag in
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color(hex: tag.colorHex))
                        .frame(width: 12, height: 12)
                    Text(tag.name)
                    Spacer()
                    if !tag.isCustom {
                        Text(String(localized: "Standard"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { offsets in
                for idx in offsets {
                    modelContext.delete(tags[idx])
                }
            }
        }
        .navigationTitle(String(localized: "Manage Tags"))
        .navigationTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showAddSheet = true } label: {
                    Label(String(localized: "Add"), systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddTagSheet()
        }
    }
}

// MARK: - Add tag sheet

private struct AddTagSheet: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings

    @State private var name = ""
    @State private var selectedColor = RecipeTag.presetColors[5]


    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Name")) {
                    TextField(String(localized: "Tag name"), text: $name)
                }
                Section(String(localized: "Color")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(RecipeTag.presetColors, id: \.self) { hex in
                            Button {
                                selectedColor = hex
                            } label: {
                                ZStack {
                                    Circle().fill(Color(hex: hex)).frame(width: 36, height: 36)
                                    if selectedColor == hex {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .font(.caption.bold())
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
            .navigationTitle(String(localized: "New Tag"))
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Add")) {
                        let trimmed = name.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            modelContext.insert(RecipeTag(name: trimmed, colorHex: selectedColor, isCustom: true))
                        }
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    CategoryManagementView()
        .environment(AppSettings())
        .modelContainer(for: [RecipeCategory.self, Recipe.self], inMemory: true)
}
