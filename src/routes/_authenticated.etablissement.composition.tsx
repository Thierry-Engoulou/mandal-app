import { useState } from "react";
import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useChefSchool, useChefClasses, useCreateCompositeClass } from "@/lib/use-chef";
import { ChefNoSchool } from "@/components/chef-empty";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Skeleton } from "@/components/ui/skeleton";

export const Route = createFileRoute("/_authenticated/etablissement/composition")({
  component: CompositionPage,
  head: () => ({
    meta: [
      { title: "Composition de classe — MANDAL" },
      {
        name: "description",
        content: "Fusionnez plusieurs classes existantes en une classe composite.",
      },
      { name: "robots", content: "noindex" },
      { property: "og:title", content: "Composition de classe — MANDAL" },
      {
        property: "og:description",
        content: "Fusionnez plusieurs classes existantes en une classe composite.",
      },
    ],
  }),
});

const STEPS = ["Classes sources", "Configuration", "Récapitulatif"] as const;

function CompositionPage() {
  const { etabId, isLoading } = useChefSchool();
  const { data: classes = [], isLoading: classesLoading } = useChefClasses(etabId);
  const createComposite = useCreateCompositeClass(etabId);
  const navigate = useNavigate();

  const [step, setStep] = useState(0);
  const [selected, setSelected] = useState<string[]>([]);
  const [nom, setNom] = useState("");
  const [description, setDescription] = useState("");
  const [annee, setAnnee] = useState("");

  if (isLoading) return <Skeleton className="h-40 rounded-2xl" />;
  if (!etabId) return <ChefNoSchool />;

  const sources = classes.filter((c) => selected.includes(c.id));
  const effectifTotal = sources.reduce((sum, c) => sum + c.effectif, 0);

  const toggle = (id: string) =>
    setSelected((prev) => (prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]));

  const canNext = step === 0 ? selected.length > 0 : step === 1 ? nom.trim().length > 0 : true;

  const submit = () => {
    createComposite.mutate(
      {
        nom: nom.trim(),
        description: description.trim() || null,
        annee_scolaire: annee.trim() || null,
        sourceIds: selected,
      },
      { onSuccess: () => navigate({ to: "/etablissement/classes" }) },
    );
  };

  return (
    <div className="space-y-6">
      <header>
        <h1 className="font-display text-2xl font-bold text-foreground">Composition de classe</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          Réunissez les élèves de plusieurs classes dans une nouvelle classe composite.
        </p>
      </header>

      <ol className="flex flex-wrap gap-3">
        {STEPS.map((label, i) => (
          <li
            key={label}
            className={
              i === step
                ? "rounded-xl bg-violet/10 px-4 py-2 text-sm font-semibold text-violet"
                : "rounded-xl px-4 py-2 text-sm text-muted-foreground"
            }
          >
            {i + 1}. {label}
          </li>
        ))}
      </ol>

      <section className="rounded-2xl bg-card p-6 shadow-sm">
        {step === 0 && (
          <>
            <h2 className="font-display text-lg font-semibold text-foreground">
              Sélectionnez les classes à fusionner
            </h2>
            {classesLoading ? (
              <Skeleton className="mt-4 h-32 rounded-xl" />
            ) : classes.length === 0 ? (
              <p className="mt-2 text-sm text-muted-foreground">
                Créez d'abord des classes dans votre établissement.
              </p>
            ) : (
              <ul className="mt-4 divide-y divide-border">
                {classes.map((c) => (
                  <li key={c.id} className="flex items-center gap-3 py-3">
                    <Checkbox
                      id={`c-${c.id}`}
                      checked={selected.includes(c.id)}
                      onCheckedChange={() => toggle(c.id)}
                    />
                    <label htmlFor={`c-${c.id}`} className="min-w-0 flex-1 cursor-pointer">
                      <span className="block truncate text-sm font-medium text-foreground">
                        {c.nom}
                      </span>
                      <span className="text-xs text-muted-foreground">
                        {c.niveau ?? "Niveau non renseigné"} · {c.filiere ?? "Filière non renseignée"}{" "}
                        · {c.effectif} élève(s)
                      </span>
                    </label>
                  </li>
                ))}
              </ul>
            )}
          </>
        )}

        {step === 1 && (
          <>
            <h2 className="font-display text-lg font-semibold text-foreground">
              Configurez la classe composite
            </h2>
            <div className="mt-4 grid gap-4 md:grid-cols-2">
              <div className="space-y-1.5">
                <Label htmlFor="comp-nom">Nom de la classe</Label>
                <Input
                  id="comp-nom"
                  value={nom}
                  onChange={(e) => setNom(e.target.value)}
                  placeholder="Groupe Sciences fusionné"
                />
              </div>
              <div className="space-y-1.5">
                <Label htmlFor="comp-annee">Année scolaire</Label>
                <Input
                  id="comp-annee"
                  value={annee}
                  onChange={(e) => setAnnee(e.target.value)}
                  placeholder="2026-2027"
                />
              </div>
              <div className="space-y-1.5 md:col-span-2">
                <Label htmlFor="comp-desc">Description</Label>
                <Textarea
                  id="comp-desc"
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder="Objectif de cette classe composite…"
                />
              </div>
            </div>
          </>
        )}

        {step === 2 && (
          <>
            <h2 className="font-display text-lg font-semibold text-foreground">Récapitulatif</h2>
            <dl className="mt-4 space-y-3 text-sm">
              <div>
                <dt className="text-muted-foreground">Nom</dt>
                <dd className="font-medium text-foreground">{nom || "—"}</dd>
              </div>
              <div>
                <dt className="text-muted-foreground">Année scolaire</dt>
                <dd className="font-medium text-foreground">{annee || "—"}</dd>
              </div>
              <div>
                <dt className="text-muted-foreground">Description</dt>
                <dd className="font-medium text-foreground">{description || "—"}</dd>
              </div>
              <div>
                <dt className="text-muted-foreground">Classes fusionnées</dt>
                <dd className="font-medium text-foreground">
                  {sources.map((c) => c.nom).join(", ") || "—"}
                </dd>
              </div>
              <div>
                <dt className="text-muted-foreground">Élèves concernés (estimation)</dt>
                <dd className="font-medium text-foreground">{effectifTotal}</dd>
              </div>
            </dl>
          </>
        )}

        <div className="mt-6 flex flex-wrap items-center gap-2">
          {step > 0 && (
            <Button variant="ghost" onClick={() => setStep(step - 1)}>
              Retour
            </Button>
          )}
          {step < 2 ? (
            <Button disabled={!canNext} onClick={() => setStep(step + 1)}>
              Continuer
            </Button>
          ) : (
            <Button disabled={createComposite.isPending} onClick={submit}>
              Créer la classe composite
            </Button>
          )}
        </div>
      </section>
    </div>
  );
}
