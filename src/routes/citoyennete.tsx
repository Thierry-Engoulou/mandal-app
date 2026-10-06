import { createFileRoute, Link } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import {
  Scale,
  Landmark,
  ShieldCheck,
  HeartHandshake,
  CheckCircle2,
  ArrowLeft,
  ArrowRight,
  BookOpen,
  Sparkles,
} from "lucide-react";
import { MandalLogo } from "@/components/mandal-logo";
import { Button } from "@/components/ui/button";
import { AuthRequiredModal } from "@/components/auth-required-modal";
import { supabase } from "@/integrations/supabase/client";

export const Route = createFileRoute("/citoyennete")({
  head: () => ({
    meta: [
      { title: "Citoyenneté — M'ANDAL" },
      {
        name: "description",
        content: "Comprendre ses droits, ses devoirs et l'engagement civique sur M'ANDAL.",
      },
    ],
  }),
  component: CitizenshipPage,
});

function CitizenshipPage() {
  const [userSession, setUserSession] = useState<{ id: string } | null>(null);
  const [authModalOpen, setAuthModalOpen] = useState(false);
  const [modalTitle, setModalTitle] = useState("Institutions et droits");

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
        category="citoyennete"
      />

      {/* Header */}
      <header className="sticky top-0 z-50 border-b border-slate-800 bg-slate-950/90 backdrop-blur">
        <div className="mx-auto flex h-18 max-w-7xl items-center justify-between px-5 lg:px-8">
          <Link to="/" className="flex items-center gap-3">
            <MandalLogo />
          </Link>
          <nav className="hidden items-center gap-6 md:flex">
            <Link to="/" className="inline-flex items-center gap-1.5 text-sm font-semibold text-slate-300 hover:text-blue-400">
              <span>🏠</span> Accueil
            </Link>
            <Link to="/education" className="inline-flex items-center gap-1.5 text-sm font-semibold text-slate-300 hover:text-emerald-400">
              <span>📚</span> Éducation
            </Link>
            <Link to="/citoyennete" className="inline-flex items-center gap-1.5 text-sm font-bold text-blue-400">
              <span>⚖️</span> Citoyenneté
            </Link>
            <Link to="/culture" className="inline-flex items-center gap-1.5 text-sm font-semibold text-slate-300 hover:text-amber-400">
              <span>🌍</span> Culture
            </Link>
          </nav>
          <div className="flex items-center gap-3">
            {userSession ? (
              <Button asChild className="rounded-full bg-blue-600 font-semibold text-white hover:bg-blue-500">
                <Link to="/etudiant">Mon Tableau de bord</Link>
              </Button>
            ) : (
              <>
                <Button asChild variant="ghost" className="text-slate-200 hover:bg-slate-800">
                  <Link to="/auth">Connexion</Link>
                </Button>
                <Button asChild className="rounded-full bg-blue-600 font-semibold text-white hover:bg-blue-500">
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
            className="inline-flex items-center gap-2 text-xs font-semibold text-slate-400 transition hover:text-blue-400"
          >
            <ArrowLeft className="size-4" /> Retour à l'accueil
          </Link>

          {/* Page Banner */}
          <div className="mt-6 rounded-3xl border border-blue-500/30 bg-gradient-to-br from-blue-950/60 via-slate-900 to-slate-950 p-8 sm:p-12 shadow-2xl">
            <div className="inline-flex items-center gap-2 rounded-full border border-blue-500/40 bg-blue-500/15 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-blue-300">
              <Scale className="size-4" /> Volet 02 · Citoyenneté
            </div>
            <h1 className="mt-4 font-display text-3xl font-black text-white sm:text-5xl lg:text-6xl">
              Citoyenneté
            </h1>
            <p className="mt-3 text-xl font-medium text-blue-300 sm:text-2xl">
              Comprendre ses droits, ses devoirs et l'engagement civique
            </p>
            <p className="mt-4 max-w-3xl text-sm text-slate-300 sm:text-base leading-relaxed">
              Conscience civique, respect des institutions et des devoirs républicains pour construire une nation forte, tolérante et solidaire.
            </p>
          </div>

          {/* 3 Columns matching Slide 8 */}
          <div className="mt-12 grid grid-cols-1 gap-8 md:grid-cols-3">
            {/* Card 1: Institutions et droits */}
            <div className="flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-900/90 p-8 shadow-xl transition hover:border-blue-500/50 hover:bg-slate-900">
              <div>
                <div className="flex size-12 items-center justify-center rounded-2xl bg-blue-500/20 text-blue-400">
                  <Landmark className="size-6" />
                </div>
                <h2 className="mt-6 font-display text-xl font-bold text-white">Institutions et droits</h2>
                <p className="mt-1 text-xs text-slate-400">Fondements juridiques et protection républicaine</p>

                <ul className="mt-6 space-y-4 text-sm text-slate-300">
                  <li className="flex items-start gap-3">
                    <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                    <span><strong>La Constitution</strong> et les institutions de l'État</span>
                  </li>
                  <li className="flex items-start gap-3">
                    <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                    <span><strong>Droits de l'enfant</strong> et de l'élève en milieu scolaire</span>
                  </li>
                  <li className="flex items-start gap-3">
                    <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                    <span><strong>Le rôle du citoyen</strong> en démocratie</span>
                  </li>
                </ul>
              </div>

              <div className="mt-8 pt-4 border-t border-slate-800">
                <Button
                  onClick={() => handleOpenModule("Institutions et droits")}
                  className="w-full bg-blue-600 font-bold text-white hover:bg-blue-500 cursor-pointer"
                >
                  Ouvrir ce module <ArrowRight className="ml-2 size-4" />
                </Button>
              </div>
            </div>

            {/* Card 2: Devoirs et vivre-ensemble */}
            <div className="flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-900/90 p-8 shadow-xl transition hover:border-blue-500/50 hover:bg-slate-900">
              <div>
                <div className="flex size-12 items-center justify-center rounded-2xl bg-blue-500/20 text-blue-400">
                  <ShieldCheck className="size-6" />
                </div>
                <h2 className="mt-6 font-display text-xl font-bold text-white">Devoirs et vivre-ensemble</h2>
                <p className="mt-1 text-xs text-slate-400">Éthique, respect mutuel et cohésion nationale</p>

                <ul className="mt-6 space-y-4 text-sm text-slate-300">
                  <li className="flex items-start gap-3">
                    <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                    <span><strong>Respect des lois</strong> et du bien commun</span>
                  </li>
                  <li className="flex items-start gap-3">
                    <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                    <span><strong>Lutte contre la corruption</strong> au quotidien</span>
                  </li>
                  <li className="flex items-start gap-3">
                    <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                    <span><strong>Cohabitation pacifique</strong> et tolérance</span>
                  </li>
                </ul>
              </div>

              <div className="mt-8 pt-4 border-t border-slate-800">
                <Button
                  onClick={() => handleOpenModule("Devoirs et vivre-ensemble")}
                  className="w-full bg-blue-600 font-bold text-white hover:bg-blue-500 cursor-pointer"
                >
                  Ouvrir ce module <ArrowRight className="ml-2 size-4" />
                </Button>
              </div>
            </div>

            {/* Card 3: Engagement civique */}
            <div className="flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-900/90 p-8 shadow-xl transition hover:border-blue-500/50 hover:bg-slate-900">
              <div>
                <div className="flex size-12 items-center justify-center rounded-2xl bg-blue-500/20 text-blue-400">
                  <HeartHandshake className="size-6" />
                </div>
                <h2 className="mt-6 font-display text-xl font-bold text-white">Engagement civique</h2>
                <p className="mt-1 text-xs text-slate-400">L'action concrète au service de la communauté</p>

                <ul className="mt-6 space-y-4 text-sm text-slate-300">
                  <li className="flex items-start gap-3">
                    <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                    <span><strong>Participer à la vie</strong> de sa communauté</span>
                  </li>
                  <li className="flex items-start gap-3">
                    <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                    <span><strong>Bénévolat</strong> et action associative</span>
                  </li>
                  <li className="flex items-start gap-3">
                    <CheckCircle2 className="size-4 text-blue-400 shrink-0 mt-0.5" />
                    <span><strong>Comprendre les élections</strong> et le vote</span>
                  </li>
                </ul>
              </div>

              <div className="mt-8 pt-4 border-t border-slate-800">
                <Button
                  onClick={() => handleOpenModule("Engagement civique")}
                  className="w-full bg-blue-600 font-bold text-white hover:bg-blue-500 cursor-pointer"
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

