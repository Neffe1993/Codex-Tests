import SwiftUI

// Hourglass-Challenge wird für Level mit .hourglass Typ genutzt (aktuell nicht direkt
// aus der Map aufgerufen, aber die View bleibt vollständig als optionaler Modus)
struct HourglassChallengeView: View {
    @EnvironmentObject var gs: GameState
    let config: PipeLevelConfig

    @State private var playerProgress: Double = 0
    @State private var enemyProgress:  Double = 0
    @State private var timeLeft: Double = 30
    @State private var finished = false
    @State private var tapCount = 0

    var body: some View {
        ZStack {
            LinearGradient(colors:[Color(red:0.22,green:0.18,blue:0.32), Color(red:0.36,green:0.28,blue:0.48)],
                           startPoint:.top, endPoint:.bottom)
                .ignoresSafeArea()

            VStack(spacing:0) {
                header
                Spacer()
                arena
                Spacer()
                tapButton
                Spacer().frame(height:40)
            }
        }
        .onAppear(perform:startChallenge)
    }

    // MARK: - Kopfzeile
    private var header: some View {
        ZStack {
            LinearGradient(colors:[Color(red:0.78,green:0.08,blue:0.08),Color(red:0.88,green:0.14,blue:0.14)],
                           startPoint:.top, endPoint:.bottom)
            HStack {
                Button(action:{ gs.screen = .map }) {
                    ZStack {
                        Circle().fill(Color.black.opacity(0.35)).frame(width:36,height:36)
                        Image(systemName:"xmark").font(.system(size:14,weight:.bold)).foregroundColor(.white)
                    }
                }
                .padding(.leading,16)
                Spacer()
                VStack(spacing:2) {
                    Text("Stell dich der Herausforderung!")
                        .font(.system(size:20,weight:.black,design:.rounded))
                        .italic().foregroundColor(.white)
                        .shadow(color:.black.opacity(0.3), radius:2, x:1, y:2)
                    Text(String(format:"%.0f Sekunden verbleibend",max(0,timeLeft)))
                        .font(.system(size:12,weight:.medium))
                        .foregroundColor(timeLeft < 10 ? Color(red:1,green:0.85,blue:0.2) : .white.opacity(0.75))
                }
                Spacer()
                HStack(spacing:4) {
                    Image(systemName:"star.fill").foregroundColor(Color(red:1,green:0.85,blue:0.15)).font(.system(size:12))
                    Text("\(gs.stars)").font(.system(size:13,weight:.black,design:.rounded)).foregroundColor(.white)
                }
                .padding(.horizontal,10).padding(.vertical,5)
                .background(Color.black.opacity(0.3)).clipShape(Capsule())
                .padding(.trailing,16)
            }
            .padding(.top,50).padding(.bottom,12)
        }
    }

    // MARK: - Arena
    private var arena: some View {
        HStack(spacing:2) {
            // Gegner-Seite (links)
            side(label:"Gegner", progress:enemyProgress,
                 topColor:Color(red:0.72,green:0.12,blue:0.12),
                 fillColor:Color(red:0.9,green:0.18,blue:0.18),
                 isPlayer:false)

            // Trennlinie
            Rectangle()
                .fill(Color(red:0.55,green:0.42,blue:0.72))
                .frame(width:5)

            // Spieler-Seite (rechts)
            side(label:"Du", progress:playerProgress,
                 topColor:Color(red:0.55,green:0.38,blue:0.05),
                 fillColor:Color(red:1,green:0.82,blue:0.12),
                 isPlayer:true)
        }
        .frame(height:320)
        .clipShape(RoundedRectangle(cornerRadius:18))
        .overlay(RoundedRectangle(cornerRadius:18).strokeBorder(Color.white.opacity(0.14),lineWidth:1.5))
        .padding(.horizontal,16)
    }

    private func side(label:String, progress:Double, topColor:Color, fillColor:Color, isPlayer:Bool) -> some View {
        ZStack(alignment:.bottom) {
            // Hintergrund
            Rectangle()
                .fill(topColor.opacity(0.18))

            // Füllung von unten
            Rectangle()
                .fill(LinearGradient(colors:[fillColor.opacity(0.85), fillColor.opacity(0.55)],
                                     startPoint:.bottom, endPoint:.top))
                .frame(maxHeight: .infinity)
                .scaleEffect(y:progress, anchor:.bottom)
                .animation(.spring(response:0.35,dampingFraction:0.75), value:progress)

            VStack {
                // Icon oben
                HStack(spacing:-1) {
                    ForEach(0..<5,id:\.self) { _ in
                        Image(systemName:isPlayer ? "circle.fill" : "diamond.fill")
                            .font(.system(size:10))
                            .foregroundColor(fillColor)
                    }
                }
                .padding(.top,10)
                Spacer()
                // Charakter
                Group {
                    if isPlayer { CharacterWoman().scaleEffect(0.58) }
                    else { CharacterChild().scaleEffect(0.65) }
                }
                .frame(height:60)
                // Prozent
                Text("\(Int(progress*100))%")
                    .font(.system(size:15,weight:.black,design:.rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal,10).padding(.vertical,4)
                    .background(Capsule().fill(isPlayer ? topColor : Color(red:0.45,green:0.08,blue:0.08)))
                    .padding(.bottom,10)
            }

            // Label
            VStack {
                Text(label)
                    .font(.system(size:12,weight:.bold)).foregroundColor(.white.opacity(0.7))
                    .padding(.top,44)
                Spacer()
            }
        }
        .frame(maxWidth:.infinity)
    }

    // MARK: - Tipp-Button
    private var tapButton: some View {
        VStack(spacing:10) {
            Text("Tippe so schnell du kannst!")
                .font(.system(size:14,weight:.semibold,design:.rounded))
                .foregroundColor(.white.opacity(0.8))
            Button(action:tap) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors:[Color(red:0.95,green:0.62,blue:0.05), Color(red:0.82,green:0.42,blue:0.05)],
                                             startPoint:.top, endPoint:.bottom))
                        .frame(width:100,height:100)
                        .shadow(color:.orange.opacity(0.55),radius:12,x:0,y:4)
                    Image(systemName:"hand.tap.fill")
                        .font(.system(size:36)).foregroundColor(.white)
                }
            }
            .disabled(finished)
            Text("\(tapCount) Tipps")
                .font(.system(size:12,weight:.medium)).foregroundColor(.white.opacity(0.55))
        }
    }

    private func tap() {
        guard !finished else { return }
        tapCount += 1
        withAnimation { playerProgress = min(1, playerProgress + 0.045) }
        if playerProgress >= 1 { finish() }
    }

    private func startChallenge() {
        Timer.scheduledTimer(withTimeInterval:0.6, repeats:true) { t in
            guard !finished else { t.invalidate(); return }
            withAnimation { enemyProgress = min(1, enemyProgress + 0.032) }
            timeLeft -= 0.6
            if timeLeft <= 0 || enemyProgress >= 1 { t.invalidate(); finish() }
        }
    }

    private func finish() {
        finished = true
        let won = playerProgress >= enemyProgress
        let s = won ? (playerProgress > 0.8 ? 3 : 2) : 1
        DispatchQueue.main.asyncAfter(deadline:.now()+0.6) { gs.complete(config.id, stars:s) }
    }
}
