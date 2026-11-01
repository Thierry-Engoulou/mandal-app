-- ============================================================================
-- MANDAL — Mathématiques 1ère C : densification des simulations (chapitres 12 a 17)
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
-- Chapitre 12 : 2 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 12;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 12 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : chaînes, cycles et connexité', 'Simulation : parcourir toutes les routes une seule fois');

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
    (v_chapitre_id, 'Simulation : chaînes, cycles et connexité', 45, 'interactif', '{
  "widget": "graphe-chaines",
  "consigne": "Enlève une route et regarde une ville se détacher du reste : le graphe n''est plus connexe. Le nombre dans chaque cercle est le degré du sommet."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : parcourir toutes les routes une seule fois', 55, 'interactif', '{
  "widget": "graphe-chaines",
  "consigne": "Arrange les routes pour que tous les degrés soient pairs : il existe alors un circuit qui emprunte chaque route une fois et revient au départ. Avec exactement deux degrés impairs, le parcours existe aussi, mais il ne revient pas au point de départ."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 12 : 2 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 14 : 2 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 14;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 14 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : le barycentre de deux points', 'Simulation : les lignes de niveau');

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
    (v_chapitre_id, 'Simulation : le barycentre de deux points', 15, 'interactif', '{
  "widget": "barycentre",
  "consigne": "Mets le poids du troisième point à zéro pour ne garder que deux points pondérés. Le barycentre reste toujours sur le segment tant que les deux poids sont de même signe."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : les lignes de niveau', 45, 'interactif', '{
  "widget": "lignes-niveau",
  "consigne": "Trois familles à comparer. Celle du rapport réserve une surprise : quand le rapport vaut exactement 1, le cercle devient une droite, la médiatrice de [AB]."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 14 : 2 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 15 : 1 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 15;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 15 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : cocyclicité');

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
    (v_chapitre_id, 'Simulation : cocyclicité', 35, 'interactif', '{
  "widget": "cocyclicite",
  "consigne": "Éloigne D du cercle : l''angle en D change. Ramène-le dessus : les deux angles redeviennent égaux. C''est le critère de cocyclicité, et c''est ainsi qu''on démontre que quatre points sont sur un même cercle."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 15 : 1 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 16 : 3 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 16;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 16 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : trois transformations à comparer', 'Simulation : la symétrie orthogonale', 'Simulation : les expressions analytiques');

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
    (v_chapitre_id, 'Simulation : trois transformations à comparer', 15, 'interactif', '{
  "widget": "transformations",
  "consigne": "Translation, rotation, homothétie : observe à chaque fois ce qui est conservé. Les longueurs, les angles, l''orientation — toutes ne le sont pas."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : la symétrie orthogonale', 25, 'interactif', '{
  "widget": "symetrie-orthogonale",
  "consigne": "Le milieu de [MM''] est toujours sur l''axe, et le segment lui est perpendiculaire. Remarque aussi que le triangle image est retourné : une symétrie change l''orientation."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : les expressions analytiques', 55, 'interactif', '{
  "widget": "transformation-analytique",
  "consigne": "La même transformation, vue sur la figure et lue sur les coordonnées. La translation ajoute une constante, l''homothétie multiplie, la rotation fait intervenir le cosinus et le sinus."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 16 : 3 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 17 : 1 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 17;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 17 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : famille libre ou famille liée');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 17 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : famille libre ou famille liée', 15, 'interactif', '{
  "widget": "espace-vectoriel",
  "consigne": "Deux vecteurs du plan sont liés exactement quand ils sont colinéaires. Place-les l''un sur l''autre et regarde le parallélogramme s''aplatir : la famille ne peut plus engendrer tout le plan."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 17 : 1 simulation(s) ajoutee(s).';
END $p1cs$;
