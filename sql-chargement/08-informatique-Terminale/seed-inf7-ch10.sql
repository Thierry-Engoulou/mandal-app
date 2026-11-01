-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 10 : Les protocoles réseaux et l'adressage IP
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
    WHERE programme_id = v_programme_id AND ordre = 10;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les protocoles réseaux et l''adressage IP', 10, 'Module 1 : Systèmes informatiques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 10 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 10 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les protocoles d''Internet', 1, 'texte', '
Un réseau sans protocole, ce sont des machines reliées qui ne se comprennent
pas. Le programme demande le **rôle de chacun** des protocoles suivants :
HTTP, IP, FTP, SMTP, POP3 et DHCP.

### Ce qu''est un protocole

Un **protocole** est un **ensemble de règles** qui définissent **comment deux
machines échangent des informations** : le format des messages, l''ordre dans
lequel ils sont envoyés, et ce qu''il faut faire en cas d''erreur.

C''est la langue commune. Sans elle, le câble transporte des signaux que personne
ne sait lire.

### La pile TCP/IP et ses trois couches

Les protocoles sont rangés en couches, chacune rendant service à celle du
dessus.

**La couche Application** — ce que l''utilisateur voit.

**HTTP** — *HyperText Transfer Protocol*. Il sert à **transférer les fichiers
qui composent les pages web**. Sa variante sécurisée est **HTTPS**, qui chiffre
l''échange.

**FTP** — *File Transfer Protocol*. Il permet le **transfert interactif de
fichiers** entre ordinateurs.

**SMTP** — *Simple Mail Transfer Protocol*. Il sert à **transmettre les
courriels et leurs pièces jointes**. Retiens-le comme le protocole de
l''**envoi**.

**POP3** — *Post Office Protocol version 3*. Il sert à **relever les courriels**
sur le serveur de messagerie, c''est-à-dire à les **recevoir**. Dans sa forme
classique, il **télécharge** les messages et les **efface du serveur**.

**DHCP** — *Dynamic Host Configuration Protocol*. Il **attribue automatiquement
une adresse IP** à chaque machine qui se connecte, avec son masque et sa
passerelle. C''est lui qui t''évite de configurer chaque poste à la main.

**La couche Transport** — comment les messages voyagent.

**TCP** — *Transmission Control Protocol*. Il envoie les messages **en séquence
et dans le bon ordre**, et **vérifie leur arrivée**. On dit qu''il travaille en
**mode connecté**. C''est le protocole du web et du courriel : on ne veut pas
d''une page à moitié arrivée.

**UDP** — *User Datagram Protocol*. Il envoie les messages **sans vérifier leur
arrivée** et **ne garantit ni leur ordre ni leur livraison** : c''est le **mode
non connecté**. On l''emploie là où la vitesse compte plus que la perfection,
comme la voix ou la vidéo en direct.

**La couche Inter-réseau** — où vont les paquets.

**IP** — *Internet Protocol*. Il **achemine les paquets** entre l''émetteur et le
destinataire **grâce à leurs adresses**. IPv4 utilise **32 bits**, IPv6 en
utilise **128**.

**ICMP** — il **contrôle les erreurs** au niveau IP et permet aux routeurs de
signaler les problèmes de transmission. C''est lui qui fait fonctionner la
commande `ping`.

**ARP** — *Address Resolution Protocol*. Il établit la **correspondance entre une
adresse IP et une adresse physique MAC** sur un même réseau local.

### Le tableau de révision

| Protocole | Son rôle, en une ligne |
| --- | --- |
| **HTTP** | transférer les fichiers des pages web |
| **FTP** | transférer des fichiers entre ordinateurs |
| **SMTP** | **envoyer** les courriels |
| **POP3** | **recevoir** les courriels |
| **DHCP** | attribuer automatiquement les adresses IP |
| **IP** | acheminer les paquets grâce aux adresses |
| **TCP** | livrer en ordre et vérifier l''arrivée |

---

**Exercice corrigé**

*Donner le rôle de SMTP, de POP3 et de DHCP.*

**Correction.**

**SMTP** — *Simple Mail Transfer Protocol* — sert à **transmettre les courriels
et leurs pièces jointes** du client vers le serveur, et entre serveurs. C''est le
protocole de l''**envoi**.

**POP3** — *Post Office Protocol version 3* — sert à **relever les courriels**
déposés sur le serveur de messagerie, c''est-à-dire à les **recevoir**. Dans sa
forme classique, il télécharge les messages et les supprime du serveur.

**DHCP** — *Dynamic Host Configuration Protocol* — **attribue automatiquement
une adresse IP** à chaque machine qui se connecte au réseau, ainsi que son
masque de sous-réseau et sa passerelle par défaut.

*Le moyen mnémotechnique qui sauve en examen : **S** comme Send pour SMTP,
**P** comme Pick up pour POP3.*
', NULL, 28),
      (v_chapitre_id, 'Simulation : à chaque protocole son travail', 2, 'interactif', '{
  "widget": "protocoles-internet",
  "consigne": "Sept actions ordinaires te sont présentées : ouvrir une page web, envoyer un courriel, le relever, téléverser un fichier, brancher un portable neuf sur le réseau. Tu désignes le protocole à l''œuvre, et la simulation fait circuler le message à l''écran, couche par couche, du clavier jusqu''au câble. Un panneau montre les trois couches de la pile TCP/IP se remplir au passage."
}', NULL, 10),
      (v_chapitre_id, 'L''adressage IP', 3, 'texte', '
Pour qu''un paquet arrive, il faut une adresse. C''est le rôle de l''adressage, une
fonction de la **couche réseau** de la pile TCP/IP.

### Ce qu''il faut pour adresser une machine

Trois choses, et le programme les demande :

son **adresse IP** ;
son **masque de sous-réseau** ;
son **mode d''adressage** : **statique** ou **dynamique**.

### Statique ou dynamique

En **adressage statique**, l''adresse est **saisie à la main** sur chaque
machine, et ne change pas. On le réserve aux serveurs et aux imprimantes, qu''on
doit pouvoir joindre toujours à la même adresse.

En **adressage dynamique**, un serveur **DHCP distribue** les adresses
automatiquement. C''est le mode normal pour les postes de travail : on branche,
ça marche.

Comment on reconnaît le mode dynamique sur une copie d''écran : la configuration
indique « Obtenir une adresse IP automatiquement », ou la commande `ipconfig`
affiche « Bail DHCP activé : Oui ».

### IPv4 et IPv6

**IPv4** code l''adresse sur **32 bits**, écrits en **quatre nombres de 0 à 255
séparés par des points** : `192.168.1.1`.

Quatre octets donnent $2^{32}$, soit environ **4,3 milliards** d''adresses. C''est
beaucoup, et c''est devenu trop peu.

**IPv6** code l''adresse sur **128 bits**, écrits en hexadécimal.

**Le principal avantage d''IPv6 sur IPv4** — c''est la question du programme — est
le **nombre d''adresses disponibles**, pratiquement illimité. Le cours ajoute
deux autres avantages : de **meilleures performances de routage** et une
**configuration automatique du réseau plus simple**.

### Adresses publiques et adresses privées

Les **adresses publiques** sont utilisées par les équipements **directement
connectés à Internet**. Elles sont distribuées par l''**ICANN**, et le **DNS**
fait correspondre les adresses IP aux noms de domaine — c''est lui qui traduit
`www.minesec.gov.cm` en une adresse numérique.

Les **adresses privées** servent **à l''intérieur** d''un réseau local, et ne
circulent jamais sur Internet. Trois plages leur sont réservées en IPv4 :

| Plage | Nombre d''adresses |
| --- | --- |
| `10.0.0.0/8` | 16 777 216 |
| `172.16.0.0/12` | 1 048 576 |
| `192.168.0.0/16` | 65 536 |

C''est la dernière que tu rencontres partout : la box de la maison distribue des
adresses en `192.168.x.x`.

### Les deux parties d''une adresse

Toute adresse IPv4 se lit en deux morceaux :

la **partie réseau**, **identique** pour toutes les machines du même réseau ;
la **partie hôte**, **différente** pour chacune.

C''est le **masque de sous-réseau** qui dit où passe la frontière : les octets à
**255** recouvrent la partie réseau, ceux à **0** la partie hôte.

Pour `192.168.1.1` avec le masque `255.255.255.0` :

la partie réseau est `192.168.1`, la partie hôte est `1` ;
l''**adresse du réseau** est `192.168.1.0` — partie hôte à zéro ;
l''**adresse de diffusion** est `192.168.1.255` — partie hôte au maximum.

Ces deux adresses ne s''attribuent **jamais** à une machine.

---

**Exercice corrigé**

*Deux machines portent les adresses `192.168.0.23` et `192.168.1.2`, toutes deux
avec le masque `255.255.255.0`. Peuvent-elles communiquer directement ?
Justifier.*

**Correction.** **Non.**

*La justification.* Le masque `255.255.255.0` indique que les **trois premiers
octets** forment la partie réseau.

Pour la première machine, la partie réseau est `192.168.0`.
Pour la seconde, elle est `192.168.1`.

Les deux parties réseau sont **différentes** : les machines ne sont donc pas sur
le même réseau, et elles ne peuvent pas communiquer directement.

*Pour qu''elles communiquent*, il faudrait soit **changer l''adresse** de l''une
pour la ramener dans le réseau de l''autre, soit placer un **routeur** entre les
deux réseaux.

*Cette question est tombée au Baccalauréat 2023, pour 0,5 point, et la
justification y comptait autant que la réponse.*
', NULL, 30),
      (v_chapitre_id, 'Figure : une adresse IPv4, son masque et sa classe', 4, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 220" width="560" height="220">
<rect width="560" height="220" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Une adresse IPv4 et son masque</text>

<text x="84" y="68" font-size="26" font-family="monospace" font-weight="700" fill="#2563eb">192.168.1</text>
<text x="286" y="68" font-size="26" font-family="monospace" font-weight="700" fill="#15803d">.1</text>

<line x1="84" y1="78" x2="282" y2="78" stroke="#2563eb" stroke-width="2"/>
<text x="183" y="96" text-anchor="middle" font-size="10" font-weight="700" fill="#2563eb">partie RÉSEAU</text>
<text x="183" y="110" text-anchor="middle" font-size="9" fill="#1e40af">la même pour toutes les machines</text>

<line x1="286" y1="78" x2="320" y2="78" stroke="#15803d" stroke-width="2"/>
<text x="303" y="96" text-anchor="middle" font-size="10" font-weight="700" fill="#15803d">HÔTE</text>
<text x="330" y="110" font-size="9" fill="#166534">différente pour chacune</text>

<text x="30" y="142" font-size="11" fill="#0f172a">Masque :</text>
<text x="100" y="142" font-size="13" font-family="monospace" font-weight="700" fill="#334155">255.255.255.0</text>
<text x="240" y="142" font-size="10" fill="#64748b">— les 255 recouvrent la partie réseau</text>

<text x="30" y="168" font-size="11" fill="#0f172a">Adresse du réseau :</text>
<text x="160" y="168" font-size="13" font-family="monospace" font-weight="700" fill="#2563eb">192.168.1.0</text>

<text x="30" y="192" font-size="11" fill="#0f172a">Adresse de diffusion :</text>
<text x="176" y="192" font-size="13" font-family="monospace" font-weight="700" fill="#b91c1c">192.168.1.255</text>

<rect x="368" y="150" width="172" height="52" rx="6" fill="#fef3c7" stroke="#ca8a04" stroke-width="1.4"/>
<text x="454" y="170" text-anchor="middle" font-size="10" font-weight="700" fill="#78350f">Premier octet 192 à 223</text>
<text x="454" y="188" text-anchor="middle" font-size="12" font-weight="700" fill="#78350f">donc CLASSE C</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : composer une adresse IP', 5, 'interactif', '{
  "widget": "adresse-ip",
  "consigne": "Compose une adresse octet par octet et choisis son masque : la simulation sépare en couleurs la partie réseau de la partie hôte, calcule l''adresse du réseau et celle de diffusion, et te dit combien de machines le réseau peut accueillir. Pose ensuite une seconde machine et demande-toi si elles peuvent se parler — la réponse s''affiche avec la justification, partie réseau contre partie réseau."
}', NULL, 10),
      (v_chapitre_id, 'Les classes d''adresses IPv4', 6, 'texte', '
Le programme demande d''**identifier une adresse IPv4 de classe A, B ou C**. La
règle tient dans une colonne.

### Le tableau des classes

| Classe | Premiers bits | Premier octet | Masque par défaut |
| --- | --- | --- | --- |
| **A** | 0 | **0 à 126** | `255.0.0.0` |
| **B** | 10 | **128 à 191** | `255.255.0.0` |
| **C** | 110 | **192 à 223** | `255.255.255.0` |
| D | 1110 | 224 à 239 | non définie |
| E | 1111 | 240 à 255 | non définie |

**Tout se joue sur le premier octet.** On le lit, on le situe dans la colonne, on
a la classe. Il n''y a rien d''autre à faire.

### Les deux classes à part

La **classe D** est réservée à la **diffusion multiple**, et la **classe E** à
la **recherche**. Elles n''ont pas de masque par défaut et ne s''attribuent pas à
des machines ordinaires. On les cite, on ne les utilise pas.

### Le trou de 127

Tu as remarqué que la classe A s''arrête à 126 et que la classe B commence à 128.
Le **127** manque : il est réservé au **bouclage local**. L''adresse `127.0.0.1`
désigne **la machine elle-même**, et sert à tester sa propre pile réseau.

### Ce que chaque classe permet

| Classe | Octets du réseau | Machines par réseau |
| --- | --- | --- |
| A | 1 | plus de 16 millions |
| B | 2 | 65 534 |
| C | 3 | **254** |

La classe C donne 254 machines, et non 256 : l''adresse du réseau et l''adresse de
diffusion ne s''attribuent pas.

C''est amplement suffisant pour une salle, un établissement, une entreprise
moyenne — et c''est pourquoi `192.168.x.x`, qui est de classe C, se retrouve
partout.

---

**Exercice corrigé**

*Soit l''adresse `192.168.1.1`.*
*1. À quelle classe appartient-elle ? 2. Quel est son masque par défaut ?
3. Quelle est la partie réseau, et la partie hôte ? 4. Donner l''adresse du
réseau et l''adresse de diffusion.*

**Correction.**

**1.** Le premier octet vaut **192**. Il se situe entre 192 et 223 : l''adresse
est donc de **classe C**.

**2.** Le masque par défaut d''une classe C est **`255.255.255.0`**.

**3.** Les trois premiers octets forment la partie réseau, le dernier la partie
hôte :

partie réseau : **`192.168.1`** ; partie hôte : **`1`**.

**4.** L''adresse du **réseau** s''obtient en mettant la partie hôte à zéro :
**`192.168.1.0`**.

L''adresse de **diffusion** s''obtient en mettant la partie hôte au maximum :
**`192.168.1.255`**.

*Ni l''une ni l''autre ne s''attribue à une machine : c''est pourquoi un réseau de
classe C accueille 254 machines et non 256.*
', NULL, 26),
      (v_chapitre_id, 'Simulation : reconnaître la classe d''une adresse', 7, 'interactif', '{
  "widget": "classes-adresses",
  "consigne": "Des adresses défilent et tu dois donner leur classe. La simulation surligne le premier octet — le seul qui compte — et place la valeur sur une règle graduée de 0 à 255, où les cinq classes sont colorées. Elle te fait ensuite déduire le masque par défaut, le nombre de machines possibles, l''adresse du réseau et celle de diffusion, et te signale l''adresse 127 qui ne désigne jamais qu''une machine : elle-même."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 10', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quel protocole sert à ENVOYER les courriels ?",
      "choix": [
        "POP3",
        "SMTP",
        "HTTP",
        "FTP"
      ],
      "bonne": 1,
      "explication": "S comme Send pour SMTP, P comme Pick up pour POP3. POP3, lui, sert à relever les messages sur le serveur."
    },
    {
      "question": "À quoi sert le protocole DHCP ?",
      "choix": [
        "À transférer des fichiers",
        "À attribuer automatiquement une adresse IP aux machines qui se connectent",
        "À chiffrer les pages web",
        "À convertir les noms de domaine en adresses"
      ],
      "bonne": 1,
      "explication": "Avec son masque et sa passerelle. C''est lui qui t''évite de configurer chaque poste à la main."
    },
    {
      "question": "Quelle est la différence entre TCP et UDP ?",
      "choix": [
        "Aucune",
        "TCP livre en ordre et vérifie l''arrivée ; UDP envoie sans vérifier ni garantir l''ordre",
        "UDP est plus sûr",
        "TCP ne fonctionne qu''en local"
      ],
      "bonne": 1,
      "explication": "TCP travaille en mode connecté, UDP en mode non connecté. On emploie UDP là où la vitesse compte plus que la perfection."
    },
    {
      "question": "Sur combien de bits est codée une adresse IPv4 ?",
      "choix": [
        "16 bits",
        "32 bits",
        "64 bits",
        "128 bits"
      ],
      "bonne": 1,
      "explication": "Quatre octets, écrits de 0 à 255 et séparés par des points. IPv6, lui, utilise 128 bits."
    },
    {
      "question": "Quel est le principal avantage d''IPv6 sur IPv4 ?",
      "choix": [
        "Il est plus rapide",
        "Le nombre d''adresses disponibles, pratiquement illimité",
        "Il ne nécessite pas de masque",
        "Il fonctionne sans routeur"
      ],
      "bonne": 1,
      "explication": "32 bits donnent 4,3 milliards d''adresses, ce qui est devenu trop peu. Le cours cite aussi de meilleures performances de routage."
    },
    {
      "question": "À quelle classe appartient l''adresse 192.168.1.1 ?",
      "choix": [
        "Classe A",
        "Classe B",
        "Classe C",
        "Classe D"
      ],
      "bonne": 2,
      "explication": "Tout se joue sur le premier octet : 192 se situe entre 192 et 223, donc classe C, de masque 255.255.255.0."
    },
    {
      "question": "Les machines 192.168.0.23 et 192.168.1.2, masque 255.255.255.0, peuvent-elles communiquer directement ?",
      "choix": [
        "Oui, elles commencent toutes deux par 192.168",
        "Non, leurs parties réseau diffèrent : 192.168.0 et 192.168.1",
        "Oui, si elles ont le même masque",
        "Seulement avec un switch"
      ],
      "bonne": 1,
      "explication": "Le masque dit que les trois premiers octets forment la partie réseau. Il faudrait changer une adresse, ou placer un routeur entre les deux réseaux."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 10, Les protocoles réseaux et l''adressage IP.', v_nom;
  END LOOP;
END $inf7$;
