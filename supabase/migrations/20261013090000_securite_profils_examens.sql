-- ============================================================================
-- Durcissement de la sécurité : profils, examens, contenus pédagogiques
-- ============================================================================
-- 1. Création de profil : le rôle choisi à l'inscription est limité à
--    student / teacher (plus d'auto-promotion en admin via les métadonnées).
--    Un enseignant démarre "en_attente" de validation. Un élève qui choisit
--    une classe à l'inscription est inscrit dans class_membres côté serveur.
-- 2. Un utilisateur ne peut plus modifier lui-même ses champs sensibles
--    (role, statut_validation, etablissement_id, xp_total).
-- 3. Les examens sont corrigés côté serveur (fonction soumettre_examen) :
--    les élèves ne lisent plus les réponses correctes et ne peuvent plus
--    écrire eux-mêmes leur note ni leurs XP.
-- 4. Les enseignants ne gèrent plus que les chapitres / concepts / questions /
--    résultats de leur propre établissement.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Création de profil à l'inscription
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  meta_role app_role;
  meta_classe uuid;
  classe_etab uuid;
BEGIN
  -- Seuls les rôles "student" et "teacher" peuvent être choisis à l'inscription.
  meta_role := CASE
    WHEN NEW.raw_user_meta_data ->> 'role' = 'teacher' THEN 'teacher'::app_role
    ELSE 'student'::app_role
  END;

  IF meta_role = 'student' THEN
    BEGIN
      meta_classe := (NEW.raw_user_meta_data ->> 'classe_id')::uuid;
    EXCEPTION WHEN others THEN
      meta_classe := NULL;
    END;
    IF meta_classe IS NOT NULL THEN
      SELECT etablissement_id INTO classe_etab FROM public.classes WHERE id = meta_classe;
      IF classe_etab IS NULL THEN
        meta_classe := NULL;
      END IF;
    END IF;
  END IF;

  INSERT INTO public.profiles (id, role, full_name, nom, prenom, avatar_url, etablissement_id, statut_validation)
  VALUES (
    NEW.id,
    meta_role,
    COALESCE(NEW.raw_user_meta_data ->> 'full_name', NEW.raw_user_meta_data ->> 'name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data ->> 'nom', NEW.raw_user_meta_data ->> 'family_name'),
    COALESCE(NEW.raw_user_meta_data ->> 'prenom', NEW.raw_user_meta_data ->> 'given_name'),
    COALESCE(NEW.raw_user_meta_data ->> 'avatar_url', NEW.raw_user_meta_data ->> 'picture'),
    classe_etab,
    CASE WHEN meta_role = 'teacher' THEN 'en_attente'::validation_statut ELSE 'approuve'::validation_statut END
  )
  ON CONFLICT (id) DO NOTHING;

  IF meta_classe IS NOT NULL THEN
    INSERT INTO public.class_membres (class_id, eleve_id)
    VALUES (meta_classe, NEW.id)
    ON CONFLICT (class_id, eleve_id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;

-- Nouveaux profils : statut "en_attente" par défaut (les élèves sont approuvés
-- explicitement par handle_new_user / guard ci-dessous).
ALTER TABLE public.profiles ALTER COLUMN statut_validation SET DEFAULT 'en_attente';

-- ---------------------------------------------------------------------------
-- 2. Protection des champs sensibles de profiles
-- ---------------------------------------------------------------------------
-- SECURITY INVOKER volontaire : current_user vaut alors le rôle appelant
-- ("authenticated" pour le navigateur, "service_role" pour le backend, ou le
-- propriétaire d'une fonction SECURITY DEFINER comme soumettre_examen).
CREATE OR REPLACE FUNCTION private.guard_profile_changes()
RETURNS trigger
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = private, public
AS $$
DECLARE
  uid uuid := auth.uid();
BEGIN
  -- Backend (service_role), fonctions SECURITY DEFINER, éditeur SQL : pas de restriction.
  IF current_user NOT IN ('authenticated', 'anon') THEN
    RETURN NEW;
  END IF;

  IF private.is_super(uid) THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'INSERT' THEN
    -- Création de son propre profil depuis le client : valeurs imposées.
    IF NEW.role NOT IN ('student', 'teacher') THEN
      NEW.role := 'student';
    END IF;
    NEW.xp_total := 0;
    NEW.etablissement_id := NULL;
    NEW.statut_validation := CASE WHEN NEW.role = 'teacher' THEN 'en_attente'::validation_statut
                                  ELSE 'approuve'::validation_statut END;
    RETURN NEW;
  END IF;

  -- UPDATE par un chef d'établissement sur un membre de son établissement
  IF OLD.id <> uid AND private.is_chef(uid, OLD.etablissement_id) THEN
    IF OLD.role IN ('chef_etablissement', 'admin', 'super_admin') THEN
      RAISE EXCEPTION 'Modification non autorisée de ce profil';
    END IF;
    IF NEW.role IS DISTINCT FROM OLD.role OR NEW.xp_total IS DISTINCT FROM OLD.xp_total THEN
      RAISE EXCEPTION 'Le rôle et les XP ne peuvent pas être modifiés par un chef d''établissement';
    END IF;
    IF NEW.etablissement_id IS DISTINCT FROM OLD.etablissement_id THEN
      RAISE EXCEPTION 'Utilisez retirer_membre_etablissement pour retirer un membre';
    END IF;
    RETURN NEW;
  END IF;

  -- UPDATE de son propre profil : champs sensibles verrouillés.
  IF NEW.role IS DISTINCT FROM OLD.role
     OR NEW.statut_validation IS DISTINCT FROM OLD.statut_validation
     OR NEW.etablissement_id IS DISTINCT FROM OLD.etablissement_id
     OR NEW.xp_total IS DISTINCT FROM OLD.xp_total THEN
    RAISE EXCEPTION 'Les champs role, statut_validation, etablissement_id et xp_total ne sont pas modifiables';
  END IF;

  RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION private.guard_profile_changes() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS trg_profiles_guard ON public.profiles;
CREATE TRIGGER trg_profiles_guard
BEFORE INSERT OR UPDATE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION private.guard_profile_changes();

-- Retrait d'un membre par son chef d'établissement. Passe par une fonction car
-- la RLS de SELECT empêche le chef de « voir » la ligne une fois
-- etablissement_id remis à NULL (l'UPDATE direct échouait).
CREATE OR REPLACE FUNCTION public.retirer_membre_etablissement(p_profile_id uuid)
RETURNS void
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = public, private
AS $$
DECLARE
  cible record;
BEGIN
  SELECT id, role, etablissement_id INTO cible FROM public.profiles WHERE id = p_profile_id;
  IF cible.id IS NULL OR cible.etablissement_id IS NULL
     OR NOT private.is_chef(auth.uid(), cible.etablissement_id) THEN
    RAISE EXCEPTION 'Membre introuvable';
  END IF;
  IF cible.role NOT IN ('student', 'teacher') OR cible.id = auth.uid() THEN
    RAISE EXCEPTION 'Ce compte ne peut pas être retiré';
  END IF;

  DELETE FROM public.class_membres m
    USING public.classes c
    WHERE m.class_id = c.id AND m.eleve_id = cible.id AND c.etablissement_id = cible.etablissement_id;

  UPDATE public.profiles
    SET etablissement_id = NULL, statut_validation = 'rejete'
    WHERE id = cible.id;
END;
$$;
REVOKE EXECUTE ON FUNCTION public.retirer_membre_etablissement(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.retirer_membre_etablissement(uuid) TO authenticated;

-- ---------------------------------------------------------------------------
-- 3. Examens : correction côté serveur
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION private.peut_voir_examen(_user_id uuid, _examen_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = private, public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.examens e
    WHERE e.id = _examen_id
      AND (
        e.etablissement_id = private.etab(_user_id)
        OR private.is_super(_user_id)
        OR EXISTS (SELECT 1 FROM public.class_membres m WHERE m.class_id = e.classe_id AND m.eleve_id = _user_id)
      )
  )
$$;
GRANT EXECUTE ON FUNCTION private.peut_voir_examen(uuid, uuid) TO authenticated;

-- Seule l'équipe pédagogique lit directement la table questions (avec les réponses).
DROP POLICY IF EXISTS "Questions lisibles dans l etablissement" ON public.questions;
DROP POLICY IF EXISTS "Enseignants gerent les questions" ON public.questions;
DROP POLICY IF EXISTS "Enseignants lisent les questions" ON public.questions;
CREATE POLICY "Enseignants lisent les questions" ON public.questions FOR SELECT TO authenticated
  USING (private.is_teacher(auth.uid()) AND EXISTS (
    SELECT 1 FROM public.examens e WHERE e.id = examen_id
      AND (e.etablissement_id = private.etab(auth.uid()) OR e.created_by = auth.uid() OR private.is_super(auth.uid()))));
CREATE POLICY "Enseignants gerent les questions" ON public.questions FOR ALL TO authenticated
  USING (private.is_teacher(auth.uid()) AND EXISTS (
    SELECT 1 FROM public.examens e WHERE e.id = examen_id
      AND (e.etablissement_id = private.etab(auth.uid()) OR e.created_by = auth.uid() OR private.is_super(auth.uid()))))
  WITH CHECK (private.is_teacher(auth.uid()) AND EXISTS (
    SELECT 1 FROM public.examens e WHERE e.id = examen_id
      AND (e.etablissement_id = private.etab(auth.uid()) OR e.created_by = auth.uid() OR private.is_super(auth.uid()))));

-- Questions d'un examen pour l'élève, SANS la réponse correcte.
CREATE OR REPLACE FUNCTION public.questions_examen(p_examen_id uuid)
RETURNS TABLE (id uuid, enonce text, type text, options jsonb, points integer, ordre integer)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public, private
AS $$
BEGIN
  IF auth.uid() IS NULL OR NOT private.peut_voir_examen(auth.uid(), p_examen_id) THEN
    RAISE EXCEPTION 'Examen introuvable';
  END IF;
  RETURN QUERY
    SELECT q.id, q.enonce, q.type, q.options, q.points, q.ordre
    FROM public.questions q
    WHERE q.examen_id = p_examen_id
    ORDER BY q.ordre;
END;
$$;
REVOKE EXECUTE ON FUNCTION public.questions_examen(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.questions_examen(uuid) TO authenticated;

-- Soumission d'une copie : correction, enregistrement du résultat et des XP.
CREATE OR REPLACE FUNCTION public.soumettre_examen(p_examen_id uuid, p_reponses jsonb)
RETURNS TABLE (score numeric, xp integer)
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = public, private
AS $$
DECLARE
  uid uuid := auth.uid();
  ex record;
  total integer := 0;
  obtenu integer := 0;
  note numeric := 0;
  xp_gagne integer := 0;
  q record;
  donnee text;
  nb_concepts integer;
  nb_termines integer;
BEGIN
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Non authentifié';
  END IF;
  IF NOT private.peut_voir_examen(uid, p_examen_id) THEN
    RAISE EXCEPTION 'Examen introuvable';
  END IF;

  SELECT e.id, e.titre, e.statut, e.date_debut, e.date_fin, e.deverrouille_si, e.chapitre_id
    INTO ex FROM public.examens e WHERE e.id = p_examen_id;

  IF ex.statut <> 'publie' THEN
    RAISE EXCEPTION 'Cet examen n''est pas ouvert';
  END IF;
  IF ex.date_debut IS NOT NULL AND now() < ex.date_debut THEN
    RAISE EXCEPTION 'Cet examen n''a pas encore commencé';
  END IF;
  -- Petite marge pour une copie envoyée automatiquement en fin de chrono.
  IF ex.date_fin IS NOT NULL AND now() > ex.date_fin + interval '5 minutes' THEN
    RAISE EXCEPTION 'Cet examen est clos';
  END IF;

  IF ex.deverrouille_si = 'tous_concepts_termines' AND ex.chapitre_id IS NOT NULL THEN
    SELECT count(*) INTO nb_concepts FROM public.concepts c WHERE c.chapitre_id = ex.chapitre_id;
    SELECT count(*) INTO nb_termines
      FROM public.concepts c
      JOIN public.progression_concepts p ON p.concept_id = c.id AND p.eleve_id = uid AND p.termine
      WHERE c.chapitre_id = ex.chapitre_id;
    IF nb_concepts > 0 AND nb_termines < nb_concepts THEN
      RAISE EXCEPTION 'Ce quiz est verrouillé';
    END IF;
  END IF;

  IF EXISTS (SELECT 1 FROM public.resultats_examens r WHERE r.examen_id = p_examen_id AND r.eleve_id = uid) THEN
    RAISE EXCEPTION 'Vous avez déjà passé cet examen';
  END IF;

  FOR q IN SELECT qq.id, qq.reponse_correcte, qq.points FROM public.questions qq WHERE qq.examen_id = p_examen_id LOOP
    total := total + COALESCE(NULLIF(q.points, 0), 1);
    donnee := p_reponses ->> q.id::text;
    IF donnee IS NOT NULL AND q.reponse_correcte IS NOT NULL
       AND btrim(donnee) = btrim(q.reponse_correcte) THEN
      obtenu := obtenu + COALESCE(NULLIF(q.points, 0), 1);
    END IF;
  END LOOP;

  IF total > 0 THEN
    note := round((obtenu::numeric / total) * 20, 2);
  END IF;
  xp_gagne := round(note * 5)::integer;

  INSERT INTO public.resultats_examens (examen_id, eleve_id, score, reponses)
  VALUES (p_examen_id, uid, note, COALESCE(p_reponses, '{}'::jsonb));

  IF xp_gagne > 0 THEN
    INSERT INTO public.xp_transactions (profile_id, montant, source, description)
    VALUES (uid, xp_gagne, 'examen', ex.titre);
    UPDATE public.profiles SET xp_total = xp_total + xp_gagne WHERE profiles.id = uid;
  END IF;

  RETURN QUERY SELECT note, xp_gagne;
END;
$$;
REVOKE EXECUTE ON FUNCTION public.soumettre_examen(uuid, jsonb) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.soumettre_examen(uuid, jsonb) TO authenticated;

-- Les élèves n'écrivent plus eux-mêmes leurs résultats ni leurs XP.
DROP POLICY IF EXISTS "Eleve enregistre son resultat" ON public.resultats_examens;
DROP POLICY IF EXISTS "XP personnel ajoute" ON public.xp_transactions;

DROP POLICY IF EXISTS "Enseignant corrige un resultat" ON public.resultats_examens;
CREATE POLICY "Enseignant corrige un resultat" ON public.resultats_examens FOR UPDATE TO authenticated
  USING (private.is_teacher(auth.uid()) AND EXISTS (
    SELECT 1 FROM public.examens e WHERE e.id = examen_id
      AND (e.etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid()))))
  WITH CHECK (private.is_teacher(auth.uid()) AND EXISTS (
    SELECT 1 FROM public.examens e WHERE e.id = examen_id
      AND (e.etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid()))));

-- ---------------------------------------------------------------------------
-- 4. Chapitres et concepts : limités à l'établissement de l'enseignant
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "Enseignants gerent les chapitres" ON public.chapitres;
CREATE POLICY "Enseignants gerent les chapitres" ON public.chapitres FOR ALL TO authenticated
  USING (private.is_teacher(auth.uid()) AND EXISTS (
    SELECT 1 FROM public.programmes p WHERE p.id = programme_id
      AND (p.etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid()))))
  WITH CHECK (private.is_teacher(auth.uid()) AND EXISTS (
    SELECT 1 FROM public.programmes p WHERE p.id = programme_id
      AND (p.etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid()))));

DROP POLICY IF EXISTS "Enseignants gerent les concepts" ON public.concepts;
CREATE POLICY "Enseignants gerent les concepts" ON public.concepts FOR ALL TO authenticated
  USING (private.is_teacher(auth.uid()) AND EXISTS (
    SELECT 1 FROM public.chapitres c JOIN public.programmes p ON p.id = c.programme_id
    WHERE c.id = chapitre_id
      AND (p.etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid()))))
  WITH CHECK (private.is_teacher(auth.uid()) AND EXISTS (
    SELECT 1 FROM public.chapitres c JOIN public.programmes p ON p.id = c.programme_id
    WHERE c.id = chapitre_id
      AND (p.etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid()))));
