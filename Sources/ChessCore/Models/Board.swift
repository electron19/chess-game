import Foundation

// MARK: - CastlingRights

public struct CastlingRights: Equatable {
    public var whiteKingside: Bool
    public var whiteQueenside: Bool
    public var blackKingside: Bool
    public var blackQueenside: Bool

    public init(
        whiteKingside: Bool = true,
        whiteQueenside: Bool = true,
        blackKingside: Bool = true,
        blackQueenside: Bool = true
    ) {
        self.whiteKingside = whiteKingside
        self.whiteQueenside = whiteQueenside
        self.blackKingside = blackKingside
        self.blackQueenside = blackQueenside
    }
}

// MARK: - Board

public struct Board: Equatable {
    /// 8×8 grid: `squares[row][col]`. Row 0 = rank 8, col 0 = file a.
    public var squares: [[Piece?]]
    /// The square to which an en passant capture can be made (the empty square
    /// behind the just-double-pushed pawn), or nil.
    public var enPassantTarget: Position?
    public var castlingRights: CastlingRights

    public init() {
        squares = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        castlingRights = CastlingRights()
        setupInitialPosition()
    }

    public subscript(position: Position) -> Piece? {
        get { squares[position.row][position.col] }
        set { squares[position.row][position.col] = newValue }
    }

    // MARK: - Setup

    private mutating func setupInitialPosition() {
        let backRank: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
        for col in 0..<8 {
            squares[0][col] = Piece(type: backRank[col], color: .black)
            squares[1][col] = Piece(type: .pawn,         color: .black)
            squares[6][col] = Piece(type: .pawn,         color: .white)
            squares[7][col] = Piece(type: backRank[col], color: .white)
        }
    }

    // MARK: - Apply move

    public mutating func apply(move: Move) {
        guard let piece = squares[move.from.row][move.from.col] else { return }

        // En passant: remove the captured pawn (it sits on the same row as the
        // capturing pawn, but on the destination column).
        if move.isEnPassant {
            squares[move.from.row][move.to.col] = nil
        }

        // Castling: also move the rook.
        if move.isCastling {
            let row = move.from.row
            if move.to.col == 6 {       // kingside: rook h→f
                squares[row][5] = squares[row][7]
                squares[row][7] = nil
            } else {                    // queenside: rook a→d
                squares[row][3] = squares[row][0]
                squares[row][0] = nil
            }
        }

        // Place the moving piece (apply promotion if any).
        let placed = move.promotion.map { Piece(type: $0, color: piece.color) } ?? piece
        squares[move.to.row][move.to.col] = placed
        squares[move.from.row][move.from.col] = nil

        // Update en passant target: set only after a two-square pawn push.
        if piece.type == .pawn && abs(move.to.row - move.from.row) == 2 {
            enPassantTarget = Position(row: (move.from.row + move.to.row) / 2, col: move.from.col)
        } else {
            enPassantTarget = nil
        }

        // Update castling rights on king move.
        if piece.type == .king {
            if piece.color == .white {
                castlingRights.whiteKingside  = false
                castlingRights.whiteQueenside = false
            } else {
                castlingRights.blackKingside  = false
                castlingRights.blackQueenside = false
            }
        }

        // Update castling rights when a rook moves or is captured.
        let a1 = Position(row: 7, col: 0), h1 = Position(row: 7, col: 7)
        let a8 = Position(row: 0, col: 0), h8 = Position(row: 0, col: 7)
        if move.from == a1 || move.to == a1 { castlingRights.whiteQueenside = false }
        if move.from == h1 || move.to == h1 { castlingRights.whiteKingside  = false }
        if move.from == a8 || move.to == a8 { castlingRights.blackQueenside = false }
        if move.from == h8 || move.to == h8 { castlingRights.blackKingside  = false }
    }
}
