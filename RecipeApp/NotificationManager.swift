import Foundation
import UserNotifications

final class NotificationManager {

    static let shared = NotificationManager()
    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // Schedule 2-day and 1-day-before notifications, or cancel if no expiry date.
    func updateNotifications(for item: StorageItem) {
        cancelNotifications(for: item)
        guard let expiry = item.expiryDate else { return }

        let center = UNUserNotificationCenter.current()
        let ingredientName = item.ingredient?.name ?? "Item"
        let lang = AppLanguage(rawValue: UserDefaults.standard.string(forKey: "appLanguage") ?? "en") ?? .english

        for daysOffset in [2, 1] {
            guard let fireDate = Calendar.current.date(byAdding: .day, value: -daysOffset, to: expiry),
                  fireDate > Date() else { continue }

            var components = Calendar.current.dateComponents([.year, .month, .day], from: fireDate)
            components.hour   = UserDefaults.standard.object(forKey: "notificationHour")   as? Int ?? 9
            components.minute = UserDefaults.standard.object(forKey: "notificationMinute") as? Int ?? 0

            let content = UNMutableNotificationContent()
            content.title = lang.notificationExpiryTitle
            content.body = daysOffset == 1
                ? lang.notificationExpiresTomorrow(ingredientName)
                : lang.notificationExpiresInDays(ingredientName, daysOffset)
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(item.notificationToken)-\(daysOffset)d",
                content: content,
                trigger: trigger
            )
            center.add(request) { _ in }
        }
    }

    func cancelNotifications(for item: StorageItem) {
        let ids = ["\(item.notificationToken)-2d", "\(item.notificationToken)-1d"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
