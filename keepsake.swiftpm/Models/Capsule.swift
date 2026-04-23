import Foundation
import SwiftData
import SwiftUI

@Model
final class TimeCapsule {


    var id: UUID
    var name: String
    var milestoneTypeRaw: String
    var createdDate: Date
    var isSealed: Bool
    var accentColorHex: String
    var sealedDate: Date?
    var anniversaryDate: Date?
    var anniversaryMessage: String?
    var reunionDate: Date?
    var isReunion: Bool = false
    
    @Relationship(deleteRule: .cascade)
    var reminders: [CapsuleReminder] = []

    @Relationship(deleteRule: .cascade, inverse: \Memory.capsule)
    var memories: [Memory]



    init(
        name: String,
        milestoneType: MilestoneType,
        accentColorHex: String = "#A78BFA"
    ) {
        self.id = UUID()
        self.name = name
        self.milestoneTypeRaw = milestoneType.rawValue
        self.createdDate = .now
        self.isSealed = false
        self.accentColorHex = accentColorHex
        self.memories = []
    }

    var milestoneType: MilestoneType {
        get { MilestoneType(rawValue: milestoneTypeRaw) ?? .other }
        set { milestoneTypeRaw = newValue.rawValue }
    }

    var accentColor: Color {
        Color(hex: accentColorHex)
    }

    var memoryCount: Int {
        memories.count
    }
    var formattedDate: String {
        createdDate.formatted(date: .abbreviated, time: .omitted)
    }
    var distinctEmotions: [Emotion] {
        let raw = Set(memories.compactMap { Emotion(rawValue: $0.emotionRaw) })
        
        return Emotion.allCases.filter { raw.contains($0) }
    }
}
