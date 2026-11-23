# dr-tabelle

Gemeinsame Tabellen-Komponente `<dr-tabelle>` (Lit) für duennqs, quer_2 und d2beam-gui.
Hier liegt die einzige gepflegte Fassung; die Projekte enthalten Kopien.

| Datei | Ziel im Projekt |
|---|---|
| `dr-tabelle.ts`, `dr-tabelle.css` | `src/components/` |
| `confirm_dialog.ts` | `src/components/` (d2beam-gui: `src/pages/`) |

Alles Projektspezifische (Übersetzung `msg`/`str`, `berechnungErforderlich`, `touch_support_table`,
`Detect`, Querschnittsnamen für Auswahlspalten, `write`, `ConfirmDialog`) importiert die Tabelle aus
`src/components/tabelle_umgebung.ts` des jeweiligen Projekts. Diese Datei wird **nicht** verteilt.

## Ablauf bei einer Änderung
1. Hier ändern (oder im Projekt ändern/testen und mit `./dr-tabelle-verteilen.sh --von <projekt>` holen).
2. Hier committen.
3. `./dr-tabelle-verteilen.sh` (Status) und `./dr-tabelle-verteilen.sh --kopieren`.
4. In jedem Projekt `npm run build`, testen, committen, hochladen.
5. `./dr-tabelle-pushen.sh` (zeigt, was gepusht würde) und `./dr-tabelle-pushen.sh --push`: pusht dieses Repo
   und alle Projekte mit lokalen Commits. Repos, auf denen GitHub neuere Commits hat, werden übersprungen.

Neues Projekt: in `dr-tabelle-verteilen.sh` bei `PROJEKTE` (und ggf. `ziel()`) eintragen und eine
`tabelle_umgebung.ts` nach dem Muster von quer_2 (nur Deutsch) oder duennqs (mehrsprachig) anlegen.
