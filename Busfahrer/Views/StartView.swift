import SwiftUI

struct StartView: View {
    @Environment(GameViewModel.self) private var game
    @State private var showRules = false
    @State private var appear = false

    private var isBusfahrer: Bool { game.currentGame == .busfahrer }

    private var gameTitle: String {
        switch game.currentGame {
        case .busfahrer: return "Busfahrer"
        case .pferderennen: return Strings.pferderennen.title
        case .kingsCup: return Strings.kingsCup.title
        case .fckTheDealer: return Strings.ftd.title
        }
    }

    private var gameSubtitle: String {
        switch game.currentGame {
        case .busfahrer: return Strings.start.subtitle
        case .pferderennen: return Strings.pferderennen.subtitle
        case .kingsCup: return Strings.kingsCup.subtitle
        case .fckTheDealer: return Strings.ftd.subtitle
        }
    }

    private var gameEmoji: String {
        switch game.currentGame {
        case .busfahrer: return "🚌"
        case .pferderennen: return "🏇"
        case .kingsCup: return "👑"
        case .fckTheDealer: return "🃏"
        }
    }

    private var gameFlavorText: String {
        switch game.currentGame {
        case .busfahrer: return Strings.detail.flavorText
        case .pferderennen: return Strings.pferderennen.flavorText
        case .kingsCup: return Strings.kingsCup.flavorText
        case .fckTheDealer: return Strings.ftd.flavorText
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top bar: back, spacer, question mark (rules)
                HStack {
                    CircleIconButton(systemName: "chevron.left") {
                        withAnimation(Theme.springSnappy) {
                            game.phase = .home
                        }
                    }
                    Spacer()
                    CircleIconButton(systemName: "questionmark") {
                        showRules = true
                    }
                }
                .padding(.horizontal, Theme.padding)
                .padding(.top, 8)

                // Scrollable content
                ScrollView {
                    VStack(spacing: Theme.sectionSpacing) {
                        // Title section
                        VStack(spacing: 6) {
                            Text(gameTitle)
                                .font(Theme.detailTitleFont)
                                .foregroundStyle(.white)

                            Text(gameSubtitle)
                                .font(Theme.calloutFont)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(.top, 16)
                        .opacity(appear ? 1.0 : 0.0)

                        // Settings card
                        VStack(spacing: 0) {
                            // Players row
                            Button {
                                HapticManager.selection()
                                game.phase = .playerSetup
                            } label: {
                                HStack(spacing: 12) {
                                    Text("👥")
                                        .font(.system(size: 22))
                                    Text(Strings.detail.players)
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text("\(game.players.count)")
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(.white.opacity(0.5))
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.white.opacity(0.3))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }

                            // Card Style row (only for Busfahrer, which uses cards)
                            if isBusfahrer {
                                Theme.separator
                                    .frame(height: 1)
                                    .padding(.leading, 52)

                                Button {
                                    HapticManager.selection()
                                    withAnimation(Theme.springSnappy) {
                                        game.cardStyle = game.cardStyle == .neon ? .cartoon : .neon
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        Text("🃏")
                                            .font(.system(size: 22))
                                        Text(Strings.detail.cardStyle)
                                            .font(Theme.bodyFont)
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Text(game.cardStyle == .neon ? Strings.detail.neonStyle : Strings.detail.cartoonStyle)
                                            .font(Theme.bodyFont)
                                            .foregroundStyle(.white.opacity(0.5))
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(.white.opacity(0.3))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                }
                            }

                            Theme.separator
                                .frame(height: 1)
                                .padding(.leading, 52)

                            // Rules row
                            Button {
                                HapticManager.selection()
                                showRules = true
                            } label: {
                                HStack(spacing: 12) {
                                    Text("📖")
                                        .font(.system(size: 22))
                                    Text(Strings.start.rules)
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.white.opacity(0.3))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }
                        }
                        .background(Theme.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        .padding(.horizontal, Theme.padding)
                        .opacity(appear ? 1.0 : 0.0)

                        // Flavor text
                        Text(gameFlavorText)
                            .font(Theme.calloutFont)
                            .foregroundStyle(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.padding * 2)
                            .opacity(appear ? 1.0 : 0.0)

                        // Emoji art
                        Text(gameEmoji)
                            .font(.system(size: 100))
                            .scaleEffect(appear ? 1.0 : 0.5)
                            .opacity(appear ? 1.0 : 0.0)
                    }
                    .padding(.bottom, 120)
                }
            }

            // Fixed bottom Start Game button
            VStack {
                Spacer()
                Button {
                    HapticManager.selection()
                    if game.players.count >= 2 {
                        switch game.currentGame {
                        case .busfahrer: game.startGame()
                        case .pferderennen: game.startPferderennen()
                        case .kingsCup: game.startKingsCup()
                        case .fckTheDealer: game.startFckTheDealer()
                        }
                    } else {
                        game.phase = .playerSetup
                    }
                } label: {
                    Text(Strings.detail.startGame)
                        .font(Theme.bodyFont)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.buttonHeight)
                        .background(Theme.cardBg)
                        .clipShape(Capsule())
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.horizontal, Theme.padding)
                .padding(.bottom, Theme.buttonBottomPadding)
                .opacity(appear ? 1.0 : 0.0)
            }
        }
        .sheet(isPresented: $showRules) {
            switch game.currentGame {
            case .busfahrer:
                RulesView()
            case .pferderennen:
                PferderennenRulesView()
            case .kingsCup:
                KingsCupRulesView()
            case .fckTheDealer:
                FTDRulesView()
            }
        }
        .onAppear {
            appear = false
            withAnimation(Theme.springDramatic) {
                appear = true
            }
        }
    }
}

// MARK: - Pferderennen Rules

struct PferderennenRulesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text(Strings.pferderennen.rulesTitle)
                        .font(Theme.bodyFont)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .overlay(alignment: .trailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(width: 30, height: 30)
                            .background(Theme.cardBgElevated)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, Theme.padding)
                .padding(.top, 16)

                ScrollView {
                    Text(Strings.pferderennen.rulesText)
                        .font(Theme.calloutFont)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, Theme.padding)
                        .padding(.top, Theme.sectionSpacing)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Settings Sheet (Splash-style)
struct SettingsView: View {
    @Environment(LanguageManager.self) private var language
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Text(Strings.menu.settings)
                        .font(Theme.bodyFont)
                        .foregroundStyle(.white)
                    Spacer()
                }
                .overlay(alignment: .trailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(width: 30, height: 30)
                            .background(Theme.cardBgElevated)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, Theme.padding)
                .padding(.top, 16)

                ScrollView {
                    VStack(spacing: Theme.sectionSpacing) {
                        // Language section
                        VStack(spacing: 0) {
                            ForEach(AppLanguage.allCases, id: \.self) { lang in
                                Button {
                                    HapticManager.selection()
                                    language.current = lang
                                } label: {
                                    HStack(spacing: 12) {
                                        Text(lang.flag)
                                            .font(.system(size: 16))
                                            .frame(width: 32, height: 32)
                                            .background(Color.blue.opacity(0.15))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        Text(lang.displayName)
                                            .font(Theme.bodyFont)
                                            .foregroundStyle(.white)
                                        Spacer()
                                        if language.current == lang {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundStyle(Theme.accentGreen)
                                        }
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(.white.opacity(0.3))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                }

                                if lang != AppLanguage.allCases.last {
                                    Theme.separator
                                        .frame(height: 1)
                                        .padding(.leading, 52)
                                }
                            }
                        }
                        .background(Theme.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    }
                    .padding(.horizontal, Theme.padding)
                    .padding(.top, Theme.sectionSpacing)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
