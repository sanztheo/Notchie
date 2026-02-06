//
//  VoiceDetector.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import Foundation

/// Etats de detection vocale.
enum VoiceActivityState: Equatable {
    case speaking
    case silence
}

/// Transforme les niveaux RMS en etat vocal et metadonnees de visualisation.
nonisolated @Observable
final class VoiceDetector {

    @ObservationIgnored
    private let defaults = UserDefaults.standard

    @ObservationIgnored
    private var silenceWorkItem: DispatchWorkItem?

    @ObservationIgnored
    private var debugSampleCounter = 0

    /// Etat vocal courant deduit des niveaux audio.
    private(set) var activityState: VoiceActivityState = .silence

    /// Niveau audio RMS courant (0.0 a 1.0).
    var audioLevel: Float = 0

    /// Indique si au moins un buffer audio a ete recu depuis le demarrage.
    private(set) var hasReceivedSamples: Bool = false

    /// Niveau maximum observe depuis le dernier reset.
    private(set) var peakAudioLevel: Float = 0

    /// Sensibilite utilisateur (0.0 = tres sensible, 1.0 = peu sensible).
    var sensitivity: Double = Constants.Voice.defaultSensitivity {
        didSet {
            persistSensitivityIfNeeded()
        }
    }

    /// Message associe a la permission micro (nil si tout est OK).
    var microphonePermissionMessage: String?

    /// Indique si une voix est detectee.
    var isSpeaking: Bool {
        activityState == .speaking
    }

    /// Seuil RMS derive de la sensibilite.
    var threshold: Float {
        Float(Constants.Voice.thresholdMin + (sensitivity * Constants.Voice.thresholdRange))
    }

    init() {
        restoreSensitivity()
    }

    // MARK: - Input

    /// Consomme un niveau RMS et met a jour speaking/silence avec debounce.
    /// - Parameter level: Niveau RMS normalise entre 0.0 et 1.0.
    func consume(level: Float) {
        let clampedLevel = min(max(level, 0), 1)
        debugSampleCounter += 1
        hasReceivedSamples = true
        audioLevel = clampedLevel
        peakAudioLevel = max(peakAudioLevel, clampedLevel)
        debugLogLevelIfNeeded(level: clampedLevel)

        if clampedLevel >= threshold {
            microphonePermissionMessage = nil
            handleSpeakingDetected()
            return
        }

        scheduleSilenceTransitionIfNeeded()
    }

    /// Reinitialise l'etat vocal et annule les transitions en attente.
    func reset() {
        silenceWorkItem?.cancel()
        silenceWorkItem = nil
        activityState = .silence
        audioLevel = 0
        hasReceivedSamples = false
        peakAudioLevel = 0
        debugSampleCounter = 0
    }

    /// Stocke un message de permission refusee pour l'affichage UI.
    /// - Parameter message: Texte utilisateur concis.
    func setMicrophonePermissionMessage(_ message: String?) {
        microphonePermissionMessage = message
    }

    // MARK: - Private

    private func handleSpeakingDetected() {
        silenceWorkItem?.cancel()
        silenceWorkItem = nil

        guard activityState != .speaking else { return }
        activityState = .speaking
        debugLog("state -> speaking (level=\(audioLevel), threshold=\(threshold))")
    }

    private func scheduleSilenceTransitionIfNeeded() {
        guard activityState == .speaking,
              silenceWorkItem == nil else {
            return
        }

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.activityState = .silence
            self.silenceWorkItem = nil
            self.debugLog("state -> silence (level=\(self.audioLevel), threshold=\(self.threshold))")
        }

        silenceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Voice.silenceDebounce, execute: workItem)
    }

    private func restoreSensitivity() {
        let stored = defaults.object(forKey: Constants.Voice.sensitivityKey) as? Double
        let value = stored ?? Constants.Voice.defaultSensitivity
        sensitivity = min(max(value, 0), 1)
    }

    private func persistSensitivityIfNeeded() {
        let clamped = min(max(sensitivity, 0), 1)

        guard clamped == sensitivity else {
            sensitivity = clamped
            return
        }

        defaults.set(clamped, forKey: Constants.Voice.sensitivityKey)
    }

    private func debugLogLevelIfNeeded(level: Float) {
        if debugSampleCounter == 1 {
            debugLog("first sample level=\(level), threshold=\(threshold)")
            return
        }

        guard debugSampleCounter % 120 == 0 else { return }
        debugLog(
            "samples=\(debugSampleCounter) level=\(level) peak=\(peakAudioLevel) " +
            "threshold=\(threshold) speaking=\(isSpeaking)"
        )
    }

    private func debugLog(_ message: String) {
#if DEBUG
        print("[VoiceDebug] VoiceDetector \(message)")
#endif
    }
}
