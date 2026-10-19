import { useState } from "react";
import {
  Arrow,
  Board,
  Choice,
  Ctrl,
  PALETTE,
  Panel,
  Stat,
  Verdict,
  curvePath,
  fmt,
  makeScales,
} from "./controls";

/** Simulations de Chimie Terminale C, D et E — modules 2, 3 et 4. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* Chapitres 2, 4 et 9 — Échelle des pKa et règle du gamma             */
/* ------------------------------------------------------------------ */

type Couple = { value: string; acide: string; base: string; pKa: number };

const COUPLE_DEFAUT: Couple = { value: "h3o", acide: "H₃O⁺", base: "H₂O", pKa: 0 };

const COUPLES: ReadonlyArray<Couple> = [
  COUPLE_DEFAUT,
  { value: "hcooh", acide: "HCOOH", base: "HCOO⁻", pKa: 3.8 },
  { value: "ch3cooh", acide: "CH₃COOH", base: "CH₃COO⁻", pKa: 4.8 },
  { value: "nh4", acide: "NH₄⁺", base: "NH₃", pKa: 9.2 },
  { value: "ethylamine", acide: "C₂H₅NH₃⁺", base: "C₂H₅NH₂", pKa: 10.7 },
  { value: "eau", acide: "H₂O", base: "HO⁻", pKa: 14 },
];

function pkaWidget(titre: string) {
  return function EchellePka() {
    const [c1, setC1] = useState("ch3cooh");
    const [c2, setC2] = useState("nh4");

    const a = COUPLES.find((x) => x.value === c1) ?? COUPLE_DEFAUT;
    const b = COUPLES.find((x) => x.value === c2) ?? COUPLE_DEFAUT;

    const bas = a.pKa <= b.pKa ? a : b;
    const haut = a.pKa <= b.pKa ? b : a;
    const ecart = haut.pKa - bas.pKa;
    const K = Math.pow(10, ecart);
    const totale = K > 1e4;
    const memeCouple = a.value === b.value;

    const W = 440;
    const H = 300;
    const pad = 36;
    const sy = (p: number) => H - pad - (p / 15) * (H - 2 * pad);

    return (
      <div className="space-y-3">
        <Board width={W} height={H}>
          <rect width={W} height={H} fill="#ffffff" />
          <line
            x1={72}
            y1={sy(0) + 10}
            x2={72}
            y2={sy(15)}
            stroke={PALETTE.axis}
            strokeWidth={1.6}
          />
          <text x={72} y={sy(15) - 8} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
            pKa
          </text>
          {COUPLES.map((c) => {
            const vedette = c.value === a.value || c.value === b.value;
            return (
              <g key={c.value}>
                <line
                  x1={66}
                  y1={sy(c.pKa)}
                  x2={78}
                  y2={sy(c.pKa)}
                  stroke={vedette ? PALETTE.ink : PALETTE.gridStrong}
                  strokeWidth={vedette ? 2.4 : 1.2}
                />
                <text x={60} y={sy(c.pKa) + 4} textAnchor="end" fontSize={10} fill={PALETTE.slate}>
                  {fmt(c.pKa, 1)}
                </text>
                <text
                  x={92}
                  y={sy(c.pKa) + 4}
                  fontSize={11.5}
                  fontWeight={vedette ? 700 : 400}
                  fill={vedette ? PALETTE.red : PALETTE.slate}
                >
                  {c.acide}
                </text>
                <text
                  x={236}
                  y={sy(c.pKa) + 4}
                  fontSize={11.5}
                  fontWeight={vedette ? 700 : 400}
                  fill={vedette ? PALETTE.blue : PALETTE.slate}
                >
                  {c.base}
                </text>
              </g>
            );
          })}
          <text x={92} y={sy(15) - 8} fontSize={10} fontWeight={700} fill={PALETTE.red}>
            acides
          </text>
          <text x={236} y={sy(15) - 8} fontSize={10} fontWeight={700} fill={PALETTE.blue}>
            bases
          </text>
          {!memeCouple ? (
            <g>
              <line
                x1={200}
                y1={sy(bas.pKa) - 11}
                x2={404}
                y2={sy(bas.pKa) - 11}
                stroke={PALETTE.green}
                strokeWidth={2}
              />
              <line
                x1={404}
                y1={sy(bas.pKa) - 11}
                x2={404}
                y2={sy(haut.pKa) - 11}
                stroke={PALETTE.green}
                strokeWidth={2}
              />
              <Arrow
                x1={404}
                y1={sy(haut.pKa) - 11}
                x2={322}
                y2={sy(haut.pKa) - 11}
                color={PALETTE.green}
                width={2}
              />
            </g>
          ) : null}
        </Board>

        <Panel>
          <Choice
            label="Premier couple"
            value={c1}
            options={COUPLES.map((o) => ({
              value: o.value,
              label: `${o.acide} (${fmt(o.pKa, 1)})`,
            }))}
            onChange={setC1}
          />
          <Choice
            label="Second couple"
            value={c2}
            options={COUPLES.map((o) => ({
              value: o.value,
              label: `${o.acide} (${fmt(o.pKa, 1)})`,
            }))}
            onChange={setC2}
          />
        </Panel>

        {memeCouple ? (
          <Verdict tone="warn">
            Choisis deux couples différents : il ne se passe rien entre un acide et sa propre base
            conjuguée, qui forment simplement une solution tampon.
          </Verdict>
        ) : (
          <>
            <div className="rounded-xl border border-border bg-white p-3 text-center">
              <p className="font-mono text-sm font-semibold text-foreground">
                {bas.acide} + {haut.base} → {bas.base} + {haut.acide}
              </p>
            </div>
            <div className="grid grid-cols-2 gap-2">
              <Stat label="Écart des pKa" value={fmt(ecart, 1)} color={PALETTE.purple} />
              <Stat
                label="Constante K"
                value={K >= 1e6 ? `10^${fmt(ecart, 1)}` : fmt(K, 1)}
                color={totale ? PALETTE.green : PALETTE.orange}
              />
            </div>
            <Verdict tone={totale ? "ok" : "warn"}>
              {totale
                ? `L'écart dépasse 4 unités, donc K dépasse 10⁴ : la réaction est pratiquement totale. ${titre}`
                : "L'écart est trop faible : la réaction est limitée et les quatre espèces coexistent à l'équilibre."}
            </Verdict>
          </>
        )}
      </div>
    );
  };
}

export const EchellePka = pkaWidget(
  "La flèche verte dessine le gamma : l'acide du bas attaque la base du haut.",
);
export const RegleGamma = pkaWidget("C'est exactement la règle du gamma.");

/* ------------------------------------------------------------------ */
/* Chapitre 7 — Échelle des pH du quotidien                            */
/* ------------------------------------------------------------------ */

const SOLUTIONS = [
  { value: "chlorhydrique", label: "Acide de batterie", ph: 1.0 },
  { value: "citron", label: "Jus de citron", ph: 2.3 },
  { value: "vinaigre", label: "Vinaigre", ph: 2.9 },
  { value: "tomate", label: "Jus de tomate", ph: 4.2 },
  { value: "pluie", label: "Eau de pluie", ph: 5.6 },
  { value: "lait", label: "Lait", ph: 6.6 },
  { value: "pure", label: "Eau pure", ph: 7.0 },
  { value: "sang", label: "Sang", ph: 7.4 },
  { value: "mer", label: "Eau de mer", ph: 8.1 },
  { value: "bicarbonate", label: "Bicarbonate", ph: 8.4 },
  { value: "savon", label: "Eau savonneuse", ph: 10.0 },
  { value: "soude", label: "Soude diluée", ph: 13.0 },
] as const;

export function EchellePh() {
  const [choix, setChoix] = useState<string>("citron");
  const [reference, setReference] = useState<string>("pure");

  const s = SOLUTIONS.find((x) => x.value === choix) ?? SOLUTIONS[0];
  const r = SOLUTIONS.find((x) => x.value === reference) ?? SOLUTIONS[6];

  const h = Math.pow(10, -s.ph);
  const ho = 1e-14 / h;
  const rapport = Math.pow(10, r.ph - s.ph);

  const W = 440;
  const H = 150;
  const pad = 26;
  const sx = (p: number) => pad + (p / 14) * (W - 2 * pad);

  function teinte(p: number): string {
    if (p < 3) return "#dc2626";
    if (p < 5) return "#ea580c";
    if (p < 6.5) return "#ca8a04";
    if (p < 7.5) return "#16a34a";
    if (p < 9.5) return "#0891b2";
    if (p < 12) return "#2563eb";
    return "#6d28d9";
  }

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {Array.from({ length: 140 }).map((_, i) => {
          const p = (i * 14) / 140;
          return (
            <rect
              key={i}
              x={sx(p)}
              y={44}
              width={(W - 2 * pad) / 140 + 1}
              height={30}
              fill={teinte(p)}
            />
          );
        })}
        {[0, 2, 4, 6, 7, 8, 10, 12, 14].map((p) => (
          <g key={p}>
            <line x1={sx(p)} y1={74} x2={sx(p)} y2={82} stroke={PALETTE.slate} strokeWidth={1} />
            <text x={sx(p)} y={95} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
              {p}
            </text>
          </g>
        ))}
        <text
          x={sx(3)}
          y={18}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.red}
        >
          acide
        </text>
        <text
          x={sx(7)}
          y={18}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.green}
        >
          neutre
        </text>
        <text
          x={sx(11)}
          y={18}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.blue}
        >
          basique
        </text>
        <polygon
          points={`${sx(s.ph)},${42} ${sx(s.ph) - 7},${28} ${sx(s.ph) + 7},${28}`}
          fill={PALETTE.ink}
        />
        <text
          x={sx(s.ph)}
          y={118}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {s.label}
        </text>
        <text x={sx(s.ph)} y={134} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          pH = {fmt(s.ph, 1)}
        </text>
      </Board>

      <Panel>
        <Choice
          label="Solution observée"
          value={choix}
          options={SOLUTIONS.map((o) => ({ value: o.value as string, label: o.label }))}
          onChange={setChoix}
        />
        <Choice
          label="Comparer à"
          value={reference}
          options={SOLUTIONS.map((o) => ({ value: o.value as string, label: o.label }))}
          onChange={setReference}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Ions oxonium" value={`${h.toExponential(1)} mol/L`} color={PALETTE.red} />
        <Stat label="Ions hydroxyde" value={`${ho.toExponential(1)} mol/L`} color={PALETTE.blue} />
      </div>

      <Verdict tone="ok">
        {rapport >= 1
          ? `Le ${s.label.toLowerCase()} contient ${fmt(rapport, 0)} fois plus d'ions oxonium que le ${r.label.toLowerCase()}.`
          : `Le ${s.label.toLowerCase()} contient ${fmt(1 / rapport, 0)} fois moins d'ions oxonium que le ${r.label.toLowerCase()}.`}{" "}
        Une unité de pH vaut toujours un facteur 10, jamais une simple différence.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 8 — Acide fort contre acide faible                         */
/* ------------------------------------------------------------------ */

export function AcideFortFaible() {
  const [pC, setPC] = useState(2); // concentration = 10^-pC
  const [pKa, setPKa] = useState(4.8);
  const [type, setType] = useState<"fort" | "faible">("faible");

  const C = Math.pow(10, -pC);
  const Ka = Math.pow(10, -pKa);

  // acide faible : h^2 + Ka h - Ka C = 0
  const h = type === "fort" ? C : (-Ka + Math.sqrt(Ka * Ka + 4 * Ka * C)) / 2;
  const ph = -Math.log10(h);
  const phFort = -Math.log10(C);
  const alpha = h / C;

  const W = 440;
  const H = 220;
  const s = makeScales(W, H, 1, 5, 0, 7, 34);

  const courbeFort = (p: number) => p;
  const courbeFaible = (p: number) => {
    const c = Math.pow(10, -p);
    const x = (-Ka + Math.sqrt(Ka * Ka + 4 * Ka * c)) / 2;
    return -Math.log10(x);
  };

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={s.sx(1)}
          y1={s.sy(0)}
          x2={s.sx(5)}
          y2={s.sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(1)}
          y1={s.sy(0)}
          x2={s.sx(1)}
          y2={s.sy(7)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        {[1, 2, 3, 4, 5].map((p) => (
          <text
            key={p}
            x={s.sx(p)}
            y={s.sy(0) + 17}
            textAnchor="middle"
            fontSize={10}
            fill={PALETTE.slate}
          >
            10⁻{p}
          </text>
        ))}
        <path
          d={curvePath(courbeFort, s, 200)}
          fill="none"
          stroke={PALETTE.red}
          strokeWidth={2.4}
        />
        <path
          d={curvePath(courbeFaible, s, 200)}
          fill="none"
          stroke={PALETTE.blue}
          strokeWidth={2.4}
        />
        <circle
          cx={s.sx(pC)}
          cy={s.sy(ph)}
          r={6}
          fill={type === "fort" ? PALETTE.red : PALETTE.blue}
        />
        <text x={s.sx(3.6)} y={s.sy(2.6)} fontSize={11} fontWeight={700} fill={PALETTE.red}>
          acide fort
        </text>
        <text x={s.sx(1.5)} y={s.sy(5.3)} fontSize={11} fontWeight={700} fill={PALETTE.blue}>
          acide faible
        </text>
        <text x={s.sx(1) + 6} y={s.sy(7) + 12} fontSize={10} fill={PALETTE.slate}>
          pH
        </text>
        <text x={s.sx(5)} y={s.sy(0) + 32} textAnchor="end" fontSize={10} fill={PALETTE.slate}>
          concentration apportée (mol/L)
        </text>
      </Board>

      <Choice
        value={type}
        options={[
          { value: "faible", label: "Acide faible" },
          { value: "fort", label: "Acide fort" },
        ]}
        onChange={setType}
      />

      <Panel>
        <Ctrl
          label="Concentration : 10⁻ⁿ mol/L"
          value={pC}
          min={1}
          max={5}
          step={0.1}
          onChange={setPC}
          display={`10⁻${fmt(pC, 1)}`}
        />
        {type === "faible" ? (
          <Ctrl
            label="pKa du couple"
            value={pKa}
            min={2}
            max={10}
            step={0.1}
            onChange={setPKa}
            display={fmt(pKa, 1)}
            color={PALETTE.purple}
          />
        ) : null}
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat
          label="pH obtenu"
          value={fmt(ph, 2)}
          color={type === "fort" ? PALETTE.red : PALETTE.blue}
        />
        <Stat label="pH si l'acide était fort" value={fmt(phFort, 2)} color={PALETTE.red} />
        <Stat label="Taux d'ionisation" value={`${fmt(alpha * 100, 1)} %`} color={PALETTE.purple} />
      </div>

      <Verdict tone="ok">
        {type === "fort"
          ? "Acide fort : il est totalement ionisé, donc pH = −log C et le taux vaut 100 %. Diluer d'un facteur 10 fait monter le pH d'exactement une unité."
          : `Acide faible : le pH mesuré (${fmt(ph, 2)}) est plus élevé que celui d'un acide fort de même concentration (${fmt(phFort, 2)}). Dilue et regarde le taux d'ionisation augmenter.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 10 — Courbe de dosage acido-basique                        */
/* ------------------------------------------------------------------ */

const INDICATEURS = [
  { value: "aucun", label: "Aucun", bas: 0, haut: 0 },
  { value: "helianthine", label: "Hélianthine", bas: 3.1, haut: 4.4 },
  { value: "bbt", label: "Bleu de bromothymol", bas: 6.0, haut: 7.6 },
  { value: "phenol", label: "Phénolphtaléine", bas: 8.2, haut: 10.0 },
] as const;

export function CourbeDosage() {
  const [faible, setFaible] = useState<"fort" | "faible">("fort");
  const [pKa, setPKa] = useState(4.8);
  const [indic, setIndic] = useState<string>("bbt");
  const [vb, setVb] = useState(0);

  const Ca = 0.1;
  const Cb = 0.1;
  const Va = 20;
  const vbE = (Ca * Va) / Cb;
  const Ka = Math.pow(10, -pKa);

  function phDe(v: number): number {
    const na = (Ca * Va) / 1000;
    const nb = (Cb * v) / 1000;
    const vt = (Va + v) / 1000;
    if (faible === "fort") {
      if (v < vbE - 1e-9) return -Math.log10((na - nb) / vt);
      if (v > vbE + 1e-9) return 14 + Math.log10((nb - na) / vt);
      return 7;
    }
    if (v < 1e-9) {
      const c = na / vt;
      return -Math.log10((-Ka + Math.sqrt(Ka * Ka + 4 * Ka * c)) / 2);
    }
    if (v < vbE - 1e-9) return pKa + Math.log10(nb / (na - nb));
    if (v > vbE + 1e-9) return 14 + Math.log10((nb - na) / vt);
    // equivalence : base faible A- de concentration na/vt
    const cb = na / vt;
    const Kb = 1e-14 / Ka;
    const oh = (-Kb + Math.sqrt(Kb * Kb + 4 * Kb * cb)) / 2;
    return 14 + Math.log10(oh);
  }

  const phE = phDe(vbE);
  const phCourant = phDe(clamp(vb, 0, 40));
  const ind = INDICATEURS.find((x) => x.value === indic) ?? INDICATEURS[0];
  const bonIndicateur = ind.value !== "aucun" && phE >= ind.bas && phE <= ind.haut;

  const W = 440;
  const H = 250;
  const s = makeScales(W, H, 0, 40, 0, 14, 32);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {ind.value !== "aucun" ? (
          <rect
            x={s.sx(0)}
            y={s.sy(ind.haut)}
            width={s.sx(40) - s.sx(0)}
            height={s.sy(ind.bas) - s.sy(ind.haut)}
            fill={bonIndicateur ? "#16a34a" : "#dc2626"}
            opacity={0.14}
          />
        ) : null}
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(40)}
          y2={s.sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(0)}
          y2={s.sy(14)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        {[0, 10, 20, 30, 40].map((v) => (
          <text
            key={v}
            x={s.sx(v)}
            y={s.sy(0) + 16}
            textAnchor="middle"
            fontSize={10}
            fill={PALETTE.slate}
          >
            {v}
          </text>
        ))}
        {[0, 2, 4, 6, 8, 10, 12, 14].map((p) => (
          <text
            key={p}
            x={s.sx(0) - 6}
            y={s.sy(p) + 4}
            textAnchor="end"
            fontSize={10}
            fill={PALETTE.slate}
          >
            {p}
          </text>
        ))}
        <path
          d={curvePath((v) => phDe(v), s, 500)}
          fill="none"
          stroke={PALETTE.blue}
          strokeWidth={2.8}
        />
        <line
          x1={s.sx(vbE)}
          y1={s.sy(0)}
          x2={s.sx(vbE)}
          y2={s.sy(phE)}
          stroke={PALETTE.red}
          strokeWidth={1.4}
          strokeDasharray="5 4"
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(phE)}
          x2={s.sx(vbE)}
          y2={s.sy(phE)}
          stroke={PALETTE.red}
          strokeWidth={1.4}
          strokeDasharray="5 4"
        />
        <circle cx={s.sx(vbE)} cy={s.sy(phE)} r={6} fill={PALETTE.red} />
        <text
          x={s.sx(vbE) + 10}
          y={s.sy(phE) - 8}
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.red}
        >
          équivalence
        </text>
        {faible === "faible" ? (
          <>
            <circle cx={s.sx(vbE / 2)} cy={s.sy(pKa)} r={5} fill={PALETTE.green} />
            <text
              x={s.sx(vbE / 2) + 8}
              y={s.sy(pKa) + 16}
              fontSize={10.5}
              fontWeight={700}
              fill={PALETTE.green}
            >
              pH = pKa
            </text>
          </>
        ) : null}
        <circle cx={s.sx(clamp(vb, 0, 40))} cy={s.sy(phCourant)} r={5.5} fill={PALETTE.orange} />
        <text x={s.sx(40)} y={s.sy(0) + 30} textAnchor="end" fontSize={10} fill={PALETTE.slate}>
          volume de base versé (mL)
        </text>
      </Board>

      <Panel>
        <Choice
          label="Acide dosé"
          value={faible}
          options={[
            { value: "fort", label: "Acide fort" },
            { value: "faible", label: "Acide faible" },
          ]}
          onChange={setFaible}
        />
        <Choice
          label="Indicateur coloré"
          value={indic}
          options={INDICATEURS.map((o) => ({ value: o.value as string, label: o.label }))}
          onChange={setIndic}
        />
        {faible === "faible" ? (
          <Ctrl
            label="pKa de l'acide"
            value={pKa}
            min={3}
            max={7}
            step={0.1}
            onChange={setPKa}
            display={fmt(pKa, 1)}
            color={PALETTE.purple}
          />
        ) : null}
        <Ctrl
          label="Volume versé"
          value={vb}
          min={0}
          max={40}
          step={0.2}
          onChange={setVb}
          display={`${fmt(vb, 1)} mL`}
          color={PALETTE.orange}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="pH actuel" value={fmt(phCourant, 2)} color={PALETTE.orange} />
        <Stat label="Volume équivalent" value={`${fmt(vbE, 1)} mL`} />
        <Stat label="pH à l'équivalence" value={fmt(phE, 2)} color={PALETTE.red} />
      </div>

      <Verdict tone={ind.value === "aucun" ? "warn" : bonIndicateur ? "ok" : "bad"}>
        {ind.value === "aucun"
          ? `Le pH à l'équivalence vaut ${fmt(phE, 2)}. Choisis maintenant l'indicateur dont la zone de virage l'encadre.`
          : bonIndicateur
            ? `Bon choix : la zone de virage (${fmt(ind.bas, 1)} à ${fmt(ind.haut, 1)}) encadre bien le pH à l'équivalence, ${fmt(phE, 2)}.`
            : `Mauvais choix : la zone de virage (${fmt(ind.bas, 1)} à ${fmt(ind.haut, 1)}) ne contient pas le pH à l'équivalence, ${fmt(phE, 2)}. L'indicateur virerait trop tôt ou trop tard.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 11 — Vitesse et méthode des tangentes                      */
/* ------------------------------------------------------------------ */

export function VitesseReaction() {
  const [t, setT] = useState(2);
  const nMax = 20;
  const tau = 2.2;

  const n = (x: number) => nMax * (1 - Math.exp(-x / tau));
  const v = (x: number) => (nMax / tau) * Math.exp(-x / tau);

  const tMax = 12;
  const W = 440;
  const H = 250;
  const s = makeScales(W, H, 0, tMax, 0, nMax * 1.1, 34);

  const tDemi = tau * Math.LN2;
  const pente = v(t);
  const n0 = n(t);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(tMax)}
          y2={s.sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(0)}
          y2={s.sy(nMax * 1.1)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(nMax)}
          x2={s.sx(tMax)}
          y2={s.sy(nMax)}
          stroke={PALETTE.gridStrong}
          strokeWidth={1.2}
          strokeDasharray="6 5"
        />
        <text
          x={s.sx(tMax) - 4}
          y={s.sy(nMax) - 8}
          textAnchor="end"
          fontSize={10}
          fill={PALETTE.slate}
        >
          palier : {nMax} mmol
        </text>
        <path d={curvePath(n, s, 320)} fill="none" stroke={PALETTE.blue} strokeWidth={2.8} />
        <path
          d={curvePath((x) => n0 + pente * (x - t), s, 160, 1)}
          fill="none"
          stroke={PALETTE.red}
          strokeWidth={2}
          strokeDasharray="7 4"
        />
        <circle cx={s.sx(t)} cy={s.sy(n0)} r={6} fill={PALETTE.red} />
        <line
          x1={s.sx(tDemi)}
          y1={s.sy(0)}
          x2={s.sx(tDemi)}
          y2={s.sy(nMax / 2)}
          stroke={PALETTE.green}
          strokeWidth={1.4}
          strokeDasharray="4 4"
        />
        <circle cx={s.sx(tDemi)} cy={s.sy(nMax / 2)} r={5} fill={PALETTE.green} />
        <text
          x={s.sx(tDemi) + 8}
          y={s.sy(nMax / 2) + 16}
          fontSize={10.5}
          fontWeight={700}
          fill={PALETTE.green}
        >
          t½
        </text>
        {[0, 2, 4, 6, 8, 10, 12].map((x) => (
          <text
            key={x}
            x={s.sx(x)}
            y={s.sy(0) + 16}
            textAnchor="middle"
            fontSize={10}
            fill={PALETTE.slate}
          >
            {x}
          </text>
        ))}
        <text x={s.sx(tMax)} y={s.sy(0) + 32} textAnchor="end" fontSize={10} fill={PALETTE.slate}>
          temps (min)
        </text>
      </Board>

      <Ctrl
        label="Instant de lecture"
        value={t}
        min={0}
        max={tMax}
        step={0.1}
        onChange={setT}
        display={`${fmt(t, 1)} min`}
        color={PALETTE.red}
      />

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Quantité formée" value={`${fmt(n0, 1)} mmol`} color={PALETTE.blue} />
        <Stat label="Vitesse (pente)" value={`${fmt(pente, 2)} mmol/min`} color={PALETTE.red} />
        <Stat label="Temps de demi-réaction" value={`${fmt(tDemi, 2)} min`} color={PALETTE.green} />
      </div>

      <Verdict tone="ok">
        La vitesse à l&apos;instant initial vaut {fmt(v(0), 2)} mmol/min, et à {fmt(t, 1)} min elle
        n&apos;est plus que de {fmt(pente, 2)}. Elle diminue sans cesse parce que les réactifs se
        raréfient, et la tangente s&apos;aplatit avec elle.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 12 — Les facteurs cinétiques                               */
/* ------------------------------------------------------------------ */

export function FacteursCinetiques() {
  const [temperature, setTemperature] = useState(20);
  const [concentration, setConcentration] = useState(1);
  const [catalyseur, setCatalyseur] = useState<"non" | "oui">("non");
  const [surface, setSurface] = useState<"bloc" | "poudre">("bloc");

  const kT = Math.pow(2, (temperature - 20) / 10);
  const kC = concentration;
  const kCat = catalyseur === "oui" ? 8 : 1;
  const kS = surface === "poudre" ? 5 : 1;
  const k = kT * kC * kCat * kS;

  const nMax = 20; // le palier ne depend d'aucun facteur cinetique
  const tau = 6 / k;
  const tMax = 20;
  const W = 440;
  const H = 240;
  const s = makeScales(W, H, 0, tMax, 0, nMax * 1.12, 32);

  const courbe = (x: number) => nMax * (1 - Math.exp(-x / tau));
  const ref = (x: number) => nMax * (1 - Math.exp(-x / 6));

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(tMax)}
          y2={s.sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(0)}
          y2={s.sy(nMax * 1.12)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(nMax)}
          x2={s.sx(tMax)}
          y2={s.sy(nMax)}
          stroke={PALETTE.red}
          strokeWidth={1.6}
          strokeDasharray="6 5"
        />
        <text
          x={s.sx(tMax) - 4}
          y={s.sy(nMax) - 8}
          textAnchor="end"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.red}
        >
          palier inchangé
        </text>
        <path
          d={curvePath(ref, s, 260)}
          fill="none"
          stroke={PALETTE.gridStrong}
          strokeWidth={2}
          strokeDasharray="5 4"
        />
        <path d={curvePath(courbe, s, 320)} fill="none" stroke={PALETTE.blue} strokeWidth={2.8} />
        <text x={s.sx(0) + 8} y={s.sy(0) + 28} fontSize={10} fill={PALETTE.slate}>
          en pointillé gris : les conditions de référence
        </text>
        <text x={s.sx(tMax)} y={s.sy(0) + 28} textAnchor="end" fontSize={10} fill={PALETTE.slate}>
          temps (min)
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Température"
          value={temperature}
          min={0}
          max={80}
          step={5}
          onChange={setTemperature}
          display={`${fmt(temperature, 0)} °C`}
          color={PALETTE.red}
        />
        <Ctrl
          label="Concentration (× la référence)"
          value={concentration}
          min={0.25}
          max={4}
          step={0.25}
          onChange={setConcentration}
          display={`× ${fmt(concentration, 2)}`}
        />
        <Choice
          label="Catalyseur"
          value={catalyseur}
          options={[
            { value: "non", label: "Sans" },
            { value: "oui", label: "Avec" },
          ]}
          onChange={setCatalyseur}
        />
        <Choice
          label="État du solide"
          value={surface}
          options={[
            { value: "bloc", label: "En bloc" },
            { value: "poudre", label: "En poudre" },
          ]}
          onChange={setSurface}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Vitesse relative" value={`× ${fmt(k, 1)}`} color={PALETTE.blue} />
        <Stat label="Quantité finale" value={`${nMax} mmol`} color={PALETTE.red} />
      </div>

      <Verdict tone="ok">
        Quoi que tu règles, la courbe bleue finit toujours sur le même palier que la grise. Les
        facteurs cinétiques changent le <strong>temps</strong> mis pour y arriver, jamais la
        quantité finale, qui ne dépend que des quantités de réactifs engagées.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 13 — Cinétique de l'estérification                         */
/* ------------------------------------------------------------------ */

export function CinetiqueEsterification() {
  const [sens, setSens] = useState<"esterification" | "hydrolyse">("esterification");
  const [temperature, setTemperature] = useState(60);
  const [exces, setExces] = useState(1);

  const K = 4; // alcool primaire
  const a = 1;
  const b = exces;

  let lo = 0;
  let hi = Math.min(a, b);
  for (let i = 0; i < 60; i++) {
    const x = (lo + hi) / 2;
    const q = (x * x) / Math.max((a - x) * (b - x), 1e-12);
    if (q < K) lo = x;
    else hi = x;
  }
  const xEq = (lo + hi) / 2;
  const esterFinal = sens === "esterification" ? xEq : 1 - xEq;
  const depart = sens === "esterification" ? 0 : 1;

  const tau = 40 / Math.pow(2, (temperature - 20) / 10);
  const tMax = 24;
  const W = 440;
  const H = 240;
  const s = makeScales(W, H, 0, tMax, 0, 1.1, 34);

  const courbe = (t: number) => depart + (esterFinal - depart) * (1 - Math.exp(-t / tau));

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(tMax)}
          y2={s.sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(0)}
          y2={s.sy(1.1)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(esterFinal)}
          x2={s.sx(tMax)}
          y2={s.sy(esterFinal)}
          stroke={PALETTE.red}
          strokeWidth={1.5}
          strokeDasharray="6 5"
        />
        <text
          x={s.sx(tMax) - 4}
          y={s.sy(esterFinal) - 8}
          textAnchor="end"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.red}
        >
          {fmt(esterFinal, 2)} mol
        </text>
        <path d={curvePath(courbe, s, 320)} fill="none" stroke={PALETTE.blue} strokeWidth={2.8} />
        {[0, 6, 12, 18, 24].map((t) => (
          <text
            key={t}
            x={s.sx(t)}
            y={s.sy(0) + 16}
            textAnchor="middle"
            fontSize={10}
            fill={PALETTE.slate}
          >
            {t}
          </text>
        ))}
        <text x={s.sx(0) + 6} y={s.sy(1.1) + 12} fontSize={10} fill={PALETTE.slate}>
          ester (mol)
        </text>
        <text x={s.sx(tMax)} y={s.sy(0) + 32} textAnchor="end" fontSize={10} fill={PALETTE.slate}>
          temps (h)
        </text>
      </Board>

      <Panel>
        <Choice
          label="Sens de l'expérience"
          value={sens}
          options={[
            { value: "esterification", label: "Acide + alcool" },
            { value: "hydrolyse", label: "Ester + eau" },
          ]}
          onChange={setSens}
        />
        <Ctrl
          label="Température"
          value={temperature}
          min={20}
          max={100}
          step={5}
          onChange={setTemperature}
          display={`${fmt(temperature, 0)} °C`}
          color={PALETTE.red}
        />
        {sens === "esterification" ? (
          <Ctrl
            label="Alcool engagé"
            value={exces}
            min={1}
            max={5}
            step={0.5}
            onChange={setExces}
            display={`${fmt(exces, 1)} mol`}
            color={PALETTE.purple}
          />
        ) : null}
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Ester à l'équilibre" value={`${fmt(esterFinal, 2)} mol`} color={PALETTE.red} />
        <Stat
          label="Rendement"
          value={`${fmt((sens === "esterification" ? xEq : xEq) * 100, 0)} %`}
          color={PALETTE.purple}
        />
      </div>

      <Verdict tone="ok">
        {sens === "esterification"
          ? exces > 1.2
            ? "L'alcool est en excès : le palier monte vraiment. C'est un déplacement d'équilibre, pas un simple gain de temps."
            : "Monte la température : la courbe grimpe plus vite mais s'arrête au même palier de 0,67 mol. Mets ensuite l'alcool en excès : là, le palier bouge."
          : "En partant de l'ester et de l'eau, la courbe descend. Remarque qu'elle s'arrête au même état d'équilibre : 0,33 mol d'ester restant, soit exactement le complément."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 14 — Réactivité des métaux                                 */
/* ------------------------------------------------------------------ */

const METAUX = [
  { value: "mg", nom: "Magnésium", symbole: "Mg", ion: "Mg²⁺", E: -2.37 },
  { value: "zn", nom: "Zinc", symbole: "Zn", ion: "Zn²⁺", E: -0.76 },
  { value: "fe", nom: "Fer", symbole: "Fe", ion: "Fe²⁺", E: -0.44 },
  { value: "pb", nom: "Plomb", symbole: "Pb", ion: "Pb²⁺", E: -0.13 },
  { value: "cu", nom: "Cuivre", symbole: "Cu", ion: "Cu²⁺", E: 0.34 },
  { value: "ag", nom: "Argent", symbole: "Ag", ion: "Ag⁺", E: 0.8 },
] as const;

export function RedoxMetal() {
  const [lame, setLame] = useState<string>("zn");
  const [solution, setSolution] = useState<string>("cu");

  const m = METAUX.find((x) => x.value === lame) ?? METAUX[0];
  const s = METAUX.find((x) => x.value === solution) ?? METAUX[0];
  const reaction = m.E < s.E;
  const meme = m.value === s.value;

  const W = 440;
  const H = 210;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <path
          d={`M120,54 L120,172 Q120,184 132,184 L308,184 Q320,184 320,172 L320,54`}
          fill={reaction && !meme ? "#dbeafe" : "#e0f2fe"}
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <text x={220} y={204} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          solution de {s.ion}
        </text>
        <rect x={206} y={34} width={28} height={124} rx={3} fill={PALETTE.slate} />
        {reaction && !meme ? (
          <rect x={206} y={74} width={28} height={84} rx={2} fill="#b45309" opacity={0.92} />
        ) : null}
        <text x={220} y={26} textAnchor="middle" fontSize={12} fontWeight={700} fill={PALETTE.ink}>
          lame de {m.symbole}
        </text>
        {reaction && !meme
          ? Array.from({ length: 10 }).map((_, i) => (
              <circle
                key={i}
                cx={(i % 2 === 0 ? 202 : 238) + (i % 4 === 0 ? -3 : 2)}
                cy={84 + i * 7.4}
                r={4}
                fill="#b45309"
                opacity={0.95}
              />
            ))
          : null}
        <text
          x={220}
          y={H - 34}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={meme ? PALETTE.slate : reaction ? PALETTE.green : PALETTE.red}
        >
          {meme ? "même métal, rien à observer" : reaction ? "dépôt métallique" : "aucune réaction"}
        </text>
      </Board>

      <Panel>
        <Choice
          label="Métal plongé"
          value={lame}
          options={METAUX.map((o) => ({ value: o.value as string, label: o.nom }))}
          onChange={setLame}
        />
        <Choice
          label="Solution d'ions"
          value={solution}
          options={METAUX.map((o) => ({ value: o.value as string, label: o.ion }))}
          onChange={setSolution}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label={`E° du couple ${m.ion}/${m.symbole}`}
          value={`${fmt(m.E, 2)} V`}
          color={PALETTE.blue}
        />
        <Stat
          label={`E° du couple ${s.ion}/${s.symbole}`}
          value={`${fmt(s.E, 2)} V`}
          color={PALETTE.purple}
        />
      </div>

      {reaction && !meme ? (
        <div className="rounded-xl border border-border bg-white p-3 text-center">
          <p className="font-mono text-sm font-semibold text-foreground">
            {m.symbole} + {s.ion} → {m.ion} + {s.symbole}
          </p>
        </div>
      ) : null}

      <Verdict tone={meme ? "warn" : reaction ? "ok" : "bad"}>
        {meme
          ? "Un métal plongé dans ses propres ions n'évolue pas : il n'y a qu'un seul couple en présence."
          : reaction
            ? `Le ${m.nom.toLowerCase()} a un potentiel plus bas, c'est donc le réducteur le plus fort. Il cède ses électrons aux ions ${s.ion}, qui se déposent en métal.`
            : `Le ${m.nom.toLowerCase()} a un potentiel plus élevé que ${s.ion} : il est trop faible comme réducteur, rien ne se passe. Essaie dans l'autre sens.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 15 — Nombre d'oxydation                                    */
/* ------------------------------------------------------------------ */

type Espece = {
  value: string;
  label: string;
  element: string;
  detail: string;
  no: number;
};

const ESPECE_DEFAUT: Espece = {
  value: "mno4",
  label: "MnO₄⁻",
  element: "Mn",
  detail: "x + 4 × (−2) = −1",
  no: 7,
};

const ESPECES: ReadonlyArray<Espece> = [
  ESPECE_DEFAUT,
  { value: "mn2", label: "Mn²⁺", element: "Mn", detail: "ion monoatomique, n.o. = charge", no: 2 },
  { value: "cr2o7", label: "Cr₂O₇²⁻", element: "Cr", detail: "2x + 7 × (−2) = −2", no: 6 },
  { value: "cr3", label: "Cr³⁺", element: "Cr", detail: "ion monoatomique, n.o. = charge", no: 3 },
  { value: "so2", label: "SO₂", element: "S", detail: "x + 2 × (−2) = 0", no: 4 },
  { value: "h2so4", label: "H₂SO₄", element: "S", detail: "2 × (+1) + x + 4 × (−2) = 0", no: 6 },
  { value: "h2s", label: "H₂S", element: "S", detail: "2 × (+1) + x = 0", no: -2 },
  { value: "fe2o3", label: "Fe₂O₃", element: "Fe", detail: "2x + 3 × (−2) = 0", no: 3 },
  { value: "fe", label: "Fe", element: "Fe", detail: "corps simple", no: 0 },
  { value: "ch4", label: "CH₄", element: "C", detail: "x + 4 × (+1) = 0", no: -4 },
  { value: "co2", label: "CO₂", element: "C", detail: "x + 2 × (−2) = 0", no: 4 },
];

function romain(n: number): string {
  const abs = Math.abs(n);
  const r = ["0", "I", "II", "III", "IV", "V", "VI", "VII", "VIII"][abs] ?? String(abs);
  if (n === 0) return "0";
  return (n > 0 ? "+" : "−") + r;
}

export function NombreOxydation() {
  const [g, setG] = useState("mno4");
  const [d, setD] = useState("mn2");

  const eg = ESPECES.find((x) => x.value === g) ?? ESPECE_DEFAUT;
  const ed = ESPECES.find((x) => x.value === d) ?? ESPECE_DEFAUT;

  const memeElement = eg.element === ed.element;
  const variation = ed.no - eg.no;
  const redox = memeElement && variation !== 0;

  return (
    <div className="space-y-3">
      <Panel>
        <Choice
          label="Espèce de départ"
          value={g}
          options={ESPECES.map((o) => ({ value: o.value, label: o.label }))}
          onChange={setG}
        />
        <Choice
          label="Espèce d'arrivée"
          value={d}
          options={ESPECES.map((o) => ({ value: o.value, label: o.label }))}
          onChange={setD}
        />
      </Panel>

      <div className="grid gap-2 sm:grid-cols-2">
        {[eg, ed].map((e, i) => (
          <div key={i} className="rounded-xl border border-border bg-white p-3">
            <p className="text-center font-mono text-base font-semibold text-foreground">
              {e.label}
            </p>
            <p className="mt-2 text-center text-xs text-muted-foreground">{e.detail}</p>
            <p
              className="mt-2 text-center font-mono text-lg font-bold"
              style={{ color: PALETTE.purple }}
            >
              n.o.({e.element}) = {romain(e.no)}
            </p>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Variation" value={memeElement ? fmt(variation, 0) : "—"} color={PALETTE.red} />
        <Stat
          label="Transformation"
          value={
            !memeElement
              ? "éléments différents"
              : variation > 0
                ? "oxydation"
                : variation < 0
                  ? "réduction"
                  : "aucune"
          }
          color={redox ? PALETTE.green : PALETTE.slate}
        />
      </div>

      <Verdict tone={redox ? "ok" : "warn"}>
        {!memeElement
          ? "Choisis deux espèces contenant le même élément : le nombre d'oxydation ne se compare que d'une forme à l'autre d'un même élément."
          : variation > 0
            ? `Le nombre d'oxydation augmente de ${fmt(variation, 0)} : c'est une oxydation, donc une perte de ${fmt(variation, 0)} électron(s).`
            : variation < 0
              ? `Le nombre d'oxydation diminue de ${fmt(-variation, 0)} : c'est une réduction, donc un gain de ${fmt(-variation, 0)} électron(s).`
              : "Le nombre d'oxydation ne change pas : il ne s'agit pas d'une réaction d'oxydoréduction."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 16 — La pile                                               */
/* ------------------------------------------------------------------ */

export function PileDaniell() {
  const [gauche, setGauche] = useState<string>("zn");
  const [droite, setDroite] = useState<string>("cu");
  const [pont, setPont] = useState<"oui" | "non">("oui");

  const a = METAUX.find((x) => x.value === gauche) ?? METAUX[0];
  const b = METAUX.find((x) => x.value === droite) ?? METAUX[0];

  const identique = a.value === b.value;
  const cathode = a.E >= b.E ? a : b;
  const anode = a.E >= b.E ? b : a;
  const fem = cathode.E - anode.E;
  const marche = pont === "oui" && !identique;

  const aEstAnode = anode.value === a.value;

  const W = 440;
  const H = 250;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {[
          { x: 36, m: a, estAnode: aEstAnode },
          { x: 254, m: b, estAnode: !aEstAnode },
        ].map((o, i) => (
          <g key={i}>
            <path
              d={`M${o.x},96 L${o.x},196 Q${o.x},206 ${o.x + 10},206 L${o.x + 130},206 Q${o.x + 150},206 ${o.x + 150},196 L${o.x + 150},96`}
              fill="#e0f2fe"
              stroke={PALETTE.slate}
              strokeWidth={1.8}
            />
            <rect x={o.x + 62} y={76} width={22} height={112} rx={3} fill={PALETTE.slate} />
            <text
              x={o.x + 73}
              y={70}
              textAnchor="middle"
              fontSize={12}
              fontWeight={700}
              fill={PALETTE.ink}
            >
              {o.m.symbole}
            </text>
            <text x={o.x + 75} y={226} textAnchor="middle" fontSize={10.5} fill={PALETTE.slate}>
              {o.m.ion}
            </text>
            {marche ? (
              <text
                x={o.x + 73}
                y={176}
                textAnchor="middle"
                fontSize={20}
                fontWeight={700}
                fill="#ffffff"
              >
                {o.estAnode ? "−" : "+"}
              </text>
            ) : null}
          </g>
        ))}

        <line x1={109} y1={76} x2={109} y2={38} stroke={PALETTE.ink} strokeWidth={2} />
        <line x1={109} y1={38} x2={327} y2={38} stroke={PALETTE.ink} strokeWidth={2} />
        <line x1={327} y1={38} x2={327} y2={76} stroke={PALETTE.ink} strokeWidth={2} />
        <circle cx={218} cy={38} r={15} fill="#ffffff" stroke={PALETTE.ink} strokeWidth={2} />
        <text x={218} y={43} textAnchor="middle" fontSize={11} fontWeight={700} fill={PALETTE.ink}>
          A
        </text>

        {marche ? (
          <Arrow
            x1={aEstAnode ? 150 : 290}
            y1={24}
            x2={aEstAnode ? 250 : 180}
            y2={24}
            color={PALETTE.green}
            width={2.4}
          />
        ) : null}
        {marche ? (
          <text
            x={218}
            y={16}
            textAnchor="middle"
            fontSize={10}
            fontWeight={700}
            fill={PALETTE.green}
          >
            électrons
          </text>
        ) : null}

        {pont === "oui" ? (
          <path
            d="M150,120 Q218,86 290,120"
            fill="none"
            stroke={PALETTE.orange}
            strokeWidth={9}
            strokeLinecap="round"
          />
        ) : null}
        <text
          x={218}
          y={138}
          textAnchor="middle"
          fontSize={10}
          fill={pont === "oui" ? PALETTE.orange : PALETTE.red}
        >
          {pont === "oui" ? "pont salin" : "pont salin retiré"}
        </text>
      </Board>

      <Panel>
        <Choice
          label="Demi-pile de gauche"
          value={gauche}
          options={METAUX.map((o) => ({ value: o.value as string, label: o.nom }))}
          onChange={setGauche}
        />
        <Choice
          label="Demi-pile de droite"
          value={droite}
          options={METAUX.map((o) => ({ value: o.value as string, label: o.nom }))}
          onChange={setDroite}
        />
        <Choice
          label="Pont salin"
          value={pont}
          options={[
            { value: "oui", label: "En place" },
            { value: "non", label: "Retiré" },
          ]}
          onChange={setPont}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Anode, pôle −" value={identique ? "—" : anode.symbole} color={PALETTE.red} />
        <Stat
          label="Cathode, pôle +"
          value={identique ? "—" : cathode.symbole}
          color={PALETTE.blue}
        />
        <Stat
          label="Force électromotrice"
          value={marche ? `${fmt(fem, 2)} V` : "0 V"}
          color={PALETTE.green}
        />
      </div>

      <Verdict tone={marche ? "ok" : "bad"}>
        {identique
          ? "Les deux demi-piles sont identiques : les potentiels sont égaux, la force électromotrice est nulle et aucun courant ne circule."
          : pont === "non"
            ? "Sans pont salin, les charges s'accumulent de chaque côté et bloquent tout de suite la réaction. Aucun courant ne circule, même si la f.é.m. théorique est non nulle."
            : `E = E°(cathode) − E°(anode) = ${fmt(cathode.E, 2)} − (${fmt(anode.E, 2)}) = ${fmt(fem, 2)} V. La lame de ${anode.symbole} maigrit, celle de ${cathode.symbole} grossit.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 17 — Dosage d'oxydoréduction                               */
/* ------------------------------------------------------------------ */

export function DosageRedox() {
  const [concentration, setConcentration] = useState(0.09);
  const [verse, setVerse] = useState(0);

  const Va = 10; // mL de solution de fer II
  const Ctitrant = 1.5e-2; // permanganate
  const coeff = 5; // 1 MnO4- pour 5 Fe2+

  const nFe = (concentration * Va) / 1000;
  const vE = (nFe / coeff / Ctitrant) * 1000;
  const depasse = verse > vE;
  const exces = Math.max(0, verse - vE);
  const intensite = clamp(exces / 4, 0, 1);

  const W = 440;
  const H = 210;
  const couleur = depasse
    ? `rgb(${Math.round(250 - 60 * intensite)},${Math.round(240 - 150 * intensite)},${Math.round(250 - 60 * intensite)})`
    : "#f8fafc";

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <rect
          x={296}
          y={10}
          width={30}
          height={96}
          rx={3}
          fill="#faf5ff"
          stroke={PALETTE.slate}
          strokeWidth={1.6}
        />
        <rect
          x={298}
          y={12 + 92 * clamp(verse / 20, 0, 1)}
          width={26}
          height={92 * (1 - clamp(verse / 20, 0, 1))}
          fill="#7c3aed"
          opacity={0.8}
        />
        <text x={311} y={122} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          burette
        </text>
        <line x1={311} y1={106} x2={311} y2={132} stroke={PALETTE.slate} strokeWidth={1.4} />

        <path
          d="M118,86 L118,176 Q118,190 132,190 L258,190 Q272,190 272,176 L272,86"
          fill={couleur}
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <text x={195} y={206} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          solution de Fe²⁺ acidifiée
        </text>
        {depasse ? (
          <text x={195} y={142} textAnchor="middle" fontSize={13} fontWeight={700} fill="#a21caf">
            teinte rose persistante
          </text>
        ) : (
          <text x={195} y={142} textAnchor="middle" fontSize={12} fill={PALETTE.slate}>
            chaque goutte se décolore
          </text>
        )}
      </Board>

      <Panel>
        <Ctrl
          label="Volume de permanganate versé"
          value={verse}
          min={0}
          max={20}
          step={0.1}
          onChange={setVerse}
          display={`${fmt(verse, 1)} mL`}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Concentration en Fe²⁺ (cachée)"
          value={concentration}
          min={0.02}
          max={0.2}
          step={0.005}
          onChange={setConcentration}
          display={`${fmt(concentration, 3)} mol/L`}
        />
      </Panel>

      <div className="rounded-xl border border-border bg-white p-3 text-center">
        <p className="font-mono text-xs font-semibold text-foreground">
          MnO₄⁻ + 5 Fe²⁺ + 8 H⁺ → Mn²⁺ + 5 Fe³⁺ + 4 H₂O
        </p>
      </div>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Volume à l'équivalence" value={`${fmt(vE, 1)} mL`} color={PALETTE.red} />
        <Stat
          label="Concentration retrouvée"
          value={`${fmt((5 * Ctitrant * vE) / Va, 3)} mol/L`}
          color={PALETTE.green}
        />
      </div>

      <Verdict tone={depasse ? "ok" : "warn"}>
        {depasse
          ? `L'équivalence est franchie à ${fmt(vE, 1)} mL. Applique la relation en tenant compte du coefficient 5 : C = 5 × C(MnO₄⁻) × V(E) / Va. Oublier ce facteur 5 divise le résultat par cinq.`
          : "Continue à verser jusqu'à ce que la teinte rose persiste. Le permanganate est son propre indicateur : tant qu'il reste du fer II, il se décolore aussitôt."}
      </Verdict>
    </div>
  );
}
