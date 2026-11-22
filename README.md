# Wanderlore

Ein Modpack für Luanti auf Basis von Minetest Game, in dem man durch Entdecken wächst statt durch Graben.

Das Projekt ist in Entwicklung. Es gibt das Grundgerüst: ein Modpack, das lädt, aber noch nichts erzeugt. Die Welt ist leer.

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
| `sources.toml` | was Wanderlore zum Laufen braucht, in fester Version |
| `scripts/` | Einrichten, Prüfen, Starten |
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

startet einen Server ohne Fenster auf einer frischen Welt und meldet, ob alle Mods ohne Fehler laden.

```bash
scripts/run.sh
```

startet das Spiel mit der Testwelt. Nach einer Änderung am Generator braucht es eine neue Welt:

```bash
scripts/run.sh --new
```

Heißt das Programm nicht `luanti`, lässt es sich mit `LUANTI=/pfad/zum/programm` angeben.

## Lizenz

Der eigene Code steht unter der [LGPL 3.0](LICENSE). Übernommene Medien behalten ihre Lizenzen; sie stehen in [docs/medien.md](docs/medien.md).
