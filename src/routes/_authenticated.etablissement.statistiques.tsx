import { createFileRoute } from "@tanstack/react-router";
import {
  Bar,
  BarChart,
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { useChefSchool, useChefStats } from "@/lib/use-chef";
import { ChefNoSchool } from "@/components/chef-empty";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

export const Route = createFileRoute("/_authenticated/etablissement/statistiques")({
  component: StatistiquesPage,
  head: () => ({
    meta: [
      { title: "Statistiques de l'établissement — MANDAL" },
      {
        name: "description",
        content: "Effectifs et résultats moyens par filière dans votre établissement.",
      },
      { name: "robots", content: "noindex" },
      { property: "og:title", content: "Statistiques de l'établissement — MANDAL" },
      {
        property: "og:description",
        content: "Effectifs et résultats moyens par filière dans votre établissement.",
      },
    ],
  }),
});

function StatistiquesPage() {
  const { etabId, isLoading } = useChefSchool();
  const { data: rows = [], isLoading: statsLoading } = useChefStats(etabId);

  if (isLoading) return <Skeleton className="h-40 rounded-2xl" />;
  if (!etabId) return <ChefNoSchool />;

  const empty = !statsLoading && rows.length === 0;

  return (
    <div className="space-y-6">
      <header>
        <h1 className="font-display text-2xl font-bold text-foreground">Statistiques</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Effectifs et résultats moyens par filière.
        </p>
      </header>

      {statsLoading ? (
        <Skeleton className="h-72 rounded-2xl" />
      ) : empty ? (
        <div className="rounded-2xl bg-card p-6 shadow-sm">
          <p className="text-sm text-muted-foreground">
            Aucune donnée disponible : créez des classes et enregistrez des résultats d'examens.
          </p>
        </div>
      ) : (
        <>
          <div className="grid gap-6 lg:grid-cols-2">
            <section className="rounded-2xl bg-card p-6 shadow-sm">
              <h2 className="font-display text-lg font-semibold text-foreground">
                Élèves par filière
              </h2>
              <div className="mt-4 h-72">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={rows}>
                    <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
                    <XAxis dataKey="filiere" fontSize={12} stroke="var(--muted-foreground)" />
                    <YAxis allowDecimals={false} fontSize={12} stroke="var(--muted-foreground)" />
                    <Tooltip />
                    <Bar dataKey="eleves" name="Élèves" fill="var(--violet)" radius={[8, 8, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </section>

            <section className="rounded-2xl bg-card p-6 shadow-sm">
              <h2 className="font-display text-lg font-semibold text-foreground">
                Score moyen aux examens
              </h2>
              <div className="mt-4 h-72">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={rows}>
                    <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
                    <XAxis dataKey="filiere" fontSize={12} stroke="var(--muted-foreground)" />
                    <YAxis fontSize={12} stroke="var(--muted-foreground)" />
                    <Tooltip />
                    <Line
                      type="monotone"
                      dataKey="scoreMoyen"
                      name="Score moyen"
                      stroke="var(--violet)"
                      strokeWidth={2}
                      dot={{ r: 4 }}
                    />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </section>
          </div>

          <div className="overflow-x-auto rounded-2xl bg-card p-2 shadow-sm">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Filière</TableHead>
                  <TableHead>Classes</TableHead>
                  <TableHead>Élèves</TableHead>
                  <TableHead>Score moyen</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {rows.map((r) => (
                  <TableRow key={r.filiere}>
                    <TableCell className="font-medium">{r.filiere}</TableCell>
                    <TableCell>{r.classes}</TableCell>
                    <TableCell>{r.eleves}</TableCell>
                    <TableCell>{r.scoreMoyen}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        </>
      )}
    </div>
  );
}
