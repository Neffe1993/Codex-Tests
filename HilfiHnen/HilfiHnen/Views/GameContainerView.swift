import SwiftUI
import SpriteKit

struct GameContainerView: View {
    @EnvironmentObject var gameState: GameState
    let levelIndex: Int

    private var level: GameLevel { LevelData.levels[levelIndex] }

    var body: some View {
        ZStack {
            LinearGradient(colors: level.backgroundColors, startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            switch level.type {
            case .match3(let config):
                Match3GameView(config: config, level: level, levelIndex: levelIndex)
            case .pipePuzzle(let config):
                PipePuzzleGameView(config: config, level: level, levelIndex: levelIndex)
            case .balanceChallenge(let config):
                BalanceGameView(config: config, level: level, levelIndex: levelIndex)
            case .thermometer(let config):
                ThermometerGameView(config: config, level: level, levelIndex: levelIndex)
            }
        }
    }
}

// MARK: - Match-3 Game View

struct Match3GameView: View {
    @EnvironmentObject var gameState: GameState
    let config: Match3Config
    let level: GameLevel
    let levelIndex: Int

    @StateObject private var engine: Match3Engine
    @State private var showQuit = false

    init(config: Match3Config, level: GameLevel, levelIndex: Int) {
        self.config = config
        self.level = level
        self.levelIndex = levelIndex
        _engine = StateObject(wrappedValue: Match3Engine(config: config))
    }

    var body: some View {
        VStack(spacing: 0) {
            hud
            goalBar
            boardArea
            bottomBar
        }
        .onChange(of: engine.isComplete) { complete in
            if complete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    gameState.completeLevel(levelIndex, stars: engine.calculateStars())
                }
            }
        }
    }

    private var hud: some View {
        HStack {
            Button(action: { showQuit = true }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            .padding(.leading, 16)

            Spacer()

            VStack(spacing: 2) {
                Text("Level \(levelIndex + 1)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                Text(level.title)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("Züge")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                Text("\(engine.movesLeft)")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(engine.movesLeft <= 5 ? .red : .white)
            }
            .frame(width: 56)
            .padding(.trailing, 16)
        }
        .padding(.top, 52)
        .padding(.bottom, 10)
        .alert("Level verlassen?", isPresented: $showQuit) {
            Button("Verlassen", role: .destructive) { gameState.goToLevelSelect() }
            Button("Weiter spielen", role: .cancel) {}
        }
    }

    private var goalBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                scoreGoalCell
                ForEach(engine.goalProgress, id: \.tileColor.rawValue) { goal in
                    goalCell(goal)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 60)
        .background(Color.black.opacity(0.2))
    }

    private var scoreGoalCell: some View {
        VStack(spacing: 2) {
            Text("\(engine.score)")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text("/ \(config.targetScore)")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(width: 72, height: 44)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(engine.score >= config.targetScore ? Color.green.opacity(0.4) : Color.white.opacity(0.15))
        )
    }

    private func goalCell(_ goal: GoalProgress) -> some View {
        HStack(spacing: 6) {
            Image(systemName: goal.tileColor.symbol)
                .font(.system(size: 14))
                .foregroundColor(goal.tileColor.color)
            VStack(alignment: .leading, spacing: 1) {
                Text("\(goal.collected)/\(goal.target)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                ProgressView(value: Double(goal.collected), total: Double(goal.target))
                    .tint(goal.tileColor.color)
                    .frame(width: 50)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(goal.isComplete ? Color.green.opacity(0.35) : Color.white.opacity(0.12))
        )
    }

    private var boardArea: some View {
        GeometryReader { geo in
            let tileSize = min(geo.size.width / CGFloat(config.cols), geo.size.height / CGFloat(config.rows)) - 4
            let boardW = tileSize * CGFloat(config.cols)
            let boardH = tileSize * CGFloat(config.rows)

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.25))
                    .frame(width: boardW + 20, height: boardH + 20)

                VStack(spacing: 3) {
                    ForEach(0..<config.rows, id: \.self) { row in
                        HStack(spacing: 3) {
                            ForEach(0..<config.cols, id: \.self) { col in
                                tileView(row: row, col: col, size: tileSize)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 8)
    }

    private func tileView(row: Int, col: Int, size: CGFloat) -> some View {
        let tile = engine.board[row][col]
        let isSelected = engine.selectedTile?.row == row && engine.selectedTile?.col == col

        return Button(action: { engine.tap(row: row, col: col) }) {
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.18)
                    .fill(
                        LinearGradient(
                            colors: [tile.color.color.opacity(0.9), tile.color.color.opacity(0.6)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: size * 0.18)
                            .strokeBorder(isSelected ? Color.white : Color.white.opacity(0.25), lineWidth: isSelected ? 3 : 1)
                    )
                    .shadow(color: tile.color.color.opacity(0.5), radius: isSelected ? 6 : 2)

                Image(systemName: tile.color.symbol)
                    .font(.system(size: size * 0.42))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)

                if tile.isSpecial {
                    Image(systemName: "sparkles")
                        .font(.system(size: size * 0.28))
                        .foregroundColor(.white)
                        .offset(x: size * 0.2, y: -size * 0.2)
                }
            }
            .frame(width: size, height: size)
            .scaleEffect(isSelected ? 1.12 : (tile.isNew ? 0.85 : 1.0))
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isSelected)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: tile.isNew)
        }
        .buttonStyle(.plain)
        .opacity(tile.isRemoving ? 0.2 : 1.0)
        .scaleEffect(tile.isRemoving ? 1.4 : 1.0)
        .animation(.easeOut(duration: 0.25), value: tile.isRemoving)
    }

    private var bottomBar: some View {
        HStack {
            scoreBar
            Spacer()
            boosterButton(icon: "bolt.fill", label: "Blitz", color: .yellow)
            boosterButton(icon: "shuffle", label: "Mischen", color: .blue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.25))
    }

    private var scoreBar: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill").foregroundColor(.yellow).font(.system(size: 12))
                Text("\(engine.score)")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.2)).frame(height: 8)
                    Capsule()
                        .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * min(Double(engine.score) / Double(config.targetScore), 1.0), height: 8)
                        .animation(.easeOut(duration: 0.3), value: engine.score)
                }
            }
            .frame(width: 140, height: 8)
        }
    }

    private func boosterButton(icon: String, label: String, color: Color) -> some View {
        Button(action: {}) {
            VStack(spacing: 2) {
                Image(systemName: icon).font(.system(size: 18)).foregroundColor(color)
                Text(label).font(.system(size: 10, weight: .semibold)).foregroundColor(.white.opacity(0.8))
            }
            .frame(width: 52, height: 48)
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Pipe Puzzle View

struct PipePuzzleGameView: View {
    @EnvironmentObject var gameState: GameState
    let config: PipeConfig
    let level: GameLevel
    let levelIndex: Int

    @StateObject private var engine: PipeEngine

    init(config: PipeConfig, level: GameLevel, levelIndex: Int) {
        self.config = config
        self.level = level
        self.levelIndex = levelIndex
        _engine = StateObject(wrappedValue: PipeEngine(config: config))
    }

    var body: some View {
        VStack(spacing: 0) {
            pipeHUD
            Spacer()
            pipeBoard
            Spacer()
            pipeStatus
        }
        .onChange(of: engine.isConnected) { connected in
            if connected {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    gameState.completeLevel(levelIndex, stars: 3)
                }
            }
        }
    }

    private var pipeHUD: some View {
        HStack {
            Button(action: { gameState.goToLevelSelect() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            .padding(.leading, 16)

            Spacer()

            VStack {
                Text("Spiele Minispiele!")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2)
            }

            Spacer()

            VStack(spacing: 2) {
                Image(systemName: "circle.fill").foregroundColor(.yellow).font(.system(size: 14))
                Text("\(Int(engine.coinsCollected))")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.trailing, 16)
        }
        .padding(.top, 52)
        .padding(.bottom, 10)
    }

    private var pipeBoard: some View {
        GeometryReader { geo in
            let cellSize = min(geo.size.width, geo.size.height) / CGFloat(config.gridSize)

            ZStack {
                ForEach(engine.cells.indices, id: \.self) { i in
                    let cell = engine.cells[i]
                    PipeCellView(cell: cell, size: cellSize, isFlowing: engine.flowPath.contains(i))
                        .position(
                            x: CGFloat(cell.col) * cellSize + cellSize / 2,
                            y: CGFloat(cell.row) * cellSize + cellSize / 2
                        )
                        .onTapGesture { engine.rotate(index: i) }
                }
            }
            .frame(width: CGFloat(config.gridSize) * cellSize, height: CGFloat(config.gridSize) * cellSize)
            .background(Color.black.opacity(0.25))
            .cornerRadius(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(20)
    }

    private var pipeStatus: some View {
        VStack(spacing: 8) {
            if engine.isConnected {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green).font(.system(size: 20))
                    Text("Verbunden! Münzen fließen!")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.green.opacity(0.3))
                .cornerRadius(12)
            } else {
                Text("Drehe die Segmente um die Rohre zu verbinden!")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            ProgressView(value: engine.coinsCollected, total: Double(config.coinTarget))
                .tint(.yellow)
                .frame(width: 200)

            Text("\(Int(engine.coinsCollected)) / \(config.coinTarget) Münzen")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.bottom, 40)
    }
}

// MARK: - Balance Game View

struct BalanceGameView: View {
    @EnvironmentObject var gameState: GameState
    let config: BalanceConfig
    let level: GameLevel
    let levelIndex: Int

    @StateObject private var engine: BalanceEngine

    init(config: BalanceConfig, level: GameLevel, levelIndex: Int) {
        self.config = config
        self.level = level
        self.levelIndex = levelIndex
        _engine = StateObject(wrappedValue: BalanceEngine(config: config))
    }

    var body: some View {
        VStack(spacing: 0) {
            balanceHUD
            Spacer()
            balanceVisual
            Spacer()
            sliders
            confirmButton
                .padding(.bottom, 40)
        }
    }

    private var balanceHUD: some View {
        HStack {
            Button(action: { gameState.goToLevelSelect() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            .padding(.leading, 16)
            Spacer()
            Text("Stell dich der Herausforderung!")
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.top, 52)
        .padding(.bottom, 10)
    }

    private var balanceVisual: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                balanceSide(
                    label: "Links",
                    value: engine.leftValue,
                    color: Color(red: 0.85, green: 0.25, blue: 0.2),
                    iconName: "flame.fill"
                )

                Rectangle()
                    .fill(Color(red: 0.45, green: 0.35, blue: 0.55))
                    .frame(width: 6)

                balanceSide(
                    label: "Rechts",
                    value: engine.rightValue,
                    color: Color(red: 0.85, green: 0.65, blue: 0.1),
                    iconName: "circle.fill"
                )
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            balanceBar
        }
        .padding(.horizontal, 20)
    }

    private func balanceSide(label: String, value: Double, color: Color, iconName: String) -> some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.3))

            Rectangle()
                .fill(
                    LinearGradient(colors: [color.opacity(0.9), color.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                )
                .frame(height: 200 * value)
                .animation(.spring(response: 0.4, dampingFraction: 0.65), value: value)

            VStack(spacing: 4) {
                Image(systemName: iconName).foregroundColor(.white).font(.system(size: 20))
                Text(label).font(.system(size: 12, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text("\(Int(value * 100))%").font(.system(size: 16, weight: .black, design: .rounded)).foregroundColor(.white)
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
    }

    private var balanceBar: some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.45, green: 0.35, blue: 0.55))
                .frame(height: 24)

            HStack {
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(Color.white.opacity(0.15)))
                }
            }

            Circle()
                .fill(engine.isBalanced ? Color.green : Color.white)
                .frame(width: 28, height: 28)
                .offset(x: (engine.leftValue - 0.5) * 160)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: engine.leftValue)
        }
        .frame(height: 24)
    }

    private var sliders: some View {
        VStack(spacing: 10) {
            Text("Regler anpassen:")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))

            ForEach(0..<config.sliderCount, id: \.self) { i in
                sliderRow(index: i)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.2))
        .cornerRadius(16)
        .padding(.horizontal, 16)
    }

    private func sliderRow(index: Int) -> some View {
        HStack(spacing: 10) {
            Image(systemName: index % 2 == 0 ? "flame.fill" : "circle.fill")
                .foregroundColor(index % 2 == 0 ? .orange : .yellow)
                .frame(width: 20)
            Slider(value: $engine.sliderValues[index], in: 0...1)
                .tint(index % 2 == 0 ? .orange : .yellow)
                .onChange(of: engine.sliderValues[index]) { _ in engine.recalculate() }
            Text("\(Int(engine.sliderValues[index] * 100))%")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 36)
        }
    }

    private var confirmButton: some View {
        Button(action: {
            if engine.isBalanced {
                gameState.completeLevel(levelIndex, stars: engine.calculateStars())
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: engine.isBalanced ? "checkmark.circle.fill" : "scalemass.fill")
                Text(engine.isBalanced ? "Perfekt! Bestätigen" : "Noch nicht balanciert...")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(engine.isBalanced ? Color.green : Color.gray.opacity(0.5))
            .clipShape(Capsule())
            .padding(.horizontal, 24)
        }
        .disabled(!engine.isBalanced)
        .animation(.easeInOut(duration: 0.3), value: engine.isBalanced)
    }
}

// MARK: - Thermometer Game View

struct ThermometerGameView: View {
    @EnvironmentObject var gameState: GameState
    let config: ThermometerConfig
    let level: GameLevel
    let levelIndex: Int

    @StateObject private var engine: ThermometerEngine

    init(config: ThermometerConfig, level: GameLevel, levelIndex: Int) {
        self.config = config
        self.level = level
        self.levelIndex = levelIndex
        _engine = StateObject(wrappedValue: ThermometerEngine(config: config))
    }

    var body: some View {
        VStack(spacing: 0) {
            thermometerHUD
            thermometerDisplay
            boardGrid
            Spacer()
        }
        .onChange(of: engine.isComplete) { complete in
            if complete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    gameState.completeLevel(levelIndex, stars: engine.calculateStars())
                }
            }
        }
    }

    private var thermometerHUD: some View {
        HStack {
            Button(action: { gameState.goToLevelSelect() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 34, height: 34)
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            .padding(.leading, 16)
            Spacer()
            VStack(spacing: 2) {
                Text(level.title)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("Züge: \(engine.movesLeft)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(engine.movesLeft <= 5 ? .red : .white.opacity(0.7))
            }
            Spacer()
        }
        .padding(.top, 52)
        .padding(.bottom, 8)
    }

    private var thermometerDisplay: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 36, height: 160)
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.4), lineWidth: 2))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.3, green: 0.5, blue: 0.95), Color(red: 0.9, green: 0.25, blue: 0.2)],
                            startPoint: .bottom, endPoint: .top
                        )
                    )
                    .frame(width: 28, height: 160 * engine.fillLevel)
                    .animation(.spring(response: 0.4, dampingFraction: 0.65), value: engine.fillLevel)

                Circle()
                    .fill(Color(red: 0.3, green: 0.5, blue: 0.95))
                    .frame(width: 44, height: 44)
                    .offset(y: 22)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Füllung: \(Int(engine.fillLevel * 100))%")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Ziel: \(Int(config.targetFill * 100))%")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                ProgressView(value: engine.fillLevel, total: config.targetFill)
                    .tint(engine.fillLevel >= config.targetFill ? .green : .blue)
                    .frame(width: 160)

                if engine.fillLevel >= config.targetFill {
                    Label("Ziel erreicht!", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.2))
        .cornerRadius(16)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private var boardGrid: some View {
        GeometryReader { geo in
            let tileCount = config.tileTypes + 1
            let tileSize = min(geo.size.width / CGFloat(tileCount), 64.0) - 6

            VStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { row in
                    HStack(spacing: 6) {
                        ForEach(0..<tileCount, id: \.self) { col in
                            let index = row * tileCount + col
                            if index < engine.tiles.count {
                                thermometerTileView(index: index, size: tileSize)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 16)
    }

    private func thermometerTileView(index: Int, size: CGFloat) -> some View {
        let tile = engine.tiles[index]
        return Button(action: { engine.tap(index: index) }) {
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.2)
                    .fill(
                        LinearGradient(
                            colors: [tile.color.color.opacity(0.85), tile.color.color.opacity(0.55)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .overlay(RoundedRectangle(cornerRadius: size * 0.2).strokeBorder(Color.white.opacity(0.2), lineWidth: 1))
                    .shadow(color: tile.color.color.opacity(0.4), radius: 3)

                Image(systemName: tile.color.symbol)
                    .font(.system(size: size * 0.4))
                    .foregroundColor(.white)
            }
            .frame(width: size, height: size)
            .opacity(tile.isRemoving ? 0.15 : 1.0)
            .scaleEffect(tile.isRemoving ? 1.3 : 1.0)
            .animation(.easeOut(duration: 0.2), value: tile.isRemoving)
        }
        .buttonStyle(.plain)
    }
}
