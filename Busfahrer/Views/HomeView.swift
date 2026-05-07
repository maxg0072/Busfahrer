import SwiftUI

struct HomeView: View {
    @Environment(GameViewModel.self) private var game
    @State private var showSettings = false
    @State private var appear = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    // Game data
    struct GameItem: Identifiable {
        let id = UUID()
        let type: GameType
        let title: String
        let subtitle: String
        let emoji: String
        let imageName: String? // Asset catalog image name (nil = use gradient+emoji)
        let gradientColors: [Color]
        let accentColor: Color
        let isPopular: Bool
    }

    private var games: [GameItem] {
        [
            GameItem(
                type: .busfahrer,
                title: Strings.home.busfahrer,
                subtitle: Strings.home.busfahrerSubtitle,
                emoji: "🚌",
                imageName: "tile_busfahrer",
                gradientColors: [
                    Color(red: 0.29, green: 0.23, blue: 1.0),
                    Color(red: 0.20, green: 0.12, blue: 0.75)
                ],
                accentColor: Theme.busfahrerColor,
                isPopular: true
            ),
            GameItem(
                type: .pferderennen,
                title: Strings.home.pferderennen,
                subtitle: Strings.home.pferderennenSubtitle,
                emoji: "🏇",
                imageName: "tile_pferderennen",
                gradientColors: [
                    Color(red: 0.15, green: 0.60, blue: 0.30),
                    Color(red: 0.08, green: 0.40, blue: 0.18)
                ],
                accentColor: Theme.pferderennenColor,
                isPopular: false
            ),
            GameItem(
                type: .kingsCup,
                title: Strings.home.kingsCup,
                subtitle: Strings.home.kingsCupSubtitle,
                emoji: "👑",
                imageName: "tile_kingscup",
                gradientColors: [
                    Color(red: 0.80, green: 0.18, blue: 0.55),
                    Color(red: 0.55, green: 0.10, blue: 0.40)
                ],
                accentColor: Theme.kingsCupColor,
                isPopular: true
            ),
            GameItem(
                type: .fckTheDealer,
                title: Strings.home.fckTheDealer,
                subtitle: Strings.home.fckTheDealerSubtitle,
                emoji: "🃏",
                imageName: "tile_ftd",
                gradientColors: [
                    Color(red: 0.90, green: 0.40, blue: 0.12),
                    Color(red: 0.70, green: 0.25, blue: 0.08)
                ],
                accentColor: Theme.ftdColor,
                isPopular: false
            ),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Settings gear top-right (Splash-style)
            HStack {
                Spacer()
                Button {
                    HapticManager.selection()
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(width: 48, height: 48)
                        .background(Theme.cardBg)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, Theme.padding)
            .padding(.top, 4)

            // Large bold title (Splash-style)
            HStack {
                Text(Strings.home.title)
                    .font(Theme.largeTitleFont)
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, Theme.padding)
            .padding(.top, 2)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 10)
            .animation(Theme.springSmooth, value: appear)

            // Game grid
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(games.enumerated()), id: \.element.id) { index, item in
                        SplashGameTile(item: item) {
                            HapticManager.selection()
                            withAnimation(Theme.springSnappy) {
                                game.currentGame = item.type
                                game.phase = .start
                            }
                        }
                        .staggeredAppear(index: index, appear: appear, delay: 0.08)
                    }
                }
                .padding(.horizontal, Theme.padding)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            withAnimation(Theme.springSmooth) {
                appear = true
            }
        }
    }
}

// MARK: - Splash-Style Game Tile

struct SplashGameTile: View {
    let item: HomeView.GameItem
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            action()
        } label: {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    // Background: Try asset image, fall back to gradient + emoji
                    if let imageName = item.imageName, UIImage(named: imageName) != nil {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    } else {
                        LinearGradient(
                            colors: item.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )

                        VStack {
                            Spacer().frame(height: 30)
                            Text(item.emoji)
                                .font(.system(size: 65))
                                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                            Spacer()
                        }
                    }

                    // Bottom gradient overlay for text readability
                    VStack {
                        Spacer()
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.75)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 90)
                    }

                    // Title + subtitle at bottom center
                    VStack(spacing: 3) {
                        Text(item.title.uppercased())
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black.opacity(0.6), radius: 4, y: 2)

                        Text(item.subtitle.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(1)
                            .shadow(color: .black.opacity(0.5), radius: 3, y: 1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 12)

                    // "Popular" badge
                    if item.isPopular {
                        VStack {
                            HStack {
                                HStack(spacing: 4) {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.red)
                                    Text("Popular")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundStyle(.black)
                                }
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(.white))
                                .padding(.leading, 8)
                                .padding(.top, 8)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
            }
            .aspectRatio(0.78, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.3),
                                .white.opacity(0.1),
                                .white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: item.accentColor.opacity(0.25), radius: 8, y: 4)
        }
        .buttonStyle(TilePressStyle())
    }
}

// MARK: - Press Animation Style

struct TilePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(Theme.springSnappy, value: configuration.isPressed)
    }
}
