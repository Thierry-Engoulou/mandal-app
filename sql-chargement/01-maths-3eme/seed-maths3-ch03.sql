-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 3, Calcul littéral
-- 10 leçons.
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
  WHERE programme_id = v_programme_id AND ordre = 3;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Calcul littéral', 3, 'Module 13 : Relations et opérations fondamentales dans l''ensemble des nombres réels')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 3 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 3 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Développer et réduire une expression', 1, 'texte', 'Développer, c''est transformer un produit en somme. Réduire, c''est ensuite regrouper ce qui se ressemble pour obtenir l''écriture la plus courte.

## La simple distributivité

Pour tous réels $k$, $a$ et $b$ :

$$k(a + b) = ka + kb \qquad \text{et} \qquad k(a - b) = ka - kb$$

Par exemple $3(2x + 5) = 6x + 15$ et $-2(4x - 7) = -8x + 14$. Fais très attention au signe moins devant la parenthèse : il change le signe de tous les termes à l''intérieur.

## La double distributivité

Pour multiplier deux parenthèses, chaque terme de la première multiplie chaque terme de la seconde :

$$(a + b)(c + d) = ac + ad + bc + bd$$

Exemple : $(x + 3)(2x - 5) = 2x^{2} - 5x + 6x - 15 = 2x^{2} + x - 15$.

## Réduire

Réduire, c''est regrouper les termes de même nature. Les $x^{2}$ avec les $x^{2}$, les $x$ avec les $x$, les nombres seuls avec les nombres seuls.

$$5x^{2} + 3x - 2x^{2} + 7x - 4 = 3x^{2} + 10x - 4$$

## Exercice d''application

Développe puis réduis $A = 2(3x - 1) + (x + 4)(x - 2)$.

Correction. D''abord $2(3x - 1) = 6x - 2$. Ensuite $(x + 4)(x - 2) = x^{2} - 2x + 4x - 8 = x^{2} + 2x - 8$. En additionnant, $A = 6x - 2 + x^{2} + 2x - 8 = x^{2} + 8x - 10$.', NULL, 15),
    (v_chapitre_id, 'Les trois identités remarquables', 2, 'texte', 'Ce sont trois produits qui reviennent sans arrêt. Les connaître par cœur te fait gagner un temps précieux au BEPC.

## Les formules

$$(a + b)^{2} = a^{2} + 2ab + b^{2}$$
$$(a - b)^{2} = a^{2} - 2ab + b^{2}$$
$$(a - b)(a + b) = a^{2} - b^{2}$$

L''erreur la plus fréquente est d''écrire $(a+b)^{2} = a^{2} + b^{2}$. C''est faux, le double produit $2ab$ manque. Vérifie avec des nombres : $(3+2)^{2} = 25$, alors que $3^{2} + 2^{2} = 13$.

## Les utiliser pour développer

$(x + 5)^{2} = x^{2} + 10x + 25$.

$(2x - 3)^{2} = 4x^{2} - 12x + 9$, en pensant bien que $a = 2x$ donc $a^{2} = 4x^{2}$.

$(3x - 7)(3x + 7) = 9x^{2} - 49$.

## Les utiliser pour calculer de tête

$101^{2} = (100 + 1)^{2} = 10\,000 + 200 + 1 = 10\,201$.

$98 \times 102 = (100 - 2)(100 + 2) = 10\,000 - 4 = 9\,996$.

## Exercice d''application

Développe $(5x - 2)^{2}$ et calcule $47 \times 53$ sans poser l''opération.

Correction. $(5x-2)^{2} = 25x^{2} - 20x + 4$. Pour le produit, $47 \times 53 = (50 - 3)(50 + 3) = 2\,500 - 9 = 2\,491$.', NULL, 15),
    (v_chapitre_id, 'Simulation : les identités remarquables par les aires', 3, 'interactif', '{
  "widget": "identites-remarquables",
  "consigne": "Choisis $(a+b)^{2}$ avec $a = 4$ et $b = 2$. Le grand carré de côté 6 se découpe en quatre morceaux : tu vois apparaître $a^{2}$, puis deux rectangles $ab$, puis $b^{2}$. Compte les aires : $16 + 8 + 8 + 4 = 36$, et $6^{2} = 36$. Tu comprends alors pourquoi le double produit $2ab$ ne peut pas disparaître. Passe ensuite aux deux autres identités."
}', NULL, 10),
    (v_chapitre_id, 'Factoriser une expression', 4, 'texte', 'Factoriser, c''est l''opération inverse du développement : transformer une somme en produit. C''est indispensable pour résoudre les équations du chapitre suivant.

## Mettre en évidence un facteur commun

Tu repères ce qui apparaît dans tous les termes, et tu le sors.

$$6x + 9 = 3(2x + 3)$$
$$5x^{2} - 15x = 5x(x - 3)$$
$$(x+1)(2x-3) + (x+1)(x+7) = (x+1)\big[(2x-3) + (x+7)\big] = (x+1)(3x+4)$$

Dans le dernier exemple, le facteur commun est la parenthèse $(x+1)$ tout entière.

## Reconnaître une identité remarquable

Lue de droite à gauche, chaque identité devient une factorisation.

$$x^{2} - 16 = x^{2} - 4^{2} = (x - 4)(x + 4)$$
$$x^{2} + 6x + 9 = (x + 3)^{2}$$
$$4x^{2} - 20x + 25 = (2x - 5)^{2}$$

Pour la différence de deux carrés, cherche toujours si les deux termes sont des carrés et si le signe est bien un moins.

## Une méthode en deux temps

Souvent il faut d''abord faire apparaître un facteur commun caché.

$$9x^{2} - 4 + (3x - 2)(x + 5)$$

Le début est une différence de carrés : $9x^{2} - 4 = (3x-2)(3x+2)$. L''expression devient $(3x-2)(3x+2) + (3x-2)(x+5)$, et le facteur commun $(3x-2)$ apparaît. On obtient $(3x-2)(4x+7)$.

## Exercice d''application

Factorise $A = 25x^{2} - 9$ et $B = x^{2} - 8x + 16$.

Correction. $A = (5x)^{2} - 3^{2} = (5x - 3)(5x + 3)$. Pour $B$, on reconnaît $x^{2} - 2 \times 4 \times x + 4^{2}$, donc $B = (x - 4)^{2}$.', NULL, 15),
    (v_chapitre_id, 'Quiz : développer et factoriser', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Le développement de $(x - 6)^{2}$ est :",
      "choix": [
        "$x^{2} - 36$",
        "$x^{2} - 12x + 36$",
        "$x^{2} + 12x + 36$"
      ],
      "bonne": 1,
      "explication": "On applique $(a-b)^{2} = a^{2} - 2ab + b^{2}$ avec $a = x$ et $b = 6$. Le double produit vaut $2 \\times x \\times 6 = 12x$, avec un signe moins."
    },
    {
      "question": "$-3(2x - 5)$ est égal à :",
      "choix": [
        "$-6x - 15$",
        "$-6x + 15$",
        "$-6x - 5$"
      ],
      "bonne": 1,
      "explication": "Le $-3$ multiplie les deux termes. $-3 \\times 2x = -6x$ et $-3 \\times (-5) = +15$."
    },
    {
      "question": "La factorisation de $x^{2} - 49$ est :",
      "choix": [
        "$(x-7)(x+7)$",
        "$(x-7)^{2}$",
        "$(x-49)(x+1)$"
      ],
      "bonne": 0,
      "explication": "C''est une différence de deux carrés : $x^{2} - 7^{2} = (x-7)(x+7)$."
    },
    {
      "question": "Dans $(2x+1)(x-4) + (2x+1)(3x)$, le facteur commun est :",
      "choix": [
        "$x$",
        "$(2x+1)$",
        "$(x-4)$"
      ],
      "bonne": 1,
      "explication": "La parenthèse $(2x+1)$ apparaît dans les deux produits. On obtient $(2x+1)(4x-4)$, soit $4(2x+1)(x-1)$."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Les polynômes', 6, 'texte', 'Un polynôme, c''est simplement une expression faite de puissances de $x$ additionnées, avec des coefficients.

## Vocabulaire

$P(x) = 3x^{3} - 5x^{2} + x - 7$ est un polynôme. Les nombres 3, $-5$, 1 et $-7$ sont ses coefficients, et $-7$ est son terme constant.

Le degré du polynôme est le plus grand exposant de $x$ qui apparaît avec un coefficient non nul. Ici le degré vaut 3.

Un polynôme de degré 1 comme $2x + 3$ s''appelle un binôme du premier degré. Un polynôme de degré 2 comme $x^{2} - 4x + 1$ s''appelle un trinôme du second degré.

## Valeur numérique

Calculer la valeur numérique de $P$ en $a$, c''est remplacer $x$ par $a$ et effectuer. On note cela $P(a)$.

Avec $P(x) = 3x^{3} - 5x^{2} + x - 7$ :
$$P(2) = 3 \times 8 - 5 \times 4 + 2 - 7 = 24 - 20 + 2 - 7 = -1$$

## Racine d''un polynôme

Un réel $a$ est une racine, ou un zéro, du polynôme $P$ lorsque $P(a) = 0$.

Prenons $Q(x) = x^{2} - 5x + 6$. On calcule $Q(2) = 4 - 10 + 6 = 0$, donc 2 est une racine. De même $Q(3) = 9 - 15 + 6 = 0$, donc 3 aussi.

Ces racines servent à factoriser : ici $Q(x) = (x-2)(x-3)$, ce que tu peux vérifier en développant.

## Exercice d''application

Soit $P(x) = 2x^{2} - 7x + 3$. Calcule $P(3)$ et $P(-1)$. Le nombre 3 est-il une racine de $P$ ?

Correction. $P(3) = 2 \times 9 - 21 + 3 = 18 - 21 + 3 = 0$. Comme $P(3) = 0$, le nombre 3 est bien une racine. Ensuite $P(-1) = 2 \times 1 + 7 + 3 = 12$, donc $-1$ n''est pas une racine.', NULL, 15),
    (v_chapitre_id, 'Les fractions rationnelles', 7, 'texte', 'Une fraction rationnelle est un quotient de deux polynômes, par exemple $F(x) = \dfrac{x^{2} - 9}{x - 3}$. Comme pour toute fraction, le dénominateur ne doit jamais être nul.

## Les valeurs interdites

Ce sont les valeurs de $x$ qui annulent le dénominateur. On les cherche avant tout calcul.

Pour $F(x) = \dfrac{x^{2} - 9}{x - 3}$, le dénominateur s''annule quand $x - 3 = 0$, donc quand $x = 3$. La valeur interdite est 3, et on dit que $F$ est définie pour tout $x \neq 3$.

Pour $G(x) = \dfrac{2x + 1}{x^{2} - 4}$, le dénominateur $x^{2} - 4 = (x-2)(x+2)$ s''annule pour $x = 2$ et pour $x = -2$. Il y a donc deux valeurs interdites.

## Simplifier

On factorise le numérateur et le dénominateur, puis on supprime les facteurs communs.

$$F(x) = \dfrac{x^{2} - 9}{x - 3} = \dfrac{(x-3)(x+3)}{x-3} = x + 3 \quad \text{pour } x \neq 3$$

La précision $x \neq 3$ est obligatoire : l''expression de départ n''existe pas en 3, même si $x+3$ existe partout.

## Additionner des fractions rationnelles

Il faut le même dénominateur, exactement comme avec les fractions de nombres.

$$\dfrac{2}{x} + \dfrac{3}{x+1} = \dfrac{2(x+1)}{x(x+1)} + \dfrac{3x}{x(x+1)} = \dfrac{2x + 2 + 3x}{x(x+1)} = \dfrac{5x+2}{x(x+1)}$$

Les valeurs interdites sont 0 et $-1$.

## Exercice d''application

Donne les valeurs interdites puis simplifie $H(x) = \dfrac{x^{2} - 4}{x^{2} + 4x + 4}$.

Correction. Le dénominateur s''écrit $(x+2)^{2}$, qui s''annule pour $x = -2$. C''est la seule valeur interdite. Ensuite $x^{2} - 4 = (x-2)(x+2)$, donc $H(x) = \dfrac{(x-2)(x+2)}{(x+2)^{2}} = \dfrac{x-2}{x+2}$ pour $x \neq -2$.', NULL, 15),
    (v_chapitre_id, 'Quiz : polynômes et fractions rationnelles', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quel est le degré du polynôme $P(x) = 4x^{2} - x^{5} + 7$ ?",
      "choix": [
        "2",
        "5",
        "7"
      ],
      "bonne": 1,
      "explication": "Le degré est le plus grand exposant présent, ici 5, même s''il n''est pas écrit en premier."
    },
    {
      "question": "Pour $P(x) = x^{2} - 3x$, que vaut $P(-2)$ ?",
      "choix": [
        "$-2$",
        "$10$",
        "$-10$"
      ],
      "bonne": 1,
      "explication": "$P(-2) = (-2)^{2} - 3 \\times (-2) = 4 + 6 = 10$. Attention au produit de deux nombres négatifs."
    },
    {
      "question": "Les valeurs interdites de $\\dfrac{x+5}{x^{2}-9}$ sont :",
      "choix": [
        "$-5$",
        "$3$ et $-3$",
        "$9$"
      ],
      "bonne": 1,
      "explication": "On annule le dénominateur : $x^{2} - 9 = (x-3)(x+3)$ s''annule pour $x = 3$ et $x = -3$."
    },
    {
      "question": "$a$ est une racine du polynôme $P$ lorsque :",
      "choix": [
        "$P(a) = a$",
        "$P(a) = 0$",
        "$P(0) = a$"
      ],
      "bonne": 1,
      "explication": "Une racine, ou un zéro, est une valeur qui annule le polynôme."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 9, 'texte', '## Exercice 1

Développe et réduis $A = (2x - 3)^{2} - (x + 1)(x - 4)$.

Correction. $(2x-3)^{2} = 4x^{2} - 12x + 9$ et $(x+1)(x-4) = x^{2} - 3x - 4$. Donc $A = 4x^{2} - 12x + 9 - x^{2} + 3x + 4 = 3x^{2} - 9x + 13$. Attention au signe moins devant la seconde parenthèse, il change les deux signes.

## Exercice 2

Factorise $B = (x-2)(3x+1) - (x-2)^{2}$.

Correction. Le facteur commun est $(x-2)$. On écrit $B = (x-2)\big[(3x+1) - (x-2)\big] = (x-2)(3x + 1 - x + 2) = (x-2)(2x+3)$.

## Exercice 3

Factorise $C = 16x^{2} - 25$ puis $D = 9x^{2} + 30x + 25$.

Correction. $C = (4x)^{2} - 5^{2} = (4x-5)(4x+5)$. Pour $D$, on reconnaît $(3x)^{2} + 2 \times 3x \times 5 + 5^{2}$, donc $D = (3x+5)^{2}$.

## Exercice 4

Soit $P(x) = x^{3} - 7x + 6$. Montre que 1 est une racine, puis que 2 l''est aussi.

Correction. $P(1) = 1 - 7 + 6 = 0$, donc 1 est une racine. Ensuite $P(2) = 8 - 14 + 6 = 0$, donc 2 est aussi une racine.

## Exercice 5

Simplifie $E = \dfrac{4x^{2} - 1}{2x + 1}$ en précisant la valeur interdite.

Correction. Le dénominateur s''annule pour $x = -\dfrac{1}{2}$, c''est la valeur interdite. Le numérateur se factorise : $4x^{2} - 1 = (2x-1)(2x+1)$. Donc $E = 2x - 1$ pour $x \neq -\dfrac{1}{2}$.', NULL, 15),
    (v_chapitre_id, 'Activité d''intégration : le jardin de Mama Rose', 10, 'texte', '## La situation

Mama Rose cultive un jardin carré de côté $x$ mètres, à Dschang. Elle veut l''agrandir : elle ajoute 3 m de longueur d''un côté, et retire 1 m de largeur de l''autre côté, pour contourner un manguier.

1. Exprime l''aire du nouveau jardin en fonction de $x$, sous forme développée et réduite.
2. De combien l''aire a-t-elle changé par rapport au jardin carré de départ ?
3. Pour quelle valeur de $x$ l''aire reste-t-elle exactement la même ?
4. Le jardin de départ mesurait 10 m de côté. Calcule les deux aires et conclus.

## La solution

1. Le nouveau jardin est un rectangle de longueur $x + 3$ et de largeur $x - 1$. Son aire vaut
$$\mathcal{A}(x) = (x+3)(x-1) = x^{2} - x + 3x - 3 = x^{2} + 2x - 3$$

2. L''aire du carré de départ était $x^{2}$. La variation vaut donc
$$\mathcal{A}(x) - x^{2} = x^{2} + 2x - 3 - x^{2} = 2x - 3$$
L''aire augmente de $2x - 3$ mètres carrés.

3. L''aire ne change pas quand $2x - 3 = 0$, c''est-à-dire quand $x = 1{,}5$ m. Mais attention : avec $x = 1{,}5$, la largeur $x - 1$ ne fait que 0,5 m. C''est mathématiquement correct, mais un jardin de 50 cm de large n''a pas grand intérêt.

4. Avec $x = 10$, l''aire du carré valait $100$ m². La nouvelle aire vaut $\mathcal{A}(10) = 100 + 20 - 3 = 117$ m². Mama Rose gagne 17 m², ce que confirme le calcul $2 \times 10 - 3 = 17$.

## Ce qu''il faut remarquer

Le calcul littéral donne la réponse pour toutes les tailles de jardin d''un seul coup. C''est tout son intérêt : au lieu de refaire le calcul pour chaque valeur, tu obtiens une formule valable une fois pour toutes.', NULL, 15);

  RAISE NOTICE 'Chapitre 3, Calcul littéral : 10 lecons ajoutees.';
END $m3$;
