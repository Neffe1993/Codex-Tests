import SwiftUI

struct LevelInfo: Identifiable {
    let id: Int
    let bannerText: String
    let bodyText: String
    let scene: SceneType
    let needs: [(icon: String, color: Color)]
    let gameType: GameType

    enum SceneType { case winterOutdoor, brokenRoom, snowStorm, fireRoom }
    enum GameType  { case match3, pipe, hourglass, match3Fire }
}

let allLevels: [LevelInfo] = [
    LevelInfo(
        id: 0,
        bannerText: "Hilf ihnen!",
        bodyText: "Marie und ihre Kinder sind in der eisigen Kälte gestrandet.",
        scene: .winterOutdoor,
        needs: [("jacket", Color(red:0.9,green:0.35,blue:0.15)), ("house.fill", Color(red:0.85,green:0.55,blue:0.1))],
        gameType: .match3
    ),
    LevelInfo(
        id: 1,
        bannerText: "Hilf ihnen!",
        bodyText: "Das Zimmer ist kaputt — Ventilator, Fenster und Kamin müssen repariert werden.",
        scene: .brokenRoom,
        needs: [("fan", .white), ("window.casement", Color(red:0.9,green:0.6,blue:0.1)), ("flame", Color(red:0.95,green:0.4,blue:0.1))],
        gameType: .pipe
    ),
    LevelInfo(
        id: 2,
        bannerText: "Stell dich der Herausforderung!",
        bodyText: "Sammle mehr Ressourcen als dein Gegner!",
        scene: .snowStorm,
        needs: [("drop.fill", .blue), ("fork.knife", .orange)],
        gameType: .hourglass
    ),
    LevelInfo(
        id: 3,
        bannerText: "Spiele Minispiele!",
        bodyText: "Verbinde das Rohr um Münzen zu sammeln.",
        scene: .fireRoom,
        needs: [("pipe.and.drop", .cyan)],
        gameType: .pipe
    ),
    LevelInfo(
        id: 4,
        bannerText: "Hilf ihnen!",
        bodyText: "Feuer! Sammle Wasser bevor es zu spät ist.",
        scene: .fireRoom,
        needs: [("flame.fill", .orange), ("drop.fill", .blue)],
        gameType: .match3Fire
    ),
    LevelInfo(
        id: 5,
        bannerText: "Hilf ihnen!",
        bodyText: "Sturm zerstört das Dorf. Rette alle Familien!",
        scene: .winterOutdoor,
        needs: [("wind", .white), ("house.fill", Color(red:0.85,green:0.55,blue:0.1))],
        gameType: .match3
    ),
]
