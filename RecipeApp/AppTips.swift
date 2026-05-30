import TipKit

struct AddRecipeTip: Tip {
    var title: Text { Text("Add Your First Recipe") }
    var message: Text? { Text("Tap + to create a recipe manually or import one from a URL.") }
    var image: Image? { Image(systemName: "fork.knife") }
}

struct FilterRecipeTip: Tip {
    var title: Text { Text("Filter & Sort Recipes") }
    var message: Text? { Text("Filter by prep time, ingredients, tags, or show only what you can cook with items in storage.") }
    var image: Image? { Image(systemName: "line.3.horizontal.decrease.circle") }
}

struct CookModeTip: Tip {
    var title: Text { Text("Cook Mode") }
    var message: Text? { Text("Step-by-step guided view that keeps your screen on while you cook.") }
    var image: Image? { Image(systemName: "flame") }
}

struct AddIngredientTip: Tip {
    var title: Text { Text("Build Your Ingredient Library") }
    var message: Text? { Text("Tap + to add an ingredient. Nutrition values are looked up automatically from the NEVO database.") }
    var image: Image? { Image(systemName: "carrot") }
}

struct AddMealPlanTip: Tip {
    var title: Text { Text("Plan Your Meals") }
    var message: Text? { Text("Tap + to schedule a recipe on any day. The calendar shows your full week at a glance.") }
    var image: Image? { Image(systemName: "calendar") }
}

struct ShoppingListTip: Tip {
    var title: Text { Text("Generate a Shopping List") }
    var message: Text? { Text("Tap the circle icon to select days, then tap the cart to get a shopping list for those meals.") }
    var image: Image? { Image(systemName: "cart") }
}

struct AddStorageTip: Tip {
    var title: Text { Text("Track Your Pantry") }
    var message: Text? { Text("Log what's in your fridge and cupboards. Recipes will show which ones you can cook right now.") }
    var image: Image? { Image(systemName: "archivebox") }
}
