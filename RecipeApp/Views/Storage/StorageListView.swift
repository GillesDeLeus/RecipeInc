import SwiftUI
import SwiftData
import TipKit

enum StorageSortOrder: String, CaseIterable {
    case byLocation   // default grouped view
    case nameAsc
    case nameDesc
    case expirySoonest
}

struct StorageListView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \StorageItem.createdAt) private var items: [StorageItem]

    private let addStorageTip = AddStorageTip()

    @State private var showAddSheet = false
    @State private var itemToEdit: StorageItem?
    @State private var searchText = ""
    @State private var sortOrder: StorageSortOrder = .byLocation
    @State private var filterLocations: Set<StorageLocation> = []
    @State private var filterCategories: Set<ShoppingCategory> = []
    @State private var filterExpiringSoon = false
    @State private var filterExpired = false
    @State private var showFilterSheet = false

    private var lang: AppLanguage { appSettings.language }

    private var isFiltering: Bool {
        !filterLocations.isEmpty || !filterCategories.isEmpty
            || filterExpiringSoon || filterExpired
    }

    // MARK: - Filtered + sorted items

    private var filtered: [StorageItem] {
        let today = Calendar.current.startOfDay(for: Date())
        let in7Days = Calendar.current.date(byAdding: .day, value: 7, to: today)!

        var result = items.filter { item in
            if !searchText.isEmpty {
                let name = item.ingredient?.name ?? ""
                if !name.localizedCaseInsensitiveContains(searchText) { return false }
            }
            if !filterLocations.isEmpty, !filterLocations.contains(item.location) { return false }
            if !filterCategories.isEmpty {
                guard let cat = item.ingredient?.shoppingCategory,
                      filterCategories.contains(cat) else { return false }
            }
            if filterExpiringSoon {
                guard let expiry = item.expiryDate,
                      expiry >= today, expiry <= in7Days else { return false }
            }
            if filterExpired {
                guard let expiry = item.expiryDate, expiry < today else { return false }
            }
            return true
        }

        switch sortOrder {
        case .byLocation:
            result.sort {
                let locOrder = StorageLocation.allCases
                let li = locOrder.firstIndex(of: $0.location) ?? 0
                let ri = locOrder.firstIndex(of: $1.location) ?? 0
                if li != ri { return li < ri }
                return ($0.ingredient?.name ?? "").localizedCaseInsensitiveCompare(
                    $1.ingredient?.name ?? "") == .orderedAscending
            }
        case .nameAsc:
            result.sort {
                ($0.ingredient?.name ?? "").localizedCaseInsensitiveCompare(
                    $1.ingredient?.name ?? "") == .orderedAscending
            }
        case .nameDesc:
            result.sort {
                ($0.ingredient?.name ?? "").localizedCaseInsensitiveCompare(
                    $1.ingredient?.name ?? "") == .orderedDescending
            }
        case .expirySoonest:
            result.sort {
                switch ($0.expiryDate, $1.expiryDate) {
                case let (a?, b?): return a < b
                case (_?, nil):    return true
                case (nil, _?):    return false
                default:           return ($0.ingredient?.name ?? "") < ($1.ingredient?.name ?? "")
                }
            }
        }
        return result
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TipView(addStorageTip)
                    .padding(.horizontal)
                    .padding(.top, 4)
                Group {
                    if items.isEmpty {
                        emptyState
                    } else if filtered.isEmpty {
                        ContentUnavailableView {
                            Label(lang.filterTitle, systemImage: "line.3.horizontal.decrease.circle")
                        } description: {
                            Text(lang.noShoppingItemsHint)
                        }
                    } else if sortOrder == .byLocation && !isFiltering && searchText.isEmpty {
                        groupedList
                    } else {
                        flatList
                    }
                }
            }
            .navigationTitle(lang.tabStorage)
            .searchable(text: $searchText, prompt: lang.searchStorage)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu {
                        ForEach(StorageSortOrder.allCases, id: \.self) { order in
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

                    Button { showFilterSheet = true } label: {
                        Label(lang.filterTitle, systemImage: isFiltering
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                    }

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
        .sheet(isPresented: $showFilterSheet) {
            StorageFilterView(
                filterLocations: $filterLocations,
                filterCategories: $filterCategories,
                filterExpiringSoon: $filterExpiringSoon,
                filterExpired: $filterExpired
            )
        }
    }

    // MARK: - Grouped list (default, by location)

    private var groupedList: some View {
        List {
            ForEach(StorageLocation.allCases, id: \.self) { location in
                let locationItems = filtered.filter { $0.location == location }
                if !locationItems.isEmpty {
                    Section {
                        ForEach(locationItems) { item in
                            StorageRowView(item: item)
                                .contentShape(Rectangle())
                                .onTapGesture { itemToEdit = item }
                        }
                        .onDelete { offsets in deleteItems(locationItems, at: offsets) }
                    } header: {
                        Label(location.localizedName(in: lang), systemImage: location.icon)
                    }
                }
            }
        }
    }

    // MARK: - Flat list (when sorted or filtered)

    private var flatList: some View {
        List {
            ForEach(filtered) { item in
                StorageRowView(item: item)
                    .contentShape(Rectangle())
                    .onTapGesture { itemToEdit = item }
            }
            .onDelete { offsets in deleteItems(filtered, at: offsets) }
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

    // MARK: - Helpers

    private func sortLabel(for order: StorageSortOrder) -> String {
        switch order {
        case .byLocation:    return lang.filterByLocation
        case .nameAsc:       return lang.sortByNameAZ
        case .nameDesc:      return lang.sortByNameZA
        case .expirySoonest: return lang.sortByExpiry
        }
    }

    private func deleteItems(_ source: [StorageItem], at offsets: IndexSet) {
        for idx in offsets {
            let item = source[idx]
            NotificationManager.shared.cancelNotifications(for: item)
            modelContext.delete(item)
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

// MARK: - Filter sheet

private struct StorageFilterView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings
    @Binding var filterLocations: Set<StorageLocation>
    @Binding var filterCategories: Set<ShoppingCategory>
    @Binding var filterExpiringSoon: Bool
    @Binding var filterExpired: Bool

    private var lang: AppLanguage { appSettings.language }

    var body: some View {
        NavigationStack {
            Form {
                // ── Expiry ────────────────────────────────────────
                Section(lang.expiryDateSection) {
                    Toggle(lang.filterExpiringSoon, isOn: $filterExpiringSoon)
                        .onChange(of: filterExpiringSoon) { _, on in if on { filterExpired = false } }
                    Toggle(lang.filterExpired, isOn: $filterExpired)
                        .onChange(of: filterExpired) { _, on in if on { filterExpiringSoon = false } }
                }

                // ── Location ──────────────────────────────────────
                Section(lang.filterByLocation) {
                    ForEach(StorageLocation.allCases, id: \.self) { location in
                        Button {
                            if filterLocations.contains(location) {
                                filterLocations.remove(location)
                            } else {
                                filterLocations.insert(location)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: location.icon)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20)
                                Text(location.localizedName(in: lang))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if filterLocations.contains(location) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                    }
                }

                // ── Category ──────────────────────────────────────
                Section(lang.shoppingCategoryLabel) {
                    ForEach(ShoppingCategory.allCases) { category in
                        Button {
                            if filterCategories.contains(category) {
                                filterCategories.remove(category)
                            } else {
                                filterCategories.insert(category)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: category.icon)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20)
                                Text(category.localizedName(in: lang))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if filterCategories.contains(category) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(lang.filterTitle)
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(lang.reset) {
                        filterLocations = []
                        filterCategories = []
                        filterExpiringSoon = false
                        filterExpired = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(lang.done) { dismiss() }
                }
            }
        }
    }
}

#Preview {
    StorageListView()
        .environment(AppSettings())
        .modelContainer(for: [StorageItem.self, Ingredient.self], inMemory: true)
}
