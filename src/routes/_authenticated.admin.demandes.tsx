import { createFileRoute, Link } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { listStudentApplications } from "@/lib/site-content.functions";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";

export const Route = createFileRoute("/_authenticated/admin/demandes")({
  component: ApplicationsPage,
  head: () => ({
    meta: [
      { title: "Demandes d'inscription — M'Andal" },
      { name: "description", content: "Suivi des demandes d'inscription étudiantes M'Andal." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function ApplicationsPage() {
  const fetchApplications = useServerFn(listStudentApplications);
  const { data, isLoading, error } = useQuery({
    queryKey: ["student-applications"],
    queryFn: () => fetchApplications(),
  });

  return (
    <div className="min-h-screen bg-background text-foreground">
      <header className="border-b border-border">
        <div className="mx-auto flex max-w-5xl items-center justify-between px-6 py-4">
          <Link to="/" className="font-display text-xl font-extrabold tracking-tighter">
            M'ANDAL
          </Link>
          <Link to="/courses" className="text-sm hover:text-primary transition-colors">
            Modules
          </Link>
        </div>
      </header>

      <main className="mx-auto max-w-5xl px-6 py-12">
        <h1 className="font-display text-3xl font-extrabold tracking-tighter">
          Demandes d'inscription
        </h1>
        <p className="mt-2 text-muted-foreground">
          Réservé à l'équipe M'Andal (comptes administrateurs).
        </p>

        {isLoading ? (
          <p className="mt-8 text-muted-foreground">Chargement…</p>
        ) : error ? (
          <p className="mt-8 text-muted-foreground">
            Accès réservé aux administrateurs de l'équipe M'Andal.
          </p>
        ) : !data || data.length === 0 ? (
          <p className="mt-8 text-muted-foreground">Aucune demande pour le moment.</p>
        ) : (
          <div className="mt-8 space-y-4">
            {data.map((a) => (
              <Card key={a.id}>
                <CardHeader>
                  <div className="flex items-center justify-between gap-4">
                    <CardTitle className="font-display text-lg">{a.full_name}</CardTitle>
                    <Badge variant="secondary">{a.status}</Badge>
                  </div>
                  <p className="text-sm text-muted-foreground">
                    {a.email}
                    {a.phone ? ` · ${a.phone}` : ""} · {a.country}
                    {a.city ? `, ${a.city}` : ""} · {a.school_level}
                  </p>
                </CardHeader>
                <CardContent>
                  <p className="text-sm whitespace-pre-wrap">{a.motivation}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}
