import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { CheckCircle2, Clock, Eye, LoaderCircle, Trash2, XCircle } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { ouvrirFichier, supprimerEpreuve, type EpreuveBanque } from "@/lib/banque";
import { Button } from "@/components/ui/button";

const STATUTS: Record<string, { label: string; icon: React.ReactNode; className: string }> = {
  en_attente: {
    label: "En attente de validation",
    icon: <Clock className="size-3.5" />,
    className: "bg-warning/15 text-warning",
  },
  publiee: {
    label: "Publiée",
    icon: <CheckCircle2 className="size-3.5" />,
    className: "bg-success/10 text-success",
  },
  rejetee: {
    label: "Refusée",
    icon: <XCircle className="size-3.5" />,
    className: "bg-destructive/10 text-destructive",
  },
};

/** Épreuves déposées par l'utilisateur, avec leur état de validation. */
export function MesDepots({ userId }: { userId: string }) {
  const queryClient = useQueryClient();
  const [suppression, setSuppression] = useState<string | null>(null);
  const { data = [], isLoading } = useQuery({
    queryKey: ["banque-mes-depots", userId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("banque_epreuves")
        .select("*")
        .eq("depose_par", userId)
        .order("created_at", { ascending: false });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  const supprimer = async (e: EpreuveBanque) => {
    if (!window.confirm(`Supprimer « ${e.titre} » ?`)) return;
    setSuppression(e.id);
    try {
      await supprimerEpreuve(e);
      await queryClient.invalidateQueries({ queryKey: ["banque-mes-depots"] });
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Suppression impossible.");
    } finally {
      setSuppression(null);
    }
  };

  if (isLoading) return <p className="text-sm text-muted-foreground">Chargement…</p>;
  if (data.length === 0)
    return (
      <p className="rounded-2xl bg-card p-6 text-sm text-muted-foreground shadow-sm">
        Aucune épreuve déposée pour le moment.
      </p>
    );

  return (
    <ul className="space-y-2">
      {data.map((e) => {
        const s = STATUTS[e.statut] ?? STATUTS["en_attente"]!;
        return (
          <li
            key={e.id}
            className="flex flex-wrap items-center gap-3 rounded-2xl bg-card p-4 shadow-sm"
          >
            <div className="min-w-0 flex-1">
              <p className="font-semibold text-foreground">{e.titre}</p>
              <p className="text-xs text-muted-foreground">
                {[e.type_examen, e.matiere, e.classe, e.annee].filter(Boolean).join(" · ")}
                {e.statut === "publiee" ? ` · ${e.telechargements} téléchargement(s)` : ""}
              </p>
              {e.statut === "rejetee" && e.motif_rejet ? (
                <p className="mt-1 text-xs text-destructive">Motif : {e.motif_rejet}</p>
              ) : null}
            </div>
            <span
              className={`inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-semibold ${s.className}`}
            >
              {s.icon} {s.label}
            </span>
            <Button
              size="sm"
              variant="outline"
              className="rounded-xl"
              onClick={() => void ouvrirFichier(e).catch((err: Error) => toast.error(err.message))}
            >
              <Eye className="size-4" /> Voir
            </Button>
            {e.statut !== "publiee" ? (
              <Button
                size="sm"
                variant="ghost"
                className="rounded-xl text-destructive"
                disabled={suppression === e.id}
                onClick={() => void supprimer(e)}
              >
                {suppression === e.id ? (
                  <LoaderCircle className="size-4 animate-spin" />
                ) : (
                  <Trash2 className="size-4" />
                )}
              </Button>
            ) : null}
          </li>
        );
      })}
    </ul>
  );
}
