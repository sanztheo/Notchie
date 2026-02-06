//
//  Script.swift
//  TopCue
//
//  Created by Sanz on 06/02/2026.
//

import Foundation
import SwiftData

@Model
final class Script {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var modifiedAt: Date
    var isFavorite: Bool

    init(
        title: String,
        content: String = "",
        isFavorite: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.modifiedAt = Date()
        self.isFavorite = isFavorite
    }

    /// Nombre de mots dans le script
    var wordCount: Int {
        content.split(separator: " ").count
    }

    /// Duree estimee de lecture (150 mots par minute)
    var estimatedDuration: TimeInterval {
        Double(wordCount) / 150.0 * 60.0
    }

    /// Duree estimee formatee (ex: "2 min 30 s")
    var formattedDuration: String {
        let minutes = Int(estimatedDuration) / 60
        let seconds = Int(estimatedDuration) % 60
        if minutes > 0 {
            return "\(minutes) min \(seconds) s"
        }
        return "\(seconds) s"
    }
}
