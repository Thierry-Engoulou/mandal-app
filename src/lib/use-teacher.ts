import { useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { useProfile, type Profile } from "@/lib/use-profile";
import { setSelectedSchoolId, useSelectedSchoolId } from "@/lib/teacher-store";

export type TeacherSchool = {
  id: string;
  nom: string;
  type: string | null;
  logo_url: string | null;
  systeme_educatif: string;
};

export type TeacherClass = {
  id: string;
  nom: string;
  niveau: string | null;
  filiere: string | null;
  annee_scolaire: string | null;
  effectif: number;
  etablissement_id: string;
};

/** Établissements dans lesquels l'enseignant a au moins une classe assignée. */
export function useTeacherSchools() {
  const { data: profile } = useProfile();
  return useQuery({
    enabled: !!profile,
    queryKey: ["enseignant-etablissements", profile?.id],
    queryFn: async (): Promise<TeacherSchool[]> => {
      const { data, error } = await supabase
        .from("classes")
        .select("etablissement_id, etablissements(id, nom, type, logo_url, systeme_educatif)")
        .eq("enseignant_id", profile!.id);
      if (error) throw new Error(error.message);
      const map = new Map<string, TeacherSchool>();
      for (const row of data ?? []) {
        const e = row.etablissements as unknown as TeacherSchool | null;
        if (e?.id) map.set(e.id, e);
      }
      return [...map.values()].sort((a, b) => a.nom.localeCompare(b.nom));
    },
  });
}

/** Établissement courant (persisté), auto-sélectionné sur le premier disponible. */
export function useSelectedSchool() {
  const { data: schools = [], isLoading } = useTeacherSchools();
  const selectedId = useSelectedSchoolId();

  useEffect(() => {
    if (schools.length === 0) return;
    if (!selectedId || !schools.some((s) => s.id === selectedId)) {
      setSelectedSchoolId(schools[0]!.id);
    }
  }, [schools, selectedId]);

  const school = schools.find((s) => s.id === selectedId) ?? null;
  return { schools, school, schoolId: school?.id ?? null, isLoading };
}

/** Classes de l'enseignant dans l'établissement sélectionné. */
export function useTeacherClasses(schoolId: string | null) {
  const { data: profile } = useProfile();
  return useQuery({
    enabled: !!profile && !!schoolId,
    queryKey: ["enseignant-classes", profile?.id, schoolId],
    queryFn: async (): Promise<TeacherClass[]> => {
      const { data, error } = await supabase
        .from("classes")
        .select("id, nom, niveau, filiere, annee_scolaire, effectif, etablissement_id")
        .eq("enseignant_id", profile!.id)
        .eq("etablissement_id", schoolId!)
        .order("nom");
      if (error) throw new Error(error.message);
      return (data ?? []) as TeacherClass[];
    },
  });
}

export type TeacherValidation = {
  statut: "en_attente" | "approuve" | "rejete";
  hasRequest: boolean;
};

/** Statut de validation du compte enseignant auprès du chef d'établissement. */
export function useTeacherValidation(schoolId: string | null) {
  const { data: profile } = useProfile();
  return useQuery({
    enabled: !!profile,
    queryKey: ["enseignant-validation", profile?.id, schoolId],
    queryFn: async (): Promise<TeacherValidation> => {
      let q = supabase
        .from("validations_enseignants")
        .select("statut, etablissement_id, created_at")
        .eq("enseignant_id", profile!.id)
        .order("created_at", { ascending: false });
      if (schoolId) q = q.eq("etablissement_id", schoolId);
      const { data, error } = await q.limit(1);
      if (error) throw new Error(error.message);
      const row = data?.[0];
      if (row) return { statut: row.statut as TeacherValidation["statut"], hasRequest: true };
      // Pas de demande enregistrée : on retombe sur le statut du profil.
      const fallback = (profile as Profile).statut_validation as TeacherValidation["statut"];
      return { statut: fallback ?? "en_attente", hasRequest: false };
    },
  });
}

/**
 * Raccourci : le compte peut-il créer du contenu ?
 * Accès immédiat : tout enseignant connecté peut travailler dès son inscription.
 * La validation par le chef d'établissement reste informative.
 */
export function useCanWrite(schoolId: string | null) {
  const { data } = useTeacherValidation(schoolId);
  return { canWrite: true, validation: data };
}
