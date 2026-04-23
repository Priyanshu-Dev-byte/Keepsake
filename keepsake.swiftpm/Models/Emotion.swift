import SwiftUI

// MARK: - Emotion
/// Represents the primary emotion tagged to a memory.
/// Each case carries a unique color palette, SF Symbol icon, and emoji
/// used throughout the app — from the emotion picker to constellation stars.
enum Emotion: String, Codable, CaseIterable, Identifiable, Sendable {
    case joy
    case nostalgia
    case pride
    case love
    case bittersweet
    case hope

    var id: String { rawValue }


    var displayName: String {
        switch self {
        case .joy:         "Joy"
        case .nostalgia:   "Nostalgia"
        case .pride:       "Pride"
        case .love:        "Love"
        case .bittersweet: "Bittersweet"
        case .hope:        "Hope"
        }
    }

    var emoji: String {
        switch self {
        case .joy:         "🌟"
        case .nostalgia:   "💜"
        case .pride:       "🔵"
        case .love:        "❤️"
        case .bittersweet: "🩶"
        case .hope:        "🌿"
        }
    }

    var systemImage: String {
        switch self {
        case .joy:         "sun.max.fill"
        case .nostalgia:   "moon.stars.fill"
        case .pride:       "shield.fill"
        case .love:        "heart.fill"
        case .bittersweet: "cloud.rain.fill"
        case .hope:        "leaf.fill"
        }
    }

    var color: Color {
        Color(hex: hexValue)
    }

    var hexValue: String {
        switch self {
        case .joy:         "#FFD700"
        case .nostalgia:   "#9B72CF"
        case .pride:       "#4A90D9"
        case .love:        "#FF6B8A"
        case .bittersweet: "#7B8FA1"
        case .hope:        "#52B788"
        }
    }

    var cardHexValue: String {
        switch self {
        case .joy:         "#FFD700"
        case .love:        "#FF6B9D"
        case .pride:       "#A78BFA"
        case .nostalgia:   "#60A5FA"
        case .hope:        "#34D399"
        case .bittersweet: "#FB923C"
        }
    }

    var cardColor: Color {
        Color(hex: cardHexValue)
    }

    var glowColor: Color {
        color.opacity(0.45)
    }

    var descriptor: String {
        switch self {
        case .joy:         "A moment of pure radiance"
        case .nostalgia:   "A gentle ache for what was"
        case .pride:       "Standing tall in your story"
        case .love:        "A warmth that never fades"
        case .bittersweet: "Beautiful and melancholy"
        case .hope:        "A seed of what's to come"
        }
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: Double
        switch hex.count {
        case 6: // RGB
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8)  & 0xFF) / 255.0
            b = Double(int        & 0xFF) / 255.0
        case 8: // ARGB
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8)  & 0xFF) / 255.0
            b = Double(int        & 0xFF) / 255.0
        default:
            r = 1; g = 1; b = 1
        }
        self.init(red: r, green: g, blue: b)
    }
}
