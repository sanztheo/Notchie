//
//  PrompterView.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI

/// Vue du teleprompter qui s'integre visuellement dans le notch MacBook.
///
/// Architecture :
/// - La fenetre (FloatingPanel) est 100% transparente
/// - Le contenu est un ZStack noir clippe avec NotchShape
/// - Le noir du contenu fusionne avec le noir du notch physique
/// - Effet : le texte semble "sortir" du notch
struct PrompterView: View {

    @Bindable var state: PrompterState

    @State private var scrollController: ScrollController?
    @State private var isHovering = false

    @AppStorage("prompterFontSize") private var fontSize: Double = Constants.Prompter.defaultFontSize
    @AppStorage("textColorHex") private var textColorHex: String = "#FFFFFF"

    var body: some View {
        // Fond completement transparent (laisse voir le bureau)
        Color.clear
            .overlay(alignment: .top) {
                notchContent
            }
            .onAppear {
                let controller = ScrollController(state: state)
                scrollController = controller
                controller.start()
            }
            .onDisappear {
                scrollController?.stop()
            }
    }

    // MARK: - Notch Content

    /// Le contenu noir qui fusionne avec le notch physique
    private var notchContent: some View {
        ZStack(alignment: .top) {
            // Texte defilant - commence juste sous la zone du notch physique
            if let script = state.currentScript {
                ScrollView(.vertical, showsIndicators: false) {
                    Text(script.content)
                        .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                        .foregroundStyle(textColor)
                        .lineSpacing(4)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.top, Constants.Notch.physicalHeight + 4)
                        .padding(.bottom, 200)
                        .frame(maxWidth: .infinity)
                        .offset(y: -state.scrollOffset)
                }
                .scrollDisabled(true)
            } else {
                Text("Aucun script")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.top, Constants.Notch.physicalHeight + 8)
            }

            // Controles compacts au hover
            if isHovering {
                controlsOverlay
            }
        }
        .frame(
            width: Constants.Notch.openWidth,
            height: Constants.Notch.openHeight
        )
        .background(.black)
        .clipShape(NotchShape())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
            // Pause/resume le defilement au survol
            if hovering {
                state.hoverPause()
            } else {
                state.hoverResume()
            }
        }
    }

    // MARK: - Controls Overlay

    private var controlsOverlay: some View {
        VStack {
            Spacer()
            HStack(spacing: 6) {

                // --- Recommencer ---
                Button { state.restart() } label: {
                    Image(systemName: "backward.end.fill")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .help("Recommencer")

                // --- Play / Pause ---
                Button { state.togglePlayPause() } label: {
                    Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                        .font(.caption)
                }
                .buttonStyle(.plain)

                controlDivider

                // --- Vitesse : tortue / lievre ---
                Button { state.decreaseSpeed() } label: {
                    Image(systemName: "tortoise.fill")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
                .help("Ralentir")

                Text(state.speedMultiplier)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)

                Button { state.increaseSpeed() } label: {
                    Image(systemName: "hare.fill")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
                .help("Accelerer")

                controlDivider

                // --- Zoom texte ---
                Button { zoomOut() } label: {
                    Image(systemName: "textformat.size.smaller")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
                .help("Reduire le texte")

                Button { zoomIn() } label: {
                    Image(systemName: "textformat.size.larger")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
                .help("Agrandir le texte")
            }
            .foregroundStyle(.white)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(.black.opacity(0.85))
            .clipShape(Capsule())
            .padding(.bottom, 6)
        }
        .transition(.opacity)
    }

    /// Separateur visuel entre groupes de controles
    private var controlDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.25))
            .frame(width: 1, height: 12)
    }

    // MARK: - Zoom

    private func zoomIn() {
        fontSize = min(fontSize + 2, Constants.Prompter.maxFontSize)
    }

    private func zoomOut() {
        fontSize = max(fontSize - 2, Constants.Prompter.minFontSize)
    }

    // MARK: - Helpers

    private var textColor: Color {
        Color(hex: textColorHex) ?? Constants.Colors.defaultTextColor
    }
}

// MARK: - Color hex extension

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard hexSanitized.count == 6,
              let rgb = UInt64(hexSanitized, radix: 16) else {
            return nil
        }

        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}
