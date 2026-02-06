//
//  NotionSettingsPopover.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI

/// Panneau de reglages style Notion avec configuration directe.
struct NotionSettingsPopover: View {

    // MARK: - Properties

    @Environment(\.dismiss) var dismiss

    @Bindable var state: PrompterState
    @Bindable var voiceDetector: VoiceDetector

    let onToggleMode: () -> Void
    let onToggleInvisibility: () -> Void
    let onToggleVoiceMode: () -> Void

    @AppStorage("prompterFontSize") var fontSize: Double = Constants.Prompter.defaultFontSize
    @AppStorage("textColorHex") var textColorHex: String = "#FFFFFF"

    let presetColors: [(name: String, hex: String)] = [
        ("White", "#FFFFFF"),
        ("Green", "#00FF41"),
        ("Yellow", "#FFFF00"),
        ("Cyan", "#00FFFF"),
        ("Pink", "#FF69B4"),
    ]

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider().overlay(NotionTheme.subtleDivider)
            content
        }
        .frame(width: 900, height: 560)
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(NotionTheme.subtleDivider, lineWidth: 1)
        )
    }

    // MARK: - Layout

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Account")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(NotionTheme.tertiaryText)
                .textCase(.uppercase)
                .tracking(0.3)

            accountRow

            Divider().overlay(NotionTheme.subtleDivider)

            VStack(spacing: 3) {
                sidebarRow(icon: "slider.horizontal.3", title: "Preferences", isActive: true)
                sidebarRow(icon: "mic.fill", title: "Voice", isActive: false)
                sidebarRow(icon: "rectangle.on.rectangle", title: "Sharing", isActive: false)
                sidebarRow(icon: "eye", title: "Preview", isActive: false)
            }

            Spacer()

            Text("TopCue")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(NotionTheme.tertiaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .frame(width: 220)
        .background(NotionTheme.sidebar)
    }

    private var accountRow: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(NotionTheme.accent.opacity(0.22))
                .frame(width: 26, height: 26)
                .overlay {
                    Text("S")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(NotionTheme.accent)
                }

            VStack(alignment: .leading, spacing: 1) {
                Text("The Sanz")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(NotionTheme.text)
                Text("Workspace")
                    .font(.system(size: 11))
                    .foregroundStyle(NotionTheme.tertiaryText)
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(NotionTheme.selected)
        )
    }

    private func sidebarRow(icon: String, title: String, isActive: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .frame(width: 16)

            Text(title)
                .font(.system(size: 13, weight: .medium))

            Spacer(minLength: 0)
        }
        .foregroundStyle(isActive ? NotionTheme.text : NotionTheme.secondaryText)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isActive ? NotionTheme.selected : .clear)
        )
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            contentHeader
            Divider().overlay(NotionTheme.subtleDivider)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    appearanceBlock
                    voiceBlock
                    sharingBlock
                    previewBlock
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NotionTheme.content)
    }

    private var contentHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Preferences")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(NotionTheme.text)

                Text("Configure TopCue directement depuis ce panneau.")
                    .font(.system(size: 13))
                    .foregroundStyle(NotionTheme.secondaryText)
            }

            Spacer(minLength: 12)

            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(NotionTheme.secondaryText)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(NotionTheme.hover)
                    )
            }
            .buttonStyle(.plain)
            .help("Fermer")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    // MARK: - Computed

    var panelBackground: some View {
        LinearGradient(
            colors: [NotionTheme.sidebar, NotionTheme.content],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview("Notion Settings") {
    let state = PrompterState()
    let detector = VoiceDetector()

    NotionSettingsPopover(
        state: state,
        voiceDetector: detector,
        onToggleMode: { state.toggleMode() },
        onToggleInvisibility: { state.toggleInvisibility() },
        onToggleVoiceMode: { state.toggleVoiceMode() }
    )
    .padding(24)
    .background(Color.black)
    .preferredColorScheme(.dark)
}
