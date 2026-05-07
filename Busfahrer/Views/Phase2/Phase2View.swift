import SwiftUI

struct Phase2View: View {
    @Environment(GameViewModel.self) private var game

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text(Strings.phase2.header)
                .font(Theme.captionFont)
                .foregroundStyle(.white.opacity(0.75))
                .padding(.top, 12)

            switch game.phase {
            case .phase2Setup:
                VStack {
                    Spacer()
                    ProgressView()
                        .tint(.white)
                    Spacer()
                }
                .onAppear { game.setupPyramid() }

            case .phase2(let row, let cardIndex):
                pyramidContent(activeRow: row, activeCard: cardIndex, showPrompt: true)

            case .phase2Reveal(let row, _):
                pyramidRevealContent(row: row)

            case .phase2Discard(let row, let cardIndex, let playerIndex):
                pyramidDiscardContent(row: row, cardIndex: cardIndex, playerIndex: playerIndex)

            case .phase2SipDistribution(_, _, let playerIndex, let sipsRemaining):
                VStack {
                    Spacer()
                    SipDistributionView(distributorIndex: playerIndex, sipsRemaining: sipsRemaining)
                    Spacer()
                }

            default:
                EmptyView()
            }

            // Player bar
            playerBar
                .padding(.bottom, 8)
        }
    }

    private func pyramidContent(activeRow: Int, activeCard: Int, showPrompt: Bool) -> some View {
        VStack(spacing: 16) {
            Spacer()

            PyramidGridView(activeRow: activeRow, activeCard: activeCard)

            if showPrompt {
                Text(Strings.phase2.tapCard)
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white.opacity(0.75))
            }

            Spacer()
        }
    }

    private func pyramidRevealContent(row: Int) -> some View {
        VStack(spacing: 16) {
            Spacer()

            if let card = game.currentCard {
                LargeCardView(card: card)

                Text(Strings.phase2.rowSips(row + 1, game.sipsForRow(row)))
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white)
            }

            Button {
                HapticManager.selection()
                game.phase2AfterReveal()
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

            Spacer()
        }
    }

    private func pyramidDiscardContent(row: Int, cardIndex: Int, playerIndex: Int) -> some View {
        CardDiscardView(row: row, cardIndex: cardIndex, playerIndex: playerIndex)
    }

    private var playerBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(game.players.enumerated()), id: \.element.id) { index, player in
                    let isActive: Bool = {
                        if case .phase2Discard(_, _, let pi) = game.phase { return index == pi }
                        if case .phase2SipDistribution(_, _, let pi, _) = game.phase { return index == pi }
                        return false
                    }()
                    VStack(spacing: 2) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(player.color)
                                .frame(width: 18, height: 18)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white.opacity(isActive ? 0.8 : 0), lineWidth: 2)
                                )
                            Text(player.name)
                                .font(Theme.captionFont)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        }
                        HStack(spacing: 6) {
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
                            Text("· \(Strings.common.cardsCount(player.cardCount))")
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(Theme.textSecondary))
                                .contentTransition(.numericText())
                                .animation(Theme.springSnappy, value: player.cardCount)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isActive ? Theme.cardBgElevated : Theme.cardBg)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(isActive ? .white.opacity(0.3) : .clear, lineWidth: 1.5)
                    )
                }
            }
            .padding(.horizontal, Theme.padding)
        }
    }
}
