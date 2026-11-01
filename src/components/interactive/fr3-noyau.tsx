import { type ReactNode, useMemo, useState } from "react";
import { PALETTE, Verdict } from "./controls";

/** Briques partagées par les simulations de Français de 3ème.
 *  Ce fichier n'enregistre aucune simulation : il fournit les moteurs
 *  que les cinq modules réemploient.
 *
 *  Les mécaniques générales — trier, enchaîner des étapes, répondre à un QCM —
 *  viennent de philo-noyau.tsx. Ici vivent les trois moteurs propres à la
 *  langue : transformer une phrase, surligner dans un texte, conjuguer. */

/* ------------------------------------------------------------------ */
/* Comparaison souple d'une réponse écrite                             */
/* ------------------------------------------------------------------ */

/** On ignore la casse, les espaces en trop et la ponctuation finale.
 *  On ne touche NI aux accents NI aux apostrophes : en français, ce sont
 *  des fautes, pas des détails. */
export function normaliser(s: string): string {
  return s
    .trim()
    .toLowerCase()
    .replace(/\s+/g, " ")
    .replace(/[.!?;:]+$/u, "")
    .replace(/[’‘]/g, "'")
    .trim();
}

export function memeReponse(saisie: string, attendues: ReadonlyArray<string>): boolean {
  const n = normaliser(saisie);
  return attendues.some((a) => normaliser(a) === n);
}

/* ------------------------------------------------------------------ */
/* Transformer : réécrire une phrase, et se faire corriger             */
/* ------------------------------------------------------------------ */

export type Indice = { quand: RegExp; message: string };

export type Transformation = {
  id: string;
  consigne: string;
  depart: string;
  attendues: ReadonlyArray<string>;
  explication: string;
  /** Pièges reconnus dans une réponse fausse, pour répondre précisément. */
  indices?: ReadonlyArray<Indice>;
  /** Message affiché quand aucun indice ne correspond. */
  aide?: string;
};

const TRANSFO_VIDE: Transformation = {
  id: "",
  consigne: "—",
  depart: "—",
  attendues: [],
  explication: "—",
};

export function Transformer({
  consigne,
  items,
  conclusion,
}: {
  consigne: string;
  items: ReadonlyArray<Transformation>;
  conclusion: ReactNode;
}) {
  const [rang, setRang] = useState(0);
  const [saisie, setSaisie] = useState("");
  const [verifie, setVerifie] = useState(false);
  const [score, setScore] = useState(0);
  const [essais, setEssais] = useState(0);

  const t = items[rang] ?? TRANSFO_VIDE;
  const juste = verifie && memeReponse(saisie, t.attendues);

  const remarque = useMemo(() => {
    if (!verifie || juste) return "";
    for (const i of t.indices ?? []) {
      if (i.quand.test(saisie)) return i.message;
    }
    return t.aide ?? "Compare ta phrase à la correction, mot à mot.";
  }, [verifie, juste, saisie, t]);

  const termine = rang >= items.length;

  if (termine) {
    return (
      <div className="space-y-2">
        <Verdict tone={score === items.length ? "ok" : score * 2 >= items.length ? "warn" : "bad"}>
          {score} réussite(s) du premier coup sur {items.length}.
        </Verdict>
        <div className="rounded-lg border border-border bg-secondary/20 p-3 text-xs leading-relaxed text-muted-foreground">
          {conclusion}
        </div>
        <button
          type="button"
          onClick={() => {
            setRang(0);
            setSaisie("");
            setVerifie(false);
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
        Phrase {rang + 1} sur {items.length} · {score} juste(s) du premier coup
      </p>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
          {t.consigne}
        </p>
        <p className="mt-1.5 text-sm italic leading-relaxed text-foreground">{t.depart}</p>

        <textarea
          value={saisie}
          onChange={(e) => {
            setSaisie(e.target.value);
            setVerifie(false);
          }}
          rows={2}
          placeholder="Écris ta phrase ici…"
          className="mt-2 w-full resize-none rounded-lg border border-border bg-background px-2.5 py-1.5 text-sm text-foreground outline-none focus:border-primary"
        />

        {!verifie ? (
          <button
            type="button"
            onClick={() => {
              setVerifie(true);
              setEssais((e) => e + 1);
              if (memeReponse(saisie, t.attendues) && essais === 0) setScore((s) => s + 1);
            }}
            className="mt-2 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Vérifier
          </button>
        ) : (
          <div className="mt-2 space-y-2">
            <Verdict tone={juste ? "ok" : "bad"}>
              {juste ? "C'est juste. " : "Pas encore. "}
              {juste ? t.explication : remarque}
            </Verdict>
            {!juste ? (
              <details className="rounded-lg border border-border bg-secondary/20 px-2.5 py-1.5">
                <summary className="cursor-pointer text-xs font-medium text-muted-foreground">
                  Voir la correction
                </summary>
                <p className="mt-1.5 text-sm font-medium text-foreground">{t.attendues[0]}</p>
                <p className="mt-1 text-xs leading-snug text-muted-foreground">{t.explication}</p>
              </details>
            ) : null}
            <button
              type="button"
              onClick={() => {
                setRang((r) => r + 1);
                setSaisie("");
                setVerifie(false);
                setEssais(0);
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              {rang + 1 === items.length ? "Voir le bilan" : "Phrase suivante"}
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Surligner : cliquer des mots dans un texte                          */
/* ------------------------------------------------------------------ */

export type Jeton = {
  /** Le mot tel qu'il s'affiche. */
  mot: string;
  /** true si ce jeton fait partie de la réponse attendue. */
  bon?: boolean;
  /** Explication montrée quand on le clique. */
  pourquoi?: string;
  /** false pour la ponctuation et les mots non cliquables. */
  cliquable?: boolean;
};

export type Releve = {
  id: string;
  consigne: string;
  jetons: ReadonlyArray<Jeton>;
  /** Nombre de mots demandés ; 0 signifie « tous les bons ». */
  combien: number;
  bilan: string;
};

const RELEVE_VIDE: Releve = { id: "", consigne: "—", jetons: [], combien: 0, bilan: "—" };

export function Surligner({
  consigne,
  releves,
  conclusion,
}: {
  consigne: string;
  releves: ReadonlyArray<Releve>;
  conclusion: ReactNode;
}) {
  const [rang, setRang] = useState(0);
  const [choisis, setChoisis] = useState<number[]>([]);
  const [verifie, setVerifie] = useState(false);

  const r = releves[rang] ?? RELEVE_VIDE;
  const attendus = r.jetons.reduce((n, j) => n + (j.bon ? 1 : 0), 0);
  const cible = r.combien > 0 ? r.combien : attendus;
  const justes = choisis.filter((i) => r.jetons[i]?.bon).length;
  const faux = choisis.length - justes;
  const termine = rang >= releves.length;

  if (termine) {
    return (
      <div className="space-y-2">
        <Verdict tone="ok">Relevés terminés.</Verdict>
        <div className="rounded-lg border border-border bg-secondary/20 p-3 text-xs leading-relaxed text-muted-foreground">
          {conclusion}
        </div>
        <button
          type="button"
          onClick={() => {
            setRang(0);
            setChoisis([]);
            setVerifie(false);
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
      <p className="rounded-lg bg-secondary/40 px-2.5 py-1.5 text-xs font-medium text-foreground">
        {r.consigne}
      </p>

      <div className="rounded-lg border border-border bg-background p-3 leading-loose">
        {r.jetons.map((j, i) => {
          if (j.cliquable === false) {
            return (
              <span key={`${j.mot}-${i}`} className="text-sm text-foreground">
                {j.mot}{" "}
              </span>
            );
          }
          const pris = choisis.includes(i);
          const cls = !pris
            ? "hover:bg-secondary"
            : verifie
              ? j.bon
                ? "bg-emerald-500/25 text-emerald-800"
                : "bg-rose-500/25 text-rose-800"
              : "bg-primary/20";
          return (
            <button
              key={`${j.mot}-${i}`}
              type="button"
              onClick={() => {
                if (verifie) return;
                setChoisis((c) => (c.includes(i) ? c.filter((x) => x !== i) : [...c, i]));
              }}
              className={`mr-1 rounded px-0.5 text-sm text-foreground ${cls}`}
            >
              {j.mot}
            </button>
          );
        })}
      </div>

      <div className="flex flex-wrap items-center gap-2">
        <span
          className="rounded-lg border border-border px-2.5 py-1 font-mono text-xs font-semibold"
          style={{ color: choisis.length === cible ? PALETTE.green : PALETTE.orange }}
        >
          {r.combien > 0 ? `${choisis.length} / ${cible} relevé(s)` : `${choisis.length} relevé(s)`}
        </span>
        {!verifie ? (
          <button
            type="button"
            onClick={() => setVerifie(true)}
            className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Vérifier
          </button>
        ) : (
          <button
            type="button"
            onClick={() => {
              setRang((x) => x + 1);
              setChoisis([]);
              setVerifie(false);
            }}
            className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            {rang + 1 === releves.length ? "Voir le bilan" : "Texte suivant"}
          </button>
        )}
        {choisis.length > 0 && !verifie ? (
          <button
            type="button"
            onClick={() => setChoisis([])}
            className="rounded-lg border border-border px-2.5 py-1 text-xs text-muted-foreground hover:bg-secondary/60"
          >
            Effacer
          </button>
        ) : null}
      </div>

      {verifie ? (
        <div className="space-y-2">
          <Verdict tone={justes === cible && faux === 0 ? "ok" : faux === 0 ? "warn" : "bad"}>
            {justes} bon(s) relevé(s)
            {faux > 0 ? `, et ${faux} erreur(s)` : ""}. {r.bilan}
          </Verdict>
          <ul className="space-y-1">
            {choisis.map((i) => {
              const j = r.jetons[i];
              if (!j || !j.pourquoi) return null;
              return (
                <li
                  key={i}
                  className="text-[11px] leading-snug"
                  style={{ color: j.bon ? PALETTE.green : PALETTE.red }}
                >
                  <span className="font-semibold">{j.mot}</span> — {j.pourquoi}
                </li>
              );
            })}
          </ul>
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Conjuguer : un tableau de personnes à remplir                       */
/* ------------------------------------------------------------------ */

export const PERSONNES = [
  "je",
  "tu",
  "il / elle",
  "nous",
  "vous",
  "ils / elles",
] as const;

export type Conjugaison = {
  id: string;
  verbe: string;
  temps: string;
  groupe: string;
  /** Six formes, sans le pronom. */
  formes: ReadonlyArray<string>;
  piege?: string;
};

const CONJ_VIDE: Conjugaison = {
  id: "",
  verbe: "—",
  temps: "—",
  groupe: "—",
  formes: ["", "", "", "", "", ""],
};

export function Conjuguer({
  consigne,
  tableaux,
  conclusion,
}: {
  consigne: string;
  tableaux: ReadonlyArray<Conjugaison>;
  conclusion: ReactNode;
}) {
  const [rang, setRang] = useState(0);
  const [saisies, setSaisies] = useState<string[]>(["", "", "", "", "", ""]);
  const [verifie, setVerifie] = useState(false);

  const c = tableaux[rang] ?? CONJ_VIDE;
  const justes = c.formes.filter((f, i) => memeReponse(saisies[i] ?? "", [f])).length;
  const termine = rang >= tableaux.length;

  if (termine) {
    return (
      <div className="space-y-2">
        <Verdict tone="ok">Tableaux terminés.</Verdict>
        <div className="rounded-lg border border-border bg-secondary/20 p-3 text-xs leading-relaxed text-muted-foreground">
          {conclusion}
        </div>
        <button
          type="button"
          onClick={() => {
            setRang(0);
            setSaisies(["", "", "", "", "", ""]);
            setVerifie(false);
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

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm font-semibold text-foreground">
          {c.verbe} <span className="font-normal text-muted-foreground">— {c.temps}</span>
        </p>
        <p className="text-[11px] italic text-muted-foreground">{c.groupe}</p>

        <ul className="mt-2 space-y-1">
          {PERSONNES.map((p, i) => {
            const attendue = c.formes[i] ?? "";
            const saisie = saisies[i] ?? "";
            const bon = memeReponse(saisie, [attendue]);
            return (
              <li key={p} className="flex items-center gap-2">
                <span className="w-20 shrink-0 text-right text-xs text-muted-foreground">{p}</span>
                <input
                  value={saisie}
                  onChange={(e) => {
                    const v = e.target.value;
                    setSaisies((s) => s.map((x, k) => (k === i ? v : x)));
                    setVerifie(false);
                  }}
                  className="flex-1 rounded-lg border px-2 py-1 text-sm outline-none focus:border-primary"
                  style={{
                    borderColor: !verifie
                      ? "hsl(var(--border))"
                      : bon
                        ? "rgba(22,163,74,0.5)"
                        : "rgba(220,38,38,0.5)",
                    backgroundColor: !verifie
                      ? "transparent"
                      : bon
                        ? "rgba(22,163,74,0.08)"
                        : "rgba(220,38,38,0.08)",
                  }}
                />
                {verifie && !bon ? (
                  <span className="w-28 shrink-0 font-mono text-xs" style={{ color: PALETTE.green }}>
                    {attendue}
                  </span>
                ) : null}
              </li>
            );
          })}
        </ul>

        <div className="mt-2 flex flex-wrap items-center gap-2">
          {!verifie ? (
            <button
              type="button"
              onClick={() => setVerifie(true)}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Vérifier le tableau
            </button>
          ) : (
            <button
              type="button"
              onClick={() => {
                setRang((r) => r + 1);
                setSaisies(["", "", "", "", "", ""]);
                setVerifie(false);
              }}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              {rang + 1 === tableaux.length ? "Voir le bilan" : "Verbe suivant"}
            </button>
          )}
          <span className="text-xs text-muted-foreground">
            {rang + 1} / {tableaux.length}
          </span>
        </div>

        {verifie ? (
          <div className="mt-2 space-y-1.5">
            <Verdict tone={justes === 6 ? "ok" : justes >= 4 ? "warn" : "bad"}>
              {justes} forme(s) juste(s) sur 6.
            </Verdict>
            {c.piege ? (
              <p className="rounded-lg bg-secondary/40 px-2.5 py-1.5 text-[11px] leading-snug text-muted-foreground">
                {c.piege}
              </p>
            ) : null}
          </div>
        ) : null}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Le texte annoté, pour montrer un résultat                           */
/* ------------------------------------------------------------------ */

export type Segment = { texte: string; couleur?: string; note?: string };

export function TexteColore({
  segments,
  legende,
}: {
  segments: ReadonlyArray<Segment>;
  legende?: ReadonlyArray<{ label: string; couleur: string }>;
}) {
  return (
    <div className="space-y-2">
      {legende ? (
        <div className="flex flex-wrap gap-2">
          {legende.map((l) => (
            <span key={l.label} className="flex items-center gap-1 text-[11px] text-muted-foreground">
              <span
                className="inline-block h-2.5 w-2.5 rounded-sm"
                style={{ backgroundColor: l.couleur }}
              />
              {l.label}
            </span>
          ))}
        </div>
      ) : null}
      <p className="rounded-lg border border-border bg-background p-3 text-sm leading-relaxed">
        {segments.map((s, i) => (
          <span
            key={i}
            title={s.note ?? ""}
            style={
              s.couleur
                ? { backgroundColor: s.couleur, borderRadius: "3px", padding: "0 2px" }
                : undefined
            }
          >
            {s.texte}
          </span>
        ))}
      </p>
    </div>
  );
}
