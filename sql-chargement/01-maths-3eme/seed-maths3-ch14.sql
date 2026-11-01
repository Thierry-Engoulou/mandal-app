-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 14, Homothéties
-- 5 leçons.
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
  WHERE programme_id = v_programme_id AND ordre = 14;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Homothéties', 14, 'Module 15 : Configurations et transformations élémentaires du plan')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 14 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 14 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'L''homothétie, définie par son centre et son rapport', 1, 'texte', 'Quand tu agrandis une photo ou qu''un projecteur grossit une image sur un mur, la forme reste la même mais les dimensions changent. En mathématiques, cette transformation s''appelle une homothétie.

## La définition

Soit $\Omega$ un point du plan et $k$ un réel non nul. L''homothétie de centre $\Omega$ et de rapport $k$ associe à tout point $M$ le point $M''$ tel que

$$\overrightarrow{\Omega M''} = k\,\overrightarrow{\Omega M}$$

Le point $\Omega$ est le seul point qui ne bouge pas : il est invariant.

## Ce que fait le rapport

Si $k > 1$, la figure est agrandie et l''image reste du même côté du centre.

Si $0 < k < 1$, la figure est réduite, toujours du même côté.

Si $k = 1$, rien ne bouge du tout.

Si $k < 0$, l''image passe de l''autre côté du centre et elle est retournée. Le cas $k = -1$ correspond exactement à la symétrie centrale de centre $\Omega$.

## Construire l''image d''un point

Trace la droite $(\Omega M)$. L''image $M''$ se trouve sur cette droite, à une distance $|k| \times \Omega M$ du centre, du même côté si $k$ est positif, de l''autre côté sinon.

Exemple : avec $k = 3$ et $\Omega M = 2$ cm, le point $M''$ est sur la demi-droite $[\Omega M)$ à 6 cm de $\Omega$.

Avec $k = -2$ et $\Omega M = 2$ cm, le point $M''$ est sur la demi-droite opposée, à 4 cm de $\Omega$.

## Exercice d''application

$\Omega$ est un point et $A$ un point tel que $\Omega A = 5$ cm. Place $A''$, image de $A$ par l''homothétie de centre $\Omega$ et de rapport $-\dfrac{3}{5}$, puis donne $\Omega A''$.

Correction. Comme le rapport est négatif, $A''$ se trouve de l''autre côté de $\Omega$ par rapport à $A$. Sa distance au centre vaut $\left|-\dfrac{3}{5}\right| \times 5 = 3$ cm.', NULL, 15),
    (v_chapitre_id, 'Les propriétés d''une homothétie', 2, 'texte', 'Une homothétie déforme les longueurs mais respecte tout le reste. C''est ce qui en fait un outil de calcul très sûr.

## Ce qui est conservé

L''alignement des points est conservé : l''image d''une droite est une droite qui lui est parallèle.

Les angles sont conservés, donc la forme de la figure ne change pas.

Le parallélisme, le milieu, le contact entre deux figures sont conservés aussi. L''image d''un cercle est un cercle, celle d''un segment est un segment.

## Ce qui change

Les longueurs sont multipliées par $|k|$. Si $AB = 6$ cm et $k = 2{,}5$, alors $A''B'' = 15$ cm.

Les aires sont multipliées par $k^{2}$. Un rapport 2 multiplie donc l''aire par 4, et non par 2.

Les volumes, quand on travaille dans l''espace, sont multipliés par $|k|^{3}$.

## Pourquoi $k^{2}$ pour les aires

Une aire se calcule toujours à partir de deux longueurs. Chacune est multipliée par $|k|$, donc le produit est multiplié par $k^{2}$. Un carré de 3 cm de côté a 9 cm² d''aire. Avec $k = 2$, le côté passe à 6 cm et l''aire à 36 cm², soit bien 4 fois plus.

## Un exemple complet

Un triangle $ABC$ d''aire 12 cm² et de périmètre 18 cm subit une homothétie de rapport 3.

Le périmètre de l''image vaut $3 \times 18 = 54$ cm. L''aire de l''image vaut $3^{2} \times 12 = 9 \times 12 = 108$ cm².

## Exercice d''application

Un rectangle de 4 cm sur 7 cm subit une homothétie de rapport $-\dfrac{1}{2}$. Donne les dimensions et l''aire de l''image.

Correction. Les longueurs sont multipliées par $\dfrac{1}{2}$, donc l''image mesure 2 cm sur 3,5 cm. Son aire vaut $2 \times 3{,}5 = 7$ cm². On retrouve bien $\left(\dfrac{1}{2}\right)^{2} \times 28 = \dfrac{28}{4} = 7$ cm².', NULL, 15),
    (v_chapitre_id, 'Simulation : agrandir, réduire, retourner', 3, 'interactif', '{
  "widget": "transformations",
  "consigne": "Choisis l''homothétie et règle le rapport $k$ sur 2 : la figure double de taille, en restant du même côté du centre $\\Omega$. Descends à $0{,}5$ : elle est réduite de moitié. Passe à $-1$ : tu obtiens la symétrie centrale, la figure est retournée de l''autre côté. Déplace enfin le centre $\\Omega$ et observe que lui seul ne bouge jamais."
}', NULL, 10),
    (v_chapitre_id, 'Quiz : homothéties', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Dans une homothétie de rapport $k = 4$, les longueurs sont multipliées par :",
      "choix": [
        "$4$",
        "$16$",
        "$2$"
      ],
      "bonne": 0,
      "explication": "Les longueurs sont multipliées par $|k| = 4$. Ce sont les aires qui sont multipliées par 16."
    },
    {
      "question": "Une homothétie de rapport $-1$ est en fait :",
      "choix": [
        "une translation",
        "une symétrie centrale",
        "une rotation de 90°"
      ],
      "bonne": 1,
      "explication": "Avec $k = -1$, l''image est de l''autre côté du centre à la même distance : c''est exactement la symétrie centrale."
    },
    {
      "question": "Un triangle d''aire 5 cm² subit une homothétie de rapport 3. L''aire de l''image vaut :",
      "choix": [
        "$15$ cm²",
        "$45$ cm²",
        "$8$ cm²"
      ],
      "bonne": 1,
      "explication": "Les aires sont multipliées par $k^{2} = 9$, donc $9 \\times 5 = 45$ cm²."
    },
    {
      "question": "L''image d''une droite par une homothétie est :",
      "choix": [
        "une droite parallèle à la première",
        "un cercle",
        "la même droite toujours"
      ],
      "bonne": 0,
      "explication": "L''homothétie conserve l''alignement et transforme une droite en une droite parallèle."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 5, 'texte', '## Exercice 1

$\Omega$ est le centre d''une homothétie de rapport $k = -3$. On donne $\Omega A = 2$ cm. Où se trouve $A''$ et quelle est la distance $\Omega A''$ ?

Correction. Comme $k$ est négatif, $A''$ est sur la demi-droite opposée à $[\Omega A)$. La distance vaut $|-3| \times 2 = 6$ cm.

## Exercice 2

Le périmètre d''un polygone passe de 24 cm à 36 cm par une homothétie de rapport positif. Quel est ce rapport ? Si l''aire de départ valait 30 cm², que vaut celle de l''image ?

Correction. Le rapport vaut $k = \dfrac{36}{24} = 1{,}5$. L''aire est multipliée par $k^{2} = 2{,}25$, donc elle devient $30 \times 2{,}25 = 67{,}5$ cm².

## Exercice 3

Un photographe agrandit une photo de 10 cm sur 15 cm pour en faire une affiche de 40 cm de large. Quel est le rapport d''agrandissement ? Quelle sera la hauteur de l''affiche ? Combien de fois plus de papier faudra-t-il ?

Correction. Le rapport vaut $k = \dfrac{40}{10} = 4$. La hauteur devient $15 \times 4 = 60$ cm. L''aire étant multipliée par $k^{2} = 16$, il faudra 16 fois plus de papier.

## Exercice 4

$ABC$ est un triangle et $\Omega$ un point. On construit l''image $A''B''C''$ par l''homothétie de centre $\Omega$ et de rapport 2. Montre que $(A''B'')$ est parallèle à $(AB)$.

Correction. Par définition de l''homothétie, $\overrightarrow{\Omega A''} = 2\,\overrightarrow{\Omega A}$ et $\overrightarrow{\Omega B''} = 2\,\overrightarrow{\Omega B}$. Avec la relation de Chasles, $\overrightarrow{A''B''} = \overrightarrow{\Omega B''} - \overrightarrow{\Omega A''} = 2(\overrightarrow{\Omega B} - \overrightarrow{\Omega A}) = 2\,\overrightarrow{AB}$. Les vecteurs $\overrightarrow{A''B''}$ et $\overrightarrow{AB}$ sont colinéaires, donc les droites sont parallèles.', NULL, 15);

  RAISE NOTICE 'Chapitre 14, Homothéties : 5 lecons ajoutees.';
END $m3$;
