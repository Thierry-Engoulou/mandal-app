-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 6, Limite et continuité d''une fonction numérique
-- Module 21 : Relations et opérations fondamentales dans l'ensemble des nombres réels
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
  WHERE programme_id = v_programme_id AND ordre = 6;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Limite et continuité d''une fonction numérique', 6, 'Module 21 : Relations et opérations fondamentales dans l''ensemble des nombres réels')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 6 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 6 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Les limites d''une fonction', 1, 'texte', 'La limite répond à une question simple : quand $x$ s''approche d''une valeur, vers quoi se dirige $f(x)$ ?

## Limite en l''infini

Quand $x$ devient très grand, que devient $f(x)$ ?

Pour $f(x) = \dfrac{1}{x}$, plus $x$ grandit, plus $\dfrac{1}{x}$ se rapproche de 0. On écrit
$$\lim_{x \to +\infty} \dfrac{1}{x} = 0$$

Les limites de référence à connaître par cœur :
$$\lim_{x \to +\infty} x^{n} = +\infty \qquad \lim_{x \to +\infty} \dfrac{1}{x^{n}} = 0 \qquad \lim_{x \to +\infty} \sqrt{x} = +\infty$$

En $-\infty$, $x^{n}$ tend vers $+\infty$ si $n$ est pair, vers $-\infty$ si $n$ est impair.

## Limite en un point

Pour $f(x) = \dfrac{1}{x}$ en 0, tout dépend du côté d''où tu arrives.

Si $x$ s''approche de 0 par la droite, $x$ est positif et $\dfrac{1}{x}$ devient très grand :
$$\lim_{x \to 0^{+}} \dfrac{1}{x} = +\infty$$

Par la gauche, $x$ est négatif :
$$\lim_{x \to 0^{-}} \dfrac{1}{x} = -\infty$$

Les deux limites sont différentes, donc $f$ n''a pas de limite en 0.

## Les opérations

La limite d''une somme est la somme des limites, celle d''un produit le produit des limites, celle d''un quotient le quotient des limites. Sauf dans quatre cas.

## Les quatre formes indéterminées

$$\infty - \infty \qquad 0 \times \infty \qquad \dfrac{\infty}{\infty} \qquad \dfrac{0}{0}$$

« Indéterminée » ne veut pas dire « pas de limite ». Cela veut dire que la règle habituelle ne suffit pas, et qu''il faut transformer l''expression.

## La technique du terme de plus haut degré

Pour un polynôme en $\pm\infty$, seul le terme de plus haut degré compte.
$$\lim_{x \to +\infty} (3x^{3} - 500x^{2} + 10^{6}) = \lim_{x \to +\infty} 3x^{3} = +\infty$$

Pour un quotient de polynômes en $\pm\infty$, tu gardes le rapport des termes de plus haut degré.
$$\lim_{x \to +\infty} \dfrac{2x^{2} - 5x + 1}{3x^{2} + 7} = \lim_{x \to +\infty} \dfrac{2x^{2}}{3x^{2}} = \dfrac{2}{3}$$

Attention, cette règle ne vaut que pour les limites en l''infini. En un point fini, elle est fausse.

## La forme 0 sur 0 : on factorise

$$\lim_{x \to 3} \dfrac{x^{2} - 9}{x - 3}$$

En remplaçant directement, on obtient $\dfrac{0}{0}$. On factorise le numérateur :
$$\dfrac{x^{2} - 9}{x - 3} = \dfrac{(x-3)(x+3)}{x - 3} = x + 3$$

pour $x \neq 3$. La limite vaut donc $3 + 3 = 6$.

## L''expression conjuguée

$$\lim_{x \to +\infty} \left(\sqrt{x^{2} + 1} - x\right)$$

C''est une forme $\infty - \infty$. On multiplie et on divise par la quantité conjuguée :
$$\sqrt{x^{2}+1} - x = \dfrac{(x^{2} + 1) - x^{2}}{\sqrt{x^{2}+1} + x} = \dfrac{1}{\sqrt{x^{2}+1} + x}$$

Le dénominateur tend vers $+\infty$, donc la limite vaut 0.

## Exercice d''application

Calcule $\displaystyle\lim_{x \to 2} \dfrac{x^{2} - 5x + 6}{x - 2}$.

Correction. En remplaçant, on obtient $\dfrac{0}{0}$. Le numérateur a pour racines 2 et 3, donc il se factorise en $(x-2)(x-3)$.

Pour $x \neq 2$, l''expression vaut $x - 3$. La limite est donc $2 - 3 = -1$.', NULL, 15),
    (v_chapitre_id, 'La continuité', 2, 'texte', 'Une fonction est continue quand tu peux tracer sa courbe sans lever le crayon. Voilà l''idée. Voici maintenant la définition.

## La définition

$f$ est continue en $a$ si $f$ est définie en $a$ et si
$$\lim_{x \to a} f(x) = f(a)$$

Trois choses doivent donc être vraies en même temps : $f(a)$ existe, la limite existe, et les deux sont égales.

$f$ est continue sur un intervalle si elle est continue en chacun de ses points.

## Les fonctions continues que tu connais déjà

Les polynômes sont continus sur $\mathbb{R}$. Les fonctions rationnelles sont continues sur leur ensemble de définition. La racine carrée est continue sur $[0\,;+\infty[$. Le sinus et le cosinus sont continus sur $\mathbb{R}$.

Somme, produit, quotient et composée de fonctions continues restent continus, partout où ils sont définis.

## Une fonction qui n''est pas continue

Soit $f$ définie par $f(x) = x + 1$ si $x < 2$ et $f(x) = x^{2}$ si $x \geq 2$.

À gauche de 2, la limite vaut $2 + 1 = 3$. À droite, elle vaut $4$. Et $f(2) = 4$.

Les limites à gauche et à droite sont différentes, donc $f$ n''est pas continue en 2. La courbe fait un saut.

Pour qu''une fonction définie par morceaux soit continue au point de raccordement, il faut que la limite à gauche, la limite à droite et la valeur en ce point soient toutes les trois égales.

## Le prolongement par continuité

Reprenons $g(x) = \dfrac{x^{2} - 9}{x - 3}$. Cette fonction n''est pas définie en 3, mais sa limite en 3 vaut 6.

On peut alors définir une nouvelle fonction $\tilde{g}$ qui vaut $g(x)$ pour $x \neq 3$ et 6 pour $x = 3$. Cette fonction est continue sur $\mathbb{R}$. On dit qu''on a prolongé $g$ par continuité en 3.

Ce prolongement n''est possible que si la limite existe et est finie.

## Le théorème des valeurs intermédiaires

Si $f$ est continue sur $[a\,;b]$, alors $f$ prend toutes les valeurs comprises entre $f(a)$ et $f(b)$.

En particulier, si $f(a)$ et $f(b)$ sont de signes contraires, l''équation $f(x) = 0$ a au moins une solution dans $]a\,;b[$.

Si en plus $f$ est strictement monotone, cette solution est unique.

C''est l''outil qui permet d''affirmer qu''une équation a une solution, même sans savoir la calculer.

## Un exemple d''utilisation

Montrons que $x^{3} + x - 1 = 0$ a une solution unique dans $[0\,;1]$.

La fonction $f(x) = x^{3} + x - 1$ est un polynôme, donc continue.

$f(0) = -1$ et $f(1) = 1$. Les signes sont contraires, donc il y a au moins une solution.

De plus $f$ est strictement croissante, puisque $x^{3}$ et $x$ le sont. La solution est donc unique.

En calculant $f(0{,}6) = 0{,}216 + 0{,}6 - 1 = -0{,}184$ et $f(0{,}7) = 0{,}343 + 0{,}7 - 1 = 0{,}043$, on encadre la solution entre 0,6 et 0,7.

## Exercice d''application

Soit $f(x) = \dfrac{x^{2} - 4}{x - 2}$ pour $x \neq 2$. Peut-on prolonger $f$ par continuité en 2 ? Si oui, quelle valeur donner à $f(2)$ ?

Correction. Pour $x \neq 2$, $f(x) = \dfrac{(x-2)(x+2)}{x-2} = x + 2$.

La limite en 2 vaut 4, elle est finie. On peut donc prolonger en posant $f(2) = 4$.', NULL, 15),
    (v_chapitre_id, 'Voir une asymptote se former', 3, 'interactif', '{
  "widget": "limites-asymptotes",
  "consigne": "Garde $a = 2$, $b = 1$, $c = 1$ et $d = -1$. Fais glisser $x$ tout près de 1 par la gauche, puis par la droite, et lis $f(x)$ à chaque fois. Ensuite pousse $x$ vers 6 : de quelle valeur $f(x)$ se rapproche-t-il ?"
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 6', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "La limite en +∞ de (2x² − 5x + 1)/(3x² + 7) vaut :",
      "choix": [
        "2/3",
        "0",
        "+∞",
        "1/7"
      ],
      "bonne": 0,
      "explication": "En l''infini on garde le rapport des termes de plus haut degré, soit 2x²/3x² = 2/3."
    },
    {
      "question": "Laquelle de ces écritures est une forme indéterminée ?",
      "choix": [
        "∞ − ∞",
        "∞ + ∞",
        "0 × 5",
        "1/∞"
      ],
      "bonne": 0,
      "explication": "Les quatre formes indéterminées sont ∞ − ∞, 0 × ∞, ∞/∞ et 0/0. Les autres se calculent directement."
    },
    {
      "question": "f est continue en a lorsque :",
      "choix": [
        "f(a) existe et la limite de f en a vaut f(a)",
        "f est définie sur ℝ",
        "f est croissante autour de a",
        "la limite de f en a existe"
      ],
      "bonne": 0,
      "explication": "Il faut les trois à la fois : f définie en a, limite existante, et égalité entre les deux."
    },
    {
      "question": "Si f est continue sur [0 ; 1] avec f(0) = −3 et f(1) = 5, alors l''équation f(x) = 0 :",
      "choix": [
        "a au moins une solution dans ]0 ; 1[",
        "n''a aucune solution",
        "a exactement deux solutions",
        "a une solution seulement si f est croissante"
      ],
      "bonne": 0,
      "explication": "C''est le théorème des valeurs intermédiaires. La monotonie servirait seulement à prouver que la solution est unique."
    },
    {
      "question": "La limite en 3 de (x² − 9)/(x − 3) vaut :",
      "choix": [
        "6",
        "0",
        "+∞",
        "elle n''existe pas"
      ],
      "bonne": 0,
      "explication": "On factorise le numérateur en (x − 3)(x + 3), on simplifie, et il reste x + 3 qui tend vers 6."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 6, Limite et continuité d''une fonction numérique : 4 lecons ajoutees.';
END $p1c$;
