import Foundation

/// A position on the 8×8 board.
/// Row 0 = rank 8 (black's back rank, top of board).
/// Col 0 = file a (left side).
public struct Position: Equatable, Hashable {
    public let row: Int
    public let col: Int

    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }

    public var isValid: Bool {
        row >= 0 && row < 8 && col >= 0 && col < 8
    }

    /// File letter: a–h.
    public var fileLabel: String {
        String(UnicodeScalar(UInt32(col) + 97)!)
    }

    /// Rank number: 1–8.
    public var rankLabel: String { "\(8 - row)" }

    /// Algebraic notation, e.g. "e4".
    public var notation: String { "\(fileLabel)\(rankLabel)" }
}
