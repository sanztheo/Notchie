//
//  NotchDetector.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import AppKit

extension NSScreen {

    /// Indique si l'ecran expose un notch via les safe area insets.
    var hasNotch: Bool {
        safeAreaInsets.top > 0
    }

    /// Hauteur du notch exposee par le systeme.
    var notchHeight: CGFloat {
        safeAreaInsets.top
    }

    /// Rectangle du notch calcule comme l'espace entre les zones auxiliaires
    /// superieures gauche et droite.
    var notchRect: CGRect? {
        guard hasNotch else { return nil }

        guard let leftArea = auxiliaryTopLeftArea,
              let rightArea = auxiliaryTopRightArea else {
            return nil
        }

        let notchMinX = leftArea.maxX
        let notchMaxX = rightArea.minX
        let width = notchMaxX - notchMinX
        guard width > 0 else { return nil }

        let height = notchHeight
        let originY = frame.maxY - height
        return CGRect(x: notchMinX, y: originY, width: width, height: height)
    }
}

enum NotchDetector {

    /// Retourne le premier ecran connecte qui expose un notch.
    static func screenWithNotch() -> NSScreen? {
        NSScreen.screens.first(where: \.hasNotch)
    }
}
