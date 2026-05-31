import Foundation
import Observation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case dutch = "nl"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .dutch:   return "Nederlands"
        }
    }

    func t(_ en: String, _ nl: String) -> String {
        self == .dutch ? nl : en
    }
}

// MARK: - Observable settings (language persisted in UserDefaults)

@Observable
final class AppSettings {
    var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "appLanguage") }
    }
    // Feature flags — default ON on first launch
    var featureStorage: Bool {
        didSet { UserDefaults.standard.set(featureStorage, forKey: "featureStorage") }
    }
    var featureCalendar: Bool {
        didSet { UserDefaults.standard.set(featureCalendar, forKey: "featureCalendar") }
    }
    var featureAIImport: Bool {
        didSet { UserDefaults.standard.set(featureAIImport, forKey: "featureAIImport") }
    }
    var featureNutrition: Bool {
        didSet { UserDefaults.standard.set(featureNutrition, forKey: "featureNutrition") }
    }
    var featureShopping: Bool {
        didSet { UserDefaults.standard.set(featureShopping, forKey: "featureShopping") }
    }
    var notificationHour: Int {
        didSet { UserDefaults.standard.set(notificationHour, forKey: "notificationHour") }
    }
    var notificationMinute: Int {
        didSet { UserDefaults.standard.set(notificationMinute, forKey: "notificationMinute") }
    }
    var aisleOrder: [ShoppingCategory] {
        didSet {
            if let data = try? JSONEncoder().encode(aisleOrder) {
                UserDefaults.standard.set(data, forKey: "aisleOrder")
            }
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        self.language = AppLanguage(rawValue: saved) ?? .english
        // Use object(forKey:) so missing key → nil → default true (not false)
        self.featureStorage   = UserDefaults.standard.object(forKey: "featureStorage")   as? Bool ?? true
        self.featureCalendar  = UserDefaults.standard.object(forKey: "featureCalendar")  as? Bool ?? true
        self.featureAIImport  = UserDefaults.standard.object(forKey: "featureAIImport")  as? Bool ?? true
        self.featureNutrition = UserDefaults.standard.object(forKey: "featureNutrition") as? Bool ?? true
        self.featureShopping  = UserDefaults.standard.object(forKey: "featureShopping")  as? Bool ?? true
        self.notificationHour   = UserDefaults.standard.object(forKey: "notificationHour")   as? Int ?? 9
        self.notificationMinute = UserDefaults.standard.object(forKey: "notificationMinute") as? Int ?? 0
        // Restore saved order; append any categories added in future app updates
        if let data = UserDefaults.standard.data(forKey: "aisleOrder"),
           let order = try? JSONDecoder().decode([ShoppingCategory].self, from: data) {
            let missing = ShoppingCategory.allCases.filter { !order.contains($0) }
            self.aisleOrder = order + missing
        } else {
            self.aisleOrder = ShoppingCategory.allCases
        }
    }
}

// MARK: - All localised strings

extension AppLanguage {

    // Common actions
    var cancel: String      { t("Cancel", "Annuleer") }
    var save: String        { t("Save", "Bewaar") }
    var addItem: String     { t("Add", "Voeg toe") }
    var done: String        { t("Done", "Klaar") }
    var ok: String          { t("OK", "OK") }
    var reset: String       { t("Reset", "Reset") }
    var delete: String      { t("Delete", "Verwijderen") }
    var editAction: String   { t("Edit", "Bewerken") }
    var shareRecipe: String  { t("Share Recipe", "Recept delen") }
    var noLimit: String     { t("No limit", "Geen limiet") }
    var photoLoadErrorTitle: String   { t("Photo Error", "Fotofout") }
    var photoLoadErrorMessage: String { t("One or more photos could not be loaded.", "Één of meerdere foto's konden niet worden geladen.") }

    // Tabs
    var tabRecipes: String      { t("Recipes", "Recepten") }
    var tabIngredients: String  { t("Ingredients", "Ingrediënten") }
    var tabStorage: String      { t("Storage", "Voorraad") }
    var tabCalendar: String     { t("Calendar", "Agenda") }
    var tabSettings: String     { t("Settings", "Instellingen") }

    // Settings
    var settingsTitle: String   { t("Settings", "Instellingen") }
    var languageLabel: String   { t("Language", "Taal") }
    var manageCategories: String { t("Manage Categories", "Categorieën beheren") }
    var manageTags: String      { t("Manage Tags", "Labels beheren") }

    // Recipes – list
    var newRecipe: String       { t("New Recipe", "Nieuw recept") }
    var editRecipe: String      { t("Edit Recipe", "Bewerk recept") }
    var noRecipes: String       { t("No Recipes", "Geen recepten") }
    var addFirstRecipe: String  { t("Add your first recipe with the + button.", "Voeg je eerste recept toe via de + knop.") }
    var addRecipeBtn: String    { t("Add Recipe", "Voeg recept toe") }
    var searchRecipe: String    { t("Search recipe…", "Zoek recept…") }

    // Recipes – form
    var recipeName: String          { t("Recipe Name", "Naam van het recept") }
    var prepTime: String            { t("Preparation Time", "Bereidingstijd") }
    var hoursLabel: String          { t("Hours", "Uren") }
    var minutesLabel: String        { t("Minutes", "Minuten") }
    var ingredientsPerServing: String { t("Ingredients (per serving)", "Ingrediënten (per portie)") }
    var amountsNote: String         { t("Amounts are for 1 serving.", "Hoeveelheden zijn voor 1 portie.") }
    var addIngredient: String       { t("Add Ingredient", "Voeg ingrediënt toe") }
    var preparation: String         { t("Preparation", "Bereiding") }
    var photosLabel: String         { t("Photos", "Foto's") }
    var addPhotos: String           { t("Add Photos", "Voeg foto's toe") }

    // Recipes – detail
    var ingredientsTitle: String    { t("Ingredients", "Ingrediënten") }
    var noIngredientsAdded: String  { t("No ingredients added.", "Geen ingrediënten toegevoegd.") }
    var noPreparation: String       { t("No preparation instructions added.", "Geen bereidingsinstructies toegevoegd.") }
    var deleteRecipeTitle: String   { t("Delete Recipe?", "Recept verwijderen?") }
    var servingsLabel: String       { t("Servings", "Porties") }

    func ingredientCount(_ n: Int) -> String {
        t("\(n) ingredient\(n == 1 ? "" : "s")",
          "\(n) ingrediënt\(n == 1 ? "" : "en")")
    }
    func deleteRecipeMessage(_ name: String) -> String {
        t("\u{201C}\(name)\u{201D} will be permanently deleted.",
          "\u{201C}\(name)\u{201D} wordt permanent verwijderd.")
    }

    // Filter
    var filterTitle: String             { t("Filter", "Filter") }
    var prepTimeRange: String           { t("Preparation Time", "Bereidingstijd") }
    var includedIngredients: String     { t("Included Ingredients", "Ingrediënten aanwezig") }
    var excludedIngredients: String     { t("Excluded Ingredients", "Ingrediënten uitgesloten") }
    var favoritesOnly: String           { t("Favorites only", "Alleen favorieten") }
    var filterByCategory: String        { t("Category", "Categorie") }
    var filterByTags: String            { t("Tags", "Labels") }
    var searchCategory: String          { t("Search category…", "Zoek categorie…") }
    var searchTag: String               { t("Search tag…", "Zoek label…") }

    func minimumLabel(_ s: String) -> String { t("Minimum: \(s)", "Minimum: \(s)") }
    func maximumLabel(_ s: String) -> String { t("Maximum: \(s)", "Maximum: \(s)") }

    func formattedFilterTime(_ minutes: Double, isMax: Bool = false) -> String {
        if isMax && minutes >= 240 { return noLimit }
        if minutes == 0 { return "0 min" }
        let h = Int(minutes) / 60
        let m = Int(minutes) % 60
        let hUnit = t("h", "u")
        if h > 0 && m > 0 { return "\(h) \(hUnit) \(m) min" }
        return h > 0 ? "\(h) \(hUnit)" : "\(m) min"
    }

    func formattedPrepTime(_ totalMinutes: Int) -> String {
        guard totalMinutes > 0 else { return "–" }
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        let hUnit = t("h", "u")
        if h > 0 && m > 0 { return "\(h) \(hUnit) \(m) min" }
        if h > 0 { return "\(h) \(hUnit)" }
        return "\(m) min"
    }

    // Ingredients (database tab)
    var newIngredient: String       { t("New Ingredient", "Nieuw ingrediënt") }
    var editIngredient: String      { t("Edit Ingredient", "Bewerk ingrediënt") }
    var noIngredientsTitle: String  { t("No Ingredients", "Geen ingrediënten") }
    var addFirstIngredient: String  { t("Add your first ingredient with the + button.", "Voeg je eerste ingrediënt toe via de + knop.") }
    var addIngredientBtn: String    { t("Add Ingredient", "Voeg ingrediënt toe") }
    var searchIngredient: String    { t("Search ingredient…", "Zoek ingrediënt…") }
    var unitLabel: String           { t("Unit", "Eenheid") }
    var nameLabel: String           { t("Name", "Naam") }
    var namePlaceholder: String     { t("e.g. flour, butter, milk…", "bijv. bloem, boter, melk…") }
    var unitPlaceholder: String     { t("e.g. g, ml, piece, tbsp…", "bijv. g, ml, stuk, el…") }
    var chooseIngredients: String   { t("Choose Ingredients", "Kies ingrediënten") }
    var noIngredientsHint: String   { t("First add ingredients via the Ingredients tab.", "Voeg eerst ingrediënten toe via het tabblad Ingrediënten.") }

    // Storage
    var newStorageItem: String      { t("New Storage Item", "Nieuwe voorraad") }
    var editStorageItem: String     { t("Edit Storage Item", "Bewerk voorraad") }
    var noStorageTitle: String      { t("No Storage Items", "Geen voorraad") }
    var addStorageHint: String      { t("Add ingredients you have at home.", "Voeg ingrediënten toe die je in huis hebt.") }
    var searchStorage: String       { t("Search storage…", "Zoek in voorraad…") }
    var sortByExpiry: String        { t("Expiry (soonest first)", "Vervaldatum (vroegste eerst)") }
    var filterExpiringSoon: String  { t("Expiring within 7 days", "Verloopt binnen 7 dagen") }
    var filterExpired: String       { t("Show expired items", "Verlopen items tonen") }
    var filterByLocation: String    { t("Location", "Locatie") }
    var ingredientLabel: String     { t("Ingredient", "Ingrediënt") }
    var chooseIngredient: String    { t("Choose an ingredient", "Kies een ingrediënt") }
    var amountLabel: String         { t("Amount", "Hoeveelheid") }
    var locationLabel: String       { t("Location", "Locatie") }
    var expiryDateSection: String   { t("Expiry Date", "Houdbaarheidsdatum") }
    var hasExpiryToggle: String     { t("Has expiry date", "Heeft vervaldatum") }
    var expiryDateField: String     { t("Date", "Vervaldatum") }

    // Storage locations
    var freezerName: String         { t("Freezer", "Vriezer") }
    var refrigeratorName: String    { t("Refrigerator", "Koelkast") }
    var foodClosetName: String      { t("Food Closet", "Voorraadkast") }

    // Expiry labels
    var expired: String             { t("Expired", "Verlopen") }
    var expiresToday: String        { t("Expires today", "Verloopt vandaag") }
    var expiresTomorrow: String     { t("Expires tomorrow", "Verloopt morgen") }
    func expiresInDays(_ n: Int) -> String {
        t("Expires in \(n) days", "Verloopt in \(n) dagen")
    }

    // Tags & Categories
    var categoryLabel: String       { t("Category", "Categorie") }
    var noCategoryOption: String    { t("None", "Geen") }
    var newCategoryTitle: String    { t("New Category", "Nieuwe categorie") }
    var categoryNamePlaceholder: String { t("Category name", "Naam categorie") }
    var addNewCategory: String      { t("New Category…", "Nieuwe categorie…") }
    var tagsLabel: String           { t("Tags", "Labels") }
    var newTagTitle: String         { t("New Tag", "Nieuw label") }
    var tagNamePlaceholder: String  { t("Tag name", "Naam label") }
    var addNewTag: String           { t("New Tag…", "Nieuw label…") }
    var tagColor: String            { t("Color", "Kleur") }
    var standardBadge: String       { t("Standard", "Standaard") }
    var customBadge: String         { t("Custom", "Aangepast") }

    // Calendar
    var calendarTab: String         { t("Calendar", "Agenda") }
    var monthView: String           { t("Month", "Maand") }
    var weekView: String            { t("Week", "Week") }
    var dayView: String             { t("Day", "Dag") }
    var noMealsPlanned: String      { t("No meals planned", "Geen maaltijden gepland") }
    var addMealHint: String         { t("Tap + to add a meal.", "Druk op + om een maaltijd toe te voegen.") }
    var addMeal: String             { t("Add Meal", "Maaltijd toevoegen") }
    var todayButton: String         { t("Today", "Vandaag") }
    var portionSingular: String     { t("portion", "portie") }
    var portionPlural: String       { t("portions", "porties") }
    var mealTypeLabel: String       { t("Meal Type", "Maaltijdtype") }
    var recipeLabel: String         { t("Recipe", "Recept") }
    var customMeal: String          { t("Custom Meal", "Aangepaste maaltijd") }
    var mealName: String            { t("Meal Name", "Naam maaltijd") }
    var notesLabel: String          { t("Notes", "Notities") }
    var editMeal: String            { t("Edit Meal", "Bewerk maaltijd") }
    var newMeal: String             { t("New Meal", "Nieuwe maaltijd") }
    var dateLabel: String           { t("Date", "Datum") }

    // Meal types
    var breakfastLabel: String      { t("Breakfast", "Ontbijt") }
    var lunchLabel: String          { t("Lunch", "Lunch") }
    var dinnerLabel: String         { t("Dinner", "Avondeten") }
    var snackLabel: String          { t("Snack", "Snack") }
    var otherMealLabel: String      { t("Other", "Overig") }

    // Shopping list
    var selectDates: String          { t("Select Dates", "Datums selecteren") }
    var shoppingList: String         { t("Shopping List", "Boodschappenlijst") }
    var noShoppingItemsHint: String  { t("No recipe ingredients for the selected meals.", "Geen recept-ingrediënten voor de geselecteerde maaltijden.") }
    var selectedDatesSection: String { t("Selected Dates", "Geselecteerde datums") }
    var customMealsSection: String   { t("Custom Meals (no ingredients)", "Aangepaste maaltijden (geen ingrediënten)") }

    func datesSelectedCount(_ n: Int) -> String {
        t("\(n) date\(n == 1 ? "" : "s") selected",
          "\(n) datum\(n == 1 ? "" : "s") geselecteerd")
    }

    // What Can I Cook
    var whatCanICook: String        { t("What Can I Cook?", "Wat kan ik koken?") }
    var stockModeAll: String        { t("All Recipes", "Alle recepten") }
    var stockModeCanCook: String    { t("Can Cook Now", "Nu te koken") }
    var stockModeAlmost: String     { t("Almost Ready", "Bijna klaar") }
    var allInStock: String          { t("All in stock", "Alles op voorraad") }
    func missingCount(_ n: Int) -> String { t("Missing \(n)", "Mist \(n)") }

    // Cook Mode
    var cookMode: String                { t("Cook Mode", "Kookstand") }
    var previousStep: String            { t("Previous", "Vorige") }
    var nextStep: String                { t("Next", "Volgende") }
    var cookModeFinish: String          { t("Done Cooking", "Klaar") }
    var noInstructionsForCookMode: String {
        t("No preparation steps found.\nAdd instructions to your recipe first.",
          "Geen bereidingsstappen gevonden.\nVoeg eerst instructies toe aan je recept.")
    }

    func stepLabel(_ current: Int, _ total: Int) -> String {
        t("Step \(current) of \(total)", "Stap \(current) van \(total)")
    }

    // Recipe import
    var importRecipeTitle: String    { t("Import Recipe", "Recept importeren") }
    var importFromURL: String        { t("From URL", "Via URL") }
    var importFromPhoto: String      { t("From Photo", "Via foto") }
    var importFromText: String       { t("Paste Text", "Tekst plakken") }
    var textPlaceholder: String      { t("Paste recipe text here…", "Plak hier de recepttekst…") }
    var pendingImportBanner: String  { t("A recipe is ready to import.", "Een recept staat klaar om te importeren.") }
    var urlPlaceholder: String       { t("Paste recipe URL…", "Plak recept-URL…") }
    var fetchButton: String          { t("Fetch", "Ophalen") }
    var choosePhoto: String          { t("Choose Image", "Afbeelding kiezen") }
    var takePhoto: String            { t("Take Photo", "Foto nemen") }
    var analyzeButton: String        { t("Analyze", "Analyseren") }
    var analyzingRecipe: String      { t("Analyzing recipe…", "Recept analyseren…") }
    var fetchingURL: String          { t("Fetching page…", "Pagina ophalen…") }
    var aiImportDisclaimer: String   { t(
        "AI-assisted import is experimental and may make mistakes. All processing happens on-device — no data is sent to external servers.",
        "AI-gestuurde import is experimenteel en kan fouten bevatten. Alle verwerking gebeurt op het apparaat zelf — er worden geen gegevens naar externe servers verzonden."
    ) }
    var addToRecipes: String         { t("Add to Recipes", "Toevoegen aan recepten") }
    var importRecipeBtn: String      { t("Import Recipe", "Recept importeren") }
    var importedPreviewTitle: String { t("Recipe Preview", "Receptvoorbeeld") }
    var noAIHint: String             { t("Structured data not found. AI parsing requires macOS 26 or later.", "Gestructureerde data niet gevonden. AI-verwerking vereist macOS 26 of hoger.") }
    var aiRequiresiOS26: String      { t("Photo analysis requires iOS 26 or later. Update your device to use this feature.", "Fotoanalyse vereist iOS 26 of hoger. Update je toestel om deze functie te gebruiken.") }

    // Privacy policy
    var privacyPolicyTitle: String         { t("Privacy Policy", "Privacybeleid") }
    var privacyPolicyEffectiveDate: String { t("Effective date: May 2026", "Ingangsdatum: mei 2026") }
    var privacyPolicy: String              { t("Privacy Policy", "Privacybeleid") }

    // Data export / import
    var dataLabel: String          { t("Data", "Gegevens") }
    var exportData: String         { t("Export Data…", "Gegevens exporteren…") }
    var importData: String         { t("Import Data…", "Gegevens importeren…") }
    var importSuccessTitle: String { t("Import Complete", "Import voltooid") }
    var importFailedTitle: String  { t("Import Failed", "Import mislukt") }
    var exportFailedTitle: String  { t("Export Failed", "Export mislukt") }
    var nothingImported: String    { t("Nothing new to import.", "Niets nieuws om te importeren.") }
    func importedRecipes(_ n: Int) -> String      { t("\(n) recipe\(n == 1 ? "" : "s")", "\(n) recept\(n == 1 ? "" : "en")") }
    func importedIngredients(_ n: Int) -> String  { t("\(n) ingredient\(n == 1 ? "" : "s")", "\(n) ingrediënt\(n == 1 ? "" : "en")") }
    func importedStorageItems(_ n: Int) -> String { t("\(n) storage item\(n == 1 ? "" : "s")", "\(n) voorraaditem\(n == 1 ? "" : "s")") }
    func importedMeals(_ n: Int) -> String        { t("\(n) meal\(n == 1 ? "" : "s")", "\(n) maaltijd\(n == 1 ? "" : "en")") }
    func importedCategories(_ n: Int) -> String   { t("\(n) categor\(n == 1 ? "y" : "ies")", "\(n) categorie\(n == 1 ? "" : "ën")") }
    func importedTags(_ n: Int) -> String         { t("\(n) tag\(n == 1 ? "" : "s")", "\(n) label\(n == 1 ? "" : "s")") }

    // Shopping category names
    var categoryProduce: String   { t("Produce", "Groenten & Fruit") }
    var categoryDairy: String     { t("Dairy & Eggs", "Zuivel & Eieren") }
    var categoryMeat: String      { t("Meat & Fish", "Vlees & Vis") }
    var categoryFrozen: String    { t("Frozen", "Diepvries") }
    var categoryPantry: String    { t("Pantry", "Droogwaren") }
    var categoryBakery: String    { t("Bakery", "Bakkerij") }
    var categoryBeverages: String { t("Beverages", "Dranken") }
    var categoryHerbs: String     { t("Herbs & Spices", "Kruiden") }
    var categoryOther: String     { t("Other", "Overig") }
    var shoppingCategoryLabel: String { t("Category", "Categorie") }
    var tabShoppingList: String   { t("Shopping", "Boodschappen") }
    var groupByCategory: String   { t("Group by Category", "Groepeer op categorie") }
    var clearChecked: String      { t("Clear Checked", "Afgevinkte verwijderen") }
    var addShoppingItemTitle: String { t("Add Item", "Item toevoegen") }
    var addAllToShoppingList: String { t("Add All to My List", "Alles naar mijn lijst") }
    var myListEmptyHint: String   { t("Add items manually or tap \"Add All to My List\" from a meal plan.", "Voeg items handmatig toe of tik op \"Alles naar mijn lijst\" vanuit een maaltijdplan.") }
    var aisleOrderTitle: String   { t("Aisle Order", "Gangvolgorde") }
    var aisleOrderHint: String    { t("Drag categories to match your store's layout. The shopping list groups items in this order.", "Sleep categorieën om de indeling van uw winkel te weerspiegelen. De boodschappenlijst groepeert items in deze volgorde.") }
    var manageAisleOrder: String  { t("Aisle Order", "Gangvolgorde") }
    var newItem: String           { t("New Item", "Nieuw item") }
    func addAsNewItem(_ name: String) -> String {
        t("Add \"\(name)\" as new item", "Voeg \"\(name)\" toe als nieuw item")
    }
    var deductFromStorage: String { t("Deduct from storage", "Trek voorraad af") }
    var fullyInStorage: String    { t("In storage", "Al in voorraad") }
    func haveInStorage(_ amount: String) -> String { t("have \(amount) in storage", "\(amount) in voorraad") }

    // Import conflict resolution
    var resolveConflictsTitle: String { t("Import Conflicts", "Importconflicten") }
    var conflictExistingLabel: String { t("Existing", "Bestaand") }
    var conflictImportedLabel: String { t("Imported", "Geïmporteerd") }
    var keepExistingAction: String    { t("Keep Existing", "Bestaande behouden") }
    var useImportedAction: String     { t("Use Imported", "Geïmporteerde gebruiken") }
    var applyConflictsAction: String  { t("Apply", "Toepassen") }
    func conflictSubtitle(_ n: Int) -> String {
        t("\(n) item\(n == 1 ? " differs" : "s differ") from your existing data.",
          "\(n) item\(n == 1 ? "" : "s") verschilt van je bestaande data.")
    }

    // Ingredient deletion guard
    var ingredientInUseTitle: String { t("Cannot Delete Ingredient", "Ingrediënt kan niet worden verwijderd") }
    func ingredientInUseMessage(_ name: String, recipes: Int, storage: Int) -> String {
        var parts: [String] = []
        if recipes > 0 { parts.append(t("\(recipes) recipe\(recipes == 1 ? "" : "s")", "\(recipes) recept\(recipes == 1 ? "" : "en")")) }
        if storage > 0 { parts.append(t("\(storage) storage item\(storage == 1 ? "" : "s")", "\(storage) voorraaditem\(storage == 1 ? "" : "s")")) }
        return t("\"\(name)\" is used in \(parts.joined(separator: " and ")). Remove those references first.",
                 "\"\(name)\" wordt gebruikt in \(parts.joined(separator: " en ")). Verwijder die verwijzingen eerst.")
    }

    // Recipe deletion — calendar guard
    var recipeFutureScheduledTitle: String { t("Recipe Is Scheduled", "Recept is ingepland") }
    func recipeFutureScheduledMessage(_ name: String, _ count: Int) -> String {
        t("\"\(name)\" is planned \(count) time\(count == 1 ? "" : "s") in the future. Remove it from the calendar first.",
          "\"\(name)\" staat \(count) keer ingepland in de toekomst. Verwijder het eerst uit de agenda.")
    }
    func deleteRecipeWithPastPlansMessage(_ name: String, _ count: Int) -> String {
        t("\"\(name)\" was planned \(count) time\(count == 1 ? "" : "s") in the past. Those calendar entries will also be deleted.",
          "\"\(name)\" stond \(count) keer ingepland in het verleden. Die agenda-items worden ook verwijderd.")
    }

    // Features
    var featuresTitle: String          { t("Features", "Functies") }
    var featureStorageLabel: String    { t("Storage", "Voorraad") }
    var featureStorageDesc: String     { t("Track ingredients you have at home.", "Bijhouden wat je thuis in voorraad hebt.") }
    var featureCalendarLabel: String   { t("Meal Calendar", "Maaltijdenplanner") }
    var featureCalendarDesc: String    { t("Plan meals and generate shopping lists.", "Maaltijden plannen en boodschappenlijsten maken.") }
    var featureAILabel: String         { t("AI Recipe Import", "AI-receptimport") }
    var featureAIDesc: String          { t("Import recipes from photos or URLs using on-device AI.", "Recepten importeren via foto's of URL's met on-device AI.") }
    var featureNutritionLabel: String  { t("Nutrition", "Voedingswaarden") }
    var featureNutritionDesc: String   { t("Show calorie and nutrient data per recipe.", "Calorie- en voedingswaarden per recept tonen.") }
    var featureShoppingLabel: String   { t("Shopping List", "Boodschappenlijst") }
    var featureShoppingDesc: String    { t("Manually add items and generate lists from your meal plan.", "Handmatig items toevoegen en lijsten genereren vanuit je maaltijdplan.") }

    // Nutrition
    var nutritionTitle: String        { t("Nutrition", "Voedingswaarden") }
    var nutritionCalories: String     { t("Calories", "Calorieën") }
    var nutritionProtein: String      { t("Protein", "Eiwit") }
    var nutritionFat: String          { t("Fat", "Vet") }
    var nutritionCarbs: String        { t("Carbs", "Koolhydraten") }
    var nutritionFiber: String        { t("Fiber", "Vezels") }
    var nutritionSatFat: String       { t("of which Saturated Fat", "waarvan verzadigd vet") }
    var nutritionSugars: String       { t("of which Sugars", "waarvan suikers") }
    var nutritionSodium: String       { t("Sodium", "Natrium") }
    var nutritionPotassium: String    { t("Potassium", "Kalium") }
    var nutritionCalcium: String      { t("Calcium", "Calcium") }
    var nutritionIron: String         { t("Iron", "IJzer") }
    var nutritionVitC: String         { t("Vitamin C", "Vitamine C") }
    var nutritionVitD: String         { t("Vitamin D", "Vitamine D") }
    var nutritionMinerals: String     { t("Minerals", "Mineralen") }
    var nutritionVitamins: String     { t("Vitamins", "Vitaminen") }
    var nutritionPer100g: String      { t("per 100 g", "per 100 g") }
    var lookupNutrition: String       { t("Look Up Nutrition", "Voedingswaarden opzoeken") }
    var refreshNutrition: String      { t("Refresh Nutrition", "Voedingswaarden verversen") }
    var nutritionSource: String       { t("Based on data from NEVO online version 2025/9.0, RIVM, Bilthoven",
                                         "Gebaseerd op gegevens van NEVO online versie 2025/9.0, RIVM, Bilthoven") }
    func nutritionIngredientNote(_ n: Int, _ total: Int) -> String {
        t("Based on \(n)/\(total) ingredients (g/ml units only)",
          "Op basis van \(n)/\(total) ingrediënten (g/ml-eenheden)")
    }
    var nutritionDailyTotal: String  { t("Nutrition Today", "Voedingswaarden vandaag") }
    var nutritionWeeklyTotal: String { t("This Week", "Deze week") }
    var nutritionAvgPerDay: String   { t("avg/day", "gem/dag") }
    func nutritionMealsTracked(_ n: Int, _ total: Int) -> String {
        t("Based on \(n) of \(total) meals", "Op basis van \(n) van \(total) maaltijden")
    }

    // Notifications
    var notificationExpiryTitle: String { t("Expiry Reminder", "Vervaldatum herinnering") }
    func notificationExpiresTomorrow(_ name: String) -> String {
        t("\(name) expires tomorrow.", "\(name) verloopt morgen.")
    }
    func notificationExpiresInDays(_ name: String, _ days: Int) -> String {
        t("\(name) expires in \(days) days.", "\(name) verloopt over \(days) dagen.")
    }
    var notificationTimeSection: String { t("Expiry Notifications", "Vervaldatumherinneringen") }
    var notificationTimeLabel: String   { t("Notify at", "Herinnering om") }

    // Barcode scanning
    var scanBarcode: String         { t("Scan Barcode", "Streepjescode scannen") }
    var scanningBarcode: String     { t("Looking up product…", "Product opzoeken…") }
    var barcodeNotFound: String     { t("Product not found. Select manually.", "Product niet gevonden. Selecteer handmatig.") }
    func productFound(_ name: String) -> String { t("Found: \(name)", "Gevonden: \(name)") }

    // Rating
    var ratingLabel: String        { t("Rating", "Beoordeling") }
    var filterByRating: String     { t("Minimum Rating", "Minimale beoordeling") }
    var ratingAny: String          { t("Any", "Alle") }
    var shareShoppingList: String  { t("Share List", "Lijst delen") }

    // Sorting
    var sortLabel: String      { t("Sort", "Sorteren") }
    var sortByNameAZ: String      { t("Name A–Z", "Naam A–Z") }
    var sortByNameZA: String      { t("Name Z–A", "Naam Z–A") }
    var sortByCategory: String    { t("Category", "Categorie") }
    var sortByPrepAsc: String  { t("Quickest First", "Kortste bereidingstijd") }
    var sortByPrepDesc: String { t("Longest First", "Langste bereidingstijd") }
    var sortNewest: String     { t("Newest First", "Nieuwste eerst") }
    var sortOldest: String     { t("Oldest First", "Oudste eerst") }

    // Duplication
    func duplicateRecipeName(_ name: String) -> String {
        t("Copy of \(name)", "Kopie van \(name)")
    }
    var duplicateRecipe: String { t("Duplicate Recipe", "Recept dupliceren") }
}
