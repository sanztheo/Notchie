//
//  ScriptListView.swift
//  Notchie
//
//  Created by Sanz on 06/02/2026.
//

import SwiftUI
import SwiftData

/// Sidebar : liste des scripts avec recherche, ajout et suppression.
/// Design Notion-like : fond propre, hover effects, pas de separateurs.
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
        List(selection: $selectedScript) {
            ForEach(filteredScripts) { script in
                ScriptRowView(script: script)
                    .tag(script)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 10))
                    .contextMenu {
                        Button {
                            withAnimation(.spring(duration: 0.2)) {
                                script.isFavorite.toggle()
                            }
                        } label: {
                            Label(
                                script.isFavorite ? "Retirer des favoris" : "Ajouter aux favoris",
                                systemImage: script.isFavorite ? "star.slash" : "star"
                            )
                        }

                        Divider()

                        Button(role: .destructive) {
                            deleteScript(script)
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
            }
            .onDelete(perform: deleteScripts)
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .searchable(text: $searchText, prompt: "Rechercher\u{2026}")
        .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 300)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: addScript) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
                .help("Nouveau script")
            }
        }
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

    private func deleteScripts(offsets: IndexSet) {
        withAnimation(.snappy(duration: 0.25)) {
            for index in offsets {
                let script = filteredScripts[index]
                if selectedScript?.id == script.id {
                    selectedScript = nil
                }
                modelContext.delete(script)
            }
        }
    }
}

// MARK: - Script Row

/// Ligne de script — style Notion : titre medium, metadata caption, etoile au hover.
private struct ScriptRowView: View {

    let script: Script
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
                            script.isFavorite ? .orange : .quaternary
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
        .padding(.vertical, 3)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}
