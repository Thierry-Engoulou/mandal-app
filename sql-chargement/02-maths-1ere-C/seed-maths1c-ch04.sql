-- ============================================================================
-- MANDAL — Mathématiques 1ère C : chapitre 4, Généralités sur les fonctions numériques, 1ère partie
-- Module 21 : Relations et opérations fondamentales dans l'ensemble des nombres réels
-- 4 leçons.
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
  WHERE programme_id = v_programme_id AND ordre = 4;

  -- 4. sinon on le cree
  IF v_chapitre_id IS NULL THEN
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_programme_id, 'Généralités sur les fonctions numériques, 1ère partie', 4, 'Module 21 : Relations et opérations fondamentales dans l''ensemble des nombres réels')
    RETURNING id INTO v_chapitre_id;
    RAISE NOTICE 'Chapitre 4 cree.';
  END IF;

  -- 5. les lecons
  SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 4 : contient deja % lecon(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Fonction, application, image et antécédent', 1, 'texte', 'Une fonction, c''est une machine. Tu lui donnes un nombre, elle en ressort un autre, et toujours le même pour une entrée donnée.

## Le vocabulaire exact

Soit $f$ une fonction de $\mathbb{R}$ vers $\mathbb{R}$.

L''ensemble de définition $D_{f}$ est l''ensemble des réels pour lesquels la machine fonctionne. Si $f(x) = \dfrac{1}{x - 3}$, alors $D_{f} = \mathbb{R} \setminus \{3\}$, parce qu''on ne divise pas par zéro.

Si $f(x) = \sqrt{x - 5}$, alors $D_{f} = [5\,;+\infty[$, parce que la racine veut du positif.

L''image de $a$ par $f$, c''est le nombre $f(a)$. Il y en a un seul.

Un antécédent de $b$ par $f$, c''est un nombre $x$ tel que $f(x) = b$. Il peut y en avoir zéro, un, ou plusieurs.

Par exemple pour $f(x) = x^{2}$, l''image de $-3$ est 9. Les antécédents de 9 sont $-3$ et 3. Le nombre $-4$ n''a aucun antécédent.

## Fonction ou application ?

On parle d''application quand chaque élément de l''ensemble de départ a bien une image. Autrement dit, quand $D_{f}$ est tout l''ensemble de départ.

La fonction $x \mapsto \dfrac{1}{x}$ est une fonction de $\mathbb{R}$ vers $\mathbb{R}$, mais pas une application de $\mathbb{R}$ vers $\mathbb{R}$, car 0 n''a pas d''image. En revanche, c''est une application de $\mathbb{R}^{*}$ vers $\mathbb{R}$.

## Injective, surjective, bijective

Ces trois mots décrivent la façon dont la machine relie le départ et l''arrivée.

$f$ est injective si deux nombres différents ont toujours des images différentes. Autrement dit, si $f(a) = f(b)$ entraîne $a = b$. Chaque élément d''arrivée a au plus un antécédent.

$f$ est surjective si tout élément de l''ensemble d''arrivée a au moins un antécédent. Rien n''est laissé de côté.

$f$ est bijective si elle est à la fois injective et surjective. Chaque élément d''arrivée a alors exactement un antécédent, et on peut définir la fonction réciproque $f^{-1}$.

## Comment le voir sur une courbe

Pour l''injectivité, trace des droites horizontales. Si aucune ne coupe la courbe plus d''une fois, la fonction est injective.

Pour la surjectivité vers $\mathbb{R}$, il faut que toute horizontale coupe la courbe au moins une fois.

La fonction $x \mapsto x^{2}$ de $\mathbb{R}$ vers $\mathbb{R}$ n''est ni injective, car l''horizontale $y = 9$ coupe deux fois, ni surjective, car l''horizontale $y = -1$ ne coupe pas.

En revanche $x \mapsto x^{2}$ de $[0\,;+\infty[$ vers $[0\,;+\infty[$ est bijective, et sa réciproque est la racine carrée.

## Exercice d''application

Détermine l''ensemble de définition de $f(x) = \dfrac{\sqrt{x + 1}}{x - 2}$, puis cherche les antécédents de 0.

Correction. Il faut $x + 1 \geq 0$, donc $x \geq -1$, et $x - 2 \neq 0$, donc $x \neq 2$.

Ainsi $D_{f} = [-1\,;2[ \;\cup\; ]2\,;+\infty[$.

Un antécédent de 0 vérifie $\dfrac{\sqrt{x+1}}{x - 2} = 0$, donc $\sqrt{x + 1} = 0$, donc $x = -1$. Ce nombre est bien dans $D_{f}$. Le seul antécédent de 0 est $-1$.', NULL, 15),
    (v_chapitre_id, 'Application, injection, surjection, bijection', 2, 'figure', '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 620 420" width="620" height="420" font-family="system-ui, Arial" font-size="13">
<rect width="620" height="420" fill="#ffffff"/>
<g stroke="#334155" fill="none" stroke-width="1.6">
<ellipse cx="90" cy="80" rx="52" ry="62"/><ellipse cx="250" cy="80" rx="52" ry="62"/>
<ellipse cx="400" cy="80" rx="52" ry="62"/><ellipse cx="560" cy="80" rx="52" ry="62"/>
<ellipse cx="90" cy="270" rx="52" ry="62"/><ellipse cx="250" cy="270" rx="52" ry="62"/>
<ellipse cx="400" cy="270" rx="52" ry="62"/><ellipse cx="560" cy="270" rx="52" ry="62"/>
</g>
<text x="170" y="18" text-anchor="middle" font-weight="700" fill="#2563eb">Injective, pas surjective</text>
<text x="480" y="18" text-anchor="middle" font-weight="700" fill="#16a34a">Bijective</text>
<text x="170" y="208" text-anchor="middle" font-weight="700" fill="#ea580c">Surjective, pas injective</text>
<text x="480" y="208" text-anchor="middle" font-weight="700" fill="#dc2626">Ni l''une ni l''autre</text>
<g fill="#0f172a">
<circle cx="90" cy="50" r="4"/><circle cx="90" cy="80" r="4"/><circle cx="90" cy="110" r="4"/>
<circle cx="250" cy="40" r="4"/><circle cx="250" cy="68" r="4"/><circle cx="250" cy="96" r="4"/><circle cx="250" cy="124" r="4"/>
<circle cx="400" cy="50" r="4"/><circle cx="400" cy="80" r="4"/><circle cx="400" cy="110" r="4"/>
<circle cx="560" cy="50" r="4"/><circle cx="560" cy="80" r="4"/><circle cx="560" cy="110" r="4"/>
<circle cx="90" cy="235" r="4"/><circle cx="90" cy="263" r="4"/><circle cx="90" cy="291" r="4"/><circle cx="90" cy="319" r="4"/>
<circle cx="250" cy="248" r="4"/><circle cx="250" cy="292" r="4"/>
<circle cx="400" cy="240" r="4"/><circle cx="400" cy="270" r="4"/><circle cx="400" cy="300" r="4"/>
<circle cx="560" cy="240" r="4"/><circle cx="560" cy="270" r="4"/><circle cx="560" cy="300" r="4"/>
</g>
<g stroke="#2563eb" stroke-width="1.8" marker-end="url(#fl)">
<line x1="95" y1="50" x2="243" y2="40"/><line x1="95" y1="80" x2="243" y2="68"/><line x1="95" y1="110" x2="243" y2="96"/>
</g>
<g stroke="#16a34a" stroke-width="1.8" marker-end="url(#fv)">
<line x1="405" y1="50" x2="553" y2="80"/><line x1="405" y1="80" x2="553" y2="110"/><line x1="405" y1="110" x2="553" y2="50"/>
</g>
<g stroke="#ea580c" stroke-width="1.8" marker-end="url(#fo)">
<line x1="95" y1="235" x2="243" y2="248"/><line x1="95" y1="263" x2="243" y2="248"/>
<line x1="95" y1="291" x2="243" y2="292"/><line x1="95" y1="319" x2="243" y2="292"/>
</g>
<g stroke="#dc2626" stroke-width="1.8" marker-end="url(#fr)">
<line x1="405" y1="240" x2="553" y2="270"/><line x1="405" y1="270" x2="553" y2="270"/><line x1="405" y1="300" x2="553" y2="300"/>
</g>
<defs>
<marker id="fl" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 z" fill="#2563eb"/></marker>
<marker id="fv" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 z" fill="#16a34a"/></marker>
<marker id="fo" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 z" fill="#ea580c"/></marker>
<marker id="fr" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 z" fill="#dc2626"/></marker>
</defs>
<text x="60" y="155" fill="#64748b" font-size="11">départ</text><text x="228" y="155" fill="#64748b" font-size="11">arrivée</text>
<text x="370" y="155" fill="#64748b" font-size="11">départ</text><text x="538" y="155" fill="#64748b" font-size="11">arrivée</text>
<text x="60" y="345" fill="#64748b" font-size="11">départ</text><text x="228" y="345" fill="#64748b" font-size="11">arrivée</text>
<text x="370" y="345" fill="#64748b" font-size="11">départ</text><text x="538" y="345" fill="#64748b" font-size="11">arrivée</text>
<text x="310" y="382" text-anchor="middle" fill="#334155" font-size="12">Injective : au plus une flèche arrive sur chaque point d''arrivée.</text>
<text x="310" y="399" text-anchor="middle" fill="#334155" font-size="12">Surjective : au moins une flèche arrive sur chaque point d''arrivée.</text>
<text x="310" y="416" text-anchor="middle" fill="#334155" font-size="12">Bijective : exactement une flèche arrive sur chaque point d''arrivée.</text>
</svg>', NULL, 5),
    (v_chapitre_id, 'Opérations sur les fonctions', 3, 'texte', 'Avec deux fonctions tu peux en fabriquer d''autres. Chaque opération a son propre ensemble de définition, et c''est là que se jouent la plupart des erreurs.

## Somme, produit, quotient

Pour la somme $f + g$ et le produit $f \times g$, il faut que les deux fonctions existent. Donc
$$D_{f+g} = D_{f} \cap D_{g}$$

Pour le quotient $\dfrac{f}{g}$, il faut en plus que $g$ ne s''annule pas :
$$D_{f/g} = \{x \in D_{f} \cap D_{g} \;\text{tels que}\; g(x) \neq 0\}$$

Prenons $f(x) = \sqrt{x - 1}$ et $g(x) = x - 4$.

Alors $D_{f} = [1\,;+\infty[$ et $D_{g} = \mathbb{R}$, donc $D_{f+g} = [1\,;+\infty[$.

Pour le quotient, il faut enlever 4. Donc $D_{f/g} = [1\,;4[ \;\cup\; ]4\,;+\infty[$.

## La composée

La composée $g \circ f$ se lit « $g$ rond $f$ ». Elle signifie : d''abord $f$, ensuite $g$.
$$(g \circ f)(x) = g\big(f(x)\big)$$

L''ordre compte énormément. En général $g \circ f \neq f \circ g$.

Avec $f(x) = x + 2$ et $g(x) = x^{2}$ :

$(g \circ f)(x) = (x + 2)^{2} = x^{2} + 4x + 4$

$(f \circ g)(x) = x^{2} + 2$

Ce ne sont pas les mêmes fonctions.

## L''ensemble de définition d''une composée

Pour que $g \circ f$ existe en $x$, il faut que $x$ soit dans $D_{f}$, et que $f(x)$ soit dans $D_{g}$.

Avec $f(x) = x - 3$ et $g(x) = \sqrt{x}$, il faut $x - 3 \geq 0$, donc $D_{g \circ f} = [3\,;+\infty[$.

## Composée et sens de variation

Si $f$ et $g$ varient dans le même sens, la composée est croissante. Si elles varient en sens contraire, la composée est décroissante. C''est la même règle de signes que pour la multiplication.

Par exemple $x \mapsto \sqrt{5 - x}$ est la composée de $x \mapsto 5 - x$, qui est décroissante, et de la racine, qui est croissante. La composée est donc décroissante sur $]-\infty\,;5]$.

## Exercice d''application

Soient $f(x) = 2x - 1$ et $g(x) = \dfrac{1}{x}$. Calcule $f \circ g$ et $g \circ f$, avec leurs ensembles de définition.

Correction. $(f \circ g)(x) = 2 \times \dfrac{1}{x} - 1 = \dfrac{2 - x}{x}$, défini pour $x \neq 0$.

$(g \circ f)(x) = \dfrac{1}{2x - 1}$, défini pour $x \neq \dfrac{1}{2}$.

Les deux fonctions sont différentes, et leurs ensembles de définition aussi.', NULL, 15),
    (v_chapitre_id, 'Quiz du chapitre 4', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "L''ensemble de définition de f(x) = √(x − 5) est :",
      "choix": [
        "[5 ; +∞[",
        "]5 ; +∞[",
        "ℝ",
        "]−∞ ; 5]"
      ],
      "bonne": 0,
      "explication": "Il faut que ce qui est sous la racine soit positif ou nul, donc x − 5 ≥ 0, c''est-à-dire x ≥ 5. Le 5 est inclus car √0 existe."
    },
    {
      "question": "Pour f(x) = x², les antécédents de 16 sont :",
      "choix": [
        "−4 et 4",
        "4 seulement",
        "16 et −16",
        "il n''y en a pas"
      ],
      "bonne": 0,
      "explication": "On résout x² = 16, ce qui donne x = −4 ou x = 4. Un nombre peut avoir plusieurs antécédents, mais une seule image."
    },
    {
      "question": "Une fonction est injective lorsque :",
      "choix": [
        "deux nombres différents ont toujours des images différentes",
        "tout élément d''arrivée a un antécédent",
        "elle est croissante",
        "son ensemble de définition est ℝ"
      ],
      "bonne": 0,
      "explication": "Injective veut dire que f(a) = f(b) entraîne a = b. Graphiquement, aucune droite horizontale ne coupe la courbe deux fois."
    },
    {
      "question": "Avec f(x) = x + 2 et g(x) = x², (g ∘ f)(3) vaut :",
      "choix": [
        "25",
        "11",
        "13",
        "9"
      ],
      "bonne": 0,
      "explication": "D''abord f(3) = 5, puis g(5) = 25. On applique f en premier, g ensuite."
    },
    {
      "question": "L''ensemble de définition du quotient f/g est :",
      "choix": [
        "l''intersection des deux domaines, privée des zéros de g",
        "l''intersection des deux domaines",
        "la réunion des deux domaines",
        "le domaine de f"
      ],
      "bonne": 0,
      "explication": "Les deux fonctions doivent exister, et en plus le dénominateur ne doit pas s''annuler."
    }
  ]
}', NULL, 5);

  RAISE NOTICE 'Chapitre 4, Généralités sur les fonctions numériques, 1ère partie : 4 lecons ajoutees.';
END $p1c$;
