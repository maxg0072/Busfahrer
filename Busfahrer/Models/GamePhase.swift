import Foundation

enum GamePhase: Equatable {
    case home
    case start
    case playerSetup

    // MARK: - Busfahrer Phases
    case phase1(round: Int, playerIndex: Int)
    case phase1SipDistribution(round: Int, playerIndex: Int, sipsRemaining: Int)
    case phase1Reveal(round: Int, playerIndex: Int)
    case phaseTransition(to: PhaseTarget)
    case phase2Setup
    case phase2(row: Int, cardIndex: Int)
    case phase2Reveal(row: Int, cardIndex: Int)
    case phase2Discard(row: Int, cardIndex: Int, playerIndex: Int)
    case phase2SipDistribution(row: Int, cardIndex: Int, playerIndex: Int, sipsRemaining: Int)
    case phase2BusDriverReveal
    case phase2Oracle
    case phase3(round: Int, attempt: Int)
    case phase3Reveal(round: Int, attempt: Int)
    case gameEnd

    // MARK: - Pferderennen Phases
    case pferderennenBetting(playerIndex: Int)
    case pferderennenPreDrink(playerIndex: Int)
    case pferderennenRace
    case pferderennenCardReveal
    case pferderennenTrackReveal(trackIndex: Int)
    case pferderennenFinish
    case pferderennenSipDistribution(playerIndex: Int, sipsRemaining: Int)

    // MARK: - Kings Cup Phases
    case kingsCupTurn(playerIndex: Int)
    case kingsCupCardReveal(playerIndex: Int)
    case kingsCupAction(playerIndex: Int)
    case kingsCupDistribute(playerIndex: Int, sipsRemaining: Int)
    case kingsCupPickBuddy(playerIndex: Int)
    case kingsCupGameOver

    // MARK: - F*ck the Dealer Phases
    case ftdGuess1(dealerIndex: Int, guesserIndex: Int)
    case ftdHint(dealerIndex: Int, guesserIndex: Int)
    case ftdGuess2(dealerIndex: Int, guesserIndex: Int)
    case ftdReveal(dealerIndex: Int, guesserIndex: Int)
    case ftdDrink(dealerIndex: Int, guesserIndex: Int)
    case ftdGameOver

    static func == (lhs: GamePhase, rhs: GamePhase) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home): return true
        case (.start, .start): return true
        case (.playerSetup, .playerSetup): return true
        case let (.phase1(r1, p1), .phase1(r2, p2)): return r1 == r2 && p1 == p2
        case let (.phase1SipDistribution(r1, p1, s1), .phase1SipDistribution(r2, p2, s2)):
            return r1 == r2 && p1 == p2 && s1 == s2
        case let (.phase1Reveal(r1, p1), .phase1Reveal(r2, p2)): return r1 == r2 && p1 == p2
        case let (.phaseTransition(t1), .phaseTransition(t2)): return t1 == t2
        case (.phase2Setup, .phase2Setup): return true
        case let (.phase2(r1, c1), .phase2(r2, c2)): return r1 == r2 && c1 == c2
        case let (.phase2Reveal(r1, c1), .phase2Reveal(r2, c2)): return r1 == r2 && c1 == c2
        case let (.phase2Discard(r1, c1, p1), .phase2Discard(r2, c2, p2)):
            return r1 == r2 && c1 == c2 && p1 == p2
        case let (.phase2SipDistribution(r1, c1, p1, s1), .phase2SipDistribution(r2, c2, p2, s2)):
            return r1 == r2 && c1 == c2 && p1 == p2 && s1 == s2
        case (.phase2BusDriverReveal, .phase2BusDriverReveal): return true
        case (.phase2Oracle, .phase2Oracle): return true
        case let (.phase3(r1, a1), .phase3(r2, a2)): return r1 == r2 && a1 == a2
        case let (.phase3Reveal(r1, a1), .phase3Reveal(r2, a2)): return r1 == r2 && a1 == a2
        case (.gameEnd, .gameEnd): return true
        // Pferderennen
        case let (.pferderennenBetting(p1), .pferderennenBetting(p2)): return p1 == p2
        case let (.pferderennenPreDrink(p1), .pferderennenPreDrink(p2)): return p1 == p2
        case (.pferderennenRace, .pferderennenRace): return true
        case (.pferderennenCardReveal, .pferderennenCardReveal): return true
        case let (.pferderennenTrackReveal(t1), .pferderennenTrackReveal(t2)): return t1 == t2
        case (.pferderennenFinish, .pferderennenFinish): return true
        case let (.pferderennenSipDistribution(p1, s1), .pferderennenSipDistribution(p2, s2)):
            return p1 == p2 && s1 == s2
        // Kings Cup
        case let (.kingsCupTurn(p1), .kingsCupTurn(p2)): return p1 == p2
        case let (.kingsCupCardReveal(p1), .kingsCupCardReveal(p2)): return p1 == p2
        case let (.kingsCupAction(p1), .kingsCupAction(p2)): return p1 == p2
        case let (.kingsCupDistribute(p1, s1), .kingsCupDistribute(p2, s2)):
            return p1 == p2 && s1 == s2
        case let (.kingsCupPickBuddy(p1), .kingsCupPickBuddy(p2)): return p1 == p2
        case (.kingsCupGameOver, .kingsCupGameOver): return true
        // FTD
        case let (.ftdGuess1(d1, g1), .ftdGuess1(d2, g2)): return d1 == d2 && g1 == g2
        case let (.ftdHint(d1, g1), .ftdHint(d2, g2)): return d1 == d2 && g1 == g2
        case let (.ftdGuess2(d1, g1), .ftdGuess2(d2, g2)): return d1 == d2 && g1 == g2
        case let (.ftdReveal(d1, g1), .ftdReveal(d2, g2)): return d1 == d2 && g1 == g2
        case let (.ftdDrink(d1, g1), .ftdDrink(d2, g2)): return d1 == d2 && g1 == g2
        case (.ftdGameOver, .ftdGameOver): return true
        default: return false
        }
    }
}

enum PhaseTarget: Equatable {
    case phase1
    case phase2
    case phase3
    case gameEnd
    case pferderennenRace
    case kingsCup
    case fckTheDealer
}
