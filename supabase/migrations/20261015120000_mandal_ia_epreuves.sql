-- Épreuves générées par Mandal IA et corrections des copies manuscrites.
CREATE TABLE IF NOT EXISTS public.epreuves_ia (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  eleve_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  programme_id uuid REFERENCES public.programmes(id) ON DELETE SET NULL,
  titre text NOT NULL,
  -- Énoncé : titre, niveau, durée, parties et questions avec leur barème.
  contenu jsonb NOT NULL,
  -- Corrigé et barème détaillé, utilisés pour corriger la copie.
  corrige jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS epreuves_ia_eleve_created_idx
  ON public.epreuves_ia (eleve_id, created_at DESC);

CREATE TABLE IF NOT EXISTS public.corrections_ia (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  eleve_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  epreuve_id uuid REFERENCES public.epreuves_ia(id) ON DELETE CASCADE,
  note numeric,
  sur numeric,
  -- Rapport : détail par question, points forts, difficultés, conseils, chapitres à revoir.
  rapport jsonb NOT NULL,
  nb_pages integer NOT NULL DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS corrections_ia_eleve_created_idx
  ON public.corrections_ia (eleve_id, created_at DESC);
CREATE INDEX IF NOT EXISTS corrections_ia_epreuve_idx
  ON public.corrections_ia (epreuve_id);

GRANT SELECT, INSERT, DELETE ON public.epreuves_ia TO authenticated;
GRANT SELECT, INSERT, DELETE ON public.corrections_ia TO authenticated;
GRANT ALL ON public.epreuves_ia TO service_role;
GRANT ALL ON public.corrections_ia TO service_role;
ALTER TABLE public.epreuves_ia ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.corrections_ia ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Mes epreuves Mandal IA" ON public.epreuves_ia;
CREATE POLICY "Mes epreuves Mandal IA" ON public.epreuves_ia FOR SELECT TO authenticated
  USING (eleve_id = auth.uid());
DROP POLICY IF EXISTS "Ecriture epreuves Mandal IA" ON public.epreuves_ia;
CREATE POLICY "Ecriture epreuves Mandal IA" ON public.epreuves_ia FOR INSERT TO authenticated
  WITH CHECK (eleve_id = auth.uid());
DROP POLICY IF EXISTS "Effacer mes epreuves Mandal IA" ON public.epreuves_ia;
CREATE POLICY "Effacer mes epreuves Mandal IA" ON public.epreuves_ia FOR DELETE TO authenticated
  USING (eleve_id = auth.uid());

DROP POLICY IF EXISTS "Mes corrections Mandal IA" ON public.corrections_ia;
CREATE POLICY "Mes corrections Mandal IA" ON public.corrections_ia FOR SELECT TO authenticated
  USING (eleve_id = auth.uid());
DROP POLICY IF EXISTS "Ecriture corrections Mandal IA" ON public.corrections_ia;
CREATE POLICY "Ecriture corrections Mandal IA" ON public.corrections_ia FOR INSERT TO authenticated
  WITH CHECK (
    eleve_id = auth.uid()
    AND (epreuve_id IS NULL OR EXISTS (
      SELECT 1 FROM public.epreuves_ia e WHERE e.id = epreuve_id AND e.eleve_id = auth.uid()
    ))
  );
DROP POLICY IF EXISTS "Effacer mes corrections Mandal IA" ON public.corrections_ia;
CREATE POLICY "Effacer mes corrections Mandal IA" ON public.corrections_ia FOR DELETE TO authenticated
  USING (eleve_id = auth.uid());
