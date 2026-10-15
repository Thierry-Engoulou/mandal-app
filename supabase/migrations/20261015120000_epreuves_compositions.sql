-- ============================================================================
-- Épreuves chargées par les enseignants (PDF) et compositions chronométrées
-- ============================================================================
-- - L'enseignant charge le sujet en PDF (bucket privé « epreuves ») avec la
--   matière, le niveau, la classe (facultative), la durée et les dates.
-- - L'élève démarre l'épreuve : le chronomètre est fixé côté serveur
--   (fin_prevue_at). Il envoie ses pages (photos / PDF) au fur et à mesure
--   dans le bucket privé « compositions » ; tout ce qui est envoyé est acquis.
-- - Après la fin, un délai de numérisation (15 min) permet d'envoyer les
--   dernières photos ; ensuite la copie est verrouillée et considérée rendue.
-- - L'enseignant note et commente ; la pré-correction Mandal IA n'est visible
--   que de lui.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Buckets
-- ---------------------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('epreuves', 'epreuves', false, 20971520,
        ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('compositions', 'compositions', false, 15728640,
        ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif', 'application/pdf'])
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.epreuves (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  enseignant_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  titre text NOT NULL,
  matiere text NOT NULL,
  niveau text NOT NULL,
  classe_id uuid REFERENCES public.classes(id) ON DELETE SET NULL,
  consignes text,
  fichier_path text NOT NULL,
  duree_minutes integer NOT NULL CHECK (duree_minutes BETWEEN 5 AND 600),
  date_debut timestamptz,
  date_fin timestamptz,
  statut text NOT NULL DEFAULT 'publiee' CHECK (statut IN ('brouillon', 'publiee', 'archivee')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (date_fin IS NULL OR date_debut IS NULL OR date_fin > date_debut)
);
CREATE INDEX IF NOT EXISTS epreuves_niveau_idx ON public.epreuves (niveau, statut);
CREATE INDEX IF NOT EXISTS epreuves_enseignant_idx ON public.epreuves (enseignant_id);

DROP TRIGGER IF EXISTS trg_epreuves_updated ON public.epreuves;
CREATE TRIGGER trg_epreuves_updated BEFORE UPDATE ON public.epreuves
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE IF NOT EXISTS public.compositions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  epreuve_id uuid NOT NULL REFERENCES public.epreuves(id) ON DELETE CASCADE,
  eleve_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  debut_at timestamptz NOT NULL DEFAULT now(),
  fin_prevue_at timestamptz NOT NULL,
  rendu_at timestamptz,
  rendu_auto boolean NOT NULL DEFAULT false,
  fichiers text[] NOT NULL DEFAULT '{}',
  note numeric CHECK (note IS NULL OR (note >= 0 AND note <= 20)),
  commentaire text,
  corrige_at timestamptz,
  UNIQUE (epreuve_id, eleve_id)
);
CREATE INDEX IF NOT EXISTS compositions_eleve_idx ON public.compositions (eleve_id);

-- Pré-correction Mandal IA : réservée à l'enseignant (table séparée pour que
-- l'élève ne la voie pas avant la note officielle).
CREATE TABLE IF NOT EXISTS public.compositions_correction_ia (
  composition_id uuid PRIMARY KEY REFERENCES public.compositions(id) ON DELETE CASCADE,
  texte text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Délai de numérisation après la fin du chronomètre.
CREATE OR REPLACE FUNCTION private.delai_numerisation()
RETURNS interval LANGUAGE sql IMMUTABLE AS $$ SELECT interval '15 minutes' $$;

-- Un utilisateur peut-il voir cette épreuve ?
CREATE OR REPLACE FUNCTION private.peut_voir_epreuve(_user_id uuid, _epreuve_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = private, public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.epreuves e
    WHERE e.id = _epreuve_id
      AND (
        e.enseignant_id = _user_id
        OR private.is_super(_user_id)
        OR (
          e.statut = 'publiee'
          AND (
            e.classe_id IS NULL
            OR EXISTS (SELECT 1 FROM public.class_membres m WHERE m.class_id = e.classe_id AND m.eleve_id = _user_id)
            OR EXISTS (SELECT 1 FROM public.classes c WHERE c.id = e.classe_id
                       AND (c.enseignant_id = _user_id OR private.is_chef(_user_id, c.etablissement_id)))
          )
        )
      )
  )
$$;

CREATE OR REPLACE FUNCTION private.est_auteur_epreuve(_user_id uuid, _epreuve_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = private, public AS $$
  SELECT EXISTS (SELECT 1 FROM public.epreuves e WHERE e.id = _epreuve_id
                 AND (e.enseignant_id = _user_id OR private.is_super(_user_id)))
$$;

GRANT EXECUTE ON FUNCTION private.delai_numerisation(), private.peut_voir_epreuve(uuid, uuid),
  private.est_auteur_epreuve(uuid, uuid) TO authenticated;

-- ---------------------------------------------------------------------------
-- RLS : épreuves
-- ---------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON public.epreuves TO authenticated;
GRANT ALL ON public.epreuves TO service_role;
ALTER TABLE public.epreuves ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Epreuves visibles" ON public.epreuves;
CREATE POLICY "Epreuves visibles" ON public.epreuves FOR SELECT TO authenticated
  USING (private.peut_voir_epreuve(auth.uid(), id));

DROP POLICY IF EXISTS "Enseignant cree ses epreuves" ON public.epreuves;
CREATE POLICY "Enseignant cree ses epreuves" ON public.epreuves FOR INSERT TO authenticated
  WITH CHECK (
    enseignant_id = auth.uid() AND private.is_teacher(auth.uid())
    AND (classe_id IS NULL OR EXISTS (
      SELECT 1 FROM public.classes c WHERE c.id = classe_id
        AND (c.enseignant_id = auth.uid() OR private.is_chef(auth.uid(), c.etablissement_id))))
  );

DROP POLICY IF EXISTS "Enseignant gere ses epreuves" ON public.epreuves;
CREATE POLICY "Enseignant gere ses epreuves" ON public.epreuves FOR UPDATE TO authenticated
  USING (enseignant_id = auth.uid() OR private.is_super(auth.uid()))
  WITH CHECK (
    (enseignant_id = auth.uid() OR private.is_super(auth.uid()))
    AND (classe_id IS NULL OR EXISTS (
      SELECT 1 FROM public.classes c WHERE c.id = classe_id
        AND (c.enseignant_id = auth.uid() OR private.is_chef(auth.uid(), c.etablissement_id))))
  );

DROP POLICY IF EXISTS "Enseignant supprime ses epreuves" ON public.epreuves;
CREATE POLICY "Enseignant supprime ses epreuves" ON public.epreuves FOR DELETE TO authenticated
  USING (enseignant_id = auth.uid() OR private.is_super(auth.uid()));

-- ---------------------------------------------------------------------------
-- RLS : compositions (écritures uniquement via les fonctions ci-dessous)
-- ---------------------------------------------------------------------------
GRANT SELECT ON public.compositions TO authenticated;
GRANT ALL ON public.compositions TO service_role;
ALTER TABLE public.compositions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Compositions visibles" ON public.compositions;
CREATE POLICY "Compositions visibles" ON public.compositions FOR SELECT TO authenticated
  USING (eleve_id = auth.uid() OR private.est_auteur_epreuve(auth.uid(), epreuve_id));

GRANT SELECT ON public.compositions_correction_ia TO authenticated;
GRANT ALL ON public.compositions_correction_ia TO service_role;
ALTER TABLE public.compositions_correction_ia ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Pre-correction visible par l enseignant" ON public.compositions_correction_ia;
CREATE POLICY "Pre-correction visible par l enseignant" ON public.compositions_correction_ia
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.compositions c WHERE c.id = composition_id
                 AND private.est_auteur_epreuve(auth.uid(), c.epreuve_id)));

-- ---------------------------------------------------------------------------
-- Fonctions de composition (élève)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.commencer_composition(p_epreuve_id uuid)
RETURNS public.compositions
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = public, private
AS $$
DECLARE
  uid uuid := auth.uid();
  e record;
  c public.compositions;
BEGIN
  IF uid IS NULL OR NOT private.peut_voir_epreuve(uid, p_epreuve_id) THEN
    RAISE EXCEPTION 'Épreuve introuvable';
  END IF;

  SELECT * INTO c FROM public.compositions WHERE epreuve_id = p_epreuve_id AND eleve_id = uid;
  IF FOUND THEN
    RETURN c;
  END IF;

  SELECT * INTO e FROM public.epreuves WHERE id = p_epreuve_id;
  IF e.statut <> 'publiee' THEN
    RAISE EXCEPTION 'Cette épreuve n''est pas ouverte';
  END IF;
  IF e.date_debut IS NOT NULL AND now() < e.date_debut THEN
    RAISE EXCEPTION 'Cette épreuve n''a pas encore commencé';
  END IF;
  IF e.date_fin IS NOT NULL AND now() >= e.date_fin THEN
    RAISE EXCEPTION 'Cette épreuve est terminée';
  END IF;

  INSERT INTO public.compositions (epreuve_id, eleve_id, debut_at, fin_prevue_at)
  VALUES (
    p_epreuve_id, uid, now(),
    CASE WHEN e.date_fin IS NULL THEN now() + make_interval(mins => e.duree_minutes)
         ELSE LEAST(now() + make_interval(mins => e.duree_minutes), e.date_fin) END
  )
  RETURNING * INTO c;
  RETURN c;
END;
$$;

-- Vérifie que la composition appartient à l'élève et accepte encore des pages.
CREATE OR REPLACE FUNCTION private.composition_ouverte(_composition_id uuid)
RETURNS public.compositions
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public, private
AS $$
DECLARE
  c public.compositions;
BEGIN
  SELECT * INTO c FROM public.compositions WHERE id = _composition_id AND eleve_id = auth.uid();
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Composition introuvable';
  END IF;
  IF c.rendu_at IS NOT NULL THEN
    RAISE EXCEPTION 'Copie déjà rendue';
  END IF;
  IF now() > c.fin_prevue_at + private.delai_numerisation() THEN
    RAISE EXCEPTION 'Le temps est écoulé : la copie a été transmise';
  END IF;
  RETURN c;
END;
$$;

CREATE OR REPLACE FUNCTION public.ajouter_page_composition(p_composition_id uuid, p_path text)
RETURNS text[]
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = public, private
AS $$
DECLARE
  c public.compositions := private.composition_ouverte(p_composition_id);
  res text[];
BEGIN
  IF p_path IS NULL OR p_path NOT LIKE c.epreuve_id::text || '/' || c.eleve_id::text || '/%'
     OR p_path LIKE '%..%' THEN
    RAISE EXCEPTION 'Fichier non autorisé';
  END IF;
  IF array_length(c.fichiers, 1) >= 20 THEN
    RAISE EXCEPTION '20 pages maximum';
  END IF;
  UPDATE public.compositions
    SET fichiers = CASE WHEN p_path = ANY (fichiers) THEN fichiers ELSE array_append(fichiers, p_path) END
    WHERE id = c.id
    RETURNING fichiers INTO res;
  RETURN res;
END;
$$;

CREATE OR REPLACE FUNCTION public.retirer_page_composition(p_composition_id uuid, p_path text)
RETURNS text[]
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = public, private
AS $$
DECLARE
  c public.compositions := private.composition_ouverte(p_composition_id);
  res text[];
BEGIN
  UPDATE public.compositions SET fichiers = array_remove(fichiers, p_path)
    WHERE id = c.id RETURNING fichiers INTO res;
  RETURN res;
END;
$$;

CREATE OR REPLACE FUNCTION public.rendre_composition(p_composition_id uuid)
RETURNS public.compositions
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = public, private
AS $$
DECLARE
  c public.compositions;
BEGIN
  SELECT * INTO c FROM public.compositions WHERE id = p_composition_id AND eleve_id = auth.uid();
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Composition introuvable';
  END IF;
  IF c.rendu_at IS NULL THEN
    UPDATE public.compositions
      SET rendu_at = LEAST(now(), fin_prevue_at + private.delai_numerisation()),
          rendu_auto = now() > fin_prevue_at
      WHERE id = c.id
      RETURNING * INTO c;
  END IF;
  RETURN c;
END;
$$;

-- ---------------------------------------------------------------------------
-- Fonctions enseignant
-- ---------------------------------------------------------------------------
-- Copies d'une épreuve avec le nom de l'élève (les profils d'élèves d'autres
-- établissements ne sont pas lisibles directement par l'enseignant).
CREATE OR REPLACE FUNCTION public.copies_epreuve(p_epreuve_id uuid)
RETURNS TABLE (
  id uuid, eleve_id uuid, eleve_nom text, debut_at timestamptz, fin_prevue_at timestamptz,
  rendu_at timestamptz, rendu_auto boolean, fichiers text[], note numeric, commentaire text,
  corrige_at timestamptz, a_correction_ia boolean
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public, private
AS $$
BEGIN
  IF NOT private.est_auteur_epreuve(auth.uid(), p_epreuve_id) THEN
    RAISE EXCEPTION 'Épreuve introuvable';
  END IF;
  RETURN QUERY
    SELECT c.id, c.eleve_id,
           COALESCE(NULLIF(trim(concat_ws(' ', p.prenom, p.nom)), ''), p.full_name, 'Élève'),
           c.debut_at, c.fin_prevue_at, c.rendu_at, c.rendu_auto, c.fichiers, c.note,
           c.commentaire, c.corrige_at,
           EXISTS (SELECT 1 FROM public.compositions_correction_ia x WHERE x.composition_id = c.id)
    FROM public.compositions c
    JOIN public.profiles p ON p.id = c.eleve_id
    WHERE c.epreuve_id = p_epreuve_id
    ORDER BY c.debut_at;
END;
$$;

CREATE OR REPLACE FUNCTION public.noter_composition(
  p_composition_id uuid, p_note numeric, p_commentaire text
)
RETURNS void
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = public, private
AS $$
DECLARE
  c public.compositions;
BEGIN
  SELECT * INTO c FROM public.compositions WHERE id = p_composition_id;
  IF NOT FOUND OR NOT private.est_auteur_epreuve(auth.uid(), c.epreuve_id) THEN
    RAISE EXCEPTION 'Composition introuvable';
  END IF;
  IF p_note IS NOT NULL AND (p_note < 0 OR p_note > 20) THEN
    RAISE EXCEPTION 'La note doit être comprise entre 0 et 20';
  END IF;
  UPDATE public.compositions
    SET note = p_note, commentaire = NULLIF(trim(p_commentaire), ''),
        corrige_at = CASE WHEN p_note IS NULL THEN NULL ELSE now() END
    WHERE id = c.id;
END;
$$;

CREATE OR REPLACE FUNCTION public.enregistrer_correction_ia(p_composition_id uuid, p_texte text)
RETURNS void
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = public, private
AS $$
DECLARE
  c public.compositions;
BEGIN
  SELECT * INTO c FROM public.compositions WHERE id = p_composition_id;
  IF NOT FOUND OR NOT private.est_auteur_epreuve(auth.uid(), c.epreuve_id) THEN
    RAISE EXCEPTION 'Composition introuvable';
  END IF;
  INSERT INTO public.compositions_correction_ia (composition_id, texte)
  VALUES (c.id, p_texte)
  ON CONFLICT (composition_id) DO UPDATE SET texte = EXCLUDED.texte, created_at = now();
END;
$$;

REVOKE EXECUTE ON FUNCTION public.commencer_composition(uuid), public.ajouter_page_composition(uuid, text),
  public.retirer_page_composition(uuid, text), public.rendre_composition(uuid),
  public.copies_epreuve(uuid), public.noter_composition(uuid, numeric, text),
  public.enregistrer_correction_ia(uuid, text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.commencer_composition(uuid), public.ajouter_page_composition(uuid, text),
  public.retirer_page_composition(uuid, text), public.rendre_composition(uuid),
  public.copies_epreuve(uuid), public.noter_composition(uuid, numeric, text),
  public.enregistrer_correction_ia(uuid, text) TO authenticated;

-- ---------------------------------------------------------------------------
-- Stockage
-- ---------------------------------------------------------------------------
-- Sujets : l'enseignant dépose dans son dossier ; lecture si l'épreuve est visible.
DROP POLICY IF EXISTS "epreuves depot" ON storage.objects;
CREATE POLICY "epreuves depot" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'epreuves' AND (storage.foldername(name))[1] = auth.uid()::text
              AND private.is_teacher(auth.uid()));
DROP POLICY IF EXISTS "epreuves lecture" ON storage.objects;
CREATE POLICY "epreuves lecture" ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'epreuves' AND (
    (storage.foldername(name))[1] = auth.uid()::text
    OR EXISTS (SELECT 1 FROM public.epreuves e WHERE e.fichier_path = name
               AND private.peut_voir_epreuve(auth.uid(), e.id))));
DROP POLICY IF EXISTS "epreuves suppression" ON storage.objects;
CREATE POLICY "epreuves suppression" ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'epreuves' AND (storage.foldername(name))[1] = auth.uid()::text);

-- Copies : <epreuve_id>/<eleve_id>/fichier ; dépôt tant que la composition est ouverte.
DROP POLICY IF EXISTS "compositions depot" ON storage.objects;
CREATE POLICY "compositions depot" ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'compositions' AND (storage.foldername(name))[2] = auth.uid()::text
    AND EXISTS (SELECT 1 FROM public.compositions c
                WHERE c.epreuve_id::text = (storage.foldername(name))[1]
                  AND c.eleve_id = auth.uid() AND c.rendu_at IS NULL
                  AND now() <= c.fin_prevue_at + private.delai_numerisation()));
DROP POLICY IF EXISTS "compositions lecture" ON storage.objects;
CREATE POLICY "compositions lecture" ON storage.objects FOR SELECT TO authenticated
  USING (bucket_id = 'compositions' AND (
    (storage.foldername(name))[2] = auth.uid()::text
    OR EXISTS (SELECT 1 FROM public.epreuves e WHERE e.id::text = (storage.foldername(name))[1]
               AND (e.enseignant_id = auth.uid() OR private.is_super(auth.uid())))));
DROP POLICY IF EXISTS "compositions suppression" ON storage.objects;
CREATE POLICY "compositions suppression" ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'compositions' AND (storage.foldername(name))[2] = auth.uid()::text
    AND EXISTS (SELECT 1 FROM public.compositions c
                WHERE c.epreuve_id::text = (storage.foldername(name))[1]
                  AND c.eleve_id = auth.uid() AND c.rendu_at IS NULL
                  AND now() <= c.fin_prevue_at + private.delai_numerisation()));
