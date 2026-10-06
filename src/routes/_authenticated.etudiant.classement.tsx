import { createFileRoute } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { Crown, Medal, TrendingUp } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { Skeleton } from "@/components/ui/skeleton";

export const Route = createFileRoute("/_authenticated/etudiant/classement")({
  component: StudentRankingPage,
  head: () => ({
    meta: [
      { title: "Classement — MANDAL" },
      { name: "description", content: "Votre position et celle de votre établissement sur MANDAL." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function rankStyle(rank: number) {
  if (rank === 1) return "bg-warning/15 text-warning";
  if (rank === 2) return "bg-primary/10 text-primary";
  if (rank === 3) return "bg-success/10 text-success";
  return "bg-muted text-muted-foreground";
}

function StudentRankingPage() {
  const { data: profile } = useProfile();

  const { data, isLoading } = useQuery({
    enabled: !!profile,
    queryKey: ["classement", profile?.etablissement_id],
    queryFn: async () => {
      const [rows, badges] = await Promise.all([
        supabase
          .from("profiles")
          .select("id, full_name, nom, prenom, xp_total, etablissements(nom)")
          .eq("role", "student")
          .order("xp_total", { ascending: false })
          .limit(50),
        supabase.from("eleve_badges").select("id").eq("eleve_id", profile!.id),
      ]);
      return {
        rows: (rows.data ?? []).map((p, index) => ({
          rank: index + 1,
          id: p.id,
          name: [p.prenom, p.nom].filter(Boolean).join(" ") || p.full_name || "Élève",
          school: (p as { etablissements?: { nom?: string } }).etablissements?.nom ?? "—",
          xp: p.xp_total,
        })),
        badges: badges.data?.length ?? 0,
      };
    },
  });

  const myRank = data?.rows.find((r) => r.id === profile?.id)?.rank;

  return (
    <div className="space-y-6">
      <div className="gradient-progress rounded-2xl p-6 text-primary-foreground shadow-sm">
        <p className="text-sm/6 opacity-90">Gamification</p>
        <h1 className="font-display text-2xl font-bold tracking-tight">Classement</h1>
        <p className="mt-1 text-sm opacity-90">
          Gagnez des XP en passant vos examens et en suivant les ressources.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        {[
          { icon: Crown, label: "Votre rang", value: myRank ? `${myRank}e` : "—" },
          { icon: TrendingUp, label: "Vos XP", value: (profile?.xp_total ?? 0).toLocaleString("fr-FR") },
          { icon: Medal, label: "Badges obtenus", value: String(data?.badges ?? 0) },
        ].map((stat) => (
          <div key={stat.label} className="rounded-2xl bg-card p-5 shadow-sm">
            <span className="flex size-10 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <stat.icon className="size-5" />
            </span>
            <p className="mt-3 text-sm text-muted-foreground">{stat.label}</p>
            <p className="font-display text-2xl font-bold text-foreground">{stat.value}</p>
          </div>
        ))}
      </div>

      <div className="overflow-hidden rounded-2xl bg-card shadow-sm">
        <div className="border-b px-5 py-4">
          <h2 className="font-display text-lg font-semibold text-foreground">Top apprenants</h2>
          <p className="text-sm text-muted-foreground">Classement par XP cumulés</p>
        </div>
        {isLoading ? (
          <div className="space-y-3 p-5">
            <Skeleton className="h-12 rounded-xl" />
            <Skeleton className="h-12 rounded-xl" />
          </div>
        ) : !data || data.rows.length === 0 ? (
          <p className="p-8 text-center text-sm text-muted-foreground">
            Le classement s'affichera dès que des élèves auront gagné des XP.
          </p>
        ) : (
          <ul className="divide-y">
            {data.rows.map((row) => {
              const me = row.id === profile?.id;
              return (
                <li key={row.id} className={`flex items-center gap-4 px-5 py-4 ${me ? "bg-success/5" : ""}`}>
                  <span
                    className={`flex size-9 shrink-0 items-center justify-center rounded-full text-sm font-bold ${rankStyle(row.rank)}`}
                  >
                    {row.rank}
                  </span>
                  <div className="min-w-0 flex-1">
                    <p className="truncate font-medium text-foreground">
                      {row.name}
                      {me ? (
                        <span className="ml-2 rounded-full bg-success/10 px-2 py-0.5 text-xs font-semibold text-success">
                          Vous
                        </span>
                      ) : null}
                    </p>
                    <p className="truncate text-sm text-muted-foreground">{row.school}</p>
                  </div>
                  <span className="font-display text-sm font-bold text-foreground">
                    {row.xp.toLocaleString("fr-FR")} XP
                  </span>
                </li>
              );
            })}
          </ul>
        )}
      </div>
    </div>
  );
}
