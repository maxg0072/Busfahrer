import SwiftUI

struct ShimmerModifier: ViewModifier {
    var color: Color = .white
    var duration: Double = 2.5

    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: max(0, phase - 0.2)),
                            .init(color: color.opacity(0.35), location: phase),
                            .init(color: .clear, location: min(1, phase + 0.2)),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    phase = 1.2
                }
            }
    }
}

extension View {
    func shimmer(color: Color = .white, duration: Double = 2.5) -> some View {
        modifier(ShimmerModifier(color: color, duration: duration))
    }
}
