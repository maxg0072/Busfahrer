import SwiftUI

struct PferderennenSipDistributionView: View {
    @Environment(GameViewModel.self) private var game
    @State private var sipAppear = false

    private var distributorIndex: Int {
        if case .pferderennenSipDistribution(let pIdx, _) = game.phase {
            return pIdx
        }
        return 0
    }

    private var sipsRemaining: Int {
        if case .pferderennenSipDistribution(_, let sips) = game.phase {
            return sips
        }
        return 0
    }

    private var distributor: Player? {
        distributorIndex < game.players.count ? game.players[distributorIndex] : nil
    }

    var body: some View {
        VStack(spacing: Theme.sectionSpacing) {
            Spacer()

            if let player = distributor {
                VStack(spacing: 12) {
                    Text("🍻")
                        .font(.system(size: 60))
                        .scaleEffect(sipAppear ? 1.0 : 0.3)

                    Text(Strings.pferderennen.winnerDistributes(player.name, sipsRemaining))
                        .font(Theme.headlineFont)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("\(sipsRemaining) \(Strings.sips.word(sipsRemaining))")
                        .font(Theme.titleFont)
                        .foregroundStyle(Theme.gold)
                }
                .opacity(sipAppear ? 1.0 : 0.0)
            }

            // Target player buttons
            VStack(spacing: Theme.itemSpacing) {
                ForEach(Array(game.players.enumerated()), id: \.element.id) { idx, player in
                    if idx != distributorIndex {
                        Button {
                            HapticManager.heavy()
                            let amount = min(sipsRemaining, sipsRemaining) // Give all remaining to one
                            game.pferderennenDistributeSip(from: distributorIndex, to: idx, amount: amount)
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(player.color)
                                    .frame(width: 14, height: 14)
                                Text(player.name)
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(.white)
                                Spacer()
                                Text("\(sipsRemaining) \(Strings.sips.word(sipsRemaining))")
                                    .font(Theme.captionFont)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Theme.cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        }
                        .buttonStyle(PressableButtonStyle())
                        .staggeredAppear(index: idx, appear: sipAppear, delay: 0.06)
                    }
                }
            }
            .padding(.horizontal, Theme.padding)

            Spacer()

            // Option to distribute 1 at a time
            if sipsRemaining > 1 {
                Text(LanguageManager.shared.current == .de ? "Tippe auf einen Spieler, um alle zu geben" : "Tap a player to give all sips")
                    .font(Theme.captionFont)
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.bottom, Theme.buttonBottomPadding)
            }
        }
        .animation(Theme.springBouncy, value: sipAppear)
        .onAppear {
            sipAppear = false
            withAnimation(Theme.springBouncy) { sipAppear = true }
        }
    }
}
