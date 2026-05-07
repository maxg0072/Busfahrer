import SwiftUI

struct KingsCupGameOverView: View {
    @Environment(GameViewModel.self) private var game
    @State private var appear = false
    @State private var showEmojiExplosion = false

    private func safePlayer(_ index: Int) -> (name: String, color: Color) {
        guard index < game.players.count else { return ("", .clear) }
        return (game.players[index].name, game.players[index].color)
    }

    private var loserIndex: Int? {
        // The player who drew the 4th king
        switch game.phase {
        case .kingsCupGameOver:
            // Last player who drew (check who has the most sipsReceived from kings cup)
            return nil // We'll show the info differently
        default:
            return nil
        }
    }

    var body: some View {
        ZStack {
        VStack(spacing: Theme.sectionSpacing) {
            Spacer()

            // Crown + cup
            VStack(spacing: 16) {
                Text("👑🍺")
                    .font(.system(size: 70))
                    .scaleEffect(appear ? 1.0 : 0.3)

                Text(Strings.kingsCup.kingsCupFull)
                    .font(Theme.titleFont)
                    .foregroundStyle(Theme.gold)
                    .multilineTextAlignment(.center)

                Text(Strings.kingsCup.title)
                    .font(Theme.headlineFont)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .opacity(appear ? 1.0 : 0.0)

            // Stats
            VStack(spacing: 0) {
                ForEach(Array(game.players.enumerated()), id: \.element.id) { idx, player in
                    HStack {
                        Circle()
                            .fill(player.color)
                            .frame(width: 12, height: 12)
                        Text(player.name)
                            .font(Theme.bodyFont)
                            .foregroundStyle(.white)
                        Spacer()
                        Text("↓\(player.sipsReceived)")
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.accentRed.opacity(0.8))
                        Text("↑\(player.sipsDistributed)")
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.accentGreen.opacity(0.8))
                            .padding(.leading, 8)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .staggeredAppear(index: idx + 2, appear: appear, delay: 0.08)

                    if idx < game.players.count - 1 {
                        Theme.separator.frame(height: 1).padding(.leading, 38)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .fill(Theme.cardBg)
            )
            .padding(.horizontal, Theme.padding)
            .opacity(appear ? 1.0 : 0.0)

            Spacer()

            // Action buttons
            VStack(spacing: Theme.itemSpacing) {
                Button {
                    HapticManager.selection()
                    game.startKingsCup()
                } label: {
                    Text(Strings.gameEnd.newGame)
                        .font(Theme.bodyFont)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.buttonHeight)
                        .background(Theme.cardBg)
                        .clipShape(Capsule())
                }
                .buttonStyle(PressableButtonStyle())

                Button {
                    HapticManager.selection()
                    game.exitGame()
                } label: {
                    Text(Strings.gameEnd.quit)
                        .font(Theme.bodyFont)
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.buttonHeight)
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.horizontal, Theme.padding)
            .padding(.bottom, Theme.buttonBottomPadding)
            .opacity(appear ? 1.0 : 0.0)
        }
        .task {
            withAnimation(Theme.springDramatic) { appear = true }
            HapticManager.celebration()
            try? await Task.sleep(for: .milliseconds(300))
            withAnimation { showEmojiExplosion = true }
        }

            if showEmojiExplosion {
                EmojiExplosionView(emojis: ["👑", "🍺", "🎉", "💀", "🔥"], count: 16, particleSize: 32)
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }
        } // ZStack
    }
}
