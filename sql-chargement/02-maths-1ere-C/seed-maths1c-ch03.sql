-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 3, Trigonométrie
-- Module 21 : Relations et opérations fondamentales dans l'ensemble des nombres réels
-- 6 leçons.
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
  WHERE programme_id = v_programme_id AND ordre = 3;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Trigonométrie', 3, 'Module 21 : Relations et opérations fondamentales dans l''ensemble des nombres réels')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 3 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 3 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Les formules de transformation', 1, 'texte', 'La trigonométrie de Première repose sur une poignée de formules. Tu n''as pas besoin de toutes les retenir par cœur : les deux premières suffisent, le reste s''en déduit.

## Les formules d''addition

$$\cos(a + b) = \cos a \cos b - \sin a \sin b$$
$$\sin(a + b) = \sin a \cos b + \cos a \sin b$$

Pour la soustraction, remplace $b$ par $-b$. Comme $\cos(-b) = \cos b$ et $\sin(-b) = -\sin b$ :
$$\cos(a - b) = \cos a \cos b + \sin a \sin b$$
$$\sin(a - b) = \sin a \cos b - \cos a \sin b$$

Attention au signe de la formule du cosinus : il est inversé par rapport à ce qu''on attendrait. C''est le piège classique.

## Les formules de duplication

Fais $b = a$ dans les formules d''addition.
$$\cos 2a = \cos^{2} a - \sin^{2} a = 2\cos^{2}a - 1 = 1 - 2\sin^{2}a$$
$$\sin 2a = 2 \sin a \cos a$$

Les trois écritures de $\cos 2a$ sont équivalentes grâce à $\cos^{2}a + \sin^{2}a = 1$. Choisis celle qui t''arrange.

## Les formules de linéarisation

En retournant les écritures de $\cos 2a$ :
$$\cos^{2} a = \dfrac{1 + \cos 2a}{2} \qquad \sin^{2} a = \dfrac{1 - \cos 2a}{2}$$

Elles servent à transformer un carré en quelque chose de linéaire, ce qui est très utile pour calculer des intégrales en Terminale.

## Un calcul exact

Combien vaut $\cos 75°$ ?

Comme $75 = 45 + 30$,
$$\cos 75° = \cos 45° \cos 30° - \sin 45° \sin 30° = \dfrac{\sqrt{2}}{2}\times\dfrac{\sqrt{3}}{2} - \dfrac{\sqrt{2}}{2}\times\dfrac{1}{2}$$

ce qui donne
$$\cos 75° = \dfrac{\sqrt{6} - \sqrt{2}}{4}$$

Avec la calculatrice, $\dfrac{2{,}449 - 1{,}414}{4} \approx 0{,}259$, et $\cos 75° \approx 0{,}259$. C''est cohérent.

## Exercice d''application

Montre que $\sin 3a = 3\sin a - 4\sin^{3} a$.

Correction. On écrit $\sin 3a = \sin(2a + a) = \sin 2a \cos a + \cos 2a \sin a$.

Donc $\sin 3a = 2 \sin a \cos^{2} a + (1 - 2\sin^{2}a)\sin a$.

Or $\cos^{2} a = 1 - \sin^{2} a$, donc $\sin 3a = 2\sin a - 2\sin^{3}a + \sin a - 2\sin^{3}a$, c''est-à-dire $3\sin a - 4\sin^{3}a$.', NULL, 15),
    (v_chapitre_id, 'Le cercle trigonométrique en main', 2, 'interactif', '{
  "widget": "cercle-trigo",
  "consigne": "Place M à 30°, puis à 150°. Que remarques-tu sur les cosinus ? Et sur les sinus ? Place ensuite M à 60° et à 300°, et recommence l''observation."
}', NULL, 10),
    (v_chapitre_id, 'Résoudre cos x = a, sin x = a, tan x = a', 3, 'texte', 'Ces trois équations reviennent partout. Leur résolution suit toujours le même schéma : trouver une solution particulière, puis écrire toutes les autres.

## L''équation cos x = cos α

$$\cos x = \cos \alpha \iff x = \alpha + 2k\pi \quad \text{ou} \quad x = -\alpha + 2k\pi, \quad k \in \mathbb{Z}$$

Sur le cercle, les deux points qui ont le même cosinus sont symétriques par rapport à l''axe des abscisses.

Résolvons $\cos x = \dfrac{1}{2}$ dans $[0\,;2\pi[$.

Comme $\cos\dfrac{\pi}{3} = \dfrac{1}{2}$, les solutions sont $x = \dfrac{\pi}{3}$ et $x = -\dfrac{\pi}{3}$, soit $\dfrac{5\pi}{3}$ dans l''intervalle demandé. Donc $S = \left\{\dfrac{\pi}{3}\,;\dfrac{5\pi}{3}\right\}$.

## L''équation sin x = sin α

$$\sin x = \sin \alpha \iff x = \alpha + 2k\pi \quad \text{ou} \quad x = \pi - \alpha + 2k\pi$$

Cette fois les deux points sont symétriques par rapport à l''axe des ordonnées.

Résolvons $\sin x = \dfrac{\sqrt{3}}{2}$ dans $[0\,;2\pi[$. Comme $\sin\dfrac{\pi}{3} = \dfrac{\sqrt{3}}{2}$, les solutions sont $\dfrac{\pi}{3}$ et $\pi - \dfrac{\pi}{3} = \dfrac{2\pi}{3}$.

## L''équation tan x = tan α

$$\tan x = \tan \alpha \iff x = \alpha + k\pi$$

Le $\pi$ au lieu du $2\pi$ vient du fait que la tangente a pour période $\pi$. Les deux points sont diamétralement opposés.

## Quand il n''y a pas de solution

$\cos x$ et $\sin x$ sont toujours compris entre $-1$ et 1. Donc $\cos x = 2$ n''a aucune solution. Vérifie toujours cela en premier, cela t''évite de chercher pour rien.

La tangente, elle, prend toutes les valeurs réelles. $\tan x = 1\,000$ a bien des solutions.

## Exercice d''application

Résous $\cos 2x = \dfrac{\sqrt{2}}{2}$ dans $[0\,;2\pi[$.

Correction. On pose $X = 2x$. Alors $\cos X = \cos\dfrac{\pi}{4}$, donc $X = \dfrac{\pi}{4} + 2k\pi$ ou $X = -\dfrac{\pi}{4} + 2k\pi$.

Donc $x = \dfrac{\pi}{8} + k\pi$ ou $x = -\dfrac{\pi}{8} + k\pi$.

Dans $[0\,;2\pi[$, cela donne $\dfrac{\pi}{8}$, $\dfrac{9\pi}{8}$, $\dfrac{7\pi}{8}$ et $\dfrac{15\pi}{8}$.

Fais attention : comme l''inconnue est $2x$, il faut parcourir $X$ dans $[0\,;4\pi[$, ce qui donne bien quatre solutions pour $x$.', NULL, 15),
    (v_chapitre_id, 'Résoudre a cos x + b sin x = c', 4, 'texte', 'Voici le type d''équation qui fait peur, alors qu''une seule astuce suffit.

## L''idée : tout ramener à un seul cosinus

On veut écrire $a\cos x + b\sin x$ sous la forme $r\cos(x - \varphi)$.

On pose $r = \sqrt{a^{2} + b^{2}}$. Puis on factorise :
$$a\cos x + b\sin x = r\left(\dfrac{a}{r}\cos x + \dfrac{b}{r}\sin x\right)$$

Le point de coordonnées $\left(\dfrac{a}{r}\,;\dfrac{b}{r}\right)$ est sur le cercle trigonométrique, puisque la somme des carrés vaut 1. Il existe donc un angle $\varphi$ tel que $\cos\varphi = \dfrac{a}{r}$ et $\sin\varphi = \dfrac{b}{r}$.

Alors
$$a\cos x + b\sin x = r(\cos\varphi\cos x + \sin\varphi\sin x) = r\cos(x - \varphi)$$

## Un exemple

Résolvons $\cos x + \sqrt{3}\sin x = 1$.

Ici $a = 1$, $b = \sqrt{3}$, donc $r = \sqrt{1 + 3} = 2$.

On cherche $\varphi$ avec $\cos\varphi = \dfrac{1}{2}$ et $\sin\varphi = \dfrac{\sqrt{3}}{2}$. C''est $\varphi = \dfrac{\pi}{3}$.

L''équation devient $2\cos\left(x - \dfrac{\pi}{3}\right) = 1$, soit $\cos\left(x - \dfrac{\pi}{3}\right) = \dfrac{1}{2}$.

Donc $x - \dfrac{\pi}{3} = \pm\dfrac{\pi}{3} + 2k\pi$.

Cela donne $x = \dfrac{2\pi}{3} + 2k\pi$ ou $x = 2k\pi$.

Dans $[0\,;2\pi[$, $S = \left\{0\,;\dfrac{2\pi}{3}\right\}$.

Vérifie avec $x = 0$ : $\cos 0 + \sqrt{3}\sin 0 = 1$. C''est bon.

## Quand il n''y a pas de solution

Comme $r\cos(x - \varphi)$ reste entre $-r$ et $r$, l''équation $a\cos x + b\sin x = c$ n''a de solution que si $|c| \leq \sqrt{a^{2} + b^{2}}$.

Par exemple $3\cos x + 4\sin x = 7$ n''a pas de solution, car $r = 5$ et $7 > 5$.

C''est le premier réflexe à avoir : compare $|c|$ et $r$ avant tout calcul.

## Exercice d''application

Résous $\sqrt{3}\cos x - \sin x = \sqrt{3}$ dans $[0\,;2\pi[$.

Correction. On a $r = \sqrt{3 + 1} = 2$. On cherche $\varphi$ avec $\cos\varphi = \dfrac{\sqrt{3}}{2}$ et $\sin\varphi = -\dfrac{1}{2}$, donc $\varphi = -\dfrac{\pi}{6}$.

L''équation devient $2\cos\left(x + \dfrac{\pi}{6}\right) = \sqrt{3}$, soit $\cos\left(x + \dfrac{\pi}{6}\right) = \dfrac{\sqrt{3}}{2}$.

Donc $x + \dfrac{\pi}{6} = \pm\dfrac{\pi}{6} + 2k\pi$, ce qui donne $x = 0$ ou $x = -\dfrac{\pi}{3} + 2k\pi$.

Dans $[0\,;2\pi[$, $S = \left\{0\,;\dfrac{5\pi}{3}\right\}$.', NULL, 15),
    (v_chapitre_id, 'Les inéquations trigonométriques', 5, 'texte', 'Pour une inéquation, le cercle trigonométrique est ton meilleur outil. Tu y lis la réponse directement.

## La méthode en trois temps

D''abord tu résous l''équation correspondante, pour trouver les points frontières. Ensuite tu places ces points sur le cercle. Enfin tu lis l''arc qui convient.

## Un exemple avec le cosinus

Résolvons $\cos x \geq \dfrac{1}{2}$ sur $[0\,;2\pi[$.

L''égalité $\cos x = \dfrac{1}{2}$ donne $\dfrac{\pi}{3}$ et $\dfrac{5\pi}{3}$.

Sur le cercle, le cosinus est l''abscisse. Les points dont l''abscisse dépasse $\dfrac{1}{2}$ forment l''arc à droite de la verticale d''abscisse $\dfrac{1}{2}$. Cet arc va de $\dfrac{5\pi}{3}$ à $2\pi$ puis de 0 à $\dfrac{\pi}{3}$.

Donc $S = \left[0\,;\dfrac{\pi}{3}\right] \cup \left[\dfrac{5\pi}{3}\,;2\pi\right[$.

## Un exemple avec le sinus

Résolvons $\sin x < \dfrac{\sqrt{2}}{2}$ sur $[0\,;2\pi[$.

L''égalité donne $\dfrac{\pi}{4}$ et $\dfrac{3\pi}{4}$.

Le sinus est l''ordonnée. Les points dont l''ordonnée est inférieure à $\dfrac{\sqrt{2}}{2}$ sont ceux situés sous la droite horizontale correspondante. Cela exclut l''arc entre $\dfrac{\pi}{4}$ et $\dfrac{3\pi}{4}$.

Donc $S = \left[0\,;\dfrac{\pi}{4}\right[ \;\cup\; \left]\dfrac{3\pi}{4}\,;2\pi\right[$.

## Le cas a cos x + b sin x comparé à c

Tu commences par écrire $r\cos(x - \varphi)$, comme pour l''équation, puis tu te ramènes à une inéquation en cosinus.

Pour $\cos x + \sqrt{3}\sin x \geq 1$, on obtient $2\cos\left(x - \dfrac{\pi}{3}\right) \geq 1$, soit $\cos\left(x - \dfrac{\pi}{3}\right) \geq \dfrac{1}{2}$.

En posant $X = x - \dfrac{\pi}{3}$, on sait que $X$ doit être dans $\left[-\dfrac{\pi}{3}\,;\dfrac{\pi}{3}\right]$ modulo $2\pi$.

Donc $x$ est dans $\left[0\,;\dfrac{2\pi}{3}\right]$ modulo $2\pi$.

## Exercice d''application

Résous $2\sin x + 1 > 0$ sur $[0\,;2\pi[$.

Correction. L''inéquation s''écrit $\sin x > -\dfrac{1}{2}$.

L''égalité $\sin x = -\dfrac{1}{2}$ donne $x = -\dfrac{\pi}{6}$, soit $\dfrac{11\pi}{6}$, et $x = \pi + \dfrac{\pi}{6} = \dfrac{7\pi}{6}$.

Le sinus est supérieur à $-\dfrac{1}{2}$ au-dessus de la droite horizontale, c''est-à-dire sur le grand arc qui contient le haut du cercle.

Donc $S = \left[0\,;\dfrac{7\pi}{6}\right[ \;\cup\; \left]\dfrac{11\pi}{6}\,;2\pi\right[$.', NULL, 15),
    (v_chapitre_id, 'Quiz du chapitre 3', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "cos(a + b) est égal à :",
      "choix": [
        "cos a cos b − sin a sin b",
        "cos a cos b + sin a sin b",
        "cos a + cos b",
        "sin a cos b + cos a sin b"
      ],
      "bonne": 0,
      "explication": "Le signe est inversé dans la formule du cosinus. C''est l''erreur la plus fréquente."
    },
    {
      "question": "L''équation cos x = 3 admet :",
      "choix": [
        "aucune solution",
        "deux solutions par tour",
        "une infinité de solutions",
        "une solution unique"
      ],
      "bonne": 0,
      "explication": "Le cosinus reste toujours entre −1 et 1. Une valeur de 3 est impossible."
    },
    {
      "question": "Pour résoudre 3cos x + 4sin x = c, on écrit l''expression sous la forme r cos(x − φ) avec r égal à :",
      "choix": [
        "5",
        "7",
        "12",
        "25"
      ],
      "bonne": 0,
      "explication": "r = √(a² + b²) = √(9 + 16) = √25 = 5."
    },
    {
      "question": "Dans [0 ; 2π[, les solutions de sin x = sin α sont :",
      "choix": [
        "α et π − α",
        "α et −α",
        "α et α + π",
        "α seulement"
      ],
      "bonne": 0,
      "explication": "Deux angles ont le même sinus quand ils sont symétriques par rapport à l''axe des ordonnées, donc x = α ou x = π − α."
    },
    {
      "question": "sin 2a vaut :",
      "choix": [
        "2 sin a cos a",
        "sin²a − cos²a",
        "2 sin a",
        "1 − 2cos²a"
      ],
      "bonne": 0,
      "explication": "On applique la formule d''addition avec b = a : sin(a + a) = sin a cos a + cos a sin a = 2 sin a cos a."
    },
    {
      "question": "L''équation 3cos x + 4sin x = 7 :",
      "choix": [
        "n''a pas de solution car 7 > 5",
        "a deux solutions",
        "a une solution unique",
        "a une infinité de solutions"
      ],
      "bonne": 0,
      "explication": "L''expression s''écrit 5cos(x − φ), qui reste entre −5 et 5. Elle ne peut jamais valoir 7."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 3, Trigonométrie : 6 lecons ajoutees.';
END $p1c$;
