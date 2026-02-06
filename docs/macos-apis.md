# APIs macOS - Reference technique

Toutes les APIs macOS cles necessaires pour Notchie, avec exemples de code Swift.

---

## 1. Fenetre invisible au screen sharing

### NSWindow.sharingType

```swift
// Empêche les APIs legacy de capturer la fenetre
// FONCTIONNE : macOS <= 14 (legacy capture APIs)
// NE FONCTIONNE PAS : macOS 15+ (ScreenCaptureKit ignore ce flag)
window.sharingType = .none
```

### Configuration complete "best effort"

```swift
func configureInvisibleWindow(_ window: NSWindow) {
    // 1. Bloquer les APIs legacy de capture
    window.sharingType = .none

    // 2. Utiliser un window level eleve (assistive tech)
    window.level = NSWindow.Level(
        rawValue: Int(CGWindowLevelForKey(.assistiveTechHighWindow))
    )

    // 3. Comportement de collection
    window.collectionBehavior = [
        .canJoinAllSpaces,    // Visible sur tous les Spaces
        .stationary,          // Ne bouge pas avec les Spaces
        .ignoresCycle         // Ignore Cmd+Tab
    ]
}

// Pour rendre visible a nouveau
func configureVisibleWindow(_ window: NSWindow) {
    window.sharingType = .readOnly
    window.level = .floating
    window.collectionBehavior = [.canJoinAllSpaces, .stationary]
}
```

### Matrice de compatibilite

| macOS | sharingType bloque legacy APIs | Bloque ScreenCaptureKit | Bloque Zoom/OBS/Meet |
|-------|-------------------------------|------------------------|---------------------|
| 10.5 - 13.x | Oui | N/A | Non |
| 14 (Sonoma) | Oui | Non | Non (sauf Zoom window filter) |
| 15+ (Sequoia) | Non (ignore) | Non | Non |

---

## 2. Detection et positionnement du notch

### Detecter si le Mac a un notch

```swift
import AppKit

extension NSScreen {
    /// Le Mac a-t-il un notch ? (MacBook Pro 2021+, MacBook Air M2+)
    @available(macOS 12, *)
    var hasNotch: Bool {
        return safeAreaInsets.top > 0
    }

    /// Hauteur du notch en points
    @available(macOS 12, *)
    var notchHeight: CGFloat {
        return safeAreaInsets.top  // ~32pt sur les MacBooks avec notch
    }
}
```

### Obtenir les dimensions du notch

```swift
@available(macOS 12, *)
func getNotchGeometry(screen: NSScreen) -> (
    notchRect: CGRect,
    leftSafe: CGRect,
    rightSafe: CGRect
)? {
    guard screen.safeAreaInsets.top > 0 else { return nil }

    let leftArea = screen.auxiliaryTopLeftArea     // Zone safe a gauche du notch
    let rightArea = screen.auxiliaryTopRightArea    // Zone safe a droite du notch

    // Le notch est l'espace entre les deux zones auxiliaires
    let notchRect = CGRect(
        x: leftArea.maxX,
        y: screen.frame.height - screen.safeAreaInsets.top,
        width: rightArea.minX - leftArea.maxX,
        height: screen.safeAreaInsets.top
    )

    return (notchRect, leftArea, rightArea)
}
```

### Positionner la fenetre sous le notch

```swift
func positionBelowNotch(window: NSWindow, width: CGFloat, height: CGFloat) {
    guard let screen = NSScreen.main else { return }

    var originY: CGFloat
    var originX: CGFloat

    if #available(macOS 12, *), screen.safeAreaInsets.top > 0 {
        // Mac avec notch : positionner juste sous le notch
        originY = screen.frame.height - screen.safeAreaInsets.top - height
        originX = screen.frame.midX - width / 2
    } else {
        // Mac sans notch : positionner sous la barre de menu
        originY = screen.visibleFrame.maxY - height
        originX = screen.frame.midX - width / 2
    }

    window.setFrame(
        CGRect(x: originX, y: originY, width: width, height: height),
        display: true
    )
}
```

### Relations entre NSScreen properties

```
screen.frame           = Dimensions physiques completes de l'ecran
screen.visibleFrame    = frame - barre de menu - Dock
screen.safeAreaInsets   = Distance depuis les bords (top > 0 = notch)

auxiliaryTopLeftArea   = Rectangle safe a GAUCHE du notch
auxiliaryTopRightArea  = Rectangle safe a DROITE du notch

Notch = espace ENTRE auxiliaryTopLeftArea.maxX et auxiliaryTopRightArea.minX
```

---

## 3. Floating Panel (NSPanel)

### Subclass NSPanel pour fenetre flottante

```swift
import AppKit

final class FloatingPanel: NSPanel {

    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [
                .nonactivatingPanel,        // Ne vole pas le focus
                .titled,                     // Barre de titre (invisible)
                .resizable,                  // Redimensionnable
                .fullSizeContentView         // Contenu sous la barre de titre
            ],
            backing: .buffered,
            defer: false
        )

        // --- Comportement flottant ---
        isFloatingPanel = true
        level = .floating                    // Au-dessus des fenetres normales
        hidesOnDeactivate = false            // Reste visible quand l'app perd le focus
        isMovableByWindowBackground = true   // Drag depuis n'importe ou
        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        // --- Comportement Spaces ---
        collectionBehavior = [
            .canJoinAllSpaces,               // Visible sur tous les Spaces
            .fullScreenAuxiliary             // Reste visible au-dessus du fullscreen
        ]

        // --- Apparence ---
        backgroundColor = .black
        isOpaque = false
        hasShadow = true

        // --- Taille ---
        minSize = NSSize(width: 200, height: 100)
    }
}
```

### Window Levels (hierarchie)

```swift
NSWindow.Level.normal       = 0      // Fenetres normales
NSWindow.Level.floating     = 3      // Palettes flottantes
NSWindow.Level.modalPanel   = 8      // Dialogues modaux
NSWindow.Level.mainMenu     = 24     // Barre de menu
NSWindow.Level.statusBar    = 25     // Status bar
NSWindow.Level.popUpMenu    = 101    // Menus popup
NSWindow.Level.screenSaver  = 1000   // Ecran de veille

// Custom : au-dessus de tout
let aboveEverything = NSWindow.Level(rawValue: 2002)

// Assistive tech (utilise pour l'invisibilite)
let assistiveLevel = NSWindow.Level(
    rawValue: Int(CGWindowLevelForKey(.assistiveTechHighWindow))
)
```

### Rester au-dessus des apps fullscreen

```swift
// Solution 1 : fullScreenAuxiliary (recommandee)
panel.collectionBehavior.insert(.fullScreenAuxiliary)

// Solution 2 : Window level eleve
panel.level = NSWindow.Level(rawValue: 2002)

// Solution 3 : NSPanel + nonactivatingPanel
// (combine avec fullScreenAuxiliary pour meilleur resultat)
```

---

## 4. AVAudioEngine (Microphone)

### Setup basique

```swift
import AVFoundation

final class AudioEngine {
    let engine = AVAudioEngine()
    var onAudioLevel: ((Float) -> Void)?

    func start() throws {
        let inputNode = engine.inputNode
        let format = inputNode.inputFormat(forBus: 0)

        inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: format
        ) { [weak self] buffer, _ in
            let level = self?.calculateRMS(buffer) ?? 0
            self?.onAudioLevel?(level)
        }

        engine.prepare()
        try engine.start()
    }

    func stop() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
    }

    /// Calcul RMS (Root Mean Square) pour niveau audio
    private func calculateRMS(_ buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0 }

        let samples = Array(
            UnsafeBufferPointer(
                start: channelData[0],
                count: Int(buffer.frameLength)
            )
        )

        // RMS = sqrt(sum(x^2) / N)
        let sumOfSquares = samples.reduce(0) { $0 + $1 * $1 }
        let rms = sqrt(sumOfSquares / Float(buffer.frameLength))

        // Convertir en dB : dB = 20 * log10(rms)
        let db = 20 * log10(rms + Float.ulpOfOne)  // ulpOfOne evite log(0)

        // Normaliser entre 0 et 1 (range typique : -80dB a 0dB)
        let normalized = max(0, min(1, (db + 80) / 80))

        return normalized
    }
}
```

### Voice Activity Detection (VAD)

```swift
final class VoiceDetector {
    private var silenceFrames = 0
    private var speakingFrames = 0
    private(set) var isSpeaking = false

    /// Nombre de frames avant de confirmer un changement d'etat
    var silenceThreshold = 5     // ~5 frames de silence = pause
    var speakingThreshold = 3    // ~3 frames de voix = parle
    var audioLevelThreshold: Float = 0.1  // 10% du max

    var onStateChanged: ((Bool) -> Void)?

    func analyze(level: Float) {
        if level > audioLevelThreshold {
            speakingFrames += 1
            silenceFrames = 0

            if !isSpeaking && speakingFrames >= speakingThreshold {
                isSpeaking = true
                speakingFrames = 0
                onStateChanged?(true)
            }
        } else {
            silenceFrames += 1
            speakingFrames = 0

            if isSpeaking && silenceFrames >= silenceThreshold {
                isSpeaking = false
                silenceFrames = 0
                onStateChanged?(false)
            }
        }
    }
}
```

---

## 5. Permissions

### Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Acces microphone (obligatoire pour voice activation) -->
    <key>NSMicrophoneUsageDescription</key>
    <string>Notchie utilise le microphone pour detecter votre voix et faire defiler le texte automatiquement.</string>

    <!-- Pas de safe area compatibility mode (on gere le notch nous-memes) -->
    <key>NSPrefersDisplaySafeAreaCompatibilityMode</key>
    <false/>
</dict>
</plist>
```

### Demande de permission runtime

```swift
import AVFoundation

final class PermissionManager {
    static func requestMicrophoneAccess() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)

        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .audio)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    static func openSystemPreferences() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
            NSWorkspace.shared.open(url)
        }
    }
}
```

---

## 6. Smooth Scrolling (Defilement fluide)

### Approche avec Timer a 60fps

```swift
import SwiftUI

struct TeleprompterScrollView: View {
    let text: String
    @Binding var isPlaying: Bool
    @Binding var speed: CGFloat  // points par seconde (defaut: 50)

    @State private var scrollOffset: CGFloat = 0

    private let frameRate: CGFloat = 1.0 / 60.0  // 60fps

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                Text(text)
                    .font(.system(size: 24, design: .monospaced))
                    .lineSpacing(12)
                    .padding(40)
                    .offset(y: -scrollOffset)
            }
        }
        .onReceive(
            Timer.publish(every: frameRate, on: .main, in: .common).autoconnect()
        ) { _ in
            guard isPlaying else { return }
            withAnimation(.linear(duration: frameRate)) {
                scrollOffset += speed * frameRate
            }
        }
    }
}
```

### Approche avec CVDisplayLink (plus precise)

```swift
import QuartzCore

final class DisplayLinkScroller {
    private var displayLink: CVDisplayLink?
    private(set) var scrollOffset: CGFloat = 0
    var speed: CGFloat = 50  // points par seconde
    var isPlaying = false
    var onScroll: ((CGFloat) -> Void)?

    func start() {
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        guard let link = displayLink else { return }

        let callback: CVDisplayLinkOutputCallback = {
            _, inNow, _, _, _, userInfo -> CVReturn in
            guard let userInfo = userInfo else { return kCVReturnError }

            let scroller = Unmanaged<DisplayLinkScroller>
                .fromOpaque(userInfo)
                .takeUnretainedValue()

            if scroller.isPlaying {
                let delta = scroller.speed / 60.0  // Approx 60fps
                scroller.scrollOffset += delta
                DispatchQueue.main.async {
                    scroller.onScroll?(scroller.scrollOffset)
                }
            }
            return kCVReturnSuccess
        }

        CVDisplayLinkSetOutputCallback(
            link,
            callback,
            Unmanaged.passUnretained(self).toOpaque()
        )
        CVDisplayLinkStart(link)
    }

    func stop() {
        guard let link = displayLink else { return }
        CVDisplayLinkStop(link)
        displayLink = nil
    }

    func reset() {
        scrollOffset = 0
    }

    deinit {
        stop()
    }
}
```

---

## 7. SwiftData (Persistence des scripts)

### Modele

```swift
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
}
```

### Configuration dans l'App

```swift
import SwiftUI
import SwiftData

@main
struct NotchieApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Script.self)
    }
}
```

### Repository

```swift
import SwiftData

@MainActor
final class ScriptRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [Script] {
        let descriptor = FetchDescriptor<Script>(
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func save(_ script: Script) throws {
        context.insert(script)
        try context.save()
    }

    func delete(_ script: Script) throws {
        context.delete(script)
        try context.save()
    }

    func search(query: String) throws -> [Script] {
        let descriptor = FetchDescriptor<Script>(
            predicate: #Predicate { $0.title.localizedStandardContains(query) },
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
}
```

---

## 8. Keyboard Shortcuts

### SwiftUI natif

```swift
// Dans les menus de l'app
.commands {
    CommandGroup(replacing: .newItem) {
        Button("Nouveau Script") { createNewScript() }
            .keyboardShortcut("n", modifiers: .command)
    }

    CommandMenu("Presentation") {
        Button("Demarrer / Pause") { togglePresentation() }
            .keyboardShortcut(.space, modifiers: .command)

        Button("Augmenter vitesse") { increaseSpeed() }
            .keyboardShortcut(.upArrow, modifiers: .command)

        Button("Diminuer vitesse") { decreaseSpeed() }
            .keyboardShortcut(.downArrow, modifiers: .command)

        Divider()

        Button("Countdown 3s") { startCountdown(seconds: 3) }
            .keyboardShortcut("3", modifiers: [.command, .shift])
    }
}
```

### Raccourcis globaux (avec KeyboardShortcuts)

```swift
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let togglePresentation = Self(
        "togglePresentation",
        default: .init(.p, modifiers: [.command, .shift])
    )
    static let toggleInvisible = Self(
        "toggleInvisible",
        default: .init(.i, modifiers: [.command, .shift])
    )
}

// Enregistrement
KeyboardShortcuts.onKeyUp(for: .togglePresentation) {
    togglePresentation()
}
```

---

## 9. AppStorage (Preferences utilisateur)

```swift
import SwiftUI

extension UserDefaults {
    // Cles de preferences
    static let textColorKey = "prompterTextColor"
    static let fontSizeKey = "prompterFontSize"
    static let scrollSpeedKey = "prompterScrollSpeed"
    static let countdownDurationKey = "countdownDuration"
    static let micSensitivityKey = "micSensitivity"
}

// Dans les Views
struct SettingsView: View {
    @AppStorage("prompterFontSize") private var fontSize: Double = 24
    @AppStorage("prompterScrollSpeed") private var scrollSpeed: Double = 50
    @AppStorage("countdownDuration") private var countdownDuration: Int = 3
    @AppStorage("micSensitivity") private var micSensitivity: Double = 0.1
    @AppStorage("textColorHex") private var textColorHex: String = "#FFFFFF"

    var body: some View {
        Form {
            Section("Affichage") {
                Slider(value: $fontSize, in: 14...72, step: 2) {
                    Text("Taille du texte: \(Int(fontSize))pt")
                }
                // ...
            }
        }
    }
}
```
