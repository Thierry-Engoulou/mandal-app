import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect, useState, useRef } from "react";
import { supabase } from "@/integrations/supabase/client";

export const Route = createFileRoute("/auth/callback")({
  ssr: false,
  component: AuthCallback,
});

function AuthCallback() {
  const navigate = useNavigate();
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [statusText, setStatusText] = useState("Authentification Google en cours…");
  const processedRef = useRef(false);

  useEffect(() => {
    let isMounted = true;

    async function handleAuth() {
      if (processedRef.current) return;

      try {
        setStatusText("Vérification des accès Google…");

        // 1. Vérifier si un code PKCE est présent dans l'URL (?code=...)
        const searchParams = new URLSearchParams(window.location.search);
        const code = searchParams.get("code");
        const error = searchParams.get("error");
        const errorDescription = searchParams.get("error_description");

        if (error) {
          throw new Error(errorDescription || error);
        }

        if (code) {
          setStatusText("Validation de votre jeton sécurisé…");
          const { data, error: exchangeError } = await supabase.auth.exchangeCodeForSession(code);
          
          if (!exchangeError && data?.session) {
            processedRef.current = true;
            await syncProfileAndRedirect(data.session);
            return;
          }
          // Si exchangeCodeForSession a échoué (ex: déjà consommé par auto-détection Supabase),
          // on continue vers la vérification de session existante
          console.warn("exchangeCodeForSession notice:", exchangeError?.message);
        }

        // 2. Vérifier si des tokens sont dans le hash (#access_token=...)
        const hash = window.location.hash.startsWith("#") ? window.location.hash.substring(1) : window.location.hash;
        if (hash) {
          const hashParams = new URLSearchParams(hash);
          const accessToken = hashParams.get("access_token");
          const refreshToken = hashParams.get("refresh_token");

          if (accessToken && refreshToken) {
            setStatusText("Initialisation de la session…");
            const { data: sessionData, error: setSessionErr } = await supabase.auth.setSession({
              access_token: accessToken,
              refresh_token: refreshToken,
            });

            if (!setSessionErr && sessionData?.session) {
              processedRef.current = true;
              await syncProfileAndRedirect(sessionData.session);
              return;
            }
          }
        }

        // 3. Vérifier si une session Supabase active est déjà présente
        const { data: { session } } = await supabase.auth.getSession();
        if (session) {
          processedRef.current = true;
          await syncProfileAndRedirect(session);
          return;
        }

        // 4. Écouter l'événement auth state change pendant 4 secondes max
        const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, currentSession) => {
          if (currentSession && !processedRef.current) {
            processedRef.current = true;
            subscription.unsubscribe();
            await syncProfileAndRedirect(currentSession);
          }
        });

        // 5. Fallback après 3.5 secondes
        setTimeout(async () => {
          if (!isMounted || processedRef.current) return;
          const { data: { session: fallbackSession } } = await supabase.auth.getSession();
          if (fallbackSession) {
            processedRef.current = true;
            await syncProfileAndRedirect(fallbackSession);
          } else {
            console.warn("No active OAuth session found, redirecting to /auth");
            navigate({ to: "/auth", replace: true });
          }
        }, 3500);

      } catch (err: any) {
        console.error("Auth callback error:", err);
        if (isMounted) {
          setErrorMsg(err.message || "Impossible de finaliser la connexion Google.");
        }
      }
    }

    async function syncProfileAndRedirect(session: any) {
      if (!session?.user) {
        navigate({ to: "/auth", replace: true });
        return;
      }

      setStatusText("Préparation de votre espace personnel…");
      const user = session.user;
      const meta = user.user_metadata || {};

      try {
        // Vérifier le profil existant
        const { data: existingProfile } = await supabase
          .from("profiles")
          .select("id, role, full_name, niveau")
          .eq("id", user.id)
          .maybeSingle();

        let role = existingProfile?.role || "student";

        if (!existingProfile) {
          const fullName = meta.full_name || meta.name || user.email?.split("@")[0] || "Étudiant";
          const givenName = meta.given_name || meta.first_name || null;
          const familyName = meta.family_name || meta.last_name || null;
          const avatar = meta.avatar_url || meta.picture || null;

          // Upsert sécurisé avec les champs par défaut
          await supabase.from("profiles").upsert({
            id: user.id,
            role: "student",
            full_name: fullName,
            nom: familyName,
            prenom: givenName,
            avatar_url: avatar,
            niveau: "Terminale",
            statut_validation: "approuve",
            xp_total: 0,
          }, { onConflict: "id" });
        }

        // Redirection selon le rôle
        if (role === "admin" || role === "super_admin") {
          navigate({ to: "/admin", replace: true });
        } else if (role === "teacher") {
          navigate({ to: "/enseignant", replace: true });
        } else {
          navigate({ to: "/etudiant", replace: true });
        }
      } catch (e) {
        console.error("Profile sync exception:", e);
        // Même en cas d'erreur de profil, on dirige vers l'espace étudiant
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
      <div className="w-full max-w-sm rounded-3xl border border-slate-800 bg-slate-900/90 p-8 text-center shadow-2xl backdrop-blur-xl">
        {errorMsg ? (
          <div>
            <div className="mx-auto flex size-12 items-center justify-center rounded-2xl bg-red-500/10 text-red-400">
              ⚠️
            </div>
            <h2 className="mt-4 font-display text-lg font-bold text-white">Connexion interrompue</h2>
            <p className="mt-2 text-xs text-red-400/90 leading-relaxed">{errorMsg}</p>
            <button
              onClick={() => navigate({ to: "/auth", replace: true })}
              className="mt-6 w-full rounded-xl bg-slate-800 py-3 text-xs font-bold text-white transition hover:bg-slate-700"
            >
              Retour à la page de connexion
            </button>
          </div>
        ) : (
          <div>
            <div className="mx-auto size-12 animate-spin rounded-full border-3 border-emerald-400 border-t-transparent shadow-lg shadow-emerald-500/20" />
            <h2 className="mt-5 font-display text-lg font-bold text-white">Connexion avec Google</h2>
            <p className="mt-2 text-xs text-slate-400">
              {statusText}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

