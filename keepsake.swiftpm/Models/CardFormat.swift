import Foundation

enum CardFormat: String, CaseIterable, Identifiable, Sendable {
    case story
    case square

    var id: String { rawValue }

    var label: String {
        switch self {
        case .story:  "Story 9:16"
        case .square: "Square 1:1"
        }
    }

    var size: CGSize {
        switch self {
        case .story:  CGSize(width: 1080, height: 1920)
        case .square: CGSize(width: 1080, height: 1080)
        }
    }
}
