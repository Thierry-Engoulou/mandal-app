-- AVATARS : lecture par tout utilisateur connecté, écriture sur son propre dossier
CREATE POLICY "avatars lecture" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'avatars');
CREATE POLICY "avatars depot" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);
CREATE POLICY "avatars maj" ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);
CREATE POLICY "avatars suppression" ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

-- LOGOS
CREATE POLICY "logos lecture" ON storage.objects FOR SELECT TO authenticated USING (bucket_id = 'logos-etablissements');
CREATE POLICY "logos gestion" ON storage.objects FOR ALL TO authenticated
  USING (bucket_id = 'logos-etablissements' AND private.is_chef(auth.uid(), ((storage.foldername(name))[1])::uuid))
  WITH CHECK (bucket_id = 'logos-etablissements' AND private.is_chef(auth.uid(), ((storage.foldername(name))[1])::uuid));

-- MEDIATHEQUE : lecture pour les membres connectes, depot par les enseignants
CREATE POLICY "mediatheque lecture" ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id IN ('mediatheque-videos','mediatheque-audio','mediatheque-documents'));
CREATE POLICY "mediatheque depot" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id IN ('mediatheque-videos','mediatheque-audio','mediatheque-documents') AND private.is_teacher(auth.uid()));
CREATE POLICY "mediatheque maj" ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id IN ('mediatheque-videos','mediatheque-audio','mediatheque-documents') AND (owner_id = auth.uid()::text OR private.is_super(auth.uid())));
CREATE POLICY "mediatheque suppression" ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id IN ('mediatheque-videos','mediatheque-audio','mediatheque-documents') AND (owner_id = auth.uid()::text OR private.is_super(auth.uid())));

-- CONTENUS EN ATTENTE : auteur + chef d'etablissement (dossier = etablissement_id)
CREATE POLICY "en attente lecture" ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'contenus-en-attente' AND (owner_id = auth.uid()::text OR private.is_chef(auth.uid(), ((storage.foldername(name))[1])::uuid)));
CREATE POLICY "en attente depot" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'contenus-en-attente' AND private.is_teacher(auth.uid()));
CREATE POLICY "en attente gestion" ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'contenus-en-attente' AND (owner_id = auth.uid()::text OR private.is_chef(auth.uid(), ((storage.foldername(name))[1])::uuid)));