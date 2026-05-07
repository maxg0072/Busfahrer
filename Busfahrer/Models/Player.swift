import SwiftUI

@MainActor @Observable
class Player: Identifiable {
    let id: UUID
    var name: String
    var color: Color
    var hand: [Card]
    var sipsReceived: Int
    var sipsDistributed: Int

    init(name: String, color: Color) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.hand = []
        self.sipsReceived = 0
        self.sipsDistributed = 0
    }

    var cardCount: Int { hand.count }

    func cardsMatching(value: CardValue) -> [Card] {
        hand.filter { $0.value == value }
    }

    func removeCard(_ card: Card) {
        hand.removeAll { $0.id == card.id }
    }
}
