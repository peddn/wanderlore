# CLAUDE.md

Anweisungen für die Zusammenarbeit an Wanderlore.

## Projekt

Wanderlore ist ein Modpack für Luanti auf Basis von Minetest Game. Man wächst durch Entdecken statt durch Graben: Man zieht durch eine in Zonen gegliederte Welt, sammelt Lore und schaltet damit Rezepte frei.

Drei Dateien führen, in dieser Reihenfolge lesen:

1. [`docs/konzept.md`](docs/konzept.md): was Wanderlore ist. Verbindlich.
2. [`docs/arbeitsplan.md`](docs/arbeitsplan.md): in welchen Meilensteinen gebaut wird.
3. [`docs/recherche.md`](docs/recherche.md): Quellen für Assets mit Lizenzen, Techniken, Vorbilder.

Die Skizzen unter `docs/weltkarte/` und `docs/landschaft/` sind Diskussionshilfen in Python, kein Spielcode. Sie zeigen die Verfahren, auf die sich der Autor festgelegt hat.

Verwandte Repositories:

- [`peddn/wanderlore-catalog`](https://github.com/peddn/wanderlore-catalog): zeigt 200 Monster und Tiere aus acht Mods in Luanti, zum Auswählen nach Nummer. Sein Aufbau mit `sources.toml`, `scripts/setup.sh` und `scripts/run.sh` ist das Vorbild für die Skripte hier.
- [`peddn/luanti-education-platform`](https://github.com/peddn/luanti-education-platform) (LEP): Wanderlore muss in dessen Welten laufen können, hängt aber nicht davon ab. Die Vorgaben stehen im Konzept.

## Stand

Stand 22.11.2026: Das Konzept steht, M0 und M1 sind gebaut, und von M2, der Weltkarte, der erste von drei Teilen. Das Modpack unter `modpack/` enthält nur `wl_world`. Der Mod erzeugt einen Kontinent aus drei Zonen und teilt die Biome auf dessen Zellen aus: in Zone 1 die drei ausgearbeiteten Biome mit eigener Landschaftsform, Oberfläche und Übergängen, in Zone 2 und 3 neun Platzhalter (`zone2_a` bis `zone3_d`), dahinter ein vorläufiges Meer. Bewuchs, Erze und Höhlen gibt es noch nicht. Er bringt die ersten eigenen Blöcke mit: vier Sumpfblöcke für Reed Meres in `nodes.lua`, mit sieben Texturen aus Extra Biomes, und Waldgras für Old Wood, das die Grastextur von Minetest Game im Spiel umfärbt. Es fehlen von M2 noch der zweite Teil, Meer und Inseln, und der dritte, die Schwellen an den Zonengrenzen.

- `scripts/setup.sh` richtet unter `.dev/` Spiel, Modpack und Testwelt ein. Die Testwelt hat den festen Startwert `wanderlore`, denselben wie `map.sh` und `shots.sh`; so passen Karten, Bilder und Koordinaten zur Welt des Autors.
- `scripts/check.sh` startet einen Server ohne Bildschirm auf frischer Welt, lässt den Generator die Portionen um den Startpunkt erzeugen und scheitert bei Fehlern oder Warnungen im Log. Es läuft vor jedem Pull Request.
- `scripts/measure.sh` misst die Zeit des Generators je Portion, `scripts/measure.sh v7` zum Vergleich Luantis Generator v7. Nach jeder größeren Änderung am Generator neu messen und die Zahlen im Arbeitsplan nachtragen.
- `scripts/shots.sh [text]` macht Screenshots aller Biome und ihrer Grenzen nach `.dev/shots/`, mit einem Text nur die Ansichten, deren Name ihn enthält, etwa `_above` oder `zone2_b`. Eine Ansicht dauert in der Cloud knapp eine Minute; alle zusammen sind es seit den Platzhaltern weit über fünfzig.
- `scripts/map.sh [biom] [blöcke je bildpunkt]` zeichnet in wenigen Sekunden eine Karte von oben mit Relief nach `.dev/map.png`. Das ist der schnellste Weg, eine Änderung an einer Höhenformel zu beurteilen, bevor man Screenshots macht. `scripts/map.sh world` zeichnet den ganzen Kontinent mit Zonengrenzen und einer Liste der Biome.
- `devmods/wl_dev` ist ein Hilfs-Mod außerhalb des Modpacks, den die Skripte nur in die Testwelten einbinden. Er stellt die Kamera, misst, setzt Tester auf die Oberfläche und bringt die Befehle `/wl_where` und `/wl_goto <biom>` mit.
- Der Code des Generators läuft in zwei Umgebungen: `init.lua` lädt ihn für die Fragen der anderen Mods, `mapgen.lua` lädt dieselben Dateien in Luantis Generator-Umgebung. Gemeinsame Dateien dürfen deshalb nur nutzen, was es in beiden gibt.
- `scripts/run.sh` startet den Client, mit `--new` auf frischer Welt.
- Jeder Mod schreibt am Ende seiner `init.lua` die Zeile `[<Name>] loaded` ins Log. `check.sh` wartet darauf.
- Ein neuer Mod kommt mit dem Meilenstein, der ihn braucht, nicht vorher als leere Hülle. Dasselbe gilt für Mobs Redo und 3D Armor in `sources.toml`.
- Fremde Dateien werden in [`docs/medien.md`](docs/medien.md) eingetragen.

Wer diese Datei liest und etwas anderes vorfindet, etwa weitere Mods unter `modpack/`, richtet sich nach dem Repository und nicht nach diesem Absatz, und bringt ihn auf den neuen Stand.

## Arbeitsregeln

1. **Gebaut wird erst nach Zustimmung.** Vor jeder Aufgabe beschreiben, was gebaut wird und wie, und auf Zustimmung warten. Der Autor hat früh gesagt: „Baue noch nichts“, und das gilt, bis er einen Meilenstein freigibt.
2. **Das Konzept führt.** Weicht eine Entscheidung vom Konzept ab, wird zuerst das Konzept angepasst, dann der Code. Neue Entscheidungen aus einem Gespräch werden noch im selben Zug ins Konzept eingetragen.
3. **Die Inhalte entscheidet der Autor.** Welche Biome, Feldfrüchte, Monster und Gerichte es gibt, wählt er aus. Dafür braucht er etwas zum Ansehen: Kataloge mit Nummern, Screenshots aus Luanti, Skizzen. Vorschläge machen und kennzeichnen, nicht stillschweigend festlegen.
4. **Widersprechen, wenn etwas das Projekt beschädigt**, etwa durch Doppelentwicklung oder große Verkomplizierung. Erst begründen, dann die Entscheidung des Autors umsetzen.
5. **Ehrlich über Geprüftes und Ungeprüftes.** Was nur im Code gelesen und nicht im Spiel gesehen wurde, wird so benannt. Schätzungen ohne Messung heißen Schätzung.
6. **Keine Rücksicht auf bereits erstellte Welten.** Das Projekt ist in Entwicklung und wird von niemandem sonst genutzt. Jede Änderung am Generator darf eine neue Welt verlangen.
7. **Sprache:** Code, Bezeichner, Kommentare und Commit-Nachrichten auf Englisch. Dokumentation und Gespräch auf Deutsch. Texte im Spiel stehen auf Englisch im Code, über `core.get_translator`, und bekommen eine deutsche Übersetzung über Luantis Übersetzungssystem. Das hat der Autor am 22.11.2026 bestätigt. Eine Übersetzungsdatei gibt es noch nicht.
8. **Dateien für den Autor als Markdown oder Bild.** Dokumente in Claudes eigenem Dokumentenformat ließen sich bei ihm nicht öffnen.

## Regeln aus dem Konzept, die jeden Code betreffen

Diese Regeln stehen im Konzept. Sie sind hier wiederholt, weil ein Verstoß spät auffällt und teuer ist.

- **Nur `wl_world` weiß, wo etwas liegt.** Kein anderer Mod fragt Koordinaten, Temperatur oder Feuchtigkeit ab. Die anderen Mods melden ihre Kräuter, Erze, Monster und Bauwerke bei `wl_world` mit Biom und Zone an und fragen sonst nur „welches Biom, welche Zone?“.
- **Nichts hängt an Luantis eigenen Generatoren.** Die Welt läuft mit `singlenode`. Höhlen, Dungeons, Biome und Bewuchs der eingebauten Generatoren gibt es nicht.
- **Der Himmel bleibt leer.** Oberhalb der Landschaft erzeugt der Generator nichts. LEP nutzt die Höhe ab 10.000.
- **Nur Assets aus fremden Mods, keine fremden Mods.** Zugelassene Abhängigkeiten sind Mobs Redo und 3D Armor, sonst keine. Eine weitere braucht die Zustimmung des Autors.
- **Jede fremde Datei wird eingetragen**, mit Autor, Lizenz und Quelle, bevor sie ins Repository kommt. Bei unklarer Lizenz nicht übernehmen, sondern nachfragen. Bekannter Fall: Paleotest.
- **Vegan-Regel:** Speisen sind rein pflanzlich. Tiere lassen sich nicht halten, züchten oder melken. Tierisches gibt es nur als Beute, etwa als seltene Zutat für Tränke.
- **Keine Inhalts-Schalter.** Einstellungen ändern Werte wie Dichte, Tempo und Schaden, nie ob es einen Inhalt gibt.
- **Rezepte, die an Lore hängen, gehören an eine Station.** Das normale Handwerksfeld kann nichts je Spieler sperren.
- **Was Tempo, Sprungkraft oder Schwerkraft eines Spielers ändert, geht über `player_monoids`,** damit es sich mit 3D Armor verträgt.
- **Mod-Kürzel `wl_`.** Eigener Code steht unter LGPL 3.0.

## Git

- Nie direkt auf `main` schreiben. Jede Aufgabe bekommt einen Zweig und einen Pull Request.
- Zweige heißen nach Meilenstein und Stichwort, auf Englisch: `m1-generator-prototype`, `m1-vegetation`, `m2-world-map`. Arbeiten außerhalb eines Meilensteins bekommen ein Präfix, etwa `docs/…`. Das hat der Autor am 22.11.2026 festgelegt und damit erlaubt, auf solche Zweige zu schreiben. Gibt eine Cloud-Sitzung einen anderen Namen vor, etwa `claude/…`, gilt trotzdem dieses Schema; lässt die Sitzung das nicht zu, einmal beim Autor nachfragen.
- Der Autor prüft und führt zusammen. Claude führt nie selbst zusammen.
- Ein Meilenstein, ein Pull Request. Größere Meilensteine dürfen in mehrere kleine Pull Requests zerfallen, jeder für sich lauffähig.
- Commit-Nachrichten auf Englisch, im Imperativ, ohne Präfixe wie `feat:`.
- Vor dem Weiterarbeiten an einem Zweig prüfen, ob sein Pull Request schon zusammengeführt ist. Dann von `main` neu abzweigen.

## Luanti in der Arbeitsumgebung

So lief es am 22.11.2026 in Claudes Arbeitsumgebung in der Cloud. Auf dem Rechner des Autors kann es anders sein.

**Einrichten**

```
curl -sS -O "https://ppa.launchpadcontent.net/minetestdevs/stable/ubuntu/pool/main/m/minetest/minetest_5.18.0-ppa0~ubuntu24.04.1_amd64.deb"
apt-get install -y ./minetest_5.18.0*.deb xvfb xdotool libgl1-mesa-dri imagemagick
```

Das Paket bringt das Programm `luanti` mit. Selbst kompilieren war nicht nötig. Fehlen dem Paket Abhängigkeiten, hilft vorher `apt-get update`.

Der Host `ppa.launchpadcontent.net` muss im Netzwerk der Cloud-Umgebung erlaubt sein. In der Umgebung „wanderlore“ ist er das, in der Standardumgebung nicht.

**Erreichbar** waren GitHub und Codeberg per `git clone`. ContentDB (`content.luanti.org`) war aus der Shell nicht erreichbar, nur über das Werkzeug zum Abrufen von Webseiten.

**Eigenes Benutzerverzeichnis.** Luanti legt alles unter `$HOME/.minetest` ab. Mit `HOME=<Ordner>` vor dem Aufruf bleibt eine Testumgebung für sich.

**Server ohne Bildschirm,** um zu prüfen, ob alles lädt:

```
HOME=<Ordner> timeout 25 luanti --server --config <conf> --world <Welt> --gameid minetest
```

In der Konfiguration braucht es dafür `ipv6_server = false` und `bind_address = 127.0.0.1`, sonst scheitert der Start am Netzwerk. Fehler stehen danach in `debug.txt` im Benutzerverzeichnis.

**Client mit Screenshots,** auf einem unsichtbaren Bildschirm:

```
Xvfb :9 -screen 0 1280x760x24 &
HOME=<Ordner> DISPLAY=:9 LIBGL_ALWAYS_SOFTWARE=1 luanti --config <conf> --world <Welt> --go &
DISPLAY=:9 import -window root bild.png
```

- Bis die Welt steht, vergehen etwa 20 bis 30 Sekunden.
- Zuverlässiger als feste Wartezeiten: Der Mod schreibt eine Zeile ins Log, und das Skript wartet auf diese Zeile. So entstanden die Kataloge.
- Klicks gehen mit `xdotool mousemove X Y click 1`.
- Die Kamera stellt man im Mod: Position und Blickrichtung des Spielers setzen, Schwerkraft auf null, Anzeigen ausblenden.
- Gerendert wird in Software. Das ist langsam; Messungen der Bildrate sagen dort nichts. Die Zeit, die der Generator je Portion braucht, lässt sich trotzdem messen.

**Fallstricke**

- Luantis Mod-Sicherheit folgt keinen Verknüpfungen, die aus einem Mod-Ordner hinausführen. Ein ganzer Mod-Ordner darf eine Verknüpfung sein, einzelne Dateien darin nicht. Auch ein ganzer Modpack-Ordner darf eine Verknüpfung sein; so bindet `setup.sh` das Modpack ein.
- Ein Mod mit dem Namen eines Mods aus dem Spiel ersetzt diesen.
- Alte Mods scheitern unter Luanti 5.18 teils an strengeren Prüfungen. Der Katalog zeigt in `mods/wl_catalog/compat.lua`, wie sich das ohne Eingriff in die Quelle ausgleichen lässt.
- Die Einstellungen des Generators stehen in der Welt, sobald sie einmal gestartet wurde. Wer sie ändert, braucht eine neue Welt.
- Lücken in Himmelsfarbe auf fernen, ebenen Flächen sind kein Fehler des Generators. Der Server schickt ferne Blöcke aus reiner Luft nicht an den Client. Abhilfe in der Testwelt: `block_send_optimize_distance = 32`. Näheres in der Recherche.
- Ein Fehler in der Generator-Umgebung beendet den Server. Die Meldung steht in der Logdatei.
- `ValueNoiseMap` verlangt für zweidimensionales Rauschen eine Größe mit `z = 1`, anders als die Dokumentation sagt.
- Aus dem Rückruf von `core.emerge_area` nicht gleich die nächste Anfrage stellen, sondern erst mit `core.after(0, ...)` herausspringen. Ohne das blieb der Server in einem Lauf hängen, in dem zugleich der Generator scheiterte; die Ursache ist nicht einzeln geprüft.

## Was der Autor zuletzt entschieden hat

Stand 22.11.2026, für den Einstieg in M0 und M1:

- Blossom Downs ist flach: Grundhöhe 12, Hügel von ±10, dazwischen breite, flache Flüsse, die stark mäandern, mit einer ebenen Aue am Ufer und sehr sanftem Anstieg. Die Ufer sind aus Sand, der Flussgrund aus Kies; in den Flüssen liegen Kiesbänke und kleine Inseln. Steine an der Oberfläche gibt es nur in den obersten Lagen der Hügel. Tiefe Flusstäler und treppige Ufer will der Autor dort nicht.
- Reed Meres: kleine Tümpel, und vom Ufer geht es höchstens einen Block hinab zum Wasser. Wasser, das tief unter dem Ufer sitzt, will der Autor nicht.
- Old Wood hat Waldseen über dem Meeresspiegel. Sie entstehen aus einem eigenen Wasserspiegel des Bioms, bis zu dem alle Mulden gefüllt werden; das war die Idee des Autors. Auch dort höchstens ein Block hinab zum Wasser.
- Zellgröße 1.000 statt 1.600, als Versuch: Mit 1.600 wirkten die Biome sehr groß.
- Reed Meres: sehr flach, das Land liegt nur 1 oder 2 über dem Wasser. Sumpfgras als Deckschicht, Torf (der trockene, Nummer 6 der Tafel) am Ufer und am Gewässergrund, Wasser aus Minetest Game, dazu ebene Flecken aus grünem und gelbem Sumpfmoos, deren Farbe gegenüber der Vorlage dunkler und kräftiger ist. Die Werte hat der Autor an einer Tafel gewählt; sie stehen in `docs/medien.md`.
- Biomübergänge sollen nicht künstlich wirken: keine gerade Linie, kein harter Wechsel der Oberfläche. Gebaut sind eine unregelmäßige Grenzlinie und ein gesprenkelter Wechsel der Oberfläche; ob das dem Autor reicht, ist offen.
- Der Übergang zwischen zwei Biomen war mit 120 Blöcken je Seite zu breit und ist auf 60 halbiert.
- Old Wood hat Gras nur auf den Hügelkuppen, leicht fleckig mit Sprenkeln des normalen Bodens. Es ist ein eigenes Waldgras; dessen Farbton ist ein Vorschlag von Claude und vom Autor noch nicht bestätigt.
- M1 bekommt keinen zweiten Teil mit Bewuchs. Der Bewuchs kommt mit M4.
- M2 wird in drei Pull Requests gebaut: Zonen und Austeilen, dann Meer und Inseln, dann Schwellen an den Zonengrenzen.
- Die Biome der Zonen 2 und 3 und der Inseln sind in M2 Platzhalter aus Blöcken von Minetest Game. Der Autor arbeitet die echten Biome danach einzeln aus.

- Der Prototyp beginnt mit den drei Biomen von Zone 1: Blossom Downs, Reed Meres, Old Wood. Das sind Arbeitsnamen.
- Jedes Biom hat eine eigene Holzart, eine Feldfrucht, eine Kochzutat und eine Zutat für die Alchemie.
- Kohle liegt überall in der oberen Schicht, unabhängig von Zone und Biom. Sie gilt als Brennstoff, nicht als Erz.
- Zone 1: unter Blossom Downs Kupfer, unter Reed Meres Zinn, unter Old Wood besonders viel Kohle. Eisen und Gold liegen in Zone 2, Mese und Diamant in Zone 3.
