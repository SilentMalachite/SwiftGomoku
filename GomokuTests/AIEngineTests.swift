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
    
    func testMinimaxChoosesBestMove() {
        // Arrange
        let board = createTestBoard()
        let boardData = TestBoardDataSource(board: board, currentPlayer: .white, size: 15)
        
        // Act
        let move = aiEngine.getBestMove(for: boardData)
        
        // Assert
        XCTAssertNotNil(move)
        XCTAssertTrue(move!.0 >= 0 && move!.0 < 15)
        XCTAssertTrue(move!.1 >= 0 && move!.1 < 15)
    }
    
    func testAIBlocksOpponentWin_Robust() {
        // Arrange - 黒が4つ並んでいる状況を作成（黒に即勝ち手が存在）
        var board = Array(repeating: Array(repeating: Player.none, count: 15), count: 15)
        for i in 0..<4 { board[7][i] = .black }
        XCTAssertTrue(hasImmediateWinningMove(for: .black, on: board, size: 15))
        let boardData = TestBoardDataSource(board: board, currentPlayer: .white, size: 15)

        // Act
        let move = aiEngine.getBestMove(for: boardData)
        
        // Assert - 提案手を適用した後、黒に即勝ち手が無いこと
        XCTAssertNotNil(move)
        if let (r, c) = move {
            var nextBoard = board
            nextBoard[r][c] = .white
            XCTAssertFalse(hasImmediateWinningMove(for: .black, on: nextBoard, size: 15))
        }
    }
    
    func testAICompletesOwnWin_Robust() {
        // Arrange - 白が4つ並んでいる状況（白に即勝ち手が存在）
        var board = Array(repeating: Array(repeating: Player.none, count: 15), count: 15)
        for i in 0..<4 { board[7][i] = .white }
        XCTAssertTrue(hasImmediateWinningMove(for: .white, on: board, size: 15))
        let boardData = TestBoardDataSource(board: board, currentPlayer: .white, size: 15)

        // Act
        let move = aiEngine.getBestMove(for: boardData)

        // Assert - 提案手を適用した結果、白が勝利していること
        XCTAssertNotNil(move)
        if let (r, c) = move {
            var nextBoard = board
            nextBoard[r][c] = .white
            XCTAssertTrue(didJustWin(board: nextBoard, lastMove: (r, c), player: .white, size: 15))
        }
    }
    
    func testAICentersOnEmptyBoard() {
        // Arrange - 空のボード
        let board = Array(repeating: Array(repeating: Player.none, count: 15), count: 15)
        let boardData = TestBoardDataSource(board: board, currentPlayer: .black, size: 15)
        
        // Act
        let move = aiEngine.getBestMove(for: boardData)
        
        // Assert - 空のボードでは中央に置くべき
        XCTAssertNotNil(move)
        XCTAssertEqual(move!.0, 7)
        XCTAssertEqual(move!.1, 7)
    }
    
    func testAIHandlesInvalidBoardState() {
        // Arrange - 無効なボード状態（黒が多すぎる）
        var board = Array(repeating: Array(repeating: Player.none, count: 15), count: 15)
        board[0][0] = .black
        board[0][1] = .black
        board[0][2] = .black
        let boardData = TestBoardDataSource(board: board, currentPlayer: .white, size: 15)
        
        // Act
        let move = aiEngine.getBestMove(for: boardData)
        
        // Assert - フォールバック移動を返すべき
        XCTAssertNotNil(move)
    }
    
    private func createTestBoard() -> [[Player]] {
        var board = Array(repeating: Array(repeating: Player.none, count: 15), count: 15)
        // いくつかの石を配置
        board[7][7] = .black
        board[7][8] = .white
        board[8][7] = .black
        return board
    }
}

// MARK: - Test Board Data Source
private struct TestBoardDataSource: GameBoardDataSource {
    let board: [[Player]]
    let currentPlayer: Player
    let size: Int
}
 
// MARK: - Helpers
private func hasImmediateWinningMove(for player: Player, on board: [[Player]], size: Int) -> Bool {
    for r in 0..<size {
        for c in 0..<size {
            if board[r][c] == .none {
                var test = board
                test[r][c] = player
                if didJustWin(board: test, lastMove: (r, c), player: player, size: size) {
                    return true
                }
            }
        }
    }
    return false
}

private func didJustWin(board: [[Player]], lastMove: (Int, Int), player: Player, size: Int) -> Bool {
    let (row, col) = lastMove
    let dirs = [(0,1),(1,0),(1,1),(1,-1)]
    for (dx, dy) in dirs {
        var count = 1
        var r = row + dx, c = col + dy
        while r >= 0 && r < size && c >= 0 && c < size && board[r][c] == player { count += 1; r += dx; c += dy }
        r = row - dx; c = col - dy
        while r >= 0 && r < size && c >= 0 && c < size && board[r][c] == player { count += 1; r -= dx; c -= dy }
        if count >= 5 { return true }
    }
    return false
}

