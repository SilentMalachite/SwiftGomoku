import XCTest
@testable import Gomoku

@MainActor
final class GameViewModelTests: XCTestCase {
    
    var viewModel: GameViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = GameViewModel(boardSize: 15)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertEqual(viewModel.currentPlayer, .black)
        XCTAssertNil(viewModel.winner)
        XCTAssertFalse(viewModel.isGameOver)
        XCTAssertTrue(viewModel.winningLine.isEmpty)
        XCTAssertFalse(viewModel.isAIEnabled)
        XCTAssertFalse(viewModel.isAIThinking)
        
        // Check initial board is empty
        for row in viewModel.board {
            for cell in row {
                XCTAssertEqual(cell, .none)
            }
        }
    }
    
    func testCanToggleAI() {
        XCTAssertTrue(viewModel.canToggleAI)
        
        // Make a move
        _ = viewModel.makeMove(row: 7, col: 7)
        XCTAssertFalse(viewModel.canToggleAI)
    }
    
    // MARK: - Move Tests
    
    func testValidMove() {
        let success = viewModel.makeMove(row: 7, col: 7)
        XCTAssertTrue(success)
        XCTAssertEqual(viewModel.board[7][7], .black)
        XCTAssertEqual(viewModel.currentPlayer, .white)
    }
    
    func testInvalidMoveOutOfBounds() {
        let success1 = viewModel.makeMove(row: -1, col: 0)
        XCTAssertFalse(success1)
        
        let success2 = viewModel.makeMove(row: 15, col: 0)
        XCTAssertFalse(success2)
        
        let success3 = viewModel.makeMove(row: 0, col: -1)
        XCTAssertFalse(success3)
        
        let success4 = viewModel.makeMove(row: 0, col: 15)
        XCTAssertFalse(success4)
    }
    
    func testInvalidMoveOccupiedPosition() {
        _ = viewModel.makeMove(row: 7, col: 7)
        let success = viewModel.makeMove(row: 7, col: 7)
        XCTAssertFalse(success)
    }
    
    func testAlternatingPlayers() {
        XCTAssertEqual(viewModel.currentPlayer, .black)
        
        _ = viewModel.makeMove(row: 7, col: 7)
        XCTAssertEqual(viewModel.currentPlayer, .white)
        
        _ = viewModel.makeMove(row: 7, col: 8)
        XCTAssertEqual(viewModel.currentPlayer, .black)
    }
    
    // MARK: - Win Condition Tests
    
    func testHorizontalWin() {
        // Black plays horizontal line
        for col in 0..<5 {
            _ = viewModel.makeMove(row: 7, col: col)
            if col < 4 {
                // White plays somewhere else
                _ = viewModel.makeMove(row: 8, col: col)
            }
        }
        
        XCTAssertTrue(viewModel.isGameOver)
        XCTAssertEqual(viewModel.winner, .black)
        XCTAssertEqual(viewModel.winningLine.count, 5)
    }
    
    func testVerticalWin() {
        // Black plays vertical line
        for row in 0..<5 {
            _ = viewModel.makeMove(row: row, col: 7)
            if row < 4 {
                // White plays somewhere else
                _ = viewModel.makeMove(row: row, col: 8)
            }
        }
        
        XCTAssertTrue(viewModel.isGameOver)
        XCTAssertEqual(viewModel.winner, .black)
        XCTAssertEqual(viewModel.winningLine.count, 5)
    }
    
    func testDiagonalWin() {
        // Black plays diagonal line
        for i in 0..<5 {
            _ = viewModel.makeMove(row: i, col: i)
            if i < 4 {
                // White plays somewhere else
                _ = viewModel.makeMove(row: i, col: i + 6)
            }
        }
        
        XCTAssertTrue(viewModel.isGameOver)
        XCTAssertEqual(viewModel.winner, .black)
        XCTAssertEqual(viewModel.winningLine.count, 5)
    }
    
    func testAntiDiagonalWin() {
        // Black plays anti-diagonal line
        for i in 0..<5 {
            _ = viewModel.makeMove(row: i, col: 4 - i)
            if i < 4 {
                // White plays somewhere else
                _ = viewModel.makeMove(row: i + 6, col: i)
            }
        }
        
        XCTAssertTrue(viewModel.isGameOver)
        XCTAssertEqual(viewModel.winner, .black)
        XCTAssertEqual(viewModel.winningLine.count, 5)
    }
    
    // MARK: - Draw Tests
    
    func testDrawCondition() {
        // Fill the board in a pattern that prevents any wins
        // This is a simplified test - in reality, filling a 15x15 board without wins is complex
        // For testing purposes, we'll create a small 3x3 board scenario
        let smallViewModel = GameViewModel(boardSize: 3)
        
        // Pattern that results in a draw on 3x3:
        // X O X
        // O X O
        // O X X
        _ = smallViewModel.makeMove(row: 0, col: 0) // X
        _ = smallViewModel.makeMove(row: 0, col: 1) // O
        _ = smallViewModel.makeMove(row: 0, col: 2) // X
        _ = smallViewModel.makeMove(row: 1, col: 0) // O
        _ = smallViewModel.makeMove(row: 1, col: 1) // X
        _ = smallViewModel.makeMove(row: 1, col: 2) // O
        _ = smallViewModel.makeMove(row: 2, col: 2) // X
        _ = smallViewModel.makeMove(row: 2, col: 0) // O
        _ = smallViewModel.makeMove(row: 2, col: 1) // X
        
        XCTAssertTrue(smallViewModel.isGameOver)
        XCTAssertNil(smallViewModel.winner)
    }
    
    // MARK: - Reset Tests
    
    func testReset() {
        // Make some moves
        _ = viewModel.makeMove(row: 7, col: 7)
        _ = viewModel.makeMove(row: 8, col: 8)
        viewModel.isAIEnabled = true
        
        // Reset
        viewModel.reset()
        
        // Check state is back to initial
        XCTAssertEqual(viewModel.currentPlayer, .black)
        XCTAssertNil(viewModel.winner)
        XCTAssertFalse(viewModel.isGameOver)
        XCTAssertTrue(viewModel.winningLine.isEmpty)
        XCTAssertFalse(viewModel.isAIThinking)
        
        // Board should be empty
        for row in viewModel.board {
            for cell in row {
                XCTAssertEqual(cell, .none)
            }
        }
    }
    
    // MARK: - Alert Tests
    
    func testAlertMessages() {
        // Test win alert
        for col in 0..<5 {
            _ = viewModel.makeMove(row: 7, col: col)
            if col < 4 {
                _ = viewModel.makeMove(row: 8, col: col)
            }
        }
        
        XCTAssertEqual(viewModel.alertTitle, "Game Over")
        XCTAssertEqual(viewModel.alertMessage, "Black wins!")
        XCTAssertTrue(viewModel.shouldShowAlert)
    }
    
    // MARK: - AI Tests
    
    func testAIMoveAsync() async {
        viewModel.isAIEnabled = true
        
        // Black makes first move
        _ = viewModel.makeMove(row: 7, col: 7)
        
        // Wait for AI to make move
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Check that AI (white) made a move
        var whiteCount = 0
        for row in viewModel.board {
            for cell in row {
                if cell == .white {
                    whiteCount += 1
                }
            }
        }
        
        XCTAssertEqual(whiteCount, 1)
        XCTAssertEqual(viewModel.currentPlayer, .black)
    }
    
    func testNoMovesAfterGameOver() {
        // Create a win condition
        for col in 0..<5 {
            _ = viewModel.makeMove(row: 7, col: col)
            if col < 4 {
                _ = viewModel.makeMove(row: 8, col: col)
            }
        }
        
        XCTAssertTrue(viewModel.isGameOver)
        
        // Try to make another move
        let success = viewModel.makeMove(row: 0, col: 0)
        XCTAssertFalse(success)
    }
}