import Foundation
import SwiftUI
import Combine

struct Tile {
    var color: TileColor
    var isSpecial: Bool = false
    var isRemoving: Bool = false
    var isNew: Bool = false
    var id: UUID = UUID()
}

struct TilePosition: Equatable {
    var row: Int
    var col: Int
}

struct GoalProgress: Identifiable {
    var id: String { tileColor.rawValue }
    var tileColor: TileColor
    var target: Int
    var collected: Int
    var isComplete: Bool { collected >= target }
}

final class Match3Engine: ObservableObject {
    @Published var board: [[Tile]] = []
    @Published var score: Int = 0
    @Published var movesLeft: Int = 0
    @Published var selectedTile: TilePosition? = nil
    @Published var goalProgress: [GoalProgress] = []
    @Published var isComplete: Bool = false

    private let config: Match3Config
    private let availableColors: [TileColor]

    init(config: Match3Config) {
        self.config = config
        self.movesLeft = config.moveLimit
        self.availableColors = Array(TileColor.allCases.prefix(config.tileTypes))
        self.goalProgress = config.specialGoals.map { GoalProgress(tileColor: $0.tileColor, target: $0.count, collected: 0) }
        generateBoard()
    }

    private func generateBoard() {
        board = (0..<config.rows).map { _ in
            (0..<config.cols).map { _ in
                Tile(color: availableColors.randomElement()!, isNew: true)
            }
        }
        resolveInitialMatches()
    }

    private func resolveInitialMatches() {
        var iterations = 0
        while findMatches().isEmpty == false && iterations < 20 {
            let matches = findMatches()
            for pos in matches {
                board[pos.row][pos.col] = Tile(color: availableColors.randomElement()!)
            }
            iterations += 1
        }
        for row in 0..<config.rows {
            for col in 0..<config.cols {
                board[row][col].isNew = false
            }
        }
    }

    func tap(row: Int, col: Int) {
        guard !isComplete else { return }

        if let selected = selectedTile {
            if selected.row == row && selected.col == col {
                selectedTile = nil
                return
            }
            let dr = abs(selected.row - row)
            let dc = abs(selected.col - col)
            if (dr == 1 && dc == 0) || (dr == 0 && dc == 1) {
                swap(from: selected, to: TilePosition(row: row, col: col))
                selectedTile = nil
            } else {
                selectedTile = TilePosition(row: row, col: col)
            }
        } else {
            selectedTile = TilePosition(row: row, col: col)
        }
    }

    private func swap(from: TilePosition, to: TilePosition) {
        let temp = board[from.row][from.col]
        board[from.row][from.col] = board[to.row][to.col]
        board[to.row][to.col] = temp

        let matches = findMatches()
        if matches.isEmpty {
            // revert
            let revert = board[from.row][from.col]
            board[from.row][from.col] = board[to.row][to.col]
            board[to.row][to.col] = revert
            return
        }

        movesLeft -= 1
        processMatches(matches)
    }

    private func processMatches(_ matches: [TilePosition]) {
        var scoreGain = matches.count * 10
        if matches.count >= 5 { scoreGain += 50 }
        else if matches.count >= 4 { scoreGain += 20 }
        score += scoreGain

        for pos in matches {
            let color = board[pos.row][pos.col].color
            board[pos.row][pos.col].isRemoving = true
            collectGoal(color: color)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.removeAndRefill(positions: matches)
        }
    }

    private func collectGoal(color: TileColor) {
        for i in 0..<goalProgress.count {
            if goalProgress[i].tileColor == color && !goalProgress[i].isComplete {
                goalProgress[i].collected = min(goalProgress[i].collected + 1, goalProgress[i].target)
            }
        }
    }

    private func removeAndRefill(positions: [TilePosition]) {
        for pos in positions {
            board[pos.row][pos.col] = Tile(color: availableColors.randomElement()!, isNew: true)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            guard let self = self else { return }
            for row in 0..<self.config.rows {
                for col in 0..<self.config.cols {
                    self.board[row][col].isNew = false
                }
            }
            let newMatches = self.findMatches()
            if !newMatches.isEmpty {
                self.processMatches(newMatches)
            } else {
                self.checkCompletion()
            }
        }
    }

    private func findMatches() -> [TilePosition] {
        var matched = Set<String>()
        var positions: [TilePosition] = []

        func key(_ r: Int, _ c: Int) -> String { "\(r),\(c)" }

        // horizontal
        for row in 0..<config.rows {
            var col = 0
            while col < config.cols - 2 {
                let color = board[row][col].color
                var end = col + 1
                while end < config.cols && board[row][end].color == color { end += 1 }
                if end - col >= 3 {
                    for c in col..<end {
                        if matched.insert(key(row, c)).inserted {
                            positions.append(TilePosition(row: row, col: c))
                        }
                    }
                }
                col = end
            }
        }

        // vertical
        for col in 0..<config.cols {
            var row = 0
            while row < config.rows - 2 {
                let color = board[row][col].color
                var end = row + 1
                while end < config.rows && board[end][col].color == color { end += 1 }
                if end - row >= 3 {
                    for r in row..<end {
                        if matched.insert(key(r, col)).inserted {
                            positions.append(TilePosition(row: r, col: col))
                        }
                    }
                }
                row = end
            }
        }

        return positions
    }

    private func checkCompletion() {
        let scoreReached = score >= config.targetScore
        let goalsComplete = goalProgress.allSatisfy { $0.isComplete }
        let noMoves = movesLeft <= 0

        if scoreReached && goalsComplete {
            isComplete = true
        } else if noMoves {
            isComplete = true
        }
    }

    func calculateStars() -> Int {
        let goalsComplete = goalProgress.allSatisfy { $0.isComplete }
        let scoreReached = score >= config.targetScore

        if goalsComplete && scoreReached && movesLeft >= config.moveLimit / 3 { return 3 }
        if goalsComplete && scoreReached { return 2 }
        if scoreReached || goalsComplete { return 1 }
        return 0
    }
}
