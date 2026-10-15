import { createFileRoute } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { useEffect, useMemo, useRef, useState } from "react";
import {
  Camera,
  ChevronDown,
  FileText,
  ImagePlus,
  LoaderCircle,
  ScanLine,
  Sparkles,
  Trash2,
  X,
} from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { COPIES_BUCKET, corrigerCopie } from "@/lib/correction.functions";
import { compressImage } from "@/lib/compress-image";
import { MATIERES } from "@/lib/epreuves";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { MathText } from "@/components/math-text";
import { PickFileButton } from "@/components/pick-file-button";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/_authenticated/etudiant/correction")({
  component: CorrectionPage,
  head: () => ({
    meta: [
      { title: "Corriger ma copie — Mandal IA" },
      {
        name: "description",
        content: "Envoyez la photo ou le scan de votre copie : Mandal IA la corrige.",
      },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const MAX_COPIES = 8;
const MAX_SUJETS = 4;

function extensionOf(file: File) {
  if (file.type === "application/pdf") return "pdf";
  const fromName = file.name.split(".").pop()?.toLowerCase();
  return fromName && fromName.length <= 5 ? fromName : "jpg";
}

function CorrectionPage() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();
  const corriger = useServerFn(corrigerCopie);
  const [matiere, setMatiere] = useState("");
  const [sujetTexte, setSujetTexte] = useState("");
  const [sujets, setSujets] = useState<File[]>([]);
  const [copies, setCopies] = useState<File[]>([]);
  const [step, setStep] = useState<string | null>(null);
  const [result, setResult] = useState<string | null>(null);
  const resultRef = useRef<HTMLDivElement>(null);

  const { data: history = [] } = useQuery({
    enabled: !!profile,
    queryKey: ["corrections-ia", profile?.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("corrections_ia")
        .select("id, matiere, correction, created_at, fichiers_copie")
        .eq("eleve_id", profile!.id)
        .order("created_at", { ascending: false })
        .limit(30);
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  useEffect(() => {
    if (result) resultRef.current?.scrollIntoView({ behavior: "smooth", block: "start" });
  }, [result]);

  const submit = async () => {
    if (!profile || step) return;
    if (copies.length === 0) {
      toast.error("Ajoutez au moins une photo ou un PDF de votre copie.");
      return;
    }
    setResult(null);
    try {
      setStep("Préparation des photos…");
      const stamp = Date.now();
      const upload = async (file: File, kind: string, i: number) => {
        const ready = await compressImage(file);
        const path = `${profile.id}/${stamp}-${kind}-${i + 1}.${extensionOf(ready)}`;
        const { error } = await supabase.storage
          .from(COPIES_BUCKET)
          .upload(path, ready, ready.type ? { contentType: ready.type } : {});
        if (error) throw new Error(`Envoi impossible (${file.name}) : ${error.message}`);
        return path;
      };
      setStep("Envoi de vos fichiers…");
      const sujetPaths = await Promise.all(sujets.map((f, i) => upload(f, "sujet", i)));
      const copiePaths = await Promise.all(copies.map((f, i) => upload(f, "copie", i)));

      setStep("Mandal IA lit et corrige votre copie… (jusqu'à une minute)");
      const res = await corriger({
        data: {
          matiere: matiere || undefined,
          sujetTexte: sujetTexte.trim() || undefined,
          copies: copiePaths,
          sujets: sujetPaths,
        },
      });
      setResult(res.correction);
      setCopies([]);
      setSujets([]);
      await queryClient.invalidateQueries({ queryKey: ["corrections-ia"] });
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "La correction a échoué.");
    } finally {
      setStep(null);
    }
  };

  const deleteCorrection = async (id: string, paths: string[]) => {
    if (!confirm("Supprimer cette correction et les photos associées ?")) return;
    const { error } = await supabase.from("corrections_ia").delete().eq("id", id);
    if (error) {
      toast.error(error.message);
      return;
    }
    if (paths.length > 0) await supabase.storage.from(COPIES_BUCKET).remove(paths);
    await queryClient.invalidateQueries({ queryKey: ["corrections-ia"] });
  };

  return (
    <div className="space-y-6">
      <header className="gradient-progress rounded-2xl p-6 text-primary-foreground shadow-sm">
        <ScanLine className="mb-2 size-6" />
        <h1 className="font-display text-2xl font-bold tracking-tight">Corriger ma copie</h1>
        <p className="mt-1 max-w-2xl text-sm opacity-90">
          Tu as traité un sujet sur papier ? Prends ta copie en photo (ou scanne-la) : Mandal IA la
          corrige, te donne une note estimée et t'explique tes difficultés.
        </p>
      </header>

      <section className="space-y-5 rounded-2xl bg-card p-5 shadow-sm">
        <div className="grid gap-4 md:grid-cols-2">
          <div className="space-y-2">
            <Label htmlFor="matiere">Matière</Label>
            <select
              id="matiere"
              value={matiere}
              onChange={(e) => setMatiere(e.target.value)}
              className="w-full rounded-xl border border-border bg-background px-3 py-2.5 text-sm"
            >
              <option value="">— Choisir —</option>
              {MATIERES.map((m) => (
                <option key={m} value={m}>
                  {m}
                </option>
              ))}
            </select>
          </div>
          <div className="space-y-2">
            <Label htmlFor="enonce">Énoncé (facultatif, si tu n'as pas la photo du sujet)</Label>
            <textarea
              id="enonce"
              value={sujetTexte}
              onChange={(e) => setSujetTexte(e.target.value)}
              rows={2}
              maxLength={4000}
              placeholder="Ex. : Exercice 2 — Résoudre l'équation 2x² − 3x + 1 = 0"
              className="w-full resize-y rounded-xl border border-border bg-background p-3 text-sm"
            />
          </div>
        </div>

        <FilePicker
          title="Le sujet (facultatif)"
          hint="Photo ou PDF de l'énoncé, pour une correction plus précise."
          files={sujets}
          max={MAX_SUJETS}
          onChange={setSujets}
          disabled={!!step}
        />
        <FilePicker
          title="Ma copie"
          hint="Une photo par page, bien éclairée, prise d'au-dessus. Ou un PDF scanné."
          files={copies}
          max={MAX_COPIES}
          onChange={setCopies}
          disabled={!!step}
          required
        />

        <Button
          onClick={submit}
          disabled={!!step || copies.length === 0}
          className="h-12 w-full rounded-xl text-base font-semibold"
        >
          {step ? (
            <>
              <LoaderCircle className="animate-spin" /> {step}
            </>
          ) : (
            <>
              <Sparkles className="size-4" /> Faire corriger par Mandal IA
            </>
          )}
        </Button>
        <p className="text-xs text-muted-foreground">
          La note est une estimation de l'IA : ton enseignant reste la référence.
        </p>
      </section>

      {result ? (
        <section
          ref={resultRef}
          className="rounded-2xl border border-primary/30 bg-card p-5 shadow-sm"
        >
          <h2 className="mb-3 font-display text-lg font-bold text-foreground">Ta correction</h2>
          <MathText text={result} className="text-sm leading-relaxed text-foreground" />
        </section>
      ) : null}

      {history.length > 0 ? (
        <section className="space-y-3">
          <h2 className="font-display text-lg font-bold text-foreground">Mes corrections</h2>
          {history.map((h) => (
            <HistoryItem
              key={h.id}
              date={h.created_at}
              matiere={h.matiere}
              correction={h.correction}
              onDelete={() => deleteCorrection(h.id, h.fichiers_copie)}
            />
          ))}
        </section>
      ) : null}
    </div>
  );
}

function FilePicker({
  title,
  hint,
  files,
  max,
  onChange,
  disabled,
  required,
}: {
  title: string;
  hint: string;
  files: File[];
  max: number;
  onChange: (files: File[]) => void;
  disabled?: boolean | undefined;
  required?: boolean | undefined;
}) {
  const addFiles = (list: FileList | null) => {
    if (!list) return;
    const accepted = Array.from(list).filter(
      (f) => f.type.startsWith("image/") || f.type === "application/pdf",
    );
    if (accepted.length < list.length) toast.error("Seules les photos et les PDF sont acceptés.");
    const next = [...files, ...accepted];
    if (next.length > max) toast.error(`${max} fichiers maximum.`);
    onChange(next.slice(0, max));
  };

  return (
    <div className="space-y-2">
      <div>
        <p className="text-sm font-semibold text-foreground">
          {title} {required ? <span className="text-destructive">*</span> : null}
        </p>
        <p className="text-xs text-muted-foreground">{hint}</p>
      </div>
      <div className="flex flex-wrap gap-2">
        <PickFileButton
          icon={<Camera className="size-4" />}
          label="Prendre une photo"
          accept="image/*"
          capture
          onFiles={addFiles}
          disabled={disabled || files.length >= max}
        />
        <PickFileButton
          icon={<ImagePlus className="size-4" />}
          label="Choisir photos / PDF"
          accept="image/*,application/pdf"
          multiple
          onFiles={addFiles}
          disabled={disabled || files.length >= max}
        />
      </div>
      {files.length > 0 ? (
        <ul className="flex flex-wrap gap-2">
          {files.map((f, i) => (
            <FileChip
              key={`${f.name}-${i}`}
              file={f}
              index={i}
              onRemove={() => onChange(files.filter((_, j) => j !== i))}
              disabled={disabled}
            />
          ))}
        </ul>
      ) : null}
    </div>
  );
}

function FileChip({
  file,
  index,
  onRemove,
  disabled,
}: {
  file: File;
  index: number;
  onRemove: () => void;
  disabled?: boolean | undefined;
}) {
  const preview = useMemo(
    () => (file.type.startsWith("image/") ? URL.createObjectURL(file) : null),
    [file],
  );
  useEffect(() => () => (preview ? URL.revokeObjectURL(preview) : undefined), [preview]);

  return (
    <li className="relative flex w-28 flex-col items-center gap-1 rounded-xl border border-border bg-background p-2">
      {preview ? (
        <img
          src={preview}
          alt={`Page ${index + 1}`}
          className="h-24 w-full rounded-lg object-cover"
        />
      ) : (
        <div className="flex h-24 w-full items-center justify-center rounded-lg bg-secondary">
          <FileText className="size-8 text-muted-foreground" />
        </div>
      )}
      <span className="w-full truncate text-center text-[11px] text-muted-foreground">
        {index + 1}. {file.name}
      </span>
      <button
        type="button"
        onClick={onRemove}
        disabled={disabled}
        aria-label={`Retirer ${file.name}`}
        className="absolute -right-2 -top-2 flex size-6 items-center justify-center rounded-full bg-destructive text-white shadow disabled:opacity-50"
      >
        <X className="size-3.5" />
      </button>
    </li>
  );
}

function HistoryItem({
  date,
  matiere,
  correction,
  onDelete,
}: {
  date: string;
  matiere: string | null;
  correction: string;
  onDelete: () => void;
}) {
  const [open, setOpen] = useState(false);
  const note = /##\s*Note estimée\s*\n+([^\n]+)/.exec(correction)?.[1]?.trim();
  return (
    <div className="rounded-2xl bg-card shadow-sm">
      <div className="flex items-center gap-3 p-4">
        <button
          type="button"
          onClick={() => setOpen((v) => !v)}
          className="flex min-w-0 flex-1 items-center gap-3 text-left"
        >
          <ChevronDown
            className={cn("size-4 shrink-0 transition-transform", open && "rotate-180")}
          />
          <div className="min-w-0">
            <p className="truncate text-sm font-semibold text-foreground">
              {matiere || "Copie"} — {new Date(date).toLocaleDateString("fr-FR")}
            </p>
            {note ? <p className="truncate text-xs text-muted-foreground">{note}</p> : null}
          </div>
        </button>
        <Button variant="ghost" size="icon" onClick={onDelete} aria-label="Supprimer">
          <Trash2 className="size-4" />
        </Button>
      </div>
      {open ? (
        <div className="border-t border-border p-4">
          <MathText text={correction} className="text-sm leading-relaxed text-foreground" />
        </div>
      ) : null}
    </div>
  );
}
