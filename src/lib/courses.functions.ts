import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";
import { createClient } from "@supabase/supabase-js";
import type { Database } from "@/integrations/supabase/types";
import { requireSupabaseAuth } from "@/integrations/supabase/auth-middleware";

function createSupabaseFetch(supabaseKey: string): typeof fetch {
  return (input, init) => {
    const headers = new Headers(
      typeof Request !== "undefined" && input instanceof Request ? input.headers : undefined,
    );
    if (init?.headers) {
      new Headers(init.headers).forEach((value, key) => headers.set(key, value));
    }
    const isNewKey =
      supabaseKey.startsWith("sb_publishable_") || supabaseKey.startsWith("sb_secret_");
    if (isNewKey && headers.get("Authorization") === `Bearer ${supabaseKey}`) {
      headers.delete("Authorization");
    }
    headers.set("apikey", supabaseKey);
    return fetch(input, { ...init, headers });
  };
}

function createPublicClient() {
  const url = process.env["SUPABASE_URL"]!;
  const key = process.env["SUPABASE_PUBLISHABLE_KEY"]!;
  return createClient<Database>(url, key, {
    auth: { persistSession: false, autoRefreshToken: false, storage: undefined },
    global: { fetch: createSupabaseFetch(key) },
  });
}

const PILLAR_LABELS: Record<string, string> = {
  education: "Éducation",
  citoyennete: "Citoyenneté",
  identite_culture: "Identité & Culture",
  orientation: "Orientation",
  developpement: "Développement",
  entrepreneuriat: "Entrepreneuriat",
  sante_bien_etre: "Santé & Bien-être",
  culture_generale: "Culture générale",
};

const LEVEL_LABELS: Record<string, string> = {
  debutant: "Débutant",
  intermediaire: "Intermédiaire",
  avance: "Avancé",
};

export const listCourses = createServerFn({ method: "GET" }).handler(async () => {
  const supabase = createPublicClient();
  const { data, error } = await supabase
    .from("courses")
    .select("id, title, pillar, level, is_published, created_at, author_id")
    .eq("is_published", true)
    .order("created_at", { ascending: false });

  if (error) throw error;

  return (data ?? []).map((course) => ({
    ...course,
    pillarLabel: PILLAR_LABELS[course.pillar] ?? course.pillar,
    levelLabel: LEVEL_LABELS[course.level] ?? course.level,
  }));
});

export const getCourse = createServerFn({ method: "GET" })
  .inputValidator((data: unknown) => z.object({ id: z.string().uuid() }).parse(data))
  .handler(async ({ data }) => {
    const supabase = createPublicClient();
    const { data: course, error } = await supabase
      .from("courses")
      .select("id, title, content, pillar, level, is_published, created_at, updated_at, author_id")
      .eq("id", data.id)
      .eq("is_published", true)
      .single();

    if (error) throw error;
    if (!course) throw new Error("Course not found");

    return {
      ...course,
      pillarLabel: PILLAR_LABELS[course.pillar] ?? course.pillar,
      levelLabel: LEVEL_LABELS[course.level] ?? course.level,
    };
  });

const courseInputSchema = z.object({
  title: z.string().trim().min(1).max(200),
  content: z.string().max(100_000),
  pillar: z.enum([
    "education",
    "citoyennete",
    "identite_culture",
    "orientation",
    "developpement",
    "entrepreneuriat",
    "sante_bien_etre",
    "culture_generale",
  ]),
  level: z.enum(["debutant", "intermediaire", "avance"]),
  is_published: z.boolean(),
});

export const createCourse = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) => courseInputSchema.parse(data))
  .handler(async ({ data, context }) => {
    const { data: course, error } = await context.supabase
      .from("courses")
      .insert({
        title: data.title,
        content: data.content,
        pillar: data.pillar,
        level: data.level,
        is_published: data.is_published,
        author_id: context.userId,
      })
      .select("id")
      .single();

    if (error) throw error;
    return { id: course!.id };
  });

export const updateCourse = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) =>
    courseInputSchema.extend({ id: z.string().uuid() }).parse(data),
  )
  .handler(async ({ data, context }) => {
    const { error } = await context.supabase
      .from("courses")
      .update({
        title: data.title,
        content: data.content,
        pillar: data.pillar,
        level: data.level,
        is_published: data.is_published,
      })
      .eq("id", data.id)
      .eq("author_id", context.userId);

    if (error) throw error;
    return { id: data.id };
  });

export const deleteCourse = createServerFn({ method: "POST" })
  .middleware([requireSupabaseAuth])
  .inputValidator((data: unknown) => z.object({ id: z.string().uuid() }).parse(data))
  .handler(async ({ data, context }) => {
    const { error } = await context.supabase
      .from("courses")
      .delete()
      .eq("id", data.id)
      .eq("author_id", context.userId);

    if (error) throw error;
    return { id: data.id };
  });
