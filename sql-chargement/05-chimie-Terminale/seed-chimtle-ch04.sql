-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 4, Les amines
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
    WHERE programme_id = v_programme_id AND ordre = 4;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les amines', 4, 'Module 1 : Chimie organique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 4 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 4 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Reconnaître et nommer une amine', 1, 'texte', 'L''odeur du poisson qui n''est plus frais, c''est celle des amines. Ces molécules dérivent de l''ammoniac $\text{NH}_{3}$ : on remplace un, deux ou trois de ses hydrogènes par des groupes carbonés.

## Les trois classes

Attention, la classe d''une amine ne se détermine pas comme celle d''un alcool. Ici, on compte les carbones liés à l''**azote**, pas à un carbone.

Une amine est **primaire** si l''azote porte un seul groupe carboné : $\text{R}-\text{NH}_{2}$. Exemple, l''éthanamine $\text{CH}_{3}-\text{CH}_{2}-\text{NH}_{2}$.

Elle est **secondaire** si l''azote en porte deux : $\text{R}-\text{NH}-\text{R}''$. Exemple, la N-méthyléthanamine.

Elle est **tertiaire** si l''azote en porte trois : $\text{R}-\text{N}(\text{R}'')-\text{R}''''$.

Ne confonds pas avec les alcools. Le 2-méthylpropan-2-amine $(\text{CH}_{3})_{3}\text{C}-\text{NH}_{2}$ est une amine **primaire**, parce que son azote ne porte qu''un seul carbone, même si ce carbone est lui-même entouré de trois autres.

## La nomenclature

Pour une amine primaire, on prend le nom de l''alcane et on remplace le $-e$ final par **-amine**, en indiquant la position de l''azote.

Ainsi $\text{CH}_{3}-\text{NH}_{2}$ est la méthanamine, $\text{CH}_{3}-\text{CH}_{2}-\text{CH}_{2}-\text{NH}_{2}$ la propan-1-amine.

Pour une amine secondaire ou tertiaire, on nomme la chaîne la plus longue, et on place les autres groupes en préfixes précédés de la lettre **N**, qui signifie qu''ils sont portés par l''azote.

Ainsi $\text{CH}_{3}-\text{NH}-\text{CH}_{2}-\text{CH}_{3}$ est la N-méthyléthanamine.

## Les propriétés physiques

Les amines primaires et secondaires forment des liaisons hydrogène, mais plus faibles que celles des alcools, car l''azote est moins électronégatif que l''oxygène. Elles bouillent donc entre les alcanes et les alcools.

Les amines tertiaires n''ont plus d''hydrogène sur l''azote, donc aucune liaison hydrogène entre elles. Elles bouillent nettement plus bas.

Les premiers termes sont des gaz à odeur ammoniacale. Au-delà, l''odeur devient celle du poisson avarié.

## Exercice d''application

Une amine saturée à chaîne ouverte a une masse molaire de $59\ \text{g}\cdot\text{mol}^{-1}$. Détermine sa formule brute, puis donne et nomme ses isomères en précisant leur classe. On donne $\text{C} : 12$, $\text{H} : 1$, $\text{N} : 14$.

Correction. La formule générale d''une amine saturée est $\text{C}_{n}\text{H}_{2n+3}\text{N}$, de masse molaire $14n + 17$.

On résout $14n + 17 = 59$, donc $14n = 42$ et $n = 3$. L''amine est en $\text{C}_{3}\text{H}_{9}\text{N}$.

Il faut maintenant répartir trois carbones autour de l''azote.

Avec les trois carbones en chaîne et l''azote au bout, on a la **propan-1-amine**, $\text{CH}_{3}-\text{CH}_{2}-\text{CH}_{2}-\text{NH}_{2}$, primaire.

Avec l''azote sur le carbone du milieu, on a la **propan-2-amine**, $(\text{CH}_{3})_{2}\text{CH}-\text{NH}_{2}$, primaire elle aussi.

Avec deux groupes sur l''azote, on a la **N-méthyléthanamine**, $\text{CH}_{3}-\text{NH}-\text{CH}_{2}-\text{CH}_{3}$, secondaire.

Avec trois groupes sur l''azote, on a la **N,N-diméthylméthanamine**, $(\text{CH}_{3})_{3}\text{N}$, tertiaire.

Il y a donc quatre isomères : deux primaires, une secondaire et une tertiaire.', NULL, 15),
      (v_chapitre_id, 'Les propriétés chimiques des amines', 2, 'texte', 'Toutes les propriétés des amines viennent d''une même cause : le **doublet libre** porté par l''azote. Ce doublet cherche à se lier à quelque chose, et c''est ce qui rend l''amine à la fois basique et nucléophile.

## L''amine est une base faible

Dans l''eau, l''amine capte un proton :
$$\text{R}-\text{NH}_{2} + \text{H}_{2}\text{O} \rightleftharpoons \text{R}-\text{NH}_{3}^{+} + \text{HO}^{-}$$

La solution devient **basique**, et le papier pH humide bleuit. C''est le test le plus simple.

L''ion $\text{R}-\text{NH}_{3}^{+}$ s''appelle un ion **alkylammonium**. Le couple acide-base est $\text{R}-\text{NH}_{3}^{+}/\text{R}-\text{NH}_{2}$, et son $\text{p}K_{a}$ vaut typiquement entre $10$ et $11$. Pour l''éthanamine, $\text{p}K_{a} = 10{,}7$.

Attention au sens de lecture. Dans ce couple, l''**acide** est l''ion ammonium, et la **base** est l''amine. C''est une inversion par rapport aux acides carboxyliques, où l''acide porte le nom de la famille.

Une amine est une base plus forte que l''ammoniac, parce que les groupes carbonés enrichissent l''azote en électrons et rendent son doublet plus disponible.

## La réaction avec les acides

Avec un acide fort, la réaction est totale et donne un sel solide :
$$\text{R}-\text{NH}_{2} + \text{HCl} \longrightarrow \text{R}-\text{NH}_{3}^{+} + \text{Cl}^{-}$$

Ce sel, le chlorure d''alkylammonium, est bien plus soluble dans l''eau que l''amine de départ. C''est ainsi qu''on formule beaucoup de médicaments : sous forme de sel, pour qu''ils se dissolvent.

## L''amine est nucléophile

Le même doublet permet à l''amine d''attaquer les carbones pauvres en électrons. C''est de là que vient toute la suite.

Avec un **chlorure d''acyle**, la réaction est rapide et totale et donne un **amide** :
$$\text{R}-\text{COCl} + 2\,\text{R}''-\text{NH}_{2} \longrightarrow \text{R}-\text{CO}-\text{NH}-\text{R}'' + \text{R}''-\text{NH}_{3}^{+} + \text{Cl}^{-}$$

Il faut **deux** moles d''amine pour une de chlorure : la première forme l''amide, la seconde neutralise le chlorure d''hydrogène dégagé. C''est une erreur de stœchiométrie très fréquente.

Avec un **anhydride d''acide**, on obtient aussi un amide, de façon rapide et totale.

Avec un **acide carboxylique**, la réaction donne d''abord un simple sel. Il faut chauffer fortement pour obtenir l''amide, et le rendement reste médiocre. On lui préfère donc toujours un dérivé.

## Exercice d''application

On dispose de $4{,}5$ g d''éthanamine, que l''on fait réagir avec un excès de chlorure d''éthanoyle. Écris l''équation, nomme le produit organique obtenu et calcule sa masse, en supposant la réaction totale. On donne $\text{C} : 12$, $\text{H} : 1$, $\text{N} : 14$, $\text{O} : 16$.

Correction. L''éthanamine est $\text{CH}_{3}-\text{CH}_{2}-\text{NH}_{2}$, de masse molaire
$$M = 2 \times 12 + 7 \times 1 + 14 = 24 + 7 + 14 = 45\ \text{g}\cdot\text{mol}^{-1}$$

La quantité de matière vaut donc $n = \dfrac{4{,}5}{45} = 0{,}10$ mol.

L''équation s''écrit
$$\text{CH}_{3}-\text{COCl} + 2\,\text{CH}_{3}-\text{CH}_{2}-\text{NH}_{2} \longrightarrow \text{CH}_{3}-\text{CO}-\text{NH}-\text{CH}_{2}-\text{CH}_{3} + \text{CH}_{3}-\text{CH}_{2}-\text{NH}_{3}^{+} + \text{Cl}^{-}$$

Le produit organique est la **N-éthyléthanamide**.

Attention à la stœchiométrie : deux moles d''amine donnent **une** mole d''amide. Avec $0{,}10$ mol d''amine, on obtient donc $0{,}050$ mol d''amide.

La masse molaire de l''amide $\text{C}_{4}\text{H}_{9}\text{NO}$ vaut
$$M = 4 \times 12 + 9 \times 1 + 14 + 16 = 48 + 9 + 14 + 16 = 87\ \text{g}\cdot\text{mol}^{-1}$$

La masse obtenue vaut donc
$$m = 0{,}050 \times 87 = 4{,}35\ \text{g}$$', NULL, 15),
      (v_chapitre_id, 'Compare la force des bases azotées', 3, 'interactif', '{
  "widget": "echelle-pka",
  "consigne": "Place les couples des amines sur l''échelle et compare-les à l''ammoniac. Une amine est-elle une base plus forte ou plus faible que l''ammoniac ? Cherche ensuite où se situe l''ion éthanoate par rapport à l''éthanamine."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 4', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la classe de l''amine $(\\text{CH}_3)_3\\text{C}-\\text{NH}_2$ ?",
      "choix": [
        "Primaire",
        "Secondaire",
        "Tertiaire",
        "Ce n''est pas une amine"
      ],
      "bonne": 0,
      "explication": "Pour une amine, on compte les carbones liés à l''azote, et non au carbone fonctionnel. Ici l''azote ne porte qu''un seul groupe carboné, donc l''amine est primaire, même si ce carbone est très ramifié."
    },
    {
      "question": "On plonge du papier pH humide dans une solution d''éthanamine. Que se passe-t-il ?",
      "choix": [
        "Il rougit",
        "Il bleuit",
        "Il ne change pas",
        "Il se décolore"
      ],
      "bonne": 1,
      "explication": "L''amine capte un proton à l''eau et libère des ions hydroxyde, donc la solution est basique et le papier bleuit. C''est le test le plus simple pour reconnaître une amine."
    },
    {
      "question": "Dans le couple $\\text{R}-\\text{NH}_3^+/\\text{R}-\\text{NH}_2$, qui est l''acide ?",
      "choix": [
        "L''amine $\\text{R}-\\text{NH}_2$",
        "L''ion ammonium $\\text{R}-\\text{NH}_3^+$",
        "Les deux",
        "Aucun des deux"
      ],
      "bonne": 1,
      "explication": "L''acide est l''espèce qui peut céder un proton, donc l''ion alkylammonium. L''amine, qui peut en capter un, est la base. C''est l''inverse des acides carboxyliques, où l''acide porte le nom de la famille."
    },
    {
      "question": "Combien faut-il de moles d''amine primaire pour transformer une mole de chlorure d''acyle en amide ?",
      "choix": [
        "Une demi-mole",
        "Une mole",
        "Deux moles",
        "Trois moles"
      ],
      "bonne": 2,
      "explication": "La première mole forme l''amide, la seconde neutralise le chlorure d''hydrogène dégagé. Oublier cette seconde mole est l''erreur de stœchiométrie la plus fréquente du chapitre."
    },
    {
      "question": "D''où viennent à la fois la basicité et le caractère nucléophile des amines ?",
      "choix": [
        "De la chaîne carbonée",
        "Du doublet libre de l''azote",
        "Des hydrogènes",
        "De la masse molaire"
      ],
      "bonne": 1,
      "explication": "Le doublet non liant de l''azote peut capter un proton, ce qui rend l''amine basique, ou attaquer un carbone pauvre en électrons, ce qui la rend nucléophile. Une seule cause, deux conséquences."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 4, Les amines — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
