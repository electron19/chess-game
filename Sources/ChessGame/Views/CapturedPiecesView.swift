import SwiftUI
import ChessCore

struct CapturedPiecesView: View {
    @ObservedObject var game: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            capturedSection(title: "White captured", pieces: game.capturedByWhite)
            Divider()
            capturedSection(title: "Black captured", pieces: game.capturedByBlack)
            Spacer()
        }
        .frame(width: 110)
        .padding(.top, 4)
    }

    private func capturedSection(title: String, pieces: [Piece]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            if pieces.isEmpty {
                Text("—")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                let sorted = pieces.sorted { $0.value > $1.value }
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(30)), count: 3), spacing: 2) {
                    ForEach(sorted.indices, id: \.self) { i in
                        Text(sorted[i].symbol)
                            .font(.system(size: 22))
                    }
                }
            }
        }
    }
}
