import Foundation
import SwiftUI
import Combine

final class ThermometerEngine: ObservableObject {
    @Published var tiles: [Tile] = []
    @Published var fillLevel: Double = 0.0
    @Published var movesLeft: Int = 0
    @Published var isComplete: Bool = false

    private let config: ThermometerConfig
    private let availableColors: [TileColor]
    private let tileCount: Int = 30

    init(config: ThermometerConfig) {
        self.config = config
        self.movesLeft = config.moveLimit
        self.availableColors = Array(TileColor.allCases.prefix(config.tileTypes))
        generateTiles()
    }

    private func generateTiles() {
        tiles = (0..<tileCount).map { _ in
            Tile(color: availableColors.randomElement()!)
        }
    }

    func tap(index: Int) {
        guard index < tiles.count, !isComplete, movesLeft > 0 else { return }
        let color = tiles[index].color

        var matchIndices: [Int] = [index]
        // Find adjacent same-color tiles (simplified: find all of same color in nearby positions)
        let row = index / (config.tileTypes + 1)
        let col = index % (config.tileTypes + 1)
        let cols = config.tileTypes + 1

        let neighbors = [(row-1,col),(row+1,col),(row,col-1),(row,col+1)]
        for (r, c) in neighbors {
            if r >= 0 && c >= 0 && c < cols {
                let ni = r * cols + c
                if ni < tiles.count && tiles[ni].color == color && ni != index {
                    matchIndices.append(ni)
                }
            }
        }

        if matchIndices.count >= 2 {
            movesLeft -= 1
            let fillGain = Double(matchIndices.count) * 0.04

            for i in matchIndices {
                tiles[i].isRemoving = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                guard let self = self else { return }
                for i in matchIndices {
                    self.tiles[i] = Tile(color: self.availableColors.randomElement()!, isNew: true)
                }
                self.fillLevel = min(self.fillLevel + fillGain, 1.0)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    for i in 0..<self.tiles.count {
                        self.tiles[i].isNew = false
                    }
                    self.checkCompletion()
                }
            }
        }
    }

    private func checkCompletion() {
        if fillLevel >= config.targetFill {
            isComplete = true
        } else if movesLeft <= 0 {
            isComplete = true
        }
    }

    func calculateStars() -> Int {
        if fillLevel >= config.targetFill && movesLeft >= config.moveLimit / 3 { return 3 }
        if fillLevel >= config.targetFill { return 2 }
        if fillLevel >= config.targetFill * 0.7 { return 1 }
        return 0
    }
}
