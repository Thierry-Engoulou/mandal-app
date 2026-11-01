-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 7, Dérivation
-- Module 21 : Relations et opérations fondamentales dans l'ensemble des nombres réels
-- 5 leçons.
--
-- Autonome : ce fichier cree lui-meme la matiere, la classe, le programme et
-- le chapitre s'ils n'existent pas encore. Lancez-le seul, dans n'importe
-- quel ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $p1c$
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
  WHERE p.titre = 'Mathématiques — 1ère C';

  -- 2. sinon on le cree
  IF v_programme_id IS NULL THEN
    INSERT INTO public.matieres (nom) VALUES ('Mathématiques') ON CONFLICT (nom) DO NOTHING;
    SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Mathématiques';

    SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
    IF v_nb_etabs <> 1 THEN
      RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
    END IF;
    SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

    -- la classe, quelle que soit la facon dont elle a ete ecrite
    SELECT id INTO v_classe_id FROM public.classes
    WHERE etablissement_id = v_etab_id
      AND (nom = '1ère C' OR nom ILIKE '1%re C' OR nom ILIKE 'Premi%re C')
    ORDER BY (nom = '1ère C') DESC
    LIMIT 1;

    -- si elle n'existe pas, on la cree
    IF v_classe_id IS NULL THEN
      INSERT INTO public.classes (etablissement_id, nom, niveau, filiere)
      VALUES (v_etab_id, '1ère C', 'Première', 'C')
      RETURNING id INTO v_classe_id;
      RAISE NOTICE 'Classe "1ère C" creee.';
    END IF;

    INSERT INTO public.programmes (matiere_id, classe_id, etablissement_id, titre, description)
    VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Mathématiques — 1ère C',
            'Programme officiel de Mathématiques, classe de Première C (Cameroun) — 4 modules, 21 chapitres.')
    RETURNING id INTO v_programme_id;
    RAISE NOTICE 'Programme "Mathématiques — 1ère C" cree.';
  END IF;

  -- 3. le chapitre existe-t-il deja ?
  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 7;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Dérivation', 7, 'Module 21 : Relations et opérations fondamentales dans l''ensemble des nombres réels')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 7 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 7 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Le nombre dérivé', 1, 'texte', 'Le nombre dérivé mesure la vitesse à laquelle une fonction change. C''est l''une des idées les plus utiles de toutes les mathématiques.

## D''où vient l''idée

Entre deux points $A(a\,;f(a))$ et $M(a+h\,;f(a+h))$ de la courbe, la droite $(AM)$ a pour coefficient directeur
$$\dfrac{f(a+h) - f(a)}{h}$$

C''est le taux de variation. Il mesure la pente moyenne entre les deux points.

Maintenant fais tendre $h$ vers 0. Le point $M$ glisse vers $A$, et la sécante $(AM)$ se rapproche d''une position limite : la tangente en $A$.

## La définition

$f$ est dérivable en $a$ si le taux de variation a une limite finie quand $h$ tend vers 0. Cette limite s''appelle le nombre dérivé et se note $f''(a)$.
$$f''(a) = \lim_{h \to 0} \dfrac{f(a+h) - f(a)}{h}$$

## Ce que ça veut dire

$f''(a)$ est le coefficient directeur de la tangente à la courbe au point d''abscisse $a$.

L''équation de cette tangente est
$$y = f''(a)(x - a) + f(a)$$

Retiens cette formule, elle tombe à chaque devoir.

## Un calcul complet

Soit $f(x) = x^{2}$ et $a = 3$.

$$\dfrac{f(3+h) - f(3)}{h} = \dfrac{(3+h)^{2} - 9}{h} = \dfrac{9 + 6h + h^{2} - 9}{h} = \dfrac{h(6 + h)}{h} = 6 + h$$

Quand $h$ tend vers 0, cela tend vers 6. Donc $f''(3) = 6$.

La tangente en $x = 3$ a pour équation $y = 6(x - 3) + 9$, soit $y = 6x - 9$.

## Dérivable implique continue

Si $f$ est dérivable en $a$, alors $f$ est continue en $a$.

La réciproque est fausse. La fonction valeur absolue est continue en 0, mais elle n''y est pas dérivable : à gauche le taux vaut $-1$, à droite il vaut $1$. La courbe forme un angle, il n''y a pas de tangente unique.

## Exercice d''application

Calcule le nombre dérivé de $f(x) = \dfrac{1}{x}$ en $a = 2$, puis écris l''équation de la tangente.

Correction. Le taux vaut
$$\dfrac{\frac{1}{2+h} - \frac{1}{2}}{h} = \dfrac{\frac{2 - (2+h)}{2(2+h)}}{h} = \dfrac{-h}{2h(2+h)} = \dfrac{-1}{2(2+h)}$$

Quand $h$ tend vers 0, cela tend vers $-\dfrac{1}{4}$. Donc $f''(2) = -\dfrac{1}{4}$.

Comme $f(2) = \dfrac{1}{2}$, la tangente a pour équation $y = -\dfrac{1}{4}(x - 2) + \dfrac{1}{2}$, soit $y = -\dfrac{x}{4} + 1$.', NULL, 15),
    (v_chapitre_id, 'De la sécante à la tangente', 2, 'interactif', '{
  "widget": "derivee-tangente",
  "consigne": "Fais diminuer $h$ petit à petit et regarde la sécante pivoter. Vers quelle droite se stabilise-t-elle ? Compare le coefficient directeur affiché avec le nombre dérivé que tu calcules à la main."
}', NULL, 10),
    (v_chapitre_id, 'La fonction dérivée et les formules', 3, 'texte', 'Plutôt que de recalculer une limite à chaque point, on calcule une fois pour toutes la fonction qui donne le nombre dérivé en chaque point.

## Les dérivées de référence

$$(k)'' = 0 \qquad (x)'' = 1 \qquad (x^{n})'' = n x^{n-1}$$
$$\left(\dfrac{1}{x}\right)'' = -\dfrac{1}{x^{2}} \qquad \left(\sqrt{x}\right)'' = \dfrac{1}{2\sqrt{x}}$$
$$(\sin x)'' = \cos x \qquad (\cos x)'' = -\sin x$$

Le signe moins de la dérivée du cosinus est à retenir absolument.

## Les opérations

$$(u + v)'' = u'' + v'' \qquad (ku)'' = k u''$$
$$(uv)'' = u''v + uv''$$
$$\left(\dfrac{u}{v}\right)'' = \dfrac{u''v - uv''}{v^{2}}$$
$$\left(\dfrac{1}{v}\right)'' = -\dfrac{v''}{v^{2}}$$

Dans la dérivée d''un quotient, l''ordre compte : c''est $u''v$ moins $uv''$, pas l''inverse.

## La composée

$$\big(u^{n}\big)'' = n u'' u^{n-1} \qquad \big(\sqrt{u}\big)'' = \dfrac{u''}{2\sqrt{u}}$$
$$\big(\sin u\big)'' = u'' \cos u \qquad \big(\cos u\big)'' = -u'' \sin u$$

La règle générale : tu dérives la fonction extérieure, puis tu multiplies par la dérivée de l''intérieur.

## Trois exemples

Pour $f(x) = 3x^{4} - 5x^{2} + 7x - 2$, on dérive terme à terme :
$$f''(x) = 12x^{3} - 10x + 7$$

Pour $g(x) = (2x - 1)(x^{2} + 3)$, on utilise la formule du produit avec $u = 2x - 1$ et $v = x^{2} + 3$ :
$$g''(x) = 2(x^{2} + 3) + (2x - 1)(2x) = 2x^{2} + 6 + 4x^{2} - 2x = 6x^{2} - 2x + 6$$

Pour $h(x) = \dfrac{x + 1}{x - 2}$, on utilise le quotient avec $u = x + 1$ et $v = x - 2$ :
$$h''(x) = \dfrac{1 \times (x - 2) - (x + 1) \times 1}{(x-2)^{2}} = \dfrac{-3}{(x-2)^{2}}$$

Cette dérivée est toujours négative, donc $h$ est décroissante sur chacun de ses intervalles.

## Exercice d''application

Dérive $f(x) = \sqrt{3x^{2} + 1}$ et $g(x) = \sin(2x + 1)$.

Correction. Pour $f$, on pose $u = 3x^{2} + 1$, donc $u'' = 6x$ et
$$f''(x) = \dfrac{6x}{2\sqrt{3x^{2}+1}} = \dfrac{3x}{\sqrt{3x^{2}+1}}$$

Pour $g$, on pose $u = 2x + 1$, donc $u'' = 2$ et $g''(x) = 2\cos(2x + 1)$.', NULL, 15),
    (v_chapitre_id, 'Dérivée et sens de variation', 4, 'texte', 'Voici pourquoi la dérivée est si utile : son signe donne directement le sens de variation.

## Le théorème

Soit $f$ dérivable sur un intervalle $I$.

Si $f''(x) > 0$ sur $I$, alors $f$ est strictement croissante sur $I$.

Si $f''(x) < 0$ sur $I$, alors $f$ est strictement décroissante sur $I$.

Si $f''(x) = 0$ sur $I$, alors $f$ est constante sur $I$.

## La méthode complète

Tu calcules $f''(x)$. Tu étudies son signe, souvent en la factorisant. Tu dresses le tableau de variations. Tu lis les extremums.

## Un exemple complet

Étudions $f(x) = x^{3} - 3x^{2} - 9x + 5$ sur $\mathbb{R}$.

$$f''(x) = 3x^{2} - 6x - 9 = 3(x^{2} - 2x - 3)$$

Le trinôme a pour discriminant $4 + 12 = 16$, et pour racines $-1$ et 3.

Comme le coefficient de $x^{2}$ est positif, $f''$ est positive à l''extérieur de $[-1\,;3]$ et négative entre $-1$ et 3.

Donc $f$ croît sur $]-\infty\,;-1]$, décroît sur $[-1\,;3]$, puis croît sur $[3\,;+\infty[$.

Elle atteint un maximum local en $-1$, qui vaut $f(-1) = -1 - 3 + 9 + 5 = 10$.

Elle atteint un minimum local en 3, qui vaut $f(3) = 27 - 27 - 27 + 5 = -22$.

## Les extremums

En un extremum local situé à l''intérieur de l''intervalle, la dérivée s''annule et change de signe.

Attention : la dérivée peut s''annuler sans qu''il y ait d''extremum. Pour $f(x) = x^{3}$, on a $f''(0) = 0$, mais $f$ est croissante partout. La tangente en 0 est horizontale, et la courbe la traverse. On parle de point d''inflexion.

La vraie condition est donc le changement de signe de $f''$, pas seulement son annulation.

## Une application concrète

Un éleveur de Bafoussam dispose de 60 mètres de grillage pour clôturer un enclos rectangulaire adossé à un mur. Le mur forme un côté, le grillage les trois autres. Quelles dimensions donnent la plus grande aire ?

Soit $x$ la largeur perpendiculaire au mur. Les deux largeurs consomment $2x$, il reste $60 - 2x$ pour la longueur.

L''aire vaut $A(x) = x(60 - 2x) = 60x - 2x^{2}$, pour $x$ dans $]0\,;30[$.

$$A''(x) = 60 - 4x$$

Elle s''annule en $x = 15$, est positive avant et négative après. L''aire est donc maximale pour $x = 15$.

L''enclos mesure 15 mètres sur 30 mètres, pour une aire de 450 mètres carrés.

## Exercice d''application

Étudie les variations de $f(x) = \dfrac{x^{2} + 1}{x}$ sur $]0\,;+\infty[$.

Correction. On écrit $f(x) = x + \dfrac{1}{x}$, donc $f''(x) = 1 - \dfrac{1}{x^{2}} = \dfrac{x^{2} - 1}{x^{2}}$.

Sur $]0\,;+\infty[$, le dénominateur est positif, donc $f''$ a le signe de $x^{2} - 1$.

Ainsi $f''$ est négative sur $]0\,;1[$ et positive sur $]1\,;+\infty[$.

La fonction décroît puis croît, avec un minimum en 1 qui vaut $f(1) = 2$.', NULL, 15),
    (v_chapitre_id, 'Quiz du chapitre 7', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "La dérivée de f(x) = x⁵ est :",
      "choix": [
        "5x⁴",
        "x⁴",
        "5x⁶",
        "4x⁵"
      ],
      "bonne": 0,
      "explication": "On applique (xⁿ)'' = n·xⁿ⁻¹, donc la dérivée vaut 5x⁴."
    },
    {
      "question": "L''équation de la tangente à la courbe de f au point d''abscisse a est :",
      "choix": [
        "y = f''(a)(x − a) + f(a)",
        "y = f(a)(x − a) + f''(a)",
        "y = f''(a)·x + a",
        "y = f''(x)(x − a)"
      ],
      "bonne": 0,
      "explication": "Le coefficient directeur est f''(a), et la droite passe par le point de coordonnées (a ; f(a))."
    },
    {
      "question": "La dérivée de cos x est :",
      "choix": [
        "−sin x",
        "sin x",
        "−cos x",
        "tan x"
      ],
      "bonne": 0,
      "explication": "La dérivée du cosinus porte un signe moins. C''est l''erreur la plus fréquente du chapitre."
    },
    {
      "question": "Si f''(x) < 0 sur un intervalle I, alors sur I la fonction f est :",
      "choix": [
        "strictement décroissante",
        "strictement croissante",
        "constante",
        "négative"
      ],
      "bonne": 0,
      "explication": "Le signe de la dérivée donne le sens de variation, pas le signe de la fonction elle-même."
    },
    {
      "question": "La dérivée de (u/v) vaut :",
      "choix": [
        "(u''v − uv'')/v²",
        "(uv'' − u''v)/v²",
        "u''/v''",
        "(u''v + uv'')/v²"
      ],
      "bonne": 0,
      "explication": "L''ordre est important : c''est u''v moins uv'', le tout divisé par v au carré."
    },
    {
      "question": "Pour f(x) = x³, on a f''(0) = 0. Cela signifie que :",
      "choix": [
        "la tangente en 0 est horizontale, mais il n''y a pas d''extremum",
        "0 est un maximum",
        "0 est un minimum",
        "f n''est pas dérivable en 0"
      ],
      "bonne": 0,
      "explication": "La dérivée s''annule sans changer de signe, donc la fonction reste croissante. Il faut un changement de signe pour avoir un extremum."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 7, Dérivation : 5 lecons ajoutees.';
END $p1c$;
