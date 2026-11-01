-- ============================================================================
-- MANDAL — Mathématiques 3ème : densification des simulations (chapitres 1 a 4)
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
-- Chapitre 1 : 4 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 1;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 1 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : diviseurs communs, PGCD et PPCM', 'Simulation : soustractions successives ou divisions d''Euclide ?', 'Simulation : retrouver le PPCM dans la liste des multiples', 'Simulation : rendre une fraction irréductible');

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
    (v_chapitre_id, 'Simulation : diviseurs communs, PGCD et PPCM', 15, 'interactif', '{
  "widget": "diviseurs-communs",
  "consigne": "Choisis deux nombres, puis repère en vert les diviseurs qu''ils ont en commun. Le plus grand d''entre eux est leur PGCD. Essaie ensuite 35 et 24 : ils n''ont que 1 en commun, ils sont premiers entre eux."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : soustractions successives ou divisions d''Euclide ?', 25, 'interactif', '{
  "widget": "algo-euclide",
  "consigne": "Lance les deux méthodes sur 48 et 18, puis sur 120 et 7. Compte les étapes de chacune : tu comprendras pourquoi c''est la méthode d''Euclide qu''on retient."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : retrouver le PPCM dans la liste des multiples', 65, 'interactif', '{
  "widget": "diviseurs-communs",
  "consigne": "Passe à l''onglet « Multiples et PPCM ». Le premier nombre présent dans les deux listes est le PPCM. Vérifie ensuite que PGCD × PPCM redonne bien le produit des deux nombres de départ."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : rendre une fraction irréductible', 75, 'interactif', '{
  "widget": "fraction-irreductible",
  "consigne": "Simplifie 84/126 facteur premier par facteur premier, puis recommence en divisant une seule fois par le PGCD. Cherche enfin une fraction déjà irréductible : son PGCD vaut 1."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 1 : 4 simulation(s) ajoutee(s).';
END $m3s$;

-- ----------------------------------------------------------------------------
-- Chapitre 2 : 5 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 2;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 2 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : sortir le plus grand carré d''un radical', 'Simulation : écriture exacte ou valeur approchée ?', 'Simulation : placer et comparer deux réels', 'Simulation : encadrer de plus en plus finement', 'Simulation : les puissances d''exposant négatif');

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
    (v_chapitre_id, 'Simulation : sortir le plus grand carré d''un radical', 35, 'interactif', '{
  "widget": "radicaux",
  "consigne": "Mets 72 sous le radical : il devient 6√2. Essaie ensuite 50, puis 98. Termine par 30 : celui-là ne se simplifie pas, et c''est normal, il ne contient aucun facteur carré."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : écriture exacte ou valeur approchée ?', 45, 'interactif', '{
  "widget": "radicaux",
  "consigne": "Compare l''écriture avec le radical et la valeur approchée affichée en dessous. En devoir on garde l''écriture exacte : elle ne perd aucune décimale et elle se simplifie dans les calculs suivants."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : placer et comparer deux réels', 65, 'interactif', '{
  "widget": "comparer-reels",
  "consigne": "Choisis √2, puis π, puis 7/3, et regarde où chacun se place sur la droite graduée. Lequel est le plus grand ? La droite répond avant le calcul."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : encadrer de plus en plus finement', 95, 'interactif', '{
  "widget": "comparer-reels",
  "consigne": "Fais passer la précision de l''unité au millième. À chaque décimale gagnée, la fenêtre se resserre dix fois : c''est exactement ce que veut dire « encadrer au dixième près », puis « au centième près »."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : les puissances d''exposant négatif', 105, 'interactif', '{
  "widget": "puissances-relatives",
  "consigne": "Mets le second exposant à −5. Vérifie que 10⁻⁵ vaut 1/100000 et non un nombre négatif : c''est l''erreur la plus fréquente. Vérifie ensuite que les exposants s''ajoutent quand on multiplie, et se soustraient quand on divise."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 2 : 5 simulation(s) ajoutee(s).';
END $m3s$;

-- ----------------------------------------------------------------------------
-- Chapitre 3 : 5 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 3;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 3 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : développer par les aires', 'Simulation PhET : modélisation par les aires', 'Simulation : factoriser, c''est développer à l''envers', 'Simulation : degré, valeur et racine d''un polynôme', 'Simulation : la valeur interdite d''une fraction rationnelle');

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
    (v_chapitre_id, 'Simulation : développer par les aires', 15, 'interactif', '{
  "widget": "developper-reduire",
  "consigne": "Règle (x + 3)(x + 2) et retrouve les quatre morceaux du rectangle. Le terme en x vient de deux rectangles jaunes, jamais d''un seul : c''est l''oubli le plus courant quand on développe de tête."
}', NULL, 10),
    (v_chapitre_id, 'Simulation PhET : modélisation par les aires', 45, 'simulation', 'Simulation de l''université du Colorado, en français. Prends d''abord l''onglet « Produits » pour développer, puis l''onglet « Factorisation » pour faire le chemin inverse.', 'https://phet.colorado.edu/sims/html/area-model-algebra/latest/area-model-algebra_fr.html', 15),
    (v_chapitre_id, 'Simulation : factoriser, c''est développer à l''envers', 47, 'interactif', '{
  "widget": "identites-remarquables",
  "consigne": "Reprends le carré découpé, mais lis-le de droite à gauche : la somme des quatre morceaux te donne la forme factorisée."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : degré, valeur et racine d''un polynôme', 65, 'interactif', '{
  "widget": "polynomes",
  "consigne": "Règle les coefficients, lis le degré, puis déplace x jusqu''à ce que la courbe traverse l''axe horizontal : tu auras trouvé une racine. Mets ensuite le coefficient de x² à zéro et regarde le degré tomber à 1."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : la valeur interdite d''une fraction rationnelle', 75, 'interactif', '{
  "widget": "fraction-rationnelle",
  "consigne": "Amène x sur le trait rouge : la division devient impossible. Amène-le ensuite sur le cercle vert : la fraction s''annule. Ce sont deux choses très différentes, et on les confond souvent."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 3 : 5 simulation(s) ajoutee(s).';
END $m3s$;

-- ----------------------------------------------------------------------------
-- Chapitre 4 : 5 simulation(s) ajoutee(s).
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
  WHERE programme_id = v_programme_id AND ordre = 4;
  IF v_chapitre_id IS NULL THEN
    RAISE EXCEPTION 'Chapitre 4 introuvable dans le programme "Mathématiques — 3ème".';
  END IF;

  -- Les simulations de ce chapitre sont-elles deja posees ?
  SELECT count(*) INTO v_deja FROM public.concepts
  WHERE chapitre_id = v_chapitre_id AND titre IN ('Simulation : la balance de l''équation', 'Simulation PhET : l''explorateur d''égalité', 'Simulation : équation produit et équation quotient', 'Simulation : traduire un énoncé en équation', 'Simulation : écrire l''ensemble des solutions');

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
    (v_chapitre_id, 'Simulation : la balance de l''équation', 15, 'interactif', '{
  "widget": "balance-equation",
  "consigne": "Équilibre les deux plateaux à la main en déplaçant x. Refais ensuite le calcul : on retranche b des deux côtés, puis on partage en a parts égales. La balance montre pourquoi on fait la même chose des deux côtés."
}', NULL, 10),
    (v_chapitre_id, 'Simulation PhET : l''explorateur d''égalité', 17, 'simulation', 'La même idée avec des objets à poser sur une balance. Enlève la même chose des deux côtés jusqu''à isoler l''inconnue.', 'https://phet.colorado.edu/sims/html/equality-explorer/latest/equality-explorer_fr.html', 15),
    (v_chapitre_id, 'Simulation : équation produit et équation quotient', 25, 'interactif', '{
  "widget": "equation-produit",
  "consigne": "Un produit est nul dès qu''un seul de ses facteurs l''est : il y a donc deux solutions. Passe ensuite en « quotient » et mets les deux nombres égaux pour découvrir le piège de la valeur interdite."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : traduire un énoncé en équation', 35, 'interactif', '{
  "widget": "balance-equation",
  "consigne": "Le plateau de gauche représente l''énoncé, celui de droite le résultat annoncé. Règle a, b et c pour représenter ton problème, puis cherche x."
}', NULL, 10),
    (v_chapitre_id, 'Simulation : écrire l''ensemble des solutions', 75, 'interactif', '{
  "widget": "intervalles",
  "consigne": "Écris l''ensemble des solutions de ton inéquation sous forme d''intervalle, puis teste quelques valeurs pour vérifier. Attention au crochet : ouvert pour « strictement », fermé sinon."
}', NULL, 10);

  RAISE NOTICE 'Chapitre 4 : 5 simulation(s) ajoutee(s).';
END $m3s$;
