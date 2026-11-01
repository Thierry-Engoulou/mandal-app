-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 12, Multiplication d''un vecteur par un nombre réel
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
  WHERE programme_id = v_programme_id AND ordre = 12;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Multiplication d''un vecteur par un nombre réel', 12, 'Module 15 : Configurations et transformations élémentaires du plan')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 12 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 12 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Multiplier un vecteur par un nombre réel', 1, 'texte', 'Un vecteur, c''est une flèche : elle a une direction, un sens et une longueur. Le multiplier par un nombre revient à l''étirer, à le raccourcir ou à le retourner.

## La définition

Soit $\vec{u}$ un vecteur non nul et $k$ un réel non nul. Le vecteur $k\vec{u}$ est le vecteur qui a :

la même direction que $\vec{u}$, toujours ;

le même sens que $\vec{u}$ si $k > 0$, et le sens contraire si $k < 0$ ;

une longueur égale à $|k|$ fois celle de $\vec{u}$.

Si $k = 0$ ou si $\vec{u}$ est le vecteur nul, alors $k\vec{u} = \vec{0}$.

## Ce que cela donne concrètement

$2\vec{u}$ pointe dans le même sens que $\vec{u}$ mais il est deux fois plus long.

$\dfrac{1}{2}\vec{u}$ pointe dans le même sens, mais il est deux fois plus court.

$-\vec{u}$ a la même longueur que $\vec{u}$ et pointe exactement dans le sens contraire.

$-3\vec{u}$ pointe dans le sens contraire et il est trois fois plus long.

## Les règles de calcul

Pour tous réels $k$ et $k''$ et tous vecteurs $\vec{u}$ et $\vec{v}$ :

$$k(\vec{u} + \vec{v}) = k\vec{u} + k\vec{v} \qquad (k + k'')\vec{u} = k\vec{u} + k''\vec{u} \qquad k(k''\vec{u}) = (kk'')\vec{u}$$

Tu calcules donc comme avec des nombres, en gardant les flèches.

Par exemple $3(\vec{u} - 2\vec{v}) + 2\vec{v} = 3\vec{u} - 6\vec{v} + 2\vec{v} = 3\vec{u} - 4\vec{v}$.

## Exercice d''application

Simplifie $\vec{w} = 2(\vec{u} + 3\vec{v}) - 3(\vec{u} - \vec{v})$.

Correction. On développe : $\vec{w} = 2\vec{u} + 6\vec{v} - 3\vec{u} + 3\vec{v}$. En regroupant, $\vec{w} = -\vec{u} + 9\vec{v}$.', NULL, 15),
    (v_chapitre_id, 'Les vecteurs colinéaires', 2, 'texte', 'Deux vecteurs colinéaires, ce sont deux flèches qui pointent dans la même direction, qu''elles aillent dans le même sens ou en sens contraire.

## La définition

Deux vecteurs $\vec{u}$ et $\vec{v}$, avec $\vec{u}$ non nul, sont colinéaires lorsqu''il existe un réel $k$ tel que $\vec{v} = k\vec{u}$.

Le vecteur nul est colinéaire à tous les vecteurs.

## À quoi cela sert

C''est l''outil qui démontre les alignements et les parallélismes, et il tombe très souvent au BEPC.

Trois points $A$, $B$ et $C$ sont alignés si et seulement si les vecteurs $\overrightarrow{AB}$ et $\overrightarrow{AC}$ sont colinéaires.

Les droites $(AB)$ et $(CD)$ sont parallèles si et seulement si les vecteurs $\overrightarrow{AB}$ et $\overrightarrow{CD}$ sont colinéaires.

## Rédiger une démonstration d''alignement

On te donne $\overrightarrow{AB} = 2\vec{u} + 3\vec{v}$ et $\overrightarrow{AC} = 6\vec{u} + 9\vec{v}$. Montre que $A$, $B$ et $C$ sont alignés.

On remarque que $6\vec{u} + 9\vec{v} = 3(2\vec{u} + 3\vec{v})$, donc $\overrightarrow{AC} = 3\,\overrightarrow{AB}$. Les deux vecteurs sont colinéaires, donc les points $A$, $B$ et $C$ sont alignés.

## Le milieu et le point partage

Dire que $I$ est le milieu de $[AB]$ revient à écrire $\overrightarrow{AI} = \dfrac{1}{2}\,\overrightarrow{AB}$, ou encore $\overrightarrow{AI} = \overrightarrow{IB}$.

Plus généralement, le point $M$ tel que $\overrightarrow{AM} = \dfrac{2}{3}\,\overrightarrow{AB}$ se trouve aux deux tiers du segment, en partant de $A$.

## Exercice d''application

On donne $\overrightarrow{AB} = \vec{u} - 2\vec{v}$ et $\overrightarrow{CD} = -3\vec{u} + 6\vec{v}$. Que peux-tu dire des droites $(AB)$ et $(CD)$ ?

Correction. On remarque que $-3\vec{u} + 6\vec{v} = -3(\vec{u} - 2\vec{v})$, donc $\overrightarrow{CD} = -3\,\overrightarrow{AB}$. Les vecteurs sont colinéaires, donc les droites $(AB)$ et $(CD)$ sont parallèles. Le coefficient négatif indique simplement qu''elles sont parcourues en sens contraire.', NULL, 15),
    (v_chapitre_id, 'Simulation : somme de vecteurs et colinéarité', 3, 'interactif', '{
  "widget": "vecteurs",
  "consigne": "Tire les deux flèches et observe le parallélogramme de la somme $\\vec{u} + \\vec{v}$. Cherche maintenant une position où le déterminant affiché vaut $0$ : les deux vecteurs sont alors colinéaires, et tu les vois alignés sur une même direction. Essaie ensuite d''obtenir un produit scalaire nul : cette fois les vecteurs sont perpendiculaires, ce qui est l''exact contraire."
}', NULL, 10),
    (v_chapitre_id, 'Quiz : vecteurs colinéaires', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Le vecteur $-2\\vec{u}$ par rapport à $\\vec{u}$ est :",
      "choix": [
        "deux fois plus long et de sens contraire",
        "deux fois plus court et de même sens",
        "de même longueur et de sens contraire"
      ],
      "bonne": 0,
      "explication": "La longueur est multipliée par $|-2| = 2$, et le signe négatif inverse le sens."
    },
    {
      "question": "Si $\\overrightarrow{AC} = 4\\,\\overrightarrow{AB}$, alors :",
      "choix": [
        "$A$, $B$, $C$ sont alignés",
        "$(AB)$ et $(AC)$ sont perpendiculaires",
        "$B$ est le milieu de $[AC]$"
      ],
      "bonne": 0,
      "explication": "Les deux vecteurs sont colinéaires et partent du même point $A$, donc les trois points sont alignés."
    },
    {
      "question": "$I$ est le milieu de $[AB]$. On peut écrire :",
      "choix": [
        "$\\overrightarrow{AI} = 2\\,\\overrightarrow{AB}$",
        "$\\overrightarrow{AI} = \\dfrac{1}{2}\\,\\overrightarrow{AB}$",
        "$\\overrightarrow{AI} = -\\overrightarrow{IB}$"
      ],
      "bonne": 1,
      "explication": "Le milieu est à la moitié du segment. On a aussi $\\overrightarrow{AI} = \\overrightarrow{IB}$, sans signe moins."
    },
    {
      "question": "Simplifie $3\\vec{u} - 2(\\vec{u} - \\vec{v})$ :",
      "choix": [
        "$\\vec{u} + 2\\vec{v}$",
        "$5\\vec{u} - 2\\vec{v}$",
        "$\\vec{u} - 2\\vec{v}$"
      ],
      "bonne": 0,
      "explication": "$3\\vec{u} - 2\\vec{u} + 2\\vec{v} = \\vec{u} + 2\\vec{v}$. Attention au signe devant la parenthèse."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 5, 'texte', '## Exercice 1

Simplifie $\vec{w} = 4(\vec{u} - \vec{v}) - 2(\vec{u} - 3\vec{v})$.

Correction. $\vec{w} = 4\vec{u} - 4\vec{v} - 2\vec{u} + 6\vec{v} = 2\vec{u} + 2\vec{v}$, soit $\vec{w} = 2(\vec{u} + \vec{v})$.

## Exercice 2

$ABC$ est un triangle. $M$ est le point tel que $\overrightarrow{AM} = \dfrac{3}{4}\,\overrightarrow{AB}$. Où se trouve $M$ ?

Correction. Comme le coefficient $\dfrac{3}{4}$ est compris entre 0 et 1, le point $M$ appartient au segment $[AB]$, aux trois quarts en partant de $A$.

## Exercice 3

On donne $\overrightarrow{AB} = 2\vec{u} + \vec{v}$, $\overrightarrow{AC} = -4\vec{u} - 2\vec{v}$. Montre que $A$, $B$ et $C$ sont alignés et précise la position de $C$.

Correction. On factorise : $-4\vec{u} - 2\vec{v} = -2(2\vec{u} + \vec{v})$, donc $\overrightarrow{AC} = -2\,\overrightarrow{AB}$. Les vecteurs sont colinéaires, donc les points sont alignés. Le coefficient $-2$ indique que $C$ se trouve de l''autre côté de $A$ par rapport à $B$, à une distance double de $AB$.

## Exercice 4

$ABCD$ est un parallélogramme. Exprime $\overrightarrow{AC}$ en fonction de $\overrightarrow{AB}$ et $\overrightarrow{AD}$, puis montre que les diagonales se coupent en leur milieu.

Correction. Dans un parallélogramme, $\overrightarrow{AC} = \overrightarrow{AB} + \overrightarrow{AD}$, d''après la relation de Chasles. Soit $I$ le milieu de $[AC]$. Alors $\overrightarrow{AI} = \dfrac{1}{2}(\overrightarrow{AB} + \overrightarrow{AD})$. Un calcul identique depuis $B$ montre que le milieu de $[BD]$ occupe la même position. Les deux diagonales se coupent donc bien en leur milieu commun.', NULL, 15);

  RAISE NOTICE 'Chapitre 12, Multiplication d''un vecteur par un nombre réel : 5 lecons ajoutees.';
END $m3$;
