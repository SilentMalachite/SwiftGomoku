import Foundation

struct GameBoard: GameBoardDataSource {
    private(set) var board: [[Player]]
    let size: Int
    var currentPlayer: Player
    
    init(size: Int = 15) {
        self.size = size
        self.board = Array(repeating: Array(repeating: .none, count: size), count: size)
        self.currentPlayer = .black
    }
    
    mutating func reset() {
        board = Array(repeating: Array(repeating: .none, count: size), count: size)
        currentPlayer = .black
    }
    
    mutating func placeStone(at row: Int, col: Int, player: Player) -> Result<Void, GameError> {
        guard row >= 0, row < size,
              col >= 0, col < size else {
            return .failure(.outOfBounds(row: row, col: col))
        }
        
        guard board[row][col] == .none else {
            return .failure(.positionOccupied(row: row, col: col))
        }
        
        board[row][col] = player
        return .success(())
    }
    
    mutating func switchPlayer() {
        currentPlayer = currentPlayer == .black ? .white : .black
    }
    
    func isValidMove(row: Int, col: Int) -> Bool {
        return row >= 0 && row < size &&
               col >= 0 && col < size &&
               board[row][col] == .none
    }
    
    func isBoardFull() -> Bool {
        return board.allSatisfy { row in
            row.allSatisfy { $0 != .none }
        }
    }
    
    func checkForWinner() -> (winner: Player?, winningLine: [(Int, Int)]) {
        // Check all positions for winning patterns
        for row in 0..<size {
            for col in 0..<size {
                let player = board[row][col]
                if player != .none {
                    if let line = checkWinFromPosition(row: row, col: col, player: player) {
                        return (player, line)
                    }
                }
            }
        }
        return (nil, [])
    }
    
    private func checkWinFromPosition(row: Int, col: Int, player: Player) -> [(Int, Int)]? {
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        
        for (dx, dy) in directions {
            var positions = [(row, col)]
            
            var r = row + dx
            var c = col + dy
            while r >= 0 && r < size && c >= 0 && c < size && board[r][c] == player {
                positions.append((r, c))
                r += dx
                c += dy
            }
            
            r = row - dx
            c = col - dy
            while r >= 0 && r < size && c >= 0 && c < size && board[r][c] == player {
                positions.append((r, c))
                r -= dx
                c -= dy
            }
            
            if positions.count >= 5 {
                return positions
            }
        }
        
        return nil
    }
}