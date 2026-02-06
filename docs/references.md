# References - Notchie

Projets open-source, articles, et documentation officielle.

---

## 1. Projets open-source de reference

### Teleprompters

| Projet | Tech | Description |
|--------|------|-------------|
| [NotchPrompter](https://github.com/jpomykala/NotchPrompter) | Swift (81%) + HTML | Floating text prompter macOS - **reference directe** |
| [QPrompt](https://github.com/Cuperino/QPrompt-Teleprompter) | C++ / Qt 6 | Teleprompter cross-platform, tres complet |
| [Imaginary Teleprompter](https://github.com/ImaginarySense/Imaginary-Teleprompter) | Web | Teleprompter open-source web-based |
| [voice-activated-teleprompter](https://github.com/jlecomte/voice-activated-teleprompter) | Web | Teleprompter avec activation vocale (Web Speech API) |
| [Echo-Prompter](https://github.com/sherwinvishesh/Echo-Prompter) | Web | Voice-activated avec speech recognition |

### Apps notch macOS

| Projet | Tech | Description |
|--------|------|-------------|
| [Atoll](https://github.com/Ebullioscopic/Atoll) | SwiftUI | Dynamic Island pour macOS - positionnement notch |
| [Boring Notch](https://theboring.name/) | SwiftUI | Transforme le notch en Dynamic Island |
| [Dynamic-Island-Sketchybar](https://github.com/crissNb/Dynamic-Island-Sketchybar) | Sketchybar | Dynamic Island avec menu bar replacement |
| [MacIsland](https://github.com/RKInnovate/MacIsland) | SwiftUI | Dynamic Island en SwiftUI |

### Editeurs de texte macOS

| Projet | Tech | Description |
|--------|------|-------------|
| [CotEditor](https://github.com/coteditor/CotEditor) | Swift / AppKit | Editeur texte macOS complet (reference) |
| [RichTextKit](https://github.com/danielsaidi/RichTextKit) | SwiftUI | Framework rich text editing |
| [STTextView](https://github.com/krzyzanowskim/STTextView) | AppKit / TextKit 2 | Composant text view moderne |

### Audio / VAD

| Projet | Tech | Description |
|--------|------|-------------|
| [RealTimeCutVADLibrary](https://github.com/helloooideeeeea/RealTimeCutVADLibrary) | Swift | VAD production-ready avec modeles Silero |
| [VoiceActivityDetector](https://github.com/reedom/VoiceActivityDetector) | Swift | WebRTC VAD wrapper pour iOS/macOS |
| [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) | Swift | Raccourcis clavier globaux |

---

## 2. Documentation Apple officielle

### AppKit / Fenetres

- [NSWindow.sharingType](https://developer.apple.com/documentation/appkit/nswindow/sharingtype-swift.enum)
- [NSWindow.Level](https://developer.apple.com/documentation/appkit/nswindow/1419511-level)
- [NSScreen.safeAreaInsets](https://developer.apple.com/documentation/appkit/nsscreen/safeareainsets)
- [NSScreen.auxiliaryTopLeftArea](https://developer.apple.com/documentation/AppKit/NSScreen/auxiliaryTopLeftArea-uglc)
- [NSPrefersDisplaySafeAreaCompatibilityMode](https://developer.apple.com/documentation/bundleresources/information-property-list/nsprefersdisplaysafeareacompatibilitymode)
- [Window Layers and Levels](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/WinPanel/Concepts/WindowLevel.html)

### Audio

- [AVAudioEngine](https://developer.apple.com/documentation/avfaudio/avaudioengine)
- [SFSpeechRecognizer](https://developer.apple.com/documentation/speech/sfspeechrecognizer)
- [NSMicrophoneUsageDescription](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSMicrophoneUsageDescription)
- [Recognizing speech in live audio](https://developer.apple.com/documentation/Speech/recognizing-speech-in-live-audio)

### SwiftUI

- [TextEditor](https://developer.apple.com/documentation/swiftui/texteditor)
- [SwiftData](https://developer.apple.com/documentation/SwiftData)

---

## 3. Articles et blogs

### Notch et fenetres

- [Fullscreen apps above the MacBook notch - Alin Panaitiu](https://notes.alinpanaitiu.com/Fullscreen-apps-above-the-MacBook-notch)
- [What is the order of NSWindow levels? - James Fisher](https://jameshfisher.com/2020/08/03/what-is-the-order-of-nswindow-levels/)
- [Building a (kind of) invisible mac app - Pierce Freeman](https://pierce.dev/notes/building-a-kind-of-invisible-mac-app)
- [How Interview Cheating Tools Hide from Zoom - Adam Svoboda](https://adamsvoboda.net/how-interview-cheating-tools-hide-from-zoom/)
- [Make a floating panel in SwiftUI - Cindori](https://cindori.com/developer/floating-panel)
- [Creating a floating window using SwiftUI in macOS 15 - Pol Piella](https://www.polpiella.dev/creating-a-floating-window-using-swiftui-in-macos-15)

### Audio et voix

- [AVAudioEngine Tutorial - Kodeco](https://www.kodeco.com/21672160-avaudioengine-tutorial-for-ios-getting-started/page/2)
- [Bring advanced speech-to-text with SpeechAnalyzer - WWDC25](https://developer.apple.com/videos/play/wwdc2025/277/)
- [Audio Visualization in Swift Using Metal and Accelerate](https://betterprogramming.pub/audio-visualization-in-swift-using-metal-accelerate-part-1-390965c095d7)

### Editeur et persistence

- [Mastering TextEditor in SwiftUI - Artem Novichkov](https://artemnovichkov.com/blog/mastering-text-editor-in-swiftui)
- [Rich text editing with AttributedString - Hacking with Swift](https://www.hackingwithswift.com/quick-start/swiftui/how-to-use-rich-text-editing-with-textview-and-attributedstring)
- [Core Data vs SwiftData 2025 - DistantJob](https://distantjob.com/blog/core-data-vs-swiftdata/)
- [Build an app with SwiftData - WWDC23](https://developer.apple.com/videos/play/wwdc2023/10154/)

### Invisibilite screen sharing

- [Screen Sharing Got Smarter on macOS - AddPipe Blog](https://blog.addpipe.com/screen-sharing-got-smarter-and-more-private-on-macos-understanding-the-system-private-window-picker/)
- [WindowSharingMode sample - GitHub](https://github.com/usagimaru/WindowSharingMode)
- [Tauri Issue #14200 - ScreenCaptureKit ignores sharingType](https://github.com/tauri-apps/tauri/issues/14200)
- [Apple Developer Forums - macOS 15 ScreenCaptureKit](https://developer.apple.com/forums/thread/792152)

---

## 4. App de reference

- [Moody - Your discreet notch prompter](https://moody.mjarosz.com/) - $59, l'app qu'on clone en open-source
- [Notchie.app](https://www.notchie.app/) - Autre teleprompter notch (nom similaire, attention)

> **Note** : Il existe deja une app "Notchie" sur le marche. Si le nom pose un probleme de trademark, envisager un rename (ex: NotchCue, Promptch, GhostCue).
