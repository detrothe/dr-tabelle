#!/usr/bin/env bash
# Pusht dr-tabelle und alle Projekte aus dr-tabelle-verteilen.sh, die lokale Commits haben.
#
#   ./dr-tabelle-pushen.sh          zeigen, was gepusht würde
#   ./dr-tabelle-pushen.sh --push   wirklich pushen
#
# Gepusht wird jeweils nur der aktuelle Branch auf seinen Upstream. Nicht committete Änderungen
# werden nur gemeldet, nicht mitgenommen.

set -u
QUELLE="$(cd "$(dirname "$0")" && pwd)"
BASIS="$(dirname "$QUELLE")"
PROJEKTE=($(sed -n 's/^PROJEKTE=(\(.*\))/\1/p' "$QUELLE/dr-tabelle-verteilen.sh"))

modus="${1:-zeigen}"

for p in dr-tabelle "${PROJEKTE[@]}"; do
   d="$BASIS/$p"
   branch="$(git -C "$d" branch --show-current)"
   git -C "$d" fetch -q 2>/dev/null || echo "$p: fetch fehlgeschlagen (offline?)"
   vor="$(git -C "$d" rev-list --count '@{u}..HEAD' 2>/dev/null || echo '?')"
   hinter="$(git -C "$d" rev-list --count 'HEAD..@{u}' 2>/dev/null || echo '?')"
   offen="$(git -C "$d" status --porcelain --untracked-files=no | wc -l)"

   printf '%-32s %-8s %s Commit(s) zu pushen' "$p" "$branch" "$vor"
   [[ "$hinter" != "0" ]] && printf ', %s hinter GitHub (erst pullen!)' "$hinter"
   [[ "$offen" != "0" ]] && printf ', %s Datei(en) nicht committet' "$offen"
   echo

   if [[ "$modus" == "--push" && "$vor" != "0" && "$vor" != "?" ]]; then
      if [[ "$hinter" != "0" ]]; then
         echo "   -> übersprungen, weil GitHub neuere Commits hat"
      else
         git -C "$d" push && echo "   -> gepusht"
      fi
   fi
done

[[ "$modus" != "--push" ]] && echo && echo "Zum Pushen: $0 --push"
