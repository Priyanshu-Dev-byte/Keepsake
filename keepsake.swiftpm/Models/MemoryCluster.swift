import SwiftUI

struct MemoryCluster: Identifiable {
    let id: UUID            // same as memory.id
    let memory: Memory
    var starPositions: [UUID: CGPoint]
    // Center point of this cluster
    var center: CGPoint {
        guard !starPositions.isEmpty else {
            return .zero
        }
        let xs = starPositions.values.map { $0.x }
        let ys = starPositions.values.map { $0.y }
        return CGPoint(
            x: xs.reduce(0, +) / CGFloat(xs.count),
            y: ys.reduce(0, +) / CGFloat(ys.count)
        )
    }

    // All photos as UIImages
    var photos: [UIImage] {
        memory.photosData.compactMap { UIImage(data: $0) }
    }

    var photoCount: Int { photos.count }
    var isSinglePhoto: Bool { photoCount == 1 }
    var isCluster: Bool { photoCount > 1 }
}
