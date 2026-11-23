#!/usr/bin/env bash
# Verteilt dr-tabelle.ts, dr-tabelle.css und confirm_dialog.ts aus diesem Ordner in die Projekte.
#
#   ./dr-tabelle-verteilen.sh              Status: welche Projektdatei ist gleich, veraltet oder lokal geändert
#   ./dr-tabelle-verteilen.sh --kopieren   veraltete Dateien ersetzen (lokal geänderte bleiben, mit Diff)
#   ./dr-tabelle-verteilen.sh --erzwingen  alle abweichenden Dateien ersetzen, auch lokal geänderte
#   ./dr-tabelle-verteilen.sh --von duennqs   Dateien eines Projekts hierher holen (nach Änderung im Projekt)
#
# „veraltet“ = die Projektdatei entspricht einer früher hier committeten Fassung.
# Neue Fassung erst hier committen, dann verteilen; danach in jedem Projekt bauen und testen.

set -u
QUELLE="$(cd "$(dirname "$0")" && pwd)"
BASIS="$(dirname "$QUELLE")"
DATEIEN=(dr-tabelle.ts dr-tabelle.css confirm_dialog.ts)

# Projekt -> Zielordner je Datei (Name des Projekts = Ordner in ~/git-code)
ziel() {   # $1 Projekt, $2 Datei
   case "$1:$2" in
      d2beam-gui-5-11-2026-claude:confirm_dialog.ts) echo "src/pages" ;;
      *) echo "src/components" ;;
   esac
}
PROJEKTE=(duennqs quer_2 d2beam-gui-5-11-2026-claude)

modus="${1:-status}"

if [[ "$modus" == "--von" ]]; then
   p="${2:?Projekt angeben, z. B. --von duennqs}"
   for d in "${DATEIEN[@]}"; do
      f="$BASIS/$p/$(ziel "$p" "$d")/$d"
      if ! cmp -s "$f" "$QUELLE/$d"; then cp "$f" "$QUELLE/$d"; echo "geholt: $p/$(ziel "$p" "$d")/$d"; fi
   done
   git -C "$QUELLE" status --short
   exit 0
fi

# Ist $1 (Datei) gleich einer früher committeten Fassung von $2 (Name)?
frueher_verteilt() {
   local h
   for h in $(git -C "$QUELLE" log --format=%H -- "$2" 2>/dev/null); do
      git -C "$QUELLE" show "$h:$2" 2>/dev/null | cmp -s - "$1" && return 0
   done
   return 1
}

if [[ -n "$(git -C "$QUELLE" status --porcelain -- "${DATEIEN[@]}")" ]]; then
   echo "Hinweis: Änderungen in $QUELLE noch nicht committet."
fi

for p in "${PROJEKTE[@]}"; do
   for d in "${DATEIEN[@]}"; do
      rel="$p/$(ziel "$p" "$d")/$d"
      f="$BASIS/$rel"
      if [[ ! -f "$f" ]]; then echo "FEHLT        $rel"; continue; fi
      if cmp -s "$f" "$QUELLE/$d"; then echo "gleich       $rel"; continue; fi
      if frueher_verteilt "$f" "$d"; then
         if [[ "$modus" == "--kopieren" || "$modus" == "--erzwingen" ]]; then
            cp "$QUELLE/$d" "$f"; echo "ERSETZT      $rel"
         else
            echo "veraltet     $rel"
         fi
      else
         if [[ "$modus" == "--erzwingen" ]]; then
            cp "$QUELLE/$d" "$f"; echo "ERSETZT (!)  $rel  (lokale Änderung überschrieben)"
         else
            echo "LOKAL GEÄND. $rel  – nicht ersetzt; übernehmen mit --von $p oder überschreiben mit --erzwingen"
            [[ "$modus" == "--kopieren" ]] && diff -u "$QUELLE/$d" "$f" | head -40
         fi
      fi
   done
done
