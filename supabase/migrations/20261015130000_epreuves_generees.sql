-- Épreuves blanches générées par Mandal IA pour un élève.
CREATE TABLE IF NOT EXISTS public.epreuves_generees (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  eleve_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  matiere text NOT NULL,
  niveau text NOT NULL,
  duree_minutes integer NOT NULL,
  contenu text NOT NULL,
  modeles_utilises integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS epreuves_generees_eleve_idx
  ON public.epreuves_generees (eleve_id, created_at DESC);

GRANT SELECT, INSERT, DELETE ON public.epreuves_generees TO authenticated;
GRANT ALL ON public.epreuves_generees TO service_role;
ALTER TABLE public.epreuves_generees ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Mes epreuves generees" ON public.epreuves_generees;
CREATE POLICY "Mes epreuves generees" ON public.epreuves_generees FOR SELECT TO authenticated
  USING (eleve_id = auth.uid());
DROP POLICY IF EXISTS "Enregistrer mes epreuves generees" ON public.epreuves_generees;
CREATE POLICY "Enregistrer mes epreuves generees" ON public.epreuves_generees FOR INSERT TO authenticated
  WITH CHECK (eleve_id = auth.uid());
DROP POLICY IF EXISTS "Supprimer mes epreuves generees" ON public.epreuves_generees;
CREATE POLICY "Supprimer mes epreuves generees" ON public.epreuves_generees FOR DELETE TO authenticated
  USING (eleve_id = auth.uid());
