import Foundation
import SwiftData

@Model
final class CapsuleReminder {
    var id: UUID
    var title: String
    var reminderDate: Date
    var message: String
    var isDelivered: Bool
    
    @Relationship(inverse: \TimeCapsule.reminders)
    var capsule: TimeCapsule?
    
    init(
        title: String,
        reminderDate: Date,
        message: String = ""
    ) {
        self.id = UUID()
        self.title = title
        self.reminderDate = reminderDate
        self.message = message
        self.isDelivered = false
    }
}
