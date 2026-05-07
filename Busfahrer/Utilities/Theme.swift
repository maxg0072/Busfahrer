import SwiftUI

enum Theme {
    // MARK: - Base Colors (Splash-inspired dark theme)
    static let background = Color.black
    static let cardBg = Color(red: 0.11, green: 0.11, blue: 0.118)         // #1C1C1E
    static let cardBgElevated = Color(red: 0.17, green: 0.17, blue: 0.18)  // #2C2C2E

    // Text opacity helpers
    static let textSecondary: Double = 0.6
    static let textTertiary: Double = 0.4

    // Separator
    static let separator = Color.white.opacity(0.10)

    // MARK: - Accent Colors
    static let accentGreen = Color(red: 0.20, green: 0.78, blue: 0.35)     // #34C759
    static let accentRed = Color(red: 1.0, green: 0.23, blue: 0.19)        // #FF3B30
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)              // #FFD700

    // Feedback
    static let correct = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let wrong = Color(red: 1.0, green: 0.23, blue: 0.19)

    // Card colors
    static let cardRed = Color(red: 1.0, green: 0.22, blue: 0.28)
    static let cardBlack = Color.white

    // MARK: - Button System (Dark pills on colored backgrounds)
    static let buttonPrimaryBg = Color(red: 0.11, green: 0.11, blue: 0.118) // #1C1C1E
    static let buttonPrimaryFg = Color.white
    static let buttonSecondaryBg = Color(red: 0.17, green: 0.17, blue: 0.18) // #2C2C2E
    static let buttonAnswerBg = Color.black.opacity(0.40)

    // MARK: - Player Colors (vibrant)
    static let playerColors: [Color] = [
        Color(red: 1.0, green: 0.42, blue: 0.52),   // Rose
        Color(red: 0.35, green: 0.55, blue: 1.0),   // Blue
        Color(red: 0.25, green: 0.90, blue: 0.55),   // Green
        Color(red: 1.0, green: 0.72, blue: 0.22),   // Amber
        Color(red: 0.68, green: 0.38, blue: 1.0),   // Purple
        Color(red: 0.20, green: 0.85, blue: 0.90),  // Cyan
        Color(red: 1.0, green: 0.52, blue: 0.25),   // Orange
        Color(red: 0.92, green: 0.85, blue: 0.20),  // Yellow
    ]

    // MARK: - Phase Colors (solid colors for in-game backgrounds)
    static let phase1Color = Color(red: 0.29, green: 0.23, blue: 1.0)       // #4A3AFF Indigo
    static let phase2Color = Color(red: 1.0, green: 0.55, blue: 0.0)        // #FF8C00 Orange
    static let phase3Color = Color(red: 1.0, green: 0.23, blue: 0.29)       // #FF3B4A Red

    // Arrays kept for AnimatedBackgroundView compatibility
    static let phase1Colors: [Color] = [phase1Color]
    static let phase2Colors: [Color] = [phase2Color]
    static let phase3Colors: [Color] = [phase3Color]
    static let startColors: [Color] = [Color.black]

    // MARK: - Typography (SF Rounded, bolder & bigger)
    static let largeTitleFont = Font.system(size: 40, weight: .black, design: .rounded)
    static let titleFont = Font.system(size: 34, weight: .heavy, design: .rounded)
    static let headlineFont = Font.system(size: 24, weight: .bold, design: .rounded)
    static let bodyFont = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let calloutFont = Font.system(size: 16, weight: .medium, design: .rounded)
    static let captionFont = Font.system(size: 14, weight: .medium, design: .rounded)
    static let timerFont = Font.system(size: 64, weight: .black, design: .rounded)
    static let cardValueFont = Font.system(size: 42, weight: .bold, design: .rounded)

    // MARK: - Spacing & Layout
    static let padding: CGFloat = 20
    static let cornerRadius: CGFloat = 16
    static let buttonHeight: CGFloat = 56
    static let sectionSpacing: CGFloat = 24
    static let itemSpacing: CGFloat = 12
    static let buttonBottomPadding: CGFloat = 34

    // MARK: - Game-Specific Colors
    static let busfahrerColor = phase1Color  // Indigo #4A3AFF
    static let pferderennenColor = Color(red: 0.15, green: 0.55, blue: 0.25) // Forest Green #278F40
    static let pferderennenColors: [Color] = [pferderennenColor]
    static let kingsCupColor = Color(red: 0.75, green: 0.15, blue: 0.55)    // Royal Purple/Magenta
    static let kingsCupColors: [Color] = [kingsCupColor]
    static let ftdColor = Color(red: 0.85, green: 0.35, blue: 0.10)       // Fiery Orange #D95A1A
    static let ftdColors: [Color] = [ftdColor]

    // MARK: - Detail View Typography
    static let detailTitleFont = Font.system(size: 38, weight: .black, design: .rounded)

    // MARK: - Spring Animations
    static let springSnappy = Animation.spring(response: 0.35, dampingFraction: 0.7)
    static let springBouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let springSmooth = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let springDramatic = Animation.spring(response: 0.7, dampingFraction: 0.5)
}

// MARK: - Pressable Button Style (app-wide)

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Staggered Appear Modifier

struct StaggeredAppear: ViewModifier {
    let index: Int
    let appear: Bool
    var delay: Double = 0.06

    func body(content: Content) -> some View {
        content
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 16)
            .animation(
                Theme.springSmooth.delay(Double(index) * delay),
                value: appear
            )
    }
}

extension View {
    func staggeredAppear(index: Int, appear: Bool, delay: Double = 0.06) -> some View {
        modifier(StaggeredAppear(index: index, appear: appear, delay: delay))
    }
}
