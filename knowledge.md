# Swift Gomoku Project Knowledge

## Mission
A native iOS Gomoku (Five-in-a-row) game built with Swift and SwiftUI. Features AI opponent with minimax algorithm, full accessibility support, and bilingual localization (English/Japanese).

## Architecture
- **Pattern**: MVVM (Model-View-ViewModel)
- **Model**: `Player` enum, board arrays in `Domain.swift`
- **View**: `ContentView.swift` with SwiftUI + accessibility
- **ViewModel**: `GameViewModel.swift` for state management
- **AI**: `AIEngine.swift` with minimax + alpha-beta pruning
- **Evaluation**: `AIEvaluator.swift` for board pattern analysis

## Key Implementation Details

### AI System
- Minimax algorithm with alpha-beta pruning (4 moves deep)
- Async execution using Swift concurrency to prevent UI blocking
- Progress tracking shows evaluated positions and search depth
- Proper task cancellation handling
- Synergy evaluation for multiple open threats (double slates)

### Accessibility
- Full VoiceOver support with detailed labels
- Accessibility identifiers for UI testing
- Dynamic hints based on game state
- Proper accessibility traits for interactive elements

### Localization
- English (Base) and Japanese (`ja`) support
- All UI text uses `NSLocalizedString`
- Localized strings in `Base.lproj/Localizable.strings` and `ja.lproj/Localizable.strings`

### Testing
- Unit tests for core game logic
- UI tests using accessibility identifiers (not display text)
- Shared scheme `Gomoku` for running tests

## Development Guidelines

### Code Style
- Use Swift 5.7+ features
- Follow SwiftUI best practices
- Maintain accessibility for all UI elements
- Keep localization consistent

### Testing
- Run tests via: `xcodebuild test -scheme Gomoku -destination 'platform=iOS Simulator,name=iPhone 15'`
- UI tests rely on accessibility identifiers, not text content
- Always test accessibility features

### Build Requirements
- iOS 16.0+ deployment target
- Xcode 14.0+ required
- No external dependencies

## File Structure Notes
- Main app code in `Gomoku/` directory
- Tests split into `GomokuTests/` (unit) and `GomokuUITests/` (UI)
- Localization files in respective `.lproj` directories
- Project uses standard Xcode project structure

## Current State
The app is feature-complete with working AI, accessibility, and localization. Recent changes include improved alpha-beta pruning and enhanced localized strings.