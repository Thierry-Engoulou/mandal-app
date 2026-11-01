-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 7 : Les familles et les types de réseaux
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
    WHERE programme_id = v_programme_id AND ordre = 7;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les familles et les types de réseaux', 7, 'Module 1 : Systèmes informatiques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 7 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 7 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Qu''est-ce qu''un réseau informatique ?', 1, 'texte', '
Nous entrons dans la partie du programme la plus présente au Baccalauréat :
quatre unités d''enseignement sur les réseaux, et une question à chaque session.

### La définition

Un **réseau informatique** est un **ensemble d''équipements informatiques reliés
entre eux pour échanger des informations**.

Apprends-la mot pour mot : elle a valu **un point** au Baccalauréat 2024, où
elle était la toute première question.

Note bien « équipements », et non « ordinateurs » : une imprimante réseau, un
téléphone, une caméra de surveillance font partie du réseau.

### Pourquoi relier les machines

Quatre raisons, qu''on demande parfois de citer.

**Partager des ressources matérielles.** Une seule imprimante pour quinze
postes, un seul accès à Internet.

**Partager des données.** Le même fichier de notes consulté par tous les
professeurs, sans copie sur clé USB — et sans virus qui circule avec.

**Communiquer.** Messagerie, messagerie instantanée, visioconférence.

**Centraliser l''administration.** Sauvegarder, mettre à jour et surveiller
depuis un seul poste.

### Ce qu''il faut pour en construire un

Trois ingrédients, pas un de moins :

des **équipements terminaux** — les ordinateurs, les imprimantes ;
un **support de transmission** — un câble, ou des ondes ;
des **équipements d''interconnexion** — un commutateur, un routeur ;
et un **langage commun**, c''est-à-dire des **protocoles**.

Les trois chapitres qui suivent traitent chacun l''un de ces points.

---

**Exercice corrigé**

*Définir « réseau informatique », puis citer deux avantages qu''un lycée tire de
la mise en réseau de sa salle d''informatique.*

**Correction.**

Un réseau informatique est un **ensemble d''équipements informatiques reliés
entre eux pour échanger des informations**.

*Deux avantages, parmi ceux attendus :*

**Le partage de ressources** : une seule imprimante et un seul accès à Internet
servent toute la salle, au lieu d''un équipement par poste.

**Le partage des données** : les élèves déposent leurs travaux dans un dossier
commun, et le professeur les relève sans passer de poste en poste avec une clé
USB — ce qui supprime au passage la principale voie de contamination par les
virus.

*On accepte aussi la communication interne et l''administration centralisée du
parc.*
', NULL, 22),
      (v_chapitre_id, 'Simulation : pourquoi mettre en réseau ?', 2, 'interactif', '{
  "widget": "pourquoi-reseau",
  "consigne": "Une salle de huit postes isolés t''est confiée, avec huit imprimantes, huit abonnements internet et une clé USB qui circule. Relie les machines une à une et regarde les compteurs changer : le coût du matériel, le temps perdu à transporter les fichiers, le nombre de machines infectées par la clé. La simulation chiffre ce que le réseau fait économiser au bout d''une année."
}', NULL, 10),
      (v_chapitre_id, 'La classification par l''étendue géographique', 3, 'texte', '
C''est l''action principale du programme pour cette leçon, et le tableau se
retient en deux minutes.

### Les réseaux filaires

**PAN** — *Personal Area Network*. Un **petit réseau personnel**, d''une dizaine
de mètres. Ton téléphone relié à ton ordinateur.

**LAN** — *Local Area Network*. Un réseau **à l''intérieur d''un bâtiment**, ou
couvrant une zone de **moins de 10 km**. La salle de TP du lycée en est un.

**MAN** — *Metropolitan Area Network*. Un réseau **limité à une ville**. Les
agences d''une banque reliées dans tout Douala.

**WAN** — *Wide Area Network*. Un réseau **de la taille d''un pays au moins**,
et souvent de la planète entière.

### Les réseaux sans fil : on ajoute un W

La règle est mécanique : le **W** de *Wireless*, « sans fil », se met devant.

| Sigle | Nom | Portée | Technologie |
| --- | --- | --- | --- |
| **WPAN** | Wireless PAN | quelques mètres | Bluetooth, infrarouge |
| **WLAN** | Wireless LAN | une centaine de mètres | le **Wi-Fi** |
| **WMAN** | Wireless MAN | une ville | la **boucle locale radio** |
| **WWAN** | Wireless WAN | un pays, le monde | le **réseau cellulaire** : GSM, GPRS, UMTS |

Le WWAN est celui que tu utilises tous les jours sans le nommer : c''est le
réseau de ton opérateur mobile.

### Les avantages du sans-fil

Le cours camerounais en énumère cinq, et ils tombent :

la **mobilité**, puisqu''on se déplace sans se débrancher ;
la **facilité de connexion**, immédiate dès qu''on est dans la zone couverte et
autorisé ;
la **souplesse**, car la zone de couverture se règle ;
le **faible coût**, la main-d''œuvre d''installation étant réduite ;
l''**évolutivité**, le réseau s''agrandissant ou se réduisant facilement.

---

**Exercice corrigé**

*Déterminer le type de réseau qu''on peut mettre en place dans une salle de
travaux pratiques d''un établissement scolaire.*

**Correction.** Un **réseau local**, c''est-à-dire un **LAN**.

*La justification*, qu''il vaut mieux donner même si on ne la demande pas : une
salle de travaux pratiques occupe quelques dizaines de mètres, à l''intérieur
d''un même bâtiment. On est donc très en dessous des 10 km qui marquent la
limite du réseau local.

*Si les postes sont reliés sans fil*, on parle plus précisément de **WLAN**, un
réseau local sans fil — ce qui reste un LAN.

*Cette question est tombée au Baccalauréat 2025, pour 0,5 point.*
', NULL, 24),
      (v_chapitre_id, 'Figure : les réseaux classés par leur étendue', 4, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 280" width="560" height="280">
<rect width="560" height="280" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les réseaux classés par leur étendue</text>

<circle cx="280" cy="150" r="118" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.6"/>
<circle cx="280" cy="150" r="88" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.6"/>
<circle cx="280" cy="150" r="56" fill="#dcfce7" stroke="#15803d" stroke-width="1.6"/>
<circle cx="280" cy="150" r="26" fill="#dbeafe" stroke="#2563eb" stroke-width="1.6"/>

<text x="280" y="148" text-anchor="middle" font-size="10" font-weight="700" fill="#1e3a8a">PAN</text>
<text x="280" y="160" text-anchor="middle" font-size="7" fill="#1e40af">10 m</text>

<text x="280" y="120" text-anchor="middle" font-size="10" font-weight="700" fill="#14532d">LAN</text>
<text x="280" y="131" text-anchor="middle" font-size="7" fill="#166534">&lt; 10 km</text>

<text x="280" y="88" text-anchor="middle" font-size="10" font-weight="700" fill="#78350f">MAN</text>
<text x="280" y="99" text-anchor="middle" font-size="7" fill="#92400e">une ville</text>

<text x="280" y="58" text-anchor="middle" font-size="10" font-weight="700" fill="#7f1d1d">WAN</text>
<text x="280" y="69" text-anchor="middle" font-size="7" fill="#991b1b">un pays, la planète</text>

<text x="30" y="200" font-size="10" font-weight="700" fill="#0f172a">Sans fil : on ajoute un W devant</text>
<text x="30" y="218" font-size="9" fill="#334155">WPAN — Bluetooth, quelques mètres</text>
<text x="30" y="234" font-size="9" fill="#334155">WLAN — le Wi-Fi, une centaine de mètres</text>
<text x="30" y="250" font-size="9" fill="#334155">WMAN — la boucle locale radio, une ville</text>
<text x="30" y="266" font-size="9" fill="#334155">WWAN — le réseau cellulaire : GSM, GPRS, UMTS</text>

<text x="392" y="218" font-size="9" fill="#64748b">Une salle de TP : un LAN.</text>
<text x="392" y="234" font-size="9" fill="#64748b">Les agences d&apos;une banque</text>
<text x="392" y="248" font-size="9" fill="#64748b">dans Douala : un MAN.</text>
<text x="392" y="266" font-size="9" fill="#64748b">Internet : le WAN des WAN.</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : à chaque situation son réseau', 5, 'interactif', '{
  "widget": "etendue-reseaux",
  "consigne": "Dix situations te sont décrites — une salle de TP, les agences d''une banque dans Douala, un casque Bluetooth, le réseau de ton opérateur, les sites d''une entreprise entre Yaoundé et Garoua — et tu dois nommer le type de réseau. La simulation place chaque réponse sur une carte à l''échelle, des dix mètres à la planète entière, et ajoute ou retire le W selon que tu as choisi le filaire ou le sans-fil."
}', NULL, 10),
      (v_chapitre_id, 'Internet, intranet et extranet', 6, 'texte', '
Trois mots qui se ressemblent, trois réalités différentes. Le programme demande
explicitement de les **différencier**.

### Internet

Un **ensemble mondial de réseaux interconnectés**, qui permet aux machines et
aux serveurs de communiquer efficacement grâce à un **protocole commun, IP**.

C''est un réseau **public** : n''importe qui peut s''y connecter.

Le mot s''écrit avec une majuscule quand il désigne **le** réseau mondial.

### Intranet

Un **réseau privé**, utilisé par les **employés d''une entreprise** ou les
membres d''une autre organisation, et qui **emploie les mêmes protocoles**
qu''Internet.

C''est la clé : techniquement, c''est la même chose qu''Internet — mêmes
protocoles, mêmes navigateurs, mêmes pages web. Ce qui change, c''est **qui y a
accès** : les gens de la maison, et personne d''autre.

L''intranet d''un lycée hébergerait les emplois du temps, les notes, les notes de
service.

### Extranet

Un réseau qui **relie plusieurs sites d''une même entreprise**, ou qui **connecte
l''entreprise à des partenaires ou des clients extérieurs**.

C''est un intranet dont on **ouvre une porte** à des gens de l''extérieur, mais à
eux seuls et sur une partie seulement.

Le fournisseur qui consulte l''état des stocks de son client, le parent d''élève
qui consulte les notes de son enfant : ils passent par un extranet.

### Le tableau qui tranche

| | Qui y accède | Protocoles |
| --- | --- | --- |
| **Internet** | tout le monde | IP et la famille TCP/IP |
| **Intranet** | les membres de l''organisation | **les mêmes** |
| **Extranet** | les membres, **plus** des partenaires choisis | **les mêmes** |

La question d''examen porte toujours sur la **première colonne** : les trois
utilisent les mêmes protocoles, et c''est l''accès qui les distingue.

---

**Exercice corrigé**

*Différencier internet, intranet et extranet.*

**Correction.**

**Internet** est l''ensemble mondial de réseaux interconnectés, **public**, qui
permet à toute machine connectée de communiquer avec toute autre grâce au
protocole IP.

**L''intranet** est un réseau **privé**, réservé aux membres d''une organisation
— les employés d''une entreprise, le personnel d''un établissement —, et qui
utilise **les mêmes protocoles** qu''Internet.

**L''extranet** est un réseau qui relie plusieurs sites d''une même entreprise, ou
qui **ouvre une partie de l''intranet à des partenaires ou des clients
extérieurs** choisis.

*La phrase qui résume et qui rapporte le point : les trois reposent sur les
mêmes protocoles, et ce qui les distingue est l''étendue des personnes
autorisées à y accéder.*
', NULL, 24),
      (v_chapitre_id, 'Simulation : qui accède à quoi ?', 7, 'interactif', '{
  "widget": "internet-intranet-extranet",
  "consigne": "Une entreprise camerounaise s''affiche avec son siège, ses deux agences, ses employés, ses fournisseurs et le grand public. Tu places chaque ressource — le site vitrine, l''annuaire interne, le catalogue des stocks, les bulletins de paie — dans internet, intranet ou extranet. La simulation fait ensuite frapper à la porte chaque catégorie de visiteur et te montre ce qu''elle peut voir."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 7', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la définition d''un réseau informatique ?",
      "choix": [
        "Un ensemble d''ordinateurs dans une même salle",
        "Un ensemble d''équipements informatiques reliés entre eux pour échanger des informations",
        "Internet",
        "Un ensemble de câbles et de prises"
      ],
      "bonne": 1,
      "explication": "« Équipements », et non « ordinateurs » : une imprimante réseau ou une caméra en font partie. Cette définition a valu un point au Baccalauréat 2024."
    },
    {
      "question": "Un réseau limité à une ville s''appelle :",
      "choix": [
        "un LAN",
        "un MAN",
        "un WAN",
        "un PAN"
      ],
      "bonne": 1,
      "explication": "MAN pour Metropolitan Area Network. Le LAN reste sous les 10 km, le WAN fait au moins la taille d''un pays."
    },
    {
      "question": "Quel type de réseau met-on en place dans une salle de travaux pratiques ?",
      "choix": [
        "Un WAN",
        "Un MAN",
        "Un LAN",
        "Un PAN"
      ],
      "bonne": 2,
      "explication": "Quelques dizaines de mètres dans un même bâtiment : on est très en dessous des 10 km du réseau local. Question du Baccalauréat 2025."
    },
    {
      "question": "Que désigne le sigle WLAN ?",
      "choix": [
        "Un réseau local sans fil, le Wi-Fi",
        "Un réseau mondial",
        "Un réseau de ville sans fil",
        "Un réseau personnel filaire"
      ],
      "bonne": 0,
      "explication": "Le W de Wireless se met devant le sigle filaire correspondant. WLAN = LAN sans fil, d''une portée d''une centaine de mètres."
    },
    {
      "question": "Le réseau de ton opérateur mobile — GSM, GPRS, UMTS — est un :",
      "choix": [
        "WPAN",
        "WLAN",
        "WMAN",
        "WWAN"
      ],
      "bonne": 3,
      "explication": "C''est le réseau cellulaire : un réseau étendu sans fil, à l''échelle d''un pays et au-delà."
    },
    {
      "question": "Qu''est-ce qu''un intranet ?",
      "choix": [
        "Un réseau mondial public",
        "Un réseau privé réservé aux membres d''une organisation, qui utilise les mêmes protocoles qu''Internet",
        "Un réseau sans fil",
        "Un réseau reliant une entreprise à ses clients"
      ],
      "bonne": 1,
      "explication": "Techniquement identique à Internet : mêmes protocoles, mêmes navigateurs. Ce qui change, c''est qui a le droit d''y accéder."
    },
    {
      "question": "Un parent d''élève qui consulte les notes de son enfant sur le portail du lycée passe par :",
      "choix": [
        "l''intranet",
        "l''extranet",
        "un réseau local",
        "un WPAN"
      ],
      "bonne": 1,
      "explication": "L''extranet ouvre une partie de l''intranet à des personnes extérieures choisies — partenaires, clients, familles."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 7, Les familles et les types de réseaux.', v_nom;
  END LOOP;
END $inf7$;
