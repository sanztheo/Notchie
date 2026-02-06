//
//  FloatingPanel.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import AppKit

/// NSPanel completement transparent qui se fusionne avec le notch physique.
///
/// Inspiré de boring.notch / Atoll :
/// - Fond transparent, pas de barre de titre, pas d'ombre
/// - Niveau au-dessus de la menu bar (.mainMenu + 3)
/// - Immobile, collé au haut de l'ecran
/// - Visible sur tous les Spaces
final class FloatingPanel: NSPanel {

    init() {
        super.init(
            contentRect: .zero,
            styleMask: [
                .nonactivatingPanel,
                .borderless,
                .fullSizeContentView
            ],
            backing: .buffered,
            defer: false
        )

        // --- Fenetre flottante ---
        isFloatingPanel = true
        level = .mainMenu + 3       // Au-dessus de la menu bar et du notch
        hidesOnDeactivate = false

        // --- Pas de barre de titre ---
        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        // --- Completement transparent ---
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false

        // --- Immobile ---
        isMovable = false
        isMovableByWindowBackground = false

        // --- Visible partout ---
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]

        isReleasedWhenClosed = false
    }

    // MARK: - Key handling

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    /// Cache la fenetre au lieu de la detruire
    override func close() {
        orderOut(nil)
    }
}
