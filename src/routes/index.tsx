import { createFileRoute, Link } from "@tanstack/react-router";
import { queryOptions, useSuspenseQuery } from "@tanstack/react-query";
import {
  ArrowRight,
  GraduationCap,
  Scale,
  Sparkles,
  Menu,
  CheckCircle2,
  Phone,
  Mail,
  Heart,
  BookOpen,
  Award,
} from "lucide-react";
import classroomImage from "@/assets/mandal-classroom.jpg";
import { AnnouncementsCarousel } from "@/components/announcements-carousel";
import { MandalLogo } from "@/components/mandal-logo";
import { MandalSponsorshipSection } from "@/components/mandal-sponsorship-section";
import { Button } from "@/components/ui/button";
import { Sheet, SheetClose, SheetContent, SheetTitle, SheetTrigger } from "@/components/ui/sheet";
import { listOlympiads } from "@/lib/site-content.functions";
import { cn } from "@/lib/utils";

const olympiadsQuery = queryOptions({ queryKey: ["olympiads"], queryFn: () => listOlympiads() });

export const Route = createFileRoute("/")({
  loader: async ({ context }) => {
    await Promise.all([context.queryClient.ensureQueryData(olympiadsQuery)]);
  },
  head: () => ({
    meta: [
      { title: "M'ANDAL — L'Éducation d'Excellence Accessible à Tous" },
      {
        name: "description",
        content:
          "M'ANDAL : Démocratiser le soutien scolaire et l'excellence académique pour tous au Cameroun.",
      },
      { property: "og:title", content: "M'ANDAL — Apprendre avec sourire et rigueur" },
      {
        property: "og:description",
        content:
          "Plateforme pédagogique complète : Éducation, Citoyenneté, Culture et Parrainage d'élèves méritants.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
  component: HomePage,
});

const navLinks = [
  { to: "/", label: "Accueil", icon: "🏠" },
  { to: "/education", label: "Éducation", icon: "📚" },
  { to: "/citoyennete", label: "Citoyenneté", icon: "⚖️" },
  { to: "/culture", label: "Culture", icon: "🌍" },
] as const;

function Header() {
  return (
    <header className="sticky top-0 z-50 border-b border-border bg-card/95 backdrop-blur">
      <div className="mx-auto flex h-18 max-w-7xl items-center justify-between px-5 lg:px-8">
        <div className="flex items-center gap-3">
          <MandalLogo />
          <span className="hidden rounded-full bg-emerald-500/15 px-3 py-1 text-xs font-bold text-emerald-600 dark:text-emerald-400 sm:inline-flex">
            Mahol Andal
          </span>
        </div>

        {/* Onglets principaux dans la barre de navigation avec logos exacts */}
        <nav className="hidden items-center gap-8 lg:flex" aria-label="Navigation principale">
          {navLinks.map((item) => (
            <Link
              key={item.to}
              to={item.to}
              className="inline-flex items-center gap-2 text-base font-bold text-foreground/80 transition-colors hover:text-emerald-600 dark:hover:text-emerald-400"
            >
              <span>{item.icon}</span>
              <span>{item.label}</span>
            </Link>
          ))}
        </nav>

        <div className="hidden items-center gap-3 sm:flex">
          <Button asChild variant="ghost">
            <Link to="/auth">Connexion</Link>
          </Button>
          <Button asChild className="rounded-full bg-emerald-600 px-6 font-semibold text-white hover:bg-emerald-500">
            <Link to="/inscription">Inscription</Link>
          </Button>
        </div>

        <Sheet>
          <SheetTrigger asChild>
            <Button variant="ghost" size="icon" className="sm:hidden" aria-label="Ouvrir le menu">
              <Menu />
            </Button>
          </SheetTrigger>
          <SheetContent className="flex flex-col" side="right">
            <SheetTitle>
              <MandalLogo />
            </SheetTitle>
            <nav className="mt-8 flex flex-col gap-3">
              {navLinks.map((item) => (
                <SheetClose asChild key={item.to}>
                  <Link
                    to={item.to}
                    className="flex items-center gap-3 rounded-xl px-4 py-3 text-lg font-bold text-foreground hover:bg-secondary"
                  >
                    <span>{item.icon}</span>
                    <span>{item.label}</span>
                  </Link>
                </SheetClose>
              ))}
            </nav>
            <div className="mt-auto grid gap-3">
              <Button asChild variant="outline">
                <Link to="/auth">Connexion</Link>
              </Button>
              <Button asChild className="bg-emerald-600 text-white hover:bg-emerald-500">
                <Link to="/inscription">Inscription</Link>
              </Button>
            </div>
          </SheetContent>
        </Sheet>
      </div>
    </header>
  );
}

function Hero() {
  return (
    <main className="relative overflow-hidden bg-slate-950">
      <img
        src={classroomImage}
        alt="Une enseignante accompagne des apprenants dans une salle de classe au Cameroun"
        width={1600}
        height={1104}
        className="absolute inset-0 h-full w-full object-cover object-center opacity-35"
        loading="eager"
        fetchPriority="high"
      />
      <div className="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-950/80 to-slate-950/40" />
      <section className="relative mx-auto flex min-h-[75vh] w-full max-w-5xl flex-col items-center justify-end px-5 pb-16 pt-32 text-center sm:min-h-[80vh] lg:pb-24">
        <div className="inline-flex items-center gap-2 rounded-full border border-emerald-400/30 bg-emerald-500/10 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-emerald-300">
          <GraduationCap className="size-4" /> L'Éducation d'Excellence Accessible à Tous
        </div>

        <h1 className="animate-fade-up mt-6 font-display text-4xl font-extrabold leading-[1.1] text-white sm:text-6xl lg:text-7xl">
          Apprendre avec <span className="text-emerald-400">sourire</span> et rigueur.
        </h1>
        <p className="mt-6 max-w-3xl text-lg leading-relaxed text-white/90 sm:text-xl">
          Démocratiser le soutien scolaire et la réussite aux examens et grands concours nationaux face aux défis socio-économiques actuels.
        </p>

        {/* Boutons d'accès créatifs aux 3 Volets avec logos distincts */}
        <div className="animate-fade-up mt-8 flex flex-wrap items-center justify-center gap-3.5 [animation-delay:120ms]">
          {/* 01. Éducation: Vert Émeraude */}
          <Button
            asChild
            size="lg"
            className="group rounded-full bg-gradient-to-r from-emerald-600 to-teal-600 px-6 py-3.5 text-base font-bold text-white shadow-lg shadow-emerald-600/30 transition-all hover:scale-105 hover:from-emerald-500 hover:to-teal-500"
          >
            <Link to="/education" className="flex items-center gap-2">
              <span className="text-xl transition-transform group-hover:scale-125">📚</span>
              <span>01. Éducation</span>
            </Link>
          </Button>

          {/* 02. Citoyenneté: Bleu Républicain / Saphir */}
          <Button
            asChild
            size="lg"
            className="group rounded-full bg-gradient-to-r from-blue-600 to-indigo-600 px-6 py-3.5 text-base font-bold text-white shadow-lg shadow-blue-600/30 transition-all hover:scale-105 hover:from-blue-500 hover:to-indigo-500"
          >
            <Link to="/citoyennete" className="flex items-center gap-2">
              <span className="text-xl transition-transform group-hover:scale-125">⚖️</span>
              <span>02. Citoyenneté</span>
            </Link>
          </Button>

          {/* 03. Culture: Or / Ambre Solaire Africain */}
          <Button
            asChild
            size="lg"
            className="group rounded-full bg-gradient-to-r from-amber-500 to-yellow-500 px-6 py-3.5 text-base font-bold text-slate-950 shadow-lg shadow-amber-500/30 transition-all hover:scale-105 hover:from-amber-400 hover:to-yellow-400"
          >
            <Link to="/culture" className="flex items-center gap-2">
              <span className="text-xl transition-transform group-hover:scale-125">🌍</span>
              <span>03. Culture</span>
            </Link>
          </Button>
        </div>

        <div className="animate-fade-up mt-10 flex w-full max-w-md items-center gap-4 rounded-2xl border border-white/20 bg-white/15 px-6 py-3.5 shadow-2xl backdrop-blur-xl [animation-delay:240ms]">
          <span className="flex size-11 shrink-0 items-center justify-center rounded-full bg-amber-400/20 text-xl shadow-[0_0_20px_rgba(251,191,36,0.45)]">
            🏆
          </span>
          <div className="min-w-0 flex-1 text-left">
            <p className="text-xs font-medium text-white/70">Progression moyenne</p>
            <div className="mt-1.5 h-1.5 w-full overflow-hidden rounded-full bg-white/20">
              <div className="h-full w-[98%] rounded-full bg-emerald-400" />
            </div>
          </div>
          <p className="shrink-0 font-display text-lg font-bold text-white">+98% de réussite</p>
        </div>
      </section>
    </main>
  );
}

function PillarsPreviewSection() {
  const pillars = [
    {
      to: "/education",
      num: "01",
      icon: "📚",
      title: "Éducation",
      desc: "Niveaux scolaires (BEPC, Probatoire, Baccalauréat) & Préparations aux concours (ENSPD, IUT). Cours de Maths, Physique et annales corrigées.",
      tag: "Niveaux & Concours",
      tone: "border-emerald-500/40 bg-gradient-to-b from-emerald-950/40 via-slate-900 to-slate-950 hover:border-emerald-400 text-emerald-400",
      btnBg: "bg-emerald-600 text-white hover:bg-emerald-500 shadow-md shadow-emerald-900/50",
      badgeBg: "bg-emerald-500/15 border-emerald-500/30 text-emerald-300",
    },
    {
      to: "/citoyennete",
      num: "02",
      icon: "⚖️",
      title: "Citoyenneté",
      desc: "Comprendre ses droits, ses devoirs et l'engagement civique. La Constitution, lutte contre la corruption et vivre-ensemble pacifique.",
      tag: "Droits & Devoirs",
      tone: "border-blue-500/40 bg-gradient-to-b from-blue-950/40 via-slate-900 to-slate-950 hover:border-blue-400 text-blue-400",
      btnBg: "bg-blue-600 text-white hover:bg-blue-500 shadow-md shadow-blue-900/50",
      badgeBg: "bg-blue-500/15 border-blue-500/30 text-blue-300",
    },
    {
      to: "/culture",
      num: "03",
      icon: "🌍",
      title: "Culture",
      desc: "Valoriser le patrimoine africain et camerounais. Histoire du continent, traditions orales, arts et grandes figures inspirantes.",
      tag: "Patrimoine & Fierté",
      tone: "border-amber-500/40 bg-gradient-to-b from-amber-950/40 via-slate-900 to-slate-950 hover:border-amber-400 text-amber-400",
      btnBg: "bg-amber-500 text-slate-950 hover:bg-amber-400 shadow-md shadow-amber-900/50",
      badgeBg: "bg-amber-500/15 border-amber-500/30 text-amber-300",
    },
  ];

  return (
    <section className="bg-slate-950 py-20 text-white border-b border-slate-800">
      <div className="mx-auto max-w-7xl px-5 lg:px-8">
        <div className="text-center max-w-3xl mx-auto">
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/30 bg-emerald-500/10 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-emerald-400">
            ✨ Architecture Pédagogique M'Andal
          </div>
          <h2 className="mt-4 font-display text-3xl font-black tracking-tight sm:text-4xl lg:text-5xl">
            Bien plus qu'un simple livre scolaire : <br className="hidden sm:inline" />
            <span className="bg-gradient-to-r from-emerald-400 via-amber-300 to-orange-400 bg-clip-text text-transparent">
              former le citoyen de demain
            </span>
          </h2>
          <p className="mt-3 text-slate-300 text-sm sm:text-base">
            Explorez les 3 volets d'excellence pour outiller et inspirer chaque apprenant.
          </p>
        </div>

        <div className="mt-14 grid grid-cols-1 gap-8 md:grid-cols-3">
          {pillars.map((p) => (
            <div
              key={p.num}
              className={cn(
                "group relative flex flex-col justify-between rounded-3xl border p-8 shadow-2xl transition-all duration-300 hover:-translate-y-1 hover:shadow-2xl",
                p.tone,
              )}
            >
              <div>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <span className="flex size-14 items-center justify-center rounded-2xl bg-white/10 text-3xl shadow-inner backdrop-blur-sm transition-transform duration-300 group-hover:scale-110">
                      {p.icon}
                    </span>
                    <span className="font-display text-3xl font-black tracking-wider text-white/90">
                      {p.num}
                    </span>
                  </div>
                  <span className={cn("rounded-full border px-3 py-1 text-xs font-bold", p.badgeBg)}>
                    {p.tag}
                  </span>
                </div>

                <div className="mt-6">
                  <h3 className="flex items-center gap-2 font-display text-2xl font-bold text-white">
                    <span>{p.icon}</span>
                    <span>{p.title}</span>
                  </h3>
                  <p className="mt-3 text-sm leading-relaxed text-slate-300">{p.desc}</p>
                </div>
              </div>

              <div className="mt-8 pt-4 border-t border-white/10">
                <Button asChild className={cn("w-full rounded-xl font-bold py-6 text-sm transition-all group-hover:scale-[1.02]", p.btnBg)}>
                  <Link to={p.to} className="flex items-center justify-center gap-2">
                    <span>Consulter le volet {p.title}</span>
                    <span>{p.icon}</span>
                    <ArrowRight className="size-4 ml-1 transition-transform group-hover:translate-x-1" />
                  </Link>
                </Button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function Footer() {
  const partners = [
    { src: "/images/partenaires/fondation-mackenzie.jpeg", alt: "Fondation Mackenzie" },
    { src: "/images/partenaires/jvepi.jpeg", alt: "JVEPI" },
    { src: "/images/partenaires/jvepi-centre.jpeg", alt: "JVEPI Centre" },
  ];

  return (
    <footer className="border-t border-border bg-card px-5 lg:px-8">
      <div className="mx-auto max-w-7xl py-12">
        <div className="grid grid-cols-1 gap-8 md:grid-cols-3">
          {/* Brand */}
          <div className="space-y-3">
            <MandalLogo />
            <p className="text-xs font-semibold text-emerald-600 dark:text-emerald-400 uppercase tracking-wide">
              « Apprendre avec sourire et rigueur »
            </p>
            <p className="text-sm text-muted-foreground leading-relaxed">
              Démocratiser le soutien scolaire et l'excellence académique pour tous les élèves du Cameroun.
            </p>
          </div>

          {/* Contact Details from Slide 13 */}
          <div className="space-y-3">
            <h3 className="font-display text-base font-bold text-foreground">Contact &amp; Informations</h3>
            <ul className="space-y-2 text-sm text-muted-foreground">
              <li className="flex items-center gap-2">
                <Phone className="size-4 text-emerald-500 shrink-0" />
                <span>Infoline : (+237) 690 50 41 28</span>
              </li>
              <li className="flex items-center gap-2">
                <Mail className="size-4 text-emerald-500 shrink-0" />
                <a href="mailto:contact@jvepi-mandalorgmandal.cm" className="hover:underline">
                  contact@jvepi-mandalorgmandal.cm
                </a>
              </li>
            </ul>
          </div>

          {/* Partenaires */}
          <div className="space-y-3">
            <h3 className="font-display text-base font-bold text-foreground">Partenaires institutionnels</h3>
            <div className="grid grid-cols-3 gap-3">
              {partners.map((partner) => (
                <div
                  key={partner.src}
                  className="flex h-16 items-center justify-center rounded-lg border border-border bg-background p-2"
                >
                  <img src={partner.src} alt={partner.alt} className="h-12 max-w-full object-contain" />
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      <div className="mx-auto flex max-w-7xl flex-col gap-4 border-t border-border py-6 sm:flex-row sm:items-center sm:justify-between">
        <p className="text-xs text-muted-foreground">
          © 2026 M'ANDAL (Mahol Andal) · Tous droits réservés.
        </p>
        <div className="flex flex-wrap gap-5 text-sm font-semibold text-muted-foreground">
          <Link to="/" className="hover:text-emerald-500">🏠 Accueil</Link>
          <Link to="/education" className="hover:text-emerald-500">📚 Éducation</Link>
          <Link to="/citoyennete" className="hover:text-orange-500">⚖️ Citoyenneté</Link>
          <Link to="/culture" className="hover:text-amber-500">🌍 Culture</Link>
          <a href="#parrainage" className="hover:text-foreground">🤝 Parrainage</a>
        </div>
      </div>
    </footer>
  );
}

function HomePage() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <Header />
      <Hero />
      <PillarsPreviewSection />

      {/* 1. Le Parrainage M'Andal visible directement sur la page d'accueil */}
      <MandalSponsorshipSection />

      {/* 2. Les Annonces positionnées à la fin de la page d'accueil */}
      <div className="py-8 bg-slate-950/90 border-t border-slate-800">
        <div className="mx-auto max-w-7xl px-5 lg:px-8 mb-4">
          <p className="text-xs font-bold uppercase tracking-wider text-emerald-400">Actualités &amp; Événements</p>
          <h2 className="font-display text-xl font-bold text-white">Les dernières annonces M'Andal</h2>
        </div>
        <AnnouncementsCarousel />
      </div>

      <Footer />
    </div>
  );
}