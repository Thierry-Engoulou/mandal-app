import { createFileRoute, Link } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import {
  Sparkles,
  History,
  Palette,
  Flame,
  CheckCircle2,
  ArrowLeft,
  ArrowRight,
  BookOpen,
} from "lucide-react";
import { MandalLogo } from "@/components/mandal-logo";
import { Button } from "@/components/ui/button";
import { AuthRequiredModal } from "@/components/auth-required-modal";
import { supabase } from "@/integrations/supabase/client";

export const Route = createFileRoute("/culture")({
  head: () => ({
    meta: [
      { title: "Culture & Patrimoine — M'ANDAL" },
      {
        name: "description",
        content:
          "Valoriser le patrimoine africain plus précisément Camerounais et son histoire millénaire.",
      },
    ],
  }),
  component: CulturePage,
});

function CulturePage() {
  const [userSession, setUserSession] = useState<{ id: string } | null>(null);
  const [authModalOpen, setAuthModalOpen] = useState(false);
  const [modalTitle, setModalTitle] = useState("Histoire du continent");

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      if (data.session?.user) {
        setUserSession({ id: data.session.user.id });
      }
    });
  }, []);

  const handleOpenModule = (title: string) => {
    if (userSession) {
      window.location.href = "/etudiant/cours";
    } else {
      setModalTitle(title);
      setAuthModalOpen(true);
    }
  };

  return (
    <div className="min-h-screen bg-slate-950 text-white">
      <AuthRequiredModal
        isOpen={authModalOpen}
        onClose={() => setAuthModalOpen(false)}
        title={modalTitle}
        category="culture"
      />

      {/* Header */}
      <header className="sticky top-0 z-50 border-b border-slate-800 bg-slate-950/90 backdrop-blur">
        <div className="mx-auto flex h-18 max-w-7xl items-center justify-between px-5 lg:px-8">
          <Link to="/" className="flex items-center gap-3">
            <MandalLogo />
          </Link>
          <nav className="hidden items-center gap-6 md:flex">
            <Link to="/" className="inline-flex items-center gap-1.5 text-sm font-semibold text-slate-300 hover:text-amber-400">
              <span>🏠</span> Accueil
            </Link>
            <Link to="/education" className="inline-flex items-center gap-1.5 text-sm font-semibold text-slate-300 hover:text-emerald-400">
              <span>📚</span> Éducation
            </Link>
            <Link to="/citoyennete" className="inline-flex items-center gap-1.5 text-sm font-semibold text-slate-300 hover:text-blue-400">
              <span>⚖️</span> Citoyenneté
            </Link>
            <Link to="/culture" className="inline-flex items-center gap-1.5 text-sm font-bold text-amber-400">
              <span>🌍</span> Culture
            </Link>
          </nav>
          <div className="flex items-center gap-3">
            {userSession ? (
              <Button asChild className="rounded-full bg-amber-600 font-semibold text-white hover:bg-amber-500">
                <Link to="/etudiant">Mon Tableau de bord</Link>
              </Button>
            ) : (
              <>
                <Button asChild variant="ghost" className="text-slate-200 hover:bg-slate-800">
                  <Link to="/auth">Connexion</Link>
                </Button>
                <Button asChild className="rounded-full bg-amber-600 font-semibold text-white hover:bg-amber-500">
                  <Link to="/inscription">Inscription</Link>
                </Button>
              </>
            )}
          </div>
        </div>
      </header>

      <main className="py-12 lg:py-16">
        <div className="mx-auto max-w-7xl px-5 lg:px-8">
          <Link
            to="/"
            className="inline-flex items-center gap-2 text-xs font-semibold text-slate-400 transition hover:text-amber-400"
          >
            <ArrowLeft className="size-4" /> Retour à l'accueil
          </Link>

          {/* Page Banner */}
          <div className="mt-6 rounded-3xl border border-amber-500/30 bg-gradient-to-br from-amber-950/60 via-slate-900 to-slate-950 p-8 sm:p-12 shadow-2xl">
            <div className="inline-flex items-center gap-2 rounded-full border border-amber-500/40 bg-amber-500/15 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-amber-300">
              <Sparkles className="size-4" /> Volet 03 · Culture
            </div>
            <h1 className="mt-4 font-display text-3xl font-black text-white sm:text-5xl lg:text-6xl">
              Culture
            </h1>
            <p className="mt-3 text-xl font-medium text-amber-300 sm:text-2xl">
              Valoriser le patrimoine africain plus précisément Camerounais et son histoire millénaire
            </p>
            <p className="mt-4 max-w-3xl text-sm text-slate-300 sm:text-base leading-relaxed">
              Valorisation du patrimoine national, ouverture intellectuelle et construction d'une identité africaine positive et ambitieuse.
            </p>
          </div>

          {/* 3 Columns matching Slide 9 */}
          <div className="mt-12 grid grid-cols-1 gap-8 md:grid-cols-3">
            {/* Card 1: Histoire du continent */}
            <div className="flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-900/90 p-8 shadow-xl transition hover:border-amber-500/50 hover:bg-slate-900">
              <div>
                <div className="flex size-12 items-center justify-center rounded-2xl bg-amber-500/20 text-amber-400">
                  <History className="size-6" />
                </div>
                <h2 className="mt-6 font-display text-xl font-bold text-white">Histoire du continent</h2>
                <p className="mt-1 text-xs text-slate-400">La trajectoire de nos civilisations millénaires</p>

                <ul className="mt-6 space-y-4 text-sm text-slate-300">
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

              <div className="mt-8 pt-4 border-t border-slate-800">
                <Button
                  onClick={() => handleOpenModule("Histoire du continent")}
                  className="w-full bg-amber-600 font-bold text-white hover:bg-amber-500 cursor-pointer"
                >
                  Ouvrir ce module <ArrowRight className="ml-2 size-4" />
                </Button>
              </div>
            </div>

            {/* Card 2: Patrimoine culturel */}
            <div className="flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-900/90 p-8 shadow-xl transition hover:border-amber-500/50 hover:bg-slate-900">
              <div>
                <div className="flex size-12 items-center justify-center rounded-2xl bg-emerald-500/20 text-emerald-400">
                  <Palette className="size-6" />
                </div>
                <h2 className="mt-6 font-display text-xl font-bold text-white">Patrimoine culturel</h2>
                <p className="mt-1 text-xs text-slate-400">L'expression vivante des arts et savoirs camerounais</p>

                <ul className="mt-6 space-y-4 text-sm text-slate-300">
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

              <div className="mt-8 pt-4 border-t border-slate-800">
                <Button
                  onClick={() => handleOpenModule("Patrimoine culturel")}
                  className="w-full bg-amber-600 font-bold text-white hover:bg-amber-500 cursor-pointer"
                >
                  Ouvrir ce module <ArrowRight className="ml-2 size-4" />
                </Button>
              </div>
            </div>

            {/* Card 3: Figures et fierté africaine */}
            <div className="flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-900/90 p-8 shadow-xl transition hover:border-amber-500/50 hover:bg-slate-900">
              <div>
                <div className="flex size-12 items-center justify-center rounded-2xl bg-orange-500/20 text-orange-400">
                  <Flame className="size-6" />
                </div>
                <h2 className="mt-6 font-display text-xl font-bold text-white">Figures et fierté africaine</h2>
                <p className="mt-1 text-xs text-slate-400">Inspirer la jeunesse par des modèles d'excellence</p>

                <ul className="mt-6 space-y-4 text-sm text-slate-300">
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

              <div className="mt-8 pt-4 border-t border-slate-800">
                <Button
                  onClick={() => handleOpenModule("Figures et fierté africaine")}
                  className="w-full bg-amber-600 font-bold text-white hover:bg-amber-500 cursor-pointer"
                >
                  Ouvrir ce module <ArrowRight className="ml-2 size-4" />
                </Button>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}

