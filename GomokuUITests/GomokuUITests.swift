import XCTest

final class GomokuUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    
    private func tapCell(row: Int, col: Int) {
        let cell = app.otherElements["Cell_\(row)_\(col)"]
        if cell.exists {
            cell.tap()
        }
    }
    
    private func waitForStone(player: String, row: Int, col: Int, timeout: TimeInterval = 2) -> Bool {
        let stone = app.otherElements["Stone_\(player)_\(row)_\(col)"]
        return stone.waitForExistence(timeout: timeout)
    }
    
    // MARK: - UI Element Tests
    
    func testGameBoardExists() {
        let gameBoard = app.otherElements["GameBoard"]
        XCTAssertTrue(gameBoard.exists)
    }
    
    func testNewGameButtonExists() {
        let newGameButton = app.buttons["New Game"]
        XCTAssertTrue(newGameButton.exists)
    }
    
    func testAIToggleExists() {
        let aiToggle = app.switches["AI Enabled"]
        XCTAssertTrue(aiToggle.exists)
    }
    
    // MARK: - Game Play Tests
    
    func testMakingMove() {
        // Tap center cell
        tapCell(row: 7, col: 7)
        
        // Verify black stone appears
        XCTAssertTrue(waitForStone(player: "Black", row: 7, col: 7))
    }
    
    func testNewGameResetsBoard() {
        // Make a move
        tapCell(row: 7, col: 7)
        XCTAssertTrue(waitForStone(player: "Black", row: 7, col: 7))
        
        // Reset game
        let newGameButton = app.buttons["New Game"]
        newGameButton.tap()
        
        // Verify stone is removed
        let blackStone = app.otherElements["Stone_Black_7_7"]
        XCTAssertFalse(blackStone.exists)
        
        // Verify cell is clickable again
        let cell = app.otherElements["Cell_7_7"]
        XCTAssertTrue(cell.exists)
    }
    
    func testWinConditionShowsWinner() {
        // Create winning condition for black (horizontal line)
        for i in 0..<5 {
            // Black moves
            tapCell(row: 7, col: i)
            
            // White moves (if not last move)
            if i < 4 {
                tapCell(row: 8, col: i)
            }
        }
        
        // Verify winner text appears
        let winnerText = app.staticTexts["Winner: Black"]
        XCTAssertTrue(winnerText.waitForExistence(timeout: 2))
    }
    
    // MARK: - AI Tests
    
    func testAIToggleDisabledAfterMove() {
        let aiToggle = app.switches["AI Enabled"]
        XCTAssertTrue(aiToggle.isEnabled)
        
        // Make a move
        tapCell(row: 7, col: 7)
        
        // Verify toggle is disabled
        XCTAssertFalse(aiToggle.isEnabled)
    }
    
    func testAIMovesAutomatically() {
        // Enable AI
        let aiToggle = app.switches["AI Enabled"]
        aiToggle.tap()
        
        // Black makes first move
        tapCell(row: 7, col: 7)
        
        // Wait for AI (white) to make a move
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true"),
            object: app.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH 'Stone_White_'")).firstMatch
        )
        
        wait(for: [expectation], timeout: 3)
    }
    
    func testMultipleMoves() {
        // Test alternating moves
        tapCell(row: 7, col: 7)  // Black
        XCTAssertTrue(waitForStone(player: "Black", row: 7, col: 7))
        
        tapCell(row: 8, col: 8)  // White
        XCTAssertTrue(waitForStone(player: "White", row: 8, col: 8))
        
        tapCell(row: 7, col: 8)  // Black
        XCTAssertTrue(waitForStone(player: "Black", row: 7, col: 8))
    }
    
    func testInvalidMoveOnOccupiedCell() {
        // Make first move
        tapCell(row: 7, col: 7)
        XCTAssertTrue(waitForStone(player: "Black", row: 7, col: 7))
        
        // Try to tap same cell again
        tapCell(row: 7, col: 7)
        
        // Verify alert appears
        let alert = app.alerts["Invalid Move"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))
        
        // Dismiss alert
        alert.buttons["OK"].tap()
    }
    
    func testAIButtonAppearsWhenEnabled() {
        // Enable AI
        let aiToggle = app.switches["AI Enabled"]
        aiToggle.tap()
        
        // Make black move
        tapCell(row: 7, col: 7)
        
        // Check if AI Move button appears for white's turn
        let aiMoveButton = app.buttons["AI Move"]
        XCTAssertTrue(aiMoveButton.waitForExistence(timeout: 2))
    }
}