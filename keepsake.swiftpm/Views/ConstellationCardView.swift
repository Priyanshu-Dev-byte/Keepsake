import SwiftUI

struct ConstellationCardView: View {
    let capsule: TimeCapsule
    let format: CardFormat

    private var cardSize: CGSize { format.size }
    private var scale: CGFloat { cardSize.width / 1080 }
    private var isStory: Bool { format == .story }

    private var emotionCounts: [(emotion: Emotion, count: Int)] {
        var counts: [Emotion: Int] = [:]
        for memory in capsule.memories {
            counts[memory.emotion, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }
            .map { (emotion: $0.key, count: $0.value) }
    }

    private var distinctEmotionCount: Int {
        Set(capsule.memories.map { $0.emotionRaw }).count
    }

    private func seededPositions(count: Int, in rect: CGRect) -> [(CGPoint, Emotion)] {
        let uuidStr = capsule.id.uuidString.replacingOccurrences(of: "-", with: "")
        var seed: UInt64 = 0
        for (i, char) in uuidStr.unicodeScalars.enumerated() {
            seed = seed &+ UInt64(char.value) &* UInt64(i &+ 1)
        }

        var positions: [(CGPoint, Emotion)] = []
        let memories = capsule.memories

        for i in 0..<count {
            let idx = i < memories.count ? i : i % max(memories.count, 1)
            let emotion = idx < memories.count ? memories[idx].emotion : .joy

            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            let x = rect.minX + CGFloat(seed % 10000) / 10000.0 * rect.width
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            let y = rect.minY + CGFloat(seed % 10000) / 10000.0 * rect.height

            positions.append((CGPoint(x: x, y: y), emotion))
        }
        return positions
    }

    var body: some View {
        let bgColor = Color(hex: "#0D0D1A")

        ZStack {
            bgColor

            VStack(spacing: 0) {
                Spacer().frame(height: isStory ? 80 * scale : 50 * scale)

                Text(capsule.name)
                    .font(.system(size: 48 * scale, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40 * scale)

                Spacer().frame(height: isStory ? 40 * scale : 20 * scale)

                constellationCanvas
                    .frame(height: isStory ? 900 * scale : 550 * scale)
                    .padding(.horizontal, 40 * scale)

                Spacer().frame(height: isStory ? 40 * scale : 20 * scale)

                HStack(spacing: 30 * scale) {
                    statLabel("\(capsule.memories.count) memories")
                    statLabel("\(distinctEmotionCount) emotions")
                }

                Spacer().frame(height: isStory ? 40 * scale : 20 * scale)

                Text("Your milestones, written in stars")
                    .font(.system(size: 24 * scale, weight: .medium))
                    .italic()
                    .foregroundStyle(.white.opacity(0.6))

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

    private func statLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 24 * scale, weight: .medium))
            .foregroundStyle(.white.opacity(0.7))
    }

    private var constellationCanvas: some View {
        Canvas { context, size in
            let padding: CGFloat = 30 * scale
            let starRect = CGRect(
                x: padding,
                y: padding,
                width: size.width - padding * 2,
                height: size.height - padding * 2
            )

            let starCount = min(capsule.memories.count, 30)
            guard starCount > 0 else { return }

            let stars = seededPositions(count: starCount, in: starRect)

            for i in 0..<stars.count - 1 {
                let from = stars[i].0
                let to = stars[i + 1].0

                var path = Path()
                path.move(to: from)
                path.addLine(to: to)

                context.stroke(
                    path,
                    with: .color(.white.opacity(0.15)),
                    lineWidth: 1.5 * scale
                )
            }

            if stars.count >= 3 {
                let last = stars[stars.count - 1].0
                let first = stars[0].0
                var path = Path()
                path.move(to: last)
                path.addLine(to: first)
                context.stroke(
                    path,
                    with: .color(.white.opacity(0.1)),
                    lineWidth: 1.0 * scale
                )
            }

            for (point, emotion) in stars {
                let starColor = emotion.cardColor
                let glowRadius: CGFloat = 20 * scale
                let starRadius: CGFloat = 6 * scale

                let glowRect = CGRect(
                    x: point.x - glowRadius,
                    y: point.y - glowRadius,
                    width: glowRadius * 2,
                    height: glowRadius * 2
                )
                context.fill(
                    Path(ellipseIn: glowRect),
                    with: .radialGradient(
                        Gradient(colors: [starColor.opacity(0.5), starColor.opacity(0)]),
                        center: point,
                        startRadius: 0,
                        endRadius: glowRadius
                    )
                )

                let dotRect = CGRect(
                    x: point.x - starRadius,
                    y: point.y - starRadius,
                    width: starRadius * 2,
                    height: starRadius * 2
                )
                context.fill(
                    Path(ellipseIn: dotRect),
                    with: .color(starColor)
                )
            }
        }
    }
}
