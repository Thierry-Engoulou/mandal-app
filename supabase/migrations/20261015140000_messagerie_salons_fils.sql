-- ============================================================================
-- Messagerie : salons de matière + fils privés par épreuve, avec Mandal IA
-- ============================================================================
-- 1. Salons de matière : tous les élèves et enseignants d'une matière et d'un
--    niveau échangent. Mandal IA répond à la demande.
-- 2. Fil privé par épreuve : l'élève et l'enseignant qui a chargé l'épreuve
--    (questions sur le sujet, signalement d'erreur). Si l'enseignant s'est
--    déclaré indisponible, Mandal IA répond ; elle peut aussi rédiger une
--    correction provisoire de la copie, que l'enseignant vérifie ensuite.
-- Les messages de Mandal IA sont écrits par le serveur (clé service_role) :
-- un utilisateur ne peut pas publier un message au nom de l'IA.
-- ============================================================================

-- Nom affiché d'un utilisateur (les profils d'autres établissements ne sont
-- pas lisibles directement).
CREATE OR REPLACE FUNCTION private.nom_affiche(_user_id uuid)
RETURNS text LANGUAGE sql STABLE SECURITY DEFINER SET search_path = private, public AS $$
  SELECT COALESCE(NULLIF(trim(concat_ws(' ', prenom, nom)), ''), full_name, 'Utilisateur')
  FROM public.profiles WHERE id = _user_id
$$;
GRANT EXECUTE ON FUNCTION private.nom_affiche(uuid) TO authenticated;

-- ---------------------------------------------------------------------------
-- 1. Salons de matière
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.salon_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  matiere text NOT NULL,
  niveau text NOT NULL,
  auteur_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  auteur_nom text NOT NULL,
  auteur_role text NOT NULL CHECK (auteur_role IN ('eleve', 'enseignant', 'ia')),
  demande_par uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  contenu text NOT NULL CHECK (char_length(contenu) BETWEEN 1 AND 8000),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS salon_messages_salon_idx
  ON public.salon_messages (matiere, niveau, created_at DESC);

-- Auteur, rôle et nom fixés par la base pour les messages venant du navigateur.
CREATE OR REPLACE FUNCTION private.salon_message_auteur()
RETURNS trigger LANGUAGE plpgsql SECURITY INVOKER SET search_path = private, public AS $$
BEGIN
  IF current_user IN ('authenticated', 'anon') THEN
    NEW.auteur_id := auth.uid();
    NEW.auteur_role := CASE WHEN private.is_teacher(auth.uid()) THEN 'enseignant' ELSE 'eleve' END;
    NEW.auteur_nom := COALESCE(private.nom_affiche(auth.uid()), 'Utilisateur');
    NEW.demande_par := NULL;
    NEW.created_at := now();
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_salon_message_auteur ON public.salon_messages;
CREATE TRIGGER trg_salon_message_auteur BEFORE INSERT ON public.salon_messages
  FOR EACH ROW EXECUTE FUNCTION private.salon_message_auteur();

GRANT SELECT, INSERT, DELETE ON public.salon_messages TO authenticated;
GRANT ALL ON public.salon_messages TO service_role;
ALTER TABLE public.salon_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Salons lisibles" ON public.salon_messages;
CREATE POLICY "Salons lisibles" ON public.salon_messages FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "Ecrire dans un salon" ON public.salon_messages;
CREATE POLICY "Ecrire dans un salon" ON public.salon_messages FOR INSERT TO authenticated
  WITH CHECK (auth.uid() IS NOT NULL);
-- L'auteur supprime ses messages ; les enseignants modèrent.
DROP POLICY IF EXISTS "Moderer un salon" ON public.salon_messages;
CREATE POLICY "Moderer un salon" ON public.salon_messages FOR DELETE TO authenticated
  USING (auteur_id = auth.uid() OR private.is_teacher(auth.uid()));

-- ---------------------------------------------------------------------------
-- 2. Fils privés par épreuve (tables conversations / messages existantes)
-- ---------------------------------------------------------------------------
ALTER TABLE public.conversations
  ADD COLUMN IF NOT EXISTS epreuve_id uuid REFERENCES public.epreuves(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS eleve_nom text;
CREATE UNIQUE INDEX IF NOT EXISTS conversations_eleve_epreuve_uidx
  ON public.conversations (eleve_id, epreuve_id) WHERE epreuve_id IS NOT NULL;

ALTER TABLE public.messages ALTER COLUMN sender_id DROP NOT NULL;
ALTER TABLE public.messages
  ADD COLUMN IF NOT EXISTS auteur_ia boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS verification text CHECK (verification IN ('valide', 'corrige'));

-- Un message envoyé depuis le navigateur n'est jamais un message de l'IA.
CREATE OR REPLACE FUNCTION private.message_humain()
RETURNS trigger LANGUAGE plpgsql SECURITY INVOKER AS $$
BEGIN
  IF current_user IN ('authenticated', 'anon') THEN
    NEW.auteur_ia := false;
    NEW.verification := NULL;
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_message_humain ON public.messages;
CREATE TRIGGER trg_message_humain BEFORE INSERT ON public.messages
  FOR EACH ROW EXECUTE FUNCTION private.message_humain();

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables
                 WHERE pubname = 'supabase_realtime' AND schemaname = 'public'
                   AND tablename = 'salon_messages') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.salon_messages;
  END IF;
END $$;

-- Ouvre (ou retrouve) le fil privé élève ↔ enseignant d'une épreuve.
CREATE OR REPLACE FUNCTION public.ouvrir_fil_epreuve(p_epreuve_id uuid)
RETURNS uuid
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = public, private
AS $$
DECLARE
  uid uuid := auth.uid();
  e record;
  conv_id uuid;
BEGIN
  IF uid IS NULL OR NOT private.peut_voir_epreuve(uid, p_epreuve_id) THEN
    RAISE EXCEPTION 'Épreuve introuvable';
  END IF;
  SELECT id INTO conv_id FROM public.conversations WHERE eleve_id = uid AND epreuve_id = p_epreuve_id;
  IF conv_id IS NOT NULL THEN
    RETURN conv_id;
  END IF;
  SELECT id, titre, enseignant_id INTO e FROM public.epreuves WHERE id = p_epreuve_id;
  IF e.enseignant_id = uid THEN
    RAISE EXCEPTION 'Vous êtes l''auteur de cette épreuve';
  END IF;
  INSERT INTO public.conversations (eleve_id, enseignant_id, sujet, type, statut, epreuve_id, eleve_nom)
  VALUES (uid, e.enseignant_id, 'Épreuve : ' || e.titre, 'epreuve', 'ouverte', p_epreuve_id,
          private.nom_affiche(uid))
  RETURNING id INTO conv_id;
  RETURN conv_id;
END;
$$;

-- L'enseignant valide ou corrige une réponse de Mandal IA dans ses fils.
CREATE OR REPLACE FUNCTION public.verifier_message_ia(p_message_id uuid, p_verification text)
RETURNS void
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = public, private
AS $$
BEGIN
  IF p_verification IS NOT NULL AND p_verification NOT IN ('valide', 'corrige') THEN
    RAISE EXCEPTION 'Valeur invalide';
  END IF;
  UPDATE public.messages m SET verification = p_verification
  FROM public.conversations c
  WHERE m.id = p_message_id AND m.auteur_ia AND c.id = m.conversation_id
    AND c.enseignant_id = auth.uid();
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Message introuvable';
  END IF;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.ouvrir_fil_epreuve(uuid), public.verifier_message_ia(uuid, text)
  FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.ouvrir_fil_epreuve(uuid), public.verifier_message_ia(uuid, text)
  TO authenticated;

-- ---------------------------------------------------------------------------
-- 3. Disponibilité des enseignants
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.enseignant_disponibilite (
  enseignant_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  disponible boolean NOT NULL DEFAULT true,
  message text,
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON public.enseignant_disponibilite TO authenticated;
GRANT ALL ON public.enseignant_disponibilite TO service_role;
ALTER TABLE public.enseignant_disponibilite ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Disponibilites lisibles" ON public.enseignant_disponibilite;
CREATE POLICY "Disponibilites lisibles" ON public.enseignant_disponibilite FOR SELECT
  TO authenticated USING (true);
DROP POLICY IF EXISTS "Enseignant declare sa disponibilite" ON public.enseignant_disponibilite;
CREATE POLICY "Enseignant declare sa disponibilite" ON public.enseignant_disponibilite FOR INSERT
  TO authenticated WITH CHECK (enseignant_id = auth.uid() AND private.is_teacher(auth.uid()));
DROP POLICY IF EXISTS "Enseignant modifie sa disponibilite" ON public.enseignant_disponibilite;
CREATE POLICY "Enseignant modifie sa disponibilite" ON public.enseignant_disponibilite FOR UPDATE
  TO authenticated USING (enseignant_id = auth.uid()) WITH CHECK (enseignant_id = auth.uid());
