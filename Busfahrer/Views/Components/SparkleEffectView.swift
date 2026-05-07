import SwiftUI

struct SparkleEffectView: View {
    let color: Color
    let count: Int

    init(color: Color = .yellow, count: Int = 30) {
        self.color = color
        self.count = count
    }

    @State private var sparkles: [Sparkle] = []

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                for sparkle in sparkles {
                    let elapsed = now - sparkle.startTime
                    let cycle = elapsed * sparkle.speed
                    let pulse = (sin(cycle) + 1) / 2  // 0...1
                    let opacity = pulse * sparkle.maxOpacity

                    guard opacity > 0.01 else { continue }

                    let x = sparkle.x * size.width
                    let y = sparkle.y * size.height
                    let starSize = sparkle.size * (0.5 + pulse * 0.5)

                    context.opacity = opacity
                    context.fill(
                        beerMugPath(at: CGPoint(x: x, y: y), size: starSize),
                        with: .color(sparkle.color)
                    )
                }
            }
        }
        .onAppear { generateSparkles() }
        .allowsHitTesting(false)
    }

    private func beerMugPath(at center: CGPoint, size: CGFloat) -> Path {
        var path = Path()

        let s = size
        // Shift left slightly so handle doesn't push mug off-center
        let cx = center.x - s * 0.05
        let cy = center.y

        // Mug body
        let bodyW = s * 0.5
        let bodyH = s * 0.6
        let bodyRect = CGRect(
            x: cx - bodyW / 2,
            y: cy - bodyH * 0.3,
            width: bodyW,
            height: bodyH
        )
        path.addRoundedRect(in: bodyRect, cornerSize: CGSize(width: s * 0.06, height: s * 0.06))

        // Foam cap (slightly wider, overlapping top of body)
        let foamW = bodyW * 1.15
        let foamH = s * 0.2
        let foamRect = CGRect(
            x: cx - foamW / 2,
            y: bodyRect.minY - foamH * 0.55,
            width: foamW,
            height: foamH
        )
        path.addRoundedRect(in: foamRect, cornerSize: CGSize(width: foamH * 0.5, height: foamH * 0.5))

        // Handle (D-shape on right side)
        let hx = bodyRect.maxX
        let hTopY = bodyRect.minY + bodyH * 0.18
        let hBotY = bodyRect.minY + bodyH * 0.72
        let hOutX = hx + s * 0.2
        let thick = s * 0.08

        path.move(to: CGPoint(x: hx, y: hTopY))
        path.addCurve(
            to: CGPoint(x: hx, y: hBotY),
            control1: CGPoint(x: hOutX, y: hTopY),
            control2: CGPoint(x: hOutX, y: hBotY)
        )
        path.addCurve(
            to: CGPoint(x: hx, y: hTopY),
            control1: CGPoint(x: hOutX - thick, y: hBotY),
            control2: CGPoint(x: hOutX - thick, y: hTopY)
        )

        return path
    }

    private func generateSparkles() {
        sparkles = (0..<count).map { _ in
            Sparkle(
                x: Double.random(in: 0.05...0.95),
                y: Double.random(in: 0.05...0.95),
                size: Double.random(in: 10...22),
                speed: Double.random(in: 1.5...4.0),
                maxOpacity: Double.random(in: 0.3...0.8),
                startTime: Date.now.timeIntervalSinceReferenceDate - Double.random(in: 0...3),
                color: color
            )
        }
    }
}

private struct Sparkle {
    let x: Double
    let y: Double
    let size: Double
    let speed: Double
    let maxOpacity: Double
    let startTime: Double
    let color: Color
}
