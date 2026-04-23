import SwiftUI

struct OpenCapsuleView: View {
    let capsule: TimeCapsule
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var revealPhase = 0
    @State private var revealedCount = 0
    @State private var showConstellation = false
    @State private var meshPhase: Double = 0

    private var sortedMemories: [Memory] {
        capsule.memories.sorted { $0.createdDate < $1.createdDate }
    }

    var body: some View {
        ZStack {
            meshBackground
                .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                    Button {
                        capsule.isSealed = false
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding()
                }

                if revealPhase == 0 {
                    introView
                } else if revealPhase == 1 {
                    memoriesReveal
                } else {
                    constellationReveal
                }
            }
        }
        .onAppear {
            startReveal()
        }
    }

    @ViewBuilder
    private var meshBackground: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 15.0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let colors = capsule.milestoneType.meshColors
                for (i, color) in colors.enumerated() {
                    let phase = time * 0.3 + Double(i) * 1.5
                    let x = size.width * (0.3 + 0.4 * sin(phase * 0.7))
                    let y = size.height * (0.3 + 0.4 * cos(phase * 0.5))
                    let radius = min(size.width, size.height) * 0.4

                    var ctx = context
                    ctx.opacity = 0.3
                    ctx.addFilter(.blur(radius: radius * 0.6))
                    ctx.fill(
                        Circle().path(in: CGRect(
                            x: x - radius,
                            y: y - radius,
                            width: radius * 2,
                            height: radius * 2
                        )),
                        with: .color(color)
                    )
                }
            }
            .background(Color(hex: "#0B0C1E"))
        }
    }

    @ViewBuilder
    private var introView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "lock.open.fill")
                .font(.system(size: 56))
                .foregroundStyle(capsule.milestoneType.primaryColor)
                .symbolEffect(.bounce, value: revealPhase)

            Text("Opening \(capsule.name)")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)

            Text(capsule.milestoneType.tagline)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
                .italic()

            Spacer()
        }
        .transition(.opacity)
    }

    @ViewBuilder
    private var memoriesReveal: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Your Memories")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.top, 20)

                ForEach(Array(sortedMemories.enumerated()), id: \.element.id) { index, memory in
                    if index < revealedCount {
                        memoryRevealCard(memory)
                            .transition(
                                .asymmetric(
                                    insertion: .opacity
                                        .combined(with: .scale(scale: 0.8))
                                        .combined(with: .offset(y: 20)),
                                    removal: .opacity
                                )
                            )
                    }
                }

                if revealedCount >= sortedMemories.count {
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            revealPhase = 2
                        }
                    } label: {
                        Label("View Constellation", systemImage: "star.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background {
                                Capsule()
                                    .fill(capsule.milestoneType.primaryColor)
                            }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 20)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .padding(.bottom, 60)
        }
    }

    @ViewBuilder
    private func memoryRevealCard(_ memory: Memory) -> some View {
        HStack(spacing: 12) {
            if let photoData = memory.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(memory.emotionColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: memory.emotion.systemImage)
                            .foregroundStyle(memory.emotionColor)
                    }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(memory.notePreview)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(memory.emotion.emoji + " " + memory.emotion.displayName)
                    .font(.caption)
                    .foregroundStyle(memory.emotionColor)
            }

            Spacer()
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "#1A1B2E").opacity(0.8))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(memory.emotionColor.opacity(0.3), lineWidth: 1)
                }
        }
        .shadow(color: memory.emotionColor.opacity(0.2), radius: 8, y: 2)
    }

    @ViewBuilder
    private var constellationReveal: some View {
        VStack {
            ConstellationView(capsule: capsule)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    private func startReveal() {
        capsule.isSealed = false

        Task {
            try? await Task.sleep(for: .seconds(1.5))
            HapticManager.medium()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                revealPhase = 1
            }

            for i in 0..<sortedMemories.count {
                try? await Task.sleep(for: .seconds(0.6))
                withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
                    revealedCount = i + 1
                }
                HapticManager.light()
            }
        }
    }
}
