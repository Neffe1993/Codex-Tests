import SwiftUI

struct ResultView: View {
    @EnvironmentObject var gameState: GameState
    let stars: Int
    let levelIndex: Int

    @State private var starScales: [CGFloat] = [0, 0, 0]
    @State private var rewardOpacity: Double = 0
    @State private var titleOffset: CGFloat = -40
    @State private var confettiParticles: [ConfettiParticle] = []
    @State private var animateConfetti = false

    private var level: GameLevel { LevelData.levels[levelIndex] }

    var body: some View {
        ZStack {
            backgroundGradient
            confettiLayer
            VStack(spacing: 0) {
                Spacer()
                titleSection
                Spacer().frame(height: 24)
                starSection
                Spacer().frame(height: 20)
                rewardSection
                Spacer()
                buttonsSection
                Spacer().frame(height: 48)
            }
        }
        .onAppear { startAnimation() }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: stars >= 2
                ? [Color(red: 0.05, green: 0.28, blue: 0.1), Color(red: 0.12, green: 0.52, blue: 0.22)]
                : [Color(red: 0.25, green: 0.15, blue: 0.05), Color(red: 0.45, green: 0.3, blue: 0.1)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var confettiLayer: some View {
        ZStack {
            ForEach(confettiParticles) { p in
                RoundedRectangle(cornerRadius: 3)
                    .fill(p.color)
                    .frame(width: p.width, height: p.height)
                    .rotationEffect(.degrees(p.rotation))
                    .position(x: p.x, y: animateConfetti ? p.yEnd : p.yStart)
                    .opacity(animateConfetti ? 0 : 1)
                    .animation(
                        .easeIn(duration: p.duration).delay(p.delay),
                        value: animateConfetti
                    )
            }
        }
        .ignoresSafeArea()
    }

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text(stars == 3 ? "Perfekt!" : stars >= 2 ? "Super!" : stars == 1 ? "Geschafft!" : "Fast...")
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: stars >= 2 ? [.yellow, .orange] : [.white, Color(red: 0.8, green: 0.7, blue: 0.5)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 4, x: 2, y: 3)
                .offset(y: titleOffset)

            Text("Level \(levelIndex + 1): \(level.title)")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
    }

    private var starSection: some View {
        HStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < stars ? "star.fill" : "star")
                    .font(.system(size: i == 1 ? 56 : 44))
                    .foregroundColor(i < stars ? .yellow : .white.opacity(0.3))
                    .scaleEffect(starScales[i])
                    .shadow(color: i < stars ? .yellow.opacity(0.6) : .clear, radius: 8, x: 0, y: 0)
            }
        }
    }

    private var rewardSection: some View {
        VStack(spacing: 10) {
            if stars > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "gift.fill")
                        .foregroundColor(.yellow)
                    Text(level.rewardText)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.12))
                .cornerRadius(14)
                .padding(.horizontal, 20)
                .opacity(rewardOpacity)
            }

            HStack(spacing: 16) {
                rewardPill(icon: "star.fill", value: "+\(stars * 10)", label: "Sterne", color: .yellow)
                rewardPill(icon: "circle.fill", value: "+\(stars * 25)", label: "Münzen", color: Color(red: 1.0, green: 0.8, blue: 0.2))
            }
            .opacity(rewardOpacity)
        }
    }

    private func rewardPill(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon).foregroundColor(color).font(.system(size: 16))
                Text(value).font(.system(size: 20, weight: .black, design: .rounded)).foregroundColor(.white)
            }
            Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(.white.opacity(0.7))
        }
        .frame(width: 100, height: 64)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(color.opacity(0.4), lineWidth: 1.5))
    }

    private var buttonsSection: some View {
        VStack(spacing: 12) {
            if levelIndex + 1 < LevelData.levels.count {
                Button(action: { gameState.nextLevel(after: levelIndex) }) {
                    HStack(spacing: 10) {
                        Text("Weiter")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(width: 220, height: 54)
                    .background(
                        LinearGradient(colors: [Color(red: 0.18, green: 0.72, blue: 0.32), Color(red: 0.1, green: 0.55, blue: 0.22)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .clipShape(Capsule())
                    .shadow(color: .green.opacity(0.5), radius: 8, x: 0, y: 4)
                }
            }

            HStack(spacing: 14) {
                secondaryButton(icon: "arrow.clockwise", label: "Wiederholen") {
                    gameState.beginGame(levelIndex)
                }
                secondaryButton(icon: "list.bullet", label: "Level-Karte") {
                    gameState.goToLevelSelect()
                }
            }
        }
    }

    private func secondaryButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 20)).foregroundColor(.white)
                Text(label).font(.system(size: 12, weight: .semibold, design: .rounded)).foregroundColor(.white.opacity(0.85))
            }
            .frame(width: 105, height: 60)
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.white.opacity(0.25), lineWidth: 1))
        }
    }

    private func startAnimation() {
        confettiParticles = (0..<50).map { _ in ConfettiParticle.random() }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            titleOffset = 0
        }

        for i in 0..<min(stars, 3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(Double(i) * 0.22 + 0.4)) {
                starScales[i] = 1.0
            }
        }
        let emptystars = stars..<3
        for i in emptystars {
            withAnimation(.easeOut(duration: 0.3).delay(Double(i) * 0.15 + 0.3)) {
                starScales[i] = 1.0
            }
        }

        withAnimation(.easeIn(duration: 0.5).delay(1.0)) {
            rewardOpacity = 1.0
        }

        if stars >= 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateConfetti = true
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var yStart: CGFloat
    var yEnd: CGFloat
    var width: CGFloat
    var height: CGFloat
    var rotation: Double
    var color: Color
    var duration: Double
    var delay: Double

    static let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, Color(red: 1.0, green: 0.4, blue: 0.8)]

    static func random() -> ConfettiParticle {
        ConfettiParticle(
            x: CGFloat.random(in: 0...390),
            yStart: CGFloat.random(in: -30...0),
            yEnd: CGFloat.random(in: 700...900),
            width: CGFloat.random(in: 6...14),
            height: CGFloat.random(in: 10...20),
            rotation: Double.random(in: 0...360),
            color: colors.randomElement()!,
            duration: Double.random(in: 1.5...3.5),
            delay: Double.random(in: 0...0.8)
        )
    }
}
