import SwiftUI

struct PipeCellView: View {
    let cell: PipeCell
    let size: CGFloat
    let isFlowing: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(isFlowing ? Color(red: 0.25, green: 0.3, blue: 0.45) : Color(red: 0.15, green: 0.18, blue: 0.28))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(isFlowing ? Color(red: 0.5, green: 0.7, blue: 1.0) : Color.white.opacity(0.1), lineWidth: isFlowing ? 1.5 : 0.5)
                )

            pipeShape
                .rotationEffect(.degrees(Double(cell.rotation) * 90))

            if cell.isFixed {
                Image(systemName: "lock.fill")
                    .font(.system(size: size * 0.2))
                    .foregroundColor(.white.opacity(0.4))
                    .offset(x: size * 0.3, y: -size * 0.3)
            }
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private var pipeShape: some View {
        let pipeColor = isFlowing ? Color(red: 0.6, green: 0.85, blue: 1.0) : Color(red: 0.55, green: 0.55, blue: 0.65)
        let pipeWidth: CGFloat = size * 0.28

        ZStack {
            switch cell.type {
            case .straight:
                Rectangle()
                    .fill(pipeColor)
                    .frame(width: pipeWidth, height: size * 0.9)
                    .clipShape(RoundedRectangle(cornerRadius: pipeWidth / 2))

            case .curve:
                Path { path in
                    path.addArc(center: CGPoint(x: size / 2, y: size / 2),
                                radius: size * 0.28,
                                startAngle: .degrees(180),
                                endAngle: .degrees(270),
                                clockwise: false)
                }
                .stroke(pipeColor, style: StrokeStyle(lineWidth: pipeWidth, lineCap: .round))
                .frame(width: size, height: size)

            case .junction:
                Rectangle()
                    .fill(pipeColor)
                    .frame(width: pipeWidth, height: size * 0.9)
                    .clipShape(RoundedRectangle(cornerRadius: pipeWidth / 2))
                Rectangle()
                    .fill(pipeColor)
                    .frame(width: size * 0.45, height: pipeWidth)
                    .clipShape(RoundedRectangle(cornerRadius: pipeWidth / 2))

            case .end:
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(pipeColor)
                        .frame(width: pipeWidth, height: size * 0.5)
                        .clipShape(RoundedRectangle(cornerRadius: pipeWidth / 2))
                    Circle()
                        .fill(pipeColor)
                        .frame(width: pipeWidth * 1.4, height: pipeWidth * 1.4)
                }
            }

            if isFlowing {
                coinFlowDots(pipeColor: pipeColor)
            }
        }
    }

    private func coinFlowDots(pipeColor: Color) -> some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.yellow.opacity(0.6))
                    .frame(width: size * 0.1, height: size * 0.1)
                    .offset(y: CGFloat(i - 1) * size * 0.15)
            }
        }
    }
}
