# Roadmap - TopCue

Suivi de progression du projet. Chaque tache est marquee : fait, en cours, ou a faire.

---

## Phase 1 : Core MVP ✅

> Fenetre flottante + texte defilant + editeur basique

| # | Tache | Statut |
|---|-------|--------|
| 1.1 | Setup projet Xcode (macOS 14+, SwiftData, Info.plist, entitlements) | ✅ Done |
| 1.2 | Modele `Script` SwiftData (title, content, dates, favorite, wordCount, duration) | ✅ Done |
| 1.3 | `PrompterState` (@Observable) - etat reactif play/pause/idle/speed/offset | ✅ Done |
| 1.4 | `ScrollController` - defilement continu via Combine Timer 60fps | ✅ Done |
| 1.5 | `FloatingPanel` (NSPanel) - fenetre flottante non-activating | ✅ Done |
| 1.6 | `WindowManager` - gestion lifecycle panel + hosting SwiftUI | ✅ Done |
| 1.7 | `PrompterView` - texte defilant, fond noir, controles play/pause/vitesse | ✅ Done |
| 1.8 | `EditorView` + `ScriptListView` - editeur + sidebar liste scripts | ✅ Done |
| 1.9 | `TopCueApp` - entry point, WindowGroup, menu Presentation, raccourcis | ✅ Done |
| 1.10 | `Constants` - toutes les constantes centralisees | ✅ Done |

---

## Phase 1.5 : Integration Notch ✅

> Integration visuelle dans le notch MacBook (style boring.notch / Moody)

| # | Tache | Statut |
|---|-------|--------|
| 1.5.1 | `FloatingPanel` refait : transparent, borderless, level mainMenu+3, immobile | ✅ Done |
| 1.5.2 | `NotchShape` - forme custom qui imite les coins du notch (quadratic curves) | ✅ Done |
| 1.5.3 | `WindowManager` - positionnement colle au haut de l'ecran (fusionne avec notch) | ✅ Done |
| 1.5.4 | `PrompterView` - fond transparent + contenu noir clippe NotchShape | ✅ Done |
| 1.5.5 | Taille compacte (310x92pt) - petit encart sous le notch comme Moody | ✅ Done |
| 1.5.6 | Demarrage automatique du defilement au lancement du prompteur | ✅ Done |

---

## Phase 1.6 : Design Editeur ✅

> Redesign de l'editeur de scripts avec un style Notion (pur, minimal, blanc)

| # | Tache | Statut |
|---|-------|--------|
| 1.6.1 | Sidebar redesign : fond propre, items sans bordure, selection subtile, hover effects | ✅ Done |
| 1.6.2 | Titre du script : grand TextField sans bordure (style Notion page title) | ✅ Done |
| 1.6.3 | Metadata sous le titre (mots, duree, date) discrets | ✅ Done |
| 1.6.4 | TextEditor propre sans chrome, police systeme, pleine largeur | ✅ Done |
| 1.6.5 | Bouton Presenter discret (apparait au hover) | ✅ Done |
| 1.6.6 | Etat vide design (pas de script selectionne) | ✅ Done |
| 1.6.7 | Animations hover subtiles | 🔄 Partiel — effets de hover basiques presents, animations avancees a affiner |

---

## Phase 2 : Positionnement intelligent + Invisibilite

> Detection dynamique du notch, mode floating, invisibilite screen sharing

| # | Tache | Statut |
|---|-------|--------|
| 2.1 | `NotchDetector` - detection notch via safeAreaInsets + auxiliaryTopLeftArea | 🔲 A faire |
| 2.2 | Calcul dynamique de la largeur du notch (varie selon modele MacBook) | 🔲 A faire |
| 2.3 | Mode Notch vs Mode Floating (toggle) | 🔲 A faire |
| 2.4 | Position sauvegardee en mode floating (@AppStorage) | 🔲 A faire |
| 2.5 | `window.sharingType = .none` + window level assistive tech | 🔲 A faire |
| 2.6 | Toggle visible/invisible avec indicateur visuel | 🔲 A faire |
| 2.7 | Support multi-ecran (detecter l'ecran avec notch) | 🔲 A faire |
| 2.8 | Fallback Macs sans notch (position sous menu bar) | 🔲 A faire |

---

## Phase 3 : Voice Activation

> Defilement controle par la voix

| # | Tache | Statut |
|---|-------|--------|
| 3.1 | `AudioEngine` - wrapper AVAudioEngine, tap sur inputNode | 🔲 A faire |
| 3.2 | `VoiceDetector` - VAD basee sur seuil RMS, debounce speaking/silence | 🔲 A faire |
| 3.3 | Sensibilite configurable | 🔲 A faire |
| 3.4 | Integration VoiceDetector <-> ScrollController (speaking = scroll, silence = pause douce) | 🔲 A faire |
| 3.5 | `VoiceBeamView` - arc/beam anime selon niveau audio | 🔲 A faire |
| 3.6 | Couleur dynamique selon intensite (bleu -> violet -> rouge) | 🔲 A faire |
| 3.7 | Pause au hover (mouse enter = pause, mouse exit = resume) | ✅ Done |
| 3.8 | Permission micro - demande au premier lancement | 🔲 A faire |

---

## Phase 4 : Polish et Customisation

> Countdown, couleurs, tailles, raccourcis, settings

| # | Tache | Statut |
|---|-------|--------|
| 4.1 | Countdown Timer overlay (3-2-1-Go avec animation scale+fade) | 🔲 A faire |
| 4.2 | Duree countdown configurable (3s, 5s, 10s) | 🔲 A faire |
| 4.3 | Presets couleur texte (blanc, vert matrix, jaune, cyan, rose) | 🔄 Partiel — constantes definies, pas de UI |
| 4.4 | ColorPicker custom pour couleur libre | 🔲 A faire |
| 4.5 | Slider taille texte (14-72pt) + raccourcis Cmd+Plus/Minus | 🔄 Partiel — zoom in/out dans le prompteur (14-36pt) + persistance @AppStorage, pas de slider dans settings |
| 4.6 | Raccourcis clavier complets (espace, vitesse, taille, invisible, mode) | 🔄 Partiel — raccourcis play/pause/vitesse presents, raccourcis zoom et mode manquants |
| 4.7 | `SettingsView` - preferences centralisees | 🔲 A faire |
| 4.8 | Menu bar icon (NSStatusItem) - acces rapide | 🔲 A faire |
| 4.9 | Animations et transitions fluides | 🔄 Partiel — transitions basiques presentes dans les vues |
| 4.10 | Gestion erreurs (pas de micro, pas de notch) | 🔲 A faire |

---

## Post-launch (v2+)

| # | Feature | Statut |
|---|---------|--------|
| 5.1 | Import/Export Markdown (.txt, .md) | 🔲 A faire |
| 5.2 | Themes complets (pas juste la couleur) | 🔄 Partiel — systeme NotionTheme clair/sombre dans Constants, pas de selecteur |
| 5.3 | Mode miroir (texte inverse pour teleprompter physique) | 🔲 A faire |
| 5.4 | Telecommande iPhone (Multipeer Connectivity) | 🔲 A faire |
| 5.5 | Raccourcis configurables par l'utilisateur | 🔲 A faire |
| 5.6 | Widget menu bar avec timer | 🔲 A faire |
| 5.7 | Support VoiceOver / accessibilite | 🔲 A faire |
| 5.8 | Localisation (FR, EN, ES, DE) | 🔲 A faire |

---

## Resume

| Phase | Statut | Progression |
|-------|--------|-------------|
| 1 - Core MVP | ✅ Complete | 10/10 |
| 1.5 - Integration Notch | ✅ Complete | 6/6 |
| 1.6 - Design Editeur | ✅ Quasi complete | 6/7 (+1 partiel) |
| 2 - Notch + Invisible | 🔲 A faire | 0/8 |
| 3 - Voice Activation | 🔄 En cours | 1/8 |
| 4 - Polish | 🔄 En cours | 0/10 (+4 partiels) |
| 5 - Post-launch | 🔲 A faire | 0/8 (+1 partiel) |

**Total : 23/57 taches completees + 6 partielles (~40-50% de progression reelle)**
