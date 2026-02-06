//
//  NotionSettingsPopover+Sections.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI

extension NotionSettingsPopover {

    // MARK: - Sections

    var appearanceBlock: some View {
        settingsBlock(title: "Apparence", subtitle: "Personnalise le rendu du prompteur.") {
            settingsRow(title: "Mode") {
                modeButtons
            }

            settingsRow(title: "Taille du texte", description: "Ajuste la taille des lignes du script.") {
                Text("\(Int(fontSize)) pt")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(NotionTheme.secondaryText)
            }

            Slider(value: $fontSize, in: 14...72, step: 1)
                .tint(NotionTheme.accent)

            settingsRow(title: "Couleur du texte", description: "Presets rapides pour la lisibilite.") {
                colorPresets
            }
        }
    }

    var voiceBlock: some View {
        settingsBlock(title: "Mode voix", subtitle: "Le defilement suit votre prise de parole.") {
            settingsRow(title: "Activer le mode voix") {
                Toggle("", isOn: voiceModeBinding)
                    .labelsHidden()
                    .toggleStyle(.switch)
            }

            settingsRow(title: "Sensibilite micro", description: "0 = tres sensible, 1 = peu sensible") {
                Text(sensitivityLabel)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(NotionTheme.secondaryText)
            }

            Slider(value: $voiceDetector.sensitivity, in: 0...1, step: 0.01)
                .tint(NotionTheme.accent)

            settingsRow(title: "Etat detection") {
                statusBadge
            }

            audioMeter

            if let permissionMessage = voiceDetector.microphonePermissionMessage {
                Text(permissionMessage)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.orange.opacity(0.08))
                    )
            }
        }
    }

    var sharingBlock: some View {
        settingsBlock(title: "Partage", subtitle: "Controle la visibilite pendant le partage d'ecran.") {
            settingsRow(title: "Invisible pendant le partage") {
                Toggle("", isOn: invisibilityBinding)
                    .labelsHidden()
                    .toggleStyle(.switch)
            }

            Text("Masque la fenetre du prompteur dans les apps de conferencing qui respectent ce flag.")
                .font(.system(size: 12))
                .foregroundStyle(NotionTheme.secondaryText)
                .padding(.top, 2)
        }
    }

    var previewBlock: some View {
        settingsBlock(title: "Apercu echantillon", subtitle: "Le rendu se met a jour en temps reel.") {
            previewCanvas(height: 150)
        }
    }

    // MARK: - Blocks

    func settingsBlock<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(NotionTheme.text)

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(NotionTheme.secondaryText)
            }

            content()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(NotionTheme.sidebar.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(NotionTheme.subtleDivider, lineWidth: 1)
        )
    }

    func settingsRow<Control: View>(
        title: String,
        description: String? = nil,
        @ViewBuilder control: () -> Control
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(NotionTheme.text)

                if let description {
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundStyle(NotionTheme.tertiaryText)
                }
            }

            Spacer(minLength: 12)
            control()
        }
        .padding(.vertical, 2)
    }

    // MARK: - Components

    var modeButtons: some View {
        HStack(spacing: 6) {
            modeButton(title: "Notch", isSelected: !state.isFloatingMode) {
                guard state.isFloatingMode else { return }
                onToggleMode()
            }

            modeButton(title: "Floating", isSelected: state.isFloatingMode) {
                guard !state.isFloatingMode else { return }
                onToggleMode()
            }
        }
    }

    func modeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(isSelected ? .white : NotionTheme.secondaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(isSelected ? NotionTheme.accent : NotionTheme.hover)
                )
        }
        .buttonStyle(.plain)
    }

    var colorPresets: some View {
        HStack(spacing: 7) {
            ForEach(presetColors, id: \.hex) { preset in
                Button {
                    textColorHex = preset.hex
                } label: {
                    Circle()
                        .fill(color(forHex: preset.hex))
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(borderColor(for: preset.hex), lineWidth: 1)
                        )
                        .overlay {
                            if textColorHex == preset.hex {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(checkmarkColor(for: preset.hex))
                            }
                        }
                }
                .buttonStyle(.plain)
                .help(preset.name)
            }
        }
    }

    var statusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(voiceDetector.isSpeaking ? .green : NotionTheme.secondaryText.opacity(0.4))
                .frame(width: 7, height: 7)

            Text(voiceDetector.isSpeaking ? "Speaking" : "Silence")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(voiceDetector.isSpeaking ? .green : NotionTheme.secondaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule(style: .continuous)
                .fill(NotionTheme.hover)
        )
    }

    var audioMeter: some View {
        ZStack(alignment: .leading) {
            Capsule(style: .continuous)
                .fill(NotionTheme.hover)
                .frame(height: 8)

            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: max(6, 320 * currentAudioLevel), height: 8)
                .animation(.easeOut(duration: 0.1), value: currentAudioLevel)
        }
        .frame(width: 320, alignment: .leading)
    }

    func previewCanvas(height: CGFloat) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color.black.opacity(0.94), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                if !state.isFloatingMode {
                    Color.clear.frame(height: 16)
                }

                Text("TopCue garde vos yeux pres de la camera")
                    .font(previewFont)
                    .foregroundStyle(color(forHex: textColorHex))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if state.voiceModeEnabled {
                    VoiceBeamView(audioLevel: Float(currentAudioLevel))
                        .padding(.bottom, 6)
                }
            }
        }
        .frame(height: height)
        .clipShape(previewShape)
        .overlay(
            previewShape
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Computed

    var voiceModeBinding: Binding<Bool> {
        Binding(
            get: { state.voiceModeEnabled },
            set: { newValue in
                guard newValue != state.voiceModeEnabled else { return }
                onToggleVoiceMode()
            }
        )
    }

    var invisibilityBinding: Binding<Bool> {
        Binding(
            get: { state.isInvisible },
            set: { newValue in
                guard newValue != state.isInvisible else { return }
                onToggleInvisibility()
            }
        )
    }

    var sensitivityLabel: String {
        switch voiceDetector.sensitivity {
        case 0..<0.33:
            return "Elevee"
        case 0.33..<0.66:
            return "Moyenne"
        default:
            return "Faible"
        }
    }

    var currentAudioLevel: CGFloat {
        let detectorLevel = CGFloat(voiceDetector.audioLevel)

        guard state.voiceModeEnabled else {
            return max(detectorLevel, 0.08)
        }

        return min(max(detectorLevel, 0), 1)
    }

    var previewFont: Font {
        let size = min(max(fontSize * 0.58, 12), 25)
        return .system(size: size, weight: .medium, design: .monospaced)
    }

    var previewShape: AnyShape {
        if state.isFloatingMode {
            return AnyShape(
                RoundedRectangle(cornerRadius: Constants.Floating.cornerRadius, style: .continuous)
            )
        }

        return AnyShape(
            NotchShape(
                topCornerRadius: Constants.Notch.topCornerRadius,
                bottomCornerRadius: Constants.Notch.bottomCornerRadius
            )
        )
    }

    // MARK: - Colors

    func borderColor(for hex: String) -> Color {
        if textColorHex == hex {
            return NotionTheme.accent
        }

        return NotionTheme.subtleDivider
    }

    func checkmarkColor(for hex: String) -> Color {
        if hex == "#FFFFFF" || hex == "#FFFF00" {
            return .black.opacity(0.75)
        }

        return .white
    }

    func color(forHex hex: String) -> Color {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        value = value.replacingOccurrences(of: "#", with: "")

        guard value.count == 6,
              let rgb = UInt64(value, radix: 16) else {
            return .white
        }

        return Color(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}
