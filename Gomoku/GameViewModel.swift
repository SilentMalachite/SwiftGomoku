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
            return NSLocalizedString("Game Over", comment: "")
        } else if isGameOver {
            return NSLocalizedString("Game Over", comment: "")
        } else {
            return NSLocalizedString("Invalid Move", comment: "")
        }
    }
    
    var alertMessage: String {
        if let winner = winner {
            return "\(winner.rawValue) wins!"
        } else if isGameOver {
            return NSLocalizedString("It's a draw!", comment: "")
        } else {
            return NSLocalizedString("This position is not available.", comment: "")
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

        // Snapshot state on main actor
        let boardSnapshot = gameBoard.board
        let current = gameBoard.currentPlayer
        let size = gameBoard.size
        let engine = aiEngine

        // Create new cancellable task (parent)
        aiTask = Task { @MainActor in
            isAIThinking = true
            aiThinkingProgress = NSLocalizedString("Analyzing board...", comment: "")
            aiEvaluatedMoves = 0
            aiSearchDepth = 0

            // Add slight delay for better UX and allow cancellation
            do { try await Task.sleep(nanoseconds: 100_000_000) } catch { }

            // Progress handler updates on main actor
            let progressHandler: (String, Int, Int) -> Void = { [weak self] message, moves, depth in
                Task { @MainActor in
                    self?.aiThinkingProgress = message
                    self?.aiEvaluatedMoves = moves
                    self?.aiSearchDepth = depth
                }
            }

            // Child task via task group to propagate cancellation
            var chosenMove: (Int, Int)? = nil
            await withTaskCancellationHandler {
                await withTaskGroup(of: (Int, Int)?.self) { group in
                    group.addTask(priority: .userInitiated) {
                        let ds = BoardSnapshot(board: boardSnapshot, currentPlayer: current, size: size)
                        return engine.getBestMove(for: ds, progressHandler: progressHandler)
                    }
                    chosenMove = await group.next() ?? nil
                }
            } onCancel: {
                // nothing specific, UI cleanup happens below
            }

            if let (row, col) = chosenMove, !isGameOver {
                aiThinkingProgress = NSLocalizedString("Making move...", comment: "")
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

// MARK: - Private Helpers
private struct BoardSnapshot: GameBoardDataSource {
    let board: [[Player]]
    let currentPlayer: Player
    let size: Int
}
