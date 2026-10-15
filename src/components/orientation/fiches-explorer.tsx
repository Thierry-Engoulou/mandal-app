import { useQuery } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { BookOpen, ChevronDown, ExternalLink, LoaderCircle, Search } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import type { Tables } from "@/integrations/supabase/types";
import { MathText } from "@/components/math-text";
import { cn } from "@/lib/utils";

type Fiche = Tables<"orientation_fiches">;
export type TypeFiche = "filiere" | "metier" | "faq";

function lireSources(value: Fiche["sources"]): Array<{ titre: string; url?: string }> {
  if (!Array.isArray(value)) return [];
  return value.flatMap((s) => {
    if (!s || typeof s !== "object" || Array.isArray(s)) return [];
    const { titre, url } = s;
    if (typeof titre !== "string") return [];
    return [typeof url === "string" ? { titre, url } : { titre }];
  });
}

/** Petit délai pour ne pas interroger la base à chaque frappe. */
function useDebounced(value: string, ms = 300) {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const t = setTimeout(() => setDebounced(value), ms);
    return () => clearTimeout(t);
  }, [value, ms]);
  return debounced;
}

export function FichesExplorer({ type, placeholder }: { type: TypeFiche; placeholder: string }) {
  const [recherche, setRecherche] = useState("");
  const [categorie, setCategorie] = useState<string | null>(null);
  const terme = useDebounced(recherche.trim());

  const { data: toutes = [], isLoading } = useQuery({
    queryKey: ["orientation-fiches", type],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("orientation_fiches")
        .select("*")
        .eq("type", type)
        .order("categorie")
        .order("titre");
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  const { data: trouvees, isFetching } = useQuery({
    enabled: terme.length >= 2,
    queryKey: ["orientation-fiches", type, "recherche", terme],
    queryFn: async () => {
      const { data, error } = await supabase.rpc("rechercher_fiches_orientation", {
        p_question: terme,
        p_limite: 20,
        p_type: type,
      });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  const categories = [...new Set(toutes.map((f) => f.categorie))];
  const base = terme.length >= 2 ? (trouvees ?? []) : toutes;
  const fiches = categorie ? base.filter((f) => f.categorie === categorie) : base;

  return (
    <div className="space-y-4">
      <div className="relative">
        <Search className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
        <input
          value={recherche}
          onChange={(e) => setRecherche(e.target.value)}
          placeholder={placeholder}
          className="w-full rounded-xl border border-border bg-card py-3 pl-10 pr-10 text-sm shadow-sm"
        />
        {isFetching ? (
          <LoaderCircle className="absolute right-3 top-1/2 size-4 -translate-y-1/2 animate-spin text-muted-foreground" />
        ) : null}
      </div>

      {categories.length > 1 ? (
        <div className="flex flex-wrap gap-2">
          {[null, ...categories].map((c) => (
            <button
              key={c ?? "toutes"}
              type="button"
              onClick={() => setCategorie(c)}
              className={cn(
                "rounded-full border px-3 py-1 text-xs font-semibold transition",
                c === categorie
                  ? "border-primary bg-primary text-primary-foreground"
                  : "border-border bg-card text-muted-foreground hover:text-foreground",
              )}
            >
              {c ?? "Toutes"}
            </button>
          ))}
        </div>
      ) : null}

      {isLoading ? (
        <p className="flex items-center gap-2 text-sm text-muted-foreground">
          <LoaderCircle className="size-4 animate-spin" /> Chargement…
        </p>
      ) : fiches.length === 0 ? (
        <div className="rounded-2xl bg-card p-8 text-center text-sm text-muted-foreground shadow-sm">
          {toutes.length === 0
            ? "La base d'orientation n'est pas encore chargée."
            : "Aucune fiche ne correspond. Pose ta question au Conseiller IA."}
        </div>
      ) : (
        <div className="space-y-3">
          {fiches.map((f) => (
            <FicheCard key={f.id} fiche={f} />
          ))}
        </div>
      )}
    </div>
  );
}

function FicheCard({ fiche }: { fiche: Fiche }) {
  const [ouverte, setOuverte] = useState(false);
  const sources = lireSources(fiche.sources);
  // Les questions fréquentes répètent le résumé en tête du contenu.
  const contenu =
    fiche.type === "faq" ? fiche.contenu.slice(fiche.resume.length).trim() : fiche.contenu;

  return (
    <article className="rounded-2xl bg-card shadow-sm">
      <button
        type="button"
        onClick={() => setOuverte((o) => !o)}
        className="flex w-full items-start gap-3 p-4 text-left"
        aria-expanded={ouverte}
      >
        <BookOpen className="mt-0.5 size-5 shrink-0 text-primary" />
        <span className="min-w-0 flex-1">
          <span className="block font-semibold text-foreground">{fiche.titre}</span>
          <span className="mt-0.5 block text-xs text-muted-foreground">
            {fiche.categorie}
            {fiche.niveau_acces ? ` · ${fiche.niveau_acces}` : ""}
          </span>
        </span>
        <ChevronDown
          className={cn("mt-1 size-4 shrink-0 transition", ouverte ? "rotate-180" : "")}
        />
      </button>
      <MathText
        text={fiche.resume}
        className="-mt-2 px-4 pb-4 pl-12 text-sm text-muted-foreground"
      />

      {ouverte ? (
        <div className="space-y-4 border-t border-border px-4 pb-4 pt-3 text-sm">
          {contenu ? <MathText text={contenu} /> : null}
          {fiche.debouches.length ? <Liste titre="Débouchés" items={fiche.debouches} /> : null}
          {fiche.formations.length ? <Liste titre="Où se former" items={fiche.formations} /> : null}
          {sources.length ? (
            <div>
              <p className="mb-1 font-semibold text-foreground">Sources</p>
              <ul className="space-y-1 text-muted-foreground">
                {sources.map((s) => (
                  <li key={s.titre}>
                    {s.url ? (
                      <a
                        href={s.url}
                        target="_blank"
                        rel="noreferrer"
                        className="inline-flex items-center gap-1 text-primary hover:underline"
                      >
                        {s.titre} <ExternalLink className="size-3" />
                      </a>
                    ) : (
                      s.titre
                    )}
                  </li>
                ))}
              </ul>
            </div>
          ) : null}
          <p className="text-xs text-muted-foreground">
            Fiche mise à jour le {new Date(fiche.mis_a_jour).toLocaleDateString("fr-FR")}. Dates,
            frais et places changent chaque année : vérifie toujours le communiqué officiel.
          </p>
        </div>
      ) : null}
    </article>
  );
}

function Liste({ titre, items }: { titre: string; items: string[] }) {
  return (
    <div>
      <p className="mb-1 font-semibold text-foreground">{titre}</p>
      <div className="flex flex-wrap gap-1.5">
        {items.map((i) => (
          <span key={i} className="rounded-full bg-secondary px-2.5 py-1 text-xs text-foreground">
            {i}
          </span>
        ))}
      </div>
    </div>
  );
}
