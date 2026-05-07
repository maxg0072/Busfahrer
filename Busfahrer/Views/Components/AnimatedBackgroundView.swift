import SwiftUI

struct AnimatedBackgroundView: View {
    let colors: [Color]

    @State private var breathe = false

    var body: some View {
        Group {
            if colors.first == .black || colors.isEmpty {
                // Black base for home/setup/settings/end screens
                Color.black
            } else {
                // Solid phase color with animated radial gradient
                ZStack {
                    colors.first ?? Theme.phase1Color

                    RadialGradient(
                        colors: [
                            .white.opacity(breathe ? 0.10 : 0.06),
                            .clear
                        ],
                        center: .center,
                        startRadius: breathe ? 30 : 80,
                        endRadius: breathe ? 550 : 450
                    )
                }
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 3.5)
                        .repeatForever(autoreverses: true)
                    ) {
                        breathe = true
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}
