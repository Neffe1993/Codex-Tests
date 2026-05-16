import SwiftUI

struct StoryView: View {
    @EnvironmentObject var gameState: GameState
    let levelIndex: Int

    @State private var slideIndex = 0
    @State private var slideOpacity: Double = 0
    @State private var needsOffset: CGFloat = 30
    @State private var characterScale: CGFloat = 0.7
    @State private var thermometerFill: Double = 0.25

    private var level: GameLevel { LevelData.levels[levelIndex] }
    private var currentSlide: StorySlide { level.storySlides[min(slideIndex, level.storySlides.count - 1)] }

    var body: some View {
        ZStack {
            backgroundLayer
            mainContent
            topBar
        }
        .onAppear { animateIn() }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: currentSlide.backgroundGradient,
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            snowParticles
        }
    }

    private var snowParticles: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: CGFloat.random(in: 4...10), height: CGFloat.random(in: 4...10))
                    .position(x: CGFloat(i * 35 + 20), y: CGFloat(i * 60 + 100))
            }
        }
    }

    private var topBar: some View {
        VStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.7, green: 0.1, blue: 0.1), Color(red: 0.9, green: 0.2, blue: 0.15)],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(height: 100)
                .ignoresSafeArea(edges: .top)

                HStack {
                    Button(action: { gameState.goToLevelSelect() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.black.opacity(0.25))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 50)

                    Spacer()
                }
            }
            Spacer()
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            titleBanner

            Spacer().frame(height: 20)

            thermometerBar

            Spacer().frame(height: 30)

            characterArea
                .scaleEffect(characterScale)

            Spacer()

            needsBubbles
                .offset(y: needsOffset)

            Spacer()

            bodyTextBox

            actionButton
                .padding(.bottom, 40)
        }
        .opacity(slideOpacity)
    }

    private var titleBanner: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.7, green: 0.1, blue: 0.1), Color(red: 0.9, green: 0.2, blue: 0.15)],
                startPoint: .leading, endPoint: .trailing
            )

            Text(currentSlide.titleText)
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.35), radius: 3, x: 2, y: 2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 55)
                .padding(.bottom, 16)
        }
    }

    private var thermometerBar: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(red: 0.3, green: 0.5, blue: 0.95))
                .frame(width: 26, height: 26)
                .shadow(color: .blue.opacity(0.5), radius: 4)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 22)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.3, green: 0.5, blue: 0.95), Color(red: 0.9, green: 0.25, blue: 0.25)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * thermometerFill, height: 22)
                        .animation(.easeInOut(duration: 1.2), value: thermometerFill)

                    Capsule()
                        .strokeBorder(Color.white.opacity(0.6), lineWidth: 2)
                        .frame(height: 22)
                }
            }
            .frame(height: 22)
        }
        .padding(.horizontal, 30)
        .frame(height: 26)
    }

    private var characterArea: some View {
        ZStack {
            ForEach(0..<currentSlide.characters.count, id: \.self) { i in
                characterBubble(currentSlide.characters[i], index: i, total: currentSlide.characters.count)
            }
        }
        .frame(height: 200)
    }

    private func characterBubble(_ character: ScenarioCharacter, index: Int, total: Int) -> some View {
        let xOffset = total > 1 ? CGFloat(index - (total - 1) / 2) * 90 : 0.0

        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 70, height: 70)
                Image(systemName: character.imageName)
                    .font(.system(size: 38))
                    .foregroundColor(.white)
            }

            speechBubble(character.speechBubble)
        }
        .offset(x: xOffset, y: 0)
    }

    private func speechBubble(_ text: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.orange, lineWidth: 2)
            Text(text)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        }
        .frame(maxWidth: 120)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var needsBubbles: some View {
        HStack(spacing: 16) {
            ForEach(currentSlide.needs, id: \.self) { need in
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 68, height: 68)
                    Circle()
                        .strokeBorder(Color.orange, lineWidth: 3)
                        .frame(width: 68, height: 68)
                    Image(systemName: need)
                        .font(.system(size: 28))
                        .foregroundColor(Color(red: 0.85, green: 0.4, blue: 0.1))
                }
            }
        }
    }

    private var bodyTextBox: some View {
        Text(currentSlide.bodyText)
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.25))
            .cornerRadius(14)
            .padding(.horizontal, 20)
    }

    private var actionButton: some View {
        Button(action: { gameState.beginGame(levelIndex) }) {
            HStack(spacing: 10) {
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 18))
                Text("Spielen!")
                    .font(.system(size: 20, weight: .black, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(width: 200, height: 52)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.15, green: 0.72, blue: 0.3), Color(red: 0.08, green: 0.55, blue: 0.22)],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .clipShape(Capsule())
            .shadow(color: .green.opacity(0.5), radius: 8, x: 0, y: 4)
        }
        .padding(.top, 12)
    }

    private func animateIn() {
        thermometerFill = 0.0
        withAnimation(.easeOut(duration: 0.6)) {
            slideOpacity = 1.0
            needsOffset = 0
            characterScale = 1.0
        }
        withAnimation(.easeInOut(duration: 1.4).delay(0.5)) {
            thermometerFill = 0.25
        }
    }
}
