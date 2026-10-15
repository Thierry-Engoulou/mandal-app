import { supabase } from "@/integrations/supabase/client";

export const EPREUVES_BUCKET = "epreuves";
export const COMPOSITIONS_BUCKET = "compositions";

/** Délai après la fin du chronomètre pour photographier / scanner les dernières
 *  pages (identique à private.delai_numerisation() en base). */
export const DELAI_NUMERISATION_MS = 15 * 60 * 1000;

export const NIVEAUX = [
  "6ème",
  "5ème",
  "4ème",
  "3ème / BEPC",
  "2nde",
  "1ère / Probatoire",
  "Terminale / Baccalauréat",
  "GCE O Level",
  "GCE A Level",
  "Concours",
] as const;

export const MATIERES = [
  "Mathématiques",
  "Physique",
  "Chimie",
  "PCT (Physique-Chimie-Technologie)",
  "SVT",
  "Français",
  "Anglais",
  "Histoire-Géographie",
  "Philosophie",
  "Informatique",
  "Autre",
];

export type CompositionLike = {
  fin_prevue_at: string;
  rendu_at: string | null;
  rendu_auto: boolean;
  note: number | null;
};

export type CompositionStatus = "en_cours" | "numerisation" | "rendue" | "transmise_auto" | "notee";

/** État d'une composition à l'instant `now`. */
export function compositionStatus(c: CompositionLike, now = Date.now()): CompositionStatus {
  if (c.note !== null) return "notee";
  if (c.rendu_at) return c.rendu_auto ? "transmise_auto" : "rendue";
  const fin = new Date(c.fin_prevue_at).getTime();
  if (now <= fin) return "en_cours";
  if (now <= fin + DELAI_NUMERISATION_MS) return "numerisation";
  return "transmise_auto";
}

export const STATUS_LABELS: Record<CompositionStatus, string> = {
  en_cours: "En cours",
  numerisation: "Temps écoulé — envoi des dernières pages",
  rendue: "Copie rendue",
  transmise_auto: "Transmise automatiquement",
  notee: "Notée",
};

export function formatDuree(minutes: number) {
  const h = Math.floor(minutes / 60);
  const m = minutes % 60;
  return h > 0 ? `${h} h${m > 0 ? ` ${String(m).padStart(2, "0")}` : ""}` : `${m} min`;
}

export function formatDateTime(iso: string) {
  return new Date(iso).toLocaleString("fr-FR", { dateStyle: "medium", timeStyle: "short" });
}

/** Lien temporaire (1 h) vers un fichier privé. */
export async function signedUrl(bucket: string, path: string) {
  const { data, error } = await supabase.storage.from(bucket).createSignedUrl(path, 3600);
  if (error) throw new Error(error.message);
  return data.signedUrl;
}
