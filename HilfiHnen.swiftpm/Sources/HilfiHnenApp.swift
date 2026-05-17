import SwiftUI

@main
struct HilfiHnenApp: App {
    @StateObject private var gs = GameState()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(gs)
                .preferredColorScheme(.light)
        }
    }
}
