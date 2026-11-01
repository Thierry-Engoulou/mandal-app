-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 14, Les chaînes électroniques
-- Module 3 : Électricité, évolutions temporelles des circuits électriques
-- 3 leçons.
--
-- Ce fichier remplit LES DEUX CLASSES a la fois : Terminale C et Terminale D.
-- Autonome : il cree lui-meme la matiere, les classes, les programmes et le
-- chapitre s'ils n'existent pas encore. Lancez-le seul, dans n'importe quel
-- ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $ptc$
DECLARE
  v_noms text[] := ARRAY['Terminale C', 'Terminale D'];
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
  -- la matiere, une seule fois
  INSERT INTO public.matieres (nom) VALUES ('Physique') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Physique';

  -- l'etablissement, deduit de la table des classes
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- on refait le meme travail pour la Terminale C puis pour la Terminale D
  FOR v_i IN 1..2 LOOP
    v_nom := v_noms[v_i];
    v_lettre := v_lettres[v_i];

    -- 1. le programme existe-t-il deja ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Physique — ' || v_nom;

    -- 2. sinon on le cree
    IF v_programme_id IS NULL THEN
      -- la classe, quelle que soit la facon dont elle a ete ecrite
      SELECT id INTO v_classe_id FROM public.classes
      WHERE etablissement_id = v_etab_id
        AND (nom = v_nom OR nom ILIKE 'T%le ' || v_lettre)
      ORDER BY (nom = v_nom) DESC
      LIMIT 1;

      -- si elle n'existe pas, on la cree
      IF v_classe_id IS NULL THEN
        INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
        VALUES (v_etab_id, v_nom, 'Terminale', v_lettre)
        RETURNING id INTO v_classe_id;
        RAISE NOTICE 'Classe "%" creee.', v_nom;
      END IF;

      INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Physique — ' || v_nom,
              'Programme officiel de Physique, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 4 modules, 22 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme "Physique — %" cree.', v_nom;
    END IF;

    -- 3. le chapitre existe-t-il deja ?
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 14;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les chaînes électroniques', 14, 'Module 3 : Électricité, évolutions temporelles des circuits électriques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 14 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 14 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les éléments d''une chaîne électronique', 1, 'texte', 'Un capteur seul ne sert à rien. Pour qu''une grandeur physique produise un effet utile, il faut l''enchaîner à d''autres blocs. L''ensemble s''appelle une chaîne électronique.

## Le schéma général

Toute chaîne électronique suit la même architecture, du début à la fin.

En entrée se trouve le **capteur**, qui transforme la grandeur physique en signal électrique. Ce signal est en général très faible, de l''ordre du millivolt.

Vient ensuite le **conditionneur**, ou étage d''adaptation. Son rôle est de mettre le signal en forme : un pont diviseur transforme une variation de résistance en variation de tension, un pont de Wheatstone améliore la sensibilité.

Puis vient l''**amplificateur**, qui augmente le niveau du signal pour qu''il soit exploitable. On le caractérise par son **gain**
$$A = \dfrac{U_{\text{sortie}}}{U_{\text{entrée}}}$$

Après l''amplification intervient le **traitement**. Ce peut être un filtre qui élimine les parasites, un comparateur qui compare le signal à un seuil, ou un convertisseur analogique-numérique si la suite est gérée par un microcontrôleur.

Enfin vient l''**actionneur**, qui transforme le signal électrique en effet physique visible. C''est un haut-parleur, une lampe, un moteur, un afficheur, une sirène.

## Chaîne ouverte et chaîne fermée

Une chaîne est **ouverte** quand le signal va du capteur à l''actionneur sans retour. Elle est simple, mais elle ne corrige pas ses erreurs.

Une chaîne est **fermée**, ou bouclée, quand on mesure le résultat obtenu et qu''on le compare à la consigne pour ajuster la commande. C''est le principe de l''**asservissement**.

Un fer à repasser avec thermostat est une chaîne fermée : il chauffe, mesure, coupe, et recommence. C''est ce bouclage qui maintient la température stable.

## L''amplificateur opérationnel

L''amplificateur le plus utilisé en Terminale est l''amplificateur opérationnel, souvent appelé AO.

En montage **non inverseur**, le gain vaut
$$A = 1 + \dfrac{R_{2}}{R_{1}}$$

En montage **inverseur**, il vaut
$$A = -\dfrac{R_{2}}{R_{1}}$$

Le signe moins signifie que le signal de sortie est en opposition de phase avec celui d''entrée.

Utilisé sans contre-réaction, l''AO fonctionne en **comparateur** : sa sortie bascule à sa valeur maximale ou minimale selon le signe de la différence de ses deux entrées. C''est ce qui permet de déclencher une action à partir d''un seuil.

## Exercice d''application

Un capteur délivre un signal de $20$ mV. On veut piloter un afficheur qui demande $4{,}0$ V. Quel gain faut-il ? Si on utilise un montage non inverseur avec $R_{1} = 1{,}0\ \text{k}\Omega$, que doit valoir $R_{2}$ ?

Correction. Le gain nécessaire vaut
$$A = \dfrac{4{,}0}{20 \times 10^{-3}} = \dfrac{4{,}0}{0{,}020} = 200$$

Pour un montage non inverseur, $A = 1 + \dfrac{R_{2}}{R_{1}}$, donc
$$\dfrac{R_{2}}{R_{1}} = A - 1 = 199$$

d''où $R_{2} = 199 \times 1{,}0 \times 10^{3} = 199\ \text{k}\Omega$.

En pratique on prendrait une résistance normalisée de $200\ \text{k}\Omega$, ce qui donne un gain de $201$, soit une sortie de $4{,}02$ V. L''écart est négligeable.', NULL, 15),
      (v_chapitre_id, 'Trois chaînes électroniques à connaître', 2, 'texte', 'Voici trois montages classiques du programme. Pour chacun, repère bien les cinq blocs de la chaîne.

## La chaîne microphone, amplificateur, haut-parleur

C''est la sonorisation, celle d''une salle de classe ou d''une église.

Le **microphone** est le capteur. Il transforme l''onde sonore en une tension alternative de quelques millivolts, image fidèle de la pression acoustique.

L''**amplificateur** élève ce signal à plusieurs volts, avec une puissance suffisante pour alimenter un haut-parleur.

Le **haut-parleur** est l''actionneur. Une bobine parcourue par le courant du signal est placée dans l''entrefer d''un aimant. La force de Laplace la fait vibrer, elle entraîne la membrane, et la membrane pousse l''air. Le son est reconstitué.

Remarque la symétrie. Le microphone utilise l''induction pour transformer un son en courant, le haut-parleur utilise la force de Laplace pour transformer un courant en son. Ce sont deux conversions inverses l''une de l''autre.

Si le micro est trop près du haut-parleur, le son amplifié revient dans le micro et le circuit s''emballe. C''est l''effet Larsen, un bouclage involontaire.

## L''indicateur de niveau d''eau

Très utile pour un réservoir ou un forage.

Deux **électrodes** plongent dans le réservoir à la hauteur à surveiller. Quand l''eau les atteint, elle ferme le circuit, car l''eau ordinaire conduit un peu le courant. Les électrodes forment donc le capteur, de type tout ou rien.

Le courant qui passe est minuscule. Un **transistor** l''amplifie, son courant de base provenant des électrodes et son courant de collecteur alimentant la suite.

L''**actionneur** est une lampe, un buzzer ou un relais qui coupe la pompe.

Si tu veux surveiller plusieurs niveaux, tu places plusieurs paires d''électrodes à des hauteurs différentes, chacune avec son propre transistor et sa propre lampe.

## La commande d''une sirène par photorésistance

C''est le principe d''une alarme de passage ou d''un éclairage automatique.

La **photorésistance** est le capteur. Elle est montée en diviseur de tension avec une résistance fixe.

Le **diviseur de tension** est le conditionneur. Il transforme la variation de résistance en variation de tension, comme tu l''as calculé au chapitre précédent.

Un **comparateur** à amplificateur opérationnel compare cette tension à un seuil réglable par un potentiomètre. Tant qu''on est en dessous, la sortie reste basse. Dès qu''on dépasse, elle bascule.

Un **transistor** amplifie alors le courant pour alimenter la **sirène**, qui est l''actionneur.

Le potentiomètre de seuil est essentiel. Sans lui, l''alarme se déclencherait au moindre nuage. Avec lui, on règle finement la sensibilité.

## Exercice d''application

Dans l''indicateur de niveau d''eau, la résistance de l''eau entre les électrodes vaut environ $50\ \text{k}\Omega$ et l''alimentation est de $9{,}0$ V. Le transistor a un gain $\beta = 200$ et la lampe consomme $80$ mA. Vérifie que le montage fonctionne.

Correction. Le courant qui traverse l''eau, et donc la base du transistor, vaut approximativement
$$i_{B} = \dfrac{U}{R_{\text{eau}}} = \dfrac{9{,}0}{50 \times 10^{3}} = 1{,}8 \times 10^{-4}\ \text{A} = 0{,}18\ \text{mA}$$

Le courant de collecteur que le transistor peut alors laisser passer vaut
$$i_{C} = \beta\,i_{B} = 200 \times 0{,}18 = 36\ \text{mA}$$

Or la lampe demande $80$ mA. Le transistor ne peut donc pas la faire briller normalement, elle n''éclairera que faiblement.

Deux solutions. On peut utiliser un transistor de gain plus élevé, il en faudrait un d''au moins $450$. Ou bien, et c''est la solution habituelle, on monte deux transistors en cascade, ce qu''on appelle un montage Darlington : le gain total est alors le produit des deux gains, ce qui donne largement de quoi alimenter la lampe.', NULL, 15),
      (v_chapitre_id, 'Quiz du chapitre 14', 3, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Dans quel ordre se succèdent les blocs d''une chaîne électronique ?",
      "choix": [
        "Actionneur, amplificateur, capteur",
        "Capteur, conditionneur, amplificateur, traitement, actionneur",
        "Amplificateur, capteur, actionneur",
        "Capteur, actionneur, amplificateur"
      ],
      "bonne": 1,
      "explication": "Le signal part toujours du capteur, qui traduit la grandeur physique, et se termine à l''actionneur, qui produit l''effet voulu. Entre les deux, le signal est mis en forme, amplifié puis traité."
    },
    {
      "question": "Un amplificateur non inverseur a $R_1 = 2{,}0$ kΩ et $R_2 = 18$ kΩ. Que vaut son gain ?",
      "choix": [
        "9",
        "10",
        "18",
        "0,9"
      ],
      "bonne": 1,
      "explication": "Pour le montage non inverseur, $A = 1 + R_2/R_1 = 1 + 18/2 = 1 + 9 = 10$. Le 1 vient du montage lui-même, on l''oublie souvent."
    },
    {
      "question": "Qu''est-ce qui distingue une chaîne fermée d''une chaîne ouverte ?",
      "choix": [
        "Elle contient plus de composants",
        "Elle mesure le résultat obtenu pour corriger la commande",
        "Elle fonctionne en courant alternatif",
        "Elle n''a pas d''actionneur"
      ],
      "bonne": 1,
      "explication": "Dans une chaîne fermée, la sortie est renvoyée vers l''entrée et comparée à la consigne. Ce bouclage permet de corriger automatiquement les écarts, c''est le principe de l''asservissement."
    },
    {
      "question": "Dans un haut-parleur, quelle force fait vibrer la membrane ?",
      "choix": [
        "La force de Coulomb",
        "La force de Laplace",
        "La force de gravitation",
        "La poussée d''Archimède"
      ],
      "bonne": 1,
      "explication": "La bobine parcourue par le courant du signal est placée dans le champ d''un aimant permanent. Elle subit donc la force de Laplace, qui la fait vibrer et entraîne la membrane."
    },
    {
      "question": "Pourquoi utilise-t-on un montage Darlington ?",
      "choix": [
        "Pour réduire la tension",
        "Pour multiplier les gains de deux transistors",
        "Pour filtrer les parasites",
        "Pour mesurer la température"
      ],
      "bonne": 1,
      "explication": "Deux transistors en cascade donnent un gain total égal au produit des deux gains. Cela permet de commander une forte charge à partir d''un courant de base très faible, comme celui qui traverse l''eau d''un réservoir."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 14, Les chaînes électroniques — 3 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
