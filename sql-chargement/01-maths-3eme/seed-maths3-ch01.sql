-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 1, Arithmétique
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
  WHERE programme_id = v_programme_id AND ordre = 1;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Arithmétique', 1, 'Module 13 : Relations et opérations fondamentales dans l''ensemble des nombres réels')
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
    (v_chapitre_id, 'Diviseurs communs et PGCD', 1, 'texte', 'Au marché de Mokolo tu achètes 48 oranges et 36 mangues. Tu veux préparer des paniers identiques, avec le même nombre d''oranges et le même nombre de mangues dans chaque panier, et sans qu''il te reste un seul fruit. Combien de paniers peux-tu faire au maximum ?

Pour répondre, il te faut un nombre qui divise à la fois 48 et 36. On dit que c''est un diviseur commun.

## Ce qu''il faut savoir

Un entier naturel $d$ est un diviseur commun de $a$ et de $b$ lorsqu''il divise $a$ et qu''il divise aussi $b$.

Les diviseurs de 48 sont 1, 2, 3, 4, 6, 8, 12, 16, 24 et 48. Ceux de 36 sont 1, 2, 3, 4, 6, 9, 12, 18 et 36. Les diviseurs communs aux deux nombres sont donc 1, 2, 3, 4, 6 et 12.

Le plus grand de ces diviseurs communs s''appelle le plus grand commun diviseur, et on le note $\mathrm{PGCD}(a\,;b)$. Ici $\mathrm{PGCD}(48\,;36) = 12$.

Tu peux donc préparer 12 paniers. Chacun contiendra $48 \div 12 = 4$ oranges et $36 \div 12 = 3$ mangues.

## Deux remarques utiles

Le PGCD existe toujours, parce que 1 divise tous les nombres : il y a donc au moins un diviseur commun.

Si $b$ divise $a$, alors $\mathrm{PGCD}(a\,;b) = b$. Par exemple $\mathrm{PGCD}(60\,;15) = 15$, puisque 15 divise 60.

## Exercice d''application

Détermine $\mathrm{PGCD}(30\,;45)$ en écrivant la liste des diviseurs.

Correction. Les diviseurs de 30 sont 1, 2, 3, 5, 6, 10, 15 et 30. Ceux de 45 sont 1, 3, 5, 9, 15 et 45. Les diviseurs communs sont 1, 3, 5 et 15. Le plus grand est 15, donc $\mathrm{PGCD}(30\,;45) = 15$.', NULL, 15),
    (v_chapitre_id, 'L''algorithme des soustractions successives', 2, 'texte', 'Lister tous les diviseurs, ça marche bien pour 48 et 36. Essaie avec 561 et 462, et tu y passeras ton après-midi. Il te faut une méthode mécanique, qui marche à tous les coups.

## L''idée

Elle repose sur une propriété simple : si $a > b$, alors $\mathrm{PGCD}(a\,;b) = \mathrm{PGCD}(a - b\,;b)$. Autrement dit, retirer le petit nombre du grand ne change pas le PGCD.

Tu retires donc le plus petit du plus grand, tu recommences avec les deux nombres obtenus, et tu continues. Quand les deux nombres deviennent égaux, tu t''arrêtes : ce nombre est le PGCD.

## Un exemple complet

Cherchons $\mathrm{PGCD}(561\,;462)$.

1. $561 - 462 = 99$, il reste 462 et 99.
2. $462 - 99 = 363$, il reste 363 et 99.
3. $363 - 99 = 264$, il reste 264 et 99.
4. $264 - 99 = 165$, il reste 165 et 99.
5. $165 - 99 = 66$, il reste 99 et 66.
6. $99 - 66 = 33$, il reste 66 et 33.
7. $66 - 33 = 33$, les deux nombres sont égaux.

Donc $\mathrm{PGCD}(561\,;462) = 33$.

Tu vois le défaut : quand les deux nombres sont très éloignés, il faut beaucoup de soustractions. La leçon suivante te donne un raccourci.

## Exercice d''application

Trouve $\mathrm{PGCD}(84\,;36)$ par soustractions successives.

Correction. $84 - 36 = 48$ ; $48 - 36 = 12$ ; $36 - 12 = 24$ ; $24 - 12 = 12$. Les deux nombres sont égaux à 12, donc $\mathrm{PGCD}(84\,;36) = 12$.', NULL, 15),
    (v_chapitre_id, 'L''algorithme d''Euclide', 3, 'texte', 'Au lieu de retirer 99 quatre fois de suite, autant faire la division d''un coup. C''est exactement l''idée d''Euclide.

## La propriété

Si $r$ est le reste de la division euclidienne de $a$ par $b$, alors $\mathrm{PGCD}(a\,;b) = \mathrm{PGCD}(b\,;r)$.

Tu divises donc $a$ par $b$, puis $b$ par le reste, puis ce reste par le nouveau reste, et ainsi de suite. Le dernier reste non nul est le PGCD.

## Le même exemple, en quatre lignes

$$561 = 462 \times 1 + 99$$
$$462 = 99 \times 4 + 66$$
$$99 = 66 \times 1 + 33$$
$$66 = 33 \times 2 + 0$$

Le dernier reste non nul est 33, donc $\mathrm{PGCD}(561\,;462) = 33$. Quatre lignes au lieu de sept soustractions, et l''écart se creuse encore plus avec de grands nombres.

## Une situation du quotidien

Un planteur de Mbalmayo a récolté 1 silo de 182 kg de cacao et un autre de 143 kg. Il veut tout conditionner dans des sacs de même masse, sans mélanger les deux récoltes et sans reste.

$$182 = 143 \times 1 + 39$$
$$143 = 39 \times 3 + 26$$
$$39 = 26 \times 1 + 13$$
$$26 = 13 \times 2 + 0$$

Le dernier reste non nul est 13. Les sacs feront 13 kg. Il en faudra $182 \div 13 = 14$ pour le premier silo et $143 \div 13 = 11$ pour le second, soit 25 sacs.

## Exercice d''application

Calcule $\mathrm{PGCD}(1\,071\,;462)$ avec l''algorithme d''Euclide.

Correction. $1\,071 = 462 \times 2 + 147$, puis $462 = 147 \times 3 + 21$, puis $147 = 21 \times 7 + 0$. Le dernier reste non nul est 21, donc $\mathrm{PGCD}(1\,071\,;462) = 21$.', NULL, 15),
    (v_chapitre_id, 'Simulation : le PGCD et le carrelage', 4, 'interactif', '{
  "widget": "pgcd-carreaux",
  "consigne": "Le père d''Agnès veut carreler son salon avec des carreaux carrés tous identiques, sans aucune coupe et sans espace entre eux. Règle la longueur sur 56 cm et la largeur sur 42 cm, puis lis le côté du carreau : c''est $\\mathrm{PGCD}(56\\,;42)$. Change ensuite les dimensions et regarde l''algorithme d''Euclide se dérouler tout seul à chaque fois. Cherche enfin deux dimensions qui donnent un PGCD de 1, et comprends pourquoi le carrelage devient impossible en pratique."
}', NULL, 10),
    (v_chapitre_id, 'Quiz : trouver un PGCD', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quels sont les diviseurs communs de $18$ et $24$ ?",
      "choix": [
        "1, 2, 3 et 6",
        "1, 2, 3, 4 et 6",
        "2, 3 et 6"
      ],
      "bonne": 0,
      "explication": "Les diviseurs de 18 sont 1, 2, 3, 6, 9, 18 et ceux de 24 sont 1, 2, 3, 4, 6, 8, 12, 24. Les communs sont 1, 2, 3 et 6. Le 4 ne divise pas 18."
    },
    {
      "question": "Que vaut $\\mathrm{PGCD}(72\\,;24)$ ?",
      "choix": [
        "8",
        "12",
        "24"
      ],
      "bonne": 2,
      "explication": "24 divise 72, car $72 = 24 \\times 3$. Quand $b$ divise $a$, le PGCD est $b$ lui-même."
    },
    {
      "question": "Dans l''algorithme d''Euclide, le PGCD est :",
      "choix": [
        "le dernier reste non nul",
        "le dernier quotient",
        "le dernier reste, qui vaut 0"
      ],
      "bonne": 0,
      "explication": "On s''arrête quand le reste devient 0, et le PGCD est le reste juste avant, celui qui n''est pas nul."
    },
    {
      "question": "$84 = 60 \\times 1 + 24$, puis $60 = 24 \\times 2 + 12$, puis $24 = 12 \\times 2 + 0$. Donc $\\mathrm{PGCD}(84\\,;60)$ vaut :",
      "choix": [
        "24",
        "12",
        "6"
      ],
      "bonne": 1,
      "explication": "Le dernier reste non nul de la suite de divisions est 12."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Le PPCM et sa relation avec le PGCD', 6, 'texte', 'Le marché de Bafia se tient tous les 8 jours, celui de Ndikiniméki tous les 12 jours. Les deux tombent aujourd''hui le même jour. Dans combien de jours cela se reproduira-t-il ?

Il te faut cette fois un nombre qui soit à la fois multiple de 8 et multiple de 12, et le plus petit possible.

## Ce qu''il faut savoir

On appelle plus petit commun multiple de $a$ et $b$, noté $\mathrm{PPCM}(a\,;b)$, le plus petit entier non nul qui est à la fois multiple de $a$ et multiple de $b$.

Les multiples de 8 sont 8, 16, 24, 32, 40, 48 et ainsi de suite. Ceux de 12 sont 12, 24, 36, 48. Le plus petit multiple commun est 24. Les deux marchés coïncideront donc dans 24 jours.

## La relation à retenir

Pour deux entiers naturels non nuls $a$ et $b$ :

$$\mathrm{PGCD}(a\,;b) \times \mathrm{PPCM}(a\,;b) = a \times b$$

Elle est très pratique : dès que tu connais l''un, tu obtiens l''autre par une simple division.

Avec 8 et 12 : $\mathrm{PGCD}(8\,;12) = 4$, donc $\mathrm{PPCM}(8\,;12) = \dfrac{8 \times 12}{4} = \dfrac{96}{4} = 24$. Tu retrouves bien le résultat.

## Exercice d''application

On donne $\mathrm{PGCD}(561\,;462) = 33$. Calcule $\mathrm{PPCM}(561\,;462)$.

Correction. $\mathrm{PPCM} = \dfrac{561 \times 462}{33} = \dfrac{259\,182}{33} = 7\,854$.', NULL, 15),
    (v_chapitre_id, 'Nombres premiers entre eux et fraction irréductible', 7, 'texte', 'Quand tu écris un résultat, ton professeur attend une fraction simplifiée au maximum. Le PGCD te donne la méthode la plus rapide.

## Nombres premiers entre eux

Deux entiers naturels non nuls sont premiers entre eux lorsque leur PGCD vaut 1, c''est-à-dire que leur seul diviseur commun est 1.

Par exemple 14 et 17 sont premiers entre eux. En revanche 14 et 21 ne le sont pas, puisque 7 les divise tous les deux.

Attention à ne pas confondre : un nombre premier et deux nombres premiers entre eux, ce n''est pas la même chose. 14 n''est pas un nombre premier, pourtant 14 et 17 sont bien premiers entre eux.

## Rendre une fraction irréductible

Une fraction est irréductible quand son numérateur et son dénominateur sont premiers entre eux. Pour y arriver, tu divises les deux par leur PGCD, en une seule fois.

Prenons $\dfrac{462}{561}$. On a vu que $\mathrm{PGCD}(462\,;561) = 33$.

$$\dfrac{462}{561} = \dfrac{462 \div 33}{561 \div 33} = \dfrac{14}{17}$$

Comme 14 et 17 sont premiers entre eux, la fraction $\dfrac{14}{17}$ est irréductible.

## Exercice d''application

Rends la fraction $\dfrac{84}{36}$ irréductible.

Correction. On a vu que $\mathrm{PGCD}(84\,;36) = 12$. Donc $\dfrac{84}{36} = \dfrac{84 \div 12}{36 \div 12} = \dfrac{7}{3}$. Comme 7 et 3 sont premiers entre eux, c''est terminé.', NULL, 15),
    (v_chapitre_id, 'Quiz : PPCM et fractions', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Deux cars partent de Yaoundé, l''un toutes les 15 minutes, l''autre toutes les 20 minutes. Ils viennent de partir ensemble. Dans combien de minutes repartiront-ils ensemble ?",
      "choix": [
        "35 min",
        "60 min",
        "300 min"
      ],
      "bonne": 1,
      "explication": "C''est le PPCM de 15 et 20. Comme $\\mathrm{PGCD}(15\\,;20) = 5$, on a $\\mathrm{PPCM} = \\dfrac{15 \\times 20}{5} = 60$."
    },
    {
      "question": "Si $\\mathrm{PGCD}(a\\,;b) = 6$ et $a \\times b = 360$, que vaut $\\mathrm{PPCM}(a\\,;b)$ ?",
      "choix": [
        "60",
        "6",
        "2160"
      ],
      "bonne": 0,
      "explication": "La relation donne $\\mathrm{PPCM} = \\dfrac{a \\times b}{\\mathrm{PGCD}} = \\dfrac{360}{6} = 60$."
    },
    {
      "question": "La fraction $\\dfrac{45}{60}$ rendue irréductible donne :",
      "choix": [
        "$\\dfrac{9}{12}$",
        "$\\dfrac{3}{4}$",
        "$\\dfrac{15}{20}$"
      ],
      "bonne": 1,
      "explication": "$\\mathrm{PGCD}(45\\,;60) = 15$. En divisant les deux termes par 15 on obtient $\\dfrac{3}{4}$, et 3 et 4 sont premiers entre eux."
    },
    {
      "question": "Les nombres 25 et 12 sont :",
      "choix": [
        "tous les deux premiers",
        "premiers entre eux",
        "ni l''un ni l''autre"
      ],
      "bonne": 1,
      "explication": "Ni 25 ni 12 n''est un nombre premier, mais leur seul diviseur commun est 1 : ils sont donc premiers entre eux."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 9, 'texte', 'Prends une feuille, cherche d''abord seul, puis compare. Ne lis la correction qu''après avoir essayé.

## Exercice 1

Calcule $\mathrm{PGCD}(144\,;60)$ par l''algorithme d''Euclide, puis déduis-en $\mathrm{PPCM}(144\,;60)$.

Correction. $144 = 60 \times 2 + 24$ ; $60 = 24 \times 2 + 12$ ; $24 = 12 \times 2 + 0$. Le dernier reste non nul est 12, donc $\mathrm{PGCD}(144\,;60) = 12$. Ensuite $\mathrm{PPCM} = \dfrac{144 \times 60}{12} = \dfrac{8\,640}{12} = 720$.

## Exercice 2

Un commerçant de Douala a 96 savons et 72 paquets de biscuits. Il prépare des lots identiques, en utilisant tout.

a) Quel est le nombre maximal de lots ?
b) Que contient alors chaque lot ?

Correction. a) Il faut $\mathrm{PGCD}(96\,;72)$. On a $96 = 72 \times 1 + 24$ et $72 = 24 \times 3 + 0$, donc le PGCD vaut 24. Il peut faire 24 lots. b) Chaque lot contient $96 \div 24 = 4$ savons et $72 \div 24 = 3$ paquets de biscuits.

## Exercice 3

Rends irréductibles les fractions $\dfrac{126}{98}$ et $\dfrac{255}{153}$.

Correction. Pour la première, $126 = 98 \times 1 + 28$ ; $98 = 28 \times 3 + 14$ ; $28 = 14 \times 2 + 0$, donc le PGCD est 14 et $\dfrac{126}{98} = \dfrac{9}{7}$. Pour la seconde, $255 = 153 \times 1 + 102$ ; $153 = 102 \times 1 + 51$ ; $102 = 51 \times 2 + 0$, donc le PGCD est 51 et $\dfrac{255}{153} = \dfrac{5}{3}$.

## Exercice 4

Deux feux clignotants s''allument en même temps. Le premier clignote toutes les 18 secondes, le second toutes les 24 secondes. Au bout de combien de temps s''allumeront-ils à nouveau ensemble ?

Correction. C''est le PPCM de 18 et 24. Le PGCD vaut 6, donc $\mathrm{PPCM} = \dfrac{18 \times 24}{6} = 72$. Ils s''allumeront ensemble au bout de 72 secondes, soit 1 minute et 12 secondes.', NULL, 15),
    (v_chapitre_id, 'Activité d''intégration : la clôture du champ', 10, 'texte', 'Voici une situation complète, comme au BEPC. Prends ton temps.

## La situation

M. Ndongo possède un champ rectangulaire de 168 m de long et 126 m de large, du côté de Mbalmayo. Il veut le clôturer avec du grillage et planter des piquets.

Les piquets doivent être régulièrement espacés, il en faut un à chaque coin, et l''écart entre deux piquets voisins doit être un nombre entier de mètres, le plus grand possible pour économiser les piquets.

Un piquet coûte 1 500 FCFA et le grillage coûte 2 000 FCFA le mètre.

1. Quel sera l''écart entre deux piquets ?
2. Combien de piquets faudra-t-il ?
3. Quel sera le coût total du projet ?

## La solution

1. L''écart doit diviser à la fois 168 et 126, et être le plus grand possible : c''est $\mathrm{PGCD}(168\,;126)$. Avec Euclide, $168 = 126 \times 1 + 42$ puis $126 = 42 \times 3 + 0$. Le dernier reste non nul est 42, donc les piquets seront espacés de 42 m.

2. Le périmètre du champ vaut $2 \times (168 + 126) = 2 \times 294 = 588$ m. Comme les piquets sont espacés de 42 m tout autour, leur nombre est $588 \div 42 = 14$ piquets. Il y en a bien un à chaque coin, puisque 42 divise la longueur et la largeur.

3. Les piquets coûtent $14 \times 1\,500 = 21\,000$ FCFA. Le grillage coûte $588 \times 2\,000 = 1\,176\,000$ FCFA. Le total s''élève donc à $1\,197\,000$ FCFA.

## Pour aller plus loin

Si M. Ndongo voulait des piquets tous les 21 m, combien lui en faudrait-il, et le coin serait-il encore occupé par un piquet ? Essaie de répondre seul : 21 divise 42, donc il divise aussi 168 et 126.', NULL, 15);

  RAISE NOTICE 'Chapitre 1, Arithmétique : 10 lecons ajoutees.';
END $m3$;
