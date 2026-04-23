import Foundation
import SwiftData
import SwiftUI

@Model
final class Memory {


    var id: UUID
    var textNote: String
    var emotionRaw: String
    var createdDate: Date

    @Attribute(.externalStorage)
    var photosData: [Data] = []
    
    var photoData: Data? { photosData.first }

    var capsule: TimeCapsule?

    init(
        textNote: String,
        emotion: Emotion,
        photosData: [Data] = [],
        capsule: TimeCapsule? = nil
    ) {
        self.id = UUID()
        self.textNote = textNote
        self.emotionRaw = emotion.rawValue
        self.createdDate = .now
        self.photosData = photosData
        self.capsule = capsule
    }

    var emotion: Emotion {
        get { Emotion(rawValue: emotionRaw) ?? .joy }
        set { emotionRaw = newValue.rawValue }
    }

    var emotionColor: Color {
        emotion.color
    }

    var hasPhoto: Bool {
        !photosData.isEmpty
    }

    var formattedDate: String {
        createdDate.formatted(date: .abbreviated, time: .shortened)
    }

    var notePreview: String {
        if textNote.count <= 80 {
            return textNote
        }
        return String(textNote.prefix(77)) + "…"
    }

    var capsuleName: String {
        capsule?.name ?? "Uncategorized"
    }
}
