import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() async {
        do {
            try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Failed to request notification permission: \(error)")
        }
    }
    
    func scheduleAnniversaryReminder(for capsule: TimeCapsule) {
        cancelAnniversaryReminder(for: capsule)
        
        guard let anniversaryDate = capsule.anniversaryDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🌟 \(capsule.name) Anniversary"
        
        if let msg = capsule.anniversaryMessage, !msg.trimmingCharacters(in: .whitespaces).isEmpty {
            content.body = msg
        } else {
            content.body = "Today marks another year. Relive how it felt."
        }
        
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.month, .day], from: anniversaryDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: capsule.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling anniversary notification: \(error)")
            }
        }
    }
    
    func cancelAnniversaryReminder(for capsule: TimeCapsule) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [capsule.id.uuidString])
    }
    
    func scheduleReminder(reminder: CapsuleReminder, capsule: TimeCapsule) {
        cancelReminder(reminder: reminder)
        
        guard reminder.reminderDate > .now else { return }
        
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.message.trimmingCharacters(in: .whitespaces).isEmpty
            ? "You have a reminder for \(capsule.name)"
            : reminder.message
        content.sound = .default
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminder.reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "reminder-\(reminder.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling general reminder: \(error)")
            }
        }
    }
    
    func cancelReminder(reminder: CapsuleReminder) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["reminder-\(reminder.id.uuidString)"])
    }
    
    func cancelAllReminders(for capsule: TimeCapsule) {
        let identifiers = capsule.reminders.map { "reminder-\($0.id.uuidString)" }
        if !identifiers.isEmpty {
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    // MARK: - Reunion Reminders

    func scheduleReunionReminder(for capsule: TimeCapsule) {
        cancelReunionReminder(for: capsule)

        guard capsule.isReunion,
              let reunionDate = capsule.reunionDate
        else { return }

        let content = UNMutableNotificationContent()
        content.title = "🤝 Vesper — \(capsule.name)"
        content.body = "It's been a year since your reunion. Relive the moment."
        content.sound = .default
        content.userInfo = [
            "capsuleID": capsule.id.uuidString,
            "type": "reunion"
        ]

        var components = Calendar.current.dateComponents([.month, .day], from: reunionDate)
        components.hour = 9
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: "reunion-\(capsule.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling reunion notification: \(error)")
            }
        }
    }

    func cancelReunionReminder(for capsule: TimeCapsule) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: ["reunion-\(capsule.id.uuidString)"]
            )
    }
}
