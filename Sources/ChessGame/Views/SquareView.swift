import SwiftUI
import ChessCore

struct SquareView: View {
    let piece: Piece?
    let isSelected: Bool
    let isLegalMove: Bool
    let isLight: Bool
    let squareSize: CGFloat

    private static let lightColor = Color(red: 0.94, green: 0.85, blue: 0.71)
    private static let darkColor  = Color(red: 0.71, green: 0.53, blue: 0.39)

    private var background: Color {
        if isSelected { return .yellow.opacity(0.85) }
        return isLight ? Self.lightColor : Self.darkColor
    }

    var body: some View {
        ZStack {
            background

            // Legal-move indicator.
            if isLegalMove {
                if piece != nil {
                    // Capture target: ring around the edge.
                    Circle()
                        .strokeBorder(Color.black.opacity(0.3), lineWidth: 4)
                        .padding(2)
                } else {
                    // Empty square: small dot in the centre.
                    Circle()
                        .fill(Color.black.opacity(0.2))
                        .padding(squareSize * 0.28)
                }
            }

            // Piece glyph.
            if let piece {
                Text(piece.symbol)
                    .font(.system(size: squareSize * 0.70))
                    .shadow(color: .black.opacity(0.25), radius: 1, x: 0.5, y: 1)
            }
        }
        .frame(width: squareSize, height: squareSize)
    }
}
