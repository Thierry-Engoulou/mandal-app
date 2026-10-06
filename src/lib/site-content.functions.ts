import { createServerFn } from "@tanstack/react-start";
import { createClient } from "@supabase/supabase-js";
import type { Database } from "@/integrations/supabase/types";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";

function createPublicClient() {
  const url = process.env["SUPABASE_URL"]!;
  const key = process.env["SUPABASE_PUBLISHABLE_KEY"]!;
  return createClient<Database>(url, key, {
    auth: { persistSession: false, autoRefreshToken: false, storage: undefined },
    global: {
      fetch: (input, init) => {
        const headers = new Headers(init?.headers);
        if (key.startsWith("sb_") && headers.get("Authorization") === `Bearer ${key}`) {
          headers.delete("Authorization");
        }
        headers.set("apikey", key);
        return fetch(input, { ...init, headers });
      },
    },
  });
}

export const listPillars = createServerFn({ method: "GET" }).handler(async () => {
  const supabase = createPublicClient();
  const { data, error } = await supabase
    .from("pillars")
    .select("id, slug, number, title, description")
    .order("sort_order", { ascending: true });
  if (error) throw error;
  return data ?? [];
});

export const listOlympiads = createServerFn({ method: "GET" }).handler(async () => {
  const supabase = createPublicClient();
  const { data, error } = await supabase
    .from("olympiads")
    .select("id, slug, title, edition, year, description, location, starts_on, ends_on, is_featured")
    .order("sort_order", { ascending: true });
  if (error) throw error;
  return data ?? [];
});

export const submitStudentApplication = createServerFn({ method: "POST" })
  .validator(
    (input: {
      full_name: string;
      email: string;
      phone?: string;
      country: string;
      city?: string;
      school?: string;
      school_level: string;
      pillar_interest?: string;
      motivation: string;
    }) => input,
  )
  .handler(async ({ data }) => {
    const fullName = data.full_name.trim();
    const email = data.email.trim();
    const motivation = data.motivation.trim();

    if (fullName.length < 2 || fullName.length > 120) throw new Error("Nom invalide.");
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 160)
      throw new Error("Adresse e-mail invalide.");
    if (motivation.length < 20 || motivation.length > 2000)
      throw new Error("La motivation doit contenir entre 20 et 2000 caractères.");
    if (!data.country.trim()) throw new Error("Le pays est requis.");
    if (!data.school_level.trim()) throw new Error("Le niveau scolaire est requis.");

    const supabase = createPublicClient();
    const { error } = await supabase.from("student_applications").insert({
      full_name: fullName,
      email,
      phone: data.phone?.trim() || null,
      country: data.country.trim(),
      city: data.city?.trim() || null,
      school: data.school?.trim() || null,
      school_level: data.school_level.trim(),
      pillar_interest: (data.pillar_interest || null) as never,
      motivation,
    });

    if (error) throw error;
    return { ok: true };
  });

export const listStudentApplications = createServerFn({ method: "GET" })
  .middleware([requireSupabaseAuth])
  .handler(async ({ context }) => {
    const { data, error } = await context.supabase
      .from("student_applications")
      .select(
        "id, full_name, email, phone, country, city, school, school_level, pillar_interest, motivation, status, created_at",
      )
      .order("created_at", { ascending: false });
    if (error) throw error;
    return data ?? [];
  });
