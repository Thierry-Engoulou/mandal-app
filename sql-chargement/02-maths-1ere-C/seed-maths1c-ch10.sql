-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 10, Séries statistiques regroupées en classes
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
  WHERE programme_id = v_programme_id AND ordre = 10;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Séries statistiques regroupées en classes', 10, 'Module 21 : Relations et opérations fondamentales dans l''ensemble des nombres réels')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 10 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 10 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Vocabulaire des séries regroupées en classes', 1, 'texte', 'Quand les données sont nombreuses et très variées, on ne peut plus lister chaque valeur. On les range alors par tranches, qu''on appelle des classes.

## Le vocabulaire

Une classe est un intervalle, par exemple $[0\,;4[$. Son amplitude est sa longueur, ici 4. Son centre est le milieu, ici 2.

L''effectif $n_{i}$ d''une classe est le nombre d''individus qui s''y trouvent. L''effectif total $N$ est la somme de tous les effectifs.

La fréquence est $f_{i} = \dfrac{n_{i}}{N}$. On l''exprime souvent en pourcentage. La somme des fréquences vaut toujours 1, soit 100 %.

## Les effectifs cumulés

L''effectif cumulé croissant d''une classe, c''est le nombre d''individus situés avant la borne supérieure de cette classe.

Pour les notes d''une classe de 1ère C, si les effectifs sont 4, 9, 14, 8 et 5 pour les classes $[0\,;4[$, $[4\,;8[$, $[8\,;12[$, $[12\,;16[$ et $[16\,;20]$, les effectifs cumulés croissants sont 4, 13, 27, 35 et 40.

Cela signifie par exemple que 27 élèves ont moins de 12 sur 20.

## L''histogramme

Dans un histogramme, c''est l''aire du rectangle qui représente l''effectif, pas sa hauteur.

Quand toutes les classes ont la même amplitude, hauteur et effectif sont proportionnels, et on peut prendre l''effectif comme hauteur.

Quand les amplitudes sont différentes, il faut utiliser la densité :
$$\text{hauteur} = \dfrac{\text{effectif}}{\text{amplitude}}$$

Sinon le graphique ment. Une classe large paraîtrait plus importante qu''elle ne l''est.

## Un exemple de correction par la densité

Imaginons les classes $[0\,;10[$ avec 20 individus et $[10\,;12[$ avec 12 individus.

En hauteur brute, la première paraît presque deux fois plus importante. Mais les densités valent $\dfrac{20}{10} = 2$ et $\dfrac{12}{2} = 6$. La deuxième classe est en réalité trois fois plus dense.

## Exercice d''application

Dans une coopérative de Dschang, on a relevé la masse en kilos des sacs de pommes de terre : 8 sacs entre 20 et 30 kilos, 15 sacs entre 30 et 40, 22 sacs entre 40 et 50, et 5 sacs entre 50 et 60.

Calcule l''effectif total, les fréquences et les effectifs cumulés croissants.

Correction. L''effectif total vaut $8 + 15 + 22 + 5 = 50$.

Les fréquences sont $\dfrac{8}{50} = 16\,\%$, $\dfrac{15}{50} = 30\,\%$, $\dfrac{22}{50} = 44\,\%$ et $\dfrac{5}{50} = 10\,\%$. Leur somme vaut bien 100 %.

Les effectifs cumulés croissants sont 8, 23, 45 et 50.', NULL, 15),
    (v_chapitre_id, 'Paramètres de position et de dispersion', 2, 'texte', 'Deux séries peuvent avoir la même moyenne et ne rien avoir à voir. C''est pourquoi il faut aussi mesurer l''étalement.

## La moyenne

Pour une série en classes, on utilise les centres de classes $c_{i}$ :
$$\overline{x} = \dfrac{1}{N}\sum n_{i} c_{i}$$

C''est une valeur approchée, puisqu''on suppose que tous les individus d''une classe sont au centre. C''est une bonne approximation quand les classes sont étroites.

## La classe modale

C''est la classe qui a le plus grand effectif, à amplitude égale. Si les amplitudes diffèrent, c''est celle de plus grande densité.

## La médiane

La médiane partage l''effectif en deux parties égales. La moitié des individus sont en dessous, la moitié au-dessus.

Pour la trouver, on utilise l''interpolation linéaire dans la classe qui contient le rang $\dfrac{N}{2}$.

Si la classe médiane est $[a\,;b[$, qu''elle contient $n$ individus, et que l''effectif cumulé avant elle vaut $E$ :
$$\text{Me} = a + \dfrac{\frac{N}{2} - E}{n} \times (b - a)$$

## Un calcul complet de médiane

Reprenons les notes : effectifs 4, 9, 14, 8, 5 sur les classes de largeur 4, avec $N = 40$.

La moitié de l''effectif vaut 20. Les effectifs cumulés sont 4, 13, 27, 35, 40. Le rang 20 tombe dans la troisième classe, $[8\,;12[$.

Avant cette classe, l''effectif cumulé vaut 13. La classe contient 14 individus.
$$\text{Me} = 8 + \dfrac{20 - 13}{14} \times 4 = 8 + \dfrac{7}{14} \times 4 = 8 + 2 = 10$$

La médiane vaut 10 sur 20.

## Les quartiles

$Q_{1}$ est la valeur qui laisse un quart de l''effectif en dessous, $Q_{3}$ les trois quarts. On les calcule par la même interpolation, avec $\dfrac{N}{4}$ et $\dfrac{3N}{4}$.

L''écart interquartile $Q_{3} - Q_{1}$ mesure l''étalement de la moitié centrale des données. Il ne se laisse pas influencer par les valeurs extrêmes.

## Variance et écart-type

$$V = \dfrac{1}{N}\sum n_{i}(c_{i} - \overline{x})^{2} \qquad \sigma = \sqrt{V}$$

Il existe une formule plus rapide à calculer :
$$V = \dfrac{1}{N}\sum n_{i}c_{i}^{2} - \overline{x}^{2}$$

L''écart-type $\sigma$ s''exprime dans la même unité que les données, ce qui le rend plus parlant que la variance.

Un petit écart-type signifie que les valeurs sont serrées autour de la moyenne. Un grand écart-type signifie qu''elles sont dispersées.

## Exercice d''application

Avec les notes précédentes, calcule la moyenne et l''écart-type.

Correction. Les centres de classes sont 2, 6, 10, 14 et 18.

$$\overline{x} = \dfrac{4 \times 2 + 9 \times 6 + 14 \times 10 + 8 \times 14 + 5 \times 18}{40}$$

Le numérateur vaut $8 + 54 + 140 + 112 + 90 = 404$, donc $\overline{x} = 10{,}1$.

Pour la variance, la somme des $n_{i}c_{i}^{2}$ vaut $4 \times 4 + 9 \times 36 + 14 \times 100 + 8 \times 196 + 5 \times 324 = 16 + 324 + 1\,400 + 1\,568 + 1\,620 = 4\,928$.

Donc $V = \dfrac{4\,928}{40} - 10{,}1^{2} = 123{,}2 - 102{,}01 = 21{,}19$.

Et $\sigma = \sqrt{21{,}19} \approx 4{,}6$.

La moyenne de la classe est de 10,1 sur 20, avec un écart-type de 4,6 points.', NULL, 15),
    (v_chapitre_id, 'Construis ta propre série statistique', 3, 'interactif', '{
  "widget": "stats-classes",
  "consigne": "Règle les effectifs de chaque classe. Fais monter une seule classe très haut : que deviennent la moyenne, la médiane et l''écart-type ? Essaie ensuite une répartition très étalée et compare les écarts-types."
}', NULL, 10),
    (v_chapitre_id, 'Histogramme et courbes cumulatives', 4, 'texte', 'Les graphiques ne servent pas à décorer. Ils permettent de lire des informations qu''un tableau cache.

## Construire un histogramme

En abscisse tu portes les classes, bout à bout, sans espace entre les rectangles. C''est ce qui distingue un histogramme d''un diagramme en barres.

En ordonnée tu portes l''effectif si les amplitudes sont égales, la densité sinon.

Le polygone des effectifs relie les milieux des sommets des rectangles. Il donne l''allure générale de la distribution.

## Les courbes cumulatives

La courbe des effectifs cumulés croissants part de 0 à la borne inférieure de la première classe, et monte jusqu''à $N$ à la borne supérieure de la dernière.

Entre deux bornes, on relie par un segment de droite. C''est exactement l''hypothèse d''interpolation linéaire qu''on utilise pour la médiane.

La courbe des effectifs cumulés décroissants fait l''inverse : elle part de $N$ et descend vers 0.

## Lire la médiane sur le graphique

Place la hauteur $\dfrac{N}{2}$ sur l''axe des ordonnées. Trace une horizontale jusqu''à la courbe croissante, puis descends verticalement. L''abscisse lue est la médiane.

C''est la même chose que le calcul par interpolation, mais en image. Le point d''intersection des deux courbes cumulatives donne aussi la médiane.

## Lire les quartiles

Même principe, aux hauteurs $\dfrac{N}{4}$ et $\dfrac{3N}{4}$.

## Ce qu''on voit sur la forme

Une distribution symétrique a une moyenne proche de la médiane.

Si quelques valeurs très grandes tirent la série vers la droite, la moyenne devient plus grande que la médiane. C''est le cas des salaires : quelques très hauts revenus tirent la moyenne vers le haut, alors que la médiane reste proche de ce que gagne la majorité.

C''est pour cette raison que la médiane est souvent plus honnête que la moyenne pour décrire un revenu.

## Exercice d''application

On relève les dépenses mensuelles en milliers de FCFA de 60 ménages : 12 ménages dans $[0\,;25[$, 20 dans $[25\,;50[$, 18 dans $[50\,;75[$ et 10 dans $[75\,;100[$. Détermine graphiquement la médiane, puis vérifie par le calcul.

Correction. La moitié de l''effectif vaut 30. Les effectifs cumulés croissants sont 12, 32, 50 et 60.

Le rang 30 tombe dans la classe $[25\,;50[$, qui contient 20 ménages, et avant laquelle l''effectif cumulé vaut 12.

$$\text{Me} = 25 + \dfrac{30 - 12}{20} \times 25 = 25 + \dfrac{18}{20} \times 25 = 25 + 22{,}5 = 47{,}5$$

La médiane vaut 47 500 FCFA. Sur le graphique, l''horizontale de hauteur 30 coupe la courbe croissante juste avant 50, ce qui est cohérent.', NULL, 15),
    (v_chapitre_id, 'Quiz du chapitre 10', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Dans un histogramme, ce qui représente l''effectif d''une classe, c''est :",
      "choix": [
        "l''aire du rectangle",
        "la hauteur du rectangle",
        "la largeur du rectangle",
        "le périmètre du rectangle"
      ],
      "bonne": 0,
      "explication": "C''est l''aire. Quand toutes les classes ont la même amplitude, hauteur et effectif sont proportionnels, mais sinon il faut passer par la densité."
    },
    {
      "question": "La moyenne d''une série en classes se calcule avec :",
      "choix": [
        "les centres de classes",
        "les bornes inférieures",
        "les bornes supérieures",
        "les amplitudes"
      ],
      "bonne": 0,
      "explication": "On suppose que les individus d''une classe se trouvent tous au centre de celle-ci. Cela donne une valeur approchée de la vraie moyenne."
    },
    {
      "question": "La médiane d''une série de 40 valeurs se lit sur la courbe des effectifs cumulés croissants à la hauteur :",
      "choix": [
        "20",
        "40",
        "10",
        "80"
      ],
      "bonne": 0,
      "explication": "La médiane partage l''effectif en deux parts égales, donc on se place à la hauteur N/2 = 20."
    },
    {
      "question": "Un écart-type petit signifie que :",
      "choix": [
        "les valeurs sont serrées autour de la moyenne",
        "la moyenne est petite",
        "il y a peu de données",
        "la médiane est petite"
      ],
      "bonne": 0,
      "explication": "L''écart-type mesure la dispersion. Plus il est petit, plus les valeurs sont regroupées autour de la moyenne."
    },
    {
      "question": "Deux classes [0 ; 10[ avec 20 individus et [10 ; 12[ avec 12 individus. Laquelle est la plus dense ?",
      "choix": [
        "la seconde, avec une densité de 6 contre 2",
        "la première, avec 20 individus",
        "les deux sont équivalentes",
        "on ne peut pas savoir"
      ],
      "bonne": 0,
      "explication": "La densité vaut effectif divisé par amplitude : 20/10 = 2 pour la première, 12/2 = 6 pour la seconde."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 10, Séries statistiques regroupées en classes : 5 lecons ajoutees.';
END $p1c$;
