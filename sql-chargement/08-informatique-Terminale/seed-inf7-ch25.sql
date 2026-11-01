-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 25 : Manipulation d'un tableau en langage C
-- Module 3 : Algorithme et programmation — 9 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 25;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Manipulation d''un tableau en langage C', 25, 'Module 3 : Algorithme et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 25 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 25 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Déclarer et parcourir un tableau en langage C', 1, 'texte', '
Dernier chapitre du programme, et il réunit tout : les tableaux du chapitre 21
et le langage C des trois derniers.

### La déclaration

```c
int notes[30];
float moyennes[50];
char nom[30];
```

Entre crochets, **le nombre de cases** — et non les bornes des indices comme en
LDA.

**La taille doit être une constante connue à la compilation.** On écrit donc :

```c
#define TAILLE 50
int notes[TAILLE];
```

### L''erreur de traduction la plus coûteuse

**En C, les indices d''un tableau de n cases vont de 0 à n−1.**

Avec `int notes[5];`, les cases valides sont `notes[0]`, `notes[1]`, `notes[2]`,
`notes[3]` et `notes[4]`. **`notes[5]` n''existe pas.**

Le LDA écrivait `tableau[1..5]` et parcourait de 1 à 5. **Le C parcourt de 0 à
4.** Toute traduction d''algorithme doit opérer ce **décalage de un**, et c''est
là que la moitié des copies perdent des points.

Et le C est impitoyable : **il ne vérifie pas les indices**. Écrire `notes[5]`
compile sans un mot, puis lit ou écrit dans une zone de mémoire qui ne vous
appartient pas. Le programme donne un résultat absurde, ou s''arrête
brutalement — c''est le fameux *segmentation fault*.

### Le parcours de référence

```c
for (i = 0 ; i < n ; i++)
{
    /* traiter notes[i] */
}
```

**Retiens cette ligne par cœur** : `i = 0`, et `i < n` — avec un `<` **strict**,
et non `<=`. Écrire `i <= n` déborde d''une case à chaque fois.

### La saisie et l''affichage

```c
#include <stdio.h>
#define TAILLE 100

int main()
{
    float notes[TAILLE];
    int n, i;

    printf("Combien d''eleves ? ");
    scanf("%d", &n);

    for (i = 0 ; i < n ; i++)
    {
        printf("Note de l''eleve %d : ", i + 1);
        scanf("%f", &notes[i]);
    }

    for (i = 0 ; i < n ; i++)
    {
        printf("Eleve %d : %.2f\n", i + 1, notes[i]);
    }

    return 0;
}
```

Deux détails professionnels dans ce code. Le **`&notes[i]`** dans le `scanf` :
une case de tableau est une variable ordinaire, elle a donc besoin de son `&`.
Et le **`i + 1`** dans les messages : l''utilisateur compte ses élèves à partir
de 1, même si la machine compte à partir de 0.

### L''initialisation à la déclaration

```c
int tab[5] = {12, 9, 15, 7, 18};
int zeros[100] = {0};        /* toutes les cases à 0 */
```

La seconde forme est pratique : **mettre 0 dans la première case suffit, le
compilateur remplit le reste de zéros**.

### La somme et la moyenne

```c
somme = 0;                         /* initialiser */
for (i = 0 ; i < n ; i++)
    somme += notes[i];             /* accumuler */
moyenne = somme / n;               /* exploiter */
```

Le schéma **initialiser, accumuler, exploiter** du chapitre 21, mot pour mot.

**Mais attention** : avec `somme` et `n` déclarés `int`, la division est entière.
Il faut `float somme;` ou `(float) somme / n`.

---

**Exercice corrigé**

*Écrire un programme C qui lit les notes de n élèves, affiche la moyenne de la
classe et le nombre d''élèves ayant la moyenne.*

**Correction.**

```c
#include <stdio.h>
#define TAILLE 100

int main()
{
    float notes[TAILLE], somme, moyenne;
    int n, i, nbAdmis;

    do
    {
        printf("Nombre d''eleves (1 a %d) : ", TAILLE);
        scanf("%d", &n);
    }
    while (n < 1 || n > TAILLE);

    for (i = 0 ; i < n ; i++)
    {
        printf("Note de l''eleve %d : ", i + 1);
        scanf("%f", &notes[i]);
    }

    somme = 0;
    nbAdmis = 0;

    for (i = 0 ; i < n ; i++)
    {
        somme += notes[i];
        if (notes[i] >= 10)
            nbAdmis++;
    }

    moyenne = somme / n;

    printf("\nMoyenne de la classe : %.2f\n", moyenne);
    printf("Eleves ayant la moyenne : %d\n", nbAdmis);

    return 0;
}
```

*Les cinq points vérifiés par le correcteur.*

Le **`do … while` de contrôle de saisie**, qui empêche un `n` hors des bornes du
tableau et au passage une division par zéro.

Le parcours **`i = 0 ; i < n`**, avec le `<` strict.

Le **`&notes[i]`** dans le `scanf`.

Les **deux accumulateurs initialisés** avant la boucle.

Le **`somme` déclaré `float`**, sans quoi `somme / n` ferait une division
entière.
', NULL, 30),
      (v_chapitre_id, 'Figure : les indices en LDA et en C', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 230" width="560" height="230">
<rect width="560" height="230" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le piège des indices : LDA contre langage C</text>

<text x="140" y="48" text-anchor="middle" font-size="11" font-weight="700" fill="#2563eb">En LDA</text>
<text x="140" y="64" text-anchor="middle" font-size="9" font-family="monospace" fill="#334155">tab : tableau[1..5] de entier</text>
<g>
<rect x="24" y="76" width="46" height="32" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<rect x="70" y="76" width="46" height="32" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<rect x="116" y="76" width="46" height="32" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<rect x="162" y="76" width="46" height="32" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<rect x="208" y="76" width="46" height="32" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
</g>
<g font-size="12" font-family="monospace" font-weight="700" fill="#1e3a8a" text-anchor="middle">
<text x="47" y="98">12</text><text x="93" y="98">9</text><text x="139" y="98">15</text><text x="185" y="98">7</text><text x="231" y="98">18</text>
</g>
<g font-size="10" font-weight="700" fill="#2563eb" text-anchor="middle">
<text x="47" y="124">1</text><text x="93" y="124">2</text><text x="139" y="124">3</text><text x="185" y="124">4</text><text x="231" y="124">5</text>
</g>
<text x="140" y="148" text-anchor="middle" font-size="9" fill="#475569">les indices vont de 1 à 5</text>
<rect x="24" y="160" width="230" height="26" rx="3" fill="#eff6ff" stroke="#60a5fa"/>
<text x="139" y="177" text-anchor="middle" font-size="9" font-family="monospace" fill="#1e40af">Pour i de 1 à 5 faire … tab[i]</text>

<text x="420" y="48" text-anchor="middle" font-size="11" font-weight="700" fill="#b91c1c">En langage C</text>
<text x="420" y="64" text-anchor="middle" font-size="9" font-family="monospace" fill="#334155">int tab[5] ;</text>
<g>
<rect x="304" y="76" width="46" height="32" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.4"/>
<rect x="350" y="76" width="46" height="32" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.4"/>
<rect x="396" y="76" width="46" height="32" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.4"/>
<rect x="442" y="76" width="46" height="32" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.4"/>
<rect x="488" y="76" width="46" height="32" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.4"/>
</g>
<g font-size="12" font-family="monospace" font-weight="700" fill="#7f1d1d" text-anchor="middle">
<text x="327" y="98">12</text><text x="373" y="98">9</text><text x="419" y="98">15</text><text x="465" y="98">7</text><text x="511" y="98">18</text>
</g>
<g font-size="10" font-weight="700" fill="#b91c1c" text-anchor="middle">
<text x="327" y="124">0</text><text x="373" y="124">1</text><text x="419" y="124">2</text><text x="465" y="124">3</text><text x="511" y="124">4</text>
</g>
<text x="420" y="148" text-anchor="middle" font-size="9" fill="#475569">les indices vont de 0 à 4</text>
<rect x="304" y="160" width="230" height="26" rx="3" fill="#fef2f2" stroke="#f87171"/>
<text x="419" y="177" text-anchor="middle" font-size="9" font-family="monospace" fill="#991b1b">for (i = 0 ; i &lt; 5 ; i++) … tab[i]</text>

<text x="280" y="210" text-anchor="middle" font-size="10" font-weight="700" fill="#0f172a">Même tableau, mêmes valeurs — mais tab[5] existe en LDA et déborde en C.</text>
<text x="280" y="224" text-anchor="middle" font-size="9" fill="#64748b">En C, un tableau de n cases a ses indices de 0 à n−1. C&apos;est l&apos;erreur de traduction la plus coûteuse.</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : le tableau en C', 3, 'interactif', '{
  "widget": "tableau-c",
  "consigne": "Un tableau LDA et sa traduction en C s''affichent côte à côte, avec leurs indices respectifs. Traduis le parcours : garde « de 1 à n » et la simulation te montre la première case oubliée et la case fantôme lue après la fin. Écris i <= n et vois le débordement toucher la mémoire voisine, avec le segmentation fault à la clé. Un volet mémoire montre ce que contient réellement tab[5] dans un tableau de cinq cases."
}', NULL, 10),
      (v_chapitre_id, 'La recherche séquentielle en langage C', 4, 'texte', '
C''est l''exercice de traduction le plus demandé : l''algorithme du chapitre 21,
porté en C.

### Le programme complet

```c
#include <stdio.h>
#define TAILLE 100

int main()
{
    int tab[TAILLE];
    int n, i, x;
    int trouve;                    /* la variable drapeau */

    printf("Combien de valeurs ? ");
    scanf("%d", &n);

    for (i = 0 ; i < n ; i++)
    {
        printf("Valeur %d : ", i + 1);
        scanf("%d", &tab[i]);
    }

    printf("Quelle valeur cherchez-vous ? ");
    scanf("%d", &x);

    trouve = 0;                    /* faux */
    i = 0;

    while (i < n && trouve == 0)
    {
        if (tab[i] == x)
            trouve = 1;            /* vrai */
        else
            i++;
    }

    if (trouve == 1)
        printf("Valeur trouvee a la position %d\n", i + 1);
    else
        printf("Valeur absente du tableau\n");

    return 0;
}
```

### Les cinq points de traduction

**Le drapeau est un `int`**, pas un booléen : le C de base n''a pas ce type. On
utilise **0 pour faux et 1 pour vrai**.

**Le `et` devient `&&`**, et le `trouve = faux` de la condition devient `trouve
== 0` avec **deux signes égal**.

**L''incrémentation reste dans le `else`**, pour la même raison qu''en LDA : au
tour où l''on trouve, `i` doit conserver la position.

**Le parcours part de 0 et teste `i < n`.**

**L''affichage ajoute 1 à la position** : la case `tab[1]` est la **deuxième**
valeur pour l''utilisateur. Oublier ce `+ 1` donne une position fausse, et c''est
une faute fréquente.

### La version avec un break

Le C offre un raccourci que le LDA n''a pas : l''instruction **`break`** sort
immédiatement de la boucle.

```c
trouve = 0;
for (i = 0 ; i < n ; i++)
{
    if (tab[i] == x)
    {
        trouve = 1;
        break;                     /* on sort tout de suite */
    }
}
```

Elle est plus courte, et elle fonctionne. **Mais en examen, préfère la version
avec le `while` et le drapeau** : c''est celle que le programme demande, et c''est
elle qui montre que la variable drapeau a été comprise.

### Le coût, en C comme en LDA

Meilleur cas, la valeur est en `tab[0]` : **une** comparaison. Pire cas, elle est
absente : **n** comparaisons. En moyenne, **n/2**.

---

**Exercice corrigé**

*Traduire en langage C l''algorithme de recherche séquentielle ci-dessous, et
indiquer précisément les transformations opérées.*

```
trouve ← faux
i ← 1
TantQue (i <= N) et (trouve = faux) faire
    Si numero[i] = x alors
        trouve ← vrai
    Sinon
        i ← i + 1
    Finsi
FinTantQue
```

**Correction.**

```c
int trouve = 0;
int i = 0;

while (i < N && trouve == 0)
{
    if (numero[i] == x)
        trouve = 1;
    else
        i++;
}

if (trouve == 1)
    printf("Trouve a la position %d\n", i + 1);
else
    printf("Absent\n");
```

*Les six transformations, à citer en copie.*

`trouve ← faux` devient **`trouve = 0`**, le C n''ayant pas de type booléen.

`i ← 1` devient **`i = 0`**, parce que les indices du C commencent à 0.

`i <= N` devient **`i < N`**, conséquence directe du décalage précédent.

`et` devient **`&&`**.

`trouve = faux` devient **`trouve == 0`**, avec deux signes égal puisqu''il s''agit
d''une **comparaison** et non d''une affectation.

`numero[i] = x` devient **`numero[i] == x`**, pour la même raison.

*Et à l''affichage, la position est `i + 1` pour retrouver la numérotation
humaine.*
', NULL, 30),
      (v_chapitre_id, 'Simulation : la recherche séquentielle en C', 5, 'interactif', '{
  "widget": "recherche-c",
  "consigne": "L''algorithme LDA et le programme C tournent en parallèle sur le même tableau, et tu vois les deux compteurs avancer — l''un à partir de 1, l''autre à partir de 0. Oublie le décalage, oublie le i + 1 à l''affichage, écris un seul = dans la condition : la simulation te montre chaque conséquence séparément, et les deux programmes cessent de dire la même chose."
}', NULL, 10),
      (v_chapitre_id, 'Identifier, interpréter et corriger les erreurs', 6, 'texte', '
Le programme demande explicitement ces trois actions, et elles valent des points
à chaque session.

### Les trois familles d''erreurs

**Les erreurs de syntaxe**, ou de compilation. Le code viole les règles du
langage : le compilateur **refuse** de produire l''exécutable et indique la
ligne. Ce sont les plus faciles.

**Les erreurs d''exécution**. Le programme compile, puis **s''arrête
brutalement** : division par zéro, débordement de tableau, accès à une adresse
interdite.

**Les erreurs de logique**. Le programme compile, tourne jusqu''au bout, et donne
**un résultat faux**. Ce sont les plus dangereuses, parce que **rien ne les
signale**.

### Les erreurs de syntaxe et leur message

| Le message | La cause |
| --- | --- |
| `expected '';'' before …` | point-virgule oublié **à la ligne précédente** |
| `''x'' undeclared` | variable non déclarée, ou mal orthographiée |
| `expected ''}'' at end of input` | une accolade fermante manque |
| `undefined reference to printf` | `#include <stdio.h>` oublié |
| `undefined reference to main` | `main` mal écrite ou fichier mal nommé |

**La règle d''or : le compilateur signale souvent le point-virgule manquant à la
ligne SUIVANTE.** Quand le message est incompréhensible, regarde **au-dessus**.

**Et corrige toujours la première erreur d''abord.** Une seule faute en entraîne
souvent dix dans la liste ; la première corrigée, les autres disparaissent.

### Les erreurs de logique à connaître

**Le `=` au lieu de `==`** dans un `if` ou un `while`. Le test est toujours vrai
et la variable est écrasée. **Aucun message.**

**Le `;` après un `if` ou un `while`.** La structure n''a plus de corps : le `if`
ne fait rien, le `while` tourne indéfiniment. **Aucun message.**

**Le `break` oublié dans un `switch`.** L''exécution dégringole dans les cas
suivants.

**Le parcours `i <= n` au lieu de `i < n`.** Débordement d''une case.

**L''indice parti de 1 au lieu de 0.** La première valeur est ignorée.

**L''accumulateur non initialisé.** La somme contient n''importe quoi.

**La division entière.** `somme / n` avec deux `int` donne 13 au lieu de 13,67.

### La méthode de correction

**Lire le message**, et retenir le **numéro de ligne**.

**Regarder la ligne indiquée et celle du dessus.**

**Corriger la première erreur seulement**, puis recompiler.

**Si le programme compile mais répond faux**, faire la **trace d''exécution** du
chapitre 21 : c''est elle qui révèle les erreurs de logique, ou le **débogueur**
de l''IDE, qui la fait automatiquement.

**Tester les cas limites** : zéro élément, un seul élément, la valeur cherchée en
première et en dernière position, des valeurs négatives.

---

**Exercice corrigé**

*Le programme suivant doit afficher la somme des n premières valeurs d''un tableau.
Identifier les erreurs, interpréter chacune, et donner la version corrigée.*

```c
#include <stdio.h>

int main()
{
    int tab[5] = {4, 8, 1, 9, 3}
    int i, n = 5, somme;

    for (i = 1 ; i <= n ; i++);
    {
        somme = somme + tab[i]
    }

    if (somme = 25)
        printf("La somme vaut 25");

    return 0;
}
```

**Correction. Six erreurs.**

**1. Ligne de la déclaration du tableau : point-virgule manquant** après
`{4, 8, 1, 9, 3}`. *Erreur de syntaxe.* Le compilateur la signalera à la ligne
**suivante**, celle du `int i, n = 5, somme;`.

**2. `somme` n''est pas initialisée.** *Erreur de logique.* En C, une variable non
initialisée contient une valeur imprévisible : la somme est fausse dès le départ.
Il faut `somme = 0;`.

**3. `i = 1` au lieu de `i = 0`.** *Erreur de logique.* La première case
`tab[0]`, qui vaut 4, n''est jamais ajoutée.

**4. `i <= n` au lieu de `i < n`.** *Erreur d''exécution.* Avec n = 5, la boucle
lit `tab[5]`, qui n''existe pas dans un tableau de cinq cases : le programme lit
la mémoire voisine.

**5. Point-virgule après le `for`.** *Erreur de logique, et la plus
sournoise.* Le `for` n''a plus de corps : il tourne à vide, et le bloc entre
accolades s''exécute **une seule fois**, après la boucle, avec `i` valant 6.

**6. `if (somme = 25)` au lieu de `==`.** *Erreur de logique.* Le `=` **affecte**
25 à `somme`, puis juge la valeur 25 vraie : le message s''affiche **toujours**, et
la vraie somme est écrasée.

**La version corrigée :**

```c
#include <stdio.h>

int main()
{
    int tab[5] = {4, 8, 1, 9, 3};      /* 1. le point-virgule */
    int i, n = 5, somme;

    somme = 0;                          /* 2. l''initialisation */

    for (i = 0 ; i < n ; i++)           /* 3, 4 et 5. de 0, strictement, sans ; */
    {
        somme = somme + tab[i];
    }

    if (somme == 25)                    /* 6. deux signes egal */
        printf("La somme vaut 25\n");

    printf("Somme : %d\n", somme);

    return 0;
}
```

*Vérification :* 4 + 8 + 1 + 9 + 3 = **25**. Le message s''affiche, et cette
fois-ci parce que c''est vrai.
', NULL, 32),
      (v_chapitre_id, 'Simulation : le chasseur d''erreurs', 7, 'interactif', '{
  "widget": "erreurs-c",
  "consigne": "Des programmes C truffés d''erreurs s''affichent, et tu dois cliquer sur la ligne fautive, dire de quelle famille elle relève, puis la corriger. La simulation affiche le message exact du compilateur — y compris le décalage d''une ligne du point-virgule manquant — et, pour les erreurs de logique silencieuses, exécute le programme avant et après pour te montrer le résultat faux."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — Partie III, algorithmique et programmation (2023)', 8, 'texte', '
**Partie III — Algorithmique et programmation — 6 points**

Voici l''intégralité de la troisième partie de l''épreuve, dans sa structure
officielle : d''abord un exercice d''algorithmique, puis un exercice de
programmation en C. Les six points de l''épreuve se jouent ici.

---

### Exercice 1 — Algorithmique (3 points)

*Le club informatique d''un lycée gère la liste des numéros de ses membres dans
un tableau `numero` de N cases. L''algorithme suivant cherche si un numéro saisi
appartient à la liste.*

```
lire(x)
trouve ← faux
i ← 1
TantQue (i <= N) et (trouve = faux) faire
    Si numero[i] = x alors
        trouve ← vrai
    Sinon
        i ← i + 1
    Finsi
FinTantQue
Si trouve = vrai alors
    écrire("Membre numéro ", i)
Sinon
    écrire("Non membre")
Finsi
```

**1.1.** Donner le nom de l''algorithme mis en œuvre. **(0,5 pt)**

**1.2.** Identifier la variable drapeau et justifier votre réponse. **(1 pt)**

**1.3.** Réécrire la boucle en utilisant la structure `Répéter … Jusqu''à`.
**(1,5 pt)**

---

### Exercice 2 — Programmation (3 points)

**2.1.** Donner la signification du sigle **IDE** et citer un IDE utilisable
pour le langage C. **(0,5 pt)**

**2.2.** Traduire l''algorithme de l''exercice 1 en langage C. **(2 pt)**

**2.3.** Le programme affiche « Membre numéro 3 » alors que le numéro cherché se
trouve en deuxième position. Identifier l''erreur et la corriger. **(0,5 pt)**

---
---

## Correction détaillée

### 1.1. Le nom de l''algorithme *(0,5 pt)*

Il s''agit de la **recherche séquentielle** — on accepte aussi « recherche
linéaire ».

*Justification à écrire en une ligne :* le tableau est parcouru **case par
case**, de la première vers la dernière, jusqu''à trouver la valeur ou épuiser le
tableau. On ne suppose pas le tableau trié.

### 1.2. La variable drapeau *(1 pt)*

La variable drapeau est **`trouve`**.

*Les trois éléments de justification :*

elle est de type **booléen**, et ne prend donc que les valeurs vrai ou faux ;

elle est **initialisée à faux avant la boucle**, et ne passe à vrai qu''au moment
où la valeur est trouvée : elle **mémorise** donc qu''un évènement s''est produit ;

elle **figure dans la condition de la boucle**, ce qui permet d''en **sortir dès
que la valeur est trouvée**, sans parcourir le reste du tableau.

### 1.3. La réécriture avec Répéter … Jusqu''à *(1,5 pt)*

```
lire(x)
trouve ← faux
i ← 1
Répéter
    Si numero[i] = x alors
        trouve ← vrai
    Sinon
        i ← i + 1
    Finsi
Jusqu''à (i > N) ou (trouve = vrai)

Si trouve = vrai alors
    écrire("Membre numéro ", i)
Sinon
    écrire("Non membre")
Finsi
```

*Les deux transformations à justifier, et c''est là que se trouvent les points.*

**La condition est inversée.** Le `TantQue` **restait** dans la boucle tant que
`(i <= N) et (trouve = faux)`. Le `Répéter` en **sort** quand la condition
devient vraie : il faut donc écrire la **négation** de la précédente. Le
« et » devient « **ou** », `i <= N` devient `i > N`, et `trouve = faux` devient
`trouve = vrai`.

**Le corps de la boucle est inchangé**, et l''incrémentation **reste dans le
`Sinon`**. Plusieurs corrigés en circulation la sortent du `Sinon` : la boucle
cesse alors de rendre la bonne position, et si l''on supprime l''incrémentation,
elle tourne indéfiniment.

*La réserve à mentionner pour une copie complète.* Le `Répéter` exécute son corps
**au moins une fois** : si le tableau était vide, c''est-à-dire N = 0, il lirait
`numero[1]`, qui n''existe pas. Le `TantQue` d''origine, lui, ne faisait aucun
tour. Un programme rigoureux encadre donc le `Répéter` par un test sur N.

### 2.1. Le sigle IDE *(0,5 pt)*

**IDE** signifie *Integrated Development Environment*, en français
**environnement de développement intégré**. C''est un logiciel qui regroupe en
une seule interface l''**éditeur de code**, le **compilateur** et le
**débogueur**.

*Un IDE pour le langage C :* **Code::Blocks**. *On accepte aussi Dev-C++, Visual
Studio ou Turbo C.*

### 2.2. La traduction en langage C *(2 pt)*

```c
#include <stdio.h>
#define N 50

int main()
{
    int numero[N];
    int i, x, nb;
    int trouve;

    printf("Nombre de membres : ");
    scanf("%d", &nb);

    for (i = 0 ; i < nb ; i++)
    {
        printf("Numero du membre %d : ", i + 1);
        scanf("%d", &numero[i]);
    }

    printf("Numero recherche : ");
    scanf("%d", &x);

    trouve = 0;
    i = 0;

    while (i < nb && trouve == 0)
    {
        if (numero[i] == x)
            trouve = 1;
        else
            i++;
    }

    if (trouve == 1)
        printf("Membre numero %d\n", i + 1);
    else
        printf("Non membre\n");

    return 0;
}
```

*Le barème se joue sur six transformations :*

le drapeau devient un **`int`**, avec **0 pour faux et 1 pour vrai**, le C de
base n''ayant pas de type booléen ;

`i ← 1` devient **`i = 0`**, et `i <= N` devient **`i < nb`**, parce que les
indices d''un tableau de n cases vont **de 0 à n−1** ;

le `et` devient **`&&`** ;

les comparaisons prennent **deux signes égal** : `numero[i] == x` et `trouve ==
0` ;

l''incrémentation **reste dans le `else`** ;

l''affichage utilise **`i + 1`** pour retrouver la numérotation humaine.

### 2.3. L''erreur et sa correction *(0,5 pt)*

*Le symptôme :* la position affichée est **supérieure d''une unité** à la vraie
position.

*La cause :* l''**incrémentation `i++` a été placée hors du `else`**, et s''exécute
donc **aussi au tour où la valeur est trouvée**. La variable `i` désigne alors la
case **suivante**.

```c
while (i < nb && trouve == 0)
{
    if (numero[i] == x)
        trouve = 1;
    i++;                    /* l''erreur : hors du else */
}
```

*La correction :* remettre l''incrémentation **dans le `else`**, de sorte que `i`
ne bouge plus dès que la valeur est trouvée.

```c
while (i < nb && trouve == 0)
{
    if (numero[i] == x)
        trouve = 1;
    else
        i++;                /* corrige */
}
```

*La vérification sur le cas donné.* Avec le numéro cherché en deuxième position,
donc dans `numero[1]` : au premier tour `numero[0]` diffère, `i` passe à 1 ; au
deuxième tour `numero[1]` correspond, `trouve` passe à 1 et **`i` reste à 1**.
L''affichage `i + 1` donne bien **« Membre numéro 2 »**.

*Avec l''erreur, `i` était passé à 2 et l''affichage donnait 3.*

---

### Ce que cette partie III enseigne pour les prochaines sessions

**Les mêmes quatre questions reviennent.** Nommer un algorithme, identifier une
variable drapeau, transformer une boucle en une autre, traduire en C. Travaillées
une fois sérieusement, elles valent les six points à chaque session.

**La transformation de boucle est le piège principal.** Inverser la condition, et
ne pas déplacer l''incrémentation : deux réflexes, 1,5 point.

**La traduction en C se joue sur le décalage des indices.** De 1 à N en LDA, de 0
à n−1 en C. Écris le `for (i = 0 ; i < n ; i++)` sans réfléchir, et ajoute le
`+ 1` à l''affichage.

**Le sigle IDE est un demi-point gratuit.** Ne le laisse jamais passer.
', NULL, 40),
      (v_chapitre_id, 'Quiz du chapitre 25', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Dans int tab[5]; quels sont les indices valides ?",
      "choix": [
        "De 1 à 5",
        "De 0 à 4",
        "De 0 à 5",
        "De 1 à 4"
      ],
      "bonne": 1,
      "explication": "En C, un tableau de n cases a ses indices de 0 à n−1. tab[5] n''existe pas, et le C ne le vérifie même pas."
    },
    {
      "question": "Quel parcours faut-il écrire pour un tableau de n cases en C ?",
      "choix": [
        "for (i = 1 ; i <= n ; i++)",
        "for (i = 0 ; i < n ; i++)",
        "for (i = 0 ; i <= n ; i++)",
        "for (i = 1 ; i < n ; i++)"
      ],
      "bonne": 1,
      "explication": "De 0, et avec un < STRICT. Retiens cette ligne par cœur : c''est elle qui fait la moitié des points de traduction."
    },
    {
      "question": "Comment représente-t-on une variable drapeau en C ?",
      "choix": [
        "Par un bool",
        "Par un int, avec 0 pour faux et 1 pour vrai",
        "Par un char",
        "Par un float"
      ],
      "bonne": 1,
      "explication": "Le C de base n''a pas de type booléen. Et la comparaison s''écrit trouve == 0, avec DEUX signes égal."
    },
    {
      "question": "Pourquoi afficher i + 1 et non i comme position trouvée ?",
      "choix": [
        "Pour éviter une erreur de compilation",
        "Parce que la case tab[1] est la deuxième valeur pour l''utilisateur, qui compte à partir de 1",
        "Pour accélérer le programme",
        "Ce n''est pas nécessaire"
      ],
      "bonne": 1,
      "explication": "La machine compte à partir de 0, l''humain à partir de 1. Oublier ce + 1 donne une position fausse."
    },
    {
      "question": "Quelle famille d''erreurs est la plus dangereuse ?",
      "choix": [
        "Les erreurs de syntaxe",
        "Les erreurs de logique, parce que le programme compile, tourne, et donne un résultat faux sans aucun message",
        "Les erreurs d''exécution",
        "Elles sont équivalentes"
      ],
      "bonne": 1,
      "explication": "Le = au lieu de ==, le ; après un if, la division entière : rien ne les signale. Seule la trace d''exécution les révèle."
    },
    {
      "question": "Le compilateur signale « expected '';'' » à la ligne 12. Où est l''erreur ?",
      "choix": [
        "À la ligne 12",
        "Le plus souvent à la ligne 11, celle du dessus",
        "À la ligne 13",
        "Dans le #include"
      ],
      "bonne": 1,
      "explication": "C''est la règle d''or du débogage en C : quand le message est incompréhensible, regarde AU-DESSUS. Et corrige toujours la première erreur d''abord."
    },
    {
      "question": "Au Bac 2023, quelles transformations fallait-il opérer pour passer du TantQue au Répéter ?",
      "choix": [
        "Aucune, le corps suffit",
        "Inverser la condition (le et devient ou, chaque comparaison s''inverse) et laisser l''incrémentation dans le Sinon",
        "Supprimer la variable drapeau",
        "Remplacer le tableau par une liste"
      ],
      "bonne": 1,
      "explication": "Deux réflexes, 1,5 point. Plusieurs corrigés en circulation sortent l''incrémentation du Sinon : la boucle cesse alors de rendre la bonne position."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 9 leçons ajoutées au chapitre 25, Manipulation d''un tableau en langage C.', v_nom;
  END LOOP;
END $inf7$;
