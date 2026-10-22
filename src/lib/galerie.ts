// Galerie de photos des événements M'ANDAL : fichiers dans le bucket Supabase
// « galerie » (public), liste et légendes dans la table galerie_photos.
import { supabase } from "@/integrations/supabase/client";
import type { Tables } from "@/integrations/supabase/types";

export type PhotoGalerie = Tables<"galerie_photos">;

export const GALERIE_BUCKET = "galerie";
const TAILLE_MAX = 10 * 1024 * 1024;

/** Photos livrées avec le site : affichées tant que la galerie Supabase est
 *  vide, et importables dans Supabase depuis /admin/galerie. */
export const PHOTOS_DE_DEPART = [
  { src: "/images/galerie/awards-2026-1.jpg", legende: "Awards M'ANDAL 2026 : les lauréats" },
  { src: "/images/galerie/awards-2026-2.jpg", legende: "Prix spéciaux M'ANDAL 2026" },
  { src: "/images/galerie/awards-2026-3.jpg", legende: "Awards M'ANDAL 2026" },
  { src: "/images/galerie/awards-2026-4.jpg", legende: "Awards M'ANDAL 2026 : la cérémonie" },
  { src: "/images/galerie/awards-2026-5.jpg", legende: "Remise des prix, Awards M'ANDAL 2026" },
] as const;

export function urlPhoto(chemin: string): string {
  return supabase.storage.from(GALERIE_BUCKET).getPublicUrl(chemin).data.publicUrl;
}

/** Photos visibles, dans l'ordre d'affichage (tout, pour un administrateur). */
export async function chargerGalerie(): Promise<PhotoGalerie[]> {
  const { data, error } = await supabase
    .from("galerie_photos")
    .select("*")
    .order("ordre", { ascending: true })
    .order("created_at", { ascending: false });
  if (error) throw new Error(error.message);
  return data ?? [];
}

/** Réduit la photo (2000 px max) et la convertit en JPEG. */
async function versJpeg(blob: Blob): Promise<Blob> {
  const bitmap = await createImageBitmap(blob);
  const scale = Math.min(1, 2000 / Math.max(bitmap.width, bitmap.height));
  const canvas = document.createElement("canvas");
  canvas.width = Math.round(bitmap.width * scale);
  canvas.height = Math.round(bitmap.height * scale);
  const ctx = canvas.getContext("2d");
  if (!ctx) throw new Error("Conversion d'image impossible sur ce navigateur.");
  ctx.drawImage(bitmap, 0, 0, canvas.width, canvas.height);
  bitmap.close();
  const jpeg = await new Promise<Blob | null>((resolve) =>
    canvas.toBlob(resolve, "image/jpeg", 0.85),
  );
  if (!jpeg) throw new Error("Conversion d'image impossible.");
  return jpeg;
}

/** Envoie une photo dans le bucket et l'ajoute à la galerie. */
export async function ajouterPhoto(source: Blob, legende: string, nom = "photo") {
  let jpeg: Blob;
  try {
    jpeg = await versJpeg(source);
  } catch {
    throw new Error(`Impossible de lire « ${nom} » (format HEIC ? utilise une photo JPEG).`);
  }
  if (jpeg.size > TAILLE_MAX) throw new Error(`« ${nom} » dépasse 10 Mo.`);
  const chemin = `${crypto.randomUUID()}.jpg`;
  const { error } = await supabase.storage
    .from(GALERIE_BUCKET)
    .upload(chemin, jpeg, { contentType: "image/jpeg", upsert: false });
  if (error) throw new Error(`Envoi de « ${nom} » impossible : ${error.message}`);
  const { error: e2 } = await supabase
    .from("galerie_photos")
    .insert({ chemin, legende: legende.trim() || null });
  if (e2) {
    await supabase.storage.from(GALERIE_BUCKET).remove([chemin]);
    throw new Error(e2.message);
  }
}

/** Copie les photos livrées avec le site dans la galerie Supabase. */
export async function importerPhotosDeDepart() {
  for (const p of PHOTOS_DE_DEPART) {
    const reponse = await fetch(p.src);
    if (!reponse.ok) throw new Error(`Photo introuvable : ${p.src}`);
    await ajouterPhoto(await reponse.blob(), p.legende, p.src.split("/").pop());
  }
}

export async function modifierPhoto(
  id: string,
  changements: { legende?: string | null; visible?: boolean; ordre?: number },
) {
  const { error } = await supabase.from("galerie_photos").update(changements).eq("id", id);
  if (error) throw new Error(error.message);
}

export async function supprimerPhoto(photo: Pick<PhotoGalerie, "id" | "chemin">) {
  const { error } = await supabase.from("galerie_photos").delete().eq("id", photo.id);
  if (error) throw new Error(error.message);
  await supabase.storage.from(GALERIE_BUCKET).remove([photo.chemin]);
}
