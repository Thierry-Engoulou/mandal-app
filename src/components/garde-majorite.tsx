import { useEffect, useState, type ComponentType } from "react";
import { Link } from "@tanstack/react-router";
import { Bot, ShieldAlert } from "lucide-react";
import { Button } from "@/components/ui/button";

const CLE_MAJORITE = "mandal_ia_majeur_v1";

function lireConfirmation(): boolean {
  try {
    return localStorage.getItem(CLE_MAJORITE) === "1";
  } catch {
    return false;
  }
}

/** Mandal IA repose sur Gemini (Google), dont les conditions réservent l'usage aux
 *  personnes de 18 ans ou plus : l'utilisateur doit le confirmer avant d'y accéder. */
export function GardeMajorite({ children }: { children: React.ReactNode }) {
  const [majeur, setMajeur] = useState<boolean | null>(null);
  useEffect(() => setMajeur(lireConfirmation()), []);

  if (majeur === null) return null;
  if (majeur) return <>{children}</>;

  const confirmer = () => {
    try {
      localStorage.setItem(CLE_MAJORITE, "1");
    } catch {
      // stockage indisponible : confirmation valable pour cette visite
    }
    setMajeur(true);
  };

  return (
    <div className="mx-auto max-w-xl rounded-3xl bg-card p-6 shadow-sm sm:p-8">
      <div className="flex items-center gap-3">
        <span className="grid size-11 place-items-center rounded-2xl bg-primary/10 text-primary">
          <Bot className="size-6" aria-hidden="true" />
        </span>
        <h1 className="font-display text-xl font-bold text-foreground">
          Mandal IA : réservé aux 18 ans et plus
        </h1>
      </div>
      <p className="mt-4 text-sm text-muted-foreground">
        Les fonctions d'intelligence artificielle (questions à Mandal IA, conseiller d'orientation,
        correction de copies, épreuves blanches) utilisent le service Gemini de Google, dont les
        conditions d'utilisation sont réservées aux personnes de <strong>18 ans ou plus</strong>.
      </p>
      <p className="mt-3 text-sm text-muted-foreground">
        Si tu as moins de 18 ans, tu peux continuer à utiliser tout le reste de M'ANDAL : cours,
        banque d'épreuves, fiches d'orientation, classes et messagerie.
      </p>
      <div className="mt-6 flex flex-wrap gap-3">
        <Button className="rounded-xl" onClick={confirmer}>
          J'ai 18 ans ou plus
        </Button>
        <Button asChild variant="outline" className="rounded-xl">
          <Link to="/etudiant">J'ai moins de 18 ans</Link>
        </Button>
      </div>
      <p className="mt-4 flex items-start gap-2 text-xs text-muted-foreground">
        <ShieldAlert className="mt-0.5 size-4 shrink-0" aria-hidden="true" />
        Déclarer un âge inexact est contraire aux{" "}
        <Link to="/conditions-utilisation" className="underline">
          conditions d'utilisation
        </Link>
        .
      </p>
    </div>
  );
}

/** Enveloppe une page de route avec la confirmation d'âge. */
export function avecGardeMajorite(Page: ComponentType) {
  return function PageGardee() {
    return (
      <GardeMajorite>
        <Page />
      </GardeMajorite>
    );
  };
}
