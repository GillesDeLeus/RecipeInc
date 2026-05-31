# BRecipe

A native iOS recipe manager built entirely with SwiftUI and SwiftData. BRecipe keeps your recipes, ingredients, meal plans, shopping list, and pantry in one place — all stored on-device with no account required.

---

## Features

### Core (always available)

| Feature | Description |
|---|---|
| **Recipe library** | Create, browse, filter, and favorite recipes. Search by name, filter by category, tag, rating, or preparation time. Sort by name, date, or rating. |
| **Cook mode** | Distraction-free, step-by-step cooking view with screen keep-awake, VoiceOver navigation, and swipe gestures between steps. |
| **Recipe import** | Import recipes from any URL via JSON-LD structured data. |
| **Ingredient database** | Shared ingredient list with unit, shopping category, and optional NEVO nutritional values (calories, protein, fat, carbs, fiber, and more). |
| **Data export / import** | Full JSON export and import of all app data. Conflict-resolution UI handles duplicate recipes, ingredients, and tags on import. |
| **Localization** | English and Dutch (Nederlands) — switchable in Settings without restarting the app. |

### Optional features (toggled in Settings → Features)

| Feature | Description |
|---|---|
| **Shopping list** | Persistent shopping list grouped by aisle/category. Checked items stay visible until manually cleared. Badge shows unchecked count on the tab. |
| **Pantry / Storage** | Track food stock across Freezer, Refrigerator, and Food Closet. Includes barcode scanning to look up ingredient names and expiry-date push notifications. |
| **Meal calendar** | Plan meals by day and meal type (Breakfast, Lunch, Dinner, Snack). Link a recipe or enter a free-form name. Generate a shopping list directly from a week's meal plan. |
| **AI recipe import** | On-device AI via Apple's FoundationModels framework. Point the camera at a handwritten or printed recipe and the app extracts name, prep time, and ingredients automatically. |
| **Nutrition tracking** | Per-recipe macro and micro nutrient summary calculated from the NEVO database. Scales automatically to the number of portions. |

---

## Architecture

```
RecipeApp/
├── RecipeApp/
│   ├── Models/           # SwiftData @Model classes
│   ├── ViewModels/       # @Observable view models
│   ├── Views/
│   │   ├── Recipe/
│   │   ├── Ingredient/
│   │   ├── Calendar/
│   │   ├── Shopping/
│   │   └── Storage/
│   ├── BarcodeService.swift
│   ├── DataExportService.swift
│   ├── NotificationManager.swift
│   ├── NutritionService.swift
│   ├── NutritionCalculator.swift
│   ├── NevoData.swift            # Bundled NEVO nutritional database
│   ├── NevoSupplementData.swift
│   └── RecipeImportService.swift
└── BRecipeTests/         # Unit test target
```

### Key design decisions

- **SwiftData** — single `ModelContainer` shared across the app via `@Environment(\.modelContext)`. All queries use `@Query` or `FetchDescriptor` with `#Predicate` for efficient on-device filtering.
- **`@Observable` ViewModels** — business logic and filtering extracted from views into testable `@Observable` classes (`RecipeListViewModel`, `RecipeDetailViewModel`, `IngredientListViewModel`, `ShoppingListViewModel`, `StorageListViewModel`).
- **`AppSettings`** — `@Observable` class persisted in `UserDefaults`. Holds language, feature flags, notification time, and aisle order. Injected app-wide via `@Environment`.
- **`AppLanguage`** — custom localization enum (`.english` / `.dutch`) with a `.t("en", "nl")` helper. All user-facing strings go through this; no `.strings` file required.
- **Services** — stateless `enum` namespaces (`DataExportService`, `NutritionService`) or `actor`/`class` singletons (`BarcodeService`, `NotificationManager`). All use `OSLog` for structured logging.

---

## Data model

```
Recipe ──< RecipeIngredient >── Ingredient
  │                                 │
  ├──< RecipePhoto              ShoppingCategory (enum)
  ├── RecipeCategory?
  └──> RecipeTag (many-to-many)

MealPlan ──> Recipe?

StorageItem ──> Ingredient?

ShoppingListItem (standalone)
```

### Models at a glance

| Model | Key fields |
|---|---|
| `Recipe` | name, instructions, prepTimeMinutes, isFavorite, rating (0–5), createdAt |
| `Ingredient` | name, unit, shoppingCategory, 13 NEVO nutritional fields (all optional) |
| `RecipeIngredient` | amount (Double) — join between Recipe and Ingredient |
| `RecipePhoto` | imageData (Data), sortOrder |
| `RecipeCategory` | name, isCustom |
| `RecipeTag` | name, colorHex, isCustom |
| `MealPlan` | date, mealType (breakfast/lunch/dinner/snack/other), portions, notes, recipe? |
| `StorageItem` | ingredient, amount, location (freezer/refrigerator/foodCloset), expiryDate?, notificationToken |
| `ShoppingListItem` | name, amount, unit, aisle, isChecked |

---

## Requirements

- **Xcode 16+**
- **iOS 18+** (uses SwiftData, `@Observable`, TipKit, FoundationModels)
- No third-party dependencies — pure Apple frameworks only

### Frameworks used

| Framework | Purpose |
|---|---|
| SwiftUI | All UI |
| SwiftData | On-device persistence |
| Foundation / Observation | `@Observable`, `UserDefaults`, JSON |
| TipKit | Contextual onboarding tips |
| Vision | OCR for camera-based recipe import |
| FoundationModels | On-device LLM for AI recipe parsing |
| UserNotifications | Expiry-date reminders |
| OSLog | Structured logging |

### Entitlements

| Entitlement | Reason |
|---|---|
| App Sandbox | Standard macOS/iOS sandboxing |
| Network client | Barcode lookup API, recipe URL import |
| User-selected file read/write | JSON export/import via Files |

---

## Getting started

1. Clone the repository and open `RecipeApp/RecipeApp.xcodeproj` in Xcode.
2. Select the **BRecipe** scheme and a simulator or device running iOS 18+.
3. Build and run (`⌘R`). No configuration or API keys are required.

On first launch the app seeds 10 default recipe categories (Breakfast, Lunch, Dinner, …) and 10 default tags (Quick, Vegetarian, Vegan, …).

---

## Running tests

Select the **BRecipeTests** scheme and press `⌘U`. The test suite uses the Swift **Testing** framework (no XCTest).

| Test file | What it covers |
|---|---|
| `RecipeFilterTests` | `RecipeFilter` and `StorageFilter` struct logic — search, category, tag, rating, and sort order |
| `NutritionServiceTests` | NEVO fuzzy matching, `normalize()`, `topMatches()`, and `lookup()` |
| `RecipeListViewModelTests` | `inStockIDs`, `missingCount`, `filtered()` across all filter/sort combinations |
| `IngredientListViewModelTests` | Search, category filter, and all three sort orders |
| `ShoppingListViewModelTests` | `formattedItem()` and `groupedItems()` output |

All SwiftData tests run against an in-memory `ModelContainer` for full isolation.

---

## Settings overview

| Setting | Description |
|---|---|
| Language | English / Nederlands |
| Features | Per-feature on/off toggles |
| Categories | Add, rename, delete recipe categories |
| Tags | Add, rename, recolour, delete tags |
| Aisle order | Drag to reorder shopping aisles |
| Notification time | Daily time for expiry-date reminders (visible when Storage is enabled) |
| Export data | Saves all data to a JSON file |
| Import data | Restores data from a previously exported JSON file |

---

## Privacy

All data is stored exclusively on-device using SwiftData. The app makes outbound network requests only for:

- **Barcode lookup** — product name from a public barcode API when adding a storage item
- **Recipe URL import** — fetching the HTML of a URL you paste in the import screen

No analytics, no accounts, no cloud sync.
