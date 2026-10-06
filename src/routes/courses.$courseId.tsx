import { createFileRoute, Link } from "@tanstack/react-router";
import { useSuspenseQuery, queryOptions } from "@tanstack/react-query";
import { getCourse } from "@/lib/courses.functions";
import { Button } from "@/components/ui/button";
import { MandalLogo } from "@/components/mandal-logo";
import { ArrowLeft, BookOpen, CalendarDays, GraduationCap } from "lucide-react";

const courseQueryOptions = (id: string) =>
  queryOptions({
    queryKey: ["course", id],
    queryFn: () => getCourse({ data: { id } }),
  });

export const Route = createFileRoute("/courses/$courseId")({
  loader: ({ context, params }) => context.queryClient.ensureQueryData(courseQueryOptions(params.courseId)),
  component: CourseDetailPage,
  head: ({ loaderData }) => ({
    meta: [
      { title: loaderData ? `${loaderData.title} — MANDAL` : "Module — MANDAL" },
      { name: "description", content: loaderData ? `Module ${loaderData.title} sur ${loaderData.pillarLabel}.` : "Module de cours MANDAL." },
      { property: "og:title", content: loaderData ? `${loaderData.title} — MANDAL` : "Module — MANDAL" },
      { property: "og:description", content: loaderData ? `Module ${loaderData.title} sur ${loaderData.pillarLabel}.` : "Module de cours MANDAL." },
      { property: "og:type", content: "article" },
      { name: "twitter:card", content: "summary" },
    ],
  }),
});

function CourseDetailPage() {
  const { courseId } = Route.useParams();
  const { data: course } = useSuspenseQuery(courseQueryOptions(courseId));

  return (
    <div className="min-h-screen bg-background">
      <header className="sticky top-0 z-10 border-b border-border bg-card/95 backdrop-blur">
        <div className="mx-auto flex h-16 max-w-5xl items-center justify-between px-5 lg:px-8">
          <Link to="/" aria-label="Retour à l'accueil MANDAL">
            <MandalLogo />
          </Link>
          <Button asChild variant="ghost" size="sm" className="rounded-full">
            <Link to="/etudiant/cours">
              <ArrowLeft className="size-4" />
              Retour à mes cours
            </Link>
          </Button>
        </div>
      </header>

      <main className="mx-auto max-w-5xl space-y-6 px-5 py-8 lg:px-8">
        <section className="gradient-welcome relative overflow-hidden rounded-2xl p-6 text-primary-foreground shadow-sm md:p-8">
          <div className="absolute -right-6 -top-6 flex size-32 items-center justify-center rounded-full bg-white/10">
            <GraduationCap className="size-14" aria-hidden="true" />
          </div>
          <p className="text-xs font-bold uppercase tracking-wide opacity-80">Module de cours</p>
          <h1 className="mt-2 max-w-2xl font-display text-2xl font-bold md:text-3xl">{course.title}</h1>
          <div className="mt-4 flex flex-wrap items-center gap-2">
            <span className="rounded-full bg-white/20 px-3 py-1 text-xs font-semibold">{course.pillarLabel}</span>
            <span className="rounded-full bg-white/20 px-3 py-1 text-xs font-semibold">{course.levelLabel}</span>
            <span className="flex items-center gap-1.5 rounded-full bg-white/20 px-3 py-1 text-xs font-semibold">
              <CalendarDays className="size-3.5" aria-hidden="true" />
              Publié le {new Date(course.created_at).toLocaleDateString("fr-FR")}
            </span>
          </div>
        </section>

        <article className="rounded-2xl bg-card p-6 shadow-sm md:p-8">
          <div className="mb-4 flex items-center gap-2 text-primary">
            <BookOpen className="size-5" aria-hidden="true" />
            <h2 className="font-display text-lg font-bold">Contenu du module</h2>
          </div>
          <div className="whitespace-pre-wrap leading-relaxed text-foreground">
            {course.content}
          </div>
        </article>
      </main>
    </div>
  );
}
