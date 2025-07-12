import XCTest
@testable import Gomoku

final class GameStateCheckerTests: XCTestCase {
    
    // MARK: - isGameOver Tests
    
    func testIsGameOverEmptyBoard() {
        let board = createEmptyBoard()
        let result = GameStateChecker.isGameOver(board: board, size: 15)
        
        XCTAssertFalse(result)
    }
    
    func testIsGameOverWithWinner() {
        var board = createEmptyBoard()
        // Create horizontal win for black
        for col in 0..<5 {
            board[7][col] = .black
        }
        
        let result = GameStateChecker.isGameOver(board: board, size: 15)
        XCTAssertTrue(result)
    }
    
    func testIsGameOverFullBoardNoWinner() {
        // Create a full board with no winner (alternating pattern)
        var board = createEmptyBoard(size: 3) // Use smaller board for simplicity
        board[0][0] = .black
        board[0][1] = .white
        board[0][2] = .black
        board[1][0] = .white
        board[1][1] = .black
        board[1][2] = .white
        board[2][0] = .white
        board[2][1] = .black
        board[2][2] = .white
        
        let result = GameStateChecker.isGameOver(board: board, size: 3)
        XCTAssertTrue(result) // Game over due to full board
    }
    
    func testIsGameOverPartialBoardNoWinner() {
        var board = createEmptyBoard()
        // Add some stones but no winner
        board[7][7] = .black
        board[7][8] = .white
        board[8][7] = .white
        board[8][8] = .black
        
        let result = GameStateChecker.isGameOver(board: board, size: 15)
        XCTAssertFalse(result)
    }
    
    // MARK: - isBoardFull Tests
    
    func testIsBoardFullEmpty() {
        let board = createEmptyBoard()
        let result = GameStateChecker.isBoardFull(board: board, size: 15)
        
        XCTAssertFalse(result)
    }
    
    func testIsBoardFullPartial() {
        var board = createEmptyBoard()
        // Fill half the board
        for row in 0..<8 {
            for col in 0..<15 {
                board[row][col] = row % 2 == 0 ? .black : .white
            }
        }
        
        let result = GameStateChecker.isBoardFull(board: board, size: 15)
        XCTAssertFalse(result)
    }
    
    func testIsBoardFullComplete() {
        var board = createEmptyBoard()
        // Fill entire board
        for row in 0..<15 {
            for col in 0..<15 {
                board[row][col] = (row + col) % 2 == 0 ? .black : .white
            }
        }
        
        let result = GameStateChecker.isBoardFull(board: board, size: 15)
        XCTAssertTrue(result)
    }
    
    func testIsBoardFullSingleEmpty() {
        var board = createEmptyBoard()
        // Fill entire board except one cell
        for row in 0..<15 {
            for col in 0..<15 {
                if !(row == 7 && col == 7) {
                    board[row][col] = (row + col) % 2 == 0 ? .black : .white
                }
            }
        }
        
        let result = GameStateChecker.isBoardFull(board: board, size: 15)
        XCTAssertFalse(result)
    }
    
    // MARK: - checkWin Tests
    
    func testCheckWinHorizontal() {
        var board = createEmptyBoard()
        // Create horizontal line of 5
        for col in 3...7 {
            board[10][col] = .black
        }
        
        let result = GameStateChecker.checkWin(board: board, row: 10, col: 5, player: .black, size: 15)
        XCTAssertTrue(result)
    }
    
    func testCheckWinVertical() {
        var board = createEmptyBoard()
        // Create vertical line of 5
        for row in 2...6 {
            board[row][8] = .white
        }
        
        let result = GameStateChecker.checkWin(board: board, row: 4, col: 8, player: .white, size: 15)
        XCTAssertTrue(result)
    }
    
    func testCheckWinDiagonal() {
        var board = createEmptyBoard()
        // Create diagonal line of 5
        for i in 0..<5 {
            board[5+i][5+i] = .black
        }
        
        let result = GameStateChecker.checkWin(board: board, row: 7, col: 7, player: .black, size: 15)
        XCTAssertTrue(result)
    }
    
    func testCheckWinAntiDiagonal() {
        var board = createEmptyBoard()
        // Create anti-diagonal line of 5
        for i in 0..<5 {
            board[5+i][9-i] = .white
        }
        
        let result = GameStateChecker.checkWin(board: board, row: 7, col: 7, player: .white, size: 15)
        XCTAssertTrue(result)
    }
    
    func testCheckWinExactlyFive() {
        var board = createEmptyBoard()
        // Create line of exactly 5
        for col in 5...9 {
            board[7][col] = .black
        }
        
        let result = GameStateChecker.checkWin(board: board, row: 7, col: 7, player: .black, size: 15)
        XCTAssertTrue(result)
    }
    
    func testCheckWinMoreThanFive() {
        var board = createEmptyBoard()
        // Create line of 6 (still wins in Gomoku)
        for col in 4...9 {
            board[7][col] = .white
        }
        
        let result = GameStateChecker.checkWin(board: board, row: 7, col: 7, player: .white, size: 15)
        XCTAssertTrue(result)
    }
    
    func testCheckWinFourNotEnough() {
        var board = createEmptyBoard()
        // Create line of only 4
        for col in 5...8 {
            board[7][col] = .black
        }
        
        let result = GameStateChecker.checkWin(board: board, row: 7, col: 6, player: .black, size: 15)
        XCTAssertFalse(result)
    }
    
    func testCheckWinInterrupted() {
        var board = createEmptyBoard()
        // Create interrupted line
        board[7][5] = .black
        board[7][6] = .black
        board[7][7] = .white // Interruption
        board[7][8] = .black
        board[7][9] = .black
        
        let result = GameStateChecker.checkWin(board: board, row: 7, col: 6, player: .black, size: 15)
        XCTAssertFalse(result)
    }
    
    func testCheckWinAtBoardEdge() {
        var board = createEmptyBoard()
        // Create win at board edge
        for row in 0..<5 {
            board[row][0] = .white
        }
        
        let result = GameStateChecker.checkWin(board: board, row: 2, col: 0, player: .white, size: 15)
        XCTAssertTrue(result)
    }
    
    func testCheckWinAtCorner() {
        var board = createEmptyBoard()
        // Create diagonal win from corner
        for i in 0..<5 {
            board[i][i] = .black
        }
        
        let result = GameStateChecker.checkWin(board: board, row: 0, col: 0, player: .black, size: 15)
        XCTAssertTrue(result)
    }
    
    func testCheckWinWrongPlayer() {
        var board = createEmptyBoard()
        // Create line for black
        for col in 5...9 {
            board[7][col] = .black
        }
        
        // Check for white player (should be false)
        let result = GameStateChecker.checkWin(board: board, row: 7, col: 7, player: .white, size: 15)
        XCTAssertFalse(result)
    }
    
    // MARK: - Performance Tests
    
    func testIsGameOverPerformance() {
        var board = createEmptyBoard()
        // Add scattered stones
        for i in 0..<50 {
            let row = (i * 3) % 15
            let col = (i * 7) % 15
            board[row][col] = i % 2 == 0 ? .black : .white
        }
        
        measure {
            _ = GameStateChecker.isGameOver(board: board, size: 15)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createEmptyBoard(size: Int = 15) -> [[Player]] {
        return Array(repeating: Array(repeating: Player.none, count: size), count: size)
    }
}