import SwiftUI

struct StarTooltipView: View {
    let memory: Memory

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 5) {
                Image(systemName: memory.emotion.systemImage)
                    .font(.caption2)
                    .foregroundStyle(memory.emotion.color)
                Text(memory.emotion.displayName)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }
            Text(memory.createdDate.formatted(
                .dateTime.month(.abbreviated).day().year()
            ))
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassEffect(
            .regular,
            in: RoundedRectangle(cornerRadius: 12)
        )
        .shadow(color: memory.emotion.color.opacity(0.3), radius: 8)
    }
}
