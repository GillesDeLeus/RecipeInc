import SwiftUI
import SwiftData

struct StorageListView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \StorageItem.createdAt) private var items: [StorageItem]

    @State private var showAddSheet = false
    @State private var itemToEdit: StorageItem?

    private var lang: AppLanguage { appSettings.language }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle(lang.tabStorage)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAddSheet = true } label: {
                        Label(lang.addItem, systemImage: "plus")
                    }
                }
            }
            .sheet(item: $itemToEdit) { item in
                StorageFormView(item: item)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            StorageFormView()
        }
    }

    // MARK: - Subviews

    private var list: some View {
        List {
            ForEach(StorageLocation.allCases, id: \.self) { location in
                let locationItems = items.filter { $0.location == location }
                if !locationItems.isEmpty {
                    Section {
                        ForEach(locationItems) { item in
                            StorageRowView(item: item)
                                .contentShape(Rectangle())
                                .onTapGesture { itemToEdit = item }
                        }
                        .onDelete { offsets in
                            for idx in offsets {
                                let item = locationItems[idx]
                                NotificationManager.shared.cancelNotifications(for: item)
                                modelContext.delete(item)
                            }
                        }
                    } header: {
                        Label(location.localizedName(in: lang), systemImage: location.icon)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(lang.noStorageTitle, systemImage: "cart")
        } description: {
            Text(lang.addStorageHint)
        } actions: {
            Button(lang.addItem) { showAddSheet = true }
                .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Row

private struct StorageRowView: View {

    @Environment(AppSettings.self) private var appSettings
    let item: StorageItem

    private var lang: AppLanguage { appSettings.language }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.ingredient?.name ?? "–")
                    .font(.body)
                Text(formattedAmount)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if item.expiryDate != nil {
                Text(expiryLabel)
                    .font(.caption)
                    .foregroundStyle(expiryColor)
            }
        }
        .padding(.vertical, 2)
    }

    private var formattedAmount: String {
        let unit = item.ingredient?.unit ?? ""
        let number = item.amount.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(item.amount))
            : String(format: "%.1f", item.amount)
        return unit.isEmpty ? number : "\(number) \(unit)"
    }

    private var expiryLabel: String {
        guard let expiry = item.expiryDate else { return "" }
        let days = Calendar.current.dateComponents([.day], from: .now, to: expiry).day ?? 0
        switch days {
        case ..<0:  return lang.expired
        case 0:     return lang.expiresToday
        case 1:     return lang.expiresTomorrow
        case 2...7: return lang.expiresInDays(days)
        default:    return expiry.formatted(date: .abbreviated, time: .omitted)
        }
    }

    private var expiryColor: Color {
        guard let expiry = item.expiryDate else { return .secondary }
        let days = Calendar.current.dateComponents([.day], from: .now, to: expiry).day ?? 0
        if days < 0  { return .red }
        if days <= 3 { return .orange }
        if days <= 7 { return .yellow }
        return .secondary
    }
}

#Preview {
    StorageListView()
        .environment(AppSettings())
        .modelContainer(for: [StorageItem.self, Ingredient.self], inMemory: true)
}
