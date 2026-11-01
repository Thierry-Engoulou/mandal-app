-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 14, Barycentres
-- Module 23 : Configurations et transformations élémentaires du plan
-- 5 leçons.
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
  WHERE programme_id = v_programme_id AND ordre = 14;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Barycentres', 14, 'Module 23 : Configurations et transformations élémentaires du plan')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 14 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 14 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Barycentre de deux points pondérés', 1, 'texte', 'Le barycentre, c''est le point d''équilibre. Si tu poses deux masses aux extrémités d''une tige, le point où elle tient en équilibre sur ton doigt est le barycentre.

## La définition

Soient $A$ et $B$ deux points, affectés des coefficients $\alpha$ et $\beta$ avec $\alpha + \beta \neq 0$.

Le barycentre $G$ du système $\{(A\,;\alpha), (B\,;\beta)\}$ est l''unique point vérifiant
$$\alpha \vec{GA} + \beta \vec{GB} = \vec{0}$$

La condition $\alpha + \beta \neq 0$ est essentielle. Sans elle, le point n''existe pas.

## La formule de position

En introduisant un point quelconque $O$ dans la relation, on obtient
$$\vec{OG} = \dfrac{\alpha \vec{OA} + \beta \vec{OB}}{\alpha + \beta}$$

En coordonnées, cela donne
$$x_{G} = \dfrac{\alpha x_{A} + \beta x_{B}}{\alpha + \beta} \qquad y_{G} = \dfrac{\alpha y_{A} + \beta y_{B}}{\alpha + \beta}$$

C''est une moyenne pondérée des coordonnées.

## Les propriétés à connaître

$G$ appartient toujours à la droite $(AB)$.

Si $\alpha$ et $\beta$ sont de même signe, $G$ est entre $A$ et $B$. Sinon, il est à l''extérieur du segment.

$G$ se trouve plus près du point dont le coefficient est le plus grand. C''est logique : la masse la plus lourde attire le point d''équilibre.

Si $\alpha = \beta$, le barycentre est le milieu de $[AB]$. On l''appelle alors isobarycentre.

Multiplier tous les coefficients par un même nombre non nul ne change pas le barycentre. Les systèmes $\{(A\,;2),(B\,;6)\}$ et $\{(A\,;1),(B\,;3)\}$ ont le même barycentre.

## Un calcul

Soient $A(1\,;4)$ et $B(7\,;-2)$. Cherchons le barycentre de $\{(A\,;2),(B\,;1)\}$.
$$x_{G} = \dfrac{2 \times 1 + 1 \times 7}{3} = 3 \qquad y_{G} = \dfrac{2 \times 4 + 1 \times (-2)}{3} = 2$$

Donc $G(3\,;2)$. Il est plus proche de $A$, dont le coefficient est le double. On vérifie d''ailleurs que $\vec{AG} = \dfrac{1}{3}\vec{AB}$.

## Exercice d''application

Soient $A(-2\,;3)$ et $B(4\,;0)$. Trouve le barycentre de $\{(A\,;3),(B\,;-1)\}$ et dis où il se situe par rapport au segment.

Correction. La somme des coefficients vaut 2, qui n''est pas nulle, donc le barycentre existe.
$$x_{G} = \dfrac{3 \times (-2) - 4}{2} = -5 \qquad y_{G} = \dfrac{3 \times 3 - 0}{2} = 4{,}5$$

Donc $G(-5\,;4{,}5)$. Les coefficients sont de signes contraires, et $G$ se trouve bien à l''extérieur du segment, au-delà de $A$.', NULL, 15),
    (v_chapitre_id, 'Barycentre de trois ou quatre points, associativité', 2, 'texte', 'La définition s''étend naturellement, et une propriété très pratique permet de simplifier les calculs.

## La définition générale

Le barycentre de $\{(A\,;\alpha),(B\,;\beta),(C\,;\gamma)\}$ avec $\alpha + \beta + \gamma \neq 0$ est l''unique point $G$ tel que
$$\alpha\vec{GA} + \beta\vec{GB} + \gamma\vec{GC} = \vec{0}$$

En coordonnées,
$$x_{G} = \dfrac{\alpha x_{A} + \beta x_{B} + \gamma x_{C}}{\alpha + \beta + \gamma}$$

et de même pour $y_{G}$.

## L''isobarycentre d''un triangle

Quand les trois coefficients sont égaux, $G$ est le centre de gravité du triangle. Il se trouve à l''intersection des trois médianes, aux deux tiers de chaque médiane en partant du sommet.

## L''associativité, la propriété qui fait gagner du temps

Tu peux remplacer deux points par leur barycentre partiel, affecté de la somme de leurs coefficients.

Pour $\{(A\,;2),(B\,;3),(C\,;1)\}$, appelle $H$ le barycentre de $\{(A\,;2),(B\,;3)\}$.

Alors $G$ est le barycentre de $\{(H\,;5),(C\,;1)\}$.

Cette propriété permet de construire $G$ à la règle, en deux étapes au lieu de chercher directement un point dans le plan.

## Une construction

Soient $A$, $B$, $C$ trois points et $G$ le barycentre de $\{(A\,;1),(B\,;1),(C\,;2)\}$.

Le barycentre de $\{(A\,;1),(B\,;1)\}$ est le milieu $I$ de $[AB]$.

Donc $G$ est le barycentre de $\{(I\,;2),(C\,;2)\}$, c''est-à-dire le milieu de $[IC]$.

## Le théorème qui sert partout

Pour tout point $M$ du plan,
$$\alpha\vec{MA} + \beta\vec{MB} + \gamma\vec{MC} = (\alpha + \beta + \gamma)\,\vec{MG}$$

Cette égalité transforme une somme de trois vecteurs en un seul. C''est l''outil central des lignes de niveau.

## Exercice d''application

Soient $A(0\,;0)$, $B(6\,;0)$ et $C(0\,;9)$. Trouve le barycentre de $\{(A\,;1),(B\,;2),(C\,;3)\}$, puis retrouve-le par associativité.

Correction. La somme vaut 6.
$$x_{G} = \dfrac{0 + 12 + 0}{6} = 2 \qquad y_{G} = \dfrac{0 + 0 + 27}{6} = 4{,}5$$

Donc $G(2\,;4{,}5)$.

Par associativité, soit $H$ le barycentre de $\{(A\,;1),(B\,;2)\}$, de coordonnées $\left(\dfrac{12}{3}\,;0\right) = (4\,;0)$.

Alors $G$ est le barycentre de $\{(H\,;3),(C\,;3)\}$, donc le milieu de $[HC]$, soit $\left(\dfrac{4+0}{2}\,;\dfrac{0+9}{2}\right) = (2\,;4{,}5)$. Les deux méthodes concordent.', NULL, 15),
    (v_chapitre_id, 'Déplace les poids, suis le barycentre', 3, 'interactif', '{
  "widget": "barycentre",
  "consigne": "Mets le même poids aux trois points : où tombe $G$ ? Augmente ensuite fortement un seul poids et regarde $G$ se rapprocher de ce sommet. Essaie enfin un poids négatif."
}', NULL, 10),
    (v_chapitre_id, 'Les lignes de niveau', 4, 'texte', 'Une ligne de niveau, c''est l''ensemble des points $M$ pour lesquels une certaine expression garde une valeur fixée. Le barycentre sert à reconnaître la figure obtenue.

## La ligne de niveau de ‖αMA + βMB‖

L''expression se réduit grâce au barycentre $G$ :
$$\|\alpha\vec{MA} + \beta\vec{MB}\| = |\alpha + \beta| \times MG$$

L''ensemble des points tels que cette norme vaut $k$ est donc l''ensemble des points tels que
$$MG = \dfrac{k}{|\alpha + \beta|}$$

C''est un cercle de centre $G$. Si $k = 0$, c''est le point $G$ seul.

Attention au cas $\alpha + \beta = 0$. L''expression devient alors $\alpha\vec{BA}$, qui est un vecteur constant. L''ensemble est soit vide, soit le plan entier.

## La ligne de niveau de MA² + MB²

En introduisant le milieu $I$ de $[AB]$ :
$$MA^{2} + MB^{2} = 2MI^{2} + \dfrac{AB^{2}}{2}$$

C''est le théorème de la médiane. L''ensemble des points tels que $MA^{2} + MB^{2} = k$ est donc un cercle de centre $I$, de rayon
$$r = \sqrt{\dfrac{k}{2} - \dfrac{AB^{2}}{4}}$$

Il n''existe que si l''expression sous la racine est positive.

## La ligne de niveau de $\vec{MA} \cdot \vec{MB}$

Toujours avec le milieu $I$ :
$$\vec{MA} \cdot \vec{MB} = MI^{2} - \dfrac{AB^{2}}{4}$$

L''ensemble des points tels que ce produit scalaire vaut $k$ est un cercle de centre $I$ et de rayon $\sqrt{k + \dfrac{AB^{2}}{4}}$.

Le cas $k = 0$ est particulièrement important : l''ensemble est alors le cercle de diamètre $[AB]$. C''est la traduction analytique du fait qu''un angle inscrit dans un demi-cercle est droit.

## La ligne de niveau de MA² − MB²

$$MA^{2} - MB^{2} = 2\,\vec{IM} \cdot \vec{BA}$$

Cette expression est affine en les coordonnées de $M$. L''ensemble est donc une droite, perpendiculaire à $(AB)$.

## Un exemple complet

Soient $A(0\,;0)$ et $B(4\,;0)$. Détermine l''ensemble des points $M$ tels que $\vec{MA} \cdot \vec{MB} = 5$.

Le milieu est $I(2\,;0)$, et $AB = 4$.

Donc $MI^{2} - 4 = 5$, soit $MI^{2} = 9$ et $MI = 3$.

L''ensemble est le cercle de centre $(2\,;0)$ et de rayon 3.

Vérifions avec un point. Le point $M(5\,;0)$ est sur ce cercle. On a $\vec{MA}(-5\,;0)$ et $\vec{MB}(-1\,;0)$, donc le produit scalaire vaut 5. C''est bon.

## Exercice d''application

Soient $A(-3\,;0)$ et $B(3\,;0)$. Détermine l''ensemble des points $M$ tels que $MA^{2} + MB^{2} = 26$.

Correction. Le milieu est l''origine $O$, et $AB = 6$.

Le théorème de la médiane donne $2MO^{2} + \dfrac{36}{2} = 26$, soit $2MO^{2} = 8$ et $MO = 2$.

L''ensemble est le cercle de centre $O$ et de rayon 2.

Vérifie avec $M(0\,;2)$ : $MA^{2} = 9 + 4 = 13$ et $MB^{2} = 13$, dont la somme vaut 26.', NULL, 15),
    (v_chapitre_id, 'Quiz du chapitre 14', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Le barycentre de {(A ; α), (B ; β)} existe à condition que :",
      "choix": [
        "α + β ≠ 0",
        "α et β soient positifs",
        "α = β",
        "A soit différent de B"
      ],
      "bonne": 0,
      "explication": "Si la somme des coefficients est nulle, la relation vectorielle n''a pas de solution et le barycentre n''existe pas."
    },
    {
      "question": "Le barycentre de {(A ; 2), (B ; 1)} se trouve :",
      "choix": [
        "sur [AB], plus près de A",
        "sur [AB], plus près de B",
        "au milieu de [AB]",
        "à l''extérieur de [AB]"
      ],
      "bonne": 0,
      "explication": "Le point d''équilibre se rapproche du plus gros coefficient. On a d''ailleurs AG = AB/3."
    },
    {
      "question": "L''isobarycentre des trois sommets d''un triangle est :",
      "choix": [
        "le centre de gravité",
        "le centre du cercle circonscrit",
        "l''orthocentre",
        "le milieu d''un côté"
      ],
      "bonne": 0,
      "explication": "C''est le point d''intersection des médianes, situé aux deux tiers de chacune en partant du sommet."
    },
    {
      "question": "L''ensemble des points M tels que $\\vec{MA} \\cdot \\vec{MB} = 0$ est :",
      "choix": [
        "le cercle de diamètre [AB]",
        "la droite (AB)",
        "la médiatrice de [AB]",
        "le point milieu de [AB]"
      ],
      "bonne": 0,
      "explication": "C''est la traduction du fait que l''angle AMB est droit, donc que M voit [AB] sous un angle droit."
    },
    {
      "question": "Multiplier tous les coefficients d''un barycentre par 5 :",
      "choix": [
        "ne change pas le barycentre",
        "multiplie ses coordonnées par 5",
        "le déplace vers A",
        "le fait disparaître"
      ],
      "bonne": 0,
      "explication": "Les coefficients apparaissent au numérateur et au dénominateur, le facteur 5 se simplifie."
    },
    {
      "question": "L''ensemble des points M tels que MA² − MB² = k est :",
      "choix": [
        "une droite perpendiculaire à (AB)",
        "un cercle de centre le milieu de [AB]",
        "la droite (AB)",
        "un point"
      ],
      "bonne": 0,
      "explication": "L''expression se ramène à $2\\,\\vec{IM} \\cdot \\vec{BA}$, qui est affine en les coordonnées de M. L''ensemble est donc une droite."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 14, Barycentres : 5 lecons ajoutees.';
END $p1c$;
