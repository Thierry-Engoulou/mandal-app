-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 13, Géométrie analytique dans le plan
-- Module 23 : Configurations et transformations élémentaires du plan
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
  WHERE programme_id = v_programme_id AND ordre = 13;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Géométrie analytique dans le plan', 13, 'Module 23 : Configurations et transformations élémentaires du plan')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 13 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 13 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Distance d''un point à une droite, équation normale', 1, 'texte', 'Le plan est muni d''un repère orthonormé. Toute droite s''écrit alors sous la forme $ax + by + c = 0$, et cette écriture cache deux informations précieuses.

## Le vecteur normal

Si une droite a pour équation $ax + by + c = 0$, alors le vecteur $\vec{n}(a\,;b)$ lui est perpendiculaire. On l''appelle vecteur normal.

Le vecteur directeur, lui, est $\vec{u}(-b\,;a)$. Tu vérifies facilement que $\vec{n} \cdot \vec{u} = -ab + ab = 0$.

Cette remarque permet d''écrire très vite l''équation d''une droite dont on connaît un point et une direction perpendiculaire.

## Trouver l''équation à partir d''un point et d''un vecteur normal

La droite passant par $A(x_{A}\,;y_{A})$ et de vecteur normal $\vec{n}(a\,;b)$ a pour équation
$$a(x - x_{A}) + b(y - y_{A}) = 0$$

Par exemple, la droite passant par $A(2\,;-1)$ et de vecteur normal $\vec{n}(3\,;4)$ a pour équation $3(x-2) + 4(y+1) = 0$, soit $3x + 4y - 2 = 0$.

## La distance d''un point à une droite

$$d(M, D) = \dfrac{|a x_{M} + b y_{M} + c|}{\sqrt{a^{2} + b^{2}}}$$

C''est la longueur du segment $[MH]$, où $H$ est le pied de la perpendiculaire issue de $M$. La formule évite d''avoir à construire $H$.

Les barres de valeur absolue sont indispensables : une distance est toujours positive.

## Un calcul

Distance du point $M(4\,;3)$ à la droite $3x - 4y + 5 = 0$.
$$d = \dfrac{|3 \times 4 - 4 \times 3 + 5|}{\sqrt{9 + 16}} = \dfrac{|12 - 12 + 5|}{5} = \dfrac{5}{5} = 1$$

Le point $M$ est donc à une unité de la droite.

## L''équation normale

Si tu divises toute l''équation par $\sqrt{a^{2} + b^{2}}$, tu obtiens l''équation normale. Le vecteur normal devient unitaire, et la distance se lit directement en remplaçant $x$ et $y$ par les coordonnées du point.

Pour $3x - 4y + 5 = 0$, la norme vaut 5, donc l''équation normale est
$$\dfrac{3}{5}x - \dfrac{4}{5}y + 1 = 0$$

## Deux applications classiques

Pour trouver l''ensemble des points à distance 2 d''une droite, tu écris $d(M, D) = 2$, ce qui donne deux droites parallèles, une de chaque côté.

Pour trouver les bissectrices de deux droites sécantes, tu écris que les distances aux deux droites sont égales. Tu obtiens deux droites perpendiculaires entre elles.

## Exercice d''application

Trouve la distance du point $A(1\,;2)$ à la droite $D$ d''équation $2x + y - 7 = 0$, puis les coordonnées du projeté orthogonal $H$ de $A$ sur $D$.

Correction. La distance vaut $\dfrac{|2 + 2 - 7|}{\sqrt{4+1}} = \dfrac{3}{\sqrt{5}} = \dfrac{3\sqrt{5}}{5} \approx 1{,}34$.

Pour $H$, on écrit que $\vec{AH}$ est colinéaire au vecteur normal $\vec{n}(2\,;1)$. Donc $H(1 + 2t\,;2 + t)$ pour un certain réel $t$.

Comme $H$ appartient à $D$, on a $2(1+2t) + (2+t) - 7 = 0$, soit $5t - 3 = 0$, donc $t = \dfrac{3}{5}$.

Ainsi $H\left(\dfrac{11}{5}\,;\dfrac{13}{5}\right)$.

Vérifie : $AH = \sqrt{\left(\dfrac{6}{5}\right)^{2} + \left(\dfrac{3}{5}\right)^{2}} = \dfrac{\sqrt{45}}{5} = \dfrac{3\sqrt{5}}{5}$. C''est bien la distance trouvée.', NULL, 15),
    (v_chapitre_id, 'Mesure la distance d''un point à une droite', 2, 'interactif', '{
  "widget": "distance-droite",
  "consigne": "Déplace $M$ et lis la distance. Place-le ensuite exactement sur la droite : que vaut $a x + b y + c$ à ce moment-là ? Change $a$ et $b$ et observe le vecteur normal vert tourner avec la droite."
}', NULL, 10),
    (v_chapitre_id, 'Le cercle : équations et tangentes', 3, 'texte', 'Le cercle est la deuxième grande figure de la géométrie analytique. Lui aussi se décrit par des équations.

## L''équation cartésienne

Le cercle de centre $\Omega(a\,;b)$ et de rayon $R$ a pour équation
$$(x - a)^{2} + (y - b)^{2} = R^{2}$$

Un point appartient au cercle si et seulement si sa distance au centre vaut $R$. L''équation n''est rien d''autre que cette phrase, écrite avec le théorème de Pythagore.

## L''équation développée

En développant, on obtient une forme du type
$$x^{2} + y^{2} - 2ax - 2by + c = 0$$

Pour retrouver le centre et le rayon à partir de cette forme, tu regroupes en carrés.

Prenons $x^{2} + y^{2} - 6x + 4y - 12 = 0$.

On écrit $x^{2} - 6x = (x-3)^{2} - 9$ et $y^{2} + 4y = (y+2)^{2} - 4$.

L''équation devient $(x-3)^{2} + (y+2)^{2} - 9 - 4 - 12 = 0$, soit $(x-3)^{2} + (y+2)^{2} = 25$.

C''est le cercle de centre $(3\,;-2)$ et de rayon 5.

Attention, toutes ces équations ne donnent pas un cercle. Si après regroupement tu obtiens un nombre négatif à droite, l''ensemble est vide. Si tu obtiens 0, c''est un point unique.

## La représentation paramétrique

$$\begin{cases} x = a + R\cos t \\ y = b + R\sin t \end{cases} \quad \text{avec } t \in [0\,;2\pi[$$

Quand $t$ parcourt un tour, le point parcourt tout le cercle. Cette écriture est très pratique pour décrire un mouvement circulaire.

## La tangente en un point du cercle

La tangente en un point $A$ du cercle est perpendiculaire au rayon $[\Omega A]$.

Donc le vecteur $\vec{\Omega A}$ est un vecteur normal de la tangente, et l''équation s''écrit immédiatement.

Pour le cercle de centre $(3\,;-2)$ et de rayon 5, le point $A(7\,;1)$ est sur le cercle, car $16 + 9 = 25$.

Le vecteur $\vec{\Omega A}(4\,;3)$ est normal à la tangente. Celle-ci a donc pour équation
$$4(x - 7) + 3(y - 1) = 0 \quad \text{soit} \quad 4x + 3y - 31 = 0$$

## Les tangentes issues d''un point extérieur

Si $P$ est à l''extérieur du cercle, il part de $P$ exactement deux tangentes.

La longueur commune de $P$ au point de contact vaut
$$PT = \sqrt{P\Omega^{2} - R^{2}}$$

C''est le théorème de Pythagore dans le triangle $\Omega TP$, rectangle en $T$.

Les points de contact se trouvent sur le cercle de diamètre $[\Omega P]$, puisque l''angle $\widehat{\Omega T P}$ est droit.

## Exercice d''application

Le cercle a pour équation $x^{2} + y^{2} = 9$ et le point $P$ a pour coordonnées $(5\,;0)$. Calcule la longueur des tangentes issues de $P$, puis les coordonnées des points de contact.

Correction. Le centre est l''origine et le rayon vaut 3. La distance $OP$ vaut 5.

Donc $PT = \sqrt{25 - 9} = 4$.

Pour les points de contact, un point $T(x\,;y)$ du cercle vérifie $x^{2} + y^{2} = 9$, et la perpendicularité donne $\vec{OT} \cdot \vec{TP} = 0$, soit $x(5 - x) - y^{2} = 0$, donc $5x = x^{2} + y^{2} = 9$ et $x = \dfrac{9}{5}$.

Alors $y^{2} = 9 - \dfrac{81}{25} = \dfrac{144}{25}$, donc $y = \pm\dfrac{12}{5}$.

Les points de contact sont $\left(\dfrac{9}{5}\,;\dfrac{12}{5}\right)$ et $\left(\dfrac{9}{5}\,;-\dfrac{12}{5}\right)$.', NULL, 15),
    (v_chapitre_id, 'Les tangentes issues d''un point', 4, 'interactif', '{
  "widget": "tangentes-cercle",
  "consigne": "Fais entrer $P$ à l''intérieur du cercle : combien de tangentes reste-t-il ? Place ensuite $P$ exactement sur le cercle. Enfin, ressors $P$ et vérifie que les deux longueurs $PT$ sont bien égales."
}', NULL, 10),
    (v_chapitre_id, 'Quiz du chapitre 13', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Un vecteur normal à la droite d''équation 3x − 5y + 1 = 0 est :",
      "choix": [
        "(3 ; −5)",
        "(−5 ; 3)",
        "(5 ; 3)",
        "(1 ; 1)"
      ],
      "bonne": 0,
      "explication": "Les coefficients de x et de y forment un vecteur normal. Le vecteur directeur serait (5 ; 3)."
    },
    {
      "question": "La distance du point M(4 ; 3) à la droite 3x − 4y + 5 = 0 vaut :",
      "choix": [
        "1",
        "5",
        "0,2",
        "25"
      ],
      "bonne": 0,
      "explication": "On applique |3×4 − 4×3 + 5| / √(9 + 16) = 5/5 = 1."
    },
    {
      "question": "L''équation x² + y² − 6x + 4y − 12 = 0 est celle du cercle :",
      "choix": [
        "de centre (3 ; −2) et de rayon 5",
        "de centre (−3 ; 2) et de rayon 5",
        "de centre (6 ; −4) et de rayon 12",
        "de centre (3 ; −2) et de rayon 25"
      ],
      "bonne": 0,
      "explication": "En regroupant en carrés on obtient (x − 3)² + (y + 2)² = 25, donc un rayon de 5."
    },
    {
      "question": "La tangente à un cercle en un point A de ce cercle est :",
      "choix": [
        "perpendiculaire au rayon [ΩA]",
        "parallèle au rayon [ΩA]",
        "passe par le centre",
        "de même longueur que le rayon"
      ],
      "bonne": 0,
      "explication": "Le rayon est donc un vecteur normal de la tangente, ce qui permet d''écrire son équation immédiatement."
    },
    {
      "question": "D''un point P situé à l''extérieur d''un cercle, on peut mener :",
      "choix": [
        "exactement deux tangentes, de même longueur",
        "une seule tangente",
        "une infinité de tangentes",
        "aucune tangente"
      ],
      "bonne": 0,
      "explication": "Les deux longueurs valent √(PΩ² − R²), par le théorème de Pythagore dans le triangle rectangle en T."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 13, Géométrie analytique dans le plan : 5 lecons ajoutees.';
END $p1c$;
