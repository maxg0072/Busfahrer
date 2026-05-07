import UIKit
import CoreHaptics

enum HapticManager {
    private static var engine: CHHapticEngine?

    private static func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        if engine == nil {
            do {
                let eng = try CHHapticEngine()
                eng.resetHandler = { engine = nil }
                eng.stoppedHandler = { _ in engine = nil }
                try eng.start()
                engine = eng
            } catch {}
        }
    }

    // MARK: - Simple fallbacks (always available)

    static func correct() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func wrong() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func reveal() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    // MARK: - CoreHaptics patterns

    static func cardFlip() {
        prepareEngine()
        guard let engine else { reveal(); return }
        do {
            let sharp = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8),
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                ],
                relativeTime: 0
            )
            let land = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3),
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                ],
                relativeTime: 0.2
            )
            let pattern = try CHHapticPattern(events: [sharp, land], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch { reveal() }
    }

    static func celebration() {
        prepareEngine()
        guard let engine else { correct(); return }
        do {
            var events: [CHHapticEvent] = []
            // Pop-pop-pop
            for i in 0..<3 {
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5 + Float(i) * 0.1),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6),
                    ],
                    relativeTime: Double(i) * 0.12
                ))
            }
            // BOOM
            events.append(CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
                ],
                relativeTime: 0.5
            ))
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch { correct() }
    }

    static func dangerBuzz() {
        prepareEngine()
        guard let engine else { wrong(); return }
        do {
            let buzz = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4),
                ],
                relativeTime: 0,
                duration: 0.3
            )
            let hit = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8),
                ],
                relativeTime: 0.3
            )
            let pattern = try CHHapticPattern(events: [buzz, hit], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch { wrong() }
    }

    static func drumroll(duration: Double = 1.5) {
        prepareEngine()
        guard let engine else { return }
        do {
            var events: [CHHapticEvent] = []
            let ticks = Int(duration / 0.05)
            for i in 0..<ticks {
                let progress = Float(i) / Float(ticks)
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3 + progress * 0.5),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3 + progress * 0.4),
                    ],
                    relativeTime: Double(i) * 0.05
                ))
            }
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {}
    }

    static func tensionBuild(duration: Double = 0.8) {
        prepareEngine()
        guard let engine else { return }
        do {
            var events: [CHHapticEvent] = []
            let count = 6
            for i in 0..<count {
                let progress = Float(i) / Float(count)
                let time = Double(i) * (duration / Double(count))
                events.append(CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.2 + progress * 0.6),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2 + progress * 0.5),
                    ],
                    relativeTime: time
                ))
            }
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {}
    }

    static func heartbeat() {
        prepareEngine()
        guard let engine else { heavy(); return }
        do {
            let lub = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.7),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3),
                ],
                relativeTime: 0
            )
            let dub = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2),
                ],
                relativeTime: 0.15
            )
            let pattern = try CHHapticPattern(events: [lub, dub], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch { heavy() }
    }
}
