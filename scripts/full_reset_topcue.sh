#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

APP_NAME="TopCue"
BUNDLE_ID="sanz.TopCue"
LOGS_DIR="$REPO_ROOT/docs/logs"

remove_path() {
    local target="$1"
    if [[ -e "$target" ]]; then
        rm -rf "$target"
        echo "[TopCue Reset] Supprime: $target"
    else
        echo "[TopCue Reset] Absent: $target"
    fi
}

echo "[TopCue Reset] Debut: $(date)"
echo "[TopCue Reset] Repo: $REPO_ROOT"

echo
echo "[TopCue Reset] Step 1/6: Arret de l'app"
pkill -x "$APP_NAME" >/dev/null 2>&1 || true

echo
echo "[TopCue Reset] Step 2/6: Nettoyage build local"
shopt -s nullglob
for path in "$HOME"/Library/Developer/Xcode/DerivedData/TopCue-*; do
    remove_path "$path"
done
shopt -u nullglob
remove_path "$REPO_ROOT/TopCue/build"
remove_path "$REPO_ROOT/TopCue/.build"

echo
echo "[TopCue Reset] Step 3/6: Nettoyage donnees application"
remove_path "$HOME/Library/Containers/$BUNDLE_ID"
remove_path "$HOME/Library/Application Support/$APP_NAME"
remove_path "$HOME/Library/Caches/$BUNDLE_ID"
remove_path "$HOME/Library/Caches/$APP_NAME"
remove_path "$HOME/Library/Saved Application State/$BUNDLE_ID.savedState"
remove_path "$HOME/Library/Preferences/$BUNDLE_ID.plist"

echo
echo "[TopCue Reset] Step 4/6: Nettoyage defaults"
defaults delete "$BUNDLE_ID" >/dev/null 2>&1 || true
echo "[TopCue Reset] defaults supprimes pour $BUNDLE_ID"

echo
echo "[TopCue Reset] Step 5/6: Reset permissions microphone (TCC)"
tccutil reset Microphone "$BUNDLE_ID" >/dev/null 2>&1 || true
echo "[TopCue Reset] TCC Microphone reset pour $BUNDLE_ID"

echo
echo "[TopCue Reset] Step 6/6: Nettoyage logs locaux"
if [[ "${1:-}" == "--keep-logs" ]]; then
    echo "[TopCue Reset] Logs conserves (--keep-logs)"
else
    remove_path "$LOGS_DIR"
    mkdir -p "$LOGS_DIR"
    echo "[TopCue Reset] Dossier logs recree: $LOGS_DIR"
fi

echo
echo "[TopCue Reset] Termine: $(date)"
echo "[TopCue Reset] Tu peux relancer avec: ./scripts/launch_with_logs.sh"
