import XCTest
@testable import Gomoku

final class AIEngineTests: XCTestCase {
    
    var aiEngine: AIEngine!
    
    override func setUp() {
        super.setUp()
        aiEngine = AIEngine()
    }
    
    override func tearDown() {
        aiEngine = nil
        super.tearDown()
    }
    
    // Helper to create board data source
    private func createBoardDataSource(board: [[Player]], currentPlayer: Player = .black, size: Int = 15) -> GameBoardDataSource {
        return TestBoardDataSource(board: board, currentPlayer: currentPlayer, size: size)
    }
    
    func testSuggestMoveReturnsValidMove() {
        let board = Array(repeating: Array(repeating: Player.none, count: 15), count: 15)
        let boardData = createBoardDataSource(board: board)
        
        let move = aiEngine.getBestMove(for: boardData)
        XCTAssertNotNil(move)
        
        if let (row, col) = move {
            XCTAssertTrue(row >= 0 && row < 15)
            XCTAssertTrue(col >= 0 && col < 15)
            XCTAssertEqual(board[row][col], .none)
        }
    }
    
    func testSuggestMoveOnFullBoard() {
        // Create a full board
        var board = Array(repeating: Array(repeating: Player.none, count: 15), count: 15)
        for row in 0..<15 {
            for col in 0..<15 {
                board[row][col] = (row + col) % 2 == 0 ? .black : .white
            }
        }
        
        let boardData = createBoardDataSource(board: board)
        let move = aiEngine.getBestMove(for: boardData)
        XCTAssertNil(move)
    }
    
    func testBlockOpponentWin() {
        var board = Array(repeating: Array(repeating: Player.none, count: 15), count: 15)
        // Black has 4 in a row horizontally at row 7
        board[7][7] = .black
        board[7][8] = .black
        board[7][9] = .black
        board[7][10] = .black
        // White has some stones
        board[8][8] = .white
        board[8][9] = .white
        board[8][10] = .white
        
        // White's turn, should block at (7,6) or (7,11)
        let boardData = createBoardDataSource(board: board, currentPlayer: .white)
        let move = aiEngine.getBestMove(for: boardData)
        XCTAssertNotNil(move)
        
        if let (row, col) = move {
            XCTAssertTrue((row == 7 && col == 11) || (row == 7 && col == 6))
        }
    }
    
    func testCompleteOwnWin() {
        var board = Array(repeating: Array(repeating: Player.none, count: 15), count: 15)
        // White has 4 in a diagonal
        board[7][7] = .white
        board[8][8] = .white
        board[9][9] = .white
        board[10][10] = .white
        // Black has some stones
        board[7][8] = .black
        board[7][9] = .black
        board[7][10] = .black
        
        // White's turn, should complete win at (6,6) or (11,11)
        let boardData = createBoardDataSource(board: board, currentPlayer: .white)
        let move = aiEngine.getBestMove(for: boardData)
        XCTAssertNotNil(move)
        
        if let (row, col) = move {
            XCTAssertTrue((row == 6 && col == 6) || (row == 11 && col == 11))
        }
    }
    
    // Test removed - evaluatePosition is now private implementation detail
    
    func testFirstMovePreferCenter() {
        let board = Array(repeating: Array(repeating: Player.none, count: 15), count: 15)
        let boardData = createBoardDataSource(board: board)
        
        let move = aiEngine.getBestMove(for: boardData)
        XCTAssertNotNil(move)
        
        if let (row, col) = move {
            let centerDistance = abs(row - 7) + abs(col - 7)
            XCTAssertLessThanOrEqual(centerDistance, 2)
        }
    }
    
    func testDefensivePriority() {
        var board = Array(repeating: Array(repeating: Player.none, count: 15), count: 15)
        // Black has 3 in a row
        board[7][7] = .black
        board[7][8] = .black
        board[7][9] = .black
        // White has 2 in a row
        board[8][8] = .white
        board[8][9] = .white
        
        // White's turn, should prioritize blocking black's potential win
        let boardData = createBoardDataSource(board: board, currentPlayer: .white)
        let move = aiEngine.getBestMove(for: boardData)
        XCTAssertNotNil(move)
        
        if let (row, col) = move {
            // Should block at (7,6) or (7,10)
            XCTAssertEqual(row, 7)
            XCTAssertTrue(col == 6 || col == 10)
        }
    }
    
    func testPerformance() {
        let board = Array(repeating: Array(repeating: Player.none, count: 15), count: 15)
        let boardData = createBoardDataSource(board: board)
        
        measure {
            _ = aiEngine.getBestMove(for: boardData)
        }
    }
    
    func testInvalidBoardState() {
        var board = Array(repeating: Array(repeating: Player.none, count: 15), count: 15)
        // Create an invalid state where black has significantly more stones
        for i in 0..<10 {
            board[i][0] = .black
        }
        board[0][1] = .white
        
        let boardData = createBoardDataSource(board: board, currentPlayer: .white)
        let move = aiEngine.getBestMove(for: boardData)
        
        // Should still return a valid move (fallback behavior)
        XCTAssertNotNil(move)
    }
}

// Test helper
private struct TestBoardDataSource: GameBoardDataSource {
    let board: [[Player]]
    let currentPlayer: Player
    let size: Int
}