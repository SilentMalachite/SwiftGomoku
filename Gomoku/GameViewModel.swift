import SwiftUI
import Combine

@MainActor
class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var gameBoard: GameBoard
    @Published private(set) var winner: Player?
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var winningLine: [(Int, Int)] = []
    @Published var isAIEnabled: Bool = false
    @Published private(set) var isAIThinking: Bool = false
    @Published var lastError: GameError?
    @Published private(set) var aiThinkingProgress: String = ""
    @Published private(set) var aiEvaluatedMoves: Int = 0
    @Published private(set) var aiSearchDepth: Int = 0
    
    // MARK: - Properties
    private let aiEngine: AIEngine
    private var aiTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(boardSize: Int = 15) {
        self.gameBoard = GameBoard(size: boardSize)
        self.aiEngine = AIEngine()
    }
    
    // MARK: - Computed Properties
    var board: [[Player]] {
        gameBoard.board
    }
    
    var currentPlayer: Player {
        gameBoard.currentPlayer
    }
    
    var boardSize: Int {
        gameBoard.size
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
        return gameBoard.board.flatMap { $0 }.allSatisfy { $0 == .none }
    }
    
    // MARK: - Public Methods
    func makeMove(row: Int, col: Int) -> Result<Void, GameError> {
        lastError = nil
        
        guard !isGameOver else {
            let error = GameError.gameAlreadyOver
            lastError = error
            return .failure(error)
        }
        
        guard row >= 0 && row < boardSize && col >= 0 && col < boardSize else {
            let error = GameError.outOfBounds(row: row, col: col)
            lastError = error
            return .failure(error)
        }
        
        guard gameBoard.isValidMove(row: row, col: col) else {
            let error = GameError.positionOccupied(row: row, col: col)
            lastError = error
            return .failure(error)
        }
        
        let placeResult = gameBoard.placeStone(at: row, col: col, player: gameBoard.currentPlayer)
        switch placeResult {
        case .failure(let error):
            lastError = error
            return .failure(error)
        case .success:
            break
        }
        
        let (winner, line) = gameBoard.checkForWinner()
        if let winner = winner {
            self.winner = winner
            self.winningLine = line
            self.isGameOver = true
            return .success(())
        }
        
        if gameBoard.isBoardFull() {
            self.isGameOver = true
            return .success(())
        }
        
        gameBoard.switchPlayer()
        
        if isAIEnabled && gameBoard.currentPlayer == .white && !isGameOver {
            Task {
                await makeAIMove()
            }
        }
        
        return .success(())
    }
    
    func reset() {
        // Cancel any ongoing AI task
        aiTask?.cancel()
        aiTask = nil
        
        gameBoard.reset()
        winner = nil
        isGameOver = false
        winningLine = []
        isAIThinking = false
        lastError = nil
        aiThinkingProgress = ""
        aiEvaluatedMoves = 0
        aiSearchDepth = 0
    }
    
    func makeAIMove() async {
        guard isAIEnabled && gameBoard.currentPlayer == .white && !isGameOver else { return }
        
        // Cancel any existing AI task
        aiTask?.cancel()
        
        // Create new cancellable task
        aiTask = Task { @MainActor in
            isAIThinking = true
            aiThinkingProgress = "Analyzing board..."
            aiEvaluatedMoves = 0
            aiSearchDepth = 0
            
            // Check for cancellation
            guard !Task.isCancelled else {
                isAIThinking = false
                return
            }
            
            // Add slight delay for better UX
            do {
                try await Task.sleep(nanoseconds: 100_000_000) // 100ms
            } catch {
                // Task was cancelled
                isAIThinking = false
                return
            }
            
            // Create progress handler
            let progressHandler: (String, Int, Int) -> Void = { [weak self] message, moves, depth in
                guard !Task.isCancelled else { return }
                Task { @MainActor in
                    self?.aiThinkingProgress = message
                    self?.aiEvaluatedMoves = moves
                    self?.aiSearchDepth = depth
                }
            }
            
            // Perform AI calculation in background
            let move = await withTaskCancellationHandler {
                await Task.detached(priority: .userInitiated) { [weak self] in
                    guard let self = self else { return nil }
                    guard !Task.isCancelled else { return nil }
                    return self.aiEngine.getBestMove(for: self.gameBoard, progressHandler: progressHandler)
                }.value
            } onCancel: {
                // Handle cancellation
            }
            
            // Check for cancellation before making the move
            guard !Task.isCancelled else {
                isAIThinking = false
                aiThinkingProgress = ""
                aiEvaluatedMoves = 0
                aiSearchDepth = 0
                return
            }
            
            if let (row, col) = move {
                aiThinkingProgress = "Making move..."
                _ = makeMove(row: row, col: col)
            }
            
            isAIThinking = false
            aiThinkingProgress = ""
            aiEvaluatedMoves = 0
            aiSearchDepth = 0
        }
        
        await aiTask?.value
    }
    
    func cancelAIMove() {
        aiTask?.cancel()
        aiTask = nil
        isAIThinking = false
        aiThinkingProgress = ""
        aiEvaluatedMoves = 0
        aiSearchDepth = 0
    }
}