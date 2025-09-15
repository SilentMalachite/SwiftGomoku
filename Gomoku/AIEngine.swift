import Foundation

// MARK: - AIEngine
/// Main AI engine responsible for move calculation using minimax algorithm
class AIEngine {
    
    // MARK: - Algorithm Constants
    private enum Algorithm {
        static let maxDepth = 4
        static let searchRadius = 2
        static let thinkingDelay: UInt64 = 300_000_000 // 300ms
    }
    
    // MARK: - Properties
    private let evaluator = AIEvaluator()
    
    // MARK: - Helper Functions
    private func movePriority(_ move: (Int, Int), size: Int) -> Int {
        let (row, col) = move
        let center = size / 2
        return -(abs(row - center) + abs(col - center)) // Negative for descending sort
    }
    
    // MARK: - Public Interface
    init() {}
    
    /// Gets the best move for the current board state
    func getBestMove(for boardData: GameBoardDataSource, progressHandler: ((String, Int, Int) -> Void)? = nil) -> (Int, Int)? {
        do {
            try validateBoardState(boardData: boardData)
            
            guard let move = calculateBestMove(boardData: boardData, progressHandler: progressHandler) else {
                return getFallbackMove(for: boardData)
            }
            return move
        } catch {
            print("AI Error: \(error)")
            return getFallbackMove(for: boardData)
        }
    }
    
    // MARK: - Board Validation
    private func validateBoardState(boardData: GameBoardDataSource) throws {
        let board = boardData.board
        var blackCount = 0
        var whiteCount = 0
        
        for row in board {
            for cell in row {
                switch cell {
                case .black: blackCount += 1
                case .white: whiteCount += 1
                case .none: break
                }
            }
        }
        
        let difference = abs(blackCount - whiteCount)
        guard difference <= 1 else {
            throw GameError.invalidBoardState
        }
    }
    
    // MARK: - Move Calculation
    private func calculateBestMove(boardData: GameBoardDataSource, progressHandler: ((String, Int, Int) -> Void)? = nil) -> (Int, Int)? {
        var bestMove: (Int, Int)?
        var bestScore = Int.min
        var alpha = Int.min
        let beta = Int.max
        var movesEvaluated = 0
        
        let board = boardData.board
        let relevantMoves = getRelevantMoves(board: board, size: boardData.size)
        
        // If board is empty, play in the center
        if relevantMoves.isEmpty {
            return (boardData.size / 2, boardData.size / 2)
        }
        
        progressHandler?(String(format: NSLocalizedString("Found %d candidate moves", comment: "AI progress"), relevantMoves.count), 0, 0)
        
        // Sort moves by priority for better performance
        let sortedMoves = relevantMoves.sorted { movePriority($0, size: boardData.size) > movePriority($1, size: boardData.size) }
        
        // Evaluate each possible move
        for (index, (row, col)) in sortedMoves.enumerated() {
            if Task.isCancelled { return bestMove }
            var newBoard = board
            newBoard[row][col] = boardData.currentPlayer
            
            progressHandler?(String(format: NSLocalizedString("Evaluating move %d/%d", comment: "AI progress"), index + 1, relevantMoves.count), movesEvaluated, 1)
            
            let score = minimax(
                board: newBoard,
                depth: Algorithm.maxDepth - 1,
                isMaximizing: false,
                alpha: alpha,
                beta: beta,
                player: boardData.currentPlayer,
                size: boardData.size,
                currentDepth: 1,
                progressHandler: progressHandler,
                movesEvaluated: &movesEvaluated
            )
            
            if score > bestScore {
                bestScore = score
                bestMove = (row, col)
                progressHandler?(String(format: NSLocalizedString("Found better move at (%d, %d)", comment: "AI progress"), row, col), movesEvaluated, Algorithm.maxDepth)
                alpha = max(alpha, bestScore)
            }
        }
        
        progressHandler?(NSLocalizedString("Analysis complete", comment: "AI progress"), movesEvaluated, Algorithm.maxDepth)
        return bestMove
    }
    
    // MARK: - Fallback Strategy
    private func getFallbackMove(for boardData: GameBoardDataSource) -> (Int, Int)? {
        var bestScore = Int.min
        var bestMove: (Int, Int)?
        
        // Prefer center positions in fallback
        let center = boardData.size / 2
        let searchOrder = generateSearchOrder(center: center, size: boardData.size)
        
        for (row, col) in searchOrder {
            if boardData.board[row][col] == .none {
                let score = evaluator.evaluatePosition(
                    row: row,
                    col: col,
                    boardData: boardData
                )
                if score > bestScore {
                    bestScore = score
                    bestMove = (row, col)
                }
            }
        }
        
        return bestMove ?? (center, center) // Ultimate fallback to center
    }
    
    private func generateSearchOrder(center: Int, size: Int) -> [(Int, Int)] {
        var positions: [(Int, Int)] = []
        for row in 0..<size {
            for col in 0..<size {
                positions.append((row, col))
            }
        }
        return positions.sorted { pos1, pos2 in
            let dist1 = abs(pos1.0 - center) + abs(pos1.1 - center)
            let dist2 = abs(pos2.0 - center) + abs(pos2.1 - center)
            return dist1 < dist2
        }
    }
    
    // MARK: - Minimax Algorithm
    private func minimax(
        board: [[Player]],
        depth: Int,
        isMaximizing: Bool,
        alpha: Int,
        beta: Int,
        player: Player,
        size: Int,
        currentDepth: Int = 0,
        progressHandler: ((String, Int, Int) -> Void)? = nil,
        movesEvaluated: inout Int
    ) -> Int {
        // Terminal state check
        if depth == 0 || evaluator.isGameOver(board: board, size: size) {
            movesEvaluated += 1
            return evaluator.evaluateBoard(board: board, for: player, size: size)
        }
        
        var currentAlpha = alpha
        var currentBeta = beta
        
        if isMaximizing {
            return maximizingMove(
                board: board,
                depth: depth,
                alpha: &currentAlpha,
                beta: currentBeta,
                player: player,
                size: size,
                currentDepth: currentDepth,
                progressHandler: progressHandler,
                movesEvaluated: &movesEvaluated
            )
        } else {
            return minimizingMove(
                board: board,
                depth: depth,
                alpha: currentAlpha,
                beta: &currentBeta,
                player: player,
                size: size,
                currentDepth: currentDepth,
                progressHandler: progressHandler,
                movesEvaluated: &movesEvaluated
            )
        }
    }
    
    private func maximizingMove(
        board: [[Player]],
        depth: Int,
        alpha: inout Int,
        beta: Int,
        player: Player,
        size: Int,
        currentDepth: Int,
        progressHandler: ((String, Int, Int) -> Void)?,
        movesEvaluated: inout Int
    ) -> Int {
        var maxScore = Int.min
        let moves = getRelevantMoves(board: board, size: size, ordered: true)
        
        for (row, col) in moves {
            if Task.isCancelled { return maxScore }
            var newBoard = board
            newBoard[row][col] = player
            
            let score = minimax(
                board: newBoard,
                depth: depth - 1,
                isMaximizing: false,
                alpha: alpha,
                beta: beta,
                player: player,
                size: size,
                currentDepth: currentDepth + 1,
                progressHandler: progressHandler,
                movesEvaluated: &movesEvaluated
            )
            
            maxScore = max(maxScore, score)
            alpha = max(alpha, maxScore)
            progressHandler?(String(format: NSLocalizedString("Searching depth %d", comment: "AI progress"), currentDepth), movesEvaluated, currentDepth)
            
            // Alpha-beta pruning
            if beta <= alpha {
                return maxScore
            }
        }
        
        return maxScore
    }
    
    private func minimizingMove(
        board: [[Player]],
        depth: Int,
        alpha: Int,
        beta: inout Int,
        player: Player,
        size: Int,
        currentDepth: Int,
        progressHandler: ((String, Int, Int) -> Void)?,
        movesEvaluated: inout Int
    ) -> Int {
        var minScore = Int.max
        let opponent = player == .black ? Player.white : Player.black
        let moves = getRelevantMoves(board: board, size: size, ordered: true)
        
        for (row, col) in moves {
            if Task.isCancelled { return minScore }
            var newBoard = board
            newBoard[row][col] = opponent
            
            let score = minimax(
                board: newBoard,
                depth: depth - 1,
                isMaximizing: true,
                alpha: alpha,
                beta: beta,
                player: player,
                size: size,
                currentDepth: currentDepth + 1,
                progressHandler: progressHandler,
                movesEvaluated: &movesEvaluated
            )
            
            minScore = min(minScore, score)
            beta = min(beta, minScore)
            progressHandler?(String(format: NSLocalizedString("Searching depth %d", comment: "AI progress"), currentDepth), movesEvaluated, currentDepth)
            
            // Alpha-beta pruning
            if beta <= alpha {
                return minScore
            }
        }
        
        return minScore
    }
    
    // MARK: - Move Generation
    private func getRelevantMoves(board: [[Player]], size: Int, ordered: Bool = false) -> [(Int, Int)] {
        var relevantMoves: Set<Move> = []
        var hasPieces = false
        
        // Find all empty positions near existing pieces
        for row in 0..<size {
            for col in 0..<size {
                if board[row][col] != .none {
                    hasPieces = true
                    addAdjacentMoves(
                        board: board,
                        centerRow: row,
                        centerCol: col,
                        size: size,
                        moves: &relevantMoves
                    )
                }
            }
        }
        
        // If board is empty, return center position
        if !hasPieces {
            return [(size / 2, size / 2)]
        }
        
        // Sort moves by distance to center for better ordering
        let moves = relevantMoves.map { ($0.row, $0.col) }
        return ordered ? moves.sorted { movePriority($0, size: size) > movePriority($1, size: size) } : moves
    }
    
    private func addAdjacentMoves(
        board: [[Player]],
        centerRow: Int,
        centerCol: Int,
        size: Int,
        moves: inout Set<Move>
    ) {
        for dr in -Algorithm.searchRadius...Algorithm.searchRadius {
            for dc in -Algorithm.searchRadius...Algorithm.searchRadius {
                let newRow = centerRow + dr
                let newCol = centerCol + dc
                
                if newRow >= 0 && newRow < size &&
                   newCol >= 0 && newCol < size &&
                   board[newRow][newCol] == .none {
                    moves.insert(Move(newRow, newCol))
                }
            }
        }
    }
}

// MARK: - Move Helper
struct Move: Hashable, Equatable {
    let row: Int
    let col: Int
    
    init(_ row: Int, _ col: Int) {
        self.row = row
        self.col = col
    }
    
    func distanceToCenter(boardSize: Int) -> Int {
        let center = boardSize / 2
        return abs(row - center) + abs(col - center)
    }
}

// GameBoardDataSource is defined in Domain.swift
