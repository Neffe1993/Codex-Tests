import SwiftUI

// MARK: - Stilisierte Charaktere (SwiftUI-Formen, kein Asset-Copyright)

struct CharacterWoman: View {
    var body: some View {
        ZStack {
            // Haare hinten
            Ellipse()
                .fill(Color(red:0.72,green:0.22,blue:0.1))
                .frame(width:36,height:22)
                .offset(y:-62)
            Ellipse()
                .fill(Color(red:0.72,green:0.22,blue:0.1))
                .frame(width:14,height:30)
                .offset(x:-18,y:-52)
            // Gesicht
            Circle()
                .fill(Color(red:0.96,green:0.80,blue:0.70))
                .frame(width:30,height:30)
                .offset(y:-52)
            // Augen
            Circle().fill(Color(red:0.3,green:0.2,blue:0.15)).frame(width:4,height:4).offset(x:-6,y:-55)
            Circle().fill(Color(red:0.3,green:0.2,blue:0.15)).frame(width:4,height:4).offset(x:6,y:-55)
            // Körper (grünes Kleid)
            RoundedRectangle(cornerRadius:10)
                .fill(LinearGradient(colors:[Color(red:0.22,green:0.60,blue:0.32), Color(red:0.16,green:0.46,blue:0.24)],
                                     startPoint:.top, endPoint:.bottom))
                .frame(width:32,height:52)
                .offset(y:-22)
            // Arme
            RoundedRectangle(cornerRadius:4)
                .fill(Color(red:0.22,green:0.60,blue:0.32))
                .frame(width:10,height:30)
                .rotationEffect(.degrees(22)).offset(x:-20,y:-28)
            RoundedRectangle(cornerRadius:4)
                .fill(Color(red:0.22,green:0.60,blue:0.32))
                .frame(width:10,height:30)
                .rotationEffect(.degrees(-22)).offset(x:20,y:-28)
            // Beine
            RoundedRectangle(cornerRadius:4)
                .fill(Color(red:0.96,green:0.80,blue:0.70))
                .frame(width:12,height:22).offset(x:-8,y:12)
            RoundedRectangle(cornerRadius:4)
                .fill(Color(red:0.96,green:0.80,blue:0.70))
                .frame(width:12,height:22).offset(x:8,y:12)
        }
    }
}

struct CharacterChild: View {
    var body: some View {
        ZStack {
            // Mütze
            RoundedRectangle(cornerRadius:4)
                .fill(Color(red:0.85,green:0.25,blue:0.22))
                .frame(width:24,height:10).offset(y:-36)
            // Gesicht
            Circle()
                .fill(Color(red:0.96,green:0.80,blue:0.70))
                .frame(width:20,height:20).offset(y:-30)
            // Körper
            RoundedRectangle(cornerRadius:6)
                .fill(Color(red:0.85,green:0.35,blue:0.25))
                .frame(width:20,height:28).offset(y:-12)
            // Beine
            RoundedRectangle(cornerRadius:3)
                .fill(Color(red:0.28,green:0.38,blue:0.68))
                .frame(width:8,height:14).offset(x:-5,y:8)
            RoundedRectangle(cornerRadius:3)
                .fill(Color(red:0.28,green:0.38,blue:0.68))
                .frame(width:8,height:14).offset(x:5,y:8)
        }
    }
}

struct CharacterMan: View {
    var body: some View {
        ZStack {
            // Mütze
            RoundedRectangle(cornerRadius:4)
                .fill(Color(red:0.45,green:0.28,blue:0.12))
                .frame(width:26,height:10).offset(y:-52)
            // Gesicht
            Circle()
                .fill(Color(red:0.88,green:0.70,blue:0.58))
                .frame(width:24,height:24).offset(y:-42)
            // Augen
            Circle().fill(Color(red:0.2,green:0.15,blue:0.1)).frame(width:4,height:4).offset(x:-5,y:-44)
            Circle().fill(Color(red:0.2,green:0.15,blue:0.1)).frame(width:4,height:4).offset(x:5,y:-44)
            // Körper (orange Jacke)
            RoundedRectangle(cornerRadius:8)
                .fill(LinearGradient(colors:[Color(red:0.85,green:0.45,blue:0.1), Color(red:0.72,green:0.32,blue:0.06)],
                                     startPoint:.top, endPoint:.bottom))
                .frame(width:28,height:38).offset(y:-20)
            // Beine
            RoundedRectangle(cornerRadius:3)
                .fill(Color(red:0.25,green:0.32,blue:0.55))
                .frame(width:10,height:18).offset(x:-6,y:8)
            RoundedRectangle(cornerRadius:3)
                .fill(Color(red:0.25,green:0.32,blue:0.55))
                .frame(width:10,height:18).offset(x:6,y:8)
        }
    }
}
