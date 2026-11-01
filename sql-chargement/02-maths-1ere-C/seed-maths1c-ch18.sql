-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 18, Matrices et applications linéaires
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
  WHERE programme_id = v_programme_id AND ordre = 18;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Matrices et applications linéaires', 18, 'Module 23 : Configurations et transformations élémentaires du plan')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 18 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 18 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Les matrices : présentation et vocabulaire', 1, 'texte', 'Une matrice, c''est un tableau de nombres rangés en lignes et en colonnes. Derrière ce tableau se cachent des systèmes, des transformations et des données.

## Le vocabulaire

Une matrice de taille $n \times p$ possède $n$ lignes et $p$ colonnes. On note toujours les lignes en premier.

$$A = \begin{pmatrix} 2 & -1 & 0 \\ 5 & 3 & 7 \end{pmatrix}$$

Cette matrice est de taille $2 \times 3$. Le coefficient $a_{21}$, situé à la deuxième ligne et à la première colonne, vaut 5.

Une matrice carrée a autant de lignes que de colonnes.

Une matrice colonne a une seule colonne, une matrice ligne une seule ligne.

## Les matrices particulières

La matrice nulle n''a que des zéros.

La matrice identité d''ordre $n$, notée $I_{n}$, a des 1 sur la diagonale et des 0 partout ailleurs.
$$I_{2} = \begin{pmatrix} 1 & 0 \\ 0 & 1 \end{pmatrix}$$

Une matrice diagonale n''a de coefficients non nuls que sur sa diagonale.

La transposée de $A$, notée $^{t}A$, s''obtient en échangeant lignes et colonnes.

## À quoi ça sert

Une matrice peut coder un système d''équations, une transformation du plan, les liaisons d''un graphe, ou encore un tableau de données.

Le système
$$\begin{cases} 2x - y = 4 \\ 3x + 5y = 1 \end{cases}$$

s''écrit $AX = B$ avec
$$A = \begin{pmatrix} 2 & -1 \\ 3 & 5 \end{pmatrix} \qquad X = \begin{pmatrix} x \\ y \end{pmatrix} \qquad B = \begin{pmatrix} 4 \\ 1 \end{pmatrix}$$

Toute la théorie des systèmes se ramène alors à savoir inverser $A$.

## Exercice d''application

Écris la matrice $A$ de taille $3 \times 2$ dont le coefficient de la ligne $i$ et de la colonne $j$ vaut $i + 2j$.

Correction. On calcule case par case.

Première ligne : $1 + 2 = 3$ et $1 + 4 = 5$.

Deuxième ligne : $2 + 2 = 4$ et $2 + 4 = 6$.

Troisième ligne : $3 + 2 = 5$ et $3 + 4 = 7$.

$$A = \begin{pmatrix} 3 & 5 \\ 4 & 6 \\ 5 & 7 \end{pmatrix}$$', NULL, 15),
    (v_chapitre_id, 'Les opérations sur les matrices', 2, 'texte', 'Addition, multiplication par un réel, produit, inverse. Les trois premières sont simples, la quatrième demande de l''attention.

## Addition et multiplication par un réel

On additionne case par case, à condition que les deux matrices aient la même taille.

On multiplie par un réel en multipliant chaque case.

$$2\begin{pmatrix} 1 & 3 \\ 0 & -2 \end{pmatrix} + \begin{pmatrix} 4 & -1 \\ 5 & 2 \end{pmatrix} = \begin{pmatrix} 6 & 5 \\ 5 & -2 \end{pmatrix}$$

## Le produit de deux matrices

Pour multiplier $A$ de taille $n \times p$ par $B$ de taille $p \times q$, il faut que le nombre de colonnes de $A$ soit égal au nombre de lignes de $B$. Le résultat est de taille $n \times q$.

Le coefficient de la ligne $i$ et de la colonne $j$ du produit s''obtient en parcourant la ligne $i$ de $A$ et la colonne $j$ de $B$, en multipliant terme à terme et en additionnant.

Calculons
$$\begin{pmatrix} 2 & -1 \\ 3 & 5 \end{pmatrix} \begin{pmatrix} 1 & 4 \\ 0 & -2 \end{pmatrix}$$

Première ligne, première colonne : $2 \times 1 + (-1) \times 0 = 2$.

Première ligne, deuxième colonne : $2 \times 4 + (-1) \times (-2) = 10$.

Deuxième ligne, première colonne : $3 \times 1 + 5 \times 0 = 3$.

Deuxième ligne, deuxième colonne : $3 \times 4 + 5 \times (-2) = 2$.

$$\text{Résultat} = \begin{pmatrix} 2 & 10 \\ 3 & 2 \end{pmatrix}$$

## Le produit n''est pas commutatif

En général $AB \neq BA$. C''est la grande différence avec les nombres.

Vérifie-le en calculant le produit dans l''autre sens sur l''exemple précédent. Tu obtiendras une matrice différente.

Autre surprise : un produit de deux matrices non nulles peut être nul. Par exemple
$$\begin{pmatrix} 1 & 0 \\ 0 & 0 \end{pmatrix}\begin{pmatrix} 0 & 0 \\ 0 & 1 \end{pmatrix} = \begin{pmatrix} 0 & 0 \\ 0 & 0 \end{pmatrix}$$

Tu ne peux donc pas simplifier une égalité matricielle comme tu le ferais avec des nombres.

## Le déterminant d''une matrice 2 × 2

$$\det\begin{pmatrix} a & b \\ c & d \end{pmatrix} = ad - bc$$

## L''inverse d''une matrice 2 × 2

$A$ est inversible si et seulement si son déterminant est non nul. Dans ce cas
$$A^{-1} = \dfrac{1}{ad - bc}\begin{pmatrix} d & -b \\ -c & a \end{pmatrix}$$

Tu échanges $a$ et $d$, tu changes le signe de $b$ et de $c$, et tu divises tout par le déterminant.

L''inverse vérifie $AA^{-1} = A^{-1}A = I_{2}$.

## Résoudre un système avec l''inverse

Si $AX = B$ et que $A$ est inversible, alors $X = A^{-1}B$.

Reprenons
$$A = \begin{pmatrix} 2 & -1 \\ 3 & 5 \end{pmatrix} \qquad B = \begin{pmatrix} 4 \\ 1 \end{pmatrix}$$

Le déterminant vaut $2 \times 5 - (-1) \times 3 = 13$.

$$A^{-1} = \dfrac{1}{13}\begin{pmatrix} 5 & 1 \\ -3 & 2 \end{pmatrix}$$

$$X = \dfrac{1}{13}\begin{pmatrix} 5 & 1 \\ -3 & 2 \end{pmatrix}\begin{pmatrix} 4 \\ 1 \end{pmatrix} = \dfrac{1}{13}\begin{pmatrix} 21 \\ -10 \end{pmatrix}$$

Donc $x = \dfrac{21}{13}$ et $y = -\dfrac{10}{13}$.

Vérifie dans la première équation : $2 \times \dfrac{21}{13} + \dfrac{10}{13} = \dfrac{42 + 10}{13} = 4$. C''est bon.

## Exercice d''application

La matrice $M = \begin{pmatrix} 3 & 1 \\ 5 & 2 \end{pmatrix}$ est-elle inversible ? Si oui, calcule son inverse et vérifie le résultat.

Correction. Le déterminant vaut $3 \times 2 - 1 \times 5 = 1$. Il n''est pas nul, donc $M$ est inversible.

$$M^{-1} = \dfrac{1}{1}\begin{pmatrix} 2 & -1 \\ -5 & 3 \end{pmatrix} = \begin{pmatrix} 2 & -1 \\ -5 & 3 \end{pmatrix}$$

Vérification : $\begin{pmatrix} 3 & 1 \\ 5 & 2 \end{pmatrix}\begin{pmatrix} 2 & -1 \\ -5 & 3 \end{pmatrix} = \begin{pmatrix} 6 - 5 & -3 + 3 \\ 10 - 10 & -5 + 6\end{pmatrix} = \begin{pmatrix} 1 & 0 \\ 0 & 1\end{pmatrix}$. C''est bien l''identité.', NULL, 15),
    (v_chapitre_id, 'Les applications linéaires', 3, 'texte', 'Une application linéaire, c''est une application entre espaces vectoriels qui respecte les deux opérations.

## La définition

$f$ de $E$ vers $F$ est linéaire si, pour tous vecteurs $\vec{u}$, $\vec{v}$ de $E$ et tout réel $\lambda$ :
$$f(\vec{u} + \vec{v}) = f(\vec{u}) + f(\vec{v}) \qquad f(\lambda\vec{u}) = \lambda f(\vec{u})$$

Ces deux conditions se résument en une seule :
$$f(\lambda\vec{u} + \mu\vec{v}) = \lambda f(\vec{u}) + \mu f(\vec{v})$$

## Une conséquence immédiate

Toute application linéaire envoie le vecteur nul sur le vecteur nul :
$$f(\vec{0}) = \vec{0}$$

C''est le test le plus rapide. Si $f(\vec{0}) \neq \vec{0}$, l''application n''est pas linéaire, et ce n''est pas la peine d''aller plus loin.

## Linéaire ou affine ?

L''application $f(x\,;y) = (2x - y\,;x + 3y)$ est linéaire. Elle envoie bien $(0\,;0)$ sur $(0\,;0)$, et chaque coordonnée de l''image est une combinaison linéaire de $x$ et $y$, sans terme constant.

L''application $g(x\,;y) = (2x - y + 1\,;x + 3y)$ n''est pas linéaire, à cause du $+1$. Elle est affine.

C''est exactement la même distinction qu''entre $x \mapsto 3x$ et $x \mapsto 3x + 2$.

## Des exemples géométriques

Les homothéties de centre $O$ sont linéaires. Les rotations de centre $O$ aussi. Les symétries orthogonales d''axe passant par $O$ également.

Les translations de vecteur non nul ne sont pas linéaires, puisqu''elles déplacent l''origine.

## Le noyau et l''image

Le noyau de $f$, noté $\ker f$, est l''ensemble des vecteurs qui s''écrasent sur zéro :
$$\ker f = \{\vec{u} \in E \;\text{tels que}\; f(\vec{u}) = \vec{0}\}$$

L''image de $f$, notée $\text{Im} f$, est l''ensemble de tous les vecteurs atteints.

Ce sont tous deux des sous-espaces vectoriels.

## Le lien avec l''injectivité

$f$ est injective si et seulement si son noyau est réduit au vecteur nul.

C''est beaucoup plus simple à vérifier que la définition générale de l''injectivité. Tu résous $f(\vec{u}) = \vec{0}$ : si la seule solution est le vecteur nul, $f$ est injective.

## Le théorème du rang

$$\dim(\ker f) + \dim(\text{Im} f) = \dim E$$

Ce qui est écrasé plus ce qui est atteint fait toujours la dimension de départ.

Pour une application linéaire du plan dans le plan, si le noyau est une droite, l''image est aussi une droite. Si le noyau est réduit à zéro, l''image est le plan entier et $f$ est bijective.

## Exercice d''application

Soit $f(x\,;y) = (2x - 4y\,;-x + 2y)$. Détermine son noyau et son image.

Correction. Le noyau est l''ensemble des couples tels que $2x - 4y = 0$ et $-x + 2y = 0$.

Ces deux équations disent la même chose : $x = 2y$.

Le noyau est donc la droite d''équation $x = 2y$, de dimension 1.

Par le théorème du rang, l''image est de dimension $2 - 1 = 1$, c''est une droite.

Pour la trouver, calcule l''image d''un vecteur hors du noyau. Par exemple $f(1\,;0) = (2\,;-1)$. L''image est la droite engendrée par le vecteur $(2\,;-1)$.', NULL, 15),
    (v_chapitre_id, 'Matrice d''une application linéaire', 4, 'texte', 'Toute application linéaire se résume à un tableau de nombres. C''est ce qui rend les calculs mécaniques.

## La règle de construction

Soit $f$ une application linéaire du plan dans le plan, et $(\vec{i}, \vec{j})$ une base.

La matrice de $f$ dans cette base est la matrice dont les colonnes sont les coordonnées de $f(\vec{i})$ et de $f(\vec{j})$.

Les colonnes sont les images des vecteurs de base. Retiens cette phrase, elle suffit à tout reconstruire.

## Un exemple

Soit $f(x\,;y) = (2x - y\,;x + 3y)$.

On calcule $f(1\,;0) = (2\,;1)$ et $f(0\,;1) = (-1\,;3)$.

$$M = \begin{pmatrix} 2 & -1 \\ 1 & 3 \end{pmatrix}$$

Les coefficients de la matrice se lisent d''ailleurs directement dans l''expression de $f$.

## Calculer une image avec la matrice

$$f\begin{pmatrix} x \\ y\end{pmatrix} = M\begin{pmatrix} x \\ y\end{pmatrix}$$

Pour $(3\,;-2)$ :
$$\begin{pmatrix} 2 & -1 \\ 1 & 3\end{pmatrix}\begin{pmatrix} 3 \\ -2\end{pmatrix} = \begin{pmatrix} 6 + 2 \\ 3 - 6\end{pmatrix} = \begin{pmatrix} 8 \\ -3\end{pmatrix}$$

## Composition et produit

La matrice de $g \circ f$ est le produit de la matrice de $g$ par celle de $f$, dans cet ordre.
$$M_{g \circ f} = M_{g} \times M_{f}$$

L''ordre est inversé par rapport à l''écriture $g \circ f$, ce qui explique pourquoi le produit de matrices n''est pas commutatif : composer dans l''autre sens ne donne pas le même résultat.

## Le déterminant et la bijectivité

$f$ est bijective si et seulement si le déterminant de sa matrice est non nul.

Dans ce cas, la matrice de $f^{-1}$ est l''inverse de la matrice de $f$.

Si le déterminant est nul, le noyau n''est pas réduit à zéro, et toute la figure s''écrase sur une droite.

## Le déterminant mesure les aires

La valeur absolue du déterminant est le facteur par lequel les aires sont multipliées.

Si $|\det| = 3$, toute figure voit son aire triplée. Si le déterminant est négatif, l''orientation est en plus inversée, comme dans un miroir.

Si le déterminant est nul, l''aire de l''image est nulle, ce qui confirme que tout s''écrase sur une droite.

## Les matrices des transformations usuelles

Homothétie de centre $O$ et de rapport $k$ :
$$\begin{pmatrix} k & 0 \\ 0 & k\end{pmatrix} \qquad \det = k^{2}$$

Rotation de centre $O$ et d''angle $\theta$ :
$$\begin{pmatrix} \cos\theta & -\sin\theta \\ \sin\theta & \cos\theta\end{pmatrix} \qquad \det = 1$$

Symétrie d''axe $(Ox)$ :
$$\begin{pmatrix} 1 & 0 \\ 0 & -1\end{pmatrix} \qquad \det = -1$$

Le déterminant vaut 1 pour la rotation, qui conserve les aires et l''orientation, et $-1$ pour la symétrie, qui conserve les aires mais inverse l''orientation.

## Exercice d''application

Soit $f$ de matrice $M = \begin{pmatrix} 1 & 2 \\ 3 & 6\end{pmatrix}$. L''application est-elle bijective ? Détermine son noyau.

Correction. Le déterminant vaut $1 \times 6 - 2 \times 3 = 0$. L''application n''est donc pas bijective.

Le noyau est l''ensemble des $(x\,;y)$ tels que $x + 2y = 0$ et $3x + 6y = 0$. La seconde équation est le triple de la première.

Le noyau est donc la droite d''équation $x + 2y = 0$, engendrée par le vecteur $(2\,;-1)$.

L''image est la droite engendrée par $f(1\,;0) = (1\,;3)$. Tout le plan s''écrase sur cette droite.', NULL, 15),
    (v_chapitre_id, 'La matrice vue comme une déformation', 5, 'interactif', '{
  "widget": "matrice-transformation",
  "consigne": "Règle la matrice pour que le déterminant soit exactement 0 : que devient la maison ? Mets ensuite un déterminant négatif et compare l''orientation de la maison avec celle de départ. Vérifie enfin que l''aire de l''image vaut bien l''aire de départ multipliée par la valeur absolue du déterminant."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 18', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Une matrice de taille 2 × 3 possède :",
      "choix": [
        "2 lignes et 3 colonnes",
        "3 lignes et 2 colonnes",
        "6 lignes",
        "2 colonnes"
      ],
      "bonne": 0,
      "explication": "On note toujours les lignes en premier, puis les colonnes."
    },
    {
      "question": "Le déterminant de la matrice de coefficients a, b, c, d vaut :",
      "choix": [
        "ad − bc",
        "ab − cd",
        "ac − bd",
        "ad + bc"
      ],
      "bonne": 0,
      "explication": "C''est le produit de la diagonale principale moins celui de l''autre diagonale."
    },
    {
      "question": "Une matrice carrée est inversible si et seulement si :",
      "choix": [
        "son déterminant est non nul",
        "elle est diagonale",
        "elle est symétrique",
        "tous ses coefficients sont non nuls"
      ],
      "bonne": 0,
      "explication": "Quand le déterminant est nul, l''application associée écrase l''espace et ne peut pas être bijective."
    },
    {
      "question": "Dans la matrice d''une application linéaire, les colonnes sont :",
      "choix": [
        "les images des vecteurs de la base",
        "les antécédents de la base",
        "les coordonnées du noyau",
        "les valeurs propres"
      ],
      "bonne": 0,
      "explication": "C''est la règle de construction. Elle permet de retrouver la matrice sans calcul, à partir de f(i) et f(j)."
    },
    {
      "question": "Une application linéaire envoie toujours le vecteur nul sur :",
      "choix": [
        "le vecteur nul",
        "un vecteur unitaire",
        "n''importe quel vecteur",
        "le premier vecteur de la base"
      ],
      "bonne": 0,
      "explication": "C''est le test le plus rapide pour éliminer une application affine, qui n''est pas linéaire dès qu''elle déplace l''origine."
    },
    {
      "question": "Si le déterminant de la matrice de f vaut −3, alors les aires sont :",
      "choix": [
        "multipliées par 3, avec inversion de l''orientation",
        "multipliées par −3",
        "divisées par 3",
        "inchangées"
      ],
      "bonne": 0,
      "explication": "C''est la valeur absolue qui donne le facteur d''aire. Le signe indique seulement si l''orientation est conservée ou inversée."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 18, Matrices et applications linéaires : 6 lecons ajoutees.';
END $p1c$;
