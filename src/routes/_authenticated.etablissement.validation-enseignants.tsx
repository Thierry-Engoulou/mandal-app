import { createFileRoute } from "@tanstack/react-router";
import { useChefSchool, useChefValidations, useTeacherDecision } from "@/lib/use-chef";
import { ChefNoSchool } from "@/components/chef-empty";
import { TeacherStatusBadge } from "@/components/teacher-status-badge";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";

export const Route = createFileRoute("/_authenticated/etablissement/validation-enseignants")({
  component: ValidationEnseignantsPage,
  head: () => ({
    meta: [
      { title: "Validation des enseignants — MANDAL" },
      {
        name: "description",
        content: "Approuvez ou rejetez les demandes de rattachement des enseignants.",
      },
      { name: "robots", content: "noindex" },
      { property: "og:title", content: "Validation des enseignants — MANDAL" },
      {
        property: "og:description",
        content: "Approuvez ou rejetez les demandes de rattachement des enseignants.",
      },
    ],
  }),
});

function ValidationEnseignantsPage() {
  const { etabId, isLoading } = useChefSchool();
  const { data: validations = [], isLoading: listLoading } = useChefValidations(etabId);
  const decide = useTeacherDecision(etabId);

  if (isLoading) return <Skeleton className="h-40 rounded-2xl" />;
  if (!etabId) return <ChefNoSchool />;

  const pending = validations.filter((v) => v.statut === "en_attente");
  const approved = validations.filter((v) => v.statut === "approuve");

  return (
    <div className="space-y-6">
      <header>
        <h1 className="font-display text-2xl font-bold text-foreground">Validation enseignants</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          {pending.length} demande(s) en attente de votre décision.
        </p>
      </header>

      <section className="rounded-2xl bg-card p-6 shadow-sm">
        <h2 className="font-display text-lg font-semibold text-foreground">Demandes en attente</h2>
        {listLoading ? (
          <Skeleton className="mt-4 h-24 rounded-xl" />
        ) : pending.length === 0 ? (
          <p className="mt-2 text-sm text-muted-foreground">Aucune demande en attente.</p>
        ) : (
          <ul className="mt-4 divide-y divide-border">
            {pending.map((v) => (
              <li key={v.id} className="flex flex-wrap items-center justify-between gap-3 py-3">
                <div className="min-w-0">
                  <p className="truncate text-sm font-medium text-foreground">{v.nom}</p>
                  <p className="text-xs text-muted-foreground">
                    Demande du {new Date(v.created_at).toLocaleDateString("fr-FR")}
                  </p>
                </div>
                <div className="flex shrink-0 items-center gap-2">
                  <TeacherStatusBadge status="en_attente" />
                  <Button
                    size="sm"
                    disabled={decide.isPending}
                    onClick={() =>
                      decide.mutate({
                        validationId: v.id,
                        enseignantId: v.enseignant_id,
                        decision: "approuve",
                      })
                    }
                  >
                    Approuver
                  </Button>
                  <Button
                    size="sm"
                    variant="ghost"
                    className="text-destructive"
                    disabled={decide.isPending}
                    onClick={() =>
                      decide.mutate({
                        validationId: v.id,
                        enseignantId: v.enseignant_id,
                        decision: "rejete",
                      })
                    }
                  >
                    Rejeter
                  </Button>
                </div>
              </li>
            ))}
          </ul>
        )}
      </section>

      <section className="rounded-2xl bg-card p-6 shadow-sm">
        <h2 className="font-display text-lg font-semibold text-foreground">
          Enseignants déjà approuvés
        </h2>
        {approved.length === 0 ? (
          <p className="mt-2 text-sm text-muted-foreground">Aucun enseignant approuvé.</p>
        ) : (
          <ul className="mt-4 divide-y divide-border">
            {approved.map((v) => (
              <li key={v.id} className="flex items-center justify-between gap-3 py-3">
                <p className="truncate text-sm font-medium text-foreground">{v.nom}</p>
                <div className="flex shrink-0 items-center gap-3">
                  <span className="text-xs text-muted-foreground">
                    {v.date_validation
                      ? new Date(v.date_validation).toLocaleDateString("fr-FR")
                      : "—"}
                  </span>
                  <TeacherStatusBadge status="approuve" />
                </div>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}
