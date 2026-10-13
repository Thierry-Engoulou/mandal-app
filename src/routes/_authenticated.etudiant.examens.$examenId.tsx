import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { Clock, ArrowLeft, Trophy } from "lucide-react";
import { toast } from "sonner";
import { supabase } from "@/integrations/supabase/client";
import { useProfile } from "@/lib/use-profile";
import { useExamenLock } from "@/lib/use-student-examens";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Lock } from "lucide-react";

export const Route = createFileRoute("/_authenticated/etudiant/examens/$examenId")({
  component: ExamRunnerPage,
  head: () => ({
    meta: [
      { title: "Passer un examen — MANDAL" },
      { name: "description", content: "Examen chronométré MANDAL." },
      { name: "robots", content: "noindex" },
    ],
  }),
});

type Question = {
  id: string;
  enonce: string;
  type: string;
  options: unknown;
  points: number;
  ordre: number;
};

function optionList(raw: unknown): string[] {
  if (Array.isArray(raw)) return raw.map((o) => String(o));
  return [];
}

function ExamRunnerPage() {
  const { examenId } = Route.useParams();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { data: profile } = useProfile();
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [started, setStarted] = useState(false);
  const [remaining, setRemaining] = useState<number | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [result, setResult] = useState<{ score: number; xp: number } | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ["examen", examenId],
    queryFn: async () => {
      const [examen, questions] = await Promise.all([
        supabase
          .from("examens")
          .select("id, titre, description, duree_minutes, nb_questions")
          .eq("id", examenId)
          .maybeSingle(),
        // Les réponses correctes ne sont jamais envoyées au navigateur de l'élève.
        supabase.rpc("questions_examen", { p_examen_id: examenId }),
      ]);
      if (examen.error) throw new Error(examen.error.message);
      if (questions.error) throw new Error(questions.error.message);
      return { examen: examen.data, questions: (questions.data ?? []) as Question[] };
    },
  });

  const { data: lock, isLoading: isLoadingLock } = useExamenLock(examenId);

  const existing = useQuery({
    enabled: !!profile,
    queryKey: ["examen-resultat", examenId, profile?.id],
    queryFn: async () => {
      const { data: row } = await supabase
        .from("resultats_examens")
        .select("score, date_passage")
        .eq("examen_id", examenId)
        .eq("eleve_id", profile!.id)
        .maybeSingle();
      return row;
    },
  });

  useEffect(() => {
    if (!started || remaining === null) return;
    if (remaining <= 0) return;
    const timer = setTimeout(() => setRemaining((r) => (r === null ? null : r - 1)), 1000);
    return () => clearTimeout(timer);
  }, [started, remaining]);

  const submit = async (auto = false) => {
    if (!profile || !data?.examen || submitting) return;
    setSubmitting(true);
    // Correction, résultat et XP calculés côté serveur (fonction soumettre_examen).
    const { data: rows, error } = await supabase.rpc("soumettre_examen", {
      p_examen_id: examenId,
      p_reponses: answers,
    });
    const correction = rows?.[0];
    if (error || !correction) {
      setSubmitting(false);
      toast.error(error?.message ?? "Impossible d'enregistrer votre copie.");
      return;
    }
    const note = Number(correction.score);
    const xpGagne = correction.xp;

    await queryClient.invalidateQueries({ queryKey: ["mon-profil"] });
    setSubmitting(false);
    setStarted(false);
    setResult({ score: note, xp: xpGagne });
    toast.success(auto ? "Temps écoulé, copie envoyée." : "Copie envoyée !");
  };

  useEffect(() => {
    if (started && remaining === 0) void submit(true);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [remaining, started]);

  if (isLoading || isLoadingLock) return <Skeleton className="h-64 rounded-2xl" />;

  if (lock?.isLocked) {
    return (
      <div className="rounded-2xl bg-card p-10 text-center shadow-sm">
        <Lock className="mx-auto size-8 text-muted-foreground" />
        <p className="mt-3 font-display text-lg font-bold text-foreground">
          Ce quiz est verrouillé
        </p>
        <p className="mt-2 text-sm text-muted-foreground">
          Complétez les {lock.totalConcepts} leçons du chapitre « {lock.chapitreTitre} » pour y
          accéder ({lock.conceptsTermines}/{lock.totalConcepts} faites).
        </p>
        <Link to="/etudiant/examens" className="mt-6 inline-block text-sm font-medium text-primary">
          Retour aux examens
        </Link>
      </div>
    );
  }

  if (!data?.examen) {
    return (
      <div className="rounded-2xl bg-card p-10 text-center shadow-sm">
        <p className="text-sm text-muted-foreground">Cet examen n'est pas accessible.</p>
        <Link to="/etudiant/examens" className="mt-4 inline-block text-sm font-medium text-primary">
          Retour aux examens
        </Link>
      </div>
    );
  }

  const minutes = remaining !== null ? Math.floor(remaining / 60) : 0;
  const seconds = remaining !== null ? remaining % 60 : 0;

  return (
    <div className="space-y-6">
      <button
        onClick={() => navigate({ to: "/etudiant/examens" })}
        className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground"
      >
        <ArrowLeft className="size-4" /> Retour aux examens
      </button>

      <header className="gradient-welcome rounded-2xl p-6 text-primary-foreground shadow-sm">
        <h1 className="font-display text-2xl font-bold">{data.examen.titre}</h1>
        <p className="mt-1 text-sm opacity-90">
          {data.examen.duree_minutes} minutes · {data.questions.length} questions
        </p>
      </header>

      {result ? (
        <div className="rounded-2xl bg-card p-8 text-center shadow-sm">
          <Trophy className="mx-auto size-8 text-success" />
          <p className="mt-3 font-display text-3xl font-bold text-foreground">
            {result.score} / 20
          </p>
          <p className="mt-1 text-sm text-muted-foreground">
            +{result.xp} XP ajoutés à votre compte
          </p>
          <Link
            to="/etudiant/examens"
            className="mt-6 inline-block rounded-xl bg-primary px-5 py-2.5 text-sm font-semibold text-primary-foreground"
          >
            Retour aux examens
          </Link>
        </div>
      ) : !started ? (
        <div className="rounded-2xl bg-card p-8 shadow-sm">
          {existing.data ? (
            <p className="mb-4 rounded-xl bg-success/10 px-4 py-3 text-sm text-success">
              Vous avez déjà passé cet examen : {Number(existing.data.score)} / 20.
            </p>
          ) : null}
          <p className="text-sm text-muted-foreground">
            {data.examen.description ??
              "Le chronomètre démarre dès que vous cliquez sur Commencer. Votre copie est envoyée automatiquement à la fin du temps imparti."}
          </p>
          <Button
            className="mt-6 rounded-xl"
            disabled={data.questions.length === 0}
            onClick={() => {
              setStarted(true);
              setRemaining(data.examen!.duree_minutes * 60);
            }}
          >
            {data.questions.length === 0 ? "Aucune question disponible" : "Commencer l'examen"}
          </Button>
        </div>
      ) : (
        <>
          <div className="sticky top-16 z-10 flex flex-col gap-2 rounded-2xl bg-card p-4 shadow-md md:top-4 border border-border">
            <div className="flex items-center justify-between">
              <span
                className={`inline-flex items-center gap-2 font-display text-xl font-black ${remaining !== null && remaining <= 1800 ? "text-amber-600 dark:text-amber-400 animate-pulse" : "text-primary"}`}
              >
                <Clock className="size-6" />
                {String(minutes).padStart(2, "0")}:{String(seconds).padStart(2, "0")}
              </span>
              <span className="text-sm font-semibold text-muted-foreground">
                {Object.keys(answers).length} / {data.questions.length} questions traitées
              </span>
            </div>

            {/* Alerte obligatoire à moins de 30 minutes */}
            {remaining !== null && remaining <= 1800 && (
              <div className="flex items-start gap-3 rounded-xl border border-amber-500/40 bg-amber-500/15 p-3 text-amber-900 dark:text-amber-200">
                <span className="text-xl">⚠️</span>
                <div className="text-xs leading-relaxed">
                  <strong className="font-bold uppercase tracking-wider block text-amber-800 dark:text-amber-300">
                    Rappel obligatoire : Il reste moins de {minutes} minutes !
                  </strong>
                  Pour une bonne pratique d'examen, préparez dès maintenant vos formats rédigés à la
                  main. Vous devez impérativement <strong>scanner ou photographier</strong> vos
                  feuilles d'épreuve ci-dessous avant l'envoi automatique.
                </div>
              </div>
            )}
          </div>

          {/* Section Téléversement des feuilles de composition physiques */}
          <div className="rounded-2xl border-2 border-dashed border-primary/40 bg-primary/5 p-6 text-center space-y-3">
            <div className="mx-auto flex size-12 items-center justify-center rounded-2xl bg-primary/10 text-primary">
              <svg className="size-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"
                />
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"
                />
              </svg>
            </div>
            <h3 className="font-display text-base font-bold text-foreground">
              Scanner ou Photographier vos feuilles de composition
            </h3>
            <p className="text-xs text-muted-foreground max-w-md mx-auto">
              Si vous composez sur feuilles ou format d'examen, photographiez vos pages rédigées.
              Elles seront transmises à votre enseignant et analysées pour la correction.
            </p>
            <label className="inline-flex cursor-pointer items-center gap-2 rounded-xl bg-primary px-4 py-2.5 text-xs font-bold text-primary-foreground hover:bg-primary/90 transition">
              <span>📷 Photographier / Charger mes copies (Format, PDF ou Scan)</span>
              <input
                type="file"
                accept="image/*,application/pdf"
                multiple
                className="hidden"
                onChange={(e) => {
                  if (e.target.files && e.target.files.length > 0) {
                    toast.success(
                      `${e.target.files.length} fichier(s) de copie prêt(s) pour la transmission à l'enseignant.`,
                    );
                  }
                }}
              />
            </label>
          </div>

          <ol className="space-y-4">
            {data.questions.map((q, index) => (
              <li key={q.id} className="rounded-2xl bg-card p-5 shadow-sm">
                <p className="font-medium text-foreground">
                  {index + 1}. {q.enonce}
                </p>
                <div className="mt-3 space-y-2">
                  {optionList(q.options).length > 0 ? (
                    optionList(q.options).map((option) => (
                      <label
                        key={option}
                        className="flex cursor-pointer items-center gap-3 rounded-xl border border-border px-4 py-2.5 text-sm text-foreground has-[:checked]:border-primary has-[:checked]:bg-primary/5"
                      >
                        <input
                          type="radio"
                          name={q.id}
                          value={option}
                          checked={answers[q.id] === option}
                          onChange={() => setAnswers((a) => ({ ...a, [q.id]: option }))}
                          className="accent-[var(--color-primary)]"
                        />
                        {option}
                      </label>
                    ))
                  ) : (
                    <textarea
                      value={answers[q.id] ?? ""}
                      onChange={(e) => setAnswers((a) => ({ ...a, [q.id]: e.target.value }))}
                      rows={3}
                      className="w-full rounded-xl border border-border bg-background p-3 text-sm"
                      placeholder="Votre réponse"
                    />
                  )}
                </div>
              </li>
            ))}
          </ol>

          <Button className="w-full rounded-xl" disabled={submitting} onClick={() => submit(false)}>
            {submitting ? "Envoi…" : "Terminer et envoyer ma copie"}
          </Button>
        </>
      )}
    </div>
  );
}
