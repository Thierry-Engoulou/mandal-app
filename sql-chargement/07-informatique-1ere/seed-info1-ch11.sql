-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 11 : Les structures répétitives
-- Module 2 : Algorithmique et programmation — 9 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 11;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les structures répétitives', 11, 'Module 2 : Algorithmique et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 11 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 11 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'TantQue… faire… FinTantQue', 1, 'texte', '
Troisième et dernière grande famille d''instructions : celles qui **répètent**.
On les appelle **structures répétitives**, ou **boucles**.

### Pourquoi

Pour additionner cinq nombres, on pourrait écrire cinq `lire` et cinq
additions. Mais pour cent nombres ? Et pour un nombre de valeurs qu''on ne
connaîtra qu''à l''exécution ?

### La forme

```
TantQue condition faire
    instructions
FinTantQue
```

La condition est **testée d''abord**, et le bloc se répète **aussi longtemps**
qu''elle est vraie.

```
i ← 1
TantQue i <= 5 faire
    écrire(i)
    i ← i + 1
FinTantQue
```

Déroulons. `i` vaut 1, la condition est vraie, on affiche 1, `i` passe à 2. On
recommence jusqu''à `i = 6` : la condition devient fausse, on sort. L''algorithme
affiche 1, 2, 3, 4, 5.

### Les trois ingrédients obligatoires

Toute boucle `TantQue` en a besoin, et en oublier un est l''erreur numéro un.

**L''initialisation** avant la boucle : `i ← 1`. Sans elle, la condition compare
une variable qui ne contient rien.

**La condition** : `i <= 5`.

**La progression** dans le bloc : `i ← i + 1`. Sans elle, `i` reste à 1, la
condition reste vraie, et la boucle **ne s''arrête jamais**. C''est la **boucle
infinie**, et sur une copie d''examen elle coûte la question entière.

Avant de rendre une boucle, pose-toi toujours cette question : **qu''est-ce qui,
dans le bloc, rapproche de la sortie ?** Si tu ne trouves pas, la boucle est
infinie.

### Le cas où le bloc ne s''exécute jamais

```
i ← 10
TantQue i <= 5 faire
    écrire(i)
    i ← i + 1
FinTantQue
```

La condition est fausse dès le départ : le bloc ne s''exécute **pas une seule
fois**. C''est normal, et c''est même l''intérêt du `TantQue` : il vérifie **avant**
d''agir.

---

**Exercice corrigé**

*Écrire un algorithme qui lit des entiers jusqu''à ce que l''utilisateur tape 0,
puis affiche leur somme et leur nombre.*

**Correction.**

```
Algorithme : SommeJusquaZero

Variable
    n, somme, nb : entier ;

Début
    somme ← 0
    nb ← 0
    écrire("Entrez un entier (0 pour terminer) :")
    lire(n)
    TantQue n <> 0 faire
        somme ← somme + n
        nb ← nb + 1
        écrire("Entrez un entier (0 pour terminer) :")
        lire(n)
    FinTantQue
    écrire("Somme : ", somme)
    écrire("Nombre de valeurs : ", nb)
Fin
```

Trois points à comprendre.

`somme ← 0` et `nb ← 0` **avant** la boucle : on ne peut pas ajouter à une
variable qui ne contient rien.

Il y a **deux** `lire(n)` : un avant la boucle, pour avoir une valeur à tester,
et un à la fin du bloc, pour préparer le tour suivant. C''est le schéma classique
de la lecture jusqu''à une valeur sentinelle, et l''oubli du second `lire` est
précisément ce qui crée la boucle infinie.

Le `0` ne doit **pas** être compté. Il n''est pas une donnée, c''est le signal
d''arrêt : comme on sort dès qu''il est lu, il n''est jamais ajouté à la somme.
C''est juste.
', NULL, 28),
      (v_chapitre_id, 'Simulation : la boucle TantQue, pas à pas', 2, 'interactif', '{
  "widget": "boucle-tantque",
  "consigne": "Choisis l''initialisation, la condition et la progression, et regarde la boucle tourner avec son compteur de tours et son tableau de trace. Supprime la ligne de progression et la simulation détecte la boucle infinie, l''arrête au bout de cent tours et te montre la variable qui n''a pas bougé. Mets une condition fausse dès le départ pour voir le bloc n''être exécuté aucune fois."
}', NULL, 10),
      (v_chapitre_id, 'Pour… faire… FinPour', 3, 'texte', '
Quand on sait **à l''avance** combien de tours il faut, le `TantQue` devient
bavard : trois lignes pour gérer le compteur. Le `Pour` fait tout cela seul.

### La forme

```
Pour i de debut à fin faire
    instructions
FinPour
```

```
Pour i de 1 à 5 faire
    écrire(i)
FinPour
```

Cinq lignes de `TantQue` tiennent en trois. Et surtout, **le compteur est géré
automatiquement** : il est initialisé à `debut`, augmenté de 1 à chaque tour, et
la boucle s''arrête après `fin`.

Une boucle `Pour` **ne peut donc pas être infinie**. C''est sa grande qualité.

### Le pas

```
Pour i de 10 à 1 pas -1 faire
    écrire(i)
FinPour
```

Affiche 10, 9, 8… jusqu''à 1. Sans `pas -1`, une boucle qui descend ne
s''exécuterait pas du tout, puisque le début est déjà au-delà de la fin.

### Ne pas toucher au compteur

À l''intérieur d''une boucle `Pour`, on **ne modifie jamais** la variable de
contrôle. Écrire `i ← i + 3` dans le bloc est une faute : c''est la boucle qui
gère `i`, pas toi. Si tu as besoin d''un compteur que tu contrôles, prends un
`TantQue`.

### Laquelle choisir

| Situation | Boucle |
| --- | --- |
| le nombre de tours est connu à l''avance | **Pour** |
| on s''arrête sur une condition | **TantQue** |
| il faut au moins un tour | **Répéter** |

« Afficher les dix premiers entiers » : dix tours, donc `Pour`. « Lire jusqu''à 0 » :
on ne sait pas combien, donc `TantQue`. « Redemander un mot de passe jusqu''à ce
qu''il soit bon » : au moins une demande, donc `Répéter`.

---

**Exercice corrigé**

*Écrire un algorithme qui calcule la moyenne de `n` notes saisies au clavier.*

**Correction.**

```
Algorithme : MoyenneNotes

Variable
    n, i : entier ;
    note, somme, moy : réel ;

Début
    écrire("Combien de notes ?")
    lire(n)
    somme ← 0
    Pour i de 1 à n faire
        écrire("Note numéro ", i, " :")
        lire(note)
        somme ← somme + note
    FinPour
    Si n > 0 alors
        moy ← somme / n
        écrire("Moyenne : ", moy)
    Sinon
        écrire("Aucune note saisie")
    Finsi
Fin
```

Le `Pour` convient ici parce que `n` est connu **avant** d''entrer dans la
boucle : l''utilisateur l''a donné.

Et surtout, remarque le `Si n > 0` avant la division. Si l''utilisateur répond
`0` à la première question, la boucle ne tourne pas, `somme` reste à 0, et
`somme / n` serait une **division par zéro** — qui arrête brutalement un vrai
programme. Se méfier du dénominateur est un réflexe à prendre : il fait la
différence entre un algorithme juste et un algorithme solide.
', NULL, 28),
      (v_chapitre_id, 'Simulation : Pour, et le choix de la boucle', 4, 'interactif', '{
  "widget": "boucle-pour",
  "consigne": "Règle le début, la fin et le pas d''une boucle Pour, et vois la liste des valeurs prises par le compteur avant même de lancer. Essaie de descendre sans mettre un pas négatif : zéro tour. Un second volet te donne huit énoncés à classer entre Pour, TantQue et Répéter, avec la question qui tranche à chaque fois — connaît-on le nombre de tours, faut-il au moins un passage ?"
}', NULL, 10),
      (v_chapitre_id, 'Répéter… Jusqu''à, et la comparaison des trois', 5, 'texte', '
### La forme

```
Répéter
    instructions
Jusqu''à condition
```

La différence avec le `TantQue` tient en deux points, et ce sont exactement les
deux que l''on demande en examen.

**La condition est testée à la fin.** Le bloc s''exécute donc **toujours au moins
une fois**.

**On sort quand la condition devient vraie** — alors que dans un `TantQue`, on
reste tant qu''elle est vraie. Les conditions des deux boucles sont donc
**opposées**.

### Le même travail, écrit des deux façons

```
i ← 1
TantQue i <= 5 faire
    écrire(i)
    i ← i + 1
FinTantQue
```

```
i ← 1
Répéter
    écrire(i)
    i ← i + 1
Jusqu''à i > 5
```

Même résultat. Et remarque bien les conditions : `i <= 5` d''un côté, `i > 5` de
l''autre. L''une est la négation de l''autre.

### Son terrain naturel : le contrôle de saisie

```
Répéter
    écrire("Entrez une note entre 0 et 20 :")
    lire(note)
Jusqu''à (note >= 0) et (note <= 20)
```

On est **obligé** de demander au moins une fois : on ne peut pas vérifier une
note qu''on n''a pas encore lue. C''est le cas d''école du `Répéter`, et c''est pour
cela qu''on l''appelle parfois la boucle de validation.

### Le tableau récapitulatif

| | Test | Nombre minimal de tours | On sort quand |
| --- | --- | --- | --- |
| **TantQue** | au début | 0 | la condition devient **fausse** |
| **Répéter** | à la fin | **1** | la condition devient **vraie** |
| **Pour** | compteur automatique | 0 | le compteur dépasse la fin |

Ces trois lignes répondent à la question « comparez les structures répétitives »,
qui tombe régulièrement.

---

**Exercice corrigé**

*Écrire un algorithme qui demande un mot de passe jusqu''à ce que l''utilisateur
entre « mandal », en lui laissant au maximum trois essais.*

**Correction.**

```
Algorithme : MotDePasse

Variable
    mdp : chaîne ;
    essais : entier ;

Début
    essais ← 0
    Répéter
        écrire("Entrez le mot de passe :")
        lire(mdp)
        essais ← essais + 1
    Jusqu''à (mdp = "mandal") ou (essais = 3)

    Si mdp = "mandal" alors
        écrire("Accès autorisé")
    Sinon
        écrire("Accès refusé : trois essais épuisés")
    Finsi
Fin
```

Le `Répéter` s''impose : il faut demander au moins une fois.

La condition de sortie est un `ou` avec **deux** raisons de sortir — le bon mot
de passe, ou les essais épuisés. Si on en oubliait une, l''algorithme serait
faux : sans `essais = 3`, un utilisateur qui ne trouve jamais le mot de passe
resterait coincé indéfiniment.

Et comme on peut sortir pour deux raisons différentes, il faut un `Si` **après**
la boucle pour savoir laquelle. C''est le point que les copies oublient le plus
souvent : sortir d''une boucle ne dit pas pourquoi on en est sorti.
', NULL, 28),
      (v_chapitre_id, 'Simulation : TantQue et Répéter côte à côte', 6, 'interactif', '{
  "widget": "comparer-boucles",
  "consigne": "Les deux boucles tournent en parallèle sur la même donnée, avec leurs conditions opposées affichées l''une sous l''autre. Rends la condition fausse dès le départ : le TantQue ne fait aucun tour, le Répéter en fait un. Un contrôle de saisie de note est ensuite proposé en TantQue — tu verras qu''il oblige à lire une première fois avant la boucle, ce que le Répéter évite."
}', NULL, 10),
      (v_chapitre_id, 'Les tableaux', 7, 'texte', '
### Le problème

Pour garder les notes de trente élèves, il faudrait trente variables : `note1`,
`note2`, … `note30`. Impossible à écrire, et surtout impossible à parcourir avec
une boucle : on ne peut pas « ajouter 1 » au nom d''une variable.

### La définition

Un **tableau** est un **ensemble de cases de même type**, portant **un seul
nom**, et repérées par un **indice**.

```
Variable
    notes : tableau[1..30] de réel ;
```

Une seule déclaration, trente cases. On y accède par :

```
notes[1] ← 12.5
notes[7] ← 9
écrire(notes[7])
```

### Le tableau et la boucle sont faits l''un pour l''autre

Puisque l''indice est un **nombre**, il peut être le **compteur d''une boucle**.
C''est là que tout devient possible.

```
Pour i de 1 à 30 faire
    écrire("Note de l''élève ", i, " :")
    lire(notes[i])
FinPour
```

Trente saisies en quatre lignes. Essaie de faire la même chose avec trente
variables séparées.

### Le parcours : le schéma à connaître par cœur

```
somme ← 0
Pour i de 1 à n faire
    somme ← somme + notes[i]
FinPour
moy ← somme / n
```

Ce schéma — initialiser, parcourir en accumulant, exploiter — résout la somme,
la moyenne, le comptage, le maximum, la recherche. **Toutes** les questions de
tableau du programme en sortent.

### Les deux fautes à ne pas commettre

**Sortir des bornes.** Avec `tableau[1..30]`, l''indice 0 et l''indice 31
n''existent pas. Une boucle `Pour i de 1 à 31` déborde.

**Confondre l''indice et le contenu.** `notes[3]` est la **troisième note**, par
exemple 14,5. Le `3` est la **place**, le `14.5` est la **valeur**. On s''y perd
souvent au début ; le tableau de trace remet les idées en place.

---

**Exercice corrigé**

*Écrire un algorithme qui lit les notes de `n` élèves dans un tableau, puis
affiche la moyenne de la classe et le nombre d''élèves ayant la moyenne.*

**Correction.**

```
Algorithme : BilanClasse

Variable
    n, i, nbAdmis : entier ;
    notes : tableau[1..100] de réel ;
    somme, moy : réel ;

Début
    Répéter
        écrire("Nombre d''élèves (1 à 100) :")
        lire(n)
    Jusqu''à (n >= 1) et (n <= 100)

    Pour i de 1 à n faire
        écrire("Note de l''élève ", i, " :")
        lire(notes[i])
    FinPour

    somme ← 0
    nbAdmis ← 0
    Pour i de 1 à n faire
        somme ← somme + notes[i]
        Si notes[i] >= 10 alors
            nbAdmis ← nbAdmis + 1
        Finsi
    FinPour

    moy ← somme / n
    écrire("Moyenne de la classe : ", moy)
    écrire("Élèves ayant la moyenne : ", nbAdmis)
Fin
```

Trois choses à noter, et chacune vaut des points.

Le tableau est déclaré pour **100** cases alors qu''on n''en utilisera que `n`. La
taille d''un tableau est fixée à la déclaration : on prévoit donc un maximum
raisonnable, et le `Répéter` empêche l''utilisateur de le dépasser. Sans ce
contrôle, `n = 150` ferait déborder le tableau.

Les deux compteurs, `somme` et `nbAdmis`, sont **initialisés à 0** avant le
parcours.

Un **seul** parcours suffit pour les deux calculs. On aurait pu écrire deux
boucles ; une seule est plus courte et plus rapide. C''est le réflexe à prendre
sur toutes les questions de tableau.
', NULL, 30),
      (v_chapitre_id, 'Simulation : parcourir un tableau', 8, 'interactif', '{
  "widget": "tableaux",
  "consigne": "Un tableau de notes s''affiche en cases numérotées. Remplis-le, puis lance un parcours et suis la case courante s''éclairer pendant que la somme, le compteur et le maximum se mettent à jour à côté. Change l''indice de départ ou d''arrivée pour sortir des bornes : la simulation te montre exactement ce qui se passe quand un algorithme lit une case qui n''existe pas."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 11', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quels sont les trois ingrédients obligatoires d''une boucle TantQue ?",
      "choix": [
        "Début, milieu, fin",
        "L''initialisation, la condition et la progression",
        "Le compteur, le test et le Finsi",
        "lire, traiter, écrire"
      ],
      "bonne": 1,
      "explication": "Sans initialisation, la condition teste une variable vide ; sans progression, la boucle est infinie. Demande-toi toujours : qu''est-ce qui rapproche de la sortie ?"
    },
    {
      "question": "Qu''est-ce qu''une boucle infinie ?",
      "choix": [
        "Une boucle qui tourne très longtemps",
        "Une boucle dont la condition reste vraie parce que rien ne la fait progresser vers la sortie",
        "Une boucle Pour mal écrite",
        "Une boucle qui ne tourne jamais"
      ],
      "bonne": 1,
      "explication": "Elle vient presque toujours de l''oubli de la ligne de progression. Sur une copie d''examen, elle coûte la question entière."
    },
    {
      "question": "Une boucle Pour peut-elle être infinie ?",
      "choix": [
        "Oui, si la condition est mal écrite",
        "Non, son compteur est géré automatiquement et s''arrête après la valeur finale",
        "Oui, si on oublie le FinPour",
        "Seulement avec un pas négatif"
      ],
      "bonne": 1,
      "explication": "C''est sa grande qualité. En revanche il ne faut jamais modifier soi-même la variable de contrôle à l''intérieur du bloc."
    },
    {
      "question": "Quelle est la différence essentielle entre TantQue et Répéter ?",
      "choix": [
        "Aucune",
        "Le TantQue teste au début et peut ne faire aucun tour ; le Répéter teste à la fin et fait toujours au moins un tour",
        "Le Répéter est plus rapide",
        "Le TantQue ne marche qu''avec des entiers"
      ],
      "bonne": 1,
      "explication": "Et leurs conditions sont opposées : on reste tant que la condition du TantQue est vraie, on sort quand celle du Répéter devient vraie."
    },
    {
      "question": "Quelle boucle convient pour redemander une note jusqu''à ce qu''elle soit entre 0 et 20 ?",
      "choix": [
        "Pour",
        "TantQue",
        "Répéter… Jusqu''à",
        "Selon"
      ],
      "bonne": 2,
      "explication": "On est obligé de demander au moins une fois : on ne peut pas vérifier une note qu''on n''a pas encore lue. C''est le cas d''école du Répéter."
    },
    {
      "question": "Qu''est-ce qu''un tableau ?",
      "choix": [
        "Une suite d''instructions répétées",
        "Un ensemble de cases de même type, portant un seul nom et repérées par un indice",
        "Un organigramme",
        "Une liste de variables de types différents"
      ],
      "bonne": 1,
      "explication": "Comme l''indice est un nombre, il peut être le compteur d''une boucle : c''est ce qui rend les tableaux et les boucles inséparables."
    },
    {
      "question": "Dans notes[3] = 14.5, que désigne le 3 ?",
      "choix": [
        "La valeur de la note",
        "La place de la case dans le tableau",
        "Le nombre de cases du tableau",
        "Le type de la case"
      ],
      "bonne": 1,
      "explication": "L''indice est la PLACE, le contenu est la VALEUR. Avec un tableau[1..30], les indices 0 et 31 n''existent pas."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 9 leçons ajoutées au chapitre 11, Les structures répétitives.', v_nom;
  END LOOP;
END $inf1$;
