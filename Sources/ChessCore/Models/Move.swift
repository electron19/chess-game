import Foundation

/// Represents a single chess move.
public struct Move: Equatable {
    public let from: Position
    public let to: Position
    /// Non-nil when a pawn reaches the back rank; contains the chosen piece type.
    public var promotion: PieceType?
    /// True when the move is a pawn en passant capture.
    public var isEnPassant: Bool
    /// True when the move is a king castling move.
    public var isCastling: Bool

    public init(
        from: Position,
        to: Position,
        promotion: PieceType? = nil,
        isEnPassant: Bool = false,
        isCastling: Bool = false
    ) {
        self.from = from
        self.to = to
        self.promotion = promotion
        self.isEnPassant = isEnPassant
        self.isCastling = isCastling
    }

    /// Short coordinate notation, e.g. "e2e4".
    public var notation: String { "\(from.notation)\(to.notation)" }
}
