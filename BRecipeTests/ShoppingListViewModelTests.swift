import Testing
import SwiftData
@testable import BRecipe

@MainActor
struct ShoppingListViewModelTests {

    private func vm() -> ShoppingListViewModel { ShoppingListViewModel() }

    // MARK: - formattedItem

    @Test func formattedItemWholeAmount() throws {
        let c = try makeTestContainer()
        let item = ShoppingListItem(name: "Boter", unit: "g", amount: 200, category: .dairy)
        c.mainContext.insert(item)

        #expect(vm().formattedItem(item) == "200 g Boter")
    }

    @Test func formattedItemDecimalAmount() throws {
        let c = try makeTestContainer()
        let item = ShoppingListItem(name: "Suiker", unit: "kg", amount: 1.5, category: .pantry)
        c.mainContext.insert(item)

        #expect(vm().formattedItem(item) == "1.5 kg Suiker")
    }

    @Test func formattedItemNoUnit() throws {
        let c = try makeTestContainer()
        let item = ShoppingListItem(name: "Appel", unit: "", amount: 3, category: .produce)
        c.mainContext.insert(item)

        #expect(vm().formattedItem(item) == "3 Appel")
    }

    @Test func formattedItemSingleItem() throws {
        let c = try makeTestContainer()
        let item = ShoppingListItem(name: "Ei", unit: "", amount: 1, category: .dairy)
        c.mainContext.insert(item)

        #expect(vm().formattedItem(item) == "1 Ei")
    }

    // MARK: - groupedItems

    @Test func groupedItemsRespectAisleOrder() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let dairy   = ShoppingListItem(name: "Melk",   unit: "l", amount: 1,   category: .dairy)
        let produce = ShoppingListItem(name: "Wortel", unit: "g", amount: 200, category: .produce)
        ctx.insert(dairy); ctx.insert(produce)

        let order: [ShoppingCategory] = [.produce, .dairy]
        let groups = vm().groupedItems(from: [dairy, produce], aisleOrder: order)

        #expect(groups.count == 2)
        #expect(groups[0].0 == .produce)
        #expect(groups[1].0 == .dairy)
    }

    @Test func groupedItemsSkipsEmptyCategories() throws {
        let c = try makeTestContainer()
        let item = ShoppingListItem(name: "Melk", unit: "l", amount: 1, category: .dairy)
        c.mainContext.insert(item)

        let groups = vm().groupedItems(from: [item],
                                       aisleOrder: [.produce, .dairy, .frozen])

        #expect(groups.count == 1)
        #expect(groups[0].0 == .dairy)
    }

    @Test func groupedItemsEmptyListReturnsEmpty() throws {
        let groups = vm().groupedItems(from: [], aisleOrder: ShoppingCategory.allCases)
        #expect(groups.isEmpty)
    }

    @Test func groupedItemsSortedAlphabeticallyWithinCategory() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let broccoli = ShoppingListItem(name: "Broccoli", unit: "g", amount: 200, category: .produce)
        let appel    = ShoppingListItem(name: "Appel",    unit: "",  amount: 2,   category: .produce)
        ctx.insert(broccoli); ctx.insert(appel)

        let groups = vm().groupedItems(from: [broccoli, appel], aisleOrder: [.produce])

        #expect(groups.count == 1)
        #expect(groups[0].1.map(\.name) == ["Appel", "Broccoli"])
    }

    @Test func groupedItemsMultipleCategoriesEachContainsCorrectItems() throws {
        let c = try makeTestContainer()
        let ctx = c.mainContext
        let dairy1 = ShoppingListItem(name: "Melk",  unit: "l", amount: 1, category: .dairy)
        let dairy2 = ShoppingListItem(name: "Boter", unit: "g", amount: 200, category: .dairy)
        let frozen = ShoppingListItem(name: "Ijs",   unit: "g", amount: 500, category: .frozen)
        ctx.insert(dairy1); ctx.insert(dairy2); ctx.insert(frozen)

        let groups = vm().groupedItems(from: [dairy1, dairy2, frozen],
                                       aisleOrder: [.dairy, .frozen])

        #expect(groups.count == 2)
        #expect(groups[0].0 == .dairy)
        #expect(groups[0].1.count == 2)
        #expect(groups[1].0 == .frozen)
        #expect(groups[1].1.count == 1)
    }

    @Test func groupedItemsOrderIgnoredCategoryNotIncluded() throws {
        let c = try makeTestContainer()
        let item = ShoppingListItem(name: "Melk", unit: "l", amount: 1, category: .dairy)
        c.mainContext.insert(item)

        // Dairy not in aisleOrder → should not appear
        let groups = vm().groupedItems(from: [item], aisleOrder: [.produce, .frozen])
        #expect(groups.isEmpty)
    }
}
