# Contributing to Swift Gomoku 🎮

Thank you for considering contributing to Swift Gomoku! Your contributions help make this project a great tool for iOS game development and Gomoku enthusiasts.

<p align="center">
  <a href="#code-of-conduct">Code of Conduct</a> •
  <a href="#how-to-contribute">How to Contribute</a> •
  <a href="#development-setup">Development Setup</a> •
  <a href="#pull-request-process">PR Process</a> •
  <a href="#style-guidelines">Style Guidelines</a>
</p>

---

## 🤝 Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it to understand our community standards.

## 🚀 How to Contribute

### 🐛 Reporting Bugs

Before creating a bug report, please check existing issues to avoid duplicates. When creating a bug report, include:

- **🔍 Clear Title**: Use a descriptive title that identifies the problem
- **📝 Detailed Steps**: Provide exact steps to reproduce the issue
- **📱 Environment**: Include iOS version, device model, and app version
- **📸 Screenshots**: Add screenshots to clarify the problem
- **🎮 Game State**: Describe the game situation when the bug occurred
- **♿ Accessibility**: Note if you're using assistive technologies

**Use our [Bug Report Template](.github/ISSUE_TEMPLATE/bug_report.md) for consistency.**

### ✨ Suggesting Features

Feature suggestions are tracked as GitHub issues. When creating a feature request:

- **🎯 Problem Statement**: Clearly describe the problem or need
- **💡 Proposed Solution**: Detail your suggested implementation
- **🎮 Use Cases**: Provide specific scenarios where this would be useful
- **📱 Platform Considerations**: Consider iOS, accessibility, and localization impacts
- **🎨 Design Ideas**: Include mockups or wireframes if you have them

**Use our [Feature Request Template](.github/ISSUE_TEMPLATE/feature_request.md) for consistency.**

### 🛠️ Code Contributions

We welcome code contributions! Here are some areas where you can help:

#### 🎯 Good First Issues
- 🐛 **Bug Fixes**: Fix reported issues
- 📝 **Documentation**: Improve README, comments, or guides
- 🧪 **Tests**: Add unit or UI tests
- 🌍 **Localization**: Add new language support
- ♿ **Accessibility**: Improve VoiceOver support

#### 🚀 Advanced Contributions
- 🤖 **AI Improvements**: Enhance minimax algorithm or evaluation
- 🎨 **UI/UX**: Design improvements and animations
- ⚡ **Performance**: Optimize game performance
- 📱 **Platform Features**: iPad optimization, widgets, etc.

## 🏗️ Development Setup

### 📋 Prerequisites

- **macOS**: 13.0 or later
- **Xcode**: 14.0 or later
- **Swift**: 5.7 or later
- **Git**: Latest version
- **iOS Simulator**: 16.0 or later

### 🚀 Getting Started

1. **Fork the Repository**
   ```bash
   # Click the Fork button on GitHub, then:
   git clone https://github.com/YOUR_USERNAME/SwiftGomoku.git
   cd SwiftGomoku
   ```

2. **Set Up Upstream Remote**
   ```bash
   git remote add upstream https://github.com/SilentMalachite/SwiftGomoku.git
   git fetch upstream
   ```

3. **Open in Xcode**
   ```bash
   open Gomoku.xcodeproj
   ```

4. **Verify Setup**
   - Build the project (⌘B)
   - Run tests (⌘U)
   - Run the app (⌘R)

### 🧪 Running Tests

```bash
# All tests
xcodebuild test -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15'

# Unit tests only
xcodebuild test -scheme Gomoku -only-testing:GomokuTests -destination 'platform=iOS Simulator,name=iPhone 15'

# UI tests only
xcodebuild test -scheme Gomoku -only-testing:GomokuUITests -destination 'platform=iOS Simulator,name=iPhone 15'

# With coverage
xcodebuild test -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15' -enableCodeCoverage YES
```

## 📝 Pull Request Process

### 🌿 Branching Strategy

1. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/bug-description
   ```

2. **Keep Your Branch Updated**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

### 📤 Submitting Your PR

1. **Push Your Branch**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request**
   - Use our [PR Template](.github/PULL_REQUEST_TEMPLATE.md)
   - Link related issues
   - Provide clear description of changes
   - Add screenshots for UI changes

3. **Address Review Feedback**
   - Make requested changes
   - Push updates to your branch
   - Respond to reviewer comments

### ✅ PR Checklist

Before submitting your PR, ensure:

#### 🔍 Code Quality
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Code is commented where necessary
- [ ] No new warnings generated
- [ ] Debug statements removed

#### 🧪 Testing
- [ ] Tests added/updated for new functionality
- [ ] All tests pass locally
- [ ] UI tests use accessibility identifiers
- [ ] Accessibility tested with VoiceOver

#### 📚 Documentation
- [ ] Documentation updated if needed
- [ ] CHANGELOG.md updated for notable changes
- [ ] Code comments are clear and helpful

#### 🌍 Internationalization
- [ ] New strings added to all `Localizable.strings` files
- [ ] All user-facing text uses `NSLocalizedString`
- [ ] Tested with both English and Japanese

## 📐 Style Guidelines

### 🧑‍💻 Swift Code Style

We follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) with these additions:

```swift
// ✅ Good: Clear, descriptive names
func calculateBestMove(for boardState: GameBoard) -> Position?
let isAIThinking: Bool
var winningPositions: [Position]

// ❌ Avoid: Abbreviated or unclear names
func calcMove(for b: GameBoard) -> Position?
let thinking: Bool
var positions: [Position]
```

#### 🏗️ Architecture Guidelines

- **MVVM Pattern**: Follow established MVVM structure
- **Single Responsibility**: Each class/struct should have one clear purpose
- **Dependency Injection**: Prefer injecting dependencies over singletons
- **Protocol-Oriented**: Use protocols for testability and flexibility

```swift
// ✅ Good: Protocol-oriented design
protocol GameBoardDataSource {
    var board: [[Player]] { get }
    var currentPlayer: Player { get }
    var size: Int { get }
}

// ✅ Good: Clear separation of concerns
class GameViewModel: ObservableObject {
    @Published private(set) var gameBoard: GameBoard
    private let aiEngine: AIEngine
    
    func makeMove(row: Int, col: Int) -> Result<Void, GameError> {
        // Game logic here
    }
}
```

### 🎨 SwiftUI Guidelines

```swift
// ✅ Good: Extracted view components
struct StoneView: View {
    let player: Player
    let isWinning: Bool
    
    var body: some View {
        Circle()
            .fill(player.color)
            .overlay(winningOverlay)
    }
}

// ✅ Good: Accessibility support
.accessibilityLabel("Black stone at row \(row), column \(col)")
.accessibilityIdentifier("Stone_\(player.rawValue)_\(row)_\(col)")
```

### 🧪 Testing Guidelines

#### Unit Tests
```swift
// ✅ Good: AAA pattern (Arrange, Act, Assert)
func testMakeMoveUpdatesCurrentPlayer() {
    // Arrange
    let viewModel = GameViewModel()
    
    // Act
    let result = viewModel.makeMove(row: 7, col: 7)
    
    // Assert
    XCTAssertEqual(result, .success(()))
    XCTAssertEqual(viewModel.currentPlayer, .white)
}
```

#### UI Tests
```swift
// ✅ Good: Use accessibility identifiers
let newGameButton = app.buttons["New Game"]
newGameButton.tap()

// ❌ Avoid: Using display text (breaks with localization)
let button = app.buttons["新規ゲーム"] // Don't do this!
```

### 🌍 Localization Guidelines

```swift
// ✅ Good: Localized strings
Text(NSLocalizedString("Current Player:", comment: "Label for current player"))

// ✅ Good: Parameterized strings
String(format: NSLocalizedString("%@ wins!", comment: "Winner announcement"), winner.localizedName)

// ❌ Avoid: Hardcoded strings
Text("Current Player:") // Don't do this!
```

### ♿ Accessibility Guidelines

```swift
// ✅ Good: Comprehensive accessibility
.accessibilityLabel("Empty cell at row \(row), column \(col)")
.accessibilityHint("Double tap to place \(currentPlayer.localizedName) stone")
.accessibilityIdentifier("Cell_\(row)_\(col)")
.accessibilityAddTraits(.isButton)
```

## 📐 Commit Message Guidelines

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
type(scope): description

[optional body]

[optional footer]
```

### 🏷️ Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### 📝 Examples
```bash
# Good examples
git commit -m "feat(ai): improve minimax algorithm performance"
git commit -m "fix(ui): resolve VoiceOver navigation issue"
git commit -m "docs: update README with new setup instructions"

# With body and breaking change
git commit -m "feat(game): add undo/redo functionality

Implement undo/redo stack with proper state management.
Includes UI buttons and keyboard shortcuts.

BREAKING CHANGE: GameViewModel API changed"
```

## 🎮 Game-Specific Guidelines

### 🤖 AI Development
- **Fair Play**: Ensure AI remains challenging but fair
- **Performance**: Optimize for mobile device constraints
- **Difficulty**: Consider different skill levels
- **Accessibility**: Provide clear AI status feedback

### 🎯 Game Balance
- **Traditional Rules**: Maintain classic Gomoku rules
- **User Experience**: Prioritize intuitive interactions
- **Accessibility**: Ensure all players can enjoy the game
- **Localization**: Consider cultural gaming preferences

## 🔍 Review Process

### 👀 What Reviewers Look For

1. **Code Quality**: Clean, readable, maintainable code
2. **Testing**: Adequate test coverage and quality
3. **Documentation**: Clear comments and updated docs
4. **Performance**: No negative impact on game performance
5. **Accessibility**: Proper VoiceOver and accessibility support
6. **Localization**: Proper internationalization support
7. **Game Balance**: Changes don't break game fairness

### ⏱️ Timeline Expectations

- **Initial Review**: 3-5 business days
- **Follow-up Reviews**: 1-2 business days
- **Minor Changes**: Same day for simple fixes
- **Major Features**: May require multiple review rounds

## 🎯 Issue Labels

We use these labels to organize issues:

### 🏷️ Type Labels
- `bug` - Something isn't working
- `enhancement` - New feature or improvement
- `documentation` - Documentation improvements
- `question` - Questions or discussions

### 🎚️ Priority Labels
- `priority: critical` - Breaks core functionality
- `priority: high` - Important improvements
- `priority: medium` - Nice to have
- `priority: low` - Future considerations

### 🎮 Domain Labels
- `ai` - AI engine and algorithms
- `ui` - User interface and design
- `accessibility` - Accessibility features
- `localization` - Internationalization
- `testing` - Test improvements
- `performance` - Performance optimizations

### 👥 Contributor Labels
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `hacktoberfest` - Hacktoberfest eligible

## 🏆 Recognition

Contributors are recognized in several ways:

- **🎖️ README Credits**: Listed in the contributors section
- **📋 Release Notes**: Mentioned for significant contributions
- **🏅 Special Thanks**: Highlighted for exceptional contributions
- **💬 Social Media**: Shared on project social accounts

## 🆘 Getting Help

### 📚 Resources
- **📖 Documentation**: Check README and docs first
- **🔍 Search Issues**: Look for existing discussions
- **💬 Discussions**: Use GitHub Discussions for questions
- **📧 Direct Contact**: Reach out to maintainers for sensitive issues

### 🤝 Community
- **👥 Be Patient**: Maintainers are volunteers
- **🙏 Be Respectful**: Follow our Code of Conduct
- **📖 Be Helpful**: Help others when you can
- **🎉 Celebrate**: Acknowledge others' contributions

---

<p align="center">
  <strong>🎮 Happy Contributing! 🚀</strong><br>
  <sub>Thank you for making Swift Gomoku better for everyone!</sub>
</p>
