# Wanderlore: Fremde Medien

Hier steht jede Datei, die nicht für Wanderlore selbst entstanden ist: Texturen, Modelle, Klänge, Musik. Der eigene Code steht unter LGPL 3.0, siehe [`LICENSE`](../LICENSE). Übernommene Medien behalten ihre Lizenz.

## Regeln

- **Erst eintragen, dann übernehmen.** Eine fremde Datei kommt erst ins Repository, wenn sie hier mit Autor, Lizenz und Quelle steht.
- **Jede Datei einzeln prüfen.** Die Lizenzangabe eines Mods gilt nicht immer für alle seine Dateien.
- **Bei unklarer Lizenz nicht übernehmen,** sondern den Autor von Wanderlore fragen. Bekannter Fall: Paleotest.
- **Die Quelle ist genau:** Repository und Commit, aus dem die Datei stammt.
- **Veränderte Dateien** werden als verändert gekennzeichnet, mit einem Wort dazu, was geändert wurde.

Woher Assets kommen können, steht in [recherche.md](recherche.md).

## Dateien

Stand 22.11.2026: sieben Texturen für Reed Meres aus Extra Biomes. Alle liegen unter `modpack/wl_world/textures/`.

| Datei | Autor | Lizenz | Quelle | Verändert |
| --- | --- | --- | --- | --- |
| `wl_world_swamp_grass.png` | CowboyLv | CC BY-SA 3.0 | [Extra Biomes](https://github.com/CowboyLva/ebiomes), Commit `67623c25b5449c0f821fde70211ba2f88aa9e724`, dort `textures/ebiomes_grass_swamp.png` | nein, nur umbenannt |
| `wl_world_swamp_grass_side.png` | CowboyLv | CC BY-SA 3.0 | [Extra Biomes](https://github.com/CowboyLva/ebiomes), Commit `67623c25b5449c0f821fde70211ba2f88aa9e724`, dort `textures/ebiomes_grass_swamp_side.png` | nein, nur umbenannt |
| `wl_world_peat.png` | CowboyLv | CC BY-SA 4.0 | [Extra Biomes](https://github.com/CowboyLva/ebiomes), Commit `67623c25b5449c0f821fde70211ba2f88aa9e724`, dort `textures/ebiomes_peat_dry.png` | nein, nur umbenannt |
| `wl_world_swamp_moss_green.png` | CowboyLv | CC BY-SA 4.0 | [Extra Biomes](https://github.com/CowboyLva/ebiomes), Commit `67623c25b5449c0f821fde70211ba2f88aa9e724`, dort `textures/ebiomes_swamp_moss_green.png` | ja: dunkler und kräftiger, Helligkeit 60 %, Sättigung 200 % |
| `wl_world_swamp_moss_green_side.png` | CowboyLv | CC BY-SA 4.0 | [Extra Biomes](https://github.com/CowboyLva/ebiomes), Commit `67623c25b5449c0f821fde70211ba2f88aa9e724`, dort `textures/ebiomes_swamp_moss_green_side.png` | ja: dunkler und kräftiger, Helligkeit 60 %, Sättigung 200 % |
| `wl_world_swamp_moss_yellow.png` | CowboyLv | CC BY-SA 4.0 | [Extra Biomes](https://github.com/CowboyLva/ebiomes), Commit `67623c25b5449c0f821fde70211ba2f88aa9e724`, dort `textures/ebiomes_swamp_moss_yellow.png` | ja: dunkler und kräftiger, Helligkeit 85 %, Sättigung 160 % |
| `wl_world_swamp_moss_yellow_side.png` | CowboyLv | CC BY-SA 4.0 | [Extra Biomes](https://github.com/CowboyLva/ebiomes), Commit `67623c25b5449c0f821fde70211ba2f88aa9e724`, dort `textures/ebiomes_swamp_moss_yellow_side.png` | ja: dunkler und kräftiger, Helligkeit 85 %, Sättigung 160 % |

Die Farbe der vier Moos-Texturen wurde mit ImageMagick verändert: `convert <Quelle> -modulate <Helligkeit>,<Sättigung> PNG32:<Ziel>`, für das grüne Moos mit `60,200`, für das gelbe mit `85,160`. Als Abwandlungen stehen sie unter derselben Lizenz wie ihre Vorlagen.

Zur Lizenz: Die Datei `license.txt` von Extra Biomes nennt Torf und Sumpfmoos namentlich als eigene Texturen unter CC BY-SA 4.0. Sumpfgras steht dort nicht einzeln; es fällt unter den allgemeinen Abschnitt für Abwandlungen von Texturen aus Minetest Game, CC BY-SA 3.0, Copyright CowboyLv. Die Seitenansichten der Moose sind dort ebenfalls nicht einzeln genannt und hier wie ihre Oberseiten eingeordnet. Das ist eine Lesart der Lizenzdatei, keine Angabe je Datei.
