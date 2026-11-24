# Wanderlore: Konzept

Fassung 1.9 · 22.11.2026 · Luanti 5.18, Minetest Game · Gebaut sind der Prototyp des Generators und von der Weltkarte Zonen und Austeilen, vom Spiel selbst noch nichts

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

**Stand (G2, alle drei Teile):** Die Schritte 1 bis 4 sind gebaut, Schritt 4 ohne Bewuchs und Landmarken. Jede Zelle ist 700 Blöcke groß, gehört zu einer Zone und bekommt ihr Biom beim Austeilen. An den Zonengrenzen liegen die Schwellen: ein Fluss um Zone 1, ein Höhenzug zwischen Zone 2 und 3. Jenseits von Zone 3 liegt das Meer mit einem Grund etwa 30 unter dem Wasser, und in einem Ring weit draußen liegen die Inseln mit vier Vulkaninseln. Jedes Biom endet am Meer mit Strand oder Steilküste. Der Meeresspiegel ist der von Luanti, in der Voreinstellung Höhe 1.

### Die Weltkarte

Skizze und Verfahren: `docs/weltkarte/skizze.py`. Daneben liegt `karte.png`: der Kontinent, wie ihn der Generator für den Startwert `wanderlore` berechnet, gezeichnet mit `scripts/map.sh world`.

| | Zone 1 Startland | Zone 2 Wildnis | Zone 3 Ödland | Inseln |
| --- | --- | --- | --- | --- |
| Charakter | freundlich, Grundzutaten | abwechslungsreich | karg, gefährlich | Sonderzone, nur über Wasser |
| Äußerer Rand ab Start | 4.000 Blöcke | 7.500 | 11.500 | 14.000 bis 17.500 |
| Fußweg bis zum Rand | ca. 16 Minuten | ca. 31 | ca. 48 | – |
| Zellgröße | 700 | 700 | 700 | 800 |
| Biome | 3 | 5 | 4 | 3, dazu Vulkaninseln |
| Austeilen der Biome | reihum | nach Richtung | nach Richtung | nach Richtung |
| Ein Biom-Land ist etwa | 700 breit, wo gleiche Zellen aneinanderliegen mehr | 4.500 breit | 7.000 breit | Inselgruppen |

- **Eine Zelle gehört immer ganz zu einer Zone.** So zerschneidet keine Zonengrenze ein Biom.
- **Die Zellgröße 700 ist ein Versuch.** Mit 1.600 wirkten die Biome dem Autor im Prototyp sehr groß, mit 1.000 beim Wandern in Zone 1 immer noch; am 23.11.2026 hat er 700 gewählt. Die Skizze in `docs/weltkarte/` rechnet weiter mit 1.000, `karte.png` zeigt den Stand mit 700. In Zone 1 liegen öfter Zellen desselben Bioms nebeneinander und bilden dann ein größeres Gebiet. Die Inseln sind mit Zellen von 800 gebaut; ob das passt, und die Breite der Biom-Länder in Zone 2 und 3, beurteilt der Autor an Karte und Spiel.
- **Der Rand einer Zone schwingt.** Die Zone einer Zelle folgt aus dem Abstand ihrer Mitte zum Start; dieser Abstand wird mit einem weiten Rauschen um bis zu 22 % gestreckt oder gestaucht. Die Zahlen der Tabelle sind deshalb Mittelwerte.
- **Die Heimatrichtungen hängen vom Startwert der Welt ab.** In jeder Welt liegt ein Biom der Zonen 2 und 3 in einer anderen Himmelsrichtung. Eine Zelle weicht von der Heimatrichtung ihres Bioms meist um weniger als 20 Grad ab, einzelne mehr; das sind die Ausreißer.
- **Auf dem Meer ist die Zone 0, auf den Inseln die Zone 4.** Das Meer meldet sich als eigenes Biom `ocean`.
- **Die Inseln liegen auf einem eigenen, feineren Raster** in einem Ring von 14.000 bis 17.500 Blöcken um den Start, dessen Rand schwingt wie der der Zonen. Zwischen dem Kontinent und den nächsten Inseln liegen damit etwa 2.000 bis 3.000 Blöcke offenes Meer. Eine Zelle des Rings ist Insel, wo ein weites Rauschen hoch steht; so entstehen Inselgruppen mit offenem Meer dazwischen. Im Startwert `wanderlore` sind es gut 160 Inselzellen. Wie dicht die Inseln liegen, ist ein Regler; die Dichte hat der Autor am 23.11.2026 für passend befunden.
- **Vier Inselzellen sind Vulkaninseln,** in gleichen Abständen rund um den Ring verteilt, die erste an einer Stelle, die vom Startwert abhängt. Gebaut ist nur ihre Form: ein Kegel von knapp 100 Blöcken Höhe mit einem Krater. Das Besteigen soll schwierig sein: Auf einem Sockel, der 30 Blöcke ansteigt, steht ein glatter, steiler Kegel, der auf etwa 75 Blöcken Strecke weitere 65 gewinnt. Ein Rauschen macht ihn je nach Seite schmaler oder breiter; manche Flanken sind zu steil zum Hinauflaufen, andere lassen einen Weg. Stufen und Absätze hat der Kegel nicht; einen Aufbau in Stufen hat der Autor am 23.11.2026 verworfen. Schlot und Siegel kommen mit G5.
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
| Blossom Downs | 12 | flache Hügel von ±10 zwischen Flüssen. Ein Fluss ist etwa 28 breit und bis 3 tief und mäandert in weiten Schwüngen. Neben ihm liegt eine ebene Aue, einen Block über dem Wasser und je Seite etwa 15 breit; erst dahinter steigt das Land langsam zu den Hügeln an. In den Flüssen liegen Kiesbänke und kleine Inseln | Gras, am Ufer Sand, am Flussgrund und auf den Bänken Kies. Nur in den obersten Lagen der Hügel, mehr als 16 über dem Wasser, Flecken aus blankem Stein und einzelne kleine Felsen |
| Reed Meres | 1,6 | eben, das Land liegt 1 oder 2 über dem Wasser und nirgends höher. Viele kleine Mulden von 10 bis 40 Breite sinken unter den Wasserspiegel und werden Tümpel, etwa 3 tief. Zum Tümpel hin senkt sich das Land, sodass das Ufer höchstens einen Block über dem Wasser liegt | Sumpfgras mit ebenen Flecken aus grünem und gelbem Sumpfmoos, am Ufer und im Wasser Torf |
| Old Wood | 30 | lange Wellen von ±10, darauf enge Kuppen und Mulden von ±8 im Abstand von etwa 50. Dazu Waldseen über dem Meeresspiegel | Nadelstreu, auf den Hügelkuppen Waldgras mit Sprenkeln aus Nadelstreu, dazu Findlinge aus Stein, etwa ein Drittel der Blöcke bemoost |

Bis auf die Waldseen steht alles Wasser des Prototyps auf Meereshöhe, auch die Flüsse von Blossom Downs. Deshalb liegen sie alle gleich hoch, und die Hügel steigen von ihnen aus an. Zur Biomgrenze hin laufen sie aus, weil sich dort die Höhe mit der des Nachbarn mischt. Gewässer, die einen Hang hinabfließen oder Biome verbinden, gehören zu den Flüssen in G3.

Die Flüsse mäandern, weil ihr Rauschen an einer um bis zu 100 Blöcke verschobenen Stelle gelesen wird. Dabei schließt sich gelegentlich ein Bogen zu einem Ring um eine kleine Insel.

Die Waldseen von Old Wood entstehen aus einem eigenen Wasserspiegel des Bioms, 24 über dem Meer: Jede Mulde, die tiefer liegt, füllt sich bis dorthin. So liegen die Seen in Gruppen in den Niederungen, und die höheren Gegenden bleiben trocken. Das Ufer liegt von selbst einen Block über dem Wasser. Zur Biomgrenze hin fällt das Land zum Nachbarn ab; deshalb hält der Generator den äußersten Streifen des Bioms als natürlichen Rand über dem Wasserspiegel, und jenseits davon gibt es dieses Wasser nicht. Am Wasser gilt in allen drei Biomen: höchstens ein Block hinab.

Jedes Biom hat im Prototyp eine Deckschicht aus einem Block, dazu je einen für Ufer und Gewässergrund. Unter der Deckschicht liegen auf ebenem Boden drei Blöcke Füllung, etwa Erde, darunter Stein. An einem steilen Hang reicht die Füllung so tief, wie der Hang zur nächsten Säule abfällt, damit die Wand nicht aus Streifen von blankem Stein besteht. Nur an manchen Stellen schaut der Stein heraus, in unregelmäßigen Flecken von einigen Blöcken Breite. Rechteckige Flecken wirkten künstlich. Die Höhenformel eines Bioms kann Stellen markieren, die an der Wasserlinie einen anderen Block bekommen; so entstehen die Kiesbänke. Findlinge sind eigene Körper aus anderen Blöcken, und Flecken ersetzen die Deckschicht an verstreuten Stellen, ohne die Höhe zu ändern. Jedes Biom nennt, ob es Findlinge und Flecken hat, wie häufig und wie groß, und ab welcher Höhe über dem Wasser.

Gras gibt es in Old Wood nur auf den Hügelkuppen, als Kappen von meist 20 bis 80 Blöcken Breite. Es ist leicht fleckig: Etwa jeder zehnte Block bleibt Nadelstreu, und den Hang hinab dünnt das Gras aus. Sein Block ist Waldgras: das Gras von Minetest Game in einem dunkleren, kühleren Grün. Die Farbe entsteht erst im Spiel aus dessen Textur, eine fremde Datei ist dafür nicht übernommen. Lage und Sprenkel hat der Autor am 22.11.2026 festgelegt und den Farbton bestätigt.

Reed Meres hat die ersten eigenen Blöcke von Wanderlore: Sumpfgras, zwei Sumpfmoose und Torf, mit Texturen aus Extra Biomes. Die Farbe der Moose ist gegenüber der Vorlage dunkler und kräftiger, damit sich die Flecken vom Gras abheben. Der Torf ist ein fester Block. Das Wasser bleibt das von Minetest Game. Ein eigenes Sumpfwasser kommt frühestens mit dem Bewuchs.

### Übergänge

- **Zwischen Biomen derselben Zone** werden die Grundhöhen weich gemischt, und die Form blendet zur Grenze hin aus.
- **An Zonengrenzen liegt eine sichtbare Schwelle:** zwischen Zone 1 und 2 ein Fluss, zwischen Zone 2 und 3 ein Höhenzug. Beide folgen den Grenzen der Zellen und umschließen ihre Zone ganz.
- **Der Fluss** ist etwa 56 Blöcke breit und 3 bis 4 tief, auf Meereshöhe wie alles Wasser bisher. Zu beiden Seiten kommt das Land über etwa 36 Blöcke zu ihm herab. Man durchschwimmt ihn; eine Brücke oder Furt gibt es nicht. Breite und Tiefe sind Vorschläge von Claude.
- **Der Höhenzug** ist etwa 140 Blöcke breit und hebt das Land an der Grenze um bis zu 36 Blöcke. Entlang seiner Länge ist er mal höher, mal niedriger; an den niedrigsten Stellen, den Pässen, sind es nur etwa 7. Er trägt die Oberfläche der Biome, die er trennt. Auch diese Zahlen sind Vorschläge von Claude.
- **Zwischen Varianten desselben Bioms** gleiten die Regler der Formel ineinander.
- **Die Mischzone ist schmal**, 60 Blöcke je Seite. Mit 120 war der Übergang dem Autor zu breit; er hat ihn am 22.11.2026 halbiert. Das Mischen der Grundhöhen und das Ausblenden der Form sind seit G1 gebaut.
- **Oberfläche und Bewuchs** wechseln gesprenkelt über etwa 20 Blöcke; die Breite hängt an der Mischzone und hat sich mit ihr halbiert. Für die Oberfläche ist das seit G1 gebaut: Nahe der Grenze trägt eine Stelle mal die Oberfläche des einen, mal die des anderen Bioms, teils Block für Block, teils in kleinen Gruppen.
- **Die Grenzlinie ist unregelmäßig.** Eine zweite, feine Verschiebung von bis zu 24 Blöcken gibt ihr Buchten und Zungen.
- **Küste:** je Biom Strand oder Steilküste. Am Strand senkt sich das Land auf eine Stufe 1 bis 2 über dem Wasser, die auf knapp 40 Blöcken Breite flach ins Wasser ausläuft, etwa zur Hälfte trocken; sie ist aus Sand, über und unter Wasser. Dahinter sinkt der Grund zum Meeresboden. An der Steilküste hält das Land seine Höhe fast bis zur Grenze und fällt dann auf wenigen Blöcken ins tiefe Wasser. Wo ein Biom mit Strand und eines mit Steilküste am Meer zusammentreffen, gehen die beiden Formen ineinander über. Welcher Platzhalter welche Küste hat, steht in der Tabelle der Platzhalter; der Autor hat das am 23.11.2026 vorerst so angenommen. Die drei Biome von Zone 1 berühren das Meer nicht.

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

- **eigene Baumarten**, von denen einzelne auch im Nachbarbiom stehen dürfen; siehe „Bäume und Holz“
- **eine Feldfrucht**
- **eine Kochzutat**
- **eine Zutat für die Alchemie**

Dazu kommen gegebenenfalls sein Erz, seine Monster und sein Stronghold-Typ. Bei 15 Biomen sind das je 15 Feldfrüchte, Kochzutaten und Zutaten für die Alchemie, und zwei bis drei Baumarten je Biom.

### Bäume und Holz

Der Autor hat das am 23.11.2026 entschieden. Gebaut ist davon noch nichts.

Ein Baum besteht aus Form und Material. Die Form ist eine Bauanleitung und kostet keinen Block; eine Holzart kann viele Formen haben, jung, alt, riesig. Das Material kostet Blöcke, und viele neue Blöcke sind die Hauptgefahr. Deshalb ist es knapp gehalten:

- **Eine Holzart hat drei eigene Blöcke:** Stamm, Laub und Setzling.
- **Bretter gehören nicht der Holzart, sondern einer Holzkategorie.** Jede Holzart gehört zu genau einer Kategorie. Wer Stämme zu Brettern verarbeitet, bekommt die Bretter der Kategorie.
- **Alles aus Brettern hängt an der Kategorie,** nicht an der Holzart: Treppen, Platten, Zäune, Tore.
- **Eine Kategorie ist vorerst nur eine Farbe.** Sie ändert keine Werte.
- **Die Kategorien sind an die Zonen gebunden,** je zwei: Zone 1, Zone 2, Zone 3, Inseln und Unterwelt. Das sind zehn. Eine neue Kategorie ist damit selbst eine Entdeckung.
- **Die Bretter kommen zuerst aus Minetest Game.** Es bringt fünf mit, jeweils schon mit Treppen, Platten, Zäunen und Toren. Bretter aus anderen Quellen kommen ebenfalls in Betracht; für zehn Kategorien braucht es ohnehin mindestens fünf weitere. Welche Bretter zu welcher Kategorie werden und wie die Kategorien heißen, ist offen.
- **Alle Hölzer werden auf dieselbe Weise angemeldet,** mit denselben Gruppen, Klängen, Härten und Rezepten. So verhalten sich alle Bäume gleich: fällen, Laub zerfällt, Setzling.
- **Von fremden Mods kommen nur Texturen und Formen.** Eine fremde Bauanleitung wird auf die eigenen Blöcke umgeschrieben; die Blöcke des fremden Mods kommen nicht ins Spiel.

- **Kein Baum gleicht dem anderen.** Beim Setzen wird jede Form leicht abgewandelt: gedreht oder gespiegelt, der Stamm einen Block länger oder kürzer, am Rand der Krone einzelne Blätter weg oder dazu. Die Abweichungen werden berechnet, nicht als eigene Formen gezeichnet, und bleiben geringfügig. Der Katalog zeigt das Verfahren an der Birke.
- **Ein Baum fällt oberhalb des Schnitts.** Baut man am aufrechten Stamm eine ganze Schicht ab, verschwindet alles, was darüber zum Baum gehört, von unten nach oben und lässt seine Gegenstände fallen. Was unter dem Schnitt steht, bleibt als Stumpf. Wo man schneidet, ist frei; am Fuß lohnt es am meisten.
  - Ein Ast ist keine Schicht des Stamms. Baut man ihn ab, fällt nichts.
  - Jeder Stamm-Block gibt einen Stamm, jeder zweite Laub-Block ein Laub. Hängendes Laub zählt wie Laub.
  - Ein Laub-Block lässt mit 1 zu 20 einen Setzling fallen, wie in Minetest Game.
  - Die Gegenstände entstehen dort, wo der Block war, und fallen senkrecht nach unten.
  - Das gilt für alle Baumarten gleich und ist an einer Stelle festgelegt.
  - Zu lösen ist dabei, dass der Baum ein gewachsener ist und kein gebautes Haus aus Stämmen, und dass von zwei ineinanderstehenden Kronen nur der gefällte Baum verschwindet.

Beide Regeln hat der Autor am 24.11.2026 entschieden. Zum Vergleich: In Minetest Game lässt ein Laub-Block mit 1 zu 20 einen Setzling fallen, bei Büschen mit 1 zu 5, sonst sich selbst, und der Baum fällt nicht mit.

Die Rechnung dahinter, als Schätzung: 15 Holzarten kosten 45 Blöcke, 30 kosten 90. Mit eigenen Brettern und allem daraus je Holzart wären es bei 15 schon etwa 180.

Ob „Unterwelt“ die Zwischenschicht meint oder auch die Höhlen, ist noch zu klären. Offen ist auch, ob Laub in mehreren Farbtönen aus einem Block entstehen kann, über eine Farbpalette; das ist nicht geprüft.

**Gewählte Baumarten.** Die Nummern sind die des Katalogs.

| Baumart | Biom | Stamm | Laub | Formen | Kategorie |
| --- | --- | --- | --- | --- | --- |
| Birke | Blossom Downs | Stamm von `MT-T3`, die Birke aus More Trees | Laub von `NB-T22`, die Birke aus Natural Biomes | vier: klein nach `EB-T20` (3 × 7), mittel nach `NB-T22` (7 × 11), groß nach `NB-T21` (9 × 14), Elder (17 × 20) | Weichholz |
| Buche | Blossom Downs und Old Wood, in beiden selten | Stamm von `EB-T10`, die Buche aus Extra Biomes | Laub von `EB-T10` | vier: klein nach `BB-T5` (7 × 13), mittel nach `BB-T6` (7 × 16), groß als verkleinerte Elder-Form (13 × 20), Elder nach `BB-T32` mit längerem Stamm und Wurzeln (16 × 25) | Hartholz |

Die Birke hat einen vierten Block: hängendes Laub, dasselbe Laub in Strähnen geschnitten. Es sitzt dort, wo das Laub am Rand einer Krone frei herabhängt, in allen vier Formen. Das ist eine Ausnahme von den drei Blöcken je Holzart, die der Autor am 24.11.2026 für die Birke gewählt hat.

Die Elder-Form der Birke hat Claude gebaut, weil sich im Bestand keine fand: ein Stamm von zwei mal zwei Blöcken, der oben einfach wird, Äste mit je einer Krone und hängendes Laub am Rand der Kronen. Sie ist etwa anderthalbmal so groß wie die große Form; ein doppelt so großer erster Entwurf war dem Autor zu viel, eine schlanke Variante hat er nicht gewählt. Beschrieben sind die Formen in `mods/wl_catalog/selection.lua` des Katalogs.

Der Setzling der Birke ist `EB86`, der Birkensetzling aus Extra Biomes.

Die Buche hat der Autor am 24.11.2026 gewählt. Klein und mittel stammen aus Better Biomes und sind dort Espen; die Elder-Form, und mit ihr die große, ist dort eine Eiche. Alle tragen Stamm und Laub der Buche. Die Elder-Form hat gegenüber der Vorlage einen um fünf Blöcke längeren Stamm, damit sie die große Form überragt, und etwa zehn Wurzelblöcke am Fuß; der Autor hat sie am 24.11.2026 so angenommen. Die große Form ist diese Elder-Form, auf vier Fünftel verkleinert. Das hat der Autor vorgeschlagen, nachdem drei Versuche, die zuerst gewählte schmale Espe `BB-T7` zu verbreitern, nicht passten: eine Kugel, eine Glocke und eine Kugel mit Kerben. Ob ihm die verkleinerte Form passt, ist offen.

**Die Kategorien von Zone 1** sind Weichholz und Hartholz. Weichholz bekommt die Bretter `EB25`, die Birkenbretter aus Extra Biomes; das hat der Autor am 24.11.2026 gewählt. Hartholz bekommt `EB33`, die Eichenbretter aus Extra Biomes.

**Die Baumarten von Zone 1,** wie der Autor sie am 24.11.2026 skizziert hat. Ausgearbeitet sind davon bisher Birke und Buche.

| Biom | Baumart | Kategorie | Häufigkeit |
| --- | --- | --- | --- |
| Blossom Downs | Birke | Weichholz | – |
| Blossom Downs | Buche | Hartholz | selten |
| Old Wood | Eiche | Hartholz | häufig |
| Old Wood | Ahorn | Weichholz | mäßig |
| Old Wood | Buche | Hartholz | selten |
| Reed Meres | Weide | Weichholz | – |
| Reed Meres | Erle | Weichholz | – |

Die Buche steht in zwei Biomen. Ein Biom hat also nicht mehr nur eine einzige, ihm allein gehörende Holzart, sondern eine Mischung, in der einzelne Arten auch beim Nachbarn vorkommen. Die Erle hat der Autor als zweiten Sumpfbaum gewählt, auf Vorschlag von Claude. Sie ist Weichholz; Reed Meres hat damit kein Hartholz. Ausgearbeitet sind Birke und Buche; es fehlen Eiche, Ahorn, Weide und Erle.

Zum Auswählen dient der [Wanderlore-Katalog](https://github.com/peddn/wanderlore-catalog). Seine Welt der Pflanzen zeigt die Blöcke, Bäume und Bodenpflanzen der Quellen mit Nummern, die Bäume auch nach Art sortiert, und in einem eigenen Bereich die Auswahl: jede gewählte Form mit dem gewählten Stamm und Laub.

Welche Biome es gibt, entsteht mit der Zeit am Generator. Festgelegt sind die drei Biome von Zone 1, mit denen der Prototyp beginnt; die übrigen sind erste Skizzen. Alle Namen sind Arbeitsnamen.

**Platzhalter.** Damit die Weltkarte gebaut werden kann, bevor es die äußeren Biome gibt, stehen im Generator Platzhalter: fünf für Zone 2 (`Zone 2 A` bis `E`), vier für Zone 3 (`Zone 3 A` bis `D`) und drei für die Inseln (`Island A` bis `C`). Jeder hat eine einfache Landschaftsform und eine Oberfläche aus Blöcken von Minetest Game, an der man ihn erkennt. Sie sind Vorschläge von Claude ohne Anspruch und halten nur den Platz frei. Der Autor arbeitet die echten Biome danach einzeln aus, wie bei Zone 1; die Skizzen der folgenden Tabelle sind dabei der Ausgangspunkt. Das hat der Autor am 22.11.2026 entschieden.

| Platzhalter | Form | Oberfläche | Küste |
| --- | --- | --- | --- |
| Zone 2 A | hohe, runde Hügel | Gras | – |
| Zone 2 B | Terrassen in Stufen von 8 | Regenwaldboden | – |
| Zone 2 C | Dünen | Wüstensand | – |
| Zone 2 D | Hochland | Schnee auf Erde | – |
| Zone 2 E | Ebene mit tiefen, runden Senken | Kies | – |
| Zone 3 A | Hochfläche mit Schluchten | roter Wüstenstein | Steilküste |
| Zone 3 B | Nadeln auf einer Eisfläche | Eis | Strand |
| Zone 3 C | schroffes Gebirge | Dauerfrostboden mit Steinen | Steilküste |
| Zone 3 D | Tafelberge mit steilen Flanken | Wüstensandstein | Strand |
| Island A | niedrig und eben, mit Dünen | Sand | Strand |
| Island B | grüne Hügel | Regenwaldboden | Strand |
| Island C | felsige Tafel | heller Sandstein | Steilküste |
| Vulkaninsel | steiler Kegel mit Krater auf flachem Sockel | Obsidian | Strand |

| Arbeitsname | Zone | Landschaft | Besonderheit |
| --- | --- | --- | --- |
| Blossom Downs | 1 | flache, runde Hügel zwischen breiten, mäandernden Flüssen mit ebenen Auen | blühende Bäume, Riesenbäume als Wegmarken |
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

Das **Lorebook** zeigt, was gefunden ist und wie viel noch fehlt, ohne das Fehlende zu verraten. Es ist kein Gegenstand, sondern ein Reiter im Inventar. So kann man es weder ablegen noch verlieren. Der Reiter hängt in `sfinv`, dem Inventar von Minetest Game; das nutzt auch LEP. Das Lorebook ordnet die Biome nach Zone 1 bis 3, Inseln und Meer.

Wann ein Biom als betreten gilt, hat der Autor am 23.11.2026 entschieden:

- **Erst hinter dem Übergangsstreifen.** Im gesprenkelten Rand zwischen zwei Biomen, am Fluss und am Höhenzug zwischen den Zonen und am Strand gibt es noch keine Lore.
- **Das Meer ist ein Biom** und zählt wie die anderen, sobald man im offenen Wasser hinter dem Strand ist. Es gehört zu keiner Zone.
- **Die Vulkaninseln sind ein eigenes Biom.**
- **Die Platzhalter zählen vorerst mit** und heißen im Lorebook „Zone 2 A“ und so weiter, bis die echten Biome sie ersetzen.
- **Im Himmel oberhalb der Landschaft** betritt man kein Biom. Dort liegen bei LEP Lobby und Lernräume.

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
| `wl_lore` | Lore sammeln, Lorebook, Lore-Station, Freischalten von Rezepten | `wl_world`, `sfinv` |
| `wl_vitals` | Leben, Ausdauer, Wirkung von Nahrung | – |
| `wl_farming` | Feldfrüchte, Speisen, Herd, Essenz | `wl_world`, `farming` |
| `wl_alchemy` | Wildkräuter, Kessel, Tränke, Wurftränke | `wl_world`, `vessels` |
| `wl_combat` | Waffen, Rüstungen, Schmiede, Aufwertungen, Geschoss-System | 3D Armor |
| `wl_monsters` | Monster und Tiere | `wl_world`, Mobs Redo |
| `wl_strongholds` | Baukasten, Platzierung, Beute, Spawner, Dungeon-Bausteine | `wl_world` |

`wl_vitals` ist ein Vorschlag aus dieser Fassung und noch nicht bestätigt.

Nicht zum Modpack gehört der Hilfs-Mod `wl_dev` unter `devmods/`. Er dient nur der Entwicklung: Er setzt Tester auf die Oberfläche, springt mit `/wl_goto` in ein Biom oder an Fluss, Höhenzug und Küste, misst den Generator und stellt die Kamera für Screenshots. Die Skripte binden ihn nur in die Testwelten ein. Auch er fragt `wl_world`, wo etwas liegt.

`wl_world` beantwortet bisher sechs Fragen: welches Biom, welches Biom als betreten gilt, welche Zone (1 bis 3, auf den Inseln 4, auf dem Meer 0), wo ein sicherer Ort an der Oberfläche liegt, wo die nächste Zelle eines Bioms liegt und wo der nächste Waldsee liegt.

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

Später:

7. **Anzeige und Bedienung.** Leisten für Leben und Ausdauer, Magen, Fenster der Stationen.
