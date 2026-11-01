-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 2, Les acides carboxyliques
-- Module 1 : Chimie organique
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
    WHERE programme_id = v_programme_id AND ordre = 2;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Les acides carboxyliques', 2, 'Module 1 : Chimie organique')
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
      (v_chapitre_id, 'Reconnaître et nommer un acide carboxylique', 1, 'texte', 'Le vinaigre que tu achètes au marché, c''est de l''acide éthanoïque dilué. Le goût acide du citron vient de l''acide citrique. Cette famille est partout.

## Le groupe caractéristique

Un acide carboxylique porte le groupe **carboxyle**, qu''on écrit $-\text{COOH}$ en formule semi-développée.

Ce raccourci cache la vraie structure. Le même carbone porte une **double liaison** avec un oxygène et une **liaison simple** avec un groupe $\text{OH}$, ce qu''on détaille par $-\text{CO}-\text{OH}$. C''est cette combinaison qui fait toute la différence avec un alcool.

La formule générale d''un acide carboxylique saturé est $\text{C}_{n}\text{H}_{2n+1}\text{COOH}$, qu''on note souvent $\text{R}-\text{COOH}$. Sa masse molaire vaut $14n + 46$.

## La nomenclature

On compte **tous** les carbones de la chaîne principale, y compris celui du groupe carboxyle, qui porte toujours le numéro 1.

On prend le nom de l''alcane correspondant, et on ajoute le suffixe **-oïque**, précédé du mot acide.

Ainsi $\text{HCOOH}$ est l''acide méthanoïque, $\text{CH}_{3}\text{COOH}$ l''acide éthanoïque, $\text{CH}_{3}-\text{CH}_{2}-\text{COOH}$ l''acide propanoïque.

Beaucoup gardent aussi un nom usuel : l''acide méthanoïque s''appelle acide formique, l''acide éthanoïque acide acétique.

## Les propriétés physiques

Les acides carboxyliques bouillent **encore plus haut** que les alcools de masse comparable. La raison est que deux molécules d''acide s''associent par **deux** liaisons hydrogène à la fois, formant un dimère très stable.

L''acide éthanoïque bout à $118\ °\text{C}$, alors que l''éthanol bout à $78\ °\text{C}$ et le propane à $-42\ °\text{C}$. Pour des masses molaires voisines, l''écart est considérable.

Les premiers termes sont très solubles dans l''eau et ont une odeur piquante désagréable. Au-delà de cinq ou six carbones, la solubilité chute.

## Comment les préparer

On les obtient surtout par **oxydation ménagée** d''un alcool primaire avec un excès d''oxydant, ou d''un aldéhyde.
$$\text{R}-\text{CH}_{2}\text{OH} \longrightarrow \text{R}-\text{CHO} \longrightarrow \text{R}-\text{COOH}$$

On les obtient aussi par **hydrolyse** d''un ester ou d''un nitrile.

## Exercice d''application

Un acide carboxylique saturé à chaîne ouverte a une masse molaire de $88\ \text{g}\cdot\text{mol}^{-1}$. Détermine sa formule brute, donne toutes ses formules semi-développées possibles et nomme-les. On donne $\text{C} : 12$, $\text{H} : 1$, $\text{O} : 16$.

Correction. La formule générale est $\text{C}_{n}\text{H}_{2n+1}\text{COOH}$, de masse molaire $14n + 46$.

On résout $14n + 46 = 88$, donc $14n = 42$ et $n = 3$. L''acide est en $\text{C}_{3}\text{H}_{7}\text{COOH}$, soit $\text{C}_{4}\text{H}_{8}\text{O}_{2}$.

Il faut maintenant placer les quatre carbones. Comme celui du carboxyle est forcément en bout de chaîne, il reste à arranger trois carbones.

En chaîne droite, on obtient $\text{CH}_{3}-\text{CH}_{2}-\text{CH}_{2}-\text{COOH}$, l''**acide butanoïque**.

Avec une ramification, on obtient $(\text{CH}_{3})_{2}\text{CH}-\text{COOH}$, l''**acide 2-méthylpropanoïque**.

Il n''y a que ces deux isomères. Remarque que l''acide butanoïque est celui qui donne au beurre rance son odeur caractéristique.', NULL, 15),
      (v_chapitre_id, 'Les propriétés acides et la décarboxylation', 2, 'texte', 'Le mot acide est dans le nom, mais attention : ce sont des acides **faibles**. Ils ne se comportent pas du tout comme l''acide chlorhydrique.

## L''ionisation dans l''eau

Dissous dans l''eau, un acide carboxylique ne cède qu''une petite partie de ses protons :
$$\text{R}-\text{COOH} + \text{H}_{2}\text{O} \rightleftharpoons \text{R}-\text{COO}^{-} + \text{H}_{3}\text{O}^{+}$$

La double flèche est essentielle : la réaction n''est pas totale, un équilibre s''établit. Dans une solution d''acide éthanoïque à $10^{-2}\ \text{mol}\cdot\text{L}^{-1}$, moins de $5\%$ des molécules sont ionisées.

L''ion $\text{R}-\text{COO}^{-}$ s''appelle l''ion **carboxylate**. Avec l''acide éthanoïque, c''est l''ion éthanoate.

Le couple acide-base est donc $\text{R}-\text{COOH}/\text{R}-\text{COO}^{-}$, et son $\text{p}K_{a}$ vaut typiquement entre $4$ et $5$. Pour l''acide éthanoïque, $\text{p}K_{a} = 4{,}8$.

## Pourquoi cette acidité

Dans un alcool, l''hydrogène du $\text{OH}$ part très difficilement. Dans un acide carboxylique, il part bien plus facilement.

La raison est que l''ion carboxylate qui reste est stabilisé : la charge négative se répartit également sur les **deux** oxygènes, au lieu de rester concentrée sur un seul. Cette répartition rend l''ion bien plus stable, donc sa formation plus facile.

## Les réactions acide-base

Avec une **base forte**, la réaction est totale et donne un sel :
$$\text{R}-\text{COOH} + \text{Na}^{+} + \text{HO}^{-} \longrightarrow \text{R}-\text{COO}^{-} + \text{Na}^{+} + \text{H}_{2}\text{O}$$

Avec un **carbonate**, il y a effervescence, car il se dégage du dioxyde de carbone :
$$2\,\text{R}-\text{COOH} + \text{Na}_{2}\text{CO}_{3} \longrightarrow 2\,\text{R}-\text{COO}^{-}\text{Na}^{+} + \text{H}_{2}\text{O} + \text{CO}_{2}$$

Ce dégagement de gaz est le test le plus simple pour reconnaître un acide carboxylique au laboratoire.

Avec un **métal** comme le magnésium ou le zinc, il se dégage du dihydrogène :
$$2\,\text{R}-\text{COOH} + \text{Mg} \longrightarrow (\text{R}-\text{COO}^{-})_{2}\text{Mg}^{2+} + \text{H}_{2}$$

## La décarboxylation

Chauffé fortement, ou chauffé en présence de chaux sodée, un acide carboxylique perd son groupe carboxyle sous forme de dioxyde de carbone :
$$\text{R}-\text{COOH} \longrightarrow \text{R}-\text{H} + \text{CO}_{2}$$

La molécule perd donc un carbone. L''acide éthanoïque donne du méthane, l''acide propanoïque donne de l''éthane.

C''est une façon de **raccourcir** une chaîne carbonée d''un atome, ce qui est parfois demandé dans les exercices de synthèse.

## Exercice d''application

On dose $20{,}0$ mL d''une solution d''acide éthanoïque de concentration inconnue par une solution d''hydroxyde de sodium à $0{,}100\ \text{mol}\cdot\text{L}^{-1}$. L''équivalence est atteinte pour $16{,}0$ mL de soude versée. Calcule la concentration de l''acide. Le pH à l''équivalence sera-t-il acide, neutre ou basique ?

Correction. À l''équivalence, les réactifs ont été mélangés dans les proportions de l''équation, donc
$$C_{a} \times V_{a} = C_{b} \times V_{b}$$

D''où
$$C_{a} = \dfrac{C_{b}\,V_{b}}{V_{a}} = \dfrac{0{,}100 \times 16{,}0}{20{,}0} = 0{,}0800\ \text{mol}\cdot\text{L}^{-1}$$

Pour le pH à l''équivalence, il faut regarder ce qui se trouve dans le bécher. Tout l''acide a été consommé, il ne reste que des ions éthanoate et des ions sodium.

L''ion éthanoate est la **base conjuguée** d''un acide faible, donc c''est une base faible. Il réagit un peu avec l''eau :
$$\text{CH}_{3}\text{COO}^{-} + \text{H}_{2}\text{O} \rightleftharpoons \text{CH}_{3}\text{COOH} + \text{HO}^{-}$$

Cette réaction libère des ions hydroxyde, donc le pH à l''équivalence est **basique**, supérieur à 7. On trouve en pratique une valeur voisine de $8{,}5$.

C''est pour cela qu''on utilise la phénolphtaléine, qui vire vers $8{,}2$, et jamais l''hélianthine pour ce dosage.', NULL, 15),
      (v_chapitre_id, 'Place les couples sur l''échelle des pKa', 3, 'interactif', '{
  "widget": "echelle-pka",
  "consigne": "Fais glisser les couples acide-base sur l''échelle et lis leur force. Compare l''acide éthanoïque à l''acide chlorhydrique. Trouve ensuite quel acide réagit avec quelle base : la règle du gamma se lit directement sur l''échelle."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 2', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quelle est la formule du groupe caractéristique des acides carboxyliques ?",
      "choix": [
        "$-\\text{OH}$",
        "$-\\text{CHO}$",
        "$-\\text{COOH}$",
        "$-\\text{NH}_2$"
      ],
      "bonne": 2,
      "explication": "Le groupe carboxyle $-\\text{COOH}$ réunit sur le même carbone une double liaison avec un oxygène et un groupe hydroxyle. C''est cette combinaison qui donne ses propriétés à la famille."
    },
    {
      "question": "Un acide carboxylique saturé a une masse molaire de 60 g/mol. Quel est-il ?",
      "choix": [
        "L''acide méthanoïque",
        "L''acide éthanoïque",
        "L''acide propanoïque",
        "L''acide butanoïque"
      ],
      "bonne": 1,
      "explication": "La masse molaire vaut $14n + 46$. On résout $14n + 46 = 60$, donc $n = 1$ : c''est $\\text{CH}_3\\text{COOH}$, l''acide éthanoïque, celui du vinaigre."
    },
    {
      "question": "Pourquoi un acide carboxylique est-il plus acide qu''un alcool ?",
      "choix": [
        "Parce qu''il est plus lourd",
        "Parce que l''ion carboxylate répartit sa charge sur deux oxygènes",
        "Parce qu''il contient plus de carbone",
        "Parce qu''il bout plus haut"
      ],
      "bonne": 1,
      "explication": "Une fois le proton parti, la charge négative se partage entre les deux oxygènes au lieu de rester sur un seul. L''ion obtenu est donc bien plus stable, ce qui facilite le départ du proton."
    },
    {
      "question": "On verse une solution d''acide éthanoïque sur du carbonate de sodium. Qu''observe-t-on ?",
      "choix": [
        "Un précipité blanc",
        "Une effervescence",
        "Un miroir d''argent",
        "Rien du tout"
      ],
      "bonne": 1,
      "explication": "La réaction dégage du dioxyde de carbone, d''où l''effervescence. C''est le test le plus simple pour reconnaître un acide carboxylique au laboratoire."
    },
    {
      "question": "Au moment de l''équivalence d''un dosage d''acide éthanoïque par la soude, le pH est :",
      "choix": [
        "inférieur à 7",
        "égal à 7",
        "supérieur à 7",
        "impossible à prévoir"
      ],
      "bonne": 2,
      "explication": "À l''équivalence il ne reste que l''ion éthanoate, base conjuguée d''un acide faible, donc une base faible. Elle réagit un peu avec l''eau et rend le milieu basique, vers pH 8,5."
    },
    {
      "question": "La décarboxylation de l''acide propanoïque donne :",
      "choix": [
        "du propane",
        "de l''éthane",
        "du méthane",
        "de l''éthanol"
      ],
      "bonne": 1,
      "explication": "La décarboxylation retire le groupe carboxyle sous forme de CO₂, donc la molécule perd un carbone. L''acide propanoïque, à trois carbones, donne l''éthane, à deux carbones."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 2, Les acides carboxyliques — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
