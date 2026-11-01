-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 3, Les dérivés des acides carboxyliques
-- Module 1 : Chimie organique
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
    WHERE programme_id = v_programme_id AND ordre = 3;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les dérivés des acides carboxyliques', 3, 'Module 1 : Chimie organique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 3 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 3 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les quatre dérivés et leur nomenclature', 1, 'texte', 'À partir d''un acide carboxylique, on fabrique quatre familles de composés en remplaçant le groupe $\text{OH}$ par autre chose. Ce sont les **dérivés d''acide**.

## Le tableau des quatre familles

L''**ester** s''obtient en remplaçant $\text{OH}$ par $\text{OR}''$. Sa formule est $\text{R}-\text{COO}-\text{R}''$.

Le **chlorure d''acyle** s''obtient en remplaçant $\text{OH}$ par $\text{Cl}$. Sa formule est $\text{R}-\text{COCl}$.

L''**anhydride d''acide** résulte de la perte d''une molécule d''eau entre deux acides. Sa formule est $\text{R}-\text{CO}-\text{O}-\text{CO}-\text{R}$.

L''**amide** s''obtient en remplaçant $\text{OH}$ par $\text{NH}_{2}$. Sa formule est $\text{R}-\text{CO}-\text{NH}_{2}$.

## Comment les nommer

Pour un **ester**, le nom se fait en deux parties. On prend le nom de l''acide, on remplace « acide …oïque » par « …oate », puis on ajoute « de » suivi du nom du groupe $\text{R}''$ venu de l''alcool.

Ainsi $\text{CH}_{3}-\text{COO}-\text{CH}_{2}-\text{CH}_{3}$ est l''**éthanoate d''éthyle**. Le premier mot vient de l''acide, le second de l''alcool. Ne les inverse jamais.

Pour un **chlorure d''acyle**, on dit « chlorure de … oyle ». Ainsi $\text{CH}_{3}-\text{COCl}$ est le chlorure d''éthanoyle.

Pour un **anhydride**, on dit « anhydride …oïque ». Ainsi $(\text{CH}_{3}\text{CO})_{2}\text{O}$ est l''anhydride éthanoïque.

Pour un **amide**, on remplace « acide …oïque » par « …amide ». Ainsi $\text{CH}_{3}-\text{CO}-\text{NH}_{2}$ est l''éthanamide.

## À quoi servent les esters

Les esters ont presque tous une odeur agréable et fruitée. Ce sont eux qui donnent son parfum à la banane, à l''ananas, au jasmin. L''industrie alimentaire et la parfumerie en font un grand usage.

Les corps gras, huile de palme comme beurre de karité, sont des esters du glycérol avec des acides à longue chaîne.

## Exercice d''application

Donne le nom et la formule semi-développée de l''ester formé entre l''acide propanoïque et le méthanol. Quelle est sa masse molaire ?

Correction. L''acide propanoïque est $\text{CH}_{3}-\text{CH}_{2}-\text{COOH}$ et le méthanol est $\text{CH}_{3}-\text{OH}$.

L''estérification remplace le $\text{OH}$ de l''acide par le $\text{OCH}_{3}$ venu de l''alcool :
$$\text{CH}_{3}-\text{CH}_{2}-\text{COO}-\text{CH}_{3}$$

Le nom vient d''abord de l''acide, « propanoate », puis de l''alcool, « de méthyle ». C''est donc le **propanoate de méthyle**.

Sa formule brute est $\text{C}_{4}\text{H}_{8}\text{O}_{2}$, de masse molaire
$$M = 4 \times 12 + 8 \times 1 + 2 \times 16 = 48 + 8 + 32 = 88\ \text{g}\cdot\text{mol}^{-1}$$', NULL, 15),
      (v_chapitre_id, 'L''estérification et l''hydrolyse', 2, 'texte', 'Voici la réaction la plus importante du chapitre, et l''une des rares du programme qui soit **limitée par un équilibre**. Cette particularité est au cœur de beaucoup d''exercices.

## La réaction d''estérification

Un acide carboxylique et un alcool chauffés ensemble donnent un ester et de l''eau :
$$\text{R}-\text{COOH} + \text{R}''-\text{OH} \rightleftharpoons \text{R}-\text{COO}-\text{R}'' + \text{H}_{2}\text{O}$$

Retiens ses trois caractères, c''est une question d''examen classique.

Elle est **lente**. Sans rien faire, il faut des jours pour atteindre l''équilibre.

Elle est **limitée**, c''est-à-dire qu''elle n''est jamais totale. Il reste toujours de l''acide et de l''alcool dans le mélange final.

Elle est **athermique**, c''est-à-dire qu''elle n''échange pratiquement pas de chaleur avec l''extérieur.

La réaction inverse, l''**hydrolyse** de l''ester, se produit en même temps et possède exactement les trois mêmes caractères.

## Les rendements à l''équilibre

Si l''on part d''une mole d''acide et d''une mole d''alcool, le rendement à l''équilibre ne dépend que de la **classe de l''alcool**.

Avec un alcool **primaire**, le rendement vaut environ $67\%$.

Avec un alcool **secondaire**, il tombe à environ $60\%$.

Avec un alcool **tertiaire**, il s''effondre à environ $5\%$. L''encombrement autour du carbone fonctionnel gêne la réaction.

Ces nombres sont à connaître.

## Comment déplacer l''équilibre

Puisque la réaction est limitée, on cherche à la pousser vers l''ester. Deux leviers seulement.

**Mettre un réactif en excès.** En doublant la quantité d''alcool, on consomme davantage d''acide. On calcule alors le rendement par rapport au réactif limitant.

**Éliminer un produit au fur et à mesure.** On distille l''ester s''il est volatil, ou on piège l''eau avec un déshydratant.

Ce qui ne marche **pas** : chauffer davantage ou ajouter un catalyseur. Ces deux actions accélèrent l''arrivée à l''équilibre, mais ne changent pas du tout sa position. C''est le piège le plus fréquent de l''examen.

Le catalyseur habituel est l''acide sulfurique concentré, en quelques gouttes.

## Les dérivés réagissent mieux que l''acide

Pour obtenir un ester avec un bon rendement, on n''utilise pas l''acide, mais un de ses dérivés.

Avec un **chlorure d''acyle**, la réaction est **rapide et totale** :
$$\text{R}-\text{COCl} + \text{R}''-\text{OH} \longrightarrow \text{R}-\text{COO}-\text{R}'' + \text{HCl}$$

Avec un **anhydride d''acide**, elle est également rapide et totale :
$$(\text{R}-\text{CO})_{2}\text{O} + \text{R}''-\text{OH} \longrightarrow \text{R}-\text{COO}-\text{R}'' + \text{R}-\text{COOH}$$

Le chlorure d''acyle est plus efficace mais dégage du chlorure d''hydrogène, un gaz corrosif. L''anhydride est plus doux à manipuler.

Retiens le contraste : acide plus alcool donne lent, limité, athermique ; chlorure d''acyle plus alcool donne rapide, total, exothermique.

## La saponification

L''hydrolyse d''un ester par une **base forte** est, elle, totale :
$$\text{R}-\text{COO}-\text{R}'' + \text{Na}^{+} + \text{HO}^{-} \longrightarrow \text{R}-\text{COO}^{-}\text{Na}^{+} + \text{R}''-\text{OH}$$

Elle est totale parce que l''ion hydroxyde capture l''acide formé sous forme de carboxylate, ce qui empêche la réaction inverse.

Appliquée à un corps gras, elle donne du **savon**. C''est le procédé utilisé depuis des siècles, et toujours dans les savonneries de Douala : on chauffe de l''huile de palme avec de la soude, et on récupère le savon et le glycérol.

## Exercice d''application

On chauffe un mélange de $0{,}50$ mol d''acide éthanoïque et $0{,}50$ mol de butan-1-ol en présence de quelques gouttes d''acide sulfurique. À l''équilibre, il s''est formé $0{,}335$ mol d''ester. Calcule le rendement. Que se passerait-il si on avait utilisé $1{,}0$ mol d''alcool au lieu de $0{,}50$ ? Et si on avait simplement chauffé plus fort ?

Correction. Le rendement est le rapport entre l''ester obtenu et l''ester qu''on obtiendrait si la réaction était totale. Les réactifs étant en quantités égales, le maximum théorique est $0{,}50$ mol.
$$r = \dfrac{0{,}335}{0{,}50} = 0{,}67$$

soit un rendement de $67\%$. C''est bien la valeur attendue, puisque le butan-1-ol est un alcool **primaire**.

Avec $1{,}0$ mol d''alcool, l''alcool est en excès. L''équilibre se déplace dans le sens de la formation de l''ester, et le rendement calculé par rapport à l''acide, désormais limitant, **augmente** nettement. On dépasserait $80\%$.

En chauffant simplement plus fort, l''équilibre serait atteint **plus vite**, mais au même endroit. Le rendement resterait de $67\%$. La température est un facteur cinétique, pas un facteur d''équilibre pour cette réaction athermique.', NULL, 15),
      (v_chapitre_id, 'Déplace l''équilibre d''estérification', 3, 'interactif', '{
  "widget": "esterification-equilibre",
  "consigne": "Choisis la classe de l''alcool et les quantités de départ, puis regarde l''équilibre s''installer. Vérifie les rendements de 67 %, 60 % et 5 %. Mets ensuite un réactif en excès : le rendement bouge. Augmente la température : il ne bouge pas. Pourquoi ?"
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 3', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Comment se nomme l''ester $\\text{CH}_3-\\text{COO}-\\text{CH}_2-\\text{CH}_3$ ?",
      "choix": [
        "Éthanoate d''éthyle",
        "Propanoate de méthyle",
        "Éthanoate de méthyle",
        "Butanoate d''éthyle"
      ],
      "bonne": 0,
      "explication": "Le premier mot vient de l''acide, ici l''acide éthanoïque, d''où « éthanoate ». Le second vient de l''alcool, ici l''éthanol, d''où « d''éthyle »."
    },
    {
      "question": "Quels sont les trois caractères de la réaction d''estérification ?",
      "choix": [
        "Rapide, totale, exothermique",
        "Lente, limitée, athermique",
        "Rapide, limitée, endothermique",
        "Lente, totale, athermique"
      ],
      "bonne": 1,
      "explication": "L''estérification entre un acide et un alcool est lente, limitée par un équilibre, et athermique. C''est précisément pourquoi on lui préfère un chlorure d''acyle quand on veut un bon rendement."
    },
    {
      "question": "On chauffe davantage un mélange d''estérification. Que devient le rendement à l''équilibre ?",
      "choix": [
        "Il augmente",
        "Il diminue",
        "Il ne change pas",
        "La réaction s''arrête"
      ],
      "bonne": 2,
      "explication": "La température est un facteur cinétique : elle fait arriver plus vite à l''équilibre, mais ne déplace pas sa position, car la réaction est athermique. C''est le piège classique de l''examen."
    },
    {
      "question": "Quel rendement attend-on en partant de quantités égales d''acide et d''un alcool tertiaire ?",
      "choix": [
        "Environ 5 %",
        "Environ 60 %",
        "Environ 67 %",
        "100 %"
      ],
      "bonne": 0,
      "explication": "L''encombrement autour du carbone fonctionnel d''un alcool tertiaire gêne fortement la réaction. Le rendement s''effondre à environ 5 %, contre 67 % pour un alcool primaire."
    },
    {
      "question": "Pourquoi la saponification d''un ester est-elle totale, alors que son hydrolyse par l''eau est limitée ?",
      "choix": [
        "Parce qu''on chauffe plus fort",
        "Parce que l''ion hydroxyde capture l''acide sous forme de carboxylate",
        "Parce que le savon est solide",
        "Parce que la base est un catalyseur"
      ],
      "bonne": 1,
      "explication": "L''acide formé est immédiatement transformé en ion carboxylate par la base. Il ne peut donc plus réagir en sens inverse, et la réaction est poussée jusqu''au bout."
    },
    {
      "question": "Pour obtenir un ester rapidement et avec un rendement de 100 %, on fait réagir l''alcool avec :",
      "choix": [
        "l''acide carboxylique",
        "un chlorure d''acyle",
        "de l''eau",
        "une base forte"
      ],
      "bonne": 1,
      "explication": "La réaction entre un chlorure d''acyle et un alcool est rapide et totale, contrairement à l''estérification classique. Elle dégage en revanche du chlorure d''hydrogène, un gaz corrosif."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 3, Les dérivés des acides carboxyliques — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
