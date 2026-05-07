import SwiftUI

struct CardGuessView: View {
    @Environment(GameViewModel.self) private var game
    let round: Int
    let playerIndex: Int

    @State private var appear = false
    @State private var cardBreathing = false

    var player: Player {
        playerIndex < game.players.count ? game.players[playerIndex] : Player(name: "", color: .clear)
    }

    var body: some View {
        VStack(spacing: 28) {
            // Player name
            Text(player.name)
                .font(Theme.titleFont)
                .foregroundStyle(player.color)
                .scaleEffect(appear ? 1.0 : 0.8)
                .opacity(appear ? 1 : 0)

            // Previous cards reference
            if round >= 2 {
                HStack(spacing: 8) {
                    ForEach(Array(player.hand.enumerated()), id: \.element.id) { _, card in
                        CardView(card: card, faceUp: true, compact: true)
                    }
                }
                .opacity(appear ? 1 : 0)
            }

            // Question
            Text(question)
                .font(Theme.headlineFont)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.padding)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 10)

            // Card back with breathing pulse when interactive
            CardView(card: nil, faceUp: false)
                .glowingBorder(color: .white.opacity(cardBreathing ? 0.4 : 0.2), lineWidth: 1.5, glowRadius: cardBreathing ? 10 : 4, cornerRadius: 10)
                .scaleEffect(appear ? (cardBreathing ? 1.03 : 1.0) : 0.5)

            // Answer buttons (dark pills on phase color)
            VStack(spacing: 10) {
                ForEach(Array(answers.enumerated()), id: \.element) { index, answer in
                    Button {
                        HapticManager.cardFlip()
                        game.phase1Guess(answer: answer)
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
                    .staggeredAppear(index: index + 2, appear: appear, delay: 0.06)
                }
            }
            .padding(.horizontal, Theme.padding)
        }
        .animation(Theme.springBouncy, value: appear)
        .task(id: "\(round)-\(playerIndex)") {
            appear = false
            cardBreathing = false
            withAnimation(Theme.springBouncy) {
                appear = true
            }
            // Start card breathing after entrance
            try? await Task.sleep(for: .milliseconds(600))
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                cardBreathing = true
            }
        }
    }

    private var question: String {
        switch round {
        case 1: return Strings.guess.questionRound1
        case 2: return Strings.guess.questionRound2
        case 3: return Strings.guess.questionRound3
        case 4: return Strings.guess.questionRound4
        default: return ""
        }
    }

    private var answers: [GuessKey] {
        switch round {
        case 1: return [.red, .black]
        case 2: return [.higher, .lower, .equal]
        case 3: return [.inside, .outside, .equal]
        case 4: return [.hearts, .diamonds, .spades, .clubs]
        default: return []
        }
    }
}
