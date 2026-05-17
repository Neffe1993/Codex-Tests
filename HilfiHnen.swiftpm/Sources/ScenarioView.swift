import SwiftUI

// Hauptansicht für Story-Szenarien (Screenshot 1 & 2 Stil)
struct ScenarioView: View {
    @EnvironmentObject var gs: GameState
    let level: LevelInfo

    @State private var thermFill: Double = 0.18
    @State private var appear = false

    var body: some View {
        ZStack {
            Color(red:0.08,green:0.08,blue:0.12).ignoresSafeArea()

            VStack(spacing: 0) {
                // Oben: X-Button
                HStack {
                    Spacer()
                    CloseButton { gs.screen = .map }
                    .padding(.trailing, 16)
                    .padding(.top, 52)
                    .padding(.bottom, 8)
                }

                // Haupt-Karte
                VStack(spacing: 0) {
                    // Rotes Banner
                    RedBanner(text: level.bannerText)

                    ZStack(alignment: .bottom) {
                        // Szenen-Illustration
                        Group {
                            switch level.scene {
                            case .winterOutdoor:
                                WinterOutdoorScene()
                            case .brokenRoom:
                                BrokenRoomScene()
                            default:
                                WinterOutdoorScene()
                            }
                        }
                        .frame(height: 340)

                        // Thermometer-Leiste
                        VStack {
                            ThermometerBar(fill: thermFill)
                                .padding(.top, 12)
                            Spacer()
                        }

                        // Sprechblasen
                        HStack(spacing: 20) {
                            ForEach(0..<level.needs.count, id:\.self) { i in
                                SpeechBubble(icon: level.needs[i].icon, color: level.needs[i].color)
                                    .opacity(appear ? 1 : 0)
                                    .offset(y: appear ? 0 : 20)
                                    .animation(.spring(response:0.5, dampingFraction:0.65).delay(Double(i)*0.15+0.3), value: appear)
                            }
                        }
                        .padding(.bottom, 55)

                        // Aufgaben-Button (links unten)
                        HStack {
                            GlowingTaskButton(icon: glowIcon) {
                                startGame()
                            }
                            .padding(.leading, 24)
                            .padding(.bottom, 16)
                            Spacer()
                        }
                    }

                    // Sterne-Anzeige (wie in Screenshot 2)
                    HStack {
                        Spacer()
                        StarsCounter(count: gs.stars)
                        .padding(.trailing, 14)
                    }
                    .padding(.vertical, 6)
                    .background(Color(red:0.12,green:0.12,blue:0.18))

                    // Body-Text
                    Text(level.bodyText)
                        .font(.system(size:14, weight:.medium, design:.rounded))
                        .foregroundColor(Color.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal,20)
                        .padding(.vertical,10)
                        .background(Color(red:0.14,green:0.14,blue:0.2))
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color:.black.opacity(0.5), radius:12, x:0, y:6)
                .padding(.horizontal, 12)

                Spacer()

                // Bottom Bar
                BottomNavBar(onMap: { gs.screen = .map }, stars: gs.stars)
                    .padding(.top, 8)
            }
        }
        .onAppear {
            appear = true
            withAnimation(.easeOut(duration:1.5).delay(0.4)) { thermFill = 0.28 }
        }
    }

    private var glowIcon: String {
        switch level.scene {
        case .brokenRoom: return "bed.double.fill"
        case .winterOutdoor: return "house.fill"
        default: return "star.fill"
        }
    }

    private func startGame() {
        switch level.gameType {
        case .match3, .match3Fire:
            gs.screen = .pipe(level.id)    // zeige Pipe-Puzzle statt Match-3
        case .pipe:
            gs.screen = .pipe(level.id)
        case .hourglass:
            gs.screen = .hourglass(level.id)
        }
    }
}
