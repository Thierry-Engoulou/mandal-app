import { createFileRoute, Link } from "@tanstack/react-router";
import { z } from "zod";
import { Bot, Download, FileText, ScanLine } from "lucide-react";
import { MandalLogo } from "@/components/mandal-logo";
import { BanqueExplorer } from "@/components/banque/banque-explorer";
import { Button } from "@/components/ui/button";

const searchSchema = z.object({
  q: z.string().max(200).optional(),
  matiere: z.string().max(80).optional(),
  classe: z.string().max(80).optional(),
  type: z.string().max(80).optional(),
  annee: z.coerce.number().int().min(1960).max(2100).optional(),
});

export const Route = createFileRoute("/banque-epreuves")({
  validateSearch: (search) => searchSchema.parse(search),
  head: () => ({
    meta: [
      { title: "Banque d'épreuves : BEPC, Probatoire, Bac, GCE — M'ANDAL" },
      {
        name: "description",
        content:
          "Télécharge gratuitement des épreuves d'examens camerounais (BEPC, Probatoire, Baccalauréat, GCE O/A Level, concours) et des devoirs, avec leurs corrigés.",
      },
    ],
  }),
  component: BanqueEpreuvesPage,
});

function BanqueEpreuvesPage() {
  const search = Route.useSearch();
  const navigate = Route.useNavigate();

  return (
    <div className="min-h-screen bg-background text-foreground">
      <header className="sticky top-0 z-50 border-b border-border bg-card/95 backdrop-blur">
        <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 lg:px-8">
          <Link to="/" className="flex items-center gap-3">
            <MandalLogo />
          </Link>
          <div className="flex items-center gap-2">
            <Button asChild variant="ghost" className="hidden sm:inline-flex">
              <Link to="/education">Éducation</Link>
            </Button>
            <Button
              asChild
              className="rounded-full bg-emerald-600 px-5 font-semibold text-white hover:bg-emerald-500"
            >
              <Link to="/auth">Mon espace</Link>
            </Button>
          </div>
        </div>
      </header>

      <section className="bg-gradient-to-b from-emerald-500/10 via-background to-background py-10 sm:py-14">
        <div className="mx-auto max-w-4xl px-4 text-center">
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/30 bg-emerald-500/10 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400">
            <FileText className="size-3.5" /> Banque d'épreuves
          </div>
          <h1 className="mt-4 font-display text-3xl font-black tracking-tight sm:text-4xl">
            Les épreuves des examens, à télécharger gratuitement
          </h1>
          <p className="mt-3 text-muted-foreground">
            BEPC, CAP, Probatoire, Baccalauréat, GCE O Level et A Level, concours et devoirs de
            classe : cherche ton épreuve, consulte-la et télécharge-la en PDF, avec son corrigé
            quand il existe.
          </p>
        </div>
      </section>

      <main className="mx-auto max-w-6xl space-y-8 px-4 pb-16">
        <BanqueExplorer
          initial={search}
          onFiltresChange={(f) => void navigate({ search: f, replace: true })}
        />

        <section className="grid gap-4 rounded-3xl bg-card p-6 shadow-sm md:grid-cols-3">
          <Atout icon={<Download className="size-5" />} titre="Téléchargement libre">
            Toutes les épreuves publiées sont téléchargeables sans compte.
          </Atout>
          <Atout icon={<ScanLine className="size-5" />} titre="Fais corriger ta copie">
            Avec un compte, photographie ta copie : Mandal IA la corrige et t'explique tes erreurs.
          </Atout>
          <Atout icon={<Bot className="size-5" />} titre="Épreuves blanches">
            Mandal IA rédige de nouvelles épreuves sur le modèle de celles de la banque.
          </Atout>
          <div className="md:col-span-3">
            <Button asChild className="rounded-xl">
              <Link to="/inscription">Créer mon compte gratuit</Link>
            </Button>
          </div>
        </section>

        <p className="text-center text-xs text-muted-foreground">
          Les épreuves sont publiées à des fins pédagogiques, avec l'indication de leur source.
          Enseignant ? Connecte-toi pour proposer tes épreuves. Une erreur ou un fichier à retirer :
          écris-nous depuis la page À propos.
        </p>
      </main>
    </div>
  );
}

function Atout({
  icon,
  titre,
  children,
}: {
  icon: React.ReactNode;
  titre: string;
  children: React.ReactNode;
}) {
  return (
    <div className="space-y-1">
      <div className="flex items-center gap-2 font-semibold text-foreground">
        <span className="text-primary">{icon}</span> {titre}
      </div>
      <p className="text-sm text-muted-foreground">{children}</p>
    </div>
  );
}
