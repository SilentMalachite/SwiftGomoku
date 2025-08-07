import XCTest
@testable import Gomoku

final class GameBoardTests: XCTestCase {
    var gameBoard: GameBoard!
    
    override func setUp() {
        super.setUp()
        gameBoard = GameBoard(size: 15)
    }
    
    override func tearDown() {
        gameBoard = nil
        super.tearDown()
    }
    
    func testInitialBoardState() {
        // Assert
        XCTAssertEqual(gameBoard.board.count, 15)
        XCTAssertEqual(gameBoard.board[0].count, 15)
        XCTAssertEqual(gameBoard.currentPlayer, .black)
        
        // すべてのセルが空であることを確認
        for row in gameBoard.board {
            for cell in row {
                XCTAssertEqual(cell, .none)
            }
        }
    }
    
    func testValidMovePlacement() {
        // Act
        let result = gameBoard.placeStone(at: 7, col: 7, player: .black)
        
        // Assert
        switch result {
        case .success:
            XCTAssertEqual(gameBoard.board[7][7], .black)
        case .failure(let error):
            XCTFail("Expected success but failed with: \(error)")
        }
    }
    
    func testInvalidMoves() {
        // Arrange
        _ = gameBoard.placeStone(at: 7, col: 7, player: .black)
        
        // Act - 同じ位置に再度置こうとする
        let result = gameBoard.placeStone(at: 7, col: 7, player: .white)
        
        // Assert
        if case .success = result { XCTFail("Expected failure for occupied position") }
    }
    
    func testOutOfBoundsMoves() {
        // Act - 範囲外の位置
        let result1 = gameBoard.placeStone(at: -1, col: 7, player: .black)
        let result2 = gameBoard.placeStone(at: 15, col: 7, player: .black)
        let result3 = gameBoard.placeStone(at: 7, col: -1, player: .black)
        let result4 = gameBoard.placeStone(at: 7, col: 15, player: .black)
        
        // Assert
        if case .success = result1 { XCTFail("Out of bounds move should fail") }
        if case .success = result2 { XCTFail("Out of bounds move should fail") }
        if case .success = result3 { XCTFail("Out of bounds move should fail") }
        if case .success = result4 { XCTFail("Out of bounds move should fail") }
    }
    
    func testSwitchPlayer() {
        // Act
        gameBoard.switchPlayer()
        
        // Assert
        XCTAssertEqual(gameBoard.currentPlayer, .white)
        
        // Act again
        gameBoard.switchPlayer()
        XCTAssertEqual(gameBoard.currentPlayer, .black)
    }
    
    func testHorizontalWinDetection() {
        // Arrange - 黒が5つ横並び
        for i in 0..<5 {
            _ = gameBoard.placeStone(at: 7, col: i, player: .black)
        }
        
        // Act
        let (winner, line) = gameBoard.checkForWinner()
        
        // Assert
        XCTAssertEqual(winner, .black)
        XCTAssertEqual(line.count, 5)
    }
    
    func testVerticalWinDetection() {
        // Arrange - 黒が5つ縦並び
        for i in 0..<5 {
            _ = gameBoard.placeStone(at: i, col: 7, player: .black)
        }
        
        // Act
        let (winner, _) = gameBoard.checkForWinner()
        
        // Assert
        XCTAssertEqual(winner, .black)
    }
    
    func testDiagonalWinDetection() {
        // Arrange - 黒が斜めに5つ
        for i in 0..<5 {
            _ = gameBoard.placeStone(at: i, col: i, player: .black)
        }
        
        // Act
        let (winner, _) = gameBoard.checkForWinner()
        
        // Assert
        XCTAssertEqual(winner, .black)
    }
    
    func testIsBoardFull() {
        // Arrange - 盤面を埋める（同一色での勝利を避けるよう交互に）
        for r in 0..<15 {
            for c in 0..<15 {
                _ = gameBoard.placeStone(at: r, col: c, player: (r + c) % 2 == 0 ? .black : .white)
            }
        }
        
        // Assert
        XCTAssertTrue(gameBoard.isBoardFull())
    }
    
    func testReset() {
        // Arrange - いくつかの石
        _ = gameBoard.placeStone(at: 7, col: 7, player: .black)
        _ = gameBoard.placeStone(at: 7, col: 8, player: .white)
        
        // Act
        gameBoard.reset()
        
        // Assert
        XCTAssertEqual(gameBoard.currentPlayer, .black)
        for row in gameBoard.board {
            for cell in row {
                XCTAssertEqual(cell, .none)
            }
        }
    }
}

