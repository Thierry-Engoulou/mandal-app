-- Ajout des colonnes chapitre_id et deverrouille_si sur public.examens
ALTER TABLE public.examens
  ADD COLUMN IF NOT EXISTS chapitre_id uuid REFERENCES public.chapitres(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS deverrouille_si text NOT NULL DEFAULT 'toujours';

-- Remarque :
-- deverrouille_si peut prendre les valeurs :
--   'toujours'                 : le quiz est toujours accessible
--   'tous_concepts_termines'   : le quiz requiert que tous les concepts du chapitre lié
--                                 soient marqués termine = true dans progression_concepts
