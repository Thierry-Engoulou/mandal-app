import { type ReactNode, useMemo, useState } from "react";
import { PALETTE, Verdict } from "./controls";

/** Briques partagées par les simulations de Philosophie de Terminale.
 *  Ce fichier n'enregistre aucune simulation : il fournit les pièces
 *  que les autres fichiers assemblent. */

export function borne(v: number, lo: number, hi: number) {
  return Math.min(hi, Math.max(lo, v));
}

/* ------------------------------------------------------------------ */
/* Le tri : ranger des énoncés dans des catégories                     */
/* ------------------------------------------------------------------ */

export type Categorie = { value: string; label: string; aide?: string };
export type ItemTri = { id: string; texte: string; bonne: string; pourquoi: string };

const CAT_VIDE: Categorie = { value: "", label: "—" };

export function JeuTri({
  consigne,
  categories,
  items,
  conclusion,
}: {
  consigne: string;
  categories: ReadonlyArray<Categorie>;
  items: ReadonlyArray<ItemTri>;
  conclusion?: ReactNode;
}) {
  const [reponses, setReponses] = useState<Record<string, string>>({});

  const repondus = items.filter((it) => reponses[it.id]);
  const justes = items.filter((it) => reponses[it.id] === it.bonne);
  const fini = repondus.length === items.length;

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">{consigne}</p>

      <div className="flex flex-wrap gap-2 rounded-lg border border-border bg-secondary/20 p-2">
        {categories.map((c) => (
          <div key={c.value} className="text-[11px] leading-tight">
            <span className="font-semibold text-foreground">{c.label}</span>
            {c.aide ? <span className="text-muted-foreground"> — {c.aide}</span> : null}
          </div>
        ))}
      </div>

      <ul className="space-y-2">
        {items.map((it) => {
          const choix = reponses[it.id] ?? "";
          const bon = choix === it.bonne;
          const cat = categories.find((c) => c.value === it.bonne) ?? CAT_VIDE;
          return (
            <li key={it.id} className="rounded-lg border border-border bg-background p-2.5">
              <p className="text-sm text-foreground">{it.texte}</p>
              <div className="mt-2 flex flex-wrap gap-1.5">
                {categories.map((c) => {
                  const actif = choix === c.value;
                  const cls = !actif
                    ? "border border-border bg-background text-muted-foreground hover:bg-secondary/60"
                    : bon
                      ? "border border-emerald-500/40 bg-emerald-500/15 text-emerald-700"
                      : "border border-rose-500/40 bg-rose-500/15 text-rose-700";
                  return (
                    <button
                      key={c.value}
                      type="button"
                      onClick={() => setReponses((r) => ({ ...r, [it.id]: c.value }))}
                      className={`rounded-lg px-2.5 py-1 text-xs font-medium ${cls}`}
                    >
                      {c.label}
                    </button>
                  );
                })}
              </div>
              {choix ? (
                <p
                  className="mt-2 text-xs leading-snug"
                  style={{ color: bon ? PALETTE.green : PALETTE.red }}
                >
                  {bon ? "Oui. " : `Non, c'est « ${cat.label} ». `}
                  <span className="text-muted-foreground">{it.pourquoi}</span>
                </p>
              ) : null}
            </li>
          );
        })}
      </ul>

      <p className="text-xs text-muted-foreground">
        {justes.length} bonne(s) réponse(s) sur {repondus.length} essai(s), pour {items.length}{" "}
        énoncés.
      </p>

      {fini ? (
        <Verdict tone={justes.length === items.length ? "ok" : "warn"}>
          {justes.length === items.length
            ? "Tout est classé juste. "
            : "Reprends les énoncés en rouge avant de continuer. "}
          {conclusion}
        </Verdict>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Le parcours : avancer étape par étape, le bon choix seul fait avancer */
/* ------------------------------------------------------------------ */

export type OptionEtape = { texte: string; bonne: boolean; retour: string };
export type Etape = { titre: string; question: string; options: ReadonlyArray<OptionEtape> };

const ETAPE_VIDE: Etape = { titre: "—", question: "—", options: [] };

export function Parcours({
  consigne,
  etapes,
  fin,
}: {
  consigne: string;
  etapes: ReadonlyArray<Etape>;
  fin: ReactNode;
}) {
  const [rang, setRang] = useState(0);
  const [choisi, setChoisi] = useState<number | null>(null);

  const termine = rang >= etapes.length;
  const etape = etapes[rang] ?? ETAPE_VIDE;
  const option = choisi === null ? null : (etape.options[choisi] ?? null);

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">{consigne}</p>

      <div className="flex flex-wrap gap-1.5">
        {etapes.map((e, i) => (
          <span
            key={e.titre}
            className={
              i < rang
                ? "rounded-full bg-emerald-500/15 px-2.5 py-0.5 text-[11px] font-medium text-emerald-700"
                : i === rang
                  ? "rounded-full bg-primary px-2.5 py-0.5 text-[11px] font-semibold text-primary-foreground"
                  : "rounded-full border border-border px-2.5 py-0.5 text-[11px] text-muted-foreground"
            }
          >
            {i + 1}. {e.titre}
          </span>
        ))}
      </div>

      {!termine ? (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="text-sm font-medium text-foreground">{etape.question}</p>
          <ul className="mt-2 space-y-1.5">
            {etape.options.map((o, i) => {
              const actif = choisi === i;
              const cls = !actif
                ? "border-border bg-background hover:bg-secondary/60"
                : o.bonne
                  ? "border-emerald-500/40 bg-emerald-500/10"
                  : "border-rose-500/40 bg-rose-500/10";
              return (
                <li key={o.texte}>
                  <button
                    type="button"
                    onClick={() => setChoisi(i)}
                    className={`w-full rounded-lg border px-2.5 py-1.5 text-left text-xs ${cls}`}
                  >
                    {o.texte}
                  </button>
                </li>
              );
            })}
          </ul>
          {option ? (
            <div className="mt-2 space-y-2">
              <p
                className="text-xs leading-snug"
                style={{ color: option.bonne ? PALETTE.green : PALETTE.red }}
              >
                {option.retour}
              </p>
              {option.bonne ? (
                <button
                  type="button"
                  onClick={() => {
                    setRang((r) => r + 1);
                    setChoisi(null);
                  }}
                  className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                >
                  Étape suivante
                </button>
              ) : null}
            </div>
          ) : null}
        </div>
      ) : (
        <div className="space-y-2">
          <Verdict tone="ok">Parcours terminé.</Verdict>
          <div className="rounded-lg border border-border bg-secondary/20 p-3 text-xs leading-relaxed text-muted-foreground">
            {fin}
          </div>
          <button
            type="button"
            onClick={() => {
              setRang(0);
              setChoisi(null);
            }}
            className="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
          >
            Recommencer
          </button>
        </div>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Les jauges : montrer l'effet d'un réglage                           */
/* ------------------------------------------------------------------ */

export type Jauge = { label: string; valeur: number; couleur: string; note?: string };

export function Jauges({ jauges }: { jauges: ReadonlyArray<Jauge> }) {
  return (
    <ul className="space-y-2">
      {jauges.map((j) => {
        const v = borne(Math.round(j.valeur), 0, 100);
        return (
          <li key={j.label} className="space-y-1">
            <p className="flex items-baseline justify-between gap-2 text-xs">
              <span className="font-medium text-foreground">{j.label}</span>
              <span className="font-mono font-semibold" style={{ color: j.couleur }}>
                {v} %
              </span>
            </p>
            <div className="h-2.5 w-full overflow-hidden rounded-full bg-secondary">
              <div
                className="h-full rounded-full transition-all"
                style={{ width: `${v}%`, backgroundColor: j.couleur }}
              />
            </div>
            {j.note ? (
              <p className="text-[11px] leading-snug text-muted-foreground">{j.note}</p>
            ) : null}
          </li>
        );
      })}
    </ul>
  );
}

/* ------------------------------------------------------------------ */
/* La fiche d'auteur : nom, œuvre, thèse                               */
/* ------------------------------------------------------------------ */

export type Auteur = {
  id: string;
  nom: string;
  dates?: string;
  oeuvre: string;
  these: string;
  camp: string;
};

export function Galerie({ auteurs }: { auteurs: ReadonlyArray<Auteur> }) {
  const [ouvert, setOuvert] = useState<string>("");
  return (
    <div className="grid gap-2 sm:grid-cols-2">
      {auteurs.map((a) => (
        <button
          key={a.id}
          type="button"
          onClick={() => setOuvert((o) => (o === a.id ? "" : a.id))}
          className={
            ouvert === a.id
              ? "rounded-lg border border-primary/50 bg-primary/5 p-2.5 text-left"
              : "rounded-lg border border-border bg-background p-2.5 text-left hover:bg-secondary/40"
          }
        >
          <p className="text-sm font-semibold text-foreground">
            {a.nom}
            {a.dates ? (
              <span className="ml-1 font-normal text-muted-foreground">({a.dates})</span>
            ) : null}
          </p>
          <p className="text-[11px] italic leading-snug text-muted-foreground">{a.oeuvre}</p>
          {ouvert === a.id ? (
            <p className="mt-1.5 text-xs leading-snug text-foreground">{a.these}</p>
          ) : null}
        </button>
      ))}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Le barème : répartir des points et se faire corriger                */
/* ------------------------------------------------------------------ */

export type Poste = { id: string; label: string; points: number; aide: string };

export function RepartirPoints({
  consigne,
  postes,
  total,
}: {
  consigne: string;
  postes: ReadonlyArray<Poste>;
  total: number;
}) {
  const depart = useMemo(() => {
    const o: Record<string, number> = {};
    for (const p of postes) o[p.id] = 0;
    return o;
  }, [postes]);
  const [mise, setMise] = useState<Record<string, number>>(depart);
  const [corrige, setCorrige] = useState(false);

  const somme = postes.reduce((s, p) => s + (mise[p.id] ?? 0), 0);
  const exact = postes.every((p) => (mise[p.id] ?? 0) === p.points);

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">{consigne}</p>

      <ul className="space-y-2">
        {postes.map((p) => {
          const v = mise[p.id] ?? 0;
          const bon = v === p.points;
          return (
            <li key={p.id} className="rounded-lg border border-border bg-background p-2.5">
              <div className="flex flex-wrap items-center justify-between gap-2">
                <p className="text-sm text-foreground">{p.label}</p>
                <div className="flex items-center gap-1">
                  <button
                    type="button"
                    onClick={() =>
                      setMise((m) => ({ ...m, [p.id]: borne((m[p.id] ?? 0) - 1, 0, total) }))
                    }
                    className="h-7 w-7 rounded-lg border border-border text-sm font-semibold text-muted-foreground"
                  >
                    −
                  </button>
                  <span
                    className="w-10 text-center font-mono text-sm font-semibold"
                    style={{
                      color: corrige ? (bon ? PALETTE.green : PALETTE.red) : PALETTE.ink,
                    }}
                  >
                    {v}
                  </span>
                  <button
                    type="button"
                    onClick={() =>
                      setMise((m) => ({ ...m, [p.id]: borne((m[p.id] ?? 0) + 1, 0, total) }))
                    }
                    className="h-7 w-7 rounded-lg border border-border text-sm font-semibold text-muted-foreground"
                  >
                    +
                  </button>
                </div>
              </div>
              {corrige ? (
                <p className="mt-1.5 text-xs leading-snug text-muted-foreground">
                  <span className="font-semibold text-foreground">{p.points} point(s). </span>
                  {p.aide}
                </p>
              ) : null}
            </li>
          );
        })}
      </ul>

      <div className="flex flex-wrap items-center gap-2">
        <span
          className="rounded-lg border border-border px-2.5 py-1 font-mono text-xs font-semibold"
          style={{ color: somme === total ? PALETTE.green : PALETTE.orange }}
        >
          total : {somme} / {total}
        </span>
        <button
          type="button"
          onClick={() => setCorrige(true)}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Comparer au barème officiel
        </button>
        <button
          type="button"
          onClick={() => {
            setMise(depart);
            setCorrige(false);
          }}
          className="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Effacer
        </button>
      </div>

      {corrige ? (
        <Verdict tone={exact ? "ok" : "warn"}>
          {exact
            ? "C'est exactement le barème de l'épreuve. Tu sais désormais où sont les points."
            : "Les chiffres exacts sont affichés sous chaque poste. Apprends-les : savoir où sont les points change la façon de rédiger."}
        </Verdict>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* L'ordre : remettre des éléments dans le bon ordre                   */
/* ------------------------------------------------------------------ */

export type ElementOrdre = { id: string; texte: string; rang: number; pourquoi: string };

export function MettreEnOrdre({
  consigne,
  elements,
  conclusion,
}: {
  consigne: string;
  elements: ReadonlyArray<ElementOrdre>;
  conclusion: ReactNode;
}) {
  const [pile, setPile] = useState<string[]>([]);

  const restants = elements.filter((e) => !pile.includes(e.id));
  const fini = pile.length === elements.length;
  const juste = pile.every((id, i) => {
    const e = elements.find((x) => x.id === id);
    return e ? e.rang === i + 1 : false;
  });

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">{consigne}</p>

      <ol className="space-y-1.5">
        {pile.map((id, i) => {
          const e = elements.find((x) => x.id === id);
          if (!e) return null;
          const bon = e.rang === i + 1;
          return (
            <li
              key={id}
              className="rounded-lg border px-2.5 py-1.5 text-xs"
              style={{
                borderColor: bon ? "rgba(22,163,74,0.4)" : "rgba(220,38,38,0.4)",
                backgroundColor: bon ? "rgba(22,163,74,0.08)" : "rgba(220,38,38,0.08)",
              }}
            >
              <span className="font-semibold">{i + 1}. </span>
              {e.texte}
              {!bon ? (
                <span className="block text-[11px] text-muted-foreground">
                  Sa place est la {e.rang}e. {e.pourquoi}
                </span>
              ) : null}
            </li>
          );
        })}
      </ol>

      {restants.length > 0 ? (
        <div className="flex flex-wrap gap-1.5">
          {restants.map((e) => (
            <button
              key={e.id}
              type="button"
              onClick={() => setPile((p) => [...p, e.id])}
              className="rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs text-muted-foreground hover:bg-secondary/60"
            >
              {e.texte}
            </button>
          ))}
        </div>
      ) : null}

      {fini ? (
        <div className="space-y-2">
          <Verdict tone={juste ? "ok" : "bad"}>
            {juste ? "L'ordre est le bon. " : "L'ordre n'est pas bon, les écarts sont signalés. "}
            {conclusion}
          </Verdict>
          <button
            type="button"
            onClick={() => setPile([])}
            className="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
          >
            Recommencer
          </button>
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Le QCM : une question à la fois, chacune avec ses propres options    */
/* ------------------------------------------------------------------ */

export type OptionQcm = { texte: string; bonne: boolean; retour: string };
export type Question = {
  id: string;
  enonce: string;
  precision?: string;
  options: ReadonlyArray<OptionQcm>;
  suite?: string;
};

const QUESTION_VIDE: Question = { id: "", enonce: "—", options: [] };

export function Qcm({
  consigne,
  questions,
  conclusion,
}: {
  consigne: string;
  questions: ReadonlyArray<Question>;
  conclusion: ReactNode;
}) {
  const [rang, setRang] = useState(0);
  const [choisi, setChoisi] = useState<number | null>(null);
  const [score, setScore] = useState(0);
  const [essais, setEssais] = useState(0);

  const termine = rang >= questions.length;
  const q = questions[rang] ?? QUESTION_VIDE;
  const option = choisi === null ? null : (q.options[choisi] ?? null);

  function repondre(i: number) {
    if (choisi !== null) return;
    const o = q.options[i];
    setChoisi(i);
    setEssais((e) => e + 1);
    if (o && o.bonne) setScore((s) => s + 1);
  }

  if (termine) {
    const tone = score === questions.length ? "ok" : score * 2 >= questions.length ? "warn" : "bad";
    return (
      <div className="space-y-2">
        <Verdict tone={tone}>
          {score} bonne(s) réponse(s) sur {questions.length}.
        </Verdict>
        <div className="rounded-lg border border-border bg-secondary/20 p-3 text-xs leading-relaxed text-muted-foreground">
          {conclusion}
        </div>
        <button
          type="button"
          onClick={() => {
            setRang(0);
            setChoisi(null);
            setScore(0);
            setEssais(0);
          }}
          className="rounded-lg border border-border px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Recommencer
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      <p className="text-sm text-muted-foreground">{consigne}</p>

      <p className="text-xs font-medium text-muted-foreground">
        Question {rang + 1} sur {questions.length} · {score} juste(s) sur {essais}
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm font-medium leading-snug text-foreground">{q.enonce}</p>
        {q.precision ? (
          <p className="mt-1 text-[11px] italic leading-snug text-muted-foreground">
            {q.precision}
          </p>
        ) : null}

        <ul className="mt-2 space-y-1.5">
          {q.options.map((o, i) => {
            const actif = choisi === i;
            const revele = choisi !== null;
            const cls = !revele
              ? "border-border bg-background hover:bg-secondary/60"
              : o.bonne
                ? "border-emerald-500/40 bg-emerald-500/10"
                : actif
                  ? "border-rose-500/40 bg-rose-500/10"
                  : "border-border bg-background opacity-60";
            return (
              <li key={o.texte}>
                <button
                  type="button"
                  onClick={() => repondre(i)}
                  className={`w-full rounded-lg border px-2.5 py-1.5 text-left text-xs leading-snug ${cls}`}
                >
                  {o.texte}
                </button>
              </li>
            );
          })}
        </ul>

        {option ? (
          <div className="mt-2 space-y-2">
            <p
              className="text-xs leading-snug"
              style={{ color: option.bonne ? PALETTE.green : PALETTE.red }}
            >
              {option.retour}
            </p>
            {q.suite ? (
              <p className="rounded-lg bg-secondary/40 px-2.5 py-1.5 text-[11px] leading-snug text-muted-foreground">
                {q.suite}
              </p>
            ) : null}
            <button
              type="button"
              onClick={() => {
                setRang((r) => r + 1);
                setChoisi(null);
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              {rang + 1 === questions.length ? "Voir le bilan" : "Suivant"}
            </button>
          </div>
        ) : null}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* La citation encadrée                                                */
/* ------------------------------------------------------------------ */

export function Citation({ auteur, children }: { auteur: string; children: ReactNode }) {
  return (
    <blockquote className="rounded-lg border-l-2 border-primary/50 bg-secondary/20 px-3 py-2">
      <p className="text-xs italic leading-relaxed text-foreground">{children}</p>
      <p className="mt-1 text-[11px] font-medium text-muted-foreground">— {auteur}</p>
    </blockquote>
  );
}
