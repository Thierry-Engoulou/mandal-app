import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";

async function assertSuperAdmin(context: { supabase: any; userId: string }) {
  const { data, error } = await context.supabase
    .from("profiles")
    .select("role")
    .eq("id", context.userId)
    .maybeSingle();
  if (error) throw new Error(error.message);
  if (data?.role !== "super_admin") {
    throw new Error("Accès réservé au super administrateur.");
  }
}

async function admin() {
  const { supabaseAdmin } = await import("@/integrations/supabase/client.server");
  return supabaseAdmin;
}

export type AdminUser = {
  id: string;
  email: string | null;
  nom: string;
  role: string;
  etablissement_id: string | null;
  etablissement_nom: string | null;
  statut_validation: string;
  xp_total: number;
  created_at: string;
};

export type UpdateAdminUserInput = {
  userId: string;
  role?: "student" | "teacher" | "admin" | "chef_etablissement" | "super_admin";
  etablissementId?: string | null;
  statutValidation?: "en_attente" | "approuve" | "rejete";
};

export const listAdminUsers = createServerFn({ method: "GET" })
  .middleware([requireSupabaseAuth])
  .handler(async ({ context }): Promise<AdminUser[]> => {
    await assertSuperAdmin(context as any);
    const db = await admin();

    const { data: profiles, error } = await db
      .from("profiles")
      .select(
        "id, role, full_name, nom, prenom, etablissement_id, statut_validation, xp_total, created_at, etablissements(nom)",
      )
      .order("created_at", { ascending: false });
    if (error) throw new Error(error.message);

    const emails = new Map<string, string | null>();
    const { data: userList } = await db.auth.admin.listUsers({ page: 1, perPage: 1000 });
    for (const u of userList?.users ?? []) emails.set(u.id, u.email ?? null);

    return (profiles ?? []).map((p: any) => ({
      id: p.id,
      email: emails.get(p.id) ?? null,
      nom: [p.prenom, p.nom].filter(Boolean).join(" ") || p.full_name || "Sans nom",
      role: p.role,
      etablissement_id: p.etablissement_id,
      etablissement_nom: p.etablissements?.nom ?? null,
      statut_validation: p.statut_validation,
      xp_total: p.xp_total,
      created_at: p.created_at,
    }));
  });

export const updateAdminUser = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) =>
    z
      .object({
        userId: z.string().uuid(),
        role: z
          .enum(["student", "teacher", "admin", "chef_etablissement", "super_admin"])
          .optional(),
        etablissementId: z.string().uuid().nullable().optional(),
        statutValidation: z.enum(["en_attente", "approuve", "rejete"]).optional(),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    await assertSuperAdmin(context as any);
    const db = await admin();
    const patch = {
      ...(data.role ? { role: data.role } : {}),
      ...(data.etablissementId !== undefined
        ? { etablissement_id: data.etablissementId }
        : {}),
      ...(data.statutValidation ? { statut_validation: data.statutValidation } : {}),
    };
    if (Object.keys(patch).length === 0) return { ok: true };
    const { error } = await db.from("profiles").update(patch).eq("id", data.userId);
    if (error) throw new Error(error.message);
    return { ok: true };
  });

export const listEtablissements = createServerFn({ method: "GET" })
  .middleware([requireSupabaseAuth])
  .handler(async ({ context }) => {
    const { data, error } = await context.supabase
      .from("etablissements")
      .select("id, nom, type, systeme_educatif")
      .order("nom");
    if (error) throw new Error(error.message);
    return data ?? [];
  });

export const createEtablissement = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) =>
    z
      .object({
        nom: z.string().min(2).max(160),
        type: z.string().max(80).optional(),
        systemeEducatif: z.string().min(1).max(80).default("francophone"),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    await assertSuperAdmin(context as any);
    const db = await admin();
    const { error } = await db.from("etablissements").insert({
      nom: data.nom,
      type: data.type ?? null,
      systeme_educatif: data.systemeEducatif,
    });
    if (error) throw new Error(error.message);
    return { ok: true };
  });

export const listAdminInvitations = createServerFn({ method: "GET" })
  .middleware([requireSupabaseAuth])
  .handler(async ({ context }) => {
    await assertSuperAdmin(context as any);
    const db = await admin();
    const { data, error } = await db
      .from("invitations_admin")
      .select("id, email, statut, token, expire_le, created_at, etablissement_id, etablissements(nom)")
      .order("created_at", { ascending: false });
    if (error) throw new Error(error.message);
    return (data ?? []).map((i: any) => ({
      id: i.id,
      email: i.email,
      statut: i.statut,
      token: i.token,
      expire_le: i.expire_le,
      created_at: i.created_at,
      etablissement_nom: i.etablissements?.nom ?? "—",
    }));
  });

export const createAdminInvitation = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) =>
    z
      .object({
        email: z.string().email(),
        etablissementId: z.string().uuid(),
        joursValidite: z.number().int().min(1).max(90).default(14),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    await assertSuperAdmin(context as any);
    const db = await admin();
    const token = crypto.randomUUID().replace(/-/g, "");
    const expire = new Date(Date.now() + data.joursValidite * 86_400_000).toISOString();
    const { error } = await db.from("invitations_admin").insert({
      email: data.email.toLowerCase(),
      etablissement_id: data.etablissementId,
      token,
      statut: "en_attente",
      expire_le: expire,
      created_by: context.userId,
    });
    if (error) throw new Error(error.message);
    return { token };
  });

export const updateAdminInvitation = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) =>
    z
      .object({
        id: z.string().uuid(),
        statut: z.enum(["en_attente", "acceptee", "annulee"]),
      })
      .parse(data),
  )
  .handler(async ({ data, context }) => {
    await assertSuperAdmin(context as any);
    const db = await admin();
    const { error } = await db
      .from("invitations_admin")
      .update({ statut: data.statut })
      .eq("id", data.id);
    if (error) throw new Error(error.message);
    return { ok: true };
  });
