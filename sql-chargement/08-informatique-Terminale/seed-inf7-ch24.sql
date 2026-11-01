-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 24 : Les structures de contrôle en langage C
-- Module 3 : Algorithme et programmation — 7 leçons
--
-- Ce fichier remplit les deux séries d'un coup : la Terminale C et la
-- Terminale D. Il n'a besoin de rien d'autre pour tourner. Si la matière, les
-- classes, les programmes ou le chapitre n'existent pas encore, il les crée
-- lui-même au passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $inf7$
DECLARE
  v_lettres text[] := ARRAY['C', 'D'];
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
  FOR v_i IN 1..2 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := 'Terminale ' || v_lettre;

    -- Le programme de Chimie de cette série existe-t-il déjà ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Informatique — ' || v_nom;

    -- Non : on le crée, et la classe avec si besoin.
    IF v_programme_id IS NULL THEN
      -- La classe a pu être écrite de plusieurs façons : Terminale C, Tle C, TC.
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE 'T%le ' || v_lettre OR nom ILIKE 'Terminale ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Terminale', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'La classe % n''existait pas : je viens de la créer.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Informatique — ' || v_nom,
              'Programme officiel d''Informatique, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 3 modules, 25 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme d''Informatique de la % : créé.', v_nom;
    END IF;

    -- Le chapitre lui-même.
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 24;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les structures de contrôle en langage C', 24, 'Module 3 : Algorithme et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 24 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 24 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les structures alternatives en langage C', 1, 'texte', '
Le LDA et le C disent la même chose. Seule l''écriture change — et c''est cette
traduction qu''on demande en examen.

### if … else

```c
if (condition)
{
    /* instructions si vrai */
}
else
{
    /* instructions si faux */
}
```

**Quatre règles d''écriture.**

La condition est **toujours entre parenthèses**.

Il n''y a **pas de point-virgule après la parenthèse** du `if`. Écrire `if (x >
0);` est accepté par le compilateur : le `if` ne fait alors rien du tout, et le
bloc s''exécute toujours. C''est un bug redoutable, parce qu''il ne provoque aucune
erreur.

Les accolades sont **facultatives pour une seule instruction**, mais il vaut
mieux **toujours les mettre** : ajouter une ligne plus tard sans ajouter les
accolades casse silencieusement le programme.

Le mot est **`else`**, et non `sinon`.

### Les opérateurs

| En LDA | En C |
| --- | --- |
| `=` *(comparer)* | **`==`** |
| `≠` | `!=` |
| `<` `>` `<=` `>=` | identiques |
| `et` | `&&` |
| `ou` | `||` |
| `non` | `!` |

**Le piège du `=` contre `==`.** `if (x == 5)` **compare**. `if (x = 5)`
**affecte** 5 à `x`, puis juge la valeur 5 vraie — donc le bloc s''exécute
toujours, et `x` a été modifié au passage. **Le compilateur ne dit rien.** Dans
un exercice de correction d''erreurs, c''est la faute à repérer en priorité.

### else if, pour plus de deux cas

Le C évite l''empilement d''accolades des `Si` imbriqués du LDA :

```c
if (moy >= 16)
    printf("Tres bien\n");
else if (moy >= 14)
    printf("Bien\n");
else if (moy >= 12)
    printf("Assez bien\n");
else if (moy >= 10)
    printf("Passable\n");
else
    printf("Ajourne\n");
```

**Et l''ordre reste capital**, exactement comme en LDA : du plus exigeant au
moins exigeant.

### switch, l''équivalent du Selon

```c
switch (jour)
{
    case 1 : printf("Lundi\n");   break;
    case 2 : printf("Mardi\n");   break;
    case 3 : printf("Mercredi\n"); break;
    default : printf("Jour invalide\n");
}
```

**Le `break` est obligatoire**, et son oubli est l''erreur classique du
`switch` : sans lui, l''exécution **continue dans les cas suivants**. Avec `jour`
valant 1 et aucun `break`, le programme afficherait Lundi, Mardi, Mercredi et le
message d''erreur.

**Le `default`** correspond au `Autre` du LDA et s''exécute quand aucun cas ne
correspond.

**Le `switch` ne fonctionne que sur des valeurs entières ou des caractères, et
jamais sur des intervalles.** Les mentions exigent donc des `else if`.

---

**Exercice corrigé**

*Traduire en C l''algorithme suivant, puis repérer et corriger l''erreur du
programme donné ensuite.*

```
Si (moy >= 10) et (absences < 5) alors
    écrire("Admis")
Sinon
    écrire("Refusé")
Finsi
```

```c
if (moy = 10)
    printf("Admis");
```

**Correction.**

*La traduction :*

```c
if (moy >= 10 && absences < 5)
{
    printf("Admis\n");
}
else
{
    printf("Refuse\n");
}
```

*Les trois transformations :* le `et` devient **`&&`**, le `écrire` devient
**`printf`** avec un `\n`, et le `Sinon … Finsi` devient **`else { }`**.

*L''erreur du second programme.* `if (moy = 10)` utilise un **`=`** là où il faut
un **`==`**. Le programme **affecte** la valeur 10 à `moy`, puis juge cette
valeur vraie : le message « Admis » s''affiche **toujours**, et la vraie moyenne
a été **écrasée**.

*La correction :* `if (moy == 10)`, ou plus probablement `if (moy >= 10)` si
l''intention était de tester l''admission.

*Le compilateur n''émet aucune erreur sur cette ligne : c''est pour cela qu''elle
est si dangereuse, et qu''elle revient régulièrement dans les questions de
correction d''erreurs.*
', NULL, 28),
      (v_chapitre_id, 'Simulation : if, else if et switch', 2, 'interactif', '{
  "widget": "if-else-c",
  "consigne": "Écris une condition et la simulation l''évalue pour les valeurs que tu entres, en éclairant la branche prise. Remplace un == par un = et regarde le bloc s''exécuter quand même, avec la variable modifiée au passage. Un second volet construit un switch où tu peux retirer les break un par un, pour voir l''exécution dégringoler dans les cas suivants."
}', NULL, 10),
      (v_chapitre_id, 'Le switch et le choix de la structure', 3, 'texte', '
### Le switch en détail

```c
switch (expression)
{
    case valeur1 :
        instructions
        break;
    case valeur2 :
        instructions
        break;
    default :
        instructions
}
```

L''expression est évaluée **une fois**, puis comparée à chaque `case` jusqu''à
trouver l''égalité.

### Les contraintes du switch

L''expression doit être de type **entier** ou **caractère** — jamais un `float`,
jamais une chaîne.

Chaque `case` porte une **valeur unique et constante**, pas une condition : on
ne peut écrire ni `case moy >= 10 :` ni `case 10..12 :`.

### Grouper plusieurs cas

L''absence de `break` est parfois **voulue**, et c''est le seul cas où on
l''omet volontairement :

```c
switch (note)
{
    case 18 :
    case 19 :
    case 20 :
        printf("Excellent\n");
        break;
    default :
        printf("Autre\n");
}
```

Les trois notes mènent au même message, parce que les deux premiers `case` sont
vides et laissent l''exécution tomber sur le troisième.

### Un exemple complet : la calculatrice

```c
#include <stdio.h>

int main()
{
    float a, b;
    char op;

    printf("Operation (a + b) : ");
    scanf("%f %c %f", &a, &op, &b);

    switch (op)
    {
        case ''+'' : printf("%.2f\n", a + b); break;
        case ''-'' : printf("%.2f\n", a - b); break;
        case ''*'' : printf("%.2f\n", a * b); break;
        case ''/'' :
            if (b != 0)
                printf("%.2f\n", a / b);
            else
                printf("Division par zero impossible\n");
            break;
        default : printf("Operateur inconnu\n");
    }

    return 0;
}
```

Deux choses à remarquer. Le `switch` porte sur un **`char`**, ce qui est
autorisé. Et le cas de la division contient un **`if` imbriqué** pour refuser le
diviseur nul : un `switch` peut contenir n''importe quelle instruction.

### Quelle structure choisir

| La situation | La structure |
| --- | --- |
| deux cas opposés | `if … else` |
| plusieurs **intervalles** | `else if` en chaîne |
| plusieurs **valeurs précises** d''une même variable | `switch` |
| une seule action conditionnelle | `if` seul |

**La question à se poser : est-ce que je compare à des valeurs précises, ou à
des intervalles ?** Valeurs précises, `switch`. Intervalles, `else if`.

---

**Exercice corrigé**

*Écrire un programme qui lit un numéro de mois et affiche le nombre de jours,
l''année n''étant pas bissextile. Puis dire pourquoi un switch convient ici, et
pas pour les mentions.*

**Correction.**

```c
#include <stdio.h>

int main()
{
    int mois;

    printf("Numero du mois (1 a 12) : ");
    scanf("%d", &mois);

    switch (mois)
    {
        case 1 : case 3 : case 5 : case 7 :
        case 8 : case 10 : case 12 :
            printf("31 jours\n");
            break;

        case 4 : case 6 : case 9 : case 11 :
            printf("30 jours\n");
            break;

        case 2 :
            printf("28 jours\n");
            break;

        default :
            printf("Numero de mois invalide\n");
    }

    return 0;
}
```

*Pourquoi le `switch` convient.* On compare une **variable entière** à des
**valeurs précises et énumérables** : les douze numéros de mois. Et le
regroupement des `case` sans `break` évite de répéter sept fois la même ligne.

*Pourquoi il ne conviendrait pas aux mentions.* Une mention se détermine par un
**intervalle** — « entre 14 et 16 » — et un `case` n''accepte qu''une **valeur
unique**. Il faudrait écrire un `case` pour chaque dixième de point, ce qui est
impossible avec des notes réelles. De plus, l''expression d''un `switch` ne peut
pas être un `float`.
', NULL, 26),
      (v_chapitre_id, 'Simulation : construire un switch', 4, 'interactif', '{
  "widget": "switch-c",
  "consigne": "Monte un switch cas par cas et teste-le avec les valeurs de ton choix. La simulation refuse un case sur un intervalle ou sur un float, en citant la règle. Groupe plusieurs cas en retirant leurs break volontairement et vois le mécanisme de la chute. Un comparateur met côte à côte le même problème écrit en switch et en else if, et te dit lequel était le bon choix."
}', NULL, 10),
      (v_chapitre_id, 'Les boucles en langage C', 5, 'texte', '
### while, l''équivalent du TantQue

```c
while (condition)
{
    instructions
}
```

Même fonctionnement : test **au début**, répétition **tant que la condition est
vraie**, et **zéro tour possible**.

```c
int i = 1;
while (i <= 5)
{
    printf("%d ", i);
    i++;
}
```

Les **trois ingrédients** du LDA restent obligatoires : initialiser, tester,
progresser.

**Le piège propre au C** : un point-virgule après la parenthèse. `while (i <=
5);` est une **boucle infinie** sans aucun message d''erreur.

### do … while, l''équivalent du Répéter

```c
do
{
    instructions
}
while (condition);
```

**Deux différences avec le LDA**, et elles comptent en examen.

Le C **garde la même condition qu''un `while`** : on **reste** tant qu''elle est
vraie. Le LDA inversait la condition du `Jusqu''à`.

Le `while` final porte un **point-virgule**, le seul `while` du langage à en
porter un.

```c
int note;
do
{
    printf("Note entre 0 et 20 : ");
    scanf("%d", &note);
}
while (note < 0 || note > 20);
```

### for, l''équivalent du Pour

```c
for (initialisation ; condition ; progression)
{
    instructions
}
```

Les trois ingrédients tiennent sur **une seule ligne**, séparés par des
**points-virgules** — et non par des virgules.

```c
for (i = 1 ; i <= 5 ; i++)
{
    printf("%d ", i);
}
```

### Les opérateurs d''incrémentation

| Écriture | Équivalent |
| --- | --- |
| `i++` | `i = i + 1` |
| `i--` | `i = i - 1` |
| `i += 2` | `i = i + 2` |
| `somme += x` | `somme = somme + x` |

### Le tableau de traduction complet

| En LDA | En C |
| --- | --- |
| `TantQue c faire … FinTantQue` | `while (c) { … }` |
| `Répéter … Jusqu''à c` | `do { … } while (!c);` |
| `Pour i de 1 à n faire … FinPour` | `for (i = 1 ; i <= n ; i++) { … }` |
| `i ← i + 1` | `i++;` |

**Attention à la ligne du `Répéter`.** Le LDA sort **quand la condition devient
vraie**, le C **reste** tant qu''elle est vraie : la condition doit donc être
**inversée** à la traduction. `Jusqu''à i > n` devient `while (i <= n);`.

C''est la traduction la plus souvent ratée, et elle tombe régulièrement.

---

**Exercice corrigé**

*Traduire en langage C l''algorithme suivant, qui affiche la table de
multiplication d''un nombre.*

```
lire(n)
i ← 1
TantQue i <= 10 faire
    écrire(n, " x ", i, " = ", n * i)
    i ← i + 1
FinTantQue
```

*Puis réécrire la même boucle avec un for, et avec un do … while.*

**Correction.**

*Avec `while`, traduction directe :*

```c
#include <stdio.h>

int main()
{
    int n, i;

    printf("Quel nombre ? ");
    scanf("%d", &n);

    i = 1;
    while (i <= 10)
    {
        printf("%d x %d = %d\n", n, i, n * i);
        i++;
    }

    return 0;
}
```

*Avec `for`, plus compact :*

```c
for (i = 1 ; i <= 10 ; i++)
{
    printf("%d x %d = %d\n", n, i, n * i);
}
```

*Avec `do … while` :*

```c
i = 1;
do
{
    printf("%d x %d = %d\n", n, i, n * i);
    i++;
}
while (i <= 10);
```

*Les trois points vérifiés.* L''**initialisation `i = 1`** avant le `while`, sans
laquelle `i` contient n''importe quoi. Le **`i++`** dans le bloc, sans lequel la
boucle est infinie. Et le **point-virgule après le `while` final** du `do …
while`, qui est obligatoire là et interdit ailleurs.

*Ici le `for` est le meilleur choix : le nombre de tours est connu à l''avance,
et les trois ingrédients tiennent sur une ligne où l''on ne peut pas les
oublier.*
', NULL, 30),
      (v_chapitre_id, 'Simulation : traduire les boucles LDA en C', 6, 'interactif', '{
  "widget": "boucles-c",
  "consigne": "Un algorithme LDA s''affiche à gauche, et tu construis sa traduction en C à droite, morceau par morceau. La simulation exécute les deux côte à côte et compare les sorties ligne à ligne. Traduis un Répéter … Jusqu''à sans inverser la condition et vois les deux programmes diverger immédiatement — c''est l''erreur de traduction la plus fréquente de l''examen. Un point-virgule égaré après un while déclenche le détecteur de boucle infinie."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 24', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Comment s''écrit « et » en langage C ?",
      "choix": [
        "and",
        "&&",
        "&",
        "et"
      ],
      "bonne": 1,
      "explication": "&& pour le et, || pour le ou, ! pour le non. Le simple & est un autre opérateur, qui travaille bit à bit."
    },
    {
      "question": "Que fait if (x = 5) ?",
      "choix": [
        "Il compare x à 5",
        "Il affecte 5 à x puis juge cette valeur vraie : le bloc s''exécute toujours et x est écrasé",
        "Il provoque une erreur de compilation",
        "Il ne fait rien"
      ],
      "bonne": 1,
      "explication": "Le compilateur ne dit rien. Dans un exercice de correction d''erreurs, c''est la faute à repérer en priorité."
    },
    {
      "question": "Que se passe-t-il si on oublie un break dans un switch ?",
      "choix": [
        "Rien",
        "L''exécution continue dans les cas suivants",
        "Le programme s''arrête",
        "Le switch est ignoré"
      ],
      "bonne": 1,
      "explication": "Avec jour = 1 et aucun break, le programme afficherait Lundi, Mardi, Mercredi et le message d''erreur à la suite."
    },
    {
      "question": "Pourquoi un switch ne convient-il pas aux mentions ?",
      "choix": [
        "Il est trop lent",
        "Parce qu''une mention se détermine par un intervalle, et qu''un case n''accepte qu''une valeur unique et constante",
        "Parce qu''il n''accepte pas les printf",
        "Parce qu''il faut un break"
      ],
      "bonne": 1,
      "explication": "Et l''expression d''un switch ne peut pas être un float. Les mentions exigent des else if en chaîne."
    },
    {
      "question": "Comment traduit-on « Répéter … Jusqu''à i > n » en C ?",
      "choix": [
        "do { … } while (i > n);",
        "do { … } while (i <= n);",
        "while (i > n) { … }",
        "for (i > n) { … }"
      ],
      "bonne": 1,
      "explication": "Le LDA sort quand la condition devient vraie, le C reste tant qu''elle est vraie : il faut INVERSER la condition. C''est la traduction la plus souvent ratée."
    },
    {
      "question": "Quels séparateurs utilise-t-on dans un for ?",
      "choix": [
        "Des virgules",
        "Des points-virgules",
        "Des deux-points",
        "Rien du tout"
      ],
      "bonne": 1,
      "explication": "for (i = 1 ; i <= n ; i++) : initialisation, condition, progression, séparées par des points-virgules."
    },
    {
      "question": "Que provoque un point-virgule juste après while (i <= 5) ?",
      "choix": [
        "Une erreur de compilation",
        "Une boucle infinie, sans aucun message d''erreur",
        "Rien du tout",
        "Le programme saute la boucle"
      ],
      "bonne": 1,
      "explication": "Le while n''a plus de corps et tourne sur place. Le même piège existe avec if (x > 0); où le if ne fait plus rien."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 24, Les structures de contrôle en langage C.', v_nom;
  END LOOP;
END $inf7$;
