import { createFileRoute, Link } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { useEffect, useMemo, useState } from "react";
import {
  Sparkles,
  Camera,
  UploadCloud,
  CheckCircle2,
  AlertTriangle,
  Lightbulb,
  BookOpen,
  ArrowRight,
  LoaderCircle,
  Clock,
  FileText,
  X,
  Timer,
  History,
  Eye,
} from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { MathText } from "@/components/math-text";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import {
  useProgrammeDetail,
  useProgression,
  useStudentProgrammes,
} from "@/lib/use-student-programmes";
import {
  corrigerCopie,
  genererEpreuve,
  MAX_COPIE_BASE64,
  parseCorrige,
  parseEpreuve,
  parseRapport,
  type EpreuveIA,
  type RapportCorrection,
} from "@/lib/epreuves-ia.functions";

export const Route = createFileRoute("/_authenticated/etudiant/sujets")({
  component: StudentSubjectsPage,
  head: () => ({
    meta: [
      { title: "Épreuves Mandal IA — génération et correction" },
      {
        name: "description",
        content:
          "Mandal IA rédige des épreuves sur les chapitres que vous avez étudiés et corrige vos copies manuscrites.",
      },
      { name: "robots", content: "noindex" },
    ],
  }),
});

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

type Fichier = { name: string; mimeType: string; base64: string };

function readAsBase64(blob: Blob): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result).split(",")[1] ?? "");
    reader.onerror = () => reject(reader.error);
    reader.readAsDataURL(blob);
  });
}

/** Réduit une photo (1600 px max, JPEG) : lisible par l'IA et légère à envoyer. */
async function compressImage(file: File): Promise<Fichier> {
  const bitmap = await createImageBitmap(file);
  const scale = Math.min(1, 1600 / Math.max(bitmap.width, bitmap.height));
  const canvas = document.createElement("canvas");
  canvas.width = Math.round(bitmap.width * scale);
  canvas.height = Math.round(bitmap.height * scale);
  canvas.getContext("2d")?.drawImage(bitmap, 0, 0, canvas.width, canvas.height);
  bitmap.close();
  const blob = await new Promise<Blob | null>((resolve) =>
    canvas.toBlob(resolve, "image/jpeg", 0.75),
  );
  if (!blob) throw new Error("Image illisible");
  return { name: file.name, mimeType: "image/jpeg", base64: await readAsBase64(blob) };
}

function formatTime(seconds: number) {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  return `${h > 0 ? `${h}:` : ""}${String(m).padStart(h > 0 ? 2 : 1, "0")}:${String(s).padStart(2, "0")}`;
}

function StudentSubjectsPage() {
  const { data: profile } = useProfile();
  const queryClient = useQueryClient();
  const generate = useServerFn(genererEpreuve);
  const correct = useServerFn(corrigerCopie);

  // --- Choix du cours et des chapitres ---
  const { data: programmes = [], isLoading: loadingProgrammes } = useStudentProgrammes();
  const cours = programmes.filter((p) => UUID.test(p.id));
  const [programmeId, setProgrammeId] = useState("");
  useEffect(() => {
    if (!programmeId && cours[0]) setProgrammeId(cours[0].id);
  }, [programmeId, cours]);

  const { data: detail } = useProgrammeDetail(programmeId);
  const chapitres = useMemo(() => detail?.chapitres ?? [], [detail]);
  const conceptIds = useMemo(
    () => chapitres.flatMap((c) => c.concepts.map((k) => k.id)),
    [chapitres],
  );
  const { data: done } = useProgression(conceptIds);

  const etatChapitre = (concepts: { id: string }[]) => {
    const n = concepts.filter((k) => done?.has(k.id)).length;
    if (concepts.length === 0 || n === 0) return null;
    return n === concepts.length ? "terminé" : `${n}/${concepts.length}`;
  };

  // Par défaut : les chapitres que l'élève a commencés ou terminés.
  const [selected, setSelected] = useState<Set<string>>(new Set());
  useEffect(() => {
    setSelected(
      new Set(chapitres.filter((c) => c.concepts.some((k) => done?.has(k.id))).map((c) => c.id)),
    );
  }, [chapitres, done]);

  const toggleChapitre = (id: string) =>
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });

  const [precision, setPrecision] = useState("");
  const [generating, setGenerating] = useState(false);
  const [epreuveId, setEpreuveId] = useState<string | null>(null);
  const [epreuve, setEpreuve] = useState<EpreuveIA | null>(null);

  // --- Chronomètre ---
  const [endsAt, setEndsAt] = useState<number | null>(null);
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    if (!endsAt) return;
    const id = window.setInterval(() => setNow(Date.now()), 1000);
    return () => window.clearInterval(id);
  }, [endsAt]);
  const remaining = endsAt ? Math.max(0, Math.round((endsAt - now) / 1000)) : null;
  useEffect(() => {
    if (remaining === 0) {
      toast.warning("Temps écoulé ! Photographiez ou scannez votre copie pour la faire corriger.");
      setEndsAt(null);
    }
  }, [remaining]);

  // --- Copie et correction ---
  const [fichiers, setFichiers] = useState<Fichier[]>([]);
  const [preparing, setPreparing] = useState(false);
  const [analyzing, setAnalyzing] = useState(false);
  const [rapport, setRapport] = useState<RapportCorrection | null>(null);
  const [showCorrige, setShowCorrige] = useState(false);
  const totalBase64 = fichiers.reduce((n, f) => n + f.base64.length, 0);

  const { data: corrige = [] } = useQuery({
    enabled: !!epreuveId && showCorrige,
    queryKey: ["epreuve-corrige", epreuveId],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("epreuves_ia")
        .select("corrige")
        .eq("id", epreuveId!)
        .maybeSingle();
      if (error) throw new Error(error.message);
      return parseCorrige(data?.corrige);
    },
  });

  const { data: historique = [] } = useQuery({
    enabled: !!profile,
    queryKey: ["epreuves-ia", profile?.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("epreuves_ia")
        .select("id, titre, contenu, created_at, corrections_ia(note, sur, rapport, created_at)")
        .eq("eleve_id", profile!.id)
        .order("created_at", { ascending: false })
        .limit(10);
      if (error) throw new Error(error.message);
      return data ?? [];
    },
  });

  const resetCopie = () => {
    setFichiers([]);
    setRapport(null);
    setShowCorrige(false);
  };

  const handleGenerate = async () => {
    if (!programmeId || selected.size === 0) {
      toast.error("Choisissez au moins un chapitre étudié.");
      return;
    }
    setGenerating(true);
    try {
      const res = await generate({
        data: {
          programmeId,
          chapitreIds: [...selected],
          precision: precision.trim() || undefined,
        },
      });
      setEpreuve(res.epreuve);
      setEpreuveId(res.id);
      setEndsAt(null);
      resetCopie();
      queryClient.invalidateQueries({ queryKey: ["epreuves-ia"] });
      toast.success(
        res.sourceBanque
          ? "Épreuve rédigée sur le modèle des épreuves de votre établissement."
          : "Épreuve rédigée au format officiel de l'examen.",
      );
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Génération impossible.");
    } finally {
      setGenerating(false);
    }
  };

  const handleFiles = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files ?? []);
    e.target.value = "";
    if (files.length === 0) return;
    setPreparing(true);
    try {
      const prepared: Fichier[] = [];
      for (const file of files) {
        if (file.type === "application/pdf") {
          prepared.push({
            name: file.name,
            mimeType: file.type,
            base64: await readAsBase64(file),
          });
        } else if (file.type.startsWith("image/")) {
          prepared.push(await compressImage(file));
        }
      }
      const next = [...fichiers, ...prepared].slice(0, 12);
      if (next.reduce((n, f) => n + f.base64.length, 0) > MAX_COPIE_BASE64) {
        toast.error(
          "La copie est trop lourde. Envoyez des photos plutôt qu'un gros PDF, ou moins de pages.",
        );
        return;
      }
      setFichiers(next);
      setRapport(null);
    } catch {
      toast.error("Impossible de lire ce fichier. Essayez une photo JPG ou un PDF.");
    } finally {
      setPreparing(false);
    }
  };

  const handleCorrection = async () => {
    if (fichiers.length === 0) {
      toast.error("Photographiez ou scannez d'abord votre copie.");
      return;
    }
    setAnalyzing(true);
    try {
      const res = await correct({
        data: {
          epreuveId,
          fichiers: fichiers.map(({ mimeType, base64 }) => ({ mimeType, base64 })),
        },
      });
      setRapport(res.rapport);
      setEndsAt(null);
      queryClient.invalidateQueries({ queryKey: ["epreuves-ia"] });
      toast.success("Correction terminée.");
    } catch (err) {
      toast.error(err instanceof Error ? err.message : "Correction impossible.");
    } finally {
      setAnalyzing(false);
    }
  };

  const openFromHistory = (row: (typeof historique)[number]) => {
    const contenu = parseEpreuve(row.contenu);
    if (!contenu) return;
    setEpreuve(contenu);
    setEpreuveId(row.id);
    setEndsAt(null);
    resetCopie();
    const last = [...(row.corrections_ia ?? [])].sort((a, b) =>
      b.created_at.localeCompare(a.created_at),
    )[0];
    if (last) setRapport(parseRapport(last.rapport));
    window.scrollTo({ top: 0, behavior: "smooth" });
  };

  const noteSur20 = rapport && rapport.sur > 0 ? (rapport.note / rapport.sur) * 20 : null;

  return (
    <div className="space-y-8">
      {/* En-tête */}
      <div className="gradient-welcome rounded-3xl p-6 sm:p-8 text-primary-foreground shadow-sm">
        <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider opacity-80">
          <Sparkles className="size-4" /> Épreuves Mandal IA
        </div>
        <h1 className="mt-2 font-display text-2xl sm:text-3xl font-black tracking-tight">
          Compose, envoie ta copie, Mandal IA corrige
        </h1>
        <p className="mt-2 text-sm sm:text-base opacity-90 max-w-2xl leading-relaxed">
          Mandal IA rédige une épreuve sur les chapitres que tu as étudiés, sur le modèle des
          épreuves de ton établissement. Tu composes sur papier, tu photographies ta copie, et tu
          reçois ta note et tes points à travailler.
        </p>
      </div>

      {/* 1. GÉNÉRATION */}
      <section className="rounded-3xl border border-border bg-card p-6 sm:p-8 shadow-sm space-y-6">
        <div>
          <h2 className="font-display text-xl font-bold text-foreground flex items-center gap-2">
            <BookOpen className="size-5 text-primary" /> 1. Générer une épreuve
          </h2>
          <p className="text-xs sm:text-sm text-muted-foreground mt-1">
            Les chapitres que tu as commencés sont cochés. Ajoute ou retire ceux que tu veux.
          </p>
        </div>

        {loadingProgrammes ? (
          <p className="text-sm text-muted-foreground">Chargement de tes cours…</p>
        ) : cours.length === 0 ? (
          <div className="rounded-xl border border-dashed border-border p-6 text-center text-sm text-muted-foreground">
            Aucun cours trouvé. Rejoins ta classe depuis{" "}
            <Link to="/etudiant/cours" className="font-semibold text-primary underline">
              Mes cours
            </Link>{" "}
            pour que Mandal IA puisse te préparer des épreuves.
          </div>
        ) : (
          <div className="space-y-4">
            <select
              value={programmeId}
              onChange={(e) => setProgrammeId(e.target.value)}
              className="w-full sm:w-auto rounded-xl border border-border bg-background px-3 py-2 text-sm font-semibold text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
            >
              {cours.map((p) => (
                <option key={p.id} value={p.id}>
                  {p.titre}
                  {p.classeNom ? ` — ${p.classeNom}` : ""}
                </option>
              ))}
            </select>

            <div className="grid gap-2 sm:grid-cols-2">
              {chapitres.map((ch) => {
                const etat = etatChapitre(ch.concepts);
                return (
                  <label
                    key={ch.id}
                    className="flex items-start gap-3 rounded-xl border border-border bg-background p-3 text-sm cursor-pointer hover:border-primary/40"
                  >
                    <input
                      type="checkbox"
                      className="mt-0.5 size-4 accent-[var(--primary)]"
                      checked={selected.has(ch.id)}
                      onChange={() => toggleChapitre(ch.id)}
                    />
                    <span className="flex-1 leading-snug">{ch.titre}</span>
                    {etat && (
                      <span className="shrink-0 rounded-full bg-emerald-500/10 px-2 py-0.5 text-[11px] font-bold text-emerald-700 dark:text-emerald-400">
                        {etat}
                      </span>
                    )}
                  </label>
                );
              })}
            </div>

            <input
              value={precision}
              onChange={(e) => setPrecision(e.target.value)}
              maxLength={500}
              placeholder="Précision facultative : « surtout des exercices sur les limites », « épreuve d'une heure »…"
              className="w-full rounded-xl border border-border bg-background px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            />

            <Button
              onClick={handleGenerate}
              disabled={generating || selected.size === 0}
              className="rounded-xl font-bold"
            >
              {generating ? (
                <>
                  <LoaderCircle className="mr-2 size-4 animate-spin" /> Mandal IA rédige l'épreuve…
                </>
              ) : (
                <>
                  <Sparkles className="mr-2 size-4" /> Générer mon épreuve ({selected.size} chapitre
                  {selected.size > 1 ? "s" : ""})
                </>
              )}
            </Button>
          </div>
        )}

        {epreuve && (
          <div className="rounded-2xl border border-primary/20 bg-primary/5 p-5 sm:p-6 space-y-5">
            <div className="border-b border-primary/10 pb-4 flex flex-col sm:flex-row sm:items-start justify-between gap-3">
              <div>
                <span className="text-xs font-bold uppercase tracking-wider text-primary">
                  {[epreuve.niveau, epreuve.matiere].filter(Boolean).join(" · ")}
                </span>
                <h3 className="font-display text-lg sm:text-xl font-black text-foreground mt-0.5">
                  {epreuve.titre}
                </h3>
              </div>
              <div className="flex flex-wrap items-center gap-2 shrink-0">
                <span className="rounded-full bg-primary/10 px-3 py-1 text-xs font-bold text-primary">
                  <Clock className="inline mr-1 size-3.5" /> {epreuve.dureeMinutes} min
                </span>
                {remaining !== null ? (
                  <span className="rounded-full bg-amber-500/15 px-3 py-1 text-xs font-bold text-amber-700 dark:text-amber-300 tabular-nums">
                    <Timer className="inline mr-1 size-3.5" /> {formatTime(remaining)}
                  </span>
                ) : (
                  <Button
                    size="sm"
                    variant="outline"
                    className="rounded-full h-7 text-xs"
                    onClick={() => setEndsAt(Date.now() + epreuve.dureeMinutes * 60_000)}
                  >
                    <Timer className="mr-1 size-3.5" /> Démarrer le chrono
                  </Button>
                )}
              </div>
            </div>

            {epreuve.consignes && (
              <p className="text-xs sm:text-sm text-muted-foreground italic">{epreuve.consignes}</p>
            )}

            {epreuve.parties.map((partie, idx) => (
              <div
                key={idx}
                className="rounded-xl bg-card p-4 sm:p-5 border border-border space-y-3"
              >
                <div className="flex items-start justify-between gap-3 border-b border-border/60 pb-2">
                  <h4 className="font-display font-bold text-sm sm:text-base text-foreground">
                    {partie.titre}
                  </h4>
                  <span className="shrink-0 rounded bg-secondary px-2 py-0.5 text-xs font-bold text-muted-foreground">
                    {partie.points} pts
                  </span>
                </div>
                {partie.description && (
                  <MathText text={partie.description} className="text-xs text-muted-foreground" />
                )}
                <ol className="space-y-2">
                  {partie.questions.map((q, qIdx) => (
                    <li
                      key={qIdx}
                      className="flex gap-3 rounded-lg border border-border/40 bg-muted/20 p-3 text-sm"
                    >
                      <span className="font-bold text-primary shrink-0">{q.numero}.</span>
                      <MathText text={q.enonce} className="flex-1 min-w-0" />
                      <span className="shrink-0 text-xs font-semibold text-muted-foreground">
                        {q.points} pt{q.points > 1 ? "s" : ""}
                      </span>
                    </li>
                  ))}
                </ol>
              </div>
            ))}

            <div className="rounded-xl bg-amber-500/10 border border-amber-500/20 p-4 text-xs text-amber-900 dark:text-amber-200 flex items-start gap-3">
              <Lightbulb className="size-4 shrink-0 mt-0.5" />
              <p>
                Compose sur des feuilles, en écrivant lisiblement et en numérotant tes réponses.
                Quand tu as fini, ou quand le chrono s'arrête, photographie chaque page et envoie-la
                ci-dessous pour être corrigé.
              </p>
            </div>
          </div>
        )}
      </section>

      {/* 2. CORRECTION */}
      <section className="rounded-3xl border border-border bg-card p-6 sm:p-8 shadow-sm space-y-6">
        <div>
          <h2 className="font-display text-xl font-bold text-foreground flex items-center gap-2">
            <Camera className="size-5 text-emerald-600 dark:text-emerald-400" /> 2. Faire corriger
            ma copie
          </h2>
          <p className="text-xs sm:text-sm text-muted-foreground mt-1">
            {epreuve
              ? `Copie de l'épreuve « ${epreuve.titre} ». Mandal IA la corrige avec le barème de l'épreuve.`
              : "Sans épreuve générée, Mandal IA corrige la copie en déduisant le sujet de ce que tu as écrit."}
          </p>
        </div>

        <div className="rounded-2xl border-2 border-dashed border-border p-6 sm:p-8 text-center space-y-4 bg-muted/10">
          <div className="mx-auto flex size-14 items-center justify-center rounded-2xl bg-emerald-500/10 text-emerald-600 dark:text-emerald-400">
            <UploadCloud className="size-7" />
          </div>
          <p className="text-xs text-muted-foreground">
            Photos (une par page, bien éclairées et à plat) ou un PDF scanné · 12 pages au plus
          </p>
          <label className="cursor-pointer inline-flex items-center gap-2 rounded-xl bg-emerald-600 px-5 py-2.5 text-sm font-bold text-white hover:bg-emerald-500 transition shadow-sm">
            {preparing ? (
              <LoaderCircle className="size-4 animate-spin" />
            ) : (
              <Camera className="size-4" />
            )}
            Photographier ou choisir les pages
            <input
              type="file"
              accept="image/*,application/pdf"
              multiple
              className="hidden"
              onChange={handleFiles}
              disabled={preparing}
            />
          </label>

          {fichiers.length > 0 && (
            <ul className="flex flex-wrap justify-center gap-2 pt-2">
              {fichiers.map((f, i) => (
                <li
                  key={i}
                  className="inline-flex items-center gap-1.5 rounded-full border border-emerald-500/30 bg-emerald-500/10 pl-3 pr-1.5 py-1 text-xs font-semibold text-emerald-700 dark:text-emerald-300"
                >
                  <FileText className="size-3.5" /> Page {i + 1}
                  <button
                    type="button"
                    aria-label={`Retirer ${f.name}`}
                    onClick={() => setFichiers((prev) => prev.filter((_, j) => j !== i))}
                    className="rounded-full p-0.5 hover:bg-emerald-500/20"
                  >
                    <X className="size-3.5" />
                  </button>
                </li>
              ))}
            </ul>
          )}
          {fichiers.length > 0 && (
            <p className="text-[11px] text-muted-foreground">
              {Math.round((totalBase64 / MAX_COPIE_BASE64) * 100)} % de la taille maximale
            </p>
          )}
        </div>

        <div className="flex justify-end">
          <Button
            size="lg"
            onClick={handleCorrection}
            disabled={analyzing || preparing || fichiers.length === 0}
            className="rounded-xl font-bold bg-emerald-600 text-white hover:bg-emerald-500 px-6"
          >
            {analyzing ? (
              <>
                <LoaderCircle className="mr-2 size-4 animate-spin" /> Mandal IA lit ta copie…
              </>
            ) : (
              <>
                <Sparkles className="mr-2 size-4" /> Demander la correction
              </>
            )}
          </Button>
        </div>

        {rapport && (
          <div className="rounded-2xl border border-emerald-500/30 bg-emerald-500/5 p-5 sm:p-8 space-y-6">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-emerald-500/20 pb-4">
              <div>
                <span className="text-xs font-bold uppercase tracking-wider text-emerald-600 dark:text-emerald-400">
                  Rapport de correction
                </span>
                {rapport.appreciation && (
                  <MathText text={rapport.appreciation} className="mt-1 text-sm text-foreground" />
                )}
              </div>
              <div className="rounded-2xl bg-card border border-emerald-500/30 px-5 py-2.5 text-center shrink-0">
                <span className="text-xs text-muted-foreground block font-medium">Note</span>
                <span className="font-display text-2xl font-black text-emerald-600 dark:text-emerald-400">
                  {rapport.note} / {rapport.sur}
                </span>
                {noteSur20 !== null && rapport.sur !== 20 && (
                  <span className="block text-[11px] text-muted-foreground">
                    soit {noteSur20.toFixed(1)} / 20
                  </span>
                )}
              </div>
            </div>

            {rapport.questions.length > 0 && (
              <div className="rounded-xl bg-card border border-border divide-y divide-border">
                {rapport.questions.map((q, i) => (
                  <div key={i} className="flex gap-3 p-3 text-sm">
                    <span className="font-bold text-primary shrink-0 w-10">{q.numero}</span>
                    <MathText text={q.commentaire} className="flex-1 min-w-0 text-foreground" />
                    <span className="shrink-0 font-semibold tabular-nums">
                      {q.points}/{q.sur}
                    </span>
                  </div>
                ))}
              </div>
            )}

            <div className="grid gap-4 md:grid-cols-2">
              <div className="rounded-xl bg-card p-5 border border-border space-y-3">
                <h4 className="font-bold text-sm text-emerald-600 dark:text-emerald-400 flex items-center gap-2">
                  <CheckCircle2 className="size-4" /> Ce que tu maîtrises
                </h4>
                <ul className="space-y-2 text-sm text-foreground">
                  {rapport.pointsForts.map((pt, i) => (
                    <li key={i} className="flex items-start gap-2">
                      <span className="text-emerald-500">✓</span>
                      <MathText text={pt} className="flex-1 min-w-0" />
                    </li>
                  ))}
                </ul>
              </div>
              <div className="rounded-xl bg-card p-5 border border-border space-y-3">
                <h4 className="font-bold text-sm text-amber-600 dark:text-amber-400 flex items-center gap-2">
                  <AlertTriangle className="size-4" /> Tes difficultés
                </h4>
                <ul className="space-y-2 text-sm text-foreground">
                  {rapport.difficultes.map((d, i) => (
                    <li key={i} className="flex items-start gap-2">
                      <span className="text-amber-500">•</span>
                      <MathText text={d} className="flex-1 min-w-0" />
                    </li>
                  ))}
                </ul>
              </div>
            </div>

            <div className="rounded-xl bg-card p-5 border border-border space-y-4">
              <h4 className="font-bold text-sm text-foreground flex items-center gap-2">
                <Lightbulb className="size-4 text-amber-500" /> Conseils pour progresser
              </h4>
              <ul className="space-y-2 text-sm text-muted-foreground">
                {rapport.conseils.map((c, i) => (
                  <li key={i} className="flex items-start gap-2">
                    <span className="text-primary font-bold">→</span>
                    <MathText text={c} className="flex-1 min-w-0" />
                  </li>
                ))}
              </ul>
              {rapport.chapitresAReviser.length > 0 && (
                <div className="border-t border-border pt-4 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <div>
                    <span className="text-xs text-muted-foreground block">Chapitres à revoir</span>
                    <span className="font-bold text-sm text-foreground">
                      {rapport.chapitresAReviser.join(" · ")}
                    </span>
                  </div>
                  <Button asChild size="sm" className="rounded-xl font-bold shrink-0">
                    <Link to="/etudiant/cours">
                      Ouvrir mes cours <ArrowRight className="ml-1 size-3.5" />
                    </Link>
                  </Button>
                </div>
              )}
            </div>

            {epreuveId && (
              <div className="space-y-3">
                <Button
                  variant="outline"
                  size="sm"
                  className="rounded-xl"
                  onClick={() => setShowCorrige((v) => !v)}
                >
                  <Eye className="mr-2 size-4" />
                  {showCorrige ? "Masquer le corrigé" : "Voir le corrigé détaillé"}
                </Button>
                {showCorrige && (
                  <div className="rounded-xl bg-card border border-border divide-y divide-border">
                    {corrige.map((c, i) => (
                      <div key={i} className="p-3 text-sm space-y-1">
                        <span className="font-bold text-primary">{c.numero}.</span>
                        <MathText text={c.reponse} className="text-foreground" />
                        {c.bareme && (
                          <p className="text-xs text-muted-foreground">Barème : {c.bareme}</p>
                        )}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}
          </div>
        )}
      </section>

      {/* 3. HISTORIQUE */}
      {historique.length > 0 && (
        <section className="rounded-3xl border border-border bg-card p-6 sm:p-8 shadow-sm space-y-4">
          <h2 className="font-display text-xl font-bold text-foreground flex items-center gap-2">
            <History className="size-5 text-primary" /> Mes épreuves
          </h2>
          <ul className="divide-y divide-border">
            {historique.map((row) => {
              const notes = [...(row.corrections_ia ?? [])].sort((a, b) =>
                b.created_at.localeCompare(a.created_at),
              );
              const last = notes[0];
              return (
                <li key={row.id}>
                  <button
                    type="button"
                    onClick={() => openFromHistory(row)}
                    className="w-full flex items-center justify-between gap-3 py-3 text-left hover:text-primary"
                  >
                    <span className="min-w-0">
                      <span className="block truncate font-semibold text-sm">{row.titre}</span>
                      <span className="text-xs text-muted-foreground">
                        {new Date(row.created_at).toLocaleDateString("fr-FR", {
                          day: "numeric",
                          month: "long",
                        })}
                      </span>
                    </span>
                    <span className="shrink-0 rounded-full bg-secondary px-3 py-1 text-xs font-bold">
                      {last ? `${last.note ?? "?"} / ${last.sur ?? 20}` : "Non corrigée"}
                    </span>
                  </button>
                </li>
              );
            })}
          </ul>
        </section>
      )}
    </div>
  );
}
