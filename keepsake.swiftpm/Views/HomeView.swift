import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \TimeCapsule.createdDate, order: .reverse)
    var capsules: [TimeCapsule]
    @State private var showCreateCapsule = false
    @State private var showAboutSheet = false
    @Environment(\.modelContext) var modelContext

    var body: some View {
        ZStack {
            Color(hex: "0B0C1E").ignoresSafeArea()

            if capsules.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 56))
                        .foregroundStyle(.white.opacity(0.3))

                    VStack(spacing: 8) {
                        Text("No capsules yet")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                        Text("Seal your first milestone")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Button {
                        showCreateCapsule = true
                    } label: {
                        Label("Create Capsule",
                              systemImage: "plus")
                            .font(.body.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                    }
                    .glassEffect(
                        .regular.tint(.purple.opacity(0.4))
                            .interactive(),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                }
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 16
                    ) {
                        ForEach(capsules) { capsule in
                            NavigationLink(value: capsule) {
                                CapsuleCard(capsule: capsule)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle("Keepsake")
        .navigationDestination(for: TimeCapsule.self) { capsule in
            CapsuleDetailView(capsule: capsule)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showCreateCapsule = true
                } label: {
                    Image(systemName: "plus")
                        .font(.body.bold())
                        .frame(width: 36, height: 36)
                }
                .glassEffect(
                    .regular.interactive(),
                    in: .circle
                )
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAboutSheet = true
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.body)
                        .frame(width: 36, height: 36)
                }
                .glassEffect(
                    .regular.interactive(),
                    in: .circle
                )
            }
        }
        .sheet(isPresented: $showCreateCapsule) {
            CreateCapsuleView()
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutView()
        }
        .preferredColorScheme(.dark)
    }
}
