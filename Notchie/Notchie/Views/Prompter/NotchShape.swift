//
//  NotchShape.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI

/// Forme qui imite les coins arrondis du notch MacBook.
///
/// Les coins du haut sont petits (comme les bords du notch physique),
/// les coins du bas sont plus larges (effet "pilule" / Dynamic Island).
/// Utilise des courbes quadratiques comme boring.notch / Atoll.
struct NotchShape: Shape {

    private var topCornerRadius: CGFloat
    private var bottomCornerRadius: CGFloat

    init(
        topCornerRadius: CGFloat = 6,
        bottomCornerRadius: CGFloat = 14
    ) {
        self.topCornerRadius = topCornerRadius
        self.bottomCornerRadius = bottomCornerRadius
    }

    // MARK: - Animatable

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { .init(topCornerRadius, bottomCornerRadius) }
        set {
            topCornerRadius = newValue.first
            bottomCornerRadius = newValue.second
        }
    }

    // MARK: - Shape

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Depart : coin haut gauche
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        // Coin haut gauche (petit rayon)
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topCornerRadius, y: rect.minY + topCornerRadius),
            control: CGPoint(x: rect.minX + topCornerRadius, y: rect.minY)
        )

        // Descente cote gauche
        path.addLine(to: CGPoint(x: rect.minX + topCornerRadius, y: rect.maxY - bottomCornerRadius))

        // Coin bas gauche (grand rayon)
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topCornerRadius + bottomCornerRadius, y: rect.maxY),
            control: CGPoint(x: rect.minX + topCornerRadius, y: rect.maxY)
        )

        // Ligne du bas
        path.addLine(to: CGPoint(x: rect.maxX - topCornerRadius - bottomCornerRadius, y: rect.maxY))

        // Coin bas droit (grand rayon)
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - topCornerRadius, y: rect.maxY - bottomCornerRadius),
            control: CGPoint(x: rect.maxX - topCornerRadius, y: rect.maxY)
        )

        // Remontee cote droit
        path.addLine(to: CGPoint(x: rect.maxX - topCornerRadius, y: rect.minY + topCornerRadius))

        // Coin haut droit (petit rayon)
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.maxX - topCornerRadius, y: rect.minY)
        )

        // Fermer le path
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        return path
    }
}
