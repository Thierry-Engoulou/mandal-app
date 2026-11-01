-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 9 : Variables, types et instructions élémentaires
-- Module 2 : Algorithmique et programmation — 7 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 9;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Variables, types et instructions élémentaires', 9, 'Module 2 : Algorithmique et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 9 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 9 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les variables, les constantes et les types', 1, 'texte', '
### La variable

Une **variable** est un **emplacement de la mémoire** repéré par un **nom**, et
destiné à contenir une **valeur** qui peut **changer** pendant l''exécution.

Pense à un casier d''un vestiaire. Le casier a un numéro — c''est le nom. Ce qu''on
met dedans peut changer — c''est la valeur. Mais il n''y a **qu''une seule chose à
la fois** dans un casier : dès que tu en mets une nouvelle, l''ancienne est
perdue.

Cette dernière phrase est à retenir : c''est exactement ce que fait
l''affectation.

### La constante

Une **constante** est un emplacement dont la valeur est **fixée une fois pour
toutes** et ne change jamais.

On l''utilise pour les valeurs qui ne bougent pas : un taux de TVA, le nombre
pi, le nombre de jours d''une semaine. L''intérêt est double : le nom explique la
valeur, et si le taux change un jour, on ne le modifie **qu''à un seul endroit**.

### Les cinq types

| Type | Ce qu''il contient | Exemples |
| --- | --- | --- |
| **entier** | un nombre sans virgule | `-5`, `0`, `347` |
| **réel** | un nombre à virgule | `3.14`, `-0.5`, `7500.0` |
| **caractère** | un seul signe, entre apostrophes | `''A''`, `''7''`, `''?''` |
| **chaîne de caractères** | un texte, entre guillemets | `"Thierry"`, `"1ère C"` |
| **booléen** | vrai ou faux, rien d''autre | `vrai`, `faux` |

Deux pièges reviennent sans cesse.

**`''7''` n''est pas `7`.** Le premier est un caractère, on ne peut pas l''additionner.
Le second est un entier.

**Un numéro de téléphone n''est pas un entier**, c''est une chaîne. On ne fait
jamais de calcul avec, il peut commencer par un zéro, et il est trop grand. La
règle générale : un nombre sur lequel on ne calcule pas est une chaîne.

### La déclaration

```
Constante
    tva = 0.07 ;
    pi = 3.14 ;
Variable
    age, n : entier ;
    moyenne : réel ;
    nom, classe : chaîne ;
    reussi : booléen ;
```

Le nom d''une variable commence par une lettre, ne contient ni espace ni accent,
et n''est pas un mot réservé du langage. `note1` est correct, `1note` et
`ma note` ne le sont pas.

---

**Exercice corrigé**

*Déclarer les variables nécessaires pour enregistrer le nom d''un élève, sa
classe, son âge, sa moyenne annuelle et s''il est admis ou non.*

**Correction.**

```
Variable
    nom, classe : chaîne ;
    age : entier ;
    moyenne : réel ;
    admis : booléen ;
```

Les justifications, car c''est elles qu''on note.

`nom` et `classe` sont des **chaînes** : ce sont des textes. On remarque au
passage que « 1ère C » contient un espace et un accent, donc c''est bien du
texte.

`age` est un **entier** : on ne dit pas qu''on a 15,5 ans en état civil.

`moyenne` est un **réel** : une moyenne vaut couramment 12,75.

`admis` est un **booléen** : il n''y a que deux réponses possibles, vrai ou faux.
', NULL, 25),
      (v_chapitre_id, 'Simulation : choisir le bon type', 2, 'interactif', '{
  "widget": "choix-types",
  "consigne": "Une douzaine de données te sont présentées — un nom, un numéro de téléphone, un âge, une moyenne, une réponse par oui ou non, le caractère d''une série — et tu dois donner à chacune son type. La simulation sanctionne les deux pièges habituels : le numéro de téléphone déclaré en entier, et le caractère confondu avec le nombre, en te montrant ce qui casse à l''exécution."
}', NULL, 10),
      (v_chapitre_id, 'L''affectation, la lecture et l''écriture', 3, 'texte', '
Trois instructions suffisent à écrire la moitié des algorithmes du programme.

### L''affectation

L''**affectation** met une valeur dans une variable. Elle s''écrit avec une
**flèche vers la gauche** :

```
x ← 5
y ← x + 3
x ← x + 1
```

Trois règles à ne jamais perdre de vue.

**Elle se lit de droite à gauche.** On calcule d''abord ce qui est à droite,
**ensuite** on le range dans la variable de gauche.

**À gauche, il y a toujours une seule variable.** `x + 1 ← 5` n''a aucun sens.

**L''ancienne valeur est écrasée.** C''est le casier du vestiaire.

La troisième ligne ci-dessus, `x ← x + 1`, trouble beaucoup d''élèves. En
mathématiques, elle serait absurde. En algorithmique, elle se lit : « prends la
valeur actuelle de `x`, ajoute 1, et remets le résultat dans `x` ». Si `x`
valait 5, il vaut maintenant 6. C''est l''instruction la plus utilisée de tout le
programme, car c''est elle qui fait avancer les boucles.

### La lecture

`lire(x)` met dans `x` ce que l''utilisateur **tape au clavier**. C''est une
entrée, et c''est la seule façon pour l''algorithme de recevoir une information
qu''il ne connaît pas.

```
lire(x)
lire(pu, q)
```

### L''écriture

`écrire(…)` **affiche** à l''écran. C''est une sortie.

```
écrire(x)
écrire("Le résultat est : ", x)
écrire("Bonjour")
```

Attention à la différence entre `écrire(x)` et `écrire("x")`. Le premier
affiche **le contenu** de la variable, par exemple `5`. Le second affiche la
**lettre x**. Les guillemets changent tout.

### Dérouler un algorithme à la main

C''est la technique la plus rentable de tout le module. On fait un tableau avec
une colonne par variable et une ligne par instruction, et on note ce que
contient chaque variable après chaque ligne.

Déroulons :

```
a ← 3
b ← 7
a ← b
b ← a
écrire(a, b)
```

| Instruction | `a` | `b` |
| --- | --- | --- |
| `a ← 3` | 3 | — |
| `b ← 7` | 3 | 7 |
| `a ← b` | 7 | 7 |
| `b ← a` | 7 | 7 |

L''algorithme affiche `7 7`. Il **ne permute pas** `a` et `b`, contrairement à ce
que beaucoup croient : la première affectation a déjà écrasé le 3.

---

**Exercice corrigé**

*Écrire un algorithme qui échange les contenus de deux variables `a` et `b`.*

**Correction.** Il faut une **variable intermédiaire** pour mettre de côté la
valeur qu''on va écraser.

```
Algorithme : Echange

Variable
    a, b, temp : entier ;

Début
    lire(a, b)
    temp ← a
    a ← b
    b ← temp
    écrire(a, b)
Fin
```

Déroulons avec `a = 3` et `b = 7` :

| Instruction | `a` | `b` | `temp` |
| --- | --- | --- | --- |
| `lire(a, b)` | 3 | 7 | — |
| `temp ← a` | 3 | 7 | 3 |
| `a ← b` | 7 | 7 | 3 |
| `b ← temp` | 7 | 3 | 3 |

L''échange est fait. La variable `temp` est indispensable : sans elle, la valeur
de `a` serait perdue avant d''avoir pu être recopiée dans `b`.
', NULL, 28),
      (v_chapitre_id, 'Simulation : dérouler un algorithme', 4, 'interactif', '{
  "widget": "trace-variables",
  "consigne": "Un algorithme s''exécute ligne par ligne sous tes yeux, et le tableau de trace se remplit à droite : une colonne par variable, une ligne par instruction. Tu peux avancer pas à pas, revenir en arrière, et surtout prédire la prochaine valeur avant de la découvrir. L''algorithme d''échange avec et sans variable intermédiaire est proposé côte à côte : c''est le meilleur moyen de comprendre pourquoi temp est indispensable."
}', NULL, 10),
      (v_chapitre_id, 'Les opérateurs et les expressions', 5, 'texte', '
### Les opérateurs arithmétiques

| Opérateur | Rôle | Exemple |
| --- | --- | --- |
| `+` `-` `*` `/` | les quatre opérations | `5 * 3` vaut 15 |
| `div` | quotient de la division **entière** | `17 div 5` vaut 3 |
| `mod` | **reste** de la division entière | `17 mod 5` vaut 2 |

`div` et `mod` sont les deux outils les plus utiles de tout le module, et on les
sous-estime. Avec eux :

**`n mod 2 = 0`** teste si `n` est **pair**. C''est la question la plus fréquente
du Probatoire.

**`n mod d = 0`** teste si `n` est **divisible** par `d`.

**`n div 10` et `n mod 10`** séparent un nombre de ses chiffres : pour 347,
`347 div 10` vaut 34 et `347 mod 10` vaut 7, le chiffre des unités.

### Les opérateurs de comparaison

`=` égal, `<>` différent, `<`, `>`, `<=`, `>=`.

Une comparaison ne donne jamais un nombre : elle donne un **booléen**, vrai ou
faux. `5 > 3` vaut `vrai`.

Et ne confonds pas `=` avec `←`. La flèche **affecte**, le signe égal
**compare**.

### Les opérateurs logiques

Ils combinent des booléens.

**`et`** est vrai seulement si **les deux** conditions sont vraies.
**`ou`** est vrai si **au moins une** des deux l''est.
**`non`** inverse.

```
(moyenne >= 10) et (absences < 5)
(age < 18) ou (etudiant = vrai)
non (note > 20)
```

### L''ordre de priorité

Comme en mathématiques : d''abord les **parenthèses**, puis `*` `/` `div` `mod`,
puis `+` `-`, puis les **comparaisons**, puis `non`, puis `et`, puis `ou`.

Le conseil pratique : **mets des parenthèses**. Elles ne coûtent rien, elles
lèvent toute ambiguïté, et le correcteur n''a pas à deviner ton intention.

---

**Exercice corrigé**

*Écrire un algorithme qui lit un entier et affiche s''il est pair ou impair,
ainsi que son chiffre des unités.*

**Correction.**

```
Algorithme : PairImpair

Variable
    n, unite : entier ;

Début
    écrire("Entrez un entier :")
    lire(n)
    unite ← n mod 10
    écrire("Chiffre des unités : ", unite)
    Si (n mod 2 = 0) alors
        écrire(n, " est pair")
    Sinon
        écrire(n, " est impair")
    Finsi
Fin
```

Avec `n = 347` : `unite` vaut 7, et `347 mod 2` vaut 1, donc l''algorithme
affiche « 347 est impair ».

Remarque qu''on n''a pas eu besoin de diviser par 2 ni de comparer des moitiés.
Le reste `mod` répond directement à la question, et c''est pour cela qu''il faut
le connaître.
', NULL, 25),
      (v_chapitre_id, 'Simulation : div, mod et les opérateurs logiques', 6, 'interactif', '{
  "widget": "operateurs",
  "consigne": "Entre deux nombres et vois `div` et `mod` travailler côte à côte, avec la division posée dessinée pour que la différence entre quotient et reste devienne évidente. Un second volet te donne une table de vérité à remplir pour `et`, `ou` et `non`, puis t''envoie des conditions composées à évaluer, parenthèses comprises."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 9', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qu''une variable ?",
      "choix": [
        "Une valeur qui ne change jamais",
        "Un emplacement de la mémoire, repéré par un nom, dont le contenu peut changer",
        "Une instruction d''affichage",
        "Un type de donnée"
      ],
      "bonne": 1,
      "explication": "Comme un casier de vestiaire : le nom est le numéro du casier, la valeur est ce qu''on met dedans — et il n''y a qu''une chose à la fois."
    },
    {
      "question": "Quel est le type approprié pour un numéro de téléphone ?",
      "choix": [
        "entier",
        "réel",
        "chaîne de caractères",
        "booléen"
      ],
      "bonne": 2,
      "explication": "On ne calcule jamais avec, il peut commencer par un zéro et il est trop grand. La règle : un nombre sur lequel on ne calcule pas est une chaîne."
    },
    {
      "question": "Comment se lit l''affectation x ← y + 2 ?",
      "choix": [
        "De gauche à droite",
        "On calcule d''abord y + 2, puis on range le résultat dans x",
        "x et y échangent leurs valeurs",
        "On compare x et y + 2"
      ],
      "bonne": 1,
      "explication": "Toujours de droite à gauche. Et l''ancienne valeur de x est écrasée : c''est le casier du vestiaire."
    },
    {
      "question": "Que vaut 17 mod 5 ?",
      "choix": [
        "3",
        "2",
        "3.4",
        "85"
      ],
      "bonne": 1,
      "explication": "mod donne le RESTE de la division entière : 17 = 5 × 3 + 2. C''est div qui donne le quotient 3."
    },
    {
      "question": "Comment teste-t-on si un entier n est pair ?",
      "choix": [
        "Si n / 2 = 0",
        "Si n mod 2 = 0",
        "Si n div 2 = 0",
        "Si n > 2"
      ],
      "bonne": 1,
      "explication": "Le reste de la division par 2 vaut 0 pour un nombre pair. C''est la question la plus fréquente du Probatoire, et elle tient en un mod."
    },
    {
      "question": "Quelle est la différence entre écrire(x) et écrire(« x ») ?",
      "choix": [
        "Aucune",
        "Le premier affiche le contenu de la variable, le second affiche la lettre x",
        "Le premier est faux",
        "Le second affiche le contenu"
      ],
      "bonne": 1,
      "explication": "Les guillemets changent tout : sans eux on affiche la valeur, avec eux on affiche le texte tel quel."
    },
    {
      "question": "L''expression (moyenne >= 10) et (absences < 5) est vraie quand :",
      "choix": [
        "au moins une des deux conditions est vraie",
        "les deux conditions sont vraies en même temps",
        "aucune des deux n''est vraie",
        "la moyenne dépasse 10"
      ],
      "bonne": 1,
      "explication": "et exige les DEUX. C''est ou qui se contente d''une seule. Une comparaison ne donne jamais un nombre mais un booléen."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 9, Variables, types et instructions élémentaires.', v_nom;
  END LOOP;
END $inf1$;
