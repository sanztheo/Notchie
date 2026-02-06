# Architecture - Notchie

## 1. Pourquoi Swift natif (et pas Tauri)

### Swift natif : le choix evident

| Critere | Swift natif | Tauri (Rust + Web) |
|---------|------------|-------------------|
| Invisibilite screen sharing | `NSWindow.sharingType = .none` | Impossible sur macOS 15+ |
| Positionnement notch | `NSScreen.safeAreaInsets` natif | Pas d'acces direct |
| Window levels (au-dessus fullscreen) | `NSWindow.Level` complet | Limite, necessite plugins |
| Audio/Microphone | AVFoundation natif | Plugin requis |
| Taille binaire | ~5-10 MB | ~15-30 MB (WebView runtime) |
| Performance | Natif, zero overhead | WebView overhead |
| Integration macOS | Parfaite (menu bar, Spaces, etc.) | Limitee |

### Pourquoi Tauri est disqualifie

1. **`NSWindow.sharingType = .none` est inaccessible** depuis Tauri de maniere fiable
2. **ScreenCaptureKit (macOS 15+) ignore** toutes les protections de fenetre - meme Swift ne peut pas garantir l'invisibilite, mais Tauri ne peut meme pas essayer
3. **Le positionnement notch** necessite `NSScreen.auxiliaryTopLeftArea/auxiliaryTopRightArea` - APIs AppKit pures
4. **Les window levels au-dessus de fullscreen** necessitent `NSPanel` avec `.fullScreenAuxiliary` - pas de support Tauri natif

### SwiftUI + AppKit hybride

- **SwiftUI** pour : UI, state management, TextEditor, animations
- **AppKit** pour : NSPanel (floating window), NSWindow.Level, sharingType, notch positioning

---

## 2. Stack technique

```
Notchie.app
|
|-- SwiftUI (UI Layer)
|   |-- ContentView          # Vue principale (editeur + controles)
|   |-- PrompterView         # Vue teleprompter (texte defilant)
|   |-- SettingsView         # Preferences (couleurs, tailles, etc.)
|   |-- CountdownOverlay     # Overlay timer avant presentation
|   +-- VoiceBeamView        # Visualisation audio
|
|-- AppKit (Window Layer)
|   |-- FloatingPanel        # NSPanel subclass (floating, non-activating)
|   |-- NotchWindow          # Fenetre positionnee au notch
|   +-- WindowManager        # Gestion des fenetres et niveaux
|
|-- Services
|   |-- AudioEngine          # AVAudioEngine (microphone input)
|   |-- VoiceDetector        # VAD (Voice Activity Detection)
|   |-- ScrollController     # Controle du defilement (vitesse, pause)
|   +-- ScriptStorage        # SwiftData persistence
|
|-- Models
|   |-- Script               # @Model SwiftData
|   |-- AppSettings          # @AppStorage preferences
|   +-- PrompterState        # Etat de la presentation
|
+-- Utils
    |-- NotchDetector        # Detection notch + dimensions
    |-- PermissionManager    # Permissions micro/accessibilite
    +-- Constants            # Constantes nommees
```

---

## 3. Structure Xcode

```
Notchie/
|-- Notchie.xcodeproj
|-- Notchie/
|   |-- App/
|   |   |-- NotchieApp.swift          # @main, Scene definition
|   |   +-- AppDelegate.swift         # NSApplicationDelegateAdaptor
|   |
|   |-- Views/
|   |   |-- Editor/
|   |   |   |-- EditorView.swift      # Editeur de scripts
|   |   |   +-- ScriptListView.swift  # Liste des scripts
|   |   |
|   |   |-- Prompter/
|   |   |   |-- PrompterView.swift    # Vue teleprompter
|   |   |   |-- CountdownView.swift   # Countdown overlay
|   |   |   +-- VoiceBeamView.swift   # Visualisation voix
|   |   |
|   |   +-- Settings/
|   |       +-- SettingsView.swift    # Preferences
|   |
|   |-- Windows/
|   |   |-- FloatingPanel.swift       # NSPanel subclass
|   |   |-- NotchWindow.swift         # Fenetre notch
|   |   +-- WindowManager.swift       # Gestion fenetres
|   |
|   |-- Services/
|   |   |-- AudioEngine.swift         # AVAudioEngine wrapper
|   |   |-- VoiceDetector.swift       # Voice Activity Detection
|   |   |-- ScrollController.swift    # Controle defilement
|   |   +-- ScriptStorage.swift       # SwiftData repository
|   |
|   |-- Models/
|   |   |-- Script.swift              # @Model
|   |   +-- PrompterState.swift       # Etat presentation
|   |
|   |-- Utils/
|   |   |-- NotchDetector.swift       # Detection notch
|   |   |-- PermissionManager.swift   # Permissions
|   |   +-- Constants.swift           # Constantes
|   |
|   |-- Resources/
|   |   |-- Assets.xcassets           # Icones, couleurs
|   |   +-- Info.plist                # Permissions, config
|   |
|   +-- Preview Content/
|       +-- Preview Assets.xcassets
|
|-- NotchieTests/
|   +-- ...
|
+-- docs/                             # Cette documentation
```

---

## 4. Architecture MVVM

```
View (SwiftUI)
  |
  |-- @StateObject ViewModel
  |     |
  |     |-- Service Layer
  |     |     |-- AudioEngine
  |     |     |-- VoiceDetector
  |     |     |-- ScrollController
  |     |     +-- ScriptStorage
  |     |
  |     +-- @Published properties
  |           (state visible par la View)
  |
  +-- AppKit Bridge
        |-- FloatingPanel (NSPanel)
        +-- WindowManager
```

### Flux de donnees

```
[Script Editor] --> SwiftData --> [Script List]
                                       |
                                       v
                              [Select Script]
                                       |
                                       v
                              [Prompter View]
                                  |        |
                    [Voice Detector]    [Manual Scroll]
                         |                    |
                         v                    v
                    [ScrollController] <------+
                         |
                         v
                    [Text Scrolling Animation]
```

---

## 5. Targets et deploiement

| Parametre | Valeur |
|-----------|--------|
| Deployment Target | macOS 14.0 (Sonoma) |
| Swift Version | 5.9+ |
| Xcode | 15.0+ |
| Signing | Developer ID (distribution hors App Store) |
| Distribution | GitHub Releases (.dmg) |
| Licence | MIT |

### Pourquoi macOS 14.0 minimum

- `safeAreaInsets` existe depuis macOS 12, mais les APIs SwiftUI modernes (`.windowLevel`, `.windowStyle`) arrivent en macOS 15
- macOS 14.0 est un bon compromis : couvre les MacBooks avec notch (2021+) et offre SwiftData
- Pour les APIs macOS 15+ (`.windowLevel(.floating)`), on utilise `#available` avec fallback AppKit

---

## 6. Dependencies externes

| Package | Usage | Source |
|---------|-------|--------|
| KeyboardShortcuts | Raccourcis globaux personnalisables | [sindresorhus/KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) |

**Philosophie : minimum de dependencies.** AVFoundation, AppKit, SwiftUI, SwiftData sont tous dans le SDK Apple.
