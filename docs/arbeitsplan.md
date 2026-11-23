# Wanderlore: Arbeitsplan

Entwurf vom 22.11.2026. Der Plan zerlegt das [Konzept](konzept.md) in Meilensteine. Jeder hat ein Ergebnis, das man im Spiel sehen oder prüfen kann, und nennt, was der Autor dafür entscheiden oder beisteuern muss.

Es gibt keinen Zeitplan. Die Reihenfolge zählt, nicht das Datum.

## Arbeitsweise

- **Ein Meilenstein, ein Pull Request.** Zusammengeführt wird, wenn das „Fertig, wenn“ erfüllt ist.
- **Ein Meilenstein, ein neuer Chat.** Lange Chats werden unzuverlässig. Damit ein neuer Chat nicht bei null anfängt, stehen die Regeln des Projekts in der [`CLAUDE.md`](../CLAUDE.md).
- **Prüfen in zwei Schritten.** Claude lädt das Modpack in Luanti 5.18, prüft auf Fehler und macht Screenshots. Wie es sich anfühlt, prüft der Autor im Spiel.
- **Neue Welt nach jeder Änderung am Generator.** Auf alte Welten wird keine Rücksicht genommen.
- **Fremde Assets kommen nie ungeprüft ins Repository.** Jede Datei wird mit Autor, Lizenz und Quelle in der Lizenzdatei eingetragen.

## Meilensteine

| Nr. | Meilenstein | Ergebnis | Fertig, wenn | Beitrag des Autors |
| --- | --- | --- | --- | --- |
| M0 | Grundgerüst | Aufbau des Repositories, leeres Modpack, Skripte zum Einrichten und Starten, Lizenzdatei | das leere Modpack lädt in Luanti ohne Fehler | – |
| M1 | Generator G1: Prototyp | die drei Biome von Zone 1 mit eigener Landschaftsform | Screenshots zeigen deutlich verschiedene Landschaften, die Geschwindigkeit ist gemessen | die Landschaft im Spiel beurteilen |
| M2 | Generator G2: Weltkarte | Zonen, ausgeteilte Biome, Meer, Inseln, Vulkaninseln, Übergänge, Schwellen an Zonengrenzen | man kann vom Startland bis zu einer Insel reisen | Übergänge und Reisezeiten beurteilen |
| M3 | Lore, einfach | Lore für betretene Biome, Lorebook als Reiter im Inventar | das Lorebook füllt sich beim Wandern | prüfen, ob Entdecken als Antrieb trägt |
| M4 | Generator G3: Ausbau | Erzschichten nach Zone, Biom und Tiefe, Flüsse, Bewuchs, gesperrter Raum für die Zwischenschicht | eine Welt lässt sich flüssig erkunden, auch mit mehreren Spielern | Biome weiter ausarbeiten |
| M5 | Leben und Ausdauer | zwei Leisten, Magen mit drei Plätzen, Verbrauch von Ausdauer | ohne Nahrung ist man schwach, mit Nahrung stark | Grundwerte beurteilen |
| M6 | Farming und Küche | gewählte Feldfrüchte, Wildvorkommen, Herd mit Stufen, erste Gerichte, Essenz | die erste Stunde lässt sich bis zum Kochen durchspielen | Feldfrüchte und Gerichte auswählen |
| M7 | Alchemie | Wildkräuter je Biom, Kessel, Tränke zum Trinken | ein Trank lässt sich aus gesammelten Kräutern brauen | Tränke bestätigen |
| M8 | Baukasten | Marker, Speichern und Probesetzen von Bauwerken, Platzierung durch den Generator, Beutekisten | ein selbst gebauter Stronghold erscheint in einer neuen Welt | Strongholds bauen, ab hier laufend |
| M9 | Monster und Tiere | gewählte Wesen in Welt und Strongholds, Spawner, Schutz durch Häuser | nachts kommen Monster, im Haus ist man sicher | Wesen im Katalog auswählen |
| M10 | Kampf | Schmiede, Waffen und Rüstungen in Stufen, Bogen, Armbrust, Wurftränke, Aufwertungen | ein Stronghold der Zone 2 lässt sich mit passender Ausrüstung bezwingen | Stufen und Werte beurteilen |
| M11 | Lore, vollständig | Lore für alle Funde, Lore-Station, Ketten, Freischalten, Umentscheiden | die Lore reicht für einen Bereich ganz und einen zweiten zur Hälfte | Ketten und Kosten festlegen |
| M12 | Generator G4: Unterwelt | drei Höhlentypen, Dungeons aus Bausteinen | man findet Höhlen und steigt in einem Dungeon mehrere Ebenen ab | Dungeon-Bausteine bauen |
| M13 | Generator G5: Zwischenschicht und Ziel | Siegel, Werkzeug aus den vier Elementen, die zweite Welt, der Drache | man öffnet einen Vulkan, steigt ab und besiegt den Drachen | Wesen der Urzeit auswählen, Lizenz von Paleotest klären |
| M14 | Hülle und LEP | Spiel-Hülle für Einzelspieler, Anbindung an LEP | Wanderlore startet als Spiel und läuft in einer LEP-Welt | die zwei Anpassungen in LEP |

## Stand

- **M0** ist zusammengeführt.
- **M1** ist zusammengeführt: Landschaftsform und Oberfläche der drei Biome, die Übergänge zwischen ihnen, die Messung und die Screenshots. Einen zweiten Teil mit vorläufigem Bewuchs gibt es nicht; das hat der Autor am 22.11.2026 entschieden. Der Bewuchs kommt mit M4.
- **M2** ist in drei Pull Requests gebaut, jeder für sich lauffähig. Reisen vom Startland bis zu einer Insel geht bisher nur fliegend oder mit den Befehlen der Testwelt; Boote gibt es noch nicht. Die drei Teile:
  1. Zonen und Austeilen der Biome, mit Platzhaltern für die neun Biome der Zonen 2 und 3 und einem vorläufigen Meer.
  2. Meer und Inseln: Küsten, Inselgruppen, Vulkaninseln als Form.
  3. Schwellen an den Zonengrenzen, Reisen über weite Strecken in der Testwelt, Messung und Screenshots.
- **M3** ist gebaut: der Mod `wl_lore` mit Lore für betretene Biome und dem Lorebook als Reiter im Inventar. Geprüft am 23.11.2026 in Claudes Arbeitsumgebung: Ein Tester, der nacheinander in fünf Biome gesetzt wurde, bekam fünf Lore, und das Lorebook zeigte sie an. Ob Entdecken als Antrieb trägt, kann nur der Autor im Spiel beurteilen. Nicht geprüft ist der Lauf in einer Welt von LEP; dort wurde nur im Code nachgelesen, dass LEP dasselbe Inventar nutzt.
- Danach kommt **M4**, der Ausbau des Generators.

### Messung zu M1

Gemessen am 22.11.2026 mit `scripts/measure.sh` in Claudes Arbeitsumgebung in der Cloud, vier Prozessorkerne, Luanti 5.18.0. Je Biom wurden 108 Portionen von 80×80×80 Blöcken erzeugt.

| | Zeit je Portion |
| --- | --- |
| Wanderlore, alles zusammen, wie der Server es erlebt | 15 bis 19 ms |
| Luantis Generator v7 mit Minetest Game, dieselbe Menge | 53 bis 60 ms |
| Wanderlore, nur der eigene Code, Portion mit Oberfläche | 33 bis 39 ms im Mittel, höchstens 59 ms |
| Wanderlore, nur der eigene Code, Portion aus reinem Stein | 28 bis 32 ms im Mittel, höchstens 49 ms |
| Wanderlore, nur der eigene Code, Portion aus reiner Luft | 3 ms im Mittel |

Die Zahlen gelten für den Stand am Ende des ersten Teils von M1, mit mäandernden Flüssen, Kiesbänken, Waldseen, Flecken, Findlingen und gesprenkelten Biomgrenzen. Zwischen zwei Läufen schwanken die Werte um mehrere Millisekunden, auch die von v7 und die der Portionen aus reinem Stein, an denen sich nichts geändert hat. Ein früherer Lauf am selben Tag ergab 13 bis 16 ms für Wanderlore und 52 bis 55 ms für v7. Ob die Ergänzungen seit dem ersten Stand etwas kosten, lässt sich daraus nicht ablesen; viel ist es nicht.

- Die erste Zeile ist kleiner als die dritte, weil Luanti mehrere Portionen gleichzeitig erzeugt.
- Von den rund 30 ms einer Portion mit Oberfläche entfallen etwa 18 ms auf das Übergeben der Blöcke zwischen Luanti und Lua, 8 ms auf das Licht und 4 ms auf die Rechnung der Landschaft. Diese Aufteilung stammt aus einem einzelnen Lauf während der Entwicklung.
- Der Vergleich mit v7 ist nicht gerecht: v7 erzeugt dabei auch Höhlen, Erze und Bewuchs. Er zeigt nur die Größenordnung.
- Wie es sich mit vielen Spielern verhält, ist nicht gemessen.

### Messung zu M2, erster Teil

Gemessen am 22.11.2026 wie oben, nach dem Einbau von Zonen, Austeilen und Platzhaltern. Je Biom 108 Portionen, alles zusammen, wie der Server es erlebt:

| | Zeit je Portion |
| --- | --- |
| die drei Biome von Zone 1 | 15 bis 18 ms |
| dieselben auf dem Stand von M1, am selben Tag auf derselben Maschine | 16 bis 18 ms |
| Platzhalter von Zone 2 | 14 bis 21 ms |
| Platzhalter von Zone 3 | 20 bis 24 ms |

| Platzhalter der Inseln und Vulkaninsel, nach dem zweiten Teil | 19 bis 22 ms |

- Nach dem zweiten Teil, mit Küsten und Inseln, lagen Zone 1 bei 15 bis 18 ms, Zone 2 bei 15 bis 19 ms und Zone 3 bei 19 bis 22 ms, also unverändert.
- Nach dem dritten Teil, am 23.11.2026: Zone 1 bei 19 bis 22 ms, Zone 2 bei 17 bis 26 ms, Zone 3 bei 21 bis 29 ms, Inseln bei 23 bis 27 ms. Die Maschine war an diesem Tag langsamer und unruhiger: Der Stand vor dem dritten Teil kam im selben Zeitraum auf 16 bis 21 ms in Zone 1 und 22 bis 30 ms in Zone 3. In der reinen Rechenzeit des Generators je Portion war zwischen beiden Ständen kein Unterschied zu erkennen, der größer wäre als die Schwankung zwischen zwei Läufen. Ob die tiefere Füllung an Steilwänden aus dem zweiten Teil etwas kostet, ist nicht einzeln gemessen.
- Zone 3 kostet mehr, weil das Land dort bis über 100 Blöcke hoch reicht. Dann enthält auch die obere der drei gemessenen Lagen Land statt nur Luft.
- Der eigene Code braucht für eine Portion aus reiner Luft in Zone 1 jetzt 5 bis 6 ms im Mittel; der Stand von M1 kam im selben Lauf auf 4 bis 5 ms. Der Unterschied liegt in der Größe der Schwankung zwischen zwei Läufen.
- Der Generator sieht je Portion nur die Biome der umliegenden Zellen an, nicht alle 13. In einem Lauf ohne das kostete eine Portion aus Luft 6 bis 7 ms; auch dieser Unterschied ist kaum größer als die Schwankung.

## Wegmarken

| Wegmarke | Nach | Was dann möglich ist |
| --- | --- | --- |
| Erste Welt | M2 | die Welt bereisen und beurteilen, ohne Inhalt |
| Erste Stunde | M6 | ankommen, sammeln, anbauen, kochen, Lore finden |
| Erstes Abenteuer | M10 | reisen, kämpfen, einen Stronghold bezwingen |
| Ganzes Spiel | M13 | das Ziel erreichen |

Nach der Wegmarke „Erste Stunde“ fehlen noch die Monster der ersten Nacht. Wenn das stört, lässt sich ein kleiner Teil von M9 vorziehen.

## Festgelegt für den Anfang

- **Der Prototyp beginnt mit den drei Biomen von Zone 1:** Blossom Downs, Reed Meres und Old Wood. Das sind Arbeitsnamen.
- **Der eigene Code steht unter LGPL 3.0.** Die übernommenen Medien behalten ihre Lizenzen.

## Was den Plan umwerfen kann

- **Der Generator ist zu langsam.** Das zeigt M1. Dann wird zuerst dort nachgebessert, bevor etwas darauf aufbaut.
- **Entdecken trägt nicht als Antrieb.** Das zeigt M3. Dann ist das Konzept an seiner wichtigsten Stelle zu überdenken.
- **Der Umfang.** Grob 7.000 bis 10.000 Zeilen Lua, dazu die Bauzeit für Strongholds und Dungeons. Jede Wegmarke ist ein Punkt, an dem man aufhören oder kürzen kann und trotzdem etwas Spielbares hat.
