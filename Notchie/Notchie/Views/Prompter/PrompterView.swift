//
//  PrompterView.swift
//  Notchie
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
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
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
            HStack(spacing: 12) {
                Button { state.decreaseSpeed() } label: {
                    Image(systemName: "minus.circle.fill").font(.body)
                }
                .buttonStyle(.plain)

                Button { state.togglePlayPause() } label: {
                    Image(systemName: state.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)

                Button { state.increaseSpeed() } label: {
                    Image(systemName: "plus.circle.fill").font(.body)
                }
                .buttonStyle(.plain)

                Text(state.speedMultiplier)
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.white)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(.black.opacity(0.85))
            .clipShape(Capsule())
            .padding(.bottom, 6)
        }
        .transition(.opacity)
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
