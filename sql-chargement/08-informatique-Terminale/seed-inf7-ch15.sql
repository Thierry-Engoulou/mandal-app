-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 15 : Les fonctions d'un SGBD
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
    WHERE programme_id = v_programme_id AND ordre = 15;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les fonctions d''un SGBD', 15, 'Module 2 : Systèmes d''information et base de données')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 15 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 15 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Donnée, base de données et modèles', 1, 'texte', '
Nouveau sujet : on passe du modèle sur le papier à la base réelle.

### Les définitions

Une **donnée** est une **information codée** de façon à pouvoir être **traitée
automatiquement** par une machine.

Une **base de données** est un **ensemble structuré de données liées à un ou
plusieurs domaines** du monde réel.

Le mot qui compte est **structuré**. Un dossier plein de fichiers Word n''est pas
une base de données : il n''y a pas de structure commune, et rien ne garantit la
cohérence.

### Ses trois avantages

Le cours les énumère, et la question « citer les avantages d''une base de
données » tombe régulièrement.

**La centralisation.** Les données sont rassemblées en un seul endroit, ce qui
**évite les doublons**. L''adresse d''un élève est écrite une fois, pas dans
quatre fichiers différents.

**L''intégrité.** Des **règles garantissent la cohérence** : une note reste entre
0 et 20, une commande appartient toujours à un client qui existe.

**Le partage.** Plusieurs utilisateurs accèdent aux mêmes données **en même
temps**, chacun avec ses droits.

### Les quatre modèles, dans l''ordre historique

| Modèle | Son principe |
| --- | --- |
| **hiérarchique** | les données en arbre, chaque fils a un seul père |
| **réseau** | un fils peut avoir plusieurs pères |
| **relationnel** | des **tables** reliées par des **champs communs** |
| **orienté objet** | les données et les traitements réunis en objets |

Le **modèle relationnel est le plus utilisé**, et c''est le seul au programme. Il
**relie les tables entre elles par des champs communs** — ce que nous avons
appelé les clés étrangères au chapitre précédent.

Retiens l''ordre : **hiérarchique, réseau, relationnel, objet**. On demande
parfois de les citer « dans l''ordre de leur apparition ».

---

**Exercice corrigé**

*Définir « base de données » et citer ses trois principaux avantages.*

**Correction.**

Une base de données est un **ensemble structuré de données liées à un ou
plusieurs domaines** du monde réel.

*Ses trois avantages :*

**La centralisation** : les données sont rassemblées en un seul endroit, ce qui
évite les doublons et les versions contradictoires.

**L''intégrité** : des règles garantissent la cohérence des données, et empêchent
d''enregistrer des valeurs impossibles.

**Le partage** : plusieurs utilisateurs peuvent accéder aux mêmes données
simultanément, chacun selon ses droits.
', NULL, 24),
      (v_chapitre_id, 'Simulation : pourquoi une base plutôt que des fichiers ?', 2, 'interactif', '{
  "widget": "modeles-bd",
  "consigne": "Deux systèmes fonctionnent côte à côte : à gauche quatre fichiers séparés, à droite une base de données. Change l''adresse d''un élève et regarde ce qui se passe de chaque côté — à gauche, trois fichiers sur quatre gardent l''ancienne adresse. Essaie ensuite d''enregistrer une note de 25 sur 20 : seule la base la refuse. Un troisième volet compare les quatre modèles historiques."
}', NULL, 10),
      (v_chapitre_id, 'Le SGBD et ses fonctions', 3, 'texte', '
### La définition

Un **SGBD** — **système de gestion de bases de données** — est un **logiciel**
qui permet de **décrire, modifier, interroger et administrer** les données d''une
base.

C''est l''intermédiaire obligé : on ne touche jamais aux fichiers de la base
directement, on passe par le SGBD.

### Ses deux composantes

Le **moteur** est la **composante principale** : c''est lui qui exécute
réellement les opérations sur les données.

L''**interface** donne un **accès convivial** : elle permet aussi la **sauvegarde
et la restauration** de la base.

### Ses cinq fonctions

Le programme demande de les **lister**, et c''est une question de pure mémoire.

**1. La définition des données** — créer et modifier la structure : tables,
colonnes, contraintes.

**2. La manipulation des données** — insérer, modifier, supprimer, rechercher.

**3. L''intégrité et la gestion des accès concurrents** — garantir la cohérence,
et empêcher deux utilisateurs de se gêner quand ils écrivent en même temps.

**4. La confidentialité** — gérer les droits : qui a le droit de voir quoi, et
de modifier quoi.

**5. La sécurité du fonctionnement** — sauvegarder, restaurer, et redémarrer
proprement après une panne.

### Les SGBD relationnels à citer

Le cours en nomme cinq, et il faut pouvoir en citer au moins deux.

**Microsoft Access** — un SGBD relationnel de la suite MS Office, avec une
interface graphique. C''est celui du programme, au chapitre 18.

**Microsoft SQL Server** — le successeur d''Access pour les grosses
applications.

**MySQL** — un logiciel **libre**, très répandu sur le web.

**Oracle Database** — un environnement de développement complet, avec un noyau
SGBD puissant.

**PostgreSQL** — un logiciel **libre** offrant plus de fonctionnalités que
MySQL.

---

**Exercice corrigé**

*Donner la signification du sigle SGBD, puis lister trois de ses fonctions, et
citer deux exemples de SGBD relationnels.*

**Correction.**

**SGBD** signifie **système de gestion de bases de données**. C''est un logiciel
qui permet de décrire, modifier, interroger et administrer les données d''une
base.

*Trois de ses fonctions :*

la **définition des données**, c''est-à-dire la création et la modification de la
structure ;
la **manipulation des données** : insertion, modification, suppression,
recherche ;
la **confidentialité**, par la gestion des droits d''accès des utilisateurs.

*On accepte aussi l''intégrité avec la gestion des accès concurrents, et la
sécurité de fonctionnement.*

*Deux exemples :* **Microsoft Access** et **MySQL**. On accepte également SQL
Server, Oracle et PostgreSQL.

*La signification du sigle valait un point au Baccalauréat 2024, posée en même
temps que celle de SQL.*
', NULL, 26),
      (v_chapitre_id, 'Simulation : les cinq fonctions d''un SGBD', 4, 'interactif', '{
  "widget": "fonctions-sgbd",
  "consigne": "Dix opérations te sont demandées sur une base de lycée : créer une table, ajouter un élève, empêcher deux secrétaires d''écrire la même ligne en même temps, interdire aux professeurs de voir les salaires, restaurer après une coupure. Range chacune dans la bonne fonction du SGBD. La simulation te montre ensuite le moteur et l''interface travailler séparément sur la même demande."
}', NULL, 10),
      (v_chapitre_id, 'La structure d''une base de données relationnelle', 5, 'texte', '
Le modèle relationnel ne connaît qu''une seule forme : la **table**. Tout le
reste en découle.

### La table

Une **table** **regroupe les données relatives à un même sujet**, dans une
disposition en grille.

Une table par entité, comme la règle 1 du passage au MLD nous l''a appris.

### La colonne

Une **colonne**, ou **champ**, représente **une propriété élémentaire** de
l''objet.

Chaque colonne possède :

un **nom** ;
un **type de données** ;
une **taille maximale** ;
un **caractère obligatoire ou non** ;
une **valeur par défaut**, facultative ;
une **règle sur les valeurs autorisées**, facultative.

### La ligne

Une **ligne**, ou **enregistrement**, ou **tuple**, est **une occurrence du
sujet** : elle correspond à **un objet du monde réel**.

Une ligne de la table ELEVE, c''est un élève.

### La clé primaire

Une **colonne ou un groupe de colonnes qui identifie de façon unique chaque
ligne**.

Ses valeurs sont **uniques** et **non nulles**. Le SGBD refuse d''enregistrer
deux lignes avec la même clé primaire, et refuse une clé primaire vide.

### La clé étrangère

Pour **relier la table A et la table B**, on **ajoute à la table B une colonne
qui contient la clé primaire de A**.

C''est le lien, et c''est la seule façon de relier deux tables dans le modèle
relationnel.

### Les contraintes d''intégrité

Ce sont des **règles sur une colonne ou sur une table, qui doivent toujours être
vraies**.

*Deux exemples du cours* : une note doit être **comprise entre 0 et 20** ; une
quantité commandée est **obligatoire** et doit être **strictement positive**.

Le SGBD **refuse** toute donnée qui violerait une contrainte. C''est ce qui fait
la différence entre une base de données et un simple tableau.

### Fichier et table ne sont pas la même chose

Un point que le cours souligne, et qui surprend : les **données d''une table
peuvent être réparties sur plusieurs fichiers**, et **un seul fichier peut
contenir les données de plusieurs tables**.

La table est une **vue logique**, le fichier est un **rangement physique**. Ce
n''est pas la même chose, et c''est le SGBD qui fait le pont.

### Le type de relation

Le lien ainsi créé est une relation « **un à plusieurs** » : **une ligne de A
peut correspondre à plusieurs lignes de B, mais chaque ligne de B ne correspond
qu''à une seule ligne de A**.

Sur le schéma graphique, on note **(1,n)** du côté de la clé étrangère et
**(1,1)** du côté de la clé primaire référencée.

---

**Exercice corrigé**

*Soit la table ARTICLE suivante :*

| Identifiant | Designation | Prix | Quantite | NumMagasin |
| --- | --- | --- | --- | --- |
| A001 | Ordinateur portable | 250 000 | 12 | M1 |
| A002 | Imprimante laser | 180 000 | 5 | M1 |
| A003 | Onduleur 650 VA | 65 000 | 20 | M2 |

*1. Combien cette table a-t-elle de champs et d''enregistrements ?*
*2. Que représente la colonne NumMagasin ?*

**Correction.**

**1.** La table a **5 champs** — Identifiant, Designation, Prix, Quantite,
NumMagasin — et **3 enregistrements**, un par ligne de données.

*Attention : la ligne d''en-tête n''est pas un enregistrement. C''est l''erreur
habituelle.*

**2.** `NumMagasin` est une **clé étrangère**. C''est une colonne de la table
ARTICLE qui **fait référence à la clé primaire de la table MAGASIN**, et qui
indique dans quel magasin l''article est stocké.

*La clé primaire de ARTICLE, elle, est `Identifiant`.*
', NULL, 28),
      (v_chapitre_id, 'Figure : deux tables, et la clé qui les relie', 6, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 270" width="560" height="270">
<rect width="560" height="270" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Deux tables, et la clé qui les relie</text>

<text x="30" y="48" font-size="11" font-weight="700" fill="#2563eb">Table CLASSE</text>
<rect x="30" y="56" width="90" height="24" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<rect x="120" y="56" width="110" height="24" fill="#dbeafe" stroke="#2563eb" stroke-width="1.4"/>
<text x="75" y="72" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">CodeClasse</text>
<text x="175" y="72" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">NomClasse</text>
<g font-size="10" fill="#334155">
<rect x="30" y="80" width="90" height="22" fill="#ffffff" stroke="#cbd5e1"/><rect x="120" y="80" width="110" height="22" fill="#ffffff" stroke="#cbd5e1"/>
<text x="75" y="95" text-anchor="middle">T1</text><text x="175" y="95" text-anchor="middle">Terminale C</text>
<rect x="30" y="102" width="90" height="22" fill="#f8fafc" stroke="#cbd5e1"/><rect x="120" y="102" width="110" height="22" fill="#f8fafc" stroke="#cbd5e1"/>
<text x="75" y="117" text-anchor="middle">T2</text><text x="175" y="117" text-anchor="middle">Terminale D</text>
</g>
<text x="30" y="142" font-size="9" fill="#2563eb">↑ clé primaire : unique et non nulle</text>

<text x="300" y="48" font-size="11" font-weight="700" fill="#15803d">Table ELEVE</text>
<rect x="300" y="56" width="74" height="24" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<rect x="374" y="56" width="86" height="24" fill="#dcfce7" stroke="#15803d" stroke-width="1.4"/>
<rect x="460" y="56" width="74" height="24" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.4"/>
<text x="337" y="72" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">Matricule</text>
<text x="417" y="72" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">Nom</text>
<text x="497" y="72" text-anchor="middle" font-size="9" font-weight="700" fill="#7f1d1d">#CodeClasse</text>
<g font-size="10" fill="#334155">
<rect x="300" y="80" width="74" height="22" fill="#ffffff" stroke="#cbd5e1"/><rect x="374" y="80" width="86" height="22" fill="#ffffff" stroke="#cbd5e1"/><rect x="460" y="80" width="74" height="22" fill="#fef2f2" stroke="#cbd5e1"/>
<text x="337" y="95" text-anchor="middle">E101</text><text x="417" y="95" text-anchor="middle">Mbida</text><text x="497" y="95" text-anchor="middle">T1</text>
<rect x="300" y="102" width="74" height="22" fill="#f8fafc" stroke="#cbd5e1"/><rect x="374" y="102" width="86" height="22" fill="#f8fafc" stroke="#cbd5e1"/><rect x="460" y="102" width="74" height="22" fill="#fef2f2" stroke="#cbd5e1"/>
<text x="337" y="117" text-anchor="middle">E102</text><text x="417" y="117" text-anchor="middle">Ngono</text><text x="497" y="117" text-anchor="middle">T1</text>
<rect x="300" y="124" width="74" height="22" fill="#ffffff" stroke="#cbd5e1"/><rect x="374" y="124" width="86" height="22" fill="#ffffff" stroke="#cbd5e1"/><rect x="460" y="124" width="74" height="22" fill="#fef2f2" stroke="#cbd5e1"/>
<text x="337" y="139" text-anchor="middle">E103</text><text x="417" y="139" text-anchor="middle">Essomba</text><text x="497" y="139" text-anchor="middle">T2</text>
</g>
<text x="460" y="164" font-size="9" fill="#b91c1c">↑ clé étrangère</text>

<path d="M 75 128 C 75 180, 497 190, 497 150" fill="none" stroke="#b91c1c" stroke-width="1.6" stroke-dasharray="5 4"/>
<text x="280" y="196" text-anchor="middle" font-size="10" font-weight="700" fill="#b91c1c">chaque valeur de #CodeClasse doit exister dans CLASSE</text>

<rect x="30" y="212" width="504" height="46" rx="6" fill="#f1f5f9" stroke="#94a3b8" stroke-width="1.2"/>
<text x="44" y="230" font-size="10" font-weight="700" fill="#0f172a">Le vocabulaire</text>
<text x="44" y="248" font-size="10" fill="#334155">colonne = champ = attribut = propriété     ·     ligne = enregistrement = n-uplet = occurrence</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : explorer une base relationnelle', 7, 'interactif', '{
  "widget": "structure-table",
  "consigne": "Deux tables remplies s''affichent, et chaque élément est cliquable : la simulation te dit si tu as désigné un champ, un enregistrement, une clé primaire ou une clé étrangère. Essaie ensuite d''ajouter des lignes fautives — un identifiant en double, une clé primaire vide, un numéro de magasin qui n''existe pas, une note de 25 sur 20 — et vois la contrainte violée s''afficher à chaque refus."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 15', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qu''une base de données ?",
      "choix": [
        "Un dossier contenant des fichiers",
        "Un ensemble structuré de données liées à un ou plusieurs domaines",
        "Un logiciel de gestion",
        "Un tableau Excel"
      ],
      "bonne": 1,
      "explication": "Le mot qui compte est « structuré ». Un dossier plein de fichiers Word n''est pas une base de données."
    },
    {
      "question": "Que signifie le sigle SGBD ?",
      "choix": [
        "Système Général de Base de Données",
        "Système de Gestion de Bases de Données",
        "Structure Générale des Bases de Données",
        "Serveur de Gestion des Bases de Données"
      ],
      "bonne": 1,
      "explication": "C''est le logiciel qui permet de décrire, modifier, interroger et administrer les données. Question du Baccalauréat 2024."
    },
    {
      "question": "Quels sont les quatre modèles de bases de données, dans l''ordre historique ?",
      "choix": [
        "Relationnel, objet, hiérarchique, réseau",
        "Hiérarchique, réseau, relationnel, orienté objet",
        "Réseau, hiérarchique, objet, relationnel",
        "Objet, relationnel, réseau, hiérarchique"
      ],
      "bonne": 1,
      "explication": "Le relationnel est de loin le plus utilisé, et c''est le seul au programme : il relie les tables par des champs communs."
    },
    {
      "question": "Quelles sont les deux composantes d''un SGBD ?",
      "choix": [
        "Le serveur et le client",
        "Le moteur et l''interface",
        "La table et la requête",
        "Le LDD et le LMD"
      ],
      "bonne": 1,
      "explication": "Le moteur exécute les opérations, l''interface donne un accès convivial et permet la sauvegarde et la restauration."
    },
    {
      "question": "Combien d''enregistrements compte une table affichant une ligne d''en-tête et trois lignes de données ?",
      "choix": [
        "Quatre",
        "Trois",
        "Deux",
        "Cinq"
      ],
      "bonne": 1,
      "explication": "La ligne d''en-tête donne les noms des champs : ce n''est pas un enregistrement. C''est l''erreur de comptage habituelle."
    },
    {
      "question": "Qu''est-ce qu''une contrainte d''intégrité ?",
      "choix": [
        "Une clé primaire",
        "Une règle sur une colonne ou une table qui doit toujours être vraie",
        "Un type de données",
        "Une requête de vérification"
      ],
      "bonne": 1,
      "explication": "Une note entre 0 et 20, une quantité strictement positive. Le SGBD refuse toute donnée qui la violerait."
    },
    {
      "question": "Une table correspond-elle toujours à un fichier ?",
      "choix": [
        "Oui, une table est un fichier",
        "Non : une table peut être répartie sur plusieurs fichiers, et un fichier peut contenir plusieurs tables",
        "Oui, sauf dans Access",
        "Non, une table n''est jamais stockée dans un fichier"
      ],
      "bonne": 1,
      "explication": "La table est une vue logique, le fichier un rangement physique. C''est le SGBD qui fait le pont entre les deux."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 15, Les fonctions d''un SGBD.', v_nom;
  END LOOP;
END $inf7$;
