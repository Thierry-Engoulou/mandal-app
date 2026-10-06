import { createFileRoute } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { FileAudio, FileText, Film, Loader2, Upload } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { useSelectedSchool, useTeacherValidation } from "@/lib/use-teacher";
import { TeacherPendingBanner } from "@/components/teacher-pending-banner";
import { TeacherStatusBadge } from "@/components/teacher-status-badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

export const Route = createFileRoute("/_authenticated/enseignant/mediatheque")({
  component: TeacherMediaPage,
  head: () => ({
    meta: [
      { title: "Médiathèque — M'Andal" },
      { name: "description", content: "Déposez vos ressources pédagogiques sur M'Andal." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

type ResourceType = "video" | "audio" | "document";

const TYPE_ICON = { video: Film, audio: FileAudio, document: FileText } as const;
const TYPE_LABEL = { video: "Vidéo", audio: "Audio", document: "Document" } as const;
const ACCEPT = { video: "video/*", audio: "audio/*", document: ".pdf,.doc,.docx,.txt,.md,.ppt,.pptx" };

function TeacherMediaPage() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();
  const { school, schoolId } = useSelectedSchool();
  const { data: validation } = useTeacherValidation(schoolId);
  const canWrite = true; // accès immédiat après inscription

  const [titre, setTitre] = useState("");
  const [description, setDescription] = useState("");
  const [type, setType] = useState<ResourceType>("document");
  const [matiereId, setMatiereId] = useState<string>("");
  const [xp, setXp] = useState("10");
  const [file, setFile] = useState<File | null>(null);
  const [busy, setBusy] = useState(false);

  const { data: matieres = [] } = useQuery({
    queryKey: ["matieres"],
    queryFn: async () => {
      const { data, error } = await supabase.from("matieres").select("id, nom").order("nom");
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  const { data: resources = [] } = useQuery({
    enabled: !!profile,
    queryKey: ["mes-ressources", profile?.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("ressources_mediatheque")
        .select("id, titre, type, statut_validation, xp_valeur, created_at, matieres(nom)")
        .eq("uploaded_by", profile!.id)
        .order("created_at", { ascending: false });
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!profile || !canWrite) return;
    if (!file) {
      toast.error("Choisissez un fichier à déposer.");
      return;
    }
    if (!schoolId) {
      toast.error("Aucun établissement sélectionné.");
      return;
    }

    setBusy(true);
    // La ressource est créée en attente : le fichier va dans le bucket de validation.
    const safeName = file.name.replace(/[^\w.-]+/g, "-");
    const path = `${schoolId}/${profile.id}/${Date.now()}-${safeName}`;
    const { error: upErr } = await supabase.storage
      .from("contenus-en-attente")
      .upload(path, file, { upsert: false });
    if (upErr) {
      setBusy(false);
      toast.error(upErr.message);
      return;
    }

    const { error } = await supabase.from("ressources_mediatheque").insert({
      etablissement_id: schoolId,
      titre: titre.trim(),
      description: description.trim() || null,
      type,
      url_storage: `contenus-en-attente/${path}`,
      matiere_id: matiereId || null,
      xp_valeur: Number(xp) || 0,
      statut_validation: "en_attente",
      uploaded_by: profile.id,
    });
    setBusy(false);
    if (error) {
      toast.error(error.message);
      return;
    }

    toast.success("Ressource envoyée pour validation");
    setTitre("");
    setDescription("");
    setMatiereId("");
    setXp("10");
    setFile(null);
    await queryClient.invalidateQueries({ queryKey: ["mes-ressources"] });
  };

  return (
    <div className="space-y-6">
      <header>
        <h1 className="font-display text-2xl font-bold tracking-tight text-foreground">
          Médiathèque
        </h1>
        <p className="text-sm text-muted-foreground">
          Déposez une ressource : elle sera visible après validation par votre chef
          d'établissement.
        </p>
      </header>

      <TeacherPendingBanner statut={validation?.statut} />

      <section className="rounded-2xl bg-card p-6 shadow-sm">
        <h2 className="font-display text-lg font-bold text-foreground">Nouvelle ressource</h2>
        <form onSubmit={submit} className="mt-5 grid gap-4 sm:grid-cols-2">
          <div className="space-y-2 sm:col-span-2">
            <Label htmlFor="titre">Titre</Label>
            <Input
              id="titre"
              value={titre}
              onChange={(e) => setTitre(e.target.value)}
              required
              disabled={!canWrite}
              className="rounded-xl"
              placeholder="Cours sur les fonctions affines"
            />
          </div>
          <div className="space-y-2 sm:col-span-2">
            <Label htmlFor="desc">Description</Label>
            <Textarea
              id="desc"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              disabled={!canWrite}
              className="rounded-xl"
              rows={3}
            />
          </div>
          <div className="space-y-2">
            <Label>Type</Label>
            <Select
              value={type}
              onValueChange={(v) => setType(v as ResourceType)}
              disabled={!canWrite}
            >
              <SelectTrigger className="rounded-xl">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="video">Vidéo</SelectItem>
                <SelectItem value="audio">Audio</SelectItem>
                <SelectItem value="document">Document</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label>Matière</Label>
            <Select value={matiereId} onValueChange={setMatiereId} disabled={!canWrite}>
              <SelectTrigger className="rounded-xl">
                <SelectValue placeholder="Choisir une matière" />
              </SelectTrigger>
              <SelectContent>
                {matieres.map((m) => (
                  <SelectItem key={m.id} value={m.id}>
                    {m.nom}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="xp">Valeur XP</Label>
            <Input
              id="xp"
              type="number"
              min={0}
              value={xp}
              onChange={(e) => setXp(e.target.value)}
              disabled={!canWrite}
              className="rounded-xl"
            />
          </div>
          <div className="space-y-2">
            <Label htmlFor="fichier">Fichier</Label>
            <Input
              id="fichier"
              type="file"
              accept={ACCEPT[type]}
              disabled={!canWrite}
              onChange={(e) => setFile(e.target.files?.[0] ?? null)}
              className="rounded-xl"
            />
          </div>
          <div className="sm:col-span-2">
            <Button
              type="submit"
              disabled={!canWrite || busy || !school}
              className="rounded-xl bg-success text-success-foreground hover:bg-success/90"
            >
              {busy ? <Loader2 className="size-4 animate-spin" /> : <Upload className="size-4" />}
              Envoyer pour validation
            </Button>
          </div>
        </form>
      </section>

      <section className="rounded-2xl bg-card p-6 shadow-sm">
        <h2 className="font-display text-lg font-bold text-foreground">Mes dépôts</h2>
        {resources.length === 0 ? (
          <p className="mt-2 text-sm text-muted-foreground">Aucune ressource déposée.</p>
        ) : (
          <ul className="mt-4 divide-y">
            {resources.map((r) => {
              const Icon = TYPE_ICON[r.type as ResourceType] ?? FileText;
              const matiere = (r.matieres as unknown as { nom: string } | null)?.nom;
              return (
                <li key={r.id} className="flex items-center justify-between gap-4 py-3">
                  <div className="flex items-center gap-3">
                    <div className="flex size-9 items-center justify-center rounded-xl bg-secondary text-muted-foreground">
                      <Icon className="size-4" />
                    </div>
                    <div>
                      <p className="font-medium text-foreground">{r.titre}</p>
                      <p className="text-xs text-muted-foreground">
                        {TYPE_LABEL[r.type as ResourceType]}
                        {matiere ? ` · ${matiere}` : ""} · {r.xp_valeur} XP
                      </p>
                    </div>
                  </div>
                  <TeacherStatusBadge status={r.statut_validation} />
                </li>
              );
            })}
          </ul>
        )}
      </section>
    </div>
  );
}
