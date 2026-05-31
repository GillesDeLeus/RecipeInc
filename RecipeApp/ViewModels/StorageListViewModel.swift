import Foundation
import SwiftData
import Observation

// MARK: - Enum (moved from StorageListView)

enum StorageSortOrder: String, CaseIterable {
    case byLocation
    case nameAsc
    case nameDesc
    case expirySoonest
}

// MARK: - Filter state

struct StorageFilter {
    var locations: Set<StorageLocation> = []
    var categories: Set<ShoppingCategory> = []
    var expiringSoon = false
    var expired = false

    var isActive: Bool {
        !locations.isEmpty || !categories.isEmpty || expiringSoon || expired
    }

    mutating func reset() { self = StorageFilter() }
}

// MARK: - ViewModel

@Observable
final class StorageListViewModel {

    // MARK: UI State
    var searchText = ""
    var showAddSheet = false
    var itemToEdit: StorageItem?
    var sortOrder: StorageSortOrder = .byLocation
    var filter = StorageFilter()
    var showFilterSheet = false

    var isFiltering: Bool { filter.isActive }

    // MARK: - Pure helpers

    func filtered(items: [StorageItem]) -> [StorageItem] {
        let today = Calendar.current.startOfDay(for: Date())
        let in7Days = Calendar.current.date(byAdding: .day, value: 7, to: today)!

        var result = items.filter { item in
            if !searchText.isEmpty {
                let name = item.ingredient?.name ?? ""
                if !name.localizedCaseInsensitiveContains(searchText) { return false }
            }
            if !filter.locations.isEmpty, !filter.locations.contains(item.location) { return false }
            if !filter.categories.isEmpty {
                guard let cat = item.ingredient?.shoppingCategory,
                      filter.categories.contains(cat) else { return false }
            }
            if filter.expiringSoon {
                guard let expiry = item.expiryDate,
                      expiry >= today, expiry <= in7Days else { return false }
            }
            if filter.expired {
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

    // MARK: - Mutations

    func delete(from source: [StorageItem], at offsets: IndexSet, in context: ModelContext) {
        for idx in offsets {
            let item = source[idx]
            NotificationManager.shared.cancelNotifications(for: item)
            context.delete(item)
        }
    }
}
