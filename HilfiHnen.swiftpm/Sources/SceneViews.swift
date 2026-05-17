import SwiftUI

// MARK: - Winter-Außenszene (Screenshot 1 Stil)
struct WinterOutdoorScene: View {
    var body: some View {
        ZStack {
            // Himmel
            LinearGradient(colors: [Color(red:0.62,green:0.78,blue:0.95), Color(red:0.82,green:0.92,blue:1.0)],
                           startPoint:.top, endPoint:.bottom)

            // Schneeboden
            VStack {
                Spacer()
                Ellipse()
                    .fill(Color.white.opacity(0.9))
                    .frame(height: 90)
                    .padding(.horizontal, -20)
            }

            // Ziegelmauer hinten
            ZStack {
                RoundedRectangle(cornerRadius:6)
                    .fill(Color(red:0.62,green:0.68,blue:0.78))
                    .frame(width:200, height:130)
                    .offset(x:-30, y:-20)
                // Ziegellinien
                ForEach(0..<4) { row in
                    ForEach(0..<5) { col in
                        RoundedRectangle(cornerRadius:2)
                            .stroke(Color.white.opacity(0.25), lineWidth:1)
                            .frame(width:36, height:18)
                            .offset(x: CGFloat(col-2)*38 + (row%2==0 ? 0 : 19) - 30,
                                    y: CGFloat(row-1)*20 - 20)
                    }
                }
            }

            // Schnee auf Mauer
            Ellipse()
                .fill(Color.white.opacity(0.85))
                .frame(width:210, height:24)
                .offset(x:-30, y:-82)

            // Einkaufswagen rechts
            Group {
                // Wagen-Körper
                RoundedRectangle(cornerRadius:6)
                    .fill(Color(red:0.72,green:0.76,blue:0.82))
                    .frame(width:52, height:36)
                    .offset(x:80, y:28)
                // Räder
                Circle().fill(Color(red:0.4,green:0.4,blue:0.4)).frame(width:10,height:10).offset(x:68,y:52)
                Circle().fill(Color(red:0.4,green:0.4,blue:0.4)).frame(width:10,height:10).offset(x:90,y:52)
                // Griff
                Rectangle()
                    .fill(Color(red:0.5,green:0.52,blue:0.58))
                    .frame(width:4, height:28)
                    .rotationEffect(.degrees(20))
                    .offset(x:55, y:12)
            }

            // Baby im Wagen (Kreis)
            Circle()
                .fill(Color(red:0.95,green:0.78,blue:0.72))
                .frame(width:22,height:22)
                .offset(x:80, y:20)

            // Kind auf Boden
            Group {
                Ellipse()
                    .fill(Color(red:0.72,green:0.55,blue:0.85).opacity(0.8))
                    .frame(width:55,height:22)
                    .rotationEffect(.degrees(-15))
                    .offset(x:-65, y:40)
                Circle()
                    .fill(Color(red:0.95,green:0.78,blue:0.72))
                    .frame(width:18,height:18)
                    .offset(x:-85, y:30)
            }

            // Hauptcharakter (Frau, rote Haare, grünes Kleid)
            CharacterWoman().offset(x:-5, y:8)

            // Feuer + Pfanne
            Group {
                // Flammen
                ForEach(0..<3) { i in
                    Ellipse()
                        .fill(Color(red:1,green:CGFloat(0.55+Double(i)*0.1),blue:0.1).opacity(0.8))
                        .frame(width:12,height:18)
                        .offset(x: CGFloat(-20+i*6), y:62)
                        .rotationEffect(.degrees(Double(i)*8-8))
                }
                // Pfanne
                Ellipse()
                    .fill(Color(red:0.25,green:0.25,blue:0.28))
                    .frame(width:30,height:12)
                    .offset(x:-18, y:72)
                // Tomate
                Circle()
                    .fill(Color(red:0.92,green:0.2,blue:0.18))
                    .frame(width:10,height:10)
                    .offset(x:-16, y:68)
            }

            // Schneeflocken
            ForEach(0..<12, id:\.self) { i in
                Text("❄")
                    .font(.system(size: CGFloat([8,10,6,12,9][i%5])))
                    .opacity(0.55)
                    .position(x: CGFloat([25,60,100,140,180,210,250,290,310,350,370,30][i]),
                              y: CGFloat([30,80,20,60,40,90,25,55,35,70,15,45][i]))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius:0))
    }
}

// MARK: - Kaputtes Zimmer Szene (Screenshot 2 Stil)
struct BrokenRoomScene: View {
    var body: some View {
        ZStack {
            // Dunkelgraue Wand
            LinearGradient(colors:[Color(red:0.18,green:0.18,blue:0.24), Color(red:0.26,green:0.26,blue:0.34)],
                           startPoint:.top, endPoint:.bottom)

            // Holzboden
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color(red:0.32,green:0.22,blue:0.14))
                    .frame(height:80)
            }

            // Fenster links (Sturm draußen)
            ZStack {
                RoundedRectangle(cornerRadius:8)
                    .fill(LinearGradient(colors:[Color(red:0.12,green:0.18,blue:0.4),Color(red:0.2,green:0.3,blue:0.55)],
                                         startPoint:.top, endPoint:.bottom))
                    .frame(width:70,height:90)
                // Rahmenkreuz
                Rectangle().fill(Color(red:0.55,green:0.48,blue:0.38)).frame(width:70,height:4).offset(y:0)
                Rectangle().fill(Color(red:0.55,green:0.48,blue:0.38)).frame(width:4,height:90).offset(x:0)
                RoundedRectangle(cornerRadius:8)
                    .strokeBorder(Color(red:0.55,green:0.48,blue:0.38), lineWidth:4)
                    .frame(width:70,height:90)
                // Regen
                ForEach(0..<5, id:\.self) { i in
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width:1.5,height:20)
                        .rotationEffect(.degrees(10))
                        .offset(x:CGFloat(-25+i*12), y:CGFloat(-15+i*4))
                }
            }
            .offset(x:-115, y:-40)

            // Kamin rechts
            ZStack {
                // Kamingehäuse
                RoundedRectangle(cornerRadius:4)
                    .fill(Color(red:0.28,green:0.24,blue:0.2))
                    .frame(width:80,height:80)
                // Öffnung
                RoundedRectangle(cornerRadius:4)
                    .fill(Color(red:0.12,green:0.1,blue:0.08))
                    .frame(width:60,height:50)
                    .offset(y:8)
                // Sims oben
                Rectangle()
                    .fill(Color(red:0.38,green:0.32,blue:0.26))
                    .frame(width:90,height:10)
                    .offset(y:-45)
            }
            .offset(x:110, y:20)

            // Kaputte Kohle im Kamin
            ForEach(0..<3, id:\.self) { i in
                Ellipse()
                    .fill(Color(red:0.22,green:0.2,blue:0.18))
                    .frame(width:18,height:10)
                    .offset(x:CGFloat(95+i*12), y:38)
            }

            // Ventilator oben (mit Blitz-Funken)
            ZStack {
                // Deckenbefestigung
                Rectangle()
                    .fill(Color(red:0.4,green:0.4,blue:0.48))
                    .frame(width:8, height:30)
                    .offset(y:-90)
                // Ventilatorgehäuse
                Circle()
                    .fill(Color(red:0.45,green:0.45,blue:0.52))
                    .frame(width:24,height:24)
                    .offset(y:-60)
                // Flügel
                ForEach(0..<3, id:\.self) { i in
                    Ellipse()
                        .fill(Color(red:0.52,green:0.52,blue:0.60))
                        .frame(width:55,height:14)
                        .rotationEffect(.degrees(Double(i)*60))
                        .offset(y:-60)
                }
                // Blitze
                ForEach(0..<4, id:\.self) { i in
                    LightningBolt()
                        .stroke(Color(red:0.55,green:0.75,blue:1.0), style:StrokeStyle(lineWidth:2, lineCap:.round))
                        .frame(width:22,height:30)
                        .rotationEffect(.degrees(Double(i)*90))
                        .offset(x:CGFloat(cos(Double(i)*1.57)*40),
                                y:CGFloat(sin(Double(i)*1.57)*40)-60)
                }
            }
            .offset(x:10)

            // Bett
            ZStack {
                RoundedRectangle(cornerRadius:8)
                    .fill(Color(red:0.38,green:0.28,blue:0.20))
                    .frame(width:180,height:70)
                // Kissen
                RoundedRectangle(cornerRadius:6)
                    .fill(Color(red:0.62,green:0.55,blue:0.78))
                    .frame(width:60,height:35)
                    .offset(x:-50,y:-12)
                // Bettrahmen-Kopfteil
                RoundedRectangle(cornerRadius:6)
                    .fill(Color(red:0.42,green:0.32,blue:0.22))
                    .frame(width:180,height:12)
                    .offset(y:-41)
            }
            .offset(x:-15, y:40)

            // Frau auf Bett
            CharacterWoman().scaleEffect(0.75).offset(x:-40, y:10)

            // Baby auf Bett
            Circle()
                .fill(Color(red:0.95,green:0.78,blue:0.72))
                .frame(width:18,height:18)
                .offset(x:-15, y:15)

            // Kind steht neben Bett
            CharacterChild().scaleEffect(0.8).offset(x:55, y:25)

            // Mülleimer
            ZStack {
                RoundedRectangle(cornerRadius:4)
                    .fill(Color(red:0.42,green:0.42,blue:0.45))
                    .frame(width:28,height:36)
                Rectangle()
                    .fill(Color(red:0.35,green:0.35,blue:0.38))
                    .frame(width:32,height:5)
                    .offset(y:-18)
            }
            .offset(x:-125, y:40)

            // Papiere auf Boden
            ForEach(0..<5, id:\.self) { i in
                RoundedRectangle(cornerRadius:2)
                    .fill(Color.white.opacity(0.6))
                    .frame(width:CGFloat([22,18,25,20,16][i]), height:CGFloat([14,18,12,16,20][i]))
                    .rotationEffect(.degrees(Double([-15,20,-5,30,-10][i])))
                    .offset(x:CGFloat([20,-60,40,-20,70][i]), y:CGFloat([65,70,72,68,66][i]))
            }
        }
    }
}

// MARK: - Blitz-Form
struct LightningBolt: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX+4, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX-2, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.midX+3, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.midX-4, y: rect.maxY))
        return p
    }
}

// MARK: - Frauencharakter (stilisiert)
struct CharacterWoman: View {
    var body: some View {
        ZStack {
            // Haare
            Ellipse()
                .fill(Color(red:0.72,green:0.22,blue:0.1))
                .frame(width:36,height:22)
                .offset(y:-62)
            // Haare seitlich
            Ellipse()
                .fill(Color(red:0.72,green:0.22,blue:0.1))
                .frame(width:14,height:28)
                .offset(x:-18,y:-52)

            // Gesicht
            Circle()
                .fill(Color(red:0.96,green:0.80,blue:0.70))
                .frame(width:30,height:30)
                .offset(y:-52)

            // Augen
            Circle().fill(Color(red:0.3,green:0.2,blue:0.15)).frame(width:5,height:5).offset(x:-6,y:-55)
            Circle().fill(Color(red:0.3,green:0.2,blue:0.15)).frame(width:5,height:5).offset(x:6,y:-55)

            // Körper (grünes Kleid)
            RoundedRectangle(cornerRadius:10)
                .fill(LinearGradient(colors:[Color(red:0.22,green:0.60,blue:0.32), Color(red:0.18,green:0.48,blue:0.26)],
                                     startPoint:.top, endPoint:.bottom))
                .frame(width:32,height:52)
                .offset(y:-22)

            // Arme
            RoundedRectangle(cornerRadius:4)
                .fill(Color(red:0.22,green:0.60,blue:0.32))
                .frame(width:10,height:32)
                .rotationEffect(.degrees(20))
                .offset(x:-20,y:-28)
            RoundedRectangle(cornerRadius:4)
                .fill(Color(red:0.22,green:0.60,blue:0.32))
                .frame(width:10,height:32)
                .rotationEffect(.degrees(-20))
                .offset(x:20,y:-28)

            // Beine
            RoundedRectangle(cornerRadius:4)
                .fill(Color(red:0.96,green:0.80,blue:0.70))
                .frame(width:12,height:22)
                .offset(x:-8,y:12)
            RoundedRectangle(cornerRadius:4)
                .fill(Color(red:0.96,green:0.80,blue:0.70))
                .frame(width:12,height:22)
                .offset(x:8,y:12)
        }
    }
}

// MARK: - Kindcharakter (stilisiert)
struct CharacterChild: View {
    var body: some View {
        ZStack {
            // Haare
            Ellipse()
                .fill(Color(red:0.72,green:0.22,blue:0.1))
                .frame(width:24,height:14)
                .offset(y:-36)
            // Gesicht
            Circle()
                .fill(Color(red:0.96,green:0.80,blue:0.70))
                .frame(width:20,height:20)
                .offset(y:-32)
            // Körper
            RoundedRectangle(cornerRadius:6)
                .fill(Color(red:0.85,green:0.3,blue:0.3))
                .frame(width:20,height:30)
                .offset(y:-12)
            // Beine
            RoundedRectangle(cornerRadius:3)
                .fill(Color(red:0.3,green:0.4,blue:0.7))
                .frame(width:8,height:15)
                .offset(x:-5,y:8)
            RoundedRectangle(cornerRadius:3)
                .fill(Color(red:0.3,green:0.4,blue:0.7))
                .frame(width:8,height:15)
                .offset(x:5,y:8)
        }
    }
}
