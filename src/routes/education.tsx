import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { useState, useEffect } from "react";
import { z } from "zod";
import {
  GraduationCap,
  BookOpen,
  Award,
  CheckCircle2,
  Binary,
  ArrowRight,
  ArrowLeft,
  Sparkles,
  Layers,
  ChevronRight,
  PlayCircle,
  FileText,
  Lock,
  Search,
  Check,
  Building2,
  Cpu,
  Atom,
  Calculator,
  Compass,
  FileCheck2,
  HelpCircle,
  Flame,
} from "lucide-react";
import { MandalLogo } from "@/components/mandal-logo";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { AuthRequiredModal } from "@/components/auth-required-modal";
import { supabase } from "@/integrations/supabase/client";
import { cn } from "@/lib/utils";
import {
  ANNEES_SUJETS,
  CONCOURS,
  ENSEIGNEMENT_GENERAL,
  EXAMENS_GENERAL,
  EXAMENS_TECHNIQUE,
  TECHNIQUE_COMMERCIAL,
  TECHNIQUE_INDUSTRIEL,
  TOUS_LES_PARCOURS,
  type Concours,
  type LienSujets,
  type Section,
} from "@/lib/education-structure";

const educationSearchSchema = z.object({
  niveau: z.string().optional(),
});

export const Route = createFileRoute("/education")({
  validateSearch: (search) => educationSearchSchema.parse(search),
  head: () => ({
    meta: [
      { title: "Éducation : Niveaux scolaires & Concours — M'ANDAL" },
      {
        name: "description",
        content:
          "Le parcours de l'élève, du BEPC aux grands concours d'entrée (ENSPD, IUT, ENS, Baccalauréat).",
      },
    ],
  }),
  component: EducationPage,
});

export function EducationPage() {
  const navigate = useNavigate();
  const searchParams = Route.useSearch();
  const [userSession, setUserSession] = useState<{ id: string } | null>(null);
  const [authModalOpen, setAuthModalOpen] = useState(false);
  const [modalCourseTitle, setModalCourseTitle] = useState("Mathématiques 1ère");
  const [modalLevelId, setModalLevelId] = useState("probatoire");
  const [searchQuery, setSearchQuery] = useState("");

  // Niveau actif basé sur le search param de l'URL
  const activeLevel = TOUS_LES_PARCOURS.find((p) => p.id === searchParams.niveau) ?? null;

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      if (data.session?.user) {
        setUserSession({ id: data.session.user.id });
      }
    });
  }, []);

  const handleSelectLevel = (levelId: string) => {
    navigate({
      to: "/education",
      search: { niveau: levelId },
    });
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleBackToLevels = () => {
    navigate({
      to: "/education",
      search: { niveau: undefined },
    });
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const handleOpenCourse = (title: string, levelId: string) => {
    if (userSession) {
      window.location.href = "/etudiant/cours";
    } else {
      setModalCourseTitle(title);
      setModalLevelId(levelId);
      setAuthModalOpen(true);
    }
  };

  // Filtrage des matières si recherche
  const filteredSubjects = activeLevel
    ? activeLevel.matieres.filter((s) => {
        if (!searchQuery.trim()) return true;
        const q = searchQuery.toLowerCase();
        return (
          s.matiere.toLowerCase().includes(q) ||
          (s.description ?? "").toLowerCase().includes(q) ||
          s.chapitres.some((c) => c.toLowerCase().includes(q))
        );
      })
    : [];

  const totalChapters = activeLevel
    ? activeLevel.matieres.reduce((acc, sub) => acc + sub.chapitres.length, 0)
    : 0;

  return (
    <div className="min-h-screen bg-slate-950 text-white selection:bg-emerald-500 selection:text-slate-950">
      {/* Modal d'inscription requise */}
      <AuthRequiredModal
        isOpen={authModalOpen}
        onClose={() => setAuthModalOpen(false)}
        title={modalCourseTitle}
        levelId={modalLevelId}
        category="education"
      />

      {/* Header Sticky */}
      <header className="sticky top-0 z-50 border-b border-slate-800/80 bg-slate-950/90 backdrop-blur-md">
        <div className="mx-auto flex h-18 max-w-7xl items-center justify-between px-5 lg:px-8">
          <Link to="/" className="flex items-center gap-3">
            <MandalLogo />
          </Link>
          <nav className="hidden items-center gap-6 md:flex">
            <Link
              to="/"
              className="inline-flex items-center gap-1.5 text-sm font-semibold text-slate-300 hover:text-emerald-400 transition-colors"
            >
              <span>🏠</span> Accueil
            </Link>
            <Link
              to="/education"
              className="inline-flex items-center gap-1.5 text-sm font-bold text-emerald-400"
            >
              <span>📚</span> Éducation
            </Link>
            <Link
              to="/mandal-sup"
              className="inline-flex items-center gap-1.5 text-sm font-semibold text-slate-300 hover:text-sky-400 transition-colors"
            >
              <span>🎓</span> M'Andal'Sup
            </Link>
            <Link
              to="/citoyennete"
              className="inline-flex items-center gap-1.5 text-sm font-semibold text-slate-300 hover:text-blue-400 transition-colors"
            >
              <span>⚖️</span> Citoyenneté
            </Link>
            <Link
              to="/culture"
              className="inline-flex items-center gap-1.5 text-sm font-semibold text-slate-300 hover:text-amber-400 transition-colors"
            >
              <span>🌍</span> Culture
            </Link>
          </nav>
          <div className="flex items-center gap-3">
            {userSession ? (
              <Button
                asChild
                className="rounded-full bg-emerald-600 font-semibold text-white hover:bg-emerald-500 shadow-lg shadow-emerald-950"
              >
                <Link to="/etudiant">Mon Tableau de bord</Link>
              </Button>
            ) : (
              <>
                <Button asChild variant="ghost" className="text-slate-200 hover:bg-slate-800">
                  <Link to="/auth">Connexion</Link>
                </Button>
                <Button
                  asChild
                  className="rounded-full bg-emerald-600 font-semibold text-white hover:bg-emerald-500 shadow-lg shadow-emerald-950"
                >
                  <Link to="/inscription">Inscription</Link>
                </Button>
              </>
            )}
          </div>
        </div>
      </header>

      <main className="py-8 sm:py-12 lg:py-16">
        <div className="mx-auto max-w-7xl px-5 lg:px-8">
          {/* ========================================================= */}
          {/* CAS 1 : UNE OPTION / NIVEAU EST SÉLECTIONNÉ DANS L'URL   */}
          {/* PAGE DÉDIÉE DU NIVEAU AVEC TOUS LES COURS DU NIVEAU       */}
          {/* ========================================================= */}
          {activeLevel ? (
            <div className="space-y-8 animate-in fade-in slide-in-from-bottom-3 duration-300">
              {/* Fil d'ariane & Bouton Retour */}
              <div className="flex flex-wrap items-center justify-between gap-4">
                <button
                  type="button"
                  onClick={handleBackToLevels}
                  className="inline-flex items-center gap-2 rounded-full border border-slate-700 bg-slate-900/80 px-4 py-2 text-xs font-bold text-slate-200 transition hover:border-emerald-500 hover:bg-slate-800 hover:text-emerald-400 cursor-pointer shadow-sm"
                >
                  <ArrowLeft className="size-4" /> ← Choisir un autre niveau ou concours
                </button>

                <div className="flex items-center gap-2 text-xs font-medium text-slate-400">
                  <Link to="/" className="hover:text-white">
                    Accueil
                  </Link>
                  <span>/</span>
                  <Link to="/education" search={{ niveau: undefined }} className="hover:text-white">
                    Éducation
                  </Link>
                  <span>/</span>
                  <span className="font-bold text-emerald-400">{activeLevel.nom}</span>
                </div>
              </div>

              {/* Bannière Header du Niveau Dédié */}
              <div
                className={cn(
                  "relative overflow-hidden rounded-3xl border p-8 sm:p-12 shadow-2xl",
                  activeLevel.type === "concours"
                    ? "border-amber-500/30 bg-gradient-to-br from-amber-950/60 via-slate-900 to-slate-950 shadow-amber-950/40"
                    : "border-emerald-500/30 bg-gradient-to-br from-emerald-950/70 via-slate-900 to-slate-950 shadow-emerald-950/40",
                )}
              >
                <div className="flex flex-wrap items-center gap-2.5">
                  <span
                    className={cn(
                      "rounded-full px-3.5 py-1 text-xs font-black uppercase tracking-wider",
                      activeLevel.type === "concours"
                        ? "bg-amber-500/20 text-amber-300 border border-amber-500/40"
                        : "bg-emerald-500/20 text-emerald-300 border border-emerald-500/40",
                    )}
                  >
                    {activeLevel.type === "concours"
                      ? "🏆 Concours d'Entrée"
                      : activeLevel.type === "technique"
                        ? "🛠️ Enseignement technique"
                        : "🎓 Enseignement général"}
                  </span>
                  {activeLevel.badge && (
                    <span className="rounded-full bg-slate-800 border border-slate-700 px-3 py-1 text-xs font-medium text-slate-300">
                      {activeLevel.badge}
                    </span>
                  )}
                </div>

                <h1 className="mt-4 font-display text-3xl font-black text-white sm:text-4xl lg:text-5xl tracking-tight">
                  {activeLevel.nom}
                </h1>
                <p className="mt-3 text-lg font-medium text-emerald-300 sm:text-xl">
                  {activeLevel.sousTitre}
                </p>
                {activeLevel.specialites ? (
                  <p className="mt-3 max-w-3xl text-sm text-slate-300">
                    <span className="font-semibold text-white">Spécialités : </span>
                    {activeLevel.specialites.join(" · ")}
                  </p>
                ) : null}
                <p className="mt-3 max-w-3xl text-sm text-slate-300 leading-relaxed">
                  Accédez à tous les programmes officiels, chapitres pas à pas, fiches mémo de
                  formules, quiz d'auto-évaluation et exercices corrigés enregistrés pour ce niveau.
                </p>

                {/* Statistiques Rapides */}
                <div className="mt-8 flex flex-wrap items-center gap-4 sm:gap-6 border-t border-slate-800/80 pt-6">
                  <div className="flex items-center gap-2 rounded-xl bg-slate-900/80 px-4 py-2 border border-slate-800">
                    <BookOpen className="size-4 text-emerald-400" />
                    <span className="text-xs font-bold text-white">
                      {activeLevel.matieres.length} Matières complètes
                    </span>
                  </div>
                  <div className="flex items-center gap-2 rounded-xl bg-slate-900/80 px-4 py-2 border border-slate-800">
                    <CheckCircle2 className="size-4 text-blue-400" />
                    <span className="text-xs font-bold text-white">
                      {totalChapters} Chapitres détaillés
                    </span>
                  </div>
                  <div className="flex items-center gap-2 rounded-xl bg-slate-900/80 px-4 py-2 border border-slate-800">
                    <Sparkles className="size-4 text-amber-400" />
                    <span className="text-xs font-bold text-white">
                      Quiz &amp; Simulations GeoGebra
                    </span>
                  </div>
                </div>
              </div>

              {/* BANNIÈRE D'AVERTISSEMENT : INSCRIPTION OBLIGATOIRE POUR ACCÉDER AUX COURS */}
              <div className="rounded-2xl border border-amber-500/40 bg-gradient-to-r from-amber-950/40 via-slate-900 to-amber-950/30 p-5 sm:p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 shadow-lg">
                <div className="flex items-start sm:items-center gap-3.5">
                  <div className="flex size-11 shrink-0 items-center justify-center rounded-xl bg-amber-500/20 text-amber-400 border border-amber-500/40">
                    <Lock className="size-5" />
                  </div>
                  <div>
                    <h3 className="font-display text-sm sm:text-base font-bold text-white">
                      Inscription obligatoire pour débloquer l'intégralité des cours
                    </h3>
                    <p className="text-xs text-slate-300 mt-0.5">
                      Consultez la liste des matières et chapitres ci-dessous. Pour ouvrir une
                      leçon, lancer un quiz ou télécharger les fiches, créez votre compte gratuit.
                    </p>
                  </div>
                </div>

                <div className="flex shrink-0 items-center gap-2.5">
                  {userSession ? (
                    <Button
                      asChild
                      className="rounded-xl bg-emerald-600 font-bold text-white hover:bg-emerald-500"
                    >
                      <Link to="/etudiant/cours">Ouvrir dans mon espace</Link>
                    </Button>
                  ) : (
                    <Button
                      asChild
                      className="rounded-xl bg-gradient-to-r from-emerald-600 to-teal-600 font-bold text-white hover:from-emerald-500 hover:to-teal-500 shadow-md shadow-emerald-950 cursor-pointer"
                    >
                      <Link to="/inscription" search={{ level: activeLevel.niveauInscription }}>
                        Créer mon compte (Gratuit)
                      </Link>
                    </Button>
                  )}
                </div>
              </div>

              {/* Barre de recherche dans les cours */}
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-slate-800 pb-4">
                <div>
                  <h2 className="font-display text-2xl font-bold text-white flex items-center gap-2">
                    <BookOpen className="size-6 text-emerald-400" />
                    Tous les cours &amp; Matières de {activeLevel.nom}
                  </h2>
                  <p className="text-xs text-slate-400 mt-1">
                    Cliquez sur un chapitre pour ouvrir la leçon (nécessite un compte).
                  </p>
                </div>

                <div className="relative w-full sm:w-72">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-slate-400" />
                  <Input
                    placeholder="Filtrer par chapitre ou matière..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="pl-9 bg-slate-900 border-slate-700 text-xs rounded-xl focus:border-emerald-500"
                  />
                </div>
              </div>

              {/* LISTE DES MATIÈRES & CHAPITRES DU NIVEAU */}
              <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
                {filteredSubjects.map((sub, idx) => (
                  <div
                    key={idx}
                    className="flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-900/90 p-6 sm:p-8 shadow-xl transition-all duration-200 hover:border-emerald-500/50 hover:bg-slate-900"
                  >
                    <div>
                      <div className="flex items-start justify-between gap-3">
                        <div className="flex items-center gap-2.5">
                          <span className="text-2xl">{sub.icon || "📚"}</span>
                          <h3 className="font-display text-lg font-bold text-white">
                            {sub.matiere}
                          </h3>
                        </div>
                        <span className="shrink-0 rounded-full bg-emerald-500/10 border border-emerald-500/30 px-2.5 py-1 text-[11px] font-bold text-emerald-300">
                          {sub.chapitres.length
                            ? `${sub.chapitres.length} chapitres`
                            : "Chapitres à venir"}
                        </span>
                      </div>

                      {sub.description ? (
                        <p className="mt-3 text-xs leading-relaxed text-slate-300">
                          {sub.description}
                        </p>
                      ) : null}

                      {sub.chapitres.length === 0 ? (
                        <p className="mt-6 rounded-xl border border-dashed border-slate-700 px-4 py-3 text-xs text-slate-400">
                          Le programme détaillé de cette matière est en cours de rédaction. Ouvre le
                          cours depuis ton espace pour suivre les leçons déjà publiées.
                        </p>
                      ) : null}

                      {/* Liste exhaustive des chapitres */}
                      <div className={cn("mt-6 space-y-2", sub.chapitres.length === 0 && "hidden")}>
                        <div className="flex items-center justify-between text-[11px] font-bold uppercase tracking-wider text-slate-400">
                          <span>Programme détaillé par chapitre :</span>
                          <span className="text-emerald-400 font-semibold">
                            Cliquer pour ouvrir
                          </span>
                        </div>

                        <div className="space-y-1.5 max-h-[360px] overflow-y-auto pr-1">
                          {sub.chapitres.map((chap, cIdx) => (
                            <button
                              key={cIdx}
                              type="button"
                              onClick={() =>
                                handleOpenCourse(
                                  `${sub.matiere} — ${chap}`,
                                  activeLevel.niveauInscription,
                                )
                              }
                              className="w-full flex items-center justify-between gap-2.5 rounded-xl border border-slate-800/80 bg-slate-950/70 px-3.5 py-2.5 text-left text-xs text-slate-300 transition hover:border-emerald-500/50 hover:bg-slate-950 hover:text-white cursor-pointer group"
                            >
                              <div className="flex items-center gap-2.5 min-w-0">
                                <span className="flex size-5 shrink-0 items-center justify-center rounded-full bg-emerald-500/15 text-[10px] font-bold text-emerald-300 group-hover:bg-emerald-500 group-hover:text-slate-950 transition-colors">
                                  {cIdx + 1}
                                </span>
                                <span className="truncate">{chap}</span>
                              </div>
                              <span className="shrink-0 flex items-center gap-1 text-[11px] font-semibold text-emerald-400 opacity-80 group-hover:opacity-100">
                                <Lock className="size-3 text-amber-400" /> Ouvrir
                              </span>
                            </button>
                          ))}
                        </div>
                      </div>
                    </div>

                    {/* Bouton d'action du bas de la carte */}
                    <div className="mt-6 pt-5 border-t border-slate-800 flex flex-wrap items-center justify-between gap-3">
                      <div className="flex items-center gap-2 text-[11px] text-slate-400">
                        <Sparkles className="size-3.5 text-amber-400" />
                        <span>Fiches mémo · Quiz chronométrés</span>
                      </div>
                      <Button
                        onClick={() =>
                          handleOpenCourse(
                            `Programme complet ${sub.matiere}`,
                            activeLevel.niveauInscription,
                          )
                        }
                        className="bg-emerald-600 font-bold text-white hover:bg-emerald-500 shadow-md cursor-pointer"
                        size="sm"
                      >
                        {userSession ? "Accéder à la matière" : "Ouvrir ce cours"}
                        <ArrowRight className="ml-1.5 size-3.5" />
                      </Button>
                    </div>
                  </div>
                ))}
              </div>

              {/* OUTILS PÉDAGOGIQUES ASSOCIÉS À CE NIVEAU */}
              <div className="mt-12 rounded-3xl border border-slate-800 bg-slate-900/90 p-8 sm:p-10 shadow-2xl">
                <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-emerald-400">
                  <Binary className="size-4" /> Outils Pédagogiques inclus
                </div>
                <h3 className="mt-2 font-display text-xl sm:text-2xl font-bold text-white">
                  Tout le matériel d'apprentissage pour réussir {activeLevel.nom}
                </h3>

                <div className="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
                  <div
                    onClick={() =>
                      handleOpenCourse(
                        `Fiches de synthèse Maths & Physique (${activeLevel.nom})`,
                        activeLevel.niveauInscription,
                      )
                    }
                    className="p-5 rounded-2xl border border-slate-800 bg-slate-950 hover:border-emerald-500/50 cursor-pointer transition"
                  >
                    <BookOpen className="size-6 text-emerald-400" />
                    <h4 className="mt-3 font-bold text-sm text-white">Fiches de Synthèse</h4>
                    <p className="mt-1 text-xs text-slate-400">
                      Résumés de cours et formulaires téléchargeables.
                    </p>
                  </div>

                  <div
                    onClick={() =>
                      handleOpenCourse(
                        `Quiz & Épreuves interactives (${activeLevel.nom})`,
                        activeLevel.niveauInscription,
                      )
                    }
                    className="p-5 rounded-2xl border border-slate-800 bg-slate-950 hover:border-blue-500/50 cursor-pointer transition"
                  >
                    <Sparkles className="size-6 text-blue-400" />
                    <h4 className="mt-3 font-bold text-sm text-white">
                      Quiz &amp; Auto-évaluation
                    </h4>
                    <p className="mt-1 text-xs text-slate-400">
                      Tests interactifs corrigés avec scores.
                    </p>
                  </div>

                  <div
                    onClick={() =>
                      handleOpenCourse(
                        `Annales et Corrigés officiels (${activeLevel.nom})`,
                        activeLevel.niveauInscription,
                      )
                    }
                    className="p-5 rounded-2xl border border-slate-800 bg-slate-950 hover:border-amber-500/50 cursor-pointer transition"
                  >
                    <Award className="size-6 text-amber-400" />
                    <h4 className="mt-3 font-bold text-sm text-white">Annales Corrigées</h4>
                    <p className="mt-1 text-xs text-slate-400">
                      Épreuves des sessions antérieures décortiquées.
                    </p>
                  </div>

                  <div
                    onClick={() =>
                      handleOpenCourse(
                        `Laboratoire GeoGebra & Simulations (${activeLevel.nom})`,
                        activeLevel.niveauInscription,
                      )
                    }
                    className="p-5 rounded-2xl border border-slate-800 bg-slate-950 hover:border-teal-500/50 cursor-pointer transition"
                  >
                    <Cpu className="size-6 text-teal-400" />
                    <h4 className="mt-3 font-bold text-sm text-white">Simulations Virtuelles</h4>
                    <p className="mt-1 text-xs text-slate-400">
                      GeoGebra et manipulations 2D/3D en ligne.
                    </p>
                  </div>
                </div>
              </div>

              {/* BANNIÈRE D'APPEL À L'ACTION FINALE */}
              <div className="rounded-3xl border border-emerald-500/30 bg-gradient-to-r from-emerald-950/80 via-slate-900 to-slate-950 p-8 sm:p-12 text-center shadow-2xl">
                <h3 className="font-display text-2xl sm:text-3xl font-bold text-white">
                  Prêt à commencer vos cours de {activeLevel.nom} ?
                </h3>
                <p className="mt-2 max-w-2xl mx-auto text-sm text-slate-300">
                  Rejoignez la communauté M'ANDAL gratuitement et accédez à tous vos cours,
                  exercices et simulations dès aujourd'hui.
                </p>
                <div className="mt-6 flex flex-wrap justify-center items-center gap-3">
                  <Button
                    asChild
                    size="lg"
                    className="rounded-full bg-emerald-600 px-8 font-bold text-white hover:bg-emerald-500 shadow-xl shadow-emerald-950"
                  >
                    <Link to="/inscription" search={{ level: activeLevel.niveauInscription }}>
                      Créer mon compte gratuit
                    </Link>
                  </Button>
                  <Button
                    type="button"
                    variant="outline"
                    onClick={handleBackToLevels}
                    className="rounded-full border-slate-700 bg-slate-900/80 text-slate-300 hover:bg-slate-800"
                  >
                    ← Choisir un autre niveau
                  </Button>
                </div>
              </div>
            </div>
          ) : (
            /* ========================================================= */
            /* CAS 2 : ACCUEIL ÉDUCATION (LISTE DES NIVEAUX & CONCOURS)  */
            /* ========================================================= */
            <div className="space-y-12">
              <Link
                to="/"
                className="inline-flex items-center gap-2 text-xs font-semibold text-slate-400 transition hover:text-emerald-400"
              >
                <ArrowLeft className="size-4" /> Retour à l'accueil
              </Link>

              {/* Page Banner Header */}
              <div className="rounded-3xl border border-emerald-500/30 bg-gradient-to-br from-emerald-950/70 via-slate-900 to-slate-950 p-8 sm:p-12 shadow-2xl">
                <div className="inline-flex items-center gap-2 rounded-full border border-emerald-500/40 bg-emerald-500/15 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-emerald-300">
                  <GraduationCap className="size-4" /> Volet 01 · Éducation
                </div>
                <h1 className="mt-4 font-display text-3xl font-black text-white sm:text-5xl lg:text-6xl tracking-tight">
                  Éducation : Niveaux scolaires &amp; Concours
                </h1>
                <p className="mt-3 text-xl font-medium text-emerald-300 sm:text-2xl">
                  Le parcours de l'élève, du BEPC aux grands concours d'entrée
                </p>
                <p className="mt-4 max-w-3xl text-sm text-slate-300 sm:text-base leading-relaxed">
                  Maîtrise des fondamentaux académiques (Maths, Physique, SVT, etc.) et préparation
                  méthodique aux grands examens et concours nationaux.
                </p>
              </div>

              {/* NAVIGATION ENTRE LES RUBRIQUES */}
              <nav className="flex flex-wrap gap-2" aria-label="Rubriques de l'éducation">
                {[
                  ["#general", "A. Enseignement général"],
                  ["#technique", "B. Enseignement technique"],
                  ["#sujets", "Anciens sujets d'examens"],
                  ["#concours", "Concours des grandes écoles"],
                ].map(([href, libelle]) => (
                  <a
                    key={href}
                    href={href}
                    className="rounded-full border border-slate-700 bg-slate-900 px-4 py-2 text-xs font-bold text-slate-200 transition hover:border-emerald-500 hover:text-emerald-300"
                  >
                    {libelle}
                  </a>
                ))}
                <Link
                  to="/mandal-sup"
                  className="rounded-full border border-sky-500/50 bg-sky-500/10 px-4 py-2 text-xs font-bold text-sky-300 transition hover:bg-sky-500/20"
                >
                  🎓 M'Andal'Sup : universités et grandes écoles
                </Link>
              </nav>

              {/* A. ENSEIGNEMENT GÉNÉRAL */}
              <section id="general" className="scroll-mt-24 space-y-8">
                <EnTeteRubrique
                  surtitre="A. Enseignement général"
                  titre="Choisis ta classe pour voir ses matières"
                />
                {ENSEIGNEMENT_GENERAL.map((section) => (
                  <GrilleParcours
                    key={section.titre}
                    section={section}
                    onOuvrir={handleSelectLevel}
                  />
                ))}
              </section>

              {/* B. ENSEIGNEMENT TECHNIQUE */}
              <section id="technique" className="scroll-mt-24 space-y-8">
                <EnTeteRubrique
                  surtitre="B. Enseignement technique"
                  titre="Choisis ta filière pour voir ses spécialités et ses matières"
                />
                <h3 className="font-display text-xl font-bold text-white">
                  B1 — Enseignement technique industriel
                </h3>
                {TECHNIQUE_INDUSTRIEL.map((section) => (
                  <GrilleParcours
                    key={`ind-${section.titre}`}
                    section={section}
                    onOuvrir={handleSelectLevel}
                  />
                ))}
                <h3 className="font-display text-xl font-bold text-white">
                  B2 — Enseignement technique commercial
                </h3>
                {TECHNIQUE_COMMERCIAL.map((section) => (
                  <GrilleParcours
                    key={`com-${section.titre}`}
                    section={section}
                    onOuvrir={handleSelectLevel}
                  />
                ))}
              </section>

              {/* ANCIENS SUJETS D'EXAMENS NATIONAUX */}
              <section id="sujets" className="scroll-mt-24 space-y-6">
                <EnTeteRubrique
                  surtitre={`Anciens sujets d'examens nationaux (${ANNEES_SUJETS[ANNEES_SUJETS.length - 1]} à ${ANNEES_SUJETS[0]})`}
                  titre="Clique sur une année pour ouvrir les épreuves dans la banque"
                />
                <div className="grid gap-6 lg:grid-cols-2">
                  <BlocExamens titre="Enseignement général" examens={EXAMENS_GENERAL} />
                  <BlocExamens titre="Enseignement technique" examens={EXAMENS_TECHNIQUE} />
                </div>
              </section>

              {/* CONCOURS DES GRANDES ÉCOLES */}
              <section id="concours" className="scroll-mt-24 space-y-6">
                <EnTeteRubrique
                  surtitre="Anciennes épreuves des concours des grandes écoles"
                  titre="Polytechniques, médecine, grandes écoles et IUT"
                />
                <div className="grid gap-4 md:grid-cols-2">
                  {CONCOURS.map((c) => (
                    <CarteConcours key={c.sigle} concours={c} onPreparer={handleSelectLevel} />
                  ))}
                </div>
              </section>

              {/* OUTILS PÉDAGOGIQUES & CONTENUS DE COURS (MATHS & PHYSIQUE) */}
              <div className="mt-16 rounded-3xl border border-slate-800 bg-slate-900/90 p-8 sm:p-12 shadow-2xl">
                <div className="max-w-2xl">
                  <div className="inline-flex items-center gap-2 rounded-lg bg-emerald-500/10 px-3 py-1 text-xs font-bold uppercase tracking-wider text-emerald-400">
                    <Binary className="size-4" /> Pédagogie d'Excellence
                  </div>
                  <h2 className="mt-3 font-display text-2xl sm:text-3xl font-bold text-white">
                    Outils pédagogiques &amp; Contenus de cours (Maths &amp; Physique)
                  </h2>
                  <p className="mt-2 text-sm text-slate-300">
                    Un environnement complet conçu pour rendre l'apprentissage clair, rigoureux et
                    stimulant.
                  </p>
                </div>

                <div className="mt-8 grid grid-cols-1 gap-5 md:grid-cols-2 lg:grid-cols-3">
                  <div
                    onClick={() => handleSelectLevel("probatoire")}
                    className="group cursor-pointer rounded-2xl border border-slate-800 bg-slate-950 p-6 shadow-sm transition hover:border-emerald-500/50 hover:bg-slate-900/60"
                  >
                    <div className="flex size-10 items-center justify-center rounded-xl bg-emerald-500/20 text-emerald-400 group-hover:scale-110 transition-transform">
                      <BookOpen className="size-5" />
                    </div>
                    <h3 className="mt-4 font-display text-base font-bold text-white group-hover:text-emerald-300">
                      Cours de Mathématiques &amp; Physique
                    </h3>
                    <p className="mt-2 text-xs leading-relaxed text-slate-300">
                      Syllabus complet, fiches de synthèse, formules clés et démonstrations pas à
                      pas.
                    </p>
                    <span className="mt-4 inline-flex items-center gap-1 text-[11px] font-semibold text-emerald-400">
                      Consulter les fiches <ArrowRight className="size-3" />
                    </span>
                  </div>

                  <div
                    onClick={() => handleSelectLevel("probatoire")}
                    className="group cursor-pointer rounded-2xl border border-slate-800 bg-slate-950 p-6 shadow-sm transition hover:border-blue-500/50 hover:bg-slate-900/60"
                  >
                    <div className="flex size-10 items-center justify-center rounded-xl bg-blue-500/20 text-blue-400 group-hover:scale-110 transition-transform">
                      <Sparkles className="size-5" />
                    </div>
                    <h3 className="mt-4 font-display text-base font-bold text-white group-hover:text-blue-300">
                      Épreuves &amp; Quiz interactifs
                    </h3>
                    <p className="mt-2 text-xs leading-relaxed text-slate-300">
                      Entraînements chronométrés et tests d'auto-évaluation par chapitre avec barème
                      officiel.
                    </p>
                    <span className="mt-4 inline-flex items-center gap-1 text-[11px] font-semibold text-blue-400">
                      Lancer un entraînement <ArrowRight className="size-3" />
                    </span>
                  </div>

                  <div
                    onClick={() => handleSelectLevel("bac")}
                    className="group cursor-pointer rounded-2xl border border-slate-800 bg-slate-950 p-6 shadow-sm transition hover:border-teal-500/50 hover:bg-slate-900/60"
                  >
                    <div className="flex size-10 items-center justify-center rounded-xl bg-teal-500/20 text-teal-400 group-hover:scale-110 transition-transform">
                      <CheckCircle2 className="size-5" />
                    </div>
                    <h3 className="mt-4 font-display text-base font-bold text-white group-hover:text-teal-300">
                      Correction d'épreuves pas à pas
                    </h3>
                    <p className="mt-2 text-xs leading-relaxed text-slate-300">
                      Corrigés détaillés, pièges fréquents et barèmes officiels des sessions
                      antérieures.
                    </p>
                    <span className="mt-4 inline-flex items-center gap-1 text-[11px] font-semibold text-teal-400">
                      Voir les annales corrigées <ArrowRight className="size-3" />
                    </span>
                  </div>

                  <div
                    onClick={() => handleSelectLevel("bac")}
                    className="group cursor-pointer rounded-2xl border border-slate-800 bg-slate-950 p-6 shadow-sm transition hover:border-amber-500/50 hover:bg-slate-900/60"
                  >
                    <div className="flex size-10 items-center justify-center rounded-xl bg-amber-500/20 text-amber-400 group-hover:scale-110 transition-transform">
                      <Award className="size-5" />
                    </div>
                    <h3 className="mt-4 font-display text-base font-bold text-white group-hover:text-amber-300">
                      Épreuves de bourse d'excellence
                    </h3>
                    <p className="mt-2 text-xs leading-relaxed text-slate-300">
                      Sujets de sélection pour les programmes de financement, parrainage et bourses
                      d'études.
                    </p>
                    <span className="mt-4 inline-flex items-center gap-1 text-[11px] font-semibold text-amber-400">
                      Accéder aux sujets de bourse <ArrowRight className="size-3" />
                    </span>
                  </div>

                  <div
                    onClick={() => handleSelectLevel("probatoire")}
                    className="group cursor-pointer rounded-2xl border border-slate-800 bg-slate-950 p-6 shadow-sm md:col-span-2 lg:col-span-2 transition hover:border-emerald-500/50 hover:bg-slate-900/60"
                  >
                    <div className="flex size-10 items-center justify-center rounded-xl bg-emerald-500/20 text-emerald-400 group-hover:scale-110 transition-transform">
                      <Cpu className="size-5" />
                    </div>
                    <h3 className="mt-4 font-display text-base font-bold text-white group-hover:text-emerald-300">
                      Simulation virtuelle &amp; GeoGebra
                    </h3>
                    <p className="mt-2 text-xs leading-relaxed text-slate-300">
                      Visualisations graphiques interactives de fonctions mathématiques, simulations
                      d'expériences de physique et manipulation directe de figures en 2D/3D.
                    </p>
                    <span className="mt-4 inline-flex items-center gap-1 text-[11px] font-semibold text-emerald-400">
                      Ouvrir le laboratoire virtuel <ArrowRight className="size-3" />
                    </span>
                  </div>
                </div>
              </div>

              {/* PRÉSENTATION DES CONCOURS D'ENTRÉE (ENSPD & IUT) */}
              <div className="mt-16 rounded-3xl border border-slate-800 bg-slate-900/90 p-8 sm:p-12 shadow-2xl">
                <div className="max-w-2xl">
                  <div className="inline-flex items-center gap-2 rounded-lg bg-amber-500/10 px-3 py-1 text-xs font-bold uppercase tracking-wider text-amber-400">
                    <Award className="size-4" /> Grandes Écoles
                  </div>
                  <h2 className="mt-3 font-display text-2xl sm:text-3xl font-bold text-white">
                    CONCOURS D'ENTRÉE
                  </h2>
                  <p className="mt-2 text-sm text-slate-300">
                    Préparation aux grandes écoles d'ingénieurs et technologiques du Cameroun.
                  </p>
                </div>

                <div className="mt-8 grid grid-cols-1 gap-8 md:grid-cols-2">
                  {/* ENSPD */}
                  <div className="rounded-2xl border border-slate-800 bg-slate-950 p-6 sm:p-8 flex flex-col justify-between">
                    <div>
                      <div className="flex items-center justify-between">
                        <h3 className="font-display text-xl font-bold text-white">ENSPD</h3>
                        <span className="rounded-full bg-emerald-500/20 px-3 py-1 text-xs font-bold text-emerald-300">
                          Polytechnique Douala
                        </span>
                      </div>
                      <ul className="mt-6 space-y-3.5 text-sm text-slate-300">
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-emerald-400 shrink-0 mt-0.5" />
                          <span>
                            <strong>Présentation de l'école</strong> &amp; débouchés d'ingénierie
                          </span>
                        </li>
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-emerald-400 shrink-0 mt-0.5" />
                          <span>
                            <strong>Concours d'entrée</strong> (après Bac, Probatoire, BEPC/CAP,
                            autre)
                          </span>
                        </li>
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-emerald-400 shrink-0 mt-0.5" />
                          <span>
                            <strong>Cours de renforcement</strong> (Maths, Physique-Chimie)
                          </span>
                        </li>
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-emerald-400 shrink-0 mt-0.5" />
                          <span>
                            <strong>Correction d'épreuves</strong> et annales corrigées
                          </span>
                        </li>
                      </ul>
                    </div>

                    <div className="mt-8 pt-4 border-t border-slate-800">
                      <Button
                        type="button"
                        onClick={() => handleSelectLevel("enspd")}
                        className="w-full bg-emerald-600 font-bold text-white hover:bg-emerald-500 cursor-pointer"
                      >
                        Ouvrir la page Prépa ENSPD →
                      </Button>
                    </div>
                  </div>

                  {/* IUT */}
                  <div className="rounded-2xl border border-slate-800 bg-slate-950 p-6 sm:p-8 flex flex-col justify-between">
                    <div>
                      <div className="flex items-center justify-between">
                        <h3 className="font-display text-xl font-bold text-white">IUT</h3>
                        <span className="rounded-full bg-blue-500/20 px-3 py-1 text-xs font-bold text-blue-300">
                          Filières Technologiques
                        </span>
                      </div>
                      <ul className="mt-6 space-y-3.5 text-sm text-slate-300">
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                          <span>
                            <strong>Présentation de l'IUT</strong> et des filières d'avenir
                          </span>
                        </li>
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                          <span>
                            <strong>Filière technologique</strong> &amp; industrielle
                          </span>
                        </li>
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                          <span>
                            <strong>Physique appliquée</strong> &amp; sciences de l'ingénieur
                          </span>
                        </li>
                        <li className="flex items-start gap-3">
                          <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                          <span>
                            <strong>Spécialités</strong>, métiers et passerelles
                          </span>
                        </li>
                      </ul>
                    </div>

                    <div className="mt-8 pt-4 border-t border-slate-800">
                      <Button
                        type="button"
                        onClick={() => handleSelectLevel("iut")}
                        className="w-full bg-blue-600 font-bold text-white hover:bg-blue-500 cursor-pointer"
                      >
                        Ouvrir la page Prépa IUT →
                      </Button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

function EnTeteRubrique({ surtitre, titre }: { surtitre: string; titre: string }) {
  return (
    <div className="border-b border-slate-800 pb-4">
      <span className="text-xs font-bold uppercase tracking-wider text-emerald-400">
        {surtitre}
      </span>
      <h2 className="mt-1 font-display text-2xl font-bold text-white sm:text-3xl">{titre}</h2>
    </div>
  );
}

function GrilleParcours({
  section,
  onOuvrir,
}: {
  section: Section;
  onOuvrir: (id: string) => void;
}) {
  return (
    <div>
      <p className="mb-3 text-sm font-bold text-slate-200">
        {section.titre}
        {section.sousTitre ? (
          <span className="font-normal text-slate-400"> — {section.sousTitre}</span>
        ) : null}
      </p>
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {section.parcours.map((p) => {
          const chapitres = p.matieres.reduce((n, m) => n + m.chapitres.length, 0);
          return (
            <button
              key={p.id}
              type="button"
              onClick={() => onOuvrir(p.id)}
              className="group flex flex-col justify-between rounded-3xl border border-slate-800 bg-gradient-to-b from-slate-900 to-slate-950 p-5 text-left shadow-lg transition-all duration-300 hover:-translate-y-1 hover:border-emerald-400"
            >
              <div>
                <h3 className="font-display text-lg font-bold text-white transition-colors group-hover:text-emerald-300">
                  {p.nom}
                </h3>
                <p className="mt-1 text-xs text-slate-400">{p.sousTitre}</p>
                {p.specialites ? (
                  <p className="mt-2 line-clamp-2 text-[11px] text-slate-500">
                    {p.specialites.join(" · ")}
                  </p>
                ) : null}
              </div>
              <div className="mt-4 flex items-center justify-between border-t border-slate-800/80 pt-3 text-xs font-bold text-emerald-400">
                <span>
                  {p.matieres.length} matière{p.matieres.length > 1 ? "s" : ""}
                  {chapitres ? ` · ${chapitres} chapitres` : ""}
                </span>
                <ArrowRight className="size-4" />
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
}

function AnneesSujets({ lien }: { lien: LienSujets }) {
  return (
    <div className="flex flex-wrap gap-1.5">
      {ANNEES_SUJETS.map((annee) => (
        <Link
          key={annee}
          to="/banque-epreuves"
          search={{ type: lien.type, ...(lien.q ? { q: lien.q } : {}), annee }}
          className="rounded-lg border border-slate-700 bg-slate-950 px-2.5 py-1 text-xs font-semibold text-slate-200 transition hover:border-emerald-500 hover:text-emerald-300"
        >
          {annee}
        </Link>
      ))}
    </div>
  );
}

function BlocExamens({
  titre,
  examens,
}: {
  titre: string;
  examens: { examen: string; liens: LienSujets[] }[];
}) {
  return (
    <div className="space-y-5 rounded-3xl border border-slate-800 bg-slate-900/90 p-6">
      <h3 className="font-display text-lg font-bold text-white">{titre}</h3>
      {examens.map((e) => (
        <div key={e.examen} className="space-y-3">
          <p className="text-sm font-bold uppercase tracking-wide text-amber-300">{e.examen}</p>
          {e.liens.map((lien) => (
            <div key={lien.libelle} className="space-y-1.5">
              {e.liens.length > 1 ? (
                <p className="text-xs font-semibold text-slate-300">{lien.libelle}</p>
              ) : null}
              <AnneesSujets lien={lien} />
            </div>
          ))}
        </div>
      ))}
    </div>
  );
}

function CarteConcours({
  concours,
  onPreparer,
}: {
  concours: Concours;
  onPreparer: (id: string) => void;
}) {
  return (
    <div className="space-y-4 rounded-3xl border border-amber-500/30 bg-gradient-to-b from-slate-900 to-amber-950/20 p-6">
      <div>
        <span className="rounded-full border border-amber-500/40 bg-amber-500/15 px-2.5 py-0.5 text-[11px] font-bold uppercase text-amber-300">
          {concours.categorie}
        </span>
        <h3 className="mt-3 font-display text-xl font-black text-white">{concours.sigle}</h3>
        <p className="mt-1 text-xs text-slate-300">{concours.nom}</p>
      </div>
      {concours.filieres ? (
        <div className="space-y-2">
          {concours.filieres.map((f) => (
            <details
              key={f.mention}
              className="rounded-xl border border-slate-800 bg-slate-950/70 px-3 py-2"
            >
              <summary className="cursor-pointer text-xs font-bold text-slate-200">
                {f.mention}
              </summary>
              <ul className="mt-2 space-y-1 text-xs text-slate-400">
                {f.liste.map((l) => (
                  <li key={l}>• {l}</li>
                ))}
              </ul>
            </details>
          ))}
        </div>
      ) : null}
      <div className="space-y-1.5">
        <p className="text-xs font-semibold text-slate-400">Anciennes épreuves :</p>
        <AnneesSujets lien={{ libelle: concours.sigle, type: "Concours", q: concours.q }} />
      </div>
      {concours.preparation ? (
        <Button
          type="button"
          size="sm"
          onClick={() => onPreparer(concours.preparation!)}
          className="rounded-xl bg-amber-500 font-bold text-slate-950 hover:bg-amber-400"
        >
          Préparer ce concours <ArrowRight className="ml-1.5 size-3.5" />
        </Button>
      ) : null}
    </div>
  );
}
