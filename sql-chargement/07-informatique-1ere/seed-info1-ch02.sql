-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 2 : Les composants de l'unité centrale
-- Module 1 : Maintenance informatique — 6 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 2;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les composants de l''unité centrale', 2, 'Module 1 : Maintenance informatique')
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
      (v_chapitre_id, 'Le microprocesseur, cerveau de la machine', 1, 'texte', '
Ouvrons l''unité centrale. Le premier composant qu''on y cherche est le
processeur.

### Ce que c''est

En anglais **CPU**, pour *Central Processing Unit*, le microprocesseur
constitue le **cerveau** de l''ordinateur. C''est un composant électronique très
sophistiqué et très miniaturisé, fabriqué le plus souvent en **silicium**.

### Ses deux parties

Le processeur se compose de deux parties essentielles :

**L''unité de contrôle** exécute et organise les travaux réalisés par le
processeur. C''est elle qui décide de l''ordre des opérations.

**L''unité arithmétique et logique**, abrégée **UAL** — en anglais **ALU** —
effectue les opérations sur les données : les additions, les soustractions, les
multiplications, les divisions, mais aussi les opérations logiques *non*, *et*,
*ou*.

Retiens la répartition : l''une **organise**, l''autre **calcule**.

### Ses quatre caractéristiques

Le microprocesseur est principalement caractérisé par :

1. sa **marque** — Intel, AMD, Motorola, IBM ;
2. sa **fréquence**, c''est-à-dire la vitesse ou le nombre d''opérations qu''il
peut effectuer en une seconde, mesurée **en hertz** ;
3. son **jeu d''instruction**, c''est-à-dire la taille de données qu''il peut
traiter — 32 bits ou 64 bits ;
4. la quantité de **mémoire adressable** — 1 Mo, 4 Go, 64 Go.

Ces quatre-là reviennent constamment en examen. Apprends-les dans l''ordre.

### Deux architectures

On distingue deux architectures de processeur :

**RISC**, pour *Reduced Instruction Set Computer* — jeu d''instructions réduit.

**CISC**, pour *Complex Instruction Set Computer* — jeu d''instructions
complexe.

---

**Exercice corrigé**

*Sur la fiche technique d''un ordinateur on lit : « Processeur Intel Quad Core
J1900, Windows 8.1 64 bits ». Que t''apprend cette ligne sur le processeur ?*

**Correction.**
*La marque* : Intel.
*Le modèle* : Quad Core J1900 — « Quad Core » signifie quatre cœurs, donc
quatre unités de calcul travaillant en parallèle.
*Le jeu d''instruction* : 64 bits, indiqué par la mention du système
d''exploitation. C''est la longueur d''instruction de cette machine.
La fréquence, elle, n''est pas donnée ici : il faudrait la chercher dans la
documentation du modèle J1900.
', NULL, 22),
      (v_chapitre_id, 'Figure : l''intérieur de l''unité centrale', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 300" width="540" height="300">
<rect width="540" height="300" fill="#ffffff"/>
<text x="270" y="24" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Ce qu&apos;on trouve en ouvrant l&apos;unité centrale</text>

<rect x="40" y="42" width="330" height="238" rx="8" fill="#14532d" opacity="0.14" stroke="#166534" stroke-width="2"/>
<text x="205" y="62" text-anchor="middle" font-size="11" font-weight="700" fill="#166534">LA CARTE MÈRE</text>

<rect x="76" y="84" width="86" height="86" rx="6" fill="#334155"/>
<rect x="88" y="96" width="62" height="62" rx="3" fill="#64748b"/>
<text x="119" y="132" text-anchor="middle" font-size="12" font-weight="700" fill="#ffffff">CPU</text>
<text x="119" y="186" text-anchor="middle" font-size="10" fill="#0f172a">le processeur</text>
<text x="119" y="200" text-anchor="middle" font-size="9" fill="#64748b">le cerveau</text>

<rect x="196" y="84" width="22" height="120" rx="3" fill="#1d4ed8"/>
<rect x="226" y="84" width="22" height="120" rx="3" fill="#1d4ed8"/>
<text x="222" y="222" text-anchor="middle" font-size="10" fill="#0f172a">barrettes de RAM</text>
<text x="222" y="236" text-anchor="middle" font-size="9" fill="#64748b">la mémoire vive</text>

<rect x="276" y="110" width="76" height="14" rx="3" fill="#b45309"/>
<rect x="276" y="134" width="76" height="14" rx="3" fill="#b45309"/>
<rect x="276" y="158" width="76" height="14" rx="3" fill="#b45309"/>
<text x="314" y="192" text-anchor="middle" font-size="10" fill="#0f172a">connecteurs</text>
<text x="314" y="206" text-anchor="middle" font-size="10" fill="#0f172a">d&apos;extension</text>

<rect x="396" y="60" width="118" height="62" rx="6" fill="#78716c"/>
<text x="455" y="96" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">DISQUE DUR</text>
<text x="455" y="138" text-anchor="middle" font-size="10" fill="#64748b">le stockage, en Go</text>

<rect x="396" y="160" width="118" height="48" rx="6" fill="#475569"/>
<text x="455" y="189" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">ALIMENTATION</text>

<rect x="396" y="226" width="118" height="48" rx="6" fill="#0f766e"/>
<text x="455" y="248" text-anchor="middle" font-size="11" font-weight="700" fill="#ffffff">VENTILATEUR</text>
<text x="455" y="264" text-anchor="middle" font-size="9" fill="#ccfbf1">il refroidit le CPU</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : ouvrir l''unité centrale', 3, 'interactif', '{
  "widget": "composants-uc",
  "consigne": "L''unité centrale s''ouvre devant toi. Clique sur chaque composant — le processeur, les barrettes de mémoire, le disque dur, les connecteurs d''extension, l''alimentation, le ventilateur — et la simulation te donne son rôle, son unité de mesure et ce qui se passe quand il tombe en panne. Essaie ensuite de retirer un composant : elle te dira si la machine démarre encore."
}', NULL, 10),
      (v_chapitre_id, 'La mémoire vive et les connecteurs d''extension', 4, 'texte', '
### La mémoire vive

Généralement appelée **RAM**, pour *Random Access Memory* — « mémoire à accès
aléatoire » — c''est une mémoire **volatile**.

Volatile veut dire qu''elle **perd son contenu dès qu''on coupe le courant**.
C''est pour cela que tu perds ton texte non enregistré quand l''électricité
saute.

Elle constitue la **mémoire principale** du système, car elle conserve les
informations traitées par le processeur pendant une session de travail.

**Ne confonds pas avec le disque dur.** La RAM est rapide mais volatile et
petite : elle sert de plan de travail. Le disque dur est lent mais permanent et
grand : il sert d''armoire de rangement.

Et surtout, ne confonds pas RAM et ROM. La **ROM**, *Read Only Memory*, est la
mémoire **morte** : on la lit, on ne l''écrit pas, et elle garde son contenu
hors tension. Une question de Probatoire pose exactement ce piège à l''envers :
« la RAM est une mémoire morte et la ROM une mémoire vive » — c''est faux.

### Les connecteurs d''extension

Ce sont des **emplacements disponibles sur la carte mère** destinés à recevoir
des cartes d''usages divers.

Tu peux y brancher une carte satellite, une carte TV, une carte son, une carte
graphique, une carte réseau.

C''est là tout l''intérêt : une carte d''extension **ajoute une fonctionnalité** à
un ordinateur qui ne l''avait pas.

### La carte mère

C''est la grande plaque verte sur laquelle tout est branché. Elle porte le
processeur, la mémoire, les connecteurs d''extension, et elle relie le tout.

---

**Exercice corrigé**

*Une carte que l''on ajoute à un ordinateur pour lui augmenter une
fonctionnalité supplémentaire est : a) une carte graphique, b) une carte
d''extension, c) une carte physique, d) une carte son.*

**Correction.** La réponse est **b) une carte d''extension**.

C''est le terme général. La carte graphique et la carte son en sont des exemples
particuliers : ce sont des cartes d''extension, mais toutes les cartes
d''extension ne sont pas des cartes graphiques. En examen, quand une réponse
englobe une autre, c''est la plus générale qu''on attend.
', NULL, 22),
      (v_chapitre_id, 'Simulation : régler les caractéristiques d''un processeur', 5, 'interactif', '{
  "widget": "caracteristiques-cpu",
  "consigne": "Fais varier la fréquence, le jeu d''instruction et la quantité de mémoire adressable, et regarde une tâche se dérouler plus ou moins vite à l''écran. Baisse la mémoire vive et tu verras la machine ramer alors que le processeur, lui, n''a pas bougé : c''est la démonstration qu''un ordinateur ne va jamais plus vite que son composant le plus lent."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 2', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que signifie CPU ?",
      "choix": [
        "Computer Processing Unit",
        "Central Processing Unit",
        "Central Program Unit",
        "Computer Program Utility"
      ],
      "bonne": 1,
      "explication": "Unité centrale de traitement, en français. C''est le cerveau de l''ordinateur, fabriqué le plus souvent en silicium."
    },
    {
      "question": "Quelles sont les deux parties essentielles du processeur ?",
      "choix": [
        "La RAM et la ROM",
        "L''unité de contrôle et l''unité arithmétique et logique",
        "Le disque dur et la carte mère",
        "Le BIOS et le chipset"
      ],
      "bonne": 1,
      "explication": "L''unité de contrôle organise les travaux, l''UAL effectue les calculs et les opérations logiques. L''une organise, l''autre calcule."
    },
    {
      "question": "Parmi ces quatre éléments, lequel n''est PAS une caractéristique du processeur ?",
      "choix": [
        "Sa marque",
        "Sa fréquence",
        "Sa couleur",
        "Son jeu d''instruction"
      ],
      "bonne": 2,
      "explication": "Les quatre caractéristiques sont la marque, la fréquence, le jeu d''instruction et la quantité de mémoire adressable."
    },
    {
      "question": "Que veut dire « la RAM est volatile » ?",
      "choix": [
        "Elle est très rapide",
        "Elle perd son contenu dès qu''on coupe le courant",
        "Elle peut être retirée facilement",
        "Elle chauffe beaucoup"
      ],
      "bonne": 1,
      "explication": "C''est pour cela qu''on perd un texte non enregistré quand l''électricité saute. Le disque dur, lui, garde son contenu hors tension."
    },
    {
      "question": "Vrai ou faux : la RAM est une mémoire morte et la ROM une mémoire vive.",
      "choix": [
        "Vrai",
        "Faux, c''est exactement l''inverse",
        "Les deux sont des mémoires mortes",
        "Les deux sont des mémoires vives"
      ],
      "bonne": 1,
      "explication": "La RAM (Random Access Memory) est la mémoire VIVE, la ROM (Read Only Memory) la mémoire MORTE. Cette question est tombée telle quelle au Probatoire."
    },
    {
      "question": "À quoi servent les connecteurs d''extension ?",
      "choix": [
        "À brancher l''écran",
        "À recevoir des cartes qui ajoutent une fonctionnalité",
        "À alimenter la carte mère",
        "À refroidir le processeur"
      ],
      "bonne": 1,
      "explication": "Carte graphique, carte son, carte réseau, carte TV : ce sont toutes des cartes d''extension, et elles se branchent sur ces connecteurs."
    },
    {
      "question": "Que signifient les sigles RISC et CISC ?",
      "choix": [
        "Deux marques de processeurs",
        "Deux architectures de processeur, à jeu d''instructions réduit ou complexe",
        "Deux types de mémoire",
        "Deux systèmes d''exploitation"
      ],
      "bonne": 1,
      "explication": "RISC pour Reduced Instruction Set Computer, CISC pour Complex Instruction Set Computer."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 6 leçons ajoutées au chapitre 2, Les composants de l''unité centrale.', v_nom;
  END LOOP;
END $inf1$;
