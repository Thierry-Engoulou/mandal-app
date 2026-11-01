-- ---------------------------------------------------------------------------
-- M'Andal — Mathématiques 3ème : filet de sécurité pour les simulations
--
-- Les scripts seed-maths3-simulations-1 à 4 jugent le chapitre dans son
-- ensemble : dès qu'une seule de leurs simulations s'y trouve déjà, ils
-- s'arrêtent et laissent les autres de côté. Si un chargement s'est arrêté en
-- route, des simulations peuvent donc rester en rade sans que rien ne le dise.
--
-- Ce fichier-ci regarde les leçons une par une. Il pose celles qui manquent,
-- laisse tranquilles celles qui sont là, et ne touche à rien d'autre.
-- Relancez-le autant de fois que vous voulez : il vous dira chapitre par
-- chapitre ce qu'il a trouvé.
--
-- Partie 2 sur 2 : chapitres 9 à 16.
-- ---------------------------------------------------------------------------

-- Chapitre 9
DO $m3c$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_max int;
  v_n int;
  v_ajout int := 0;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';
  IF v_programme_id IS NULL THEN
    RAISE NOTICE 'Chapitre 9 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 9;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 9 : introuvable, je passe.';
    RETURN;
  END IF;

  -- Si les leçons se suivent encore de un en un, j'écarte leurs numéros d'ordre
  -- pour faire de la place aux simulations. Le détour par le négatif évite les
  -- collisions pendant l'opération. Le contenu des leçons n'est pas touché.
  SELECT max(ordre) INTO v_max FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_max IS NOT NULL AND v_max < 10 THEN
    UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
    UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;
  END IF;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation PhET : la tour de trigo', 15, 'simulation', 'Cosinus, sinus et tangente vus sur un cercle. Tu retrouveras cette simulation en classe de seconde, elle prépare la suite.', 'https://phet.colorado.edu/sims/html/trig-tour/latest/trig-tour_fr.html', 15
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation PhET : la tour de trigo'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : calculer un côté avec la trigonométrie', 35, 'interactif', '{
  "widget": "trigo-rectangle",
  "consigne": "Choisis l''angle, lis son cosinus, puis retrouve la longueur du côté adjacent. Vérifie ensuite ton résultat avec le théorème de Pythagore : les deux méthodes doivent donner la même valeur."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : calculer un côté avec la trigonométrie'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 9 : rien à ajouter, les 2 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 9 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;


-- Chapitre 10
DO $m3c$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_max int;
  v_n int;
  v_ajout int := 0;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';
  IF v_programme_id IS NULL THEN
    RAISE NOTICE 'Chapitre 10 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 10;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 10 : introuvable, je passe.';
    RETURN;
  END IF;

  -- Si les leçons se suivent encore de un en un, j'écarte leurs numéros d'ordre
  -- pour faire de la place aux simulations. Le détour par le négatif évite les
  -- collisions pendant l'opération. Le contenu des leçons n'est pas touché.
  SELECT max(ordre) INTO v_max FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_max IS NOT NULL AND v_max < 10 THEN
    UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
    UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;
  END IF;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : angle inscrit et angle au centre', 15, 'interactif', '{
  "widget": "angles-inscrits",
  "consigne": "Repère l''angle au centre et l''angle inscrit qui interceptent le même arc. Le premier vaut toujours le double du second, quelle que soit la position du point sur le cercle."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : angle inscrit et angle au centre'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 10 : rien à ajouter, les 1 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 10 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;


-- Chapitre 11
DO $m3c$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_max int;
  v_n int;
  v_ajout int := 0;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';
  IF v_programme_id IS NULL THEN
    RAISE NOTICE 'Chapitre 11 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 11;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 11 : introuvable, je passe.';
    RETURN;
  END IF;

  -- Si les leçons se suivent encore de un en un, j'écarte leurs numéros d'ordre
  -- pour faire de la place aux simulations. Le détour par le négatif évite les
  -- collisions pendant l'opération. Le contenu des leçons n'est pas touché.
  SELECT max(ordre) INTO v_max FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_max IS NOT NULL AND v_max < 10 THEN
    UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
    UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;
  END IF;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : reconnaître un polygone régulier', 15, 'interactif', '{
  "widget": "polygones-reguliers",
  "consigne": "Fais varier le nombre de côtés de 3 à 12. Tous les côtés restent égaux et tous les angles aussi : c''est exactement la définition. Regarde aussi l''angle au centre diminuer quand le nombre de côtés augmente."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : reconnaître un polygone régulier'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 11 : rien à ajouter, les 1 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 11 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;


-- Chapitre 12
DO $m3c$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_max int;
  v_n int;
  v_ajout int := 0;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';
  IF v_programme_id IS NULL THEN
    RAISE NOTICE 'Chapitre 12 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 12;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 12 : introuvable, je passe.';
    RETURN;
  END IF;

  -- Si les leçons se suivent encore de un en un, j'écarte leurs numéros d'ordre
  -- pour faire de la place aux simulations. Le détour par le négatif évite les
  -- collisions pendant l'opération. Le contenu des leçons n'est pas touché.
  SELECT max(ordre) INTO v_max FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_max IS NOT NULL AND v_max < 10 THEN
    UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
    UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;
  END IF;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : multiplier un vecteur par un réel', 15, 'interactif', '{
  "widget": "vecteurs",
  "consigne": "Allonge un vecteur, raccourcis-le, puis retourne-le avec un nombre négatif. Sa direction ne change jamais : seuls son sens et sa longueur bougent."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : multiplier un vecteur par un réel'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation PhET : addition de vecteurs', 25, 'simulation', 'Place deux vecteurs bout à bout et lis la somme. La simulation affiche les composantes, ce qui prépare le chapitre suivant sur les coordonnées.', 'https://phet.colorado.edu/sims/html/vector-addition/latest/vector-addition_fr.html', 15
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation PhET : addition de vecteurs'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 12 : rien à ajouter, les 2 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 12 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;


-- Chapitre 13
DO $m3c$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_max int;
  v_n int;
  v_ajout int := 0;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';
  IF v_programme_id IS NULL THEN
    RAISE NOTICE 'Chapitre 13 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 13;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 13 : introuvable, je passe.';
    RETURN;
  END IF;

  -- Si les leçons se suivent encore de un en un, j'écarte leurs numéros d'ordre
  -- pour faire de la place aux simulations. Le détour par le négatif évite les
  -- collisions pendant l'opération. Le contenu des leçons n'est pas touché.
  SELECT max(ordre) INTO v_max FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_max IS NOT NULL AND v_max < 10 THEN
    UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
    UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;
  END IF;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : lire les coordonnées d''un vecteur', 15, 'interactif', '{
  "widget": "coordonnees-vecteur",
  "consigne": "Déplace A et B, puis lis les coordonnées de AB sur les pointillés : abscisse de l''arrivée moins abscisse du départ, et pareil pour les ordonnées. L''ordre compte, ne l''inverse pas."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : lire les coordonnées d''un vecteur'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : la colinéarité par le déterminant', 25, 'interactif', '{
  "widget": "coordonnees-vecteur",
  "consigne": "Déplace C jusqu''à ce que le déterminant s''annule. Les vecteurs AB et AC sont alors colinéaires, donc les trois points A, B et C sont alignés."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : la colinéarité par le déterminant'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : reconnaître deux vecteurs orthogonaux', 35, 'interactif', '{
  "widget": "coordonnees-vecteur",
  "consigne": "Cherche maintenant à annuler le produit scalaire au lieu du déterminant : l''angle en A devient droit. Déterminant nul et produit scalaire nul, ce sont deux tests différents, pour deux propriétés différentes."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : reconnaître deux vecteurs orthogonaux'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 13 : rien à ajouter, les 3 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 13 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;


-- Chapitre 14
DO $m3c$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_max int;
  v_n int;
  v_ajout int := 0;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';
  IF v_programme_id IS NULL THEN
    RAISE NOTICE 'Chapitre 14 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 14;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 14 : introuvable, je passe.';
    RETURN;
  END IF;

  -- Si les leçons se suivent encore de un en un, j'écarte leurs numéros d'ordre
  -- pour faire de la place aux simulations. Le détour par le négatif évite les
  -- collisions pendant l'opération. Le contenu des leçons n'est pas touché.
  SELECT max(ordre) INTO v_max FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_max IS NOT NULL AND v_max < 10 THEN
    UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
    UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;
  END IF;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : centre et rapport d''une homothétie', 15, 'interactif', '{
  "widget": "transformations",
  "consigne": "Choisis l''homothétie, puis fais varier le rapport. Un rapport supérieur à 1 agrandit, un rapport entre 0 et 1 réduit, un rapport négatif retourne la figure de l''autre côté du centre."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : centre et rapport d''une homothétie'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 14 : rien à ajouter, les 1 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 14 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;


-- Chapitre 15
DO $m3c$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_max int;
  v_n int;
  v_ajout int := 0;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';
  IF v_programme_id IS NULL THEN
    RAISE NOTICE 'Chapitre 15 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 15;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 15 : introuvable, je passe.';
    RETURN;
  END IF;

  -- Si les leçons se suivent encore de un en un, j'écarte leurs numéros d'ordre
  -- pour faire de la place aux simulations. Le détour par le négatif évite les
  -- collisions pendant l'opération. Le contenu des leçons n'est pas touché.
  SELECT max(ordre) INTO v_max FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_max IS NOT NULL AND v_max < 10 THEN
    UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
    UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;
  END IF;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : la droite qui passe par deux points', 15, 'interactif', '{
  "widget": "droite-deux-points",
  "consigne": "Place A et B, lis le coefficient directeur, puis vérifie l''équation obtenue. Mets-les ensuite sur la même abscisse : la droite devient verticale et n''a plus de coefficient directeur."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : la droite qui passe par deux points'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation PhET : le traceur de droites', 25, 'simulation', 'Pente et ordonnée à l''origine, à régler directement sur le graphique. L''onglet « Pente » montre bien le rapport entre le déplacement vertical et le déplacement horizontal.', 'https://phet.colorado.edu/sims/html/graphing-lines/latest/graphing-lines_fr.html', 15
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation PhET : le traceur de droites'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : parallèles, sécantes ou confondues ?', 55, 'interactif', '{
  "widget": "droite-deux-points",
  "consigne": "Règle la seconde droite pour obtenir successivement les trois positions relatives. Même coefficient directeur et même ordonnée à l''origine : les droites sont confondues."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : parallèles, sécantes ou confondues ?'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 15 : rien à ajouter, les 3 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 15 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;


-- Chapitre 16
DO $m3c$
DECLARE
  v_programme_id uuid;
  v_chapitre_id uuid;
  v_max int;
  v_n int;
  v_ajout int := 0;
BEGIN
  SELECT p.id INTO v_programme_id FROM public.programmes p
  WHERE p.titre = 'Mathématiques — 3ème';
  IF v_programme_id IS NULL THEN
    RAISE NOTICE 'Chapitre 16 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 16;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 16 : introuvable, je passe.';
    RETURN;
  END IF;

  -- Si les leçons se suivent encore de un en un, j'écarte leurs numéros d'ordre
  -- pour faire de la place aux simulations. Le détour par le négatif évite les
  -- collisions pendant l'opération. Le contenu des leçons n'est pas touché.
  SELECT max(ordre) INTO v_max FROM public.concepts WHERE chapitre_id = v_chapitre_id;
  IF v_max IS NOT NULL AND v_max < 10 THEN
    UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
    UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;
  END IF;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : les rapports k, k² et k³', 15, 'interactif', '{
  "widget": "section-pyramide",
  "consigne": "Fais glisser le plan de coupe et observe les trois rapports : k pour les longueurs, k² pour les aires, k³ pour les volumes. C''est la raison pour laquelle un volume diminue beaucoup plus vite qu''une longueur."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : les rapports k, k² et k³'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 16 : rien à ajouter, les 1 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 16 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;

