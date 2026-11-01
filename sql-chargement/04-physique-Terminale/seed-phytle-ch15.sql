-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 15, Les ondes mécaniques
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
    WHERE programme_id = v_programme_id AND ordre = 15;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les ondes mécaniques', 15, 'Module 4 : Ondes, matière et transformations nucléaires')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 15 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 15 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Signaux et propagation d''une onde', 1, 'texte', 'Jette un caillou dans une mare. Des rides partent du point d''impact et s''éloignent. Pourtant, une feuille qui flotte à la surface ne part pas avec elles : elle monte et descend sur place. Voilà toute l''idée de l''onde.

## Le signal

Un **signal** est une perturbation brève et locale d''un milieu.

Une secousse donnée à l''extrémité d''une corde tendue, un coup frappé sur une table, un claquement de mains dans l''air : ce sont des signaux.

Un signal est **transversal** quand la perturbation est perpendiculaire à la direction de propagation. C''est le cas de la corde qu''on secoue de haut en bas alors que l''onde part sur le côté.

Il est **longitudinal** quand la perturbation est parallèle à la direction de propagation. C''est le cas d''un ressort qu''on comprime brusquement, et c''est aussi le cas du son dans l''air.

## La propagation

Une **onde** est la propagation d''une perturbation dans un milieu, sans transport de matière.

Retiens bien ces trois mots : sans transport de matière. Chaque point du milieu reste à sa place et ne fait qu''osciller. Ce qui se déplace, c''est la perturbation, donc l''**énergie** et l''**information**.

La feuille sur la mare ne traverse pas l''étang. Elle monte et redescend pendant que la ride passe sous elle.

## La célérité

La **célérité** $v$ est la vitesse de propagation de l''onde. Elle se mesure en m/s et vaut
$$v = \dfrac{d}{\Delta t}$$
où $d$ est la distance parcourue par la perturbation pendant la durée $\Delta t$.

La célérité ne dépend pas de l''amplitude de la perturbation, mais uniquement des **propriétés du milieu**.

Pour une corde de masse linéique $\mu$ tendue avec la force $F$,
$$v = \sqrt{\dfrac{F}{\mu}}$$

Une corde plus tendue transmet plus vite, une corde plus lourde transmet plus lentement. C''est pourquoi les cordes graves d''une guitare sont les plus épaisses.

Le son se déplace à environ $340$ m/s dans l''air, $1500$ m/s dans l''eau et $5000$ m/s dans l''acier. Plus le milieu est rigide, plus le son va vite.

Une onde mécanique a toujours besoin d''un milieu matériel. Dans le vide, aucun son ne se propage.

## Le retard

Si l''onde met un temps $\tau$ pour aller du point source $S$ au point $M$ distant de $d$, alors
$$\tau = \dfrac{d}{v}$$

Le point $M$ reproduit le mouvement de $S$ avec ce retard :
$$y_{M}(t) = y_{S}(t - \tau)$$

C''est la relation fondamentale, et elle sert dans presque tous les exercices.

## Exercice d''application

Un pêcheur sur le lac Ossa frappe la coque de sa pirogue. Un second pêcheur, à $510$ m, entend le coup dans l''air puis, s''il met l''oreille dans l''eau, l''entend aussi par l''eau. Calcule les deux durées de propagation et l''écart entre elles. On prend $v_{\text{air}} = 340$ m/s et $v_{\text{eau}} = 1500$ m/s.

Correction. Dans l''air,
$$\tau_{\text{air}} = \dfrac{510}{340} = 1{,}5\ \text{s}$$

Dans l''eau,
$$\tau_{\text{eau}} = \dfrac{510}{1500} = 0{,}34\ \text{s}$$

L''écart vaut $1{,}5 - 0{,}34 = 1{,}16$ s, soit environ $1{,}2$ s.

Le son arrive donc largement en avance par l''eau. C''est d''ailleurs cette méthode, dite des deux ondes, qui permet de mesurer la distance d''un orage : l''éclair arrive presque instantanément, le tonnerre met trois secondes par kilomètre.', NULL, 15),
      (v_chapitre_id, 'Les ondes progressives périodiques', 2, 'texte', 'Si au lieu d''une secousse unique tu agites la corde régulièrement, tu crées une suite de perturbations identiques. L''onde devient périodique, et une nouvelle grandeur apparaît : la longueur d''onde.

## La double périodicité

Une onde progressive périodique possède deux périodicités.

Une **périodicité temporelle**. En un point fixe, l''élongation se reproduit identique à elle-même toutes les $T$ secondes. C''est la période temporelle, imposée par la source.

Une **périodicité spatiale**. À un instant donné, la photographie de l''onde se reproduit identique à elle-même tous les $\lambda$ mètres. C''est la **longueur d''onde**.

## La relation fondamentale

Pendant une période $T$, l''onde avance exactement d''une longueur d''onde. Donc
$$\lambda = v\,T = \dfrac{v}{N}$$

Cette relation est à connaître par cœur. Elle relie une grandeur de la source, la fréquence, à une grandeur du milieu, la célérité.

Attention à un point important. Quand une onde change de milieu, sa **fréquence ne change pas**, car elle est imposée par la source. Ce sont la célérité et donc la longueur d''onde qui changent.

## L''équation de l''onde progressive

Si la source en $x = 0$ oscille selon $y_{S}(t) = a\cos(\omega t)$, un point $M$ à l''abscisse $x$ reproduit ce mouvement avec le retard $\tau = \dfrac{x}{v}$ :
$$y_{M}(x,t) = a\cos\left[\omega\left(t - \dfrac{x}{v}\right)\right]$$

En développant avec $\omega = \dfrac{2\pi}{T}$ et $\lambda = vT$,
$$y_{M}(x,t) = a\cos\left(\dfrac{2\pi t}{T} - \dfrac{2\pi x}{\lambda}\right)$$

Cette écriture met bien en évidence les deux périodicités : en $T$ pour le temps, en $\lambda$ pour l''espace.

## Points en phase et en opposition de phase

Deux points de la corde vibrent **en phase** lorsqu''ils montent et descendent ensemble. Cela arrive quand leur distance est un multiple entier de la longueur d''onde :
$$d = k\,\lambda \qquad \text{avec } k \text{ entier}$$

Ils vibrent en **opposition de phase** lorsque l''un monte pendant que l''autre descend, ce qui arrive quand
$$d = \left(k + \dfrac{1}{2}\right)\lambda$$

## Exercice d''application

Une corde est agitée à la fréquence $N = 50$ Hz. On mesure que la perturbation parcourt $6{,}0$ m en $0{,}40$ s. Calcule la célérité et la longueur d''onde. Deux points distants de $36$ cm vibrent-ils en phase ?

Correction. La célérité vaut
$$v = \dfrac{d}{\Delta t} = \dfrac{6{,}0}{0{,}40} = 15\ \text{m/s}$$

La longueur d''onde vaut
$$\lambda = \dfrac{v}{N} = \dfrac{15}{50} = 0{,}30\ \text{m} = 30\ \text{cm}$$

Pour les deux points, calculons le rapport
$$\dfrac{d}{\lambda} = \dfrac{36}{30} = 1{,}2$$

Ce rapport n''est pas un entier, donc les deux points ne vibrent pas en phase. Ils ne sont pas non plus en opposition de phase, puisque $1{,}2$ n''est pas de la forme $k + 0{,}5$. Leur déphasage vaut
$$\Delta\varphi = 2\pi \times 1{,}2 = 2{,}4\pi\ \text{rad}$$

ce qui, modulo $2\pi$, équivaut à $0{,}4\pi$ rad, soit $72°$.', NULL, 15),
      (v_chapitre_id, 'Fais courir une onde sur une corde', 3, 'interactif', '{
  "widget": "onde-progressive",
  "consigne": "Change la fréquence et la célérité, et regarde la longueur d''onde se modifier. Place deux marqueurs sur la corde et trouve la distance qui les met en opposition de phase. Vérifie ensuite que $\\lambda = v/N$ sur trois réglages différents."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 15', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qui se propage dans une onde mécanique ?",
      "choix": [
        "La matière du milieu",
        "L''énergie et l''information, sans transport de matière",
        "Uniquement de la chaleur",
        "Des particules de la source"
      ],
      "bonne": 1,
      "explication": "Chaque point du milieu reste à sa place et ne fait qu''osciller autour de sa position d''équilibre. Seule la perturbation se déplace, en transportant de l''énergie et de l''information."
    },
    {
      "question": "Une onde de fréquence 100 Hz se propage à 340 m/s. Quelle est sa longueur d''onde ?",
      "choix": [
        "3,4 m",
        "0,34 m",
        "34 m",
        "3,4 cm"
      ],
      "bonne": 0,
      "explication": "On applique $\\lambda = v/N = 340/100 = 3{,}4$ m. La longueur d''onde est la distance parcourue par l''onde pendant une période."
    },
    {
      "question": "Une onde sonore passe de l''air dans l''eau. Qu''est-ce qui ne change pas ?",
      "choix": [
        "La célérité",
        "La longueur d''onde",
        "La fréquence",
        "L''amplitude"
      ],
      "bonne": 2,
      "explication": "La fréquence est imposée par la source et reste la même dans tous les milieux. Comme la célérité change, la longueur d''onde $\\lambda = v/N$ change forcément elle aussi."
    },
    {
      "question": "Le son se propage-t-il dans le vide ?",
      "choix": [
        "Oui, comme la lumière",
        "Non, il lui faut un milieu matériel",
        "Oui, mais plus lentement",
        "Seulement s''il est très intense"
      ],
      "bonne": 1,
      "explication": "Une onde mécanique est la propagation d''une déformation de la matière. S''il n''y a pas de matière, il n''y a rien à déformer. C''est une différence essentielle avec les ondes électromagnétiques."
    },
    {
      "question": "Deux points d''une corde distants de $2{,}5\\lambda$ vibrent :",
      "choix": [
        "en phase",
        "en opposition de phase",
        "en quadrature",
        "de façon quelconque"
      ],
      "bonne": 1,
      "explication": "La distance s''écrit $(2 + 0{,}5)\\lambda$, elle est donc de la forme $(k + 1/2)\\lambda$. Les deux points sont en opposition de phase : quand l''un monte, l''autre descend."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 15, Les ondes mécaniques — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
