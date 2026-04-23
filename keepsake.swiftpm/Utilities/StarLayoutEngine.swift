import Foundation

enum StarLayoutEngine: Sendable {

  

  
    struct StarDescriptor: Identifiable, Sendable {
        let id: UUID
       
        let normalizedX: Double
        
        let normalizedY: Double
       
        let radius: Double
       
        let twinklePhase: Double

        let emotion: Emotion
    }


    @MainActor static func descriptor(for memory: Memory) -> StarDescriptor {
        let hash = stableHash(memory.id)
        return StarDescriptor(
            id: memory.id,
            normalizedX: pseudoRandom(seed: hash, offset: 0),
            normalizedY: pseudoRandom(seed: hash, offset: 1),
            radius: lerp(min: 3.0, max: 8.0, t: pseudoRandom(seed: hash, offset: 2)),
            twinklePhase: pseudoRandom(seed: hash, offset: 3) * .pi * 2,
            emotion: memory.emotion
        )
    }

    @MainActor static func descriptors(for memories: [Memory]) -> [StarDescriptor] {
        memories.map { descriptor(for: $0) }
    }


    static func position(
        for star: StarDescriptor,
        in size: CGSize,
        padding: Double = 24
    ) -> CGPoint {
        let usableWidth  = size.width  - padding * 2
        let usableHeight = size.height - padding * 2
        return CGPoint(
            x: padding + star.normalizedX * usableWidth,
            y: padding + star.normalizedY * usableHeight
        )
    }

    static func hitTest(
        point: CGPoint,
        stars: [StarDescriptor],
        canvasSize: CGSize,
        padding: Double = 24
    ) -> StarDescriptor? {
        for star in stars {
            let pos = position(for: star, in: canvasSize, padding: padding)
            let tapRadius = star.radius + 12
            let dx = point.x - pos.x
            let dy = point.y - pos.y
            if dx * dx + dy * dy <= tapRadius * tapRadius {
                return star
            }
        }
        return nil
    }

    private static func stableHash(_ uuid: UUID) -> UInt64 {
        let (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p) = uuid.uuid
        var result: UInt64 = 14695981039346656037 // FNV offset basis
        let bytes: [UInt8] = [a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p]
        for byte in bytes {
            result ^= UInt64(byte)
            result &*= 1099511628211 // FNV prime
        }
        return result
    }

    private static func pseudoRandom(seed: UInt64, offset: Int) -> Double {
        var h = seed &+ UInt64(offset) &* 2654435761
        h ^= h >> 33
        h &*= 0xff51afd7ed558ccd
        h ^= h >> 33
        h &*= 0xc4ceb9fe1a85ec53
        h ^= h >> 33
        return Double(h % 1_000_000) / 1_000_000.0
    }

    private static func lerp(min: Double, max: Double, t: Double) -> Double {
        min + (max - min) * t
    }
}
