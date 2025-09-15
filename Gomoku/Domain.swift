import Foundation

// MARK: - Core Domain Types

enum Player: String, CaseIterable {
    case black = "Black"
    case white = "White"
    case none = ""
}

extension Player {
    var localizedName: String {
        switch self {
        case .black: return NSLocalizedString("Black", comment: "Player name")
        case .white: return NSLocalizedString("White", comment: "Player name")
        case .none: return ""
        }
    }
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
            return String(format: NSLocalizedString("Invalid move: %@", comment: ""), reason)
        case .gameAlreadyOver:
            return NSLocalizedString("The game is already over", comment: "")
        case .invalidBoardState:
            return NSLocalizedString("Invalid board state", comment: "")
        case .positionOccupied(let row, let col):
            return String(format: NSLocalizedString("Position (%d, %d) is already occupied", comment: ""), row, col)
        case .outOfBounds(let row, let col):
            return String(format: NSLocalizedString("Position (%d, %d) is out of bounds", comment: ""), row, col)
        }
    }
}

// MARK: - Protocols

protocol GameBoardDataSource {
    var board: [[Player]] { get }
    var currentPlayer: Player { get }
    var size: Int { get }
}
