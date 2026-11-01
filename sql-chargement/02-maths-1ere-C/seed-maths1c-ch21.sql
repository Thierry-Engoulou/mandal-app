-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 21, Les sphères
-- Module 24 : Solides de l'espace
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
  WHERE programme_id = v_programme_id AND ordre = 21;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Les sphères', 21, 'Module 24 : Solides de l''espace')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 21 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 21 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'L''équation cartésienne d''une sphère', 1, 'texte', 'La sphère est à l''espace ce que le cercle est au plan. Les formules se ressemblent, avec une coordonnée de plus.

## La définition

La sphère de centre $\Omega$ et de rayon $R$ est l''ensemble des points $M$ de l''espace tels que $\Omega M = R$.

La boule, elle, est l''ensemble des points tels que $\Omega M \leq R$. La sphère n''est que la surface, la boule est pleine.

## L''équation

Dans un repère orthonormé, la sphère de centre $\Omega(a\,;b\,;c)$ et de rayon $R$ a pour équation
$$(x - a)^{2} + (y - b)^{2} + (z - c)^{2} = R^{2}$$

C''est exactement la traduction de $\Omega M^{2} = R^{2}$.

## L''équation développée

En développant, on obtient
$$x^{2} + y^{2} + z^{2} - 2ax - 2by - 2cz + e = 0$$

Pour retrouver le centre et le rayon, tu regroupes en carrés, comme pour le cercle.

Prenons $x^{2} + y^{2} + z^{2} - 4x + 6y - 2z - 11 = 0$.

On écrit $x^{2} - 4x = (x-2)^{2} - 4$, puis $y^{2} + 6y = (y+3)^{2} - 9$, puis $z^{2} - 2z = (z-1)^{2} - 1$.

L''équation devient
$$(x-2)^{2} + (y+3)^{2} + (z-1)^{2} - 4 - 9 - 1 - 11 = 0$$
$$(x-2)^{2} + (y+3)^{2} + (z-1)^{2} = 25$$

C''est la sphère de centre $(2\,;-3\,;1)$ et de rayon 5.

## Attention aux faux cas

Si après regroupement le second membre est négatif, l''ensemble est vide.

S''il vaut exactement 0, l''ensemble se réduit au centre, un point unique.

Calcule donc toujours jusqu''au bout avant de conclure.

## La sphère de diamètre [AB]

Un point $M$ appartient à la sphère de diamètre $[AB]$ si et seulement si
$$\vec{MA} \cdot \vec{MB} = 0$$

C''est l''extension à l''espace du cercle de diamètre $[AB]$. L''angle $\widehat{AMB}$ est droit.

Cette caractérisation donne directement l''équation, sans passer par le centre et le rayon.

Pour $A(1\,;0\,;0)$ et $B(3\,;2\,;4)$ :
$$(1-x)(3-x) + (0-y)(2-y) + (0-z)(4-z) = 0$$
$$3 - 4x + x^{2} - 2y + y^{2} - 4z + z^{2} = 0$$

Le centre est le milieu $(2\,;1\,;2)$ et le rayon vaut la moitié de $AB$, soit $\dfrac{\sqrt{4+4+16}}{2} = \dfrac{\sqrt{24}}{2} = \sqrt{6}$.

## Exercice d''application

Détermine le centre et le rayon de la sphère d''équation $x^{2} + y^{2} + z^{2} + 2x - 4y + 1 = 0$.

Correction. On regroupe : $x^{2} + 2x = (x+1)^{2} - 1$ et $y^{2} - 4y = (y-2)^{2} - 4$. Le terme en $z$ est déjà un carré.

L''équation devient $(x+1)^{2} + (y-2)^{2} + z^{2} - 1 - 4 + 1 = 0$, soit
$$(x+1)^{2} + (y-2)^{2} + z^{2} = 4$$

C''est la sphère de centre $(-1\,;2\,;0)$ et de rayon 2.', NULL, 15),
    (v_chapitre_id, 'Sphère et plan, sphère et droite', 2, 'texte', 'Que se passe-t-il quand on coupe une sphère ? Tout dépend d''une seule grandeur : la distance du centre à l''objet qui coupe.

## Sphère et plan

Soit une sphère de centre $\Omega$ et de rayon $R$, et un plan $(P)$. Note $d$ la distance de $\Omega$ au plan.

Si $d > R$, le plan ne touche pas la sphère. L''intersection est vide.

Si $d = R$, le plan est tangent à la sphère. L''intersection est un point unique, le projeté orthogonal de $\Omega$ sur $(P)$.

Si $d < R$, le plan coupe la sphère suivant un cercle de centre $H$, projeté orthogonal de $\Omega$, et de rayon
$$r = \sqrt{R^{2} - d^{2}}$$

Cette formule vient du théorème de Pythagore dans le triangle rectangle formé par $\Omega$, $H$ et un point du cercle.

## Le grand cercle

Quand le plan passe par le centre, on a $d = 0$ et $r = R$. On obtient alors un grand cercle, le plus grand possible sur la sphère.

Sur la Terre, l''équateur est un grand cercle, les parallèles ne le sont pas.

## Un calcul

Soit la sphère de centre $\Omega(1\,;2\,;-1)$ et de rayon 6, et le plan $2x - y + 2z - 3 = 0$.

La distance vaut
$$d = \dfrac{|2 - 2 - 2 - 3|}{\sqrt{4 + 1 + 4}} = \dfrac{5}{3} \approx 1{,}67$$

Comme $d < 6$, le plan coupe la sphère. Le rayon du cercle de section vaut
$$r = \sqrt{36 - \dfrac{25}{9}} = \sqrt{\dfrac{324 - 25}{9}} = \dfrac{\sqrt{299}}{3} \approx 5{,}76$$

## Sphère et droite

Même principe, avec la distance du centre à la droite.

Si $d > R$, la droite ne coupe pas la sphère.

Si $d = R$, elle est tangente et touche en un point.

Si $d < R$, elle coupe la sphère en deux points. La corde ainsi formée a pour longueur $2\sqrt{R^{2} - d^{2}}$.

## La méthode par substitution

Pour trouver les points d''intersection, tu remplaces la représentation paramétrique de la droite dans l''équation de la sphère. Tu obtiens une équation du second degré en $t$.

Le discriminant décide : deux solutions, une solution double ou aucune. C''est exactement la traduction algébrique des trois cas géométriques.

## Un exemple

Soit la sphère $x^{2} + y^{2} + z^{2} = 9$ et la droite $x = t$, $y = t$, $z = 1$.

En substituant : $t^{2} + t^{2} + 1 = 9$, donc $2t^{2} = 8$ et $t = \pm 2$.

Il y a deux points d''intersection, $(2\,;2\,;1)$ et $(-2\,;-2\,;1)$.

La corde a pour longueur $\sqrt{16 + 16 + 0} = \sqrt{32} \approx 5{,}66$.

Vérifions avec la formule. La distance du centre $O$ à la droite est la distance de $O$ au point le plus proche. En projetant, on trouve $d = 1$. Alors $2\sqrt{9 - 1} = 2\sqrt{8} = \sqrt{32}$. Les deux concordent.

## Le plan tangent

Le plan tangent à la sphère en un point $A$ de celle-ci est le plan passant par $A$ et de vecteur normal $\vec{\Omega A}$.

Pour la sphère $x^{2} + y^{2} + z^{2} = 9$ et le point $A(2\,;2\,;1)$, qui est bien sur la sphère puisque $4 + 4 + 1 = 9$, le plan tangent a pour équation
$$2(x - 2) + 2(y - 2) + (z - 1) = 0 \quad \text{soit} \quad 2x + 2y + z - 9 = 0$$

## Exercice d''application

Soit la sphère de centre $\Omega(0\,;0\,;0)$ et de rayon 5, et le plan $z = 3$. Détermine la nature et les éléments de l''intersection.

Correction. La distance du centre au plan vaut 3, qui est inférieure à 5.

L''intersection est donc un cercle, de centre le projeté de $\Omega$, c''est-à-dire $(0\,;0\,;3)$, et de rayon
$$r = \sqrt{25 - 9} = 4$$

C''est le cercle d''équations $x^{2} + y^{2} = 16$ et $z = 3$.', NULL, 15),
    (v_chapitre_id, 'Coupe une sphère par un plan', 3, 'interactif', '{
  "widget": "sphere-section",
  "consigne": "Pars de $R = 4$ et fais monter $d$ doucement. À quelle valeur de $d$ le cercle de section disparaît-il ? Place-toi ensuite à $d = 0$ : comment s''appelle le cercle obtenu, et que vaut son rayon ?"
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 21', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "La sphère de centre (2 ; −3 ; 1) et de rayon 5 a pour équation :",
      "choix": [
        "(x−2)² + (y+3)² + (z−1)² = 25",
        "(x+2)² + (y−3)² + (z+1)² = 25",
        "(x−2)² + (y−3)² + (z−1)² = 5",
        "x² + y² + z² = 25"
      ],
      "bonne": 0,
      "explication": "On soustrait les coordonnées du centre et on élève le rayon au carré."
    },
    {
      "question": "Un plan est à la distance d du centre d''une sphère de rayon R, avec d < R. L''intersection est :",
      "choix": [
        "un cercle de rayon √(R² − d²)",
        "un point",
        "vide",
        "un cercle de rayon R − d"
      ],
      "bonne": 0,
      "explication": "C''est le théorème de Pythagore dans le triangle rectangle formé par le centre, le projeté et un point du cercle."
    },
    {
      "question": "Un plan passant par le centre d''une sphère la coupe suivant :",
      "choix": [
        "un grand cercle de rayon R",
        "un point",
        "un cercle de rayon R/2",
        "rien"
      ],
      "bonne": 0,
      "explication": "La distance vaut 0, donc r = √(R² − 0) = R. C''est le plus grand cercle possible sur la sphère, comme l''équateur sur la Terre."
    },
    {
      "question": "Le plan tangent à une sphère en un point A de celle-ci a pour vecteur normal :",
      "choix": [
        "le vecteur $\\vec{\\Omega A}$",
        "un vecteur quelconque du plan",
        "le vecteur nul",
        "le vecteur $\\vec{OA}$ avec O l''origine"
      ],
      "bonne": 0,
      "explication": "Le rayon est perpendiculaire au plan tangent, exactement comme pour le cercle et sa tangente."
    },
    {
      "question": "Pour trouver l''intersection d''une droite et d''une sphère, on obtient une équation :",
      "choix": [
        "du second degré en t, dont le discriminant donne le nombre de points",
        "du premier degré en t",
        "sans solution",
        "à trois inconnues"
      ],
      "bonne": 0,
      "explication": "On substitue la représentation paramétrique dans l''équation de la sphère. Le signe du discriminant traduit les trois cas géométriques."
    },
    {
      "question": "L''ensemble des points M tels que $\\vec{MA} \\cdot \\vec{MB} = 0$ dans l''espace est :",
      "choix": [
        "la sphère de diamètre [AB]",
        "le cercle de diamètre [AB]",
        "le plan médiateur de [AB]",
        "la droite (AB)"
      ],
      "bonne": 0,
      "explication": "C''est l''extension à l''espace du cercle de diamètre [AB]. L''angle AMB est droit en tout point de cette sphère."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 21, Les sphères : 4 lecons ajoutees.';
END $p1c$;
