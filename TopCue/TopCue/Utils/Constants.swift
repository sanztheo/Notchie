//
//  Constants.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import Foundation
import SwiftUI

enum Constants {

    // MARK: - Prompter

    enum Prompter {
        /// Vitesse de defilement par defaut (points/seconde)
        static let defaultSpeed: CGFloat = 50

        /// Vitesse minimum (0.25x)
        static let minSpeed: CGFloat = 12.5

        /// Vitesse maximum (4x)
        static let maxSpeed: CGFloat = 200

        /// Increment de vitesse
        static let speedStep: CGFloat = 12.5

        /// Taille de police par defaut
        static let defaultFontSize: CGFloat = 24

        /// Taille de police minimum
        static let minFontSize: CGFloat = 14

        /// Taille de police maximum (la zone visible fait ~60pt, limiter a 36pt)
        static let maxFontSize: CGFloat = 36

        /// Espacement entre les lignes
        static let lineSpacing: CGFloat = 12

        /// Padding du texte
        static let textPadding: CGFloat = 40

        /// Framerate du timer de defilement
        static let frameRate: TimeInterval = 1.0 / 60.0
    }

    // MARK: - Voice

    enum Voice {
        /// Cle UserDefaults du mode voix
        static let modeEnabledKey = "voice.mode.enabled"

        /// Cle UserDefaults de sensibilite micro
        static let sensitivityKey = "voice.sensitivity"

        /// Sensibilite par defaut (0.0 = tres sensible, 1.0 = peu sensible)
        static let defaultSensitivity: Double = 0.5

        /// Borne basse du seuil RMS (micro sensible)
        static let thresholdMin: Double = 0.003

        /// Amplitude du seuil RMS selon la sensibilite
        static let thresholdRange: Double = 0.022

        /// Gain applique au RMS brut pour compenser les micros faibles.
        static let inputLevelBoost: Float = 1.8

        /// Delai sans voix avant retour en silence (secondes)
        static let silenceDebounce: TimeInterval = 0.3

        /// Facteur de transition douce du defilement vocal
        static let scrollEasingFactor: CGFloat = 0.18

        /// Vitesse minimale consideree comme nulle en easing
        static let minVelocityFactor: CGFloat = 0.002

        /// Taille de buffer audio pour le tap micro
        static let bufferSize: UInt32 = 1024

        /// Hauteur max du beam vocal discret
        static let beamMaxHeight: CGFloat = 4
    }

    // MARK: - Notch

    enum Notch {
        /// Hauteur du notch physique (~32pt)
        static let physicalHeight: CGFloat = 32

        /// Largeur du prompteur (compact, juste un peu plus large que le notch)
        static let openWidth: CGFloat = 310

        /// Marge ajoutee autour de la largeur du notch detecte
        static let extraWidthPadding: CGFloat = 40

        /// Hauteur totale : notch (~32pt) + zone texte (~60pt) = ~92pt
        static let openHeight: CGFloat = 92

        /// Rayon des coins du haut (petits, coins du notch)
        static let topCornerRadius: CGFloat = 6

        /// Rayon des coins du bas (effet pilule)
        static let bottomCornerRadius: CGFloat = 12

        /// Padding horizontal interieur
        static let horizontalPadding: CGFloat = 10

        /// Padding bas interieur
        static let bottomPadding: CGFloat = 8
    }

    // MARK: - Floating Mode

    enum Floating {
        /// Largeur par defaut en mode fenetre flottante
        static let width: CGFloat = 500

        /// Hauteur par defaut en mode fenetre flottante
        static let height: CGFloat = 200

        /// Rayon des coins du mode fenetre flottante
        static let cornerRadius: CGFloat = 18
    }

    // MARK: - Window

    enum Window {
        /// Taille minimum de la fenetre editeur
        static let minSize = NSSize(width: 960, height: 640)

        /// Taille par defaut de la fenetre prompteur
        static let defaultSize = NSSize(width: 700, height: 450)

        /// Taille par defaut de la fenetre editeur
        static let editorSize = NSSize(width: 900, height: 650)
    }

    // MARK: - Colors

    enum Colors {
        /// Couleur de texte par defaut
        static let defaultTextColor: Color = .white

        /// Couleur de fond du prompteur
        static let prompterBackground: Color = .black

        /// Presets de couleurs
        static let presets: [(name: String, color: Color)] = [
            ("White", .white),
            ("Green", Color(red: 0, green: 1, blue: 0.255)),   // #00FF41 Matrix green
            ("Yellow", .yellow),
            ("Cyan", .cyan),
            ("Pink", Color(red: 1, green: 0.412, blue: 0.706)), // #FF69B4
        ]
    }

    // MARK: - Reading Speed

    enum Reading {
        /// Mots par minute pour l'estimation de duree
        static let wordsPerMinute: Double = 150
    }
}

// MARK: - Notion Theme

/// Couleurs adaptatives fideles au design system Notion.
/// Light : sidebar #F7F7F5, content #FFFFFF, text #37352F
/// Dark  : sidebar #252525, content #191919, text white 90%
enum NotionTheme {

    // MARK: Backgrounds

    /// Sidebar — off-white chaud (light) / gris fonce (dark)
    static let sidebar = adaptiveColor(
        light: (0.969, 0.969, 0.961, 1),  // #F7F7F5
        dark:  (0.145, 0.145, 0.145, 1)   // #252525
    )

    /// Zone de contenu — blanc pur (light) / quasi-noir (dark)
    static let content = adaptiveColor(
        light: (1, 1, 1, 1),              // #FFFFFF
        dark:  (0.098, 0.098, 0.098, 1)   // #191919
    )

    // MARK: Text

    /// Texte principal — brun chaud (light) / blanc 90% (dark)
    static let text = adaptiveColor(
        light: (0.216, 0.208, 0.184, 1),  // #37352F
        dark:  (1, 1, 1, 0.9)
    )

    /// Texte secondaire — gris moyen
    static let secondaryText = adaptiveColor(
        light: (0.608, 0.604, 0.592, 1),  // #9B9A97
        dark:  (0.592, 0.604, 0.608, 0.65)
    )

    /// Texte tertiaire — gris clair
    static let tertiaryText = adaptiveColor(
        light: (0.608, 0.604, 0.592, 0.6),
        dark:  (0.592, 0.604, 0.608, 0.4)
    )

    // MARK: Interactive

    /// Fond de survol — noir/blanc a 4%
    static let hover = adaptiveColor(
        light: (0, 0, 0, 0.04),
        dark:  (1, 1, 1, 0.04)
    )

    /// Fond de selection — noir/blanc a 6%
    static let selected = adaptiveColor(
        light: (0, 0, 0, 0.06),
        dark:  (1, 1, 1, 0.055)
    )

    // MARK: Dividers

    /// Separateur sidebar/content
    static let divider = adaptiveColor(
        light: (0.922, 0.922, 0.918, 1),  // #EBEBEA
        dark:  (1, 1, 1, 0.06)
    )

    /// Separateur interne subtil
    static let subtleDivider = adaptiveColor(
        light: (0, 0, 0, 0.04),
        dark:  (1, 1, 1, 0.04)
    )

    // MARK: Accent

    /// Bleu Notion
    static let accent = adaptiveColor(
        light: (0.043, 0.431, 0.6, 1),    // #0B6E99
        dark:  (0.322, 0.612, 0.792, 1)   // #529CCA
    )

    /// Orange favori
    static let orange = adaptiveColor(
        light: (0.851, 0.451, 0.051, 1),  // #D9730D
        dark:  (1, 0.639, 0.267, 1)       // #FFA344
    )

    // MARK: Private

    private static func adaptiveColor(
        light: (CGFloat, CGFloat, CGFloat, CGFloat),
        dark: (CGFloat, CGFloat, CGFloat, CGFloat)
    ) -> Color {
        Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            let c = isDark ? dark : light
            return NSColor(srgbRed: c.0, green: c.1, blue: c.2, alpha: c.3)
        }))
    }
}
