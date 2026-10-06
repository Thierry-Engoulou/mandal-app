import { Link } from "@tanstack/react-router";
import {
  Heart,
  HelpCircle,
  Sparkles,
  School,
  Building2,
  Users,
  CheckCircle,
  ArrowRight,
  ShieldAlert,
  GraduationCap,
  DollarSign,
} from "lucide-react";
import { Button } from "@/components/ui/button";

export function MandalSponsorshipSection() {
  return (
    <section id="parrainage" className="relative overflow-hidden bg-slate-950 py-20 text-white lg:py-28">
      {/* Background glow and subtle grid */}
      <div className="pointer-events-none absolute inset-0 bg-[radial-gradient(circle_at_top,_var(--tw-gradient-stops))] from-emerald-900/20 via-slate-950 to-slate-950" />
      <div className="pointer-events-none absolute right-0 top-1/2 -translate-y-1/2 h-[500px] w-[500px] rounded-full bg-amber-500/5 blur-[120px]" />

      <div className="relative mx-auto max-w-7xl px-5 lg:px-8">
        {/* Top Header */}
        <div className="mx-auto max-w-3xl text-center">
          <div className="inline-flex items-center gap-2 rounded-full border border-amber-500/30 bg-amber-500/10 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-amber-400">
            <Heart className="size-3.5 fill-amber-400/30 text-amber-400" /> Programme d'Inclusion & Solidarité
          </div>
          <h2 className="mt-4 font-display text-3xl font-extrabold tracking-tight text-white sm:text-4xl lg:text-5xl">
            Le Parrainage M'Andal
          </h2>
          
          {/* Main Key Quote (Slide 10) */}
          <div className="mt-6 rounded-2xl border border-amber-500/25 bg-gradient-to-r from-amber-500/10 via-emerald-500/10 to-transparent p-6 shadow-lg backdrop-blur-sm sm:p-8">
            <p className="font-display text-xl font-bold italic leading-relaxed text-amber-200 sm:text-2xl">
              « Un élève brillant ne devrait jamais renoncer à un concours faute de moyens »
            </p>
          </div>
        </div>

        {/* 3 Columns Mechanism (Slide 10) */}
        <div className="mt-14 grid grid-cols-1 gap-6 md:grid-cols-3">
          {/* 1. Le constat */}
          <div className="group relative flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-900/80 p-8 shadow-xl transition-all duration-300 hover:border-red-500/40 hover:bg-slate-900">
            <div>
              <div className="flex size-12 items-center justify-center rounded-2xl bg-red-500/15 text-red-400">
                <ShieldAlert className="size-6" />
              </div>
              <div className="mt-6">
                <span className="text-xs font-bold uppercase tracking-wider text-red-400">01. La Réalité</span>
                <h3 className="mt-1 font-display text-2xl font-bold text-white">Le constat</h3>
              </div>
              <p className="mt-4 text-sm leading-relaxed text-slate-300">
                De nombreux élèves particulièrement brillants ne peuvent pas financer une préparation de qualité aux grands concours d'entrée (<span className="font-semibold text-white">ENSPD, IUT, ENS, Médecine...</span>) ni acquérir les annales nécessaires face au coût élevé de la vie.
              </p>
            </div>
            <div className="mt-8 rounded-xl border border-red-500/20 bg-red-950/20 p-4 text-xs font-medium text-red-300">
              ⚡ Risque : Décrochage et perte de talents exceptionnels pour le pays.
            </div>
          </div>

          {/* 2. Le mécanisme */}
          <div className="group relative flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-900/80 p-8 shadow-xl transition-all duration-300 hover:border-emerald-500/40 hover:bg-slate-900">
            <div>
              <div className="flex size-12 items-center justify-center rounded-2xl bg-emerald-500/15 text-emerald-400">
                <Heart className="size-6 text-emerald-400" />
              </div>
              <div className="mt-6">
                <span className="text-xs font-bold uppercase tracking-wider text-emerald-400">02. La Solution</span>
                <h3 className="mt-1 font-display text-2xl font-bold text-white">Le mécanisme</h3>
              </div>
              <p className="mt-4 text-sm leading-relaxed text-slate-300">
                Un parrain (<span className="font-semibold text-white">entreprise citoyenne, membre de la diaspora, ancien élève ou particulier</span>) finance directement l'accès complet et le suivi pédagogique d'un élève identifié comme brillant mais en situation de précarité financière.
              </p>
            </div>
            <div className="mt-8 rounded-xl border border-emerald-500/20 bg-emerald-950/20 p-4 text-xs font-medium text-emerald-300">
              ✨ Impact : Accès garanti 24h/24 aux cours, simulations et épreuves corrigées.
            </div>
          </div>

          {/* 3. Le rôle des établissements */}
          <div className="group relative flex flex-col justify-between rounded-3xl border border-slate-800 bg-slate-900/80 p-8 shadow-xl transition-all duration-300 hover:border-blue-500/40 hover:bg-slate-900">
            <div>
              <div className="flex size-12 items-center justify-center rounded-2xl bg-blue-500/15 text-blue-400">
                <School className="size-6" />
              </div>
              <div className="mt-6">
                <span className="text-xs font-bold uppercase tracking-wider text-blue-400">03. Le Relais Local</span>
                <h3 className="mt-1 font-display text-2xl font-bold text-white">Le rôle des établissements</h3>
              </div>
              <p className="mt-4 text-sm leading-relaxed text-slate-300">
                Les lycées, collèges et enseignants partenaires <span className="font-semibold text-white">identifient et recommandent</span> ces élèves méritants directement à travers la plateforme, en lien étroit avec l'équipe M'Andal pour un suivi rigoureux et transparent.
              </p>
            </div>
            <div className="mt-8 rounded-xl border border-blue-500/20 bg-blue-950/20 p-4 text-xs font-medium text-blue-300">
              🤝 Garantie : Transparence, méritocratie et transmission directe du savoir.
            </div>
          </div>
        </div>

        {/* Action Banner */}
        <div className="mt-12 rounded-3xl border border-slate-800 bg-gradient-to-r from-slate-900 via-slate-850 to-slate-900 p-8 sm:p-10 flex flex-col lg:flex-row items-center justify-between gap-6">
          <div className="space-y-2 text-center lg:text-left">
            <h4 className="font-display text-xl sm:text-2xl font-bold text-white">
              Vous souhaitez parrainer un futur bachelier ou ingénieur ?
            </h4>
            <p className="text-sm text-slate-400 max-w-xl">
              Entreprises, fondations ou particuliers : contribuez directement à l'émergence des talents de notre jeunesse.
            </p>
          </div>
          <div className="flex flex-wrap items-center justify-center gap-3">
            <Button asChild size="lg" className="rounded-full bg-amber-500 text-slate-950 font-bold hover:bg-amber-400">
              <a href="mailto:contact@jvepi-mandalorgmandal.cm?subject=Parrainage%20M'Andal">
                Devenir Parrain / Partenaire <ArrowRight className="ml-2 size-4" />
              </a>
            </Button>
            <Button asChild variant="outline" size="lg" className="rounded-full border-slate-700 text-slate-200 hover:bg-slate-800">
              <Link to="/demande-inscription">
                Recommander un élève
              </Link>
            </Button>
          </div>
        </div>
      </div>
    </section>
  );
}
