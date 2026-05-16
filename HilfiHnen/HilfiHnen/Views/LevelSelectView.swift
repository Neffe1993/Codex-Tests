import SwiftUI

struct LevelSelectView: View {
    @EnvironmentObject var gameState: GameState
    @State private var selectedScenario: Int = 0

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            backgroundGradient
            VStack(spacing: 0) {
                header
                coinsBar
                scrollableGrid
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.08, green: 0.14, blue: 0.35), Color(red: 0.18, green: 0.32, blue: 0.62)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            Button(action: { gameState.goToMainMenu() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }
            Spacer()
            Text("Level auswählen")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "star.fill").foregroundColor(.yellow).font(.system(size: 14))
                Text("\(gameState.totalStars)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.black.opacity(0.3))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
        .padding(.bottom, 12)
    }

    private var coinsBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "circle.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 18))
            Text("\(gameState.coins) Münzen")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            Spacer()
            Button(action: {}) {
                Text("+")
                    .font(.system(size: 18, weight: .black))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Color.green)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.1))
        .padding(.horizontal, 16)
        .cornerRadius(12)
    }

    private var scrollableGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<LevelData.levels.count, id: \.self) { index in
                    levelCell(for: index)
                }
            }
            .padding(16)
            .padding(.bottom, 32)
        }
    }

    private func levelCell(for index: Int) -> some View {
        let level = LevelData.levels[index]
        let isUnlocked = index < gameState.unlockedLevels
        let bestStars = gameState.levelProgress[index] ?? 0

        return Button(action: {
            if isUnlocked { gameState.startLevel(index) }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: isUnlocked ? level.backgroundColors : [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(isUnlocked ? Color.white.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1.5)
                    )

                VStack(spacing: 6) {
                    levelTypeIcon(level.type)
                        .font(.system(size: 28))
                        .foregroundColor(isUnlocked ? .white : .white.opacity(0.4))

                    Text("Level \(index + 1)")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundColor(isUnlocked ? .white : .white.opacity(0.4))

                    Text(level.title)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(isUnlocked ? .white.opacity(0.85) : .white.opacity(0.3))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    if isUnlocked {
                        starsRow(count: bestStars)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.5))
                    }

                    difficultyBadge(level.difficultyLabel, isUnlocked: isUnlocked)
                }
                .padding(8)
            }
            .frame(height: 140)
        }
        .disabled(!isUnlocked)
    }

    private func levelTypeIcon(_ type: LevelType) -> Image {
        switch type {
        case .match3:       return Image(systemName: "square.grid.3x3.fill")
        case .pipePuzzle:   return Image(systemName: "arrow.triangle.branch")
        case .balanceChallenge: return Image(systemName: "scalemass.fill")
        case .thermometer:  return Image(systemName: "thermometer.medium")
        }
    }

    private func starsRow(count: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { i in
                Image(systemName: i < count ? "star.fill" : "star")
                    .font(.system(size: 11))
                    .foregroundColor(i < count ? .yellow : .white.opacity(0.35))
            }
        }
    }

    private func difficultyBadge(_ label: String, isUnlocked: Bool) -> some View {
        Text(label)
            .font(.system(size: 8, weight: .bold, design: .rounded))
            .foregroundColor(isUnlocked ? .white : .white.opacity(0.3))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(isUnlocked ? Color.black.opacity(0.3) : Color.clear)
            .clipShape(Capsule())
    }
}
