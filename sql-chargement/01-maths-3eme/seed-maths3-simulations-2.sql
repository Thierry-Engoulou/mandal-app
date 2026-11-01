-- ============================================================================
-- MANDAL — Mathématiques 3ème : densification des simulations (chapitres 5 a 8)
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
-- Chapitre 5 : 4 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 5;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 5 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : une équation à deux inconnues, c''est une droite', 'Simulation : vérifier la solution d''un système', 'Simulation PhET : explorateur d''équations à deux variables', 'Simulation : les trois cas possibles');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 5 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : une équation à deux inconnues, c''est une droite', 15, 'interactif', '{
  "widget": "droite-deux-points",
  "consigne": "Règle la seconde droite sur y = −2x + 7. Tu viens de dessiner l''ensemble des couples solutions de 2x + y = 7 : ils sont en nombre infini et tous alignés."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : vérifier la solution d''un système', 35, 'interactif', '{
  "widget": "systeme-equations",
  "consigne": "Résous d''abord le système par substitution sur ton cahier, puis vérifie ici que le point d''intersection a bien les coordonnées que tu as trouvées."
}', NULL, 10),
    (v_chapitre_id, 'Simulation PhET : explorateur d''équations à deux variables', 37, 'simulation', 'Deux inconnues sur la même balance. Manipule-les pour sentir ce que veut dire « un couple solution ».', 'https://phet.colorado.edu/sims/html/equality-explorer-two-variables/latest/equality-explorer-two-variables_fr.html', 15),
    (v_chapitre_id, 'Simulation : les trois cas possibles', 65, 'interactif', '{
  "widget": "systeme-equations",
  "consigne": "Fais apparaître tour à tour les trois situations : deux droites sécantes (une seule solution), parallèles (aucune solution), confondues (une infinité de solutions)."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 5 : 4 simulation(s) ajoutee(s).';
END $m3s$;

-- ----------------------------------------------------------------------------
-- Chapitre 6 : 3 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 6;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 6 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : une application linéaire, c''est une affine avec b = 0', 'Simulation PhET : représenter à partir de l''équation réduite', 'Simulation : le forfait téléphonique');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 6 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : une application linéaire, c''est une affine avec b = 0', 15, 'interactif', '{
  "widget": "application-affine",
  "consigne": "Mets b à zéro : la droite passe par l''origine du repère. C''est la signature d''une application linéaire, et c''est le seul cas où l''image de 0 est 0."
}', NULL, 10),
    (v_chapitre_id, 'Simulation PhET : représenter à partir de l''équation réduite', 25, 'simulation', 'Change a et b dans l''équation y = ax + b et regarde la droite bouger. Essaie ensuite le jeu de la simulation pour t''entraîner.', 'https://phet.colorado.edu/sims/html/graphing-slope-intercept/latest/graphing-slope-intercept_fr.html', 15),
    (v_chapitre_id, 'Simulation : le forfait téléphonique', 45, 'interactif', '{
  "widget": "affine-morceaux",
  "consigne": "Avant le seuil, le prix ne bouge pas : la partie est constante. Après, chaque gigaoctet s''ajoute. Règle ton propre forfait et calcule ce que tu paierais pour 45 Go."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 6 : 3 simulation(s) ajoutee(s).';
END $m3s$;

-- ----------------------------------------------------------------------------
-- Chapitre 7 : 3 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 7;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 7 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : construire sa série et la regrouper', 'Simulation : trois diagrammes pour une même série', 'Simulation PhET : centre et variabilité');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 7 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : construire sa série et la regrouper', 15, 'interactif', '{
  "widget": "statistiques",
  "consigne": "Change les effectifs classe par classe et regarde la moyenne se déplacer. Une seule valeur très éloignée suffit à la tirer : c''est sa faiblesse."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : trois diagrammes pour une même série', 45, 'interactif', '{
  "widget": "diagrammes-stats",
  "consigne": "Passe des bâtons à l''histogramme, puis au diagramme circulaire. Vérifie que la somme des quatre angles fait bien 360°, et retiens pourquoi les barres se touchent dans un histogramme et pas dans un diagramme en bâtons."
}', NULL, 10),
    (v_chapitre_id, 'Simulation PhET : centre et variabilité', 47, 'simulation', 'Moyenne, médiane et étendue sur une série que tu construis toi-même. Déplace un point très loin des autres et regarde laquelle des deux mesures bouge le plus.', 'https://phet.colorado.edu/sims/html/center-and-variability/latest/center-and-variability_fr.html', 15);

  RAISE NOTICE 'Chapitre 7 : 3 simulation(s) ajoutee(s).';
END $m3s$;

-- ----------------------------------------------------------------------------
-- Chapitre 8 : 2 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 8;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 8 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation PhET : l''aire de jeu proportionnelle', 'Simulation : la réciproque de Thalès');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 8 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation PhET : l''aire de jeu proportionnelle', 15, 'simulation', 'Pour sentir ce qu''est une proportion avant d''aborder Thalès : deux quantités qui gardent le même rapport quand on les agrandit.', 'https://phet.colorado.edu/sims/html/proportion-playground/latest/proportion-playground_fr.html', 15),
    (v_chapitre_id, 'Simulation : la réciproque de Thalès', 45, 'interactif', '{
  "widget": "thales",
  "consigne": "Avec la réciproque, l''ordre est imposé : on vérifie d''abord que les rapports sont égaux, et seulement ensuite on conclut que les droites sont parallèles. Déplace la parallèle pour voir les rapports rester égaux."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 8 : 2 simulation(s) ajoutee(s).';
END $m3s$;
