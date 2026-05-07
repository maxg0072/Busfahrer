import SwiftUI

struct PlayerBadgeView: View {
    let player: Player
    var isActive: Bool = false
    var showSips: Bool = true
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 8 : 12) {
            Circle()
                .fill(player.color)
                .frame(width: compact ? 20 : 28, height: compact ? 20 : 28)
                .overlay(
                    Circle()
                        .strokeBorder(.white.opacity(isActive ? 0.9 : 0), lineWidth: 2)
                )

            Text(player.name)
                .font(compact ? Theme.captionFont : Theme.bodyFont)
                .foregroundStyle(.white)
                .lineLimit(1)

            if showSips {
                Spacer()

                HStack(spacing: 8) {
                    Label("\(player.sipsReceived)", systemImage: "arrow.down.circle.fill")
                        .font(Theme.captionFont)
                        .foregroundStyle(.white.opacity(0.85))
                        .contentTransition(.numericText())
                        .animation(Theme.springSnappy, value: player.sipsReceived)

                    Label("\(player.sipsDistributed)", systemImage: "arrow.up.circle.fill")
                        .font(Theme.captionFont)
                        .foregroundStyle(.white.opacity(0.85))
                        .contentTransition(.numericText())
                        .animation(Theme.springSnappy, value: player.sipsDistributed)
                }
            }
        }
        .padding(.horizontal, compact ? 10 : 14)
        .padding(.vertical, compact ? 6 : 10)
        .background(
            RoundedRectangle(cornerRadius: compact ? 8 : 12)
                .fill(isActive ? Theme.cardBgElevated : Theme.cardBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: compact ? 8 : 12)
                .strokeBorder(
                    isActive ? .white.opacity(0.3) : .clear,
                    lineWidth: 1.5
                )
        )
    }
}
