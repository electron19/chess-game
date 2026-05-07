import SwiftUI
import ChessCore

struct ContentView: View {
    @StateObject private var game = GameState()

    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(spacing: 16) {
                GameInfoView(game: game)
                BoardView(game: game)
                Button("New Game") { game.newGame() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
            CapturedPiecesView(game: game)
        }
        .padding(24)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
