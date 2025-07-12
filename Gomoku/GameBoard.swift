import Foundation

enum Player: String, CaseIterable {
    case black = "Black"
    case white = "White"
    case none = ""
}

enum GameError: Error {
    case invalidMove
    case gameAlreadyOver
    case invalidBoardState
}

@MainActor
class GameBoard: ObservableObject, GameBoardDataSource {
    static let size = 15
    var size: Int { GameBoard.size }
    
    @Published private(set) var board: [[Player]]
    @Published private(set) var currentPlayer: Player = .black
    @Published private(set) var winner: Player?
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var winningLine: [(Int, Int)] = []
    
    init() {
        self.board = Array(repeating: Array(repeating: .none, count: GameBoard.size), count: GameBoard.size)
    }
    
    func reset() {
        board = Array(repeating: Array(repeating: .none, count: GameBoard.size), count: GameBoard.size)
        currentPlayer = .black
        winner = nil
        isGameOver = false
        winningLine = []
    }
    
    func makeMove(row: Int, col: Int) -> Bool {
        do {
            try validateMove(row: row, col: col)
            board[row][col] = currentPlayer
            
            if checkWin(row: row, col: col) {
                winner = currentPlayer
                isGameOver = true
            } else if isBoardFull() {
                isGameOver = true
            } else {
                currentPlayer = currentPlayer == .black ? .white : .black
            }
            
            return true
        } catch {
            print("Move failed: \(error)")
            return false
        }
    }
    
    private func validateMove(row: Int, col: Int) throws {
        guard row >= 0, row < GameBoard.size,
              col >= 0, col < GameBoard.size else {
            throw GameError.invalidMove
        }
        
        guard board[row][col] == .none else {
            throw GameError.invalidMove
        }
        
        guard !isGameOver else {
            throw GameError.gameAlreadyOver
        }
    }
    
    private func isBoardFull() -> Bool {
        for row in board {
            for cell in row {
                if cell == .none {
                    return false
                }
            }
        }
        return true
    }
    
    private func checkWin(row: Int, col: Int) -> Bool {
        let player = board[row][col]
        
        let directions = [
            (0, 1),   // horizontal
            (1, 0),   // vertical
            (1, 1),   // diagonal \
            (1, -1)   // diagonal /
        ]
        
        for (dx, dy) in directions {
            var count = 1
            var line = [(row, col)]
            
            // Check positive direction
            var r = row + dx
            var c = col + dy
            while r >= 0 && r < GameBoard.size && c >= 0 && c < GameBoard.size && board[r][c] == player {
                count += 1
                line.append((r, c))
                r += dx
                c += dy
            }
            
            // Check negative direction
            r = row - dx
            c = col - dy
            while r >= 0 && r < GameBoard.size && c >= 0 && c < GameBoard.size && board[r][c] == player {
                count += 1
                line.insert((r, c), at: 0)
                r -= dx
                c -= dy
            }
            
            if count >= 5 {
                winningLine = line
                return true
            }
        }
        
        return false
    }
}