import SwiftUI
import SwiftData
import TipKit

struct StorageListView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \StorageItem.createdAt) private var items: [StorageItem]

    private let addStorageTip = AddStorageTip()

    @State private var vm = StorageListViewModel()


    private var filtered: [StorageItem] { vm.filtered(items: items) }

    // MARK: - Body

    var body: some View {
        @Bindable var vm = vm
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
                            Label(String(localized: "Filter"), systemImage: "line.3.horizontal.decrease.circle")
                        } description: {
                            Text(String(localized: "No recipe ingredients for the selected meals."))
                        }
                    } else if vm.sortOrder == .byLocation && !vm.isFiltering && vm.searchText.isEmpty {
                        groupedList
                    } else {
                        flatList
                    }
                }
            }
            .navigationTitle(String(localized: "Storage"))
            .searchable(text: $vm.searchText, prompt: String(localized: "Search storage…"))
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Menu {
                        ForEach(StorageSortOrder.allCases, id: \.self) { order in
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

                    Button { vm.showFilterSheet = true } label: {
                        Label(String(localized: "Filter"), systemImage: vm.isFiltering
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                    }

                    Button { vm.showAddSheet = true } label: {
                        Label(String(localized: "Add"), systemImage: "plus")
                    }
                }
            }
            .sheet(item: $vm.itemToEdit) { item in
                StorageFormView(item: item)
            }
        }
        .sheet(isPresented: $vm.showAddSheet) {
            StorageFormView()
        }
        .sheet(isPresented: $vm.showFilterSheet) {
            StorageFilterView(filter: $vm.filter)
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
                                .onTapGesture { vm.itemToEdit = item }
                        }
                        .onDelete { offsets in vm.delete(from: locationItems, at: offsets, in: modelContext) }
                    } header: {
                        Label(location.localizedName, systemImage: location.icon)
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
                    .onTapGesture { vm.itemToEdit = item }
            }
            .onDelete { offsets in vm.delete(from: filtered, at: offsets, in: modelContext) }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(String(localized: "No Storage Items"), systemImage: "cart")
        } description: {
            Text(String(localized: "Add ingredients you have at home."))
        } actions: {
            Button(String(localized: "Add")) { vm.showAddSheet = true }
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Helpers

    private func sortLabel(for order: StorageSortOrder) -> String {
        switch order {
        case .byLocation:    return String(localized: "Location")
        case .nameAsc:       return String(localized: "Name A–Z")
        case .nameDesc:      return String(localized: "Name Z–A")
        case .expirySoonest: return String(localized: "Expiry (soonest first)")
        }
    }
}

// MARK: - Row

private struct StorageRowView: View {

    @Environment(AppSettings.self) private var appSettings
    let item: StorageItem


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
        case ..<0:  return String(localized: "Expired")
        case 0:     return String(localized: "Expires today")
        case 1:     return String(localized: "Expires tomorrow")
        case 2...7: return String(localized: "Expires in \(days) days")
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
    @Binding var filter: StorageFilter


    var body: some View {
        NavigationStack {
            Form {
                // ── Expiry ────────────────────────────────────────
                Section(String(localized: "Expiry Date")) {
                    Toggle(String(localized: "Expiring within 7 days"), isOn: $filter.expiringSoon)
                        .onChange(of: filter.expiringSoon) { _, on in if on { filter.expired = false } }
                    Toggle(String(localized: "Show expired items"), isOn: $filter.expired)
                        .onChange(of: filter.expired) { _, on in if on { filter.expiringSoon = false } }
                }

                // ── Location ──────────────────────────────────────
                Section(String(localized: "Location")) {
                    ForEach(StorageLocation.allCases, id: \.self) { location in
                        Button {
                            if filter.locations.contains(location) {
                                filter.locations.remove(location)
                            } else {
                                filter.locations.insert(location)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: location.icon)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20)
                                Text(location.localizedName)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if filter.locations.contains(location) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                    }
                }

                // ── Category ──────────────────────────────────────
                Section(String(localized: "Category")) {
                    ForEach(ShoppingCategory.allCases) { category in
                        Button {
                            if filter.categories.contains(category) {
                                filter.categories.remove(category)
                            } else {
                                filter.categories.insert(category)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: category.icon)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20)
                                Text(category.localizedName)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if filter.categories.contains(category) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(String(localized: "Filter"))
            .navigationTitleDisplayMode(.inline)
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
}

#Preview {
    StorageListView()
        .environment(AppSettings())
        .modelContainer(for: [StorageItem.self, Ingredient.self], inMemory: true)
}
