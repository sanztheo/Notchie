//
//  TopCueApp.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI
import SwiftData

@main
struct TopCueApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var windowManager = WindowManager()

    var body: some Scene {
        WindowGroup {
            EditorView(windowManager: windowManager)
                .frame(
                    minWidth: Constants.Window.minSize.width,
                    minHeight: Constants.Window.minSize.height
                )
        }
        .modelContainer(for: Script.self)
        .commands {
            // Menu Presentation
            CommandMenu("Presentation") {
                Button("Demarrer / Pause") {
                    windowManager.prompterState.togglePlayPause()
                }
                .keyboardShortcut(.space, modifiers: .command)

                Divider()

                Button("Augmenter vitesse") {
                    windowManager.prompterState.increaseSpeed()
                }
                .keyboardShortcut(.upArrow, modifiers: .command)

                Button("Diminuer vitesse") {
                    windowManager.prompterState.decreaseSpeed()
                }
                .keyboardShortcut(.downArrow, modifiers: .command)

                Divider()

                Button(
                    windowManager.prompterState.isFloatingMode
                        ? "Mode Notch"
                        : "Mode Flottant"
                ) {
                    windowManager.toggleMode()
                }
                .keyboardShortcut("p", modifiers: [.command, .shift])

                Button(
                    windowManager.prompterState.isInvisible
                        ? "Rendre visible au partage"
                        : "Rendre invisible au partage"
                ) {
                    windowManager.toggleInvisibility()
                }
                .keyboardShortcut("i", modifiers: [.command, .shift])

                Divider()

                Button("Fermer prompteur") {
                    windowManager.hidePrompter()
                }
                .keyboardShortcut("w", modifiers: [.command, .shift])
            }
        }
    }
}
