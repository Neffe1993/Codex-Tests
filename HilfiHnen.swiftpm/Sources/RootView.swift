import SwiftUI

struct RootView: View {
    @EnvironmentObject var gs: GameState

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            switch gs.screen {
            case .map:
                LevelMapView()
            case .scenario(let i):
                ScenarioView(level: allLevels[i])
            case .match3(let i):
                Match3View(level: allLevels[i])
            case .pipe(let i):
                PipeMiniGameView(level: allLevels[i])
            case .hourglass(let i):
                HourglassChallengeView(level: allLevels[i])
            case .result(let i, let s):
                ResultView(levelIndex: i, stars: s)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: gs.screen)
    }
}
