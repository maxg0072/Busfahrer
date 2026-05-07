import Foundation

// swiftlint:disable type_name nesting

enum Strings {
    private static var lang: AppLanguage { LanguageManager.shared.current }

    // MARK: - Common

    enum common {
        static var continueButton: String {
            lang == .de ? "Weiter" : "Continue"
        }
        static var back: String {
            lang == .de ? "Zurück" : "Back"
        }
        static var cancel: String {
            lang == .de ? "Abbrechen" : "Cancel"
        }
        static var correct: String {
            lang == .de ? "Richtig!" : "Correct!"
        }
        static var wrong: String {
            lang == .de ? "Falsch!" : "Wrong!"
        }
        static var no: String {
            lang == .de ? "Nein" : "No"
        }
        static func cardsCount(_ n: Int) -> String {
            lang == .de ? "\(n) Karten" : "\(n) cards"
        }
    }

    // MARK: - Sips

    enum sips {
        static func word(_ n: Int) -> String {
            if lang == .de { return n == 1 ? "Schluck" : "Schlücke" }
            return n == 1 ? "sip" : "sips"
        }
        static func count(_ n: Int) -> String {
            "\(n) \(word(n))"
        }
        static func canDistribute(_ name: String, _ n: Int) -> String {
            if lang == .de { return "\(name) darf \(n) \(word(n)) verteilen!" }
            return "\(name) can distribute \(n) \(word(n))!"
        }
        static func mustDrink(_ name: String, _ n: Int) -> String {
            if lang == .de { return "\(name) trinkt \(n) \(word(n))!" }
            return "\(name) drinks \(n) \(word(n))!"
        }
        static func drinksCount(_ n: Int) -> String {
            if lang == .de { return "trinkt \(n) \(word(n))!" }
            return "drinks \(n) \(word(n))!"
        }
        static func distributes(_ name: String, _ n: Int) -> String {
            if lang == .de { return "verteilt \(n) \(word(n))" }
            return "distributes \(n) \(word(n))"
        }
        static func from(_ name: String) -> String {
            lang == .de ? "von \(name)" : "from \(name)"
        }
        static var toWhom: String {
            lang == .de ? "An wen?" : "To whom?"
        }
        static func howManyFor(_ name: String) -> String {
            if lang == .de { return "Wie viele Schlücke für \(name)?" }
            return "How many sips for \(name)?"
        }
    }

    // MARK: - Guess (Questions & Answers)

    enum guess {
        static var red: String { lang == .de ? "Rot" : "Red" }
        static var black: String { lang == .de ? "Schwarz" : "Black" }
        static var higher: String { lang == .de ? "Höher" : "Higher" }
        static var lower: String { lang == .de ? "Tiefer" : "Lower" }
        static var equal: String { lang == .de ? "Gleich" : "Equal" }
        static var inside: String { lang == .de ? "Innerhalb" : "Inside" }
        static var outside: String { lang == .de ? "Außerhalb" : "Outside" }
        static var hearts: String { lang == .de ? "Herz ♥" : "Hearts ♥" }
        static var diamonds: String { lang == .de ? "Karo ♦" : "Diamonds ♦" }
        static var spades: String { lang == .de ? "Pik ♠" : "Spades ♠" }
        static var clubs: String { lang == .de ? "Kreuz ♣" : "Clubs ♣" }

        static var questionRound1: String {
            lang == .de ? "Welche Farbe hat die Karte?" : "What color is the card?"
        }
        static var questionRound2: String {
            lang == .de ? "Höher, Tiefer oder Gleich?" : "Higher, Lower or Equal?"
        }
        static var questionRound3: String {
            lang == .de ? "Innerhalb, Außerhalb oder Gleich?" : "Inside, Outside or Equal?"
        }
        static var questionRound4: String {
            lang == .de ? "Welches Symbol hat die Karte?" : "What suit is the card?"
        }
    }

    // MARK: - Game Detail Screen

    enum detail {
        static var players: String {
            lang == .de ? "Spieler" : "Players"
        }
        static var cardStyle: String {
            lang == .de ? "Kartenstil" : "Card Style"
        }
        static var neonStyle: String {
            "Neon"
        }
        static var cartoonStyle: String {
            "Cartoon"
        }
        static var startGame: String {
            lang == .de ? "Spiel starten" : "Start Game"
        }
        static var flavorText: String {
            lang == .de ? "Wer wird heute Busfahrer?\nMacht euch bereit." : "Who will be the bus driver today?\nPrepare yourselves."
        }
    }

    // MARK: - Home Screen

    enum home {
        static var title: String {
            lang == .de ? "Trinkspiele" : "Drinking Games"
        }
        static var comingSoon: String {
            lang == .de ? "Bald verfügbar" : "Coming Soon"
        }
        static var busfahrer: String {
            "Busfahrer"
        }
        static var busfahrerSubtitle: String {
            lang == .de ? "Das Kartenspiel" : "The Card Game"
        }
        static var pferderennen: String {
            lang == .de ? "Pferderennen" : "Horse Race"
        }
        static var pferderennenSubtitle: String {
            lang == .de ? "Das Wettspiel" : "The Betting Game"
        }
        static var kingsCup: String {
            "Kings Cup"
        }
        static var kingsCupSubtitle: String {
            "Circle of Death"
        }
        static var fckTheDealer: String {
            "F*ck the Dealer"
        }
        static var fckTheDealerSubtitle: String {
            lang == .de ? "Das Ratespiel" : "The Guessing Game"
        }
    }

    // MARK: - Start Screen

    enum start {
        static var subtitle: String {
            lang == .de ? "Das Trinkspiel" : "The Drinking Game"
        }
        static var newGame: String {
            lang == .de ? "Neues Spiel starten" : "Start New Game"
        }
        static var rules: String {
            lang == .de ? "Regeln" : "Rules"
        }
    }

    // MARK: - Player Setup

    enum playerSetup {
        static var title: String {
            lang == .de ? "Spieler hinzufügen" : "Add Players"
        }
        static func playerCount(_ n: Int) -> String {
            lang == .de ? "\(n)/8 Spieler" : "\(n)/8 Players"
        }
        static var namePlaceholder: String {
            lang == .de ? "Name eingeben" : "Enter name"
        }
        static var minPlayers: String {
            lang == .de ? "Mindestens 2 Spieler benötigt" : "At least 2 players required"
        }
        static var startGame: String {
            lang == .de ? "Spiel starten" : "Start Game"
        }
    }

    // MARK: - Rules

    enum rules {
        static var title: String {
            lang == .de ? "Spielregeln" : "Game Rules"
        }
        static var phase1Title: String {
            lang == .de ? "Phase 1 – Kartenraten" : "Phase 1 – Card Guessing"
        }
        static var phase1Text: String {
            if lang == .de {
                return """
                Jeder Spieler beantwortet 4 Fragen und erhält pro Runde eine Karte:

                Runde 1: Rot oder Schwarz? (1 Schluck)
                Runde 2: Höher oder Tiefer? (2 Schlücke)
                Runde 3: Innerhalb, Außerhalb oder Gleich? (3 Schlücke)
                Runde 4: Welches Symbol? (4 Schlücke)

                Richtig = Schlücke verteilen
                Falsch = Schlücke selbst trinken
                """
            }
            return """
            Each player answers 4 questions and receives a card per round:

            Round 1: Red or Black? (1 sip)
            Round 2: Higher or Lower? (2 sips)
            Round 3: Inside, Outside or Equal? (3 sips)
            Round 4: Which suit? (4 sips)

            Correct = distribute sips
            Wrong = drink sips yourself
            """
        }
        static var phase2Title: String {
            lang == .de ? "Phase 2 – Die Pyramide" : "Phase 2 – The Pyramid"
        }
        static var phase2Text: String {
            if lang == .de {
                return """
                Eine Pyramide aus 10 verdeckten Karten wird aufgebaut (4-3-2-1).

                Karten werden von unten nach oben aufgedeckt. Wenn eine Karte aufgedeckt wird, können Spieler passende Karten aus ihrer Hand ablegen und Schlücke verteilen.

                Reihe 1: 2 Schlücke | Reihe 2: 4 Schlücke
                Reihe 3: 6 Schlücke | Reihe 4: 8 Schlücke

                Der Spieler mit den meisten verbleibenden Karten wird zum Busfahrer!
                """
            }
            return """
            A pyramid of 10 face-down cards is built (4-3-2-1).

            Cards are revealed from bottom to top. When a card is revealed, players can discard matching cards from their hand and distribute sips.

            Row 1: 2 sips | Row 2: 4 sips
            Row 3: 6 sips | Row 4: 8 sips

            The player with the most remaining cards becomes the bus driver!
            """
        }
        static var phase3Title: String {
            lang == .de ? "Phase 3 – Busfahren" : "Phase 3 – Bus Ride"
        }
        static var phase3Text: String {
            if lang == .de {
                return """
                Der Busfahrer muss die 4 Runden aus Phase 1 fehlerfrei hintereinander durchspielen.

                Bei jedem Fehler: Zurück auf Runde 1 + Schlücke trinken!

                Das Spiel endet, wenn alle 4 Runden am Stück richtig beantwortet werden.
                """
            }
            return """
            The bus driver must complete the 4 rounds from Phase 1 without any mistakes in a row.

            On every mistake: Back to round 1 + drink sips!

            The game ends when all 4 rounds are answered correctly in a row.
            """
        }
    }

    // MARK: - Phase 1

    enum phase1 {
        static var header: String {
            lang == .de ? "Phase 1 – Kartenraten" : "Phase 1 – Card Guessing"
        }
    }

    // MARK: - Phase 2

    enum phase2 {
        static var header: String {
            lang == .de ? "Phase 2 – Die Pyramide" : "Phase 2 – The Pyramid"
        }
        static var tapCard: String {
            lang == .de ? "Tippe auf eine Karte" : "Tap a card"
        }
        static func rowSips(_ row: Int, _ sipCount: Int) -> String {
            if lang == .de { return "Reihe \(row) – \(sipCount) Schlücke" }
            return "Row \(row) – \(sipCount) sips"
        }
        static func rowLabel(_ row: Int, _ sipCount: Int) -> String {
            if lang == .de { return "Reihe \(row) · \(sipCount) Schlücke" }
            return "Row \(row) · \(sipCount) sips"
        }
        static func cardAccessibility(_ card: Int, _ row: Int) -> String {
            if lang == .de { return "Karte \(card) in Reihe \(row)" }
            return "Card \(card) in row \(row)"
        }
        static func revealed(_ cardName: String) -> String {
            if lang == .de { return "Aufgedeckt: \(cardName)" }
            return "Revealed: \(cardName)"
        }
        static func discardPrompt(_ valueName: String) -> String {
            if lang == .de { return "Möchtest du deine \(valueName) ablegen?" }
            return "Do you want to discard your \(valueName)?"
        }
        static var yesDiscard: String {
            lang == .de ? "Ja, ablegen!" : "Yes, discard!"
        }
        static var isBusDriver: String {
            lang == .de ? "ist der Busfahrer!" : "is the bus driver!"
        }
        static var startBusRide: String {
            lang == .de ? "Busfahrt starten" : "Start Bus Ride"
        }
    }

    // MARK: - Phase 3

    enum phase3 {
        static var busRide: String {
            lang == .de ? "BUSFAHRT!" : "BUS RIDE!"
        }
        static func attempt(_ n: Int) -> String {
            lang == .de ? "Versuch \(n)" : "Attempt \(n)"
        }
        static var currentCards: String {
            lang == .de ? "Aktuelle Karten" : "Current Cards"
        }
        static func wrongMessage(_ round: Int) -> String {
            if lang == .de { return "\(round) \(sips.word(round)) trinken! Zurück zu Runde 1." }
            return "Drink \(round) \(sips.word(round))! Back to round 1."
        }
        static var completed: String {
            lang == .de ? "Geschafft! Die Busfahrt ist vorbei!" : "Done! The bus ride is over!"
        }
        static func nextRound(_ n: Int) -> String {
            lang == .de ? "Weiter zu Runde \(n)!" : "On to round \(n)!"
        }
    }

    // MARK: - Menu

    enum menu {
        static var title: String {
            lang == .de ? "Menü" : "Menu"
        }
        static var continueGame: String {
            lang == .de ? "Weiterspielen" : "Continue"
        }
        static var backToMain: String {
            lang == .de ? "Zurück zum Hauptmenü" : "Back to Main Menu"
        }
        static var endGameQuestion: String {
            lang == .de ? "Spiel beenden?" : "End game?"
        }
        static var progressLost: String {
            lang == .de ? "Der aktuelle Spielfortschritt geht verloren." : "Current game progress will be lost."
        }
        static var toMainMenu: String {
            lang == .de ? "Zum Hauptmenü" : "To Main Menu"
        }
        static var language: String {
            lang == .de ? "Sprache" : "Language"
        }
        static var settings: String {
            lang == .de ? "Einstellungen" : "Settings"
        }
    }

    // MARK: - Game End

    enum gameEnd {
        static var title: String {
            lang == .de ? "Spiel vorbei!" : "Game Over!"
        }
        static func survived(_ name: String) -> String {
            if lang == .de { return "\(name) hat die Busfahrt überstanden!" }
            return "\(name) survived the bus ride!"
        }
        static var playerColumn: String {
            lang == .de ? "Spieler" : "Player"
        }
        static var drunkColumn: String {
            lang == .de ? "Getrunken" : "Drunk"
        }
        static var distributedColumn: String {
            lang == .de ? "Verteilt" : "Dealt"
        }
        static var newGame: String {
            lang == .de ? "Neues Spiel" : "New Game"
        }
        static var newPlayers: String {
            lang == .de ? "Neue Spieler" : "New Players"
        }
        static var quit: String {
            lang == .de ? "Beenden" : "Quit"
        }
        static var sipKing: String {
            lang == .de ? "Schluck-König" : "Sip King"
        }
        static var unlucky: String {
            lang == .de ? "Pechvogel" : "Unlucky"
        }
        static var busDriver: String {
            lang == .de ? "Busfahrer" : "Bus Driver"
        }
        static func sipsDistributed(_ n: Int) -> String {
            if lang == .de { return "\(n) Schlücke verteilt" }
            return "\(n) sips distributed"
        }
        static func sipsDrunk(_ n: Int) -> String {
            if lang == .de { return "\(n) Schlücke getrunken" }
            return "\(n) sips drunk"
        }
        static func failedAttempts(_ n: Int) -> String {
            if lang == .de { return "\(n) Fehlversuche" }
            return "\(n) failed attempts"
        }
    }

    // MARK: - Phase Transitions

    enum transition {
        static var phase3Title: String {
            lang == .de ? "Busfahrt" : "Bus Ride"
        }
        static var gameEndTitle: String {
            lang == .de ? "Geschafft!" : "Done!"
        }
        static var phase1Subtitle: String {
            lang == .de ? "Kartenraten – Rate die Eigenschaften deiner Karten!" : "Card Guessing – Guess the properties of your cards!"
        }
        static var phase2Subtitle: String {
            lang == .de ? "Die Pyramide – Werde deine Karten los!" : "The Pyramid – Get rid of your cards!"
        }
        static func phase3Subtitle(_ name: String) -> String {
            if lang == .de { return "\(name) muss Busfahren!" }
            return "\(name) has to ride the bus!"
        }
        static var phase3SubtitleGeneric: String {
            lang == .de ? "Der Busfahrer muss alle 4 Runden schaffen!" : "The bus driver must complete all 4 rounds!"
        }
        static var gameOverSubtitle: String {
            lang == .de ? "Das Spiel ist vorbei!" : "The game is over!"
        }
        static var letsGo: String {
            lang == .de ? "Los geht's!" : "Let's go!"
        }
    }

    // MARK: - Oracle

    enum oracle {
        static var deciding: String {
            lang == .de ? "Das Orakel entscheidet..." : "The oracle decides..."
        }
        static var tiebreaker: String {
            lang == .de ? "Gleichstand! Wer wird Busfahrer?" : "Tie! Who becomes the bus driver?"
        }
    }

    // MARK: - Pferderennen

    enum pferderennen {
        static var title: String {
            lang == .de ? "Pferderennen" : "Horse Race"
        }
        static var subtitle: String {
            lang == .de ? "Das Wett-Trinkspiel" : "The Betting Drinking Game"
        }
        static var flavorText: String {
            lang == .de ? "Setzt auf euer Pferd und hofft auf den Sieg!\nWer gewinnt, verteilt doppelt." : "Bet on your horse and hope for victory!\nWinners distribute double."
        }
        static var placeBet: String {
            lang == .de ? "Wette platzieren" : "Place Your Bet"
        }
        static func chooseHorse(_ name: String) -> String {
            lang == .de ? "\(name), wähle dein Pferd!" : "\(name), choose your horse!"
        }
        static var howManySips: String {
            lang == .de ? "Wie viele Schlücke setzt du?" : "How many sips do you bet?"
        }
        static func betPlaced(_ name: String, _ sips: Int, _ suit: String) -> String {
            if lang == .de { return "\(name) setzt \(sips) Schlücke auf \(suit)!" }
            return "\(name) bets \(sips) sips on \(suit)!"
        }
        static func drinkBet(_ name: String, _ sips: Int) -> String {
            if lang == .de { return "\(name), trinke deinen Einsatz: \(sips) Schlücke!" }
            return "\(name), drink your bet: \(sips) sips!"
        }
        static var raceStarting: String {
            lang == .de ? "Das Rennen beginnt!" : "The race begins!"
        }
        static var drawCard: String {
            lang == .de ? "Karte ziehen" : "Draw Card"
        }
        static func horseAdvances(_ suit: String) -> String {
            if lang == .de { return "\(suit) rückt vor!" }
            return "\(suit) advances!"
        }
        static func horseRetreats(_ suit: String) -> String {
            if lang == .de { return "\(suit) muss zurück!" }
            return "\(suit) falls back!"
        }
        static func trackRevealed(_ suit: String) -> String {
            if lang == .de { return "Streckenkarte: \(suit) geht einen Schritt zurück!" }
            return "Track card: \(suit) moves back one step!"
        }
        static func winner(_ suit: String) -> String {
            if lang == .de { return "\(suit) gewinnt das Rennen!" }
            return "\(suit) wins the race!"
        }
        static func winnerDistributes(_ name: String, _ sips: Int) -> String {
            if lang == .de { return "\(name) darf \(sips) Schlücke verteilen!" }
            return "\(name) can distribute \(sips) sips!"
        }
        static func loserDrinks(_ name: String, _ sips: Int) -> String {
            if lang == .de { return "\(name) trinkt \(sips) Schlücke!" }
            return "\(name) drinks \(sips) sips!"
        }
        static var nextRace: String {
            lang == .de ? "Nächstes Rennen" : "Next Race"
        }
        static var raceTrack: String {
            lang == .de ? "Rennstrecke" : "Race Track"
        }
        static var horses: String {
            lang == .de ? "Pferde" : "Horses"
        }
        static var rulesTitle: String {
            lang == .de ? "Pferderennen – Regeln" : "Horse Race – Rules"
        }
        static var rulesText: String {
            if lang == .de {
                return """
                Die 4 Buben sind die Pferde. Jeder Spieler wählt ein Pferd und setzt Schlücke darauf.

                Den Einsatz muss man vor dem Rennen selbst trinken!

                Es werden Karten vom Stapel gezogen. Das Pferd der gleichen Farbe rückt ein Feld vor.

                Sobald alle Pferde ein Streckenfeld erreicht haben, wird es aufgedeckt. Das Pferd dieser Farbe muss ein Feld zurück.

                Das erste Pferd über die Ziellinie gewinnt! Gewinner verteilen den doppelten Einsatz.
                """
            }
            return """
            The 4 Jacks are the horses. Each player picks a horse and bets sips on it.

            You must drink your bet before the race starts!

            Cards are drawn from the deck. The horse matching the card's suit advances one step.

            When all horses reach a track card position, it's revealed. The matching horse moves back one step.

            The first horse past the finish line wins! Winners distribute double their bet.
            """
        }
    }

    // MARK: - F*ck the Dealer

    enum ftd {
        static var title: String {
            "F*ck the Dealer"
        }
        static var subtitle: String {
            lang == .de ? "Das Ratespiel" : "The Guessing Game"
        }
        static var flavorText: String {
            lang == .de ? "Rate die Karte oder trink die Differenz!\nDer Dealer ist dein Feind." : "Guess the card or drink the difference!\nThe dealer is your enemy."
        }
        static func dealerIs(_ name: String) -> String {
            lang == .de ? "\(name) ist der Dealer" : "\(name) is the Dealer"
        }
        static func guesserTurn(_ name: String) -> String {
            lang == .de ? "\(name), rate den Kartenwert!" : "\(name), guess the card value!"
        }
        static var firstGuess: String {
            lang == .de ? "Erster Versuch" : "First Guess"
        }
        static var secondGuess: String {
            lang == .de ? "Zweiter Versuch" : "Second Guess"
        }
        static func hintHigher(_ name: String) -> String {
            lang == .de ? "Höher! \(name), rate nochmal!" : "Higher! \(name), guess again!"
        }
        static func hintLower(_ name: String) -> String {
            lang == .de ? "Tiefer! \(name), rate nochmal!" : "Lower! \(name), guess again!"
        }
        static func correctGuess1(_ dealer: String) -> String {
            lang == .de ? "Richtig beim 1. Versuch! \(dealer) trinkt 4 Schlücke!" : "Correct on 1st guess! \(dealer) drinks 4 sips!"
        }
        static func correctGuess2(_ dealer: String) -> String {
            lang == .de ? "Richtig beim 2. Versuch! \(dealer) trinkt 2 Schlücke!" : "Correct on 2nd guess! \(dealer) drinks 2 sips!"
        }
        static func wrongBothGuesses(_ name: String, _ diff: Int) -> String {
            if lang == .de { return "Daneben! \(name) trinkt \(diff) Schlücke!" }
            return "Wrong! \(name) drinks \(diff) sips!"
        }
        static func dealerSurvived(_ n: Int) -> String {
            lang == .de ? "\(n)/3 Spieler falsch – Dealer wechselt bei 3!" : "\(n)/3 players wrong – Dealer changes at 3!"
        }
        static func newDealer(_ name: String) -> String {
            lang == .de ? "Neuer Dealer: \(name)!" : "New Dealer: \(name)!"
        }
        static var cardsPlayed: String {
            lang == .de ? "Gespielte Karten" : "Cards Played"
        }
        static var rulesTitle: String {
            lang == .de ? "F*ck the Dealer – Regeln" : "F*ck the Dealer – Rules"
        }
        static var rulesText: String {
            if lang == .de {
                return """
                Der Dealer zieht eine verdeckte Karte. Der Spieler links vom Dealer rät den Kartenwert.

                1. Versuch: Falsch → Der Dealer sagt "Höher" oder "Tiefer".
                2. Versuch: Falsch → Der Spieler trinkt die Differenz zwischen seinem Tipp und dem echten Wert.

                Richtig beim 1. Versuch: Dealer trinkt 4 Schlücke.
                Richtig beim 2. Versuch: Dealer trinkt 2 Schlücke.

                Wenn 3 Spieler hintereinander falsch raten, wechselt der Dealer.

                Aufgedeckte Karten werden offen hingelegt – merkt euch, was schon weg ist!
                """
            }
            return """
            The dealer draws a hidden card. The player to the dealer's left guesses the card value.

            1st Guess Wrong → The dealer says "Higher" or "Lower".
            2nd Guess Wrong → The player drinks the difference between their guess and the actual value.

            Correct on 1st guess: Dealer drinks 4 sips.
            Correct on 2nd guess: Dealer drinks 2 sips.

            If 3 consecutive players guess wrong, the dealer role passes on.

            Revealed cards are placed face-up – remember what's already been played!
            """
        }
    }

    // MARK: - Kings Cup

    enum kingsCup {
        static var title: String {
            "Kings Cup"
        }
        static var subtitle: String {
            lang == .de ? "Circle of Death" : "Circle of Death"
        }
        static var flavorText: String {
            lang == .de ? "Zieht Karten, befolgt die Regeln,\nund trinkt den Kelch des Königs!" : "Draw cards, follow the rules,\nand drink the King's Cup!"
        }
        static var drawCard: String {
            lang == .de ? "Karte ziehen" : "Draw Card"
        }
        static func playerTurn(_ name: String) -> String {
            lang == .de ? "\(name) ist dran!" : "\(name)'s turn!"
        }
        static var cardsRemaining: String {
            lang == .de ? "Karten übrig" : "cards left"
        }
        static func kingsDrawn(_ n: Int) -> String {
            lang == .de ? "\(n)/4 Könige gezogen" : "\(n)/4 Kings drawn"
        }
        static var kingsCupFull: String {
            lang == .de ? "Der Kings Cup ist voll!" : "The Kings Cup is full!"
        }
        static func mustDrinkCup(_ name: String) -> String {
            lang == .de ? "\(name) muss den Kings Cup trinken!" : "\(name) must drink the Kings Cup!"
        }
        static var thumbKing: String {
            lang == .de ? "Daumenkönig" : "Thumb King"
        }
        static var questionQueen: String {
            "Questionmaster"
        }
        static var drinkingBuddy: String {
            lang == .de ? "Mate" : "Mate"
        }
        static func chooseBuddy(_ name: String) -> String {
            lang == .de ? "\(name), wähle deinen Mate!" : "\(name), choose your Mate!"
        }
        static var rulesTitle: String {
            lang == .de ? "Kings Cup – Regeln" : "Kings Cup – Rules"
        }
        static var rulesText: String {
            if lang == .de {
                return """
                Legt alle Karten verdeckt im Kreis um ein Glas (den Kings Cup). Reihum zieht jeder eine Karte:

                2 – Verteile 2: Du verteilst 2 Schlücke.
                3 – Trinke 3: Du trinkst 3 Schlücke.
                4 – Floormaster: Letzter am Boden trinkt!
                5 – Five is Guys: Alle Jungs trinken.
                6 – Six is Chicks: Alle Mädels trinken.
                7 – Daumenkönig: Du darfst jederzeit den Daumen auf den Tisch legen. Der Letzte trinkt!
                8 – Eight is Mate: Wähle einen Mate. Wenn einer trinkt, trinkt der andere mit.
                9 – Nine is Rhyme: Sage ein Wort, im Uhrzeigersinn wird gereimt. Wer nicht kann, trinkt.
                10 – Regel ausdenken: Denke dir eine Regel aus, die ab jetzt gilt. Wer sie bricht, trinkt!
                Bube – Ich hab noch nie: Sage etwas, das du noch nie getan hast. Wer es getan hat, trinkt.
                Dame – Questionmaster: Dir darf niemand Fragen beantworten bis zur nächsten Dame.
                König – Kings Cup: Fülle den Cup 1/4 voll. Beim 4. König trinkt der Zieher den gesamten Cup!
                Ass – Waterfall: Du fängst an zu trinken, alle trinken mit. Erst wenn du aufhörst, darf der nächste aufhören.
                """
            }
            return """
            Place all cards face-down in a circle around a glass (the Kings Cup). Players take turns drawing:

            2 – Distribute 2: Give out 2 sips.
            3 – Drink 3: Drink 3 sips yourself.
            4 – Floormaster: Last to touch the floor drinks!
            5 – Five is Guys: All boys drink.
            6 – Six is Chicks: All girls drink.
            7 – Thumb King: You may place your thumb on the table anytime. Last to follow drinks!
            8 – Eight is Mate: Pick a mate. When one drinks, both drink.
            9 – Nine is Rhyme: Say a word, go clockwise rhyming. First to fail drinks.
            10 – Make a Rule: Make up a rule that applies from now on. Whoever breaks it, drinks!
            Jack – Never Have I Ever: Say something you've never done. Those who have, drink.
            Queen – Questionmaster: No one may answer your questions until the next Queen.
            King – Kings Cup: Fill the cup 1/4 full. The 4th King = drink the entire cup!
            Ace – Waterfall: Start drinking, everyone follows. They can only stop after the person before them stops.
            """
        }

        // Card action titles
        static func actionTitle(for value: CardValue) -> String {
            switch value {
            case .zwei:
                return lang == .de ? "Verteile 2!" : "Distribute 2!"
            case .drei:
                return lang == .de ? "Trinke 3!" : "Drink 3!"
            case .vier:
                return "Floormaster!"
            case .fuenf:
                return "Five is Guys!"
            case .sechs:
                return "Six is Chicks!"
            case .sieben:
                return lang == .de ? "Daumenkönig!" : "Thumb King!"
            case .acht:
                return "Eight is Mate!"
            case .neun:
                return "Nine is Rhyme!"
            case .zehn:
                return lang == .de ? "Regel ausdenken!" : "Make a Rule!"
            case .bube:
                return lang == .de ? "Ich hab noch nie..." : "Never Have I Ever..."
            case .dame:
                return "Questionmaster!"
            case .koenig:
                return "Kings Cup!"
            case .ass:
                return "Waterfall!"
            }
        }

        static func actionDescription(for value: CardValue) -> String {
            switch value {
            case .zwei:
                return lang == .de ? "Du darfst 2 Schlücke verteilen." : "You get to distribute 2 sips."
            case .drei:
                return lang == .de ? "Du trinkst 3 Schlücke." : "You drink 3 sips."
            case .vier:
                return lang == .de ? "Floormaster! Der Letzte, der den Boden berührt, trinkt!" : "Floormaster! Last person to touch the floor drinks!"
            case .fuenf:
                return lang == .de ? "Five is Guys! Alle Jungs trinken einen Schluck!" : "Five is Guys! All boys take a sip!"
            case .sechs:
                return lang == .de ? "Six is Chicks! Alle Mädels trinken einen Schluck!" : "Six is Chicks! All girls take a sip!"
            case .sieben:
                return lang == .de ? "Du bist der Daumenkönig! Lege jederzeit deinen Daumen auf den Tisch – der Letzte trinkt." : "You're the Thumb King! Place your thumb on the table anytime – last to follow drinks."
            case .acht:
                return lang == .de ? "Eight is Mate! Wähle deinen Mate! Wenn einer von euch trinkt, trinkt der andere mit." : "Eight is Mate! Choose your mate! When one of you drinks, the other drinks too."
            case .neun:
                return lang == .de ? "Nine is Rhyme! Sage ein Wort! Im Uhrzeigersinn wird gereimt. Wer nicht kann, trinkt." : "Nine is Rhyme! Say a word! Go clockwise rhyming. Whoever can't think of one drinks."
            case .zehn:
                return lang == .de ? "Denke dir eine Regel aus, die ab sofort gilt! Wer sie bricht, trinkt." : "Make up a rule that applies from now on! Whoever breaks it, drinks."
            case .bube:
                return lang == .de ? "Sage etwas, das du noch nie getan hast. Jeder, der es getan hat, trinkt!" : "Say something you've never done. Everyone who has done it drinks!"
            case .dame:
                return lang == .de ? "Du bist der Questionmaster! Niemand darf deine Fragen beantworten – bis zur nächsten Dame." : "You're the Questionmaster! Nobody may answer your questions – until the next Queen."
            case .koenig:
                return lang == .de ? "Fülle den Kings Cup zu 1/4 mit deinem Getränk." : "Fill the Kings Cup 1/4 full with your drink."
            case .ass:
                return lang == .de ? "Waterfall! Du fängst an zu trinken, alle anderen trinken mit. Erst wenn du aufhörst, darf der Nächste aufhören." : "Waterfall! Start drinking, everyone follows. They can only stop after the person before them stops."
            }
        }

        static func actionEmoji(for value: CardValue) -> String {
            switch value {
            case .zwei: return "✌️"
            case .drei: return "🍺"
            case .vier: return "🫳"
            case .fuenf: return "🙋‍♂️"
            case .sechs: return "🙋‍♀️"
            case .sieben: return "👍"
            case .acht: return "🤝"
            case .neun: return "🎤"
            case .zehn: return "📜"
            case .bube: return "🙈"
            case .dame: return "❓"
            case .koenig: return "👑"
            case .ass: return "🌊"
            }
        }
    }

    // MARK: - Card Names

    enum card {
        static func suitName(_ suit: Suit) -> String {
            switch suit {
            case .herz:  return lang == .de ? "Herz" : "Hearts"
            case .karo:  return lang == .de ? "Karo" : "Diamonds"
            case .pik:   return lang == .de ? "Pik" : "Spades"
            case .kreuz: return lang == .de ? "Kreuz" : "Clubs"
            }
        }
        static func valueName(_ value: CardValue) -> String {
            switch value {
            case .zwei:   return lang == .de ? "Zwei" : "Two"
            case .drei:   return lang == .de ? "Drei" : "Three"
            case .vier:   return lang == .de ? "Vier" : "Four"
            case .fuenf:  return lang == .de ? "Fünf" : "Five"
            case .sechs:  return lang == .de ? "Sechs" : "Six"
            case .sieben: return lang == .de ? "Sieben" : "Seven"
            case .acht:   return lang == .de ? "Acht" : "Eight"
            case .neun:   return lang == .de ? "Neun" : "Nine"
            case .zehn:   return lang == .de ? "Zehn" : "Ten"
            case .bube:   return lang == .de ? "Bube" : "Jack"
            case .dame:   return lang == .de ? "Dame" : "Queen"
            case .koenig: return lang == .de ? "König" : "King"
            case .ass:    return lang == .de ? "Ass" : "Ace"
            }
        }
        static func valueDisplayName(_ value: CardValue) -> String {
            switch value {
            case .zwei:   return "2"
            case .drei:   return "3"
            case .vier:   return "4"
            case .fuenf:  return "5"
            case .sechs:  return "6"
            case .sieben: return "7"
            case .acht:   return "8"
            case .neun:   return "9"
            case .zehn:   return "10"
            case .bube:   return lang == .de ? "B" : "J"
            case .dame:   return lang == .de ? "D" : "Q"
            case .koenig: return "K"
            case .ass:    return "A"
            }
        }
    }
}

// swiftlint:enable type_name nesting
