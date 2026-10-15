import { createFileRoute } from "@tanstack/react-router";
import { Briefcase } from "lucide-react";
import { FichesExplorer } from "@/components/orientation/fiches-explorer";

export const Route = createFileRoute("/_authenticated/etudiant/orientation/metiers")({
  component: StudentCareersPage,
  head: () => ({
    meta: [
      { title: "Métiers — M'Andal" },
      {
        name: "description",
        content: "Métiers au Cameroun : missions, parcours de formation et réalité du terrain.",
      },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function StudentCareersPage() {
  return (
    <div className="space-y-6">
      <header className="gradient-progress rounded-2xl p-6 text-primary-foreground shadow-sm">
        <Briefcase className="mb-2 size-6" />
        <h1 className="font-display text-2xl font-bold tracking-tight">Métiers</h1>
        <p className="mt-1 max-w-2xl text-sm opacity-90">
          Ce que fait chaque professionnel, comment y arriver au Cameroun et la réalité du terrain,
          avec les références à consulter.
        </p>
      </header>
      <FichesExplorer type="metier" placeholder="Ex. : infirmier, développeur, agronome, police…" />
    </div>
  );
}
