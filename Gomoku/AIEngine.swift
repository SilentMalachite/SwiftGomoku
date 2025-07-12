import Foundation

protocol GameBoardDataSource {
    var board: [[Player]] { get }
    var currentPlayer: Player { get }
    var size: Int { get }
}

class AIEngine {
    init() {}
    
    func getBestMove(for boardData: GameBoardDataSource) -> (Int, Int)? {
        do {
            try validateBoardState(boardData: boardData)
            
            guard let move = calculateBestMove(boardData: boardData) else {
                return getFallbackMove(for: boardData)
            }
            return move
        } catch {
            print("AI Error: \(error)")
            return getFallbackMove(for: boardData)
        }
    }
    
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
    
    private func calculateBestMove(boardData: GameBoardDataSource) -> (Int, Int)? {
        var bestMove: (Int, Int)?
        var bestScore = Int.min
        let alpha = Int.min
        let beta = Int.max
        
        let board = boardData.board
        let relevantMoves = getRelevantMoves(board: board, size: boardData.size)
        
        if relevantMoves.isEmpty {
            return (boardData.size / 2, boardData.size / 2)
        }
        
        for (row, col) in relevantMoves {
            var newBoard = board
            newBoard[row][col] = boardData.currentPlayer
            
            let score = minimax(
                board: newBoard,
                depth: AIConstants.Algorithm.maxDepth - 1,
                isMaximizing: false,
                alpha: alpha,
                beta: beta,
                player: boardData.currentPlayer,
                size: boardData.size
            )
            
            if score > bestScore {
                bestScore = score
                bestMove = (row, col)
            }
        }
        
        return bestMove
    }
    
    private func getFallbackMove(for boardData: GameBoardDataSource) -> (Int, Int)? {
        var bestScore = Int.min
        var bestMove: (Int, Int)?
        
        for row in 0..<boardData.size {
            for col in 0..<boardData.size {
                if boardData.board[row][col] == .none {
                    let score = BoardEvaluator.evaluatePosition(row: row, col: col, boardData: boardData)
                    if score > bestScore {
                        bestScore = score
                        bestMove = (row, col)
                    }
                }
            }
        }
        
        return bestMove
    }
    
    private func minimax(board: [[Player]], depth: Int, isMaximizing: Bool, alpha: Int, beta: Int, player: Player, size: Int) -> Int {
        if depth == 0 || GameStateChecker.isGameOver(board: board, size: size) {
            return BoardEvaluator.evaluateBoard(board: board, for: player, size: size)
        }
        
        var currentAlpha = alpha
        var currentBeta = beta
        
        if isMaximizing {
            var maxScore = Int.min
            let moves = getRelevantMoves(board: board, size: size)
            
            for (row, col) in moves {
                var newBoard = board
                newBoard[row][col] = player
                
                let score = minimax(
                    board: newBoard,
                    depth: depth - 1,
                    isMaximizing: false,
                    alpha: currentAlpha,
                    beta: currentBeta,
                    player: player,
                    size: size
                )
                
                maxScore = max(maxScore, score)
                currentAlpha = max(currentAlpha, maxScore)
                
                if currentBeta <= currentAlpha {
                    return maxScore
                }
            }
            
            return maxScore
        } else {
            var minScore = Int.max
            let opponent = player == .black ? Player.white : Player.black
            let moves = getRelevantMoves(board: board, size: size)
            
            for (row, col) in moves {
                var newBoard = board
                newBoard[row][col] = opponent
                
                let score = minimax(
                    board: newBoard,
                    depth: depth - 1,
                    isMaximizing: true,
                    alpha: currentAlpha,
                    beta: currentBeta,
                    player: player,
                    size: size
                )
                
                minScore = min(minScore, score)
                currentBeta = min(currentBeta, minScore)
                
                if currentBeta <= currentAlpha {
                    return minScore
                }
            }
            
            return minScore
        }
    }
    
    private func getRelevantMoves(board: [[Player]], size: Int) -> [(Int, Int)] {
        var relevantMoves: Set<Move> = []
        var hasPieces = false
        
        for row in 0..<size {
            for col in 0..<size {
                if board[row][col] != .none {
                    hasPieces = true
                    
                    for dr in -AIConstants.Algorithm.searchRadius...AIConstants.Algorithm.searchRadius {
                        for dc in -AIConstants.Algorithm.searchRadius...AIConstants.Algorithm.searchRadius {
                            let newRow = row + dr
                            let newCol = col + dc
                            
                            if newRow >= 0 && newRow < size && 
                               newCol >= 0 && newCol < size && 
                               board[newRow][newCol] == .none {
                                relevantMoves.insert(Move(newRow, newCol))
                            }
                        }
                    }
                }
            }
        }
        
        if !hasPieces {
            return [(size / 2, size / 2)]
        }
        
        return relevantMoves
            .sorted { $0.distanceToCenter(boardSize: size) < $1.distanceToCenter(boardSize: size) }
            .map { ($0.row, $0.col) }
    }
}