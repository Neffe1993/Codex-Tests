import SwiftUI

struct LevelMapView: View {
    @EnvironmentObject var gs: GameState

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            // Hintergrund (Winterszene wie in den Screenshots)
            LinearGradient(colors:[Color(red:0.22,green:0.30,blue:0.58), Color(red:0.32,green:0.48,blue:0.82)],
                           startPoint:.top, endPoint:.bottom)
                .ignoresSafeArea()

            // Schneeboden
            VStack { Spacer()
                Ellipse().fill(Color.white.opacity(0.7)).frame(height:120).padding(.horizontal,-30)
            }.ignoresSafeArea()

            // Schneeflocken
            ForEach(0..<10, id:\.self) { i in
                Text("❄")
                    .font(.system(size:CGFloat([10,8,14,9,12,7,11,13,8,10][i])))
                    .opacity(0.3)
                    .position(x:CGFloat([30,90,160,220,290,340,380,50,120,260][i]),
                              y:CGFloat([70,180,110,280,160,80,230,320,140,300][i]))
            }

            VStack(spacing:0) {
                // Kopfzeile
                ZStack {
                    LinearGradient(colors:[Color(red:0.78,green:0.08,blue:0.08), Color(red:0.88,green:0.14,blue:0.14)],
                                   startPoint:.top, endPoint:.bottom)
                    VStack(spacing:2) {
                        Text("Hilf ihnen!")
                            .font(.system(size:34,weight:.black,design:.rounded))
                            .italic()
                            .foregroundColor(.white)
                            .shadow(color:.black.opacity(0.35), radius:3, x:1, y:2)
                        Text("DEV MODE – alle Level freigeschaltet")
                            .font(.system(size:11,weight:.semibold,design:.rounded))
                            .foregroundColor(Color(red:1,green:0.88,blue:0.5))
                    }
                    .padding(.top,52).padding(.bottom,14)

                    HStack {
                        Spacer()
                        starsChip
                            .padding(.trailing,16)
                    }
                    .padding(.top,52)
                }
                .frame(maxWidth:.infinity)

                // Level-Grid
                ScrollView(showsIndicators:false) {
                    LazyVGrid(columns:columns, spacing:12) {
                        ForEach(allPipeLevels) { lvl in
                            LevelCell(level:lvl, bestStars:gs.bestStars(for:lvl.id))
                                .onTapGesture { gs.screen = .pipe(lvl.id) }
                        }
                    }
                    .padding(.horizontal,14)
                    .padding(.top,14)
                    .padding(.bottom,30)
                }
            }
        }
    }

    private var starsChip: some View {
        HStack(spacing:4) {
            Image(systemName:"star.fill")
                .foregroundColor(Color(red:1,green:0.85,blue:0.15))
                .font(.system(size:14))
            Text("\(gs.stars)")
                .font(.system(size:14,weight:.black,design:.rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal,10).padding(.vertical,5)
        .background(Color.black.opacity(0.35))
        .clipShape(Capsule())
    }
}

// MARK: - Level-Kachel
struct LevelCell: View {
    let level: PipeLevelConfig
    let bestStars: Int

    @State private var pressed = false

    var body: some View {
        ZStack {
            // Hintergrund
            RoundedRectangle(cornerRadius:18)
                .fill(LinearGradient(colors:[level.bgColorTop, level.bgColorBot],
                                     startPoint:.topLeading, endPoint:.bottomTrailing))
                .shadow(color:.black.opacity(0.35), radius:6, x:0, y:4)

            RoundedRectangle(cornerRadius:18)
                .strokeBorder(Color.white.opacity(0.2), lineWidth:1.5)

            VStack(spacing:6) {
                // Puzzle-Icon
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.22))
                        .frame(width:50,height:50)
                    Image(systemName: variantIcon(level.puzzleVariant))
                        .font(.system(size:22,weight:.semibold))
                        .foregroundColor(.white)
                }

                // Level-Nummer
                Text("Level \(level.id+1)")
                    .font(.system(size:12,weight:.black,design:.rounded))
                    .foregroundColor(.white)

                // Sterne
                HStack(spacing:2) {
                    ForEach(0..<3) { i in
                        Image(systemName: i < bestStars ? "star.fill" : "star")
                            .font(.system(size:11))
                            .foregroundColor(i < bestStars ? Color(red:1,green:0.85,blue:0.15) : .white.opacity(0.28))
                    }
                }

                // Timer-Badge
                HStack(spacing:3) {
                    Image(systemName:"clock").font(.system(size:9)).foregroundColor(.white.opacity(0.7))
                    Text("\(Int(level.timeLimit))s")
                        .font(.system(size:10,weight:.semibold)).foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.vertical,12)

            // Spiel-Pfeil unten rechts
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(Color(red:0.18,green:0.72,blue:0.32))
                            .frame(width:26,height:26)
                            .shadow(color:.green.opacity(0.5),radius:3,x:0,y:2)
                        Image(systemName:"play.fill")
                            .font(.system(size:10,weight:.bold))
                            .foregroundColor(.white)
                            .offset(x:1)
                    }
                    .padding(8)
                }
            }
        }
        .scaleEffect(pressed ? 0.94 : 1.0)
        .animation(.spring(response:0.2, dampingFraction:0.6), value:pressed)
        .onTapGesture {
            pressed = true
            DispatchQueue.main.asyncAfter(deadline:.now()+0.12) { pressed = false }
        }
        .frame(height:140)
    }

    private func variantIcon(_ v: PipeLevelConfig.PuzzleVariant) -> String {
        switch v {
        case .pipe:     return "arrow.triangle.branch"
        case .scissors: return "scissors"
        case .chain:    return "link"
        case .gravity:  return "arrow.down.circle"
        }
    }
}
