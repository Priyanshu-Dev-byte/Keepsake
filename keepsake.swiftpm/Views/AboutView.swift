import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    headerSection

                    philosophySection

                    featuresSection

                    creditsSection

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            .scrollIndicators(.hidden)
            .background(Color(hex: "#0D0D1A"))
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#A78BFA"), Color(hex: "#7C3AED")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .shadow(color: Color(hex: "#A78BFA").opacity(0.4), radius: 16, y: 8)

                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
            }

            Text("Keepsake")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)

            Text("Version 1.0")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.top, 20)
    }

    private var philosophySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Our Philosophy")

            Text("Memories fade. Feelings disappear. We remember what happened but forget how it felt. Vesper was designed to preserve not just your moments — but the emotions that made them matter.\n\nSeal your milestones. Relive how they felt.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.8))
                .lineSpacing(4)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
        }
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 1) {
            sectionHeader("Features")

            VStack(spacing: 0) {
                featureRow(
                    icon: "sparkles",
                    color: .yellow,
                    title: "Constellation View",
                    description: "Every memory becomes a star. Every emotion becomes a color. Your milestones arrange themselves as a living constellation unique to you."
                )

                featureDivider

                featureRow(
                    icon: "heart.fill",
                    color: .purple,
                    title: "Emotion Tagging",
                    description: "Tag every memory with how it felt — Joy, Love, Pride, Nostalgia, Hope, or Bittersweet. Vesper organizes your life by feeling, not just by date."
                )

                featureDivider

                featureRow(
                    icon: "flame.fill",
                    color: .orange,
                    title: "Seal Ritual",
                    description: "Sealing a capsule is an intentional act. A ritual that marks a chapter of your life as complete. Beautiful animation included."
                )

                featureDivider

                featureRow(
                    icon: "rectangle.portrait.on.rectangle.portrait",
                    color: .blue,
                    title: "Memory Cards",
                    description: "Auto-generate beautiful shareable cards from your memories. Share to Instagram, WhatsApp, or save to Photos. Works completely offline."
                )

                featureDivider

                featureRow(
                    icon: "bell.fill",
                    color: .teal,
                    title: "Anniversary & Reunion Reminders",
                    description: "Set anniversary and reunion dates. Vesper reminds you every year and brings you back to how that milestone felt."
                )

                featureDivider

            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var creditsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Credits")

            VStack(spacing: 0) {
                creditRow(label: "Developer", value: "Priyanshu")

                Rectangle()
                    .fill(.white.opacity(0.06))
                    .frame(height: 1)
                    .padding(.horizontal, 16)

                creditRow(label: "Made for", value: "Swift Student Challenge 2026")
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(Color(hex: "#14B8A6"))
            .textCase(.uppercase)
            .tracking(1.5)
    }

    private func featureRow(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineSpacing(2)
            }
        }
        .padding(16)
    }

    private var featureDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.06))
            .frame(height: 1)
            .padding(.horizontal, 16)
    }

    private func creditRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(.white)
        }
        .padding(16)
    }
}
