-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Terminale
-- Chapitre 3 : Les causes des dysfonctionnements matériels et logiciels
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
    WHERE programme_id = v_programme_id AND ordre = 3;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les causes des dysfonctionnements matériels et logiciels', 3, 'Module 1 : Systèmes informatiques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 3 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 3 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les causes matérielles des dysfonctionnements', 1, 'texte', '
Le programme demande d''**identifier quelques causes de dysfonctionnement du
matériel et des logiciels**. Commençons par le matériel, et par ce qui se
rencontre réellement au Cameroun.

### L''instabilité du courant électrique

C''est la première cause, loin devant les autres. Coupures brutales, retours de
courant, surtensions et sous-tensions abîment le bloc d''alimentation, la carte
mère et le disque dur.

Elle fait l''objet du chapitre suivant, entièrement consacré aux équipements qui
en protègent.

### La poussière et la chaleur

La poussière s''accumule sur les ventilateurs et les grilles d''aération. Le
processeur ne se refroidit plus, la machine chauffe, ralentit, puis s''éteint
seule.

Le symptôme qui ne trompe pas : la panne survient **après un certain temps de
travail**, et **s''aggrave en fin d''après-midi**, quand la salle est déjà chaude.

### L''humidité et les insectes

La saison des pluies oxyde les contacts. Les cafards et les fourmis s''installent
dans les boîtiers tièdes et court-circuitent les cartes. Ce n''est pas anecdotique
dans une salle informatique mal fermée.

### Les chocs et les manipulations

Un disque dur mécanique en fonctionnement ne supporte pas d''être déplacé
brusquement. Une barrette mal enfoncée, un câble tiré, un connecteur forcé : ce
sont des pannes de manipulation.

### L''usure

Les ventilateurs s''encrassent et se grippent, les piles de carte mère se vident
— l''horloge se dérègle et le BIOS perd ses réglages —, les disques mécaniques
développent des secteurs défectueux.

---

**Exercice corrigé**

*Dans une salle informatique, les ordinateurs s''éteignent tout seuls après une
heure de travail, et le problème s''aggrave en fin d''après-midi. Quelle est la
cause la plus probable, et que faites-vous ?*

**Correction.** La **surchauffe**, par accumulation de poussière dans les
ventilateurs et les grilles d''aération.

*Deux indices le disent.* D''abord **après une heure** : il faut du temps pour
que la température monte, ce qui exclut un défaut d''alimentation, qui serait
immédiat. Ensuite **en fin d''après-midi** : la salle est déjà chaude, et le
seuil critique est atteint plus vite.

*L''intervention.* Souffler les ventilateurs et les grilles, vérifier que rien
ne bouche l''aération, puis améliorer la ventilation de la salle elle-même.
', NULL, 24),
      (v_chapitre_id, 'Simulation : remonter à la cause matérielle', 2, 'interactif', '{
  "widget": "causes-materielles",
  "consigne": "Huit machines présentent chacune leur symptôme : extinction après une heure, aucun voyant, horloge qui se dérègle à chaque démarrage, bips au lancement, grincement du disque. Tu choisis la cause et la simulation te montre l''indice décisif que tu avais sous les yeux — le délai, le bruit, le moment de la journée. Un chronomètre mesure la température du processeur pendant que la poussière s''accumule."
}', NULL, 10),
      (v_chapitre_id, 'Les causes logicielles', 3, 'texte', '
Quand le matériel est sain, le problème est ailleurs. Quatre causes couvrent la
quasi-totalité des cas.

### Les programmes malveillants

Virus, vers, chevaux de Troie, logiciels espions. Ils consomment le processeur
et la mémoire, modifient ou détruisent des données, et commencent souvent par
**désactiver l''antivirus** — le signe qui ne trompe presque jamais.

La parade : un **antivirus à jour**, et la prudence avec les clés USB et les
pièces jointes.

### Le pilote absent ou inadapté

Nous l''avons vu au chapitre précédent. C''est le cas classique du son qui
disparaît après une réinstallation.

### L''absence de mise à jour

Un système non mis à jour accumule des failles de sécurité et des
incompatibilités avec les logiciels récents.

### La mauvaise manipulation

Un fichier système supprimé, une désinstallation interrompue, un réglage changé
au hasard, un disque rempli à ras bord. L''utilisateur est, de loin, la cause
logicielle la plus fréquente — et il ne s''en rend presque jamais compte.

### Comment distinguer une panne matérielle d''une panne logicielle

Le test est simple et il se donne en une phrase : **si la machine passe la
séquence de tests du démarrage et charge son système, le matériel essentiel va
bien**, et il faut chercher du côté logiciel.

À l''inverse, une machine qui bipe sans afficher, ou qui s''éteint seule, a un
problème matériel.

---

**Exercice corrigé**

*Depuis trois jours, un ordinateur est très lent et des raccourcis inconnus
apparaissent sur le bureau. Le disque est rempli à 45 %. Panne matérielle ou
logicielle ? Que faites-vous ?*

**Correction.** Panne **logicielle**, et très probablement une **infection**.

*Pourquoi on écarte le matériel.* La machine démarre et affiche son bureau :
elle a donc passé la séquence de tests, et ses composants essentiels répondent.

*Pourquoi on écarte le disque plein.* À 45 % de remplissage, il reste plus de la
moitié du disque : la lenteur ne vient pas de là.

*Ce qui reste.* Les raccourcis inconnus et le lancement automatique de
programmes sont des manifestations typiques d''une infection, le plus souvent
arrivée par une clé USB.

*L''intervention.* Analyser la machine avec un antivirus à jour, mettre les
fichiers détectés en quarantaine, puis nettoyer également la clé USB — faute de
quoi elle réinfectera la machine suivante.
', NULL, 25),
      (v_chapitre_id, 'Simulation : matériel ou logiciel ?', 4, 'interactif', '{
  "widget": "diagnostic-dysfonctionnement",
  "consigne": "Dix pannes te sont décrites avec leurs symptômes, et tu dois d''abord trancher entre matériel et logiciel avant de proposer une cause. La simulation t''oblige à justifier en désignant l''indice décisif, et elle te rappelle le test qui sert de frontière : la machine passe-t-elle la séquence de démarrage et charge-t-elle son système ?"
}', NULL, 10),
      (v_chapitre_id, 'Les risques de la non-protection de l''environnement de travail', 5, 'texte', '
Le programme demande de **présenter quelques risques liés à la non-protection de
l''environnement de travail**. Ils ne concernent pas que les machines.

### Les risques pour le matériel

**La destruction par le courant.** Une surtension grille une alimentation, et
parfois la carte mère avec. Sans protection électrique, c''est une question de
mois, pas d''années.

**L''usure prématurée.** Poussière, chaleur et humidité raccourcissent la durée
de vie de tout le parc.

**Le vol.** Une salle non fermée, des machines non fixées : le risque est réel
et il est rarement cité en copie, alors qu''il est le plus coûteux.

### Les risques pour les données

**La perte**, par panne de disque ou par extinction brutale. Un travail non
enregistré disparaît avec le courant.

**L''altération**, par un programme malveillant ou une fausse manipulation.

**Le vol de données** et l''atteinte à la confidentialité : une session laissée
ouverte, un mot de passe collé sous le clavier, et les notes de tout un
établissement circulent.

### Les risques pour les personnes

Le programme de Terminale y tient, et les copies l''oublient.

**L''électrisation**, par un câble dénudé ou une multiprise surchargée.

**L''incendie**, par surcharge électrique.

**La chute**, par des câbles qui traversent le passage.

**Les troubles liés au poste** : fatigue visuelle devant un écran mal placé,
douleurs du dos et du poignet sur un siège inadapté.

### Les mesures de protection

| Risque | Mesure |
| --- | --- |
| courant | onduleur, régulateur, parasurtenseur, mise à la terre |
| poussière | housses, dépoussiérage régulier, salle propre |
| vol | local fermé, machines fixées, inventaire |
| perte de données | sauvegardes régulières sur un autre support |
| malveillance | antivirus à jour, sessions protégées par mot de passe |
| personnes | câbles rangés, prises aux normes, extincteur, poste réglé |

---

**Exercice corrigé**

*Citer trois risques liés à la non-protection d''une salle informatique, et
donner pour chacun une mesure de protection.*

**Correction.**

**La destruction du matériel par les variations de courant.** Mesure : équiper
la salle d''**onduleurs** et de **régulateurs de tension**, et vérifier la mise
à la terre.

**La perte des données** en cas de panne ou de coupure. Mesure : des
**sauvegardes régulières sur un autre support** — disque externe ou espace en
ligne — et non sur une autre partition du même disque.

**L''électrisation ou l''incendie** par des câbles dénudés et des multiprises
surchargées. Mesure : des **prises aux normes**, des câbles rangés hors du
passage, et un **extincteur** adapté dans la salle.

*On accepte aussi le vol, la poussière, ou la fatigue visuelle — à condition que
la mesure proposée corresponde vraiment au risque cité.*
', NULL, 25),
      (v_chapitre_id, 'Simulation : sécuriser une salle informatique', 6, 'interactif', '{
  "widget": "risques-poste",
  "consigne": "Une salle de quinze postes t''est confiée, avec ses défauts : câbles qui traversent le passage, multiprise surchargée, fenêtre ouverte sur la poussière, aucune sauvegarde, porte sans serrure. Tu disposes d''un budget et d''une liste de mesures. La simulation fait ensuite passer une année sur la salle, avec ses coupures, sa saison des pluies et ses incidents, et te montre ce qui a tenu."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 3', 7, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la première cause de panne matérielle dans un parc informatique au Cameroun ?",
      "choix": [
        "Les chocs",
        "L''instabilité du courant électrique",
        "Les virus",
        "L''usure des ventilateurs"
      ],
      "bonne": 1,
      "explication": "Coupures, retours de courant et surtensions abîment l''alimentation, la carte mère et le disque dur. Les virus, eux, sont une cause logicielle."
    },
    {
      "question": "Une machine s''éteint seule après une heure, surtout en fin d''après-midi. Quelle cause ?",
      "choix": [
        "Un virus",
        "La surchauffe par accumulation de poussière",
        "Un pilote manquant",
        "Un disque plein"
      ],
      "bonne": 1,
      "explication": "Le délai est l''indice : il faut du temps pour que la température monte. Un défaut d''alimentation, lui, serait immédiat."
    },
    {
      "question": "Quel test permet de distinguer une panne matérielle d''une panne logicielle ?",
      "choix": [
        "Regarder la couleur des voyants",
        "Vérifier si la machine passe la séquence de démarrage et charge son système",
        "Peser l''unité centrale",
        "Compter les câbles"
      ],
      "bonne": 1,
      "explication": "Si elle démarre et affiche son bureau, les composants essentiels répondent : il faut chercher du côté logiciel."
    },
    {
      "question": "Quelle est la cause logicielle la plus fréquente, et la moins soupçonnée ?",
      "choix": [
        "Les virus",
        "La mauvaise manipulation de l''utilisateur",
        "L''absence de pilote",
        "Le manque de mises à jour"
      ],
      "bonne": 1,
      "explication": "Fichier système supprimé, désinstallation interrompue, réglage changé au hasard : et l''utilisateur ne s''en rend presque jamais compte."
    },
    {
      "question": "Parmi ces risques liés à la non-protection, lequel concerne les personnes ?",
      "choix": [
        "Le vol de données",
        "L''électrisation par un câble dénudé",
        "L''usure prématurée du matériel",
        "L''altération des fichiers"
      ],
      "bonne": 1,
      "explication": "Le programme de Terminale tient aux risques humains — électrisation, incendie, chute, fatigue visuelle — et les copies les oublient."
    },
    {
      "question": "Quelle mesure protège réellement contre la perte de données ?",
      "choix": [
        "Mettre les fichiers sur une autre partition du même disque",
        "Faire des sauvegardes régulières sur un autre support",
        "Installer un onduleur",
        "Changer de système d''exploitation"
      ],
      "bonne": 1,
      "explication": "Une partition n''est pas une sauvegarde : si le disque meurt, les deux partitions meurent avec lui. Il faut un AUTRE support."
    },
    {
      "question": "Quel signe trahit presque à coup sûr une infection ?",
      "choix": [
        "La machine chauffe",
        "L''antivirus se désactive tout seul et refuse de se relancer",
        "Le ventilateur fait du bruit",
        "Le disque est plein"
      ],
      "bonne": 1,
      "explication": "Beaucoup de programmes malveillants commencent par neutraliser l''antivirus. Les trois autres symptômes ont des causes matérielles bien plus probables."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 7 leçons ajoutées au chapitre 3, Les causes des dysfonctionnements matériels et logiciels.', v_nom;
  END LOOP;
END $inf7$;
