import SwiftUI

// MARK: - Hourglass-Challenge (Screenshot 3 Stil)
// Zwei Seiten (Spieler vs. Gegner), jeder füllt seine Seite durch Tippen auf Schieberegler.

struct HourglassChallengeView: View {
    @EnvironmentObject var gs: GameState
    let level: LevelInfo

    @State private var playerProgress: Double = 0
    @State private var enemyProgress: Double = 0
    @State private var sliderLeft: CGFloat = 0.5
    @State private var sliderRight: CGFloat = 0.5
    @State private var timeLeft: Double = 30
    @State private var finished = false
    @State private var pulseHand = false

    private let totalTime: Double = 30

    var body: some View {
        ZStack {
            // Hintergrund: Dachboden-Stil (Screenshot 3)
            LinearGradient(colors:[Color(red:0.22,green:0.18,blue:0.28), Color(red:0.35,green:0.28,blue:0.42)],
                           startPoint:.top, endPoint:.bottom)
                .ignoresSafeArea()

            // Holzbalken Hintergrund
            woodenBackground

            VStack(spacing:0) {
                // Banner
                ZStack {
                    LinearGradient(colors:[Color(red:0.78,green:0.08,blue:0.08),Color(red:0.88,green:0.14,blue:0.14)],
                                   startPoint:.top, endPoint:.bottom)
                    HStack {
                        CloseButton { gs.screen = .map }.padding(.leading,16)
                        Spacer()
                        VStack(spacing:2) {
                            Text("Stell dich der Herausforderung!")
                                .font(.system(size:22,weight:.black,design:.rounded))
                                .italic().foregroundColor(.white)
                                .shadow(color:.black.opacity(0.3), radius:2, x:1, y:2)
                            // Timer
                            Text(String(format:"%.0fs",timeLeft))
                                .font(.system(size:15,weight:.bold,design:.rounded))
                                .foregroundColor(timeLeft < 10 ? Color(red:1,green:0.85,blue:0.2) : .white.opacity(0.8))
                        }
                        Spacer()
                        StarsCounter(count:gs.stars).padding(.trailing,14)
                    }
                    .padding(.top,50).padding(.bottom,12)
                }

                Spacer()

                // Haupt-Hourglass-Bild
                hourglassLayout

                Spacer()

                // Schieberegler (Interaktion)
                slidersSection

                Spacer()

                BottomNavBar(onMap:{ gs.screen = .map }, stars: gs.stars)
            }
        }
        .onAppear { startChallenge() }
    }

    // MARK: - Holz-Hintergrund
    private var woodenBackground: some View {
        ZStack {
            // Holzbalken-Textur (vereinfacht)
            ForEach(0..<5, id:\.self) { i in
                Rectangle()
                    .fill(Color(red:0.38+Double(i)*0.02, green:0.28+Double(i)*0.01, blue:0.18))
                    .frame(height:2)
                    .offset(y:CGFloat(i*80-160))
                    .opacity(0.4)
            }
            // Mittelpfosten (Screenshot 3: vertikaler Pfosten in der Mitte)
            Rectangle()
                .fill(Color(red:0.42,green:0.32,blue:0.22))
                .frame(width:18)
        }
        .ignoresSafeArea()
    }

    // MARK: - Hourglass-Layout
    private var hourglassLayout: some View {
        HStack(spacing:0) {
            // Linke Seite (Gegner) — dunkler
            VStack(spacing:0) {
                hourglassSide(
                    isPlayer: false,
                    progress: enemyProgress,
                    topColor: Color(red:0.75,green:0.15,blue:0.15),
                    fillColor: Color(red:0.82,green:0.22,blue:0.18),
                    itemIcon: "diamond.fill",
                    itemColor: Color(red:0.9,green:0.2,blue:0.2)
                )
                enemyCharacter
                progressBadge(enemyProgress, isPlayer:false)
            }

            // Mitteltrenner
            Rectangle()
                .fill(Color(red:0.45,green:0.35,blue:0.55))
                .frame(width:6)
                .frame(maxHeight:.infinity)

            // Rechte Seite (Spieler) — heller, Münzen
            VStack(spacing:0) {
                hourglassSide(
                    isPlayer: true,
                    progress: playerProgress,
                    topColor: Color(red:0.85,green:0.65,blue:0.05),
                    fillColor: Color(red:1,green:0.82,blue:0.1),
                    itemIcon: "circle.fill",
                    itemColor: Color(red:1,green:0.82,blue:0.1)
                )
                playerCharacter
                progressBadge(playerProgress, isPlayer:true)
            }
        }
        .frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius:16))
        .overlay(RoundedRectangle(cornerRadius:16).strokeBorder(Color.white.opacity(0.12), lineWidth:1.5))
        .padding(.horizontal,20)
    }

    // MARK: - Eine Sanduhr-Seite (Hourglass-Hälfte)
    private func hourglassSide(isPlayer:Bool, progress:Double, topColor:Color, fillColor:Color, itemIcon:String, itemColor:Color) -> some View {
        ZStack(alignment:.bottom) {
            // Sanduhr-Silhouette
            HourglassHalf(isPlayer:isPlayer)
                .fill(topColor.opacity(0.18))
            HourglassHalf(isPlayer:isPlayer)
                .stroke(Color(red:0.45,green:0.32,blue:0.62), style:StrokeStyle(lineWidth:2.5))

            // Füllung (Münzen/Rubine fallen von oben)
            HourglassHalf(isPlayer:isPlayer)
                .fill(
                    LinearGradient(
                        colors:[fillColor.opacity(0.9), fillColor.opacity(0.55)],
                        startPoint:.top, endPoint:.bottom
                    )
                )
                .scaleEffect(y:progress, anchor:.top)
                .animation(.easeOut(duration:0.3), value:progress)

            // Artikel-Icons oben
            VStack {
                HStack(spacing:-2) {
                    ForEach(0..<5, id:\.self) { i in
                        Image(systemName: itemIcon)
                            .font(.system(size:11))
                            .foregroundColor(itemColor)
                            .offset(y:CGFloat(i%2==0 ? 0 : 3))
                    }
                }
                .padding(.top,6)
                Spacer()
            }

            // Kiste / Behälter unten (nur Spieler-Seite)
            if isPlayer {
                ZStack {
                    RoundedRectangle(cornerRadius:6)
                        .fill(Color(red:0.88,green:0.58,blue:0.12))
                        .frame(width:44,height:34)
                    RoundedRectangle(cornerRadius:3)
                        .fill(Color(red:0.72,green:0.42,blue:0.08))
                        .frame(width:44,height:6)
                        .offset(y:-14)
                    Image(systemName:"lock.fill")
                        .font(.system(size:12))
                        .foregroundColor(Color(red:0.58,green:0.32,blue:0.05))
                }
                .offset(y:8)
            }

            // Hand-Cursor (Screenshot 3: zeigt auf rechten Schieberegler)
            if isPlayer && !finished {
                Image(systemName:"hand.point.up.left.fill")
                    .font(.system(size:28))
                    .foregroundColor(.white)
                    .scaleEffect(pulseHand ? 1.1 : 0.95)
                    .offset(x:60, y:-60)
                    .animation(.easeInOut(duration:0.7).repeatForever(autoreverses:true), value:pulseHand)
            }
        }
        .frame(maxWidth:.infinity, maxHeight:200)
    }

    // MARK: - Charaktere unten
    private var enemyCharacter: some View {
        VStack(spacing:2) {
            CharacterChild()
                .scaleEffect(0.65)
                .frame(height:50)
        }
    }

    private var playerCharacter: some View {
        VStack(spacing:2) {
            CharacterWoman()
                .scaleEffect(0.65)
                .frame(height:50)
        }
    }

    private func progressBadge(_ progress:Double, isPlayer:Bool) -> some View {
        Text("\(Int(progress*100))%")
            .font(.system(size:14,weight:.black,design:.rounded))
            .foregroundColor(.white)
            .padding(.horizontal,10).padding(.vertical,4)
            .background(Capsule().fill(isPlayer ? Color(red:0.55,green:0.38,blue:0.05) : Color(red:0.55,green:0.12,blue:0.12)))
            .padding(.bottom,4)
    }

    // MARK: - Schieberegler (Interaktion)
    private var slidersSection: some View {
        VStack(spacing:10) {
            Text("Tippe auf die Schieberegler!")
                .font(.system(size:13,weight:.semibold,design:.rounded))
                .foregroundColor(.white.opacity(0.8))

            // Oberer Schieberegler (Screenshot 3: horizontal, verbindet beide Seiten)
            horizontalSlider(value:$sliderLeft, color:Color(red:1,green:0.82,blue:0.1), label:"Linker Regler") {
                playerProgress = min(1, playerProgress + sliderLeft * 0.08)
            }

            // Unterer Schieberegler
            horizontalSlider(value:$sliderRight, color:Color(red:0.55,green:0.75,blue:1.0), label:"Rechter Regler") {
                playerProgress = min(1, playerProgress + sliderRight * 0.06)
            }
        }
        .padding(.horizontal,24)
        .padding(.vertical,12)
        .background(Color.black.opacity(0.28))
        .cornerRadius(14)
        .padding(.horizontal,16)
    }

    private func horizontalSlider(value:Binding<CGFloat>, color:Color, label:String, onTap:@escaping ()->Void) -> some View {
        VStack(alignment:.leading,spacing:4) {
            Text(label).font(.system(size:11,weight:.medium)).foregroundColor(.white.opacity(0.6))
            ZStack(alignment:.leading) {
                // Schiene
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(height:8)

                // Füllung
                Capsule()
                    .fill(color)
                    .frame(width:max(8, (UIScreen.main.bounds.width-72)*value.wrappedValue), height:8)
                    .animation(.easeOut(duration:0.2), value:value.wrappedValue)

                // Kreis (wie in Screenshot 3 — die weißen Kreise auf den Schienen)
                HStack {
                    // Linker Kreis
                    Circle()
                        .fill(Color.white)
                        .frame(width:18,height:18)
                        .overlay(Circle().strokeBorder(Color(red:0.45,green:0.35,blue:0.55),lineWidth:2))
                        .shadow(color:.black.opacity(0.2),radius:2,x:0,y:1)

                    Spacer()

                    // Rechter Kreis (beweglich)
                    Circle()
                        .fill(Color.white)
                        .frame(width:20,height:20)
                        .overlay(Circle().strokeBorder(color,lineWidth:2.5))
                        .shadow(color:color.opacity(0.4),radius:3,x:0,y:1)
                        .offset(x: -(UIScreen.main.bounds.width-72)*(1-value.wrappedValue))
                        .animation(.easeOut(duration:0.2), value:value.wrappedValue)

                    Spacer().frame(width:8)
                }
                .frame(height:20)
            }
            .onTapGesture {
                let r = Double.random(in:0.4...1.0)
                value.wrappedValue = r
                onTap()
            }
        }
    }

    // MARK: - Logik
    private func startChallenge() {
        pulseHand = true
        Timer.scheduledTimer(withTimeInterval:1, repeats:true) { t in
            if finished { t.invalidate(); return }
            timeLeft -= 1
            // Gegner füllt automatisch (langsamer)
            enemyProgress = min(1, enemyProgress + 0.022)
            if timeLeft <= 0 || playerProgress >= 1 || enemyProgress >= 1 {
                t.invalidate()
                finishChallenge()
            }
        }
    }

    private func finishChallenge() {
        finished = true
        let won = playerProgress >= enemyProgress
        let stars = won ? (playerProgress > 0.8 ? 3 : 2) : 1
        DispatchQueue.main.asyncAfter(deadline:.now()+0.6) {
            gs.complete(level.id, stars: stars)
        }
    }
}

// MARK: - Sanduhr-Hälfte (Form)
struct HourglassHalf: Shape {
    let isPlayer: Bool   // rechts oder links

    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let mid = rect.midX
        var p = Path()

        if isPlayer {
            // Rechte Hälfte: breiter oben, schmaler zur Mitte, dann wieder breiter
            p.move(to: CGPoint(x:mid-4, y:rect.minY))
            p.addLine(to: CGPoint(x:rect.maxX, y:rect.minY))
            p.addLine(to: CGPoint(x:rect.maxX, y:h*0.38))
            p.addLine(to: CGPoint(x:mid+8, y:h*0.5))
            p.addLine(to: CGPoint(x:rect.maxX, y:h*0.62))
            p.addLine(to: CGPoint(x:rect.maxX, y:rect.maxY))
            p.addLine(to: CGPoint(x:mid-4, y:rect.maxY))
            p.closeSubpath()
        } else {
            // Linke Hälfte: gespiegelt
            p.move(to: CGPoint(x:mid+4, y:rect.minY))
            p.addLine(to: CGPoint(x:rect.minX, y:rect.minY))
            p.addLine(to: CGPoint(x:rect.minX, y:h*0.38))
            p.addLine(to: CGPoint(x:mid-8, y:h*0.5))
            p.addLine(to: CGPoint(x:rect.minX, y:h*0.62))
            p.addLine(to: CGPoint(x:rect.minX, y:rect.maxY))
            p.addLine(to: CGPoint(x:mid+4, y:rect.maxY))
            p.closeSubpath()
        }
        return p
    }
}
