-- ============ BASE MANDAL ============
CREATE TYPE public.app_role AS ENUM ('student', 'teacher', 'admin', 'chef_etablissement', 'super_admin');
CREATE TYPE public.pillar AS ENUM ('education','citoyennete','identite_culture','orientation','developpement','entrepreneuriat','sante_bien_etre','culture_generale');
CREATE TYPE public.course_level AS ENUM ('debutant', 'intermediaire', 'avance');
CREATE TYPE public.application_status AS ENUM ('pending', 'reviewing', 'accepted', 'rejected');
CREATE TYPE public.validation_statut AS ENUM ('en_attente', 'approuve', 'rejete');
CREATE TYPE public.ressource_type AS ENUM ('video', 'audio', 'document');

CREATE SCHEMA IF NOT EXISTS private;
GRANT USAGE ON SCHEMA private TO authenticated;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER LANGUAGE plpgsql SET search_path = public AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;

-- ============ ETABLISSEMENTS ============
CREATE TABLE public.etablissements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nom text NOT NULL,
  type text,
  logo_url text,
  systeme_educatif text NOT NULL DEFAULT 'francophone',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.etablissements TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.etablissements TO authenticated;
GRANT ALL ON public.etablissements TO service_role;
ALTER TABLE public.etablissements ENABLE ROW LEVEL SECURITY;

-- ============ PROFILES ============
CREATE TABLE public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  etablissement_id uuid REFERENCES public.etablissements(id) ON DELETE SET NULL,
  role public.app_role NOT NULL DEFAULT 'student',
  full_name text,
  nom text,
  prenom text,
  avatar_url text,
  xp_total integer NOT NULL DEFAULT 0,
  niveau text NOT NULL DEFAULT 'Débutant',
  statut_validation public.validation_statut NOT NULL DEFAULT 'approuve',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- ============ HELPERS (SECURITY DEFINER) ============
CREATE OR REPLACE FUNCTION private.has_role(_user_id uuid, _role public.app_role)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = private, public AS $$
  SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = _user_id AND role = _role)
$$;

CREATE OR REPLACE FUNCTION private.etab(_user_id uuid)
RETURNS uuid LANGUAGE sql STABLE SECURITY DEFINER SET search_path = private, public AS $$
  SELECT etablissement_id FROM public.profiles WHERE id = _user_id
$$;

CREATE OR REPLACE FUNCTION private.is_super(_user_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = private, public AS $$
  SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = _user_id AND role IN ('super_admin','admin'))
$$;

CREATE OR REPLACE FUNCTION private.is_chef(_user_id uuid, _etab uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = private, public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = _user_id
      AND (role IN ('super_admin','admin')
           OR (role = 'chef_etablissement' AND etablissement_id = _etab))
  )
$$;

CREATE OR REPLACE FUNCTION private.is_teacher(_user_id uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = private, public AS $$
  SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = _user_id AND role IN ('teacher','chef_etablissement','admin','super_admin'))
$$;

GRANT EXECUTE ON FUNCTION private.has_role(uuid, public.app_role), private.etab(uuid), private.is_super(uuid), private.is_chef(uuid, uuid), private.is_teacher(uuid) TO authenticated, service_role;

-- policies etablissements / profiles
CREATE POLICY "Etablissements lisibles" ON public.etablissements FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Chef gere son etablissement" ON public.etablissements FOR UPDATE TO authenticated
  USING (private.is_chef(auth.uid(), id)) WITH CHECK (private.is_chef(auth.uid(), id));
CREATE POLICY "Super admin cree etablissement" ON public.etablissements FOR INSERT TO authenticated
  WITH CHECK (private.is_super(auth.uid()));
CREATE POLICY "Super admin supprime etablissement" ON public.etablissements FOR DELETE TO authenticated
  USING (private.is_super(auth.uid()));

CREATE POLICY "Profil personnel lisible" ON public.profiles FOR SELECT TO authenticated USING (auth.uid() = id);
CREATE POLICY "Profils du meme etablissement lisibles" ON public.profiles FOR SELECT TO authenticated
  USING (etablissement_id IS NOT NULL AND etablissement_id = private.etab(auth.uid()));
CREATE POLICY "Super admin lit les profils" ON public.profiles FOR SELECT TO authenticated USING (private.is_super(auth.uid()));
CREATE POLICY "Creation de son profil" ON public.profiles FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);
CREATE POLICY "Mise a jour de son profil" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
CREATE POLICY "Chef gere les profils de son etablissement" ON public.profiles FOR UPDATE TO authenticated
  USING (private.is_chef(auth.uid(), etablissement_id)) WITH CHECK (private.is_chef(auth.uid(), etablissement_id));

CREATE TRIGGER trg_profiles_updated BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER trg_etab_updated BEFORE UPDATE ON public.etablissements FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============ CLASSES ============
CREATE TABLE public.classes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  etablissement_id uuid NOT NULL REFERENCES public.etablissements(id) ON DELETE CASCADE,
  nom text NOT NULL,
  niveau text,
  filiere text,
  enseignant_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  is_composite boolean NOT NULL DEFAULT false,
  description text,
  annee_scolaire text,
  effectif integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.classes TO authenticated;
GRANT ALL ON public.classes TO service_role;
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Classes de mon etablissement" ON public.classes FOR SELECT TO authenticated
  USING (etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid()));
CREATE POLICY "Chef gere les classes" ON public.classes FOR ALL TO authenticated
  USING (private.is_chef(auth.uid(), etablissement_id)) WITH CHECK (private.is_chef(auth.uid(), etablissement_id));
CREATE POLICY "Enseignant met a jour sa classe" ON public.classes FOR UPDATE TO authenticated
  USING (enseignant_id = auth.uid()) WITH CHECK (enseignant_id = auth.uid());
CREATE TRIGGER trg_classes_updated BEFORE UPDATE ON public.classes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE public.class_membres (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id uuid NOT NULL REFERENCES public.classes(id) ON DELETE CASCADE,
  eleve_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (class_id, eleve_id)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.class_membres TO authenticated;
GRANT ALL ON public.class_membres TO service_role;
ALTER TABLE public.class_membres ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Membres visibles dans l etablissement" ON public.class_membres FOR SELECT TO authenticated
  USING (eleve_id = auth.uid() OR EXISTS (SELECT 1 FROM public.classes c WHERE c.id = class_id AND (c.etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid()))));
CREATE POLICY "Chef et enseignant gerent les membres" ON public.class_membres FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.classes c WHERE c.id = class_id AND (private.is_chef(auth.uid(), c.etablissement_id) OR c.enseignant_id = auth.uid())))
  WITH CHECK (EXISTS (SELECT 1 FROM public.classes c WHERE c.id = class_id AND (private.is_chef(auth.uid(), c.etablissement_id) OR c.enseignant_id = auth.uid())));

-- ============ PROGRAMMES ============
CREATE TABLE public.matieres (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nom text NOT NULL UNIQUE,
  couleur text,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.matieres TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.matieres TO authenticated;
GRANT ALL ON public.matieres TO service_role;
ALTER TABLE public.matieres ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Matieres lisibles" ON public.matieres FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Admins gerent les matieres" ON public.matieres FOR ALL TO authenticated
  USING (private.is_super(auth.uid())) WITH CHECK (private.is_super(auth.uid()));

CREATE TABLE public.programmes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  matiere_id uuid REFERENCES public.matieres(id) ON DELETE SET NULL,
  classe_id uuid REFERENCES public.classes(id) ON DELETE CASCADE,
  etablissement_id uuid REFERENCES public.etablissements(id) ON DELETE CASCADE,
  titre text NOT NULL,
  description text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.programmes TO authenticated;
GRANT ALL ON public.programmes TO service_role;
ALTER TABLE public.programmes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Programmes de mon etablissement" ON public.programmes FOR SELECT TO authenticated
  USING (etablissement_id IS NULL OR etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid()));
CREATE POLICY "Enseignants gerent les programmes" ON public.programmes FOR ALL TO authenticated
  USING (private.is_teacher(auth.uid()) AND (etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid())))
  WITH CHECK (private.is_teacher(auth.uid()) AND (etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid())));
CREATE TRIGGER trg_programmes_updated BEFORE UPDATE ON public.programmes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE public.chapitres (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  programme_id uuid NOT NULL REFERENCES public.programmes(id) ON DELETE CASCADE,
  titre text NOT NULL,
  ordre integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.chapitres TO authenticated;
GRANT ALL ON public.chapitres TO service_role;
ALTER TABLE public.chapitres ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Chapitres lisibles" ON public.chapitres FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.programmes p WHERE p.id = programme_id AND (p.etablissement_id IS NULL OR p.etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid()))));
CREATE POLICY "Enseignants gerent les chapitres" ON public.chapitres FOR ALL TO authenticated
  USING (private.is_teacher(auth.uid())) WITH CHECK (private.is_teacher(auth.uid()));

CREATE TABLE public.concepts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chapitre_id uuid NOT NULL REFERENCES public.chapitres(id) ON DELETE CASCADE,
  titre text NOT NULL,
  ordre integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.concepts TO authenticated;
GRANT ALL ON public.concepts TO service_role;
ALTER TABLE public.concepts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Concepts lisibles" ON public.concepts FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.chapitres c JOIN public.programmes p ON p.id = c.programme_id
                 WHERE c.id = chapitre_id AND (p.etablissement_id IS NULL OR p.etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid()))));
CREATE POLICY "Enseignants gerent les concepts" ON public.concepts FOR ALL TO authenticated
  USING (private.is_teacher(auth.uid())) WITH CHECK (private.is_teacher(auth.uid()));

-- ============ EXAMENS ============
CREATE TABLE public.examens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  programme_id uuid REFERENCES public.programmes(id) ON DELETE SET NULL,
  classe_id uuid REFERENCES public.classes(id) ON DELETE CASCADE,
  etablissement_id uuid REFERENCES public.etablissements(id) ON DELETE CASCADE,
  titre text NOT NULL,
  description text,
  duree_minutes integer NOT NULL DEFAULT 60,
  nb_questions integer NOT NULL DEFAULT 0,
  mode_evaluation text NOT NULL DEFAULT 'automatique',
  statut text NOT NULL DEFAULT 'brouillon',
  date_debut timestamptz,
  date_fin timestamptz,
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.examens TO authenticated;
GRANT ALL ON public.examens TO service_role;
ALTER TABLE public.examens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Examens de mon etablissement" ON public.examens FOR SELECT TO authenticated
  USING (etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid()));
CREATE POLICY "Enseignants gerent les examens" ON public.examens FOR ALL TO authenticated
  USING (private.is_teacher(auth.uid()) AND (etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid())))
  WITH CHECK (private.is_teacher(auth.uid()) AND (etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid())));
CREATE TRIGGER trg_examens_updated BEFORE UPDATE ON public.examens FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE public.questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  examen_id uuid NOT NULL REFERENCES public.examens(id) ON DELETE CASCADE,
  concept_id uuid REFERENCES public.concepts(id) ON DELETE SET NULL,
  enonce text NOT NULL,
  type text NOT NULL DEFAULT 'qcm',
  options jsonb NOT NULL DEFAULT '[]'::jsonb,
  reponse_correcte text,
  points integer NOT NULL DEFAULT 1,
  ordre integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.questions TO authenticated;
GRANT ALL ON public.questions TO service_role;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Questions lisibles dans l etablissement" ON public.questions FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.examens e WHERE e.id = examen_id AND (e.etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid()))));
CREATE POLICY "Enseignants gerent les questions" ON public.questions FOR ALL TO authenticated
  USING (private.is_teacher(auth.uid())) WITH CHECK (private.is_teacher(auth.uid()));

CREATE TABLE public.resultats_examens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  examen_id uuid NOT NULL REFERENCES public.examens(id) ON DELETE CASCADE,
  eleve_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  score numeric NOT NULL DEFAULT 0,
  reponses jsonb NOT NULL DEFAULT '{}'::jsonb,
  date_passage timestamptz NOT NULL DEFAULT now(),
  UNIQUE (examen_id, eleve_id)
);
GRANT SELECT, INSERT, UPDATE ON public.resultats_examens TO authenticated;
GRANT ALL ON public.resultats_examens TO service_role;
ALTER TABLE public.resultats_examens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Eleve lit ses resultats" ON public.resultats_examens FOR SELECT TO authenticated USING (eleve_id = auth.uid());
CREATE POLICY "Encadrants lisent les resultats" ON public.resultats_examens FOR SELECT TO authenticated
  USING (private.is_teacher(auth.uid()) AND EXISTS (SELECT 1 FROM public.examens e WHERE e.id = examen_id AND (e.etablissement_id = private.etab(auth.uid()) OR private.is_super(auth.uid()))));
CREATE POLICY "Eleve enregistre son resultat" ON public.resultats_examens FOR INSERT TO authenticated WITH CHECK (eleve_id = auth.uid());
CREATE POLICY "Enseignant corrige un resultat" ON public.resultats_examens FOR UPDATE TO authenticated
  USING (private.is_teacher(auth.uid())) WITH CHECK (private.is_teacher(auth.uid()));

-- ============ GAMIFICATION ============
CREATE TABLE public.xp_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  montant integer NOT NULL,
  source text NOT NULL,
  description text,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT ON public.xp_transactions TO authenticated;
GRANT ALL ON public.xp_transactions TO service_role;
ALTER TABLE public.xp_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "XP personnel lisible" ON public.xp_transactions FOR SELECT TO authenticated
  USING (profile_id = auth.uid() OR private.is_teacher(auth.uid()));
CREATE POLICY "XP personnel ajoute" ON public.xp_transactions FOR INSERT TO authenticated WITH CHECK (profile_id = auth.uid());

CREATE TABLE public.badges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nom text NOT NULL,
  description text,
  icon_url text,
  critere text,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.badges TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.badges TO authenticated;
GRANT ALL ON public.badges TO service_role;
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Badges lisibles" ON public.badges FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Admins gerent les badges" ON public.badges FOR ALL TO authenticated
  USING (private.is_super(auth.uid())) WITH CHECK (private.is_super(auth.uid()));

CREATE TABLE public.eleve_badges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  eleve_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  badge_id uuid NOT NULL REFERENCES public.badges(id) ON DELETE CASCADE,
  date_obtention timestamptz NOT NULL DEFAULT now(),
  UNIQUE (eleve_id, badge_id)
);
GRANT SELECT, INSERT ON public.eleve_badges TO authenticated;
GRANT ALL ON public.eleve_badges TO service_role;
ALTER TABLE public.eleve_badges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Badges obtenus lisibles" ON public.eleve_badges FOR SELECT TO authenticated
  USING (eleve_id = auth.uid() OR private.is_teacher(auth.uid()));
CREATE POLICY "Attribution de badge" ON public.eleve_badges FOR INSERT TO authenticated
  WITH CHECK (eleve_id = auth.uid() OR private.is_teacher(auth.uid()));

CREATE TABLE public.predictions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  eleve_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  matiere_id uuid REFERENCES public.matieres(id) ON DELETE CASCADE,
  probabilite_reussite numeric NOT NULL DEFAULT 0,
  tendance text,
  score_confiance numeric NOT NULL DEFAULT 0,
  calcule_le timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON public.predictions TO authenticated;
GRANT ALL ON public.predictions TO service_role;
ALTER TABLE public.predictions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Predictions lisibles" ON public.predictions FOR SELECT TO authenticated
  USING (eleve_id = auth.uid() OR private.is_teacher(auth.uid()));
CREATE POLICY "Predictions gerees par encadrants" ON public.predictions FOR ALL TO authenticated
  USING (private.is_teacher(auth.uid())) WITH CHECK (private.is_teacher(auth.uid()));

-- ============ MEDIATHEQUE ============
CREATE TABLE public.ressources_mediatheque (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  etablissement_id uuid REFERENCES public.etablissements(id) ON DELETE CASCADE,
  titre text NOT NULL,
  description text,
  type public.ressource_type NOT NULL,
  url_storage text NOT NULL,
  matiere_id uuid REFERENCES public.matieres(id) ON DELETE SET NULL,
  xp_valeur integer NOT NULL DEFAULT 10,
  statut_validation public.validation_statut NOT NULL DEFAULT 'en_attente',
  uploaded_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.ressources_mediatheque TO authenticated;
GRANT ALL ON public.ressources_mediatheque TO service_role;
ALTER TABLE public.ressources_mediatheque ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Ressources validees lisibles" ON public.ressources_mediatheque FOR SELECT TO authenticated
  USING (statut_validation = 'approuve' AND (etablissement_id IS NULL OR etablissement_id = private.etab(auth.uid())));
CREATE POLICY "Auteur lit ses ressources" ON public.ressources_mediatheque FOR SELECT TO authenticated USING (uploaded_by = auth.uid());
CREATE POLICY "Chef lit les ressources en attente" ON public.ressources_mediatheque FOR SELECT TO authenticated
  USING (private.is_chef(auth.uid(), etablissement_id));
CREATE POLICY "Depot de ressource" ON public.ressources_mediatheque FOR INSERT TO authenticated
  WITH CHECK (uploaded_by = auth.uid() AND private.is_teacher(auth.uid()));
CREATE POLICY "Chef valide les ressources" ON public.ressources_mediatheque FOR UPDATE TO authenticated
  USING (private.is_chef(auth.uid(), etablissement_id)) WITH CHECK (private.is_chef(auth.uid(), etablissement_id));
CREATE POLICY "Chef supprime les ressources" ON public.ressources_mediatheque FOR DELETE TO authenticated
  USING (private.is_chef(auth.uid(), etablissement_id) OR uploaded_by = auth.uid());
CREATE TRIGGER trg_ressources_updated BEFORE UPDATE ON public.ressources_mediatheque FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============ MESSAGERIE ============
CREATE TABLE public.conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  eleve_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  enseignant_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  sujet text NOT NULL,
  type text NOT NULL DEFAULT 'assistance',
  statut text NOT NULL DEFAULT 'en_attente',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON public.conversations TO authenticated;
GRANT ALL ON public.conversations TO service_role;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Mes conversations" ON public.conversations FOR SELECT TO authenticated
  USING (eleve_id = auth.uid() OR enseignant_id = auth.uid());
CREATE POLICY "Eleve cree une conversation" ON public.conversations FOR INSERT TO authenticated WITH CHECK (eleve_id = auth.uid());
CREATE POLICY "Participants mettent a jour" ON public.conversations FOR UPDATE TO authenticated
  USING (eleve_id = auth.uid() OR enseignant_id = auth.uid()) WITH CHECK (eleve_id = auth.uid() OR enseignant_id = auth.uid());
CREATE TRIGGER trg_conversations_updated BEFORE UPDATE ON public.conversations FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE public.messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  contenu text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT ON public.messages TO authenticated;
GRANT ALL ON public.messages TO service_role;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Messages de mes conversations" ON public.messages FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM public.conversations c WHERE c.id = conversation_id AND (c.eleve_id = auth.uid() OR c.enseignant_id = auth.uid())));
CREATE POLICY "Envoi de message" ON public.messages FOR INSERT TO authenticated
  WITH CHECK (sender_id = auth.uid() AND EXISTS (SELECT 1 FROM public.conversations c WHERE c.id = conversation_id AND (c.eleve_id = auth.uid() OR c.enseignant_id = auth.uid())));

CREATE TABLE public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  titre text NOT NULL,
  contenu text,
  lu boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.notifications TO authenticated;
GRANT ALL ON public.notifications TO service_role;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Mes notifications" ON public.notifications FOR SELECT TO authenticated USING (profile_id = auth.uid());
CREATE POLICY "Creation de notification" ON public.notifications FOR INSERT TO authenticated
  WITH CHECK (profile_id = auth.uid() OR private.is_teacher(auth.uid()));
CREATE POLICY "Mise a jour de mes notifications" ON public.notifications FOR UPDATE TO authenticated
  USING (profile_id = auth.uid()) WITH CHECK (profile_id = auth.uid());
CREATE POLICY "Suppression de mes notifications" ON public.notifications FOR DELETE TO authenticated USING (profile_id = auth.uid());

-- ============ ORIENTATION ============
CREATE TABLE public.orientation_profils (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  eleve_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE,
  niveau_scolaire text NOT NULL,
  filiere_cible text,
  systeme_educatif text NOT NULL DEFAULT 'francophone',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON public.orientation_profils TO authenticated;
GRANT ALL ON public.orientation_profils TO service_role;
ALTER TABLE public.orientation_profils ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Mon profil orientation" ON public.orientation_profils FOR ALL TO authenticated
  USING (eleve_id = auth.uid()) WITH CHECK (eleve_id = auth.uid());
CREATE TRIGGER trg_orientation_profils_updated BEFORE UPDATE ON public.orientation_profils FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE public.orientation_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  eleve_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role text NOT NULL,
  contenu text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, DELETE ON public.orientation_messages TO authenticated;
GRANT ALL ON public.orientation_messages TO service_role;
ALTER TABLE public.orientation_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Mon historique orientation" ON public.orientation_messages FOR SELECT TO authenticated USING (eleve_id = auth.uid());
CREATE POLICY "Ecriture historique orientation" ON public.orientation_messages FOR INSERT TO authenticated WITH CHECK (eleve_id = auth.uid());
CREATE POLICY "Effacer mon historique orientation" ON public.orientation_messages FOR DELETE TO authenticated USING (eleve_id = auth.uid());

-- ============ VALIDATION & INVITATIONS ============
CREATE TABLE public.validations_enseignants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  enseignant_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  etablissement_id uuid NOT NULL REFERENCES public.etablissements(id) ON DELETE CASCADE,
  statut public.validation_statut NOT NULL DEFAULT 'en_attente',
  valide_par uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  date_validation timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON public.validations_enseignants TO authenticated;
GRANT ALL ON public.validations_enseignants TO service_role;
ALTER TABLE public.validations_enseignants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Demande visible par l enseignant et le chef" ON public.validations_enseignants FOR SELECT TO authenticated
  USING (enseignant_id = auth.uid() OR private.is_chef(auth.uid(), etablissement_id));
CREATE POLICY "Enseignant depose sa demande" ON public.validations_enseignants FOR INSERT TO authenticated
  WITH CHECK (enseignant_id = auth.uid());
CREATE POLICY "Chef valide les enseignants" ON public.validations_enseignants FOR UPDATE TO authenticated
  USING (private.is_chef(auth.uid(), etablissement_id)) WITH CHECK (private.is_chef(auth.uid(), etablissement_id));

CREATE TABLE public.invitations_admin (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  etablissement_id uuid NOT NULL REFERENCES public.etablissements(id) ON DELETE CASCADE,
  email text NOT NULL,
  token text NOT NULL UNIQUE DEFAULT encode(gen_random_bytes(24), 'hex'),
  statut text NOT NULL DEFAULT 'en_attente',
  expire_le timestamptz NOT NULL DEFAULT (now() + interval '14 days'),
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.invitations_admin TO authenticated;
GRANT ALL ON public.invitations_admin TO service_role;
ALTER TABLE public.invitations_admin ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Invitations visibles par les responsables" ON public.invitations_admin FOR ALL TO authenticated
  USING (private.is_chef(auth.uid(), etablissement_id)) WITH CHECK (private.is_chef(auth.uid(), etablissement_id));

-- ============ CONTENU MANDAL EXISTANT ============
CREATE TABLE public.courses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  content text NOT NULL,
  pillar public.pillar NOT NULL,
  level public.course_level NOT NULL DEFAULT 'debutant',
  author_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  is_published boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.courses TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.courses TO authenticated;
GRANT ALL ON public.courses TO service_role;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Cours publies lisibles" ON public.courses FOR SELECT TO anon, authenticated USING (is_published = true);
CREATE POLICY "Auteur lit ses cours" ON public.courses FOR SELECT TO authenticated USING (auth.uid() = author_id);
CREATE POLICY "Auteur cree un cours" ON public.courses FOR INSERT TO authenticated WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Auteur met a jour son cours" ON public.courses FOR UPDATE TO authenticated USING (auth.uid() = author_id) WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Auteur supprime son cours" ON public.courses FOR DELETE TO authenticated USING (auth.uid() = author_id);
CREATE TRIGGER trg_courses_updated BEFORE UPDATE ON public.courses FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE public.pillars (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  number text NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.pillars TO anon, authenticated;
GRANT ALL ON public.pillars TO service_role;
ALTER TABLE public.pillars ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Piliers lisibles" ON public.pillars FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Admins gerent les piliers" ON public.pillars FOR ALL TO authenticated
  USING (private.is_super(auth.uid())) WITH CHECK (private.is_super(auth.uid()));
CREATE TRIGGER trg_pillars_updated BEFORE UPDATE ON public.pillars FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE public.olympiads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  title text NOT NULL,
  edition text NOT NULL,
  year integer NOT NULL,
  description text NOT NULL,
  location text,
  starts_on date,
  ends_on date,
  is_featured boolean NOT NULL DEFAULT false,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.olympiads TO anon, authenticated;
GRANT ALL ON public.olympiads TO service_role;
ALTER TABLE public.olympiads ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Olympiades lisibles" ON public.olympiads FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Admins gerent les olympiades" ON public.olympiads FOR ALL TO authenticated
  USING (private.is_super(auth.uid())) WITH CHECK (private.is_super(auth.uid()));
CREATE TRIGGER trg_olympiads_updated BEFORE UPDATE ON public.olympiads FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TABLE public.student_applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name text NOT NULL,
  email text NOT NULL,
  phone text,
  country text NOT NULL,
  city text,
  school text,
  school_level text NOT NULL,
  pillar_interest public.pillar,
  motivation text NOT NULL,
  status public.application_status NOT NULL DEFAULT 'pending',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT INSERT ON public.student_applications TO anon;
GRANT SELECT, INSERT, UPDATE ON public.student_applications TO authenticated;
GRANT ALL ON public.student_applications TO service_role;
ALTER TABLE public.student_applications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Candidature ouverte a tous" ON public.student_applications FOR INSERT TO anon, authenticated WITH CHECK (true);
CREATE POLICY "Admins lisent les candidatures" ON public.student_applications FOR SELECT TO authenticated USING (private.is_super(auth.uid()));
CREATE POLICY "Admins traitent les candidatures" ON public.student_applications FOR UPDATE TO authenticated
  USING (private.is_super(auth.uid())) WITH CHECK (private.is_super(auth.uid()));
CREATE TRIGGER trg_student_applications_updated BEFORE UPDATE ON public.student_applications FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============ REALTIME ============
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;

-- ============ DONNEES DE REFERENCE ============
INSERT INTO public.pillars (slug, number, title, description, sort_order) VALUES
('education', '01', 'Éducation', 'Maîtrise des fondamentaux académiques et outils numériques.', 1),
('citoyennete', '02', 'Citoyenneté', 'Comprendre ses droits, ses devoirs et l''engagement civique.', 2),
('identite_culture', '03', 'Identité & Culture', 'Valoriser le patrimoine africain et son histoire millénaire.', 3),
('orientation', '04', 'Orientation', 'Tracer sa voie professionnelle avec clarté et ambition.', 4),
('developpement', '05', 'Développement', 'Intelligence émotionnelle et leadership personnel.', 5),
('entrepreneuriat', '06', 'Entrepreneuriat', 'Créer des solutions locales pour un impact global.', 6),
('sante_bien_etre', '07', 'Santé & Bien-être', 'Équilibre physique et mental pour une performance durable.', 7),
('culture_generale', '08', 'Culture générale', 'Élargir ses horizons et nourrir sa curiosité intellectuelle.', 8);

INSERT INTO public.olympiads (slug, title, edition, year, description, location, starts_on, ends_on, is_featured, sort_order) VALUES
('olympiades-2025', 'Les Olympiades M''Andal', 'Édition 2025', 2025, 'Le plus grand concours panafricain de savoir et de citoyenneté. Une finale prestigieuse pour récompenser les futurs leaders du continent.', 'Douala, Cameroun', '2025-11-10', '2025-11-15', true, 1),
('olympiades-2026', 'Les Olympiades M''Andal', 'Édition 2026', 2026, 'Nouvelle édition panafricaine : épreuves régionales en ligne, demi-finales nationales et grande finale continentale sur les 8 piliers de l''excellence.', 'Dakar, Sénégal', '2026-11-09', '2026-11-14', false, 2);

INSERT INTO public.matieres (nom) VALUES
('Mathématiques'), ('Français'), ('Anglais'), ('Physique-Chimie'), ('SVT'),
('Histoire-Géographie'), ('Philosophie'), ('Informatique'), ('Économie');

INSERT INTO public.badges (nom, description, critere) VALUES
('Premiers pas', 'Première connexion à la plateforme', 'connexion'),
('Studieux', 'Cinq ressources consultées', 'mediatheque_5'),
('Champion d''examen', 'Un examen réussi avec plus de 80%', 'examen_80'),
('Curieux', 'Premier échange avec le conseiller d''orientation', 'orientation_1');