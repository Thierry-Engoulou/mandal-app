-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 20, Géométrie analytique dans l''espace
-- Module 24 : Solides de l'espace
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
  WHERE programme_id = v_programme_id AND ordre = 20;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Géométrie analytique dans l''espace', 20, 'Module 24 : Solides de l''espace')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 20 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 20 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Les repères de l''espace', 1, 'texte', 'Pour calculer dans l''espace, il faut d''abord pouvoir y repérer les points. Il suffit d''ajouter un troisième axe à ce que tu connais déjà.

## Le repère

Un repère de l''espace est la donnée d''un point $O$ et de trois vecteurs $\vec{i}$, $\vec{j}$, $\vec{k}$ non coplanaires.

Tout point $M$ s''écrit alors d''une seule façon
$$\vec{OM} = x\vec{i} + y\vec{j} + z\vec{k}$$

Les trois nombres $x$, $y$ et $z$ sont les coordonnées de $M$. On les appelle l''abscisse, l''ordonnée et la cote.

Le repère est orthonormé si les trois vecteurs sont deux à deux orthogonaux et de norme 1. C''est le cas le plus commode, et celui qu''on utilisera toujours.

## Calculer avec les coordonnées

Pour deux points $A(x_{A}\,;y_{A}\,;z_{A})$ et $B(x_{B}\,;y_{B}\,;z_{B})$ :

Le vecteur $\vec{AB}$ a pour coordonnées $(x_{B} - x_{A}\,;y_{B} - y_{A}\,;z_{B} - z_{A})$.

Le milieu de $[AB]$ a pour coordonnées $\left(\dfrac{x_{A}+x_{B}}{2}\,;\dfrac{y_{A}+y_{B}}{2}\,;\dfrac{z_{A}+z_{B}}{2}\right)$.

Dans un repère orthonormé, la distance vaut
$$AB = \sqrt{(x_{B}-x_{A})^{2} + (y_{B}-y_{A})^{2} + (z_{B}-z_{A})^{2}}$$

C''est le théorème de Pythagore appliqué deux fois de suite.

## Le produit scalaire dans l''espace

Pour $\vec{u}(x\,;y\,;z)$ et $\vec{v}(x''\,;y''\,;z'')$ dans un repère orthonormé :
$$\vec{u} \cdot \vec{v} = xx'' + yy'' + zz''$$

Toutes les propriétés du plan restent vraies. En particulier, le produit scalaire est nul si et seulement si les vecteurs sont orthogonaux.

## Coplanarité

Trois vecteurs sont coplanaires s''ils appartiennent à un même plan vectoriel. Cela revient à dire que l''un d''eux est combinaison linéaire des deux autres.

Quatre points $A$, $B$, $C$ et $D$ sont coplanaires si les vecteurs $\vec{AB}$, $\vec{AC}$ et $\vec{AD}$ sont coplanaires.

## Un calcul complet

Soient $A(1\,;0\,;2)$, $B(3\,;1\,;0)$ et $C(0\,;2\,;1)$.

Le vecteur $\vec{AB}$ a pour coordonnées $(2\,;1\,;-2)$ et $\vec{AC}$ a pour coordonnées $(-1\,;2\,;-1)$.

Leur produit scalaire vaut $-2 + 2 + 2 = 2$.

Les normes valent $\|\vec{AB}\| = \sqrt{4+1+4} = 3$ et $\|\vec{AC}\| = \sqrt{1+4+1} = \sqrt{6}$.

Donc $\cos\widehat{BAC} = \dfrac{2}{3\sqrt{6}} \approx 0{,}272$, soit un angle d''environ 74,2 degrés.

## Exercice d''application

Soient $A(2\,;-1\,;3)$ et $B(4\,;3\,;-1)$. Calcule $AB$ et les coordonnées du milieu de $[AB]$.

Correction. Le vecteur $\vec{AB}$ a pour coordonnées $(2\,;4\,;-4)$.

Donc $AB = \sqrt{4 + 16 + 16} = \sqrt{36} = 6$.

Le milieu a pour coordonnées $\left(\dfrac{2+4}{2}\,;\dfrac{-1+3}{2}\,;\dfrac{3-1}{2}\right) = (3\,;1\,;1)$.', NULL, 15),
    (v_chapitre_id, 'Place un point dans l''espace', 2, 'interactif', '{
  "widget": "repere-espace",
  "consigne": "Règle $x$, $y$ et $z$ pour placer $M$ au point de coordonnées $(2\\,;3\\,;2)$, puis vérifie à la main que $OM = \\sqrt{17}$. Mets ensuite une coordonnée à zéro : où se retrouve le point par rapport aux plans du repère ?"
}', NULL, 10),
    (v_chapitre_id, 'Droites de l''espace : représentations paramétriques', 3, 'texte', 'Dans le plan, une droite a une équation. Dans l''espace, une seule équation ne suffit plus : elle décrirait un plan. On utilise donc une représentation paramétrique.

## La représentation paramétrique

La droite passant par $A(x_{A}\,;y_{A}\,;z_{A})$ et de vecteur directeur $\vec{u}(a\,;b\,;c)$ est l''ensemble des points $M$ tels que $\vec{AM} = t\,\vec{u}$ pour un réel $t$.

En coordonnées :
$$\begin{cases} x = x_{A} + at \\ y = y_{A} + bt \\ z = z_{A} + ct \end{cases} \quad t \in \mathbb{R}$$

Le réel $t$ s''appelle le paramètre. Chaque valeur de $t$ donne un point de la droite, et chaque point correspond à une seule valeur de $t$.

## Un exemple

La droite passant par $A(1\,;2\,;-1)$ et de vecteur directeur $\vec{u}(3\,;-1\,;2)$ a pour représentation
$$\begin{cases} x = 1 + 3t \\ y = 2 - t \\ z = -1 + 2t\end{cases}$$

Pour $t = 0$ on retrouve $A$. Pour $t = 1$ on obtient le point $(4\,;1\,;1)$, qui est aussi sur la droite.

## Un point appartient-il à la droite ?

Tu résous le système. Si une même valeur de $t$ convient pour les trois coordonnées, le point appartient à la droite. Sinon, non.

Le point $(7\,;0\,;3)$ appartient-il à la droite précédente ?

De $x = 7$ on tire $3t = 6$, donc $t = 2$. De $y = 0$ on tire $t = 2$. De $z = 3$ on tire $2t = 4$, donc $t = 2$.

Les trois valeurs concordent, le point appartient bien à la droite.

Le point $(7\,;0\,;5)$, lui, donnerait $t = 3$ pour la troisième coordonnée, en contradiction avec les deux autres. Il n''appartient pas à la droite.

## Les positions relatives de deux droites

Dans l''espace, deux droites peuvent être coplanaires ou non.

Si elles sont coplanaires, elles sont soit parallèles, soit sécantes.

Si elles ne sont pas coplanaires, elles ne se rencontrent pas et ne sont pas parallèles. Cette situation n''existe pas dans le plan, et c''est la plus fréquente dans l''espace.

## La méthode pour trancher

D''abord tu compares les vecteurs directeurs.

S''ils sont colinéaires, les droites sont parallèles. Elles sont confondues si un point de l''une appartient à l''autre, strictement parallèles sinon.

S''ils ne sont pas colinéaires, tu cherches un point commun en résolvant le système. Attention, il faut deux paramètres différents, un par droite.

Si le système a une solution, les droites sont sécantes. S''il n''en a pas, elles ne sont pas coplanaires.

## Un exemple de résolution

Soient
$$(d_{1}) : \begin{cases} x = 1 + t \\ y = 2t \\ z = 3 - t\end{cases} \qquad (d_{2}) : \begin{cases} x = 2 + s \\ y = 1 + s \\ z = 2s\end{cases}$$

Les vecteurs directeurs $(1\,;2\,;-1)$ et $(1\,;1\,;2)$ ne sont pas colinéaires.

Cherchons un point commun. Les deux premières équations donnent
$$1 + t = 2 + s \qquad \text{et} \qquad 2t = 1 + s$$

De la première, $s = t - 1$. En reportant dans la seconde, $2t = 1 + t - 1 = t$, donc $t = 0$ et $s = -1$.

Vérifions avec la troisième : pour $t = 0$, on a $z = 3$. Pour $s = -1$, on a $z = -2$.

Les deux ne coïncident pas. Le système n''a pas de solution, les droites ne sont pas coplanaires.

## Exercice d''application

Donne une représentation paramétrique de la droite passant par $A(2\,;0\,;1)$ et $B(5\,;3\,;-2)$.

Correction. Le vecteur $\vec{AB}$ a pour coordonnées $(3\,;3\,;-3)$, et on peut le simplifier en $(1\,;1\,;-1)$.
$$\begin{cases} x = 2 + t \\ y = t \\ z = 1 - t\end{cases}$$

Pour $t = 0$ on a bien $A$, et pour $t = 3$ on obtient $(5\,;3\,;-2)$, c''est-à-dire $B$.', NULL, 15),
    (v_chapitre_id, 'Les plans : équations cartésiennes', 4, 'texte', 'Le plan, lui, se décrit très bien par une seule équation, à condition de penser au vecteur normal.

## L''équation cartésienne

Tout plan de l''espace admet une équation de la forme
$$ax + by + cz + d = 0$$

avec $a$, $b$, $c$ non tous nuls. Le vecteur $\vec{n}(a\,;b\,;c)$ est normal au plan.

Réciproquement, toute équation de cette forme décrit un plan.

## Trouver l''équation à partir d''un point et d''une normale

Le plan passant par $A(x_{A}\,;y_{A}\,;z_{A})$ et de vecteur normal $\vec{n}(a\,;b\,;c)$ a pour équation
$$a(x - x_{A}) + b(y - y_{A}) + c(z - z_{A}) = 0$$

Par exemple, le plan passant par $A(1\,;2\,;-1)$ et de normale $\vec{n}(2\,;-1\,;3)$ a pour équation
$$2(x-1) - (y-2) + 3(z+1) = 0$$

soit $2x - y + 3z + 3 = 0$.

Vérifie avec $A$ : $2 - 2 - 3 + 3 = 0$. C''est bon.

## Trouver l''équation à partir de trois points

Tu écris l''équation générale, puis tu remplaces par les coordonnées des trois points. Tu obtiens un système.

Prenons $A(1\,;0\,;0)$, $B(0\,;2\,;0)$ et $C(0\,;0\,;3)$.

Avec $ax + by + cz + d = 0$, le point $A$ donne $a + d = 0$, le point $B$ donne $2b + d = 0$, et le point $C$ donne $3c + d = 0$.

En posant $d = -6$, on obtient $a = 6$, $b = 3$ et $c = 2$.

L''équation est donc $6x + 3y + 2z - 6 = 0$.

## La représentation paramétrique d''un plan

Un plan passant par $A$ et dirigé par deux vecteurs non colinéaires $\vec{u}$ et $\vec{v}$ s''écrit
$$\vec{AM} = t\,\vec{u} + s\,\vec{v}$$

avec deux paramètres cette fois. C''est logique : un plan est de dimension 2.

## Les positions relatives

Deux plans sont parallèles si leurs vecteurs normaux sont colinéaires. Ils sont alors confondus ou strictement parallèles.

Sinon ils sont sécants, et leur intersection est une droite.

Une droite est parallèle à un plan si son vecteur directeur est orthogonal au vecteur normal du plan. Elle est contenue dans le plan si en plus un de ses points y appartient.

Sinon, la droite perce le plan en un point unique.

## Trouver le point d''intersection d''une droite et d''un plan

Tu remplaces $x$, $y$ et $z$ de la représentation paramétrique dans l''équation du plan, et tu résous en $t$.

Prenons la droite $x = 1 + 3t$, $y = 2 - t$, $z = -1 + 2t$ et le plan $x + y + z - 4 = 0$.

En remplaçant : $(1 + 3t) + (2 - t) + (-1 + 2t) - 4 = 0$, soit $4t - 2 = 0$, donc $t = \dfrac{1}{2}$.

Le point d''intersection a pour coordonnées $\left(\dfrac{5}{2}\,;\dfrac{3}{2}\,;0\right)$.

Vérifie : $\dfrac{5}{2} + \dfrac{3}{2} + 0 - 4 = 0$. C''est bon.

## La distance d''un point à un plan

$$d(M, P) = \dfrac{|a x_{M} + b y_{M} + c z_{M} + d|}{\sqrt{a^{2} + b^{2} + c^{2}}}$$

C''est la même formule que dans le plan, avec une coordonnée de plus.

## Exercice d''application

Détermine l''équation du plan passant par $A(2\,;1\,;0)$ et orthogonal à la droite de vecteur directeur $\vec{u}(1\,;-2\,;3)$, puis calcule la distance du point $B(0\,;0\,;0)$ à ce plan.

Correction. Le vecteur $\vec{u}$ est normal au plan, donc l''équation est
$$(x - 2) - 2(y - 1) + 3z = 0 \quad \text{soit} \quad x - 2y + 3z = 0$$

La distance de l''origine vaut $\dfrac{|0 - 0 + 0|}{\sqrt{1 + 4 + 9}} = 0$.

L''origine appartient donc au plan, ce qu''on pouvait voir directement puisque l''équation n''a pas de terme constant.', NULL, 15),
    (v_chapitre_id, 'Projeté orthogonal d''un point sur une droite ou un plan', 5, 'texte', 'Le projeté orthogonal, c''est l''ombre du point, projetée perpendiculairement. C''est lui qui réalise la distance minimale.

## Sur un plan

Soit $M$ un point et $(P)$ un plan de vecteur normal $\vec{n}$.

Le projeté orthogonal $H$ de $M$ sur $(P)$ est l''unique point de $(P)$ tel que $\vec{MH}$ soit colinéaire à $\vec{n}$.

La méthode est toujours la même. Tu écris $H = M + t\vec{n}$, ce qui donne ses coordonnées en fonction de $t$. Puis tu écris que $H$ appartient au plan, ce qui détermine $t$.

## Un calcul

Projetons $M(3\,;1\,;2)$ sur le plan $x + 2y - z - 4 = 0$.

Le vecteur normal est $\vec{n}(1\,;2\,;-1)$, donc $H(3 + t\,;1 + 2t\,;2 - t)$.

$H$ appartient au plan :
$$(3+t) + 2(1+2t) - (2-t) - 4 = 0$$
$$3 + t + 2 + 4t - 2 + t - 4 = 0$$
$$6t - 1 = 0 \quad \text{donc} \quad t = \dfrac{1}{6}$$

Ainsi $H\left(\dfrac{19}{6}\,;\dfrac{4}{3}\,;\dfrac{11}{6}\right)$.

La distance $MH$ vaut $|t| \times \|\vec{n}\| = \dfrac{1}{6}\sqrt{6} = \dfrac{\sqrt{6}}{6} \approx 0{,}41$.

Vérifie avec la formule directe : $\dfrac{|3 + 2 - 2 - 4|}{\sqrt{6}} = \dfrac{1}{\sqrt{6}}$. Les deux concordent.

## Sur une droite

Soit $M$ un point et $(d)$ une droite passant par $A$ et de vecteur directeur $\vec{u}$.

Le projeté $H$ est le point de $(d)$ tel que $\vec{MH}$ soit orthogonal à $\vec{u}$.

Tu écris $H = A + t\vec{u}$, puis tu résous $\vec{MH} \cdot \vec{u} = 0$.

## Un calcul

Projetons $M(1\,;1\,;1)$ sur la droite passant par $A(0\,;0\,;0)$ et de vecteur directeur $\vec{u}(1\,;2\,;0)$.

On a $H(t\,;2t\,;0)$, donc $\vec{MH}(t - 1\,;2t - 1\,;-1)$.

La condition $\vec{MH} \cdot \vec{u} = 0$ donne
$$(t-1) + 2(2t-1) = 0 \quad \text{soit} \quad 5t - 3 = 0 \quad \text{donc} \quad t = \dfrac{3}{5}$$

Ainsi $H\left(\dfrac{3}{5}\,;\dfrac{6}{5}\,;0\right)$.

La distance vaut $MH = \sqrt{\left(-\dfrac{2}{5}\right)^{2} + \left(\dfrac{1}{5}\right)^{2} + 1} = \sqrt{\dfrac{4 + 1 + 25}{25}} = \sqrt{\dfrac{30}{25}} = \dfrac{\sqrt{30}}{5} \approx 1{,}10$.

## Pourquoi c''est le plus court

Pour tout autre point $K$ de la droite ou du plan, le triangle $MHK$ est rectangle en $H$. Donc $MK^{2} = MH^{2} + HK^{2}$, ce qui est strictement plus grand que $MH^{2}$ dès que $K$ est différent de $H$.

Le projeté orthogonal réalise donc bien le minimum.

## Exercice d''application

Trouve le projeté orthogonal de $M(2\,;3\,;1)$ sur le plan $2x - y + 2z + 1 = 0$, puis la distance.

Correction. Le vecteur normal est $\vec{n}(2\,;-1\,;2)$, de norme 3.

On écrit $H(2 + 2t\,;3 - t\,;1 + 2t)$, puis on l''injecte dans l''équation :
$$2(2+2t) - (3-t) + 2(1+2t) + 1 = 0$$
$$4 + 4t - 3 + t + 2 + 4t + 1 = 0$$
$$9t + 4 = 0 \quad \text{donc} \quad t = -\dfrac{4}{9}$$

Ainsi $H\left(\dfrac{10}{9}\,;\dfrac{31}{9}\,;\dfrac{1}{9}\right)$.

La distance vaut $|t| \times 3 = \dfrac{4}{3}$.

Vérification par la formule : $\dfrac{|4 - 3 + 2 + 1|}{3} = \dfrac{4}{3}$. Les deux résultats concordent.', NULL, 15),
    (v_chapitre_id, 'Quiz du chapitre 20', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Dans un repère orthonormé de l''espace, la distance AB vaut :",
      "choix": [
        "√((xB−xA)² + (yB−yA)² + (zB−zA)²)",
        "(xB−xA) + (yB−yA) + (zB−zA)",
        "√((xB−xA)² + (yB−yA)²)",
        "|xB−xA| × |yB−yA| × |zB−zA|"
      ],
      "bonne": 0,
      "explication": "C''est le théorème de Pythagore appliqué deux fois, une fois dans le plan de base puis une fois en hauteur."
    },
    {
      "question": "Une droite de l''espace se décrit par :",
      "choix": [
        "une représentation paramétrique à un paramètre",
        "une seule équation cartésienne",
        "deux paramètres",
        "une équation du second degré"
      ],
      "bonne": 0,
      "explication": "Une seule équation cartésienne décrirait un plan. Une droite est de dimension 1, donc il faut un paramètre."
    },
    {
      "question": "Deux plans sont parallèles si leurs vecteurs normaux sont :",
      "choix": [
        "colinéaires",
        "orthogonaux",
        "unitaires",
        "nuls"
      ],
      "bonne": 0,
      "explication": "Des normales colinéaires signifient que les plans ont la même direction. S''ils ont en plus un point commun, ils sont confondus."
    },
    {
      "question": "Deux droites de l''espace non parallèles et sans point commun sont :",
      "choix": [
        "non coplanaires",
        "sécantes",
        "confondues",
        "orthogonales"
      ],
      "bonne": 0,
      "explication": "Cette situation n''existe pas dans le plan. Dans l''espace, c''est au contraire le cas le plus fréquent."
    },
    {
      "question": "Le projeté orthogonal H de M sur un plan est caractérisé par :",
      "choix": [
        "H appartient au plan et $\\vec{MH}$ est colinéaire au vecteur normal",
        "H est le milieu de la projection",
        "MH est parallèle au plan",
        "H est l''origine"
      ],
      "bonne": 0,
      "explication": "C''est cette double condition qui permet de le calculer : on écrit H = M + t·n, puis on impose que H soit dans le plan."
    },
    {
      "question": "La distance du point M au plan ax + by + cz + d = 0 vaut :",
      "choix": [
        "|axM + byM + czM + d| / √(a² + b² + c²)",
        "axM + byM + czM + d",
        "√(a² + b² + c²)",
        "|d| / √(a² + b² + c²)"
      ],
      "bonne": 0,
      "explication": "C''est l''extension directe de la formule du plan. Les barres de valeur absolue sont indispensables, une distance étant positive."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 20, Géométrie analytique dans l''espace : 6 lecons ajoutees.';
END $p1c$;
