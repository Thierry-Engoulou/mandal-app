import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";

export const Route = createFileRoute("/auth/callback")({
  component: AuthCallback,
});

function AuthCallback() {
  const navigate = useNavigate();

  useEffect(() => {
    supabase.auth.getSession().then(async ({ data: { session } }) => {
      if (session && session.user) {
        const user = session.user;
        const meta = user.user_metadata || {};

        // S'assurer que le profil existe et contient les données Google dans public.profiles
        const { data: existingProfile } = await supabase
          .from("profiles")
          .select("id, role, full_name")
          .eq("id", user.id)
          .maybeSingle();

        if (!existingProfile) {
          // Création automatique du profil Google avec nom, prénom et photo
          const fullName = meta.full_name || meta.name || user.email?.split("@")[0] || "Utilisateur";
          await supabase.from("profiles").insert({
            id: user.id,
            role: "student",
            full_name: fullName,
            nom: meta.family_name || null,
            prenom: meta.given_name || null,
            avatar_url: meta.avatar_url || meta.picture || null,
          });
        }

        const role = existingProfile?.role || "student";

        if (role === "admin" || role === "super_admin") {
          navigate({ to: "/admin", replace: true });
        } else if (role === "teacher") {
          navigate({ to: "/enseignant", replace: true });
        } else {
          navigate({ to: "/etudiant", replace: true });
        }
      } else {
        navigate({ to: "/auth", replace: true });
      }
    });
  }, [navigate]);

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-950 text-white">
      <div className="text-center">
        <div className="mx-auto size-8 animate-spin rounded-full border-2 border-emerald-400 border-t-transparent" />
        <p className="mt-4 text-sm text-slate-300">Synchronisation des données Google avec M'ANDAL…</p>
      </div>
    </div>
  );
}
