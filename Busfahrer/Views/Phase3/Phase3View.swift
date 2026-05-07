import SwiftUI

struct Phase3View: View {
    @Environment(GameViewModel.self) private var game
    @State private var showShake = false
    @State private var showSparkles = false
    @State private var showRedFlash = false
    @State private var showConfetti = false
    @State private var guessAppear = false
    @State private var showEmojiExplosion = false

    // Danger intensity scales with attempts (0.0 to 1.0)
    private var dangerIntensity: Double {
        min(Double(game.phase3TotalAttempts) / 8.0, 1.0)
    }

    var body: some View {
        ZStack {
            // Dark vignette that intensifies with attempts
            if dangerIntensity > 0 {
                RadialGradient(
                    colors: [.clear, .black.opacity(0.25 * dangerIntensity)],
                    center: .center,
                    startRadius: 100,
                    endRadius: 500
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)
            }

            VStack(spacing: 0) {
                // Header
                phase3Header
                    .padding(.top, 12)

                Spacer()

                switch game.phase {
                case .phase3(let round, let attempt):
                    phase3GuessView(round: round, attempt: attempt)

                case .phase3Reveal(let round, _):
                    phase3RevealView(round: round)

                default:
                    EmptyView()
                }

                Spacer()

                // Current attempt cards
                if !game.phase3Cards.isEmpty {
                    VStack(spacing: 4) {
                        Text(Strings.phase3.currentCards)
                            .font(Theme.captionFont)
                            .foregroundStyle(.white.opacity(0.7))

                        HStack(spacing: 8) {
                            ForEach(game.phase3Cards) { card in
                                CardView(card: card, faceUp: true, compact: true)
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }

                // Player bar with sip counts
                playerBar
                    .padding(.bottom, 8)
            }
            .modifier(ShakeEffect(animatableData: showShake ? 1 : 0))

            // Dark flash on wrong
            if showRedFlash {
                Rectangle()
                    .fill(.black.opacity(0.35))
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            // Sparkles for correct
            if showSparkles {
                SparkleEffectView(color: Theme.correct)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            // Emoji explosion on correct
            if showEmojiExplosion {
                EmojiExplosionView(emojis: ["🍺", "🎉", "✨", "🚌", "💪"], count: 15, particleSize: 32)
                    .transition(.opacity)
            }

            // Confetti for round 4 completion
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                SparkleEffectView(color: Theme.gold, count: 40)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
    }

    private var playerBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(game.players) { player in
                    let isBusDriver = game.busDriver?.id == player.id
                    HStack(spacing: 6) {
                        Circle()
                            .fill(player.color)
                            .frame(width: 18, height: 18)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white.opacity(isBusDriver ? 0.8 : 0), lineWidth: 2)
                            )
                        Text(player.name)
                            .font(Theme.captionFont)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Label("\(player.sipsReceived)", systemImage: "arrow.down.circle.fill")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                            .contentTransition(.numericText())
                            .animation(Theme.springSnappy, value: player.sipsReceived)
                        Label("\(player.sipsDistributed)", systemImage: "arrow.up.circle.fill")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                            .contentTransition(.numericText())
                            .animation(Theme.springSnappy, value: player.sipsDistributed)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isBusDriver ? Theme.cardBgElevated : Theme.cardBg)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(isBusDriver ? .white.opacity(0.3) : .clear, lineWidth: 1.5)
                    )
                }
            }
            .padding(.horizontal, Theme.padding)
        }
    }

    private var phase3Header: some View {
        VStack(spacing: 8) {
            if let driver = game.busDriver {
                HStack(spacing: 8) {
                    Text(Strings.phase3.busRide)
                        .font(Theme.bodyFont)
                        .foregroundStyle(.white.opacity(0.9))
                    Text(driver.name)
                        .font(Theme.bodyFont)
                        .foregroundStyle(driver.color)
                }
            }

            HStack(spacing: 16) {
                if game.phase3TotalAttempts > 0 {
                    Label(Strings.phase3.attempt(game.phase3TotalAttempts + 1), systemImage: "arrow.counterclockwise")
                        .font(Theme.captionFont)
                        .foregroundStyle(.white.opacity(0.75))
                }

                if let driver = game.busDriver {
                    Label(Strings.sips.count(driver.sipsReceived), systemImage: "drop.fill")
                        .font(Theme.captionFont)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }

            // Round progress
            let currentRound: Int = {
                switch game.phase {
                case .phase3(let r, _), .phase3Reveal(let r, _): return r
                default: return 1
                }
            }()

            HStack(spacing: 6) {
                ForEach(1...4, id: \.self) { r in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(r < currentRound ? .white :
                                r == currentRound ? .white.opacity(0.8) : .white.opacity(0.25))
                        .frame(height: 5)
                }
            }
            .padding(.horizontal, Theme.padding)
        }
    }

    private func phase3GuessView(round: Int, attempt: Int) -> some View {
        VStack(spacing: 28) {
            Text(question(for: round))
                .font(Theme.headlineFont)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.padding)
                .opacity(guessAppear ? 1 : 0)
                .offset(y: guessAppear ? 0 : 10)

            ZStack {
                // Tension ring around card
                TensionRingView(round: round, totalAttempts: game.phase3TotalAttempts)

                CardView(card: nil, faceUp: false)
                    .glowingBorder(
                        color: Theme.wrong.opacity(0.3 + dangerIntensity * 0.4),
                        lineWidth: 1.5,
                        glowRadius: 4 + dangerIntensity * 4,
                        cornerRadius: 10
                    )
            }
            .scaleEffect(guessAppear ? 1.0 : 0.5)

            VStack(spacing: 10) {
                ForEach(Array(answers(for: round).enumerated()), id: \.element) { index, answer in
                    Button {
                        HapticManager.cardFlip()
                        game.phase3Guess(answer: answer)
                    } label: {
                        Text(answer.displayName)
                            .font(Theme.bodyFont)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: Theme.buttonHeight)
                            .background(Color.black.opacity(0.40))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .staggeredAppear(index: index + 2, appear: guessAppear, delay: 0.06)
                }
            }
            .padding(.horizontal, Theme.padding)
        }
        .animation(Theme.springBouncy, value: guessAppear)
        .onAppear {
            guessAppear = false
            // Tension haptic before showing the card
            if game.phase3TotalAttempts > 0 {
                HapticManager.tensionBuild(duration: 0.6)
            }
            withAnimation(Theme.springBouncy) {
                guessAppear = true
            }
        }
    }

    private func phase3RevealView(round: Int) -> some View {
        let isCorrect = game.lastGuessCorrect ?? false

        return VStack(spacing: 24) {
            if let card = game.currentCard {
                LargeCardView(card: card)
            }

            Text(isCorrect ? Strings.common.correct : Strings.common.wrong)
                .font(Theme.titleFont)
                .foregroundStyle(isCorrect ? Theme.accentGreen : Theme.accentRed)

            if !isCorrect {
                // Dramatic sip penalty counter
                Text("+\(round)")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.accentRed)
                    .shadow(color: Theme.accentRed.opacity(0.6), radius: 12)
                    .contentTransition(.numericText())

                Text(Strings.phase3.wrongMessage(round))
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.padding)
            } else if round >= 4 {
                Text(Strings.phase3.completed)
                    .font(Theme.headlineFont)
                    .foregroundStyle(Theme.gold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.padding)
                    .shadow(color: Theme.gold.opacity(0.5), radius: 10)
            } else {
                Text(Strings.phase3.nextRound(round + 1))
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.accentGreen)
            }

            Button {
                HapticManager.selection()
                game.phase3AfterReveal()
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
                withAnimation { showSparkles = true }
                withAnimation { showEmojiExplosion = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { showSparkles = false }
                    showEmojiExplosion = false
                }
                // Round 4 correct = massive celebration
                if round >= 4 {
                    HapticManager.celebration()
                    withAnimation { showConfetti = true }
                }
            } else {
                HapticManager.dangerBuzz()
                // Simultaneous punishment stack: shake + flash + haptic
                withAnimation(.linear(duration: 0.4)) { showShake = true }
                withAnimation(.easeIn(duration: 0.1)) { showRedFlash = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showShake = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeOut(duration: 0.4)) { showRedFlash = false }
                }
            }
        }
    }

    private func question(for round: Int) -> String {
        switch round {
        case 1: return Strings.guess.questionRound1
        case 2: return Strings.guess.questionRound2
        case 3: return Strings.guess.questionRound3
        case 4: return Strings.guess.questionRound4
        default: return ""
        }
    }

    private func answers(for round: Int) -> [GuessKey] {
        switch round {
        case 1: return [.red, .black]
        case 2: return [.higher, .lower, .equal]
        case 3: return [.inside, .outside, .equal]
        case 4: return [.hearts, .diamonds, .spades, .clubs]
        default: return []
        }
    }
}
