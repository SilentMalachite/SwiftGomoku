# Swift 五目並べ (Gomoku)

Swift と SwiftUI で構築されたネイティブ iOS 五目並べアプリケーション。

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2016.0%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 概要

五目並べは、2人のプレイヤーが15×15のグリッド上に交互に石を置いていく伝統的なボードゲームです。先に5つの石を一列（横、縦、斜め）に並べたプレイヤーが勝利します。

このアプリの特徴：
- SwiftUI を使用したクリーンなネイティブ iOS インターフェース
- 2人プレイモード
- AI対戦オプション
- リアルタイム勝利判定
- 勝利ラインのハイライト表示
- レスポンシブなボードデザイン

## 機能

- **伝統的なゲームプレイ**: 標準的な五目並べルールに従った15×15のボード
- **AI対戦**: AIモードをオンにしてコンピューター（白石）と対戦
- **視覚的フィードバック**: 勝利した石は赤い枠線でハイライト表示
- **クリーンなUI**: 伝統的な木目調のボード外観を持つミニマリストデザイン
- **すぐにプレイ可能**: Xcode以外のインストールは不要

## 必要環境

- iOS 16.0 以降
- Xcode 14.0 以降
- Swift 5.0 以降

## インストール

1. リポジトリをクローン：
```bash
git clone https://github.com/SilentMalachite/Swift-Gomoku.git
cd Swift-Gomoku
```

2. Xcode でプロジェクトを開く：
```bash
open Gomoku.xcodeproj
```

3. ビルドして実行 (⌘R)

## プレイ方法

1. **ゲーム開始**: アプリを起動すると自動的に新しいゲームが始まります
2. **石を置く**: 空いている交点をクリックして石を配置
   - 黒が常に先手です
   - プレイヤーは交互にターンを行います
3. **勝利条件**: 最初に5つの石を一列に並べる
4. **AIモード**: 「AI対戦」をオンにしてコンピューターと対戦
5. **新規ゲーム**: 「新規ゲーム」をクリックしてボードをリセット

## プロジェクト構造

```
Swift-Gomoku/
├── Gomoku/
│   ├── GomokuApp.swift       # メインアプリエントリーポイント
│   ├── ContentView.swift     # メインゲームUIビュー
│   ├── GameViewModel.swift   # ゲーム状態を管理するMVVMビューモデル
│   ├── GameBoard.swift       # レガシーゲームボードモデル
│   ├── AIEngine.swift        # ミニマックスアルゴリズムを使用したAIロジック
│   ├── AIUtilities.swift     # AIヘルパー構造体と定数
│   └── Gomoku.entitlements   # アプリ権限
├── GomokuTests/              # ユニットテスト
│   ├── AIEngineTests.swift
│   ├── BoardEvaluatorTests.swift
│   ├── GameBoardTests.swift
│   ├── GameStateCheckerTests.swift
│   ├── GameViewModelTests.swift
│   └── PatternAnalyzerTests.swift
├── GomokuUITests/            # UIテスト
│   ├── GomokuUITests.swift
│   └── GomokuUITestsLaunchTests.swift
├── Gomoku.xcodeproj/         # Xcodeプロジェクトファイル
├── .gitignore                # Git除外ルール
├── LICENSE                   # MITライセンス
├── CONTRIBUTING.md           # コントリビューションガイドライン
├── README_TEST_SETUP.md      # テストセットアップ手順
└── README.md                 # このファイル
```

## アーキテクチャ

このアプリはMVVM（Model-View-ViewModel）パターンに従っています：

- **Model**: `Player` 列挙型とボード配列で表現されるゲーム状態
- **View**: `ContentView` がSwiftUIインターフェースを提供
- **ViewModel**: `GameViewModel` がゲームロジック、状態管理、AIとの調整を行う
- **AIロジック**: `AIEngine` がアルファベータ枝刈りを使用したミニマックスアルゴリズムを実装
- **ユーティリティ**: `AIUtilities` に定数、パターン分析器、ボード評価器を含む

## AI実装

AIは高度なミニマックスアルゴリズムを使用：
- **ミニマックス探索**: アルファベータ枝刈りで最大4手先まで先読み
- **パターン分析**: 攻撃的および防御的な手のためのボードパターン評価
- **位置スコアリング**: 以下に基づく動的スコアリング：
  - 勝利条件（5つ並び）
  - 4つ並びパターン（開放/閉鎖）
  - 3つ並びパターン
  - 中央制御ボーナス
- **手の最適化**: 探索半径内の関連する手のみを考慮
- **パフォーマンス**: レスポンシブなUIを維持するための非同期実行

## テスト

プロジェクトには主要なコンポーネントすべての包括的なユニットテストが含まれています：

- **AIEngineTests**: AI移動生成とミニマックスアルゴリズムのテスト
- **BoardEvaluatorTests**: ボード評価ロジックのテスト
- **GameBoardTests**: ゲームボード状態管理のテスト
- **GameStateCheckerTests**: 勝利条件検出のテスト
- **GameViewModelTests**: ゲームフローと状態遷移のテスト
- **PatternAnalyzerTests**: パターン認識アルゴリズムのテスト

テストの実行：
```bash
# すべてのテストを実行
xcodebuild test -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15'

# または Xcode で
# Cmd+U を押す
```

詳細なテストセットアップ手順については、[README_TEST_SETUP.md](README_TEST_SETUP.md) を参照してください。

## コントリビューション

コントリビューションを歓迎します！詳細については[コントリビューションガイドライン](CONTRIBUTING.md)を参照してください：

- バグレポートの提出方法
- 新機能の提案方法
- 開発環境のセットアップ方法
- コーディング標準とコミットメッセージ規約
- プルリクエストプロセス

大きな変更については、まず issue を開いて変更内容について議論してください。

## 今後の機能拡張

- [ ] AI難易度レベル（簡単、普通、難しい）
- [ ] ゲーム履歴とリプレイ機能
- [ ] オンライン対戦サポート
- [ ] 効果音と触覚フィードバック
- [ ] 複数のテーマとボードカスタマイズ
- [ ] トーナメントモード（ブラケット付き）
- [ ] 統計追跡とプレイヤープロファイル
- [ ] Game Center 統合
- [ ] iPad 最適化インターフェース
- [ ] 元に戻す/やり直し機能
- [ ] 競技プレイ用の時間制限
- [ ] 初心者向けチュートリアルモード

## サポート

問題が発生した場合や質問がある場合：

1. [Issues](https://github.com/SilentMalachite/Swift-Gomoku/issues) ページを確認
2. [コントリビューションガイドライン](CONTRIBUTING.md)を読む
3. 詳細な情報を含む新しい issue を作成

---

Swift と SwiftUI を使用して ❤️ を込めて作成