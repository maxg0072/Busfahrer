import Foundation

enum GuessKey: String, CaseIterable {
    // Round 1: Color
    case red, black
    // Round 2: Higher/Lower
    case higher, lower, equal
    // Round 3: Inside/Outside
    case inside, outside
    // Round 4: Suit
    case hearts, diamonds, spades, clubs

    var displayName: String {
        switch self {
        case .red:      return Strings.guess.red
        case .black:    return Strings.guess.black
        case .higher:   return Strings.guess.higher
        case .lower:    return Strings.guess.lower
        case .equal:    return Strings.guess.equal
        case .inside:   return Strings.guess.inside
        case .outside:  return Strings.guess.outside
        case .hearts:   return Strings.guess.hearts
        case .diamonds: return Strings.guess.diamonds
        case .spades:   return Strings.guess.spades
        case .clubs:    return Strings.guess.clubs
        }
    }
}
