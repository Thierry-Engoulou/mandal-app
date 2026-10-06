import { createFileRoute, Link } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { listCourses } from "@/lib/courses.functions";
import { Button } from "@/components/ui/button";
import { MandalLogo } from "@/components/mandal-logo";
import { supabase } from "@/integrations/supabase/client";
import { useState, useEffect } from "react";
import type { Session } from "@supabase/supabase-js";
import { GraduationCap } from "lucide-react";

export const Route = createFileRoute("/courses/")({
  component: CoursesPage,
  head: () => ({
    meta: [
      { title: "Modules de cours — MANDAL" },
      { name: "description", content: "Découvrez les modules de cours MANDAL par pilier et niveau." },
      { property: "og:title", content: "Modules de cours — MANDAL" },
      { property: "og:description", content: "Découvrez les modules de cours MANDAL par pilier et niveau." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary" },
    ],
  }),
});

function CoursesPage() {
  const [session, setSession] = useState<Session | null>(null);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => setSession(data.session));
    const { data: listener } = supabase.auth.onAuthStateChange((_event, s) => setSession(s));
    return () => listener.subscription.unsubscribe();
  }, []);

  const { data: courses = [], isLoading } = useQuery({
    queryKey: ["courses"],
    queryFn: () => listCourses(),
  });

  const pillars = Array.from(new Map(courses.map((c) => [c.pillar, c.pillarLabel])).entries());

  return (
    <div className="min-h-screen bg-background">
      <header className="sticky top-0 z-10 border-b border-border bg-card/95 backdrop-blur">
        <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-5 lg:px-8">
          <Link to="/" aria-label="Retour à l'accueil MANDAL">
            <MandalLogo />
          </Link>
          <div className="flex items-center gap-3">
            {session ? (
              <Button asChild className="rounded-full">
                <Link to="/courses/new">Nouveau module</Link>
              </Button>
            ) : (
              <Button asChild variant="outline" className="rounded-full">
                <Link to="/auth">Se connecter</Link>
              </Button>
            )}
          </div>
        </div>
      </header>

      <main className="mx-auto max-w-6xl space-y-6 px-5 py-8 lg:px-8">
        <section className="gradient-welcome rounded-2xl p-6 text-primary-foreground shadow-sm md:p-8">
          <p className="text-xs font-bold uppercase tracking-wide opacity-80">Catalogue</p>
          <h1 className="mt-2 font-display text-2xl font-bold md:text-3xl">Modules de cours</h1>
          <p className="mt-2 max-w-2xl text-sm opacity-90">
            Explorez les modules publiés par piliers et niveaux.
          </p>
        </section>

        {isLoading ? (
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {[0, 1, 2].map((i) => (
              <div key={i} className="h-32 animate-pulse rounded-2xl bg-card shadow-sm" />
            ))}
          </div>
        ) : courses.length === 0 ? (
          <div className="rounded-2xl border border-dashed border-border p-12 text-center">
            <p className="text-muted-foreground">Aucun module publié pour le moment.</p>
            {session && (
              <Button asChild className="mt-4 rounded-full">
                <Link to="/courses/new">Créer le premier module</Link>
              </Button>
            )}
          </div>
        ) : (
          <div className="space-y-10">
            {pillars.map(([pillar, pillarLabel]) => (
              <section key={pillar}>
                <h2 className="mb-4 font-display text-xl font-bold text-foreground">
                  {pillarLabel}
                </h2>
                <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                  {courses
                    .filter((c) => c.pillar === pillar)
                    .map((course) => (
                      <article
                        key={course.id}
                        className="flex flex-col gap-4 rounded-2xl bg-card p-5 shadow-sm transition-shadow hover:shadow-md"
                      >
                        <div className="flex items-center gap-3">
                          <span className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
                            <GraduationCap className="size-5" aria-hidden="true" />
                          </span>
                          <span className="rounded-full bg-secondary px-2.5 py-1 text-xs font-semibold text-muted-foreground">
                            {course.levelLabel}
                          </span>
                        </div>
                        <h3 className="font-display text-base font-bold text-foreground">
                          {course.title}
                        </h3>
                        <Button asChild variant="outline" className="mt-auto rounded-full">
                          <Link to="/courses/$courseId" params={{ courseId: course.id }}>
                            Ouvrir le module
                          </Link>
                        </Button>
                      </article>
                    ))}
                </div>
              </section>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}
