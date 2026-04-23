import SwiftUI

struct ThreadsCanvasView: View {
    let positions: [UUID: CGPoint]
    let memories: [Memory]
    let opacity: Double

    var connectionPairs: [(Memory, Memory)] {
        var pairs: [(Memory, Memory)] = []
        var addedPairs = Set<String>()

        for memory in memories {
            guard let pos = positions[memory.id] else { continue }

            let neighbours = memories
                .filter { $0.id != memory.id }
                .sorted { a, b in
                    guard let posA = positions[a.id],
                          let posB = positions[b.id]
                    else { return false }
                    return distance(from: pos, to: posA) < distance(from: pos, to: posB)
                }
                .prefix(2)

            for neighbour in neighbours {
                guard let posB = positions[neighbour.id] else { continue }
                let dist = distance(from: pos, to: posB)
                guard dist < 250 else { continue }

                let pairKey = [
                    memory.id.uuidString,
                    neighbour.id.uuidString
                ].sorted().joined()

                if !addedPairs.contains(pairKey) {
                    pairs.append((memory, neighbour))
                    addedPairs.insert(pairKey)
                }
            }
        }
        return pairs
    }

    var body: some View {
        Canvas { context, size in
            for (memA, memB) in connectionPairs {
                guard let posA = positions[memA.id],
                      let posB = positions[memB.id]
                else { continue }

                // Thread path — quadratic bezier for organic curve
                var path = Path()
                path.move(to: posA)

                let midX = (posA.x + posB.x) / 2
                let midY = (posA.y + posB.y) / 2
                let controlOffset: CGFloat = 20
                let controlPoint = CGPoint(
                    x: midX + controlOffset,
                    y: midY - controlOffset
                )
                path.addQuadCurve(to: posB, control: controlPoint)

                // Gradient stroke from emotion A → emotion B
                context.stroke(
                    path,
                    with: .linearGradient(
                        Gradient(colors: [
                            memA.emotion.color.opacity(0.35 * opacity),
                            memB.emotion.color.opacity(0.35 * opacity)
                        ]),
                        startPoint: posA,
                        endPoint: posB
                    ),
                    style: StrokeStyle(
                        lineWidth: 0.8,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )

                // Midpoint dot — subtle white circle
                let dotPos = CGPoint(
                    x: (posA.x + controlPoint.x + posB.x) / 3,
                    y: (posA.y + controlPoint.y + posB.y) / 3
                )
                let dotPath = Path(ellipseIn: CGRect(
                    x: dotPos.x - 1.5,
                    y: dotPos.y - 1.5,
                    width: 3,
                    height: 3
                ))
                context.fill(
                    dotPath,
                    with: .color(.white.opacity(0.2 * opacity))
                )
            }
        }
        .allowsHitTesting(false)
    }

    private func distance(from a: CGPoint, to b: CGPoint) -> CGFloat {
        sqrt(pow(b.x - a.x, 2) + pow(b.y - a.y, 2))
    }
}
