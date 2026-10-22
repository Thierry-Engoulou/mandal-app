-- Galerie de photos (événements M'ANDAL), affichée en bandeau défilant sur
-- l'accueil. Les administrateurs téléversent les photos depuis /admin/galerie ;
-- le bucket est public (photos destinées à être vues par tous).

-- ---------------------------------------------------------------------------
-- Bucket (public, 10 Mo par photo)
-- ---------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('galerie', 'galerie', true, 10485760,
        ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Table
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.galerie_photos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chemin text NOT NULL UNIQUE,
  legende text CHECK (legende IS NULL OR char_length(legende) <= 200),
  ordre integer NOT NULL DEFAULT 0,
  visible boolean NOT NULL DEFAULT true,
  ajoute_par uuid REFERENCES auth.users(id) ON DELETE SET NULL DEFAULT auth.uid(),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS galerie_photos_ordre_idx
  ON public.galerie_photos (ordre, created_at DESC);

ALTER TABLE public.galerie_photos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Galerie publique" ON public.galerie_photos;
CREATE POLICY "Galerie publique" ON public.galerie_photos FOR SELECT TO anon
  USING (visible);

DROP POLICY IF EXISTS "Galerie lecture" ON public.galerie_photos;
CREATE POLICY "Galerie lecture" ON public.galerie_photos FOR SELECT TO authenticated
  USING (visible OR private.is_super(auth.uid()));

DROP POLICY IF EXISTS "Galerie ajout" ON public.galerie_photos;
CREATE POLICY "Galerie ajout" ON public.galerie_photos FOR INSERT TO authenticated
  WITH CHECK (private.is_super(auth.uid()));

DROP POLICY IF EXISTS "Galerie modification" ON public.galerie_photos;
CREATE POLICY "Galerie modification" ON public.galerie_photos FOR UPDATE TO authenticated
  USING (private.is_super(auth.uid())) WITH CHECK (private.is_super(auth.uid()));

DROP POLICY IF EXISTS "Galerie suppression" ON public.galerie_photos;
CREATE POLICY "Galerie suppression" ON public.galerie_photos FOR DELETE TO authenticated
  USING (private.is_super(auth.uid()));

GRANT SELECT ON public.galerie_photos TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.galerie_photos TO authenticated;

-- ---------------------------------------------------------------------------
-- Stockage : lecture publique (bucket public), écriture réservée aux admins
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "galerie ajout" ON storage.objects;
CREATE POLICY "galerie ajout" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'galerie' AND private.is_super(auth.uid()));

DROP POLICY IF EXISTS "galerie suppression" ON storage.objects;
CREATE POLICY "galerie suppression" ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'galerie' AND private.is_super(auth.uid()));
