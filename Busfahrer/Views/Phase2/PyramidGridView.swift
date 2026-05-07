import SwiftUI

struct PyramidGridView: View {
    @Environment(GameViewModel.self) private var game
    var activeRow: Int
    var activeCard: Int

    var body: some View {
        VStack(spacing: 8) {
            ForEach((0..<game.pyramidCards.count).reversed(), id: \.self) { rowIndex in
                let row = game.pyramidCards[rowIndex]
                let revealed = game.pyramidRevealed[rowIndex]

                HStack(spacing: 6) {
                    ForEach(Array(row.enumerated()), id: \.element.id) { cardIdx, card in
                        let isRevealed = revealed[cardIdx]
                        let isTappable = rowIndex == activeRow && !isRevealed

                        Button {
                            HapticManager.cardFlip()
                            game.phase2RevealCard(row: rowIndex, cardIndex: cardIdx)
                        } label: {
                            CardView(
                                card: isRevealed ? card : nil,
                                faceUp: isRevealed,
                                compact: true
                            )
                            .opacity(isRevealed ? 0.6 : 1.0)
                            .overlay(
                                Group {
                                    if isTappable {
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(rowGlowColor(rowIndex), lineWidth: 2)
                                            .shadow(color: rowGlowColor(rowIndex).opacity(0.5), radius: 6)
                                            .shadow(color: rowGlowColor(rowIndex).opacity(0.3), radius: 12)
                                    }
                                }
                            )
                        }
                        .disabled(!isTappable)
                        .accessibilityLabel(Strings.phase2.cardAccessibility(cardIdx + 1, rowIndex + 1))
                    }
                }

                // Row label with color gradient (bottom=cool, top=warm)
                Text(Strings.phase2.rowLabel(rowIndex + 1, game.sipsForRow(rowIndex)))
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(rowLabelColor(rowIndex, isActive: rowIndex == activeRow))
            }
        }
        .padding(.horizontal, Theme.padding)
    }

    private func rowGlowColor(_ row: Int) -> Color {
        let totalRows = game.pyramidCards.count
        let progress = Double(row) / Double(max(totalRows - 1, 1))
        // All white-based glow that gets brighter at higher rows
        return .white.opacity(0.6 + progress * 0.4)
    }

    private func rowLabelColor(_ row: Int, isActive: Bool) -> Color {
        if !isActive { return .white.opacity(0.45) }
        return .white.opacity(0.85)
    }
}
