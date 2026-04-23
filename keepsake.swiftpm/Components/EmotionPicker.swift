import SwiftUI

struct EmotionPicker: View {
    @Binding var selectedEmotion: Emotion?
    var compact: Bool = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: compact ? 8 : 12) {
                ForEach(Emotion.allCases) { emotion in
                    emotionPill(emotion)
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func emotionPill(_ emotion: Emotion) -> some View {
        let isSelected = selectedEmotion == emotion

        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedEmotion = emotion
            }
            HapticManager.selection()
        } label: {
            HStack(spacing: compact ? 4 : 6) {
                Image(systemName: emotion.systemImage)
                    .font(compact ? .caption : .subheadline)
                    .foregroundStyle(isSelected ? .white : emotion.color)

                if !compact {
                    Text(emotion.displayName)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(isSelected ? .white : .primary)
                }
            }
            .padding(.horizontal, compact ? 10 : 14)
            .padding(.vertical, compact ? 6 : 10)
            .background {
                Capsule()
                    .fill(isSelected ? emotion.color : Color(hex: "#1A1B2E"))
            }
            .overlay {
                Capsule()
                    .strokeBorder(
                        isSelected ? emotion.color : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            }
            .shadow(
                color: isSelected ? emotion.glowColor : .clear,
                radius: isSelected ? 8 : 0
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
