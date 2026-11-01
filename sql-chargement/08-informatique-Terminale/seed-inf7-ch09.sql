-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 9 : Les équipements d'interconnexion réseau
-- Module 1 : Systèmes informatiques — 7 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 9;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les équipements d''interconnexion réseau', 9, 'Module 1 : Systèmes informatiques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 9 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 9 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les supports de transmission', 1, 'texte', '
Troisième ingrédient d''un réseau : ce par quoi l''information passe.

### La définition

Un **support de transmission** est le **canal physique** qui relie les
ordinateurs et les périphériques entre eux.

### Les deux grandes familles

**Les supports filaires**, c''est-à-dire les **câbles** : le cuivre et la fibre
optique.

**Les supports sans fil**, qui utilisent l''**infrarouge**, les **ondes radio**
ou les **micro-ondes**. Le Wi-Fi et le Bluetooth en relèvent.

### Ce qu''on compare

Quatre critères, qui reviennent dans toute question de comparaison :

le **débit**, en bits par seconde — combien de données passent à la seconde ;
la **portée**, en mètres ou en kilomètres ;
la **sensibilité aux perturbations** électromagnétiques ;
le **coût**, à l''achat et à l''installation.

### Filaire ou sans fil : ce que l''un a et l''autre pas

| | Filaire | Sans fil |
| --- | --- | --- |
| débit | **élevé et stable** | variable, partagé entre les usagers |
| sécurité | **bonne** : il faut accéder au câble | plus exposée : l''onde traverse les murs |
| installation | lourde : il faut tirer les câbles | **légère et rapide** |
| mobilité | nulle | **totale** |
| coût d''installation | élevé | **faible** |

Dans un lycée camerounais, la réponse pratique est souvent **les deux** : du
câble pour la salle de TP, où les postes ne bougent pas et où l''on veut du
débit, et du Wi-Fi pour les salles de cours et l''administration.

---

**Exercice corrigé**

*Un établissement veut relier les quinze postes de sa salle d''informatique,
située dans un bâtiment où l''on ne peut pas percer les murs. Filaire ou sans
fil ? Justifier.*

**Correction.** Le **sans-fil**, c''est-à-dire un **WLAN** en Wi-Fi.

*La raison décisive est donnée par l''énoncé* : on ne peut pas percer les murs,
donc on ne peut pas tirer les câbles jusqu''aux postes. L''installation sans fil
ne demande qu''un point d''accès.

*Les avantages qui s''y ajoutent* : un coût d''installation faible, puisque la
main-d''œuvre est réduite, et un réseau facile à agrandir si la salle s''étend.

*Les contreparties à signaler, car une bonne réponse les mentionne* : le débit
sera **partagé** entre les quinze postes et moins stable qu''en filaire, et la
sécurité demandera un chiffrement sérieux et un mot de passe solide, l''onde
traversant les murs.
', NULL, 22),
      (v_chapitre_id, 'Simulation : filaire ou sans fil ?', 2, 'interactif', '{
  "widget": "supports-transmission",
  "consigne": "Six locaux te sont proposés avec leurs contraintes : des murs qu''on ne peut percer, une salle de montage vidéo qui exige du débit, un amphithéâtre, un bâtiment classé. Choisis le support pour chacun et la simulation te montre le débit réellement obtenu par poste, le coût d''installation et le niveau d''exposition, puis te dit si ton choix tient."
}', NULL, 10),
      (v_chapitre_id, 'Les trois câbles du programme', 3, 'texte', '
Le programme nomme trois types de câbles. Il faut savoir les décrire et les
distinguer.

### La paire torsadée

**Sa structure.** Deux, quatre, six ou huit fils **torsadés deux à deux**, de
même couleur par paire, réunis dans une gaine.

**Pourquoi torsadés ?** Parce que la torsade annule les perturbations
électromagnétiques : ce qui gêne un fil gêne également son jumeau, et les deux
perturbations s''annulent.

**Ses qualités.** Elle est **souple, légère et facile à installer**. C''est de
très loin le câble le plus utilisé dans les réseaux locaux.

**Sa limite.** Elle ne transmet les signaux que sur **quelques dizaines de
mètres** — on retient **100 mètres** comme limite pratique.

**Ses deux variantes** : **non blindée** (UTP), la plus courante et la moins
chère, et **blindée** (STP), entourée d''une feuille métallique pour les
environnements perturbés — un atelier, une salle de machines.

Son connecteur est le **RJ45**.

### Le câble coaxial

**Sa structure**, de l''intérieur vers l''extérieur : un **fil de cuivre rigide**,
une **couche plastique** isolante, une **feuille ou une tresse métallique**, et
une **gaine plastique souple**.

La tresse métallique joue le rôle de blindage : le coaxial résiste bien aux
perturbations et porte plus loin que la paire torsadée.

C''était le câble de la topologie en **bus**. On ne le monte plus en réseau
local, mais il sert encore pour la télévision et les antennes.

### La fibre optique

Elle transporte la lumière dans un fil de verre ou de plastique extrêmement
fin.

**Ses qualités** : un **débit très élevé**, une **portée de plusieurs
kilomètres**, et une **insensibilité totale aux perturbations
électromagnétiques**, puisqu''elle ne transporte pas d''électricité.

**Ses limites** : un **coût élevé**, et une installation délicate — la fibre se
casse si on la plie, et les raccords demandent un matériel spécialisé.

C''est le câble des **artères** : entre deux bâtiments, entre deux villes, et
c''est elle qui apporte internet au Cameroun par les câbles sous-marins.

### Le tableau à retenir

| | Paire torsadée | Coaxial | Fibre optique |
| --- | --- | --- | --- |
| porte | de l''électricité | de l''électricité | de la **lumière** |
| portée | ~100 m | quelques centaines de m | **plusieurs km** |
| débit | bon | moyen | **très élevé** |
| perturbations | sensible | peu sensible | **insensible** |
| coût | **faible** | moyen | élevé |
| emploi | le réseau local | ancien, la télévision | les artères |

---

**Exercice corrigé**

*Relier deux bâtiments distants de 800 mètres, dans un établissement traversé
par une ligne électrique de forte puissance. Quel câble choisir, et pourquoi ?*

**Correction.** La **fibre optique**.

*Deux raisons, et chacune suffirait.*

**La distance.** 800 mètres dépassent très largement la limite de la paire
torsadée, qui est d''environ 100 mètres. Il faudrait sinon poser plusieurs
répéteurs.

**Les perturbations.** Une ligne de forte puissance crée un champ
électromagnétique qui brouillerait un câble de cuivre. La fibre, qui transporte
de la **lumière** et non de l''électricité, y est **totalement insensible**.

*La contrepartie* : le coût du câble et d''une pose spécialisée. Mais sur une
liaison entre bâtiments, elle se pose une fois pour vingt ans.
', NULL, 26),
      (v_chapitre_id, 'Simulation : choisir son câble', 4, 'interactif', '{
  "widget": "cables-reseau",
  "consigne": "Fais varier la distance à couvrir et le niveau de perturbation du lieu, et vois les trois câbles réagir : le signal de la paire torsadée s''affaiblit au-delà de cent mètres, le coaxial tient plus loin, la fibre ne bouge pas. Une coupe de chaque câble s''ouvre en détail — âme, isolant, tresse, gaine — et le prix total de la liaison s''affiche à mesure que tu allonges la distance."
}', NULL, 10),
      (v_chapitre_id, 'Les équipements d''interconnexion', 5, 'texte', '
Le programme demande explicitement le **rôle** du modem, du hub, du switch et du
routeur. Les voici, avec ceux qui les accompagnent.

### La carte réseau

C''est l''équipement qui **permet à l''ordinateur de se connecter au réseau**. Elle
reçoit et émet les données, et porte une adresse physique unique, l''**adresse
MAC**, gravée à la fabrication.

Sans carte réseau, une machine ne peut pas être mise en réseau — ce qui en fait
la première chose à vérifier.

### Le modem

**Modem** est la contraction de **mo**dulateur-**dém**odulateur.

Son rôle : **convertir les signaux numériques de l''ordinateur en signaux
analogiques** transmissibles sur la ligne, et **inversement**. C''est lui qui
raccorde l''ordinateur au réseau téléphonique, donc à Internet.

Un téléphone Android dont on active le point d''accès joue ce rôle.

### Le concentrateur, ou hub

Il se place **au centre d''un réseau en étoile**. Il **redistribue chaque message
à tous les ordinateurs** connectés, et seul le destinataire l''ouvre.

Conséquence : il **sature vite** — chaque message occupe tout le réseau — et il
est **peu sûr**, puisque tout le monde reçoit tout. On ne l''installe plus.

### Le commutateur, ou switch

Semblable au hub en apparence, mais il **envoie le message directement au
destinataire**, sans en informer les autres.

Il apprend pour cela quelle machine est branchée sur quel port, grâce aux
adresses MAC.

Deux conséquences : **beaucoup plus rapide**, puisque plusieurs conversations
peuvent avoir lieu en même temps, et **plus sûr**. C''est l''équipement central du
réseau local d''aujourd''hui.

### Le routeur

Il **oriente les données dans le réseau** et les **fait circuler entre deux
interfaces réseau** — autrement dit, entre **deux réseaux différents**.

C''est lui qui relie le réseau local du lycée à Internet, et c''est lui qui décide
par quel chemin un paquet doit partir.

La frontière à retenir : le **switch relie des machines à l''intérieur d''un
réseau**, le **routeur relie des réseaux entre eux**.

### Les trois autres

Le **répéteur** combine un récepteur et un émetteur pour **compenser les pertes
de transmission** : il amplifie ou retraite le signal **sans en changer le
contenu**. Il sert à dépasser la limite de longueur d''un câble.

Le **pont** relie des réseaux utilisant le **même protocole**. Il **garde les
trames destinées au réseau local** et transmet les autres, ce qui **réduit les
collisions**.

La **passerelle** relie des réseaux **de types différents**, en **convertissant
les protocoles**.

---

**Exercice corrigé**

*Sur le schéma d''un réseau, l''équipement E1 relie entre eux les cinq postes d''une
salle, et l''équipement E2 relie ce réseau à Internet. Nommer E1 et E2 et donner
leur rôle.*

**Correction.**

**E1 est un commutateur**, en anglais *switch*. Son rôle : **interconnecter les
machines d''un réseau local** en envoyant chaque message directement à son
destinataire, sans le diffuser aux autres.

*On pourrait penser au hub, qui occupe la même place sur le schéma. Mais le hub
est un équipement ancien, bien moins adapté, et le commutateur est la réponse
attendue.*

**E2 est un modem.** Son rôle : **convertir les signaux numériques en signaux
analogiques et inversement**, afin de raccorder le réseau local à Internet par
la ligne de l''opérateur.

*Cette question est tombée au Baccalauréat 2023, pour un point — un demi-point
par équipement, le nom et le rôle étant exigés tous les deux.*
', NULL, 28),
      (v_chapitre_id, 'Simulation : le bon équipement à la bonne place', 6, 'interactif', '{
  "widget": "equipements-reseau",
  "consigne": "Un réseau incomplet s''affiche avec des emplacements vides, et une caisse d''équipements : carte réseau, modem, hub, switch, routeur, répéteur. Place-les et envoie un message d''un poste à l''autre, puis d''un poste vers Internet. La simulation te montre le hub inonder tout le réseau quand le switch n''envoie qu''au destinataire, et refuse de sortir du réseau local tant qu''il manque un routeur."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 9', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Pourquoi les fils d''une paire torsadée sont-ils torsadés ?",
      "choix": [
        "Pour gagner de la place",
        "Parce que la torsade annule les perturbations électromagnétiques",
        "Pour augmenter le débit",
        "Pour renforcer le câble"
      ],
      "bonne": 1,
      "explication": "Ce qui gêne un fil gêne aussi son jumeau, et les deux perturbations s''annulent. C''est toute l''astuce."
    },
    {
      "question": "Quelle est la portée pratique d''une paire torsadée ?",
      "choix": [
        "10 mètres",
        "environ 100 mètres",
        "1 kilomètre",
        "10 kilomètres"
      ],
      "bonne": 1,
      "explication": "Au-delà, le signal s''affaiblit trop : il faut un répéteur, ou passer à la fibre optique."
    },
    {
      "question": "Quel câble est totalement insensible aux perturbations électromagnétiques ?",
      "choix": [
        "La paire torsadée blindée",
        "Le câble coaxial",
        "La fibre optique",
        "Aucun"
      ],
      "bonne": 2,
      "explication": "Parce qu''elle transporte de la lumière et non de l''électricité. C''est l''argument décisif près d''une ligne de forte puissance."
    },
    {
      "question": "Quel est le rôle d''un modem ?",
      "choix": [
        "Relier les machines d''un réseau local",
        "Convertir les signaux numériques en signaux analogiques et inversement",
        "Orienter les paquets entre deux réseaux",
        "Amplifier le signal d''un câble trop long"
      ],
      "bonne": 1,
      "explication": "Modem est la contraction de modulateur-démodulateur. C''est lui qui raccorde l''ordinateur à la ligne de l''opérateur."
    },
    {
      "question": "Quelle est la différence entre un hub et un switch ?",
      "choix": [
        "Aucune",
        "Le hub redistribue le message à tous, le switch l''envoie directement au destinataire",
        "Le hub est plus rapide",
        "Le switch relie deux réseaux différents"
      ],
      "bonne": 1,
      "explication": "Le switch est donc plus rapide et plus sûr. C''est pourquoi on n''installe plus de hub aujourd''hui."
    },
    {
      "question": "Quel équipement relie deux réseaux différents entre eux ?",
      "choix": [
        "Le switch",
        "Le hub",
        "Le routeur",
        "Le répéteur"
      ],
      "bonne": 2,
      "explication": "La frontière à retenir : le switch relie des machines à l''intérieur d''un réseau, le routeur relie des réseaux entre eux."
    },
    {
      "question": "À quoi sert un répéteur ?",
      "choix": [
        "À convertir les protocoles",
        "À compenser les pertes de transmission en amplifiant le signal, sans en changer le contenu",
        "À filtrer les trames",
        "À distribuer les adresses IP"
      ],
      "bonne": 1,
      "explication": "Il sert à dépasser la limite de longueur d''un câble. La passerelle, elle, convertit les protocoles entre réseaux de types différents."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 9, Les équipements d''interconnexion réseau.', v_nom;
  END LOOP;
END $inf7$;
