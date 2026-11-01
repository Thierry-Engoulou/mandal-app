-- ---------------------------------------------------------------------------
-- M'Andal — Informatique, classes de Première
-- Chapitre 5 : Les pannes matérielles et logicielles
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
    WHERE programme_id = v_programme_id AND ordre = 5;

    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les pannes matérielles et logicielles', 5, 'Module 1 : Maintenance informatique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 5 créé.', v_nom;
    END IF;

    -- Les leçons. Si le chapitre en a déjà, on passe son tour sans rien toucher.
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : le chapitre 5 a déjà ses % leçons, je n''y touche pas.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les causes matérielles des pannes', 1, 'texte', '
Un technicien ne devine pas : il connaît les causes habituelles et les vérifie
dans l''ordre. Au Cameroun, trois d''entre elles expliquent la grande majorité
des pannes matérielles.

### L''instabilité du courant électrique

C''est la première cause, et de loin. Les coupures brutales, les retours de
courant, les surtensions abîment l''alimentation, la carte mère et le disque dur.

Trois appareils protègent, et il faut savoir lequel fait quoi :

| Appareil | Ce qu''il fait |
| --- | --- |
| le **régulateur de tension** | ramène la tension à sa valeur normale quand elle monte ou descend |
| le **parasurtenseur** | absorbe les pointes brutales de tension, la foudre par exemple |
| l''**onduleur** (en anglais *UPS*) | contient une batterie : il continue à alimenter l''ordinateur pendant la coupure, le temps d''enregistrer et d''éteindre proprement |

L''onduleur est le seul des trois qui **fait face à une coupure**. C''est pour
cela qu''on le demande presque toujours en examen.

### La poussière

Elle s''accumule sur le ventilateur et les grilles d''aération. Le processeur ne
se refroidit plus, la machine chauffe, elle s''éteint seule ou ralentit.

On la combat avec un **souffleur** — ou une bombe à air sec — et on l''empêche de
revenir avec une **nappe** ou une housse de protection quand la machine ne sert
pas.

### Les chocs, la chaleur et l''humidité

Un disque dur mécanique en marche ne supporte pas d''être déplacé brusquement.
Une salle sans ventilation fatigue tout le matériel. L''humidité de la saison des
pluies oxyde les contacts.

---

**Exercice corrigé**

*Dans une salle informatique, les ordinateurs s''éteignent tout seuls après une
heure de travail, et le problème s''aggrave en fin d''après-midi. Quelle est la
cause la plus probable ?*

**Correction.** La **surchauffe**, par accumulation de poussière dans les
ventilateurs et les grilles.

Deux indices le disent. D''abord **après une heure** : il faut du temps pour que
la température monte, ce qui exclut un problème d''alimentation, qui serait
immédiat. Ensuite **en fin d''après-midi** : la salle est déjà chaude, le seuil
est atteint plus vite.

L''intervention : souffler les ventilateurs et les grilles, vérifier que rien ne
bouche l''aération, et améliorer la ventilation de la salle.
', NULL, 24),
      (v_chapitre_id, 'Simulation : protéger une salle informatique', 2, 'interactif', '{
  "widget": "protection-electrique",
  "consigne": "Tu équipes une salle de six postes avec un budget limité, en choisissant entre régulateur, parasurtenseur et onduleur. La simulation envoie ensuite une série d''incidents — une baisse de tension, un coup de foudre, une coupure de deux minutes — et te montre quels postes survivent et lesquels perdent leurs données. Tu verras vite pourquoi l''onduleur n''a pas de remplaçant."
}', NULL, 10),
      (v_chapitre_id, 'Les causes logicielles et le diagnostic', 3, 'texte', '
### Les causes logicielles

Quand le matériel est sain, le problème est ailleurs. Quatre causes couvrent
presque tout.

Un **virus**, ou un autre programme malveillant. On en fait tout un chapitre
juste après.

L''**absence de pilote**, ou un mauvais pilote. Souviens-toi du chapitre 3 : sans
son pilote, un périphérique est inutilisable même parfaitement branché. C''est le
cas classique du son qui ne marche plus après une réinstallation.

L''**absence de mise à jour**. Un système non mis à jour accumule des failles et
des incompatibilités.

Une **mauvaise manipulation** de l''utilisateur : un fichier système supprimé, une
désinstallation interrompue, un réglage changé au hasard.

### La méthode de diagnostic

Un bon technicien suit toujours le même ordre, du plus simple au plus
compliqué :

1. **Observer** — qu''est-ce qui se passe exactement ? Des voyants ? Des bips ?
Un écran noir, ou un écran avec un message ?
2. **Questionner l''utilisateur** — que faisiez-vous juste avant ? Qu''est-ce qui
a changé depuis la dernière fois où ça marchait ?
3. **Vérifier l''évident** — le câble d''alimentation, la prise, l''interrupteur de
l''alimentation, le câble de l''écran.
4. **Isoler** : matériel ou logiciel ? Si la machine passe la séquence POST,
le matériel essentiel va bien, et le problème est logiciel.
5. **Tester une seule hypothèse à la fois.** Si tu changes trois choses
ensemble et que ça marche, tu ne sauras jamais laquelle était en cause.

### La boîte à outils

**Les outils matériels** : tournevis plat et cruciforme, pince, **souffleur**,
**bracelet antistatique** — il évacue l''électricité statique de ton corps, qui
suffirait à griller un composant —, fer à souder, étain, pompe à dessouder,
**multimètre** pour mesurer les tensions.

**Les outils logiciels** : un antivirus à jour, des programmes de détection et
de réparation, une **clé de démarrage** amorçable pour accéder à une machine qui
ne démarre plus, et les CD ou images d''installation du système et des pilotes.

---

**Exercice corrigé**

*Vous appuyez sur le bouton d''un ordinateur : rien ne se passe, aucun voyant,
aucun bruit de ventilateur. Quel est le premier élément à vérifier ?*

**Correction.** Le **câble d''alimentation** : son branchement sur la machine,
son branchement sur la prise, l''état de la prise, et l''interrupteur à l''arrière
du bloc d''alimentation.

Pourquoi en premier ? Parce que **aucun voyant et aucun bruit** signifie que le
courant n''arrive pas du tout. Si l''alimentation fonctionnait, tu aurais au
minimum un voyant ou un ventilateur qui tourne, même avec une carte mère morte.

Et parce que c''est la vérification la moins chère et la plus rapide. On ne
démonte jamais une machine avant d''avoir vérifié qu''elle est branchée.
', NULL, 25),
      (v_chapitre_id, 'Simulation : diagnostiquer une panne', 4, 'interactif', '{
  "widget": "diagnostic-panne",
  "consigne": "Six machines en panne t''attendent, chacune avec ses symptômes : écran noir sans voyant, bips au démarrage, démarrage qui s''arrête avant le bureau, machine très lente, pas de son. Tu choisis tes vérifications une par une et la simulation te donne le résultat de chacune — en comptant combien de vérifications tu as utilisées. Le but n''est pas de trouver, c''est de trouver vite."
}', NULL, 10),
      (v_chapitre_id, 'Simulation : la boîte à outils', 5, 'interactif', '{
  "widget": "boite-outils",
  "consigne": "Une intervention est annoncée, et tu dois remplir ta sacoche avant de partir. Choisis parmi une quinzaine d''outils, matériels et logiciels. Sur place, la simulation te met en situation : s''il te manque le bracelet antistatique au moment de toucher la barrette de mémoire, ou la clé amorçable devant une machine qui ne démarre pas, tu le sauras."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 5', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la première cause de panne matérielle dans un parc informatique au Cameroun ?",
      "choix": [
        "Les chocs",
        "L''instabilité du courant électrique",
        "L''humidité",
        "Les virus"
      ],
      "bonne": 1,
      "explication": "Coupures brutales, retours de courant et surtensions abîment l''alimentation, la carte mère et le disque dur. Les virus, eux, sont une cause logicielle."
    },
    {
      "question": "Quel appareil permet de continuer à travailler pendant une coupure de courant ?",
      "choix": [
        "Le régulateur de tension",
        "Le parasurtenseur",
        "L''onduleur",
        "Le multimètre"
      ],
      "bonne": 2,
      "explication": "Lui seul contient une batterie. Le régulateur corrige la tension, le parasurtenseur absorbe les pointes, mais ni l''un ni l''autre ne survit à une coupure."
    },
    {
      "question": "Une machine s''éteint toute seule après une heure de travail. La cause la plus probable est :",
      "choix": [
        "Un virus",
        "La surchauffe par accumulation de poussière",
        "Un pilote manquant",
        "Un câble d''alimentation défectueux"
      ],
      "bonne": 1,
      "explication": "Le délai est l''indice : il faut du temps pour que la température monte. Un problème d''alimentation, lui, serait immédiat."
    },
    {
      "question": "À quoi sert un bracelet antistatique ?",
      "choix": [
        "À protéger le technicien de l''électrocution",
        "À évacuer l''électricité statique du corps, qui pourrait griller un composant",
        "À mesurer la tension",
        "À fixer les câbles"
      ],
      "bonne": 1,
      "explication": "La décharge statique de ton corps suffit à détruire une barrette de mémoire ou un processeur, sans que tu sentes quoi que ce soit."
    },
    {
      "question": "Vous appuyez sur le bouton : aucun voyant, aucun bruit. Que vérifiez-vous en premier ?",
      "choix": [
        "Le disque dur",
        "Le câble d''alimentation et la prise",
        "La barrette de mémoire",
        "Le système d''exploitation"
      ],
      "bonne": 1,
      "explication": "Aucun voyant et aucun bruit signifie que le courant n''arrive pas du tout. On ne démonte jamais une machine avant d''avoir vérifié qu''elle est branchée."
    },
    {
      "question": "La machine passe la séquence POST mais n''arrive pas au bureau. Que peut-on en déduire ?",
      "choix": [
        "Le matériel essentiel va bien, le problème est logiciel",
        "La carte mère est morte",
        "L''alimentation est défaillante",
        "La mémoire vive est absente"
      ],
      "bonne": 0,
      "explication": "Le POST teste le matériel. S''il passe, c''est que les composants essentiels répondent : il faut chercher du côté du système d''exploitation."
    },
    {
      "question": "Pourquoi ne faut-il tester qu''une seule hypothèse à la fois ?",
      "choix": [
        "Pour gagner du temps",
        "Parce que si on change trois choses ensemble et que ça marche, on ne sait pas laquelle était en cause",
        "Pour économiser les pièces",
        "Parce que c''est plus prudent pour le matériel"
      ],
      "bonne": 1,
      "explication": "C''est la règle de base du diagnostic. Une panne résolue sans qu''on sache pourquoi reviendra."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : 6 leçons ajoutées au chapitre 5, Les pannes matérielles et logicielles.', v_nom;
  END LOOP;
END $inf1$;
