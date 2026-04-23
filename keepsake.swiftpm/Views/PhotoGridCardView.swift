import SwiftUI

struct PhotoGridCardView: View {
    let capsule: TimeCapsule
    let format: CardFormat

    private var cardSize: CGSize { format.size }
    private var scale: CGFloat { cardSize.width / 1080 }
    private var isStory: Bool { format == .story }

    private var photos: [UIImage] {
        capsule.memories
            .flatMap { $0.photosData }
            .prefix(4)
            .compactMap { UIImage(data: $0) }
    }

    private var emotionCounts: [(emotion: Emotion, count: Int)] {
        var counts: [Emotion: Int] = [:]
        for memory in capsule.memories {
            counts[memory.emotion, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }
            .map { (emotion: $0.key, count: $0.value) }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#0D0D1A"), Color(hex: "#1A1A2E")],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                Spacer().frame(height: isStory ? 80 * scale : 50 * scale)

                Text(capsule.name)
                    .font(.system(size: 48 * scale, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40 * scale)

                Spacer().frame(height: isStory ? 60 * scale : 30 * scale)

                photoGrid
                    .padding(.horizontal, 40 * scale)

                Spacer().frame(height: isStory ? 50 * scale : 24 * scale)

                emotionPills
                    .padding(.horizontal, 40 * scale)

                Spacer().frame(height: isStory ? 40 * scale : 20 * scale)

                metadataRow
                    .padding(.horizontal, 40 * scale)

                Spacer()

                watermark
                    .padding(.trailing, 30 * scale)
                    .padding(.bottom, 30 * scale)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .frame(width: cardSize.width, height: cardSize.height)
        .clipped()
    }

    private var photoGrid: some View {
        let gridSpacing: CGFloat = 8 * scale
        let gridWidth = cardSize.width - 80 * scale
        let cellSize = (gridWidth - gridSpacing) / 2

        return VStack(spacing: gridSpacing) {
            HStack(spacing: gridSpacing) {
                gridCell(index: 0, size: cellSize)
                gridCell(index: 1, size: cellSize)
            }
            HStack(spacing: gridSpacing) {
                gridCell(index: 2, size: cellSize)
                gridCell(index: 3, size: cellSize)
            }
        }
    }

    @ViewBuilder
    private func gridCell(index: Int, size: CGFloat) -> some View {
        if index < photos.count {
            Image(uiImage: photos[index])
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 16 * scale))
        } else {
            let emotion = emotionCounts.first?.emotion ?? .joy
            RoundedRectangle(cornerRadius: 16 * scale)
                .fill(
                    LinearGradient(
                        colors: [emotion.cardColor.opacity(0.6), emotion.cardColor.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
        }
    }

    private var emotionPills: some View {
        HStack(spacing: 10 * scale) {
            ForEach(emotionCounts.prefix(3), id: \.emotion) { item in
                HStack(spacing: 6 * scale) {
                    Text(item.emotion.emoji)
                        .font(.system(size: 18 * scale))
                    Text(item.emotion.displayName)
                        .font(.system(size: 18 * scale, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16 * scale)
                .padding(.vertical, 10 * scale)
                .background(
                    Capsule()
                        .fill(item.emotion.cardColor.opacity(0.3))
                )
            }
        }
    }

    private var metadataRow: some View {
        VStack(spacing: 8 * scale) {
            Text("\(capsule.memories.count) memories")
                .font(.system(size: 24 * scale, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))

            if let sealedDate = capsule.sealedDate {
                Text("Sealed \(sealedDate.formatted(.dateTime.month(.wide).year()))")
                    .font(.system(size: 20 * scale))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

    private var watermark: some View {
        Text("Made with Vesper")
            .font(.system(size: 18 * scale, weight: .medium))
            .foregroundStyle(.white.opacity(0.6))
    }
}
