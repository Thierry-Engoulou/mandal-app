-- ============================================================================
-- MANDAL — Mathématiques 3ème : chapitre 16, Section d''une pyramide ou d''un cône de révolution par un plan parallèle à la base
-- 6 leçons.
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
  WHERE programme_id = v_programme_id AND ordre = 16;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Section d''une pyramide ou d''un cône de révolution par un plan parallèle à la base', 16, 'Module 16 : Solides de l''espace')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 16 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 16 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Section d''une pyramide ou d''un cône par un plan parallèle à la base', 1, 'texte', 'Quand on coupe horizontalement une pyramide ou un cône, on obtient deux morceaux. Celui du haut ressemble exactement au solide de départ, en plus petit.

## Ce qu''on obtient

Si on coupe une pyramide par un plan parallèle à sa base, la section est un polygone de même nature que la base, mais plus petit. Une pyramide à base carrée donne un carré, une pyramide à base triangulaire donne un triangle.

Si on coupe un cône de révolution par un plan parallèle à sa base, la section est un disque.

Le solide situé entre le sommet et le plan de coupe est appelé la pyramide réduite, ou le cône réduit. C''est une réduction du solide de départ.

## Le coefficient de réduction

Soit $S$ le sommet, $SH$ la hauteur du solide de départ et $SH''$ la hauteur du solide réduit. Le coefficient de réduction vaut

$$k = \dfrac{SH''}{SH}$$

Ce même coefficient se retrouve sur toutes les longueurs. Si $SA'' $ est l''arête du petit solide et $SA$ celle du grand, alors $\dfrac{SA''}{SA} = k$ également. C''est une conséquence directe de la propriété de Thalès.

## Un exemple

Une pyramide a une hauteur de 12 cm. On la coupe à 8 cm du sommet. Le coefficient de réduction vaut $k = \dfrac{8}{12} = \dfrac{2}{3}$.

Si la base est un carré de 9 cm de côté, la section est un carré de $9 \times \dfrac{2}{3} = 6$ cm de côté.

## Exercice d''application

Un cône de hauteur 15 cm et de rayon de base 6 cm est coupé à 5 cm du sommet. Donne le coefficient de réduction et le rayon de la section.

Correction. $k = \dfrac{5}{15} = \dfrac{1}{3}$. Le rayon de la section vaut $6 \times \dfrac{1}{3} = 2$ cm.', NULL, 15),
    (v_chapitre_id, 'Les propriétés de réduction', 2, 'texte', 'Le coefficient $k$ agit différemment sur les longueurs, les aires et les volumes. C''est le point que les correcteurs vérifient en priorité.

## Les trois règles

Les longueurs du solide réduit sont celles du solide de départ multipliées par $k$.

Les aires, qu''il s''agisse de la base ou de la surface latérale, sont multipliées par $k^{2}$.

Les volumes sont multipliés par $k^{3}$.

## Pourquoi

Une longueur dépend d''une seule dimension, donc elle est multipliée une fois par $k$. Une aire dépend de deux dimensions, donc de $k \times k$. Un volume dépend de trois dimensions, donc de $k \times k \times k$.

## Un exemple chiffré

Une pyramide a une base carrée de 10 cm de côté et une hauteur de 15 cm. On la coupe à 9 cm du sommet.

Le coefficient vaut $k = \dfrac{9}{15} = 0{,}6$.

Le côté de la section vaut $10 \times 0{,}6 = 6$ cm.

L''aire de la base de départ vaut $10^{2} = 100$ cm², donc l''aire de la section vaut $100 \times 0{,}6^{2} = 100 \times 0{,}36 = 36$ cm². On le vérifie directement : $6^{2} = 36$ cm².

Le volume de départ vaut $\dfrac{100 \times 15}{3} = 500$ cm³, donc le volume réduit vaut $500 \times 0{,}6^{3} = 500 \times 0{,}216 = 108$ cm³.

## Le tronc de pyramide

Le morceau du bas, entre la base et la section, s''appelle un tronc de pyramide, ou un tronc de cône. Son volume s''obtient par soustraction :

$$V_{\text{tronc}} = V_{\text{grand}} - V_{\text{réduit}}$$

Dans l''exemple ci-dessus, le tronc a un volume de $500 - 108 = 392$ cm³.

## Exercice d''application

Un cône a un rayon de base de 8 cm et une hauteur de 12 cm. On le coupe à mi-hauteur. Calcule le volume du petit cône et celui du tronc, en prenant $\pi \approx 3{,}14$.

Correction. Le coefficient vaut $k = 0{,}5$. Le volume du grand cône vaut $\dfrac{\pi \times 64 \times 12}{3} \approx 803{,}8$ cm³. Le volume du petit vaut $803{,}8 \times 0{,}5^{3} = 803{,}8 \times 0{,}125 \approx 100{,}5$ cm³. Le tronc a donc un volume d''environ $803{,}8 - 100{,}5 = 703{,}3$ cm³.', NULL, 15),
    (v_chapitre_id, 'Simulation : couper la pyramide', 3, 'interactif', '{
  "widget": "section-pyramide",
  "consigne": "Mets le coefficient $k$ à $0{,}5$ et compare les trois rapports affichés : les longueurs sont divisées par 2, les aires par 4, les volumes par 8. Beaucoup d''élèves pensent qu''à mi-hauteur le petit solide fait la moitié du grand, alors qu''il n''en fait que le huitième. Passe ensuite au cône de révolution : les règles sont exactement les mêmes."
}', NULL, 10),
    (v_chapitre_id, 'Quiz : sections et réductions', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "On coupe un cône par un plan parallèle à sa base. La section est :",
      "choix": [
        "un triangle",
        "un disque",
        "un rectangle"
      ],
      "bonne": 1,
      "explication": "La section d''un cône de révolution par un plan parallèle à la base est un disque, plus petit que la base."
    },
    {
      "question": "Avec un coefficient de réduction $k = 0{,}5$, le volume du petit solide vaut :",
      "choix": [
        "la moitié du grand",
        "le quart du grand",
        "le huitième du grand"
      ],
      "bonne": 2,
      "explication": "Les volumes sont multipliés par $k^{3} = 0{,}125$, soit un huitième."
    },
    {
      "question": "Une pyramide de hauteur 20 cm est coupée à 15 cm du sommet. Le coefficient vaut :",
      "choix": [
        "$0{,}75$",
        "$1{,}33$",
        "$5$"
      ],
      "bonne": 0,
      "explication": "$k = \\dfrac{15}{20} = 0{,}75$. On divise toujours la hauteur du petit par celle du grand."
    },
    {
      "question": "Une base carrée de 8 cm de côté, réduite avec $k = 0{,}25$, donne une section de côté :",
      "choix": [
        "$2$ cm",
        "$4$ cm",
        "$0{,}5$ cm"
      ],
      "bonne": 0,
      "explication": "Les longueurs sont multipliées par $k$, donc $8 \\times 0{,}25 = 2$ cm."
    }
  ]
}', NULL, 5),
    (v_chapitre_id, 'Exercices d''entraînement corrigés', 5, 'texte', '## Exercice 1

Une pyramide régulière a une base carrée de 12 cm de côté et une hauteur de 18 cm. On la coupe par un plan parallèle à la base, à 6 cm du sommet.

a) Donne le coefficient de réduction.
b) Calcule le côté de la section.
c) Calcule le volume de la pyramide réduite.

Correction. a) $k = \dfrac{6}{18} = \dfrac{1}{3}$. b) Le côté vaut $12 \times \dfrac{1}{3} = 4$ cm. c) Le volume de départ vaut $\dfrac{144 \times 18}{3} = 864$ cm³, donc le volume réduit vaut $864 \times \left(\dfrac{1}{3}\right)^{3} = \dfrac{864}{27} = 32$ cm³.

## Exercice 2

Un seau a la forme d''un tronc de cône. Le cône complet aurait 30 cm de hauteur et 10 cm de rayon. Le seau s''obtient en coupant à 12 cm du sommet. Calcule le volume du seau, avec $\pi \approx 3{,}14$.

Correction. $k = \dfrac{12}{30} = 0{,}4$. Le volume du grand cône vaut $\dfrac{3{,}14 \times 100 \times 30}{3} = 3\,140$ cm³. Le petit cône a un volume de $3\,140 \times 0{,}4^{3} = 3\,140 \times 0{,}064 \approx 201$ cm³. Le seau a donc un volume d''environ $3\,140 - 201 = 2\,939$ cm³, soit près de 2,9 litres.

## Exercice 3

L''aire de la base d''une pyramide vaut 50 cm². Celle de la section parallèle vaut 18 cm². Quel est le coefficient de réduction ?

Correction. Les aires sont dans le rapport $k^{2}$, donc $k^{2} = \dfrac{18}{50} = 0{,}36$, et $k = \sqrt{0{,}36} = 0{,}6$.

## Exercice 4

Le volume d''une pyramide réduite vaut 27 cm³, celui de la pyramide de départ 216 cm³. Donne le coefficient de réduction, puis le rapport des hauteurs.

Correction. $k^{3} = \dfrac{27}{216} = \dfrac{1}{8}$, donc $k = \dfrac{1}{2}$. Les hauteurs sont donc dans le rapport $\dfrac{1}{2}$ : la coupe a été faite à mi-hauteur.', NULL, 15),
    (v_chapitre_id, 'Activité d''intégration : le silo à grains', 6, 'texte', '## La situation

Un agriculteur de Ngaoundéré possède un silo en forme de tronc de cône, posé sur sa grande base.

Le cône complet dont il est issu aurait une hauteur de 6 m et un rayon de base de 2 m. Le silo s''arrête à 2 m du sommet, qui a été supprimé.

On prendra $\pi \approx 3{,}14$.

1. Donne le coefficient de réduction du petit cône supprimé.
2. Calcule le rayon du dessus du silo.
3. Calcule le volume du silo, en mètres cubes puis en litres.
4. Un sac de maïs occupe 50 litres. Combien de sacs le silo peut-il contenir ?

## La solution

1. Le petit cône supprimé a une hauteur de 2 m, pour un cône complet de 6 m. Le coefficient vaut
$$k = \dfrac{2}{6} = \dfrac{1}{3}$$

2. Le rayon du dessus du silo est celui de la section, donc $2 \times \dfrac{1}{3} \approx 0{,}67$ m.

3. Le volume du cône complet vaut
$$V = \dfrac{\pi R^{2} h}{3} = \dfrac{3{,}14 \times 4 \times 6}{3} = 25{,}12 \text{ m}^{3}$$

Le petit cône supprimé a un volume de $25{,}12 \times \left(\dfrac{1}{3}\right)^{3} = \dfrac{25{,}12}{27} \approx 0{,}93$ m³.

Le silo a donc un volume de $25{,}12 - 0{,}93 = 24{,}19$ m³. Comme 1 m³ vaut 1 000 litres, cela fait environ 24 190 litres.

4. Avec des sacs de 50 litres, le silo contient $\dfrac{24\,190}{50} \approx 483$ sacs.

## Ce qu''il faut remarquer

Le petit cône supprimé représente le tiers de la hauteur, mais seulement $\dfrac{1}{27}$ du volume, soit moins de 4 %. En coupant la pointe, on ne perd presque rien. C''est exactement pour cette raison que les silos, les seaux et les entonnoirs ont cette forme tronquée : on gagne une ouverture pratique en haut, en sacrifiant très peu de capacité.', NULL, 15);

  RAISE NOTICE 'Chapitre 16, Section d''une pyramide ou d''un cône de révolution par un plan parallèle à la base : 6 lecons ajoutees.';
END $m3$;
