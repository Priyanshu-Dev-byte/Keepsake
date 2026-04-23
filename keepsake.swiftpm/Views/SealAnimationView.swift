import SwiftUI

struct SealAnimationView: View {
    let capsule: TimeCapsule
    var onComplete: () -> Void
    @Environment(\.modelContext) private var modelContext

    @State private var animationPhase: Double = 0
    @State private var showCompletion = false
    @State private var particlePositions: [CGPoint] = []

    var body: some View {
        ZStack {
            Color(hex: "#0B0C1E")
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                sealVisual

                VStack(spacing: 8) {
                    Text(showCompletion ? "Capsule Sealed!" : "Sealing your capsule…")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)

                    Text(capsule.milestoneType.tagline)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .italic()
                }
                .opacity(animationPhase > 0.3 ? 1 : 0)
                .animation(.easeIn(duration: 0.5), value: animationPhase)

                Spacer()

                if showCompletion {
                    Button {
                        onComplete()
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(capsule.milestoneType.primaryColor)
                            }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.bottom, 40)

            if capsule.milestoneType == .birthday && animationPhase > 0.5 {
                confettiOverlay
            }
        }
        .onAppear {
            runSealAnimation()
        }
    }

    @ViewBuilder
    private var sealVisual: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            capsule.milestoneType.primaryColor.opacity(0.3 * animationPhase),
                            .clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .scaleEffect(0.5 + animationPhase * 0.5)

            switch capsule.milestoneType.sealAnimationStyle {
            case .scrollRollUp:
                scrollAnimation
            case .confettiBurst:
                giftBoxAnimation
            case .boardingPassFold:
                envelopeAnimation
            case .waxSeal:
                waxSealAnimation
            }
        }
    }

    @ViewBuilder
    private var scrollAnimation: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#D4A843"), Color(hex: "#F5E6D3")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 100, height: max(200 * (1.0 - animationPhase), 8))
                .overlay {
                    if animationPhase < 0.7 {
                        VStack(spacing: 4) {
                            ForEach(0..<5, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(Color.brown.opacity(0.3))
                                    .frame(width: 70, height: 2)
                            }
                        }
                        .opacity(1.0 - animationPhase * 1.5)
                    }
                }

            if animationPhase > 0.8 {
                Image(systemName: "ribbon.fill")
                    .font(.title)
                    .foregroundStyle(Color(hex: "#D4A843"))
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    @ViewBuilder
    private var giftBoxAnimation: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#FF7EB3"), Color(hex: "#FF4081")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 120, height: 100)
                .offset(y: 30)

            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "#FF4081"))
                .frame(width: 130, height: 30)
                .offset(y: -30 * (1.0 - animationPhase) + 10)
                .rotationEffect(.degrees(-5 * (1.0 - animationPhase)))

            Rectangle()
                .fill(Color(hex: "#FFD700"))
                .frame(width: 10, height: 100)
                .offset(y: 30)

            Rectangle()
                .fill(Color(hex: "#FFD700"))
                .frame(width: 120, height: 10)
                .offset(y: 30)

            if animationPhase > 0.6 {
                Image(systemName: "gift.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color(hex: "#FFD700"))
                    .offset(y: -20)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    @ViewBuilder
    private var envelopeAnimation: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: "#7EC8E3"))
                .frame(width: 150, height: 100)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .frame(width: 130, height: 60)
                .offset(y: -50 * (1.0 - animationPhase))
                .opacity(1.0 - animationPhase * 0.5)

            Triangle()
                .fill(Color(hex: "#4A90D9"))
                .frame(width: 150, height: 60)
                .offset(y: -50)
                .rotation3DEffect(
                    .degrees(180 * animationPhase),
                    axis: (x: 1, y: 0, z: 0),
                    anchor: .bottom
                )

            if animationPhase > 0.9 {
                Image(systemName: "airplane")
                    .font(.title)
                    .foregroundStyle(.white)
                    .transition(.scale)
            }
        }
    }

    @ViewBuilder
    private var waxSealAnimation: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#F5E6D3"), Color(hex: "#DCC8A0")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 140, height: 180)
                .overlay {
                    VStack(spacing: 6) {
                        ForEach(0..<6, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.brown.opacity(0.2))
                                .frame(width: 100, height: 2)
                        }
                    }
                }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#C0392B"), Color(hex: "#8B0000")],
                        center: .center,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 60, height: 60)
                .scaleEffect(animationPhase > 0.5 ? 1.0 : 0.0)
                .overlay {
                    Image(systemName: "seal.fill")
                        .font(.title2)
                        .foregroundStyle(Color(hex: "#D4A843"))
                        .opacity(animationPhase > 0.7 ? 1 : 0)
                }
                .offset(y: 60)
        }
    }

    @ViewBuilder
    private var confettiOverlay: some View {
        Canvas { context, size in
            let colors: [Color] = [.pink, .yellow, .blue, .green, .orange, .purple]
            for i in 0..<30 {
                let seed = UInt64(i) &* 2654435761
                let x = CGFloat(seed % UInt64(size.width))
                let startY = -CGFloat((seed >> 8) % 100)
                let progress = min((animationPhase - 0.5) * 2.0, 1.0)
                let y = startY + progress * (size.height + 100)
                let color = colors[i % colors.count]
                let w: CGFloat = 6
                let h: CGFloat = 8

                context.fill(
                    RoundedRectangle(cornerRadius: 1).path(in: CGRect(x: x, y: y, width: w, height: h)),
                    with: .color(color)
                )
            }
        }
        .allowsHitTesting(false)
    }

    private func runSealAnimation() {
        withAnimation(.easeInOut(duration: 2.0)) {
            animationPhase = 1.0
        }

        Task {
            try? await Task.sleep(for: .seconds(1.5))
            capsule.isSealed = true
            HapticManager.heavy()
        }

        Task {
            try? await Task.sleep(for: .seconds(2.2))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showCompletion = true
            }
            HapticManager.success()
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}
