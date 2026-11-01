-- ============================================================================
-- MANDAL — Chimie Terminale : chapitre 7, L''eau, le pH et les concentrations
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
    WHERE programme_id = v_programme_id AND ordre = 7;

    -- 4. sinon on le cree
    IF v_chapitre_id IS NULL THEN
      INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
      VALUES (v_programme_id, 'L''eau, le pH et les concentrations', 7, 'Module 2 : Acides et bases en solution aqueuse')
      RETURNING id INTO v_chapitre_id;
      RAISE NOTICE '% : chapitre 7 cree.', v_nom;
    END IF;

    -- 5. les lecons
    SELECT count(*) INTO v_deja FROM public.concepts WHERE chapitre_id = v_chapitre_id;
    IF v_deja > 0 THEN
      RAISE NOTICE '% : chapitre 7 contient deja % lecon(s) — aucun ajout.', v_nom, v_deja;
      CONTINUE;
    END IF;

    INSERT INTO public.concepts
      (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
      (v_chapitre_id, 'L''eau, solvant et acide-base', 1, 'texte', 'Toute la chimie des acides et des bases que tu vas étudier se passe dans l''eau. Il faut donc d''abord comprendre pourquoi l''eau est un solvant si particulier.

## Une molécule coudée et polaire

La molécule d''eau n''est pas droite. L''angle entre les deux liaisons $\text{O}-\text{H}$ vaut environ $105°$, à cause des deux doublets libres de l''oxygène qui repoussent les liaisons.

L''oxygène étant bien plus électronégatif que l''hydrogène, il attire les électrons à lui. Il porte donc une charge partielle négative, et chaque hydrogène une charge partielle positive. La molécule est un **dipôle**.

Et comme elle est coudée, ces effets ne se compensent pas. Une molécule linéaire comme $\text{CO}_{2}$, elle, n''est pas polaire malgré ses liaisons polarisées.

## Le pouvoir solvant

C''est cette polarité qui explique tout. Plonge un cristal de chlorure de sodium dans l''eau.

Les molécules d''eau orientent leur côté négatif vers les ions $\text{Na}^{+}$ et leur côté positif vers les ions $\text{Cl}^{-}$. Elles arrachent ainsi les ions du cristal, c''est la **dissociation**, puis les entourent d''une coque protectrice, c''est la **solvatation** ou hydratation.

$$\text{NaCl}_{(s)} \longrightarrow \text{Na}^{+}_{(aq)} + \text{Cl}^{-}_{(aq)}$$

L''eau dissout donc très bien les composés ioniques et les molécules polaires, et très mal les corps gras, qui ne sont pas polaires. D''où le dicton : l''huile et l''eau ne se mélangent pas.

## L''autoprotolyse de l''eau

L''eau pure n''est pas totalement inerte. Très rarement, une molécule d''eau cède un proton à une autre :
$$2\,\text{H}_{2}\text{O} \rightleftharpoons \text{H}_{3}\text{O}^{+} + \text{HO}^{-}$$

C''est l''**autoprotolyse**. L''eau joue à la fois le rôle d''acide et de base, on dit qu''elle est **amphotère**.

La réaction est extrêmement limitée, mais elle existe toujours, dans toute solution aqueuse.

## Le produit ionique de l''eau

À l''équilibre, le produit des concentrations des deux ions est constant :
$$K_{e} = [\text{H}_{3}\text{O}^{+}] \times [\text{HO}^{-}]$$

À $25\ °\text{C}$, cette constante vaut
$$K_{e} = 1{,}0 \times 10^{-14}$$

et on pose $\text{p}K_{e} = -\log K_{e} = 14$.

Cette relation est **toujours vraie** dans l''eau, quelle que soit la solution. Acide, basique ou neutre, le produit des deux concentrations reste $10^{-14}$ à $25\ °\text{C}$.

Attention, $K_{e}$ dépend de la température. À $60\ °\text{C}$ il vaut environ $10^{-13}$. Toutes les valeurs du cours supposent $25\ °\text{C}$.

Dans l''eau **pure**, les deux ions sont en quantités égales, donc
$$[\text{H}_{3}\text{O}^{+}] = [\text{HO}^{-}] = \sqrt{K_{e}} = 10^{-7}\ \text{mol}\cdot\text{L}^{-1}$$

## Exercice d''application

Dans une solution à $25\ °\text{C}$, la concentration en ions hydroxyde vaut $2{,}0 \times 10^{-3}\ \text{mol}\cdot\text{L}^{-1}$. Calcule la concentration en ions oxonium. La solution est-elle acide ou basique ?

Correction. On utilise le produit ionique de l''eau :
$$[\text{H}_{3}\text{O}^{+}] = \dfrac{K_{e}}{[\text{HO}^{-}]} = \dfrac{1{,}0 \times 10^{-14}}{2{,}0 \times 10^{-3}} = 5{,}0 \times 10^{-12}\ \text{mol}\cdot\text{L}^{-1}$$

Les ions hydroxyde sont bien plus nombreux que les ions oxonium, donc la solution est **basique**.

Vérifions autrement : $[\text{H}_{3}\text{O}^{+}] = 5{,}0 \times 10^{-12}$ est inférieur à $10^{-7}$, ce qui confirme le caractère basique.', NULL, 15),
      (v_chapitre_id, 'Les concentrations et la dilution', 2, 'texte', 'Avant de calculer un pH, il faut savoir exprimer ce qu''il y a dans la solution. Trois grandeurs reviennent sans cesse, et il faut passer de l''une à l''autre sans hésiter.

## La concentration molaire

C''est la quantité de matière de soluté par litre de solution :
$$C = \dfrac{n}{V}$$

Elle s''exprime en $\text{mol}\cdot\text{L}^{-1}$. Attention, $V$ est le volume de la **solution**, pas du solvant ajouté.

## La concentration massique

C''est la masse de soluté par litre de solution :
$$C_{m} = \dfrac{m}{V}$$

Elle s''exprime en $\text{g}\cdot\text{L}^{-1}$. Le lien avec la précédente se fait par la masse molaire :
$$C_{m} = C \times M$$

## Les concentrations effectives

Voici une distinction que beaucoup d''élèves manquent. La concentration **apportée**, notée $C$, est celle qu''on a préparée. Les concentrations **effectives**, notées entre crochets, sont celles des espèces réellement présentes après réaction.

Pour un acide fort comme $\text{HCl}$ à $C = 10^{-2}\ \text{mol}\cdot\text{L}^{-1}$, l''ionisation est totale, donc $[\text{H}_{3}\text{O}^{+}] = 10^{-2}$ : les deux coïncident.

Pour un acide faible comme $\text{CH}_{3}\text{COOH}$ à la même concentration apportée, l''ionisation est partielle, donc $[\text{H}_{3}\text{O}^{+}]$ est bien plus petit que $C$, et il reste beaucoup de $\text{CH}_{3}\text{COOH}$ non ionisé.

Ne confonds jamais les deux, c''est la source d''erreur numéro un du module.

## Les deux relations de conservation

Pour résoudre un exercice, on s''appuie toujours sur deux lois.

La **conservation de la matière** dit que tout ce qu''on a apporté se retrouve, sous une forme ou une autre. Pour l''acide éthanoïque :
$$C = [\text{CH}_{3}\text{COOH}] + [\text{CH}_{3}\text{COO}^{-}]$$

L''**électroneutralité** dit qu''une solution est globalement neutre, donc la somme des charges positives égale celle des charges négatives :
$$[\text{H}_{3}\text{O}^{+}] = [\text{CH}_{3}\text{COO}^{-}] + [\text{HO}^{-}]$$

Avec ces deux relations, le produit ionique et la constante d''acidité, tu peux résoudre n''importe quel problème du chapitre.

## La dilution

Diluer, c''est ajouter du solvant sans changer la quantité de soluté. Donc
$$C_{1}\,V_{1} = C_{2}\,V_{2}$$

Le **facteur de dilution** est $F = \dfrac{C_{1}}{C_{2}} = \dfrac{V_{2}}{V_{1}}$.

En pratique, pour préparer une solution diluée, tu prélèves $V_{1}$ à la **pipette jaugée**, tu verses dans une **fiole jaugée** de volume $V_{2}$, puis tu complètes avec de l''eau distillée jusqu''au trait de jauge et tu homogénéises.

N''utilise jamais une éprouvette graduée pour un travail précis : elle n''est pas assez juste.

## Exercice d''application

On veut préparer $250$ mL d''une solution d''acide chlorhydrique à $5{,}0 \times 10^{-2}\ \text{mol}\cdot\text{L}^{-1}$ à partir d''une solution mère à $1{,}0\ \text{mol}\cdot\text{L}^{-1}$. Quel volume faut-il prélever ? Décris le mode opératoire.

Correction. On applique la conservation de la quantité de matière :
$$C_{1}\,V_{1} = C_{2}\,V_{2}$$

D''où
$$V_{1} = \dfrac{C_{2}\,V_{2}}{C_{1}} = \dfrac{5{,}0 \times 10^{-2} \times 0{,}250}{1{,}0} = 1{,}25 \times 10^{-2}\ \text{L} = 12{,}5\ \text{mL}$$

Le facteur de dilution vaut $F = \dfrac{1{,}0}{5{,}0 \times 10^{-2}} = 20$, ce qui est cohérent avec $\dfrac{250}{12{,}5} = 20$.

Mode opératoire. On prélève $12{,}5$ mL de solution mère à la pipette jaugée, on les verse dans une fiole jaugée de $250$ mL contenant déjà un peu d''eau distillée, on complète jusqu''au trait de jauge, on bouche et on retourne plusieurs fois pour homogénéiser.

Règle de sécurité : avec un acide concentré, on verse toujours **l''acide dans l''eau**, et jamais l''inverse, car la dissolution dégage beaucoup de chaleur et pourrait provoquer des projections.', NULL, 15),
      (v_chapitre_id, 'Le pH : définition, mesure et interprétation', 3, 'texte', 'Manipuler des concentrations de $10^{-12}\ \text{mol}\cdot\text{L}^{-1}$ est pénible. Le pH est simplement une façon commode de les écrire.

## La définition

$$\text{pH} = -\log\,[\text{H}_{3}\text{O}^{+}]$$

et la relation inverse
$$[\text{H}_{3}\text{O}^{+}] = 10^{-\text{pH}}$$

La concentration s''exprime en $\text{mol}\cdot\text{L}^{-1}$, et le pH n''a pas d''unité.

Cette définition n''est valable que pour les solutions diluées, disons jusqu''à $10^{-1}\ \text{mol}\cdot\text{L}^{-1}$.

## L''échelle de pH

À $25\ °\text{C}$, une solution est **acide** si $\text{pH} < 7$, **neutre** si $\text{pH} = 7$, et **basique** si $\text{pH} > 7$.

Attention, ce 7 n''est pas magique : il vaut $\dfrac{\text{p}K_{e}}{2}$, donc il change avec la température. À $60\ °\text{C}$, l''eau pure a un pH de $6{,}5$ et elle reste pourtant neutre.

## L''échelle est logarithmique

C''est le point que les élèves oublient le plus souvent. Quand le pH **baisse d''une unité**, la concentration en ions oxonium est **multipliée par 10**.

Entre un jus de citron à $\text{pH} = 2$ et une eau minérale à $\text{pH} = 7$, il n''y a pas un écart de 5, mais un facteur $10^{5}$, soit cent mille fois plus d''ions oxonium.

De même, diluer dix fois une solution d''acide fort augmente son pH d''une unité exactement.

## Le lien avec les ions hydroxyde

En combinant la définition avec le produit ionique, on obtient
$$\text{pH} + \text{pOH} = \text{p}K_{e} = 14 \quad \text{à } 25\ °\text{C}$$

où $\text{pOH} = -\log\,[\text{HO}^{-}]$. C''est très pratique pour les solutions basiques.

## Mesurer le pH

Le **papier pH** donne une indication rapide à une unité près. C''est suffisant pour savoir si une solution est acide ou basique, pas pour un calcul.

Les **indicateurs colorés** changent de teinte dans une zone étroite. Ils servent surtout à repérer l''équivalence d''un dosage.

Le **pH-mètre** donne une mesure précise au dixième, voire au centième. Il faut l''**étalonner** avant usage avec au moins deux solutions tampon de pH connus, souvent 4 et 7, puis rincer l''électrode à l''eau distillée entre deux mesures.

L''étalonnage est la question de cours classique : sans lui, la mesure ne vaut rien.

## Exercice d''application

Une solution a un pH de $3{,}4$ à $25\ °\text{C}$. Calcule $[\text{H}_{3}\text{O}^{+}]$ et $[\text{HO}^{-}]$. On dilue ensuite cette solution 100 fois ; que devient son pH, en supposant qu''il s''agit d''un acide fort ?

Correction. La concentration en ions oxonium vaut
$$[\text{H}_{3}\text{O}^{+}] = 10^{-3{,}4} = 4{,}0 \times 10^{-4}\ \text{mol}\cdot\text{L}^{-1}$$

Celle en ions hydroxyde s''obtient par le produit ionique :
$$[\text{HO}^{-}] = \dfrac{10^{-14}}{4{,}0 \times 10^{-4}} = 2{,}5 \times 10^{-11}\ \text{mol}\cdot\text{L}^{-1}$$

Pour la dilution, s''il s''agit d''un acide fort, $[\text{H}_{3}\text{O}^{+}]$ est divisée par 100 :
$$[\text{H}_{3}\text{O}^{+}] = \dfrac{4{,}0 \times 10^{-4}}{100} = 4{,}0 \times 10^{-6}\ \text{mol}\cdot\text{L}^{-1}$$

Le nouveau pH vaut
$$\text{pH} = -\log(4{,}0 \times 10^{-6}) = 5{,}4$$

Le pH a donc augmenté de 2 unités, exactement comme attendu pour une dilution d''un facteur $100 = 10^{2}$. Retiens cette règle : diluer un acide fort d''un facteur $10^{n}$ augmente son pH de $n$ unités.', NULL, 15),
      (v_chapitre_id, 'Promène-toi sur l''échelle des pH', 4, 'interactif', '{
  "widget": "echelle-ph",
  "consigne": "Choisis une solution de la vie courante et lis son pH, puis la concentration en ions oxonium correspondante. Compare le jus de citron et l''eau de mer : combien de fois plus d''ions oxonium dans le premier ? Dilue ensuite une solution et regarde le pH grimper."
}', NULL, 10),
      (v_chapitre_id, 'Quiz du chapitre 7', 5, 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Que vaut le produit ionique de l''eau à 25 °C ?",
      "choix": [
        "$10^{-7}$",
        "$10^{-14}$",
        "$10^{14}$",
        "$7$"
      ],
      "bonne": 1,
      "explication": "$K_e = [\\text{H}_3\\text{O}^+][\\text{HO}^-] = 1{,}0 \\times 10^{-14}$ à 25 °C. Cette relation est vraie dans toute solution aqueuse, qu''elle soit acide, neutre ou basique."
    },
    {
      "question": "Une solution a un pH de 5. Combien de fois plus d''ions oxonium contient-elle qu''une solution de pH 8 ?",
      "choix": [
        "3 fois plus",
        "30 fois plus",
        "1 000 fois plus",
        "Autant"
      ],
      "bonne": 2,
      "explication": "L''échelle est logarithmique : trois unités de pH correspondent à un facteur $10^3 = 1\\,000$. C''est l''erreur la plus fréquente, on raisonne souvent en différence au lieu de rapport."
    },
    {
      "question": "On dilue 10 fois une solution d''acide fort. Que devient son pH ?",
      "choix": [
        "Il diminue de 1",
        "Il augmente de 1",
        "Il est divisé par 10",
        "Il ne change pas"
      ],
      "bonne": 1,
      "explication": "La concentration en ions oxonium est divisée par 10, donc son logarithme baisse d''une unité et le pH augmente de 1. Diluer d''un facteur $10^n$ augmente le pH de $n$ unités."
    },
    {
      "question": "Pourquoi l''eau dissout-elle bien le sel mais pas l''huile ?",
      "choix": [
        "Parce que l''eau est liquide",
        "Parce que la molécule d''eau est polaire et le sel ionique, alors que l''huile n''est pas polaire",
        "Parce que le sel est solide",
        "Parce que l''huile est plus légère"
      ],
      "bonne": 1,
      "explication": "La molécule d''eau est coudée et polaire. Elle peut donc entourer et séparer les ions du cristal. Les corps gras, non polaires, n''offrent aucune prise à ces interactions."
    },
    {
      "question": "Avant d''utiliser un pH-mètre, que faut-il impérativement faire ?",
      "choix": [
        "Le chauffer",
        "L''étalonner avec des solutions tampon",
        "Le plonger dans l''acide",
        "Le sécher au feu"
      ],
      "bonne": 1,
      "explication": "Sans étalonnage avec au moins deux solutions tampon de pH connus, la mesure n''a aucune valeur. Il faut aussi rincer l''électrode à l''eau distillée entre deux mesures."
    },
    {
      "question": "Dans une solution basique à 25 °C, que peut-on dire ?",
      "choix": [
        "$[\\text{H}_3\\text{O}^+] > 10^{-7}$",
        "$[\\text{HO}^-] > [\\text{H}_3\\text{O}^+]$",
        "$[\\text{HO}^-] = 0$",
        "Le produit ionique est nul"
      ],
      "bonne": 1,
      "explication": "Dans une solution basique, les ions hydroxyde dominent. Les ions oxonium ne disparaissent jamais complètement : leur produit avec les hydroxyde reste égal à $10^{-14}$."
    }
  ]
}', NULL, 5);

    RAISE NOTICE '% : chapitre 7, L''eau, le pH et les concentrations — 5 lecons ajoutees.', v_nom;
  END LOOP;
END $chi$;
