import { Link } from "@tanstack/react-router";
import type { ReactNode } from "react";
import { MandalLogo } from "@/components/mandal-logo";
import { SITE_INFO } from "@/lib/site-info";
import { LiensLegaux } from "@/components/legal/liens-legaux";

/** Mise en page commune des pages légales (texte lisible, sans décor). */
export function LegalLayout({ titre, children }: { titre: string; children: ReactNode }) {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <header className="border-b border-border bg-card">
        <div className="mx-auto flex h-16 max-w-3xl items-center justify-between px-4">
          <Link to="/" aria-label="Accueil M'ANDAL">
            <MandalLogo />
          </Link>
          <Link to="/" className="text-sm font-medium text-muted-foreground hover:text-foreground">
            Retour à l'accueil
          </Link>
        </div>
      </header>
      <main className="mx-auto max-w-3xl px-4 py-10">
        <h1 className="font-display text-3xl font-bold tracking-tight">{titre}</h1>
        <p className="mt-2 text-sm text-muted-foreground">
          Dernière mise à jour : {SITE_INFO.miseAJour}
        </p>
        <div className="legal-content mt-8 space-y-6 text-[15px] leading-relaxed text-foreground [&_a]:text-primary [&_a]:underline [&_h2]:mt-8 [&_h2]:font-display [&_h2]:text-xl [&_h2]:font-bold [&_li]:ml-5 [&_li]:list-disc [&_table]:w-full [&_table]:text-sm [&_td]:border [&_td]:border-border [&_td]:p-2 [&_td]:align-top [&_th]:border [&_th]:border-border [&_th]:bg-muted [&_th]:p-2 [&_th]:text-left [&_ul]:space-y-1">
          {children}
        </div>
      </main>
      <footer className="border-t border-border py-6">
        <div className="mx-auto max-w-3xl px-4">
          <LiensLegaux />
        </div>
      </footer>
    </div>
  );
}
