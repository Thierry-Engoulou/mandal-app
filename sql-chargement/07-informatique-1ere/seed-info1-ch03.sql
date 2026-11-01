-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 3 : Le système d'exploitation, les bus et les pilotes
-- Module 1 : Maintenance informatique — 7 leçons
--
-- Ce fichier remplit les trois séries d'un coup : la 1ère A, la 1ère C et la
-- 1ère D. Il n'a besoin de rien d'autre pour tourner. Si la matière, les
-- classes, les programmes ou le chapitre n'existent pas encore, il les crée
-- lui-même au passage.
--
-- Lancez-le quand vous voulez, dans l'ordre que vous voulez, et autant de fois
-- que vous voulez : quand le chapitre a déjà ses leçons, le script s'en rend
-- compte et n'ajoute rien.
-- ---------------------------------------------------------------------------
DO $inf1$
DECLARE
  v_lettres text[] := ARRAY['A', 'C', 'D'];
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
  FOR v_i IN 1..3 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := '1ère ' || v_lettre;

    -- Le programme de Chimie de cette série existe-t-il déjà ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Informatique — ' || v_nom;

    -- Non : on le crée, et la classe avec si besoin.
    IF v_programme_id IS NULL THEN
      -- La classe a pu être écrite de plusieurs façons : 1ère A, 1ere A, Première A.
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE '1%re ' || v_lettre OR nom ILIKE 'Premi%re ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Première', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'La classe % n''existait pas : je viens de la créer.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Informatique — ' || v_nom,
              'Programme officiel d''Informatique, classe de Première ' || v_lettre ||
              ' (Cameroun) — 3 modules, 20 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme d''Informatique de la % : créé.', v_nom;
    END IF;

    -- Le chapitre lui-même.
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 3;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Le système d''exploitation, les bus et les pilotes', 3, 'Module 1 : Maintenance informatique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 3 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 3 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le système d''exploitation', 1, 'texte', '
L''ordinateur a besoin d''être mis sous tension, puis d''un programme qui prenne
les commandes. Ce programme, c''est le système d''exploitation.

### La définition

Un **système d''exploitation**, souvent appelé **OS** pour *Operating System*,
est un **ensemble de programmes qui dirige l''utilisation des capacités d''un
ordinateur par des logiciels applicatifs**.

C''est le **premier programme exécuté** lors de la mise en marche de
l''ordinateur, après l''amorçage. Il offre une suite de services généraux qui
facilitent la création de logiciels applicatifs, et il sert d''**intermédiaire**
entre ces logiciels et le matériel informatique.

Retiens cette image : le système d''exploitation est le **chef d''orchestre**. Il
ne joue d''aucun instrument, mais sans lui, personne ne jouerait ensemble.

### Les deux grandes familles

Il existe sur le marché des dizaines de systèmes d''exploitation différents. Ils
sont souvent livrés avec l''appareil informatique : c''est le cas de **Windows,
Mac OS, Irix, Symbian OS, Ubuntu et Android**.

Les deux familles les plus populaires sont :

- la famille **Unix**, dont font partie Mac OS X, GNU/Linux, iOS et Android ;
- la famille **Windows**, qui détient un quasi-monopole sur les ordinateurs
personnels, avec près de **90 % de part de marché** depuis plus de vingt ans.

### Ses six fonctionnalités

Le système d''exploitation est comparable à un chef d''orchestre du fait des
fonctions suivantes :

1. la **gestion du processeur** ;
2. la **gestion de la mémoire** ;
3. la **gestion des entrées/sorties** ;
4. la **gestion de la concurrence** ;
5. la **gestion des fichiers** ;
6. la **gestion du matériel**.

Elles tombent régulièrement, et on te demande souvent d''en citer trois ou
quatre.

---

**Exercice corrigé**

*Le dysfonctionnement d''un logiciel d''application quelconque dans un ordinateur
peut-il empêcher ce dernier de démarrer normalement ? Justifier.*

**Correction.** **Non.**

Un logiciel d''application — Word, un navigateur, un jeu — se lance **après** le
système d''exploitation. Au démarrage, la machine exécute d''abord le BIOS, puis
le système d''exploitation. Un logiciel applicatif en panne ne sera tout
simplement pas lancé, ou plantera une fois le bureau affiché, mais le démarrage
lui-même aura réussi.

La réponse serait **oui** si c''était le **système d''exploitation** qui était
endommagé, car lui est indispensable au démarrage.
', NULL, 22),
      (v_chapitre_id, 'Figure : les quatre couches, de vous au matériel', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 250" width="540" height="250">
<rect width="540" height="250" fill="#ffffff"/>
<text x="270" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Le système d&apos;exploitation, chef d&apos;orchestre entre vous et la machine</text>

<rect x="130" y="44" width="280" height="42" rx="8" fill="#ea580c"/>
<text x="270" y="70" text-anchor="middle" font-size="13" font-weight="700" fill="#ffffff">UTILISATEUR</text>

<rect x="130" y="96" width="280" height="42" rx="8" fill="#16a34a"/>
<text x="270" y="122" text-anchor="middle" font-size="13" font-weight="700" fill="#ffffff">APPLICATION</text>
<text x="424" y="122" font-size="10" fill="#64748b">Word, le navigateur…</text>

<rect x="130" y="148" width="280" height="42" rx="8" fill="#2563eb"/>
<text x="270" y="174" text-anchor="middle" font-size="13" font-weight="700" fill="#ffffff">SYSTÈME D&apos;EXPLOITATION</text>
<text x="424" y="174" font-size="10" fill="#64748b">Windows, Linux…</text>

<rect x="130" y="200" width="280" height="42" rx="8" fill="#b91c1c"/>
<text x="270" y="226" text-anchor="middle" font-size="13" font-weight="700" fill="#ffffff">MATÉRIEL INFORMATIQUE</text>
<text x="424" y="226" font-size="10" fill="#64748b">CPU, RAM, disque…</text>

<g stroke="#334155" stroke-width="2">
  <line x1="104" y1="70" x2="104" y2="226"/>
</g>
<polygon points="104,230 98,216 110,216" fill="#334155"/>
<polygon points="104,66 98,80 110,80" fill="#334155"/>
<text x="90" y="152" font-size="10" fill="#64748b" transform="rotate(-90 90 152)" text-anchor="middle">les demandes descendent, les réponses remontent</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : les quatre couches', 3, 'interactif', '{
  "widget": "couches-systeme",
  "consigne": "Clique n''importe où dans la pile — sur toi, sur l''application, sur le système d''exploitation, sur le matériel — et suis une demande qui descend jusqu''au disque dur puis remonte avec sa réponse. Retire ensuite le système d''exploitation et recommence : l''application se retrouve à parler directement au matériel, et plus rien ne fonctionne."
}', NULL, 10),
      (v_chapitre_id, 'Les bus, le chipset et les pilotes', 4, 'texte', '
### Les bus

Un **bus** est un circuit intégré à la carte mère qui assure la **circulation
des données** entre les différents éléments du PC : la mémoire vive, la carte
graphique, les ports USB.

Chaque bus est généralement décomposé en **trois sous-ensembles** spécialisés :

| Bus | Ce qu''il transporte |
| --- | --- |
| le **bus d''adresses** (ou bus d''adressage, ou bus mémoire) | l''adresse de la case visée |
| le **bus de données** | l''information elle-même |
| le **bus de contrôle** (ou bus de commandes) | l''ordre : lire, ou écrire |

Pense à la poste. Le bus d''adresses porte l''adresse sur l''enveloppe, le bus de
données porte la lettre à l''intérieur, et le bus de contrôle dit s''il s''agit
d''un envoi ou d''un retrait.

L''élément chargé d''**aiguiller** les informations entre les différents bus de
l''ordinateur, afin de permettre à tous ses éléments constitutifs de communiquer
entre eux, s''appelle le **chipset**.

### Les pilotes

Un **pilote informatique**, souvent abrégé en **pilote** — en anglais *driver*
— est un programme informatique destiné à permettre à un autre programme,
souvent un système d''exploitation, d''**interagir avec un périphérique**.

En général, chaque périphérique a son propre pilote.

De manière simple : un pilote d''imprimante est un logiciel qui **explique à
l''ordinateur comment utiliser l''imprimante**. Sans pilote, l''imprimante ou la
carte graphique ne pourraient pas être utilisées.

C''est pour cela qu''un périphérique tout neuf, branché sur une machine qui n''a
pas son pilote, ne fait rien du tout.

### Le BIOS et la séquence POST

Le **BIOS**, pour *Basic Input Output System*, s''occupe de **tester et
d''initialiser tous les matériels** au démarrage.

On appelle cette étape la **séquence POST**, pour *Power On Self Test*, ou
encore séquence pré-boot. C''est la séquence durant laquelle tous les composants
vont être testés, de même que leur compatibilité.

**Si la séquence POST ne passe pas, le système n''ira pas plus loin et le
système d''exploitation ne sera pas lancé.**

C''est l''explication des bips que tu entends parfois au démarrage : le BIOS
signale par des sons ce qu''il n''arrive pas à initialiser.

---

**Exercice corrigé**

*Vous avez démarré l''ordinateur mais votre secrétaire, passant à proximité, a
par inadvertance laissé tomber le dictionnaire qu''elle tenait en main sur le
clavier, ce qui provoque un long sifflement de l''ordinateur. Qu''est-ce qui est
à l''origine de ce sifflement ?*

**Correction.** Une **touche du clavier restée enfoncée** sous le poids du
dictionnaire.

Pendant la séquence POST, le BIOS teste le clavier. Il détecte une touche
bloquée, considère qu''il y a une anomalie matérielle et le signale par un
**signal sonore continu**. Il suffit de soulever le dictionnaire et de
redémarrer.

Cette question est tombée au Probatoire session 2017.
', NULL, 25),
      (v_chapitre_id, 'Simulation : les trois bus', 5, 'interactif', '{
  "widget": "bus-ordinateur",
  "consigne": "Envoie une donnée du processeur vers la mémoire et suis-la sur les trois bus en même temps : l''adresse part sur l''un, la donnée sur l''autre, et l''ordre « écrire » sur le troisième. Coupe ensuite un seul des trois bus et relance : tu verras précisément ce qui manque. Le chipset, au centre, s''allume à chaque fois qu''il aiguille."
}', NULL, 10),
      (v_chapitre_id, 'Simulation : le démarrage, étape par étape', 6, 'interactif', '{
  "widget": "demarrage-bios",
  "consigne": "Appuie sur le bouton et suis la machine qui s''allume : la mise sous tension, le BIOS qui prend la main, la séquence POST qui teste les composants un par un, puis le chargement du système d''exploitation. Débranche un composant avant de démarrer et regarde le POST s''arrêter net, avec le code sonore correspondant — c''est exactement ce que fait ton ordinateur quand il bipe sans s''allumer."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 3', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qu''un système d''exploitation ?",
      "choix": [
        "Un logiciel de traitement de texte",
        "Un ensemble de programmes qui dirige l''utilisation des capacités de l''ordinateur par les logiciels applicatifs",
        "Un composant de la carte mère",
        "Un antivirus"
      ],
      "bonne": 1,
      "explication": "C''est le premier programme exécuté au démarrage, et il sert d''intermédiaire entre les logiciels et le matériel."
    },
    {
      "question": "Quelles sont les deux grandes familles de systèmes d''exploitation ?",
      "choix": [
        "Windows et Word",
        "Unix et Windows",
        "Android et Linux",
        "Intel et AMD"
      ],
      "bonne": 1,
      "explication": "La famille Unix comprend Mac OS X, GNU/Linux, iOS et Android. La famille Windows détient près de 90 % du marché des ordinateurs personnels."
    },
    {
      "question": "Quels sont les trois sous-ensembles d''un bus ?",
      "choix": [
        "Entrée, traitement, sortie",
        "Adresses, données, contrôle",
        "Lecture, écriture, effacement",
        "Processeur, mémoire, disque"
      ],
      "bonne": 1,
      "explication": "Le bus d''adresses porte l''adresse, le bus de données porte l''information, le bus de contrôle porte l''ordre de lire ou d''écrire."
    },
    {
      "question": "Comment s''appelle l''élément qui aiguille les informations entre les bus ?",
      "choix": [
        "Le BIOS",
        "Le chipset",
        "Le pilote",
        "L''UAL"
      ],
      "bonne": 1,
      "explication": "Le chipset permet à tous les éléments constitutifs de l''ordinateur de communiquer entre eux."
    },
    {
      "question": "À quoi sert un pilote de périphérique ?",
      "choix": [
        "À alimenter le périphérique en courant",
        "À permettre au système d''exploitation d''interagir avec le périphérique",
        "À nettoyer le périphérique",
        "À connecter le périphérique au réseau"
      ],
      "bonne": 1,
      "explication": "Un pilote d''imprimante explique à l''ordinateur comment utiliser l''imprimante. Sans lui, le périphérique est inutilisable, même branché."
    },
    {
      "question": "Comment s''appelle la séquence pendant laquelle le BIOS teste les composants au démarrage ?",
      "choix": [
        "La séquence POST",
        "La séquence BOOT",
        "La défragmentation",
        "Le formatage"
      ],
      "bonne": 0,
      "explication": "POST pour Power On Self Test. Si elle ne passe pas, le système d''exploitation n''est pas lancé du tout."
    },
    {
      "question": "Citer deux fonctionnalités du système d''exploitation.",
      "choix": [
        "La gestion du processeur et la gestion de la mémoire",
        "La rédaction de documents et le calcul",
        "La navigation et la messagerie",
        "L''impression et la numérisation"
      ],
      "bonne": 0,
      "explication": "Les six fonctionnalités sont : gestion du processeur, de la mémoire, des entrées/sorties, de la concurrence, des fichiers et du matériel."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 3, Le système d''exploitation, les bus et les pilotes.', v_nom;
  END LOOP;
END $inf1$;
