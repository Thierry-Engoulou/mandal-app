-- ============================================================================
-- Base de connaissances « Orientation » (réalité camerounaise)
-- ============================================================================
-- Fiches Filières, Métiers et Questions fréquentes, chacune avec ses
-- références (sources). Elles alimentent les pages Filières / Métiers et sont
-- fournies à Mandal IA (recherche plein texte) pour des réponses sourcées.
-- Le contenu est chargé par la migration suivante (seed) ; les
-- administrateurs peuvent ensuite ajouter ou corriger des fiches.
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS extensions;
CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA extensions;

-- unaccent n'est pas IMMUTABLE : enveloppe pour pouvoir l'indexer.
CREATE OR REPLACE FUNCTION private.sans_accents(_t text)
RETURNS text LANGUAGE sql IMMUTABLE PARALLEL SAFE SET search_path = extensions, public AS $$
  SELECT extensions.unaccent('extensions.unaccent'::regdictionary, coalesce(_t, ''))
$$;
GRANT EXECUTE ON FUNCTION private.sans_accents(text) TO authenticated, anon;

-- array_to_string n'est pas IMMUTABLE non plus (pour text[], le résultat est stable).
CREATE OR REPLACE FUNCTION private.joindre_mots(_mots text[])
RETURNS text LANGUAGE sql IMMUTABLE PARALLEL SAFE AS $$
  SELECT coalesce(array_to_string(_mots, ' '), '')
$$;
GRANT EXECUTE ON FUNCTION private.joindre_mots(text[]) TO authenticated, anon;

CREATE TABLE IF NOT EXISTS public.orientation_fiches (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  type text NOT NULL CHECK (type IN ('filiere', 'metier', 'faq')),
  titre text NOT NULL,
  categorie text NOT NULL,
  niveau_acces text,
  resume text NOT NULL,
  contenu text NOT NULL,
  debouches text[] NOT NULL DEFAULT '{}',
  formations text[] NOT NULL DEFAULT '{}',
  mots_cles text[] NOT NULL DEFAULT '{}',
  -- [{ "titre": "...", "url": "https://..." }] ; url facultative.
  sources jsonb NOT NULL DEFAULT '[]'::jsonb,
  mis_a_jour date NOT NULL DEFAULT current_date,
  created_at timestamptz NOT NULL DEFAULT now(),
  recherche tsvector GENERATED ALWAYS AS (
    setweight(to_tsvector('french'::regconfig, private.sans_accents(titre)), 'A') ||
    setweight(to_tsvector('french'::regconfig, private.sans_accents(private.joindre_mots(mots_cles))), 'A') ||
    setweight(to_tsvector('french'::regconfig, private.sans_accents(categorie || ' ' || resume)), 'B') ||
    setweight(to_tsvector('french'::regconfig, private.sans_accents(contenu)), 'C')
  ) STORED
);
CREATE INDEX IF NOT EXISTS orientation_fiches_recherche_idx
  ON public.orientation_fiches USING gin (recherche);
CREATE INDEX IF NOT EXISTS orientation_fiches_type_idx
  ON public.orientation_fiches (type, categorie);

GRANT SELECT ON public.orientation_fiches TO authenticated, anon;
GRANT INSERT, UPDATE, DELETE ON public.orientation_fiches TO authenticated;
GRANT ALL ON public.orientation_fiches TO service_role;
ALTER TABLE public.orientation_fiches ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Fiches orientation lisibles" ON public.orientation_fiches;
CREATE POLICY "Fiches orientation lisibles" ON public.orientation_fiches FOR SELECT
  TO authenticated, anon USING (true);
DROP POLICY IF EXISTS "Admins gerent les fiches orientation" ON public.orientation_fiches;
CREATE POLICY "Admins gerent les fiches orientation" ON public.orientation_fiches FOR ALL
  TO authenticated USING (private.is_super(auth.uid())) WITH CHECK (private.is_super(auth.uid()));

-- Recherche plein texte (sans accents, mots en OU) des fiches les plus pertinentes.
CREATE OR REPLACE FUNCTION public.rechercher_fiches_orientation(
  p_question text, p_limite integer DEFAULT 6, p_type text DEFAULT NULL
)
RETURNS SETOF public.orientation_fiches
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, private
AS $$
  WITH q AS (
    SELECT to_tsquery('simple', string_agg(quote_literal(lexeme), ' | ')) AS tsq
    FROM unnest(to_tsvector('french'::regconfig, private.sans_accents(p_question)))
  )
  SELECT f.*
  FROM public.orientation_fiches f, q
  WHERE q.tsq IS NOT NULL
    AND f.recherche @@ q.tsq
    AND (p_type IS NULL OR f.type = p_type)
  ORDER BY ts_rank_cd(f.recherche, q.tsq) DESC, f.titre
  LIMIT LEAST(GREATEST(p_limite, 1), 20)
$$;
GRANT EXECUTE ON FUNCTION public.rechercher_fiches_orientation(text, integer, text)
  TO authenticated, anon;
