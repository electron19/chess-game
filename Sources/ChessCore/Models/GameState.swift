import Foundation
import Combine

// MARK: - GameStatus

public enum GameStatus: Equatable {
    case playing
    case check
    case checkmate(winner: PieceColor)
    case stalemate
}

// MARK: - GameState

public final class GameState: ObservableObject {
    @Published public var board: Board
    @Published public var currentTurn: PieceColor
    @Published public var status: GameStatus
    @Published public var selectedPosition: Position?
    @Published public var legalMovesForSelected: [Move]
    @Published public var capturedByWhite: [Piece]   // pieces white has taken
    @Published public var capturedByBlack: [Piece]   // pieces black has taken

    public init() {
        board = Board()
        currentTurn = .white
        status = .playing
        selectedPosition = nil
        legalMovesForSelected = []
        capturedByWhite = []
        capturedByBlack = []
    }

    // MARK: - Public API

    public var isGameOver: Bool {
        switch status {
        case .checkmate, .stalemate: return true
        default: return false
        }
    }

    /// Handle a tap on `position`. Selects a piece or executes a move.
    public func select(position: Position) {
        guard !isGameOver else { return }

        // If something is already selected, try to move there first.
        if selectedPosition != nil {
            let candidates = legalMovesForSelected.filter { $0.to == position }
            if !candidates.isEmpty {
                // Prefer queen promotion; otherwise take the first candidate.
                let move = candidates.first(where: { $0.promotion == .queen }) ?? candidates[0]
                applyMove(move)
                selectedPosition = nil
                legalMovesForSelected = []
                return
            }
        }

        // Select a piece belonging to the current player.
        if let piece = board[position], piece.color == currentTurn {
            selectedPosition = position
            legalMovesForSelected = MoveGenerator.legalMoves(from: position, on: board)
        } else {
            selectedPosition = nil
            legalMovesForSelected = []
        }
    }

    public func newGame() {
        board = Board()
        currentTurn = .white
        status = .playing
        selectedPosition = nil
        legalMovesForSelected = []
        capturedByWhite = []
        capturedByBlack = []
    }

    // MARK: - Private

    private func applyMove(_ move: Move) {
        // Track the captured piece (regular capture).
        if let captured = board[move.to] {
            append(captured: captured, by: currentTurn)
        }
        // Track en passant capture.
        if move.isEnPassant {
            append(captured: Piece(type: .pawn, color: currentTurn.opposite), by: currentTurn)
        }

        board.apply(move: move)
        currentTurn = currentTurn.opposite
        refreshStatus()
    }

    private func append(captured piece: Piece, by capturer: PieceColor) {
        if capturer == .white {
            capturedByWhite.append(piece)
        } else {
            capturedByBlack.append(piece)
        }
    }

    private func refreshStatus() {
        if MoveGenerator.isCheckmate(color: currentTurn, on: board) {
            status = .checkmate(winner: currentTurn.opposite)
        } else if MoveGenerator.isStalemate(color: currentTurn, on: board) {
            status = .stalemate
        } else if MoveGenerator.isInCheck(color: currentTurn, on: board) {
            status = .check
        } else {
            status = .playing
        }
    }
}
