-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 10, Angles inscrits dans un cercle
-- 6 leçons.
--
-- Autonome : ce fichier cree lui-meme le programme et le chapitre s'ils
-- n'existent pas encore. Vous pouvez le lancer seul, dans n'importe quel ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $m3$
DECLARE
  v_matiere_id uuid;
  v_classe_id uuid;
  v_etab_id uuid;
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_nb_etabs int;
  v_deja int;
BEGIN
  -- 1. le programme existe-t-il deja ?
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';

  -- 2. sinon on le cree
  IF v_programme_id IS NULL THEN
    INSERT INTO public.matieres (nom) VALUES ('Mathématiques') ON CONFLICT (nom) DO NOTHING;
    SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Mathématiques';

    SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
    IF v_nb_etabs <> 1 THEN
      RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
    END IF;
    SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

    SELECT id INTO v_classe_id FROM public.classes
    WHERE nom = '3ème' AND etablissement_id = v_etab_id LIMIT 1;
    IF v_classe_id IS NULL THEN
      RAISE EXCEPTION 'Classe "3ème" introuvable dans public.classes.';
    END IF;

    INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
    VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Mathématiques — 3ème',
            'Programme de Mathématiques, classe de 3ème (BEPC) — 4 modules, 16 chapitres.')
    RETURNING id INTO v_programme_id;
    RAISE NOTICE 'Programme "Mathématiques — 3ème" cree.';
  END IF;

  -- 3. le chapitre existe-t-il deja ?
  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 10;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Angles inscrits dans un cercle', 10, 'Module 15 : Configurations et transformations élémentaires du plan')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 10 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 10 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Angle inscrit et angle au centre', 1, 'texte', 'Dans un cercle, deux points $A$ et $B$ découpent une corde. Selon l''endroit d''où tu regardes cette corde, l''angle sous lequel tu la vois change ou non. Cette leçon explique exactement ce qui se passe.

## Les définitions

Le cercle a pour centre $O$. On fixe deux points $A$ et $B$ sur ce cercle.

L''angle au centre associé à la corde $[AB]$ est l''angle $\widehat{AOB}$, dont le sommet est le centre du cercle.

Un angle inscrit est un angle $\widehat{AMB}$ dont le sommet $M$ est sur le cercle, et dont les côtés passent par $A$ et par $B$.

On dit que l''angle inscrit $\widehat{AMB}$ et l''angle au centre $\widehat{AOB}$ interceptent le même arc $AB$.

## La propriété fondamentale

Un angle inscrit vaut la moitié de l''angle au centre qui intercepte le même arc.

$$\widehat{AMB} = \dfrac{1}{2}\,\widehat{AOB}$$

Autrement dit, l''angle au centre est le double de l''angle inscrit.

## Un exemple

Si $\widehat{AOB} = 110°$, alors tout angle inscrit interceptant le même arc mesure $\dfrac{110}{2} = 55°$.

Inversement, si un angle inscrit mesure 32°, l''angle au centre correspondant mesure $2 \times 32 = 64°$.

## Exercice d''application

Sur un cercle de centre $O$, l''angle au centre $\widehat{AOB}$ mesure 86°. Donne la mesure de l''angle inscrit $\widehat{AMB}$, puis celle de l''angle au centre si l''angle inscrit mesurait 41°.

Correction. L''angle inscrit vaut $\dfrac{86}{2} = 43°$. Et si l''angle inscrit valait 41°, l''angle au centre vaudrait $2 \times 41 = 82°$.', NULL, 15),
    (v_chapitre_id, 'Les propriétés des angles inscrits', 2, 'texte', 'Deux conséquences de la propriété précédente reviennent sans arrêt dans les exercices et au BEPC.

## Les angles inscrits qui interceptent le même arc sont égaux

Si $M$ et $M''$ sont deux points du cercle situés du même côté de la corde $[AB]$, alors

$$\widehat{AMB} = \widehat{AM''B}$$

La raison est simple : les deux angles valent la moitié du même angle au centre. Peu importe où se trouve $M$ sur l''arc, l''angle ne bouge pas.

C''est pour cela qu''un joueur de football voit le but sous le même angle depuis n''importe quel point d''un certain arc de cercle.

## L''angle inscrit dans un demi-cercle est droit

Si $[AB]$ est un diamètre du cercle et si $M$ est un autre point du cercle, alors le triangle $AMB$ est rectangle en $M$.

La démonstration tient en une ligne : comme $[AB]$ est un diamètre, l''angle au centre $\widehat{AOB}$ est un angle plat de 180°. L''angle inscrit vaut donc $\dfrac{180}{2} = 90°$.

La réciproque est vraie aussi. Si un triangle $AMB$ est rectangle en $M$, alors $M$ appartient au cercle de diamètre $[AB]$. Le centre de ce cercle est le milieu de l''hypoténuse.

## Exercice d''application

$[AB]$ est un diamètre d''un cercle de centre $O$ et de rayon 5 cm. $M$ est un point du cercle tel que $AM = 6$ cm. Calcule $MB$.

Correction. Comme $[AB]$ est un diamètre, le triangle $AMB$ est rectangle en $M$. De plus $AB = 2 \times 5 = 10$ cm. Par Pythagore, $MB^{2} = AB^{2} - AM^{2} = 100 - 36 = 64$, donc $MB = 8$ cm.', NULL, 15),
    (v_chapitre_id, 'Simulation : l''angle inscrit ne bouge pas', 3, 'interactif', '{
  "widget": "angles-inscrits",
  "consigne": "Déplace le point $M$ le long du cercle, du même côté de la corde $[AB]$. L''angle inscrit $\\widehat{AMB}$ garde exactement la même mesure, et l''angle vert $\\widehat{AM''B}$ reste égal au sien. Compare ensuite avec l''angle au centre $\\widehat{AOB}$ en orange : le rapport affiché vaut toujours 2. Fais enfin glisser $A$ et $B$ pour changer la corde, et vérifie que la règle tient encore."
}', NULL, 10),
    (v_chapitre_id, 'Quiz : angles inscrits', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Un angle au centre mesure 120°. L''angle inscrit interceptant le même arc mesure :",
      "choix": [
        "$240°$",
        "$60°$",
        "$120°$"
      ],
      "bonne": 1,
      "explication": "L''angle inscrit vaut la moitié de l''angle au centre, soit $\\dfrac{120}{2} = 60°$."
    },
    {
      "question": "$[AB]$ est un diamètre et $M$ un point du cercle. Le triangle $AMB$ est :",
      "choix": [
        "équilatéral",
        "rectangle en $M$",
        "isocèle en $M$"
      ],
      "bonne": 1,
      "explication": "L''angle au centre vaut 180°, donc l''angle inscrit en $M$ vaut 90°."
    },
    {
      "question": "Deux angles inscrits interceptant le même arc, du même côté de la corde :",
      "choix": [
        "sont égaux",
        "sont complémentaires",
        "dépendent de la position du sommet"
      ],
      "bonne": 0,
      "explication": "Ils valent tous les deux la moitié du même angle au centre, donc ils sont égaux."
    },
    {
      "question": "Un triangle $ABC$ est rectangle en $C$ avec $AB = 12$ cm. Le centre du cercle passant par $A$, $B$ et $C$ est :",
      "choix": [
        "le point $C$",
        "le milieu de $[AB]$",
        "le centre de gravité"
      ],
      "bonne": 1,
      "explication": "Le cercle circonscrit à un triangle rectangle a pour diamètre l''hypoténuse, donc pour centre son milieu. Son rayon vaut ici 6 cm."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 5, 'texte', '## Exercice 1

Sur un cercle de centre $O$, les points $A$, $B$ et $M$ sont placés de sorte que $\widehat{AMB} = 37°$. Calcule $\widehat{AOB}$.

Correction. L''angle au centre est le double de l''angle inscrit, donc $\widehat{AOB} = 2 \times 37 = 74°$.

## Exercice 2

$[AB]$ est un diamètre d''un cercle. $M$ est sur le cercle avec $\widehat{MAB} = 28°$. Calcule $\widehat{MBA}$.

Correction. Le triangle $AMB$ est rectangle en $M$. La somme des angles d''un triangle vaut 180°, donc $\widehat{MBA} = 180 - 90 - 28 = 62°$.

## Exercice 3

Dans un cercle de centre $O$, l''angle inscrit $\widehat{AMB}$ mesure 45°. Que peux-tu dire du triangle $AOB$ ?

Correction. L''angle au centre vaut $2 \times 45 = 90°$. Comme $OA$ et $OB$ sont deux rayons, ils sont égaux, donc le triangle $AOB$ est rectangle isocèle en $O$.

## Exercice 4

Un terrain de football a un but $[AB]$ de 7,32 m. Un attaquant se déplace sur un arc de cercle passant par deux positions $M$ et $M''$. Explique pourquoi il voit le but sous le même angle depuis ces deux positions.

Correction. Les deux angles $\widehat{AMB}$ et $\widehat{AM''B}$ sont des angles inscrits interceptant le même arc $AB$, du même côté de la corde. Ils sont donc égaux. L''attaquant voit le but sous le même angle depuis tous les points de cet arc.', NULL, 15),
    (v_chapitre_id, 'Activité d''intégration : le projecteur du stade', 6, 'texte', '## La situation

Le stade municipal de Bamenda installe un projecteur qui doit éclairer entièrement la tribune principale, représentée par le segment $[AB]$ de 40 m de long.

Le projecteur a une ouverture fixe de 50°. On cherche où le placer pour que la tribune tienne exactement dans son faisceau.

1. Explique pourquoi toutes les positions possibles du projecteur se trouvent sur un arc de cercle.
2. Quel est l''angle au centre correspondant ?
3. Le technicien propose de placer le projecteur à un point $P$ tel que $\widehat{APB} = 50°$, puis un second à un point $Q$ sur le même arc. Verront-ils la tribune sous le même angle ?
4. Si on remplaçait le projecteur par un modèle à 90° d''ouverture, où faudrait-il le placer ?

## La solution

1. Le projecteur doit voir la tribune $[AB]$ sous un angle de 50°. Les points d''où l''on voit un segment donné sous un angle donné forment un arc de cercle passant par $A$ et $B$. C''est exactement la propriété des angles inscrits, lue à l''envers.

2. L''angle au centre vaut le double de l''angle inscrit, soit $2 \times 50 = 100°$.

3. Oui. Les points $P$ et $Q$ sont sur le même arc, du même côté de la corde $[AB]$. Les angles $\widehat{APB}$ et $\widehat{AQB}$ interceptent donc le même arc et sont égaux, tous deux à 50°. Le technicien peut choisir la position la plus pratique sur cet arc, par exemple la plus proche d''une alimentation électrique.

4. Avec une ouverture de 90°, l''angle inscrit vaut 90°, donc l''angle au centre vaut 180° : la corde $[AB]$ devient un diamètre. Le projecteur doit donc se trouver sur le cercle de diamètre $[AB]$, c''est-à-dire le cercle de centre le milieu de $[AB]$ et de rayon 20 m.

## Ce qu''il faut remarquer

Un angle d''ouverture plus large rapproche le projecteur, un angle plus étroit l''éloigne. L''arc de cercle te donne toutes les positions possibles d''un coup, au lieu de les chercher une par une.', NULL, 15);

  RAISE NOTICE 'Chapitre 10, Angles inscrits dans un cercle : 6 lecons ajoutees.';
END $m3$;
