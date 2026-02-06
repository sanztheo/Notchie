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
                    minWidth: Constants.Window.editorSize.width * 0.6,
                    minHeight: Constants.Window.editorSize.height * 0.5
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

                Button("Fermer prompteur") {
                    windowManager.hidePrompter()
                }
                .keyboardShortcut("w", modifiers: [.command, .shift])
            }
        }
    }
}
