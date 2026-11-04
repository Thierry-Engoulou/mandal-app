import { createFileRoute, Link } from "@tanstack/react-router";
import { ExternalLink, GraduationCap, Landmark, MapPin, Plane } from "lucide-react";
import { MandalLogo } from "@/components/mandal-logo";
import { Button } from "@/components/ui/button";
import { LiensLegaux } from "@/components/legal/liens-legaux";
import { BOURSES, CONCOURS_NATIONAUX, UNIVERSITES, type Universite } from "@/lib/mandal-sup";

export const Route = createFileRoute("/mandal-sup")({
  head: () => ({
    meta: [
      { title: "M'Andal'Sup : universités, grandes écoles et bourses — M'ANDAL" },
      {
        name: "description",
        content:
          "Les universités d'État du Cameroun par région, leurs grandes écoles, les concours nationaux et les bourses pour étudier à l'étranger.",
      },
    ],
  }),
  component: MandalSupPage,
});

function MandalSupPage() {
  return (
    <div className="min-h-screen bg-background text-foreground">
      <header className="sticky top-0 z-50 border-b border-border bg-card/95 backdrop-blur">
        <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 lg:px-8">
          <Link to="/" className="flex items-center gap-3">
            <MandalLogo />
          </Link>
          <div className="flex items-center gap-2">
            <Button asChild variant="ghost" className="hidden sm:inline-flex">
              <Link to="/education">Éducation</Link>
            </Button>
            <Button
              asChild
              className="rounded-full bg-sky-600 px-5 font-semibold text-white hover:bg-sky-500"
            >
              <Link to="/auth">Mon espace</Link>
            </Button>
          </div>
        </div>
      </header>

      <section className="bg-gradient-to-b from-sky-500/10 via-background to-background py-10 sm:py-14">
        <div className="mx-auto max-w-4xl px-4 text-center">
          <div className="inline-flex items-center gap-2 rounded-full border border-sky-500/30 bg-sky-500/10 px-4 py-1.5 text-xs font-bold uppercase tracking-wider text-sky-700 dark:text-sky-300">
            <GraduationCap className="size-3.5" /> M'Andal'Sup
          </div>
          <h1 className="mt-4 font-display text-3xl font-black tracking-tight sm:text-4xl">
            Après le Bac : universités, grandes écoles et bourses
          </h1>
          <p className="mt-3 text-muted-foreground">
            Les universités d'État du Cameroun région par région, leurs grandes écoles, les concours
            nationaux et les bourses pour étudier à l'étranger.
          </p>
          <nav className="mt-6 flex flex-wrap justify-center gap-2 text-sm">
            <a
              href="#universites"
              className="rounded-full border border-border bg-card px-4 py-2 font-semibold hover:border-sky-500"
            >
              Universités
            </a>
            <a
              href="#concours-nationaux"
              className="rounded-full border border-border bg-card px-4 py-2 font-semibold hover:border-sky-500"
            >
              Concours nationaux
            </a>
            <a
              href="#bourses"
              className="rounded-full border border-border bg-card px-4 py-2 font-semibold hover:border-sky-500"
            >
              Bourses à l'étranger
            </a>
          </nav>
        </div>
      </section>

      <main className="mx-auto max-w-6xl space-y-14 px-4 pb-16">
        <section id="universites" className="scroll-mt-24 space-y-5">
          <h2 className="flex items-center gap-2 font-display text-2xl font-bold">
            <Landmark className="size-6 text-sky-600" /> Universités d'État par région
          </h2>
          <div className="space-y-4">
            {UNIVERSITES.map((u, i) => (
              <CarteUniversite key={u.nom} universite={u} numero={i + 1} />
            ))}
          </div>
        </section>

        <section id="concours-nationaux" className="scroll-mt-24 space-y-4">
          <h2 className="font-display text-2xl font-bold">
            Concours nationaux et interministériels
          </h2>
          <ul className="grid gap-3 md:grid-cols-2">
            {CONCOURS_NATIONAUX.map((c) => (
              <li key={c.tutelle} className="rounded-2xl bg-card p-5 shadow-sm">
                <p className="text-sm font-bold text-sky-700 dark:text-sky-300">{c.tutelle}</p>
                <p className="mt-1 text-sm text-muted-foreground">{c.contenu}</p>
              </li>
            ))}
          </ul>
          <p className="text-xs text-muted-foreground">
            Les anciennes épreuves des concours sont dans la{" "}
            <Link to="/banque-epreuves" search={{ type: "Concours" }} className="underline">
              banque d'épreuves
            </Link>
            .
          </p>
        </section>

        <section id="bourses" className="scroll-mt-24 space-y-4">
          <h2 className="flex items-center gap-2 font-display text-2xl font-bold">
            <Plane className="size-6 text-sky-600" /> Opportunités internationales : bourses
          </h2>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {BOURSES.map((b) => (
              <div key={b.pays} className="rounded-2xl bg-card p-5 shadow-sm">
                <p className="font-display text-lg font-bold">
                  <span aria-hidden="true">{b.drapeau}</span> {b.pays}
                </p>
                <ul className="mt-3 space-y-2 text-sm">
                  {b.programmes.map((p) => (
                    <li key={p.lien}>
                      <a
                        href={p.lien}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-start gap-1.5 text-sky-700 hover:underline dark:text-sky-300"
                      >
                        <ExternalLink className="mt-0.5 size-3.5 shrink-0" /> {p.nom}
                      </a>
                    </li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
          <p className="text-xs text-muted-foreground">
            Les conditions, montants et dates limites changent chaque année : vérifie toujours sur
            le site officiel du programme avant de constituer ton dossier.
          </p>
        </section>

        <LiensLegaux className="justify-center" />
      </main>
    </div>
  );
}

function CarteUniversite({ universite: u, numero }: { universite: Universite; numero: number }) {
  return (
    <details className="group rounded-2xl bg-card shadow-sm" open={numero === 1}>
      <summary className="flex cursor-pointer list-none items-center justify-between gap-3 p-5">
        <div>
          <p className="flex items-center gap-1.5 text-xs font-bold uppercase tracking-wide text-sky-700 dark:text-sky-300">
            <MapPin className="size-3.5" /> {numero}. {u.region}
          </p>
          <p className="mt-1 font-display text-lg font-bold">{u.nom}</p>
        </div>
        <span className="text-sm text-muted-foreground transition group-open:rotate-180">▾</span>
      </summary>
      <div className="space-y-4 border-t border-border px-5 pb-5 pt-4">
        <div>
          <h3 className="text-sm font-bold">a) Présentation</h3>
          <p className="mt-1 text-sm text-muted-foreground">{u.presentation}</p>
          {u.site ? (
            <a
              href={u.site}
              target="_blank"
              rel="noopener noreferrer"
              className="mt-2 inline-flex items-center gap-1.5 text-sm font-semibold text-sky-700 hover:underline dark:text-sky-300"
            >
              <ExternalLink className="size-3.5" /> Site officiel
            </a>
          ) : null}
        </div>
        <div>
          <h3 className="text-sm font-bold">b) Grandes écoles</h3>
          <ul className="mt-2 space-y-2">
            {u.ecoles.map((e) => (
              <li key={`${e.sigle}-${e.nom}`} className="text-sm">
                <span className="font-semibold">{e.sigle}</span>
                {e.sigle !== e.nom ? <span> — {e.nom}</span> : null}
                {e.precision ? (
                  <span className="text-muted-foreground"> ({e.precision})</span>
                ) : null}
                {e.lien ? (
                  <a
                    href={e.lien}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="ml-1.5 inline-flex items-center gap-1 text-xs font-semibold text-sky-700 hover:underline dark:text-sky-300"
                  >
                    <ExternalLink className="size-3" /> Présentation
                  </a>
                ) : null}
              </li>
            ))}
          </ul>
        </div>
      </div>
    </details>
  );
}
