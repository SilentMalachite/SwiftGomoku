# Swift 五目並べ (Gomoku)

Swift と SwiftUI で構築されたネイティブ iOS 五目並べアプリケーション。

![Swift](https://img.shields.io/badge/Swift-5.7-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2016.0%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
[![iOS Build & Test](https://github.com/SilentMalachite/SwiftGomoku/actions/workflows/ci.yml/badge.svg)](https://github.com/SilentMalachite/SwiftGomoku/actions/workflows/ci.yml)

## 概要

五目並べは、2人のプレイヤーが15×15のグリッド上に交互に石を置いていく伝統的なボードゲームです。先に5つの石を一列（横、縦、斜め）に並べたプレイヤーが勝利します。

このアプリの特徴：
- SwiftUI を使用したクリーンなネイティブ iOS インターフェース
- 2人プレイモード
- AI対戦オプション（ミニマックスアルゴリズム）
- リアルタイム勝利判定
- 勝利ラインの強化されたビジュアルフィードバック（アニメーション付き）
- レスポンシブなボードデザイン
- 完全なアクセシビリティサポート（VoiceOver対応）
 - ローカライズ（英語/日本語）対応、UIテスト向けの安定識別子

## 実装済み機能

### ゲームプレイ
- ✅ **伝統的なゲームプレイ**: 標準的な五目並べルールに従った15×15のボード
- ✅ **AI対戦**: AIモードをオンにしてコンピューター（白石）と対戦
- ✅ **視覚的フィードバック**: 勝利した石のアニメーション付きハイライト表示
- ✅ **クリーンなUI**: 伝統的な木目調のボード外観を持つミニマリストデザイン
- ✅ **すぐにプレイ可能**: Xcode以外のインストールは不要

### パフォーマンス & UX
- ✅ **非同期AI計算**: UIをブロックしない非同期タスク処理
- ✅ **タスクキャンセレーション**: AI計算の適切なキャンセル処理
- ✅ **進行状況表示**: AI思考中の詳細な進行状況とステータス表示
- ✅ **レスポンシブUI**: スムーズなユーザー体験のための最適化

### アクセシビリティ
- ✅ **VoiceOverサポート**: 完全な音声読み上げ対応
- ✅ **詳細なラベル**: 各UI要素に適切なアクセシビリティラベル
- ✅ **ヒントとアナウンス**: ゲーム状態変更時の自動アナウンス
- ✅ **アクセシビリティトレイト**: 適切なUI要素の役割指定

## 必要環境

- iOS 16.0 以降
- Xcode 14.0 以降
- Swift 5.7 以降

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
2. **石を置く**: 空いている交点をタップして石を配置
   - 黒が常に先手です
   - プレイヤーは交互にターンを行います
3. **勝利条件**: 最初に5つの石を一列に並べる
4. **AIモード**: 「AI Opponent」をオンにしてコンピューターと対戦
5. **新規ゲーム**: 「New Game」をタップしてボードをリセット

## プロジェクト構造

```
Swift-Gomoku/
├── Gomoku/
│   ├── GomokuApp.swift       # メインアプリエントリーポイント
│   ├── ContentView.swift     # メインゲームUIビュー（アクセシビリティ実装含む）
│   ├── GameViewModel.swift   # ゲーム状態管理とタスク管理
│   ├── GameBoard.swift       # ゲームボードモデル
│   ├── AIEngine.swift        # ミニマックスアルゴリズムを使用したAIロジック
│   ├── AIEvaluator.swift     # ボード評価とパターン認識
│   ├── Base.lproj/Localizable.strings  # 英語(ベース)文言
│   └── ja.lproj/Localizable.strings    # 日本語文言
├── GomokuTests/              # ユニットテスト
├── GomokuUITests/            # UIテスト
├── LICENSE                   # MITライセンス
├── CONTRIBUTING.md           # コントリビューションガイドライン
├── README_TEST_SETUP.md      # テストセットアップ手順
└── README.md                 # このファイル
```

## アーキテクチャ

このアプリはMVVM（Model-View-ViewModel）パターンに従っています：

- **Model**: `Player` 列挙型とボード配列で表現されるゲーム状態
- **View**: `ContentView` がSwiftUIインターフェースとアクセシビリティを提供
- **ViewModel**: `GameViewModel` がゲームロジック、状態管理、タスク管理を行う
- **AIロジック**: `AIEngine` がアルファベータ枝刈りを使用したミニマックスアルゴリズムを実装（構造化並行でキャンセル伝播）
- **評価器**: `AIEvaluator` がボード評価とパターン認識を提供（ダブルスレート等のシナジー評価含む）

## AI実装

AIは高度なミニマックスアルゴリズムを使用：
- **ミニマックス探索**: アルファベータ枝刈りで最大4手先まで先読み
- **パターン分析**: 攻撃的および防御的な手のためのボードパターン評価
- **進行状況追跡**: 評価中のポジション数と探索深度のリアルタイム表示
- **非同期実行**: UIの応答性を保つためのTask管理
- **キャンセレーション**: 適切なタスクキャンセル処理
 - **シナジー評価**: 複数のオープン3/4（ダブルスレート）を加点し、勝ち/ブロックをより自然に選好

## テスト

プロジェクトにはユニット/ UI テストが含まれています。共有スキーム `Gomoku` で実行できます。

テストの実行：
```bash
# すべてのテスト
xcodebuild test -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15'

# ユニットテストのみ
xcodebuild test -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:GomokuTests

# UIテストのみ
xcodebuild test -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:GomokuUITests
```

UIテストは表示テキストに依存せず、以下のアクセシビリティ識別子を使用します：
- `GameBoard`, `Cell_{row}_{col}`, `Stone_{color}_{row}_{col}`
- `AI Enabled`, `New Game`, `AI Move`
- `CurrentPlayerLabel`, `AIStatusLabel`, `WinnerLabel`

詳細なテストセットアップ手順については、[README_TEST_SETUP.md](README_TEST_SETUP.md) を参照してください。

## コントリビューション

コントリビューションを歓迎します！詳細については[コントリビューションガイドライン](CONTRIBUTING.md)を参照してください。

## 今後の機能拡張

- [ ] AI難易度レベル（簡単、普通、難しい）
- [ ] ゲーム履歴とリプレイ機能
- [ ] オンライン対戦サポート
- [ ] 効果音と触覚フィードバック
- [ ] 複数のテーマとボードカスタマイズ
- [ ] 統計追跡とプレイヤープロファイル
- [ ] Game Center 統合
- [ ] iPad 最適化インターフェース
- [ ] 元に戻す/やり直し機能
- [ ] 競技プレイ用の時間制限

## ローカライズ

- 対応言語: 英語（Base）、日本語（`ja`）
- 文言は `NSLocalizedString` で参照され、`Gomoku/Base.lproj/Localizable.strings` と `Gomoku/ja.lproj/Localizable.strings` に定義
- 言語追加手順: Xcode で `Localizable.strings` にローカライズを追加し、必要なキーの翻訳を追加

## サポート

問題が発生した場合や質問がある場合：

1. [Issues](https://github.com/SilentMalachite/Swift-Gomoku/issues) ページを確認
2. [コントリビューションガイドライン](CONTRIBUTING.md)を読む
3. 詳細な情報を含む新しい issue を作成

---

Swift と SwiftUI を使用して ❤️ を込めて作成
