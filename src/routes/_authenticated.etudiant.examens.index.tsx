import { createFileRoute, Link } from "@tanstack/react-router";
import { Clock, FileQuestion, CheckCircle2, Lock } from "lucide-react";
import { useStudentExamensWithLock } from "@/lib/use-student-examens";
import { Skeleton } from "@/components/ui/skeleton";

export const Route = createFileRoute("/_authenticated/etudiant/examens/")({
  component: StudentExamsPage,
  head: () => ({
    meta: [
      { title: "Examens — MANDAL" },
      { name: "description", content: "Passez vos examens chronométrés MANDAL." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function StudentExamsPage() {
  const { data, isLoading } = useStudentExamensWithLock();

  return (
    <div className="space-y-6">
      <header className="gradient-welcome rounded-2xl p-6 text-primary-foreground shadow-sm">
        <p className="text-sm/6 opacity-90">Évaluation</p>
        <h1 className="font-display text-2xl font-bold tracking-tight">Examens</h1>
        <p className="mt-1 text-sm opacity-90">
          Chaque examen est chronométré. Une fois lancé, terminez-le en une seule session.
        </p>
      </header>

      {isLoading ? (
        <div className="grid gap-4 sm:grid-cols-2">
          <Skeleton className="h-36 rounded-2xl" />
          <Skeleton className="h-36 rounded-2xl" />
        </div>
      ) : !data || data.length === 0 ? (
        <div className="rounded-2xl bg-card p-10 text-center shadow-sm">
          <p className="text-sm text-muted-foreground">
            Aucun examen publié pour votre établissement pour l'instant.
          </p>
        </div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2">
          {data.map((examen) => (
            <div key={examen.id} className="flex flex-col rounded-2xl bg-card p-5 shadow-sm">
              <div className="flex items-start justify-between gap-2">
                <h2 className="font-display text-lg font-semibold text-foreground">{examen.titre}</h2>
                {examen.lock.isLocked ? <Lock className="size-5 shrink-0 text-muted-foreground" /> : null}
              </div>
              {examen.description ? (
                <p className="mt-1 line-clamp-2 text-sm text-muted-foreground">{examen.description}</p>
              ) : null}
              <div className="mt-3 flex flex-wrap gap-3 text-sm text-muted-foreground">
                <span className="inline-flex items-center gap-1.5">
                  <Clock className="size-4" /> {examen.duree_minutes} min
                </span>
                <span className="inline-flex items-center gap-1.5">
                  <FileQuestion className="size-4" /> {examen.nb_questions} questions
                </span>
              </div>

              {examen.lock.isLocked ? (
                <p className="mt-3 rounded-xl bg-warning/10 px-3 py-2 text-xs font-medium text-warning">
                  Complétez les {examen.lock.totalConcepts} leçons du chapitre « {examen.lock.chapitreTitre} »
                  pour déverrouiller ce quiz ({examen.lock.conceptsTermines}/{examen.lock.totalConcepts} faites).
                </p>
              ) : null}

              <div className="mt-5 flex items-center justify-between">
                {examen.score !== null ? (
                  <span className="inline-flex items-center gap-1.5 text-sm font-semibold text-success">
                    <CheckCircle2 className="size-4" /> {examen.score} / 20
                  </span>
                ) : (
                  <span className="text-sm text-muted-foreground">Non passé</span>
                )}
                {examen.lock.isLocked ? (
                  <button
                    disabled
                    className="cursor-not-allowed rounded-xl bg-muted px-4 py-2 text-sm font-semibold text-muted-foreground"
                  >
                    <Lock className="mr-1.5 inline size-3.5" /> Verrouillé
                  </button>
                ) : (
                  <Link
                    to="/etudiant/examens/$examenId"
                    params={{ examenId: examen.id }}
                    className="rounded-xl bg-primary px-4 py-2 text-sm font-semibold text-primary-foreground"
                  >
                    {examen.score !== null ? "Revoir" : "Commencer"}
                  </Link>
                )}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
