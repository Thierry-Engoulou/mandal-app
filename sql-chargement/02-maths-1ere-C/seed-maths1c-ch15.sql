-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 15, Arcs capables
-- Module 23 : Configurations et transformations élémentaires du plan
-- 4 leçons.
--
-- Autonome : ce fichier cree lui-meme la matiere, la classe, le programme et
-- le chapitre s'ils n'existent pas encore. Lancez-le seul, dans n'importe
-- quel ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $p1c$
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
  WHERE p.titre = 'Mathématiques — 1ère C';

  -- 2. sinon on le cree
  IF v_programme_id IS NULL THEN
    INSERT INTO public.matieres (nom) VALUES ('Mathématiques') ON CONFLICT (nom) DO NOTHING;
    SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Mathématiques';

    SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
    IF v_nb_etabs <> 1 THEN
      RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
    END IF;
    SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

    -- la classe, quelle que soit la facon dont elle a ete ecrite
    SELECT id INTO v_classe_id FROM public.classes
    WHERE etablissement_id = v_etab_id
      AND (nom = '1ère C' OR nom ILIKE '1%re C' OR nom ILIKE 'Premi%re C')
    ORDER BY (nom = '1ère C') DESC
    LIMIT 1;

    -- si elle n'existe pas, on la cree
    IF v_classe_id IS NULL THEN
      INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
      VALUES (v_etab_id, '1ère C', 'Première', 'C')
      RETURNING id INTO v_classe_id;
      RAISE NOTICE 'Classe "1ère C" creee.';
    END IF;

    INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
    VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Mathématiques — 1ère C',
            'Programme officiel de Mathématiques, classe de Première C (Cameroun) — 4 modules, 21 chapitres.')
    RETURNING id INTO v_programme_id;
    RAISE NOTICE 'Programme "Mathématiques — 1ère C" cree.';
  END IF;

  -- 3. le chapitre existe-t-il deja ?
  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 15;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Arcs capables', 15, 'Module 23 : Configurations et transformations élémentaires du plan')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 15 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 15 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'L''ensemble des points qui voient un segment sous un angle donné', 1, 'texte', 'Voici une question de géométrie qui a une réponse très élégante. Fixe deux points $A$ et $B$. Où se placer pour voir le segment $[AB]$ sous un angle de 60 degrés ?

## Le théorème de l''angle inscrit, rappel

Dans un cercle, tous les angles inscrits qui interceptent le même arc ont la même mesure. Et cette mesure vaut la moitié de l''angle au centre correspondant.

C''est précisément ce qui va servir ici.

## L''arc capable

Soient $A$ et $B$ deux points distincts, et $x$ un angle strictement compris entre 0 et 180 degrés.

L''ensemble des points $M$ du plan tels que la mesure de l''angle $\widehat{AMB}$ vaut $x$ est la réunion de deux arcs de cercle, symétriques par rapport à la droite $(AB)$, privés des points $A$ et $B$.

On les appelle les arcs capables d''angle $x$ relatifs au segment $[AB]$.

## Le rayon de ces arcs

Le rayon se calcule avec la loi des sinus :
$$R = \dfrac{AB}{2\sin x}$$

Plus l''angle $x$ est grand, plus le rayon est petit, et plus les arcs se rapprochent du segment.

## Les trois cas remarquables

Si $x = 90°$, alors $R = \dfrac{AB}{2}$. Les deux arcs forment le cercle de diamètre $[AB]$. C''est le théorème que tu connais depuis la 3ème.

Si $x < 90°$, l''angle est aigu. Les arcs capables sont alors les grands arcs, ceux qui s''éloignent le plus du segment, et le centre de chaque cercle se trouve du même côté que son arc.

Si $x > 90°$, l''angle est obtus. Les arcs capables sont les petits arcs, serrés contre le segment, et le centre se trouve de l''autre côté.

## La construction

Trace la médiatrice de $[AB]$. Depuis $A$, trace la demi-droite qui fait un angle de $90° - x$ avec $[AB]$, du côté choisi. Elle coupe la médiatrice au centre $O$ de l''arc.

Trace alors le cercle de centre $O$ passant par $A$ et $B$. L''arc situé du côté opposé à $O$ est l''arc capable cherché.

Le symétrique de cet arc par rapport à $(AB)$ donne le second.

## Un calcul

Soient $A$ et $B$ distants de 6 centimètres. Quel est le rayon de l''arc capable d''angle 30 degrés ?
$$R = \dfrac{6}{2\sin 30°} = \dfrac{6}{2 \times 0{,}5} = 6 \text{ centimètres}$$

Et pour un angle de 120 degrés ?
$$R = \dfrac{6}{2\sin 120°} = \dfrac{6}{2 \times 0{,}866} \approx 3{,}46 \text{ centimètres}$$

Le rayon est bien plus petit, conformément à ce qu''on attendait.

## Exercice d''application

Un gardien de but se tient entre les deux poteaux, distants de 7,32 mètres. Un attaquant voit le but sous un angle de 20 degrés. Sur quelle courbe se trouve-t-il ?

Correction. Il se trouve sur l''arc capable d''angle 20 degrés relatif au segment formé par les deux poteaux.

Le rayon de cet arc vaut $\dfrac{7{,}32}{2\sin 20°} = \dfrac{7{,}32}{0{,}684} \approx 10{,}7$ mètres.

Tous les points de cet arc offrent exactement le même angle de tir. C''est pour cela qu''un attaquant cherche à se rapprocher : il change d''arc capable et gagne de l''angle.', NULL, 15),
    (v_chapitre_id, 'L''arc capable, à explorer', 2, 'interactif', '{
  "widget": "arcs-capables",
  "consigne": "Règle l''angle à 90° et observe la figure obtenue : reconnais-tu le cercle de diamètre $[AB]$ ? Fais ensuite glisser $M$ sur l''arc et vérifie que l''angle affiché ne change pas. Enfin, augmente l''angle à 150° et regarde les arcs s''écraser contre le segment."
}', NULL, 10),
    (v_chapitre_id, 'Les conséquences : cocyclicité et constructions', 3, 'texte', 'L''arc capable n''est pas seulement une jolie figure. Il sert à démontrer, et à construire.

## Montrer que quatre points sont cocycliques

Quatre points sont cocycliques s''ils appartiennent à un même cercle.

Si $M$ et $N$ sont du même côté de $(AB)$ et voient $[AB]$ sous le même angle, alors $A$, $B$, $M$ et $N$ sont cocycliques. Ils sont tous sur le même arc capable.

C''est une méthode très efficace. Plutôt que de chercher un centre et un rayon, tu compares deux angles.

## Le critère des angles opposés

Dans un quadrilatère $ABCD$ inscrit dans un cercle, les angles opposés sont supplémentaires :
$$\widehat{A} + \widehat{C} = 180° \qquad \widehat{B} + \widehat{D} = 180°$$

La réciproque est vraie aussi. Si dans un quadrilatère convexe deux angles opposés sont supplémentaires, alors il est inscriptible dans un cercle.

Cela vient du fait que les deux arcs capables complémentaires, d''angles $x$ et $180° - x$, forment ensemble un cercle entier.

## Construire un triangle

On veut construire un triangle $ABC$ connaissant $BC = 7$ centimètres, l''angle en $A$ égal à 50 degrés, et la hauteur issue de $A$ égale à 4 centimètres.

Tu traces d''abord $[BC]$. Puis l''arc capable d''angle 50 degrés relatif à $[BC]$. Puis la parallèle à $(BC)$ à distance 4.

Le point $A$ se trouve à l''intersection de l''arc et de la parallèle. S''il y a deux intersections, il y a deux triangles solutions. S''il n''y en a pas, le problème est impossible.

## Un critère d''existence

Pour un angle aigu $x$, l''arc capable s''éloigne au maximum de $(BC)$ d''une hauteur égale à
$$h_{\max} = R + R\cos x = R(1 + \cos x) \quad \text{où } R = \dfrac{BC}{2\sin x}$$

Ce maximum est atteint au sommet de l''arc, sur la médiatrice de $[BC]$. Si la hauteur demandée le dépasse, aucun triangle n''existe.

Pour $BC = 7$ et $x = 50°$, on a $R = \dfrac{7}{2 \times 0{,}766} \approx 4{,}57$, donc
$$h_{\max} \approx 4{,}57 \times (1 + 0{,}643) \approx 7{,}5 \text{ centimètres}$$

La hauteur demandée vaut 4 centimètres, elle est bien inférieure à 7,5. La parallèle coupe donc l''arc en deux points, et il existe deux triangles solutions, symétriques par rapport à la médiatrice de $[BC]$.

Si on avait demandé une hauteur de 9 centimètres, le problème aurait été impossible.

## Exercice d''application

Dans un triangle $ABC$, les hauteurs issues de $B$ et de $C$ coupent les côtés opposés en $H_{B}$ et $H_{C}$. Montre que $B$, $C$, $H_{B}$ et $H_{C}$ sont cocycliques.

Correction. L''angle $\widehat{BH_{B}C}$ est droit, puisque $BH_{B}$ est une hauteur, donc perpendiculaire à $(AC)$.

De même, l''angle $\widehat{BH_{C}C}$ est droit.

Les points $H_{B}$ et $H_{C}$ voient donc tous les deux le segment $[BC]$ sous un angle de 90 degrés, et ils sont du même côté de $(BC)$.

Ils appartiennent donc au même arc capable, qui est ici le cercle de diamètre $[BC]$. Les quatre points sont cocycliques.', NULL, 15),
    (v_chapitre_id, 'Quiz du chapitre 15', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "L''ensemble des points M tels que l''angle AMB mesure 90° est :",
      "choix": [
        "le cercle de diamètre [AB], privé de A et B",
        "la médiatrice de [AB]",
        "la droite (AB)",
        "un arc unique"
      ],
      "bonne": 0,
      "explication": "C''est le cas particulier le plus connu de l''arc capable. Les deux arcs d''angle 90° se recollent en un cercle entier."
    },
    {
      "question": "Le rayon de l''arc capable d''angle x relatif à [AB] vaut :",
      "choix": [
        "AB / (2 sin x)",
        "AB × sin x",
        "AB / 2",
        "2 AB sin x"
      ],
      "bonne": 0,
      "explication": "C''est la loi des sinus appliquée au triangle AMB, où l''angle en M vaut x."
    },
    {
      "question": "Quand l''angle x augmente, les arcs capables :",
      "choix": [
        "se rapprochent du segment [AB]",
        "s''éloignent du segment",
        "ne bougent pas",
        "deviennent des droites"
      ],
      "bonne": 0,
      "explication": "Le rayon AB/(2 sin x) diminue quand sin x augmente, donc les arcs s''aplatissent contre le segment."
    },
    {
      "question": "Deux points M et N, du même côté de (AB), voient [AB] sous le même angle. Alors :",
      "choix": [
        "A, B, M et N sont cocycliques",
        "M et N sont confondus",
        "(MN) est parallèle à (AB)",
        "MN = AB"
      ],
      "bonne": 0,
      "explication": "Ils appartiennent au même arc capable, donc au même cercle passant par A et B."
    },
    {
      "question": "Dans un quadrilatère inscrit dans un cercle, deux angles opposés :",
      "choix": [
        "sont supplémentaires",
        "sont égaux",
        "sont complémentaires",
        "sont droits"
      ],
      "bonne": 0,
      "explication": "Leur somme vaut 180 degrés, parce que les arcs capables d''angles x et 180° − x forment ensemble le cercle complet."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 15, Arcs capables : 4 lecons ajoutees.';
END $p1c$;
