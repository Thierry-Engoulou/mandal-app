-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 12, Les facteurs cinétiques
-- Module 3 : Cinétique chimique
-- 3 leçons.
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
    WHERE programme_id = v_programme_id AND ordre = 12;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les facteurs cinétiques', 12, 'Module 3 : Cinétique chimique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 12 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 12 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les cinq facteurs cinétiques', 1, 'texte', 'Un facteur cinétique est une grandeur qui modifie la **vitesse** d''une réaction sans changer son état final. Il y en a cinq à connaître.

## La concentration des réactifs

Plus les réactifs sont concentrés, plus la réaction est rapide.

L''explication est microscopique : pour réagir, deux molécules doivent se rencontrer. Plus elles sont nombreuses dans un même volume, plus les chocs sont fréquents, donc plus la réaction avance vite.

Conséquence pratique : la **dilution ralentit** une réaction, ce qui est le principe de la trempe.

## La température

C''est le facteur le plus puissant. Une règle empirique dit qu''une élévation de **dix degrés double** la vitesse d''une réaction courante.

L''explication tient en deux points. D''abord, à haute température les molécules vont plus vite, donc se heurtent plus souvent. Ensuite, et surtout, leurs chocs sont plus violents : une plus grande proportion d''entre eux dispose de l''énergie nécessaire pour casser les liaisons. Ce sont les **chocs efficaces**.

Applications de tous les jours : la cocotte-minute cuit plus vite parce qu''elle monte en température, et le réfrigérateur conserve les aliments parce que le froid ralentit les réactions de dégradation.

## Le catalyseur

Un **catalyseur** accélère une réaction sans être consommé. On le retrouve intact à la fin, et il n''apparaît donc pas dans l''équation bilan.

Il agit en ouvrant un **chemin réactionnel différent**, qui demande moins d''énergie pour démarrer.

Point capital : un catalyseur **ne déplace pas l''équilibre**. Il fait arriver plus vite au même état final. C''est la question piège par excellence, en estérification notamment.

On distingue trois sortes. La catalyse est **homogène** quand le catalyseur est dans la même phase que les réactifs, comme l''acide sulfurique en estérification. Elle est **hétérogène** quand il est dans une phase différente, comme le platine solide pour des gaz. Elle est **enzymatique** quand le catalyseur est une enzyme : ce sont les plus efficaces et les plus sélectives, et elles font fonctionner tout ton organisme.

## La surface de contact

Pour une réaction entre un solide et une solution, seule la surface du solide réagit.

En divisant le solide, on augmente énormément cette surface, donc la vitesse. Le zinc en poudre réagit bien plus vite que le même zinc en bille.

C''est aussi pourquoi la farine en suspension dans l''air peut exploser dans un silo, alors qu''un sac de farine ne brûle que lentement.

## Le solvant

Le choix du solvant change la vitesse, parce qu''il modifie la façon dont les molécules se rencontrent et se stabilisent. Ce facteur est le moins exploité au lycée, mais il faut savoir le citer.

## Facteur cinétique ou facteur d''équilibre

Voici la distinction à ne jamais perdre de vue.

Un **facteur cinétique** change la vitesse, donc le temps mis pour arriver à l''état final. La température, le catalyseur, la surface de contact en font partie.

Un **facteur d''équilibre** change l''état final lui-même, donc le rendement. Les quantités initiales et l''élimination d''un produit en font partie.

La concentration est le seul qui joue parfois sur les deux.

## Exercice d''application

On fait réagir du calcaire $\text{CaCO}_{3}$ avec de l''acide chlorhydrique. On réalise quatre expériences, toutes avec la même masse de calcaire et la même quantité d''acide.

Expérience 1 : calcaire en gros morceaux, acide à $1\ \text{mol}\cdot\text{L}^{-1}$, à $20\ °\text{C}$.
Expérience 2 : calcaire en poudre, acide à $1\ \text{mol}\cdot\text{L}^{-1}$, à $20\ °\text{C}$.
Expérience 3 : calcaire en gros morceaux, acide à $2\ \text{mol}\cdot\text{L}^{-1}$, à $20\ °\text{C}$.
Expérience 4 : calcaire en gros morceaux, acide à $1\ \text{mol}\cdot\text{L}^{-1}$, à $40\ °\text{C}$.

Classe ces expériences de la plus lente à la plus rapide, en justifiant. Le volume final de dioxyde de carbone sera-t-il le même dans les quatre cas ?

Correction. L''expérience 1 est la référence, avec les conditions les moins favorables sur les trois facteurs : elle est la **plus lente**.

L''expérience 3 double la concentration, ce qui double à peu près la fréquence des chocs : elle est plus rapide que la 1.

L''expérience 4 augmente la température de $20\ °\text{C}$, donc double la vitesse deux fois de suite, soit un facteur 4 environ : elle est plus rapide que la 3.

L''expérience 2 utilise de la poudre, ce qui multiplie la surface de contact par un facteur énorme, souvent plusieurs centaines : c''est la **plus rapide**.

Le classement est donc 1, puis 3, puis 4, puis 2.

Quant au volume de gaz, il sera **le même dans les quatre cas**. Les quantités de réactifs sont identiques, donc l''avancement final aussi. Seul le temps mis pour y arriver change. C''est toute la différence entre cinétique et thermodynamique.', NULL, 15),
      (v_chapitre_id, 'Joue sur les facteurs cinétiques', 2, 'interactif', '{
  "widget": "facteurs-cinetiques",
  "consigne": "Règle la température, la concentration et la présence d''un catalyseur, puis lance la réaction. Compare les courbes obtenues. Vérifie le point essentiel : la courbe monte plus ou moins vite, mais arrive-t-elle toujours au même palier ?"
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 12', 3, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "On ajoute un catalyseur à une réaction limitée. Que devient le rendement final ?",
      "choix": [
        "Il augmente",
        "Il diminue",
        "Il ne change pas",
        "Il devient 100 %"
      ],
      "bonne": 2,
      "explication": "Un catalyseur est un facteur cinétique : il accélère l''arrivée à l''état final sans le déplacer. Le rendement reste exactement le même, seul le temps change."
    },
    {
      "question": "Pourquoi une élévation de température accélère-t-elle une réaction ?",
      "choix": [
        "Les molécules deviennent plus grosses",
        "Les chocs sont plus fréquents et surtout plus souvent efficaces",
        "La concentration augmente",
        "Le volume diminue"
      ],
      "bonne": 1,
      "explication": "À haute température les molécules se déplacent plus vite, donc se heurtent plus souvent, et surtout une plus grande proportion de chocs dispose de l''énergie nécessaire pour casser les liaisons."
    },
    {
      "question": "Pourquoi le zinc en poudre réagit-il plus vite que le zinc en bille ?",
      "choix": [
        "Il est plus pur",
        "Sa surface de contact avec la solution est bien plus grande",
        "Il est plus léger",
        "Il est plus chaud"
      ],
      "bonne": 1,
      "explication": "Pour une réaction solide-solution, seule la surface réagit. Diviser le solide multiplie cette surface par un facteur considérable, donc la vitesse aussi."
    },
    {
      "question": "Qu''est-ce qui distingue un facteur cinétique d''un facteur d''équilibre ?",
      "choix": [
        "Rien, c''est pareil",
        "Le facteur cinétique change la vitesse, le facteur d''équilibre change l''état final",
        "Le facteur cinétique agit seulement à chaud",
        "Le facteur d''équilibre agit seulement en solution"
      ],
      "bonne": 1,
      "explication": "Un facteur cinétique modifie le temps mis pour atteindre l''état final. Un facteur d''équilibre modifie cet état final lui-même, donc le rendement."
    },
    {
      "question": "Un catalyseur apparaît-il dans l''équation bilan ?",
      "choix": [
        "Oui, comme réactif",
        "Oui, comme produit",
        "Non, il est retrouvé intact à la fin",
        "Seulement en catalyse enzymatique"
      ],
      "bonne": 2,
      "explication": "Le catalyseur participe au mécanisme mais il est régénéré, donc sa quantité ne change pas. On le note parfois au-dessus de la flèche, jamais dans le bilan."
    },
    {
      "question": "Pourquoi conserve-t-on les aliments au réfrigérateur ?",
      "choix": [
        "Le froid tue toutes les bactéries",
        "Le froid ralentit les réactions de dégradation",
        "Le froid augmente la concentration",
        "Le froid est un catalyseur"
      ],
      "bonne": 1,
      "explication": "La température est un facteur cinétique. En abaissant la température, on ralentit fortement toutes les réactions chimiques et biochimiques de dégradation, sans pour autant les arrêter."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 12, Les facteurs cinétiques — 3 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
