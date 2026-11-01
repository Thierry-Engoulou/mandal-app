-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 5 : Manipulation d'une feuille de calculs
-- Module 1 : Systèmes informatiques — 8 leçons
--
-- Ce fichier remplit les deux séries d'un coup : la Terminale C et la
-- Terminale D. Il n'a besoin de rien d'autre pour tourner. Si la matière, les
-- classes, les programmes ou le chapitre n'existent pas encore, il les crée
-- lui-même au passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $inf7$
DECLARE
  v_lettres text[] := ARRAY['C', 'D'];
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
  FOR v_i IN 1..2 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := 'Terminale ' || v_lettre;

    -- Le programme de Chimie de cette série existe-t-il déjà ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Informatique — ' || v_nom;

    -- Non : on le crée, et la classe avec si besoin.
    IF v_programme_id IS NULL THEN
      -- La classe a pu être écrite de plusieurs façons : Terminale C, Tle C, TC.
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE 'T%le ' || v_lettre OR nom ILIKE 'Terminale ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Terminale', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'La classe % n''existait pas : je viens de la créer.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Informatique — ' || v_nom,
              'Programme officiel d''Informatique, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 3 modules, 25 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme d''Informatique de la % : créé.', v_nom;
    END IF;

    -- Le chapitre lui-même.
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 5;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Manipulation d''une feuille de calculs', 5, 'Module 1 : Systèmes informatiques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 5 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 5 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le classeur, la feuille et la cellule', 1, 'texte', '
Le tableur est l''outil le plus utilisé du programme, et celui qui revient à
chaque session du Baccalauréat dans la première partie. Commençons par le
vocabulaire, qui est noté pour lui-même.

### Les quatre mots à connaître

Un **tableur** est un **programme capable de manipuler des feuilles de calcul**.

Une **feuille de calcul** est un **ensemble de cellules organisées en tableau**,
repérable par un **onglet** portant son nom.

Une **cellule** est un emplacement repéré par le **croisement d''une ligne**,
numérotée, **et d''une colonne**, désignée par une lettre.

Un **classeur** est un **fichier contenant une ou plusieurs feuilles de
calcul**.

Retiens la hiérarchie : le classeur est le fichier, la feuille est un onglet
dedans, la cellule est une case de la feuille.

### Nommer une cellule

Le nom s''écrit **la lettre d''abord, le numéro ensuite** : `B2`, `D15`, `AA3`.
L''inverse — `2B` — n''existe pas.

La **cellule active** est celle qui est entourée d''un cadre épais : c''est là que
ce que tu tapes va s''inscrire. Le Baccalauréat 2023 demandait précisément de
l''identifier sur une copie d''écran.

Une **plage** est un rectangle de cellules, noté par ses deux coins opposés
séparés par deux points : `B2:D5` désigne toutes les cellules du rectangle allant
de B2 à D5.

### Quelques exemples de tableurs

Le programme demande d''en citer quelques-uns :

**Microsoft Excel**, le plus répandu ; **Sun StarOffice Calc** et
**OpenCalc** ; **IBM/Lotus 1-2-3** ; **Corel Quattro Pro** ; **KSpread**.

On y ajoute aujourd''hui **LibreOffice Calc**, gratuit, et **Google Sheets**, en
ligne.

### Ce qu''ils ont tous en commun

Trois caractéristiques, que le cours camerounais énumère :

les **calculs répétitifs** ou les formules élaborées ;
les **données ordonnées en lignes et en colonnes** ;
la **génération automatique de graphiques**.

---

**Exercice corrigé**

*Sur une copie d''écran de tableur, on voit un cadre épais autour de la case
située au croisement de la colonne D et de la ligne 8.*
*1. Quel type de logiciel est utilisé ? 2. Quelle est la cellule active ?
3. Comment nomme-t-on le rectangle allant de B3 à D7 ?*

**Correction.**

1. Un **tableur**. On accepte le nom d''un logiciel précis — Microsoft Excel,
LibreOffice Calc — mais la question porte sur le **type**, donc « tableur » est
la réponse attendue.

2. La cellule active est **D8** : la lettre de la colonne d''abord, le numéro de
la ligne ensuite.

3. C''est une **plage**, et elle se note **B3:D7**.

*Les questions 1 et 2 sont tombées au Baccalauréat 2023, pour 0,25 point
chacune. Ce sont les points les plus faciles de toute l''épreuve.*
', NULL, 24),
      (v_chapitre_id, 'Figure : le classeur, ses feuilles et une cellule', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 270" width="560" height="270">
<rect width="560" height="270" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Un classeur, ses feuilles, et une cellule</text>

<rect x="20" y="36" width="520" height="196" rx="8" fill="#f8fafc" stroke="#94a3b8" stroke-width="1.6"/>
<text x="34" y="54" font-size="10" font-weight="700" fill="#64748b">LE CLASSEUR — un seul fichier : notes.xlsx</text>

<rect x="34" y="62" width="88" height="20" rx="3" fill="#15803d"/>
<text x="78" y="76" text-anchor="middle" font-size="9" font-weight="700" fill="#ffffff">Trimestre 1</text>
<rect x="126" y="62" width="88" height="20" rx="3" fill="#cbd5e1"/>
<text x="170" y="76" text-anchor="middle" font-size="9" fill="#334155">Trimestre 2</text>
<rect x="218" y="62" width="88" height="20" rx="3" fill="#cbd5e1"/>
<text x="262" y="76" text-anchor="middle" font-size="9" fill="#334155">Trimestre 3</text>
<text x="320" y="76" font-size="9" fill="#64748b">← les onglets sont les feuilles de calcul</text>

<rect x="34" y="92" width="492" height="128" fill="#ffffff" stroke="#cbd5e1" stroke-width="1"/>
<rect x="34" y="92" width="44" height="18" fill="#e2e8f0" stroke="#cbd5e1"/>
<rect x="78" y="92" width="112" height="18" fill="#e2e8f0" stroke="#cbd5e1"/>
<rect x="190" y="92" width="112" height="18" fill="#e2e8f0" stroke="#cbd5e1"/>
<rect x="302" y="92" width="112" height="18" fill="#e2e8f0" stroke="#cbd5e1"/>
<rect x="414" y="92" width="112" height="18" fill="#e2e8f0" stroke="#cbd5e1"/>
<text x="56" y="105" text-anchor="middle" font-size="9" font-weight="700" fill="#334155"> </text>
<text x="134" y="105" text-anchor="middle" font-size="9" font-weight="700" fill="#334155">A</text>
<text x="246" y="105" text-anchor="middle" font-size="9" font-weight="700" fill="#334155">B</text>
<text x="358" y="105" text-anchor="middle" font-size="9" font-weight="700" fill="#334155">C</text>
<text x="470" y="105" text-anchor="middle" font-size="9" font-weight="700" fill="#334155">D</text>

<rect x="34" y="110" width="44" height="26" fill="#e2e8f0" stroke="#cbd5e1"/>
<text x="56" y="127" text-anchor="middle" font-size="9" font-weight="700" fill="#334155">1</text>
<rect x="34" y="136" width="44" height="26" fill="#e2e8f0" stroke="#cbd5e1"/>
<text x="56" y="153" text-anchor="middle" font-size="9" font-weight="700" fill="#334155">2</text>
<rect x="34" y="162" width="44" height="26" fill="#e2e8f0" stroke="#cbd5e1"/>
<text x="56" y="179" text-anchor="middle" font-size="9" font-weight="700" fill="#334155">3</text>
<rect x="34" y="188" width="44" height="26" fill="#e2e8f0" stroke="#cbd5e1"/>
<text x="56" y="205" text-anchor="middle" font-size="9" font-weight="700" fill="#334155">4</text>

<g stroke="#e2e8f0" stroke-width="1">
<line x1="78" y1="136" x2="526" y2="136"/><line x1="78" y1="162" x2="526" y2="162"/><line x1="78" y1="188" x2="526" y2="188"/>
<line x1="190" y1="110" x2="190" y2="214"/><line x1="302" y1="110" x2="302" y2="214"/><line x1="414" y1="110" x2="414" y2="214"/>
</g>

<rect x="190" y="136" width="112" height="26" fill="#dbeafe" stroke="#2563eb" stroke-width="2.4"/>
<text x="246" y="153" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">B2</text>

<text x="134" y="127" text-anchor="middle" font-size="9" fill="#334155">Élève</text>
<text x="246" y="127" text-anchor="middle" font-size="9" fill="#334155">Devoir</text>
<text x="358" y="127" text-anchor="middle" font-size="9" fill="#334155">Composition</text>
<text x="470" y="127" text-anchor="middle" font-size="9" fill="#334155">Moyenne</text>
<text x="134" y="153" text-anchor="middle" font-size="9" fill="#334155">Mbida</text>
<text x="358" y="153" text-anchor="middle" font-size="9" fill="#334155">14</text>
<text x="470" y="153" text-anchor="middle" font-size="9" fill="#334155">13</text>

<text x="280" y="248" text-anchor="middle" font-size="10" fill="#64748b">La cellule active est B2 : croisement de la colonne B et de la ligne 2.</text>
<text x="280" y="263" text-anchor="middle" font-size="10" fill="#64748b">Son nom s&apos;écrit toujours la lettre d&apos;abord, le numéro ensuite.</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : se repérer dans un classeur', 3, 'interactif', '{
  "widget": "classeur-feuille",
  "consigne": "Une feuille de calcul s''affiche avec ses lettres de colonnes et ses numéros de lignes. La simulation te demande de cliquer une cellule précise, puis de nommer celle qu''elle a sélectionnée, puis de désigner une plage par ses deux coins. Les onglets du bas sont cliquables : tu vois le classeur contenir plusieurs feuilles, et la cellule B2 de chacune porter une valeur différente."
}', NULL, 10),
      (v_chapitre_id, 'Mettre en forme une feuille de calculs', 4, 'texte', '
Le programme énumère quatre mises en forme précises : **bordures, fusion de
cellules, orientation de texte, retour automatique à la ligne**. Ce sont celles
qu''on attend en pratique comme en examen.

### Les bordures

Par défaut, le quadrillage que tu vois à l''écran **ne s''imprime pas** : ce sont
des repères, pas des traits. Pour qu''un tableau ait un cadre sur le papier, il
faut lui poser des **bordures**.

Onglet **Accueil**, groupe **Police**, bouton **Bordures**. On choisit le style
du trait, son épaisseur, sa couleur, et les côtés concernés.

C''est l''erreur de débutant classique : un tableau magnifique à l''écran, et une
feuille blanche à l''impression.

### La fusion de cellules

**Fusionner**, c''est réunir plusieurs cellules voisines en une seule. On s''en
sert pour un **titre qui s''étend sur toute la largeur** du tableau.

Onglet **Accueil**, bouton **Fusionner et centrer**.

Attention : la cellule fusionnée ne garde que le contenu de la **première**
cellule, en haut à gauche. Le reste est perdu, et le tableur prévient.

Autre conséquence : une colonne qui contient des cellules fusionnées se trie et
se filtre mal. On fusionne les titres, pas les données.

### L''orientation du texte

On peut **incliner le texte** d''une cellule, ou l''écrire à la verticale. C''est
très utile pour des en-têtes de colonnes étroites — « Mathématiques »,
« Physique », « Sciences de la vie » au-dessus de colonnes de notes.

Onglet **Accueil**, groupe **Alignement**, bouton **Orientation**.

### Le retour automatique à la ligne

Un texte trop long déborde sur la cellule voisine, ou se fait couper si celle-ci
est occupée. Le **retour automatique à la ligne** le fait passer **à la ligne
dans la même cellule**, en augmentant la hauteur de la ligne.

Onglet **Accueil**, groupe **Alignement**, bouton **Renvoyer à la ligne
automatiquement**.

Ne le confonds pas avec l''élargissement de la colonne : le premier garde la
colonne étroite, le second l''élargit.

### Les autres mises en forme utiles

Le **format de nombre** — monétaire pour afficher « 250 000 FCFA », pourcentage,
date, nombre de décimales. C''est un **affichage** : la valeur stockée ne change
pas, et les calculs se font sur la valeur, pas sur ce qui est affiché.

L''**alignement** horizontal et vertical, la **couleur de fond**, le **gras** et
les **styles**.

---

**Exercice corrigé**

*Vous construisez un bulletin de notes. Le titre « LYCÉE DE NGOA-EKELLÉ —
BULLETIN DU PREMIER TRIMESTRE » doit s''étendre sur les cinq colonnes du tableau,
les en-têtes de colonnes doivent tenir dans des colonnes étroites, et le tableau
doit apparaître encadré à l''impression. Quelles mises en forme utilisez-vous ?*

**Correction.**

Pour le **titre sur cinq colonnes** : sélectionner les cinq cellules de la
première ligne, puis **Fusionner et centrer**.

Pour les **en-têtes dans des colonnes étroites** : deux solutions, et toutes
deux sont acceptées. L''**orientation du texte**, en inclinant ou en passant à la
verticale ; ou le **retour automatique à la ligne**, qui garde la colonne étroite
en répartissant le texte sur plusieurs lignes.

Pour le **cadre à l''impression** : poser des **bordures** sur le tableau. Le
quadrillage visible à l''écran ne s''imprime pas, et c''est précisément le piège de
la question.
', NULL, 26),
      (v_chapitre_id, 'Simulation : mettre en forme un tableau', 5, 'interactif', '{
  "widget": "mise-en-forme-cellule",
  "consigne": "Un bulletin de notes brut t''est donné, sans aucune mise en forme. Les quatre outils du programme sont à ta disposition : bordures, fusion, orientation du texte, retour automatique à la ligne. Un bouton « Aperçu avant impression » te montre à tout moment ce qui sortira réellement sur le papier — et tu verras que sans bordures, le tableau y est invisible."
}', NULL, 10),
      (v_chapitre_id, 'Protéger, délimiter et imprimer', 6, 'texte', '
Trois actions du programme, qu''on fait rarement par plaisir et toujours par
nécessité.

### Protéger une feuille de calculs

**Pourquoi.** Un bulletin circule entre plusieurs mains. On veut que les
professeurs saisissent les notes, et que personne n''écrase les formules de
moyenne.

**Comment.** En deux temps, et c''est l''ordre qui compte :

1. **Déverrouiller d''abord** les cellules qu''on veut laisser modifiables.
Sélectionner ces cellules, puis **Format de cellule**, onglet **Protection**,
décocher **Verrouillée**. Par défaut, toutes les cellules sont verrouillées.

2. **Protéger ensuite la feuille.** Onglet **Révision**, bouton **Protéger la
feuille**, et un mot de passe si l''on veut.

Tant que la feuille n''est pas protégée, le verrouillage des cellules ne fait
rien du tout. C''est le point que tout le monde rate la première fois.

### Définir une zone d''impression

**Le problème.** Une feuille contient souvent plus que ce qu''on veut imprimer :
des calculs intermédiaires, une table de références, des notes de travail.

**La solution.** Sélectionner la plage à imprimer, puis onglet **Mise en page**,
bouton **Zone d''impression**, **Définir**.

Dès lors, seule cette zone sort de l''imprimante, quel que soit le reste de la
feuille. **Annuler** la zone rétablit l''impression complète.

### La mise en page

Onglet **Mise en page**. Les réglages du programme :

| Réglage | Ce qu''il fait |
| --- | --- |
| **Marges** | Normales, Larges, Étroites, ou personnalisées, avec centrage sur la page |
| **Orientation** | **Portrait** (en hauteur) ou **Paysage** (en largeur) |
| **Taille** | le format de papier : A4, A3, Letter |
| **Ordre des pages** | « Vers le bas, puis à droite » ou « À droite, puis vers le bas » |
| **Mise à l''échelle** | ajuster à un nombre de pages en largeur et en hauteur |

L''**en-tête et le pied de page** s''ajoutent par **Insertion**, groupe **Texte**,
bouton **En-tête/Pied de page**.

### Imprimer

Toujours passer par l''**aperçu avant impression** — `Ctrl` + `P` l''affiche
directement. On y voit la pagination réelle, et c''est là qu''on découvre qu''un
tableau de six colonnes déborde sur une deuxième page.

Les deux réparations, dans l''ordre : passer en **Paysage**, puis utiliser la
**mise à l''échelle** pour forcer « 1 page en largeur ».

---

**Exercice corrigé**

*Un bulletin de notes de douze colonnes déborde sur une seconde page à
l''impression, et on ne veut imprimer que le tableau, pas les calculs
intermédiaires situés plus bas. Que faites-vous, et dans quel ordre ?*

**Correction.**

**1. Définir la zone d''impression.** Sélectionner uniquement la plage du tableau,
puis Mise en page, Zone d''impression, Définir. Les calculs intermédiaires ne
sortiront plus.

**2. Passer en orientation Paysage.** Douze colonnes tiennent mal en hauteur sur
une A4.

**3. Si cela déborde encore, utiliser la mise à l''échelle** pour ajuster à
1 page en largeur.

**4. Vérifier dans l''aperçu avant impression** avant de lancer l''impression. On
ne découvre jamais la pagination sur le papier.
', NULL, 25),
      (v_chapitre_id, 'Simulation : préparer une feuille pour l''impression', 7, 'interactif', '{
  "widget": "zone-impression",
  "consigne": "Une feuille contient un bulletin et, plus bas, des calculs intermédiaires qui ne doivent pas sortir. Définis la zone d''impression, choisis l''orientation, joue sur les marges et la mise à l''échelle, et l''aperçu se recompose en direct en te montrant les pages réelles. Un second volet te fait protéger la feuille : tu déverrouilles les cellules de saisie, tu protèges, puis tu essaies d''écraser une formule — et tu vois le refus."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 5', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qu''un classeur ?",
      "choix": [
        "Une cellule contenant une formule",
        "Un fichier contenant une ou plusieurs feuilles de calcul",
        "Un ensemble de cellules en tableau",
        "Le logiciel lui-même"
      ],
      "bonne": 1,
      "explication": "Le classeur est le fichier, la feuille est un onglet dedans, la cellule est une case de la feuille. Le tableur, lui, est le programme."
    },
    {
      "question": "Comment se nomme la cellule au croisement de la colonne D et de la ligne 8 ?",
      "choix": [
        "8D",
        "D8",
        "D-8",
        "L8C4"
      ],
      "bonne": 1,
      "explication": "Toujours la lettre de la colonne d''abord, le numéro de la ligne ensuite. Cette question est tombée au Baccalauréat 2023."
    },
    {
      "question": "Citer un exemple de tableur.",
      "choix": [
        "Microsoft Word",
        "Microsoft Excel",
        "Microsoft Access",
        "Adobe Photoshop"
      ],
      "bonne": 1,
      "explication": "On accepte aussi LibreOffice Calc, OpenCalc, Lotus 1-2-3, Quattro Pro ou KSpread. Word est un traitement de texte et Access un SGBD."
    },
    {
      "question": "Pourquoi un tableau peut-il apparaître sans cadre à l''impression ?",
      "choix": [
        "L''imprimante est mal réglée",
        "Le quadrillage visible à l''écran ne s''imprime pas : il faut poser des bordures",
        "La feuille est protégée",
        "La zone d''impression est mal définie"
      ],
      "bonne": 1,
      "explication": "Le quadrillage n''est qu''un repère à l''écran. C''est l''erreur de débutant la plus classique du tableur."
    },
    {
      "question": "Que se passe-t-il quand on fusionne plusieurs cellules remplies ?",
      "choix": [
        "Les contenus sont additionnés",
        "Seul le contenu de la première cellule, en haut à gauche, est conservé",
        "Les contenus sont mis bout à bout",
        "Le tableur refuse l''opération"
      ],
      "bonne": 1,
      "explication": "Le reste est perdu, et le tableur prévient avant. C''est pourquoi on fusionne les titres, pas les données."
    },
    {
      "question": "Dans quel ordre protège-t-on une feuille de calculs ?",
      "choix": [
        "Protéger la feuille, puis déverrouiller les cellules de saisie",
        "Déverrouiller d''abord les cellules de saisie, puis protéger la feuille",
        "Il suffit de protéger la feuille",
        "Il suffit de verrouiller les cellules"
      ],
      "bonne": 1,
      "explication": "Toutes les cellules sont verrouillées par défaut, et le verrouillage ne fait rien tant que la feuille n''est pas protégée. C''est l''ordre qui compte."
    },
    {
      "question": "À quoi sert la zone d''impression ?",
      "choix": [
        "À protéger une partie de la feuille",
        "À n''imprimer qu''une plage choisie, le reste de la feuille étant ignoré",
        "À régler les marges",
        "À fusionner les cellules du titre"
      ],
      "bonne": 1,
      "explication": "Pratique quand la feuille contient des calculs intermédiaires ou des notes de travail qu''on ne veut pas sur le papier."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 5, Manipulation d''une feuille de calculs.', v_nom;
  END LOOP;
END $inf7$;
