-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 21, L''effet Compton
-- Module 4 : Ondes, matière et transformations nucléaires
-- 3 leçons.
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
    WHERE programme_id = v_programme_id AND ordre = 21;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'L''effet Compton', 21, 'Module 4 : Ondes, matière et transformations nucléaires')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 21 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 21 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'L''effet Compton', 1, 'texte', 'L''effet photoélectrique montre que le photon porte une énergie. L''effet Compton, découvert en 1923, montre qu''il porte aussi une quantité de mouvement, comme une vraie particule.

## L''expérience

Compton envoie un faisceau de rayons X sur un bloc de graphite et analyse le rayonnement diffusé dans différentes directions.

Il observe que le rayonnement diffusé contient, en plus de la longueur d''onde initiale, une longueur d''onde **plus grande**. Et ce décalage augmente avec l''angle de diffusion.

C''est inexplicable par la théorie ondulatoire, qui prévoit que la lumière diffusée garde la même fréquence.

## L''interprétation

Compton traite le phénomène comme un **choc élastique** entre un photon et un électron faiblement lié du matériau, exactement comme deux boules de billard.

Le photon cède une partie de son énergie à l''électron, qui part en reculant. Ayant perdu de l''énergie, le photon diffusé a une fréquence plus faible, donc une longueur d''onde plus grande.

Pour que le calcul fonctionne, il faut attribuer au photon une **quantité de mouvement**
$$p = \dfrac{h}{\lambda} = \dfrac{h\,\nu}{c}$$

## La formule de Compton

Le décalage de longueur d''onde vaut
$$\Delta\lambda = \lambda'' - \lambda = \dfrac{h}{m_{e}\,c}\,(1 - \cos\theta)$$
où $\theta$ est l''angle de diffusion et $m_{e}$ la masse de l''électron.

La quantité $\dfrac{h}{m_{e}c}$ s''appelle la **longueur d''onde de Compton** de l''électron. Elle vaut
$$\lambda_{C} = 2{,}43 \times 10^{-12}\ \text{m}$$

## Les cas remarquables

Si $\theta = 0$, le photon continue tout droit, $\cos\theta = 1$ et $\Delta\lambda = 0$. Rien ne change, il n''y a pas eu de choc.

Si $\theta = 90°$, alors $\cos\theta = 0$ et $\Delta\lambda = \lambda_{C} = 2{,}43$ pm.

Si $\theta = 180°$, le photon rebondit en arrière, $\cos\theta = -1$ et le décalage est maximal : $\Delta\lambda = 2\lambda_{C} = 4{,}86$ pm.

## Pourquoi on n''observe pas l''effet en lumière visible

Le décalage $\Delta\lambda$ ne dépend pas de la longueur d''onde initiale, il vaut toujours quelques picomètres.

Pour la lumière visible, $\lambda$ vaut environ $500$ nm, soit $500\,000$ pm. Un décalage de $2{,}4$ pm représente alors cinq millionièmes de la valeur, totalement indétectable.

Pour les rayons X, $\lambda$ vaut quelques dizaines de picomètres. Le décalage devient alors de l''ordre de $10\%$, parfaitement mesurable.

C''est pourquoi Compton a dû utiliser des rayons X.

## L''importance et les applications

L''effet Compton a définitivement établi que le photon est une particule à part entière, dotée d''une énergie et d''une quantité de mouvement, même si sa masse est nulle.

En **radioprotection**, c''est le principal mécanisme d''atténuation des rayons gamma dans la matière aux énergies moyennes, à côté de l''effet photoélectrique qui domine aux basses énergies.

En **imagerie médicale**, la diffusion Compton dégrade le contraste des radiographies, et les techniciens utilisent des grilles anti-diffusantes pour limiter son effet.

## Exercice d''application

Un photon X de longueur d''onde $\lambda = 50{,}0$ pm est diffusé à $60°$ par un électron. Calcule la longueur d''onde du photon diffusé, puis l''énergie cédée à l''électron. On donne $\lambda_{C} = 2{,}43$ pm, $h = 6{,}63 \times 10^{-34}$ J·s et $c = 3{,}00 \times 10^{8}$ m/s.

Correction. Le décalage vaut
$$\Delta\lambda = \lambda_{C}(1 - \cos 60°) = 2{,}43 \times (1 - 0{,}5) = 2{,}43 \times 0{,}5 = 1{,}215\ \text{pm}$$

La longueur d''onde diffusée vaut donc
$$\lambda'' = 50{,}0 + 1{,}215 \approx 51{,}2\ \text{pm}$$

L''énergie du photon incident vaut
$$E = \dfrac{hc}{\lambda} = \dfrac{1{,}989 \times 10^{-25}}{50{,}0 \times 10^{-12}} = 3{,}978 \times 10^{-15}\ \text{J}$$

L''énergie du photon diffusé vaut
$$E'' = \dfrac{1{,}989 \times 10^{-25}}{51{,}2 \times 10^{-12}} = 3{,}885 \times 10^{-15}\ \text{J}$$

L''énergie cédée à l''électron est la différence :
$$\Delta E = 3{,}978 \times 10^{-15} - 3{,}885 \times 10^{-15} = 9{,}3 \times 10^{-17}\ \text{J}$$

soit environ $580$ eV. L''électron part donc avec une énergie cinétique de $580$ électronvolts.', NULL, 15),
      (v_chapitre_id, 'Fais rebondir un photon sur un électron', 2, 'interactif', '{
  "widget": "diffusion-compton",
  "consigne": "Règle la longueur d''onde du photon incident et l''angle de diffusion, puis lis le décalage obtenu. Trouve l''angle qui donne le décalage maximal. Passe ensuite de rayons X à la lumière visible : pourquoi l''effet devient-il invisible ?"
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 21', 3, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que montre l''effet Compton au sujet du photon ?",
      "choix": [
        "Qu''il a une masse",
        "Qu''il possède une quantité de mouvement",
        "Qu''il est une onde pure",
        "Qu''il n''a pas d''énergie"
      ],
      "bonne": 1,
      "explication": "Le choc photon-électron ne s''explique qu''en attribuant au photon une quantité de mouvement $p = h/\\lambda$. Sa masse reste pourtant nulle, ce qui est propre aux particules se déplaçant à la vitesse de la lumière."
    },
    {
      "question": "Après diffusion Compton, la longueur d''onde du photon :",
      "choix": [
        "diminue",
        "augmente",
        "ne change pas",
        "devient nulle"
      ],
      "bonne": 1,
      "explication": "Le photon cède de l''énergie à l''électron, donc sa fréquence diminue et sa longueur d''onde augmente. Le décalage $\\Delta\\lambda$ est toujours positif."
    },
    {
      "question": "Pour quel angle de diffusion le décalage de Compton est-il maximal ?",
      "choix": [
        "0°",
        "90°",
        "180°",
        "45°"
      ],
      "bonne": 2,
      "explication": "Le décalage vaut $\\lambda_C(1 - \\cos\\theta)$. Il est maximal quand $\\cos\\theta = -1$, donc pour $\\theta = 180°$, c''est-à-dire quand le photon rebondit en arrière. Il vaut alors $2\\lambda_C$."
    },
    {
      "question": "Pourquoi l''effet Compton ne s''observe-t-il pas en lumière visible ?",
      "choix": [
        "La lumière visible n''a pas d''énergie",
        "Le décalage de quelques picomètres est négligeable devant 500 nm",
        "Les électrons ne réagissent pas",
        "L''effet n''existe que dans le vide"
      ],
      "bonne": 1,
      "explication": "Le décalage vaut toujours quelques picomètres, quelle que soit la longueur d''onde initiale. Rapporté aux 500 000 pm de la lumière visible, c''est indétectable, alors que pour des rayons X de 50 pm cela fait environ 5 %."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 21, L''effet Compton — 3 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
