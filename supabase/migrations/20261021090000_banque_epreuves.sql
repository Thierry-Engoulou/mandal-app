-- ============================================================================
-- Banque d'épreuves (annales) : sujets d'examens et de devoirs à consulter et
-- télécharger, avec corrigé facultatif.
-- ============================================================================
-- - Les enseignants déposent ; un administrateur valide avant publication.
--   Les dépôts des administrateurs sont publiés directement.
-- - Tout le monde (même sans compte) voit et télécharge les épreuves PUBLIÉES,
--   via des liens temporaires : le bucket reste privé, un fichier en attente
--   de validation n'est jamais accessible au public.
-- - Une épreuve = un fichier (PDF ; les photos sont regroupées en PDF par le
--   navigateur avant l'envoi) + un corrigé facultatif.
-- ============================================================================

-- Fonctions de recherche sans accents (déjà créées par la base d'orientation ;
-- répétées ici pour que cette migration fonctionne seule).
CREATE SCHEMA IF NOT EXISTS extensions;
CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA extensions;
-- Le calcul de la colonne de recherche se fait avec les droits de l'appelant
-- (un enseignant qui dépose) : accès au schéma extensions (défaut Supabase).
GRANT USAGE ON SCHEMA extensions TO anon, authenticated;
CREATE OR REPLACE FUNCTION private.sans_accents(_t text)
RETURNS text LANGUAGE sql IMMUTABLE PARALLEL SAFE SET search_path = extensions, public AS $$
  SELECT extensions.unaccent('extensions.unaccent'::regdictionary, coalesce(_t, ''))
$$;

-- ---------------------------------------------------------------------------
-- Bucket (privé, 25 Mo par fichier)
-- ---------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('banque-epreuves', 'banque-epreuves', false, 26214400,
        ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Table
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.banque_epreuves (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  titre text NOT NULL CHECK (char_length(titre) BETWEEN 3 AND 200),
  matiere text NOT NULL,
  classe text NOT NULL,
  serie text,
  type_examen text NOT NULL,
  annee integer CHECK (annee BETWEEN 1960 AND 2100),
  session text,
  -- Origine du sujet : « Office du Baccalauréat du Cameroun », « Lycée de … »
  source text,
  description text,
  fichier_path text NOT NULL,
  corrige_path text,
  statut text NOT NULL DEFAULT 'en_attente'
    CHECK (statut IN ('en_attente', 'publiee', 'rejetee')),
  motif_rejet text,
  depose_par uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  valide_par uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  valide_at timestamptz,
  telechargements integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  recherche tsvector GENERATED ALWAYS AS (
    to_tsvector('simple'::regconfig, private.sans_accents(
      titre || ' ' || matiere || ' ' || classe || ' ' || coalesce(serie, '') || ' ' ||
      type_examen || ' ' || coalesce(annee::text, '') || ' ' || coalesce(session, '') || ' ' ||
      coalesce(source, '') || ' ' || coalesce(description, '')))
  ) STORED
);
CREATE INDEX IF NOT EXISTS banque_epreuves_recherche_idx
  ON public.banque_epreuves USING gin (recherche);
CREATE INDEX IF NOT EXISTS banque_epreuves_filtres_idx
  ON public.banque_epreuves (statut, matiere, classe, type_examen, annee DESC);
CREATE INDEX IF NOT EXISTS banque_epreuves_depose_par_idx
  ON public.banque_epreuves (depose_par);

DROP TRIGGER IF EXISTS trg_banque_epreuves_updated ON public.banque_epreuves;
CREATE TRIGGER trg_banque_epreuves_updated BEFORE UPDATE ON public.banque_epreuves
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Garde-fou : un utilisateur ne peut ni se publier lui-même, ni usurper
-- l'auteur, ni gonfler le compteur. SECURITY INVOKER volontaire : current_user
-- vaut le rôle appelant (les scripts service_role / postgres ne sont pas bridés).
CREATE OR REPLACE FUNCTION private.banque_epreuves_garde()
RETURNS trigger LANGUAGE plpgsql SET search_path = private, public AS $$
DECLARE
  admin boolean;
BEGIN
  IF current_user NOT IN ('authenticated', 'anon') THEN
    RETURN NEW;
  END IF;
  admin := private.is_super(auth.uid());

  IF TG_OP = 'INSERT' THEN
    NEW.depose_par := auth.uid();
    NEW.telechargements := 0;
    IF admin THEN
      NEW.statut := coalesce(NEW.statut, 'publiee');
    ELSE
      NEW.statut := 'en_attente';
    END IF;
  ELSE
    NEW.depose_par := OLD.depose_par;
    NEW.telechargements := OLD.telechargements;
    IF NOT admin THEN
      -- Toute modification par l'auteur renvoie l'épreuve en validation.
      NEW.statut := 'en_attente';
    END IF;
  END IF;

  IF NEW.statut = 'publiee' AND (TG_OP = 'INSERT' OR OLD.statut IS DISTINCT FROM 'publiee') THEN
    NEW.valide_par := auth.uid();
    NEW.valide_at := now();
    NEW.motif_rejet := NULL;
  ELSIF NEW.statut <> 'publiee' THEN
    NEW.valide_par := NULL;
    NEW.valide_at := NULL;
    IF NEW.statut = 'en_attente' THEN
      NEW.motif_rejet := NULL;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_banque_epreuves_garde ON public.banque_epreuves;
CREATE TRIGGER trg_banque_epreuves_garde BEFORE INSERT OR UPDATE ON public.banque_epreuves
  FOR EACH ROW EXECUTE FUNCTION private.banque_epreuves_garde();

-- ---------------------------------------------------------------------------
-- Droits et RLS
-- ---------------------------------------------------------------------------
GRANT SELECT ON public.banque_epreuves TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.banque_epreuves TO authenticated;
GRANT ALL ON public.banque_epreuves TO service_role;
ALTER TABLE public.banque_epreuves ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Banque publique" ON public.banque_epreuves;
CREATE POLICY "Banque publique" ON public.banque_epreuves FOR SELECT TO anon
  USING (statut = 'publiee');
DROP POLICY IF EXISTS "Banque lecture" ON public.banque_epreuves;
CREATE POLICY "Banque lecture" ON public.banque_epreuves FOR SELECT TO authenticated
  USING (statut = 'publiee' OR depose_par = auth.uid() OR private.is_super(auth.uid()));
DROP POLICY IF EXISTS "Banque depot" ON public.banque_epreuves;
CREATE POLICY "Banque depot" ON public.banque_epreuves FOR INSERT TO authenticated
  WITH CHECK (private.is_teacher(auth.uid()));
DROP POLICY IF EXISTS "Banque modification" ON public.banque_epreuves;
CREATE POLICY "Banque modification" ON public.banque_epreuves FOR UPDATE TO authenticated
  USING (private.is_super(auth.uid()) OR (depose_par = auth.uid() AND statut <> 'publiee'))
  WITH CHECK (private.is_super(auth.uid()) OR depose_par = auth.uid());
DROP POLICY IF EXISTS "Banque suppression" ON public.banque_epreuves;
CREATE POLICY "Banque suppression" ON public.banque_epreuves FOR DELETE TO authenticated
  USING (private.is_super(auth.uid()) OR (depose_par = auth.uid() AND statut <> 'publiee'));

-- ---------------------------------------------------------------------------
-- Recherche (publiées uniquement) : mots en ET (ou en OU avec p_mode = 'ou'),
-- préfixes acceptés (« math » trouve « mathématiques »), filtres facultatifs.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.rechercher_banque_epreuves(
  p_texte text DEFAULT NULL,
  p_matiere text DEFAULT NULL,
  p_classe text DEFAULT NULL,
  p_type text DEFAULT NULL,
  p_annee integer DEFAULT NULL,
  p_limite integer DEFAULT 24,
  p_offset integer DEFAULT 0,
  p_mode text DEFAULT 'et'
)
RETURNS SETOF public.banque_epreuves
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, private AS $$
  WITH mots AS (
    -- « maths » doit trouver « mathématiques » : on retire le s final.
    SELECT DISTINCT CASE WHEN char_length(m[1]) > 3 THEN regexp_replace(m[1], 's$', '') ELSE m[1] END AS mot
    FROM regexp_matches(lower(private.sans_accents(coalesce(p_texte, ''))), '([a-z0-9]{2,})', 'g') AS m
  ), q AS (
    SELECT to_tsquery('simple', string_agg(quote_literal(mot) || ':*',
                                           CASE WHEN p_mode = 'ou' THEN ' | ' ELSE ' & ' END)) AS tsq
    FROM mots
  )
  SELECT b.*
  FROM public.banque_epreuves b, q
  WHERE b.statut = 'publiee'
    AND (q.tsq IS NULL OR b.recherche @@ q.tsq)
    AND (p_matiere IS NULL OR b.matiere = p_matiere)
    AND (p_classe IS NULL OR b.classe = p_classe)
    AND (p_type IS NULL OR b.type_examen = p_type)
    AND (p_annee IS NULL OR b.annee = p_annee)
  ORDER BY
    CASE WHEN q.tsq IS NULL THEN 0 ELSE ts_rank(b.recherche, q.tsq) END DESC,
    b.annee DESC NULLS LAST, b.created_at DESC
  LIMIT LEAST(GREATEST(p_limite, 1), 100) OFFSET GREATEST(p_offset, 0)
$$;
GRANT EXECUTE ON FUNCTION public.rechercher_banque_epreuves(text, text, text, text, integer, integer, integer, text)
  TO anon, authenticated;

-- Compteur de téléchargements (épreuves publiées uniquement).
CREATE OR REPLACE FUNCTION public.compter_telechargement_epreuve(p_id uuid)
RETURNS void LANGUAGE sql SECURITY DEFINER SET search_path = public AS $$
  UPDATE public.banque_epreuves SET telechargements = telechargements + 1
  WHERE id = p_id AND statut = 'publiee'
$$;
GRANT EXECUTE ON FUNCTION public.compter_telechargement_epreuve(uuid) TO anon, authenticated;

-- ---------------------------------------------------------------------------
-- Stockage : <auteur>/<fichier>
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "banque depot" ON storage.objects;
CREATE POLICY "banque depot" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'banque-epreuves' AND (storage.foldername(name))[1] = auth.uid()::text
              AND private.is_teacher(auth.uid()));
DROP POLICY IF EXISTS "banque lecture publique" ON storage.objects;
CREATE POLICY "banque lecture publique" ON storage.objects FOR SELECT TO anon
  USING (bucket_id = 'banque-epreuves' AND EXISTS (
    SELECT 1 FROM public.banque_epreuves b
    WHERE (b.fichier_path = name OR b.corrige_path = name) AND b.statut = 'publiee'));
DROP POLICY IF EXISTS "banque lecture" ON storage.objects;
CREATE POLICY "banque lecture" ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'banque-epreuves' AND (
    (storage.foldername(name))[1] = auth.uid()::text
    OR private.is_super(auth.uid())
    OR EXISTS (SELECT 1 FROM public.banque_epreuves b
               WHERE (b.fichier_path = name OR b.corrige_path = name) AND b.statut = 'publiee')));
DROP POLICY IF EXISTS "banque suppression" ON storage.objects;
CREATE POLICY "banque suppression" ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'banque-epreuves' AND (
    private.is_super(auth.uid())
    OR ((storage.foldername(name))[1] = auth.uid()::text
        AND NOT EXISTS (SELECT 1 FROM public.banque_epreuves b
                        WHERE (b.fichier_path = name OR b.corrige_path = name)
                          AND b.statut = 'publiee'))));
