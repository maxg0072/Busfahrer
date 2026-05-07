import SwiftUI

/// A pulsing ring around the card that intensifies with Phase 3 danger level.
/// Shows round progress (1/4 to 4/4) and pulses faster at higher danger.
struct TensionRingView: View {
    let round: Int          // 1-4
    let totalAttempts: Int  // how many restarts

    @State private var pulse = false
    @State private var rotate = false

    private var progress: CGFloat {
        CGFloat(round) / 4.0
    }

    private var dangerLevel: Double {
        min(Double(totalAttempts) / 6.0, 1.0)
    }

    private var ringColor: Color {
        if totalAttempts >= 4 {
            return Theme.accentRed
        } else if totalAttempts >= 2 {
            return .orange
        } else {
            return .white.opacity(0.6)
        }
    }

    private var pulseSpeed: Double {
        // Faster pulse = more tension
        max(0.4, 1.2 - dangerLevel * 0.8)
    }

    var body: some View {
        ZStack {
            // Background ring (faint)
            Circle()
                .strokeBorder(.white.opacity(0.1), lineWidth: 4)
                .frame(width: 120, height: 120)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))
                .rotationEffect(.degrees(rotate ? 360 : 0))
                .shadow(color: ringColor.opacity(0.6), radius: pulse ? 12 : 4)

            // Outer glow ring (danger only)
            if totalAttempts >= 2 {
                Circle()
                    .strokeBorder(ringColor.opacity(pulse ? 0.3 : 0.1), lineWidth: 2)
                    .frame(width: 140, height: 140)
            }

            // Round indicator
            VStack(spacing: 2) {
                Text("\(round)/4")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(ringColor)
            }
            .offset(y: 72)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: pulseSpeed).repeatForever(autoreverses: true)) {
                pulse = true
            }
            if totalAttempts >= 3 {
                withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                    rotate = true
                }
            }
        }
    }
}
