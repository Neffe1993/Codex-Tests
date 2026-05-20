import SwiftUI

enum Screen: Equatable {
    case map
    case pipe(Int)       // Rohr-Puzzle Level-Index
    case hourglass(Int)
    case result(Int, Int)
}

final class GameState: ObservableObject {
    @Published var screen: Screen = .map
    @Published var stars: Int = 25348
    @Published var levelStars: [Int: Int] = [:]   // levelId → best stars earned

    // DEV MODE: alle Level sofort spielbar
    func bestStars(for id: Int) -> Int { levelStars[id] ?? 0 }

    func complete(_ levelId: Int, stars s: Int) {
        let prev = levelStars[levelId] ?? 0
        if s > prev {
            stars += (s - prev) * 10
            levelStars[levelId] = s
        }
        screen = .result(levelId, s)
    }
}
