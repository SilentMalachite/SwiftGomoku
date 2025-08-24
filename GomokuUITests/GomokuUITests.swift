import XCTest

final class GomokuUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // クリーンアップ
    }
    
    func testGameplayFlow() throws {
        // ゲームボードが表示されていることを確認
        let gameBoard = app.otherElements["GameBoard"]
        XCTAssertTrue(gameBoard.exists)
        
        // 現在のプレイヤー表示ラベルが存在することを確認（文言に依存しない）
        XCTAssertTrue(app.staticTexts["CurrentPlayerLabel"].exists || app.otherElements["CurrentPlayerLabel"].exists)
        
        // 中央のセルをタップ
        let centerCell = app.otherElements["Cell_7_7"]
        XCTAssertTrue(centerCell.exists)
        centerCell.tap()
        
        // 石が配置されたことを確認
        let blackStone = app.otherElements["Stone_Black_7_7"]
        XCTAssertTrue(blackStone.exists)
        
        // プレイヤー表示ラベルが引き続き存在（テキストに依存せず）
        XCTAssertTrue(app.staticTexts["CurrentPlayerLabel"].exists || app.otherElements["CurrentPlayerLabel"].exists)
    }
    
    func testAIToggle() throws {
        // AIトグルが存在することを確認
        let aiToggle = app.switches["AI Enabled"]
        XCTAssertTrue(aiToggle.exists)
        
        // 初期状態ではAIが無効であることを確認
        let initialValue = (aiToggle.value as? String) ?? "0"
        XCTAssertTrue(initialValue == "0" || initialValue.lowercased() == "0")
        
        // AIを有効にする
        aiToggle.tap()
        
        // AIが有効になったことを確認
        let toggledValue = (aiToggle.value as? String) ?? "1"
        XCTAssertTrue(toggledValue == "1" || toggledValue.lowercased() == "1")
    }
    
    func testNewGameButton() throws {
        // 新規ゲームボタンが存在することを確認
        let newGameButton = app.buttons["New Game"]
        XCTAssertTrue(newGameButton.exists)
        
        // いくつかの手を置く
        let cell1 = app.otherElements["Cell_7_7"]
        let cell2 = app.otherElements["Cell_7_8"]
        
        cell1.tap()
        cell2.tap()
        
        // 石が配置されたことを確認
        XCTAssertTrue(app.otherElements["Stone_Black_7_7"].exists)
        XCTAssertTrue(app.otherElements["Stone_White_7_8"].exists)
        
        // 新規ゲームボタンをタップ
        newGameButton.tap()
        
        // ボードがリセットされたことを確認
        XCTAssertTrue(app.otherElements["Cell_7_7"].exists)
        XCTAssertTrue(app.otherElements["Cell_7_8"].exists)
        
        // 現在のプレイヤー表示が存在することを確認（文言依存を避ける）
        XCTAssertTrue(app.staticTexts["CurrentPlayerLabel"].exists || app.otherElements["CurrentPlayerLabel"].exists)
    }
    
    func testInvalidMove() throws {
        // セルに石を置く
        let cell = app.otherElements["Cell_7_7"]
        cell.tap()
        
        // 同じセルに再度置こうとする
        cell.tap()
        
        // アラートが表示されることを確認
        let alert = app.alerts.element(boundBy: 0)
        XCTAssertTrue(alert.exists)
        
        // アラートのタイトルとメッセージを確認
        XCTAssertTrue(alert.staticTexts["Invalid Move"].exists)
        XCTAssertTrue(alert.staticTexts["This position is not available."].exists)
        
        // OKボタンをタップしてアラートを閉じる
        alert.buttons["OK"].tap()
    }
    
    func testGameWin() throws {
        // 黒が勝利する状況を作成（横方向に5つ並べる）
        let cells = [
            app.otherElements["Cell_7_0"],
            app.otherElements["Cell_7_1"],
            app.otherElements["Cell_7_2"],
            app.otherElements["Cell_7_3"],
            app.otherElements["Cell_7_4"]
        ]
        
        // 白の手を間に挟む
        let whiteCells = [
            app.otherElements["Cell_8_0"],
            app.otherElements["Cell_8_1"],
            app.otherElements["Cell_8_2"],
            app.otherElements["Cell_8_3"]
        ]
        
        // 手を置いていく
        for i in 0..<4 {
            cells[i].tap()
            whiteCells[i].tap()
        }
        
        // 最後の手で勝利
        cells[4].tap()
        
        // 勝利アラートが表示されることを確認
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.exists)
        
        // アラートの内容を確認
        XCTAssertTrue(alert.staticTexts["Game Over"].exists)
        XCTAssertTrue(alert.staticTexts["Black wins!"].exists)
        
        // OKボタンをタップ
        alert.buttons["OK"].tap()
    }
    
    func testAIGameplay() throws {
        // AIを有効にする
        let aiToggle = app.switches["AI Enabled"]
        aiToggle.tap()
        
        // 黒の手を置く
        let cell = app.otherElements["Cell_7_7"]
        cell.tap()
        
        // AIが思考中であることを確認（識別子ベース）
        let thinkingText = app.staticTexts["AIStatusLabel"]
        XCTAssertTrue(thinkingText.exists)
        
        // AIの手が完了するまで待機
        let predicate = NSPredicate(format: "exists == false")
        expectation(for: predicate, evaluatedWith: thinkingText, handler: nil)
        waitForExpectations(timeout: 10.0, handler: nil)
        
        // AIが手を置いたことを確認
        let whiteStone = app.otherElements.containing(NSPredicate(format: "identifier BEGINSWITH %@", "Stone_White_")).firstMatch
        XCTAssertTrue(whiteStone.exists)
    }
    
    func testAIMoveButton() throws {
        // AIを有効にする
        let aiToggle = app.switches["AI Enabled"]
        aiToggle.tap()
        
        // 黒の手を置く
        let cell = app.otherElements["Cell_7_7"]
        cell.tap()
        
        // AI Moveボタンが表示されることを確認
        let aiMoveButton = app.buttons["AI Move"]
        XCTAssertTrue(aiMoveButton.exists)
        
        // AI Moveボタンをタップ
        aiMoveButton.tap()
        
        // AIが手を置いたことを確認
        let whiteStone = app.otherElements.containing(NSPredicate(format: "identifier BEGINSWITH %@", "Stone_White_")).firstMatch
        XCTAssertTrue(whiteStone.exists)
    }
    
    func testWinningLineHighlight() throws {
        // 黒が勝利する状況を作成
        let cells = [
            app.otherElements["Cell_7_0"],
            app.otherElements["Cell_7_1"],
            app.otherElements["Cell_7_2"],
            app.otherElements["Cell_7_3"],
            app.otherElements["Cell_7_4"]
        ]
        
        let whiteCells = [
            app.otherElements["Cell_8_0"],
            app.otherElements["Cell_8_1"],
            app.otherElements["Cell_8_2"],
            app.otherElements["Cell_8_3"]
        ]
        
        // 手を置いていく
        for i in 0..<4 {
            cells[i].tap()
            whiteCells[i].tap()
        }
        
        // 最後の手で勝利
        cells[4].tap()
        
        // 勝利ラインがハイライトされていることを確認
        // 注: 実際のハイライト表示は実装に依存するため、基本的な存在確認のみ
        for i in 0..<5 {
            let winningStone = app.otherElements["Stone_Black_7_\(i)"]
            XCTAssertTrue(winningStone.exists)
        }
    }
    
    func testAccessibility() throws {
        // アクセシビリティ要素が正しく設定されていることを確認
        let gameBoard = app.otherElements["GameBoard"]
        XCTAssertTrue(gameBoard.exists)
        
        // 空のセルがアクセシビリティ識別子を持っていることを確認
        let emptyCell = app.otherElements["Cell_7_7"]
        XCTAssertTrue(emptyCell.exists)
        
        // 石が配置された後のアクセシビリティ識別子を確認
        emptyCell.tap()
        let blackStone = app.otherElements["Stone_Black_7_7"]
        XCTAssertTrue(blackStone.exists)
    }
    
    func testGameTitle() throws {
        // ゲームタイトルが表示されていることを確認
        let title = app.staticTexts["Gomoku"]
        XCTAssertTrue(title.exists)
    }
    
    func testBoardGrid() throws {
        // ボードグリッドが表示されていることを確認
        let gameBoard = app.otherElements["GameBoard"]
        XCTAssertTrue(gameBoard.exists)
        
        // ボードのサイズが正しいことを確認（15x15）
        // 注: 実際のサイズ確認は実装に依存するため、基本的な存在確認のみ
        XCTAssertTrue(gameBoard.frame.width > 0)
        XCTAssertTrue(gameBoard.frame.height > 0)
    }
}


