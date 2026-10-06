import { createFileRoute, Link } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import {
  BookOpen,
  Flame,
  Trophy,
  Sparkles,
  ArrowRight,
  Bell,
  GraduationCap,
  Scale,
  HeartHandshake,
} from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { useProfile, displayName } from "@/lib/use-profile";
import { Skeleton } from "@/components/ui/skeleton";

export const Route = createFileRoute("/_authenticated/etudiant/")({
  component: StudentDashboardPage,
  head: () => ({
    meta: [
      { title: "Tableau de bord — MANDAL" },
      { name: "description", content: "Votre progression, vos examens et vos XP sur MANDAL." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const PALIER = 1000;

function StudentDashboardPage() {
  const { data: profile, isLoading: loadingProfile } = useProfile();

  const { data: stats } = useQuery({
    enabled: !!profile,
    queryKey: ["etudiant-dashboard", profile?.id],
    queryFn: async () => {
      const [resultats, examens, notifs, badges] = await Promise.all([
        supabase
          .from("resultats_examens")
          .select("id, score, date_passage, examens(titre)")
          .eq("eleve_id", profile!.id)
          .order("date_passage", { ascending: false })
          .limit(5),
        supabase
          .from("examens")
          .select("id, titre, duree_minutes, nb_questions, statut")
          .eq("statut", "publie")
          .order("created_at", { ascending: false })
          .limit(5),
        supabase
          .from("notifications")
          .select("id, titre, created_at")
          .eq("profile_id", profile!.id)
          .eq("lu", false)
          .order("created_at", { ascending: false })
          .limit(3),
        supabase.from("eleve_badges").select("id").eq("eleve_id", profile!.id),
      ]);
      return {
        resultats: resultats.data ?? [],
        examens: examens.data ?? [],
        notifs: notifs.data ?? [],
        badges: badges.data?.length ?? 0,
      };
    },
  });

  const xp = profile?.xp_total ?? 0;
  const progression = Math.min(100, Math.round(((xp % PALIER) / PALIER) * 100));

  const cards = [
    { label: "Examens passés", value: String(stats?.resultats.length ?? 0), icon: BookOpen, tone: "text-primary bg-primary/10" },
    { label: "Badges obtenus", value: String(stats?.badges ?? 0), icon: Flame, tone: "text-warning bg-warning/10" },
    { label: "XP cumulés", value: xp.toLocaleString("fr-FR"), icon: Trophy, tone: "text-success bg-success/10" },
  ];

  return (
    <div className="space-y-6">
      <div className="gradient-welcome rounded-2xl p-6 text-primary-foreground shadow-sm">
        <h1 className="font-display text-2xl font-bold tracking-tight">
          {loadingProfile ? "Bienvenue" : `Bonjour ${displayName(profile)}`}
        </h1>
        <p className="mt-1 text-sm opacity-90">
          Reprenez votre parcours d'excellence M'Andal : Éducation, Citoyenneté &amp; Culture.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        {cards.map((stat) => (
          <div key={stat.label} className="rounded-2xl bg-card p-5 shadow-sm">
            <div className={`mb-3 flex h-10 w-10 items-center justify-center rounded-xl ${stat.tone}`}>
              <stat.icon className="h-5 w-5" />
            </div>
            <p className="font-display text-2xl font-bold text-foreground">{stat.value}</p>
            <p className="text-sm text-muted-foreground">{stat.label}</p>
          </div>
        ))}
      </div>

      {/* 3 Pillars Quick Explorer for Students */}
      <div className="rounded-2xl border border-border bg-card p-6 shadow-sm">
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2">
          <div>
            <h2 className="font-display text-lg font-bold text-foreground">Les 3 Volets Pédagogiques M'Andal</h2>
            <p className="text-xs text-muted-foreground">Accédez aux modules académiques, civiques et culturels</p>
          </div>
          <span className="text-xs font-semibold text-emerald-600 dark:text-emerald-400 bg-emerald-500/10 px-3 py-1 rounded-full w-fit">
            Programme Complet
          </span>
        </div>

        <div className="mt-5 grid gap-4 sm:grid-cols-3">
          {/* 01 Éducation */}
          <Link
            to="/etudiant/cours"
            className="group flex flex-col justify-between rounded-xl border border-emerald-500/20 bg-emerald-500/5 p-4 transition-all hover:border-emerald-500 hover:bg-emerald-500/10"
          >
            <div>
              <div className="flex items-center justify-between">
                <span className="text-xs font-black text-emerald-600 dark:text-emerald-400">01</span>
                <GraduationCap className="size-5 text-emerald-600 dark:text-emerald-400" />
              </div>
              <h3 className="mt-2 font-display text-sm font-bold text-foreground group-hover:text-emerald-600">
                Éducation &amp; Concours
              </h3>
              <p className="mt-1 text-xs text-muted-foreground leading-relaxed">
                BEPC, Probatoire, Baccalauréat, ENSPD, IUT... Cours et annales corrigées.
              </p>
            </div>
            <div className="mt-3 flex items-center gap-1 text-xs font-semibold text-emerald-600 dark:text-emerald-400">
              <span>Mes cours</span> <ArrowRight className="size-3" />
            </div>
          </Link>

          {/* 02 Citoyenneté */}
          <div className="flex flex-col justify-between rounded-xl border border-orange-500/20 bg-orange-500/5 p-4 transition-all">
            <div>
              <div className="flex items-center justify-between">
                <span className="text-xs font-black text-orange-600 dark:text-orange-400">02</span>
                <Scale className="size-5 text-orange-600 dark:text-orange-400" />
              </div>
              <h3 className="mt-2 font-display text-sm font-bold text-foreground">
                Citoyenneté &amp; Devoirs
              </h3>
              <p className="mt-1 text-xs text-muted-foreground leading-relaxed">
                Institutions, droits de l'élève, lutte contre la corruption et vivre-ensemble.
              </p>
            </div>
            <span className="mt-3 text-xs font-semibold text-orange-600 dark:text-orange-400">
              Intégré au parcours
            </span>
          </div>

          {/* 03 Culture */}
          <div className="flex flex-col justify-between rounded-xl border border-amber-500/20 bg-amber-500/5 p-4 transition-all">
            <div>
              <div className="flex items-center justify-between">
                <span className="text-xs font-black text-amber-600 dark:text-amber-400">03</span>
                <Sparkles className="size-5 text-amber-600 dark:text-amber-400" />
              </div>
              <h3 className="mt-2 font-display text-sm font-bold text-foreground">
                Culture &amp; Fierté
              </h3>
              <p className="mt-1 text-xs text-muted-foreground leading-relaxed">
                Histoire du continent africain, patrimoine camerounais et grandes figures.
              </p>
            </div>
            <span className="mt-3 text-xs font-semibold text-amber-600 dark:text-amber-400">
              Médiathèque culturelle
            </span>
          </div>
        </div>

        {/* Notice Parrainage */}
        <div className="mt-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 rounded-xl border border-amber-500/30 bg-amber-500/10 p-3.5">
          <div className="flex items-center gap-2.5">
            <HeartHandshake className="size-5 text-amber-600 dark:text-amber-400 shrink-0" />
            <p className="text-xs text-foreground font-medium">
              <strong>Programme Parrainage M'Andal :</strong> « Un élève brillant ne devrait jamais renoncer à un concours faute de moyens. »
            </p>
          </div>
          <Link
            to="/etudiant/aide"
            className="shrink-0 text-xs font-bold text-amber-700 dark:text-amber-300 hover:underline"
          >
            En savoir plus &rarr;
          </Link>
        </div>
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        <div className="rounded-2xl bg-card p-6 shadow-sm lg:col-span-2">
          <div className="mb-4 flex items-center justify-between">
            <h2 className="font-display text-lg font-bold text-foreground">Examens disponibles</h2>
            <Link to="/etudiant/examens" className="text-sm font-medium text-primary">
              Tout voir
            </Link>
          </div>

          {!stats ? (
            <div className="space-y-3">
              <Skeleton className="h-16 rounded-xl" />
              <Skeleton className="h-16 rounded-xl" />
            </div>
          ) : stats.examens.length === 0 ? (
            <div className="rounded-xl border border-dashed border-border p-8 text-center">
              <p className="text-sm text-muted-foreground">
                Aucun examen publié pour le moment dans votre établissement.
              </p>
            </div>
          ) : (
            <ul className="space-y-3">
              {stats.examens.map((examen) => (
                <li key={examen.id}>
                  <Link
                    to="/etudiant/examens/$examenId"
                    params={{ examenId: examen.id }}
                    className="flex items-center justify-between rounded-xl border border-border p-4 transition-colors hover:border-primary/50"
                  >
                    <div className="min-w-0">
                      <p className="truncate text-sm font-semibold text-foreground">{examen.titre}</p>
                      <p className="text-xs text-muted-foreground">
                        {examen.duree_minutes} min · {examen.nb_questions} questions
                      </p>
                    </div>
                    <ArrowRight className="h-4 w-4 shrink-0 text-muted-foreground" />
                  </Link>
                </li>
              ))}
            </ul>
          )}

          <div className="mt-6">
            <h3 className="mb-3 font-display text-sm font-bold text-foreground">Derniers résultats</h3>
            {stats?.resultats.length ? (
              <ul className="divide-y rounded-xl border border-border">
                {stats.resultats.map((r) => (
                  <li key={r.id} className="flex items-center justify-between px-4 py-3">
                    <span className="truncate text-sm text-foreground">
                      {(r as { examens?: { titre?: string } }).examens?.titre ?? "Examen"}
                    </span>
                    <span className="text-sm font-semibold text-primary">{Number(r.score)} / 20</span>
                  </li>
                ))}
              </ul>
            ) : (
              <p className="text-sm text-muted-foreground">Pas encore de résultat enregistré.</p>
            )}
          </div>
        </div>

        <div className="space-y-4">
          <div className="gradient-progress rounded-2xl p-6 text-primary-foreground shadow-sm">
            <Sparkles className="mb-3 h-6 w-6" />
            <h2 className="font-display text-lg font-bold">Votre progression</h2>
            <p className="mt-1 text-sm opacity-90">{profile?.niveau ?? "Niveau 1"}</p>
            <div className="mt-4 h-2 w-full overflow-hidden rounded-full bg-white/25">
              <div className="h-full rounded-full bg-white" style={{ width: `${progression}%` }} />
            </div>
            <p className="mt-2 text-xs opacity-90">{progression} % vers le palier suivant</p>
            <Link
              to="/etudiant/orientation/conseiller"
              className="mt-5 inline-flex items-center gap-2 rounded-xl bg-white/20 px-4 py-2 text-sm font-semibold"
            >
              Parler au conseiller IA
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>

          <div className="rounded-2xl bg-card p-5 shadow-sm">
            <div className="mb-3 flex items-center gap-2">
              <Bell className="h-4 w-4 text-primary" />
              <h2 className="font-display text-sm font-bold text-foreground">Notifications</h2>
            </div>
            {stats?.notifs.length ? (
              <ul className="space-y-2">
                {stats.notifs.map((n) => (
                  <li key={n.id} className="text-sm text-muted-foreground">
                    {n.titre}
                  </li>
                ))}
              </ul>
            ) : (
              <p className="text-sm text-muted-foreground">Aucune notification non lue.</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
