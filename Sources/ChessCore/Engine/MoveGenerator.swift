import Foundation

/// Generates legal chess moves and evaluates game state conditions.
public struct MoveGenerator {

    // MARK: - Public interface

    /// All legal moves for every piece of `color`.
    public static func legalMoves(for color: PieceColor, on board: Board) -> [Move] {
        var moves: [Move] = []
        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if board[pos]?.color == color {
                    moves += legalMoves(from: pos, on: board)
                }
            }
        }
        return moves
    }

    /// Legal moves for the piece on `pos` (filters pseudo-legal moves that leave the king in check).
    public static func legalMoves(from pos: Position, on board: Board) -> [Move] {
        guard let piece = board[pos] else { return [] }
        return pseudoLegalMoves(for: piece, from: pos, on: board).filter { move in
            var next = board
            next.apply(move: move)
            return !isInCheck(color: piece.color, on: next)
        }
    }

    public static func isInCheck(color: PieceColor, on board: Board) -> Bool {
        guard let kingPos = findKing(color: color, on: board) else { return false }
        return isAttacked(kingPos, by: color.opposite, on: board)
    }

    public static func isCheckmate(color: PieceColor, on board: Board) -> Bool {
        isInCheck(color: color, on: board) && legalMoves(for: color, on: board).isEmpty
    }

    public static func isStalemate(color: PieceColor, on board: Board) -> Bool {
        !isInCheck(color: color, on: board) && legalMoves(for: color, on: board).isEmpty
    }

    // MARK: - Internal helpers

    static func pseudoLegalMoves(for piece: Piece, from pos: Position, on board: Board) -> [Move] {
        switch piece.type {
        case .pawn:   return pawnMoves(piece: piece, from: pos, on: board)
        case .knight: return knightMoves(piece: piece, from: pos, on: board)
        case .bishop: return slidingMoves(piece: piece, from: pos, on: board,
                                          dirs: [(-1,-1),(-1,1),(1,-1),(1,1)])
        case .rook:   return slidingMoves(piece: piece, from: pos, on: board,
                                          dirs: [(-1,0),(1,0),(0,-1),(0,1)])
        case .queen:  return slidingMoves(piece: piece, from: pos, on: board,
                                          dirs: [(-1,-1),(-1,1),(1,-1),(1,1),
                                                 (-1,0),(1,0),(0,-1),(0,1)])
        case .king:   return kingMoves(piece: piece, from: pos, on: board)
        }
    }

    // MARK: - Piece move generators

    private static func pawnMoves(piece: Piece, from pos: Position, on board: Board) -> [Move] {
        var moves: [Move] = []
        let dir       = piece.color == .white ? -1 : 1
        let startRow  = piece.color == .white ? 6 : 1
        let promoRow  = piece.color == .white ? 0 : 7

        // One square forward.
        let fwd = Position(row: pos.row + dir, col: pos.col)
        if fwd.isValid && board[fwd] == nil {
            if fwd.row == promoRow {
                appendPromotions(from: pos, to: fwd, into: &moves)
            } else {
                moves.append(Move(from: pos, to: fwd))
                // Two squares from the starting rank.
                let fwd2 = Position(row: pos.row + 2 * dir, col: pos.col)
                if pos.row == startRow && board[fwd2] == nil {
                    moves.append(Move(from: pos, to: fwd2))
                }
            }
        }

        // Diagonal captures and en passant.
        for dc in [-1, 1] {
            let cap = Position(row: pos.row + dir, col: pos.col + dc)
            guard cap.isValid else { continue }

            if let target = board[cap], target.color != piece.color {
                if cap.row == promoRow {
                    appendPromotions(from: pos, to: cap, into: &moves)
                } else {
                    moves.append(Move(from: pos, to: cap))
                }
            }

            if let ep = board.enPassantTarget, cap == ep {
                moves.append(Move(from: pos, to: cap, isEnPassant: true))
            }
        }

        return moves
    }

    private static func appendPromotions(from: Position, to: Position, into moves: inout [Move]) {
        for pt in [PieceType.queen, .rook, .bishop, .knight] {
            moves.append(Move(from: from, to: to, promotion: pt))
        }
    }

    private static func knightMoves(piece: Piece, from pos: Position, on board: Board) -> [Move] {
        [(-2,-1),(-2,1),(-1,-2),(-1,2),(1,-2),(1,2),(2,-1),(2,1)].compactMap { (dr, dc) in
            let target = Position(row: pos.row + dr, col: pos.col + dc)
            guard target.isValid, board[target]?.color != piece.color else { return nil }
            return Move(from: pos, to: target)
        }
    }

    private static func slidingMoves(piece: Piece, from pos: Position, on board: Board,
                                     dirs: [(Int, Int)]) -> [Move] {
        var moves: [Move] = []
        for (dr, dc) in dirs {
            var cur = Position(row: pos.row + dr, col: pos.col + dc)
            while cur.isValid {
                if let occupant = board[cur] {
                    if occupant.color != piece.color { moves.append(Move(from: pos, to: cur)) }
                    break
                }
                moves.append(Move(from: pos, to: cur))
                cur = Position(row: cur.row + dr, col: cur.col + dc)
            }
        }
        return moves
    }

    private static func kingMoves(piece: Piece, from pos: Position, on board: Board) -> [Move] {
        var moves: [Move] = []

        // Regular one-square moves in all 8 directions.
        for (dr, dc) in [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)] {
            let target = Position(row: pos.row + dr, col: pos.col + dc)
            guard target.isValid, board[target]?.color != piece.color else { continue }
            moves.append(Move(from: pos, to: target))
        }

        // Castling: king must be on its starting square and not in check.
        let backRow = piece.color == .white ? 7 : 0
        guard pos == Position(row: backRow, col: 4),
              !isInCheck(color: piece.color, on: board) else { return moves }

        // Kingside castling (f and g files must be empty; king must not pass through f).
        let canKS = piece.color == .white
            ? board.castlingRights.whiteKingside
            : board.castlingRights.blackKingside
        if canKS,
           board[Position(row: backRow, col: 5)] == nil,
           board[Position(row: backRow, col: 6)] == nil {
            var test = board
            test.squares[backRow][5] = test.squares[backRow][4]
            test.squares[backRow][4] = nil
            if !isInCheck(color: piece.color, on: test) {
                moves.append(Move(from: pos, to: Position(row: backRow, col: 6), isCastling: true))
            }
        }

        // Queenside castling (b, c, d files must be empty; king must not pass through d).
        let canQS = piece.color == .white
            ? board.castlingRights.whiteQueenside
            : board.castlingRights.blackQueenside
        if canQS,
           board[Position(row: backRow, col: 3)] == nil,
           board[Position(row: backRow, col: 2)] == nil,
           board[Position(row: backRow, col: 1)] == nil {
            var test = board
            test.squares[backRow][3] = test.squares[backRow][4]
            test.squares[backRow][4] = nil
            if !isInCheck(color: piece.color, on: test) {
                moves.append(Move(from: pos, to: Position(row: backRow, col: 2), isCastling: true))
            }
        }

        return moves
    }

    // MARK: - Attack helpers

    private static func findKing(color: PieceColor, on board: Board) -> Position? {
        let target = Piece(type: .king, color: color)
        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if board[pos] == target { return pos }
            }
        }
        return nil
    }

    /// Returns true if `pos` is attacked by any piece of `attacker`.
    private static func isAttacked(_ pos: Position, by attacker: PieceColor, on board: Board) -> Bool {
        for row in 0..<8 {
            for col in 0..<8 {
                let attackerPos = Position(row: row, col: col)
                guard let piece = board[attackerPos], piece.color == attacker else { continue }
                let attacks = pseudoLegalMoves(for: piece, from: attackerPos, on: board)
                if attacks.contains(where: { $0.to == pos }) { return true }
            }
        }
        return false
    }
}
