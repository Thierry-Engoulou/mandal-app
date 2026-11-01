-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 20 : Le son et la vidéo numériques
-- Module 3 : Infographie et multimédia — 7 leçons
--
-- Ce fichier remplit les trois séries d'un coup : la 1ère A, la 1ère C et la
-- 1ère D. Il n'a besoin de rien d'autre pour tourner. Si la matière, les
-- classes, les programmes ou le chapitre n'existent pas encore, il les crée
-- lui-même au passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $inf1$
DECLARE
  v_lettres text[] := ARRAY['A', 'C', 'D'];
  v_i int;
  v_nom text;
  v_lettre text;
  v_matiere_id uuid;
  v_classe_id uuid;
  v_etab_id uuid;
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_nb_etabs int;
  v_deja int;
BEGIN
  -- La matière Chimie : on ne la crée qu'une fois pour toutes.
  INSERT INTO public.matieres (nom) VALUES ('Informatique') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Informatique';

  -- L'établissement, on le retrouve à partir des classes déjà en base.
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Je ne sais pas à quel établissement rattacher ces classes : j''en trouve % dans la table des classes, et il m''en faudrait exactement un.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- On refait le même travail trois fois : pour la 1ère C, puis la D, puis la E.
  FOR v_i IN 1..3 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := '1ère ' || v_lettre;

    -- Le programme de Chimie de cette série existe-t-il déjà ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Informatique — ' || v_nom;

    -- Non : on le crée, et la classe avec si besoin.
    IF v_programme_id IS NULL THEN
      -- La classe a pu être écrite de plusieurs façons : 1ère A, 1ere A, Première A.
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE '1%re ' || v_lettre OR nom ILIKE 'Premi%re ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Première', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'La classe % n''existait pas : je viens de la créer.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Informatique — ' || v_nom,
              'Programme officiel d''Informatique, classe de Première ' || v_lettre ||
              ' (Cameroun) — 3 modules, 20 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme d''Informatique de la % : créé.', v_nom;
    END IF;

    -- Le chapitre lui-même.
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 20;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Le son et la vidéo numériques', 20, 'Module 3 : Infographie et multimédia')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 20 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 20 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le son numérique', 1, 'texte', '
Le son est une **onde continue**. Pour le mettre dans un ordinateur, il faut le
numériser — et cela se fait en deux temps.

### L''échantillonnage

**Échantillonner**, c''est **mesurer l''amplitude de l''onde à intervalles
réguliers**, très rapprochés. Chaque mesure s''appelle un **échantillon**.

La **fréquence d''échantillonnage** est le **nombre de mesures par seconde**. Elle
s''exprime en **hertz**.

Les valeurs usuelles : **8 000 Hz** pour la voix au téléphone, **44 100 Hz** pour
la qualité du disque compact, **48 000 Hz** pour la vidéo professionnelle.

Plus la fréquence est élevée, plus la copie numérique ressemble à l''original — et
plus le fichier est gros.

### La quantification

**Quantifier**, c''est décider **sur combien de bits** chaque échantillon est
codé. C''est la **résolution** du son, l''équivalent de la profondeur de couleur
pour une image.

**8 bits** donnent 256 niveaux d''amplitude : un son pauvre et bruité.
**16 bits** donnent 65 536 niveaux : c''est la qualité du disque compact.
**24 bits** sont réservés au studio.

### Le nombre de canaux

**Mono** : un seul canal. **Stéréo** : deux canaux, gauche et droite — et donc
un fichier **deux fois plus gros**.

### Le calcul du poids

$$\text{poids} = f_{\text{éch}} \times \frac{\text{bits}}{8} \times
n_{\text{canaux}} \times \text{durée}$$

La division par 8 convertit les bits en octets.

### Les formats

| Format | Compression | Son terrain |
| --- | --- | --- |
| **WAV** (`.wav`) | aucune | le son brut, de qualité, très lourd |
| **MP3** (`.mp3`) | avec perte | la **musique courante** ; environ dix fois plus léger |
| **WMA** (`.wma`) | avec perte | le format de Microsoft |
| **AAC** (`.aac`, `.m4a`) | avec perte | le successeur du MP3, meilleur à poids égal |
| **FLAC** (`.flac`) | **sans perte** | l''archivage de qualité |
| **MIDI** (`.mid`) | — | **ce n''est pas du son** |

Le **MIDI** mérite l''attention, car c''est un piège d''examen. Un fichier MIDI ne
contient **aucun son enregistré** : il contient des **instructions** — « note la,
sur un piano, pendant une demi-seconde ». C''est l''instrument de l''ordinateur qui
joue. D''où sa taille minuscule, et le fait que le même fichier sonne
différemment d''une machine à l''autre.

On peut faire le rapprochement avec le chapitre 18 : le MIDI est au son ce que
le **vectoriel** est à l''image. Il décrit au lieu d''enregistrer.

---

**Exercice corrigé**

*Calculer le poids d''une minute de son en qualité disque compact : 44 100 Hz,
16 bits, stéréo. Puis expliquer pourquoi le même morceau en MP3 pèse environ
1 Mo.*

**Correction.** Reprenons la formule terme à terme.

$$f_{\text{éch}} = 44\,100 \text{ échantillons par seconde}$$
$$\frac{16}{8} = 2 \text{ octets par échantillon}$$
$$n_{\text{canaux}} = 2 \quad (\text{stéréo})$$
$$\text{durée} = 60 \text{ s}$$

Le produit :

$$44\,100 \times 2 \times 2 \times 60 = 10\,584\,000 \text{ octets}$$

En mégaoctets :

$$\frac{10\,584\,000}{1\,048\,576} \approx 10{,}1 \text{ Mo}$$

Une minute de son non compressé pèse donc environ **10 Mo**, et un morceau de
quatre minutes environ 40 Mo. C''est bien le poids d''un fichier WAV.

*Pourquoi le MP3 pèse dix fois moins.* Parce que sa compression est **avec
perte** : elle supprime les informations que l''oreille humaine ne perçoit pas ou
presque — les sons trop aigus, et surtout les sons **masqués** par un son plus
fort émis au même moment. Ce qui reste suffit à l''oreille, mais l''original est
définitivement perdu.

Une minute de MP3 pèse donc environ 1 Mo, et un morceau de quatre minutes
environ 4 Mo. C''est ce rapport de dix qui a rendu la musique transportable.
', NULL, 30),
      (v_chapitre_id, 'Figure : échantillonner une onde sonore', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 270" width="540" height="270">
<rect width="540" height="270" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">De l&apos;onde sonore au fichier : échantillonner et quantifier</text>

<text x="30" y="52" font-size="11" font-weight="700" fill="#2563eb">Le son réel : une onde continue</text>
<path d="M 40 100 Q 70 62 100 100 Q 130 138 160 100 Q 190 62 220 100 Q 250 138 280 100 Q 310 62 340 100 Q 370 138 400 100 Q 430 62 460 100" fill="none" stroke="#2563eb" stroke-width="2.4"/>
<line x1="40" y1="100" x2="470" y2="100" stroke="#cbd5e1" stroke-width="1"/>

<text x="30" y="152" font-size="11" font-weight="700" fill="#b91c1c">Échantillonner : on mesure à intervalles réguliers</text>
<g fill="#b91c1c">
<circle cx="40" cy="200" r="3.4"/><circle cx="70" cy="178" r="3.4"/><circle cx="100" cy="200" r="3.4"/><circle cx="130" cy="222" r="3.4"/><circle cx="160" cy="200" r="3.4"/><circle cx="190" cy="178" r="3.4"/><circle cx="220" cy="200" r="3.4"/><circle cx="250" cy="222" r="3.4"/><circle cx="280" cy="200" r="3.4"/><circle cx="310" cy="178" r="3.4"/><circle cx="340" cy="200" r="3.4"/><circle cx="370" cy="222" r="3.4"/><circle cx="400" cy="200" r="3.4"/><circle cx="430" cy="178" r="3.4"/><circle cx="460" cy="200" r="3.4"/>
</g>
<g stroke="#fca5a5" stroke-width="1.4">
<line x1="40" y1="200" x2="70" y2="178"/><line x1="70" y1="178" x2="100" y2="200"/><line x1="100" y1="200" x2="130" y2="222"/><line x1="130" y1="222" x2="160" y2="200"/><line x1="160" y1="200" x2="190" y2="178"/><line x1="190" y1="178" x2="220" y2="200"/><line x1="220" y1="200" x2="250" y2="222"/><line x1="250" y1="222" x2="280" y2="200"/><line x1="280" y1="200" x2="310" y2="178"/><line x1="310" y1="178" x2="340" y2="200"/><line x1="340" y1="200" x2="370" y2="222"/><line x1="370" y1="222" x2="400" y2="200"/><line x1="400" y1="200" x2="430" y2="178"/><line x1="430" y1="178" x2="460" y2="200"/>
</g>
<line x1="40" y1="200" x2="470" y2="200" stroke="#cbd5e1" stroke-width="1"/>

<text x="30" y="250" font-size="10" fill="#64748b">Plus les points sont rapprochés — plus la fréquence d&apos;échantillonnage est élevée —</text>
<text x="30" y="264" font-size="10" fill="#64748b">plus la copie ressemble à l&apos;original, et plus le fichier est gros.</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : numériser un son', 3, 'interactif', '{
  "widget": "son-numerique",
  "consigne": "Une onde sonore s''affiche, et deux curseurs te laissent régler la fréquence d''échantillonnage et le nombre de bits. Les points de mesure se rapprochent ou s''écartent sous tes yeux, et la courbe reconstituée se superpose à l''originale : tu vois exactement ce que l''on perd en descendant à 8 000 Hz. Le poids du fichier est calculé en direct, avec le détail du calcul, et un bouton compare mono et stéréo."
}', NULL, 10),
      (v_chapitre_id, 'La vidéo numérique', 4, 'texte', '
### Ce qu''est une vidéo

Une vidéo est une **succession d''images fixes** affichées assez vite pour que
l''œil y voie du mouvement. Chaque image s''appelle une **trame**, ou *frame*.

### Les trois caractéristiques

**La définition de chaque image**, comme pour une photographie :
$640 \times 480$ pour la définition standard, $1\,280 \times 720$ pour le HD,
$1\,920 \times 1\,080$ pour le Full HD, $3\,840 \times 2\,160$ pour le 4K.

**La cadence**, ou nombre d''**images par seconde** — *fps*. Le cinéma tourne à
**24** images par seconde, la télévision à **25** ou **30**, les jeux vidéo à
**60** et plus.

En dessous de 15 images par seconde environ, l''œil cesse de voir un mouvement
fluide et perçoit des saccades.

**Le débit**, en bits par seconde, qui résume la quantité de données par seconde
de vidéo.

### Pourquoi la compression est indispensable

Calculons une seconde de Full HD non compressée :

$$1\,920 \times 1\,080 = 2\,073\,600 \text{ pixels par image}$$
$$2\,073\,600 \times 3 = 6\,220\,800 \text{ octets par image}$$
$$6\,220\,800 \times 25 \approx 155\,520\,000 \text{ octets par seconde}$$

Soit environ **148 Mo par seconde**, et **8,7 Go par minute**. Un film de deux
heures dépasserait **1 000 Go**.

C''est impossible à stocker et impossible à transmettre. **Toute vidéo est donc
compressée**, sans exception.

La compression vidéo exploite une idée simple : d''une image à la suivante,
**presque rien ne change**. On enregistre donc une image complète de temps en
temps, et entre elles, seulement les **différences**.

### Codec et conteneur : la distinction demandée

Le **codec** — contraction de **co**deur-**déc**odeur — est l''**algorithme** de
compression. Exemples : H.264, H.265, VP9, DivX, MPEG-4.

Le **conteneur** est le **fichier** qui emballe la vidéo compressée, la bande
son, et parfois les sous-titres. C''est lui que désigne l''extension : `.avi`,
`.mp4`, `.mkv`, `.mov`, `.flv`.

L''image à retenir : le conteneur est le **carton**, le codec est la **manière de
plier** ce qu''on met dedans.

Cela explique un phénomène que tout le monde a rencontré : un fichier `.avi` qui
ne s''ouvre pas sur une machine alors qu''un autre `.avi` s''ouvre. Le conteneur est
bien reconnu, mais le **codec** qu''il contient manque au lecteur. La solution est
d''installer un pack de codecs, ou un lecteur qui les embarque tous, comme VLC.

### Les formats de conteneurs

| Extension | Remarque |
| --- | --- |
| `.avi` | ancien format de Microsoft, très répandu |
| `.mp4` | le standard actuel, lisible à peu près partout |
| `.mkv` | Matroska, souple, accepte plusieurs pistes et sous-titres |
| `.mov` | le format d''Apple, QuickTime |
| `.flv` | ancien format du web, aujourd''hui abandonné |
| `.wmv` | le format de Windows Media |

---

**Exercice corrigé**

*Un élève vous dit que son fichier vidéo `.avi` ne s''ouvre pas, alors qu''un autre
fichier `.avi` s''ouvre très bien sur la même machine. Expliquer et proposer une
solution.*

**Correction.** Le problème ne vient pas du **conteneur** mais du **codec**.

L''extension `.avi` désigne seulement le conteneur, c''est-à-dire l''emballage. À
l''intérieur, la vidéo peut avoir été compressée par n''importe quel codec :
DivX, XviD, H.264, et bien d''autres.

Le lecteur de l''élève reconnaît donc bien le fichier `.avi` et l''ouvre, mais il
ne possède pas le **décodeur** correspondant au codec utilisé. D''où le symptôme
caractéristique : le son fonctionne et l''image reste noire, ou l''inverse.

Deux solutions.

**Installer un lecteur qui embarque ses propres codecs**, comme **VLC**. C''est la
solution la plus simple, et celle à conseiller : VLC lit pratiquement tout, et
n''exige rien du système.

**Ou installer un pack de codecs** sur le système, ce qui bénéficiera à tous les
lecteurs — mais au prix d''une installation plus lourde et parfois instable.

*On pourrait aussi reconvertir la vidéo dans un codec courant, mais ce serait
une recompression : la qualité baisserait inutilement.*
', NULL, 30),
      (v_chapitre_id, 'Simulation : les réglages d''une vidéo', 5, 'interactif', '{
  "widget": "video-numerique",
  "consigne": "Règle la définition, la cadence en images par seconde et le niveau de compression, et vois le poids par minute se recalculer — en commençant par le chiffre affolant de la vidéo non compressée. Un lecteur te montre la même séquence à 5, 15, 24 et 60 images par seconde, pour que tu sentes où l''œil cesse de voir des saccades. Un dernier volet sépare le conteneur du codec et reproduit la panne du son sans image."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Probatoire — infographie et multimédia (session 2017)', 6, 'texte', '
Voici la deuxième partie du Probatoire d''informatique, session 2017,
entièrement corrigée. Elle vaut **6 points** sur 20.

---

**Énoncé**

*1. Définir la résolution d''une image.*

*2. Quelle est la différence entre une image matricielle et une image
vectorielle ?*

*3. Donner le type de fichier correspondant à chacune des extensions suivantes :
`.mp3`, `.avi`, `.jpg`.*

*4. Citer deux logiciels de traitement d''images.*

*5. Pourquoi une image vectorielle peut-elle être agrandie sans perte de
qualité ?*

---

**Correction détaillée**

**1. La résolution d''une image** est le **nombre de pixels par unité de
mesure**. On l''exprime en **points par pouce** — ppp, ou *dpi* en anglais.

*Le piège.* Beaucoup de candidats répondent « le nombre de pixels de l''image ».
C''est la **définition**, pas la résolution. La définition dit combien il y a de
pixels en tout — $1\,920 \times 1\,080$ par exemple ; la résolution dit à quel
point ils sont serrés — 300 ppp par exemple. Les deux notions sont
indépendantes, et c''est exactement ce que la question vérifie.

**2. La différence.**

Une **image matricielle** est décrite comme une **grille de pixels**, chacun
portant sa couleur. Elle convient aux **photographies**, et elle **pixelise**
quand on l''agrandit. Ses formats : JPEG, PNG, GIF, BMP.

Une **image vectorielle** est décrite par des **formules mathématiques** —
points, droites, courbes, avec leurs coordonnées. Elle convient aux **logos** et
aux schémas, et elle reste **nette** à toutes les tailles. Ses formats : SVG, AI,
EPS.

**3. Les extensions.**

| Extension | Type de fichier |
| --- | --- |
| `.mp3` | un fichier **son**, compressé avec perte |
| `.avi` | un fichier **vidéo** — plus précisément un conteneur vidéo |
| `.jpg` | un fichier **image** matricielle, compressé avec perte |

*Pour gagner tous les points, précise la compression.* Dire « .mp3 : son » vaut
le point ; dire « .mp3 : fichier son compressé avec perte » montre que tu as
compris pourquoi il pèse dix fois moins qu''un WAV.

**4. Deux logiciels de traitement d''images** : **Adobe Photoshop** et **GIMP**,
ce dernier étant libre et gratuit.

*On peut aussi citer Paint, ou, pour le vectoriel, Illustrator, Inkscape et
CorelDRAW — mais si la question dit « traitement d''images » sans préciser, les
deux logiciels matriciels sont la réponse la plus sûre.*

**5. Pourquoi l''agrandissement est sans perte.**

Parce qu''une image vectorielle ne contient **pas de pixels** : elle contient la
**description mathématique** des formes. À chaque affichage ou impression,
l''ordinateur **recalcule** ces formules à la taille demandée, et redessine un
tracé net.

Une image matricielle, au contraire, ne dispose que des pixels enregistrés. En
l''agrandissant, le logiciel ne peut qu''**étirer** ces pixels ou en inventer par
interpolation : le contour devient un escalier. L''information manquante n''était
pas dans le fichier, et aucun logiciel ne peut la créer.

---

**Ce que ce sujet t''apprend sur l''épreuve**

Regarde les cinq questions : ce sont **cinq définitions**. Aucun calcul, aucun
raisonnement long.

C''est la caractéristique de la partie infographie du Probatoire : elle se prépare
en apprenant précisément le vocabulaire, et surtout en ne confondant pas les
couples qui se ressemblent — **définition et résolution**, **matricielle et
vectorielle**, **codec et conteneur**, **avec perte et sans perte**.

Chacun de ces quatre couples a fourni une question d''examen dans les dernières
années. Révise-les par paires, pas séparément.
', NULL, 32),
      (v_chapitre_id, 'Quiz du chapitre 20', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce que la fréquence d''échantillonnage d''un son ?",
      "choix": [
        "Le nombre de bits par échantillon",
        "Le nombre de mesures de l''onde par seconde, exprimé en hertz",
        "Le nombre de canaux",
        "La durée du son"
      ],
      "bonne": 1,
      "explication": "44 100 Hz pour la qualité du disque compact, 8 000 Hz pour la voix au téléphone. Plus elle est élevée, plus la copie est fidèle et plus le fichier est gros."
    },
    {
      "question": "Que contient un fichier MIDI ?",
      "choix": [
        "Du son enregistré et compressé",
        "Des instructions décrivant les notes à jouer, pas de son enregistré",
        "Une vidéo sans image",
        "Une image vectorielle"
      ],
      "bonne": 1,
      "explication": "C''est pour cela qu''il est minuscule et qu''il sonne différemment d''une machine à l''autre. Le MIDI est au son ce que le vectoriel est à l''image."
    },
    {
      "question": "Une minute de son en 44 100 Hz, 16 bits, stéréo pèse environ :",
      "choix": [
        "1 Mo",
        "10 Mo",
        "100 Mo",
        "1 Go"
      ],
      "bonne": 1,
      "explication": "44 100 × 2 octets × 2 canaux × 60 s = 10 584 000 octets, soit environ 10,1 Mo. En MP3, le même son pèse dix fois moins."
    },
    {
      "question": "Pourquoi toute vidéo est-elle nécessairement compressée ?",
      "choix": [
        "Pour protéger les droits d''auteur",
        "Parce qu''une seconde de Full HD non compressée pèse environ 148 Mo, soit plus de 1 000 Go pour un film",
        "Parce que les lecteurs ne lisent que des fichiers compressés",
        "Pour permettre les sous-titres"
      ],
      "bonne": 1,
      "explication": "La compression exploite le fait que d''une image à la suivante, presque rien ne change : on n''enregistre que les différences."
    },
    {
      "question": "Quelle est la différence entre un codec et un conteneur ?",
      "choix": [
        "Aucune",
        "Le codec est l''algorithme de compression ; le conteneur est le fichier qui emballe la vidéo, le son et les sous-titres",
        "Le codec concerne le son, le conteneur l''image",
        "Le conteneur compresse, le codec emballe"
      ],
      "bonne": 1,
      "explication": "Le conteneur est le carton — c''est lui que désigne l''extension .avi ou .mp4 — et le codec est la manière de plier ce qu''on met dedans."
    },
    {
      "question": "Un fichier .avi s''ouvre sans image mais avec le son. Quelle est la cause la plus probable ?",
      "choix": [
        "Le fichier est corrompu",
        "Le lecteur ne possède pas le décodeur correspondant au codec vidéo utilisé",
        "L''écran est mal branché",
        "Le fichier est en réalité un fichier son"
      ],
      "bonne": 1,
      "explication": "Le conteneur .avi est reconnu, mais pas le codec qu''il contient. La solution la plus simple est d''utiliser VLC, qui embarque ses propres codecs."
    },
    {
      "question": "Quelle est la définition exacte de la résolution d''une image ?",
      "choix": [
        "Le nombre total de pixels de l''image",
        "Le nombre de pixels par unité de mesure, en points par pouce",
        "Le nombre de couleurs de l''image",
        "La taille du fichier"
      ],
      "bonne": 1,
      "explication": "Le premier choix est la DÉFINITION, et c''est le piège que le Probatoire 2017 tendait précisément sur cette question."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 20, Le son et la vidéo numériques.', v_nom;
  END LOOP;
END $inf1$;
