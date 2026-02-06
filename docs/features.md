# Features - Notchie

Les 12 features a implementer, directement basees sur Moody.

---

## 1. Voice Activated (Defilement vocal)

**Description** : Le texte defile automatiquement quand l'utilisateur parle et se met en pause quand il s'arrete.

### Implementation

**Approche recommandee : VAD basee sur le niveau audio (RMS)**

Pas besoin de reconnaissance vocale complete. On detecte simplement si le micro capte du son au-dessus d'un seuil.

```
Microphone --> AVAudioEngine (installTap) --> Buffer audio
    --> Calcul RMS (Root Mean Square)
    --> Seuil de detection (ex: 0.1 = 10%)
    --> Speaking: true/false
    --> ScrollController: accelere / decelere
```

**Composants :**
- `AudioEngine` : wrapper AVAudioEngine, installe un tap sur le inputNode
- `VoiceDetector` : analyse les buffers, calcule RMS, determine speaking/silence
- Seuil configurable par l'utilisateur (sensibilite du micro)
- Deceleration douce (pas d'arret brusque)

**Permissions requises :**
- `NSMicrophoneUsageDescription` dans Info.plist
- Demande de permission au premier lancement

---

## 2. Discreet to Others (Invisible en screen sharing)

**Description** : La fenetre du prompteur est invisible pendant le partage d'ecran (Zoom, Meet, OBS, etc.)

### Implementation

**Realite technique :** Sur macOS 15+, `NSWindow.sharingType = .none` est **ignore** par ScreenCaptureKit. Aucune solution publique n'existe pour etre invisible aux outils modernes de capture.

**Approche "best effort" :**

```swift
// Combinaison de toutes les techniques disponibles
window.sharingType = .none  // Bloque les APIs legacy (macOS <= 14)

window.level = NSWindow.Level(
    rawValue: Int(CGWindowLevelForKey(.assistiveTechHighWindow))
)

window.collectionBehavior = [
    .canJoinAllSpaces,
    .stationary,
    .ignoresCycle
]
```

**Ce qui fonctionne :**
- macOS <= 14 : invisible pour les outils utilisant CGWindowList (legacy)
- Zoom (mode "Advanced capture with window filtering") : fonctionne
- QuickTime, OBS modernes : **NE fonctionne PAS**

**Honnetete open-source :** Documenter clairement les limites dans le README. Moody a probablement les memes contraintes.

---

## 3. Positioned at Your Camera (Position notch)

**Description** : Le contenu apparait directement sous la camera/notch pour un contact visuel naturel.

### Implementation

**Detection du notch :**
```swift
extension NSScreen {
    var hasNotch: Bool {
        guard #available(macOS 12, *) else { return false }
        return safeAreaInsets.top > 0
    }

    var notchRect: CGRect? {
        guard #available(macOS 12, *), hasNotch else { return nil }
        let leftArea = auxiliaryTopLeftArea
        let rightArea = auxiliaryTopRightArea
        return CGRect(
            x: leftArea.maxX,
            y: frame.height - safeAreaInsets.top,
            width: rightArea.minX - leftArea.maxX,
            height: safeAreaInsets.top
        )
    }
}
```

**Positionnement de la fenetre :**
- Centrer horizontalement sur l'ecran
- Positionner le bord superieur juste sous le notch
- Largeur : ajustable, mais par defaut ~largeur du notch

**Fallback sans notch :**
- Sur les Macs sans notch (iMac, Mac externe, anciens MacBooks) : positionner en haut centre de l'ecran, sous la barre de menu

---

## 4. Floating Window (Fenetre flottante)

**Description** : Placer le prompteur n'importe ou sur l'ecran et le redimensionner librement.

### Implementation

**NSPanel subclass :**
```swift
class FloatingPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .titled, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        backgroundColor = .black
    }
}
```

**Proprietes cles :**
- `.nonactivatingPanel` : ne vole pas le focus quand on clique dessus
- `.fullScreenAuxiliary` : reste visible au-dessus des apps en plein ecran
- `.canJoinAllSpaces` : visible sur tous les Spaces/bureaux
- `hidesOnDeactivate = false` : ne se cache pas quand l'app perd le focus
- `isMovableByWindowBackground = true` : drag depuis n'importe ou

---

## 5. Pause (Pause au survol)

**Description** : Hover au-dessus du prompteur pour pause instantanee. Clic sur l'icone pour pause prolongee.

### Implementation

- `NSTrackingArea` sur la fenetre pour detecter mouseEntered/mouseExited
- `onHover` en SwiftUI pour le modifier visuel
- Etat : `.playing`, `.hoveredPause`, `.manualPause`
- Icone de pause/play visible au hover

```
Mouse Enter --> Pause immédiate + afficher icone pause
Mouse Exit  --> Resume automatique (sauf si manualPause)
Click icone --> Toggle manualPause
```

---

## 6. Control the Pace (Controle de vitesse)

**Description** : Scroll manuel a travers le contenu et ajuster la vitesse pendant la presentation.

### Implementation

- **Scroll manuel** : trackpad/souris pour naviguer dans le texte
- **Ajustement de vitesse** : raccourcis clavier ou slider
  - `Cmd+Up` : augmenter la vitesse
  - `Cmd+Down` : diminuer la vitesse
  - Affichage de la vitesse actuelle (ex: "1.5x")
- **Plage de vitesse** : 0.25x a 4.0x (par pas de 0.25x)
- **Vitesse par defaut** : 1.0x (environ 50 points/seconde)

---

## 7. Customize Prompter Size (Taille personnalisable)

**Description** : Ajuster la taille de la fenetre et du texte pour s'adapter a l'ecran.

### Implementation

- **Taille de fenetre** : NSPanel resizable avec contraintes min/max
  - Min : 200x100
  - Max : taille de l'ecran
- **Taille de texte** : slider ou raccourcis `Cmd+Plus` / `Cmd+Minus`
  - Range : 14pt a 72pt
  - Par defaut : 24pt
- **Persistance** : @AppStorage pour sauvegarder les preferences

---

## 8. Customize Text Color (Couleur de texte)

**Description** : Choisir la couleur du texte pour un contraste optimal.

### Implementation

- **Presets** : Blanc, Vert (classique prompteur), Jaune, Cyan, Rouge, Rose
- **Custom** : ColorPicker SwiftUI pour couleur libre
- **Background** : Toujours noir (pour contraste maximal et discretion)
- **Persistance** : @AppStorage avec encodage Color -> Data

```swift
// Presets de couleurs
static let colorPresets: [(name: String, color: Color)] = [
    ("White", .white),
    ("Green", Color(hex: "#00FF41")),   // Matrix green
    ("Yellow", .yellow),
    ("Cyan", .cyan),
    ("Pink", Color(hex: "#FF69B4")),
]
```

---

## 9. Voice Visual Feedback (Beam vocal)

**Description** : Un "beam" visuel qui repond au volume de la voix pour monitorer le niveau de parole.

### Implementation

- Utilise les memes donnees RMS que le Voice Detector
- Arc/beam anime au-dessus ou en dessous du texte
- Couleur qui change selon l'intensite (bleu -> violet -> rouge)
- Animation fluide a 60fps

```
RMS Level: 0.0 ----[___________]---- 1.0
Beam:      petit    moyen    grand
Color:     bleu     violet   rouge
```

**SwiftUI :** Custom Shape avec animation basee sur `audioLevel: CGFloat`

---

## 10. Countdown Timer (Minuteur)

**Description** : Timer de preparation avant de commencer la presentation.

### Implementation

- Overlay plein ecran (sur la fenetre prompteur)
- Countdown : 3, 2, 1, Go! (configurable : 3s, 5s, 10s)
- Animation de scale + fade
- Son optionnel a chaque seconde
- Demarrage automatique du defilement a la fin du countdown

```
[3] --> scale down, fade
[2] --> scale down, fade
[1] --> scale down, fade
[Go!] --> flash, start scrolling
```

---

## 11. Your Content Stays Private (100% local)

**Description** : Tout reste sur l'ordinateur. Aucun upload cloud, aucune collecte de donnees.

### Implementation

- **Stockage** : SwiftData (SQLite local dans ~/Library/Application Support/Notchie/)
- **Pas de reseau** : zero appel HTTP, zero analytics, zero telemetrie
- **Pas de compte** : pas d'authentification requise
- **Export** : les scripts sont de simples fichiers texte, exportables en .txt/.md

---

## 12. Built-in Editor (Editeur integre)

**Description** : Creer et editer les scripts de presentation directement dans l'app.

### Implementation

**Editeur principal :**
- SwiftUI `TextEditor` pour l'edition de texte
- Font monospace par defaut
- Compteur de mots / estimation de duree de lecture
- Sauvegarde automatique (SwiftData)

**Gestion des scripts :**
- Liste de scripts avec recherche
- Creer / Dupliquer / Supprimer
- Import depuis fichier (.txt, .md)
- Export vers fichier

**Modele de donnees :**
```swift
@Model
final class Script {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var modifiedAt: Date
    var isFavorite: Bool

    // Duree estimee (mots / 150 mots par minute)
    var estimatedDuration: TimeInterval {
        let wordCount = content.split(separator: " ").count
        return Double(wordCount) / 150.0 * 60.0
    }
}
```
