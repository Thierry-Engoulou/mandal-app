-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 14 : Le modèle logique de données
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
    WHERE programme_id = v_programme_id AND ordre = 14;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Le modèle logique de données', 14, 'Module 2 : Systèmes d''information et base de données')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 14 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 14 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Du MCD au MLD : les notions préalables', 1, 'texte', '
Le MCD décrit le réel. Il n''est **pas** implantable tel quel dans une base de
données : il faut le **transformer**. C''est le rôle du MLD, et le programme
demande explicitement d''**énoncer les règles de passage** puis de les
**utiliser**.

### Ce qu''est le MLD

Le **modèle logique de données** décrit la **structure des données
indépendamment de tout langage de programmation**.

Il se situe **entre le MCD et le modèle physique** : c''est le MCD complété par
l''**organisation logique des données**, optimisée selon les traitements prévus.

Autrement dit : le MCD parle d''**entités et d''associations**, le MLD parle de
**tables, de clés primaires et de clés étrangères**.

### La clé primaire

Une **clé primaire** **identifie de façon unique un enregistrement**. Ses
valeurs sont **uniques** et **non nulles**.

C''est l''identifiant du MCD, devenu clé dans la table.

### La clé étrangère

Une **clé étrangère** est un **champ — ou un ensemble de champs — d''une table
qui fait référence à la clé primaire d''une autre table**.

C''est elle qui **matérialise le lien** entre deux tables. Dans le MCD, le lien
était un dessin ; dans le MLD, c''est une colonne.

On la note en la faisant précéder d''un **dièse** : `#CodeClasse`.

### Les deux écritures du MLD

**L''écriture textuelle.** On décrit chaque table par son nom suivi de ses
colonnes entre parenthèses, la **clé primaire en premier** et les **clés
étrangères marquées d''un dièse** :

```
CLASSE (CodeClasse, NomClasse, Effectif)
ELEVE  (Matricule, Nom, Prenom, #CodeClasse)
```

**L''écriture graphique.** Les clés primaires sont **soulignées**, et un **trait
relie les deux tables**. Du côté de la clé étrangère on note **(1,n)**, et du
côté de la clé primaire référencée **(1,1)**.

C''est une relation « **un à plusieurs** » : une ligne de la première table peut
correspondre à plusieurs lignes de la seconde, mais chaque ligne de la seconde
ne correspond qu''à une seule ligne de la première.

---

**Exercice corrigé**

*Dans le MLD `ELEVE (Matricule, Nom, Prenom, #NumClasse)`, donner la
signification de `Matricule` et de `#NumClasse`.*

**Correction.**

**`Matricule`** est la **clé primaire** de la table ELEVE. Elle identifie de
façon unique chaque enregistrement : ses valeurs sont uniques et non nulles, et
deux élèves ne peuvent pas porter le même matricule.

**`#NumClasse`** est une **clé étrangère**. C''est un champ de la table ELEVE qui
**fait référence à la clé primaire de la table CLASSE**. C''est lui qui indique à
quelle classe appartient l''élève, et c''est lui qui matérialise le lien entre les
deux tables.

*Le dièse est précisément la convention qui signale une clé étrangère : c''est ce
que la question teste.*

*Cette question est tombée au Baccalauréat 2023, pour un point.*
', NULL, 26),
      (v_chapitre_id, 'Simulation : clé primaire et clé étrangère', 2, 'interactif', '{
  "widget": "cles-tables",
  "consigne": "Deux tables te sont données, remplies de lignes. Désigne la clé primaire de chacune, puis la colonne qui fait le lien entre les deux. La simulation essaie alors d''insérer des lignes fautives — un matricule en double, un code de classe qui n''existe pas dans la table CLASSE — et te montre la base les refuser, en nommant la contrainte violée à chaque fois."
}', NULL, 10),
      (v_chapitre_id, 'Les quatre règles de passage', 3, 'texte', '
Le passage du MCD au MLD est **mécanique**. Quatre règles suffisent, et le
programme demande de les **énoncer**.

### Règle 1 — chaque entité devient une table

**Chaque entité devient une table.**

Son **identifiant devient la clé primaire**.

Ses **autres propriétés deviennent les attributs** de la table.

C''est la règle la plus simple, et on l''applique toujours en premier, pour toutes
les entités.

### Règle 2 — l''association « un à plusieurs »

C''est le cas de cardinalités **(x,1) d''un côté** et **(x,n) de l''autre**, où x
vaut 0 ou 1. C''est le cas le plus fréquent.

**L''identifiant du côté (x,n) migre vers la table du côté (x,1)**, où il devient
**clé étrangère**.

Les **propriétés de l''association migrent** vers l''entité de cardinalité (0,1) —
c''est-à-dire vers la même table.

*En cas d''association réflexive*, l''identifiant est **dupliqué puis renommé**.

**Aucune table nouvelle n''est créée.** C''est le point que les copies ratent le
plus souvent.

*Moyen de retenir le sens* : la clé migre **vers le côté qui ne peut en avoir
qu''un**. Un élève n''a qu''une classe, donc c''est l''élève qui porte le code de la
classe — et non l''inverse, car une classe a plusieurs élèves et ne pourrait pas
tous les loger dans une colonne.

### Règle 3 — l''association « un à un »

Cardinalités **(x,1)** des deux côtés.

**On crée une nouvelle table.**

Les **identifiants des deux entités y migrent**. Leur **ensemble forme la clé
primaire**, et **chacun devient clé étrangère**.

Les **propriétés de l''association** deviennent les autres attributs de cette
nouvelle table.

Les clés étrangères reçoivent en plus une **contrainte d''unicité**.

*En cas d''association réflexive*, l''identifiant est dupliqué puis renommé.

### Règle 4 — l''association « plusieurs à plusieurs »

Cardinalités **(x,n) des deux côtés**, ou association n-aire avec n supérieur
à 2.

**L''association devient une table.**

Sa **clé primaire est la composition des identifiants de toutes les entités
liées**.

Ses **attributs sont ceux de l''association**.

C''est ici que la **quantité commandée** trouve enfin sa place : dans la table
issue de l''association.

### Le tableau de décision

| Cardinalités maximales | Ce qu''on fait |
| --- | --- |
| **1 et n** | la clé **migre** vers le côté 1 — pas de table nouvelle |
| **1 et 1** | on crée une table avec les deux clés |
| **n et n** | l''association **devient** une table |

**Lis toujours les cardinalités maximales d''abord** : ce sont elles, et elles
seules, qui décident de la règle à appliquer.

---

**Exercice corrigé**

*Énoncer la règle de passage d''une association de cardinalités (1,n) et (1,1),
puis l''appliquer au MCD :*

```
CLASSE (1,n) ──── CONTIENT ──── (1,1) ELEVE
CLASSE : CodeClasse, NomClasse, Effectif
ELEVE  : Matricule, Nom, DateNaissance
```

**Correction.**

*La règle.* Pour une association dont les cardinalités sont (x,1) d''un côté et
(x,n) de l''autre, **l''identifiant de l''entité du côté (x,n) migre vers la table
de l''entité du côté (x,1), où il devient clé étrangère**. Aucune table nouvelle
n''est créée, et les éventuelles propriétés de l''association migrent avec.

*L''application.* Le côté (1,n) est CLASSE, le côté (1,1) est ELEVE. C''est donc
**CodeClasse qui migre vers ELEVE**.

```
CLASSE (CodeClasse, NomClasse, Effectif)
ELEVE  (Matricule, Nom, DateNaissance, #CodeClasse)
```

*La vérification de bon sens, à faire systématiquement* : un élève n''a qu''une
classe, et la colonne `#CodeClasse` ne peut contenir qu''une valeur — c''est
cohérent. Si l''on avait fait migrer `Matricule` vers CLASSE, il aurait fallu
loger quarante matricules dans une seule colonne, ce qui est impossible.

*C''est exactement la question posée au Baccalauréat 2024 : « déduire le modèle
logique de données correspondant », pour 1,5 point.*
', NULL, 32),
      (v_chapitre_id, 'Simulation : appliquer les règles de passage', 4, 'interactif', '{
  "widget": "passage-mcd-mld",
  "consigne": "Un MCD s''affiche avec ses cardinalités, et tu dois en déduire le MLD. La simulation te demande d''abord quelle règle s''applique, puis où la clé doit migrer, puis elle écrit les tables. Change les cardinalités et le MLD se reconstruit : fais passer un couple de (1,n) et (1,1) à (1,n) et (1,n), et regarde une table d''association apparaître. Un panneau te montre ce qui arriverait si la clé migrait du mauvais côté."
}', NULL, 10),
      (v_chapitre_id, 'Normaliser le MCD avant de le traduire', 5, 'texte', '
Un MCD juste n''est pas forcément un bon MCD. Le cours donne des **règles de
normalisation** à vérifier **avant** de passer au MLD.

### Sur les entités et les associations

Le **nom** d''une entité, d''une association ou d''un attribut est **unique** dans
tout le modèle. Deux entités ne peuvent pas s''appeler pareil, et une propriété
`Nom` ne doit pas apparaître dans deux entités sans être distinguée —
`NomEleve`, `NomClasse`.

Une **entité qui peut être remplacée par une association doit l''être**. Si
« INSCRIPTION » ne porte qu''un lien entre un élève et une classe, ce n''est pas
une entité : c''est une association.

Les **associations fantômes, redondantes ou en double sont éliminées**. Si l''on
peut déjà aller de A à C en passant par B, l''association directe de A vers C est
redondante et doit disparaître.

### Sur les identifiants

**Chaque entité possède un identifiant.** Sans exception.

### Sur les attributs

Les **attributs calculables sont retirés** des entités. Si le montant total se
calcule par prix × quantité, il ne figure pas dans le modèle : on le recalcule
au besoin.

Pourquoi : un attribut calculé stocké finit toujours par **contredire** ce dont
il est tiré, le jour où l''un change et pas l''autre.

Les **attributs d''une association dépendent directement des identifiants de
toutes les entités associées**. Sinon, ils sont mal placés.

### Sur les cardinalités

La **cardinalité minimale vaut 0 ou 1**, et la **cardinalité maximale vaut 1 ou
n**. Rien d''autre.

### La liste de contrôle avant de rendre

Avant de passer au MLD, relis ton MCD et vérifie :

1. Chaque entité a-t-elle un identifiant **souligné** ?
2. Chaque nom est-il **unique** dans le modèle ?
3. Les propriétés sont-elles toutes **atomiques** ?
4. Y a-t-il un **attribut calculable** qui traîne ?
5. Les cardinalités sont-elles toutes dans les **quatre couples** autorisés ?
6. Une **association redondante** peut-elle être supprimée ?

---

**Exercice corrigé**

*Critiquer ce MCD :*

```
FACTURE (NumFacture, DateFacture, MontantTotal)
LIGNE   (NumLigne, Designation, PrixUnitaire, Quantite, MontantLigne)
FACTURE (1,n) ──── COMPORTE ──── (1,1) LIGNE
```

**Correction.** Deux attributs sont fautifs, pour la même raison.

**`MontantLigne` est calculable** : il vaut `PrixUnitaire × Quantite`. Il doit
donc être **retiré** du modèle.

**`MontantTotal` est calculable** lui aussi : il vaut la somme des montants des
lignes de la facture. Il doit être **retiré** également.

*Pourquoi c''est une vraie faute, et pas un détail.* Le jour où l''on corrige une
quantité sans recalculer les deux totaux, la base se contredit elle-même : la
facture affiche un montant qui ne correspond plus à ses lignes. On ne stocke
jamais ce qu''on peut recalculer.

*Le MCD corrigé :*

```
FACTURE (NumFacture, DateFacture)
LIGNE   (NumLigne, Designation, PrixUnitaire, Quantite)
```

*Une remarque de plus, pour une copie excellente* : `Designation` et
`PrixUnitaire` décrivent en réalité un **article**, pas une ligne de facture. Un
meilleur modèle ferait apparaître une entité ARTICLE, reliée à FACTURE par une
association « plusieurs à plusieurs » portant la quantité.
', NULL, 28),
      (v_chapitre_id, 'Simulation : corriger un MCD fautif', 6, 'interactif', '{
  "widget": "normaliser-mcd",
  "consigne": "Six MCD te sont soumis, chacun avec un défaut : un attribut calculable, une entité sans identifiant, une association redondante, une cardinalité impossible, deux noms identiques, une propriété non atomique. Repère le défaut, corrige-le, et la simulation te montre le dégât concret que ton MCD aurait causé dans la base — notamment la facture qui finit par contredire ses propres lignes."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 14', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qu''une clé étrangère ?",
      "choix": [
        "La clé primaire d''une table",
        "Un champ d''une table qui fait référence à la clé primaire d''une autre table",
        "Une propriété calculable",
        "Un identifiant composé"
      ],
      "bonne": 1,
      "explication": "C''est elle qui matérialise le lien entre deux tables. On la note avec un dièse devant : #CodeClasse."
    },
    {
      "question": "Que devient une entité lors du passage au MLD ?",
      "choix": [
        "Une association",
        "Une table, dont l''identifiant devient la clé primaire",
        "Une clé étrangère",
        "Elle disparaît"
      ],
      "bonne": 1,
      "explication": "C''est la règle 1, et on l''applique toujours en premier, pour toutes les entités."
    },
    {
      "question": "Pour une association (1,n) d''un côté et (1,1) de l''autre, que fait-on ?",
      "choix": [
        "On crée une nouvelle table",
        "L''identifiant du côté (1,n) migre vers la table du côté (1,1) comme clé étrangère",
        "L''association devient une table",
        "On ne fait rien"
      ],
      "bonne": 1,
      "explication": "Aucune table nouvelle n''est créée. La clé migre vers le côté qui ne peut en avoir qu''un : l''élève porte le code de sa classe."
    },
    {
      "question": "Pour une association (1,n) des deux côtés, que fait-on ?",
      "choix": [
        "La clé migre vers la première table",
        "L''association devient une table, dont la clé primaire compose les identifiants des entités liées",
        "On supprime l''association",
        "On crée deux clés étrangères dans chaque table"
      ],
      "bonne": 1,
      "explication": "C''est là que les propriétés de l''association, comme la quantité commandée, trouvent enfin leur place."
    },
    {
      "question": "Que lit-on en premier pour choisir la règle de passage ?",
      "choix": [
        "Les cardinalités minimales",
        "Les cardinalités maximales",
        "Le nombre de propriétés",
        "Le nom de l''association"
      ],
      "bonne": 1,
      "explication": "Ce sont elles, et elles seules, qui décident : 1 et n, 1 et 1, ou n et n."
    },
    {
      "question": "Pourquoi retire-t-on les attributs calculables d''un MCD ?",
      "choix": [
        "Pour gagner de la place",
        "Parce qu''ils finissent par contredire ce dont ils sont tirés quand l''un change et pas l''autre",
        "Parce que SQL ne sait pas les stocker",
        "Parce qu''ils ralentissent la base"
      ],
      "bonne": 1,
      "explication": "Une facture qui affiche un montant ne correspondant plus à ses lignes : on ne stocke jamais ce qu''on peut recalculer."
    },
    {
      "question": "Dans ELEVE (Matricule, Nom, #NumClasse), que signifie le dièse ?",
      "choix": [
        "Que la propriété est obligatoire",
        "Que NumClasse est une clé étrangère référençant la table CLASSE",
        "Que NumClasse est la clé primaire",
        "Que la propriété est calculée"
      ],
      "bonne": 1,
      "explication": "C''est la convention du MLD. Question tombée au Baccalauréat 2023, pour un point."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 14, Le modèle logique de données.', v_nom;
  END LOOP;
END $inf7$;
