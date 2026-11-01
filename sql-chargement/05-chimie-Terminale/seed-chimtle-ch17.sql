-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 17, Les dosages d''oxydoréduction
-- Module 4 : Oxydoréduction
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
    WHERE programme_id = v_programme_id AND ordre = 17;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les dosages d''oxydoréduction', 17, 'Module 4 : Oxydoréduction')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 17 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 17 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les dosages d''oxydoréduction', 1, 'texte', 'Le principe est exactement celui des dosages acide-base : on fait réagir une solution de concentration inconnue avec une solution titrante, jusqu''à l''équivalence. Seule la réaction change.

## Les conditions à remplir

Une réaction ne peut servir de support à un dosage que si elle est **totale**, **rapide** et **unique**, c''est-à-dire sans réaction parasite.

Pour les dosages rédox, on vérifie que l''écart des potentiels standard est grand, en pratique supérieur à $0{,}3$ V. Plus il est grand, plus la réaction est complète.

## La relation à l''équivalence

À l''équivalence, les réactifs ont été mélangés dans les proportions **stœchiométriques** de l''équation bilan.

Attention, ces proportions ne sont presque jamais de un pour un en oxydoréduction. Il faut d''abord écrire l''équation, puis en tirer la relation.

Pour une équation $a\,\text{Ox}_{1} + b\,\text{Red}_{2} \longrightarrow \ldots$, la relation s''écrit
$$\dfrac{n_{1}}{a} = \dfrac{n_{2}}{b} \qquad \text{soit} \qquad \dfrac{C_{1}V_{1}}{a} = \dfrac{C_{2}V_{2\text{E}}}{b}$$

C''est l''erreur la plus fréquente du chapitre : appliquer $C_{1}V_{1} = C_{2}V_{2}$ sans regarder les coefficients.

## Le dosage par le permanganate

C''est le plus élégant, parce qu''il **ne demande aucun indicateur**.

Le permanganate est violet intense, et l''ion $\text{Mn}^{2+}$ est incolore. Tant qu''il reste du réducteur dans le bécher, chaque goutte versée se décolore aussitôt. Dès que le réducteur est épuisé, la goutte suivante **persiste** et colore la solution en rose pâle.

L''équivalence est donc repérée par la **persistance de la teinte rose**. On dit que le permanganate est son propre indicateur.

Le dosage du fer II par le permanganate s''écrit
$$\text{MnO}_{4}^{-} + 5\,\text{Fe}^{2+} + 8\,\text{H}^{+} \longrightarrow \text{Mn}^{2+} + 5\,\text{Fe}^{3+} + 4\,\text{H}_{2}\text{O}$$

Le rapport est de **un pour cinq**, pas un pour un. Le milieu doit être acidifié, et toujours à l''acide sulfurique : l''acide chlorhydrique serait lui-même oxydé par le permanganate.

## Le dosage iodométrique

Le second grand classique. Le diiode $\text{I}_{2}$ est brun en solution, l''ion iodure $\text{I}^{-}$ est incolore.

On dose le diiode par le thiosulfate de sodium :
$$\text{I}_{2} + 2\,\text{S}_{2}\text{O}_{3}^{2-} \longrightarrow 2\,\text{I}^{-} + \text{S}_{4}\text{O}_{6}^{2-}$$

On peut suivre la décoloration du brun, mais la fin est difficile à voir. On ajoute donc de l''**empois d''amidon**, qui donne une coloration bleu-noir très intense avec le diiode. L''équivalence est marquée par la **disparition brutale du bleu**.

Précaution importante : on n''ajoute l''empois d''amidon qu''**en fin de dosage**, quand la solution est devenue jaune pâle. Ajouté trop tôt, il piège le diiode et fausse le résultat.

## Exercice d''application

On dose $20{,}0$ mL d''une solution de sulfate de fer II, acidifiée à l''acide sulfurique, par une solution de permanganate de potassium à $2{,}00 \times 10^{-2}\ \text{mol}\cdot\text{L}^{-1}$. La teinte rose persiste après avoir versé $18{,}0$ mL. Calcule la concentration en ions fer II, puis la masse de fer contenue dans un litre de la solution dosée. On donne $\text{Fe} : 56\ \text{g}\cdot\text{mol}^{-1}$.

Correction. Écrivons d''abord l''équation. Les deux demi-équations sont
$$\text{MnO}_{4}^{-} + 8\,\text{H}^{+} + 5\,\text{e}^{-} \longrightarrow \text{Mn}^{2+} + 4\,\text{H}_{2}\text{O}$$
$$\text{Fe}^{2+} \longrightarrow \text{Fe}^{3+} + \text{e}^{-}$$

En multipliant la seconde par 5 et en additionnant :
$$\text{MnO}_{4}^{-} + 5\,\text{Fe}^{2+} + 8\,\text{H}^{+} \longrightarrow \text{Mn}^{2+} + 5\,\text{Fe}^{3+} + 4\,\text{H}_{2}\text{O}$$

Le rapport est donc de **1 permanganate pour 5 fer**.

Quantité de permanganate versée à l''équivalence :
$$n(\text{MnO}_{4}^{-}) = 2{,}00 \times 10^{-2} \times 18{,}0 \times 10^{-3} = 3{,}60 \times 10^{-4}\ \text{mol}$$

Quantité de fer II dosée :
$$n(\text{Fe}^{2+}) = 5 \times 3{,}60 \times 10^{-4} = 1{,}80 \times 10^{-3}\ \text{mol}$$

Concentration :
$$C = \dfrac{1{,}80 \times 10^{-3}}{20{,}0 \times 10^{-3}} = 9{,}00 \times 10^{-2}\ \text{mol}\cdot\text{L}^{-1}$$

Masse de fer par litre :
$$m = C \times M = 9{,}00 \times 10^{-2} \times 56 = 5{,}04\ \text{g}\cdot\text{L}^{-1}$$

Vérifie bien le facteur 5. Si tu avais écrit $C_{1}V_{1} = C_{2}V_{2}$, tu aurais trouvé cinq fois moins, soit $1{,}8 \times 10^{-2}\ \text{mol}\cdot\text{L}^{-1}$, et une réponse fausse.', NULL, 15),
      (v_chapitre_id, 'Réalise un dosage d''oxydoréduction', 2, 'interactif', '{
  "widget": "dosage-redox",
  "consigne": "Choisis le couple titrant et verse la solution goutte à goutte. Guette le changement de couleur qui marque l''équivalence. Lis le volume versé, puis calcule la concentration en tenant compte des coefficients de l''équation. Compare avec la valeur que donne le simulateur."
}', NULL, 10),
      (v_chapitre_id, 'Sujet type Bac : oxydoréduction', 3, 'texte', 'Voici un sujet d''oxydoréduction, dans l''esprit du Baccalauréat. Le point difficile est toujours la stœchiométrie : prends le temps d''écrire l''équation avant de calculer.

## Énoncé

On dispose d''une solution $S$ de sulfate de fer II de concentration inconnue.

**1.** Écris les demi-équations des couples $\text{MnO}_{4}^{-}/\text{Mn}^{2+}$ et $\text{Fe}^{3+}/\text{Fe}^{2+}$, puis l''équation bilan du dosage du fer II par le permanganate en milieu acide.

**2.** On dose $V_{a} = 10{,}0$ mL de $S$ acidifiée par du permanganate de potassium à $C = 1{,}50 \times 10^{-2}\ \text{mol}\cdot\text{L}^{-1}$. La teinte rose persiste pour $V_{\text{E}} = 12{,}0$ mL. Calcule la concentration de $S$.

**3.** Pourquoi ce dosage ne nécessite-t-il aucun indicateur coloré ? Pourquoi acidifie-t-on à l''acide sulfurique et non à l''acide chlorhydrique ?

**4.** On réalise maintenant une pile en associant une demi-pile fer, $\text{Fe}^{2+}/\text{Fe}$ de potentiel $E^{\circ}_{1} = -0{,}44$ V, et une demi-pile cuivre, $\text{Cu}^{2+}/\text{Cu}$ de potentiel $E^{\circ}_{2} = +0{,}34$ V. Identifie les pôles, écris les réactions aux électrodes, donne l''équation bilan et calcule la force électromotrice.

**5.** Indique le sens de circulation des électrons dans le fil, et dis ce que devient chaque lame au cours du fonctionnement.

Données : $\text{Fe} : 56\ \text{g}\cdot\text{mol}^{-1}$.

## Correction

**1.** Pour le permanganate, on équilibre les oxygènes par de l''eau, les hydrogènes par des $\text{H}^{+}$, puis les charges par des électrons :
$$\text{MnO}_{4}^{-} + 8\,\text{H}^{+} + 5\,\text{e}^{-} \longrightarrow \text{Mn}^{2+} + 4\,\text{H}_{2}\text{O}$$

Pour le fer :
$$\text{Fe}^{2+} \longrightarrow \text{Fe}^{3+} + \text{e}^{-}$$

Pour additionner, il faut le même nombre d''électrons : on multiplie la seconde par 5.
$$\text{MnO}_{4}^{-} + 5\,\text{Fe}^{2+} + 8\,\text{H}^{+} \longrightarrow \text{Mn}^{2+} + 5\,\text{Fe}^{3+} + 4\,\text{H}_{2}\text{O}$$

**2.** Quantité de permanganate versée :
$$n(\text{MnO}_{4}^{-}) = 1{,}50 \times 10^{-2} \times 12{,}0 \times 10^{-3} = 1{,}80 \times 10^{-4}\ \text{mol}$$

D''après l''équation, un permanganate consomme **cinq** fer II :
$$n(\text{Fe}^{2+}) = 5 \times 1{,}80 \times 10^{-4} = 9{,}00 \times 10^{-4}\ \text{mol}$$

D''où
$$C_{\text{Fe}} = \dfrac{9{,}00 \times 10^{-4}}{10{,}0 \times 10^{-3}} = 9{,}00 \times 10^{-2}\ \text{mol}\cdot\text{L}^{-1}$$

Soit, en masse de fer par litre, $9{,}00 \times 10^{-2} \times 56 = 5{,}04\ \text{g}\cdot\text{L}^{-1}$.

**3.** Le permanganate est violet et l''ion $\text{Mn}^{2+}$ incolore. Tant qu''il reste du fer II, chaque goutte versée se décolore aussitôt. Dès l''équivalence franchie, la goutte suivante n''a plus rien à réduire et **persiste**, colorant le mélange en rose pâle. Le réactif titrant est donc **son propre indicateur**.

On acidifie à l''acide sulfurique parce que le permanganate est assez oxydant pour oxyder les ions **chlorure** en dichlore. Cette réaction parasite consommerait du titrant et donnerait un volume équivalent trop grand, donc une concentration surestimée.

**4.** Le couple de potentiel le plus élevé est celui du cuivre. C''est donc là que se produit la **réduction**, à la **cathode**, pôle **positif** :
$$\text{Cu}^{2+} + 2\,\text{e}^{-} \longrightarrow \text{Cu}$$

Le couple de plus bas potentiel est celui du fer. C''est là que se produit l''**oxydation**, à l''**anode**, pôle **négatif** :
$$\text{Fe} \longrightarrow \text{Fe}^{2+} + 2\,\text{e}^{-}$$

Les deux demi-équations échangent deux électrons chacune, on les additionne directement :
$$\text{Fe} + \text{Cu}^{2+} \longrightarrow \text{Fe}^{2+} + \text{Cu}$$

La force électromotrice vaut
$$E = E^{\circ}_{\text{cathode}} - E^{\circ}_{\text{anode}} = 0{,}34 - (-0{,}44) = 0{,}78\ \text{V}$$

Elle est positive, ce qui confirme que les pôles ont été correctement identifiés.

**5.** Les **électrons** sortent du pôle négatif et vont vers le pôle positif, donc ils circulent dans le fil **du fer vers le cuivre**. Le courant conventionnel, lui, va en sens inverse, du cuivre vers le fer.

La lame de **fer maigrit**, puisqu''elle se dissout en ions $\text{Fe}^{2+}$. La lame de **cuivre grossit**, par dépôt de cuivre métallique, et la solution bleue pâlit à mesure qu''elle perd ses ions $\text{Cu}^{2+}$.', NULL, 25),
      (v_chapitre_id, 'Quiz du chapitre 17', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Pourquoi le dosage par le permanganate ne nécessite-t-il pas d''indicateur coloré ?",
      "choix": [
        "Parce qu''il est incolore",
        "Parce que sa couleur violette persiste dès l''équivalence dépassée",
        "Parce qu''il précipite",
        "Parce qu''il dégage un gaz"
      ],
      "bonne": 1,
      "explication": "Tant qu''il reste du réducteur, chaque goutte de permanganate se décolore. Dès l''équivalence franchie, la goutte suivante persiste et rosit la solution : le réactif est son propre indicateur."
    },
    {
      "question": "Dans le dosage du fer II par le permanganate, quel est le rapport stœchiométrique ?",
      "choix": [
        "1 pour 1",
        "1 pour 2",
        "1 pour 5",
        "5 pour 1"
      ],
      "bonne": 2,
      "explication": "Le permanganate échange 5 électrons et le fer II un seul, donc il faut 5 ions $\\text{Fe}^{2+}$ pour un ion $\\text{MnO}_4^-$. Oublier ce facteur 5 est l''erreur la plus courante."
    },
    {
      "question": "Pourquoi acidifie-t-on à l''acide sulfurique et non à l''acide chlorhydrique ?",
      "choix": [
        "L''acide sulfurique est moins cher",
        "Les ions chlorure seraient oxydés par le permanganate",
        "L''acide chlorhydrique est trop dilué",
        "Pour éviter les précipités"
      ],
      "bonne": 1,
      "explication": "Le permanganate est un oxydant assez fort pour oxyder les ions chlorure en dichlore. Cette réaction parasite consommerait du titrant et fausserait le dosage."
    },
    {
      "question": "Quand doit-on ajouter l''empois d''amidon dans un dosage iodométrique ?",
      "choix": [
        "Dès le début",
        "En fin de dosage, quand la solution est jaune pâle",
        "Après l''équivalence",
        "Jamais"
      ],
      "bonne": 1,
      "explication": "Ajouté trop tôt, l''empois piège le diiode et le libère mal, ce qui fausse le résultat. On l''ajoute donc juste avant l''équivalence, quand il ne reste que peu de diiode."
    },
    {
      "question": "Quelles conditions une réaction doit-elle remplir pour servir de support à un dosage ?",
      "choix": [
        "Être lente et limitée",
        "Être totale, rapide et unique",
        "Dégager un gaz",
        "Changer de couleur"
      ],
      "bonne": 1,
      "explication": "Totale pour que l''équivalence soit nette, rapide pour que chaque goutte réagisse aussitôt, unique pour qu''aucune réaction parasite ne consomme de réactif."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 17, Les dosages d''oxydoréduction — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
