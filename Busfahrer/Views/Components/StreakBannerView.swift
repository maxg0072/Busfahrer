import SwiftUI

/// An animated streak counter that appears and pulses when players get consecutive correct answers.
struct StreakBannerView: View {
    let streak: Int
    @State private var pulse = false
    @State private var appear = false

    private var streakColor: Color {
        switch streak {
        case 2: return .orange
        case 3: return Color(red: 1.0, green: 0.6, blue: 0.0) // Bright orange
        case 4: return Theme.gold
        default: return Theme.gold
        }
    }

    private var streakEmoji: String {
        switch streak {
        case 2: return "🔥"
        case 3: return "🔥🔥"
        case 4: return "🔥🔥🔥"
        default: return "🔥🔥🔥"
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(streakEmoji)
                .font(.system(size: streak >= 4 ? 24 : 18))

            Text("\(streak)x STREAK!")
                .font(.system(size: streak >= 4 ? 28 : 22, weight: .black, design: .rounded))
                .foregroundStyle(streakColor)
                .shadow(color: streakColor.opacity(0.8), radius: streak >= 3 ? 12 : 6)
        }
        .scaleEffect(appear ? (pulse ? 1.1 : 1.0) : 0.3)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                appear = true
            }
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true).delay(0.4)) {
                pulse = true
            }
            // Streak-intensity haptic
            if streak >= 3 {
                HapticManager.celebration()
            } else {
                HapticManager.correct()
            }
        }
    }
}
