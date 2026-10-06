import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";

/**
 * Source de vérité unique pour les classes : la table Supabase `classes`.
 * Toute création / modification / suppression passe par ici.
 */

export type ClasseRow = {
  id: string;
  nom: string;
  niveau: string | null;
  filiere: string | null;
  annee_scolaire: string | null;
  description: string | null;
  effectif: number;
  etablissement_id: string;
  enseignant_id: string | null;
  created_at: string;
};

const SELECT =
  "id, nom, niveau, filiere, annee_scolaire, description, effectif, etablissement_id, enseignant_id, created_at";

export type ClasseInput = {
  nom: string;
  niveau: string;
  filiere: string;
  annee_scolaire: string;
  description?: string;
};

/** Toutes les classes de l'enseignant connecté (tous établissements confondus). */
export function useMyClasses() {
  const { data: profile } = useProfile();
  return useQuery({
    enabled: !!profile,
    queryKey: ["classes", "enseignant", profile?.id],
    queryFn: async (): Promise<ClasseRow[]> => {
      const { data, error } = await supabase
        .from("classes")
        .select(SELECT)
        .eq("enseignant_id", profile!.id)
        .order("nom");
      if (error) throw new Error(error.message);
      return (data ?? []) as ClasseRow[];
    },
  });
}

/** Une classe par son identifiant. */
export function useClasse(classId: string) {
  return useQuery({
    enabled: !!classId,
    queryKey: ["classe", classId],
    queryFn: async (): Promise<ClasseRow | null> => {
      const { data, error } = await supabase
        .from("classes")
        .select(SELECT)
        .eq("id", classId)
        .maybeSingle();
      if (error) throw new Error(error.message);
      return (data as ClasseRow | null) ?? null;
    },
  });
}

/** Examens rattachés à une classe. */
export function useClasseExamens(classId: string) {
  return useQuery({
    enabled: !!classId,
    queryKey: ["classe-examens", classId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("examens")
        .select("id, titre, statut, date_debut, duree_minutes, nb_questions")
        .eq("classe_id", classId)
        .order("date_debut", { ascending: true, nullsFirst: false });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });
}

function useInvalidateClasses() {
  const queryClient = useQueryClient();
  return () =>
    Promise.all([
      queryClient.invalidateQueries({ queryKey: ["classes"] }),
      queryClient.invalidateQueries({ queryKey: ["classe"] }),
      queryClient.invalidateQueries({ queryKey: ["enseignant-classes"] }),
      queryClient.invalidateQueries({ queryKey: ["enseignant-etablissements"] }),
    ]);
}

export function useCreateClasse() {
  const { data: profile } = useProfile();
  const invalidate = useInvalidateClasses();
  return useMutation({
    mutationFn: async (input: ClasseInput & { etablissementId?: string | null }) => {
      const etablissementId = input.etablissementId ?? profile?.etablissement_id ?? null;
      if (!etablissementId) {
        throw new Error(
          "Aucun établissement rattaché à votre compte : impossible de créer une classe.",
        );
      }
      const { data, error } = await supabase
        .from("classes")
        .insert({
          nom: input.nom.trim(),
          niveau: input.niveau.trim() || null,
          filiere: input.filiere.trim() || null,
          annee_scolaire: input.annee_scolaire.trim() || null,
          description: input.description?.trim() || null,
          etablissement_id: etablissementId,
          enseignant_id: profile!.id,
        })
        .select(SELECT)
        .single();
      if (error) throw new Error(error.message);
      return data as ClasseRow;
    },
    onSuccess: invalidate,
  });
}

export function useUpdateClasse() {
  const invalidate = useInvalidateClasses();
  return useMutation({
    mutationFn: async ({ id, ...input }: ClasseInput & { id: string }) => {
      const { data, error } = await supabase
        .from("classes")
        .update({
          nom: input.nom.trim(),
          niveau: input.niveau.trim() || null,
          filiere: input.filiere.trim() || null,
          annee_scolaire: input.annee_scolaire.trim() || null,
          description: input.description?.trim() || null,
        })
        .eq("id", id)
        .select(SELECT)
        .single();
      if (error) throw new Error(error.message);
      return data as ClasseRow;
    },
    onSuccess: invalidate,
  });
}

export function useDeleteClasse() {
  const invalidate = useInvalidateClasses();
  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from("classes").delete().eq("id", id);
      if (error) throw new Error(error.message);
      return id;
    },
    onSuccess: invalidate,
  });
}
