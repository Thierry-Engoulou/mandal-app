import { createFileRoute, Link } from "@tanstack/react-router";
import { Flame, Target, Timer, Trophy } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";

export const Route = createFileRoute("/_authenticated/etudiant/defis")({
  component: StudentChallengesPage,
  head: () => ({
    meta: [
      { title: "Défis — MANDAL" },
      { name: "description", content: "Relevez les défis hebdomadaires MANDAL et gagnez des XP." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const CHALLENGES = [
  {
    title: "Trois modules en une semaine",
    description: "Terminez 3 modules de votre choix avant dimanche soir.",
    xp: 150,
    progress: 66,
    status: "En cours",
    tone: "status-active",
    icon: Target,
  },
  {
    title: "Série de 5 jours",
    description: "Connectez-vous et apprenez 5 jours d’affilée.",
    xp: 100,
    progress: 40,
    status: "En cours",
    tone: "status-active",
    icon: Flame,
  },
  {
    title: "Quiz éclair citoyenneté",
    description: "Répondez à 10 questions en moins de 5 minutes.",
    xp: 80,
    progress: 0,
    status: "À venir",
    tone: "status-draft",
    icon: Timer,
  },
  {
    title: "Champion du mois",
    description: "Entrez dans le top 3 du classement de votre école.",
    xp: 300,
    progress: 85,
    status: "Urgent",
    tone: "status-urgent",
    icon: Trophy,
  },
];

function StudentChallengesPage() {
  return (
    <div className="space-y-6">
      <div className="gradient-progress rounded-2xl p-6 text-primary-foreground shadow-sm">
        <p className="text-sm/6 opacity-90">Motivation</p>
        <h1 className="font-display text-2xl font-bold tracking-tight">Défis</h1>
        <p className="mt-1 text-sm opacity-90">
          Chaque défi réussi vous rapproche du haut du classement.
        </p>
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        {CHALLENGES.map((challenge) => (
          <div key={challenge.title} className="rounded-2xl bg-card p-5 shadow-sm">
            <div className="flex items-start justify-between gap-3">
              <span className="flex size-11 items-center justify-center rounded-xl bg-accent/10 text-accent">
                <challenge.icon className="size-5" />
              </span>
              <span className={challenge.tone}>{challenge.status}</span>
            </div>
            <h2 className="mt-4 font-display text-lg font-semibold text-foreground">
              {challenge.title}
            </h2>
            <p className="mt-1 text-sm text-muted-foreground">{challenge.description}</p>
            <div className="mt-4 space-y-1.5">
              <div className="flex items-center justify-between text-sm">
                <span className="text-muted-foreground">Progression</span>
                <span className="font-semibold text-foreground">{challenge.progress}%</span>
              </div>
              <Progress value={challenge.progress} />
            </div>
            <div className="mt-4 flex items-center justify-between">
              <span className="text-sm font-semibold text-success">+{challenge.xp} XP</span>
              <Button asChild size="sm">
                <Link to="/etudiant/cours">Continuer</Link>
              </Button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
