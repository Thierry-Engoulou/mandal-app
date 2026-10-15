import { createFileRoute, Link } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { useMemo, useState } from "react";
import { ClipboardCheck, Clock, PenLine } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import {
  NIVEAUX,
  STATUS_LABELS,
  compositionStatus,
  formatDateTime,
  formatDuree,
} from "@/lib/epreuves";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";

export const Route = createFileRoute("/_authenticated/etudiant/epreuves/")({
  component: StudentEpreuvesPage,
  head: () => ({
    meta: [{ title: "Épreuves à composer — M'Andal" }, { name: "robots", content: "noindex" }],
  }),
});

function StudentEpreuvesPage() {
  const { data: profile } = useProfile();
  const [niveau, setNiveau] = useState("tous");

  const { data, isLoading } = useQuery({
    enabled: !!profile,
    queryKey: ["etudiant-epreuves", profile?.id],
    queryFn: async () => {
      const [epreuves, compositions] = await Promise.all([
        supabase
          .from("epreuves")
          .select("id, titre, matiere, niveau, duree_minutes, date_debut, date_fin, classes(nom)")
          .eq("statut", "publiee")
          .order("created_at", { ascending: false }),
        supabase
          .from("compositions")
          .select("epreuve_id, fin_prevue_at, rendu_at, rendu_auto, note")
          .eq("eleve_id", profile!.id),
      ]);
      if (epreuves.error) throw new Error(epreuves.error.message);
      if (compositions.error) throw new Error(compositions.error.message);
      return {
        epreuves: epreuves.data ?? [],
        compositions: new Map((compositions.data ?? []).map((c) => [c.epreuve_id, c])),
      };
    },
  });

  const now = Date.now();
  const list = useMemo(
    () => (data?.epreuves ?? []).filter((e) => niveau === "tous" || e.niveau === niveau),
    [data, niveau],
  );
  const niveauxPresents = useMemo(
    () => NIVEAUX.filter((n) => (data?.epreuves ?? []).some((e) => e.niveau === n)),
    [data],
  );

  return (
    <div className="space-y-6">
      <header className="gradient-welcome rounded-2xl p-6 text-primary-foreground shadow-sm">
        <ClipboardCheck className="mb-2 size-6" />
        <h1 className="font-display text-2xl font-bold">Épreuves à composer</h1>
        <p className="mt-1 max-w-2xl text-sm opacity-90">
          Les sujets déposés par tes enseignants. Compose sur papier en temps limité, puis
          photographie ou scanne tes pages : elles sont transmises à ton enseignant.
        </p>
      </header>

      <div className="flex flex-wrap items-center gap-2">
        <label htmlFor="niveau" className="text-sm font-semibold text-foreground">
          Niveau
        </label>
        <select
          id="niveau"
          value={niveau}
          onChange={(e) => setNiveau(e.target.value)}
          className="rounded-xl border border-border bg-card px-3 py-2 text-sm"
        >
          <option value="tous">Tous les niveaux</option>
          {niveauxPresents.map((n) => (
            <option key={n}>{n}</option>
          ))}
        </select>
      </div>

      {isLoading ? (
        <Skeleton className="h-40 rounded-2xl" />
      ) : list.length === 0 ? (
        <p className="rounded-2xl border border-dashed border-border p-10 text-center text-sm text-muted-foreground">
          Aucune épreuve disponible pour l'instant.
        </p>
      ) : (
        <div className="grid gap-3 md:grid-cols-2">
          {list.map((e) => {
            const comp = data?.compositions.get(e.id);
            const status = comp ? compositionStatus(comp, now) : null;
            const pasOuverte = e.date_debut && new Date(e.date_debut).getTime() > now;
            const close = e.date_fin && new Date(e.date_fin).getTime() <= now;
            const classe = Array.isArray(e.classes) ? e.classes[0] : e.classes;
            return (
              <div key={e.id} className="flex flex-col rounded-2xl bg-card p-4 shadow-sm">
                <p className="text-xs font-bold uppercase tracking-wide text-primary">
                  {e.matiere} · {e.niveau}
                  {classe ? ` · ${classe.nom}` : ""}
                </p>
                <p className="mt-1 font-semibold text-foreground">{e.titre}</p>
                <p className="mt-1 flex items-center gap-1 text-xs text-muted-foreground">
                  <Clock className="size-3.5" /> {formatDuree(e.duree_minutes)}
                  {e.date_fin ? ` · jusqu'au ${formatDateTime(e.date_fin)}` : ""}
                </p>
                <div className="mt-3 flex flex-1 items-end justify-between gap-2">
                  <span className="text-xs font-semibold text-muted-foreground">
                    {status === "notee" && comp?.note !== null
                      ? `Note : ${comp?.note}/20`
                      : status
                        ? STATUS_LABELS[status]
                        : pasOuverte
                          ? `Ouvre le ${formatDateTime(e.date_debut!)}`
                          : close
                            ? "Clôturée"
                            : "À faire"}
                  </span>
                  <Button asChild size="sm" className="rounded-xl">
                    <Link to="/etudiant/epreuves/$epreuveId" params={{ epreuveId: e.id }}>
                      <PenLine className="size-4" />
                      {status === "en_cours" || status === "numerisation"
                        ? "Continuer"
                        : status
                          ? "Voir"
                          : "Composer"}
                    </Link>
                  </Button>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
