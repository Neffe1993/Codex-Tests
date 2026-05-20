import SwiftUI

// MARK: - Haupt-Rohr-Puzzle View (Screenshot 4 Stil)
struct PipePuzzleView: View {
    @EnvironmentObject var gs: GameState
    let config: PipeLevelConfig

    @State private var joints: [JointDef] = []
    @State private var coinFill: Double = 0          // 0…1
    @State private var timeLeft: Double = 0
    @State private var flowing = false
    @State private var finished = false
    @State private var showHintHand = true
    @State private var hintJointIdx: Int = 1
    @State private var handOffset: CGSize = .zero
    @State private var handOpacity: Double = 1
    @State private var coinPhase: Double = 0

    // Rohrstärke (wie im Screenshot: dick)
    private let pipeW: CGFloat = 40
    // Containerpos relativ zu joint.last
    private let fieldSize = CGSize(width: C, height: C)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            snowParticles

            VStack(spacing:0) {
                header
                gameField
                    .padding(.horizontal,12)
                    .padding(.top,8)
                progressBar
                    .padding(.horizontal,20)
                    .padding(.top,8)
                Spacer()
                bottomBar
            }
        }
        .onAppear(perform: setup)
    }

    // MARK: - Hintergrund
    private var bg: some View {
        LinearGradient(colors:[config.bgColorTop, config.bgColorBot],
                       startPoint:.top, endPoint:.bottom)
    }

    // MARK: - Schneepartikel
    private var snowParticles: some View {
        ZStack {
            ForEach(0..<14, id:\.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double([0.35,0.25,0.45,0.30,0.40][i%5])))
                    .frame(width:CGFloat([6,4,8,5,7,3,9,4,6,5,7,4,8,5][i]))
                    .position(x:CGFloat([30,90,155,215,280,335,370,50,120,200,265,310,380,70][i]),
                              y:CGFloat([80,200,120,320,180,80,260,350,140,280,100,380,50,300][i]))
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Kopfzeile
    private var header: some View {
        ZStack {
            LinearGradient(colors:[Color(red:0.78,green:0.08,blue:0.08),Color(red:0.88,green:0.14,blue:0.14)],
                           startPoint:.top, endPoint:.bottom)
            HStack(alignment:.center) {
                Button(action:{ gs.screen = .map }) {
                    ZStack {
                        Circle().fill(Color.black.opacity(0.35)).frame(width:36,height:36)
                        Image(systemName:"xmark").font(.system(size:14,weight:.bold)).foregroundColor(.white)
                    }
                }
                .padding(.leading,16)

                Spacer()

                VStack(spacing:1) {
                    Text(config.title)
                        .font(.system(size:22,weight:.black,design:.rounded))
                        .italic().foregroundColor(.white)
                        .shadow(color:.black.opacity(0.3), radius:2, x:1, y:2)
                    Text("Level \(config.id+1) • \(config.subtitle)")
                        .font(.system(size:11,weight:.medium)).foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                // Countdown
                timerBadge.padding(.trailing,16)
            }
            .padding(.top,50).padding(.bottom,12)
        }
    }

    private var timerBadge: some View {
        HStack(spacing:4) {
            Image(systemName:"clock.fill").foregroundColor(.white).font(.system(size:12))
            Text(String(format:"%.0f",max(0,timeLeft)))
                .font(.system(size:16,weight:.black,design:.rounded))
                .foregroundColor(timeLeft < 10 ? Color(red:1,green:0.85,blue:0.2) : .white)
                .animation(nil, value:timeLeft)
        }
        .padding(.horizontal,10).padding(.vertical,5)
        .background(Capsule().fill(Color.black.opacity(timeLeft < 10 ? 0.55 : 0.3)))
        .overlay(Capsule().strokeBorder(timeLeft < 10 ? Color(red:1,green:0.85,blue:0.2).opacity(0.7) : .clear, lineWidth:1.5))
    }

    // MARK: - Spielfeld
    private var gameField: some View {
        ZStack {
            // Spielfeld-Karte
            RoundedRectangle(cornerRadius:20)
                .fill(Color.white.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius:20).strokeBorder(Color.white.opacity(0.18), lineWidth:1.5))

            // Rohr
            if joints.count >= 2 {
                pipeShape
            }

            // Münzhaufen am Eingang (erstes Gelenk)
            if let first = joints.first {
                coinPile(at: first.pos)
            }

            // Gelenke + Querstäbe
            jointLayer

            // Hand-Hinweis
            if showHintHand && joints.count > hintJointIdx {
                handHint(at: joints[hintJointIdx].pos)
            }

            // Container + Charakter (letztes Gelenk)
            if let last = joints.last {
                containerCharacter(at: last.pos)
            }
        }
        .frame(width: fieldSize.width, height: fieldSize.height)
        .clipped()
    }

    // MARK: - Rohr-Form
    private var pipeShape: some View {
        ZStack {
            // Äußere dunkle Schicht (lila/violett)
            smoothPipePath(width: pipeW)
                .stroke(Color(red:0.42,green:0.08,blue:0.62),
                        style: StrokeStyle(lineWidth: pipeW, lineCap:.round, lineJoin:.round))

            // Innere helle Schicht (hellblau/türkis — wie im Screenshot)
            smoothPipePath(width: pipeW-8)
                .stroke(Color(red:0.48,green:0.72,blue:0.88).opacity(0.85),
                        style: StrokeStyle(lineWidth: pipeW-12, lineCap:.round, lineJoin:.round))

            // Highlight-Glanz
            smoothPipePath(width: pipeW-20)
                .stroke(Color.white.opacity(0.22),
                        style: StrokeStyle(lineWidth: 8, lineCap:.round, lineJoin:.round))

            // Münzfluss (fahrende Münzen)
            if flowing {
                coinFlow
            }
        }
    }

    // Smooth Bezier-Kurve durch alle Gelenke
    private func smoothPipePath(width: CGFloat) -> Path {
        guard joints.count >= 2 else { return Path() }
        var path = Path()
        path.move(to: joints[0].pos)
        if joints.count == 2 {
            path.addLine(to: joints[1].pos)
        } else {
            // Catmull-Rom-ähnliche Kurven durch alle Punkte
            for i in 1..<joints.count {
                let prev = joints[i-1].pos
                let curr = joints[i].pos
                if i < joints.count-1 {
                    let next = joints[i+1].pos
                    let cp1 = CGPoint(x: prev.x + (curr.x-prev.x)*0.5,
                                      y: prev.y + (curr.y-prev.y)*0.5)
                    let cp2 = CGPoint(x: curr.x - (next.x-prev.x)*0.15,
                                      y: curr.y - (next.y-prev.y)*0.15)
                    path.addCurve(to: curr, control1: cp1, control2: cp2)
                } else {
                    path.addLine(to: curr)
                }
            }
        }
        return path
    }

    // MARK: - Münzfluss-Animation
    private var coinFlow: some View {
        TimelineView(.animation(minimumInterval: 0.016)) { tl in
            ZStack {
                ForEach(0..<8, id:\.self) { i in
                    Circle()
                        .fill(Color(red:1,green:0.85,blue:0.12))
                        .frame(width:9,height:9)
                        .shadow(color:.yellow.opacity(0.8), radius:4)
                        .position(flowPosition(particle:i, time:tl.date.timeIntervalSinceReferenceDate))
                }
            }
        }
    }

    private func flowPosition(particle: Int, time: TimeInterval) -> CGPoint {
        guard joints.count >= 2 else { return joints.first?.pos ?? .zero }
        let period = 1.6
        let offset = Double(particle) / 8.0
        let t = ((time / period) + offset).truncatingRemainder(dividingBy: 1.0)
        return pointOnPath(t: t)
    }

    private func pointOnPath(t: Double) -> CGPoint {
        let pts = joints.map(\.pos)
        guard pts.count >= 2 else { return pts.first ?? .zero }
        let seg = Int(t * Double(pts.count-1))
        let segT = t * Double(pts.count-1) - Double(seg)
        let a = pts[min(seg, pts.count-1)]
        let b = pts[min(seg+1, pts.count-1)]
        return CGPoint(x: a.x + (b.x-a.x)*segT, y: a.y + (b.y-a.y)*segT)
    }

    // MARK: - Münzhaufen (Eingang)
    private func coinPile(at pos: CGPoint) -> some View {
        ZStack {
            ForEach(0..<16, id:\.self) { i in
                let angle = Double(i) / 16.0 * .pi * 2
                let r = CGFloat([0,8,14,10,5,12,16,7,11,4,9,13,6,15,3,10][i])
                Circle()
                    .fill(Color(red:1,green:CGFloat(0.72+Double(i%3)*0.05),blue:0.08))
                    .frame(width:CGFloat([11,9,10,8,12,9,10,11,8,10,9,11,8,10,9,11][i]),
                           height:CGFloat([7,6,7,5,7,6,7,6,5,6,7,6,5,7,6,7][i]))
                    .offset(x:CGFloat(cos(angle))*r, y:CGFloat(sin(angle))*r - 4)
            }
        }
        .position(pos)
    }

    // MARK: - Gelenke & Querstäbe
    private var jointLayer: some View {
        ZStack {
            // Querstäbe (wie im Screenshot: weiße Linien zwischen Gelenken)
            ForEach(0..<joints.count, id:\.self) { i in
                if joints[i].hasBar && i < joints.count-1 {
                    crossBar(from: joints[i].pos, to: joints[i+1].pos)
                }
            }
            // Gelenk-Kreise
            ForEach(joints.indices, id:\.self) { i in
                jointCircle(index: i)
            }
        }
    }

    private func crossBar(from a: CGPoint, to b: CGPoint) -> some View {
        let mid = CGPoint(x:(a.x+b.x)/2, y:(a.y+b.y)/2)
        let len = sqrt(pow(b.x-a.x,2)+pow(b.y-a.y,2)) * 0.55
        let angle = atan2(b.y-a.y, b.x-a.x)
        return ZStack {
            // Querstab
            Capsule()
                .fill(Color.white.opacity(0.7))
                .frame(width:max(len,20), height:3.5)
            // Endpunkte
            Circle().fill(Color.white.opacity(0.55)).frame(width:7,height:7)
                .offset(x:-len/2, y:0)
            Circle().fill(Color.white.opacity(0.55)).frame(width:7,height:7)
                .offset(x:len/2, y:0)
        }
        .rotationEffect(.radians(angle))
        .position(mid)
    }

    @ViewBuilder
    private func jointCircle(index: Int) -> some View {
        let j = joints[index]
        ZStack {
            if !j.fixed {
                // Äußerer Glanz-Ring (nur bewegliche)
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width:32,height:32)
            }
            // Hauptkreis — wie im Screenshot: weißer Kreis, lila Rand
            Circle()
                .fill(Color.white)
                .frame(width: j.fixed ? 14 : 24, height: j.fixed ? 14 : 24)
                .shadow(color:.black.opacity(0.28), radius:3, x:0, y:2)
            Circle()
                .strokeBorder(
                    j.fixed
                        ? Color(red:0.42,green:0.08,blue:0.62)
                        : Color(red:0.60,green:0.20,blue:0.85),
                    lineWidth: j.fixed ? 2 : 3
                )
                .frame(width: j.fixed ? 14 : 24, height: j.fixed ? 14 : 24)
            if j.fixed {
                Circle()
                    .fill(Color(red:0.42,green:0.08,blue:0.62))
                    .frame(width:6,height:6)
            }
        }
        .position(j.pos)
        .gesture(
            j.fixed ? nil :
            DragGesture(minimumDistance:0)
                .onChanged { v in
                    showHintHand = false
                    let clamped = CGPoint(
                        x: max(pipeW/2, min(fieldSize.width - pipeW/2, v.location.x)),
                        y: max(pipeW/2, min(fieldSize.height - pipeW/2, v.location.y))
                    )
                    joints[index].pos = clamped
                    updateFlow()
                }
        )
    }

    // MARK: - Hand-Hinweis
    private func handHint(at pos: CGPoint) -> some View {
        Image(systemName:"hand.point.up.left.fill")
            .font(.system(size:32))
            .foregroundColor(.white)
            .shadow(color:.black.opacity(0.4), radius:3, x:1, y:2)
            .position(CGPoint(x:pos.x+38, y:pos.y-22))
            .modifier(BreathingModifier())
    }

    // MARK: - Container + Charakter
    private func containerCharacter(at pos: CGPoint) -> some View {
        ZStack {
            // Glas-Behälter (wie im Screenshot: lila Deckel, blauer Körper)
            ZStack {
                // Körper
                RoundedRectangle(cornerRadius:9)
                    .fill(Color(red:0.38,green:0.68,blue:0.82).opacity(0.65))
                    .frame(width:40,height:50)
                    .overlay(
                        RoundedRectangle(cornerRadius:9)
                            .strokeBorder(Color.white.opacity(0.55), lineWidth:1.5)
                    )
                // Füllstand
                if coinFill > 0.02 {
                    VStack(spacing:0) {
                        Spacer()
                        RoundedRectangle(cornerRadius:5)
                            .fill(LinearGradient(
                                colors:[Color(red:1,green:0.85,blue:0.12), Color(red:0.95,green:0.65,blue:0.05)],
                                startPoint:.top, endPoint:.bottom
                            ))
                            .frame(width:33, height:max(4, 42*coinFill))
                            .animation(.easeOut(duration:0.3), value:coinFill)
                    }
                    .frame(width:36,height:46)
                    .clipped()
                }
                // Lila Deckel (wie im Screenshot)
                RoundedRectangle(cornerRadius:5)
                    .fill(Color(red:0.45,green:0.12,blue:0.65))
                    .frame(width:46,height:9)
                    .offset(y:-29)
            }
            .offset(y:-32)

            // Charakter (Mann + Kind)
            HStack(spacing:-6) {
                CharacterMan().scaleEffect(0.62)
                CharacterChild().scaleEffect(0.52).offset(y:8)
            }
            .offset(y:10)

            // Prozent
            Text("\(Int(coinFill*100))%")
                .font(.system(size:13,weight:.black,design:.rounded))
                .foregroundColor(.white)
                .padding(.horizontal,9).padding(.vertical,3)
                .background(Capsule().fill(Color(red:0.30,green:0.10,blue:0.52)))
                .offset(y:52)
        }
        .position(pos)
        .offset(y:22)
    }

    // MARK: - Fortschrittsbalken
    private var progressBar: some View {
        VStack(spacing:5) {
            HStack {
                Text(flowStatus)
                    .font(.system(size:12,weight:.semibold,design:.rounded))
                    .foregroundColor(.white.opacity(0.85))
                Spacer()
                Text("Ziel: \(Int(config.targetPercent*100))%")
                    .font(.system(size:12,weight:.medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            GeometryReader { geo in
                ZStack(alignment:.leading) {
                    Capsule().fill(Color.white.opacity(0.2)).frame(height:10)
                    // Hintergrund-Ziel-Marker
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(width:geo.size.width*config.targetPercent, height:10)
                    // Füllung
                    Capsule()
                        .fill(LinearGradient(
                            colors:[Color(red:1,green:0.85,blue:0.12), Color(red:0.95,green:0.55,blue:0.05)],
                            startPoint:.leading, endPoint:.trailing
                        ))
                        .frame(width:max(6, geo.size.width*coinFill), height:10)
                        .animation(.easeOut(duration:0.25), value:coinFill)
                    // Ziel-Linie
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width:2, height:14)
                        .offset(x:geo.size.width*config.targetPercent - 1)
                }
            }
            .frame(height:10)

            Text("Bewege die ○ Gelenke — lenke die Münzen zum Behälter")
                .font(.system(size:11,weight:.medium))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical,8)
        .padding(.horizontal,4)
    }

    private var flowStatus: String {
        if finished { return coinFill >= config.targetPercent ? "✓ Ziel erreicht!" : "Zeit abgelaufen" }
        return flowing ? "Münzen fließen..." : "Gelenke anpassen..."
    }

    // MARK: - Untere Leiste
    private var bottomBar: some View {
        HStack {
            Button(action:{ gs.screen = .map }) {
                ZStack {
                    RoundedRectangle(cornerRadius:14)
                        .fill(Color(red:0.25,green:0.55,blue:0.35))
                        .frame(width:54,height:54)
                        .shadow(color:.black.opacity(0.3), radius:4, x:0, y:3)
                    Image(systemName:"map.fill")
                        .font(.system(size:22)).foregroundColor(.white)
                }
            }
            Spacer()
            // Neustart-Button
            Button(action:{ reset() }) {
                ZStack {
                    RoundedRectangle(cornerRadius:14)
                        .fill(Color.white.opacity(0.15))
                        .frame(width:54,height:54)
                        .overlay(RoundedRectangle(cornerRadius:14).strokeBorder(Color.white.opacity(0.25),lineWidth:1.5))
                    Image(systemName:"arrow.clockwise")
                        .font(.system(size:22)).foregroundColor(.white)
                }
            }
            Spacer()
            Button(action:{}) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors:[Color(red:0.35,green:0.78,blue:0.25), Color(red:0.18,green:0.58,blue:0.12)],
                                             startPoint:.top, endPoint:.bottom))
                        .frame(width:54,height:54)
                        .shadow(color:.green.opacity(0.5), radius:4, x:0, y:3)
                    Image(systemName:"questionmark")
                        .font(.system(size:22,weight:.black)).foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal,20)
        .padding(.bottom,12)
        .padding(.top,8)
    }

    // MARK: - Logik
    private func setup() {
        joints = config.joints
        timeLeft = config.timeLimit
        coinFill = 0
        flowing = true
        hintJointIdx = joints.indices.first(where:{ !joints[$0].fixed }) ?? 1
        startTimer()
        startCoinFlow()
    }

    private func reset() {
        joints = config.joints
        coinFill = 0
        flowing = true
        finished = false
        timeLeft = config.timeLimit
        showHintHand = true
        hintJointIdx = joints.indices.first(where:{ !joints[$0].fixed }) ?? 1
    }

    private func updateFlow() {
        flowing = pathIsReasonable()
    }

    private func pathIsReasonable() -> Bool {
        for i in 1..<joints.count {
            let d = dist(joints[i-1].pos, joints[i].pos)
            if d < 18 || d > 200 { return false }
        }
        return true
    }

    private func dist(_ a:CGPoint, _ b:CGPoint) -> CGFloat {
        sqrt(pow(b.x-a.x,2)+pow(b.y-a.y,2))
    }

    private func startCoinFlow() {
        guard !finished else { return }
        let rate = 0.018
        if flowing {
            withAnimation(.linear(duration:0.3)) { coinFill = min(1, coinFill + rate) }
        }
        DispatchQueue.main.asyncAfter(deadline:.now()+0.3) { startCoinFlow() }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval:0.1, repeats:true) { t in
            guard !finished else { t.invalidate(); return }
            timeLeft = max(0, timeLeft - 0.1)
            if timeLeft <= 0 { t.invalidate(); finish() }
        }
    }

    private func finish() {
        finished = true
        flowing = false
        let pct = coinFill / config.targetPercent
        let s = pct >= 1.0 ? 3 : pct >= 0.65 ? 2 : coinFill > 0.05 ? 1 : 0
        DispatchQueue.main.asyncAfter(deadline:.now()+0.5) {
            gs.complete(config.id, stars: max(1,s))
        }
    }
}

// MARK: - Atemanimation für den Hand-Hinweis
struct BreathingModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration:0.7).repeatForever(autoreverses:true)) {
                    scale = 1.12
                }
            }
    }
}
