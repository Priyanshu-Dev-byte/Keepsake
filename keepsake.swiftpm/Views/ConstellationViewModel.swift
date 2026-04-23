import SwiftUI

@Observable
@MainActor
final class ConstellationViewModel {

    var memories: [Memory] = []
    var clusters: [MemoryCluster] = []
    var starNodes: [StarNode] = []
    var selectedMemory: Memory? = nil
    var showMemorySheet = false
    var tooltipMemoryID: UUID? = nil

    func buildClusters(
        for memories: [Memory],
        in size: CGSize
    ) {
        self.memories = memories

        var builtClusters: [MemoryCluster] = []
        var allNodes: [StarNode] = []

        let clusterPositions = assignClusterPositions(
            for: memories,
            in: size
        )

        for memory in memories {
            guard let clusterAnchor =
                clusterPositions[memory.id]
            else { continue }

            let photos = memory.photosData
                .compactMap { UIImage(data: $0) }

            if photos.isEmpty { continue }

            var starPositions: [UUID: CGPoint] = [:]

            if photos.count == 1 {
                let node = StarNode(
                    memoryID: memory.id,
                    photoIndex: 0,
                    image: photos[0],
                    position: clusterAnchor
                )
                allNodes.append(node)
                starPositions[node.id] = clusterAnchor

            } else {
                let positions = clusterStarPositions(
                    count: photos.count,
                    anchor: clusterAnchor,
                    radius: clusterRadius(for: photos.count)
                )
                for (i, photo) in photos.enumerated() {
                    let pos = i < positions.count
                        ? positions[i] : clusterAnchor
                    let node = StarNode(
                        memoryID: memory.id,
                        photoIndex: i,
                        image: photo,
                        position: pos
                    )
                    allNodes.append(node)
                    starPositions[node.id] = pos
                }
            }

            let cluster = MemoryCluster(
                id: memory.id,
                memory: memory,
                starPositions: starPositions
            )
            builtClusters.append(cluster)
        }

        self.clusters = builtClusters
        self.starNodes = allNodes
    }

    private func clusterRadius(for count: Int) -> CGFloat {
        switch count {
        case 2: return 52
        case 3: return 58
        case 4: return 62
        case 5: return 68
        default: return 72
        }
    }

    private func clusterStarPositions(
        count: Int,
        anchor: CGPoint,
        radius: CGFloat
    ) -> [CGPoint] {
        switch count {
        case 2:
            return [
                CGPoint(
                    x: anchor.x - radius * 0.6,
                    y: anchor.y
                ),
                CGPoint(
                    x: anchor.x + radius * 0.6,
                    y: anchor.y
                )
            ]

        case 3:
            return [
                CGPoint(
                    x: anchor.x,
                    y: anchor.y - radius * 0.65
                ),
                CGPoint(
                    x: anchor.x - radius * 0.65,
                    y: anchor.y + radius * 0.45
                ),
                CGPoint(
                    x: anchor.x + radius * 0.65,
                    y: anchor.y + radius * 0.45
                )
            ]

        case 4:
            return [
                CGPoint(x: anchor.x, y: anchor.y - radius),
                CGPoint(x: anchor.x + radius, y: anchor.y),
                CGPoint(x: anchor.x, y: anchor.y + radius),
                CGPoint(x: anchor.x - radius, y: anchor.y)
            ]

        case 5:
            return (0..<5).map { i in
                let angle = Double(i) * (2 * .pi / 5)
                    - .pi / 2
                return CGPoint(
                    x: anchor.x + radius
                        * CGFloat(cos(angle)),
                    y: anchor.y + radius
                        * CGFloat(sin(angle))
                )
            }

        default:
            return (0..<count).map { i in
                let angle = Double(i) * (2 * .pi
                    / Double(count))
                return CGPoint(
                    x: anchor.x + radius
                        * CGFloat(cos(angle)),
                    y: anchor.y + radius
                        * CGFloat(sin(angle))
                )
            }
        }
    }

    private func assignClusterPositions(
        for memories: [Memory],
        in size: CGSize
    ) -> [UUID: CGPoint] {
        var positions: [UUID: CGPoint] = [:]
        let padding: CGFloat = 80

        for memory in memories {
            let idStr = memory.id.uuidString
            let h1 = abs(idStr.hashValue)
            let h2 = abs(idStr.reversed()
                .description.hashValue)

            let availW = size.width - padding * 2
            let availH = size.height - padding * 2

            var pos = CGPoint(
                x: padding + CGFloat(h1 % 10000)
                    / 10000.0 * availW,
                y: padding + CGFloat(h2 % 10000)
                    / 10000.0 * availH
            )

            let minClusterDistance: CGFloat = 140
            for _ in 0..<8 {
                let tooClose = positions.values.first { existing in
                    let dx = existing.x - pos.x
                    let dy = existing.y - pos.y
                    return sqrt(dx*dx + dy*dy)
                        < minClusterDistance
                }
                guard tooClose != nil else { break }
                pos.x += CGFloat.random(in: -40...40)
                pos.y += CGFloat.random(in: -40...40)
                pos.x = max(padding,
                    min(size.width - padding, pos.x))
                pos.y = max(padding,
                    min(size.height - padding, pos.y))
            }
            positions[memory.id] = pos
        }
        return positions
    }

    func cluster(for memoryID: UUID) -> MemoryCluster? {
        clusters.first { $0.id == memoryID }
    }

    func selectMemory(_ memory: Memory) {
        selectedMemory = memory
        showMemorySheet = true
        UIImpactFeedbackGenerator(style: .medium)
            .impactOccurred()
    }

    func showTooltip(for memoryID: UUID) {
        tooltipMemoryID = memoryID
        Task {
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                if tooltipMemoryID == memoryID {
                    tooltipMemoryID = nil
                }
            }
        }
    }
}
