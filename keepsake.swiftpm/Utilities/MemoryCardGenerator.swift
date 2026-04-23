import SwiftUI


@MainActor
final class MemoryCardGenerator {
 
    static func generate(
        capsule: TimeCapsule,
        style: CardStyle,
        format: CardFormat
    ) async -> UIImage? {
        let view = cardView(capsule: capsule, style: style, format: format)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        return renderer.uiImage
    }

    @ViewBuilder
    private static func cardView(
        capsule: TimeCapsule,
        style: CardStyle,
        format: CardFormat
    ) -> some View {
        switch style {
        case .photoGrid:
            PhotoGridCardView(capsule: capsule, format: format)
        case .constellation:
            ConstellationCardView(capsule: capsule, format: format)
        case .emotionFocus:
            EmotionFocusCardView(capsule: capsule, format: format)
        }
    }
}
