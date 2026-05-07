import SwiftUI

struct PferderennenResultView: View {
    @Environment(GameViewModel.self) private var game
    @State private var appear = false

    private let horseIcons = ["♥", "♦", "♠", "♣"]
    private let horseColors: [Color] = [
        Color(red: 1.0, green: 0.22, blue: 0.28),
        Color(red: 0.2, green: 0.6, blue: 1.0),
        Color(red: 0.5, green: 0.5, blue: 0.55),
        Color(red: 0.2, green: 0.75, blue: 0.35),
    ]

    private func safePlayer(_ index: Int) -> (name: String, color: Color) {
        guard index < game.players.count else { return ("", .clear) }
        return (game.players[index].name, game.players[index].color)
    }

    var body: some View {
        VStack(spacing: Theme.sectionSpacing) {
            Spacer()

            // Winner announcement
            if let winIdx = game.winningSuitIndex {
                VStack(spacing: 16) {
                    Text("🏆")
                        .font(.system(size: 80))
                        .scaleEffect(appear ? 1.0 : 0.3)

                    Text(Strings.pferderennen.winner(game.horseSuit(at: winIdx).displayName))
                        .font(Theme.titleFont)
                        .foregroundStyle(Theme.gold)
                        .multilineTextAlignment(.center)

                    // Horse icon
                    Text(horseIcons[winIdx])
                        .font(.system(size: 60))
                        .foregroundStyle(horseColors[winIdx])
                }
                .opacity(appear ? 1.0 : 0.0)
            }

            // Winners & Losers lists
            VStack(spacing: 12) {
                // Winners
                let winners = game.pferderennenWinners
                if !winners.isEmpty {
                    VStack(spacing: 0) {
                        HStack {
                            Text("🎉")
                            Text(LanguageManager.shared.current == .de ? "Gewinner" : "Winners")
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.accentGreen)
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)

                        ForEach(winners, id: \.playerIndex) { w in
                            let p = safePlayer(w.playerIndex)
                            HStack {
                                Circle()
                                    .fill(p.color)
                                    .frame(width: 10, height: 10)
                                Text(p.name)
                                    .font(Theme.calloutFont)
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(Strings.pferderennen.winnerDistributes(p.name, w.sips))
                                    .font(Theme.captionFont)
                                    .foregroundStyle(Theme.accentGreen.opacity(0.8))
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .fill(Theme.cardBg)
                    )
                }

                // Losers
                let losers = game.pferderennenLosers
                if !losers.isEmpty {
                    VStack(spacing: 0) {
                        HStack {
                            Text("😵")
                            Text(LanguageManager.shared.current == .de ? "Verlierer" : "Losers")
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.accentRed)
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)

                        ForEach(losers, id: \.playerIndex) { l in
                            let p = safePlayer(l.playerIndex)
                            HStack {
                                Circle()
                                    .fill(p.color)
                                    .frame(width: 10, height: 10)
                                Text(p.name)
                                    .font(Theme.calloutFont)
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(Strings.pferderennen.loserDrinks(p.name, l.sips))
                                    .font(Theme.captionFont)
                                    .foregroundStyle(Theme.accentRed.opacity(0.8))
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .fill(Theme.cardBg)
                    )
                }
            }
            .padding(.horizontal, Theme.padding)
            .opacity(appear ? 1.0 : 0.0)

            Spacer()

            // Action buttons
            VStack(spacing: Theme.itemSpacing) {
                // Distribute sips (if winners exist)
                if !game.pferderennenWinners.isEmpty {
                    Button {
                        HapticManager.heavy()
                        game.pferderennenStartSipDistribution()
                    } label: {
                        Text(LanguageManager.shared.current == .de ? "Schlücke verteilen" : "Distribute Sips")
                            .font(Theme.bodyFont)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: Theme.buttonHeight)
                            .background(Theme.cardBg)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PressableButtonStyle())
                }

                // New race
                Button {
                    HapticManager.selection()
                    game.pferderennenNewRace()
                } label: {
                    Text(Strings.pferderennen.nextRace)
                        .font(Theme.bodyFont)
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.buttonHeight)
                        .background(Theme.cardBgElevated)
                        .clipShape(Capsule())
                }
                .buttonStyle(PressableButtonStyle())

                // Quit
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
        .onAppear {
            withAnimation(Theme.springDramatic) {
                appear = true
            }
            HapticManager.celebration()
        }
    }
}
