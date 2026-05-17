import SwiftUI
import Combine

enum Screen: Equatable {
    case map
    case scenario(Int)
    case match3(Int)
    case pipe(Int)
    case hourglass(Int)
    case result(Int, Int) // levelIndex, stars
}

final class GameState: ObservableObject {
    @Published var screen: Screen = .map
    @Published var stars: Int = 25348
    @Published var completedLevels: [Int: Int] = [:]   // level → stars

    func unlocked(_ i: Int) -> Bool { i == 0 || (completedLevels[i-1] ?? 0) > 0 }

    func complete(_ level: Int, stars s: Int) {
        let prev = completedLevels[level] ?? 0
        if s > prev { stars += (s - prev) * 10; completedLevels[level] = s }
        screen = .result(level, s)
    }
}
