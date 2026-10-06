import { createFileRoute } from "@tanstack/react-router";
import { Award, BookOpenCheck, CalendarCheck, Sparkles, Star, Users } from "lucide-react";
import { Progress } from "@/components/ui/progress";

export const Route = createFileRoute("/_authenticated/etudiant/representations")({
  component: StudentRepresentationsPage,
  head: () => ({
    meta: [
      { title: "Représentations — MANDAL" },
      { name: "description", content: "Vos badges, statistiques et progression sur MANDAL." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const BADGES = [
  { icon: Star, label: "Premier module", earned: true },
  { icon: BookOpenCheck, label: "10 modules terminés", earned: true },
  { icon: CalendarCheck, label: "Série de 7 jours", earned: true },
  { icon: Users, label: "Entraide de classe", earned: false },
  { icon: Award, label: "Top 3 de l’école", earned: false },
  { icon: Sparkles, label: "Champion Olympiades", earned: false },
];

const PILLARS = [
  { label: "Éducation", value: 78 },
  { label: "Citoyenneté", value: 62 },
  { label: "Identité & Culture", value: 45 },
  { label: "Orientation", value: 30 },
  { label: "Entrepreneuriat", value: 18 },
];

function StudentRepresentationsPage() {
  return (
    <div className="space-y-6">
      <div className="gradient-analytics rounded-2xl p-6 text-primary-foreground shadow-sm">
        <p className="text-sm/6 opacity-90">Votre profil d’apprentissage</p>
        <h1 className="font-display text-2xl font-bold tracking-tight">Représentations</h1>
        <p className="mt-1 text-sm opacity-90">
          Visualisez vos acquis, pilier par pilier, et les badges déjà obtenus.
        </p>
      </div>

      <div className="rounded-2xl bg-card p-6 shadow-sm">
        <h2 className="font-display text-lg font-semibold text-foreground">Maîtrise par pilier</h2>
        <div className="mt-4 space-y-4">
          {PILLARS.map((pillar) => (
            <div key={pillar.label} className="space-y-1.5">
              <div className="flex items-center justify-between text-sm">
                <span className="font-medium text-foreground">{pillar.label}</span>
                <span className="text-muted-foreground">{pillar.value}%</span>
              </div>
              <Progress value={pillar.value} />
            </div>
          ))}
        </div>
      </div>

      <div className="rounded-2xl bg-card p-6 shadow-sm">
        <h2 className="font-display text-lg font-semibold text-foreground">Badges</h2>
        <div className="mt-4 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {BADGES.map((badge) => (
            <div
              key={badge.label}
              className={`flex items-center gap-3 rounded-2xl border p-4 ${
                badge.earned ? "border-success/30 bg-success/5" : "border-border bg-muted/40 opacity-70"
              }`}
            >
              <span
                className={`flex size-10 items-center justify-center rounded-xl ${
                  badge.earned ? "bg-success/15 text-success" : "bg-muted text-muted-foreground"
                }`}
              >
                <badge.icon className="size-5" />
              </span>
              <div>
                <p className="font-medium text-foreground">{badge.label}</p>
                <p className="text-xs text-muted-foreground">
                  {badge.earned ? "Obtenu" : "À débloquer"}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
