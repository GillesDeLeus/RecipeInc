import Testing
@testable import BRecipe

// MARK: - RecipeFilter

struct RecipeFilterTests {

    @Test func isInactiveByDefault() {
        #expect(!RecipeFilter().isActive)
    }

    @Test func favoritesOnlyMakesActive() {
        var f = RecipeFilter()
        f.favoritesOnly = true
        #expect(f.isActive)
    }

    @Test func minRatingMakesActive() {
        var f = RecipeFilter()
        f.minRating = 1
        #expect(f.isActive)
    }

    @Test func stockModeMakesActive() {
        var f = RecipeFilter()
        f.stockMode = .canCook
        #expect(f.isActive)
        f.stockMode = .almostCanCook
        #expect(f.isActive)
    }

    @Test func narrowMinMinutesMakesActive() {
        var f = RecipeFilter()
        f.minMinutes = 15
        #expect(f.isActive)
    }

    @Test func narrowMaxMinutesMakesActive() {
        var f = RecipeFilter()
        f.maxMinutes = 60
        #expect(f.isActive)
    }

    @Test func defaultMaxMinutesIsNotActive() {
        var f = RecipeFilter()
        f.maxMinutes = 240
        #expect(!f.isActive)
    }

    @Test func resetRestoresInactiveState() {
        var f = RecipeFilter()
        f.favoritesOnly = true
        f.minRating = 3
        f.stockMode = .canCook
        f.minMinutes = 30
        f.reset()
        #expect(!f.isActive)
    }

    @Test func resetResetsAllFields() {
        var f = RecipeFilter()
        f.favoritesOnly = true
        f.minRating = 4
        f.maxMinutes = 45
        f.stockMode = .almostCanCook
        f.reset()
        #expect(!f.favoritesOnly)
        #expect(f.minRating == 0)
        #expect(f.maxMinutes == 240)
        #expect(f.stockMode == .all)
    }
}

// MARK: - StorageFilter

struct StorageFilterTests {

    @Test func isInactiveByDefault() {
        #expect(!StorageFilter().isActive)
    }

    @Test func locationSetMakesActive() {
        var f = StorageFilter()
        f.locations = [.freezer]
        #expect(f.isActive)
    }

    @Test func categorySetMakesActive() {
        var f = StorageFilter()
        f.categories = [.dairy]
        #expect(f.isActive)
    }

    @Test func expiringSoonMakesActive() {
        var f = StorageFilter()
        f.expiringSoon = true
        #expect(f.isActive)
    }

    @Test func expiredMakesActive() {
        var f = StorageFilter()
        f.expired = true
        #expect(f.isActive)
    }

    @Test func resetRestoresInactiveState() {
        var f = StorageFilter()
        f.expiringSoon = true
        f.locations = [.refrigerator]
        f.categories = [.produce]
        f.reset()
        #expect(!f.isActive)
        #expect(f.locations.isEmpty)
        #expect(f.categories.isEmpty)
    }
}
