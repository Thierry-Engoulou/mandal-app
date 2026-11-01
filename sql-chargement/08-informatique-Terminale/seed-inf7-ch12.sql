-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 12 : Les méthodes de conception d'un système d'information
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
    WHERE programme_id = v_programme_id AND ordre = 12;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les méthodes de conception d''un système d''information', 12, 'Module 2 : Systèmes d''information et base de données')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 12 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 12 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le système d''information et ses méthodes de conception', 1, 'texte', '
Nouveau module. On quitte le matériel pour la **conception** : avant de créer
une base de données, il faut savoir ce qu''on va y mettre.

### Rappel : le système d''information

Un **système d''information** est un ensemble organisé de **ressources** —
humaines, matérielles et logicielles — qui permet de **collecter, stocker,
traiter et diffuser l''information**.

Son but : **la bonne information, à la bonne personne, au bon moment, sous la
bonne forme**.

### Les deux familles de méthodes

Le programme demande de **citer quelques méthodes de conception d''un système
d''information**. Elles se rangent en deux familles.

**Les méthodes systémiques** considèrent le système comme un **ensemble
d''éléments reliés entre eux**.

Exemples : **MERISE**, **AXIAL**, **Information Engineering (IE)**.

*Leurs avantages* : une meilleure **cohérence des données**, et le respect des
niveaux ANSI/SPARC.

*Leurs inconvénients* : aucune règle n''assure la cohérence entre le modèle des
données et celui des traitements, et la **modélisation des traitements est
faible**.

**Les méthodes orientées objet** favorisent la cohérence entre les **objets** et
leur dynamique, ainsi que la **modularité** et la **réutilisation**.

Exemples : **OOD** de G. Booch, **HOOD**. On y ajoute aujourd''hui **UML**.

*Leurs avantages* : une bonne modélisation des **objets complexes** et
l''**encapsulation**.

*Leurs inconvénients* : une perception parfois **monolithique** des
applications, et un **effort d''abstraction élevé**.

### MERISE, la méthode du programme

**MERISE** signifie **Méthode d''Étude et de Réalisation Informatique pour les
Systèmes d''Entreprise**.

C''est une méthode d''analyse et de conception fondée sur la **séparation des
données et des traitements**. Elle sert surtout à **concevoir des bases de
données**, et c''est elle que tu utiliseras dans les deux chapitres suivants.

### Deux notions de vocabulaire

Un **système** est un **tout composé d''éléments liés par des relations**, ces
éléments et ces relations ayant des **propriétés**.

Un système complexe se **décompose en sous-systèmes**, et il existe **plusieurs
décompositions possibles** : la qualité de la représentation dépend d''une bonne
décomposition.

*Exemple d''un système « entreprise »* :

| | Exemples |
| --- | --- |
| **éléments** | employés, services, articles, entrepôt, salaire |
| **propriétés des éléments** | le nom et le matricule d''un employé, la référence d''un article |
| **relations** | un employé est rattaché à un service ; un article est stocké dans un entrepôt |
| **propriétés des relations** | la date d''entrée dans le service, la quantité stockée |

Les **règles de gestion** sont l''**ensemble des contraintes que doivent
respecter les données** du système d''information pour refléter le fonctionnement
réel de l''organisation. C''est d''elles qu''on partira pour construire le MCD.

---

**Exercice corrigé**

*Citer deux méthodes de conception d''un système d''information.*

**Correction.** **MERISE** et **UML**.

*On accepte aussi* AXIAL, Information Engineering, OOD ou HOOD.

*Pour gagner le point en entier*, précise la famille : MERISE est une méthode
**systémique**, fondée sur la séparation des données et des traitements ; UML
et OOD sont des méthodes **orientées objet**.

*Cette question est tombée au Baccalauréat 2024, pour 0,5 point. Elle ne demande
que de la mémoire, et beaucoup de candidats la laissent blanche.*
', NULL, 26),
      (v_chapitre_id, 'Simulation : décomposer un système', 2, 'interactif', '{
  "widget": "decomposer-systeme",
  "consigne": "Une organisation camerounaise t''est décrite en quelques phrases — un lycée, une pharmacie, une agence de location. Tu dois en extraire les éléments, leurs propriétés, les relations et les propriétés des relations, en glissant chaque mot dans la bonne colonne. La simulation te montre ensuite deux décompositions différentes du même système, et pourquoi l''une mène à un bon modèle et l''autre à un modèle bancal."
}', NULL, 10),
      (v_chapitre_id, 'Les trois niveaux de modélisation', 3, 'texte', '
MERISE regarde le système d''information à **trois hauteurs** différentes. C''est
la clé de toute la méthode, et chaque niveau répond à une question.

### Le niveau conceptuel

Il décrit la **finalité et les objectifs** du système, **indépendamment de leur
réalisation**.

Il répond à la question **« QUOI ? »** — que manipule-t-on, et que fait-on ?

À ce niveau, on ne se demande ni qui fera le travail, ni avec quel logiciel.

### Le niveau logique, ou organisationnel

Il décrit l''**organisation à mettre en place** pour atteindre ces objectifs.

Il répond aux questions **« QUI ? OÙ ? QUAND ? »** — quel poste de travail,
dans quel service, à quel moment.

### Le niveau physique, ou opérationnel

Il décrit l''**implémentation** avec les **choix techniques** retenus.

Il répond à la question **« COMMENT ? »** — avec quel SGBD, sur quelle machine,
dans quel langage.

### Les six modèles

Chaque niveau donne **deux** modèles, puisque MERISE sépare les **données** des
**traitements**.

| Niveau | Données | Traitements |
| --- | --- | --- |
| **Conceptuel** | **MCD** | MCT |
| **Logique / organisationnel** | **MLD** | MOT |
| **Physique / opérationnel** | **MPD** | MOP |

Le programme de Terminale ne travaille que la **colonne des données** : le
**MCD** au chapitre suivant, le **MLD** au chapitre d''après. Mais il faut savoir
nommer les six, car la question « citez les modèles de MERISE » existe.

### Le chemin complet

```
règles de gestion  →  MCD  →  MLD  →  MPD  →  la base réelle
    le réel          QUOI    QUI     COMMENT     le SQL
```

On descend toujours dans ce sens. On ne commence **jamais** par écrire du SQL :
on le déduit, à la fin, d''un modèle qu''on a d''abord posé sur le papier.

---

**Exercice corrigé**

*Compléter : « Le niveau ……… répond à la question QUOI, et son modèle de
données s''appelle le ……… . Le niveau logique répond aux questions ………, et son
modèle de données s''appelle le ……… . »*

**Correction.**

Le niveau **conceptuel** répond à la question **QUOI**, et son modèle de données
s''appelle le **MCD** — modèle conceptuel de données.

Le niveau logique répond aux questions **QUI, OÙ et QUAND**, et son modèle de
données s''appelle le **MLD** — modèle logique de données.

*Et pour compléter la série : le niveau physique répond à COMMENT, et son modèle
de données est le MPD.*
', NULL, 25),
      (v_chapitre_id, 'Figure : les trois niveaux de MERISE et leurs six modèles', 4, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 250" width="560" height="250">
<rect width="560" height="250" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les trois niveaux de MERISE, et leurs six modèles</text>

<rect x="24" y="38" width="100" height="36" rx="6" fill="#1e293b"/>
<text x="74" y="55" text-anchor="middle" font-size="10" font-weight="700" fill="#ffffff">NIVEAU</text>
<text x="74" y="68" text-anchor="middle" font-size="10" font-weight="700" fill="#ffffff">QUESTION</text>
<rect x="132" y="38" width="200" height="36" rx="6" fill="#1e293b"/>
<text x="232" y="61" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">DONNÉES</text>
<rect x="340" y="38" width="196" height="36" rx="6" fill="#1e293b"/>
<text x="438" y="61" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">TRAITEMENTS</text>

<rect x="24" y="82" width="100" height="48" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.6"/>
<text x="74" y="101" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">Conceptuel</text>
<text x="74" y="118" text-anchor="middle" font-size="13" font-weight="700" fill="#2563eb">QUOI ?</text>
<rect x="132" y="82" width="200" height="48" rx="6" fill="#dbeafe" stroke="#2563eb" stroke-width="1.6"/>
<text x="232" y="106" text-anchor="middle" font-size="16" font-weight="700" fill="#1e3a8a">MCD</text>
<text x="232" y="122" text-anchor="middle" font-size="9" fill="#1e40af">entités, associations, cardinalités</text>
<rect x="340" y="82" width="196" height="48" rx="6" fill="#eff6ff" stroke="#93c5fd" stroke-width="1.4"/>
<text x="438" y="112" text-anchor="middle" font-size="16" font-weight="700" fill="#2563eb">MCT</text>

<rect x="24" y="138" width="100" height="48" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<text x="74" y="155" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">Logique</text>
<text x="74" y="173" text-anchor="middle" font-size="11" font-weight="700" fill="#15803d">QUI ? OÙ ?</text>
<rect x="132" y="138" width="200" height="48" rx="6" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<text x="232" y="162" text-anchor="middle" font-size="16" font-weight="700" fill="#14532d">MLD</text>
<text x="232" y="178" text-anchor="middle" font-size="9" fill="#166534">tables, clés primaires, clés étrangères</text>
<rect x="340" y="138" width="196" height="48" rx="6" fill="#f0fdf4" stroke="#86efac" stroke-width="1.4"/>
<text x="438" y="168" text-anchor="middle" font-size="16" font-weight="700" fill="#15803d">MOT</text>

<rect x="24" y="194" width="100" height="44" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<text x="74" y="211" text-anchor="middle" font-size="10" font-weight="700" fill="#78350f">Physique</text>
<text x="74" y="228" text-anchor="middle" font-size="12" font-weight="700" fill="#ca8a04">COMMENT ?</text>
<rect x="132" y="194" width="200" height="44" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<text x="232" y="216" text-anchor="middle" font-size="16" font-weight="700" fill="#78350f">MPD</text>
<text x="232" y="231" text-anchor="middle" font-size="9" fill="#92400e">le SQL réellement exécuté</text>
<rect x="340" y="194" width="196" height="44" rx="6" fill="#fefce8" stroke="#fde047" stroke-width="1.4"/>
<text x="438" y="222" text-anchor="middle" font-size="16" font-weight="700" fill="#ca8a04">MOP</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : à quel niveau se pose la question ?', 5, 'interactif', '{
  "widget": "niveaux-merise",
  "consigne": "Douze décisions de projet te sont soumises : « un élève appartient à une seule classe », « la saisie se fera au secrétariat le lundi », « on utilisera MySQL », « quel est l''identifiant d''un élève ». Place chacune au bon niveau — conceptuel, logique ou physique — et la simulation te renvoie la question qui tranche : quoi, qui et où, ou comment. Le tableau des six modèles se remplit à mesure."
}', NULL, 10),
      (v_chapitre_id, 'Les règles de gestion, point de départ de tout', 6, 'texte', '
Un MCD ne s''invente pas : il se **déduit** de phrases écrites en français, qu''on
appelle les **règles de gestion**.

### Ce qu''est une règle de gestion

C''est une **contrainte que doivent respecter les données** du système
d''information pour **refléter le fonctionnement réel** de l''organisation.

Elles s''obtiennent en **interrogeant les gens** : le directeur, le secrétaire,
le magasinier. C''est la première étape de tout projet.

### À quoi elles ressemblent

Les sujets du Baccalauréat les écrivent toujours de la même façon, numérotées
RG1, RG2, RG3 :

```
RG1 : une personne peut faire plusieurs réservations,
      mais une réservation n''est faite que par une seule personne.
RG2 : une réservation concerne une ou plusieurs salles,
      et une salle peut être concernée par plusieurs réservations.
RG3 : une personne est définie par un code unique, un nom,
      un prénom, un contact et un numéro de CNI.
RG4 : une réservation possède un numéro unique et une date.
```

### Comment les lire

Chaque règle apporte **une** information, et une seule. Apprends à reconnaître
laquelle.

**Les règles qui donnent les propriétés.** Elles contiennent « est définie
par », « possède », « comporte ». Elles te donnent la **liste des propriétés**
d''une entité, et l''adjectif **« unique »** y désigne l''**identifiant**.

Dans RG3 ci-dessus : l''entité PERSONNE a pour propriétés le code, le nom, le
prénom, le contact et le numéro de CNI — et le **code est l''identifiant**,
puisqu''il est dit unique.

**Les règles qui donnent les associations et les cardinalités.** Elles
contiennent un **verbe d''action** — fait, concerne, participe, contient — et des
expressions de quantité : « plusieurs », « une seule », « au moins une ».

Dans RG1 : le verbe est **FAIRE**, et les quantités donnent les cardinalités.

### La méthode en quatre temps

1. **Souligner les noms** : ce sont les futures entités et propriétés.
2. **Entourer les verbes** : ce sont les futures associations.
3. **Repérer les mots « unique »** : ce sont les identifiants.
4. **Repérer les quantités** — un seul, plusieurs, au moins un : ce sont les
cardinalités.

C''est mécanique, et c''est exactement ce que le correcteur attend.

---

**Exercice corrigé**

*À partir de la règle « un client peut passer plusieurs commandes, mais une
commande est passée par un seul client », identifier les entités, l''association,
et dire ce que la règle apprend sur les cardinalités.*

**Correction.**

*Les entités*, données par les noms : **CLIENT** et **COMMANDE**.

*L''association*, donnée par le verbe : **PASSER**.

*Les cardinalités.* La règle se lit dans les deux sens, et chaque sens donne une
cardinalité.

« Un client peut passer **plusieurs** commandes » : du côté CLIENT, la
cardinalité maximale est **n**.

« Une commande est passée par **un seul** client » : du côté COMMANDE, la
cardinalité maximale est **1**.

*On note donc CLIENT (1,n) — PASSER — (1,1) COMMANDE*, en supposant qu''un client
passe au moins une commande et qu''une commande a toujours un client.

*Nous verrons au chapitre suivant comment choisir entre 0 et 1 pour la
cardinalité minimale.*
', NULL, 26),
      (v_chapitre_id, 'Simulation : lire des règles de gestion', 7, 'interactif', '{
  "widget": "regles-gestion",
  "consigne": "Un énoncé de Baccalauréat s''affiche avec ses règles RG1 à RG4. Surligne les noms, les verbes, les mots « unique » et les quantités : la simulation colore ce que tu désignes et construit en parallèle la liste des entités, des propriétés, des identifiants et des associations. Quand tout est repéré, elle te montre le MCD que ces règles imposent."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 12', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que signifie le sigle MERISE ?",
      "choix": [
        "Méthode d''Étude et de Réalisation Informatique pour les Systèmes d''Entreprise",
        "Modèle d''Étude Relationnel Informatisé des Systèmes d''Entreprise",
        "Méthode d''Élaboration Rapide des Interfaces et Systèmes",
        "Modèle Européen de Référence Informatique"
      ],
      "bonne": 0,
      "explication": "C''est une méthode systémique, fondée sur la séparation des données et des traitements, et elle sert surtout à concevoir des bases de données."
    },
    {
      "question": "Citer deux méthodes de conception d''un système d''information.",
      "choix": [
        "Excel et Access",
        "MERISE et UML",
        "SQL et PHP",
        "TCP et IP"
      ],
      "bonne": 1,
      "explication": "On accepte aussi AXIAL, Information Engineering, OOD ou HOOD. Préciser la famille — systémique ou orientée objet — sécurise le point."
    },
    {
      "question": "À quelle question répond le niveau conceptuel ?",
      "choix": [
        "COMMENT ?",
        "QUOI ?",
        "QUI et OÙ ?",
        "COMBIEN ?"
      ],
      "bonne": 1,
      "explication": "Il décrit la finalité du système indépendamment de sa réalisation. Le logique répond à qui, où et quand ; le physique à comment."
    },
    {
      "question": "Quel est le modèle de données du niveau logique ?",
      "choix": [
        "Le MCD",
        "Le MLD",
        "Le MPD",
        "Le MOT"
      ],
      "bonne": 1,
      "explication": "MCD au conceptuel, MLD au logique, MPD au physique. Les trois autres — MCT, MOT, MOP — sont les modèles de traitements."
    },
    {
      "question": "Qu''est-ce qu''une règle de gestion ?",
      "choix": [
        "Une requête SQL",
        "Une contrainte que doivent respecter les données pour refléter le fonctionnement réel de l''organisation",
        "Une table de la base",
        "Un niveau de MERISE"
      ],
      "bonne": 1,
      "explication": "On les obtient en interrogeant les gens de l''organisation, et c''est d''elles qu''on déduit le MCD."
    },
    {
      "question": "Dans une règle de gestion, que signale le mot « unique » ?",
      "choix": [
        "Une association",
        "Une cardinalité",
        "L''identifiant de l''entité",
        "Une clé étrangère"
      ],
      "bonne": 2,
      "explication": "« Une personne est définie par un code unique » : le code est l''identifiant. C''est mécanique, et le correcteur l''attend."
    },
    {
      "question": "Dans quel ordre descend-on les modèles de MERISE ?",
      "choix": [
        "MPD, puis MLD, puis MCD",
        "MCD, puis MLD, puis MPD",
        "MLD, puis MCD, puis MPD",
        "Peu importe"
      ],
      "bonne": 1,
      "explication": "Des règles de gestion au MCD, du MCD au MLD, du MLD au MPD. On ne commence jamais par écrire du SQL : on le déduit."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 12, Les méthodes de conception d''un système d''information.', v_nom;
  END LOOP;
END $inf7$;
