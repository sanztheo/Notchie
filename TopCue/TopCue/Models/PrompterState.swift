//
//  PrompterState.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import Foundation
import SwiftUI

/// Etats possibles du prompteur
enum PlaybackState: Equatable {
    case idle           // Pas de presentation en cours
    case playing        // Texte en defilement
    case hoveredPause   // Pause temporaire par survol souris
    case paused         // Pause manuelle (bouton)
}

/// Modes d'affichage disponibles pour le prompteur.
enum PrompterMode: String, Equatable {
    case notch
    case floating
}

/// Etat observable de la presentation en cours
@Observable
final class PrompterState {
    /// Script actuellement presente
    var currentScript: Script?

    /// Etat de lecture
    var playbackState: PlaybackState = .idle

    /// Offset de defilement actuel (en points)
    var scrollOffset: CGFloat = 0

    /// Vitesse de defilement (points par seconde)
    var speed: CGFloat = 50

    /// La fenetre du prompteur est-elle visible
    var isWindowVisible: Bool = false

    /// Mode d'affichage courant du prompteur
    var mode: PrompterMode = .notch

    /// Controle si la fenetre est exclue du partage d'ecran
    var isInvisible: Bool = true

    /// Taille courante du conteneur visible du prompteur
    var panelSize: CGSize = CGSize(
        width: Constants.Notch.openWidth,
        height: Constants.Notch.openHeight
    )

    /// Hauteur physique du notch detectee sur l'ecran actif
    var detectedNotchHeight: CGFloat = Constants.Notch.physicalHeight

    /// Indique si un notch reel a ete detecte sur un ecran connecte
    var hasDetectedNotch: Bool = false

    // MARK: - Computed

    var isPlaying: Bool {
        playbackState == .playing
    }

    var isPaused: Bool {
        playbackState == .paused || playbackState == .hoveredPause
    }

    var isFloatingMode: Bool {
        mode == .floating
    }

    // MARK: - Actions

    func play() {
        playbackState = .playing
    }

    func pause() {
        playbackState = .paused
    }

    /// Pause temporaire declenchee par le survol de la souris.
    /// Mouse enter : si on jouait, passe en hoveredPause.
    /// Mouse exit  : si on etait en hoveredPause, reprend la lecture.
    func hoverPause() {
        guard playbackState == .playing else { return }
        playbackState = .hoveredPause
    }

    func hoverResume() {
        guard playbackState == .hoveredPause else { return }
        playbackState = .playing
    }

    /// Toggle depuis le bouton de controles.
    /// Si en hoveredPause (souris au-dessus), un clic passe en pause manuelle
    /// (pour que le texte reste en pause meme apres le mouse exit).
    func togglePlayPause() {
        switch playbackState {
        case .playing:
            pause()
        case .hoveredPause:
            // L'utilisateur clique pause alors qu'il survole : pause manuelle
            pause()
        case .paused:
            play()
        case .idle:
            play()
        }
    }

    /// Recommence le defilement depuis le debut sans arreter la presentation
    func restart() {
        scrollOffset = 0
    }

    func stop() {
        playbackState = .idle
        scrollOffset = 0
    }

    func toggleMode() {
        mode = isFloatingMode ? .notch : .floating
    }

    func toggleInvisibility() {
        isInvisible.toggle()
    }

    func increaseSpeed() {
        speed = min(speed + Constants.Prompter.speedStep, Constants.Prompter.maxSpeed)
    }

    func decreaseSpeed() {
        speed = max(speed - Constants.Prompter.speedStep, Constants.Prompter.minSpeed)
    }

    /// Multiplicateur de vitesse affichable (ex: "1.0x")
    var speedMultiplier: String {
        String(format: "%.1fx", speed / 50.0)
    }
}
