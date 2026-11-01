-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 4 : Les équipements de protection électrique
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
    WHERE programme_id = v_programme_id AND ordre = 4;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les équipements de protection électrique', 4, 'Module 1 : Systèmes informatiques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 4 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 4 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le bloc d''alimentation', 1, 'texte', '
Le programme consacre une unité entière à la protection électrique, et commence
par le composant qui reçoit le courant : le bloc d''alimentation.

### Sa fonction

Le **bloc d''alimentation** transforme le **courant alternatif** du secteur — au
Cameroun, 220 volts à 50 hertz — en **courants continus de faible tension**
utilisables par les composants : **12 V**, **5 V** et **3,3 V**.

C''est la réponse attendue quand on demande « donner la fonction du bloc
d''alimentation » : il **convertit** et il **distribue**.

### Ce qu''il alimente

Le 12 V fait tourner les moteurs : ventilateurs et disques mécaniques. Le 5 V et
le 3,3 V alimentent l''électronique : carte mère, mémoire, cartes d''extension.

### Sa caractéristique

La **puissance**, en **watts**. Une machine de bureau se contente de 350 à
450 W ; une machine équipée d''une carte graphique puissante en réclame 650 ou
plus.

Sous-dimensionner l''alimentation est une erreur coûteuse : la machine redémarre
au hasard dès qu''elle est sollicitée, et on cherche longtemps ailleurs.

### Pourquoi c''est lui qui meurt en premier

Il est en **première ligne**. C''est lui qui encaisse les surtensions, et c''est
donc lui qui grille — ce qui est une bonne nouvelle, car il coûte bien moins
cher qu''une carte mère.

D''où le symptôme à connaître : **aucun voyant, aucun bruit de ventilateur**.
Quand rien ne s''allume du tout, on vérifie le câble, la prise, l''interrupteur à
l''arrière du bloc, puis le bloc lui-même.

---

**Exercice corrigé**

*Donner la fonction du bloc d''alimentation d''un ordinateur.*

**Correction.** Le bloc d''alimentation **convertit le courant alternatif du
secteur, de 220 V, en courants continus de basse tension** — 12 V, 5 V et
3,3 V — et les **distribue** aux différents composants de la machine.

*Cette question figure telle quelle dans les actions à mener du programme, et
elle est tombée au Baccalauréat. Une réponse en une phrase suffit, mais elle
doit contenir les deux idées : convertir, et distribuer.*
', NULL, 22),
      (v_chapitre_id, 'Simulation : à l''intérieur du bloc d''alimentation', 2, 'interactif', '{
  "widget": "bloc-alimentation",
  "consigne": "Le courant de la prise entre dans le bloc et en ressort en trois tensions continues. Suis-le, et vois quelle ligne alimente quel composant. Fais ensuite varier la puissance du bloc et la configuration de la machine : la simulation additionne la consommation et te montre la machine redémarrer au hasard dès que la demande dépasse ce que le bloc peut fournir."
}', NULL, 10),
      (v_chapitre_id, 'L''onduleur, le régulateur et le parasurtenseur', 3, 'texte', '
Trois appareils, trois fonctions différentes. Les confondre coûte un point à
chaque fois, car le Baccalauréat demande précisément **le rôle de chacun**.

### Le régulateur de tension

Il **ramène la tension à sa valeur normale** quand elle monte ou qu''elle
descend.

Au Cameroun, la tension du secteur descend régulièrement à 180 ou 170 volts aux
heures de pointe. Le régulateur relève cette tension et épargne les
alimentations, qui sinon forcent et s''échauffent.

Ce qu''il ne fait pas : **il ne fournit aucun courant pendant une coupure**.

### Le parasurtenseur

Il **absorbe les pointes brutales de tension** — la foudre, le retour de courant
après une coupure.

Il travaille en une fraction de seconde et se sacrifie : un bon parasurtenseur
est un consommable, il faut le remplacer après un gros choc.

Ce qu''il ne fait pas : **il ne corrige pas une tension trop basse**, et **il ne
fournit rien pendant une coupure**.

### L''onduleur

En anglais **UPS**, pour *Uninterruptible Power Supply*. Il contient une
**batterie** et **continue d''alimenter la machine pendant la coupure**.

C''est le seul des trois à faire cela, et c''est pour cette raison que c''est
presque toujours lui qu''on attend en réponse d''examen.

Son autonomie se compte en minutes — cinq à quinze pour un modèle de bureau. Ce
n''est pas un groupe électrogène : il sert à **enregistrer le travail et à
éteindre proprement**, pas à continuer la journée.

La plupart des onduleurs assurent en plus la **régulation** et la **protection
contre les surtensions** : ils font donc les trois métiers.

### Le tableau à retenir

| | baisse de tension | surtension brutale | coupure totale |
| --- | --- | --- | --- |
| **régulateur** | ✔ corrige | ✘ | ✘ |
| **parasurtenseur** | ✘ | ✔ absorbe | ✘ |
| **onduleur** | ✔ | ✔ | ✔ **la batterie prend le relais** |

---

**Exercice corrigé**

*Donner le rôle du régulateur de tension, puis celui de l''onduleur.*

**Correction.**

Le **régulateur de tension** maintient la tension d''alimentation à sa valeur
normale : il **relève** une tension trop basse et **abaisse** une tension trop
haute, protégeant ainsi les équipements des variations du secteur.

L''**onduleur** **continue d''alimenter les équipements pendant une coupure de
courant**, grâce à une batterie interne, le temps d''enregistrer le travail en
cours et d''éteindre proprement les machines. Il assure en général aussi la
régulation et la protection contre les surtensions.

*Le rôle du régulateur valait 0,5 point au Baccalauréat 2024. Le piège consiste
à répondre « il protège l''ordinateur » : c''est vrai de tous les trois, et cela
ne distingue rien. Il faut dire ce qu''il fait au courant.*
', NULL, 26),
      (v_chapitre_id, 'Simulation : trois incidents, trois appareils', 4, 'interactif', '{
  "widget": "equipements-protection",
  "consigne": "Choisis l''équipement installé dans la salle — rien, régulateur, parasurtenseur ou onduleur — puis envoie sur la ligne une baisse de tension, un coup de foudre ou une coupure de deux minutes. La simulation te montre poste par poste ce qui survit et ce qui grille, avec la tension réellement reçue par les machines. Essaie les neuf combinaisons : un seul appareil passe les trois épreuves."
}', NULL, 10),
      (v_chapitre_id, 'Dimensionner et choisir sa protection', 5, 'texte', '
Savoir ce que fait chaque appareil ne suffit pas : il faut savoir **lequel
acheter, et de quelle taille**.

### Dimensionner un onduleur

La puissance d''un onduleur s''exprime en **VA** (volt-ampères), parfois en watts.

La règle pratique : on additionne la consommation des appareils à protéger, puis
on prévoit une **marge d''environ 30 %**.

Pour un ordinateur de bureau et son écran plat :

$$P \approx 250 \text{ W (unité centrale)} + 40 \text{ W (écran)} = 290 \text{ W}$$

Avec la marge :

$$290 \times 1{,}3 \approx 380 \text{ W}$$

Soit un onduleur d''environ **650 VA**, puisqu''on compte en général 0,6 watt par
volt-ampère.

**Ce qu''on ne branche jamais sur un onduleur** : une imprimante laser. Son
préchauffage consomme en pointe plus que tout le reste de la salle et fait
disjoncter l''onduleur.

### Choisir selon le besoin

| Situation | Équipement |
| --- | --- |
| tension qui varie beaucoup, pas de coupure | régulateur |
| orages fréquents, bonne tension | parasurtenseur |
| coupures fréquentes, travail à sauvegarder | **onduleur** |
| serveur ou salle entière | onduleur de forte puissance, voire groupe |

### Les gestes qui ne coûtent rien

Brancher les machines sur des prises **avec terre**. Ne pas surcharger les
multiprises. Débrancher pendant un orage violent — aucun parasurtenseur ne
garantit contre un coup direct. Et vérifier la batterie de l''onduleur une fois
par an : une batterie morte ne prévient pas, elle se découvre le jour de la
coupure.

---

**Exercice corrigé**

*Une salle doit recevoir 6 postes de 250 W et 6 écrans de 40 W. On veut que les
élèves puissent enregistrer leur travail et éteindre proprement en cas de
coupure. Que faut-il installer, et de quelle puissance ?*

**Correction.** Il faut des **onduleurs**, puisque l''énoncé parle de
**coupures** : ni le régulateur ni le parasurtenseur ne fournissent de courant.

*La puissance.* La consommation totale vaut :

$$6 \times 250 + 6 \times 40 = 1\,500 + 240 = 1\,740 \text{ W}$$

Avec une marge de 30 % :

$$1\,740 \times 1{,}3 = 2\,262 \text{ W}$$

*Deux solutions.* Un **onduleur central** d''au moins 2 300 W — soit environ
3 800 VA —, ou **six onduleurs individuels** d''environ 650 VA chacun.

La seconde solution est souvent préférée dans les établissements : elle coûte
moins cher à l''achat, et la panne d''un onduleur ne prive qu''un seul poste.
', NULL, 25),
      (v_chapitre_id, 'Simulation : dimensionner l''onduleur d''une salle', 6, 'interactif', '{
  "widget": "dimensionner-onduleur",
  "consigne": "Compose ta salle — nombre de postes, d''écrans, présence d''une imprimante — et la simulation additionne les consommations, applique la marge et te propose la puissance en VA. Branche ensuite l''imprimante laser sur l''onduleur et lance une impression : tu verras l''appel de courant du préchauffage faire disjoncter tout le monde. Un compteur te donne l''autonomie en minutes selon la charge."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 4', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la fonction du bloc d''alimentation ?",
      "choix": [
        "Protéger contre les coupures",
        "Convertir le courant alternatif du secteur en courants continus de basse tension et les distribuer",
        "Refroidir le processeur",
        "Stocker les données"
      ],
      "bonne": 1,
      "explication": "Deux idées attendues : convertir, et distribuer. Il fournit du 12 V, du 5 V et du 3,3 V aux composants."
    },
    {
      "question": "Quel est le rôle du régulateur de tension ?",
      "choix": [
        "Fournir du courant pendant une coupure",
        "Ramener la tension à sa valeur normale quand elle monte ou descend",
        "Absorber les coups de foudre",
        "Transformer le courant continu en alternatif"
      ],
      "bonne": 1,
      "explication": "Il relève une tension trop basse et abaisse une tension trop haute. Répondre « il protège l''ordinateur » ne distingue rien et ne vaut pas le point."
    },
    {
      "question": "Quel appareil permet de continuer à travailler pendant une coupure ?",
      "choix": [
        "Le régulateur",
        "Le parasurtenseur",
        "L''onduleur",
        "Le bloc d''alimentation"
      ],
      "bonne": 2,
      "explication": "Lui seul contient une batterie. C''est pour cela qu''on l''attend presque toujours en réponse d''examen quand l''énoncé parle de coupure."
    },
    {
      "question": "Que fait un parasurtenseur ?",
      "choix": [
        "Il relève les tensions trop basses",
        "Il absorbe les pointes brutales de tension, comme la foudre",
        "Il alimente la machine sur batterie",
        "Il régule la vitesse du ventilateur"
      ],
      "bonne": 1,
      "explication": "Il travaille en une fraction de seconde et se sacrifie : c''est un consommable, à remplacer après un gros choc."
    },
    {
      "question": "Combien de temps un onduleur de bureau tient-il en général ?",
      "choix": [
        "Quelques secondes",
        "Cinq à quinze minutes",
        "Deux heures",
        "Toute la journée"
      ],
      "bonne": 1,
      "explication": "Ce n''est pas un groupe électrogène : il sert à enregistrer le travail et à éteindre proprement, pas à continuer la journée."
    },
    {
      "question": "Que ne faut-il jamais brancher sur un onduleur ?",
      "choix": [
        "Un écran plat",
        "Une imprimante laser",
        "Une unité centrale",
        "Un modem"
      ],
      "bonne": 1,
      "explication": "Son préchauffage consomme en pointe plus que tout le reste de la salle et fait disjoncter l''onduleur."
    },
    {
      "question": "Six postes de 250 W et six écrans de 40 W, avec une marge de 30 % : quelle puissance d''onduleur ?",
      "choix": [
        "environ 1 740 W",
        "environ 2 300 W",
        "environ 290 W",
        "environ 580 W"
      ],
      "bonne": 1,
      "explication": "6 × 250 + 6 × 40 = 1 740 W, puis 1 740 × 1,3 ≈ 2 262 W, soit environ 2 300 W — ou six onduleurs individuels de 650 VA."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 4, Les équipements de protection électrique.', v_nom;
  END LOOP;
END $inf7$;
