-- ============================================================================
-- MANDAL — Physique 1ère D : etape 5 sur 5, module 4, circuits electriques
-- Ajoute les lecons, les quiz et les simulations de ce module.
-- A lancer APRES PH-1-structure.sql.
-- Idempotent : relancez-le autant de fois que vous voulez.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Générateurs, récepteurs et point de fonctionnement d''un circuit électrique
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
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'Générateurs, récepteurs et point de fonctionnement d''un circuit électrique';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "Générateurs, récepteurs et point de fonctionnement d''un circuit électrique" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Simulation : trouver le point de fonctionnement', 'interactif', '{
  "widget": "point-fonctionnement",
  "consigne": "Règle le générateur sur $E = 12$ V et $r = 1{,}5\\ \\Omega$, et le récepteur sur $E'' = 4$ V et $r'' = 2\\ \\Omega$. Le point vert, là où les deux droites se croisent, donne l''intensité et la tension réelles du circuit. Augmente maintenant la résistance interne $r$ : la droite bleue descend plus vite, le point glisse vers la gauche et la tension chute. C''est exactement ce qui arrive à une pile usée."
}', NULL, 10),
    ('Quiz : générateurs et récepteurs', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "La loi d''Ohm pour un générateur s''écrit :",
      "choix": [
        "$U = E + rI$",
        "$U = E - rI$",
        "$U = rI - E$"
      ],
      "bonne": 1,
      "explication": "La chute de tension interne $rI$ se retranche de la force électromotrice."
    },
    {
      "question": "Pour un récepteur, la loi s''écrit :",
      "choix": [
        "$U = E'' + r''I$",
        "$U = E'' - r''I$",
        "$U = r''I$"
      ],
      "bonne": 0,
      "explication": "Le récepteur consomme : il faut une tension supérieure à sa force contre-électromotrice pour le faire fonctionner."
    },
    {
      "question": "Le point de fonctionnement d''un circuit est :",
      "choix": [
        "le point d''intersection des deux caractéristiques",
        "le point le plus haut de la courbe",
        "l''origine du repère"
      ],
      "bonne": 0,
      "explication": "C''est le seul couple intensité-tension qui convient en même temps au générateur et au récepteur."
    },
    {
      "question": "Avec $E = 12$ V, $E'' = 4$ V, $r = 1$ Ω et $r'' = 3$ Ω, l''intensité vaut :",
      "choix": [
        "$2$ A",
        "$4$ A",
        "$16$ A"
      ],
      "bonne": 0,
      "explication": "$I = \\dfrac{E - E''}{r + r''} = \\dfrac{8}{4} = 2$ A."
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
  RAISE NOTICE 'Générateurs, récepteurs et point de fonctionnement d''un circuit électrique : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;

-- ---------------------------------------------------------------------------
-- Énergie et puissance électrique
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
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'Énergie et puissance électrique';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "Énergie et puissance électrique" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Simulation : du watt à la facture', 'interactif', '{
  "widget": "energie-electrique",
  "consigne": "Choisis l''ampoule à filament, 5 heures par jour, et lis le coût mensuel. Passe maintenant à l''ampoule LED : même lumière, onze fois moins de puissance, et la barre s''effondre. Essaie enfin le fer à repasser une heure par jour et compare. Tu verras pourquoi on conseille de changer d''ampoules avant tout le reste."
}', NULL, 10),
    ('Quiz : énergie et puissance électrique', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "L''énergie consommée par un appareil se calcule par :",
      "choix": [
        "$E = \\dfrac{P}{t}$",
        "$E = P \\times t$",
        "$E = P + t$"
      ],
      "bonne": 1,
      "explication": "En joules si $P$ est en watts et $t$ en secondes, en wattheures si $t$ est en heures."
    },
    {
      "question": "Un kilowattheure vaut :",
      "choix": [
        "$1\\,000$ J",
        "$3{,}6 \\times 10^{6}$ J",
        "$3\\,600$ J"
      ],
      "bonne": 1,
      "explication": "$1$ kWh $= 1\\,000 \\times 3\\,600 = 3{,}6 \\times 10^{6}$ J."
    },
    {
      "question": "Un fer à repasser de 1 000 W utilisé 2 h par jour consomme par jour :",
      "choix": [
        "$2$ kWh",
        "$2\\,000$ kWh",
        "$0{,}5$ kWh"
      ],
      "bonne": 0,
      "explication": "$1$ kW $\\times$ 2 h $= 2$ kWh. À 79 FCFA le kWh, cela fait environ 158 FCFA par jour."
    },
    {
      "question": "L''effet Joule dans un conducteur de résistance $R$ dissipe une puissance :",
      "choix": [
        "$RI$",
        "$RI^{2}$",
        "$\\dfrac{R}{I}$"
      ],
      "bonne": 1,
      "explication": "$P = RI^{2}$. C''est pourquoi on transporte l''électricité sous haute tension, pour faire baisser l''intensité."
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
  RAISE NOTICE 'Énergie et puissance électrique : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;

-- ---------------------------------------------------------------------------
-- Induction électromagnétique
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
  WHERE p.titre = 'Physique — 1ère D' AND c.titre = 'Induction électromagnétique';

  IF v_chap IS NULL THEN
    RAISE NOTICE 'Chapitre "Induction électromagnétique" introuvable — ignore.';
    RETURN;
  END IF;

  FOR r IN SELECT * FROM (VALUES
    ('Simulation : la loi de Faraday', 'simulation', 'Ouvrez la simulation PhET « La loi de Faraday ».

1. Déplacez l''aimant dans la bobine et observez l''ampoule : elle ne s''allume que pendant le mouvement. À l''arrêt, même aimant à l''intérieur, plus rien ne passe.
2. Déplacez l''aimant plus vite : la tension induite augmente. C''est la variation du flux qui compte, pas le flux lui-même.
3. Inversez le sens du mouvement : le courant change de sens.
4. Passez à la bobine à deux enroulements : la tension induite est plus grande.

À retenir : un courant n''apparaît que lorsque le flux magnétique à travers la bobine varie. C''est le principe de l''alternateur, donc de toute la production d''électricité.', 'https://phet.colorado.edu/sims/html/faradays-law/latest/faradays-law_fr.html', 15),
    ('Quiz : induction électromagnétique', 'quiz', '{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Un courant induit apparaît dans une bobine quand :",
      "choix": [
        "un aimant est posé à l''intérieur",
        "le flux magnétique à travers la bobine varie",
        "la bobine est chaude"
      ],
      "bonne": 1,
      "explication": "C''est la variation du flux qui crée la tension induite. Un aimant immobile ne produit aucun courant."
    },
    {
      "question": "La loi de Lenz dit que le courant induit :",
      "choix": [
        "s''oppose à la cause qui lui donne naissance",
        "amplifie la cause",
        "est toujours nul"
      ],
      "bonne": 0,
      "explication": "C''est une conséquence de la conservation de l''énergie : sinon on obtiendrait un mouvement perpétuel."
    },
    {
      "question": "Dans un alternateur, on produit du courant en :",
      "choix": [
        "chauffant un fil",
        "faisant tourner une bobine dans un champ magnétique",
        "frottant deux aimants"
      ],
      "bonne": 1,
      "explication": "La rotation fait varier le flux à travers la bobine, ce qui crée une tension alternative."
    },
    {
      "question": "La tension induite est d''autant plus grande que :",
      "choix": [
        "la variation du flux est rapide",
        "l''aimant est lourd",
        "la bobine est courte"
      ],
      "bonne": 0,
      "explication": "$e = -\\dfrac{\\mathrm{d}\\Phi}{\\mathrm{d}t}$ : plus la variation est rapide, plus la tension est élevée."
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
  RAISE NOTICE 'Induction électromagnétique : % lecon(s) ajoutee(s).', v_ajout;
END $ph$;
