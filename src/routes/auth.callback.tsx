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
      if (session) {
        const { data: profile } = await supabase
          .from("profiles")
          .select("role")
          .eq("id", session.user.id)
          .maybeSingle();

        if (profile?.role === "admin" || profile?.role === "super_admin") {
          navigate({ to: "/admin", replace: true });
        } else if (profile?.role === "teacher") {
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
        <p className="mt-4 text-sm text-slate-300">Connexion sécurisée en cours…</p>
      </div>
    </div>
  );
}
