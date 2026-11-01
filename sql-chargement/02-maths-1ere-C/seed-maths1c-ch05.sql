-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 5, Généralités sur les fonctions numériques, 2ème partie
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
  WHERE programme_id = v_programme_id AND ordre = 5;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Généralités sur les fonctions numériques, 2ème partie', 5, 'Module 21 : Relations et opérations fondamentales dans l''ensemble des nombres réels')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 5 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 5 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Lire une courbe', 1, 'texte', 'Une courbe contient énormément d''informations. Encore faut-il savoir les y chercher.

## Un point appartient-il à la courbe ?

Le point $A(a\,;b)$ appartient à la courbe de $f$ si et seulement si $f(a) = b$. C''est tout.

Le point $A(2\,;7)$ appartient-il à la courbe de $f(x) = x^{2} + 3$ ? On calcule $f(2) = 4 + 3 = 7$. Oui.

Et $B(-1\,;5)$ ? On calcule $f(-1) = 1 + 3 = 4$, ce qui n''est pas 5. Non.

## Lire une image et un antécédent

Pour lire $f(3)$, tu pars de 3 sur l''axe des abscisses, tu montes jusqu''à la courbe, puis tu lis à gauche sur l''axe des ordonnées.

Pour lire les antécédents de 2, tu pars de 2 sur l''axe des ordonnées, tu traces une horizontale, et tu lis les abscisses de tous les points d''intersection avec la courbe.

## Le sens de variation

$f$ est croissante sur un intervalle $I$ si, pour tous $a$ et $b$ de $I$ avec $a < b$, on a $f(a) \leq f(b)$. La courbe monte quand on va vers la droite.

$f$ est décroissante si $a < b$ entraîne $f(a) \geq f(b)$. La courbe descend.

Quand les inégalités sont strictes, on dit strictement croissante ou strictement décroissante.

Le tableau de variations résume tout cela avec des flèches.

## Résoudre graphiquement

Pour résoudre $f(x) = k$, tu traces l''horizontale $y = k$ et tu comptes les points d''intersection.

Pour résoudre $f(x) \geq k$, tu repères les portions de courbe situées au-dessus de cette horizontale, et tu lis les abscisses correspondantes.

Pour résoudre $f(x) = g(x)$, tu cherches les abscisses des points où les deux courbes se croisent.

## Un exemple

Soit $f$ définie sur $[-3\,;4]$ par $f(x) = x^{2} - 2x - 3$.

Les points d''intersection avec l''axe des abscisses vérifient $f(x) = 0$. Le discriminant vaut $4 + 12 = 16$, les racines sont $-1$ et 3.

Le sommet est en $x = \dfrac{2}{2} = 1$, et $f(1) = 1 - 2 - 3 = -4$.

Donc $f$ décroît sur $[-3\,;1]$ puis croît sur $[1\,;4]$. Son minimum vaut $-4$, atteint en 1.

L''inéquation $f(x) \leq 0$ a pour solution $[-1\,;3]$, la portion où la courbe est sous l''axe.

## Exercice d''application

Une fonction $f$ est définie sur $[-2\,;5]$. Sa courbe passe par $A(-2\,;3)$, descend jusqu''à $B(1\,;-2)$, puis remonte jusqu''à $C(5\,;4)$. Combien l''équation $f(x) = 0$ a-t-elle de solutions ?

Correction. Sur $[-2\,;1]$, $f$ passe de 3 à $-2$ en décroissant, donc elle traverse 0 une fois. Sur $[1\,;5]$, elle passe de $-2$ à 4 en croissant, donc elle traverse 0 une fois encore. L''équation a exactement deux solutions.', NULL, 15),
    (v_chapitre_id, 'Parité, périodicité, symétries', 2, 'texte', 'Repérer une symétrie, c''est diviser le travail par deux. Tu étudies la fonction sur la moitié du domaine, et tu complètes par symétrie.

## Fonction paire

$f$ est paire si $D_{f}$ est symétrique par rapport à 0 et si
$$f(-x) = f(x) \quad \text{pour tout } x \text{ de } D_{f}$$

Sa courbe est alors symétrique par rapport à l''axe des ordonnées.

Exemples : $x^{2}$, $x^{4}$, $\cos x$, $|x|$.

## Fonction impaire

$f$ est impaire si $D_{f}$ est symétrique par rapport à 0 et si
$$f(-x) = -f(x)$$

Sa courbe est symétrique par rapport à l''origine.

Exemples : $x$, $x^{3}$, $\sin x$, $\dfrac{1}{x}$.

Remarque utile : si $f$ est impaire et définie en 0, alors $f(0) = 0$.

## Comment le vérifier

Calcule $f(-x)$ et compare avec $f(x)$ et $-f(x)$.

Pour $f(x) = \dfrac{x^{3}}{x^{2} + 1}$, on a $f(-x) = \dfrac{-x^{3}}{x^{2} + 1} = -f(x)$. La fonction est impaire.

Pour $f(x) = x^{2} + x$, on a $f(-x) = x^{2} - x$. Ce n''est ni $f(x)$ ni $-f(x)$. La fonction n''est ni paire ni impaire, ce qui est le cas le plus fréquent.

## Périodicité

$f$ est périodique de période $T$ si
$$f(x + T) = f(x) \quad \text{pour tout } x$$

Tu étudies alors $f$ sur un intervalle de longueur $T$, et tu recopies le motif.

Les fonctions $\cos$ et $\sin$ ont pour période $2\pi$. La fonction $\tan$ a pour période $\pi$.

Pour $f(x) = \cos(3x)$, la période est $\dfrac{2\pi}{3}$. De façon générale, $\cos(\omega x)$ a pour période $\dfrac{2\pi}{|\omega|}$.

## Axe de symétrie et centre de symétrie

La droite d''équation $x = a$ est axe de symétrie de la courbe si
$$f(a + h) = f(a - h) \quad \text{pour tout } h \text{ tel que ces nombres soient définis}$$

Le point $\Omega(a\,;b)$ est centre de symétrie si
$$f(a + h) + f(a - h) = 2b$$

Pour une parabole $ax^{2} + bx + c$, l''axe de symétrie est toujours $x = -\dfrac{b}{2a}$.

## Exercice d''application

Montre que la droite $x = 2$ est axe de symétrie de la courbe de $f(x) = x^{2} - 4x + 7$.

Correction. On calcule $f(2 + h) = (2+h)^{2} - 4(2+h) + 7 = 4 + 4h + h^{2} - 8 - 4h + 7 = h^{2} + 3$.

Puis $f(2 - h) = 4 - 4h + h^{2} - 8 + 4h + 7 = h^{2} + 3$.

Les deux sont égaux pour tout $h$, donc la droite $x = 2$ est bien axe de symétrie.', NULL, 15),
    (v_chapitre_id, 'Les fonctions associées', 3, 'texte', 'À partir de la courbe de $f$, tu obtiens gratuitement plusieurs autres courbes. Il suffit de savoir quel mouvement correspond à quelle écriture.

## Les quatre transformations de base

La courbe de $f(x) + k$ est celle de $f$ translatée de $k$ vers le haut si $k > 0$, vers le bas si $k < 0$.

La courbe de $f(x + a)$ est celle de $f$ translatée de $a$ vers la gauche si $a > 0$, vers la droite si $a < 0$. Attention, c''est l''inverse de ce qu''on croit au premier regard.

La courbe de $-f(x)$ est la symétrique de celle de $f$ par rapport à l''axe des abscisses.

La courbe de $f(-x)$ est la symétrique par rapport à l''axe des ordonnées.

## La valeur absolue

La courbe de $|f(x)|$ s''obtient en gardant la partie de la courbe située au-dessus de l''axe des abscisses, et en repliant vers le haut la partie située en dessous.

C''est logique, puisque $|f(x)| = f(x)$ quand $f(x) \geq 0$, et $|f(x)| = -f(x)$ sinon.

## L''étirement

La courbe de $k \times f(x)$ avec $k > 0$ est celle de $f$ étirée verticalement d''un facteur $k$. Si $k > 1$ la courbe est tirée vers le haut, si $0 < k < 1$ elle est écrasée vers l''axe.

## Les combiner

Pour $g(x) = -(x - 3)^{2} + 5$, pars de la parabole $x^{2}$.

Tu la translates de 3 vers la droite, ce qui donne $(x-3)^{2}$. Tu la retournes, ce qui donne $-(x-3)^{2}$. Tu la montes de 5.

Le sommet, qui était en $(0\,;0)$, se retrouve en $(3\,;5)$, et la parabole est tournée vers le bas.

## Exercice d''application

La courbe de $f(x) = \dfrac{1}{x}$ est une hyperbole. Décris la courbe de $g(x) = \dfrac{1}{x - 2} + 3$.

Correction. On part de $\dfrac{1}{x}$, on translate de 2 vers la droite, puis de 3 vers le haut.

Les asymptotes, qui étaient les axes, deviennent les droites $x = 2$ et $y = 3$. Le centre de symétrie passe de l''origine au point $(2\,;3)$.', NULL, 15),
    (v_chapitre_id, 'Une fonction et ses associées', 4, 'graphique', '{"functions": [{"expr": "x^2", "label": "f(x) = x²", "color": "#64748b"}, {"expr": "(x - 3)^2", "label": "f(x − 3), translatée vers la droite", "color": "#2563eb"}, {"expr": "0 - (x - 3)^2 + 5", "label": "−f(x − 3) + 5, retournée puis montée", "color": "#dc2626"}], "domain": [-3, 7], "range": [-5, 9], "points": [{"x": 0, "y": 0, "label": "sommet de f"}, {"x": 3, "y": 5, "label": "nouveau sommet"}]}', NULL, 5),
    (v_chapitre_id, 'Quiz du chapitre 5', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Une fonction est paire lorsque :",
      "choix": [
        "f(−x) = f(x) pour tout x du domaine",
        "f(−x) = −f(x)",
        "f(0) = 0",
        "sa courbe passe par l''origine"
      ],
      "bonne": 0,
      "explication": "La courbe est alors symétrique par rapport à l''axe des ordonnées. Il faut aussi que le domaine soit symétrique par rapport à 0."
    },
    {
      "question": "La courbe de f(x + 2) est celle de f translatée :",
      "choix": [
        "de 2 vers la gauche",
        "de 2 vers la droite",
        "de 2 vers le haut",
        "de 2 vers le bas"
      ],
      "bonne": 0,
      "explication": "C''est le piège classique. Pour obtenir la même valeur, il faut entrer un x plus petit de 2, donc la courbe se déplace vers la gauche."
    },
    {
      "question": "La fonction x ↦ cos(3x) a pour période :",
      "choix": [
        "2π/3",
        "2π",
        "3π",
        "π/3"
      ],
      "bonne": 0,
      "explication": "La période de cos(ωx) vaut 2π divisé par la valeur absolue de ω, soit 2π/3."
    },
    {
      "question": "La courbe de |f(x)| s''obtient en :",
      "choix": [
        "repliant vers le haut la partie située sous l''axe des abscisses",
        "déplaçant la courbe vers le haut",
        "symétrisant par rapport à l''axe des ordonnées",
        "retournant toute la courbe"
      ],
      "bonne": 0,
      "explication": "Là où f est positive, rien ne change. Là où f est négative, on prend l''opposé, ce qui revient à replier cette partie au-dessus de l''axe."
    },
    {
      "question": "L''axe de symétrie de la parabole d''équation y = 2x² − 8x + 1 est :",
      "choix": [
        "x = 2",
        "x = −2",
        "x = 4",
        "y = 1"
      ],
      "bonne": 0,
      "explication": "L''axe a pour équation x = −b/(2a) = 8/4 = 2."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 5, Généralités sur les fonctions numériques, 2ème partie : 5 lecons ajoutees.';
END $p1c$;
