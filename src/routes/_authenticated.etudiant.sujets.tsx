import { createFileRoute, Link } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { BookOpen, Layers } from "lucide-react";
import { listCourses } from "@/lib/courses.functions";
import { Skeleton } from "@/components/ui/skeleton";

export const Route = createFileRoute("/_authenticated/etudiant/sujets")({
  component: StudentSubjectsPage,
  head: () => ({
    meta: [
      { title: "Sujets — MANDAL" },
      { name: "description", content: "Explorez les sujets et matières disponibles sur MANDAL." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function StudentSubjectsPage() {
  const fetchCourses = useServerFn(listCourses);
  const { data, isLoading } = useQuery({ queryKey: ["courses"], queryFn: () => fetchCourses() });

  const groups = new Map<string, { label: string; count: number }>();
  for (const course of data ?? []) {
    const current = groups.get(course.pillar);
    groups.set(course.pillar, {
      label: course.pillarLabel,
      count: (current?.count ?? 0) + 1,
    });
  }
  const subjects = [...groups.entries()];

  return (
    <div className="space-y-6">
      <div className="gradient-welcome rounded-2xl p-6 text-primary-foreground shadow-sm">
        <p className="text-sm/6 opacity-90">Explorer</p>
        <h1 className="font-display text-2xl font-bold tracking-tight">Sujets</h1>
        <p className="mt-1 text-sm opacity-90">
          Les grands domaines à explorer, regroupés par pilier MANDAL.
        </p>
      </div>

      {isLoading ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[0, 1, 2, 3, 4, 5].map((i) => (
            <Skeleton key={i} className="h-32 rounded-2xl" />
          ))}
        </div>
      ) : subjects.length === 0 ? (
        <div className="rounded-2xl bg-card p-10 text-center shadow-sm">
          <p className="text-sm text-muted-foreground">Aucun sujet disponible pour l’instant.</p>
        </div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {subjects.map(([key, subject]) => (
            <Link
              key={key}
              to="/etudiant/cours"
              className="group rounded-2xl bg-card p-5 shadow-sm transition hover:shadow-md"
            >
              <span className="flex size-11 items-center justify-center rounded-xl bg-primary/10 text-primary">
                <Layers className="size-5" />
              </span>
              <h2 className="mt-4 font-display text-lg font-semibold text-foreground">
                {subject.label}
              </h2>
              <p className="mt-1 flex items-center gap-1.5 text-sm text-muted-foreground">
                <BookOpen className="size-4" />
                {subject.count} module{subject.count > 1 ? "s" : ""}
              </p>
              <span className="mt-3 inline-block text-sm font-medium text-primary group-hover:underline">
                Voir les modules ›
              </span>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}
