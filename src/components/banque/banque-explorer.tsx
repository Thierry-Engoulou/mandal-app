import { useInfiniteQuery } from "@tanstack/react-query";
import { useEffect, useState, type ReactNode } from "react";
import {
  CheckCircle2,
  Download,
  Eye,
  FileText,
  LoaderCircle,
  Search,
  SlidersHorizontal,
} from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import {
  CLASSES,
  MATIERES_BANQUE,
  TYPES_EXAMEN,
  ouvrirFichier,
  type EpreuveBanque,
} from "@/lib/banque";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

const PAGE = 24;
const selectClass = "w-full rounded-xl border border-border bg-background px-3 py-2.5 text-sm";

export type FiltresBanque = {
  q?: string | undefined;
  matiere?: string | undefined;
  classe?: string | undefined;
  type?: string | undefined;
  annee?: number | undefined;
};

function useDebounced<T>(value: T, ms = 350) {
  const [v, setV] = useState(value);
  useEffect(() => {
    const t = setTimeout(() => setV(value), ms);
    return () => clearTimeout(t);
  }, [value, ms]);
  return v;
}

/** Recherche et téléchargement des épreuves publiées. */
export function BanqueExplorer({
  initial = {},
  onFiltresChange,
  actionsSupplementaires,
}: {
  initial?: FiltresBanque;
  onFiltresChange?: ((f: FiltresBanque) => void) | undefined;
  actionsSupplementaires?: ((e: EpreuveBanque) => ReactNode) | undefined;
}) {
  const [texte, setTexte] = useState(initial.q ?? "");
  const [matiere, setMatiere] = useState(initial.matiere ?? "");
  const [classe, setClasse] = useState(initial.classe ?? "");
  const [type, setType] = useState(initial.type ?? "");
  const [annee, setAnnee] = useState(initial.annee ? String(initial.annee) : "");
  const [filtresOuverts, setFiltresOuverts] = useState(
    !!(initial.matiere || initial.classe || initial.type || initial.annee),
  );
  const q = useDebounced(texte.trim());
  const anneeNum = /^\d{4}$/.test(annee) ? Number(annee) : undefined;

  useEffect(() => {
    onFiltresChange?.({
      q: q || undefined,
      matiere: matiere || undefined,
      classe: classe || undefined,
      type: type || undefined,
      annee: anneeNum,
    });
    // onFiltresChange est volontairement exclu (fonction recréée à chaque rendu).
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [q, matiere, classe, type, anneeNum]);

  const requete = useInfiniteQuery({
    queryKey: ["banque-epreuves", q, matiere, classe, type, anneeNum],
    initialPageParam: 0,
    queryFn: async ({ pageParam }) => {
      const { data, error } = await supabase.rpc("rechercher_banque_epreuves", {
        ...(q ? { p_texte: q } : {}),
        ...(matiere ? { p_matiere: matiere } : {}),
        ...(classe ? { p_classe: classe } : {}),
        ...(type ? { p_type: type } : {}),
        ...(anneeNum ? { p_annee: anneeNum } : {}),
        p_limite: PAGE,
        p_offset: pageParam,
      });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
    getNextPageParam: (dernier, pages) =>
      dernier.length === PAGE ? pages.length * PAGE : undefined,
  });

  const epreuves = requete.data?.pages.flat() ?? [];
  const nbFiltres = [matiere, classe, type, annee].filter(Boolean).length;

  return (
    <div className="space-y-4">
      <div className="flex gap-2">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
          <input
            value={texte}
            onChange={(e) => setTexte(e.target.value)}
            placeholder="Ex. : bac D maths 2023, BEPC anglais, GCE chemistry…"
            className="w-full rounded-xl border border-border bg-card py-3 pl-10 pr-3 text-sm shadow-sm"
            aria-label="Rechercher une épreuve"
          />
        </div>
        <Button
          type="button"
          variant={filtresOuverts ? "default" : "outline"}
          className="h-auto rounded-xl"
          onClick={() => setFiltresOuverts((o) => !o)}
        >
          <SlidersHorizontal className="size-4" />
          <span className="hidden sm:inline">Filtres</span>
          {nbFiltres ? ` (${nbFiltres})` : ""}
        </Button>
      </div>

      {filtresOuverts ? (
        <div className="grid gap-3 rounded-2xl bg-card p-4 shadow-sm sm:grid-cols-2 lg:grid-cols-4">
          <select
            className={selectClass}
            value={type}
            onChange={(e) => setType(e.target.value)}
            aria-label="Examen"
          >
            <option value="">Tous les examens</option>
            {TYPES_EXAMEN.map((t) => (
              <option key={t}>{t}</option>
            ))}
          </select>
          <select
            className={selectClass}
            value={classe}
            onChange={(e) => setClasse(e.target.value)}
            aria-label="Classe"
          >
            <option value="">Toutes les classes</option>
            {CLASSES.map((c) => (
              <option key={c}>{c}</option>
            ))}
          </select>
          <select
            className={selectClass}
            value={matiere}
            onChange={(e) => setMatiere(e.target.value)}
            aria-label="Matière"
          >
            <option value="">Toutes les matières</option>
            {MATIERES_BANQUE.map((m) => (
              <option key={m}>{m}</option>
            ))}
          </select>
          <div className="flex gap-2">
            <input
              value={annee}
              onChange={(e) => setAnnee(e.target.value.replace(/\D/g, "").slice(0, 4))}
              inputMode="numeric"
              placeholder="Année (ex. 2023)"
              className={selectClass}
              aria-label="Année"
            />
            {nbFiltres ? (
              <Button
                type="button"
                variant="ghost"
                className="rounded-xl"
                onClick={() => {
                  setMatiere("");
                  setClasse("");
                  setType("");
                  setAnnee("");
                }}
              >
                Effacer
              </Button>
            ) : null}
          </div>
        </div>
      ) : null}

      {requete.isLoading ? (
        <p className="flex items-center gap-2 text-sm text-muted-foreground">
          <LoaderCircle className="size-4 animate-spin" /> Chargement des épreuves…
        </p>
      ) : requete.isError ? (
        <div className="rounded-2xl bg-card p-8 text-center text-sm text-muted-foreground shadow-sm">
          La banque d'épreuves n'est pas encore disponible. Réessaie dans quelques instants.
        </div>
      ) : epreuves.length === 0 ? (
        <div className="rounded-2xl bg-card p-8 text-center text-sm text-muted-foreground shadow-sm">
          Aucune épreuve ne correspond. Essaie avec moins de mots ou retire un filtre.
        </div>
      ) : (
        <>
          <div className="grid gap-3 md:grid-cols-2">
            {epreuves.map((e) => (
              <CarteEpreuve key={e.id} epreuve={e} actions={actionsSupplementaires?.(e)} />
            ))}
          </div>
          {requete.hasNextPage ? (
            <div className="text-center">
              <Button
                variant="outline"
                className="rounded-xl"
                disabled={requete.isFetchingNextPage}
                onClick={() => void requete.fetchNextPage()}
              >
                {requete.isFetchingNextPage ? (
                  <LoaderCircle className="size-4 animate-spin" />
                ) : null}
                Voir plus d'épreuves
              </Button>
            </div>
          ) : null}
        </>
      )}
    </div>
  );
}

function Badge({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <span
      className={cn(
        "rounded-full bg-secondary px-2.5 py-0.5 text-xs font-medium text-foreground",
        className,
      )}
    >
      {children}
    </span>
  );
}

export function CarteEpreuve({
  epreuve: e,
  actions,
}: {
  epreuve: EpreuveBanque;
  actions?: ReactNode;
}) {
  const [enCours, setEnCours] = useState<string | null>(null);
  const agir = async (cle: string, options: { corrige?: boolean; telecharger?: boolean }) => {
    setEnCours(cle);
    try {
      await ouvrirFichier(e, options);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Fichier indisponible.");
    } finally {
      setEnCours(null);
    }
  };

  return (
    <article className="flex flex-col gap-3 rounded-2xl bg-card p-4 shadow-sm">
      <div className="flex items-start gap-3">
        <FileText className="mt-0.5 size-5 shrink-0 text-primary" />
        <div className="min-w-0 flex-1">
          <h3 className="font-semibold leading-snug text-foreground">{e.titre}</h3>
          <div className="mt-2 flex flex-wrap gap-1.5">
            <Badge className="bg-primary/10 text-primary">{e.type_examen}</Badge>
            <Badge>{e.matiere}</Badge>
            <Badge>{e.classe}</Badge>
            {e.serie ? <Badge>Série {e.serie}</Badge> : null}
            {e.annee ? <Badge>{e.annee}</Badge> : null}
            {e.corrige_path ? (
              <Badge className="bg-success/10 text-success">
                <CheckCircle2 className="mr-1 inline size-3" />
                Corrigé
              </Badge>
            ) : null}
          </div>
          {e.source || e.session ? (
            <p className="mt-2 text-xs text-muted-foreground">
              {[e.session, e.source].filter(Boolean).join(" · ")}
            </p>
          ) : null}
          {e.description ? (
            <p className="mt-1 text-xs text-muted-foreground">{e.description}</p>
          ) : null}
        </div>
      </div>
      <div className="mt-auto flex flex-wrap items-center gap-2">
        <Button
          size="sm"
          className="rounded-xl"
          disabled={!!enCours}
          onClick={() => void agir("dl", { telecharger: true })}
        >
          {enCours === "dl" ? (
            <LoaderCircle className="size-4 animate-spin" />
          ) : (
            <Download className="size-4" />
          )}
          Télécharger
        </Button>
        <Button
          size="sm"
          variant="outline"
          className="rounded-xl"
          disabled={!!enCours}
          onClick={() => void agir("voir", {})}
        >
          <Eye className="size-4" /> Aperçu
        </Button>
        {e.corrige_path ? (
          <Button
            size="sm"
            variant="outline"
            className="rounded-xl"
            disabled={!!enCours}
            onClick={() => void agir("corrige", { corrige: true, telecharger: true })}
          >
            {enCours === "corrige" ? (
              <LoaderCircle className="size-4 animate-spin" />
            ) : (
              <Download className="size-4" />
            )}
            Corrigé
          </Button>
        ) : null}
        {actions}
        {e.telechargements > 0 ? (
          <span className="ml-auto text-xs text-muted-foreground">
            {e.telechargements} téléchargement{e.telechargements > 1 ? "s" : ""}
          </span>
        ) : null}
      </div>
    </article>
  );
}
