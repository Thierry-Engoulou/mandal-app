-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 16 : Création d'une base de données en SQL
-- Module 2 : Systèmes d'information et base de données — 8 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 16;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Création d''une base de données en SQL', 16, 'Module 2 : Systèmes d''information et base de données')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 16 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 16 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'SQL et ses trois sous-langages', 1, 'texte', '
### Ce qu''est SQL

**SQL** signifie **Structured Query Language**, soit **langage de requêtes
structuré**.

C''est le **langage normalisé** des bases de données **relationnelles** : tous
les SGBD relationnels le comprennent, avec de légères variantes.

### Les deux modes de création

Le cours distingue deux façons de créer une base.

Le **mode assisté** : on passe par des **assistants graphiques**, en plusieurs
fenêtres successives. C''est le mode d''Access, au chapitre 18.

Le **mode commande** : on écrit des **instructions SQL**. C''est le mode de ce
chapitre, et celui du Baccalauréat.

### Les trois sous-langages

C''est une question qui tombe, et la réponse tient en trois sigles.

**Le LDD** — **langage de définition des données**, en anglais **DDL**. Il
**définit et modifie la structure** de la base.

Ses commandes : `CREATE`, `ALTER`, `DROP`, et aussi `RENAME`, `TRUNCATE`.

**Le LMD** — **langage de manipulation des données**, en anglais **DML**. Il
**lit et modifie le contenu** de la base.

Ses commandes : `INSERT`, `UPDATE`, `DELETE` pour les mises à jour, et `SELECT`
pour les interrogations.

**Le LCD** — **langage de contrôle des données**, en anglais **DCL**. Il **gère
les privilèges des utilisateurs**.

Ses commandes : `GRANT` pour accorder un droit, `REVOKE` pour le retirer.

### L''image qui fixe les idées

Le LDD construit le **meuble** : il décide qu''il y aura trois tiroirs, et de
quelle taille.

Le LMD range des choses **dans** les tiroirs, les déplace, les sort.

Le LCD distribue les **clés** du meuble.

### Les deux confusions à éviter

**`ALTER` et `UPDATE`.** `ALTER` appartient au **LDD** et modifie la
**structure** — il ajoute une colonne. `UPDATE` appartient au **LMD** et modifie
les **données** — il change une valeur.

**`DELETE` et `DROP`.** `DELETE` **supprime des lignes** et **garde la
structure** de la table. `DROP` **supprime la table elle-même**, structure
comprise.

Après un `DELETE`, la table existe, vide. Après un `DROP`, elle n''existe plus.

---

**Exercice corrigé**

*1. Que signifie le sigle SQL ? 2. Citer ses trois sous-langages et leur rôle.
3. Quelle différence entre ALTER et UPDATE ?*

**Correction.**

**1.** SQL signifie **Structured Query Language**, langage de requêtes
structuré. C''est le langage normalisé d''interrogation des bases de données
relationnelles.

**2.**

Le **LDD**, langage de définition des données, **définit et modifie la
structure** de la base : `CREATE`, `ALTER`, `DROP`.

Le **LMD**, langage de manipulation des données, **lit et modifie le contenu** :
`INSERT`, `UPDATE`, `DELETE`, `SELECT`.

Le **LCD**, langage de contrôle des données, **gère les droits des
utilisateurs** : `GRANT`, `REVOKE`.

**3.** **`ALTER` modifie la structure** de la table — il ajoute, modifie ou
supprime une colonne — et appartient au **LDD**. **`UPDATE` modifie les
enregistrements**, c''est-à-dire les valeurs contenues dans les lignes, et
appartient au **LMD**.

*Attention : certains corrigés en circulation inversent les deux. Retiens
l''image du meuble — ALTER change le meuble, UPDATE change ce qu''il y a
dedans.*
', NULL, 28),
      (v_chapitre_id, 'Figure : les trois sous-langages de SQL', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 230" width="560" height="230">
<rect width="560" height="230" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les trois sous-langages de SQL</text>

<rect x="20" y="40" width="170" height="160" rx="8" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
<text x="105" y="62" text-anchor="middle" font-size="12" font-weight="700" fill="#1e3a8a">LDD</text>
<text x="105" y="78" text-anchor="middle" font-size="9" fill="#1e40af">langage de définition</text>
<text x="105" y="90" text-anchor="middle" font-size="9" fill="#1e40af">des données — DDL</text>
<text x="105" y="112" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">il crée la STRUCTURE</text>
<text x="105" y="136" text-anchor="middle" font-size="12" font-family="monospace" fill="#2563eb">CREATE</text>
<text x="105" y="154" text-anchor="middle" font-size="12" font-family="monospace" fill="#2563eb">ALTER</text>
<text x="105" y="172" text-anchor="middle" font-size="12" font-family="monospace" fill="#2563eb">DROP</text>
<text x="105" y="190" text-anchor="middle" font-size="9" fill="#64748b">le meuble</text>

<rect x="200" y="40" width="170" height="160" rx="8" fill="#dcfce7" stroke="#15803d" stroke-width="2"/>
<text x="285" y="62" text-anchor="middle" font-size="12" font-weight="700" fill="#14532d">LMD</text>
<text x="285" y="78" text-anchor="middle" font-size="9" fill="#166534">langage de manipulation</text>
<text x="285" y="90" text-anchor="middle" font-size="9" fill="#166534">des données — DML</text>
<text x="285" y="112" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">il gère le CONTENU</text>
<text x="285" y="136" text-anchor="middle" font-size="12" font-family="monospace" fill="#15803d">INSERT</text>
<text x="285" y="154" text-anchor="middle" font-size="12" font-family="monospace" fill="#15803d">UPDATE · DELETE</text>
<text x="285" y="172" text-anchor="middle" font-size="12" font-family="monospace" fill="#15803d">SELECT</text>
<text x="285" y="190" text-anchor="middle" font-size="9" fill="#64748b">ce qu&apos;on range dedans</text>

<rect x="380" y="40" width="160" height="160" rx="8" fill="#fef3c7" stroke="#ca8a04" stroke-width="2"/>
<text x="460" y="62" text-anchor="middle" font-size="12" font-weight="700" fill="#78350f">LCD</text>
<text x="460" y="78" text-anchor="middle" font-size="9" fill="#92400e">langage de contrôle</text>
<text x="460" y="90" text-anchor="middle" font-size="9" fill="#92400e">des données — DCL</text>
<text x="460" y="112" text-anchor="middle" font-size="10" font-weight="700" fill="#78350f">il gère les DROITS</text>
<text x="460" y="136" text-anchor="middle" font-size="12" font-family="monospace" fill="#ca8a04">GRANT</text>
<text x="460" y="154" text-anchor="middle" font-size="12" font-family="monospace" fill="#ca8a04">REVOKE</text>
<text x="460" y="190" text-anchor="middle" font-size="9" fill="#64748b">la clé du meuble</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : ranger les commandes SQL', 3, 'interactif', '{
  "widget": "sous-langages-sql",
  "consigne": "Douze commandes SQL défilent et tu les classes dans l''un des trois sous-langages. La simulation montre ensuite l''effet de chacune sur une base miniature : le meuble qui change de forme avec le LDD, les tiroirs qui se remplissent avec le LMD, les clés qui changent de mains avec le LCD. Les deux pièges — ALTER contre UPDATE, DELETE contre DROP — font l''objet d''un volet à part."
}', NULL, 10),
      (v_chapitre_id, 'CREATE TABLE et les types de données', 4, 'texte', '
### La syntaxe

```sql
CREATE TABLE nom_table
(
    colonne1 type_donnees,
    colonne2 type_donnees,
    ...
)
```

**Deux règles sur le nom de la table** : il doit être **unique dans la base**,
et il ne doit pas être un **mot-clé SQL**. On n''appelle pas une table `SELECT`
ni `ORDER`.

### Un exemple complet

```sql
CREATE TABLE utilisateur
(
    id INT PRIMARY KEY NOT NULL,
    nom VARCHAR(100),
    prenom VARCHAR(100),
    email VARCHAR(255),
    code_postal VARCHAR(5)
)
```

Remarque qu''il n''y a **pas de virgule après la dernière colonne** : c''est une
faute de syntaxe très fréquente, et elle fait échouer toute la requête.

### Les types de données

Ils varient selon le SGBD. Le cours en retient quatre, et ce sont ceux attendus
en examen :

| Type | Ce qu''il contient | Exemple |
| --- | --- | --- |
| `INT(n)` | un nombre entier | `INT` |
| `DECIMAL(n, m)` | un nombre à virgule, n chiffres dont m décimales | `DECIMAL(8,2)` |
| `VARCHAR(n)` | une chaîne de **longueur variable**, n au maximum | `VARCHAR(50)` |
| `DATE` | une date | `DATE` |

On rencontre aussi **`CHAR(n)`**, une chaîne de **longueur fixe**.

**La différence entre CHAR et VARCHAR** est une question d''examen :

`CHAR(n)` a une **longueur fixe** : la valeur est **complétée par des espaces**
jusqu''à n caractères, et l''allocation est **statique**. On l''emploie pour un
code dont la longueur ne varie pas — un matricule de 9 caractères.

`VARCHAR(n)` a une **longueur variable** : seule la place utile est occupée, et
l''allocation est **dynamique**. On l''emploie pour un nom, une adresse.

### Les options de colonne

**`NULL`** — la colonne est **facultative** : elle peut rester vide.

**`NOT NULL`** — la colonne est **obligatoire**.

**`DEFAULT valeur`** — une **valeur par défaut**, prise si l''on n''en fournit
pas. Elle est **incompatible avec `NOT NULL`**.

**`PRIMARY KEY`** — la colonne est la **clé primaire** : unique et non nulle.

**`FOREIGN KEY (colonne) REFERENCES table(colonne)`** — la colonne est une **clé
étrangère**.

**`CHECK (condition)`** — une **contrainte** sur les valeurs autorisées.

### Un exemple avec les clés

```sql
CREATE TABLE ELEVE
(
    Matricule CHAR(9) PRIMARY KEY,
    Nom VARCHAR(30) NOT NULL,
    Prenom VARCHAR(30),
    Sexe VARCHAR(10),
    DateNaissance DATE,
    NumClasse INT,
    FOREIGN KEY (NumClasse) REFERENCES CLASSE(NumClasse)
)
```

**La table CLASSE doit exister avant.** On ne peut pas référencer une table qui
n''a pas encore été créée : c''est l''ordre de création qu''il faut respecter.

---

**Exercice corrigé**

*Écrire la requête SQL de création de la table ELEVE, sachant qu''un élève est
caractérisé par un matricule de 9 caractères qui l''identifie, un nom, un prénom,
une adresse, un sexe, une date de naissance, un lieu de naissance, et le numéro
de sa classe qui référence la table CLASSE.*

**Correction.**

```sql
CREATE TABLE ELEVE
(
    Matricule CHAR(9) PRIMARY KEY,
    Nom VARCHAR(30),
    Prenom VARCHAR(30),
    Adresse VARCHAR(50),
    Sexe VARCHAR(10),
    DateNaissance DATE,
    LieuNaissance VARCHAR(30),
    NumClasse INT,
    FOREIGN KEY (NumClasse) REFERENCES CLASSE(NumClasse)
);
```

*Les quatre points que le correcteur vérifie.*

Le **`PRIMARY KEY`** sur Matricule, puisque l''énoncé dit qu''il identifie
l''élève.

Le **`CHAR(9)`** plutôt que VARCHAR, puisque la longueur est fixée à 9.

Le **`DATE`** pour la date de naissance, et non VARCHAR : sans quoi on ne
pourrait ni trier ni comparer les dates.

La **clé étrangère** sur NumClasse, et la **table CLASSE créée auparavant**.

*Et surtout : **pas de virgule après la dernière ligne**, avant la parenthèse
fermante. C''est la faute qui traîne dans beaucoup de corrigés en circulation.*

*Cette question est tombée au Baccalauréat 2023, pour un point.*
', NULL, 32),
      (v_chapitre_id, 'Simulation : écrire un CREATE TABLE', 5, 'interactif', '{
  "widget": "create-table",
  "consigne": "Un énoncé décrit une table à créer, et tu écris la requête dans un véritable éditeur SQL. La simulation l''exécute sur une base miniature : si elle passe, la table apparaît avec ses colonnes et ses types ; sinon, le message d''erreur te dit où. Elle guette les quatre fautes classiques — la virgule finale, la clé primaire oubliée, VARCHAR là où il fallait DATE, et la table référencée qui n''existe pas encore."
}', NULL, 10),
      (v_chapitre_id, 'ALTER TABLE et DROP TABLE', 6, 'texte', '
### ALTER TABLE : modifier la structure

```sql
ALTER TABLE nom_table
[ADD COLUMN définition_colonne]
[ADD CONSTRAINT définition_contrainte]
[MODIFY définition_colonne]
[DROP COLUMN nom_colonne]
[DROP CONSTRAINT nom_contrainte]
[ENABLE | DISABLE nom_contrainte]
```

Les crochets signifient qu''on choisit **une** de ces clauses à la fois.

**Ajouter une colonne :**

```sql
ALTER TABLE client ADD COLUMN
(
    email VARCHAR(80)
);
```

**Modifier une colonne :**

```sql
ALTER TABLE client MODIFY (email VARCHAR(100));
```

**Supprimer une colonne :**

```sql
ALTER TABLE client DROP COLUMN email;
```

*Le cours signale un point important : `DROP COLUMN` n''existe pas dans certaines
versions de SQL.* C''est l''une des commandes les moins portables d''un SGBD à
l''autre.

**`ENABLE` et `DISABLE`** réactivent ou désactivent une **contrainte
d''intégrité**, sans la supprimer. On s''en sert pour charger en masse des données
qui violeraient temporairement une contrainte.

### DROP TABLE : supprimer la table

```sql
DROP TABLE nom_table
```

Cette commande supprime **à la fois le contenu et la structure** de la table.

Elle est **irréversible**. Il n''y a pas de confirmation, pas de corbeille.

Et si d''autres tables référencent celle-ci par une clé étrangère, le SGBD
**refusera** la suppression — ou supprimera les références en cascade, selon la
façon dont les contraintes ont été définies.

### Le tableau qui évite les confusions

| Commande | Ce qu''elle touche | Ce qui reste après |
| --- | --- | --- |
| `DELETE FROM t` | les **lignes** | la table, vide |
| `DROP TABLE t` | la **table entière** | **rien** |
| `ALTER TABLE t` | la **structure** | la table, modifiée |
| `UPDATE t` | les **valeurs** | la table, avec d''autres valeurs |

---

**Exercice corrigé**

*La table `client` existe avec les colonnes `code`, `nom` et `ville`.*
*1. Ajouter une colonne `telephone` de 20 caractères.*
*2. Porter la taille de `ville` à 50 caractères.*
*3. Quelle est la différence entre `DELETE FROM client;` et
`DROP TABLE client;` ?*

**Correction.**

**1.**
```sql
ALTER TABLE client ADD COLUMN (telephone VARCHAR(20));
```

**2.**
```sql
ALTER TABLE client MODIFY (ville VARCHAR(50));
```

**3.** **`DELETE FROM client;`** supprime **toutes les lignes** de la table,
mais **conserve sa structure** : la table existe toujours, avec ses colonnes,
et elle est vide. On peut y insérer de nouvelles lignes immédiatement.

**`DROP TABLE client;`** supprime **la table elle-même**, structure comprise.
Après cette commande, la table n''existe plus : toute requête qui la nomme
échouera, et il faudrait la recréer par un `CREATE TABLE`.

*La règle de prudence qui va avec : un `DELETE` sans clause `WHERE` vide toute
la table. On écrit toujours le `WHERE` avant le reste de la requête.*
', NULL, 26),
      (v_chapitre_id, 'Simulation : modifier et supprimer', 7, 'interactif', '{
  "widget": "alter-drop",
  "consigne": "Une base de trois tables s''affiche avec sa structure et ses lignes. Exécute ALTER, DELETE, DROP et UPDATE, et vois exactement ce que chacune change : la colonne qui apparaît, les lignes qui disparaissent en laissant la table vide, la table qui s''efface entièrement. La simulation refuse de supprimer une table référencée par une clé étrangère et te dit laquelle, puis te propose d''annuler ta dernière commande — ce qu''un vrai SGBD ne fera pas."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 16', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que signifie le sigle SQL ?",
      "choix": [
        "Standard Query Language",
        "Structured Query Language",
        "Simple Question Language",
        "System Query Logic"
      ],
      "bonne": 1,
      "explication": "Langage de requêtes structuré : le langage normalisé des bases de données relationnelles."
    },
    {
      "question": "Quels sont les trois sous-langages de SQL ?",
      "choix": [
        "LDD, LMD et LCD",
        "SELECT, INSERT et UPDATE",
        "DDL, SQL et NoSQL",
        "Création, lecture et suppression"
      ],
      "bonne": 0,
      "explication": "Le LDD définit la structure, le LMD manipule le contenu, le LCD gère les droits. Le meuble, ce qu''on range dedans, et les clés."
    },
    {
      "question": "À quel sous-langage appartient la commande ALTER ?",
      "choix": [
        "Au LMD, car elle modifie",
        "Au LDD, car elle modifie la structure",
        "Au LCD",
        "À aucun"
      ],
      "bonne": 1,
      "explication": "ALTER change le meuble, UPDATE change ce qu''il y a dedans. Certains corrigés en circulation inversent les deux."
    },
    {
      "question": "Quelle est la différence entre CHAR(n) et VARCHAR(n) ?",
      "choix": [
        "Aucune",
        "CHAR est de longueur fixe et complété par des espaces ; VARCHAR est de longueur variable",
        "CHAR n''accepte que des lettres",
        "VARCHAR est réservé aux dates"
      ],
      "bonne": 1,
      "explication": "CHAR pour un code de longueur fixe comme un matricule, VARCHAR pour un nom ou une adresse."
    },
    {
      "question": "Quelle faute de syntaxe fait échouer un CREATE TABLE ?",
      "choix": [
        "Mettre la clé primaire en premier",
        "Laisser une virgule après la dernière colonne, avant la parenthèse fermante",
        "Écrire les types en majuscules",
        "Nommer la table en minuscules"
      ],
      "bonne": 1,
      "explication": "C''est la faute la plus fréquente, et elle traîne même dans des corrigés publiés."
    },
    {
      "question": "Quelle est la différence entre DELETE et DROP ?",
      "choix": [
        "Aucune",
        "DELETE supprime des lignes et garde la structure ; DROP supprime la table entière",
        "DROP est plus lent",
        "DELETE supprime la table"
      ],
      "bonne": 1,
      "explication": "Après un DELETE, la table existe, vide. Après un DROP, elle n''existe plus et il faut la recréer."
    },
    {
      "question": "Pour créer une table ELEVE avec une clé étrangère vers CLASSE, que faut-il d''abord ?",
      "choix": [
        "Rien de particulier",
        "Créer la table CLASSE avant",
        "Créer d''abord la clé étrangère",
        "Désactiver les contraintes"
      ],
      "bonne": 1,
      "explication": "On ne peut pas référencer une table qui n''existe pas encore : l''ordre de création compte."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 16, Création d''une base de données en SQL.', v_nom;
  END LOOP;
END $inf7$;
