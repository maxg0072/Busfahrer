import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    @State private var expired = false

    var body: some View {
        if !expired {
            GeometryReader { geo in
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let now = timeline.date.timeIntervalSinceReferenceDate
                        for particle in particles {
                            let elapsed = now - particle.startTime
                            guard elapsed > 0, elapsed < particle.lifetime else { continue }

                            let progress = elapsed / particle.lifetime

                            // Initial upward burst then gravity fall
                            let burstY = particle.initialVelocityY * elapsed
                            let gravityY = 0.5 * particle.gravity * elapsed * elapsed
                            let y = particle.startY + burstY + gravityY

                            let x = particle.startX + sin(elapsed * particle.wobbleSpeed) * particle.wobbleAmount

                            // Fade in final 20%
                            let opacity = progress > 0.8 ? 1.0 - ((progress - 0.8) / 0.2) : 1.0

                            guard y < size.height + 20, opacity > 0.01 else { continue }

                            let rotation = elapsed * particle.rotationSpeed

                            context.opacity = opacity

                            switch particle.shape {
                            case .rectangle:
                                let transform = CGAffineTransform(translationX: x, y: y)
                                    .rotated(by: rotation)
                                let rect = CGRect(
                                    x: -particle.size / 2,
                                    y: -particle.size * 0.3,
                                    width: particle.size,
                                    height: particle.size * 0.6
                                )
                                var path = Path(roundedRect: rect, cornerRadius: 2)
                                path = path.applying(transform)
                                context.fill(path, with: .color(particle.color))

                            case .circle:
                                let rect = CGRect(
                                    x: x - particle.size / 2,
                                    y: y - particle.size / 2,
                                    width: particle.size,
                                    height: particle.size
                                )
                                context.fill(Path(ellipseIn: rect), with: .color(particle.color))

                            case .triangle:
                                var path = Path()
                                let s = particle.size
                                path.move(to: .init(x: 0, y: -s / 2))
                                path.addLine(to: .init(x: s / 2, y: s / 2))
                                path.addLine(to: .init(x: -s / 2, y: s / 2))
                                path.closeSubpath()
                                let transform = CGAffineTransform(translationX: x, y: y)
                                    .rotated(by: rotation)
                                path = path.applying(transform)
                                context.fill(path, with: .color(particle.color))
                            }
                        }
                    }
                }
                .onAppear {
                    generateParticles(screenWidth: geo.size.width)
                    // Auto-expire after max particle lifetime + stagger to stop TimelineView
                    DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
                        expired = true
                    }
                }
            }
        }
    }

    private func generateParticles(screenWidth: Double) {
        let colors: [Color] = [
            Theme.phase1Color, Theme.phase2Color, Theme.accentGreen, Theme.gold,
            Theme.correct, .yellow, .orange, .pink
        ]
        let shapes: [ConfettiShape] = [.rectangle, .circle, .triangle]

        particles = (0..<100).map { _ in
            ConfettiParticle(
                startX: Double.random(in: 0...screenWidth),
                startY: Double.random(in: -20...40),
                size: Double.random(in: 6...12),
                color: colors.randomElement()!,
                shape: shapes.randomElement()!,
                initialVelocityY: Double.random(in: -250...(-80)),
                gravity: Double.random(in: 200...400),
                wobbleSpeed: Double.random(in: 2...6),
                wobbleAmount: Double.random(in: 20...60),
                rotationSpeed: Double.random(in: 1...8),
                lifetime: Double.random(in: 3...6),
                startTime: Date.now.timeIntervalSinceReferenceDate + Double.random(in: 0...0.8)
            )
        }
    }
}

private enum ConfettiShape {
    case rectangle, circle, triangle
}

private struct ConfettiParticle {
    let startX: Double
    let startY: Double
    let size: Double
    let color: Color
    let shape: ConfettiShape
    let initialVelocityY: Double
    let gravity: Double
    let wobbleSpeed: Double
    let wobbleAmount: Double
    let rotationSpeed: Double
    let lifetime: Double
    let startTime: Double
}
