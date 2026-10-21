import { createFileRoute } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import {
  Check,
  Eye,
  FilePlus2,
  Files,
  Inbox,
  Library,
  LoaderCircle,
  Pencil,
  Trash2,
  Undo2,
  X,
} from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import {
  ouvrirFichier,
  supprimerEpreuve,
  type EpreuveBanque,
  type MetaEpreuve,
} from "@/lib/banque";
import { BanqueExplorer } from "@/components/banque/banque-explorer";
import { ChampsEpreuve, DepotEpreuveForm } from "@/components/banque/depot-form";
import { ImportMasse } from "@/components/banque/import-masse";
import { TabButton } from "@/components/messagerie/tab-button";
import { Button } from "@/components/ui/button";

export const Route = createFileRoute("/_authenticated/admin/banque")({
  component: AdminBanquePage,
  head: () => ({
    meta: [
      { title: "Banque d'épreuves — Administration M'Andal" },
      { name: "robots", content: "noindex" },
    ],
  }),
});

type Onglet = "validation" | "ajout" | "import" | "publiees";

function versMeta(e: EpreuveBanque): MetaEpreuve {
  return {
    titre: e.titre,
    matiere: e.matiere,
    classe: e.classe,
    serie: e.serie ?? "",
    type_examen: e.type_examen,
    annee: e.annee ? String(e.annee) : "",
    session: e.session ?? "",
    source: e.source ?? "",
    description: e.description ?? "",
  };
}

function AdminBanquePage() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();
  const [onglet, setOnglet] = useState<Onglet>("validation");

  const enAttente = useQuery({
    queryKey: ["banque-en-attente"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("banque_epreuves")
        .select("*")
        .eq("statut", "en_attente")
        .order("created_at", { ascending: true });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  const rafraichir = () => {
    void queryClient.invalidateQueries({ queryKey: ["banque-en-attente"] });
    void queryClient.invalidateQueries({ queryKey: ["banque-epreuves"] });
  };

  return (
    <div className="space-y-6 p-4 md:p-8">
      <header>
        <h1 className="flex items-center gap-2 font-display text-2xl font-bold tracking-tight">
          <Library className="size-6 text-primary" /> Banque d'épreuves
        </h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Valide les épreuves proposées par les enseignants, ajoute les tiennes et gère la banque
          publique (/banque-epreuves).
        </p>
      </header>

      <div className="flex flex-wrap gap-2">
        <TabButton
          active={onglet === "validation"}
          onClick={() => setOnglet("validation")}
          icon={<Inbox className="size-4" />}
          label={`À valider${enAttente.data?.length ? ` (${enAttente.data.length})` : ""}`}
        />
        <TabButton
          active={onglet === "ajout"}
          onClick={() => setOnglet("ajout")}
          icon={<FilePlus2 className="size-4" />}
          label="Ajouter une épreuve"
        />
        <TabButton
          active={onglet === "import"}
          onClick={() => setOnglet("import")}
          icon={<Files className="size-4" />}
          label="Import en masse"
        />
        <TabButton
          active={onglet === "publiees"}
          onClick={() => setOnglet("publiees")}
          icon={<Library className="size-4" />}
          label="Épreuves publiées"
        />
      </div>

      {!profile ? null : onglet === "validation" ? (
        enAttente.isLoading ? (
          <p className="text-sm text-muted-foreground">Chargement…</p>
        ) : !enAttente.data?.length ? (
          <p className="rounded-2xl bg-card p-6 text-sm text-muted-foreground shadow-sm">
            Aucune épreuve en attente de validation.
          </p>
        ) : (
          <div className="space-y-3">
            {enAttente.data.map((e) => (
              <AValider key={e.id} epreuve={e} onFait={rafraichir} />
            ))}
          </div>
        )
      ) : onglet === "ajout" ? (
        <DepotEpreuveForm userId={profile.id} publier onDepose={rafraichir} />
      ) : onglet === "import" ? (
        <ImportMasse userId={profile.id} onTermine={rafraichir} />
      ) : (
        <BanqueExplorer
          actionsSupplementaires={(e) => <ActionsPubliee epreuve={e} onFait={rafraichir} />}
        />
      )}
    </div>
  );
}

function AValider({ epreuve: e, onFait }: { epreuve: EpreuveBanque; onFait: () => void }) {
  const [edition, setEdition] = useState(false);
  const [meta, setMeta] = useState<MetaEpreuve>(versMeta(e));
  const [enCours, setEnCours] = useState(false);

  const decider = async (statut: "publiee" | "rejetee") => {
    let motif: string | null = null;
    if (statut === "rejetee") {
      motif = window.prompt(
        "Motif du refus (visible par l'enseignant) :",
        "Fichier illisible ou incomplet",
      );
      if (motif === null) return;
    }
    setEnCours(true);
    const { error } = await supabase
      .from("banque_epreuves")
      .update({
        statut,
        motif_rejet: motif,
        ...(edition
          ? {
              titre: meta.titre.trim(),
              matiere: meta.matiere,
              classe: meta.classe,
              serie: meta.serie.trim() || null,
              type_examen: meta.type_examen,
              annee: meta.annee ? Number(meta.annee) : null,
              session: meta.session.trim() || null,
              source: meta.source.trim() || null,
              description: meta.description.trim() || null,
            }
          : {}),
      })
      .eq("id", e.id);
    setEnCours(false);
    if (error) {
      toast.error(error.message);
      return;
    }
    toast.success(statut === "publiee" ? "Épreuve publiée." : "Épreuve refusée.");
    onFait();
  };

  return (
    <div className="space-y-3 rounded-2xl bg-card p-4 shadow-sm">
      <div className="flex flex-wrap items-start gap-3">
        <div className="min-w-0 flex-1">
          <p className="font-semibold text-foreground">{e.titre}</p>
          <p className="text-xs text-muted-foreground">
            {[e.type_examen, e.matiere, e.classe, e.serie && `Série ${e.serie}`, e.annee, e.source]
              .filter(Boolean)
              .join(" · ")}
            {e.corrige_path ? " · avec corrigé" : ""}
          </p>
          <p className="text-xs text-muted-foreground">
            Déposée le {new Date(e.created_at).toLocaleDateString("fr-FR")}
          </p>
        </div>
        <Button
          size="sm"
          variant="outline"
          className="rounded-xl"
          onClick={() => void ouvrirFichier(e).catch((err: Error) => toast.error(err.message))}
        >
          <Eye className="size-4" /> Sujet
        </Button>
        {e.corrige_path ? (
          <Button
            size="sm"
            variant="outline"
            className="rounded-xl"
            onClick={() =>
              void ouvrirFichier(e, { corrige: true }).catch((err: Error) =>
                toast.error(err.message),
              )
            }
          >
            <Eye className="size-4" /> Corrigé
          </Button>
        ) : null}
        <Button
          size="sm"
          variant="ghost"
          className="rounded-xl"
          onClick={() => setEdition((v) => !v)}
        >
          <Pencil className="size-4" /> Modifier
        </Button>
      </div>
      {edition ? <ChampsEpreuve meta={meta} onChange={setMeta} /> : null}
      <div className="flex gap-2">
        <Button
          size="sm"
          className="rounded-xl"
          disabled={enCours}
          onClick={() => void decider("publiee")}
        >
          {enCours ? (
            <LoaderCircle className="size-4 animate-spin" />
          ) : (
            <Check className="size-4" />
          )}
          Publier
        </Button>
        <Button
          size="sm"
          variant="outline"
          className="rounded-xl text-destructive"
          disabled={enCours}
          onClick={() => void decider("rejetee")}
        >
          <X className="size-4" /> Refuser
        </Button>
      </div>
    </div>
  );
}

function ActionsPubliee({ epreuve: e, onFait }: { epreuve: EpreuveBanque; onFait: () => void }) {
  const [enCours, setEnCours] = useState(false);
  const depublier = async () => {
    setEnCours(true);
    const { error } = await supabase
      .from("banque_epreuves")
      .update({ statut: "en_attente" })
      .eq("id", e.id);
    setEnCours(false);
    if (error) toast.error(error.message);
    else {
      toast.success("Épreuve retirée de la banque publique (remise en validation).");
      onFait();
    }
  };
  const supprimer = async () => {
    if (!window.confirm(`Supprimer définitivement « ${e.titre} » et ses fichiers ?`)) return;
    setEnCours(true);
    try {
      await supprimerEpreuve(e);
      toast.success("Épreuve supprimée.");
      onFait();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Suppression impossible.");
    } finally {
      setEnCours(false);
    }
  };
  return (
    <>
      <Button
        size="sm"
        variant="ghost"
        className="rounded-xl"
        disabled={enCours}
        onClick={() => void depublier()}
        title="Retirer de la banque publique"
      >
        <Undo2 className="size-4" />
      </Button>
      <Button
        size="sm"
        variant="ghost"
        className="rounded-xl text-destructive"
        disabled={enCours}
        onClick={() => void supprimer()}
        title="Supprimer"
      >
        <Trash2 className="size-4" />
      </Button>
    </>
  );
}
