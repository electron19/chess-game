import Foundation

// MARK: - PieceColor

public enum PieceColor: Equatable, Hashable {
    case white, black

    public var opposite: PieceColor { self == .white ? .black : .white }
}

// MARK: - PieceType

public enum PieceType: Equatable, Hashable {
    case king, queen, rook, bishop, knight, pawn
}

// MARK: - Piece

public struct Piece: Equatable, Hashable {
    public let type: PieceType
    public let color: PieceColor

    public init(type: PieceType, color: PieceColor) {
        self.type = type
        self.color = color
    }

    /// Unicode chess symbol for display.
    public var symbol: String {
        switch color {
        case .white:
            switch type {
            case .king:   return "♔"
            case .queen:  return "♕"
            case .rook:   return "♖"
            case .bishop: return "♗"
            case .knight: return "♘"
            case .pawn:   return "♙"
            }
        case .black:
            switch type {
            case .king:   return "♚"
            case .queen:  return "♛"
            case .rook:   return "♜"
            case .bishop: return "♝"
            case .knight: return "♞"
            case .pawn:   return "♟"
            }
        }
    }

    /// Material value used for sorting captured pieces.
    public var value: Int {
        switch type {
        case .queen:           return 9
        case .rook:            return 5
        case .bishop, .knight: return 3
        case .pawn:            return 1
        case .king:            return 0
        }
    }
}
