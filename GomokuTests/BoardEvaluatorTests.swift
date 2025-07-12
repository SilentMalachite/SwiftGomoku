import XCTest
@testable import Gomoku

final class BoardEvaluatorTests: XCTestCase {
    
    // MARK: - evaluateBoard Tests
    
    func testEvaluateBoardEmpty() {
        let board = createEmptyBoard()
        let score = BoardEvaluator.evaluateBoard(board: board, for: .black, size: 15)
        
        // Empty board should have minimal score (only center control bonus for empty center)
        XCTAssertEqual(score, 0)
    }
    
    func testEvaluateBoardSingleStone() {
        var board = createEmptyBoard()
        board[7][7] = .black
        
        let scoreBlack = BoardEvaluator.evaluateBoard(board: board, for: .black, size: 15)
        let scoreWhite = BoardEvaluator.evaluateBoard(board: board, for: .white, size: 15)
        
        // Black should have positive score for its stone
        XCTAssertGreaterThan(scoreBlack, 0)
        // White should have negative score due to opponent's stone
        XCTAssertLessThan(scoreWhite, 0)
    }
    
    func testEvaluateBoardWinningPosition() {
        var board = createEmptyBoard()
        // Create a winning line for black
        for col in 3...7 {
            board[7][col] = .black
        }
        
        let score = BoardEvaluator.evaluateBoard(board: board, for: .black, size: 15)
        
        // Should have very high score due to winning position
        XCTAssertGreaterThanOrEqual(score, AIConstants.Score.win)
    }
    
    func testEvaluateBoardDefensiveEvaluation() {
        var board = createEmptyBoard()
        // White has 4 in a row (threatening to win)
        for col in 3...6 {
            board[7][col] = .white
        }
        
        let scoreBlack = BoardEvaluator.evaluateBoard(board: board, for: .black, size: 15)
        
        // Black should have very negative score due to opponent's threat
        XCTAssertLessThan(scoreBlack, -AIConstants.Score.fourInRow)
    }
    
    func testEvaluateBoardMixedPositions() {
        var board = createEmptyBoard()
        // Black has 3 in a row
        board[7][5] = .black
        board[7][6] = .black
        board[7][7] = .black
        
        // White has 2 in a row
        board[9][5] = .white
        board[9][6] = .white
        
        let scoreBlack = BoardEvaluator.evaluateBoard(board: board, for: .black, size: 15)
        
        // Black should have positive score (3 in row is better than opponent's 2)
        XCTAssertGreaterThan(scoreBlack, 0)
    }
    
    // MARK: - evaluatePositionOnBoard Tests
    
    func testEvaluatePositionOnBoardCenter() {
        var board = createEmptyBoard()
        board[7][7] = .black
        
        let score = BoardEvaluator.evaluatePositionOnBoard(
            board: board,
            row: 7,
            col: 7,
            player: .black,
            size: 15
        )
        
        // Center position with potential in all directions
        XCTAssertGreaterThan(score, 0)
    }
    
    func testEvaluatePositionOnBoardThreeInRow() {
        var board = createEmptyBoard()
        board[7][5] = .black
        board[7][6] = .black
        board[7][7] = .black
        
        let score = BoardEvaluator.evaluatePositionOnBoard(
            board: board,
            row: 7,
            col: 6,
            player: .black,
            size: 15
        )
        
        // Should recognize the three-in-a-row pattern
        XCTAssertGreaterThanOrEqual(score, AIConstants.Score.threeInRow)
    }
    
    func testEvaluatePositionOnBoardMultiplePatterns() {
        var board = createEmptyBoard()
        // Create intersection of patterns
        board[7][7] = .black
        board[7][8] = .black // Horizontal
        board[8][7] = .black // Vertical
        board[8][8] = .black // Diagonal
        
        let score = BoardEvaluator.evaluatePositionOnBoard(
            board: board,
            row: 7,
            col: 7,
            player: .black,
            size: 15
        )
        
        // Should accumulate scores from multiple directions
        XCTAssertGreaterThan(score, AIConstants.Score.twoInRow * 2)
    }
    
    // MARK: - evaluateCenterControl Tests
    
    func testEvaluateCenterControlEmpty() {
        let board = createEmptyBoard()
        let score = BoardEvaluator.evaluateCenterControl(board: board, for: .black, size: 15)
        
        XCTAssertEqual(score, 0)
    }
    
    func testEvaluateCenterControlSingleCenterStone() {
        var board = createEmptyBoard()
        board[7][7] = .black
        
        let scoreBlack = BoardEvaluator.evaluateCenterControl(board: board, for: .black, size: 15)
        let scoreWhite = BoardEvaluator.evaluateCenterControl(board: board, for: .white, size: 15)
        
        XCTAssertGreaterThan(scoreBlack, 0)
        XCTAssertEqual(scoreWhite, 0)
    }
    
    func testEvaluateCenterControlMultipleStones() {
        var board = createEmptyBoard()
        let center = 7
        
        // Place stones at various distances from center
        board[center][center] = .black     // Distance 0
        board[center-1][center] = .black   // Distance 1
        board[center][center+1] = .black   // Distance 1
        board[center-2][center] = .white   // Distance 2
        
        let scoreBlack = BoardEvaluator.evaluateCenterControl(board: board, for: .black, size: 15)
        
        // Should have positive score with higher bonus for closer stones
        XCTAssertGreaterThan(scoreBlack, 0)
        
        // Verify the scoring follows distance penalty
        let expectedScore = AIConstants.Evaluation.centerControlMaxBonus + // Center stone
                          2 * (AIConstants.Evaluation.centerControlMaxBonus - AIConstants.Evaluation.centerControlDistancePenalty) // Two stones at distance 1
        XCTAssertEqual(scoreBlack, expectedScore)
    }
    
    // MARK: - evaluatePosition Tests (GameBoardDataSource)
    
    func testEvaluatePositionEmpty() {
        let board = createEmptyBoard()
        let boardData = TestBoardDataSource(board: board, currentPlayer: .black, size: 15)
        
        let score = BoardEvaluator.evaluatePosition(row: 7, col: 7, boardData: boardData)
        
        // Center position bonus
        XCTAssertEqual(score, AIConstants.Score.centerBonus)
    }
    
    func testEvaluatePositionOffensive() {
        var board = createEmptyBoard()
        // Black has two stones that could form a line with position (7,7)
        board[7][5] = .black
        board[7][6] = .black
        
        let boardData = TestBoardDataSource(board: board, currentPlayer: .black, size: 15)
        let score = BoardEvaluator.evaluatePosition(row: 7, col: 7, boardData: boardData)
        
        // Should have high score for completing own pattern
        XCTAssertGreaterThan(score, 0)
    }
    
    func testEvaluatePositionDefensive() {
        var board = createEmptyBoard()
        // White has three stones that need blocking
        board[7][5] = .white
        board[7][6] = .white
        board[7][8] = .white
        
        let boardData = TestBoardDataSource(board: board, currentPlayer: .black, size: 15)
        let score = BoardEvaluator.evaluatePosition(row: 7, col: 7, boardData: boardData)
        
        // Should have high score for blocking opponent
        XCTAssertGreaterThan(score, 0)
    }
    
    func testEvaluatePositionBothPlayersPatterns() {
        var board = createEmptyBoard()
        // Black has potential horizontal line
        board[7][5] = .black
        board[7][6] = .black
        
        // White has potential vertical line
        board[6][7] = .white
        board[8][7] = .white
        
        let boardData = TestBoardDataSource(board: board, currentPlayer: .black, size: 15)
        let score = BoardEvaluator.evaluatePosition(row: 7, col: 7, boardData: boardData)
        
        // Should consider both offensive and defensive value
        XCTAssertGreaterThan(score, 0)
    }
    
    // MARK: - Helper Methods
    
    private func createEmptyBoard(size: Int = 15) -> [[Player]] {
        return Array(repeating: Array(repeating: Player.none, count: size), count: size)
    }
}

// Test helper
private struct TestBoardDataSource: GameBoardDataSource {
    let board: [[Player]]
    let currentPlayer: Player
    let size: Int
}