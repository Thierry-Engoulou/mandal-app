-- ============================================================================
-- MANDAL — Mathématiques 1ère C : densification des simulations (chapitres 1 a 5)
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
-- Chapitre 1 : 5 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 1;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 1 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : somme, produit et factorisation', 'Simulation PhET : modélisation par les aires', 'Simulation : équation irrationnelle et solutions parasites', 'Simulation : polynôme de degré 3', 'Simulation : le discriminant sur un problème concret');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 1 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : somme, produit et factorisation', 35, 'interactif', '{
  "widget": "somme-produit-racines",
  "consigne": "Règle a, b et c, puis lis la somme et le produit des racines sans les calculer. Cherche ensuite un trinôme dont les racines sont 2 et 5 : il te suffit d''une somme de 7 et d''un produit de 10."
}', NULL, 10),
    (v_chapitre_id, 'Simulation PhET : modélisation par les aires', 37, 'simulation', 'Onglet « Factorisation » : retrouve la forme factorisée d''un trinôme en reconstituant le rectangle. C''est la lecture géométrique de ce que tu viens de faire par le calcul.', 'https://phet.colorado.edu/sims/html/area-model-algebra/latest/area-model-algebra_fr.html', 15),
    (v_chapitre_id, 'Simulation : équation irrationnelle et solutions parasites', 65, 'interactif', '{
  "widget": "equation-irrationnelle",
  "consigne": "Règle l''équation √(x + 2) = x. Les deux courbes se croisent en un seul point, mais l''équation élevée au carré donne deux solutions : celle qui est barrée en rouge est parasite. C''est la raison pour laquelle on vérifie toujours à la fin."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : polynôme de degré 3', 75, 'interactif', '{
  "widget": "polynome-degre3",
  "consigne": "Fais varier la racine évidente, puis le trinôme restant. Quand le discriminant du trinôme devient négatif, le polynôme n''a plus qu''une seule racine, mais sa courbe traverse toujours l''axe au moins une fois : c''est vrai pour tout polynôme de degré impair."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : le discriminant sur un problème concret', 85, 'interactif', '{
  "widget": "second-degre",
  "consigne": "Traduis ton problème en trinôme, puis regarde le discriminant. S''il est négatif, c''est que le problème n''a pas de solution, et il faut le dire dans la rédaction au lieu de forcer un résultat."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 1 : 5 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 2 : 3 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 2;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 2 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : le pivot de Gauss, étape par étape', 'Simulation PhET : explorateur d''équations à deux variables', 'Simulation : vérifier la solution d''un système');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 2 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : le pivot de Gauss, étape par étape', 35, 'interactif', '{
  "widget": "pivot-gauss",
  "consigne": "Avance d''une étape à la fois. À chaque fois, une inconnue disparaît d''une ligne. Quand le système est triangulaire, on remonte : z, puis y, puis x."
}', NULL, 10),
    (v_chapitre_id, 'Simulation PhET : explorateur d''équations à deux variables', 37, 'simulation', 'Deux inconnues sur une balance. Enlève la même chose des deux côtés, c''est exactement ce que fait la méthode par combinaison.', 'https://phet.colorado.edu/sims/html/equality-explorer-two-variables/latest/equality-explorer-two-variables_fr.html', 15),
    (v_chapitre_id, 'Simulation : vérifier la solution d''un système', 45, 'interactif', '{
  "widget": "systeme-equations",
  "consigne": "Résous ton problème sur le cahier, puis vérifie ici que le point d''intersection a bien les coordonnées trouvées. Si les droites sont parallèles, c''est que le problème n''a pas de solution."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 2 : 3 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 3 : 4 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 3;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 3 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation PhET : la tour de trigo', 'Simulation : résoudre cos x = a, sin x = a, tan x = a', 'Simulation : réduire a cos x + b sin x', 'Simulation : l''arc solution d''une inéquation');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 3 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation PhET : la tour de trigo', 25, 'simulation', 'Cosinus, sinus et tangente lus sur le cercle, avec la courbe qui se construit à côté. Fais un tour complet et regarde la courbe se répéter.', 'https://phet.colorado.edu/sims/html/trig-tour/latest/trig-tour_fr.html', 15),
    (v_chapitre_id, 'Simulation : résoudre cos x = a, sin x = a, tan x = a', 35, 'interactif', '{
  "widget": "equation-trigo",
  "consigne": "Pour le cosinus, les deux solutions sont symétriques par rapport à l''axe horizontal ; pour le sinus, par rapport à l''axe vertical. Change de bouton et observe la différence, c''est elle qu''on oublie le plus souvent."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : réduire a cos x + b sin x', 45, 'interactif', '{
  "widget": "acos-bsin",
  "consigne": "Règle a = 3 et b = 4 : l''amplitude R vaut 5. Monte ensuite le second membre au-dessus de 5 et regarde les solutions disparaître. Une équation a cos x + b sin x = c n''a de solution que si c est compris entre −R et R."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : l''arc solution d''une inéquation', 55, 'interactif', '{
  "widget": "inequation-trigo",
  "consigne": "Trace la droite qui correspond à a, puis garde l''arc du bon côté. Change le sens de l''inégalité et vérifie que l''arc devient le complémentaire du précédent."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 3 : 4 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 4 : 2 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 4;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 4 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : somme, produit, quotient et composée', 'Simulation PhET : le constructeur de fonction');

  IF v_deja > 0 THEN
    RAISE NOTICE 'Chapitre 4 : % simulation(s) deja presente(s) — aucun ajout.', v_deja;
    RETURN;
  END IF;

  -- On multiplie les numeros d'ordre par 10 pour liberer de la place entre les
  -- lecons. Le detour par des valeurs negatives evite toute collision pendant
  -- la mise a jour. Le contenu des lecons n'est pas touche.
  UPDATE public.concepts SET ordre = -(ordre * 10) WHERE chapitre_id = v_chapitre_id;
  UPDATE public.concepts SET ordre = -ordre WHERE chapitre_id = v_chapitre_id AND ordre < 0;

  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes) VALUES
    (v_chapitre_id, 'Simulation : somme, produit, quotient et composée', 35, 'interactif', '{
  "widget": "operations-fonctions",
  "consigne": "Passe d''une opération à l''autre et regarde la courbe bleue se construire à partir des deux courbes en pointillés. Seul le quotient réduit le domaine, parce qu''il faut écarter les valeurs qui annulent le dénominateur."
}', NULL, 10),
    (v_chapitre_id, 'Simulation PhET : le constructeur de fonction', 37, 'simulation', 'Des fonctions mises bout à bout, comme sur une chaîne de montage. C''est la composition, vue comme un enchaînement de machines.', 'https://phet.colorado.edu/sims/html/function-builder/latest/function-builder_fr.html', 15);

  RAISE NOTICE 'Chapitre 4 : 2 simulation(s) ajoutee(s).';
END $p1cs$;

-- ----------------------------------------------------------------------------
-- Chapitre 5 : 2 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 5;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 5 introuvable dans le programme "Mathématiques — 1ère C".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : lire une courbe', 'Simulation : parité, imparité, périodicité');

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
    (v_chapitre_id, 'Simulation : lire une courbe', 15, 'interactif', '{
  "widget": "lire-courbe",
  "consigne": "Trois lectures différentes sur la même courbe : l''image d''un nombre, ses antécédents, et le sens de variation. Remarque qu''un nombre n''a qu''une seule image, mais peut avoir plusieurs antécédents."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : parité, imparité, périodicité', 25, 'interactif', '{
  "widget": "parite-periodicite",
  "consigne": "Compare les quatre fonctions proposées. Les points orange sont placés en x et en −x : s''ils sont à la même hauteur, la fonction est paire ; s''ils sont symétriques par rapport à l''origine, elle est impaire."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 5 : 2 simulation(s) ajoutee(s).';
END $p1cs$;
