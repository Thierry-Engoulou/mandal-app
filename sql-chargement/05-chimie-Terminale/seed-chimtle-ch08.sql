-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 8, Acides forts, bases fortes, acides et bases faibles
-- Module 2 : Acides et bases en solution aqueuse
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
    WHERE programme_id = v_programme_id AND ordre = 8;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'Acides forts, bases fortes, acides et bases faibles', 8, 'Module 2 : Acides et bases en solution aqueuse')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 8 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 8 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'Les acides forts et les bases fortes', 1, 'texte', 'Un acide fort est un acide qui cède **totalement** son proton à l''eau. Cette seule phrase suffit à calculer son pH, et c''est pourquoi on commence par là.

## Définition et exemples

Pour un acide fort $\text{HA}$, la réaction avec l''eau est **totale**, et on l''écrit avec une flèche simple :
$$\text{HA} + \text{H}_{2}\text{O} \longrightarrow \text{A}^{-} + \text{H}_{3}\text{O}^{+}$$

Il ne reste plus une seule molécule $\text{HA}$ dans la solution.

Les acides forts à connaître sont l''acide chlorhydrique $\text{HCl}$, l''acide nitrique $\text{HNO}_{3}$ et l''acide sulfurique $\text{H}_{2}\text{SO}_{4}$, qui lui cède deux protons.

## Le pH d''un acide fort

Puisque chaque molécule d''acide donne un ion oxonium, on a directement
$$[\text{H}_{3}\text{O}^{+}] = C_{a} \qquad \text{donc} \qquad \text{pH} = -\log C_{a}$$

C''est tout. Une seule ligne de calcul.

Cette formule n''est valable que si $C_{a}$ reste supérieure à environ $10^{-6}\ \text{mol}\cdot\text{L}^{-1}$. En dessous, les ions venus de l''eau ne sont plus négligeables, et le pH ne dépasse jamais 7.

## Les bases fortes

Symétriquement, une base forte capte **totalement** un proton. La plus courante est l''hydroxyde de sodium, ou soude, qui se dissocie en totalité :
$$\text{NaOH} \longrightarrow \text{Na}^{+} + \text{HO}^{-}$$

On a donc $[\text{HO}^{-}] = C_{b}$, puis
$$\text{pOH} = -\log C_{b} \qquad \text{et} \qquad \text{pH} = 14 + \log C_{b}$$

Le piège classique est d''écrire $\text{pH} = -\log C_{b}$. Vérifie toujours la cohérence : une base doit donner un pH supérieur à 7.

## Exercice d''application

Calcule le pH d''une solution d''acide chlorhydrique à $2{,}0 \times 10^{-3}\ \text{mol}\cdot\text{L}^{-1}$, puis celui d''une solution d''hydroxyde de sodium de même concentration.

Correction. Pour l''acide fort,
$$\text{pH} = -\log(2{,}0 \times 10^{-3}) = 2{,}7$$

Le pH est inférieur à 7, c''est cohérent pour un acide.

Pour la base forte,
$$\text{pH} = 14 + \log(2{,}0 \times 10^{-3}) = 14 - 2{,}7 = 11{,}3$$

Le pH est supérieur à 7, c''est cohérent pour une base.

Remarque la symétrie : les deux pH sont à égale distance de 7, ce qui est normal puisque les concentrations sont égales et les deux espèces totalement dissociées.', NULL, 15),
      (v_chapitre_id, 'Les acides faibles et les bases faibles', 2, 'texte', 'Un acide faible ne cède qu''une **partie** de ses protons. C''est ce « partiellement » qui rend le chapitre plus riche, et plus exigeant.

## L''équilibre d''ionisation

Prends l''acide éthanoïque, l''acide du vinaigre. Dans l''eau :
$$\text{CH}_{3}\text{COOH} + \text{H}_{2}\text{O} \rightleftharpoons \text{CH}_{3}\text{COO}^{-} + \text{H}_{3}\text{O}^{+}$$

La double flèche signale que la réaction est **limitée**. Les deux sens coexistent, et un équilibre s''installe.

Conséquence directe : la solution contient à la fois $\text{CH}_{3}\text{COOH}$ et $\text{CH}_{3}\text{COO}^{-}$, alors qu''avec un acide fort il ne resterait que la forme ionisée.

Et comme tous les protons ne sont pas cédés, le pH d''un acide faible est **plus élevé** que celui d''un acide fort de même concentration.

## Le coefficient d''ionisation

On mesure l''ampleur de l''ionisation par
$$\alpha = \dfrac{\text{quantité d''acide ionisé}}{\text{quantité d''acide apporté}} = \dfrac{[\text{H}_{3}\text{O}^{+}]}{C_{a}}$$

Ce nombre est compris entre 0 et 1, et on l''exprime souvent en pourcentage.

Pour un acide fort, $\alpha = 1$ exactement. Pour l''acide éthanoïque à $10^{-2}\ \text{mol}\cdot\text{L}^{-1}$, $\alpha$ vaut environ $4\%$.

Fait important : $\alpha$ **augmente quand on dilue**. Plus la solution est diluée, plus la proportion ionisée est grande, même si la concentration en ions oxonium, elle, diminue.

## Comment reconnaître un acide faible

Trois signes, tous vérifiables au laboratoire.

Son **pH mesuré est supérieur** au pH calculé par $-\log C_{a}$. C''est le test le plus direct : si tu mesures $3{,}4$ pour une solution à $10^{-2}$, alors qu''un acide fort donnerait $2$, l''acide est faible.

Son **coefficient d''ionisation est inférieur à 1**.

La **dilution par 10 ne fait pas monter le pH d''une unité entière**, mais d''environ une demi-unité.

## Les bases faibles

Même raisonnement en miroir. L''ion éthanoate, base conjuguée de l''acide éthanoïque, réagit partiellement :
$$\text{CH}_{3}\text{COO}^{-} + \text{H}_{2}\text{O} \rightleftharpoons \text{CH}_{3}\text{COOH} + \text{HO}^{-}$$

Les amines sont aussi des bases faibles, comme tu l''as vu au chapitre 4.

Le pH d''une base faible est **inférieur** à celui d''une base forte de même concentration.

## La méthode de résolution

Face à un exercice sur un acide faible, procède toujours de la même façon.

Tu écris l''équation d''ionisation. Tu calcules $[\text{H}_{3}\text{O}^{+}] = 10^{-\text{pH}}$ à partir du pH mesuré. Tu en déduis $[\text{CH}_{3}\text{COO}^{-}]$ par l''électroneutralité, en négligeant $[\text{HO}^{-}]$ si le milieu est nettement acide. Tu obtiens $[\text{CH}_{3}\text{COOH}]$ par la conservation de la matière. Et tu peux alors calculer $\alpha$, ou la constante d''acidité du chapitre suivant.

## Exercice d''application

Une solution d''acide méthanoïque de concentration $C_{a} = 1{,}0 \times 10^{-2}\ \text{mol}\cdot\text{L}^{-1}$ a un pH mesuré de $2{,}9$ à $25\ °\text{C}$. Montre que cet acide est faible, calcule son coefficient d''ionisation, puis les concentrations de toutes les espèces en solution.

Correction. Si l''acide était fort, le pH vaudrait $-\log(1{,}0 \times 10^{-2}) = 2{,}0$. Le pH mesuré est $2{,}9$, donc **supérieur** : l''acide est **faible**.

Calculons les concentrations.
$$[\text{H}_{3}\text{O}^{+}] = 10^{-2{,}9} = 1{,}26 \times 10^{-3}\ \text{mol}\cdot\text{L}^{-1}$$

Le coefficient d''ionisation vaut
$$\alpha = \dfrac{1{,}26 \times 10^{-3}}{1{,}0 \times 10^{-2}} = 0{,}126$$

soit environ $13\%$ seulement. L''acide est bien peu ionisé.

Par électroneutralité, et en négligeant $[\text{HO}^{-}]$ qui vaut $7{,}9 \times 10^{-12}$, totalement négligeable :
$$[\text{HCOO}^{-}] = [\text{H}_{3}\text{O}^{+}] = 1{,}26 \times 10^{-3}\ \text{mol}\cdot\text{L}^{-1}$$

Par conservation de la matière :
$$[\text{HCOOH}] = C_{a} - [\text{HCOO}^{-}] = 1{,}0 \times 10^{-2} - 1{,}26 \times 10^{-3} = 8{,}7 \times 10^{-3}\ \text{mol}\cdot\text{L}^{-1}$$

Enfin $[\text{HO}^{-}] = \dfrac{10^{-14}}{1{,}26 \times 10^{-3}} = 7{,}9 \times 10^{-12}\ \text{mol}\cdot\text{L}^{-1}$.

Remarque que la forme non ionisée $\text{HCOOH}$ reste largement majoritaire, ce qui est la signature d''un acide faible.', NULL, 15),
      (v_chapitre_id, 'Compare un acide fort et un acide faible', 3, 'interactif', '{
  "widget": "acide-fort-faible",
  "consigne": "Choisis un acide et sa concentration, puis lis le pH obtenu. Compare l''acide chlorhydrique et l''acide éthanoïque à la même concentration : lequel donne le pH le plus bas, et pourquoi ? Dilue ensuite dix fois chacun et regarde de combien le pH monte dans les deux cas."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 8', 4, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quel est le pH d''une solution d''acide chlorhydrique à $10^{-3}$ mol/L ?",
      "choix": [
        "3",
        "11",
        "−3",
        "1,3"
      ],
      "bonne": 0,
      "explication": "L''acide chlorhydrique est fort, donc totalement ionisé : $[\\text{H}_3\\text{O}^+] = C_a = 10^{-3}$ et $\\text{pH} = -\\log(10^{-3}) = 3$."
    },
    {
      "question": "Quel est le pH d''une solution de soude à $10^{-2}$ mol/L ?",
      "choix": [
        "2",
        "12",
        "7",
        "−2"
      ],
      "bonne": 1,
      "explication": "Pour une base forte, $[\\text{HO}^-] = C_b$, donc $\\text{pOH} = 2$ et $\\text{pH} = 14 - 2 = 12$. Écrire $\\text{pH} = -\\log C_b = 2$ est le piège classique : une base ne peut pas donner un pH acide."
    },
    {
      "question": "Une solution d''acide à $10^{-2}$ mol/L a un pH mesuré de 3,4. Que peut-on conclure ?",
      "choix": [
        "L''acide est fort",
        "L''acide est faible",
        "La mesure est fausse",
        "La solution est basique"
      ],
      "bonne": 1,
      "explication": "Un acide fort à cette concentration donnerait pH = 2. Le pH mesuré étant plus élevé, tous les protons n''ont pas été cédés : l''acide est faible."
    },
    {
      "question": "Que devient le coefficient d''ionisation d''un acide faible quand on dilue la solution ?",
      "choix": [
        "Il augmente",
        "Il diminue",
        "Il ne change pas",
        "Il devient nul"
      ],
      "bonne": 0,
      "explication": "La dilution déplace l''équilibre dans le sens de l''ionisation, donc la proportion d''acide ionisé augmente. En revanche la concentration en ions oxonium, elle, diminue."
    },
    {
      "question": "Dans une solution d''acide éthanoïque, quelle espèce est majoritaire ?",
      "choix": [
        "L''ion éthanoate",
        "L''acide éthanoïque non ionisé",
        "L''ion hydroxyde",
        "L''ion sodium"
      ],
      "bonne": 1,
      "explication": "L''acide est faible donc peu ionisé : la plus grande partie reste sous forme de molécules $\\text{CH}_3\\text{COOH}$. C''est exactement ce qui distingue un acide faible d''un acide fort."
    },
    {
      "question": "À concentration égale, comment se comparent les pH d''un acide fort et d''un acide faible ?",
      "choix": [
        "Ils sont égaux",
        "L''acide faible a un pH plus bas",
        "L''acide faible a un pH plus élevé",
        "Cela dépend de la température"
      ],
      "bonne": 2,
      "explication": "L''acide faible ne cède qu''une partie de ses protons, donc il libère moins d''ions oxonium. Sa solution est moins acide, et son pH est plus élevé."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 8, Acides forts, bases fortes, acides et bases faibles — 4 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
