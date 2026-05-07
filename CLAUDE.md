# Busfahrer App — Design & Architecture Reference

This file serves as the single source of truth for the app's design language, user flow, architecture, and UI patterns. Every Claude session working on this project should read this file first.

---

## Design Philosophy

The app is a **multi-game party game platform** inspired by **Splash Party Games** (Splash - Party & Gruppenspiele). The visual language, user flow, and component patterns are modeled after Splash's design system.

### Core Principles
1. **Dark-first**: Pure black backgrounds (#000000) with dark gray card layers
2. **Game-colored detail pages**: Each game has a signature color used as full-screen background on its detail/setup pages
3. **Drunk-proof UI**: Minimum 16pt font, semibold minimum weight, 56pt button height, high contrast
4. **Haptics over sound**: Every interaction has haptic feedback (parties are loud)
5. **Forward flow**: Minimal back-navigation during gameplay, clear phase progression
6. **Spring animations everywhere**: No linear animations, everything uses spring physics

---

## Reference App: Splash Party Games

### Splash Home Screen
- **Black background** (#000000)
- **Large bold title** top-left ("LilEars' Games" style) — we use the app/brand name
- **Settings gear** icon top-right in a dark circle button
- **2-column grid** of game tiles:
  - Nearly **square** aspect ratio (1:1)
  - **20pt corner radius**
  - Colorful gradient/image background filling entire tile
  - Game title in **UPPERCASE BLACK weight** at bottom-left of tile
  - Subtitle smaller below title
  - Optional "Popular" badge overlay (top-left corner)
  - Tiles fill the full width with 16pt gap between them

### Splash Game Detail Screen (KEY REFERENCE)
- **Full-screen game-colored background** (teal for Werewolves, red for Impostor, etc.)
- **Top bar**: Back arrow (circle button), optional heart icon (circle), question mark/help (circle)
- **Large game title** centered, ~38pt black weight
- **Subtitle** below: "by Hannes & Jeremy" or game tagline
- **Video Tutorial row**: Dark card with icon + text + blue "Watch" button (optional feature)
- **Settings card**: Dark rounded rectangle (#1C1C1E) with grouped rows:
  - Each row: emoji icon + label + value/count + chevron.right
  - Rows separated by thin separator lines (white 10% opacity)
  - Toggle switches where applicable (green system toggle)
  - Row padding: 16pt horizontal, 14pt vertical
- **Flavor text**: Centered, lighter opacity, below settings card
- **Character art / Emoji art**: Centered illustration area
- **"Start Game" button**: Fixed at bottom, dark pill (capsule shape), 56pt height

### Splash In-Game Header
- Game name **centered** at top in callout font
- **X button** (circle) on the right to open pause/exit menu
- Colored background specific to the current game phase

### Splash Settings Sheet
- Presented as a **bottom sheet** (.medium detent)
- "Settings" title centered, X close button top-right
- Grouped sections with dark card backgrounds
- Each row: colored icon in rounded-rect background + label + chevron.right
- Thin separator lines between rows within a group
- Sections separated by spacing

---

## App Architecture

### Navigation Flow
```
HOME (HomeView)
  |-- Settings sheet (SettingsView)
  |-- Tap game tile -->
  |
  GAME DETAIL (StartView) [game-colored background]
    |-- Back arrow --> HOME
    |-- Question mark --> Rules sheet (RulesView)
    |-- Players row --> PLAYER SETUP
    |-- Start Game button -->
    |
    PLAYER SETUP (PlayerSetupView) [game-colored background]
      |-- Back arrow --> GAME DETAIL
      |-- Start Game -->
      |
      PHASE TRANSITION --> PHASE 1 --> PHASE TRANSITION --> PHASE 2
        --> BUS DRIVER REVEAL --> PHASE TRANSITION --> PHASE 3
        --> PHASE TRANSITION --> GAME END
          |-- New Game --> PHASE TRANSITION (same players)
          |-- New Players --> PLAYER SETUP
          |-- Quit --> HOME
```

### Phase State Machine (GamePhase enum)
```
.home --> .start --> .playerSetup
  --> .phaseTransition(.phase1) --> .phase1(round, playerIndex)
  --> .phase1Reveal --> .phase1SipDistribution
  --> .phaseTransition(.phase2) --> .phase2Setup --> .phase2(row, cardIndex)
  --> .phase2Reveal --> .phase2Discard --> .phase2SipDistribution
  --> .phase2BusDriverReveal / .phase2Oracle
  --> .phaseTransition(.phase3) --> .phase3(round, attempt)
  --> .phase3Reveal
  --> .phaseTransition(.gameEnd) --> .gameEnd
```

### Key Files
| File | Purpose |
|------|---------|
| `BusfahrerApp.swift` | Entry point, injects GameViewModel + LanguageManager |
| `ContentView.swift` | Phase router, background colors, in-game header overlay |
| `Views/HomeView.swift` | Home screen with 2-column game grid |
| `Views/StartView.swift` | Game detail page (Splash-style) + SettingsView |
| `Views/PlayerSetupView.swift` | Add/remove players (2-8) |
| `Views/Phase1/Phase1View.swift` | Card guessing gameplay |
| `Views/Phase1/CardGuessView.swift` | Question + answer buttons UI |
| `Views/Phase2/Phase2View.swift` | Pyramid card matching |
| `Views/Phase2/PyramidGridView.swift` | Pyramid layout |
| `Views/Phase2/CardDiscardView.swift` | Discard matching cards |
| `Views/Phase2/BusDriverRevealView.swift` | Announce bus driver |
| `Views/Phase3/Phase3View.swift` | Bus driver final challenge |
| `Views/GameEndView.swift` | Stats, fun titles, action buttons |
| `Views/RulesView.swift` | Game rules sheet |
| `Views/SipDistributionView.swift` | Choose who drinks |
| `ViewModels/GameViewModel.swift` | All game state + logic (@Observable) |
| `Models/GamePhase.swift` | Phase enum |
| `Models/Card.swift` | Card, Suit, CardValue |
| `Models/Player.swift` | Player with name, color, hand, sips |
| `Models/Deck.swift` | Card deck management |
| `Utilities/Theme.swift` | All design tokens |
| `Utilities/Strings.swift` | DE/EN localization |
| `Utilities/HapticManager.swift` | Haptic feedback patterns |

---

## Design System (Theme.swift)

### Color Palette
```
Background:     #000000 (pure black)
Card BG:        #1C1C1E (dark gray — all cards, containers, buttons)
Card Elevated:  #2C2C2E (slightly lighter — secondary surfaces)
Separator:      white 10% opacity

Accent Green:   #34C759 (correct answers, success)
Accent Red:     #FF3B30 (wrong answers, danger)
Gold:           #FFD700 (celebrations)

Phase 1 Color:  #4A3AFF (Indigo) — also "busfahrerColor"
Phase 2 Color:  #FF8C00 (Orange)
Phase 3 Color:  #FF3B4A (Crimson Red)

Player Colors:  Rose, Blue, Green, Amber, Purple, Cyan, Orange, Yellow (8 vibrant colors)
```

### Typography (all SF Rounded)
```
largeTitleFont:  40pt .black    — home screen title
detailTitleFont: 38pt .black    — game detail page title
titleFont:       34pt .heavy    — section titles
headlineFont:    24pt .bold     — card titles, emphasis
bodyFont:        18pt .semibold — buttons, body text, row labels
calloutFont:     16pt .medium   — subtitles, secondary text
captionFont:     14pt .medium   — labels, badges
timerFont:       64pt .black    — countdown timers
cardValueFont:   42pt .bold     — card face values
```

### Spacing
```
padding:            20pt  — standard horizontal margins
cornerRadius:       16pt  — cards, containers
buttonHeight:       56pt  — all primary buttons
sectionSpacing:     24pt  — between major sections
itemSpacing:        12pt  — between items in a list
buttonBottomPadding: 34pt — bottom safe area for fixed buttons
```

### Animations
```
springSnappy:    response: 0.35, damping: 0.7  — quick interactions
springBouncy:    response: 0.5,  damping: 0.6  — playful feedback
springSmooth:    response: 0.6,  damping: 0.8  — smooth transitions
springDramatic:  response: 0.7,  damping: 0.5  — dramatic reveals
```

---

## Component Library

### CircleIconButton
Reusable circular icon button used in all top bars.
- Parameters: `systemName`, `size` (default 40), `iconSize` (default 16), `bgColor` (default cardBg), `fgOpacity` (default 0.7)
- Always triggers `HapticManager.selection()` on tap
- Usage: back arrows, settings gear, close X, help question mark

### GameTileView
Grid tile for home screen game selection.
- Colorful gradient background, 20pt corners, square aspect ratio
- Title UPPERCASE at bottom-left, subtitle below
- Large emoji centered
- Disabled state: 50% opacity, non-interactive

### Dark Card Pattern
Grouped rows in a dark rounded rectangle (cardBg + cornerRadius):
- Row: emoji + label + value + chevron.right
- Separator: `Theme.separator` (1pt, white 10%) with leading padding matching text start
- Row padding: horizontal 16pt, vertical 14pt

### Phase Transition Screen
Full-screen between phases with:
- Large emoji icon (scale animation 0.3 → 1.0)
- Phase title + subtitle
- Progress dots (3 circles, filled for completed phases)
- "Let's go!" button with heartbeat haptic

### Card System
- Card Back: Dark navy gradient, diamond crosshatch pattern, gold borders, "?" center motif, glowing border when interactive
- Card Face: White background, colored suit symbols, clean typography
- Flip: 3D rotation with scale pulse at midpoint

### Feedback
- Correct: Green sparkles (beer mug particles) + success haptic
- Wrong: Shake effect (10pt, 3 cycles) + red vignette flash + error haptic
- Phase 3 wrong: Enhanced danger — red vignette stronger, shake + vignette together
- Celebration: Confetti (100 particles, 3 shapes) + sparkles + gold effects

---

## Localization

All user-facing strings go through `Strings.swift` with DE/EN support.
- Access pattern: `Strings.section.property` (e.g., `Strings.detail.startGame`)
- Language controlled by `LanguageManager.shared.current` (AppLanguage enum: `.de`, `.en`)
- Always add both German and English for any new string

---

## Design Rules for New Games

When adding a new game to the platform:

1. **Assign a signature color** — add it to Theme.swift (e.g., `static let newGameColor = Color(...)`)
2. **Create a game tile** in HomeView with the game's emoji, title, subtitle, and gradient colors
3. **Create a detail view** following the Splash Game Detail pattern:
   - Full-screen game-colored background
   - Top bar: back + optional icons
   - Title + subtitle
   - Settings card with game-specific options
   - Flavor text
   - Start Game button fixed at bottom
4. **In-game**: Use AnimatedBackgroundView with game-specific phase colors
5. **In-game header**: Show game name centered + X close button
6. **Phase transitions**: Use PhaseTransitionView with appropriate icons and descriptions
7. **All new strings** must go in Strings.swift with DE + EN

---

## Design Rules for UI Changes

1. **Never use flat/linear animations** — always spring
2. **Never use system default buttons** — always custom dark pill style
3. **All interactive elements need haptic feedback** via HapticManager
4. **Minimum touch target**: 44pt (Apple HIG)
5. **Text colors**: White for primary, white 60% for secondary, white 40% for tertiary
6. **Buttons**: cardBg background, white text, Capsule shape, 56pt height, bodyFont
7. **Cards/containers**: cardBg background, 16pt corner radius
8. **Separators**: white 10% opacity, 1pt height
9. **Top bar pattern**: CircleIconButton for all navigation (back, close, settings, help)
10. **Bottom fixed buttons**: 20pt horizontal padding, 34pt bottom padding
11. **No white/light backgrounds** — everything dark
12. **Emojis for game icons** — no custom image assets needed for game representations
