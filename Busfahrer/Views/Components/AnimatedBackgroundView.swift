import SwiftUI

struct AnimatedBackgroundView: View {
    let colors: [Color]

    @State private var breathe = false

    private var isBlack: Bool {
        colors.first == .black || colors.isEmpty
    }

    var body: some View {
        Group {
            if isBlack {
                // Black base for home/setup/settings/end screens
                Color.black
            } else {
                // Solid phase color with animated radial gradient
                ZStack {
                    (colors.first ?? Theme.phase1Color)
                        .animation(.easeInOut(duration: 0.6), value: colors.first)

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
