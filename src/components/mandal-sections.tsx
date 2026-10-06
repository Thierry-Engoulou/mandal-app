import { Link } from "@tanstack/react-router";
import {
  GraduationCap,
  Scale,
  Sparkles,
  BookOpen,
  Award,
  CheckCircle2,
  Building2,
  ArrowRight,
  Landmark,
  ShieldCheck,
  HeartHandshake,
  History,
  Palette,
  Flame,
  Binary,
  Atom,
  HelpCircle,
} from "lucide-react";
import { Button } from "@/components/ui/button";

export function EducationSection() {
  const schoolLevels = [
    { name: "BEPC", desc: "Premier cycle secondaire", highlight: false },
    { name: "Probatoire", desc: "Enseignement général & technique", highlight: false },
    { name: "Baccalauréat (Séries A · C · D)", desc: "Examen décisif vers le supérieur", highlight: true },
    { name: "Advanced Level", desc: "Section anglophone", highlight: false },
    { name: "ENS Technique", desc: "Formation des professeurs techniques", highlight: false },
    { name: "Université", desc: "Licence, Master & Doctorat", highlight: false },
  ];

  const tools = [
    { title: "Cours de Mathématiques & Physique", detail: "Syllabus complet, fiches de synthèse, formules clés et démonstrations" },
    { title: "Épreuves & Quiz interactifs", detail: "Entraînements chronométrés et tests d'auto-évaluation par chapitre" },
    { title: "Correction d'épreuves pas à pas", detail: "Corrigés détaillés et barèmes officiels des sessions antérieures" },
    { title: "Épreuves de bourse d'excellence", detail: "Sujets de sélection pour les programmes de financement et bourses" },
    { title: "Simulation virtuelle & GeoGebra", detail: "Visualisations graphiques interactives de fonctions et expériences de physique" },
  ];

  return (
    <section id="education" className="relative scroll-mt-20 bg-slate-900 py-20 text-white lg:py-28 border-b border-slate-800">
      <div className="mx-auto max-w-7xl px-5 lg:px-8">
        {/* Section Header */}
        <div className="flex flex-col items-start gap-4 md:flex-row md:items-end md:justify-between">
          <div>
            <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/40 bg-emerald-500/15 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-emerald-300">
              <GraduationCap className="size-4" /> Volet 01 · Éducation
            </div>
            <h2 className="mt-4 font-display text-3xl font-black text-white sm:text-4xl lg:text-5xl">
              Éducation : Niveaux scolaires &amp; Concours
            </h2>
            <p className="mt-2 text-lg font-medium text-emerald-300 sm:text-xl">
              Le parcours de l'élève, du BEPC aux grands concours d'entrée
            </p>
          </div>
          <p className="max-w-md text-sm text-slate-300">
            Maîtrise des fondamentaux académiques (Maths, Physique, SVT, etc.) et préparation méthodique aux grands examens et concours nationaux.
          </p>
        </div>

        {/* Content Layout */}
        <div className="mt-12 grid grid-cols-1 gap-8 lg:grid-cols-12">
          {/* Left Column: Niveaux Scolaires (7 cols) */}
          <div className="space-y-6 lg:col-span-7">
            <div className="rounded-3xl border border-slate-800 bg-slate-950/80 p-6 sm:p-8 shadow-xl">
              <div className="flex items-center gap-3">
                <div className="flex size-11 items-center justify-center rounded-2xl bg-emerald-500/20 text-emerald-400">
                  <BookOpen className="size-6" />
                </div>
                <div>
                  <h3 className="font-display text-xl font-bold text-white">NIVEAUX SCOLAIRES</h3>
                  <p className="text-xs text-slate-400">Un accompagnement adapté à chaque étape du secondaire et du supérieur</p>
                </div>
              </div>

              {/* Badges Grid */}
              <div className="mt-6 grid grid-cols-1 gap-3 sm:grid-cols-2">
                {schoolLevels.map((lvl) => (
                  <div
                    key={lvl.name}
                    className={`rounded-2xl border p-4 transition-all ${
                      lvl.highlight
                        ? "border-amber-500/50 bg-amber-500/10 text-white"
                        : "border-slate-800 bg-slate-900 text-slate-200"
                    }`}
                  >
                    <div className="flex items-center justify-between">
                      <h4 className="font-display text-sm font-bold">{lvl.name}</h4>
                      {lvl.highlight && (
                        <span className="rounded-full bg-amber-500/20 px-2 py-0.5 text-[10px] font-bold text-amber-300">
                          Séries A · C · D
                        </span>
                      )}
                    </div>
                    <p className="mt-1 text-xs text-slate-400">{lvl.desc}</p>
                  </div>
                ))}
              </div>

              {/* Outils et Contenus */}
              <div className="mt-8 rounded-2xl border border-emerald-500/25 bg-emerald-950/30 p-5">
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-400">
                  <Binary className="size-4" /> Outils pédagogiques &amp; Contenus de cours (Maths &amp; Physique)
                </div>
                <div className="mt-4 space-y-3">
                  {tools.map((t) => (
                    <div key={t.title} className="flex items-start gap-3">
                      <CheckCircle2 className="size-4 text-emerald-400 shrink-0 mt-1" />
                      <div>
                        <p className="text-sm font-semibold text-white">{t.title}</p>
                        <p className="text-xs text-slate-300">{t.detail}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Right Column: CONCOURS (5 cols) */}
          <div className="space-y-6 lg:col-span-5">
            <div className="rounded-3xl border border-slate-800 bg-slate-950/80 p-6 sm:p-8 shadow-xl flex flex-col justify-between h-full">
              <div>
                <div className="flex items-center gap-3">
                  <div className="flex size-11 items-center justify-center rounded-2xl bg-amber-500/20 text-amber-400">
                    <Award className="size-6" />
                  </div>
                  <div>
                    <h3 className="font-display text-xl font-bold text-white">CONCOURS D'ENTRÉE</h3>
                    <p className="text-xs text-slate-400">Préparation aux grandes écoles d'ingénieurs et technologiques</p>
                  </div>
                </div>

                <div className="mt-6 space-y-5">
                  {/* ENSPD */}
                  <div className="rounded-2xl border border-slate-700 bg-slate-900 p-5">
                    <div className="flex items-center justify-between">
                      <h4 className="font-display text-base font-bold text-white">ENSPD</h4>
                      <span className="rounded-full bg-emerald-500/20 px-2.5 py-0.5 text-xs font-semibold text-emerald-300">
                        Polytechnique Douala
                      </span>
                    </div>
                    <ul className="mt-3 space-y-2 text-xs text-slate-300">
                      <li className="flex items-center gap-2">
                        <span className="size-1.5 rounded-full bg-amber-400" />
                        <span><strong>Présentation de l'école</strong> &amp; débouchés professionnels</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <span className="size-1.5 rounded-full bg-amber-400" />
                        <span><strong>Concours d'entrée</strong> (après Bac, Probatoire, BEPC/CAP, autre)</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <span className="size-1.5 rounded-full bg-amber-400" />
                        <span><strong>Cours préparatoires intensifs</strong> (Maths, Physique-Chimie)</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <span className="size-1.5 rounded-full bg-amber-400" />
                        <span><strong>Correction d'épreuves</strong> et annales corrigées</span>
                      </li>
                    </ul>
                  </div>

                  {/* IUT */}
                  <div className="rounded-2xl border border-slate-700 bg-slate-900 p-5">
                    <div className="flex items-center justify-between">
                      <h4 className="font-display text-base font-bold text-white">IUT</h4>
                      <span className="rounded-full bg-blue-500/20 px-2.5 py-0.5 text-xs font-semibold text-blue-300">
                        Filières Technologiques
                      </span>
                    </div>
                    <ul className="mt-3 space-y-2 text-xs text-slate-300">
                      <li className="flex items-center gap-2">
                        <span className="size-1.5 rounded-full bg-amber-400" />
                        <span><strong>Présentation de l'IUT</strong></span>
                      </li>
                      <li className="flex items-center gap-2">
                        <span className="size-1.5 rounded-full bg-amber-400" />
                        <span><strong>Filière technologique</strong> &amp; industrielle</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <span className="size-1.5 rounded-full bg-amber-400" />
                        <span><strong>Physique appliquée</strong> &amp; sciences de l'ingénieur</span>
                      </li>
                      <li className="flex items-center gap-2">
                        <span className="size-1.5 rounded-full bg-amber-400" />
                        <span><strong>Spécialités</strong>, métiers et passerelles</span>
                      </li>
                    </ul>
                  </div>
                </div>
              </div>

              <div className="mt-8 pt-4 border-t border-slate-800">
                <Button asChild className="w-full rounded-xl bg-emerald-600 font-bold text-white hover:bg-emerald-500">
                  <Link to="/courses">
                    Accéder aux modules d'apprentissage <ArrowRight className="ml-2 size-4" />
                  </Link>
                </Button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export function CitizenshipSection() {
  return (
    <section id="citoyennete" className="relative scroll-mt-20 bg-slate-950 py-20 text-white lg:py-28 border-b border-slate-800">
      <div className="mx-auto max-w-7xl px-5 lg:px-8">
        {/* Section Header */}
        <div className="flex flex-col items-start gap-4 md:flex-row md:items-end md:justify-between">
          <div>
            <div className="inline-flex items-center gap-2 rounded-full border border-orange-500/40 bg-orange-500/15 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-orange-300">
              <Scale className="size-4" /> Volet 02 · Citoyenneté
            </div>
            <h2 className="mt-4 font-display text-3xl font-black text-white sm:text-4xl lg:text-5xl">
              Citoyenneté
            </h2>
            <p className="mt-2 text-lg font-medium text-orange-300 sm:text-xl">
              Comprendre ses droits, ses devoirs et l'engagement civique
            </p>
          </div>
          <p className="max-w-md text-sm text-slate-300">
            Conscience civique, respect des institutions et acquisition des devoirs républicains pour former des citoyens intègres et engagés.
          </p>
        </div>

        {/* 3 Pillars Cards matching Page 8 */}
        <div className="mt-12 grid grid-cols-1 gap-6 md:grid-cols-3">
          {/* Card 1: Institutions et droits */}
          <div className="flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-900/90 p-8 shadow-xl transition hover:border-orange-500/40">
            <div>
              <div className="flex size-12 items-center justify-center rounded-2xl bg-orange-500/20 text-orange-400">
                <Landmark className="size-6" />
              </div>
              <h3 className="mt-6 font-display text-xl font-bold text-white">Institutions et droits</h3>
              <p className="mt-1 text-xs text-slate-400">Fondements juridiques et protection républicaine</p>

              <ul className="mt-6 space-y-3.5 text-sm text-slate-300">
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-orange-400 shrink-0 mt-0.5" />
                  <span><strong>La Constitution</strong> et les institutions</span>
                </li>
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-orange-400 shrink-0 mt-0.5" />
                  <span><strong>Droits de l'enfant</strong> et de l'élève</span>
                </li>
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-orange-400 shrink-0 mt-0.5" />
                  <span><strong>Le rôle du citoyen</strong> en démocratie</span>
                </li>
              </ul>
            </div>
          </div>

          {/* Card 2: Devoirs et vivre-ensemble */}
          <div className="flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-900/90 p-8 shadow-xl transition hover:border-amber-500/40">
            <div>
              <div className="flex size-12 items-center justify-center rounded-2xl bg-amber-500/20 text-amber-400">
                <ShieldCheck className="size-6" />
              </div>
              <h3 className="mt-6 font-display text-xl font-bold text-white">Devoirs et vivre-ensemble</h3>
              <p className="mt-1 text-xs text-slate-400">Éthique, respect mutuel et paix sociale</p>

              <ul className="mt-6 space-y-3.5 text-sm text-slate-300">
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-amber-400 shrink-0 mt-0.5" />
                  <span><strong>Respect des lois</strong> et du bien commun</span>
                </li>
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-amber-400 shrink-0 mt-0.5" />
                  <span><strong>Lutte contre la corruption</strong> au quotidien</span>
                </li>
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-amber-400 shrink-0 mt-0.5" />
                  <span><strong>Cohabitation pacifique</strong> et tolérance</span>
                </li>
              </ul>
            </div>
          </div>

          {/* Card 3: Engagement civique */}
          <div className="flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-900/90 p-8 shadow-xl transition hover:border-teal-500/40">
            <div>
              <div className="flex size-12 items-center justify-center rounded-2xl bg-teal-500/20 text-teal-400">
                <HeartHandshake className="size-6" />
              </div>
              <h3 className="mt-6 font-display text-xl font-bold text-white">Engagement civique</h3>
              <p className="mt-1 text-xs text-slate-400">L'action concrète au service de la nation</p>

              <ul className="mt-6 space-y-3.5 text-sm text-slate-300">
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-teal-400 shrink-0 mt-0.5" />
                  <span><strong>Participer à la vie</strong> de sa communauté</span>
                </li>
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-teal-400 shrink-0 mt-0.5" />
                  <span><strong>Bénévolat</strong> et action associative</span>
                </li>
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-teal-400 shrink-0 mt-0.5" />
                  <span><strong>Comprendre les élections</strong> et le vote</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

export function CultureSection() {
  return (
    <section id="culture" className="relative scroll-mt-20 bg-slate-900 py-20 text-white lg:py-28 border-b border-slate-800">
      <div className="mx-auto max-w-7xl px-5 lg:px-8">
        {/* Section Header */}
        <div className="flex flex-col items-start gap-4 md:flex-row md:items-end md:justify-between">
          <div>
            <div className="inline-flex items-center gap-2 rounded-full border border-amber-500/40 bg-amber-500/15 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-amber-300">
              <Sparkles className="size-4" /> Volet 03 · Culture
            </div>
            <h2 className="mt-4 font-display text-3xl font-black text-white sm:text-4xl lg:text-5xl">
              Culture
            </h2>
            <p className="mt-2 text-lg font-medium text-amber-300 sm:text-xl">
              Valoriser le patrimoine africain plus précisément Camerounais et son histoire millénaire
            </p>
          </div>
          <p className="max-w-md text-sm text-slate-300">
            Valorisation du patrimoine national, réappropriation historique et fierté des savoirs et innovations du continent.
          </p>
        </div>

        {/* 3 Pillars Cards matching Page 9 */}
        <div className="mt-12 grid grid-cols-1 gap-6 md:grid-cols-3">
          {/* Card 1: Histoire du continent */}
          <div className="flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-950/80 p-8 shadow-xl transition hover:border-amber-500/40">
            <div>
              <div className="flex size-12 items-center justify-center rounded-2xl bg-amber-500/20 text-amber-400">
                <History className="size-6" />
              </div>
              <h3 className="mt-6 font-display text-xl font-bold text-white">Histoire du continent</h3>
              <p className="mt-1 text-xs text-slate-400">La trajectoire de nos civilisations millénaires</p>

              <ul className="mt-6 space-y-3.5 text-sm text-slate-300">
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-amber-400 shrink-0 mt-0.5" />
                  <span><strong>Grands royaumes</strong> et empires africains</span>
                </li>
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-amber-400 shrink-0 mt-0.5" />
                  <span><strong>La période précoloniale</strong></span>
                </li>
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-amber-400 shrink-0 mt-0.5" />
                  <span><strong>Colonisation</strong> et indépendances</span>
                </li>
              </ul>
            </div>
          </div>

          {/* Card 2: Patrimoine culturel */}
          <div className="flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-950/80 p-8 shadow-xl transition hover:border-emerald-500/40">
            <div>
              <div className="flex size-12 items-center justify-center rounded-2xl bg-emerald-500/20 text-emerald-400">
                <Palette className="size-6" />
              </div>
              <h3 className="mt-6 font-display text-xl font-bold text-white">Patrimoine culturel</h3>
              <p className="mt-1 text-xs text-slate-400">L'expression vivante des arts et savoir-faire camerounais</p>

              <ul className="mt-6 space-y-3.5 text-sm text-slate-300">
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-emerald-400 shrink-0 mt-0.5" />
                  <span><strong>Langues</strong> et traditions orales</span>
                </li>
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-emerald-400 shrink-0 mt-0.5" />
                  <span><strong>Arts et artisanat</strong> africains</span>
                </li>
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-emerald-400 shrink-0 mt-0.5" />
                  <span><strong>Musique</strong> et danses traditionnelles</span>
                </li>
              </ul>
            </div>
          </div>

          {/* Card 3: Figures et fierté africaine */}
          <div className="flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-950/80 p-8 shadow-xl transition hover:border-orange-500/40">
            <div>
              <div className="flex size-12 items-center justify-center rounded-2xl bg-orange-500/20 text-orange-400">
                <Flame className="size-6" />
              </div>
              <h3 className="mt-6 font-display text-xl font-bold text-white">Figures et fierté africaine</h3>
              <p className="mt-1 text-xs text-slate-400">Inspirer la jeunesse par l'excellence de nos modèles</p>

              <ul className="mt-6 space-y-3.5 text-sm text-slate-300">
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-orange-400 shrink-0 mt-0.5" />
                  <span><strong>Grandes figures</strong> historiques africaines</span>
                </li>
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-orange-400 shrink-0 mt-0.5" />
                  <span><strong>Innovations africaines</strong> au monde</span>
                </li>
                <li className="flex items-start gap-3">
                  <CheckCircle2 className="size-4 text-orange-400 shrink-0 mt-0.5" />
                  <span><strong>Construire une identité</strong> africaine positive</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
