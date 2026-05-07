import SwiftUI

struct KingsCupGameView: View {
    @Environment(GameViewModel.self) private var game
    @State private var appear = false
    @State private var cardPulse = false

    private var playerIndex: Int {
        switch game.phase {
        case .kingsCupTurn(let idx): return idx
        case .kingsCupCardReveal(let idx): return idx
        case .kingsCupAction(let idx): return idx
        case .kingsCupDistribute(let idx, _): return idx
        case .kingsCupPickBuddy(let idx): return idx
        default: return 0
        }
    }

    private func safePlayer(_ index: Int) -> (name: String, color: Color) {
        guard index < game.players.count else { return ("", .clear) }
        return (game.players[index].name, game.players[index].color)
    }

    var body: some View {
        ZStack {
            switch game.phase {
            case .kingsCupTurn:
                turnView
            case .kingsCupCardReveal:
                cardRevealView
            case .kingsCupAction:
                actionView
            case .kingsCupDistribute:
                distributeView
            case .kingsCupPickBuddy:
                buddyPickerView
            default:
                EmptyView()
            }
        }
    }

    // MARK: - Turn View (Draw Card)

    private var turnView: some View {
        let p = safePlayer(playerIndex)
        return VStack(spacing: Theme.sectionSpacing) {
            Spacer()

            // Status bar
            VStack(spacing: 8) {
                Text(Strings.kingsCup.kingsDrawn(game.kingsCupKingsDrawn))
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.gold.opacity(0.8))
                    .contentTransition(.numericText())
                    .animation(Theme.springSnappy, value: game.kingsCupKingsDrawn)
                Text("\(deck.remainingCount) \(Strings.kingsCup.cardsRemaining)")
                    .font(Theme.captionFont)
                    .foregroundStyle(.white.opacity(0.4))
                    .contentTransition(.numericText())
                    .animation(Theme.springSnappy, value: deck.remainingCount)
            }
            .padding(.top, 50)
            .opacity(appear ? 1 : 0)

            Spacer()

            // Player prompt
            VStack(spacing: 12) {
                Text(Strings.kingsCup.playerTurn(p.name))
                    .font(Theme.headlineFont)
                    .foregroundStyle(.white)
                    .opacity(appear ? 1 : 0)
                    .scaleEffect(appear ? 1.0 : 0.8)

                // Card back (tap to draw) with idle pulse
                CardView(card: nil, faceUp: false)
                    .glowingBorder(color: Theme.gold.opacity(cardPulse ? 0.4 : 0.15), lineWidth: 1.5, glowRadius: cardPulse ? 10 : 4, cornerRadius: 10)
                    .scaleEffect(cardPulse ? 1.53 : 1.5)
                    .padding(.vertical, 20)
                    .scaleEffect(appear ? 1.0 : 0.3)
            }

            // Active effects
            activeEffectsBar
                .opacity(appear ? 1 : 0)

            Spacer()

            Button {
                HapticManager.heavy()
                game.kingsCupDrawCard(playerIndex: playerIndex)
            } label: {
                Text(Strings.kingsCup.drawCard)
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
            .opacity(appear ? 1 : 0)
        }
        .animation(Theme.springBouncy, value: appear)
        .onAppear {
            appear = false
            cardPulse = false
            withAnimation(Theme.springBouncy) {
                appear = true
            }
            // Start idle card breathing
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                cardPulse = true
            }
        }
    }

    private var deck: Deck { game.deck }

    // MARK: - Card Reveal

    private var cardRevealView: some View {
        ZStack {
            VStack(spacing: Theme.sectionSpacing) {
                Spacer()

                if let card = game.kingsCupCurrentCard {
                    // Show the card
                    LargeCardView(card: card)

                    // Action title with dramatic entrance
                    Text(Strings.kingsCup.actionTitle(for: card.value))
                        .font(Theme.titleFont)
                        .foregroundStyle(.white)
                        .scaleEffect(cardRevealAppear ? 1.0 : 0.6)
                        .opacity(cardRevealAppear ? 1.0 : 0.0)

                    Text(Strings.kingsCup.actionEmoji(for: card.value))
                        .font(.system(size: 50))
                        .scaleEffect(cardRevealAppear ? 1.0 : 0.3)

                    // King warning
                    if card.value == .koenig {
                        Text("👑 \(game.kingsCupKingsDrawn)/4")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.gold)
                            .shadow(color: Theme.gold.opacity(0.6), radius: 8)
                    }
                }

                Spacer()

                Button {
                    HapticManager.selection()
                    game.kingsCupProceedToAction(playerIndex: playerIndex)
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
                .opacity(cardRevealAppear ? 1.0 : 0.0)
            }

            // Emoji explosion for Kings
            if cardRevealAppear, let card = game.kingsCupCurrentCard, card.value == .koenig {
                EmojiExplosionView(emojis: ["👑", "🍺", "🔥", "💀"], count: 14, particleSize: 30)
            }
        }
        .onAppear {
            cardRevealAppear = false
            withAnimation(Theme.springBouncy) { cardRevealAppear = true }
        }
    }

    // MARK: - Action View (display action + continue)

    @State private var cardRevealAppear = false
    @State private var actionAppear = false

    private var actionView: some View {
        let p = safePlayer(playerIndex)
        return VStack(spacing: Theme.sectionSpacing) {
            Spacer()

            if let card = game.kingsCupCurrentCard {
                VStack(spacing: 16) {
                    Text(Strings.kingsCup.actionEmoji(for: card.value))
                        .font(.system(size: 70))
                        .scaleEffect(actionAppear ? 1.0 : 0.3)

                    Text(Strings.kingsCup.actionTitle(for: card.value))
                        .font(Theme.titleFont)
                        .foregroundStyle(.white)

                    Text(Strings.kingsCup.actionDescription(for: card.value))
                        .font(Theme.bodyFont)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.padding)

                    // Show card small
                    CardView(card: card, faceUp: true, compact: true)

                    // Special info for certain cards
                    if card.value == .koenig {
                        Text(Strings.kingsCup.kingsDrawn(game.kingsCupKingsDrawn))
                            .font(Theme.headlineFont)
                            .foregroundStyle(Theme.gold)
                    }

                    if card.value == .sieben, let tkIdx = game.kingsCupThumbKingIndex {
                        let tk = safePlayer(tkIdx)
                        Text("👍 \(Strings.kingsCup.thumbKing): \(tk.name)")
                            .font(Theme.calloutFont)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    if card.value == .dame, let qqIdx = game.kingsCupQuestionQueenIndex {
                        let qq = safePlayer(qqIdx)
                        Text("❓ \(Strings.kingsCup.questionQueen): \(qq.name)")
                            .font(Theme.calloutFont)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    if card.value == .drei {
                        Text("\(p.name) \(Strings.sips.drinksCount(3))")
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.accentRed)
                    }
                }
            }

            Spacer()

            Button {
                HapticManager.selection()
                game.kingsCupAfterAction(playerIndex: playerIndex)
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
        }
        .animation(Theme.springBouncy, value: actionAppear)
        .onAppear {
            actionAppear = false
            withAnimation(Theme.springBouncy) {
                actionAppear = true
            }
        }
    }

    // MARK: - Distribute View

    private var distributeView: some View {
        let sipsRemaining: Int = {
            if case .kingsCupDistribute(_, let sips) = game.phase { return sips }
            return 0
        }()
        let p = safePlayer(playerIndex)

        return VStack(spacing: Theme.sectionSpacing) {
            Spacer()

            VStack(spacing: 12) {
                Text("✌️")
                    .font(.system(size: 60))
                Text(Strings.sips.canDistribute(p.name, sipsRemaining))
                    .font(Theme.headlineFont)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text("\(sipsRemaining) \(Strings.sips.word(sipsRemaining))")
                    .font(Theme.titleFont)
                    .foregroundStyle(Theme.gold)
                    .contentTransition(.numericText())
                    .animation(Theme.springSnappy, value: sipsRemaining)
            }

            // Player buttons
            VStack(spacing: Theme.itemSpacing) {
                ForEach(Array(game.players.enumerated()), id: \.element.id) { idx, player in
                    if idx != playerIndex {
                        Button {
                            HapticManager.heavy()
                            game.kingsCupDistributeSip(from: playerIndex, to: idx, amount: 1)
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(player.color)
                                    .frame(width: 14, height: 14)
                                Text(player.name)
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(.white)
                                Spacer()
                                Text("1 \(Strings.sips.word(1))")
                                    .font(Theme.captionFont)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Theme.cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
            }
            .padding(.horizontal, Theme.padding)

            Spacer()
        }
    }

    // MARK: - Buddy Picker

    private var buddyPickerView: some View {
        let p = safePlayer(playerIndex)
        return VStack(spacing: Theme.sectionSpacing) {
            Spacer()

            VStack(spacing: 12) {
                Text("🤝")
                    .font(.system(size: 60))
                Text(Strings.kingsCup.chooseBuddy(p.name))
                    .font(Theme.headlineFont)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: Theme.itemSpacing) {
                ForEach(Array(game.players.enumerated()), id: \.element.id) { idx, player in
                    if idx != playerIndex {
                        Button {
                            HapticManager.heavy()
                            game.kingsCupSelectBuddy(playerIndex: playerIndex, buddyIndex: idx)
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(player.color)
                                    .frame(width: 14, height: 14)
                                Text(player.name)
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(.white)
                                Spacer()
                                Text("🤝")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Theme.cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
            }
            .padding(.horizontal, Theme.padding)

            Spacer()
        }
    }

    // MARK: - Active Effects Bar

    private var activeEffectsBar: some View {
        VStack(spacing: 6) {
            if let tkIdx = game.kingsCupThumbKingIndex {
                let tk = safePlayer(tkIdx)
                HStack(spacing: 6) {
                    Text("👍")
                    Text("\(Strings.kingsCup.thumbKing): \(tk.name)")
                        .font(Theme.captionFont)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            if let qqIdx = game.kingsCupQuestionQueenIndex {
                let qq = safePlayer(qqIdx)
                HStack(spacing: 6) {
                    Text("❓")
                    Text("\(Strings.kingsCup.questionQueen): \(qq.name)")
                        .font(Theme.captionFont)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            if !game.kingsCupBuddyPairs.isEmpty {
                ForEach(0..<game.kingsCupBuddyPairs.count, id: \.self) { i in
                    let pair = game.kingsCupBuddyPairs[i]
                    let p1 = safePlayer(pair.0)
                    let p2 = safePlayer(pair.1)
                    HStack(spacing: 6) {
                        Text("🤝")
                        Text("\(p1.name) & \(p2.name)")
                            .font(Theme.captionFont)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
        .padding(.horizontal, Theme.padding)
    }
}
