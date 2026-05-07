import SwiftUI

// MARK: - DarkCard (replaces GlassCard — Splash-style)
struct DarkCard: ViewModifier {
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Theme.cardBg)
            )
    }
}

extension View {
    func darkCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(DarkCard(cornerRadius: cornerRadius))
    }

    // Keep glassCard as alias for backward compatibility during migration
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(DarkCard(cornerRadius: cornerRadius))
    }
}
