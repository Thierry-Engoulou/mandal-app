import { createFileRoute, Link } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { useState } from "react";
import { ArrowLeft, Bot, Eye, FileImage, LoaderCircle, Save } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { preCorrigerComposition } from "@/lib/epreuves.functions";
import {
  COMPOSITIONS_BUCKET,
  EPREUVES_BUCKET,
  STATUS_LABELS,
  compositionStatus,
  formatDateTime,
  formatDuree,
  signedUrl,
} from "@/lib/epreuves";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { MathText } from "@/components/math-text";
import { Skeleton } from "@/components/ui/skeleton";

export const Route = createFileRoute("/_authenticated/enseignant/epreuves/$epreuveId")({
  component: TeacherEpreuveCopiesPage,
  head: () => ({
    meta: [{ title: "Copies de l'épreuve — M'Andal" }, { name: "robots", content: "noindex" }],
  }),
});

async function openFile(bucket: string, path: string) {
  try {
    window.open(await signedUrl(bucket, path), "_blank", "noopener");
  } catch (err) {
    toast.error(err instanceof Error ? err.message : "Fichier introuvable.");
  }
}

function TeacherEpreuveCopiesPage() {
  const { epreuveId } = Route.useParams();

  const { data: epreuve, isLoading } = useQuery({
    queryKey: ["epreuve", epreuveId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("epreuves")
        .select("id, titre, matiere, niveau, duree_minutes, fichier_path, consignes, statut")
        .eq("id", epreuveId)
        .maybeSingle();
      if (error) throw new Error(error.message);
      return data;
    },
  });

  const { data: copies = [] } = useQuery({
    queryKey: ["copies-epreuve", epreuveId],
    queryFn: async () => {
      const { data, error } = await supabase.rpc("copies_epreuve", { p_epreuve_id: epreuveId });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
    refetchInterval: 60_000,
  });

  if (isLoading) return <Skeleton className="h-64 rounded-2xl" />;
  if (!epreuve) {
    return (
      <div className="rounded-2xl bg-card p-8 text-center text-sm text-muted-foreground">
        Épreuve introuvable.
      </div>
    );
  }

  const rendues = copies.filter((c) => compositionStatus(c) !== "en_cours").length;

  return (
    <div className="space-y-6">
      <Link
        to="/enseignant/epreuves"
        className="inline-flex items-center gap-1 text-sm text-muted-foreground hover:text-foreground"
      >
        <ArrowLeft className="size-4" /> Mes épreuves
      </Link>
      <header className="rounded-2xl bg-card p-5 shadow-sm">
        <p className="text-xs font-bold uppercase tracking-wide text-primary">
          {epreuve.matiere} · {epreuve.niveau} · {formatDuree(epreuve.duree_minutes)}
        </p>
        <h1 className="font-display text-2xl font-bold text-foreground">{epreuve.titre}</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          {copies.length} élève(s) ont commencé · {rendues} copie(s) rendue(s) ou transmise(s)
        </p>
        <Button
          variant="outline"
          size="sm"
          className="mt-3 rounded-xl"
          onClick={() => openFile(EPREUVES_BUCKET, epreuve.fichier_path)}
        >
          <Eye className="size-4" /> Voir le sujet
        </Button>
      </header>

      {copies.length === 0 ? (
        <p className="rounded-2xl border border-dashed border-border p-8 text-center text-sm text-muted-foreground">
          Aucun élève n'a encore commencé cette épreuve.
        </p>
      ) : (
        copies.map((c) => <CopieCard key={c.id} copie={c} epreuveId={epreuveId} />)
      )}
    </div>
  );
}

type Copie = {
  id: string;
  eleve_nom: string;
  debut_at: string;
  fin_prevue_at: string;
  rendu_at: string | null;
  rendu_auto: boolean;
  fichiers: string[];
  note: number | null;
  commentaire: string | null;
  a_correction_ia: boolean;
};

function CopieCard({ copie, epreuveId }: { copie: Copie; epreuveId: string }) {
  const queryClient = useQueryClient();
  const preCorriger = useServerFn(preCorrigerComposition);
  const [note, setNote] = useState(copie.note === null ? "" : String(copie.note));
  const [commentaire, setCommentaire] = useState(copie.commentaire ?? "");
  const [saving, setSaving] = useState(false);
  const [iaBusy, setIaBusy] = useState(false);
  const [showIa, setShowIa] = useState(false);
  const status = compositionStatus(copie);

  const { data: correctionIa } = useQuery({
    enabled: showIa && copie.a_correction_ia,
    queryKey: ["correction-ia-composition", copie.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("compositions_correction_ia")
        .select("texte")
        .eq("composition_id", copie.id)
        .maybeSingle();
      if (error) throw new Error(error.message);
      return data?.texte ?? null;
    },
  });

  const save = async () => {
    const value = note.trim() === "" ? null : Number(note.replace(",", "."));
    if (value !== null && (!Number.isFinite(value) || value < 0 || value > 20)) {
      toast.error("La note doit être comprise entre 0 et 20.");
      return;
    }
    setSaving(true);
    const { error } = await supabase.rpc("noter_composition", {
      p_composition_id: copie.id,
      p_note: value,
      p_commentaire: commentaire,
    });
    setSaving(false);
    if (error) {
      toast.error(error.message);
      return;
    }
    toast.success(
      value === null ? "Commentaire enregistré." : "Note enregistrée : l'élève la voit.",
    );
    await queryClient.invalidateQueries({ queryKey: ["copies-epreuve", epreuveId] });
  };

  const runIa = async () => {
    setIaBusy(true);
    try {
      const res = await preCorriger({ data: { compositionId: copie.id } });
      queryClient.setQueryData(["correction-ia-composition", copie.id], res.texte);
      setShowIa(true);
      await queryClient.invalidateQueries({ queryKey: ["copies-epreuve", epreuveId] });
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "La pré-correction a échoué.");
    } finally {
      setIaBusy(false);
    }
  };

  return (
    <div className="space-y-3 rounded-2xl bg-card p-4 shadow-sm">
      <div className="flex flex-wrap items-start justify-between gap-2">
        <div>
          <p className="font-semibold text-foreground">{copie.eleve_nom}</p>
          <p className="text-xs text-muted-foreground">
            Commencée le {formatDateTime(copie.debut_at)}
            {copie.rendu_at ? ` · rendue le ${formatDateTime(copie.rendu_at)}` : ""}
          </p>
        </div>
        <span className="rounded-full bg-secondary px-2.5 py-0.5 text-xs font-semibold text-muted-foreground">
          {STATUS_LABELS[status]}
        </span>
      </div>

      {copie.fichiers.length === 0 ? (
        <p className="text-sm text-muted-foreground">Aucune page envoyée.</p>
      ) : (
        <div className="flex flex-wrap gap-2">
          {copie.fichiers.map((path, i) => (
            <Button
              key={path}
              size="sm"
              variant="outline"
              className="rounded-xl"
              onClick={() => openFile(COMPOSITIONS_BUCKET, path)}
            >
              <FileImage className="size-4" /> Page {i + 1}
            </Button>
          ))}
        </div>
      )}

      <div className="grid gap-3 md:grid-cols-[120px_1fr_auto] md:items-start">
        <Input
          value={note}
          onChange={(e) => setNote(e.target.value)}
          placeholder="Note /20"
          inputMode="decimal"
          aria-label="Note sur 20"
        />
        <Textarea
          value={commentaire}
          onChange={(e) => setCommentaire(e.target.value)}
          rows={2}
          placeholder="Commentaire pour l'élève"
        />
        <Button onClick={save} disabled={saving} className="rounded-xl">
          {saving ? <LoaderCircle className="animate-spin" /> : <Save className="size-4" />}
          Enregistrer
        </Button>
      </div>

      <div className="flex flex-wrap gap-2">
        <Button
          size="sm"
          variant="secondary"
          className="rounded-xl"
          onClick={runIa}
          disabled={iaBusy || copie.fichiers.length === 0}
        >
          {iaBusy ? <LoaderCircle className="animate-spin" /> : <Bot className="size-4" />}
          {copie.a_correction_ia ? "Relancer la pré-correction IA" : "Pré-corriger avec Mandal IA"}
        </Button>
        {copie.a_correction_ia ? (
          <Button
            size="sm"
            variant="ghost"
            className="rounded-xl"
            onClick={() => setShowIa((v) => !v)}
          >
            {showIa ? "Masquer la proposition" : "Voir la proposition de l'IA"}
          </Button>
        ) : null}
      </div>
      {showIa && correctionIa ? (
        <div className="rounded-xl border border-border bg-secondary/40 p-4">
          <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            Proposition de Mandal IA (visible par vous seul)
          </p>
          <MathText text={correctionIa} className="text-sm leading-relaxed text-foreground" />
        </div>
      ) : null}
    </div>
  );
}
