import { createFileRoute } from "@tanstack/react-router";
import { useEffect } from "react";
import { supabase } from "@/integrations/supabase/client";
import { useNavigate } from "@tanstack/react-router";

export const Route = createFileRoute("/auth/callback")({
  component: AuthCallback,
});

function AuthCallback() {
  const navigate = useNavigate();

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      if (session) {
        navigate({ to: "/courses" });
      } else {
        navigate({ to: "/auth" });
      }
    });
  }, [navigate]);

  return (
    <div className="flex min-h-screen items-center justify-center">
      <p className="text-muted-foreground">Connexion en cours…</p>
    </div>
  );
}
