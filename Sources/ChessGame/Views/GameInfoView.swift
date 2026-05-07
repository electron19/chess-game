import SwiftUI
import ChessCore

struct GameInfoView: View {
    @ObservedObject var game: GameState

    var body: some View {
        VStack(spacing: 6) {
            Text("Chess")
                .font(.system(size: 26, weight: .bold, design: .rounded))

            HStack(spacing: 8) {
                Circle()
                    .fill(turnDotColor)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().strokeBorder(Color.gray.opacity(0.6), lineWidth: 1))

                Text(statusText)
                    .font(.headline)
                    .foregroundColor(statusColor)
                    .animation(.default, value: statusText)
            }
        }
        .padding(.bottom, 4)
    }

    // MARK: - Helpers

    private var turnDotColor: Color {
        game.currentTurn == .white ? .white : .black
    }

    private var statusText: String {
        switch game.status {
        case .playing:
            return "\(label(game.currentTurn)) to move"
        case .check:
            return "\(label(game.currentTurn)) is in check!"
        case .checkmate(let winner):
            return "\(label(winner)) wins by checkmate!"
        case .stalemate:
            return "Stalemate — draw!"
        }
    }

    private var statusColor: Color {
        switch game.status {
        case .playing:             return .primary
        case .check:               return .red
        case .checkmate:           return .green
        case .stalemate:           return .orange
        }
    }

    private func label(_ color: PieceColor) -> String {
        color == .white ? "White" : "Black"
    }
}
