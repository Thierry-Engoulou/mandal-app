-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 14, Oxydoréduction en solution aqueuse
-- Module 4 : Oxydoréduction
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
    WHERE programme_id = v_programme_id AND ordre = 14;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Oxydoréduction en solution aqueuse', 14, 'Module 4 : Oxydoréduction')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 14 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 14 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Oxydant, réducteur et couple rédox', 1, 'texte', 'Plonge une lame de zinc dans une solution bleue de sulfate de cuivre. En quelques minutes, un dépôt rouge de cuivre recouvre la lame, et le bleu de la solution pâlit. Des électrons viennent de changer de propriétaire.

## Les deux définitions

Un **réducteur** est une espèce qui **cède** des électrons. Il est lui-même oxydé.

Un **oxydant** est une espèce qui **capte** des électrons. Il est lui-même réduit.

Le moyen mnémotechnique classique : le réducteur réduit l''autre et s''oxyde, l''oxydant oxyde l''autre et se réduit.

## Le couple oxydant-réducteur

À tout oxydant correspond le réducteur qu''il devient après avoir capté ses électrons. Les deux forment un **couple rédox**, noté $\text{Ox}/\text{Red}$, relié par une **demi-équation électronique** :
$$\text{Ox} + n\,\text{e}^{-} \rightleftharpoons \text{Red}$$

Attention à l''ordre d''écriture : l''**oxydant vient toujours en premier**, avant la barre.

Quelques couples à connaître : $\text{Cu}^{2+}/\text{Cu}$, $\text{Zn}^{2+}/\text{Zn}$, $\text{Fe}^{2+}/\text{Fe}$, $\text{H}^{+}/\text{H}_{2}$, $\text{Fe}^{3+}/\text{Fe}^{2+}$, $\text{MnO}_{4}^{-}/\text{Mn}^{2+}$ et $\text{Cr}_{2}\text{O}_{7}^{2-}/\text{Cr}^{3+}$.

## Équilibrer une demi-équation

C''est un geste technique à automatiser. Procède toujours dans cet ordre.

Tu équilibres d''abord l''élément principal, celui qui change de degré.

Tu équilibres ensuite les **oxygènes** en ajoutant des molécules d''eau du côté qui en manque.

Tu équilibres les **hydrogènes** en ajoutant des ions $\text{H}^{+}$.

Tu équilibres enfin les **charges** en ajoutant des électrons du côté le plus positif.

Prends le permanganate. On part de $\text{MnO}_{4}^{-} \rightleftharpoons \text{Mn}^{2+}$. Le manganèse est déjà équilibré. Il y a quatre oxygènes à gauche, donc on ajoute quatre eaux à droite. Cela fait huit hydrogènes à droite, donc on ajoute huit $\text{H}^{+}$ à gauche. Les charges valent alors $-1 + 8 = +7$ à gauche et $+2$ à droite : il faut cinq électrons à gauche.
$$\text{MnO}_{4}^{-} + 8\,\text{H}^{+} + 5\,\text{e}^{-} \rightleftharpoons \text{Mn}^{2+} + 4\,\text{H}_{2}\text{O}$$

## Construire l''équation bilan

Les électrons ne restent jamais libres en solution. Il faut donc multiplier les deux demi-équations pour qu''ils se compensent exactement, puis les additionner.

Les électrons doivent avoir **disparu** du bilan final. Si ce n''est pas le cas, c''est que tu t''es trompé.

## L''action d''un acide sur un métal

Beaucoup de métaux sont attaqués par les acides, avec dégagement de dihydrogène.
$$\text{Zn} + 2\,\text{H}^{+} \longrightarrow \text{Zn}^{2+} + \text{H}_{2}$$

Le métal joue le réducteur, l''ion $\text{H}^{+}$ joue l''oxydant.

Mais tous les métaux ne réagissent pas. Le cuivre, l''argent et l''or ne sont **pas** attaqués par l''acide chlorhydrique, même concentré. On dit qu''ils sont placés après l''hydrogène dans la classification.

Ce simple test permet donc de classer un métal par rapport à l''hydrogène.

## Exercice d''application

On plonge une lame de fer dans une solution de sulfate de cuivre. Un dépôt rouge apparaît. Écris les deux demi-équations et l''équation bilan. Que se passerait-il en plongeant une lame de cuivre dans une solution de sulfate de fer ?

Correction. Le dépôt rouge est du cuivre métallique, donc les ions $\text{Cu}^{2+}$ ont été réduits.

Demi-équation de réduction, pour le couple $\text{Cu}^{2+}/\text{Cu}$ :
$$\text{Cu}^{2+} + 2\,\text{e}^{-} \longrightarrow \text{Cu}$$

Demi-équation d''oxydation, pour le couple $\text{Fe}^{2+}/\text{Fe}$ :
$$\text{Fe} \longrightarrow \text{Fe}^{2+} + 2\,\text{e}^{-}$$

Les deux demi-équations échangent le même nombre d''électrons, on peut donc les additionner directement :
$$\text{Fe} + \text{Cu}^{2+} \longrightarrow \text{Fe}^{2+} + \text{Cu}$$

La solution, initialement bleue à cause des ions cuivre, verdit à mesure que les ions fer apparaissent.

Dans l''autre sens, en plongeant du cuivre dans une solution de sulfate de fer, **rien ne se passe**. Le cuivre est un réducteur plus faible que le fer : il n''arrive pas à céder ses électrons aux ions $\text{Fe}^{2+}$.

Une réaction d''oxydoréduction spontanée ne se produit donc que dans un seul sens, et c''est la classification des couples qui dit lequel.', NULL, 15),
      (v_chapitre_id, 'Teste les métaux les uns contre les autres', 2, 'interactif', '{
  "widget": "redox-metal",
  "consigne": "Plonge un métal dans une solution d''ions métalliques et regarde ce qui se passe. Essaie le zinc dans le cuivre, puis le cuivre dans le zinc. Classe ensuite les métaux du plus réducteur au moins réducteur, et vérifie ton classement."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 14', 3, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qu''un réducteur ?",
      "choix": [
        "Une espèce qui capte des électrons",
        "Une espèce qui cède des électrons",
        "Une espèce qui capte des protons",
        "Une espèce qui ne réagit pas"
      ],
      "bonne": 1,
      "explication": "Le réducteur cède ses électrons à l''oxydant. Il réduit donc l''autre espèce, et s''oxyde lui-même au passage."
    },
    {
      "question": "Dans la demi-équation du permanganate, combien d''électrons sont échangés ?",
      "choix": [
        "2",
        "3",
        "5",
        "8"
      ],
      "bonne": 2,
      "explication": "La demi-équation s''écrit $\\text{MnO}_4^- + 8\\text{H}^+ + 5\\text{e}^- \\rightarrow \\text{Mn}^{2+} + 4\\text{H}_2\\text{O}$. On trouve 5 en équilibrant les charges : $-1 + 8 = +7$ à gauche contre $+2$ à droite."
    },
    {
      "question": "Pourquoi le cuivre n''est-il pas attaqué par l''acide chlorhydrique ?",
      "choix": [
        "Il est trop dur",
        "C''est un réducteur plus faible que le dihydrogène",
        "Il est recouvert d''une couche protectrice",
        "L''acide est trop dilué"
      ],
      "bonne": 1,
      "explication": "Le cuivre se situe après l''hydrogène dans la classification des couples. Il ne parvient pas à céder ses électrons aux ions $\\text{H}^+$, donc aucune réaction ne se produit."
    },
    {
      "question": "Dans l''équation bilan finale d''une réaction rédox, que doivent devenir les électrons ?",
      "choix": [
        "Ils apparaissent à gauche",
        "Ils apparaissent à droite",
        "Ils doivent avoir disparu",
        "Il en reste toujours un"
      ],
      "bonne": 2,
      "explication": "Les électrons cédés par le réducteur sont exactement ceux captés par l''oxydant. Après multiplication et addition des deux demi-équations, ils se compensent et disparaissent du bilan."
    },
    {
      "question": "On plonge une lame de zinc dans du sulfate de cuivre. Qu''observe-t-on ?",
      "choix": [
        "Rien",
        "Un dépôt rouge et la solution qui se décolore",
        "Un dégagement gazeux",
        "Un précipité blanc"
      ],
      "bonne": 1,
      "explication": "Le zinc, plus réducteur, cède ses électrons aux ions cuivre qui se déposent sous forme de cuivre métallique rouge. La solution perd sa couleur bleue en perdant ses ions $\\text{Cu}^{2+}$."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 14, Oxydoréduction en solution aqueuse — 3 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
