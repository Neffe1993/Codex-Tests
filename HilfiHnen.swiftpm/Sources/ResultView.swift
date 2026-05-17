import SwiftUI

struct ResultView: View {
    @EnvironmentObject var gs: GameState
    let levelIndex: Int
    let stars: Int

    @State private var starScales: [CGFloat] = [0,0,0]
    @State private var titleOffset: CGFloat = -30
    @State private var showReward = false
    @State private var confetti: [ConfettiPiece] = []
    @State private var animate = false

    private let level: LevelInfo? = nil

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            confettiLayer
            VStack(spacing:0) {
                Spacer()
                titleSection
                Spacer().frame(height:20)
                starRow
                Spacer().frame(height:18)
                rewardSection
                Spacer()
                buttons
                Spacer().frame(height:50)
            }
        }
        .onAppear { animate() }
    }

    private var bg: some View {
        LinearGradient(
            colors: stars >= 2
                ? [Color(red:0.05,green:0.25,blue:0.1), Color(red:0.12,green:0.48,blue:0.22)]
                : [Color(red:0.22,green:0.12,blue:0.05), Color(red:0.42,green:0.28,blue:0.08)],
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
                    .position(x:p.x, y:animate ? p.y1 : p.y0)
                    .opacity(animate ? 0 : 1)
                    .animation(.easeIn(duration:p.dur).delay(p.delay), value:animate)
            }
        }
    }

    private var titleSection: some View {
        VStack(spacing:6) {
            Text(stars == 3 ? "Perfekt!" : stars >= 2 ? "Super!" : stars == 1 ? "Geschafft!" : "Weiter üben!")
                .font(.system(size:50,weight:.black,design:.rounded))
                .italic()
                .foregroundStyle(LinearGradient(
                    colors: stars >= 2 ? [Color(red:1,green:0.88,blue:0.2), .orange] : [.white, Color(red:0.8,green:0.7,blue:0.5)],
                    startPoint:.top, endPoint:.bottom))
                .shadow(color:.black.opacity(0.3), radius:4, x:2, y:3)
                .offset(y:titleOffset)

            Text("Level \(levelIndex+1) abgeschlossen")
                .font(.system(size:15,weight:.semibold,design:.rounded))
                .foregroundColor(.white.opacity(0.75))
        }
    }

    private var starRow: some View {
        HStack(spacing:10) {
            ForEach(0..<3) { i in
                Image(systemName: i < stars ? "star.fill" : "star")
                    .font(.system(size: i==1 ? 54 : 42))
                    .foregroundColor(i < stars ? Color(red:1,green:0.82,blue:0.1) : .white.opacity(0.25))
                    .scaleEffect(starScales[i])
                    .shadow(color: i < stars ? .yellow.opacity(0.7) : .clear, radius:8)
            }
        }
    }

    private var rewardSection: some View {
        VStack(spacing:10) {
            HStack(spacing:20) {
                rewardChip(icon:"star.fill", value:"+\(stars*10)", color:Color(red:1,green:0.82,blue:0.1), label:"Sterne")
                rewardChip(icon:"circle.fill", value:"+\(stars*25)", color:.yellow, label:"Münzen")
            }
            .opacity(showReward ? 1 : 0)
            .animation(.easeIn(duration:0.4).delay(0.9), value:showReward)
        }
    }

    private func rewardChip(icon:String, value:String, color:Color, label:String) -> some View {
        VStack(spacing:4) {
            HStack(spacing:4) {
                Image(systemName:icon).foregroundColor(color).font(.system(size:16))
                Text(value).font(.system(size:20,weight:.black,design:.rounded)).foregroundColor(.white)
            }
            Text(label).font(.system(size:11,weight:.medium)).foregroundColor(.white.opacity(0.65))
        }
        .frame(width:105,height:62)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius:14))
        .overlay(RoundedRectangle(cornerRadius:14).strokeBorder(color.opacity(0.35),lineWidth:1.5))
    }

    private var buttons: some View {
        VStack(spacing:12) {
            if levelIndex+1 < allLevels.count {
                Button(action:{ gs.screen = .scenario(levelIndex+1) }) {
                    HStack(spacing:8) {
                        Text("Weiter")
                            .font(.system(size:20,weight:.black,design:.rounded))
                        Image(systemName:"arrow.right")
                            .font(.system(size:18,weight:.bold))
                    }
                    .foregroundColor(.white)
                    .frame(width:210,height:54)
                    .background(LinearGradient(colors:[Color(red:0.18,green:0.72,blue:0.32),Color(red:0.10,green:0.55,blue:0.22)],startPoint:.top,endPoint:.bottom))
                    .clipShape(Capsule())
                    .shadow(color:.green.opacity(0.45),radius:8,x:0,y:4)
                }
            }
            HStack(spacing:12) {
                outlineButton(icon:"arrow.clockwise", label:"Nochmal") { gs.screen = .scenario(levelIndex) }
                outlineButton(icon:"map.fill", label:"Karte") { gs.screen = .map }
            }
        }
    }

    private func outlineButton(icon:String, label:String, action:@escaping()->Void) -> some View {
        Button(action:action) {
            VStack(spacing:3) {
                Image(systemName:icon).font(.system(size:20)).foregroundColor(.white)
                Text(label).font(.system(size:12,weight:.semibold,design:.rounded)).foregroundColor(.white.opacity(0.85))
            }
            .frame(width:100,height:58)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius:14))
            .overlay(RoundedRectangle(cornerRadius:14).strokeBorder(Color.white.opacity(0.22),lineWidth:1))
        }
    }

    private func animate() {
        confetti = (0..<45).map { _ in ConfettiPiece.random() }
        withAnimation(.spring(response:0.5,dampingFraction:0.6)) { titleOffset = 0 }
        for i in 0..<min(stars,3) {
            withAnimation(.spring(response:0.4,dampingFraction:0.5).delay(Double(i)*0.22+0.4)) { starScales[i] = 1 }
        }
        for i in stars..<3 {
            withAnimation(.easeOut(duration:0.3).delay(Double(i)*0.12+0.3)) { starScales[i] = 1 }
        }
        showReward = true
        if stars >= 2 {
            DispatchQueue.main.asyncAfter(deadline:.now()+0.25) { animate = true }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x,y0,y1,w,h,rot,dur,delay: Double
    var color: Color

    static let cols: [Color] = [.red,.orange,.yellow,.green,.blue,.purple,Color(red:1,green:0.4,blue:0.8)]
    static func random() -> ConfettiPiece {
        ConfettiPiece(x:Double.random(in:0...390), y0:Double.random(in:-20...0),
                      y1:Double.random(in:700...900), w:Double.random(in:6...14),
                      h:Double.random(in:10...20), rot:Double.random(in:0...360),
                      dur:Double.random(in:1.5...3.5), delay:Double.random(in:0...0.8),
                      color:cols.randomElement()!)
    }
}
