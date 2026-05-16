import SwiftUI

enum LevelType {
    case match3(config: Match3Config)
    case pipePuzzle(config: PipeConfig)
    case balanceChallenge(config: BalanceConfig)
    case thermometer(config: ThermometerConfig)
}

struct Match3Config {
    var rows: Int = 8
    var cols: Int = 8
    var tileTypes: Int = 5
    var targetScore: Int
    var moveLimit: Int
    var specialGoals: [TileGoal]
}

struct TileGoal {
    var tileColor: TileColor
    var count: Int
}

struct PipeConfig {
    var gridSize: Int = 6
    var segments: [PipeSegment]
    var coinTarget: Int
}

struct PipeSegment {
    var row: Int
    var col: Int
    var type: SegmentType
    var isFixed: Bool

    enum SegmentType {
        case straight, curve, junction, end
    }
}

struct BalanceConfig {
    var sliderCount: Int
    var targetRatio: Double
    var tolerance: Double
}

struct ThermometerConfig {
    var targetFill: Double
    var moveLimit: Int
    var tileTypes: Int = 4
}

struct ScenarioCharacter {
    var name: String
    var imageName: String
    var speechBubble: String
}

struct StorySlide {
    var backgroundGradient: [Color]
    var characters: [ScenarioCharacter]
    var needs: [String]
    var titleText: String
    var bodyText: String
}

struct GameLevel {
    var id: Int
    var title: String
    var subtitle: String
    var scenario: Scenario
    var type: LevelType
    var storySlides: [StorySlide]
    var rewardText: String
    var backgroundColors: [Color]
    var difficultyLabel: String

    enum Scenario {
        case winterRescue
        case brokenHome
        case snowStorm
        case fireRescue
        case floodRescue
        case desertHeat
        case cityRebuild
        case forestRestore
        case oceanClean
        case mountainSurvival
    }
}

enum TileColor: String, CaseIterable {
    case red, blue, green, yellow, purple, orange

    var color: Color {
        switch self {
        case .red:    return Color(red: 0.95, green: 0.3, blue: 0.3)
        case .blue:   return Color(red: 0.3, green: 0.55, blue: 0.95)
        case .green:  return Color(red: 0.3, green: 0.85, blue: 0.4)
        case .yellow: return Color(red: 1.0, green: 0.85, blue: 0.2)
        case .purple: return Color(red: 0.7, green: 0.3, blue: 0.95)
        case .orange: return Color(red: 1.0, green: 0.6, blue: 0.15)
        }
    }

    var symbol: String {
        switch self {
        case .red:    return "heart.fill"
        case .blue:   return "drop.fill"
        case .green:  return "leaf.fill"
        case .yellow: return "star.fill"
        case .purple: return "moon.fill"
        case .orange: return "flame.fill"
        }
    }
}
