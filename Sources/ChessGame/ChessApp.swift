import SwiftUI
import ChessCore

@main
struct ChessApp: App {
    var body: some Scene {
        WindowGroup("Chess") {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
