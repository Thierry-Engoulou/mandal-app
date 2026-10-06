
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
