-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 2 : Le fonctionnement d'un ordinateur
-- Module 1 : Systèmes informatiques — 8 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 2;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Le fonctionnement d''un ordinateur', 2, 'Module 1 : Systèmes informatiques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 2 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 2 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les composants internes de l''unité centrale', 1, 'texte', '
Ouvrons le boîtier. Le programme demande de **lister les principaux composants
internes** : carte mère, processeur, RAM, disque dur, chipset, bloc
d''alimentation et cartes d''extension.

### La carte mère

C''est la grande plaque qui **réunit tous les composants internes** et les relie
entre eux.

Elle existe en trois **formats**, et le programme les attend :

**ATX**, le plus répandu et le plus grand ; **micro-ATX**, compact ;
**ITX**, ultracompact.

Le format n''est pas un détail : il décide du boîtier, du nombre de connecteurs
d''extension, et du bloc d''alimentation compatible.

Le processeur ne se soude pas : il s''insère dans un support appelé **socket**.

### Le processeur

Le **CPU** interprète et exécute les instructions des programmes. Il se compose
de deux unités :

l''**unité arithmétique et logique**, ou **UAL**, qui calcule ;
l''**unité de commande**, qui organise et séquence le travail.

**Ses caractéristiques** : la **marque**, le **type**, la **fréquence** —
c''est-à-dire la cadence de l''horloge, en hertz —, la **largeur des registres**
et le **jeu d''instructions**, en 32 ou 64 bits.

### La mémoire vive

La **RAM** est la mémoire **principale** et **rapide**, mais **volatile** :
elle perd son contenu dès qu''on coupe le courant. Elle stocke temporairement
les programmes et les données en cours d''utilisation.

**Ses caractéristiques** : le **type** — SDRAM, DDR et ses générations —, la
**capacité** en gigaoctets, et la **vitesse**.

### Le disque dur

Il stocke de façon **permanente** le système, les programmes et les données.

**Ses caractéristiques** : la **capacité**, l''**interface** — IDE, aujourd''hui
SATA —, le **débit**, et la **vitesse de rotation**, de 7 200 à 15 000 tours
par minute pour les disques mécaniques.

**Ses types** : le **HDD** mécanique, le **SSD** à mémoire électronique, et le
disque **externe**.

### Les cartes d''extension

Elles se branchent sur les connecteurs de la carte mère et ajoutent une
fonction : la **carte graphique** affiche les résultats à l''écran, la **carte
son** gère l''entrée et la sortie audio, la **carte réseau** permet la
communication entre ordinateurs.

### Le chipset et le bloc d''alimentation

Le **chipset** est le jeu de circuits qui **aiguille les informations** entre
les différents bus de la machine, afin que tous les composants communiquent.

Le **bloc d''alimentation** transforme le courant alternatif de la prise en
tensions continues utilisables — 12 V, 5 V, 3,3 V. Son format suit celui de la
carte mère : une alimentation ATX pour une carte ATX.

---

**Exercice corrigé**

*Donner la signification du sigle CPU, et nommer ses deux unités.*

**Correction.** **CPU** signifie *Central Processing Unit*, soit **unité
centrale de traitement**. En français courant, on dit le **processeur**.

Ses deux unités sont l''**unité arithmétique et logique** (UAL), qui effectue
les calculs et les opérations logiques, et l''**unité de commande**, qui
interprète les instructions et organise leur exécution.

*La signification du sigle valait 0,5 point au Baccalauréat 2024. Elle ne se
devine pas : il faut l''avoir apprise.*
', NULL, 28),
      (v_chapitre_id, 'Figure : la carte mère et ce qui s''y branche', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 300" width="560" height="300">
<rect width="560" height="300" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">La carte mère et ce qui s&apos;y branche</text>

<rect x="24" y="38" width="352" height="244" rx="8" fill="#dcfce7" stroke="#166534" stroke-width="2"/>
<text x="200" y="58" text-anchor="middle" font-size="11" font-weight="700" fill="#166534">CARTE MÈRE — format ATX, micro-ATX ou ITX</text>

<rect x="52" y="76" width="92" height="92" rx="6" fill="#334155"/>
<rect x="64" y="88" width="68" height="68" rx="3" fill="#64748b"/>
<text x="98" y="126" text-anchor="middle" font-size="12" font-weight="700" fill="#ffffff">CPU</text>
<text x="98" y="142" text-anchor="middle" font-size="8" fill="#e2e8f0">UAL + UC</text>
<text x="98" y="186" text-anchor="middle" font-size="9" fill="#0f172a">processeur</text>
<text x="98" y="199" text-anchor="middle" font-size="8" fill="#64748b">dans son socket</text>

<rect x="170" y="76" width="18" height="112" rx="3" fill="#1d4ed8"/>
<rect x="194" y="76" width="18" height="112" rx="3" fill="#1d4ed8"/>
<rect x="218" y="76" width="18" height="112" rx="3" fill="#1d4ed8"/>
<text x="203" y="206" text-anchor="middle" font-size="9" fill="#0f172a">barrettes de RAM</text>
<text x="203" y="219" text-anchor="middle" font-size="8" fill="#64748b">SDRAM, DDR — en Go</text>

<rect x="256" y="84" width="96" height="14" rx="3" fill="#b45309"/>
<rect x="256" y="106" width="96" height="14" rx="3" fill="#b45309"/>
<rect x="256" y="128" width="96" height="14" rx="3" fill="#b45309"/>
<text x="304" y="166" text-anchor="middle" font-size="9" fill="#0f172a">connecteurs</text>
<text x="304" y="179" text-anchor="middle" font-size="9" fill="#0f172a">d&apos;extension</text>
<text x="304" y="196" text-anchor="middle" font-size="8" fill="#64748b">carte graphique,</text>
<text x="304" y="208" text-anchor="middle" font-size="8" fill="#64748b">carte son, carte réseau</text>

<rect x="52" y="222" width="140" height="42" rx="6" fill="#7c3aed"/>
<text x="122" y="241" text-anchor="middle" font-size="10" font-weight="700" fill="#ffffff">CHIPSET</text>
<text x="122" y="256" text-anchor="middle" font-size="8" fill="#ede9fe">il aiguille entre les bus</text>

<rect x="396" y="38" width="140" height="66" rx="6" fill="#78716c"/>
<text x="466" y="68" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">DISQUE DUR</text>
<text x="466" y="86" text-anchor="middle" font-size="8" fill="#e7e5e4">HDD ou SSD — IDE, SATA</text>

<rect x="396" y="118" width="140" height="66" rx="6" fill="#475569"/>
<text x="466" y="148" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">ALIMENTATION</text>
<text x="466" y="166" text-anchor="middle" font-size="8" fill="#e2e8f0">elle transforme le courant</text>

<rect x="396" y="198" width="140" height="66" rx="6" fill="#0f766e"/>
<text x="466" y="228" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">VENTILATEUR</text>
<text x="466" y="246" text-anchor="middle" font-size="8" fill="#ccfbf1">il refroidit le processeur</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : reconnaître les composants internes', 3, 'interactif', '{
  "widget": "carte-mere",
  "consigne": "Le boîtier s''ouvre devant toi. Clique sur chaque composant — carte mère, processeur, barrettes de mémoire, disque dur, connecteurs d''extension, chipset, alimentation — et la simulation te donne son rôle, ses caractéristiques et leurs unités. Change ensuite le format de la carte mère, d''ATX à ITX, et regarde le nombre de connecteurs disponibles fondre : c''est tout l''enjeu du format."
}', NULL, 10),
      (v_chapitre_id, 'Le rôle des pilotes', 4, 'texte', '
Un périphérique parfaitement branché peut rester muet. C''est presque toujours le
même coupable.

### La définition

Un **pilote** — en anglais *driver* — est un **programme** qui permet au
**système d''exploitation d''interagir avec un périphérique**.

Il **traduit les ordres du système dans le langage propre au matériel**. Chaque
périphérique a le sien, et chaque modèle a le sien.

Sans pilote, une imprimante, une carte graphique, une souris ou un clavier ne
peut tout simplement pas fonctionner.

### Comment on reconnaît un pilote manquant

Le symptôme est toujours le même : le matériel est **détecté** mais
**inutilisable**, ou bien il n''apparaît pas du tout. Dans le gestionnaire de
périphériques de Windows, il porte un **point d''exclamation jaune**, et son nom
devient générique — « Périphérique inconnu », « Contrôleur vidéo ».

### Les trois réflexes

1. **Vérifier d''abord le branchement** et le câble. On ne cherche pas un pilote
avant d''avoir vérifié la prise.
2. **Installer le pilote** fourni avec le matériel, ou le télécharger sur le
site du constructeur — jamais sur un site inconnu, c''est une porte d''entrée
classique pour les programmes malveillants.
3. **Mettre à jour** le pilote quand le périphérique fonctionne mal depuis une
mise à jour du système.

---

**Exercice corrigé**

*Un vidéoprojecteur neuf, branché sur un ordinateur, n''est pas reconnu par le
système d''exploitation. Identifier le problème et proposer une solution.*

**Correction.**

*Le problème.* Trois causes possibles, dans l''ordre où on les vérifie : le
**pilote** du vidéoprojecteur est **absent** ou inadapté ; le **branchement**
est mauvais ; le **câble** est défectueux.

*La solution.* Vérifier d''abord les branchements et, au besoin, changer le
câble ; puis **installer ou mettre à jour le pilote** du vidéoprojecteur, à
partir du support fourni ou du site du constructeur.

*Cette question est tombée au Baccalauréat 2023, pour un point — un demi-point
pour le problème, un demi-point pour la solution. Note bien qu''on attend les
deux : identifier ne suffit pas, il faut proposer.*
', NULL, 25),
      (v_chapitre_id, 'Simulation : le périphérique muet', 5, 'interactif', '{
  "widget": "pilote-peripherique",
  "consigne": "Cinq périphériques refusent de fonctionner : un vidéoprojecteur neuf, une imprimante après une réinstallation, une carte son, une souris, une carte réseau. Pour chacun, tu mènes tes vérifications dans l''ordre que tu veux — branchement, câble, gestionnaire de périphériques, pilote — et la simulation affiche le gestionnaire de Windows avec son point d''exclamation jaune quand le pilote manque."
}', NULL, 10),
      (v_chapitre_id, 'Lire une fiche technique avant d''acheter', 6, 'texte', '
Le Baccalauréat demande régulièrement de **relever des caractéristiques de
base** sur une fiche technique, ou d''en déduire une valeur. C''est une question
facile, à condition de savoir ce que chaque ligne signifie.

### Une fiche technique, ligne par ligne

Prenons une fiche réelle, telle qu''on la lit chez un revendeur de Douala ou de
Yaoundé :

| Ligne de la fiche | Ce qu''elle décrit | Unité |
| --- | --- | --- |
| Intel Core i5-10400, 2,9 GHz | le **processeur** : marque, modèle, fréquence | hertz |
| 64 bits | le **jeu d''instruction** | bits |
| RAM 8 Go DDR4 | la **mémoire vive** : capacité et type | octets |
| HDD 1 To, SATA, 7 200 tr/min | le **disque dur** : capacité, interface, vitesse | octets, tr/min |
| Écran 15,6" | l''**écran** : diagonale | pouces |
| Carte graphique Intel UHD | la **carte d''extension** vidéo | — |
| Windows 11 Famille | le **système d''exploitation** | — |

### Les deux caractéristiques de base

Quand on demande d''en citer **deux** à considérer avant d''acheter, les plus
attendues sont la **fréquence du processeur** et la **capacité de la mémoire
vive** — ce sont elles qui décident de la vitesse ressentie.

On accepte aussi la **capacité du disque dur** et la **taille de l''écran**.

### Le piège des unités

**Go** n''est pas **GHz**. Le premier mesure une **quantité** de mémoire ou de
stockage, le second une **vitesse** de calcul. Un candidat qui écrit « un
processeur de 8 Go » perd son point.

---

**Exercice corrigé**

*Sur une fiche technique on lit : « Processeur Intel Core i3, 2,4 GHz — RAM
4 Go — HDD 500 Go — Écran 14" — Windows 10, 64 bits ».*
*1. Quelle est la fréquence du processeur ? 2. Quelle est la capacité de
stockage ? 3. Que signifie « 64 bits » ? 4. Quelle est la taille de l''écran en
centimètres ?*

**Correction.**

1. **2,4 GHz**, soit 2,4 milliards de cycles par seconde. L''unité est le
**hertz**.

2. **500 Go**, c''est la capacité du **disque dur**. Attention à ne pas répondre
« 4 Go » : ces 4 Go sont la mémoire **vive**, qui ne stocke rien de façon
permanente.

3. Le **jeu d''instruction** du processeur, c''est-à-dire la **taille des données
qu''il traite en une seule opération**.

4. $14 \times 2{,}54 = 35{,}56$ cm, soit environ **35,6 cm** en diagonale.
', NULL, 25),
      (v_chapitre_id, 'Simulation : décrypter une fiche technique', 7, 'interactif', '{
  "widget": "fiche-technique",
  "consigne": "Une fiche technique s''affiche comme chez un revendeur, et chaque ligne est cliquable : la simulation te dit quel composant elle décrit, quelle est son unité, et ce que la valeur signifie vraiment. Un second volet te fait comparer deux machines au même prix et choisir laquelle prendre selon l''usage — bureautique, jeu, montage vidéo — en te montrant le composant qui fait la différence à chaque fois."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 2', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que signifie le sigle CPU ?",
      "choix": [
        "Computer Personal Unit",
        "Central Processing Unit",
        "Control Program Unit",
        "Central Power Unit"
      ],
      "bonne": 1,
      "explication": "Unité centrale de traitement, en français : le processeur. Cette question valait 0,5 point au Baccalauréat 2024."
    },
    {
      "question": "Quelles sont les deux unités du processeur ?",
      "choix": [
        "La RAM et la ROM",
        "L''unité arithmétique et logique et l''unité de commande",
        "Le chipset et le socket",
        "Le disque dur et la mémoire vive"
      ],
      "bonne": 1,
      "explication": "L''UAL calcule, l''unité de commande organise et séquence. L''une exécute, l''autre dirige."
    },
    {
      "question": "Quels sont les trois formats de carte mère au programme ?",
      "choix": [
        "ATX, micro-ATX et ITX",
        "IDE, SATA et USB",
        "DDR, SDRAM et SSD",
        "PCI, AGP et PCI-Express"
      ],
      "bonne": 0,
      "explication": "ATX est le plus grand et le plus répandu, micro-ATX est compact, ITX ultracompact. Le format décide du boîtier et du nombre de connecteurs."
    },
    {
      "question": "Comment s''appelle le support dans lequel s''insère le processeur ?",
      "choix": [
        "Le chipset",
        "Le socket",
        "Le bus",
        "Le slot d''extension"
      ],
      "bonne": 1,
      "explication": "Le processeur ne se soude pas : il se pose dans son socket, ce qui permet de le changer."
    },
    {
      "question": "Quel composant aiguille les informations entre les différents bus de la machine ?",
      "choix": [
        "Le processeur",
        "Le chipset",
        "La mémoire vive",
        "Le bloc d''alimentation"
      ],
      "bonne": 1,
      "explication": "C''est son rôle : permettre à tous les composants de communiquer entre eux."
    },
    {
      "question": "Qu''est-ce qu''un pilote ?",
      "choix": [
        "Un câble de connexion",
        "Un programme qui permet au système d''exploitation d''interagir avec un périphérique",
        "Une carte d''extension",
        "Une partie du processeur"
      ],
      "bonne": 1,
      "explication": "Il traduit les ordres du système dans le langage propre au matériel. Sans lui, le périphérique est inutilisable même parfaitement branché."
    },
    {
      "question": "Un vidéoprojecteur neuf n''est pas reconnu par le système. Quelle est la cause la plus probable ?",
      "choix": [
        "Le vidéoprojecteur est en panne",
        "Son pilote est absent ou inadapté",
        "L''ordinateur manque de mémoire",
        "L''écran est trop petit"
      ],
      "bonne": 1,
      "explication": "On vérifie d''abord le branchement et le câble, puis on installe ou met à jour le pilote. Question tombée au Baccalauréat 2023."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 2, Le fonctionnement d''un ordinateur.', v_nom;
  END LOOP;
END $inf7$;
