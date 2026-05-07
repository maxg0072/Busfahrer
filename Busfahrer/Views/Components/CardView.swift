import SwiftUI

struct CardView: View {
    @Environment(GameViewModel.self) private var game
    let card: Card?
    var faceUp: Bool = true
    var compact: Bool = false

    @State private var flipProgress: Double = 0
    @State private var flipScale: CGFloat = 1.0

    private var width: CGFloat { compact ? 55 : 80 }
    private var height: CGFloat { compact ? 77 : 112 }

    var body: some View {
        ZStack {
            if flipProgress < 0.5 {
                cardBack
            } else {
                cardFace
                    .scaleEffect(x: -1, y: 1)
            }
        }
        .frame(width: width, height: height)
        .scaleEffect(flipScale)
        .rotation3DEffect(.degrees(flipProgress * 180), axis: (x: 0, y: 1, z: 0), perspective: 0.4)
        .shadow(
            color: (flipProgress > 0.2 && flipProgress < 0.8) ? Theme.phase1Color.opacity(0.4) : .clear,
            radius: 12
        )
        .onChange(of: faceUp) { _, newValue in
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                flipProgress = newValue ? 1.0 : 0.0
            }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6).delay(0.15)) {
                flipScale = 1.08
            }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7).delay(0.35)) {
                flipScale = 1.0
            }
        }
        .onAppear {
            flipProgress = faceUp ? 1.0 : 0.0
        }
    }

    @ViewBuilder
    private var cardBack: some View {
        switch game.cardStyle {
        case .neon:
            NeonCardBack(compact: compact)
        case .cartoon:
            CartoonCardBack(compact: compact)
        }
    }

    @ViewBuilder
    private var cardFace: some View {
        if let card = card {
            switch game.cardStyle {
            case .neon:
                NeonCardFace(card: card, compact: compact)
            case .cartoon:
                CartoonCardFace(card: card, compact: compact)
            }
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// MARK: - Neon / Glow Style

struct NeonCardBack: View {
    var compact: Bool = false
    @State private var shimmerOffset: CGFloat = -1.0

    var body: some View {
        ZStack {
            // Base: Deep dark with subtle purple tint
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.02, blue: 0.15),
                            Color(red: 0.02, green: 0.01, blue: 0.10),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Neon grid pattern
            Canvas { context, size in
                let inset: CGFloat = 6
                let spacing: CGFloat = compact ? 10 : 14
                let clipRect = CGRect(x: inset, y: inset, width: size.width - inset * 2, height: size.height - inset * 2)
                context.clip(to: RoundedRectangle(cornerRadius: 7).path(in: clipRect))

                // Horizontal lines
                for y in stride(from: inset, through: size.height - inset, by: spacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: inset, y: y))
                    path.addLine(to: CGPoint(x: size.width - inset, y: y))
                    context.stroke(path, with: .color(Color(red: 0.4, green: 0.2, blue: 1.0).opacity(0.12)), lineWidth: 0.5)
                }
                // Vertical lines
                for x in stride(from: inset, through: size.width - inset, by: spacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: inset))
                    path.addLine(to: CGPoint(x: x, y: size.height - inset))
                    context.stroke(path, with: .color(Color(red: 0.4, green: 0.2, blue: 1.0).opacity(0.12)), lineWidth: 0.5)
                }
            }

            // Neon border glow
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color(red: 0.5, green: 0.3, blue: 1.0).opacity(0.7),
                            Color(red: 0.2, green: 0.8, blue: 1.0).opacity(0.5),
                            Color(red: 0.5, green: 0.3, blue: 1.0).opacity(0.7),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: compact ? 1.5 : 2.0
                )

            // Inner glow line
            RoundedRectangle(cornerRadius: 7)
                .strokeBorder(Color(red: 0.4, green: 0.2, blue: 1.0).opacity(0.15), lineWidth: 0.75)
                .padding(4)

            // Center: Beer mug icon with neon glow
            VStack(spacing: compact ? 4 : 6) {
                Text("🍺")
                    .font(.system(size: compact ? 14 : 20))
                Text("?")
                    .font(.system(size: compact ? 14 : 20, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.5, green: 0.3, blue: 1.0),
                                Color(red: 0.3, green: 0.7, blue: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(red: 0.4, green: 0.2, blue: 1.0).opacity(0.8), radius: 6)
            }

            // Shimmer sweep
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.08), .clear],
                        startPoint: UnitPoint(x: shimmerOffset - 0.3, y: 0),
                        endPoint: UnitPoint(x: shimmerOffset + 0.3, y: 1)
                    )
                )
                .allowsHitTesting(false)
        }
        .shadow(color: Color(red: 0.4, green: 0.2, blue: 1.0).opacity(0.3), radius: 8, y: 2)
        .onAppear {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                shimmerOffset = 2.0
            }
        }
    }
}

struct NeonCardFace: View {
    let card: Card
    var compact: Bool = false

    private var neonColor: Color {
        card.isRed
            ? Color(red: 1.0, green: 0.15, blue: 0.3)
            : Color(red: 0.3, green: 0.5, blue: 1.0)
    }

    private var bgGradient: [Color] {
        card.isRed
            ? [Color(red: 0.12, green: 0.02, blue: 0.05), Color(red: 0.08, green: 0.01, blue: 0.03)]
            : [Color(red: 0.02, green: 0.03, blue: 0.12), Color(red: 0.01, green: 0.02, blue: 0.08)]
    }

    private var illustrationName: String? {
        switch card.value {
        case .koenig:
            switch card.suit {
            case .herz:  return "king_hearts"
            case .karo:  return "king_diamonds"
            case .kreuz: return "king_clubs"
            case .pik:   return "king_spades"
            }
        default: return nil
        }
    }

    var body: some View {
        ZStack {
            // Dark background
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(colors: bgGradient, startPoint: .topLeading, endPoint: .bottomTrailing))

            if let imgName = illustrationName {
                // Illustration filling the card, aligned to bottom
                Image(imgName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .clipped()

                // Subtle neon color wash
                RoundedRectangle(cornerRadius: 10)
                    .fill(neonColor.opacity(0.10))
            } else {
                // Suit watermark for number cards
                Text(card.suit.symbol)
                    .font(.system(size: compact ? 35 : 55))
                    .foregroundStyle(neonColor.opacity(0.08))

                // Value + suit
                VStack(spacing: compact ? 1 : 3) {
                    Text(card.value.displayName)
                        .font(.system(size: compact ? 20 : 30, weight: .black, design: .rounded))
                        .foregroundStyle(neonColor)
                        .shadow(color: neonColor.opacity(0.8), radius: 4)
                    Text(card.suit.symbol)
                        .font(.system(size: compact ? 14 : 20))
                        .shadow(color: neonColor.opacity(0.6), radius: 3)
                }
            }

            // Corner indicators (always shown)
            VStack {
                HStack {
                    cornerLabel
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    cornerLabel.rotationEffect(.degrees(180))
                }
            }
            .padding(compact ? 3 : 5)

            // Neon border (glows brighter for face cards)
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    neonColor.opacity(illustrationName != nil ? 0.9 : 0.5),
                    lineWidth: compact ? (illustrationName != nil ? 1.5 : 1.0) : (illustrationName != nil ? 2.0 : 1.5)
                )
                .shadow(color: neonColor.opacity(illustrationName != nil ? 0.6 : 0), radius: 4)
        }
        .shadow(color: neonColor.opacity(illustrationName != nil ? 0.5 : 0.25), radius: illustrationName != nil ? 10 : 6, y: 2)
    }

    private var cornerLabel: some View {
        VStack(spacing: 0) {
            Text(card.value.displayName)
                .font(.system(size: compact ? 8 : 10, weight: .bold, design: .rounded))
            Text(card.suit.symbol)
                .font(.system(size: compact ? 6 : 8))
        }
        .foregroundStyle(neonColor.opacity(0.6))
    }

    private var drinkEmoji: String {
        switch card.value {
        case .koenig: return "🍺"
        case .dame: return "🍷"
        case .bube: return "🍸"
        case .ass: return "🥂"
        default: return ""
        }
    }
}

// MARK: - Cartoon / Illustrative Style

struct CartoonCardBack: View {
    var compact: Bool = false

    var body: some View {
        ZStack {
            // Warm orange-red base
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.25, blue: 0.15),
                            Color(red: 0.70, green: 0.15, blue: 0.10),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Checkerboard pattern with drink icons
            Canvas { context, size in
                let inset: CGFloat = 6
                let spacing: CGFloat = compact ? 12 : 16
                let clipRect = CGRect(x: inset, y: inset, width: size.width - inset * 2, height: size.height - inset * 2)
                context.clip(to: RoundedRectangle(cornerRadius: 7).path(in: clipRect))

                var toggle = false
                for row in stride(from: inset, through: size.height - inset, by: spacing) {
                    toggle.toggle()
                    var colToggle = toggle
                    for col in stride(from: inset, through: size.width - inset, by: spacing) {
                        if colToggle {
                            let rect = CGRect(x: col, y: row, width: spacing, height: spacing)
                            context.fill(Path(rect), with: .color(.white.opacity(0.06)))
                        }
                        colToggle.toggle()
                    }
                }
            }

            // White rounded inner frame
            RoundedRectangle(cornerRadius: 7)
                .strokeBorder(.white.opacity(0.4), lineWidth: compact ? 1.5 : 2.5)
                .padding(5)

            // Outer border
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.white.opacity(0.25), lineWidth: compact ? 1.0 : 1.5)

            // Center motif: beer mug cartoon style
            VStack(spacing: compact ? 2 : 4) {
                Text("🍻")
                    .font(.system(size: compact ? 18 : 28))
                Text("?")
                    .font(.system(size: compact ? 14 : 20, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
            }
            .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
        }
        .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
    }
}

struct CartoonCardFace: View {
    let card: Card
    var compact: Bool = false

    private var cardColor: Color {
        card.isRed ? Color(red: 0.90, green: 0.20, blue: 0.25) : Color(red: 0.15, green: 0.15, blue: 0.20)
    }

    /// Background color per suit for illustrated cards
    private var illustrationBgColor: Color {
        switch card.suit {
        case .herz:   return Color(red: 0.95, green: 0.88, blue: 0.88) // soft red
        case .karo:   return Color(red: 0.88, green: 0.90, blue: 0.98) // soft blue
        case .kreuz:  return Color(red: 0.88, green: 0.96, blue: 0.90) // soft green
        case .pik:    return Color(red: 0.88, green: 0.88, blue: 0.92) // soft dark
        }
    }

    private var bgColor: Color {
        Color(red: 0.98, green: 0.96, blue: 0.92) // warm cream
    }

    /// Asset name for face card illustrations (currently only kings)
    private var illustrationName: String? {
        switch card.value {
        case .koenig:
            switch card.suit {
            case .herz:  return "king_hearts"
            case .karo:  return "king_diamonds"
            case .kreuz: return "king_clubs"
            case .pik:   return "king_spades"
            }
        default:
            return nil
        }
    }

    var body: some View {
        ZStack {
            if let imageName = illustrationName {
                // Illustrated face card
                RoundedRectangle(cornerRadius: 10)
                    .fill(illustrationBgColor)

                // Character illustration fills the card
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .clipped()

                // Corner labels (top-left + bottom-right)
                VStack {
                    HStack {
                        cartoonCorner
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        cartoonCorner
                            .rotationEffect(.degrees(180))
                    }
                }
                .padding(compact ? 3 : 5)

                // Border
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(cardColor.opacity(0.3), lineWidth: compact ? 1.5 : 2.5)

            } else {
                // Number / non-illustrated card
                // Cream/warm white background
                RoundedRectangle(cornerRadius: 10)
                    .fill(bgColor)

                // Subtle scattered drink icons
                if !compact {
                    Canvas { context, size in
                        let emojis = ["🍺", "🍷", "🍸", "🥂"]
                        let positions: [(CGFloat, CGFloat)] = [
                            (0.2, 0.25), (0.8, 0.3), (0.15, 0.7), (0.85, 0.75),
                            (0.5, 0.15), (0.5, 0.85)
                        ]
                        for (i, pos) in positions.enumerated() {
                            let text = Text(emojis[i % emojis.count]).font(.system(size: 8))
                            context.opacity = 0.12
                            context.draw(context.resolve(text),
                                         at: CGPoint(x: size.width * pos.0, y: size.height * pos.1))
                        }
                    }
                }

                // Big center value + suit
                VStack(spacing: compact ? 1 : 4) {
                    Text(card.value.displayName)
                        .font(.system(size: compact ? 20 : 30, weight: .black, design: .rounded))
                        .foregroundStyle(cardColor)

                    Text(card.suit.symbol)
                        .font(.system(size: compact ? 16 : 24))
                        .foregroundStyle(cardColor)
                }

                // Corner labels
                VStack {
                    HStack {
                        cartoonCorner
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        cartoonCorner
                            .rotationEffect(.degrees(180))
                    }
                }
                .padding(compact ? 3 : 5)

                // Playful colored border
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(cardColor.opacity(0.3), lineWidth: compact ? 1.5 : 2.5)
            } // end else
        }
        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
    }

    private var cartoonCorner: some View {
        VStack(spacing: 0) {
            Text(card.value.displayName)
                .font(.system(size: compact ? 8 : 11, weight: .bold, design: .rounded))
            Text(card.suit.symbol)
                .font(.system(size: compact ? 7 : 9))
        }
        .foregroundStyle(cardColor)
    }

    private var cartoonDrinkEmoji: String {
        switch card.value {
        case .koenig: return "🍺"
        case .dame: return "🍷"
        case .bube: return "🍸"
        case .ass: return "🥂"
        default: return ""
        }
    }
}

// MARK: - Large Card View

struct LargeCardView: View {
    @Environment(GameViewModel.self) private var game
    let card: Card
    @State private var appear = false

    var body: some View {
        switch game.cardStyle {
        case .neon:
            neonLargeCard
        case .cartoon:
            cartoonLargeCard
        }
    }

    private var neonColor: Color {
        card.isRed
            ? Color(red: 1.0, green: 0.15, blue: 0.3)
            : Color(red: 0.3, green: 0.5, blue: 1.0)
    }

    private var neonLargeCard: some View {
        let imgName = cartoonIllustrationName  // reuse same illustration logic

        return ZStack {
            // Dark bg
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: card.isRed
                            ? [Color(red: 0.15, green: 0.02, blue: 0.05), Color(red: 0.10, green: 0.01, blue: 0.03)]
                            : [Color(red: 0.02, green: 0.03, blue: 0.15), Color(red: 0.01, green: 0.02, blue: 0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            if let imgName {
                // Illustration filling the card
                Image(imgName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 220, alignment: .bottom)
                    .clipped()

                // Subtle neon wash
                RoundedRectangle(cornerRadius: 20)
                    .fill(neonColor.opacity(0.08))

                // Value + suit corner label
                VStack {
                    HStack {
                        VStack(spacing: 2) {
                            Text(card.value.displayName)
                                .font(.system(size: 16, weight: .black, design: .rounded))
                                .foregroundStyle(neonColor)
                                .shadow(color: neonColor.opacity(0.9), radius: 4)
                            Text(card.suit.symbol)
                                .font(.system(size: 13))
                                .shadow(color: neonColor.opacity(0.6), radius: 3)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(10)

            } else {
                // Number card: text only
                Text(card.suit.symbol)
                    .font(.system(size: 100))
                    .foregroundStyle(neonColor.opacity(0.06))

                VStack(spacing: 8) {
                    Text(card.suit.symbol)
                        .font(.system(size: 50))
                        .shadow(color: neonColor.opacity(0.8), radius: 8)
                    Text(card.value.displayName)
                        .font(.system(size: 60, weight: .black, design: .rounded))
                        .foregroundStyle(neonColor)
                        .shadow(color: neonColor.opacity(0.9), radius: 10)
                }
            }

            // Neon border (brighter for illustrated cards)
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(neonColor.opacity(imgName != nil ? 0.9 : 0.6), lineWidth: imgName != nil ? 2.5 : 2)
                .shadow(color: neonColor.opacity(imgName != nil ? 0.5 : 0), radius: 6)
        }
        .frame(width: 160, height: 220)
        .shadow(color: neonColor.opacity(imgName != nil ? 0.6 : 0.4), radius: imgName != nil ? 25 : 20)
        .scaleEffect(appear ? 1.0 : 0.5)
        .opacity(appear ? 1.0 : 0.0)
        .onAppear {
            withAnimation(Theme.springBouncy) { appear = true }
        }
        .onDisappear { appear = false }
    }

    private var cartoonLargeCard: some View {
        let cardColor = card.isRed ? Color(red: 0.90, green: 0.20, blue: 0.25) : Color(red: 0.15, green: 0.15, blue: 0.20)
        let imgName = cartoonIllustrationName

        return ZStack {
            if let imgName {
                // Illustrated face card (kings etc.)
                RoundedRectangle(cornerRadius: 20)
                    .fill(cartoonIllustrationBgColor)

                Image(imgName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 220, alignment: .bottom)
                    .clipped()

                // Corner labels
                VStack {
                    HStack {
                        largeSuitCorner(color: cardColor)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        largeSuitCorner(color: cardColor)
                            .rotationEffect(.degrees(180))
                    }
                }
                .padding(10)

            } else {
                // Number card
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.98, green: 0.96, blue: 0.92))

                Canvas { context, size in
                    let emojis = ["🍺", "🍷", "🍸", "🥂", "🍻", "🥃"]
                    let positions: [(CGFloat, CGFloat)] = [
                        (0.12, 0.15), (0.88, 0.12), (0.10, 0.85), (0.90, 0.88),
                        (0.15, 0.50), (0.85, 0.50), (0.50, 0.08), (0.50, 0.92)
                    ]
                    for (i, pos) in positions.enumerated() {
                        let text = Text(emojis[i % emojis.count]).font(.system(size: 12))
                        context.opacity = 0.10
                        context.draw(context.resolve(text),
                                     at: CGPoint(x: size.width * pos.0, y: size.height * pos.1))
                    }
                }

                VStack(spacing: 8) {
                    Text(card.suit.symbol)
                        .font(.system(size: 50))
                    Text(card.value.displayName)
                        .font(.system(size: 60, weight: .heavy, design: .rounded))
                }
                .foregroundStyle(cardColor)
            }

            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(cardColor.opacity(0.3), lineWidth: 3)
        }
        .frame(width: 160, height: 220)
        .shadow(color: .black.opacity(0.15), radius: 20)
        .shadow(color: (card.isRed ? Color.red : Color.blue).opacity(0.15), radius: 30)
        .scaleEffect(appear ? 1.0 : 0.5)
        .opacity(appear ? 1.0 : 0.0)
        .onAppear {
            withAnimation(Theme.springBouncy) { appear = true }
        }
        .onDisappear { appear = false }
    }

    private func largeSuitCorner(color: Color) -> some View {
        VStack(spacing: 0) {
            Text(card.value.displayName)
                .font(.system(size: 14, weight: .bold, design: .rounded))
            Text(card.suit.symbol)
                .font(.system(size: 11))
        }
        .foregroundStyle(color)
    }

    private var cartoonIllustrationName: String? {
        switch card.value {
        case .koenig:
            switch card.suit {
            case .herz:  return "king_hearts"
            case .karo:  return "king_diamonds"
            case .kreuz: return "king_clubs"
            case .pik:   return "king_spades"
            }
        default:
            return nil
        }
    }

    private var cartoonIllustrationBgColor: Color {
        switch card.suit {
        case .herz:   return Color(red: 0.95, green: 0.88, blue: 0.88)
        case .karo:   return Color(red: 0.88, green: 0.90, blue: 0.98)
        case .kreuz:  return Color(red: 0.88, green: 0.96, blue: 0.90)
        case .pik:    return Color(red: 0.88, green: 0.88, blue: 0.92)
        }
    }

    private var neonDrinkEmoji: String {
        switch card.value {
        case .koenig: return "🍺"
        case .dame: return "🍷"
        case .bube: return "🍸"
        case .ass: return "🥂"
        default: return ""
        }
    }
}
