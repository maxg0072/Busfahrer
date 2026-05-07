import SwiftUI

struct PferderennenRaceView: View {
    @Environment(GameViewModel.self) private var game
    @State private var showCard = false
    @State private var cardFlipped = false
    @State private var raceAppear = false
    @State private var showWinExplosion = false

    private let horseEmojis = ["🟥", "🟦", "⬛", "🟩"]
    private let horseIcons = ["♥", "♦", "♠", "♣"]
    private let horseColors: [Color] = [
        Color(red: 1.0, green: 0.22, blue: 0.28),  // Red (Hearts)
        Color(red: 0.2, green: 0.6, blue: 1.0),     // Blue (Diamonds)
        Color(red: 0.5, green: 0.5, blue: 0.55),    // Gray (Spades)
        Color(red: 0.2, green: 0.75, blue: 0.35),   // Green (Clubs)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Race track (scrollable)
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    Text(Strings.pferderennen.raceTrack)
                        .font(Theme.headlineFont)
                        .foregroundStyle(.white)
                        .padding(.top, 60)
                        .opacity(raceAppear ? 1 : 0)
                        .offset(y: raceAppear ? 0 : -10)

                    // Cards drawn counter
                    Text("\(game.raceCardsDrawn) \(game.raceCardsDrawn == 1 ? "Karte" : "Karten") gezogen")
                        .font(Theme.captionFont)
                        .foregroundStyle(.white.opacity(0.5))
                        .contentTransition(.numericText())
                        .animation(Theme.springSnappy, value: game.raceCardsDrawn)
                        .opacity(raceAppear ? 1 : 0)

                    // Race track visualization
                    raceTrackView
                        .padding(.horizontal, Theme.padding)

                    // Current card reveal
                    if case .pferderennenCardReveal = game.phase {
                        cardRevealSection
                            .padding(.horizontal, Theme.padding)
                    }

                    // Player bets summary
                    betsSummary
                        .padding(.horizontal, Theme.padding)
                }
                .padding(.bottom, 120)
            }
            .animation(Theme.springSmooth, value: raceAppear)
            .onAppear {
                raceAppear = false
                withAnimation(Theme.springSmooth) { raceAppear = true }
            }

            // Win explosion overlay
            if showWinExplosion {
                EmojiExplosionView(emojis: ["🏇", "🏆", "🍺", "🎉", "💰"], count: 18, particleSize: 32)
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }

            // Bottom action button
            VStack {
                if case .pferderennenRace = game.phase {
                    Button {
                        HapticManager.heavy()
                        showCard = false
                        game.pferderennenDrawCard()
                        withAnimation(Theme.springBouncy) {
                            showCard = true
                        }
                    } label: {
                        Label(Strings.pferderennen.drawCard, systemImage: "rectangle.portrait.rotate")
                            .font(Theme.bodyFont)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: Theme.buttonHeight)
                            .background(Theme.cardBg)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(PressableButtonStyle())
                    .padding(.horizontal, Theme.padding)
                } else if case .pferderennenCardReveal = game.phase {
                    Button {
                        HapticManager.selection()
                        showCard = false
                        game.pferderennenAfterCardReveal()
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
                }
            }
            .padding(.bottom, Theme.buttonBottomPadding)
        }
    }

    // MARK: - Race Track

    private var raceTrackView: some View {
        VStack(spacing: 0) {
            // Finish line
            HStack {
                Text("🏁")
                    .font(.system(size: 20))
                Text(LanguageManager.shared.current == .de ? "Ziel" : "Finish")
                    .font(Theme.captionFont)
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
            }
            .padding(.bottom, 4)

            // Track grid: 4 lanes x positions
            VStack(spacing: 2) {
                ForEach(0..<4, id: \.self) { horseIdx in
                    horseTrackRow(horseIdx: horseIdx)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .fill(Theme.cardBg)
            )

            // Track cards row
            trackCardsRow
                .padding(.top, 8)
        }
    }

    private func horseTrackRow(horseIdx: Int) -> some View {
        HStack(spacing: 3) {
            // Horse icon label
            Text(horseIcons[horseIdx])
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(horseColors[horseIdx])
                .frame(width: 28)

            // Track cells (0 = start, 1-7 = track, 8 = finish)
            ForEach(0..<9, id: \.self) { pos in
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            pos == 0 ? Color.white.opacity(0.05) :
                            pos == 8 ? Theme.gold.opacity(0.1) :
                            Color.white.opacity(0.03)
                        )
                        .frame(height: 32)

                    if game.horsePositions[horseIdx] == pos {
                        // Horse is here!
                        Text("🐴")
                            .font(.system(size: 16))
                            .transition(.scale.combined(with: .opacity))
                    }

                    // Track card marker
                    if pos >= 1 && pos <= 7 {
                        let trackIdx = pos - 1
                        if game.trackRevealed[trackIdx] {
                            // Revealed track card indicator
                            Circle()
                                .fill(horseColors[game.suitIndex(for: game.trackCards[trackIdx].suit)].opacity(0.3))
                                .frame(width: 6, height: 6)
                                .offset(y: 12)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .animation(Theme.springBouncy, value: game.horsePositions[horseIdx])
    }

    private var trackCardsRow: some View {
        HStack(spacing: 3) {
            // Spacer for horse label column
            Color.clear.frame(width: 28)

            // Start label
            Text("S")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.3))
                .frame(maxWidth: .infinity)

            // 7 track cards
            ForEach(0..<7, id: \.self) { idx in
                ZStack {
                    if game.trackRevealed[idx] {
                        // Show the revealed card suit
                        Text(game.trackCards[idx].suit.symbol)
                            .font(.system(size: 12))
                            .foregroundStyle(horseColors[game.suitIndex(for: game.trackCards[idx].suit)])
                    } else {
                        Text("\(idx + 1)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
                .frame(maxWidth: .infinity)
            }

            // Finish label
            Text("🏁")
                .font(.system(size: 10))
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Card Reveal

    private var cardRevealSection: some View {
        VStack(spacing: 12) {
            if let card = game.raceCurrentCard {
                // Show the drawn card
                HStack(spacing: 12) {
                    CardView(card: card, faceUp: true)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.fullDisplayName)
                            .font(Theme.bodyFont)
                            .foregroundStyle(.white)

                        if game.winningSuitIndex != nil {
                            Text(Strings.pferderennen.winner(card.suit.displayName))
                                .font(Theme.headlineFont)
                                .foregroundStyle(Theme.gold)
                                .shadow(color: Theme.gold.opacity(0.6), radius: 8)
                        } else {
                            Text(Strings.pferderennen.horseAdvances(card.suit.displayName))
                                .font(Theme.calloutFont)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(Theme.cardBgElevated)
                )
                .scaleEffect(showCard ? 1.0 : 0.5)
                .opacity(showCard ? 1.0 : 0.0)
                .onAppear {
                    // Trigger winner celebration
                    if game.winningSuitIndex != nil {
                        HapticManager.celebration()
                        withAnimation { showWinExplosion = true }
                    }
                }
            }
        }
    }

    // MARK: - Bets Summary

    private var betsSummary: some View {
        VStack(spacing: 8) {
            Text(LanguageManager.shared.current == .de ? "Wetten" : "Bets")
                .font(Theme.captionFont)
                .foregroundStyle(.white.opacity(0.5))

            VStack(spacing: 0) {
                ForEach(Array(game.playerBets.sorted(by: { $0.key < $1.key })), id: \.key) { pIdx, bet in
                    if pIdx < game.players.count {
                        HStack {
                            Circle()
                                .fill(game.players[pIdx].color)
                                .frame(width: 10, height: 10)
                            Text(game.players[pIdx].name)
                                .font(Theme.calloutFont)
                                .foregroundStyle(.white)
                            Spacer()
                            Text(horseIcons[bet.suitIndex])
                                .foregroundStyle(horseColors[bet.suitIndex])
                            Text("\(bet.sips) \(Strings.sips.word(bet.sips))")
                                .font(Theme.captionFont)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)

                        if pIdx != game.playerBets.keys.sorted().last {
                            Theme.separator.frame(height: 1).padding(.leading, 38)
                        }
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .fill(Theme.cardBg)
            )
        }
    }
}
