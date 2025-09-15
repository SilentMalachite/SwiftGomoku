## 📝 Description

Briefly describe the changes in this PR.

## 🎯 Type of Change

Please delete options that are not relevant:

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🧪 Test improvements
- [ ] 🔧 Code refactoring
- [ ] ⚡ Performance improvement
- [ ] 🌍 Localization update
- [ ] ♿ Accessibility improvement

## 🔗 Related Issues

Please link any related issues:

- Closes #(issue number)
- Fixes #(issue number)
- Related to #(issue number)

## 🧪 Testing

Describe the tests you ran to verify your changes:

- [ ] Unit tests pass (`xcodebuild test -scheme Gomoku -only-testing:GomokuTests`)
- [ ] UI tests pass (`xcodebuild test -scheme Gomoku -only-testing:GomokuUITests`)
- [ ] Manual testing performed
- [ ] Accessibility testing (VoiceOver)
- [ ] Localization testing (if applicable)

### 📱 Test Configuration

- **Device**: [e.g. iPhone 15 Simulator]
- **iOS Version**: [e.g. iOS 17.0]
- **Xcode Version**: [e.g. 15.4]

## 📸 Screenshots

If applicable, add screenshots to help explain your changes.

| Before | After |
|--------|-------|
| (screenshot) | (screenshot) |

## ✅ Checklist

Please check all that apply:

### 🔍 Code Quality
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] My changes generate no new warnings
- [ ] I have removed any debug/console.log statements

### 🧪 Testing
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] UI tests pass and use accessibility identifiers (not display text)
- [ ] I have tested accessibility features (if UI changes)

### 📚 Documentation
- [ ] I have made corresponding changes to the documentation
- [ ] I have updated the README.md if needed
- [ ] I have updated CHANGELOG.md if this is a notable change
- [ ] Comments in code are clear and helpful

### 🌍 Localization
- [ ] I have added new strings to all `Localizable.strings` files
- [ ] All user-facing text uses `NSLocalizedString`
- [ ] I have tested with both English and Japanese locales (if applicable)

### ♿ Accessibility
- [ ] All new UI elements have appropriate accessibility labels
- [ ] Accessibility identifiers are set for UI testing
- [ ] VoiceOver navigation works correctly
- [ ] Color contrast meets accessibility standards

## 🎮 Game Impact

If your changes affect gameplay:

- [ ] Game rules remain consistent with traditional Gomoku
- [ ] AI behavior improvements don't break existing difficulty balance
- [ ] Performance impact is minimal (especially for AI calculations)
- [ ] Changes work correctly in both human vs human and human vs AI modes

## 🔄 Breaking Changes

If this is a breaking change, please describe:

1. What breaks?
2. How can users adapt their usage?
3. Is there a migration path?

## 📋 Additional Notes

Add any additional notes, concerns, or context for reviewers here.

---

**👀 Review Guidelines**: Please ensure all checkboxes are ticked before requesting review. Reviewers will focus on code quality, test coverage, and adherence to project standards.