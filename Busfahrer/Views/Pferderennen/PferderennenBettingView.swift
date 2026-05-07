import SwiftUI

struct PferderennenBettingView: View {
    @Environment(GameViewModel.self) private var game
    @State private var selectedSuit: Int? = nil
    @State private var sipAmount: Int = 2
    @State private var appear = false

    private var playerIndex: Int {
        switch game.phase {
        case .pferderennenBetting(let idx): return idx
        case .pferderennenPreDrink(let idx): return idx
        default: return 0
        }
    }

    private var currentPlayer: Player? {
        playerIndex < game.players.count ? game.players[playerIndex] : nil
    }

    private let horseSuitNames: [(emoji: String, suit: Suit, color: Color)] = [
        ("♥", .herz, Color(red: 1.0, green: 0.22, blue: 0.28)),
        ("♦", .karo, Color(red: 0.2, green: 0.6, blue: 1.0)),
        ("♠", .pik, Color(red: 0.5, green: 0.5, blue: 0.55)),
        ("♣", .kreuz, Color(red: 0.2, green: 0.75, blue: 0.35)),
    ]

    var body: some View {
        ZStack {
            if case .pferderennenPreDrink = game.phase {
                preDrinkView
            } else {
                bettingView
            }
        }
        .onAppear {
            selectedSuit = nil
            sipAmount = 2
            withAnimation(Theme.springBouncy) { appear = true }
        }
        .onChange(of: game.phase) { _, _ in
            selectedSuit = nil
            sipAmount = 2
        }
    }

    private var bettingView: some View {
        VStack(spacing: Theme.sectionSpacing) {
            Spacer()

            // Player name + prompt
            if let player = currentPlayer {
                VStack(spacing: 8) {
                    Text("🏇")
                        .font(.system(size: 60))
                    Text(Strings.pferderennen.chooseHorse(player.name))
                        .font(Theme.headlineFont)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
                .scaleEffect(appear ? 1.0 : 0.5)
                .opacity(appear ? 1.0 : 0.0)
            }

            // Horse selection (4 suit buttons)
            HStack(spacing: 14) {
                ForEach(0..<4, id: \.self) { idx in
                    Button {
                        HapticManager.selection()
                        withAnimation(Theme.springSnappy) {
                            selectedSuit = idx
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(horseSuitNames[idx].emoji)
                                .font(.system(size: 36))
                            Text(horseSuitNames[idx].suit.displayName)
                                .font(Theme.captionFont)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .fill(selectedSuit == idx
                                    ? horseSuitNames[idx].color.opacity(0.35)
                                    : Theme.cardBg
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .strokeBorder(
                                    selectedSuit == idx
                                        ? horseSuitNames[idx].color
                                        : .white.opacity(0.1),
                                    lineWidth: selectedSuit == idx ? 2.5 : 1
                                )
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .staggeredAppear(index: idx, appear: appear, delay: 0.08)
                }
            }
            .padding(.horizontal, Theme.padding)

            // Sip amount selector
            VStack(spacing: 12) {
                Text(Strings.pferderennen.howManySips)
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white.opacity(0.7))

                HStack(spacing: 16) {
                    Button {
                        HapticManager.selection()
                        if sipAmount > 1 { sipAmount -= 1 }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Theme.cardBg)
                            .clipShape(Circle())
                    }

                    Text("\(sipAmount)")
                        .font(Theme.timerFont)
                        .foregroundStyle(.white)
                        .frame(width: 100)

                    Button {
                        HapticManager.selection()
                        if sipAmount < 10 { sipAmount += 1 }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Theme.cardBg)
                            .clipShape(Circle())
                    }
                }

                Text(Strings.sips.count(sipAmount))
                    .font(Theme.calloutFont)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            // Confirm bet button
            Button {
                HapticManager.heavy()
                guard let suit = selectedSuit else { return }
                game.pferderennenPlaceBet(playerIndex: playerIndex, suitIndex: suit, sips: sipAmount)
            } label: {
                Text(Strings.pferderennen.placeBet)
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.buttonHeight)
                    .background(selectedSuit != nil ? Theme.cardBg : Theme.cardBg.opacity(0.4))
                    .clipShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(selectedSuit == nil)
            .padding(.horizontal, Theme.padding)
            .padding(.bottom, Theme.buttonBottomPadding)
            .opacity(appear ? 1.0 : 0.0)
        }
    }

    @State private var drinkAppear = false

    private var preDrinkView: some View {
        VStack(spacing: Theme.sectionSpacing) {
            Spacer()

            if let player = currentPlayer,
               let bet = game.playerBets[playerIndex] {
                VStack(spacing: 16) {
                    Text("🍺")
                        .font(.system(size: 80))
                        .scaleEffect(drinkAppear ? 1.0 : 0.3)

                    Text(Strings.pferderennen.drinkBet(player.name, bet.sips))
                        .font(Theme.headlineFont)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .opacity(drinkAppear ? 1.0 : 0.0)

                    Text(Strings.pferderennen.betPlaced(player.name, bet.sips, horseSuitNames[bet.suitIndex].suit.displayName))
                        .font(Theme.calloutFont)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .opacity(drinkAppear ? 1.0 : 0.0)
                }
            }

            Spacer()

            Button {
                HapticManager.selection()
                game.pferderennenAfterDrink()
            } label: {
                Text(Strings.common.continueButton)
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.buttonHeight)
                    .background(Theme.cardBg)
                    .clipShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal, Theme.padding)
            .padding(.bottom, Theme.buttonBottomPadding)
            .opacity(drinkAppear ? 1.0 : 0.0)
        }
        .onAppear {
            drinkAppear = false
            withAnimation(Theme.springBouncy) { drinkAppear = true }
        }
    }
}
