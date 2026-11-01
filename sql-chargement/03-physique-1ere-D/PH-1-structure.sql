-- ============================================================================
-- MANDAL — Physique 1ère D : etape 1 sur 5, la structure
-- Cree les 2 chapitres officiels manquants, renumerote les 17 chapitres
-- et renseigne les 4 modules. A LANCER EN PREMIER.
-- Idempotent : relancez-le autant de fois que vous voulez.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Chapitre manquant : Mesure des grandeurs physique et chimique
-- ---------------------------------------------------------------------------
DO $ph$
DECLARE
  v_prog uuid;
  v_ordre int;
BEGIN
  SELECT id INTO v_prog FROM public.programmes WHERE titre = 'Physique — 1ère D';
  IF v_prog IS NULL THEN
    RAISE EXCEPTION 'Programme "Physique — 1ère D" introuvable.';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.chapitres WHERE programme_id = v_prog AND titre = 'Mesure des grandeurs physique et chimique') THEN
    SELECT coalesce(max(ordre), 0) + 1 INTO v_ordre FROM public.chapitres WHERE programme_id = v_prog;
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_prog, 'Mesure des grandeurs physique et chimique', v_ordre, 'Module 1 : Mesures et incertitudes');
    RAISE NOTICE 'Chapitre "Mesure des grandeurs physique et chimique" cree.';
  END IF;
END $ph$;

-- ---------------------------------------------------------------------------
-- Chapitre manquant : Contraintes d''une loi
-- ---------------------------------------------------------------------------
DO $ph$
DECLARE
  v_prog uuid;
  v_ordre int;
BEGIN
  SELECT id INTO v_prog FROM public.programmes WHERE titre = 'Physique — 1ère D';
  IF v_prog IS NULL THEN
    RAISE EXCEPTION 'Programme "Physique — 1ère D" introuvable.';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.chapitres WHERE programme_id = v_prog AND titre = 'Contraintes d''une loi') THEN
    SELECT coalesce(max(ordre), 0) + 1 INTO v_ordre FROM public.chapitres WHERE programme_id = v_prog;
    INSERT INTO public.chapitres (programme_id, titre, ordre, niveau)
    VALUES (v_prog, 'Contraintes d''une loi', v_ordre, 'Module 1 : Mesures et incertitudes');
    RAISE NOTICE 'Chapitre "Contraintes d''une loi" cree.';
  END IF;
END $ph$;

-- ---------------------------------------------------------------------------
-- Reorganisation : ordre officiel et modules du programme
-- ---------------------------------------------------------------------------
DO $ph$
DECLARE
  r record;
  v_prog uuid;
  v_maj int := 0;
  v_abs int := 0;
BEGIN
  SELECT id INTO v_prog FROM public.programmes WHERE titre = 'Physique — 1ère D';
  IF v_prog IS NULL THEN
    RAISE EXCEPTION 'Programme "Physique — 1ère D" introuvable.';
  END IF;

  -- on decale d'abord tout le monde, pour eviter tout melange
  UPDATE public.chapitres SET ordre = ordre + 1000 WHERE programme_id = v_prog;

  FOR r IN SELECT * FROM (VALUES
    (1, 'Mesure des grandeurs physique et chimique', 'Module 1 : Mesures et incertitudes'),
    (2, 'Incertitude de mesure', 'Module 1 : Mesures et incertitudes'),
    (3, 'Exemples de modèles utilisés en physique et en chimie', 'Module 1 : Mesures et incertitudes'),
    (4, 'Contraintes d''une loi', 'Module 1 : Mesures et incertitudes'),
    (5, 'Travail et puissance d''une force', 'Module 2 : Mouvements et interactions'),
    (6, 'L''énergie cinétique', 'Module 2 : Mouvements et interactions'),
    (7, 'L''énergie potentielle', 'Module 2 : Mouvements et interactions'),
    (8, 'L''énergie mécanique', 'Module 2 : Mouvements et interactions'),
    (9, 'L''énergie thermique', 'Module 2 : Mouvements et interactions'),
    (10, 'Sources de lumière colorée', 'Module 3 : Optique géométrique'),
    (11, 'Interaction lumière-matière', 'Module 3 : Optique géométrique'),
    (12, 'Les lentilles minces', 'Module 3 : Optique géométrique'),
    (13, 'L''œil réduit', 'Module 3 : Optique géométrique'),
    (14, 'Étude de quelques instruments d''optique', 'Module 3 : Optique géométrique'),
    (15, 'Générateurs, récepteurs et point de fonctionnement d''un circuit électrique', 'Module 4 : Aspects énergétiques des circuits électriques'),
    (16, 'Énergie et puissance électrique', 'Module 4 : Aspects énergétiques des circuits électriques'),
    (17, 'Induction électromagnétique', 'Module 4 : Aspects énergétiques des circuits électriques')
  ) AS t(rang, titre, module) LOOP
    UPDATE public.chapitres SET ordre = r.rang, niveau = r.module
    WHERE programme_id = v_prog AND titre = r.titre;
    IF FOUND THEN v_maj := v_maj + 1; ELSE v_abs := v_abs + 1;
      RAISE NOTICE 'Chapitre absent : %', r.titre;
    END IF;
  END LOOP;

  -- si un chapitre inattendu reste decale, on le remet a la suite
  UPDATE public.chapitres SET ordre = ordre - 1000 + 100
  WHERE programme_id = v_prog AND ordre > 1000;

  RAISE NOTICE 'Chapitres renumerotes : % — absents : %', v_maj, v_abs;
END $ph$;
