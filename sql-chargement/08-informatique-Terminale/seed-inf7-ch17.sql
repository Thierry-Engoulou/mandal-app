-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 17 : Manipulation des données d'une base en SQL
-- Module 2 : Systèmes d'information et base de données — 7 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 17;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Manipulation des données d''une base en SQL', 17, 'Module 2 : Systèmes d''information et base de données')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 17 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 17 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Insérer, modifier et supprimer des lignes', 1, 'texte', '
Le LDD a construit le meuble. Le LMD va le remplir.

### INSERT — ajouter une ligne

```sql
INSERT INTO table (nom_colonne_1, nom_colonne_2, ...)
VALUES (''valeur 1'', ''valeur 2'', ...) ;
```

Un exemple :

```sql
INSERT INTO Employes (Code, Nom, Titre, Salaire)
VALUES (''C004'', ''NKOMA Leslie'', ''Statisticienne'', 300000);
```

**Trois règles de syntaxe**, et chacune coûte des points.

Les **chaînes de caractères et les dates** se mettent **entre apostrophes
simples** : `''NKOMA Leslie''`, `''2008-03-15''`.

Les **nombres ne prennent pas d''apostrophes**, et surtout **pas d''espace
séparateur de milliers** : on écrit `300000`, jamais `300 000`. Un espace rend
la requête invalide.

L''**ordre des valeurs doit suivre l''ordre des colonnes** annoncées.

*On peut omettre la liste des colonnes* si l''on fournit une valeur pour
**toutes**, dans l''ordre de la table :

```sql
INSERT INTO Employes VALUES (''C004'', ''NKOMA Leslie'', ''Statisticienne'', 300000);
```

C''est plus court, mais plus fragile : si la table change, la requête devient
fausse en silence.

### UPDATE — modifier des lignes

```sql
UPDATE table
SET nom_colonne_1 = ''nouvelle valeur''
WHERE condition
```

Un exemple :

```sql
UPDATE ELEVE
SET DateNaissance = ''2007-05-12''
WHERE Matricule = ''E101'';
```

**Sans clause `WHERE`, toutes les lignes sont modifiées.** C''est l''accident
classique : un `UPDATE` sans `WHERE` met le même salaire à toute l''entreprise.

On peut modifier **plusieurs colonnes** d''un coup, séparées par des virgules :

```sql
UPDATE ELEVE
SET Nom = ''MBIDA'', Prenom = ''Jean''
WHERE Matricule = ''E101'';
```

### DELETE — supprimer des lignes

```sql
DELETE FROM table
WHERE condition
```

Un exemple :

```sql
DELETE FROM ELEVE
WHERE Matricule = ''E103'';
```

**Sans clause `WHERE`, toutes les lignes sont supprimées.** Le cours insiste, et
il a raison.

### La règle de survie

Avant tout `UPDATE` ou tout `DELETE`, **écris le `WHERE` en premier**, puis
remonte écrire le reste.

Mieux encore : transforme d''abord ta requête en `SELECT` pour voir **quelles
lignes** elle touche.

```sql
SELECT * FROM ELEVE WHERE Matricule = ''E103'';    -- je vérifie
DELETE FROM ELEVE WHERE Matricule = ''E103'';      -- puis je supprime
```

---

**Exercice corrigé**

*Écrire la requête SQL qui insère dans la table `Employes` l''employé de code
C004, nommé NKOMA Leslie, statisticienne, avec un salaire de 300 000.*

**Correction.**

```sql
INSERT INTO Employes (Code, Nom, Titre, Salaire)
VALUES (''C004'', ''NKOMA Leslie'', ''Statisticienne'', 300000);
```

*Les trois points vérifiés.*

Les **apostrophes** autour des trois chaînes de caractères.

Le **salaire sans apostrophes et sans espace** : `300000`. Écrire `300 000`
rendrait la requête invalide, et `''300000''` entre apostrophes serait traité
comme du texte.

Le **point-virgule** final.

*Cette question est tombée au Baccalauréat 2025, pour 1,5 point — le plus gros
barème de la partie bases de données.*
', NULL, 28),
      (v_chapitre_id, 'Simulation : remplir et modifier une table', 2, 'interactif', '{
  "widget": "insert-update-delete",
  "consigne": "Une table vide t''attend, et tu la remplis avec de vrais INSERT. La simulation exécute, affiche les lignes, et refuse les requêtes fautives en te disant pourquoi : apostrophes manquantes, espace dans un nombre, nombre de valeurs qui ne correspond pas. Lance ensuite un UPDATE ou un DELETE sans clause WHERE : elle te montre d''abord combien de lignes seraient touchées, et te demande confirmation."
}', NULL, 10),
      (v_chapitre_id, 'SELECT : projection, sélection et jointure', 3, 'texte', '
`SELECT` est la commande la plus utilisée de SQL, et elle fait trois choses
différentes qu''il faut savoir nommer.

### La projection — choisir des colonnes

```sql
SELECT [DISTINCT] * | liste_Nom_colonne
FROM nom_table
```

L''**astérisque** désigne **toutes les colonnes**. `DISTINCT` **élimine les
doublons** du résultat.

```sql
SELECT Nom, Prenom FROM ELEVE;
SELECT * FROM ELEVE;
SELECT DISTINCT Ville FROM CLIENT;
```

### La sélection — choisir des lignes

```sql
SELECT [DISTINCT] * | liste_Nom_colonne
FROM nom_table
WHERE condition
```

```sql
SELECT Nom, Prenom
FROM ELEVE
WHERE Sexe = ''Féminin'';
```

C''est la clause **`WHERE`** qui fait la sélection. Sans elle, toutes les lignes
sortent.

### La jointure — relier deux tables

Quand l''information est répartie sur **deux tables liées par une colonne
commune**, on les joint.

```sql
SELECT [DISTINCT] * | liste_Nom_colonne
FROM nom_table1 [alias1], nom_table2 [alias2]
WHERE condition
```

L''exemple du cours :

```sql
SELECT Nom_client, Prénom_client, date_comm
FROM Client, Commande
WHERE Client.code_client = Commande.code_client;
```

**La condition de jointure est obligatoire** : elle dit **quelle colonne de la
première table correspond à quelle colonne de la seconde**.

Si tu l''oublies, le SGBD renvoie **toutes les combinaisons possibles** — cent
clients et cent commandes donnent dix mille lignes absurdes. C''est le **produit
cartésien**, et c''est l''erreur la plus spectaculaire de SQL.

Quand une colonne porte le même nom dans les deux tables, on la **préfixe du nom
de la table** : `Client.code_client`.

### Les clauses qui complètent

**`ORDER BY colonne [ASC | DESC]`** trie le résultat. `ASC` pour croissant — la
valeur par défaut —, `DESC` pour décroissant.

**Les fonctions d''agrégat** : `SUM()` additionne une colonne numérique,
`AVG()` en fait la moyenne, `COUNT()` compte les lignes, `MIN()` et `MAX()`
donnent les extrêmes.

```sql
SELECT AVG(Salaire) FROM Employes;
SELECT COUNT(*) FROM ELEVE WHERE Sexe = ''Féminin'';
```

---

**Exercice corrigé**

*1. Écrire la requête qui affiche les noms et prénoms des élèves de sexe
féminin.*
*2. Donner la signification de la requête :*

```sql
SELECT Nom, Prenom FROM ELEVE WHERE NumClasse = 2 ORDER BY Nom ASC;
```

**Correction.**

**1.**
```sql
SELECT Nom, Prenom
FROM ELEVE
WHERE Sexe = ''Féminin'';
```

*Trois points de vigilance.* On ne met que les **deux colonnes demandées**, et
non `*`. La valeur est **entre apostrophes simples**, et non entre guillemets —
les doubles apostrophes qu''on voit dans certains corrigés ne sont pas valides en
SQL. Et la valeur exacte — `''Féminin''` ou `''F''` — dépend de ce qui est
réellement stocké dans la table.

**2.** Cette requête **affiche le nom et le prénom des élèves de la classe
numéro 2, triés par ordre alphabétique croissant des noms**.

*Décomposition* : `SELECT Nom, Prenom` est la **projection**, elle choisit les
colonnes ; `WHERE NumClasse = 2` est la **sélection**, elle choisit les lignes ;
`ORDER BY Nom ASC` est le **tri**.
', NULL, 30),
      (v_chapitre_id, 'Simulation : interroger une base', 4, 'interactif', '{
  "widget": "requete-select",
  "consigne": "Une base de lycée remplie t''attend — élèves, classes, matières, notes — et une console SQL. Écris tes SELECT et vois le résultat s''afficher en tableau, avec les lignes retenues qui s''éclairent dans la table source. Oublie la condition de jointure et la simulation te montre le produit cartésien exploser : deux tables de trente lignes en donnent neuf cents."
}', NULL, 10),
      (v_chapitre_id, 'Les opérateurs du WHERE', 5, 'texte', '
Toute la puissance de `SELECT` tient dans sa clause `WHERE`. Le programme nomme
les opérateurs à connaître.

### Les opérateurs de comparaison

Le programme les cite explicitement : **`=`, `<`, `>`, `<=`, `>=`**, auxquels
s''ajoute **`<>`** pour « différent de ».

```sql
SELECT * FROM Employes WHERE Salaire <= 200000;
SELECT * FROM ELEVE WHERE DateNaissance > ''2007-01-01'';
```

Attention : en SQL, « différent » s''écrit **`<>`**, et non `!=` — même si
beaucoup de SGBD acceptent les deux.

### Les opérateurs logiques

Le programme nomme **`AND`** et **`OR`**, auxquels s''ajoute **`NOT`**.

**`AND`** exige que **les deux** conditions soient vraies.
**`OR`** se contente d''**au moins une**.
**`NOT`** inverse.

```sql
SELECT * FROM ELEVE
WHERE Sexe = ''Féminin'' AND NumClasse = 2;

SELECT * FROM Employes
WHERE Titre = ''Ingénieur'' OR Titre = ''Technicien'';
```

**Mets des parenthèses** dès que tu mélanges `AND` et `OR` : `AND` est évalué
avant `OR`, et l''oubli change le résultat.

```sql
WHERE (Ville = ''Douala'' OR Ville = ''Yaoundé'') AND Salaire > 200000
```

Sans les parenthèses, cette requête donnerait tous les employés de Douala, plus
ceux de Yaoundé gagnant plus de 200 000 — ce qui n''est pas la même chose.

### Les opérateurs particuliers

**`BETWEEN a AND b`** — entre deux valeurs, **bornes comprises**.

```sql
WHERE Salaire BETWEEN 100000 AND 300000
```

**`IN (liste)`** — dans une liste de valeurs. Plus court qu''une suite de `OR`.

```sql
WHERE Ville IN (''Douala'', ''Yaoundé'', ''Garoua'')
```

**`IS NULL`** et **`IS NOT NULL`** — la valeur est absente, ou présente.

Attention : on n''écrit **jamais** `= NULL`. `NULL` n''est pas une valeur, c''est
une absence de valeur, et aucune comparaison ne lui est vraie.

**`LIKE`** — filtre les chaînes, avec deux jokers :

`%` remplace **n''importe quelle suite** de caractères ;
`_` remplace **un seul** caractère.

```sql
WHERE Nom LIKE ''M%''        -- les noms commençant par M
WHERE Nom LIKE ''%a''        -- les noms finissant par a
WHERE Nom LIKE ''_bida''     -- cinq lettres, se terminant par bida
```

### Le tableau de révision

| Opérateur | Ce qu''il fait |
| --- | --- |
| `=` `<>` `<` `>` `<=` `>=` | comparer |
| `AND` `OR` `NOT` | combiner |
| `BETWEEN … AND …` | un intervalle, bornes comprises |
| `IN (…)` | appartenir à une liste |
| `IS NULL` / `IS NOT NULL` | tester l''absence de valeur |
| `LIKE` | filtrer une chaîne, avec `%` et `_` |

---

**Exercice corrigé**

*Soit la table `Employes (Code, Nom, Titre, Salaire)`. Donner le résultat de la
requête suivante, puis écrire une requête affichant les employés dont le nom
commence par N et dont le salaire est compris entre 150 000 et 350 000.*

```sql
SELECT Nom, Titre FROM Employes WHERE Salaire <= 200000;
```

*Contenu de la table :*

| Code | Nom | Titre | Salaire |
| --- | --- | --- | --- |
| C001 | MBIDA Paul | Ingénieur | 450 000 |
| C002 | NGONO Marie | Secrétaire | 180 000 |
| C003 | ESSOMBA Jean | Technicien | 200 000 |
| C004 | NKOMA Leslie | Statisticienne | 300 000 |

**Correction.**

*Le résultat de la première requête.* La condition `Salaire <= 200000` retient
les lignes dont le salaire est **inférieur ou égal** à 200 000 — donc **y
compris** 200 000 exactement. La projection ne garde que `Nom` et `Titre`.

| Nom | Titre |
| --- | --- |
| NGONO Marie | Secrétaire |
| ESSOMBA Jean | Technicien |

*Le piège est le `<=` : ESSOMBA Jean, à exactement 200 000, fait partie du
résultat. Avec `<` strict, il en sortirait.*

*La seconde requête.*

```sql
SELECT * FROM Employes
WHERE Nom LIKE ''N%'' AND Salaire BETWEEN 150000 AND 350000;
```

Elle retient NGONO Marie — nom en N, salaire 180 000 — et NKOMA Leslie — nom en
N, salaire 300 000.

*Une question de ce type, « donner le résultat de la requête », est tombée au
Baccalauréat 2025 pour 1,5 point, et au Baccalauréat 2024 sous la forme
« présenter le résultat sous forme de tableau ».*
', NULL, 32),
      (v_chapitre_id, 'Simulation : composer une clause WHERE', 6, 'interactif', '{
  "widget": "operateurs-sql",
  "consigne": "Une table d''employés s''affiche, et tu construis ta condition en cliquant les opérateurs : comparaisons, AND, OR, BETWEEN, IN, LIKE, IS NULL. Les lignes retenues s''éclairent en direct à mesure que tu écris. La simulation met en évidence deux pièges : la borne comprise du <= et du BETWEEN, et ce que change une paire de parenthèses quand tu mélanges AND et OR."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 17', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Comment écrit-on un salaire de 300 000 dans un INSERT ?",
      "choix": [
        "''300 000''",
        "300 000",
        "300000",
        "\\u0022300000\\u0022"
      ],
      "bonne": 2,
      "explication": "Les nombres ne prennent ni apostrophes ni espace séparateur de milliers. Un espace rend la requête invalide."
    },
    {
      "question": "Que se passe-t-il si on exécute un UPDATE sans clause WHERE ?",
      "choix": [
        "Rien, la requête est refusée",
        "Toutes les lignes de la table sont modifiées",
        "Seule la première ligne est modifiée",
        "La table est supprimée"
      ],
      "bonne": 1,
      "explication": "C''est l''accident classique. Écris toujours le WHERE en premier, et vérifie d''abord avec un SELECT."
    },
    {
      "question": "Comment appelle-t-on le fait de choisir certaines colonnes dans un SELECT ?",
      "choix": [
        "La sélection",
        "La projection",
        "La jointure",
        "Le tri"
      ],
      "bonne": 1,
      "explication": "La projection choisit les COLONNES, la sélection choisit les LIGNES par la clause WHERE."
    },
    {
      "question": "Qu''arrive-t-il si on oublie la condition de jointure entre deux tables ?",
      "choix": [
        "La requête est refusée",
        "On obtient toutes les combinaisons possibles : le produit cartésien",
        "On n''obtient aucune ligne",
        "Seule la première table est lue"
      ],
      "bonne": 1,
      "explication": "Cent clients et cent commandes donnent dix mille lignes absurdes. C''est l''erreur la plus spectaculaire de SQL."
    },
    {
      "question": "Comment teste-t-on l''absence de valeur dans une colonne ?",
      "choix": [
        "WHERE colonne = NULL",
        "WHERE colonne IS NULL",
        "WHERE colonne = ''''",
        "WHERE colonne <> 0"
      ],
      "bonne": 1,
      "explication": "NULL n''est pas une valeur mais une absence de valeur : aucune comparaison ne lui est vraie, d''où IS NULL."
    },
    {
      "question": "Que fait la condition WHERE Nom LIKE ''M%'' ?",
      "choix": [
        "Elle retient les noms contenant M",
        "Elle retient les noms commençant par M",
        "Elle retient les noms finissant par M",
        "Elle retient les noms de deux lettres"
      ],
      "bonne": 1,
      "explication": "Le % remplace n''importe quelle suite de caractères, et le tiret bas en remplace un seul."
    },
    {
      "question": "Dans WHERE Salaire <= 200000, un employé gagnant exactement 200 000 est-il retenu ?",
      "choix": [
        "Non",
        "Oui, car la borne est comprise",
        "Seulement avec BETWEEN",
        "Cela dépend du SGBD"
      ],
      "bonne": 1,
      "explication": "Le <= inclut la borne, contrairement au < strict. Même chose pour BETWEEN, dont les deux bornes sont comprises."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 17, Manipulation des données d''une base en SQL.', v_nom;
  END LOOP;
END $inf7$;
