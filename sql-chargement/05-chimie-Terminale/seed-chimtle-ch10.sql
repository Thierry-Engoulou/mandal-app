-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 10, Dosages acido-basiques et solutions tampon
-- Module 2 : Acides et bases en solution aqueuse
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
    WHERE programme_id = v_programme_id AND ordre = 10;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Dosages acido-basiques et solutions tampon', 10, 'Module 2 : Acides et bases en solution aqueuse')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 10 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 10 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Le principe d''un dosage acido-basique', 1, 'texte', 'Doser, c''est déterminer une concentration inconnue en faisant réagir la solution avec une autre, de concentration connue. C''est la manipulation la plus pratiquée du programme.

## Le vocabulaire

La solution **titrée** est celle dont on cherche la concentration. On en prélève un volume précis à la pipette jaugée, et on le place dans le bécher.

La solution **titrante** est celle dont on connaît la concentration. On la place dans la burette graduée, et on la verse progressivement.

L''**équivalence** est l''instant où les réactifs ont été mélangés dans les proportions exactes de l''équation. Ni l''un ni l''autre n''est alors en excès.

## La relation à l''équivalence

Pour une réaction qui consomme une mole d''acide pour une mole de base :
$$C_{a}\,V_{a} = C_{b}\,V_{b\text{E}}$$

où $V_{b\text{E}}$ est le volume versé à l''équivalence.

Attention aux diacides et dibases. Pour l''acide sulfurique, qui libère deux protons, la relation devient $2\,C_{a}V_{a} = C_{b}V_{b\text{E}}$.

## Le montage

Dans le bécher, la solution titrée, un barreau aimanté et l''électrode du pH-mètre, le tout sur un agitateur magnétique. Au-dessus, la burette graduée contenant la solution titrante.

Trois précautions à connaître. On étalonne le pH-mètre avant de commencer. On ajoute si nécessaire de l''eau distillée dans le bécher pour que l''électrode baigne bien, ce qui **ne change pas** la quantité d''acide et donc pas le volume équivalent. Et on agite sans arrêt pour homogénéiser.

## Repérer l''équivalence

Deux méthodes, et il faut savoir les deux.

Par **pH-métrie**, on trace $\text{pH} = f(V_{b})$ et on repère le point d''inflexion, là où la courbe monte le plus vite. On utilise la **méthode des tangentes** : on trace deux tangentes parallèles de part et d''autre du saut, puis une parallèle équidistante. Son intersection avec la courbe donne le point d''équivalence $E$.

Par **indicateur coloré**, on choisit un indicateur dont la zone de virage **contient** le pH à l''équivalence, et on repère le changement de couleur. C''est moins précis, mais plus rapide et sans appareil.

## Exercice d''application

On dose $V_{a} = 20{,}0$ mL d''une solution d''acide chlorhydrique par une solution d''hydroxyde de sodium à $C_{b} = 0{,}120\ \text{mol}\cdot\text{L}^{-1}$. L''équivalence est obtenue pour $V_{b\text{E}} = 15{,}0$ mL. Calcule la concentration de l''acide, puis le pH du mélange après avoir versé $10{,}0$ mL de soude.

Correction. À l''équivalence,
$$C_{a} = \dfrac{C_{b}\,V_{b\text{E}}}{V_{a}} = \dfrac{0{,}120 \times 15{,}0}{20{,}0} = 0{,}0900\ \text{mol}\cdot\text{L}^{-1}$$

Pour le pH après $10{,}0$ mL, calculons les quantités de matière.

Acide initial : $n_{a} = 0{,}0900 \times 0{,}0200 = 1{,}80 \times 10^{-3}$ mol.

Base versée : $n_{b} = 0{,}120 \times 0{,}0100 = 1{,}20 \times 10^{-3}$ mol.

La base est en défaut, donc elle est entièrement consommée. Il reste de l''acide :
$$n_{a\text{ restant}} = 1{,}80 \times 10^{-3} - 1{,}20 \times 10^{-3} = 6{,}0 \times 10^{-4}\ \text{mol}$$

Le volume total vaut $20{,}0 + 10{,}0 = 30{,}0$ mL, soit $0{,}0300$ L. Donc
$$[\text{H}_{3}\text{O}^{+}] = \dfrac{6{,}0 \times 10^{-4}}{0{,}0300} = 2{,}0 \times 10^{-2}\ \text{mol}\cdot\text{L}^{-1}$$

et
$$\text{pH} = -\log(2{,}0 \times 10^{-2}) = 1{,}7$$

N''oublie jamais de diviser par le volume **total**, celui du mélange. C''est l''erreur la plus fréquente de tout le chapitre.', NULL, 15),
      (v_chapitre_id, 'Les quatre dosages et le choix de l''indicateur', 2, 'texte', 'Selon la force de l''acide et de la base, l''allure de la courbe change, et le pH à l''équivalence aussi. Il faut connaître les quatre cas.

## Acide fort par base forte

La réaction est $\text{H}_{3}\text{O}^{+} + \text{HO}^{-} \longrightarrow 2\,\text{H}_{2}\text{O}$, de constante $10^{14}$ : elle est **totale**.

Le pH de départ est très bas, le saut à l''équivalence est **très marqué**, souvent de 4 à 10, et
$$\text{pH}_{\text{E}} = 7$$

À l''équivalence il ne reste que des ions spectateurs, $\text{Na}^{+}$ et $\text{Cl}^{-}$, qui ne modifient pas le pH.

## Acide faible par base forte

La réaction est $\text{AH} + \text{HO}^{-} \longrightarrow \text{A}^{-} + \text{H}_{2}\text{O}$, totale elle aussi car l''écart des $\text{p}K_{a}$ est grand.

Le pH de départ est plus élevé que dans le cas précédent. Le saut est **moins marqué**. Et surtout
$$\text{pH}_{\text{E}} > 7$$

parce qu''il reste la base conjuguée $\text{A}^{-}$, qui est une base faible.

Cette courbe a une particularité précieuse : à la **demi-équivalence**, c''est-à-dire pour $V_{b} = \dfrac{V_{b\text{E}}}{2}$, on a $\text{pH} = \text{p}K_{a}$. C''est la méthode expérimentale de mesure d''un $\text{p}K_{a}$.

## Acide fort par base faible

Symétrique du précédent. Le saut est atténué et
$$\text{pH}_{\text{E}} < 7$$

car il reste l''acide conjugué de la base faible, par exemple l''ion ammonium.

## Acide faible par base faible

Le saut est si peu marqué qu''on ne peut pas repérer l''équivalence de façon fiable. **Ce dosage ne se pratique pas**.

## Choisir l''indicateur coloré

La règle est simple : la **zone de virage** de l''indicateur doit contenir le $\text{pH}_{\text{E}}$.

Les trois indicateurs à connaître sont l''**hélianthine**, qui vire entre $3{,}1$ et $4{,}4$, du rouge au jaune ; le **bleu de bromothymol**, ou BBT, qui vire entre $6{,}0$ et $7{,}6$, du jaune au bleu ; et la **phénolphtaléine**, qui vire entre $8{,}2$ et $10{,}0$, de l''incolore au rose.

Pour un dosage acide fort par base forte, $\text{pH}_{\text{E}} = 7$, donc on prend le **BBT**.

Pour un acide faible par base forte, $\text{pH}_{\text{E}}$ vaut typiquement $8{,}5$, donc on prend la **phénolphtaléine**.

Pour un acide fort par base faible, $\text{pH}_{\text{E}}$ vaut typiquement $5{,}5$, donc on prend l''**hélianthine**.

Retiens le sens physique : l''indicateur doit changer de couleur **pendant** le saut, sinon il vire trop tôt ou trop tard et fausse le résultat.

## Les solutions tampon

Une **solution tampon** est une solution dont le pH varie très peu quand on ajoute un peu d''acide, un peu de base, ou quand on dilue.

On la prépare en mélangeant un acide faible et sa base conjuguée en quantités comparables. Son pH vaut alors
$$\text{pH} = \text{p}K_{a} + \log\dfrac{[\text{A}^{-}]}{[\text{AH}]}$$

Le tampon est le plus efficace quand $[\text{A}^{-}] = [\text{AH}]$, donc quand $\text{pH} = \text{p}K_{a}$.

En pratique, on obtient un tampon en s''arrêtant à la **demi-équivalence** d''un dosage d''acide faible par base forte.

Pourquoi cela marche. Si tu ajoutes de l''acide, la base $\text{A}^{-}$ présente en réserve le consomme. Si tu ajoutes de la base, l''acide $\text{AH}$ la consomme. Le rapport des deux formes bouge peu, donc le pH aussi.

Ton sang est une solution tampon, à base d''ions hydrogénocarbonate, maintenue à $\text{pH} = 7{,}4$. Un écart de $0{,}4$ unité suffit à mettre la vie en danger.

## Exercice d''application

On dose $20{,}0$ mL d''acide éthanoïque de concentration inconnue par de la soude à $0{,}100\ \text{mol}\cdot\text{L}^{-1}$. La courbe montre une équivalence à $V_{b\text{E}} = 12{,}0$ mL, et le pH vaut $4{,}8$ pour $V_{b} = 6{,}0$ mL. Détermine la concentration de l''acide, son $\text{p}K_{a}$, et choisis l''indicateur coloré.

Correction. À l''équivalence,
$$C_{a} = \dfrac{0{,}100 \times 12{,}0}{20{,}0} = 0{,}0600\ \text{mol}\cdot\text{L}^{-1}$$

Le volume $6{,}0$ mL vaut exactement la moitié de $12{,}0$ mL : c''est la **demi-équivalence**. Donc
$$\text{p}K_{a} = \text{pH} = 4{,}8$$

Ce qui correspond bien à l''acide éthanoïque, dont le $\text{p}K_{a}$ tabulé vaut $4{,}8$.

Pour l''indicateur, on dose un acide **faible** par une base **forte**, donc $\text{pH}_{\text{E}} > 7$, autour de $8{,}5$. La **phénolphtaléine**, qui vire entre $8{,}2$ et $10{,}0$, convient parfaitement.

Le BBT virerait trop tôt et l''hélianthine beaucoup trop tôt : tous deux donneraient un volume équivalent faussé par défaut.', NULL, 15),
      (v_chapitre_id, 'Trace une courbe de dosage', 3, 'interactif', '{
  "widget": "courbe-dosage",
  "consigne": "Choisis l''acide et la base, puis verse la solution titrante millilitre par millilitre. Repère le saut de pH et place l''équivalence. Compare un acide fort et un acide faible : lequel donne le saut le plus net ? Teste ensuite les trois indicateurs colorés et trouve celui qui convient."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Bac : acides et bases', 4, 'texte', 'Voici un sujet complet d''acides et bases, dans l''esprit du Baccalauréat. Prends une feuille, cherche, puis compare.

## Énoncé

On dispose d''une solution $S$ d''acide méthanoïque $\text{HCOOH}$ de concentration $C_{a} = 2{,}0 \times 10^{-2}\ \text{mol}\cdot\text{L}^{-1}$. Son pH mesuré à $25\ °\text{C}$ vaut $2{,}6$.

**1.** Montre que l''acide méthanoïque est un acide faible.

**2.** Calcule les concentrations de toutes les espèces chimiques présentes dans $S$, puis le coefficient d''ionisation de l''acide.

**3.** Détermine la constante d''acidité $K_{a}$ et le $\text{p}K_{a}$ du couple.

**4.** On dose $V_{a} = 20{,}0$ mL de $S$ par une solution d''hydroxyde de sodium de concentration $C_{b} = 2{,}0 \times 10^{-2}\ \text{mol}\cdot\text{L}^{-1}$. Écris l''équation du dosage et calcule le volume équivalent.

**5.** Quel est le pH à la demi-équivalence ? À l''équivalence, le pH sera-t-il acide, neutre ou basique ? Justifie.

**6.** Parmi l''hélianthine, zone de virage $3{,}1$ à $4{,}4$, le bleu de bromothymol, $6{,}0$ à $7{,}6$, et la phénolphtaléine, $8{,}2$ à $10{,}0$, lequel choisis-tu ? Pourquoi ?

Données : $K_{e} = 10^{-14}$ à $25\ °\text{C}$.

## Correction

**1.** Si l''acide était fort, on aurait $\text{pH} = -\log(2{,}0 \times 10^{-2}) = 1{,}7$.

Le pH mesuré vaut $2{,}6$, donc il est **supérieur** au pH calculé. Tous les protons n''ont pas été cédés : l''acide est **faible**.

**2.** Calculons les quatre espèces.
$$[\text{H}_{3}\text{O}^{+}] = 10^{-2{,}6} = 2{,}51 \times 10^{-3}\ \text{mol}\cdot\text{L}^{-1}$$
$$[\text{HO}^{-}] = \dfrac{10^{-14}}{2{,}51 \times 10^{-3}} = 3{,}98 \times 10^{-12}\ \text{mol}\cdot\text{L}^{-1}$$

Par électroneutralité, $[\text{H}_{3}\text{O}^{+}] = [\text{HCOO}^{-}] + [\text{HO}^{-}]$. Comme $[\text{HO}^{-}]$ est neuf ordres de grandeur plus petit, on le néglige :
$$[\text{HCOO}^{-}] = 2{,}51 \times 10^{-3}\ \text{mol}\cdot\text{L}^{-1}$$

Par conservation de la matière :
$$[\text{HCOOH}] = 2{,}0 \times 10^{-2} - 2{,}51 \times 10^{-3} = 1{,}75 \times 10^{-2}\ \text{mol}\cdot\text{L}^{-1}$$

Le coefficient d''ionisation vaut
$$\alpha = \dfrac{2{,}51 \times 10^{-3}}{2{,}0 \times 10^{-2}} = 0{,}126$$

soit environ $13\%$. L''acide est bien peu ionisé, ce qui confirme la réponse 1.

**3.** Appliquons la définition :
$$K_{a} = \dfrac{[\text{HCOO}^{-}]\,[\text{H}_{3}\text{O}^{+}]}{[\text{HCOOH}]} = \dfrac{2{,}51 \times 10^{-3} \times 2{,}51 \times 10^{-3}}{1{,}75 \times 10^{-2}}$$

Le numérateur vaut $6{,}30 \times 10^{-6}$, donc
$$K_{a} = \dfrac{6{,}30 \times 10^{-6}}{1{,}75 \times 10^{-2}} = 3{,}60 \times 10^{-4}$$

et
$$\text{p}K_{a} = -\log(3{,}60 \times 10^{-4}) = 3{,}4$$

**4.** L''équation du dosage s''écrit
$$\text{HCOOH} + \text{HO}^{-} \longrightarrow \text{HCOO}^{-} + \text{H}_{2}\text{O}$$

À l''équivalence, $C_{a}V_{a} = C_{b}V_{b\text{E}}$. Les concentrations étant égales,
$$V_{b\text{E}} = V_{a} = 20{,}0\ \text{mL}$$

**5.** À la demi-équivalence, c''est-à-dire pour $V_{b} = 10{,}0$ mL, la moitié de l''acide a réagi, donc $[\text{HCOO}^{-}] = [\text{HCOOH}]$ et
$$\text{pH} = \text{p}K_{a} = 3{,}4$$

À l''équivalence, tout l''acide a été consommé. Il ne reste en solution que l''ion méthanoate et l''ion sodium. L''ion méthanoate est la **base conjuguée d''un acide faible**, donc une base faible, qui réagit partiellement avec l''eau :
$$\text{HCOO}^{-} + \text{H}_{2}\text{O} \rightleftharpoons \text{HCOOH} + \text{HO}^{-}$$

Cette réaction libère des ions hydroxyde, donc le pH à l''équivalence est **basique**, supérieur à 7. On trouve en pratique une valeur voisine de $8$.

**6.** Il faut un indicateur dont la zone de virage **contient** le pH à l''équivalence, voisin de $8$.

L''hélianthine virerait vers $3{,}5$, bien trop tôt. Le bleu de bromothymol virerait vers $7$, encore trop tôt. Seule la **phénolphtaléine**, qui vire entre $8{,}2$ et $10{,}0$, encadre la valeur cherchée.

On choisit donc la **phénolphtaléine**, dont le virage de l''incolore au rose persistant marquera l''équivalence.', NULL, 25),
      (v_chapitre_id, 'Quiz du chapitre 10', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "On dose 20 mL d''acide à 0,05 mol/L par une base à 0,10 mol/L. Quel volume faut-il à l''équivalence ?",
      "choix": [
        "5 mL",
        "10 mL",
        "20 mL",
        "40 mL"
      ],
      "bonne": 1,
      "explication": "À l''équivalence, $C_aV_a = C_bV_{bE}$, donc $V_{bE} = (0{,}05 \\times 20)/0{,}10 = 10$ mL. La base étant deux fois plus concentrée, il en faut deux fois moins."
    },
    {
      "question": "Quel est le pH à l''équivalence d''un dosage d''acide fort par base forte ?",
      "choix": [
        "Inférieur à 7",
        "Égal à 7",
        "Supérieur à 7",
        "Égal au pKa"
      ],
      "bonne": 1,
      "explication": "À l''équivalence il ne reste que des ions spectateurs, qui ne modifient pas le pH de l''eau. Le pH vaut donc 7 à 25 °C."
    },
    {
      "question": "Quel indicateur choisir pour doser l''acide éthanoïque par la soude ?",
      "choix": [
        "L''hélianthine",
        "Le bleu de bromothymol",
        "La phénolphtaléine",
        "N''importe lequel"
      ],
      "bonne": 2,
      "explication": "C''est un acide faible dosé par une base forte, donc le pH à l''équivalence dépasse 7, vers 8,5. Seule la phénolphtaléine, qui vire entre 8,2 et 10,0, encadre cette valeur."
    },
    {
      "question": "À quoi sert la demi-équivalence dans un dosage d''acide faible ?",
      "choix": [
        "À calculer la concentration",
        "À lire directement le pKa",
        "À choisir l''indicateur",
        "À vérifier le volume de la burette"
      ],
      "bonne": 1,
      "explication": "À la demi-équivalence, les formes acide et basique sont en quantités égales, donc le pH lu sur la courbe vaut directement le pKa du couple."
    },
    {
      "question": "Qu''est-ce qui caractérise une solution tampon ?",
      "choix": [
        "Son pH est toujours 7",
        "Son pH varie peu par ajout modéré d''acide, de base ou par dilution",
        "Elle ne contient pas d''ions",
        "Elle est toujours basique"
      ],
      "bonne": 1,
      "explication": "Le mélange d''un acide faible et de sa base conjuguée dispose d''une réserve dans les deux sens. Tout ajout modéré est absorbé, et le rapport des deux formes bouge peu, donc le pH aussi."
    },
    {
      "question": "On ajoute de l''eau distillée dans le bécher avant un dosage. Que devient le volume équivalent ?",
      "choix": [
        "Il augmente",
        "Il diminue",
        "Il ne change pas",
        "Le dosage devient impossible"
      ],
      "bonne": 2,
      "explication": "L''ajout d''eau ne change pas la quantité de matière d''acide présente dans le bécher, seulement sa concentration. Comme l''équivalence porte sur les quantités, le volume versé reste le même."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 10, Dosages acido-basiques et solutions tampon — 5 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
