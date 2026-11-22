# Wanderlore: Konzept

Fassung 1.9 · 22.11.2026 · Luanti 5.18, Minetest Game · Gebaut ist der Prototyp des Generators, vom Spiel selbst noch nichts

Wanderlore ist ein Modpack für Luanti, in dem man durch Entdecken wächst statt durch Graben. Man zieht durch eine in Zonen gegliederte Welt, sammelt dabei Lore und schaltet damit Rezepte frei. Was man selbst herstellt, kommt aus dem eigenen Garten und ist pflanzlich; das Seltene gibt nur die Wildnis her.

Diese Fassung bündelt alle Entscheidungen bis zum 22.11.2026. Woher Assets kommen können und was die Recherche ergab, steht in [recherche.md](recherche.md). In welchen Schritten gebaut wird, steht in [arbeitsplan.md](arbeitsplan.md).

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
| Lizenz | Eigener Code unter LGPL 3.0. Übernommene Medien behalten ihre Lizenzen |
| Texte im Spiel | Englisch im Code, deutsche Übersetzung über Luantis Übersetzungssystem |

## 2. Ziel und Ablauf

### Das Ziel

Die Welt selbst ist das Rätsel. Tief unter ihr liegt die Zwischenschicht, und der einzige Weg hinab führt durch die Schlote der Vulkaninseln. Die sind versiegelt.

1. **Die Siegel** sind Blöcke in den Schloten, die sich nur mit einem bestimmten Werkzeug abbauen lassen.
2. **Das Werkzeug** stellt man aus vier Zutaten her, je eine aus den Strongholds der vier Elemente: Feuer, Wasser, Erde und Luft. Jedes der vier Biome von Zone 3 steht für ein Element und hat seinen Stronghold. Weil diese Biome nach Himmelsrichtung verteilt sind, muss man den ganzen Kontinent bereisen.
3. **Das Werkzeug verbraucht sich.** Eines reicht, um einen Vulkan zu öffnen.
4. **Der Abstieg** in die Zwischenschicht ist der Höhepunkt. Dort wartet als letzter Gegner ein Drache.
5. **Danach geht es weiter.** Die Zwischenschicht reicht unter dem Meer hindurch und kann später zu weiteren Kontinenten führen.

Die Vulkane sind nicht von weitem zu sehen, weil Luanti nur die nähere Umgebung zeichnet. Sie sind über die Inseln verteilt und müssen gefunden werden.

Daneben gibt es ein stilles zweites Ziel: ein vollständiges Lorebook.

### Die erste Stunde

1. **Ankunft im Startland** mit leerem Inventar, wenig Leben und wenig Ausdauer, weil der Magen leer ist.
2. **Erste Nahrung sammeln.** Wilde Feldfrüchte roh essen füllt die Leisten etwas.
3. **Werkzeug aus Holz und Stein**, wie in Minetest Game.
4. **Saatgut anbauen**, den ersten Herd bauen, das erste Gericht kochen.
5. **Die erste Nacht:** schwache Monster. Ein Unterschlupf und ein Bett, das den Wiedereinstieg festlegt.
6. **Die drei Biome des Startlands durchwandern.**
7. **Flach graben:** Kohle überall, Kupfer unter dem einen Biom, Zinn unter einem anderen. Bronze.
8. **Die Lore-Station bauen und die erste Lore ausgeben.** Hier fällt die erste Entscheidung.
9. **Der Fluss.** Für die zweite Stufe einer Station braucht man Material von drüben.

Es gibt keine Anleitung und keine Aufgabenliste. Das Lorebook zeigt, wie viel in jedem Bereich noch fehlt, und weist so den Weg.

## 3. Form und Kompatibilität

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

## 4. Die Welt

### Aufbau des Generators

Luantis eigene Generatoren erzeugen zuerst die Landschaftsform und wählen danach das Biom aus Temperatur und Feuchtigkeit. Deshalb haben dort alle Biome dieselbe Form. Wanderlore dreht die Reihenfolge um:

1. **Zelle.** Die Position wird mit Rauschen leicht verschoben und der nächstgelegenen Zelle zugeordnet.
2. **Zone und Biom der Zelle.**
3. **Landschaftsform** aus der Höhenformel des Bioms.
4. **Oberfläche, Bewuchs, Landmarken** nach dem Biom.
5. **Erze, Höhlen, Dungeons, Strongholds.**

Weil Zone und Biom nur berechnet werden, sind sie auch für Gegenden bekannt, die noch nicht erzeugt sind.

**Stand des Prototyps (G1):** Die Schritte 1 bis 4 sind gebaut, Schritt 4 ohne Bewuchs und Landmarken. Alle Zellen gehören zu Zone 1, und jede Zelle ist 1.000 Blöcke groß und bekommt eines der drei Biome per Zufall aus dem Startwert der Welt. Zonen, das Austeilen der Biome und das Meer kommen mit G2. Der Meeresspiegel ist der von Luanti, in der Voreinstellung Höhe 1.

### Die Weltkarte

Skizze und Verfahren: `docs/weltkarte/`.

| | Zone 1 Startland | Zone 2 Wildnis | Zone 3 Ödland | Inseln |
| --- | --- | --- | --- | --- |
| Charakter | freundlich, Grundzutaten | abwechslungsreich | karg, gefährlich | Sonderzone, nur über Wasser |
| Äußerer Rand ab Start | 4.000 Blöcke | 7.500 | 11.500 | 14.000 bis 17.500 |
| Fußweg bis zum Rand | ca. 16 Minuten | ca. 31 | ca. 48 | – |
| Zellgröße | 1.000 | 1.000 | 1.000 | 800 |
| Biome | 3 | 5 | 4 | 3, dazu Vulkaninseln |
| Austeilen der Biome | reihum | nach Richtung | nach Richtung | nach Richtung |
| Ein Biom-Land ist etwa | 1.000 breit | 4.500 breit | 7.000 breit | Inselgruppen |

- **Eine Zelle gehört immer ganz zu einer Zone.** So zerschneidet keine Zonengrenze ein Biom.
- **Die Zellgröße 1.000 ist ein Versuch.** Mit 1.600 wirkten die Biome dem Autor im Prototyp sehr groß. Die Skizze in `docs/weltkarte/` rechnet noch mit 1.600; sie wird mit G2 angepasst, ebenso die Zellgröße der Inseln und die Breite der Biom-Länder in Zone 2 und 3.
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

Die Formeln der drei Biome von Zone 1, in Blöcken über dem Meeresspiegel. Alle Zahlen sind Startwerte:

| Biom | Grundhöhe | Form | Oberfläche |
| --- | --- | --- | --- |
| Blossom Downs | 12 | flache Hügel von ±10 zwischen Flüssen. Ein Fluss ist etwa 28 breit und bis 3 tief und mäandert in weiten Schwüngen. Neben ihm liegt eine ebene Aue, einen Block über dem Wasser und je Seite etwa 15 breit; erst dahinter steigt das Land langsam zu den Hügeln an | Gras, am Ufer und im Wasser Sand |
| Reed Meres | 1,6 | eben, das Land liegt 1 oder 2 über dem Wasser und nirgends höher. Viele kleine Mulden von 10 bis 40 Breite sinken unter den Wasserspiegel und werden Tümpel, etwa 3 tief. Zum Tümpel hin senkt sich das Land, sodass das Ufer höchstens einen Block über dem Wasser liegt | Sumpfgras mit ebenen Flecken aus grünem und gelbem Sumpfmoos, am Ufer und im Wasser Torf |
| Old Wood | 30 | lange Wellen von ±10, darauf enge Kuppen und Mulden von ±8 im Abstand von etwa 50. Dazu Waldseen über dem Meeresspiegel | Nadelstreu, dazu Findlinge aus Stein, etwa ein Drittel der Blöcke bemoost |

Bis auf die Waldseen steht alles Wasser des Prototyps auf Meereshöhe, auch die Flüsse von Blossom Downs. Deshalb liegen sie alle gleich hoch, und die Hügel steigen von ihnen aus an. Zur Biomgrenze hin laufen sie aus, weil sich dort die Höhe mit der des Nachbarn mischt. Gewässer, die einen Hang hinabfließen oder Biome verbinden, gehören zu den Flüssen in G3.

Die Flüsse mäandern, weil ihr Rauschen an einer um bis zu 100 Blöcke verschobenen Stelle gelesen wird. Dabei schließt sich gelegentlich ein Bogen zu einem Ring um eine kleine Insel.

Die Waldseen von Old Wood entstehen aus einem eigenen Wasserspiegel des Bioms, 24 über dem Meer: Jede Mulde, die tiefer liegt, füllt sich bis dorthin. So liegen die Seen in Gruppen in den Niederungen, und die höheren Gegenden bleiben trocken. Das Ufer liegt von selbst einen Block über dem Wasser. Zur Biomgrenze hin fällt das Land zum Nachbarn ab; deshalb hält der Generator den äußersten Streifen des Bioms als natürlichen Rand über dem Wasserspiegel, und jenseits davon gibt es dieses Wasser nicht. Am Wasser gilt in allen drei Biomen: höchstens ein Block hinab.

Jedes Biom hat im Prototyp eine Deckschicht aus einem Block, dazu je einen für Ufer und Gewässergrund. Findlinge sind eigene Körper aus anderen Blöcken, und Flecken ersetzen die Deckschicht an verstreuten Stellen, ohne die Höhe zu ändern.

Reed Meres hat die ersten eigenen Blöcke von Wanderlore: Sumpfgras, zwei Sumpfmoose und Torf, mit Texturen aus Extra Biomes. Die Farbe der Moose ist gegenüber der Vorlage dunkler und kräftiger, damit sich die Flecken vom Gras abheben. Der Torf ist ein fester Block. Das Wasser bleibt das von Minetest Game. Ein eigenes Sumpfwasser kommt frühestens mit dem Bewuchs.

### Übergänge

- **Zwischen Biomen derselben Zone** werden die Grundhöhen weich gemischt, und die Form blendet zur Grenze hin aus.
- **An Zonengrenzen liegt eine sichtbare Schwelle:** zwischen Zone 1 und 2 ein Fluss, zwischen Zone 2 und 3 ein Höhenzug.
- **Zwischen Varianten desselben Bioms** gleiten die Regler der Formel ineinander.
- **Die Mischzone ist schmal**, zum Start 120 Blöcke je Seite. Das Mischen der Grundhöhen und das Ausblenden der Form sind seit G1 gebaut.
- **Oberfläche und Bewuchs** wechseln gesprenkelt über etwa 40 Blöcke. Im Prototyp wechselt die Oberfläche noch hart an der Grenze.
- **Küste:** je Biom Strand oder Steilküste.

### Erze und Tiefe

Für ein Erz braucht es drei Dinge: die richtige Zone, das richtige Biom und die richtige Tiefe. Tiefen in Blöcken unter der Oberfläche, als Startwerte:

| Schicht | Tiefe | unter Zone 1 | unter Zone 2 | unter Zone 3 und Inseln |
| --- | --- | --- | --- | --- |
| obere | 0 bis 30 | Kupfer, Zinn | Kupfer, Zinn | Kupfer, Zinn |
| mittlere | 30 bis 120 | taubes Gestein | Eisen, Gold | Eisen, Gold |
| tiefe | 100 bis 250 | taubes Gestein | taubes Gestein | Mese, Diamant |

- **Kohle liegt überall in der oberen Schicht,** unabhängig von Zone und Biom. Sie ist kein Erz, sondern ein guter Brennstoff.
- **Die drei Biome von Zone 1:** unter Blossom Downs liegt Kupfer, unter Reed Meres Zinn, unter Old Wood besonders viel Kohle. Für Bronze muss man also zwei Biome aufsuchen.
- **Erze der inneren Zonen laufen in ihrer Schicht nach außen weiter.**
- **Das Biom entscheidet, welches Erz einer Schicht es gibt.**
- **Keine Anzeichen an der Oberfläche.** Das Entdecken besteht darin, in einem Biom tief genug zu graben.
- **Besondere Stoffe der Inseln** gibt es nur als Beute in den Strongholds der Inseln.
- Kupfer, Zinn, Bronze und die Werkzeuge daraus gibt es in Minetest Game. Werkzeugstufen und Rezepte für Werkzeuge bleiben die von dort.

In Minetest Game liegt Bronze nur knapp unter Stahl: gleicher Schaden, etwas langsamer beim Abbauen, etwas kürzere Haltbarkeit. Ob der Schritt von Zone 1 zu Zone 2 damit groß genug ist, zeigt sich im Spiel.

### Unter der Erde

- **Höhlen** sollen hohe Qualität haben: gut zu erforschen, ohne Rundwege, nicht zu lang, schön beleuchtet, mit eigenen Gegnern und schöner Dekoration. Geplant sind drei Typen.
- **Dungeons** entstehen aus Bausteinen. Der Autor baut einzelne Räume und Gänge, der Generator setzt sie zu immer anderen Anlagen zusammen, ähnlich wie in Diablo 1: mehrere Ebenen, nach unten härter.
- **Die Zwischenschicht** ist eine durchgehende zweite Welt etwa 360 bis 460 Blöcke unter dem Meer. Thema ist die Urzeit, mit Dinosauriern und Drachen. Sie ist die Zone des späten Spiels und liefert dessen Rohstoffe.
- **Über der Zwischenschicht liegt unzerstörbares Gestein.** Nur die Schlote der Vulkaninseln durchbrechen es, und die sind versiegelt (Abschnitt 2). Geplant sind vier Vulkaninseln.
- **Vorerst bleibt die Zwischenschicht leer** und gesperrt.

### Biome

Die Biome sind eigene, aus vorhandenem Material neu zusammengesetzt. Jedes ist ein Steckbrief aus Landschaftsform, Farbpalette, Pflanzenmischung, Landmarke, Atmosphäre und einer eigenen Regel.

Jedes Biom hat außerdem etwas, das es nur dort gibt:

- **eine eigene Holzart**
- **eine Feldfrucht**
- **eine Kochzutat**
- **eine Zutat für die Alchemie**

Dazu kommen gegebenenfalls sein Erz, seine Monster und sein Stronghold-Typ. Bei 15 Biomen sind das je 15 Holzarten, Feldfrüchte, Kochzutaten und Zutaten für die Alchemie.

Welche Biome es gibt, entsteht mit der Zeit am Generator. Festgelegt sind die drei Biome von Zone 1, mit denen der Prototyp beginnt; die übrigen sind erste Skizzen. Alle Namen sind Arbeitsnamen.

| Arbeitsname | Zone | Landschaft | Besonderheit |
| --- | --- | --- | --- |
| Blossom Downs | 1 | weite, runde Hügel mit eingeschnittenen Bachtälern | blühende Bäume, Riesenbäume als Wegmarken |
| Reed Meres | 1 | flaches Tiefland mit vielen kleinen Seen und Tümpeln | Schilf, Weiden, Seerosen |
| Old Wood | 1 | buckliger Waldboden aus Kuppen und Mulden, Lichtungen | sehr hohe alte Bäume, Moos, Findlinge |
| Bamboo Terraces | 2 | gestufte Terrassen mit Wasserbecken | Reis wächst wild |
| Mushroom Hollows | 2 | tiefe Senken | Pilze leuchten nachts |
| Ember Scar | 3, Feuer | Schluchten in rotem Fels, Lavaflüsse | Hitze |
| Frost Spires | 3, Wasser | Eisnadeln, dazwischen Frostwald | Schneesturm senkt die Sicht |
| Crystal Atoll | Inseln | Ringinseln mit Lagune | nachwachsende Kristalle |

## 5. Fortschritt

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

Das **Lorebook** zeigt, was gefunden ist und wie viel noch fehlt, ohne das Fehlende zu verraten. Es ist kein Gegenstand, sondern ein Reiter im Inventar. So kann man es weder ablegen noch verlieren.

Mit Lore schaltet man **Rezepte** frei, die dann an den Stationen zur Verfügung stehen. Ausgegeben wird sie an einer eigenen, baubaren Station:

- **Lore wird ausgegeben.** Der Spieler entscheidet, welche Rezepte er freischaltet.
- **Lore reicht nicht für alles.** Richtwert: genug für einen der Bereiche Waffen, Rüstung und Alchemie ganz und für einen zweiten zur Hälfte.
- **Rezepte bilden Ketten** von schlecht nach gut, zum Beispiel für Schwerter, für Bögen und für Wurftränke. Es gibt keine Gabelungen und keine förmliche Wahl. Die Spezialisierung ergibt sich allein aus der Knappheit.
- **Die Küche steht allen offen.** Ihre Rezepte sind billig.
- **Umentscheiden ist gegen einen Preis möglich.**
- **Freischaltungen gelten je Spieler.** Eine Station zeigt jedem die Rezepte, die er kennt.

### Stationen

Hergestellt wird an drei Stationen: Herd, Kessel und Schmiede. Ein Rezept braucht die freigeschaltete Kenntnis und eine Station der nötigen Stufe. Die vierte Station ist die Lore-Station, an der man Rezepte freischaltet. Sie ist billig zu bauen und hat keine Stufen.

Stationen werden nur mit Material aufgewertet, Lore spielt dabei keine Rolle. Das Material für höhere Stufen liegt in den äußeren Zonen und in Strongholds. Das lädt dazu ein, sich in gefährliche Gebiete zu wagen.

Waffen und Rüstungen entstehen nur an der Schmiede, weil das normale Handwerksfeld Rezepte nicht je Spieler sperren kann. Werkzeuge wie Spitzhacken bleiben im Handwerksfeld.

### Essenz

Reife Feldfrüchte geben beim Ernten manchmal Lebensessenz, wilde Pflanzen öfter. Damit kauft man Saatgut von Sorten, die man noch nicht gefunden hat. Essenz ist erneuerbar, Lore nicht.

## 6. Überleben

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

## 7. Herstellen

### Farming und Küche

- **Feldfrüchte** nach Auswahl aus den 42 von Farming Redo, nur die Texturen. Angebaut wird mit dem Farming aus Minetest Game.
- **Jedes Biom hat seine Feldfrucht.** Sie wächst dort wild und ist die Quelle des Saatguts.
- **Jedes Biom hat seine Kochzutat**, etwa ein Gewürz, einen Pilz oder eine Beere.
- **Herd** mit vier Zutatenfächern, Brennstoff und Rezepte-Reiter.
- **Alle Rezepte sind pflanzlich.** Tofu ersetzt Fleisch.
- Bessere Gerichte brauchen Zutaten aus mehreren Biomen und höhere Stufen des Herds.

### Alchemie

- **Zutaten:** eine je Biom, nicht anbaubar.
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

## 8. Gegner, Bauwerke und Zusammenspiel

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

### Schutz durch Häuser

Ein Haus schützt vor den Monstern der Nacht. Monster entstehen nicht in Häusern. Als Regel für den Bau: Monster entstehen nur auf natürlichem Boden und nur im Dunkeln. Gebaute Böden und Licht halten sie fern, und Türen öffnen sie nicht.

### Mehrspieler, Tod und Wiedereinstieg

- **Handel** ist normales Tauschen von Gegenständen. Ein eigenes Handelssystem gibt es nicht.
- **Stationen** kann jeder bedienen. Jeder sieht dort die Rezepte, die er selbst kennt.
- **Kampf zwischen Spielern** ist wahlweise an oder aus, als Einstellung der Welt.
- **Tod** wie in Minetest Game.
- **Wiedereinstieg** am eigenen Bett, sonst am Startpunkt.

### Klang und Musik

Klänge und Musik kommen zunächst als vorläufige Platzhalter ins Spiel. Die Musik schreibt der Autor später selbst.

## 9. Technik

### Mods

| Mod | Aufgabe | braucht |
| --- | --- | --- |
| `wl_world` | Generator, Zonen, Biome, Verteilung von allem in der Welt | Minetest Game |
| `wl_lore` | Lore sammeln, Lorebook, Lore-Station, Freischalten von Rezepten | `wl_world` |
| `wl_vitals` | Leben, Ausdauer, Wirkung von Nahrung | – |
| `wl_farming` | Feldfrüchte, Speisen, Herd, Essenz | `wl_world`, `farming` |
| `wl_alchemy` | Wildkräuter, Kessel, Tränke, Wurftränke | `wl_world`, `vessels` |
| `wl_combat` | Waffen, Rüstungen, Schmiede, Aufwertungen, Geschoss-System | 3D Armor |
| `wl_monsters` | Monster und Tiere | `wl_world`, Mobs Redo |
| `wl_strongholds` | Baukasten, Platzierung, Beute, Spawner, Dungeon-Bausteine | `wl_world` |

`wl_vitals` ist ein Vorschlag aus dieser Fassung und noch nicht bestätigt.

Nicht zum Modpack gehört der Hilfs-Mod `wl_dev` unter `devmods/`. Er dient nur der Entwicklung: Er setzt Tester auf die Oberfläche, springt mit `/wl_goto` in ein Biom, misst den Generator und stellt die Kamera für Screenshots. Die Skripte binden ihn nur in die Testwelten ein. Auch er fragt `wl_world`, wo etwas liegt.

`wl_world` beantwortet bisher fünf Fragen: welches Biom, welche Zone, wo ein sicherer Ort an der Oberfläche liegt, wo die nächste Zelle eines Bioms liegt und wo der nächste Waldsee liegt.

Regel für alle: Nur `wl_world` weiß, wo etwas liegt. Die anderen Mods melden ihre Kräuter, Erze, Monster und Bauwerke dort mit Biom und Zone an und fragen sonst nur „welches Biom, welche Zone?“.

### Stufen des Generators

| Stufe | Inhalt | Fertig, wenn |
| --- | --- | --- |
| G1 Prototyp | Landschaftsformen und die drei Biome von Zone 1 | Screenshots zeigen deutlich verschiedene Landschaften, die Geschwindigkeit ist gemessen |
| G2 Weltkarte | Zonen, Lage der Biome, Meer und Inseln, Übergänge | man kann vom Startland bis zu einer Insel reisen |
| G3 Ausbau | Erzschichten, Flüsse, Platz für Höhlen und Zwischenschicht freigehalten | eine Welt lässt sich flüssig erkunden |
| G4 Unterwelt | Höhlen und Dungeons | man findet Höhlen und steigt in ihnen ab |
| G5 Zwischenschicht | die zweite Welt, die Schlote der Vulkaninseln öffnen sich | man reist durch einen Vulkan hinab |

Selbst zu liefern sind Höhlen, Flüsse, Dungeons, die Auswahl der Biome, der Bewuchs und die Erzverteilung. Große Bauwerke reichen über mehrere Portionen der Welt; ihr Ort muss deshalb vorab berechenbar sein.

## 10. Reihenfolge und Umfang

Gebaut wird in 15 Meilensteinen, die im [Arbeitsplan](arbeitsplan.md) stehen. Die Reihenfolge in Kürze: zuerst die Welt bis zur Weltkarte, dann Lore in einfacher Form, dann der Ausbau der Welt, danach Überleben, Küche, Alchemie, Bauwerke, Monster, Kampf und die vollständige Lore, zuletzt Unterwelt, Zwischenschicht und die Spiel-Hülle.

Lore kommt früh, weil sich erst dort zeigt, ob Entdecken als Fortschritt trägt.

Grober Umfang: 7.000 bis 10.000 Zeilen Lua, davon etwa ein Drittel für den Generator. Die Zahl ist eine Schätzung ohne Messung. Dazu kommt die Bauzeit des Autors für Strongholds und Dungeon-Bausteine.

## 11. Risiken

- **Der Generator ist zu langsam** für viele gleichzeitige Spieler. In G1 gemessen: Der Prototyp braucht etwa ein Viertel der Zeit von Luantis Generator v7, hat aber noch keinen Bewuchs, keine Erze und keine Höhlen. Die Zahlen stehen im [Arbeitsplan](arbeitsplan.md). Jede weitere Stufe wird neu gemessen.
- **Übergänge zwischen Biomen** sehen unnatürlich aus. Wird in G2 sichtbar.
- **Feinschliff ohne Ende.** Jede Generator-Stufe hat deshalb ein festes Ende.
- **Assets aus vielen Quellen passen optisch nicht zusammen.** Bei den Monstern ist das im Katalog schon zu sehen.
- **Lizenzen der Medien sind gemischt.** Jede Datei behält Autor und Lizenz in der Lizenzdatei. Einzelne Quellen sind vor einer Übernahme zu klären.
- **Knappe Lore im Einzelspiel.** Wer allein spielt, sieht einen großen Teil der Rezepte nie.
- **Der Umfang ist groß** für ein Projekt ohne festen Zeitplan.
- **Das Spielgefühl lässt sich nur im Spiel beurteilen**, nicht an Screenshots.

## 12. Offen

Bewusst auf später verschoben, weil es sich aus dem Spielen ergibt:

- welche Biome es gibt
- welche Feldfrüchte, Gerichte, Waffen, Rüstungen und Tränke je Stufe
- Werte für Leben, Ausdauer, Gerichte und Lore-Kosten

Noch zu entscheiden:

1. **Monster und Tiere** je Lebensraum aus dem Katalog auswählen.
2. **Der Preis für das Umentscheiden** bei Lore.
3. **Wo man Essenz gegen Saatgut tauscht.**
4. **`wl_vitals`** als eigener Mod.

5. **Welche Biome der äußeren Zonen welches Erz bekommen.** Das folgt, sobald es diese Biome gibt.
6. **Biome für Erde und Luft** in Zone 3. Für Feuer und Wasser gibt es Skizzen: Ember Scar und Frost Spires.
7. **Das Lorebook als Reiter im Inventar** ist mit dem Inventar von LEP abzugleichen.

Später:

8. **Anzeige und Bedienung.** Leisten für Leben und Ausdauer, Magen, Fenster der Stationen.
