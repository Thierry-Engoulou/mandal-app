-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 8 : Polymérisation et préparations au laboratoire
-- Module 1 : Chimie organique — 10 leçons
--
-- Ce fichier remplit les trois séries d'un coup : la 1ère C, la 1ère D et la
-- 1ère E. Il n'a besoin de rien d'autre pour tourner. Si la matière, les
-- classes, les programmes ou le chapitre n'existent pas encore, il les crée
-- lui-même au passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $ch1$
DECLARE
  v_lettres text[] := ARRAY['C', 'D', 'E'];
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
  INSERT INTO public.matieres (nom) VALUES ('Chimie') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Chimie';

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
    WHERE p.titre = 'Chimie — ' || v_nom;

    -- Non : on le crée, et la classe avec si besoin.
    IF v_programme_id IS NULL THEN
      -- La classe a pu être écrite de plusieurs façons : 1ère C, 1ere C, Première C.
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
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Chimie — ' || v_nom,
              'Programme officiel de Chimie, classe de Première ' || v_lettre ||
              ' (Cameroun) — 3 modules, 19 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme de Chimie de la % : créé.', v_nom;
    END IF;

    -- Le chapitre lui-même.
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 8;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Polymérisation et préparations au laboratoire', 8, 'Module 1 : Chimie organique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 8 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 8 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'La polymérisation', 1, 'texte', '
Voici la réaction qui a changé le monde matériel au XXᵉ siècle, et qui explique
pourquoi les alcènes valent bien plus cher comme matière première que comme
combustible.

### Définition

On appelle **polymérisation** une réaction d''addition des unes sur les autres
de molécules insaturées **identiques**.

Le composé de départ s''appelle le **monomère**. Le composé final s''appelle le
**polymère**.

Si les molécules additionnées sont insaturées mais **différentes**, on parle de
**copolymérisation**.

### Le vocabulaire à maîtriser

Le **motif** du polymère est le groupe d''atomes — la plus petite unité
structurale — qui se répète un grand nombre de fois dans la macromolécule.

L''**indice de polymérisation**, aussi appelé **degré de polymérisation** et noté
$n$, est le nombre de monomères additionnés pour obtenir le polymère.

On le calcule toujours de la même façon :

$$n = \frac{M_{polymère}}{M_{motif}}$$

### Le mécanisme en une image

La liaison $\pi$ de chaque monomère s''ouvre. Chaque molécule tend alors une main
à gauche et une main à droite, et toutes se prennent par la main pour former une
chaîne immense. C''est une **macromolécule**.

$$n\,CH_2 = CH_2 \longrightarrow -(CH_2-CH_2)_n-$$

---

**Exercice corrigé**

*Le 1,1-difluoroéthylène peut être polymérisé. Donne le motif du polymère, puis
son degré de polymérisation sachant que la masse molaire du polymère vaut
85 kg/mol. On donne $M(C) = 12$, $M(H) = 1$, $M(F) = 19$ g/mol.*

**Correction.**
Le monomère est $CH_2 = CF_2$. L''ouverture de la liaison $\pi$ donne le motif
$$-(CH_2-CF_2)-$$
Sa masse molaire vaut
$$M_{motif} = 2 \times 12 + 2 \times 1 + 2 \times 19 = 64 \text{ g/mol}$$
D''où
$$n = \frac{85\,000}{64} \approx 1\,328$$
La macromolécule compte environ 1 328 motifs.
', NULL, 22),
      (v_chapitre_id, 'Simulation : fabriquer un polymère', 2, 'interactif', '{
  "widget": "polymerisation",
  "consigne": "Choisis un monomère, puis ajoute-les un par un : la liaison double s''ouvre et la chaîne s''allonge sous tes yeux. La simulation affiche en permanence le motif, le nombre de monomères et la masse molaire de la macromolécule. Fixe une masse molaire cible et retrouve l''indice de polymérisation, exactement comme à l''examen."
}', NULL, 10),
      (v_chapitre_id, 'Trois polymères du quotidien', 3, 'texte', '
### Le polyéthylène, PE

$$n\,CH_2 = CH_2 \longrightarrow -(CH_2-CH_2)_n-$$

L''industrie en fabrique deux sortes, qui ne se ressemblent pas :

- le **polyéthylène basse densité (PEBD)**, obtenu **sous haute pression**. Il
sert aux emballages souples — sachets, bouteilles — et aux isolants
électriques.
- le **polyéthylène haute densité (PEHD)**, obtenu **à basse pression**. Il sert
aux emballages rigides : casiers, règles, jouets.

Note l''inversion, elle surprend souvent : c''est la **haute** pression qui donne
la **basse** densité.

### Le polychlorure de vinyle, PVC

$$n\,CH_2 = CHCl \longrightarrow -(CH_2-CHCl)_n-$$

Le monomère, le chlorure de vinyle, vient de l''acétylène comme tu l''as vu au
chapitre 7. Le PVC sert aux tuyaux, aux prises électriques, aux bouteilles
rigides.

### Le polystyrène, PS

$$n\,CH_2 = CH-C_6H_5 \longrightarrow -(CH_2-CH\!-\!C_6H_5)_n-$$

Le monomère, le styrène, s''appelle aussi **vinylbenzène** ou
phényléthylène. Le polystyrène est un solide thermoplastique très dur, utilisé
pour emballer les objets fragiles et comme isolant thermique et phonique.

---

**Exercice corrigé**

*On polymérise le styrène. La macromolécule obtenue a pour masse molaire
$M = 8\,320$ g/mol. Détermine son indice de polymérisation.*

**Correction.**
Le motif est $-(CH_2-CH-C_6H_5)-$, soit $C_8H_8$.
$$M_{motif} = 8 \times 12 + 8 \times 1 = 104 \text{ g/mol}$$
$$n = \frac{8\,320}{104} = 80$$
La macromolécule compte 80 motifs de styrène.
', NULL, 20),
      (v_chapitre_id, 'Figure : PE, PVC et polystyrène', 4, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 290" width="540" height="290">
<rect width="540" height="290" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Trois polymères que tu touches tous les jours</text>

<g transform="translate(0,44)">
  <rect x="20" y="0" width="500" height="68" fill="#f1f5f9" rx="8"/>
  <text x="34" y="22" font-size="12" font-weight="700" fill="#2563eb">POLYÉTHYLÈNE (PE)</text>
  <text x="34" y="42" font-size="11" fill="#334155">monomère : CH&#8322;=CH&#8322; (éthylène)</text>
  <text x="34" y="60" font-size="11" fill="#64748b">sachets, bouteilles souples, casiers, règles, jouets</text>
  <text x="330" y="40" font-size="13" font-weight="700" fill="#0f172a">&#8212;(CH&#8322;&#8211;CH&#8322;)&#8345;&#8212;</text>
  <text x="330" y="60" font-size="10" fill="#64748b">motif répété n fois</text>
</g>

<g transform="translate(0,124)">
  <rect x="20" y="0" width="500" height="68" fill="#f1f5f9" rx="8"/>
  <text x="34" y="22" font-size="12" font-weight="700" fill="#16a34a">POLYCHLORURE DE VINYLE (PVC)</text>
  <text x="34" y="42" font-size="11" fill="#334155">monomère : CH&#8322;=CHCl (chlorure de vinyle)</text>
  <text x="34" y="60" font-size="11" fill="#64748b">tuyaux, prises électriques, bouteilles rigides</text>
  <text x="330" y="40" font-size="13" font-weight="700" fill="#0f172a">&#8212;(CH&#8322;&#8211;CHCl)&#8345;&#8212;</text>
  <text x="330" y="60" font-size="10" fill="#64748b">motif répété n fois</text>
</g>

<g transform="translate(0,204)">
  <rect x="20" y="0" width="500" height="68" fill="#f1f5f9" rx="8"/>
  <text x="34" y="22" font-size="12" font-weight="700" fill="#b45309">POLYSTYRÈNE (PS)</text>
  <text x="34" y="42" font-size="11" fill="#334155">monomère : CH&#8322;=CH&#8211;C&#8326;H&#8325; (styrène)</text>
  <text x="34" y="60" font-size="11" fill="#64748b">emballages d&apos;objets fragiles, isolants</text>
  <text x="330" y="40" font-size="13" font-weight="700" fill="#0f172a">&#8212;(CH&#8322;&#8211;CHC&#8326;H&#8325;)&#8345;&#8212;</text>
  <text x="330" y="60" font-size="10" fill="#64748b">motif répété n fois</text>
</g>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : du monomère à l''objet', 5, 'interactif', '{
  "widget": "polymeres-usages",
  "consigne": "Prends un objet du quotidien — un sachet, un tuyau, un casier, une barquette d''emballage — et la simulation remonte la chaîne à l''envers : quel polymère le compose, quel est son motif, et de quel monomère il vient. Inverse ensuite le sens et pars du monomère pour retrouver les objets. C''est la façon la plus sûre de ne plus confondre PE, PVC et polystyrène le jour de l''examen."
}', NULL, 10),
      (v_chapitre_id, 'Préparer l''acétylène au laboratoire', 6, 'texte', '
Il n''y a qu''une seule préparation à connaître, et elle est simple. On fait
réagir de l''eau sur le **carbure de calcium** $CaC_2$ :

$$CaC_2 + 2\,H_2O \longrightarrow C_2H_2 + Ca(OH)_2$$

Le carbure de calcium est un solide gris. On le pose dans un flacon, on verse
l''eau goutte à goutte, et l''acétylène se dégage immédiatement. Le second produit
est l''hydroxyde de calcium, la chaux éteinte.

**Purification.** Le gaz obtenu n''est pas pur : le carbure de calcium du
commerce contient des impuretés sulfurées qui donnent au gaz une odeur
désagréable. On fait barboter l''acétylène dans une **solution de sulfate de
cuivre**, qui retient ces impuretés.

**Accélérer la réaction.** Elle est plus rapide si l''on place le flacon dans de
l''**eau tiède**.

**Un usage que tu connais peut-être.** C''est le principe de la lampe à carbure,
encore utilisée dans certaines mines : l''eau goutte sur le carbure, l''acétylène
produit brûle à la sortie d''un bec et éclaire.

---

**Exercice corrigé**

*On part de 70 g de carbure de calcium et on obtient 19 g d''acétylène. Montre
que le carbure contenait des impuretés et calcule leur pourcentage.*
*On donne $M(H) = 1$, $M(C) = 12$, $M(Ca) = 40$ g/mol.*

**Correction.**
$$M(CaC_2) = 40 + 2 \times 12 = 64 \text{ g/mol} \qquad M(C_2H_2) = 26 \text{ g/mol}$$
D''après l''équation, une mole de carbure donne une mole d''acétylène. Donc
$$n_{C_2H_2} = \frac{19}{26} = 0{,}731 \text{ mol}$$
La masse de carbure **réellement présent** est
$$m_r = 0{,}731 \times 64 = 46{,}8 \text{ g}$$
Or on en avait pesé 70 g : les 23,2 g manquants sont des impuretés. D''où
$$p = \frac{70 - 46{,}8}{70} \times 100 = 33{,}1\,\%$$
Le carbure utilisé contenait environ 33 % d''impuretés.
', NULL, 22),
      (v_chapitre_id, 'Simulation : la lampe à carbure', 7, 'interactif', '{
  "widget": "carbure-acetylene",
  "consigne": "Verse l''eau goutte à goutte sur le carbure de calcium et regarde l''acétylène se dégager, puis brûler au bec. Fais varier la masse de carbure et le taux d''impuretés : la simulation calcule le volume de gaz attendu, le volume réellement obtenu et le rendement. Place ensuite le flacon dans l''eau tiède pour voir la réaction s''accélérer."
}', NULL, 10),
      (v_chapitre_id, 'Préparer un alcène : la déshydratation d''un alcool', 8, 'texte', '
Au chapitre 7 tu as fabriqué un alcool à partir d''un alcène, en ajoutant de
l''eau. On peut faire exactement l''inverse : **retirer** l''eau d''un alcool pour
obtenir un alcène. C''est la **déshydratation**.

$$CH_3-CH_2-OH \xrightarrow[170\,°C]{\;H_2SO_4\;} CH_2 = CH_2 + H_2O$$

Deux conditions sont indispensables :

- un **déshydratant**, l''acide sulfurique concentré $H_2SO_4$ ;
- une **température élevée**, de l''ordre de 170 °C.

Hydratation et déshydratation sont donc deux réactions inverses l''une de
l''autre. Ce qui les départage, ce sont les conditions : acide dilué et douceur
d''un côté, acide concentré et forte chaleur de l''autre.

### Pourquoi c''est utile à savoir

Dans beaucoup d''exercices d''examen, on te demande de passer d''un composé à un
autre en plusieurs étapes. Tu disposes maintenant d''un aller-retour complet :

$$\text{alcyne} \xrightarrow{+H_2,\;Pd} \text{alcène}
\xrightarrow[\text{hydratation}]{+H_2O} \text{alcool}
\xrightarrow[\text{déshydratation}]{-H_2O} \text{alcène}$$

---

**Exercice corrigé**

*On produit du butan-2-ol à partir du but-1-ène. Écris l''équation-bilan, puis
calcule la masse de butan-2-ol obtenue en traitant 1,5 t de but-1-ène si le
rendement, après recyclage, est de 43 %.*

**Correction.** L''alcène est dissymétrique : la règle de Markovnikov s''applique
et le $-OH$ se fixe sur le carbone n° 2.
$$CH_3-CH_2-CH=CH_2 + H_2O \longrightarrow CH_3-CH_2-CH(OH)-CH_3$$
Les masses molaires valent $M_{alcène} = 56$ g/mol et $M_{alcool} = 74$ g/mol.
$$n_{alcène} = \frac{1{,}5 \times 10^6}{56} = 2{,}68 \times 10^4 \text{ mol}$$
Avec un rendement de 43 % :
$$m = 0{,}43 \times 2{,}68 \times 10^4 \times 74 = 8{,}52 \times 10^5 \text{ g}$$
soit environ **0,85 tonne** de butan-2-ol.
', NULL, 20),
      (v_chapitre_id, 'Simulation : hydrater, déshydrater', 9, 'interactif', '{
  "widget": "deshydratation-alcool",
  "consigne": "Pose un alcool dans le ballon, chauffe, et regarde l''eau partir pour laisser un alcène. Puis inverse le sens : ajoute de l''eau en milieu acide dilué et l''alcool revient. Le curseur de température te montre pourquoi les deux réactions ne se font pas dans les mêmes conditions. Essaie avec un alcool dissymétrique et vérifie que Markovnikov est respecté au retour."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 8', 10, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''appelle-t-on le motif d''un polymère ?",
      "choix": [
        "Le monomère de départ",
        "La plus petite unité structurale qui se répète",
        "La masse molaire du polymère",
        "Le catalyseur utilisé"
      ],
      "bonne": 1,
      "explication": "Pour le polyéthylène, le motif est $-(CH_2-CH_2)-$. C''est lui dont on calcule la masse molaire pour trouver l''indice de polymérisation."
    },
    {
      "question": "Comment calcule-t-on l''indice de polymérisation ?",
      "choix": [
        "$n = M_{motif} \\times M_{polymère}$",
        "$n = \\frac{M_{polymère}}{M_{motif}}$",
        "$n = \\frac{M_{motif}}{M_{polymère}}$",
        "$n = M_{polymère} - M_{motif}$"
      ],
      "bonne": 1,
      "explication": "On divise la masse molaire de la macromolécule par celle d''un motif : le quotient donne le nombre de motifs enchaînés."
    },
    {
      "question": "Le polyéthylène basse densité (PEBD) est obtenu :",
      "choix": [
        "à basse pression",
        "sous haute pression",
        "à basse température",
        "sans catalyseur"
      ],
      "bonne": 1,
      "explication": "C''est l''inversion qui surprend : haute pression donne basse densité, et c''est le PEBD qui sert aux sachets et aux emballages souples."
    },
    {
      "question": "Quel est le monomère du PVC ?",
      "choix": [
        "L''éthylène",
        "Le chlorure de vinyle $CH_2 = CHCl$",
        "Le styrène",
        "Le propène"
      ],
      "bonne": 1,
      "explication": "Le chlorure de vinyle s''obtient par addition de $HCl$ sur l''acétylène, en présence de chlorure de mercure à 200 °C."
    },
    {
      "question": "Quelle est l''équation de préparation de l''acétylène au laboratoire ?",
      "choix": [
        "$Al_4C_3 + 12H_2O \\rightarrow 4Al(OH)_3 + 3CH_4$",
        "$CaC_2 + 2H_2O \\rightarrow C_2H_2 + Ca(OH)_2$",
        "$C_2H_4 + H_2 \\rightarrow C_2H_6$",
        "$CaCO_3 \\rightarrow CaO + CO_2$"
      ],
      "bonne": 1,
      "explication": "On verse de l''eau sur le carbure de calcium. Attention à ne pas confondre avec la préparation du méthane, qui part du carbure d''aluminium."
    },
    {
      "question": "Dans quoi fait-on barboter l''acétylène pour le purifier ?",
      "choix": [
        "Dans l''eau salée",
        "Dans une solution de sulfate de cuivre",
        "Dans l''acide sulfurique",
        "Dans l''eau de dibrome"
      ],
      "bonne": 1,
      "explication": "La solution de sulfate de cuivre retient les impuretés sulfurées présentes dans le carbure de calcium du commerce."
    },
    {
      "question": "Quelles conditions faut-il pour déshydrater un alcool en alcène ?",
      "choix": [
        "De l''eau froide",
        "De l''acide sulfurique concentré vers 170 °C",
        "De la lumière",
        "Du nickel à 60 °C"
      ],
      "bonne": 1,
      "explication": "Il faut un déshydratant puissant et une forte chaleur. Avec de l''acide dilué et sans chauffage, c''est la réaction inverse — l''hydratation — qui l''emporte."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 10 leçons ajoutées au chapitre 8, Polymérisation et préparations au laboratoire.', v_nom;
  END LOOP;
END $ch1$;
