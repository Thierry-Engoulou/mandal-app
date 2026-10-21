import { createFileRoute, Link } from "@tanstack/react-router";
import { Library, ScanLine } from "lucide-react";
import { BanqueExplorer } from "@/components/banque/banque-explorer";
import { Button } from "@/components/ui/button";

export const Route = createFileRoute("/_authenticated/etudiant/banque")({
  component: StudentBanquePage,
  head: () => ({
    meta: [
      { title: "Banque d'épreuves — M'ANDAL" },
      { name: "description", content: "Épreuves d'examens et de devoirs à télécharger." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

function StudentBanquePage() {
  return (
    <div className="space-y-6">
      <header className="gradient-welcome rounded-2xl p-6 text-primary-foreground shadow-sm">
        <Library className="mb-2 size-6" />
        <h1 className="font-display text-2xl font-bold tracking-tight">Banque d'épreuves</h1>
        <p className="mt-1 max-w-2xl text-sm opacity-90">
          Télécharge les épreuves du BEPC, du Probatoire, du Bac, du GCE et des concours. Fais-les
          dans les conditions de l'examen, puis photographie ta copie : Mandal IA la corrige.
        </p>
      </header>
      <BanqueExplorer
        actionsSupplementaires={() => (
          <Button asChild size="sm" variant="ghost" className="rounded-xl">
            <Link to="/etudiant/correction">
              <ScanLine className="size-4" /> Corriger ma copie
            </Link>
          </Button>
        )}
      />
    </div>
  );
}
