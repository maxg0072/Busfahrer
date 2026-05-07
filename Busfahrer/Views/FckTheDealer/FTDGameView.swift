import SwiftUI

struct FTDGameView: View {
    @Environment(GameViewModel.self) private var game
    @State private var appear = false
    @State private var hintAppear = false
    @State private var hintBounce = false
    @State private var revealAppear = false
    @State private var showEmojiExplosion = false
    @State private var showRedFlash = false
    @State private var showShake = false

    private var dealerIndex: Int {
        switch game.phase {
        case .ftdGuess1(let d, _), .ftdHint(let d, _), .ftdGuess2(let d, _),
             .ftdReveal(let d, _), .ftdDrink(let d, _):
            return d
        default: return 0
        }
    }

    private var guesserIndex: Int {
        switch game.phase {
        case .ftdGuess1(_, let g), .ftdHint(_, let g), .ftdGuess2(_, let g),
             .ftdReveal(_, let g), .ftdDrink(_, let g):
            return g
        default: return 0
        }
    }

    private func safePlayer(_ index: Int) -> (name: String, color: Color) {
        guard index < game.players.count else { return ("", .clear) }
        return (game.players[index].name, game.players[index].color)
    }

    // All card values for the guess grid (2-14 / Ace high)
    private let cardValues: [(value: Int, label: String)] = [
        (2, "2"), (3, "3"), (4, "4"), (5, "5"), (6, "6"), (7, "7"),
        (8, "8"), (9, "9"), (10, "10"), (11, "B"), (12, "D"), (13, "K"), (14, "A")
    ]

    var body: some View {
        ZStack {
            switch game.phase {
            case .ftdGuess1:
                guessView(isSecondGuess: false)
            case .ftdHint:
                hintView
            case .ftdGuess2:
                guessView(isSecondGuess: true)
            case .ftdReveal:
                revealView
            default:
                EmptyView()
            }

            // Emoji explosion on correct
            if showEmojiExplosion {
                EmojiExplosionView(emojis: ["🎉", "✨", "🍺", "💪", "😵"], count: 14, particleSize: 30)
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
        .modifier(ShakeEffect(animatableData: showShake ? 1 : 0))
    }

    // MARK: - Guess View (1st or 2nd)

    private func guessView(isSecondGuess: Bool) -> some View {
        let guesser = safePlayer(guesserIndex)
        let dealer = safePlayer(dealerIndex)

        return VStack(spacing: 16) {
            // Status bar
            VStack(spacing: 6) {
                Text(Strings.ftd.dealerIs(dealer.name))
                    .font(Theme.captionFont)
                    .foregroundStyle(.white.opacity(0.5))
                Text("\(game.ftdCardsPlayed)/52 \(Strings.ftd.cardsPlayed)")
                    .font(Theme.captionFont)
                    .foregroundStyle(.white.opacity(0.4))
                    .contentTransition(.numericText())
                    .animation(Theme.springSnappy, value: game.ftdCardsPlayed)
                if game.ftdConsecutiveWrong > 0 {
                    Text(Strings.ftd.dealerSurvived(game.ftdConsecutiveWrong))
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.gold.opacity(0.7))
                        .contentTransition(.numericText())
                        .animation(Theme.springSnappy, value: game.ftdConsecutiveWrong)
                }
            }
            .padding(.top, 60)
            .opacity(appear ? 1 : 0)

            Spacer()

            // Player prompt
            VStack(spacing: 8) {
                Text(Strings.ftd.guesserTurn(guesser.name))
                    .font(Theme.headlineFont)
                    .foregroundStyle(.white)

                Text(isSecondGuess ? Strings.ftd.secondGuess : Strings.ftd.firstGuess)
                    .font(Theme.calloutFont)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .opacity(appear ? 1 : 0)
            .scaleEffect(appear ? 1.0 : 0.8)

            // Card value grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                ForEach(Array(cardValues.enumerated()), id: \.element.value) { idx, cv in
                    let isEliminated = game.ftdDiscardedValues.filter({ $0 == cv.value }).count >= 4
                    Button {
                        HapticManager.heavy()
                        if isSecondGuess {
                            game.ftdMakeGuess2(value: cv.value)
                        } else {
                            game.ftdMakeGuess1(value: cv.value)
                        }
                    } label: {
                        Text(cv.label)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(isEliminated ? .white.opacity(0.2) : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(isEliminated ? Theme.cardBg.opacity(0.3) : Theme.cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(isEliminated ? .clear : .white.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .disabled(isEliminated)
                    .staggeredAppear(index: idx + 2, appear: appear, delay: 0.04)
                }
            }
            .padding(.horizontal, Theme.padding)

            // Discarded cards summary
            discardSummary

            Spacer()
        }
        .animation(Theme.springBouncy, value: appear)
        .task(id: "guess-\(isSecondGuess)-\(game.ftdCardsPlayed)") {
            appear = false
            withAnimation(Theme.springBouncy) {
                appear = true
            }
        }
    }

    // MARK: - Hint View

    private var hintView: some View {
        let guesser = safePlayer(guesserIndex)
        let isHigher = game.ftdHintIsHigher

        return VStack(spacing: Theme.sectionSpacing) {
            Spacer()

            VStack(spacing: 16) {
                Text(isHigher ? "⬆️" : "⬇️")
                    .font(.system(size: 70))
                    .scaleEffect(hintAppear ? (hintBounce ? 1.15 : 1.0) : 0.3)
                    .offset(y: hintBounce ? (isHigher ? -8 : 8) : 0)

                Text(isHigher
                     ? Strings.ftd.hintHigher(guesser.name)
                     : Strings.ftd.hintLower(guesser.name))
                    .font(Theme.headlineFont)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .opacity(hintAppear ? 1 : 0)
                    .scaleEffect(hintAppear ? 1.0 : 0.8)

                if let guess1 = game.ftdGuess1Value {
                    Text(LanguageManager.shared.current == .de
                         ? "Dein Tipp war: \(displayValue(guess1))"
                         : "Your guess was: \(displayValue(guess1))")
                        .font(Theme.calloutFont)
                        .foregroundStyle(.white.opacity(0.6))
                        .opacity(hintAppear ? 1 : 0)
                }
            }

            Spacer()

            Button {
                HapticManager.selection()
                game.ftdProceedFromHint()
            } label: {
                Text(Strings.common.continueButton)
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.buttonHeight)
                    .background(Theme.cardBg)
                    .clipShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal, Theme.padding)
            .padding(.bottom, Theme.buttonBottomPadding)
            .opacity(hintAppear ? 1 : 0)
        }
        .animation(Theme.springBouncy, value: hintAppear)
        .task(id: "hint-\(game.ftdCardsPlayed)") {
            hintAppear = false
            hintBounce = false
            withAnimation(Theme.springBouncy) {
                hintAppear = true
            }
            try? await Task.sleep(for: .milliseconds(500))
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                hintBounce = true
            }
        }
    }

    // MARK: - Reveal View

    private var revealView: some View {
        let guesser = safePlayer(guesserIndex)
        let dealer = safePlayer(dealerIndex)
        let isCorrect = game.ftdCorrectOnGuess != nil

        return VStack(spacing: Theme.sectionSpacing) {
            Spacer()

            // Show the card
            if let card = game.ftdCurrentCard {
                LargeCardView(card: card)
            }

            // Result message
            VStack(spacing: 8) {
                if let correctGuess = game.ftdCorrectOnGuess {
                    Text("🎉")
                        .font(.system(size: 50))
                        .scaleEffect(revealAppear ? 1.0 : 0.3)
                    Text(correctGuess == 1
                         ? Strings.ftd.correctGuess1(dealer.name)
                         : Strings.ftd.correctGuess2(dealer.name))
                        .font(Theme.headlineFont)
                        .foregroundStyle(Theme.accentGreen)
                        .multilineTextAlignment(.center)
                        .opacity(revealAppear ? 1 : 0)
                } else {
                    Text("😵")
                        .font(.system(size: 50))
                        .scaleEffect(revealAppear ? 1.0 : 0.3)
                    if let guess2 = game.ftdGuess2Value, let card = game.ftdCurrentCard {
                        let diff = abs(guess2 - card.value.rawValue)
                        Text(Strings.ftd.wrongBothGuesses(guesser.name, diff))
                            .font(Theme.headlineFont)
                            .foregroundStyle(.white)
                            .shadow(color: Theme.accentRed, radius: 8)
                            .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                            .multilineTextAlignment(.center)
                            .opacity(revealAppear ? 1 : 0)

                        // Dramatic difference counter
                        if diff > 0 {
                            Text("\(diff)")
                                .font(.system(size: 42, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .shadow(color: Theme.accentRed, radius: 12)
                                .shadow(color: .black.opacity(0.6), radius: 4, y: 2)
                                .contentTransition(.numericText())
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.padding)

            Spacer()

            Button {
                HapticManager.selection()
                game.ftdAfterReveal()
            } label: {
                Text(Strings.common.continueButton)
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.buttonHeight)
                    .background(Theme.cardBg)
                    .clipShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal, Theme.padding)
            .padding(.bottom, Theme.buttonBottomPadding)
            .opacity(revealAppear ? 1 : 0)
        }
        .animation(Theme.springBouncy, value: revealAppear)
        .task(id: "reveal-\(isCorrect)-\(game.ftdCardsPlayed)") {
            revealAppear = false
            withAnimation(Theme.springBouncy) {
                revealAppear = true
            }
            if isCorrect {
                HapticManager.correct()
                withAnimation { showEmojiExplosion = true }
                try? await Task.sleep(for: .milliseconds(1500))
                showEmojiExplosion = false
            } else {
                HapticManager.dangerBuzz()
                withAnimation(.linear(duration: 0.4)) { showShake = true }
                withAnimation(.easeIn(duration: 0.1)) { showRedFlash = true }
                try? await Task.sleep(for: .milliseconds(500))
                showShake = false
                withAnimation(.easeOut(duration: 0.3)) { showRedFlash = false }
            }
        }
    }

    // MARK: - Helpers

    private func displayValue(_ v: Int) -> String {
        switch v {
        case 11: return LanguageManager.shared.current == .de ? "Bube" : "Jack"
        case 12: return LanguageManager.shared.current == .de ? "Dame" : "Queen"
        case 13: return LanguageManager.shared.current == .de ? "König" : "King"
        case 14: return LanguageManager.shared.current == .de ? "Ass" : "Ace"
        default: return "\(v)"
        }
    }

    private var discardCounts: [Int: Int] {
        Dictionary(game.ftdDiscardedValues.map { ($0, 1) }, uniquingKeysWith: +)
    }

    private var discardSummary: some View {
        let counts = discardCounts

        return HStack(spacing: 4) {
            ForEach(cardValues, id: \.value) { cv in
                let count = counts[cv.value] ?? 0
                if count > 0 {
                    Text("\(cv.label)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(count >= 4 ? 0.2 : 0.5))
                        .frame(width: 22, height: 22)
                        .background(
                            Circle()
                                .fill(count >= 4 ? Theme.accentRed.opacity(0.2) : Theme.cardBg)
                        )
                }
            }
        }
        .padding(.horizontal, Theme.padding)
    }
}
