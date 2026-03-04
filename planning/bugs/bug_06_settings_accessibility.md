# 6. Settings: High Contrast & Font Non-Functional

## Description
As a user with accessibility limits, I want the high contrast mode and font settings to actually change the app's appearance, so that I can read the text comfortably.
**Problem Context:** The toggles exist in settings but do not trigger global theme rebuilds.

## Acceptance Criteria
- [ ] Toggling "High Contrast" immediately updates the app theme to use high-contrast color palettes.
- [ ] Changing the font preference updates text across all screens dynamically.

## Resolution / Solution Method
- Verify that the Settings provider is correctly notifying listeners when these preferences change.
- Ensure the root `MaterialApp` is consuming the custom Theme extensions for fonts and contrast colors.
- Audit text widgets to ensure they aren't using hardcoded `TextStyle`s that override the global theme.
