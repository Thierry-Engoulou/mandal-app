import { createFileRoute, Outlet, Link } from "@tanstack/react-router";
import { AdminShell } from "@/components/admin-shell";
import { useProfile } from "@/lib/use-profile";

export const Route = createFileRoute("/_authenticated/admin")({
  component: AdminLayout,
});

function AdminLayout() {
  const { data: profile, isLoading } = useProfile();

  if (!isLoading && profile && profile.role !== "super_admin" && profile.role !== "admin") {
    return (
      <div className="flex min-h-screen items-center justify-center px-4">
        <div className="max-w-sm text-center">
          <h1 className="font-display text-xl font-bold text-foreground">Accès réservé</h1>
          <p className="mt-2 text-sm text-muted-foreground">
            Cet espace est réservé aux administrateurs de la plateforme.
          </p>
          <Link to="/etudiant" className="mt-6 inline-block text-sm font-medium text-primary">
            Retour à mon espace
          </Link>
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
