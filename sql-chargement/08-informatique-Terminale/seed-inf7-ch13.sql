-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 13 : Le modèle conceptuel de données
-- Module 2 : Systèmes d'information et base de données — 6 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 13;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Le modèle conceptuel de données', 13, 'Module 2 : Systèmes d''information et base de données')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 13 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 13 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Entité, propriété et identifiant', 1, 'texte', '
Nous entrons dans le modèle le plus demandé du programme. Le **MCD** apparaît à
toutes les sessions du Baccalauréat, et il vaut à lui seul entre 1,5 et 3
points.

### Ce que décrit le MCD

Le **modèle conceptuel de données** représente **de façon statique les données
manipulées** par l''organisation, et les **règles de gestion** qui s''y
appliquent.

« Statique » veut dire qu''il décrit ce qui **est**, pas ce qui **se passe** : il
dit qu''un élève appartient à une classe, pas la procédure d''inscription.

### Le vocabulaire, qui a plusieurs noms

Une même chose porte souvent plusieurs noms selon le contexte. Le cours les
donne tous, et l''examen peut employer l''un ou l''autre :

**colonne = champ = attribut = propriété**

**ligne = objet = n-uplet = enregistrement = occurrence**

### La propriété

Une **propriété** est la **plus petite information significative**.

Elle est dite **atomique** si ses valeurs ne peuvent pas être décomposées :
matricule, nom, prix sont atomiques.

*À l''inverse*, « adresse complète » ne l''est pas : elle se décompose en rue,
quartier, ville. En pratique, on décompose jusqu''à ce que chaque propriété ne
porte plus qu''une seule information.

### L''entité

Une **entité** est un **élément matériel ou immatériel important pour le
système**.

On la dessine sous forme de **rectangle** : le **libellé en haut**, la **liste
des propriétés en bas**.

Matériel : un élève, un article, une salle. Immatériel : une commande, une
réservation, un compte.

Par convention, le nom d''une entité s''écrit **au singulier** et **en
majuscules** : ELEVE, et non « les élèves ».

### L''identifiant

L''**identifiant** est **une ou plusieurs propriétés qui désignent une entité et
une seule**.

On le **souligne** dans le rectangle. Certains auteurs le font précéder d''un
dièse.

**Chaque entité doit en avoir un.** C''est une règle absolue : une entité sans
identifiant est une faute.

Comment le trouver : c''est la propriété **unique** pour chaque occurrence. Le
matricule d''un élève, la référence d''un article, le numéro d''une commande.

**Jamais le nom.** Deux élèves peuvent s''appeler NGONO Paul.

---

**Exercice corrigé**

*Un lycée gère ses élèves. Un élève est caractérisé par un matricule unique, un
nom, un prénom, une date de naissance et un lieu de naissance. Dessiner
l''entité.*

**Correction.**

```
┌──────────────────┐
│      ELEVE       │
├──────────────────┤
│  Matricule       │   ← souligné : c''est l''identifiant
│  Nom             │
│  Prenom          │
│  DateNaissance   │
│  LieuNaissance   │
└──────────────────┘
```

*Les trois points notés.* Le **nom de l''entité au singulier et en majuscules**,
en haut du rectangle. Les **propriétés en dessous**. Et le **Matricule
souligné**, parce que l''énoncé dit « unique ».

*Remarque que « Nom » et « Prenom » sont deux propriétés distinctes, et non une
seule « NomPrenom » : on décompose jusqu''à l''atome, sans quoi on ne pourra
jamais trier par nom de famille.*
', NULL, 26),
      (v_chapitre_id, 'Simulation : construire une entité', 2, 'interactif', '{
  "widget": "entite-propriete",
  "consigne": "Un énoncé te décrit un objet du réel — un élève, un article, une salle — et une liste de propriétés en vrac t''est donnée, dont certaines ne sont pas atomiques. Construis l''entité : nomme-la, choisis ses propriétés, désigne l''identifiant. La simulation refuse une entité sans identifiant, signale les propriétés décomposables, et t''avertit quand tu choisis le nom comme identifiant — en te montrant deux élèves homonymes."
}', NULL, 10),
      (v_chapitre_id, 'Associations et cardinalités', 3, 'texte', '
Les entités seules ne suffisent pas : il faut dire **comment elles sont liées**.

### L''association

Une **association** est un **lien sémantique entre entités**, souvent exprimé
par un **verbe**.

On la dessine sous forme d''**hexagone** ou d''**ellipse**, et elle peut **porter
des propriétés**.

*Exemples du cours* : une commande **CONCERNE** des articles ; un service
**COMPREND** des employés.

**Selon le nombre d''entités liées**, elle est :

**récursive** — une entité avec elle-même : un employé DIRIGE un employé ;
**binaire** — deux entités, le cas de loin le plus fréquent ;
**ternaire** — trois entités ;
**n-aire** — davantage.

### Les propriétés portées par une association

Une propriété se met **sur l''association** quand elle ne dépend **ni de l''une ni
de l''autre entité seule**, mais **des deux ensemble**.

La **quantité commandée** ne dépend ni de la commande seule ni de l''article
seul : elle dépend du couple. Elle se place donc sur l''association CONCERNE.

C''est un point de finesse qui distingue une bonne copie.

### Les cardinalités

Les **cardinalités** indiquent, **pour chaque couple (entité, association)**, le
**nombre minimal et maximal d''occurrences** en jeu.

On les écrit **(min, max)** du côté de l''entité, sur le trait qui la relie à
l''association.

**Quatre couples seulement sont utilisés**, et il faut le savoir :

**(0,1)** — **(1,1)** — **(1,n)** — **(0,n)**

Toute autre écriture est une faute.

**La cardinalité minimale** vaut **0** ou **1**. Elle vaut 1 si la participation
est **obligatoire**, 0 si elle est **facultative**.

*L''exemple du cours* : un client **doit** passer au moins une commande, donc
min = 1 ; un prospect n''en a pas encore passé, donc min = 0.

**La cardinalité maximale** vaut **1** ou **n**. Elle vaut 1 si l''occurrence
participe **au plus une fois**, n si la participation est **multiple**.

### Comment les trouver sans se tromper

On se place **du côté d''une entité** et on pose **deux questions**, toujours les
mêmes :

> *« Une occurrence de cette entité participe-t-elle **au minimum** zéro ou une
> fois ? »*
>
> *« Et **au maximum**, une seule fois ou plusieurs ? »*

Puis on recommence de l''autre côté.

Le piège : on écrit souvent la cardinalité **du mauvais côté**. Retiens qu''elle
se lit **en partant de l''entité qu''elle touche**.

### Les quatre étapes de construction

Le cours les énumère, et il faut les suivre dans cet ordre :

1. **Repérer les concepts pertinents** et en déduire les **entités**.
2. **Rattacher les propriétés** à chaque entité.
3. **Identifier les associations**, généralement grâce aux **verbes d''action**.
4. **Étudier les cardinalités** de chaque couple entité-association, à partir
des **règles de gestion**.

---

**Exercice corrigé**

*Un directeur d''agence de location de salles de spectacle veut informatiser sa
gestion. Règles de gestion :*

*RG1 : une personne peut faire plusieurs réservations, mais une réservation
n''est faite que par une personne.*
*RG2 : une réservation concerne une ou plusieurs salles, et une salle peut être
concernée par plusieurs réservations.*
*RG3 : une personne est définie par un code unique, un nom, un prénom, un
contact et un numéro de CNI.*
*RG4 : une réservation possède un numéro unique et une date.*
*RG5 : une salle possède un numéro unique, un nom, une capacité et une adresse.*

*Élaborer le MCD.*

**Correction.**

*Étape 1 — les entités*, données par les noms : **PERSONNE**, **RESERVATION**,
**SALLE**.

*Étape 2 — les propriétés et les identifiants*, données par RG3, RG4 et RG5 :

```
PERSONNE                RESERVATION           SALLE
  CodePersonne            NumReservation        NumSalle
  Nom                     DateReservation       NomSalle
  Prenom                                        Capacite
  Contact                                       Adresse
  NumeroCNI
```

Les trois propriétés dites « uniques » sont **soulignées** : ce sont les
identifiants.

*Étape 3 — les associations*, données par les verbes : **FAIRE** entre PERSONNE
et RESERVATION, **CONCERNER** entre RESERVATION et SALLE.

*Étape 4 — les cardinalités*, données par RG1 et RG2 :

```
PERSONNE (1,n) ──── FAIRE ──── (1,1) RESERVATION
RESERVATION (1,n) ──── CONCERNER ──── (1,n) SALLE
```

*Comment on les a trouvées.* « Une personne peut faire **plusieurs**
réservations » donne le n du côté PERSONNE ; « une réservation n''est faite que
par **une** personne » donne le 1 du côté RESERVATION. Pour RG2, les deux sens
disent « plusieurs », d''où **(1,n)** des deux côtés.

*Ce sujet est celui du Baccalauréat 2025, exercice 1 de la partie II, noté sur
3 points : 1,5 pour les entités avec leurs propriétés et identifiants, 0,5 pour
les relations, 1 pour les cardinalités.*
', NULL, 32),
      (v_chapitre_id, 'Figure : un MCD, puis le MLD qu''on en déduit', 4, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 290" width="560" height="290">
<rect width="560" height="290" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Un MCD, puis le MLD qu&apos;on en déduit</text>

<rect x="24" y="40" width="150" height="94" rx="4" fill="#ffffff" stroke="#2563eb" stroke-width="2"/>
<rect x="24" y="40" width="150" height="22" fill="#2563eb"/>
<text x="99" y="56" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">CLASSE</text>
<text x="34" y="78" font-size="10" font-weight="700" fill="#1e3a8a" text-decoration="underline">CodeClasse</text>
<text x="34" y="96" font-size="10" fill="#334155">NomClasse</text>
<text x="34" y="114" font-size="10" fill="#334155">Effectif</text>

<polygon points="256,62 300,87 256,112 212,87" fill="#fef3c7" stroke="#ca8a04" stroke-width="2"/>
<text x="256" y="91" text-anchor="middle" font-size="10" font-weight="700" fill="#78350f">CONTIENT</text>

<rect x="338" y="40" width="150" height="94" rx="4" fill="#ffffff" stroke="#15803d" stroke-width="2"/>
<rect x="338" y="40" width="150" height="22" fill="#15803d"/>
<text x="413" y="56" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">ELEVE</text>
<text x="348" y="78" font-size="10" font-weight="700" fill="#14532d" text-decoration="underline">Matricule</text>
<text x="348" y="96" font-size="10" fill="#334155">Nom</text>
<text x="348" y="114" font-size="10" fill="#334155">DateNaissance</text>

<line x1="174" y1="87" x2="212" y2="87" stroke="#334155" stroke-width="1.6"/>
<line x1="300" y1="87" x2="338" y2="87" stroke="#334155" stroke-width="1.6"/>
<text x="193" y="80" text-anchor="middle" font-size="10" font-weight="700" fill="#b91c1c">1,n</text>
<text x="319" y="80" text-anchor="middle" font-size="10" font-weight="700" fill="#b91c1c">1,1</text>

<text x="280" y="152" text-anchor="middle" font-size="11" font-weight="700" fill="#64748b">↓ règle 2 : l&apos;identifiant du côté (1,n) migre vers la table du côté (1,1)</text>

<rect x="24" y="170" width="226" height="94" rx="4" fill="#eff6ff" stroke="#2563eb" stroke-width="1.6"/>
<text x="34" y="190" font-size="11" font-weight="700" fill="#1e3a8a">CLASSE</text>
<text x="34" y="210" font-size="10" font-family="monospace" fill="#334155">CodeClasse  — clé primaire</text>
<text x="34" y="228" font-size="10" font-family="monospace" fill="#334155">NomClasse</text>
<text x="34" y="246" font-size="10" font-family="monospace" fill="#334155">Effectif</text>

<rect x="300" y="170" width="236" height="94" rx="4" fill="#f0fdf4" stroke="#15803d" stroke-width="1.6"/>
<text x="310" y="190" font-size="11" font-weight="700" fill="#14532d">ELEVE</text>
<text x="310" y="210" font-size="10" font-family="monospace" fill="#334155">Matricule   — clé primaire</text>
<text x="310" y="228" font-size="10" font-family="monospace" fill="#334155">Nom</text>
<text x="310" y="246" font-size="10" font-family="monospace" fill="#b91c1c">#CodeClasse — clé étrangère</text>

<line x1="250" y1="246" x2="300" y2="246" stroke="#b91c1c" stroke-width="1.6" stroke-dasharray="4 3"/>
<text x="275" y="280" text-anchor="middle" font-size="9" fill="#b91c1c">le # marque la clé étrangère</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : poser les cardinalités', 5, 'interactif', '{
  "widget": "cardinalites",
  "consigne": "Un MCD à deux entités s''affiche, et les cardinalités sont vides. La simulation te pose les deux questions dans l''ordre — au minimum zéro ou une fois, au maximum une ou plusieurs — et place ta réponse du bon côté du trait. Elle refuse toute écriture hors des quatre couples autorisés, et un panneau te montre, occurrence par occurrence, ce que ta cardinalité autorise réellement dans la base."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 13', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qu''une propriété atomique ?",
      "choix": [
        "Une propriété obligatoire",
        "Une propriété dont les valeurs ne peuvent pas être décomposées",
        "L''identifiant de l''entité",
        "Une propriété portée par une association"
      ],
      "bonne": 1,
      "explication": "Matricule, nom et prix sont atomiques. « Adresse complète » ne l''est pas : elle se décompose en rue, quartier, ville."
    },
    {
      "question": "Comment représente-t-on une entité dans un MCD ?",
      "choix": [
        "Par un hexagone",
        "Par un rectangle, libellé en haut et propriétés en bas",
        "Par une ellipse",
        "Par un losange"
      ],
      "bonne": 1,
      "explication": "L''hexagone ou l''ellipse, c''est l''association. Et le nom de l''entité s''écrit au singulier et en majuscules."
    },
    {
      "question": "Que fait-on de l''identifiant d''une entité dans le dessin ?",
      "choix": [
        "On le met en gras",
        "On le souligne",
        "On l''écrit en rouge",
        "On le place en dernier"
      ],
      "bonne": 1,
      "explication": "Certains auteurs le font aussi précéder d''un dièse. Et chaque entité doit en avoir un : une entité sans identifiant est une faute."
    },
    {
      "question": "Pourquoi le nom d''une personne ne peut-il pas servir d''identifiant ?",
      "choix": [
        "Il est trop long",
        "Parce que deux personnes peuvent porter le même nom",
        "Parce qu''il contient des espaces",
        "Parce qu''il change avec le temps"
      ],
      "bonne": 1,
      "explication": "Un identifiant désigne une occurrence ET UNE SEULE. Deux élèves peuvent s''appeler NGONO Paul : le matricule, lui, est unique."
    },
    {
      "question": "Quels sont les quatre couples de cardinalités autorisés ?",
      "choix": [
        "(0,1), (1,1), (1,n) et (0,n)",
        "(1,1), (2,2), (1,n) et (n,n)",
        "(0,0), (0,1), (1,0) et (1,1)",
        "Tous les couples sont possibles"
      ],
      "bonne": 0,
      "explication": "La minimale vaut 0 ou 1, la maximale vaut 1 ou n. Toute autre écriture est une faute."
    },
    {
      "question": "Où place-t-on la quantité commandée dans un MCD reliant COMMANDE et ARTICLE ?",
      "choix": [
        "Dans l''entité COMMANDE",
        "Dans l''entité ARTICLE",
        "Sur l''association CONCERNE",
        "Elle ne figure pas au MCD"
      ],
      "bonne": 2,
      "explication": "Elle ne dépend ni de la commande seule ni de l''article seul, mais du couple. C''est le point de finesse qui distingue une bonne copie."
    },
    {
      "question": "« Une réservation n''est faite que par une seule personne. » Quelle cardinalité du côté RESERVATION ?",
      "choix": [
        "(0,n)",
        "(1,n)",
        "(1,1)",
        "(0,1)"
      ],
      "bonne": 2,
      "explication": "Une seule personne, et toujours une : maximum 1, minimum 1. C''est l''exercice du Baccalauréat 2025."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 6 leçons ajoutées au chapitre 13, Le modèle conceptuel de données.', v_nom;
  END LOOP;
END $inf7$;
