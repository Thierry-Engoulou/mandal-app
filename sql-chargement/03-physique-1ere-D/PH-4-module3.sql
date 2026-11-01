-- ============================================================================
-- MANDAL — Physique 1ère D : etape 4 sur 5, module 3, optique geometrique
-- Ajoute les lecons, les quiz et les simulations de ce module.
-- A lancer APRES PH-1-structure.sql.
-- Idempotent : relancez-le autant de fois que vous voulez.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Sources de lumière colorée
-- ---------------------------------------------------------------------------
DO $ph$
DECLARE
  r record;
  v_chap uuid;
  v_ordre int;
  v_ajout int := 0;
BEGIN
  SELECT c.id INTO v_chap FROM public.chapitres c
  JOIN public.programmes p ON p.id = c.programme_id
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'Sources de lumière colorée';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "Sources de lumière colorée" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Quiz : sources et couleurs', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Une source primaire de lumière est une source qui :",
      "choix": [
        "produit sa propre lumière",
        "renvoie la lumière reçue",
        "absorbe la lumière"
      ],
      "bonne": 0,
      "explication": "Le Soleil et une lampe sont des sources primaires. La Lune et un mur sont des objets diffusants."
    },
    {
      "question": "La lumière blanche du Soleil est :",
      "choix": [
        "une lumière monochromatique",
        "un mélange de radiations de couleurs différentes",
        "sans couleur"
      ],
      "bonne": 1,
      "explication": "Un prisme la décompose en un spectre continu, du rouge au violet."
    },
    {
      "question": "Les trois couleurs primaires de la synthèse additive sont :",
      "choix": [
        "rouge, vert, bleu",
        "rouge, jaune, bleu",
        "cyan, magenta, jaune"
      ],
      "bonne": 0,
      "explication": "Rouge, vert et bleu : c''est le principe de l''écran de télévision. Cyan, magenta et jaune sont les couleurs de la synthèse soustractive."
    },
    {
      "question": "Un objet paraît rouge en lumière blanche parce qu''il :",
      "choix": [
        "émet du rouge",
        "diffuse le rouge et absorbe le reste",
        "absorbe le rouge"
      ],
      "bonne": 1,
      "explication": "Éclairé en lumière verte, le même objet paraîtrait noir, car il n''aurait aucun rouge à renvoyer."
    }
  ]
}', NULL, 5)
  ) AS t(titre, typ, contenu, media, duree) LOOP
    IF NOT EXISTS (SELECT 1 FROM public.concepts WHERE chapitre_id = v_chap AND titre = r.titre) THEN
      SELECT coalesce(max(ordre), 0) + 1 INTO v_ordre FROM public.concepts WHERE chapitre_id = v_chap;
      INSERT INTO public.concepts
        (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
      VALUES (v_chap, r.titre, v_ordre, r.typ, r.contenu, r.media, r.duree);
      v_ajout := v_ajout + 1;
    END IF;
  END LOOP;
  RAISE NOTICE 'Sources de lumière colorée : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;

-- ---------------------------------------------------------------------------
-- Interaction lumière-matière
-- ---------------------------------------------------------------------------
DO $ph$
DECLARE
  r record;
  v_chap uuid;
  v_ordre int;
  v_ajout int := 0;
BEGIN
  SELECT c.id INTO v_chap FROM public.chapitres c
  JOIN public.programmes p ON p.id = c.programme_id
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'Interaction lumière-matière';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "Interaction lumière-matière" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Quiz : interaction lumière-matière', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Un filtre rouge placé devant une lumière blanche :",
      "choix": [
        "ajoute du rouge",
        "ne laisse passer que le rouge",
        "change le rouge en vert"
      ],
      "bonne": 1,
      "explication": "Un filtre fonctionne par absorption : il retient toutes les radiations sauf celles de sa couleur."
    },
    {
      "question": "Un objet blanc éclairé en lumière bleue paraît :",
      "choix": [
        "blanc",
        "bleu",
        "noir"
      ],
      "bonne": 1,
      "explication": "Un objet blanc diffuse toutes les radiations. S''il ne reçoit que du bleu, il ne peut renvoyer que du bleu."
    },
    {
      "question": "La lumière transporte :",
      "choix": [
        "de la matière",
        "de l''énergie",
        "de la masse"
      ],
      "bonne": 1,
      "explication": "C''est cette énergie qui chauffe une surface exposée au Soleil et qui fait fonctionner un panneau solaire."
    },
    {
      "question": "Un objet noir éclairé en lumière blanche paraît noir parce qu''il :",
      "choix": [
        "absorbe presque toutes les radiations",
        "les diffuse toutes",
        "les réfléchit"
      ],
      "bonne": 0,
      "explication": "Il ne renvoie presque rien vers l''œil, et l''énergie absorbée le fait chauffer. C''est pourquoi un habit noir tient plus chaud au soleil."
    }
  ]
}', NULL, 5)
  ) AS t(titre, typ, contenu, media, duree) LOOP
    IF NOT EXISTS (SELECT 1 FROM public.concepts WHERE chapitre_id = v_chap AND titre = r.titre) THEN
      SELECT coalesce(max(ordre), 0) + 1 INTO v_ordre FROM public.concepts WHERE chapitre_id = v_chap;
      INSERT INTO public.concepts
        (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
      VALUES (v_chap, r.titre, v_ordre, r.typ, r.contenu, r.media, r.duree);
      v_ajout := v_ajout + 1;
    END IF;
  END LOOP;
  RAISE NOTICE 'Interaction lumière-matière : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;

-- ---------------------------------------------------------------------------
-- Les lentilles minces
-- ---------------------------------------------------------------------------
DO $ph$
DECLARE
  r record;
  v_chap uuid;
  v_ordre int;
  v_ajout int := 0;
BEGIN
  SELECT c.id INTO v_chap FROM public.chapitres c
  JOIN public.programmes p ON p.id = c.programme_id
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'Les lentilles minces';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "Les lentilles minces" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Simulation : construire l''image d''un objet', 'interactif', '{
  "widget": "lentille-mince",
  "consigne": "Place l''objet à 7 cm devant une lentille de 3 cm de distance focale. Suis les deux rayons orange : celui qui arrive parallèle à l''axe repart par $F''$, celui qui passe par le centre optique n''est pas dévié. Leur croisement donne l''image. Rapproche maintenant l''objet jusqu''à $F$ : l''image part à l''infini. Passe ensuite en deçà de $F$ : l''image devient virtuelle et droite, c''est le fonctionnement de la loupe."
}', NULL, 10),
    ('Quiz : lentilles minces', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "La relation de conjugaison d''une lentille mince s''écrit :",
      "choix": [
        "$\\dfrac{1}{\\overline{OA''}} - \\dfrac{1}{\\overline{OA}} = \\dfrac{1}{\\overline{OF''}}$",
        "$\\overline{OA''} + \\overline{OA} = \\overline{OF''}$",
        "$\\overline{OA''} \\times \\overline{OA} = \\overline{OF''}$"
      ],
      "bonne": 0,
      "explication": "C''est la relation de Descartes, avec des mesures algébriques comptées depuis le centre optique."
    },
    {
      "question": "Le grandissement $\\gamma$ se calcule par :",
      "choix": [
        "$\\dfrac{\\overline{OA}}{\\overline{OA''}}$",
        "$\\dfrac{\\overline{OA''}}{\\overline{OA}}$",
        "$\\overline{OA} \\times \\overline{OA''}$"
      ],
      "bonne": 1,
      "explication": "Il vaut aussi $\\dfrac{\\overline{A''B''}}{\\overline{AB}}$. S''il est négatif, l''image est renversée."
    },
    {
      "question": "Une image qu''on peut recevoir sur un écran est :",
      "choix": [
        "réelle",
        "virtuelle",
        "toujours droite"
      ],
      "bonne": 0,
      "explication": "Une image virtuelle ne peut pas être projetée : les rayons ne se croisent pas réellement."
    },
    {
      "question": "La vergence d''une lentille de distance focale 25 cm vaut :",
      "choix": [
        "$25$ δ",
        "$4$ δ",
        "$0{,}25$ δ"
      ],
      "bonne": 1,
      "explication": "$C = \\dfrac{1}{f''}$ avec $f''$ en mètres : $\\dfrac{1}{0{,}25} = 4$ dioptries."
    }
  ]
}', NULL, 5)
  ) AS t(titre, typ, contenu, media, duree) LOOP
    IF NOT EXISTS (SELECT 1 FROM public.concepts WHERE chapitre_id = v_chap AND titre = r.titre) THEN
      SELECT coalesce(max(ordre), 0) + 1 INTO v_ordre FROM public.concepts WHERE chapitre_id = v_chap;
      INSERT INTO public.concepts
        (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
      VALUES (v_chap, r.titre, v_ordre, r.typ, r.contenu, r.media, r.duree);
      v_ajout := v_ajout + 1;
    END IF;
  END LOOP;
  RAISE NOTICE 'Les lentilles minces : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;

-- ---------------------------------------------------------------------------
-- L''œil réduit
-- ---------------------------------------------------------------------------
DO $ph$
DECLARE
  r record;
  v_chap uuid;
  v_ordre int;
  v_ajout int := 0;
BEGIN
  SELECT c.id INTO v_chap FROM public.chapitres c
  JOIN public.programmes p ON p.id = c.programme_id
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'L''œil réduit';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "L''œil réduit" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Simulation : accommodation et défauts de l''œil', 'interactif', '{
  "widget": "oeil-reduit",
  "consigne": "Garde l''œil normal et éloigne l''objet jusqu''à 200 cm : l''image reste nette, le cristallin s''est adapté. Rapproche-le maintenant à 10 cm : l''image ne se forme plus sur la rétine, tu es en deçà du punctum proximum. Passe ensuite à l''œil myope et regarde ce qui se passe pour les objets lointains, puis à l''œil hypermétrope pour les objets proches."
}', NULL, 10),
    ('Quiz : l''œil réduit', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Dans le modèle de l''œil réduit, le cristallin joue le rôle :",
      "choix": [
        "d''un écran",
        "d''une lentille convergente",
        "d''un miroir"
      ],
      "bonne": 1,
      "explication": "Le cristallin est assimilé à une lentille convergente, la rétine à un écran, et l''iris à un diaphragme."
    },
    {
      "question": "L''accommodation, c''est la capacité du cristallin à :",
      "choix": [
        "changer de distance focale",
        "se déplacer",
        "changer de couleur"
      ],
      "bonne": 0,
      "explication": "Les muscles ciliaires déforment le cristallin, ce qui modifie sa vergence et garde l''image sur la rétine."
    },
    {
      "question": "Un œil myope voit mal :",
      "choix": [
        "de près",
        "de loin",
        "les couleurs"
      ],
      "bonne": 1,
      "explication": "Son œil est trop convergent : l''image des objets lointains se forme en avant de la rétine. On corrige avec une lentille divergente."
    },
    {
      "question": "Le punctum proximum d''un œil normal se situe vers :",
      "choix": [
        "25 cm",
        "1 m",
        "l''infini"
      ],
      "bonne": 0,
      "explication": "C''est le point le plus proche vu net. Le punctum remotum, lui, est à l''infini pour un œil normal."
    }
  ]
}', NULL, 5)
  ) AS t(titre, typ, contenu, media, duree) LOOP
    IF NOT EXISTS (SELECT 1 FROM public.concepts WHERE chapitre_id = v_chap AND titre = r.titre) THEN
      SELECT coalesce(max(ordre), 0) + 1 INTO v_ordre FROM public.concepts WHERE chapitre_id = v_chap;
      INSERT INTO public.concepts
        (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
      VALUES (v_chap, r.titre, v_ordre, r.typ, r.contenu, r.media, r.duree);
      v_ajout := v_ajout + 1;
    END IF;
  END LOOP;
  RAISE NOTICE 'L''œil réduit : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;

-- ---------------------------------------------------------------------------
-- Étude de quelques instruments d''optique
-- ---------------------------------------------------------------------------
DO $ph$
DECLARE
  r record;
  v_chap uuid;
  v_ordre int;
  v_ajout int := 0;
BEGIN
  SELECT c.id INTO v_chap FROM public.chapitres c
  JOIN public.programmes p ON p.id = c.programme_id
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'Étude de quelques instruments d''optique';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "Étude de quelques instruments d''optique" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Simulation : le principe de la loupe', 'interactif', '{
  "widget": "lentille-mince",
  "consigne": "Prends une lentille convergente de 3 cm de distance focale et place l''objet à seulement 2 cm, donc entre $F$ et la lentille. L''image devient virtuelle, droite et plus grande que l''objet : c''est exactement ce que fait une loupe. Note le grandissement affiché, puis rapproche encore l''objet de la lentille et regarde comment il évolue."
}', NULL, 10),
    ('Quiz : instruments d''optique', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Avec une loupe, l''objet doit être placé :",
      "choix": [
        "au-delà de $2f''$",
        "entre le foyer $F$ et la lentille",
        "exactement en $F$"
      ],
      "bonne": 1,
      "explication": "Dans cette position l''image est virtuelle, droite et agrandie, ce que l''œil peut observer directement."
    },
    {
      "question": "Le microscope est formé de :",
      "choix": [
        "deux lentilles convergentes",
        "une lentille et un miroir",
        "deux lentilles divergentes"
      ],
      "bonne": 0,
      "explication": "L''objectif, de très courte focale, donne une image réelle agrandie ; l''oculaire sert ensuite de loupe."
    },
    {
      "question": "Dans une lunette astronomique, l''objet observé est :",
      "choix": [
        "très proche",
        "pratiquement à l''infini",
        "au foyer de l''oculaire"
      ],
      "bonne": 1,
      "explication": "Les astres sont si éloignés que leurs rayons arrivent parallèles entre eux."
    },
    {
      "question": "Le grossissement d''un instrument compare :",
      "choix": [
        "deux longueurs",
        "deux angles sous lesquels on voit l''objet",
        "deux distances focales"
      ],
      "bonne": 1,
      "explication": "C''est le rapport de l''angle sous lequel on voit l''image à travers l''instrument, à l''angle à l''œil nu."
    }
  ]
}', NULL, 5)
  ) AS t(titre, typ, contenu, media, duree) LOOP
    IF NOT EXISTS (SELECT 1 FROM public.concepts WHERE chapitre_id = v_chap AND titre = r.titre) THEN
      SELECT coalesce(max(ordre), 0) + 1 INTO v_ordre FROM public.concepts WHERE chapitre_id = v_chap;
      INSERT INTO public.concepts
        (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
      VALUES (v_chap, r.titre, v_ordre, r.typ, r.contenu, r.media, r.duree);
      v_ajout := v_ajout + 1;
    END IF;
  END LOOP;
  RAISE NOTICE 'Étude de quelques instruments d''optique : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;
