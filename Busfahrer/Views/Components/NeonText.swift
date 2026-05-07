import SwiftUI

struct NeonText: View {
    let text: String
    let color: Color
    var font: Font = Theme.titleFont

    @State private var glow = false

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(glow ? 0.3 : 0.15), radius: glow ? 8 : 4)
            .shadow(color: color.opacity(glow ? 0.3 : 0.15), radius: glow ? 16 : 8)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    glow = true
                }
            }
    }
}
