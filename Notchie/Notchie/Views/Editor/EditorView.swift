//
//  EditorView.swift
//  Notchie
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI
import SwiftData

/// Vue principale de l'editeur : sidebar (liste) + editeur de texte.
/// Contient le bouton "Presenter" pour ouvrir le prompteur.
struct EditorView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var selectedScript: Script?

    var windowManager: WindowManager

    var body: some View {
        NavigationSplitView {
            ScriptListView(selectedScript: $selectedScript)
        } detail: {
            if let selectedScript {
                EditorDetailView(
                    script: selectedScript,
                    windowManager: windowManager
                )
            } else {
                EmptyEditorView(onCreate: createScript)
            }
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

/// Etat vide — design minimaliste Notion-like.
private struct EmptyEditorView: View {

    var onCreate: () -> Void
    @State private var isButtonHovered = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 56, weight: .ultraLight))
                .foregroundStyle(.quaternary)

            VStack(spacing: 6) {
                Text("Aucun script")
                    .font(.system(.title3, weight: .medium))
                    .foregroundStyle(.secondary)

                Text("Selectionnez un script ou creez-en un nouveau.")
                    .font(.system(.subheadline))
                    .foregroundStyle(.tertiary)
            }

            Button(action: onCreate) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("Nouveau script")
                        .font(.system(.subheadline, weight: .medium))
                }
                .foregroundStyle(isButtonHovered ? Color.accentColor : .secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            isButtonHovered
                                ? Color.accentColor.opacity(0.08)
                                : Color.primary.opacity(0.04)
                        )
                )
            }
            .buttonStyle(.plain)
            .onHover { isButtonHovered = $0 }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }
}

// MARK: - Editor Detail

/// Vue detail : editeur de texte pour un script individuel.
/// Design Notion-like : grand titre, metadata discrete, editeur propre.
struct EditorDetailView: View {

    @Bindable var script: Script
    var windowManager: WindowManager

    @FocusState private var isTitleFocused: Bool
    @FocusState private var isEditorFocused: Bool
    @State private var isPresentHovered = false
    @State private var isFavHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top bar — boutons discrets, alignes a droite
            topBar

            // Titre — grand, bold, sans bordure
            TextField("Sans titre", text: $script.title)
                .textFieldStyle(.plain)
                .font(.system(size: 34, weight: .bold))
                .focused($isTitleFocused)
                .onSubmit { isEditorFocused = true }
                .padding(.horizontal, 52)
                .padding(.top, 20)
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
                .fill(Color.primary.opacity(0.04))
                .frame(height: 1)
                .padding(.horizontal, 48)

            // Editeur de texte — remplissage complet
            TextEditor(text: $script.content)
                .font(.system(.body))
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
        .background(.background)
        .navigationTitle("")
        .onAppear { updateFocus() }
        .onChange(of: script.id) { updateFocus() }
    }

    // MARK: - Subviews

    private var topBar: some View {
        HStack(spacing: 12) {
            Spacer()

            // Favori — etoile discrete
            Button {
                withAnimation(.spring(duration: 0.25)) {
                    script.isFavorite.toggle()
                }
            } label: {
                Image(systemName: script.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(
                        script.isFavorite
                            ? Color.orange
                            : (isFavHovered ? Color.primary.opacity(0.5) : Color.primary.opacity(0.15))
                    )
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .onHover { isFavHovered = $0 }

            // Presenter — hover effect bleu
            Button {
                windowManager.showPrompter(script: script)
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 9))
                    Text("Presenter")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(isPresentHovered ? .white : .secondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(
                            isPresentHovered
                                ? Color.accentColor
                                : Color.primary.opacity(0.04)
                        )
                )
                .animation(.easeOut(duration: 0.15), value: isPresentHovered)
            }
            .buttonStyle(.plain)
            .onHover { isPresentHovered = $0 }
        }
        .padding(.horizontal, 20)
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
        .foregroundStyle(.tertiary)
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
