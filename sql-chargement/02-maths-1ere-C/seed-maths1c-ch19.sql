-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 19, Orthogonalité dans l''espace
-- Module 24 : Solides de l'espace
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
  WHERE programme_id = v_programme_id AND ordre = 19;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Orthogonalité dans l''espace', 19, 'Module 24 : Solides de l''espace')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 19 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 19 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Droites orthogonales dans l''espace', 1, 'texte', 'Dans le plan, deux droites perpendiculaires se coupent forcément. Dans l''espace, ce n''est plus vrai, et c''est la première chose à comprendre.

## Perpendiculaires ou orthogonales ?

Deux droites de l''espace sont orthogonales si leurs vecteurs directeurs ont un produit scalaire nul.

Elles sont perpendiculaires si, en plus, elles sont sécantes.

Toutes les droites perpendiculaires sont orthogonales, mais l''inverse est faux. Deux droites peuvent être orthogonales et ne jamais se rencontrer. On dit alors qu''elles ne sont pas coplanaires.

## Un exemple sur un cube

Prends un cube $ABCDEFGH$, avec $ABCD$ la face du bas et $EFGH$ celle du haut, $E$ au-dessus de $A$.

Les droites $(AB)$ et $(AE)$ sont perpendiculaires : elles se coupent en $A$ et forment un angle droit.

Les droites $(AB)$ et $(DH)$ sont orthogonales, mais pas perpendiculaires. Elles ne se rencontrent jamais, elles ne sont pas dans un même plan.

Pour s''en convaincre, place-toi dans une salle de classe. L''arête entre le sol et le mur de devant, et l''arête verticale du coin arrière, ne se touchent pas, et pourtant elles font bien un angle droit.

## Le test par le produit scalaire

Munis l''espace d''un repère orthonormé. Si $\vec{u}(x\,;y\,;z)$ et $\vec{v}(x''\,;y''\,;z'')$ sont des vecteurs directeurs, alors
$$\vec{u} \cdot \vec{v} = xx'' + yy'' + zz''$$

Les droites sont orthogonales si et seulement si ce nombre est nul.

Sur le cube de côté 1, avec $A$ à l''origine, $\vec{AB}(1\,;0\,;0)$ et $\vec{DH}(0\,;0\,;1)$. Leur produit scalaire vaut 0, les droites sont bien orthogonales.

## La norme et l''angle

$$\|\vec{u}\| = \sqrt{x^{2} + y^{2} + z^{2}}$$

$$\cos\theta = \dfrac{\vec{u} \cdot \vec{v}}{\|\vec{u}\|\,\|\vec{v}\|}$$

Cette dernière formule donne l''angle entre deux droites, même quand elles ne se coupent pas.

## Un calcul d''angle

Sur le cube de côté 1, quel angle font les diagonales $(AG)$ et $(BH)$ ?

Avec $A(0\,;0\,;0)$, $B(1\,;0\,;0)$, $G(1\,;1\,;1)$ et $H(0\,;1\,;1)$ :

$\vec{AG}(1\,;1\,;1)$ et $\vec{BH}(-1\,;1\,;1)$.

Le produit scalaire vaut $-1 + 1 + 1 = 1$. Les normes valent toutes deux $\sqrt{3}$.

Donc $\cos\theta = \dfrac{1}{3}$, ce qui donne $\theta \approx 70{,}5$ degrés. Les deux diagonales ne sont pas orthogonales.

## Exercice d''application

Sur le cube $ABCDEFGH$ de côté 1, les droites $(AC)$ et $(BG)$ sont-elles orthogonales ?

Correction. Avec $A(0\,;0\,;0)$, $B(1\,;0\,;0)$, $C(1\,;1\,;0)$ et $G(1\,;1\,;1)$ :

$\vec{AC}(1\,;1\,;0)$ et $\vec{BG}(0\,;1\,;1)$.

Le produit scalaire vaut $0 + 1 + 0 = 1$, il n''est pas nul. Les droites ne sont pas orthogonales.

L''angle vérifie $\cos\theta = \dfrac{1}{\sqrt{2}\sqrt{2}} = \dfrac{1}{2}$, donc $\theta = 60$ degrés.', NULL, 15),
    (v_chapitre_id, 'Droites et plans orthogonaux', 2, 'texte', 'Une droite peut être perpendiculaire à un plan tout entier. C''est une situation très utile, parce qu''elle donne d''un coup une infinité d''angles droits.

## La définition

Une droite $(d)$ est orthogonale à un plan $(P)$ si elle est orthogonale à toutes les droites de $(P)$.

## Le théorème qui change tout

Pour prouver qu''une droite est orthogonale à un plan, il suffit de montrer qu''elle est orthogonale à deux droites sécantes de ce plan.

Deux suffisent. C''est le théorème le plus utilisé du chapitre, parce qu''il transforme une infinité de vérifications en deux.

Attention, les deux droites doivent être sécantes. Si elles sont parallèles, la conclusion est fausse.

## Le vecteur normal

Si l''espace est muni d''un repère orthonormé, on appelle vecteur normal au plan tout vecteur directeur d''une droite orthogonale à ce plan.

Un plan d''équation $ax + by + cz + d = 0$ admet pour vecteur normal le vecteur $\vec{n}(a\,;b\,;c)$.

Une droite est orthogonale au plan si et seulement si son vecteur directeur est colinéaire à $\vec{n}$.

## Les conséquences à connaître

Si deux droites sont orthogonales à un même plan, elles sont parallèles entre elles.

Si deux plans sont orthogonaux à une même droite, ils sont parallèles entre eux.

Si une droite est orthogonale à un plan, tout plan qui la contient est perpendiculaire à ce plan.

## Le plan médiateur

Le plan médiateur d''un segment $[AB]$ est le plan perpendiculaire à $(AB)$ passant par le milieu de $[AB]$.

C''est l''ensemble des points équidistants de $A$ et $B$. Il joue dans l''espace le rôle que la médiatrice joue dans le plan.

## Deux plans perpendiculaires

Deux plans sont perpendiculaires si l''un contient une droite orthogonale à l''autre.

En termes de vecteurs normaux, deux plans sont perpendiculaires si et seulement si leurs vecteurs normaux sont orthogonaux :
$$\vec{n_{1}} \cdot \vec{n_{2}} = 0$$

Attention au piège : les plans sont perpendiculaires quand leurs normales le sont, et parallèles quand leurs normales sont colinéaires. C''est l''inverse de ce qu''on croit spontanément.

## Un exemple sur le cube

Montrons que la droite $(AE)$ est orthogonale au plan $(ABC)$, c''est-à-dire à la face du bas.

La droite $(AE)$ est orthogonale à $(AB)$ et à $(AD)$, qui sont deux droites sécantes en $A$ du plan de la face.

D''après le théorème, $(AE)$ est donc orthogonale au plan tout entier. Elle est en particulier orthogonale à la diagonale $(AC)$, et à $(BD)$.

## Exercice d''application

Sur le cube $ABCDEFGH$, montre que la droite $(BD)$ est orthogonale au plan $(ACE)$.

Correction. Prenons le repère d''origine $A$ avec $B(1\,;0\,;0)$, $D(0\,;1\,;0)$ et $E(0\,;0\,;1)$. Alors $C(1\,;1\,;0)$.

Le vecteur $\vec{BD}$ a pour coordonnées $(-1\,;1\,;0)$.

Le plan $(ACE)$ contient les vecteurs $\vec{AC}(1\,;1\,;0)$ et $\vec{AE}(0\,;0\,;1)$, qui ne sont pas colinéaires.

On calcule $\vec{BD} \cdot \vec{AC} = -1 + 1 + 0 = 0$, et $\vec{BD} \cdot \vec{AE} = 0$.

La droite $(BD)$ est orthogonale à deux droites sécantes du plan $(ACE)$, elle est donc orthogonale à ce plan.', NULL, 15),
    (v_chapitre_id, 'Teste l''orthogonalité sur un cube', 3, 'interactif', '{
  "widget": "cube-orthogonalite",
  "consigne": "Compare d''abord (AB) et (AE) : le produit scalaire est-il nul ? Compare ensuite (AB) et (DH), qui ne se rencontrent jamais. Passe enfin en mode droite et plan, et cherche une droite perpendiculaire à la face (ABCD)."
}', NULL, 10),
    (v_chapitre_id, 'Le cube et ses angles droits', 4, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 400" width="560" height="400" font-family="system-ui, Arial" font-size="13">
<rect width="560" height="400" fill="#ffffff"/>
<text x="280" y="24" text-anchor="middle" font-weight="700" fill="#0f172a">Orthogonales sans être sécantes</text>
<g stroke="#94a3b8" stroke-width="1.5" fill="none">
<polygon points="120,300 320,300 400,230 200,230"/>
<polygon points="120,120 320,120 400,50 200,50"/>
<line x1="120" y1="300" x2="120" y2="120"/><line x1="320" y1="300" x2="320" y2="120"/>
<line x1="400" y1="230" x2="400" y2="50"/><line x1="200" y1="230" x2="200" y2="50"/>
</g>
<line x1="120" y1="300" x2="320" y2="300" stroke="#dc2626" stroke-width="4.5"/>
<line x1="200" y1="230" x2="200" y2="50" stroke="#2563eb" stroke-width="4.5"/>
<g fill="#0f172a">
<circle cx="120" cy="300" r="4"/><circle cx="320" cy="300" r="4"/><circle cx="400" cy="230" r="4"/><circle cx="200" cy="230" r="4"/>
<circle cx="120" cy="120" r="4"/><circle cx="320" cy="120" r="4"/><circle cx="400" cy="50" r="4"/><circle cx="200" cy="50" r="4"/>
</g>
<g font-weight="700" font-size="14" fill="#0f172a">
<text x="104" y="318">A</text><text x="326" y="318">B</text><text x="408" y="244">C</text><text x="178" y="246">D</text>
<text x="104" y="114">E</text><text x="326" y="114">F</text><text x="408" y="44">G</text><text x="178" y="44">H</text>
</g>
<text x="215" y="296" fill="#dc2626" font-weight="700">(AB)</text>
<text x="208" y="146" fill="#2563eb" font-weight="700">(DH)</text>
<text x="416" y="150" fill="#16a34a" font-weight="700" font-size="11">vecteur AB (1 ; 0 ; 0)</text>
<text x="416" y="167" fill="#16a34a" font-weight="700" font-size="11">vecteur DH (0 ; 0 ; 1)</text>
<text x="416" y="184" fill="#16a34a" font-weight="700" font-size="11">produit scalaire = 0</text>
<text x="280" y="356" text-anchor="middle" fill="#334155" font-size="12">Les deux arêtes colorées ne se rencontrent jamais : elles ne sont pas dans un même plan.</text>
<text x="280" y="376" text-anchor="middle" fill="#334155" font-size="12">Leur produit scalaire est pourtant nul, elles sont donc orthogonales, mais pas perpendiculaires.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'TP : plans orthogonaux et distances dans l''espace', 5, 'texte', 'Un travail dirigé pour mettre bout à bout tout ce que tu viens de voir, sur une situation concrète.

## La situation

Un entrepôt de Douala a la forme d''un pavé droit $ABCDEFGH$. Le sol est le rectangle $ABCD$ avec $AB = 8$ mètres et $AD = 6$ mètres. La hauteur $AE$ vaut 4 mètres.

On place un repère orthonormé d''origine $A$, dont les axes suivent $[AB]$, $[AD]$ et $[AE]$, avec le mètre pour unité.

Les coordonnées sont alors $A(0\,;0\,;0)$, $B(8\,;0\,;0)$, $C(8\,;6\,;0)$, $D(0\,;6\,;0)$, $E(0\,;0\,;4)$, $F(8\,;0\,;4)$, $G(8\,;6\,;4)$ et $H(0\,;6\,;4)$.

## Première question : la grande diagonale

Calcule la longueur $AG$.

Le vecteur $\vec{AG}$ a pour coordonnées $(8\,;6\,;4)$, donc
$$AG = \sqrt{64 + 36 + 16} = \sqrt{116} \approx 10{,}77 \text{ mètres}$$

C''est la plus longue barre qu''on puisse faire entrer dans l''entrepôt.

## Deuxième question : un câble perpendiculaire

Un câble part de $A$ et doit être perpendiculaire au plan du mur $(ABFE)$. Dans quelle direction part-il ?

Le plan $(ABFE)$ est le mur d''équation $y = 0$. Son vecteur normal est $\vec{n}(0\,;1\,;0)$.

Le câble part donc dans la direction de $\vec{AD}$, c''est-à-dire horizontalement, vers l''intérieur de l''entrepôt.

## Troisième question : deux plans perpendiculaires

Montre que les plans $(ABCD)$ et $(ABFE)$ sont perpendiculaires.

Le plan du sol $(ABCD)$ a pour équation $z = 0$, de vecteur normal $\vec{n_{1}}(0\,;0\,;1)$.

Le plan du mur $(ABFE)$ a pour équation $y = 0$, de vecteur normal $\vec{n_{2}}(0\,;1\,;0)$.

Le produit scalaire vaut 0, donc les deux plans sont perpendiculaires. C''est bien ce qu''on attend d''un sol et d''un mur.

## Quatrième question : une droite orthogonale à un plan

La droite $(AE)$ est-elle orthogonale au plan du sol ?

Le vecteur $\vec{AE}(0\,;0\,;4)$ est colinéaire à $\vec{n_{1}}(0\,;0\,;1)$.

Donc oui, le poteau vertical est bien perpendiculaire au sol, et il est orthogonal à toutes les droites tracées sur le sol.

## Cinquième question : un angle

Un projecteur est fixé en $E$ et vise le coin $C$. Quel angle fait le faisceau avec la verticale $(EA)$ ?

Le vecteur $\vec{EC}$ a pour coordonnées $(8\,;6\,;-4)$ et le vecteur $\vec{EA}$ a pour coordonnées $(0\,;0\,;-4)$.

Le produit scalaire vaut 16. Les normes valent $\sqrt{116} \approx 10{,}77$ et 4.
$$\cos\theta = \dfrac{16}{10{,}77 \times 4} = \dfrac{16}{43{,}08} \approx 0{,}371$$

Donc $\theta \approx 68$ degrés.

## Sixième question : le plan médiateur

Un détecteur doit être placé à égale distance de $A$ et de $G$. Sur quel ensemble peut-on le mettre ?

C''est le plan médiateur de $[AG]$, perpendiculaire à $(AG)$ et passant par le milieu de $[AG]$, qui a pour coordonnées $(4\,;3\,;2)$.

Son équation s''écrit avec le vecteur normal $\vec{AG}(8\,;6\,;4)$ :
$$8(x - 4) + 6(y - 3) + 4(z - 2) = 0$$

ce qui donne, après simplification par 2,
$$4x + 3y + 2z - 29 = 0$$

Vérifie que le milieu $(4\,;3\,;2)$ satisfait bien cette équation : $16 + 9 + 4 - 29 = 0$.', NULL, 15),
    (v_chapitre_id, 'Quiz du chapitre 19', 6, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Deux droites de l''espace sont orthogonales et non sécantes. Elles sont :",
      "choix": [
        "orthogonales mais pas perpendiculaires",
        "perpendiculaires",
        "parallèles",
        "confondues"
      ],
      "bonne": 0,
      "explication": "Le mot perpendiculaire exige en plus que les droites se coupent. Dans l''espace, deux droites peuvent faire un angle droit sans jamais se rencontrer."
    },
    {
      "question": "Pour montrer qu''une droite est orthogonale à un plan, il suffit de montrer qu''elle est orthogonale à :",
      "choix": [
        "deux droites sécantes de ce plan",
        "une seule droite du plan",
        "toutes les droites du plan",
        "deux droites parallèles du plan"
      ],
      "bonne": 0,
      "explication": "Deux droites sécantes suffisent, et c''est ce qui rend le théorème si utile. Avec deux parallèles, la conclusion serait fausse."
    },
    {
      "question": "Le plan d''équation 2x − y + 3z − 5 = 0 admet pour vecteur normal :",
      "choix": [
        "(2 ; −1 ; 3)",
        "(2 ; −1 ; 3 ; −5)",
        "(−5 ; 0 ; 0)",
        "(1 ; 1 ; 1)"
      ],
      "bonne": 0,
      "explication": "Les coefficients de x, y et z forment directement un vecteur normal au plan."
    },
    {
      "question": "Deux plans sont perpendiculaires si et seulement si leurs vecteurs normaux sont :",
      "choix": [
        "orthogonaux",
        "colinéaires",
        "égaux",
        "unitaires"
      ],
      "bonne": 0,
      "explication": "C''est l''inverse de l''intuition. Normales colinéaires signifie plans parallèles, normales orthogonales signifie plans perpendiculaires."
    },
    {
      "question": "Dans un pavé de dimensions 8, 6 et 4, la grande diagonale mesure :",
      "choix": [
        "√116 ≈ 10,77",
        "18",
        "√18",
        "192"
      ],
      "bonne": 0,
      "explication": "On applique le Pythagore de l''espace : √(8² + 6² + 4²) = √116."
    },
    {
      "question": "L''ensemble des points équidistants de A et de B dans l''espace est :",
      "choix": [
        "le plan médiateur de [AB]",
        "la médiatrice de [AB]",
        "une sphère",
        "la droite (AB)"
      ],
      "bonne": 0,
      "explication": "C''est le plan perpendiculaire à (AB) passant par le milieu du segment. Il joue dans l''espace le rôle de la médiatrice du plan."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 19, Orthogonalité dans l''espace : 6 lecons ajoutees.';
END $p1c$;
