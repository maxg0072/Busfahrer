import SwiftUI

struct OracleAnimationView: View {
    @Environment(GameViewModel.self) private var game
    var onComplete: () -> Void

    @State private var highlightedIndex: Int = 0
    @State private var finished = false
    @State private var animationTask: Task<Void, Never>?

    private var tiedPlayers: [(index: Int, player: Player)] {
        let maxCards = game.players.map { $0.cardCount }.max() ?? 0
        return game.players.enumerated()
            .filter { $0.element.cardCount == maxCards }
            .map { (index: $0.offset, player: $0.element) }
    }

    var body: some View {
        VStack(spacing: 32) {
            Text(Strings.oracle.deciding)
                .font(Theme.headlineFont)
                .foregroundStyle(.white)

            Text(Strings.oracle.tiebreaker)
                .font(Theme.bodyFont)
                .foregroundStyle(.white.opacity(0.8))

            VStack(spacing: Theme.itemSpacing) {
                ForEach(Array(tiedPlayers.enumerated()), id: \.element.index) { i, item in
                    let isHighlighted = highlightedIndex == i

                    HStack(spacing: 12) {
                        Circle()
                            .fill(item.player.color)
                            .frame(width: 32, height: 32)

                        Text(item.player.name)
                            .font(Theme.headlineFont)
                            .foregroundStyle(.white)

                        Spacer()

                        Text(Strings.common.cardsCount(item.player.cardCount))
                            .font(Theme.captionFont)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isHighlighted ? Theme.cardBgElevated : Theme.cardBg)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(isHighlighted ? .white.opacity(0.4) : .clear, lineWidth: 2)
                    )
                    .scaleEffect(isHighlighted && !finished ? 1.05 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isHighlighted)
                }
            }
            .padding(.horizontal, Theme.padding)
        }
        .task {
            await startAnimation()
        }
        .onDisappear {
            animationTask?.cancel()
        }
    }

    private func startAnimation() async {
        let players = tiedPlayers
        guard players.count > 1 else {
            finished = true
            onComplete()
            return
        }

        // Trigger drumroll haptic
        HapticManager.drumroll(duration: 2.0)

        let busDriverIdx = game.busDriverIndex ?? 0
        let targetTiedIndex = players.firstIndex { $0.index == busDriverIdx } ?? 0
        let totalTicks = 20 + targetTiedIndex

        for tick in 0..<totalTicks {
            guard !Task.isCancelled else { return }
            let delay = 100 + tick * 40
            try? await Task.sleep(for: .milliseconds(delay))
            guard !Task.isCancelled else { return }
            highlightedIndex = tick % players.count
            HapticManager.selection()
        }

        finished = true
        HapticManager.celebration()
        try? await Task.sleep(for: .milliseconds(800))
        guard !Task.isCancelled else { return }
        onComplete()
    }
}
