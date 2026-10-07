import { createFileRoute, Outlet, Link, useNavigate } from "@tanstack/react-router";
import { useEffect } from "react";
import { ShieldAlert, Lock, ArrowLeft, LogOut, CheckCircle2 } from "lucide-react";
import { AdminShell } from "@/components/admin-shell";
import { useProfile } from "@/lib/use-profile";
import { Button } from "@/components/ui/button";
import { supabase } from "@/integrations/supabase/client";
import { recordSecurityAudit } from "@/lib/site-analytics";

export const Route = createFileRoute("/_authenticated/admin")({
  component: AdminLayout,
});

function AdminLayout() {
  const navigate = useNavigate();
  const { data: profile, isLoading } = useProfile();

  const isAuthorized = profile && (profile.role === "super_admin" || profile.role === "admin");

  useEffect(() => {
    if (!isLoading && profile) {
      if (!isAuthorized) {
        recordSecurityAudit(
          `Tentative d'accès non autorisé refusée (Utilisateur: ${profile.full_name || profile.id}, Rôle: ${profile.role})`,
          "blocked",
        );
      } else {
        recordSecurityAudit(
          `Accès session Administrateur autorisé (Utilisateur: ${profile.full_name || profile.id})`,
          "success",
        );
      }
    }
  }, [isLoading, profile, isAuthorized]);

  // Si le profil est chargé et n'a pas les droits administrateur
  if (!isLoading && profile && !isAuthorized) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-slate-950 px-4 text-white">
        <div className="w-full max-w-md rounded-3xl border border-red-500/30 bg-slate-900/90 p-8 text-center shadow-2xl backdrop-blur-xl">
          <div className="mx-auto flex size-16 items-center justify-center rounded-2xl border border-red-500/40 bg-red-500/15 text-red-400 shadow-lg shadow-red-950/50">
            <ShieldAlert className="size-8" />
          </div>

          <div className="mt-4 inline-flex items-center gap-1.5 rounded-full border border-red-500/30 bg-red-500/10 px-3 py-1 text-xs font-bold uppercase tracking-wider text-red-400">
            <Lock className="size-3" /> Zone de Sécurité Restreinte
          </div>

          <h1 className="mt-4 font-display text-2xl font-black text-white">
            Accès Administrateur Refusé
          </h1>

          <p className="mt-2 text-sm text-slate-300 leading-relaxed">
            Ce tableau de bord et les statistiques de la plateforme M'ANDAL sont strictement réservés à la direction et aux comptes administrateurs certifiés.
          </p>

          <div className="mt-6 rounded-2xl border border-slate-800 bg-slate-950 p-4 text-left text-xs space-y-1.5 text-slate-400">
            <div className="flex justify-between">
              <span>Compte connecté :</span>
              <span className="font-semibold text-white">{profile.full_name || "Utilisateur"}</span>
            </div>
            <div className="flex justify-between">
              <span>Rôle actuel :</span>
              <span className="rounded bg-slate-800 px-2 py-0.5 font-bold uppercase text-amber-400">
                {profile.role}
              </span>
            </div>
            <div className="flex justify-between">
              <span>Contrôle RBAC :</span>
              <span className="font-semibold text-red-400">Droits insuffisants</span>
            </div>
          </div>

          <div className="mt-6 flex flex-col gap-2.5">
            <Button
              asChild
              className="rounded-xl bg-emerald-600 font-bold text-white hover:bg-emerald-500"
            >
              <Link to="/etudiant">
                <ArrowLeft className="mr-2 size-4" /> Retour à mon espace
              </Link>
            </Button>
            <Button
              variant="outline"
              onClick={async () => {
                await supabase.auth.signOut();
                navigate({ to: "/auth", replace: true });
              }}
              className="rounded-xl border-slate-800 bg-slate-900 text-slate-300 hover:bg-slate-800 hover:text-white"
            >
              <LogOut className="mr-2 size-4" /> Se connecter avec un compte Administrateur
            </Button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <AdminShell>
      <Outlet />
    </AdminShell>
  );
}
