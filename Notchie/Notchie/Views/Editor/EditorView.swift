//
//  EditorView.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI
import SwiftData

/// Vue principale de l'editeur : sidebar + editeur de texte.
/// Title bar transparent integree, toggle sidebar Cmd+S, design Notion.
struct EditorView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var selectedScript: Script?
    @State private var isSidebarVisible = true

    var windowManager: WindowManager

    var body: some View {
        HStack(spacing: 0) {
            if isSidebarVisible {
                ScriptListView(
                    selectedScript: $selectedScript,
                    isSidebarVisible: $isSidebarVisible
                )
                .frame(width: 260)
                .transition(.move(edge: .leading))

                Rectangle()
                    .fill(NotionTheme.divider)
                    .frame(width: 1)
            }

            Group {
                if let selectedScript {
                    EditorDetailView(
                        script: selectedScript,
                        windowManager: windowManager,
                        isSidebarVisible: $isSidebarVisible
                    )
                } else {
                    EmptyEditorView(
                        isSidebarVisible: $isSidebarVisible,
                        onCreate: createScript
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { NotionTheme.content.ignoresSafeArea() }
        }
        .background { WindowAccessor() }
        .overlay {
            Button("", action: toggleSidebar)
                .keyboardShortcut("s")
                .opacity(0)
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
        }
    }

    private func toggleSidebar() {
        withAnimation(.spring(duration: 0.25, bounce: 0)) {
            isSidebarVisible.toggle()
        }
    }

    private func createScript() {
        withAnimation(.snappy(duration: 0.3)) {
            let script = Script(title: "", content: "")
            modelContext.insert(script)
            selectedScript = script
        }
    }
}

// MARK: - Window Accessor

/// Configure la fenetre : title bar transparent, pas de titre, contenu plein cadre.
private struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        DispatchQueue.main.async {
            guard let window = nsView.window else { return }
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.styleMask.insert(.fullSizeContentView)
        }
        return nsView
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

// MARK: - Empty State

private struct EmptyEditorView: View {

    @Binding var isSidebarVisible: Bool
    var onCreate: () -> Void
    @State private var isButtonHovered = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                SidebarToggleButton(isSidebarVisible: $isSidebarVisible)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Spacer()

            VStack(spacing: 20) {
                Image(systemName: "doc.text")
                    .font(.system(size: 48, weight: .ultraLight))
                    .foregroundStyle(NotionTheme.tertiaryText)

                VStack(spacing: 6) {
                    Text("Aucun script")
                        .font(.system(.title3, weight: .medium))
                        .foregroundStyle(NotionTheme.secondaryText)

                    Text("Selectionnez un script ou creez-en un nouveau.")
                        .font(.system(.subheadline))
                        .foregroundStyle(NotionTheme.tertiaryText)
                }

                Button(action: onCreate) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                        Text("Nouveau script")
                            .font(.system(.subheadline, weight: .medium))
                    }
                    .foregroundStyle(
                        isButtonHovered ? NotionTheme.accent : NotionTheme.secondaryText
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isButtonHovered ? NotionTheme.accent.opacity(0.1) : NotionTheme.hover)
                    )
                }
                .buttonStyle(.plain)
                .onHover { isButtonHovered = $0 }
            }

            Spacer()
        }
    }
}

// MARK: - Sidebar Toggle

struct SidebarToggleButton: View {

    @Binding var isSidebarVisible: Bool
    @State private var isHovered = false

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.25, bounce: 0)) {
                isSidebarVisible.toggle()
            }
        } label: {
            Image(systemName: "sidebar.left")
                .font(.system(size: 14))
                .foregroundStyle(isHovered ? NotionTheme.text : NotionTheme.secondaryText)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isHovered ? NotionTheme.hover : .clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .help("Afficher/masquer la sidebar (\u{2318}S)")
    }
}

// MARK: - Editor Detail

/// Vue detail Notion : grand titre, metadata, editeur.
/// Utilise des Bindings custom pour ne pas trigger modifiedAt au changement de script.
struct EditorDetailView: View {

    @Bindable var script: Script
    var windowManager: WindowManager
    @Binding var isSidebarVisible: Bool

    @FocusState private var isTitleFocused: Bool
    @FocusState private var isEditorFocused: Bool
    @State private var isPresentHovered = false
    @State private var isFavHovered = false

    /// Binding custom : set() = edition reelle, pas un switch de script.
    private var titleBinding: Binding<String> {
        Binding(
            get: { script.title },
            set: { newValue in
                script.title = newValue
                script.modifiedAt = Date()
            }
        )
    }

    private var contentBinding: Binding<String> {
        Binding(
            get: { script.content },
            set: { newValue in
                script.content = newValue
                script.modifiedAt = Date()
            }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topBar

            TextField("Sans titre", text: titleBinding)
                .textFieldStyle(.plain)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(NotionTheme.text)
                .focused($isTitleFocused)
                .onSubmit { isEditorFocused = true }
                .padding(.horizontal, 52)
                .padding(.top, 16)

            metadataLine
                .padding(.horizontal, 52)
                .padding(.top, 8)
                .padding(.bottom, 28)

            Rectangle()
                .fill(NotionTheme.subtleDivider)
                .frame(height: 1)
                .padding(.horizontal, 48)

            TextEditor(text: contentBinding)
                .font(.system(.body))
                .foregroundStyle(NotionTheme.text)
                .lineSpacing(5)
                .scrollContentBackground(.hidden)
                .focused($isEditorFocused)
                .padding(.horizontal, 48)
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear { updateFocus() }
        .onChange(of: script.id) { updateFocus() }
    }

    // MARK: - Subviews

    private var topBar: some View {
        HStack(spacing: 8) {
            SidebarToggleButton(isSidebarVisible: $isSidebarVisible)

            Spacer()

            Button {
                withAnimation(.spring(duration: 0.25)) {
                    script.isFavorite.toggle()
                }
            } label: {
                Image(systemName: script.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(
                        script.isFavorite
                            ? NotionTheme.orange
                            : (isFavHovered
                                ? NotionTheme.text.opacity(0.5)
                                : NotionTheme.text.opacity(0.15))
                    )
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .onHover { isFavHovered = $0 }

            Button {
                windowManager.showPrompter(script: script)
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 9))
                    Text("Presenter")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(isPresentHovered ? .white : NotionTheme.secondaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(isPresentHovered ? NotionTheme.accent : NotionTheme.hover)
                )
                .animation(.easeOut(duration: 0.15), value: isPresentHovered)
            }
            .buttonStyle(.plain)
            .onHover { isPresentHovered = $0 }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var metadataLine: some View {
        HStack(spacing: 6) {
            Text("\(script.wordCount) mots")
            Text("\u{00B7}")
            Text(script.formattedDuration)
            Text("\u{00B7}")
            Text("Modifie \(script.modifiedAt.formatted(.relative(presentation: .named)))")
        }
        .font(.system(size: 12))
        .foregroundStyle(NotionTheme.tertiaryText)
    }

    private func updateFocus() {
        if script.title.isEmpty {
            isTitleFocused = true
        } else {
            isEditorFocused = true
        }
    }
}
