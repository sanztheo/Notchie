# Repository Guidelines

## Project Structure & Module Organization
Le projet est un app macOS Swift nommee TopCue. Le code applicatif est dans `TopCue/TopCue/` avec une organisation par responsabilite:
- `App/` (entree app et cycle de vie)
- `Models/` (etat et donnees, ex. scripts SwiftData)
- `Services/` (logique metier comme le defilement)
- `Views/Editor`, `Views/Prompter`, `Views/Settings` (UI SwiftUI)
- `Windows/` (integration AppKit, `NSPanel`, fenetres)
- `Utils/` et `Assets.xcassets/` (constantes et ressources)

Tests:
- `TopCue/TopCueTests/` (unitaires)
- `TopCue/TopCueUITests/` (UI)

Documentation technique dans `docs/`. Le projet Xcode est `TopCue/TopCue.xcodeproj`.

## Build, Test, and Development Commands
- `open TopCue/TopCue.xcodeproj` : ouvre le projet dans Xcode.
- `xcodebuild -project TopCue/TopCue.xcodeproj -scheme TopCue -configuration Debug build` : build local en ligne de commande.
- `xcodebuild test -project TopCue/TopCue.xcodeproj -scheme TopCue -destination 'platform=macOS'` : execute tests unitaires et UI.
- `xcodebuild -list -project TopCue/TopCue.xcodeproj` : verifie targets/scheme disponibles.

## Coding Style & Naming Conventions
Respecter `CLAUDE.md` en priorite:
- Indentation: 4 espaces, pas de tabulations.
- Longueur de ligne cible: 120 caracteres.
- Nommage: `UpperCamelCase` pour types, `lowerCamelCase` pour variables/fonctions.
- Booleens lisibles comme assertions (`isPlaying`, `canEditScript`).
- Fichiers Swift organises avec `// MARK:` et une responsabilite principale par fichier.

## Testing Guidelines
Framework actuel: `XCTest` (`TopCueTests`, `TopCueUITests`).
- Nommer les tests par comportement (`testLaunch`, `testScrollPausesOnHover`).
- Garder les tests independants et deterministes (pas de dependance d'ordre).
- Cibler d'abord logique de `Models/`, `Services/`, et etats de lecture; limiter les tests UI a des parcours critiques.

## Commit & Pull Request Guidelines
Historique actuel: messages imperatifs et descriptifs (`Add`, `Update`, `Refactor`, `Remove` + zone impactee).
- Faire des commits atomiques (une intention technique par commit).
- PR: inclure resume, issue liee, impact utilisateur, et preuve de test.
- Pour les changements UI, joindre captures d'ecran/GIF.
- Mentionner la version de macOS/Xcode utilisee si pertinent.

## Security & Configuration Notes
Le projet vise une execution locale sans dependances externes ni appels reseau.
- Ne pas versionner `DerivedData/`, `xcuserdata/`, logs ou fichiers temporaires.
- Toute modification de permissions (`*.entitlements`, `Info.plist`) doit etre explicitee dans la PR.
