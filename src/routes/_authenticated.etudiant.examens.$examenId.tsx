import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, useMemo, useState } from "react";
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
        supabase
          .from("questions")
          .select("id, enonce, type, options, points, ordre")
          .eq("examen_id", examenId)
          .order("ordre"),
      ]);
      if (examen.error) throw new Error(examen.error.message);
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

  const totalPoints = useMemo(
    () => (data?.questions ?? []).reduce((sum, q) => sum + (q.points || 1), 0),
    [data],
  );

  const submit = async (auto = false) => {
    if (!profile || !data?.examen || submitting) return;
    setSubmitting(true);
    const { data: correction, error: corrError } = await supabase
      .from("questions")
      .select("id, reponse_correcte, points")
      .eq("examen_id", examenId);
    if (corrError) {
      setSubmitting(false);
      toast.error("Impossible d'enregistrer votre copie.");
      return;
    }
    let obtained = 0;
    for (const q of correction ?? []) {
      const given = answers[q.id];
      if (given && q.reponse_correcte && given.trim() === q.reponse_correcte.trim()) {
        obtained += q.points || 1;
      }
    }
    const note = totalPoints > 0 ? Math.round((obtained / totalPoints) * 20 * 100) / 100 : 0;
    const xpGagne = Math.round(note * 5);

    const { error } = await supabase.from("resultats_examens").insert({
      examen_id: examenId,
      eleve_id: profile.id,
      score: note,
      reponses: answers,
    });
    if (error) {
      setSubmitting(false);
      toast.error(error.message);
      return;
    }
    await supabase.from("xp_transactions").insert({
      profile_id: profile.id,
      montant: xpGagne,
      source: "examen",
      description: data.examen.titre,
    });
    await supabase
      .from("profiles")
      .update({ xp_total: (profile.xp_total ?? 0) + xpGagne })
      .eq("id", profile.id);

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
        <p className="mt-3 font-display text-lg font-bold text-foreground">Ce quiz est verrouillé</p>
        <p className="mt-2 text-sm text-muted-foreground">
          Complétez les {lock.totalConcepts} leçons du chapitre « {lock.chapitreTitre} » pour y accéder
          ({lock.conceptsTermines}/{lock.totalConcepts} faites).
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
          <p className="mt-3 font-display text-3xl font-bold text-foreground">{result.score} / 20</p>
          <p className="mt-1 text-sm text-muted-foreground">+{result.xp} XP ajoutés à votre compte</p>
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
          <div className="sticky top-16 z-10 flex items-center justify-between rounded-2xl bg-card px-5 py-3 shadow-sm md:top-4">
            <span className="inline-flex items-center gap-2 font-display text-lg font-bold text-foreground">
              <Clock className="size-5 text-primary" />
              {String(minutes).padStart(2, "0")}:{String(seconds).padStart(2, "0")}
            </span>
            <span className="text-sm text-muted-foreground">
              {Object.keys(answers).length} / {data.questions.length} répondues
            </span>
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
