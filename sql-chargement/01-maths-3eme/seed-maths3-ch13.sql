-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 13, Coordonnées d''un vecteur
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
  WHERE programme_id = v_programme_id AND ordre = 13;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Coordonnées d''un vecteur', 13, 'Module 15 : Configurations et transformations élémentaires du plan')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 13 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 13 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Les coordonnées d''un vecteur', 1, 'texte', 'Dans un repère, un vecteur se décrit par deux nombres : de combien il avance horizontalement, et de combien il monte. Tout devient alors du calcul.

## Le repère

On se place dans un repère $(O\,;\vec{i}\,;\vec{j})$ du plan. Chaque point $A$ a deux coordonnées, notées $A(x_{A}\,;y_{A})$.

## Coordonnées d''un vecteur défini par deux points

Si $A(x_{A}\,;y_{A})$ et $B(x_{B}\,;y_{B})$, alors

$$\overrightarrow{AB}\begin{pmatrix} x_{B} - x_{A} \\ y_{B} - y_{A} \end{pmatrix}$$

Retiens l''ordre : arrivée moins départ. C''est l''erreur la plus fréquente de tout le chapitre.

Pour $A(1\,;3)$ et $B(5\,;-1)$, on obtient $\overrightarrow{AB}\begin{pmatrix} 5 - 1 \\ -1 - 3 \end{pmatrix}$, c''est-à-dire $\overrightarrow{AB}\begin{pmatrix} 4 \\ -4 \end{pmatrix}$.

## La norme

Dans un repère orthonormé, la longueur du vecteur $\vec{u}\begin{pmatrix} x \\ y \end{pmatrix}$ vaut

$$\|\vec{u}\| = \sqrt{x^{2} + y^{2}}$$

C''est le théorème de Pythagore appliqué au triangle rectangle formé par le déplacement horizontal et le déplacement vertical.

Pour $\overrightarrow{AB}\begin{pmatrix} 4 \\ -4 \end{pmatrix}$, la longueur vaut $\sqrt{16 + 16} = \sqrt{32} = 4\sqrt{2} \approx 5{,}66$.

## Les coordonnées du milieu

Le milieu $I$ du segment $[AB]$ a pour coordonnées

$$I\left(\dfrac{x_{A} + x_{B}}{2}\,;\dfrac{y_{A} + y_{B}}{2}\right)$$

Pour $A(1\,;3)$ et $B(5\,;-1)$, le milieu est $I(3\,;1)$.

## Exercice d''application

On donne $A(-2\,;4)$ et $B(3\,;-8)$. Calcule les coordonnées de $\overrightarrow{AB}$, sa norme, et les coordonnées du milieu de $[AB]$.

Correction. $\overrightarrow{AB}\begin{pmatrix} 3-(-2) \\ -8-4 \end{pmatrix} = \begin{pmatrix} 5 \\ -12 \end{pmatrix}$. Sa norme vaut $\sqrt{25 + 144} = \sqrt{169} = 13$. Le milieu est $I\left(\dfrac{-2+3}{2}\,;\dfrac{4-8}{2}\right)$, soit $I(0{,}5\,;-2)$.', NULL, 15),
    (v_chapitre_id, 'Somme, produit par un réel et colinéarité en coordonnées', 2, 'texte', 'Toutes les opérations sur les vecteurs se font coordonnée par coordonnée. C''est ce qui rend le calcul vectoriel si pratique.

## Les opérations

Pour $\vec{u}\begin{pmatrix} x \\ y \end{pmatrix}$ et $\vec{v}\begin{pmatrix} x'' \\ y'' \end{pmatrix}$, et pour un réel $k$ :

$$\vec{u} + \vec{v}\begin{pmatrix} x + x'' \\ y + y'' \end{pmatrix} \qquad k\vec{u}\begin{pmatrix} kx \\ ky \end{pmatrix}$$

Deux vecteurs sont égaux exactement quand leurs deux coordonnées sont égales.

## Le critère de colinéarité

C''est le résultat le plus utile du chapitre. Les vecteurs $\vec{u}\begin{pmatrix} x \\ y \end{pmatrix}$ et $\vec{v}\begin{pmatrix} x'' \\ y'' \end{pmatrix}$ sont colinéaires si et seulement si

$$xy'' - x''y = 0$$

Ce nombre $xy'' - x''y$ s''appelle le déterminant des deux vecteurs. Un déterminant nul signifie colinéaires, un déterminant non nul signifie non colinéaires.

## Démontrer un alignement

Les points $A(1\,;2)$, $B(3\,;5)$ et $C(7\,;11)$ sont-ils alignés ?

On calcule $\overrightarrow{AB}\begin{pmatrix} 2 \\ 3 \end{pmatrix}$ et $\overrightarrow{AC}\begin{pmatrix} 6 \\ 9 \end{pmatrix}$.

Le déterminant vaut $2 \times 9 - 6 \times 3 = 18 - 18 = 0$. Les vecteurs sont colinéaires, donc les trois points sont alignés.

## Démontrer un parallélogramme

$ABCD$ est un parallélogramme si et seulement si $\overrightarrow{AB} = \overrightarrow{DC}$. Il suffit donc de vérifier l''égalité des deux coordonnées.

## Exercice d''application

On donne $A(0\,;1)$, $B(4\,;3)$, $C(6\,;7)$ et $D(2\,;5)$. Montre que $ABCD$ est un parallélogramme.

Correction. $\overrightarrow{AB}\begin{pmatrix} 4 \\ 2 \end{pmatrix}$ et $\overrightarrow{DC}\begin{pmatrix} 6-2 \\ 7-5 \end{pmatrix} = \begin{pmatrix} 4 \\ 2 \end{pmatrix}$. Les deux vecteurs sont égaux, donc $ABCD$ est un parallélogramme.', NULL, 15),
    (v_chapitre_id, 'Vecteurs orthogonaux dans un repère orthonormé', 3, 'texte', 'Dans un repère orthonormé, un simple calcul permet de savoir si deux vecteurs forment un angle droit.

## Le critère

Dans un repère orthonormé, les vecteurs $\vec{u}\begin{pmatrix} x \\ y \end{pmatrix}$ et $\vec{v}\begin{pmatrix} x'' \\ y'' \end{pmatrix}$ sont orthogonaux si et seulement si

$$xx'' + yy'' = 0$$

Ce nombre $xx'' + yy''$ s''appelle le produit scalaire des deux vecteurs.

Ne confonds pas les deux critères. Pour la colinéarité on croise et on soustrait, pour l''orthogonalité on multiplie en parallèle et on additionne.

## Un exemple

$\vec{u}\begin{pmatrix} 3 \\ 2 \end{pmatrix}$ et $\vec{v}\begin{pmatrix} -4 \\ 6 \end{pmatrix}$ sont-ils orthogonaux ?

On calcule $3 \times (-4) + 2 \times 6 = -12 + 12 = 0$. Oui, ils sont orthogonaux.

## Démontrer qu''un triangle est rectangle

$A(1\,;1)$, $B(4\,;2)$ et $C(2\,;7)$. Le triangle $ABC$ est-il rectangle ?

On calcule $\overrightarrow{AB}\begin{pmatrix} 3 \\ 1 \end{pmatrix}$ et $\overrightarrow{AC}\begin{pmatrix} 1 \\ 6 \end{pmatrix}$. Leur produit scalaire vaut $3 \times 1 + 1 \times 6 = 9$, qui n''est pas nul, donc l''angle en $A$ n''est pas droit.

On essaie en $B$ : $\overrightarrow{BA}\begin{pmatrix} -3 \\ -1 \end{pmatrix}$ et $\overrightarrow{BC}\begin{pmatrix} -2 \\ 5 \end{pmatrix}$. Le produit scalaire vaut $6 - 5 = 1$, non nul non plus.

On essaie en $C$ : $\overrightarrow{CA}\begin{pmatrix} -1 \\ -6 \end{pmatrix}$ et $\overrightarrow{CB}\begin{pmatrix} 2 \\ -5 \end{pmatrix}$. Le produit scalaire vaut $-2 + 30 = 28$. Le triangle n''est donc rectangle en aucun sommet.

## Exercice d''application

Trouve un vecteur orthogonal à $\vec{u}\begin{pmatrix} 5 \\ -2 \end{pmatrix}$.

Correction. Il suffit d''échanger les coordonnées et de changer un signe : $\vec{v}\begin{pmatrix} 2 \\ 5 \end{pmatrix}$ convient, car $5 \times 2 + (-2) \times 5 = 10 - 10 = 0$. Tous les multiples de $\vec{v}$ conviennent aussi.', NULL, 15),
    (v_chapitre_id, 'Quiz : coordonnées de vecteurs', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Pour $A(2\\,;5)$ et $B(7\\,;1)$, les coordonnées de $\\overrightarrow{AB}$ sont :",
      "choix": [
        "$(5\\,;-4)$",
        "$(-5\\,;4)$",
        "$(9\\,;6)$"
      ],
      "bonne": 0,
      "explication": "On fait arrivée moins départ : $7 - 2 = 5$ et $1 - 5 = -4$."
    },
    {
      "question": "La norme du vecteur de coordonnées $(6\\,;8)$ vaut :",
      "choix": [
        "$14$",
        "$10$",
        "$48$"
      ],
      "bonne": 1,
      "explication": "$\\sqrt{36 + 64} = \\sqrt{100} = 10$."
    },
    {
      "question": "Les vecteurs $(2\\,;3)$ et $(6\\,;9)$ sont :",
      "choix": [
        "colinéaires",
        "orthogonaux",
        "ni l''un ni l''autre"
      ],
      "bonne": 0,
      "explication": "Le déterminant vaut $2 \\times 9 - 6 \\times 3 = 0$, donc ils sont colinéaires. Le second est le triple du premier."
    },
    {
      "question": "Les vecteurs $(4\\,;1)$ et $(-1\\,;4)$ sont :",
      "choix": [
        "colinéaires",
        "orthogonaux",
        "égaux"
      ],
      "bonne": 1,
      "explication": "Le produit scalaire vaut $4 \\times (-1) + 1 \\times 4 = 0$, donc ils forment un angle droit."
    },
    {
      "question": "Le milieu de $[AB]$ avec $A(-3\\,;2)$ et $B(5\\,;6)$ est :",
      "choix": [
        "$(1\\,;4)$",
        "$(2\\,;8)$",
        "$(4\\,;2)$"
      ],
      "bonne": 0,
      "explication": "On fait la moyenne des coordonnées : $\\dfrac{-3+5}{2} = 1$ et $\\dfrac{2+6}{2} = 4$."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 5, 'texte', '## Exercice 1

On donne $A(-1\,;2)$, $B(3\,;4)$ et $C(5\,;0)$. Calcule les coordonnées de $\overrightarrow{AB}$, $\overrightarrow{BC}$ et $\overrightarrow{AC}$, puis vérifie la relation de Chasles.

Correction. $\overrightarrow{AB}\begin{pmatrix} 4 \\ 2 \end{pmatrix}$, $\overrightarrow{BC}\begin{pmatrix} 2 \\ -4 \end{pmatrix}$ et $\overrightarrow{AC}\begin{pmatrix} 6 \\ -2 \end{pmatrix}$. On vérifie que $4 + 2 = 6$ et $2 - 4 = -2$, donc $\overrightarrow{AB} + \overrightarrow{BC} = \overrightarrow{AC}$.

## Exercice 2

Avec les mêmes points, le triangle $ABC$ est-il rectangle ?

Correction. Le produit scalaire de $\overrightarrow{BA}\begin{pmatrix} -4 \\ -2 \end{pmatrix}$ et $\overrightarrow{BC}\begin{pmatrix} 2 \\ -4 \end{pmatrix}$ vaut $-8 + 8 = 0$. Le triangle est donc rectangle en $B$.

## Exercice 3

Détermine le réel $m$ pour que les vecteurs $\vec{u}\begin{pmatrix} 3 \\ m \end{pmatrix}$ et $\vec{v}\begin{pmatrix} 6 \\ 10 \end{pmatrix}$ soient colinéaires.

Correction. Le déterminant doit être nul : $3 \times 10 - 6m = 0$, donc $30 = 6m$ et $m = 5$.

## Exercice 4

Détermine le réel $p$ pour que $\vec{u}\begin{pmatrix} 2 \\ p \end{pmatrix}$ et $\vec{v}\begin{pmatrix} -3 \\ 4 \end{pmatrix}$ soient orthogonaux.

Correction. Le produit scalaire doit être nul : $2 \times (-3) + 4p = 0$, donc $4p = 6$ et $p = 1{,}5$.

## Exercice 5

$A(0\,;0)$, $B(6\,;2)$ et $D(1\,;5)$. Trouve les coordonnées de $C$ pour que $ABCD$ soit un parallélogramme.

Correction. Il faut $\overrightarrow{AB} = \overrightarrow{DC}$. On a $\overrightarrow{AB}\begin{pmatrix} 6 \\ 2 \end{pmatrix}$, donc $x_{C} - 1 = 6$ et $y_{C} - 5 = 2$. Ainsi $C(7\,;7)$.', NULL, 15),
    (v_chapitre_id, 'Activité d''intégration : le plan du terrain', 6, 'texte', '## La situation

Un géomètre de Kribi place un repère orthonormé sur le plan d''un terrain, l''unité valant 10 m. Les quatre bornes du terrain ont pour coordonnées $A(0\,;0)$, $B(8\,;0)$, $C(8\,;6)$ et $D(0\,;6)$.

Le propriétaire veut planter un manguier au centre du terrain, et tendre un fil entre $A$ et $C$.

1. Montre que $ABCD$ est un rectangle.
2. Calcule la longueur réelle du fil $[AC]$, en mètres.
3. Donne les coordonnées du point où planter le manguier, puis sa position réelle par rapport à la borne $A$.
4. Le propriétaire veut aussi un second fil allant de $B$ à $D$. Les deux fils se croisent-ils au pied du manguier ? Justifie.

## La solution

1. On calcule $\overrightarrow{AB}\begin{pmatrix} 8 \\ 0 \end{pmatrix}$ et $\overrightarrow{DC}\begin{pmatrix} 8 \\ 0 \end{pmatrix}$. Les deux vecteurs sont égaux, donc $ABCD$ est un parallélogramme. De plus le produit scalaire de $\overrightarrow{AB}\begin{pmatrix} 8 \\ 0 \end{pmatrix}$ et $\overrightarrow{AD}\begin{pmatrix} 0 \\ 6 \end{pmatrix}$ vaut $0 + 0 = 0$, donc l''angle en $A$ est droit. Un parallélogramme ayant un angle droit est un rectangle.

2. $\overrightarrow{AC}\begin{pmatrix} 8 \\ 6 \end{pmatrix}$, donc sa norme vaut $\sqrt{64 + 36} = \sqrt{100} = 10$ unités. Comme une unité vaut 10 m, le fil mesure 100 m.

3. Le centre du rectangle est le milieu de la diagonale $[AC]$, soit $I\left(\dfrac{0+8}{2}\,;\dfrac{0+6}{2}\right) = I(4\,;3)$. En mètres, le manguier se trouve à 40 m vers l''est et 30 m vers le nord de la borne $A$.

4. Le milieu de $[BD]$ a pour coordonnées $\left(\dfrac{8+0}{2}\,;\dfrac{0+6}{2}\right) = (4\,;3)$. C''est exactement le même point. Les deux fils se croisent donc bien au pied du manguier, ce qui confirme que les diagonales d''un rectangle se coupent en leur milieu.

## Ce qu''il faut remarquer

Le repère transforme un problème de terrain en calculs simples. Le géomètre n''a pas besoin de mesurer la diagonale sur place : il la calcule. Retiens surtout les trois outils du chapitre, la norme pour les longueurs, le déterminant pour les alignements, le produit scalaire pour les angles droits.', NULL, 15);

  RAISE NOTICE 'Chapitre 13, Coordonnées d''un vecteur : 6 lecons ajoutees.';
END $m3$;
