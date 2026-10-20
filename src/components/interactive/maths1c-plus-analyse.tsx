import { useState } from "react";
import {
  Board,
  Choice,
  Ctrl,
  Grid,
  PALETTE,
  Panel,
  Stat,
  Verdict,
  curvePath,
  fmt,
  makeScales,
} from "./controls";

/** Simulations d'analyse et de statistiques complémentaires du programme de 1ère C. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/** Écrit un rang en indice : 6 devient ₆. */
function indice(n: number): string {
  const chiffres = "₀₁₂₃₄₅₆₇₈₉";
  return String(n)
    .split("")
    .map((d) => chiffres[Number(d)] ?? d)
    .join("");
}

/* ------------------------------------------------------------------ */
/* ch05 — Lire une courbe                                              */
/* ------------------------------------------------------------------ */

export function LireCourbe() {
  const [x, setX] = useState(2.5);
  const [lecture, setLecture] = useState<"image" | "antecedents" | "variations">("image");

  // f(x) = 0,25 x^3 - 1,5 x + 1
  const f = (t: number) => 0.25 * t * t * t - 1.5 * t + 1;
  const fp = (t: number) => 0.75 * t * t - 1.5;
  const xA = -Math.sqrt(2);
  const xB = Math.sqrt(2);

  const y = f(x);
  // antecedents de y : on balaie la courbe
  const anteced: number[] = [];
  for (let t = -4; t <= 4; t += 0.002) {
    if ((f(t) - y) * (f(t + 0.002) - y) <= 0) anteced.push(Number((t + 0.001).toFixed(3)));
  }
  const uniques = anteced.filter((t, i) => anteced.findIndex((u) => Math.abs(u - t) < 0.05) === i);

  const W = 420;
  const H = 260;
  const s = makeScales(W, H, -4, 4, -4, 5, 28);

  return (
    <div className="space-y-3">
      <Choice
        label="Ce que je veux lire"
        value={lecture}
        options={[
          { value: "image", label: "L'image de x" },
          { value: "antecedents", label: "Les antécédents" },
          { value: "variations", label: "Les variations" },
        ]}
        onChange={setLecture}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={1} />
        {lecture === "variations" ? (
          <>
            <rect
              x={s.sx(-4)}
              y={s.sy(5)}
              width={s.sx(xA) - s.sx(-4)}
              height={s.sy(-4) - s.sy(5)}
              fill={PALETTE.green}
              opacity={0.08}
            />
            <rect
              x={s.sx(xA)}
              y={s.sy(5)}
              width={s.sx(xB) - s.sx(xA)}
              height={s.sy(-4) - s.sy(5)}
              fill={PALETTE.red}
              opacity={0.08}
            />
            <rect
              x={s.sx(xB)}
              y={s.sy(5)}
              width={s.sx(4) - s.sx(xB)}
              height={s.sy(-4) - s.sy(5)}
              fill={PALETTE.green}
              opacity={0.08}
            />
          </>
        ) : null}
        <path d={curvePath(f, s)} fill="none" stroke={PALETTE.blue} strokeWidth={2.8} />

        {lecture === "image" ? (
          <>
            <line
              x1={s.sx(x)}
              y1={s.sy(0)}
              x2={s.sx(x)}
              y2={s.sy(clamp(y, -4, 5))}
              stroke={PALETTE.orange}
              strokeWidth={1.6}
              strokeDasharray="5 4"
            />
            <line
              x1={s.sx(0)}
              y1={s.sy(clamp(y, -4, 5))}
              x2={s.sx(x)}
              y2={s.sy(clamp(y, -4, 5))}
              stroke={PALETTE.orange}
              strokeWidth={1.6}
              strokeDasharray="5 4"
            />
            <circle cx={s.sx(x)} cy={s.sy(clamp(y, -4, 5))} r={6} fill={PALETTE.orange} />
          </>
        ) : null}

        {lecture === "antecedents" ? (
          <>
            <line
              x1={s.sx(-4)}
              y1={s.sy(clamp(y, -4, 5))}
              x2={s.sx(4)}
              y2={s.sy(clamp(y, -4, 5))}
              stroke={PALETTE.orange}
              strokeWidth={2}
              strokeDasharray="5 4"
            />
            {uniques.map((t, i) => (
              <circle key={i} cx={s.sx(t)} cy={s.sy(clamp(y, -4, 5))} r={6} fill={PALETTE.green} />
            ))}
          </>
        ) : null}

        {lecture === "variations" ? (
          <>
            <circle cx={s.sx(xA)} cy={s.sy(f(xA))} r={6} fill={PALETTE.purple} />
            <circle cx={s.sx(xB)} cy={s.sy(f(xB))} r={6} fill={PALETTE.purple} />
            <text
              x={s.sx(xA)}
              y={s.sy(f(xA)) - 12}
              textAnchor="middle"
              fontSize={10}
              fontWeight={700}
              fill={PALETTE.purple}
              stroke="#ffffff"
              strokeWidth={3}
              paintOrder="stroke"
            >
              maximum local
            </text>
            <text
              x={s.sx(xB)}
              y={s.sy(f(xB)) + 20}
              textAnchor="middle"
              fontSize={10}
              fontWeight={700}
              fill={PALETTE.purple}
              stroke="#ffffff"
              strokeWidth={3}
              paintOrder="stroke"
            >
              minimum local
            </text>
          </>
        ) : null}
      </Board>

      <Ctrl
        label="Abscisse x"
        value={x}
        min={-4}
        max={4}
        step={0.1}
        onChange={setX}
        display={fmt(x, 1)}
        color={PALETTE.orange}
      />

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Image f(x)" value={fmt(y, 3)} color={PALETTE.orange} />
        <Stat
          label={`Antécédents de ${fmt(y, 2)}`}
          value={uniques.map((t) => fmt(t, 2)).join(" · ")}
          color={PALETTE.green}
        />
        <Stat
          label="Sens de variation en x"
          value={fp(x) > 0 ? "croissante" : fp(x) < 0 ? "décroissante" : "extremum"}
          color={fp(x) > 0 ? PALETTE.green : PALETTE.red}
        />
      </div>

      <Verdict tone="ok">
        {lecture === "image"
          ? "Pour lire une image, on part de x sur l'axe horizontal, on monte jusqu'à la courbe, puis on lit sur l'axe vertical. Un nombre n'a jamais qu'une seule image."
          : lecture === "antecedents"
            ? `On part cette fois de l'ordonnée et on cherche tous les points de la courbe à cette hauteur. Ici il y en a ${uniques.length} : un nombre peut avoir plusieurs antécédents, c'est la différence avec l'image.`
            : "Sur fond vert la fonction croît, sur fond rouge elle décroît. Les deux points violets sont les extremums locaux : la courbe y change de sens, et la tangente y est horizontale."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch05 — Parité et périodicité                                        */
/* ------------------------------------------------------------------ */

export function PariteePeriodicite() {
  const [choix, setChoix] = useState<string>("paire");
  const [a, setA] = useState(1.5);

  const FONCTIONS = [
    { value: "paire", label: "x² − a", f: (x: number) => x * x - a, nature: "paire" },
    { value: "impaire", label: "x³ − a x", f: (x: number) => x * x * x - a * x, nature: "impaire" },
    {
      value: "periodique",
      label: "a sin x",
      f: (x: number) => a * Math.sin(x),
      nature: "périodique",
    },
    {
      value: "aucune",
      label: "x² + a x",
      f: (x: number) => x * x + a * x,
      nature: "ni paire ni impaire",
    },
  ] as const;

  const choisie = FONCTIONS.find((o) => o.value === choix) ?? FONCTIONS[0];
  const f = choisie.f;

  // tests numeriques
  let paire = true;
  let impaire = true;
  for (let x = 0.3; x <= 3; x += 0.3) {
    if (Math.abs(f(-x) - f(x)) > 1e-6) paire = false;
    if (Math.abs(f(-x) + f(x)) > 1e-6) impaire = false;
  }
  let periode = 0;
  if (choix === "periodique") periode = 2 * Math.PI;

  const W = 420;
  const H = 240;
  const s = makeScales(W, H, -6, 6, -6, 6, 28);

  return (
    <div className="space-y-3">
      <Choice
        label="Fonction"
        value={choix}
        options={FONCTIONS.map((o) => ({ value: o.value as string, label: o.label }))}
        onChange={setChoix}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={2} />
        {paire ? (
          <line
            x1={s.sx(0)}
            y1={s.sy(-6)}
            x2={s.sx(0)}
            y2={s.sy(6)}
            stroke={PALETTE.green}
            strokeWidth={3}
            opacity={0.5}
          />
        ) : null}
        {impaire ? (
          <circle
            cx={s.sx(0)}
            cy={s.sy(0)}
            r={9}
            fill="none"
            stroke={PALETTE.green}
            strokeWidth={3}
          />
        ) : null}
        {periode > 0
          ? [-periode, periode].map((p, i) => (
              <line
                key={i}
                x1={s.sx(p)}
                y1={s.sy(-6)}
                x2={s.sx(p)}
                y2={s.sy(6)}
                stroke={PALETTE.purple}
                strokeWidth={1.6}
                strokeDasharray="5 4"
              />
            ))
          : null}
        <path d={curvePath(f, s)} fill="none" stroke={PALETTE.blue} strokeWidth={2.8} />
        {[1, 2, 3]
          .filter((x) => Math.abs(f(x)) <= 6 && Math.abs(f(-x)) <= 6)
          .map((x) => (
            <g key={x}>
              <circle cx={s.sx(x)} cy={s.sy(f(x))} r={4.5} fill={PALETTE.orange} />
              <circle cx={s.sx(-x)} cy={s.sy(f(-x))} r={4.5} fill={PALETTE.orange} />
            </g>
          ))}
      </Board>

      <Ctrl
        label="Paramètre a"
        value={a}
        min={0.5}
        max={4}
        step={0.5}
        onChange={setA}
        display={fmt(a, 1)}
      />

      <div className="grid grid-cols-3 gap-2">
        <Stat
          label="f(−x) = f(x) ?"
          value={paire ? "oui" : "non"}
          color={paire ? PALETTE.green : PALETTE.slate}
        />
        <Stat
          label="f(−x) = −f(x) ?"
          value={impaire ? "oui" : "non"}
          color={impaire ? PALETTE.green : PALETTE.slate}
        />
        <Stat
          label="Nature"
          value={choisie.nature}
          color={paire || impaire || periode > 0 ? PALETTE.green : PALETTE.red}
        />
      </div>

      <Verdict tone={paire || impaire || periode > 0 ? "ok" : "warn"}>
        {paire
          ? "Les points orange sont symétriques par rapport à l'axe des ordonnées, marqué en vert : la fonction est paire. On peut donc l'étudier seulement sur les x positifs, puis compléter par symétrie."
          : impaire
            ? "Les points orange sont symétriques par rapport à l'origine, marquée en vert : la fonction est impaire. Là aussi, une moitié d'étude suffit."
            : periode > 0
              ? "La courbe se répète à l'identique tous les 2π, marqués par les traits violets. Il suffit de l'étudier sur une période, puis de recopier."
              : "Aucune symétrie : les points orange ne se correspondent ni par l'axe des ordonnées, ni par l'origine. Il faudra étudier la fonction sur tout son domaine."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch07 — La fonction dérivée                                          */
/* ------------------------------------------------------------------ */

export function FonctionDerivee() {
  const [x, setX] = useState(-1);
  const [choix, setChoix] = useState<string>("cube");

  const FAMILLES = [
    {
      value: "cube",
      label: "x³/3 − x",
      f: (t: number) => (t * t * t) / 3 - t,
      d: (t: number) => t * t - 1,
      ecrit: "f(x) = x³/3 − x,  donc  f ′(x) = x² − 1",
    },
    {
      value: "carre",
      label: "x² − 2x",
      f: (t: number) => t * t - 2 * t,
      d: (t: number) => 2 * t - 2,
      ecrit: "f(x) = x² − 2x,  donc  f ′(x) = 2x − 2",
    },
    {
      value: "inverse",
      label: "1/x",
      f: (t: number) => (Math.abs(t) < 0.12 ? Number.NaN : 1 / t),
      d: (t: number) => (Math.abs(t) < 0.12 ? Number.NaN : -1 / (t * t)),
      ecrit: "f(x) = 1/x,  donc  f ′(x) = −1/x²",
    },
    {
      value: "racine",
      label: "√x",
      f: (t: number) => (t <= 0.02 ? Number.NaN : Math.sqrt(t)),
      d: (t: number) => (t <= 0.02 ? Number.NaN : 1 / (2 * Math.sqrt(t))),
      ecrit: "f(x) = √x,  donc  f ′(x) = 1 / (2√x)",
    },
  ] as const;

  const fam = FAMILLES.find((o) => o.value === choix) ?? FAMILLES[0];
  const pente = fam.d(x);
  const y0 = fam.f(x);
  const tangente = (t: number) => y0 + pente * (t - x);

  const W = 420;
  const H = 260;
  const s = makeScales(W, H, -4, 4, -4, 4, 28);

  return (
    <div className="space-y-3">
      <Choice
        label="Fonction"
        value={choix}
        options={FAMILLES.map((o) => ({ value: o.value as string, label: o.label }))}
        onChange={setChoix}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={1} />
        <path d={curvePath(fam.f, s)} fill="none" stroke={PALETTE.blue} strokeWidth={2.8} />
        <path
          d={curvePath(fam.d, s)}
          fill="none"
          stroke={PALETTE.purple}
          strokeWidth={2.2}
          strokeDasharray="6 5"
        />
        {Number.isFinite(pente) && Number.isFinite(y0) ? (
          <>
            <path
              d={curvePath(tangente, s)}
              fill="none"
              stroke={PALETTE.orange}
              strokeWidth={1.8}
            />
            <circle cx={s.sx(x)} cy={s.sy(clamp(y0, -4, 4))} r={6} fill={PALETTE.blue} />
            <circle cx={s.sx(x)} cy={s.sy(clamp(pente, -4, 4))} r={6} fill={PALETTE.purple} />
            <line
              x1={s.sx(x)}
              y1={s.sy(clamp(y0, -4, 4))}
              x2={s.sx(x)}
              y2={s.sy(clamp(pente, -4, 4))}
              stroke={PALETTE.gridStrong}
              strokeWidth={1.2}
              strokeDasharray="3 4"
            />
          </>
        ) : null}
        <circle cx={s.sx(-4) + 14} cy={s.sy(4) + 10} r={5} fill={PALETTE.blue} />
        <text x={s.sx(-4) + 24} y={s.sy(4) + 14} fontSize={10} fill={PALETTE.slate}>
          la fonction f
        </text>
        <circle cx={s.sx(-4) + 14} cy={s.sy(4) + 26} r={5} fill={PALETTE.purple} />
        <text x={s.sx(-4) + 24} y={s.sy(4) + 30} fontSize={10} fill={PALETTE.slate}>
          sa dérivée f ′
        </text>
      </Board>

      <Ctrl
        label="Abscisse x"
        value={x}
        min={-4}
        max={4}
        step={0.1}
        onChange={setX}
        display={fmt(x, 1)}
        color={PALETTE.orange}
      />

      <div className="rounded-xl border border-border bg-white p-3 text-center">
        <p className="font-mono text-sm font-semibold text-foreground">{fam.ecrit}</p>
      </div>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="f(x)" value={fmt(y0, 3)} color={PALETTE.blue} />
        <Stat label="f ′(x), la pente" value={fmt(pente, 3)} color={PALETTE.purple} />
        <Stat
          label="La tangente"
          value={
            !Number.isFinite(pente)
              ? "non définie"
              : pente > 0
                ? "monte"
                : pente < 0
                  ? "descend"
                  : "horizontale"
          }
          color={PALETTE.orange}
        />
      </div>

      <Verdict tone="ok">
        Le point violet, à la même abscisse, donne la <strong>pente</strong> de la tangente orange.
        Quand la courbe bleue monte, le point violet est au-dessus de l&apos;axe ; quand elle
        descend, il est en dessous. C&apos;est tout le lien entre la dérivée et le sens de
        variation.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch07 — Dérivée et sens de variation                                 */
/* ------------------------------------------------------------------ */

export function VariationsDerivee() {
  const [b, setB] = useState(-3);
  const [c, setC] = useState(0);

  // f(x) = x^3/3 + b x^2 / 2 ... on prend plutot f'(x) = x^2 + b x + c
  const d = (t: number) => t * t + b * t + c;
  const f = (t: number) => (t * t * t) / 3 + (b * t * t) / 2 + c * t;

  const delta = b * b - 4 * c;
  const racines: number[] = [];
  if (delta > 1e-9) {
    racines.push((-b - Math.sqrt(delta)) / 2, (-b + Math.sqrt(delta)) / 2);
  } else if (Math.abs(delta) <= 1e-9) {
    racines.push(-b / 2);
  }

  const W = 420;
  const H = 280;
  const s = makeScales(W, H, -2, 6, -8, 8, 28);

  const zones: Array<{ x0: number; x1: number; croit: boolean }> = [];
  const bornes = [-2, ...racines.filter((r) => r > -2 && r < 6), 6];
  for (let i = 0; i < bornes.length - 1; i++) {
    const x0 = bornes[i] ?? -2;
    const x1 = bornes[i + 1] ?? 6;
    zones.push({ x0, x1, croit: d((x0 + x1) / 2) > 0 });
  }

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {zones.map((z, i) => (
          <rect
            key={i}
            x={s.sx(z.x0)}
            y={s.sy(8)}
            width={s.sx(z.x1) - s.sx(z.x0)}
            height={s.sy(-8) - s.sy(8)}
            fill={z.croit ? PALETTE.green : PALETTE.red}
            opacity={0.08}
          />
        ))}
        <Grid s={s} step={2} />
        <path d={curvePath(f, s)} fill="none" stroke={PALETTE.blue} strokeWidth={2.8} />
        <path
          d={curvePath(d, s)}
          fill="none"
          stroke={PALETTE.purple}
          strokeWidth={2.2}
          strokeDasharray="6 5"
        />
        {racines.map((r, i) => (
          <g key={i}>
            <line
              x1={s.sx(r)}
              y1={s.sy(-8)}
              x2={s.sx(r)}
              y2={s.sy(8)}
              stroke={PALETTE.gridStrong}
              strokeWidth={1.4}
            />
            <circle cx={s.sx(r)} cy={s.sy(clamp(f(r), -8, 8))} r={6} fill={PALETTE.orange} />
          </g>
        ))}
        <rect
          x={s.sx(-2) + 4}
          y={s.sy(8) + 2}
          width={54}
          height={36}
          rx={5}
          fill="#ffffff"
          opacity={0.92}
        />
        <circle cx={s.sx(-2) + 14} cy={s.sy(8) + 10} r={5} fill={PALETTE.blue} />
        <text x={s.sx(-2) + 24} y={s.sy(8) + 14} fontSize={10} fill={PALETTE.slate}>
          f
        </text>
        <circle cx={s.sx(-2) + 14} cy={s.sy(8) + 26} r={5} fill={PALETTE.purple} />
        <text x={s.sx(-2) + 24} y={s.sy(8) + 30} fontSize={10} fill={PALETTE.slate}>
          f ′
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="f ′ : coefficient de x"
          value={b}
          min={-6}
          max={2}
          step={0.5}
          onChange={setB}
          display={fmt(b, 1)}
          color={PALETTE.purple}
        />
        <Ctrl
          label="f ′ : constante"
          value={c}
          min={-4}
          max={6}
          step={0.5}
          onChange={setC}
          display={fmt(c, 1)}
          color={PALETTE.purple}
        />
      </Panel>

      <div className="rounded-xl border border-border bg-white p-3 text-center">
        <p className="font-mono text-sm font-semibold text-foreground">
          f ′(x) = x² {b >= 0 ? "+" : "−"} {fmt(Math.abs(b), 1)}x {c >= 0 ? "+" : "−"}{" "}
          {fmt(Math.abs(c), 1)}
        </p>
      </div>

      <div className="grid grid-cols-3 gap-2">
        <Stat
          label="Δ de f ′"
          value={fmt(delta, 2)}
          color={delta > 0 ? PALETTE.green : PALETTE.red}
        />
        <Stat
          label="f ′ s'annule en"
          value={racines.length ? racines.map((r) => fmt(r, 2)).join(" · ") : "jamais"}
          color={PALETTE.orange}
        />
        <Stat label="Nombre d'extremums" value={String(delta > 1e-9 ? 2 : 0)} />
      </div>

      <Verdict tone={delta > 1e-9 ? "ok" : "warn"}>
        {delta > 1e-9
          ? "Sur fond vert f ′ est positive et f croît ; sur fond rouge f ′ est négative et f décroît. Les points orange, là où f ′ s'annule en changeant de signe, sont les extremums de f."
          : "f ′ garde un signe constant : f est monotone sur tout son domaine, sans aucun extremum. Baisse la constante pour faire apparaître deux racines à la dérivée."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch08 — L'asymptote oblique                                          */
/* ------------------------------------------------------------------ */

export function AsymptoteOblique() {
  const [a, setA] = useState(1);
  const [b, setB] = useState(1);
  const [k, setK] = useState(3);
  const [x, setX] = useState(1.6);

  // f(x) = a x + b + k / x
  const f = (t: number) => (Math.abs(t) < 0.08 ? Number.NaN : a * t + b + k / t);
  const asy = (t: number) => a * t + b;
  const ecart = Math.abs(x) < 0.08 ? Number.NaN : k / x;

  const W = 430;
  const H = 270;
  const s = makeScales(W, H, -8, 8, -10, 10, 28);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={2} />
        <path
          d={curvePath(asy, s)}
          fill="none"
          stroke={PALETTE.orange}
          strokeWidth={2}
          strokeDasharray="7 5"
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(-10)}
          x2={s.sx(0)}
          y2={s.sy(10)}
          stroke={PALETTE.red}
          strokeWidth={1.6}
          strokeDasharray="5 4"
        />
        <path d={curvePath(f, s)} fill="none" stroke={PALETTE.blue} strokeWidth={2.8} />
        {Number.isFinite(ecart) ? (
          <>
            <line
              x1={s.sx(x)}
              y1={s.sy(clamp(asy(x), -10, 10))}
              x2={s.sx(x)}
              y2={s.sy(clamp(f(x), -10, 10))}
              stroke={PALETTE.green}
              strokeWidth={3}
            />
            <circle cx={s.sx(x)} cy={s.sy(clamp(f(x), -10, 10))} r={5} fill={PALETTE.blue} />
            <circle cx={s.sx(x)} cy={s.sy(clamp(asy(x), -10, 10))} r={5} fill={PALETTE.orange} />
          </>
        ) : null}
      </Board>

      <Panel>
        <Ctrl
          label="Pente a de l'asymptote"
          value={a}
          min={-2}
          max={2}
          step={0.5}
          onChange={setA}
          display={fmt(a, 1)}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Ordonnée b à l'origine"
          value={b}
          min={-4}
          max={4}
          step={0.5}
          onChange={setB}
          display={fmt(b, 1)}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Terme k/x qui s'efface"
          value={k}
          min={-6}
          max={6}
          step={0.5}
          onChange={setK}
          display={fmt(k, 1)}
          color={PALETTE.green}
        />
        <Ctrl
          label="Abscisse d'observation"
          value={x}
          min={-8}
          max={8}
          step={0.2}
          onChange={setX}
          display={fmt(x, 1)}
        />
      </Panel>

      <div className="rounded-xl border border-border bg-white p-3 text-center">
        <p className="font-mono text-sm font-semibold text-foreground">
          f(x) = {fmt(a, 1)}x {b >= 0 ? "+" : "−"} {fmt(Math.abs(b), 1)} {k >= 0 ? "+" : "−"}{" "}
          {fmt(Math.abs(k), 1)}/x
        </p>
      </div>

      <div className="grid grid-cols-3 gap-2">
        <Stat
          label="Asymptote oblique"
          value={`y = ${fmt(a, 1)}x ${b >= 0 ? "+" : "−"} ${fmt(Math.abs(b), 1)}`}
          color={PALETTE.orange}
        />
        <Stat label="Écart f(x) − y" value={fmt(ecart, 4)} color={PALETTE.green} />
        <Stat label="Asymptote verticale" value="x = 0" color={PALETTE.red} />
      </div>

      <Verdict tone="ok">
        Le trait vert mesure l&apos;écart entre la courbe et la droite. Éloigne le point
        d&apos;observation : l&apos;écart vaut k/x, et il tend vers zéro. C&apos;est exactement la
        définition d&apos;une asymptote oblique, et c&apos;est ce calcul de limite qu&apos;on rédige
        au devoir.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch09 — Les suites arithmétiques                                     */
/* ------------------------------------------------------------------ */

export function SuiteArithmetique() {
  const [u0, setU0] = useState(2);
  const [r, setR] = useState(1.5);
  const [n, setN] = useState(6);

  const u = (i: number) => u0 + i * r;
  const somme = ((n + 1) * (u(0) + u(n))) / 2;

  const W = 430;
  const H = 240;
  const marge = 40;
  const vals: number[] = [];
  for (let i = 0; i <= 12; i++) vals.push(u(i));
  const vMax = Math.max(...vals, 1);
  const vMin = Math.min(...vals, 0);
  const sx = (i: number) => marge + (i / 12) * (W - 2 * marge);
  const sy = (v: number) => H - 42 - ((v - vMin) / Math.max(vMax - vMin, 1)) * (H - 76);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={marge}
          y1={sy(vMin)}
          x2={W - marge}
          y2={sy(vMin)}
          stroke={PALETTE.axis}
          strokeWidth={1.3}
        />
        {[0, 2, 4, 6, 8, 10, 12].map((i) => (
          <text
            key={i}
            x={sx(i)}
            y={sy(vMin) + 18}
            textAnchor="middle"
            fontSize={10}
            fill={PALETTE.slate}
          >
            {i}
          </text>
        ))}
        {vals.map((v, i) =>
          i < 12 ? (
            <line
              key={`l${i}`}
              x1={sx(i)}
              y1={sy(v)}
              x2={sx(i + 1)}
              y2={sy(vals[i + 1] ?? v)}
              stroke={PALETTE.gridStrong}
              strokeWidth={1.2}
            />
          ) : null,
        )}
        {vals.map((v, i) => (
          <g key={i}>
            <circle cx={sx(i)} cy={sy(v)} r={5} fill={i <= n ? PALETTE.blue : PALETTE.gridStrong} />
            {i <= n && i > 0 ? (
              <line
                x1={sx(i)}
                y1={sy(vals[i - 1] ?? v)}
                x2={sx(i)}
                y2={sy(v)}
                stroke={PALETTE.green}
                strokeWidth={2.4}
              />
            ) : null}
          </g>
        ))}
        <text
          x={sx(0)}
          y={sy(u(0)) - 12}
          textAnchor="middle"
          fontSize={10}
          fontWeight={700}
          fill={PALETTE.blue}
          stroke="#ffffff"
          strokeWidth={3}
          paintOrder="stroke"
        >
          u₀ = {fmt(u(0), 2)}
        </text>
        <text
          x={sx(n)}
          y={sy(u(n)) - 12}
          textAnchor="middle"
          fontSize={10}
          fontWeight={700}
          fill={PALETTE.blue}
          stroke="#ffffff"
          strokeWidth={3}
          paintOrder="stroke"
        >
          u{indice(n)} = {fmt(u(n), 2)}
        </text>
        <text x={W / 2} y={20} textAnchor="middle" fontSize={11} fill={PALETTE.green}>
          chaque saut vert vaut exactement la raison r = {fmt(r, 2)}
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Premier terme u₀"
          value={u0}
          min={-5}
          max={10}
          step={0.5}
          onChange={setU0}
          display={fmt(u0, 1)}
        />
        <Ctrl
          label="Raison r"
          value={r}
          min={-3}
          max={3}
          step={0.25}
          onChange={setR}
          display={fmt(r, 2)}
          color={PALETTE.green}
        />
        <Ctrl
          label="Rang n"
          value={n}
          min={0}
          max={12}
          step={1}
          onChange={(v) => setN(Math.round(v))}
          display={String(n)}
          color={PALETTE.blue}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="uₙ = u₀ + n r" value={fmt(u(n), 3)} color={PALETTE.blue} />
        <Stat label="Somme u₀ + … + uₙ" value={fmt(somme, 3)} color={PALETTE.purple} />
        <Stat
          label="Sens"
          value={r > 0 ? "croissante" : r < 0 ? "décroissante" : "constante"}
          color={r >= 0 ? PALETTE.green : PALETTE.red}
        />
      </div>

      <Verdict tone="ok">
        Les points sont alignés : une suite arithmétique se comporte comme une fonction affine du
        rang. La somme se calcule avec la formule du cours, nombre de termes multiplié par la
        demi-somme des extrêmes : {n + 1} × ({fmt(u(0), 2)} + {fmt(u(n), 2)}) / 2 = {fmt(somme, 2)}.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch09 — Les suites géométriques                                      */
/* ------------------------------------------------------------------ */

export function SuiteGeometrique() {
  const [u0, setU0] = useState(1);
  const [q, setQ] = useState(1.5);
  const [n, setN] = useState(6);

  const u = (i: number) => u0 * Math.pow(q, i);
  const somme = Math.abs(q - 1) < 1e-9 ? u0 * (n + 1) : (u0 * (1 - Math.pow(q, n + 1))) / (1 - q);
  const limite =
    Math.abs(q) < 1 ? "0" : Math.abs(q - 1) < 1e-9 ? fmt(u0, 2) : q > 1 ? "+∞" : "pas de limite";

  const W = 430;
  const H = 240;
  const marge = 42;
  const vals: number[] = [];
  for (let i = 0; i <= 10; i++) vals.push(u(i));
  const vMax = Math.max(...vals, 0);
  const vMin = Math.min(...vals, 0);
  const etendue = Math.max(vMax - vMin, 1);
  const sx = (i: number) => marge + (i / 10) * (W - 2 * marge);
  const sy = (v: number) => H - 42 - ((clamp(v, vMin, vMax) - vMin) / etendue) * (H - 80);
  const zero = sy(0);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={marge}
          y1={zero}
          x2={W - marge}
          y2={zero}
          stroke={PALETTE.axis}
          strokeWidth={1.3}
        />
        <text x={marge - 8} y={sy(vMax) + 4} textAnchor="end" fontSize={10} fill={PALETTE.slate}>
          {fmt(vMax, 1)}
        </text>
        <text x={marge - 8} y={zero + 4} textAnchor="end" fontSize={10} fill={PALETTE.slate}>
          0
        </text>
        {[0, 2, 4, 6, 8, 10].map((i) => (
          <text
            key={i}
            x={sx(i)}
            y={sy(vMin) + 18}
            textAnchor="middle"
            fontSize={10}
            fill={PALETTE.slate}
          >
            {i}
          </text>
        ))}
        {vals.map((v, i) => (
          <g key={i}>
            <line
              x1={sx(i)}
              y1={zero}
              x2={sx(i)}
              y2={sy(v)}
              stroke={i <= n ? PALETTE.purple : PALETTE.gridStrong}
              strokeWidth={2.4}
            />
            <circle
              cx={sx(i)}
              cy={sy(v)}
              r={5}
              fill={i <= n ? PALETTE.purple : PALETTE.gridStrong}
            />
          </g>
        ))}
        <text x={W / 2} y={20} textAnchor="middle" fontSize={11} fill={PALETTE.purple}>
          on multiplie par q = {fmt(q, 2)} à chaque rang
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Premier terme u₀"
          value={u0}
          min={-4}
          max={6}
          step={0.5}
          onChange={setU0}
          display={fmt(u0, 1)}
        />
        <Ctrl
          label="Raison q"
          value={q}
          min={-2}
          max={2.5}
          step={0.1}
          onChange={setQ}
          display={fmt(q, 2)}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Rang n"
          value={n}
          min={0}
          max={10}
          step={1}
          onChange={(v) => setN(Math.round(v))}
          display={String(n)}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="uₙ = u₀ qⁿ" value={fmt(u(n), 4)} color={PALETTE.purple} />
        <Stat label="Somme u₀ + … + uₙ" value={fmt(somme, 4)} color={PALETTE.blue} />
        <Stat
          label="Limite quand n → +∞"
          value={limite}
          color={Math.abs(q) < 1 ? PALETTE.green : PALETTE.orange}
        />
      </div>

      <Verdict tone={Math.abs(q) < 1 ? "ok" : "warn"}>
        {Math.abs(q) < 1
          ? "Avec une raison comprise strictement entre −1 et 1, les termes s'écrasent vers zéro et la somme se rapproche d'une valeur finie. C'est la suite géométrique convergente du cours."
          : q < 0
            ? "Une raison négative fait alterner le signe des termes : la suite saute d'un côté puis de l'autre de l'axe. Elle n'a pas de limite."
            : "Avec une raison supérieure à 1, les termes explosent. Compare avec la suite arithmétique de la leçon précédente : la croissance géométrique dépasse toujours la croissance affine, et vite."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch10 — Les courbes cumulatives                                      */
/* ------------------------------------------------------------------ */

export function CourbesCumulatives() {
  const [e1, setE1] = useState(6);
  const [e2, setE2] = useState(14);
  const [e3, setE3] = useState(20);
  const [e4, setE4] = useState(10);
  const [sens, setSens] = useState<"croissante" | "decroissante">("croissante");

  const effectifs = [e1, e2, e3, e4];
  const bornes = [0, 5, 10, 15, 20];
  const total = effectifs.reduce((a, b) => a + b, 0);

  const cumulCroissant = [0];
  for (const e of effectifs)
    cumulCroissant.push((cumulCroissant[cumulCroissant.length - 1] ?? 0) + e);
  const cumulDecroissant = cumulCroissant.map((v) => total - v);
  const courbe = sens === "croissante" ? cumulCroissant : cumulDecroissant;

  // mediane : effectif cumule croissant egal a total / 2, par interpolation
  const cible = total / 2;
  let mediane = 0;
  for (let i = 0; i < 4; i++) {
    const a = cumulCroissant[i] ?? 0;
    const b = cumulCroissant[i + 1] ?? 0;
    if (a <= cible && cible <= b && b > a) {
      const x0 = bornes[i] ?? 0;
      const x1 = bornes[i + 1] ?? 0;
      mediane = x0 + ((cible - a) / (b - a)) * (x1 - x0);
      break;
    }
  }

  const W = 430;
  const H = 250;
  const marge = 44;
  const sx = (v: number) => marge + (v / 20) * (W - 2 * marge);
  const sy = (v: number) => H - 42 - (v / Math.max(total, 1)) * (H - 74);

  return (
    <div className="space-y-3">
      <Choice
        value={sens}
        options={[
          { value: "croissante", label: "Cumuls croissants" },
          { value: "decroissante", label: "Cumuls décroissants" },
        ]}
        onChange={setSens}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={marge}
          y1={sy(0)}
          x2={W - marge}
          y2={sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.3}
        />
        <line
          x1={marge}
          y1={sy(0)}
          x2={marge}
          y2={sy(total)}
          stroke={PALETTE.axis}
          strokeWidth={1.3}
        />
        {bornes.map((b) => (
          <text
            key={b}
            x={sx(b)}
            y={sy(0) + 18}
            textAnchor="middle"
            fontSize={10}
            fill={PALETTE.slate}
          >
            {b}
          </text>
        ))}
        <text x={marge - 8} y={sy(total) + 4} textAnchor="end" fontSize={10} fill={PALETTE.slate}>
          {total}
        </text>
        <polyline
          points={bornes.map((b, i) => `${sx(b)},${sy(courbe[i] ?? 0)}`).join(" ")}
          fill="none"
          stroke={sens === "croissante" ? PALETTE.blue : PALETTE.purple}
          strokeWidth={2.8}
        />
        {bornes.map((b, i) => (
          <circle
            key={i}
            cx={sx(b)}
            cy={sy(courbe[i] ?? 0)}
            r={4.5}
            fill={sens === "croissante" ? PALETTE.blue : PALETTE.purple}
          />
        ))}
        <line
          x1={marge}
          y1={sy(cible)}
          x2={sx(mediane)}
          y2={sy(cible)}
          stroke={PALETTE.green}
          strokeWidth={1.8}
          strokeDasharray="5 4"
        />
        <text x={marge - 8} y={sy(cible) + 4} textAnchor="end" fontSize={10} fill={PALETTE.green}>
          {fmt(cible, 1)}
        </text>
        <line
          x1={sx(mediane)}
          y1={sy(cible)}
          x2={sx(mediane)}
          y2={sy(0)}
          stroke={PALETTE.green}
          strokeWidth={1.8}
          strokeDasharray="5 4"
        />
        <text
          x={sx(mediane)}
          y={sy(0) + 32}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.green}
        >
          médiane ≈ {fmt(mediane, 2)}
        </text>
      </Board>

      <Panel>
        {effectifs.map((e, i) => (
          <Ctrl
            key={i}
            label={`[${bornes[i]} ; ${bornes[i + 1]}[`}
            value={e}
            min={0}
            max={30}
            step={1}
            onChange={(v) => [setE1, setE2, setE3, setE4][i]?.(Math.round(v))}
            display={String(e)}
          />
        ))}
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Effectif total" value={String(total)} />
        <Stat label="Moitié de l'effectif" value={fmt(cible, 1)} color={PALETTE.green} />
        <Stat label="Médiane lue" value={fmt(mediane, 3)} color={PALETTE.green} />
      </div>

      <Verdict tone="ok">
        La médiane se lit à l&apos;intersection : on part de la moitié de l&apos;effectif sur
        l&apos;axe vertical, on rejoint la courbe, puis on redescend. Les deux courbes, croissante
        et décroissante, se croisent exactement à cette abscisse : tu peux le vérifier en changeant
        de bouton.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch11 — Le triangle de Pascal et le binôme                           */
/* ------------------------------------------------------------------ */

export function TrianglePascal() {
  const [n, setN] = useState(5);
  const [k, setK] = useState(2);

  const lignes: number[][] = [];
  for (let i = 0; i <= 8; i++) {
    const precedente = lignes[i - 1];
    if (!precedente) {
      lignes.push([1]);
      continue;
    }
    const courante: number[] = [1];
    for (let j = 1; j < i; j++) {
      courante.push((precedente[j - 1] ?? 0) + (precedente[j] ?? 0));
    }
    courante.push(1);
    lignes.push(courante);
  }

  const kv = Math.min(k, n);
  const ligne = lignes[n] ?? [1];
  const valeur = ligne[kv] ?? 1;

  function terme(j: number): string {
    const c = ligne[j] ?? 1;
    const pa = n - j;
    const pb = j;
    const ca = pa === 0 ? "" : pa === 1 ? "a" : `a^${pa}`;
    const cb = pb === 0 ? "" : pb === 1 ? "b" : `b^${pb}`;
    const co = c === 1 && (ca || cb) ? "" : String(c);
    return `${co}${ca}${cb}`;
  }

  return (
    <div className="space-y-3">
      <div className="space-y-1.5 overflow-x-auto rounded-xl border border-border bg-white p-3">
        {lignes.map((l, i) => (
          <div key={i} className="flex justify-center gap-1.5">
            {l.map((v, j) => {
              const choisi = i === n && j === kv;
              const parent = i === n - 1 && (j === kv - 1 || j === kv);
              return (
                <span
                  key={j}
                  className="inline-flex h-7 min-w-7 items-center justify-center rounded-md px-1.5 font-mono text-xs font-semibold"
                  style={{
                    backgroundColor: choisi ? PALETTE.green : parent ? "#dcfce7" : "#f1f5f9",
                    color: choisi ? "#ffffff" : PALETTE.ink,
                  }}
                >
                  {v}
                </span>
              );
            })}
          </div>
        ))}
      </div>

      <Panel>
        <Ctrl
          label="Ligne n"
          value={n}
          min={0}
          max={8}
          step={1}
          onChange={(v) => setN(Math.round(v))}
          display={String(n)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Rang k"
          value={k}
          min={0}
          max={8}
          step={1}
          onChange={(v) => setK(Math.round(v))}
          display={String(kv)}
          color={PALETTE.green}
        />
      </Panel>

      <div className="rounded-xl border border-border bg-white p-3 text-center">
        <p className="font-mono text-sm font-semibold text-foreground">
          (a + b)^{n} = {ligne.map((_, j) => terme(j)).join(" + ")}
        </p>
      </div>

      <div className="grid grid-cols-3 gap-2">
        <Stat label={`C(${n} ; ${kv})`} value={String(valeur)} color={PALETTE.green} />
        <Stat
          label="Les deux cases du dessus"
          value={
            n === 0 ? "aucune" : `${lignes[n - 1]?.[kv - 1] ?? 0} + ${lignes[n - 1]?.[kv] ?? 0}`
          }
        />
        <Stat label="Somme de la ligne" value={String(Math.pow(2, n))} color={PALETTE.purple} />
      </div>

      <Verdict tone="ok">
        Chaque case est la somme des deux cases juste au-dessus : c&apos;est la relation de Pascal.
        Les nombres d&apos;une ligne sont exactement les coefficients du développement de (a + b)ⁿ,
        et leur somme vaut 2ⁿ, c&apos;est-à-dire le nombre total de parties d&apos;un ensemble à n
        éléments.
      </Verdict>
    </div>
  );
}
