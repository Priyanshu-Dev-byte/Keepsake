import SwiftUI

struct EmotionFocusCardView: View {
    let capsule: TimeCapsule
    let format: CardFormat

    private var cardSize: CGSize { format.size }
    private var scale: CGFloat { cardSize.width / 1080 }
    private var isStory: Bool { format == .story }

    private var dominantEmotion: Emotion {
        var counts: [Emotion: Int] = [:]
        for memory in capsule.memories {
            counts[memory.emotion, default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key ?? .joy
    }

    private var spacedName: String {
        dominantEmotion.displayName
            .uppercased()
            .map(String.init)
            .joined(separator: " ")
    }

    private var firstPhoto: UIImage? {
        capsule.memories
            .flatMap { $0.photosData }
            .first
            .flatMap { UIImage(data: $0) }
    }

    private var firstNote: String? {
        capsule.memories.first(where: { !$0.textNote.isEmpty })?.textNote
    }

    var body: some View {
        let emotion = dominantEmotion

        ZStack {
            Color(hex: "#0D0D1A")

            LinearGradient(
                colors: [
                    emotion.cardColor.opacity(0.8),
                    emotion.cardColor.opacity(0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                Spacer().frame(height: isStory ? 140 * scale : 60 * scale)

                Text(emotion.emoji)
                    .font(.system(size: 72 * scale))

                Spacer().frame(height: isStory ? 30 * scale : 16 * scale)

                Text(spacedName)
                    .font(.system(size: 28 * scale, weight: .bold))
                    .foregroundStyle(.white)
                    .tracking(4 * scale)

                Spacer().frame(height: isStory ? 50 * scale : 30 * scale)

                Rectangle()
                    .fill(.white.opacity(0.3))
                    .frame(width: 200 * scale, height: 1.5 * scale)

                Spacer().frame(height: isStory ? 50 * scale : 30 * scale)

                if let photo = firstPhoto {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: cardSize.width * 0.4,
                            height: cardSize.width * 0.4
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20 * scale))
                } else {
                    RoundedRectangle(cornerRadius: 20 * scale)
                        .fill(emotion.cardColor.opacity(0.3))
                        .frame(
                            width: cardSize.width * 0.4,
                            height: cardSize.width * 0.4
                        )
                        .overlay {
                            Image(systemName: emotion.systemImage)
                                .font(.system(size: 48 * scale))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                }

                Spacer().frame(height: isStory ? 40 * scale : 24 * scale)

                Text(capsule.name)
                    .font(.system(size: 32 * scale, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 60 * scale)

                if let note = firstNote {
                    Spacer().frame(height: 12 * scale)
                    Text("\"\(note)\"")
                        .font(.system(size: 20 * scale))
                        .foregroundStyle(.white.opacity(0.7))
                        .italic()
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal, 60 * scale)
                }

                Spacer()

                Text("Made with Vesper")
                    .font(.system(size: 18 * scale, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 30 * scale)
                    .padding(.bottom, 30 * scale)
            }
        }
        .frame(width: cardSize.width, height: cardSize.height)
        .clipped()
    }
}
