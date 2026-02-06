//
//  AudioEngine.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import AVFoundation
import Foundation

/// Fournit un flux de niveaux audio RMS a partir du microphone systeme.
final class AudioEngine {

    typealias LevelHandler = (Float) -> Void

    // MARK: - Properties

    /// Callback appelee a chaque buffer avec un niveau RMS entre 0.0 et 1.0.
    /// Le callback est execute sur la queue audio du tap (pas sur le MainActor).
    var onLevel: LevelHandler?

    /// Indique si le moteur audio est actif.
    var isRunning: Bool {
        engine.isRunning
    }

    private let engine = AVAudioEngine()
    private var isTapInstalled = false

    // MARK: - Control

    /// Demarre la capture micro et l'emission des niveaux RMS.
    /// - Throws: `AudioEngineError.microphoneUnavailable` si aucun canal d'entree n'est detecte.
    func start() throws {
        guard !engine.isRunning else { return }

        let inputNode = engine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        let levelHandler = onLevel
        let levelBoost = Constants.Voice.inputLevelBoost

        guard inputFormat.channelCount > 0 else {
            throw AudioEngineError.microphoneUnavailable
        }

        let tapFormat = preferredTapFormat(from: inputFormat)
        inputNode.removeTap(onBus: 0)

        inputNode.installTap(
            onBus: 0,
            bufferSize: AVAudioFrameCount(Constants.Voice.bufferSize),
            format: tapFormat
        ) { buffer, _ in
            let level = Self.computeRmsLevel(from: buffer, levelBoost: levelBoost)
            Self.emit(level: level, to: levelHandler)
        }

        isTapInstalled = true
        engine.prepare()
        try engine.start()
    }

    /// Arrete la capture micro et nettoie le tap audio.
    func stop() {
        guard engine.isRunning || isTapInstalled else { return }

        if isTapInstalled {
            engine.inputNode.removeTap(onBus: 0)
            isTapInstalled = false
        }

        engine.stop()
        engine.reset()
    }

    // MARK: - Private

    private func preferredTapFormat(from inputFormat: AVAudioFormat) -> AVAudioFormat {
        if let monoFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: inputFormat.sampleRate,
            channels: 1,
            interleaved: false
        ) {
            return monoFormat
        }

        return inputFormat
    }

    nonisolated private static func computeRmsLevel(
        from buffer: AVAudioPCMBuffer,
        levelBoost: Float
    ) -> Float {
        let frameLength = Int(buffer.frameLength)
        let channelCount = Int(buffer.format.channelCount)

        guard frameLength > 0, channelCount > 0 else { return 0 }

        if let channels = buffer.floatChannelData {
            let rms = rmsFromFloatBuffer(
                channels: channels,
                frameLength: frameLength,
                channelCount: channelCount,
                isInterleaved: buffer.format.isInterleaved
            )
            return min(max(rms * levelBoost, 0), 1)
        }

        if let channels = buffer.int16ChannelData {
            let rms = rmsFromInt16Buffer(
                channels: channels,
                frameLength: frameLength,
                channelCount: channelCount,
                isInterleaved: buffer.format.isInterleaved
            )
            return min(max(rms * levelBoost, 0), 1)
        }

        if let channels = buffer.int32ChannelData {
            let rms = rmsFromInt32Buffer(
                channels: channels,
                frameLength: frameLength,
                channelCount: channelCount,
                isInterleaved: buffer.format.isInterleaved
            )
            return min(max(rms * levelBoost, 0), 1)
        }

        return 0
    }

    nonisolated private static func emit(level: Float, to handler: LevelHandler?) {
        guard let handler else { return }
        let clampedLevel = min(max(level, 0), 1)
        handler(clampedLevel)
    }

    nonisolated private static func rmsFromFloatBuffer(
        channels: UnsafePointer<UnsafeMutablePointer<Float>>,
        frameLength: Int,
        channelCount: Int,
        isInterleaved: Bool
    ) -> Float {
        var squaredSum: Float = 0
        let sampleCount: Int

        if isInterleaved {
            let totalSamples = frameLength * channelCount
            let channelData = channels[0]

            for index in 0..<totalSamples {
                let sample = channelData[index]
                squaredSum += sample * sample
            }

            sampleCount = totalSamples
        } else {
            for channelIndex in 0..<channelCount {
                let channelData = channels[channelIndex]
                for frameIndex in 0..<frameLength {
                    let sample = channelData[frameIndex]
                    squaredSum += sample * sample
                }
            }

            sampleCount = frameLength * channelCount
        }

        guard sampleCount > 0 else { return 0 }
        return sqrt(squaredSum / Float(sampleCount))
    }

    nonisolated private static func rmsFromInt16Buffer(
        channels: UnsafePointer<UnsafeMutablePointer<Int16>>,
        frameLength: Int,
        channelCount: Int,
        isInterleaved: Bool
    ) -> Float {
        var squaredSum: Float = 0
        let sampleCount: Int
        let normalization: Float = 32768

        if isInterleaved {
            let totalSamples = frameLength * channelCount
            let channelData = channels[0]

            for index in 0..<totalSamples {
                let sample = Float(channelData[index]) / normalization
                squaredSum += sample * sample
            }

            sampleCount = totalSamples
        } else {
            for channelIndex in 0..<channelCount {
                let channelData = channels[channelIndex]
                for frameIndex in 0..<frameLength {
                    let sample = Float(channelData[frameIndex]) / normalization
                    squaredSum += sample * sample
                }
            }

            sampleCount = frameLength * channelCount
        }

        guard sampleCount > 0 else { return 0 }
        return sqrt(squaredSum / Float(sampleCount))
    }

    nonisolated private static func rmsFromInt32Buffer(
        channels: UnsafePointer<UnsafeMutablePointer<Int32>>,
        frameLength: Int,
        channelCount: Int,
        isInterleaved: Bool
    ) -> Float {
        var squaredSum: Float = 0
        let sampleCount: Int
        let normalization: Float = 2147483648

        if isInterleaved {
            let totalSamples = frameLength * channelCount
            let channelData = channels[0]

            for index in 0..<totalSamples {
                let sample = Float(channelData[index]) / normalization
                squaredSum += sample * sample
            }

            sampleCount = totalSamples
        } else {
            for channelIndex in 0..<channelCount {
                let channelData = channels[channelIndex]
                for frameIndex in 0..<frameLength {
                    let sample = Float(channelData[frameIndex]) / normalization
                    squaredSum += sample * sample
                }
            }

            sampleCount = frameLength * channelCount
        }

        guard sampleCount > 0 else { return 0 }
        return sqrt(squaredSum / Float(sampleCount))
    }
}

/// Erreurs liees au cycle de vie du moteur audio.
enum AudioEngineError: Error {
    case microphoneUnavailable
}
