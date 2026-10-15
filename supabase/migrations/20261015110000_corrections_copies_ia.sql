-- Correction des copies par Mandal IA : stockage privé des photos / PDF de
-- l'élève (dossier = son id) et historique des corrections.

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'copies-eleves', 'copies-eleves', false, 15728640,
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif', 'application/pdf']
)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "copies lecture" ON storage.objects;
CREATE POLICY "copies lecture" ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'copies-eleves' AND (storage.foldername(name))[1] = auth.uid()::text);
DROP POLICY IF EXISTS "copies depot" ON storage.objects;
CREATE POLICY "copies depot" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'copies-eleves' AND (storage.foldername(name))[1] = auth.uid()::text);
DROP POLICY IF EXISTS "copies suppression" ON storage.objects;
CREATE POLICY "copies suppression" ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'copies-eleves' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE TABLE IF NOT EXISTS public.corrections_ia (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  eleve_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  matiere text,
  sujet_texte text,
  fichiers_copie text[] NOT NULL DEFAULT '{}',
  fichiers_sujet text[] NOT NULL DEFAULT '{}',
  correction text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS corrections_ia_eleve_created_idx
  ON public.corrections_ia (eleve_id, created_at DESC);

GRANT SELECT, INSERT, DELETE ON public.corrections_ia TO authenticated;
GRANT ALL ON public.corrections_ia TO service_role;
ALTER TABLE public.corrections_ia ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Mes corrections" ON public.corrections_ia;
CREATE POLICY "Mes corrections" ON public.corrections_ia FOR SELECT TO authenticated
  USING (eleve_id = auth.uid());
DROP POLICY IF EXISTS "Enregistrer mes corrections" ON public.corrections_ia;
CREATE POLICY "Enregistrer mes corrections" ON public.corrections_ia FOR INSERT TO authenticated
  WITH CHECK (eleve_id = auth.uid());
DROP POLICY IF EXISTS "Supprimer mes corrections" ON public.corrections_ia;
CREATE POLICY "Supprimer mes corrections" ON public.corrections_ia FOR DELETE TO authenticated
  USING (eleve_id = auth.uid());
