import Foundation

// MARK: - AIEvaluator
/// Handles board evaluation and pattern analysis for the AI
class AIEvaluator {
    
    // MARK: - Scoring Constants
    private enum Score {
        static let win = 100000
        static let fourInRow = 10000
        static let threeInRow = 1000
        static let twoInRow = 100
        static let oneInRow = 10
        static let openEndBonus = 5
        static let centerBonus = 10
        static let doubleThreeBonus = 1500
        static let doubleFourBonus = 5000
    }
    
    // MARK: - Evaluation Constants
    private enum Evaluation {
        static let opponentMultiplier = 2
        static let defenseMultiplier = 3
        static let centerControlRadius = 2
        static let centerControlMaxBonus = 10
        static let centerControlDistancePenalty = 2
    }
    
    // MARK: - Public Methods
    
    /// Evaluates the entire board for a given player
    func evaluateBoard(board: [[Player]], for player: Player, size: Int) -> Int {
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
                        score -= cellScore * Evaluation.opponentMultiplier
                    }
                }
            }
        }
        
        // Add center control bonus
        score += evaluateCenterControl(board: board, for: player, size: size)
        score -= evaluateCenterControl(board: board, for: opponent, size: size) / 2
        
        return score
    }
    
    /// Evaluates a single position for placement
    func evaluatePosition(row: Int, col: Int, boardData: GameBoardDataSource) -> Int {
        var score = 0
        
        let currentPlayer = boardData.currentPlayer
        let opponent = currentPlayer == .black ? Player.white : Player.black
        
        // Evaluate offensive potential
        score += evaluatePlayerPosition(
            row: row,
            col: col,
            player: currentPlayer,
            boardData: boardData
        ) * Evaluation.opponentMultiplier
        
        // Evaluate defensive necessity
        score += evaluatePlayerPosition(
            row: row,
            col: col,
            player: opponent,
            boardData: boardData
        ) * Evaluation.defenseMultiplier
        
        // Center position bonus
        if row == boardData.size / 2 && col == boardData.size / 2 {
            score += Score.centerBonus
        }
        
        return score
    }
    
    /// Checks if the game is over
    func isGameOver(board: [[Player]], size: Int) -> Bool {
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
    
    // MARK: - Private Methods - Position Evaluation
    
    private func evaluatePositionOnBoard(
        board: [[Player]],
        row: Int,
        col: Int,
        player: Player,
        size: Int
    ) -> Int {
        var totalScore = 0
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        var openThreeCount = 0
        var openFourCount = 0
        
        for (dx, dy) in directions {
            let pattern = analyzePattern(
                board: board,
                row: row,
                col: col,
                dx: dx,
                dy: dy,
                player: player,
                size: size
            )
            
            totalScore += evaluatePattern(count: pattern.count, openEnds: pattern.openEnds)
            if pattern.count == 3 && pattern.openEnds == 2 { openThreeCount += 1 }
            if pattern.count == 4 && pattern.openEnds == 2 { openFourCount += 1 }
        }
        // Synergy bonuses: multiple simultaneous threats
        if openThreeCount >= 2 { totalScore += Score.doubleThreeBonus }
        if openFourCount >= 2 { totalScore += Score.doubleFourBonus }

        return totalScore
    }
    
    private func evaluatePlayerPosition(
        row: Int,
        col: Int,
        player: Player,
        boardData: GameBoardDataSource
    ) -> Int {
        var score = 0
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        var openThreeCount = 0
        var openFourCount = 0
        
        for (dx, dy) in directions {
            let pattern = evaluateLineFeatures(
                row: row,
                col: col,
                dx: dx,
                dy: dy,
                player: player,
                boardData: boardData
            )
            score += evaluatePattern(count: pattern.count, openEnds: pattern.openEnds)
            if pattern.count == 3 && pattern.openEnds == 2 { openThreeCount += 1 }
            if pattern.count == 4 && pattern.openEnds == 2 { openFourCount += 1 }
        }
        // Synergy: prioritize double threats
        if openThreeCount >= 2 { score += Score.doubleThreeBonus }
        if openFourCount >= 2 { score += Score.doubleFourBonus }

        return score
    }
    
    private func evaluateLineFeatures(
        row: Int,
        col: Int,
        dx: Int,
        dy: Int,
        player: Player,
        boardData: GameBoardDataSource
    ) -> (count: Int, openEnds: Int) {
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
        return (count, openEnds)
    }
    
    // MARK: - Private Methods - Pattern Analysis
    
    private func analyzePattern(
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
    
    private func evaluatePattern(count: Int, openEnds: Int) -> Int {
        switch (count, openEnds) {
        case (5..., _):
            return Score.win
        case (4, 2):
            return Score.fourInRow
        case (4, 1):
            return Score.fourInRow / 2
        case (3, 2):
            return Score.threeInRow
        case (3, 1):
            return Score.threeInRow / 4
        case (2, 2):
            return Score.twoInRow
        case (2, 1):
            return Score.twoInRow / 4
        case (1, 2):
            return Score.openEndBonus
        default:
            return 0
        }
    }
    
    private func countInDirection(
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
    
    // MARK: - Private Methods - Center Control
    
    private func evaluateCenterControl(board: [[Player]], for player: Player, size: Int) -> Int {
        var score = 0
        let center = size / 2
        let radius = Evaluation.centerControlRadius
        
        for row in (center - radius)...(center + radius) {
            for col in (center - radius)...(center + radius) {
                if row >= 0 && row < size && col >= 0 && col < size {
                    if board[row][col] == player {
                        let distance = abs(row - center) + abs(col - center)
                        let bonus = Evaluation.centerControlMaxBonus
                        let penalty = Evaluation.centerControlDistancePenalty
                        score += bonus - distance * penalty
                    }
                }
            }
        }
        
        return score
    }
    
    // MARK: - Private Methods - Game State
    
    private func checkWin(board: [[Player]], row: Int, col: Int, player: Player, size: Int) -> Bool {
        let directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        
        for (dx, dy) in directions {
            let count = countInDirection(
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
    
    private func isBoardFull(board: [[Player]], size: Int) -> Bool {
        for row in 0..<size {
            for col in 0..<size {
                if board[row][col] == .none {
                    return false
                }
            }
        }
        return true
    }
}
