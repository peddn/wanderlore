# Wanderlore: Konzept

Stand: 22.11.2026 · Version 6 · Luanti 5.18, Minetest Game · Status: Konzept, noch nichts gebaut

Wanderlore ist ein Modpack für Luanti, in dem man durch Entdecken wächst statt durch Graben. Man zieht durch eine in Zonen gegliederte Welt, sammelt dabei Lore und schaltet damit neue Möglichkeiten frei. Was man selbst herstellt, kommt aus dem eigenen Garten und ist pflanzlich; das Seltene gibt nur die Wildnis her.

## 1. Festgelegt

| Thema | Entscheidung |
| --- | --- |
| Name | Wanderlore. Repo `peddn/wanderlore`, Mod-Kürzel `wl_` |
| Form | Modpack auf unverändertem Minetest Game. Dazu später eine dünne Spiel-Hülle für Einzelspieler |
| Entwicklung | Unabhängig. Inhalte entscheidest du |
| LEP | Wanderlore muss in Welten der Luanti Education Platform laufen können, hängt aber nicht von ihr ab |
| Alleinstellungsmerkmal | Fortschritt durch Entdecken statt durch Abbauen |
| Fremde Mods | Nur Assets übernehmen, nach deiner Auswahl. Ausnahme: Mobs Redo als Schnittstelle |
| Vegan-Regel | Was Spieler anbauen, kochen oder brauen, ist pflanzlich. Tierisches nur als Beute |
| Inhalts-Schalter | Keine. Was im Spiel ist, gehört dazu. Einstellbar sind nur Werte wie Dichte, Tempo, Schaden |
| Monster | Gehören fest dazu, in Welt und Strongholds, jeweils andere. Später eigene |
| Strongholds | Baust du im Spiel und speicherst sie als Asset |
| Fortschritt | Was man sammelt, heißt Lore. Dazu Stationsstufen und Essenz aus der Ernte |
| Welt | Eigener Kartengenerator, der Zone, Biom und Landschaftsform gemeinsam festlegt. Vier Zonen zum Start |
| Biome | Eigene, aus vorhandenem Material neu zusammengesetzt, jedes mit eigener Landschaftsform |
| Reihenfolge | Generator zuerst |

## 2. Form und Kompatibilität

### Modpack plus Hülle

| Teil | Inhalt | Für wen |
| --- | --- | --- |
| Modpack `wanderlore` | alle eigenen Mods samt Generator | LEP und jeder mit Minetest Game |
| Spiel-Hülle | Beschreibung, Voreinstellungen, Skript, das Minetest Game und Mobs Redo in fester Version holt | Einzelspieler |

Der Generator läuft als Mod. Voraussetzung ist, dass die Welt mit dem Generator `singlenode` angelegt wird. Die Hülle setzt das von selbst, LEP über eine Einstellung in seiner Mod-Liste. Bestehende Welten lassen sich nicht umstellen.

### Was LEP vorgibt

- **Der Himmel bleibt leer.** LEP legt Lobby und Lernräume ab Höhe 10.000 an. Der Generator erzeugt oberhalb der Landschaft nichts.
- **Am Startpunkt liegt Land der Zone 1.** Dort steht bei LEP das Portal zur Wildnis.
- **Wanderlore bestimmt nicht, wo Spieler erscheinen.** Es liefert nur eine Funktion für einen sicheren Ort.
- **Wirkungen nur in der Wildnis.** Über eine optionale Anbindung an die Ortsverwaltung von LEP ruhen Boni, Tränke und Stationen in Lobby und Lernräumen.
- **Grundstücksschutz achten**, über Luantis Standardfunktion.
- **Lore liegt in den Spielerdaten**, damit sie beim Löschen eines Kontos mit verschwindet.
- **Viele Spieler gleichzeitig.** Eine Klasse, die sich zusammen anmeldet, macht die Geschwindigkeit des Generators zum harten Kriterium.

Eine Wanderlore-Welt ist immer eine Welt mit Monstern. In LEP sind zwei kleine Anpassungen nötig: Die Mod-Liste muss ein Modpack mit mehreren Mods laden können, und die Überschneidung mit dem Mod Awards ist zu klären.

## 3. Mods

| Mod | Aufgabe | braucht |
| --- | --- | --- |
| `wl_world` | Generator, Zonen, Biome, Verteilung von allem in der Welt, Abfrage „welches Biom, welche Zone“ | Minetest Game |
| `wl_lore` | Lore sammeln, Lorebook, Lore Table, Freischaltungen | `wl_world` |
| `wl_farming` | Feldfrüchte, Speisen, Kochstation, Mahlzeit-Boni, Essenz | `wl_world`, `farming` |
| `wl_alchemy` | Wildkräuter, Kessel, Tränke | `wl_world`, `vessels` |
| `wl_monsters` | Monster für Welt und Strongholds | `wl_world`, Mobs Redo |
| `wl_strongholds` | Baukasten, Platzierung, Beute, Spawner | `wl_world` |

Regel für alle: Nur `wl_world` weiß, wo etwas liegt. Die anderen Mods melden ihre Kräuter, Monster und Bauwerke dort mit Biom und Zone an und fragen sonst nur „welches Biom, welche Zone?“.

## 4. Der Generator

### Wie Luanti es von Haus aus macht

Die Welt entsteht in Portionen von 80×80×80 Würfeln, erst wenn ein Spieler in die Nähe kommt, und allein aus Startwert und Position. Ein eingebauter Generator erzeugt zuerst die Landschaftsform aus Rauschfunktionen und wählt danach das Biom aus Temperatur und Feuchtigkeit. Das Biom bestimmt nur noch Oberfläche und Bewuchs. Deshalb haben dort alle Biome dieselbe Form.

### Wie Wanderlore es macht

Die Reihenfolge wird umgedreht:

1. **Zelle.** Die Position wird mit Rauschen leicht verschoben und dann der nächstgelegenen Zelle zugeordnet. Zellen sind unregelmäßige Flächen von etwa 1.600 Blöcken Breite.
2. **Zone und Biom der Zelle.** Die Zone ergibt sich aus der Entfernung der Zelle vom Start, das Biom aus dem Austeilen (siehe „Die Weltkarte“).
3. **Landschaftsform** aus der Höhenformel des Bioms: Terrassen, Schluchten, Felsnadeln, Senken, Atolle.
4. **Oberfläche, Bewuchs, Landmarken** nach dem Biom.
5. **Höhlen, Erze, Strongholds.**

Weil Zone und Biom nur berechnet werden, kennt `wl_world` sie auch für Gegenden, die noch nicht erzeugt sind. Ein Kompass zum nächsten Stronghold ist damit einfach.

### Die Weltkarte

Stand der Diskussion vom 22.11.2026. Die Skizze dazu liegt unter `docs/weltkarte/skizze.png`, das Verfahren als Python-Skript daneben. Es ist eine Diskussionshilfe, kein Spielcode.

| | Zone 1 | Zone 2 | Zone 3 | Inseln |
| --- | --- | --- | --- | --- |
| Äußerer Rand ab Start | 4.000 Blöcke | 7.500 | 11.500 | 14.000 bis 17.500 |
| Fußweg bis zum Rand | ca. 16 Minuten | ca. 31 | ca. 48 | – |
| Zellgröße | 1.600 | 1.600 | 1.600 | 800 |
| Zellen in der Skizze | 23 | 49 | 92 | 82 |
| Biome | 3 | 6 | 5 | 3 |
| Austeilen der Biome | reihum | nach Richtung | nach Richtung | nach Richtung |
| Ein Biom-Land ist etwa | 1.600 breit | 4.500 breit | 7.000 breit | Inselgruppen |

Die Regeln:

- **Eine Zelle gehört immer ganz zu einer Zone.** Die Zone wird für den Mittelpunkt der Zelle bestimmt. So zerschneidet keine Zonengrenze ein Biom.
- **An Land gibt es nur eine Zellgröße.** Zwei Größen an einer Zonengrenze schneiden Zellen ab. Nur die Inseln haben kleinere Zellen, weil sie das Festland nie berühren.
- **Biome werden fest ausgeteilt.** Beim Anlegen der Welt werden alle Zellen jeder Zone aufgezählt und die Biome wie Karten verteilt. Jedes Biom bekommt gleich viele Zellen, keines fehlt.
- **Zone 1 wird reihum ausgeteilt**, damit alle Grundzutaten nah am Start liegen.
- **Zone 2, 3 und die Inseln werden nach Richtung ausgeteilt.** Jedes Biom hat eine Heimatrichtung, mit einzelnen Ausreißern. Wer alle Zutaten will, muss in verschiedene Richtungen reisen.
- **Die Größe eines Bioms hängt am Austeilen, nicht an der Zellgröße.** Regler sind der Zusammenhang gleicher Biome, die Zahl der Biome je Zone und die Größe der Zone.
- **Die Zelle ist die Spielart des Bioms.** Jede Zelle bekommt eine Variante, etwa dicht, licht, mit See oder mit Landmarke.
- **Die Welt speichert ihre Verteilung** beim Anlegen und rechnet sie nie neu. Neue Biome erscheinen nur in neuen Welten oder neuen Zonen.
- **Weites Reisen soll kosten.** Es gibt keine Wegsteine. Portale kommen vielleicht später. Betten setzen den Wiedereinstiegspunkt.
- **Hinter dem Meer ist Platz.** Die Welt reicht bis etwa 31.000 Blöcke; dort können später weitere Kontinente mit neuen Zonen liegen.

### Landschaftsformen

Jedes Biom hat eine Höhenformel, die für eine Position die Geländehöhe liefert. Alle Formen entstehen aus weichem Rauschen, nur anders weiterverarbeitet. Skizze und Skript liegen unter `docs/landschaft/`.

| Form | Verfahren | Werte in der Skizze |
| --- | --- | --- |
| Hügel mit Bachtälern | Rauschen als Höhe, ein zweites Rauschen gräbt schmale Täler | Höhen bis etwa 45 Blöcke |
| Terrassen | Höhe in Stufen gerundet, kurze Rampe an der Kante | Stufen von 11 Blöcken |
| Schluchten | Hochebene, gefaltetes Rauschen schneidet tief ein | etwa 75 Blöcke tief |
| Felsnadeln | flacher Boden, feines Rauschen oberhalb einer Schwelle stark überhöht | Spitzen bis etwa 115 Blöcke |

Festgelegt:

- **Kräftige Formen.** Die Landschaft darf deutlich dramatischer sein als in Minetest Game.
- **Höchstens etwa 120 Blöcke über dem Meer.**
- **Begehbarkeit nach Zone.** Zone 1 ist überall zu Fuß begehbar. Nach außen wird das Gelände sperriger, in Zone 3 bewusst so, dass man bauen, klettern oder einen Trank nutzen muss.
- **Dreidimensionales Rauschen** nur dort, wo eine Form es braucht. Echte Nadeln, Bögen und Überhänge gehen mit einer Höhenformel nicht.

### Übergänge

Skizze und Skript: `docs/landschaft/skizze_uebergaenge.png`.

Jede Höhenformel besteht aus zwei Teilen: einer **Grundhöhe** des Bioms und der **Form** (Stufen, Einschnitte, Nadeln).

- **Zwischen Biomen derselben Zone** werden die Grundhöhen weich gemischt, und die Form blendet zur Grenze hin aus. Eine Schlucht läuft zum Rand flach aus, statt abzubrechen. Im Inneren bleibt jede Form unverfälscht.
- **An Zonengrenzen liegt eine sichtbare Schwelle:** zwischen Zone 1 und 2 ein Fluss, zwischen Zone 2 und 3 ein Höhenzug.
- **Zwischen Varianten desselben Bioms** gibt es keinen eigenen Übergang. Die Regler der Formel gleiten ineinander.
- **Die Mischzone ist schmal**, zum Start 120 Blöcke je Seite. Breiter wäre sanfter, kostet aber Fläche und Rechenzeit.
- **Oberfläche und Bewuchs** wechseln gesprenkelt über etwa 40 Blöcke, nicht an einer Linie.
- **Küste:** je Biom Strand oder Steilküste.

### Technische Knackpunkte

- **Übergänge** sind der kniffligste Teil. Das Verfahren steht oben; ob es im Spiel überzeugt, zeigt erst G2.
- **Überhänge und Bögen** brauchen dreidimensionales Rauschen, das deutlich teurer ist. Start mit Höhenformeln, 3D nur wo ein Biom es braucht.
- **Große Bauwerke** reichen über mehrere Portionen. Ihr Ort muss vorab berechenbar sein, damit jede Portion ihren Teil zeichnet.
- **Geschwindigkeit** ist erst nach einer Messung am Prototyp bekannt.
- **Selbst zu liefern:** Höhlen, Flüsse, Dungeons, Biom-Auswahl und Bewuchs. Erzverteilung und das Setzen von Bauvorlagen stellt Luanti weiter bereit.

### Stufen

| Stufe | Inhalt | Fertig, wenn |
| --- | --- | --- |
| G1 Prototyp | Landschaftsformen und zwei bis drei Biome, ohne Höhlen und Erze | Screenshots zeigen deutlich verschiedene Landschaften, Geschwindigkeit ist gemessen |
| G2 Weltkarte | Zonen, Lage der Biome, Meer und Inseln, Übergänge | man kann vom Startland bis zu einer Insel reisen |
| G3 Ausbau | Höhlen, Erze, Flüsse, Feinschliff der Geschwindigkeit | eine Welt lässt sich flüssig erkunden |

## 5. Zonen und Biome

### Vier Zonen zum Start

| Zone | Charakter | Monster | Strongholds |
| --- | --- | --- | --- |
| 1 Startland | freundlich, Grundzutaten, drei Biome | wenige, schwach, nur nachts | kleine Ruinen |
| 2 Wildnis | abwechslungsreich, die meisten Kräuter | mehr, mittel | Türme, Schreine |
| 3 Ödland | karg, gefährlich, seltene Zutaten | stark, auch tags | Festungen mit Endgegner |
| Inseln | Sonderzone, nur über Wasser erreichbar | eigene | einzelne besondere |

### Eigene Biome

Jedes Biom ist ein Steckbrief: Landschaftsform, Farbpalette, Pflanzenmischung, Landmarke, Atmosphäre, eine eigene Regel und sein Spielinhalt (Kraut, Feldfrucht, Monster, Stronghold-Typ).

Sechs Skizzen als Richtung. Die Nummern beziehen sich auf den Biom-Katalog (vier Bildtafeln mit 51 Biomen aus Minetest Game, Extra Biomes, Ethereal und Everness).

| Arbeitsname | Zone | Landschaft | Material | Besonderheit |
| --- | --- | --- | --- | --- |
| Blossom Downs | 1 | sanfte Hügel mit Bachtälern | E1, E10, Blumenwiesen | Riesenbäume als Wegmarken |
| Bamboo Terraces | 2 | gestufte Terrassen mit Wasserbecken | E6, V1, V8 | Reis wächst wild |
| Mushroom Hollows | 2 | tiefe Senken | E12 | Pilze leuchten nachts, Sporennebel |
| Ember Scar | 3 | Schluchten in rotem Fels, Lavaflüsse | E2, E3, E13 | Hitze |
| Frost Spires | 3 | Eisnadeln, dazwischen Frostwald | V7, E4 | Schneesturm senkt die Sicht |
| Crystal Atoll | Inseln | Ringinseln mit Lagune | V3, V2 | nachwachsende Kristalle |

Die Steckbriefe entstehen am Prototyp, nicht auf dem Papier. Ob Material aus verschiedenen Mods nebeneinander stimmig aussieht, zeigt sich erst im Spiel.

## 6. Fortschritt

### Lore

Lore gibt es für alles, was man zum ersten Mal tut. Jeder Spieler hat sein eigenes Konto.

| Erster Fund | Lore |
| --- | --- |
| Biom betreten | 1 |
| Wildkraut oder wilde Feldfrucht gefunden | 1 |
| Gericht gekocht, Trank gebraut | 1 |
| Monsterart besiegt | 2 |
| Stronghold-Typ betreten | 3 |
| Endgegner besiegt | 5 |

Das **Lorebook** zeigt, was gefunden ist und wie viel noch fehlt, ohne das Fehlende zu verraten.

Am **Lore Table** gibt man Lore aus. Vier Äste:

| Ast | Beispiele |
| --- | --- |
| Küche | einzelne Bonus-Gerichte, zweiter Mahlzeit-Bonus gleichzeitig, kürzere Kochzeit |
| Alchemie | einzelne Tränke, längere Wirkdauer, zwei Tränke pro Brauvorgang |
| Feld | schnelleres Wachstum, mehr Ertrag, Saatgut fremder Zonen |
| Entdecker | Kompass zum nächsten Stronghold, größerer Rucksack, Rückkehr-Trank |

### Stationsstufen

Herd und Kessel haben drei Stufen und werden mit Material aufgewertet. Das Material für Stufe 2 stammt aus Zone 2, für Stufe 3 aus Zone 3 und aus Strongholds. Die Stufe bestimmt, was technisch möglich ist; Lore bestimmt, welche Rezepte man davon kennt.

### Essenz

Reife Feldfrüchte geben beim Ernten manchmal Lebensessenz, wilde Pflanzen öfter. Damit kauft man Saatgut noch nicht gefundener Sorten und bezahlt Aufwertungen im Ast „Feld“. Essenz ist erneuerbar, Lore nicht.

## 7. Farming und Küche

- **Feldfrüchte:** Auswahl aus den 42 von Farming Redo, nur die Texturen. Angebaut wird mit dem Farming aus Minetest Game. Vorschlag: Karotte, Chili, Mais, Gurke, Knoblauch, Salat, Zwiebel, Erbsen, Kartoffel, Reis, Soja, Tomate.
- **Wildvorkommen** als Saatgutquelle, je Biom verschieden.
- **Kochstation:** Herd mit vier Zutatenfächern, Brennstoff und Rezepte-Reiter.
- **Bonus-Gerichte** entstehen nur am Herd. Vorschlag: Tomatensuppe, Erbsensuppe, Zwiebelsuppe, Salat, gebratener Tofu, Chili, Spaghetti, Paella, Bibimbap, Burger.
- **Alle Rezepte sind pflanzlich.** Tofu ersetzt Fleisch.

## 8. Alchemie

- **Wildkräuter:** eines je Biom, nicht anbaubar.
- **Glasfläschchen:** die Glasflasche aus Minetest Game, an Wasser gefüllt.
- **Kessel:** Wasserflasche plus bis zu drei Zutaten, kein Brennstoff.
- **Sieben Tränke** in zwei Wirkstufen: Heilung, Schnelligkeit, Sprungkraft, Federfall, Wasseratmung, Feuerschutz, Katzenauge.
- **Wirkstufe II** braucht Kessel Stufe 3 und eine seltene Zutat: Mondstaub oder Eiskristall aus Truhen, Knochen, Zahn oder Horn als Monster-Beute.

## 9. Monster

Grundstock sind die Monster aus Mobs Monster, über Mobs Redo gesteuert.

| Monster | Leben | Schaden | Wo | Zone |
| --- | --- | --- | --- | --- |
| Sandmonster | 20 | 1 | Welt | 1–2 |
| Erdmonster | 27 | 2 | Welt | 1–2 |
| Baummonster | 40 | 2 | Welt | 2 |
| Spinne | 30 | 3 | Welt | 2–3 |
| Steinmonster | 35 | 3 | Welt | 3 |
| Oerkki | 34 | 4 | Stronghold | 2 |
| Mese-Monster | 25 | 2 | Stronghold | 2 |
| Lava-Flan | 35 | 3 | Stronghold | 3 |
| Feuergeist | 45 | 4 | Stronghold | 3 |
| Landwächter | 65 | 12 | Stronghold, Endgegner | 3 |
| Dungeon Master | 75 | 6 | Stronghold, Endgegner | 3 |

Jedes Monster ist ein Eintrag in einer Tabelle. Eigene Monster entstehen zuerst als neue Textur auf einem vorhandenen Modell; neue Modelle brauchen Blender oder Blockbench.

## 10. Strongholds

1. In einer Kreativwelt bauen.
2. Beute-Marker und Spawner-Marker setzen.
3. Zwei Ecken markieren und mit einem Befehl speichern.
4. Die Datei einmal von Hand aus dem Weltordner in den Mod kopieren.
5. In einer Liste eintragen: Name, Zone, Biome, Seltenheit.
6. Mit einem Befehl zur Probe setzen.

Die Zone bestimmt Stärke von Beute und Monstern. Platziert wird vom Generator.

## 11. Powerups

| | Mahlzeit | Trank |
| --- | --- | --- |
| Charakter | passiv, defensiv | aktiv, situativ |
| Dauer | 5–10 Minuten | 1–3 Minuten, Heilung sofort |
| Gleichzeitig | ein Bonus, per Lore zwei | verschiedene Tränke stapelbar |
| Quelle | Feldarbeit, erneuerbar | Kräuter aus Biomen, Wirkstufe II nur mit Beute |

Mahlzeit-Boni: Regeneration, Zusatzherzen, Langer Atem, Zähigkeit, Leichtfuß, Sanfte Landung.

## 12. Reihenfolge

| Schritt | Inhalt |
| --- | --- |
| 1 | `wl_world` G1: Prototyp |
| 2 | `wl_world` G2: Weltkarte |
| 3 | `wl_lore` in einfacher Form: Lore für Biome, Lorebook |
| 4 | `wl_world` G3: Ausbau |
| 5 | `wl_farming` |
| 6 | `wl_alchemy` |
| 7 | `wl_strongholds`, zuerst der Baukasten |
| 8 | `wl_monsters` |
| 9 | `wl_lore` vollständig: Lore Table, Äste |
| 10 | Spiel-Hülle, Anbindung an LEP |

Schritt 3 kommt früh, weil sich erst dort zeigt, ob Entdecken als Fortschritt trägt.

Grober Umfang: 4.000 bis 5.000 Zeilen Lua. Der unsicherste Posten ist der Generator.

## 13. Risiken

- **Der Generator ist zu langsam** für eine Klasse gleichzeitiger Spieler. Wird in G1 gemessen.
- **Übergänge zwischen Biomen** sehen unnatürlich aus. Wird in G2 sichtbar.
- **Feinschliff ohne Ende.** Jede Generator-Stufe hat ein festes Ende.
- **Material aus drei Mods passt optisch nicht zusammen.**
- **Lizenzen der Medien sind gemischt.** Jede Datei behält Autor und Lizenz in der Lizenzdatei.
- **Mobs Redo als Abhängigkeit** widerspricht wörtlich „nur Assets“, ist aber als Schnittstelle bewusst ausgenommen.
- **Ich sehe die Welt nur in Screenshots.** Wie sie sich beim Herumlaufen anfühlt, musst du prüfen.

## 14. Offen

1. Biome: welche Skizzen, welche weiteren.
2. Feldfrüchte und Speisen auswählen.
3. Aufteilung der Monster prüfen.

## Quellen

- [Luanti Education Platform](https://github.com/peddn/luanti-education-platform) – docs/konzept.md, third_party, scripts, agent
- [Luanti-Doku: Custom Lua Mapgen](https://docs.luanti.org/mapgen/custom-lua-mapgen)
- [Biome Generator](https://content.luanti.org/packages/Gael%20de%20Sailly/biomegen)
- [Farming Redo](https://codeberg.org/tenplus1/farming) · [Mobs Redo](https://codeberg.org/tenplus1/mobs_redo) · [Mobs Monster](https://codeberg.org/tenplus1/mobs_monster) · [Ethereal](https://codeberg.org/tenplus1/ethereal)
- [Extra Biomes](https://github.com/CowboyLva/ebiomes) · [Everness, Abspaltung](https://github.com/programmerjake/everness)
- [Minetest Game](https://github.com/luanti-org/minetest_game) · [Witchcraft](https://github.com/D00Med/witchcraft) · [Plantlife](https://github.com/mt-mods/plantlife_modpack)
- Hytale-Mechaniken: [Memories](https://www.4netplayers.com/en/blog/hytale/hytale-memories-find-locations-tips-rewards/) · [Werkbank-Stufen](https://nerdschalk.com/hytale-complete-workbench-upgrade-guide-materials-and-tips/)
