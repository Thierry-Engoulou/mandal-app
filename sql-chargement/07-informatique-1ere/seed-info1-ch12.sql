-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 12 : Les fonctions et les procédures
-- Module 2 : Algorithmique et programmation — 8 leçons
--
-- Ce fichier remplit les trois séries d'un coup : la 1ère A, la 1ère C et la
-- 1ère D. Il n'a besoin de rien d'autre pour tourner. Si la matière, les
-- classes, les programmes ou le chapitre n'existent pas encore, il les crée
-- lui-même au passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $inf1$
DECLARE
  v_lettres text[] := ARRAY['A', 'C', 'D'];
  v_i int;
  v_nom text;
  v_lettre text;
  v_matiere_id uuid;
  v_classe_id uuid;
  v_etab_id uuid;
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_nb_etabs int;
  v_deja int;
BEGIN
  -- La matière Chimie : on ne la crée qu'une fois pour toutes.
  INSERT INTO public.matieres (nom) VALUES ('Informatique') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Informatique';

  -- L'établissement, on le retrouve à partir des classes déjà en base.
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Je ne sais pas à quel établissement rattacher ces classes : j''en trouve % dans la table des classes, et il m''en faudrait exactement un.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- On refait le même travail trois fois : pour la 1ère C, puis la D, puis la E.
  FOR v_i IN 1..3 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := '1ère ' || v_lettre;

    -- Le programme de Chimie de cette série existe-t-il déjà ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Informatique — ' || v_nom;

    -- Non : on le crée, et la classe avec si besoin.
    IF v_programme_id IS NULL THEN
      -- La classe a pu être écrite de plusieurs façons : 1ère A, 1ere A, Première A.
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE '1%re ' || v_lettre OR nom ILIKE 'Premi%re ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Première', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'La classe % n''existait pas : je viens de la créer.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Informatique — ' || v_nom,
              'Programme officiel d''Informatique, classe de Première ' || v_lettre ||
              ' (Cameroun) — 3 modules, 20 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme d''Informatique de la % : créé.', v_nom;
    END IF;

    -- Le chapitre lui-même.
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 12;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les fonctions et les procédures', 12, 'Module 2 : Algorithmique et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 12 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 12 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Pourquoi découper un algorithme', 1, 'texte', '
Un algorithme de deux cents lignes est illisible, impossible à corriger et
impossible à réutiliser. On le **découpe** en morceaux qui ont chacun un nom et
un travail.

Ces morceaux s''appellent des **sous-programmes**, et il y en a deux sortes : les
**procédures** et les **fonctions**.

### Les trois bénéfices

**La lisibilité.** `afficherBulletin(eleve)` se comprend sans qu''on lise les
quarante lignes qui le composent.

**La réutilisation.** Écrit une fois, appelé partout. Si le calcul de la TVA
apparaît à six endroits, on l''écrit une fois.

**La correction.** Une erreur dans la TVA se corrige **à un seul endroit**, et
les six appels en profitent.

### La différence entre les deux

C''est la question d''examen la plus prévisible de ce chapitre.

Une **procédure exécute une action** et ne renvoie rien. Afficher un bulletin,
dessiner une ligne, trier un tableau.

Une **fonction calcule et renvoie une valeur**, au moyen de l''instruction
`retourner`. Calculer une TVA, chercher un maximum, tester si un nombre est
premier.

Le repère pratique : si le résultat se **récupère dans une variable**, c''est une
fonction. Si on l''appelle juste pour qu''il **fasse quelque chose**, c''est une
procédure.

```
afficherTitre()              -- procédure : elle agit
p ← prixTTC(7500, 5)         -- fonction : elle renvoie, on récupère
```

### Les paramètres

Les **paramètres** sont les informations qu''on **donne** au sous-programme au
moment de l''appeler.

Dans `prixTTC(7500, 5)`, les valeurs 7500 et 5 sont les paramètres. À
l''intérieur, ils porteront les noms annoncés dans la déclaration.

---

**Exercice corrigé**

*Donner la différence entre une procédure et une fonction, et illustrer par un
exemple de chaque.*

**Correction.** Une **procédure** est un sous-programme qui **exécute une
action** sans renvoyer de valeur. Une **fonction** est un sous-programme qui
**calcule et renvoie une valeur** à l''aide de l''instruction `retourner`.

Exemple de procédure :

```
Procédure afficherLigne()
Début
    écrire("------------------------")
FinProcédure
```

On l''appelle par `afficherLigne()`. Elle agit, elle ne rend rien.

Exemple de fonction :

```
Fonction carre(x : réel) : réel
Début
    retourner x * x
FinFonction
```

On l''appelle par `y ← carre(4)`, et `y` vaut 16. Remarque le **type de retour**
après les deux points dans l''en-tête : une fonction l''annonce toujours, une
procédure jamais. C''est à cela qu''on les reconnaît sur une copie.
', NULL, 25),
      (v_chapitre_id, 'Simulation : procédure ou fonction ?', 2, 'interactif', '{
  "widget": "fonction-procedure",
  "consigne": "Dix sous-programmes te sont décrits par leur travail — afficher un bulletin, calculer une moyenne, trier un tableau, tester si un nombre est pair — et tu dois dire pour chacun s''il s''agit d''une procédure ou d''une fonction. La simulation te renvoie à chaque fois la question qui tranche : le résultat se récupère-t-il dans une variable ? Puis elle écrit la déclaration correcte."
}', NULL, 10),
      (v_chapitre_id, 'Les procédures et leurs paramètres', 3, 'texte', '
### La déclaration

```
Procédure nom(paramètres)
Début
    instructions
FinProcédure
```

```
Procédure afficherEleve(nom : chaîne ; moy : réel)
Début
    écrire("Élève : ", nom)
    écrire("Moyenne : ", moy)
    Si moy >= 10 alors
        écrire("Admis")
    Sinon
        écrire("Ajourné")
    Finsi
FinProcédure
```

L''appel :

```
afficherEleve("Thierry", 13.5)
```

### Les paramètres formels et effectifs

Deux mots de vocabulaire à connaître, car ils sont souvent demandés.

Les **paramètres formels** sont ceux de la **déclaration** : `nom` et `moy`
ci-dessus. Ce sont des noms, pas des valeurs.

Les **paramètres effectifs** sont ceux de l''**appel** : `"Thierry"` et `13.5`.
Ce sont de vraies valeurs.

À l''appel, les effectifs viennent **remplacer** les formels, dans l''ordre et
avec les bons types. Appeler `afficherEleve(13.5, "Thierry")` serait faux :
l''ordre compte.

### Les variables locales

Une variable déclarée **à l''intérieur** d''un sous-programme n''existe que **le
temps de son exécution**. On dit qu''elle est **locale**. Le programme principal
ne la voit pas et ne peut pas s''en servir.

```
Procédure afficherTable(n : entier)
Variable
    i : entier ;
Début
    Pour i de 1 à 10 faire
        écrire(n, " x ", i, " = ", n * i)
    FinPour
FinProcédure
```

Ici `i` est locale. C''est une bonne chose : un autre `i` dans le programme
principal n''entre pas en conflit avec celui-ci.

---

**Exercice corrigé**

*Écrire une procédure qui affiche la table de multiplication d''un entier donné,
puis un algorithme principal qui affiche les tables de 1 à 5.*

**Correction.**

```
Procédure afficherTable(n : entier)
Variable
    i : entier ;
Début
    écrire("--- Table de ", n, " ---")
    Pour i de 1 à 10 faire
        écrire(n, " x ", i, " = ", n * i)
    FinPour
FinProcédure


Algorithme : Tables

Variable
    k : entier ;

Début
    Pour k de 1 à 5 faire
        afficherTable(k)
    FinPour
Fin
```

Observe le programme principal : **trois lignes utiles**. Tout le travail est
dans la procédure, et on l''appelle cinq fois.

C''est exactement le bénéfice annoncé en début de chapitre. Sans la procédure, il
aurait fallu imbriquer deux boucles dans le programme principal — ce qui est
possible, mais nettement moins lisible, et surtout non réutilisable ailleurs.
', NULL, 25),
      (v_chapitre_id, 'Simulation : passer des paramètres', 4, 'interactif', '{
  "widget": "procedure-parametres",
  "consigne": "Appelle une procédure en remplissant toi-même ses paramètres effectifs, et regarde les valeurs se ranger dans les paramètres formels avant l''exécution. Inverse l''ordre des arguments ou donne-leur le mauvais type : la simulation refuse l''appel et t''explique lequel ne correspond pas. Une fenêtre montre aussi la variable locale naître à l''entrée et disparaître à la sortie."
}', NULL, 10),
      (v_chapitre_id, 'Les fonctions et la récursivité', 5, 'texte', '
### La déclaration d''une fonction

```
Fonction nom(paramètres) : type_de_retour
Début
    instructions
    retourner valeur
FinFonction
```

Deux éléments distinguent une fonction d''une procédure : le **type de retour**
dans l''en-tête, et l''instruction **`retourner`** dans le corps.

```
Fonction prixTTC(pu : réel ; q : entier) : réel
Variable
    ht : réel ;
Début
    ht ← pu * q
    retourner ht * 1.07
FinFonction
```

L''appel se place **là où on attendrait une valeur** :

```
p ← prixTTC(7500, 5)
écrire("À payer : ", prixTTC(7500, 5), " FCFA")
Si prixTTC(pu, q) > 50000 alors …
```

`retourner` **sort immédiatement** de la fonction. Tout ce qui suit dans le même
bloc ne sera pas exécuté — ce qui est parfois bien pratique :

```
Fonction estPair(n : entier) : booléen
Début
    Si n mod 2 = 0 alors
        retourner vrai
    Finsi
    retourner faux
FinFonction
```

### La récursivité

Une fonction est **récursive** quand elle **s''appelle elle-même**.

L''exemple canonique est la factorielle. Par définition,
$n! = n \times (n-1)!$, et $0! = 1$.

```
Fonction factorielle(n : entier) : entier
Début
    Si n = 0 alors
        retourner 1
    Sinon
        retourner n * factorielle(n - 1)
    Finsi
FinFonction
```

Déroulons `factorielle(4)` :

```
factorielle(4) = 4 * factorielle(3)
               = 4 * 3 * factorielle(2)
               = 4 * 3 * 2 * factorielle(1)
               = 4 * 3 * 2 * 1 * factorielle(0)
               = 4 * 3 * 2 * 1 * 1
               = 24
```

### Les deux parties obligatoires

Toute fonction récursive en a exactement deux, et l''oubli de la première est
l''erreur classique.

**Le cas de base** : le cas qu''on sait résoudre **sans** se rappeler. Ici
`n = 0` qui renvoie 1. Il arrête la descente.

**Le cas récursif** : l''appel à soi-même, sur un problème **plus petit**. Ici
`factorielle(n - 1)`.

Sans cas de base, la fonction s''appelle indéfiniment : c''est l''équivalent de la
boucle infinie, et la machine s''arrête en saturant sa mémoire. Et l''appel
récursif doit **vraiment** réduire le problème : `factorielle(n)` appelant
`factorielle(n)` ne descend jamais.

---

**Exercice corrigé**

*Écrire une fonction récursive qui calcule la somme des entiers de 1 à n.*

**Correction.** Le raisonnement d''abord : la somme de 1 à `n` vaut `n` plus la
somme de 1 à `n-1`. Et la somme de 1 à 0 vaut 0 : c''est le cas de base.

```
Fonction somme(n : entier) : entier
Début
    Si n = 0 alors
        retourner 0
    Sinon
        retourner n + somme(n - 1)
    Finsi
FinFonction
```

Vérification sur `somme(4)` :

```
somme(4) = 4 + somme(3)
         = 4 + 3 + somme(2)
         = 4 + 3 + 2 + somme(1)
         = 4 + 3 + 2 + 1 + somme(0)
         = 4 + 3 + 2 + 1 + 0 = 10
```

La formule directe donne $\dfrac{4 \times 5}{2} = 10$. Les deux concordent.

En examen, vérifie **toujours** ta récursivité sur une petite valeur, 3 ou 4. Si
la descente n''atteint pas le cas de base, l''erreur se voit immédiatement.
', NULL, 28),
      (v_chapitre_id, 'Simulation : la récursivité en action', 6, 'interactif', '{
  "widget": "recursivite",
  "consigne": "Appelle la factorielle sur un petit nombre et regarde la pile des appels se construire vers le bas, puis les résultats remonter un par un jusqu''à la réponse. Supprime le cas de base et la simulation montre la pile grandir sans fin, jusqu''à la saturation — c''est l''équivalent exact de la boucle infinie. La somme de 1 à n et la suite de Fibonacci sont proposées en plus."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Probatoire — algorithmique (session 2017)', 7, 'texte', '
Voici la première partie du Probatoire d''informatique, session 2017,
entièrement corrigée. Elle vaut **7 points** sur 20, le plus gros morceau de
l''épreuve.

---

**Énoncé**

*Un commerçant vend des articles au prix unitaire hors taxe de 7 500 FCFA. Le
taux de la taxe sur la valeur ajoutée est de 7 %.*

*1. Quelles sont les données d''entrée du problème ?*

*2. Quelles sont les données de sortie ?*

*3. Écrire un algorithme qui lit le prix unitaire hors taxe et la quantité
achetée, calcule le prix hors taxe puis le prix toutes taxes comprises, et les
affiche.*

*4. Dérouler cet algorithme pour l''achat de 5 articles.*

*5. Quel est le type de la variable contenant la quantité ? Justifier.*

---

**Correction détaillée**

**1. Les données d''entrée** sont le **prix unitaire hors taxe** et la
**quantité** achetée.

*Attention à ne pas y mettre le taux de TVA.* Il vaut 7 % et ne change pas : ce
n''est pas une donnée d''entrée, c''est une **constante**. Confondre les deux coûte
un point à chaque fois.

**2. Les données de sortie** sont le **prix hors taxe** et le **prix toutes
taxes comprises**.

**3. L''algorithme.**

```
Algorithme : PrixTTC

Constante
    tva = 0.07 ;

Variable
    pu, pht, pttc : réel ;
    q : entier ;

Début
    écrire("Entrez le prix unitaire hors taxe :")
    lire(pu)
    écrire("Entrez la quantité :")
    lire(q)
    pht ← pu * q
    pttc ← pht * (1 + tva)
    écrire("Prix hors taxe : ", pht, " FCFA")
    écrire("Prix toutes taxes comprises : ", pttc, " FCFA")
Fin
```

**4. Le déroulement pour 5 articles.**

| Instruction | `pu` | `q` | `pht` | `pttc` |
| --- | --- | --- | --- | --- |
| `lire(pu)` | 7500 | — | — | — |
| `lire(q)` | 7500 | 5 | — | — |
| `pht ← pu * q` | 7500 | 5 | 37500 | — |
| `pttc ← pht * 1.07` | 7500 | 5 | 37500 | 40125 |

Les calculs posés :

$$p_{ht} = 7\,500 \times 5 = 37\,500 \text{ FCFA}$$

$$p_{ttc} = 37\,500 \times 1{,}07 = 40\,125 \text{ FCFA}$$

L''algorithme affiche donc **37 500 FCFA** hors taxe et **40 125 FCFA** toutes
taxes comprises.

*On peut vérifier autrement : la TVA seule vaut $37\,500 \times 0{,}07 =
2\,625$ FCFA, et $37\,500 + 2\,625 = 40\,125$. Les deux chemins concordent.*

**5. Le type de la quantité** est **entier**.

*Justification.* On n''achète pas 2,5 articles : une quantité d''articles est un
nombre entier d''unités. Les prix, eux, sont déclarés **réels**, car un montant
comporte des décimales — et parce que la multiplication par 1,07 produit des
décimales même si l''on part d''un nombre rond.

---

**Ce que ce sujet t''apprend sur l''épreuve**

Note l''enchaînement des questions : d''abord l''**analyse** (entrées, sorties),
ensuite l''**algorithme**, ensuite le **déroulement** sur un cas, enfin une
question de **type**.

C''est la structure habituelle de la partie algorithmique. Les points de
l''analyse et du déroulement sont les plus faciles de toute l''épreuve, et ce sont
ceux que les candidats sautent pour se jeter sur l''algorithme. Ne fais pas cela :
réponds aux questions dans l''ordre, et le déroulement te servira en plus à
vérifier ton propre algorithme.
', NULL, 32),
      (v_chapitre_id, 'Quiz du chapitre 12', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la différence entre une procédure et une fonction ?",
      "choix": [
        "Aucune",
        "La procédure exécute une action sans rien renvoyer ; la fonction calcule et renvoie une valeur avec retourner",
        "La fonction est plus courte",
        "La procédure ne prend pas de paramètres"
      ],
      "bonne": 1,
      "explication": "Le repère pratique : si le résultat se récupère dans une variable, c''est une fonction. Si on l''appelle juste pour qu''il fasse quelque chose, c''est une procédure."
    },
    {
      "question": "Comment reconnaît-on une fonction à son en-tête ?",
      "choix": [
        "Elle commence par le mot Fonction et annonce un type de retour",
        "Elle a plus de paramètres",
        "Elle n''a pas de Début",
        "Elle est déclarée après le programme principal"
      ],
      "bonne": 0,
      "explication": "Le type de retour après les deux points, plus l''instruction retourner dans le corps : ce sont les deux marques d''une fonction."
    },
    {
      "question": "Dans l''appel afficherEleve(« Thierry », 13.5), comment appelle-t-on ces deux valeurs ?",
      "choix": [
        "Des paramètres formels",
        "Des paramètres effectifs",
        "Des variables locales",
        "Des constantes"
      ],
      "bonne": 1,
      "explication": "Les effectifs sont ceux de l''APPEL, de vraies valeurs ; les formels sont ceux de la DÉCLARATION, de simples noms. L''ordre et les types doivent correspondre."
    },
    {
      "question": "Qu''est-ce qu''une variable locale ?",
      "choix": [
        "Une variable du programme principal",
        "Une variable déclarée dans un sous-programme, qui n''existe que le temps de son exécution",
        "Une constante",
        "Un paramètre effectif"
      ],
      "bonne": 1,
      "explication": "Le programme principal ne la voit pas. C''est une bonne chose : un autre i ailleurs n''entre pas en conflit avec celui-ci."
    },
    {
      "question": "Qu''est-ce qu''une fonction récursive ?",
      "choix": [
        "Une fonction très longue",
        "Une fonction qui s''appelle elle-même",
        "Une fonction sans paramètres",
        "Une fonction qui contient une boucle"
      ],
      "bonne": 1,
      "explication": "La factorielle en est l''exemple canonique : factorielle(n) renvoie n multiplié par factorielle(n-1)."
    },
    {
      "question": "Quelles sont les deux parties obligatoires d''une fonction récursive ?",
      "choix": [
        "Le Début et le Fin",
        "Le cas de base et le cas récursif",
        "Les paramètres et le type de retour",
        "L''initialisation et la progression"
      ],
      "bonne": 1,
      "explication": "Sans cas de base, la fonction s''appelle indéfiniment et sature la mémoire : c''est l''équivalent exact de la boucle infinie."
    },
    {
      "question": "Cinq articles à 7 500 FCFA hors taxe, TVA de 7 % : quel est le prix toutes taxes comprises ?",
      "choix": [
        "37 500 FCFA",
        "40 125 FCFA",
        "40 000 FCFA",
        "42 750 FCFA"
      ],
      "bonne": 1,
      "explication": "Le prix hors taxe vaut 7 500 × 5 = 37 500 FCFA, puis 37 500 × 1,07 = 40 125 FCFA. La TVA seule vaut 2 625 FCFA."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 12, Les fonctions et les procédures.', v_nom;
  END LOOP;
END $inf1$;
