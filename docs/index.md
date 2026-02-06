# Notchie - Documentation

**Notchie** est un teleprompteur macOS open-source qui affiche du texte dans/sous le notch du MacBook, permettant un contact visuel naturel avec la camera.

Clone open-source de [Moody](https://moody.mjarosz.com/).

---

## Navigation

| Document | Description |
|----------|-------------|
| [roadmap.md](./roadmap.md) | **Roadmap** - suivi de progression tache par tache |
| [architecture.md](./architecture.md) | Choix technologique, structure projet, stack |
| [features.md](./features.md) | Toutes les 12 features detaillees |
| [macos-apis.md](./macos-apis.md) | APIs macOS cles avec exemples de code Swift |
| [implementation-plan.md](./implementation-plan.md) | Plan d'implementation phase par phase |
| [references.md](./references.md) | Projets open-source, sources, liens utiles |

---

## Specs rapides

| Spec | Valeur |
|------|--------|
| Plateforme | macOS 14.0+ |
| Langage | Swift 5.9+ |
| UI Framework | SwiftUI + AppKit (NSPanel) |
| Persistence | SwiftData |
| Audio | AVAudioEngine (AVFoundation) |
| Licence | MIT |
| Architecture | MVVM |

---

## Features (clone de Moody)

1. **Voice activated** - Le texte defile quand tu parles, pause quand tu t'arretes
2. **Discreet to others** - Invisible pendant le screen sharing (best effort)
3. **Positioned at your camera** - Contenu directement sous la camera/notch
4. **Floating window** - Fenetre flottante repositionnable et redimensionnable
5. **Pause** - Hover pour pause/resume instantane
6. **Control the pace** - Scroll manuel + vitesse ajustable en temps reel
7. **Customize prompter size** - Taille de fenetre et texte ajustables
8. **Customize text color** - Couleur de texte personnalisable
9. **Voice visual feedback** - Beam visuel qui repond au volume vocal
10. **Countdown timer** - Timer avant de commencer la presentation
11. **Your content stays private** - 100% local, zero cloud
12. **Built-in editor** - Editeur de scripts integre
