import SwiftUI

struct PhaseTransitionView: View {
    @Environment(GameViewModel.self) private var game
    let target: PhaseTarget

    @State private var appear = false
    @State private var emojiBreathing = false
    @State private var buttonGlow = false

    var body: some View {
        VStack(spacing: Theme.sectionSpacing) {
            Spacer()

            Text(icon)
                .font(.system(size: 70))
                .scaleEffect(appear ? (emojiBreathing ? 1.08 : 1.0) : 0.3)

            Text(title)
                .font(Theme.titleFont)
                .foregroundStyle(.white)
                .scaleEffect(appear ? 1.0 : 0.8)

            Text(subtitle)
                .font(Theme.bodyFont)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.padding)
                .opacity(appear ? 1.0 : 0.0)

            // Phase progress dots (staggered pop)
            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(dotFilled(index) ? .white : .white.opacity(0.3))
                        .frame(width: 10, height: 10)
                        .scaleEffect(appear ? 1.0 : 0.0)
                        .animation(Theme.springBouncy.delay(0.3 + Double(index) * 0.1), value: appear)
                }
            }

            Spacer()

            Button {
                HapticManager.heartbeat()
                advance()
            } label: {
                Text(Strings.transition.letsGo)
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.buttonHeight)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(.white.opacity(buttonGlow ? 0.4 : 0.1), lineWidth: 1.5)
                    )
                    .shadow(color: .white.opacity(buttonGlow ? 0.15 : 0), radius: 12)
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal, Theme.padding)
            .padding(.bottom, Theme.buttonBottomPadding)
            .opacity(appear ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                appear = true
            }
            // Start breathing emoji
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.8)) {
                emojiBreathing = true
            }
            // Start button glow pulse
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(1.0)) {
                buttonGlow = true
            }
        }
    }

    private func dotFilled(_ index: Int) -> Bool {
        switch target {
        case .phase1: return index == 0
        case .phase2: return index <= 1
        case .phase3: return true
        case .gameEnd: return true
        case .pferderennenRace: return true
        case .kingsCup: return true
        case .fckTheDealer: return true
        }
    }

    private var icon: String {
        switch target {
        case .phase1: return "🃏"
        case .phase2: return "🔺"
        case .phase3: return "🚌"
        case .gameEnd: return "🎉"
        case .pferderennenRace: return "🏇"
        case .kingsCup: return "👑"
        case .fckTheDealer: return "🃏"
        }
    }

    private var title: String {
        switch target {
        case .phase1: return "Phase 1"
        case .phase2: return "Phase 2"
        case .phase3: return Strings.transition.phase3Title
        case .gameEnd: return Strings.transition.gameEndTitle
        case .pferderennenRace: return Strings.pferderennen.raceStarting
        case .kingsCup: return "Kings Cup"
        case .fckTheDealer: return "F*ck the Dealer"
        }
    }

    private var subtitle: String {
        switch target {
        case .phase1: return Strings.transition.phase1Subtitle
        case .phase2: return Strings.transition.phase2Subtitle
        case .phase3:
            if let driver = game.busDriver {
                return Strings.transition.phase3Subtitle(driver.name)
            }
            return Strings.transition.phase3SubtitleGeneric
        case .gameEnd: return Strings.transition.gameOverSubtitle
        case .pferderennenRace: return Strings.pferderennen.flavorText
        case .kingsCup: return Strings.kingsCup.flavorText
        case .fckTheDealer: return Strings.ftd.flavorText
        }
    }

    private func advance() {
        switch target {
        case .phase1: game.beginPhase1()
        case .phase2: game.phase = .phase2Setup
        case .phase3: break
        case .gameEnd: game.phase = .gameEnd
        case .pferderennenRace: game.pferderennenStartRace()
        case .kingsCup: game.kingsCupBeginGame()
        case .fckTheDealer: game.ftdBeginGame()
        }
    }
}
