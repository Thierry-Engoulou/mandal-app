import { useQuery } from "@tanstack/react-query";
import { supabase } from "@/integrations/supabase/client";

export type Profile = {
  id: string;
  role: string;
  full_name: string | null;
  nom: string | null;
  prenom: string | null;
  avatar_url: string | null;
  xp_total: number;
  niveau: string;
  etablissement_id: string | null;
  statut_validation: string;
};

export function useProfile() {
  return useQuery({
    queryKey: ["mon-profil"],
    queryFn: async (): Promise<Profile | null> => {
      const { data: auth } = await supabase.auth.getUser();
      if (!auth.user) return null;
      const { data, error } = await supabase
        .from("profiles")
        .select(
          "id, role, full_name, nom, prenom, avatar_url, xp_total, niveau, etablissement_id, statut_validation",
        )
        .eq("id", auth.user.id)
        .maybeSingle();
      if (error) throw new Error(error.message);
      return (data as Profile | null) ?? null;
    },
  });
}

export function displayName(p?: Profile | null) {
  if (!p) return "Étudiant";
  const composed = [p.prenom, p.nom].filter(Boolean).join(" ").trim();
  return composed || p.full_name || "Étudiant";
}
