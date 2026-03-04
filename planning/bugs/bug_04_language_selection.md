# 4. Onboarding Language Selection

## Description
As a new user, I want the app to detect my system language but allow me to explicitly confirm or change it during onboarding, so that I fully understand the app's interface.
**Problem Context:** No explicit language gate upon first launch.

## Acceptance Criteria
- [ ] The very first screen of onboarding shows a language selector.
- [ ] The selector defaults to the device's current locale/system language.
- [ ] A user can easily tap to change it to another supported language before proceeding.

## Resolution / Solution Method
- Add a new `LanguageSelection` step to the start of the Intro/Onboarding flow.
- Fetch `PlatformDispatcher.instance.locale` to set the default dropdown value.
- Wire the selection to update the app's localization state globally.
