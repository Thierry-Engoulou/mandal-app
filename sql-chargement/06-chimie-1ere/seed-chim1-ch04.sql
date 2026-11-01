-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 4 : Les cyclanes et les propriétés physiques des alcanes
-- Module 1 : Chimie organique — 8 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 4;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les cyclanes et les propriétés physiques des alcanes', 4, 'Module 1 : Chimie organique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 4 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 4 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les cyclanes', 1, 'texte', '
Jusqu''ici, nos chaînes carbonées avaient deux extrémités. Et si on les refermait
sur elles-mêmes ?

### Définition

Un **cyclane**, ou cycloalcane, est un hydrocarbure saturé dont la chaîne
carbonée forme un **cycle fermé**. En refermant la chaîne, on crée une liaison
$C-C$ de plus et l''on perd deux hydrogènes. La formule générale devient :

$$C_nH_{2n} \qquad \text{avec } n \geqslant 3$$

Il faut au moins trois carbones pour fermer un cycle : avec deux, on ne ferait
que doubler une liaison existante.

### Nomenclature

On ajoute simplement le préfixe **cyclo-** au nom de l''alcane de même nombre de
carbones.

| Formule | Nom | Forme |
| --- | --- | --- |
| $C_3H_6$ | cyclopropane | triangle |
| $C_4H_8$ | cyclobutane | carré |
| $C_5H_{10}$ | cyclopentane | pentagone |
| $C_6H_{12}$ | cyclohexane | hexagone |

### La stabilité croît avec la taille du cycle

Le carbone « veut » un angle de 109,5° entre ses liaisons. Dans un triangle
équilatéral, l''angle vaut 60° : les liaisons du cyclopropane sont donc fortement
contraintes, et la molécule est instable, très réactive. Dans un hexagone,
l''angle vaut 120°, bien plus proche des 109,5° voulus.

**La stabilité croît donc de $C_3H_6$ à $C_6H_{12}$.** Le cyclohexane est le plus
stable, et c''est le cyclane que l''on rencontre le plus souvent.

### Une précision qui tombe souvent

Le cyclohexane **n''est pas plan**. Pour que chaque carbone retrouve ses 109,5°,
le cycle se plisse et adopte une forme dite « en chaise ». Si un sujet te demande
si la molécule de cyclohexane est plane, la réponse est non.

### Attention à la confusion

$C_nH_{2n}$ est aussi la formule générale des alcènes, que tu verras au chapitre
suivant. Une même formule brute, deux familles : $C_3H_6$ peut être le
cyclopropane ou le propène. C''est une **isomérie de fonction**, et les sujets en
jouent volontiers.

---

**Exercice corrigé**

*Un hydrocarbure cyclique saturé a une masse molaire de 70 g/mol. Donne sa
formule brute, son nom, et dis s''il est plus ou moins stable que le
cyclopropane.*

**Correction.**
$$M = 14n = 70 \;\Longrightarrow\; n = 5$$
La formule brute est $C_5H_{10}$, c''est le **cyclopentane**. Son cycle à cinq
côtés impose un angle de 108°, très proche des 109,5° naturels du carbone : il
est donc **bien plus stable** que le cyclopropane, dont l''angle de 60° contraint
fortement les liaisons.
', NULL, 22),
      (v_chapitre_id, 'Simulation : les cyclanes et leur stabilité', 2, 'interactif', '{
  "widget": "cyclanes",
  "consigne": "Fais varier le nombre de carbones du cycle, de 3 à 8. L''angle imposé par le polygone s''affiche à côté des 109,5° que le carbone recherche. L''écart entre les deux mesure la tension du cycle, donc son instabilité."
}', NULL, 10),
      (v_chapitre_id, 'Les conformations de l''éthane', 3, 'texte', '
Prends la molécule d''éthane $CH_3-CH_3$ et fais tourner un groupe méthyle autour
de la liaison $C-C$, comme on tourne une poignée. La molécule change d''aspect
sans qu''aucune liaison ne soit rompue. Ces différentes formes géométriques
s''appellent des **conformations**.

### Une infinité de conformations, deux remarquables

La rotation est libre et continue : il existe donc une infinité de
conformations. Deux d''entre elles méritent un nom.

La conformation **décalée** : vus selon l''axe $C-C$, les hydrogènes de l''avant
tombent exactement entre ceux de l''arrière. Ils sont le plus **éloignés**
possible les uns des autres.

La conformation **éclipsée** : les hydrogènes de l''avant cachent ceux de
l''arrière. Ils sont le plus **rapprochés** possible.

### Laquelle est la plus stable ?

La conformation **décalée**. Les atomes d''hydrogène se repoussent ; plus ils sont
éloignés, plus l''énergie de la molécule est basse, et plus la forme est stable.

Retiens le raisonnement, pas seulement le résultat : on te demandera de justifier.

### La représentation de Newman

Pour dessiner tout cela, on regarde la molécule **dans l''axe de la liaison
$C-C$**. Le carbone de devant est figuré par un point d''où partent trois traits ;
celui de derrière par un cercle d''où partent trois autres traits. Décalée, les
traits alternent ; éclipsée, ils se superposent.

### Conformation n''est pas isomérie

Deux conformations ne sont **pas** deux corps différents. On passe de l''une à
l''autre par simple rotation, sans casser de liaison. Deux isomères, au
contraire, ne peuvent se transformer l''un en l''autre qu''en rompant des liaisons.
C''est une distinction que les correcteurs guettent.

Et le méthane, dans tout cela ? Il n''a qu''un seul carbone, donc **aucune liaison
$C-C$** autour de laquelle tourner. La notion de conformation ne s''applique pas
au méthane.

---

**Exercice corrigé**

*Soit la molécule d''éthane. 1) Pourquoi présente-t-elle une infinité de
conformations ? 2) Représente selon Newman les deux conformations
particulières. 3) Laquelle est la plus stable et pourquoi ?*

**Correction.**
1) Parce que la rotation autour de la liaison simple $C-C$ est **libre**. Chaque
angle de rotation donne une conformation différente, et l''angle varie de façon
continue : il y en a donc une infinité.
2) Voir la figure de la leçon : décalée, les traits avant tombent entre les
traits arrière ; éclipsée, ils se superposent.
3) La **décalée**. Les atomes d''hydrogène portés par les deux carbones y sont au
maximum d''éloignement, donc leur répulsion mutuelle est minimale et l''énergie de
la molécule est la plus basse.
', NULL, 22),
      (v_chapitre_id, 'Figure : les projections de Newman de l''éthane', 4, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 240" width="520" height="240">
<rect width="520" height="240" fill="#ffffff"/>
<text x="260" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les deux conformations de l&apos;éthane, vues selon l&apos;axe C–C</text>

<g transform="translate(130,135)">
  <circle cx="0" cy="0" r="56" fill="#ffffff" stroke="#64748b" stroke-width="2"/>
  <line x1="0" y1="0" x2="0" y2="-56" stroke="#2563eb" stroke-width="3"/>
  <line x1="0" y1="0" x2="-48" y2="28" stroke="#2563eb" stroke-width="3"/>
  <line x1="0" y1="0" x2="48" y2="28" stroke="#2563eb" stroke-width="3"/>
  <line x1="0" y1="56" x2="0" y2="76" stroke="#dc2626" stroke-width="3"/>
  <line x1="-48" y1="-28" x2="-66" y2="-38" stroke="#dc2626" stroke-width="3"/>
  <line x1="48" y1="-28" x2="66" y2="-38" stroke="#dc2626" stroke-width="3"/>
  <circle cx="0" cy="0" r="7" fill="#334155"/>
  <text x="0" y="-78" text-anchor="middle" font-size="12" font-weight="700" fill="#16a34a">DÉCALÉE</text>
  <text x="0" y="104" text-anchor="middle" font-size="11" fill="#16a34a">hydrogènes éloignés</text>
  <text x="0" y="120" text-anchor="middle" font-size="11" font-weight="700" fill="#16a34a">la plus stable</text>
</g>

<g transform="translate(370,135)">
  <circle cx="0" cy="0" r="56" fill="#ffffff" stroke="#64748b" stroke-width="2"/>
  <line x1="0" y1="0" x2="0" y2="-56" stroke="#2563eb" stroke-width="3"/>
  <line x1="0" y1="0" x2="-48" y2="28" stroke="#2563eb" stroke-width="3"/>
  <line x1="0" y1="0" x2="48" y2="28" stroke="#2563eb" stroke-width="3"/>
  <line x1="0" y1="-56" x2="0" y2="-76" stroke="#dc2626" stroke-width="3"/>
  <line x1="-48" y1="28" x2="-66" y2="38" stroke="#dc2626" stroke-width="3"/>
  <line x1="48" y1="28" x2="66" y2="38" stroke="#dc2626" stroke-width="3"/>
  <circle cx="0" cy="0" r="7" fill="#334155"/>
  <text x="0" y="-92" text-anchor="middle" font-size="12" font-weight="700" fill="#dc2626">ÉCLIPSÉE</text>
  <text x="0" y="104" text-anchor="middle" font-size="11" fill="#dc2626">hydrogènes face à face</text>
  <text x="0" y="120" text-anchor="middle" font-size="11" font-weight="700" fill="#dc2626">la moins stable</text>
</g>

<text x="260" y="226" text-anchor="middle" font-size="10" fill="#64748b">bleu : carbone avant &#8212; rouge : carbone arrière</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : faire tourner la molécule d''éthane', 5, 'interactif', '{
  "widget": "conformations-ethane",
  "consigne": "Attrape la molécule et fais-la tourner autour de la liaison carbone-carbone. La projection de Newman suit ton geste, et une courbe d''énergie monte et descend en dessous : tu vois les creux correspondre aux conformations décalées et les sommets aux conformations éclipsées. Lâche la molécule n''importe où et elle retombera d''elle-même dans le creux le plus proche."
}', NULL, 10),
      (v_chapitre_id, 'Les propriétés physiques des alcanes', 6, 'texte', '
Quatre propriétés physiques suffisent, et toutes s''expliquent par la même idée :
les molécules d''alcanes ne portent pas de charge et ne s''attirent que faiblement.

### L''état physique dépend du nombre de carbones

| $n$ | État à température ordinaire |
| --- | --- |
| 1 à 4 | gaz |
| 5 à 17 | liquide |
| 18 et plus | solide |

C''est pourquoi le butane ($n = 4$) est en bouteille sous pression, l''essence
($n$ voisin de 8) est liquide, et la paraffine des bougies ($n$ grand) est
solide.

### La température d''ébullition croît avec la masse molaire

Plus la chaîne est longue, plus les molécules s''accrochent les unes aux autres,
et plus il faut chauffer pour les séparer. C''est ce qui permet de séparer les
constituants du pétrole par distillation, comme tu le verras au chapitre 11.

### Mais elle décroît quand la chaîne se ramifie

À nombre de carbones égal, **plus la chaîne est ramifiée, plus la température
d''ébullition est basse**. Une molécule ramifiée est compacte, presque sphérique :
elle offre moins de surface de contact à ses voisines, donc elles se tiennent
moins. Compare les trois isomères du pentane : 36 °C pour le n-pentane linéaire,
28 °C pour le 2-méthylbutane, 10 °C pour le 2,2-diméthylpropane, le plus ramifié.

C''est une question de probatoire classique, et beaucoup d''élèves répondent le
contraire. Retiens le sens : **ramification plus forte, ébullition plus basse**.

### Insolubles dans l''eau, et moins denses qu''elle

Les alcanes sont des molécules non polaires : l''eau, polaire, ne les dissout pas.
Ils flottent, car leur densité est inférieure à 1. C''est pour cette raison qu''une
nappe de pétrole reste en surface de la mer, et qu''on ne nettoie pas une tache de
cambouis à l''eau claire.

---

**Exercice corrigé**

*Classe par température d''ébullition croissante : le n-hexane, le
2,2-diméthylbutane et le n-butane. Justifie.*

**Correction.**
Le **n-butane** vient en premier : avec quatre carbones seulement, sa masse
molaire est la plus faible, et il est d''ailleurs gazeux à température ordinaire.
Viennent ensuite les deux isomères en $C_6$. Entre eux, le
**2,2-diméthylbutane** est le plus ramifié, donc le plus compact, donc celui qui
bout le plus bas. Le **n-hexane**, linéaire, bout le plus haut.

Classement : n-butane < 2,2-diméthylbutane < n-hexane.
', NULL, 22),
      (v_chapitre_id, 'Simulation : température d''ébullition et ramification', 7, 'interactif', '{
  "widget": "proprietes-alcanes",
  "consigne": "Allonge la chaîne carbonée et regarde la température d''ébullition grimper le long de la courbe : c''est ce qui explique que le propane soit un gaz et le pentane un liquide. Ajoute ensuite une ramification sans changer le nombre de carbones : la molécule devient plus compacte et le point d''ébullition redescend. Pose les trois isomères du pentane côte à côte pour voir l''écart."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 4', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la formule générale des cyclanes ?",
      "choix": [
        "$C_nH_{2n+2}$",
        "$C_nH_{2n}$",
        "$C_nH_{2n-2}$",
        "$C_nH_{n+2}$"
      ],
      "bonne": 1,
      "explication": "La fermeture du cycle crée une liaison C–C supplémentaire et fait perdre deux hydrogènes par rapport à l''alcane."
    },
    {
      "question": "Quel est le plus petit cyclane possible ?",
      "choix": [
        "Le cycloéthane",
        "Le cyclopropane",
        "Le cyclobutane",
        "Le cyclohexane"
      ],
      "bonne": 1,
      "explication": "Il faut au moins trois carbones pour fermer un cycle. Avec deux, on ne ferait que doubler une liaison déjà existante."
    },
    {
      "question": "Pourquoi le cyclopropane est-il instable ?",
      "choix": [
        "Parce qu''il est trop lourd",
        "Parce que l''angle de 60° est très éloigné des 109,5° du carbone",
        "Parce qu''il contient une double liaison",
        "Parce qu''il est insoluble"
      ],
      "bonne": 1,
      "explication": "Les liaisons sont fortement contraintes par la géométrie du triangle, ce qui rend la molécule très réactive."
    },
    {
      "question": "Quelle conformation de l''éthane est la plus stable ?",
      "choix": [
        "L''éclipsée",
        "La décalée",
        "Les deux autant",
        "Cela dépend de la température"
      ],
      "bonne": 1,
      "explication": "Dans la conformation décalée, les hydrogènes sont au maximum d''éloignement, donc leur répulsion est minimale."
    },
    {
      "question": "La notion de conformation s''applique-t-elle au méthane ?",
      "choix": [
        "Oui, il en a deux",
        "Oui, il en a une infinité",
        "Non, il n''a aucune liaison C–C",
        "Non, il est trop petit"
      ],
      "bonne": 2,
      "explication": "Une conformation suppose une rotation autour d''une liaison C–C. Le méthane n''a qu''un seul carbone."
    },
    {
      "question": "À nombre de carbones égal, comment varie la température d''ébullition quand la chaîne se ramifie ?",
      "choix": [
        "Elle augmente",
        "Elle diminue",
        "Elle ne change pas",
        "Elle double"
      ],
      "bonne": 1,
      "explication": "Une molécule ramifiée est plus compacte, offre moins de surface de contact, et ses voisines la retiennent moins : elle bout plus bas."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 4, Les cyclanes et les propriétés physiques des alcanes.', v_nom;
  END LOOP;
END $ch1$;
