import SwiftUI

@MainActor @Observable
class GameViewModel {
    var deck = Deck()
    var players: [Player] = []
    var phase: GamePhase = .home
    var cardStyle: CardStyle = .neon
    var currentGame: GameType = .busfahrer

    // Phase 2: Pyramid cards
    var pyramidCards: [[Card]] = []
    var pyramidRevealed: [[Bool]] = []

    // Phase 2: Bus driver
    var busDriverIndex: Int? = nil

    // Phase 3: Cards drawn this attempt
    var phase3Cards: [Card] = []
    var phase3TotalAttempts: Int = 0

    // Current card being revealed
    var currentCard: Card? = nil
    var lastGuessCorrect: Bool? = nil

    // Sip distribution state
    var sipDistributionTargetIndex: Int? = nil

    // Phase transition
    var showPhaseTransition: Bool = false

    // Phase 1: Correct answer streak (for streak banner)
    var phase1CorrectStreak: Int = 0

    // MARK: - Player Setup

    func addPlayer(name: String, color: Color) {
        guard players.count < 8 else { return }
        let player = Player(name: name, color: color)
        players.append(player)
    }

    func removePlayer(at index: Int) {
        guard index < players.count else { return }
        players.remove(at: index)
    }

    var canStartGame: Bool {
        players.count >= 2
    }

    // MARK: - Game Start

    func startGame() {
        guard canStartGame else { return }
        deck.reset()
        players.shuffle()
        for player in players {
            player.hand = []
            player.sipsReceived = 0
            player.sipsDistributed = 0
        }
        pyramidCards = []
        pyramidRevealed = []
        busDriverIndex = nil
        phase3Cards = []
        phase3TotalAttempts = 0
        currentCard = nil
        lastGuessCorrect = nil
        phase1CorrectStreak = 0

        phase = .phaseTransition(to: .phase1)
    }

    func beginPhase1() {
        phase = .phase1(round: 1, playerIndex: 0)
    }

    // MARK: - Phase 1: Card Guessing

    var phase1CurrentPlayer: Player? {
        switch phase {
        case .phase1(_, let playerIndex),
             .phase1Reveal(_, let playerIndex),
             .phase1SipDistribution(_, let playerIndex, _):
            guard playerIndex < players.count else { return nil }
            return players[playerIndex]
        default:
            return nil
        }
    }

    func phase1Round() -> Int {
        switch phase {
        case .phase1(let round, _),
             .phase1Reveal(let round, _),
             .phase1SipDistribution(let round, _, _):
            return round
        default:
            return 0
        }
    }

    func phase1Guess(answer: GuessKey) {
        guard case .phase1(let round, let playerIndex) = phase,
              playerIndex < players.count else { return }
        let card = deck.draw()
        currentCard = card
        let player = players[playerIndex]

        let correct: Bool
        switch round {
        case 1:
            correct = answer == .red ? card.isRed : !card.isRed
        case 2:
            guard let firstCard = player.hand.first else { correct = false; break }
            if answer == .equal {
                correct = card.value == firstCard.value
            } else if card.value == firstCard.value {
                correct = false
            } else if answer == .higher {
                correct = card.value > firstCard.value
            } else {
                correct = card.value < firstCard.value
            }
        case 3:
            guard player.hand.count >= 2 else { correct = false; break }
            let v1 = player.hand[0].value.rawValue
            let v2 = player.hand[1].value.rawValue
            let low = min(v1, v2)
            let high = max(v1, v2)
            let cv = card.value.rawValue
            switch answer {
            case .inside:  correct = cv > low && cv < high
            case .outside: correct = cv < low || cv > high
            case .equal:   correct = cv == v1 || cv == v2
            default: correct = false
            }
        case 4:
            switch answer {
            case .hearts:   correct = card.suit == .herz
            case .diamonds: correct = card.suit == .karo
            case .spades:   correct = card.suit == .pik
            case .clubs:    correct = card.suit == .kreuz
            default: correct = false
            }
        default:
            correct = false
        }

        lastGuessCorrect = correct
        player.hand.append(card)

        if correct {
            phase1CorrectStreak += 1
            phase = .phase1Reveal(round: round, playerIndex: playerIndex)
        } else {
            phase1CorrectStreak = 0
            player.sipsReceived += round
            phase = .phase1Reveal(round: round, playerIndex: playerIndex)
        }
    }

    func phase1AfterReveal() {
        guard case .phase1Reveal(let round, let playerIndex) = phase else { return }
        if lastGuessCorrect == true {
            phase = .phase1SipDistribution(round: round, playerIndex: playerIndex, sipsRemaining: round)
        } else {
            advancePhase1(round: round, playerIndex: playerIndex)
        }
    }

    func distributeSip(from distributorIndex: Int, to targetIndex: Int, amount: Int) {
        guard targetIndex < players.count, distributorIndex < players.count else { return }
        players[targetIndex].sipsReceived += amount
        players[distributorIndex].sipsDistributed += amount

        switch phase {
        case .phase1SipDistribution(let round, let playerIndex, let remaining):
            let newRemaining = remaining - amount
            if newRemaining <= 0 {
                advancePhase1(round: round, playerIndex: playerIndex)
            } else {
                phase = .phase1SipDistribution(round: round, playerIndex: playerIndex, sipsRemaining: newRemaining)
            }
        case .phase2SipDistribution(let row, let cardIndex, let playerIndex, let remaining):
            let newRemaining = remaining - amount
            if newRemaining <= 0 {
                // Check if player has more matching cards to discard
                let pyramidCard = pyramidCards[row][cardIndex]
                let player = players[playerIndex]
                if !player.cardsMatching(value: pyramidCard.value).isEmpty {
                    // Ask again if they want to discard another
                    phase = .phase2Discard(row: row, cardIndex: cardIndex, playerIndex: playerIndex)
                } else {
                    advancePhase2Discard(row: row, cardIndex: cardIndex, afterPlayerIndex: playerIndex)
                }
            } else {
                phase = .phase2SipDistribution(row: row, cardIndex: cardIndex, playerIndex: playerIndex, sipsRemaining: newRemaining)
            }
        default:
            break
        }
    }

    private func advancePhase1(round: Int, playerIndex: Int) {
        let nextPlayer = playerIndex + 1
        if nextPlayer < players.count {
            currentCard = nil
            lastGuessCorrect = nil
            phase = .phase1(round: round, playerIndex: nextPlayer)
        } else {
            let nextRound = round + 1
            if nextRound <= 4 {
                currentCard = nil
                lastGuessCorrect = nil
                phase = .phase1(round: nextRound, playerIndex: 0)
            } else {
                currentCard = nil
                lastGuessCorrect = nil
                phase = .phaseTransition(to: .phase2)
            }
        }
    }

    // MARK: - Phase 2: Pyramid

    func setupPyramid() {
        pyramidCards = []
        pyramidRevealed = []
        let rowSizes = [4, 3, 2, 1]
        for size in rowSizes {
            var row: [Card] = []
            for _ in 0..<size {
                row.append(deck.draw())
            }
            pyramidCards.append(row)
            pyramidRevealed.append(Array(repeating: false, count: size))
        }
        phase = .phase2(row: 0, cardIndex: 0)
    }

    func sipsForRow(_ row: Int) -> Int {
        return (row + 1) * 2
    }

    func phase2RevealCard(row: Int, cardIndex: Int) {
        pyramidRevealed[row][cardIndex] = true
        currentCard = pyramidCards[row][cardIndex]
        phase = .phase2Reveal(row: row, cardIndex: cardIndex)
    }

    func phase2AfterReveal() {
        guard case .phase2Reveal(let row, let cardIndex) = phase else { return }
        let card = pyramidCards[row][cardIndex]

        // Find first player with matching cards
        let firstMatchIndex = players.firstIndex { !$0.cardsMatching(value: card.value).isEmpty }
        if let firstMatch = firstMatchIndex {
            phase = .phase2Discard(row: row, cardIndex: cardIndex, playerIndex: firstMatch)
        } else {
            advancePhase2Card(row: row, cardIndex: cardIndex)
        }
    }

    func phase2PlayerDiscard(row: Int, cardIndex: Int, playerIndex: Int, discard: Bool) {
        let player = players[playerIndex]
        let pyramidCard = pyramidCards[row][cardIndex]

        if discard {
            if let card = player.cardsMatching(value: pyramidCard.value).first {
                player.removeCard(card)
                deck.discard(card)
                let sips = sipsForRow(row)
                phase = .phase2SipDistribution(row: row, cardIndex: cardIndex, playerIndex: playerIndex, sipsRemaining: sips)
                return
            }
        }

        advancePhase2Discard(row: row, cardIndex: cardIndex, afterPlayerIndex: playerIndex)
    }

    func phase2PlayerDiscardAnother(row: Int, cardIndex: Int, playerIndex: Int) {
        let player = players[playerIndex]
        let pyramidCard = pyramidCards[row][cardIndex]
        if !player.cardsMatching(value: pyramidCard.value).isEmpty {
            phase = .phase2Discard(row: row, cardIndex: cardIndex, playerIndex: playerIndex)
        } else {
            advancePhase2Discard(row: row, cardIndex: cardIndex, afterPlayerIndex: playerIndex)
        }
    }

    private func advancePhase2Discard(row: Int, cardIndex: Int, afterPlayerIndex: Int) {
        let pyramidCard = pyramidCards[row][cardIndex]
        // Find next player with matching cards
        let remaining = players[(afterPlayerIndex + 1)...]
        if let nextMatch = remaining.firstIndex(where: { !$0.cardsMatching(value: pyramidCard.value).isEmpty }) {
            phase = .phase2Discard(row: row, cardIndex: cardIndex, playerIndex: nextMatch)
        } else {
            advancePhase2Card(row: row, cardIndex: cardIndex)
        }
    }

    private func advancePhase2Card(row: Int, cardIndex: Int) {
        currentCard = nil
        // Find next unrevealed card in current row
        if let nextUnrevealed = pyramidRevealed[row].firstIndex(where: { !$0 }) {
            phase = .phase2(row: row, cardIndex: nextUnrevealed)
        } else {
            // All cards in this row revealed, advance to next row
            let nextRow = row + 1
            if nextRow < pyramidCards.count {
                phase = .phase2(row: nextRow, cardIndex: 0)
            } else {
                determineBusDriver()
            }
        }
    }

    private func determineBusDriver() {
        let maxCards = players.map { $0.cardCount }.max() ?? 0
        let candidates = players.enumerated().filter { $0.element.cardCount == maxCards }

        if candidates.count == 1 {
            busDriverIndex = candidates[0].offset
            phase = .phase2BusDriverReveal
        } else {
            // Tiebreaker needed
            busDriverIndex = candidates.randomElement()?.offset ?? 0
            phase = .phase2Oracle
        }
    }

    func startPhase3() {
        guard let busDriverIdx = busDriverIndex else { return }
        // Discard all player hands
        for player in players {
            deck.discard(player.hand)
            player.hand = []
        }
        // Discard pyramid cards
        for row in pyramidCards {
            deck.discard(row)
        }
        phase3Cards = []
        phase3TotalAttempts = 0
        _ = busDriverIdx // used via busDriverIndex
        phase = .phase3(round: 1, attempt: 1)
    }

    // MARK: - Phase 3: Bus Driving

    var busDriver: Player? {
        guard let idx = busDriverIndex, idx < players.count else { return nil }
        return players[idx]
    }

    func phase3Guess(answer: GuessKey) {
        guard case .phase3(let round, let attempt) = phase else { return }
        let card = deck.draw()
        currentCard = card
        phase3Cards.append(card)

        let correct: Bool
        switch round {
        case 1:
            correct = answer == .red ? card.isRed : !card.isRed
        case 2:
            guard phase3Cards.count >= 1 else { correct = false; break }
            let firstCard = phase3Cards[0]
            if answer == .equal {
                correct = card.value == firstCard.value
            } else if card.value == firstCard.value {
                correct = false
            } else if answer == .higher {
                correct = card.value > firstCard.value
            } else {
                correct = card.value < firstCard.value
            }
        case 3:
            guard phase3Cards.count >= 2 else { correct = false; break }
            let v1 = phase3Cards[0].value.rawValue
            let v2 = phase3Cards[1].value.rawValue
            let low = min(v1, v2)
            let high = max(v1, v2)
            let cv = card.value.rawValue
            switch answer {
            case .inside:  correct = cv > low && cv < high
            case .outside: correct = cv < low || cv > high
            case .equal:   correct = cv == v1 || cv == v2
            default: correct = false
            }
        case 4:
            switch answer {
            case .hearts:   correct = card.suit == .herz
            case .diamonds: correct = card.suit == .karo
            case .spades:   correct = card.suit == .pik
            case .clubs:    correct = card.suit == .kreuz
            default: correct = false
            }
        default:
            correct = false
        }

        lastGuessCorrect = correct
        phase = .phase3Reveal(round: round, attempt: attempt)
    }

    func phase3AfterReveal() {
        guard case .phase3Reveal(let round, let attempt) = phase else { return }
        guard let driver = busDriver else { return }

        if lastGuessCorrect == true {
            if round >= 4 {
                phase = .phaseTransition(to: .gameEnd)
            } else {
                currentCard = nil
                lastGuessCorrect = nil
                phase = .phase3(round: round + 1, attempt: attempt)
            }
        } else {
            driver.sipsReceived += round
            // Discard cards from this attempt
            deck.discard(phase3Cards)
            phase3Cards = []
            currentCard = nil
            lastGuessCorrect = nil
            phase3TotalAttempts += 1
            phase = .phase3(round: 1, attempt: attempt + 1)
        }
    }

    // MARK: - Game End

    func newGameSamePlayers() {
        for player in players {
            player.hand = []
            player.sipsReceived = 0
            player.sipsDistributed = 0
        }
        deck.reset()
        pyramidCards = []
        pyramidRevealed = []
        busDriverIndex = nil
        phase3Cards = []
        phase3TotalAttempts = 0
        currentCard = nil
        lastGuessCorrect = nil
        phase = .phaseTransition(to: .phase1)
    }

    func newGameNewPlayers() {
        // Set phase FIRST to switch view before clearing arrays
        phase = .playerSetup
        players = []
        deck.reset()
        pyramidCards = []
        pyramidRevealed = []
        busDriverIndex = nil
        phase3Cards = []
        phase3TotalAttempts = 0
        currentCard = nil
        lastGuessCorrect = nil
    }

    func exitGame() {
        // IMPORTANT: Set phase FIRST so SwiftUI switches to HomeView
        // before we clear any arrays (prevents index-out-of-bounds crashes)
        phase = .home

        // Reset Pferderennen state
        horsePositions = [0, 0, 0, 0]
        horseMaxPositions = [0, 0, 0, 0]
        trackCards = []
        trackRevealed = [false, false, false, false, false, false, false]
        playerBets = [:]
        raceCurrentCard = nil
        winningSuitIndex = nil
        raceCardsDrawn = 0

        // Reset FTD state
        ftdDealerIndex = 0
        ftdCurrentCard = nil
        ftdGuess1Value = nil
        ftdGuess2Value = nil
        ftdCorrectOnGuess = nil
        ftdConsecutiveWrong = 0
        ftdDiscardedValues = []
        ftdCardsPlayed = 0

        // Reset Kings Cup state
        kingsCupKingsDrawn = 0
        kingsCupCurrentCard = nil
        kingsCupThumbKingIndex = nil
        kingsCupQuestionQueenIndex = nil
        kingsCupBuddyPairs = []
        kingsCupCardsDrawn = 0

        // Reset Busfahrer state
        pyramidCards = []
        pyramidRevealed = []
        busDriverIndex = nil
        phase3Cards = []
        phase3TotalAttempts = 0
        currentCard = nil
        lastGuessCorrect = nil

        // Reset common state last
        players = []
        deck.reset()
    }

    // MARK: - Helper

    func playerIndex(for player: Player) -> Int? {
        players.firstIndex { $0.id == player.id }
    }

    // MARK: - Pferderennen (Horse Race)

    /// Horse positions: index 0-3 for suits herz, karo, pik, kreuz
    var horsePositions: [Int] = [0, 0, 0, 0]
    /// Maximum position each horse has ever reached (for track card reveal logic)
    var horseMaxPositions: [Int] = [0, 0, 0, 0]
    /// 7 track cards (face-down obstacles)
    var trackCards: [Card] = []
    var trackRevealed: [Bool] = [false, false, false, false, false, false, false]
    /// Player bets: [playerIndex: (suitIndex, sipAmount)]
    var playerBets: [Int: (suitIndex: Int, sips: Int)] = [:]
    /// Current drawn card during race
    var raceCurrentCard: Card? = nil
    /// Winning suit index (0-3)
    var winningSuitIndex: Int? = nil
    /// Total cards drawn in race
    var raceCardsDrawn: Int = 0
    /// The finish line position (past 7th track card = position 8+)
    let finishLine: Int = 8

    private let horseSuits: [Suit] = [.herz, .karo, .pik, .kreuz]

    func horseSuit(at index: Int) -> Suit {
        horseSuits[index]
    }

    func suitIndex(for suit: Suit) -> Int {
        switch suit {
        case .herz: return 0
        case .karo: return 1
        case .pik: return 2
        case .kreuz: return 3
        }
    }

    func startPferderennen() {
        guard canStartGame else { return }
        deck.reset()
        players.shuffle()
        for player in players {
            player.hand = []
            player.sipsReceived = 0
            player.sipsDistributed = 0
        }
        horsePositions = [0, 0, 0, 0]
        horseMaxPositions = [0, 0, 0, 0]
        trackCards = []
        trackRevealed = [false, false, false, false, false, false, false]
        playerBets = [:]
        raceCurrentCard = nil
        winningSuitIndex = nil
        raceCardsDrawn = 0

        // Deal 7 track cards
        for _ in 0..<7 {
            trackCards.append(deck.draw())
        }

        phase = .pferderennenBetting(playerIndex: 0)
    }

    func pferderennenPlaceBet(playerIndex: Int, suitIndex: Int, sips: Int) {
        guard playerIndex < players.count else { return }
        playerBets[playerIndex] = (suitIndex: suitIndex, sips: sips)
        players[playerIndex].sipsReceived += sips // They drink their bet
        phase = .pferderennenPreDrink(playerIndex: playerIndex)
    }

    func pferderennenAfterDrink() {
        guard case .pferderennenPreDrink(let playerIndex) = phase else { return }
        let nextPlayer = playerIndex + 1
        if nextPlayer < players.count {
            phase = .pferderennenBetting(playerIndex: nextPlayer)
        } else {
            // All bets placed, start race
            phase = .phaseTransition(to: .pferderennenRace)
        }
    }

    func pferderennenStartRace() {
        phase = .pferderennenRace
    }

    func pferderennenDrawCard() {
        guard case .pferderennenRace = phase else { return }
        let card = deck.draw()
        raceCurrentCard = card
        raceCardsDrawn += 1

        // Advance the matching horse
        let idx = suitIndex(for: card.suit)
        horsePositions[idx] += 1
        horseMaxPositions[idx] = max(horseMaxPositions[idx], horsePositions[idx])

        // Check for win
        if horsePositions[idx] >= finishLine {
            winningSuitIndex = idx
            phase = .pferderennenCardReveal
            return
        }

        // Check if a track card should be revealed
        // Track cards are at positions 1-7. When ALL horses have passed position N,
        // the Nth track card (index N-1) is revealed
        checkTrackCards()

        phase = .pferderennenCardReveal
    }

    func pferderennenAfterCardReveal() {
        guard case .pferderennenCardReveal = phase else { return }

        if winningSuitIndex != nil {
            // Race over!
            phase = .pferderennenFinish
        } else {
            raceCurrentCard = nil
            phase = .pferderennenRace
        }
    }

    private func checkTrackCards() {
        for i in 0..<7 {
            let trackPosition = i + 1
            if !trackRevealed[i] {
                // Check if all horses have EVER reached this position
                // (uses max positions so a horse that was pushed back still counts)
                let allPassed = horseMaxPositions.allSatisfy { $0 >= trackPosition }
                if allPassed {
                    trackRevealed[i] = true
                    // The horse matching this track card's suit goes back 1
                    let trackSuit = trackCards[i].suit
                    let sIdx = suitIndex(for: trackSuit)
                    horsePositions[sIdx] = max(0, horsePositions[sIdx] - 1)

                    // If this caused the horse to go below the finish line after winning
                    if winningSuitIndex == sIdx && horsePositions[sIdx] < finishLine {
                        winningSuitIndex = nil
                    }
                }
            }
        }
    }

    func pferderennenAfterTrackReveal() {
        guard case .pferderennenTrackReveal = phase else { return }
        // Continue race
        raceCurrentCard = nil
        phase = .pferderennenRace
    }

    /// Get winners (players who bet on winning suit)
    var pferderennenWinners: [(playerIndex: Int, sips: Int)] {
        guard let winIdx = winningSuitIndex, !players.isEmpty else { return [] }
        return playerBets.compactMap { (pIdx, bet) in
            guard pIdx < players.count else { return nil }
            return bet.suitIndex == winIdx ? (playerIndex: pIdx, sips: bet.sips * 2) : nil
        }
    }

    /// Get losers (players who didn't bet on winning suit)
    var pferderennenLosers: [(playerIndex: Int, sips: Int)] {
        guard let winIdx = winningSuitIndex, !players.isEmpty else { return [] }
        return playerBets.compactMap { (pIdx, bet) in
            guard pIdx < players.count else { return nil }
            return bet.suitIndex != winIdx ? (playerIndex: pIdx, sips: bet.sips) : nil
        }
    }

    func pferderennenStartSipDistribution() {
        let winners = pferderennenWinners
        if let first = winners.first {
            phase = .pferderennenSipDistribution(playerIndex: first.playerIndex, sipsRemaining: first.sips)
        } else {
            // No winners — everyone lost. Go to game end
            phase = .gameEnd
        }
    }

    func pferderennenDistributeSip(from distributorIndex: Int, to targetIndex: Int, amount: Int) {
        guard targetIndex < players.count, distributorIndex < players.count else { return }
        players[targetIndex].sipsReceived += amount
        players[distributorIndex].sipsDistributed += amount

        guard case .pferderennenSipDistribution(let playerIndex, let remaining) = phase else { return }
        let newRemaining = remaining - amount
        if newRemaining <= 0 {
            // Check if there are more winners to distribute
            let winners = pferderennenWinners
            if let currentWinnerIdx = winners.firstIndex(where: { $0.playerIndex == playerIndex }) {
                let nextIdx = winners.index(after: currentWinnerIdx)
                if nextIdx < winners.endIndex {
                    let next = winners[nextIdx]
                    phase = .pferderennenSipDistribution(playerIndex: next.playerIndex, sipsRemaining: next.sips)
                    return
                }
            }
            // All distributions done
            phase = .gameEnd
        } else {
            phase = .pferderennenSipDistribution(playerIndex: playerIndex, sipsRemaining: newRemaining)
        }
    }

    func pferderennenNewRace() {
        startPferderennen()
    }

    // MARK: - Kings Cup

    var kingsCupKingsDrawn: Int = 0
    var kingsCupCurrentCard: Card? = nil
    var kingsCupThumbKingIndex: Int? = nil
    var kingsCupQuestionQueenIndex: Int? = nil
    var kingsCupBuddyPairs: [(Int, Int)] = [] // pairs of drinking buddy indices
    var kingsCupCardsDrawn: Int = 0

    func startKingsCup() {
        guard canStartGame else { return }
        deck.reset()
        players.shuffle()
        for player in players {
            player.hand = []
            player.sipsReceived = 0
            player.sipsDistributed = 0
        }
        kingsCupKingsDrawn = 0
        kingsCupCurrentCard = nil
        kingsCupThumbKingIndex = nil
        kingsCupQuestionQueenIndex = nil
        kingsCupBuddyPairs = []
        kingsCupCardsDrawn = 0
        phase = .phaseTransition(to: .kingsCup)
    }

    func kingsCupBeginGame() {
        phase = .kingsCupTurn(playerIndex: 0)
    }

    func kingsCupDrawCard(playerIndex: Int) {
        guard playerIndex < players.count else { return }
        let card = deck.draw()
        kingsCupCurrentCard = card
        kingsCupCardsDrawn += 1
        phase = .kingsCupCardReveal(playerIndex: playerIndex)
    }

    func kingsCupProceedToAction(playerIndex: Int) {
        guard let card = kingsCupCurrentCard else {
            kingsCupAdvanceTurn(playerIndex: playerIndex)
            return
        }

        switch card.value {
        case .zwei:
            // Distribute 2 sips
            phase = .kingsCupDistribute(playerIndex: playerIndex, sipsRemaining: 2)
        case .drei:
            // Drink 3 yourself
            if playerIndex < players.count {
                players[playerIndex].sipsReceived += 3
            }
            phase = .kingsCupAction(playerIndex: playerIndex)
        case .sieben:
            // Thumb King
            kingsCupThumbKingIndex = playerIndex
            phase = .kingsCupAction(playerIndex: playerIndex)
        case .acht:
            // Pick drinking buddy
            phase = .kingsCupPickBuddy(playerIndex: playerIndex)
        case .dame:
            // Question Queen
            kingsCupQuestionQueenIndex = playerIndex
            phase = .kingsCupAction(playerIndex: playerIndex)
        case .koenig:
            // Kings Cup!
            kingsCupKingsDrawn += 1
            if kingsCupKingsDrawn >= 4 {
                // 4th King = drink the cup, game over
                if playerIndex < players.count {
                    players[playerIndex].sipsReceived += 10 // symbolic "Kings Cup"
                }
                phase = .kingsCupGameOver
                return
            }
            phase = .kingsCupAction(playerIndex: playerIndex)
        default:
            // 4,5,6,9,10,J,A = display-only actions
            phase = .kingsCupAction(playerIndex: playerIndex)
        }
    }

    func kingsCupSelectBuddy(playerIndex: Int, buddyIndex: Int) {
        guard playerIndex < players.count, buddyIndex < players.count else { return }
        // Remove old pairs involving this player
        kingsCupBuddyPairs.removeAll { $0.0 == playerIndex || $0.1 == playerIndex }
        kingsCupBuddyPairs.append((playerIndex, buddyIndex))
        phase = .kingsCupAction(playerIndex: playerIndex)
    }

    func kingsCupDistributeSip(from distributorIndex: Int, to targetIndex: Int, amount: Int) {
        guard targetIndex < players.count, distributorIndex < players.count else { return }
        players[targetIndex].sipsReceived += amount
        players[distributorIndex].sipsDistributed += amount

        guard case .kingsCupDistribute(let playerIndex, let remaining) = phase else { return }
        let newRemaining = remaining - amount
        if newRemaining <= 0 {
            kingsCupAdvanceTurn(playerIndex: playerIndex)
        } else {
            phase = .kingsCupDistribute(playerIndex: playerIndex, sipsRemaining: newRemaining)
        }
    }

    func kingsCupAfterAction(playerIndex: Int) {
        kingsCupAdvanceTurn(playerIndex: playerIndex)
    }

    private func kingsCupAdvanceTurn(playerIndex: Int) {
        kingsCupCurrentCard = nil
        // Check if deck is empty
        if deck.remainingCount <= 0 {
            phase = .gameEnd
            return
        }
        let nextPlayer = (playerIndex + 1) % players.count
        phase = .kingsCupTurn(playerIndex: nextPlayer)
    }

    // MARK: - F*ck the Dealer

    var ftdDealerIndex: Int = 0
    var ftdCurrentCard: Card? = nil
    var ftdGuess1Value: Int? = nil
    var ftdGuess2Value: Int? = nil
    var ftdCorrectOnGuess: Int? = nil   // 1 or 2 if correct, nil if wrong
    var ftdConsecutiveWrong: Int = 0     // 3 = dealer changes
    var ftdDiscardedValues: [Int] = []   // track revealed card values
    var ftdCardsPlayed: Int = 0

    func startFckTheDealer() {
        guard canStartGame else { return }
        deck.reset()
        players.shuffle()
        for player in players {
            player.hand = []
            player.sipsReceived = 0
            player.sipsDistributed = 0
        }
        ftdDealerIndex = 0
        ftdCurrentCard = nil
        ftdGuess1Value = nil
        ftdGuess2Value = nil
        ftdCorrectOnGuess = nil
        ftdConsecutiveWrong = 0
        ftdDiscardedValues = []
        ftdCardsPlayed = 0
        phase = .phaseTransition(to: .fckTheDealer)
    }

    func ftdBeginGame() {
        let guesserIndex = (ftdDealerIndex + 1) % players.count
        // Dealer draws a hidden card
        ftdCurrentCard = deck.draw()
        ftdGuess1Value = nil
        ftdGuess2Value = nil
        ftdCorrectOnGuess = nil
        phase = .ftdGuess1(dealerIndex: ftdDealerIndex, guesserIndex: guesserIndex)
    }

    func ftdMakeGuess1(value: Int) {
        guard case .ftdGuess1(let dealerIdx, let guesserIdx) = phase,
              let card = ftdCurrentCard else { return }

        ftdGuess1Value = value

        if value == card.value.rawValue {
            // Correct on first guess! Dealer drinks 4
            ftdCorrectOnGuess = 1
            if dealerIdx < players.count { players[dealerIdx].sipsReceived += 4 }
            if guesserIdx < players.count { players[guesserIdx].sipsDistributed += 4 }
            ftdConsecutiveWrong = 0
            phase = .ftdReveal(dealerIndex: dealerIdx, guesserIndex: guesserIdx)
        } else {
            // Wrong — give hint higher/lower
            phase = .ftdHint(dealerIndex: dealerIdx, guesserIndex: guesserIdx)
        }
    }

    var ftdHintIsHigher: Bool {
        guard let card = ftdCurrentCard, let guess = ftdGuess1Value else { return true }
        return card.value.rawValue > guess
    }

    func ftdMakeGuess2(value: Int) {
        guard case .ftdGuess2(let dealerIdx, let guesserIdx) = phase,
              let card = ftdCurrentCard else { return }

        ftdGuess2Value = value

        if value == card.value.rawValue {
            // Correct on second guess! Dealer drinks 2
            ftdCorrectOnGuess = 2
            if dealerIdx < players.count { players[dealerIdx].sipsReceived += 2 }
            if guesserIdx < players.count { players[guesserIdx].sipsDistributed += 2 }
            ftdConsecutiveWrong = 0
        } else {
            // Wrong both times — guesser drinks the difference
            ftdCorrectOnGuess = nil
            let diff = abs(value - card.value.rawValue)
            if guesserIdx < players.count { players[guesserIdx].sipsReceived += diff }
            ftdConsecutiveWrong += 1
        }
        phase = .ftdReveal(dealerIndex: dealerIdx, guesserIndex: guesserIdx)
    }

    func ftdProceedFromHint() {
        guard case .ftdHint(let dealerIdx, let guesserIdx) = phase else { return }
        phase = .ftdGuess2(dealerIndex: dealerIdx, guesserIndex: guesserIdx)
    }

    func ftdAfterReveal() {
        guard case .ftdReveal(let dealerIdx, let guesserIdx) = phase else { return }

        // Add card value to discards
        if let card = ftdCurrentCard {
            ftdDiscardedValues.append(card.value.rawValue)
            ftdCardsPlayed += 1
        }

        // Check if deck is empty
        if deck.remainingCount <= 0 {
            phase = .ftdGameOver
            return
        }

        // Check if dealer changes (3 consecutive wrong)
        var newDealerIdx = dealerIdx
        if ftdConsecutiveWrong >= 3 {
            ftdConsecutiveWrong = 0
            newDealerIdx = (dealerIdx + 1) % players.count
            ftdDealerIndex = newDealerIdx
        }

        // Next guesser (skip the dealer)
        var nextGuesser = (guesserIdx + 1) % players.count
        if nextGuesser == newDealerIdx {
            nextGuesser = (nextGuesser + 1) % players.count
        }

        // Draw new card for dealer
        ftdCurrentCard = deck.draw()
        ftdGuess1Value = nil
        ftdGuess2Value = nil
        ftdCorrectOnGuess = nil

        phase = .ftdGuess1(dealerIndex: newDealerIdx, guesserIndex: nextGuesser)
    }
}
