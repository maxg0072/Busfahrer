import Foundation

enum CardStyle: String, CaseIterable {
    case neon
    case cartoon
}

enum Suit: String, CaseIterable, Codable, Identifiable {
    case herz, karo, pik, kreuz

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .herz: return "♥"
        case .karo: return "♦"
        case .pik: return "♠"
        case .kreuz: return "♣"
        }
    }

    var displayName: String {
        Strings.card.suitName(self)
    }

    var isRed: Bool {
        self == .herz || self == .karo
    }
}

enum CardValue: Int, CaseIterable, Codable, Comparable {
    case zwei = 2, drei, vier, fuenf, sechs, sieben, acht, neun, zehn
    case bube = 11, dame = 12, koenig = 13, ass = 14

    static func < (lhs: CardValue, rhs: CardValue) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        Strings.card.valueDisplayName(self)
    }

    var fullName: String {
        Strings.card.valueName(self)
    }
}

struct Card: Identifiable, Equatable, Codable {
    let id: UUID
    let suit: Suit
    let value: CardValue

    init(suit: Suit, value: CardValue) {
        self.id = UUID()
        self.suit = suit
        self.value = value
    }

    var isRed: Bool { suit.isRed }

    var displayName: String {
        "\(value.displayName)\(suit.symbol)"
    }

    var fullDisplayName: String {
        "\(value.fullName) \(suit.displayName)"
    }
}
