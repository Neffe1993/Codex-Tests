import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameState: GameState

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            screenView
        }
        .animation(.easeInOut(duration: 0.5), value: gameState.currentScreen)
    }

    @ViewBuilder
    private var screenView: some View {
        switch gameState.currentScreen {
        case .mainMenu:
            MainMenuView()
                .transition(.opacity)
        case .levelSelect:
            LevelSelectView()
                .transition(.move(edge: .trailing))
        case .story(let levelIndex):
            StoryView(levelIndex: levelIndex)
                .transition(.opacity)
        case .game(let levelIndex):
            GameContainerView(levelIndex: levelIndex)
                .transition(.move(edge: .bottom))
        case .result(let stars, let levelIndex):
            ResultView(stars: stars, levelIndex: levelIndex)
                .transition(.scale.combined(with: .opacity))
        }
    }
}
