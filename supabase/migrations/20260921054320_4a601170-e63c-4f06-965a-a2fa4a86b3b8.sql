DROP POLICY "avatars lecture" ON storage.objects;
CREATE POLICY "avatars lecture" ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = (auth.uid())::text);

DROP POLICY "mediatheque lecture" ON storage.objects;
CREATE POLICY "mediatheque lecture" ON storage.objects FOR SELECT TO authenticated
USING (
  bucket_id IN ('mediatheque-videos', 'mediatheque-audio', 'mediatheque-documents')
  AND (
    owner_id = (auth.uid())::text
    OR private.is_teacher(auth.uid())
    OR EXISTS (
      SELECT 1 FROM public.ressources_mediatheque r
      WHERE r.url_storage = storage.objects.bucket_id || '/' || storage.objects.name
        AND r.statut_validation = 'approuve'
    )
  )
);