import SwiftUI
import SwiftData
import PhotosUI

@MainActor
struct AddMemoryView: View {
    let capsule: TimeCapsule
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var loadedImages: [UIImage] = []
    @State private var selectedEmotion: Emotion = .joy
    @State private var textNote: String = ""
    @State private var isSaving = false

    var canSave: Bool {
        !loadedImages.isEmpty || !textNote
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0B0C1E").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        photoSection
                        
                        emotionSection

                        noteSection

                        Button {
                            Task { await saveMemory() }
                        } label: {
                            HStack(spacing: 8) {
                                if isSaving {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(0.8)
                                } else {
                                    Image(
                                        systemName: "checkmark"
                                    )
                                    .font(.body.bold())
                                }
                                Text("Save Memory")
                                    .font(.body.bold())
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        }
                        .glassEffect(
                            canSave
                                ? .regular.tint(
                                    selectedEmotion.color
                                        .opacity(0.5)
                                ).interactive()
                                : .regular,
                            in: RoundedRectangle(
                                cornerRadius: 16
                            )
                        )
                        .disabled(!canSave || isSaving)
                        .padding(.bottom, 32)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("New Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .preferredColorScheme(.dark)
        .photosPicker(
            isPresented: .constant(false),
            selection: $selectedPhotos,
            maxSelectionCount: 5,
            matching: .images
        )
        .onChange(of: selectedPhotos) { _, items in
            Task { await loadPhotos(items) }
        }
    }

    var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Photos", systemImage: "photo.stack.fill")
                .font(.subheadline.bold())
                .foregroundStyle(.white.opacity(0.8))

            if loadedImages.isEmpty {
                PhotosPicker(
                    selection: $selectedPhotos,
                    maxSelectionCount: 5,
                    matching: .images
                ) {
                    emptyPhotoPromptView()
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(loadedImages.enumerated()), id: \.offset) { index, image in
                            imageThumbnail(image: image, index: index)
                        }

                        if loadedImages.count < 5 {
                            PhotosPicker(
                                selection: $selectedPhotos,
                                maxSelectionCount: 5,
                                matching: .images
                            ) {
                                addMorePhotosButton()
                            }
                        }
                    }
                }
            }
        }
    }

    nonisolated private func emptyPhotoPromptView() -> some View {
        VStack(spacing: 10) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 32))
                .foregroundStyle(.white.opacity(0.3))
            Text("Add up to 5 photos")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        .white.opacity(0.15),
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
                )
        )
    }

    nonisolated private func addMorePhotosButton() -> some View {
        VStack(spacing: 4) {
            Image(systemName: "plus")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.4))
            Text("Add more")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.3))
        }
        .frame(width: 90, height: 90)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
                )
        )
    }

    private func imageThumbnail(image: UIImage, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                removeImage(at: index)
            } label: {
                ZStack {
                    Circle()
                        .fill(.black.opacity(0.7))
                        .frame(width: 22, height: 22)
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .offset(x: 4, y: -4)
        }
    }

    private func removeImage(at index: Int) {
        loadedImages.remove(at: index)
        if index < selectedPhotos.count {
            selectedPhotos.remove(at: index)
        }
    }

    var emotionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(
                "How did this feel?",
                systemImage: "heart.fill"
            )
            .font(.subheadline.bold())
            .foregroundStyle(.white.opacity(0.8))

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 10
            ) {
                ForEach(Emotion.allCases, id: \.self) {
                    emotion in
                    Button {
                        withAnimation(
                            .spring(response: 0.3,
                                    dampingFraction: 0.7)
                        ) {
                            selectedEmotion = emotion
                        }
                        UIImpactFeedbackGenerator(style: .light)
                            .impactOccurred()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: emotion.systemImage)
                                .font(.title3)
                                .foregroundStyle(
                                    selectedEmotion == emotion
                                        ? emotion.color
                                        : .white.opacity(0.5)
                                )
                            Text(emotion.displayName)
                                .font(.caption.bold())
                                .foregroundStyle(
                                    selectedEmotion == emotion
                                        ? .white
                                        : .white.opacity(0.4)
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                    .glassEffect(
                        selectedEmotion == emotion
                            ? .regular.tint(
                                emotion.color.opacity(0.35)
                            ).interactive()
                            : .regular.interactive(),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
                }
            }
        }
    }

    var noteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(
                "Note (optional)",
                systemImage: "text.alignleft"
            )
            .font(.subheadline.bold())
            .foregroundStyle(.white.opacity(0.8))

            TextField(
                "What made this moment special?",
                text: $textNote,
                axis: .vertical
            )
            .font(.body)
            .foregroundStyle(.white)
            .lineLimit(3...6)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                .white.opacity(0.12),
                                lineWidth: 1
                            )
                    )
            )
        }
    }

    @MainActor
    private func saveMemory() async {
        guard canSave else { return }
        isSaving = true

        let photosData = loadedImages.compactMap {
            $0.jpegData(compressionQuality: 0.8)
        }

        let memory = Memory(
            textNote: textNote,
            emotion: selectedEmotion,
            photosData: photosData,
            capsule: capsule
        )
        modelContext.insert(memory)

        UINotificationFeedbackGenerator()
            .notificationOccurred(.success)
        dismiss()
    }

    private func loadPhotos(
        _ items: [PhotosPickerItem]
    ) async {
        var images: [UIImage] = []
        for item in items {
            if let data = try? await item.loadTransferable(
                type: Data.self
            ),
               let image = UIImage(data: data) {
                images.append(image)
            }
        }
        await MainActor.run {
            loadedImages = images
        }
    }
}
