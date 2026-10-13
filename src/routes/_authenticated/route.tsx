import { createFileRoute, Outlet, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";

export const Route = createFileRoute("/_authenticated")({
  ssr: false,
  component: AuthenticatedLayout,
});

function AuthenticatedLayout() {
  const navigate = useNavigate();
  const [checking, setChecking] = useState(true);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  useEffect(() => {
    let mounted = true;
    let timer: ReturnType<typeof setTimeout> | undefined;

    const accept = () => {
      if (!mounted) return;
      setIsAuthenticated(true);
      setChecking(false);
    };

    // Écoute onAuthStateChange au cas où les tokens sont encore en cours de chargement
    // (retour OAuth, synchronisation entre onglets…).
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, currentSession) => {
      if (currentSession) accept();
    });

    supabase.auth
      .getSession()
      .then(({ data: { session } }) => {
        if (!mounted) return;
        if (session) {
          accept();
          return;
        }
        // Délai de grâce avant de rediriger si vraiment aucune session n'est présente
        timer = setTimeout(async () => {
          const {
            data: { session: finalSession },
          } = await supabase.auth.getSession();
          if (!mounted) return;
          if (finalSession) accept();
          else navigate({ to: "/auth", replace: true });
        }, 1200);
      })
      .catch((err: unknown) => {
        console.error("Auth check error:", err);
        if (mounted) navigate({ to: "/auth", replace: true });
      });

    return () => {
      mounted = false;
      clearTimeout(timer);
      subscription.unsubscribe();
    };
  }, [navigate]);

  if (checking) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background text-foreground">
        <div className="flex flex-col items-center gap-3">
          <div className="size-8 animate-spin rounded-full border-2 border-primary border-t-transparent" />
          <p className="text-xs text-muted-foreground">Chargement de votre espace…</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return null;
  }

  return <Outlet />;
}

