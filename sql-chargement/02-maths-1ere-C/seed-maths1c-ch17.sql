-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 17, Espaces vectoriels sur ℝ
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
  WHERE programme_id = v_programme_id AND ordre = 17;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Espaces vectoriels sur ℝ', 17, 'Module 23 : Configurations et transformations élémentaires du plan')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 17 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 17 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Qu''est-ce qu''un espace vectoriel sur ℝ', 1, 'texte', 'Jusqu''ici, tu manipulais des vecteurs du plan. L''idée du chapitre est de dégager les règles qu''ils vérifient, puis de remarquer que beaucoup d''autres objets vérifient les mêmes règles.

## La définition

Un ensemble $E$ est un espace vectoriel sur $\mathbb{R}$ s''il est muni de deux opérations : une addition entre éléments de $E$, et une multiplication d''un élément de $E$ par un réel.

Ces opérations doivent vérifier un petit nombre de règles.

Pour l''addition : elle est commutative, associative, elle possède un élément neutre noté $\vec{0}$, et tout élément possède un opposé.

Pour la multiplication par un réel, avec $\lambda$ et $\mu$ réels et $\vec{u}$, $\vec{v}$ dans $E$ :
$$\lambda(\vec{u} + \vec{v}) = \lambda\vec{u} + \lambda\vec{v}$$
$$(\lambda + \mu)\vec{u} = \lambda\vec{u} + \mu\vec{u}$$
$$\lambda(\mu\vec{u}) = (\lambda\mu)\vec{u}$$
$$1 \cdot \vec{u} = \vec{u}$$

Les éléments de $E$ s''appellent des vecteurs, les réels s''appellent des scalaires.

## Des exemples

L''ensemble des vecteurs du plan est un espace vectoriel sur $\mathbb{R}$. C''est l''exemple fondateur.

L''ensemble des vecteurs de l''espace en est un aussi.

L''ensemble $\mathbb{R}^{2}$ des couples de réels en est un, avec l''addition terme à terme.

L''ensemble des fonctions de $\mathbb{R}$ dans $\mathbb{R}$ en est un. On additionne deux fonctions, on en multiplie une par un réel, et toutes les règles sont vérifiées. Le vecteur nul est la fonction nulle.

L''ensemble des polynômes en est un également.

C''est la force de l''abstraction : un même raisonnement vaudra pour les vecteurs, les fonctions et les polynômes.

## Les sous-espaces vectoriels

Une partie $F$ de $E$ est un sous-espace vectoriel si elle contient $\vec{0}$ et si elle est stable par les deux opérations. Autrement dit, pour tous $\vec{u}$, $\vec{v}$ de $F$ et tout réel $\lambda$, les vecteurs $\vec{u} + \vec{v}$ et $\lambda\vec{u}$ sont encore dans $F$.

En pratique, on vérifie les deux points suivants : $F$ contient le vecteur nul, et pour tous $\vec{u}$, $\vec{v}$ de $F$ et tous réels $\lambda$, $\mu$, le vecteur $\lambda\vec{u} + \mu\vec{v}$ appartient à $F$.

Dans le plan, les sous-espaces vectoriels sont exactement l''ensemble réduit au vecteur nul, les droites passant par l''origine, et le plan tout entier.

Une droite qui ne passe pas par l''origine n''est pas un sous-espace vectoriel, puisqu''elle ne contient pas le vecteur nul.

## Exercice d''application

L''ensemble $F$ des couples $(x\,;y)$ tels que $2x - 3y = 0$ est-il un sous-espace vectoriel de $\mathbb{R}^{2}$ ? Et l''ensemble $G$ des couples tels que $2x - 3y = 5$ ?

Correction. Pour $F$, le couple $(0\,;0)$ vérifie bien $0 = 0$. Et si $(x_{1}\,;y_{1})$ et $(x_{2}\,;y_{2})$ sont dans $F$, alors pour tous réels $\lambda$ et $\mu$,
$$2(\lambda x_{1} + \mu x_{2}) - 3(\lambda y_{1} + \mu y_{2}) = \lambda(2x_{1} - 3y_{1}) + \mu(2x_{2} - 3y_{2}) = 0$$

Donc $F$ est un sous-espace vectoriel. C''est la droite d''équation $2x - 3y = 0$, qui passe par l''origine.

Pour $G$, le couple $(0\,;0)$ donne $0 \neq 5$. Le vecteur nul n''appartient pas à $G$, donc $G$ n''est pas un sous-espace vectoriel.', NULL, 15),
    (v_chapitre_id, 'Familles génératrices, libres, et bases', 2, 'texte', 'Trois mots à ne pas confondre, et qui répondent à trois questions différentes.

## Combinaison linéaire

Une combinaison linéaire de $\vec{u}$ et $\vec{v}$ est un vecteur de la forme
$$\alpha\vec{u} + \beta\vec{v} \quad \text{avec } \alpha \text{ et } \beta \text{ réels}$$

## Famille génératrice

La famille $(\vec{u}, \vec{v})$ est génératrice de $E$ si tout vecteur de $E$ s''écrit comme combinaison linéaire de $\vec{u}$ et $\vec{v}$.

La question est : peut-on tout atteindre ?

## Famille libre

La famille $(\vec{u}, \vec{v})$ est libre si la seule combinaison linéaire nulle est la combinaison triviale :
$$\alpha\vec{u} + \beta\vec{v} = \vec{0} \implies \alpha = \beta = 0$$

Sinon la famille est liée.

La question est : y a-t-il de la redondance ?

Pour deux vecteurs du plan, être libre équivaut à ne pas être colinéaires. En coordonnées, le déterminant $x_{u}y_{v} - y_{u}x_{v}$ doit être non nul.

## Base

Une base est une famille à la fois libre et génératrice. Elle atteint tout, sans redondance.

Dans une base, tout vecteur s''écrit d''une seule et unique façon comme combinaison linéaire. Les coefficients obtenus s''appellent les coordonnées du vecteur dans cette base.

## La dimension

Toutes les bases d''un même espace vectoriel ont le même nombre de vecteurs. Ce nombre s''appelle la dimension.

Le plan vectoriel est de dimension 2, l''espace de dimension 3, une droite vectorielle de dimension 1.

Une conséquence très pratique : en dimension 2, deux vecteurs non colinéaires forment automatiquement une base. Tu n''as pas besoin de vérifier qu''ils engendrent tout, cela découle de la dimension.

## Un calcul complet

Dans $\mathbb{R}^{2}$, soient $\vec{u}(3\,;1)$ et $\vec{v}(-1\,;2)$.

Le déterminant vaut $3 \times 2 - 1 \times (-1) = 7$. Il n''est pas nul, donc la famille est libre, et comme on est en dimension 2, c''est une base.

Décomposons $\vec{w}(5\,;8)$ dans cette base. On cherche $\alpha$ et $\beta$ tels que
$$\begin{cases} 3\alpha - \beta = 5 \\ \alpha + 2\beta = 8\end{cases}$$

De la première, $\beta = 3\alpha - 5$. En reportant, $\alpha + 6\alpha - 10 = 8$, donc $7\alpha = 18$ et $\alpha = \dfrac{18}{7}$.

Alors $\beta = \dfrac{54}{7} - 5 = \dfrac{19}{7}$.

Les coordonnées de $\vec{w}$ dans la base $(\vec{u}, \vec{v})$ sont $\left(\dfrac{18}{7}\,;\dfrac{19}{7}\right)$.

Vérifie : $\dfrac{18}{7} \times 3 + \dfrac{19}{7} \times (-1) = \dfrac{54 - 19}{7} = 5$. C''est bon.

## Exercice d''application

Dans $\mathbb{R}^{2}$, la famille formée de $\vec{u}(2\,;-3)$ et $\vec{v}(-4\,;6)$ est-elle libre ?

Correction. Le déterminant vaut $2 \times 6 - (-3) \times (-4) = 12 - 12 = 0$.

La famille est donc liée. On voit d''ailleurs que $\vec{v} = -2\vec{u}$. Ces deux vecteurs n''engendrent qu''une droite, pas le plan entier.', NULL, 15),
    (v_chapitre_id, 'Famille libre ou famille liée', 3, 'interactif', '{
  "widget": "espace-vectoriel",
  "consigne": "Place $v$ dans la même direction que $u$ : que devient le déterminant, et où peut encore aller $w$ ? Remets ensuite $v$ dans une autre direction et vérifie qu''avec $\\alpha$ et $\\beta$ tu peux atteindre n''importe quel point du plan."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 17', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Une famille de vecteurs est libre lorsque :",
      "choix": [
        "la seule combinaison linéaire nulle a tous ses coefficients nuls",
        "elle engendre tout l''espace",
        "elle contient le vecteur nul",
        "tous ses vecteurs sont unitaires"
      ],
      "bonne": 0,
      "explication": "Sinon, un vecteur s''exprimerait à partir des autres et serait redondant, la famille serait liée."
    },
    {
      "question": "Dans le plan, deux vecteurs sont libres si et seulement si :",
      "choix": [
        "ils ne sont pas colinéaires",
        "ils sont perpendiculaires",
        "ils ont la même norme",
        "leur somme est nulle"
      ],
      "bonne": 0,
      "explication": "La colinéarité est exactement la redondance. On la teste en calculant le déterminant, qui doit être non nul."
    },
    {
      "question": "Une base est une famille :",
      "choix": [
        "libre et génératrice",
        "seulement libre",
        "seulement génératrice",
        "orthonormée"
      ],
      "bonne": 0,
      "explication": "Elle atteint tout l''espace, sans redondance. Chaque vecteur s''y décompose alors d''une seule façon."
    },
    {
      "question": "L''ensemble des couples (x ; y) vérifiant 2x − 3y = 5 :",
      "choix": [
        "n''est pas un sous-espace vectoriel, car il ne contient pas (0 ; 0)",
        "est un sous-espace vectoriel de dimension 1",
        "est un sous-espace vectoriel de dimension 2",
        "est réduit à un point"
      ],
      "bonne": 0,
      "explication": "C''est une droite qui ne passe pas par l''origine. Tout sous-espace vectoriel doit contenir le vecteur nul."
    },
    {
      "question": "La dimension du plan vectoriel est :",
      "choix": [
        "2",
        "1",
        "3",
        "infinie"
      ],
      "bonne": 0,
      "explication": "Toute base du plan contient exactement deux vecteurs, par exemple les deux vecteurs du repère."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 17, Espaces vectoriels sur ℝ : 4 lecons ajoutees.';
END $p1c$;
