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

    async function checkAuth() {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (!mounted) return;

        if (session) {
          setIsAuthenticated(true);
          setChecking(false);
          return;
        }

        // Si pas de session immédiate, écouter onAuthStateChange (au cas où les tokens sont en cours de chargement)
        const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, currentSession) => {
          if (!mounted) return;
          if (currentSession) {
            setIsAuthenticated(true);
            setChecking(false);
          }
        });

        // Délai de grâce avant de rediriger si vraiment aucune session n'est présente
        const timer = setTimeout(() => {
          if (mounted) {
            supabase.auth.getSession().then(({ data: { session: finalSession } }) => {
              if (mounted) {
                if (finalSession) {
                  setIsAuthenticated(true);
                  setChecking(false);
                } else {
                  navigate({ to: "/auth", replace: true });
                }
              }
            });
          }
        }, 1200);

        return () => {
          subscription.unsubscribe();
          clearTimeout(timer);
        };
      } catch (err) {
        console.error("Auth check error:", err);
        if (mounted) navigate({ to: "/auth", replace: true });
      }
    }

    checkAuth();

    return () => {
      mounted = false;
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

