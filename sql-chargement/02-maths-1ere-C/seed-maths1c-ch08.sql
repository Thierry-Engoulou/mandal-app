-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 8, Représentation graphique d''une fonction numérique
-- Module 21 : Relations et opérations fondamentales dans l'ensemble des nombres réels
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
  WHERE programme_id = v_programme_id AND ordre = 8;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Représentation graphique d''une fonction numérique', 8, 'Module 21 : Relations et opérations fondamentales dans l''ensemble des nombres réels')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 8 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 8 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Les asymptotes parallèles aux axes', 1, 'texte', 'Une asymptote, c''est une droite dont la courbe se rapproche indéfiniment sans jamais s''en écarter à nouveau. Elle guide le tracé.

## L''asymptote horizontale

Si $\displaystyle\lim_{x \to +\infty} f(x) = \ell$ avec $\ell$ fini, alors la droite d''équation $y = \ell$ est asymptote horizontale à la courbe en $+\infty$.

Même chose en $-\infty$. Une courbe peut avoir deux asymptotes horizontales différentes.

Pour $f(x) = \dfrac{3x - 1}{x + 2}$, la limite en $+\infty$ vaut $\dfrac{3x}{x} = 3$. La droite $y = 3$ est asymptote horizontale.

## L''asymptote verticale

Si $\displaystyle\lim_{x \to a} f(x) = \pm\infty$, alors la droite d''équation $x = a$ est asymptote verticale.

Cela arrive typiquement quand le dénominateur s''annule sans que le numérateur s''annule aussi.

Pour la même fonction, le dénominateur s''annule en $-2$, et le numérateur y vaut $-7$. Donc la droite $x = -2$ est asymptote verticale.

## Attention au faux positif

Si le numérateur et le dénominateur s''annulent tous les deux, il n''y a pas forcément d''asymptote.

Pour $g(x) = \dfrac{x^{2} - 4}{x - 2}$, le dénominateur s''annule en 2, mais la limite y vaut 4. Il n''y a pas d''asymptote verticale, seulement un trou dans la courbe.

Calcule toujours la limite avant de conclure.

## Position de la courbe par rapport à l''asymptote

Pour savoir si la courbe passe au-dessus ou en dessous, tu étudies le signe de $f(x) - \ell$.

Pour $f(x) = \dfrac{3x - 1}{x + 2}$ et $\ell = 3$ :
$$f(x) - 3 = \dfrac{3x - 1 - 3(x+2)}{x+2} = \dfrac{-7}{x+2}$$

Ce quotient est négatif pour $x > -2$, donc la courbe est sous l''asymptote à droite de $-2$. Il est positif pour $x < -2$, donc la courbe est au-dessus à gauche.

## Exercice d''application

Détermine les asymptotes de $f(x) = \dfrac{2x + 5}{x - 1}$.

Correction. En $\pm\infty$, la limite vaut 2, donc $y = 2$ est asymptote horizontale.

En 1, le dénominateur s''annule et le numérateur vaut 7, donc $x = 1$ est asymptote verticale.

Plus précisément, $f(x) - 2 = \dfrac{7}{x - 1}$, qui tend vers $+\infty$ quand $x$ tend vers 1 par la droite, et vers $-\infty$ par la gauche.', NULL, 15),
    (v_chapitre_id, 'Les asymptotes obliques', 2, 'texte', 'Quand la fonction tend vers l''infini mais que la courbe ressemble quand même à une droite, cette droite est une asymptote oblique.

## La définition

La droite $y = ax + b$ est asymptote oblique à la courbe en $+\infty$ si
$$\lim_{x \to +\infty} \big[f(x) - (ax + b)\big] = 0$$

L''écart entre la courbe et la droite s''écrase vers zéro.

## Comment la trouver : la division

Pour une fraction rationnelle dont le degré du numérateur dépasse d''exactement un celui du dénominateur, tu effectues la division.

Prenons $f(x) = \dfrac{x^{2} + 3x - 1}{x - 1}$.

On cherche à écrire $f(x) = ax + b + \dfrac{c}{x - 1}$.

En réduisant au même dénominateur, $(ax + b)(x-1) + c = ax^{2} + (b - a)x + c - b$.

En identifiant avec $x^{2} + 3x - 1$ : $a = 1$, puis $b - a = 3$ donc $b = 4$, puis $c - b = -1$ donc $c = 3$.

Ainsi
$$f(x) = x + 4 + \dfrac{3}{x - 1}$$

Le terme $\dfrac{3}{x-1}$ tend vers 0 en $\pm\infty$. La droite $y = x + 4$ est donc asymptote oblique.

## La position de la courbe

C''est le signe de $\dfrac{3}{x-1}$ qui décide.

Pour $x > 1$, il est positif, donc la courbe est au-dessus de l''asymptote. Pour $x < 1$, elle est en dessous.

## L''autre méthode, par les limites

Si tu ne vois pas la division, calcule d''abord
$$a = \lim_{x \to +\infty} \dfrac{f(x)}{x}$$

puis
$$b = \lim_{x \to +\infty} \big[f(x) - ax\big]$$

Si les deux limites sont finies et $a \neq 0$, la droite $y = ax + b$ est asymptote oblique.

## Exercice d''application

Montre que la courbe de $f(x) = \dfrac{2x^{2} - x + 1}{x + 1}$ admet une asymptote oblique, et précise la position de la courbe.

Correction. On écrit $f(x) = ax + b + \dfrac{c}{x+1}$. En réduisant, $(ax+b)(x+1) + c = ax^{2} + (a+b)x + b + c$.

En identifiant : $a = 2$, puis $a + b = -1$ donc $b = -3$, puis $b + c = 1$ donc $c = 4$.

Donc $f(x) = 2x - 3 + \dfrac{4}{x+1}$, et la droite $y = 2x - 3$ est asymptote oblique.

Le reste $\dfrac{4}{x+1}$ est positif pour $x > -1$ et négatif pour $x < -1$. La courbe est donc au-dessus de l''asymptote à droite de $-1$, et en dessous à gauche.', NULL, 15),
    (v_chapitre_id, 'Le plan d''étude complet d''une fonction', 3, 'texte', 'Voici la marche à suivre, dans l''ordre, pour étudier n''importe quelle fonction et tracer sa courbe. Tu l''appliqueras toute l''année, et encore en Terminale.

## Les sept étapes

Premièrement, l''ensemble de définition. Tu cherches les valeurs interdites.

Deuxièmement, les éventuelles symétries. Si la fonction est paire ou impaire, tu réduis le domaine d''étude de moitié.

Troisièmement, les limites aux bornes du domaine. Chaque borne, finie ou infinie, mérite sa limite.

Quatrièmement, les asymptotes, qui découlent des limites.

Cinquièmement, la dérivée et son signe.

Sixièmement, le tableau de variations, qui rassemble limites et signe de la dérivée.

Septièmement, quelques points particuliers et le tracé.

## Une étude complète

Étudions $f(x) = \dfrac{x^{2} + 1}{x}$.

Le domaine est $\mathbb{R}^{*}$, c''est-à-dire $\mathbb{R}$ privé de 0.

On remarque que $f(-x) = \dfrac{x^{2}+1}{-x} = -f(x)$. La fonction est impaire, sa courbe est symétrique par rapport à l''origine. On peut donc l''étudier seulement sur $]0\,;+\infty[$.

En $0^{+}$, le numérateur tend vers 1 et le dénominateur vers $0^{+}$, donc $f(x)$ tend vers $+\infty$. La droite $x = 0$ est asymptote verticale.

En $+\infty$, on écrit $f(x) = x + \dfrac{1}{x}$. Le reste tend vers 0, donc la droite $y = x$ est asymptote oblique.

Comme $\dfrac{1}{x} > 0$ pour $x > 0$, la courbe est au-dessus de son asymptote sur $]0\,;+\infty[$.

La dérivée vaut $f''(x) = 1 - \dfrac{1}{x^{2}} = \dfrac{x^{2} - 1}{x^{2}}$.

Sur $]0\,;+\infty[$, elle est négative avant 1 et positive après. La fonction décroît de $+\infty$ à 2, puis croît de 2 à $+\infty$.

Le point $(1\,;2)$ est un minimum. Par symétrie, le point $(-1\,;-2)$ est un maximum sur l''autre branche.

## Les pièges à éviter

Ne confonds pas le signe de $f$ et le signe de $f''$. Une fonction peut être négative et croissante.

N''oublie pas de calculer la limite en chaque borne, y compris à gauche et à droite d''une valeur interdite.

Vérifie que ton tableau de variations est cohérent avec les limites. Si tu annonces une limite de $+\infty$ mais que la flèche descend, quelque chose cloche.

## Exercice d''application

Étudie $f(x) = \dfrac{2x - 3}{x + 1}$ et trace sa courbe.

Correction. Le domaine est $\mathbb{R} \setminus \{-1\}$.

En $\pm\infty$, la limite vaut 2, donc $y = 2$ est asymptote horizontale.

En $-1$, le numérateur vaut $-5$. Donc $f$ tend vers $+\infty$ à gauche de $-1$ et vers $-\infty$ à droite. La droite $x = -1$ est asymptote verticale.

La dérivée vaut $f''(x) = \dfrac{2(x+1) - (2x-3)}{(x+1)^{2}} = \dfrac{5}{(x+1)^{2}}$, toujours positive.

La fonction est donc croissante sur chacun des deux intervalles. Elle coupe l''axe des abscisses en $\dfrac{3}{2}$ et l''axe des ordonnées en $-3$.', NULL, 15),
    (v_chapitre_id, 'Une courbe et ses deux asymptotes', 4, 'graphique', '{"functions": [{"expr": "(x^2 + 1)/x", "label": "f(x) = (x² + 1)/x", "color": "#2563eb"}, {"expr": "x", "label": "asymptote oblique y = x", "color": "#dc2626"}], "domain": [-6, 6], "range": [-8, 8], "points": [{"x": 1, "y": 2, "label": "minimum (1 ; 2)"}, {"x": -1, "y": -2, "label": "maximum (−1 ; −2)"}]}', NULL, 5),
    (v_chapitre_id, 'Quiz du chapitre 8', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Si la limite de f en +∞ vaut 4, alors la courbe admet :",
      "choix": [
        "l''asymptote horizontale y = 4",
        "l''asymptote verticale x = 4",
        "une asymptote oblique",
        "aucune asymptote"
      ],
      "bonne": 0,
      "explication": "Une limite finie en l''infini donne une asymptote horizontale d''équation y = cette limite."
    },
    {
      "question": "Pour f(x) = (x² + 3x − 1)/(x − 1) = x + 4 + 3/(x − 1), l''asymptote oblique est :",
      "choix": [
        "y = x + 4",
        "y = x",
        "y = 3x",
        "x = 1"
      ],
      "bonne": 0,
      "explication": "On isole la partie affine. Le reste 3/(x − 1) tend vers 0, donc la droite y = x + 4 est asymptote oblique."
    },
    {
      "question": "Pour savoir si la courbe est au-dessus ou en dessous de son asymptote, on étudie :",
      "choix": [
        "le signe de f(x) moins l''expression de l''asymptote",
        "le signe de f(x)",
        "le signe de f''(x)",
        "la limite de f"
      ],
      "bonne": 0,
      "explication": "La différence mesure l''écart signé entre la courbe et la droite. Positive, la courbe est au-dessus."
    },
    {
      "question": "Le dénominateur de f s''annule en a. Alors x = a est asymptote verticale :",
      "choix": [
        "seulement si la limite de f en a est infinie",
        "toujours",
        "jamais",
        "seulement si le numérateur s''annule aussi"
      ],
      "bonne": 0,
      "explication": "Si le numérateur s''annule aussi, la limite peut être finie. Il faut calculer la limite avant de conclure."
    },
    {
      "question": "Dans un plan d''étude de fonction, que fait-on juste après avoir trouvé l''ensemble de définition ?",
      "choix": [
        "on cherche les symétries éventuelles",
        "on trace la courbe",
        "on calcule la dérivée seconde",
        "on cherche les asymptotes obliques"
      ],
      "bonne": 0,
      "explication": "Repérer une parité permet de diviser le domaine d''étude par deux, donc de gagner beaucoup de temps avant tout calcul."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 8, Représentation graphique d''une fonction numérique : 5 lecons ajoutees.';
END $p1c$;
