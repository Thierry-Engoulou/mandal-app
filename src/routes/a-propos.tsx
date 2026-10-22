import { createFileRoute, Link } from "@tanstack/react-router";
import {
  GraduationCap,
  Sparkles,
  Target,
  Users,
  Compass,
  Award,
  Heart,
  BookOpen,
  ArrowRight,
  ShieldCheck,
  CheckCircle2,
} from "lucide-react";
import { MandalLogo } from "@/components/mandal-logo";
import { Button } from "@/components/ui/button";
import { LiensLegaux } from "@/components/legal/liens-legaux";

export const Route = createFileRoute("/a-propos")({
  head: () => ({
    meta: [
      { title: "À propos de M'ANDAL — L'Éducation & l'Excellence pour Tous" },
      {
        name: "description",
        content:
          "Découvrez l'histoire, la vision et les valeurs de M'ANDAL : démocratiser le savoir et l'accès aux grandes opportunités académiques en Afrique.",
      },
    ],
  }),
  component: AboutPage,
});

function AboutPage() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      {/* Header simple */}
      <header className="sticky top-0 z-50 border-b border-border bg-card/95 backdrop-blur">
        <div className="mx-auto flex h-18 max-w-7xl items-center justify-between px-5 lg:px-8">
          <Link to="/" className="flex items-center gap-3">
            <MandalLogo />
            <span className="hidden rounded-full bg-emerald-500/15 px-3 py-1 text-xs font-bold text-emerald-600 dark:text-emerald-400 sm:inline-flex">
              Mahol Andal
            </span>
          </Link>
          <div className="flex items-center gap-3">
            <Button asChild variant="ghost">
              <Link to="/education">Éducation</Link>
            </Button>
            <Button
              asChild
              className="rounded-full bg-emerald-600 px-5 font-semibold text-white hover:bg-emerald-500"
            >
              <Link to="/auth">Mon Espace</Link>
            </Button>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative overflow-hidden bg-gradient-to-b from-emerald-500/10 via-background to-background py-16 sm:py-24">
        <div className="mx-auto max-w-4xl px-4 text-center">
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/30 bg-emerald-500/10 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400">
            <Sparkles className="size-3.5" /> L'Esprit & La Vision M'ANDAL
          </div>
          <h1 className="mt-6 font-display text-3xl sm:text-5xl font-black tracking-tight text-foreground leading-tight">
            « Mahol Andal » : Bâtir l'Avenir par le Savoir et la Sagesse
          </h1>
          <p className="mt-6 text-base sm:text-xl text-muted-foreground leading-relaxed">
            M'ANDAL est une plateforme éducative d'excellence conçue pour accompagner chaque élève
            et étudiant africain, du collège aux plus grands concours d'ingénieurs et d'enseignement
            supérieur.
          </p>
        </div>
      </section>

      {/* Origine & Signification */}
      <section className="py-12 border-y border-border/60 bg-card/50">
        <div className="mx-auto max-w-5xl px-4 grid gap-8 md:grid-cols-2 items-center">
          <div>
            <span className="text-xs font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400">
              Notre Nom
            </span>
            <h2 className="mt-2 font-display text-2xl sm:text-3xl font-bold text-foreground">
              D'où vient le nom M'ANDAL ?
            </h2>
            <p className="mt-4 text-sm sm:text-base text-muted-foreground leading-relaxed">
              Le nom <strong>M'ANDAL</strong> prend sa source dans l'expression peule et
              camerounaise <em>« Mahol Andal »</em>, signifiant littéralement{" "}
              <strong>« Construire le Savoir »</strong> ou{" "}
              <strong>« L'Édifice de la Connaissance »</strong>.
            </p>
            <p className="mt-3 text-sm sm:text-base text-muted-foreground leading-relaxed">
              Pour nous, le savoir n'est pas un privilège réservé à une élite, mais un droit
              fondamental, une force d'émancipation et le levier numéro un de développement pour
              l'Afrique contemporaine.
            </p>
          </div>
          <div className="rounded-3xl border border-border bg-card p-8 shadow-sm space-y-4">
            <div className="flex items-start gap-4">
              <span className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-600">
                <GraduationCap className="size-5" />
              </span>
              <div>
                <h3 className="font-bold text-foreground">Rigueur & Programmes Officiels</h3>
                <p className="text-xs text-muted-foreground mt-1">
                  Conformité intégrale avec les programmes du BEPC, Probatoire, Baccalauréat et
                  prépas concours d'Afrique centrale.
                </p>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <span className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-blue-500/10 text-blue-600">
                <Compass className="size-5" />
              </span>
              <div>
                <h3 className="font-bold text-foreground">Intelligence Artificielle Éducative</h3>
                <p className="text-xs text-muted-foreground mt-1">
                  Mandal IA assiste l'élève dans la compréhension, structure des épreuves
                  d'entraînement et corrige ses copies manuscrites.
                </p>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <span className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-amber-500/10 text-amber-600">
                <Heart className="size-5" />
              </span>
              <div>
                <h3 className="font-bold text-foreground">Solidarité & Parrainage</h3>
                <p className="text-xs text-muted-foreground mt-1">
                  Permettre aux élèves brillants mais défavorisés de bénéficier du soutien des
                  anciens élèves et partenaires.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Nos Piliers */}
      <section className="py-16">
        <div className="mx-auto max-w-6xl px-4">
          <div className="text-center max-w-2xl mx-auto">
            <span className="text-xs font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400">
              Les 4 Piliers Fondateurs
            </span>
            <h2 className="mt-2 font-display text-2xl sm:text-3xl font-bold">
              Un écosystème pédagogique complet
            </h2>
          </div>

          <div className="mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            <div className="rounded-2xl border border-border bg-card p-6 shadow-sm hover:border-emerald-500/40 transition">
              <span className="text-3xl">📚</span>
              <h3 className="mt-4 font-display text-lg font-bold">1. Éducation</h3>
              <p className="mt-2 text-xs sm:text-sm text-muted-foreground leading-relaxed">
                Cours interactifs, simulations physiques GeoGebra, annales corrigées et fiches
                synthétiques.
              </p>
            </div>
            <div className="rounded-2xl border border-border bg-card p-6 shadow-sm hover:border-emerald-500/40 transition">
              <span className="text-3xl">⚖️</span>
              <h3 className="mt-4 font-display text-lg font-bold">2. Citoyenneté</h3>
              <p className="mt-2 text-xs sm:text-sm text-muted-foreground leading-relaxed">
                Formation civique, respect du bien public, intégrité et valeurs républicaines pour
                les futurs cadres du pays.
              </p>
            </div>
            <div className="rounded-2xl border border-border bg-card p-6 shadow-sm hover:border-emerald-500/40 transition">
              <span className="text-3xl">🌍</span>
              <h3 className="mt-4 font-display text-lg font-bold">3. Culture</h3>
              <p className="mt-2 text-xs sm:text-sm text-muted-foreground leading-relaxed">
                Valorisation du patrimoine, des langues nationales et de l'histoire africaine pour
                forger des citoyens éclairés.
              </p>
            </div>
            <div className="rounded-2xl border border-border bg-card p-6 shadow-sm hover:border-emerald-500/40 transition">
              <span className="text-3xl">🤝</span>
              <h3 className="mt-4 font-display text-lg font-bold">4. Parrainage</h3>
              <p className="mt-2 text-xs sm:text-sm text-muted-foreground leading-relaxed">
                Mise en relation d'élèves méritants avec des mentors professionnels et bourses
                d'études.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Appel à l'action */}
      <section className="py-16 bg-card border-t border-border text-center">
        <div className="mx-auto max-w-3xl px-4">
          <h2 className="font-display text-2xl sm:text-3xl font-bold">
            Prêt à transformer votre parcours scolaire ?
          </h2>
          <p className="mt-3 text-sm sm:text-base text-muted-foreground">
            Rejoignez dès maintenant des milliers d'élèves et préparez vos examens avec l'appui de
            Mandal IA.
          </p>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
            <Button
              asChild
              size="lg"
              className="rounded-full bg-emerald-600 px-8 font-bold text-white hover:bg-emerald-500"
            >
              <Link to="/inscription">
                Créer un compte élève <ArrowRight className="ml-2 size-4" />
              </Link>
            </Button>
            <Button asChild variant="outline" size="lg" className="rounded-full">
              <Link to="/education">Explorer les matières</Link>
            </Button>
          </div>
        </div>
      </section>
      <footer className="border-t border-border py-6">
        <div className="mx-auto max-w-4xl px-4">
          <LiensLegaux className="justify-center" />
        </div>
      </footer>
    </div>
  );
}
