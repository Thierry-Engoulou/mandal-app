import { useEffect, useMemo, useState } from "react";
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
  linePath,
  makeScales,
} from "./controls";

/* ------------------------------------------------------------------ */
/* 1. Cercle trigonométrique                                           */
/* ------------------------------------------------------------------ */

type Remarquable = { deg: number; rad: string; cos: string; sin: string; tan: string };

const REMARQUABLES: Remarquable[] = [
  { deg: 0, rad: "0", cos: "1", sin: "0", tan: "0" },
  { deg: 30, rad: "π/6", cos: "√3/2", sin: "1/2", tan: "√3/3" },
  { deg: 45, rad: "π/4", cos: "√2/2", sin: "√2/2", tan: "1" },
  { deg: 60, rad: "π/3", cos: "1/2", sin: "√3/2", tan: "√3" },
  { deg: 90, rad: "π/2", cos: "0", sin: "1", tan: "non définie" },
  { deg: 120, rad: "2π/3", cos: "−1/2", sin: "√3/2", tan: "−√3" },
  { deg: 135, rad: "3π/4", cos: "−√2/2", sin: "√2/2", tan: "−1" },
  { deg: 150, rad: "5π/6", cos: "−√3/2", sin: "1/2", tan: "−√3/3" },
  { deg: 180, rad: "π", cos: "−1", sin: "0", tan: "0" },
  { deg: 210, rad: "7π/6", cos: "−√3/2", sin: "−1/2", tan: "√3/3" },
  { deg: 225, rad: "5π/4", cos: "−√2/2", sin: "−√2/2", tan: "1" },
  { deg: 240, rad: "4π/3", cos: "−1/2", sin: "−√3/2", tan: "√3" },
  { deg: 270, rad: "3π/2", cos: "0", sin: "−1", tan: "non définie" },
  { deg: 300, rad: "5π/3", cos: "1/2", sin: "−√3/2", tan: "−√3" },
  { deg: 315, rad: "7π/4", cos: "√2/2", sin: "−√2/2", tan: "−1" },
  { deg: 330, rad: "11π/6", cos: "√3/2", sin: "−1/2", tan: "−√3/3" },
];

export function CercleTrigo() {
  const [deg, setDeg] = useState(30);
  const [mode, setMode] = useState<"libre" | "snap">("snap");

  const W = 440;
  const H = 340;
  const cx = 180;
  const cy = 170;
  const R = 128;

  const d = mode === "snap" ? nearestRemarkable(deg) : deg;
  const th = (d * Math.PI) / 180;
  const co = Math.cos(th);
  const si = Math.sin(th);
  const ta = Math.abs(co) < 1e-9 ? Number.NaN : si / co;
  const exact = REMARQUABLES.find((r) => r.deg === ((Math.round(d) % 360) + 360) % 360);
  const showExact = mode === "snap" && exact;

  const mx = cx + R * co;
  const my = cy - R * si;
  const tanX = cx + R;
  const tanY = cy - R * ta;
  const tanVisible = Number.isFinite(ta) && Math.abs(ta) <= 1.9;

  const quadrant = ((Math.floor((((d % 360) + 360) % 360) / 90) + 0) % 4) + 1;
  const signe =
    quadrant === 1
      ? "cos > 0 et sin > 0"
      : quadrant === 2
        ? "cos < 0 et sin > 0"
        : quadrant === 3
          ? "cos < 0 et sin < 0"
          : "cos > 0 et sin < 0";

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {/* axes */}
        <line x1={20} y1={cy} x2={W - 14} y2={cy} stroke={PALETTE.axis} strokeWidth={1.5} />
        <line x1={cx} y1={18} x2={cx} y2={H - 16} stroke={PALETTE.axis} strokeWidth={1.5} />
        <text x={W - 16} y={cy + 16} fontSize={11} fill={PALETTE.slate} textAnchor="end">
          x
        </text>
        <text x={cx + 8} y={24} fontSize={11} fill={PALETTE.slate}>
          y
        </text>
        {/* cercle */}
        <circle cx={cx} cy={cy} r={R} fill="none" stroke={PALETTE.slate} strokeWidth={1.6} />
        {/* secteur d'angle */}
        <path
          d={`M${cx},${cy} L${cx + 42},${cy} A42,42 0 ${Math.abs(d) % 360 > 180 ? 1 : 0},0 ${
            cx + 42 * co
          },${cy - 42 * si} Z`}
          fill={PALETTE.orange}
          opacity={0.18}
        />
        {/* axe des tangentes */}
        <line
          x1={tanX}
          y1={cy - R - 12}
          x2={tanX}
          y2={cy + R + 12}
          stroke={PALETTE.green}
          strokeWidth={1.2}
          strokeDasharray="4 4"
        />
        <text x={tanX + 6} y={cy - R - 16} fontSize={11} fill={PALETTE.green}>
          tangente
        </text>
        {/* projections */}
        <line
          x1={mx}
          y1={my}
          x2={mx}
          y2={cy}
          stroke={PALETTE.blue}
          strokeWidth={1.2}
          strokeDasharray="5 4"
        />
        <line
          x1={mx}
          y1={my}
          x2={cx}
          y2={my}
          stroke={PALETTE.red}
          strokeWidth={1.2}
          strokeDasharray="5 4"
        />
        <line x1={cx} y1={cy} x2={mx} y2={cy} stroke={PALETTE.blue} strokeWidth={5} />
        <line x1={cx} y1={cy} x2={cx} y2={my} stroke={PALETTE.red} strokeWidth={5} />
        {/* rayon OM */}
        <line x1={cx} y1={cy} x2={mx} y2={my} stroke={PALETTE.ink} strokeWidth={2} />
        {/* point tangente */}
        {tanVisible ? (
          <g>
            <line
              x1={cx}
              y1={cy}
              x2={tanX}
              y2={tanY}
              stroke={PALETTE.green}
              strokeWidth={1.2}
              strokeDasharray="3 4"
            />
            <circle cx={tanX} cy={tanY} r={5} fill={PALETTE.green} />
            <text x={tanX + 8} y={tanY + 4} fontSize={12} fontWeight={700} fill={PALETTE.green}>
              T
            </text>
          </g>
        ) : null}
        {/* repères 1 / −1 */}
        <text x={cx + R} y={cy + 16} fontSize={11} fill={PALETTE.slate} textAnchor="middle">
          1
        </text>
        <text x={cx - R} y={cy + 16} fontSize={11} fill={PALETTE.slate} textAnchor="middle">
          −1
        </text>
        <text x={cx - 8} y={cy - R + 4} fontSize={11} fill={PALETTE.slate} textAnchor="end">
          1
        </text>
        <text x={cx - 8} y={cy + R + 4} fontSize={11} fill={PALETTE.slate} textAnchor="end">
          −1
        </text>
        <text x={cx + 12} y={cy - 8} fontSize={12} fontWeight={700} fill={PALETTE.ink}>
          O
        </text>
        <text
          x={(cx + mx) / 2}
          y={cy + 18}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.blue}
          textAnchor="middle"
        >
          cos
        </text>
        <text
          x={cx - 14}
          y={(cy + my) / 2}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.red}
          textAnchor="end"
        >
          sin
        </text>
        <Handle
          x={mx}
          y={my}
          color={PALETTE.purple}
          label="M"
          labelDx={-24}
          labelDy={-14}
          onDrag={(p) => {
            const a = Math.atan2(cy - p.y, p.x - cx);
            const nd = ((a * 180) / Math.PI + 360) % 360;
            setDeg(mode === "snap" ? nearestRemarkable(nd) : Math.round(nd));
          }}
        />
      </Board>

      <Choice
        value={mode}
        onChange={(v) => {
          setMode(v);
          if (v === "snap") setDeg(nearestRemarkable(deg));
        }}
        options={[
          { value: "snap", label: "Angles remarquables" },
          { value: "libre", label: "Angle libre" },
        ]}
      />
      <Ctrl
        label="Angle x"
        value={d}
        min={0}
        max={359}
        step={mode === "snap" ? 15 : 1}
        onChange={(v) => setDeg(mode === "snap" ? nearestRemarkable(v) : v)}
        display={`${Math.round(d)}°`}
        color={PALETTE.purple}
      />
      <Panel>
        <Stat label="x en radians" value={showExact && exact ? exact.rad : `${fmt(th, 3)} rad`} />
        <Stat
          label="cos x (abscisse)"
          value={showExact && exact ? exact.cos : fmt(co, 3)}
          color={PALETTE.blue}
        />
        <Stat
          label="sin x (ordonnée)"
          value={showExact && exact ? exact.sin : fmt(si, 3)}
          color={PALETTE.red}
        />
        <Stat
          label="tan x"
          value={showExact && exact ? exact.tan : Number.isFinite(ta) ? fmt(ta, 3) : "non définie"}
          color={PALETTE.green}
        />
      </Panel>
      <Verdict tone="ok">
        Quadrant {quadrant} : {signe}. Vérifie aussi que cos²x + sin²x = {fmt(co * co + si * si, 3)}
        .
      </Verdict>
    </div>
  );
}

function nearestRemarkable(deg: number): number {
  const d = ((deg % 360) + 360) % 360;
  let best = 0;
  let dist = 999;
  for (const r of REMARQUABLES) {
    const e = Math.min(Math.abs(r.deg - d), 360 - Math.abs(r.deg - d));
    if (e < dist) {
      dist = e;
      best = r.deg;
    }
  }
  return best;
}

/* ------------------------------------------------------------------ */
/* 2. Polynôme du second degré                                         */
/* ------------------------------------------------------------------ */

export function SecondDegre() {
  const [a, setA] = useState(1);
  const [b, setB] = useState(-2);
  const [c, setC] = useState(-1);

  const aa = a;
  const s = makeScales(460, 340, -7, 7, -8, 8, 26);
  const delta = b * b - 4 * aa * c;
  const deltaNul = Math.abs(delta) < 1e-6;
  const alpha = -b / (2 * aa);
  const beta = -delta / (4 * aa);
  const r1 = delta >= 0 ? (-b - Math.sqrt(delta)) / (2 * aa) : Number.NaN;
  const r2 = delta >= 0 ? (-b + Math.sqrt(delta)) / (2 * aa) : Number.NaN;

  return (
    <div className="space-y-3">
      <Board width={s.width} height={s.height}>
        <rect width={s.width} height={s.height} fill="#ffffff" />
        <Grid s={s} />
        <line
          x1={s.sx(alpha)}
          y1={s.sy(s.yMin)}
          x2={s.sx(alpha)}
          y2={s.sy(s.yMax)}
          stroke={PALETTE.purple}
          strokeWidth={1.2}
          strokeDasharray="6 5"
        />
        <path
          d={curvePath((x) => aa * x * x + b * x + c, s)}
          fill="none"
          stroke={PALETTE.blue}
          strokeWidth={3}
        />
        {delta >= 0
          ? [r1, r2].map((r, i) =>
              r >= s.xMin && r <= s.xMax ? (
                <g key={i}>
                  <circle cx={s.sx(r)} cy={s.sy(0)} r={6} fill={PALETTE.red} />
                  <text
                    x={s.sx(r)}
                    y={s.sy(0) - 12}
                    fontSize={12}
                    fontWeight={700}
                    fill={PALETTE.red}
                    textAnchor="middle"
                  >
                    {fmt(r, 2)}
                  </text>
                </g>
              ) : null,
            )
          : null}
        {beta >= s.yMin && beta <= s.yMax ? (
          <g>
            <circle cx={s.sx(alpha)} cy={s.sy(beta)} r={6} fill={PALETTE.purple} />
            <text
              x={s.sx(alpha) + 10}
              y={s.sy(beta) + (aa > 0 ? 18 : -10)}
              fontSize={12}
              fontWeight={700}
              fill={PALETTE.purple}
            >
              S({fmt(alpha, 2)} ; {fmt(beta, 2)})
            </text>
          </g>
        ) : null}
      </Board>
      <div className="grid gap-3 sm:grid-cols-3">
        <Ctrl
          label="a"
          value={a}
          min={-3}
          max={3}
          step={0.1}
          onChange={(v) => setA(Math.abs(v) < 0.1 ? (v < 0 ? -0.1 : 0.1) : v)}
        />
        <Ctrl label="b" value={b} min={-6} max={6} step={0.1} onChange={setB} color={PALETTE.red} />
        <Ctrl
          label="c"
          value={c}
          min={-6}
          max={6}
          step={0.1}
          onChange={setC}
          color={PALETTE.green}
        />
      </div>
      <Panel>
        <Stat
          label="P(x)"
          value={`${fmt(aa, 2)}x² ${b < 0 ? "−" : "+"} ${fmt(Math.abs(b), 2)}x ${
            c < 0 ? "−" : "+"
          } ${fmt(Math.abs(c), 2)}`}
        />
        <Stat
          label="Δ = b² − 4ac"
          value={fmt(delta, 2)}
          color={delta > 0 ? PALETTE.green : delta < 0 ? PALETTE.red : PALETTE.orange}
        />
        <Stat
          label="Racines"
          value={deltaNul ? fmt(alpha, 2) : delta > 0 ? `${fmt(r1, 2)} et ${fmt(r2, 2)}` : "aucune"}
          color={PALETTE.red}
        />
        <Stat
          label="Forme canonique"
          value={`${fmt(aa, 2)}(x ${alpha < 0 ? "+" : "−"} ${fmt(Math.abs(alpha), 2)})² ${
            beta < 0 ? "−" : "+"
          } ${fmt(Math.abs(beta), 2)}`}
          color={PALETTE.purple}
        />
      </Panel>
      <Verdict tone={deltaNul ? "warn" : delta > 0 ? "ok" : "bad"}>
        {deltaNul
          ? "Δ = 0 : la parabole touche l'axe des abscisses en un seul point — une racine double."
          : delta > 0
            ? "Δ > 0 : la parabole coupe l'axe des abscisses en deux points — deux racines distinctes."
            : "Δ < 0 : la parabole ne touche jamais l'axe des abscisses — aucune racine réelle. P(x) garde le signe de a."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 3. Nombre dérivé : de la sécante à la tangente                      */
/* ------------------------------------------------------------------ */

type Fonc = { key: string; label: string; f: (x: number) => number; df: (x: number) => number };

const F_CARRE: Fonc = { key: "carre", label: "f(x) = x²", f: (x) => x * x, df: (x) => 2 * x };

const FONCTIONS: Fonc[] = [
  F_CARRE,
  { key: "cube", label: "f(x) = x³ − 3x", f: (x) => x * x * x - 3 * x, df: (x) => 3 * x * x - 3 },
  { key: "inverse", label: "f(x) = 1/x", f: (x) => 1 / x, df: (x) => -1 / (x * x) },
  { key: "racine", label: "f(x) = √x", f: (x) => Math.sqrt(x), df: (x) => 1 / (2 * Math.sqrt(x)) },
  { key: "sinus", label: "f(x) = sin x", f: (x) => Math.sin(x), df: (x) => Math.cos(x) },
];

export function DeriveeTangente() {
  const [key, setKey] = useState("carre");
  const [x0, setX0] = useState(1);
  const [h, setH] = useState(1.5);
  const [anime, setAnime] = useState(false);

  const fonc = FONCTIONS.find((v) => v.key === key) ?? F_CARRE;
  const xMinSlider = fonc.key === "racine" ? 0.2 : fonc.key === "inverse" ? 0.2 : -4;

  useEffect(() => {
    if (!anime) return undefined;
    const id = window.setInterval(() => {
      setH((prev) => {
        const next = prev * 0.82;
        if (next <= 0.02) {
          setAnime(false);
          return 0.02;
        }
        return next;
      });
    }, 110);
    return () => window.clearInterval(id);
  }, [anime]);

  const s = makeScales(460, 340, -5, 5, -6, 6, 26);
  const y0 = fonc.f(x0);
  const y1 = fonc.f(x0 + h);
  const taux = (y1 - y0) / h;
  const pente = fonc.df(x0);
  const ok = Number.isFinite(y0) && Number.isFinite(y1);

  return (
    <div className="space-y-3">
      <Board width={s.width} height={s.height}>
        <rect width={s.width} height={s.height} fill="#ffffff" />
        <Grid s={s} />
        <path d={curvePath(fonc.f, s)} fill="none" stroke={PALETTE.blue} strokeWidth={3} />
        {Number.isFinite(pente) && Number.isFinite(y0) ? (
          <path
            d={linePath(pente, y0 - pente * x0, s)}
            stroke={PALETTE.green}
            strokeWidth={2.5}
            fill="none"
          />
        ) : null}
        {ok ? (
          <path
            d={linePath(taux, y0 - taux * x0, s)}
            stroke={PALETTE.orange}
            strokeWidth={2}
            strokeDasharray="7 5"
            fill="none"
          />
        ) : null}
        {ok ? (
          <g>
            <line
              x1={s.sx(x0)}
              y1={s.sy(y0)}
              x2={s.sx(x0 + h)}
              y2={s.sy(y0)}
              stroke={PALETTE.slate}
              strokeWidth={1.2}
              strokeDasharray="4 4"
            />
            <line
              x1={s.sx(x0 + h)}
              y1={s.sy(y0)}
              x2={s.sx(x0 + h)}
              y2={s.sy(y1)}
              stroke={PALETTE.slate}
              strokeWidth={1.2}
              strokeDasharray="4 4"
            />
            <text
              x={(s.sx(x0) + s.sx(x0 + h)) / 2}
              y={s.sy(y0) + 15}
              fontSize={11}
              fill={PALETTE.slate}
              textAnchor="middle"
            >
              h = {fmt(h, 2)}
            </text>
            <circle cx={s.sx(x0 + h)} cy={s.sy(y1)} r={5.5} fill={PALETTE.orange} />
            <text
              x={s.sx(x0 + h) + 8}
              y={s.sy(y1) - 8}
              fontSize={12}
              fontWeight={700}
              fill={PALETTE.orange}
            >
              B
            </text>
          </g>
        ) : null}
        {Number.isFinite(y0) ? (
          <g>
            <circle cx={s.sx(x0)} cy={s.sy(y0)} r={6} fill={PALETTE.green} />
            <text
              x={s.sx(x0) - 16}
              y={s.sy(y0) - 8}
              fontSize={12}
              fontWeight={700}
              fill={PALETTE.green}
            >
              A
            </text>
          </g>
        ) : null}
      </Board>
      <Choice
        label="Fonction"
        value={key}
        onChange={(v) => {
          setKey(v);
          setX0(1);
          setAnime(false);
          setH(1.5);
        }}
        options={FONCTIONS.map((v) => ({ value: v.key, label: v.label }))}
      />
      <div className="grid gap-3 sm:grid-cols-2">
        <Ctrl
          label="Abscisse du point A : x₀"
          value={x0}
          min={xMinSlider}
          max={4}
          step={0.1}
          onChange={setX0}
          color={PALETTE.green}
        />
        <Ctrl
          label="Écart h"
          value={h}
          min={0.02}
          max={3}
          step={0.01}
          onChange={(v) => {
            setAnime(false);
            setH(v);
          }}
          color={PALETTE.orange}
        />
      </div>
      <button
        type="button"
        onClick={() => {
          setH(2.5);
          setAnime(true);
        }}
        className="rounded-lg bg-primary px-4 py-2 text-xs font-semibold text-primary-foreground"
      >
        ▶ Faire tendre h vers 0
      </button>
      <Panel>
        <Stat
          label="Taux d'accroissement (sécante)"
          value={ok ? fmt(taux, 3) : "non défini"}
          color={PALETTE.orange}
        />
        <Stat
          label="Nombre dérivé f′(x₀) (tangente)"
          value={Number.isFinite(pente) ? fmt(pente, 3) : "non défini"}
          color={PALETTE.green}
        />
      </Panel>
      <Verdict tone={ok && Math.abs(taux - pente) < 0.05 ? "ok" : "warn"}>
        Plus h devient petit, plus la droite orange (sécante AB) se confond avec la droite verte
        (tangente en A) : c'est exactement ce que veut dire f′(x₀) = lim (f(x₀+h) − f(x₀)) / h quand
        h → 0.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. Vecteurs du plan                                                 */
/* ------------------------------------------------------------------ */

export function Vecteurs() {
  const [u, setU] = useState({ x: 3, y: 2 });
  const [v, setV] = useState({ x: -2, y: 3 });
  const s = makeScales(440, 360, -6, 6, -5, 5, 26);

  const sum = { x: u.x + v.x, y: u.y + v.y };
  const dif = { x: u.x - v.x, y: u.y - v.y };
  const dot = u.x * v.x + u.y * v.y;
  const det = u.x * v.y - u.y * v.x;
  const nu = Math.hypot(u.x, u.y);
  const nv = Math.hypot(v.x, v.y);
  const ang =
    nu > 0 && nv > 0
      ? (Math.acos(Math.max(-1, Math.min(1, dot / (nu * nv)))) * 180) / Math.PI
      : Number.NaN;

  const snap = (p: { x: number; y: number }) => ({
    x: clamp(Math.round(s.ux(p.x) * 2) / 2, s.xMin + 0.5, s.xMax - 0.5),
    y: clamp(Math.round(s.uy(p.y) * 2) / 2, s.yMin + 0.5, s.yMax - 0.5),
  });

  return (
    <div className="space-y-3">
      <Board width={s.width} height={s.height}>
        <rect width={s.width} height={s.height} fill="#ffffff" />
        <Grid s={s} />
        <line
          x1={s.sx(u.x)}
          y1={s.sy(u.y)}
          x2={s.sx(sum.x)}
          y2={s.sy(sum.y)}
          stroke={PALETTE.red}
          strokeWidth={1.4}
          strokeDasharray="6 5"
        />
        <line
          x1={s.sx(v.x)}
          y1={s.sy(v.y)}
          x2={s.sx(sum.x)}
          y2={s.sy(sum.y)}
          stroke={PALETTE.blue}
          strokeWidth={1.4}
          strokeDasharray="6 5"
        />
        <Arrow
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(sum.x)}
          y2={s.sy(sum.y)}
          color={PALETTE.purple}
          width={3}
        />
        <Arrow
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(u.x)}
          y2={s.sy(u.y)}
          color={PALETTE.blue}
          width={3}
        />
        <Arrow
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(v.x)}
          y2={s.sy(v.y)}
          color={PALETTE.red}
          width={3}
        />
        <Arrow
          x1={s.sx(v.x)}
          y1={s.sy(v.y)}
          x2={s.sx(u.x)}
          y2={s.sy(u.y)}
          color={PALETTE.green}
          width={2}
          dashed
        />
        <text
          x={s.sx(sum.x) + 8}
          y={s.sy(sum.y) - 6}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.purple}
        >
          u + v
        </text>
        <text
          x={(s.sx(u.x) + s.sx(v.x)) / 2 + 6}
          y={(s.sy(u.y) + s.sy(v.y)) / 2 - 6}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.green}
        >
          u − v
        </text>
        <Handle
          x={s.sx(u.x)}
          y={s.sy(u.y)}
          color={PALETTE.blue}
          label="u"
          onDrag={(p) => setU(snap(p))}
        />
        <Handle
          x={s.sx(v.x)}
          y={s.sy(v.y)}
          color={PALETTE.red}
          label="v"
          onDrag={(p) => setV(snap(p))}
        />
      </Board>
      <Panel>
        <Stat label="u" value={`(${fmt(u.x, 1)} ; ${fmt(u.y, 1)})`} color={PALETTE.blue} />
        <Stat label="v" value={`(${fmt(v.x, 1)} ; ${fmt(v.y, 1)})`} color={PALETTE.red} />
        <Stat
          label="u + v"
          value={`(${fmt(sum.x, 1)} ; ${fmt(sum.y, 1)})`}
          color={PALETTE.purple}
        />
        <Stat label="u − v" value={`(${fmt(dif.x, 1)} ; ${fmt(dif.y, 1)})`} color={PALETTE.green} />
        <Stat label="‖u‖" value={fmt(nu, 2)} />
        <Stat label="‖v‖" value={fmt(nv, 2)} />
        <Stat label="Produit scalaire u·v" value={fmt(dot, 2)} />
        <Stat label="Déterminant det(u,v)" value={fmt(det, 2)} />
      </Panel>
      <Verdict tone={Math.abs(det) < 1e-9 ? "warn" : Math.abs(dot) < 1e-9 ? "ok" : "warn"}>
        {Math.abs(det) < 1e-9
          ? "det(u,v) = 0 : les deux vecteurs sont colinéaires (même direction)."
          : Math.abs(dot) < 1e-9
            ? "u·v = 0 : les deux vecteurs sont orthogonaux (angle droit)."
            : `Angle entre u et v : ${fmt(ang, 1)}°. Cherche à obtenir u·v = 0 (orthogonaux) puis det(u,v) = 0 (colinéaires).`}
      </Verdict>
    </div>
  );
}

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* 5. Barycentre de trois points                                       */
/* ------------------------------------------------------------------ */

export function Barycentre() {
  const [A, setA] = useState({ x: -3, y: -2 });
  const [B, setB] = useState({ x: 3, y: -2 });
  const [C, setC] = useState({ x: 0, y: 3 });
  const [al, setAl] = useState(1);
  const [be, setBe] = useState(1);
  const [ga, setGa] = useState(1);

  const s = makeScales(440, 360, -6, 6, -5, 5, 26);
  const som = al + be + ga;
  const existe = Math.abs(som) > 1e-6;
  const G = existe
    ? { x: (al * A.x + be * B.x + ga * C.x) / som, y: (al * A.y + be * B.y + ga * C.y) / som }
    : { x: 0, y: 0 };

  const snap = (p: { x: number; y: number }) => ({
    x: clamp(Math.round(s.ux(p.x) * 2) / 2, s.xMin + 0.5, s.xMax - 0.5),
    y: clamp(Math.round(s.uy(p.y) * 2) / 2, s.yMin + 0.5, s.yMax - 0.5),
  });

  return (
    <div className="space-y-3">
      <Board width={s.width} height={s.height}>
        <rect width={s.width} height={s.height} fill="#ffffff" />
        <Grid s={s} />
        <polygon
          points={`${s.sx(A.x)},${s.sy(A.y)} ${s.sx(B.x)},${s.sy(B.y)} ${s.sx(C.x)},${s.sy(C.y)}`}
          fill={PALETTE.blue}
          opacity={0.08}
          stroke={PALETTE.slate}
          strokeWidth={1.5}
        />
        {existe ? (
          <g>
            {[A, B, C].map((P, i) => (
              <line
                key={i}
                x1={s.sx(P.x)}
                y1={s.sy(P.y)}
                x2={s.sx(G.x)}
                y2={s.sy(G.y)}
                stroke={PALETTE.orange}
                strokeWidth={1.2}
                strokeDasharray="5 4"
              />
            ))}
            <circle cx={s.sx(G.x)} cy={s.sy(G.y)} r={8} fill={PALETTE.orange} />
            <text
              x={s.sx(G.x) + 12}
              y={s.sy(G.y) - 10}
              fontSize={14}
              fontWeight={700}
              fill={PALETTE.orange}
            >
              G
            </text>
          </g>
        ) : null}
        <Handle
          x={s.sx(A.x)}
          y={s.sy(A.y)}
          color={PALETTE.blue}
          label="A"
          onDrag={(p) => setA(snap(p))}
        />
        <Handle
          x={s.sx(B.x)}
          y={s.sy(B.y)}
          color={PALETTE.red}
          label="B"
          onDrag={(p) => setB(snap(p))}
        />
        <Handle
          x={s.sx(C.x)}
          y={s.sy(C.y)}
          color={PALETTE.green}
          label="C"
          onDrag={(p) => setC(snap(p))}
        />
      </Board>
      <div className="grid gap-3 sm:grid-cols-3">
        <Ctrl label="α (poids de A)" value={al} min={-3} max={4} step={0.5} onChange={setAl} />
        <Ctrl
          label="β (poids de B)"
          value={be}
          min={-3}
          max={4}
          step={0.5}
          onChange={setBe}
          color={PALETTE.red}
        />
        <Ctrl
          label="γ (poids de C)"
          value={ga}
          min={-3}
          max={4}
          step={0.5}
          onChange={setGa}
          color={PALETTE.green}
        />
      </div>
      <Panel>
        <Stat label="α + β + γ" value={fmt(som, 2)} color={existe ? PALETTE.ink : PALETTE.red} />
        <Stat
          label="Coordonnées de G"
          value={existe ? `(${fmt(G.x, 2)} ; ${fmt(G.y, 2)})` : "n'existe pas"}
          color={PALETTE.orange}
        />
      </Panel>
      <Verdict tone={existe ? "ok" : "bad"}>
        {existe
          ? "Mets α = β = γ = 1 : G devient l'isobarycentre, c'est-à-dire le centre de gravité du triangle, au croisement des médianes."
          : "Quand α + β + γ = 0, le barycentre n'existe pas : c'est une règle du cours."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. Suites arithmétiques et géométriques                             */
/* ------------------------------------------------------------------ */

export function Suites() {
  const [type, setType] = useState<"arith" | "geo">("arith");
  const [u0, setU0] = useState(2);
  const [r, setR] = useState(1.5);
  const [q, setQ] = useState(1.5);
  const [n, setN] = useState(10);

  const termes = useMemo(() => {
    const out: number[] = [];
    let u = u0;
    for (let i = 0; i < n; i++) {
      out.push(u);
      u = type === "arith" ? u + r : u * q;
    }
    return out;
  }, [type, u0, r, q, n]);

  const W = 460;
  const H = 300;
  const pad = 30;
  const bas = H - pad - 16;
  const vMax = Math.max(0, ...termes);
  const vMin = Math.min(0, ...termes);
  const etendue = Math.max(vMax - vMin, 1e-6);
  const yOf = (v: number) => bas - ((v - vMin) / etendue) * (bas - pad);
  const zero = yOf(0);
  const bw = (W - 2 * pad) / Math.max(1, n);

  const somme = termes.reduce((acc, t) => acc + t, 0);
  const dernier = termes[termes.length - 1] ?? u0;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={pad - 6}
          y1={zero}
          x2={W - pad + 6}
          y2={zero}
          stroke={PALETTE.axis}
          strokeWidth={1.5}
        />
        {termes.map((t, i) => {
          const yt = yOf(t);
          const x = pad + i * bw + bw * 0.15;
          const w = bw * 0.7;
          const y = Math.min(zero, yt);
          const h = Math.abs(yt - zero);
          return (
            <g key={i}>
              <rect
                x={x}
                y={y}
                width={w}
                height={Math.max(1, h)}
                fill={type === "arith" ? PALETTE.blue : PALETTE.purple}
                opacity={0.85}
                rx={2}
              />
              <text
                x={x + w / 2}
                y={t >= 0 ? y - 5 : zero - 5}
                fontSize={9}
                fill={PALETTE.slate}
                textAnchor="middle"
              >
                {fmt(t, 1)}
              </text>
              <text
                x={x + w / 2}
                y={bas + 14}
                fontSize={9}
                fill={PALETTE.slate}
                textAnchor="middle"
              >
                u{sub(i)}
              </text>
            </g>
          );
        })}
      </Board>
      <Choice
        value={type}
        onChange={setType}
        options={[
          { value: "arith", label: "Suite arithmétique" },
          { value: "geo", label: "Suite géométrique" },
        ]}
      />
      <div className="grid gap-3 sm:grid-cols-3">
        <Ctrl label="Premier terme u₀" value={u0} min={-5} max={10} step={0.5} onChange={setU0} />
        {type === "arith" ? (
          <Ctrl
            label="Raison r"
            value={r}
            min={-4}
            max={4}
            step={0.5}
            onChange={setR}
            color={PALETTE.red}
          />
        ) : (
          <Ctrl
            label="Raison q"
            value={q}
            min={-2}
            max={2.5}
            step={0.1}
            onChange={setQ}
            color={PALETTE.red}
          />
        )}
        <Ctrl
          label="Nombre de termes"
          value={n}
          min={3}
          max={14}
          step={1}
          onChange={(v) => setN(Math.round(v))}
          color={PALETTE.green}
        />
      </div>
      <Panel>
        <Stat
          label="Formule du terme général"
          value={
            type === "arith"
              ? `u${sub("n")} = ${fmt(u0, 1)} + n × ${fmt(r, 1)}`
              : `u${sub("n")} = ${fmt(u0, 1)} × ${fmt(q, 2)}ⁿ`
          }
          color={PALETTE.blue}
        />
        <Stat
          label={`Dernier terme u${sub(n - 1)}`}
          value={fmt(dernier, 3)}
          color={PALETTE.purple}
        />
        <Stat
          label={`Somme des ${n} premiers termes`}
          value={fmt(somme, 3)}
          color={PALETTE.green}
        />
        <Stat
          label="Sens de variation"
          value={
            type === "arith"
              ? r > 0
                ? "croissante"
                : r < 0
                  ? "décroissante"
                  : "constante"
              : Math.abs(q) < 1
                ? "tend vers 0"
                : Math.abs(q) > 1
                  ? "explose"
                  : "constante en valeur absolue"
          }
        />
      </Panel>
      <Verdict tone={type === "geo" && Math.abs(q) < 1 ? "ok" : "warn"}>
        {type === "arith"
          ? "Dans une suite arithmétique on ajoute toujours la même raison r : les barres montent (ou descendent) d'une hauteur constante."
          : Math.abs(q) < 1
            ? "Avec |q| < 1 les barres se rapprochent de zéro : la suite converge vers 0."
            : "Avec |q| > 1 chaque terme est multiplié par q : la croissance s'emballe très vite."}
      </Verdict>
    </div>
  );
}

function sub(v: number | string): string {
  const map: Record<string, string> = {
    "0": "₀",
    "1": "₁",
    "2": "₂",
    "3": "₃",
    "4": "₄",
    "5": "₅",
    "6": "₆",
    "7": "₇",
    "8": "₈",
    "9": "₉",
    n: "ₙ",
  };
  return String(v)
    .split("")
    .map((ch) => map[ch] ?? ch)
    .join("");
}

/* ------------------------------------------------------------------ */
/* 7. Statistiques : série à construire soi-même                       */
/* ------------------------------------------------------------------ */

const NOTES = [4, 6, 8, 10, 12, 14, 16, 18];

export function Statistiques() {
  const [eff, setEff] = useState<number[]>([1, 3, 6, 9, 7, 4, 2, 1]);

  const W = 460;
  const H = 300;
  const pad = 34;
  const maxEff = 20;
  const bw = (W - 2 * pad) / NOTES.length;
  const base = H - pad;
  const hOf = (e: number) => ((H - 2 * pad) * e) / maxEff;

  const total = eff.reduce((a, b) => a + b, 0);
  const moyenne =
    total > 0 ? eff.reduce((a, e, i) => a + e * (NOTES[i] ?? 0), 0) / total : Number.NaN;
  const variance =
    total > 0
      ? eff.reduce((a, e, i) => a + e * Math.pow((NOTES[i] ?? 0) - moyenne, 2), 0) / total
      : Number.NaN;
  const ecart = Math.sqrt(variance);
  const mediane = quantile(eff, 0.5);
  const q1 = quantile(eff, 0.25);
  const q3 = quantile(eff, 0.75);
  const modeIdx = eff.indexOf(Math.max(...eff));
  const mode = NOTES[modeIdx] ?? 0;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={pad - 8}
          y1={base}
          x2={W - pad + 8}
          y2={base}
          stroke={PALETTE.axis}
          strokeWidth={1.5}
        />
        <line
          x1={pad - 8}
          y1={base}
          x2={pad - 8}
          y2={pad - 8}
          stroke={PALETTE.axis}
          strokeWidth={1.5}
        />
        {eff.map((e, i) => {
          const x = pad + i * bw + bw * 0.12;
          const w = bw * 0.76;
          const h = hOf(e);
          return (
            <g key={i}>
              <rect
                x={x}
                y={base - h}
                width={w}
                height={h}
                fill={PALETTE.blue}
                opacity={0.85}
                rx={3}
              />
              <text
                x={x + w / 2}
                y={base - h - 6}
                fontSize={11}
                fontWeight={700}
                fill={PALETTE.blue}
                textAnchor="middle"
              >
                {e}
              </text>
              <text
                x={x + w / 2}
                y={base + 16}
                fontSize={11}
                fill={PALETTE.slate}
                textAnchor="middle"
              >
                {NOTES[i]}
              </text>
              <Handle
                x={x + w / 2}
                y={base - h}
                color={PALETTE.orange}
                onDrag={(p) => {
                  const val = Math.round(((base - p.y) / (H - 2 * pad)) * maxEff);
                  setEff(eff.map((old, j) => (j === i ? clamp(val, 0, 30) : old)));
                }}
              />
            </g>
          );
        })}
        {Number.isFinite(moyenne) ? (
          <g>
            <line
              x1={pad + ((moyenne - 3) / 16) * (W - 2 * pad)}
              y1={pad - 8}
              x2={pad + ((moyenne - 3) / 16) * (W - 2 * pad)}
              y2={base}
              stroke={PALETTE.red}
              strokeWidth={2}
              strokeDasharray="6 4"
            />
            <text
              x={pad + ((moyenne - 3) / 16) * (W - 2 * pad) + 6}
              y={pad + 4}
              fontSize={11}
              fontWeight={700}
              fill={PALETTE.red}
            >
              moyenne
            </text>
          </g>
        ) : null}
        <text x={W / 2} y={H - 6} fontSize={11} fill={PALETTE.slate} textAnchor="middle">
          Notes sur 20 — tire les points orange pour changer les effectifs
        </text>
      </Board>
      <Panel>
        <Stat label="Effectif total" value={String(total)} />
        <Stat label="Moyenne" value={fmt(moyenne, 2)} color={PALETTE.red} />
        <Stat label="Médiane" value={fmt(mediane, 1)} color={PALETTE.purple} />
        <Stat label="Mode" value={fmt(mode, 0)} color={PALETTE.blue} />
        <Stat label="Q1 — Q3" value={`${fmt(q1, 1)} — ${fmt(q3, 1)}`} />
        <Stat label="Écart-type σ" value={fmt(ecart, 2)} color={PALETTE.green} />
      </Panel>
      <Verdict tone="ok">
        Déplace les effectifs et observe : la moyenne suit immédiatement les valeurs extrêmes, alors
        que la médiane bouge très peu. C'est pour cela qu'on dit que la médiane résiste mieux aux
        notes isolées.
      </Verdict>
    </div>
  );
}

function quantile(eff: number[], p: number): number {
  const total = eff.reduce((a, b) => a + b, 0);
  if (total === 0) return Number.NaN;
  const cible = total * p;
  let cum = 0;
  for (let i = 0; i < eff.length; i++) {
    cum += eff[i] ?? 0;
    if (cum >= cible) return NOTES[i] ?? 0;
  }
  return NOTES[NOTES.length - 1] ?? 0;
}

/* ------------------------------------------------------------------ */
/* 8. Transformations du plan                                          */
/* ------------------------------------------------------------------ */

type Pt = { x: number; y: number };
const MAISON: Pt[] = [
  { x: 0, y: 0 },
  { x: 2, y: 0 },
  { x: 2, y: 1.5 },
  { x: 1, y: 2.5 },
  { x: 0, y: 1.5 },
];

export function Transformations() {
  const [type, setType] = useState<"translation" | "rotation" | "homothetie">("translation");
  const [tx, setTx] = useState(2);
  const [ty, setTy] = useState(1);
  const [angle, setAngle] = useState(90);
  const [k, setK] = useState(2);
  const [centre, setCentre] = useState<Pt>({ x: 0, y: 0 });

  const s = makeScales(440, 360, -6, 6, -5, 5, 26);

  function image(p: Pt): Pt {
    if (type === "translation") return { x: p.x + tx, y: p.y + ty };
    if (type === "rotation") {
      const a = (angle * Math.PI) / 180;
      const dx = p.x - centre.x;
      const dy = p.y - centre.y;
      return {
        x: centre.x + dx * Math.cos(a) - dy * Math.sin(a),
        y: centre.y + dx * Math.sin(a) + dy * Math.cos(a),
      };
    }
    return { x: centre.x + k * (p.x - centre.x), y: centre.y + k * (p.y - centre.y) };
  }

  const src = MAISON;
  const dst = src.map(image);
  const poly = (pts: Pt[]) => pts.map((p) => `${s.sx(p.x)},${s.sy(p.y)}`).join(" ");
  const a0 = src[0];
  const b0 = dst[0];

  return (
    <div className="space-y-3">
      <Board width={s.width} height={s.height}>
        <rect width={s.width} height={s.height} fill="#ffffff" />
        <Grid s={s} />
        <polygon
          points={poly(src)}
          fill={PALETTE.slate}
          opacity={0.2}
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <polygon
          points={poly(dst)}
          fill={PALETTE.blue}
          opacity={0.22}
          stroke={PALETTE.blue}
          strokeWidth={2.5}
        />
        {a0 && b0 ? (
          <Arrow
            x1={s.sx(a0.x)}
            y1={s.sy(a0.y)}
            x2={s.sx(b0.x)}
            y2={s.sy(b0.y)}
            color={PALETTE.orange}
            width={2}
            dashed
          />
        ) : null}
        {type !== "translation" ? (
          <Handle
            x={s.sx(centre.x)}
            y={s.sy(centre.y)}
            color={PALETTE.red}
            label="Ω"
            onDrag={(p) =>
              setCentre({
                x: clamp(Math.round(s.ux(p.x) * 2) / 2, s.xMin + 0.5, s.xMax - 0.5),
                y: clamp(Math.round(s.uy(p.y) * 2) / 2, s.yMin + 0.5, s.yMax - 0.5),
              })
            }
          />
        ) : null}
        <text x={s.sx(-5.5)} y={s.sy(4.4)} fontSize={12} fontWeight={700} fill={PALETTE.slate}>
          figure de départ
        </text>
        <text x={s.sx(-5.5)} y={s.sy(3.9)} fontSize={12} fontWeight={700} fill={PALETTE.blue}>
          figure image
        </text>
      </Board>
      <Choice
        value={type}
        onChange={setType}
        options={[
          { value: "translation", label: "Translation" },
          { value: "rotation", label: "Rotation" },
          { value: "homothetie", label: "Homothétie" },
        ]}
      />
      {type === "translation" ? (
        <div className="grid gap-3 sm:grid-cols-2">
          <Ctrl
            label="Vecteur : abscisse a"
            value={tx}
            min={-5}
            max={5}
            step={0.5}
            onChange={setTx}
          />
          <Ctrl
            label="Vecteur : ordonnée b"
            value={ty}
            min={-4}
            max={4}
            step={0.5}
            onChange={setTy}
            color={PALETTE.red}
          />
        </div>
      ) : type === "rotation" ? (
        <Ctrl
          label="Angle de rotation"
          value={angle}
          min={-180}
          max={180}
          step={15}
          onChange={setAngle}
          display={`${angle}°`}
          color={PALETTE.purple}
        />
      ) : (
        <Ctrl
          label="Rapport k"
          value={k}
          min={-2}
          max={3}
          step={0.25}
          onChange={setK}
          color={PALETTE.purple}
        />
      )}
      <Verdict tone="ok">
        {type === "translation"
          ? "La translation fait glisser la figure sans la tourner ni la déformer : toutes les flèches reliant un point à son image sont identiques."
          : type === "rotation"
            ? "La rotation tourne la figure autour du centre Ω (déplace Ω pour voir). Les longueurs sont conservées."
            : k < 0
              ? "Avec k < 0, l'image est de l'autre côté du centre Ω et retournée. Pour k = −1 on obtient la symétrie centrale."
              : "L'homothétie agrandit (k > 1) ou réduit (0 < k < 1) la figure. Les angles sont conservés, les longueurs sont multipliées par |k|."}
      </Verdict>
    </div>
  );
}
