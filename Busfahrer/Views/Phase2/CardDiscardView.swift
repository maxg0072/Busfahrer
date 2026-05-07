import SwiftUI

struct CardDiscardView: View {
    @Environment(GameViewModel.self) private var game
    let row: Int
    let cardIndex: Int
    let playerIndex: Int
    @State private var discardAppear = false

    var player: Player {
        playerIndex < game.players.count ? game.players[playerIndex] : Player(name: "", color: .clear)
    }

    var pyramidCard: Card? {
        guard row < game.pyramidCards.count, cardIndex < game.pyramidCards[row].count else { return nil }
        return game.pyramidCards[row][cardIndex]
    }

    var matchingCards: [Card] {
        guard let card = pyramidCard else { return [] }
        return player.cardsMatching(value: card.value)
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Show what pyramid card was revealed
            VStack(spacing: 8) {
                Text(Strings.phase2.revealed(pyramidCard?.displayName ?? ""))
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white.opacity(0.8))

                Text(Strings.phase2.rowLabel(row + 1, game.sipsForRow(row)))
                    .font(Theme.captionFont)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .opacity(discardAppear ? 1 : 0)
            .offset(y: discardAppear ? 0 : 10)

            // Player prompt
            VStack(spacing: 12) {
                Text(player.name)
                    .font(Theme.titleFont)
                    .foregroundStyle(player.color)
                    .scaleEffect(discardAppear ? 1.0 : 0.8)

                Text(Strings.phase2.discardPrompt(pyramidCard?.value.fullName ?? ""))
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                // Show matching cards
                HStack(spacing: 8) {
                    ForEach(matchingCards) { card in
                        CardView(card: card, faceUp: true, compact: true)
                    }
                }
            }
            .opacity(discardAppear ? 1 : 0)

            HStack(spacing: 16) {
                Button {
                    HapticManager.selection()
                    game.phase2PlayerDiscard(row: row, cardIndex: cardIndex, playerIndex: playerIndex, discard: false)
                } label: {
                    Text(Strings.common.no)
                        .font(Theme.bodyFont)
                        .foregroundStyle(.white.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.buttonHeight)
                        .background(Theme.cardBgElevated)
                        .clipShape(Capsule())
                }
                .buttonStyle(PressableButtonStyle())

                Button {
                    HapticManager.correct()
                    game.phase2PlayerDiscard(row: row, cardIndex: cardIndex, playerIndex: playerIndex, discard: true)
                } label: {
                    Text(Strings.phase2.yesDiscard)
                        .font(Theme.bodyFont)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.buttonHeight)
                        .background(Theme.cardBg)
                        .clipShape(Capsule())
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.horizontal, Theme.padding)
            .opacity(discardAppear ? 1 : 0)

            Spacer()
        }
        .animation(Theme.springBouncy, value: discardAppear)
        .onAppear {
            discardAppear = false
            withAnimation(Theme.springBouncy) { discardAppear = true }
        }
    }
}
