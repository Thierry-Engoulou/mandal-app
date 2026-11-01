-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 15, Équations de droites
-- 8 leçons.
--
-- Autonome : ce fichier cree lui-meme le programme et le chapitre s'ils
-- n'existent pas encore. Vous pouvez le lancer seul, dans n'importe quel ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $m3$
DECLARE
  v_matiere_id uuid;
  v_classe_id uuid;
  v_etab_id uuid;
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_nb_etabs int;
  v_deja int;
BEGIN
  -- 1. le programme existe-t-il deja ?
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';

  -- 2. sinon on le cree
  IF v_programme_id IS NULL THEN
    INSERT INTO public.matieres (nom) VALUES ('Mathématiques') ON CONFLICT (nom) DO NOTHING;
    SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Mathématiques';

    SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
    IF v_nb_etabs <> 1 THEN
      RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
    END IF;
    SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

    SELECT id INTO v_classe_id FROM public.classes
    WHERE nom = '3ème' AND etablissement_id = v_etab_id LIMIT 1;
    IF v_classe_id IS NULL THEN
      RAISE EXCEPTION 'Classe "3ème" introuvable dans public.classes.';
    END IF;

    INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
    VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Mathématiques — 3ème',
            'Programme de Mathématiques, classe de 3ème (BEPC) — 4 modules, 16 chapitres.')
    RETURNING id INTO v_programme_id;
    RAISE NOTICE 'Programme "Mathématiques — 3ème" cree.';
  END IF;

  -- 3. le chapitre existe-t-il deja ?
  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 15;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Équations de droites', 15, 'Module 15 : Configurations et transformations élémentaires du plan')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 15 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 15 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'L''équation d''une droite passant par deux points', 1, 'texte', 'Toute droite du plan se décrit par une équation. Savoir passer des points à l''équation, et de l''équation au tracé, est l''un des savoir-faire les plus demandés au BEPC.

## Les deux formes d''équation

Une droite non parallèle à l''axe des ordonnées a une équation réduite de la forme

$$y = ax + b$$

où $a$ est le coefficient directeur et $b$ l''ordonnée à l''origine.

Une droite parallèle à l''axe des ordonnées a une équation de la forme $x = c$. Elle n''a pas de coefficient directeur.

Toute droite admet aussi une équation cartésienne de la forme $\alpha x + \beta y + \gamma = 0$.

## Trouver l''équation à partir de deux points

Soient $A(x_{A}\,;y_{A})$ et $B(x_{B}\,;y_{B})$ avec $x_{A} \neq x_{B}$. Le coefficient directeur vaut

$$a = \dfrac{y_{B} - y_{A}}{x_{B} - x_{A}}$$

On trouve ensuite $b$ en remplaçant les coordonnées de l''un des deux points dans $y = ax + b$.

## Un exemple complet

Trouvons l''équation de la droite passant par $A(1\,;2)$ et $B(4\,;11)$.

$$a = \dfrac{11 - 2}{4 - 1} = \dfrac{9}{3} = 3$$

On remplace avec le point $A$ : $2 = 3 \times 1 + b$, donc $b = -1$.

L''équation réduite est $y = 3x - 1$. Vérifions avec $B$ : $3 \times 4 - 1 = 11$. C''est correct.

## Exercice d''application

Détermine l''équation réduite de la droite passant par $M(-2\,;7)$ et $N(2\,;-1)$.

Correction. $a = \dfrac{-1 - 7}{2 - (-2)} = \dfrac{-8}{4} = -2$. Avec le point $N$ : $-1 = -2 \times 2 + b$, donc $b = 3$. L''équation est $y = -2x + 3$.', NULL, 15),
    (v_chapitre_id, 'Vecteur directeur et coefficient directeur', 2, 'texte', 'Une droite peut aussi se décrire par un point et une direction. Cette direction se donne par un vecteur ou par un nombre.

## Le vecteur directeur

Un vecteur directeur de la droite $(AB)$ est tout vecteur colinéaire à $\overrightarrow{AB}$, non nul. Il indique la direction de la droite.

Si la droite a pour équation réduite $y = ax + b$, alors le vecteur $\vec{u}\begin{pmatrix} 1 \\ a \end{pmatrix}$ est un vecteur directeur. Si elle a pour équation cartésienne $\alpha x + \beta y + \gamma = 0$, alors $\vec{u}\begin{pmatrix} -\beta \\ \alpha \end{pmatrix}$ en est un.

## Droite passant par un point et de vecteur directeur donné

Soit $A(x_{A}\,;y_{A})$ et un vecteur directeur $\vec{u}\begin{pmatrix} p \\ q \end{pmatrix}$. Un point $M(x\,;y)$ appartient à la droite si et seulement si $\overrightarrow{AM}$ et $\vec{u}$ sont colinéaires, c''est-à-dire

$$(x - x_{A})q - (y - y_{A})p = 0$$

Exemple : la droite passant par $A(2\,;1)$ et de vecteur directeur $\vec{u}\begin{pmatrix} 3 \\ -2 \end{pmatrix}$ a pour équation $(x-2)(-2) - (y-1)(3) = 0$, soit $-2x + 4 - 3y + 3 = 0$, c''est-à-dire $2x + 3y - 7 = 0$.

## Droite passant par un point et de coefficient directeur donné

C''est plus rapide. Si la droite passe par $A(x_{A}\,;y_{A})$ et a pour coefficient directeur $a$, alors

$$y - y_{A} = a(x - x_{A})$$

Exemple : la droite passant par $A(3\,;-2)$ avec $a = 4$ a pour équation $y + 2 = 4(x - 3)$, soit $y = 4x - 14$.

## Lire le coefficient directeur sur un dessin

Depuis un point de la droite, avance de 1 vers la droite puis compte de combien tu montes. Ce nombre est le coefficient directeur. S''il faut descendre, il est négatif.

## Exercice d''application

Donne un vecteur directeur de la droite d''équation $3x - 5y + 2 = 0$, puis son coefficient directeur.

Correction. Avec $\alpha = 3$ et $\beta = -5$, le vecteur $\vec{u}\begin{pmatrix} 5 \\ 3 \end{pmatrix}$ est directeur. On peut aussi isoler $y$ : $5y = 3x + 2$, donc $y = \dfrac{3}{5}x + \dfrac{2}{5}$, et le coefficient directeur vaut $\dfrac{3}{5}$.', NULL, 15),
    (v_chapitre_id, 'Graphique : trois droites et leurs coefficients directeurs', 3, 'graphique', '{"functions": [{"expr": "3*x - 1", "label": "y = 3x - 1 (a = 3)", "color": "#2563eb"}, {"expr": "-2*x + 3", "label": "y = -2x + 3 (a = -2)", "color": "#dc2626"}, {"expr": "0.5*x + 1", "label": "y = 0,5x + 1 (a = 0,5)", "color": "#16a34a"}], "domain": [-4, 4], "points": [{"x": 0, "y": -1, "label": "b = -1"}, {"x": 0, "y": 3, "label": "b = 3"}, {"x": 0, "y": 1, "label": "b = 1"}]}', NULL, 5),
    (v_chapitre_id, 'Simulation : régler a et b', 4, 'interactif', '{
  "widget": "application-affine",
  "consigne": "Fais varier $a$ et regarde la droite pivoter : plus $a$ est grand, plus elle monte vite. Rends $a$ négatif et elle descend. Fais varier $b$ ensuite : la droite se déplace verticalement sans changer d''inclinaison, et coupe toujours l''axe des ordonnées en $b$. Place enfin le point rouge pour lire une image, puis cherche l''antécédent d''une valeur donnée."
}', NULL, 10),
    (v_chapitre_id, 'Positions relatives de deux droites', 5, 'texte', 'Deux droites du plan ne peuvent se trouver que dans trois situations, et le coefficient directeur permet de les distinguer immédiatement.

## Les trois cas

Deux droites d''équations $y = ax + b$ et $y = a''x + b''$ sont :

parallèles et distinctes si $a = a''$ et $b \neq b''$ ;

confondues si $a = a''$ et $b = b''$ ;

sécantes si $a \neq a''$, et elles se coupent alors en un seul point.

Deux droites parallèles ont donc le même coefficient directeur : c''est l''idée à retenir.

## Trouver le point d''intersection

Les coordonnées du point d''intersection vérifient les deux équations à la fois. C''est donc un système à résoudre.

Cherchons l''intersection de $y = 3x - 1$ et $y = -2x + 9$.

On écrit $3x - 1 = -2x + 9$, donc $5x = 10$ et $x = 2$. Puis $y = 3 \times 2 - 1 = 5$. Les droites se coupent au point $(2\,;5)$.

Vérification dans la seconde équation : $-2 \times 2 + 9 = 5$. C''est bon.

## Droites perpendiculaires

Dans un repère orthonormé, deux droites de coefficients directeurs $a$ et $a''$ sont perpendiculaires si et seulement si

$$a \times a'' = -1$$

Par exemple $y = 2x + 1$ et $y = -\dfrac{1}{2}x + 4$ sont perpendiculaires, car $2 \times \left(-\dfrac{1}{2}\right) = -1$.

## Exercice d''application

Les droites $d_{1}: y = \dfrac{2}{3}x + 5$ et $d_{2}: 4x - 6y + 1 = 0$ sont-elles parallèles ?

Correction. Pour $d_{2}$, on isole $y$ : $6y = 4x + 1$, donc $y = \dfrac{2}{3}x + \dfrac{1}{6}$. Les deux coefficients directeurs valent $\dfrac{2}{3}$, mais les ordonnées à l''origine diffèrent, 5 et $\dfrac{1}{6}$. Les droites sont donc parallèles et distinctes.', NULL, 15),
    (v_chapitre_id, 'Quiz : équations de droites', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "La droite passant par $A(0\\,;3)$ et $B(2\\,;7)$ a pour équation :",
      "choix": [
        "$y = 2x + 3$",
        "$y = 4x + 3$",
        "$y = 2x + 7$"
      ],
      "bonne": 0,
      "explication": "$a = \\dfrac{7-3}{2-0} = 2$, et comme $A$ a pour abscisse 0, $b = 3$."
    },
    {
      "question": "Les droites $y = 5x - 2$ et $y = 5x + 8$ sont :",
      "choix": [
        "sécantes",
        "parallèles et distinctes",
        "confondues"
      ],
      "bonne": 1,
      "explication": "Même coefficient directeur mais ordonnées à l''origine différentes : elles ne se croisent jamais."
    },
    {
      "question": "Un vecteur directeur de la droite $y = -3x + 1$ est :",
      "choix": [
        "$\\begin{pmatrix} 1 \\\\ -3 \\end{pmatrix}$",
        "$\\begin{pmatrix} -3 \\\\ 1 \\end{pmatrix}$",
        "$\\begin{pmatrix} 0 \\\\ 1 \\end{pmatrix}$"
      ],
      "bonne": 0,
      "explication": "Pour $y = ax + b$, le vecteur $\\begin{pmatrix} 1 \\\\ a \\end{pmatrix}$ est directeur, ici $\\begin{pmatrix} 1 \\\\ -3 \\end{pmatrix}$."
    },
    {
      "question": "Dans un repère orthonormé, la droite perpendiculaire à $y = 3x$ a pour coefficient directeur :",
      "choix": [
        "$3$",
        "$-3$",
        "$-\\dfrac{1}{3}$"
      ],
      "bonne": 2,
      "explication": "Le produit des coefficients directeurs doit valoir $-1$, donc $a'' = -\\dfrac{1}{3}$."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 7, 'texte', '## Exercice 1

Détermine l''équation réduite de la droite passant par $A(-1\,;4)$ et $B(3\,;-4)$.

Correction. $a = \dfrac{-4 - 4}{3 + 1} = \dfrac{-8}{4} = -2$. Avec $A$ : $4 = -2 \times (-1) + b = 2 + b$, donc $b = 2$. L''équation est $y = -2x + 2$.

## Exercice 2

Donne l''équation réduite de la droite passant par $C(2\,;-3)$ et de coefficient directeur $\dfrac{1}{2}$.

Correction. $y + 3 = \dfrac{1}{2}(x - 2)$, donc $y = \dfrac{1}{2}x - 1 - 3$, c''est-à-dire $y = \dfrac{1}{2}x - 4$.

## Exercice 3

Trouve le point d''intersection des droites $y = 4x - 7$ et $y = -x + 3$.

Correction. On écrit $4x - 7 = -x + 3$, donc $5x = 10$ et $x = 2$. Puis $y = 4 \times 2 - 7 = 1$. Le point d''intersection est $(2\,;1)$.

## Exercice 4

Le point $P(5\,;8)$ appartient-il à la droite d''équation $2x - y - 2 = 0$ ?

Correction. On remplace : $2 \times 5 - 8 - 2 = 10 - 10 = 0$. L''égalité est vérifiée, donc $P$ appartient bien à la droite.

## Exercice 5

Donne l''équation de la droite passant par $A(1\,;3)$ et parallèle à la droite $y = -4x + 9$.

Correction. Deux droites parallèles ont le même coefficient directeur, donc $a = -4$. Avec $A$ : $3 = -4 \times 1 + b$, donc $b = 7$. L''équation est $y = -4x + 7$.', NULL, 15),
    (v_chapitre_id, 'Activité d''intégration : deux motos sur la route de Bafia', 8, 'texte', '## La situation

Deux motos partent au même instant sur la route Yaoundé-Bafia, longue de 120 km.

La première part de Yaoundé et roule à 60 km/h vers Bafia.

La seconde part de Bafia et roule à 40 km/h vers Yaoundé.

On note $t$ le temps écoulé en heures, et on repère la position par la distance à Yaoundé, en kilomètres.

1. Exprime la position de chaque moto en fonction de $t$, et reconnais le type de chaque fonction.
2. Trace mentalement les deux droites et dis ce que représente leur point d''intersection.
3. Calcule l''instant et le lieu de la rencontre.
4. À quelle heure chaque moto arrive-t-elle, si le départ a lieu à 7 h ?

## La solution

1. La première moto part du kilomètre 0 et avance de 60 km par heure, donc sa position vaut $y_{1}(t) = 60t$. C''est une application linéaire, et sa droite passe par l''origine.

La seconde part du kilomètre 120 et s''en rapproche de 40 km par heure, donc $y_{2}(t) = 120 - 40t$. C''est une application affine, de coefficient directeur négatif.

2. Les deux droites se coupent en un point. Ce point correspond à l''instant où les deux motos sont à la même distance de Yaoundé, c''est-à-dire au moment précis où elles se croisent sur la route.

3. On résout
$$60t = 120 - 40t$$
$$100t = 120$$
$$t = 1{,}2$$

Elles se croisent après 1,2 heure, soit 1 h 12 min. À cet instant, la position vaut $60 \times 1{,}2 = 72$ km. La rencontre a donc lieu à 72 km de Yaoundé, et donc à 48 km de Bafia.

Vérification avec l''autre expression : $120 - 40 \times 1{,}2 = 120 - 48 = 72$. C''est cohérent.

4. La première moto arrive à Bafia quand $60t = 120$, donc $t = 2$ heures, soit à 9 h. La seconde arrive à Yaoundé quand $120 - 40t = 0$, donc $t = 3$ heures, soit à 10 h.

## Ce qu''il faut remarquer

Les deux coefficients directeurs, $+60$ et $-40$, sont différents, donc les droites sont forcément sécantes : la rencontre est certaine. Si les deux motos roulaient dans le même sens à la même vitesse, les coefficients seraient égaux, les droites parallèles, et elles ne se rattraperaient jamais.', NULL, 15);

  RAISE NOTICE 'Chapitre 15, Équations de droites : 8 lecons ajoutees.';
END $m3$;
