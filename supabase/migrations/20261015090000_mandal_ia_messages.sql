-- Historique des conversations avec Mandal IA (répétiteur numérique).
CREATE TABLE IF NOT EXISTS public.ia_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  eleve_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('user', 'assistant')),
  contenu text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ia_messages_eleve_created_idx
  ON public.ia_messages (eleve_id, created_at);

GRANT SELECT, INSERT, DELETE ON public.ia_messages TO authenticated;
GRANT ALL ON public.ia_messages TO service_role;
ALTER TABLE public.ia_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Mon historique Mandal IA" ON public.ia_messages;
CREATE POLICY "Mon historique Mandal IA" ON public.ia_messages FOR SELECT TO authenticated
  USING (eleve_id = auth.uid());
DROP POLICY IF EXISTS "Ecriture historique Mandal IA" ON public.ia_messages;
CREATE POLICY "Ecriture historique Mandal IA" ON public.ia_messages FOR INSERT TO authenticated
  WITH CHECK (eleve_id = auth.uid());
DROP POLICY IF EXISTS "Effacer mon historique Mandal IA" ON public.ia_messages;
CREATE POLICY "Effacer mon historique Mandal IA" ON public.ia_messages FOR DELETE TO authenticated
  USING (eleve_id = auth.uid());
