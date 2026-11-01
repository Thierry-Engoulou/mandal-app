-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 1 : L'environnement informatique
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
    WHERE programme_id = v_programme_id AND ordre = 1;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'L''environnement informatique', 1, 'Module 1 : Systèmes informatiques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 1 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 1 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le système informatique et ses trois types', 1, 'texte', '
Nous ouvrons le programme de Terminale par la question qui a servi d''entrée en
matière au Baccalauréat 2023 : qu''est-ce qu''un système informatique ?

### La définition

Un **système informatique** est un **ensemble de moyens informatiques et de
télécommunications** permettant de **collecter, traiter, stocker et acheminer**
des données.

Apprends-la telle quelle. Elle vaut un point entier, et le correcteur attend
les quatre verbes.

Remarque qu''un système informatique n''est pas seulement une machine : ce sont
des **moyens**, au pluriel, du matériel et des liaisons, mis ensemble pour
servir un but.

### Système informatique et système d''information

Ne confonds pas les deux, le programme les distingue.

Le **système d''information** est l''ensemble organisé de **ressources** —
humaines, matérielles et logicielles — qui permet de collecter, stocker,
traiter et diffuser l''information. Il comprend donc des **personnes** et des
**procédures**.

Le **système informatique** en est la **partie automatisée** : les machines,
les logiciels et les réseaux.

Autrement dit, le système informatique est l''outil, le système d''information
est l''organisation qui s''en sert. Le secrétaire qui saisit les notes fait
partie du système d''information, pas du système informatique.

### Les trois types de systèmes informatiques

C''est l''une des trois actions du programme pour cette leçon, et elle tombe.

**1. Les systèmes personnels.** Ils sont au service de **leur seul
propriétaire**. On y range l''ordinateur, la tablette, le téléphone,
l''imprimante, le scanner, le modem, le commutateur et la box internet de la
maison.

Leurs usages : la navigation sur le web, la messagerie et les réseaux sociaux,
les jeux, la bureautique — tableur, traitement de texte, gestion de données —
et le multimédia.

**2. Les systèmes d''organisation.** Ils sont hébergés par une **entreprise, une
association ou une administration**, et rendent de **nombreux services à de
nombreux usagers**. On y trouve les serveurs de données, les serveurs
d''applications, les capteurs, les systèmes répartis et les services dans le
nuage.

Le serveur qui héberge les notes de ton lycée en est un.

**3. Les systèmes de contrôle-commande.** Ils **pilotent un procédé**, le plus
souvent industriel, à travers une interface homme-machine et un réseau de
communication numérique.

Leur fonctionnement est toujours le même, en trois temps : des **capteurs**
relèvent l''état du procédé, le système **traite** l''information, et des
**actionneurs** agissent sur le procédé. Un robot en est l''exemple type ; la
chaîne d''embouteillage d''une brasserie aussi.

La façon de les retenir : le premier sert **une personne**, le deuxième sert
**une organisation**, le troisième sert **une machine**.

---

**Exercice corrigé**

*Classer chacun de ces systèmes : a) le portable d''un élève et son imprimante ;
b) le serveur de la SONARA qui gère les stocks ; c) le dispositif qui régule
automatiquement la température d''une cuve dans une usine.*

**Correction.**

a) Un **système personnel** : il est au service de son seul propriétaire.

b) Un **système d''organisation** : hébergé par une entreprise, il rend service
à de nombreux usagers.

c) Un **système de contrôle-commande** : un capteur mesure la température, le
système compare à la consigne, un actionneur ouvre ou ferme la vanne. Aucun
être humain n''est dans la boucle en temps normal, et c''est précisément ce qui
le caractérise.
', NULL, 25),
      (v_chapitre_id, 'Figure : les trois types de systèmes informatiques', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 250" width="560" height="250">
<rect width="560" height="250" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les trois types de systèmes informatiques</text>

<rect x="16" y="38" width="168" height="186" rx="10" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
<text x="100" y="60" text-anchor="middle" font-size="12" font-weight="700" fill="#1e3a8a">PERSONNEL</text>
<text x="100" y="78" text-anchor="middle" font-size="10" fill="#1e40af">au service d&apos;une seule personne</text>
<rect x="56" y="92" width="52" height="38" rx="3" fill="#1e3a8a"/>
<rect x="68" y="130" width="28" height="6" fill="#1e3a8a"/>
<rect x="50" y="136" width="64" height="5" rx="2" fill="#1e3a8a"/>
<rect x="118" y="100" width="36" height="24" rx="3" fill="#60a5fa"/>
<text x="100" y="166" text-anchor="middle" font-size="9" fill="#1e40af">ordinateur, tablette,</text>
<text x="100" y="180" text-anchor="middle" font-size="9" fill="#1e40af">imprimante, scanner,</text>
<text x="100" y="194" text-anchor="middle" font-size="9" fill="#1e40af">modem, box internet</text>
<text x="100" y="214" text-anchor="middle" font-size="9" font-weight="700" fill="#1e3a8a">chez toi</text>

<rect x="196" y="38" width="168" height="186" rx="10" fill="#dcfce7" stroke="#15803d" stroke-width="2"/>
<text x="280" y="60" text-anchor="middle" font-size="12" font-weight="700" fill="#14532d">D&apos;ORGANISATION</text>
<text x="280" y="78" text-anchor="middle" font-size="10" fill="#166534">au service de nombreux usagers</text>
<rect x="238" y="92" width="26" height="48" rx="3" fill="#14532d"/>
<rect x="268" y="92" width="26" height="48" rx="3" fill="#14532d"/>
<rect x="298" y="92" width="26" height="48" rx="3" fill="#14532d"/>
<text x="280" y="166" text-anchor="middle" font-size="9" fill="#166534">serveurs de données,</text>
<text x="280" y="180" text-anchor="middle" font-size="9" fill="#166534">serveurs d&apos;applications,</text>
<text x="280" y="194" text-anchor="middle" font-size="9" fill="#166534">systèmes répartis, nuage</text>
<text x="280" y="214" text-anchor="middle" font-size="9" font-weight="700" fill="#14532d">dans une entreprise, un lycée</text>

<rect x="376" y="38" width="168" height="186" rx="10" fill="#fef3c7" stroke="#ca8a04" stroke-width="2"/>
<text x="460" y="60" text-anchor="middle" font-size="12" font-weight="700" fill="#78350f">CONTRÔLE-COMMANDE</text>
<text x="460" y="78" text-anchor="middle" font-size="10" fill="#92400e">au service d&apos;un procédé</text>
<circle cx="408" cy="112" r="12" fill="#ca8a04"/>
<text x="408" y="140" text-anchor="middle" font-size="8" fill="#78350f">capteur</text>
<rect x="436" y="100" width="48" height="24" rx="3" fill="#78350f"/>
<text x="460" y="116" text-anchor="middle" font-size="8" fill="#ffffff">calcul</text>
<text x="460" y="140" text-anchor="middle" font-size="8" fill="#78350f">traitement</text>
<circle cx="512" cy="112" r="12" fill="#ca8a04"/>
<text x="512" y="140" text-anchor="middle" font-size="8" fill="#78350f">actionneur</text>
<line x1="420" y1="112" x2="434" y2="112" stroke="#78350f" stroke-width="1.6"/>
<line x1="486" y1="112" x2="498" y2="112" stroke="#78350f" stroke-width="1.6"/>
<text x="460" y="166" text-anchor="middle" font-size="9" fill="#92400e">pilote un procédé industriel</text>
<text x="460" y="180" text-anchor="middle" font-size="9" fill="#92400e">par une interface</text>
<text x="460" y="194" text-anchor="middle" font-size="9" fill="#92400e">homme-machine</text>
<text x="460" y="214" text-anchor="middle" font-size="9" font-weight="700" fill="#78350f">un robot, une usine</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : classer les systèmes informatiques', 3, 'interactif', '{
  "widget": "types-systemes",
  "consigne": "Douze situations te sont présentées — le portable d''un élève, le serveur de notes du lycée, le robot d''une chaîne d''embouteillage, la box internet d''une famille, le dispositif qui régule une cuve. Classe chacune dans l''un des trois types. La simulation te renvoie à chaque fois la question qui tranche : ce système sert-il une personne, une organisation, ou une machine ?"
}', NULL, 10),
      (v_chapitre_id, 'Les périphériques et leurs caractéristiques', 4, 'texte', '
Le programme demande de **décrire les caractéristiques de quelques
périphériques**. Deux reviennent presque toujours : l''imprimante et l''écran.

### L''imprimante

**Ses trois familles.**

L''imprimante **matricielle**, ou à aiguilles, frappe un ruban encreur. Elle est
lente et bruyante, mais elle imprime en plusieurs exemplaires d''un coup, ce qui
lui vaut de survivre pour les factures à souche.

L''imprimante **à jet d''encre** projette de minuscules gouttes. Elle est bon
marché à l''achat, excellente en couleur, et coûteuse à l''usage : les cartouches
sèchent.

L''imprimante **laser** utilise un toner et un tambour. Elle est rapide, nette
sur le texte, et la plus économique dès qu''on imprime beaucoup.

**Ses caractéristiques.**

| Caractéristique | Unité | Ce qu''elle dit |
| --- | --- | --- |
| la **vitesse** | pages par minute (ppm) | combien de pages à la minute |
| la **résolution** | points par pouce (ppp, ou *dpi*) | la finesse de l''impression |
| le **format de papier** | A4, plus rarement A3 | la taille maximale |
| le **temps de préchauffage** | secondes | l''attente avant la première page |
| la **mémoire embarquée** | méga-octets | le nombre de pages mises en file |

### L''écran

**Ses deux familles.** L''écran à **tube cathodique** (CRT), encombrant et
aujourd''hui disparu des catalogues, et l''**écran plat**.

**Ses caractéristiques.**

La **taille**, en **pouces**, mesurée **sur la diagonale**. Un pouce vaut
2,54 cm.

Le **pas de masque**, en millimètres : la distance entre deux points de même
couleur. Plus il est petit, plus l''image est fine.

La **finesse**, c''est-à-dire la **résolution** en pixels : 1 920 × 1 080 par
exemple.

La **fréquence de balayage**, en **hertz** : le nombre d''images affichées par
seconde. En dessous de 60 Hz sur un tube cathodique, l''œil percevait un
scintillement.

---

**Exercice corrigé**

*Une fiche technique annonce « Écran 18,5" ». Quelle est cette unité, comment
la mesure-t-on, et quelle est la taille de l''écran en centimètres ?*

**Correction.** L''unité est le **pouce**, et on le mesure **sur la diagonale**
de la dalle, d''un coin au coin opposé — jamais la largeur.

Un pouce valant 2,54 cm :

$$18{,}5 \times 2{,}54 = 46{,}99 \text{ cm}$$

L''écran mesure donc environ **47 cm** en diagonale.

*Cette question est tombée telle quelle au Baccalauréat 2024, pour 0,75 point.
Elle ne demande qu''une multiplication, mais encore faut-il savoir que le pouce
se mesure en diagonale et qu''il vaut 2,54 cm.*
', NULL, 25),
      (v_chapitre_id, 'Simulation : lire une fiche de périphérique', 5, 'interactif', '{
  "widget": "fiche-peripherique",
  "consigne": "Des fiches techniques d''imprimantes et d''écrans défilent, et tu dois retrouver chaque caractéristique et son unité : les pages par minute, les points par pouce, les pouces en diagonale, les hertz. Un convertisseur te donne la diagonale en centimètres pendant que tu fais varier les pouces, et un comparateur met côte à côte une matricielle, une jet d''encre et une laser pour le même travail d''impression."
}', NULL, 10),
      (v_chapitre_id, 'Les types de logiciels', 6, 'texte', '
Troisième action du programme pour cette leçon. La classification du cours
camerounais distingue six catégories, qu''on regroupe en trois familles.

### Les logiciels de base

Ce sont les programmes qui **gèrent et contrôlent le matériel**. Le système
d''exploitation en est le représentant : Windows, Linux, Android, macOS. Les
pilotes en font partie aussi.

Sans eux, la machine ne fait rien. Ils ne servent pas directement l''utilisateur,
ils servent la machine.

### Les logiciels d''application

Ce sont les programmes qui **exécutent les tâches de l''utilisateur** : la paie,
la facturation, la comptabilité, le traitement de texte, le tableur.

On les subdivise à leur tour :

Le **progiciel de gestion intégré**, en anglais **ERP** pour *Enterprise
Resource Planning* — en français **PGI** —, est un logiciel qui **centralise
les données de tous les services** d''une entreprise pour améliorer la
planification et les décisions.

Le **progiciel métier** est construit par un éditeur spécialisé autour des
bonnes pratiques d''une profession : un logiciel de pharmacie, un logiciel de
cabinet médical.

Le **logiciel spécifique** est développé **sur mesure** par l''organisation
elle-même, pour un besoin que rien du commerce ne couvre.

### Les procédures

Ce sont les **modes opératoires** : les instructions qui expliquent aux usagers
comment travailler avec le système. Elles ne sont pas des programmes, et elles
font pourtant partie du système d''information.

C''est une subtilité du programme de Terminale qu''il faut avoir vue au moins une
fois.

---

**Exercice corrigé**

*Classer : a) Windows 10 ; b) le logiciel de gestion des notes écrit par le
professeur d''informatique du lycée pour son établissement ; c) un logiciel de
gestion de pharmacie vendu par un éditeur ; d) la note de service qui explique
comment saisir les notes.*

**Correction.**

a) Un **logiciel de base** : c''est un système d''exploitation, il gère le
matériel.

b) Un **logiciel spécifique** : développé en interne pour un besoin propre à
l''établissement.

c) Un **progiciel métier** : construit par un éditeur spécialisé autour des
pratiques d''une profession, et vendu à toutes les pharmacies.

d) Une **procédure** : ce n''est pas un programme, c''est un mode opératoire — et
elle fait pourtant partie du système d''information.
', NULL, 22),
      (v_chapitre_id, 'Simulation : à chaque logiciel sa famille', 7, 'interactif', '{
  "widget": "types-logiciels",
  "consigne": "Dix logiciels et documents te sont décrits par ce qu''ils font, sans dire leur nom de famille : un système d''exploitation, un tableur, un progiciel de pharmacie, un outil écrit sur mesure par le lycée, une note de service. Range chacun dans sa catégorie. La simulation te montre ensuite la pyramide complète — logiciels de base, logiciels d''application avec leurs trois sous-familles, et procédures — et surligne celle que tu viens de choisir."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 1', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la définition d''un système informatique ?",
      "choix": [
        "Un ordinateur et ses périphériques",
        "Un ensemble de moyens informatiques et de télécommunications permettant de collecter, traiter, stocker et acheminer des données",
        "Le système d''exploitation d''une machine",
        "L''ensemble des logiciels d''une entreprise"
      ],
      "bonne": 1,
      "explication": "Le correcteur attend les quatre verbes : collecter, traiter, stocker, acheminer. Cette question valait un point entier au Baccalauréat 2023."
    },
    {
      "question": "Quels sont les trois types de systèmes informatiques ?",
      "choix": [
        "Personnels, d''organisation et de contrôle-commande",
        "Petits, moyens et grands",
        "Matériels, logiciels et réseaux",
        "Centralisés, répartis et distribués"
      ],
      "bonne": 0,
      "explication": "Le premier sert une personne, le deuxième sert une organisation, le troisième sert une machine. C''est le moyen le plus sûr de les retenir."
    },
    {
      "question": "Comment fonctionne un système de contrôle-commande ?",
      "choix": [
        "Il affiche des pages web",
        "Des capteurs relèvent l''état du procédé, le système traite l''information, des actionneurs agissent sur le procédé",
        "Il stocke les données d''une entreprise",
        "Il relie plusieurs ordinateurs personnels"
      ],
      "bonne": 1,
      "explication": "Capteur, traitement, actionneur : c''est toujours cette boucle. Un robot en est l''exemple type, la régulation d''une cuve aussi."
    },
    {
      "question": "Quelle est la différence entre système informatique et système d''information ?",
      "choix": [
        "Aucune",
        "Le système d''information comprend aussi les personnes et les procédures ; le système informatique en est la partie automatisée",
        "Le système informatique est plus grand",
        "Le système d''information ne concerne que les réseaux"
      ],
      "bonne": 1,
      "explication": "Le système informatique est l''outil, le système d''information est l''organisation qui s''en sert. Le secrétaire qui saisit les notes en fait partie."
    },
    {
      "question": "Dans quelle unité mesure-t-on la résolution d''une imprimante ?",
      "choix": [
        "En pages par minute",
        "En points par pouce",
        "En hertz",
        "En octets"
      ],
      "bonne": 1,
      "explication": "Le point par pouce — ppp, ou dpi — mesure la finesse. Les pages par minute, elles, mesurent la vitesse : ce sont deux caractéristiques différentes."
    },
    {
      "question": "Un écran de 18,5 pouces mesure environ, en diagonale :",
      "choix": [
        "18,5 cm",
        "47 cm",
        "37 cm",
        "74 cm"
      ],
      "bonne": 1,
      "explication": "18,5 × 2,54 = 46,99 cm, soit environ 47 cm. Et c''est bien la diagonale qu''on mesure, jamais la largeur. Question tombée au Baccalauréat 2024."
    },
    {
      "question": "Un logiciel de gestion écrit sur mesure par le lycée pour lui-même est :",
      "choix": [
        "un logiciel de base",
        "un progiciel métier",
        "un logiciel spécifique",
        "une procédure"
      ],
      "bonne": 2,
      "explication": "Spécifique parce qu''il est développé en interne pour un besoin propre. Le progiciel métier, lui, est vendu par un éditeur à toute une profession."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 1, L''environnement informatique.', v_nom;
  END LOOP;
END $inf7$;
