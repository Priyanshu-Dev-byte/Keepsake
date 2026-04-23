import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            Color(hex: "0B0C1E").ignoresSafeArea()

            List {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Vesper")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("Memory Constellation")
                                .font(.caption)
                                .foregroundStyle(
                                    .white.opacity(0.5)
                                )
                        }
                        Spacer()
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundStyle(.purple)
                    }
                    .padding(.vertical, 4)
                }

                Section("About") {
                    Text("Vesper turns your life milestones into constellations of emotion. Each memory is a star. Each capsule is a sky.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.vertical, 4)
                }
            }
            .scrollContentBackground(.hidden)
            .preferredColorScheme(.dark)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
