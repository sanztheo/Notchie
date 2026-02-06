<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-000000?style=flat-square&logo=apple&logoColor=white" alt="macOS 14+">
  <img src="https://img.shields.io/badge/swift-5.9%2B-F05138?style=flat-square&logo=swift&logoColor=white" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/UI-SwiftUI%20%2B%20AppKit-007AFF?style=flat-square" alt="SwiftUI + AppKit">
  <img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="MIT License">
  <img src="https://img.shields.io/badge/dependencies-zero-brightgreen?style=flat-square" alt="Zero Dependencies">
</p>

<h1 align="center">TopCue</h1>

<p align="center">
  <strong>The open-source teleprompter that lives in your MacBook's notch.</strong><br>
  Speak naturally. Maintain eye contact. Stay focused.
</p>

<p align="center">
  <em>A free, privacy-first alternative to <a href="https://moody.mjarosz.com/">Moody</a> — built with SwiftUI & AppKit.</em>
</p>

---

## Why TopCue?

Most teleprompter apps put your script far from your camera. You end up reading from the bottom of your screen while your eyes drift away from the lens. **Your audience notices.**

TopCue places your script **right next to the camera** — inside the MacBook notch — so your gaze stays natural during calls, recordings, and presentations.

| Without TopCue | With TopCue |
|:---:|:---:|
| Eyes wander, reading from notes | Eyes stay near camera, natural delivery |

## Features

### Available Now

- **Notch Integration** — Script text visually merges with the MacBook notch, creating a seamless prompter right below the camera
- **Smooth 60fps Scrolling** — Butter-smooth text scrolling powered by Combine timers
- **Built-in Script Editor** — Notion-inspired editor with a clean, minimal interface
- **Script Management** — Create, edit, search, and favorite your presentation scripts
- **Play / Pause Controls** — Start and stop scrolling with keyboard shortcuts
- **Speed Control** — Adjust scrolling speed on the fly (`Cmd+↑` / `Cmd+↓`)
- **Text Size Adjustment** — Zoom in/out to match your comfort (`Cmd++` / `Cmd+-`)
- **Hover to Pause** — Mouse over the prompter to instantly pause, move away to resume
- **Always on Top** — Stays visible over all apps, including fullscreen windows
- **Multi-Space Support** — Visible across all macOS Spaces/desktops
- **100% Local & Private** — Zero network calls, zero analytics, zero cloud. Your scripts never leave your machine
- **Persistent Storage** — Scripts auto-save locally via SwiftData

### Coming Soon

- **Voice Activation** — Text scrolls when you speak, pauses when you stop
- **Screen Sharing Invisibility** — Hidden from Zoom, Meet, and other screen sharing tools (best-effort)
- **Floating Window Mode** — Detach from the notch, place anywhere, resize freely
- **Voice Visual Feedback** — Animated beam that responds to your speaking volume
- **Countdown Timer** — 3-2-1-Go preparation countdown before presentations
- **Text Color Customization** — Presets (white, matrix green, cyan...) + custom color picker
- **Settings Panel** — Centralized preferences for all options
- **Menu Bar Widget** — Quick access from the menu bar
- **Mirror Mode** — Reversed text for physical teleprompter displays
- **iPhone Remote Control** — Control TopCue from your phone via Multipeer Connectivity

## Getting Started

### Requirements

| Requirement | Version |
|------------|---------|
| macOS | 14.0+ (Sonoma) |
| Xcode | 15.0+ |
| Swift | 5.9+ |

### Build & Run

```bash
# Clone the repository
git clone https://github.com/sanztheo/TopCue.git
cd TopCue

# Open in Xcode
open TopCue/TopCue.xcodeproj

# Build and run (⌘R)
```

> **Note:** TopCue uses only Apple-native frameworks — no external dependencies, no package managers, no setup headaches.

## How It Works

TopCue uses a transparent `NSPanel` positioned at the top of your screen, visually fusing with the MacBook notch through a custom `NotchShape` clip. The result: text appears to scroll out of the notch itself.

```
┌─────────────────────────────────────────┐
│           ┌───────────┐                 │  ← Physical notch (camera)
│           │  ■■■■■■■  │                 │
│           └─────┬─────┘                 │
│           ┌─────┴─────┐                 │
│           │  TopCue    │                 │  ← Transparent panel with text
│           │  scrolling │                 │
│           │   text...  │                 │
│           └───────────┘                 │
│                                         │
│         Your app / Zoom / Slides        │
└─────────────────────────────────────────┘
```

### Architecture

```
TopCue/
├── App/
│   ├── TopCueApp.swift           # Entry point, scenes & keyboard shortcuts
│   └── AppDelegate.swift         # NSApplicationDelegate lifecycle
├── Models/
│   ├── Script.swift              # SwiftData model for scripts
│   └── PrompterState.swift       # Observable playback state
├── Services/
│   └── ScrollController.swift    # 60fps scrolling engine (Combine)
├── Views/
│   ├── Editor/
│   │   ├── EditorView.swift      # Script editor (Notion-style)
│   │   └── ScriptListView.swift  # Sidebar with search & favorites
│   └── Prompter/
│       ├── PrompterView.swift    # Main teleprompter display
│       └── NotchShape.swift      # Custom shape matching notch curves
├── Windows/
│   ├── FloatingPanel.swift       # Transparent NSPanel subclass
│   └── WindowManager.swift       # Window lifecycle & positioning
└── Utils/
    └── Constants.swift           # Centralized constants & theme
```

**Key design decisions:**
- **MVVM** architecture with `@Observable` (Swift 5.9+, not legacy `ObservableObject`)
- **Hybrid SwiftUI + AppKit** — SwiftUI for views, AppKit for window management (`NSPanel` is required for always-on-top, non-activating behavior)
- **SwiftData** for local persistence — no Core Data boilerplate
- **Zero dependencies** — pure Apple SDK, small binary, fast launch

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Start Presentation | `Cmd+P` |
| Play / Pause | `Space` |
| Increase Speed | `Cmd+↑` |
| Decrease Speed | `Cmd+↓` |
| Zoom In | `Cmd++` |
| Zoom Out | `Cmd+-` |

## Roadmap

| Phase | Status | Progress |
|-------|--------|----------|
| **1 — Core MVP** | ✅ Complete | 10/10 |
| **1.5 — Notch Integration** | ✅ Complete | 6/6 |
| **1.6 — Editor Redesign** | 🔄 In Progress | 0/7 |
| **2 — Smart Positioning + Invisibility** | 🔲 Planned | 0/8 |
| **3 — Voice Activation** | 🔲 Planned | 0/8 |
| **4 — Polish & Customization** | 🔲 Planned | 0/10 |
| **5 — Post-launch (v2+)** | 🔲 Planned | 0/8 |

**Overall: 16/57 tasks completed (~28%)**

See the full [roadmap](docs/roadmap.md) for detailed task tracking.

## Comparison with Alternatives

| Feature | TopCue | [Moody](https://moody.mjarosz.com/) ($59) | [Notchie](https://notchie.app) ($30) | [NotchPrompter](https://notchprompter.com/) (Free) |
|---------|--------|-------|---------|---------------|
| Open Source | ✅ | ❌ | ❌ | ❌* |
| Notch Integration | ✅ | ✅ | ✅ | ✅ |
| Voice Activation | 🔜 | ✅ | ✅ | ✅ |
| Screen Share Invisible | 🔜 | ✅ | ✅ | ❌ |
| Floating Window | 🔜 | ✅ | ❌ | ❌ |
| Built-in Editor | ✅ | ✅ | ❌ | ❌ |
| 100% Private / Local | ✅ | ✅ | ✅ | ✅ |
| Price | **Free** | $59 | $30 | Free |
| macOS Requirement | 14+ | 14.7+ | 14+ | 13+ |

<sub>*NotchPrompter source available but not notarized — requires Apple Developer License to run.</sub>

## Contributing

Contributions are welcome! TopCue is in active development and there's plenty to do.

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/voice-activation`)
3. **Commit** your changes following Swift conventions
4. **Open** a Pull Request

Please follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) and the project's code quality rules in `CLAUDE.md`.

### Areas Where Help Is Appreciated

- Voice activation (AVAudioEngine + RMS-based VAD)
- Screen sharing invisibility research
- Multi-monitor support
- Accessibility (VoiceOver)
- Localization (EN, FR, ES, DE)

## Privacy

TopCue is built with privacy as a core principle:

- **No network requests** — the app never connects to the internet
- **No analytics or telemetry** — zero tracking of any kind
- **No cloud storage** — all scripts stored locally via SwiftData
- **No account required** — just open and use
- **Microphone access** — requested only for voice activation (optional), audio is never recorded or transmitted

## License

MIT License — see [LICENSE](LICENSE) for details.

Free to use, modify, and distribute. Commercial use allowed.

---

<p align="center">
  <strong>Built with SwiftUI & AppKit for macOS</strong><br>
  <sub>If TopCue helps you present better, consider giving it a ⭐</sub>
</p>
