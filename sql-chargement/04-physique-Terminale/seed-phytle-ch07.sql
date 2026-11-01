-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 7, Mouvements dans un champ uniforme
-- Module 2 : Mouvements et interactions, évolutions temporelles des systèmes mécaniques
-- 6 leçons.
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
    WHERE programme_id = v_programme_id AND ordre = 7;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Mouvements dans un champ uniforme', 7, 'Module 2 : Mouvements et interactions, évolutions temporelles des systèmes mécaniques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 7 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 7 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Position, vitesse et accélération', 1, 'texte', 'Avant d''étudier un mouvement, il faut savoir le décrire. Trois vecteurs suffisent, et ils se déduisent l''un de l''autre par dérivation.

## Le vecteur position

Dans un repère $(O, \vec{i}, \vec{j})$, le point $M$ est repéré par
$$\overrightarrow{OM} = x(t)\,\vec{i} + y(t)\,\vec{j}$$

Les fonctions $x(t)$ et $y(t)$ s''appellent les **équations horaires** du mouvement.

## Le vecteur vitesse

Il est la dérivée du vecteur position par rapport au temps.
$$\vec{v} = \dfrac{d\overrightarrow{OM}}{dt} = \dot{x}\,\vec{i} + \dot{y}\,\vec{j}$$

Sa valeur vaut $v = \sqrt{\dot{x}^{2} + \dot{y}^{2}}$.

Le vecteur vitesse est toujours **tangent à la trajectoire** et orienté dans le sens du mouvement. Retiens-le, c''est utilisé dans tous les exercices.

## Le vecteur accélération

Il est la dérivée du vecteur vitesse.
$$\vec{a} = \dfrac{d\vec{v}}{dt} = \ddot{x}\,\vec{i} + \ddot{y}\,\vec{j}$$

Contrairement à la vitesse, l''accélération n''est pas tangente à la trajectoire. Elle est toujours tournée vers l''**intérieur** de la courbure.

## Dans la base de Frenet

Pour un mouvement curviligne, on décompose l''accélération sur deux directions. Le vecteur $\vec{u}_{T}$ est tangent, le vecteur $\vec{u}_{N}$ est normal et dirigé vers le centre de courbure.
$$\vec{a} = \dfrac{dv}{dt}\,\vec{u}_{T} + \dfrac{v^{2}}{\rho}\,\vec{u}_{N}$$

La composante tangentielle $\dfrac{dv}{dt}$ fait varier la **valeur** de la vitesse. La composante normale $\dfrac{v^{2}}{\rho}$, où $\rho$ est le rayon de courbure, fait varier sa **direction**.

Cette décomposition explique tout. Un mouvement rectiligne uniforme a les deux composantes nulles. Un mouvement circulaire uniforme n''a que la composante normale. Un freinage en ligne droite n''a que la composante tangentielle.

## Les mouvements rectilignes à connaître

Pour un mouvement **rectiligne uniforme**, $a = 0$, $v$ est constante et $x = vt + x_{0}$.

Pour un mouvement **rectiligne uniformément varié**, $a$ est constante, et
$$v = at + v_{0} \qquad x = \dfrac{1}{2}at^{2} + v_{0}t + x_{0}$$

Il existe une relation très utile qui ne contient pas le temps :
$$v^{2} - v_{0}^{2} = 2a(x - x_{0})$$

Sers-t''en chaque fois qu''un exercice te donne des distances et des vitesses sans parler de durée.

Le mouvement est accéléré quand $\vec{v}$ et $\vec{a}$ ont le même sens, et retardé quand ils sont de sens contraires.

## Exercice d''application

Une moto démarre et atteint $90$ km/h en $8{,}0$ s, avec une accélération constante. Calcule cette accélération, puis la distance parcourue pendant cette phase.

Correction. Convertissons d''abord : $90$ km/h $= \dfrac{90}{3{,}6} = 25$ m/s.

L''accélération vaut
$$a = \dfrac{v - v_{0}}{t} = \dfrac{25 - 0}{8{,}0} = 3{,}1\ \text{m/s}^{2}$$

Pour la distance, on peut utiliser $x = \dfrac{1}{2}at^{2}$, soit $x = 0{,}5 \times 3{,}125 \times 64 = 100$ m.

On peut aussi vérifier avec la relation sans le temps : $v^{2} = 2ax$ donne $x = \dfrac{625}{2 \times 3{,}125} = 100$ m. Les deux méthodes concordent.', NULL, 15),
      (v_chapitre_id, 'Chute libre et mouvement d''un projectile', 2, 'texte', 'Un ballon qu''on lance, une pierre qu''on jette, un obus de mortier : tous suivent la même loi, parce que la seule force qui agit sur eux est leur poids.

## La chute libre

Un corps est en **chute libre** quand il n''est soumis qu''à son poids. On néglige donc la résistance de l''air.

La deuxième loi de Newton donne $m\vec{g} = m\vec{a}$, d''où
$$\vec{a} = \vec{g}$$

La masse disparaît. C''est le résultat de Galilée : dans le vide, une plume et une bille tombent exactement à la même vitesse.

## Le mouvement d''un projectile

Un projectile est lancé du point $O$ avec une vitesse initiale $\vec{v}_{0}$ faisant un angle $\alpha$ avec l''horizontale. On prend un repère avec $Ox$ horizontal et $Oy$ vertical ascendant.

Les composantes initiales sont $v_{0x} = v_{0}\cos\alpha$ et $v_{0y} = v_{0}\sin\alpha$.

L''accélération est $\vec{a} = -g\,\vec{j}$, donc $a_{x} = 0$ et $a_{y} = -g$.

En intégrant une première fois,
$$v_{x} = v_{0}\cos\alpha \qquad v_{y} = -gt + v_{0}\sin\alpha$$

En intégrant une seconde fois,
$$x = (v_{0}\cos\alpha)\,t \qquad y = -\dfrac{1}{2}gt^{2} + (v_{0}\sin\alpha)\,t$$

Retiens le principe : horizontalement le mouvement est **uniforme**, verticalement il est **uniformément varié**. Les deux sont indépendants.

## L''équation de la trajectoire

Pour obtenir $y$ en fonction de $x$, on tire $t = \dfrac{x}{v_{0}\cos\alpha}$ de la première équation et on reporte dans la seconde :
$$y = -\dfrac{g}{2v_{0}^{2}\cos^{2}\alpha}\,x^{2} + x\tan\alpha$$

C''est une **parabole**, puisque c''est une fonction du second degré en $x$.

## Les trois grandeurs qu''on demande toujours

La **flèche** est la hauteur maximale. Elle est atteinte quand $v_{y} = 0$, c''est-à-dire à la date $t_{s} = \dfrac{v_{0}\sin\alpha}{g}$. En reportant,
$$y_{\max} = \dfrac{v_{0}^{2}\sin^{2}\alpha}{2g}$$

La **portée** est la distance horizontale au retour au sol. On la trouve en cherchant le second $x$ pour lequel $y = 0$ :
$$x_{P} = \dfrac{v_{0}^{2}\sin 2\alpha}{g}$$

La **durée du vol** vaut $t_{v} = \dfrac{2v_{0}\sin\alpha}{g}$, soit le double du temps de montée.

La portée est maximale quand $\sin 2\alpha = 1$, c''est-à-dire pour $\alpha = 45°$. C''est pour cela qu''on lance un javelot ou un poids à environ quarante-cinq degrés.

## Exercice d''application

Un joueur frappe un ballon avec une vitesse initiale de $20$ m/s faisant un angle de $30°$ avec le sol. Calcule la flèche, la portée et la durée du vol. On prend $g = 10$ m/s².

Correction. On a $v_{0} = 20$ m/s et $\alpha = 30°$, donc $\sin 30° = 0{,}5$ et $\sin 60° = 0{,}866$.

La flèche vaut
$$y_{\max} = \dfrac{20^{2} \times 0{,}5^{2}}{2 \times 10} = \dfrac{400 \times 0{,}25}{20} = 5{,}0\ \text{m}$$

La portée vaut
$$x_{P} = \dfrac{20^{2} \times \sin 60°}{10} = \dfrac{400 \times 0{,}866}{10} \approx 34{,}6\ \text{m}$$

La durée du vol vaut
$$t_{v} = \dfrac{2 \times 20 \times 0{,}5}{10} = 2{,}0\ \text{s}$$

Vérifions la cohérence : en $2{,}0$ s, la composante horizontale $v_{0}\cos 30° = 17{,}3$ m/s parcourt $34{,}6$ m. C''est bien la portée trouvée.', NULL, 15),
      (v_chapitre_id, 'Règle ton tir', 3, 'interactif', '{
  "widget": "tir-projectile",
  "consigne": "Change la vitesse initiale et l''angle de tir, et regarde la parabole se déformer. Trouve l''angle qui donne la plus grande portée. Essaie ensuite deux angles différents qui donnent exactement la même portée : que remarques-tu sur leur somme ?"
}', NULL, 10),
      (v_chapitre_id, 'Particule chargée dans un champ électrique uniforme', 4, 'texte', 'Le mouvement d''un électron entre deux plaques chargées ressemble étrangement à celui d''un ballon lancé. C''est normal : dans les deux cas, la force est constante.

## L''accélération d''une particule chargée

Une particule de charge $q$ et de masse $m$ placée dans un champ uniforme $\vec{E}$ subit la force $\vec{F} = q\vec{E}$.

Le poids est en général totalement négligeable. Pour un électron dans un champ de $10^{4}$ V/m, la force électrique vaut $1{,}6 \times 10^{-15}$ N alors que le poids vaut $8{,}9 \times 10^{-30}$ N. Le rapport dépasse $10^{14}$.

La deuxième loi de Newton donne donc
$$\vec{a} = \dfrac{q\vec{E}}{m}$$

L''accélération est constante, comme $\vec{g}$ en chute libre. Toutes les formules du projectile se transposent, à condition de remplacer $g$ par $\dfrac{|q|E}{m}$.

## L''accélération d''une particule, cas du mouvement rectiligne

Si la particule part sans vitesse initiale, ou avec une vitesse parallèle au champ, le mouvement est rectiligne uniformément varié.

Le théorème de l''énergie cinétique donne directement la vitesse acquise sous une tension $U$ :
$$\dfrac{1}{2}mv^{2} - \dfrac{1}{2}mv_{0}^{2} = |q|\,U$$

Si la particule part du repos,
$$v = \sqrt{\dfrac{2|q|U}{m}}$$

C''est le principe du canon à électrons des anciens téléviseurs et des microscopes électroniques.

## La déviation, cas du mouvement parabolique

C''est le cas le plus demandé à l''examen. Une particule entre en $O$ avec une vitesse $\vec{v}_{0}$ horizontale, entre deux plaques de longueur $\ell$ distantes de $d$, soumises à la tension $U$.

Le champ est vertical, de valeur $E = \dfrac{U}{d}$.

Horizontalement rien ne freine : $x = v_{0}t$.

Verticalement l''accélération vaut $a = \dfrac{|q|E}{m} = \dfrac{|q|U}{md}$, donc $y = \dfrac{1}{2}at^{2}$.

En éliminant $t$, on obtient l''équation de la trajectoire :
$$y = \dfrac{|q|\,U}{2\,m\,d\,v_{0}^{2}}\;x^{2}$$

C''est encore une parabole.

## La déviation à la sortie des plaques

À la sortie, en $x = \ell$, la déviation verticale vaut
$$y_{S} = \dfrac{|q|\,U\,\ell^{2}}{2\,m\,d\,v_{0}^{2}}$$

Au-delà des plaques il n''y a plus de champ, donc plus de force. La particule repart en **ligne droite**, selon la tangente à la parabole au point de sortie. C''est ce segment rectiligne qui va frapper l''écran.

Pour que la particule sorte sans heurter une plaque, il faut $y_{S} < \dfrac{d}{2}$. Cette condition est très souvent demandée.

## Exercice d''application

Un électron pénètre avec une vitesse $v_{0} = 2{,}0 \times 10^{7}$ m/s entre deux plaques de longueur $\ell = 8{,}0$ cm distantes de $d = 4{,}0$ cm, soumises à une tension $U = 200$ V. Calcule sa déviation à la sortie. Sort-il des plaques ? On donne $m = 9{,}1 \times 10^{-31}$ kg et $e = 1{,}6 \times 10^{-19}$ C.

Correction. Appliquons la formule
$$y_{S} = \dfrac{e\,U\,\ell^{2}}{2\,m\,d\,v_{0}^{2}}$$

Le numérateur vaut $1{,}6 \times 10^{-19} \times 200 \times (0{,}080)^{2} = 1{,}6 \times 10^{-19} \times 200 \times 6{,}4 \times 10^{-3} = 2{,}048 \times 10^{-19}$.

Le dénominateur vaut $2 \times 9{,}1 \times 10^{-31} \times 0{,}040 \times (2{,}0 \times 10^{7})^{2}$, soit $7{,}28 \times 10^{-32} \times 4{,}0 \times 10^{14} = 2{,}912 \times 10^{-17}$.

Donc $y_{S} = \dfrac{2{,}048 \times 10^{-19}}{2{,}912 \times 10^{-17}} \approx 7{,}0 \times 10^{-3}$ m, soit environ $0{,}70$ cm.

La condition de sortie est $y_{S} < \dfrac{d}{2} = 2{,}0$ cm. Comme $0{,}70 < 2{,}0$, l''électron sort bien des plaques sans les toucher.

Remarque la sensibilité du résultat. Si l''électron entrait quatre fois plus lentement, la déviation serait multipliée par seize et il heurterait la plaque. C''est pourquoi un canon à électrons doit d''abord accélérer fortement les particules avant de les dévier.', NULL, 15),
      (v_chapitre_id, 'Dévie un électron entre deux plaques', 5, 'interactif', '{
  "widget": "deviation-electrique",
  "consigne": "Modifie la tension, la vitesse d''entrée et l''écartement des plaques. Observe la parabole entre les plaques et la ligne droite après la sortie. Trouve la tension à partir de laquelle l''électron heurte la plaque."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 7', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Pour un projectile lancé en l''air sans frottement, que vaut l''accélération horizontale ?",
      "choix": [
        "$g$",
        "Zéro",
        "$g\\cos\\alpha$",
        "Elle diminue au cours du vol"
      ],
      "bonne": 1,
      "explication": "La seule force est le poids, qui est vertical. Il n''y a donc aucune composante horizontale de force, donc aucune accélération horizontale. Le mouvement est uniforme selon $Ox$ et uniformément varié selon $Oy$."
    },
    {
      "question": "Quel angle de tir donne la plus grande portée sur terrain plat ?",
      "choix": [
        "30°",
        "45°",
        "60°",
        "90°"
      ],
      "bonne": 1,
      "explication": "La portée vaut $x_P = v_0^2\\sin(2\\alpha)/g$. Elle est maximale quand $\\sin(2\\alpha) = 1$, donc quand $2\\alpha = 90°$, soit $\\alpha = 45°$."
    },
    {
      "question": "Au sommet de sa trajectoire, que vaut la vitesse d''un projectile lancé obliquement ?",
      "choix": [
        "Elle est nulle",
        "Elle est égale à $v_0\\cos\\alpha$, horizontale",
        "Elle est égale à $v_0$",
        "Elle est verticale"
      ],
      "bonne": 1,
      "explication": "Au sommet, seule la composante verticale s''annule. La composante horizontale $v_0\\cos\\alpha$ reste inchangée pendant tout le vol. La vitesse au sommet n''est donc pas nulle, elle est horizontale."
    },
    {
      "question": "Pourquoi néglige-t-on le poids d''un électron dans un champ électrique ?",
      "choix": [
        "Parce que l''électron n''a pas de masse",
        "Parce que la force électrique est environ $10^{14}$ fois plus grande",
        "Parce que le champ est horizontal",
        "Parce que l''électron va trop vite"
      ],
      "bonne": 1,
      "explication": "Pour un champ courant de $10^4$ V/m, la force électrique vaut environ $1{,}6 \\times 10^{-15}$ N contre $8{,}9 \\times 10^{-30}$ N pour le poids. L''écart est tel que le poids ne change rien au résultat."
    },
    {
      "question": "Que fait un électron après être sorti de la zone entre les plaques ?",
      "choix": [
        "Il continue sur une parabole",
        "Il suit une ligne droite tangente à la parabole",
        "Il revient en arrière",
        "Il s''arrête"
      ],
      "bonne": 1,
      "explication": "Au-delà des plaques il n''y a plus de champ, donc plus de force. D''après le principe d''inertie, le mouvement devient rectiligne uniforme, dans la direction de la vitesse de sortie."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 7, Mouvements dans un champ uniforme — 6 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
