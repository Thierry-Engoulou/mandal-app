-- ============================================================================
-- MANDAL — Mathématiques 3ème : densification des simulations (chapitres 9 a 12)
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
-- Chapitre 9 : 2 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 9;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 9 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation PhET : la tour de trigo', 'Simulation : calculer un côté avec la trigonométrie');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 9 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation PhET : la tour de trigo', 15, 'simulation', 'Cosinus, sinus et tangente vus sur un cercle. Tu retrouveras cette simulation en classe de seconde, elle prépare la suite.', 'https://phet.colorado.edu/sims/html/trig-tour/latest/trig-tour_fr.html', 15),
    (v_chapitre_id, 'Simulation : calculer un côté avec la trigonométrie', 35, 'interactif', '{
  "widget": "trigo-rectangle",
  "consigne": "Choisis l''angle, lis son cosinus, puis retrouve la longueur du côté adjacent. Vérifie ensuite ton résultat avec le théorème de Pythagore : les deux méthodes doivent donner la même valeur."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 9 : 2 simulation(s) ajoutee(s).';
END $m3s$;

-- ----------------------------------------------------------------------------
-- Chapitre 10 : 1 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 10;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 10 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : angle inscrit et angle au centre');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 10 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : angle inscrit et angle au centre', 15, 'interactif', '{
  "widget": "angles-inscrits",
  "consigne": "Repère l''angle au centre et l''angle inscrit qui interceptent le même arc. Le premier vaut toujours le double du second, quelle que soit la position du point sur le cercle."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 10 : 1 simulation(s) ajoutee(s).';
END $m3s$;

-- ----------------------------------------------------------------------------
-- Chapitre 11 : 1 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 11;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 11 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : reconnaître un polygone régulier');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 11 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : reconnaître un polygone régulier', 15, 'interactif', '{
  "widget": "polygones-reguliers",
  "consigne": "Fais varier le nombre de côtés de 3 à 12. Tous les côtés restent égaux et tous les angles aussi : c''est exactement la définition. Regarde aussi l''angle au centre diminuer quand le nombre de côtés augmente."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 11 : 1 simulation(s) ajoutee(s).';
END $m3s$;

-- ----------------------------------------------------------------------------
-- Chapitre 12 : 2 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 12;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 12 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : multiplier un vecteur par un réel', 'Simulation PhET : addition de vecteurs');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 12 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : multiplier un vecteur par un réel', 15, 'interactif', '{
  "widget": "vecteurs",
  "consigne": "Allonge un vecteur, raccourcis-le, puis retourne-le avec un nombre négatif. Sa direction ne change jamais : seuls son sens et sa longueur bougent."
}', NULL, 10),
    (v_chapitre_id, 'Simulation PhET : addition de vecteurs', 25, 'simulation', 'Place deux vecteurs bout à bout et lis la somme. La simulation affiche les composantes, ce qui prépare le chapitre suivant sur les coordonnées.', 'https://phet.colorado.edu/sims/html/vector-addition/latest/vector-addition_fr.html', 15);

  RAISE NOTICE 'Chapitre 12 : 2 simulation(s) ajoutee(s).';
END $m3s$;
