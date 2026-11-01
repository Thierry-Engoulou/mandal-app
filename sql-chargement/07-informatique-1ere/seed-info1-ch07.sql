-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 7 : Optimiser un ordinateur
-- Module 1 : Maintenance informatique — 9 leçons
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
    WHERE programme_id = v_programme_id AND ordre = 7;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Optimiser un ordinateur', 7, 'Module 1 : Maintenance informatique')
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
      (v_chapitre_id, 'La défragmentation', 1, 'texte', '
Une machine saine peut quand même être lente. L''optimisation, c''est l''art de lui
rendre sa vitesse sans rien changer au matériel.

### Pourquoi un disque se fragmente

Quand tu enregistres un fichier, le système le place dans les premiers espaces
libres qu''il trouve. Avec le temps — des fichiers créés, agrandis, supprimés —
ces espaces libres sont dispersés un peu partout.

Résultat : un gros fichier finit **découpé en morceaux** rangés à des endroits
éloignés du disque. On dit qu''il est **fragmenté**.

Rien n''est perdu, le système sait où sont tous les morceaux. Mais pour lire le
fichier, la **tête de lecture** doit se déplacer d''un bout à l''autre du disque,
et chaque déplacement prend du temps.

### Ce que fait la défragmentation

La **défragmentation** réorganise les fichiers du disque pour que chacun soit
d''un seul morceau, et regroupe l''espace libre au bout.

La lecture devient continue, et la machine retrouve de la vitesse.

### Trois précautions

**Sur un disque SSD, on ne défragmente pas.** Un SSD n''a pas de tête de lecture
et accède partout à la même vitesse ; défragmenter ne gagne rien et use
inutilement sa mémoire. Les systèmes récents le détectent et refusent.

**Il faut de l''espace libre** pour travailler : au moins 15 % du disque.

**Cela prend du temps**, parfois des heures sur un gros disque bien fragmenté.
On le lance quand la machine ne sert pas.

---

**Exercice corrigé**

*Un ordinateur met trois minutes à ouvrir un fichier qu''il ouvrait en dix
secondes il y a un an. Son disque dur mécanique est rempli à 97 %. Que
faites-vous, et dans quel ordre ?*

**Correction.** **D''abord libérer de l''espace, ensuite défragmenter.**

À 97 % de remplissage, il n''y a presque plus d''espace libre contigu : chaque
nouveau fichier est donc morcelé dès son enregistrement, et la fragmentation est
massive. Lancer la défragmentation tout de suite échouerait ou traînerait des
heures, faute de place pour déplacer les morceaux.

Donc : nettoyage du disque, désinstallation des programmes inutiles,
déplacement des gros fichiers vers un disque externe — jusqu''à redescendre sous
85 %. Puis la défragmentation, lancée en dehors des heures de travail.
', NULL, 22),
      (v_chapitre_id, 'Figure : avant et après la défragmentation', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 250" width="540" height="250">
<rect width="540" height="250" fill="#ffffff"/>
<text x="270" y="22" text-anchor="middle" font-size="14" font-weight="700" fill="#0f172a">Un disque fragmenté, puis le même disque défragmenté</text>

<text x="30" y="56" font-size="11" font-weight="700" fill="#b91c1c">AVANT — les fichiers sont éparpillés</text>
<g>
<rect x="30" y="64" width="24" height="24" fill="#2563eb"/><rect x="56" y="64" width="24" height="24" fill="#e2e8f0"/><rect x="82" y="64" width="24" height="24" fill="#16a34a"/><rect x="108" y="64" width="24" height="24" fill="#2563eb"/><rect x="134" y="64" width="24" height="24" fill="#e2e8f0"/><rect x="160" y="64" width="24" height="24" fill="#ea580c"/><rect x="186" y="64" width="24" height="24" fill="#16a34a"/><rect x="212" y="64" width="24" height="24" fill="#e2e8f0"/><rect x="238" y="64" width="24" height="24" fill="#2563eb"/><rect x="264" y="64" width="24" height="24" fill="#ea580c"/><rect x="290" y="64" width="24" height="24" fill="#e2e8f0"/><rect x="316" y="64" width="24" height="24" fill="#16a34a"/><rect x="342" y="64" width="24" height="24" fill="#ea580c"/><rect x="368" y="64" width="24" height="24" fill="#e2e8f0"/><rect x="394" y="64" width="24" height="24" fill="#2563eb"/><rect x="420" y="64" width="24" height="24" fill="#e2e8f0"/><rect x="446" y="64" width="24" height="24" fill="#16a34a"/><rect x="472" y="64" width="24" height="24" fill="#e2e8f0"/>
</g>
<text x="30" y="110" font-size="10" fill="#64748b">La tête de lecture doit sauter partout pour lire un seul fichier : c&apos;est lent.</text>

<line x1="30" y1="126" x2="500" y2="126" stroke="#cbd5e1" stroke-width="1.4" stroke-dasharray="4 4"/>

<text x="30" y="156" font-size="11" font-weight="700" fill="#15803d">APRÈS — chaque fichier est d&apos;un seul morceau</text>
<g>
<rect x="30" y="164" width="24" height="24" fill="#2563eb"/><rect x="56" y="164" width="24" height="24" fill="#2563eb"/><rect x="82" y="164" width="24" height="24" fill="#2563eb"/><rect x="108" y="164" width="24" height="24" fill="#2563eb"/><rect x="134" y="164" width="24" height="24" fill="#16a34a"/><rect x="160" y="164" width="24" height="24" fill="#16a34a"/><rect x="186" y="164" width="24" height="24" fill="#16a34a"/><rect x="212" y="164" width="24" height="24" fill="#16a34a"/><rect x="238" y="164" width="24" height="24" fill="#ea580c"/><rect x="264" y="164" width="24" height="24" fill="#ea580c"/><rect x="290" y="164" width="24" height="24" fill="#ea580c"/><rect x="316" y="164" width="24" height="24" fill="#e2e8f0"/><rect x="342" y="164" width="24" height="24" fill="#e2e8f0"/><rect x="368" y="164" width="24" height="24" fill="#e2e8f0"/><rect x="394" y="164" width="24" height="24" fill="#e2e8f0"/><rect x="420" y="164" width="24" height="24" fill="#e2e8f0"/><rect x="446" y="164" width="24" height="24" fill="#e2e8f0"/><rect x="472" y="164" width="24" height="24" fill="#e2e8f0"/>
</g>
<text x="30" y="210" font-size="10" fill="#64748b">La tête lit d&apos;une traite, et l&apos;espace libre est regroupé au bout.</text>

<rect x="30" y="222" width="18" height="12" fill="#2563eb"/><text x="54" y="232" font-size="10" fill="#334155">fichier 1</text>
<rect x="124" y="222" width="18" height="12" fill="#16a34a"/><text x="148" y="232" font-size="10" fill="#334155">fichier 2</text>
<rect x="218" y="222" width="18" height="12" fill="#ea580c"/><text x="242" y="232" font-size="10" fill="#334155">fichier 3</text>
<rect x="312" y="222" width="18" height="12" fill="#e2e8f0" stroke="#94a3b8"/><text x="336" y="232" font-size="10" fill="#334155">espace libre</text>
</svg>', NULL, 5),
      (v_chapitre_id, 'Simulation : défragmenter un disque', 3, 'interactif', '{
  "widget": "defragmentation",
  "consigne": "Un disque fragmenté s''affiche en cases colorées, un fichier par couleur. Tu peux écrire de nouveaux fichiers, en supprimer, et regarder la fragmentation s''installer d''elle-même. Lance alors la défragmentation et suis les blocs se regrouper, avec le temps de lecture d''un fichier affiché avant et après. Un bouton te fait basculer en mode SSD, pour voir pourquoi l''opération n''y sert à rien."
}', NULL, 10),
      (v_chapitre_id, 'Le partitionnement et le formatage', 4, 'texte', '
### Le partitionnement

**Partitionner** un disque dur, c''est le **diviser en plusieurs volumes** qui
apparaîtront comme des disques distincts : C:, D:, E:.

Physiquement, il n''y a toujours qu''un seul disque. Logiquement, il y en a
plusieurs.

Pourquoi faire ?

- **Séparer le système des données.** Si Windows doit être réinstallé, on
reformate seulement C:, et les documents restés sur D: sont intacts.
- **Installer plusieurs systèmes** sur la même machine.
- **Organiser** un gros disque.

Et la limite à connaître : partitionner **ne protège pas d''une panne physique**.
Si le disque meurt, toutes ses partitions meurent avec lui. Une partition n''est
pas une sauvegarde.

### Le formatage

**Formater** un volume, c''est le **préparer à recevoir des données** en y
installant un système de fichiers — NTFS, FAT32, exFAT.

L''opération **efface** ce qui s''y trouvait. On ne formate donc jamais sans avoir
vérifié la sauvegarde.

On distingue le **formatage rapide**, qui réécrit seulement la table des
fichiers — les données sont encore là, récupérables par un outil — et le
**formatage complet**, qui parcourt et vérifie toute la surface. Le complet est
beaucoup plus long, et c''est celui qu''on utilise quand on soupçonne le disque
d''être abîmé.

---

**Exercice corrigé**

*Un élève vous dit : « j''ai mis mes devoirs sur la partition D:, donc ils sont
en sécurité ». A-t-il raison ?*

**Correction.** **Non.** Il confond partition et sauvegarde.

Il a raison sur un point : si le système d''exploitation doit être réinstallé, on
reformatera C: et D: sera épargné. La séparation protège donc contre une
**réinstallation** et contre une **erreur logicielle**.

Mais C: et D: sont deux parties du **même disque physique**. Si ce disque tombe
en panne mécanique, si l''alimentation grille, si la machine est volée ou prend
l''eau, les deux partitions disparaissent ensemble.

Une vraie sauvegarde est sur un **autre support** : disque externe, clé USB,
autre machine, ou en ligne. Et de préférence rangé à un autre endroit.
', NULL, 24),
      (v_chapitre_id, 'Simulation : partitionner un disque', 5, 'interactif', '{
  "widget": "partitionnement",
  "consigne": "Un disque de 500 Go t''est confié : découpe-le en partitions, choisis leur taille et leur système de fichiers, puis range tes données. La simulation t''envoie ensuite trois scénarios — une réinstallation du système, un virus qui chiffre C:, et une panne mécanique du disque — et te montre ce qui survit à chacun. Le troisième est celui qui fait comprendre qu''une partition n''est pas une sauvegarde."
}', NULL, 10),
      (v_chapitre_id, 'Le nettoyage du disque et la sauvegarde', 6, 'texte', '
### Le nettoyage du disque

Un système accumule des fichiers dont personne n''a plus besoin. Les faire
disparaître est l''optimisation la plus rentable, parce qu''elle est gratuite,
rapide et sans risque.

Ce qu''on enlève :

- les **fichiers temporaires**, laissés par les programmes qui travaillent ;
- le **cache du navigateur**, souvent plusieurs gigaoctets ;
- la **corbeille**, que beaucoup d''utilisateurs ne vident jamais ;
- les **programmes inutilisés**, à désinstaller proprement depuis le
panneau de configuration et non en supprimant leur dossier ;
- les **doublons**, surtout dans les photos et les téléchargements.

### Les programmes au démarrage

C''est la deuxième cause de lenteur après le disque plein. Beaucoup de logiciels
s''installent **dans le démarrage** sans demander, et se lancent tous ensemble
quand tu allumes la machine.

Désactiver ceux dont tu n''as pas besoin au démarrage ne les supprime pas : ils
se lanceront quand tu les ouvriras.

### La sauvegarde

Pour finir, la seule opération dont tu ne regretteras jamais de l''avoir faite.

**Sauvegarder**, c''est garder une **copie des données sur un autre support** que
celui où elles vivent.

La règle que les professionnels retiennent est celle du **3-2-1** : **trois**
copies des données, sur **deux** supports différents, dont **une** hors du lieu
de travail.

Pour un élève camerounais, cela veut dire concrètement : le devoir sur le
disque de la machine, une copie sur une clé USB, et une copie dans une boîte
mail ou un espace en ligne. Si la machine grille la veille du dépôt, le devoir
existe encore.

---

**Exercice corrigé**

*Citer trois opérations d''optimisation d''un ordinateur devenu lent, en
expliquant brièvement l''effet de chacune.*

**Correction.**

**Le nettoyage du disque** — on supprime les fichiers temporaires, le cache du
navigateur et la corbeille. Cela libère de l''espace, et un disque qui respire
travaille mieux.

**La défragmentation** — on regroupe les morceaux de chaque fichier. La tête de
lecture cesse de sauter d''un bout du disque à l''autre, et la lecture accélère.
À réserver aux disques mécaniques.

**La réduction des programmes au démarrage** — on désactive ceux qui se lancent
sans qu''on le leur demande. Le démarrage raccourcit et la mémoire vive reste
disponible pour le travail réel.

On pourrait ajouter la désinstallation des logiciels inutilisés et l''analyse
antivirus, puisqu''un virus consomme lui aussi du processeur et de la mémoire.
', NULL, 24),
      (v_chapitre_id, 'Simulation : rendre sa vitesse à une machine', 7, 'interactif', '{
  "widget": "nettoyage-disque",
  "consigne": "Une machine lente t''est donnée, avec son disque rempli à 94 %, onze programmes au démarrage, un cache de navigateur énorme et une corbeille jamais vidée. Tu choisis tes opérations dans l''ordre que tu veux, et la simulation affiche après chacune l''espace récupéré et le temps de démarrage. Essaie de descendre sous trente secondes."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Probatoire — la maintenance (session 2017)', 8, 'texte', '
Voici la troisième partie du Probatoire d''informatique, session 2017,
entièrement corrigée. Elle vaut **6 points** sur 20, et porte exclusivement sur
ce module.

---

**Énoncé**

*Vous êtes technicien de maintenance dans une entreprise. Répondez aux questions
suivantes.*

*1. Vous appuyez sur le bouton de mise en marche d''un ordinateur : aucun voyant
ne s''allume, aucun ventilateur ne tourne. Quel est le premier élément à
vérifier ?*

*2. Vous avez démarré l''ordinateur, mais votre secrétaire, passant à proximité,
a par inadvertance laissé tomber le dictionnaire qu''elle tenait en main sur le
clavier, ce qui provoque un long sifflement de l''ordinateur. Qu''est-ce qui est à
l''origine de ce sifflement ?*

*3. Comment appelle-t-on la séquence durant laquelle tous les composants sont
testés au démarrage ?*

*4. Sur quel document trouve-t-on les caractéristiques d''un ordinateur avant son
achat ?*

*5. On lit sur ce document : « Windows 8.1 — 64 bits ». Que désigne la mention
« 64 bits » ?*

*6. On lit également : « HDD 500 Go ». De quel composant s''agit-il, et quelle
grandeur mesure-t-on ?*

*7. Quel composant permet d''afficher l''image sur l''écran ?*

*8. On lit enfin : « Écran 18,5" ». Quelle est cette unité, et comment la
mesure-t-on ?*

*9. Quel appareil installer pour protéger ces ordinateurs contre les coupures et
les variations de courant ?*

---

**Correction détaillée**

**1.** Le **câble d''alimentation** : son branchement sur l''unité centrale, son
branchement sur la prise murale, l''état de la prise et l''interrupteur à
l''arrière du bloc d''alimentation.

*Pourquoi.* Aucun voyant et aucun bruit signifie que le courant n''arrive pas du
tout. Si l''alimentation fonctionnait, on aurait au moins un voyant ou un
ventilateur, même avec une carte mère morte. Et c''est la vérification la plus
rapide : on ne démonte jamais une machine avant d''avoir vérifié qu''elle est
branchée.

**2.** Une **touche du clavier restée enfoncée** sous le poids du dictionnaire.

*Pourquoi.* Pendant la séquence de tests du démarrage, le BIOS vérifie le
clavier. Il détecte une touche bloquée, considère qu''il y a une anomalie
matérielle et le signale par un signal sonore continu. Il suffit de soulever le
dictionnaire et de redémarrer.

**3.** La **séquence POST**, pour *Power On Self Test* — on l''appelle aussi
séquence pré-boot. Si elle ne passe pas, le système d''exploitation n''est pas
lancé du tout.

**4.** La **fiche technique** du matériel.

**5.** Le **jeu d''instruction** du processeur, c''est-à-dire la taille des
données qu''il peut traiter en une seule fois. C''est l''une des quatre
caractéristiques du microprocesseur, avec la marque, la fréquence et la quantité
de mémoire adressable.

**6.** Il s''agit du **disque dur** — *HDD* pour *Hard Disk Drive* — et la
grandeur mesurée est sa **capacité de stockage**, exprimée en octets et leurs
multiples : ici 500 gigaoctets.

**7.** La **carte graphique**, aussi appelée carte vidéo, à laquelle l''écran se
raccorde par le port VGA ou HDMI. C''est une carte d''extension.

**8.** Le **pouce**, qui vaut 2,54 cm. On le mesure **en diagonale**, d''un coin
de la dalle au coin opposé. Un écran de 18,5 pouces mesure donc environ 47 cm en
diagonale — et non en largeur.

**9.** Un **onduleur**, en anglais *UPS*. Il contient une batterie qui continue
à alimenter la machine pendant la coupure, le temps d''enregistrer le travail et
d''éteindre proprement.

*Attention à ne pas répondre « régulateur de tension » ou « parasurtenseur ».
Le régulateur corrige la tension quand elle monte ou descend, le parasurtenseur
absorbe les pointes brutales ; mais ni l''un ni l''autre ne fournit de courant
pendant une coupure. L''énoncé parle de coupures : c''est l''onduleur.*

---

**Ce que ce sujet t''apprend sur l''épreuve**

Regarde la nature des neuf questions : aucune ne demande de calcul, aucune ne
demande de raisonnement long. Elles vérifient que tu **connais le vocabulaire**
et que tu sais **lire une fiche technique**.

Les points de cette partie se gagnent donc en apprenant les définitions, les
sigles et les unités — exactement ce que contiennent les chapitres 1 à 7.
', NULL, 30),
      (v_chapitre_id, 'Quiz du chapitre 7', 9, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Pourquoi un disque dur se fragmente-t-il ?",
      "choix": [
        "Parce qu''il vieillit",
        "Parce que le système place chaque fichier dans les premiers espaces libres, qui finissent dispersés",
        "À cause des virus",
        "Parce qu''il chauffe"
      ],
      "bonne": 1,
      "explication": "Avec le temps, les fichiers créés, agrandis et supprimés laissent des trous un peu partout, et un gros fichier finit découpé en morceaux éloignés."
    },
    {
      "question": "Que fait la défragmentation ?",
      "choix": [
        "Elle supprime les fichiers inutiles",
        "Elle réorganise les fichiers pour que chacun soit d''un seul morceau",
        "Elle divise le disque en partitions",
        "Elle sauvegarde les données"
      ],
      "bonne": 1,
      "explication": "La tête de lecture cesse de sauter d''un bout du disque à l''autre : la lecture devient continue et la machine retrouve de la vitesse."
    },
    {
      "question": "Faut-il défragmenter un disque SSD ?",
      "choix": [
        "Oui, chaque mois",
        "Non : un SSD accède partout à la même vitesse, et l''opération userait inutilement sa mémoire",
        "Oui, mais seulement s''il est plein",
        "Oui, c''est encore plus important que sur un disque mécanique"
      ],
      "bonne": 1,
      "explication": "Un SSD n''a pas de tête de lecture à déplacer. Les systèmes récents le détectent et refusent l''opération."
    },
    {
      "question": "Qu''est-ce que le partitionnement d''un disque dur ?",
      "choix": [
        "Sa division en plusieurs volumes qui apparaissent comme des disques distincts",
        "Son nettoyage complet",
        "Sa réparation",
        "Sa copie sur un autre support"
      ],
      "bonne": 0,
      "explication": "Physiquement, il n''y a toujours qu''un seul disque ; logiquement, il y en a plusieurs. Cela permet notamment de séparer le système des données."
    },
    {
      "question": "Mettre ses documents sur la partition D: est-il une sauvegarde ?",
      "choix": [
        "Oui, c''est l''intérêt du partitionnement",
        "Non : C: et D: sont sur le même disque physique, et meurent ensemble si ce disque tombe en panne",
        "Oui, à condition que D: soit formatée en NTFS",
        "Non, il faut les mettre sur C:"
      ],
      "bonne": 1,
      "explication": "La séparation protège d''une réinstallation du système, pas d''une panne physique. Une vraie sauvegarde est sur un AUTRE support."
    },
    {
      "question": "Que signifie la règle du 3-2-1 en matière de sauvegarde ?",
      "choix": [
        "Trois copies, sur deux supports différents, dont une hors du lieu de travail",
        "Trois sauvegardes par semaine, deux par mois, une par an",
        "Trois disques durs, deux partitions, un système",
        "Trois fichiers par dossier, deux dossiers par disque"
      ],
      "bonne": 0,
      "explication": "Pour un élève : le devoir sur la machine, une copie sur clé USB, une copie en ligne. Si la machine grille la veille du dépôt, le devoir existe encore."
    },
    {
      "question": "Quelle est la deuxième cause de lenteur d''un ordinateur, après le disque plein ?",
      "choix": [
        "Un écran trop grand",
        "Les programmes qui se lancent automatiquement au démarrage",
        "Un clavier défectueux",
        "Une imprimante mal installée"
      ],
      "bonne": 1,
      "explication": "Beaucoup de logiciels s''installent dans le démarrage sans demander. Les désactiver ne les supprime pas : ils se lanceront quand tu les ouvriras."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 9 leçons ajoutées au chapitre 7, Optimiser un ordinateur.', v_nom;
  END LOOP;
END $inf1$;
