-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 5, Les acides α-aminés et les peptides
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
    WHERE programme_id = v_programme_id AND ordre = 5;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les acides α-aminés et les peptides', 5, 'Module 1 : Chimie organique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 5 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 5 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les acides α-aminés', 1, 'texte', 'Toutes les protéines de ton corps sont faites à partir de vingt petites molécules seulement. Ce sont les acides α-aminés, et ils ont une particularité : ils portent deux fonctions opposées sur la même molécule.

## La structure générale

Un acide α-aminé porte un groupe carboxyle et un groupe amine sur le **même carbone**, celui qu''on appelle le carbone $\alpha$ parce qu''il est voisin immédiat du carboxyle.
$$\text{R}-\text{CH}(\text{NH}_{2})-\text{COOH}$$

Le groupe $\text{R}$ s''appelle le **radical** ou la chaîne latérale. C''est lui seul qui distingue un acide aminé d''un autre.

Si $\text{R} = \text{H}$, on a la **glycine**, le plus simple. Si $\text{R} = \text{CH}_{3}$, on a l''**alanine**, de nom systématique acide 2-aminopropanoïque.

## La nomenclature

On nomme l''acide carboxylique correspondant, et on ajoute le préfixe **amino-** avec l''indice de position, toujours 2 pour un acide α-aminé.

Ainsi $\text{CH}_{3}-\text{CH}(\text{NH}_{2})-\text{COOH}$ est l''acide 2-aminopropanoïque.

## Le zwitterion, ou amphion

Voici la propriété la plus importante du chapitre. Dans la molécule, le groupe carboxyle est acide et le groupe amine est basique. Ils réagissent donc **entre eux**, à l''intérieur de la même molécule :
$$\text{R}-\text{CH}(\text{NH}_{2})-\text{COOH} \longrightarrow \text{R}-\text{CH}(\text{NH}_{3}^{+})-\text{COO}^{-}$$

L''espèce obtenue porte une charge positive et une charge négative. On l''appelle **zwitterion** ou **amphion**. Sa charge globale est nulle, mais elle n''est pas neutre pour autant : c''est un ion double.

C''est cette structure qui explique pourquoi les acides aminés sont des **solides** à haut point de fusion, très solubles dans l''eau, alors que leur masse molaire est petite. Ils se comportent comme des sels.

En solution, le zwitterion est la forme majoritaire autour de la neutralité.

## Le caractère amphotère

Un acide aminé peut réagir **en acide comme en base**, on dit qu''il est amphotère.

En **milieu acide**, le carboxylate capte un proton et la molécule devient un **cation** :
$$\text{R}-\text{CH}(\text{NH}_{3}^{+})-\text{COOH}$$

En **milieu basique**, l''ammonium cède son proton et la molécule devient un **anion** :
$$\text{R}-\text{CH}(\text{NH}_{2})-\text{COO}^{-}$$

Il existe donc trois formes, et c''est le pH qui décide laquelle domine. Le pH pour lequel le zwitterion est majoritaire et la charge moyenne nulle s''appelle le **point isoélectrique**, noté $\text{pH}_{i}$.

## La chiralité

Regarde le carbone $\alpha$ de l''alanine. Il porte quatre groupes différents : $\text{H}$, $\text{CH}_{3}$, $\text{NH}_{2}$ et $\text{COOH}$. C''est donc un **carbone asymétrique**, et la molécule est **chirale**.

Elle existe sous deux formes qui sont images l''une de l''autre dans un miroir sans être superposables : ce sont deux **énantiomères**, notés D et L.

Tous les acides α-aminés sont chiraux, **sauf la glycine**, dont le carbone α porte deux hydrogènes. C''est l''exception à connaître.

Fait remarquable : les protéines des êtres vivants n''utilisent que la série **L**.

## Exercice d''application

Un acide α-aminé a pour formule brute $\text{C}_{4}\text{H}_{9}\text{NO}_{2}$. Donne ses formules semi-développées possibles, nomme-les, et dis lesquelles sont chirales.

Correction. La structure générale est $\text{R}-\text{CH}(\text{NH}_{2})-\text{COOH}$. Le squelette $\text{CH}(\text{NH}_{2})-\text{COOH}$ compte deux carbones, donc il reste deux carbones pour le radical $\text{R}$.

Avec $\text{R} = \text{CH}_{3}-\text{CH}_{2}-$, on obtient
$$\text{CH}_{3}-\text{CH}_{2}-\text{CH}(\text{NH}_{2})-\text{COOH}$$
soit l''**acide 2-aminobutanoïque**. Son carbone α porte $\text{H}$, $\text{COOH}$, $\text{NH}_{2}$ et un groupe éthyle : quatre groupes différents, donc la molécule est **chirale**.

Avec $\text{R} = (\text{CH}_{3})_{2}\text{CH}-$, le radical occuperait trois carbones, ce qui est trop. En revanche on peut ramifier autrement :
$$(\text{CH}_{3})_{2}\text{C}(\text{NH}_{2})-\text{COOH}$$
soit l''**acide 2-amino-2-méthylpropanoïque**. Ici le carbone α porte deux méthyles identiques, donc il n''est **pas** asymétrique et la molécule n''est **pas chirale**.

Il y a donc deux isomères α-aminés, dont un seul est chiral.', NULL, 15),
      (v_chapitre_id, 'Change le pH et observe les trois formes', 2, 'interactif', '{
  "widget": "acide-amine-ph",
  "consigne": "Fais glisser le pH et regarde laquelle des trois formes domine : cation, zwitterion ou anion. Trouve le point isoélectrique, celui où le zwitterion est majoritaire. Que vaut alors la charge moyenne de la molécule ?"
}', NULL, 10),
      (v_chapitre_id, 'La liaison peptidique et les peptides', 3, 'texte', 'Mis bout à bout, les acides aminés forment les protéines. Le lien qui les attache s''appelle la liaison peptidique, et il se fait toujours de la même façon.

## La formation de la liaison

Le groupe carboxyle d''un acide aminé réagit avec le groupe amine d''un autre, en perdant une molécule d''eau :
$$\text{R}-\text{CH}(\text{NH}_{2})-\text{COOH} + \text{H}_{2}\text{N}-\text{CH}(\text{R}'')-\text{COOH} \longrightarrow \text{R}-\text{CH}(\text{NH}_{2})-\text{CO}-\text{NH}-\text{CH}(\text{R}'')-\text{COOH} + \text{H}_{2}\text{O}$$

Le groupe $-\text{CO}-\text{NH}-$ qui apparaît est la **liaison peptidique**. C''est en réalité une fonction amide.

Le produit s''appelle un **dipeptide**. Avec trois acides aminés on a un tripeptide, au-delà un polypeptide, et à partir d''une centaine une **protéine**.

## Le vocabulaire des extrémités

Un peptide a toujours deux bouts différents.

L''extrémité **N-terminale** porte le groupe amine libre. On l''écrit toujours à **gauche**.

L''extrémité **C-terminale** porte le groupe carboxyle libre. On l''écrit toujours à **droite**.

Cette convention est importante, car elle décide du nom.

## Combien de dipeptides avec deux acides aminés différents

C''est la question classique. Avec deux acides aminés différents $A$ et $B$, on peut former **quatre** dipeptides.

Deux font intervenir un seul acide aminé : $A$-$A$ et $B$-$B$.

Deux font intervenir les deux, mais dans un ordre différent : $A$-$B$ et $B$-$A$. Ce sont bien deux molécules distinctes, car la liaison peptidique n''est pas symétrique.

De façon générale, avec $n$ acides aminés différents, on peut former $n^{2}$ dipeptides, et $n^{k}$ peptides à $k$ résidus.

## Nommer un dipeptide

On nomme les résidus de gauche à droite, c''est-à-dire du N-terminal vers le C-terminal. Tous les résidus sauf le dernier prennent la terminaison **-yl**.

Ainsi, le dipeptide formé par le carboxyle de la glycine et l''amine de l''alanine s''appelle **glycylalanine**, et on l''écrit Gly-Ala.

Celui formé dans l''autre sens s''appelle **alanylglycine**, écrit Ala-Gly. Ce n''est pas la même molécule.

## L''hydrolyse

Chauffé en milieu acide ou basique, un peptide se coupe à l''inverse : chaque liaison peptidique fixe une molécule d''eau et libère les acides aminés.

C''est exactement ce que fait ta digestion, avec des enzymes qui remplacent le chauffage.

## Exercice d''application

On dispose de glycine, de formule $\text{H}_{2}\text{N}-\text{CH}_{2}-\text{COOH}$, et d''alanine, de formule $\text{CH}_{3}-\text{CH}(\text{NH}_{2})-\text{COOH}$. Combien de dipeptides différents peut-on former ? Écris la formule semi-développée et le nom de celui dont l''extrémité N-terminale est l''alanine et l''extrémité C-terminale la glycine.

Correction. Avec deux acides aminés différents, on peut former $2^{2} = 4$ dipeptides : Gly-Gly, Ala-Ala, Gly-Ala et Ala-Gly.

Pour le dipeptide demandé, l''alanine est à gauche avec son amine libre, la glycine à droite avec son carboxyle libre. La liaison se fait donc entre le **carboxyle de l''alanine** et l''**amine de la glycine** :
$$\text{CH}_{3}-\text{CH}(\text{NH}_{2})-\text{CO}-\text{NH}-\text{CH}_{2}-\text{COOH}$$

Son nom est **alanylglycine**, ou Ala-Gly.

Vérifie bien le sens : si tu avais relié le carboxyle de la glycine à l''amine de l''alanine, tu aurais obtenu la glycylalanine, qui est une molécule différente.', NULL, 15),
      (v_chapitre_id, 'Quiz du chapitre 5', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qu''un zwitterion ?",
      "choix": [
        "Une molécule sans charge",
        "Une molécule portant une charge + et une charge − à la fois",
        "Un ion négatif",
        "Un acide fort"
      ],
      "bonne": 1,
      "explication": "Dans un acide aminé, le carboxyle cède son proton à l''amine de la même molécule. Il en résulte un ion double, de charge globale nulle mais porteur de deux charges opposées."
    },
    {
      "question": "Quel acide α-aminé n''est pas chiral ?",
      "choix": [
        "L''alanine",
        "La glycine",
        "L''acide 2-aminobutanoïque",
        "Tous le sont"
      ],
      "bonne": 1,
      "explication": "La glycine a pour radical un simple hydrogène, donc son carbone α porte deux hydrogènes identiques. Il n''est pas asymétrique, et la molécule n''est pas chirale. C''est l''exception à retenir."
    },
    {
      "question": "En milieu fortement basique, un acide α-aminé se trouve principalement sous forme :",
      "choix": [
        "de cation",
        "de zwitterion",
        "d''anion",
        "de molécule neutre non ionisée"
      ],
      "bonne": 2,
      "explication": "La base arrache le proton de l''ion ammonium. Il ne reste alors que la charge négative du carboxylate, donc la molécule est un anion."
    },
    {
      "question": "Combien de dipeptides différents peut-on former avec trois acides aminés différents ?",
      "choix": [
        "3",
        "6",
        "9",
        "27"
      ],
      "bonne": 2,
      "explication": "Chaque position du dipeptide peut être occupée par l''un des trois acides aminés, donc $3^2 = 9$ dipeptides. L''ordre compte, car la liaison peptidique n''est pas symétrique."
    },
    {
      "question": "Quel groupe d''atomes constitue la liaison peptidique ?",
      "choix": [
        "$-\\text{COOH}$",
        "$-\\text{CO}-\\text{NH}-$",
        "$-\\text{NH}_2$",
        "$-\\text{COO}^-$"
      ],
      "bonne": 1,
      "explication": "La liaison peptidique est le groupe $-\\text{CO}-\\text{NH}-$, qui est en fait une fonction amide. Elle se forme par élimination d''une molécule d''eau entre un carboxyle et une amine."
    },
    {
      "question": "Pourquoi les acides aminés sont-ils solides et très solubles dans l''eau malgré leur petite masse molaire ?",
      "choix": [
        "Parce qu''ils contiennent de l''azote",
        "Parce qu''ils existent sous forme de zwitterions, donc se comportent comme des sels",
        "Parce qu''ils sont chiraux",
        "Parce qu''ils sont acides"
      ],
      "bonne": 1,
      "explication": "Le zwitterion porte deux charges, ce qui crée de fortes attractions électriques entre molécules. L''acide aminé se comporte donc comme un sel : solide, haut point de fusion, très soluble dans l''eau."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 5, Les acides α-aminés et les peptides — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
