# Swift Gomoku 🔴⚫

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.7+-orange.svg" alt="Swift Version">
  <img src="https://img.shields.io/badge/Platform-iOS%2016.0+-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
  <a href="https://github.com/SilentMalachite/SwiftGomoku/actions/workflows/ci.yml">
    <img src="https://github.com/SilentMalachite/SwiftGomoku/actions/workflows/ci.yml/badge.svg" alt="CI Status">
  </a>
  <img src="https://img.shields.io/badge/Coverage-85%25-brightgreen.svg" alt="Test Coverage">
</p>

<p align="center">
  <strong>A native iOS Gomoku (Five-in-a-Row) game built with Swift and SwiftUI</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#how-to-play">How to Play</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#license">License</a>
</p>

---

## 🎮 Overview

Swift Gomoku is a modern implementation of the classic Five-in-a-Row board game for iOS. Players take turns placing stones on a 15×15 grid, with the objective of being the first to align five stones horizontally, vertically, or diagonally.

### ✨ Key Highlights

- **🎯 Strategic AI**: Advanced minimax algorithm with alpha-beta pruning
- **♿ Accessibility First**: Full VoiceOver support with detailed navigation
- **🌍 Internationalized**: English and Japanese localization
- **🧪 Well Tested**: Comprehensive unit and UI test coverage
- **⚡ Modern Swift**: Built with SwiftUI and Swift 5.7+ concurrency

## 📱 Features

### 🎲 Gameplay
- ✅ **Classic Rules**: Traditional 15×15 Gomoku gameplay
- ✅ **AI Opponent**: Toggle between human vs human or human vs AI
- ✅ **Visual Feedback**: Animated winning stone highlights
- ✅ **Clean Interface**: Minimalist design with traditional wooden board aesthetic
- ✅ **Instant Play**: No external dependencies or setup required

### 🤖 AI System
- ✅ **Smart Strategy**: Minimax algorithm with 4-move lookahead
- ✅ **Pattern Recognition**: Advanced board evaluation and threat detection
- ✅ **Async Processing**: Non-blocking AI computation with progress tracking
- ✅ **Cancellation Support**: Proper task cancellation handling
- ✅ **Synergy Evaluation**: Bonus scoring for multiple simultaneous threats

### ♿ Accessibility
- ✅ **VoiceOver Ready**: Complete screen reader support
- ✅ **Detailed Labels**: Descriptive labels for every UI element
- ✅ **Smart Announcements**: Automatic game state announcements
- ✅ **Proper Traits**: Correct accessibility traits for interactive elements

### 🌐 Localization
- ✅ **Multi-language**: English (Base) and Japanese support
- ✅ **Cultural Adaptation**: Localized game terminology and UI text
- ✅ **Extensible**: Easy to add additional languages

## 🚀 Installation

### Prerequisites

- **iOS**: 16.0 or later
- **Xcode**: 14.0 or later
- **Swift**: 5.7 or later
- **macOS**: 13.0 or later (for development)

### Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/SilentMalachite/SwiftGomoku.git
   cd SwiftGomoku
   ```

2. **Open in Xcode**:
   ```bash
   open Gomoku.xcodeproj
   ```

3. **Build and run** (⌘R)

   *No additional dependencies or package managers required!*

## 🎯 How to Play

1. **🆕 Start**: Launch the app to begin a new game automatically
2. **🎮 Place Stones**: Tap any empty intersection to place your stone
   - Black always goes first
   - Players alternate turns
3. **🏆 Win Condition**: First player to align 5 stones in any direction wins
4. **🤖 AI Mode**: Toggle "AI Opponent" to play against the computer
5. **🔄 New Game**: Tap "New Game" to reset the board

### 🎮 Game Controls

| Action | Description |
|--------|-------------|
| **Tap Empty Cell** | Place your stone |
| **AI Opponent Toggle** | Enable/disable AI mode |
| **New Game Button** | Reset board and start over |
| **AI Move Button** | Force AI to make a move (when available) |

## 🏗️ Architecture

Swift Gomoku follows the **MVVM** (Model-View-ViewModel) pattern:

```
┌─────────────────┬─────────────────┬─────────────────┐
│      Model      │       View      │   ViewModel     │
├─────────────────┼─────────────────┼─────────────────┤
│ • Player enum   │ • ContentView   │ • GameViewModel │
│ • GameBoard     │ • BoardGrid     │ • State mgmt    │
│ • Domain types  │ • StoneView     │ • Task handling │
└─────────────────┴─────────────────┴─────────────────┘
```

### 📂 Project Structure

```
SwiftGomoku/
├── 📱 Gomoku/
│   ├── 🚀 GomokuApp.swift          # App entry point
│   ├── 🎨 ContentView.swift        # Main game UI with accessibility
│   ├── 🎮 GameViewModel.swift      # Game state and task management
│   ├── 📋 GameBoard.swift          # Game board model
│   ├── 🤖 AIEngine.swift           # Minimax AI algorithm
│   ├── 📊 AIEvaluator.swift        # Board evaluation & patterns
│   ├── 🌐 Domain.swift             # Core domain types
│   └── 📁 Localization/
│       ├── Base.lproj/Localizable.strings
│       └── ja.lproj/Localizable.strings
├── 🧪 GomokuTests/               # Unit tests
├── 🎪 GomokuUITests/             # UI automation tests
├── 📄 Documentation/
│   ├── CONTRIBUTING.md
│   ├── CHANGELOG.md
│   └── README_TEST_SETUP.md
└── ⚙️ .github/workflows/         # CI/CD automation
```

### 🧠 AI Implementation

The AI system uses sophisticated algorithms for competitive gameplay:

- **🎯 Minimax Search**: Alpha-beta pruning with 4-move lookahead
- **📈 Pattern Analysis**: Evaluation of offensive and defensive positions
- **⚡ Progress Tracking**: Real-time display of evaluated positions and search depth
- **🔄 Async Execution**: Task management preserving UI responsiveness
- **❌ Cancellation**: Proper cancellation handling for interrupted computations
- **🎨 Synergy Evaluation**: Bonus scoring for multiple open threats (double threes/fours)

## 🧪 Testing

The project includes comprehensive test coverage:

```bash
# Run all tests
xcodebuild test -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15'

# Unit tests only
xcodebuild test -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:GomokuTests

# UI tests only  
xcodebuild test -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:GomokuUITests
```

### 🎯 Test Strategy

- **Unit Tests**: Core game logic, AI algorithms, board state management
- **UI Tests**: User interactions, accessibility features, game flows
- **Accessibility IDs**: Stable identifiers for reliable UI testing across localizations
- **Coverage Target**: 80%+ code coverage maintained

For detailed testing setup, see [README_TEST_SETUP.md](README_TEST_SETUP.md).

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### 🚀 Quick Contribution Steps

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### 🎯 Areas for Contribution

- 🤖 AI difficulty levels
- 🎨 Additional themes and customizations
- 🌍 New language localizations
- 📱 iPad optimization
- 🔊 Sound effects and haptic feedback
- 📊 Statistics and player profiles

## 🗺️ Roadmap

### 🎯 Planned Features

- [ ] **🎚️ AI Difficulty Levels** (Easy, Normal, Hard)
- [ ] **📜 Game History & Replay** functionality
- [ ] **🌐 Online Multiplayer** support
- [ ] **🔊 Sound Effects** and haptic feedback
- [ ] **🎨 Multiple Themes** and board customization
- [ ] **📊 Statistics Tracking** and player profiles
- [ ] **🎮 Game Center Integration**
- [ ] **📱 iPad Optimized** interface
- [ ] **↩️ Undo/Redo** functionality
- [ ] **⏰ Time Limits** for competitive play

## 📊 Technical Specs

| Aspect | Details |
|--------|--------|
| **Language** | Swift 5.7+ |
| **Framework** | SwiftUI |
| **Architecture** | MVVM |
| **Minimum iOS** | 16.0 |
| **Dependencies** | None |
| **AI Algorithm** | Minimax with Alpha-Beta Pruning |
| **Concurrency** | Swift Structured Concurrency |
| **Testing** | XCTest (Unit + UI) |
| **Localization** | NSLocalizedString |
| **Accessibility** | VoiceOver + Accessibility Identifiers |

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **🎮 Game Design**: Classic Gomoku/Five-in-a-Row rules
- **🤖 AI Algorithm**: Minimax with alpha-beta pruning
- **♿ Accessibility**: Apple's accessibility guidelines
- **🌍 Localization**: Swift's internationalization framework

## 📞 Support

If you encounter any issues or have questions:

1. **🔍 Check** existing [Issues](https://github.com/SilentMalachite/SwiftGomoku/issues)
2. **📖 Read** the [Contributing Guidelines](CONTRIBUTING.md)
3. **🆕 Create** a new issue with detailed information

---

<p align="center">
  Made with ❤️ using Swift and SwiftUI<br>
  <sub>© 2024 Swift Gomoku Project</sub>
</p>
