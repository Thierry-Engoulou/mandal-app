-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 8 : Les topologies et les architectures réseaux
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
    WHERE programme_id = v_programme_id AND ordre = 8;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les topologies et les architectures réseaux', 8, 'Module 1 : Systèmes informatiques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 8 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 8 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les topologies physiques', 1, 'texte', '
La **topologie physique** décrit la **façon dont les machines sont câblées**.
Le programme en retient trois, avec leurs avantages et leurs inconvénients.

### La topologie en bus

Les ordinateurs sont tous reliés à un **câble principal unique**, historiquement
un **câble coaxial**. Chaque machine située sur le trajet d''un message le reçoit,
et ne l''ouvre que si elle en est la destinataire.

**Ses avantages** : une mise en œuvre **facile**, un fonctionnement **simple**,
et peu de câble.

**Ses inconvénients** : elle est **très vulnérable**. Une seule connexion
défectueuse peut bloquer **toute** la communication. Et les performances
**baissent** à mesure que le nombre d''ordinateurs augmente, car tous se
partagent le même câble.

C''est la topologie des débuts, qu''on ne monte plus aujourd''hui.

### La topologie en étoile

Tous les ordinateurs sont reliés à un **système central** : un **hub**, un
concentrateur, ou aujourd''hui un **commutateur**. C''est ce dispositif qui assure
la communication entre ses jonctions.

**Ses avantages** : elle est **beaucoup moins vulnérable**, car un câble
défectueux se débranche sans paralyser le reste du réseau. Elle est aussi
**simple à mettre en œuvre**.

**Ses inconvénients** : elle est **plus coûteuse**, car elle demande plus de
câble — un par poste — et le commutateur est un équipement cher.

Son vrai point faible n''est pas dans le cours mais mérite d''être dit : si le
commutateur tombe, tout le réseau tombe avec lui.

C''est **la** topologie utilisée aujourd''hui, et c''est la réponse à la question
« quelle topologie nécessite un commutateur ? ».

### La topologie en anneau

Toutes les entités forment une **boucle fermée**. Les données circulent **dans
un seul sens**, d''une entité à la suivante. Une entité ne retient une donnée que
si elle lui est adressée ; sinon, elle la transmet.

**Ses avantages** : une **quantité de câble minimale**, et un **protocole
simple** qui évite d''avoir à gérer les collisions.

**Ses inconvénients** : la **panne ou le retrait d''une entité active paralyse le
trafic**, et l''**insertion d''une nouvelle station est difficile**.

---

**Exercice corrigé**

*Donner le nom de la topologie physique de réseau qui nécessite un commutateur,
et justifier.*

**Correction.** La topologie en **étoile**.

*La justification.* Dans cette topologie, aucune machine n''est reliée
directement à une autre : toutes sont reliées à un **équipement central** qui
assure la communication entre elles. Cet équipement est un hub, un
concentrateur ou, aujourd''hui, un **commutateur**.

Les deux autres topologies s''en passent : le **bus** relie tout le monde à un
seul câble, et l''**anneau** relie chaque machine à ses deux voisines.

*Question tombée au Baccalauréat 2025, pour 0,5 point.*
', NULL, 25),
      (v_chapitre_id, 'Figure : les trois topologies physiques', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 230" width="560" height="230">
<rect width="560" height="230" fill="#ffffff"/>
<text x="280" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Les trois topologies physiques du programme</text>

<text x="92" y="48" text-anchor="middle" font-size="11" font-weight="700" fill="#b91c1c">BUS</text>
<line x1="20" y1="110" x2="164" y2="110" stroke="#334155" stroke-width="3"/>
<g fill="#1e293b">
<rect x="30" y="74" width="24" height="18" rx="2"/><rect x="70" y="74" width="24" height="18" rx="2"/><rect x="110" y="74" width="24" height="18" rx="2"/>
<rect x="50" y="128" width="24" height="18" rx="2"/><rect x="100" y="128" width="24" height="18" rx="2"/>
</g>
<g stroke="#334155" stroke-width="1.4">
<line x1="42" y1="92" x2="42" y2="110"/><line x1="82" y1="92" x2="82" y2="110"/><line x1="122" y1="92" x2="122" y2="110"/>
<line x1="62" y1="110" x2="62" y2="128"/><line x1="112" y1="110" x2="112" y2="128"/>
</g>
<text x="92" y="168" text-anchor="middle" font-size="9" fill="#166534">simple et peu coûteux</text>
<text x="92" y="182" text-anchor="middle" font-size="9" fill="#b91c1c">un câble coupé, tout tombe</text>
<text x="92" y="200" text-anchor="middle" font-size="8" fill="#64748b">câble coaxial</text>

<text x="280" y="48" text-anchor="middle" font-size="11" font-weight="700" fill="#15803d">ÉTOILE</text>
<rect x="258" y="100" width="44" height="26" rx="4" fill="#15803d"/>
<text x="280" y="117" text-anchor="middle" font-size="9" font-weight="700" fill="#ffffff">SWITCH</text>
<g fill="#1e293b">
<rect x="206" y="66" width="24" height="18" rx="2"/><rect x="268" y="60" width="24" height="18" rx="2"/><rect x="330" y="66" width="24" height="18" rx="2"/>
<rect x="206" y="146" width="24" height="18" rx="2"/><rect x="330" y="146" width="24" height="18" rx="2"/>
</g>
<g stroke="#334155" stroke-width="1.4">
<line x1="218" y1="84" x2="262" y2="104"/><line x1="280" y1="78" x2="280" y2="100"/><line x1="342" y1="84" x2="298" y2="104"/>
<line x1="218" y1="146" x2="262" y2="124"/><line x1="342" y1="146" x2="298" y2="124"/>
</g>
<text x="280" y="186" text-anchor="middle" font-size="9" fill="#166534">un câble coupé n&apos;isole qu&apos;un poste</text>
<text x="280" y="200" text-anchor="middle" font-size="9" fill="#b91c1c">plus de câble, et le switch coûte cher</text>

<text x="468" y="48" text-anchor="middle" font-size="11" font-weight="700" fill="#ca8a04">ANNEAU</text>
<circle cx="468" cy="114" r="46" fill="none" stroke="#334155" stroke-width="2.4"/>
<g fill="#1e293b">
<rect x="456" y="60" width="24" height="18" rx="2"/><rect x="502" y="104" width="24" height="18" rx="2"/>
<rect x="456" y="150" width="24" height="18" rx="2"/><rect x="410" y="104" width="24" height="18" rx="2"/>
</g>
<polygon points="468,66 462,76 474,76" fill="#ca8a04"/>
<polygon points="516,114 506,108 506,120" fill="#ca8a04"/>
<text x="468" y="186" text-anchor="middle" font-size="9" fill="#166534">peu de câble, pas de collision</text>
<text x="468" y="200" text-anchor="middle" font-size="9" fill="#b91c1c">une station tombe, le trafic s&apos;arrête</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : monter les trois topologies', 3, 'interactif', '{
  "widget": "topologies-physiques",
  "consigne": "Construis chacune des trois topologies avec cinq postes, puis coupe un câble et regarde ce qui tombe : tout le réseau en bus, un seul poste en étoile, tout le trafic en anneau. Un compteur te donne la longueur de câble utilisée et le coût du matériel, et un indicateur de performance baisse quand tu ajoutes des postes sur le bus."
}', NULL, 10),
      (v_chapitre_id, 'Les topologies logiques', 4, 'texte', '
La topologie physique dit **comment on câble**. La topologie **logique** dit
**comment on prend la parole** sur ce câble. Ce sont deux questions distinctes,
et le programme demande les deux.

### Ethernet

Un ordinateur qui veut émettre **vérifie d''abord qu''aucun message ne circule**.
Si la voie est libre, il émet.

Si **deux machines émettent en même temps**, il y a **collision**. Elles
**interrompent alors leur envoi**, **attendent un délai aléatoire**, puis la
première dont le délai s''achève réémet.

Le délai est tiré au hasard, et c''est ce qui évite que les deux machines
recommencent à se télescoper indéfiniment.

Ethernet s''emploie avec les topologies **en bus et en étoile**. C''est de très
loin la plus répandue aujourd''hui.

Pour l''imager : c''est une conversation ordinaire. On écoute avant de parler ; si
deux personnes parlent ensemble, les deux se taisent, et l''une reprend avant
l''autre.

### Token Ring, l''anneau à jeton

Un **jeton** circule en permanence sur l''anneau.

Une station **ne peut émettre qu''après avoir reçu le jeton**. Si le jeton est
**occupé**, elle le laisse passer sans le modifier. S''il est **libre**, elle
s''en saisit, émet son message, et le libère ensuite.

Il s''emploie avec la topologie **en étoile** — et historiquement en anneau.

L''image : c''est un tour de parole avec un bâton. Seul celui qui tient le bâton
parle. **Aucune collision n''est possible**, puisque personne ne parle sans le
bâton.

### La comparaison qu''on demande

| | Ethernet | Token Ring |
| --- | --- | --- |
| principe | on écoute, puis on parle | on attend le jeton |
| collisions | **possibles**, résolues par un délai aléatoire | **impossibles** |
| performance à faible charge | **excellente** | moyenne, on attend son tour |
| performance à forte charge | se dégrade, les collisions se multiplient | **stable et prévisible** |
| aujourd''hui | partout | pratiquement disparu |

---

**Exercice corrigé**

*Deux ordinateurs d''un réseau Ethernet émettent exactement au même instant.
Décrire ce qui se passe.*

**Correction.** Il se produit une **collision** : les deux signaux se
superposent sur le support et deviennent inexploitables.

Les deux machines **détectent la collision** et **interrompent immédiatement
leur envoi**.

Chacune **attend ensuite un délai aléatoire**, tiré indépendamment. La première
dont le délai s''achève **réémet** son message ; la seconde trouve la voie
occupée et attend.

*Pourquoi le délai est tiré au hasard, et c''est le vrai point de la question :*
si les deux machines attendaient la même durée, elles réémettraient ensemble et
entreraient de nouveau en collision, indéfiniment. Le hasard casse cette
symétrie.
', NULL, 25),
      (v_chapitre_id, 'Simulation : prendre la parole sur le réseau', 5, 'interactif', '{
  "widget": "topologies-logiques",
  "consigne": "Quatre machines veulent émettre, et tu choisis la méthode : Ethernet ou le jeton. En Ethernet, tu déclenches toi-même deux émissions simultanées et tu vois la collision, l''arrêt, les délais aléatoires et la reprise. Avec le jeton, tu suis le bâton de parole faire le tour. Un curseur de charge te montre pourquoi Ethernet gagne à faible trafic et perd quand tout le monde parle."
}', NULL, 10),
      (v_chapitre_id, 'Les architectures : poste à poste et client-serveur', 6, 'texte', '
Dernière façon de décrire un réseau : non plus par ses câbles ni par sa prise de
parole, mais par la **répartition des rôles**.

### L''architecture poste à poste

En anglais **peer to peer**, souvent abrégé **P2P**. Toutes les machines sont
**sur un pied d''égalité** : chacune est tour à tour **cliente et serveuse**, et
partage ses ressources — ses fichiers, son imprimante — avec les autres.

**Ses avantages** : un **coût faible**, puisqu''il n''y a pas de serveur à acheter
ni à administrer ; une **mise en œuvre simple**.

**Ses inconvénients** : la **sécurité est faible**, chaque poste décidant de ce
qu''il partage ; les **sauvegardes sont dispersées** ; et l''ensemble devient
**ingérable au-delà d''une dizaine de postes**.

C''est le réseau d''un petit bureau, ou d''une salle de classe sans serveur.

### L''architecture client-serveur

Un **serveur** sert plusieurs **clients**, qui lui adressent des **requêtes**.
Le serveur peut être **spécialisé** : serveur d''applications, serveur de
fichiers, serveur de données, serveur de messagerie.

**Ses avantages**, que le cours énumère :

les **ressources sont centralisées** — une base de données commune, par
exemple ;
la **sécurité est meilleure**, puisque les droits se gèrent en un seul point ;
le réseau est **évolutif** : ajouter ou retirer un client n''affecte pas son
fonctionnement.

**Ses inconvénients** : le **coût** du serveur et de son administration, et
surtout la **dépendance** — si le serveur tombe, tous les clients sont
paralysés. D''où les serveurs redondants dans les entreprises sérieuses.

### Comment choisir

| Situation | Architecture |
| --- | --- |
| moins de dix postes, pas de données sensibles | **poste à poste** |
| données communes à protéger, nombreux postes | **client-serveur** |
| un lycée, une banque, une administration | **client-serveur** |

---

**Exercice corrigé**

*Un établissement scolaire veut mettre en réseau ses 40 postes et héberger une
base de données des notes consultable par les professeurs. Quelle architecture
choisir, et pourquoi ?*

**Correction.** L''architecture **client-serveur**.

*Trois raisons, dans l''ordre d''importance.*

**La centralisation.** La base des notes doit exister en **un seul exemplaire**,
sur un serveur de données. En poste à poste, chaque machine aurait sa copie, et
les copies divergeraient dès le premier jour.

**La sécurité.** Les notes sont des données sensibles. Un serveur permet de
gérer les **droits d''accès en un seul point** : tel professeur ne voit que ses
classes, l''administration voit tout.

**L''évolutivité.** Avec 40 postes, et d''autres à venir, le poste à poste serait
ingérable : il devient impraticable au-delà d''une dizaine de machines.

*La contrepartie à mentionner* : il faut acheter et administrer un serveur, et
s''il tombe en panne, tout l''établissement est bloqué — d''où l''intérêt d''une
sauvegarde quotidienne.
', NULL, 25),
      (v_chapitre_id, 'Simulation : poste à poste ou client-serveur ?', 7, 'interactif', '{
  "widget": "architectures-reseau",
  "consigne": "Deux réseaux de dix postes tournent côte à côte, l''un en poste à poste, l''autre en client-serveur. Demande un fichier depuis n''importe quel poste et suis le chemin de la requête. Ajoute des postes, puis retire-en, puis fais tomber une machine : la simulation te montre ce que chaque architecture encaisse, et ce qui arrive au client-serveur le jour où c''est le serveur qui tombe."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 8', 8, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Dans quelle topologie physique toutes les machines sont-elles reliées à un même câble ?",
      "choix": [
        "En étoile",
        "En bus",
        "En anneau",
        "En maille"
      ],
      "bonne": 1,
      "explication": "Historiquement un câble coaxial. Elle est simple, mais une seule connexion défectueuse peut bloquer toute la communication."
    },
    {
      "question": "Quelle topologie physique nécessite un commutateur ?",
      "choix": [
        "Le bus",
        "L''étoile",
        "L''anneau",
        "Aucune"
      ],
      "bonne": 1,
      "explication": "Toutes les machines sont reliées à un équipement central qui assure la communication entre elles. Question du Baccalauréat 2025."
    },
    {
      "question": "Quel est l''inconvénient principal de la topologie en anneau ?",
      "choix": [
        "Elle consomme beaucoup de câble",
        "La panne ou le retrait d''une entité active paralyse le trafic",
        "Elle provoque beaucoup de collisions",
        "Elle nécessite un serveur"
      ],
      "bonne": 1,
      "explication": "Et l''insertion d''une nouvelle station y est difficile. En revanche elle utilise peu de câble et évite les collisions."
    },
    {
      "question": "Que se passe-t-il quand deux machines Ethernet émettent en même temps ?",
      "choix": [
        "Les deux messages passent",
        "Il y a collision : elles interrompent l''envoi, attendent un délai aléatoire, et la première réémet",
        "Le commutateur arbitre",
        "Le réseau tombe"
      ],
      "bonne": 1,
      "explication": "Le délai est tiré au hasard, et c''est le point essentiel : sinon les deux machines réémettraient ensemble indéfiniment."
    },
    {
      "question": "Dans Token Ring, quand une station peut-elle émettre ?",
      "choix": [
        "Quand la voie est libre",
        "Seulement après avoir reçu le jeton, et s''il est libre",
        "À tout moment",
        "Quand le serveur l''autorise"
      ],
      "bonne": 1,
      "explication": "C''est un tour de parole avec un bâton : aucune collision n''est possible, puisque personne ne parle sans le jeton."
    },
    {
      "question": "Quel est l''avantage principal de l''architecture client-serveur ?",
      "choix": [
        "Son faible coût",
        "La centralisation des ressources et une meilleure sécurité",
        "L''absence de panne possible",
        "Elle ne nécessite aucun câble"
      ],
      "bonne": 1,
      "explication": "Les droits se gèrent en un seul point et la base de données existe en un seul exemplaire. Le réseau est en plus évolutif."
    },
    {
      "question": "Au-delà de combien de postes le poste à poste devient-il ingérable ?",
      "choix": [
        "Trois",
        "Une dizaine",
        "Cinquante",
        "Cent"
      ],
      "bonne": 1,
      "explication": "Chaque poste décide de ce qu''il partage, les sauvegardes sont dispersées, et la sécurité devient impossible à tenir."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 8 leçons ajoutées au chapitre 8, Les topologies et les architectures réseaux.', v_nom;
  END LOOP;
END $inf7$;
