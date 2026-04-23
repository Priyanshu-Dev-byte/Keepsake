import SwiftUI

struct StarView: View {
    let emotion: Emotion
    var radius: CGFloat = 6
    var twinklePhase: Double = 0

    @State private var animationTime: Double = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let currentTime = timeline.date.timeIntervalSinceReferenceDate
                let opacity = 0.6 + 0.4 * sin(currentTime * 1.8 + twinklePhase)

                // Outer glow
                let outerGlow = context.resolve(
                    Image(systemName: "circle.fill")
                )
                let glowRect = CGRect(
                    x: center.x - radius * 2,
                    y: center.y - radius * 2,
                    width: radius * 4,
                    height: radius * 4
                )
                context.opacity = opacity * 0.3
                context.drawLayer { ctx in
                    ctx.addFilter(.blur(radius: radius))
                    ctx.draw(outerGlow, in: glowRect)
                }

                // Core star with radial gradient
                context.opacity = opacity
                let gradient = Gradient(colors: [
                    .white,
                    emotion.color,
                    emotion.color.opacity(0.3)
                ])
                context.fill(
                    Circle().path(in: CGRect(
                        x: center.x - radius,
                        y: center.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )),
                    with: .radialGradient(
                        gradient,
                        center: center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
            .frame(width: radius * 5, height: radius * 5)
        }
    }
}

struct MiniStarCluster: View {
    let emotions: [Emotion]
    var size: CGFloat = 32

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let count = emotions.count
            guard count > 0 else { return }

            for (index, emotion) in emotions.enumerated() {
                let angle = (Double(index) / Double(max(count, 1))) * .pi * 2 - .pi / 2
                let spreadRadius = min(canvasSize.width, canvasSize.height) * 0.28
                let x = center.x + cos(angle) * spreadRadius
                let y = center.y + sin(angle) * spreadRadius
                let starRadius: CGFloat = 3.5

                let gradient = Gradient(colors: [.white, emotion.color, emotion.color.opacity(0.2)])
                context.fill(
                    Circle().path(in: CGRect(
                        x: x - starRadius,
                        y: y - starRadius,
                        width: starRadius * 2,
                        height: starRadius * 2
                    )),
                    with: .radialGradient(gradient, center: CGPoint(x: x, y: y), startRadius: 0, endRadius: starRadius)
                )
            }
        }
        .frame(width: size, height: size)
    }
}
