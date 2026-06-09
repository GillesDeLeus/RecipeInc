import Foundation

/// Locale-aware durations ("1 hr, 30 min" / "1 u, 30 min."), replacing the
/// hand-rolled hour/minute strings from the old AppLanguage system.
enum TimeFormat {

    /// Recipe prep time; "–" when unset.
    static func prepTime(_ totalMinutes: Int) -> String {
        guard totalMinutes > 0 else { return "–" }
        return duration(minutes: totalMinutes)
    }

    /// Filter slider labels; values at/above 4 h mean "no limit".
    static func filterTime(_ minutes: Double, isMax: Bool = false) -> String {
        if isMax && minutes >= 240 { return String(localized: "No limit") }
        return duration(minutes: Int(minutes))
    }

    private static func duration(minutes: Int) -> String {
        let units: Set<Duration.UnitsFormatStyle.Unit> = minutes >= 60 ? [.hours, .minutes] : [.minutes]
        return Duration.seconds(minutes * 60)
            .formatted(.units(allowed: units, width: .abbreviated))
    }
}
