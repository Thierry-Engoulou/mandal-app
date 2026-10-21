-- ============================================================================
-- Vraies statistiques du site, sécurité des rôles et journal d'administration
-- ============================================================================
-- 1. site_evenements : visites et téléchargements réels, anonymes. Le
--    navigateur tire un identifiant aléatoire (aucune donnée personnelle).
--    Un visiteur compte une fois par page et par jour ; un téléchargement une
--    fois par visiteur, par épreuve et par jour (pas de gonflage en
--    rechargeant la page).
-- 2. Rôles : seul un super admin nomme ou retire un administrateur ou un
--    super admin ; personne ne change son propre rôle ; il reste toujours au
--    moins un super admin.
-- 3. journal_admin : changements de rôle, validations d'épreuves et accès
--    refusés à l'administration.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Statistiques
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.site_evenements (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  type text NOT NULL CHECK (type IN ('visite', 'telechargement')),
  page text NOT NULL DEFAULT '',
  epreuve_id uuid REFERENCES public.banque_epreuves(id) ON DELETE SET NULL,
  visiteur uuid NOT NULL,
  jour date NOT NULL DEFAULT (now() AT TIME ZONE 'Africa/Douala')::date,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS site_evenements_visite_unique
  ON public.site_evenements (visiteur, page, jour) WHERE type = 'visite';
CREATE UNIQUE INDEX IF NOT EXISTS site_evenements_telechargement_unique
  ON public.site_evenements (visiteur, epreuve_id, jour) WHERE type = 'telechargement';
CREATE INDEX IF NOT EXISTS site_evenements_jour_idx ON public.site_evenements (type, jour);

-- Aucun accès direct : uniquement via les fonctions ci-dessous.
ALTER TABLE public.site_evenements ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.site_evenements FROM anon, authenticated;
GRANT ALL ON public.site_evenements TO service_role;

CREATE OR REPLACE FUNCTION public.enregistrer_visite(p_visiteur uuid, p_page text)
RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  INSERT INTO public.site_evenements (type, page, visiteur)
  VALUES ('visite', left(coalesce(p_page, ''), 120), p_visiteur)
  ON CONFLICT DO NOTHING
$$;
GRANT EXECUTE ON FUNCTION public.enregistrer_visite(uuid, text) TO anon, authenticated;

-- Le compteur de la banque n'augmente que pour un nouveau téléchargement.
DROP FUNCTION IF EXISTS public.compter_telechargement_epreuve(uuid);
CREATE OR REPLACE FUNCTION public.compter_telechargement_epreuve(
  p_id uuid, p_visiteur uuid DEFAULT NULL
)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  n integer;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.banque_epreuves WHERE id = p_id AND statut = 'publiee') THEN
    RETURN;
  END IF;
  INSERT INTO public.site_evenements (type, epreuve_id, visiteur)
  VALUES ('telechargement', p_id, coalesce(p_visiteur, gen_random_uuid()))
  ON CONFLICT DO NOTHING;
  GET DIAGNOSTICS n = ROW_COUNT;
  IF n > 0 THEN
    UPDATE public.banque_epreuves SET telechargements = telechargements + 1 WHERE id = p_id;
  END IF;
END;
$$;
GRANT EXECUTE ON FUNCTION public.compter_telechargement_epreuve(uuid, uuid) TO anon, authenticated;

-- Synthèse pour le tableau de bord (administrateurs uniquement).
CREATE OR REPLACE FUNCTION public.statistiques_site()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public, private AS $$
DECLARE
  aujourdhui date := (now() AT TIME ZONE 'Africa/Douala')::date;
BEGIN
  IF NOT private.is_super(auth.uid()) THEN
    RAISE EXCEPTION 'Accès réservé aux administrateurs';
  END IF;
  RETURN jsonb_build_object(
    'depuis', (SELECT min(jour) FROM public.site_evenements),
    'visiteurs_total', (SELECT count(DISTINCT visiteur) FROM public.site_evenements WHERE type = 'visite'),
    'visiteurs_aujourdhui', (SELECT count(DISTINCT visiteur) FROM public.site_evenements
                             WHERE type = 'visite' AND jour = aujourdhui),
    'visiteurs_semaine', (SELECT count(DISTINCT visiteur) FROM public.site_evenements
                          WHERE type = 'visite' AND jour > aujourdhui - 7),
    'pages_vues', (SELECT count(*) FROM public.site_evenements WHERE type = 'visite'),
    'telechargements_total', (SELECT count(*) FROM public.site_evenements WHERE type = 'telechargement'),
    'telechargements_aujourdhui', (SELECT count(*) FROM public.site_evenements
                                   WHERE type = 'telechargement' AND jour = aujourdhui),
    'telechargeurs_total', (SELECT count(DISTINCT visiteur) FROM public.site_evenements
                            WHERE type = 'telechargement'),
    'epreuves_publiees', (SELECT count(*) FROM public.banque_epreuves WHERE statut = 'publiee'),
    'epreuves_en_attente', (SELECT count(*) FROM public.banque_epreuves WHERE statut = 'en_attente'),
    'top_epreuves', coalesce((
      SELECT jsonb_agg(t) FROM (
        SELECT titre, type_examen, telechargements FROM public.banque_epreuves
        WHERE telechargements > 0 ORDER BY telechargements DESC, titre LIMIT 5) t), '[]'::jsonb),
    'top_pages', coalesce((
      SELECT jsonb_agg(t) FROM (
        SELECT page, count(*) AS vues, count(DISTINCT visiteur) AS visiteurs
        FROM public.site_evenements WHERE type = 'visite'
        GROUP BY page ORDER BY count(*) DESC LIMIT 8) t), '[]'::jsonb),
    'par_jour', coalesce((
      SELECT jsonb_agg(t ORDER BY t.jour) FROM (
        SELECT d::date AS jour,
               (SELECT count(DISTINCT visiteur) FROM public.site_evenements
                WHERE type = 'visite' AND jour = d::date) AS visiteurs,
               (SELECT count(*) FROM public.site_evenements
                WHERE type = 'telechargement' AND jour = d::date) AS telechargements
        FROM generate_series(aujourdhui - 13, aujourdhui, interval '1 day') AS d) t), '[]'::jsonb)
  );
END;
$$;
GRANT EXECUTE ON FUNCTION public.statistiques_site() TO authenticated;

-- ---------------------------------------------------------------------------
-- 2. Journal d'administration
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.journal_admin (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  action text NOT NULL,
  acteur uuid,
  cible uuid,
  details jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS journal_admin_created_idx ON public.journal_admin (created_at DESC);
ALTER TABLE public.journal_admin ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.journal_admin FROM anon, authenticated;
GRANT ALL ON public.journal_admin TO service_role;

CREATE OR REPLACE FUNCTION private.journaliser(p_action text, p_cible uuid, p_details jsonb)
RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  INSERT INTO public.journal_admin (action, acteur, cible, details)
  VALUES (p_action, auth.uid(), p_cible, coalesce(p_details, '{}'::jsonb))
$$;

-- Tentative d'accès à l'administration sans les droits.
CREATE OR REPLACE FUNCTION public.signaler_acces_refuse(p_page text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, private AS $$
BEGIN
  IF auth.uid() IS NULL OR private.is_super(auth.uid()) THEN
    RETURN;
  END IF;
  -- Une seule trace par utilisateur et par heure.
  IF EXISTS (SELECT 1 FROM public.journal_admin
             WHERE action = 'acces_refuse' AND acteur = auth.uid()
               AND created_at > now() - interval '1 hour') THEN
    RETURN;
  END IF;
  PERFORM private.journaliser('acces_refuse', auth.uid(),
                              jsonb_build_object('page', left(coalesce(p_page, ''), 120)));
END;
$$;
GRANT EXECUTE ON FUNCTION public.signaler_acces_refuse(text) TO authenticated;

CREATE OR REPLACE FUNCTION public.journal_admin_recent(p_limite integer DEFAULT 30)
RETURNS TABLE (
  created_at timestamptz, action text, acteur_nom text, cible_nom text, details jsonb
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public, private AS $$
BEGIN
  IF NOT private.is_super(auth.uid()) THEN
    RAISE EXCEPTION 'Accès réservé aux administrateurs';
  END IF;
  RETURN QUERY
    SELECT j.created_at, j.action,
           coalesce(pa.full_name, CASE WHEN j.acteur IS NULL THEN 'Console Supabase' ELSE 'Compte supprimé' END),
           coalesce(pc.full_name, j.details->>'titre', ''),
           j.details
    FROM public.journal_admin j
    LEFT JOIN public.profiles pa ON pa.id = j.acteur
    LEFT JOIN public.profiles pc ON pc.id = j.cible
    ORDER BY j.created_at DESC
    LIMIT LEAST(GREATEST(p_limite, 1), 100);
END;
$$;
GRANT EXECUTE ON FUNCTION public.journal_admin_recent(integer) TO authenticated;

-- ---------------------------------------------------------------------------
-- 3. Règles sur les rôles (en plus de trg_profiles_guard)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION private.regles_roles()
RETURNS trigger LANGUAGE plpgsql SECURITY INVOKER SET search_path = private, public AS $$
DECLARE
  role_appelant public.app_role;
BEGIN
  IF NEW.role IS NOT DISTINCT FROM OLD.role THEN
    RETURN NEW;
  END IF;

  -- Depuis le site (rôle authenticated) : règles d'autorisation. La console
  -- SQL, service_role et les fonctions SECURITY DEFINER n'y sont pas soumises.
  IF current_user IN ('authenticated', 'anon') THEN
    IF OLD.id = auth.uid() THEN
      RAISE EXCEPTION 'Vous ne pouvez pas modifier votre propre rôle.';
    END IF;
    SELECT role INTO role_appelant FROM public.profiles WHERE id = auth.uid();
    IF (OLD.role IN ('admin', 'super_admin') OR NEW.role IN ('admin', 'super_admin'))
       AND role_appelant IS DISTINCT FROM 'super_admin' THEN
      RAISE EXCEPTION 'Seul un super administrateur peut nommer ou retirer un administrateur.';
    END IF;
  END IF;

  -- Toujours au moins un super admin (y compris depuis la console SQL).
  IF OLD.role = 'super_admin'
     AND (SELECT count(*) FROM public.profiles WHERE role = 'super_admin') <= 1 THEN
    RAISE EXCEPTION 'Impossible : c''est le dernier super administrateur de la plateforme.';
  END IF;
  RETURN NEW;
END;
$$;
REVOKE EXECUTE ON FUNCTION private.regles_roles() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS trg_profiles_roles ON public.profiles;
CREATE TRIGGER trg_profiles_roles BEFORE UPDATE OF role ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION private.regles_roles();

-- Journal des changements de rôle et de statut.
CREATE OR REPLACE FUNCTION private.journal_profils()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = private, public AS $$
BEGIN
  IF NEW.role IS DISTINCT FROM OLD.role THEN
    PERFORM private.journaliser('role', NEW.id,
      jsonb_build_object('ancien', OLD.role, 'nouveau', NEW.role));
  END IF;
  IF NEW.statut_validation IS DISTINCT FROM OLD.statut_validation THEN
    PERFORM private.journaliser('statut', NEW.id,
      jsonb_build_object('ancien', OLD.statut_validation, 'nouveau', NEW.statut_validation));
  END IF;
  RETURN NULL;
END;
$$;
DROP TRIGGER IF EXISTS trg_profiles_journal ON public.profiles;
CREATE TRIGGER trg_profiles_journal AFTER UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION private.journal_profils();

-- Journal de la banque d'épreuves (validation, refus, retrait, suppression).
CREATE OR REPLACE FUNCTION private.journal_banque()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = private, public AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    PERFORM private.journaliser('epreuve_supprimee', NULL, jsonb_build_object('titre', OLD.titre));
    RETURN NULL;
  END IF;
  IF NEW.statut IS DISTINCT FROM OLD.statut THEN
    PERFORM private.journaliser('epreuve_' || NEW.statut, NULL,
      jsonb_build_object('titre', NEW.titre, 'motif', NEW.motif_rejet));
  END IF;
  RETURN NULL;
END;
$$;
DROP TRIGGER IF EXISTS trg_banque_journal ON public.banque_epreuves;
CREATE TRIGGER trg_banque_journal AFTER UPDATE OR DELETE ON public.banque_epreuves
  FOR EACH ROW EXECUTE FUNCTION private.journal_banque();
