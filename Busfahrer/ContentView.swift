import SwiftUI

struct ContentView: View {
    @Environment(GameViewModel.self) private var game
    @State private var showMenu = false
    @State private var showRules = false

    private var showMenuButton: Bool {
        switch game.phase {
        case .home, .start, .gameEnd, .pferderennenFinish, .kingsCupGameOver, .ftdGameOver:
            return false
        default:
            return true
        }
    }

    private var gameTitle: String {
        switch game.currentGame {
        case .busfahrer: return "Busfahrer"
        case .pferderennen: return Strings.pferderennen.title
        case .kingsCup: return Strings.kingsCup.title
        case .fckTheDealer: return Strings.ftd.title
        }
    }

    private var phaseColors: [Color] {
        switch game.phase {
        case .home:
            return Theme.startColors
        case .start:
            switch game.currentGame {
            case .busfahrer: return [Theme.busfahrerColor]
            case .pferderennen: return [Theme.pferderennenColor]
            case .kingsCup: return [Theme.kingsCupColor]
            case .fckTheDealer: return [Theme.ftdColor]
            }
        case .playerSetup:
            switch game.currentGame {
            case .busfahrer: return [Theme.busfahrerColor]
            case .pferderennen: return [Theme.pferderennenColor]
            case .kingsCup: return [Theme.kingsCupColor]
            case .fckTheDealer: return [Theme.ftdColor]
            }
        case .phaseTransition(let target):
            switch target {
            case .phase1: return Theme.phase1Colors
            case .phase2: return Theme.phase2Colors
            case .phase3: return Theme.phase3Colors
            case .gameEnd: return Theme.startColors
            case .pferderennenRace: return Theme.pferderennenColors
            case .kingsCup: return Theme.kingsCupColors
            case .fckTheDealer: return Theme.ftdColors
            }
        case .phase1, .phase1Reveal, .phase1SipDistribution:
            return Theme.phase1Colors
        case .phase2Setup, .phase2, .phase2Reveal, .phase2Discard, .phase2SipDistribution,
             .phase2BusDriverReveal, .phase2Oracle:
            return Theme.phase2Colors
        case .phase3, .phase3Reveal:
            return Theme.phase3Colors
        case .gameEnd:
            return Theme.startColors
        // Pferderennen
        case .pferderennenBetting, .pferderennenPreDrink:
            return Theme.pferderennenColors
        case .pferderennenRace, .pferderennenCardReveal, .pferderennenTrackReveal:
            return Theme.pferderennenColors
        case .pferderennenFinish, .pferderennenSipDistribution:
            return Theme.pferderennenColors
        // Kings Cup
        case .kingsCupTurn, .kingsCupCardReveal, .kingsCupAction, .kingsCupDistribute, .kingsCupPickBuddy:
            return Theme.kingsCupColors
        case .kingsCupGameOver:
            return Theme.kingsCupColors
        // FTD
        case .ftdGuess1, .ftdHint, .ftdGuess2, .ftdReveal, .ftdDrink:
            return Theme.ftdColors
        case .ftdGameOver:
            return Theme.ftdColors
        }
    }

    var body: some View {
        ZStack {
            AnimatedBackgroundView(colors: phaseColors)

            Group {
                switch game.phase {
                case .home:
                    HomeView()
                case .start:
                    StartView()
                case .playerSetup:
                    PlayerSetupView()
                case .phase1, .phase1Reveal, .phase1SipDistribution:
                    Phase1View()
                case .phaseTransition(let target):
                    PhaseTransitionView(target: target)
                case .phase2Setup, .phase2, .phase2Reveal, .phase2Discard, .phase2SipDistribution:
                    Phase2View()
                case .phase2BusDriverReveal, .phase2Oracle:
                    BusDriverRevealView()
                case .phase3, .phase3Reveal:
                    Phase3View()
                case .gameEnd:
                    if game.currentGame == .pferderennen {
                        PferderennenResultView()
                    } else {
                        GameEndView()
                    }
                // Pferderennen
                case .pferderennenBetting, .pferderennenPreDrink:
                    PferderennenBettingView()
                case .pferderennenRace, .pferderennenCardReveal:
                    PferderennenRaceView()
                case .pferderennenTrackReveal:
                    PferderennenRaceView()
                case .pferderennenFinish:
                    PferderennenResultView()
                case .pferderennenSipDistribution:
                    PferderennenSipDistributionView()
                // Kings Cup
                case .kingsCupTurn, .kingsCupCardReveal, .kingsCupAction, .kingsCupDistribute, .kingsCupPickBuddy:
                    KingsCupGameView()
                case .kingsCupGameOver:
                    KingsCupGameOverView()
                // FTD
                case .ftdGuess1, .ftdHint, .ftdGuess2, .ftdReveal, .ftdDrink:
                    FTDGameView()
                case .ftdGameOver:
                    FTDGameOverView()
                }
            }
            .transaction { $0.animation = nil } // Phase transitions handled by individual views

            // In-game header: rules button + game title + close button (Splash-style)
            if showMenuButton {
                VStack {
                    HStack {
                        Spacer()
                        Text(gameTitle)
                            .font(Theme.calloutFont)
                            .foregroundStyle(.white.opacity(0.8))
                        Spacer()
                    }
                    .overlay(alignment: .leading) {
                        CircleIconButton(
                            systemName: "questionmark",
                            size: 36,
                            bgColor: Color.white.opacity(0.15)
                        ) {
                            showRules = true
                        }
                        .padding(.leading, Theme.padding)
                    }
                    .overlay(alignment: .trailing) {
                        CircleIconButton(
                            systemName: "xmark",
                            size: 36,
                            bgColor: Color.white.opacity(0.15)
                        ) {
                            showMenu = true
                        }
                        .padding(.trailing, Theme.padding)
                    }
                    .padding(.top, 8)
                    Spacer()
                }
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
        .sheet(isPresented: $showMenu) {
            GameMenuView()
        }
    }
}

struct GameMenuView: View {
    @Environment(GameViewModel.self) private var game
    @Environment(LanguageManager.self) private var language
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirmation = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: Theme.sectionSpacing) {
                // Header
                HStack {
                    Text(Strings.menu.title)
                        .font(Theme.titleFont)
                        .foregroundStyle(.white)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(width: 32, height: 32)
                            .background(Theme.cardBgElevated)
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 8)

                if showConfirmation {
                    VStack(spacing: 16) {
                        Text(Strings.menu.endGameQuestion)
                            .font(Theme.headlineFont)
                            .foregroundStyle(.white)

                        Text(Strings.menu.progressLost)
                            .font(Theme.bodyFont)
                            .foregroundStyle(.white.opacity(Theme.textSecondary))
                            .multilineTextAlignment(.center)

                        Button {
                            HapticManager.selection()
                            dismiss()
                            Task {
                                try? await Task.sleep(for: .milliseconds(400))
                                game.exitGame()
                            }
                        } label: {
                            Text(Strings.menu.toMainMenu)
                                .font(Theme.bodyFont)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: Theme.buttonHeight)
                                .background(Theme.accentRed)
                                .clipShape(Capsule())
                        }

                        Button {
                            HapticManager.selection()
                            withAnimation(Theme.springSnappy) {
                                showConfirmation = false
                            }
                        } label: {
                            Text(Strings.common.cancel)
                                .font(Theme.bodyFont)
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(maxWidth: .infinity)
                                .frame(height: Theme.buttonHeight)
                                .background(Theme.cardBgElevated)
                                .clipShape(Capsule())
                        }
                    }
                } else {
                    VStack(spacing: Theme.itemSpacing) {
                        Button {
                            HapticManager.selection()
                            dismiss()
                        } label: {
                            Label(Strings.menu.continueGame, systemImage: "play.fill")
                                .font(Theme.bodyFont)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: Theme.buttonHeight)
                                .background(Theme.cardBg)
                                .clipShape(Capsule())
                        }

                        Button {
                            HapticManager.selection()
                            withAnimation(Theme.springSnappy) {
                                showConfirmation = true
                            }
                        } label: {
                            Label(Strings.menu.backToMain, systemImage: "house.fill")
                                .font(Theme.bodyFont)
                                .foregroundStyle(.white.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .frame(height: Theme.buttonHeight)
                                .background(Theme.cardBgElevated)
                                .clipShape(Capsule())
                        }
                    }
                }

                // Language toggle
                VStack(spacing: 8) {
                    Text(Strings.menu.language)
                        .font(Theme.captionFont)
                        .foregroundStyle(.white.opacity(Theme.textSecondary))

                    HStack(spacing: 10) {
                        ForEach(AppLanguage.allCases, id: \.self) { lang in
                            Button {
                                HapticManager.selection()
                                language.current = lang
                            } label: {
                                HStack(spacing: 6) {
                                    Text(lang.flag)
                                        .font(.system(size: 18))
                                    Text(lang.displayName)
                                        .font(Theme.bodyFont)
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(
                                    language.current == lang
                                        ? Theme.cardBgElevated
                                        : Theme.cardBg
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(
                                            language.current == lang ? .white.opacity(0.3) : .clear,
                                            lineWidth: 1.5
                                        )
                                )
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(.horizontal, Theme.padding)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
