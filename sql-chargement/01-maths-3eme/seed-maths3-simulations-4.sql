-- ============================================================================
-- MANDAL — Mathématiques 3ème : densification des simulations (chapitres 13 a 16)
--
-- Ce script ajoute des lecons de simulation apres les lecons de cours qui
-- n'en avaient pas encore. Il ne modifie ni ne supprime aucune lecon existante.
--
-- Autonome : lancez-le seul, dans n'importe quel ordre.
-- Idempotent : relance-le autant de fois que vous voulez, rien ne sera
-- duplique.
-- Prerequis : les scripts seed-maths3-chXX.sql doivent avoir ete lances.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Chapitre 13 : 3 simulation(s) ajoutee(s).
-- ----------------------------------------------------------------------------
DO $m3s$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_deja int;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';
  IF v_programme_id IS NULL THEN
    RAISE EXCEPTION 'Programme "Mathématiques — 3ème" introuvable : lancez d''abord les scripts seed-maths3-chXX.sql.';
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 13;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 13 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : lire les coordonnées d''un vecteur', 'Simulation : la colinéarité par le déterminant', 'Simulation : reconnaître deux vecteurs orthogonaux');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 13 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : lire les coordonnées d''un vecteur', 15, 'interactif', '{
  "widget": "coordonnees-vecteur",
  "consigne": "Déplace A et B, puis lis les coordonnées de AB sur les pointillés : abscisse de l''arrivée moins abscisse du départ, et pareil pour les ordonnées. L''ordre compte, ne l''inverse pas."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : la colinéarité par le déterminant', 25, 'interactif', '{
  "widget": "coordonnees-vecteur",
  "consigne": "Déplace C jusqu''à ce que le déterminant s''annule. Les vecteurs AB et AC sont alors colinéaires, donc les trois points A, B et C sont alignés."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : reconnaître deux vecteurs orthogonaux', 35, 'interactif', '{
  "widget": "coordonnees-vecteur",
  "consigne": "Cherche maintenant à annuler le produit scalaire au lieu du déterminant : l''angle en A devient droit. Déterminant nul et produit scalaire nul, ce sont deux tests différents, pour deux propriétés différentes."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 13 : 3 simulation(s) ajoutee(s).';
END $m3s$;

-- ----------------------------------------------------------------------------
-- Chapitre 14 : 1 simulation(s) ajoutee(s).
-- ----------------------------------------------------------------------------
DO $m3s$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_deja int;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';
  IF v_programme_id IS NULL THEN
    RAISE EXCEPTION 'Programme "Mathématiques — 3ème" introuvable : lancez d''abord les scripts seed-maths3-chXX.sql.';
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 14;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 14 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : centre et rapport d''une homothétie');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 14 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : centre et rapport d''une homothétie', 15, 'interactif', '{
  "widget": "transformations",
  "consigne": "Choisis l''homothétie, puis fais varier le rapport. Un rapport supérieur à 1 agrandit, un rapport entre 0 et 1 réduit, un rapport négatif retourne la figure de l''autre côté du centre."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 14 : 1 simulation(s) ajoutee(s).';
END $m3s$;

-- ----------------------------------------------------------------------------
-- Chapitre 15 : 3 simulation(s) ajoutee(s).
-- ----------------------------------------------------------------------------
DO $m3s$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_deja int;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';
  IF v_programme_id IS NULL THEN
    RAISE EXCEPTION 'Programme "Mathématiques — 3ème" introuvable : lancez d''abord les scripts seed-maths3-chXX.sql.';
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 15;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 15 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : la droite qui passe par deux points', 'Simulation PhET : le traceur de droites', 'Simulation : parallèles, sécantes ou confondues ?');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 15 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : la droite qui passe par deux points', 15, 'interactif', '{
  "widget": "droite-deux-points",
  "consigne": "Place A et B, lis le coefficient directeur, puis vérifie l''équation obtenue. Mets-les ensuite sur la même abscisse : la droite devient verticale et n''a plus de coefficient directeur."
}', NULL, 10),
    (v_chapitre_id, 'Simulation PhET : le traceur de droites', 25, 'simulation', 'Pente et ordonnée à l''origine, à régler directement sur le graphique. L''onglet « Pente » montre bien le rapport entre le déplacement vertical et le déplacement horizontal.', 'https://phet.colorado.edu/sims/html/graphing-lines/latest/graphing-lines_fr.html', 15),
    (v_chapitre_id, 'Simulation : parallèles, sécantes ou confondues ?', 55, 'interactif', '{
  "widget": "droite-deux-points",
  "consigne": "Règle la seconde droite pour obtenir successivement les trois positions relatives. Même coefficient directeur et même ordonnée à l''origine : les droites sont confondues."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 15 : 3 simulation(s) ajoutee(s).';
END $m3s$;

-- ----------------------------------------------------------------------------
-- Chapitre 16 : 1 simulation(s) ajoutee(s).
-- ----------------------------------------------------------------------------
DO $m3s$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_deja int;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';
  IF v_programme_id IS NULL THEN
    RAISE EXCEPTION 'Programme "Mathématiques — 3ème" introuvable : lancez d''abord les scripts seed-maths3-chXX.sql.';
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 16;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 16 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : les rapports k, k² et k³');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 16 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : les rapports k, k² et k³', 15, 'interactif', '{
  "widget": "section-pyramide",
  "consigne": "Fais glisser le plan de coupe et observe les trois rapports : k pour les longueurs, k² pour les aires, k³ pour les volumes. C''est la raison pour laquelle un volume diminue beaucoup plus vite qu''une longueur."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 16 : 1 simulation(s) ajoutee(s).';
END $m3s$;
