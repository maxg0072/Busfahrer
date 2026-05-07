import SwiftUI

struct SipDistributionView: View {
    @Environment(GameViewModel.self) private var game
    let distributorIndex: Int
    let sipsRemaining: Int

    @State private var selectedTarget: Int? = nil
    @State private var appear = false

    var distributor: Player {
        distributorIndex < game.players.count ? game.players[distributorIndex] : Player(name: "", color: .clear)
    }

    private var soloTargetIndex: Int? {
        let others = game.players.indices.filter { $0 != distributorIndex }
        return others.count == 1 ? others.first : nil
    }

    var body: some View {
        VStack(spacing: 24) {
            if let soloIdx = soloTargetIndex {
                autoDistributeView(targetIndex: soloIdx)
            } else if selectedTarget == nil {
                normalSelectionView
            } else if let targetIdx = selectedTarget {
                amountSelectionView(targetIndex: targetIdx)
            }
        }
        .onAppear {
            appear = false
            withAnimation(Theme.springBouncy) {
                appear = true
            }
        }
    }

    // MARK: - 2 Players: Auto-distribute

    private func autoDistributeView(targetIndex: Int) -> some View {
        let target = game.players[targetIndex]

        return VStack(spacing: 20) {
            Text("🍺")
                .font(.system(size: 50))
                .scaleEffect(appear ? 1.0 : 0.3)

            Text(target.name)
                .font(Theme.titleFont)
                .foregroundStyle(target.color)
                .opacity(appear ? 1 : 0)

            Text(Strings.sips.drinksCount(sipsRemaining))
                .font(Theme.headlineFont)
                .foregroundStyle(.white)
                .opacity(appear ? 1 : 0)

            Text(Strings.sips.from(distributor.name))
                .font(Theme.bodyFont)
                .foregroundStyle(.white.opacity(0.75))
                .opacity(appear ? 1 : 0)

            Button {
                HapticManager.heavy()
                game.distributeSip(from: distributorIndex, to: targetIndex, amount: sipsRemaining)
            } label: {
                Text(Strings.common.continueButton)
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.buttonHeight)
                    .background(Color.black.opacity(0.40))
                    .clipShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal, Theme.padding)
            .opacity(appear ? 1 : 0)
        }
        .animation(Theme.springBouncy, value: appear)
    }

    // MARK: - 3+ Players: Normal selection

    private var normalSelectionView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("🍺")
                    .font(.system(size: 50))
                    .scaleEffect(appear ? 1.0 : 0.3)

                Text("\(distributor.name)")
                    .font(Theme.headlineFont)
                    .foregroundStyle(distributor.color)
                    .opacity(appear ? 1 : 0)

                Text(Strings.sips.distributes(distributor.name, sipsRemaining))
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white.opacity(0.85))
                    .opacity(appear ? 1 : 0)

                Text("\(sipsRemaining)")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(Theme.gold)
                    .contentTransition(.numericText())
                    .animation(Theme.springSnappy, value: sipsRemaining)
                    .opacity(appear ? 1 : 0)
            }
            .animation(Theme.springBouncy, value: appear)

            Text(Strings.sips.toWhom)
                .font(Theme.bodyFont)
                .foregroundStyle(.white.opacity(0.8))
                .opacity(appear ? 1 : 0)
                .animation(Theme.springBouncy.delay(0.1), value: appear)

            VStack(spacing: 8) {
                ForEach(Array(game.players.enumerated()), id: \.element.id) { index, player in
                    if index != distributorIndex {
                        Button {
                            HapticManager.heavy()
                            if sipsRemaining == 1 {
                                game.distributeSip(from: distributorIndex, to: index, amount: 1)
                            } else {
                                withAnimation(Theme.springSnappy) {
                                    selectedTarget = index
                                }
                            }
                        } label: {
                            PlayerBadgeView(player: player, showSips: false)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PressableButtonStyle())
                        .staggeredAppear(index: index, appear: appear, delay: 0.06)
                    }
                }
            }
            .padding(.horizontal, Theme.padding)
        }
    }

    // MARK: - Amount selection

    private func amountSelectionView(targetIndex: Int) -> some View {
        let target = game.players[targetIndex]

        return VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("\(distributor.name)")
                    .font(Theme.headlineFont)
                    .foregroundStyle(distributor.color)

                Text(Strings.sips.distributes(distributor.name, sipsRemaining))
                    .font(Theme.bodyFont)
                    .foregroundStyle(.white.opacity(0.85))
            }

            Text(Strings.sips.howManyFor(target.name))
                .font(Theme.bodyFont)
                .foregroundStyle(.white.opacity(0.8))

            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: min(sipsRemaining, 4))
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(1...sipsRemaining, id: \.self) { amount in
                    Button {
                        HapticManager.heavy()
                        game.distributeSip(from: distributorIndex, to: targetIndex, amount: amount)
                        selectedTarget = nil
                    } label: {
                        Text("\(amount)")
                            .font(Theme.headlineFont)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.black.opacity(0.40))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, Theme.padding)

            Button {
                HapticManager.selection()
                withAnimation(Theme.springSnappy) {
                    selectedTarget = nil
                }
            } label: {
                Text(Strings.common.back)
                    .font(Theme.captionFont)
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
}
