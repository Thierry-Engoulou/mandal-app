import { useState } from "react";
import { Choice, PALETTE, Panel, Stat, Verdict } from "./controls";

/** Brique commune aux simulations d'informatique : classer des cas concrets. */

export type Cas = { enonce: string; bonne: string; pourquoi: string };

export function JeuClassement({
  cas,
  options,
  aide,
  libelleChoix = "Ton classement",
}: {
  cas: ReadonlyArray<Cas>;
  options: ReadonlyArray<{ value: string; label: string }>;
  aide: string;
  libelleChoix?: string;
}) {
  const [i, setI] = useState(0);
  const [rep, setRep] = useState<Record<number, string>>({});

  const CAS_DEFAUT: Cas = { enonce: "", bonne: "", pourquoi: "" };
  const OPT_DEFAUT = options[0] ?? { value: "", label: "" };

  const c = cas[i] ?? CAS_DEFAUT;
  const r = rep[i];
  const juste = r === c.bonne;
  const bons = cas.filter((q, k) => rep[k] === q.bonne).length;
  const faits = Object.keys(rep).length;
  const libelle = (v: string) => options.find((o) => o.value === v)?.label ?? v;

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-[11px] text-muted-foreground">
          Cas {i + 1} sur {cas.length}
        </p>
        <p className="text-sm font-medium">{c.enonce}</p>
      </div>

      <Choice<string>
        label={libelleChoix}
        value={r ?? OPT_DEFAUT.value}
        options={options}
        onChange={(v) => setRep({ ...rep, [i]: v })}
      />

      {r === undefined ? (
        <Verdict tone="warn">{aide}</Verdict>
      ) : juste ? (
        <Verdict tone="ok">
          Exact : {libelle(c.bonne)}. {c.pourquoi}
        </Verdict>
      ) : (
        <Verdict tone="bad">
          Non, c&apos;est {libelle(c.bonne)}. {c.pourquoi}
        </Verdict>
      )}

      <Panel>
        <Stat label="Classés" value={`${faits} / ${cas.length}`} />
        <Stat label="Bien classés" value={`${bons}`} color={PALETTE.green} />
      </Panel>

      <div className="flex gap-2">
        <button
          type="button"
          onClick={() => setI((v) => (v + cas.length - 1) % cas.length)}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Précédent
        </button>
        <button
          type="button"
          onClick={() => setI((v) => (v + 1) % cas.length)}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Cas suivant
        </button>
      </div>
    </div>
  );
}
