import SwiftUI

struct GameEndView: View {
    @Environment(GameViewModel.self) private var game
    @State private var showConfetti = false
    @State private var showSparkles = false
    @State private var showEmojiExplosion = false
    @State private var appear = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: Theme.sectionSpacing) {
                        // Header
                        VStack(spacing: 8) {
                            Text("🎉")
                                .font(.system(size: 60))
                                .scaleEffect(appear ? 1.0 : 0.3)

                            Text(Strings.gameEnd.title)
                                .font(Theme.titleFont)
                                .foregroundStyle(.white)
                                .scaleEffect(appear ? 1.0 : 0.8)
                                .opacity(appear ? 1 : 0)

                            if let driver = game.busDriver {
                                Text(Strings.gameEnd.survived(driver.name))
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(.white.opacity(Theme.textSecondary))
                                    .multilineTextAlignment(.center)
                                    .opacity(appear ? 1 : 0)
                            }
                        }
                        .padding(.top, 20)
                        .animation(Theme.springDramatic, value: appear)

                        // Fun titles (staggered)
                        funTitles

                        // Stats table (dark card)
                        VStack(spacing: 0) {
                            // Header row
                            HStack {
                                Text(Strings.gameEnd.playerColumn)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(Strings.gameEnd.drunkColumn)
                                    .frame(width: 80)
                                Text(Strings.gameEnd.distributedColumn)
                                    .frame(width: 70)
                            }
                            .font(Theme.captionFont)
                            .foregroundStyle(.white.opacity(Theme.textSecondary))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)

                            ForEach(Array(sortedPlayers.enumerated()), id: \.element.id) { index, player in
                                HStack {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(player.color)
                                            .frame(width: 20, height: 20)
                                        Text(player.name)
                                            .font(Theme.bodyFont)
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                    Text("\(player.sipsReceived)")
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(.white.opacity(0.9))
                                        .frame(width: 80)

                                    Text("\(player.sipsDistributed)")
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(.white.opacity(0.9))
                                        .frame(width: 70)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .staggeredAppear(index: index + 4, appear: appear, delay: 0.06)

                                if index < sortedPlayers.count - 1 {
                                    Theme.separator
                                        .frame(height: 1)
                                        .padding(.leading, 44)
                                }
                            }
                        }
                        .background(Theme.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        .padding(.horizontal, Theme.padding)
                    }
                }

                // Action buttons
                VStack(spacing: 10) {
                    Button {
                        HapticManager.selection()
                        game.newGameSamePlayers()
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

                    HStack(spacing: 10) {
                        Button {
                            HapticManager.selection()
                            game.newGameNewPlayers()
                        } label: {
                            Text(Strings.gameEnd.newPlayers)
                                .font(Theme.bodyFont)
                                .foregroundStyle(.white.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Theme.cardBgElevated)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(PressableButtonStyle())

                        Button {
                            HapticManager.selection()
                            game.exitGame()
                        } label: {
                            Text(Strings.gameEnd.quit)
                                .font(Theme.bodyFont)
                                .foregroundStyle(.white.opacity(Theme.textSecondary))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Theme.cardBgElevated)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(.horizontal, Theme.padding)
                .padding(.bottom, Theme.buttonBottomPadding)
                .opacity(appear ? 1 : 0)
                .animation(Theme.springSmooth.delay(0.5), value: appear)
            }

            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            if showSparkles {
                SparkleEffectView(color: Theme.gold, count: 20)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            if showEmojiExplosion {
                EmojiExplosionView(emojis: ["🎉", "🍺", "🏆", "⭐️", "🚌"], count: 18, particleSize: 34)
                    .transition(.opacity)
            }
        }
        .onAppear {
            showConfetti = true
            showSparkles = true
            HapticManager.celebration()
            withAnimation(Theme.springDramatic) {
                appear = true
            }
            // Delayed emoji explosion for extra impact
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { showEmojiExplosion = true }
            }
        }
    }

    private var sortedPlayers: [Player] {
        game.players.sorted { $0.sipsReceived > $1.sipsReceived }
    }

    private var funTitles: some View {
        VStack(spacing: 8) {
            if let schluckKoenig = game.players.max(by: { $0.sipsDistributed < $1.sipsDistributed }),
               schluckKoenig.sipsDistributed > 0 {
                funTitleBadge(
                    title: Strings.gameEnd.sipKing,
                    player: schluckKoenig,
                    detail: Strings.gameEnd.sipsDistributed(schluckKoenig.sipsDistributed),
                    icon: "👑"
                )
                .staggeredAppear(index: 1, appear: appear, delay: 0.12)
            }

            if let pechvogel = game.players.max(by: { $0.sipsReceived < $1.sipsReceived }),
               pechvogel.sipsReceived > 0 {
                funTitleBadge(
                    title: Strings.gameEnd.unlucky,
                    player: pechvogel,
                    detail: Strings.gameEnd.sipsDrunk(pechvogel.sipsReceived),
                    icon: "🍺"
                )
                .staggeredAppear(index: 2, appear: appear, delay: 0.12)
            }

            if let busDriver = game.busDriver {
                funTitleBadge(
                    title: Strings.gameEnd.busDriver,
                    player: busDriver,
                    detail: Strings.gameEnd.failedAttempts(game.phase3TotalAttempts),
                    icon: "🚌"
                )
                .staggeredAppear(index: 3, appear: appear, delay: 0.12)
            }
        }
        .padding(.horizontal, Theme.padding)
    }

    private func funTitleBadge(title: String, player: Player, detail: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 28))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.captionFont)
                    .foregroundStyle(.white.opacity(0.7))
                Text(player.name)
                    .font(Theme.bodyFont)
                    .foregroundStyle(player.color)
            }

            Spacer()

            Text(detail)
                .font(Theme.captionFont)
                .foregroundStyle(.white.opacity(Theme.textSecondary))
        }
        .padding(12)
        .background(Theme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
