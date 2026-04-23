import SwiftUI

enum MilestoneType: String, Codable, CaseIterable, Identifiable, Sendable {
    case graduation
    case birthday
    case familyTrip
    case reunion
    case wedding
    case achievement
    case other

    var id: String { rawValue }


    var displayName: String {
        switch self {
        case .graduation:  "Graduation"
        case .birthday:    "Birthday"
        case .familyTrip:  "Family Trip"
        case .reunion:     "Reunion"
        case .wedding:     "Wedding"
        case .achievement: "Achievement"
        case .other:       "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .graduation:  "graduationcap.fill"
        case .birthday:    "birthday.cake.fill"
        case .familyTrip:  "airplane"
        case .reunion:     "person.3.fill"
        case .wedding:     "heart.circle.fill"
        case .achievement: "trophy.fill"
        case .other:       "sparkles"
        }
    }

    var tagline: String {
        switch self {
        case .graduation:  "A chapter closes, a story begins"
        case .birthday:    "Another trip around the sun"
        case .familyTrip:  "Miles traveled, memories made"
        case .reunion:     "Together again, just like before"
        case .wedding:     "Two hearts, one journey"
        case .achievement: "Hard work, sweet reward"
        case .other:       "A moment worth keeping"
        }
    }



    var primaryColor: Color {
        switch self {
        case .graduation:  Color(hex: "#D4A843")
        case .birthday:    Color(hex: "#FF7EB3")
        case .familyTrip:  Color(hex: "#7EC8E3")
        case .reunion:     Color(hex: "#D4915E")
        case .wedding:     Color(hex: "#F5E6D3")
        case .achievement: Color(hex: "#50C878")
        case .other:       Color(hex: "#A78BFA")
        }
    }
    var secondaryColor: Color {
        switch self {
        case .graduation:  Color(hex: "#8B6914")
        case .birthday:    Color(hex: "#FF4081")
        case .familyTrip:  Color(hex: "#4A90D9")
        case .reunion:     Color(hex: "#A0522D")
        case .wedding:     Color(hex: "#FADADD")
        case .achievement: Color(hex: "#C0C0C0")
        case .other:       Color(hex: "#7C3AED")
        }
    }

    var meshColors: [Color] {
        [primaryColor, secondaryColor, primaryColor.opacity(0.6), secondaryColor.opacity(0.4)]
    }



   
    enum SealAnimationStyle: Sendable {
        case scrollRollUp
        case confettiBurst
        case boardingPassFold
        case waxSeal        
    }

    var sealAnimationStyle: SealAnimationStyle {
        switch self {
        case .graduation:  .scrollRollUp
        case .birthday:    .confettiBurst
        case .familyTrip:  .boardingPassFold
        default:           .waxSeal
        }
    }
}
