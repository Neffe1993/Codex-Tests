import SwiftUI

// MARK: - Rohr-Puzzle (Screenshot 4 Stil)
// Gewundenes Rohr aus verbundenen Segmenten.
// Die weißen Gelenk-Kreise lassen sich verschieben um den Münzfluss umzuleiten.

struct PipeJoint: Identifiable {
    let id = UUID()
    var position: CGPoint
    var isFixed: Bool = false
}

struct PipeMiniGameView: View {
    @EnvironmentObject var gs: GameState
    let level: LevelInfo

    // Gelenke definieren die Form des Rohres
    @State private var joints: [PipeJoint] = Self.initialJoints()
    @State private var coinProgress: Double = 0
    @State private var isFlowing = false
    @State private var dragIndex: Int? = nil
    @State private var animateCoin = false
    @State private var timeLeft: Double = 45
    @State private var finished = false

    private let target: Double = 1.0
    private let pipeWidth: CGFloat = 38
    private let containerSize: CGFloat = 280

    var body: some View {
        ZStack {
            // Hintergrund (Schnee/Winter)
            LinearGradient(colors:[Color(red:0.62,green:0.75,blue:0.92), Color(red:0.82,green:0.90,blue:0.98)],
                           startPoint:.top, endPoint:.bottom)
                .ignoresSafeArea()

            // Schneeboden
            VStack { Spacer()
                Ellipse().fill(Color.white.opacity(0.85)).frame(height:100).padding(.horizontal,-20)
            }

            VStack(spacing:0) {
                // Kopfzeile
                ZStack {
                    LinearGradient(colors:[Color(red:0.78,green:0.08,blue:0.08),Color(red:0.88,green:0.14,blue:0.14)],
                                   startPoint:.top, endPoint:.bottom)
                    HStack {
                        CloseButton { gs.screen = .map }
                            .padding(.leading,16)
                        Spacer()
                        Text("Spiele Minispiele!")
                            .font(.system(size:26, weight:.black, design:.rounded))
                            .italic()
                            .foregroundColor(.white)
                            .shadow(color:.black.opacity(0.3), radius:2, x:1, y:2)
                        Spacer()
                        // Timer
                        HStack(spacing:3) {
                            Image(systemName:"clock.fill").foregroundColor(.white).font(.system(size:13))
                            Text(String(format:"%.0f",timeLeft))
                                .font(.system(size:16,weight:.black,design:.rounded))
                                .foregroundColor(timeLeft < 10 ? Color(red:1,green:0.8,blue:0.2) : .white)
                        }
                        .padding(.trailing,16)
                    }
                    .padding(.top, 50).padding(.bottom,12)
                }

                // Spielfeld
                ZStack {
                    // Rohr zeichnen
                    pipeBody

                    // Münzfluss-Animation
                    if isFlowing {
                        coinParticles
                    }

                    // Gelenke (beweglich)
                    ForEach(joints.indices, id:\.self) { i in
                        jointView(index: i)
                    }

                    // Münzhaufen am Eingang (oben)
                    coinPileTop

                    // Charakter + Behälter unten rechts
                    characterWithJar
                }
                .frame(width: containerSize, height: containerSize)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius:16))
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // Fortschritt
                progressSection

                Spacer()

                BottomNavBar(onMap:{ gs.screen = .map }, stars: gs.stars)
            }
        }
        .onAppear { startTimer() }
        .onChange(of: coinProgress) { v in
            if v >= target && !finished { finishLevel() }
        }
    }

    // MARK: - Rohr-Darstellung
    private var pipeBody: some View {
        ZStack {
            // Rohr-Fläche (gefüllt)
            pipeFillShape
                .fill(
                    LinearGradient(colors:[Color(red:0.38,green:0.55,blue:0.95), Color(red:0.28,green:0.42,blue:0.82)],
                                   startPoint:.topLeading, endPoint:.bottomTrailing)
                )
                .opacity(0.85)

            // Rohr-Umriss
            pipePath
                .stroke(Color(red:0.55,green:0.22,blue:0.75), style:StrokeStyle(lineWidth: pipeWidth, lineCap:.round, lineJoin:.round))

            // Rohrhighlight
            pipePath
                .stroke(Color.white.opacity(0.18), style:StrokeStyle(lineWidth: pipeWidth*0.4, lineCap:.round, lineJoin:.round))
        }
    }

    private var pipePath: Path {
        var path = Path()
        guard joints.count >= 2 else { return path }
        path.move(to: joints[0].position)
        for j in joints.dropFirst() {
            path.addLine(to: j.position)
        }
        return path
    }

    private var pipeFillShape: Path {
        var path = Path()
        guard joints.count >= 2 else { return path }
        let half = pipeWidth / 2
        // Vereinfachte Füllung: Umriss links+rechts des Pfades
        path.move(to: joints[0].position)
        for j in joints.dropFirst() { path.addLine(to: j.position) }
        for j in joints.dropFirst().reversed() {
            path.addLine(to: CGPoint(x: j.position.x + half, y: j.position.y + half))
        }
        path.closeSubpath()
        return path
    }

    // MARK: - Gelenk-View
    private func jointView(index: Int) -> some View {
        let j = joints[index]
        return ZStack {
            // Verbindungsstab (horizontal) — wie in Screenshot 4
            if !j.isFixed && index > 0 && index < joints.count-1 {
                HStack(spacing:0) {
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width:10,height:10)
                    Rectangle()
                        .fill(Color.white.opacity(0.55))
                        .frame(width:30,height:3)
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width:10,height:10)
                }
                .offset(x:0, y:-22)
            }

            // Hauptgelenk-Kreis
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: j.isFixed ? 18 : 22, height: j.isFixed ? 18 : 22)
                    .shadow(color:.black.opacity(0.25), radius:3, x:0, y:2)
                Circle()
                    .strokeBorder(Color(red:0.55,green:0.22,blue:0.75), lineWidth: j.isFixed ? 2 : 3)
                    .frame(width: j.isFixed ? 18 : 22, height: j.isFixed ? 18 : 22)
                if j.isFixed {
                    Circle()
                        .fill(Color(red:0.55,green:0.22,blue:0.75))
                        .frame(width:7,height:7)
                }
            }
        }
        .position(j.position)
        .gesture(
            j.isFixed ? nil :
            DragGesture(minimumDistance: 0)
                .onChanged { v in
                    let clamped = CGPoint(
                        x: max(20, min(containerSize-20, v.location.x)),
                        y: max(20, min(containerSize-20, v.location.y))
                    )
                    joints[index].position = clamped
                    checkFlow()
                }
        )
    }

    // MARK: - Münzhaufen oben
    private var coinPileTop: some View {
        ZStack {
            ForEach(0..<12, id:\.self) { i in
                Circle()
                    .fill(Color(red:1,green:0.82,blue:0.1))
                    .frame(width:CGFloat.random(in:8...14), height:CGFloat.random(in:8...14))
                    .offset(x:CGFloat([-15,-5,5,15,-10,0,10,-8,8,-3,3,0][i]),
                            y:CGFloat([-4,0,-6,-2,4,2,-8,6,-2,8,-4,10][i]))
            }
        }
        .position(joints[0].position)
        .offset(y: -pipeWidth*0.5)
    }

    // MARK: - Münzpartikel fließen
    private var coinParticles: some View {
        TimelineView(.animation) { _ in
            ZStack {
                ForEach(0..<6, id:\.self) { i in
                    Circle()
                        .fill(Color(red:1,green:0.82,blue:0.1).opacity(0.85))
                        .frame(width:9,height:9)
                        .shadow(color:.yellow.opacity(0.6), radius:3)
                        .position(coinPosition(particle:i))
                }
            }
        }
    }

    private func coinPosition(particle: Int) -> CGPoint {
        guard joints.count >= 2 else { return joints[0].position }
        let t = (Date().timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy:1.8) + Double(particle)*0.3)
                 .truncatingRemainder(dividingBy: 1.8) / 1.8
        let segCount = joints.count - 1
        let segT = t * Double(segCount)
        let seg = min(Int(segT), segCount-1)
        let localT = segT - Double(seg)
        let a = joints[seg].position
        let b = joints[seg+1].position
        return CGPoint(x: a.x + (b.x-a.x)*localT, y: a.y + (b.y-a.y)*localT)
    }

    // MARK: - Charakter unten rechts
    private var characterWithJar: some View {
        ZStack {
            // Behälter (Glas)
            ZStack {
                RoundedRectangle(cornerRadius:8)
                    .fill(Color(red:0.4,green:0.75,blue:0.85).opacity(0.6))
                    .frame(width:38,height:46)
                RoundedRectangle(cornerRadius:8)
                    .strokeBorder(Color.white.opacity(0.6), lineWidth:2)
                    .frame(width:38,height:46)
                // Münzen drin
                if coinProgress > 0 {
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius:4)
                            .fill(Color(red:1,green:0.82,blue:0.1))
                            .frame(width:30, height:max(4, 38*coinProgress))
                    }
                    .frame(width:34,height:42)
                    .clipped()
                }
                // Deckel
                RoundedRectangle(cornerRadius:4)
                    .fill(Color(red:0.5,green:0.28,blue:0.72))
                    .frame(width:42,height:8)
                    .offset(y:-27)
            }
            .offset(x:0, y:-12)

            // Männlicher Charakter
            CharacterMan()

            // Prozent-Badge
            Text("\(Int(coinProgress*100))%")
                .font(.system(size:13,weight:.black,design:.rounded))
                .foregroundColor(.white)
                .padding(.horizontal,8).padding(.vertical,3)
                .background(Capsule().fill(Color(red:0.28,green:0.18,blue:0.48)))
                .offset(y:52)
        }
        .position(joints.last?.position ?? CGPoint(x:containerSize-50, y:containerSize-50))
        .offset(y:30)
    }

    // MARK: - Fortschritt
    private var progressSection: some View {
        VStack(spacing:6) {
            HStack {
                Text("Münzen gesammelt")
                    .font(.system(size:14,weight:.semibold,design:.rounded))
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(coinProgress*100))%")
                    .font(.system(size:16,weight:.black,design:.rounded))
                    .foregroundColor(Color(red:1,green:0.82,blue:0.1))
            }
            .padding(.horizontal,20)

            ZStack(alignment:.leading) {
                Capsule().fill(Color.white.opacity(0.25)).frame(height:16)
                Capsule()
                    .fill(LinearGradient(colors:[Color(red:1,green:0.85,blue:0.1), Color(red:0.95,green:0.55,blue:0.05)],
                                         startPoint:.leading, endPoint:.trailing))
                    .frame(width:max(16, (UIScreen.main.bounds.width-40)*coinProgress), height:16)
                    .animation(.easeOut(duration:0.3), value:coinProgress)
            }
            .padding(.horizontal,20)

            Text("Bewege die Gelenke ○ um das Rohr zum Behälter zu leiten")
                .font(.system(size:12,weight:.medium,design:.rounded))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal,20)
        }
        .padding(.vertical,10)
        .background(Color.black.opacity(0.25))
    }

    // MARK: - Logik
    private static func initialJoints() -> [PipeJoint] {
        // Gewundene Rohrform wie in Screenshot 4
        [
            PipeJoint(position: CGPoint(x:60, y:40), isFixed:true),   // Eingang oben links
            PipeJoint(position: CGPoint(x:150, y:40), isFixed:false),  // Beweglich
            PipeJoint(position: CGPoint(x:200, y:100), isFixed:false),
            PipeJoint(position: CGPoint(x:100, y:140), isFixed:false),
            PipeJoint(position: CGPoint(x:80, y:200), isFixed:false),
            PipeJoint(position: CGPoint(x:180, y:220), isFixed:false),
            PipeJoint(position: CGPoint(x:220, y:250), isFixed:true),  // Ausgang rechts
        ]
    }

    private func checkFlow() {
        // Fluss: Prüfe ob Ausgang nahe am Behälter-Eingang ist
        guard let last = joints.last, let charPos = joints.last?.position else { return }
        // Immer aktiv — Münzen fließen sobald Rohr "plausibel" aussieht
        let isReasonable = jointPathReasonable()
        if isReasonable && !isFlowing {
            isFlowing = true
            startCoinFlow()
        } else if !isReasonable && isFlowing {
            isFlowing = false
        }
    }

    private func jointPathReasonable() -> Bool {
        // Pfad ist "vernünftig" wenn keine überlappenden Segmente
        var ok = true
        for i in 1..<joints.count {
            let d = dist(joints[i-1].position, joints[i].position)
            if d < 20 || d > 160 { ok = false; break }
        }
        return ok
    }

    private func dist(_ a:CGPoint, _ b:CGPoint) -> CGFloat {
        sqrt(pow(b.x-a.x,2)+pow(b.y-a.y,2))
    }

    private func startCoinFlow() {
        guard !finished else { return }
        withAnimation(.linear(duration:0.4)) { coinProgress += 0.04 }
        DispatchQueue.main.asyncAfter(deadline:.now()+0.4) {
            if isFlowing && !finished { startCoinFlow() }
        }
    }

    private func startTimer() {
        isFlowing = true
        startCoinFlow()
        Timer.scheduledTimer(withTimeInterval:1, repeats:true) { t in
            if finished { t.invalidate(); return }
            timeLeft -= 1
            if timeLeft <= 0 { t.invalidate(); finishLevel() }
        }
    }

    private func finishLevel() {
        finished = true
        isFlowing = false
        let stars = coinProgress >= 0.9 ? 3 : coinProgress >= 0.6 ? 2 : 1
        DispatchQueue.main.asyncAfter(deadline:.now()+0.5) {
            gs.complete(level.id, stars: stars)
        }
    }
}

// MARK: - Männlicher Charakter
struct CharacterMan: View {
    var body: some View {
        ZStack {
            // Mütze
            RoundedRectangle(cornerRadius:4)
                .fill(Color(red:0.55,green:0.35,blue:0.15))
                .frame(width:26,height:10)
                .offset(y:-52)
            // Gesicht
            Circle()
                .fill(Color(red:0.88,green:0.70,blue:0.58))
                .frame(width:24,height:24)
                .offset(y:-42)
            // Augen
            Circle().fill(Color(red:0.2,green:0.15,blue:0.1)).frame(width:4,height:4).offset(x:-5,y:-44)
            Circle().fill(Color(red:0.2,green:0.15,blue:0.1)).frame(width:4,height:4).offset(x:5,y:-44)
            // Körper (orange Jacke)
            RoundedRectangle(cornerRadius:8)
                .fill(LinearGradient(colors:[Color(red:0.85,green:0.45,blue:0.1), Color(red:0.75,green:0.35,blue:0.08)],
                                     startPoint:.top, endPoint:.bottom))
                .frame(width:28,height:38)
                .offset(y:-20)
            // Beine
            RoundedRectangle(cornerRadius:3).fill(Color(red:0.25,green:0.32,blue:0.55)).frame(width:10,height:18).offset(x:-6,y:8)
            RoundedRectangle(cornerRadius:3).fill(Color(red:0.25,green:0.32,blue:0.55)).frame(width:10,height:18).offset(x:6,y:8)
        }
    }
}
