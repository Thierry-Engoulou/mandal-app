import { createFileRoute, Link } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { Users, Mail, School, GraduationCap } from "lucide-react";
import { listAdminUsers, listAdminInvitations, listEtablissements } from "@/lib/admin.functions";
import { Skeleton } from "@/components/ui/skeleton";

export const Route = createFileRoute("/_authenticated/admin/")({
  component: AdminHomePage,
  head: () => ({
    meta: [
      { title: "Administration — MANDAL" },
      { name: "description", content: "Pilotage de la plateforme MANDAL." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function AdminHomePage() {
  const users = useServerFn(listAdminUsers);
  const invitations = useServerFn(listAdminInvitations);
  const etabs = useServerFn(listEtablissements);

  const { data, isLoading } = useQuery({
    queryKey: ["admin-overview"],
    queryFn: async () => {
      const [u, i, e] = await Promise.all([users(), invitations(), etabs()]);
      return {
        users: u,
        invitations: i,
        etablissements: e,
      };
    },
  });

  const cards = [
    { label: "Comptes", value: data?.users.length ?? 0, icon: Users },
    {
      label: "Enseignants",
      value: data?.users.filter((u) => u.role === "teacher").length ?? 0,
      icon: GraduationCap,
    },
    { label: "Établissements", value: data?.etablissements.length ?? 0, icon: School },
    {
      label: "Invitations en attente",
      value: data?.invitations.filter((i) => i.statut === "en_attente").length ?? 0,
      icon: Mail,
    },
  ];

  return (
    <div className="space-y-6">
      <header className="gradient-progress rounded-2xl p-6 text-primary-foreground shadow-sm">
        <h1 className="font-display text-2xl font-bold tracking-tight">Administration MANDAL</h1>
        <p className="mt-1 text-sm opacity-90">
          Gérez les comptes, les rôles et les invitations des chefs d'établissement.
        </p>
      </header>

      {isLoading ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {[0, 1, 2, 3].map((i) => (
            <Skeleton key={i} className="h-28 rounded-2xl" />
          ))}
        </div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {cards.map((c) => (
            <div key={c.label} className="rounded-2xl bg-card p-5 shadow-sm">
              <span className="flex size-10 items-center justify-center rounded-xl bg-violet/10 text-violet">
                <c.icon className="size-5" />
              </span>
              <p className="mt-3 font-display text-2xl font-bold text-foreground">{c.value}</p>
              <p className="text-sm text-muted-foreground">{c.label}</p>
            </div>
          ))}
        </div>
      )}

      <div className="grid gap-4 sm:grid-cols-2">
        <Link to="/admin/utilisateurs" className="rounded-2xl bg-card p-6 shadow-sm hover:shadow-md">
          <h2 className="font-display text-lg font-semibold text-foreground">Utilisateurs</h2>
          <p className="mt-1 text-sm text-muted-foreground">
            Modifier les rôles, rattacher un établissement, valider les enseignants.
          </p>
        </Link>
        <Link to="/admin/demandes" className="rounded-2xl bg-card p-6 shadow-sm hover:shadow-md">
          <h2 className="font-display text-lg font-semibold text-foreground">Demandes d'inscription</h2>
          <p className="mt-1 text-sm text-muted-foreground">
            Consulter et traiter les demandes d'accès reçues.
          </p>
        </Link>
      </div>
    </div>
  );
}
