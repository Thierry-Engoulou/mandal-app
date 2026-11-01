-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 17, Aspect ondulatoire de la lumière
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
    WHERE programme_id = v_programme_id AND ordre = 17;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Aspect ondulatoire de la lumière', 17, 'Module 4 : Ondes, matière et transformations nucléaires')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 17 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 17 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'La diffraction de la lumière', 1, 'texte', 'Si la lumière était faite de petites billes allant en ligne droite, elle ne pourrait pas contourner un obstacle. Pourtant elle le fait, et cette observation a changé la physique.

## L''expérience

Éclaire une fente très fine avec un faisceau laser et place un écran derrière. Au lieu d''un simple trait lumineux de la largeur de la fente, tu observes une **tache centrale large** entourée de taches secondaires plus faibles, séparées par des zones sombres.

La lumière s''est étalée. C''est la **diffraction**.

Le phénomène est d''autant plus marqué que la fente est **étroite**. C''est contre-intuitif : plus on ferme l''ouverture, plus la lumière s''élargit.

## La condition de diffraction

La diffraction devient sensible quand la dimension de l''ouverture ou de l''obstacle est du même ordre de grandeur que la longueur d''onde.

Pour la lumière visible, $\lambda$ vaut entre $400$ et $800$ nm. Il faut donc des fentes de l''ordre du micromètre, ce qui explique qu''on ne voie pas la lumière contourner une porte.

Pour le son, en revanche, $\lambda$ vaut de quelques centimètres à quelques mètres. Le son contourne donc facilement les murs et les portes, et c''est pourquoi tu entends une conversation dans la pièce voisine sans voir les gens.

## L''écart angulaire

Le demi-angle $\theta$ sous lequel on voit la tache centrale depuis la fente vérifie
$$\theta = \dfrac{\lambda}{a}$$
où $a$ est la largeur de la fente et $\theta$ est en radians, dans l''approximation des petits angles.

Si l''écran est à la distance $D$, la **largeur totale de la tache centrale** vaut
$$L = 2D\theta = \dfrac{2\lambda D}{a}$$

Retiens le facteur 2 : la tache centrale est deux fois plus large que l''écart entre le centre et la première extinction.

## Ce que cela prouve

La diffraction est le propre des **ondes**. Les ondes sonores diffractent, les ondes à la surface de l''eau diffractent, et la lumière diffracte aussi.

C''est donc une preuve directe de la nature ondulatoire de la lumière. Le modèle du rayon lumineux rectiligne, suffisant en optique géométrique, cesse d''être valable dès que les dimensions deviennent petites.

## Exercice d''application

Un laser de longueur d''onde $\lambda = 633$ nm éclaire une fente de largeur $a = 0{,}10$ mm. L''écran est à $D = 2{,}0$ m. Calcule l''écart angulaire et la largeur de la tache centrale. Que se passe-t-il si on divise la largeur de la fente par deux ?

Correction. L''écart angulaire vaut
$$\theta = \dfrac{\lambda}{a} = \dfrac{633 \times 10^{-9}}{0{,}10 \times 10^{-3}} = \dfrac{6{,}33 \times 10^{-7}}{1{,}0 \times 10^{-4}} = 6{,}33 \times 10^{-3}\ \text{rad}$$

La largeur de la tache centrale vaut
$$L = \dfrac{2\lambda D}{a} = 2 \times 6{,}33 \times 10^{-3} \times 2{,}0 = 2{,}5 \times 10^{-2}\ \text{m}$$

soit environ $2{,}5$ cm. Une fente d''un dixième de millimètre produit donc une tache de deux centimètres et demi.

Si on divise $a$ par deux, $L$ est multipliée par deux et la tache atteint $5{,}1$ cm. Plus la fente est étroite, plus la lumière s''étale.', NULL, 15),
      (v_chapitre_id, 'Les interférences lumineuses et les fentes de Young', 2, 'texte', 'En 1801, Thomas Young fit passer de la lumière par deux fentes très proches. Sur l''écran, il obtint une alternance de bandes claires et sombres. La lumière additionnée à la lumière pouvait donner du noir.

## Le dispositif

Une source monochromatique éclaire une fente source, puis deux fentes fines $S_{1}$ et $S_{2}$, parallèles, distantes de $a$. Un écran est placé à la distance $D$, avec $D$ très grande devant $a$.

La fente source unique est indispensable : elle garantit que $S_{1}$ et $S_{2}$ se comportent comme deux sources **cohérentes**, puisqu''elles reçoivent la même lumière.

## La différence de marche

Soit $M$ un point de l''écran à la distance $x$ du centre. On démontre que la différence de marche vaut
$$\delta = d_{2} - d_{1} = \dfrac{a\,x}{D}$$

Cette formule n''est valable que dans l''approximation des petits angles, c''est-à-dire tant que $x$ et $a$ restent très petits devant $D$. C''est toujours le cas en pratique.

## Franges brillantes et franges sombres

La **frange est brillante** quand les deux ondes arrivent en phase :
$$\delta = k\,\lambda \qquad \text{donc} \qquad x_{k} = k\,\dfrac{\lambda D}{a}$$

La **frange est sombre** quand elles arrivent en opposition de phase :
$$\delta = \left(k + \dfrac{1}{2}\right)\lambda \qquad \text{donc} \qquad x_{k} = \left(k + \dfrac{1}{2}\right)\dfrac{\lambda D}{a}$$

Au centre de l''écran, $x = 0$ donc $\delta = 0$ : il y a toujours une frange brillante, appelée **frange centrale**.

## L''interfrange

L''**interfrange** $i$ est la distance entre deux franges brillantes consécutives, ou entre deux franges sombres consécutives.
$$i = \dfrac{\lambda\,D}{a}$$

C''est la formule la plus importante du chapitre. Elle permet de mesurer une longueur d''onde avec une simple règle, puisque
$$\lambda = \dfrac{i\,a}{D}$$

Pour obtenir des franges bien visibles, il faut un grand interfrange, donc un écran éloigné et des fentes très rapprochées.

Dans la pratique, on mesure la largeur de $n$ interfranges d''un coup et on divise par $n$. L''incertitude est ainsi divisée par $n$, comme tu l''as vu au chapitre sur les incertitudes.

## L''influence d''une lame à faces parallèles

Si l''on place une lame transparente d''épaisseur $e$ et d''indice $n$ devant une seule des deux fentes, la lumière y circule plus lentement. La différence de marche est augmentée de $(n-1)e$, et tout le système de franges se **déplace** du côté de la lame, sans que l''interfrange change.

De même, si l''on déplace la source principale d''un côté, les franges se déplacent du côté opposé.

## Les interférences en lumière blanche

La lumière blanche contient toutes les longueurs d''onde du visible. Chaque couleur donne son propre système de franges, avec son propre interfrange, puisque $i$ est proportionnel à $\lambda$.

Au centre, $\delta = 0$ pour toutes les couleurs à la fois : la frange centrale est donc **blanche**.

Juste à côté, les systèmes se décalent progressivement et on observe quelques franges **irisées**, aux couleurs de l''arc-en-ciel, le violet étant le plus près du centre puisque sa longueur d''onde est la plus courte.

Plus loin, les systèmes se chevauchent tellement que tout se mélange et redonne du **blanc d''ordre supérieur**, un blanc sale traversé de quelques raies sombres.

La frange centrale blanche est donc le moyen le plus simple de repérer le centre exact d''une figure d''interférences.

## Exercice d''application

Dans une expérience de Young, les fentes sont distantes de $a = 0{,}50$ mm et l''écran est à $D = 2{,}0$ m. On mesure une largeur de $12{,}6$ mm pour $5$ interfranges. Calcule l''interfrange puis la longueur d''onde. De quelle couleur est cette lumière ?

Correction. L''interfrange vaut
$$i = \dfrac{12{,}6}{5} = 2{,}52\ \text{mm} = 2{,}52 \times 10^{-3}\ \text{m}$$

La longueur d''onde vaut
$$\lambda = \dfrac{i\,a}{D} = \dfrac{2{,}52 \times 10^{-3} \times 0{,}50 \times 10^{-3}}{2{,}0}$$

Le numérateur vaut $1{,}26 \times 10^{-6}$, donc
$$\lambda = \dfrac{1{,}26 \times 10^{-6}}{2{,}0} = 6{,}3 \times 10^{-7}\ \text{m} = 630\ \text{nm}$$

Une longueur d''onde de $630$ nm correspond au **rouge**. Il s''agit très probablement d''un laser hélium-néon, dont la raie caractéristique est à $633$ nm.', NULL, 15),
      (v_chapitre_id, 'Reproduis l''expérience de Young', 3, 'interactif', '{
  "widget": "fentes-young",
  "consigne": "Change l''écartement des fentes, la distance de l''écran et la longueur d''onde, et regarde les franges se resserrer ou s''écarter. Trouve le réglage qui donne l''interfrange le plus grand. Passe ensuite en lumière blanche : quelle couleur se trouve le plus près du centre ?"
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 17', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "On rétrécit la fente dans une expérience de diffraction. Que devient la tache centrale ?",
      "choix": [
        "Elle rétrécit aussi",
        "Elle s''élargit",
        "Elle disparaît",
        "Elle ne change pas"
      ],
      "bonne": 1,
      "explication": "L''écart angulaire vaut $\\theta = \\lambda/a$. Diminuer $a$ augmente $\\theta$, donc la tache s''élargit. C''est contre-intuitif mais c''est bien ce qu''on observe."
    },
    {
      "question": "Pourquoi entend-on une conversation derrière un mur sans voir les personnes ?",
      "choix": [
        "Le son traverse les murs, pas la lumière",
        "La longueur d''onde du son est comparable aux dimensions des obstacles, donc il diffracte",
        "Le son va plus vite",
        "Les ondes sonores sont longitudinales"
      ],
      "bonne": 1,
      "explication": "La diffraction est sensible quand l''ouverture est de l''ordre de la longueur d''onde. Le son a des longueurs d''onde de l''ordre du mètre, la lumière du micromètre : seul le son contourne les obstacles courants."
    },
    {
      "question": "Dans l''expérience de Young, que vaut l''interfrange ?",
      "choix": [
        "$i = \\lambda a / D$",
        "$i = \\lambda D / a$",
        "$i = a D / \\lambda$",
        "$i = 2\\lambda D / a$"
      ],
      "bonne": 1,
      "explication": "L''interfrange vaut $i = \\lambda D/a$. Pour des franges larges et bien visibles, il faut donc un écran éloigné et des fentes très rapprochées."
    },
    {
      "question": "On double la distance entre les deux fentes de Young. Que devient l''interfrange ?",
      "choix": [
        "Il double",
        "Il est divisé par 2",
        "Il ne change pas",
        "Il est multiplié par 4"
      ],
      "bonne": 1,
      "explication": "L''interfrange $i = \\lambda D/a$ est inversement proportionnel à $a$. Doubler l''écartement des fentes divise l''interfrange par deux, et les franges se resserrent."
    },
    {
      "question": "En lumière blanche, de quelle couleur est la frange centrale ?",
      "choix": [
        "Rouge",
        "Violette",
        "Blanche",
        "Noire"
      ],
      "bonne": 2,
      "explication": "Au centre, la différence de marche est nulle pour toutes les longueurs d''onde à la fois. Toutes les couleurs y sont donc constructives et leur somme redonne du blanc."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 17, Aspect ondulatoire de la lumière — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
