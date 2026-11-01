-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 16, Les piles et les potentiels d''oxydoréduction
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
    WHERE programme_id = v_programme_id AND ordre = 16;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les piles et les potentiels d''oxydoréduction', 16, 'Module 4 : Oxydoréduction')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 16 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 16 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'La pile Daniell et son fonctionnement', 1, 'texte', 'Si tu plonges une lame de zinc dans du sulfate de cuivre, la réaction se fait sur place et dégage de la chaleur, perdue. Si tu sépares les deux couples, les électrons sont obligés de passer par un fil : tu récupères un courant. C''est le principe de la pile.

## Le montage

La pile Daniell comprend deux compartiments, appelés **demi-piles**.

Dans le premier, une lame de zinc plonge dans une solution de sulfate de zinc.

Dans le second, une lame de cuivre plonge dans une solution de sulfate de cuivre.

Les deux solutions sont reliées par un **pont salin**, un tube rempli d''une solution ionique gélifiée, souvent du chlorure de potassium ou du nitrate d''ammonium.

Les deux lames, appelées **électrodes**, sont reliées par un fil conducteur où l''on intercale un ampèremètre et une résistance.

## Ce qui se passe à chaque électrode

À l''électrode de **zinc**, le métal s''oxyde et libère des électrons dans le fil :
$$\text{Zn} \longrightarrow \text{Zn}^{2+} + 2\,\text{e}^{-}$$

C''est le siège de l''**oxydation**, donc c''est l''**anode**. Dans une pile, l''anode est le pôle **négatif**.

À l''électrode de **cuivre**, les ions captent les électrons arrivés par le fil et se déposent :
$$\text{Cu}^{2+} + 2\,\text{e}^{-} \longrightarrow \text{Cu}$$

C''est le siège de la **réduction**, donc c''est la **cathode**, pôle **positif**.

Retiens le moyen mnémotechnique : l''**an**ode est le siège de l''**ox**ydation, et dans une pile elle est négative.

## Le sens des porteurs de charge

Les **électrons** circulent dans le fil, du pôle négatif vers le pôle positif, donc du zinc vers le cuivre.

Le **courant**, par convention, circule en sens inverse, du cuivre vers le zinc dans le fil.

Dans le **pont salin**, ce sont les ions qui se déplacent. Les anions vont vers la demi-pile où s''accumulent les charges positives, c''est-à-dire côté zinc. Les cations vont côté cuivre.

Sans le pont salin, les charges s''accumuleraient et la pile s''arrêterait immédiatement. Son rôle est d''assurer l''**électroneutralité** des deux solutions.

## L''évolution de la pile

Avec le temps, la lame de zinc **maigrit** et la solution de zinc se concentre. La lame de cuivre **grossit** et la solution bleue pâlit.

La pile est **usée** quand un des réactifs est épuisé, le plus souvent le zinc ou les ions cuivre.

## La force électromotrice

La **force électromotrice**, ou f.é.m., est la tension aux bornes de la pile quand elle ne débite pas. On la mesure au voltmètre, et elle se note $E$.

Pour la pile Daniell, elle vaut environ $1{,}1$ V.

Elle se calcule à partir des potentiels standard :
$$E = E^{\circ}_{\text{cathode}} - E^{\circ}_{\text{anode}}$$

Elle est toujours **positive** si on a bien identifié les deux pôles.

## Les potentiels standard

Chaque couple rédox possède un **potentiel standard** $E^{\circ}$, mesuré en volts par rapport à l''électrode standard à hydrogène, dont le potentiel vaut $0$ par convention.

Quelques valeurs : $\text{Zn}^{2+}/\text{Zn}$ à $-0{,}76$ V, $\text{Fe}^{2+}/\text{Fe}$ à $-0{,}44$ V, $\text{H}^{+}/\text{H}_{2}$ à $0$ V, $\text{Cu}^{2+}/\text{Cu}$ à $+0{,}34$ V, $\text{Ag}^{+}/\text{Ag}$ à $+0{,}80$ V, $\text{MnO}_{4}^{-}/\text{Mn}^{2+}$ à $+1{,}51$ V.

La règle est simple : plus $E^{\circ}$ est **grand**, plus l''oxydant du couple est **fort**. Plus $E^{\circ}$ est petit, plus le réducteur est fort.

On prévoit alors la réaction spontanée exactement comme avec les $\text{p}K_{a}$ : l''oxydant du couple de **plus haut** potentiel réagit avec le réducteur du couple de **plus bas** potentiel. C''est encore une règle du gamma.

## La corrosion

La corrosion du fer est une oxydation spontanée par le dioxygène en présence d''eau :
$$4\,\text{Fe} + 3\,\text{O}_{2} + 6\,\text{H}_{2}\text{O} \longrightarrow 4\,\text{Fe}(\text{OH})_{3}$$

Elle est accélérée par l''humidité, le sel et le contact avec un métal moins réducteur.

Trois protections sont au programme. La **peinture** ou le vernis isolent le métal de l''air. La **galvanisation** recouvre le fer de zinc. Et l''**anode sacrificielle** consiste à relier la pièce à protéger à un bloc de métal plus réducteur, zinc ou magnésium, qui s''oxyde à sa place.

Les coques de bateau et les pipelines sont protégés ainsi : on remplace le bloc de zinc de temps en temps, et l''acier reste intact.

## Exercice d''application

On réalise une pile avec une demi-pile argent, $E^{\circ} = +0{,}80$ V, et une demi-pile fer, $E^{\circ} = -0{,}44$ V. Identifie les pôles, écris les réactions aux électrodes et l''équation bilan, puis calcule la f.é.m.

Correction. Le couple de potentiel le plus élevé est $\text{Ag}^{+}/\text{Ag}$. C''est donc là que se produit la **réduction**, et cette électrode est la **cathode**, pôle **positif**.
$$\text{Ag}^{+} + \text{e}^{-} \longrightarrow \text{Ag}$$

Le couple de potentiel le plus bas est $\text{Fe}^{2+}/\text{Fe}$. C''est là que se produit l''**oxydation**, cette électrode est l''**anode**, pôle **négatif**.
$$\text{Fe} \longrightarrow \text{Fe}^{2+} + 2\,\text{e}^{-}$$

Pour le bilan, il faut multiplier la première demi-équation par 2 afin d''équilibrer les électrons :
$$\text{Fe} + 2\,\text{Ag}^{+} \longrightarrow \text{Fe}^{2+} + 2\,\text{Ag}$$

La force électromotrice vaut
$$E = E^{\circ}_{\text{cathode}} - E^{\circ}_{\text{anode}} = 0{,}80 - (-0{,}44) = 1{,}24\ \text{V}$$

Elle est bien positive, ce qui confirme que les pôles sont correctement identifiés.

En fonctionnement, la lame de fer maigrit, et un dépôt d''argent se forme sur l''autre électrode.', NULL, 15),
      (v_chapitre_id, 'Fais fonctionner une pile', 2, 'interactif', '{
  "widget": "pile-daniell",
  "consigne": "Choisis les deux couples de la pile et observe le sens des électrons, la polarité et la force électromotrice. Vérifie la formule $E = E^{\\circ}_{\\text{cathode}} - E^{\\circ}_{\\text{anode}}$. Supprime ensuite le pont salin : que devient le courant, et pourquoi ?"
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 16', 3, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Dans une pile, l''anode est le siège de :",
      "choix": [
        "la réduction, et c''est le pôle positif",
        "l''oxydation, et c''est le pôle négatif",
        "l''oxydation, et c''est le pôle positif",
        "la réduction, et c''est le pôle négatif"
      ],
      "bonne": 1,
      "explication": "L''anode est toujours le siège de l''oxydation. Dans une pile, c''est elle qui libère les électrons dans le circuit, donc c''est le pôle négatif."
    },
    {
      "question": "À quoi sert le pont salin dans une pile ?",
      "choix": [
        "À conduire les électrons",
        "À assurer l''électroneutralité des deux solutions",
        "À mélanger les solutions",
        "À mesurer la tension"
      ],
      "bonne": 1,
      "explication": "Sans lui, les charges s''accumuleraient de chaque côté et la pile s''arrêterait aussitôt. Les ions du pont migrent pour compenser, mais les électrons passent toujours par le fil."
    },
    {
      "question": "Une pile est formée des couples $\\text{Cu}^{2+}/\\text{Cu}$ (+0,34 V) et $\\text{Zn}^{2+}/\\text{Zn}$ (−0,76 V). Que vaut sa f.é.m. ?",
      "choix": [
        "0,42 V",
        "1,10 V",
        "−1,10 V",
        "0,34 V"
      ],
      "bonne": 1,
      "explication": "La cathode est le couple de plus haut potentiel, le cuivre. Donc $E = 0{,}34 - (-0{,}76) = 1{,}10$ V. C''est la pile Daniell."
    },
    {
      "question": "Plus le potentiel standard d''un couple est grand, plus :",
      "choix": [
        "son réducteur est fort",
        "son oxydant est fort",
        "le couple est instable",
        "la pile est faible"
      ],
      "bonne": 1,
      "explication": "Un potentiel élevé signale un oxydant puissant, qui capte facilement les électrons. Le permanganate, à +1,51 V, est l''un des oxydants les plus forts du programme."
    },
    {
      "question": "En quoi consiste la protection par anode sacrificielle ?",
      "choix": [
        "Peindre le métal",
        "Relier la pièce à un métal plus réducteur qui s''oxyde à sa place",
        "Chauffer le métal",
        "Plonger la pièce dans l''acide"
      ],
      "bonne": 1,
      "explication": "Un bloc de zinc ou de magnésium, plus réducteur que le fer, s''oxyde en premier et protège la pièce. On le remplace périodiquement, et l''acier reste intact."
    },
    {
      "question": "Dans une pile Daniell en fonctionnement, que devient la lame de zinc ?",
      "choix": [
        "Elle grossit",
        "Elle maigrit",
        "Elle ne change pas",
        "Elle devient bleue"
      ],
      "bonne": 1,
      "explication": "Le zinc s''oxyde et passe en solution sous forme d''ions $\\text{Zn}^{2+}$, donc la lame perd de la matière. C''est la lame de cuivre qui grossit, par dépôt de cuivre métallique."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 16, Les piles et les potentiels d''oxydoréduction — 3 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
