//
//  WindowManager.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import AppKit
import SwiftUI

/// Gere la creation et l'affichage de la fenetre flottante du prompteur.
///
/// La fenetre est completement transparente et positionnee au sommet de l'ecran
/// pour que son contenu (noir + NotchShape) fusionne visuellement avec le notch physique.
@Observable
final class WindowManager {

    /// La fenetre flottante du prompteur
    private var panel: FloatingPanel?

    /// Etat partage du prompteur
    let prompterState = PrompterState()

    /// La fenetre est-elle actuellement affichee
    var isPanelVisible: Bool {
        panel?.isVisible ?? false
    }

    // MARK: - Actions

    /// Ouvre la fenetre du prompteur avec le script donne
    func showPrompter(script: Script) {
        prompterState.currentScript = script
        prompterState.scrollOffset = 0

        if panel == nil {
            createPanel()
        }

        guard let panel else { return }

        // Positionner la fenetre collee au haut de l'ecran, centree sur le notch
        positionAtNotch(panel: panel)

        panel.makeKeyAndOrderFront(nil)
        prompterState.isWindowVisible = true

        // Demarrer automatiquement le defilement
        prompterState.play()
    }

    /// Ferme la fenetre du prompteur
    func hidePrompter() {
        prompterState.stop()
        prompterState.isWindowVisible = false
        panel?.orderOut(nil)
    }

    // MARK: - Private

    private func createPanel() {
        let panel = FloatingPanel()

        let prompterView = PrompterView(state: prompterState)
        let hostingView = NSHostingView(rootView: prompterView)
        hostingView.layer?.backgroundColor = .clear

        panel.contentView = hostingView

        self.panel = panel
    }

    /// Positionne la fenetre au sommet de l'ecran, centree horizontalement,
    /// avec le bord superieur touchant le haut physique de l'ecran.
    /// La fenetre transparente + contenu noir clippe en NotchShape
    /// fusionne visuellement avec le notch physique.
    private func positionAtNotch(panel: FloatingPanel) {
        guard let screen = NSScreen.main else { return }

        let panelWidth = Constants.Notch.openWidth
        let panelHeight = Constants.Notch.openHeight

        // Centrer horizontalement sur l'ecran
        let originX = screen.frame.midX - panelWidth / 2

        // Coller le bord superieur au haut de l'ecran
        // En coordonnees AppKit : y = 0 en bas, donc maxY = haut de l'ecran
        let originY = screen.frame.maxY - panelHeight

        panel.setFrame(
            CGRect(x: originX, y: originY, width: panelWidth, height: panelHeight),
            display: true
        )
    }
}
