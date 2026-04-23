import SwiftUI

struct StarThumbnailView: View {
    let memory: Memory
    let photoIndex: Int
    let isSelected: Bool
    let isInSelectedCluster: Bool
    let isDimmed: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void

    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var glowOpacity: Double = 0.4
    @State private var glowRadius: CGFloat = 3
    @State private var scale: CGFloat = 1.0
    @State private var clusterPulse: CGFloat = 1.0

    var thumbnailSize: CGFloat {
        sizeClass == .regular ? 52 : 44
    }

    var emotionColor: Color { memory.emotion.color }

    var body: some View {
        ZStack {
            if isInSelectedCluster && !isSelected {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        memory.emotion.color.opacity(0.5),
                        lineWidth: 2
                    )
                    .frame(
                        width: thumbnailSize + 18,
                        height: thumbnailSize + 18
                    )
                    .shadow(
                        color: memory.emotion.color
                            .opacity(0.4),
                        radius: 8
                    )
                    // Animated pulse on cluster mates
                    .scaleEffect(clusterPulse)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 1.2)
                            .repeatForever(
                                autoreverses: true
                            )
                        ) {
                            clusterPulse = 1.08
                        }
                    }
            }

            thumbnailContent
                .frame(width: thumbnailSize,
                       height: thumbnailSize)
                .clipShape(
                    RoundedRectangle(cornerRadius: 10)
                )
                // ONE border only — emotion color
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            emotionColor.opacity(
                                isSelected ? 1.0 : 0.7
                            ),
                            lineWidth: isSelected ? 2.5 : 1.5
                        )
                )
                // Glow via shadow — NOT a second stroke
                .shadow(
                    color: emotionColor.opacity(glowOpacity),
                    radius: glowRadius
                )
                // Selected state — brighter glow only
                // NOT an additional border
                .shadow(
                    color: isSelected
                        ? emotionColor.opacity(0.6) : .clear,
                    radius: 12
                )

            // Selected indicator — small dot, bottom right
            if isSelected {
                Circle()
                    .fill(emotionColor)
                    .frame(width: 8, height: 8)
                    .shadow(color: emotionColor, radius: 4)
                    .offset(
                        x: thumbnailSize / 2 - 4,
                        y: thumbnailSize / 2 - 4
                    )
            }
        }
        .scaleEffect(scale)
        .opacity(isDimmed ? 0.25 : 1.0)
        .animation(.easeInOut(duration: 0.25), value: isDimmed)
        .animation(
            .spring(response: 0.3, dampingFraction: 0.65),
            value: isSelected
        )
        // Apple HIG — minimum 44x44 touch target
        .frame(
            width: max(thumbnailSize + 12, 44),
            height: max(thumbnailSize + 12, 44)
        )
        .contentShape(
            RoundedRectangle(cornerRadius: 10)
        )
        .onTapGesture {
            withAnimation(
                .spring(response: 0.25, dampingFraction: 0.5)
            ) { scale = 1.15 }
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.15
            ) {
                withAnimation(
                    .spring(response: 0.3, dampingFraction: 0.7)
                ) { scale = 1.0 }
            }
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0.4) {
            UIImpactFeedbackGenerator(style: .light)
                .impactOccurred()
            onLongPress()
        }
        .onAppear { startTwinkle() }
    }

    // Thumbnail content — photo or emotion icon
    @ViewBuilder
    var thumbnailContent: some View {
        if photoIndex < memory.photosData.count,
           let uiImage = UIImage(data: memory.photosData[photoIndex]) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            // No photo — emotion gradient square
            LinearGradient(
                colors: [
                    emotionColor.opacity(0.8),
                    emotionColor.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                Image(systemName: memory.emotion.systemImage)
                    .font(.system(
                        size: thumbnailSize * 0.38
                    ))
                    .foregroundStyle(.white)
            )
        }
    }

    // Unique twinkle rate per memory
    private func startTwinkle() {
        let duration = Double(
            abs(memory.id.hashValue % 1000)
        ) / 1000.0 * 1.5 + 1.5

        withAnimation(
            .easeInOut(duration: duration)
            .repeatForever(autoreverses: true)
        ) {
            glowRadius = isSelected ? 14 : 7
            glowOpacity = 0.9
        }
    }
}
