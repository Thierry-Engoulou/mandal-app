import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";

const BUCKETS: Record<string, string> = {
  video: "mediatheque-videos",
  audio: "mediatheque-audio",
  document: "mediatheque-documents",
};

const PENDING_BUCKET = "contenus-en-attente";

/** Vérifie que l'appelant est chef de l'établissement de la ressource. */
async function assertChefOf(
  context: { supabase: any; userId: string },
  etablissementId: string | null,
) {
  const { data, error } = await context.supabase
    .from("profiles")
    .select("role, etablissement_id")
    .eq("id", context.userId)
    .maybeSingle();
  if (error) throw new Error(error.message);
  const isChef = data?.role === "chef_etablissement" && data?.etablissement_id === etablissementId;
  const isSuper = data?.role === "super_admin";
  if (!etablissementId || (!isChef && !isSuper)) {
    throw new Error("Accès réservé au chef de cet établissement.");
  }
}

async function admin() {
  const { supabaseAdmin } = await import("@/integrations/supabase/client.server");
  return supabaseAdmin;
}

/**
 * Approuve une ressource : déplace le fichier du bucket d'attente vers le
 * bucket définitif correspondant au type, met à jour url_storage et le statut.
 */
export const approveResource = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) => z.object({ resourceId: z.string().uuid() }).parse(data))
  .handler(async ({ data, context }) => {
    const db = await admin();
    const { data: resource, error } = await db
      .from("ressources_mediatheque")
      .select("id, type, url_storage, etablissement_id, statut_validation")
      .eq("id", data.resourceId)
      .maybeSingle();
    if (error) throw new Error(error.message);
    if (!resource) throw new Error("Ressource introuvable.");
    await assertChefOf(context as any, resource.etablissement_id);

    const target = BUCKETS[resource.type];
    if (!target) throw new Error("Type de ressource inconnu.");

    let newPath = resource.url_storage;
    const sourcePath = resource.url_storage.replace(new RegExp(`^${PENDING_BUCKET}/`), "");

    const { data: file, error: dlError } = await db.storage
      .from(PENDING_BUCKET)
      .download(sourcePath);

    if (!dlError && file) {
      const { error: upError } = await db.storage
        .from(target)
        .upload(sourcePath, file, {
          upsert: true,
          contentType: file.type || "application/octet-stream",
        });
      if (upError) throw new Error(upError.message);
      await db.storage.from(PENDING_BUCKET).remove([sourcePath]);
      newPath = `${target}/${sourcePath}`;
    }

    const { error: updError } = await db
      .from("ressources_mediatheque")
      .update({ statut_validation: "approuve", url_storage: newPath })
      .eq("id", resource.id);
    if (updError) throw new Error(updError.message);

    return { ok: true, url_storage: newPath, moved: !dlError };
  });

/** Rejette une ressource : supprime le fichier d'attente et passe le statut à « rejete ». */
export const rejectResource = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) => z.object({ resourceId: z.string().uuid() }).parse(data))
  .handler(async ({ data, context }) => {
    const db = await admin();
    const { data: resource, error } = await db
      .from("ressources_mediatheque")
      .select("id, type, url_storage, etablissement_id")
      .eq("id", data.resourceId)
      .maybeSingle();
    if (error) throw new Error(error.message);
    if (!resource) throw new Error("Ressource introuvable.");
    await assertChefOf(context as any, resource.etablissement_id);

    const sourcePath = resource.url_storage.replace(new RegExp(`^${PENDING_BUCKET}/`), "");
    await db.storage.from(PENDING_BUCKET).remove([sourcePath]);

    const { error: updError } = await db
      .from("ressources_mediatheque")
      .update({ statut_validation: "rejete" })
      .eq("id", resource.id);
    if (updError) throw new Error(updError.message);

    return { ok: true };
  });

export type ChefTeacherContact = { id: string; email: string | null };

/** Emails des enseignants de l'établissement (Auth Admin API). */
export const listSchoolEmails = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) =>
    z.object({ etablissementId: z.string().uuid() }).parse(data),
  )
  .handler(async ({ data, context }): Promise<ChefTeacherContact[]> => {
    await assertChefOf(context as any, data.etablissementId);
    const db = await admin();
    const { data: profiles, error } = await db
      .from("profiles")
      .select("id")
      .eq("etablissement_id", data.etablissementId);
    if (error) throw new Error(error.message);
    const ids = new Set((profiles ?? []).map((p) => p.id));
    const { data: users } = await db.auth.admin.listUsers({ page: 1, perPage: 1000 });
    return (users?.users ?? [])
      .filter((u) => ids.has(u.id))
      .map((u) => ({ id: u.id, email: u.email ?? null }));
  });
