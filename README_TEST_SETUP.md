# Swift 五目並べのテストセットアップガイド

このガイドでは、Swift 五目並べプロジェクトでテストをセットアップして実行するための包括的な手順を提供します。

## 概要

Swift 五目並べには包括的なテストスイートが含まれています：
- **ユニットテスト**: 個々のコンポーネントとゲームロジックのテスト
- **UIテスト**: ユーザーインターフェースの相互作用とワークフローのテスト

## 前提条件

- Xcode 14.0 以降
- iOS シミュレーター（iOS 16.0+）
- Xcode のコマンドラインツール

## クイックスタート

### Xcode でのテスト実行

1. Xcode でプロジェクトを開く：
   ```bash
   open Gomoku.xcodeproj
   ```

2. すべてのテストを実行：
   - `Cmd+U` を押すか
   - メニューから `Product → Test` を選択

3. 特定のテストクラスを実行：
   - テストナビゲーター（`Cmd+6`）を開く
   - 任意のテストクラスまたはメソッドの横にある再生ボタンをクリック

### コマンドラインからのテスト実行

```bash
# すべてのテストを実行
xcodebuild test -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15'

# ユニットテストのみ実行
xcodebuild test -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:GomokuTests

# UIテストのみ実行
xcodebuild test -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:GomokuUITests

# カバレッジレポート付きで実行
xcodebuild test -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15' -enableCodeCoverage YES
```

## テスト構造

### ユニットテスト（`GomokuTests/`）

- **AIEngineTests.swift**: AI移動生成とミニマックスアルゴリズムの基本テスト
  - `testMinimaxChoosesBestMove()`
  - `testAIBlocksOpponentWin_Robust()`
  - `testAICompletesOwnWin_Robust()`
  - `testAICentersOnEmptyBoard()`
  - `testAIHandlesInvalidBoardState()`
  
- **GameBoardTests.swift**: ゲームボード状態管理のテスト
  - `testInitialBoardState()`
  - `testValidMovePlacement()`
  - `testInvalidMoves()`
  - `testOutOfBoundsMoves()`
  - `testSwitchPlayer()`
  - `testHorizontalWinDetection()` ほか
  
- **GameViewModelTests.swift**: ゲームフローと状態遷移のテスト
  - `testGameInitialization()`
  - `testPlayerTurns()`
  - `testInvalidMoves()`
  - `testGameOverMoves()`
  - `testHorizontalWin()` ほか

### UIテスト（`GomokuUITests/`）

- **GomokuUITests.swift**: メインUI相互作用テスト
  - `testGameplayFlow()`
  - `testAIToggle()`
  - `testNewGameButton()`
  - `testInvalidMove()` ほか
  
- **GomokuUITestsLaunchTests.swift**: アプリ起動とパフォーマンステスト

## テストターゲットの設定（まだ設定されていない場合）

Xcode プロジェクトにテストターゲットがない場合：

### ユニットテストターゲットの追加

1. Xcode で：`File → New → Target`
2. `iOS → Unit Testing Bundle` を選択
3. 設定：
   - Product Name: `GomokuTests`
   - Team: チームを選択
   - Target to be Tested: `Gomoku`
4. `Finish` をクリック

### UIテストターゲットの追加

1. Xcode で：`File → New → Target`
2. `iOS → UI Testing Bundle` を選択
3. 設定：
   - Product Name: `GomokuUITests`
   - Team: チームを選択
   - Target to be Tested: `Gomoku`
4. `Finish` をクリック

### 既存のテストファイルのリンク

1. プロジェクトナビゲーターでテストファイルを選択
2. ファイルインスペクター（右パネル）を開く
3. 「Target Membership」で適切なテストターゲットにチェック

## UIテスト用のアクセシビリティ識別子

このプロジェクトでは既に以下の識別子を使用しています（UIテストと一致）：

```swift
// ゲームボード
.accessibilityIdentifier("GameBoard")

// 個々のセル（空のとき）
.accessibilityIdentifier("Cell_\(row)_\(col)")

// 石（配置済みのとき）
.accessibilityIdentifier("Stone_\(player.rawValue)_\(row)_\(col)")

// ボタン/トグル
Toggle: .accessibilityIdentifier("AI Enabled")
Button(新規ゲーム): .accessibilityIdentifier("New Game")
```

## 新しいテストの作成

### ユニットテストテンプレート

```swift
import XCTest
@testable import Gomoku

final class YourComponentTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // セットアップコード
    }
    
    override func tearDown() {
        // クリーンアップコード
        super.tearDown()
    }
    
    func testYourFeature() {
        // Arrange（準備）
        let component = YourComponent()
        
        // Act（実行）
        let result = component.performAction()
        
        // Assert（検証）
        XCTAssertEqual(result, expectedValue)
    }
}
```

### UIテストテンプレート

```swift
import XCTest

final class YourUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testYourUIFlow() throws {
        // 要素を見つける
        let button = app.buttons["ButtonIdentifier"]
        
        // 相互作用
        button.tap()
        
        // 検証
        XCTAssertTrue(app.staticTexts["Expected Text"].exists)
    }
}
```

## テストカバレッジ

Xcode でテストカバレッジを表示するには：

1. カバレッジを有効にしてテストを実行（`Cmd+U`）
2. レポートナビゲーター（`Cmd+9`）を開く
3. 最新のテスト実行を選択
4. 「Coverage」タブをクリック

コマンドラインからカバレッジレポートを生成するには：

```bash
# カバレッジ付きでテストを実行
xcodebuild test -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15' -enableCodeCoverage YES

# カバレッジレポートを生成
xcrun llvm-cov report \
    -instr-profile=$(find . -name "*.profdata") \
    $(find . -name "Gomoku.app" -type f)
```

## 継続的インテグレーション

CI/CD パイプライン用のコマンド：

```bash
# ビルドフォルダをクリーン
xcodebuild clean -scheme Gomoku

# テストなしでビルド
xcodebuild build-for-testing -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15'

# ビルドなしでテストを実行
xcodebuild test-without-building -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15'
```

## トラブルシューティング

### よくある問題

1. **「No such module 'Gomoku'」エラー**
   - テストターゲットが適切なターゲット依存関係を持っていることを確認
   - ビルドフォルダをクリーン：`Cmd+Shift+K`
   - 再ビルド：`Cmd+B`

2. **UIテストが要素を見つけられない**
   - アクセシビリティ識別子が設定されていることを確認
   - 非同期操作のために待機条件を追加
   - シミュレーターがスローアニメーションモードでないことを確認

3. **テストナビゲーターにテストが表示されない**
   - テストファイルがテストターゲットのメンバーであることを確認
   - テストクラスは `XCTestCase` を継承する必要がある
   - テストメソッドは `test` で始まる必要がある

### デバッグのヒント

- UI階層をデバッグするには `XCTAssertTrue(app.debugDescription.contains("text"))` を使用
- テストにブレークポイントを追加して状態を検査
- 完全なUIツリーを見るには `print(app.debugDescription)` を使用
- カバレッジレポートのためにスキーム設定で「Gather Coverage Data」を有効化

## ベストプラクティス

1. **テストを高速に保つ**: 高コストな操作をモック
2. **一つのことをテスト**: 各テストは単一の動作を検証すべき
3. **説明的な名前を使用**: テスト名は何をテストしているかを説明すべき
4. **独立性を維持**: テストは互いに依存すべきではない
5. **クリーンアップ**: `setUp()` と `tearDown()` を適切に使用
6. **エッジケースをテスト**: ハッピーパスだけでなく

## リソース

- [Apple のテストドキュメント](https://developer.apple.com/documentation/xctest)
- [UIテストのベストプラクティス](https://developer.apple.com/videos/play/wwdc2015/406/)
- [XCTest API リファレンス](https://developer.apple.com/documentation/xctest)

---

プロジェクトへのコントリビューションについての詳細は、[CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。
