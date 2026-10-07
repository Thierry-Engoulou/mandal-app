import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";

export const Route = createFileRoute("/auth/callback")({
  component: AuthCallback,
});

function AuthCallback() {
  const navigate = useNavigate();
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    async function handleAuth() {
      try {
        // 1. Vérifier si un code PKCE est présent dans l'URL (?code=...)
        const searchParams = new URLSearchParams(window.location.search);
        const code = searchParams.get("code");

        if (code) {
          const { data, error } = await supabase.auth.exchangeCodeForSession(code);
          if (error) {
            console.error("Error exchanging code for session:", error);
            if (isMounted) setErrorMsg(error.message);
          } else if (data.session) {
            await syncProfileAndRedirect(data.session);
            return;
          }
        }

        // 2. Vérifier si des tokens sont dans le hash (#access_token=...)
        const hashParams = new URLSearchParams(window.location.hash.substring(1));
        const accessToken = hashParams.get("access_token");
        const refreshToken = hashParams.get("refresh_token");

        if (accessToken && refreshToken) {
          const { data, error } = await supabase.auth.setSession({
            access_token: accessToken,
            refresh_token: refreshToken,
          });
          if (!error && data.session) {
            await syncProfileAndRedirect(data.session);
            return;
          }
        }

        // 3. Vérifier si une session existe déjà
        const { data: { session } } = await supabase.auth.getSession();
        if (session) {
          await syncProfileAndRedirect(session);
          return;
        }

        // 4. Écouter l'événement SIGNED_IN de Supabase avec un court délai
        const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, currentSession) => {
          if ((event === "SIGNED_IN" || event === "INITIAL_SESSION") && currentSession) {
            subscription.unsubscribe();
            await syncProfileAndRedirect(currentSession);
          }
        });

        // Timeout de sécurité au cas où l'utilisateur a annulé
        setTimeout(() => {
          if (isMounted) {
            supabase.auth.getSession().then(({ data: { session: finalSession } }) => {
              if (finalSession) {
                syncProfileAndRedirect(finalSession);
              } else {
                navigate({ to: "/auth", replace: true });
              }
            });
          }
        }, 3000);

      } catch (err: any) {
        console.error("Auth callback error:", err);
        if (isMounted) setErrorMsg(err.message || "Erreur de connexion");
      }
    }

    async function syncProfileAndRedirect(session: any) {
      if (!session?.user) {
        navigate({ to: "/auth", replace: true });
        return;
      }

      const user = session.user;
      const meta = user.user_metadata || {};

      try {
        // Vérifier le profil dans public.profiles
        const { data: existingProfile } = await supabase
          .from("profiles")
          .select("id, role, full_name")
          .eq("id", user.id)
          .maybeSingle();

        if (!existingProfile) {
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
      } catch (e) {
        console.error("Profile sync exception:", e);
        navigate({ to: "/etudiant", replace: true });
      }
    }

    handleAuth();

    return () => {
      isMounted = false;
    };
  }, [navigate]);

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-950 text-white px-4">
      <div className="w-full max-w-sm rounded-3xl border border-slate-800 bg-slate-900/90 p-8 text-center shadow-2xl">
        {errorMsg ? (
          <div>
            <p className="text-sm text-red-400">{errorMsg}</p>
            <button
              onClick={() => navigate({ to: "/auth", replace: true })}
              className="mt-4 rounded-xl bg-slate-800 px-4 py-2 text-xs font-bold text-white hover:bg-slate-700"
            >
              Retour à la connexion
            </button>
          </div>
        ) : (
          <div>
            <div className="mx-auto size-10 animate-spin rounded-full border-3 border-emerald-400 border-t-transparent" />
            <h2 className="mt-4 font-display text-lg font-bold text-white">Connexion avec Google</h2>
            <p className="mt-1 text-xs text-slate-400">
              Synchronisation de votre profil M'ANDAL en cours…
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
