import XCTest
@testable import ChessCore

final class ChessGameTests: XCTestCase {

    // MARK: - Board setup

    func testInitialBoardSetup() {
        let board = Board()
        XCTAssertEqual(board[Position(row: 7, col: 4)], Piece(type: .king,  color: .white))
        XCTAssertEqual(board[Position(row: 0, col: 4)], Piece(type: .king,  color: .black))
        XCTAssertEqual(board[Position(row: 7, col: 0)], Piece(type: .rook,  color: .white))
        XCTAssertEqual(board[Position(row: 7, col: 7)], Piece(type: .rook,  color: .white))
        XCTAssertEqual(board[Position(row: 6, col: 3)], Piece(type: .pawn,  color: .white))
        XCTAssertEqual(board[Position(row: 1, col: 3)], Piece(type: .pawn,  color: .black))
        XCTAssertNil(board[Position(row: 4, col: 4)])
    }

    // MARK: - Position

    func testPositionNotation() {
        XCTAssertEqual(Position(row: 7, col: 0).notation, "a1")
        XCTAssertEqual(Position(row: 0, col: 7).notation, "h8")
        XCTAssertEqual(Position(row: 6, col: 4).notation, "e2")
    }

    func testPositionValidity() {
        XCTAssertTrue(Position(row: 0, col: 0).isValid)
        XCTAssertTrue(Position(row: 7, col: 7).isValid)
        XCTAssertFalse(Position(row: 8, col: 0).isValid)
        XCTAssertFalse(Position(row: 0, col: -1).isValid)
    }

    // MARK: - Move count

    func testInitialLegalMoveCount() {
        let board = Board()
        // 8 pawns × 2 + 2 knights × 2 = 20 moves for White at start.
        let whiteMoves = MoveGenerator.legalMoves(for: .white, on: board)
        XCTAssertEqual(whiteMoves.count, 20)
    }

    func testPawnCanMoveTwoSquaresFromStart() {
        let board = Board()
        let e2 = Position(row: 6, col: 4)
        let moves = MoveGenerator.legalMoves(from: e2, on: board)
        XCTAssertEqual(moves.count, 2)
        XCTAssertTrue(moves.contains(where: { $0.to == Position(row: 5, col: 4) }))
        XCTAssertTrue(moves.contains(where: { $0.to == Position(row: 4, col: 4) }))
    }

    func testKnightInitialMoves() {
        let board = Board()
        // g1 knight: can go to f3 or h3
        let g1 = Position(row: 7, col: 6)
        let moves = MoveGenerator.legalMoves(from: g1, on: board)
        XCTAssertEqual(moves.count, 2)
    }

    // MARK: - Check detection

    func testNoCheckAtStart() {
        let board = Board()
        XCTAssertFalse(MoveGenerator.isInCheck(color: .white, on: board))
        XCTAssertFalse(MoveGenerator.isInCheck(color: .black, on: board))
    }

    func testScholarsMateIsCheckmate() {
        // Set up Scholar's Mate position.
        var board = Board()
        // 1. e4 e5 2. Bc4 Nc6 3. Qh5 Nf6?? 4. Qxf7#
        board.squares = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        board.castlingRights = CastlingRights(whiteKingside: false, whiteQueenside: false,
                                              blackKingside: false, blackQueenside: false)
        // White pieces
        board.squares[4][4] = Piece(type: .pawn,   color: .white)  // e4
        board.squares[4][2] = Piece(type: .bishop, color: .white)  // Bc4
        board.squares[1][5] = Piece(type: .queen,  color: .white)  // Qxf7 (already there)
        board.squares[7][4] = Piece(type: .king,   color: .white)  // e1
        // Black pieces
        board.squares[4][4] = nil
        board.squares[3][4] = Piece(type: .pawn,   color: .black)  // e5
        board.squares[2][2] = Piece(type: .knight, color: .black)  // Nc6
        board.squares[2][5] = Piece(type: .knight, color: .black)  // Nf6
        board.squares[0][4] = Piece(type: .king,   color: .black)  // e8
        board.squares[0][3] = Piece(type: .queen,  color: .black)  // d8
        board.squares[0][0] = Piece(type: .rook,   color: .black)  // a8
        board.squares[0][7] = Piece(type: .rook,   color: .black)  // h8
        // Qxf7 is already on f7; black's king is in check from Qf7 (with Bc4 support)
        XCTAssertTrue(MoveGenerator.isCheckmate(color: .black, on: board))
    }

    // MARK: - En passant

    func testEnPassantTargetSetAfterTwoSquarePush() {
        var board = Board()
        // Move d7→d5
        let d7 = Position(row: 1, col: 3)
        let d5 = Position(row: 3, col: 3)
        board.apply(move: Move(from: d7, to: d5))
        XCTAssertEqual(board.enPassantTarget, Position(row: 2, col: 3))
    }

    func testEnPassantCaptureAvailable() {
        var board = Board()
        // Clear the board and set up a targeted en passant scenario.
        board.squares = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        board.castlingRights = CastlingRights(whiteKingside: false, whiteQueenside: false,
                                              blackKingside: false, blackQueenside: false)
        board.squares[7][4] = Piece(type: .king, color: .white)
        board.squares[0][4] = Piece(type: .king, color: .black)
        board.squares[3][4] = Piece(type: .pawn, color: .white)  // e5
        board.squares[1][3] = Piece(type: .pawn, color: .black)  // d7

        // Black pushes d7→d5
        board.apply(move: Move(from: Position(row: 1, col: 3), to: Position(row: 3, col: 3)))

        // White should be able to capture en passant with the e5 pawn.
        let whiteMoves = MoveGenerator.legalMoves(from: Position(row: 3, col: 4), on: board)
        XCTAssertTrue(whiteMoves.contains(where: { $0.isEnPassant }))
    }

    // MARK: - Castling rights

    func testCastlingRightsRevokedOnKingMove() {
        var board = Board()
        // Move white king from e1 one step forward (illegal in real game but tests the right update).
        let e1 = Position(row: 7, col: 4)
        let e2 = Position(row: 6, col: 4)
        board.apply(move: Move(from: e1, to: e2))
        XCTAssertFalse(board.castlingRights.whiteKingside)
        XCTAssertFalse(board.castlingRights.whiteQueenside)
        XCTAssertTrue(board.castlingRights.blackKingside)
    }
}
