-- ============================================================================
-- MANDAL — Mathématiques 1ère C : densification des simulations (chapitres 18 a 21)
--
-- Ce script ajoute des lecons de simulation apres les lecons de cours qui
-- n'en avaient pas encore. Il ne modifie ni ne supprime aucune lecon existante.
--
-- Autonome : lancez-le seul, dans n'importe quel ordre.
-- Idempotent : relancez-le autant de fois que vous voulez, rien ne sera
-- duplique.
-- Prerequis : les scripts seed-maths1c-chXX.sql doivent avoir ete lances.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Chapitre 18 : 3 simulation(s) ajoutee(s).
-- ----------------------------------------------------------------------------
DO $p1cs$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_deja int;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 1ère C';
  IF v_programme_id IS NULL THEN
    RAISE EXCEPTION 'Programme "Mathématiques — 1ère C" introuvable : lancez d''abord les scripts seed-maths1c-chXX.sql.';
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 18;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 18 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : lire et remplir une matrice', 'Simulation : le produit n''est pas commutatif', 'Simulation : une application linéaire et sa matrice');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 18 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : lire et remplir une matrice', 15, 'interactif', '{
  "widget": "matrice-operations",
  "consigne": "Chaque coefficient porte deux indices : d''abord la ligne, ensuite la colonne. Passe sur l''onglet du déterminant et cherche une matrice dont le déterminant est nul."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : le produit n''est pas commutatif', 25, 'interactif', '{
  "widget": "matrice-operations",
  "consigne": "Calcule A × B, puis refais le calcul dans l''autre sens sur ton cahier. Les deux résultats diffèrent presque toujours : c''est la grande différence avec la multiplication des nombres."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : une application linéaire et sa matrice', 35, 'interactif', '{
  "widget": "application-lineaire",
  "consigne": "Les deux flèches vertes sont les images des vecteurs de base, et ce sont exactement les colonnes de la matrice. Annule le déterminant : toutes les images s''écrasent sur une seule droite."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 18 : 3 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 19 : 2 simulation(s) ajoutee(s).
-- ----------------------------------------------------------------------------
DO $p1cs$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_deja int;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 1ère C';
  IF v_programme_id IS NULL THEN
    RAISE EXCEPTION 'Programme "Mathématiques — 1ère C" introuvable : lancez d''abord les scripts seed-maths1c-chXX.sql.';
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 19;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 19 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : l''orthogonalité sur un cube', 'Simulation : distance d''un point à un plan');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 19 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : l''orthogonalité sur un cube', 15, 'interactif', '{
  "widget": "cube-orthogonalite",
  "consigne": "Deux droites de l''espace peuvent être orthogonales sans se couper : c''est la grande différence avec le plan. Cherche un exemple sur le cube."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : distance d''un point à un plan', 55, 'interactif', '{
  "widget": "projete-orthogonal",
  "consigne": "Le segment [MH] est perpendiculaire au plan, et sa longueur est la plus courte distance de M au plan. Aucun autre point du plan n''est plus proche de M."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 19 : 2 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 20 : 3 simulation(s) ajoutee(s).
-- ----------------------------------------------------------------------------
DO $p1cs$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_deja int;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 1ère C';
  IF v_programme_id IS NULL THEN
    RAISE EXCEPTION 'Programme "Mathématiques — 1ère C" introuvable : lancez d''abord les scripts seed-maths1c-chXX.sql.';
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 20;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 20 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : la droite de l''espace en paramétrique', 'Simulation : l''équation cartésienne d''un plan', 'Simulation : projeter sur une droite ou sur un plan');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 20 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : la droite de l''espace en paramétrique', 35, 'interactif', '{
  "widget": "droite-parametrique",
  "consigne": "Fais varier t : le point balaie toute la droite. Change ensuite le vecteur directeur en le multipliant par 2 : la droite ne bouge pas, seul le pas de parcours change."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : l''équation cartésienne d''un plan', 45, 'interactif', '{
  "widget": "plan-equation",
  "consigne": "Les trois premiers coefficients donnent directement un vecteur normal. Déplace M et regarde la valeur de l''équation : elle s''annule exactement quand M appartient au plan."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : projeter sur une droite ou sur un plan', 55, 'interactif', '{
  "widget": "projete-orthogonal",
  "consigne": "Compare les deux projections. Sur le plan z = 0, il suffit d''effacer la troisième coordonnée ; sur une droite, il faut passer par le produit scalaire."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 20 : 3 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 21 : 1 simulation(s) ajoutee(s).
-- ----------------------------------------------------------------------------
DO $p1cs$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_deja int;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 1ère C';
  IF v_programme_id IS NULL THEN
    RAISE EXCEPTION 'Programme "Mathématiques — 1ère C" introuvable : lancez d''abord les scripts seed-maths1c-chXX.sql.';
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 21;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 21 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : couper une sphère par un plan');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 21 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : couper une sphère par un plan', 15, 'interactif', '{
  "widget": "sphere-section",
  "consigne": "Fais glisser le plan de coupe. La section est un cercle dont le rayon diminue, puis le plan devient tangent, et enfin il ne coupe plus rien. Retrouve ces trois cas avec la distance du centre au plan."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 21 : 1 simulation(s) ajoutee(s).';
END $p1cs$;
