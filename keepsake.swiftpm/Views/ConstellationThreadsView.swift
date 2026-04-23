import SwiftUI

struct ConstellationThreadsView: View {
    let clusters: [MemoryCluster]
    let opacity: Double

    var body: some View {
        Canvas { context, size in

            for cluster in clusters {
                guard cluster.isCluster else { continue }

                let positions = Array(
                    cluster.starPositions.values
                )
                let color = cluster.memory.emotion.color

                for i in 0..<positions.count {
                    for j in (i+1)..<positions.count {
                        let posA = positions[i]
                        let posB = positions[j]

                        var path = Path()
                        path.move(to: posA)

                        let mid = CGPoint(
                            x: (posA.x + posB.x) / 2,
                            y: (posA.y + posB.y) / 2
                                - 8
                        )
                        path.addQuadCurve(
                            to: posB,
                            control: mid
                        )

                        context.stroke(
                            path,
                            with: .color(
                                color.opacity(
                                    0.55 * opacity
                                )
                            ),
                            style: StrokeStyle(
                                lineWidth: 1.2,
                                lineCap: .round
                            )
                        )

                        let dotRect = CGRect(
                            x: mid.x - 2,
                            y: mid.y - 2,
                            width: 4,
                            height: 4
                        )
                        context.fill(
                            Path(ellipseIn: dotRect),
                            with: .color(
                                color.opacity(
                                    0.35 * opacity
                                )
                            )
                        )
                    }
                }

                if cluster.photoCount >= 3 {
                    let center = cluster.center
                    let radius = clusterBoundaryRadius(
                        for: cluster.photoCount
                    )
                    let ringPath = Path(ellipseIn: CGRect(
                        x: center.x - radius,
                        y: center.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    ))
                    context.stroke(
                        ringPath,
                        with: .color(
                            color.opacity(0.1 * opacity)
                        ),
                        style: StrokeStyle(
                            lineWidth: 1,
                            dash: [4, 8]
                        )
                    )
                }
            }

            var drawnPairs = Set<String>()

            for cluster in clusters {
                let centerA = cluster.center
                guard centerA != .zero else { continue }

                let nearest = clusters
                    .filter { $0.id != cluster.id
                        && $0.center != .zero }
                    .sorted { a, b in
                        dist(centerA, a.center)
                            < dist(centerA, b.center)
                    }
                    .prefix(2)

                for neighbour in nearest {
                    let centerB = neighbour.center

                    let key = [
                        cluster.id.uuidString,
                        neighbour.id.uuidString
                    ].sorted().joined()
                    guard !drawnPairs.contains(key)
                    else { continue }
                    drawnPairs.insert(key)

                    let distance = dist(centerA, centerB)
                    guard distance < 280 else { continue }

                    var path = Path()
                    path.move(to: centerA)

                    let cp1 = CGPoint(
                        x: centerA.x
                            + (centerB.x - centerA.x) * 0.35,
                        y: centerA.y - 30
                    )
                    let cp2 = CGPoint(
                        x: centerA.x
                            + (centerB.x - centerA.x) * 0.65,
                        y: centerB.y + 30
                    )
                    path.addCurve(
                        to: centerB,
                        control1: cp1,
                        control2: cp2
                    )

                    context.stroke(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [
                                cluster.memory.emotion.color
                                    .opacity(0.22 * opacity),
                                neighbour.memory.emotion.color
                                    .opacity(0.22 * opacity)
                            ]),
                            startPoint: centerA,
                            endPoint: centerB
                        ),
                        style: StrokeStyle(
                            lineWidth: 0.7,
                            lineCap: .round
                        )
                    )

                    let midX = (centerA.x + centerB.x) / 2
                    let midY = (centerA.y + centerB.y) / 2
                    let dotRect = CGRect(
                        x: midX - 1.5,
                        y: midY - 1.5,
                        width: 3,
                        height: 3
                    )
                    context.fill(
                        Path(ellipseIn: dotRect),
                        with: .color(
                            .white.opacity(0.15 * opacity)
                        )
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func dist(
        _ a: CGPoint,
        _ b: CGPoint
    ) -> CGFloat {
        sqrt(pow(b.x - a.x, 2) + pow(b.y - a.y, 2))
    }

    private func clusterBoundaryRadius(
        for count: Int
    ) -> CGFloat {
        switch count {
        case 3: return 72
        case 4: return 78
        case 5: return 84
        default: return 90
        }
    }
}
