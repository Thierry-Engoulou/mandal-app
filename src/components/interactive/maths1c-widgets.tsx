import { useState } from "react";
import {
  Arrow,
  Board,
  Choice,
  Ctrl,
  Grid,
  Handle,
  PALETTE,
  Panel,
  Stat,
  Verdict,
  curvePath,
  fmt,
  makeScales,
} from "./controls";

/** Simulations du programme de Première C : dénombrement, graphes, statistiques
 *  en classes, limites, arcs capables, matrices, espaces vectoriels et géométrie
 *  de l'espace. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/** « + 3 » ou « − 3 », pour écrire une équation proprement. */
function terme(coef: number, lettre = ""): string {
  const signe = coef < 0 ? " − " : " + ";
  const v = Math.abs(coef);
  if (lettre !== "" && v === 1) return `${signe}${lettre}`;
  return `${signe}${fmt(v, 2)}${lettre}`;
}

/** Premier terme d'une équation : « 2x », « −x », « x ». */
function tete(coef: number, lettre: string): string {
  if (coef === 1) return lettre;
  if (coef === -1) return `−${lettre}`;
  return `${fmt(coef, 2)}${lettre}`;
}

function factorielle(n: number): number {
  let r = 1;
  for (let i = 2; i <= n; i++) r *= i;
  return r;
}

/** Perspective cavalière : (x ; y ; z) de l'espace vers le plan de la feuille. */
function cavaliere(x: number, y: number, z: number): { u: number; v: number } {
  const a = (Math.PI * 30) / 180;
  const k = 0.5;
  return { u: x + k * y * Math.cos(a), v: z + k * y * Math.sin(a) };
}

/* ------------------------------------------------------------------ */
/* 1. Dénombrement : l'arbre de choix                                  */
/* ------------------------------------------------------------------ */

const LETTRES = ["A", "B", "C", "D", "E"];

export function DenombrementArbre() {
  const [n, setN] = useState(3);
  const [p, setP] = useState(2);
  const [mode, setMode] = useState<"pupl" | "arr" | "comb">("pupl");

  const repetition = mode === "pupl";
  const possible = repetition || p <= n;

  // toutes les listes de p objets choisis parmi les n premières lettres
  function construire(prefixe: number[]): number[][] {
    if (prefixe.length === p) return [prefixe];
    const sortie: number[][] = [];
    for (let i = 0; i < n; i++) {
      if (!repetition && prefixe.includes(i)) continue;
      sortie.push(...construire([...prefixe, i]));
    }
    return sortie;
  }
  const listes = possible ? construire([]) : [];

  // pour les combinaisons on ne garde qu'un représentant par sous-ensemble
  const vues = new Set<string>();
  const retenues = listes.filter((l) => {
    if (mode !== "comb") return true;
    const cle = [...l].sort((x, y) => x - y).join("-");
    if (vues.has(cle)) return false;
    vues.add(cle);
    return true;
  });

  const nbPupl = Math.pow(n, p);
  const nbArr = p <= n ? factorielle(n) / factorielle(n - p) : 0;
  const nbComb = p <= n ? nbArr / factorielle(p) : 0;
  const total = mode === "pupl" ? nbPupl : mode === "arr" ? nbArr : nbComb;

  const formule =
    mode === "pupl"
      ? `${n}^${p} = ${nbPupl}`
      : mode === "arr"
        ? `A(${p}, ${n}) = ${n}!/(${n}−${p})! = ${nbArr}`
        : `C(${p}, ${n}) = ${n}!/(${p}!×(${n}−${p})!) = ${nbComb}`;

  // l'arbre n'est lisible que pour un petit nombre de feuilles
  const feuilles = listes.length;
  const dessiner = feuilles > 0 && feuilles <= 16;
  const W = 460;
  const H = 40 + p * 72;

  const segments: Array<{ x1: number; y1: number; x2: number; y2: number; k: number }> = [];
  const noeuds: Array<{ x: number; y: number; t: string; k: number }> = [];
  if (dessiner) {
    const parNiveau: number[][][] = [];
    for (let niveau = 1; niveau <= p; niveau++) {
      const uniques: number[][] = [];
      const cles = new Set<string>();
      for (const l of listes) {
        const d = l.slice(0, niveau);
        const c = d.join("-");
        if (!cles.has(c)) {
          cles.add(c);
          uniques.push(d);
        }
      }
      parNiveau.push(uniques);
    }
    const posX = (debut: number[]): number => {
      const groupe = listes.filter((l) => debut.every((v, i) => l[i] === v));
      const indices = groupe.map((l) => listes.indexOf(l));
      const moy = indices.reduce((a, b) => a + b, 0) / Math.max(1, indices.length);
      return 24 + ((moy + 0.5) * (W - 48)) / Math.max(1, feuilles);
    };
    noeuds.push({ x: W / 2, y: 22, t: "départ", k: -1 });
    parNiveau.forEach((uniques, i) => {
      const y = 22 + (i + 1) * 72;
      for (const d of uniques) {
        const dernier = d[d.length - 1] ?? 0;
        const x = posX(d);
        const parent = d.slice(0, d.length - 1);
        const xp = parent.length === 0 ? W / 2 : posX(parent);
        const yp = parent.length === 0 ? 22 : 22 + i * 72;
        segments.push({ x1: xp, y1: yp + 10, x2: x, y2: y - 12, k: dernier });
        noeuds.push({ x, y, t: LETTRES[dernier] ?? "?", k: dernier });
      }
    });
  }

  const couleurs = [PALETTE.blue, PALETTE.red, PALETTE.green, PALETTE.orange, PALETTE.purple];

  return (
    <div className="space-y-3">
      <Choice
        label="Je choisis p objets parmi n"
        value={mode}
        options={[
          { value: "pupl", label: "p-uplets (avec répétition)" },
          { value: "arr", label: "Arrangements (sans répétition, ordonnés)" },
          { value: "comb", label: "Combinaisons (sans ordre)" },
        ]}
        onChange={setMode}
      />
      <Panel>
        <Ctrl label="n objets disponibles" value={n} min={2} max={5} step={1} onChange={setN} />
        <Ctrl
          label="p objets à choisir"
          value={p}
          min={1}
          max={3}
          step={1}
          onChange={setP}
          color={PALETTE.orange}
        />
      </Panel>

      {dessiner ? (
        <Board width={W} height={H}>
          <rect width={W} height={H} fill="#ffffff" />
          {segments.map((s, i) => (
            <line
              key={`s${i}`}
              x1={s.x1}
              y1={s.y1}
              x2={s.x2}
              y2={s.y2}
              stroke={couleurs[s.k] ?? PALETTE.slate}
              strokeWidth={1.6}
              opacity={0.65}
            />
          ))}
          {noeuds.map((nd, i) => (
            <g key={`n${i}`}>
              <circle
                cx={nd.x}
                cy={nd.y}
                r={nd.k < 0 ? 13 : 11}
                fill={nd.k < 0 ? PALETTE.ink : (couleurs[nd.k] ?? PALETTE.slate)}
                opacity={nd.k < 0 ? 0.85 : 0.9}
              />
              <text
                x={nd.x}
                y={nd.y + 4}
                textAnchor="middle"
                fontSize={nd.k < 0 ? 8 : 11}
                fontWeight={700}
                fill="#ffffff"
              >
                {nd.t}
              </text>
            </g>
          ))}
        </Board>
      ) : null}

      {possible ? (
        <div className="rounded-xl border border-border bg-secondary/20 p-2.5">
          <p className="mb-1.5 text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
            Les {mode === "comb" ? "sous-ensembles" : "listes"} possibles ({retenues.length})
          </p>
          <div className="flex flex-wrap gap-1">
            {retenues.slice(0, 60).map((l, i) => (
              <span
                key={`l${i}`}
                className="rounded bg-background px-1.5 py-0.5 font-mono text-[11px] text-foreground"
              >
                {mode === "comb"
                  ? `{${[...l]
                      .sort((x, y) => x - y)
                      .map((v) => LETTRES[v])
                      .join(",")}}`
                  : l.map((v) => LETTRES[v]).join("")}
              </span>
            ))}
            {retenues.length > 60 ? (
              <span className="px-1.5 py-0.5 text-[11px] text-muted-foreground">…</span>
            ) : null}
          </div>
        </div>
      ) : null}

      <Panel>
        <Stat label="Nombre de possibilités" value={String(total)} color={PALETTE.blue} />
        <Stat label="Calcul" value={formule} color={PALETTE.purple} />
      </Panel>

      {!possible ? (
        <Verdict tone="bad">
          Sans répétition, on ne peut pas choisir {p} objets parmi seulement {n}. Baisse p ou
          augmente n.
        </Verdict>
      ) : mode === "pupl" ? (
        <Verdict tone="ok">
          À chaque étape tu as les {n} objets à ta disposition, donc tu multiplies {n} par lui-même{" "}
          {p} fois.
        </Verdict>
      ) : mode === "arr" ? (
        <Verdict tone="ok">
          Un objet déjà pris ne revient plus : {n} choix, puis {Math.max(0, n - 1)}, et ainsi de
          suite. L'ordre compte, AB et BA sont deux arrangements différents.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          L'ordre ne compte plus. Chaque sous-ensemble apparaît {factorielle(p)} fois parmi les{" "}
          {nbArr} arrangements, on divise donc par {p}! = {factorielle(p)}.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. Théorie des graphes                                              */
/* ------------------------------------------------------------------ */

const SOMMETS = ["A", "B", "C", "D", "E"];

export function GrapheAdjacence() {
  const [aretes, setAretes] = useState<string[]>(["0-1", "1-2", "2-3", "3-4", "0-4", "1-3"]);

  const W = 420;
  const H = 300;
  const cx = W / 2;
  const cy = H / 2 - 6;
  const R = 105;
  const pos = SOMMETS.map((_, i) => {
    const a = -Math.PI / 2 + (2 * Math.PI * i) / SOMMETS.length;
    return { x: cx + R * Math.cos(a), y: cy + R * Math.sin(a) };
  });

  const cle = (i: number, j: number) => `${Math.min(i, j)}-${Math.max(i, j)}`;
  const liee = (i: number, j: number) => aretes.includes(cle(i, j));
  const basculer = (i: number, j: number) =>
    setAretes((v) =>
      v.includes(cle(i, j)) ? v.filter((e) => e !== cle(i, j)) : [...v, cle(i, j)],
    );

  const degres = SOMMETS.map((_, i) => SOMMETS.filter((_, j) => j !== i && liee(i, j)).length);
  const sommeDegres = degres.reduce((a, b) => a + b, 0);
  const impairs = degres.filter((d) => d % 2 === 1).length;

  // connexité par parcours en largeur depuis A
  const vus = new Set<number>([0]);
  const file = [0];
  while (file.length > 0) {
    const s = file.shift();
    if (s === undefined) break;
    SOMMETS.forEach((_, j) => {
      if (!vus.has(j) && liee(s, j)) {
        vus.add(j);
        file.push(j);
      }
    });
  }
  const connexe = vus.size === SOMMETS.length;

  const paires: Array<[number, number]> = [];
  for (let i = 0; i < SOMMETS.length; i++) {
    for (let j = i + 1; j < SOMMETS.length; j++) paires.push([i, j]);
  }

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {aretes.map((e) => {
          const [a, b] = e.split("-").map(Number);
          const pa = pos[a ?? 0];
          const pb = pos[b ?? 0];
          if (!pa || !pb) return null;
          return (
            <line
              key={e}
              x1={pa.x}
              y1={pa.y}
              x2={pb.x}
              y2={pb.y}
              stroke={PALETTE.blue}
              strokeWidth={2.6}
              opacity={0.7}
            />
          );
        })}
        {pos.map((p, i) => (
          <g key={`v${i}`}>
            <circle
              cx={p.x}
              cy={p.y}
              r={17}
              fill={vus.has(i) ? PALETTE.green : PALETTE.slate}
              opacity={0.9}
            />
            <text
              x={p.x}
              y={p.y + 5}
              textAnchor="middle"
              fontSize={14}
              fontWeight={700}
              fill="#ffffff"
            >
              {SOMMETS[i]}
            </text>
            <text
              x={p.x}
              y={p.y + 32}
              textAnchor="middle"
              fontSize={10}
              fill={PALETTE.slate}
            >{`degré ${degres[i] ?? 0}`}</text>
          </g>
        ))}
      </Board>

      <div className="space-y-1">
        <p className="text-xs font-medium text-muted-foreground">
          Clique pour créer ou supprimer une arête
        </p>
        <div className="flex flex-wrap gap-1.5">
          {paires.map(([i, j]) => (
            <button
              key={cle(i, j)}
              type="button"
              onClick={() => basculer(i, j)}
              className={
                liee(i, j)
                  ? "rounded-lg bg-primary px-2.5 py-1 font-mono text-xs font-semibold text-primary-foreground"
                  : "rounded-lg border border-border bg-background px-2.5 py-1 font-mono text-xs text-muted-foreground hover:bg-secondary/60"
              }
            >
              {SOMMETS[i]}
              {SOMMETS[j]}
            </button>
          ))}
        </div>
      </div>

      <div className="overflow-hidden rounded-xl border border-border">
        <table className="w-full text-center font-mono text-xs">
          <thead className="bg-secondary/40">
            <tr>
              <th className="px-2 py-1 text-muted-foreground">M</th>
              {SOMMETS.map((s) => (
                <th key={s} className="px-2 py-1 font-semibold">
                  {s}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {SOMMETS.map((s, i) => (
              <tr key={s} className="border-t border-border">
                <td className="bg-secondary/40 px-2 py-1 font-semibold">{s}</td>
                {SOMMETS.map((_, j) => (
                  <td
                    key={j}
                    className={
                      i !== j && liee(i, j) ? "px-2 py-1 font-bold text-primary" : "px-2 py-1"
                    }
                  >
                    {i !== j && liee(i, j) ? 1 : 0}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <Panel>
        <Stat label="Nombre d'arêtes" value={String(aretes.length)} color={PALETTE.blue} />
        <Stat
          label="Somme des degrés"
          value={`${sommeDegres} = 2 × ${aretes.length}`}
          color={PALETTE.purple}
        />
      </Panel>

      {!connexe ? (
        <Verdict tone="bad">
          Le graphe n'est pas connexe : en partant de A tu n'atteins que {vus.size} sommets sur{" "}
          {SOMMETS.length}. Les sommets en gris sont isolés du reste.
        </Verdict>
      ) : impairs === 0 ? (
        <Verdict tone="ok">
          Graphe connexe et tous les degrés sont pairs : il existe un cycle eulérien. Tu peux partir
          d'un sommet, passer une seule fois par chaque arête et revenir au départ.
        </Verdict>
      ) : impairs === 2 ? (
        <Verdict tone="ok">
          Graphe connexe avec exactement 2 sommets de degré impair : il existe une chaîne
          eulérienne. Elle commence à l'un de ces deux sommets et finit à l'autre.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          {impairs} sommets ont un degré impair. Il faut 0 ou 2 sommets impairs pour parcourir
          chaque arête une seule fois.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 3. Série statistique regroupée en classes                           */
/* ------------------------------------------------------------------ */

export function StatsClasses() {
  const [eff, setEff] = useState<number[]>([4, 9, 14, 8, 5]);
  const bornes = [0, 4, 8, 12, 16, 20];

  const set = (i: number, v: number) => setEff((e) => e.map((x, k) => (k === i ? v : x)));

  const N = eff.reduce((a, b) => a + b, 0);
  const centres = eff.map((_, i) => ((bornes[i] ?? 0) + (bornes[i + 1] ?? 0)) / 2);
  const moyenne = N === 0 ? 0 : eff.reduce((a, e, i) => a + e * (centres[i] ?? 0), 0) / N;
  const variance =
    N === 0 ? 0 : eff.reduce((a, e, i) => a + e * Math.pow((centres[i] ?? 0) - moyenne, 2), 0) / N;

  const cumul: number[] = [];
  let c = 0;
  for (const e of eff) {
    c += e;
    cumul.push(c);
  }

  /** Lecture d'un quantile sur le polygone des effectifs cumulés croissants. */
  function quantile(part: number): number {
    if (N === 0) return 0;
    const cible = part * N;
    let avant = 0;
    for (let i = 0; i < eff.length; i++) {
      const e = eff[i] ?? 0;
      if (avant + e >= cible && e > 0) {
        const b0 = bornes[i] ?? 0;
        const b1 = bornes[i + 1] ?? 0;
        return b0 + ((cible - avant) * (b1 - b0)) / e;
      }
      avant += e;
    }
    return bornes[bornes.length - 1] ?? 0;
  }
  const mediane = quantile(0.5);
  const q1 = quantile(0.25);
  const q3 = quantile(0.75);
  const iModale = eff.indexOf(Math.max(...eff));

  const W = 460;
  const H = 250;
  const pad = 34;
  const maxEff = Math.max(1, ...eff);
  const px = (v: number) => pad + ((v - 0) * (W - 2 * pad)) / 20;
  const py = (v: number) => H - pad - (v * (H - 2 * pad)) / maxEff;
  const pyc = (v: number) => H - pad - (v * (H - 2 * pad)) / Math.max(1, N);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={pad}
          y1={H - pad}
          x2={W - pad}
          y2={H - pad}
          stroke={PALETTE.axis}
          strokeWidth={1.6}
        />
        {eff.map((e, i) => {
          const x0 = px(bornes[i] ?? 0);
          const x1 = px(bornes[i + 1] ?? 0);
          return (
            <g key={`b${i}`}>
              <rect
                x={x0}
                y={py(e)}
                width={x1 - x0}
                height={H - pad - py(e)}
                fill={i === iModale ? PALETTE.orange : PALETTE.blue}
                opacity={0.3}
                stroke={i === iModale ? PALETTE.orange : PALETTE.blue}
                strokeWidth={1.6}
              />
              <text
                x={(x0 + x1) / 2}
                y={py(e) - 5}
                textAnchor="middle"
                fontSize={11}
                fontWeight={700}
                fill={i === iModale ? PALETTE.orange : PALETTE.blue}
              >
                {e}
              </text>
            </g>
          );
        })}
        {/* polygone des effectifs cumulés croissants */}
        <polyline
          points={[
            `${px(bornes[0] ?? 0)},${pyc(0)}`,
            ...cumul.map((v, i) => `${px(bornes[i + 1] ?? 0)},${pyc(v)}`),
          ].join(" ")}
          fill="none"
          stroke={PALETTE.green}
          strokeWidth={2.4}
        />
        {/* lecture de la médiane */}
        <line
          x1={pad}
          y1={pyc(N / 2)}
          x2={px(mediane)}
          y2={pyc(N / 2)}
          stroke={PALETTE.red}
          strokeWidth={1.4}
          strokeDasharray="5 4"
        />
        <line
          x1={px(mediane)}
          y1={pyc(N / 2)}
          x2={px(mediane)}
          y2={H - pad}
          stroke={PALETTE.red}
          strokeWidth={1.4}
          strokeDasharray="5 4"
        />
        <text x={px(mediane)} y={H - pad + 14} textAnchor="middle" fontSize={11} fill={PALETTE.red}>
          Me = {fmt(mediane, 1)}
        </text>
        {bornes.map((b) => (
          <text
            key={`t${b}`}
            x={px(b)}
            y={H - pad + 14}
            textAnchor="middle"
            fontSize={10}
            fill={PALETTE.slate}
          >
            {b}
          </text>
        ))}
      </Board>

      <div className="grid gap-2 sm:grid-cols-3">
        {eff.map((e, i) => (
          <Ctrl
            key={`c${i}`}
            label={`[${bornes[i]} ; ${bornes[i + 1]}[`}
            value={e}
            min={0}
            max={20}
            step={1}
            onChange={(v) => set(i, v)}
            color={i === iModale ? PALETTE.orange : PALETTE.blue}
          />
        ))}
      </div>

      <Panel>
        <Stat label="Effectif total N" value={String(N)} />
        <Stat label="Moyenne" value={fmt(moyenne, 2)} color={PALETTE.blue} />
        <Stat label="Médiane (interpolation)" value={fmt(mediane, 2)} color={PALETTE.red} />
        <Stat label="Écart-type" value={fmt(Math.sqrt(variance), 2)} color={PALETTE.purple} />
        <Stat label="Q1" value={fmt(q1, 2)} />
        <Stat label="Q3" value={fmt(q3, 2)} />
      </Panel>

      <Verdict tone="ok">
        La classe modale est [{bornes[iModale]} ; {bornes[iModale + 1]}[. La courbe verte est le
        polygone des effectifs cumulés croissants : la médiane se lit à la hauteur N/2 ={" "}
        {fmt(N / 2, 1)}.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. Limites et asymptotes d'une fonction homographique               */
/* ------------------------------------------------------------------ */

export function LimitesAsymptotes() {
  const [a, setA] = useState(2);
  const [b, setB] = useState(1);
  const [cc, setCc] = useState(1);
  const [d, setD] = useState(-1);
  const [x, setX] = useState(1.6);

  const degenere = cc === 0;
  const xa = degenere ? NaN : -d / cc;
  const ya = degenere ? NaN : a / cc;
  const det = a * d - b * cc; // si nul, la fonction est constante

  const f = (t: number) => (a * t + b) / (cc * t + d);
  const s = makeScales(460, 300, -6, 6, -6, 6);
  const val = f(x);

  return (
    <div className="space-y-3">
      <Board width={460} height={300}>
        <Grid s={s} step={1} />
        {!degenere ? (
          <>
            <line
              x1={s.sx(xa)}
              y1={s.sy(s.yMin)}
              x2={s.sx(xa)}
              y2={s.sy(s.yMax)}
              stroke={PALETTE.red}
              strokeWidth={1.8}
              strokeDasharray="7 5"
            />
            <line
              x1={s.sx(s.xMin)}
              y1={s.sy(ya)}
              x2={s.sx(s.xMax)}
              y2={s.sy(ya)}
              stroke={PALETTE.green}
              strokeWidth={1.8}
              strokeDasharray="7 5"
            />
          </>
        ) : null}
        <path d={curvePath(f, s, 1400)} fill="none" stroke={PALETTE.blue} strokeWidth={2.4} />
        {Number.isFinite(val) && Math.abs(val) <= 6 ? (
          <>
            <line
              x1={s.sx(x)}
              y1={s.sy(0)}
              x2={s.sx(x)}
              y2={s.sy(val)}
              stroke={PALETTE.orange}
              strokeWidth={1.3}
              strokeDasharray="4 3"
            />
            <circle cx={s.sx(x)} cy={s.sy(val)} r={5} fill={PALETTE.orange} />
          </>
        ) : null}
      </Board>

      <Panel>
        <Ctrl label="a" value={a} min={-4} max={4} step={1} onChange={setA} />
        <Ctrl label="b" value={b} min={-4} max={4} step={1} onChange={setB} />
        <Ctrl label="c" value={cc} min={-3} max={3} step={1} onChange={setCc} />
        <Ctrl label="d" value={d} min={-4} max={4} step={1} onChange={setD} />
      </Panel>
      <Ctrl
        label="x se promène"
        value={x}
        min={-6}
        max={6}
        step={0.02}
        onChange={setX}
        color={PALETTE.orange}
      />

      <Panel>
        <Stat
          label="f(x)"
          value={`(${tete(a, "x")}${terme(b)}) / (${tete(cc, "x")}${terme(d)})`}
          color={PALETTE.blue}
        />
        <Stat
          label={`f(${fmt(x, 2)})`}
          value={Number.isFinite(val) ? fmt(val, 3) : "non définie"}
          color={PALETTE.orange}
        />
        <Stat
          label="Asymptote verticale"
          value={degenere ? "aucune" : `x = ${fmt(xa, 2)}`}
          color={PALETTE.red}
        />
        <Stat
          label="Asymptote horizontale"
          value={degenere ? "aucune" : `y = ${fmt(ya, 2)}`}
          color={PALETTE.green}
        />
      </Panel>

      {degenere ? (
        <Verdict tone="warn">
          Avec c = 0 le dénominateur est constant : f est une fonction affine, sa courbe est une
          droite et elle n'a pas d'asymptote.
        </Verdict>
      ) : det === 0 ? (
        <Verdict tone="warn">
          Ici ad − bc = 0 : la fraction se simplifie et f est constante partout où elle est définie.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          Quand x s'approche de {fmt(xa, 2)}, le dénominateur tend vers 0 et |f(x)| devient énorme :
          la droite rouge est asymptote verticale. Quand x part vers +∞ ou −∞, f(x) se colle à{" "}
          {fmt(ya, 2)} : la droite verte est asymptote horizontale.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 5. Arcs capables                                                    */
/* ------------------------------------------------------------------ */

export function ArcsCapables() {
  const s = makeScales(460, 320, -6, 6, -4, 4.4);
  const [A, setA] = useState({ x: -2.4, y: -0.6 });
  const [B, setB] = useState({ x: 2.4, y: -0.6 });
  const [angle, setAngle] = useState(60);
  const [tM, setTM] = useState(0.35);

  const AB = Math.hypot(B.x - A.x, B.y - A.y);
  const rad = (angle * Math.PI) / 180;
  const R = AB / (2 * Math.sin(rad));
  const mx = (A.x + B.x) / 2;
  const my = (A.y + B.y) / 2;
  const nx = -(B.y - A.y) / (AB || 1);
  const ny = (B.x - A.x) / (AB || 1);
  const h = R * Math.cos(rad);

  /** Les points du cercle de centre O qui voient [AB] sous l'angle demandé. */
  function arc(ox: number, oy: number): string {
    let d = "";
    let pen = false;
    for (let i = 0; i <= 360; i++) {
      const t = (i * Math.PI) / 180;
      const px = ox + R * Math.cos(t);
      const py = oy + R * Math.sin(t);
      const v1x = A.x - px;
      const v1y = A.y - py;
      const v2x = B.x - px;
      const v2y = B.y - py;
      const n1 = Math.hypot(v1x, v1y);
      const n2 = Math.hypot(v2x, v2y);
      const cosang = n1 * n2 < 1e-9 ? 2 : (v1x * v2x + v1y * v2y) / (n1 * n2);
      const mes = (Math.acos(clamp(cosang, -1, 1)) * 180) / Math.PI;
      if (Math.abs(mes - angle) > 1.2) {
        pen = false;
        continue;
      }
      d += `${pen ? "L" : "M"}${s.sx(px).toFixed(1)},${s.sy(py).toFixed(1)} `;
      pen = true;
    }
    return d.trim();
  }

  const o1 = { x: mx + h * nx, y: my + h * ny };
  const o2 = { x: mx - h * nx, y: my - h * ny };

  // un point M qui se promène sur l'arc du haut
  const pts: Array<{ x: number; y: number }> = [];
  for (let i = 0; i <= 360; i++) {
    const t = (i * Math.PI) / 180;
    const px = o2.x + R * Math.cos(t);
    const py = o2.y + R * Math.sin(t);
    const n1 = Math.hypot(A.x - px, A.y - py);
    const n2 = Math.hypot(B.x - px, B.y - py);
    const cosang =
      n1 * n2 < 1e-9 ? 2 : ((A.x - px) * (B.x - px) + (A.y - py) * (B.y - py)) / (n1 * n2);
    const mes = (Math.acos(clamp(cosang, -1, 1)) * 180) / Math.PI;
    if (Math.abs(mes - angle) < 1.2) pts.push({ x: px, y: py });
  }
  const M = pts[Math.min(pts.length - 1, Math.max(0, Math.round(tM * (pts.length - 1))))] ?? {
    x: 0,
    y: 1,
  };
  const mesM =
    (Math.acos(
      clamp(
        ((A.x - M.x) * (B.x - M.x) + (A.y - M.y) * (B.y - M.y)) /
          (Math.hypot(A.x - M.x, A.y - M.y) * Math.hypot(B.x - M.x, B.y - M.y) || 1),
        -1,
        1,
      ),
    ) *
      180) /
    Math.PI;

  return (
    <div className="space-y-3">
      <Board width={460} height={320}>
        <Grid s={s} step={1} />
        <path d={arc(o1.x, o1.y)} fill="none" stroke={PALETTE.purple} strokeWidth={2.6} />
        <path d={arc(o2.x, o2.y)} fill="none" stroke={PALETTE.purple} strokeWidth={2.6} />
        <line
          x1={s.sx(A.x)}
          y1={s.sy(A.y)}
          x2={s.sx(B.x)}
          y2={s.sy(B.y)}
          stroke={PALETTE.ink}
          strokeWidth={2.2}
        />
        <line
          x1={s.sx(M.x)}
          y1={s.sy(M.y)}
          x2={s.sx(A.x)}
          y2={s.sy(A.y)}
          stroke={PALETTE.blue}
          strokeWidth={1.8}
        />
        <line
          x1={s.sx(M.x)}
          y1={s.sy(M.y)}
          x2={s.sx(B.x)}
          y2={s.sy(B.y)}
          stroke={PALETTE.blue}
          strokeWidth={1.8}
        />
        <circle cx={s.sx(M.x)} cy={s.sy(M.y)} r={5.5} fill={PALETTE.blue} />
        <text
          x={s.sx(M.x) + 9}
          y={s.sy(M.y) - 9}
          fontSize={13}
          fontWeight={700}
          fill={PALETTE.blue}
        >
          M
        </text>
        <Handle
          x={s.sx(A.x)}
          y={s.sy(A.y)}
          label="A"
          color={PALETTE.red}
          onDrag={(p) => setA({ x: clamp(s.ux(p.x), -5.5, 5.5), y: clamp(s.uy(p.y), -3.5, 3.5) })}
        />
        <Handle
          x={s.sx(B.x)}
          y={s.sy(B.y)}
          label="B"
          color={PALETTE.red}
          onDrag={(p) => setB({ x: clamp(s.ux(p.x), -5.5, 5.5), y: clamp(s.uy(p.y), -3.5, 3.5) })}
        />
      </Board>

      <Panel>
        <Ctrl
          label="Angle demandé"
          value={angle}
          min={15}
          max={165}
          step={1}
          onChange={setAngle}
          display={`${angle}°`}
          color={PALETTE.purple}
        />
        <Ctrl
          label="M se déplace sur l'arc"
          value={tM}
          min={0}
          max={1}
          step={0.01}
          onChange={setTM}
          color={PALETTE.blue}
        />
      </Panel>

      <Panel>
        <Stat label="Mesure de l'angle AMB" value={`${fmt(mesM, 1)}°`} color={PALETTE.blue} />
        <Stat label="Rayon des arcs" value={fmt(Math.abs(R), 2)} color={PALETTE.purple} />
      </Panel>

      <Verdict tone="ok">
        Déplace M le long de l'arc violet : l'angle AMB ne bouge pas. L'ensemble des points qui
        voient [AB] sous un angle de {angle}° est fait de deux arcs symétriques par rapport à (AB).
        C'est l'arc capable d'angle {angle}°.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. Matrice 2×2 et application linéaire                              */
/* ------------------------------------------------------------------ */

export function MatriceTransformation() {
  const [a, setA] = useState(1);
  const [b, setB] = useState(-1);
  const [c, setC] = useState(0.5);
  const [d, setD] = useState(1.5);

  const s = makeScales(460, 330, -5, 5, -4, 4);
  const det = a * d - b * c;

  // une petite maison, pour voir ce que la matrice fait à une figure
  const maison: Array<[number, number]> = [
    [0, 0],
    [2, 0],
    [2, 1.4],
    [1, 2.2],
    [0, 1.4],
  ];
  const image = maison.map(([x, y]): [number, number] => [a * x + b * y, c * x + d * y]);
  const poly = (p: Array<[number, number]>) => p.map(([x, y]) => `${s.sx(x)},${s.sy(y)}`).join(" ");

  const aire = 2 * 1.4 + (2 * 0.8) / 2; // aire de la maison de départ

  return (
    <div className="space-y-3">
      <Board width={460} height={330}>
        <Grid s={s} step={1} />
        <polygon
          points={poly(maison)}
          fill={PALETTE.slate}
          opacity={0.18}
          stroke={PALETTE.slate}
          strokeWidth={1.6}
        />
        <polygon
          points={poly(image)}
          fill={PALETTE.blue}
          opacity={0.22}
          stroke={PALETTE.blue}
          strokeWidth={2.2}
        />
        <Arrow
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(a)}
          y2={s.sy(c)}
          color={PALETTE.red}
          width={2.6}
        />
        <Arrow
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(b)}
          y2={s.sy(d)}
          color={PALETTE.green}
          width={2.6}
        />
        <text x={s.sx(a) + 7} y={s.sy(c) - 6} fontSize={12} fontWeight={700} fill={PALETTE.red}>
          f(i)
        </text>
        <text x={s.sx(b) + 7} y={s.sy(d) - 6} fontSize={12} fontWeight={700} fill={PALETTE.green}>
          f(j)
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="a (ligne 1, colonne 1)"
          value={a}
          min={-3}
          max={3}
          step={0.25}
          onChange={setA}
        />
        <Ctrl
          label="b (ligne 1, colonne 2)"
          value={b}
          min={-3}
          max={3}
          step={0.25}
          onChange={setB}
        />
        <Ctrl
          label="c (ligne 2, colonne 1)"
          value={c}
          min={-3}
          max={3}
          step={0.25}
          onChange={setC}
        />
        <Ctrl
          label="d (ligne 2, colonne 2)"
          value={d}
          min={-3}
          max={3}
          step={0.25}
          onChange={setD}
        />
      </Panel>

      <Panel>
        <Stat
          label="Matrice de f"
          value={`[${fmt(a, 2)} ${fmt(b, 2)} ; ${fmt(c, 2)} ${fmt(d, 2)}]`}
          color={PALETTE.blue}
        />
        <Stat label="Déterminant ad − bc" value={fmt(det, 3)} color={PALETTE.purple} />
        <Stat label="Aire de départ" value={fmt(aire, 2)} />
        <Stat label="Aire de l'image" value={fmt(aire * Math.abs(det), 2)} color={PALETTE.blue} />
      </Panel>

      {Math.abs(det) < 1e-9 ? (
        <Verdict tone="bad">
          Le déterminant est nul : f(i) et f(j) sont colinéaires, toute la maison s'écrase sur une
          droite. f n'est pas bijective, son noyau n'est pas réduit au vecteur nul.
        </Verdict>
      ) : det < 0 ? (
        <Verdict tone="warn">
          Le déterminant est négatif : l'aire est multipliée par {fmt(Math.abs(det), 2)} et
          l'orientation est inversée, comme dans un miroir.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          Le déterminant vaut {fmt(det, 2)} : toutes les aires sont multipliées par ce nombre, et f
          est bijective. Les colonnes de la matrice sont exactement f(i) et f(j).
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 7. Espace vectoriel : combinaison linéaire, famille libre ou liée    */
/* ------------------------------------------------------------------ */

export function EspaceVectoriel() {
  const s = makeScales(460, 330, -6, 6, -4.5, 4.5);
  const [u, setU] = useState({ x: 3, y: 1 });
  const [v, setV] = useState({ x: -1, y: 2.5 });
  const [al, setAl] = useState(1);
  const [be, setBe] = useState(1);

  const det = u.x * v.y - u.y * v.x;
  const libre = Math.abs(det) > 1e-6;
  const w = { x: al * u.x + be * v.x, y: al * u.y + be * v.y };

  return (
    <div className="space-y-3">
      <Board width={460} height={330}>
        <Grid s={s} step={1} />
        {!libre && Math.hypot(u.x, u.y) > 0.2 ? (
          <line
            x1={s.sx(-6 * u.x)}
            y1={s.sy(-6 * u.y)}
            x2={s.sx(6 * u.x)}
            y2={s.sy(6 * u.y)}
            stroke={PALETTE.orange}
            strokeWidth={1.6}
            strokeDasharray="7 5"
          />
        ) : null}
        <Arrow
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(al * u.x)}
          y2={s.sy(al * u.y)}
          color={PALETTE.red}
          width={1.8}
          dashed
        />
        <Arrow
          x1={s.sx(al * u.x)}
          y1={s.sy(al * u.y)}
          x2={s.sx(w.x)}
          y2={s.sy(w.y)}
          color={PALETTE.green}
          width={1.8}
          dashed
        />
        <Arrow
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(w.x)}
          y2={s.sy(w.y)}
          color={PALETTE.purple}
          width={3}
        />
        <text
          x={s.sx(w.x) + 8}
          y={s.sy(w.y) - 8}
          fontSize={13}
          fontWeight={700}
          fill={PALETTE.purple}
        >
          w
        </text>
        <Handle
          x={s.sx(u.x)}
          y={s.sy(u.y)}
          label="u"
          color={PALETTE.red}
          onDrag={(p) => setU({ x: clamp(s.ux(p.x), -5, 5), y: clamp(s.uy(p.y), -4, 4) })}
        />
        <Handle
          x={s.sx(v.x)}
          y={s.sy(v.y)}
          label="v"
          color={PALETTE.green}
          onDrag={(p) => setV({ x: clamp(s.ux(p.x), -5, 5), y: clamp(s.uy(p.y), -4, 4) })}
        />
      </Board>

      <Panel>
        <Ctrl
          label="α"
          value={al}
          min={-3}
          max={3}
          step={0.1}
          onChange={setAl}
          color={PALETTE.red}
        />
        <Ctrl
          label="β"
          value={be}
          min={-3}
          max={3}
          step={0.1}
          onChange={setBe}
          color={PALETTE.green}
        />
      </Panel>

      <Panel>
        <Stat label="u" value={`(${fmt(u.x, 2)} ; ${fmt(u.y, 2)})`} color={PALETTE.red} />
        <Stat label="v" value={`(${fmt(v.x, 2)} ; ${fmt(v.y, 2)})`} color={PALETTE.green} />
        <Stat
          label="w = αu + βv"
          value={`(${fmt(w.x, 2)} ; ${fmt(w.y, 2)})`}
          color={PALETTE.purple}
        />
        <Stat label="Déterminant de (u, v)" value={fmt(det, 3)} />
      </Panel>

      {libre ? (
        <Verdict tone="ok">
          Le déterminant n'est pas nul, u et v ne sont pas colinéaires : la famille (u, v) est
          libre. Elle engendre tout le plan, c'est une base. En réglant α et β tu peux amener w
          absolument partout.
        </Verdict>
      ) : (
        <Verdict tone="bad">
          Le déterminant est nul : u et v sont colinéaires, la famille est liée. Quoi que tu fasses
          avec α et β, w reste sur la droite orange. Deux vecteurs liés n'engendrent qu'une droite.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 8. Orthogonalité dans l'espace, sur un cube                         */
/* ------------------------------------------------------------------ */

type P3 = { x: number; y: number; z: number };

const CUBE: Record<string, P3> = {
  A: { x: 0, y: 0, z: 0 },
  B: { x: 1, y: 0, z: 0 },
  C: { x: 1, y: 1, z: 0 },
  D: { x: 0, y: 1, z: 0 },
  E: { x: 0, y: 0, z: 1 },
  F: { x: 1, y: 0, z: 1 },
  G: { x: 1, y: 1, z: 1 },
  H: { x: 0, y: 1, z: 1 },
};

const ARETES_CUBE = [
  "AB",
  "BC",
  "CD",
  "DA",
  "EF",
  "FG",
  "GH",
  "HE",
  "AE",
  "BF",
  "CG",
  "DH",
] as const;

const DROITES = ["AB", "AD", "AE", "AC", "AG", "BD", "BG", "EG", "CE", "FH"] as const;
const PLANS: ReadonlyArray<{ value: string; label: string; n: P3 }> = [
  { value: "ABCD", label: "(ABCD)", n: { x: 0, y: 0, z: 1 } },
  { value: "EFGH", label: "(EFGH)", n: { x: 0, y: 0, z: 1 } },
  { value: "ABFE", label: "(ABFE)", n: { x: 0, y: 1, z: 0 } },
  { value: "DCGH", label: "(DCGH)", n: { x: 0, y: 1, z: 0 } },
  { value: "ADHE", label: "(ADHE)", n: { x: 1, y: 0, z: 0 } },
  { value: "BCGF", label: "(BCGF)", n: { x: 1, y: 0, z: 0 } },
];

export function CubeOrthogonalite() {
  const [mode, setMode] = useState<"dd" | "dp">("dd");
  const [d1, setD1] = useState<string>("AB");
  const [d2, setD2] = useState<string>("AE");
  const [plan, setPlan] = useState<string>("ABCD");

  const W = 420;
  const H = 320;
  const k = 150;
  const ox = 110;
  const oy = 250;
  const pp = (p: P3) => {
    const c = cavaliere(p.x, p.y, p.z);
    return { x: ox + k * c.u, y: oy - k * c.v };
  };
  const pt = (nom: string): P3 => CUBE[nom] ?? { x: 0, y: 0, z: 0 };
  const dir = (seg: string): P3 => {
    const a = pt(seg.charAt(0));
    const b = pt(seg.charAt(1));
    return { x: b.x - a.x, y: b.y - a.y, z: b.z - a.z };
  };

  const u1 = dir(d1);
  const planChoisi = PLANS.find((p) => p.value === plan) ?? PLANS[0];
  const n = planChoisi?.n ?? { x: 0, y: 0, z: 1 };
  const u2 = mode === "dd" ? dir(d2) : n;

  const ps = u1.x * u2.x + u1.y * u2.y + u1.z * u2.z;
  const n1 = Math.sqrt(u1.x * u1.x + u1.y * u1.y + u1.z * u1.z);
  const n2 = Math.sqrt(u2.x * u2.x + u2.y * u2.y + u2.z * u2.z);
  const mes = (Math.acos(clamp(ps / (n1 * n2 || 1), -1, 1)) * 180) / Math.PI;
  const orth = Math.abs(ps) < 1e-9;
  const colin = Math.abs(Math.abs(ps) - n1 * n2) < 1e-9;

  const facePoints = (f: string) =>
    f
      .split("")
      .map((c) => pp(pt(c)))
      .map((p) => `${p.x},${p.y}`)
      .join(" ");

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {mode === "dp" ? (
          <polygon
            points={facePoints(plan)}
            fill={PALETTE.green}
            opacity={0.2}
            stroke={PALETTE.green}
            strokeWidth={2}
          />
        ) : null}
        {ARETES_CUBE.map((e) => {
          const a = pp(pt(e.charAt(0)));
          const b = pp(pt(e.charAt(1)));
          return (
            <line
              key={e}
              x1={a.x}
              y1={a.y}
              x2={b.x}
              y2={b.y}
              stroke={PALETTE.slate}
              strokeWidth={1.4}
              opacity={0.55}
            />
          );
        })}
        {[d1, ...(mode === "dd" ? [d2] : [])].map((seg, i) => {
          const a = pp(pt(seg.charAt(0)));
          const b = pp(pt(seg.charAt(1)));
          return (
            <line
              key={`sel${i}`}
              x1={a.x}
              y1={a.y}
              x2={b.x}
              y2={b.y}
              stroke={i === 0 ? PALETTE.red : PALETTE.blue}
              strokeWidth={3.4}
            />
          );
        })}
        {Object.keys(CUBE).map((nom) => {
          const p = pp(pt(nom));
          return (
            <g key={nom}>
              <circle cx={p.x} cy={p.y} r={3.4} fill={PALETTE.ink} />
              <text x={p.x + 7} y={p.y - 5} fontSize={12} fontWeight={700} fill={PALETTE.ink}>
                {nom}
              </text>
            </g>
          );
        })}
      </Board>

      <Choice
        label="Qu'est-ce que je compare ?"
        value={mode}
        options={[
          { value: "dd", label: "Deux droites" },
          { value: "dp", label: "Une droite et un plan" },
        ]}
        onChange={setMode}
      />
      <Choice
        label="Première droite"
        value={d1}
        options={DROITES.map((d) => ({ value: d as string, label: `(${d})` }))}
        onChange={setD1}
      />
      {mode === "dd" ? (
        <Choice
          label="Deuxième droite"
          value={d2}
          options={DROITES.map((d) => ({ value: d as string, label: `(${d})` }))}
          onChange={setD2}
        />
      ) : (
        <Choice
          label="Plan"
          value={plan}
          options={PLANS.map((p) => ({ value: p.value, label: p.label }))}
          onChange={setPlan}
        />
      )}

      <Panel>
        <Stat
          label="Vecteur directeur de la 1ère droite"
          value={`(${u1.x} ; ${u1.y} ; ${u1.z})`}
          color={PALETTE.red}
        />
        <Stat
          label={mode === "dd" ? "Vecteur directeur de la 2ème" : "Vecteur normal au plan"}
          value={`(${u2.x} ; ${u2.y} ; ${u2.z})`}
          color={mode === "dd" ? PALETTE.blue : PALETTE.green}
        />
        <Stat label="Produit scalaire" value={fmt(ps, 3)} color={PALETTE.purple} />
        <Stat label="Angle" value={`${fmt(mes, 1)}°`} />
      </Panel>

      {mode === "dd" ? (
        orth ? (
          <Verdict tone="ok">
            Le produit scalaire des vecteurs directeurs est nul : les deux droites sont
            orthogonales. Attention, orthogonales ne veut pas dire sécantes. Dans l'espace deux
            droites peuvent être orthogonales sans jamais se rencontrer.
          </Verdict>
        ) : (
          <Verdict tone="warn">
            Le produit scalaire vaut {fmt(ps, 2)}, il n'est pas nul : les droites font un angle de{" "}
            {fmt(mes, 1)}°, elles ne sont pas orthogonales.
          </Verdict>
        )
      ) : colin ? (
        <Verdict tone="ok">
          Le vecteur directeur de la droite est colinéaire au vecteur normal du plan : la droite est
          perpendiculaire au plan. Elle est alors orthogonale à toutes les droites de ce plan.
        </Verdict>
      ) : orth ? (
        <Verdict tone="warn">
          Le vecteur directeur est orthogonal au vecteur normal : la droite est parallèle au plan ou
          contenue dedans, pas perpendiculaire.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          La droite perce le plan en faisant un angle, mais elle n'est pas perpendiculaire.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 9. La sphère et sa section par un plan                              */
/* ------------------------------------------------------------------ */

export function SphereSection() {
  const [R, setR] = useState(4);
  const [d, setD] = useState(2);

  const secant = d < R - 1e-9;
  const tangent = Math.abs(d - R) < 1e-9;
  const r = secant ? Math.sqrt(R * R - d * d) : 0;

  const W = 460;
  const H = 300;
  const k = 26;
  const cx = 150;
  const cy = H / 2;
  const demiCorde = r * k;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {/* vue en coupe : la sphère de profil */}
        <circle
          cx={cx}
          cy={cy}
          r={R * k}
          fill={PALETTE.blue}
          opacity={0.12}
          stroke={PALETTE.blue}
          strokeWidth={2}
        />
        <line
          x1={20}
          y1={cy - d * k}
          x2={290}
          y2={cy - d * k}
          stroke={PALETTE.green}
          strokeWidth={2.4}
        />
        <text x={24} y={cy - d * k - 7} fontSize={11} fill={PALETTE.green}>
          le plan (P)
        </text>
        <line x1={cx} y1={cy} x2={cx} y2={cy - d * k} stroke={PALETTE.red} strokeWidth={2} />
        <text x={cx + 6} y={cy - (d * k) / 2} fontSize={11} fill={PALETTE.red}>
          d = {fmt(d, 2)}
        </text>
        {secant ? (
          <>
            <line
              x1={cx - demiCorde}
              y1={cy - d * k}
              x2={cx + demiCorde}
              y2={cy - d * k}
              stroke={PALETTE.orange}
              strokeWidth={3.4}
            />
            <line
              x1={cx}
              y1={cy}
              x2={cx + demiCorde}
              y2={cy - d * k}
              stroke={PALETTE.blue}
              strokeWidth={1.4}
              strokeDasharray="4 3"
            />
          </>
        ) : null}
        <circle cx={cx} cy={cy} r={3.4} fill={PALETTE.ink} />
        <text x={cx - 16} y={cy + 15} fontSize={12} fontWeight={700} fill={PALETTE.ink}>
          O
        </text>

        {/* vue en perspective : le cercle de section */}
        <g transform="translate(360, 150)">
          <ellipse
            rx={R * k * 0.62}
            ry={R * k * 0.62}
            fill={PALETTE.blue}
            opacity={0.1}
            stroke={PALETTE.blue}
            strokeWidth={1.6}
          />
          {secant ? (
            <ellipse
              rx={r * k * 0.62}
              ry={r * k * 0.62 * 0.35}
              cy={-d * k * 0.62}
              fill={PALETTE.orange}
              opacity={0.3}
              stroke={PALETTE.orange}
              strokeWidth={2.2}
            />
          ) : null}
          <text y={R * k * 0.62 + 18} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
            en perspective
          </text>
        </g>
      </Board>

      <Panel>
        <Ctrl label="Rayon R de la sphère" value={R} min={2} max={5} step={0.1} onChange={setR} />
        <Ctrl
          label="Distance d du centre au plan"
          value={d}
          min={0}
          max={6}
          step={0.1}
          onChange={setD}
          color={PALETTE.red}
        />
      </Panel>

      <Panel>
        <Stat label="R" value={fmt(R, 2)} color={PALETTE.blue} />
        <Stat label="d" value={fmt(d, 2)} color={PALETTE.red} />
        <Stat
          label="Rayon r de la section"
          value={secant ? `√(${fmt(R * R, 2)} − ${fmt(d * d, 2)}) = ${fmt(r, 2)}` : "—"}
          color={PALETTE.orange}
        />
        <Stat
          label="Aire du disque de section"
          value={secant ? fmt(Math.PI * r * r, 2) : "0"}
          color={PALETTE.purple}
        />
      </Panel>

      {secant ? (
        <Verdict tone="ok">
          d &lt; R : le plan coupe la sphère suivant un cercle de rayon r = √(R² − d²) = {fmt(r, 2)}
          . Le théorème de Pythagore dans le triangle rectangle du dessin donne directement ce
          résultat.
        </Verdict>
      ) : tangent ? (
        <Verdict tone="warn">
          d = R exactement : le plan est tangent à la sphère, il la touche en un seul point. Le
          cercle de section est réduit à ce point.
        </Verdict>
      ) : (
        <Verdict tone="bad">
          d &gt; R : le plan passe trop loin du centre, il ne rencontre pas la sphère.
          L'intersection est vide.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 10. Repère de l'espace : lire les coordonnées d'un point            */
/* ------------------------------------------------------------------ */

export function RepereEspace() {
  const [x, setX] = useState(2);
  const [y, setY] = useState(3);
  const [z, setZ] = useState(2);

  const W = 440;
  const H = 320;
  const k = 42;
  const ox = 120;
  const oy = 255;
  const pp = (px: number, py: number, pz: number) => {
    const c = cavaliere(px, py, pz);
    return { x: ox + k * c.u, y: oy - k * c.v };
  };

  const O = pp(0, 0, 0);
  const M = pp(x, y, z);
  const Mxy = pp(x, y, 0);
  const Px = pp(x, 0, 0);
  const Pxy0 = pp(0, y, 0);
  const norme = Math.sqrt(x * x + y * y + z * z);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {/* les trois axes */}
        <Arrow x1={O.x} y1={O.y} x2={pp(4.4, 0, 0).x} y2={pp(4.4, 0, 0).y} color={PALETTE.red} />
        <Arrow x1={O.x} y1={O.y} x2={pp(0, 4.4, 0).x} y2={pp(0, 4.4, 0).y} color={PALETTE.green} />
        <Arrow x1={O.x} y1={O.y} x2={pp(0, 0, 4.4).x} y2={pp(0, 0, 4.4).y} color={PALETTE.blue} />
        <text x={pp(4.6, 0, 0).x} y={pp(4.6, 0, 0).y + 4} fontSize={12} fill={PALETTE.red}>
          x
        </text>
        <text x={pp(0, 4.7, 0).x} y={pp(0, 4.7, 0).y + 4} fontSize={12} fill={PALETTE.green}>
          y
        </text>
        <text x={pp(0, 0, 4.6).x - 4} y={pp(0, 0, 4.6).y - 6} fontSize={12} fill={PALETTE.blue}>
          z
        </text>

        {/* le pavé de lecture */}
        {[
          [Px, Mxy],
          [Pxy0, Mxy],
          [Mxy, M],
        ].map(([a, b], i) =>
          a && b ? (
            <line
              key={`p${i}`}
              x1={a.x}
              y1={a.y}
              x2={b.x}
              y2={b.y}
              stroke={PALETTE.slate}
              strokeWidth={1.4}
              strokeDasharray="5 4"
            />
          ) : null,
        )}
        <line
          x1={O.x}
          y1={O.y}
          x2={M.x}
          y2={M.y}
          stroke={PALETTE.purple}
          strokeWidth={2.4}
          opacity={0.8}
        />
        <circle cx={Mxy.x} cy={Mxy.y} r={3.4} fill={PALETTE.slate} />
        <text x={Mxy.x + 6} y={Mxy.y + 14} fontSize={10} fill={PALETTE.slate}>
          projeté sur (xOy)
        </text>
        <circle cx={M.x} cy={M.y} r={6} fill={PALETTE.purple} />
        <text x={M.x + 9} y={M.y - 9} fontSize={13} fontWeight={700} fill={PALETTE.purple}>
          M
        </text>
        <circle cx={O.x} cy={O.y} r={3.4} fill={PALETTE.ink} />
        <text x={O.x - 16} y={O.y + 15} fontSize={12} fontWeight={700} fill={PALETTE.ink}>
          O
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="abscisse x"
          value={x}
          min={-3}
          max={4}
          step={0.5}
          onChange={setX}
          color={PALETTE.red}
        />
        <Ctrl
          label="ordonnée y"
          value={y}
          min={-3}
          max={4}
          step={0.5}
          onChange={setY}
          color={PALETTE.green}
        />
        <Ctrl
          label="cote z"
          value={z}
          min={-3}
          max={4}
          step={0.5}
          onChange={setZ}
          color={PALETTE.blue}
        />
      </Panel>

      <Panel>
        <Stat
          label="Coordonnées de M"
          value={`(${fmt(x, 1)} ; ${fmt(y, 1)} ; ${fmt(z, 1)})`}
          color={PALETTE.purple}
        />
        <Stat
          label="Distance OM"
          value={`√(${fmt(x * x + y * y + z * z, 2)}) = ${fmt(norme, 3)}`}
          color={PALETTE.blue}
        />
        <Stat
          label="Projeté sur (xOy)"
          value={`(${fmt(x, 1)} ; ${fmt(y, 1)} ; 0)`}
          color={PALETTE.slate}
        />
        <Stat
          label="Milieu de [OM]"
          value={`(${fmt(x / 2, 2)} ; ${fmt(y / 2, 2)} ; ${fmt(z / 2, 2)})`}
        />
      </Panel>

      <Verdict tone="ok">
        Pour placer M tu avances de {fmt(x, 1)} sur l'axe des x, puis de {fmt(y, 1)} sur l'axe des
        y, puis tu montes de {fmt(z, 1)}. Les pointillés forment le pavé qui sert à lire les trois
        coordonnées, et OM = √(x² + y² + z²).
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 11. Distance d'un point à une droite, équation normale              */
/* ------------------------------------------------------------------ */

export function DistanceDroite() {
  const s = makeScales(460, 320, -6, 6, -4, 4.4);
  const [a, setA] = useState(2);
  const [b, setB] = useState(-1);
  const [c, setC] = useState(1);
  const [M, setM] = useState({ x: 2.5, y: 2.2 });

  const norme = Math.hypot(a, b);
  const valide = norme > 1e-9;
  const dist = valide ? Math.abs(a * M.x + b * M.y + c) / norme : 0;
  const t = valide ? (a * M.x + b * M.y + c) / (norme * norme) : 0;
  const Hx = M.x - a * t;
  const Hy = M.y - b * t;

  // la droite, découpée au cadre
  const pts: Array<[number, number]> = [];
  if (valide) {
    if (Math.abs(b) > 1e-9) {
      pts.push([s.xMin, (-c - a * s.xMin) / b]);
      pts.push([s.xMax, (-c - a * s.xMax) / b]);
    } else {
      pts.push([-c / a, s.yMin]);
      pts.push([-c / a, s.yMax]);
    }
  }
  const p0 = pts[0];
  const p1 = pts[1];

  return (
    <div className="space-y-3">
      <Board width={460} height={320}>
        <Grid s={s} step={1} />
        {p0 && p1 ? (
          <line
            x1={s.sx(p0[0])}
            y1={s.sy(p0[1])}
            x2={s.sx(p1[0])}
            y2={s.sy(p1[1])}
            stroke={PALETTE.blue}
            strokeWidth={2.6}
          />
        ) : null}
        {valide ? (
          <>
            <line
              x1={s.sx(M.x)}
              y1={s.sy(M.y)}
              x2={s.sx(Hx)}
              y2={s.sy(Hy)}
              stroke={PALETTE.red}
              strokeWidth={2.2}
              strokeDasharray="6 4"
            />
            <circle cx={s.sx(Hx)} cy={s.sy(Hy)} r={4.5} fill={PALETTE.red} />
            <text x={s.sx(Hx) + 8} y={s.sy(Hy) + 14} fontSize={12} fill={PALETTE.red}>
              H
            </text>
            <Arrow
              x1={s.sx(Hx)}
              y1={s.sy(Hy)}
              x2={s.sx(Hx + a / norme)}
              y2={s.sy(Hy + b / norme)}
              color={PALETTE.green}
              width={2.4}
            />
          </>
        ) : null}
        <Handle
          x={s.sx(M.x)}
          y={s.sy(M.y)}
          label="M"
          color={PALETTE.purple}
          onDrag={(p) => setM({ x: clamp(s.ux(p.x), -5.5, 5.5), y: clamp(s.uy(p.y), -3.6, 4) })}
        />
      </Board>

      <Panel>
        <Ctrl label="a" value={a} min={-4} max={4} step={1} onChange={setA} />
        <Ctrl label="b" value={b} min={-4} max={4} step={1} onChange={setB} />
        <Ctrl label="c" value={c} min={-5} max={5} step={1} onChange={setC} />
      </Panel>

      <Panel>
        <Stat
          label="Équation de (D)"
          value={`${tete(a, "x")}${terme(b, "y")}${terme(c)} = 0`}
          color={PALETTE.blue}
        />
        <Stat label="Vecteur normal" value={`(${a} ; ${b})`} color={PALETTE.green} />
        <Stat
          label="Distance de M à (D)"
          value={
            valide
              ? `${fmt(Math.abs(a * M.x + b * M.y + c), 2)} / ${fmt(norme, 3)} = ${fmt(dist, 3)}`
              : "—"
          }
          color={PALETTE.red}
        />
        <Stat
          label="Projeté orthogonal H"
          value={valide ? `(${fmt(Hx, 2)} ; ${fmt(Hy, 2)})` : "—"}
        />
      </Panel>

      {!valide ? (
        <Verdict tone="bad">
          Avec a = 0 et b = 0 il n'y a plus de droite : un vecteur normal ne peut pas être le
          vecteur nul.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          La distance de M à la droite, c'est la longueur MH, et H est le pied de la
          perpendiculaire. On l'obtient sans construire H, avec |a·x + b·y + c| divisé par √(a² +
          b²).
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 12. Tangentes à un cercle issues d'un point                         */
/* ------------------------------------------------------------------ */

export function TangentesCercle() {
  const s = makeScales(460, 320, -6, 6, -4, 4.4);
  const [R, setR] = useState(2);
  const [P, setP] = useState({ x: 4, y: 2 });

  const dOP = Math.hypot(P.x, P.y);
  const exterieur = dOP > R + 1e-9;
  const tangent = Math.abs(dOP - R) < 1e-9;
  const L = exterieur ? Math.sqrt(dOP * dOP - R * R) : 0;

  // points de contact : ils voient [OP] sous un angle droit
  const contacts: Array<{ x: number; y: number }> = [];
  if (exterieur) {
    const base = Math.atan2(P.y, P.x);
    const ecart = Math.acos(clamp(R / dOP, -1, 1));
    for (const sgn of [1, -1]) {
      const t = base + sgn * ecart;
      contacts.push({ x: R * Math.cos(t), y: R * Math.sin(t) });
    }
  }

  return (
    <div className="space-y-3">
      <Board width={460} height={320}>
        <Grid s={s} step={1} />
        <circle
          cx={s.sx(0)}
          cy={s.sy(0)}
          r={Math.abs(s.sx(R) - s.sx(0))}
          fill={PALETTE.blue}
          opacity={0.08}
          stroke={PALETTE.blue}
          strokeWidth={2.2}
        />
        {/* le cercle de diamètre [OP] : il porte les points de contact */}
        {exterieur ? (
          <circle
            cx={s.sx(P.x / 2)}
            cy={s.sy(P.y / 2)}
            r={Math.abs(s.sx(dOP / 2) - s.sx(0))}
            fill="none"
            stroke={PALETTE.slate}
            strokeWidth={1.2}
            strokeDasharray="5 4"
          />
        ) : null}
        {contacts.map((T, i) => (
          <g key={`t${i}`}>
            <line
              x1={s.sx(P.x)}
              y1={s.sy(P.y)}
              x2={s.sx(T.x + (T.x - P.x) * 0.5)}
              y2={s.sy(T.y + (T.y - P.y) * 0.5)}
              stroke={PALETTE.orange}
              strokeWidth={2.4}
            />
            <line
              x1={s.sx(0)}
              y1={s.sy(0)}
              x2={s.sx(T.x)}
              y2={s.sy(T.y)}
              stroke={PALETTE.green}
              strokeWidth={1.5}
              strokeDasharray="4 3"
            />
            <circle cx={s.sx(T.x)} cy={s.sy(T.y)} r={5} fill={PALETTE.orange} />
            <text
              x={s.sx(T.x) + 8}
              y={s.sy(T.y) - 7}
              fontSize={12}
              fontWeight={700}
              fill={PALETTE.orange}
            >
              T{i + 1}
            </text>
          </g>
        ))}
        <circle cx={s.sx(0)} cy={s.sy(0)} r={3.6} fill={PALETTE.ink} />
        <text x={s.sx(0) - 16} y={s.sy(0) + 16} fontSize={12} fontWeight={700} fill={PALETTE.ink}>
          O
        </text>
        <Handle
          x={s.sx(P.x)}
          y={s.sy(P.y)}
          label="P"
          color={PALETTE.purple}
          onDrag={(p) => setP({ x: clamp(s.ux(p.x), -5.5, 5.5), y: clamp(s.uy(p.y), -3.6, 4) })}
        />
      </Board>

      <Ctrl label="Rayon R du cercle" value={R} min={0.5} max={3.5} step={0.1} onChange={setR} />

      <Panel>
        <Stat label="OP" value={fmt(dOP, 3)} color={PALETTE.purple} />
        <Stat label="R" value={fmt(R, 2)} color={PALETTE.blue} />
        <Stat
          label="Longueur de tangente PT"
          value={exterieur ? `√(${fmt(dOP * dOP, 2)} − ${fmt(R * R, 2)}) = ${fmt(L, 3)}` : "—"}
          color={PALETTE.orange}
        />
        <Stat label="Nombre de tangentes" value={exterieur ? "2" : tangent ? "1" : "0"} />
      </Panel>

      {exterieur ? (
        <Verdict tone="ok">
          P est à l'extérieur : il part exactement deux tangentes, et elles ont la même longueur PT
          = √(OP² − R²). Les points de contact sont sur le cercle gris de diamètre [OP], parce que
          l'angle OTP est droit.
        </Verdict>
      ) : tangent ? (
        <Verdict tone="warn">
          P est pile sur le cercle : il n'y a qu'une seule tangente, celle qui passe par P
          perpendiculairement au rayon [OP].
        </Verdict>
      ) : (
        <Verdict tone="bad">
          P est à l'intérieur du cercle : aucune droite passant par P ne peut être tangente.
        </Verdict>
      )}
    </div>
  );
}
