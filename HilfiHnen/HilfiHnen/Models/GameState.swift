import Foundation
import Combine

enum AppScreen: Equatable {
    case mainMenu
    case levelSelect
    case story(levelIndex: Int)
    case game(levelIndex: Int)
    case result(stars: Int, levelIndex: Int)
}

final class GameState: ObservableObject {
    @Published var currentScreen: AppScreen = .mainMenu
    @Published var totalStars: Int = 0
    @Published var levelProgress: [Int: Int] = [:]   // levelIndex → best stars (0-3)
    @Published var coins: Int = 1000

    var unlockedLevels: Int {
        // Level 0 always unlocked; unlock next if previous completed
        var count = 1
        for i in 0..<LevelData.levels.count {
            if (levelProgress[i] ?? 0) > 0 { count = i + 2 }
        }
        return min(count, LevelData.levels.count)
    }

    func startLevel(_ index: Int) {
        currentScreen = .story(levelIndex: index)
    }

    func beginGame(_ index: Int) {
        currentScreen = .game(levelIndex: index)
    }

    func completeLevel(_ index: Int, stars: Int) {
        let prev = levelProgress[index] ?? 0
        if stars > prev {
            levelProgress[index] = stars
            let newStars = stars - prev
            totalStars += newStars
        }
        currentScreen = .result(stars: stars, levelIndex: index)
    }

    func goToLevelSelect() {
        currentScreen = .levelSelect
    }

    func goToMainMenu() {
        currentScreen = .mainMenu
    }

    func nextLevel(after index: Int) {
        let next = index + 1
        if next < LevelData.levels.count {
            startLevel(next)
        } else {
            goToLevelSelect()
        }
    }
}
