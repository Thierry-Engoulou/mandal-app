import { createFileRoute, Link } from "@tanstack/react-router";
import { AlertTriangle, Clock, FileWarning } from "lucide-react";
import { useChefSchool, useChefValidations, useChefResources } from "@/lib/use-chef";
import { ChefNoSchool } from "@/components/chef-empty";
import { Skeleton } from "@/components/ui/skeleton";

export const Route = createFileRoute("/_authenticated/etablissement/alertes")({
  component: AlertesPage,
  head: () => ({
    meta: [
      { title: "Alertes établissement — MANDAL" },
      { name: "description", content: "Demandes et contenus nécessitant votre attention." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const SEUIL_JOURS = 3;

function joursDepuis(date: string) {
  return Math.floor((Date.now() - new Date(date).getTime()) / 86_400_000);
}

function AlertesPage() {
  const { etabId, isLoading } = useChefSchool();
  const { data: validations = [] } = useChefValidations(etabId);
  const { data: resources = [] } = useChefResources(etabId, "en_attente");

  if (isLoading) return <Skeleton className="h-40 rounded-2xl" />;
  if (!etabId) return <ChefNoSchool />;

  const pending = validations.filter((v) => v.statut === "en_attente");
  const late = pending.filter((v) => joursDepuis(v.created_at) >= SEUIL_JOURS);

  const alerts = [
    ...late.map((v) => ({
      id: `late-${v.id}`,
      icon: Clock,
      titre: `${v.nom} attend une validation depuis ${joursDepuis(v.created_at)} jours`,
      to: "/etablissement/validation-enseignants" as const,
      niveau: "urgent" as const,
    })),
    ...pending
      .filter((v) => joursDepuis(v.created_at) < SEUIL_JOURS)
      .map((v) => ({
        id: `pend-${v.id}`,
        icon: AlertTriangle,
        titre: `Demande de validation enseignant : ${v.nom}`,
        to: "/etablissement/validation-enseignants" as const,
        niveau: "normal" as const,
      })),
    ...resources.map((r) => ({
      id: `res-${r.id}`,
      icon: FileWarning,
      titre: `Contenu en attente : ${r.titre}`,
      to: "/etablissement/validation-contenus" as const,
      niveau: "normal" as const,
    })),
  ];

  return (
    <div className="space-y-6">
      <header>
        <h1 className="font-display text-2xl font-bold text-foreground">Alertes</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Actions nécessitant votre attention dans votre établissement.
        </p>
      </header>

      {alerts.length === 0 ? (
        <div className="rounded-2xl bg-card p-6 text-sm text-muted-foreground shadow-sm">
          Aucune alerte : tout est à jour.
        </div>
      ) : (
        <ul className="space-y-3">
          {alerts.map((a) => (
            <li
              key={a.id}
              className="flex items-center justify-between gap-3 rounded-2xl bg-card p-4 shadow-sm"
            >
              <div className="flex min-w-0 items-center gap-3">
                <span
                  className={
                    a.niveau === "urgent"
                      ? "flex size-9 shrink-0 items-center justify-center rounded-xl bg-destructive/10 text-destructive"
                      : "flex size-9 shrink-0 items-center justify-center rounded-xl bg-warning/15 text-warning"
                  }
                >
                  <a.icon className="size-4" />
                </span>
                <p className="truncate text-sm text-foreground">{a.titre}</p>
              </div>
              <Link to={a.to} className="shrink-0 text-sm font-medium text-violet">
                Traiter
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
