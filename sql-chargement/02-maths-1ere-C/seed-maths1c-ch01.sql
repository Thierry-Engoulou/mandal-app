-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 1, Équations et inéquations polynômiales du second degré dans ℝ
-- Module 21 : Relations et opérations fondamentales dans l'ensemble des nombres réels
-- 9 leçons.
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
  WHERE programme_id = v_programme_id AND ordre = 1;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Équations et inéquations polynômiales du second degré dans ℝ', 1, 'Module 21 : Relations et opérations fondamentales dans l''ensemble des nombres réels')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 1 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 1 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Résoudre une équation du second degré', 1, 'texte', 'Une équation du second degré, c''est une équation qui s''écrit $ax^{2} + bx + c = 0$ avec $a \neq 0$. Le $a \neq 0$ est important. Si $a$ était nul, il ne resterait qu''une équation du premier degré.

## La forme canonique, d''où tout vient

Tu peux toujours réécrire $ax^{2} + bx + c$ sous la forme
$$a\left[\left(x + \dfrac{b}{2a}\right)^{2} - \dfrac{b^{2} - 4ac}{4a^{2}}\right]$$

Essaie sur $2x^{2} - 8x + 6$. Tu factorises par 2, ce qui donne $2(x^{2} - 4x + 3)$. Puis $x^{2} - 4x = (x-2)^{2} - 4$. Donc l''expression vaut $2[(x-2)^{2} - 1]$.

Cette écriture te donne tout d''un coup. Le sommet de la parabole, le signe, et les solutions.

## Le discriminant

On pose $\Delta = b^{2} - 4ac$. C''est lui qui décide de tout.

Si $\Delta > 0$, il y a deux solutions distinctes :
$$x_{1} = \dfrac{-b - \sqrt{\Delta}}{2a} \qquad x_{2} = \dfrac{-b + \sqrt{\Delta}}{2a}$$

Si $\Delta = 0$, il y a une seule solution, dite double : $x_{0} = \dfrac{-b}{2a}$.

Si $\Delta < 0$, il n''y a aucune solution réelle. En Terminale tu verras qu''il y en a deux, mais dans l''ensemble des nombres complexes.

## Un exemple complet

Résolvons $3x^{2} - 5x - 2 = 0$.

Ici $a = 3$, $b = -5$ et $c = -2$. Donc $\Delta = (-5)^{2} - 4 \times 3 \times (-2) = 25 + 24 = 49$.

$\Delta$ est positif et $\sqrt{49} = 7$. Les deux solutions sont
$$x_{1} = \dfrac{5 - 7}{6} = -\dfrac{1}{3} \qquad x_{2} = \dfrac{5 + 7}{6} = 2$$

Vérifie avec $x = 2$ : $3 \times 4 - 5 \times 2 - 2 = 12 - 10 - 2 = 0$. C''est bon.

## Le réflexe qui fait gagner du temps

Avant de sortir le discriminant, regarde si l''équation n''est pas déjà facile.

Si $c = 0$, factorise par $x$. Par exemple $4x^{2} - 12x = 0$ donne $4x(x - 3) = 0$, donc $x = 0$ ou $x = 3$.

Si $b = 0$, isole le carré. Par exemple $2x^{2} - 18 = 0$ donne $x^{2} = 9$, donc $x = -3$ ou $x = 3$.

Si tu vois une identité remarquable, sers-t''en. $x^{2} - 6x + 9 = (x-3)^{2}$, la solution double est 3.

## Exercice d''application

Résous $x^{2} - 7x + 12 = 0$ puis $2x^{2} + 3x + 5 = 0$.

Correction. Pour la première, $\Delta = 49 - 48 = 1$, donc $x_{1} = \dfrac{7-1}{2} = 3$ et $x_{2} = \dfrac{7+1}{2} = 4$. Alors $S = \{3\,;4\}$.

Pour la seconde, $\Delta = 9 - 40 = -31$. Le discriminant est négatif, donc $S = \varnothing$.', NULL, 15),
    (v_chapitre_id, 'Joue avec la parabole et le discriminant', 2, 'interactif', '{
  "widget": "second-degre",
  "consigne": "Règle $a$, $b$ et $c$, et regarde le signe de $\\Delta$ changer. Trouve une valeur de $c$ pour laquelle la parabole touche l''axe des abscisses en un seul point. Que vaut $\\Delta$ à ce moment-là ?"
}', NULL, 10),
    (v_chapitre_id, 'Somme, produit et factorisation', 3, 'texte', 'Quand une équation du second degré a deux solutions $x_{1}$ et $x_{2}$, elles sont liées aux coefficients par deux relations très utiles.

## Les deux relations

$$S = x_{1} + x_{2} = -\dfrac{b}{a} \qquad P = x_{1} \times x_{2} = \dfrac{c}{a}$$

Ces deux égalités te servent dans trois situations.

## Première utilité : vérifier

Reprends $3x^{2} - 5x - 2 = 0$, dont les solutions étaient $-\dfrac{1}{3}$ et 2.

La somme vaut $-\dfrac{1}{3} + 2 = \dfrac{5}{3}$, et $-\dfrac{b}{a} = \dfrac{5}{3}$. Le produit vaut $-\dfrac{1}{3} \times 2 = -\dfrac{2}{3}$, et $\dfrac{c}{a} = -\dfrac{2}{3}$. Tes solutions sont justes.

## Deuxième utilité : trouver la deuxième racine de tête

Si tu repères une racine évidente, la seconde tombe sans calcul.

Dans $x^{2} - 9x + 20 = 0$, tu vois que 4 convient. Comme le produit vaut 20, l''autre racine est $\dfrac{20}{4} = 5$.

Une racine évidente très fréquente : si $a + b + c = 0$, alors 1 est racine, et l''autre vaut $\dfrac{c}{a}$. Si $a - b + c = 0$, alors $-1$ est racine, et l''autre vaut $-\dfrac{c}{a}$.

## Troisième utilité : fabriquer une équation

Deux nombres dont tu connais la somme $S$ et le produit $P$ sont les solutions de
$$x^{2} - Sx + P = 0$$

Cherchons deux nombres de somme 11 et de produit 30. Ils vérifient $x^{2} - 11x + 30 = 0$. Le discriminant vaut $121 - 120 = 1$, donc les nombres sont 5 et 6.

## La factorisation

Si $\Delta > 0$, alors $ax^{2} + bx + c = a(x - x_{1})(x - x_{2})$.

Si $\Delta = 0$, alors $ax^{2} + bx + c = a(x - x_{0})^{2}$.

Si $\Delta < 0$, on ne peut pas factoriser dans $\mathbb{R}$.

Par exemple $3x^{2} - 5x - 2 = 3\left(x + \dfrac{1}{3}\right)(x - 2)$, ce qui s''écrit aussi $(3x + 1)(x - 2)$.

## Exercice d''application

Le périmètre d''un champ rectangulaire à Ngaoundéré est de 34 mètres et son aire est de 60 mètres carrés. Trouve ses dimensions.

Correction. Si $L$ et $\ell$ sont les côtés, alors $L + \ell = 17$ et $L \times \ell = 60$. Ce sont donc les racines de $x^{2} - 17x + 60 = 0$. Le discriminant vaut $289 - 240 = 49$, et $\sqrt{49} = 7$. Les racines sont $\dfrac{17-7}{2} = 5$ et $\dfrac{17+7}{2} = 12$. Le champ mesure 12 mètres sur 5 mètres.', NULL, 15),
    (v_chapitre_id, 'Signe du trinôme et inéquations', 4, 'texte', 'Une fois que tu sais résoudre l''équation, l''inéquation ne demande presque plus de travail.

## La règle à retenir

Un trinôme est du signe de $a$ partout, sauf entre ses racines quand il y en a deux.

Si $\Delta < 0$, le trinôme garde le signe de $a$ sur tout $\mathbb{R}$. Il ne s''annule jamais.

Si $\Delta = 0$, il garde le signe de $a$ partout sauf en $x_{0}$ où il s''annule.

Si $\Delta > 0$, il est du signe contraire de $a$ strictement entre $x_{1}$ et $x_{2}$, et du signe de $a$ à l''extérieur.

Beaucoup d''élèves retiennent la phrase « signe de $a$ à l''extérieur des racines ». Elle résume tout.

## Un tableau de signes complet

Résolvons $-2x^{2} + 4x + 6 \geq 0$.

Le discriminant vaut $16 + 48 = 64$, donc $\sqrt{\Delta} = 8$. Les racines sont $\dfrac{-4 - 8}{-4} = 3$ et $\dfrac{-4 + 8}{-4} = -1$.

Ici $a = -2$ est négatif. Le trinôme est donc négatif à l''extérieur de $[-1\,;3]$ et positif entre $-1$ et 3.

L''inéquation demande « positif ou nul », donc $S = [-1\,;3]$.

## Attention au sens de l''inégalité

Quand tu multiplies ou divises une inéquation par un nombre négatif, tu retournes le sens. C''est l''erreur la plus courante de l''année. Pour l''éviter, ne divise jamais par $a$ : fais plutôt le tableau de signes.

## Inéquations quotient

Pour $\dfrac{x^{2} - 1}{x - 3} \leq 0$, tu ne multiplies surtout pas par $x - 3$, car tu ne connais pas son signe. Tu fais un tableau avec les trois valeurs $-1$, 1 et 3.

Le numérateur s''annule en $-1$ et 1, le dénominateur en 3, qui est valeur interdite.

Le quotient est négatif ou nul sur $]-\infty\,;-1]$ et sur $[1\,;3[$. Donc $S = \;]-\infty\,;-1] \cup [1\,;3[$. Le crochet est ouvert en 3, parce que la fraction n''y est pas définie.

## Exercice d''application

Résous $x^{2} - 5x + 6 < 0$.

Correction. Le discriminant vaut $25 - 24 = 1$, les racines sont 2 et 3. Comme $a = 1$ est positif, le trinôme est négatif strictement entre les racines. Donc $S = \;]2\,;3[$.', NULL, 15),
    (v_chapitre_id, 'La parabole et son signe, en image', 5, 'graphique', '{"functions": [{"expr": "x^2 - 5*x + 6", "label": "f(x) = x² − 5x + 6", "color": "#2563eb"}, {"expr": "0 - 2*x^2 + 4*x + 6", "label": "g(x) = −2x² + 4x + 6", "color": "#dc2626"}], "domain": [-3, 6], "range": [-8, 9], "points": [{"x": 2, "y": 0, "label": "racine de f"}, {"x": 3, "y": 0, "label": "racine de f"}, {"x": -1, "y": 0, "label": "racine de g"}]}', NULL, 5),
    (v_chapitre_id, 'Équations et inéquations irrationnelles', 6, 'texte', 'Une équation irrationnelle, c''est une équation où l''inconnue se trouve sous un radical. Le radical impose deux précautions.

## Les deux conditions à ne jamais oublier

D''abord, ce qui est sous la racine doit être positif ou nul. Ensuite, une racine carrée est toujours positive ou nulle, donc ce à quoi elle est égale doit l''être aussi.

$$\sqrt{A} = B \iff \begin{cases} A \geq 0 \\ B \geq 0 \\ A = B^{2}\end{cases}$$

En pratique, la condition $A \geq 0$ est automatique dès que $A = B^{2}$. L''essentiel est donc de vérifier $B \geq 0$.

## Un exemple

Résolvons $\sqrt{2x + 3} = x$.

La condition est $x \geq 0$. On élève au carré : $2x + 3 = x^{2}$, donc $x^{2} - 2x - 3 = 0$.

Le discriminant vaut $4 + 12 = 16$, les racines sont $-1$ et 3.

La racine $-1$ est refusée, car elle est négative. Il reste $S = \{3\}$.

Vérifie : $\sqrt{2 \times 3 + 3} = \sqrt{9} = 3$. C''est bien $x$.

## Le cas de deux radicaux

Pour $\sqrt{x + 5} = \sqrt{3x - 1}$, les deux membres sont positifs d''office. Tu élèves au carré, ce qui donne $x + 5 = 3x - 1$, donc $x = 3$. Puis tu vérifies que 3 est bien dans les deux domaines : $3 + 5 = 8 \geq 0$ et $3 \times 3 - 1 = 8 \geq 0$. Donc $S = \{3\}$.

## Les inéquations

Pour $\sqrt{A} < B$, il faut $A \geq 0$, $B > 0$ et $A < B^{2}$, les trois en même temps.

Pour $\sqrt{A} > B$, c''est plus subtil. Si $B < 0$, l''inégalité est vraie dès que $A \geq 0$. Si $B \geq 0$, il faut $A > B^{2}$.

Résolvons $\sqrt{x - 1} > 3$. Ici le membre de droite est positif, donc on demande $x - 1 > 9$, soit $x > 10$. Et $x - 1 \geq 0$ est automatiquement vérifié. Donc $S = \;]10\,;+\infty[$.

## Exercice d''application

Résous $\sqrt{x + 7} = x - 5$.

Correction. La condition est $x - 5 \geq 0$, soit $x \geq 5$. En élevant au carré, $x + 7 = x^{2} - 10x + 25$, donc $x^{2} - 11x + 18 = 0$. Le discriminant vaut $121 - 72 = 49$, les racines sont 2 et 9. On refuse 2 qui est plus petit que 5. Donc $S = \{9\}$. Vérification : $\sqrt{9 + 7} = 4$ et $9 - 5 = 4$.', NULL, 15),
    (v_chapitre_id, 'Polynômes de degré 3', 7, 'texte', 'À partir du degré 3, il n''y a plus de formule simple. La méthode change : on cherche une racine, puis on factorise.

## La racine évidente

Teste les petits entiers : $-3$, $-2$, $-1$, 0, 1, 2, 3. Teste aussi les diviseurs du terme constant. L''un d''eux marche presque toujours dans les exercices.

Prenons $P(x) = x^{3} - 2x^{2} - 5x + 6$.

$P(1) = 1 - 2 - 5 + 6 = 0$. Donc 1 est racine.

## La factorisation par $(x - a)$

Si $a$ est racine de $P$, alors $P(x) = (x - a) Q(x)$ où $Q$ est de degré 2.

Pour trouver $Q$, écris $Q(x) = \alpha x^{2} + \beta x + \gamma$, développe, et identifie les coefficients.

Ici $P(x) = (x - 1)(\alpha x^{2} + \beta x + \gamma)$. En développant, le terme en $x^{3}$ donne $\alpha = 1$. Le terme constant donne $-\gamma = 6$, donc $\gamma = -6$. Le terme en $x^{2}$ donne $\beta - \alpha = -2$, donc $\beta = -1$.

Ainsi $P(x) = (x - 1)(x^{2} - x - 6)$.

## On finit avec le second degré

$x^{2} - x - 6 = 0$ a pour discriminant $1 + 24 = 25$. Ses racines sont $-2$ et 3.

Donc $P(x) = (x - 1)(x + 2)(x - 3)$ et l''équation $P(x) = 0$ a pour solutions $S = \{-2\,;1\,;3\}$.

## Le signe d''un polynôme de degré 3

Une fois factorisé, tu fais un tableau de signes avec les trois racines rangées dans l''ordre croissant. Chaque facteur change de signe à sa racine.

Sur $]-\infty\,;-2[$ les trois facteurs sont négatifs, donc $P$ est négatif. Puis le signe alterne à chaque racine : positif sur $]-2\,;1[$, négatif sur $]1\,;3[$, positif sur $]3\,;+\infty[$.

Cette alternance est vraie seulement quand toutes les racines sont simples.

## Exercice d''application

Factorise $P(x) = 2x^{3} + x^{2} - 13x + 6$ sachant que 2 est racine, puis résous $P(x) \geq 0$.

Correction. On écrit $P(x) = (x-2)(\alpha x^{2} + \beta x + \gamma)$. Le terme en $x^{3}$ donne $\alpha = 2$, le terme constant donne $-2\gamma = 6$ donc $\gamma = -3$, et le terme en $x^{2}$ donne $\beta - 2\alpha = 1$ donc $\beta = 5$.

Donc $P(x) = (x - 2)(2x^{2} + 5x - 3)$. Le trinôme a pour discriminant $25 + 24 = 49$, et pour racines $-3$ et $\dfrac{1}{2}$.

Les trois racines rangées sont $-3$, $\dfrac{1}{2}$ et 2. Le coefficient dominant est positif, donc $P$ est négatif avant $-3$, positif entre $-3$ et $\dfrac{1}{2}$, négatif entre $\dfrac{1}{2}$ et 2, positif après 2.

Donc $S = [-3\,;\tfrac{1}{2}] \cup [2\,;+\infty[$.', NULL, 15),
    (v_chapitre_id, 'TP : des problèmes de la vie courante', 8, 'texte', 'Le second degré sert vraiment, dès qu''une grandeur dépend du carré d''une autre. Voici trois situations, avec la rédaction complète.

## Un champ et son allée

Un planteur de Mbalmayo possède un champ carré. Il veut y tracer une allée de 2 mètres de large le long de deux côtés consécutifs. Il lui restera alors 196 mètres carrés cultivables. Quel est le côté du champ ?

Appelons $x$ le côté du champ, en mètres, avec $x > 2$. La partie cultivable est un carré de côté $x - 2$. Donc
$$(x - 2)^{2} = 196$$

D''où $x - 2 = 14$ ou $x - 2 = -14$. La seconde est impossible pour une longueur, donc $x = 16$.

Le champ mesure 16 mètres de côté. Vérifie : la partie cultivable est un carré de 14 mètres de côté, soit $14^{2} = 196$ mètres carrés. L''allée occupe $256 - 196 = 60$ mètres carrés.

## Le prix et la recette

Un vendeur de beignets à Douala vend 120 beignets par jour à 50 FCFA pièce. Il remarque que chaque fois qu''il augmente le prix de 5 FCFA, il perd 6 clients. Quel prix lui rapporte le plus ?

Soit $n$ le nombre d''augmentations de 5 FCFA. Le prix devient $50 + 5n$ et le nombre de beignets vendus devient $120 - 6n$.

La recette est
$$R(n) = (50 + 5n)(120 - 6n) = 6000 + 300n - 30n^{2}$$

C''est un trinôme avec $a = -30$, donc la parabole est tournée vers le bas et le maximum est au sommet, en $n = -\dfrac{b}{2a} = \dfrac{300}{60} = 5$.

Avec 5 augmentations, le prix est de 75 FCFA, il vend 90 beignets, et la recette vaut 6 750 FCFA au lieu de 6 000. Il gagne 750 FCFA de plus par jour.

## Une pierre lancée

Un enfant lance une pierre vers le haut depuis le bord d''un puits. Sa hauteur en mètres après $t$ secondes est $h(t) = -5t^{2} + 15t + 2$.

Quand retombe-t-elle au niveau du sol ? On résout $h(t) = 0$. Le discriminant vaut $225 + 40 = 265$, donc $\sqrt{\Delta} \approx 16{,}28$. Les racines sont $\dfrac{-15 - 16{,}28}{-10} \approx 3{,}13$ et $\dfrac{-15 + 16{,}28}{-10} \approx -0{,}13$.

Le temps négatif n''a pas de sens, la pierre touche le sol au bout d''environ 3,1 secondes.

À quelle hauteur monte-t-elle ? Au sommet, en $t = \dfrac{15}{10} = 1{,}5$ seconde. Et $h(1{,}5) = -5 \times 2{,}25 + 22{,}5 + 2 = 13{,}25$ mètres.

## Ce qu''il faut retenir de ce TP

Pose toujours l''inconnue avec son unité. Traduis l''énoncé en une seule équation. Résous. Reviens au problème, rejette les solutions impossibles, et réponds par une phrase.', NULL, 15),
    (v_chapitre_id, 'Quiz du chapitre 1', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Pour l''équation 2x² − 7x + 3 = 0, que vaut le discriminant ?",
      "choix": [
        "Δ = 25",
        "Δ = 49",
        "Δ = 73",
        "Δ = 1"
      ],
      "bonne": 0,
      "explication": "Δ = b² − 4ac = (−7)² − 4×2×3 = 49 − 24 = 25."
    },
    {
      "question": "Le trinôme f(x) = −x² + 4 est strictement positif sur :",
      "choix": [
        "]−2 ; 2[",
        "]−∞ ; −2[ ∪ ]2 ; +∞[",
        "ℝ tout entier",
        "l''ensemble vide"
      ],
      "bonne": 0,
      "explication": "Les racines sont −2 et 2, et a = −1 est négatif. Le trinôme est donc du signe contraire de a, c''est-à-dire positif, strictement entre les racines."
    },
    {
      "question": "Deux nombres ont pour somme 7 et pour produit 12. Ce sont :",
      "choix": [
        "3 et 4",
        "2 et 6",
        "1 et 12",
        "5 et 2"
      ],
      "bonne": 0,
      "explication": "Ils sont solutions de x² − 7x + 12 = 0, dont le discriminant vaut 1 et les racines 3 et 4."
    },
    {
      "question": "Dans l''équation √(x + 2) = x, quelle condition faut-il imposer avant d''élever au carré ?",
      "choix": [
        "x ≥ 0",
        "x ≥ −2 seulement",
        "aucune condition",
        "x ≤ 0"
      ],
      "bonne": 0,
      "explication": "Une racine carrée est toujours positive ou nulle. Comme elle est égale à x, il faut que x soit positif ou nul. La condition x ≥ −2 est ensuite automatique."
    },
    {
      "question": "Si a + b + c = 0 pour un trinôme ax² + bx + c, alors :",
      "choix": [
        "1 est racine, et l''autre racine vaut c/a",
        "−1 est racine",
        "le discriminant est nul",
        "il n''y a pas de racine"
      ],
      "bonne": 0,
      "explication": "En remplaçant x par 1 on obtient a + b + c, qui vaut 0. Donc 1 est racine. Comme le produit des racines vaut c/a, l''autre racine vaut c/a."
    },
    {
      "question": "La recette R(n) = −30n² + 300n + 6000 est maximale pour :",
      "choix": [
        "n = 5",
        "n = 10",
        "n = 300",
        "n = 0"
      ],
      "bonne": 0,
      "explication": "a est négatif, donc le maximum est au sommet, en n = −b/(2a) = −300/(−60) = 5."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 1, Équations et inéquations polynômiales du second degré dans ℝ : 9 lecons ajoutees.';
END $p1c$;
