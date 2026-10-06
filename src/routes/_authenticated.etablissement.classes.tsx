import { useMemo, useState } from "react";
import { createFileRoute } from "@tanstack/react-router";
import { useChefSchool, useChefClasses, useChefMembers, useClassMutations } from "@/lib/use-chef";
import type { ChefClass } from "@/lib/use-chef";
import { ChefNoSchool } from "@/components/chef-empty";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

export const Route = createFileRoute("/_authenticated/etablissement/classes")({
  component: ClassesPage,
  head: () => ({
    meta: [
      { title: "Classes de l'établissement — MANDAL" },
      {
        name: "description",
        content: "Créez, modifiez et suivez les classes de votre établissement.",
      },
      { name: "robots", content: "noindex" },
      { property: "og:title", content: "Classes de l'établissement — MANDAL" },
      {
        property: "og:description",
        content: "Créez, modifiez et suivez les classes de votre établissement.",
      },
    ],
  }),
});

const PAGE_SIZE = 10;
const NONE = "__aucun__";

type SortKey = "nom" | "niveau" | "filiere" | "effectif";

function ClassesPage() {
  const { etabId, isLoading } = useChefSchool();
  const { data: classes = [], isLoading: classesLoading } = useChefClasses(etabId);
  const { data: members = [] } = useChefMembers(etabId);
  const { create, update, remove } = useClassMutations(etabId);

  const [sortKey, setSortKey] = useState<SortKey>("nom");
  const [asc, setAsc] = useState(true);
  const [page, setPage] = useState(0);
  const [editing, setEditing] = useState<ChefClass | null>(null);
  const [form, setForm] = useState({ nom: "", niveau: "", filiere: "", enseignant_id: NONE });

  const teachers = members.filter(
    (m) => m.role === "teacher" && m.statut_validation === "approuve",
  );

  const sorted = useMemo(() => {
    const rows = [...classes];
    rows.sort((a, b) => {
      const va = a[sortKey] ?? "";
      const vb = b[sortKey] ?? "";
      if (typeof va === "number" && typeof vb === "number") return asc ? va - vb : vb - va;
      return asc
        ? String(va).localeCompare(String(vb), "fr")
        : String(vb).localeCompare(String(va), "fr");
    });
    return rows;
  }, [classes, sortKey, asc]);

  const pageCount = Math.max(1, Math.ceil(sorted.length / PAGE_SIZE));
  const current = sorted.slice(page * PAGE_SIZE, page * PAGE_SIZE + PAGE_SIZE);

  if (isLoading) return <Skeleton className="h-40 rounded-2xl" />;
  if (!etabId) return <ChefNoSchool />;

  const toggleSort = (key: SortKey) => {
    if (key === sortKey) setAsc(!asc);
    else {
      setSortKey(key);
      setAsc(true);
    }
  };

  const startEdit = (c: ChefClass) => {
    setEditing(c);
    setForm({
      nom: c.nom,
      niveau: c.niveau ?? "",
      filiere: c.filiere ?? "",
      enseignant_id: c.enseignant_id ?? NONE,
    });
  };

  const resetForm = () => {
    setEditing(null);
    setForm({ nom: "", niveau: "", filiere: "", enseignant_id: NONE });
  };

  const submit = (e: React.FormEvent) => {
    e.preventDefault();
    const payload = {
      nom: form.nom.trim(),
      niveau: form.niveau.trim() || null,
      filiere: form.filiere.trim() || null,
      enseignant_id: form.enseignant_id === NONE ? null : form.enseignant_id,
    };
    if (!payload.nom) return;
    if (editing) {
      update.mutate({ id: editing.id, ...payload }, { onSuccess: resetForm });
    } else {
      create.mutate(payload, { onSuccess: resetForm });
    }
  };

  return (
    <div className="space-y-6">
      <header>
        <h1 className="font-display text-2xl font-bold text-foreground">Classes</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          {classes.length} classe(s) dans votre établissement.
        </p>
      </header>

      <section className="rounded-2xl bg-card p-6 shadow-sm">
        <h2 className="font-display text-lg font-semibold text-foreground">
          {editing ? `Modifier « ${editing.nom} »` : "Nouvelle classe"}
        </h2>
        <form onSubmit={submit} className="mt-4 grid gap-4 md:grid-cols-4">
          <div className="space-y-1.5">
            <Label htmlFor="nom">Nom</Label>
            <Input
              id="nom"
              value={form.nom}
              onChange={(e) => setForm({ ...form, nom: e.target.value })}
              placeholder="Terminale C1"
              required
            />
          </div>
          <div className="space-y-1.5">
            <Label htmlFor="niveau">Niveau</Label>
            <Input
              id="niveau"
              value={form.niveau}
              onChange={(e) => setForm({ ...form, niveau: e.target.value })}
              placeholder="Terminale"
            />
          </div>
          <div className="space-y-1.5">
            <Label htmlFor="filiere">Filière</Label>
            <Input
              id="filiere"
              value={form.filiere}
              onChange={(e) => setForm({ ...form, filiere: e.target.value })}
              placeholder="Scientifique"
            />
          </div>
          <div className="space-y-1.5">
            <Label>Enseignant</Label>
            <Select
              value={form.enseignant_id}
              onValueChange={(v) => setForm({ ...form, enseignant_id: v })}
            >
              <SelectTrigger>
                <SelectValue placeholder="Aucun" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value={NONE}>Aucun</SelectItem>
                {teachers.map((t) => (
                  <SelectItem key={t.id} value={t.id}>
                    {t.nom}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="flex items-end gap-2 md:col-span-4">
            <Button type="submit" disabled={create.isPending || update.isPending}>
              {editing ? "Enregistrer" : "Créer la classe"}
            </Button>
            {editing && (
              <Button type="button" variant="ghost" onClick={resetForm}>
                Annuler
              </Button>
            )}
          </div>
        </form>
      </section>

      <div className="overflow-x-auto rounded-2xl bg-card p-2 shadow-sm">
        {classesLoading ? (
          <Skeleton className="h-40 rounded-xl" />
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                {(
                  [
                    ["nom", "Nom"],
                    ["niveau", "Niveau"],
                    ["filiere", "Filière"],
                  ] as const
                ).map(([key, label]) => (
                  <TableHead key={key}>
                    <button
                      type="button"
                      onClick={() => toggleSort(key)}
                      className="font-medium hover:text-violet"
                    >
                      {label} {sortKey === key ? (asc ? "▲" : "▼") : ""}
                    </button>
                  </TableHead>
                ))}
                <TableHead>Enseignant</TableHead>
                <TableHead>
                  <button
                    type="button"
                    onClick={() => toggleSort("effectif")}
                    className="font-medium hover:text-violet"
                  >
                    Effectif {sortKey === "effectif" ? (asc ? "▲" : "▼") : ""}
                  </button>
                </TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {current.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-sm text-muted-foreground">
                    Aucune classe pour le moment.
                  </TableCell>
                </TableRow>
              ) : (
                current.map((c) => (
                  <TableRow key={c.id}>
                    <TableCell className="font-medium">
                      {c.nom}
                      {c.is_composite && (
                        <span className="ml-2 rounded-full bg-violet/10 px-2 py-0.5 text-xs font-semibold text-violet">
                          Composite
                        </span>
                      )}
                    </TableCell>
                    <TableCell>{c.niveau ?? "—"}</TableCell>
                    <TableCell>{c.filiere ?? "—"}</TableCell>
                    <TableCell>{c.enseignant_nom ?? "Non assigné"}</TableCell>
                    <TableCell>{c.effectif}</TableCell>
                    <TableCell className="space-x-2 text-right">
                      <Button variant="ghost" size="sm" onClick={() => startEdit(c)}>
                        Modifier
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="text-destructive"
                        disabled={remove.isPending}
                        onClick={() => remove.mutate(c.id)}
                      >
                        Supprimer
                      </Button>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        )}
      </div>

      {pageCount > 1 && (
        <div className="flex items-center justify-between text-sm">
          <Button variant="ghost" size="sm" disabled={page === 0} onClick={() => setPage(page - 1)}>
            Précédent
          </Button>
          <span className="text-muted-foreground">
            Page {page + 1} sur {pageCount}
          </span>
          <Button
            variant="ghost"
            size="sm"
            disabled={page + 1 >= pageCount}
            onClick={() => setPage(page + 1)}
          >
            Suivant
          </Button>
        </div>
      )}
    </div>
  );
}
