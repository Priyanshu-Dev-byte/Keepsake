import Foundation

enum CardStyle: String, CaseIterable, Identifiable, Sendable {
    case photoGrid
    case constellation
    case emotionFocus

    var id: String { rawValue }

    var label: String {
        switch self {
        case .photoGrid:     "Grid"
        case .constellation: "Stars"
        case .emotionFocus:  "Emotion"
        }
    }
}
