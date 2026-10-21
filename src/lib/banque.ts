// Banque d'épreuves : constantes, dépôt (photos regroupées en PDF dans le
// navigateur) et liens de téléchargement.
import { supabase } from "@/integrations/supabase/client";
import { identifiantVisiteur } from "@/lib/site-analytics";
import type { Tables } from "@/integrations/supabase/types";
import {
  BANQUE_BUCKET,
  TAILLE_MAX,
  metaIncomplete,
  sansAccents,
  type MetaEpreuve,
} from "./banque-constantes";

export type EpreuveBanque = Tables<"banque_epreuves">;

export * from "./banque-constantes";

// ------------------------------------------------------------ Fichiers → PDF

async function imageEnJpeg(file: File): Promise<Uint8Array> {
  const bitmap = await createImageBitmap(file);
  const max = 2000;
  const scale = Math.min(1, max / Math.max(bitmap.width, bitmap.height));
  const canvas = document.createElement("canvas");
  canvas.width = Math.round(bitmap.width * scale);
  canvas.height = Math.round(bitmap.height * scale);
  const ctx = canvas.getContext("2d");
  if (!ctx) throw new Error("Conversion d'image impossible sur ce navigateur.");
  ctx.fillStyle = "#fff";
  ctx.fillRect(0, 0, canvas.width, canvas.height);
  ctx.drawImage(bitmap, 0, 0, canvas.width, canvas.height);
  bitmap.close();
  const blob = await new Promise<Blob | null>((resolve) =>
    canvas.toBlob(resolve, "image/jpeg", 0.85),
  );
  if (!blob) throw new Error("Conversion d'image impossible.");
  return new Uint8Array(await blob.arrayBuffer());
}

/** Un PDF est gardé tel quel ; des photos sont regroupées en un PDF (une page
 *  par photo, dans l'ordre choisi). */
export async function preparerFichier(fichiers: File[]): Promise<File> {
  if (fichiers.length === 0) throw new Error("Aucun fichier choisi.");
  const pdfs = fichiers.filter((f) => f.type === "application/pdf" || /\.pdf$/i.test(f.name));
  if (pdfs.length > 0) {
    if (fichiers.length > 1)
      throw new Error("Choisis un seul PDF, ou bien des photos (pas les deux).");
    return pdfs[0]!;
  }
  const nonImages = fichiers.filter((f) => !f.type.startsWith("image/"));
  if (nonImages.length) throw new Error(`Format non pris en charge : ${nonImages[0]!.name}`);

  const { PDFDocument } = await import("pdf-lib");
  const doc = await PDFDocument.create();
  for (const f of fichiers) {
    let jpeg: Uint8Array;
    try {
      jpeg = await imageEnJpeg(f);
    } catch {
      throw new Error(
        `Impossible de lire l'image « ${f.name} » (format HEIC ? prends la photo en JPEG).`,
      );
    }
    const img = await doc.embedJpg(jpeg);
    const page = doc.addPage([img.width, img.height]);
    page.drawImage(img, { x: 0, y: 0, width: img.width, height: img.height });
  }
  const bytes = await doc.save();
  const nom = fichiers[0]!.name.replace(/\.[a-z0-9]+$/i, "") + ".pdf";
  return new File([new Uint8Array(bytes)], nom, { type: "application/pdf" });
}

async function envoyer(userId: string, fichier: File) {
  if (fichier.size > TAILLE_MAX)
    throw new Error(`« ${fichier.name} » dépasse 25 Mo : compresse le PDF ou réduis les photos.`);
  const ext = fichier.type === "application/pdf" ? "pdf" : (fichier.name.split(".").pop() ?? "bin");
  const path = `${userId}/${crypto.randomUUID()}.${ext}`;
  const { error } = await supabase.storage
    .from(BANQUE_BUCKET)
    .upload(path, fichier, { contentType: fichier.type || "application/pdf", upsert: false });
  if (error) throw new Error(`Envoi de « ${fichier.name} » impossible : ${error.message}`);
  return path;
}

/** Dépose une épreuve (et son corrigé). Les administrateurs publient
 *  directement ; les dépôts des enseignants attendent la validation. */
export async function deposerEpreuve(options: {
  userId: string;
  sujet: File[];
  corrige?: File[] | undefined;
  meta: MetaEpreuve;
  publier: boolean;
}) {
  const probleme = metaIncomplete(options.meta);
  if (probleme) throw new Error(probleme);
  const sujet = await preparerFichier(options.sujet);
  const corrige = options.corrige?.length ? await preparerFichier(options.corrige) : null;

  const fichierPath = await envoyer(options.userId, sujet);
  let corrigePath: string | null = null;
  try {
    if (corrige) corrigePath = await envoyer(options.userId, corrige);
    const m = options.meta;
    const { error } = await supabase.from("banque_epreuves").insert({
      titre: m.titre.trim(),
      matiere: m.matiere,
      classe: m.classe,
      serie: m.serie.trim() || null,
      type_examen: m.type_examen,
      annee: m.annee ? Number(m.annee) : null,
      session: m.session.trim() || null,
      source: m.source.trim() || null,
      description: m.description.trim() || null,
      fichier_path: fichierPath,
      corrige_path: corrigePath,
      statut: options.publier ? "publiee" : "en_attente",
    });
    if (error) throw new Error(error.message);
  } catch (e) {
    await supabase.storage
      .from(BANQUE_BUCKET)
      .remove([fichierPath, ...(corrigePath ? [corrigePath] : [])]);
    throw e;
  }
}

/** Supprime une épreuve et ses fichiers. */
export async function supprimerEpreuve(
  e: Pick<EpreuveBanque, "id" | "fichier_path" | "corrige_path">,
) {
  const { error } = await supabase.from("banque_epreuves").delete().eq("id", e.id);
  if (error) throw new Error(error.message);
  await supabase.storage
    .from(BANQUE_BUCKET)
    .remove([e.fichier_path, ...(e.corrige_path ? [e.corrige_path] : [])]);
}

function nomTelechargement(e: Pick<EpreuveBanque, "titre">, corrige: boolean) {
  const base = sansAccents(e.titre)
    .replace(/[^a-zA-Z0-9]+/g, "_")
    .replace(/^_|_$/g, "")
    .slice(0, 80);
  return `${base || "epreuve"}${corrige ? "_corrige" : ""}_Mandal.pdf`;
}

/** Ouvre (aperçu) ou télécharge le sujet ou le corrigé. */
export async function ouvrirFichier(
  e: Pick<EpreuveBanque, "id" | "titre" | "fichier_path" | "corrige_path" | "statut">,
  options: { corrige?: boolean; telecharger?: boolean } = {},
) {
  const path = options.corrige ? e.corrige_path : e.fichier_path;
  if (!path) throw new Error("Aucun corrigé pour cette épreuve.");
  // Fenêtre ouverte tout de suite (sinon bloquée par le navigateur après l'attente).
  const fenetre = options.telecharger ? null : window.open("", "_blank");
  const { data, error } = await supabase.storage
    .from(BANQUE_BUCKET)
    .createSignedUrl(
      path,
      3600,
      options.telecharger ? { download: nomTelechargement(e, !!options.corrige) } : undefined,
    );
  if (error || !data) {
    fenetre?.close();
    throw new Error(error?.message ?? "Lien indisponible.");
  }
  if (options.telecharger) {
    if (e.statut === "publiee")
      void supabase.rpc("compter_telechargement_epreuve", {
        p_id: e.id,
        p_visiteur: identifiantVisiteur(),
      });
    window.location.assign(data.signedUrl);
  } else if (fenetre) {
    fenetre.location.href = data.signedUrl;
  } else {
    window.open(data.signedUrl, "_blank", "noopener");
  }
}
