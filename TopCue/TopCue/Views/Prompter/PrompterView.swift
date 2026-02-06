//
//  PrompterView.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI

/// Vue du teleprompter qui s'integre visuellement dans le notch MacBook.
struct PrompterView: View {

    @Bindable var state: PrompterState
    let onToggleInvisibility: () -> Void

    @State private var scrollController: ScrollController?
    @State private var isHovering = false
    @State private var visibilityBadgeText: String?
    @State private var isVisibilityBadgeVisible = false

    @AppStorage("prompterFontSize") private var fontSize: Double = Constants.Prompter.defaultFontSize
    @AppStorage("textColorHex") private var textColorHex: String = "#FFFFFF"

    var body: some View {
        Color.clear
            .overlay(alignment: .top) {
                prompterSurface
            }
            .onAppear {
                startScrollingIfNeeded()
            }
            .onDisappear {
                stopScrolling()
            }
            .onChange(of: state.isInvisible) { _, _ in
                showVisibilityBadge()
            }
    }

    // MARK: - Surface

    private var prompterSurface: some View {
        ZStack(alignment: .top) {
            scrollingContent

            if isVisibilityBadgeVisible,
               let visibilityBadgeText {
                visibilityBadge(text: visibilityBadgeText)
            }

            if isHovering {
                controlsOverlay
            }
        }
        .frame(width: state.panelSize.width, height: state.panelSize.height)
        .background(.black)
        .clipShape(surfaceShape)
        .onHover { isHovered in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = isHovered
            }

            if isHovered {
                state.hoverPause()
            } else {
                state.hoverResume()
            }
        }
    }

    private var surfaceShape: AnyShape {
        if state.isFloatingMode {
            return AnyShape(RoundedRectangle(cornerRadius: Constants.Floating.cornerRadius, style: .continuous))
        }

        return AnyShape(
            NotchShape(
                topCornerRadius: Constants.Notch.topCornerRadius,
                bottomCornerRadius: Constants.Notch.bottomCornerRadius
            )
        )
    }

    // MARK: - Content

    private var scrollingContent: some View {
        ZStack(alignment: .top) {
            if let script = state.currentScript {
                ScrollView(.vertical, showsIndicators: false) {
                    Text(script.content)
                        .font(.system(size: fontSize, weight: .medium, design: .monospaced))
                        .foregroundStyle(textColor)
                        .lineSpacing(4)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, horizontalTextPadding)
                        .padding(.top, textTopInset)
                        .padding(.bottom, 200)
                        .frame(maxWidth: .infinity)
                        .offset(y: -state.scrollOffset)
                }
                .scrollDisabled(true)
                .mask(textFadeMask)
            } else {
                Text("Aucun script")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.top, textTopInset)
            }
        }
    }

    private var horizontalTextPadding: CGFloat {
        if state.isFloatingMode {
            return 20
        }

        return Constants.Notch.topCornerRadius + Constants.Notch.bottomCornerRadius + 8
    }

    private var textTopInset: CGFloat {
        if state.isFloatingMode {
            return 14
        }

        return state.detectedNotchHeight + 4
    }

    private var textFadeMask: some View {
        Group {
            if state.isFloatingMode {
                Color.white
            } else {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: state.detectedNotchHeight)

                    LinearGradient(
                        colors: [.clear, .white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 6)

                    Color.white

                    LinearGradient(
                        colors: [.white, .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: Constants.Notch.bottomCornerRadius + 4)
                }
            }
        }
    }

    // MARK: - Controls

    private var controlsOverlay: some View {
        VStack(spacing: 4) {
            if shouldShowNoNotchHint {
                Text("Notch non detecte")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.black.opacity(0.7))
                    .clipShape(Capsule())
            }

            Spacer()

            HStack(spacing: 6) {
                restartButton
                playPauseButton
                controlDivider
                speedControls
                controlDivider
                zoomControls
                controlDivider
                visibilityButton
            }
            .foregroundStyle(.white)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(.black)
            .clipShape(Capsule())
            .padding(.bottom, 6)
        }
        .transition(.opacity)
    }

    private var shouldShowNoNotchHint: Bool {
        !state.hasDetectedNotch && !state.isFloatingMode
    }

    private var restartButton: some View {
        Button { state.restart() } label: {
            Image(systemName: "backward.end.fill")
                .font(.caption)
        }
        .buttonStyle(.plain)
        .help("Recommencer")
    }

    private var playPauseButton: some View {
        Button { state.togglePlayPause() } label: {
            Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                .font(.caption)
        }
        .buttonStyle(.plain)
        .help("Lecture / pause")
    }

    private var speedControls: some View {
        HStack(spacing: 6) {
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
        }
    }

    private var zoomControls: some View {
        HStack(spacing: 6) {
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
    }

    private var visibilityButton: some View {
        Button {
            onToggleInvisibility()
        } label: {
            Image(systemName: state.isInvisible ? "lock.fill" : "lock.open.fill")
                .font(.caption2)
        }
        .buttonStyle(.plain)
        .help(state.isInvisible ? "Invisible au partage" : "Visible au partage")
    }

    private var controlDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.25))
            .frame(width: 1, height: 12)
    }

    // MARK: - Badge

    private func visibilityBadge(text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.black.opacity(0.8))
            .overlay(
                Capsule()
                    .stroke(.white.opacity(0.35), lineWidth: 1)
            )
            .clipShape(Capsule())
            .padding(.top, state.isFloatingMode ? 8 : state.detectedNotchHeight + 6)
            .transition(.opacity)
    }

    private func showVisibilityBadge() {
        visibilityBadgeText = state.isInvisible ? "Invisible" : "Visible"

        withAnimation(.easeOut(duration: 0.15)) {
            isVisibilityBadgeVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.easeIn(duration: 0.2)) {
                isVisibilityBadgeVisible = false
            }
        }
    }

    // MARK: - Scrolling

    private func startScrollingIfNeeded() {
        let controller = ScrollController(state: state)
        scrollController = controller
        controller.start()
    }

    private func stopScrolling() {
        scrollController?.stop()
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
