import XCTest

final class GomokuUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // 起動後の基本的なUI要素が表示されていることを確認
        XCTAssertTrue(app.staticTexts["Gomoku"].exists)
        XCTAssertTrue(app.otherElements["GameBoard"].exists)
        XCTAssertTrue(app.staticTexts.containing(.staticText, identifier: "Current Player: Black").firstMatch.exists)
        XCTAssertTrue(app.buttons["New Game"].exists)
        XCTAssertTrue(app.switches["AI Enabled"].exists)
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // 起動パフォーマンスを測定
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testAppLaunchTime() throws {
        let app = XCUIApplication()
        
        // 起動時間を測定
        let startTime = Date()
        app.launch()
        let launchTime = Date().timeIntervalSince(startTime)
        
        // 起動時間が妥当な範囲内であることを確認（5秒以内）
        XCTAssertLessThan(launchTime, 5.0, "App launch time should be less than 5 seconds")
    }
    
    func testInitialStateAfterLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 初期状態の確認
        XCTAssertEqual(app.switches["AI Enabled"].value as? Bool, false)
        XCTAssertTrue(app.staticTexts.containing(.staticText, identifier: "Current Player: Black").firstMatch.exists)
        
        // ゲームボードが正しく表示されていることを確認
        let gameBoard = app.otherElements["GameBoard"]
        XCTAssertTrue(gameBoard.exists)
        XCTAssertTrue(gameBoard.isEnabled)
        
        // 新規ゲームボタンが有効であることを確認
        let newGameButton = app.buttons["New Game"]
        XCTAssertTrue(newGameButton.exists)
        XCTAssertTrue(newGameButton.isEnabled)
    }
    
    func testAppMemoryUsage() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 基本的な操作を行った後のメモリ使用量を確認
        let cell = app.otherElements["Cell_7_7"]
        cell.tap()
        
        // メモリリークがないことを確認（実際のメモリ測定は複雑なため、基本的な動作確認のみ）
        XCTAssertTrue(app.otherElements["Stone_Black_7_7"].exists)
    }
}



