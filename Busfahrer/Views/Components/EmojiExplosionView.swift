import SwiftUI

/// A burst of emoji particles that fly outward from the center and fade out.
/// Used for correct answers (🍺), celebrations (🎉), and punishments (💀).
struct EmojiExplosionView: View {
    let emojis: [String]
    let count: Int
    var particleSize: CGFloat = 28

    @State private var particles: [EmojiParticle] = []
    @State private var animating = false

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Text(particle.emoji)
                    .font(.system(size: particleSize * particle.scale))
                    .offset(
                        x: animating ? particle.endX : 0,
                        y: animating ? particle.endY : 0
                    )
                    .opacity(animating ? 0 : 1)
                    .rotationEffect(.degrees(animating ? particle.rotation : 0))
                    .scaleEffect(animating ? 0.3 : 1.2)
            }
        }
        .onAppear {
            particles = (0..<count).map { _ in
                let angle = Double.random(in: 0...(2 * .pi))
                let distance = Double.random(in: 80...220)
                return EmojiParticle(
                    emoji: emojis.randomElement() ?? "🍺",
                    endX: CGFloat(cos(angle) * distance),
                    endY: CGFloat(sin(angle) * distance),
                    rotation: Double.random(in: -180...180),
                    scale: CGFloat.random(in: 0.6...1.2)
                )
            }
            withAnimation(.easeOut(duration: 1.2)) {
                animating = true
            }
        }
        .allowsHitTesting(false)
    }
}

private struct EmojiParticle: Identifiable {
    let id = UUID()
    let emoji: String
    let endX: CGFloat
    let endY: CGFloat
    let rotation: Double
    let scale: CGFloat
}
