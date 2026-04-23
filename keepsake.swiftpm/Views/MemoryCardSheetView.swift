import SwiftUI

struct MemoryCardSheetView: View {
    let memory: Memory
    let capsule: TimeCapsule?
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State private var showDeleteMemoryAlert = false

    var body: some View {
        ZStack {
            Color(hex: "#0D0D1A").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    photoHeader

                    VStack(alignment: .leading, spacing: 20) {
                        emotionDateRow
                        noteSection
                        divider
                        capsuleTagRow
                        divider
                        deleteMemoryButton
                    }
                    .padding(20)
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    @ViewBuilder
    private var photoHeader: some View {
        if !memory.photosData.isEmpty {
            let images = memory.photosData.compactMap { UIImage(data: $0) }

            if images.count == 1 {
                Image(uiImage: images[0])
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipped()
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 20,
                            topTrailingRadius: 20
                        )
                    )
            } else {
                TabView {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 280)
                            .clipped()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 280)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 20,
                        topTrailingRadius: 20
                    )
                )
                .overlay(alignment: .topTrailing) {
                    Text("\(images.count) photos")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .glassEffect(
                            .regular,
                            in: .capsule
                        )
                        .padding(10)
                }
            }
        } else {
            ZStack {
                LinearGradient(
                    colors: [
                        memory.emotion.color.opacity(0.4),
                        Color(hex: "#0D0D1A")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 160)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 20,
                        topTrailingRadius: 20
                    )
                )

                Image(systemName: memory.emotion.systemImage)
                    .font(.system(size: 52))
                    .foregroundStyle(memory.emotion.color)
            }
        }
    }

    @ViewBuilder
    private var emotionDateRow: some View {
        HStack(alignment: .center) {
            HStack(spacing: 6) {
                Circle()
                    .fill(memory.emotion.color)
                    .frame(width: 8, height: 8)
                Text(memory.emotion.displayName)
                    .font(.caption.bold())
                    .foregroundStyle(memory.emotion.color)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .glassEffect(
                .regular.tint(memory.emotion.color.opacity(0.3)),
                in: .capsule
            )

            Spacer()

            Text(memory.createdDate.formatted(
                .dateTime.month(.abbreviated).day().year()
            ))
            .font(.caption)
            .foregroundStyle(.white.opacity(0.5))
        }
    }

    @ViewBuilder
    private var noteSection: some View {
        if !memory.textNote.isEmpty {
            Text(memory.textNote)
                .font(.body)
                .foregroundStyle(.white)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(.white.opacity(0.08))
            .frame(height: 1)
    }

    @ViewBuilder
    private var capsuleTagRow: some View {
        HStack {
            if let capsule = capsule {
                HStack(spacing: 6) {
                    Image(systemName: capsule.milestoneType.systemImage)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                    Text(capsule.name)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .glassEffect(.regular, in: .capsule)

                Spacer()

                NavigationLink {
                    CapsuleDetailView(capsule: capsule)
                } label: {
                    HStack(spacing: 4) {
                        Text("View Capsule")
                            .font(.caption.bold())
                        Image(systemName: "chevron.right")
                            .font(.caption2.bold())
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                }
                .glassEffect(
                    .regular.interactive(),
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .simultaneousGesture(
                    TapGesture().onEnded { dismiss() }
                )
            }
        }
    }

    private var deleteMemoryButton: some View {
        Button(role: .destructive) {
            showDeleteMemoryAlert = true
        } label: {
            Label("Delete Memory", systemImage: "trash")
                .font(.subheadline.bold())
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .confirmationDialog(
            "Delete this memory?",
            isPresented: $showDeleteMemoryAlert,
            titleVisibility: .visible
        ) {
            Button("Delete Memory", role: .destructive) {
                modelContext.delete(memory)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This memory and all its photos will be permanently deleted.")
        }
    }
}
