//
//  WindowManager.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import AppKit
import AVFoundation
import SwiftUI

nonisolated private func makeVoiceLevelHandler(voiceDetector: VoiceDetector) -> AudioEngine.LevelHandler {
    return { level in
        Task { @MainActor in
            voiceDetector.consume(level: level)
        }
    }
}

/// Gere la creation et la configuration de la fenetre flottante du prompteur.
@MainActor
@Observable
final class WindowManager {

    private enum StorageKey {
        static let floatingPanelFrame = "floatingPanelFrame"
    }

    @ObservationIgnored
    private let defaults = UserDefaults.standard

    /// La fenetre flottante du prompteur.
    private var panel: FloatingPanel?

    /// Observateurs lies au cycle de vie du panel.
    private var panelObservers: [NSObjectProtocol] = []

    /// Observateurs globaux (changement de configuration ecrans).
    private var appObservers: [NSObjectProtocol] = []

    /// Etat partage du prompteur.
    let prompterState = PrompterState()

    /// Detecteur vocal partage avec la vue.
    let voiceDetector = VoiceDetector()

    @ObservationIgnored
    private let audioEngine = AudioEngine()

    @ObservationIgnored
    private var voiceSignalProbeTask: Task<Void, Never>?

    /// La fenetre est-elle actuellement affichee.
    var isPanelVisible: Bool {
        panel?.isVisible ?? false
    }

    private var floatingPanelFrameStorage: String {
        get {
            defaults.string(forKey: StorageKey.floatingPanelFrame) ?? ""
        }
        set {
            defaults.set(newValue, forKey: StorageKey.floatingPanelFrame)
        }
    }

    init() {
        configureAudioPipeline()
    }

    @MainActor
    deinit {
        stopVoiceMode()
        removeObservers()
    }

    // MARK: - Actions

    /// Ouvre la fenetre du prompteur avec le script donne.
    func showPrompter(script: Script) {
        prompterState.currentScript = script
        prompterState.scrollOffset = 0

        if panel == nil {
            createPanel()
        }

        guard let panel else { return }

        applyPanelConfiguration(panel: panel)
        panel.makeKeyAndOrderFront(nil)
        prompterState.isWindowVisible = true
        prompterState.play()
        synchronizeVoiceModeState()
    }

    /// Ferme la fenetre du prompteur.
    func hidePrompter() {
        prompterState.stop()
        prompterState.isWindowVisible = false
        stopVoiceMode()
        panel?.orderOut(nil)
    }

    /// Change le mode d'affichage entre notch et floating.
    func toggleMode() {
        if prompterState.isFloatingMode {
            saveFloatingFrameIfNeeded()
        }

        prompterState.toggleMode()

        guard let panel else { return }
        applyPanelConfiguration(panel: panel)
    }

    /// Bascule la visibilite dans le partage d'ecran.
    func toggleInvisibility() {
        prompterState.toggleInvisibility()
        guard let panel else { return }
        applySharingVisibility(panel: panel)
    }

    /// Active ou desactive le mode voix.
    func toggleVoiceMode() {
        if prompterState.voiceModeEnabled {
            prompterState.setVoiceModeEnabled(false)
            stopVoiceMode()
            return
        }

        Task { @MainActor [weak self] in
            await self?.enableVoiceMode()
        }
    }

    // MARK: - Panel Lifecycle

    private func createPanel() {
        let panel = FloatingPanel()

        let prompterView = PrompterView(
            state: prompterState,
            voiceDetector: voiceDetector,
            onToggleInvisibility: { [weak self] in
                self?.toggleInvisibility()
            },
            onToggleVoiceMode: { [weak self] in
                self?.toggleVoiceMode()
            }
        )
        let hostingView = NSHostingView(rootView: prompterView)
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor

        panel.contentView = hostingView
        self.panel = panel

        registerPanelObservers(panel: panel)
        registerScreenParametersObserver()

        applyPanelConfiguration(panel: panel)
    }

    // MARK: - Voice

    private func configureAudioPipeline() {
        audioEngine.onLevel = makeVoiceLevelHandler(voiceDetector: voiceDetector)
    }

    private func synchronizeVoiceModeState() {
        guard prompterState.voiceModeEnabled else { return }

        Task { @MainActor [weak self] in
            await self?.enableVoiceMode()
        }
    }

    private func enableVoiceMode() async {
#if DEBUG
        print("[VoiceDebug] WindowManager.enableVoiceMode requested")
#endif
        let isAllowed = await ensureMicrophonePermission()
        guard isAllowed else {
            prompterState.setVoiceModeEnabled(false)
            stopVoiceMode()
            return
        }

        do {
            try audioEngine.start()
            prompterState.setVoiceModeEnabled(true)
            if prompterState.isWindowVisible {
                prompterState.play()
            }
            voiceDetector.setMicrophonePermissionMessage(nil)
            startVoiceSignalProbe()
#if DEBUG
            print("[VoiceDebug] WindowManager.enableVoiceMode started")
#endif
        } catch {
            prompterState.setVoiceModeEnabled(false)
            voiceDetector.setMicrophonePermissionMessage("Microphone indisponible")
            stopVoiceMode()
#if DEBUG
            print("[VoiceDebug] WindowManager.enableVoiceMode failed error=\(error)")
#endif
        }
    }

    private func stopVoiceMode() {
#if DEBUG
        print("[VoiceDebug] WindowManager.stopVoiceMode")
#endif
        voiceSignalProbeTask?.cancel()
        voiceSignalProbeTask = nil
        audioEngine.stop()
        voiceDetector.reset()
    }

    private func startVoiceSignalProbe() {
        voiceSignalProbeTask?.cancel()

        voiceSignalProbeTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard let self else { return }
            guard self.prompterState.voiceModeEnabled else { return }
            guard self.voiceDetector.microphonePermissionMessage == nil else { return }

            if !self.voiceDetector.hasReceivedSamples {
                self.voiceDetector.setMicrophonePermissionMessage(
                    "Aucun flux micro. Verifiez Reglages Systeme > Son > Entree."
                )
#if DEBUG
                print("[VoiceDebug] Probe: aucun sample recu")
#endif
                return
            }

            let minimumUsefulLevel = self.voiceDetector.threshold * 0.6
            if self.voiceDetector.peakAudioLevel < minimumUsefulLevel {
                self.voiceDetector.setMicrophonePermissionMessage(
                    "Signal micro faible. Montez l'entree ou baissez la sensibilite."
                )
#if DEBUG
                print(
                    "[VoiceDebug] Probe: signal faible peak=\(self.voiceDetector.peakAudioLevel) " +
                    "minimum=\(minimumUsefulLevel)"
                )
#endif
            }
        }
    }

    private func ensureMicrophonePermission() async -> Bool {
        let status = AVAudioApplication.shared.recordPermission

#if DEBUG
        print("[VoiceDebug] Permission status=\(status.rawValue)")
#endif

        switch status {
        case .granted:
            voiceDetector.setMicrophonePermissionMessage(nil)
            return true
        case .undetermined:
            let granted = await requestMicrophoneAccess()
            let message = granted ? nil : "Acces micro refuse. Ouvrez Reglages Systeme."
            voiceDetector.setMicrophonePermissionMessage(message)
            return granted
        case .denied:
            voiceDetector.setMicrophonePermissionMessage("Autorisez le micro dans Reglages Systeme.")
            return false
        @unknown default:
            voiceDetector.setMicrophonePermissionMessage("Etat de permission micro inconnu.")
            return false
        }
    }

    private func requestMicrophoneAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    private func applyPanelConfiguration(panel: FloatingPanel) {
        if prompterState.isFloatingMode {
            configureFloatingMode(panel: panel)
        } else {
            configureNotchMode(panel: panel)
        }

        applySharingVisibility(panel: panel)
    }

    private func configureNotchMode(panel: FloatingPanel) {
        panel.configureForNotchMode()
        positionAtNotch(panel: panel)
    }

    private func configureFloatingMode(panel: FloatingPanel) {
        panel.configureForFloatingMode()

        if !restoreFloatingFrameIfAvailable(panel: panel) {
            positionAtDefaultFloatingLocation(panel: panel)
        }
    }

    private func applySharingVisibility(panel: FloatingPanel) {
        if prompterState.isInvisible {
            panel.configureInvisible()
        } else {
            panel.configureVisible()
        }
    }

    // MARK: - Positioning

    /// Positionne la fenetre en mode notch sur l'ecran possedant un notch,
    /// avec fallback sous la menu bar si aucun notch n'est detecte.
    private func positionAtNotch(panel: FloatingPanel) {
        guard let screen = targetScreen() else { return }

        let notchRect = screen.notchRect
        let panelWidth = notchPanelWidth(from: notchRect)
        let panelHeight = Constants.Notch.openHeight

        prompterState.hasDetectedNotch = notchRect != nil
        prompterState.detectedNotchHeight = notchRect?.height ?? Constants.Notch.physicalHeight
        prompterState.panelSize = CGSize(width: panelWidth, height: panelHeight)

        let originX = (notchRect?.midX ?? screen.frame.midX) - panelWidth / 2
        let originY = notchRect != nil
            ? screen.frame.maxY - panelHeight
            : screen.visibleFrame.maxY - panelHeight

        let frame = CGRect(
            x: clampedX(originX, width: panelWidth, in: screen),
            y: originY,
            width: panelWidth,
            height: panelHeight
        )

        panel.setFrame(frame, display: true)
    }

    private func positionAtDefaultFloatingLocation(panel: FloatingPanel) {
        guard let screen = targetScreen() else { return }

        let size = CGSize(width: Constants.Floating.width, height: Constants.Floating.height)
        let origin = CGPoint(
            x: screen.visibleFrame.midX - size.width / 2,
            y: screen.visibleFrame.midY - size.height / 2
        )

        panel.setFrame(CGRect(origin: origin, size: size), display: true)
        prompterState.panelSize = size
        saveFloatingFrameIfNeeded()
    }

    private func targetScreen() -> NSScreen? {
        if let notchScreen = NotchDetector.screenWithNotch() {
            return notchScreen
        }
        if let mainScreen = NSScreen.main {
            return mainScreen
        }
        return NSScreen.screens.first
    }

    private func notchPanelWidth(from notchRect: CGRect?) -> CGFloat {
        guard let notchRect else { return Constants.Notch.openWidth }

        let desiredWidth = notchRect.width + Constants.Notch.extraWidthPadding
        return max(desiredWidth, Constants.Notch.openWidth)
    }

    private func clampedX(_ x: CGFloat, width: CGFloat, in screen: NSScreen) -> CGFloat {
        let minX = screen.frame.minX
        let maxX = screen.frame.maxX - width
        guard maxX > minX else { return minX }
        return min(max(x, minX), maxX)
    }

    // MARK: - Floating Frame Persistence

    private func saveFloatingFrameIfNeeded() {
        guard prompterState.isFloatingMode,
              let panel else {
            return
        }

        floatingPanelFrameStorage = NSStringFromRect(panel.frame)
        prompterState.panelSize = panel.frame.size
    }

    private func restoreFloatingFrameIfAvailable(panel: FloatingPanel) -> Bool {
        guard let frame = decodedFloatingFrame() else { return false }

        panel.setFrame(frame, display: true)
        prompterState.panelSize = frame.size
        return true
    }

    private func decodedFloatingFrame() -> CGRect? {
        guard !floatingPanelFrameStorage.isEmpty else { return nil }

        let frame = NSRectFromString(floatingPanelFrameStorage)
        return normalizedFloatingFrame(frame)
    }

    private func normalizedFloatingFrame(_ frame: CGRect) -> CGRect? {
        guard frame.width > 0,
              frame.height > 0,
              let screen = bestScreen(for: frame) else {
            return nil
        }

        let visibleFrame = screen.visibleFrame
        let width = min(frame.width, visibleFrame.width)
        let height = min(frame.height, visibleFrame.height)

        let x = min(max(frame.origin.x, visibleFrame.minX), visibleFrame.maxX - width)
        let y = min(max(frame.origin.y, visibleFrame.minY), visibleFrame.maxY - height)

        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func bestScreen(for frame: CGRect) -> NSScreen? {
        let frameCenter = CGPoint(x: frame.midX, y: frame.midY)
        if let centeredScreen = NSScreen.screens.first(where: { $0.visibleFrame.contains(frameCenter) }) {
            return centeredScreen
        }

        let bestIntersectingScreen = NSScreen.screens
            .map { ($0, intersectionArea(between: $0.visibleFrame, and: frame)) }
            .max(by: { $0.1 < $1.1 })

        if let bestIntersectingScreen,
           bestIntersectingScreen.1 > 0 {
            return bestIntersectingScreen.0
        }

        return NSScreen.main ?? targetScreen() ?? NSScreen.screens.first
    }

    private func intersectionArea(between firstRect: CGRect, and secondRect: CGRect) -> CGFloat {
        let intersection = firstRect.intersection(secondRect)
        guard !intersection.isNull else { return 0 }
        return intersection.width * intersection.height
    }

    // MARK: - Notifications

    private func registerPanelObservers(panel: FloatingPanel) {
        let center = NotificationCenter.default

        let didMoveObserver = center.addObserver(
            forName: NSWindow.didMoveNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.saveFloatingFrameIfNeeded()
            }
        }

        let didResizeObserver = center.addObserver(
            forName: NSWindow.didResizeNotification,
            object: panel,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.saveFloatingFrameIfNeeded()
            }
        }

        panelObservers = [didMoveObserver, didResizeObserver]
    }

    private func registerScreenParametersObserver() {
        let center = NotificationCenter.default
        let observer = center.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleScreenConfigurationChange()
            }
        }

        appObservers = [observer]
    }

    private func handleScreenConfigurationChange() {
        guard let panel else { return }

        if prompterState.isFloatingMode {
            return
        }

        positionAtNotch(panel: panel)
    }

    private func removeObservers() {
        let center = NotificationCenter.default

        panelObservers.forEach { center.removeObserver($0) }
        panelObservers.removeAll()

        appObservers.forEach { center.removeObserver($0) }
        appObservers.removeAll()
    }

}
