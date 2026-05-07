import SwiftUI

struct Phase1View: View {
    @Environment(GameViewModel.self) private var game
    @State private var showShake = false
    @State private var showSparkles = false
    @State private var showEmojiExplosion = false
    @State private var showRedFlash = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with round info
            phase1Header
                .padding(.top, 12)

            Spacer()

            // Main content
            ZStack {
                switch game.phase {
                case .phase1(let round, let playerIndex):
                    CardGuessView(round: round, playerIndex: playerIndex)

                case .phase1Reveal(let round, let playerIndex):
                    revealView(round: round, playerIndex: playerIndex)

                case .phase1SipDistribution(_, let playerIndex, let sipsRemaining):
                    SipDistributionView(
                        distributorIndex: playerIndex,
                        sipsRemaining: sipsRemaining
                    )

                default:
                    EmptyView()
                }

                // Sparkle overlay for correct guesses
                if showSparkles {
                    SparkleEffectView(color: Theme.correct)
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }

                // Emoji explosion on correct
                if showEmojiExplosion {
                    EmojiExplosionView(emojis: ["🍺", "🍻", "🥂", "🎉", "✨"], count: 12)
                        .transition(.opacity)
                }

                // Red flash on wrong
                if showRedFlash {
                    Rectangle()
                        .fill(Theme.accentRed.opacity(0.15))
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }

            Spacer()

            // Player scroll bar
            playerBar
                .padding(.bottom, 8)
        }
        .modifier(ShakeEffect(animatableData: showShake ? 1 : 0))
    }

    private var phase1Header: some View {
        VStack(spacing: 4) {
            Text(Strings.phase1.header)
                .font(Theme.captionFont)
                .foregroundStyle(.white.opacity(0.75))

            let round = game.phase1Round()
            HStack(spacing: 6) {
                ForEach(1...4, id: \.self) { r in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(r <= round ? .white : .white.opacity(0.25))
                        .frame(height: 5)
                }
            }
            .padding(.horizontal, Theme.padding)
        }
    }

    private func revealView(round: Int, playerIndex: Int) -> some View {
        let player = playerIndex < game.players.count ? game.players[playerIndex] : Player(name: "", color: .clear)
        let isCorrect = game.lastGuessCorrect ?? false

        return VStack(spacing: 20) {
            // Streak banner (shows above card when streak >= 2)
            if isCorrect && game.phase1CorrectStreak >= 2 {
                StreakBannerView(streak: game.phase1CorrectStreak)
            }

            if let card = game.currentCard {
                LargeCardView(card: card)
            }

            // Result text with color
            Text(isCorrect ? Strings.common.correct : Strings.common.wrong)
                .font(Theme.titleFont)
                .foregroundStyle(isCorrect ? Theme.accentGreen : Theme.accentRed)

            // Sip info with animated counter
            VStack(spacing: 6) {
                Text(isCorrect
                     ? Strings.sips.canDistribute(player.name, round)
                     : Strings.sips.mustDrink(player.name, round))
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                // Animated sip number
                Text("\(round)")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(isCorrect ? Theme.accentGreen : Theme.accentRed)
                    .contentTransition(.numericText())
                    .shadow(color: (isCorrect ? Theme.accentGreen : Theme.accentRed).opacity(0.5), radius: 8)
            }
            .padding(.horizontal, Theme.padding)

            Button {
                HapticManager.selection()
                game.phase1AfterReveal()
            } label: {
                Text(Strings.common.continueButton)
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.buttonHeight)
                    .background(Color.black.opacity(0.40))
                    .clipShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal, Theme.padding)
        }
        .onAppear {
            if isCorrect {
                HapticManager.correct()
                // Sparkles
                withAnimation { showSparkles = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { showSparkles = false }
                }
                // Emoji explosion
                withAnimation { showEmojiExplosion = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showEmojiExplosion = false
                }
            } else {
                HapticManager.dangerBuzz()
                // Shake
                withAnimation(.linear(duration: 0.4)) { showShake = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showShake = false }
                // Red flash
                withAnimation(.easeIn(duration: 0.1)) { showRedFlash = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.3)) { showRedFlash = false }
                }
            }
        }
    }

    private var playerBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(game.players.enumerated()), id: \.element.id) { index, player in
                    let isActive: Bool = {
                        switch game.phase {
                        case .phase1(_, let pi), .phase1Reveal(_, let pi), .phase1SipDistribution(_, let pi, _):
                            return index == pi
                        default:
                            return false
                        }
                    }()
                    PlayerBadgeView(player: player, isActive: isActive, compact: true)
                }
            }
            .padding(.horizontal, Theme.padding)
        }
    }
}
