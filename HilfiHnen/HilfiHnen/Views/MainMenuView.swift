import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var gameState: GameState
    @State private var snowflakes: [SnowflakeData] = []
    @State private var titleScale: CGFloat = 0.5
    @State private var titleOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 60
    @State private var buttonOpacity: Double = 0
    @State private var animateSnow = false

    var body: some View {
        ZStack {
            backgroundGradient
            snowLayer
            contentLayer
        }
        .onAppear { startAnimations() }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.18, blue: 0.45),
                Color(red: 0.18, green: 0.38, blue: 0.72),
                Color(red: 0.55, green: 0.75, blue: 0.95)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var snowLayer: some View {
        ZStack {
            ForEach(snowflakes) { flake in
                Circle()
                    .fill(Color.white.opacity(flake.opacity))
                    .frame(width: flake.size, height: flake.size)
                    .position(x: flake.x, y: animateSnow ? flake.yEnd : flake.yStart)
                    .animation(
                        .linear(duration: flake.duration).repeatForever(autoreverses: false),
                        value: animateSnow
                    )
            }
        }
        .ignoresSafeArea()
    }

    private var contentLayer: some View {
        VStack(spacing: 0) {
            Spacer()

            titleSection
                .scaleEffect(titleScale)
                .opacity(titleOpacity)

            Spacer().frame(height: 40)

            characterSection

            Spacer()

            buttonSection
                .offset(y: buttonOffset)
                .opacity(buttonOpacity)

            Spacer().frame(height: 60)
        }
    }

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("Hilf")
                .font(.system(size: 68, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [.white, Color(red: 1.0, green: 0.9, blue: 0.5)], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: .black.opacity(0.4), radius: 4, x: 2, y: 3)

            Text("Ihnen!")
                .font(.system(size: 68, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: [Color(red: 1.0, green: 0.85, blue: 0.2), Color(red: 1.0, green: 0.55, blue: 0.1)], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: .black.opacity(0.4), radius: 4, x: 2, y: 3)

            HStack(spacing: 4) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Text("\(gameState.totalStars) Sterne")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Image(systemName: "star.fill").foregroundColor(.yellow)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.3))
            .clipShape(Capsule())
        }
    }

    private var characterSection: some View {
        HStack(spacing: -20) {
            characterBubble(icon: "person.fill", color: Color(red: 0.9, green: 0.4, blue: 0.3), label: "Marie")
            characterBubble(icon: "figure.child", color: Color(red: 0.4, green: 0.7, blue: 0.9), label: "Kind")
            characterBubble(icon: "figure.stand", color: Color(red: 0.5, green: 0.8, blue: 0.4), label: "Max")
        }
    }

    private func characterBubble(icon: String, color: Color, label: String) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.25))
                    .frame(width: 72, height: 72)
                Circle()
                    .strokeBorder(color, lineWidth: 3)
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(.system(size: 34))
                    .foregroundColor(color)
            }
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
    }

    private var buttonSection: some View {
        VStack(spacing: 14) {
            Button(action: { gameState.goToLevelSelect() }) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 20, weight: .bold))
                    Text("Spielen")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(width: 240, height: 58)
                .background(
                    LinearGradient(colors: [Color(red: 0.2, green: 0.75, blue: 0.35), Color(red: 0.1, green: 0.58, blue: 0.25)], startPoint: .top, endPoint: .bottom)
                )
                .clipShape(Capsule())
                .shadow(color: Color(red: 0.1, green: 0.55, blue: 0.25).opacity(0.6), radius: 8, x: 0, y: 4)
            }

            HStack(spacing: 14) {
                menuButton(icon: "trophy.fill", label: "Erfolge", color: Color(red: 1.0, green: 0.75, blue: 0.1))
                menuButton(icon: "gearshape.fill", label: "Einstellungen", color: Color(red: 0.6, green: 0.6, blue: 0.7))
            }
        }
    }

    private func menuButton(icon: String, label: String, color: Color) -> some View {
        Button(action: {}) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(width: 100, height: 60)
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white.opacity(0.2), lineWidth: 1))
        }
    }

    private func startAnimations() {
        snowflakes = (0..<40).map { _ in SnowflakeData.random() }

        withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.1)) {
            titleScale = 1.0
            titleOpacity = 1.0
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4)) {
            buttonOffset = 0
            buttonOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            animateSnow = true
        }
    }
}

struct SnowflakeData: Identifiable {
    let id = UUID()
    var x: CGFloat
    var yStart: CGFloat
    var yEnd: CGFloat
    var size: CGFloat
    var opacity: Double
    var duration: Double

    static func random() -> SnowflakeData {
        SnowflakeData(
            x: CGFloat.random(in: 0...390),
            yStart: CGFloat.random(in: -20 ... -5),
            yEnd: CGFloat.random(in: 820...900),
            size: CGFloat.random(in: 3...10),
            opacity: Double.random(in: 0.3...0.85),
            duration: Double.random(in: 5...14)
        )
    }
}
