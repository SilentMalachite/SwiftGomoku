import XCTest
@testable import Gomoku

@MainActor
final class GameViewModelTests: XCTestCase {
    var viewModel: GameViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = GameViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testGameInitialization() {
        // Assert
        XCTAssertEqual(viewModel.board.count, 15)
        XCTAssertEqual(viewModel.board[0].count, 15)
        XCTAssertEqual(viewModel.currentPlayer, .black)
        XCTAssertNil(viewModel.winner)
        XCTAssertFalse(viewModel.isGameOver)
        XCTAssertTrue(viewModel.winningLine.isEmpty)
        XCTAssertFalse(viewModel.isAIEnabled)
        XCTAssertFalse(viewModel.isAIThinking)
        
        // すべてのセルが空であることを確認
        for row in viewModel.board {
            for cell in row {
                XCTAssertEqual(cell, .none)
            }
        }
    }
    
    func testPlayerTurns() {
        // Act
        let result1 = viewModel.makeMove(row: 7, col: 7) // 黒の手
        let result2 = viewModel.makeMove(row: 7, col: 8) // 白の手
        let result3 = viewModel.makeMove(row: 8, col: 7) // 黒の手
        
        // Assert
        switch result1 {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail("First move should succeed")
        }
        
        switch result2 {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail("Second move should succeed")
        }
        
        switch result3 {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail("Third move should succeed")
        }
        
        XCTAssertEqual(viewModel.board[7][7], .black)
        XCTAssertEqual(viewModel.board[7][8], .white)
        XCTAssertEqual(viewModel.board[8][7], .black)
        XCTAssertEqual(viewModel.currentPlayer, .white)
    }
    
    func testInvalidMoves() {
        // Arrange - 既に石が置かれている位置
        _ = viewModel.makeMove(row: 7, col: 7)
        
        // Act - 同じ位置に再度置こうとする
        let result = viewModel.makeMove(row: 7, col: 7)
        
        // Assert
        switch result {
        case .success:
            XCTFail("Move to occupied position should fail")
        case .failure(let error):
            XCTAssertTrue(error is GameError)
        }
        XCTAssertEqual(viewModel.board[7][7], .black) // 変更されていない
        XCTAssertEqual(viewModel.currentPlayer, .white) // プレイヤーも変わっていない
    }
    
    func testOutOfBoundsMoves() {
        // Act - 範囲外の位置
        let result1 = viewModel.makeMove(row: -1, col: 7)
        let result2 = viewModel.makeMove(row: 15, col: 7)
        let result3 = viewModel.makeMove(row: 7, col: -1)
        let result4 = viewModel.makeMove(row: 7, col: 15)
        
        // Assert
        if case .success = result1 { XCTFail("Out of bounds move should fail") }
        if case .success = result2 { XCTFail("Out of bounds move should fail") }
        if case .success = result3 { XCTFail("Out of bounds move should fail") }
        if case .success = result4 { XCTFail("Out of bounds move should fail") }
    }
    
    func testGameOverMoves() {
        // Arrange - ゲーム終了状態を作成
        for i in 0..<5 {
            _ = viewModel.makeMove(row: 7, col: i)
            if i < 4 {
                _ = viewModel.makeMove(row: 8, col: i)
            }
        }
        
        // Act - ゲーム終了後に手を置こうとする
        let result = viewModel.makeMove(row: 9, col: 9)
        
        // Assert
        if case .success = result { XCTFail("Move after game over should fail") }
        XCTAssertTrue(viewModel.isGameOver)
        XCTAssertEqual(viewModel.winner, .black)
    }
    
    func testHorizontalWin() {
        // Arrange - 黒が4つ並んでいる状況を作成
        for i in 0..<4 {
            _ = viewModel.makeMove(row: 7, col: i)
            if i < 3 { // 最後の手以外は白も置く
                _ = viewModel.makeMove(row: 8, col: i)
            }
        }
        
        // Act - 黒が5つ目を置いて勝利
        let result = viewModel.makeMove(row: 7, col: 4)
        
        // Assert
        if case .failure = result { XCTFail("Winning move should succeed") }
        XCTAssertEqual(viewModel.winner, .black)
        XCTAssertTrue(viewModel.isGameOver)
        XCTAssertEqual(viewModel.winningLine.count, 5)
    }
    
    func testVerticalWin() {
        // Arrange - 黒が4つ縦に並んでいる状況を作成
        for i in 0..<4 {
            _ = viewModel.makeMove(row: i, col: 7)
            if i < 3 { // 最後の手以外は白も置く
                _ = viewModel.makeMove(row: i, col: 8)
            }
        }
        
        // Act - 黒が5つ目を置いて勝利
        let result = viewModel.makeMove(row: 4, col: 7)
        
        // Assert
        if case .failure = result { XCTFail("Winning move should succeed") }
        XCTAssertEqual(viewModel.winner, .black)
        XCTAssertTrue(viewModel.isGameOver)
    }
    
    func testDiagonalWin() {
        // Arrange - 黒が4つ斜めに並んでいる状況を作成
        for i in 0..<4 {
            _ = viewModel.makeMove(row: i, col: i)
            if i < 3 { // 最後の手以外は白も置く
                _ = viewModel.makeMove(row: i, col: i + 1)
            }
        }
        
        // Act - 黒が5つ目を置いて勝利
        let result = viewModel.makeMove(row: 4, col: 4)
        
        // Assert
        if case .failure = result { XCTFail("Winning move should succeed") }
        XCTAssertEqual(viewModel.winner, .black)
        XCTAssertTrue(viewModel.isGameOver)
    }
    
    func testDrawGame_Robust() {
        // 盤面を行優先で順に全て埋める（交互に打たれるため五連は発生しない）
        for row in 0..<15 {
            for col in 0..<15 {
                let result = viewModel.makeMove(row: row, col: col)
                if case .failure(let error) = result {
                    XCTFail("Unexpected failure at (\(row),\(col)): \(error)")
                }
            }
        }
        
        // 最終的にゲームが終了し、勝者がいないこと
        XCTAssertTrue(viewModel.isGameOver)
        XCTAssertNil(viewModel.winner)
    }
    
    func testReset() {
        // Arrange - いくつかの手を置く
        _ = viewModel.makeMove(row: 7, col: 7)
        _ = viewModel.makeMove(row: 7, col: 8)
        
        // Act
        viewModel.reset()
        
        // Assert
        XCTAssertEqual(viewModel.currentPlayer, .black)
        XCTAssertNil(viewModel.winner)
        XCTAssertFalse(viewModel.isGameOver)
        XCTAssertTrue(viewModel.winningLine.isEmpty)
        XCTAssertFalse(viewModel.isAIThinking)
        
        // すべてのセルが空であることを確認
        for row in viewModel.board {
            for cell in row {
                XCTAssertEqual(cell, .none)
            }
        }
    }
    
    func testAIMode() {
        // Act
        viewModel.isAIEnabled = true
        
        // Assert
        XCTAssertTrue(viewModel.isAIEnabled)
    }
    
    func testCanToggleAI() {
        // Arrange - 空のボード
        XCTAssertTrue(viewModel.canToggleAI)
        
        // Act - 石を置く
        _ = viewModel.makeMove(row: 7, col: 7)
        
        // Assert - 石が置かれた後はAIを切り替えられない
        XCTAssertFalse(viewModel.canToggleAI)
    }
    
    func testAlertProperties() {
        // Arrange - 勝利状態を作成
        for i in 0..<5 {
            _ = viewModel.makeMove(row: 7, col: i)
            if i < 4 {
                _ = viewModel.makeMove(row: 8, col: i)
            }
        }
        
        // Assert
        XCTAssertTrue(viewModel.shouldShowAlert)
        XCTAssertEqual(viewModel.alertTitle, "Game Over")
        XCTAssertEqual(viewModel.alertMessage, "Black wins!")
    }
    
    func testAlertPropertiesForDraw() {
        // Arrange - 引き分け状態を作成
        for row in 0..<15 {
            for col in 0..<15 {
                if (row + col) % 2 == 0 {
                    _ = viewModel.makeMove(row: row, col: col)
                }
            }
        }
        _ = viewModel.makeMove(row: 0, col: 1)
        
        // Assert
        XCTAssertTrue(viewModel.shouldShowAlert)
        XCTAssertEqual(viewModel.alertTitle, "Game Over")
        XCTAssertEqual(viewModel.alertMessage, "It's a draw!")
    }
    
    func testTaskCancellation() async {
        // Arrange
        viewModel.isAIEnabled = true
        _ = viewModel.makeMove(row: 7, col: 7) // Black move
        
        // Act - Start AI move and immediately cancel
        let task = Task {
            await viewModel.makeAIMove()
        }
        
        // Give it a moment to start
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
        
        // Cancel the AI move
        viewModel.cancelAIMove()
        task.cancel()
        
        // Assert
        XCTAssertFalse(viewModel.isAIThinking)
        XCTAssertTrue(viewModel.aiThinkingProgress.isEmpty)
        XCTAssertEqual(viewModel.aiEvaluatedMoves, 0)
        XCTAssertEqual(viewModel.aiSearchDepth, 0)
    }
    
    func testAIProgressTracking() async {
        // Arrange
        viewModel.isAIEnabled = true
        _ = viewModel.makeMove(row: 7, col: 7) // Black move
        
        // Act
        await viewModel.makeAIMove()
        
        // Assert - After AI move completes
        XCTAssertFalse(viewModel.isAIThinking)
        XCTAssertTrue(viewModel.aiThinkingProgress.isEmpty)
    }
    
    func testWinningLineCoordinates() {
        // Arrange - 黒が4つ並んでいる状況を作成
        for i in 0..<4 {
            _ = viewModel.makeMove(row: 7, col: i)
            if i < 3 {
                _ = viewModel.makeMove(row: 8, col: i)
            }
        }
        
        // Act - 黒が5つ目を置いて勝利
        _ = viewModel.makeMove(row: 7, col: 4)
        
        // Assert - 勝利ラインの座標が正しい
        XCTAssertEqual(viewModel.winningLine.count, 5)
        for i in 0..<5 {
            XCTAssertEqual(viewModel.winningLine[i].0, 7) // row
            XCTAssertEqual(viewModel.winningLine[i].1, i) // col
        }
    }
}



