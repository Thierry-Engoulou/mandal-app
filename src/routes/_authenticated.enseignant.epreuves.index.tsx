import { createFileRoute, Link } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useRef, useState } from "react";
import { Archive, Eye, FileUp, LoaderCircle, Send, Trash2, Users } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { useSelectedSchool, useTeacherClasses } from "@/lib/use-teacher";
import {
  EPREUVES_BUCKET,
  MATIERES,
  NIVEAUX,
  formatDateTime,
  formatDuree,
  signedUrl,
} from "@/lib/epreuves";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";

export const Route = createFileRoute("/_authenticated/enseignant/epreuves/")({
  component: TeacherEpreuvesPage,
  head: () => ({
    meta: [
      { title: "Épreuves — Espace enseignant M'Andal" },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const STATUT_LABEL: Record<string, string> = {
  brouillon: "Brouillon",
  publiee: "Publiée",
  archivee: "Archivée",
};

const selectClass = "w-full rounded-xl border border-border bg-background px-3 py-2.5 text-sm";

function TeacherEpreuvesPage() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();
  const { schoolId } = useSelectedSchool();
  const { data: classes = [] } = useTeacherClasses(schoolId);

  const [titre, setTitre] = useState("");
  const [matiere, setMatiere] = useState(MATIERES[0]!);
  const [niveau, setNiveau] = useState<string>(NIVEAUX[5]);
  const [classeId, setClasseId] = useState("");
  const [duree, setDuree] = useState("120");
  const [dateDebut, setDateDebut] = useState("");
  const [dateFin, setDateFin] = useState("");
  const [consignes, setConsignes] = useState("");
  const [publier, setPublier] = useState(true);
  const [file, setFile] = useState<File | null>(null);
  const [busy, setBusy] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);

  const { data: epreuves = [], isLoading } = useQuery({
    enabled: !!profile,
    queryKey: ["mes-epreuves", profile?.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("epreuves")
        .select(
          "id, titre, matiere, niveau, duree_minutes, date_debut, date_fin, statut, fichier_path, created_at, classes(nom), compositions(count)",
        )
        .eq("enseignant_id", profile!.id)
        .order("created_at", { ascending: false });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  const refresh = () => queryClient.invalidateQueries({ queryKey: ["mes-epreuves"] });

  const reset = () => {
    setTitre("");
    setConsignes("");
    setDateDebut("");
    setDateFin("");
    setFile(null);
    if (fileRef.current) fileRef.current.value = "";
  };

  const create = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!profile || busy) return;
    const minutes = Number(duree);
    if (!titre.trim()) {
      toast.error("Donnez un titre à l'épreuve.");
      return;
    }
    if (!file) {
      toast.error("Ajoutez le sujet (PDF ou image).");
      return;
    }
    if (!Number.isFinite(minutes) || minutes < 5 || minutes > 600) {
      toast.error("La durée doit être comprise entre 5 et 600 minutes.");
      return;
    }
    if (dateDebut && dateFin && new Date(dateFin) <= new Date(dateDebut)) {
      toast.error("La date de fin doit être après la date de début.");
      return;
    }

    setBusy(true);
    try {
      const safeName = file.name.replace(/[^\w.-]+/g, "_").slice(-80);
      const path = `${profile.id}/${Date.now()}-${safeName}`;
      const { error: upError } = await supabase.storage
        .from(EPREUVES_BUCKET)
        .upload(path, file, file.type ? { contentType: file.type } : {});
      if (upError) throw new Error(upError.message);

      const { error } = await supabase.from("epreuves").insert({
        enseignant_id: profile.id,
        titre: titre.trim(),
        matiere,
        niveau,
        classe_id: classeId || null,
        consignes: consignes.trim() || null,
        fichier_path: path,
        duree_minutes: minutes,
        date_debut: dateDebut ? new Date(dateDebut).toISOString() : null,
        date_fin: dateFin ? new Date(dateFin).toISOString() : null,
        statut: publier ? "publiee" : "brouillon",
      });
      if (error) {
        await supabase.storage.from(EPREUVES_BUCKET).remove([path]);
        throw new Error(error.message);
      }
      toast.success(
        publier ? "Épreuve publiée : les élèves peuvent composer." : "Brouillon enregistré.",
      );
      reset();
      await refresh();
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Échec de l'enregistrement.");
    } finally {
      setBusy(false);
    }
  };

  const setStatut = async (id: string, statut: string) => {
    const { error } = await supabase.from("epreuves").update({ statut }).eq("id", id);
    if (error) toast.error(error.message);
    await refresh();
  };

  const remove = async (id: string, path: string, copies: number) => {
    const msg =
      copies > 0
        ? `Supprimer cette épreuve et les ${copies} copie(s) déjà rendues ? C'est définitif.`
        : "Supprimer cette épreuve ?";
    if (!confirm(msg)) return;
    const { error } = await supabase.from("epreuves").delete().eq("id", id);
    if (error) {
      toast.error(error.message);
      return;
    }
    await supabase.storage.from(EPREUVES_BUCKET).remove([path]);
    await refresh();
  };

  const openSujet = async (path: string) => {
    try {
      window.open(await signedUrl(EPREUVES_BUCKET, path), "_blank", "noopener");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Sujet introuvable.");
    }
  };

  return (
    <div className="space-y-6">
      <header>
        <h1 className="font-display text-2xl font-bold text-foreground">Épreuves</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Chargez un sujet en PDF : les élèves du niveau (ou de la classe choisie) le composent en
          temps limité et vous envoient leur copie en photos ou en scan.
        </p>
      </header>

      <form onSubmit={create} className="space-y-4 rounded-2xl bg-card p-5 shadow-sm">
        <h2 className="font-display text-lg font-bold text-foreground">Nouvelle épreuve</h2>
        <div className="grid gap-4 md:grid-cols-2">
          <div className="space-y-2 md:col-span-2">
            <Label htmlFor="ep-titre">Titre</Label>
            <Input
              id="ep-titre"
              value={titre}
              onChange={(e) => setTitre(e.target.value)}
              placeholder="Ex. : Devoir surveillé n°2 — Fonctions numériques"
              maxLength={200}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="ep-matiere">Matière</Label>
            <select
              id="ep-matiere"
              value={matiere}
              onChange={(e) => setMatiere(e.target.value)}
              className={selectClass}
            >
              {MATIERES.map((m) => (
                <option key={m}>{m}</option>
              ))}
            </select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="ep-niveau">Niveau</Label>
            <select
              id="ep-niveau"
              value={niveau}
              onChange={(e) => setNiveau(e.target.value)}
              className={selectClass}
            >
              {NIVEAUX.map((n) => (
                <option key={n}>{n}</option>
              ))}
            </select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="ep-classe">Élèves concernés</Label>
            <select
              id="ep-classe"
              value={classeId}
              onChange={(e) => setClasseId(e.target.value)}
              className={selectClass}
            >
              <option value="">Tous les élèves de ce niveau</option>
              {classes.map((c) => (
                <option key={c.id} value={c.id}>
                  Seulement la classe {c.nom}
                </option>
              ))}
            </select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="ep-duree">Durée (minutes)</Label>
            <Input
              id="ep-duree"
              type="number"
              min={5}
              max={600}
              value={duree}
              onChange={(e) => setDuree(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="ep-debut">Ouverture (facultatif)</Label>
            <Input
              id="ep-debut"
              type="datetime-local"
              value={dateDebut}
              onChange={(e) => setDateDebut(e.target.value)}
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="ep-fin">Clôture (facultatif)</Label>
            <Input
              id="ep-fin"
              type="datetime-local"
              value={dateFin}
              onChange={(e) => setDateFin(e.target.value)}
            />
          </div>
          <div className="space-y-2 md:col-span-2">
            <Label htmlFor="ep-consignes">Consignes (facultatif)</Label>
            <Textarea
              id="ep-consignes"
              value={consignes}
              onChange={(e) => setConsignes(e.target.value)}
              rows={3}
              placeholder="Ex. : Calculatrice autorisée. Traitez les exercices dans l'ordre de votre choix."
            />
          </div>
          <div className="space-y-2 md:col-span-2">
            <Label htmlFor="ep-fichier">Sujet (PDF ou image)</Label>
            <input
              id="ep-fichier"
              ref={fileRef}
              type="file"
              accept="application/pdf,image/*"
              onChange={(e) => setFile(e.target.files?.[0] ?? null)}
              className="block w-full text-sm file:mr-3 file:rounded-lg file:border-0 file:bg-primary/10 file:px-3 file:py-2 file:text-primary"
            />
          </div>
        </div>
        <label className="flex items-center gap-2 text-sm text-foreground">
          <input type="checkbox" checked={publier} onChange={(e) => setPublier(e.target.checked)} />
          Publier tout de suite (sinon : brouillon invisible des élèves)
        </label>
        <p className="text-xs text-muted-foreground">
          Le chronomètre démarre quand l'élève commence. Il reçoit des rappels à 30, 10 et 5 minutes
          de la fin pour envoyer ses pages, puis dispose de 15 minutes pour numériser ce qu'il a
          fait : tout ce qu'il a envoyé vous est transmis, même s'il n'a pas fini.
        </p>
        <Button type="submit" disabled={busy} className="rounded-xl">
          {busy ? <LoaderCircle className="animate-spin" /> : <FileUp className="size-4" />}
          {publier ? "Publier l'épreuve" : "Enregistrer le brouillon"}
        </Button>
      </form>

      <section className="space-y-3">
        <h2 className="font-display text-lg font-bold text-foreground">Mes épreuves</h2>
        {isLoading ? (
          <p className="text-sm text-muted-foreground">Chargement…</p>
        ) : epreuves.length === 0 ? (
          <p className="rounded-2xl border border-dashed border-border p-8 text-center text-sm text-muted-foreground">
            Aucune épreuve pour l'instant.
          </p>
        ) : (
          epreuves.map((ep) => {
            const copies = ep.compositions?.[0]?.count ?? 0;
            const classe = Array.isArray(ep.classes) ? ep.classes[0] : ep.classes;
            return (
              <div key={ep.id} className="rounded-2xl bg-card p-4 shadow-sm">
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <div className="min-w-0">
                    <p className="text-xs font-bold uppercase tracking-wide text-primary">
                      {ep.matiere} · {ep.niveau}
                      {classe ? ` · ${classe.nom}` : ""}
                    </p>
                    <p className="font-semibold text-foreground">{ep.titre}</p>
                    <p className="mt-1 text-xs text-muted-foreground">
                      {formatDuree(ep.duree_minutes)}
                      {ep.date_debut ? ` · ouvre ${formatDateTime(ep.date_debut)}` : ""}
                      {ep.date_fin ? ` · clôture ${formatDateTime(ep.date_fin)}` : ""}
                    </p>
                  </div>
                  <span className="rounded-full bg-secondary px-2.5 py-0.5 text-xs font-semibold text-muted-foreground">
                    {STATUT_LABEL[ep.statut] ?? ep.statut}
                  </span>
                </div>
                <div className="mt-3 flex flex-wrap gap-2">
                  <Button asChild size="sm" className="rounded-xl">
                    <Link to="/enseignant/epreuves/$epreuveId" params={{ epreuveId: ep.id }}>
                      <Users className="size-4" /> Copies ({copies})
                    </Link>
                  </Button>
                  <Button
                    size="sm"
                    variant="outline"
                    className="rounded-xl"
                    onClick={() => openSujet(ep.fichier_path)}
                  >
                    <Eye className="size-4" /> Sujet
                  </Button>
                  {ep.statut !== "publiee" ? (
                    <Button
                      size="sm"
                      variant="outline"
                      className="rounded-xl"
                      onClick={() => setStatut(ep.id, "publiee")}
                    >
                      <Send className="size-4" /> Publier
                    </Button>
                  ) : (
                    <Button
                      size="sm"
                      variant="outline"
                      className="rounded-xl"
                      onClick={() => setStatut(ep.id, "archivee")}
                    >
                      <Archive className="size-4" /> Archiver
                    </Button>
                  )}
                  <Button
                    size="sm"
                    variant="ghost"
                    className="rounded-xl text-destructive"
                    onClick={() => remove(ep.id, ep.fichier_path, copies)}
                  >
                    <Trash2 className="size-4" /> Supprimer
                  </Button>
                </div>
              </div>
            );
          })
        )}
      </section>
    </div>
  );
}
