import { useRef, type ReactNode } from "react";

/** Briques communes aux simulations interactives : repère, poignées, curseurs, mesures. */

export const PALETTE = {
  axis: "#334155",
  grid: "#e2e8f0",
  gridStrong: "#cbd5e1",
  blue: "#2563eb",
  red: "#dc2626",
  green: "#16a34a",
  orange: "#ea580c",
  purple: "#7c3aed",
  slate: "#64748b",
  ink: "#0f172a",
};

/** Échelles affines entre coordonnées mathématiques et coordonnées SVG. */
export type Scales = {
  sx: (x: number) => number;
  sy: (y: number) => number;
  ux: (px: number) => number;
  uy: (py: number) => number;
  xMin: number;
  xMax: number;
  yMin: number;
  yMax: number;
  width: number;
  height: number;
};

export function makeScales(
  width: number,
  height: number,
  xMin: number,
  xMax: number,
  yMin: number,
  yMax: number,
  pad = 24,
): Scales {
  const kx = (width - 2 * pad) / (xMax - xMin);
  const ky = (height - 2 * pad) / (yMax - yMin);
  return {
    sx: (x) => pad + (x - xMin) * kx,
    sy: (y) => height - pad - (y - yMin) * ky,
    ux: (px) => xMin + (px - pad) / kx,
    uy: (py) => yMin + (height - pad - py) / ky,
    xMin,
    xMax,
    yMin,
    yMax,
    width,
    height,
  };
}

/** Cadre blanc + viewBox, prêt pour le tactile. */
export function Board({
  width,
  height,
  children,
}: {
  width: number;
  height: number;
  children: ReactNode;
}) {
  return (
    <div className="overflow-hidden rounded-xl border border-border bg-white">
      <svg
        viewBox={`0 0 ${width} ${height}`}
        className="w-full select-none"
        style={{ touchAction: "none" }}
        role="img"
        aria-label="Figure interactive"
      >
        {children}
      </svg>
    </div>
  );
}

/** Quadrillage + axes gradués. */
export function Grid({ s, step = 1 }: { s: Scales; step?: number }) {
  const xs: number[] = [];
  const ys: number[] = [];
  for (let x = Math.ceil(s.xMin / step) * step; x <= s.xMax + 1e-9; x += step) xs.push(x);
  for (let y = Math.ceil(s.yMin / step) * step; y <= s.yMax + 1e-9; y += step) ys.push(y);
  const showX = s.yMin <= 0 && s.yMax >= 0;
  const showY = s.xMin <= 0 && s.xMax >= 0;
  return (
    <g>
      {xs.map((x) => (
        <line
          key={`gx${x}`}
          x1={s.sx(x)}
          y1={s.sy(s.yMin)}
          x2={s.sx(x)}
          y2={s.sy(s.yMax)}
          stroke={Math.abs(x) < 1e-9 ? PALETTE.gridStrong : PALETTE.grid}
          strokeWidth={1}
        />
      ))}
      {ys.map((y) => (
        <line
          key={`gy${y}`}
          x1={s.sx(s.xMin)}
          y1={s.sy(y)}
          x2={s.sx(s.xMax)}
          y2={s.sy(y)}
          stroke={Math.abs(y) < 1e-9 ? PALETTE.gridStrong : PALETTE.grid}
          strokeWidth={1}
        />
      ))}
      {showX ? (
        <line
          x1={s.sx(s.xMin)}
          y1={s.sy(0)}
          x2={s.sx(s.xMax)}
          y2={s.sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.6}
        />
      ) : null}
      {showY ? (
        <line
          x1={s.sx(0)}
          y1={s.sy(s.yMin)}
          x2={s.sx(0)}
          y2={s.sy(s.yMax)}
          stroke={PALETTE.axis}
          strokeWidth={1.6}
        />
      ) : null}
      {showX
        ? xs
            .filter((x) => Math.abs(x) > 1e-9)
            .map((x) => (
              <text
                key={`tx${x}`}
                x={s.sx(x)}
                y={s.sy(0) + 14}
                textAnchor="middle"
                fontSize={10}
                fill={PALETTE.slate}
              >
                {fmt(x, 2)}
              </text>
            ))
        : null}
      {showY
        ? ys
            .filter((y) => Math.abs(y) > 1e-9)
            .map((y) => (
              <text
                key={`ty${y}`}
                x={s.sx(0) - 6}
                y={s.sy(y) + 3}
                textAnchor="end"
                fontSize={10}
                fill={PALETTE.slate}
              >
                {fmt(y, 2)}
              </text>
            ))
        : null}
    </g>
  );
}

/** Point que l'élève peut déplacer au doigt ou à la souris. */
export function Handle({
  x,
  y,
  onDrag,
  color = PALETTE.red,
  label,
  labelDx = 12,
  labelDy = -12,
}: {
  x: number;
  y: number;
  onDrag: (p: { x: number; y: number }) => void;
  color?: string;
  label?: string | undefined;
  labelDx?: number;
  labelDy?: number;
}) {
  const ref = useRef<SVGCircleElement | null>(null);

  function toUser(clientX: number, clientY: number): { x: number; y: number } | null {
    const svg = ref.current?.ownerSVGElement;
    if (!svg) return null;
    const ctm = svg.getScreenCTM();
    if (!ctm) return null;
    const p = svg.createSVGPoint();
    p.x = clientX;
    p.y = clientY;
    const u = p.matrixTransform(ctm.inverse());
    return { x: u.x, y: u.y };
  }

  return (
    <g>
      <circle
        ref={ref}
        cx={x}
        cy={y}
        r={20}
        fill="transparent"
        style={{ cursor: "grab", touchAction: "none" }}
        onPointerDown={(e) => {
          e.preventDefault();
          e.currentTarget.setPointerCapture(e.pointerId);
        }}
        onPointerMove={(e) => {
          if (!e.currentTarget.hasPointerCapture(e.pointerId)) return;
          const u = toUser(e.clientX, e.clientY);
          if (u) onDrag(u);
        }}
        onPointerUp={(e) => {
          if (e.currentTarget.hasPointerCapture(e.pointerId)) {
            e.currentTarget.releasePointerCapture(e.pointerId);
          }
        }}
      />
      <circle cx={x} cy={y} r={11} fill={color} opacity={0.18} pointerEvents="none" />
      <circle
        cx={x}
        cy={y}
        r={6.5}
        fill={color}
        stroke="#ffffff"
        strokeWidth={2}
        pointerEvents="none"
      />
      {label ? (
        <text
          x={x + labelDx}
          y={y + labelDy}
          fontSize={13}
          fontWeight={700}
          fill={color}
          pointerEvents="none"
        >
          {label}
        </text>
      ) : null}
    </g>
  );
}

/** Flèche (vecteur) entre deux points déjà en coordonnées SVG. */
export function Arrow({
  x1,
  y1,
  x2,
  y2,
  color,
  width = 2.5,
  dashed = false,
}: {
  x1: number;
  y1: number;
  x2: number;
  y2: number;
  color: string;
  width?: number;
  dashed?: boolean;
}) {
  const dx = x2 - x1;
  const dy = y2 - y1;
  const len = Math.hypot(dx, dy);
  if (len < 1) return null;
  const ux = dx / len;
  const uy = dy / len;
  const head = Math.min(11, len * 0.4);
  const bx = x2 - ux * head;
  const by = y2 - uy * head;
  const px = -uy * head * 0.42;
  const py = ux * head * 0.42;
  return (
    <g>
      <line
        x1={x1}
        y1={y1}
        x2={bx}
        y2={by}
        stroke={color}
        strokeWidth={width}
        strokeDasharray={dashed ? "6 5" : undefined}
      />
      <polygon points={`${x2},${y2} ${bx + px},${by + py} ${bx - px},${by - py}`} fill={color} />
    </g>
  );
}

/** Curseur de réglage (fonctionne au doigt). */
export function Ctrl({
  label,
  value,
  min,
  max,
  step,
  onChange,
  display,
  color = PALETTE.blue,
}: {
  label: string;
  value: number;
  min: number;
  max: number;
  step: number;
  onChange: (v: number) => void;
  display?: string | undefined;
  color?: string;
}) {
  return (
    <label className="block space-y-1">
      <span className="flex items-baseline justify-between gap-2 text-xs font-medium text-muted-foreground">
        <span>{label}</span>
        <span className="font-mono text-sm font-semibold" style={{ color }}>
          {display ?? fmt(value, 2)}
        </span>
      </span>
      <input
        type="range"
        min={min}
        max={max}
        step={step}
        value={value}
        onChange={(e) => onChange(Number(e.target.value))}
        className="h-2 w-full cursor-pointer appearance-none rounded-full bg-secondary"
        style={{ accentColor: color, touchAction: "none" }}
      />
    </label>
  );
}

/** Choix entre plusieurs options (boutons collés). */
export function Choice<T extends string>({
  label,
  value,
  options,
  onChange,
}: {
  label?: string | undefined;
  value: T;
  options: ReadonlyArray<{ value: T; label: string }>;
  onChange: (v: T) => void;
}) {
  return (
    <div className="space-y-1">
      {label ? <p className="text-xs font-medium text-muted-foreground">{label}</p> : null}
      <div className="flex flex-wrap gap-1.5">
        {options.map((o) => (
          <button
            key={o.value}
            type="button"
            onClick={() => onChange(o.value)}
            className={
              o.value === value
                ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            }
          >
            {o.label}
          </button>
        ))}
      </div>
    </div>
  );
}

/** Petite carte de mesure (nom + valeur). */
export function Stat({
  label,
  value,
  color = PALETTE.ink,
}: {
  label: string;
  value: string;
  color?: string;
}) {
  return (
    <div className="rounded-lg border border-border bg-secondary/30 px-2.5 py-1.5">
      <p className="text-[11px] leading-tight text-muted-foreground">{label}</p>
      <p className="font-mono text-sm font-semibold leading-tight" style={{ color }}>
        {value}
      </p>
    </div>
  );
}

/** Bandeau de conclusion coloré. */
export function Verdict({ tone, children }: { tone: "ok" | "warn" | "bad"; children: ReactNode }) {
  const cls =
    tone === "ok"
      ? "border-emerald-500/30 bg-emerald-500/10 text-emerald-700"
      : tone === "warn"
        ? "border-amber-500/30 bg-amber-500/10 text-amber-700"
        : "border-rose-500/30 bg-rose-500/10 text-rose-700";
  return <p className={`rounded-lg border px-3 py-2 text-xs font-medium ${cls}`}>{children}</p>;
}

export function Panel({ children }: { children: ReactNode }) {
  return <div className="grid gap-2 sm:grid-cols-2">{children}</div>;
}

/** Arrondi d'affichage : enlève les zéros inutiles. */
export function fmt(v: number, digits = 2): string {
  if (!Number.isFinite(v)) return "—";
  const r = Number(v.toFixed(digits));
  if (Object.is(r, -0)) return "0";
  return String(r).replace(".", ",").replace("-", "−");
}

/** Chemin SVG d'une courbe échantillonnée, coupé aux asymptotes et hors-cadre. */
export function curvePath(f: (x: number) => number, s: Scales, steps = 420, margin = 0): string {
  let d = "";
  let pen = false;
  for (let i = 0; i <= steps; i++) {
    const x = s.xMin + ((s.xMax - s.xMin) * i) / steps;
    const y = f(x);
    if (!Number.isFinite(y) || y < s.yMin - margin || y > s.yMax + margin) {
      pen = false;
      continue;
    }
    const px = s.sx(x);
    const py = s.sy(y);
    d += `${pen ? "L" : "M"}${px.toFixed(1)},${py.toFixed(1)} `;
    pen = true;
  }
  return d.trim();
}

/** Droite d'équation y = m x + p, limitée au cadre (elle ne déborde jamais). */
export function linePath(m: number, p: number, s: Scales): string {
  const pts: Array<[number, number]> = [];
  const eps = 1e-6;
  const push = (x: number, y: number) => {
    if (x >= s.xMin - eps && x <= s.xMax + eps && y >= s.yMin - eps && y <= s.yMax + eps) {
      pts.push([x, y]);
    }
  };
  push(s.xMin, m * s.xMin + p);
  push(s.xMax, m * s.xMax + p);
  if (Math.abs(m) > eps) {
    push((s.yMin - p) / m, s.yMin);
    push((s.yMax - p) / m, s.yMax);
  }
  if (pts.length < 2) return "";
  pts.sort((a, b) => a[0] - b[0]);
  const a = pts[0];
  const b = pts[pts.length - 1];
  if (!a || !b) return "";
  return `M${s.sx(a[0])},${s.sy(a[1])} L${s.sx(b[0])},${s.sy(b[1])}`;
}
