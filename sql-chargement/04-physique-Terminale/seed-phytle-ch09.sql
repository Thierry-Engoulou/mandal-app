-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 9, Généralités sur les systèmes oscillants
-- Module 2 : Mouvements et interactions, évolutions temporelles des systèmes mécaniques
-- 5 leçons.
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
    WHERE programme_id = v_programme_id AND ordre = 9;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Généralités sur les systèmes oscillants', 9, 'Module 2 : Mouvements et interactions, évolutions temporelles des systèmes mécaniques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 9 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 9 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Caractériser un mouvement oscillatoire', 1, 'texte', 'Le balancier d''une horloge, une corde de guitare, le cœur qui bat : tous ces mouvements se répètent. On les appelle des oscillations, et quelques grandeurs suffisent à les décrire.

## Ce qu''est un système oscillant

Un **système oscillant** est un système qui, écarté de sa position d''équilibre, y revient et la dépasse, encore et encore.

Les oscillations sont **libres** quand le système évolue seul après qu''on l''a lâché, et **forcées** quand un dispositif extérieur lui impose son rythme.

Elles sont **non amorties** quand l''amplitude reste constante, et **amorties** quand elle diminue à cause des frottements.

## Les grandeurs caractéristiques

L''**élongation** $x(t)$ est l''écart à la position d''équilibre à l''instant $t$.

L''**amplitude** $X_{m}$ est la valeur maximale de l''élongation. C''est toujours un nombre positif.

La **période** $T$ est la durée d''une oscillation complète, en secondes. Attention, une oscillation complète comprend l''aller **et** le retour.

La **fréquence** $N$ est le nombre d''oscillations par seconde, en hertz.
$$N = \dfrac{1}{T}$$

La **pulsation** $\omega$, en rad/s, vaut
$$\omega = 2\pi N = \dfrac{2\pi}{T}$$

## Le mouvement rectiligne sinusoïdal

C''est le modèle le plus important. L''élongation s''écrit
$$x(t) = X_{m}\cos(\omega t + \varphi)$$

La quantité $(\omega t + \varphi)$ est la **phase** à l''instant $t$, et $\varphi$ est la **phase à l''origine**, c''est-à-dire la phase à la date $t = 0$. Elle se détermine avec les conditions initiales.

En dérivant, on obtient la vitesse
$$v(t) = -X_{m}\,\omega\sin(\omega t + \varphi)$$
dont l''amplitude vaut $V_{m} = X_{m}\omega$.

En dérivant encore, l''accélération
$$a(t) = -X_{m}\,\omega^{2}\cos(\omega t + \varphi) = -\omega^{2}\,x(t)$$

Retiens bien cette dernière relation, $a = -\omega^{2}x$. C''est la signature d''un mouvement sinusoïdal. Chaque fois que tu obtiendras une équation différentielle de la forme
$$\ddot{x} + \omega^{2}x = 0$$
tu pourras affirmer que le mouvement est sinusoïdal de pulsation $\omega$, donc de période $T = \dfrac{2\pi}{\omega}$.

## Deux oscillateurs en comparaison

Deux grandeurs sinusoïdales de même pulsation présentent un **déphasage** $\Delta\varphi = \varphi_{2} - \varphi_{1}$.

Si $\Delta\varphi = 0$, elles sont **en phase** : elles passent par leur maximum en même temps.

Si $\Delta\varphi = \pi$, elles sont en **opposition de phase** : quand l''une est au maximum, l''autre est au minimum.

Si $\Delta\varphi = \pm\dfrac{\pi}{2}$, elles sont en **quadrature**.

Remarque au passage que la vitesse est toujours en quadrature avance sur l''élongation, et que l''accélération est en opposition de phase avec elle.

## Exercice d''application

Un mobile oscille selon $x(t) = 4{,}0\cos\left(10\pi t + \dfrac{\pi}{3}\right)$, où $x$ est en centimètres et $t$ en secondes. Donne l''amplitude, la pulsation, la période, la fréquence et la phase à l''origine. Calcule la vitesse maximale et la position à $t = 0$.

Correction. Par identification avec $x = X_{m}\cos(\omega t + \varphi)$, on lit directement $X_{m} = 4{,}0$ cm, $\omega = 10\pi$ rad/s et $\varphi = \dfrac{\pi}{3}$ rad.

La période vaut $T = \dfrac{2\pi}{\omega} = \dfrac{2\pi}{10\pi} = 0{,}20$ s.

La fréquence vaut $N = \dfrac{1}{T} = 5{,}0$ Hz.

La vitesse maximale vaut $V_{m} = X_{m}\omega = 0{,}040 \times 10\pi \approx 1{,}26$ m/s.

À $t = 0$, $x(0) = 4{,}0\cos\dfrac{\pi}{3} = 4{,}0 \times 0{,}5 = 2{,}0$ cm. Le mobile part donc à mi-amplitude, et comme $v(0) = -X_{m}\omega\sin\dfrac{\pi}{3} < 0$, il se dirige vers les $x$ décroissants.', NULL, 15),
      (v_chapitre_id, 'Enregistrer et observer les oscillations', 2, 'texte', 'Pour mesurer une période, encore faut-il voir le mouvement. Trois techniques classiques permettent de le faire, et chacune a son domaine.

## L''enregistrement graphique

On fixe un stylet au mobile et on fait défiler une bande de papier à vitesse constante $v_{p}$.

Le stylet trace une sinusoïde. Si une période occupe une longueur $\ell$ sur le papier, alors
$$T = \dfrac{\ell}{v_{p}}$$

C''est la méthode la plus simple, mais elle ne convient qu''aux mouvements lents, disons jusqu''à quelques hertz, car le stylet frotte et finit par perturber le système.

## L''oscilloscope électronique

Pour les phénomènes rapides, on convertit le mouvement en tension électrique grâce à un capteur, puis on observe cette tension sur un oscilloscope.

L''écran est quadrillé. Le réglage de la **base de temps**, noté $B$ et exprimé en secondes par division, donne l''échelle horizontale. Si une période occupe $n$ divisions,
$$T = n \times B$$

De même, la **sensibilité verticale** $S$, en volts par division, donne l''amplitude : si le signal occupe $p$ divisions crête à crête, l''amplitude vaut $\dfrac{pS}{2}$.

L''oscilloscope mesure sans contact, il ne perturbe donc pas le système, et il monte à des fréquences très élevées.

## La stroboscopie

On éclaire le mobile par des éclairs très brefs, à la fréquence $N_{e}$ réglable, et on observe à l''œil nu.

Si $N_{e}$ est égale à la fréquence $N$ du mouvement, on voit le mobile **immobile**, toujours dans la même position, puisqu''il est éclairé au même point de son cycle.

C''est le cas le plus utile. En augmentant doucement $N_{e}$ depuis zéro, la première immobilité apparente donne $N_{e} = N$, et on en déduit la fréquence cherchée.

Attention aux pièges. On observe aussi l''immobilité quand $N = k\,N_{e}$ avec $k$ entier, car le mobile fait alors un nombre entier de tours entre deux éclairs. C''est pourquoi on prend toujours la **plus grande** fréquence d''éclairs donnant l''immobilité unique.

Et si $N_{e}$ est légèrement inférieure à $N$, on voit le mobile se déplacer lentement dans le sens réel. Si elle est légèrement supérieure, il semble reculer. C''est l''effet qu''on observe sur les roues de charrette dans les vieux films.

## Exercice d''application

Sur un oscilloscope réglé à $B = 2$ ms par division, un signal sinusoïdal occupe $4$ divisions pour une période complète, et $6$ divisions crête à crête en vertical, avec une sensibilité de $0{,}5$ V par division. Détermine la période, la fréquence et l''amplitude.

Correction. La période vaut
$$T = n \times B = 4 \times 2 = 8\ \text{ms} = 8 \times 10^{-3}\ \text{s}$$

La fréquence vaut
$$N = \dfrac{1}{T} = \dfrac{1}{8 \times 10^{-3}} = 125\ \text{Hz}$$

La tension crête à crête vaut $6 \times 0{,}5 = 3{,}0$ V, donc l''amplitude vaut la moitié, soit $U_{m} = 1{,}5$ V.

N''oublie jamais que l''oscilloscope affiche la valeur crête à crête, alors que l''amplitude n''en est que la moitié. C''est une erreur très fréquente.', NULL, 15),
      (v_chapitre_id, 'La représentation de Fresnel', 3, 'texte', 'Additionner deux sinusoïdes avec les formules de trigonométrie est long et pénible. Fresnel a trouvé une méthode géométrique qui transforme ce calcul en une simple addition de vecteurs.

## Le principe

À toute grandeur sinusoïdale
$$y(t) = Y_{m}\cos(\omega t + \varphi)$$
on associe un vecteur $\vec{Y}$, appelé vecteur de Fresnel, dont la longueur vaut l''amplitude $Y_{m}$ et qui fait avec l''axe des abscisses un angle égal à la phase à l''origine $\varphi$.

Tous les vecteurs tournent à la même vitesse angulaire $\omega$, donc leurs positions relatives ne changent jamais. C''est pourquoi on peut les dessiner figés, à la date $t = 0$.

La grandeur $y(t)$ est la projection du vecteur tournant sur l''axe horizontal.

## Pourquoi cela marche

Additionner deux fonctions sinusoïdales de même pulsation donne toujours une sinusoïde de la même pulsation. La seule question est de trouver sa nouvelle amplitude et sa nouvelle phase.

Or ces deux inconnues sont exactement la longueur et la direction du vecteur somme. L''addition de deux sinusoïdes devient donc une addition de deux vecteurs, qu''on résout avec un dessin ou avec le théorème d''Al-Kashi.

## La méthode, en pratique

Tu dessines chaque vecteur avec sa longueur et son angle. Tu construis la somme par la règle du parallélogramme. Tu mesures, ou tu calcules, la longueur et l''angle du résultat.

Pour deux vecteurs $\vec{Y}_{1}$ et $\vec{Y}_{2}$ faisant entre eux un angle $\Delta\varphi$, la longueur de la somme vaut
$$Y_{m} = \sqrt{Y_{1}^{2} + Y_{2}^{2} + 2\,Y_{1}\,Y_{2}\cos\Delta\varphi}$$

## Les trois cas particuliers

Si $\Delta\varphi = 0$, les vecteurs sont alignés dans le même sens, et $Y_{m} = Y_{1} + Y_{2}$. C''est l''interférence constructive.

Si $\Delta\varphi = \pi$, ils sont opposés, et $Y_{m} = |Y_{1} - Y_{2}|$. C''est l''interférence destructive. Si en plus $Y_{1} = Y_{2}$, la somme est nulle : deux oscillations peuvent s''annuler complètement.

Si $\Delta\varphi = \dfrac{\pi}{2}$, ils sont perpendiculaires, et $Y_{m} = \sqrt{Y_{1}^{2} + Y_{2}^{2}}$, par Pythagore.

## Dérivation et intégration deviennent des rotations

Voilà l''autre grand intérêt de la méthode. Dériver une sinusoïde revient à multiplier son amplitude par $\omega$ et à faire **tourner** son vecteur de $+\dfrac{\pi}{2}$.

Intégrer revient à diviser par $\omega$ et à tourner de $-\dfrac{\pi}{2}$.

Tu retrouveras ces règles au chapitre sur les circuits RLC, où elles permettent de traiter un circuit entier sans résoudre la moindre équation différentielle.

## Exercice d''application

Additionne $y_{1} = 3\cos(\omega t)$ et $y_{2} = 4\cos\left(\omega t + \dfrac{\pi}{2}\right)$.

Correction. Le vecteur $\vec{Y}_{1}$ a une longueur $3$ et un angle nul, il est donc horizontal.

Le vecteur $\vec{Y}_{2}$ a une longueur $4$ et un angle de $\dfrac{\pi}{2}$, il est donc vertical.

Les deux vecteurs sont perpendiculaires, donc la somme a pour longueur
$$Y_{m} = \sqrt{3^{2} + 4^{2}} = \sqrt{25} = 5$$

L''angle $\varphi$ du vecteur somme vérifie $\tan\varphi = \dfrac{4}{3}$, donc $\varphi \approx 0{,}93$ rad, soit environ $53°$.

La somme s''écrit donc
$$y = 5\cos(\omega t + 0{,}93)$$

Retrouver ce résultat par la trigonométrie demanderait beaucoup plus de lignes. Avec Fresnel, c''est un triangle rectangle.', NULL, 15),
      (v_chapitre_id, 'Additionne deux sinusoïdes avec Fresnel', 4, 'interactif', '{
  "widget": "vecteur-fresnel",
  "consigne": "Règle l''amplitude et la phase de chaque vecteur, puis regarde le vecteur somme et la sinusoïde résultante. Trouve un déphasage pour lequel la somme est nulle. Que faut-il pour cela sur les deux amplitudes ?"
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 9', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Un mobile oscille avec une période de 0,25 s. Quelle est sa fréquence ?",
      "choix": [
        "0,25 Hz",
        "4 Hz",
        "2,5 Hz",
        "25 Hz"
      ],
      "bonne": 1,
      "explication": "La fréquence est l''inverse de la période : $N = 1/T = 1/0{,}25 = 4$ Hz. Le mobile effectue donc quatre oscillations complètes par seconde."
    },
    {
      "question": "Quelle équation différentielle caractérise un mouvement sinusoïdal ?",
      "choix": [
        "$\\ddot{x} + \\omega x = 0$",
        "$\\ddot{x} + \\omega^{2}x = 0$",
        "$\\dot{x} + \\omega^{2}x = 0$",
        "$\\ddot{x} - \\omega^{2}x = 0$"
      ],
      "bonne": 1,
      "explication": "La forme $\\ddot{x} + \\omega^{2}x = 0$ équivaut à $a = -\\omega^{2}x$, qui est la signature du mouvement sinusoïdal. Sa solution est $x = X_m\\cos(\\omega t + \\varphi)$ et sa période vaut $2\\pi/\\omega$."
    },
    {
      "question": "Sur un oscilloscope réglé à 5 ms/div, une période occupe 4 divisions. Que vaut la fréquence ?",
      "choix": [
        "20 Hz",
        "50 Hz",
        "200 Hz",
        "1,25 Hz"
      ],
      "bonne": 1,
      "explication": "La période vaut $T = 4 \\times 5 = 20$ ms, soit $0{,}020$ s. La fréquence est donc $N = 1/0{,}020 = 50$ Hz."
    },
    {
      "question": "Deux grandeurs sinusoïdales de même amplitude sont en opposition de phase. Que vaut leur somme ?",
      "choix": [
        "Le double de l''amplitude",
        "Zéro",
        "$\\sqrt{2}$ fois l''amplitude",
        "La moitié de l''amplitude"
      ],
      "bonne": 1,
      "explication": "En opposition de phase, les deux vecteurs de Fresnel sont opposés. S''ils ont la même longueur, leur somme est le vecteur nul : les deux oscillations s''annulent exactement."
    },
    {
      "question": "En stroboscopie, le mobile paraît immobile. Que peut-on en conclure immédiatement ?",
      "choix": [
        "Le mobile s''est arrêté",
        "La fréquence des éclairs est un sous-multiple de celle du mouvement",
        "Le mobile tourne deux fois plus vite que les éclairs",
        "L''éclairage est trop faible"
      ],
      "bonne": 1,
      "explication": "L''immobilité apparente signifie que le mobile revient au même point entre deux éclairs. Cela arrive dès que $N = k N_e$ avec $k$ entier, d''où la nécessité de retenir la plus grande fréquence d''éclairs donnant une image unique."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 9, Généralités sur les systèmes oscillants — 5 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
