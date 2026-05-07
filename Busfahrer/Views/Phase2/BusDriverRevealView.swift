import SwiftUI

struct BusDriverRevealView: View {
    @Environment(GameViewModel.self) private var game
    @State private var showResult = false
    @State private var showSparkles = false
    @State private var showEmojiExplosion = false
    @State private var namePulse = false

    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                Spacer()

                switch game.phase {
                case .phase2Oracle:
                    OracleAnimationView {
                        withAnimation(.spring(response: 0.5)) {
                            game.phase = .phase2BusDriverReveal
                        }
                    }

                case .phase2BusDriverReveal:
                    busDriverResult

                default:
                    EmptyView()
                }

                Spacer()
            }

            if showSparkles {
                SparkleEffectView(color: Theme.gold)
                    .allowsHitTesting(false)
            }

            if showEmojiExplosion {
                EmojiExplosionView(emojis: ["🚌", "💀", "🍺", "😱", "🔥"], count: 16, particleSize: 32)
                    .transition(.opacity)
            }
        }
    }

    private var busDriverResult: some View {
        VStack(spacing: 24) {
            Text("🚌")
                .font(.system(size: 80))
                .scaleEffect(showResult ? 1.0 : 0.3)
                .opacity(showResult ? 1.0 : 0.0)

            if let driver = game.busDriver {
                Text("\(driver.name)")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(driver.color)
                    .scaleEffect(showResult ? (namePulse ? 1.05 : 1.0) : 0.5)
                    .opacity(showResult ? 1.0 : 0.0)
                    .shadow(color: driver.color.opacity(0.5), radius: namePulse ? 16 : 0)

                Text(Strings.phase2.isBusDriver)
                    .font(Theme.headlineFont)
                    .foregroundStyle(.white)
                    .opacity(showResult ? 1.0 : 0.0)

                // Show remaining cards for all players
                VStack(spacing: 0) {
                    ForEach(Array(game.players.enumerated()), id: \.element.id) { index, player in
                        HStack {
                            Circle()
                                .fill(player.color)
                                .frame(width: 16, height: 16)
                            Text(player.name)
                                .font(Theme.captionFont)
                                .foregroundStyle(.white.opacity(0.85))
                            Spacer()
                            Text(Strings.common.cardsCount(player.cardCount))
                                .font(Theme.captionFont)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                        if index < game.players.count - 1 {
                            Theme.separator
                                .frame(height: 1)
                                .padding(.leading, 48)
                        }
                    }
                }
                .background(Color.black.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                .padding(.horizontal, Theme.padding)
                .opacity(showResult ? 1.0 : 0.0)

                Button {
                    HapticManager.heavy()
                    game.startPhase3()
                } label: {
                    Text(Strings.phase2.startBusRide)
                        .font(Theme.bodyFont)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.buttonHeight)
                        .background(Color.black.opacity(0.40))
                        .clipShape(Capsule())
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.horizontal, Theme.padding)
                .opacity(showResult ? 1.0 : 0.0)
            }
        }
        .task {
            HapticManager.celebration()
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
                showResult = true
            }
            withAnimation(Theme.springSmooth.delay(0.5)) {
                showSparkles = true
            }
            try? await Task.sleep(for: .milliseconds(500))
            withAnimation { showEmojiExplosion = true }
            // Name pulse breathing
            try? await Task.sleep(for: .milliseconds(500))
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                namePulse = true
            }
        }
    }
}
