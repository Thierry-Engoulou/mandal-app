-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 19, Niveaux d''énergie de l''atome d''hydrogène
-- Module 4 : Ondes, matière et transformations nucléaires
-- 4 leçons.
--
-- Ce fichier remplit LES DEUX CLASSES a la fois : Terminale C et Terminale D.
-- Autonome : il cree lui-meme la matiere, les classes, les programmes et le
-- chapitre s'ils n'existent pas encore. Lancez-le seul, dans n'importe quel
-- ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $ptc$
DECLARE
  v_noms text[] := ARRAY['Terminale C', 'Terminale D'];
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
  -- la matiere, une seule fois
  INSERT INTO public.matieres (nom) VALUES ('Physique') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Physique';

  -- l'etablissement, deduit de la table des classes
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- on refait le meme travail pour la Terminale C puis pour la Terminale D
  FOR v_i IN 1..2 LOOP
    v_nom := v_noms[v_i];
    v_lettre := v_lettres[v_i];

    -- 1. le programme existe-t-il deja ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Physique — ' || v_nom;

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
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Physique — ' || v_nom,
              'Programme officiel de Physique, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 4 modules, 22 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme "Physique — %" cree.', v_nom;
    END IF;

    -- 3. le chapitre existe-t-il deja ?
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 19;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Niveaux d''énergie de l''atome d''hydrogène', 19, 'Module 4 : Ondes, matière et transformations nucléaires')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 19 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 19 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les spectres atomiques', 1, 'texte', 'Chauffe un gaz et regarde sa lumière à travers un prisme. Tu ne vois pas un arc-en-ciel continu, mais quelques raies colorées bien séparées. Chaque élément a sa propre signature.

## Le spectre continu

Un solide ou un liquide porté à haute température émet un spectre **continu** : toutes les longueurs d''onde y sont présentes, sans interruption.

C''est le cas du filament d''une lampe, du fer chauffé au rouge, ou du Soleil vu globalement.

La couleur dominante dépend de la température. Plus le corps est chaud, plus le maximum se déplace vers le bleu.

## Le spectre de raies d''émission

Un gaz à basse pression, excité par une décharge électrique, émet un spectre de **raies**. Sur fond noir apparaissent quelques raies colorées fines, à des longueurs d''onde bien précises.

Ces longueurs d''onde sont **caractéristiques de l''élément**. Le sodium donne un doublet jaune très intense, c''est pourquoi les anciens lampadaires étaient jaunes. L''hydrogène donne quatre raies visibles, une rouge, une bleu-vert, et deux violettes.

C''est une véritable carte d''identité. En analysant la lumière d''une étoile, on sait de quels éléments elle est faite sans jamais y aller.

## Le spectre d''absorption

Fais maintenant traverser un gaz froid par une lumière blanche. Le spectre obtenu est continu, mais barré de **raies noires**.

Et voici le fait remarquable : ces raies noires se trouvent exactement aux longueurs d''onde que ce même gaz émettrait s''il était chaud.

Un atome absorbe donc précisément les radiations qu''il est capable d''émettre. C''est cette observation qui a conduit au modèle des niveaux d''énergie.

Le spectre du Soleil présente ainsi des milliers de raies sombres, dites raies de Fraunhofer, dues aux gaz plus froids de son atmosphère.

## Exercice d''application

Le spectre d''une étoile présente des raies sombres à $589{,}0$ nm et $589{,}6$ nm. Sachant que le sodium chauffé émet un doublet à ces deux longueurs d''onde exactement, que peux-tu conclure ?

Correction. Les raies sombres observées correspondent à des radiations absorbées par un gaz froid situé entre la source chaude et nous.

Comme leurs longueurs d''onde coïncident exactement avec le doublet d''émission du sodium, c''est que l''atmosphère de cette étoile contient du **sodium**.

Cette méthode, l''analyse spectrale, est le principal outil des astronomes pour déterminer la composition chimique des astres. Elle a d''ailleurs permis de découvrir l''hélium dans le Soleil avant de le trouver sur Terre, d''où son nom venu du grec helios.', NULL, 15),
      (v_chapitre_id, 'Les postulats de Bohr et les niveaux d''énergie', 2, 'texte', 'Pourquoi un atome n''émet-il que certaines couleurs, et pas toutes ? Bohr a répondu en 1913, en posant une idée révolutionnaire : l''énergie de l''atome ne peut prendre que certaines valeurs.

## Les postulats de Bohr

**Premier postulat.** L''énergie d''un atome est **quantifiée**. Elle ne peut prendre qu''une suite de valeurs discrètes $E_{1}, E_{2}, E_{3}, \ldots$, appelées niveaux d''énergie. Entre ces valeurs, rien n''existe.

Le niveau le plus bas est l''**état fondamental**, c''est l''état stable de l''atome. Les autres sont des **états excités**, où l''atome ne reste qu''un instant très bref.

**Deuxième postulat.** Lorsque l''atome passe d''un niveau $E_{p}$ à un niveau $E_{n}$ plus bas, il émet un photon dont l''énergie vaut exactement la différence :
$$E_{p} - E_{n} = h\,\nu = \dfrac{h\,c}{\lambda}$$

La constante de Planck vaut $h = 6{,}63 \times 10^{-34}$ J·s.

C''est cette relation qui explique tout. Comme les niveaux sont en nombre limité, les transitions possibles le sont aussi, et donc les longueurs d''onde émises également. D''où les raies.

## Le cas de l''atome d''hydrogène

Pour l''hydrogène, les niveaux sont donnés par
$$E_{n} = -\dfrac{13{,}6}{n^{2}}\ \text{eV}$$
où $n$ est un entier non nul appelé nombre quantique principal.

L''électronvolt vaut $1\ \text{eV} = 1{,}6 \times 10^{-19}$ J.

Le niveau fondamental correspond à $n = 1$ et vaut $E_{1} = -13{,}6$ eV.

Les suivants valent $E_{2} = -3{,}40$ eV, $E_{3} = -1{,}51$ eV, $E_{4} = -0{,}85$ eV, et ainsi de suite.

Quand $n$ tend vers l''infini, $E_{n}$ tend vers zéro. L''électron est alors libre, l''atome est **ionisé**.

## Pourquoi les énergies sont négatives

Par convention, on prend l''énergie nulle quand l''électron est infiniment loin du noyau et au repos.

Un électron lié a donc une énergie **négative** : il faut lui fournir de l''énergie pour l''arracher.

L''**énergie d''ionisation** depuis le niveau fondamental vaut donc $0 - (-13{,}6) = 13{,}6$ eV.

## Émission et absorption

L''atome **émet** un photon quand il descend d''un niveau haut vers un niveau bas.

Il **absorbe** un photon quand il monte, mais à une condition stricte : l''énergie du photon doit correspondre **exactement** à un écart entre deux niveaux. Un photon d''énergie intermédiaire passe sans être absorbé.

C''est pourquoi le spectre d''absorption a exactement les mêmes raies que le spectre d''émission.

## Les séries de raies

Les transitions qui aboutissent au niveau $n = 1$ forment la **série de Lyman**, dans l''ultraviolet.

Celles qui aboutissent au niveau $n = 2$ forment la **série de Balmer**, et ce sont les seules visibles à l''œil nu.

Celles qui aboutissent au niveau $n = 3$ forment la série de Paschen, dans l''infrarouge.

## Exercice d''application

Calcule la longueur d''onde du photon émis lorsqu''un atome d''hydrogène passe du niveau $n = 3$ au niveau $n = 2$. On donne $h = 6{,}63 \times 10^{-34}$ J·s et $c = 3{,}00 \times 10^{8}$ m/s.

Correction. Les deux niveaux valent
$$E_{3} = -\dfrac{13{,}6}{9} = -1{,}51\ \text{eV} \qquad E_{2} = -\dfrac{13{,}6}{4} = -3{,}40\ \text{eV}$$

La différence vaut
$$\Delta E = E_{3} - E_{2} = -1{,}51 - (-3{,}40) = 1{,}89\ \text{eV}$$

Convertissons en joules :
$$\Delta E = 1{,}89 \times 1{,}6 \times 10^{-19} = 3{,}024 \times 10^{-19}\ \text{J}$$

La longueur d''onde vaut
$$\lambda = \dfrac{h\,c}{\Delta E} = \dfrac{6{,}63 \times 10^{-34} \times 3{,}00 \times 10^{8}}{3{,}024 \times 10^{-19}}$$

Le numérateur vaut $1{,}989 \times 10^{-25}$, donc
$$\lambda = \dfrac{1{,}989 \times 10^{-25}}{3{,}024 \times 10^{-19}} \approx 6{,}58 \times 10^{-7}\ \text{m} = 658\ \text{nm}$$

C''est la raie **rouge** de l''hydrogène, bien connue sous le nom de raie H-alpha. C''est elle qui donne leur couleur rouge aux nébuleuses photographiées par les télescopes.', NULL, 15),
      (v_chapitre_id, 'Fais sauter l''électron de niveau en niveau', 3, 'interactif', '{
  "widget": "niveaux-hydrogene",
  "consigne": "Clique sur deux niveaux pour provoquer une transition, et lis l''énergie et la longueur d''onde du photon. Trouve la transition qui donne la raie rouge visible. Cherche ensuite l''énergie minimale à fournir pour ioniser l''atome depuis son état fondamental."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 19', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Pourquoi un gaz excité n''émet-il que certaines longueurs d''onde ?",
      "choix": [
        "Parce que les autres sont absorbées",
        "Parce que son énergie est quantifiée, donc les transitions possibles sont en nombre limité",
        "Parce que le gaz est à basse pression",
        "Parce que l''œil ne voit pas les autres"
      ],
      "bonne": 1,
      "explication": "L''énergie de l''atome ne peut prendre que des valeurs discrètes. Les écarts entre niveaux sont donc eux aussi en nombre fini, et chaque écart donne une longueur d''onde bien précise."
    },
    {
      "question": "Que vaut l''énergie d''ionisation de l''atome d''hydrogène depuis son état fondamental ?",
      "choix": [
        "3,40 eV",
        "13,6 eV",
        "1,51 eV",
        "0 eV"
      ],
      "bonne": 1,
      "explication": "Le niveau fondamental vaut $-13{,}6$ eV et l''électron est libre quand l''énergie atteint 0. Il faut donc fournir $0 - (-13{,}6) = 13{,}6$ eV pour l''arracher."
    },
    {
      "question": "Pourquoi les niveaux d''énergie d''un atome sont-ils négatifs ?",
      "choix": [
        "À cause de la charge de l''électron",
        "Parce qu''on prend l''énergie nulle quand l''électron est libre et infiniment loin",
        "Parce que l''atome perd de l''énergie",
        "C''est une erreur de convention"
      ],
      "bonne": 1,
      "explication": "Le zéro est fixé pour un électron libre au repos. Un électron lié est donc dans un état d''énergie plus basse, donc négative, et il faut lui apporter de l''énergie pour le libérer."
    },
    {
      "question": "Un photon d''énergie 2,00 eV rencontre un atome d''hydrogène dans son état fondamental. Que se passe-t-il ?",
      "choix": [
        "Il est absorbé et l''atome monte au niveau 2",
        "Il n''est pas absorbé car aucune transition ne correspond",
        "Il ionise l''atome",
        "Il est absorbé puis réémis identique"
      ],
      "bonne": 1,
      "explication": "La première transition possible depuis $n=1$ demande $13{,}6 - 3{,}40 = 10{,}2$ eV. Un photon de 2,00 eV ne correspond à aucun écart de niveaux, il traverse donc l''atome sans être absorbé."
    },
    {
      "question": "Les raies sombres du spectre du Soleil correspondent :",
      "choix": [
        "à des éléments absents",
        "aux longueurs d''onde absorbées par les gaz plus froids de son atmosphère",
        "à des défauts de l''instrument",
        "à des zones sans lumière"
      ],
      "bonne": 1,
      "explication": "Les gaz de l''atmosphère solaire absorbent précisément les longueurs d''onde qu''ils émettraient s''ils étaient chauds. Ces raies de Fraunhofer révèlent donc la composition chimique du Soleil."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 19, Niveaux d''énergie de l''atome d''hydrogène — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
