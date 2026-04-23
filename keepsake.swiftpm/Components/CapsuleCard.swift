import SwiftUI

struct CapsuleCard: View {
    let capsule: TimeCapsule
    @State private var appeared = false

    var memoryCount: Int { capsule.memories.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Top — constellation mini preview
            ZStack {
                // Background gradient from accent color
                LinearGradient(
                    colors: [
                        Color(hex: capsule.accentColorHex)
                            .opacity(0.6),
                        Color(hex: "0D0D1A")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Mini star dots (decorative)
                MiniConstellationPreview(
                    memories: capsule.memories,
                    accentColor: Color(
                        hex: capsule.accentColorHex
                    )
                )
                .padding(12)

                // Sealed badge
                if capsule.isSealed {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "seal.fill")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(8)
                                .glassEffect(
                                    .regular,
                                    in: .circle
                                )
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            }
            .frame(height: 120)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 16,
                    topTrailingRadius: 16
                )
            )

            // Bottom — info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(
                        systemName: capsule.milestoneType.systemImage
                    )
                    .font(.caption)
                    .foregroundStyle(
                        Color(hex: capsule.accentColorHex)
                    )
                    Text(capsule.milestoneType.displayName)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Text(capsule.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "sparkle")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                    Text(
                        memoryCount == 0
                            ? "No memories yet"
                            : "\(memoryCount) memor\(memoryCount == 1 ? "y" : "ies")"
                    )
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "1A1B2E"))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: Color(hex: capsule.accentColorHex)
                .opacity(0.2),
            radius: 12
        )
        .scaleEffect(appeared ? 1.0 : 0.95)
        .opacity(appeared ? 1.0 : 0)
        .onAppear {
            withAnimation(
                .spring(response: 0.4, dampingFraction: 0.8)
            ) {
                appeared = true
            }
        }
    }
}

struct MiniConstellationPreview: View {
    let memories: [Memory]
    let accentColor: Color

    var body: some View {
        GeometryReader { geo in
            ForEach(
                Array(memories.prefix(8).enumerated()),
                id: \.offset
            ) { index, memory in
                let pos = miniStarPosition(
                    for: index,
                    total: min(memories.count, 8),
                    in: geo.size
                )
                Circle()
                    .fill(memory.emotion.color)
                    .frame(width: 4, height: 4)
                    .shadow(
                        color: memory.emotion.color,
                        radius: 3
                    )
                    .position(pos)
            }
        }
    }

    private func miniStarPosition(
        for index: Int,
        total: Int,
        in size: CGSize
    ) -> CGPoint {
        let hash1 = abs(index * 2654435761) % 10000
        let hash2 = abs(index * 1234567891) % 10000
        return CGPoint(
            x: CGFloat(hash1) / 10000 * size.width,
            y: CGFloat(hash2) / 10000 * size.height
        )
    }
}
