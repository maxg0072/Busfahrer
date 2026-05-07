import Foundation

enum AppLanguage: String, CaseIterable {
    case de = "de"
    case en = "en"

    var displayName: String {
        switch self {
        case .de: return "Deutsch"
        case .en: return "English"
        }
    }

    var flag: String {
        switch self {
        case .de: return "🇩🇪"
        case .en: return "🇬🇧"
        }
    }
}
