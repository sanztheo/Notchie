# Plan d'implementation - Notchie

Implementation en 4 phases, de MVP a feature-complete.

---

## Phase 1 : Core MVP (Semaine 1-2)

**Objectif** : Fenetre flottante avec texte defilant + editeur basique

### Taches

1. **Setup projet Xcode**
   - Creer le projet macOS SwiftUI
   - Configurer SwiftData
   - Target macOS 14.0+
   - Ajouter Info.plist avec permissions

2. **FloatingPanel (NSPanel)**
   - Subclass NSPanel
   - Fenetre noire, deplacable, redimensionnable
   - Reste au-dessus des autres fenetres
   - `.fullScreenAuxiliary` pour rester sur fullscreen

3. **PrompterView (texte defilant)**
   - Affichage du texte en grand (monospace, blanc sur noir)
   - Defilement automatique avec Timer 60fps
   - Play / Pause basique (barre espace)
   - Controle de vitesse (Cmd+Up/Down)

4. **EditorView (editeur de scripts)**
   - SwiftUI TextEditor
   - Sauvegarder/charger des scripts (SwiftData)
   - Liste des scripts existants
   - Compteur de mots + duree estimee

5. **Navigation editeur <-> prompteur**
   - Bouton "Presenter" dans l'editeur
   - Ouvre le FloatingPanel avec le texte du script
   - Bouton "Retour editeur" dans le prompteur

### Resultat Phase 1
> Une app fonctionnelle : on ecrit un script, on clique "Presenter", le texte defile dans une fenetre flottante.

---

## Phase 2 : Positionnement Notch + Invisibilite (Semaine 3)

**Objectif** : Se positionner au notch et etre invisible en screen sharing

### Taches

1. **NotchDetector**
   - Detecter si le Mac a un notch
   - Calculer les dimensions et position du notch
   - Fallback pour Macs sans notch

2. **Positionnement intelligent**
   - Mode "Notch" : fenetre centree sous le notch, largeur optimale
   - Mode "Floating" : fenetre libre, position sauvegardee
   - Toggle entre les deux modes

3. **Invisibilite screen sharing**
   - `window.sharingType = .none`
   - Window level assistive tech
   - `collectionBehavior = [.ignoresCycle, .stationary, .canJoinAllSpaces]`
   - Toggle visible/invisible
   - Indicateur visuel de l'etat (icone cadenas)

4. **Multi-ecran**
   - Detecter l'ecran principal (celui avec le notch)
   - Permettre de deplacer le prompteur sur un autre ecran
   - Re-detecter le notch si l'ecran change

### Resultat Phase 2
> Le prompteur se positionne automatiquement au notch et est invisible pendant les calls Zoom.

---

## Phase 3 : Voice Activation (Semaine 4)

**Objectif** : Defilement controle par la voix

### Taches

1. **AudioEngine**
   - Setup AVAudioEngine avec tap sur inputNode
   - Calcul RMS en temps reel
   - Gestion permission microphone

2. **VoiceDetector**
   - VAD basee sur seuil RMS
   - Debounce speaking/silence (eviter les faux positifs)
   - Sensibilite configurable

3. **Integration avec ScrollController**
   - Speaking = scroll
   - Silence = pause (deceleration douce)
   - Vitesse proportionnelle au volume (optionnel)

4. **VoiceBeamView**
   - Visualisation du niveau audio
   - Arc/beam anime
   - Couleur dynamique selon intensite

5. **Pause au hover**
   - Tracking area sur la fenetre
   - Mouse enter = pause
   - Mouse exit = resume (sauf si pause manuelle)
   - Icone pause/play au hover

### Resultat Phase 3
> Le texte defile automatiquement quand on parle et s'arrete quand on fait une pause vocale.

---

## Phase 4 : Polish et Customisation (Semaine 5)

**Objectif** : Toutes les features restantes + polish

### Taches

1. **Countdown Timer**
   - Overlay 3-2-1-Go
   - Animation scale + fade
   - Duree configurable (3s, 5s, 10s)
   - Son optionnel

2. **Customisation couleur de texte**
   - Presets de couleurs (blanc, vert, jaune, cyan, rose)
   - ColorPicker custom
   - Persistence @AppStorage

3. **Customisation taille**
   - Slider taille de texte (14-72pt)
   - Raccourcis Cmd+Plus/Minus
   - Persistence @AppStorage

4. **Raccourcis clavier**
   - Cmd+Space : toggle presentation
   - Cmd+Up/Down : vitesse
   - Cmd+Plus/Minus : taille texte
   - Cmd+Shift+I : toggle invisible
   - Cmd+Shift+P : toggle notch/floating

5. **Settings View**
   - Preferences centralisees
   - Sensibilite micro
   - Duree countdown
   - Couleur et taille par defaut
   - Reset to defaults

6. **Menu bar icon (optionnel)**
   - NSStatusItem dans la barre de menu
   - Acces rapide : toggle prompteur, changer script, settings

7. **Polish**
   - Animations fluides
   - Transitions entre editeur et prompteur
   - Gestion erreurs (pas de micro, pas de notch)
   - About / Credits

### Resultat Phase 4
> App complete, toutes les features de Moody reproduites.

---

## Resume des phases

| Phase | Duree | Features |
|-------|-------|----------|
| 1 - Core MVP | 2 sem | Fenetre flottante + texte defilant + editeur |
| 2 - Notch + Invisible | 1 sem | Positionnement notch + invisibilite screen sharing |
| 3 - Voice | 1 sem | Defilement vocal + beam visual + pause hover |
| 4 - Polish | 1 sem | Countdown + couleurs + tailles + raccourcis + settings |

**Total estime : ~5 semaines**

---

## Post-launch (v2+)

- [ ] Import/export Markdown
- [ ] Themes (pas juste la couleur du texte, mais des themes complets)
- [ ] Mode miroir (texte inverse pour teleprompter physique)
- [ ] Telecommande depuis iPhone (via Multipeer Connectivity)
- [ ] Raccourcis configurables par l'utilisateur
- [ ] Widget menu bar avec timer
- [ ] Support VoiceOver / accessibilite
- [ ] Localisation (FR, EN, ES, DE, etc.)
