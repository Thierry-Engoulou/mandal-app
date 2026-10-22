import { Link } from "@tanstack/react-router";
import { cn } from "@/lib/utils";

/** Liens vers les pages légales, à placer dans les pieds de page. */
export function LiensLegaux({ className }: { className?: string }) {
  const lien = "hover:text-foreground hover:underline";
  return (
    <nav
      aria-label="Informations légales"
      className={cn("flex flex-wrap gap-x-4 gap-y-1 text-xs text-muted-foreground", className)}
    >
      <Link to="/mentions-legales" className={lien}>
        Mentions légales
      </Link>
      <Link to="/confidentialite" className={lien}>
        Confidentialité
      </Link>
      <Link to="/cookies" className={lien}>
        Cookies
      </Link>
      <Link to="/conditions-utilisation" className={lien}>
        Conditions d'utilisation
      </Link>
    </nav>
  );
}
