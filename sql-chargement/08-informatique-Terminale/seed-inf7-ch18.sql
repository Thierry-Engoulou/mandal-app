-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 18 : Création d'une base de données sous MS Access
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
    WHERE programme_id = v_programme_id AND ordre = 18;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Création d''une base de données sous MS Access', 18, 'Module 2 : Systèmes d''information et base de données')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 18 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 18 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Microsoft Access et les objets d''une base', 1, 'texte', '
Dernier chapitre du module. Le programme demande de **créer une base de données
contenant une seule table en mode graphique sous MS Access**.

### Ce qu''est Access

**Microsoft Access** est un **SGBD relationnel** de la suite **MS Office**.

Sa particularité : il propose une **interface graphique complète**. On y crée
une base sans écrire une ligne de SQL — c''est le **mode assisté** du chapitre 16.

Sa limite : il convient aux **petites et moyennes bases**, sur un poste ou un
petit réseau. Au-delà, on passe à SQL Server, MySQL ou PostgreSQL.

Son fichier porte l''extension **`.accdb`** — autrefois `.mdb`.

**Un point qui surprend** : contrairement à Word ou Excel, une base Access
**s''enregistre au moment où on la crée**, avant même d''y mettre quoi que ce
soit. Et les modifications sont **enregistrées au fur et à mesure**, sans
commande « Enregistrer ».

### Les objets d''une base Access

Le volet de navigation, à gauche, les regroupe par famille.

**Les tables** — elles **contiennent les données**. C''est le seul objet
indispensable, et le seul au programme.

**Les requêtes** — elles **interrogent** les données. Access les construit
graphiquement, mais on peut passer en mode SQL à tout moment.

**Les formulaires** — ils donnent une **interface de saisie** agréable, un
enregistrement à la fois.

**Les états** — ils **mettent en forme pour l''impression** : une liste
d''élèves, un bulletin.

**Les macros et les modules** — ils **automatisent** les traitements.

### Les deux modes d''affichage d''une table

C''est la notion centrale d''Access, et celle qu''on confond.

Le **mode Création** sert à définir **la structure** : les noms des champs,
leurs types, leurs propriétés, la clé primaire. C''est l''équivalent graphique du
`CREATE TABLE`.

Le **mode Feuille de données** sert à **saisir et consulter les données**. La
table y ressemble à une feuille de calcul.

On bascule de l''un à l''autre par le bouton **Affichage**, en haut à gauche.

---

**Exercice corrigé**

*Citer un logiciel permettant d''implémenter une table de base de données, et
donner deux objets d''une base Access en précisant leur rôle.*

**Correction.**

*Le logiciel* : **Microsoft Access**. On accepte aussi MySQL, Oracle, SQL Server
ou PostgreSQL — la question du Baccalauréat 2025 valait 0,5 point et demandait
un seul nom.

*Deux objets :*

La **table**, qui **contient les données** organisées en champs et en
enregistrements. C''est l''objet indispensable : sans table, il n''y a pas de base.

La **requête**, qui **interroge les données** pour en extraire celles qui
répondent à un critère.

*On accepte aussi le formulaire, qui offre une interface de saisie, et l''état,
qui met en forme pour l''impression.*
', NULL, 24),
      (v_chapitre_id, 'Simulation : l''interface d''Access', 2, 'interactif', '{
  "widget": "interface-access",
  "consigne": "La fenêtre d''Access s''ouvre avec son ruban, son volet de navigation et sa zone de travail. Clique sur chaque partie pour la nommer, puis ouvre les cinq familles d''objets : tables, requêtes, formulaires, états, macros. Le bouton Affichage bascule entre le mode Création et le mode Feuille de données, et la simulation te montre que l''un règle la structure quand l''autre règle le contenu."
}', NULL, 10),
      (v_chapitre_id, 'Créer une table en mode Création', 3, 'texte', '
Voici la marche à suivre, étape par étape. C''est exactement ce que demande le
programme.

### Étape 1 — créer la base

Lancer Access, choisir **Base de données du bureau vide**, **donner un nom** au
fichier, choisir son emplacement, puis **Créer**.

La base est enregistrée **immédiatement**, et Access ouvre une première table
nommée `Table1`.

### Étape 2 — passer en mode Création

Onglet **Accueil**, bouton **Affichage**, **Mode Création**. Access demande
alors d''**enregistrer la table** et de lui donner un nom — `ELEVE`, par exemple.

### Étape 3 — définir les champs

Une grille à trois colonnes apparaît : **Nom du champ**, **Type de données**,
**Description**.

On saisit un champ par ligne.

### Les types de données d''Access

Ils portent d''autres noms qu''en SQL, et c''est une source de confusion.

| Type Access | Équivalent SQL | Pour quoi |
| --- | --- | --- |
| **Texte court** | `VARCHAR(255)` | nom, prénom, code — 255 caractères au plus |
| **Texte long** | `TEXT` | une observation, un commentaire |
| **Numérique** | `INT`, `DECIMAL` | un âge, une quantité, un prix |
| **Date/Heure** | `DATE` | une date de naissance |
| **Monétaire** | `DECIMAL` | un montant en FCFA |
| **NuméroAuto** | clé auto-incrémentée | un identifiant généré par Access |
| **Oui/Non** | booléen | un champ à deux états |

### Étape 4 — définir la clé primaire

Sélectionner la ligne du champ, puis bouton **Clé primaire** du ruban — l''icône
en forme de clé.

Une **petite clé apparaît** à gauche du champ : c''est la confirmation.

**Toute table doit avoir une clé primaire.** Si tu enregistres sans en définir
une, Access propose d''en créer une automatiquement, de type NuméroAuto.

### Étape 5 — régler les propriétés du champ

Le volet du bas, **Propriétés du champ**, permet de préciser :

la **Taille du champ** — le nombre de caractères, ou le type numérique ;
le **Format** d''affichage ;
**Null interdit** — l''équivalent de `NOT NULL` ;
**Indexé** — avec ou sans doublons ;
la **Valeur par défaut** ;
la **Valide si** — l''équivalent de la contrainte `CHECK`, par exemple
`>=0 Et <=20` pour une note.

### Étape 6 — enregistrer et saisir

`Ctrl` + `S` enregistre la structure. Puis **Affichage**, **Mode Feuille de
données**, et l''on saisit les enregistrements.

---

**Exercice corrigé**

*Décrire les étapes de création, sous MS Access et en mode graphique, d''une
table ELEVE contenant un matricule, un nom, une date de naissance et une
moyenne.*

**Correction.**

**1.** Lancer Access, choisir **Base de données du bureau vide**, nommer le
fichier et cliquer sur **Créer**.

**2.** Passer en **Mode Création** par le bouton **Affichage**, et nommer la
table `ELEVE`.

**3.** Saisir les quatre champs avec leur type :

| Nom du champ | Type de données |
| --- | --- |
| Matricule | Texte court |
| Nom | Texte court |
| DateNaissance | Date/Heure |
| Moyenne | Numérique |

**4.** Sélectionner la ligne `Matricule` et cliquer sur **Clé primaire**. La
petite clé apparaît à sa gauche.

**5.** Régler les propriétés : taille de 9 caractères pour le matricule,
**Null interdit** sur le nom, et une règle **Valide si** `>=0 Et <=20` sur la
moyenne.

**6.** Enregistrer, puis basculer en **Mode Feuille de données** pour saisir les
élèves.

*Les deux points que le correcteur cherche* : le **mode Création** nommé
explicitement, et la **clé primaire** définie sur le matricule.
', NULL, 28),
      (v_chapitre_id, 'Simulation : créer une table sous Access', 4, 'interactif', '{
  "widget": "creer-table-access",
  "consigne": "La grille du mode Création s''affiche comme dans Access : nom du champ, type de données, description, et le volet des propriétés en bas. Construis la table ELEVE champ par champ, pose la clé primaire, règle une règle de validation sur la moyenne. Bascule ensuite en mode Feuille de données et saisis des élèves : la simulation refuse un matricule en double et une moyenne de 25, en nommant la propriété qui s''y oppose."
}', NULL, 10),
      (v_chapitre_id, 'Saisir, trier et filtrer les données', 5, 'texte', '
La table est créée. Reste à s''en servir.

### Saisir en mode Feuille de données

On tape directement dans la grille. Access enregistre **dès qu''on quitte la
ligne** — il n''y a pas de bouton « Enregistrer » pour les données.

Le **crayon** dans la marge gauche signale une ligne en cours de modification.
L''**astérisque** marque la ligne vide, toujours présente en bas, qui attend le
prochain enregistrement.

### Les refus qu''Access oppose

Et qui sont tous de bonnes nouvelles :

**un doublon de clé primaire** — « Les modifications n''ont pas abouti car elles
créeraient des doublons » ;
**une clé primaire vide** — Access exige une valeur ;
**un type incompatible** — du texte dans un champ Numérique ;
**une règle de validation violée** — une note de 25 quand la règle dit
`<=20`.

Chacun de ces refus est une **contrainte d''intégrité** qui fait son travail.
C''est précisément ce qui distingue une base de données d''un tableur, où l''on
peut tout taper n''importe où.

### Trier

Clic droit sur la colonne, **Trier de A à Z** ou **de Z à A**. C''est
l''équivalent du `ORDER BY`.

### Filtrer

Clic sur la petite flèche de l''en-tête de colonne, puis cocher les valeurs à
garder. C''est l''équivalent du `WHERE`.

Pour un filtre plus fin : **Filtres de texte** ou **Filtres numériques**, qui
offrent « commence par », « contient », « supérieur à » — les équivalents de
`LIKE` et des comparaisons.

### Et le SQL, dans tout cela

Access **ne cache pas** SQL : il le génère.

Crée une requête en mode graphique, puis passe en **mode SQL** par le bouton
Affichage : tu verras la requête `SELECT` qu''Access a écrite pour toi.

C''est la meilleure façon de vérifier ton propre SQL quand tu débutes, et c''est
un excellent exercice de révision avant l''épreuve.

---

**Exercice corrigé**

*Vous saisissez des élèves dans une table Access. Access refuse d''enregistrer
une ligne en affichant un message de doublon. Quelle est la cause, et que
faites-vous ?*

**Correction.**

*La cause.* La valeur saisie dans le champ **clé primaire** existe déjà dans une
autre ligne. Or une clé primaire doit être **unique** : Access applique la
contrainte et refuse l''enregistrement.

*Ce qu''il faut faire.* Vérifier le matricule saisi : ou bien c''est une faute de
frappe et il faut le corriger, ou bien l''élève a déjà été saisi et il ne faut
pas le saisir deux fois.

*Ce qu''il ne faut surtout pas faire* : supprimer la clé primaire pour faire
passer la ligne. Le refus n''est pas un défaut du logiciel, c''est la base qui
protège sa cohérence — et c''est exactement ce qu''on lui demande.
', NULL, 25),
      (v_chapitre_id, 'Simulation : saisir dans une feuille de données', 6, 'interactif', '{
  "widget": "feuille-donnees-access",
  "consigne": "La feuille de données d''Access s''ouvre avec ses marges, son crayon de modification et son astérisque de ligne vide. Saisis des élèves, provoque volontairement les quatre refus — doublon, clé vide, type incompatible, règle de validation — et lis le message exact. Trie ensuite une colonne et pose un filtre, et la simulation affiche à côté la requête SQL équivalente qu''Access vient d''écrire."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — Partie II, systèmes d''information et bases de données (2023)', 7, 'texte', '
Voici la deuxième partie de l''épreuve théorique d''informatique du Baccalauréat
C, D et E, session 2023, entièrement corrigée. Elle vaut **7 points** sur 20, et
porte exclusivement sur ce module.

---

**Énoncé**

**Exercice 1 — Systèmes d''information (3 points)**

*Un lycée organise des sorties pédagogiques. Chaque sortie emmène des élèves
visiter un site, et chaque site se trouve dans une ville. Le diagramme fourni
fait apparaître quatre entités.*

*1. Identifier les quatre entités et donner l''identifiant de chacune. (2 pts)*

*2. Dessiner le MCD liant l''élève et la sortie, sachant qu''une sortie est
effectuée par au moins un élève. (1 pt)*

**Exercice 2 — Bases de données (4 points)**

*Soit le modèle logique suivant :*

```
CLASSE (NumClasse, LibelleClasse)
ELEVE  (Matricule, Nom, Prenom, Adresse, Sexe, DateNaissance,
        LieuNaissance, #NumClasse)
```

*1. Donner la signification de Matricule et de #NumClasse dans la table ELEVE.
(1 pt)*

*2. Écrire la requête SQL de création de la table ELEVE. (1 pt)*

*3. Donner la signification de la requête suivante : (1 pt)*

```sql
SELECT Nom, Prenom FROM ELEVE WHERE NumClasse = 2 ORDER BY Nom ASC;
```

*4. Écrire la requête SQL affichant les noms et prénoms des élèves de sexe
féminin. (1 pt)*

---

**Correction détaillée**

**Exercice 1 — question 1.** Les quatre entités, avec leur identifiant :

| Entité | Identifiant |
| --- | --- |
| **ELEVE** | Matricule |
| **SORTIE** | NumeroSortie |
| **SITE** | CodeSite |
| **VILLE** | CodeVille |

*Le barème accorde 0,5 point par entité correctement nommée avec son
identifiant. Un identifiant oublié coûte donc autant que l''entité.*

**Exercice 1 — question 2.** Le MCD liant l''élève et la sortie :

```
ELEVE (0,n) ──── PARTICIPER ──── (1,n) SORTIE
```

*La justification des cardinalités, qui fait la différence entre 0,5 et 1 point.*

Du côté **ELEVE** : un élève peut participer à **plusieurs** sorties, donc le
maximum est **n**. Et il peut n''en faire **aucune** — rien n''oblige un élève à
sortir —, donc le minimum est **0**.

Du côté **SORTIE** : une sortie emmène **plusieurs** élèves, donc le maximum est
**n**. Et l''énoncé précise qu''elle est effectuée par **au moins un** élève, donc
le minimum est **1**.

*C''est la phrase « au moins un » de l''énoncé qui impose le 1. Sans elle, on
aurait écrit (0,n).*

**Exercice 2 — question 1.**

**`Matricule`** est la **clé primaire** de la table ELEVE : elle identifie de
façon unique chaque élève, ses valeurs sont uniques et non nulles.

**`#NumClasse`** est une **clé étrangère** : c''est un champ de ELEVE qui fait
référence à la clé primaire `NumClasse` de la table CLASSE. Il indique à quelle
classe appartient l''élève.

**Exercice 2 — question 2.**

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

*Trois exigences.* La **table CLASSE doit exister avant**, puisqu''on la
référence. **Pas de virgule** après la dernière ligne, avant la parenthèse
fermante — cette faute traîne dans plusieurs corrigés en circulation. Et le type
**`DATE`** pour la date de naissance, sans quoi on ne pourrait ni trier ni
comparer.

**Exercice 2 — question 3.** Cette requête **affiche le nom et le prénom des
élèves de la classe numéro 2, triés par ordre alphabétique croissant des
noms**.

*Pour une réponse complète, nomme les trois parties* : `SELECT Nom, Prenom` est
la projection, `WHERE NumClasse = 2` la sélection, `ORDER BY Nom ASC` le tri
croissant.

**Exercice 2 — question 4.**

```sql
SELECT Nom, Prenom FROM ELEVE WHERE Sexe = ''Féminin'';
```

*Deux précautions.* Les **apostrophes simples** autour de la valeur : les
doubles apostrophes qu''on voit dans certains corrigés **ne sont pas valides en
SQL**. Et la valeur exacte dépend de ce qui est stocké dans la table — `''F''` si
la colonne contient des initiales.

---

**Ce que ce sujet t''apprend sur l''épreuve**

La partie II vaut 7 points et se partage toujours de la même façon : **3 points
de système d''information** — MCD, MLD, cardinalités — et **4 points de base de
données** — vocabulaire et requêtes SQL.

Et regarde le détail des 4 points SQL : un point de **vocabulaire**, un point de
**CREATE**, un point de **lecture** d''une requête, un point d''**écriture** d''un
`SELECT`. Aucune requête compliquée, aucune jointure.

Autrement dit : savoir écrire un `CREATE TABLE` propre et un `SELECT … WHERE`
rapporte la moitié de la partie. Ce sont les deux requêtes à savoir écrire les
yeux fermés.
', NULL, 34),
      (v_chapitre_id, 'Quiz du chapitre 18', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce que Microsoft Access ?",
      "choix": [
        "Un tableur",
        "Un SGBD relationnel de la suite MS Office",
        "Un traitement de texte",
        "Un langage de requêtes"
      ],
      "bonne": 1,
      "explication": "Il propose une interface graphique complète, et convient aux petites et moyennes bases. Son fichier porte l''extension .accdb."
    },
    {
      "question": "Quels sont les deux modes d''affichage d''une table sous Access ?",
      "choix": [
        "Mode lecture et mode écriture",
        "Mode Création et mode Feuille de données",
        "Mode SQL et mode graphique",
        "Mode table et mode requête"
      ],
      "bonne": 1,
      "explication": "Le mode Création définit la structure — c''est le CREATE TABLE graphique — et le mode Feuille de données sert à saisir et consulter."
    },
    {
      "question": "Quel objet d''une base Access contient les données ?",
      "choix": [
        "La requête",
        "Le formulaire",
        "La table",
        "L''état"
      ],
      "bonne": 2,
      "explication": "C''est le seul objet indispensable : sans table, il n''y a pas de base. La requête interroge, le formulaire saisit, l''état imprime."
    },
    {
      "question": "Quel type Access correspond au VARCHAR de SQL ?",
      "choix": [
        "Texte long",
        "Texte court",
        "Numérique",
        "NuméroAuto"
      ],
      "bonne": 1,
      "explication": "Texte court accepte jusqu''à 255 caractères. Texte long correspond au type TEXT, pour une observation ou un commentaire."
    },
    {
      "question": "Comment définit-on la clé primaire d''une table sous Access ?",
      "choix": [
        "En nommant le champ « clé »",
        "En sélectionnant le champ puis en cliquant sur le bouton Clé primaire du ruban",
        "En le plaçant en première ligne",
        "Access la choisit toujours seul"
      ],
      "bonne": 1,
      "explication": "Une petite clé apparaît alors à gauche du champ. Si on enregistre sans en définir une, Access propose d''en créer une en NuméroAuto."
    },
    {
      "question": "Access refuse une ligne en signalant un doublon. Que faut-il faire ?",
      "choix": [
        "Supprimer la clé primaire",
        "Vérifier la valeur saisie : faute de frappe, ou élève déjà enregistré",
        "Changer le type du champ",
        "Redémarrer Access"
      ],
      "bonne": 1,
      "explication": "Le refus n''est pas un défaut : c''est la contrainte d''intégrité qui protège la cohérence de la base. Supprimer la clé serait la pire des réponses."
    },
    {
      "question": "Dans un MCD, « une sortie est effectuée par au moins un élève » impose quelle cardinalité minimale du côté SORTIE ?",
      "choix": [
        "0",
        "1",
        "n",
        "Aucune"
      ],
      "bonne": 1,
      "explication": "« Au moins un » impose le minimum à 1. Sans cette phrase, on aurait écrit (0,n). C''est la question du Baccalauréat 2023."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 18, Création d''une base de données sous MS Access.', v_nom;
  END LOOP;
END $inf7$;
