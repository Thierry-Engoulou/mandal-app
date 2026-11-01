-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 9, Couples acide-base et constante d''acidité
-- Module 2 : Acides et bases en solution aqueuse
-- 4 leçons.
--
-- Ce fichier remplit LES TROIS CLASSES a la fois : Terminale C, D et E.
-- Autonome : il cree lui-meme la matiere, les classes, les programmes et le
-- chapitre s'ils n'existent pas encore. Lancez-le seul, dans n'importe quel
-- ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $chi$
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
  -- la matiere, une seule fois
  INSERT INTO public.matieres (nom) VALUES ('Chimie') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Chimie';

  -- l'etablissement, deduit de la table des classes
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- on refait le meme travail pour la Terminale C, puis la D, puis la E
  FOR v_i IN 1..3 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := 'Terminale ' || v_lettre;

    -- 1. le programme existe-t-il deja ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Chimie — ' || v_nom;

    -- 2. sinon on le cree
    IF v_programme_id IS NULL THEN
      -- la classe, quelle que soit la facon dont elle a ete ecrite
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE 'T%le ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      -- si elle n'existe pas, on la cree
      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Terminale', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'Classe "%" creee.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Chimie — ' || v_nom,
              'Programme officiel de Chimie, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 4 modules, 17 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme "Chimie — %" cree.', v_nom;
    END IF;

    -- 3. le chapitre existe-t-il deja ?
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 9;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Couples acide-base et constante d''acidité', 9, 'Module 2 : Acides et bases en solution aqueuse')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 9 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 9 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le couple acide-base et la constante d''acidité', 1, 'texte', 'Dire qu''un acide est faible ne suffit pas : il faut pouvoir dire **à quel point**. C''est le rôle de la constante d''acidité.

## La définition de Brønsted

Un **acide** est une espèce capable de céder un proton $\text{H}^{+}$. Une **base** est une espèce capable d''en capter un.

À tout acide correspond donc une base, celle qu''il devient après avoir cédé son proton. Les deux forment un **couple acide-base**, noté $\text{AH}/\text{A}^{-}$, relié par la demi-équation
$$\text{AH} \rightleftharpoons \text{A}^{-} + \text{H}^{+}$$

Quelques couples à connaître : $\text{CH}_{3}\text{COOH}/\text{CH}_{3}\text{COO}^{-}$, $\text{NH}_{4}^{+}/\text{NH}_{3}$, $\text{H}_{3}\text{O}^{+}/\text{H}_{2}\text{O}$ et $\text{H}_{2}\text{O}/\text{HO}^{-}$.

L''eau apparaît dans deux couples, en acide dans l''un et en base dans l''autre : c''est son caractère **amphotère**.

## La constante d''acidité

Pour le couple $\text{AH}/\text{A}^{-}$ en solution aqueuse, l''équilibre
$$\text{AH} + \text{H}_{2}\text{O} \rightleftharpoons \text{A}^{-} + \text{H}_{3}\text{O}^{+}$$
est caractérisé par
$$K_{a} = \dfrac{[\text{A}^{-}]\,[\text{H}_{3}\text{O}^{+}]}{[\text{AH}]}$$

Cette constante ne dépend que du couple et de la température. Elle ne dépend **ni de la concentration, ni du pH**. C''est ce qui en fait un outil si puissant.

Comme les valeurs sont minuscules, on utilise
$$\text{p}K_{a} = -\log K_{a}$$

Un $K_{a}$ **grand**, donc un $\text{p}K_{a}$ **petit**, signale un acide **fort**. Attention au sens, on s''y trompe souvent.

## La relation fondamentale

En prenant le logarithme de la définition, on obtient la relation la plus utile du module :
$$\text{pH} = \text{p}K_{a} + \log\dfrac{[\text{A}^{-}]}{[\text{AH}]}$$

Lis-la bien. Elle dit que le pH d''une solution dépend du couple présent et du **rapport** entre la forme basique et la forme acide.

Cas remarquable : quand $[\text{A}^{-}] = [\text{AH}]$, le logarithme s''annule et
$$\text{pH} = \text{p}K_{a}$$

C''est la **demi-équivalence** d''un dosage, et c''est ainsi qu''on mesure un $\text{p}K_{a}$ expérimentalement.

## Le diagramme de prédominance

De la relation précédente découle une règle simple et très visuelle.

Si $\text{pH} < \text{p}K_{a}$, la forme **acide** $\text{AH}$ est majoritaire.

Si $\text{pH} > \text{p}K_{a}$, la forme **basique** $\text{A}^{-}$ est majoritaire.

Si $\text{pH} = \text{p}K_{a}$, les deux sont en quantités égales.

On trace une droite graduée en pH, on marque le $\text{p}K_{a}$, et on écrit la forme acide à gauche, la forme basique à droite. C''est tout.

Pour l''acide éthanoïque, de $\text{p}K_{a} = 4{,}8$ : dans l''estomac à $\text{pH} = 2$, il est sous forme $\text{CH}_{3}\text{COOH}$. Dans le sang à $\text{pH} = 7{,}4$, il est sous forme $\text{CH}_{3}\text{COO}^{-}$.

## Exercice d''application

Une solution d''acide benzoïque $\text{C}_{6}\text{H}_{5}\text{COOH}$ de concentration $C_{a} = 1{,}0 \times 10^{-2}\ \text{mol}\cdot\text{L}^{-1}$ a un pH de $3{,}1$. Calcule le $K_{a}$ et le $\text{p}K_{a}$ de ce couple. Quelle espèce prédomine dans le sang, de pH $7{,}4$ ?

Correction. Calculons d''abord les concentrations.
$$[\text{H}_{3}\text{O}^{+}] = 10^{-3{,}1} = 7{,}94 \times 10^{-4}\ \text{mol}\cdot\text{L}^{-1}$$

Par électroneutralité, en négligeant les ions hydroxyde :
$$[\text{C}_{6}\text{H}_{5}\text{COO}^{-}] = 7{,}94 \times 10^{-4}\ \text{mol}\cdot\text{L}^{-1}$$

Par conservation de la matière :
$$[\text{C}_{6}\text{H}_{5}\text{COOH}] = 1{,}0 \times 10^{-2} - 7{,}94 \times 10^{-4} = 9{,}21 \times 10^{-3}\ \text{mol}\cdot\text{L}^{-1}$$

On applique la définition :
$$K_{a} = \dfrac{7{,}94 \times 10^{-4} \times 7{,}94 \times 10^{-4}}{9{,}21 \times 10^{-3}} = \dfrac{6{,}30 \times 10^{-7}}{9{,}21 \times 10^{-3}} = 6{,}85 \times 10^{-5}$$

D''où
$$\text{p}K_{a} = -\log(6{,}85 \times 10^{-5}) = 4{,}2$$

Dans le sang, $\text{pH} = 7{,}4$ est très supérieur au $\text{p}K_{a}$ de $4{,}2$. C''est donc la forme **basique**, l''ion benzoate $\text{C}_{6}\text{H}_{5}\text{COO}^{-}$, qui prédomine très largement.

C''est d''ailleurs pour cela que le benzoate de sodium, et non l''acide benzoïque, sert de conservateur alimentaire : il est bien plus soluble.', NULL, 15),
      (v_chapitre_id, 'Classer les couples et prévoir les réactions', 2, 'texte', 'Une fois les $\text{p}K_{a}$ connus, on peut prévoir quelle réaction se produit quand on mélange deux couples. C''est la **règle du gamma**, et elle ne se trompe jamais.

## L''échelle des pKa

On trace un axe vertical gradué en $\text{p}K_{a}$, orienté vers le haut. Sur chaque niveau, on écrit l''acide à gauche et sa base conjuguée à droite.

En bas, les $\text{p}K_{a}$ faibles : acides forts, bases très faibles.

En haut, les $\text{p}K_{a}$ élevés : acides très faibles, bases fortes.

Quelques repères utiles : $\text{H}_{3}\text{O}^{+}/\text{H}_{2}\text{O}$ à $\text{p}K_{a} = 0$, $\text{HCOOH}/\text{HCOO}^{-}$ à $3{,}8$, $\text{CH}_{3}\text{COOH}/\text{CH}_{3}\text{COO}^{-}$ à $4{,}8$, $\text{NH}_{4}^{+}/\text{NH}_{3}$ à $9{,}2$, $\text{C}_{2}\text{H}_{5}\text{NH}_{3}^{+}/\text{C}_{2}\text{H}_{5}\text{NH}_{2}$ à $10{,}7$, et $\text{H}_{2}\text{O}/\text{HO}^{-}$ à $14$.

## La règle du gamma

Mets deux couples en présence. La réaction qui se produit est celle entre l''**acide le plus fort** et la **base la plus forte**, c''est-à-dire entre l''acide du couple le plus **bas** et la base du couple le plus **haut**.

En traçant la flèche de l''acide du bas vers la base du haut, on dessine la lettre grecque gamma, d''où le nom.

Exemple. On mélange de l''acide éthanoïque, $\text{p}K_{a} = 4{,}8$, et de l''ammoniac, dont le couple est à $\text{p}K_{a} = 9{,}2$. L''acide du bas est $\text{CH}_{3}\text{COOH}$, la base du haut est $\text{NH}_{3}$. La réaction est donc
$$\text{CH}_{3}\text{COOH} + \text{NH}_{3} \longrightarrow \text{CH}_{3}\text{COO}^{-} + \text{NH}_{4}^{+}$$

## La constante de cette réaction

Pour une réaction entre l''acide 1 et la base 2, la constante d''équilibre vaut
$$K = \dfrac{K_{a1}}{K_{a2}} = 10^{\,\text{p}K_{a2} - \text{p}K_{a1}}$$

Plus l''écart des $\text{p}K_{a}$ est grand, plus $K$ est grand, et plus la réaction est **complète**.

En pratique, on considère la réaction comme **totale** si $K > 10^{4}$, c''est-à-dire si l''écart des $\text{p}K_{a}$ dépasse 4 unités.

Dans l''exemple précédent, $K = 10^{9{,}2 - 4{,}8} = 10^{4{,}4} \approx 2{,}5 \times 10^{4}$. La réaction est donc pratiquement totale.

## Le cas des acides et bases forts

Dans l''eau, tous les acides plus forts que $\text{H}_{3}\text{O}^{+}$ sont totalement transformés en $\text{H}_{3}\text{O}^{+}$. L''eau les ramène tous au même niveau, on dit qu''elle **nivelle** leur force.

De même, toutes les bases plus fortes que $\text{HO}^{-}$ sont ramenées à $\text{HO}^{-}$.

C''est pourquoi, en solution aqueuse, l''acide le plus fort possible est $\text{H}_{3}\text{O}^{+}$ et la base la plus forte est $\text{HO}^{-}$. On ne peut pas faire mieux dans l''eau.

## Exercice d''application

On mélange une solution d''acide méthanoïque, $\text{p}K_{a} = 3{,}8$, avec une solution d''éthanoate de sodium, dont le couple a un $\text{p}K_{a}$ de $4{,}8$. Écris la réaction qui se produit, calcule sa constante et dis si elle est totale.

Correction. Plaçons les deux couples. Le couple $\text{HCOOH}/\text{HCOO}^{-}$ est en bas, à $3{,}8$. Le couple $\text{CH}_{3}\text{COOH}/\text{CH}_{3}\text{COO}^{-}$ est au-dessus, à $4{,}8$.

La règle du gamma donne l''acide du bas, $\text{HCOOH}$, contre la base du haut, $\text{CH}_{3}\text{COO}^{-}$ :
$$\text{HCOOH} + \text{CH}_{3}\text{COO}^{-} \rightleftharpoons \text{HCOO}^{-} + \text{CH}_{3}\text{COOH}$$

La constante vaut
$$K = 10^{\,4{,}8 - 3{,}8} = 10^{1} = 10$$

Cette valeur est bien inférieure à $10^{4}$, donc la réaction n''est **pas totale**. Un équilibre s''établit, et les quatre espèces coexistent en quantités comparables.

C''est logique : les deux $\text{p}K_{a}$ sont proches, donc les deux acides ont des forces voisines, et aucun ne l''emporte vraiment sur l''autre.', NULL, 15),
      (v_chapitre_id, 'Applique la règle du gamma', 3, 'interactif', '{
  "widget": "regle-gamma",
  "consigne": "Choisis deux couples sur l''échelle des pKa et regarde la flèche se tracer. Lis l''équation de la réaction et sa constante. Trouve deux couples dont l''écart dépasse 4 unités : la réaction devient-elle totale ?"
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 9', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Un acide a un $\\text{p}K_a$ de 2,5, un autre de 9,0. Lequel est le plus fort ?",
      "choix": [
        "Celui de pKa 2,5",
        "Celui de pKa 9,0",
        "Ils sont aussi forts",
        "On ne peut pas savoir"
      ],
      "bonne": 0,
      "explication": "Un $\\text{p}K_a$ petit correspond à un $K_a$ grand, donc à un acide fort. L''acide de pKa 2,5 cède bien plus facilement son proton que celui de pKa 9,0."
    },
    {
      "question": "À la demi-équivalence d''un dosage d''acide faible, que vaut le pH ?",
      "choix": [
        "7",
        "$\\text{p}K_a$",
        "$\\text{p}K_a/2$",
        "14 − $\\text{p}K_a$"
      ],
      "bonne": 1,
      "explication": "À la demi-équivalence, la moitié de l''acide a réagi, donc $[\\text{A}^-] = [\\text{AH}]$. Le logarithme s''annule dans la relation $\\text{pH} = \\text{p}K_a + \\log([\\text{A}^-]/[\\text{AH}])$, et il reste $\\text{pH} = \\text{p}K_a$."
    },
    {
      "question": "Le couple $\\text{CH}_3\\text{COOH}/\\text{CH}_3\\text{COO}^-$ a un pKa de 4,8. Quelle espèce prédomine à pH 7 ?",
      "choix": [
        "L''acide éthanoïque",
        "L''ion éthanoate",
        "Les deux à égalité",
        "Ni l''un ni l''autre"
      ],
      "bonne": 1,
      "explication": "Le pH est supérieur au pKa, donc la forme basique domine. La règle est simple : au-dessus du pKa c''est la base, en dessous c''est l''acide."
    },
    {
      "question": "On mélange deux couples dont les pKa valent 3,0 et 9,0. Que vaut la constante de la réaction ?",
      "choix": [
        "$10^{-6}$",
        "$10^{6}$",
        "6",
        "$10^{12}$"
      ],
      "bonne": 1,
      "explication": "La constante vaut $10^{\\Delta \\text{p}K_a} = 10^{9{,}0 - 3{,}0} = 10^6$. Elle dépasse largement $10^4$, donc la réaction est pratiquement totale."
    },
    {
      "question": "De quoi dépend la constante d''acidité $K_a$ d''un couple ?",
      "choix": [
        "De la concentration de la solution",
        "Du pH de la solution",
        "Du couple et de la température seulement",
        "Du volume de la solution"
      ],
      "bonne": 2,
      "explication": "C''est précisément ce qui fait sa force : $K_a$ est une caractéristique du couple à une température donnée, et ne change pas quand on dilue ou qu''on modifie le pH."
    },
    {
      "question": "Pourquoi ne peut-on pas obtenir dans l''eau un acide plus fort que $\\text{H}_3\\text{O}^+$ ?",
      "choix": [
        "Parce que l''eau le détruit",
        "Parce que l''eau nivelle la force des acides forts",
        "Parce que $\\text{H}_3\\text{O}^+$ est le plus lourd",
        "Parce que l''eau est neutre"
      ],
      "bonne": 1,
      "explication": "Tout acide plus fort que l''ion oxonium réagit totalement avec l''eau et se transforme intégralement en $\\text{H}_3\\text{O}^+$. L''eau ramène donc tous ces acides au même niveau."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 9, Couples acide-base et constante d''acidité — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
