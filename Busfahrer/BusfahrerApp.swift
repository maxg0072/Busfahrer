import SwiftUI

@main
struct BusfahrerApp: App {
    @State private var game = GameViewModel()
    @State private var language = LanguageManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(game)
                .environment(language)
                .preferredColorScheme(.dark)
        }
    }
}
