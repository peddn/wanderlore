# Wanderlore: Recherche

Stand: 22.11.2026. Diese Datei sammelt, was bei der Planung nachgesehen wurde: Quellen für Assets mit ihren Lizenzen, Techniken aus anderen Mods und die Vorbilder für einzelne Mechaniken. Die Entscheidungen stehen in [konzept.md](konzept.md).

Lizenzen sind so wiedergegeben, wie die Quelle sie am genannten Tag angab. Vor einer Übernahme ist jede Datei einzeln zu prüfen.

## Feldfrüchte, Speisen, Kräuter, Tränke

| Quelle | Brauchbar für | Lizenz | Stand |
| --- | --- | --- | --- |
| [Farming Redo](https://codeberg.org/tenplus1/farming) | 42 Feldfrüchte mit Wachstumsstufen, rund 100 Speisen und Zutaten, darunter Tofu, Sojamilch, veganer Käse | Code MIT, Medien gemischt: CC0, CC BY, CC BY-SA | November 2026 |
| [Cucina Vegana](https://github.com/acmgit/cucina_vegana) | vegane Speisen, nur noch als Vergleich | LGPL 3.0 | Mai 2026 |
| [Witchcraft](https://github.com/D00Med/witchcraft) | Trankflaschen in vielen Farben, Kessel, Wurftrank-Texturen, Knochen, Zahn, Horn | Medien CC BY-SA 3.0 | 2021 |
| [Plantlife Modpack](https://github.com/mt-mods/plantlife_modpack) | Farn, Schachtelhalm, Giftefeu, Binse, Seerose, Pilze | Medien CC BY-SA 4.0 | nicht notiert |

Farming Redo hat keine Kochstation und ersetzt das Farming von Minetest Game. Deshalb werden nur seine Texturen übernommen.

## Biome

Aufgenommen wurden 51 Biome in Luanti 5.18, jedes einzeln. Die Bildtafeln wurden während der Planung verschickt und liegen nicht im Repository.

| Quelle | Biome im Katalog | Lizenz | Anmerkung |
| --- | --- | --- | --- |
| [Minetest Game](https://github.com/luanti-org/minetest_game) | M1 bis M12 | Medien CC BY-SA 3.0 und andere | schon vorhanden |
| [Extra Biomes](https://github.com/CowboyLva/ebiomes) | X1 bis X16 | Code GPL 3.0, Medien überwiegend CC BY-SA 3.0 | im Stil von Minetest Game |
| [Ethereal](https://codeberg.org/tenplus1/ethereal) | E1 bis E15 | Code MIT, Medien gemischt | die internen Namen passen nicht immer zum Bild |
| [Everness](https://content.luanti.org/packages/SaKeL/everness) | V1 bis V8 | Code LGPL 2.1, Medien je Datei zu prüfen | aufgenommen aus einer [Abspaltung](https://github.com/programmerjake/everness), weil das Original nicht erreichbar war |

Nicht aufgenommen sind Biome, die nur in bestimmten Höhen vorkommen: Sümpfe, Mangroven, Hochland, Berge, Mesa.

Der Eindruck aus dem Katalog war, dass viele Biome langweilig wirken. Grund: In Luantis Generatoren hat das Biom keinen Einfluss auf die Landschaftsform. Daraus entstand die Entscheidung für eigene Biome mit eigener Form.

## Monster und Tiere

Alle Quellen sind im [Wanderlore-Katalog](https://github.com/peddn/wanderlore-catalog) mit fester Version eingetragen und dort im Spiel zu sehen.

| Quelle | Inhalt | Lizenz der Medien | Stand | Schnittstelle |
| --- | --- | --- | --- | --- |
| [Mobs Monster](https://codeberg.org/tenplus1/mobs_monster) | 11 Monster | überwiegend CC0 | Oktober 2026 | Mobs Redo |
| [Mobs Animal](https://codeberg.org/tenplus1/mobs_animal) | 24 Einträge, darunter Farbvarianten | gemischt | nicht notiert | Mobs Redo |
| [Not So Simple Mobs](https://github.com/NPXcoot/nssm) | 68 Einträge: Spinnen, Ameisen, Sandwurm, Krake, Lavatitan, Mese-Drache, Phönix, Werwolf und mehr | CC BY-SA 4.0 | 2017 | Mobs Redo |
| [dmobs](https://github.com/D00Med/dmobs) | 35 Einträge: Ork, Oger, Golem, Skelett, Baummensch, Ratte, Wespen, Drachen | CC BY-SA 3.0 | 2019 | Mobs Redo |
| [Goblins](https://github.com/FreeLikeGNU/goblins) | 12 Einträge | CC BY-SA 3.0 | 2022 | Mobs Redo |
| [Draconis](https://github.com/ElCeejo/draconis) | 13 Einträge: Feuerdrache, Eisdrache, Wyvern | MIT | Februar 2026 | Creatura |
| [Animalia](https://github.com/ElCeejo/animalia) | 18 Tiere | MIT | nicht notiert | Creatura |
| [Paleotest](https://github.com/ElCeejo/paleotest) | 19 Urzeittiere | nur GPL 3 für das Ganze, keine eigene Medienlizenz | 2020 | Mobkit |

- Modelle aus Mods mit anderer Schnittstelle lassen sich übernehmen. Ihre Animationen müssen dann neu zugeordnet werden.
- Bei Paleotest ist die Lizenz vor einer Übernahme zu klären.
- Im Stil wirken Mobs Monster, Animalia, Draconis und Paleotest sauber und einheitlich. Not So Simple Mobs ist deutlich gröber und bunter.
- Draconis lud unter Luanti 5.18 erst mit einer kleinen Hilfsdatei des Katalogs.
- Die Modelle liegen fast alle in den Formaten b3d und x vor. Das Werkzeug Assimp wandelt beide nach glTF um und erhält dabei Skelett und Animation. Ob die Animationen danach richtig aussehen, ist nicht geprüft.

## Rüstung

[3D Armor](https://github.com/minetest-mods/3d_armor), geprüft am 22.11.2026:

- Code LGPL 2.1, Medien CC BY-SA 3.0, letzter Commit Juli 2026.
- Bringt Rüstungen aus Holz, Kaktus, Bronze, Stahl, Gold und Diamant mit, dazu Schilde. Mese fehlt.
- Eigene Rüstungen lassen sich anmelden.
- Die Werte hängen am Gegenstandstyp, nicht am einzelnen Stück. Aufwertungen brauchen deshalb je Stufe einen eigenen Gegenstand.
- Es arbeitet mit `player_monoids` zusammen. Was Tempo oder Sprungkraft ändert, muss denselben Weg nutzen.

## Fernkampf

| Quelle | Inhalt | Lizenz | Stand |
| --- | --- | --- | --- |
| [Bows](https://codeberg.org/tenplus1/bows) | Bögen aus Holz, Bronze, Stahl, Pfeile | Code LGPL 2.1, Texturen CC0 | November 2026 |
| [X Bows](https://content.luanti.org/packages/SaKeL/x_bows) | ein ausgearbeiteter Bogen mit Spannen, Köcher, Pfeilen je Material | LGPL 2.1 | November 2026 |
| [Throwing](https://github.com/minetest-mods/throwing) mit [Throwing Arrows](https://github.com/minetest-mods/throwing_arrows) | Bögen je Material, Sonderpfeile | MPL 2.0 | August 2026 |
| [Castle Weapons](https://github.com/minetest-mods/castle_weapons) | Armbrust, Streitaxt | MIT, Armbrust LGPL 2.1 | 2021 |

Bows ist die beste Asset-Quelle, weil die Texturen gemeinfrei sind.

Techniken aus Schusswaffen-Mods, angesehen in [Shooter](https://github.com/stujones11/shooter), [rawf](https://github.com/LoneWolfHT/rawf) als Grundlage des Fernkampfs in [Capture the Flag](https://github.com/MT-CTF/capturetheflag), und [Gunslinger](https://github.com/ClobberXD/gunslinger):

| Technik | Was sie tut | Für Wanderlore |
| --- | --- | --- |
| Strahl statt Geschoss | Der Treffer wird mit einem Strahl vom Auge in Blickrichtung berechnet | Grundlage der Trefferprüfung |
| Strahl in Schritten | Ein unsichtbares Geschoss rückt jeden Takt vor und prüft die Strecke per Strahl | ergibt Flugzeit und Flugbahn, ohne dass ein Pfeil durch Gegner hindurchfliegt |
| Streuung | zufällige Abweichung je Schuss | klein beim Bogen, größer bei wenig Ausdauer |
| Ladezustand im Gegenstand | Munition als Abnutzung | geladene oder ungeladene Armbrust |
| Nachladezeit | Sperre nach dem Schuss | Armbrust lädt langsam |
| Zoom | Sichtfeld wird weich verengt | leichtes Zielen bei gespanntem Bogen |
| Treffer als Schlag | der Treffer zählt wie ein Hieb mit Werkzeugwerten | Rüstung und Monster rechnen ihn ohne Sonderfall |

Die Bogen-Mods schicken einen echten Pfeil als Objekt durch die Welt. Ein schneller Pfeil kann dabei durch einen Gegner hindurchfliegen.

## Generator

- Luanti erzeugt die Welt in Portionen von 80×80×80 Blöcken, erst wenn ein Spieler in die Nähe kommt, allein aus Startwert und Position.
- Seit Luanti 5.9 laufen Lua-Generatoren in einer eigenen Umgebung je Generator-Thread. Siehe [Custom Lua Mapgen](https://docs.luanti.org/mapgen/custom-lua-mapgen).
- [Biome Generator](https://content.luanti.org/packages/Gael%20de%20Sailly/biomegen) bildet Luantis Biom-System in Lua nach, rund 830 Zeilen, LGPL 3.0. Angesehen wurde eine Kopie von 2020 auf [GitHub](https://github.com/gaelysam/biomegen).
- In Minetest Game liegen Kohle und Eisen nahe der Oberfläche, die besseren Erze tiefer, und nach unten werden sie dichter.
- Zum Testen unerreichbarer Orte reichen die Rechte `fly`, `fast` und `noclip` sowie der Befehl `/teleport`.
- Ein Generator in Lua gibt je Portion alle Blöcke einmal an Lua und wieder zurück. Das kostete in der Messung zu M1 mehr als die ganze Rechnung der Landschaft. Portionen, in denen nichts zu tun ist, fasst der Generator deshalb nicht an.
- Ab einer Entfernung von 4 Blöcken zu je 16 schickt der Server Blöcke aus reiner Luft nicht mehr an den Client (Einstellung `block_send_optimize_distance`). Liegt ebener Boden genau an einer Blockgrenze, zeichnet der Client ihn in der Ferne dann nicht, und man sieht eine Lücke in Himmelsfarbe. Auf dem Server ist der Boden vorhanden. In kahler Landschaft fällt das auf; mit Bewuchs dürfte es selten werden, geprüft ist das nicht. Die Testwelt setzt den Wert auf 32.

## Luanti Education Platform

Gelesen am 22.11.2026 im Repository [luanti-education-platform](https://github.com/peddn/luanti-education-platform):

- Welten laufen fest auf Minetest Game. Der Agent schreibt `gameid = minetest` in jede Welt.
- Fremde Mods werden über `third_party/mods.toml` in fester Version geladen. Dort lassen sich auch Welt-Einstellungen setzen.
- Die Mod-Liste kennt bisher einen Mod je Eintrag.
- Lobby und Lernräume liegen ab Höhe 10.000. Das Portal zur Wildnis steht am Startpunkt der Welt.
- Mobs Redo, Mobs Monster und Awards sind dort als geplante Fremd-Mods genannt.

## Vorbilder für Mechaniken

**Hytale**

- Erinnerungen entstehen durch das Entdecken von Kreaturen und werden an einer Statue abgegeben. Bei festen Meilensteinen gibt es Belohnungen. Siehe [4Netplayers](https://www.4netplayers.com/en/blog/hytale/hytale-memories-find-locations-tips-rewards/).
- Stufen der Werkbank kosten Material. Siehe [Nerdschalk](https://nerdschalk.com/hytale-complete-workbench-upgrade-guide-materials-and-tips/).
- Beim Farming gibt es eine Essenz, mit der man Saatgut kauft. Siehe [Nerdschalk](https://nerdschalk.com/complete-farmers-workbench-upgrade-guide-for-hytale/).

Wanderlore weicht ab: Lore wird ausgegeben statt an Meilensteinen belohnt, und sie zählt nicht nur Kreaturen.

**Valheim**

- Es gibt keinen Hunger. Ohne Nahrung hat man nur kleine Leisten für Leben und Ausdauer und heilt nicht von selbst. Siehe [Corrosion Hour](https://www.corrosionhour.com/how-does-food-work-in-valheim/).
- Der Magen hat drei Plätze, jedes Gericht darf nur einmal darin liegen. Siehe [PC Gamer](https://www.pcgamer.com/au/best-valheim-food-recipes-combo-list).
- Die Werte der drei Plätze addieren sich. Siehe [allthings.how](https://allthings.how/valheim-best-food-for-every-biome-1-0/).

**Diablo 1** als Vorbild für Dungeons aus Bausteinen mit mehreren Ebenen.

## Arbeitsumgebung

- Luanti 5.18.0 lässt sich als fertiges Paket aus der Luanti-Paketquelle installieren, wie die `CLAUDE.md` von LEP es beschreibt.
- Auf einem unsichtbaren Bildschirm (Xvfb) startet der Client, und Screenshots sind möglich. So entstanden die Kataloge.
- Geladen und fehlerfrei gestartet wurden zusammen: Minetest Game, Farming Redo, Mobs Redo, Mobs Monster.
