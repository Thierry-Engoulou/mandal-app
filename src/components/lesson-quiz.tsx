import { useMemo, useState } from "react";
import { MathText } from "@/components/math-text";

/**
 * Leçon de type "quiz" : un petit contrôle de 3 à 6 questions placé juste après
 * la leçon. L'élève répond, voit tout de suite si c'est juste et pourquoi.
 * Rien n'est enregistré : c'est un entraînement, pas une note.
 *
 * Contenu de la leçon (JSON) :
 * {
 *   "titre": "Vérifie que tu as compris",
 *   "questions": [
 *     { "question": "...", "choix": ["...", "..."], "bonne": 0, "explication": "..." }
 *   ]
 * }
 */

export const QUIZ_SPEC_PLACEHOLDER = `{
  "titre": "Vérifie que tu as compris",
  "questions": [
    {
      "question": "Quel est le PGCD de $24$ et $36$ ?",
      "choix": ["6", "12", "72"],
      "bonne": 1,
      "explication": "Les diviseurs communs sont 1, 2, 3, 4, 6 et 12. Le plus grand est 12."
    }
  ]
}`;

type Question = {
  question?: string;
  choix?: string[];
  bonne?: number;
  explication?: string;
};

type QuizSpec = { titre?: string; questions?: Question[] };

export function LessonQuiz({ spec }: { spec: string }) {
  const parsed = useMemo<QuizSpec | null>(() => {
    const brut = (spec ?? "").trim();
    if (!brut.startsWith("{")) return null;
    try {
      return JSON.parse(brut) as QuizSpec;
    } catch {
      return null;
    }
  }, [spec]);

  const questions = useMemo(
    () => (parsed?.questions ?? []).filter((q) => q.question && (q.choix ?? []).length >= 2),
    [parsed],
  );

  const [reponses, setReponses] = useState<Record<number, number>>({});
  const [tour, setTour] = useState(0);

  if (!parsed || questions.length === 0) {
    return (
      <p className="rounded-xl border border-destructive/30 bg-destructive/5 px-3 py-2 text-sm text-destructive">
        Ce quiz n'a pas encore de questions.
      </p>
    );
  }

  const repondues = Object.keys(reponses).length;
  const justes = questions.reduce((acc, q, i) => {
    const choisi = reponses[i];
    return choisi !== undefined && choisi === (q.bonne ?? 0) ? acc + 1 : acc;
  }, 0);
  const fini = repondues === questions.length;

  return (
    <div className="space-y-4" key={tour}>
      <div className="flex items-baseline justify-between gap-3">
        <p className="text-sm font-semibold text-foreground">
          {parsed.titre || "Vérifie que tu as compris"}
        </p>
        <p className="shrink-0 text-xs text-muted-foreground">
          {repondues} / {questions.length}
        </p>
      </div>

      {questions.map((q, i) => {
        const choisi = reponses[i];
        const bonne = q.bonne ?? 0;
        const repondu = choisi !== undefined;
        return (
          <div key={i} className="rounded-xl border border-border bg-card p-3">
            <div className="mb-2 flex gap-2">
              <span className="mt-0.5 flex size-5 shrink-0 items-center justify-center rounded-full bg-secondary text-[11px] font-semibold text-muted-foreground">
                {i + 1}
              </span>
              <MathText
                text={q.question ?? ""}
                className="text-sm font-medium leading-relaxed text-foreground"
              />
            </div>
            <div className="space-y-1.5">
              {(q.choix ?? []).map((c, j) => {
                const estBonne = j === bonne;
                const estChoisi = choisi === j;
                let cls = "w-full rounded-lg border px-3 py-2 text-left text-sm transition-colors";
                if (!repondu) {
                  cls += " border-border hover:bg-secondary/60";
                } else if (estBonne) {
                  cls += " border-emerald-500/40 bg-emerald-500/10 text-emerald-800";
                } else if (estChoisi) {
                  cls += " border-rose-500/40 bg-rose-500/10 text-rose-800";
                } else {
                  cls += " border-border opacity-60";
                }
                return (
                  <button
                    key={j}
                    type="button"
                    disabled={repondu}
                    onClick={() => setReponses({ ...reponses, [i]: j })}
                    className={cls}
                  >
                    <span className="flex items-start gap-2">
                      <span className="mt-0.5 font-mono text-xs text-muted-foreground">
                        {String.fromCharCode(97 + j)}.
                      </span>
                      <MathText text={c} className="flex-1" />
                      {repondu && estBonne ? <span className="text-sm">✓</span> : null}
                      {repondu && estChoisi && !estBonne ? (
                        <span className="text-sm">✗</span>
                      ) : null}
                    </span>
                  </button>
                );
              })}
            </div>
            {repondu ? (
              <div
                className={
                  choisi === bonne
                    ? "mt-2 rounded-lg border border-emerald-500/30 bg-emerald-500/5 px-3 py-2"
                    : "mt-2 rounded-lg border border-amber-500/30 bg-amber-500/5 px-3 py-2"
                }
              >
                <p className="mb-0.5 text-xs font-semibold text-foreground">
                  {choisi === bonne ? "C'est juste." : "Pas tout à fait."}
                </p>
                {q.explication ? (
                  <MathText
                    text={q.explication}
                    className="text-xs leading-relaxed text-muted-foreground"
                  />
                ) : null}
              </div>
            ) : null}
          </div>
        );
      })}

      {fini ? (
        <div className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-primary/25 bg-primary/5 px-3 py-2.5">
          <p className="text-sm font-medium text-foreground">
            {justes} bonne{justes > 1 ? "s" : ""} réponse{justes > 1 ? "s" : ""} sur{" "}
            {questions.length}.{" "}
            {justes === questions.length
              ? "Tu peux passer à la suite."
              : justes * 2 >= questions.length
                ? "C'est en bonne voie, relis le passage qui t'a manqué."
                : "Reprends la leçon tranquillement, puis réessaie."}
          </p>
          <button
            type="button"
            onClick={() => {
              setReponses({});
              setTour(tour + 1);
            }}
            className="shrink-0 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Recommencer
          </button>
        </div>
      ) : null}
    </div>
  );
}
