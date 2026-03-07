# FEATURE-02 — Customisable Themes: Light & Colour Palette System

**Status:** Proposed  
**Priority:** Medium  
**Reported:** 2026-03-07  
**Type:** New Feature  
**Module:** `lib/theme/app_theme.dart`, `session_provider.dart` → `AppSettings`, `settings_screen.dart`  
**Related:** BUG-13 (Font not applying — same root-cause fix required in `MaterialApp`)

---

## Why This Feature Exists

NeuroLoad's current design is a single **Obsidian Noir** dark theme. This is a deliberate brand choice that works beautifully for Persona B (Aisha — the senior dev who loves precision instruments) and late-night study sessions. But it creates real friction for two important scenarios:

1. **Daytime use in bright environments.** The near-black UI is genuinely harder to read in sunlight or under office lighting. Persona A (Elias, the master's student studying in libraries, cafés, and university common rooms) is routinely in bright conditions.

2. **Personal ownership and comfort.** Colour is one of the simplest, most personal forms of self-expression. Allowing someone to pick a theme that *feels like theirs* increases daily engagement. A theme they chose is a theme they return to.

This feature is not about being "fun" or trendy. It is about reducing friction and increasing the number of daily contexts where NeuroLoad feels natural to open.

---

## What Is Being Built

A small, curated set of **named themes** the user can select from Settings. Each theme is a complete colour palette swap — backgrounds, surfaces, text hierarchy, accent colour, and border tones all change together to stay visually coherent. The font and accessibility settings remain independent.

The goal is **restraint, not abundance**. No rainbow colour pickers. No per-element customisation. A handful of thoughtfully designed alternatives to the default dark theme. Each one needs to feel like it was designed intentionally, not generated.

---

## The Themes

### 1. Obsidian Noir *(current default, dark)*
The existing theme. Deep black backgrounds (`#0A0A0A`), teal accent (`#00B5A5`), silver-grey text hierarchy. Stays exactly as-is. This is the reference point.

### 2. Ash Light
A cool, grey-toned light theme. Not pure white — the backgrounds use warm off-whites and cool light greys so the screen does not glare. The accent stays teal. This is the most neutral light option: clean, readable, professional.

Key tones:
- Background: `#F5F5F3` (warm white with a grey lean)
- Surface: `#EEEEEC`
- Surface Elevated: `#E4E4E2`
- Text Primary: `#1A1A1A`
- Text Secondary: `#5C5C5C`
- Text Tertiary: `#9A9A9A`
- Accent: `#009688` (teal, slightly deeper for contrast on light)
- Borders: `#D0D0CE`

### 3. Paper
A warm, cream-toned light theme. Inspired by good printed paper and analogue notebooks. Slightly warmer than Ash Light — less clinical, more considered. Works well for long reading or writing-heavy sessions (Elias writing thesis drafts, Marcus doing creative work).

Key tones:
- Background: `#F8F4EE`
- Surface: `#F0EBE3`
- Surface Elevated: `#E8E2D9`
- Text Primary: `#2C2416`
- Text Secondary: `#6B5E4E`
- Text Tertiary: `#A8967E`
- Accent: `#3D7A6E` (muted teal-green, fits the warm palette)
- Borders: `#D8CFC4`

### 4. Dusk
A mid-tone theme — not fully dark, not light. Warm slate and indigo-grey backgrounds. Good for transitional hours (early morning, evening wind-down). Soft on the eyes in low-but-not-zero light. The accent shifts from teal to a warm amber.

Key tones:
- Background: `#1E1C2E`
- Surface: `#262437`
- Surface Elevated: `#2F2C42`
- Text Primary: `#E2DFFF`
- Text Secondary: `#9B97B8`
- Text Tertiary: `#605C7A`
- Accent: `#C9A84C` (warm amber)
- Borders: `#3D3A54`

### 5. Forest
A dark theme with green undertones rather than black/grey. Earthy and calm. For users who find Obsidian Noir too stark or who simply associate green with focus and nature. The accent shifts to a brighter sage-green.

Key tones:
- Background: `#0F1A15`
- Surface: `#162013`
- Surface Elevated: `#1D2B1A`
- Text Primary: `#D8EDD6`
- Text Secondary: `#8AAF85`
- Text Tertiary: `#4D6F49`
- Accent: `#6FBA6A` (sage green)
- Borders: `#2D4029`

---

## What Does Not Change Between Themes

- Font family (controlled by the separate font setting).
- High-contrast mode (overrides whichever theme is active — this is an accessibility concern, not a style one).
- Timer ring animation colours (these are functional indicators tied to session state, not decoration).
- Rest Mode palette (this is a distinct session-state colour system and remains independent).

---

## Implementation

### 1. Add `AppThemeVariant` Enum

```dart
// app_theme.dart
enum AppThemeVariant {
  obsidianNoir,
  ashLight,
  paper,
  dusk,
  forest,
}
```

Each variant has a corresponding static method that returns a `ThemeData`:

```dart
static ThemeData forVariant(
  AppThemeVariant variant, {
  bool highContrast = false,
  String fontFamily = 'Inter',
}) {
  switch (variant) {
    case AppThemeVariant.obsidianNoir: return buildTheme(highContrast: highContrast, fontFamily: fontFamily);
    case AppThemeVariant.ashLight:     return buildAshLight(highContrast: highContrast, fontFamily: fontFamily);
    case AppThemeVariant.paper:        return buildPaper(highContrast: highContrast, fontFamily: fontFamily);
    case AppThemeVariant.dusk:         return buildDusk(highContrast: highContrast, fontFamily: fontFamily);
    case AppThemeVariant.forest:       return buildForest(highContrast: highContrast, fontFamily: fontFamily);
  }
}
```

Each builder constructs its own `ThemeData` using the same pattern as the existing `darkTheme`, substituting the colour set for that variant.

### 2. Add `themeVariant` to `AppSettings`

```dart
// session_provider.dart → AppSettings
class AppSettings {
  ...
  final AppThemeVariant themeVariant;

  const AppSettings({
    ...
    this.themeVariant = AppThemeVariant.obsidianNoir,
  });
}
```

With a `setTheme(AppThemeVariant)` method on `SettingsNotifier` that saves to SharedPreferences under key `settings_theme_variant` (stored as the variant's `name` string).

### 3. Wire into `MaterialApp` (Also Fixes BUG-13a)

The root widget must watch `settingsProvider` and rebuild when theme or font changes. This is the same fix required for BUG-13a:

```dart
// main.dart (or wherever MaterialApp lives)
class NeuroLoadApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      theme: AppTheme.forVariant(
        settings.themeVariant,
        highContrast: settings.highContrast,
        fontFamily: settings.fontFamily,
      ),
      routerConfig: router,
    );
  }
}
```

Because `ref.watch` is used, any change to `themeVariant`, `fontFamily`, or `highContrast` triggers an immediate full-app rebuild — no restart needed.

### 4. Theme Picker in Settings

A new section in Settings, placed above the Font row under **ACCESSIBILITY** (or as its own section labelled **APPEARANCE**):

The picker shows a horizontal scrollable row of **theme preview chips**. Each chip is a small rounded rectangle (about 48×32 dp) filled with that theme's background colour, with a small accent dot in its centre colour, and the theme name below in small label text. The currently active theme has a border highlight.

Tapping a chip:
- Immediately applies the theme live (no confirmation needed — the change is visible behind the settings screen).
- Saves to SharedPreferences.
- The settings screen itself re-renders in the new theme colours.

No bottom sheet needed — the horizontal chip row is compact and all options fit in one glance.

---

## Accessibility Notes

- Light themes (Ash Light, Paper) must meet WCAG AA contrast (4.5:1) for all body text against their backgrounds. These ratios should be verified before shipping.
- When High Contrast Mode is active, it overrides the accent colour of whichever theme is selected. The background and surface colours of the selected theme remain, but accent switches to `#FFD700` and borders to `#FFFFFF`.
- Ash Light and Paper in High Contrast mode may need additional border darkening to maintain legibility — this should be tested.

---

## Acceptance Criteria

- [ ] Five named themes are available in Settings: Obsidian Noir, Ash Light, Paper, Dusk, Forest.
- [ ] Selecting a theme applies immediately to the entire app without requiring a restart.
- [ ] The selected theme persists across app restarts.
- [ ] High Contrast Mode overrides the accent colour but not the theme's background/surface tones.
- [ ] Font selection and theme selection are independent.
- [ ] All light themes (Ash Light, Paper) pass WCAG AA contrast ratio (≥ 4.5:1) for body text.
- [ ] The Rest Mode colour palette is unaffected by theme selection.
- [ ] The theme picker UI shows a visual preview of each theme (colour chip with accent dot).
- [ ] The currently active theme is visually marked in the picker.
- [ ] This change also resolves BUG-13a (font not applying) since both fixes share the same `MaterialApp` watch pattern.

---

## Out of Scope

- Custom colour pickers — users cannot define arbitrary hex values.
- Per-screen theming — every screen uses the selected theme.
- Seasonal or automatic themes (e.g., night mode auto-switch) — this is a v2 consideration.
- Separate themes for the Rest Mode timer screen — Rest Mode has its own fixed palette.
