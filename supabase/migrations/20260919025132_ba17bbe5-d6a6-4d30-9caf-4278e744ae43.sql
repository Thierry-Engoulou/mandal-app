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

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  meta_role app_role;
BEGIN
  BEGIN
    meta_role := COALESCE((NEW.raw_user_meta_data ->> 'role')::app_role, 'student');
  EXCEPTION WHEN others THEN
    meta_role := 'student';
  END;

  INSERT INTO public.profiles (id, role, full_name, nom, prenom)
  VALUES (
    NEW.id,
    meta_role,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', split_part(NEW.email, '@', 1)),
    NEW.raw_user_meta_data ->> 'nom',
    NEW.raw_user_meta_data ->> 'prenom'
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;

CREATE POLICY "Super admin met a jour les profils"
ON public.profiles FOR UPDATE TO authenticated
USING (private.is_super(auth.uid()))
WITH CHECK (private.is_super(auth.uid()));

CREATE POLICY "Super admin gere les invitations"
ON public.invitations_admin FOR ALL TO authenticated
USING (private.is_super(auth.uid()))
WITH CHECK (private.is_super(auth.uid()));

CREATE POLICY "Super admin lit les validations"
ON public.validations_enseignants FOR SELECT TO authenticated
USING (private.is_super(auth.uid()));

CREATE POLICY "Super admin valide les enseignants"
ON public.validations_enseignants FOR UPDATE TO authenticated
USING (private.is_super(auth.uid()))
WITH CHECK (private.is_super(auth.uid()));