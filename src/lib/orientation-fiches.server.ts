// Recherche, dans la base d'orientation, des fiches utiles à une question, et
// mise en forme pour le prompt de Mandal IA (avec leurs références).
import type { SupabaseClient } from "@supabase/supabase-js";
import type { Database } from "@/integrations/supabase/types";

type Source = { titre: string; url?: string };

function lireSources(value: unknown): Source[] {
  if (!Array.isArray(value)) return [];
  return value.flatMap((s: unknown) => {
    if (!s || typeof s !== "object") return [];
    const { titre, url } = s as Record<string, unknown>;
    if (typeof titre !== "string") return [];
    return [typeof url === "string" ? { titre, url } : { titre }];
  });
}

/** Fiches pertinentes au format texte, ou chaîne vide si aucune ne correspond. */
export async function fichesPourQuestion(
  supabase: SupabaseClient<Database>,
  question: string,
  limite = 4,
): Promise<string> {
  const { data, error } = await supabase.rpc("rechercher_fiches_orientation", {
    p_question: question,
    p_limite: limite,
  });
  if (error) {
    console.error("[Orientation] recherche impossible :", error.message);
    return "";
  }
  return (data ?? [])
    .map((f, i) => {
      const sources = lireSources(f.sources)
        .map((s) => `  - ${s.titre}${s.url ? ` (${s.url})` : ""}`)
        .join("\n");
      return [
        `### Fiche ${i + 1} — ${f.titre} [${f.type}, ${f.categorie}]`,
        f.niveau_acces ? `Accès : ${f.niveau_acces}` : "",
        f.contenu.slice(0, 2500),
        f.debouches.length ? `Débouchés : ${f.debouches.join(", ")}` : "",
        f.formations.length ? `Formations : ${f.formations.join(", ")}` : "",
        `Références :\n${sources}`,
      ]
        .filter(Boolean)
        .join("\n");
    })
    .join("\n\n");
}

/** Consignes communes sur l'usage des fiches et la citation des références. */
export const CONSIGNES_SOURCES = `RÉFÉRENCES (OBLIGATOIRE pour toute réponse d'orientation, de concours, d'examen ou de système éducatif)
- Appuie-toi en priorité sur les FICHES DE LA BASE M'ANDAL fournies ci-dessous ; elles décrivent la réalité camerounaise.
- Termine ces réponses par une section « ## Sources » listant 1 à 4 références sous la forme « - Titre (adresse) ».
- N'y cite QUE des références présentes dans les fiches, ou l'institution officielle compétente (MINESEC, MINESUP, OBC, GCE Board, ministère concerné) sans inventer d'adresse web.
- Ne donne jamais de date, de frais ou de nombre de places précis s'ils ne figurent pas dans les fiches : renvoie au communiqué officiel.
- N'écris pas toi-même la phrase de signature finale : elle est ajoutée automatiquement.`;
