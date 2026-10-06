import React from "react";
import { Link } from "@tanstack/react-router";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Lock, GraduationCap, CheckCircle2, ArrowRight, UserPlus, LogIn } from "lucide-react";

interface AuthRequiredModalProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  category?: "education" | "citoyennete" | "culture";
  levelId?: string;
}

export function AuthRequiredModal({
  isOpen,
  onClose,
  title = "ce contenu pédagogique",
  category = "education",
  levelId,
}: AuthRequiredModalProps) {
  const getCategoryTheme = () => {
    switch (category) {
      case "citoyennete":
        return {
          badge: "⚖️ Volet Citoyenneté & Devoirs",
          color: "text-blue-400 bg-blue-500/10 border-blue-500/30",
          btnColor: "bg-blue-600 hover:bg-blue-500 text-white",
        };
      case "culture":
        return {
          badge: "🌍 Volet Culture & Histoire Africaine",
          color: "text-amber-400 bg-amber-500/10 border-amber-500/30",
          btnColor: "bg-amber-600 hover:bg-amber-500 text-white",
        };
      default:
        return {
          badge: "📚 Volet Éducation & Concours",
          color: "text-emerald-400 bg-emerald-500/10 border-emerald-500/30",
          btnColor: "bg-emerald-600 hover:bg-emerald-500 text-white",
        };
    }
  };

  const theme = getCategoryTheme();

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="max-w-md border border-slate-800 bg-slate-950 text-white shadow-2xl rounded-3xl p-6 sm:p-8">
        <DialogHeader className="text-center sm:text-center">
          <div className="mx-auto flex size-14 items-center justify-center rounded-2xl bg-emerald-500/15 border border-emerald-500/30 text-emerald-400 mb-2">
            <Lock className="size-7" />
          </div>

          <div className={`mx-auto inline-flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs font-bold ${theme.color}`}>
            {theme.badge}
          </div>

          <DialogTitle className="mt-3 font-display text-xl sm:text-2xl font-bold text-white">
            Inscription requise pour ouvrir ce cours
          </DialogTitle>

          <DialogDescription className="mt-2 text-xs sm:text-sm text-slate-300 leading-relaxed">
            Pour accéder à <strong className="text-white font-semibold">« {title} »</strong>, consulter les leçons complètes, les simulations interactives et les quiz d'évaluation, créez votre compte gratuit ou connectez-vous.
          </DialogDescription>
        </DialogHeader>

        <div className="mt-4 space-y-2.5 rounded-2xl bg-slate-900/90 border border-slate-800/80 p-4">
          <p className="text-xs font-bold uppercase tracking-wider text-slate-400">
            Ce que vous débloquez immédiatement :
          </p>
          <ul className="space-y-2 text-xs text-slate-300">
            <li className="flex items-center gap-2">
              <CheckCircle2 className="size-4 text-emerald-400 shrink-0" />
              <span>Cours complets, formules clés &amp; démonstrations</span>
            </li>
            <li className="flex items-center gap-2">
              <CheckCircle2 className="size-4 text-emerald-400 shrink-0" />
              <span>Simulations virtuelles GeoGebra &amp; expériences</span>
            </li>
            <li className="flex items-center gap-2">
              <CheckCircle2 className="size-4 text-emerald-400 shrink-0" />
              <span>Épreuves corrigées pas à pas &amp; barèmes officiels</span>
            </li>
          </ul>
        </div>

        <div className="mt-6 flex flex-col gap-3">
          <Button
            asChild
            className={`w-full rounded-xl py-5 font-display text-sm font-bold shadow-lg ${theme.btnColor}`}
          >
            <Link
              to="/inscription"
              search={levelId ? { level: levelId } : undefined}
              onClick={onClose}
            >
              <UserPlus className="mr-2 size-4" />
              Créer mon compte (Gratuit)
            </Link>
          </Button>

          <Button
            asChild
            variant="outline"
            className="w-full rounded-xl border-slate-800 bg-slate-900 text-slate-200 hover:bg-slate-800 hover:text-white py-5 font-semibold"
          >
            <Link to="/auth" onClick={onClose}>
              <LogIn className="mr-2 size-4" />
              J'ai déjà un compte · Se connecter
            </Link>
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
