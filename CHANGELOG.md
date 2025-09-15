# Changelog 📋

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- 📚 Comprehensive GitHub documentation templates
- 🔒 Security policy and vulnerability reporting process
- 🤝 Code of conduct for community guidelines
- 📝 Issue and pull request templates
- 🌍 Enhanced English README for international audience
- 🎯 Contribution guidelines with detailed setup instructions

### Changed
- 📖 Improved documentation structure and organization
- 🎨 Enhanced README with better badges and visual appeal
- 🔧 Streamlined development setup process

## [1.1.0] - 2024-08-24

### Added
- 🔧 Shared Xcode scheme `Gomoku` for running unit and UI tests
- 🌍 Localization support with `Localizable.strings` (Base/English, Japanese)
- ♿ Accessibility identifiers for robust UI tests: `CurrentPlayerLabel`, `AIStatusLabel`, `WinnerLabel`
- 🧪 Comprehensive test coverage for game logic and UI interactions
- 📱 VoiceOver support with detailed accessibility labels
- 🤖 AI progress tracking with real-time status updates
- 🎯 Structured concurrency for non-blocking AI computation
- 🎮 Enhanced winning stone animations and visual feedback

### Changed
- ⬆️ Swift toolchain requirement to Swift 5.7 (Xcode 14+), leveraging structured concurrency
- 🔄 Refactored AI move execution to structured concurrency; cancellation now propagates reliably
- 🧠 Improved AI evaluation with synergy scoring (double open-threes/fours) and center-control differential
- 📚 Updated README/CONTRIBUTING/README_TEST_SETUP with tests, identifiers, localization info
- 🎨 Enhanced UI with better accessibility support and localized strings
- ⚡ Optimized AI performance with better move ordering and alpha-beta pruning

### Fixed
- 🐛 Resolved alert text mismatches between code and tests
- 🗣️ Fixed VoiceOver announcements to use proper localized player names
- 🛡️ Added safety guards for AI moves to prevent race conditions
- 📱 Improved UI responsiveness during AI computation

### Removed
- 🗑️ iOS-inappropriate entitlements file and references
- 🧹 Cleaned up deprecated code and unused dependencies

### Security
- 🔒 Enhanced memory safety with Swift's structured concurrency
- 🛡️ Improved error handling and edge case management
- 🔐 Added proper task cancellation to prevent resource leaks

## [1.0.0] - 2024-07-15

### Added
- 🎮 Initial release of Swift Gomoku
- 🏁 Complete traditional 15×15 Gomoku gameplay
- 🤖 AI opponent with minimax algorithm
- 🎨 Clean SwiftUI interface with wooden board design
- 📱 Native iOS app with no external dependencies
- 🎯 Real-time win detection and visual feedback
- 🔄 New game functionality
- 📋 Comprehensive unit and UI tests
- 📚 Initial documentation and setup guides

---

## Legend

- 🎮 **Game Features**: Core gameplay functionality
- 🤖 **AI/Algorithm**: Artificial intelligence improvements
- 🎨 **UI/UX**: User interface and experience
- ♿ **Accessibility**: Accessibility and inclusive design
- 🌍 **Localization**: Internationalization and localization
- 🧪 **Testing**: Test coverage and quality assurance
- 📚 **Documentation**: Documentation and guides
- ⚡ **Performance**: Performance optimizations
- 🔒 **Security**: Security improvements and fixes
- 🐛 **Bug Fixes**: Bug fixes and error corrections
- 🔧 **Development**: Developer experience and tooling
- 📱 **Platform**: iOS platform specific features

## Links

- [Repository](https://github.com/SilentMalachite/SwiftGomoku)
- [Issues](https://github.com/SilentMalachite/SwiftGomoku/issues)
- [Contributing](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)
