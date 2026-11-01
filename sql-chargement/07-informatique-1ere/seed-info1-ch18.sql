-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 18 : L'image numérique : matricielle et vectorielle
-- Module 3 : Infographie et multimédia — 8 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 18;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'L''image numérique : matricielle et vectorielle', 18, 'Module 3 : Infographie et multimédia')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 18 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 18 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'La numérisation et l''image numérique', 1, 'texte', '
Dernier module. On quitte le code pour les images, le son et la vidéo.

### La numérisation

Le monde réel est **continu** : une couleur passe à une autre sans marche
d''escalier, un son varie sans interruption. Un ordinateur, lui, ne manipule que
des **nombres**.

La **numérisation** est l''opération qui transforme une information **analogique**
— continue — en information **numérique** — une suite de nombres.

C''est ce que fait un scanner avec une photo de papier, un appareil photo avec la
lumière, un microphone avec un son.

### Le pixel

Une image numérique matricielle est un **quadrillage de petits carrés** de
couleur unie. Chacun s''appelle un **pixel**, contraction de l''anglais *picture
element*.

Chaque pixel porte **une seule couleur**. Vue de loin, la mosaïque donne
l''illusion d''une image continue ; de très près, on voit les carrés.

### Définition et résolution : la distinction capitale

Ces deux mots se confondent dans la langue courante, et c''est une question
d''examen presque garantie.

La **définition** est le **nombre total de pixels** de l''image. On l''exprime par
ses deux dimensions, ou par leur produit.

Une image de $1\,920 \times 1\,080$ a pour définition 1 920 pixels de large sur
1 080 de haut, soit $2\,073\,600$ pixels — environ 2 mégapixels.

La **résolution** est le **nombre de pixels par unité de mesure**. On l''exprime
en **points par pouce**, ppp, ou *dpi* en anglais.

Autrement dit, la définition dit **combien** il y a de pixels, la résolution dit
à quel point ils sont **serrés**.

### Pourquoi la distinction compte

Une même image de 1 200 × 1 200 pixels peut être imprimée :

- à 300 ppp, et faire alors $1\,200 / 300 = 4$ pouces de côté, soit environ
10 cm. L''impression est fine ;
- à 72 ppp, et faire $1\,200 / 72 \approx 16{,}7$ pouces, soit 42 cm. L''image
est grande mais grossière.

**La définition n''a pas changé. La résolution, oui.** C''est elle qui décide de la
qualité d''impression.

Les valeurs usuelles : **72 ppp** suffisent pour un écran, **300 ppp** sont le
minimum pour une impression de qualité.

### La profondeur de couleur

C''est le **nombre de bits consacrés à chaque pixel**. Il décide du nombre de
couleurs possibles.

| Profondeur | Nombre de couleurs | Usage |
| --- | --- | --- |
| 1 bit | $2^1 = 2$ | noir et blanc pur |
| 8 bits | $2^8 = 256$ | les GIF, les images indexées |
| 24 bits | $2^{24} \approx 16{,}7$ millions | la photographie, dite « vraies couleurs » |

Le 24 bits se comprend bien : **8 bits pour le rouge, 8 pour le vert, 8 pour le
bleu**. C''est le mode **RVB** — RGB en anglais — celui des écrans, où les
couleurs s''additionnent à partir du noir.

L''imprimeur, lui, travaille en **CMJN** : cyan, magenta, jaune, noir. Les encres
se soustraient à partir du blanc du papier. C''est pour cela qu''une couleur vive
à l''écran paraît souvent plus terne à l''impression.

### Le calcul du poids

$$\text{poids en bits} = \text{largeur} \times \text{hauteur} \times
\text{profondeur}$$

Et comme un octet vaut 8 bits, on divise par 8 pour obtenir des octets.

---

**Exercice corrigé**

*Calculer le poids d''une image non compressée de 800 × 600 pixels en vraies
couleurs.*

**Correction.** « Vraies couleurs » signifie **24 bits par pixel**, soit 3
octets.

Nombre de pixels :

$$800 \times 600 = 480\,000 \text{ pixels}$$

Poids en octets :

$$480\,000 \times 3 = 1\,440\,000 \text{ octets}$$

Conversion en mégaoctets, en se rappelant qu''un mégaoctet vaut $1\,024 \times
1\,024 = 1\,048\,576$ octets :

$$\frac{1\,440\,000}{1\,048\,576} \approx 1{,}37 \text{ Mo}$$

L''image pèse donc environ **1,4 Mo** sans compression. Enregistrée en JPEG avec
une compression ordinaire, elle tomberait autour de 100 à 200 ko — d''où
l''intérêt de la compression, que nous voyons plus loin.
', NULL, 28),
      (v_chapitre_id, 'Simulation : définition, résolution et poids', 2, 'interactif', '{
  "widget": "pixels-definition",
  "consigne": "Une image s''affiche avec sa grille de pixels visible. Fais varier la définition et regarde les carrés grossir ou se resserrer jusqu''à disparaître. Un second volet te donne une image à imprimer : change la résolution en points par pouce et vois la taille en centimètres et la qualité évoluer en sens inverse, à définition constante. Le poids du fichier est calculé en direct à partir de la profondeur de couleur."
}', NULL, 10),
      (v_chapitre_id, 'Matricielle ou vectorielle', 3, 'texte', '
Il y a **deux façons complètement différentes** de représenter une image dans un
ordinateur. C''est la question la plus demandée de tout le module.

### L''image matricielle

Appelée aussi **bitmap** ou **image en mode point**, elle est décrite comme une
**grille de pixels**, chacun avec sa couleur.

Pour un cercle, l''ordinateur retient : « ce pixel est noir, celui-ci est blanc,
celui-là est noir… » — des milliers de fois.

### L''image vectorielle

Elle est décrite par des **formules mathématiques** : des points, des droites,
des courbes, avec leurs coordonnées, leurs épaisseurs et leurs couleurs.

Pour le même cercle, l''ordinateur retient : « un cercle de centre (100, 100), de
rayon 50, trait noir de 2 pixels ». Une seule ligne.

### La comparaison

| | Matricielle | Vectorielle |
| --- | --- | --- |
| description | une grille de pixels | des formules mathématiques |
| agrandissement | elle **pixelise** | elle reste **nette** |
| photographies | **oui**, c''est son terrain | non, impossible |
| logos, plans, schémas | possible mais déconseillé | **oui**, c''est son terrain |
| poids | élevé, proportionnel au nombre de pixels | faible, proportionnel au nombre de formes |
| formats | JPEG, PNG, GIF, BMP, TIFF | SVG, AI, EPS, CDR |
| logiciels | Photoshop, GIMP, Paint | Illustrator, Inkscape, CorelDRAW |

### La propriété qui résume tout

**Une image vectorielle s''agrandit indéfiniment sans perte de qualité.**

Et la raison est simple : à chaque affichage, l''ordinateur **recalcule** la
formule à la nouvelle taille. Il ne dilate pas une grille, il redessine.

L''image matricielle, elle, ne peut que grossir ses carrés : c''est la
**pixelisation**, ou crénelage.

### Comment choisir

La règle tient en une phrase : **une photographie est matricielle, un logo est
vectoriel**.

Une photographie contient des millions de nuances irrégulières qu''aucune formule
ne peut décrire. Un logo est fait de formes nettes, et il doit s''imprimer aussi
bien sur une carte de visite que sur une banderole de dix mètres.

C''est pourquoi un graphiste dessine toujours un logo en vectoriel : le même
fichier servira à toutes les tailles.

---

**Exercice corrigé**

*Un client vous demande d''agrandir son logo, qu''il vous envoie en fichier JPEG
de 200 × 200 pixels, pour en faire une banderole de 3 mètres. Quel problème
rencontrez-vous et quelle solution proposez-vous ?*

**Correction.** Le problème est que le JPEG est un format **matriciel**.

Le fichier ne contient que 200 × 200 = 40 000 pixels. Agrandi à 3 mètres, chaque
pixel d''origine deviendra un carré visible de plus d''un centimètre de côté : la
banderole sera un escalier de gros carrés. Aucun logiciel ne peut inventer les
pixels manquants — l''information n''est pas dans le fichier.

La solution est de **redessiner le logo en vectoriel**, avec un logiciel comme
Illustrator ou Inkscape, et de livrer un fichier SVG, AI ou EPS. Ce fichier
s''imprimera net à n''importe quelle taille, de la carte de visite à la banderole,
parce que les formes seront recalculées à chaque fois.

C''est aussi la réponse à donner au client pour l''avenir : **son logo officiel
doit être conservé en vectoriel**, et les JPEG ne doivent être que des
exportations pour l''écran.
', NULL, 28),
      (v_chapitre_id, 'Figure : matricielle contre vectorielle, à l''agrandissement', 4, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 300" width="540" height="300">
<rect width="540" height="300" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le même cercle, agrandi quatre fois</text>

<text x="136" y="48" text-anchor="middle" font-size="12" font-weight="700" fill="#b91c1c">MATRICIELLE</text>
<text x="136" y="64" text-anchor="middle" font-size="10" fill="#64748b">une grille de pixels</text>
<text x="404" y="48" text-anchor="middle" font-size="12" font-weight="700" fill="#15803d">VECTORIELLE</text>
<text x="404" y="64" text-anchor="middle" font-size="10" fill="#64748b">une formule : centre et rayon</text>

<circle cx="136" cy="112" r="28" fill="none" stroke="#334155" stroke-width="2"/>
<text x="136" y="158" text-anchor="middle" font-size="10" fill="#64748b">taille d&apos;origine</text>
<circle cx="404" cy="112" r="28" fill="none" stroke="#334155" stroke-width="2"/>
<text x="404" y="158" text-anchor="middle" font-size="10" fill="#64748b">taille d&apos;origine</text>

<g fill="#334155">
<rect x="104" y="186" width="16" height="16"/><rect x="120" y="178" width="16" height="16"/><rect x="136" y="178" width="16" height="16"/><rect x="152" y="186" width="16" height="16"/>
<rect x="96" y="202" width="16" height="16"/><rect x="168" y="202" width="16" height="16"/>
<rect x="96" y="218" width="16" height="16"/><rect x="168" y="218" width="16" height="16"/>
<rect x="104" y="234" width="16" height="16"/><rect x="120" y="242" width="16" height="16"/><rect x="136" y="242" width="16" height="16"/><rect x="152" y="234" width="16" height="16"/>
</g>
<text x="136" y="276" text-anchor="middle" font-size="11" font-weight="700" fill="#b91c1c">les pixels se voient</text>
<text x="136" y="290" text-anchor="middle" font-size="10" fill="#991b1b">le contour devient un escalier</text>

<circle cx="404" cy="214" r="42" fill="none" stroke="#334155" stroke-width="3"/>
<text x="404" y="276" text-anchor="middle" font-size="11" font-weight="700" fill="#15803d">le trait reste net</text>
<text x="404" y="290" text-anchor="middle" font-size="10" fill="#166534">la formule est recalculée</text>

<line x1="270" y1="44" x2="270" y2="290" stroke="#cbd5e1" stroke-width="1.4" stroke-dasharray="4 4"/>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : agrandir les deux sortes d''images', 5, 'interactif', '{
  "widget": "matricielle-vectorielle",
  "consigne": "Le même dessin t''est donné en deux versions, l''une matricielle et l''autre vectorielle, côte à côte. Un curseur de zoom va de 100 % à 1600 % et agit sur les deux en même temps : à gauche les pixels deviennent des carrés, à droite le trait reste net. Le poids des deux fichiers est affiché, et un bouton te laisse essayer une photographie en vectoriel, pour voir pourquoi c''est impossible."
}', NULL, 10),
      (v_chapitre_id, 'Les formats de fichiers et la compression', 6, 'texte', '
### La compression

**Compresser**, c''est réduire la taille d''un fichier. Il y a deux familles, et
la distinction est demandée.

La compression **sans perte** réduit la taille **sans rien jeter**. On retrouve
l''image d''origine exactement. C''est le cas du PNG et du GIF.

La compression **avec perte** jette de l''information que l''œil remarque peu, et
gagne ainsi beaucoup plus de place. On ne retrouve **jamais** l''original. C''est
le cas du JPEG.

Conséquence importante : **chaque réenregistrement d''un JPEG dégrade l''image un
peu plus**. Ouvrir, modifier et réenregistrer dix fois le même JPEG finit par
l''abîmer visiblement. On travaille donc dans un format sans perte, et on
n''exporte en JPEG qu''à la fin.

### Les formats matriciels

| Format | Compression | Transparence | Animation | Son terrain |
| --- | --- | --- | --- | --- |
| **JPEG** (`.jpg`) | avec perte | non | non | la **photographie** |
| **PNG** (`.png`) | sans perte | **oui** | non | les logos, les captures d''écran |
| **GIF** (`.gif`) | sans perte, 256 couleurs | oui | **oui** | les petites animations |
| **BMP** (`.bmp`) | aucune | non | non | aucun usage courant, trop lourd |
| **TIFF** (`.tif`) | sans perte | oui | non | l''impression professionnelle |
| **RAW** | aucune | — | non | le **négatif numérique** du photographe |

Le **RAW** mérite un mot : c''est le fichier **brut** du capteur de l''appareil
photo, sans aucun traitement. Il est très lourd, mais il contient toute
l''information captée, ce qui laisse une grande latitude de retouche. On le
compare au négatif de la photographie argentique.

### Les formats vectoriels

| Format | Ce qu''il est |
| --- | --- |
| **SVG** (`.svg`) | le format vectoriel du web, lisible par tous les navigateurs |
| **AI** (`.ai`) | le format d''Adobe Illustrator |
| **EPS** (`.eps`) | un format d''échange pour l''impression |
| **CDR** (`.cdr`) | le format de CorelDRAW |
| **PDF** (`.pdf`) | un format d''**échange** de documents, qui peut contenir du vectoriel et du matriciel |

Le **PDF** — *Portable Document Format* — n''est pas à proprement parler un format
d''image. C''est un format de **document** conçu pour s''afficher et s''imprimer de
manière identique partout, quelle que soit la machine. C''est pour cela qu''on
envoie un devoir ou un rapport en PDF plutôt qu''en Word.

### Reconnaître un fichier à son extension

C''est une question de Probatoire récurrente, posée sous forme de tableau à
compléter.

| Extension | Type de fichier |
| --- | --- |
| `.jpg`, `.png`, `.gif`, `.bmp` | **image** |
| `.mp3`, `.wav`, `.wma` | **son** |
| `.avi`, `.mp4`, `.mkv`, `.mov` | **vidéo** |
| `.doc`, `.docx`, `.pdf`, `.txt` | **document** |
| `.xls`, `.xlsx` | **classeur** |
| `.exe` | programme exécutable |
| `.html`, `.css` | page web et feuille de style |
| `.zip`, `.rar` | archive compressée |

---

**Exercice corrigé**

*Vous devez placer sur un site web le logo du lycée, qui comporte un fond
transparent, et la photographie de la cérémonie de rentrée. Quels formats
choisissez-vous pour chacun, et pourquoi ?*

**Correction.**

Pour le **logo** : le **PNG**.

Trois raisons. Il gère la **transparence**, ce que le JPEG ne sait pas faire :
avec un JPEG, le fond transparent deviendrait un rectangle blanc visible sur la
page. Sa compression est **sans perte**, donc les traits nets du logo restent
nets. Et un logo comporte peu de couleurs, donc le PNG reste léger malgré
l''absence de perte.

*Et si le logo existe en vectoriel, le **SVG** est encore meilleur : il pèse
moins et reste net sur tous les écrans, y compris les écrans à haute densité.*

Pour la **photographie** : le **JPEG**.

C''est son terrain. Une photographie contient des millions de nuances, et la
compression avec perte y est pratiquement invisible tout en divisant le poids
par dix ou vingt. En PNG, la même photographie pèserait plusieurs mégaoctets, et
la page mettrait longtemps à s''afficher — ce qui compte beaucoup sur une
connexion camerounaise.
', NULL, 28),
      (v_chapitre_id, 'Simulation : choisir le bon format', 7, 'interactif', '{
  "widget": "formats-image",
  "consigne": "Huit situations te sont proposées : un logo transparent, une photographie de paysage, une petite animation, un scan à imprimer en grand, une capture d''écran. Choisis le format pour chacune, et la simulation te montre le poids obtenu et le défaut visible du mauvais choix — le fond blanc du JPEG sous le logo, les 256 couleurs du GIF sur une photographie. Un bouton réenregistre un JPEG dix fois de suite, pour que tu voies la dégradation s''accumuler."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 18', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce que la numérisation ?",
      "choix": [
        "L''impression d''une image",
        "La transformation d''une information analogique continue en une suite de nombres",
        "La compression d''un fichier",
        "L''agrandissement d''une image"
      ],
      "bonne": 1,
      "explication": "C''est ce que fait un scanner avec une photo de papier, un appareil photo avec la lumière, un microphone avec un son."
    },
    {
      "question": "Quelle est la différence entre définition et résolution ?",
      "choix": [
        "Aucune",
        "La définition est le nombre total de pixels de l''image ; la résolution est le nombre de pixels par unité de mesure, en ppp",
        "La définition concerne l''écran, la résolution le papier",
        "La résolution est le nombre de couleurs"
      ],
      "bonne": 1,
      "explication": "La définition dit COMBIEN il y a de pixels, la résolution dit à quel point ils sont SERRÉS. C''est une question d''examen presque garantie."
    },
    {
      "question": "Quelle résolution minimale faut-il pour une impression de qualité ?",
      "choix": [
        "72 ppp",
        "150 ppp",
        "300 ppp",
        "1000 ppp"
      ],
      "bonne": 2,
      "explication": "72 ppp suffisent pour un écran, mais il faut 300 ppp au minimum pour imprimer sans que les pixels se voient."
    },
    {
      "question": "Combien de couleurs permet une profondeur de 24 bits ?",
      "choix": [
        "256",
        "24",
        "environ 16,7 millions",
        "65 536"
      ],
      "bonne": 2,
      "explication": "2 puissance 24. On parle de vraies couleurs : 8 bits pour le rouge, 8 pour le vert, 8 pour le bleu, c''est le mode RVB des écrans."
    },
    {
      "question": "Pourquoi une image vectorielle s''agrandit-elle sans perte de qualité ?",
      "choix": [
        "Parce qu''elle contient plus de pixels",
        "Parce qu''elle est décrite par des formules mathématiques que l''ordinateur recalcule à chaque taille",
        "Parce qu''elle est compressée sans perte",
        "Parce qu''elle utilise moins de couleurs"
      ],
      "bonne": 1,
      "explication": "Il ne dilate pas une grille, il redessine. L''image matricielle, elle, ne peut que grossir ses carrés : c''est la pixelisation."
    },
    {
      "question": "Pour un logo avec fond transparent sur un site web, quel format matriciel choisir ?",
      "choix": [
        "JPEG",
        "PNG",
        "BMP",
        "RAW"
      ],
      "bonne": 1,
      "explication": "Le PNG gère la transparence et compresse sans perte. En JPEG, le fond transparent deviendrait un rectangle blanc visible sur la page."
    },
    {
      "question": "Pourquoi ne faut-il pas réenregistrer plusieurs fois un même fichier JPEG ?",
      "choix": [
        "Parce qu''il grossit à chaque fois",
        "Parce que sa compression est avec perte : chaque enregistrement jette un peu plus d''information",
        "Parce qu''il perd sa transparence",
        "Parce qu''il change d''extension"
      ],
      "bonne": 1,
      "explication": "On travaille dans un format sans perte et on n''exporte en JPEG qu''à la fin. Dix réenregistrements abîment visiblement l''image."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 18, L''image numérique : matricielle et vectorielle.', v_nom;
  END LOOP;
END $inf1$;
