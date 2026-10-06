import { createFileRoute, Link } from "@tanstack/react-router";
import { useState } from "react";
import { BookOpen } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useClasse, useClasseExamens } from "@/lib/use-classes";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/_authenticated/enseignant/classes/$classId")({
  component: ClassDetailPage,
  head: () => ({
    meta: [
      { title: "Fiche classe — M'Andal" },
      { name: "description", content: "Détail d'une classe : examens, apprenants et analyse." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const tabs = ["Vue d'ensemble", "Examens"] as const;

function ClassDetailPage() {
  const { classId } = Route.useParams();
  const { data: schoolClass, isLoading } = useClasse(classId);
  const { data: examens = [] } = useClasseExamens(classId);
  const [activeTab, setActiveTab] = useState<(typeof tabs)[number]>("Vue d'ensemble");

  if (isLoading) {
    return <div className="h-40 animate-pulse rounded-2xl bg-card shadow-sm" />;
  }

  if (!schoolClass) {
    return (
      <div className="space-y-4">
        <h1 className="font-display text-2xl font-bold">Classe introuvable</h1>
        <Button asChild variant="outline" className="rounded-xl">
          <Link to="/enseignant/classes">Retour aux classes</Link>
        </Button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="font-display text-3xl font-bold tracking-tight text-foreground">
          {schoolClass.nom}
        </h1>
        <p className="mt-2 text-sm text-muted-foreground">
          {[schoolClass.annee_scolaire, schoolClass.niveau, schoolClass.filiere]
            .filter(Boolean)
            .join(" · ") || "Aucun détail renseigné"}
        </p>
      </div>

      <div className="flex gap-1 overflow-x-auto border-b border-border">
        {tabs.map((tab) => (
          <button
            key={tab}
            type="button"
            onClick={() => setActiveTab(tab)}
            className={cn(
              "whitespace-nowrap px-4 py-2 text-sm font-medium transition-colors",
              activeTab === tab
                ? "border-b-2 border-primary text-primary"
                : "text-muted-foreground hover:text-foreground",
            )}
          >
            {tab}
          </button>
        ))}
      </div>

      {activeTab === "Examens" ? (
        examens.length > 0 ? (
          <div className="grid gap-4 sm:grid-cols-2">
            {examens.map((exam) => (
              <div key={exam.id} className="rounded-2xl bg-card p-6 shadow-sm">
                <h3 className="font-display text-base font-bold text-foreground">{exam.titre}</h3>
                <p className="mt-2 text-sm text-muted-foreground">
                  {exam.date_debut
                    ? new Date(exam.date_debut).toLocaleDateString("fr-FR")
                    : "Date non planifiée"}{" "}
                  · {exam.duree_minutes} min · {exam.nb_questions} questions
                </p>
              </div>
            ))}
          </div>
        ) : (
          <div className="rounded-2xl bg-card p-12 text-center shadow-sm">
            <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-secondary">
              <BookOpen className="h-6 w-6 text-muted-foreground" />
            </div>
            <p className="mt-4 text-sm text-muted-foreground">
              Aucun examen prévu pour cette classe.
            </p>
          </div>
        )
      ) : (
        <div className="grid gap-4 sm:grid-cols-3">
          <div className="rounded-2xl bg-card p-6 shadow-sm">
            <p className="text-xs uppercase text-muted-foreground">Effectif</p>
            <p className="mt-1 font-display text-2xl font-bold">{schoolClass.effectif}</p>
          </div>
          <div className="rounded-2xl bg-card p-6 shadow-sm">
            <p className="text-xs uppercase text-muted-foreground">Examens</p>
            <p className="mt-1 font-display text-2xl font-bold">{examens.length}</p>
          </div>
          <div className="rounded-2xl bg-card p-6 shadow-sm">
            <p className="text-xs uppercase text-muted-foreground">Année scolaire</p>
            <p className="mt-1 font-display text-2xl font-bold">
              {schoolClass.annee_scolaire ?? "—"}
            </p>
          </div>
        </div>
      )}
    </div>
  );
}
