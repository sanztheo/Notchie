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
@Observable
final class ScrollController {

    /// Timer Combine pour le defilement a 60fps
    private var timerCancellable: (any Cancellable)?

    /// Reference vers l'etat du prompteur
    private weak var state: PrompterState?

    init(state: PrompterState) {
        self.state = state
    }

    /// Demarre le timer de defilement
    func start() {
        guard timerCancellable == nil else { return }

        timerCancellable = Timer.publish(
            every: Constants.Prompter.frameRate,
            on: .main,
            in: .common
        )
        .autoconnect()
        .sink { [weak self] _ in
            self?.tick()
        }
    }

    /// Arrete le timer de defilement
    func stop() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    /// Reset le defilement a zero
    func reset() {
        stop()
        state?.scrollOffset = 0
    }

    // MARK: - Private

    private func tick() {
        guard let state, state.isPlaying else { return }
        state.scrollOffset += state.speed * Constants.Prompter.frameRate
    }

    // AnyCancellable se cancel automatiquement a la deallocation
}
