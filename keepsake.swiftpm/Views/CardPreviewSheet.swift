import SwiftUI
import Photos

struct CardPreviewSheet: View {
    let capsule: TimeCapsule

    @Environment(\.dismiss) private var dismiss

    @State private var selectedStyle: CardStyle = .photoGrid
    @State private var selectedFormat: CardFormat = .story
    @State private var generatedImage: UIImage? = nil
    @State private var isGenerating: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var showSavedAlert: Bool = false
    @State private var saveError: String? = nil
    @State private var showPhotoWarning: Bool = false

    private var totalPhotos: Int {
        capsule.memories.flatMap { $0.photosData }.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0B0C1E").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        sheetHeader

                        stylePicker

                        formatPicker

                        cardPreview

                        actionButtons
                    }
                    .padding(20)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Memory Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = generatedImage {
                    ShareSheet(items: [image])
                }
            }
            .alert("Saved!", isPresented: $showSavedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your memory card has been saved to Photos.")
            }
            .alert("Error", isPresented: .init(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(saveError ?? "An unknown error occurred.")
            }
            .alert("Not Enough Photos", isPresented: $showPhotoWarning) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Add at least 3 photos to create a card.")
            }
        }
    }

    private var sheetHeader: some View {
        VStack(spacing: 6) {
            Text("🎴 Create Memory Card")
                .font(.headline)
                .foregroundStyle(.white)
            Text(capsule.name)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#A78BFA"), Color(hex: "#7C3AED")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ).opacity(0.3)
                )
        )
    }

    private var stylePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Style")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.5))
                .textCase(.uppercase)

            HStack(spacing: 0) {
                ForEach(CardStyle.allCases) { style in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedStyle = style
                            generatedImage = nil
                        }
                    } label: {
                        Text(style.label)
                            .font(.subheadline.bold())
                            .foregroundStyle(
                                selectedStyle == style ? .white : .white.opacity(0.5)
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedStyle == style
                                    ? Capsule().fill(.white.opacity(0.15))
                                    : Capsule().fill(.clear)
                            )
                    }
                }
            }
            .padding(4)
            .background(
                Capsule().fill(.white.opacity(0.08))
            )
        }
    }

    private var formatPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Format")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.5))
                .textCase(.uppercase)

            HStack(spacing: 0) {
                ForEach(CardFormat.allCases) { format in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFormat = format
                            generatedImage = nil
                        }
                    } label: {
                        Text(format.label)
                            .font(.subheadline.bold())
                            .foregroundStyle(
                                selectedFormat == format ? .white : .white.opacity(0.5)
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedFormat == format
                                    ? Capsule().fill(.white.opacity(0.15))
                                    : Capsule().fill(.clear)
                            )
                    }
                }
            }
            .padding(4)
            .background(
                Capsule().fill(.white.opacity(0.08))
            )
        }
    }

    private var cardPreview: some View {
        Group {
            if let image = generatedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
            } else {
                liveCardPreview
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var liveCardPreview: some View {
        GeometryReader { geo in
            let previewWidth: CGFloat = geo.size.width
            let aspect = selectedFormat.size.height / selectedFormat.size.width
            let previewHeight = previewWidth * aspect

            Group {
                switch selectedStyle {
                case .photoGrid:
                    PhotoGridCardView(capsule: capsule, format: selectedFormat)
                case .constellation:
                    ConstellationCardView(capsule: capsule, format: selectedFormat)
                case .emotionFocus:
                    EmotionFocusCardView(capsule: capsule, format: selectedFormat)
                }
            }
            .frame(width: selectedFormat.size.width, height: selectedFormat.size.height)
            .scaleEffect(previewWidth / selectedFormat.size.width)
            .frame(width: previewWidth, height: previewHeight)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
        }
        .aspectRatio(selectedFormat.size.width / selectedFormat.size.height, contentMode: .fit)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if generatedImage == nil {
                generateButton
            } else {
                HStack(spacing: 12) {
                    shareButton
                    saveButton
                }
            }
        }
    }

    private var generateButton: some View {
        Button {
            Task { await generateCard() }
        } label: {
            HStack(spacing: 8) {
                if isGenerating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "wand.and.stars")
                        .font(.body.bold())
                }
                Text(isGenerating ? "Generating…" : "Generate Card")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#A78BFA"), Color(hex: "#7C3AED")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .disabled(isGenerating)
    }

    private var shareButton: some View {
        Button {
            showShareSheet = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "square.and.arrow.up")
                    .font(.body.bold())
                Text("Share")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#A78BFA"))
            )
        }
    }

    private var saveButton: some View {
        Button {
            Task { await saveToPhotos() }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.down.to.line")
                    .font(.body.bold())
                Text("Save")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "#34D399"))
            )
        }
    }

    private func generateCard() async {
        guard totalPhotos >= 3 else {
            showPhotoWarning = true
            return
        }
        isGenerating = true
        generatedImage = await MemoryCardGenerator.generate(
            capsule: capsule,
            style: selectedStyle,
            format: selectedFormat
        )
        isGenerating = false
    }

    private func saveToPhotos() async {
        guard let image = generatedImage else { return }

        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            saveError = "Please allow photo library access in Settings to save your card."
            return
        }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                if let data = image.pngData() {
                    request.addResource(with: .photo, data: data, options: nil)
                }
            }
            showSavedAlert = true
        } catch {
            saveError = "Failed to save: \(error.localizedDescription)"
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
