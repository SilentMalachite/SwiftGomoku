# Release 1.1.0 (2025-08-24)

## Highlights
- Localization: Added Base (English) and Japanese strings via `Localizable.strings`.
- Robust UI tests: Switched to accessibility identifiers for stability across locales.
- AI improvements: Structured-concurrency cancellation propagation and synergy scoring for double threats.

## Details
- Added: Shared Xcode scheme `Gomoku` for running unit and UI tests.
- Added: Accessibility identifiers `CurrentPlayerLabel`, `AIStatusLabel`, `WinnerLabel`.
- Changed: Require Swift 5.7+, leverage structured concurrency; improved `AIEvaluator` with double-open-three/four bonuses and center-control differential.
- Changed: README/CONTRIBUTING/README_TEST_SETUP updated to reflect localization and test identifiers.
- Removed: iOS-inappropriate entitlements file and its references.

Refer to CHANGELOG.md for the full change history.
