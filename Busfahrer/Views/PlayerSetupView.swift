import SwiftUI

struct PlayerSetupView: View {
    @Environment(GameViewModel.self) private var game
    @State private var playerName = ""
    @FocusState private var nameFieldFocused: Bool

    private var canStart: Bool {
        let pendingName = !playerName.trimmingCharacters(in: .whitespaces).isEmpty
        let effectiveCount = game.players.count + (pendingName ? 1 : 0)
        return effectiveCount >= 2
    }

    var nextColor: Color {
        let usedCount = game.players.count
        return Theme.playerColors[usedCount % Theme.playerColors.count]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar with back button
            HStack {
                CircleIconButton(systemName: "chevron.left") {
                    withAnimation(Theme.springSnappy) {
                        game.phase = .start
                    }
                }
                Spacer()
            }
            .padding(.horizontal, Theme.padding)
            .padding(.top, 8)

            // Header
            VStack(spacing: 8) {
                Text(Strings.playerSetup.title)
                    .font(Theme.titleFont)
                    .foregroundStyle(.white)

                Text(Strings.playerSetup.playerCount(game.players.count))
                    .font(Theme.calloutFont)
                    .foregroundStyle(.white.opacity(Theme.textSecondary))
            }
            .padding(.top, 20)
            .padding(.bottom, Theme.sectionSpacing)

            // Input field (dark card style)
            HStack(spacing: 12) {
                Circle()
                    .fill(nextColor)
                    .frame(width: 28, height: 28)

                TextField(Strings.playerSetup.namePlaceholder, text: $playerName)
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white)
                    .focused($nameFieldFocused)
                    .submitLabel(.done)
                    .onSubmit { addPlayer() }

                Button {
                    HapticManager.selection()
                    addPlayer()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(playerName.trimmingCharacters(in: .whitespaces).isEmpty ? .white.opacity(0.3) : Theme.accentGreen)
                }
                .disabled(playerName.trimmingCharacters(in: .whitespaces).isEmpty || game.players.count >= 8)
            }
            .padding(16)
            .background(Theme.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .padding(.horizontal, Theme.padding)

            // Player list (grouped dark card)
            ScrollView {
                if !game.players.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(Array(game.players.enumerated()), id: \.element.id) { index, player in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(player.color)
                                    .frame(width: 24, height: 24)

                                Text(player.name)
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(.white)

                                Spacer()

                                Button {
                                    HapticManager.selection()
                                    withAnimation(.spring(response: 0.3)) {
                                        game.removePlayer(at: index)
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white.opacity(Theme.textTertiary))
                                        .frame(width: 28, height: 28)
                                        .background(Theme.cardBgElevated)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))

                            if index < game.players.count - 1 {
                                Theme.separator
                                    .frame(height: 1)
                                    .padding(.leading, 52)
                            }
                        }
                    }
                    .background(Theme.cardBg)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .padding(.horizontal, Theme.padding)
                    .padding(.top, Theme.itemSpacing)
                }
            }

            Spacer()

            // Start button (dark pill, fixed bottom)
            VStack(spacing: 8) {
                if game.players.count < 2 {
                    Text(Strings.playerSetup.minPlayers)
                        .font(Theme.captionFont)
                        .foregroundStyle(.white.opacity(Theme.textTertiary))
                }

                Button {
                    let trimmed = playerName.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty, game.players.count < 8 {
                        game.addPlayer(name: trimmed, color: nextColor)
                        playerName = ""
                    }
                    HapticManager.selection()
                    switch game.currentGame {
                    case .busfahrer: game.startGame()
                    case .pferderennen: game.startPferderennen()
                    case .kingsCup: game.startKingsCup()
                    case .fckTheDealer: game.startFckTheDealer()
                    }
                } label: {
                    Text(Strings.playerSetup.startGame)
                        .font(Theme.bodyFont)
                        .foregroundStyle(canStart ? .white : .white.opacity(Theme.textTertiary))
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.buttonHeight)
                        .background(canStart ? Theme.cardBg : Theme.cardBgElevated.opacity(0.5))
                        .clipShape(Capsule())
                }
                .disabled(!canStart)
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.horizontal, Theme.padding)
            .padding(.bottom, Theme.buttonBottomPadding)
        }
    }

    private func addPlayer() {
        let trimmed = playerName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, game.players.count < 8 else { return }
        withAnimation(.spring(response: 0.3)) {
            game.addPlayer(name: trimmed, color: nextColor)
        }
        playerName = ""
        nameFieldFocused = true
    }
}
