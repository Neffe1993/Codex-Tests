import SwiftUI

struct ResultView: View {
    @EnvironmentObject var gs: GameState
    let levelId: Int
    let starsEarned: Int

    @State private var starScales: [CGFloat] = [0,0,0]
    @State private var titleOffset: CGFloat = -40
    @State private var showReward = false
    @State private var confetti: [ConfettiPiece] = []
    @State private var fallDone = false
    @State private var glow = false

    private var won: Bool { starsEarned >= 1 }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            confettiLayer
            VStack(spacing:0) {
                Spacer()
                titleSection
                Spacer().frame(height:22)
                starRow
                Spacer().frame(height:20)
                if showReward { rewardRow }
                Spacer()
                buttonSection
                Spacer().frame(height:44)
            }
        }
        .onAppear(perform:runAnimations)
    }

    private var bg: some View {
        LinearGradient(
            colors: won
                ? [Color(red:0.06,green:0.22,blue:0.10), Color(red:0.14,green:0.46,blue:0.22)]
                : [Color(red:0.20,green:0.10,blue:0.05), Color(red:0.40,green:0.22,blue:0.08)],
            startPoint:.top, endPoint:.bottom
        )
    }

    private var confettiLayer: some View {
        ZStack {
            ForEach(confetti) { p in
                RoundedRectangle(cornerRadius:3)
                    .fill(p.color)
                    .frame(width:p.w, height:p.h)
                    .rotationEffect(.degrees(p.rot))
                    .position(x:p.x, y:fallDone ? p.y1 : p.y0)
                    .opacity(fallDone ? 0 : 0.9)
                    .animation(.easeIn(duration:p.dur).delay(p.delay), value:fallDone)
            }
        }
        .ignoresSafeArea()
    }

    private var titleSection: some View {
        VStack(spacing:6) {
            Text(titleText)
                .font(.system(size:52,weight:.black,design:.rounded))
                .italic()
                .foregroundStyle(LinearGradient(
                    colors: won ? [Color(red:1,green:0.88,blue:0.2), .orange] : [.white, Color(red:0.75,green:0.65,blue:0.5)],
                    startPoint:.top, endPoint:.bottom))
                .shadow(color:.black.opacity(0.35), radius:4, x:2, y:3)
                .offset(y:titleOffset)
                .animation(.spring(response:0.5, dampingFraction:0.65), value:titleOffset)

            Text("Level \(levelId+1) abgeschlossen")
                .font(.system(size:14,weight:.semibold,design:.rounded))
                .foregroundColor(.white.opacity(0.72))
        }
    }

    private var titleText: String {
        switch starsEarned {
        case 3: return "Perfekt!"
        case 2: return "Großartig!"
        case 1: return "Geschafft!"
        default: return "Versuch's nochmal!"
        }
    }

    private var starRow: some View {
        HStack(spacing:12) {
            ForEach(0..<3, id:\.self) { i in
                ZStack {
                    if i < starsEarned {
                        Image(systemName:"star.fill")
                            .font(.system(size: i==1 ? 60 : 46))
                            .foregroundStyle(LinearGradient(colors:[Color(red:1,green:0.92,blue:0.3),.orange], startPoint:.top, endPoint:.bottom))
                            .shadow(color:.yellow.opacity(0.75), radius:12)
                            .scaleEffect(glow ? 1.06 : 1.0)
                            .animation(.easeInOut(duration:0.9).repeatForever(autoreverses:true).delay(Double(i)*0.2), value:glow)
                    } else {
                        Image(systemName:"star")
                            .font(.system(size: i==1 ? 60 : 46))
                            .foregroundColor(.white.opacity(0.22))
                    }
                }
                .scaleEffect(starScales[i])
                .animation(.spring(response:0.4, dampingFraction:0.5).delay(Double(i)*0.22+0.4), value:starScales[i])
            }
        }
    }

    private var rewardRow: some View {
        HStack(spacing:16) {
            rewardChip(icon:"star.fill", val:"+\(starsEarned*10)", col:Color(red:1,green:0.85,blue:0.15), lbl:"Sterne")
            rewardChip(icon:"circle.fill",  val:"+\(starsEarned*25)", col:.yellow, lbl:"Münzen")
        }
        .transition(.opacity.combined(with:.scale(scale:0.85)))
    }

    private func rewardChip(icon:String, val:String, col:Color, lbl:String) -> some View {
        VStack(spacing:4) {
            HStack(spacing:5) {
                Image(systemName:icon).foregroundColor(col).font(.system(size:15))
                Text(val).font(.system(size:20,weight:.black,design:.rounded)).foregroundColor(.white)
            }
            Text(lbl).font(.system(size:11)).foregroundColor(.white.opacity(0.6))
        }
        .frame(width:112,height:64)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius:14))
        .overlay(RoundedRectangle(cornerRadius:14).strokeBorder(col.opacity(0.38),lineWidth:1.5))
    }

    private var buttonSection: some View {
        VStack(spacing:12) {
            if levelId+1 < allPipeLevels.count {
                Button(action:{ gs.screen = .pipe(levelId+1) }) {
                    HStack(spacing:8) {
                        Text("Nächstes Level")
                            .font(.system(size:19,weight:.black,design:.rounded))
                        Image(systemName:"arrow.right").font(.system(size:17,weight:.bold))
                    }
                    .foregroundColor(.white)
                    .frame(width:220,height:54)
                    .background(LinearGradient(colors:[Color(red:0.18,green:0.72,blue:0.32),Color(red:0.10,green:0.55,blue:0.22)],startPoint:.top,endPoint:.bottom))
                    .clipShape(Capsule())
                    .shadow(color:.green.opacity(0.5),radius:8,x:0,y:4)
                }
            }
            HStack(spacing:14) {
                smallBtn(icon:"arrow.clockwise", lbl:"Nochmal") { gs.screen = .pipe(levelId) }
                smallBtn(icon:"map.fill",        lbl:"Alle Level") { gs.screen = .map }
            }
        }
    }

    private func smallBtn(icon:String, lbl:String, action:@escaping()->Void) -> some View {
        Button(action:action) {
            VStack(spacing:3) {
                Image(systemName:icon).font(.system(size:20)).foregroundColor(.white)
                Text(lbl).font(.system(size:11,weight:.semibold)).foregroundColor(.white.opacity(0.8))
            }
            .frame(width:106,height:58)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius:14))
            .overlay(RoundedRectangle(cornerRadius:14).strokeBorder(Color.white.opacity(0.2),lineWidth:1))
        }
    }

    private func runAnimations() {
        confetti = (0..<50).map { _ in ConfettiPiece.random() }
        titleOffset = 0
        for i in 0..<min(starsEarned,3) {
            DispatchQueue.main.asyncAfter(deadline:.now()+Double(i)*0.22+0.38) { starScales[i] = 1 }
        }
        for i in starsEarned..<3 {
            DispatchQueue.main.asyncAfter(deadline:.now()+Double(i)*0.1+0.3) { starScales[i] = 1 }
        }
        withAnimation(.easeIn(duration:0.5).delay(0.85)) { showReward = true }
        if won {
            glow = true
            DispatchQueue.main.asyncAfter(deadline:.now()+0.3) {
                withAnimation { fallDone = true }
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let x,y0,y1,w,h,rot,dur,delay: Double
    let color: Color
    static let palette: [Color] = [.red,.orange,.yellow,.green,.blue,.purple,Color(red:1,green:0.4,blue:0.8)]
    static func random() -> ConfettiPiece {
        ConfettiPiece(x:.random(in:0...400), y0:.random(in:-30...0), y1:.random(in:720...900),
                      w:.random(in:6...14), h:.random(in:10...20), rot:.random(in:0...360),
                      dur:.random(in:1.5...3.5), delay:.random(in:0...0.9),
                      color:palette.randomElement()!)
    }
}
