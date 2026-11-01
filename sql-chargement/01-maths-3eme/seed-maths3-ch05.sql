-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 5, Équations du premier degré dans ℝ × ℝ
-- 9 leçons.
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
  WHERE programme_id = v_programme_id AND ordre = 5;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Équations du premier degré dans ℝ × ℝ', 5, 'Module 13 : Relations et opérations fondamentales dans l''ensemble des nombres réels')
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
    (v_chapitre_id, 'L''équation du premier degré à deux inconnues', 1, 'texte', 'Jusqu''ici une équation avait une seule inconnue, et une seule solution. Avec deux inconnues, tout change : il y a une infinité de solutions, et chacune est un couple de nombres.

## Définition

Une équation du premier degré dans $\mathbb{R} \times \mathbb{R}$ s''écrit $ax + by = c$, où $a$, $b$ et $c$ sont des réels donnés, avec $a$ et $b$ non tous les deux nuls.

Une solution est un couple $(x\,;y)$ qui rend l''égalité vraie. L''ordre compte : $(2\,;5)$ et $(5\,;2)$ ne sont pas le même couple.

## Trouver des solutions

Prenons $2x + y = 7$.

Si $x = 0$, alors $y = 7$. Le couple $(0\,;7)$ est solution.
Si $x = 1$, alors $y = 5$. Le couple $(1\,;5)$ est solution.
Si $x = 3$, alors $y = 1$. Le couple $(3\,;1)$ est solution.

Tu peux continuer indéfiniment : il y a une infinité de couples solutions.

## La représentation graphique

Si tu places tous ces couples dans un repère, tu obtiens une droite. C''est le résultat important de cette leçon.

L''ensemble des solutions de $ax + by = c$, avec $b$ non nul, est une droite d''équation $y = -\dfrac{a}{b}x + \dfrac{c}{b}$.

Pour $2x + y = 7$, on écrit $y = -2x + 7$. Deux points suffisent à tracer la droite, par exemple $(0\,;7)$ et $(3\,;1)$.

## Une situation du quotidien

Au marché, un ananas coûte $x$ francs et une papaye $y$ francs. Tu payes 2 ananas et 3 papayes pour 2 500 FCFA. Cela se traduit par $2x + 3y = 2\,500$. Avec cette seule information, impossible de connaître chaque prix : il y a trop de possibilités. Il faudra une deuxième équation, c''est l''objet de la leçon suivante.

## Exercice d''application

Le couple $(4\,;-1)$ est-il solution de $3x + 5y = 7$ ? Trouve ensuite deux autres solutions.

Correction. On remplace : $3 \times 4 + 5 \times (-1) = 12 - 5 = 7$. Oui, le couple est solution. Pour en trouver d''autres, prends $x = -1$ : $-3 + 5y = 7$ donne $y = 2$, soit le couple $(-1\,;2)$. Prends $x = 9$ : $27 + 5y = 7$ donne $y = -4$, soit $(9\,;-4)$.', NULL, 15),
    (v_chapitre_id, 'Graphique : les solutions de 2x + y = 7 forment une droite', 2, 'graphique', '{"functions": [{"expr": "-2*x + 7", "label": "y = -2x + 7", "color": "#2563eb"}], "domain": [-2, 6], "points": [{"x": 0, "y": 7, "label": "(0 ; 7)"}, {"x": 1, "y": 5, "label": "(1 ; 5)"}, {"x": 3, "y": 1, "label": "(3 ; 1)"}]}', NULL, 5),
    (v_chapitre_id, 'Résoudre un système par substitution', 3, 'texte', 'Un système de deux équations, c''est deux conditions à satisfaire en même temps. Cette fois, il n''y a en général qu''un seul couple solution.

## Ce qu''est un système

On écrit les deux équations l''une sous l''autre :

$$\begin{cases} 2x + 3y = 2\,500 \\ x + y = 900 \end{cases}$$

Résoudre, c''est trouver le couple $(x\,;y)$ qui vérifie les deux lignes à la fois.

## La méthode de substitution

Tu isoles une inconnue dans la ligne la plus simple, puis tu la remplaces dans l''autre ligne.

Ici la seconde ligne donne $y = 900 - x$.

On remplace $y$ dans la première ligne :
$$2x + 3(900 - x) = 2\,500$$
$$2x + 2\,700 - 3x = 2\,500$$
$$-x = -200$$
$$x = 200$$

On revient à $y = 900 - x = 900 - 200 = 700$.

Le couple solution est $(200\,;700)$.

## Vérifier, toujours

On teste dans les deux lignes. Première ligne : $2 \times 200 + 3 \times 700 = 400 + 2\,100 = 2\,500$. Deuxième ligne : $200 + 700 = 900$. Les deux sont vraies, la solution est correcte.

Si tu reprends l''exemple du marché, l''ananas coûte 200 FCFA et la papaye 700 FCFA.

## Exercice d''application

Résous par substitution :
$$\begin{cases} y = 2x - 1 \\ 3x + y = 14 \end{cases}$$

Correction. La première ligne donne déjà $y$. On remplace : $3x + 2x - 1 = 14$, donc $5x = 15$ et $x = 3$. Puis $y = 2 \times 3 - 1 = 5$. La solution est le couple $(3\,;5)$.', NULL, 15),
    (v_chapitre_id, 'Résoudre un système par combinaison', 4, 'texte', 'Quand aucune inconnue ne s''isole facilement, la combinaison est plus rapide. L''idée est de faire disparaître une inconnue en additionnant les deux lignes.

## La méthode

Tu multiplies chaque ligne par un nombre bien choisi, pour que les coefficients d''une même inconnue deviennent opposés. Puis tu additionnes les deux lignes membre à membre.

Résolvons
$$\begin{cases} 3x + 2y = 19 \\ 5x - 2y = 13 \end{cases}$$

Les coefficients de $y$ sont déjà opposés, $+2$ et $-2$. On additionne directement les deux lignes :
$$(3x + 5x) + (2y - 2y) = 19 + 13$$
$$8x = 32$$
$$x = 4$$

On remplace dans la première ligne : $12 + 2y = 19$, donc $2y = 7$ et $y = 3{,}5$. La solution est $(4\,;3{,}5)$.

## Quand il faut d''abord multiplier

$$\begin{cases} 2x + 3y = 16 \\ 5x - 2y = 2 \end{cases}$$

Pour éliminer $y$, on multiplie la première ligne par 2 et la seconde par 3 :
$$\begin{cases} 4x + 6y = 32 \\ 15x - 6y = 6 \end{cases}$$

En additionnant : $19x = 38$, donc $x = 2$. Puis $4 + 3y = 16$ donne $y = 4$. La solution est $(2\,;4)$.

## Quel choix faire

Prends la substitution quand une inconnue a déjà le coefficient 1. Prends la combinaison dans tous les autres cas, surtout quand les coefficients sont grands. Les deux méthodes donnent évidemment le même résultat.

## Exercice d''application

Résous par combinaison :
$$\begin{cases} 4x + y = 17 \\ 3x - y = 4 \end{cases}$$

Correction. Les coefficients de $y$ sont opposés. En additionnant, $7x = 21$ donc $x = 3$. Puis $12 + y = 17$ donne $y = 5$. La solution est $(3\,;5)$.', NULL, 15),
    (v_chapitre_id, 'Simulation : un système, deux droites', 5, 'interactif', '{
  "widget": "systeme-equations",
  "consigne": "Règle la première équation sur $1x + 1y = 5$ et la seconde sur $2x - 1y = 1$. Les deux droites se croisent en un seul point, et ses coordonnées sont le couple solution du système. Déplace maintenant les curseurs pour rendre les deux droites parallèles : le point d''intersection disparaît et le système n''a plus de solution. Enfin, rends les deux équations proportionnelles, par exemple $1x + 1y = 5$ et $2x + 2y = 10$ : les droites se superposent et il y a une infinité de solutions."
}', NULL, 10),
    (v_chapitre_id, 'Résoudre graphiquement, et les trois cas possibles', 6, 'texte', 'Chaque équation du système est une droite. Résoudre le système, c''est chercher les points communs aux deux droites. Trois situations seulement sont possibles.

## Les trois cas

Les deux droites se coupent en un point : le système a une seule solution, les coordonnées de ce point.

Les deux droites sont parallèles et distinctes : elles n''ont aucun point commun, le système n''a pas de solution, $S = \varnothing$.

Les deux droites sont confondues : tous leurs points conviennent, le système a une infinité de solutions.

## Comment savoir sans tracer

Pour le système formé de $ax + by = c$ et $a''x + b''y = c''$, on calcule $ab'' - a''b$.

Si $ab'' - a''b \neq 0$, les droites se coupent et il y a une solution unique.

Si $ab'' - a''b = 0$, les droites sont parallèles. Elles sont soit confondues, soit sans point commun, selon que les troisièmes coefficients suivent la même proportion ou non.

## Un exemple de chaque

Pour $\begin{cases} x + y = 5 \\ 2x - y = 1 \end{cases}$, on a $1 \times (-1) - 2 \times 1 = -3$, non nul. Solution unique, le couple $(2\,;3)$.

Pour $\begin{cases} x + y = 5 \\ 2x + 2y = 7 \end{cases}$, on a $1 \times 2 - 2 \times 1 = 0$. La seconde ligne dit $x + y = 3{,}5$, ce qui contredit la première. Aucune solution.

Pour $\begin{cases} x + y = 5 \\ 2x + 2y = 10 \end{cases}$, la seconde ligne est le double de la première. Les deux droites sont confondues, il y a une infinité de solutions.

## La méthode graphique en pratique

Tu traces chaque droite avec deux points, et tu lis les coordonnées du point d''intersection. C''est rapide, mais la lecture reste approximative. Pour une valeur exacte, repasse toujours par le calcul.

## Exercice d''application

Sans résoudre, dis combien de solutions possède le système $\begin{cases} 3x - 6y = 9 \\ -x + 2y = -3 \end{cases}$.

Correction. On calcule $3 \times 2 - (-1) \times (-6) = 6 - 6 = 0$ : les droites sont parallèles. En multipliant la seconde ligne par $-3$, on retrouve exactement la première. Les droites sont donc confondues et le système a une infinité de solutions.', NULL, 15),
    (v_chapitre_id, 'Quiz : systèmes de deux équations', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Le couple $(2\\,;3)$ est-il solution du système $x + y = 5$ et $2x - y = 1$ ?",
      "choix": [
        "oui",
        "non, seulement de la première",
        "non, seulement de la seconde"
      ],
      "bonne": 0,
      "explication": "$2 + 3 = 5$ et $2 \\times 2 - 3 = 1$. Les deux lignes sont vérifiées, donc le couple est solution du système."
    },
    {
      "question": "Dans $\\begin{cases} y = 3x - 2 \\\\ x + y = 10 \\end{cases}$, la méthode la plus rapide est :",
      "choix": [
        "la substitution",
        "la combinaison",
        "le tracé des droites"
      ],
      "bonne": 0,
      "explication": "$y$ est déjà isolé dans la première ligne : il suffit de le remplacer dans la seconde."
    },
    {
      "question": "Deux droites parallèles et distinctes représentent un système qui a :",
      "choix": [
        "une solution",
        "aucune solution",
        "une infinité de solutions"
      ],
      "bonne": 1,
      "explication": "Sans point commun, aucun couple ne vérifie les deux équations à la fois."
    },
    {
      "question": "En additionnant $2x + 5y = 12$ et $3x - 5y = 8$, on obtient :",
      "choix": [
        "$5x = 20$",
        "$5x + 10y = 20$",
        "$x = 20$"
      ],
      "bonne": 0,
      "explication": "Les termes en $y$ s''éliminent car $5y$ et $-5y$ sont opposés. Il reste $5x = 20$, donc $x = 4$."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 8, 'texte', '## Exercice 1

Résous par substitution : $\begin{cases} x - 2y = 1 \\ 3x + y = 17 \end{cases}$

Correction. La première ligne donne $x = 1 + 2y$. On remplace : $3(1 + 2y) + y = 17$, donc $3 + 7y = 17$, donc $y = 2$. Puis $x = 1 + 4 = 5$. La solution est $(5\,;2)$.

## Exercice 2

Résous par combinaison : $\begin{cases} 5x + 3y = 21 \\ 2x - 3y = 0 \end{cases}$

Correction. Les coefficients de $y$ sont opposés. En additionnant, $7x = 21$ donc $x = 3$. Puis $6 - 3y = 0$ donne $y = 2$. La solution est $(3\,;2)$.

## Exercice 3

Résous : $\begin{cases} 4x + 3y = 18 \\ 3x - 2y = 5 \end{cases}$

Correction. Pour éliminer $y$, on multiplie la première ligne par 2 et la seconde par 3, ce qui donne $8x + 6y = 36$ et $9x - 6y = 15$. En additionnant, $17x = 51$, donc $x = 3$. On remplace dans la première ligne : $12 + 3y = 18$, donc $y = 2$. La solution est $(3\,;2)$. Vérification dans la seconde ligne : $3 \times 3 - 2 \times 2 = 5$.

## Exercice 4

Dans une salle de cinéma de Douala, le billet adulte coûte 2 000 FCFA et le billet enfant 1 200 FCFA. Un soir, 180 billets ont été vendus pour une recette de 296 000 FCFA. Combien d''adultes et combien d''enfants ?

Correction. Appelons $a$ le nombre d''adultes et $e$ le nombre d''enfants. On a $a + e = 180$ et $2\,000a + 1\,200e = 296\,000$. La première ligne donne $e = 180 - a$. En remplaçant : $2\,000a + 1\,200(180 - a) = 296\,000$, soit $2\,000a + 216\,000 - 1\,200a = 296\,000$, donc $800a = 80\,000$ et $a = 100$. Il y avait 100 adultes et 80 enfants.

## Exercice 5

Combien de solutions possède $\begin{cases} 2x + 4y = 6 \\ x + 2y = 3 \end{cases}$ ?

Correction. La première ligne est exactement le double de la seconde. Les deux droites sont confondues : il y a une infinité de solutions.', NULL, 15),
    (v_chapitre_id, 'Activité d''intégration : la coopérative de Foumbot', 9, 'texte', '## La situation

Une coopérative agricole de Foumbot vend deux produits sur le marché de Bafoussam : des sacs de pommes de terre et des sacs d''oignons.

Un jour de marché, elle vend 12 sacs de pommes de terre et 8 sacs d''oignons, et encaisse 268 000 FCFA.

Le lendemain, elle vend 9 sacs de pommes de terre et 14 sacs d''oignons, et encaisse 289 000 FCFA.

1. Mets la situation en système, en précisant ce que représentent les inconnues.
2. Résous le système.
3. Donne le prix d''un sac de chaque produit.
4. Combien encaissera-t-elle en vendant 20 sacs de pommes de terre et 25 sacs d''oignons ?

## La solution

1. Appelons $p$ le prix d''un sac de pommes de terre et $o$ le prix d''un sac d''oignons, tous deux en FCFA.

$$\begin{cases} 12p + 8o = 268\,000 \\ 9p + 14o = 289\,000 \end{cases}$$

2. On simplifie d''abord la première ligne par 4 : $3p + 2o = 67\,000$. La seconde se simplifie par 1 seulement, on la garde. Pour éliminer $o$, on multiplie la première ligne simplifiée par 7 et la seconde par 1 :

$$\begin{cases} 21p + 14o = 469\,000 \\ 9p + 14o = 289\,000 \end{cases}$$

En soustrayant la seconde de la première : $12p = 180\,000$, donc $p = 15\,000$.

On remplace dans $3p + 2o = 67\,000$ : $45\,000 + 2o = 67\,000$, donc $2o = 22\,000$ et $o = 11\,000$.

3. Un sac de pommes de terre coûte 15 000 FCFA et un sac d''oignons 11 000 FCFA.

Vérification sur le deuxième jour : $9 \times 15\,000 + 14 \times 11\,000 = 135\,000 + 154\,000 = 289\,000$. C''est exact.

4. Pour 20 sacs de pommes de terre et 25 sacs d''oignons, la recette sera de
$$20 \times 15\,000 + 25 \times 11\,000 = 300\,000 + 275\,000 = 575\,000 \text{ FCFA}$$

## Ce qu''il faut remarquer

Une seule journée de vente n''aurait pas suffi : avec une seule équation, il existe une infinité de couples de prix possibles. C''est la deuxième journée qui fixe la réponse. Retiens cette idée, elle explique à quoi servent les systèmes.', NULL, 15);

  RAISE NOTICE 'Chapitre 5, Équations du premier degré dans ℝ × ℝ : 9 lecons ajoutees.';
END $m3$;
