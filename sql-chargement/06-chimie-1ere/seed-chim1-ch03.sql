-- ---------------------------------------------------------------------------
-- M'Andal — Chimie, classes de Première
-- Chapitre 3 : Les alcanes : structure, nomenclature et isomérie
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
    WHERE programme_id = v_programme_id AND ordre = 3;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les alcanes : structure, nomenclature et isomérie', 3, 'Module 1 : Chimie organique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 3 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 3 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'La famille des alcanes', 1, 'texte', '
Les alcanes sont la famille la plus simple de toute la chimie organique, et
c''est par elle qu''on commence parce que toutes les autres s''y rattachent.

### Définition

Un **alcane** est un hydrocarbure **saturé** : ses atomes de carbone ne sont liés
entre eux que par des **liaisons simples** $C-C$, et toutes les autres valences
sont occupées par de l''hydrogène. Le mot « saturé » signifie exactement cela :
la molécule porte le maximum d''atomes d''hydrogène possible.

Leur formule générale est :

$$C_nH_{2n+2} \qquad \text{avec } n \geqslant 1$$

### Le carbone est tétragonal

Chaque atome de carbone établit **quatre** liaisons covalentes. Ces quatre
liaisons ne sont pas dans un plan : elles pointent vers les quatre sommets d''un
tétraèdre régulier, en faisant entre elles un angle de **109,5°**. On dit que le
carbone est **tétragonal**, ou tétraédrique.

L''hydrogène, lui, n''établit qu''une seule liaison : c''est un atome
**monovalent**.

### Les premiers de la famille

| $n$ | Formule | Nom | État à 25 °C |
| --- | --- | --- | --- |
| 1 | $CH_4$ | méthane | gaz |
| 2 | $C_2H_6$ | éthane | gaz |
| 3 | $C_3H_8$ | propane | gaz |
| 4 | $C_4H_{10}$ | butane | gaz |
| 5 | $C_5H_{12}$ | pentane | liquide |
| 6 | $C_6H_{14}$ | hexane | liquide |
| 7 | $C_7H_{16}$ | heptane | liquide |
| 8 | $C_8H_{18}$ | octane | liquide |

Apprends les huit premiers noms. Ils servent de racine à toute la nomenclature
organique, y compris pour les alcools et les acides que tu verras plus tard.

### Trois façons d''écrire la même molécule

La **formule brute** donne le décompte des atomes : $C_4H_{10}$.

La **formule développée** montre toutes les liaisons, y compris celles avec
l''hydrogène.

La **formule semi-développée** montre les liaisons entre carbones, mais regroupe
les hydrogènes avec leur carbone : $CH_3-CH_2-CH_2-CH_3$. C''est celle qu''on
utilise presque toujours, parce qu''elle est lisible et sans ambiguïté.

---

**Exercice corrigé**

*Un alcane a pour masse molaire 86 g/mol. Donne sa formule brute et sa formule
semi-développée linéaire.*

**Correction.**
$$M = 14n + 2 = 86 \;\Longrightarrow\; n = \frac{86-2}{14} = 6$$
La formule brute est $C_6H_{14}$ : c''est l''hexane. Sa chaîne linéaire s''écrit
$$CH_3-CH_2-CH_2-CH_2-CH_2-CH_3$$
', NULL, 20),
      (v_chapitre_id, 'Simulation : les trois écritures d''une molécule', 2, 'interactif', '{
  "widget": "famille-alcanes",
  "consigne": "Fais glisser le curseur de 1 à 10 carbones et regarde l''alcane se construire, avec son nom et sa formule brute. Bascule ensuite entre les trois écritures — brute, développée, semi-développée — sur la même molécule : tu verras exactement ce que chacune montre et ce qu''elle cache. Vérifie au passage que la masse molaire suit bien la formule 14n + 2."
}', NULL, 10),
      (v_chapitre_id, 'Figure : le carbone tétragonal', 3, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 250" width="520" height="250">
<rect width="520" height="250" fill="#ffffff"/>
<text x="260" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le carbone tétragonal : quatre liaisons dirigées vers les sommets d&apos;un tétraèdre</text>

<g transform="translate(128,140)">
  <line x1="0" y1="0" x2="0" y2="-66" stroke="#0f172a" stroke-width="2.4"/>
  <line x1="0" y1="0" x2="-62" y2="34" stroke="#0f172a" stroke-width="2.4"/>
  <polygon points="0,0 -8,34 6,38 14,8" fill="#0f172a"/>
  <line x1="0" y1="0" x2="58" y2="22" stroke="#0f172a" stroke-width="2" stroke-dasharray="5 4"/>
  <circle cx="0" cy="0" r="17" fill="#334155"/>
  <text x="0" y="5" text-anchor="middle" font-size="13" font-weight="700" fill="#ffffff">C</text>
  <circle cx="0" cy="-66" r="13" fill="#e2e8f0" stroke="#64748b" stroke-width="1.4"/>
  <text x="0" y="-62" text-anchor="middle" font-size="11" fill="#0f172a">H</text>
  <circle cx="-62" cy="34" r="13" fill="#e2e8f0" stroke="#64748b" stroke-width="1.4"/>
  <text x="-62" y="38" text-anchor="middle" font-size="11" fill="#0f172a">H</text>
  <circle cx="10" cy="38" r="13" fill="#e2e8f0" stroke="#64748b" stroke-width="1.4"/>
  <text x="10" y="42" text-anchor="middle" font-size="11" fill="#0f172a">H</text>
  <circle cx="58" cy="22" r="13" fill="#e2e8f0" stroke="#64748b" stroke-width="1.4"/>
  <text x="58" y="26" text-anchor="middle" font-size="11" fill="#0f172a">H</text>
  <path d="M-30 -16 a34 34 0 0 1 36 -10" fill="none" stroke="#2563eb" stroke-width="1.4"/>
  <text x="-36" y="-26" font-size="11" font-weight="700" fill="#2563eb">109,5°</text>
</g>

<g transform="translate(340,80)">
  <text x="0" y="0" font-size="12" font-weight="700" fill="#0f172a">À retenir</text>
  <text x="0" y="24" font-size="11" fill="#334155">Les quatre liaisons sont identiques.</text>
  <text x="0" y="44" font-size="11" fill="#334155">L&apos;angle entre deux liaisons vaut 109,5°.</text>
  <text x="0" y="64" font-size="11" fill="#334155">La molécule n&apos;est pas plane.</text>
  <text x="0" y="90" font-size="11" fill="#334155">Trait plein : dans le plan de la feuille.</text>
  <text x="0" y="110" font-size="11" fill="#334155">Triangle plein : vers l&apos;avant.</text>
  <text x="0" y="130" font-size="11" fill="#334155">Pointillés : vers l&apos;arrière.</text>
</g>
</svg>', NULL, 5),
      (v_chapitre_id, 'Nommer un alcane : les quatre règles', 4, 'texte', '
La nomenclature systématique n''est pas une liste à apprendre par cœur : c''est
une méthode à appliquer dans l''ordre. Quatre règles suffisent.

### Règle 1 — Choisir la chaîne principale

C''est la **chaîne carbonée la plus longue**. Elle donne le nom de base : six
carbones, on dira « hexane ». Attention, la chaîne la plus longue n''est pas
toujours celle qui est écrite horizontalement sur la feuille. Compte, ne regarde
pas.

### Règle 2 — Numéroter

On numérote les carbones de la chaîne principale **à partir de l''extrémité la
plus proche de la première ramification**. Le but est d''obtenir les indices les
plus petits possible.

### Règle 3 — Nommer les ramifications

Une ramification est un groupe d''atomes greffé sur la chaîne. On l''appelle
**groupe alkyle** et on le nomme en remplaçant la terminaison *-ane* par *-yle* :

| Groupe | Nom |
| --- | --- |
| $-CH_3$ | méthyle |
| $-C_2H_5$ | éthyle |
| $-C_3H_7$ | propyle |

### Règle 4 — Assembler

On écrit, dans l''ordre : l''indice, un tiret, le nom du groupe, puis le nom de la
chaîne principale, le tout en un seul mot.

Si le même groupe apparaît plusieurs fois, on le précède de **di-**, **tri-** ou
**tétra-**, et l''on cite chaque indice séparé par une virgule. Si les groupes
sont différents, on les cite par **ordre alphabétique**, en ignorant les
préfixes multiplicateurs pour le classement.

### Un exemple complet

$$CH_3-CH(CH_3)-CH_2-CH(C_2H_5)-CH_3$$

Chaîne principale : cinq carbones, donc « pentane ». En numérotant par la gauche,
les ramifications sont en 2 et 4 ; par la droite, en 2 et 4 également. On garde
la numérotation qui donne l''indice le plus petit au groupe cité en premier dans
l''ordre alphabétique. Les groupes sont un éthyle et un méthyle ; « éthyle » vient
avant « méthyle ». On numérote donc de façon que l''éthyle porte l''indice 2.

Le nom est **2-éthyl-4-méthylpentane**.

---

**Exercice corrigé**

*Nomme l''alcane suivant :*
$$CH_3-CH_2-CH(CH_3)-CH_2-CH_2-CH_3$$

**Correction.**
*Chaîne principale.* En comptant de gauche à droite : 6 carbones. Le nom de base
est hexane.
*Numérotation.* Depuis la gauche, la ramification est sur le carbone 3. Depuis
la droite, elle est sur le carbone 4. On garde 3, le plus petit.
*Ramification.* Un seul groupe, $-CH_3$, donc un méthyle.
*Nom.* **3-méthylhexane**.
', NULL, 25),
      (v_chapitre_id, 'Simulation : construire et nommer un alcane', 5, 'interactif', '{
  "widget": "nomenclature-alcane",
  "consigne": "Allonge la chaîne principale, puis pose des ramifications là où tu veux. Le nom systématique se construit à mesure. Déplace une ramification d''un carbone et regarde la numérotation basculer d''un bout à l''autre de la chaîne : c''est la règle du plus petit indice en action."
}', NULL, 10),
      (v_chapitre_id, 'L''isomérie de chaîne', 6, 'texte', '
Deux corps peuvent avoir **la même formule brute** et être pourtant des corps
différents, avec des propriétés différentes. On dit qu''ils sont **isomères**.

### Chez les alcanes, une seule sorte d''isomérie

Puisqu''il n''y a ni double liaison ni fonction, la seule façon de changer la
molécule est de changer la forme du squelette carboné. C''est l''**isomérie de
chaîne**, ou isomérie de squelette.

### Les trois isomères du pentane

Pour $C_5H_{12}$ :

$$CH_3-CH_2-CH_2-CH_2-CH_3 \qquad \text{le } n\text{-pentane}$$
$$CH_3-CH(CH_3)-CH_2-CH_3 \qquad \text{le 2-méthylbutane}$$
$$C(CH_3)_4 \qquad \text{le 2,2-diméthylpropane}$$

Trois corps, une seule formule brute, trois températures d''ébullition
différentes : 36 °C, 28 °C et 10 °C.

### Le nombre d''isomères explose avec $n$

| $n$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Isomères | 1 | 1 | 1 | 2 | 3 | 5 | 9 | 18 |

Retiens au moins jusqu''à $n = 6$. Au-delà, l''énumération complète n''est pas
demandée au probatoire.

### La méthode pour ne rien oublier

Procède par longueur de chaîne principale décroissante. Pour l''hexane :
d''abord la chaîne de 6, puis les chaînes de 5 avec un méthyle, puis les chaînes
de 4 avec deux méthyles ou un éthyle. Une ramification sur le carbone 1 n''en est
pas une : elle rallonge simplement la chaîne. C''est l''erreur classique qui fait
compter deux fois le même corps.

---

**Exercice corrigé**

*Donne les formules semi-développées et les noms de tous les isomères de
$C_6H_{14}$.*

**Correction.** Cinq isomères, trouvés par longueur de chaîne décroissante.

*Chaîne de 6 carbones*, sans ramification :
$CH_3-CH_2-CH_2-CH_2-CH_2-CH_3$ — le **n-hexane**.

*Chaîne de 5 carbones*, avec un méthyle. Le méthyle ne peut être qu''en 2 ou en 3 :
$CH_3-CH(CH_3)-CH_2-CH_2-CH_3$ — le **2-méthylpentane** ;
$CH_3-CH_2-CH(CH_3)-CH_2-CH_3$ — le **3-méthylpentane**.

*Chaîne de 4 carbones*, avec deux méthyles :
$CH_3-C(CH_3)_2-CH_2-CH_3$ — le **2,2-diméthylbutane** ;
$CH_3-CH(CH_3)-CH(CH_3)-CH_3$ — le **2,3-diméthylbutane**.

Une chaîne de 4 avec un éthyle redonnerait une chaîne de 6 : ce n''est pas un
isomère nouveau. Total : **cinq isomères**.
', NULL, 25),
      (v_chapitre_id, 'Simulation : compter les isomères', 7, 'interactif', '{
  "widget": "isomeres-alcane",
  "consigne": "Choisis le nombre d''atomes de carbone et parcours les isomères un par un. Observe comment leur nombre passe de 3 pour cinq carbones à 18 pour huit : c''est pour cela qu''on n''en demande jamais l''énumération complète au-delà de six."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 3', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la formule générale des alcanes ?",
      "choix": [
        "$C_nH_{2n}$",
        "$C_nH_{2n+2}$",
        "$C_nH_{2n-2}$",
        "$C_nH_n$"
      ],
      "bonne": 1,
      "explication": "Les alcanes sont saturés : chaque carbone porte le maximum d''hydrogènes, d''où $C_nH_{2n+2}$."
    },
    {
      "question": "Combien de liaisons un atome de carbone établit-il dans un alcane ?",
      "choix": [
        "2",
        "3",
        "4",
        "cela dépend de l''alcane"
      ],
      "bonne": 2,
      "explication": "Le carbone est toujours tétravalent. Dans un alcane, ses quatre liaisons sont simples et dirigées vers les sommets d''un tétraèdre."
    },
    {
      "question": "Quel est l''angle entre deux liaisons d''un carbone tétragonal ?",
      "choix": [
        "90°",
        "109,5°",
        "120°",
        "180°"
      ],
      "bonne": 1,
      "explication": "C''est l''angle du tétraèdre régulier. Il explique pourquoi une molécule d''alcane n''est jamais plane."
    },
    {
      "question": "Comment nomme-t-on le groupe $-C_2H_5$ ?",
      "choix": [
        "méthyle",
        "éthyle",
        "propyle",
        "éthane"
      ],
      "bonne": 1,
      "explication": "On remplace la terminaison -ane de l''alcane correspondant par -yle : éthane devient éthyle."
    },
    {
      "question": "Combien d''isomères possède $C_5H_{12}$ ?",
      "choix": [
        "2",
        "3",
        "4",
        "5"
      ],
      "bonne": 1,
      "explication": "Trois : le n-pentane, le 2-méthylbutane et le 2,2-diméthylpropane."
    },
    {
      "question": "Dans la numérotation d''une chaîne, quelle extrémité choisit-on ?",
      "choix": [
        "Toujours la gauche",
        "Celle qui donne les plus petits indices aux ramifications",
        "Celle qui donne les plus grands indices",
        "Peu importe"
      ],
      "bonne": 1,
      "explication": "La règle du plus petit indice tranche. Si les deux sens donnent le même jeu d''indices, on départage par l''ordre alphabétique."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 3, Les alcanes : structure, nomenclature et isomérie.', v_nom;
  END LOOP;
END $ch1$;
