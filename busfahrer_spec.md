# Busfahrer – App-Spezifikation für Claude Code

## 1. Projektübersicht

**App-Name:** Busfahrer
**Plattform:** iOS (App Store)
**Tech-Stack:** SwiftUI (native iOS)
**Sprache der App:** Deutsch
**Zielgruppe:** 16–25 Jahre, Deutschland / Europa
**Spieleranzahl:** 2–8 Spieler
**Design-Referenz:** Picolo Drinking Game (Farben, Animationen, Typography, UI-Patterns)

**Beschreibung:** Busfahrer ist ein Trinkspiel-App für eine Gruppe, die auf **einem einzelnen Smartphone** spielt. Das Handy wird herumgegeben oder in die Mitte gelegt. Es gibt keinen Online-Multiplayer. Die App übernimmt die Rolle des Dealers und steuert den gesamten Spielablauf.

---

## 2. Kartendeck & Grundlagen

### 2.1 Kartenwerte (aufsteigend)
2, 3, 4, 5, 6, 7, 8, 9, 10, Bube, Dame, König, Ass

- **Ass ist die höchste Karte.**
- Bei Vergleichen gilt: 2 < 3 < ... < König < Ass

### 2.2 Farben & Symbole
| Farbe   | Symbole         |
|---------|-----------------|
| Rot     | Herz ♥, Karo ♦  |
| Schwarz | Pik ♠, Kreuz ♣  |

### 2.3 Kartendeck
- Standard-Pokerdeck: 52 Karten (4 Symbole × 13 Werte)
- Kein Joker

### 2.4 Kartendeck-Management
- Das Spiel verwendet **einen gemeinsamen Kartenstapel** für alle Phasen.
- Karten, die bereits ausgeteilt oder aufgedeckt wurden, kommen **nicht** zurück in den Stapel (bis der Stapel leer ist).
- **Wenn der Kartenstapel leer ist:** Alle bereits gespielten Karten werden eingesammelt, gemischt, und als neuer Stapel verwendet.

---

## 3. Spielstart-Flow

### 3.1 Startbildschirm
- App-Logo & Name "Busfahrer"
- Button: "Neues Spiel starten"
- Optional: "Regeln anzeigen" (kurze Regelübersicht)

### 3.2 Spieler-Eingabe
1. Bildschirm: "Spieler hinzufügen"
2. Eingabefeld für Spielernamen + "Hinzufügen"-Button
3. Liste der bereits hinzugefügten Spieler (mit Möglichkeit zum Entfernen)
4. Mindestens 2, maximal 8 Spieler müssen hinzugefügt werden
5. Jeder Spieler wählt eine **Farbe** oder ein **Avatar-Icon** als visuelle Zuordnung
6. Button: "Spiel starten" (erst aktiv ab 2 Spielern)

### 3.3 Dealer
- **Der Dealer ist kein menschlicher Spieler**, sondern die App selbst.
- Die App steuert den gesamten Ablauf: Kartenvergabe, Fragereihenfolge, Auswertung.
- Die Spielerreihenfolge wird zu Beginn zufällig festgelegt und bleibt für Phase 1 bestehen.

---

## 4. Schluck-System (gilt für alle Phasen)

### 4.1 Schluck-Tracking
- Jeder Spieler hat zwei Zähler, die **permanent sichtbar** sind:
  - **Erhalten:** Gesamtzahl der Schlücke, die der Spieler trinken muss (aus eigenen Fehlern + von anderen Spielern erhalten)
  - **Verteilt:** Gesamtzahl der Schlücke, die der Spieler an andere verteilt hat
- Die Zähler werden über **alle Phasen hinweg** kumuliert.

### 4.2 Schluck-Verteilungs-Mechanik
Wenn ein Spieler X Schlücke verteilen darf (X ≥ 1):
1. App zeigt: "An wen möchtest du Schlücke verteilen?" → Liste aller **anderen** Spieler
2. Spieler wählt einen Empfänger aus
3. App zeigt: "Wie viele Schlücke für [Empfänger]?" → Auswahl von 1 bis [verbleibende Schlücke]
4. Wenn noch Schlücke übrig: Zurück zu Schritt 1
5. Wenn alle Schlücke verteilt: Weiter im Spiel

**Beispiel:** Spieler hat 4 Schlücke zu verteilen → gibt 1 an Anna → gibt 2 an Ben → gibt 1 an Clara → fertig.

---

## 5. Phase 1 – Kartenraten

### 5.1 Überblick
- Der Dealer (die App) stellt jedem Spieler nacheinander eine Frage pro Runde.
- Es gibt 4 Runden. Nach jeder Runde haben alle Spieler eine weitere Karte.
- Am Ende von Phase 1 hat jeder Spieler **4 Karten**, die für Phase 2 gespeichert werden.

### 5.2 Ablauf pro Runde
Die App geht die Spieler **in der festgelegten Reihenfolge** durch. Für jeden Spieler:
1. Frage anzeigen (abhängig von der Runde)
2. Spieler wählt seine Antwort
3. App deckt die Karte auf (mit Animation)
4. Ergebnis anzeigen: Richtig → Schlücke verteilen / Falsch → Schlücke trinken
5. Karte wird dem Spieler zugeordnet und gespeichert
6. Weiter zum nächsten Spieler

### 5.3 Runde 1: Farbe
- **Frage:** "Welche Farbe hat die Karte?"
- **Auswahl:** `Schwarz` | `Rot`
- **Richtig:** 1 Schluck verteilen
- **Falsch:** 1 Schluck selbst trinken

### 5.4 Runde 2: Höher oder Tiefer
- **Frage:** "Ist die Karte höher oder tiefer?"
- **Bezug:** Verglichen mit der Karte des Spielers aus Runde 1
- **Anzeige:** Die Karte aus Runde 1 wird angezeigt als Referenz
- **Auswahl:** `Höher` | `Tiefer`
- **Sonderfall "Gleich":** Wenn die neue Karte denselben Wert hat wie die Karte aus Runde 1, gilt das als **falsch** (egal ob der Spieler "Höher" oder "Tiefer" gewählt hat).
- **Richtig:** 2 Schlücke verteilen
- **Falsch:** 2 Schlücke selbst trinken

### 5.5 Runde 3: Innerhalb, Außerhalb oder Gleich
- **Frage:** "Ist die Karte innerhalb, außerhalb oder gleich?"
- **Bezug:** Verglichen mit den Karten des Spielers aus Runde 1 und 2
- **Anzeige:** Beide bisherigen Karten werden angezeigt als Referenz
- **Auswahl:** `Innerhalb` | `Außerhalb` | `Gleich`
- **Definitionen:**
  - **Innerhalb:** Der Wert liegt strikt zwischen den Werten der Karten aus Runde 1 und 2.
    - Beispiel: Runde 1 = 4, Runde 2 = 9 → Karte 6 ist innerhalb ✓
  - **Außerhalb:** Der Wert liegt außerhalb des Bereichs der Karten aus Runde 1 und 2.
    - Beispiel: Runde 1 = 4, Runde 2 = 9 → Karte Bube ist außerhalb ✓
  - **Gleich:** Der Wert ist identisch mit einer der Karten aus Runde 1 oder 2.
    - Beispiel: Runde 1 = 4, Runde 2 = 9 → Karte 4 ist gleich ✓
- **Richtig:** 3 Schlücke verteilen
- **Falsch:** 3 Schlücke selbst trinken

### 5.6 Runde 4: Symbol
- **Frage:** "Welches Symbol hat die Karte?"
- **Auswahl:** `Herz ♥` | `Karo ♦` | `Pik ♠` | `Kreuz ♣`
- **Richtig:** 4 Schlücke verteilen
- **Falsch:** 4 Schlücke selbst trinken

### 5.7 Übergang zu Phase 2
- Alle 4 Karten jedes Spielers werden gespeichert und in Phase 2 übernommen.
- Kurze Übergangsanimation / Bildschirm: "Phase 2 – Die Pyramide"

---

## 6. Phase 2 – Die Pyramide

### 6.1 Überblick
- Die App legt eine **Pyramide aus verdeckten Karten** aus:
  ```
        [?]          ← Reihe 4 (1 Karte)  = 8 Schlücke
       [?] [?]       ← Reihe 3 (2 Karten) = 6 Schlücke
      [?] [?] [?]    ← Reihe 2 (3 Karten) = 4 Schlücke
     [?] [?] [?] [?] ← Reihe 1 (4 Karten) = 2 Schlücke
  ```
- Insgesamt 10 Karten in der Pyramide (vom gemeinsamen Kartenstapel gezogen).
- Ziel: Eigene Karten loswerden, um nicht Busfahrer zu werden.

### 6.2 Karten aufdecken
- Karten werden **von unten nach oben** aufgedeckt (Reihe 1 zuerst).
- Innerhalb einer Reihe kann die Reihenfolge der Karten **frei gewählt** werden (durch Antippen).
- Eine neue Reihe kann erst aufgedeckt werden, wenn **alle Karten der aktuellen Reihe aufgedeckt** wurden und der Ablege-Prozess für jede Karte abgeschlossen ist.

### 6.3 Karten ablegen – Mechanik für ein einzelnes Smartphone

Da das Spiel auf **einem einzelnen Smartphone** gespielt wird, kann kein "Wer-ist-schneller"-System verwendet werden. Stattdessen wird folgende Mechanik genutzt:

**Nach dem Aufdecken einer Pyramidenkarte:**
1. Die App zeigt die aufgedeckte Karte mit ihrem Wert an.
2. Die App prüft automatisch, welche Spieler eine **passende Karte** haben (gleicher Wert, Symbol ist egal).
3. **Wenn kein Spieler eine passende Karte hat:** Kurze Anzeige "Niemand kann ablegen" → weiter zur nächsten Karte.
4. **Wenn Spieler passende Karten haben:** Die App geht die Spieler der Reihe nach durch (in Spielerreihenfolge):
   - Für jeden Spieler mit passender Karte: "**[Spielername]**, möchtest du deine [Kartenwert] ablegen?"
   - Auswahl: `Ja` | `Nein`
   - **Ja:** Die Karte wird abgelegt. Der Spieler darf Schlücke verteilen (gemäß der Reihe). Wenn der Spieler **mehrere passende Karten** hat, wird danach gefragt: "Möchtest du noch eine [Kartenwert] ablegen?" (Für jede abgelegte Karte gibt es erneut die Schlücke der Reihe.)
   - **Nein:** Der Spieler behält seine Karte(n). Er kann taktisch entscheiden, die Karte für eine höhere Reihe aufzuheben.
5. Nachdem alle Spieler gefragt wurden → weiter zur nächsten Pyramidenkarte.

**Taktisches Element:** Spieler müssen ihre Karten nicht in Reihe 1 ablegen. Sie können "pokern" und darauf hoffen, dass der gleiche Kartenwert in einer höheren Reihe nochmal vorkommt, um mehr Schlücke zu verteilen. Das Risiko: Wenn der Wert nicht nochmal kommt, behalten sie die Karte und riskieren, Busfahrer zu werden.

### 6.4 Schlücke pro Reihe
| Reihe | Anzahl Karten | Schlücke pro abgelegter Karte |
|-------|---------------|-------------------------------|
| 1     | 4             | 2 Schlücke                    |
| 2     | 3             | 4 Schlücke                    |
| 3     | 2             | 6 Schlücke                    |
| 4     | 1             | 8 Schlücke                    |

### 6.5 Busfahrer-Ermittlung
Nachdem alle 10 Pyramidenkarten aufgedeckt und alle Ablege-Runden abgeschlossen sind:

1. Die App zählt, wie viele Karten jeder Spieler noch hat.
2. **Eindeutiger Verlierer:** Der Spieler mit den meisten verbleibenden Karten wird zum **Busfahrer**.
3. **Stechen (Gleichstand):** Wenn 2 oder mehr Spieler gleich viele Karten haben:
   - Eine **Orakel-Animation** wird abgespielt (z.B. Spotlight wandert zwischen den betroffenen Spielern hin und her, wird langsamer, bleibt bei einem stehen).
   - Das Orakel wählt **zufällig** einen der Spieler im Stechen aus.
   - Dramatische Reveal-Animation: "[Spielername] ist der Busfahrer! 🚌"

### 6.6 Übergang zu Phase 3
- Übergangsbildschirm: "[Spielername] muss Busfahren!" mit Animation.

---

## 7. Phase 3 – Busfahren

### 7.1 Überblick
- **Nur der Busfahrer spielt.** Alle anderen Spieler schauen zu.
- Der Busfahrer muss die 4 Runden aus Phase 1 **fehlerfrei hintereinander** durchspielen.
- Bei **jedem Fehler**: zurück auf Runde 1 von Phase 3 + Schlücke trinken.
- Phase 3 läuft **theoretisch endlos**, bis der Busfahrer alle 4 Runden am Stück richtig beantwortet.

### 7.2 Ablauf

**Runde 1: Farbe**
- Frage: "Welche Farbe hat die Karte?"
- Auswahl: `Schwarz` | `Rot`
- Richtig → weiter zu Runde 2
- Falsch → **1 Schluck trinken**, zurück zu Runde 1 (neue Karte)

**Runde 2: Höher oder Tiefer**
- Frage: "Ist die Karte höher oder tiefer?"
- Bezug: Die Karte aus Runde 1 (dieser Phase-3-Durchgang)
- Auswahl: `Höher` | `Tiefer`
- Sonderfall: Gleicher Wert = falsch
- Richtig → weiter zu Runde 3
- Falsch → **2 Schlücke trinken**, zurück zu Runde 1 (neue Karte)

**Runde 3: Innerhalb, Außerhalb oder Gleich**
- Frage: "Ist die Karte innerhalb, außerhalb oder gleich?"
- Bezug: Die Karten aus Runde 1 und 2 (dieser Phase-3-Durchgang)
- Auswahl: `Innerhalb` | `Außerhalb` | `Gleich`
- Definitionen: Identisch zu Phase 1, Runde 3
- Richtig → weiter zu Runde 4
- Falsch → **3 Schlücke trinken**, zurück zu Runde 1 (neue Karte)

**Runde 4: Symbol**
- Frage: "Welches Symbol hat die Karte?"
- Auswahl: `Herz ♥` | `Karo ♦` | `Pik ♠` | `Kreuz ♣`
- Richtig → **Phase 3 geschafft!** 🎉
- Falsch → **4 Schlücke trinken**, zurück zu Runde 1 (neue Karte)

### 7.3 Kartenstapel in Phase 3
- Jede Runde (auch nach Fehlversuchen) wird eine **neue Karte** vom Stapel gezogen.
- Bei einem Fehler werden die Karten des aktuellen Durchgangs abgelegt und ein komplett neuer Durchgang beginnt.
- **Wenn der Kartenstapel leer ist:** Alle abgelegten Karten werden gemischt und als neuer Stapel verwendet.

### 7.4 Anzeige während Phase 3
- Fortschrittsanzeige: Welche Runde der Busfahrer gerade spielt (1/4, 2/4, etc.)
- Anzahl der bisherigen Fehlversuche
- Kumulierte Schlücke des Busfahrers
- Die Karten des aktuellen Durchgangs (als Referenz für Runde 2, 3)

---

## 8. Spielende

### 8.1 Abschlussbildschirm
Wenn der Busfahrer Phase 3 erfolgreich absolviert hat:

1. **Erfolgs-Animation** (z.B. Konfetti, "Geschafft!"-Nachricht)
2. **Statistik-Übersicht** für alle Spieler:
   - Spielername
   - Gesamte Schlücke getrunken (Summe aus eigenen Fehlern + von anderen erhalten)
   - Gesamte Schlücke verteilt
   - Evtl. Fun-Titel (z.B. "Schluck-König" für den mit den meisten verteilten Schlücken, "Pechvogel" für den mit den meisten getrunkenen)
3. **Buttons:**
   - "Neues Spiel" (gleiche Spieler, neues Spiel)
   - "Neue Spieler" (zurück zum Spieler-Eingabe-Bildschirm)
   - "Beenden"

---

## 9. Design-Richtlinien

### 9.1 Referenz
- **Picolo Drinking Game** als primäre Design-Referenz
- Modernes, jugendliches Design
- Leuchtende Farben auf dunklem Hintergrund
- Große, gut lesbare Typografie
- Smooth Animationen und Übergänge

### 9.2 Allgemeine UI-Prinzipien
- **Dark Mode als Standard** (passend für Partyumgebung / abends)
- Große Buttons, einfach mit einem Finger bedienbar
- Karten-Animationen beim Aufdecken (Flip-Animation)
- Vibration/Haptic Feedback bei wichtigen Events (richtig/falsch, Busfahrer-Reveal)
- Klare visuelle Unterscheidung zwischen Phasen
- Spieler-Avatare/Farben konsequent durchgängig verwenden

### 9.3 Schrift & Farben
- Fette, runde Sans-Serif-Schrift für Headlines
- Farbcodierung: Grün = Richtig, Rot = Falsch, Gold/Gelb = Schlücke verteilen
- Karten im klassischen Spielkarten-Design

---

## 10. Technische Anforderungen

### 10.1 Architektur
- **SwiftUI** als UI-Framework
- **MVVM-Architektur** (Model-View-ViewModel)
- Lokale State-Verwaltung (kein Backend/Server nötig)
- Kein Account-System, kein Login

### 10.2 State-Management
- Alle Spieler-Daten (Namen, Karten, Schlücke) im App-State
- Phase-Übergänge als State-Transitions
- Kartenstapel als zufällig gemischtes Array

### 10.3 Animationen
- Karten-Flip-Animation
- Orakel-Animation (Phase 2 Stechen)
- Konfetti/Erfolgs-Animation (Spielende)
- Übergangs-Animationen zwischen Phasen
- Schluck-Verteilungs-Animation

### 10.4 Kompatibilität
- iOS 17+ (SwiftUI neueste Features nutzen)
- iPhone-only (kein iPad-Layout nötig, aber sollte nicht crashen)
- Portrait-Modus fixiert

---

## 11. Offene Hinweise

- Die App benötigt **keine Internetverbindung** (vollständig offline spielbar).
- Keine In-App-Purchases in der ersten Version.
- Die App soll **flawless funktionieren** – keine Edge Cases, bei denen das Spiel hängen bleibt oder Karten fehlen.
- Alle Texte und UI-Elemente sind auf **Deutsch**.
