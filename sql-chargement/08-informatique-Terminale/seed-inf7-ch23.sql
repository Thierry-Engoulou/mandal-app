-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 23 : Les fonctions d'entrée et de sortie en C
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
    WHERE programme_id = v_programme_id AND ordre = 23;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les fonctions d''entrée et de sortie en C', 23, 'Module 3 : Algorithme et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 23 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 23 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les variables et les constantes en langage C', 1, 'texte', '
### Déclarer une variable

```c
type nom ;
```

Et en C, **toute variable doit être déclarée avant d''être utilisée** : le
compilateur refuse un nom qu''il ne connaît pas.

### Les types fondamentaux

| Type en C | Ce qu''il contient | Taille usuelle | En LDA |
| --- | --- | --- | --- |
| `int` | un entier | 4 octets | entier |
| `float` | un réel | 4 octets | réel |
| `double` | un réel plus précis | 8 octets | réel |
| `char` | **un seul** caractère | 1 octet | caractère |

**Le C n''a pas de type booléen** dans sa version de base : on utilise un `int`,
où **0 signifie faux** et **toute valeur non nulle signifie vrai**.

**Et le C n''a pas de type chaîne de caractères** : une chaîne est un **tableau
de `char`**, `char nom[30];`. C''est une différence importante avec le LDA.

### Les déclarations en pratique

```c
int age;
float moyenne;
char initiale;
int n, i, somme;              /* plusieurs d''un coup */
int compteur = 0;             /* avec une valeur initiale */
```

**L''initialisation à la déclaration est une bonne habitude.** Une variable non
initialisée en C ne vaut pas 0 : elle contient **ce qui traînait en mémoire**,
une valeur imprévisible. C''est une source de bugs incompréhensibles.

### Les règles de nommage

Commencer par une **lettre** ou un `_`, jamais par un chiffre. Ni **espace**, ni
**accent**, ni tiret. Pas un **mot réservé** du langage (`int`, `if`, `for`,
`return`, `while`…). Et **les majuscules comptent**.

Donc `moyenne_generale` est correct, `moyenne générale` et `2eNote` ne le sont
pas.

### L''affectation

```c
age = 17;
moyenne = 13.5;
initiale = ''M'';
```

Le `=` du C correspond à la **flèche `←`** du LDA. Et un caractère s''écrit entre
**apostrophes simples** `''M''`, une chaîne entre **guillemets doubles** `"Mbida"`
— les confondre est une erreur de compilation.

### Les constantes

Une **constante** est une valeur qui **ne change pas** pendant l''exécution. Deux
façons de la déclarer.

**Avec `#define`**, avant le `main`, sans point-virgule et sans type :

```c
#define PI 3.14159
#define TAILLE 50
```

**Avec `const`**, à l''intérieur du programme, avec un type et un point-virgule :

```c
const float PI = 3.14159;
const int TAILLE = 50;
```

Dans les deux cas, toute tentative de modification est **refusée par le
compilateur** — et c''est tout l''intérêt : la constante protège une valeur contre
une modification accidentelle.

**La convention est de nommer les constantes en MAJUSCULES.** Ce n''est pas une
obligation du langage, mais tout le monde la suit, et le correcteur l''attend.

### La division entière, le piège

```c
int a = 7, b = 2;
float r;
r = a / b;          /* r vaut 3, et non 3,5 */
```

**Entre deux entiers, le C fait une division entière** et jette le reste. La
correction consiste à forcer un réel :

```c
r = (float) a / b;    /* r vaut 3,5 */
```

C''est exactement ce qui arrive au calcul d''une moyenne : avec `somme` et `n`
entiers, `somme / n` donne 13 au lieu de 13,67.

---

**Exercice corrigé**

*Déclarer les variables nécessaires au calcul de la moyenne de trois notes, et
une constante valant le nombre de notes. Écrire le calcul en évitant le piège de
la division entière.*

**Correction.**

```c
#include <stdio.h>

#define NB_NOTES 3            /* la constante, en majuscules, sans ; */

int main()
{
    float n1, n2, n3;         /* des réels : une note vaut 13,5 */
    float moyenne;

    printf("Entrez les trois notes : ");
    scanf("%f %f %f", &n1, &n2, &n3);

    moyenne = (n1 + n2 + n3) / NB_NOTES;

    printf("Moyenne : %.2f\n", moyenne);

    return 0;
}
```

*Pourquoi il n''y a pas de piège ici.* Les trois notes sont déclarées **`float`**
: la somme est donc un réel, et la division par un entier donne un réel.

*Où le piège aurait frappé.* Avec `int n1, n2, n3;` et des notes de 12, 14 et
15, la somme vaut 41, et `41 / 3` donne **13** au lieu de 13,67. Il aurait fallu
écrire `(float)(n1 + n2 + n3) / NB_NOTES`.
', NULL, 28),
      (v_chapitre_id, 'Simulation : déclarer des variables en C', 2, 'interactif', '{
  "widget": "variables-c",
  "consigne": "Déclare des variables en choisissant leur type et leur nom, et la simulation accepte ou refuse en citant la règle. Essaie « 2eNote », « moyenne générale » avec un accent, ou « int » comme nom de variable. Range ensuite des valeurs dedans et regarde la mémoire : un float qui reçoit 7/2 affiche 3, et la simulation te montre le reste jeté par la division entière."
}', NULL, 10),
      (v_chapitre_id, 'Les constantes et la mémoire', 3, 'texte', '
### Pourquoi on utilise des constantes

Un programme de gestion de classe écrit avec le nombre 50 répété quinze fois est
un programme impossible à modifier : passer à 60 élèves oblige à retrouver les
quinze occurrences, et à ne pas confondre le 50 des élèves avec le 50 d''un
pourcentage.

Avec `#define NB_ELEVES 50`, **une seule ligne change**.

C''est la raison d''être de la constante : elle **nomme** une valeur, et le nom
explique ce que le nombre voulait dire.

### Les deux formes, et ce qui les sépare

| | `#define` | `const` |
| --- | --- | --- |
| où | avant le `main` | dans le programme |
| le type | non précisé | obligatoire |
| le `;` | **pas de point-virgule** | point-virgule obligatoire |
| quand | **remplacé avant la compilation** | existe à l''exécution |

Le `#define` est traité par le **préprocesseur**, qui fait un simple
**remplacement de texte** dans tout le fichier avant que le compilateur ne voie
quoi que ce soit. Le `const`, lui, est une **vraie variable protégée en
écriture**.

Les deux sont acceptés en examen. Le `#define` est celui des manuels scolaires
camerounais.

### Les constantes littérales

Les valeurs écrites directement dans le code portent aussi un nom : ce sont les
**constantes littérales**.

```c
42          /* une constante entière */
3.14        /* une constante réelle */
''A''         /* une constante caractère, apostrophes simples */
"Bonjour"   /* une constante chaîne, guillemets doubles */
```

**Apostrophes simples pour un caractère, guillemets doubles pour une chaîne.**
Écrire `char c = "A";` est une erreur de type, parce que `"A"` est une chaîne de
deux octets — le `A` et le marqueur de fin.

### Ce qu''une variable occupe en mémoire

Une variable, c''est **un nom, un type, une adresse et une valeur**.

Le **type** détermine la **place occupée** et donc **l''intervalle des valeurs
possibles**. Un `int` de 4 octets va d''environ −2 milliards à +2 milliards.

**L''adresse** est l''emplacement en mémoire, et l''opérateur **`&`** la donne.
C''est précisément pourquoi `scanf("%d", &age)` s''écrit avec un `&` : la fonction
a besoin de savoir **où** ranger ce que l''utilisateur tape, pas de connaître la
valeur actuelle.

Cette ligne-là est la raison du `&`, et une fois comprise, on ne l''oublie plus.

### Choisir le bon type

| On stocke | Le type |
| --- | --- |
| un âge, un effectif, un compteur | `int` |
| une note, un prix, une moyenne | `float` |
| un calcul scientifique précis | `double` |
| une initiale, un sexe M ou F | `char` |
| un nom, une adresse | `char nom[30]` |
| un oui/non | `int`, avec 0 pour faux |

---

**Exercice corrigé**

*Déclarer de deux façons différentes une constante TVA valant 19,25 %. Puis
expliquer pourquoi scanf exige un & devant la variable et printf non.*

**Correction.**

*Les deux déclarations :*

```c
#define TVA 0.1925            /* forme préprocesseur, avant le main, sans ; */

const float TVA = 0.1925;     /* forme const, dans le programme, avec ; */
```

*Pourquoi le `&` dans `scanf` et pas dans `printf`.*

`printf` doit **afficher** le contenu d''une variable : il lui suffit donc de
recevoir **la valeur**.

`scanf` doit **ranger** ce que l''utilisateur tape **dans** la variable : il a
besoin de savoir **où elle se trouve en mémoire**, c''est-à-dire son **adresse**.
L''opérateur `&` fournit cette adresse.

*Ce que donne l''oubli du `&`.* `scanf("%d", age)` compile souvent sans erreur,
mais `scanf` écrit à une adresse imprévisible : le programme produit n''importe
quoi ou s''arrête brutalement. C''est l''un des bugs les plus déroutants du
débutant.

*L''exception à connaître :* pour une chaîne, `scanf("%s", nom)` s''écrit **sans
`&`**, parce que le nom d''un tableau est **déjà** une adresse.
', NULL, 26),
      (v_chapitre_id, 'Simulation : les constantes et la mémoire', 4, 'interactif', '{
  "widget": "constantes-c",
  "consigne": "Déclare une constante par #define puis par const, et essaie de la modifier : le compilateur refuse dans les deux cas, avec deux messages différents que la simulation explique. Un second volet affiche la mémoire case par case, avec l''adresse de chaque variable, et te fait voir ce que scanf fait avec le & — et où il écrit quand tu l''oublies."
}', NULL, 10),
      (v_chapitre_id, 'Les fonctions d''entrée et de sortie', 5, 'texte', '
Elles viennent de `stdio.h`, et ce sont les deux instructions sans lesquelles un
programme ne communique pas.

### printf : afficher

```c
printf("Bonjour\n");
printf("Age : %d ans\n", age);
printf("%s a %.2f de moyenne\n", nom, moyenne);
```

Le premier argument est le **format**, une chaîne contenant du texte et des
**spécificateurs** commençant par `%`. Les arguments suivants fournissent les
valeurs, **dans l''ordre des `%`**.

### Les spécificateurs à connaître

| Code | Pour | Exemple |
| --- | --- | --- |
| `%d` | un entier | `printf("%d", 17)` |
| `%f` | un réel | `printf("%f", 13.5)` |
| `%.2f` | un réel à **2 décimales** | `13.50` |
| `%c` | un caractère | `printf("%c", ''M'')` |
| `%s` | une chaîne | `printf("%s", nom)` |

**Le `%.2f` est le plus utile en pratique** : sans lui, `%f` affiche six
décimales et une moyenne devient `13.500000`.

### Les caractères d''échappement

| Code | Effet |
| --- | --- |
| `\n` | aller à la ligne |
| `\t` | tabulation |
| `\"` | afficher un guillemet |
| `\\` | afficher une barre oblique inverse |

**Sans `\n`, tout s''affiche sur une seule ligne.**

### scanf : lire au clavier

```c
scanf("%d", &age);
scanf("%f", &moyenne);
scanf("%d %f", &age, &moyenne);     /* deux valeurs d''un coup */
scanf("%s", nom);                   /* une chaîne : pas de & */
```

### Les quatre règles de scanf

**Le `&` devant chaque variable**, sauf pour une chaîne.

**Le bon spécificateur** : `%d` pour un `int`, `%f` pour un `float`. Lire un
`float` avec `%d` range n''importe quoi.

**Pas de `\n` dans le format d''un `scanf`** : il ferait attendre le programme
sans raison.

**Un message avant chaque `scanf`.** Sinon l''utilisateur fait face à un écran
noir et muet. C''est une question de politesse du programme, et le correcteur y
est sensible.

### Le schéma de tout programme C

```c
#include <stdio.h>

int main()
{
    int a, b, somme;

    printf("Premier nombre : ");      /* 1. demander */
    scanf("%d", &a);

    printf("Second nombre : ");
    scanf("%d", &b);

    somme = a + b;                     /* 2. traiter */

    printf("Somme : %d\n", somme);     /* 3. afficher */

    return 0;
}
```

**Demander, traiter, afficher.** C''est le squelette de presque tout exercice
d''examen.

---

**Exercice corrigé**

*Écrire un programme C qui lit le nom d''un élève et ses trois notes, puis affiche
son nom, sa moyenne à deux décimales et sa mention.*

**Correction.**

```c
#include <stdio.h>

int main()
{
    char nom[30];
    float n1, n2, n3, moyenne;

    printf("Nom de l''eleve : ");
    scanf("%s", nom);                  /* une chaine : pas de & */

    printf("Les trois notes : ");
    scanf("%f %f %f", &n1, &n2, &n3);  /* des float : & et %f */

    moyenne = (n1 + n2 + n3) / 3;

    printf("\n%s : %.2f de moyenne\n", nom, moyenne);

    if (moyenne >= 16)
        printf("Mention : Tres bien\n");
    else if (moyenne >= 14)
        printf("Mention : Bien\n");
    else if (moyenne >= 12)
        printf("Mention : Assez bien\n");
    else if (moyenne >= 10)
        printf("Mention : Passable\n");
    else
        printf("Mention : Ajourne\n");

    return 0;
}
```

*Les cinq points vérifiés par le correcteur.*

`char nom[30]` : en C, une chaîne est un **tableau de caractères**.

**Pas de `&`** devant `nom`, mais un `&` devant chaque note.

Le **`%f`** pour des `float`, et non `%d`.

Le **`%.2f`** à l''affichage, pour éviter `13.666667`.

Les tests **du plus haut au plus bas**, comme en LDA.

*Les accents sont volontairement absents des chaînes affichées : la console de
Windows les rend mal, et les manuels camerounais écrivent « Tres bien » sans
accent pour cette raison.*
', NULL, 30),
      (v_chapitre_id, 'Simulation : printf et scanf', 6, 'interactif', '{
  "widget": "printf-scanf",
  "consigne": "Compose une ligne de printf en plaçant des spécificateurs et des variables, et la console affiche le résultat exact. Mets un %d devant un float, oublie un argument, enlève le \\n : la simulation te montre l''affichage absurde que cela produit. Pour le scanf, tape une valeur au clavier et regarde où elle atterrit en mémoire — avec le & puis sans, pour voir la différence."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 23', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Comment déclare-t-on un entier nommé age en C ?",
      "choix": [
        "age : entier ;",
        "int age ;",
        "entier age ;",
        "var age = int ;"
      ],
      "bonne": 1,
      "explication": "Le type d''abord, puis le nom, puis le point-virgule. Et toute variable doit être déclarée avant usage."
    },
    {
      "question": "Pourquoi scanf exige-t-il un & devant la variable ?",
      "choix": [
        "C''est une convention d''écriture",
        "Parce que scanf doit savoir OÙ ranger la valeur en mémoire : le & donne l''adresse",
        "Pour accélérer la lecture",
        "Pour convertir le type"
      ],
      "bonne": 1,
      "explication": "printf n''a besoin que de la valeur, scanf a besoin de l''adresse. L''exception : une chaîne, dont le nom est déjà une adresse."
    },
    {
      "question": "Que vaut r après float r; int a=7, b=2; r = a / b; ?",
      "choix": [
        "3,5",
        "3",
        "4",
        "0"
      ],
      "bonne": 1,
      "explication": "Entre deux entiers, le C fait une division ENTIÈRE et jette le reste. Il faut écrire (float) a / b."
    },
    {
      "question": "Quel spécificateur affiche un réel avec deux décimales ?",
      "choix": [
        "%d",
        "%.2f",
        "%2f",
        "%s"
      ],
      "bonne": 1,
      "explication": "Sans le .2, un %f affiche six décimales et une moyenne devient 13.500000."
    },
    {
      "question": "Comment déclare-t-on une chaîne de caractères en C ?",
      "choix": [
        "string nom ;",
        "char nom[30] ;",
        "chaine nom ;",
        "text nom ;"
      ],
      "bonne": 1,
      "explication": "Le C n''a pas de type chaîne : une chaîne est un TABLEAU de char. C''est une vraie différence avec le LDA."
    },
    {
      "question": "Quelle est la différence entre ''A'' et « A » écrit entre guillemets doubles en C ?",
      "choix": [
        "Aucune",
        "''A'' est un caractère d''un octet, « A » entre guillemets doubles est une chaîne de deux octets avec son marqueur de fin",
        "''A'' est une chaîne",
        "« A » entre guillemets doubles n''existe pas"
      ],
      "bonne": 1,
      "explication": "Apostrophes simples pour un caractère, guillemets doubles pour une chaîne. Écrire char c = « A » avec des guillemets doubles est une erreur de type."
    },
    {
      "question": "Que vaut une variable int non initialisée en C ?",
      "choix": [
        "0",
        "Ce qui traînait en mémoire : une valeur imprévisible",
        "1",
        "Rien, le programme refuse de compiler"
      ],
      "bonne": 1,
      "explication": "C''est pourquoi on initialise à la déclaration : int compteur = 0; évite des bugs incompréhensibles."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 23, Les fonctions d''entrée et de sortie en C.', v_nom;
  END LOOP;
END $inf7$;
