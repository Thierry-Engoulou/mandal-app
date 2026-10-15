-- Inscription « enseignant » via Google : Google ne permet pas de transmettre le
-- rôle, le trigger handle_new_user crée donc un profil élève. Juste après
-- l'inscription, l'utilisateur peut convertir CE profil tout neuf en compte
-- enseignant en attente de validation (exactement ce que permet déjà
-- l'inscription par e-mail). Un élève existant ne peut pas l'utiliser.
CREATE OR REPLACE FUNCTION public.devenir_enseignant()
RETURNS void
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  uid uuid := auth.uid();
  p record;
BEGIN
  SELECT id, role, created_at INTO p FROM public.profiles WHERE id = uid;
  IF p.id IS NULL THEN
    RAISE EXCEPTION 'Profil introuvable';
  END IF;
  IF p.role = 'teacher' THEN
    RETURN;
  END IF;
  IF p.role <> 'student' OR p.created_at < now() - interval '1 hour'
     OR EXISTS (SELECT 1 FROM public.class_membres WHERE eleve_id = uid)
     OR EXISTS (SELECT 1 FROM public.resultats_examens WHERE eleve_id = uid) THEN
    RAISE EXCEPTION 'Ce compte ne peut plus devenir enseignant : contactez un administrateur.';
  END IF;

  UPDATE public.profiles
    SET role = 'teacher', statut_validation = 'en_attente'
    WHERE id = uid;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.devenir_enseignant() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.devenir_enseignant() TO authenticated;
