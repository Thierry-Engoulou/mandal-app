import { createServerFn } from "@tanstack/react-start";
import { z } from "zod";

const createProfileSchema = z.object({
  userId: z.string().uuid(),
  fullName: z.string().min(1).max(200),
  role: z.enum(["student", "teacher", "admin"]),
});

export const createProfile = createServerFn({ method: "POST" })
  .validator((data) => createProfileSchema.parse(data))
  .handler(async ({ data }) => {
    const { supabaseAdmin } = await import("@/integrations/supabase/client.server");
    const { error } = await supabaseAdmin.from("profiles").insert({
      id: data.userId,
      full_name: data.fullName,
      role: data.role,
    });
    if (error) {
      throw new Error(error.message);
    }
    return { ok: true };
  });
