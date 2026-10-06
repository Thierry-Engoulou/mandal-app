import { useState } from "react";
import { Link } from "@tanstack/react-router";
import {
  GraduationCap,
  Scale,
  Sparkles,
  BookOpen,
  Award,
  CheckCircle2,
  Building2,
  Compass,
  ArrowRight,
  Landmark,
  ShieldCheck,
  HeartHandshake,
  Globe2,
  History,
  Palette,
  Flame,
  Layers,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";

export function MandalPedagogyTabs() {
  const [activeTab, setActiveTab] = useState<"education" | "citoyennete" | "culture">("education");

  const tabs = [
    {
      id: "education" as const,
      number: "01",
      title: "Éducation",
      badge: "Niveaux & Concours",
      desc: "Maîtrise des fondamentaux académiques et préparation méthodique aux grands concours et examens nationaux.",
      color: "from-emerald-600 to-teal-700",
      activeBorder: "border-emerald-500",
      activeBg: "bg-emerald-50 text-emerald-950 dark:bg-emerald-950/40 dark:text-emerald-200",
      pillColor: "bg-emerald-600 text-white",
      icon: GraduationCap,
    },
    {
      id: "citoyennete" as const,
      number: "02",
      title: "Citoyenneté",
      badge: "Droits & Devoirs",
      desc: "Conscience civique, respect des institutions et des devoirs républicains.",
      color: "from-orange-600 to-amber-700",
      activeBorder: "border-orange-500",
      activeBg: "bg-orange-50 text-orange-950 dark:bg-orange-950/40 dark:text-orange-200",
      pillColor: "bg-orange-600 text-white",
      icon: Scale,
    },
    {
      id: "culture" as const,
      number: "03",
      title: "Culture",
      badge: "Patrimoine & Histoire",
      desc: "Valorisation du patrimoine national, africain et ouverture intellectuelle.",
      color: "from-amber-500 to-yellow-600",
      activeBorder: "border-amber-500",
      activeBg: "bg-amber-50 text-amber-950 dark:bg-amber-950/40 dark:text-amber-200",
      pillColor: "bg-amber-600 text-white",
      icon: Sparkles,
    },
  ];

  return (
    <section id="architecture-pedagogique" className="relative overflow-hidden bg-slate-900 py-20 text-white lg:py-28">
      {/* Background glowing decorations */}
      <div className="pointer-events-none absolute -left-40 top-1/4 h-96 w-96 rounded-full bg-emerald-500/10 blur-3xl" />
      <div className="pointer-events-none absolute -right-40 bottom-1/4 h-96 w-96 rounded-full bg-amber-500/10 blur-3xl" />

      <div className="relative mx-auto max-w-7xl px-5 lg:px-8">
        {/* Header */}
        <div className="text-center">
          <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/30 bg-emerald-500/10 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-emerald-400">
            <Layers className="size-3.5" /> Architecture Pédagogique M'Andal
          </div>
          <h2 className="mt-4 font-display text-3xl font-extrabold tracking-tight text-white sm:text-4xl lg:text-5xl">
            Bien plus qu'un simple livre scolaire : <br className="hidden sm:inline" />
            <span className="bg-gradient-to-r from-emerald-400 via-teal-300 to-amber-300 bg-clip-text text-transparent">
              former le citoyen de demain
            </span>
          </h2>
          <p className="mx-auto mt-4 max-w-2xl text-base text-slate-300 sm:text-lg">
            Une approche d'excellence en 3 piliers complémentaires pour outiller chaque apprenant face aux défis du 21e siècle.
          </p>
        </div>

        {/* 3 Main Tabs Nav (Page 6 Style) */}
        <div className="mt-12 grid grid-cols-1 gap-4 sm:grid-cols-3">
          {tabs.map((tab) => {
            const isSelected = activeTab === tab.id;
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                type="button"
                onClick={() => setActiveTab(tab.id)}
                className={cn(
                  "group relative flex flex-col items-start justify-between rounded-2xl border p-6 text-left transition-all duration-200",
                  isSelected
                    ? "border-emerald-400/80 bg-slate-800/90 shadow-xl shadow-emerald-950/50 ring-2 ring-emerald-500/30"
                    : "border-slate-800 bg-slate-800/40 hover:border-slate-700 hover:bg-slate-800/70",
                )}
              >
                <div className="flex w-full items-center justify-between">
                  <span
                    className={cn(
                      "font-display text-2xl font-black transition-colors",
                      isSelected
                        ? tab.id === "education"
                          ? "text-emerald-400"
                          : tab.id === "citoyennete"
                            ? "text-orange-400"
                            : "text-amber-400"
                        : "text-slate-500 group-hover:text-slate-400",
                    )}
                  >
                    {tab.number}
                  </span>
                  <div
                    className={cn(
                      "flex size-10 items-center justify-center rounded-xl transition-all",
                      isSelected ? tab.pillColor : "bg-slate-700/50 text-slate-400 group-hover:text-white",
                    )}
                  >
                    <Icon className="size-5" />
                  </div>
                </div>

                <div className="mt-5">
                  <h3 className="font-display text-xl font-bold text-white group-hover:text-white">
                    {tab.title}
                  </h3>
                  <p className="mt-2 text-xs leading-relaxed text-slate-300 sm:text-sm">
                    {tab.desc}
                  </p>
                </div>

                {isSelected && (
                  <div className="mt-4 flex items-center gap-1.5 text-xs font-semibold text-emerald-400">
                    <span>Explorer ce volet</span>
                    <ArrowRight className="size-3.5" />
                  </div>
                )}
              </button>
            );
          })}
        </div>

        {/* Tab Content Display */}
        <div className="mt-10 rounded-3xl border border-slate-800 bg-slate-950/80 p-6 shadow-2xl backdrop-blur-xl sm:p-8 lg:p-12">
          {/* TAB 1: EDUCATION */}
          {activeTab === "education" && (
            <div className="space-y-10 animate-in fade-in duration-300">
              <div>
                <div className="inline-flex items-center gap-2 rounded-lg bg-emerald-500/10 px-3 py-1 text-xs font-bold uppercase tracking-wide text-emerald-400">
                  <GraduationCap className="size-4" /> Volet 01 : Éducation
                </div>
                <h3 className="mt-2 font-display text-2xl font-bold text-white sm:text-3xl">
                  Éducation : Niveaux scolaires & Concours
                </h3>
                <p className="mt-1 text-base text-emerald-300/90 font-medium">
                  Le parcours de l'élève, du BEPC aux grands concours d'entrée
                </p>
              </div>

              {/* Grid: Niveaux Scolaires & Concours */}
              <div className="grid grid-cols-1 gap-8 lg:grid-cols-2">
                {/* 1. Niveaux Scolaires */}
                <div className="flex flex-col justify-between rounded-2xl border border-slate-800 bg-slate-900/90 p-6 sm:p-8">
                  <div>
                    <div className="flex items-center gap-3">
                      <div className="flex size-10 items-center justify-center rounded-xl bg-emerald-500/20 text-emerald-400">
                        <BookOpen className="size-5" />
                      </div>
                      <div>
                        <h4 className="font-display text-lg font-bold text-white">Niveaux Scolaires</h4>
                        <p className="text-xs text-slate-400">Du secondaire supérieur aux premiers cycles universitaires</p>
                      </div>
                    </div>

                    {/* School levels tags */}
                    <div className="mt-6 flex flex-wrap gap-2.5">
                      {[
                        { name: "BEPC", highlight: false },
                        { name: "Probatoire", highlight: false },
                        { name: "Baccalauréat (Séries A · C · D)", highlight: true },
                        { name: "Advanced Level", highlight: false },
                        { name: "ENS Technique", highlight: false },
                        { name: "Université", highlight: false },
                      ].map((item) => (
                        <span
                          key={item.name}
                          className={cn(
                            "inline-flex items-center rounded-xl px-3.5 py-2 text-xs font-bold transition-all sm:text-sm",
                            item.highlight
                              ? "border border-amber-500/40 bg-amber-500/15 text-amber-300"
                              : "border border-slate-700 bg-slate-800 text-slate-200 hover:border-emerald-500/50 hover:bg-slate-750",
                          )}
                        >
                          {item.name}
                        </span>
                      ))}
                    </div>

                    {/* Features list */}
                    <div className="mt-8 rounded-xl border border-emerald-500/20 bg-emerald-950/20 p-4 sm:p-5">
                      <p className="text-xs font-bold uppercase tracking-wider text-emerald-400">
                        Outils & Contenus disponibles par niveau :
                      </p>
                      <ul className="mt-3 grid grid-cols-1 gap-2.5 sm:grid-cols-2">
                        {[
                          "Cours structurés & syllabus",
                          "Épreuves types & Quiz",
                          "Correction d'épreuves pas à pas",
                          "Épreuves de bourse d'excellence",
                          "Simulation virtuelle & graphiques",
                          "Suivi et progression continue",
                        ].map((feature) => (
                          <li key={feature} className="flex items-center gap-2 text-xs text-slate-300 sm:text-sm">
                            <CheckCircle2 className="size-4 shrink-0 text-emerald-400" />
                            <span>{feature}</span>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>

                  <div className="mt-8 pt-4 border-t border-slate-800 flex justify-end">
                    <Button asChild className="w-full sm:w-auto bg-emerald-600 text-white hover:bg-emerald-500">
                      <Link to="/courses">
                        Accéder aux cours scolaires <ArrowRight className="ml-2 size-4" />
                      </Link>
                    </Button>
                  </div>
                </div>

                {/* 2. Grands Concours */}
                <div className="flex flex-col justify-between rounded-2xl border border-slate-800 bg-slate-900/90 p-6 sm:p-8">
                  <div>
                    <div className="flex items-center gap-3">
                      <div className="flex size-10 items-center justify-center rounded-xl bg-amber-500/20 text-amber-400">
                        <Award className="size-5" />
                      </div>
                      <div>
                        <h4 className="font-display text-lg font-bold text-white">Concours d'Excellence</h4>
                        <p className="text-xs text-slate-400">Préparations intensives aux grandes écoles du Cameroun</p>
                      </div>
                    </div>

                    <div className="mt-6 space-y-4">
                      {/* ENSPD */}
                      <div className="rounded-xl border border-slate-700/80 bg-slate-800/70 p-4 transition hover:border-slate-600">
                        <div className="flex items-center justify-between">
                          <h5 className="font-display font-bold text-white text-base">
                            ENSPD (École Nationale Supérieure Polytechnique de Douala)
                          </h5>
                          <span className="rounded-md bg-emerald-500/20 px-2 py-0.5 text-[11px] font-semibold text-emerald-400">
                            Ingénierie
                          </span>
                        </div>
                        <ul className="mt-2 space-y-1.5 text-xs text-slate-300">
                          <li className="flex items-center gap-2">
                            <span className="size-1.5 rounded-full bg-amber-400" />
                            <span>Présentation de l'école & débouchés</span>
                          </li>
                          <li className="flex items-center gap-2">
                            <span className="size-1.5 rounded-full bg-amber-400" />
                            <span>Concours d'entrée (après Bac, Probatoire, BEPC/CAP, autre)</span>
                          </li>
                          <li className="flex items-center gap-2">
                            <span className="size-1.5 rounded-full bg-amber-400" />
                            <span>Cours de renforcement & méthodologie</span>
                          </li>
                          <li className="flex items-center gap-2">
                            <span className="size-1.5 rounded-full bg-amber-400" />
                            <span>Correction d'épreuves des sessions antérieures</span>
                          </li>
                        </ul>
                      </div>

                      {/* IUT */}
                      <div className="rounded-xl border border-slate-700/80 bg-slate-800/70 p-4 transition hover:border-slate-600">
                        <div className="flex items-center justify-between">
                          <h5 className="font-display font-bold text-white text-base">
                            IUT (Instituts Universitaires de Technologie)
                          </h5>
                          <span className="rounded-md bg-blue-500/20 px-2 py-0.5 text-[11px] font-semibold text-blue-400">
                            Technologie & Métiers
                          </span>
                        </div>
                        <ul className="mt-2 space-y-1.5 text-xs text-slate-300">
                          <li className="flex items-center gap-2">
                            <span className="size-1.5 rounded-full bg-amber-400" />
                            <span>Présentation de l'IUT et filières professionnalisantes</span>
                          </li>
                          <li className="flex items-center gap-2">
                            <span className="size-1.5 rounded-full bg-amber-400" />
                            <span>Filières technologiques & industrielles</span>
                          </li>
                          <li className="flex items-center gap-2">
                            <span className="size-1.5 rounded-full bg-amber-400" />
                            <span>Physique appliquée, Mathématiques et Spécialités</span>
                          </li>
                        </ul>
                      </div>
                    </div>
                  </div>

                  <div className="mt-8 pt-4 border-t border-slate-800 flex justify-end">
                    <Button asChild variant="outline" className="w-full sm:w-auto border-amber-500/40 text-amber-300 hover:bg-amber-500/10">
                      <Link to="/courses">
                        Découvrir les prépas concours <ArrowRight className="ml-2 size-4" />
                      </Link>
                    </Button>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* TAB 2: CITOYENNETE */}
          {activeTab === "citoyennete" && (
            <div className="space-y-10 animate-in fade-in duration-300">
              <div>
                <div className="inline-flex items-center gap-2 rounded-lg bg-orange-500/10 px-3 py-1 text-xs font-bold uppercase tracking-wide text-orange-400">
                  <Scale className="size-4" /> Volet 02 : Citoyenneté
                </div>
                <h3 className="mt-2 font-display text-2xl font-bold text-white sm:text-3xl">
                  Citoyenneté & Conscience Républicaine
                </h3>
                <p className="mt-1 text-base text-orange-300/90 font-medium">
                  Comprendre ses droits, ses devoirs et l'engagement civique
                </p>
              </div>

              {/* 3 Columns matching Slide 8 */}
              <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
                {/* 1. Institutions et droits */}
                <div className="rounded-2xl border border-slate-800 bg-slate-900/90 p-6 flex flex-col justify-between">
                  <div>
                    <div className="flex size-11 items-center justify-center rounded-xl bg-orange-500/20 text-orange-400">
                      <Landmark className="size-6" />
                    </div>
                    <h4 className="mt-4 font-display text-lg font-bold text-white">Institutions et droits</h4>
                    <p className="mt-1 text-xs text-slate-400">Le cadre démocratique et la protection des libertés</p>

                    <ul className="mt-6 space-y-3 text-sm text-slate-300">
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-orange-400 shrink-0 mt-0.5" />
                        <span><strong>La Constitution</strong> et les institutions de la République</span>
                      </li>
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-orange-400 shrink-0 mt-0.5" />
                        <span><strong>Droits de l'enfant</strong> et de l'élève dans le cadre scolaire</span>
                      </li>
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-orange-400 shrink-0 mt-0.5" />
                        <span><strong>Le rôle du citoyen</strong> éclairé en démocratie</span>
                      </li>
                    </ul>
                  </div>
                </div>

                {/* 2. Devoirs et vivre-ensemble */}
                <div className="rounded-2xl border border-slate-800 bg-slate-900/90 p-6 flex flex-col justify-between">
                  <div>
                    <div className="flex size-11 items-center justify-center rounded-xl bg-amber-500/20 text-amber-400">
                      <ShieldCheck className="size-6" />
                    </div>
                    <h4 className="mt-4 font-display text-lg font-bold text-white">Devoirs et vivre-ensemble</h4>
                    <p className="mt-1 text-xs text-slate-400">L'éthique, la tolérance et la cohésion nationale</p>

                    <ul className="mt-6 space-y-3 text-sm text-slate-300">
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-amber-400 shrink-0 mt-0.5" />
                        <span><strong>Respect des lois</strong> et protection du bien commun</span>
                      </li>
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-amber-400 shrink-0 mt-0.5" />
                        <span><strong>Lutte contre la corruption</strong> et l'incivisme au quotidien</span>
                      </li>
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-amber-400 shrink-0 mt-0.5" />
                        <span><strong>Cohabitation pacifique</strong>, dialogue et tolérance interculturelle</span>
                      </li>
                    </ul>
                  </div>
                </div>

                {/* 3. Engagement civique */}
                <div className="rounded-2xl border border-slate-800 bg-slate-900/90 p-6 flex flex-col justify-between">
                  <div>
                    <div className="flex size-11 items-center justify-center rounded-xl bg-teal-500/20 text-teal-400">
                      <HeartHandshake className="size-6" />
                    </div>
                    <h4 className="mt-4 font-display text-lg font-bold text-white">Engagement civique</h4>
                    <p className="mt-1 text-xs text-slate-400">Agir concrètement pour transformer sa communauté</p>

                    <ul className="mt-6 space-y-3 text-sm text-slate-300">
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-teal-400 shrink-0 mt-0.5" />
                        <span><strong>Participer activement</strong> à la vie de sa communauté</span>
                      </li>
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-teal-400 shrink-0 mt-0.5" />
                        <span><strong>Bénévolat</strong>, solidarité et action associative</span>
                      </li>
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-teal-400 shrink-0 mt-0.5" />
                        <span><strong>Comprendre les élections</strong>, le vote et la responsabilité civile</span>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* TAB 3: CULTURE */}
          {activeTab === "culture" && (
            <div className="space-y-10 animate-in fade-in duration-300">
              <div>
                <div className="inline-flex items-center gap-2 rounded-lg bg-amber-500/10 px-3 py-1 text-xs font-bold uppercase tracking-wide text-amber-400">
                  <Sparkles className="size-4" /> Volet 03 : Culture
                </div>
                <h3 className="mt-2 font-display text-2xl font-bold text-white sm:text-3xl">
                  Culture, Racines & Fierté Africaine
                </h3>
                <p className="mt-1 text-base text-amber-300/90 font-medium">
                  Valoriser le patrimoine africain plus précisément Camerounais et son histoire millénaire
                </p>
              </div>

              {/* 3 Columns matching Slide 9 */}
              <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
                {/* 1. Histoire du continent */}
                <div className="rounded-2xl border border-slate-800 bg-slate-900/90 p-6 flex flex-col justify-between">
                  <div>
                    <div className="flex size-11 items-center justify-center rounded-xl bg-amber-500/20 text-amber-400">
                      <History className="size-6" />
                    </div>
                    <h4 className="mt-4 font-display text-lg font-bold text-white">Histoire du continent</h4>
                    <p className="mt-1 text-xs text-slate-400">Comprendre nos origines et trajectoires historiques</p>

                    <ul className="mt-6 space-y-3 text-sm text-slate-300">
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-amber-400 shrink-0 mt-0.5" />
                        <span><strong>Grands royaumes</strong> et empires africains</span>
                      </li>
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-amber-400 shrink-0 mt-0.5" />
                        <span><strong>La période précoloniale</strong> et ses savoirs ancestraux</span>
                      </li>
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-amber-400 shrink-0 mt-0.5" />
                        <span><strong>Colonisation</strong>, luttes de libération et indépendances</span>
                      </li>
                    </ul>
                  </div>
                </div>

                {/* 2. Patrimoine culturel */}
                <div className="rounded-2xl border border-slate-800 bg-slate-900/90 p-6 flex flex-col justify-between">
                  <div>
                    <div className="flex size-11 items-center justify-center rounded-xl bg-emerald-500/20 text-emerald-400">
                      <Palette className="size-6" />
                    </div>
                    <h4 className="mt-4 font-display text-lg font-bold text-white">Patrimoine culturel</h4>
                    <p className="mt-1 text-xs text-slate-400">La richesse vivante des arts et des traditions</p>

                    <ul className="mt-6 space-y-3 text-sm text-slate-300">
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-emerald-400 shrink-0 mt-0.5" />
                        <span><strong>Langues nationales</strong> et traditions orales</span>
                      </li>
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-emerald-400 shrink-0 mt-0.5" />
                        <span><strong>Arts, artisanat</strong> et architecture traditionnels</span>
                      </li>
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-emerald-400 shrink-0 mt-0.5" />
                        <span><strong>Musique et danses</strong> du Cameroun et d'Afrique</span>
                      </li>
                    </ul>
                  </div>
                </div>

                {/* 3. Figures et fierté africaine */}
                <div className="rounded-2xl border border-slate-800 bg-slate-900/90 p-6 flex flex-col justify-between">
                  <div>
                    <div className="flex size-11 items-center justify-center rounded-xl bg-orange-500/20 text-orange-400">
                      <Flame className="size-6" />
                    </div>
                    <h4 className="mt-4 font-display text-lg font-bold text-white">Figures et fierté</h4>
                    <p className="mt-1 text-xs text-slate-400">Les modèles d'inspiration pour la jeunesse</p>

                    <ul className="mt-6 space-y-3 text-sm text-slate-300">
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-orange-400 shrink-0 mt-0.5" />
                        <span><strong>Grandes figures</strong> historiques et contemporaines</span>
                      </li>
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-orange-400 shrink-0 mt-0.5" />
                        <span><strong>Innovations africaines</strong> apportées au monde</span>
                      </li>
                      <li className="flex items-start gap-2.5">
                        <CheckCircle2 className="size-4 text-orange-400 shrink-0 mt-0.5" />
                        <span><strong>Construire une identité</strong> africaine positive et ambitieuse</span>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
