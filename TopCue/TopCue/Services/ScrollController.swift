//
//  ScrollController.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import Foundation
import Combine

/// Controle le defilement automatique du prompteur a 60fps.
/// Publie l'offset de defilement via un Timer Combine.
nonisolated @Observable
final class ScrollController {

    /// Timer Combine pour le defilement a 60fps
    private var timerCancellable: AnyCancellable?

    /// Reference vers l'etat du prompteur
    private weak var state: PrompterState?

    /// Reference vers l'etat du detecteur vocal
    private weak var voiceDetector: VoiceDetector?

    /// Facteur de vitesse effectif (0...1) pour transitions douces.
    private var velocityFactor: CGFloat = 0

    init(state: PrompterState, voiceDetector: VoiceDetector? = nil) {
        self.state = state
        self.voiceDetector = voiceDetector
    }

    /// Demarre le timer de defilement.
    func start() {
        guard timerCancellable == nil else { return }

        timerCancellable = Timer.publish(
            every: Constants.Prompter.frameRate,
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { [weak self] _ in
            guard let self else { return }
            self.tick()
        }
    }

    /// Arrete le timer de defilement.
    func stop() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    /// Reset le defilement a zero.
    func reset() {
        stop()
        state?.scrollOffset = 0
    }

    // MARK: - Private

    private func tick() {
        guard let state else { return }
        guard state.isPlaying else {
            velocityFactor = 0
            return
        }

        if !state.voiceModeEnabled {
            velocityFactor = 1
            state.scrollOffset += state.speed * Constants.Prompter.frameRate
            return
        }

        let targetVelocity: CGFloat = voiceDetector?.isSpeaking == true ? 1 : 0
        velocityFactor += (targetVelocity - velocityFactor) * Constants.Voice.scrollEasingFactor

        if targetVelocity == 0,
           velocityFactor < Constants.Voice.minVelocityFactor {
            velocityFactor = 0
        }

        guard velocityFactor > 0 else { return }
        state.scrollOffset += state.speed * Constants.Prompter.frameRate * velocityFactor
    }
}
