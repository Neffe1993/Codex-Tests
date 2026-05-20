import SwiftUI

struct RootView: View {
    @EnvironmentObject var gs: GameState

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            switch gs.screen {
            case .map:
                LevelMapView()
            case .pipe(let i):
                PipePuzzleView(config: allPipeLevels[i])
            case .hourglass(let i):
                HourglassChallengeView(config: allPipeLevels[i])
            case .result(let i, let s):
                ResultView(levelId: i, starsEarned: s)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: gs.screen)
    }
}
