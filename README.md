# Wanderlore

Ein Modpack für Luanti auf Basis von Minetest Game, in dem man durch Entdecken wächst statt durch Graben.

Das Projekt ist in Entwicklung. Es gibt den Prototyp des Generators: drei Biome mit eigener Landschaftsform, noch ohne Bewuchs, Erze und Höhlen. Vom Spiel selbst ist noch nichts gebaut.

- [Konzept](docs/konzept.md)
- [Arbeitsplan](docs/arbeitsplan.md)
- [Recherche](docs/recherche.md)
- [Fremde Medien und ihre Lizenzen](docs/medien.md)
- [Regeln für die Zusammenarbeit mit Claude](CLAUDE.md)

Verwandt: der [Wanderlore-Katalog](https://github.com/peddn/wanderlore-catalog) mit Monstern und Tieren zum Auswählen.

## Aufbau

| Pfad | Inhalt |
| --- | --- |
| `modpack/` | das Modpack mit allen eigenen Mods |
| `devmods/` | Hilfen für die Entwicklung, nicht Teil des Spiels |
| `sources.toml` | was Wanderlore zum Laufen braucht, in fester Version |
| `scripts/` | Einrichten, Prüfen, Starten, Messen, Screenshots |
| `docs/` | Konzept, Arbeitsplan, Recherche, Skizzen |

## Einrichten und starten

Nötig sind Luanti 5.18, `git` und `bash`.

```bash
scripts/setup.sh
```

holt Minetest Game in der Version aus `sources.toml` und legt eine Testwelt an. Alles landet im Ordner `.dev/`, der nicht eingecheckt wird. Die eigenen Welten und Einstellungen bleiben unberührt.

```bash
scripts/check.sh
```

startet einen Server ohne Fenster auf einer frischen Welt und meldet, ob alle Mods ohne Fehler laden und der Generator die Welt um den Startpunkt ohne Fehler erzeugt.

```bash
scripts/run.sh
```

startet das Spiel mit der Testwelt. Nach einer Änderung am Generator braucht es eine neue Welt:

```bash
scripts/run.sh --new
```

In der Testwelt gibt es zwei Befehle für die Entwicklung: `/wl_where` nennt Biom und Zone am eigenen Standort, `/wl_goto <biom>` springt in die nächste Zelle eines Bioms, zum Beispiel `/wl_goto old_wood`.

```bash
scripts/measure.sh
```

misst, wie lange der Generator je Portion der Welt braucht. Mit `scripts/measure.sh v7` misst es zum Vergleich Luantis eigenen Generator.

```bash
scripts/shots.sh
```

macht Screenshots aller Biome und ihrer Grenzen und legt sie in `.dev/shots/` ab. Dafür braucht es `Xvfb` und ImageMagick. Mit einem Wort dahinter, etwa `scripts/shots.sh old_wood`, entstehen nur die Bilder mit diesem Wort im Namen.

```bash
scripts/map.sh
```

zeichnet in wenigen Sekunden eine Karte von oben mit Relief nach `.dev/map.png`, ohne die Welt zu erzeugen. `scripts/map.sh blossom_downs 2` zeigt die nächste Zelle eines Bioms mit 2 Blöcken je Bildpunkt.

Heißt das Programm nicht `luanti`, lässt es sich mit `LUANTI=/pfad/zum/programm` angeben.

## Lizenz

Der eigene Code steht unter der [LGPL 3.0](LICENSE). Übernommene Medien behalten ihre Lizenzen; sie stehen in [docs/medien.md](docs/medien.md).
