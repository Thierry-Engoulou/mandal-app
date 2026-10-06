import { createFileRoute, Link } from "@tanstack/react-router";
import { useState } from "react";
import { Pencil, Plus, Trash2, Users } from "lucide-react";
import { toast } from "sonner";
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
  useCreateClasse,
  useDeleteClasse,
  useMyClasses,
  useUpdateClasse,
  type ClasseRow,
} from "@/lib/use-classes";

export const Route = createFileRoute("/_authenticated/enseignant/classes/")({
  component: TeacherClassesPage,
  head: () => ({
    meta: [
      { title: "Mes classes — M'Andal" },
      { name: "description", content: "Gérez vos classes et leurs examens sur M'Andal." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const emptyForm = { nom: "", niveau: "", filiere: "", annee_scolaire: "", description: "" };

function TeacherClassesPage() {
  const { data: classes = [], isLoading, isError, error } = useMyClasses();
  const createClasse = useCreateClasse();
  const updateClasse = useUpdateClasse();
  const deleteClasse = useDeleteClasse();

  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<ClasseRow | null>(null);
  const [form, setForm] = useState(emptyForm);

  const openCreate = () => {
    setEditing(null);
    setForm(emptyForm);
    setOpen(true);
  };

  const openEdit = (c: ClasseRow) => {
    setEditing(c);
    setForm({
      nom: c.nom,
      niveau: c.niveau ?? "",
      filiere: c.filiere ?? "",
      annee_scolaire: c.annee_scolaire ?? "",
      description: c.description ?? "",
    });
    setOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editing) {
        await updateClasse.mutateAsync({ id: editing.id, ...form });
        toast.success("Classe mise à jour");
      } else {
        await createClasse.mutateAsync(form);
        toast.success("Classe créée");
      }
      setOpen(false);
      setForm(emptyForm);
      setEditing(null);
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Enregistrement impossible");
    }
  };

  const handleDelete = async (c: ClasseRow) => {
    if (!window.confirm(`Supprimer définitivement la classe « ${c.nom} » ?`)) return;
    try {
      await deleteClasse.mutateAsync(c.id);
      toast.success("Classe supprimée");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Suppression impossible");
    }
  };

  const saving = createClasse.isPending || updateClasse.isPending;

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h1 className="font-display text-2xl font-bold tracking-tight text-foreground">
          Mes classes
        </h1>
        <Button
          onClick={openCreate}
          className="rounded-xl bg-success text-success-foreground hover:bg-success/90"
        >
          <Plus className="mr-1 h-4 w-4" /> Créer une classe
        </Button>
      </div>

      {isLoading ? (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
          {[0, 1, 2].map((i) => (
            <div key={i} className="h-36 animate-pulse rounded-2xl bg-card shadow-sm" />
          ))}
        </div>
      ) : isError ? (
        <div className="rounded-2xl border border-destructive/30 bg-card p-8 text-center">
          <p className="text-sm text-muted-foreground">
            {error instanceof Error ? error.message : "Impossible de charger vos classes."}
          </p>
        </div>
      ) : classes.length === 0 ? (
        <div className="rounded-2xl border border-dashed border-border p-12 text-center">
          <p className="font-display text-lg font-bold">Aucune classe pour l'instant</p>
          <p className="mt-2 text-sm text-muted-foreground">
            Créez votre première classe : elle sera enregistrée dans votre base de données.
          </p>
        </div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
          {classes.map((c) => (
            <div key={c.id} className="rounded-2xl bg-card p-6 shadow-sm transition-shadow hover:shadow-md">
              <div className="flex items-start justify-between gap-3">
                <Link
                  to="/enseignant/classes/$classId"
                  params={{ classId: c.id }}
                  className="font-display text-lg font-bold text-foreground hover:underline"
                >
                  {c.nom}
                </Link>
                <div className="flex shrink-0 gap-1">
                  <Button
                    size="icon"
                    variant="ghost"
                    className="size-8 rounded-lg"
                    aria-label={`Modifier ${c.nom}`}
                    onClick={() => openEdit(c)}
                  >
                    <Pencil className="size-4" />
                  </Button>
                  <Button
                    size="icon"
                    variant="ghost"
                    className="size-8 rounded-lg text-destructive hover:text-destructive"
                    aria-label={`Supprimer ${c.nom}`}
                    onClick={() => handleDelete(c)}
                  >
                    <Trash2 className="size-4" />
                  </Button>
                </div>
              </div>
              <p className="mt-3 flex items-center gap-2 text-sm text-muted-foreground">
                <Users className="h-4 w-4" />
                {c.effectif} élèves
              </p>
              <p className="mt-1 text-xs text-muted-foreground">
                {[c.annee_scolaire, c.niveau, c.filiere].filter(Boolean).join(" · ") ||
                  "Aucun détail renseigné"}
              </p>
            </div>
          ))}
        </div>
      )}

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="rounded-2xl sm:max-w-[440px]">
          <DialogHeader>
            <DialogTitle className="font-display">
              {editing ? "Modifier la classe" : "Créer une classe"}
            </DialogTitle>
          </DialogHeader>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="className">Nom de la classe</Label>
              <Input
                id="className"
                value={form.nom}
                onChange={(e) => setForm({ ...form, nom: e.target.value })}
                required
                placeholder="Terminale D"
                className="rounded-xl"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="level">Niveau</Label>
              <Input
                id="level"
                value={form.niveau}
                onChange={(e) => setForm({ ...form, niveau: e.target.value })}
                placeholder="Terminale"
                className="rounded-xl"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="year">Année scolaire</Label>
              <Input
                id="year"
                value={form.annee_scolaire}
                onChange={(e) => setForm({ ...form, annee_scolaire: e.target.value })}
                placeholder="2025-2026"
                className="rounded-xl"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="track">Série / Filière</Label>
              <Input
                id="track"
                value={form.filiere}
                onChange={(e) => setForm({ ...form, filiere: e.target.value })}
                placeholder="Série D"
                className="rounded-xl"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="desc">Description (facultatif)</Label>
              <Textarea
                id="desc"
                value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })}
                className="rounded-xl"
                rows={2}
              />
            </div>
            <DialogFooter className="gap-2 sm:gap-2">
              <Button
                type="button"
                variant="outline"
                className="rounded-xl"
                onClick={() => setOpen(false)}
              >
                Annuler
              </Button>
              <Button
                type="submit"
                disabled={saving}
                className="rounded-xl bg-success text-success-foreground hover:bg-success/90"
              >
                {saving ? "Enregistrement…" : editing ? "Enregistrer" : "Créer"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
