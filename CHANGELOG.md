# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

## [1.1.0] - 2025-08-24

### Added
- Shared Xcode scheme `Gomoku` for running unit and UI tests.
- Localization support with `Localizable.strings` (Base/English, Japanese).
- Accessibility identifiers for robust UI tests: `CurrentPlayerLabel`, `AIStatusLabel`, `WinnerLabel`.

### Changed
- Swift toolchain requirement to Swift 5.7 (Xcode 14+), leveraging structured concurrency.
- Refactored AI move execution to structured concurrency; cancellation now propagates reliably.
- Improved AI evaluation with synergy scoring (double open-threes/fours) and minor center-control differential.
- README/CONTRIBUTING/README_TEST_SETUP updated: tests, identifiers, localization.

### Removed
- iOS-inappropriate entitlements file and references.
