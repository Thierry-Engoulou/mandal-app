-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 21 : Manipulation d'un tableau
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
    WHERE programme_id = v_programme_id AND ordre = 21;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Manipulation d''un tableau', 21, 'Module 3 : Algorithme et programmation')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 21 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 21 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Parcourir un tableau pour la lecture et l''affichage', 1, 'texte', '
Le programme énumère quatre actions pour cette unité. Voici la première, et
c''est la base de toutes les autres.

### Le schéma de parcours

Un parcours de tableau s''écrit **toujours** de la même façon :

```
Pour i de 1 à n faire
    { faire quelque chose avec tab[i] }
FinPour
```

On utilise la boucle **`Pour`**, puisque le nombre de tours est **connu à
l''avance** : c''est la taille du tableau.

### La lecture — remplir le tableau

```
Algorithme : SaisieNotes

Variable
    notes : tableau[1..100] de réel ;
    n, i : entier ;

Début
    écrire("Combien d''élèves ?")
    lire(n)

    Pour i de 1 à n faire
        écrire("Note de l''élève ", i, " :")
        lire(notes[i])
    FinPour
Fin
```

Remarque l''affichage **avant** chaque lecture : sans lui, l''utilisateur se
retrouve devant un écran muet et ne sait pas quoi taper.

### L''affichage — parcourir le tableau rempli

```
Pour i de 1 à n faire
    écrire("Élève ", i, " : ", notes[i])
FinPour
```

### Le schéma avec accumulation

La plupart des traitements suivent ce modèle en trois temps, et il faut le
connaître par cœur :

```
somme ← 0                         { 1. initialiser }
Pour i de 1 à n faire
    somme ← somme + notes[i]      { 2. accumuler }
FinPour
moyenne ← somme / n               { 3. exploiter }
```

**Initialiser, accumuler, exploiter.** La somme, la moyenne, le comptage, le
maximum, la recherche : tout en sort.

### Un seul parcours pour plusieurs résultats

On peut calculer plusieurs choses en **un seul passage**. C''est le réflexe à
prendre.

```
somme ← 0
nbAdmis ← 0
Pour i de 1 à n faire
    somme ← somme + notes[i]
    Si notes[i] >= 10 alors
        nbAdmis ← nbAdmis + 1
    Finsi
FinPour
```

### Les trois précautions

**Vérifier que n est valide** avant de parcourir, et surtout avant de diviser
par n : une division par zéro arrête un programme.

**Respecter les bornes** : avec `tableau[1..100]`, un parcours `Pour i de 1 à
101` déborde.

**Initialiser les accumulateurs** à 0 avant la boucle. Sans cela, on ajoute à
une variable qui ne contient rien.

---

**Exercice corrigé**

*Écrire un algorithme qui lit les notes de n élèves, puis affiche la moyenne de
la classe et le nombre d''élèves ayant la moyenne.*

**Correction.**

```
Algorithme : BilanClasse

Variable
    notes : tableau[1..100] de réel ;
    n, i, nbAdmis : entier ;
    somme, moyenne : réel ;

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

    moyenne ← somme / n
    écrire("Moyenne de la classe : ", moyenne)
    écrire("Élèves ayant la moyenne : ", nbAdmis)
Fin
```

*Trois points qui valent des points.*

Le **`Répéter` de contrôle de saisie** empêche un `n` hors des bornes du
tableau, et au passage une division par zéro.

Les **deux accumulateurs initialisés à 0** avant la boucle.

Un **seul parcours** pour les deux calculs : on aurait pu écrire deux boucles,
une seule est plus courte et plus rapide.
', NULL, 28),
      (v_chapitre_id, 'Simulation : parcourir un tableau', 2, 'interactif', '{
  "widget": "parcours-tableau",
  "consigne": "Un tableau de notes s''affiche en cases numérotées, et le parcours avance case par case sous ton contrôle. La somme, le compteur et la moyenne se mettent à jour à droite, et la case courante s''éclaire. Oublie d''initialiser un accumulateur, ou fais déborder les bornes : la simulation te montre exactement ce que le résultat devient."
}', NULL, 10),
      (v_chapitre_id, 'La recherche séquentielle', 3, 'texte', '
C''est l''algorithme le plus demandé du programme, et il est tombé au
Baccalauréat 2023.

### Le problème

**Un tableau et une valeur. La valeur est-elle dans le tableau, et à quelle
place ?**

Le tableau n''est **pas trié** : il faut donc regarder les cases **une par une**,
d''où le nom de recherche **séquentielle**.

### La version naïve

```
trouve ← faux
Pour i de 1 à n faire
    Si tab[i] = x alors
        trouve ← vrai
    Finsi
FinPour
```

Elle fonctionne, mais elle **parcourt tout le tableau même après avoir
trouvé**. Sur mille éléments, c''est neuf cent quatre-vingt-dix-neuf
comparaisons inutiles.

### La bonne version, avec variable drapeau

```
Algorithme : RechercheSequentielle

Variable
    tab : tableau[1..100] de entier ;
    n, i, x : entier ;
    trouve : booléen ;

Début
    { … le tableau est supposé rempli, n cases utilisées … }

    écrire("Quelle valeur cherchez-vous ?")
    lire(x)

    trouve ← faux
    i ← 1

    TantQue (i <= n) et (trouve = faux) faire
        Si tab[i] = x alors
            trouve ← vrai
        Sinon
            i ← i + 1
        Finsi
    FinTantQue

    Si trouve = vrai alors
        écrire("Valeur trouvée à la position ", i)
    Sinon
        écrire("Valeur absente du tableau")
    Finsi
Fin
```

### Les quatre points à comprendre

**La boucle est un `TantQue`, et non un `Pour`.** On ne sait pas à l''avance
combien de tours il faudra : on s''arrête **dès qu''on a trouvé**.

**La condition a deux parties, reliées par `et`.** On continue tant qu''il reste
des cases **et** qu''on n''a pas trouvé. Oublier l''une des deux est une faute :
sans `i <= n`, on déborde du tableau ; sans `trouve = faux`, on ne s''arrête
jamais tôt.

**L''incrémentation est dans le `Sinon`.** C''est subtil et c''est essentiel : si
l''on trouve, on **ne doit pas** incrémenter, sinon `i` désignerait la case
suivante et la position affichée serait fausse.

**Le test final est obligatoire.** Sortir de la boucle ne dit pas **pourquoi**
on en est sorti : on peut avoir trouvé, ou avoir épuisé le tableau. Le `Si
trouve = vrai` tranche.

### Le coût

Dans le meilleur cas, la valeur est en première position : **une** comparaison.

Dans le pire cas, elle est en dernière position ou absente : **n**
comparaisons.

En moyenne, environ **n/2**. C''est pourquoi, sur de grands tableaux triés, on
préfère la recherche dichotomique — hors programme, mais bon à savoir.

---

**Exercice corrigé**

*Écrire l''algorithme de recherche séquentielle d''une valeur dans un tableau, et
expliquer pourquoi l''incrémentation se trouve dans le Sinon.*

**Correction.** L''algorithme est celui donné ci-dessus.

*Pourquoi l''incrémentation est dans le `Sinon`.*

Au moment où le test `tab[i] = x` réussit, la variable `i` contient **la
position de la valeur cherchée**. C''est cette position qu''on veut afficher.

Si l''on incrémentait `i` à chaque tour, y compris au tour où l''on trouve, `i`
désignerait la case **suivante** au moment du test final, et la position
affichée serait **fausse d''une unité**.

*La vérification sur un cas.* Avec `tab = [4, 9, 7]` et `x = 9` : au premier
tour, `tab[1] = 4` est différent de 9, donc `i` passe à 2. Au deuxième tour,
`tab[2] = 9` : `trouve` passe à vrai, et `i` **reste à 2**. L''algorithme affiche
« position 2 », ce qui est juste.

Avec une incrémentation systématique, il aurait affiché « position 3 ».
', NULL, 30),
      (v_chapitre_id, 'Simulation : la recherche séquentielle pas à pas', 4, 'interactif', '{
  "widget": "recherche-sequentielle",
  "consigne": "Un tableau s''affiche, tu choisis la valeur cherchée, et la recherche avance case par case sous ton contrôle : la case examinée s''éclaire, la comparaison s''affiche, le drapeau passe de faux à vrai au bon moment. Un compteur mesure le nombre de comparaisons, du meilleur cas au pire. Déplace l''incrémentation hors du Sinon et la simulation te montre la position affichée devenir fausse."
}', NULL, 10),
      (v_chapitre_id, 'La recherche du maximum et du minimum', 5, 'texte', '
Deuxième algorithme classique du programme, et le plus élégant.

### Le principe

On **suppose** que le premier élément est le plus grand, puis on **corrige**
chaque fois qu''on trouve mieux.

```
Algorithme : Maximum

Variable
    tab : tableau[1..100] de réel ;
    n, i : entier ;
    max : réel ;

Début
    { … le tableau est rempli, n cases utilisées … }

    max ← tab[1]

    Pour i de 2 à n faire
        Si tab[i] > max alors
            max ← tab[i]
        Finsi
    FinPour

    écrire("Le maximum est ", max)
Fin
```

### Les trois points à comprendre

**L''initialisation se fait avec `tab[1]`, et non avec 0.** C''est la faute
classique. Avec des températures négatives, ou des altitudes sous le niveau de
la mer, un maximum initialisé à 0 ne serait jamais dépassé et l''algorithme
répondrait 0.

**La boucle commence à 2.** La case 1 a déjà servi d''initialisation ; la
comparer à elle-même ne sert à rien. Commencer à 1 n''est pas faux, seulement
inutile.

**La boucle est un `Pour`.** Contrairement à la recherche séquentielle, il faut
ici parcourir **tout** le tableau : on ne peut pas savoir qu''on tient le maximum
avant d''avoir tout vu.

### Le minimum

Exactement le même algorithme, avec **deux changements** :

```
min ← tab[1]
Pour i de 2 à n faire
    Si tab[i] < min alors      { le > devient < }
        min ← tab[i]
    Finsi
FinPour
```

### Retrouver aussi la position

Souvent, on ne veut pas seulement la valeur mais **où elle se trouve**.

```
max ← tab[1]
posMax ← 1

Pour i de 2 à n faire
    Si tab[i] > max alors
        max ← tab[i]
        posMax ← i
    Finsi
FinPour

écrire("Le maximum est ", max, " en position ", posMax)
```

Les deux affectations vont **ensemble**, dans le même `Si` : oublier la seconde
donne une position qui ne correspond pas à la valeur.

### Les deux en un seul parcours

```
max ← tab[1]
min ← tab[1]

Pour i de 2 à n faire
    Si tab[i] > max alors
        max ← tab[i]
    Finsi
    Si tab[i] < min alors
        min ← tab[i]
    Finsi
FinPour
```

---

**Exercice corrigé**

*Écrire l''algorithme qui trouve la note la plus basse d''une classe et le rang de
l''élève concerné.*

**Correction.**

```
Algorithme : NoteLaPlusBasse

Variable
    notes : tableau[1..100] de réel ;
    n, i, posMin : entier ;
    min : réel ;

Début
    { … le tableau est rempli, n cases utilisées … }

    min ← notes[1]
    posMin ← 1

    Pour i de 2 à n faire
        Si notes[i] < min alors
            min ← notes[i]
            posMin ← i
        Finsi
    FinPour

    écrire("La note la plus basse est ", min)
    écrire("Elle est celle de l''élève n° ", posMin)
Fin
```

*Les trois points vérifiés par le correcteur.*

L''initialisation par **`notes[1]`**, et non par 0 ni par 20.

Le **`<`** et non le `>`, puisqu''on cherche le minimum.

Les **deux affectations dans le même `Si`** : la valeur et la position
changent ensemble, sans quoi la position finirait par désigner un autre élève
que celui du minimum.
', NULL, 28),
      (v_chapitre_id, 'Simulation : chercher le maximum', 6, 'interactif', '{
  "widget": "recherche-max",
  "consigne": "Un tableau de valeurs, et la recherche du maximum qui avance case par case : la valeur courante du max s''affiche et change de couleur chaque fois qu''elle est battue. Remplace l''initialisation par 0 et entre des valeurs négatives — la simulation te montre l''algorithme répondre 0 et rater le vrai maximum. Un bouton bascule vers le minimum, et un autre suit la position en même temps que la valeur."
}', NULL, 10),
      (v_chapitre_id, 'Exécuter un algorithme pas à pas : la trace', 7, 'texte', '
Le programme demande explicitement d''**exécuter pas à pas un algorithme de
recherche séquentielle**. C''est une question d''examen fréquente, et elle ne
demande aucune invention : seulement de la rigueur.

### Ce qu''est une trace d''exécution

C''est un **tableau** où l''on note, **ligne après ligne**, la valeur de **chaque
variable** après chaque instruction.

Une colonne par variable, une ligne par instruction exécutée. On ajoute souvent
une colonne pour le **résultat du test** et une pour l''**affichage**.

### La méthode

1. Dresser le tableau avec **une colonne par variable**.
2. Écrire **un tiret** pour une variable non encore initialisée.
3. Suivre l''algorithme **sans anticiper**, instruction par instruction.
4. Dans une boucle, **répéter les lignes** autant de fois qu''il y a de tours.
5. Ne **jamais sauter** un tour, même s''il paraît évident.

C''est la dernière règle qui fait la différence : la plupart des erreurs de trace
viennent d''un tour sauté « parce qu''on avait compris ».

### Un exemple complet

Traçons la recherche de la valeur 9 dans le tableau `[4, 9, 7]`, avec n = 3.

```
trouve ← faux
i ← 1
TantQue (i <= 3) et (trouve = faux) faire
    Si tab[i] = 9 alors
        trouve ← vrai
    Sinon
        i ← i + 1
    Finsi
FinTantQue
```

| Instruction | `i` | `trouve` | Test de la boucle | Test du Si |
| --- | --- | --- | --- | --- |
| `trouve ← faux` | — | faux | | |
| `i ← 1` | 1 | faux | | |
| entrée dans la boucle | 1 | faux | (1≤3) et (faux=faux) → **vrai** | |
| `Si tab[1] = 9` | 1 | faux | | 4 = 9 → **faux** |
| `i ← i + 1` | **2** | faux | | |
| tour suivant | 2 | faux | (2≤3) et (faux=faux) → **vrai** | |
| `Si tab[2] = 9` | 2 | faux | | 9 = 9 → **vrai** |
| `trouve ← vrai` | 2 | **vrai** | | |
| tour suivant | 2 | vrai | (2≤3) et (vrai=faux) → **faux** | |
| sortie de boucle | 2 | vrai | | |

**Résultat** : l''algorithme sort avec `trouve = vrai` et `i = 2`, et affiche
« Valeur trouvée à la position 2 ».

### Ce que la trace révèle

Elle montre **pourquoi** l''incrémentation est dans le `Sinon` : au tour où l''on
trouve, `i` **ne bouge pas** et conserve la bonne position.

Elle montre aussi que la boucle **s''arrête tout de suite** après la découverte,
sans examiner la troisième case.

---

**Exercice corrigé**

*Donner la trace d''exécution de la recherche de la valeur 5 dans le tableau
`[3, 8, 1]`, avec n = 3. Conclure.*

**Correction.**

| Instruction | `i` | `trouve` | Test du Si |
| --- | --- | --- | --- |
| `trouve ← faux` | — | faux | |
| `i ← 1` | 1 | faux | |
| `Si tab[1] = 5` | 1 | faux | 3 = 5 → faux |
| `i ← i + 1` | 2 | faux | |
| `Si tab[2] = 5` | 2 | faux | 8 = 5 → faux |
| `i ← i + 1` | 3 | faux | |
| `Si tab[3] = 5` | 3 | faux | 1 = 5 → faux |
| `i ← i + 1` | **4** | faux | |
| test de boucle | 4 | faux | (4≤3) → **faux**, on sort |

**Conclusion.** L''algorithme sort avec `trouve = faux` et `i = 4`. Le test final
affiche donc « **Valeur absente du tableau** ».

*Deux remarques pour une copie complète.* La boucle a fait **trois tours**, soit
le **pire cas** : la valeur absente coûte toujours n comparaisons. Et `i` vaut
**4**, c''est-à-dire **n + 1** : c''est la signature d''une recherche infructueuse,
et c''est d''ailleurs ce qui a provoqué la sortie.
', NULL, 30),
      (v_chapitre_id, 'Simulation : remplir une trace d''exécution', 8, 'interactif', '{
  "widget": "trace-execution",
  "consigne": "Le tableau de trace s''affiche vide, avec une colonne par variable, et tu le remplis ligne par ligne pendant que l''algorithme avance. Chaque case fausse est signalée tout de suite, avec la raison. Change le tableau de départ et la valeur cherchée pour obtenir le meilleur cas, le pire cas et la recherche infructueuse — et vois i finir à n + 1 dans le dernier."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 21', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quel schéma suit tout traitement de tableau ?",
      "choix": [
        "Lire, écrire, trier",
        "Initialiser, accumuler, exploiter",
        "Déclarer, remplir, vider",
        "Ouvrir, lire, fermer"
      ],
      "bonne": 1,
      "explication": "La somme, la moyenne, le comptage, le maximum et la recherche en sortent tous."
    },
    {
      "question": "Pourquoi la recherche séquentielle utilise-t-elle un TantQue et non un Pour ?",
      "choix": [
        "Parce que c''est plus rapide",
        "Parce qu''on ne sait pas à l''avance combien de tours il faudra : on s''arrête dès qu''on a trouvé",
        "Parce que le Pour ne marche pas sur les tableaux",
        "Parce que le tableau n''est pas trié"
      ],
      "bonne": 1,
      "explication": "La recherche du maximum, elle, utilise un Pour : il faut parcourir tout le tableau pour être sûr."
    },
    {
      "question": "Dans la recherche séquentielle, pourquoi l''incrémentation est-elle dans le Sinon ?",
      "choix": [
        "Pour aller plus vite",
        "Pour que i conserve la position de la valeur trouvée au lieu de désigner la case suivante",
        "Parce que le Si ne peut rien contenir d''autre",
        "C''est une convention d''écriture"
      ],
      "bonne": 1,
      "explication": "Avec une incrémentation systématique, la position affichée serait fausse d''une unité."
    },
    {
      "question": "Pourquoi la condition du TantQue a-t-elle deux parties reliées par « et » ?",
      "choix": [
        "Pour la lisibilité",
        "Pour s''arrêter à la fois quand le tableau est épuisé et quand on a trouvé",
        "Pour éviter les doublons",
        "Pour trier le tableau"
      ],
      "bonne": 1,
      "explication": "Sans i <= n on déborde du tableau ; sans trouve = faux on ne s''arrête jamais tôt. Les deux sont nécessaires."
    },
    {
      "question": "Par quoi initialise-t-on le maximum dans une recherche du plus grand élément ?",
      "choix": [
        "Par 0",
        "Par tab[1], le premier élément du tableau",
        "Par la plus grande valeur possible",
        "Par n"
      ],
      "bonne": 1,
      "explication": "Avec 0, un tableau de valeurs négatives donnerait 0 comme maximum : c''est la faute classique."
    },
    {
      "question": "Dans la recherche du maximum, pourquoi la boucle commence-t-elle à 2 ?",
      "choix": [
        "Pour aller plus vite",
        "Parce que la case 1 a déjà servi d''initialisation et qu''il est inutile de la comparer à elle-même",
        "Parce que l''indice 1 n''existe pas",
        "Pour éviter un débordement"
      ],
      "bonne": 1,
      "explication": "Commencer à 1 n''est pas faux, seulement inutile : on comparerait tab[1] avec lui-même."
    },
    {
      "question": "À la fin d''une recherche séquentielle infructueuse sur n cases, que vaut i ?",
      "choix": [
        "n",
        "n + 1",
        "0",
        "1"
      ],
      "bonne": 1,
      "explication": "C''est ce dépassement qui a provoqué la sortie de la boucle : i vaut n+1 et trouve vaut faux."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 9 leçons ajoutées au chapitre 21, Manipulation d''un tableau.', v_nom;
  END LOOP;
END $inf7$;
