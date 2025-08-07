import Foundation

// MARK: - Core Domain Types

enum Player: String, CaseIterable {
    case black = "Black"
    case white = "White"
    case none = ""
}

enum GameError: LocalizedError {
    case invalidMove(reason: String)
    case gameAlreadyOver
    case invalidBoardState
    case positionOccupied(row: Int, col: Int)
    case outOfBounds(row: Int, col: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidMove(let reason):
            return "Invalid move: \(reason)"
        case .gameAlreadyOver:
            return "The game is already over"
        case .invalidBoardState:
            return "Invalid board state"
        case .positionOccupied(let row, let col):
            return "Position (\(row), \(col)) is already occupied"
        case .outOfBounds(let row, let col):
            return "Position (\(row), \(col)) is out of bounds"
        }
    }
}

// MARK: - Protocols

protocol GameBoardDataSource {
    var board: [[Player]] { get }
    var currentPlayer: Player { get }
    var size: Int { get }
}


