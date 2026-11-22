# Wanderlore: Konzept

Fassung 1.0 · 22.11.2026 · Luanti 5.18, Minetest Game · Vom Spiel selbst ist noch nichts gebaut

Wanderlore ist ein Modpack für Luanti, in dem man durch Entdecken wächst statt durch Graben. Man zieht durch eine in Zonen gegliederte Welt, sammelt dabei Lore und schaltet damit Rezepte frei. Was man selbst herstellt, kommt aus dem eigenen Garten und ist pflanzlich; das Seltene gibt nur die Wildnis her.

Diese Fassung bündelt alle Entscheidungen bis zum 22.11.2026. Woher Assets kommen können und was die Recherche ergab, steht in [recherche.md](recherche.md).

## 1. Grundsätze

| Thema | Entscheidung |
| --- | --- |
| Alleinstellungsmerkmal | Fortschritt durch Entdecken statt durch Abbauen |
| Vegan-Regel | Was Spieler anbauen, kochen oder brauen, ist pflanzlich. Tierisches gibt es nur als Beute |
| Form | Modpack auf unverändertem Minetest Game. Später eine dünne Spiel-Hülle für Einzelspieler |
| Entwicklung | Unabhängig. Die Inhalte entscheidet der Autor |
| Fremde Mods | Nur Assets übernehmen, nach Auswahl. Als Abhängigkeit zugelassen sind Mobs Redo und 3D Armor |
| Inhalts-Schalter | Keine. Was im Spiel ist, gehört dazu. Einstellbar sind nur Werte wie Dichte, Tempo, Schaden |
| Monster | Gehören fest dazu |
| Weites Reisen | Soll kosten. Keine Wegsteine, Portale vielleicht später |
| Entwicklungsphase | Keine Rücksicht auf bereits erstellte Welten |
| Reihenfolge | Der Kartengenerator wird zuerst gebaut |
| Namen | Spiel: Wanderlore. Mod-Kürzel: `wl_`. Was man sammelt: Lore |

## 2. Form und Kompatibilität

| Teil | Inhalt | Für wen |
| --- | --- | --- |
| Modpack `wanderlore` | alle eigenen Mods samt Generator | jeder mit Minetest Game, auch die Luanti Education Platform (LEP) |
| Spiel-Hülle | Beschreibung, Voreinstellungen, Skript, das Minetest Game und die Abhängigkeiten in fester Version holt | Einzelspieler |

Der Generator läuft als Mod. Die Welt muss dafür mit dem Generator `singlenode` angelegt werden. Die Hülle setzt das von selbst, LEP über eine Einstellung in seiner Mod-Liste.

Wanderlore hängt nicht von LEP ab, muss aber in dessen Welten laufen können. Daraus folgt:

- **Der Himmel bleibt leer.** LEP legt Lobby und Lernräume ab Höhe 10.000 an.
- **Am Startpunkt liegt Land der Zone 1.** Dort steht bei LEP das Portal zur Wildnis.
- **Wanderlore bestimmt nicht, wo Spieler erscheinen.** Es liefert nur eine Funktion für einen sicheren Ort.
- **Wirkungen nur in der Wildnis.** Über eine optionale Anbindung ruhen Nahrung, Tränke und Stationen in Lobby und Lernräumen.
- **Grundstücksschutz achten**, über Luantis Standardfunktion.
- **Lore liegt in den Spielerdaten**, damit sie beim Löschen eines Kontos mit verschwindet.
- **Viele Spieler gleichzeitig** machen die Geschwindigkeit des Generators zum harten Kriterium.

In LEP sind zwei kleine Anpassungen nötig: Die Mod-Liste muss ein Modpack mit mehreren Mods laden können, und die Überschneidung mit dem Mod Awards ist zu klären.

## 3. Die Welt

### Aufbau des Generators

Luantis eigene Generatoren erzeugen zuerst die Landschaftsform und wählen danach das Biom aus Temperatur und Feuchtigkeit. Deshalb haben dort alle Biome dieselbe Form. Wanderlore dreht die Reihenfolge um:

1. **Zelle.** Die Position wird mit Rauschen leicht verschoben und der nächstgelegenen Zelle zugeordnet.
2. **Zone und Biom der Zelle.**
3. **Landschaftsform** aus der Höhenformel des Bioms.
4. **Oberfläche, Bewuchs, Landmarken** nach dem Biom.
5. **Erze, Höhlen, Dungeons, Strongholds.**

Weil Zone und Biom nur berechnet werden, sind sie auch für Gegenden bekannt, die noch nicht erzeugt sind.

### Die Weltkarte

Skizze und Verfahren: `docs/weltkarte/`.

| | Zone 1 Startland | Zone 2 Wildnis | Zone 3 Ödland | Inseln |
| --- | --- | --- | --- | --- |
| Charakter | freundlich, Grundzutaten | abwechslungsreich | karg, gefährlich | Sonderzone, nur über Wasser |
| Äußerer Rand ab Start | 4.000 Blöcke | 7.500 | 11.500 | 14.000 bis 17.500 |
| Fußweg bis zum Rand | ca. 16 Minuten | ca. 31 | ca. 48 | – |
| Zellgröße | 1.600 | 1.600 | 1.600 | 800 |
| Biome | 3 | 5 | 4 | 3, dazu Vulkaninseln |
| Austeilen der Biome | reihum | nach Richtung | nach Richtung | nach Richtung |
| Ein Biom-Land ist etwa | 1.600 breit | 4.500 breit | 7.000 breit | Inselgruppen |

- **Eine Zelle gehört immer ganz zu einer Zone.** So zerschneidet keine Zonengrenze ein Biom.
- **An Land gibt es nur eine Zellgröße.** Nur die Inseln haben kleinere Zellen, weil sie das Festland nie berühren.
- **Biome werden fest ausgeteilt.** Alle Zellen einer Zone werden aufgezählt und die Biome wie Karten verteilt. Jedes Biom bekommt gleich viele Zellen, keines fehlt.
- **Zone 1 wird reihum ausgeteilt**, damit alle Grundzutaten nah am Start liegen.
- **Zone 2, 3 und die Inseln werden nach Richtung ausgeteilt.** Jedes Biom hat eine Heimatrichtung, mit einzelnen Ausreißern. Wer alle Zutaten will, muss in verschiedene Richtungen reisen.
- **Die Zelle ist die Spielart des Bioms.** Jede Zelle bekommt eine Variante, etwa dicht, licht, mit See oder mit Landmarke.
- **Hinter dem Meer ist Platz.** Die Welt reicht bis etwa 31.000 Blöcke. Dort können später weitere Kontinente mit neuen Zonen liegen.

### Landschaftsformen

Skizzen: `docs/landschaft/`.

Jedes Biom hat eine Höhenformel aus zwei Teilen: einer **Grundhöhe** und der **Form**, etwa Stufen, Einschnitte oder Nadeln. Bisher skizziert sind Hügel mit Bachtälern, Terrassen, Schluchten und Felsnadeln.

- **Kräftige Formen.** Die Landschaft darf deutlich dramatischer sein als in Minetest Game.
- **Höchstens etwa 120 Blöcke über dem Meer.**
- **Begehbarkeit nach Zone.** Zone 1 ist überall zu Fuß begehbar. Nach außen wird das Gelände sperriger, in Zone 3 so, dass man bauen, klettern oder einen Trank nutzen muss.
- **Dreidimensionales Rauschen** nur dort, wo eine Form es braucht, etwa für Bögen und Überhänge.

### Übergänge

- **Zwischen Biomen derselben Zone** werden die Grundhöhen weich gemischt, und die Form blendet zur Grenze hin aus.
- **An Zonengrenzen liegt eine sichtbare Schwelle:** zwischen Zone 1 und 2 ein Fluss, zwischen Zone 2 und 3 ein Höhenzug.
- **Zwischen Varianten desselben Bioms** gleiten die Regler der Formel ineinander.
- **Die Mischzone ist schmal**, zum Start 120 Blöcke je Seite.
- **Oberfläche und Bewuchs** wechseln gesprenkelt über etwa 40 Blöcke.
- **Küste:** je Biom Strand oder Steilküste.

### Erze und Tiefe

Für ein Erz braucht es drei Dinge: die richtige Zone, das richtige Biom und die richtige Tiefe. Tiefen in Blöcken unter der Oberfläche, als Startwerte:

| Tiefe | unter Zone 1 | unter Zone 2 | unter Zone 3 und Inseln |
| --- | --- | --- | --- |
| 0 bis 30 | Kohle, Kupfer, Zinn | Kohle, Kupfer, Zinn | Kohle, Kupfer, Zinn |
| 30 bis 120 | taubes Gestein | Eisen, Gold | Eisen, Gold |
| 100 bis 250 | taubes Gestein | taubes Gestein | Mese, Diamant |

- **Das Biom entscheidet, welches Erz einer Schicht es gibt.**
- **Keine Anzeichen an der Oberfläche.** Das Entdecken besteht darin, in einem Biom tief genug zu graben.
- **Besondere Stoffe der Inseln** gibt es nur als Beute in den Strongholds der Inseln.
- Werkzeugstufen und Rezepte für Werkzeuge bleiben die von Minetest Game.

### Unter der Erde

- **Höhlen** sollen hohe Qualität haben: gut zu erforschen, ohne Rundwege, nicht zu lang, schön beleuchtet, mit eigenen Gegnern und schöner Dekoration. Geplant sind drei Typen.
- **Dungeons** entstehen aus Bausteinen. Der Autor baut einzelne Räume und Gänge, der Generator setzt sie zu immer anderen Anlagen zusammen, ähnlich wie in Diablo 1: mehrere Ebenen, nach unten härter.
- **Die Zwischenschicht** ist eine durchgehende zweite Welt etwa 360 bis 460 Blöcke unter dem Meer. Thema ist die Urzeit, mit Dinosauriern und Drachen. Sie ist die Zone des späten Spiels und liefert dessen Rohstoffe.
- **Über der Zwischenschicht liegt unzerstörbares Gestein.** Nur die Schlote der Vulkaninseln durchbrechen es. Geplant sind vier Vulkaninseln in verschiedenen Himmelsrichtungen.
- **Vorerst bleibt die Zwischenschicht leer** und gesperrt.

### Biome

Die Biome sind eigene, aus vorhandenem Material neu zusammengesetzt. Jedes ist ein Steckbrief aus Landschaftsform, Farbpalette, Pflanzenmischung, Landmarke, Atmosphäre, einer eigenen Regel und seinem Spielinhalt: Kraut, Feldfrucht, Erz, Monster, Stronghold-Typ.

Welche Biome es gibt, entsteht mit der Zeit am Generator. Erste Skizzen:

| Arbeitsname | Zone | Landschaft | Besonderheit |
| --- | --- | --- | --- |
| Blossom Downs | 1 | sanfte Hügel mit Bachtälern | Riesenbäume als Wegmarken |
| Bamboo Terraces | 2 | gestufte Terrassen mit Wasserbecken | Reis wächst wild |
| Mushroom Hollows | 2 | tiefe Senken | Pilze leuchten nachts |
| Ember Scar | 3 | Schluchten in rotem Fels, Lavaflüsse | Hitze |
| Frost Spires | 3 | Eisnadeln, dazwischen Frostwald | Schneesturm senkt die Sicht |
| Crystal Atoll | Inseln | Ringinseln mit Lagune | nachwachsende Kristalle |

## 4. Fortschritt

### Lore

Lore gibt es für alles, was man zum ersten Mal tut. Jeder Spieler hat sein eigenes Konto. Die Werte sind Startwerte:

| Erster Fund | Lore |
| --- | --- |
| Biom betreten | 1 |
| Wildkraut oder wilde Feldfrucht gefunden | 1 |
| Gericht gekocht, Trank gebraut | 1 |
| Erz gefunden | 2 |
| Monsterart besiegt | 2 |
| Höhlentyp, Dungeon oder Stronghold-Typ betreten | 3 |
| Endgegner besiegt | 5 |

Das **Lorebook** zeigt, was gefunden ist und wie viel noch fehlt, ohne das Fehlende zu verraten.

Mit Lore schaltet man **Rezepte** frei, die dann an den Stationen zur Verfügung stehen:

- **Lore wird ausgegeben.** Der Spieler entscheidet, welche Rezepte er freischaltet.
- **Lore reicht nicht für alles.** Richtwert: genug für einen der Bereiche Waffen, Rüstung und Alchemie ganz und für einen zweiten zur Hälfte.
- **Rezepte bilden Ketten** von schlecht nach gut, zum Beispiel für Schwerter, für Bögen und für Wurftränke. Es gibt keine Gabelungen und keine förmliche Wahl. Die Spezialisierung ergibt sich allein aus der Knappheit.
- **Die Küche steht allen offen.** Ihre Rezepte sind billig.
- **Umentscheiden ist gegen einen Preis möglich.**
- **Freischaltungen gelten je Spieler.** Eine Station zeigt jedem die Rezepte, die er kennt.

### Stationen

Es gibt drei Stationen: Herd, Kessel und Schmiede. Ein Rezept braucht die freigeschaltete Kenntnis und eine Station der nötigen Stufe.

Stationen werden nur mit Material aufgewertet, Lore spielt dabei keine Rolle. Das Material für höhere Stufen liegt in den äußeren Zonen und in Strongholds. Das lädt dazu ein, sich in gefährliche Gebiete zu wagen.

Waffen und Rüstungen entstehen nur an der Schmiede, weil das normale Handwerksfeld Rezepte nicht je Spieler sperren kann. Werkzeuge wie Spitzhacken bleiben im Handwerksfeld.

### Essenz

Reife Feldfrüchte geben beim Ernten manchmal Lebensessenz, wilde Pflanzen öfter. Damit kauft man Saatgut von Sorten, die man noch nicht gefunden hat. Essenz ist erneuerbar, Lore nicht.

## 5. Überleben

### Nahrung

Nach dem Prinzip von Valheim. Es gibt keinen Hunger, der einen umbringt. Stattdessen bestimmt Nahrung, wie stark man ist:

- Ohne Nahrung hat man nur eine kleine Grundausstattung an Leben und Ausdauer.
- Man kann drei verschiedene Gerichte gleichzeitig „im Magen“ haben, nie zweimal dasselbe.
- Jedes Gericht erhöht für eine feste Zeit, etwa 10 bis 20 Minuten, das Maximalleben, die Ausdauer und die Heilung. Die Wirkungen addieren sich.
- Einzelne Gerichte haben eine Zusatzwirkung, etwa längeren Atem oder weniger Fallschaden.

### Ausdauer

Ausdauer ist eine zweite Leiste neben dem Leben.

- **Verbraucht wird sie durch** Rennen, Springen, Schwimmen, Hiebe und das Spannen des Bogens.
- **Ist sie leer:** kein Rennen, kein Springen, keine wirksamen Hiebe, kein Spannen. Wer mit leerer Ausdauer schwimmt, nimmt Schaden.
- Sie füllt sich von selbst wieder auf. Das Abbauen von Blöcken kostet keine Ausdauer.

In Luanti lassen sich Hiebe nicht verhindern, aber wirkungslos machen, und zwar gegen die eigenen Monster und gegen Spieler.

### Tränke

Tränke sind das Gegenstück zur Nahrung: kurz, stark, für den Moment. Sie wirken ein bis drei Minuten, Heilung sofort. Verschiedene Tränke lassen sich gleichzeitig nutzen.

## 6. Herstellen

### Farming und Küche

- **Feldfrüchte** nach Auswahl aus den 42 von Farming Redo, nur die Texturen. Angebaut wird mit dem Farming aus Minetest Game.
- **Wildvorkommen** als Saatgutquelle, je Biom verschieden.
- **Herd** mit vier Zutatenfächern, Brennstoff und Rezepte-Reiter.
- **Alle Rezepte sind pflanzlich.** Tofu ersetzt Fleisch.
- Bessere Gerichte brauchen Zutaten aus mehreren Biomen und höhere Stufen des Herds.

### Alchemie

- **Wildkräuter:** eines je Biom, nicht anbaubar.
- **Glasfläschchen:** die Glasflasche aus Minetest Game, an Wasser gefüllt.
- **Kessel:** Wasserflasche plus bis zu drei Zutaten, kein Brennstoff.
- **Tränke zum Trinken** in zwei Wirkstufen. Geplant: Heilung, Schnelligkeit, Sprungkraft, Federfall, Wasseratmung, Feuerschutz, Katzenauge.
- **Wurftränke** als eigene Kette. Sie wirken am Einschlagsort, etwa als Brandsatz oder als Frost, der Gegner verlangsamt.
- **Die höhere Wirkstufe** braucht eine seltene Zutat aus Truhen oder Monster-Beute, darunter Tierisches wie Knochen, Zahn oder Horn.

### Waffen und Rüstung

- **Stufen folgen den Erzen:** Bronze, Stahl, Mese, Diamant, später Stoffe der Zwischenschicht.
- **Rüstung** über 3D Armor.
- **Fernkampf:** Bogen und Armbrust, dazu die Wurftränke der Alchemie. Alle nutzen dasselbe eigene Geschoss-System.
- **Bogen:** Spannen kostet Ausdauer und bestimmt Wucht und Reichweite.
- **Armbrust:** Laden dauert, der Schuss ist stark und kostet keine Ausdauer.
- **Geschosse fliegen in einer Bogenbahn.** Verschossene Pfeile und Bolzen lassen sich mit einer gewissen Chance je Stück wieder aufsammeln.
- **Aufwertungen** an der Schmiede, mit Monster-Beute und den besonderen Stoffen der Inseln.

Technisch wird die Flugbahn mit Strahlen in Schritten berechnet. Der sichtbare Pfeil ist nur Zierde. So fliegt nichts durch einen Gegner hindurch.

## 7. Gegner, Tiere und Bauwerke

### Monster und Tiere

Monster gibt es in der Welt und in Bauwerken, jeweils andere. Bedarf nach Lebensraum:

| Lebensraum | Bedarf | Gedanke |
| --- | --- | --- |
| Welt, Zone 1 | 2 | schwach, nur nachts |
| Welt, Zone 2 | 3 | mittel |
| Welt, Zone 3 | 3 | stark, auch tags |
| Höhlen | 3 bis 6 | ein bis zwei je Höhlentyp |
| Dungeons | 4 und ein Endgegner | nach unten härter |
| Strongholds | 4 und zwei Endgegner | Wächter je Zone |
| Inseln | 3 | einer je Inselgruppe |
| Zwischenschicht | 5 und ein Endgegner | Dinosaurier, Drache |

Zusammen etwa 30 bis 35 Monster. Dazu kommen friedliche Tiere, die die Welt beleben. Ihre Erzeugnisse sind nur Beute; züchten oder melken kann man sie nicht.

Ausgewählt wird im [Wanderlore-Katalog](https://github.com/peddn/wanderlore-catalog), der 200 Wesen aus acht Mods zeigt. Gesteuert werden die Monster über Mobs Redo. Jedes ist ein Eintrag in einer Tabelle. Eigene Monster entstehen zuerst als neue Textur auf einem vorhandenen Modell.

### Strongholds

Strongholds sind ganze Bauwerke an der Oberfläche. Der Autor baut sie im Spiel:

1. In einer Kreativwelt bauen.
2. Marker für Beute und Spawner setzen.
3. Zwei Ecken markieren und mit einem Befehl speichern.
4. Die Datei einmal von Hand aus dem Weltordner in den Mod kopieren.
5. In einer Liste eintragen: Name, Zone, Biome, Seltenheit.
6. Mit einem Befehl zur Probe setzen.

Die Zone bestimmt die Stärke von Beute und Monstern. Platziert wird vom Generator. Die Bausteine der Dungeons nutzen denselben Baukasten und dieselben Marker.

## 8. Technik

### Mods

| Mod | Aufgabe | braucht |
| --- | --- | --- |
| `wl_world` | Generator, Zonen, Biome, Verteilung von allem in der Welt | Minetest Game |
| `wl_lore` | Lore sammeln, Lorebook, Freischalten von Rezepten | `wl_world` |
| `wl_vitals` | Leben, Ausdauer, Wirkung von Nahrung | – |
| `wl_farming` | Feldfrüchte, Speisen, Herd, Essenz | `wl_world`, `farming` |
| `wl_alchemy` | Wildkräuter, Kessel, Tränke, Wurftränke | `wl_world`, `vessels` |
| `wl_combat` | Waffen, Rüstungen, Schmiede, Aufwertungen, Geschoss-System | 3D Armor |
| `wl_monsters` | Monster und Tiere | `wl_world`, Mobs Redo |
| `wl_strongholds` | Baukasten, Platzierung, Beute, Spawner, Dungeon-Bausteine | `wl_world` |

`wl_vitals` ist ein Vorschlag aus dieser Fassung und noch nicht bestätigt.

Regel für alle: Nur `wl_world` weiß, wo etwas liegt. Die anderen Mods melden ihre Kräuter, Erze, Monster und Bauwerke dort mit Biom und Zone an und fragen sonst nur „welches Biom, welche Zone?“.

### Stufen des Generators

| Stufe | Inhalt | Fertig, wenn |
| --- | --- | --- |
| G1 Prototyp | Landschaftsformen und zwei bis drei Biome | Screenshots zeigen deutlich verschiedene Landschaften, die Geschwindigkeit ist gemessen |
| G2 Weltkarte | Zonen, Lage der Biome, Meer und Inseln, Übergänge | man kann vom Startland bis zu einer Insel reisen |
| G3 Ausbau | Erzschichten, Flüsse, Platz für Höhlen und Zwischenschicht freigehalten | eine Welt lässt sich flüssig erkunden |
| G4 Unterwelt | Höhlen und Dungeons | man findet Höhlen und steigt in ihnen ab |
| G5 Zwischenschicht | die zweite Welt, die Schlote der Vulkaninseln öffnen sich | man reist durch einen Vulkan hinab |

Selbst zu liefern sind Höhlen, Flüsse, Dungeons, die Auswahl der Biome, der Bewuchs und die Erzverteilung. Große Bauwerke reichen über mehrere Portionen der Welt; ihr Ort muss deshalb vorab berechenbar sein.

## 9. Reihenfolge und Umfang

| Schritt | Inhalt |
| --- | --- |
| 1 | `wl_world` G1: Prototyp |
| 2 | `wl_world` G2: Weltkarte |
| 3 | `wl_lore` in einfacher Form: Lore für Biome, Lorebook |
| 4 | `wl_world` G3: Ausbau |
| 5 | `wl_vitals`: Leben, Ausdauer, Nahrung |
| 6 | `wl_farming` |
| 7 | `wl_alchemy` |
| 8 | `wl_strongholds`, zuerst der Baukasten |
| 9 | `wl_monsters` |
| 10 | `wl_combat` |
| 11 | `wl_lore` vollständig: Ketten, Freischalten, Umentscheiden |
| 12 | `wl_world` G4: Höhlen und Dungeons |
| 13 | `wl_world` G5: Zwischenschicht |
| 14 | Spiel-Hülle, Anbindung an LEP |

Schritt 3 kommt früh, weil sich erst dort zeigt, ob Entdecken als Fortschritt trägt.

Grober Umfang: 7.000 bis 10.000 Zeilen Lua, davon etwa ein Drittel für den Generator. Die Zahl ist eine Schätzung ohne Messung. Dazu kommt die Bauzeit des Autors für Strongholds und Dungeon-Bausteine.

## 10. Risiken

- **Der Generator ist zu langsam** für viele gleichzeitige Spieler. Wird in G1 gemessen.
- **Übergänge zwischen Biomen** sehen unnatürlich aus. Wird in G2 sichtbar.
- **Feinschliff ohne Ende.** Jede Generator-Stufe hat deshalb ein festes Ende.
- **Assets aus vielen Quellen passen optisch nicht zusammen.** Bei den Monstern ist das im Katalog schon zu sehen.
- **Lizenzen der Medien sind gemischt.** Jede Datei behält Autor und Lizenz in der Lizenzdatei. Einzelne Quellen sind vor einer Übernahme zu klären.
- **Knappe Lore im Einzelspiel.** Wer allein spielt, sieht einen großen Teil der Rezepte nie.
- **Der Umfang ist groß** für ein Projekt ohne festen Zeitplan.
- **Das Spielgefühl lässt sich nur im Spiel beurteilen**, nicht an Screenshots.

## 11. Offen

Bewusst auf später verschoben, weil es sich aus dem Spielen ergibt:

- welche Biome es gibt
- welche Feldfrüchte, Gerichte, Waffen, Rüstungen und Tränke je Stufe
- Werte für Leben, Ausdauer, Gerichte und Lore-Kosten

Noch zu entscheiden:

1. **Monster und Tiere** je Lebensraum aus dem Katalog auswählen.
2. **Der Preis für das Umentscheiden** bei Lore.
3. **Wo man Essenz gegen Saatgut tauscht.**
4. **`wl_vitals`** als eigener Mod.

Noch gar nicht besprochen:

5. **Ziel und Ende des Spiels.** Was ist der Höhepunkt, und was kommt danach?
6. **Die erste Stunde.** Was tut ein neuer Spieler in welcher Reihenfolge?
7. **Mehrspieler.** Handel, gemeinsame Stationen, Kampf zwischen Spielern, Tod und Rückweg.
8. **Bauen und Wohnen.** Hat ein eigenes Haus einen Nutzen?
9. **Anzeige und Bedienung.** Leisten für Leben und Ausdauer, Magen, Lorebook, Fenster der Stationen.
10. **Klang und Musik.**
