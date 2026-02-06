//
//  EditorView.swift
//  Notchie
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI
import SwiftData

/// Vue principale de l'editeur : sidebar + editeur de texte.
/// Layout custom HStack, design system Notion, toggle sidebar Cmd+S.
struct EditorView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var selectedScript: Script?
    @State private var isSidebarVisible = true

    var windowManager: WindowManager

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
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

            // Detail
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
        }
        .background(NotionTheme.content)
        .overlay {
            // Cmd+S : toggle sidebar
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

// MARK: - Empty State

/// Etat vide — minimaliste, couleurs Notion.
private struct EmptyEditorView: View {

    @Binding var isSidebarVisible: Bool
    var onCreate: () -> Void
    @State private var isButtonHovered = false

    var body: some View {
        VStack(spacing: 0) {
            // Top bar avec toggle sidebar
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

// MARK: - Sidebar Toggle Button

/// Bouton toggle sidebar — icone sidebar, hover discret.
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
                .font(.system(size: 14, weight: .regular))
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

/// Vue detail : editeur de texte pour un script individuel.
/// Design Notion : grand titre, metadata, editeur propre.
struct EditorDetailView: View {

    @Bindable var script: Script
    var windowManager: WindowManager
    @Binding var isSidebarVisible: Bool

    @FocusState private var isTitleFocused: Bool
    @FocusState private var isEditorFocused: Bool
    @State private var isPresentHovered = false
    @State private var isFavHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top bar
            topBar

            // Titre — grand, bold, sans bordure, style Notion
            TextField("Sans titre", text: $script.title)
                .textFieldStyle(.plain)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(NotionTheme.text)
                .focused($isTitleFocused)
                .onSubmit { isEditorFocused = true }
                .padding(.horizontal, 52)
                .padding(.top, 16)
                .onChange(of: script.title) {
                    script.modifiedAt = Date()
                }

            // Metadata
            metadataLine
                .padding(.horizontal, 52)
                .padding(.top, 8)
                .padding(.bottom, 28)

            // Separateur subtil
            Rectangle()
                .fill(NotionTheme.subtleDivider)
                .frame(height: 1)
                .padding(.horizontal, 48)

            // Editeur de texte
            TextEditor(text: $script.content)
                .font(.system(.body))
                .foregroundStyle(NotionTheme.text)
                .lineSpacing(5)
                .scrollContentBackground(.hidden)
                .focused($isEditorFocused)
                .padding(.horizontal, 48)
                .padding(.top, 16)
                .onChange(of: script.content) {
                    script.modifiedAt = Date()
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear { updateFocus() }
        .onChange(of: script.id) { updateFocus() }
    }

    // MARK: - Subviews

    private var topBar: some View {
        HStack(spacing: 8) {
            // Toggle sidebar
            SidebarToggleButton(isSidebarVisible: $isSidebarVisible)

            Spacer()

            // Favori
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

            // Presenter
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

    // MARK: - Helpers

    private func updateFocus() {
        if script.title.isEmpty {
            isTitleFocused = true
        } else {
            isEditorFocused = true
        }
    }
}
