import SwiftUI

struct FTDGameOverView: View {
    @Environment(GameViewModel.self) private var game
    @State private var appear = false
    @State private var showEmojiExplosion = false

    var body: some View {
        ZStack {
        VStack(spacing: Theme.sectionSpacing) {
            Spacer()

            VStack(spacing: 16) {
                Text("🃏")
                    .font(.system(size: 70))
                    .scaleEffect(appear ? 1.0 : 0.3)

                Text(LanguageManager.shared.current == .de ? "Alle Karten gespielt!" : "All cards played!")
                    .font(Theme.titleFont)
                    .foregroundStyle(.white)

                Text("F*ck the Dealer")
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

            VStack(spacing: Theme.itemSpacing) {
                Button {
                    HapticManager.selection()
                    game.startFckTheDealer()
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
                EmojiExplosionView(emojis: ["🃏", "🍺", "🎉", "✨", "😵"], count: 16, particleSize: 32)
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }
        } // ZStack
    }
}
