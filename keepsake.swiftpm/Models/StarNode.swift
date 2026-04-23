import SwiftUI

struct StarNode: Identifiable {
    let id = UUID()
    let memoryID: UUID
    let photoIndex: Int
    var image: UIImage
    var position: CGPoint
}
