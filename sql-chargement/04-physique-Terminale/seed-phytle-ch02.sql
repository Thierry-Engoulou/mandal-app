-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 2, Équations aux dimensions
-- Module 1 : Mesures et incertitudes
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
    WHERE programme_id = v_programme_id AND ordre = 2;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Équations aux dimensions', 2, 'Module 1 : Mesures et incertitudes')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 2 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 2 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les sept grandeurs de base', 1, 'texte', 'En physique, toutes les grandeurs se ramènent à sept grandeurs de base. C''est comme un alphabet : avec sept lettres, on écrit tout le reste.

## Le tableau à connaître par cœur

La longueur a pour symbole de dimension $\mathrm{L}$ et pour unité le mètre, noté m.

La masse a pour dimension $\mathrm{M}$ et pour unité le kilogramme, noté kg.

Le temps a pour dimension $\mathrm{T}$ et pour unité la seconde, notée s.

L''intensité du courant électrique a pour dimension $\mathrm{I}$ et pour unité l''ampère, noté A.

La température a pour dimension $\Theta$ et pour unité le kelvin, noté K.

La quantité de matière a pour dimension $\mathrm{N}$ et pour unité la mole, notée mol.

L''intensité lumineuse a pour dimension $\mathrm{J}$ et pour unité la candela, notée cd.

En Terminale C et D, tu utiliseras surtout les quatre premières.

## Grandeur, dimension, unité : ne confonds pas

Ces trois mots ne désignent pas la même chose.

La **grandeur** est ce qu''on mesure, par exemple la vitesse d''une moto.

La **dimension** dit de quelle nature est cette grandeur, indépendamment de la façon de la mesurer. La vitesse est une longueur divisée par un temps, et cela reste vrai partout.

L''**unité** est l''étalon choisi pour exprimer le résultat. La même vitesse peut s''écrire $90$ km/h ou $25$ m/s. L''unité change, la dimension ne change pas.

## La notation

On écrit la dimension d''une grandeur $X$ entre crochets : $[X]$.

Ainsi $[v] = \mathrm{L}\,\mathrm{T}^{-1}$ se lit « la dimension d''une vitesse est une longueur divisée par un temps ».

## Les grandeurs sans dimension

Certaines grandeurs n''ont pas de dimension. On note alors $[X] = 1$.

C''est le cas d''un rapport de deux grandeurs de même nature, comme un rendement, un indice de réfraction, ou un angle en radians puisque c''est un rapport de deux longueurs.

Attention, sans dimension ne veut pas dire sans intérêt. Un rendement de $0{,}85$ est une information précieuse.

## Exercice d''application

Donne la dimension des grandeurs suivantes : une surface, un volume, une accélération, une masse volumique.

Correction. Une surface est le produit de deux longueurs, donc $[S] = \mathrm{L}^{2}$.

Un volume est le produit de trois longueurs, donc $[V] = \mathrm{L}^{3}$.

Une accélération est une vitesse divisée par un temps, donc $[a] = \dfrac{\mathrm{L}\,\mathrm{T}^{-1}}{\mathrm{T}} = \mathrm{L}\,\mathrm{T}^{-2}$.

Une masse volumique est une masse divisée par un volume, donc $[\rho] = \dfrac{\mathrm{M}}{\mathrm{L}^{3}} = \mathrm{M}\,\mathrm{L}^{-3}$.', NULL, 15),
      (v_chapitre_id, 'Trouver la dimension d''une grandeur', 2, 'texte', 'Pour trouver la dimension d''une grandeur que tu ne connais pas, tu pars d''une formule où elle apparaît, et tu remplaces chaque terme par sa dimension.

## Les trois règles de calcul

Première règle, la dimension d''un produit est le produit des dimensions.
$$[xy] = [x] \times [y]$$

Deuxième règle, la dimension d''un quotient est le quotient des dimensions.
$$\left[\dfrac{x}{y}\right] = \dfrac{[x]}{[y]}$$

Troisième règle, l''exposant passe tel quel.
$$[x^{n}] = [x]^{n}$$

En revanche, on n''additionne jamais des dimensions. On ne peut additionner que des grandeurs de même dimension, et le résultat garde cette dimension.

## Les fonctions mathématiques exigent du sans-dimension

Tu ne peux écrire $\sin(x)$, $\cos(x)$, $\ln(x)$ ou $e^{x}$ que si $x$ est sans dimension. Écrire $\ln(5\ \text{mètres})$ n''a aucun sens.

C''est pour cela que dans $u(t) = U_{0}\,e^{-t/\tau}$, le rapport $\dfrac{t}{\tau}$ doit être sans dimension, ce qui impose à $\tau$ d''être un temps. Cette remarque te donne gratuitement la dimension d''une constante de temps.

## Un exemple détaillé : la force

Tu connais la deuxième loi de Newton, $F = ma$.

Donc $[F] = [m] \times [a] = \mathrm{M} \times \mathrm{L}\,\mathrm{T}^{-2} = \mathrm{M}\,\mathrm{L}\,\mathrm{T}^{-2}$.

L''unité correspondante est le newton, et tu vois tout de suite que $1\ \text{N} = 1\ \text{kg}\cdot\text{m}\cdot\text{s}^{-2}$.

## Un deuxième exemple : l''énergie

Le travail d''une force vaut $W = F \times d$.

Donc $[W] = \mathrm{M}\,\mathrm{L}\,\mathrm{T}^{-2} \times \mathrm{L} = \mathrm{M}\,\mathrm{L}^{2}\,\mathrm{T}^{-2}$.

Vérifie avec l''énergie cinétique, $E_{c} = \dfrac{1}{2}mv^{2}$. Tu obtiens $\mathrm{M} \times (\mathrm{L}\,\mathrm{T}^{-1})^{2} = \mathrm{M}\,\mathrm{L}^{2}\,\mathrm{T}^{-2}$. C''est la même chose, et c''est rassurant : un travail et une énergie cinétique s''additionnent, donc ils doivent avoir la même dimension. Le facteur $\dfrac{1}{2}$ ne compte pas, les nombres purs sont sans dimension.

## Quelques dimensions utiles

Une puissance est une énergie par unité de temps, donc $[P] = \mathrm{M}\,\mathrm{L}^{2}\,\mathrm{T}^{-3}$.

Une pression est une force par unité de surface, donc $[p] = \mathrm{M}\,\mathrm{L}^{-1}\,\mathrm{T}^{-2}$.

Une charge électrique est un courant multiplié par un temps, donc $[q] = \mathrm{I}\,\mathrm{T}$.

Une tension est une énergie par unité de charge, donc $[U] = \dfrac{\mathrm{M}\,\mathrm{L}^{2}\,\mathrm{T}^{-2}}{\mathrm{I}\,\mathrm{T}} = \mathrm{M}\,\mathrm{L}^{2}\,\mathrm{T}^{-3}\,\mathrm{I}^{-1}$.

## Exercice d''application

Trouve la dimension d''une résistance électrique, puis celle d''une capacité.

Correction. La loi d''Ohm donne $U = RI$, donc $R = \dfrac{U}{I}$.

Alors $[R] = \dfrac{\mathrm{M}\,\mathrm{L}^{2}\,\mathrm{T}^{-3}\,\mathrm{I}^{-1}}{\mathrm{I}} = \mathrm{M}\,\mathrm{L}^{2}\,\mathrm{T}^{-3}\,\mathrm{I}^{-2}$. L''unité est l''ohm.

Pour la capacité, on part de $Q = CU$, donc $C = \dfrac{Q}{U}$.

Alors $[C] = \dfrac{\mathrm{I}\,\mathrm{T}}{\mathrm{M}\,\mathrm{L}^{2}\,\mathrm{T}^{-3}\,\mathrm{I}^{-1}} = \mathrm{M}^{-1}\,\mathrm{L}^{-2}\,\mathrm{T}^{4}\,\mathrm{I}^{2}$. L''unité est le farad.

Vérifions au passage que $RC$ est bien un temps, comme la constante de temps d''un circuit RC l''exige. Le produit donne $\mathrm{M}\,\mathrm{L}^{2}\,\mathrm{T}^{-3}\,\mathrm{I}^{-2} \times \mathrm{M}^{-1}\,\mathrm{L}^{-2}\,\mathrm{T}^{4}\,\mathrm{I}^{2} = \mathrm{T}$. C''est bien un temps.', NULL, 15),
      (v_chapitre_id, 'Vérifier qu''une formule est homogène', 3, 'texte', 'L''analyse dimensionnelle sert surtout à une chose : repérer une formule fausse sans rien calculer. C''est un réflexe qui sauve beaucoup de points à l''examen.

## Le principe d''homogénéité

Une relation physique est **homogène** quand les deux membres ont la même dimension, et quand tous les termes qu''on additionne ont la même dimension.

Si une relation n''est pas homogène, elle est forcément fausse. Tu peux la rejeter tout de suite.

Attention au sens de l''implication. Une relation homogène n''est pas forcément juste. Si tu écris $E_{c} = 5mv^{2}$ au lieu de $\dfrac{1}{2}mv^{2}$, la formule reste homogène, et pourtant elle est fausse. L''analyse dimensionnelle ne contrôle pas les nombres.

## La méthode, en trois gestes

Tu écris la dimension du membre de gauche. Tu écris la dimension du membre de droite. Tu compares.

S''il y a une somme quelque part, tu vérifies chaque terme de la somme séparément.

## Un exemple : la période du pendule simple

On propose trois formules pour la période d''un pendule de longueur $\ell$ dans un champ de pesanteur $g$ :
$$T = 2\pi\sqrt{\dfrac{\ell}{g}} \qquad T = 2\pi\sqrt{\dfrac{g}{\ell}} \qquad T = 2\pi\dfrac{\ell}{g}$$

La dimension de $g$ est celle d''une accélération, donc $\mathrm{L}\,\mathrm{T}^{-2}$.

Pour la première, $\dfrac{\ell}{g}$ a pour dimension $\dfrac{\mathrm{L}}{\mathrm{L}\,\mathrm{T}^{-2}} = \mathrm{T}^{2}$. La racine donne $\mathrm{T}$. C''est bien un temps, cette formule peut convenir.

Pour la deuxième, $\dfrac{g}{\ell}$ a pour dimension $\mathrm{T}^{-2}$, et la racine donne $\mathrm{T}^{-1}$. C''est l''inverse d''un temps, donc une fréquence. Cette formule est fausse.

Pour la troisième, $\dfrac{\ell}{g}$ a pour dimension $\mathrm{T}^{2}$. Ce n''est pas un temps. Cette formule est fausse aussi.

En trois lignes et sans aucune expérience, tu as éliminé deux formules sur trois.

## Retrouver une formule oubliée

Tu peux même reconstruire une formule à un facteur numérique près.

Supposons que tu aies oublié l''expression de la période du pendule, mais que tu saches qu''elle dépend de $\ell$, de $g$ et de la masse $m$. Tu poses
$$T = k\,m^{\alpha}\,\ell^{\beta}\,g^{\gamma}$$
où $k$ est un nombre sans dimension.

En dimensions, cela donne $\mathrm{T} = \mathrm{M}^{\alpha}\,\mathrm{L}^{\beta}\,(\mathrm{L}\,\mathrm{T}^{-2})^{\gamma} = \mathrm{M}^{\alpha}\,\mathrm{L}^{\beta+\gamma}\,\mathrm{T}^{-2\gamma}$.

Tu identifies les exposants de chaque côté. Pour $\mathrm{M}$, il vient $\alpha = 0$. Pour $\mathrm{T}$, il vient $-2\gamma = 1$, donc $\gamma = -\dfrac{1}{2}$. Pour $\mathrm{L}$, il vient $\beta + \gamma = 0$, donc $\beta = \dfrac{1}{2}$.

Tu retrouves $T = k\sqrt{\dfrac{\ell}{g}}$, et au passage tu découvres que la période ne dépend pas de la masse, ce qui est un résultat physique important. Seul le nombre $k$, qui vaut $2\pi$, t''échappe.

## Exercice d''application

Un élève propose, pour la vitesse du son dans un gaz de masse volumique $\rho$ sous la pression $p$, la relation $v = \sqrt{\dfrac{p}{\rho}}$. Cette relation est-elle homogène ?

Correction. La pression a pour dimension $[p] = \mathrm{M}\,\mathrm{L}^{-1}\,\mathrm{T}^{-2}$ et la masse volumique $[\rho] = \mathrm{M}\,\mathrm{L}^{-3}$.

Le rapport donne $\dfrac{\mathrm{M}\,\mathrm{L}^{-1}\,\mathrm{T}^{-2}}{\mathrm{M}\,\mathrm{L}^{-3}} = \mathrm{L}^{2}\,\mathrm{T}^{-2}$.

La racine carrée donne $\mathrm{L}\,\mathrm{T}^{-1}$, qui est bien la dimension d''une vitesse.

La relation est donc homogène. Elle est effectivement utilisée en physique, à un facteur numérique près qui dépend du gaz.', NULL, 15),
      (v_chapitre_id, 'Teste l''homogénéité d''une formule', 4, 'interactif', '{
  "widget": "equation-dimensions",
  "consigne": "Compose une formule en choisissant les grandeurs, et regarde la machine calculer sa dimension. Essaie d''écrire une énergie de trois façons différentes, puis trouve une formule qui n''est pas homogène."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 2', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la dimension d''une force ?",
      "choix": [
        "$\\mathrm{M}\\,\\mathrm{L}\\,\\mathrm{T}^{-1}$",
        "$\\mathrm{M}\\,\\mathrm{L}\\,\\mathrm{T}^{-2}$",
        "$\\mathrm{M}\\,\\mathrm{L}^{2}\\,\\mathrm{T}^{-2}$",
        "$\\mathrm{M}\\,\\mathrm{L}^{-1}\\,\\mathrm{T}^{-2}$"
      ],
      "bonne": 1,
      "explication": "On part de $F = ma$. La masse donne $\\mathrm{M}$, l''accélération donne $\\mathrm{L}\\,\\mathrm{T}^{-2}$. Le produit vaut donc $\\mathrm{M}\\,\\mathrm{L}\\,\\mathrm{T}^{-2}$, ce qui correspond au newton."
    },
    {
      "question": "Une relation est homogène. Que peut-on en conclure ?",
      "choix": [
        "Elle est forcément juste",
        "Elle peut être fausse malgré tout",
        "Elle est juste à condition que les unités soient du système international",
        "Elle ne contient aucun nombre"
      ],
      "bonne": 1,
      "explication": "L''homogénéité est nécessaire mais pas suffisante. $E_c = 5mv^2$ est homogène et pourtant fausse, car le coefficient correct est $1/2$. L''analyse dimensionnelle ne contrôle jamais les facteurs numériques."
    },
    {
      "question": "Dans l''expression $u(t) = U_0\\,e^{-t/\\tau}$, que peut-on dire de $\\tau$ ?",
      "choix": [
        "C''est une tension",
        "C''est une durée",
        "C''est sans dimension",
        "C''est l''inverse d''une durée"
      ],
      "bonne": 1,
      "explication": "L''argument d''une exponentielle doit être sans dimension. Comme $t$ est un temps, il faut que $\\tau$ soit un temps lui aussi pour que le rapport $t/\\tau$ n''ait pas de dimension."
    },
    {
      "question": "Quelle est la dimension du produit $RC$, où $R$ est une résistance et $C$ une capacité ?",
      "choix": [
        "$\\mathrm{T}$",
        "$\\mathrm{T}^{-1}$",
        "$\\mathrm{M}\\,\\mathrm{L}^{2}$",
        "Sans dimension"
      ],
      "bonne": 0,
      "explication": "Le produit $RC$ est la constante de temps du circuit RC, c''est donc une durée. Le calcul complet donne bien $\\mathrm{M}\\,\\mathrm{L}^{2}\\,\\mathrm{T}^{-3}\\,\\mathrm{I}^{-2} \\times \\mathrm{M}^{-1}\\,\\mathrm{L}^{-2}\\,\\mathrm{T}^{4}\\,\\mathrm{I}^{2} = \\mathrm{T}$."
    },
    {
      "question": "Parmi ces grandeurs, laquelle est sans dimension ?",
      "choix": [
        "La pression",
        "L''indice de réfraction",
        "La masse volumique",
        "La puissance"
      ],
      "bonne": 1,
      "explication": "L''indice de réfraction est le rapport de deux vitesses, donc les dimensions se simplifient et il ne reste rien. Les trois autres ont toutes une dimension."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 2, Équations aux dimensions — 5 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
