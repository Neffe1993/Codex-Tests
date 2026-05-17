import SwiftUI

struct LevelMapView: View {
    @EnvironmentObject var gs: GameState

    var body: some View {
        ZStack {
            // Gradient Hintergrund
            LinearGradient(colors:[Color(red:0.08,green:0.14,blue:0.35), Color(red:0.18,green:0.32,blue:0.62)],
                           startPoint:.top, endPoint:.bottom)
                .ignoresSafeArea()

            // Schneeflocken
            ForEach(0..<8, id:\.self) { i in
                Text("❄").font(.system(size:CGFloat([12,8,14,10,16,9,13,11][i])))
                    .opacity(0.3)
                    .position(x:CGFloat([30,80,150,220,280,320,370,50][i]),
                              y:CGFloat([80,200,130,300,180,90,250,350][i]))
            }

            VStack(spacing:0) {
                // Kopfzeile
                HStack {
                    Text("Hilf Ihnen!")
                        .font(.system(size:32,weight:.black,design:.rounded))
                        .italic()
                        .foregroundStyle(LinearGradient(colors:[.white, Color(red:1,green:0.88,blue:0.5)], startPoint:.top, endPoint:.bottom))
                        .shadow(color:.black.opacity(0.35), radius:3, x:1, y:2)
                    Spacer()
                    StarsCounter(count: gs.stars)
                }
                .padding(.horizontal,20)
                .padding(.top,56)
                .padding(.bottom,16)

                // Level-Karten
                ScrollView(showsIndicators:false) {
                    VStack(spacing:14) {
                        ForEach(allLevels) { level in
                            levelCard(level)
                        }
                    }
                    .padding(.horizontal,16)
                    .padding(.bottom,30)
                }
            }
        }
    }

    private func levelCard(_ level: LevelInfo) -> some View {
        let unlocked = gs.unlocked(level.id)
        let bestStars = gs.completedLevels[level.id] ?? 0

        return Button(action: {
            if unlocked { gs.screen = .scenario(level.id) }
        }) {
            ZStack {
                // Karten-Hintergrund
                RoundedRectangle(cornerRadius:18)
                    .fill(LinearGradient(
                        colors: unlocked
                            ? cardColors(level.scene)
                            : [Color.gray.opacity(0.25), Color.gray.opacity(0.15)],
                        startPoint:.topLeading, endPoint:.bottomTrailing
                    ))
                    .overlay(RoundedRectangle(cornerRadius:18).strokeBorder(Color.white.opacity(0.18), lineWidth:1.5))

                HStack(spacing:14) {
                    // Level-Typ-Icon
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.25))
                            .frame(width:56,height:56)
                        Image(systemName: levelTypeIcon(level.gameType))
                            .font(.system(size:24))
                            .foregroundColor(unlocked ? .white : .white.opacity(0.35))
                    }

                    VStack(alignment:.leading, spacing:4) {
                        Text("Level \(level.id+1)")
                            .font(.system(size:12,weight:.semibold,design:.rounded))
                            .foregroundColor(.white.opacity(0.7))
                        Text(level.bannerText)
                            .font(.system(size:18,weight:.black,design:.rounded))
                            .foregroundColor(unlocked ? .white : .white.opacity(0.4))
                        Text(level.bodyText)
                            .font(.system(size:11,weight:.medium))
                            .foregroundColor(.white.opacity(unlocked ? 0.75 : 0.35))
                            .lineLimit(2)
                    }

                    Spacer()

                    VStack(spacing:6) {
                        if unlocked {
                            // Sterne
                            HStack(spacing:2) {
                                ForEach(0..<3) { i in
                                    Image(systemName: i < bestStars ? "star.fill" : "star")
                                        .font(.system(size:14))
                                        .foregroundColor(i < bestStars ? Color(red:1,green:0.82,blue:0.1) : .white.opacity(0.3))
                                }
                            }
                            // Spielen-Pfeil
                            ZStack {
                                Circle()
                                    .fill(Color(red:0.18,green:0.72,blue:0.32))
                                    .frame(width:34,height:34)
                                    .shadow(color:.green.opacity(0.45),radius:4,x:0,y:2)
                                Image(systemName:"play.fill")
                                    .font(.system(size:14,weight:.bold))
                                    .foregroundColor(.white)
                                    .offset(x:1)
                            }
                        } else {
                            Image(systemName:"lock.fill")
                                .font(.system(size:22))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    .padding(.trailing,4)
                }
                .padding(.horizontal,14)
                .padding(.vertical,14)
            }
            .frame(height:88)
        }
        .disabled(!unlocked)
    }

    private func cardColors(_ scene: LevelInfo.SceneType) -> [Color] {
        switch scene {
        case .winterOutdoor: return [Color(red:0.28,green:0.48,blue:0.82), Color(red:0.38,green:0.60,blue:0.92)]
        case .brokenRoom:    return [Color(red:0.28,green:0.24,blue:0.42), Color(red:0.40,green:0.34,blue:0.58)]
        case .snowStorm:     return [Color(red:0.22,green:0.40,blue:0.65), Color(red:0.32,green:0.52,blue:0.78)]
        case .fireRoom:      return [Color(red:0.68,green:0.22,blue:0.12), Color(red:0.82,green:0.35,blue:0.10)]
        }
    }

    private func levelTypeIcon(_ g: LevelInfo.GameType) -> String {
        switch g {
        case .match3, .match3Fire: return "square.grid.3x3.fill"
        case .pipe:      return "arrow.triangle.branch"
        case .hourglass: return "hourglass"
        }
    }
}

