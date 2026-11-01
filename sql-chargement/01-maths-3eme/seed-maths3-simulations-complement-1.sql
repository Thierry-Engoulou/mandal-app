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
-- Partie 1 sur 2 : chapitres 1 à 8.
-- ---------------------------------------------------------------------------

-- Chapitre 1
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
    RAISE NOTICE 'Chapitre 1 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 1;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 1 : introuvable, je passe.';
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
  SELECT v_chapitre_id, 'Simulation : diviseurs communs, PGCD et PPCM', 15, 'interactif', '{
  "widget": "diviseurs-communs",
  "consigne": "Choisis deux nombres, puis repère en vert les diviseurs qu''ils ont en commun. Le plus grand d''entre eux est leur PGCD. Essaie ensuite 35 et 24 : ils n''ont que 1 en commun, ils sont premiers entre eux."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : diviseurs communs, PGCD et PPCM'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : soustractions successives ou divisions d''Euclide ?', 25, 'interactif', '{
  "widget": "algo-euclide",
  "consigne": "Lance les deux méthodes sur 48 et 18, puis sur 120 et 7. Compte les étapes de chacune : tu comprendras pourquoi c''est la méthode d''Euclide qu''on retient."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : soustractions successives ou divisions d''Euclide ?'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : retrouver le PPCM dans la liste des multiples', 65, 'interactif', '{
  "widget": "diviseurs-communs",
  "consigne": "Passe à l''onglet « Multiples et PPCM ». Le premier nombre présent dans les deux listes est le PPCM. Vérifie ensuite que PGCD × PPCM redonne bien le produit des deux nombres de départ."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : retrouver le PPCM dans la liste des multiples'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : rendre une fraction irréductible', 75, 'interactif', '{
  "widget": "fraction-irreductible",
  "consigne": "Simplifie 84/126 facteur premier par facteur premier, puis recommence en divisant une seule fois par le PGCD. Cherche enfin une fraction déjà irréductible : son PGCD vaut 1."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : rendre une fraction irréductible'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 1 : rien à ajouter, les 4 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 1 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;


-- Chapitre 2
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
    RAISE NOTICE 'Chapitre 2 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 2;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 2 : introuvable, je passe.';
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
  SELECT v_chapitre_id, 'Simulation : sortir le plus grand carré d''un radical', 35, 'interactif', '{
  "widget": "radicaux",
  "consigne": "Mets 72 sous le radical : il devient 6√2. Essaie ensuite 50, puis 98. Termine par 30 : celui-là ne se simplifie pas, et c''est normal, il ne contient aucun facteur carré."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : sortir le plus grand carré d''un radical'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : écriture exacte ou valeur approchée ?', 45, 'interactif', '{
  "widget": "radicaux",
  "consigne": "Compare l''écriture avec le radical et la valeur approchée affichée en dessous. En devoir on garde l''écriture exacte : elle ne perd aucune décimale et elle se simplifie dans les calculs suivants."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : écriture exacte ou valeur approchée ?'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : placer et comparer deux réels', 65, 'interactif', '{
  "widget": "comparer-reels",
  "consigne": "Choisis √2, puis π, puis 7/3, et regarde où chacun se place sur la droite graduée. Lequel est le plus grand ? La droite répond avant le calcul."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : placer et comparer deux réels'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : encadrer de plus en plus finement', 95, 'interactif', '{
  "widget": "comparer-reels",
  "consigne": "Fais passer la précision de l''unité au millième. À chaque décimale gagnée, la fenêtre se resserre dix fois : c''est exactement ce que veut dire « encadrer au dixième près », puis « au centième près »."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : encadrer de plus en plus finement'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : les puissances d''exposant négatif', 105, 'interactif', '{
  "widget": "puissances-relatives",
  "consigne": "Mets le second exposant à −5. Vérifie que 10⁻⁵ vaut 1/100000 et non un nombre négatif : c''est l''erreur la plus fréquente. Vérifie ensuite que les exposants s''ajoutent quand on multiplie, et se soustraient quand on divise."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : les puissances d''exposant négatif'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 2 : rien à ajouter, les 5 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 2 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;


-- Chapitre 3
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
    RAISE NOTICE 'Chapitre 3 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 3;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 3 : introuvable, je passe.';
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
  SELECT v_chapitre_id, 'Simulation : développer par les aires', 15, 'interactif', '{
  "widget": "developper-reduire",
  "consigne": "Règle (x + 3)(x + 2) et retrouve les quatre morceaux du rectangle. Le terme en x vient de deux rectangles jaunes, jamais d''un seul : c''est l''oubli le plus courant quand on développe de tête."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : développer par les aires'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation PhET : modélisation par les aires', 45, 'simulation', 'Simulation de l''université du Colorado, en français. Prends d''abord l''onglet « Produits » pour développer, puis l''onglet « Factorisation » pour faire le chemin inverse.', 'https://phet.colorado.edu/sims/html/area-model-algebra/latest/area-model-algebra_fr.html', 15
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation PhET : modélisation par les aires'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : factoriser, c''est développer à l''envers', 47, 'interactif', '{
  "widget": "identites-remarquables",
  "consigne": "Reprends le carré découpé, mais lis-le de droite à gauche : la somme des quatre morceaux te donne la forme factorisée."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : factoriser, c''est développer à l''envers'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : degré, valeur et racine d''un polynôme', 65, 'interactif', '{
  "widget": "polynomes",
  "consigne": "Règle les coefficients, lis le degré, puis déplace x jusqu''à ce que la courbe traverse l''axe horizontal : tu auras trouvé une racine. Mets ensuite le coefficient de x² à zéro et regarde le degré tomber à 1."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : degré, valeur et racine d''un polynôme'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : la valeur interdite d''une fraction rationnelle', 75, 'interactif', '{
  "widget": "fraction-rationnelle",
  "consigne": "Amène x sur le trait rouge : la division devient impossible. Amène-le ensuite sur le cercle vert : la fraction s''annule. Ce sont deux choses très différentes, et on les confond souvent."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : la valeur interdite d''une fraction rationnelle'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 3 : rien à ajouter, les 5 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 3 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;


-- Chapitre 4
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
    RAISE NOTICE 'Chapitre 4 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 4;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 4 : introuvable, je passe.';
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
  SELECT v_chapitre_id, 'Simulation : la balance de l''équation', 15, 'interactif', '{
  "widget": "balance-equation",
  "consigne": "Équilibre les deux plateaux à la main en déplaçant x. Refais ensuite le calcul : on retranche b des deux côtés, puis on partage en a parts égales. La balance montre pourquoi on fait la même chose des deux côtés."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : la balance de l''équation'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation PhET : l''explorateur d''égalité', 17, 'simulation', 'La même idée avec des objets à poser sur une balance. Enlève la même chose des deux côtés jusqu''à isoler l''inconnue.', 'https://phet.colorado.edu/sims/html/equality-explorer/latest/equality-explorer_fr.html', 15
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation PhET : l''explorateur d''égalité'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : équation produit et équation quotient', 25, 'interactif', '{
  "widget": "equation-produit",
  "consigne": "Un produit est nul dès qu''un seul de ses facteurs l''est : il y a donc deux solutions. Passe ensuite en « quotient » et mets les deux nombres égaux pour découvrir le piège de la valeur interdite."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : équation produit et équation quotient'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : traduire un énoncé en équation', 35, 'interactif', '{
  "widget": "balance-equation",
  "consigne": "Le plateau de gauche représente l''énoncé, celui de droite le résultat annoncé. Règle a, b et c pour représenter ton problème, puis cherche x."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : traduire un énoncé en équation'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : écrire l''ensemble des solutions', 75, 'interactif', '{
  "widget": "intervalles",
  "consigne": "Écris l''ensemble des solutions de ton inéquation sous forme d''intervalle, puis teste quelques valeurs pour vérifier. Attention au crochet : ouvert pour « strictement », fermé sinon."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : écrire l''ensemble des solutions'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 4 : rien à ajouter, les 5 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 4 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;


-- Chapitre 5
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
    RAISE NOTICE 'Chapitre 5 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 5;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 5 : introuvable, je passe.';
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
  SELECT v_chapitre_id, 'Simulation : une équation à deux inconnues, c''est une droite', 15, 'interactif', '{
  "widget": "droite-deux-points",
  "consigne": "Règle la seconde droite sur y = −2x + 7. Tu viens de dessiner l''ensemble des couples solutions de 2x + y = 7 : ils sont en nombre infini et tous alignés."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : une équation à deux inconnues, c''est une droite'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : vérifier la solution d''un système', 35, 'interactif', '{
  "widget": "systeme-equations",
  "consigne": "Résous d''abord le système par substitution sur ton cahier, puis vérifie ici que le point d''intersection a bien les coordonnées que tu as trouvées."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : vérifier la solution d''un système'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation PhET : explorateur d''équations à deux variables', 37, 'simulation', 'Deux inconnues sur la même balance. Manipule-les pour sentir ce que veut dire « un couple solution ».', 'https://phet.colorado.edu/sims/html/equality-explorer-two-variables/latest/equality-explorer-two-variables_fr.html', 15
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation PhET : explorateur d''équations à deux variables'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : les trois cas possibles', 65, 'interactif', '{
  "widget": "systeme-equations",
  "consigne": "Fais apparaître tour à tour les trois situations : deux droites sécantes (une seule solution), parallèles (aucune solution), confondues (une infinité de solutions)."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : les trois cas possibles'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 5 : rien à ajouter, les 4 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 5 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;


-- Chapitre 6
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
    RAISE NOTICE 'Chapitre 6 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 6;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 6 : introuvable, je passe.';
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
  SELECT v_chapitre_id, 'Simulation : une application linéaire, c''est une affine avec b = 0', 15, 'interactif', '{
  "widget": "application-affine",
  "consigne": "Mets b à zéro : la droite passe par l''origine du repère. C''est la signature d''une application linéaire, et c''est le seul cas où l''image de 0 est 0."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : une application linéaire, c''est une affine avec b = 0'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation PhET : représenter à partir de l''équation réduite', 25, 'simulation', 'Change a et b dans l''équation y = ax + b et regarde la droite bouger. Essaie ensuite le jeu de la simulation pour t''entraîner.', 'https://phet.colorado.edu/sims/html/graphing-slope-intercept/latest/graphing-slope-intercept_fr.html', 15
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation PhET : représenter à partir de l''équation réduite'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : le forfait téléphonique', 45, 'interactif', '{
  "widget": "affine-morceaux",
  "consigne": "Avant le seuil, le prix ne bouge pas : la partie est constante. Après, chaque gigaoctet s''ajoute. Règle ton propre forfait et calcule ce que tu paierais pour 45 Go."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : le forfait téléphonique'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 6 : rien à ajouter, les 3 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 6 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;


-- Chapitre 7
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
    RAISE NOTICE 'Chapitre 7 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 7;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 7 : introuvable, je passe.';
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
  SELECT v_chapitre_id, 'Simulation : construire sa série et la regrouper', 15, 'interactif', '{
  "widget": "statistiques",
  "consigne": "Change les effectifs classe par classe et regarde la moyenne se déplacer. Une seule valeur très éloignée suffit à la tirer : c''est sa faiblesse."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : construire sa série et la regrouper'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : trois diagrammes pour une même série', 45, 'interactif', '{
  "widget": "diagrammes-stats",
  "consigne": "Passe des bâtons à l''histogramme, puis au diagramme circulaire. Vérifie que la somme des quatre angles fait bien 360°, et retiens pourquoi les barres se touchent dans un histogramme et pas dans un diagramme en bâtons."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : trois diagrammes pour une même série'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation PhET : centre et variabilité', 47, 'simulation', 'Moyenne, médiane et étendue sur une série que tu construis toi-même. Déplace un point très loin des autres et regarde laquelle des deux mesures bouge le plus.', 'https://phet.colorado.edu/sims/html/center-and-variability/latest/center-and-variability_fr.html', 15
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation PhET : centre et variabilité'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 7 : rien à ajouter, les 3 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 7 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;


-- Chapitre 8
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
    RAISE NOTICE 'Chapitre 8 : le programme de maths de 3ème est introuvable, je passe.';
    RETURN;
  END IF;

  SELECT id INTO v_chapitre_id FROM public.chapitres
  WHERE programme_id = v_programme_id AND ordre = 8;
  IF v_chapitre_id IS NULL THEN
    RAISE NOTICE 'Chapitre 8 : introuvable, je passe.';
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
  SELECT v_chapitre_id, 'Simulation PhET : l''aire de jeu proportionnelle', 15, 'simulation', 'Pour sentir ce qu''est une proportion avant d''aborder Thalès : deux quantités qui gardent le même rapport quand on les agrandit.', 'https://phet.colorado.edu/sims/html/proportion-playground/latest/proportion-playground_fr.html', 15
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation PhET : l''aire de jeu proportionnelle'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  INSERT INTO public.concepts
    (chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes)
  SELECT v_chapitre_id, 'Simulation : la réciproque de Thalès', 45, 'interactif', '{
  "widget": "thales",
  "consigne": "Avec la réciproque, l''ordre est imposé : on vérifie d''abord que les rapports sont égaux, et seulement ensuite on conclut que les droites sont parallèles. Déplace la parallèle pour voir les rapports rester égaux."
}', NULL, 10
  WHERE NOT EXISTS (
    SELECT 1 FROM public.concepts
    WHERE chapitre_id = v_chapitre_id AND titre = 'Simulation : la réciproque de Thalès'
  );
  GET DIAGNOSTICS v_n = ROW_COUNT;
  v_ajout := v_ajout + v_n;


  IF v_ajout = 0 THEN
    RAISE NOTICE 'Chapitre 8 : rien à ajouter, les 2 simulations y étaient déjà.';
  ELSE
    RAISE NOTICE 'Chapitre 8 : % simulation(s) posée(s).', v_ajout;
  END IF;
END $m3c$;


