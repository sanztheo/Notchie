//
//  ScriptListView.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI
import SwiftData

/// Sidebar : liste des scripts, design system Notion.
/// Fond #F7F7F5 (light) / #252525 (dark), selection subtile, hover effects.
struct ScriptListView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Script.modifiedAt, order: .reverse) private var scripts: [Script]

    @Binding var selectedScript: Script?
    @Binding var isSidebarVisible: Bool

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
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 8)

            // Recherche
            SidebarSearchField(text: $searchText)
                .padding(.horizontal, 10)
                .padding(.bottom, 8)

            // Liste
            if scripts.isEmpty {
                emptyList
            } else if filteredScripts.isEmpty {
                noResults
            } else {
                scriptList
            }
        }
        .background { NotionTheme.sidebar.ignoresSafeArea() }
    }

    // MARK: - Subviews

    private var sidebarHeader: some View {
        HStack(alignment: .center) {
            Text("Scripts")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(NotionTheme.secondaryText)
                .textCase(.uppercase)
                .tracking(0.5)

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
                            withAnimation(.easeOut(duration: 0.1)) {
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
            .padding(.horizontal, 6)
            .padding(.top, 2)
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
                .foregroundStyle(NotionTheme.secondaryText)
            Text("Cliquez + pour commencer")
                .font(.system(.caption))
                .foregroundStyle(NotionTheme.tertiaryText)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var noResults: some View {
        VStack(spacing: 6) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 20, weight: .ultraLight))
                .foregroundStyle(NotionTheme.tertiaryText)
            Text("Aucun resultat")
                .font(.system(.subheadline))
                .foregroundStyle(NotionTheme.secondaryText)
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
            withAnimation(.easeOut(duration: 0.1)) {
                selectedScript = filteredScripts[index + 1]
            }
        } else if selectedScript == nil {
            withAnimation(.easeOut(duration: 0.1)) {
                selectedScript = filteredScripts.first
            }
        }
    }

    private func selectPrevious() {
        guard !filteredScripts.isEmpty else { return }
        if let current = selectedScript,
           let index = filteredScripts.firstIndex(where: { $0.id == current.id }),
           index > 0 {
            withAnimation(.easeOut(duration: 0.1)) {
                selectedScript = filteredScripts[index - 1]
            }
        }
    }
}

// MARK: - Search Field

/// Barre de recherche Notion : fond subtil, loupe, coins arrondis.
private struct SidebarSearchField: View {

    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(NotionTheme.tertiaryText)

            TextField("Rechercher\u{2026}", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .foregroundStyle(NotionTheme.text)
                .focused($isFocused)

            if !text.isEmpty {
                Button {
                    withAnimation(.easeOut(duration: 0.15)) { text = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(NotionTheme.secondaryText)
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isFocused ? NotionTheme.selected : NotionTheme.hover)
        )
        .animation(.easeOut(duration: 0.15), value: isFocused)
    }
}

// MARK: - Add Button

/// Bouton + Notion : discret, hover effect.
private struct SidebarAddButton: View {

    var action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isHovered ? NotionTheme.text : NotionTheme.secondaryText)
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isHovered ? NotionTheme.hover : .clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Script Row

/// Ligne de script Notion : titre medium, metadata caption, etoile au hover.
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
                Text(displayTitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(script.title.isEmpty ? NotionTheme.tertiaryText : NotionTheme.text)
                    .lineLimit(1)

                Spacer(minLength: 4)

                if script.isFavorite || isHovered {
                    Image(systemName: script.isFavorite ? "star.fill" : "star")
                        .font(.system(size: 10))
                        .foregroundStyle(
                            script.isFavorite
                                ? NotionTheme.orange
                                : NotionTheme.tertiaryText
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }

            HStack(spacing: 4) {
                Text("\(script.wordCount) mots")
                Text("\u{00B7}")
                Text(script.formattedDuration)
            }
            .font(.system(size: 11))
            .foregroundStyle(NotionTheme.tertiaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(rowBackground)
        )
        .contentShape(RoundedRectangle(cornerRadius: 6))
        .onTapGesture(perform: onSelect)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
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

    private var displayTitle: String {
        script.title.isEmpty ? "Sans titre" : script.title
    }

    private var rowBackground: Color {
        if isSelected {
            return NotionTheme.selected
        } else if isHovered {
            return NotionTheme.hover
        }
        return .clear
    }
}
