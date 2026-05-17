import SwiftUI

// MARK: - Red Banner (exakt wie in den Screenshots)
struct RedBanner: View {
    let text: String
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red:0.78,green:0.08,blue:0.08), Color(red:0.88,green:0.14,blue:0.14)],
                           startPoint: .top, endPoint: .bottom)
            Text(text)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .italic()
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.35), radius: 2, x: 1, y: 2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Sprechblase mit Icon (goldener Rahmen, weißer Hintergrund)
struct SpeechBubble: View {
    let icon: String
    let color: Color

    var body: some View {
        ZStack {
            // Sprechblasen-Schwanz
            Path { p in
                p.move(to: CGPoint(x: 16, y: 54))
                p.addLine(to: CGPoint(x: 10, y: 68))
                p.addLine(to: CGPoint(x: 28, y: 58))
            }
            .fill(Color.white)

            Path { p in
                p.move(to: CGPoint(x: 16, y: 54))
                p.addLine(to: CGPoint(x: 10, y: 68))
                p.addLine(to: CGPoint(x: 28, y: 58))
            }
            .stroke(Color(red:0.85,green:0.55,blue:0.05), lineWidth: 2)

            // Bubble
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 58, height: 58)
                Circle()
                    .strokeBorder(
                        LinearGradient(colors:[Color(red:0.95,green:0.72,blue:0.15), Color(red:0.85,green:0.45,blue:0.05)],
                                       startPoint:.top, endPoint:.bottom),
                        lineWidth: 3.5
                    )
                    .frame(width: 58, height: 58)
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(color)
            }
        }
        .frame(width: 60, height: 70)
    }
}

// MARK: - Thermometer Bar (horizontal, blauer Punkt links, Farbverlauf)
struct ThermometerBar: View {
    var fill: Double = 0.25   // 0…1

    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(Color(red:0.25,green:0.45,blue:0.9))
                .frame(width: 26, height: 26)
                .shadow(color:.blue.opacity(0.5), radius: 4)

            GeometryReader { geo in
                ZStack(alignment:.leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.55))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors:[Color(red:0.3,green:0.5,blue:0.95), Color(red:0.9,green:0.2,blue:0.2)],
                                startPoint:.leading, endPoint:.trailing)
                        )
                        .frame(width: geo.size.width * fill)
                        .animation(.easeOut(duration:1.2), value: fill)
                }
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.7), lineWidth: 1.5))
            }
            .frame(height: 22)
            .padding(.leading, -12)
        }
        .padding(.horizontal, 28)
        .frame(height: 28)
    }
}

// MARK: - Pulsierender Aufgaben-Button (gelbes Glühen)
struct GlowingTaskButton: View {
    let icon: String
    let action: () -> Void
    @State private var pulse = false

    var body: some View {
        Button(action: action) {
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color(red:1,green:0.78,blue:0.0).opacity(pulse ? 0.0 : 0.25 - Double(i)*0.07))
                        .frame(width: 72 + CGFloat(i)*18, height: 72 + CGFloat(i)*18)
                        .scaleEffect(pulse ? 1.25 : 1.0)
                        .animation(.easeInOut(duration:1.1).repeatForever(autoreverses:true).delay(Double(i)*0.18), value: pulse)
                }
                Circle()
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                Circle()
                    .strokeBorder(
                        LinearGradient(colors:[Color(red:1,green:0.85,blue:0.1), Color(red:0.95,green:0.5,blue:0.05)],
                                       startPoint:.top, endPoint:.bottom),
                        lineWidth: 4
                    )
                    .frame(width: 64, height: 64)
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(Color(red:0.85,green:0.45,blue:0.05))
            }
        }
        .onAppear { pulse = true }
    }
}

// MARK: - Bottom Nav Bar (Karte links, grüner ? rechts)
struct BottomNavBar: View {
    let onMap: () -> Void
    let stars: Int

    var body: some View {
        HStack {
            Button(action: onMap) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(red:0.25,green:0.55,blue:0.35))
                        .frame(width: 56, height: 56)
                        .shadow(color:.black.opacity(0.3), radius:4, x:0, y:3)
                    Image(systemName: "map.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }

            Spacer()

            HStack(spacing: 5) {
                Image(systemName:"star.fill")
                    .foregroundColor(Color(red:1,green:0.82,blue:0.1))
                    .font(.system(size:16))
                Text("\(stars)")
                    .font(.system(size:16, weight:.black, design:.rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal,12).padding(.vertical,6)
            .background(Color.black.opacity(0.35))
            .clipShape(Capsule())

            Spacer()

            Button(action:{}) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors:[Color(red:0.35,green:0.78,blue:0.25),Color(red:0.18,green:0.58,blue:0.12)],
                                           startPoint:.top, endPoint:.bottom)
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color:.green.opacity(0.5), radius:4, x:0, y:3)
                    Image(systemName:"questionmark")
                        .font(.system(size:24, weight:.black))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

// MARK: - Sterne-Counter oben rechts
struct StarsCounter: View {
    let count: Int
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName:"star.fill")
                .foregroundColor(Color(red:1,green:0.82,blue:0.1))
            Text("\(count)")
                .font(.system(size:15, weight:.black, design:.rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal,10).padding(.vertical,5)
        .background(Color.black.opacity(0.35))
        .clipShape(Capsule())
    }
}

// MARK: - X-Button
struct CloseButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(Color.black.opacity(0.45)).frame(width:40,height:40)
                Image(systemName:"xmark")
                    .font(.system(size:16,weight:.bold))
                    .foregroundColor(.white)
            }
        }
    }
}
