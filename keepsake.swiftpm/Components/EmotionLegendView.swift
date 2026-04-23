import SwiftUI

struct EmotionLegendView: View {
    let onEmotionFilter: (Emotion?) -> Void
    @State private var selectedEmotion: Emotion? = nil
    @Namespace private var legendNamespace

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            GlassEffectContainer {
                HStack(spacing: 6) {
                    ForEach(Emotion.allCases) { emotion in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                if selectedEmotion == emotion {
                                    selectedEmotion = nil
                                    onEmotionFilter(nil)
                                } else {
                                    selectedEmotion = emotion
                                    onEmotionFilter(emotion)
                                }
                            }
                            HapticManager.selection()
                        } label: {
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(emotion.color)
                                    .frame(width: 7, height: 7)
                                if selectedEmotion == emotion {
                                    Text(emotion.displayName)
                                        .font(.caption2.bold())
                                        .foregroundStyle(.white)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                        }
                        .glassEffect(
                            selectedEmotion == emotion
                                ? .regular.tint(emotion.color.opacity(0.4)).interactive()
                                : .regular.interactive(),
                            in: .capsule
                        )
                        .glassEffectID("legend-\(emotion.rawValue)", in: legendNamespace)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
        }
        .scrollIndicators(.hidden)
    }
}
