ALTER TABLE public.chapitres ADD COLUMN IF NOT EXISTS niveau text;

ALTER TABLE public.concepts ADD COLUMN IF NOT EXISTS type_contenu text NOT NULL DEFAULT 'texte';
ALTER TABLE public.concepts ADD COLUMN IF NOT EXISTS contenu_texte text;
ALTER TABLE public.concepts ADD COLUMN IF NOT EXISTS media_url text;
ALTER TABLE public.concepts ADD COLUMN IF NOT EXISTS duree_minutes integer;

CREATE TABLE IF NOT EXISTS public.progression_concepts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  eleve_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  concept_id uuid NOT NULL REFERENCES public.concepts(id) ON DELETE CASCADE,
  termine boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (eleve_id, concept_id)
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.progression_concepts TO authenticated;
GRANT ALL ON public.progression_concepts TO service_role;

ALTER TABLE public.progression_concepts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Eleve gere sa progression"
ON public.progression_concepts
FOR ALL
TO authenticated
USING (eleve_id = auth.uid())
WITH CHECK (eleve_id = auth.uid());

CREATE POLICY "Equipe pedagogique consulte la progression"
ON public.progression_concepts
FOR SELECT
TO authenticated
USING (
  private.is_super(auth.uid())
  OR EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = progression_concepts.eleve_id
      AND p.etablissement_id = private.etab(auth.uid())
      AND (private.is_teacher(auth.uid()) OR private.is_chef(auth.uid(), p.etablissement_id))
  )
);

CREATE TRIGGER trg_progression_concepts_updated
BEFORE UPDATE ON public.progression_concepts
FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();