import SwiftUI
import SwiftData

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

    @State private var viewMode: CalendarViewMode = .month
    @State private var displayDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var activeSheet: SheetState?
    @State private var isSelectingDates = false
    @State private var selectedDates: Set<Date> = []

    private var lang: AppLanguage { appSettings.language }
    private var cal: Calendar { Calendar.current }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ── View mode picker ──────────────────────────────
                Picker("", selection: $viewMode) {
                    Text(lang.monthView).tag(CalendarViewMode.month)
                    Text(lang.weekView).tag(CalendarViewMode.week)
                    Text(lang.dayView).tag(CalendarViewMode.day)
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
                         ? lang.selectDates
                         : lang.datesSelectedCount(selectedDates.count))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 6)
                }

                Divider()

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
            .navigationTitle(lang.calendarTab)
            .navigationTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    if isSelectingDates {
                        if !selectedDates.isEmpty {
                            Button {
                                activeSheet = .shoppingList
                            } label: {
                                Label(lang.shoppingList, systemImage: "cart")
                            }
                        }
                        Button(lang.cancel) {
                            isSelectingDates = false
                            selectedDates = []
                        }
                    } else {
                        if !cal.isDateInToday(displayDate) {
                            Button(lang.todayButton) {
                                displayDate = cal.startOfDay(for: Date())
                            }
                        }
                        Button {
                            isSelectingDates = true
                        } label: {
                            Label(lang.selectDates, systemImage: "checkmark.circle")
                        }
                        Button {
                            activeSheet = .addMeal(displayDate)
                        } label: {
                            Label(lang.addMeal, systemImage: "plus")
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
                    ForEach(weekdayHeaders(), id: \.self) { label in
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
    private var lang: AppLanguage { appSettings.language }
    private let cal = Calendar.current

    var body: some View {
        List {
            ForEach(weekDates(for: displayDate), id: \.self) { date in
                let dayMeals = mealPlans
                    .filter { cal.isDate($0.date, inSameDayAs: date) }
                    .sorted { $0.mealType.sortOrder < $1.mealType.sortOrder }
                let isSelected = selectedDates.contains(cal.startOfDay(for: date))

                Section {
                    if dayMeals.isEmpty {
                        Text(lang.noMealsPlanned)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(dayMeals) { meal in
                            MealEntryRow(meal: meal)
                                .contentShape(Rectangle())
                                .onTapGesture { onEdit(meal) }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) { onDelete(meal) } label: {
                                        Label(lang.delete, systemImage: "trash")
                                    }
                                }
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
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
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
    private var lang: AppLanguage { appSettings.language }
    private let cal = Calendar.current

    private var dayMeals: [MealPlan] {
        mealPlans
            .filter { cal.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.mealType.sortOrder < $1.mealType.sortOrder }
    }

    var body: some View {
        if dayMeals.isEmpty {
            ContentUnavailableView {
                Label(lang.noMealsPlanned, systemImage: "fork.knife")
            } description: {
                Text(lang.addMealHint)
            } actions: {
                Button(action: onAdd) {
                    Label(lang.addMeal, systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
        } else {
            List {
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
                                            Label(lang.delete, systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            Label(mealType.localizedName(in: lang), systemImage: mealType.icon)
                        }
                    }
                }

                // Prominent "Add Meal" row at the bottom
                Section {
                    Button(action: onAdd) {
                        Label(lang.addMeal, systemImage: "plus.circle.fill")
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

    private var lang: AppLanguage { appSettings.language }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(meal.displayName).font(.body)
            HStack(spacing: 12) {
                let portionLabel = meal.portions == 1 ? lang.portionSingular : lang.portionPlural
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
