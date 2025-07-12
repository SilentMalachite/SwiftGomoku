import XCTest
@testable import Gomoku

final class PatternAnalyzerTests: XCTestCase {
    
    // MARK: - analyzePattern Tests
    
    func testAnalyzePatternSingleStone() {
        var board = createEmptyBoard()
        board[7][7] = .black
        
        let result = PatternAnalyzer.analyzePattern(
            board: board,
            row: 7,
            col: 7,
            dx: 0,
            dy: 1,
            player: .black,
            size: 15
        )
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.openEnds, 2) // Both sides are open
    }
    
    func testAnalyzePatternHorizontalLine() {
        var board = createEmptyBoard()
        // Create horizontal line of 3 black stones
        board[7][5] = .black
        board[7][6] = .black
        board[7][7] = .black
        
        let result = PatternAnalyzer.analyzePattern(
            board: board,
            row: 7,
            col: 6, // Check from middle stone
            dx: 0,
            dy: 1,
            player: .black,
            size: 15
        )
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result.openEnds, 2)
    }
    
    func testAnalyzePatternBlockedOneEnd() {
        var board = createEmptyBoard()
        // Create horizontal line with white stone blocking one end
        board[7][4] = .white
        board[7][5] = .black
        board[7][6] = .black
        board[7][7] = .black
        
        let result = PatternAnalyzer.analyzePattern(
            board: board,
            row: 7,
            col: 6,
            dx: 0,
            dy: 1,
            player: .black,
            size: 15
        )
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result.openEnds, 1) // Only one end is open
    }
    
    func testAnalyzePatternBlockedBothEnds() {
        var board = createEmptyBoard()
        // Create horizontal line with both ends blocked
        board[7][4] = .white
        board[7][5] = .black
        board[7][6] = .black
        board[7][7] = .black
        board[7][8] = .white
        
        let result = PatternAnalyzer.analyzePattern(
            board: board,
            row: 7,
            col: 6,
            dx: 0,
            dy: 1,
            player: .black,
            size: 15
        )
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result.openEnds, 0)
    }
    
    func testAnalyzePatternDiagonal() {
        var board = createEmptyBoard()
        // Create diagonal line
        board[5][5] = .black
        board[6][6] = .black
        board[7][7] = .black
        board[8][8] = .black
        
        let result = PatternAnalyzer.analyzePattern(
            board: board,
            row: 7,
            col: 7,
            dx: 1,
            dy: 1,
            player: .black,
            size: 15
        )
        
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result.openEnds, 2)
    }
    
    func testAnalyzePatternAtBoardEdge() {
        var board = createEmptyBoard()
        // Create pattern at board edge
        board[0][0] = .black
        board[0][1] = .black
        board[0][2] = .black
        
        let result = PatternAnalyzer.analyzePattern(
            board: board,
            row: 0,
            col: 1,
            dx: 0,
            dy: 1,
            player: .black,
            size: 15
        )
        
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result.openEnds, 1) // Only one end open (board edge blocks the other)
    }
    
    // MARK: - evaluatePattern Tests
    
    func testEvaluatePatternWin() {
        let score = PatternAnalyzer.evaluatePattern(count: 5, openEnds: 0)
        XCTAssertEqual(score, AIConstants.Score.win)
        
        let score2 = PatternAnalyzer.evaluatePattern(count: 6, openEnds: 2)
        XCTAssertEqual(score2, AIConstants.Score.win)
    }
    
    func testEvaluatePatternFourInRow() {
        let scoreOpen = PatternAnalyzer.evaluatePattern(count: 4, openEnds: 2)
        XCTAssertEqual(scoreOpen, AIConstants.Score.fourInRow)
        
        let scoreHalfOpen = PatternAnalyzer.evaluatePattern(count: 4, openEnds: 1)
        XCTAssertEqual(scoreHalfOpen, AIConstants.Score.fourInRow / 2)
        
        let scoreClosed = PatternAnalyzer.evaluatePattern(count: 4, openEnds: 0)
        XCTAssertEqual(scoreClosed, 0)
    }
    
    func testEvaluatePatternThreeInRow() {
        let scoreOpen = PatternAnalyzer.evaluatePattern(count: 3, openEnds: 2)
        XCTAssertEqual(scoreOpen, AIConstants.Score.threeInRow)
        
        let scoreHalfOpen = PatternAnalyzer.evaluatePattern(count: 3, openEnds: 1)
        XCTAssertEqual(scoreHalfOpen, AIConstants.Score.threeInRow / 4)
        
        let scoreClosed = PatternAnalyzer.evaluatePattern(count: 3, openEnds: 0)
        XCTAssertEqual(scoreClosed, 0)
    }
    
    func testEvaluatePatternTwoInRow() {
        let scoreOpen = PatternAnalyzer.evaluatePattern(count: 2, openEnds: 2)
        XCTAssertEqual(scoreOpen, AIConstants.Score.twoInRow)
        
        let scoreHalfOpen = PatternAnalyzer.evaluatePattern(count: 2, openEnds: 1)
        XCTAssertEqual(scoreHalfOpen, AIConstants.Score.twoInRow / 4)
        
        let scoreClosed = PatternAnalyzer.evaluatePattern(count: 2, openEnds: 0)
        XCTAssertEqual(scoreClosed, 0)
    }
    
    func testEvaluatePatternSingleStone() {
        let scoreOpen = PatternAnalyzer.evaluatePattern(count: 1, openEnds: 2)
        XCTAssertEqual(scoreOpen, AIConstants.Score.openEndBonus)
        
        let scoreHalfOpen = PatternAnalyzer.evaluatePattern(count: 1, openEnds: 1)
        XCTAssertEqual(scoreHalfOpen, 0)
    }
    
    // MARK: - countInDirection Tests
    
    func testCountInDirectionHorizontal() {
        var board = createEmptyBoard()
        // Create horizontal line of 5
        for col in 5...9 {
            board[7][col] = .black
        }
        
        let count = PatternAnalyzer.countInDirection(
            board: board,
            row: 7,
            col: 7,
            dx: 0,
            dy: 1,
            player: .black,
            size: 15
        )
        
        XCTAssertEqual(count, 5)
    }
    
    func testCountInDirectionVertical() {
        var board = createEmptyBoard()
        // Create vertical line of 4
        for row in 3...6 {
            board[row][7] = .white
        }
        
        let count = PatternAnalyzer.countInDirection(
            board: board,
            row: 5,
            col: 7,
            dx: 1,
            dy: 0,
            player: .white,
            size: 15
        )
        
        XCTAssertEqual(count, 4)
    }
    
    func testCountInDirectionDiagonal() {
        var board = createEmptyBoard()
        // Create diagonal line
        for i in 0..<6 {
            board[i][i] = .black
        }
        
        let count = PatternAnalyzer.countInDirection(
            board: board,
            row: 3,
            col: 3,
            dx: 1,
            dy: 1,
            player: .black,
            size: 15
        )
        
        XCTAssertEqual(count, 6)
    }
    
    func testCountInDirectionAntiDiagonal() {
        var board = createEmptyBoard()
        // Create anti-diagonal line
        for i in 0..<4 {
            board[i][10-i] = .white
        }
        
        let count = PatternAnalyzer.countInDirection(
            board: board,
            row: 1,
            col: 9,
            dx: 1,
            dy: -1,
            player: .white,
            size: 15
        )
        
        XCTAssertEqual(count, 4)
    }
    
    func testCountInDirectionInterrupted() {
        var board = createEmptyBoard()
        // Create interrupted line
        board[7][5] = .black
        board[7][6] = .black
        board[7][7] = .white // Different player
        board[7][8] = .black
        board[7][9] = .black
        
        let count = PatternAnalyzer.countInDirection(
            board: board,
            row: 7,
            col: 6,
            dx: 0,
            dy: 1,
            player: .black,
            size: 15
        )
        
        XCTAssertEqual(count, 2) // Only counts continuous stones
    }
    
    // MARK: - Helper Methods
    
    private func createEmptyBoard(size: Int = 15) -> [[Player]] {
        return Array(repeating: Array(repeating: Player.none, count: size), count: size)
    }
}