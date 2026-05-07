import SwiftUI

struct GlowingBorder: ViewModifier {
    let color: Color
    var lineWidth: CGFloat = 2
    var glowRadius: CGFloat = 8
    var cornerRadius: CGFloat = 12

    @State private var pulse = false

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(color, lineWidth: lineWidth)
                    .shadow(color: color.opacity(pulse ? 0.6 : 0.3), radius: glowRadius)
                    .shadow(color: color.opacity(pulse ? 0.3 : 0.1), radius: glowRadius * 2)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}

extension View {
    func glowingBorder(color: Color, lineWidth: CGFloat = 2, glowRadius: CGFloat = 8, cornerRadius: CGFloat = 12) -> some View {
        modifier(GlowingBorder(color: color, lineWidth: lineWidth, glowRadius: glowRadius, cornerRadius: cornerRadius))
    }
}
