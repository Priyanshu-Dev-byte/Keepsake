import SwiftUI

struct WrappingHStack<Data: RandomAccessCollection, Content: View>: View
    where Data.Element: Hashable
{
    let data: Data
    let content: (Data.Element) -> Content
    let spacing: CGFloat

    init(_ data: Data, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        // Use a simplified flow layout via VStack + HStack
        var _: [Data.Element] = []
        let rows = buildRows()

        VStack(alignment: .leading, spacing: spacing) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }

    private func buildRows() -> [[Data.Element]] {
        return [Array(data)]
    }
}
