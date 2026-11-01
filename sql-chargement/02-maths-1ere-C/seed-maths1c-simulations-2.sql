-- ============================================================================
-- MANDAL — Mathématiques 1ère C : densification des simulations (chapitres 6 a 11)
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
-- Chapitre 6 : 1 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 6;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 6 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : une limite infinie');

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
    (v_chapitre_id, 'Simulation : une limite infinie', 15, 'interactif', '{
  "widget": "limites-asymptotes",
  "consigne": "Approche la valeur interdite par la gauche, puis par la droite. Les deux limites ne sont pas toujours les mêmes, et c''est pour cela qu''on les écrit séparément."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 6 : 1 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 7 : 3 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 7;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 7 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : la fonction dérivée à côté de sa courbe', 'Simulation : signe de la dérivée et sens de variation', 'Simulation PhET : le traceur de graphiques de calcul');

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
    (v_chapitre_id, 'Simulation : la fonction dérivée à côté de sa courbe', 35, 'interactif', '{
  "widget": "fonction-derivee",
  "consigne": "Déplace le point : la pente de la tangente orange devient l''ordonnée du point violet. Vérifie les quatre formules du cours, en particulier celle de la racine carrée, dont la dérivée explose près de zéro."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : signe de la dérivée et sens de variation', 45, 'interactif', '{
  "widget": "variations-derivee",
  "consigne": "Les zones vertes sont celles où la dérivée est positive, et où la fonction croît. Les points orange, là où la dérivée s''annule en changeant de signe, sont les extremums. Annule le discriminant et regarde les extremums disparaître."
}', NULL, 10),
    (v_chapitre_id, 'Simulation PhET : le traceur de graphiques de calcul', 47, 'simulation', 'Dessine une fonction à la main et regarde sa dérivée se tracer en dessous. C''est le meilleur moyen de sentir le lien entre les deux courbes.', 'https://phet.colorado.edu/sims/html/calculus-grapher/latest/calculus-grapher_fr.html', 15);

  RAISE NOTICE 'Chapitre 7 : 3 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 8 : 2 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 8;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 8 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : les asymptotes parallèles aux axes', 'Simulation : l''asymptote oblique');

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
    (v_chapitre_id, 'Simulation : les asymptotes parallèles aux axes', 15, 'interactif', '{
  "widget": "limites-asymptotes",
  "consigne": "Une asymptote verticale vient d''une valeur interdite, une asymptote horizontale d''une limite finie à l''infini. Repère les deux sur la même courbe."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : l''asymptote oblique', 25, 'interactif', '{
  "widget": "asymptote-oblique",
  "consigne": "Le trait vert mesure l''écart entre la courbe et la droite. Éloigne le point d''observation : l''écart s''efface. C''est ce calcul de limite qu''on rédige pour justifier une asymptote oblique."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 8 : 2 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 9 : 2 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 9;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 9 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : la suite arithmétique', 'Simulation : la suite géométrique');

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
    (v_chapitre_id, 'Simulation : la suite arithmétique', 35, 'interactif', '{
  "widget": "suite-arithmetique",
  "consigne": "Chaque saut vert vaut la raison. Les points sont alignés, parce qu''une suite arithmétique est une fonction affine du rang. Vérifie la formule de la somme sur les valeurs affichées."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : la suite géométrique', 45, 'interactif', '{
  "widget": "suite-geometrique",
  "consigne": "Mets la raison à 0,5 : les termes s''écrasent vers zéro et la somme se stabilise. Remonte-la à 1,5 : tout explose. Compare avec la suite arithmétique de la leçon précédente, pour la même durée."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 9 : 2 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 10 : 3 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 10;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 10 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : construire une série groupée', 'Simulation : les courbes cumulatives et la médiane', 'Simulation PhET : la régression des moindres carrés');

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
    (v_chapitre_id, 'Simulation : construire une série groupée', 15, 'interactif', '{
  "widget": "stats-classes",
  "consigne": "Change les effectifs classe par classe. La moyenne se calcule à partir des centres de classes, ce qui introduit une petite approximation : c''est le prix du regroupement."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : les courbes cumulatives et la médiane', 45, 'interactif', '{
  "widget": "courbes-cumulatives",
  "consigne": "Pars de la moitié de l''effectif sur l''axe vertical, rejoins la courbe, puis redescends : tu lis la médiane. Change de bouton, les deux courbes se croisent exactement à cette abscisse."
}', NULL, 10),
    (v_chapitre_id, 'Simulation PhET : la régression des moindres carrés', 47, 'simulation', 'Place des points et regarde la droite d''ajustement se placer. Pour aller plus loin que le programme, et voir à quoi servent les statistiques en pratique.', 'https://phet.colorado.edu/sims/html/least-squares-regression/latest/least-squares-regression_fr.html', 15);

  RAISE NOTICE 'Chapitre 10 : 3 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 11 : 3 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 11;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 11 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : p-uplets, arrangements et permutations', 'Simulation : le triangle de Pascal et le binôme', 'Simulation PhET : la probabilité avec un plinko');

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
    (v_chapitre_id, 'Simulation : p-uplets, arrangements et permutations', 35, 'interactif', '{
  "widget": "denombrement-arbre",
  "consigne": "Déplie l''arbre des choix. Avec remise ou sans remise, le nombre de branches n''est pas le même : c''est toute la différence entre un p-uplet et un arrangement."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : le triangle de Pascal et le binôme', 45, 'interactif', '{
  "widget": "triangle-pascal",
  "consigne": "Chaque case est la somme des deux du dessus. Choisis une ligne et un rang : tu obtiens un coefficient du binôme. Vérifie aussi que la somme d''une ligne vaut toujours 2 puissance n."
}', NULL, 10),
    (v_chapitre_id, 'Simulation PhET : la probabilité avec un plinko', 47, 'simulation', 'Les billes tombent au hasard et dessinent peu à peu la courbe des coefficients binomiaux. Le lien entre dénombrement et probabilité, vu en direct.', 'https://phet.colorado.edu/sims/html/plinko-probability/latest/plinko-probability_fr.html', 15);

  RAISE NOTICE 'Chapitre 11 : 3 simulation(s) ajoutee(s).';
END $p1cs$;
