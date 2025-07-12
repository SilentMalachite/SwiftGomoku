import SwiftUI
import Combine

@MainActor
class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var board: [[Player]]
    @Published private(set) var currentPlayer: Player = .black
    @Published private(set) var winner: Player?
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var winningLine: [(Int, Int)] = []
    @Published var isAIEnabled: Bool = false
    @Published private(set) var isAIThinking: Bool = false
    
    // MARK: - Properties
    private let boardSize: Int
    private let aiEngine: AIEngine
    
    // MARK: - Initialization
    init(boardSize: Int = 15) {
        self.boardSize = boardSize
        self.board = Array(repeating: Array(repeating: .none, count: boardSize), count: boardSize)
        self.aiEngine = AIEngine()
    }
    
    // MARK: - Computed Properties
    var boardDataSource: GameBoardDataSource {
        BoardDataSource(board: board, currentPlayer: currentPlayer, size: boardSize)
    }
    
    var alertTitle: String {
        if winner != nil {
            return "Game Over"
        } else if isGameOver {
            return "Game Over"
        } else {
            return "Invalid Move"
        }
    }
    
    var alertMessage: String {
        if let winner = winner {
            return "\(winner.rawValue) wins!"
        } else if isGameOver {
            return "It's a draw!"
        } else {
            return "This position is not available."
        }
    }
    
    var shouldShowAlert: Bool {
        return winner != nil || isGameOver
    }
    
    var canToggleAI: Bool {
        return board.flatMap { $0 }.allSatisfy { $0 == .none }
    }
    
    // MARK: - Public Methods
    func makeMove(row: Int, col: Int) -> Bool {
        guard !isGameOver, 
              row >= 0, row < boardSize,
              col >= 0, col < boardSize,
              board[row][col] == .none else {
            return false
        }
        
        board[row][col] = currentPlayer
        
        if let winner = checkForWinner() {
            self.winner = winner
            self.isGameOver = true
            return true
        }
        
        if isBoardFull() {
            self.isGameOver = true
            return true
        }
        
        currentPlayer = currentPlayer == .black ? .white : .black
        
        if isAIEnabled && currentPlayer == .white && !isGameOver {
            Task {
                await makeAIMove()
            }
        }
        
        return true
    }
    
    func reset() {
        board = Array(repeating: Array(repeating: .none, count: boardSize), count: boardSize)
        currentPlayer = .black
        winner = nil
        isGameOver = false
        winningLine = []
        isAIThinking = false
    }
    
    func makeAIMove() async {
        guard isAIEnabled && currentPlayer == .white && !isGameOver else { return }
        
        isAIThinking = true
        
        // Add slight delay for better UX
        try? await Task.sleep(nanoseconds: AIConstants.Time.aiThinkingDelay)
        
        let boardData = boardDataSource
        let move = await Task.detached(priority: .userInitiated) {
            return self.aiEngine.getBestMove(for: boardData)
        }.value
        
        if let (row, col) = move {
            _ = makeMove(row: row, col: col)
        }
        
        isAIThinking = false
    }
    
    // MARK: - Private Methods
    private func checkForWinner() -> Player? {
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                if board[row][col] != .none {
                    if let line = checkWinFromPosition(row: row, col: col, player: board[row][col]) {
                        winningLine = line
                        return board[row][col]
                    }
                }
            }
        }
        return nil
    }
    
    private func checkWinFromPosition(row: Int, col: Int, player: Player) -> [(Int, Int)]? {
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        
        for (dx, dy) in directions {
            var positions = [(row, col)]
            
            // Check forward direction
            var r = row + dx
            var c = col + dy
            while r >= 0 && r < boardSize && c >= 0 && c < boardSize && board[r][c] == player {
                positions.append((r, c))
                r += dx
                c += dy
            }
            
            // Check backward direction
            r = row - dx
            c = col - dy
            while r >= 0 && r < boardSize && c >= 0 && c < boardSize && board[r][c] == player {
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
    
    private func isBoardFull() -> Bool {
        return board.allSatisfy { row in
            row.allSatisfy { $0 != .none }
        }
    }
}

// MARK: - BoardDataSource
private struct BoardDataSource: GameBoardDataSource {
    let board: [[Player]]
    let currentPlayer: Player
    let size: Int
}