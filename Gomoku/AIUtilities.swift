import Foundation

// MARK: - Constants
enum AIConstants {
    enum Score {
        static let win = 100000
        static let fourInRow = 10000
        static let threeInRow = 1000
        static let twoInRow = 100
        static let oneInRow = 10
        static let openEndBonus = 5
        static let centerBonus = 10
    }
    
    enum Algorithm {
        static let maxDepth = 4
        static let searchRadius = 2
    }
    
    enum Evaluation {
        static let opponentMultiplier = 2
        static let defenseMultiplier = 3
        static let centerControlRadius = 2
        static let centerControlMaxBonus = 10
        static let centerControlDistancePenalty = 2
    }
    
    enum Time {
        static let aiThinkingDelay: UInt64 = 300_000_000 // 300ms in nanoseconds
    }
}

// MARK: - Move
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

// MARK: - Pattern Analyzer
struct PatternAnalyzer {
    static func analyzePattern(
        board: [[Player]],
        row: Int,
        col: Int,
        dx: Int,
        dy: Int,
        player: Player,
        size: Int
    ) -> (count: Int, openEnds: Int) {
        var count = 1
        var openEnds = 0
        
        // Check forward direction
        var r = row + dx
        var c = col + dy
        while r >= 0 && r < size && c >= 0 && c < size && board[r][c] == player {
            count += 1
            r += dx
            c += dy
        }
        if r >= 0 && r < size && c >= 0 && c < size && board[r][c] == .none {
            openEnds += 1
        }
        
        // Check backward direction
        r = row - dx
        c = col - dy
        while r >= 0 && r < size && c >= 0 && c < size && board[r][c] == player {
            count += 1
            r -= dx
            c -= dy
        }
        if r >= 0 && r < size && c >= 0 && c < size && board[r][c] == .none {
            openEnds += 1
        }
        
        return (count, openEnds)
    }
    
    static func evaluatePattern(count: Int, openEnds: Int) -> Int {
        switch (count, openEnds) {
        case (5..., _):
            return AIConstants.Score.win
        case (4, 2):
            return AIConstants.Score.fourInRow
        case (4, 1):
            return AIConstants.Score.fourInRow / 2
        case (3, 2):
            return AIConstants.Score.threeInRow
        case (3, 1):
            return AIConstants.Score.threeInRow / 4
        case (2, 2):
            return AIConstants.Score.twoInRow
        case (2, 1):
            return AIConstants.Score.twoInRow / 4
        case (1, 2):
            return AIConstants.Score.openEndBonus
        default:
            return 0
        }
    }
    
    static func countInDirection(
        board: [[Player]],
        row: Int,
        col: Int,
        dx: Int,
        dy: Int,
        player: Player,
        size: Int
    ) -> Int {
        var count = 1
        
        // Check forward direction
        var r = row + dx
        var c = col + dy
        while r >= 0 && r < size && c >= 0 && c < size && board[r][c] == player {
            count += 1
            r += dx
            c += dy
        }
        
        // Check backward direction
        r = row - dx
        c = col - dy
        while r >= 0 && r < size && c >= 0 && c < size && board[r][c] == player {
            count += 1
            r -= dx
            c -= dy
        }
        
        return count
    }
}

// MARK: - Board Evaluator
struct BoardEvaluator {
    static func evaluateBoard(board: [[Player]], for player: Player, size: Int) -> Int {
        var score = 0
        let opponent = player == .black ? Player.white : Player.black
        
        // Evaluate all positions
        for row in 0..<size {
            for col in 0..<size {
                if board[row][col] != .none {
                    let cellPlayer = board[row][col]
                    let cellScore = evaluatePositionOnBoard(
                        board: board,
                        row: row,
                        col: col,
                        player: cellPlayer,
                        size: size
                    )
                    
                    if cellPlayer == player {
                        score += cellScore
                    } else {
                        score -= cellScore * AIConstants.Evaluation.opponentMultiplier
                    }
                }
            }
        }
        
        // Add center control bonus
        score += evaluateCenterControl(board: board, for: player, size: size)
        
        return score
    }
    
    static func evaluatePositionOnBoard(
        board: [[Player]],
        row: Int,
        col: Int,
        player: Player,
        size: Int
    ) -> Int {
        var totalScore = 0
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        
        for (dx, dy) in directions {
            let (count, openEnds) = PatternAnalyzer.analyzePattern(
                board: board,
                row: row,
                col: col,
                dx: dx,
                dy: dy,
                player: player,
                size: size
            )
            
            totalScore += PatternAnalyzer.evaluatePattern(count: count, openEnds: openEnds)
        }
        
        return totalScore
    }
    
    static func evaluateCenterControl(board: [[Player]], for player: Player, size: Int) -> Int {
        var score = 0
        let center = size / 2
        let radius = AIConstants.Evaluation.centerControlRadius
        
        for row in (center - radius)...(center + radius) {
            for col in (center - radius)...(center + radius) {
                if row >= 0 && row < size && col >= 0 && col < size {
                    if board[row][col] == player {
                        let distance = abs(row - center) + abs(col - center)
                        let bonus = AIConstants.Evaluation.centerControlMaxBonus
                        let penalty = AIConstants.Evaluation.centerControlDistancePenalty
                        score += bonus - distance * penalty
                    }
                }
            }
        }
        
        return score
    }
    
    static func evaluatePosition(row: Int, col: Int, boardData: GameBoardDataSource) -> Int {
        var score = 0
        
        let currentPlayer = boardData.currentPlayer
        let opponent = currentPlayer == .black ? Player.white : Player.black
        
        // Evaluate for both players
        score += evaluatePlayerPosition(row: row, col: col, player: currentPlayer, boardData: boardData) * AIConstants.Evaluation.opponentMultiplier
        score += evaluatePlayerPosition(row: row, col: col, player: opponent, boardData: boardData) * AIConstants.Evaluation.defenseMultiplier
        
        // Center position bonus
        if row == boardData.size / 2 && col == boardData.size / 2 {
            score += AIConstants.Score.centerBonus
        }
        
        return score
    }
    
    private static func evaluatePlayerPosition(
        row: Int,
        col: Int,
        player: Player,
        boardData: GameBoardDataSource
    ) -> Int {
        var score = 0
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        
        for (dx, dy) in directions {
            let lineScore = evaluateLine(
                row: row,
                col: col,
                dx: dx,
                dy: dy,
                player: player,
                boardData: boardData
            )
            score += lineScore
        }
        
        return score
    }
    
    private static func evaluateLine(
        row: Int,
        col: Int,
        dx: Int,
        dy: Int,
        player: Player,
        boardData: GameBoardDataSource
    ) -> Int {
        var count = 0
        var openEnds = 0
        
        // Check forward direction
        var r = row + dx
        var c = col + dy
        while r >= 0 && r < boardData.size && c >= 0 && c < boardData.size && boardData.board[r][c] == player {
            count += 1
            r += dx
            c += dy
        }
        if r >= 0 && r < boardData.size && c >= 0 && c < boardData.size && boardData.board[r][c] == .none {
            openEnds += 1
        }
        
        // Check backward direction
        r = row - dx
        c = col - dy
        while r >= 0 && r < boardData.size && c >= 0 && c < boardData.size && boardData.board[r][c] == player {
            count += 1
            r -= dx
            c -= dy
        }
        if r >= 0 && r < boardData.size && c >= 0 && c < boardData.size && boardData.board[r][c] == .none {
            openEnds += 1
        }
        
        return PatternAnalyzer.evaluatePattern(count: count, openEnds: openEnds)
    }
}

// MARK: - Game State Checker
struct GameStateChecker {
    static func isGameOver(board: [[Player]], size: Int) -> Bool {
        // Check for winner
        for row in 0..<size {
            for col in 0..<size {
                if board[row][col] != .none {
                    if checkWin(board: board, row: row, col: col, player: board[row][col], size: size) {
                        return true
                    }
                }
            }
        }
        
        // Check for draw (board full)
        return isBoardFull(board: board, size: size)
    }
    
    static func isBoardFull(board: [[Player]], size: Int) -> Bool {
        for row in 0..<size {
            for col in 0..<size {
                if board[row][col] == .none {
                    return false
                }
            }
        }
        return true
    }
    
    static func checkWin(board: [[Player]], row: Int, col: Int, player: Player, size: Int) -> Bool {
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        
        for (dx, dy) in directions {
            let count = PatternAnalyzer.countInDirection(
                board: board,
                row: row,
                col: col,
                dx: dx,
                dy: dy,
                player: player,
                size: size
            )
            if count >= 5 {
                return true
            }
        }
        
        return false
    }
}