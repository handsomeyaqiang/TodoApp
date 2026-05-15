import UserNotifications
import Foundation

final class NotificationService: @unchecked Sendable {
    static let shared = NotificationService()
    private init() {}

    @discardableResult
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else {
            return settings.authorizationStatus == .authorized
        }
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// 调度本地通知，幂等：先取消旧通知再创建新的。返回新 notificationID。
    @discardableResult
    func scheduleNotification(for item: TodoItem) async -> String? {
        guard let reminderDate = item.reminderDate, reminderDate > .now else { return nil }

        // 取消旧通知
        if let oldID = item.notificationID {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [oldID])
        }

        let content = UNMutableNotificationContent()
        content.title = item.title
        content.body = item.notes.isEmpty ? "待办事项提醒" : String(item.notes.prefix(60))
        content.sound = .default
        content.userInfo = ["itemID": item.id.uuidString]

        var components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: reminderDate
        )
        components.second = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let id = UUID().uuidString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
            return id
        } catch {
            return nil
        }
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    func cancelNotifications(ids: [String]) {
        guard !ids.isEmpty else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
