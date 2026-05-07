import SwiftUI
import ChessCore

struct BoardView: View {
    @ObservedObject var game: GameState

    private let squareSize: CGFloat = 64

    var body: some View {
        VStack(spacing: 0) {
            // Column labels: a–h
            HStack(spacing: 0) {
                Spacer().frame(width: 20)
                ForEach(0..<8, id: \.self) { col in
                    Text(String(UnicodeScalar(UInt32(col) + 97)!))
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                        .frame(width: squareSize)
                }
            }

            HStack(spacing: 0) {
                // Row labels: 8–1
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
                        Text("\(8 - row)")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                            .frame(width: 20, height: squareSize)
                    }
                }

                // The 8×8 grid
                VStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<8, id: \.self) { col in
                                let pos = Position(row: row, col: col)
                                SquareView(
                                    piece: game.board[pos],
                                    isSelected: game.selectedPosition == pos,
                                    isLegalMove: game.legalMovesForSelected.contains(where: { $0.to == pos }),
                                    isLight: (row + col) % 2 == 0,
                                    squareSize: squareSize
                                )
                                .onTapGesture { game.select(position: pos) }
                            }
                        }
                    }
                }
                .overlay(Rectangle().strokeBorder(Color(nsColor: .separatorColor), lineWidth: 1))
            }
        }
    }
}
