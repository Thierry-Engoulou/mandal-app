-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 20 : Les structures de données
-- Module 3 : Algorithme et programmation — 8 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 20;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les structures de données', 20, 'Module 3 : Algorithme et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 20 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 20 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les structures de données', 1, 'texte', '
Jusqu''ici, nos variables ne contenaient **qu''une seule valeur**. Pour gérer
trente élèves, il faut mieux.

### Ce qu''est une structure de données

Une **structure de données** est une **façon d''organiser plusieurs valeurs** en
mémoire, de manière à pouvoir les **ranger et les retrouver** efficacement.

### Les cinq structures à citer

Le programme demande d''en **citer cinq**. Voici les cinq attendues, avec leur
principe.

**1. Le tableau.** Des cases de **même type**, rangées côte à côte et repérées
par un **indice** numérique. C''est la structure la plus utilisée, et le
programme lui consacre deux unités.

**2. L''enregistrement.** Un groupe de **champs de types différents** décrivant
un même objet, repérés par un **nom**. Le second à décrire au programme.

**3. La liste.** Une suite d''éléments **chaînés** : chacun connaît le suivant.
Elle peut **grandir et rétrécir** pendant l''exécution, contrairement au tableau.

**4. La pile.** Une structure **LIFO** — *Last In, First Out* : **le dernier
entré est le premier sorti**. Comme une pile d''assiettes : on prend celle du
dessus.

**5. La file.** Une structure **FIFO** — *First In, First Out* : **le premier
entré est le premier sorti**. Comme une file d''attente à la banque.

*On peut aussi citer l''**arbre**, dont chaque élément a plusieurs fils, et le
**graphe**, où les éléments sont reliés librement.*

### Le tableau de révision

| Structure | Comment on repère un élément | Les types |
| --- | --- | --- |
| **tableau** | par un **indice** | tous **identiques** |
| **enregistrement** | par un **nom de champ** | **différents** |
| **liste** | en suivant les chaînons | identiques |
| **pile** | seulement le dessus — **LIFO** | identiques |
| **file** | seulement le début — **FIFO** | identiques |

### Le moyen de ne pas confondre pile et file

La **pile** se remplit et se vide **du même côté** : c''est la pile de cahiers
sur le bureau du professeur, et c''est le dernier posé qu''il prend.

La **file** se remplit d''un côté et se vide de l''autre : c''est la queue au
guichet, et c''est le premier arrivé qui passe le premier.

---

**Exercice corrigé**

*Citer cinq structures de données, et préciser pour chacune en une phrase son
principe.*

**Correction.**

**Le tableau** : un ensemble de cases de **même type**, repérées par un
**indice** numérique.

**L''enregistrement** : un groupe de **champs de types différents** décrivant un
même objet, repérés par leur **nom**.

**La liste** : une suite d''éléments chaînés, qui peut **grandir et rétrécir**
pendant l''exécution.

**La pile** : une structure **LIFO**, où le **dernier entré est le premier
sorti**.

**La file** : une structure **FIFO**, où le **premier entré est le premier
sorti**.

*On accepte aussi l''arbre et le graphe à la place de l''une des trois dernières.*
', NULL, 26),
      (v_chapitre_id, 'Simulation : les cinq structures en action', 2, 'interactif', '{
  "widget": "cinq-structures",
  "consigne": "Les cinq structures s''affichent côte à côte, vides. Ajoute et retire des éléments dans chacune et regarde leur comportement diverger : le tableau garde ses cases numérotées, la liste s''allonge, la pile rend toujours le dernier entré, la file toujours le premier. Une file d''attente de banque et une pile de cahiers tournent en parallèle pour fixer l''image."
}', NULL, 10),
      (v_chapitre_id, 'La structure de données tableau', 3, 'texte', '
Le programme demande de la **décrire**. C''est aussi la structure sur laquelle
porte toute l''unité suivante.

### La définition

Un **tableau** est un **ensemble de cases de même type**, portant **un seul
nom**, et repérées par un **indice**.

Les trois mots qui le caractérisent : **même type**, **un seul nom**, **un
indice**.

### La déclaration

```
Variable
    notes : tableau[1..30] de réel ;
    noms  : tableau[1..30] de chaîne ;
```

On y lit **trois choses** : le **nom** du tableau, l''**intervalle des indices**,
et le **type** commun des cases.

### L''accès à une case

```
notes[1] ← 12.5
notes[7] ← 9
écrire(notes[7])
```

Le nom du tableau, puis l''indice **entre crochets**.

**Ne confonds pas l''indice et le contenu.** Dans `notes[3] = 14.5`, le **3** est
la **place**, le **14,5** est la **valeur**.

### La taille est fixée à la déclaration

C''est la grande limite du tableau : **on ne peut pas l''agrandir en cours de
route**. On déclare donc une taille maximale raisonnable, et on n''en utilise
qu''une partie.

```
Variable
    notes : tableau[1..100] de réel ;
    n : entier ;        { le nombre de cases réellement utilisées }
```

C''est précisément ce que la **liste** permet, et le tableau non.

### Le tableau et la boucle sont inséparables

Puisque l''indice est un **nombre**, il peut être le **compteur d''une boucle**.
C''est ce qui rend le tableau si puissant.

```
Pour i de 1 à n faire
    écrire("Note de l''élève ", i, " :")
    lire(notes[i])
FinPour
```

Trente saisies en quatre lignes. Avec trente variables séparées, c''est
impossible : on ne peut pas « ajouter 1 » au nom d''une variable.

### Le tableau à deux dimensions

Pour une grille — des notes par élève et par matière — on déclare deux
intervalles.

```
Variable
    notes : tableau[1..30, 1..8] de réel ;
```

On y accède par **deux indices** : `notes[5, 3]` est la note du cinquième élève
dans la troisième matière.

Le parcours demande **deux boucles imbriquées**.

### Le débordement

Avec `tableau[1..30]`, les indices **0** et **31** n''existent pas. Y accéder est
une faute : en LDA on dit que le tableau **déborde**, et dans un vrai programme
cela donne une valeur imprévisible ou arrête l''exécution.

---

**Exercice corrigé**

*Décrire la structure de données « tableau », puis écrire la déclaration d''un
tableau pouvant contenir les notes de 40 élèves et l''algorithme qui les saisit.*

**Correction.**

*La description.* Un tableau est un **ensemble de cases de même type**, portant
**un seul nom** et repérées par un **indice** numérique. Sa **taille est fixée à
la déclaration** et ne peut pas changer pendant l''exécution. On accède à une
case en écrivant le nom du tableau suivi de l''indice entre crochets.

*La déclaration :*

```
Variable
    notes : tableau[1..40] de réel ;
    i : entier ;
```

*La saisie :*

```
Pour i de 1 à 40 faire
    écrire("Note de l''élève ", i, " :")
    lire(notes[i])
FinPour
```

*Le type est **réel** et non entier, parce qu''une note vaut couramment 13,5.*
', NULL, 28),
      (v_chapitre_id, 'Figure : le tableau et l''enregistrement', 4, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 250" width="560" height="250">
<rect width="560" height="250" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le tableau et l&apos;enregistrement : deux façons de grouper</text>

<text x="140" y="48" text-anchor="middle" font-size="11" font-weight="700" fill="#2563eb">LE TABLEAU</text>
<text x="140" y="64" text-anchor="middle" font-size="9" fill="#64748b">des cases de MÊME type, repérées par un indice</text>
<g>
<rect x="24" y="76" width="46" height="34" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<rect x="70" y="76" width="46" height="34" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<rect x="116" y="76" width="46" height="34" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<rect x="162" y="76" width="46" height="34" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<rect x="208" y="76" width="46" height="34" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
</g>
<g font-size="12" font-family="monospace" font-weight="700" fill="#1e3a8a" text-anchor="middle">
<text x="47" y="99">12</text><text x="93" y="99">9</text><text x="139" y="99">15,5</text><text x="185" y="99">7</text><text x="231" y="99">18</text>
</g>
<g font-size="9" fill="#64748b" text-anchor="middle">
<text x="47" y="124">[1]</text><text x="93" y="124">[2]</text><text x="139" y="124">[3]</text><text x="185" y="124">[4]</text><text x="231" y="124">[5]</text>
</g>
<text x="140" y="148" text-anchor="middle" font-size="10" font-family="monospace" fill="#334155">notes : tableau[1..5] de réel</text>
<text x="140" y="166" text-anchor="middle" font-size="9" fill="#64748b">on y accède par notes[3]</text>

<text x="420" y="48" text-anchor="middle" font-size="11" font-weight="700" fill="#15803d">L&apos;ENREGISTREMENT</text>
<text x="420" y="64" text-anchor="middle" font-size="9" fill="#64748b">des champs de types DIFFÉRENTS, repérés par un nom</text>
<rect x="306" y="76" width="228" height="104" rx="4" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<line x1="306" y1="102" x2="534" y2="102" stroke="#86efac"/>
<line x1="306" y1="128" x2="534" y2="128" stroke="#86efac"/>
<line x1="306" y1="154" x2="534" y2="154" stroke="#86efac"/>
<line x1="404" y1="76" x2="404" y2="180" stroke="#15803d" stroke-width="1.2"/>
<g font-size="10" fill="#14532d">
<text x="316" y="94">matricule</text><text x="414" y="94">E101</text>
<text x="316" y="120">nom</text><text x="414" y="120">Mbida</text>
<text x="316" y="146">age</text><text x="414" y="146">17</text>
<text x="316" y="172">moyenne</text><text x="414" y="172">13,5</text>
</g>
<text x="420" y="200" text-anchor="middle" font-size="10" font-family="monospace" fill="#334155">eleve : Eleve</text>
<text x="420" y="218" text-anchor="middle" font-size="9" fill="#64748b">on y accède par eleve.nom</text>

<text x="280" y="242" text-anchor="middle" font-size="10" font-weight="700" fill="#0f172a">Le tableau groupe le MÊME, l&apos;enregistrement groupe le DIFFÉRENT.</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : manipuler un tableau', 5, 'interactif', '{
  "widget": "structure-tableau",
  "consigne": "Déclare un tableau en choisissant ses bornes et son type, puis remplis-le case par case. La simulation refuse une valeur du mauvais type et un indice hors des bornes, en te montrant précisément ce que le débordement toucherait en mémoire. Passe ensuite au tableau à deux dimensions : la grille apparaît, et deux boucles imbriquées la parcourent sous tes yeux."
}', NULL, 10),
      (v_chapitre_id, 'La structure de données enregistrement', 6, 'texte', '
Le tableau groupe des valeurs **de même nature**. L''enregistrement groupe des
valeurs **de natures différentes** qui décrivent **un même objet**.

### La définition

Un **enregistrement** est un **ensemble de champs, éventuellement de types
différents**, regroupés sous **un seul nom** et décrivant un même objet.

On l''appelle aussi **structure** — c''est le mot du langage C.

### Pourquoi il est nécessaire

Pour décrire un élève, il faut un matricule, un nom, un âge et une moyenne. Ces
quatre informations ne sont **pas du même type** : un tableau ne peut donc pas
les contenir.

Et elles **vont ensemble** : les séparer en quatre variables, ou en quatre
tableaux parallèles, c''est prendre le risque de les désynchroniser.

### La déclaration

En deux temps : on **définit le type**, puis on **déclare la variable**.

```
Type
    Eleve = Enregistrement
        matricule : chaîne ;
        nom : chaîne ;
        age : entier ;
        moyenne : réel ;
    FinEnregistrement ;

Variable
    e : Eleve ;
```

### L''accès aux champs

Par le **point** : le nom de la variable, un point, le nom du champ.

```
e.matricule ← "E101"
e.nom ← "Mbida"
e.age ← 17
e.moyenne ← 13.5

écrire(e.nom, " a ", e.moyenne, " de moyenne")
```

Chaque champ se comporte alors comme une variable ordinaire de son propre type.

### Le tableau d''enregistrements

C''est la combinaison qui résout presque tout problème de gestion.

```
Variable
    classe : tableau[1..40] de Eleve ;
```

On accède alors par **l''indice, puis le point** :

```
classe[5].nom ← "Ngono"
écrire(classe[5].moyenne)
```

Et le parcours garde la même forme :

```
Pour i de 1 à n faire
    écrire(classe[i].nom, " : ", classe[i].moyenne)
FinPour
```

C''est exactement une **table de base de données** : chaque case du tableau est
une **ligne**, chaque champ de l''enregistrement est une **colonne**. Le
rapprochement avec le module précédent n''est pas un hasard.

### Le tableau qui tranche

| | Tableau | Enregistrement |
| --- | --- | --- |
| les types | tous **identiques** | **différents** |
| on repère par | un **indice** numérique | un **nom** de champ |
| on accède par | des **crochets** | un **point** |
| il répond à | « le troisième **quoi** ? » | « le **nom** de quoi ? » |

---

**Exercice corrigé**

*Décrire la structure de données « enregistrement », puis définir un
enregistrement ARTICLE comportant une référence, une désignation, un prix
unitaire et une quantité en stock. Écrire enfin l''instruction qui affiche la
valeur totale du stock de cet article.*

**Correction.**

*La description.* Un enregistrement est un **ensemble de champs, éventuellement
de types différents**, regroupés sous un seul nom et décrivant un même objet. On
accède à chaque champ par le **nom de la variable suivi d''un point et du nom du
champ**.

*La définition :*

```
Type
    Article = Enregistrement
        reference : chaîne ;
        designation : chaîne ;
        prixUnitaire : réel ;
        quantiteStock : entier ;
    FinEnregistrement ;

Variable
    a : Article ;
```

*L''affichage de la valeur du stock :*

```
écrire("Valeur du stock : ", a.prixUnitaire * a.quantiteStock, " FCFA")
```

*Note la cohérence des types : `prixUnitaire` est **réel** parce qu''un prix peut
avoir des décimales, et `quantiteStock` est **entier** parce qu''on ne stocke pas
2,5 articles. C''est précisément ce qu''un tableau n''aurait pas permis.*
', NULL, 28),
      (v_chapitre_id, 'Simulation : construire un enregistrement', 7, 'interactif', '{
  "widget": "enregistrement",
  "consigne": "Définis un type enregistrement champ par champ, en choisissant les noms et les types, puis remplis une variable de ce type. La simulation te montre la différence avec un tableau en essayant d''y ranger les mêmes données — et en échouant sur le premier champ d''un autre type. Un dernier volet construit un tableau d''enregistrements et te fait remarquer qu''il ressemble trait pour trait à une table de base de données."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 20', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Citer cinq structures de données.",
      "choix": [
        "Entier, réel, caractère, chaîne, booléen",
        "Tableau, enregistrement, liste, pile, file",
        "Si, TantQue, Pour, Répéter, Selon",
        "Variable, constante, fonction, procédure, programme"
      ],
      "bonne": 1,
      "explication": "On accepte aussi l''arbre et le graphe. Les cinq premiers choix de l''autre réponse sont des TYPES, pas des structures."
    },
    {
      "question": "Dans une pile, quel élément sort en premier ?",
      "choix": [
        "Le premier entré",
        "Le dernier entré",
        "Le plus grand",
        "Celui du milieu"
      ],
      "bonne": 1,
      "explication": "LIFO, Last In First Out : comme une pile de cahiers, on prend celui du dessus. La file, elle, est FIFO."
    },
    {
      "question": "Qu''est-ce qu''un tableau ?",
      "choix": [
        "Un ensemble de champs de types différents",
        "Un ensemble de cases de même type, portant un seul nom et repérées par un indice",
        "Une suite d''éléments chaînés",
        "Une structure LIFO"
      ],
      "bonne": 1,
      "explication": "Trois mots le caractérisent : même type, un seul nom, un indice."
    },
    {
      "question": "Dans notes[3] = 14.5, que désigne le 3 ?",
      "choix": [
        "La valeur de la note",
        "La place de la case dans le tableau",
        "Le nombre de cases",
        "Le type de la case"
      ],
      "bonne": 1,
      "explication": "L''indice est la PLACE, le contenu est la VALEUR. On les confond souvent au début."
    },
    {
      "question": "Quelle est la grande limite du tableau ?",
      "choix": [
        "Il ne contient que des entiers",
        "Sa taille est fixée à la déclaration et ne peut pas changer",
        "On ne peut pas le parcourir",
        "Il est limité à dix cases"
      ],
      "bonne": 1,
      "explication": "C''est précisément ce que la liste permet : grandir et rétrécir pendant l''exécution."
    },
    {
      "question": "Qu''est-ce qu''un enregistrement ?",
      "choix": [
        "Une case de tableau",
        "Un ensemble de champs, éventuellement de types différents, décrivant un même objet",
        "Une ligne de code",
        "Une boucle"
      ],
      "bonne": 1,
      "explication": "On l''appelle aussi structure. Il résout ce que le tableau ne peut pas : grouper des informations de natures différentes."
    },
    {
      "question": "Comment accède-t-on au nom d''un élève rangé dans classe[5] ?",
      "choix": [
        "classe[5][nom]",
        "classe[5].nom",
        "classe.nom[5]",
        "nom(classe, 5)"
      ],
      "bonne": 1,
      "explication": "L''indice entre crochets pour la case du tableau, puis le point pour le champ de l''enregistrement."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 20, Les structures de données.', v_nom;
  END LOOP;
END $inf7$;
