import { createFileRoute } from "@tanstack/react-router";
import { Video, Music, FileText } from "lucide-react";
import { useChefSchool, useChefResources, useResourceDecision } from "@/lib/use-chef";
import { ChefNoSchool } from "@/components/chef-empty";
import { TeacherStatusBadge } from "@/components/teacher-status-badge";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";

export const Route = createFileRoute("/_authenticated/etablissement/validation-contenus")({
  component: ValidationContenusPage,
  head: () => ({
    meta: [
      { title: "Validation des contenus — MANDAL" },
      {
        name: "description",
        content: "Approuvez ou rejetez les ressources déposées par vos enseignants.",
      },
      { name: "robots", content: "noindex" },
      { property: "og:title", content: "Validation des contenus — MANDAL" },
      {
        property: "og:description",
        content: "Approuvez ou rejetez les ressources déposées par vos enseignants.",
      },
    ],
  }),
});

const TYPE_META = {
  video: { label: "Vidéo", icon: Video },
  audio: { label: "Audio", icon: Music },
  document: { label: "Document", icon: FileText },
} as const;

function ValidationContenusPage() {
  const { etabId, isLoading } = useChefSchool();
  const { data: pending = [], isLoading: listLoading } = useChefResources(etabId, "en_attente");
  const { data: approved = [] } = useChefResources(etabId, "approuve");
  const decide = useResourceDecision(etabId);

  if (isLoading) return <Skeleton className="h-40 rounded-2xl" />;
  if (!etabId) return <ChefNoSchool />;

  return (
    <div className="space-y-6">
      <header>
        <h1 className="font-display text-2xl font-bold text-foreground">Validation contenus</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          {pending.length} contenu(s) en attente de publication.
        </p>
      </header>

      <section className="rounded-2xl bg-card p-6 shadow-sm">
        <h2 className="font-display text-lg font-semibold text-foreground">Contenus en attente</h2>
        {listLoading ? (
          <Skeleton className="mt-4 h-24 rounded-xl" />
        ) : pending.length === 0 ? (
          <p className="mt-2 text-sm text-muted-foreground">Aucun contenu en attente.</p>
        ) : (
          <ul className="mt-4 divide-y divide-border">
            {pending.map((r) => {
              const meta = TYPE_META[r.type] ?? TYPE_META.document;
              return (
                <li key={r.id} className="flex flex-wrap items-center justify-between gap-3 py-3">
                  <div className="flex min-w-0 items-center gap-3">
                    <span className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-violet/10 text-violet">
                      <meta.icon className="size-5" />
                    </span>
                    <div className="min-w-0">
                      <p className="truncate text-sm font-medium text-foreground">{r.titre}</p>
                      <p className="text-xs text-muted-foreground">
                        {meta.label} · {new Date(r.created_at).toLocaleDateString("fr-FR")}
                      </p>
                    </div>
                  </div>
                  <div className="flex shrink-0 items-center gap-2">
                    <TeacherStatusBadge status="en_attente" />
                    <Button
                      size="sm"
                      disabled={decide.isPending}
                      onClick={() => decide.mutate({ resourceId: r.id, decision: "approuve" })}
                    >
                      Approuver
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      className="text-destructive"
                      disabled={decide.isPending}
                      onClick={() => decide.mutate({ resourceId: r.id, decision: "rejete" })}
                    >
                      Rejeter
                    </Button>
                  </div>
                </li>
              );
            })}
          </ul>
        )}
      </section>

      <section className="rounded-2xl bg-card p-6 shadow-sm">
        <h2 className="font-display text-lg font-semibold text-foreground">Contenus publiés</h2>
        {approved.length === 0 ? (
          <p className="mt-2 text-sm text-muted-foreground">Aucun contenu publié.</p>
        ) : (
          <ul className="mt-4 divide-y divide-border">
            {approved.slice(0, 20).map((r) => {
              const meta = TYPE_META[r.type] ?? TYPE_META.document;
              return (
                <li key={r.id} className="flex items-center justify-between gap-3 py-3">
                  <p className="truncate text-sm font-medium text-foreground">{r.titre}</p>
                  <div className="flex shrink-0 items-center gap-3">
                    <span className="text-xs text-muted-foreground">{meta.label}</span>
                    <TeacherStatusBadge status="approuve" />
                  </div>
                </li>
              );
            })}
          </ul>
        )}
      </section>
    </div>
  );
}
