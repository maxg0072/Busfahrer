import SwiftUI

@MainActor @Observable
final class LanguageManager {
    static let shared = LanguageManager()

    var current: AppLanguage {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: "appLanguage")
        }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "de"
        self.current = AppLanguage(rawValue: saved) ?? .de
    }
}
