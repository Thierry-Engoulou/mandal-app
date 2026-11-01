-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 11, Dénombrement
-- Module 22 : Organisation et gestion des données
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
  WHERE programme_id = v_programme_id AND ordre = 11;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Dénombrement', 11, 'Module 22 : Organisation et gestion des données')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 11 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 11 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Compter sans énumérer', 1, 'texte', 'Le dénombrement, c''est l''art de compter des objets sans les écrire tous. Quand il y a 3 possibilités, tu peux lister. Quand il y en a 3 millions, il faut une méthode.

## Cardinal d''un ensemble

Le cardinal de $A$, noté $\text{card}(A)$, est le nombre d''éléments de $A$.

Pour la réunion de deux ensembles :
$$\text{card}(A \cup B) = \text{card}(A) + \text{card}(B) - \text{card}(A \cap B)$$

On retire l''intersection parce qu''elle a été comptée deux fois.

Si $A$ et $B$ sont disjoints, l''intersection est vide et la formule devient une simple addition.

## Un exemple

Dans une classe de 1ère C de 45 élèves, 28 font du football, 19 font du basket et 9 font les deux. Combien ne font aucun des deux ?

Ceux qui font au moins un sport sont $28 + 19 - 9 = 38$.

Il reste donc $45 - 38 = 7$ élèves qui ne font ni l''un ni l''autre.

## Le produit cartésien

$A \times B$ est l''ensemble des couples $(a\,;b)$ avec $a$ dans $A$ et $b$ dans $B$.
$$\text{card}(A \times B) = \text{card}(A) \times \text{card}(B)$$

## Les deux grands principes

Le principe additif : si une situation se présente sous plusieurs cas qui s''excluent, tu additionnes les possibilités de chaque cas. Le mot clé est « ou ».

Le principe multiplicatif : si un choix se fait en plusieurs étapes successives, tu multiplies les possibilités de chaque étape. Le mot clé est « et », ou « puis ».

## Un exemple de chaque

Un restaurant de Kribi propose 4 entrées, 6 plats et 3 desserts. Combien de menus complets ?

C''est une entrée puis un plat puis un dessert, donc $4 \times 6 \times 3 = 72$ menus.

Maintenant, combien de façons de commander un seul article, entrée ou plat ou dessert ?

C''est l''un ou l''autre, donc $4 + 6 + 3 = 13$ façons.

La même situation donne 72 ou 13 selon la question. Lis l''énoncé très attentivement.

## Les plaques d''immatriculation

Une plaque camerounaise comporte deux lettres puis quatre chiffres. Combien de plaques possibles, si les répétitions sont permises ?

Deux lettres parmi 26, soit $26^{2}$, puis quatre chiffres parmi 10, soit $10^{4}$.

Au total $676 \times 10\,000 = 6\,760\,000$ plaques.

## Exercice d''application

Dans un lycée de Maroua, 120 élèves passent le baccalauréat. 70 ont choisi les mathématiques en spécialité, 55 la physique, et 30 les deux. Combien n''ont choisi ni l''une ni l''autre ?

Correction. Ceux qui ont au moins une des deux sont $70 + 55 - 30 = 95$.

Il reste $120 - 95 = 25$ élèves.', NULL, 15),
    (v_chapitre_id, 'L''arbre de choix, à manipuler', 2, 'interactif', '{
  "widget": "denombrement-arbre",
  "consigne": "Commence avec $n = 3$ et $p = 2$ en p-uplets, et compte les feuilles de l''arbre. Passe ensuite en arrangements : combien de branches disparaissent, et pourquoi ? Termine en combinaisons et regarde de combien le nombre est divisé."
}', NULL, 10),
    (v_chapitre_id, 'p-uplets, arrangements et permutations', 3, 'texte', 'Trois mots, trois situations. Pour choisir le bon, pose-toi deux questions : l''ordre compte-t-il, et peut-on répéter ?

## Les p-uplets, ou p-listes

Tu choisis $p$ objets parmi $n$, l''ordre compte, et les répétitions sont permises.
$$n^{p}$$

C''est le cas d''un code à 4 chiffres : $10^{4} = 10\,000$ codes. Le code 1123 est permis, et il est différent de 3211.

## Les arrangements

Tu choisis $p$ objets parmi $n$, l''ordre compte, mais sans répétition.
$$A_{n}^{p} = n \times (n-1) \times \dots \times (n - p + 1) = \dfrac{n!}{(n-p)!}$$

C''est le cas d''un podium : 3 places à attribuer parmi 8 coureurs.
$$A_{8}^{3} = 8 \times 7 \times 6 = 336$$

Le premier a 8 possibilités, le deuxième 7 puisque le premier est pris, le troisième 6.

## Les permutations

C''est un arrangement où l''on prend tous les objets, donc $p = n$.
$$n! = n \times (n-1) \times \dots \times 2 \times 1$$

De combien de façons peut-on ranger 5 livres sur une étagère ? $5! = 120$.

Par convention, $0! = 1$.

## Les factorielles grandissent très vite

$5! = 120$, $10! = 3\,628\,800$, et $20!$ dépasse déjà deux milliards de milliards. C''est pour cela qu''on ne peut pas énumérer.

## Comment choisir entre les trois

Si les objets peuvent se répéter et que l''ordre compte, ce sont des p-uplets.

Si les objets ne se répètent pas et que l''ordre compte, ce sont des arrangements.

Si tu prends tout, ce sont des permutations.

Si l''ordre ne compte pas, ce sont des combinaisons, que tu verras dans la leçon suivante.

## Exercice d''application

Un comité de classe doit élire un président, un trésorier et un secrétaire parmi 12 élèves. Une même personne ne peut pas cumuler deux postes. Combien de comités possibles ?

Correction. Les trois postes sont différents, donc l''ordre compte, et il n''y a pas de répétition.

C''est un arrangement : $A_{12}^{3} = 12 \times 11 \times 10 = 1\,320$ comités.', NULL, 15),
    (v_chapitre_id, 'Combinaisons, triangle de Pascal et binôme', 4, 'texte', 'Quand l''ordre ne compte pas, on parle de combinaison. C''est le cas le plus fréquent dans les problèmes réels.

## La définition

Une combinaison de $p$ objets parmi $n$, c''est un sous-ensemble de $p$ éléments. L''ordre n''intervient pas.
$$C_{n}^{p} = \dfrac{n!}{p!\,(n-p)!} = \dfrac{A_{n}^{p}}{p!}$$

On divise l''arrangement par $p!$, parce que les $p!$ façons d''ordonner un même sous-ensemble donnent toutes le même ensemble.

## Un exemple

Dans une classe de 30 élèves, on choisit une délégation de 3 élèves, sans distinction de rôle. Combien de délégations ?
$$C_{30}^{3} = \dfrac{30 \times 29 \times 28}{3 \times 2 \times 1} = \dfrac{24\,360}{6} = 4\,060$$

Si les trois postes avaient été différents, il y aurait eu $A_{30}^{3} = 24\,360$ possibilités, soit six fois plus.

## Les propriétés utiles

$$C_{n}^{0} = C_{n}^{n} = 1 \qquad C_{n}^{1} = n$$
$$C_{n}^{p} = C_{n}^{\,n-p}$$

Cette dernière se comprend bien : choisir 3 élèves parmi 30, c''est la même chose que choisir les 27 qui restent.

La relation de Pascal :
$$C_{n}^{p} = C_{n-1}^{\,p-1} + C_{n-1}^{p}$$

Elle se démontre en regardant un élément particulier : soit il est dans le sous-ensemble, soit il n''y est pas.

## Le triangle de Pascal

Chaque nombre est la somme des deux situés juste au-dessus de lui.

Ligne 0 : 1

Ligne 1 : 1, 1

Ligne 2 : 1, 2, 1

Ligne 3 : 1, 3, 3, 1

Ligne 4 : 1, 4, 6, 4, 1

Ligne 5 : 1, 5, 10, 10, 5, 1

Ligne 6 : 1, 6, 15, 20, 15, 6, 1

La ligne $n$ donne tous les $C_{n}^{p}$ pour $p$ allant de 0 à $n$.

## La formule du binôme de Newton

$$(a + b)^{n} = \sum_{p=0}^{n} C_{n}^{p}\, a^{\,n-p} b^{\,p}$$

Les coefficients sont exactement la ligne $n$ du triangle.

Par exemple
$$(a+b)^{4} = a^{4} + 4a^{3}b + 6a^{2}b^{2} + 4ab^{3} + b^{4}$$

Et avec $a = x$, $b = -2$ :
$$(x - 2)^{3} = x^{3} - 6x^{2} + 12x - 8$$

parce que la ligne 3 est 1, 3, 3, 1 et que les puissances de $-2$ sont $1$, $-2$, $4$, $-8$.

## Une conséquence élégante

Fais $a = b = 1$ dans la formule du binôme :
$$2^{n} = C_{n}^{0} + C_{n}^{1} + \dots + C_{n}^{n}$$

Autrement dit, un ensemble à $n$ éléments possède exactement $2^{n}$ sous-ensembles. Chaque élément est dedans ou dehors, ce qui fait bien 2 choix répétés $n$ fois.

## Exercice d''application

Un sac contient 7 billes rouges et 5 billes bleues. On en tire 4 au hasard, simultanément. Combien de tirages contiennent exactement 2 rouges ?

Correction. Tirer simultanément veut dire que l''ordre ne compte pas.

Il faut 2 rouges parmi 7, soit $C_{7}^{2} = \dfrac{7 \times 6}{2} = 21$ façons.

Et 2 bleues parmi 5, soit $C_{5}^{2} = \dfrac{5 \times 4}{2} = 10$ façons.

Comme il faut les deux en même temps, on multiplie : $21 \times 10 = 210$ tirages.', NULL, 15),
    (v_chapitre_id, 'Quiz du chapitre 11', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Un code à 4 chiffres, répétitions autorisées, offre :",
      "choix": [
        "10⁴ possibilités",
        "A(4, 10) possibilités",
        "C(4, 10) possibilités",
        "4! possibilités"
      ],
      "bonne": 0,
      "explication": "L''ordre compte et les chiffres peuvent se répéter : c''est une 4-liste, donc 10⁴ = 10 000."
    },
    {
      "question": "Choisir 3 élèves parmi 30 pour une délégation sans rôle précis, c''est :",
      "choix": [
        "une combinaison, C(3, 30) = 4 060",
        "un arrangement, 24 360",
        "une permutation",
        "une 3-liste"
      ],
      "bonne": 0,
      "explication": "L''ordre ne compte pas puisque les trois ont le même rôle. On divise l''arrangement par 3! = 6."
    },
    {
      "question": "C(p, n) est égal à :",
      "choix": [
        "C(n − p, n)",
        "C(n, p)",
        "A(p, n)",
        "n!/p!"
      ],
      "bonne": 0,
      "explication": "Choisir p éléments revient à choisir les n − p qu''on laisse de côté. Les deux nombres sont donc égaux."
    },
    {
      "question": "Dans une classe de 45 élèves, 28 font du football, 19 du basket, 9 les deux. Combien n''en font aucun ?",
      "choix": [
        "7",
        "2",
        "16",
        "38"
      ],
      "bonne": 0,
      "explication": "Ceux qui font au moins un sport sont 28 + 19 − 9 = 38, il en reste donc 45 − 38 = 7."
    },
    {
      "question": "Le nombre de sous-ensembles d''un ensemble à n éléments vaut :",
      "choix": [
        "2ⁿ",
        "n!",
        "n²",
        "2n"
      ],
      "bonne": 0,
      "explication": "Chaque élément est pris ou laissé, ce qui fait deux choix répétés n fois. C''est aussi la somme de la ligne n du triangle de Pascal."
    },
    {
      "question": "Le développement de (a + b)⁴ a pour coefficients :",
      "choix": [
        "1, 4, 6, 4, 1",
        "1, 4, 4, 1",
        "1, 2, 3, 4",
        "4, 4, 4, 4"
      ],
      "bonne": 0,
      "explication": "Ce sont les nombres de la ligne 4 du triangle de Pascal."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 11, Dénombrement : 5 lecons ajoutees.';
END $p1c$;
