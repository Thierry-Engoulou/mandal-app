-- ============================================================================
-- MANDAL — Physique 1ère D : etape 3 sur 5, module 2, mouvements et interactions
-- Ajoute les lecons, les quiz et les simulations de ce module.
-- A lancer APRES PH-1-structure.sql.
-- Idempotent : relancez-le autant de fois que vous voulez.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Travail et puissance d''une force
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
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'Travail et puissance d''une force';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "Travail et puissance d''une force" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Simulation : travail moteur, résistant ou nul', 'interactif', '{
  "widget": "travail-force",
  "consigne": "Mets l''angle à 0° : la force tire dans le sens du déplacement, le travail est maximal. Monte à 90° : le travail devient nul, car $\\cos 90° = 0$. Dépasse 90° et le travail devient négatif : la force s''oppose au mouvement, comme le font les frottements. Fais varier aussi la distance et vérifie que le travail lui est proportionnel."
}', NULL, 10),
    ('Quiz : travail et puissance', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Le travail d''une force constante se calcule par :",
      "choix": [
        "$W = F \\times d$",
        "$W = F \\times d \\times \\cos \\alpha$",
        "$W = \\dfrac{F}{d}$"
      ],
      "bonne": 1,
      "explication": "Seule la composante de la force dans le sens du déplacement travaille, d''où le facteur $\\cos \\alpha$."
    },
    {
      "question": "Le travail du poids d''un homme qui marche sur un terrain horizontal est :",
      "choix": [
        "moteur",
        "nul",
        "résistant"
      ],
      "bonne": 1,
      "explication": "Le poids est vertical, le déplacement horizontal : l''angle vaut 90° et $\\cos 90° = 0$."
    },
    {
      "question": "Une force de 200 N déplace une caisse de 5 m dans son sens. Le travail vaut :",
      "choix": [
        "$40$ J",
        "$1\\,000$ J",
        "$205$ J"
      ],
      "bonne": 1,
      "explication": "$W = 200 \\times 5 \\times \\cos 0° = 1\\,000$ J."
    },
    {
      "question": "La puissance moyenne se calcule par :",
      "choix": [
        "$P = W \\times t$",
        "$P = \\dfrac{W}{t}$",
        "$P = \\dfrac{t}{W}$"
      ],
      "bonne": 1,
      "explication": "La puissance est le travail fourni par unité de temps, en watts."
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
  RAISE NOTICE 'Travail et puissance d''une force : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;

-- ---------------------------------------------------------------------------
-- L''énergie cinétique
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
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'L''énergie cinétique';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "L''énergie cinétique" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Simulation : la vitesse et l''énergie cinétique', 'interactif', '{
  "widget": "energie-mecanique",
  "consigne": "Place la bille en haut de la piste : sa vitesse est faible et la barre rouge est courte. Fais-la descendre jusqu''au point le plus bas : la barre rouge devient maximale. Vérifie à chaque position que $E_{c} = \\frac{1}{2}mv^{2}$ correspond bien à la vitesse affichée. Remarque surtout que doubler la vitesse multiplie l''énergie cinétique par quatre."
}', NULL, 10),
    ('Quiz : énergie cinétique', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "L''énergie cinétique d''un solide en translation vaut :",
      "choix": [
        "$mv$",
        "$\\dfrac{1}{2}mv^{2}$",
        "$mgh$"
      ],
      "bonne": 1,
      "explication": "$mgh$ est l''énergie potentielle de pesanteur, pas l''énergie cinétique."
    },
    {
      "question": "Si la vitesse d''une voiture double, son énergie cinétique est multipliée par :",
      "choix": [
        "2",
        "4",
        "8"
      ],
      "bonne": 1,
      "explication": "La vitesse est au carré dans la formule, donc $2^{2} = 4$. C''est pourquoi la distance de freinage s''allonge tant avec la vitesse."
    },
    {
      "question": "Une moto de 150 kg roule à 20 m/s. Son énergie cinétique vaut :",
      "choix": [
        "$3\\,000$ J",
        "$30\\,000$ J",
        "$60\\,000$ J"
      ],
      "bonne": 1,
      "explication": "$E_{c} = 0{,}5 \\times 150 \\times 400 = 30\\,000$ J, soit 30 kJ."
    },
    {
      "question": "Le théorème de l''énergie cinétique dit que la variation de $E_{c}$ est égale :",
      "choix": [
        "à la somme des travaux des forces extérieures",
        "au poids du corps",
        "à la puissance moyenne"
      ],
      "bonne": 0,
      "explication": "$\\Delta E_{c} = \\sum W(\\vec{F}_{ext})$. C''est l''outil de base pour calculer une vitesse finale."
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
  RAISE NOTICE 'L''énergie cinétique : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;

-- ---------------------------------------------------------------------------
-- L''énergie potentielle
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
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'L''énergie potentielle';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "L''énergie potentielle" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Simulation : l''altitude et l''énergie potentielle', 'interactif', '{
  "widget": "energie-mecanique",
  "consigne": "Suis la barre bleue, qui représente $E_{pp} = mgh$. Elle est maximale en haut de la piste et nulle au point le plus bas, là où $h = 0$. Compare-la en permanence à la barre rouge de l''énergie cinétique : quand l''une monte, l''autre descend. C''est ce transfert qu''on appelle la conversion d''énergie."
}', NULL, 10),
    ('Quiz : énergie potentielle', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "L''énergie potentielle de pesanteur vaut :",
      "choix": [
        "$mgh$",
        "$\\dfrac{1}{2}mv^{2}$",
        "$\\dfrac{1}{2}k x^{2}$"
      ],
      "bonne": 0,
      "explication": "$\\frac{1}{2}kx^{2}$ est l''énergie potentielle élastique d''un ressort, pas celle de pesanteur."
    },
    {
      "question": "L''énergie potentielle de pesanteur dépend du choix :",
      "choix": [
        "de la masse seulement",
        "de l''origine des altitudes",
        "de la vitesse"
      ],
      "bonne": 1,
      "explication": "On doit toujours préciser où l''on place $h = 0$. Seules les variations d''énergie potentielle ont un sens physique."
    },
    {
      "question": "Un sac de 25 kg monté de 3 m gagne une énergie potentielle de (avec $g = 10$ N/kg) :",
      "choix": [
        "$75$ J",
        "$750$ J",
        "$7\\,500$ J"
      ],
      "bonne": 1,
      "explication": "$E_{pp} = 25 \\times 10 \\times 3 = 750$ J."
    },
    {
      "question": "L''énergie potentielle élastique d''un ressort de raideur $k$ allongé de $x$ vaut :",
      "choix": [
        "$kx$",
        "$\\dfrac{1}{2}kx^{2}$",
        "$\\dfrac{1}{2}kx$"
      ],
      "bonne": 1,
      "explication": "C''est l''aire sous la droite $F = kx$, d''où le facteur un demi et le carré."
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
  RAISE NOTICE 'L''énergie potentielle : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;

-- ---------------------------------------------------------------------------
-- L''énergie mécanique
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
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'L''énergie mécanique';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "L''énergie mécanique" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Simulation : conservation de l''énergie mécanique', 'interactif', '{
  "widget": "energie-mecanique",
  "consigne": "Choisis d''abord « sans frottement » et déplace la bille sur toute la piste : la barre violette, qui représente $E_{m} = E_{c} + E_{pp}$, ne bouge jamais. Passe ensuite en « avec frottement » : elle diminue au fil du parcours, parce qu''une partie de l''énergie part en chaleur. C''est la différence entre un système conservatif et un système non conservatif."
}', NULL, 10),
    ('Quiz : énergie mécanique', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "L''énergie mécanique d''un système vaut :",
      "choix": [
        "$E_{c} - E_{pp}$",
        "$E_{c} + E_{pp}$",
        "$E_{c} \\times E_{pp}$"
      ],
      "bonne": 1,
      "explication": "C''est la somme de l''énergie cinétique et de l''énergie potentielle."
    },
    {
      "question": "Dans un système conservatif, l''énergie mécanique :",
      "choix": [
        "augmente",
        "reste constante",
        "diminue"
      ],
      "bonne": 1,
      "explication": "Sans frottement, l''énergie passe d''une forme à l''autre mais la somme reste la même."
    },
    {
      "question": "Une bille lâchée sans vitesse d''une hauteur de 5 m arrive en bas à (avec $g = 10$ N/kg) :",
      "choix": [
        "$5$ m/s",
        "$10$ m/s",
        "$50$ m/s"
      ],
      "bonne": 1,
      "explication": "$\\frac{1}{2}v^{2} = gh$ donne $v = \\sqrt{2 \\times 10 \\times 5} = 10$ m/s, et la masse n''intervient pas."
    },
    {
      "question": "Avec frottement, l''énergie mécanique perdue se retrouve :",
      "choix": [
        "détruite",
        "transformée en chaleur",
        "transformée en masse"
      ],
      "bonne": 1,
      "explication": "L''énergie ne disparaît jamais. Les frottements la dissipent sous forme de chaleur."
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
  RAISE NOTICE 'L''énergie mécanique : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;

-- ---------------------------------------------------------------------------
-- L''énergie thermique
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
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'L''énergie thermique';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "L''énergie thermique" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Simulation : chauffer, fondre, vaporiser', 'interactif', '{
  "widget": "quantite-chaleur",
  "consigne": "Prends 0,5 kg d''eau et augmente l''énergie apportée petit à petit. Observe les deux paliers horizontaux : pendant la fusion à 0 °C et pendant la vaporisation à 100 °C, tu continues à chauffer mais la température ne monte plus. Compare enfin les quatre énergies affichées : vaporiser coûte bien plus cher que tout le reste réuni."
}', NULL, 10),
    ('Quiz : énergie thermique', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "La quantité de chaleur pour élever la température se calcule par :",
      "choix": [
        "$Q = m \\times L$",
        "$Q = m \\times c \\times \\Delta T$",
        "$Q = m \\times g \\times h$"
      ],
      "bonne": 1,
      "explication": "$Q = mL$ s''applique aux changements d''état, à température constante."
    },
    {
      "question": "Pendant la fusion de la glace, la température :",
      "choix": [
        "monte régulièrement",
        "reste à 0 °C",
        "descend"
      ],
      "bonne": 1,
      "explication": "Toute l''énergie sert à casser les liaisons du solide. C''est la chaleur latente de fusion."
    },
    {
      "question": "Chauffer 2 kg d''eau de 20 °C à 70 °C demande (avec $c = 4\\,180$ J/kg/K) :",
      "choix": [
        "$418$ kJ",
        "$4{,}18$ kJ",
        "$41{,}8$ kJ"
      ],
      "bonne": 0,
      "explication": "$Q = 2 \\times 4\\,180 \\times 50 = 418\\,000$ J, soit 418 kJ."
    },
    {
      "question": "La chaleur passe spontanément :",
      "choix": [
        "du corps froid vers le corps chaud",
        "du corps chaud vers le corps froid",
        "dans les deux sens également"
      ],
      "bonne": 1,
      "explication": "Le transfert se fait toujours du plus chaud vers le plus froid, jusqu''à l''équilibre thermique."
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
  RAISE NOTICE 'L''énergie thermique : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;
