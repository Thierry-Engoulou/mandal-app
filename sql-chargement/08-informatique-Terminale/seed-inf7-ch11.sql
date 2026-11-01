-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 11 : Réalisation d'un petit réseau local
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
    WHERE programme_id = v_programme_id AND ordre = 11;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Réalisation d''un petit réseau local', 11, 'Module 1 : Systèmes informatiques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 11 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 11 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'La carte réseau et ses paramètres', 1, 'texte', '
Dernière unité du module : on passe de la théorie au câble. Le programme demande
de **modifier les paramètres IP d''une carte réseau**, de **donner son rôle**, de
**créer un réseau de trois PC** et d''**utiliser PING et IPCONFIG**.

### Le rôle de la carte réseau

La **carte réseau** est l''équipement qui **permet à l''ordinateur de se connecter
au réseau** : elle **émet et reçoit les données** sur le support de
transmission.

Elle porte une **adresse MAC**, physique et unique, gravée à la fabrication sur
six octets — `00-1A-2B-3C-4D-5E`. Deux cartes n''ont jamais la même.

Ne confonds pas les deux adresses : l''**adresse MAC** est **physique**, fixée à
l''usine et jamais modifiée ; l''**adresse IP** est **logique**, attribuée par
l''administrateur ou par DHCP, et elle change si la machine change de réseau.

### Les quatre paramètres à régler

Sous Windows : **Panneau de configuration**, **Centre Réseau et partage**,
**Modifier les paramètres de la carte**, clic droit sur la connexion,
**Propriétés**, puis **Protocole Internet version 4 (TCP/IPv4)**, **Propriétés**.

Deux choix s''offrent alors.

**Obtenir une adresse IP automatiquement** : c''est l''adressage **dynamique**,
par DHCP.

**Utiliser l''adresse IP suivante** : c''est l''adressage **statique**, et il faut
alors renseigner quatre champs.

| Champ | Ce qu''on met | Exemple |
| --- | --- | --- |
| **Adresse IP** | l''adresse de cette machine | `192.168.1.10` |
| **Masque de sous-réseau** | il sépare réseau et hôte | `255.255.255.0` |
| **Passerelle par défaut** | l''adresse du routeur, pour sortir du réseau | `192.168.1.1` |
| **Serveur DNS** | qui traduit les noms en adresses | `8.8.8.8` |

### Les trois erreurs qui empêchent tout

**Deux machines avec la même adresse IP.** Windows affiche « Conflit d''adresse
IP », et les deux perdent la connexion.

**Un masque différent d''une machine à l''autre.** Elles ne se voient plus, alors
que leurs adresses se ressemblent.

**Pas de passerelle.** Le réseau local fonctionne, mais rien ne sort vers
Internet. C''est la panne la plus déroutante : « on se voit entre nous, mais pas
Google ».

---

**Exercice corrigé**

*Une machine a pour adresse `192.168.1.10` et pour masque `255.255.255.0`. Elle
communique avec les autres postes de la salle mais n''accède pas à Internet. Quel
paramètre est en cause ?*

**Correction.** La **passerelle par défaut**, qui est absente ou fausse.

*Le raisonnement.* La machine **communique avec les autres postes** : son
adresse et son masque sont donc corrects, et sa carte réseau fonctionne.

Ce qui manque est donc ce qui sert à **sortir du réseau local**, c''est-à-dire
l''adresse du **routeur** — la passerelle par défaut.

*La vérification.* Lancer `ipconfig` et regarder la ligne « Passerelle par
défaut » : elle est vide, ou elle porte une adresse qui n''est pas celle du
routeur.

*La correction.* Renseigner l''adresse du routeur, souvent `192.168.1.1`, dans
les propriétés du protocole TCP/IPv4. Si le DNS est également absent, les
adresses numériques répondront mais pas les noms de sites.
', NULL, 26),
      (v_chapitre_id, 'Simulation : configurer une carte réseau', 2, 'interactif', '{
  "widget": "carte-reseau",
  "consigne": "La fenêtre des propriétés TCP/IPv4 s''ouvre comme sous Windows, avec ses quatre champs. Remplis-les et la simulation teste aussitôt trois choses : le poste voit-il ses voisins, sort-il vers Internet, atteint-il un site par son nom ? Introduis volontairement les trois erreurs classiques — adresse en double, masque différent, passerelle absente — et vois laquelle casse quoi."
}', NULL, 10),
      (v_chapitre_id, 'Monter un petit réseau de trois PC', 3, 'texte', '
Le programme demande de **créer et configurer un réseau informatique de trois
PC**. Voici la marche à suivre, dans l''ordre.

### Le matériel

Trois ordinateurs équipés d''une **carte réseau**, un **commutateur**, et trois
**câbles à paires torsadées** munis de connecteurs **RJ45**.

*Cas particulier, et c''est une question classique* : pour relier **deux** PC
**sans commutateur**, il faut un **câble croisé**. Dès qu''on passe par un
commutateur, les câbles sont **droits**.

### Les six étapes

**1. Câbler.** Chaque PC au commutateur par un câble droit. Les voyants des
ports s''allument : s''ils restent éteints, le câble ou la carte est en cause, et
il est inutile d''aller plus loin.

**2. Choisir un plan d''adressage.** On prend une plage privée, par exemple
`192.168.1.0` avec le masque `255.255.255.0`.

| Poste | Adresse IP | Masque |
| --- | --- | --- |
| PC1 | `192.168.1.1` | `255.255.255.0` |
| PC2 | `192.168.1.2` | `255.255.255.0` |
| PC3 | `192.168.1.3` | `255.255.255.0` |

Les trois ont la **même partie réseau** — `192.168.1` — et une **partie hôte
différente**. C''est la condition pour qu''ils se voient.

**3. Configurer chaque carte**, comme à la leçon précédente.

**4. Donner le même groupe de travail** aux trois machines, et un **nom
différent** à chacune.

**5. Vérifier avec `ipconfig`**, poste par poste, que l''adresse et le masque
sont bien ceux prévus.

**6. Tester avec `ping`**, de chaque poste vers les deux autres.

### Partager un dossier

Clic droit sur le dossier, **Propriétés**, onglet **Partage**, **Partager**,
choisir les utilisateurs et leurs droits — lecture seule, ou lecture et
écriture.

On y accède depuis un autre poste en tapant `\\192.168.1.1\documents` dans
l''explorateur.

---

**Exercice corrigé**

*Vous devez relier trois PC d''une salle. Donner le matériel nécessaire, le plan
d''adressage, et la façon de vérifier que le réseau fonctionne.*

**Correction.**

*Le matériel.* Trois cartes réseau — en général déjà intégrées —, un
**commutateur** d''au moins trois ports, et trois **câbles à paires torsadées
droits** à connecteurs RJ45.

*Le plan d''adressage.* Une plage privée de classe C :

`192.168.1.1`, `192.168.1.2` et `192.168.1.3`, toutes avec le masque
`255.255.255.0`.

La partie réseau `192.168.1` est **commune** aux trois, et la partie hôte
**différente** pour chacune. Aucune passerelle n''est nécessaire si le réseau
n''accède pas à Internet.

*La vérification, en deux temps.*

Sur chaque poste, `ipconfig` pour contrôler que l''adresse et le masque sont les
bons.

Puis, depuis PC1, `ping 192.168.1.2` et `ping 192.168.1.3`. Une réponse de
chacun signifie que le réseau fonctionne.
', NULL, 26),
      (v_chapitre_id, 'Simulation : monter un réseau de trois postes', 4, 'interactif', '{
  "widget": "monter-reseau",
  "consigne": "Trois PC et un commutateur t''attendent, débranchés et sans configuration. Câble, puis attribue les adresses, puis teste. La simulation refuse les plans d''adressage impossibles et te dit pourquoi : deux adresses identiques, une partie réseau différente, un masque qui ne correspond pas. Essaie aussi de relier deux PC sans commutateur — il te faudra le bon câble."
}', NULL, 10),
      (v_chapitre_id, 'Les commandes PING et IPCONFIG', 5, 'texte', '
Deux commandes, et c''est avec elles qu''on diagnostique un réseau. Le programme
les nomme toutes les deux.

### IPCONFIG

Elle **affiche la configuration IP** de la machine. On l''ouvre dans l''invite de
commandes : touche Windows + R, taper `cmd`, Entrée.

```
ipconfig
```

Elle affiche l''**adresse IPv4**, le **masque de sous-réseau** et la
**passerelle par défaut**.

```
ipconfig /all
```

La forme complète, et celle qu''on demande en examen. Elle ajoute l''**adresse
physique MAC**, les **serveurs DNS**, et surtout la ligne **« Bail DHCP
activé »** — qui dit si l''adressage est **dynamique** ou **statique**.

Deux autres formes utiles : `ipconfig /release` libère l''adresse obtenue par
DHCP, et `ipconfig /renew` en demande une nouvelle. C''est le premier geste quand
une machine n''obtient plus d''adresse.

### PING

Elle **teste la connexion** avec une autre machine.

```
ping 192.168.1.2
```

Elle envoie quatre petits paquets et attend leur retour, grâce au protocole
**ICMP**.

**Si la machine répond**, on lit quatre lignes « Réponse de… » avec le temps en
millisecondes : la liaison fonctionne.

**Si elle ne répond pas**, on lit « Délai d''attente de la demande dépassé » ou
« Hôte de destination injoignable » : la machine est éteinte, mal adressée, ou
protégée par un pare-feu qui bloque le ping.

### L''ordre de diagnostic

Il se retient et il sert pour la vie :

```
ping 127.0.0.1          ma carte réseau fonctionne-t-elle ?
ping 192.168.1.10       ma propre adresse est-elle bien posée ?
ping 192.168.1.2        mon voisin répond-il ?
ping 192.168.1.1        ma passerelle répond-elle ?
ping 8.8.8.8            Internet répond-il par l''adresse ?
ping www.google.com     et par le nom ?
```

On part de soi et on s''éloigne. **La première ligne qui échoue désigne la
panne** : si tout passe sauf la dernière, le réseau fonctionne et c''est le
**DNS** qui est en cause.

---

**Exercice corrigé**

*Sur une copie d''écran, on voit le résultat d''une commande affichant l''adresse
IPv4 192.168.0.23, le masque 255.255.255.0 et la mention « Bail DHCP activé :
Oui ».*
*1. Quelle est la commande utilisée ? 2. Quel est le mode d''adressage ? 3. À
quelle classe appartient cette adresse ? 4. Quelle commande permet de tester la
connexion avec une autre machine ?*

**Correction.**

**1.** La commande est **`ipconfig /all`**. La forme simple `ipconfig`
n''afficherait pas la ligne relative au bail DHCP.

**2.** L''adressage est **dynamique**, puisque le bail DHCP est activé :
l''adresse a été attribuée automatiquement par un serveur DHCP, et non saisie à
la main.

**3.** Le premier octet vaut **192**, compris entre 192 et 223 : l''adresse est
de **classe C**.

**4.** La commande **`ping`**, suivie de l''adresse de la machine à joindre —
par exemple `ping 192.168.0.24`.

*Ces quatre questions viennent de la partie réseau du Baccalauréat 2023.*
', NULL, 26),
      (v_chapitre_id, 'Simulation : diagnostiquer avec ping et ipconfig', 6, 'interactif', '{
  "widget": "commandes-reseau",
  "consigne": "Une vraie invite de commandes s''ouvre, et tu y tapes ipconfig, ipconfig /all et ping. Six machines en panne te sont proposées, chacune avec un défaut différent — carte désactivée, adresse en double, passerelle absente, DNS muet — et tu remontes la chaîne de diagnostic, du 127.0.0.1 jusqu''au nom de domaine. La première ligne qui échoue désigne la panne, et la simulation te le confirme."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Baccalauréat — Partie I, systèmes informatiques (2023)', 7, 'texte', '
Voici la première partie de l''épreuve théorique d''informatique du Baccalauréat
C, D et E, session 2023, entièrement corrigée. Elle vaut **7 points** sur 20, et
porte exclusivement sur ce module.

---

**Énoncé**

**A. Questions de connaissances**

*1. Définir l''expression « système informatique ». (1 pt)*

*2. Un vidéoprojecteur neuf, branché sur un ordinateur, n''est pas reconnu par le
système d''exploitation. Identifier le problème et proposer une solution.
(0,5 × 2 = 1 pt)*

**B. Réseau informatique**

*Le schéma d''un réseau local montre cinq ordinateurs reliés à un équipement E1,
lui-même relié à un équipement E2 qui donne accès à Internet.*

*1. Nommer les équipements E1 et E2, et donner leur rôle. (0,5 × 2 = 1 pt)*

*2. Une copie d''écran indique « Bail DHCP activé : Oui ». Déterminer le mode
d''adressage utilisé. (0,5 pt)*

*3. Cette copie d''écran affiche l''adresse IPv4 192.168.0.23 et le masque
255.255.255.0. (0,25 × 3 = 0,75 pt)*
*a) Quelle commande a produit cet affichage ?*
*b) Quelle est l''adresse IP de la machine ?*
*c) À quelle classe appartient-elle ?*

*4. a) La machine peut-elle communiquer avec l''adresse 192.168.1.2 ? Justifier.
(0,5 pt)*
*b) Quelle commande permet de tester la connexion avec une autre machine ?
(0,5 pt)*

**C. Tableur**

*Une feuille de calcul contient les notes d''une classe. Les notes de devoir sont
en colonne B et celles de composition en colonne C, de la ligne 3 à la ligne 7.
La colonne D doit recevoir la moyenne de chaque élève. Les coefficients sont en
colonne C.*

*1. De quel type de logiciel s''agit-il ? (0,25 pt)*
*2. La copie d''écran montre un cadre épais autour d''une case. Comment
l''appelle-t-on ? (0,25 pt)*
*3. Quelle formule place-t-on en D3 pour obtenir la note trimestrielle ?
(0,25 pt)*
*4. Quelle technique permet d''obtenir les autres moyennes sans les saisir une à
une ? (0,5 pt)*
*5. Quelles formules place-t-on en E9 pour le total des coefficients, et en D10
pour le nombre de notes supérieures ou égales à 10 ? (0,25 × 2 = 0,5 pt)*

---

**Correction détaillée**

**A.1.** Un **système informatique** est un **ensemble de moyens informatiques
et de télécommunications** permettant de **collecter, traiter, stocker et
acheminer des données**.

*Les quatre verbes sont attendus. Une définition qui n''en cite que deux ne vaut
pas le point entier.*

**A.2.** *Le problème* : le **pilote** du vidéoprojecteur est **absent** ou
inadapté. On accepte aussi un **mauvais branchement** ou un **câble
défectueux**.

*La solution* : **installer ou mettre à jour le pilote**, depuis le support
fourni ou le site du constructeur ; et au préalable, vérifier les branchements
et, au besoin, changer le câble.

**B.1.** **E1 est un commutateur**, ou *switch*. Son rôle est d''**interconnecter
les machines du réseau local**, en envoyant chaque message directement à son
destinataire.

**E2 est un modem.** Son rôle est de **convertir les signaux numériques en
signaux analogiques et inversement**, pour raccorder le réseau local à Internet.

**B.2.** L''adressage est **dynamique**. La mention « Bail DHCP activé : Oui »
indique que l''adresse a été attribuée automatiquement par un **serveur DHCP**.

**B.3.** a) La commande est **`ipconfig /all`**.
b) L''adresse IP est **192.168.0.23**.
c) Le premier octet vaut 192, compris entre 192 et 223 : **classe C**.

**B.4.** a) **Non.** Avec le masque `255.255.255.0`, la partie réseau est formée
des **trois premiers octets**. Celle de la machine est `192.168.0`, celle de
l''autre est `192.168.1` : **les deux réseaux sont différents**, donc la
communication directe est impossible. Il faudrait un **routeur** entre les deux,
ou changer l''une des adresses.

b) La commande **`ping`**, suivie de l''adresse de la machine à joindre.

**C.1.** Il s''agit d''un **tableur**. *On accepte le nom d''un logiciel — Microsoft
Excel, LibreOffice Calc — mais la question porte sur le type.*

**C.2.** C''est la **cellule active** : celle où s''inscrira ce que l''on tape.

**C.3.** `=MOYENNE(B3:C3)`

*La forme `=(B3+C3)/2` est également juste. Dans les deux cas, le signe **égal**
en tête est indispensable : sans lui, le tableur affiche du texte.*

**C.4.** La **recopie incrémentée** de formule. On saisit la **poignée de
recopie**, le petit carré en bas à droite de la cellule, et on tire vers le bas.
Les **références relatives** s''adaptent automatiquement à chaque ligne.

**C.5.** En **E9** : `=SOMME(C3:C7)`

En **D10** : `=NB.SI(D3:D7;">=10")`

*Deux points de vigilance.* Le critère **doit être entre guillemets**, puisqu''il
contient un opérateur. Et c''est bien **NB.SI** qu''on emploie, puisqu''on
**compte** les notes ; `SOMME.SI` les additionnerait.

---

**Ce que ce sujet t''apprend sur l''épreuve**

Regarde la nature des questions : sur les sept points, **aucun** ne demande un
raisonnement long. On vérifie que tu **connais le vocabulaire**, que tu sais
**lire une copie d''écran**, et que tu sais **écrire trois formules de tableur**.

Les points de cette partie se gagnent donc en apprenant les **définitions**, les
**sigles**, les **unités** et la **syntaxe des sept fonctions** — exactement ce
que contiennent les chapitres 1 à 11.

Et note la répartition : trois points de systèmes et pannes, deux points et demi
de réseau, un point et demi de tableur. Le réseau et le tableur font ensemble
plus de la moitié de la partie. Ce sont eux qu''il faut travailler en premier.
', NULL, 32),
      (v_chapitre_id, 'Quiz du chapitre 11', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quel est le rôle de la carte réseau ?",
      "choix": [
        "Convertir les signaux analogiques",
        "Permettre à l''ordinateur de se connecter au réseau en émettant et recevant les données",
        "Attribuer les adresses IP",
        "Relier deux réseaux différents"
      ],
      "bonne": 1,
      "explication": "Elle porte en plus une adresse MAC physique et unique, gravée à la fabrication sur six octets."
    },
    {
      "question": "Quelle est la différence entre adresse MAC et adresse IP ?",
      "choix": [
        "Aucune",
        "La MAC est physique et fixée à l''usine ; l''IP est logique et attribuée par l''administrateur ou par DHCP",
        "La MAC change à chaque démarrage",
        "L''IP est gravée dans la carte"
      ],
      "bonne": 1,
      "explication": "L''adresse IP change si la machine change de réseau ; l''adresse MAC ne change jamais."
    },
    {
      "question": "Une machine voit ses voisins mais n''accède pas à Internet. Quel paramètre est en cause ?",
      "choix": [
        "L''adresse IP",
        "Le masque de sous-réseau",
        "La passerelle par défaut",
        "L''adresse MAC"
      ],
      "bonne": 2,
      "explication": "Si elle voit ses voisins, l''adresse et le masque sont bons. Ce qui manque est ce qui sert à SORTIR du réseau local : l''adresse du routeur."
    },
    {
      "question": "Pour relier deux PC sans commutateur, quel câble faut-il ?",
      "choix": [
        "Un câble droit",
        "Un câble croisé",
        "Un câble coaxial",
        "Une fibre optique"
      ],
      "bonne": 1,
      "explication": "Dès qu''on passe par un commutateur, les câbles sont droits. Sans lui, il faut croiser les paires."
    },
    {
      "question": "Quelle commande affiche l''adresse IP, le masque et le bail DHCP d''une machine ?",
      "choix": [
        "ping",
        "ipconfig /all",
        "tracert",
        "netstat"
      ],
      "bonne": 1,
      "explication": "La forme simple ipconfig n''affiche pas la ligne du bail DHCP ni l''adresse physique : il faut la forme complète."
    },
    {
      "question": "Sur quel protocole repose la commande ping ?",
      "choix": [
        "HTTP",
        "ICMP",
        "SMTP",
        "DHCP"
      ],
      "bonne": 1,
      "explication": "ICMP contrôle les erreurs au niveau IP et permet de signaler les problèmes de transmission. Ping lui envoie quatre paquets et attend leur retour."
    },
    {
      "question": "Dans la chaîne de diagnostic, que signifie « tout passe sauf ping www.google.com » ?",
      "choix": [
        "La carte réseau est en panne",
        "La passerelle est absente",
        "Le réseau fonctionne, et c''est le DNS qui est en cause",
        "Le câble est coupé"
      ],
      "bonne": 2,
      "explication": "Si l''adresse numérique répond et pas le nom, c''est que la traduction des noms en adresses échoue. On part de soi et on s''éloigne : la première ligne qui échoue désigne la panne."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 11, Réalisation d''un petit réseau local.', v_nom;
  END LOOP;
END $inf7$;
