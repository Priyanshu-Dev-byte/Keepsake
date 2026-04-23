import SwiftUI

struct BackgroundStarsView: View {
    let dots: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = {
        var result: [(CGFloat, CGFloat, CGFloat, Double)] = []
        var seed = 42
        for _ in 0..<80 {
            seed = seed &* 1664525 &+ 1013904223
            let x = CGFloat(abs(seed) % 1000) / 10.0
            seed = seed &* 1664525 &+ 1013904223
            let y = CGFloat(abs(seed) % 1000) / 10.0
            seed = seed &* 1664525 &+ 1013904223
            let size = CGFloat(abs(seed) % 3) / 10.0 + 0.8
            seed = seed &* 1664525 &+ 1013904223
            let opacity = Double(abs(seed) % 50) / 100.0 + 0.1
            result.append((x, y, size, opacity))
        }
        return result
    }()

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<dots.count, id: \.self) { i in
                let dot = dots[i]
                Circle()
                    .fill(.white.opacity(dot.opacity))
                    .frame(width: dot.size, height: dot.size)
                    .position(
                        x: dot.x / 100 * geo.size.width,
                        y: dot.y / 100 * geo.size.height
                    )
            }
        }
    }
}
