//
//  ScriptListView.swift
//  Notchie
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI
import SwiftData

/// Sidebar : liste des scripts avec recherche, ajout et suppression.
/// Design Notion-like : fond propre, hover effects, selection subtile, pas de List.
struct ScriptListView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Script.modifiedAt, order: .reverse) private var scripts: [Script]

    @Binding var selectedScript: Script?

    @State private var searchText = ""

    private var filteredScripts: [Script] {
        if searchText.isEmpty {
            return scripts
        }
        return scripts.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            sidebarHeader
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

            // Recherche
            SidebarSearchField(text: $searchText)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)

            // Liste des scripts
            if scripts.isEmpty {
                emptyList
            } else if filteredScripts.isEmpty {
                noResults
            } else {
                scriptList
            }
        }
        .frame(width: 260)
        .background(Color.primary.opacity(0.02))
        .background(.background)
    }

    // MARK: - Subviews

    private var sidebarHeader: some View {
        HStack(alignment: .center) {
            Text("Scripts")
                .font(.system(.headline, weight: .semibold))
                .foregroundStyle(.primary)

            Spacer()

            SidebarAddButton(action: addScript)
        }
    }

    private var scriptList: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(filteredScripts) { script in
                    ScriptRowView(
                        script: script,
                        isSelected: selectedScript?.id == script.id,
                        onSelect: {
                            withAnimation(.easeOut(duration: 0.12)) {
                                selectedScript = script
                            }
                        },
                        onToggleFavorite: {
                            withAnimation(.spring(duration: 0.2)) {
                                script.isFavorite.toggle()
                            }
                        },
                        onDelete: { deleteScript(script) }
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)
            .padding(.bottom, 8)
        }
        .focusable()
        .focusEffectDisabled()
        .onKeyPress(.downArrow) { selectNext(); return .handled }
        .onKeyPress(.upArrow) { selectPrevious(); return .handled }
        .onKeyPress(.delete) { deleteSelected(); return .handled }
    }

    private var emptyList: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("Aucun script")
                .font(.system(.subheadline, weight: .medium))
                .foregroundStyle(.tertiary)
            Text("Cliquez + pour commencer")
                .font(.system(.caption))
                .foregroundStyle(.quaternary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var noResults: some View {
        VStack(spacing: 4) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20, weight: .ultraLight))
                .foregroundStyle(.quaternary)
            Text("Aucun resultat")
                .font(.system(.subheadline))
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Actions

    private func addScript() {
        withAnimation(.snappy(duration: 0.3)) {
            let script = Script(title: "", content: "")
            modelContext.insert(script)
            selectedScript = script
        }
    }

    private func deleteScript(_ script: Script) {
        withAnimation(.snappy(duration: 0.25)) {
            if selectedScript?.id == script.id {
                selectedScript = nil
            }
            modelContext.delete(script)
        }
    }

    private func deleteSelected() {
        guard let selectedScript else { return }
        deleteScript(selectedScript)
    }

    private func selectNext() {
        guard !filteredScripts.isEmpty else { return }
        if let current = selectedScript,
           let index = filteredScripts.firstIndex(where: { $0.id == current.id }),
           index < filteredScripts.count - 1 {
            withAnimation(.easeOut(duration: 0.12)) {
                selectedScript = filteredScripts[index + 1]
            }
        } else if selectedScript == nil {
            withAnimation(.easeOut(duration: 0.12)) {
                selectedScript = filteredScripts.first
            }
        }
    }

    private func selectPrevious() {
        guard !filteredScripts.isEmpty else { return }
        if let current = selectedScript,
           let index = filteredScripts.firstIndex(where: { $0.id == current.id }),
           index > 0 {
            withAnimation(.easeOut(duration: 0.12)) {
                selectedScript = filteredScripts[index - 1]
            }
        }
    }
}

// MARK: - Search Field

/// Barre de recherche Notion-like : fond subtil, icone loupe, pas de bordure.
private struct SidebarSearchField: View {

    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.tertiary)

            TextField("Rechercher\u{2026}", text: $text)
                .textFieldStyle(.plain)
                .font(.system(.subheadline))
                .focused($isFocused)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.primary.opacity(isFocused ? 0.06 : 0.04))
        )
        .animation(.easeOut(duration: 0.15), value: isFocused)
    }
}

// MARK: - Add Button

/// Bouton + discret, rond, avec hover effect.
private struct SidebarAddButton: View {

    var action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(isHovered ? .primary : .tertiary)
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isHovered ? Color.primary.opacity(0.06) : .clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Script Row

/// Ligne de script — style Notion : titre medium, metadata caption, etoile au hover.
private struct ScriptRowView: View {

    let script: Script
    let isSelected: Bool
    var onSelect: () -> Void
    var onToggleFavorite: () -> Void
    var onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 6) {
                Text(script.title.isEmpty ? "Sans titre" : script.title)
                    .font(.system(.body, weight: .medium))
                    .foregroundStyle(script.title.isEmpty ? .tertiary : .primary)
                    .lineLimit(1)

                Spacer(minLength: 4)

                if script.isFavorite || isHovered {
                    Image(systemName: script.isFavorite ? "star.fill" : "star")
                        .font(.system(size: 10))
                        .foregroundStyle(
                            script.isFavorite
                                ? Color.orange
                                : Color.primary.opacity(0.15)
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }

            HStack(spacing: 4) {
                Text("\(script.wordCount) mots")
                Text("\u{00B7}")
                Text(script.formattedDuration)
            }
            .font(.system(.caption))
            .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(rowBackground)
        )
        .contentShape(RoundedRectangle(cornerRadius: 7))
        .onTapGesture(perform: onSelect)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.12)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            Button {
                onToggleFavorite()
            } label: {
                Label(
                    script.isFavorite ? "Retirer des favoris" : "Ajouter aux favoris",
                    systemImage: script.isFavorite ? "star.slash" : "star"
                )
            }

            Divider()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Supprimer", systemImage: "trash")
            }
        }
    }

    private var rowBackground: Color {
        if isSelected {
            return Color.primary.opacity(0.08)
        } else if isHovered {
            return Color.primary.opacity(0.04)
        }
        return .clear
    }
}
