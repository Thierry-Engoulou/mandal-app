import type { SupabaseClient } from "@supabase/supabase-js";
import type { Database } from "@/integrations/supabase/types";

type Supabase = SupabaseClient<Database>;

/** Résumé des cours de l'élève (classes, programmes, chapitres terminés) pour l'IA. */
export async function buildStudentContext(supabase: Supabase, userId: string): Promise<string> {
  const [{ data: profile }, { data: membres }, { data: progression }] = await Promise.all([
    supabase.from("profiles").select("full_name, prenom, niveau").eq("id", userId).maybeSingle(),
    supabase.from("class_membres").select("class_id, classes(nom, niveau)").eq("eleve_id", userId),
    supabase
      .from("progression_concepts")
      .select("concept_id")
      .eq("eleve_id", userId)
      .eq("termine", true),
  ]);

  const classIds = (membres ?? []).map((m) => m.class_id);
  const classNames = (membres ?? [])
    .map((m) => {
      const c = Array.isArray(m.classes) ? m.classes[0] : m.classes;
      return c ? [c.nom, c.niveau].filter(Boolean).join(" — ") : null;
    })
    .filter(Boolean);

  let query = supabase
    .from("programmes")
    .select("titre, chapitres(titre, ordre, concepts(id))")
    .order("titre")
    .limit(12);
  if (classIds.length > 0) query = query.in("classe_id", classIds);
  const { data: programmes } = await query;

  const done = new Set((progression ?? []).map((p) => p.concept_id));
  const lines: string[] = [];
  const name = profile?.prenom || profile?.full_name;
  if (name) lines.push(`Prénom : ${name}`);
  if (profile?.niveau) lines.push(`Niveau déclaré : ${profile.niveau}`);
  if (classNames.length > 0) lines.push(`Classe(s) : ${classNames.join(", ")}`);

  for (const p of programmes ?? []) {
    const chapitres = [...(p.chapitres ?? [])].sort((a, b) => a.ordre - b.ordre);
    const status = chapitres.map((ch) => {
      const ids = (ch.concepts ?? []).map((k) => k.id);
      const n = ids.filter((id) => done.has(id)).length;
      const etat =
        ids.length === 0
          ? ""
          : n === ids.length
            ? " (terminé)"
            : n > 0
              ? ` (en cours ${n}/${ids.length})`
              : "";
      return `${ch.titre}${etat}`;
    });
    lines.push(`Programme « ${p.titre} » : ${status.join(" ; ") || "aucun chapitre"}`);
  }

  // Limite la taille du contexte envoyé à l'IA.
  return lines.join("\n").slice(0, 6000);
}
