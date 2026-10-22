import { useState, type ReactNode } from "react";
import { PlayCircle } from "lucide-react";

/** Contenu d'un site tiers (YouTube, GeoGebra) chargé seulement après un clic :
 *  aucun traceur du tiers n'est déposé tant que l'élève n'a pas choisi de l'afficher. */
export function EmbedApresClic({
  fournisseur,
  titre,
  className,
  children,
}: {
  fournisseur: string;
  titre: string;
  className?: string;
  children: ReactNode;
}) {
  const [affiche, setAffiche] = useState(false);
  if (affiche) return <>{children}</>;
  return (
    <button
      type="button"
      onClick={() => setAffiche(true)}
      className={`flex w-full flex-col items-center justify-center gap-2 rounded-xl border border-border bg-muted/40 p-6 text-center transition hover:bg-muted ${className ?? ""}`}
    >
      <PlayCircle className="size-10 text-primary" aria-hidden="true" />
      <span className="text-sm font-semibold text-foreground">Afficher : {titre}</span>
      <span className="max-w-sm text-xs text-muted-foreground">
        Contenu hébergé par {fournisseur}. En l'affichant, tu acceptes que {fournisseur} dépose ses
        propres cookies.
      </span>
    </button>
  );
}
