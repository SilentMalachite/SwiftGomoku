import XCTest
@testable import Gomoku

final class GameBoardTests: XCTestCase {
    
    var gameBoard: GameBoard!
    
    override func setUp() {
        super.setUp()
        gameBoard = GameBoard()
    }
    
    override func tearDown() {
        gameBoard = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(gameBoard.currentPlayer, .black)
        XCTAssertFalse(gameBoard.isGameOver)
        XCTAssertNil(gameBoard.winner)
        XCTAssertTrue(gameBoard.winningLine.isEmpty)
        
        for row in 0..<GameBoard.size {
            for col in 0..<GameBoard.size {
                XCTAssertEqual(gameBoard.board[row][col], .none)
            }
        }
    }
    
    func testMakeMove() {
        XCTAssertTrue(gameBoard.makeMove(row: 7, col: 7))
        XCTAssertEqual(gameBoard.board[7][7], .black)
        XCTAssertEqual(gameBoard.currentPlayer, .white)
        
        XCTAssertTrue(gameBoard.makeMove(row: 8, col: 8))
        XCTAssertEqual(gameBoard.board[8][8], .white)
        XCTAssertEqual(gameBoard.currentPlayer, .black)
    }
    
    func testInvalidMove() {
        XCTAssertTrue(gameBoard.makeMove(row: 7, col: 7))
        XCTAssertFalse(gameBoard.makeMove(row: 7, col: 7))
        XCTAssertEqual(gameBoard.currentPlayer, .white)
    }
    
    func testOutOfBoundsMove() {
        XCTAssertFalse(gameBoard.makeMove(row: -1, col: 0))
        XCTAssertFalse(gameBoard.makeMove(row: 0, col: -1))
        XCTAssertFalse(gameBoard.makeMove(row: GameBoard.size, col: 0))
        XCTAssertFalse(gameBoard.makeMove(row: 0, col: GameBoard.size))
    }
    
    func testHorizontalWin() {
        for i in 0..<5 {
            gameBoard.makeMove(row: 7, col: i)
            gameBoard.makeMove(row: 8, col: i)
        }
        
        XCTAssertTrue(gameBoard.isGameOver)
        XCTAssertEqual(gameBoard.winner, .black)
        XCTAssertEqual(gameBoard.winningLine.count, 5)
    }
    
    func testVerticalWin() {
        for i in 0..<5 {
            gameBoard.makeMove(row: i, col: 7)
            gameBoard.makeMove(row: i, col: 8)
        }
        
        XCTAssertTrue(gameBoard.isGameOver)
        XCTAssertEqual(gameBoard.winner, .black)
        XCTAssertEqual(gameBoard.winningLine.count, 5)
    }
    
    func testDiagonalWin() {
        for i in 0..<5 {
            gameBoard.makeMove(row: i, col: i)
            gameBoard.makeMove(row: i, col: i + 1)
        }
        
        XCTAssertTrue(gameBoard.isGameOver)
        XCTAssertEqual(gameBoard.winner, .black)
        XCTAssertEqual(gameBoard.winningLine.count, 5)
    }
    
    func testAntiDiagonalWin() {
        for i in 0..<5 {
            gameBoard.makeMove(row: i, col: 4 - i)
            gameBoard.makeMove(row: i, col: 5 - i)
        }
        
        XCTAssertTrue(gameBoard.isGameOver)
        XCTAssertEqual(gameBoard.winner, .black)
        XCTAssertEqual(gameBoard.winningLine.count, 5)
    }
    
    func testDrawGame() {
        // Create a mostly full board
        gameBoard.reset()
        
        // Fill board in a pattern that won't create 5 in a row
        for row in 0..<GameBoard.size {
            for col in 0..<GameBoard.size {
                if (row + col) % 3 != 2 {
                    gameBoard.makeMove(row: row, col: col)
                }
            }
        }
        
        // Fill remaining spaces
        for row in 0..<GameBoard.size {
            for col in 0..<GameBoard.size {
                if gameBoard.board[row][col] == .none {
                    gameBoard.makeMove(row: row, col: col)
                }
            }
        }
        
        XCTAssertTrue(gameBoard.isGameOver)
        XCTAssertNil(gameBoard.winner)
    }
    
    func testResetGame() {
        gameBoard.makeMove(row: 7, col: 7)
        gameBoard.makeMove(row: 8, col: 8)
        
        gameBoard.reset()
        
        XCTAssertEqual(gameBoard.currentPlayer, .black)
        XCTAssertFalse(gameBoard.isGameOver)
        XCTAssertNil(gameBoard.winner)
        XCTAssertTrue(gameBoard.winningLine.isEmpty)
        
        for row in 0..<GameBoard.size {
            for col in 0..<GameBoard.size {
                XCTAssertEqual(gameBoard.board[row][col], .none)
            }
        }
    }
}