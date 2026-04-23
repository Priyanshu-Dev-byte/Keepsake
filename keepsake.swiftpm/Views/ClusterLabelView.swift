import SwiftUI

struct ClusterLabelView: View {
    let cluster: MemoryCluster
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(cluster.memory.emotion.color)
                .frame(width: 6, height: 6)

            Text(cluster.memory.emotion.displayName)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(
                    cluster.memory.emotion.color
                )

            Text("·")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.4))

            Text(cluster.memory.createdDate.formatted(
                .dateTime.month(.abbreviated).day()
            ))
            .font(.system(size: 10))
            .foregroundStyle(.white.opacity(0.6))

            Text("\(cluster.photoCount)")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 16, height: 16)
                .background(
                    Circle()
                        .fill(
                            cluster.memory.emotion.color
                                .opacity(0.8)
                        )
                )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .glassEffect(
            isSelected
                ? .regular.tint(
                    cluster.memory.emotion.color.opacity(0.3)
                )
                : .regular,
            in: .capsule
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(
            .spring(response: 0.3, dampingFraction: 0.7),
            value: isSelected
        )
    }
}
