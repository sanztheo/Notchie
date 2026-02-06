//
//  AppDelegate.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import AppKit

/// AppDelegate pour gerer le cycle de vie de l'app et les comportements AppKit.
final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // L'app ne doit pas apparaitre dans le Dock si on veut un mode discret (optionnel)
        // NSApp.setActivationPolicy(.accessory)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Ne pas quitter quand la fenetre principale est fermee
        // (le prompteur peut rester ouvert)
        return false
    }
}
