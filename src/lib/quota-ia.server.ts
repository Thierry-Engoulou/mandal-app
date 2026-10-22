// Limite quotidienne d'utilisation de Mandal IA par élève : protège le quota
// du fournisseur d'IA et évite qu'un seul compte épuise le service pour tous.
import type { SupabaseClient } from "@supabase/supabase-js";
import type { Database } from "@/integrations/supabase/types";

type Table = "ia_messages" | "orientation_messages" | "epreuves_generees" | "corrections_ia";

export const QUOTAS_IA: Record<Table, { max: number; libelle: string }> = {
  ia_messages: { max: 40, libelle: "questions à Mandal IA" },
  orientation_messages: { max: 30, libelle: "questions au conseiller d'orientation" },
  epreuves_generees: { max: 5, libelle: "épreuves blanches" },
  corrections_ia: { max: 10, libelle: "corrections de copie" },
};

/** Lève une erreur claire si l'élève a atteint sa limite du jour (heure de Douala). */
export async function verifierQuotaIA(
  supabase: SupabaseClient<Database>,
  table: Table,
  userId: string,
): Promise<void> {
  const { max, libelle } = QUOTAS_IA[table];
  // Minuit à Douala (UTC+1), exprimé en UTC.
  const maintenant = new Date();
  const debut = new Date(
    Date.UTC(maintenant.getUTCFullYear(), maintenant.getUTCMonth(), maintenant.getUTCDate()) -
      60 * 60 * 1000,
  );
  if (maintenant.getTime() - debut.getTime() >= 24 * 60 * 60 * 1000) {
    debut.setUTCDate(debut.getUTCDate() + 1);
  }

  const depuis = debut.toISOString();
  const { count, error } =
    table === "ia_messages" || table === "orientation_messages"
      ? await supabase
          .from(table)
          .select("id", { count: "exact", head: true })
          .eq("eleve_id", userId)
          .eq("role", "user")
          .gte("created_at", depuis)
      : await supabase
          .from(table)
          .select("id", { count: "exact", head: true })
          .eq("eleve_id", userId)
          .gte("created_at", depuis);
  if (error) return; // en cas de doute, on ne bloque pas l'élève
  if ((count ?? 0) >= max) {
    throw new Error(
      `Tu as atteint la limite du jour (${max} ${libelle}). Reviens demain : la limite se réinitialise à minuit.`,
    );
  }
}
