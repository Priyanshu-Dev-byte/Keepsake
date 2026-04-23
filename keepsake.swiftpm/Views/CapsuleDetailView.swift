import SwiftUI
import SwiftData

struct CapsuleDetailView: View {
    let capsule: TimeCapsule

    @State private var showAddMemory = false
    @State private var showReminders = false
    @State private var showSealConfirm = false
    @State private var showSealAnimation = false
    @State private var showCardSheet = false
    @State private var showDeleteCapsuleAlert = false
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss

    private var totalPhotos: Int {
        capsule.memories.flatMap { $0.photosData }.count
    }

    var body: some View {
        ZStack {
            Color(hex: "0B0C1E").ignoresSafeArea()

            VStack(spacing: 0) {
                ConstellationView(capsule: capsule)
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity)

                bottomBar
            }
        }
        .navigationTitle(capsule.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if totalPhotos >= 3 {
                    Button {
                        showCardSheet = true
                    } label: {
                        Label("Create Card", systemImage: "photo.on.rectangle.angled")
                    }
                    .tint(.white)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showDeleteCapsuleAlert = true
                    } label: {
                        Label("Delete Capsule", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.white)
                }
            }
        }
        .sheet(isPresented: $showAddMemory) {
            AddMemoryView(capsule: capsule)
        }
        .sheet(isPresented: $showReminders) {
            RemindersView(capsule: capsule)
        }
        .sheet(isPresented: $showCardSheet) {
            CardPreviewSheet(capsule: capsule)
        }
        .overlay {
            if showSealAnimation {
                SealAnimationView(capsule: capsule) {
                    showSealAnimation = false
                }
            }
        }
        .confirmationDialog(
            "Seal this capsule?",
            isPresented: $showSealConfirm,
            titleVisibility: .visible
        ) {
            Button("Seal Capsule", role: .destructive) {
                sealCapsule()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You can always unseal and add more memories.")
        }
        .confirmationDialog(
            "Delete this capsule?",
            isPresented: $showDeleteCapsuleAlert,
            titleVisibility: .visible
        ) {
            Button("Delete Capsule", role: .destructive) {
                NotificationManager.shared.cancelAnniversaryReminder(for: capsule)
                NotificationManager.shared.cancelReunionReminder(for: capsule)
                NotificationManager.shared.cancelAllReminders(for: capsule)
                modelContext.delete(capsule)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete the capsule and all its memories, photos, and reminders.")
        }
    }

    var bottomBar: some View {
        HStack(spacing: 12) {
            Button {
                showReminders = true
            } label: {
                Image(systemName: "bell.fill")
                    .font(.body.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
            }
            .glassEffect(
                .regular.tint(.orange.opacity(0.3)).interactive(),
                in: RoundedRectangle(cornerRadius: 16)
            )

            Button {
                showAddMemory = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.body.bold())
                    Text("Add Memory")
                        .font(.subheadline.bold())
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .glassEffect(
                .regular.tint(.blue.opacity(0.3)).interactive(),
                in: RoundedRectangle(cornerRadius: 16)
            )

            if !capsule.isSealed {
                Button {
                    showSealConfirm = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "seal.fill")
                            .font(.body.bold())
                        Text("Seal")
                            .font(.subheadline.bold())
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                }
                .glassEffect(
                    .regular.tint(.purple.opacity(0.4))
                        .interactive(),
                    in: RoundedRectangle(cornerRadius: 16)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
        .padding(.top, 8)
    }

    private func sealCapsule() {
        capsule.isSealed = true
        capsule.sealedDate = Date()
        showSealAnimation = true
        UINotificationFeedbackGenerator()
            .notificationOccurred(.success)
    }
}
