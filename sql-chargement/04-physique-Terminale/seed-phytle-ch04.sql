-- ============================================================================
-- MANDAL — Physique Terminale : chapitre 4, Forces et champs électrostatiques
-- Module 2 : Mouvements et interactions, évolutions temporelles des systèmes mécaniques
-- 4 leçons.
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
    WHERE programme_id = v_programme_id AND ordre = 4;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Forces et champs électrostatiques', 4, 'Module 2 : Mouvements et interactions, évolutions temporelles des systèmes mécaniques')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 4 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 4 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'La loi de Coulomb', 1, 'texte', 'Frotte une règle en plastique sur tes cheveux, puis approche-la de petits morceaux de papier. Ils sautent vers la règle. Tu viens de mettre en évidence la force électrostatique.

## Les charges électriques

Il existe deux sortes de charges, qu''on appelle positive et négative. La charge se note $q$ et s''exprime en coulombs, symbole C.

La règle est simple. Deux charges de même signe se repoussent, deux charges de signes contraires s''attirent.

La plus petite charge qu''on puisse isoler est la charge élémentaire
$$e = 1{,}6 \times 10^{-19}\ \text{C}$$
Le proton porte $+e$ et l''électron porte $-e$. Toute charge est un multiple entier de $e$.

## L''énoncé de la loi de Coulomb

Deux charges ponctuelles $q_{A}$ et $q_{B}$, séparées d''une distance $r$ dans le vide, exercent l''une sur l''autre une force de valeur
$$F = k\,\dfrac{|q_{A}|\,|q_{B}|}{r^{2}}$$

La constante $k$ vaut
$$k = 9 \times 10^{9}\ \text{N}\cdot\text{m}^{2}\cdot\text{C}^{-2}$$

On l''écrit aussi $k = \dfrac{1}{4\pi\varepsilon_{0}}$, où $\varepsilon_{0}$ est la permittivité du vide.

## La ressemblance avec la gravitation, et la différence

Compare les deux lois. La forme est identique : un produit de deux grandeurs divisé par le carré de la distance.

Mais il y a deux différences de taille.

D''abord, la gravitation est toujours attractive, alors que la force électrique peut attirer ou repousser selon les signes.

Ensuite, regarde les constantes. On a $k = 9 \times 10^{9}$ contre $\mathcal{G}_{0} = 6{,}67 \times 10^{-11}$. L''écart est de vingt ordres de grandeur. Entre un proton et un électron dans un atome, la force électrique est environ $10^{39}$ fois plus intense que la force gravitationnelle. À l''échelle de l''atome, la gravitation ne compte tout simplement pas.

## L''écriture vectorielle

Avec $\vec{u}_{AB}$ le vecteur unitaire dirigé de $A$ vers $B$, la force exercée par $A$ sur $B$ s''écrit
$$\vec{F}_{A/B} = k\,\dfrac{q_{A}\,q_{B}}{r^{2}}\,\vec{u}_{AB}$$

Ici on garde les signes des charges. Si le produit $q_{A}q_{B}$ est positif, c''est-à-dire si les charges sont de même signe, la force est dans le sens de $\vec{u}_{AB}$, donc répulsive. S''il est négatif, la force est attractive. La formule gère les deux cas toute seule.

## Exercice d''application

Dans l''atome d''hydrogène, l''électron tourne à environ $r = 5{,}3 \times 10^{-11}$ m du proton. Calcule la force électrique entre eux, puis la force gravitationnelle, et fais le rapport. On donne $m_{e} = 9{,}1 \times 10^{-31}$ kg et $m_{p} = 1{,}67 \times 10^{-27}$ kg.

Correction. Pour la force électrique,
$$F_{e} = 9 \times 10^{9} \times \dfrac{(1{,}6 \times 10^{-19})^{2}}{(5{,}3 \times 10^{-11})^{2}}$$

Le numérateur vaut $9 \times 10^{9} \times 2{,}56 \times 10^{-38} = 2{,}304 \times 10^{-28}$.

Le dénominateur vaut $2{,}809 \times 10^{-21}$.

Donc $F_{e} = \dfrac{2{,}304 \times 10^{-28}}{2{,}809 \times 10^{-21}} \approx 8{,}2 \times 10^{-8}$ N.

Pour la force gravitationnelle,
$$F_{g} = 6{,}67 \times 10^{-11} \times \dfrac{9{,}1 \times 10^{-31} \times 1{,}67 \times 10^{-27}}{2{,}809 \times 10^{-21}}$$

Le numérateur vaut $6{,}67 \times 10^{-11} \times 1{,}52 \times 10^{-57} = 1{,}014 \times 10^{-67}$.

Donc $F_{g} = \dfrac{1{,}014 \times 10^{-67}}{2{,}809 \times 10^{-21}} \approx 3{,}6 \times 10^{-47}$ N.

Le rapport vaut $\dfrac{8{,}2 \times 10^{-8}}{3{,}6 \times 10^{-47}} \approx 2{,}3 \times 10^{39}$.

La force électrique est donc plus de $10^{39}$ fois plus forte. On néglige toujours la gravitation dans l''atome.', NULL, 15),
      (v_chapitre_id, 'Le champ électrique', 2, 'texte', 'Comme pour la gravitation, on préfère dire qu''une charge modifie l''espace autour d''elle plutôt qu''elle agit à distance. Cette modification, c''est le champ électrique.

## La définition

En un point $M$, le champ électrique $\vec{E}$ est défini par la force que subirait une charge $q$ placée en ce point :
$$\vec{F} = q\,\vec{E} \qquad \text{donc} \qquad \vec{E} = \dfrac{\vec{F}}{q}$$

L''unité du champ électrique est le volt par mètre, noté V/m. On peut aussi l''écrire N/C, c''est la même chose.

## Attention au signe de la charge

Voilà une différence importante avec la gravitation, où la masse est toujours positive.

Si $q > 0$, la force $\vec{F}$ est dans le **même sens** que $\vec{E}$.

Si $q < 0$, la force $\vec{F}$ est dans le **sens opposé** à $\vec{E}$.

Un électron, qui est négatif, part donc toujours à contresens du champ. C''est une source d''erreurs permanente aux examens, fais-y attention.

## Le champ créé par une charge ponctuelle

Une charge ponctuelle $q_{0}$ placée en $O$ crée, en un point $M$ situé à la distance $r$, un champ de valeur
$$E = k\,\dfrac{|q_{0}|}{r^{2}}$$

Sa direction est celle de la droite $OM$.

Son sens dépend du signe de $q_{0}$. Si la charge est positive, le champ s''éloigne d''elle, il est centrifuge. Si elle est négative, le champ pointe vers elle, il est centripète.

Un moyen mnémotechnique : le champ part du plus et va vers le moins.

## Le champ créé par plusieurs charges

Quand plusieurs charges sont présentes, les champs s''additionnent vectoriellement. C''est le **principe de superposition**.
$$\vec{E} = \vec{E}_{1} + \vec{E}_{2} + \cdots + \vec{E}_{n}$$

En pratique, tu dessines chaque vecteur champ au point considéré, puis tu fais la somme géométrique. Si les champs ne sont pas alignés, tu projettes sur deux axes.

## Les lignes de champ

Une ligne de champ est tangente en chaque point au vecteur $\vec{E}$, et orientée dans son sens.

Les lignes partent des charges positives et arrivent sur les charges négatives. Elles ne se croisent jamais, car en un point donné le champ a une seule direction.

Là où les lignes sont serrées, le champ est fort.

## Le champ uniforme

Un champ est **uniforme** dans une région quand il a la même valeur, la même direction et le même sens en tout point de cette région. Ses lignes de champ sont alors des droites parallèles et régulièrement espacées.

On réalise un champ uniforme entre deux plaques planes parallèles portant des charges opposées. C''est le condensateur plan. Si les plaques sont séparées de $d$ et soumises à une tension $U$, le champ entre elles vaut
$$E = \dfrac{U}{d}$$
et il est dirigé de la plaque positive vers la plaque négative.

## Exercice d''application

Deux plaques parallèles distantes de $d = 4{,}0$ cm sont reliées à un générateur de $U = 600$ V. Calcule le champ électrique entre elles. Quelle force subit un électron placé dans ce champ ? Dans quel sens part-il ?

Correction. Le champ vaut
$$E = \dfrac{U}{d} = \dfrac{600}{0{,}040} = 1{,}5 \times 10^{4}\ \text{V/m}$$

La force sur l''électron a pour valeur
$$F = |q|E = 1{,}6 \times 10^{-19} \times 1{,}5 \times 10^{4} = 2{,}4 \times 10^{-15}\ \text{N}$$

L''électron porte une charge négative, donc la force est de sens opposé au champ. Comme le champ va de la plaque positive vers la plaque négative, l''électron part vers la plaque positive. C''est logique, il est attiré par le plus.', NULL, 15),
      (v_chapitre_id, 'Construis un champ électrique', 3, 'interactif', '{
  "widget": "champ-electrique",
  "consigne": "Pose des charges positives et négatives sur le plan et regarde les lignes de champ se dessiner. Déplace la sonde pour lire le vecteur champ en un point. Place deux charges opposées et trouve un point où le champ est nul : y arrives-tu ? Essaie ensuite avec deux charges de même signe."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 4', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Deux charges identiques $+q$ sont placées à une distance $r$. Que fait la force entre elles ?",
      "choix": [
        "Elle les attire",
        "Elle les repousse",
        "Elle est nulle",
        "Cela dépend de la valeur de $q$"
      ],
      "bonne": 1,
      "explication": "Deux charges de même signe se repoussent toujours, quelle que soit leur valeur. Seules des charges de signes contraires s''attirent."
    },
    {
      "question": "Un électron est placé dans un champ électrique $\\vec{E}$. Dans quel sens part-il ?",
      "choix": [
        "Dans le sens de $\\vec{E}$",
        "Dans le sens opposé à $\\vec{E}$",
        "Perpendiculairement à $\\vec{E}$",
        "Il ne bouge pas"
      ],
      "bonne": 1,
      "explication": "La force vaut $\\vec{F} = q\\vec{E}$. L''électron a une charge négative, donc la force est de sens contraire au champ. C''est l''erreur la plus fréquente aux examens."
    },
    {
      "question": "Entre deux plaques parallèles distantes de 2 cm, on applique 400 V. Que vaut le champ ?",
      "choix": [
        "200 V/m",
        "800 V/m",
        "$2{,}0 \\times 10^{4}$ V/m",
        "$8{,}0 \\times 10^{3}$ V/m"
      ],
      "bonne": 2,
      "explication": "On applique $E = U/d$ avec $d$ en mètres : $E = 400 / 0{,}02 = 2{,}0 \\times 10^{4}$ V/m. L''oubli de la conversion des centimètres en mètres est le piège classique."
    },
    {
      "question": "Comment sont les lignes d''un champ électrique uniforme ?",
      "choix": [
        "Des droites parallèles également espacées",
        "Des droites qui convergent vers un point",
        "Des cercles concentriques",
        "Des courbes qui se croisent"
      ],
      "bonne": 0,
      "explication": "Uniforme signifie même valeur, même direction et même sens partout. Les lignes sont donc parallèles, et leur espacement constant traduit la valeur constante du champ. Deux lignes de champ ne se croisent jamais."
    },
    {
      "question": "Pourquoi néglige-t-on la gravitation entre le proton et l''électron d''un atome ?",
      "choix": [
        "Parce que ces particules n''ont pas de masse",
        "Parce que la force électrique y est environ $10^{39}$ fois plus intense",
        "Parce que la distance est trop grande",
        "Parce que les charges sont opposées"
      ],
      "bonne": 1,
      "explication": "Les deux lois ont la même forme en $1/r^2$, mais $k = 9 \\times 10^9$ alors que $\\mathcal{G}_0 = 6{,}67 \\times 10^{-11}$. Le rapport des forces dépasse $10^{39}$, donc la gravitation est totalement négligeable à l''échelle atomique."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 4, Forces et champs électrostatiques — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $ptc$;
