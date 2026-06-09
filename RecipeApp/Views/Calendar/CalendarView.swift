import SwiftUI
import SwiftData
import TipKit

// MARK: - Supporting types

enum CalendarViewMode: String, CaseIterable, Identifiable {
    case month, week, day
    var id: String { rawValue }
}

/// Single enum drives the one sheet modifier — avoids double-sheet issues.
private enum SheetState: Identifiable {
    case addMeal(Date)
    case editMeal(MealPlan)
    case shoppingList

    var id: String {
        switch self {
        case .addMeal(let d):  return "add:\(d.timeIntervalSince1970)"
        case .editMeal(let m): return "edit:\(ObjectIdentifier(m))"
        case .shoppingList:    return "shopping"
        }
    }
}

// Colour for each meal-type dot (view layer only)
private extension MealType {
    var dotColor: Color {
        switch self {
        case .breakfast: return .orange
        case .lunch:     return .green
        case .dinner:    return .blue
        case .snack:     return .yellow
        case .other:     return .gray
        }
    }
}

// MARK: - CalendarView (root)

struct CalendarView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) private var appSettings
    @Query(sort: \MealPlan.date) private var allMealPlans: [MealPlan]

    private let addMealPlanTip = AddMealPlanTip()
    private let shoppingListTip = ShoppingListTip()

    @State private var viewMode: CalendarViewMode = .month
    @State private var displayDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var activeSheet: SheetState?
    @State private var isSelectingDates = false
    @State private var selectedDates: Set<Date> = []

    private var cal: Calendar { Calendar.current }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ── View mode picker ──────────────────────────────
                Picker("", selection: $viewMode) {
                    Text(String(localized: "Month")).tag(CalendarViewMode.month)
                    Text(String(localized: "Week")).tag(CalendarViewMode.week)
                    Text(String(localized: "Day")).tag(CalendarViewMode.day)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 10)

                // ── Period navigation header ──────────────────────
                HStack {
                    Button { navigate(-1) } label: {
                        Image(systemName: "chevron.left").font(.title3)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Text(navigationTitle)
                        .font(.headline)
                        .animation(.none, value: displayDate)
                    Spacer()
                    Button { navigate(1) } label: {
                        Image(systemName: "chevron.right").font(.title3)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                if isSelectingDates {
                    Text(selectedDates.isEmpty
                         ? String(localized: "Select Dates")
                         : String(localized: "\(selectedDates.count) dates selected"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 6)
                }

                Divider()

                TipView(addMealPlanTip)
                    .padding(.horizontal)
                    .padding(.top, 4)
                TipView(shoppingListTip)
                    .padding(.horizontal)

                // ── Content ───────────────────────────────────────
                Group {
                    switch viewMode {
                    case .month:
                        MonthGridView(
                            displayDate: $displayDate,
                            mealPlans: allMealPlans,
                            isSelecting: isSelectingDates,
                            selectedDates: selectedDates,
                            onDayTap: { tappedDate in
                                displayDate = tappedDate
                                viewMode = .day
                            },
                            onToggleSelection: toggleSelection
                        )
                    case .week:
                        WeekListView(
                            displayDate: $displayDate,
                            mealPlans: allMealPlans,
                            isSelecting: isSelectingDates,
                            selectedDates: selectedDates,
                            onDayTap: { date in
                                displayDate = date
                                viewMode = .day
                            },
                            onToggleSelection: toggleSelection,
                            onEdit: { meal in activeSheet = .editMeal(meal) },
                            onDelete: delete
                        )
                    case .day:
                        DayDetailView(
                            date: displayDate,
                            mealPlans: allMealPlans,
                            onAdd: { activeSheet = .addMeal(displayDate) },
                            onEdit: { meal in activeSheet = .editMeal(meal) },
                            onDelete: delete
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(String(localized: "Calendar"))
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    if isSelectingDates {
                        if !selectedDates.isEmpty {
                            Button {
                                activeSheet = .shoppingList
                            } label: {
                                Label(String(localized: "Shopping List"), systemImage: "cart")
                            }
                        }
                        Button(String(localized: "Cancel")) {
                            isSelectingDates = false
                            selectedDates = []
                        }
                    } else {
                        if !cal.isDateInToday(displayDate) {
                            Button(String(localized: "Today")) {
                                displayDate = cal.startOfDay(for: Date())
                            }
                        }
                        Button {
                            isSelectingDates = true
                        } label: {
                            Label(String(localized: "Select Dates"), systemImage: "checkmark.circle")
                        }
                        Button {
                            activeSheet = .addMeal(displayDate)
                            addMealPlanTip.invalidate(reason: .actionPerformed)
                        } label: {
                            Label(String(localized: "Add Meal"), systemImage: "plus")
                        }
                    }
                }
            }
            .sheet(item: $activeSheet) { state in
                switch state {
                case .addMeal(let date):
                    MealPlanFormView(initialDate: date)
                case .editMeal(let meal):
                    MealPlanFormView(existingMealPlan: meal)
                case .shoppingList:
                    ShoppingListView(selectedDates: selectedDates)
                }
            }
        }
    }

    // MARK: - Helpers

    private func toggleSelection(_ date: Date) {
        let normalized = cal.startOfDay(for: date)
        if selectedDates.contains(normalized) {
            selectedDates.remove(normalized)
        } else {
            selectedDates.insert(normalized)
        }
    }

    private var navigationTitle: String {
        let f = DateFormatter()
        switch viewMode {
        case .month:
            f.dateFormat = "MMMM yyyy"
            return f.string(from: displayDate)
        case .week:
            let days = weekDates(for: displayDate)
            guard let first = days.first, let last = days.last else {
                f.dateFormat = "MMM d"
                return f.string(from: displayDate)
            }
            f.dateFormat = "MMM d"
            let startStr = f.string(from: first)
            if cal.component(.month, from: first) == cal.component(.month, from: last) {
                return "\(startStr)–\(cal.component(.day, from: last))"
            } else {
                return "\(startStr) – \(f.string(from: last))"
            }
        case .day:
            f.dateFormat = "EEEE, MMM d"
            return f.string(from: displayDate)
        }
    }

    private func navigate(_ direction: Int) {
        switch viewMode {
        case .month:
            displayDate = cal.date(byAdding: .month, value: direction, to: displayDate) ?? displayDate
        case .week:
            displayDate = cal.date(byAdding: .weekOfYear, value: direction, to: displayDate) ?? displayDate
        case .day:
            displayDate = cal.date(byAdding: .day, value: direction, to: displayDate) ?? displayDate
        }
    }

    private func delete(_ meal: MealPlan) {
        modelContext.delete(meal)
    }
}

// MARK: - Month grid

private struct MonthGridView: View {

    @Binding var displayDate: Date
    let mealPlans: [MealPlan]
    let isSelecting: Bool
    let selectedDates: Set<Date>
    let onDayTap: (Date) -> Void
    let onToggleSelection: (Date) -> Void

    private let cal = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        ScrollView {
            VStack(spacing: 4) {
                // Weekday headers
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(Array(weekdayHeaders().enumerated()), id: \.offset) { _, label in
                        Text(label)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)

                // Day cells
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(Array(monthDays().enumerated()), id: \.offset) { _, date in
                        if let date {
                            let meals = mealPlans.filter {
                                cal.isDate($0.date, inSameDayAs: date)
                            }
                            let isSelected = selectedDates.contains(cal.startOfDay(for: date))
                            MonthDayCell(
                                date: date,
                                meals: meals,
                                isSelecting: isSelecting,
                                isSelected: isSelected
                            ) {
                                if isSelecting {
                                    onToggleSelection(date)
                                } else {
                                    onDayTap(date)
                                }
                            }
                        } else {
                            Color.clear.frame(height: 52)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }

    private func weekdayHeaders() -> [String] {
        let symbols = cal.veryShortWeekdaySymbols
        let offset = cal.firstWeekday - 1
        return Array(symbols[offset...]) + Array(symbols[..<offset])
    }

    private func monthDays() -> [Date?] {
        guard
            let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: displayDate)),
            let range = cal.range(of: .day, in: .month, for: displayDate)
        else { return [] }

        let leadingEmpties = (cal.component(.weekday, from: monthStart) - cal.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: leadingEmpties)

        for day in range {
            var c = cal.dateComponents([.year, .month], from: displayDate)
            c.day = day
            days.append(cal.date(from: c))
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }
}

private struct MonthDayCell: View {

    let date: Date
    let meals: [MealPlan]
    let isSelecting: Bool
    let isSelected: Bool
    let onTap: () -> Void

    private var isToday: Bool { Calendar.current.isDateInToday(date) }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 3) {
                ZStack(alignment: .topTrailing) {
                    // Day number with today/selected background
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.subheadline)
                        .fontWeight(isToday ? .bold : .regular)
                        .foregroundStyle(isToday && !isSelected ? .white : .primary)
                        .frame(width: 30, height: 30)
                        .background(
                            Group {
                                if isSelected {
                                    Circle().fill(Color.accentColor.opacity(0.25))
                                } else if isToday {
                                    Circle().fill(Color.accentColor)
                                } else {
                                    Circle().fill(Color.clear)
                                }
                            }
                        )

                    // Selection checkmark badge
                    if isSelecting && isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.accentColor)
                            .offset(x: 4, y: -4)
                    }
                }
                .frame(width: 34, height: 34)

                // Up to 3 meal-type dots
                HStack(spacing: 3) {
                    let types = Array(Set(meals.map(\.mealType)))
                        .sorted { $0.sortOrder < $1.sortOrder }
                        .prefix(3)
                    ForEach(types, id: \.self) { t in
                        Circle().fill(t.dotColor).frame(width: 5, height: 5)
                    }
                    if meals.isEmpty {
                        Color.clear.frame(width: 5, height: 5)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .frame(height: 52)
    }
}

// MARK: - Week list

private struct WeekListView: View {

    @Binding var displayDate: Date
    let mealPlans: [MealPlan]
    let isSelecting: Bool
    let selectedDates: Set<Date>
    let onDayTap: (Date) -> Void
    let onToggleSelection: (Date) -> Void
    let onEdit: (MealPlan) -> Void
    let onDelete: (MealPlan) -> Void

    @Environment(AppSettings.self) private var appSettings
    private let cal = Calendar.current

    var body: some View {
        let days = weekDates(for: displayDate)
        let weekMeals = mealPlans.filter { meal in
            days.contains { cal.isDate(meal.date, inSameDayAs: $0) }
        }
        let weekNutrition = NutritionCalculator.nutrition(for: weekMeals)
        let maxDayKcal: Double = days.map { date in
            let dayMeals = mealPlans.filter { cal.isDate($0.date, inSameDayAs: date) }
            return NutritionCalculator.nutrition(for: dayMeals).calories
        }.max() ?? 1

        List {
            // ── Per-day sections ─────────────────────────────
            ForEach(days, id: \.self) { date in
                let dayMeals = mealPlans
                    .filter { cal.isDate($0.date, inSameDayAs: date) }
                    .sorted { $0.mealType.sortOrder < $1.mealType.sortOrder }
                let isSelected = selectedDates.contains(cal.startOfDay(for: date))
                let dayNutrition = NutritionCalculator.nutrition(for: dayMeals)

                Section {
                    if dayMeals.isEmpty {
                        Text(String(localized: "No meals planned"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(dayMeals) { meal in
                            MealEntryRow(meal: meal)
                                .contentShape(Rectangle())
                                .onTapGesture { onEdit(meal) }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) { onDelete(meal) } label: {
                                        Label(String(localized: "Delete"), systemImage: "trash")
                                    }
                                }
                        }

                        // Compact day nutrition bar
                        if appSettings.featureNutrition && dayNutrition.hasData {
                            DayCalorieBar(
                                nutrition: dayNutrition,
                                maxKcal: maxDayKcal
                            )
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                } header: {
                    Button {
                        if isSelecting {
                            onToggleSelection(date)
                        } else {
                            onDayTap(date)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if isSelecting {
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                                    .font(.body)
                            }
                            Text(dayHeader(date))
                                .fontWeight(cal.isDateInToday(date) ? .bold : .regular)
                                .foregroundStyle(cal.isDateInToday(date) ? Color.accentColor : .primary)
                            Spacer()
                            if !isSelecting {
                                // Calorie badge
                                if appSettings.featureNutrition && dayNutrition.hasData {
                                    Text("\(Int(dayNutrition.calories.rounded())) kcal")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            // ── Weekly nutrition summary ──────────────────────
            if appSettings.featureNutrition && weekNutrition.hasData {
                Section {
                    NutritionSummaryCard(
                        nutrition: weekNutrition,
                        averageNutrition: NutritionCalculator.average(weekNutrition, days: 7),
                        showAverage: true
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    .listRowBackground(Color.clear)
                } header: {
                    Text(String(localized: "This Week"))
                }
            }
        }
    }

    private func dayHeader(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: date)
    }
}

// MARK: - Day detail

private struct DayDetailView: View {

    let date: Date
    let mealPlans: [MealPlan]
    let onAdd: () -> Void
    let onEdit: (MealPlan) -> Void
    let onDelete: (MealPlan) -> Void

    @Environment(AppSettings.self) private var appSettings
    private let cal = Calendar.current

    private var dayMeals: [MealPlan] {
        mealPlans
            .filter { cal.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.mealType.sortOrder < $1.mealType.sortOrder }
    }

    var body: some View {
        if dayMeals.isEmpty {
            ContentUnavailableView {
                Label(String(localized: "No meals planned"), systemImage: "fork.knife")
            } description: {
                Text(String(localized: "Tap + to add a meal."))
            } actions: {
                Button(action: onAdd) {
                    Label(String(localized: "Add Meal"), systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            let nutrition = NutritionCalculator.nutrition(for: dayMeals)

            List {
                // ── Nutrition summary ─────────────────────────
                if appSettings.featureNutrition && nutrition.hasData {
                    Section {
                        NutritionSummaryCard(
                            nutrition: nutrition,
                            averageNutrition: nil,
                            showAverage: false
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                        .listRowBackground(Color.clear)
                    } header: {
                        Text(String(localized: "Nutrition Today"))
                    }
                }

                // ── Meals by type ──────────────────────────────
                ForEach(MealType.allCases, id: \.self) { mealType in
                    let meals = dayMeals.filter { $0.mealType == mealType }
                    if !meals.isEmpty {
                        Section {
                            ForEach(meals) { meal in
                                MealEntryRow(meal: meal)
                                    .contentShape(Rectangle())
                                    .onTapGesture { onEdit(meal) }
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) { onDelete(meal) } label: {
                                            Label(String(localized: "Delete"), systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            Label(mealType.localizedName, systemImage: mealType.icon)
                        }
                    }
                }

                // Prominent "Add Meal" row at the bottom
                Section {
                    Button(action: onAdd) {
                        Label(String(localized: "Add Meal"), systemImage: "plus.circle.fill")
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
        }
    }
}

// MARK: - Meal entry row

private struct MealEntryRow: View {

    @Environment(AppSettings.self) private var appSettings
    let meal: MealPlan


    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(meal.displayName).font(.body)
            HStack(spacing: 12) {
                let portionLabel = meal.portions == 1 ? String(localized: "portion") : String(localized: "portions")
                Label("\(meal.portions) \(portionLabel)", systemImage: "person.2")
                if !meal.notes.isEmpty {
                    Label(meal.notes, systemImage: "note.text").lineLimit(1)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Nutrition summary card (day + week)

private struct NutritionSummaryCard: View {
    let nutrition: PeriodNutrition
    let averageNutrition: PeriodNutrition?   // nil for day view
    let showAverage: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // ── Calorie headline ──────────────────────────────
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(Int(nutrition.calories.rounded()))")
                    .font(.system(.title, design: .rounded)).fontWeight(.bold)
                    .foregroundStyle(.orange)
                Text("kcal")
                    .font(.subheadline).foregroundStyle(.secondary)
                if showAverage, let avg = averageNutrition {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("\(Int(avg.calories.rounded())) kcal")
                            .font(.subheadline).fontWeight(.semibold).foregroundStyle(.orange.opacity(0.7))
                        Text(String(localized: "avg/day"))
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                }
            }

            // ── Macro proportion bar ──────────────────────────
            MacroProportionBar(nutrition: nutrition)

            // ── Macro breakdown ───────────────────────────────
            HStack(spacing: 0) {
                macroCell(String(localized: "Protein"), value: nutrition.protein, color: .blue)
                macroCell(String(localized: "Fat"),     value: nutrition.fat,     color: .yellow)
                macroCell(String(localized: "Carbs"),   value: nutrition.carbs,   color: .green)
                macroCell(String(localized: "Fiber"),   value: nutrition.fiber,   color: .brown)
            }

            // ── Partial-data note ─────────────────────────────
            if nutrition.mealsWithData < nutrition.totalMeals {
                Text(String(localized: "Based on \(nutrition.mealsWithData) of \(nutrition.totalMeals) meals"))
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func macroCell(_ label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(String(format: "%.1f", value))
                .font(.subheadline).fontWeight(.semibold).foregroundStyle(color)
            Text("g").font(.caption2).foregroundStyle(.secondary)
            Text(label).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Macro proportion bar

private struct MacroProportionBar: View {
    let nutrition: PeriodNutrition

    var body: some View {
        let total = nutrition.macroKcalTotal
        guard total > 0 else { return AnyView(EmptyView()) }
        let p = nutrition.proteinKcal / total
        let f = nutrition.fatKcal     / total
        let c = nutrition.carbsKcal   / total
        return AnyView(
            GeometryReader { geo in
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 2).fill(Color.blue.opacity(0.7))
                        .frame(width: geo.size.width * p)
                    RoundedRectangle(cornerRadius: 2).fill(Color.yellow.opacity(0.7))
                        .frame(width: geo.size.width * f)
                    RoundedRectangle(cornerRadius: 2).fill(Color.green.opacity(0.7))
                        .frame(width: geo.size.width * c)
                }
            }
            .frame(height: 6)
            .clipShape(RoundedRectangle(cornerRadius: 3))
        )
    }
}

// MARK: - Compact day calorie bar (week view)

private struct DayCalorieBar: View {
    let nutrition: PeriodNutrition
    let maxKcal: Double   // week's daily maximum, for relative bar width

    var body: some View {
        HStack(spacing: 8) {
            GeometryReader { geo in
                let fraction = maxKcal > 0 ? min(nutrition.calories / maxKcal, 1.0) : 0
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(Color.secondary.opacity(0.12))
                    RoundedRectangle(cornerRadius: 3).fill(Color.orange.opacity(0.6))
                        .frame(width: geo.size.width * fraction)
                }
            }
            .frame(height: 6)

            Text("\(Int(nutrition.calories.rounded())) kcal")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .frame(width: 68, alignment: .trailing)
        }
    }
}

// MARK: - Shared helper

private func weekDates(for date: Date) -> [Date] {
    let cal = Calendar.current
    guard let interval = cal.dateInterval(of: .weekOfYear, for: date) else { return [] }
    var days: [Date] = []
    var current = interval.start
    for _ in 0..<7 {
        days.append(current)
        current = cal.date(byAdding: .day, value: 1, to: current) ?? current
    }
    return days
}

#Preview {
    CalendarView()
        .environment(AppSettings())
        .modelContainer(for: [MealPlan.self, Recipe.self], inMemory: true)
}
