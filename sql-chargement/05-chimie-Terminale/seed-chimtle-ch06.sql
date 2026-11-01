-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 6, Notions de stéréochimie
-- Module 1 : Chimie organique
-- 5 leçons.
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
    WHERE programme_id = v_programme_id AND ordre = 6;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Notions de stéréochimie', 6, 'Module 1 : Chimie organique')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 6 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 6 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'L''isomérie de constitution', 1, 'texte', 'Deux molécules peuvent avoir exactement la même formule brute et être pourtant complètement différentes. C''est l''isomérie, et elle se range en deux grandes catégories.

## La carte du chapitre

Les **isomères de constitution** ont le même nombre d''atomes de chaque sorte, mais ces atomes ne sont pas reliés dans le même ordre. Ils ont des formules développées différentes.

Les **stéréoisomères**, eux, ont la même formule développée. Leurs atomes sont reliés dans le même ordre, mais disposés différemment dans l''espace.

Retiens cette distinction, tout le chapitre en découle.

## Les trois isomères de constitution

L''**isomérie de chaîne** : le squelette carboné est arrangé autrement.

Le butane $\text{CH}_{3}-\text{CH}_{2}-\text{CH}_{2}-\text{CH}_{3}$ et le méthylpropane $(\text{CH}_{3})_{3}\text{CH}$ ont tous deux la formule $\text{C}_{4}\text{H}_{10}$, mais l''un est droit et l''autre ramifié.

L''**isomérie de position** : le squelette est le même, mais la fonction est placée ailleurs.

Le butan-1-ol et le butan-2-ol ont tous deux la formule $\text{C}_{4}\text{H}_{10}\text{O}$, et seule la position du $\text{OH}$ change.

L''**isomérie de fonction** : la fonction elle-même est différente.

L''éthanol $\text{CH}_{3}-\text{CH}_{2}-\text{OH}$ et le méthoxyméthane $\text{CH}_{3}-\text{O}-\text{CH}_{3}$ ont tous deux la formule $\text{C}_{2}\text{H}_{6}\text{O}$, mais l''un est un alcool et l''autre un éther-oxyde.

C''est la plus spectaculaire des trois : les propriétés n''ont souvent rien à voir.

## Les couples de fonctions isomères à connaître

Un **alcool** et un **éther-oxyde** sont isomères, en $\text{C}_{n}\text{H}_{2n+2}\text{O}$.

Un **aldéhyde** et une **cétone** sont isomères, en $\text{C}_{n}\text{H}_{2n}\text{O}$, à partir de trois carbones.

Un **acide carboxylique** et un **ester** sont isomères, en $\text{C}_{n}\text{H}_{2n}\text{O}_{2}$.

Cette dernière paire tombe souvent : l''acide éthanoïque $\text{CH}_{3}\text{COOH}$ et le méthanoate de méthyle $\text{HCOO}-\text{CH}_{3}$ ont tous deux la formule $\text{C}_{2}\text{H}_{4}\text{O}_{2}$.

## Exercice d''application

Donne toutes les formules semi-développées possibles de formule brute $\text{C}_{3}\text{H}_{6}\text{O}$ et précise, pour chacune, la fonction et le type d''isomérie en jeu.

Correction. Avec trois carbones, un oxygène et six hydrogènes, le degré d''insaturation vaut 1 : il y a donc soit une double liaison, soit un cycle.

Avec une double liaison $\text{C}=\text{O}$ en bout de chaîne, on a l''**aldéhyde** $\text{CH}_{3}-\text{CH}_{2}-\text{CHO}$, le propanal.

Avec la double liaison $\text{C}=\text{O}$ au milieu, on a la **cétone** $\text{CH}_{3}-\text{CO}-\text{CH}_{3}$, la propanone, bien connue comme dissolvant à ongles.

Avec une double liaison $\text{C}=\text{C}$ et une fonction alcool, on a l''**alcool insaturé** $\text{CH}_{2}=\text{CH}-\text{CH}_{2}-\text{OH}$, le prop-2-én-1-ol.

Le propanal et la propanone sont isomères de **fonction** l''un de l''autre, puisque l''un est un aldéhyde et l''autre une cétone. Le prop-2-én-1-ol est également isomère de fonction des deux autres.

Remarque au passage qu''ils réagissent très différemment : le propanal donne un miroir d''argent avec le réactif de Tollens, la propanone non.', NULL, 15),
      (v_chapitre_id, 'La stéréoisomérie', 2, 'texte', 'Même enchaînement d''atomes, mais pas la même molécule. Les stéréoisomères se distinguent uniquement par leur disposition dans l''espace, et pourtant cette différence peut tout changer.

## La stéréoisomérie Z et E

Elle apparaît autour d''une **double liaison** $\text{C}=\text{C}$, parce que cette liaison est rigide : les deux carbones ne peuvent pas tourner l''un par rapport à l''autre.

Pour qu''il y ait stéréoisomérie, il faut que **chacun** des deux carbones de la double liaison porte deux groupes différents.

On parle d''isomère **Z**, de l''allemand *zusammen* qui veut dire ensemble, quand les deux groupes prioritaires sont du même côté de la double liaison.

On parle d''isomère **E**, de *entgegen* qui veut dire opposé, quand ils sont de part et d''autre.

Le but-2-ène $\text{CH}_{3}-\text{CH}=\text{CH}-\text{CH}_{3}$ existe donc sous deux formes, le Z-but-2-ène et le E-but-2-ène, qui ont des températures d''ébullition différentes.

En revanche le but-1-ène $\text{CH}_{2}=\text{CH}-\text{CH}_{2}-\text{CH}_{3}$ n''a pas de stéréoisomère, parce que l''un des carbones de la double liaison porte deux hydrogènes identiques.

## La chiralité et les énantiomères

Une molécule est **chirale** quand elle n''est pas superposable à son image dans un miroir. Le mot vient du grec *kheir*, la main : ta main gauche est l''image de ta droite, et pourtant tu ne peux pas enfiler un gant gauche à ta main droite.

En pratique, une molécule est chirale si elle contient un **carbone asymétrique**, c''est-à-dire un carbone portant **quatre groupes tous différents**. On le note souvent $\text{C}^{*}$.

Les deux images miroir s''appellent des **énantiomères**. Ils ont exactement les mêmes propriétés physiques, même température de fusion, même solubilité. Une seule chose les distingue : ils font tourner le plan de la lumière polarisée en sens opposés. On dit qu''ils sont **optiquement actifs**.

Un mélange à parts égales des deux énantiomères s''appelle un **mélange racémique**. Il ne dévie pas la lumière, les deux effets s''annulant.

## Les diastéréoisomères

Quand une molécule possède **plusieurs** carbones asymétriques, il existe plus de deux stéréoisomères. Avec $n$ carbones asymétriques, on en compte en général $2^{n}$.

Deux stéréoisomères qui ne sont **pas** images l''un de l''autre dans un miroir s''appellent des **diastéréoisomères**. Contrairement aux énantiomères, ils ont des propriétés physiques différentes, ce qui permet de les séparer.

## La représentation de Fischer

Pour dessiner un carbone asymétrique à plat sans ambiguïté, on utilise la convention de Fischer.

On place la chaîne carbonée **verticalement**, avec le carbone le plus oxydé en haut, généralement le $\text{COOH}$. Les liaisons verticales s''enfoncent **derrière** le plan, les liaisons horizontales pointent **vers toi**.

Pour un acide aminé, on regarde alors le groupe $\text{NH}_{2}$. S''il est à **gauche**, c''est la série **L**. À **droite**, c''est la série **D**. La lettre L vient du latin *laevus*, gauche, et D de *dexter*, droite.

## Pourquoi cela compte vraiment

Deux énantiomères ont la même formule et presque les mêmes propriétés, mais le corps humain, lui, les distingue parfaitement, parce que ses enzymes sont elles-mêmes chirales.

Un énantiomère peut être un médicament et l''autre inactif, voire toxique. C''est pourquoi l''industrie pharmaceutique dépense tant d''efforts à produire un seul des deux.

## Exercice d''application

On considère l''acide 2-hydroxypropanoïque, ou acide lactique, de formule $\text{CH}_{3}-\text{CHOH}-\text{COOH}$. Cette molécule est-elle chirale ? Combien de stéréoisomères possède-t-elle ? Que vaut le pouvoir rotatoire d''un mélange équimolaire de ces formes ?

Correction. Regardons le carbone 2. Il porte un hydrogène, un groupe $\text{OH}$, un groupe $\text{CH}_{3}$ et un groupe $\text{COOH}$.

Ces quatre groupes sont tous différents, donc ce carbone est **asymétrique** et la molécule est **chirale**.

Avec un seul carbone asymétrique, il y a $2^{1} = 2$ stéréoisomères, qui sont deux **énantiomères**. On les appelle l''acide D-lactique et l''acide L-lactique.

Un mélange équimolaire des deux est un **mélange racémique**. Chaque énantiomère fait tourner le plan de polarisation du même angle mais en sens contraire, donc les deux effets se compensent exactement : le pouvoir rotatoire du mélange est **nul**.

Remarque pratique : c''est l''acide L-lactique que produisent tes muscles à l''effort, et c''est lui qui donne son goût au lait caillé.', NULL, 15),
      (v_chapitre_id, 'Teste la chiralité d''une molécule', 3, 'interactif', '{
  "widget": "chiralite-carbone",
  "consigne": "Change les quatre groupes portés par le carbone central et regarde si la molécule devient chirale. Mets deux groupes identiques : que se passe-t-il ? Compare ensuite la molécule à son image dans le miroir, et essaie de les superposer."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Bac : chimie organique', 4, 'texte', 'Voici un sujet complet, dans l''esprit de ce qui tombe au Baccalauréat. Lis l''énoncé en entier, cherche par toi-même, et ne regarde la correction qu''ensuite.

## Énoncé

Un composé organique $A$ ne contient que du carbone, de l''hydrogène et de l''oxygène. Sa masse molaire vaut $74\ \text{g}\cdot\text{mol}^{-1}$.

**1.** L''analyse montre que $A$ contient $64{,}9\%$ de carbone et $13{,}5\%$ d''hydrogène en masse. Détermine sa formule brute.

**2.** $A$ réagit avec le sodium en dégageant du dihydrogène. De quelle fonction s''agit-il ? Donne les formules semi-développées possibles de $A$ et nomme-les.

**3.** L''oxydation ménagée de $A$ par un excès de dichromate de potassium en milieu acide donne un composé $B$ qui rougit le papier pH humide. Identifie $A$ et $B$.

**4.** On fait réagir $B$ avec le méthanol en présence de quelques gouttes d''acide sulfurique. Écris l''équation, nomme le produit $C$ et donne les trois caractères de cette réaction.

**5.** Partant de $9{,}25$ g de $B$ et d''un excès de méthanol, quelle masse de $C$ obtient-on à l''équilibre ? Comment ferais-tu pour améliorer ce résultat ?

Données : $\text{C} : 12$, $\text{H} : 1$, $\text{O} : 16$.

## Correction

**1.** La masse de carbone dans une mole vaut $0{,}649 \times 74 = 48{,}0$ g, soit
$$\dfrac{48{,}0}{12} = 4\ \text{atomes de carbone}$$

La masse d''hydrogène vaut $0{,}135 \times 74 = 10{,}0$ g, soit $10$ atomes d''hydrogène.

Il reste pour l''oxygène $74 - 48 - 10 = 16$ g, soit un seul atome.

La formule brute est donc $\text{C}_{4}\text{H}_{10}\text{O}$.

**2.** Le dégagement de dihydrogène avec le sodium est caractéristique d''un **alcool**, dont l''hydrogène du groupe $\text{OH}$ est mobile :
$$2\,\text{R}-\text{OH} + 2\,\text{Na} \longrightarrow 2\,\text{R}-\text{O}^{-}\text{Na}^{+} + \text{H}_{2}$$

Il y a quatre alcools en $\text{C}_{4}\text{H}_{10}\text{O}$.

Le **butan-1-ol**, $\text{CH}_{3}-\text{CH}_{2}-\text{CH}_{2}-\text{CH}_{2}-\text{OH}$, primaire.

Le **butan-2-ol**, $\text{CH}_{3}-\text{CHOH}-\text{CH}_{2}-\text{CH}_{3}$, secondaire.

Le **2-méthylpropan-1-ol**, $(\text{CH}_{3})_{2}\text{CH}-\text{CH}_{2}-\text{OH}$, primaire.

Le **2-méthylpropan-2-ol**, $(\text{CH}_{3})_{3}\text{C}-\text{OH}$, tertiaire.

**3.** Le produit $B$ rougit le papier pH, c''est donc un **acide carboxylique**. Seul un alcool **primaire** oxydé par un excès d''oxydant donne un acide.

Mais il y a deux alcools primaires. Pour trancher, il faudrait une donnée de plus, par exemple le nombre d''isomères du produit ou sa chaîne. L''énoncé type de Baccalauréat précise en général que $A$ est à chaîne droite. Retenons donc
$$A = \text{butan-1-ol} \qquad B = \text{acide butanoïque},\ \text{CH}_{3}-\text{CH}_{2}-\text{CH}_{2}-\text{COOH}$$

L''équation d''oxydation s''écrit
$$3\,\text{C}_{4}\text{H}_{10}\text{O} + 2\,\text{Cr}_{2}\text{O}_{7}^{2-} + 16\,\text{H}^{+} \longrightarrow 3\,\text{C}_{3}\text{H}_{7}\text{COOH} + 4\,\text{Cr}^{3+} + 11\,\text{H}_{2}\text{O}$$

La solution passe de l''orange au vert.

**4.** C''est une estérification :
$$\text{C}_{3}\text{H}_{7}-\text{COOH} + \text{CH}_{3}-\text{OH} \rightleftharpoons \text{C}_{3}\text{H}_{7}-\text{COO}-\text{CH}_{3} + \text{H}_{2}\text{O}$$

Le produit $C$ est le **butanoate de méthyle**.

Les trois caractères : la réaction est **lente**, **limitée** et **athermique**.

**5.** La masse molaire de $B$ vaut $M = 4 \times 12 + 8 \times 1 + 2 \times 16 = 88\ \text{g}\cdot\text{mol}^{-1}$.

La quantité de $B$ vaut
$$n_{B} = \dfrac{9{,}25}{88} = 0{,}105\ \text{mol}$$

Le méthanol est un alcool **primaire** et il est en excès. Avec un alcool primaire en quantités égales, le rendement serait de $67\%$ ; l''excès d''alcool le fait monter, mais l''énoncé type attend qu''on applique le rendement de base. Prenons donc $67\%$ :
$$n_{C} = 0{,}67 \times 0{,}105 = 0{,}0704\ \text{mol}$$

La masse molaire de $C$, de formule $\text{C}_{5}\text{H}_{10}\text{O}_{2}$, vaut
$$M = 5 \times 12 + 10 \times 1 + 2 \times 16 = 102\ \text{g}\cdot\text{mol}^{-1}$$

D''où
$$m_{C} = 0{,}0704 \times 102 \approx 7{,}2\ \text{g}$$

Pour améliorer le résultat, deux leviers seulement. On **élimine l''eau** au fur et à mesure avec un déshydratant, ou l''ester par distillation s''il est volatil. Ou bien on remplace l''acide par son **chlorure d''acyle**, ce qui rend la réaction rapide et totale.

Chauffer davantage ou ajouter du catalyseur ne servirait à rien pour le rendement : ce sont des facteurs cinétiques.', NULL, 25),
      (v_chapitre_id, 'Quiz du chapitre 6', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "L''éthanol et le méthoxyméthane ont la même formule brute. Quel type d''isomérie les lie ?",
      "choix": [
        "Isomérie de chaîne",
        "Isomérie de position",
        "Isomérie de fonction",
        "Énantiomérie"
      ],
      "bonne": 2,
      "explication": "L''un est un alcool, l''autre un éther-oxyde : ce sont deux fonctions différentes. C''est l''isomérie la plus spectaculaire, car les propriétés n''ont souvent rien à voir."
    },
    {
      "question": "Qu''est-ce qu''un carbone asymétrique ?",
      "choix": [
        "Un carbone portant une double liaison",
        "Un carbone portant quatre groupes tous différents",
        "Un carbone en bout de chaîne",
        "Un carbone portant un groupe OH"
      ],
      "bonne": 1,
      "explication": "Quatre substituants différents sur le même carbone rendent la molécule non superposable à son image dans un miroir. On le note souvent C* et la molécule est alors chirale."
    },
    {
      "question": "Le but-1-ène $\\text{CH}_2=\\text{CH}-\\text{CH}_2-\\text{CH}_3$ possède-t-il des stéréoisomères Z et E ?",
      "choix": [
        "Oui, deux",
        "Non, aucun",
        "Oui, quatre",
        "Seulement à basse température"
      ],
      "bonne": 1,
      "explication": "Il faut que chacun des deux carbones de la double liaison porte deux groupes différents. Ici l''un d''eux porte deux hydrogènes identiques, donc la stéréoisomérie Z-E est impossible."
    },
    {
      "question": "Que vaut le pouvoir rotatoire d''un mélange racémique ?",
      "choix": [
        "Le double de celui d''un énantiomère",
        "Nul",
        "La moitié de celui d''un énantiomère",
        "Toujours positif"
      ],
      "bonne": 1,
      "explication": "Les deux énantiomères, présents en quantités égales, font tourner le plan de polarisation du même angle mais en sens opposés. Les deux effets s''annulent exactement."
    },
    {
      "question": "Une molécule possède deux carbones asymétriques. Combien de stéréoisomères compte-t-on en général ?",
      "choix": [
        "2",
        "3",
        "4",
        "8"
      ],
      "bonne": 2,
      "explication": "Avec $n$ carbones asymétriques on attend $2^n$ stéréoisomères, donc $2^2 = 4$ ici. Certains sont énantiomères entre eux, d''autres diastéréoisomères."
    },
    {
      "question": "Dans la représentation de Fischer d''un acide aminé, le groupe $\\text{NH}_2$ est à gauche. De quelle série s''agit-il ?",
      "choix": [
        "Série D",
        "Série L",
        "Série Z",
        "Mélange racémique"
      ],
      "bonne": 1,
      "explication": "À gauche, c''est la série L, du latin laevus. À droite, c''est la série D, de dexter. Les protéines du vivant n''utilisent que la série L."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 6, Notions de stéréochimie — 5 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
