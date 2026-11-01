-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 16, Transformations du plan
-- Module 23 : Configurations et transformations élémentaires du plan
-- 6 leçons.
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
  WHERE programme_id = v_programme_id AND ordre = 16;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Transformations du plan', 16, 'Module 23 : Configurations et transformations élémentaires du plan')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 16 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 16 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Qu''est-ce qu''une transformation du plan', 1, 'texte', 'Une transformation du plan, c''est une façon de déplacer ou de déformer une figure, point par point, selon une règle précise.

## La définition

Une transformation du plan est une application bijective du plan dans lui-même. Chaque point a une image et une seule, et chaque point est l''image d''un point et d''un seul.

La bijectivité est ce qui permet de revenir en arrière. À toute transformation $f$ correspond une transformation réciproque $f^{-1}$.

## Le vocabulaire

Un point invariant, ou point fixe, est un point qui est sa propre image. On a $f(M) = M$.

La composée $g \circ f$ consiste à appliquer $f$ puis $g$. Elle est encore une transformation.

## Les isométries

Une isométrie est une transformation qui conserve les distances. Si $M''$ et $N''$ sont les images de $M$ et $N$, alors $M''N'' = MN$.

Une isométrie conserve donc aussi les angles, les aires, le parallélisme, l''alignement et les milieux. La figure image est superposable à la figure de départ.

Les isométries du plan sont les translations, les rotations, les symétries orthogonales et les symétries glissées. Il n''y en a pas d''autres.

## Les similitudes

Une similitude de rapport $k > 0$ multiplie toutes les distances par $k$ :
$$M''N'' = k \times MN$$

Elle conserve les angles et le parallélisme, mais pas les longueurs. Les aires sont multipliées par $k^{2}$.

Une isométrie est une similitude de rapport 1. L''homothétie de rapport $k$ est une similitude de rapport $|k|$.

## Les propriétés conservées, un tableau mental

Toutes ces transformations conservent l''alignement, le parallélisme, les milieux, les barycentres et la nature des figures. Un cercle devient un cercle, un triangle un triangle.

Les isométries conservent en plus les longueurs et les aires.

Les similitudes conservent les angles et les rapports de longueurs, mais multiplient les longueurs par $k$ et les aires par $k^{2}$.

## Exercice d''application

Une transformation multiplie les longueurs par 3. L''image d''un triangle d''aire 12 centimètres carrés a quelle aire ? Et le périmètre, s''il valait 20 centimètres ?

Correction. Les aires sont multipliées par $3^{2} = 9$, donc l''aire de l''image vaut 108 centimètres carrés.

Le périmètre est une longueur, il est donc multiplié par 3 et vaut 60 centimètres.', NULL, 15),
    (v_chapitre_id, 'Les symétries orthogonales', 2, 'texte', 'La symétrie orthogonale, ou réflexion, est la transformation du miroir. C''est la brique de base de toutes les isométries.

## La définition

Soit $(D)$ une droite. La symétrie orthogonale d''axe $(D)$, notée $S_{D}$, associe à tout point $M$ le point $M''$ tel que $(D)$ soit la médiatrice de $[MM'']$.

Si $M$ appartient à $(D)$, alors $M'' = M$. Les points de l''axe sont donc les seuls points invariants.

## Les propriétés

C''est une isométrie : les longueurs sont conservées.

C''est une involution : appliquer deux fois la même symétrie ramène au point de départ. Autrement dit $S_{D} \circ S_{D} = \text{Id}$, et la réciproque de $S_{D}$ est $S_{D}$ elle-même.

Elle inverse l''orientation. Un triangle parcouru dans le sens des aiguilles d''une montre a pour image un triangle parcouru dans l''autre sens. C''est pourquoi on dit qu''elle est indirecte.

## Les expressions analytiques

Dans un repère orthonormé, la symétrie d''axe $(Ox)$ transforme $(x\,;y)$ en $(x\,;-y)$.

La symétrie d''axe $(Oy)$ transforme $(x\,;y)$ en $(-x\,;y)$.

La symétrie d''axe la première bissectrice, d''équation $y = x$, transforme $(x\,;y)$ en $(y\,;x)$.

## Composer deux symétries

C''est là que se trouve le résultat le plus utile du chapitre.

Si les deux axes sont parallèles, la composée est une translation. Le vecteur de translation est perpendiculaire aux axes, et sa norme vaut deux fois la distance entre les axes.

Si les deux axes sont sécants en $O$ et font entre eux un angle $\theta$, la composée est une rotation de centre $O$ et d''angle $2\theta$.

Ce résultat explique pourquoi toute isométrie du plan se décompose en au plus trois symétries orthogonales.

## Une vérification

Prends les droites $x = 1$ et $x = 4$, parallèles et distantes de 3.

Le point $M(0\,;5)$ a pour image par la première symétrie le point $(2\,;5)$, puis par la seconde le point $(6\,;5)$.

Il s''est déplacé de 6 unités vers la droite, c''est-à-dire bien deux fois la distance entre les axes.

## Exercice d''application

Dans un repère orthonormé, détermine l''image du point $A(3\,;-2)$ par la symétrie d''axe la droite d''équation $y = x$, puis par la symétrie d''axe $(Ox)$. Quelle transformation obtiens-tu en composant les deux ?

Correction. Par la symétrie d''axe $y = x$, l''image de $A$ est $(-2\,;3)$.

Par la symétrie d''axe $(Ox)$, cette image devient $(-2\,;-3)$.

Les deux axes sont sécants en $O$ et font un angle de 45 degrés. La composée est donc la rotation de centre $O$ et d''angle 90 degrés, dans un sens à déterminer selon l''ordre choisi.', NULL, 15),
    (v_chapitre_id, 'Translations, rotations, homothéties', 3, 'texte', 'Voici les trois transformations que tu utiliseras le plus souvent, avec ce qui les distingue.

## La translation

La translation de vecteur $\vec{u}$ associe à $M$ le point $M''$ tel que $\vec{MM''} = \vec{u}$.

Aucun point n''est invariant, sauf si le vecteur est nul. La figure glisse sans tourner ni changer de taille.

En coordonnées, si $\vec{u}(a\,;b)$ :
$$x'' = x + a \qquad y'' = y + b$$

La composée de deux translations est une translation, de vecteur la somme des deux vecteurs.

## La rotation

La rotation de centre $\Omega$ et d''angle $\theta$ associe à $M$ le point $M''$ tel que $\Omega M'' = \Omega M$ et que l''angle orienté de $\vec{\Omega M}$ vers $\vec{\Omega M''}$ vaille $\theta$.

Le centre $\Omega$ est le seul point invariant, sauf si l''angle est nul.

En coordonnées, pour une rotation de centre $O$ et d''angle $\theta$ :
$$x'' = x\cos\theta - y\sin\theta \qquad y'' = x\sin\theta + y\cos\theta$$

La rotation d''angle 180 degrés est la symétrie centrale de centre $\Omega$. En coordonnées, elle transforme $(x\,;y)$ en $(2x_{\Omega} - x\,;2y_{\Omega} - y)$.

## L''homothétie

L''homothétie de centre $\Omega$ et de rapport $k$, avec $k \neq 0$, associe à $M$ le point $M''$ tel que
$$\vec{\Omega M''} = k\,\vec{\Omega M}$$

Le centre est invariant. Si $k = 1$, tous les points le sont.

En coordonnées :
$$x'' = x_{\Omega} + k(x - x_{\Omega}) \qquad y'' = y_{\Omega} + k(y - y_{\Omega})$$

Si $k > 0$, l''image est du même côté que l''original par rapport au centre. Si $k < 0$, elle est de l''autre côté.

Les longueurs sont multipliées par $|k|$, les aires par $k^{2}$. L''image d''une droite est une droite parallèle.

## Un exemple d''homothétie dans la vie

Un plan d''architecte à l''échelle 1 sur 50 est l''image du bâtiment réel par une homothétie de rapport $\dfrac{1}{50}$.

Un mur de 10 mètres y est dessiné sur 20 centimètres. Une pièce de 20 mètres carrés y occupe $20 \times \left(\dfrac{1}{50}\right)^{2} = 0{,}008$ mètre carré, soit 80 centimètres carrés.

## Composer des homothéties

La composée de deux homothéties de même centre et de rapports $k$ et $k''$ est l''homothétie de même centre et de rapport $kk''$.

Si les centres diffèrent, la composée est une homothétie de rapport $kk''$ lorsque $kk'' \neq 1$, et une translation lorsque $kk'' = 1$.

## Exercice d''application

Soit $h$ l''homothétie de centre $\Omega(1\,;2)$ et de rapport $-2$. Trouve l''image du point $A(4\,;3)$, et l''aire de l''image d''un triangle d''aire 5.

Correction. On applique la formule :
$$x'' = 1 - 2(4 - 1) = 1 - 6 = -5 \qquad y'' = 2 - 2(3 - 2) = 2 - 2 = 0$$

Donc $A''(-5\,;0)$. Comme le rapport est négatif, $A''$ se trouve de l''autre côté de $\Omega$ par rapport à $A$.

L''aire est multipliée par $(-2)^{2} = 4$, donc l''image du triangle a pour aire 20.', NULL, 15),
    (v_chapitre_id, 'Transforme une figure et compare', 4, 'interactif', '{
  "widget": "transformations",
  "consigne": "Applique une translation, puis une rotation, puis une homothétie à la même figure. Note à chaque fois ce qui change et ce qui reste : les longueurs, les angles, l''orientation. Quelle transformation est la seule à changer la taille ?"
}', NULL, 10),
    (v_chapitre_id, 'Expressions analytiques dans un repère', 5, 'texte', 'Mettre une transformation en formules permet de calculer au lieu de construire. C''est souvent beaucoup plus rapide.

## Le tableau des formules

Pour la translation de vecteur $\vec{u}(a\,;b)$ :
$$\begin{cases} x'' = x + a \\ y'' = y + b\end{cases}$$

Pour l''homothétie de centre $\Omega(p\,;q)$ et de rapport $k$ :
$$\begin{cases} x'' = k x + (1-k)p \\ y'' = k y + (1-k)q\end{cases}$$

Pour la rotation de centre $O$ et d''angle $\theta$ :
$$\begin{cases} x'' = x\cos\theta - y\sin\theta \\ y'' = x\sin\theta + y\cos\theta\end{cases}$$

Pour la symétrie centrale de centre $\Omega(p\,;q)$ :
$$\begin{cases} x'' = 2p - x \\ y'' = 2q - y\end{cases}$$

## Reconnaître une transformation à partir de ses formules

Si on te donne
$$\begin{cases} x'' = x + 3 \\ y'' = y - 5\end{cases}$$

tu reconnais immédiatement une translation de vecteur $(3\,;-5)$.

Si on te donne
$$\begin{cases} x'' = 3x - 4 \\ y'' = 3y + 2\end{cases}$$

les deux coordonnées sont multipliées par le même nombre 3, c''est donc une homothétie de rapport 3.

Pour trouver le centre, tu cherches le point invariant, celui qui vérifie $x'' = x$ et $y'' = y$.

De $x = 3x - 4$ on tire $x = 2$. De $y = 3y + 2$ on tire $y = -1$.

C''est l''homothétie de centre $(2\,;-1)$ et de rapport 3.

## Image d''une droite

Pour trouver l''image d''une droite, deux méthodes.

Tu peux prendre deux points de la droite, calculer leurs images, et écrire l''équation de la droite qui les joint.

Tu peux aussi exprimer $x$ et $y$ en fonction de $x''$ et $y''$, puis remplacer dans l''équation de départ.

Prenons la droite $2x + y - 3 = 0$ et la translation de vecteur $(1\,;4)$.

De $x'' = x + 1$ et $y'' = y + 4$, on tire $x = x'' - 1$ et $y = y'' - 4$.

En remplaçant : $2(x''-1) + (y''-4) - 3 = 0$, soit $2x'' + y'' - 9 = 0$.

L''image est la droite $2x + y - 9 = 0$, parallèle à la première, comme attendu.

## Image d''un cercle

Par une isométrie, le rayon ne change pas, seul le centre bouge.

Par une homothétie de rapport $k$, le rayon est multiplié par $|k|$, et le centre est l''image du centre.

## Exercice d''application

Soit la transformation donnée par $x'' = -x + 6$ et $y'' = -y + 2$. De quelle transformation s''agit-il ? Quelle est l''image du cercle de centre $(1\,;0)$ et de rayon 3 ?

Correction. Les coordonnées sont multipliées par $-1$, c''est donc une homothétie de rapport $-1$, c''est-à-dire une symétrie centrale.

Le centre est le point invariant : $x = -x + 6$ donne $x = 3$, et $y = -y + 2$ donne $y = 1$. Le centre est $(3\,;1)$.

L''image du cercle a pour centre l''image de $(1\,;0)$, soit $(-1 + 6\,;0 + 2) = (5\,;2)$, et pour rayon 3, puisque $|k| = 1$.', NULL, 15),
    (v_chapitre_id, 'Quiz du chapitre 16', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Une isométrie est une transformation qui conserve :",
      "choix": [
        "les distances",
        "seulement les angles",
        "seulement les aires",
        "l''orientation"
      ],
      "bonne": 0,
      "explication": "Conserver les distances entraîne de conserver les angles, les aires, l''alignement et le parallélisme. L''orientation, elle, peut être inversée."
    },
    {
      "question": "La composée de deux symétries orthogonales d''axes parallèles est :",
      "choix": [
        "une translation",
        "une rotation",
        "une homothétie",
        "l''identité"
      ],
      "bonne": 0,
      "explication": "Le vecteur est perpendiculaire aux axes, et sa norme vaut deux fois la distance qui les sépare."
    },
    {
      "question": "Une homothétie de rapport 3 multiplie les aires par :",
      "choix": [
        "9",
        "3",
        "6",
        "1/3"
      ],
      "bonne": 0,
      "explication": "Les longueurs sont multipliées par 3, donc les aires par 3² = 9."
    },
    {
      "question": "La transformation x'' = 3x − 4, y'' = 3y + 2 est :",
      "choix": [
        "une homothétie de rapport 3 et de centre (2 ; −1)",
        "une translation de vecteur (−4 ; 2)",
        "une rotation d''angle 3",
        "une symétrie centrale"
      ],
      "bonne": 0,
      "explication": "Les deux coordonnées sont multipliées par le même nombre, donc c''est une homothétie. Le centre est le point invariant."
    },
    {
      "question": "Dans une symétrie orthogonale, les points invariants sont :",
      "choix": [
        "exactement les points de l''axe",
        "le centre seulement",
        "aucun point",
        "tous les points"
      ],
      "bonne": 0,
      "explication": "Un point de l''axe est sa propre image, puisque l''axe est la médiatrice de tout segment [MM'']."
    },
    {
      "question": "L''homothétie de rapport −1 et de centre Ω est aussi :",
      "choix": [
        "la symétrie centrale de centre Ω",
        "une translation",
        "l''identité",
        "une rotation d''angle 90°"
      ],
      "bonne": 0,
      "explication": "Le vecteur ΩM'' est l''opposé du vecteur ΩM, donc Ω est le milieu de [MM'']."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 16, Transformations du plan : 6 lecons ajoutees.';
END $p1c$;
