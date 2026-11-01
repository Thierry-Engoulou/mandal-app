-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 13, Dipôles commandés et capteurs
-- Module 3 : Électricité, évolutions temporelles des circuits électriques
-- 4 leçons.
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
    WHERE programme_id = v_programme_id AND ordre = 13;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Dipôles commandés et capteurs', 13, 'Module 3 : Électricité, évolutions temporelles des circuits électriques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 13 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 13 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Capteurs et dipôles commandés', 1, 'texte', 'Un thermomètre électronique, un détecteur de fumée, l''écran tactile de ton téléphone : tous reposent sur des composants capables de traduire une grandeur physique en grandeur électrique.

## Le dipôle commandé

Un **dipôle commandé** est un dipôle dont la caractéristique électrique peut être modifiée par une action extérieure.

Cette action peut être **manuelle**, comme la molette d''un rhéostat qu''on tourne à la main.

Elle peut être **électrique**, comme un relais qu''un petit courant fait basculer, ou un transistor dont le courant de base commande le courant de collecteur.

Elle peut enfin être **physique**, comme une thermistance dont la résistance change avec la température. Dans ce dernier cas, le dipôle commandé est aussi un capteur.

## Le capteur

Un **capteur** est un dispositif qui transforme une grandeur physique, dite grandeur d''entrée, en une grandeur électrique exploitable, dite grandeur de sortie.

La grandeur d''entrée peut être une température, une pression, un éclairement, une force, une position, un son.

La grandeur de sortie est une tension, un courant, une résistance ou une capacité.

## Capteurs actifs et capteurs passifs

Un capteur est **actif** quand il produit lui-même une tension ou un courant, sans avoir besoin d''alimentation. Il convertit directement l''énergie captée en énergie électrique.

La cellule photovoltaïque est active : éclairée, elle délivre une tension. Le thermocouple est actif : chauffé, il crée une force électromotrice. Le microphone dynamique et le capteur piézoélectrique le sont aussi.

Un capteur est **passif** quand il se contente de faire varier une résistance, une capacité ou une inductance. Il ne produit rien tout seul, il faut donc l''insérer dans un circuit alimenté.

La thermistance est passive, la photorésistance aussi, les jauges de contrainte également.

## La sensibilité et la linéarité

La **sensibilité** d''un capteur est le rapport entre la variation de la sortie et la variation de l''entrée :
$$s = \dfrac{\Delta s_{\text{sortie}}}{\Delta e_{\text{entrée}}}$$

Un capteur est **linéaire** quand sa sortie est proportionnelle à son entrée. C''est le cas idéal, car l''étalonnage est alors immédiat.

Beaucoup de capteurs réels ne sont pas linéaires. On les utilise quand même, soit sur une plage restreinte où la courbe est presque droite, soit en corrigeant par le calcul.

## Les principaux dipôles commandés

Le **rhéostat** est une résistance variable commandée à la main. Sa caractéristique courant-tension reste une droite, mais sa pente change.

Le **relais électromagnétique** est un interrupteur commandé par un électroaimant. Un courant faible dans la bobine attire une palette qui ferme un contact de puissance. Son grand intérêt est l''**isolation galvanique** : le circuit de commande et le circuit de puissance ne sont pas reliés électriquement. On commande ainsi un moteur de $220$ V avec une carte électronique de $5$ V, sans danger.

La **VDR**, ou varistance, est une résistance qui s''effondre quand la tension dépasse un seuil. Elle sert à protéger les appareils contre la foudre et les surtensions.

La **diode Zener** laisse passer le courant en sens direct comme une diode ordinaire, mais en sens inverse elle devient conductrice dès que la tension dépasse sa tension Zener $U_{Z}$. Elle maintient alors cette tension constante, ce qui en fait un excellent **régulateur de tension**.

Le **transistor** est le composant roi de l''électronique. Un petit courant de base $i_{B}$ commande un courant de collecteur $i_{C}$ beaucoup plus grand, avec
$$i_{C} = \beta\,i_{B}$$
où $\beta$ est le gain en courant, souvent de l''ordre de $100$. Le transistor sert soit d''amplificateur, soit d''interrupteur commandé.

## Exercice d''application

Un transistor de gain $\beta = 150$ est utilisé en interrupteur pour allumer une lampe qui consomme $300$ mA. Quel courant de base faut-il au minimum ? Pourquoi ne pas brancher la lampe directement sur la sortie de la carte électronique qui délivre au maximum $5$ mA ?

Correction. Le courant de base nécessaire vaut
$$i_{B} = \dfrac{i_{C}}{\beta} = \dfrac{300}{150} = 2{,}0\ \text{mA}$$

La carte peut fournir $5$ mA, donc $2{,}0$ mA sont largement disponibles. Le transistor fonctionnera.

On ne peut pas brancher la lampe directement, car elle demande $300$ mA alors que la carte n''en fournit que $5$. La sortie serait détruite. Le transistor sert donc d''amplificateur de courant : il prend $2$ mA à la carte et laisse passer $300$ mA venus de l''alimentation de puissance.', NULL, 15),
      (v_chapitre_id, 'Quelques capteurs courants', 2, 'texte', 'Voici les capteurs que tu dois savoir reconnaître et expliquer. Pour chacun, demande-toi quelle grandeur il mesure et par quel mécanisme.

## La thermistance, capteur de température

Une thermistance est une résistance dont la valeur dépend fortement de la température.

Les **CTN**, à coefficient de température négatif, voient leur résistance **diminuer** quand la température monte. Ce sont les plus courantes.

Les **CTP**, à coefficient positif, font l''inverse.

La loi est de la forme
$$R(T) = R_{0}\,e^{B\left(\frac{1}{T} - \frac{1}{T_{0}}\right)}$$

Elle n''est donc pas du tout linéaire, mais la sensibilité est excellente. On trouve des thermistances dans les thermomètres médicaux électroniques et dans les thermostats de réfrigérateur.

Le **thermocouple**, lui, est un capteur actif. Deux métaux différents soudés produisent une petite force électromotrice qui dépend de la température de la soudure. Il monte à des températures très élevées, ce qui le rend indispensable dans les fours industriels.

## La photorésistance, capteur de lumière

Une **photorésistance**, ou LDR, est faite d''un semi-conducteur dont la résistance **diminue** quand l''éclairement augmente. Dans le noir elle peut valoir plusieurs mégohms, en plein soleil quelques centaines d''ohms.

Elle est lente, mais simple et bon marché. On la trouve dans les lampadaires qui s''allument au crépuscule.

La **photodiode** est une diode polarisée en inverse dont le courant inverse est proportionnel à l''éclairement. Elle est beaucoup plus rapide que la LDR, ce qui la rend utilisable pour les télécommandes et les transmissions par fibre optique.

La **cellule photovoltaïque** est un capteur actif. Elle produit directement une tension sous l''effet de la lumière, et c''est le composant des panneaux solaires qui équipent de plus en plus de maisons au Cameroun.

## Les capteurs d''ondes

L''**antenne** capte les ondes électromagnétiques. Le champ électrique de l''onde met en mouvement les électrons du métal, ce qui crée une petite tension alternative à la même fréquence que l''onde. C''est un capteur actif.

Le **microphone** capte les ondes sonores. Dans un microphone **électrodynamique**, la membrane entraîne une bobine qui se déplace dans un champ magnétique. Par induction, une tension apparaît, image du son. C''est encore un capteur actif, et il fonctionne exactement comme un haut-parleur à l''envers.

Dans un microphone **électrostatique**, la membrane est une armature de condensateur. Le son la fait vibrer, donc la distance entre armatures varie, donc la capacité varie. Celui-là est passif, il lui faut une alimentation.

## Le capteur de pression

Un capteur de pression courant utilise une **jauge de contrainte** collée sur une membrane. Quand la pression déforme la membrane, le fil de la jauge s''allonge et s''amincit, donc sa résistance augmente.

On monte généralement quatre jauges en pont de Wheatstone, ce qui augmente la sensibilité et compense les effets de la température.

On trouve ces capteurs dans les tensiomètres, les altimètres et les systèmes de surveillance de pression des pneus.

## Exercice d''application

Une photorésistance est montée en série avec une résistance $R = 10\ \text{k}\Omega$ sous une tension de $5{,}0$ V. Dans l''obscurité la LDR vaut $1{,}0\ \text{M}\Omega$, en pleine lumière elle vaut $500\ \Omega$. Calcule la tension aux bornes de $R$ dans les deux cas. Ce montage peut-il commander un circuit qui bascule à $2{,}5$ V ?

Correction. C''est un diviseur de tension, donc
$$U_{R} = E \times \dfrac{R}{R + R_{\text{LDR}}}$$

Dans l''obscurité,
$$U_{R} = 5{,}0 \times \dfrac{10 \times 10^{3}}{10 \times 10^{3} + 1{,}0 \times 10^{6}} = 5{,}0 \times \dfrac{10^{4}}{1{,}01 \times 10^{6}} \approx 0{,}050\ \text{V}$$

En pleine lumière,
$$U_{R} = 5{,}0 \times \dfrac{10 \times 10^{3}}{10 \times 10^{3} + 500} = 5{,}0 \times \dfrac{10000}{10500} \approx 4{,}8\ \text{V}$$

La tension passe donc de $0{,}05$ V à $4{,}8$ V, et elle traverse bien le seuil de $2{,}5$ V. Le montage convient parfaitement pour commander un éclairage automatique.', NULL, 15),
      (v_chapitre_id, 'Explore la caractéristique d''un capteur', 3, 'interactif', '{
  "widget": "capteur-caracteristique",
  "consigne": "Choisis un capteur, puis fais varier la grandeur physique d''entrée et observe sa sortie. Compare une thermistance CTN et une photorésistance : laquelle est linéaire ? Trouve ensuite le seuil d''éclairement qui fait basculer le montage à diviseur de tension."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 13', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Qu''est-ce qui distingue un capteur actif d''un capteur passif ?",
      "choix": [
        "L''actif est plus précis",
        "L''actif produit lui-même une tension, le passif fait seulement varier une résistance",
        "L''actif est plus rapide",
        "Le passif ne fonctionne qu''en courant continu"
      ],
      "bonne": 1,
      "explication": "Un capteur actif convertit directement l''énergie captée en énergie électrique, comme une cellule photovoltaïque. Un capteur passif modifie seulement une grandeur du circuit, il doit donc être alimenté."
    },
    {
      "question": "La résistance d''une thermistance CTN quand la température augmente :",
      "choix": [
        "augmente",
        "diminue",
        "ne change pas",
        "devient nulle"
      ],
      "bonne": 1,
      "explication": "CTN signifie coefficient de température négatif : la résistance diminue quand la température monte. Ce sont les plus courantes dans les thermomètres électroniques."
    },
    {
      "question": "Quel est le principal intérêt d''un relais électromagnétique ?",
      "choix": [
        "Il amplifie la tension",
        "Il isole électriquement la commande de la puissance",
        "Il mesure la température",
        "Il redresse le courant"
      ],
      "bonne": 1,
      "explication": "L''isolation galvanique permet de commander un circuit de 220 V avec une carte de 5 V sans aucune liaison électrique entre les deux. C''est un avantage décisif pour la sécurité."
    },
    {
      "question": "Un transistor de gain 100 reçoit un courant de base de 1,5 mA. Quel courant de collecteur peut-il laisser passer ?",
      "choix": [
        "1,5 mA",
        "15 mA",
        "150 mA",
        "1,5 A"
      ],
      "bonne": 2,
      "explication": "La relation est $i_C = \\beta i_B = 100 \\times 1{,}5 = 150$ mA. Le transistor amplifie donc le courant d''un facteur 100, ce qui permet de commander une charge de puissance avec un signal faible."
    },
    {
      "question": "À quoi sert une diode Zener dans un circuit ?",
      "choix": [
        "À mesurer une température",
        "À maintenir une tension constante",
        "À amplifier un courant",
        "À détecter la lumière"
      ],
      "bonne": 1,
      "explication": "En polarisation inverse, la diode Zener maintient à ses bornes une tension pratiquement constante, égale à sa tension Zener. C''est la base de tous les régulateurs de tension simples."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 13, Dipôles commandés et capteurs — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
