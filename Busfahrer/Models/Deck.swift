import Foundation
import Observation

@MainActor @Observable
class Deck {
    var drawPile: [Card] = []
    var discardPile: [Card] = []

    init() {
        reset()
    }

    func reset() {
        drawPile = []
        discardPile = []
        for suit in Suit.allCases {
            for value in CardValue.allCases {
                drawPile.append(Card(suit: suit, value: value))
            }
        }
        drawPile.shuffle()
    }

    func draw() -> Card {
        if drawPile.isEmpty {
            drawPile = discardPile.shuffled()
            discardPile = []
        }
        return drawPile.removeLast()
    }

    func discard(_ cards: [Card]) {
        discardPile.append(contentsOf: cards)
    }

    func discard(_ card: Card) {
        discardPile.append(card)
    }

    var remainingCount: Int { drawPile.count }
}
