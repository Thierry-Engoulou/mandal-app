-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 13, Estérification et hydrolyse : étude cinétique
-- Module 3 : Cinétique chimique
-- 4 leçons.
--
-- Ce fichier remplit LES TROIS CLASSES a la fois : Terminale C, D et E.
-- Autonome : il cree lui-meme la matiere, les classes, les programmes et le
-- chapitre s'ils n'existent pas encore. Lancez-le seul, dans n'importe quel
-- ordre.
-- Idempotent : si le chapitre contient deja des lecons, rien n'est ajoute.
-- ============================================================================
DO $chi$
DECLARE
  v_lettres text[] := ARRAY['C', 'D', 'E'];
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
  INSERT INTO public.matieres (nom) VALUES ('Chimie') ON CONFLICT (nom) DO NOTHING;
  SELECT id INTO v_matiere_id FROM public.matieres WHERE nom = 'Chimie';

  -- l'etablissement, deduit de la table des classes
  SELECT count(DISTINCT etablissement_id) INTO v_nb_etabs FROM public.classes;
  IF v_nb_etabs <> 1 THEN
    RAISE EXCEPTION 'Impossible de deduire l''etablissement : % etablissement(s) distinct(s) dans public.classes.', v_nb_etabs;
  END IF;
  SELECT etablissement_id INTO v_etab_id FROM public.classes LIMIT 1;

  -- on refait le meme travail pour la Terminale C, puis la D, puis la E
  FOR v_i IN 1..3 LOOP
    v_lettre := v_lettres[v_i];
    v_nom := 'Terminale ' || v_lettre;

    -- 1. le programme existe-t-il deja ?
    SELECT p.id INTO v_programme_id FROM public.programmes p
    WHERE p.titre = 'Chimie — ' || v_nom;

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
      VALUES (v_matiere_id, v_classe_id, v_etab_id, 'Chimie — ' || v_nom,
              'Programme officiel de Chimie, classe de Terminale ' || v_lettre ||
              ' (Cameroun) — 4 modules, 17 chapitres.')
      RETURNING id INTO v_programme_id;
      RAISE NOTICE 'Programme "Chimie — %" cree.', v_nom;
    END IF;

    -- 3. le chapitre existe-t-il deja ?
    SELECT id INTO v_chapitre_id FROM public.chapitres
    WHERE programme_id = v_programme_id AND ordre = 13;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Estérification et hydrolyse : étude cinétique', 13, 'Module 3 : Cinétique chimique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 13 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 13 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Suivre une estérification au laboratoire', 1, 'texte', 'Tu connais déjà l''estérification du point de vue de l''équilibre. Voyons-la maintenant du point de vue du temps, car c''est l''exemple de cinétique le plus demandé à l''examen.

## Le mélange de départ

On prépare des tubes scellés contenant tous le **même mélange initial**, typiquement une mole d''acide et une mole d''alcool, avec quelques gouttes d''acide sulfurique comme catalyseur.

On les place tous dans un bain thermostaté à la même température, et on en retire un à chaque instant de mesure.

Pourquoi des tubes séparés plutôt qu''un seul ballon ? Parce qu''il faut pouvoir arrêter la réaction net dans l''échantillon prélevé, sans perturber les autres.

## Le dosage de l''acide restant

À l''instant $t$, on sort un tube, on le trempe dans l''eau glacée, puis on dose l''acide restant par une solution de soude en présence de phénolphtaléine.

Soit $n_{a}(t)$ la quantité d''acide restante. Comme chaque mole d''acide disparue a donné une mole d''ester :
$$n_{\text{ester}}(t) = n_{a}(0) - n_{a}(t)$$

Attention à un piège de la manipulation : la soude dose à la fois l''acide carboxylique restant **et** le catalyseur sulfurique. Il faut donc soustraire la quantité de catalyseur, qu''on détermine par un dosage à blanc au temps zéro.

## L''allure de la courbe

En traçant $n_{\text{ester}}$ en fonction du temps, on obtient toujours la même forme.

La courbe part de zéro, monte d''abord rapidement, puis s''infléchit, et finit par atteindre un **palier horizontal**.

Le palier est la signature de l''**équilibre**. À partir de là, la vitesse de l''estérification est exactement égale à celle de l''hydrolyse, et les quantités ne bougent plus.

Ce palier se situe à $0{,}67$ mol pour un alcool primaire, $0{,}60$ pour un secondaire et $0{,}05$ pour un tertiaire, comme tu l''as vu au chapitre 3.

## L''hydrolyse, vue à l''envers

Pars cette fois d''une mole d''ester et une mole d''eau. L''ester s''hydrolyse, et la quantité d''ester **diminue**.

La courbe part de 1 mol et descend, jusqu''à un palier.

Fait remarquable : ce palier se trouve **au même endroit** que celui de l''estérification, soit $0{,}33$ mol d''ester restant pour un alcool primaire. Les deux expériences conduisent au même état d''équilibre, qu''on l''aborde par un bout ou par l''autre.

C''est la meilleure preuve qu''il s''agit bien d''un équilibre, et non d''une réaction qui s''arrêterait faute de réactifs.

## Ce que change chaque facteur

En **augmentant la température**, la courbe monte plus vite mais atteint **le même palier**. La température est ici un pur facteur cinétique, parce que la réaction est athermique.

En **ajoutant du catalyseur**, même chose : on gagne du temps, pas du rendement.

En **mettant un réactif en excès**, la courbe atteint un palier **plus haut**. Là, on a vraiment déplacé l''équilibre.

En **éliminant l''eau** au fur et à mesure, le palier monte aussi, et peut approcher $100\%$.

Retiens le tableau : température et catalyseur agissent sur le temps, excès et élimination agissent sur le rendement.

## La constante d''équilibre

À l''équilibre, le rapport
$$K = \dfrac{[\text{ester}]\,[\text{eau}]}{[\text{acide}]\,[\text{alcool}]}$$
est constant à une température donnée.

Pour un alcool primaire en quantités initiales égales, on trouve
$$K = \dfrac{0{,}67 \times 0{,}67}{0{,}33 \times 0{,}33} \approx 4$$

Cette valeur ne dépend ni du catalyseur, ni des quantités de départ. C''est elle qui fixe le palier.

## Exercice d''application

On part d''un mélange de $1{,}0$ mol d''acide éthanoïque et $1{,}0$ mol d''éthanol, à $60\ °\text{C}$, avec quelques gouttes d''acide sulfurique. On relève la quantité d''ester formé.

À $t = 0$ : 0 mol. À $t = 1$ h : $0{,}40$ mol. À $t = 2$ h : $0{,}55$ mol. À $t = 4$ h : $0{,}64$ mol. À $t = 8$ h : $0{,}67$ mol. À $t = 16$ h : $0{,}67$ mol.

Détermine le rendement à l''équilibre, le temps de demi-réaction et la constante d''équilibre. Que donnerait la même expérience sans catalyseur ?

Correction. Le palier est atteint à $0{,}67$ mol d''ester. Comme le maximum théorique est $1{,}0$ mol, le rendement vaut
$$r = \dfrac{0{,}67}{1{,}0} = 67\%$$

C''est bien la valeur attendue pour un alcool primaire, l''éthanol.

Le temps de demi-réaction correspond à la moitié de $0{,}67$, soit $0{,}335$ mol. D''après le tableau, cette valeur est atteinte un peu avant $t = 1$ h. Par interpolation depuis zéro :
$$t_{1/2} \approx \dfrac{0{,}335}{0{,}40} \approx 0{,}84\ \text{h}$$

soit environ **50 minutes**.

Pour la constante, à l''équilibre il reste $1{,}0 - 0{,}67 = 0{,}33$ mol d''acide et autant d''alcool, et il s''est formé $0{,}67$ mol d''ester et autant d''eau. Les volumes étant les mêmes pour toutes les espèces, ils se simplifient :
$$K = \dfrac{0{,}67 \times 0{,}67}{0{,}33 \times 0{,}33} = \dfrac{0{,}449}{0{,}109} \approx 4{,}1$$

Sans catalyseur, la courbe monterait beaucoup plus lentement, et le temps de demi-réaction se compterait en jours plutôt qu''en minutes. Mais le palier resterait **exactement à $0{,}67$ mol**, et la constante garderait la même valeur.', NULL, 15),
      (v_chapitre_id, 'Suis une estérification heure par heure', 2, 'interactif', '{
  "widget": "cinetique-esterification",
  "consigne": "Lance l''expérience et regarde la courbe se construire jusqu''au palier. Change la température : la courbe monte plus vite, mais le palier bouge-t-il ? Mets ensuite l''alcool en excès : là, le palier se déplace. Explique la différence."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Bac : cinétique chimique', 3, 'texte', 'Voici un sujet de cinétique, dans l''esprit du Baccalauréat. Le tableau de valeurs est le cœur du problème : apprends à le lire.

## Énoncé

On étudie la réaction entre une solution de thiosulfate de sodium et une solution d''acide chlorhydrique. Il se dégage du dioxyde de soufre, et il se forme du soufre solide qui trouble progressivement le mélange :
$$\text{S}_{2}\text{O}_{3}^{2-} + 2\,\text{H}_{3}\text{O}^{+} \longrightarrow \text{S} + \text{SO}_{2} + 3\,\text{H}_{2}\text{O}$$

On mélange $40$ mL de thiosulfate à $0{,}50\ \text{mol}\cdot\text{L}^{-1}$ et $10$ mL d''acide chlorhydrique à $5{,}0\ \text{mol}\cdot\text{L}^{-1}$. On suit la quantité de soufre formé.

À $t = 0$ : $0$ mmol. À $0{,}5$ min : $7{,}5$. À $1{,}0$ min : $12{,}0$. À $1{,}5$ min : $15{,}0$. À $2{,}0$ min : $17{,}0$. À $3{,}0$ min : $19{,}0$. À $5{,}0$ min : $20{,}0$. À $8{,}0$ min : $20{,}0$.

**1.** Détermine les quantités initiales des deux réactifs et identifie le réactif limitant.

**2.** Calcule la quantité maximale de soufre que l''on peut obtenir. La réaction est-elle totale ?

**3.** Définis la vitesse de formation du soufre et calcule sa valeur moyenne sur la première demi-minute.

**4.** Détermine le temps de demi-réaction.

**5.** Comment la courbe serait-elle modifiée si l''on chauffait le mélange à $50\ °\text{C}$ ? Et si l''on doublait la concentration de l''acide ?

## Correction

**1.** Quantité de thiosulfate :
$$n_{1} = 0{,}50 \times 40 \times 10^{-3} = 2{,}0 \times 10^{-2}\ \text{mol} = 20\ \text{mmol}$$

Quantité d''ions oxonium :
$$n_{2} = 5{,}0 \times 10 \times 10^{-3} = 5{,}0 \times 10^{-2}\ \text{mol} = 50\ \text{mmol}$$

D''après l''équation, il faut **deux** ions oxonium pour un thiosulfate. Comparons donc
$$\dfrac{n_{1}}{1} = 20\ \text{mmol} \qquad \text{et} \qquad \dfrac{n_{2}}{2} = 25\ \text{mmol}$$

Le plus petit rapport désigne le réactif limitant : c''est le **thiosulfate**.

**2.** Chaque mole de thiosulfate donne une mole de soufre, donc le maximum vaut $20$ mmol.

Le tableau montre que la quantité finale atteint exactement $20$ mmol, et n''évolue plus après $5$ minutes. La réaction est donc **totale**.

**3.** La vitesse de formation du soufre est
$$v = \dfrac{dn_{\text{S}}}{dt}$$

La vitesse moyenne sur la première demi-minute vaut
$$v_{\text{moy}} = \dfrac{7{,}5 - 0}{0{,}5 - 0} = 15\ \text{mmol}\cdot\text{min}^{-1}$$

Compare avec la vitesse moyenne entre $3$ et $5$ minutes :
$$v_{\text{moy}} = \dfrac{20{,}0 - 19{,}0}{2{,}0} = 0{,}5\ \text{mmol}\cdot\text{min}^{-1}$$

La réaction est devenue **trente fois plus lente**, parce que les réactifs se sont raréfiés.

**4.** La demi-réaction correspond à la moitié de $20$ mmol, soit $10$ mmol.

D''après le tableau, cette valeur est atteinte entre $t = 0{,}5$ min, où l''on a $7{,}5$ mmol, et $t = 1{,}0$ min, où l''on a $12{,}0$ mmol.

Par interpolation linéaire :
$$t_{1/2} \approx 0{,}5 + 0{,}5 \times \dfrac{10 - 7{,}5}{12{,}0 - 7{,}5} = 0{,}5 + 0{,}5 \times \dfrac{2{,}5}{4{,}5} \approx 0{,}78\ \text{min}$$

soit environ **47 secondes**.

**5.** En chauffant à $50\ °\text{C}$, la température est un **facteur cinétique** : la courbe monterait beaucoup plus vite, et le temps de demi-réaction serait nettement plus court. Mais le palier resterait à **20 mmol**, puisque les quantités de réactifs n''ont pas changé.

En doublant la concentration de l''acide, la vitesse initiale augmenterait aussi, car les chocs seraient plus fréquents. Le palier, lui, resterait encore à $20$ mmol : l''acide était déjà en excès, donc en ajouter davantage ne change rien à l''avancement final.

Retiens la règle générale : un facteur cinétique change la **pente**, pas la **hauteur du palier**.', NULL, 25),
      (v_chapitre_id, 'Quiz du chapitre 13', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Pourquoi trempe-t-on l''échantillon prélevé avant de le doser ?",
      "choix": [
        "Pour le colorer",
        "Pour arrêter la réaction pendant le dosage",
        "Pour dissoudre l''ester",
        "Pour neutraliser le catalyseur"
      ],
      "bonne": 1,
      "explication": "Sans trempe, la réaction continuerait pendant les minutes du dosage et la valeur mesurée ne correspondrait plus à l''instant du prélèvement. L''eau glacée refroidit et dilue, ce qui fige la composition."
    },
    {
      "question": "Que signifie le palier horizontal d''une courbe d''estérification ?",
      "choix": [
        "Les réactifs sont épuisés",
        "L''équilibre est atteint",
        "Le catalyseur est consommé",
        "La température a baissé"
      ],
      "bonne": 1,
      "explication": "Au palier, l''estérification et l''hydrolyse se produisent à la même vitesse, donc les quantités n''évoluent plus. Il reste pourtant de l''acide et de l''alcool dans le mélange."
    },
    {
      "question": "On double la température d''un mélange d''estérification. Que devient la hauteur du palier ?",
      "choix": [
        "Elle augmente",
        "Elle diminue",
        "Elle ne change pas",
        "Le palier disparaît"
      ],
      "bonne": 2,
      "explication": "La réaction est athermique, donc la température ne déplace pas l''équilibre. Elle n''est ici qu''un facteur cinétique : on atteint le même palier, simplement plus vite."
    },
    {
      "question": "On part de 1 mol d''ester et 1 mol d''eau au lieu de l''acide et l''alcool. Où se situe le palier ?",
      "choix": [
        "Au même état d''équilibre",
        "À un endroit complètement différent",
        "La réaction n''a pas lieu",
        "À 100 % d''hydrolyse"
      ],
      "bonne": 0,
      "explication": "Les deux expériences conduisent au même état d''équilibre, abordé par un bout ou par l''autre. C''est la meilleure preuve qu''il s''agit d''un véritable équilibre."
    },
    {
      "question": "Lors du dosage de l''acide restant par la soude, quel piège faut-il éviter ?",
      "choix": [
        "Oublier d''agiter",
        "Oublier que la soude dose aussi le catalyseur sulfurique",
        "Utiliser la phénolphtaléine",
        "Prélever trop peu"
      ],
      "bonne": 1,
      "explication": "L''acide sulfurique ajouté comme catalyseur est lui aussi dosé par la soude. Il faut le soustraire, grâce à un dosage à blanc réalisé au temps zéro."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 13, Estérification et hydrolyse : étude cinétique — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
