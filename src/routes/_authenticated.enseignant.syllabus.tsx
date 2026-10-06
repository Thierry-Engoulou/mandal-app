import { createFileRoute } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { ChevronDown, ChevronUp, ListChecks, Pencil, Plus, Trash2, Upload } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useSelectedSchool, useTeacherClasses, useTeacherValidation } from "@/lib/use-teacher";
import { useProfile } from "@/lib/use-profile";
import {
  CONCEPT_TYPES,
  type ConceptType,
  bucketForType,
  conceptTypeLabel,
  GRAPHIQUE_SPEC_PLACEHOLDER,
} from "@/lib/concept-content";
import { FunctionGraph } from "@/components/function-graph";
import { TeacherPendingBanner } from "@/components/teacher-pending-banner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

export const Route = createFileRoute("/_authenticated/enseignant/syllabus")({
  component: TeacherSyllabusPage,
  head: () => ({
    meta: [
      { title: "Création de cours — M'Andal" },
      {
        name: "description",
        content: "Créez vos cours, modules et leçons (texte, vidéo, PDF, quiz) sur M'Andal.",
      },
      { name: "robots", content: "noindex" },
    ],
  }),
});

type Chapitre = { id: string; titre: string; ordre: number; niveau: string | null };
type Concept = {
  id: string;
  chapitre_id: string;
  titre: string;
  ordre: number;
  type_contenu: string;
  contenu_texte: string | null;
  media_url: string | null;
  duree_minutes: number | null;
};

const emptyConcept = {
  titre: "",
  type_contenu: "texte" as ConceptType,
  contenu_texte: "",
  media_url: "",
  duree_minutes: "",
};

function TeacherSyllabusPage() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();
  const { schoolId } = useSelectedSchool();
  const { data: classes = [] } = useTeacherClasses(schoolId);
  const { data: validation } = useTeacherValidation(schoolId);
  const canWrite = true; // accès immédiat après inscription

  const classIds = classes.map((c) => c.id);
  const [activeProgramme, setActiveProgramme] = useState<string | null>(null);
  const [openProgramme, setOpenProgramme] = useState(false);
  const [expanded, setExpanded] = useState<string | null>(null);

  const [form, setForm] = useState({ description: "", classeId: "", matiereId: "" });
  const [newChapitre, setNewChapitre] = useState({ titre: "", niveau: "" });

  const [conceptDialog, setConceptDialog] = useState<{
    chapitreId: string;
    conceptId: string | null;
  } | null>(null);
  const [conceptForm, setConceptForm] = useState(emptyConcept);
  const [uploading, setUploading] = useState(false);
  const [saving, setSaving] = useState(false);

  const { data: matieres = [] } = useQuery({
    queryKey: ["matieres"],
    queryFn: async () => {
      const { data, error } = await supabase.from("matieres").select("id, nom").order("nom");
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  const { data: programmes = [] } = useQuery({
    enabled: classIds.length > 0,
    queryKey: ["enseignant-programmes", classIds],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("programmes")
        .select("id, titre, description, classe_id, matiere_id, matieres(nom)")
        .in("classe_id", classIds)
        .order("titre");
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  useEffect(() => {
    if (!activeProgramme && programmes.length > 0) setActiveProgramme(programmes[0]!.id);
  }, [programmes, activeProgramme]);

  const { data: chapitres = [] } = useQuery({
    enabled: !!activeProgramme,
    queryKey: ["chapitres", activeProgramme],
    queryFn: async (): Promise<Chapitre[]> => {
      const { data, error } = await supabase
        .from("chapitres")
        .select("id, titre, ordre, niveau")
        .eq("programme_id", activeProgramme!)
        .order("ordre");
      if (error) throw new Error(error.message);
      return (data ?? []) as Chapitre[];
    },
  });

  const chapitreIds = chapitres.map((c) => c.id);

  const { data: concepts = [] } = useQuery({
    enabled: chapitreIds.length > 0,
    queryKey: ["concepts", chapitreIds],
    queryFn: async (): Promise<Concept[]> => {
      const { data, error } = await supabase
        .from("concepts")
        .select("id, chapitre_id, titre, ordre, type_contenu, contenu_texte, media_url, duree_minutes")
        .in("chapitre_id", chapitreIds)
        .order("ordre");
      if (error) throw new Error(error.message);
      return (data ?? []) as Concept[];
    },
  });

  const refreshChapitres = () =>
    Promise.all([
      queryClient.invalidateQueries({ queryKey: ["chapitres"] }),
      queryClient.invalidateQueries({ queryKey: ["concepts"] }),
    ]);

  const matiereNom = matieres.find((m) => m.id === form.matiereId)?.nom ?? "";
  const classeNom = classes.find((c) => c.id === form.classeId)?.nom ?? "";
  const autoTitre = matiereNom && classeNom ? `${matiereNom} — ${classeNom}` : "";

  const createProgramme = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!profile || !canWrite) return;
    if (!form.classeId || !form.matiereId) {
      toast.error("Choisissez une classe et une matière.");
      return;
    }
    const etablissementId =
      classes.find((c) => c.id === form.classeId)?.etablissement_id ??
      schoolId ??
      profile.etablissement_id;
    if (!etablissementId) {
      toast.error("Aucun établissement rattaché à votre compte.");
      return;
    }
    const { data, error } = await supabase
      .from("programmes")
      .insert({
        titre: autoTitre,
        description: form.description.trim() || null,
        classe_id: form.classeId,
        matiere_id: form.matiereId,
        etablissement_id: etablissementId,
      })
      .select("id")
      .single();
    if (error) {
      toast.error(error.message);
      return;
    }
    toast.success("Cours créé");
    setOpenProgramme(false);
    setForm({ description: "", classeId: "", matiereId: "" });
    setActiveProgramme(data.id);
    await queryClient.invalidateQueries({ queryKey: ["enseignant-programmes"] });
  };

  const addChapitre = async () => {
    if (!activeProgramme || !newChapitre.titre.trim() || !canWrite) return;
    const { error } = await supabase.from("chapitres").insert({
      programme_id: activeProgramme,
      titre: newChapitre.titre.trim(),
      niveau: newChapitre.niveau.trim() || null,
      ordre: chapitres.length,
    });
    if (error) {
      toast.error(error.message);
      return;
    }
    setNewChapitre({ titre: "", niveau: "" });
    await refreshChapitres();
  };

  const openConcept = (chapitreId: string, concept?: Concept) => {
    setConceptDialog({ chapitreId, conceptId: concept?.id ?? null });
    setConceptForm(
      concept
        ? {
            titre: concept.titre,
            type_contenu: (concept.type_contenu ?? "texte") as ConceptType,
            contenu_texte: concept.contenu_texte ?? "",
            media_url: concept.media_url ?? "",
            duree_minutes: concept.duree_minutes ? String(concept.duree_minutes) : "",
          }
        : emptyConcept,
    );
  };

  const uploadMedia = async (file: File) => {
    if (!profile) return;
    const bucket = bucketForType(conceptForm.type_contenu);
    const path = `${profile.id}/${Date.now()}-${file.name.replace(/[^\w.-]+/g, "_")}`;
    setUploading(true);
    const { error } = await supabase.storage.from(bucket).upload(path, file);
    setUploading(false);
    if (error) {
      toast.error(error.message);
      return;
    }
    const { data } = supabase.storage.from(bucket).getPublicUrl(path);
    setConceptForm((f) => ({ ...f, media_url: data.publicUrl }));
    toast.success("Fichier importé");
  };

  const saveConcept = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!conceptDialog || !conceptForm.titre.trim() || !canWrite) return;
    setSaving(true);
    const payload = {
      titre: conceptForm.titre.trim(),
      type_contenu: conceptForm.type_contenu,
      contenu_texte: conceptForm.contenu_texte.trim() || null,
      media_url: conceptForm.media_url.trim() || null,
      duree_minutes: conceptForm.duree_minutes ? Number(conceptForm.duree_minutes) : null,
    };
    const { conceptId, chapitreId } = conceptDialog;
    const { error } = conceptId
      ? await supabase.from("concepts").update(payload).eq("id", conceptId)
      : await supabase.from("concepts").insert({
          ...payload,
          chapitre_id: chapitreId,
          ordre: concepts.filter((c) => c.chapitre_id === chapitreId).length,
        });
    setSaving(false);
    if (error) {
      toast.error(error.message);
      return;
    }
    setConceptDialog(null);
    setConceptForm(emptyConcept);
    await refreshChapitres();
  };

  const move = async (
    table: "chapitres" | "concepts",
    list: { id: string; ordre: number }[],
    index: number,
    dir: -1 | 1,
  ) => {
    const target = index + dir;
    if (target < 0 || target >= list.length || !canWrite) return;
    const a = list[index]!;
    const b = list[target]!;
    await supabase.from(table).update({ ordre: b.ordre }).eq("id", a.id);
    await supabase.from(table).update({ ordre: a.ordre }).eq("id", b.id);
    await refreshChapitres();
  };

  const remove = async (table: "chapitres" | "concepts", id: string) => {
    if (!canWrite) return;
    const { error } = await supabase.from(table).delete().eq("id", id);
    if (error) {
      toast.error(error.message);
      return;
    }
    await refreshChapitres();
  };

  const programme = programmes.find((p) => p.id === activeProgramme) ?? null;
  const needsMedia =
    conceptForm.type_contenu === "video" ||
    conceptForm.type_contenu === "pdf" ||
    conceptForm.type_contenu === "simulation";
  const isGraphique = conceptForm.type_contenu === "graphique";

  return (
    <div className="space-y-6">
      <header className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-bold tracking-tight text-foreground">
            Création de cours
          </h1>
          <p className="text-sm text-muted-foreground">Cours, modules et leçons.</p>
        </div>
        <Button
          onClick={() => setOpenProgramme(true)}
          disabled={classes.length === 0}
          className="rounded-xl bg-success text-success-foreground hover:bg-success/90"
        >
          <Plus className="size-4" /> Créer un cours
        </Button>
      </header>

      <TeacherPendingBanner statut={validation?.statut} />

      <div className="grid gap-4 lg:grid-cols-[300px_1fr]">
        <aside className="rounded-2xl bg-card p-4 shadow-sm">
          <p className="px-2 pb-2 text-xs font-semibold uppercase tracking-wide text-muted-foreground">
            Cours
          </p>
          {programmes.length === 0 ? (
            <p className="px-2 py-3 text-sm text-muted-foreground">Aucun cours.</p>
          ) : (
            <ul className="space-y-1">
              {programmes.map((p) => (
                <li key={p.id}>
                  <button
                    onClick={() => setActiveProgramme(p.id)}
                    className={`w-full rounded-xl px-3 py-2 text-left text-sm ${
                      activeProgramme === p.id ? "bg-success/10 text-success" : "hover:bg-secondary"
                    }`}
                  >
                    <span className="block truncate font-medium">{p.titre}</span>
                    <span className="block truncate text-xs text-muted-foreground">
                      {(p.matieres as unknown as { nom: string } | null)?.nom ?? "Sans matière"} ·{" "}
                      {classes.find((c) => c.id === p.classe_id)?.nom ?? "—"}
                    </span>
                  </button>
                </li>
              ))}
            </ul>
          )}
        </aside>

        <section className="rounded-2xl bg-card p-6 shadow-sm">
          {!programme ? (
            <div className="py-10 text-center">
              <ListChecks className="mx-auto size-6 text-muted-foreground" />
              <p className="mt-3 text-sm text-muted-foreground">
                Créez un cours pour commencer.
              </p>
            </div>
          ) : (
            <>
              <h2 className="font-display text-lg font-bold text-foreground">{programme.titre}</h2>
              {programme.description ? (
                <p className="mt-1 text-sm text-muted-foreground">{programme.description}</p>
              ) : null}

              <div className="mt-5 grid gap-2 sm:grid-cols-[1fr_180px_auto]">
                <Input
                  value={newChapitre.titre}
                  onChange={(e) => setNewChapitre({ ...newChapitre, titre: e.target.value })}
                  placeholder="Nouveau module"
                  className="rounded-xl"
                />
                <Input
                  value={newChapitre.niveau}
                  onChange={(e) => setNewChapitre({ ...newChapitre, niveau: e.target.value })}
                  placeholder="Niveau (ex. Débutant)"
                  className="rounded-xl"
                />
                <Button
                  onClick={addChapitre}
                  className="shrink-0 rounded-xl bg-success text-success-foreground hover:bg-success/90"
                >
                  <Plus className="size-4" /> Ajouter
                </Button>
              </div>

              <ul className="mt-5 space-y-3">
                {chapitres.length === 0 ? (
                  <li className="text-sm text-muted-foreground">Aucun module.</li>
                ) : (
                  chapitres.map((ch, i) => {
                    const items = concepts.filter((c) => c.chapitre_id === ch.id);
                    const isOpen = expanded === ch.id;
                    return (
                      <li key={ch.id} className="rounded-xl border border-border p-4">
                        <div className="flex items-center justify-between gap-3">
                          <button
                            className="flex-1 text-left font-medium text-foreground"
                            onClick={() => setExpanded(isOpen ? null : ch.id)}
                          >
                            {i + 1}. {ch.titre}
                            {ch.niveau ? (
                              <span className="ml-2 rounded-full bg-secondary px-2 py-0.5 text-xs text-muted-foreground">
                                {ch.niveau}
                              </span>
                            ) : null}
                            <span className="ml-2 text-xs text-muted-foreground">
                              ({items.length} leçon{items.length > 1 ? "s" : ""})
                            </span>
                          </button>
                          <div className="flex shrink-0 gap-1">
                            <Button
                              size="icon"
                              variant="ghost"
                              className="size-8"
                              disabled={i === 0}
                              onClick={() => move("chapitres", chapitres, i, -1)}
                            >
                              <ChevronUp className="size-4" />
                            </Button>
                            <Button
                              size="icon"
                              variant="ghost"
                              className="size-8"
                              disabled={i === chapitres.length - 1}
                              onClick={() => move("chapitres", chapitres, i, 1)}
                            >
                              <ChevronDown className="size-4" />
                            </Button>
                            <Button
                              size="icon"
                              variant="ghost"
                              className="size-8 text-destructive"
                              onClick={() => remove("chapitres", ch.id)}
                            >
                              <Trash2 className="size-4" />
                            </Button>
                          </div>
                        </div>

                        {isOpen && (
                          <div className="mt-4 space-y-2 border-t pt-4">
                            {items.length === 0 ? (
                              <p className="text-sm text-muted-foreground">Aucune leçon.</p>
                            ) : (
                              items.map((c, j) => (
                                <div
                                  key={c.id}
                                  className="flex items-center justify-between gap-3 rounded-lg bg-secondary/60 px-3 py-2"
                                >
                                  <span className="min-w-0 text-sm text-foreground">
                                    <span className="block truncate">{c.titre}</span>
                                    <span className="block text-xs text-muted-foreground">
                                      {conceptTypeLabel(c.type_contenu)}
                                      {c.duree_minutes ? ` · ${c.duree_minutes} min` : ""}
                                    </span>
                                  </span>
                                  <div className="flex shrink-0 gap-1">
                                    <Button
                                      size="icon"
                                      variant="ghost"
                                      className="size-7"
                                      onClick={() => openConcept(ch.id, c)}
                                    >
                                      <Pencil className="size-3.5" />
                                    </Button>
                                    <Button
                                      size="icon"
                                      variant="ghost"
                                      className="size-7"
                                      disabled={j === 0}
                                      onClick={() => move("concepts", items, j, -1)}
                                    >
                                      <ChevronUp className="size-3.5" />
                                    </Button>
                                    <Button
                                      size="icon"
                                      variant="ghost"
                                      className="size-7"
                                      disabled={j === items.length - 1}
                                      onClick={() => move("concepts", items, j, 1)}
                                    >
                                      <ChevronDown className="size-3.5" />
                                    </Button>
                                    <Button
                                      size="icon"
                                      variant="ghost"
                                      className="size-7 text-destructive"
                                      onClick={() => remove("concepts", c.id)}
                                    >
                                      <Trash2 className="size-3.5" />
                                    </Button>
                                  </div>
                                </div>
                              ))
                            )}
                            <Button
                              variant="outline"
                              className="mt-1 w-full rounded-xl"
                              onClick={() => openConcept(ch.id)}
                            >
                              <Plus className="size-4" /> Ajouter une leçon
                            </Button>
                          </div>
                        )}
                      </li>
                    );
                  })
                )}
              </ul>
            </>
          )}
        </section>
      </div>

      <Dialog open={openProgramme} onOpenChange={setOpenProgramme}>
        <DialogContent className="rounded-2xl sm:max-w-[480px]">
          <DialogHeader>
            <DialogTitle className="font-display">Créer un cours</DialogTitle>
          </DialogHeader>
          <form onSubmit={createProgramme} className="space-y-4">
            <div className="space-y-2">
              <Label>Classe</Label>
              <Select
                value={form.classeId}
                onValueChange={(v) => setForm({ ...form, classeId: v })}
              >
                <SelectTrigger className="rounded-xl">
                  <SelectValue placeholder="Choisir une classe" />
                </SelectTrigger>
                <SelectContent>
                  {classes.map((c) => (
                    <SelectItem key={c.id} value={c.id}>
                      {c.nom}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label>Matière</Label>
              <Select
                value={form.matiereId}
                onValueChange={(v) => setForm({ ...form, matiereId: v })}
              >
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
              <Label htmlFor="p-titre">Titre du cours (automatique)</Label>
              <Input
                id="p-titre"
                value={autoTitre}
                readOnly
                placeholder="Matière — Classe"
                className="rounded-xl bg-secondary/60"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="p-desc">Description</Label>
              <Textarea
                id="p-desc"
                value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })}
                rows={3}
                className="rounded-xl"
              />
            </div>
            <DialogFooter className="gap-2 sm:gap-2">
              <Button
                type="button"
                variant="outline"
                className="rounded-xl"
                onClick={() => setOpenProgramme(false)}
              >
                Annuler
              </Button>
              <Button
                type="submit"
                disabled={!autoTitre}
                className="rounded-xl bg-success text-success-foreground hover:bg-success/90"
              >
                Créer
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      <Dialog open={!!conceptDialog} onOpenChange={(o) => !o && setConceptDialog(null)}>
        <DialogContent className="max-h-[90vh] overflow-y-auto rounded-2xl sm:max-w-[560px]">
          <DialogHeader>
            <DialogTitle className="font-display">
              {conceptDialog?.conceptId ? "Modifier la leçon" : "Nouvelle leçon"}
            </DialogTitle>
          </DialogHeader>
          <form onSubmit={saveConcept} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="c-titre">Titre</Label>
              <Input
                id="c-titre"
                value={conceptForm.titre}
                onChange={(e) => setConceptForm({ ...conceptForm, titre: e.target.value })}
                required
                className="rounded-xl"
              />
            </div>
            <div className="space-y-2">
              <Label>Type de contenu</Label>
              <Select
                value={conceptForm.type_contenu}
                onValueChange={(v) =>
                  setConceptForm({ ...conceptForm, type_contenu: v as ConceptType })
                }
              >
                <SelectTrigger className="rounded-xl">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {CONCEPT_TYPES.map((t) => (
                    <SelectItem key={t.value} value={t.value}>
                      {t.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {needsMedia && (
              <div className="space-y-2">
                <Label htmlFor="c-media">
                  {conceptForm.type_contenu === "video"
                    ? "Lien YouTube ou fichier"
                    : conceptForm.type_contenu === "simulation"
                      ? "Lien du matériel GeoGebra (geogebra.org/m/XXXXXXXX)"
                      : "Fichier PDF"}
                </Label>
                <Input
                  id="c-media"
                  value={conceptForm.media_url}
                  onChange={(e) => setConceptForm({ ...conceptForm, media_url: e.target.value })}
                  placeholder="https://…"
                  className="rounded-xl"
                />
                {conceptForm.type_contenu !== "simulation" ? (
                  <label className="flex cursor-pointer items-center gap-2 text-sm text-muted-foreground">
                    <Upload className="size-4" />
                    <span>{uploading ? "Import en cours…" : "Importer un fichier"}</span>
                    <input
                      type="file"
                      className="hidden"
                      accept={conceptForm.type_contenu === "video" ? "video/*" : "application/pdf"}
                      onChange={(e) => {
                        const file = e.target.files?.[0];
                        if (file) void uploadMedia(file);
                      }}
                    />
                  </label>
                ) : (
                  <p className="text-xs text-muted-foreground">
                    Créez d'abord l'appliquette sur geogebra.org, puis collez ici le lien de son matériel
                    (bouton « Partager » → lien).
                  </p>
                )}
              </div>
            )}

            {isGraphique ? (
              <div className="space-y-2">
                <Label htmlFor="c-graph-spec">Spécification du graphique (JSON)</Label>
                <Textarea
                  id="c-graph-spec"
                  value={conceptForm.contenu_texte}
                  onChange={(e) => setConceptForm({ ...conceptForm, contenu_texte: e.target.value })}
                  placeholder={GRAPHIQUE_SPEC_PLACEHOLDER}
                  rows={8}
                  className="rounded-xl font-mono text-xs"
                />
                <p className="text-xs text-muted-foreground">
                  Une ou plusieurs fonctions de x (ex. <code>x^2 - 2*x - 1</code>, <code>sin(x)</code>), un domaine,
                  et des points optionnels à marquer. Le tracé ci-dessous se met à jour en direct.
                </p>
                <div className="pt-1">
                  <FunctionGraph spec={conceptForm.contenu_texte || "{}"} />
                </div>
              </div>
            ) : (
              <div className="space-y-2">
                <Label htmlFor="c-texte">
                  {conceptForm.type_contenu === "quiz"
                    ? "Consignes du quiz"
                    : "Contenu texte (facultatif)"}
                </Label>
                <Textarea
                  id="c-texte"
                  value={conceptForm.contenu_texte}
                  onChange={(e) => setConceptForm({ ...conceptForm, contenu_texte: e.target.value })}
                  rows={6}
                  className="rounded-xl"
                />
              </div>
            )}

            <div className="space-y-2">
              <Label htmlFor="c-duree">Durée estimée (minutes)</Label>
              <Input
                id="c-duree"
                type="number"
                min={0}
                value={conceptForm.duree_minutes}
                onChange={(e) => setConceptForm({ ...conceptForm, duree_minutes: e.target.value })}
                className="rounded-xl"
              />
            </div>

            <DialogFooter className="gap-2 sm:gap-2">
              <Button
                type="button"
                variant="outline"
                className="rounded-xl"
                onClick={() => setConceptDialog(null)}
              >
                Annuler
              </Button>
              <Button
                type="submit"
                disabled={saving || uploading}
                className="rounded-xl bg-success text-success-foreground hover:bg-success/90"
              >
                Enregistrer
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
