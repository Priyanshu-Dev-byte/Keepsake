import SwiftUI


struct GlassPill<Content: View>: View {
    var horizontalPadding: CGFloat = 12
    var verticalPadding: CGFloat = 8
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .glassEffect(.regular, in: .capsule)
    }
}



extension View {
    func glassPill(h: CGFloat = 12, v: CGFloat = 8) -> some View {
        GlassPill(horizontalPadding: h, verticalPadding: v) {
            self
        }
    }
}
