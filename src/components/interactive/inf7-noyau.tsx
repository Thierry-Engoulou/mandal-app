import { useState } from "react";
import type { ReactNode } from "react";
import { PALETTE, Panel, Stat, Verdict } from "./controls";

/** Briques communes aux simulations d'Informatique de Terminale C et D. */

export function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* Cocher plusieurs bonnes réponses dans une liste                     */
/* ------------------------------------------------------------------ */

export type Case = { id: string; label: string; bonne: boolean; pourquoi: string };

export function JeuCases({
  titre,
  cases,
  attendu,
  aide,
}: {
  titre: string;
  cases: ReadonlyArray<Case>;
  attendu: number;
  aide: string;
}) {
  const [coches, setCoches] = useState<string[]>([]);
  const [montre, setMontre] = useState(false);

  const basculer = (id: string) =>
    setCoches((v) => (v.includes(id) ? v.filter((x) => x !== id) : [...v, id]));

  const bonnes = cases.filter((c) => c.bonne);
  const justes = coches.filter((id) => bonnes.some((b) => b.id === id));
  const fautes = coches.filter((id) => !bonnes.some((b) => b.id === id));
  const gagne = justes.length === attendu && fautes.length === 0;

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-sm font-medium">{titre}</p>
        <p className="text-[11px] text-muted-foreground">
          Il faut en cocher {attendu}, ni plus ni moins.
        </p>
      </div>

      <div className="grid gap-1.5 sm:grid-cols-2">
        {cases.map((c) => {
          const actif = coches.includes(c.id);
          const couleur = !montre
            ? actif
              ? "border-primary bg-primary/10 text-foreground"
              : "border-border bg-background text-muted-foreground"
            : c.bonne
              ? "border-emerald-500/50 bg-emerald-500/10 text-emerald-700"
              : actif
                ? "border-rose-500/50 bg-rose-500/10 text-rose-700"
                : "border-border bg-background text-muted-foreground";
          return (
            <button
              key={c.id}
              type="button"
              onClick={() => basculer(c.id)}
              className={`rounded-lg border px-2.5 py-2 text-left text-xs font-medium ${couleur}`}
            >
              {c.label}
            </button>
          );
        })}
      </div>

      <Panel>
        <Stat label="Cochées" value={`${coches.length} / ${attendu}`} />
        <Stat
          label="Bonnes trouvées"
          value={`${justes.length}`}
          color={gagne ? PALETTE.green : PALETTE.ink}
        />
      </Panel>

      {coches.length === 0 ? (
        <Verdict tone="warn">{aide}</Verdict>
      ) : gagne ? (
        <Verdict tone="ok">
          C&apos;est exactement cela : {attendu} bonnes réponses, aucune de trop.
        </Verdict>
      ) : fautes.length > 0 ? (
        <Verdict tone="bad">
          {fautes.length === 1 ? "Une case de trop" : `${fautes.length} cases de trop`}. Appuie sur
          « Montrer la correction » pour voir lesquelles, et surtout pourquoi.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          {justes.length} bonne{justes.length > 1 ? "s" : ""} sur {attendu}, et aucune faute. Il en
          manque {attendu - justes.length}.
        </Verdict>
      )}

      <button
        type="button"
        onClick={() => setMontre((v) => !v)}
        className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
      >
        {montre ? "Cacher la correction" : "Montrer la correction"}
      </button>

      {montre ? (
        <div className="space-y-1 rounded-lg border border-border bg-background p-3">
          {cases.map((c) => (
            <p key={c.id} className="text-[11px] text-muted-foreground">
              <span
                className="font-semibold"
                style={{ color: c.bonne ? PALETTE.green : PALETTE.red }}
              >
                {c.bonne ? "Oui" : "Non"} — {c.label} :{" "}
              </span>
              {c.pourquoi}
            </p>
          ))}
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Associer deux colonnes                                              */
/* ------------------------------------------------------------------ */

export type Paire = { gauche: string; droite: string; pourquoi: string };

export function JeuAssocie({
  titre,
  paires,
  libelleGauche,
  libelleDroite,
}: {
  titre: string;
  paires: ReadonlyArray<Paire>;
  libelleGauche: string;
  libelleDroite: string;
}) {
  const [choix, setChoix] = useState<Record<number, string>>({});
  const [actif, setActif] = useState<number | null>(null);

  const droites = paires.map((p) => p.droite).sort((a, b) => a.localeCompare(b, "fr"));
  const bons = paires.filter((p, i) => choix[i] === p.droite).length;
  const faits = Object.keys(choix).length;

  const poser = (d: string) => {
    if (actif === null) return;
    setChoix({ ...choix, [actif]: d });
    setActif(null);
  };

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-sm font-medium">{titre}</p>
        <p className="text-[11px] text-muted-foreground">
          Choisis une ligne à gauche, puis sa correspondance à droite.
        </p>
      </div>

      <div className="grid gap-2 sm:grid-cols-2">
        <div className="space-y-1.5">
          <p className="text-xs font-medium text-muted-foreground">{libelleGauche}</p>
          {paires.map((p, i) => {
            const pose = choix[i];
            const juste = pose === p.droite;
            const couleur =
              actif === i
                ? "border-primary bg-primary/10"
                : pose === undefined
                  ? "border-border bg-background"
                  : juste
                    ? "border-emerald-500/50 bg-emerald-500/10"
                    : "border-rose-500/50 bg-rose-500/10";
            return (
              <button
                key={p.gauche}
                type="button"
                onClick={() => setActif(i)}
                className={`block w-full rounded-lg border px-2.5 py-1.5 text-left text-xs ${couleur}`}
              >
                <span className="font-semibold text-foreground">{p.gauche}</span>
                {pose !== undefined ? (
                  <span className="block font-mono text-[11px] text-muted-foreground">
                    → {pose}
                  </span>
                ) : null}
              </button>
            );
          })}
        </div>

        <div className="space-y-1.5">
          <p className="text-xs font-medium text-muted-foreground">{libelleDroite}</p>
          {droites.map((d) => (
            <button
              key={d}
              type="button"
              onClick={() => poser(d)}
              disabled={actif === null}
              className={
                actif === null
                  ? "block w-full rounded-lg border border-border bg-background px-2.5 py-1.5 text-left font-mono text-[11px] text-muted-foreground opacity-50"
                  : "block w-full rounded-lg border border-border bg-background px-2.5 py-1.5 text-left font-mono text-[11px] text-foreground hover:bg-secondary/60"
              }
            >
              {d}
            </button>
          ))}
        </div>
      </div>

      <Panel>
        <Stat label="Associées" value={`${faits} / ${paires.length}`} />
        <Stat
          label="Justes"
          value={`${bons}`}
          color={bons === paires.length ? PALETTE.green : PALETTE.ink}
        />
      </Panel>

      {faits === 0 ? (
        <Verdict tone="warn">
          Commence par cliquer sur une ligne de gauche : la colonne de droite s&apos;activera.
        </Verdict>
      ) : bons === paires.length ? (
        <Verdict tone="ok">Tout est associé correctement.</Verdict>
      ) : (
        <Verdict tone="warn">
          {bons} juste{bons > 1 ? "s" : ""} sur {paires.length}. Les lignes en rouge sont à
          reprendre.
        </Verdict>
      )}

      <div className="space-y-1 rounded-lg border border-border bg-background p-3">
        {paires.map((p, i) =>
          choix[i] !== undefined && choix[i] !== p.droite ? (
            <p key={p.gauche} className="text-[11px] text-muted-foreground">
              <span className="font-semibold text-foreground">{p.gauche} → </span>
              {p.pourquoi}
            </p>
          ) : null,
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Dérouler un algorithme pas à pas                                    */
/* ------------------------------------------------------------------ */

export type Pas = {
  /** Index de la ligne de code éclairée (0 = première ligne). */
  ligne: number;
  /** Valeur de chaque variable APRÈS exécution de la ligne. */
  vars: Record<string, string>;
  /** Commentaire affiché sous la trace. */
  note: string;
  /** Texte affiché dans la console, s'il y en a. */
  sortie?: string;
};

export function Deroule({
  code,
  pas,
  variables,
  conclusion,
}: {
  code: ReadonlyArray<string>;
  pas: ReadonlyArray<Pas>;
  variables: ReadonlyArray<string>;
  conclusion: ReactNode;
}) {
  const [k, setK] = useState(0);
  const PAS_DEFAUT: Pas = { ligne: -1, vars: {}, note: "", sortie: "" };
  const p = pas[k] ?? PAS_DEFAUT;
  const fini = k === pas.length - 1;

  const sorties = pas
    .slice(0, k + 1)
    .map((x) => x.sortie)
    .filter((s): s is string => typeof s === "string" && s.length > 0);

  return (
    <div className="space-y-3">
      <div className="overflow-x-auto rounded-lg border border-border bg-slate-900 p-3">
        <pre className="font-mono text-[11px] leading-relaxed">
          {code.map((l, i) => (
            <div
              key={`${i}-${l}`}
              className={
                i === p.ligne
                  ? "-mx-1 rounded bg-amber-400/25 px-1 text-amber-100"
                  : "-mx-1 px-1 text-slate-400"
              }
            >
              <span className="mr-2 select-none text-slate-600">
                {String(i + 1).padStart(2, " ")}
              </span>
              {l === "" ? " " : l}
            </div>
          ))}
        </pre>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full border-collapse text-xs">
          <thead>
            <tr>
              <th className="border border-border bg-secondary/40 px-2 py-1 text-left font-medium">
                Étape
              </th>
              {variables.map((v) => (
                <th
                  key={v}
                  className="border border-border bg-secondary/40 px-2 py-1 text-center font-mono font-medium"
                >
                  {v}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {pas.slice(0, k + 1).map((x, i) => (
              <tr key={`${i}-${x.note}`} className={i === k ? "bg-primary/5" : ""}>
                <td className="border border-border px-2 py-1 text-muted-foreground">{i + 1}</td>
                {variables.map((v) => (
                  <td
                    key={v}
                    className="border border-border px-2 py-1 text-center font-mono font-semibold"
                  >
                    {x.vars[v] ?? "—"}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {p.note ? <Verdict tone={fini ? "ok" : "warn"}>{p.note}</Verdict> : null}

      {sorties.length > 0 ? (
        <div className="rounded-lg bg-slate-900 p-3">
          <p className="mb-1 text-[10px] uppercase tracking-wide text-slate-500">Console</p>
          {sorties.map((s, i) => (
            <p key={`${i}-${s}`} className="font-mono text-[11px] text-emerald-400">
              {s}
            </p>
          ))}
        </div>
      ) : null}

      <Panel>
        <Stat label="Étape" value={`${k + 1} / ${pas.length}`} />
        <Stat
          label="État"
          value={fini ? "terminé" : "en cours"}
          color={fini ? PALETTE.green : PALETTE.ink}
        />
      </Panel>

      <div className="flex flex-wrap gap-2">
        <button
          type="button"
          onClick={() => setK((v) => Math.max(0, v - 1))}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Étape précédente
        </button>
        <button
          type="button"
          onClick={() => setK((v) => Math.min(pas.length - 1, v + 1))}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Étape suivante
        </button>
        <button
          type="button"
          onClick={() => setK(0)}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Recommencer
        </button>
      </div>

      {fini ? (
        <div className="rounded-lg border border-border bg-background p-3 text-[11px] text-muted-foreground">
          {conclusion}
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Un tableau dessiné en cases numérotées                              */
/* ------------------------------------------------------------------ */

export function Cases({
  valeurs,
  base = 1,
  courant = -1,
  marquees = [],
  legende,
}: {
  valeurs: ReadonlyArray<string | number>;
  /** 1 pour le LDA, 0 pour le langage C. */
  base?: number;
  /** Indice (en base `base`) de la case éclairée. */
  courant?: number;
  /** Indices (en base `base`) des cases déjà visitées. */
  marquees?: ReadonlyArray<number>;
  legende?: string;
}) {
  return (
    <div className="space-y-1">
      <div className="flex flex-wrap gap-1">
        {valeurs.map((v, i) => {
          const idx = i + base;
          const est = idx === courant;
          const vue = marquees.includes(idx);
          return (
            <div key={`${idx}-${String(v)}`} className="text-center">
              <div
                className={
                  est
                    ? "flex h-10 w-12 items-center justify-center rounded border-2 border-amber-500 bg-amber-500/20 font-mono text-sm font-bold"
                    : vue
                      ? "flex h-10 w-12 items-center justify-center rounded border border-slate-400 bg-secondary/60 font-mono text-sm text-muted-foreground"
                      : "flex h-10 w-12 items-center justify-center rounded border border-border bg-background font-mono text-sm font-semibold"
                }
              >
                {String(v)}
              </div>
              <p className="mt-0.5 font-mono text-[10px] text-muted-foreground">[{idx}]</p>
            </div>
          );
        })}
      </div>
      {legende ? <p className="text-[11px] text-muted-foreground">{legende}</p> : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Un bloc de code, avec une ligne éventuellement éclairée             */
/* ------------------------------------------------------------------ */

export function Code({
  lignes,
  eclairee = -1,
  tonEclairee = "warn",
}: {
  lignes: ReadonlyArray<string>;
  eclairee?: number;
  tonEclairee?: "warn" | "bad" | "ok";
}) {
  const fond =
    tonEclairee === "bad"
      ? "bg-rose-500/25 text-rose-100"
      : tonEclairee === "ok"
        ? "bg-emerald-500/25 text-emerald-100"
        : "bg-amber-400/25 text-amber-100";
  return (
    <div className="overflow-x-auto rounded-lg border border-border bg-slate-900 p-3">
      <pre className="font-mono text-[11px] leading-relaxed">
        {lignes.map((l, i) => (
          <div
            key={`${i}-${l}`}
            className={i === eclairee ? `-mx-1 rounded px-1 ${fond}` : "-mx-1 px-1 text-slate-400"}
          >
            <span className="mr-2 select-none text-slate-600">
              {String(i + 1).padStart(2, " ")}
            </span>
            {l === "" ? " " : l}
          </div>
        ))}
      </pre>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Une console de sortie                                               */
/* ------------------------------------------------------------------ */

export function Console({
  lignes,
  titre = "Console",
}: {
  lignes: ReadonlyArray<string>;
  titre?: string;
}) {
  return (
    <div className="rounded-lg bg-slate-900 p-3">
      <p className="mb-1 text-[10px] uppercase tracking-wide text-slate-500">{titre}</p>
      {lignes.length === 0 ? (
        <p className="font-mono text-[11px] text-slate-600">(rien pour l&apos;instant)</p>
      ) : (
        lignes.map((l, i) => (
          <p
            key={`${i}-${l}`}
            className={
              l.startsWith(">")
                ? "font-mono text-[11px] text-slate-300"
                : "font-mono text-[11px] text-emerald-400"
            }
          >
            {l}
          </p>
        ))
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Une fiche à remplir : plusieurs listes déroulantes à accorder        */
/* ------------------------------------------------------------------ */

export type Champ = {
  id: string;
  label: string;
  options: ReadonlyArray<string>;
  bonne: string;
  pourquoi: string;
};

export function JeuFiche({
  titre,
  champs,
  conclusion,
}: {
  titre: string;
  champs: ReadonlyArray<Champ>;
  conclusion: string;
}) {
  const [rep, setRep] = useState<Record<string, string>>({});
  const faits = champs.filter((c) => rep[c.id] !== undefined).length;
  const bons = champs.filter((c) => rep[c.id] === c.bonne).length;
  const complet = bons === champs.length;

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-sm font-medium">{titre}</p>
      </div>

      <div className="space-y-2">
        {champs.map((c) => {
          const v = rep[c.id];
          const juste = v === c.bonne;
          return (
            <div key={c.id} className="space-y-1">
              <p className="text-xs font-medium text-muted-foreground">{c.label}</p>
              <div className="flex flex-wrap gap-1.5">
                {c.options.map((o) => {
                  const choisi = v === o;
                  const cls = !choisi
                    ? "border-border bg-background text-muted-foreground hover:bg-secondary/60"
                    : juste
                      ? "border-emerald-500/50 bg-emerald-500/10 text-emerald-700"
                      : "border-rose-500/50 bg-rose-500/10 text-rose-700";
                  return (
                    <button
                      key={o}
                      type="button"
                      onClick={() => setRep({ ...rep, [c.id]: o })}
                      className={`rounded-lg border px-2.5 py-1 text-xs font-medium ${cls}`}
                    >
                      {o}
                    </button>
                  );
                })}
              </div>
              {v !== undefined && !juste ? (
                <p className="text-[11px] text-rose-600">
                  Non : la bonne réponse est « {c.bonne} ». {c.pourquoi}
                </p>
              ) : null}
            </div>
          );
        })}
      </div>

      <Panel>
        <Stat label="Champs remplis" value={`${faits} / ${champs.length}`} />
        <Stat label="Justes" value={`${bons}`} color={complet ? PALETTE.green : PALETTE.ink} />
      </Panel>

      {complet ? (
        <Verdict tone="ok">{conclusion}</Verdict>
      ) : faits === 0 ? (
        <Verdict tone="warn">Remplis chaque ligne : chaque mauvaise réponse est expliquée.</Verdict>
      ) : (
        <Verdict tone="warn">
          {bons} juste{bons > 1 ? "s" : ""} sur {champs.length}. Reprends les lignes en rouge.
        </Verdict>
      )}
    </div>
  );
}
