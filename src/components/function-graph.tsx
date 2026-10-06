import { useMemo } from "react";
import { compileExpression, sample, type GraphSpec } from "@/lib/function-plot";

const WIDTH = 640;
const HEIGHT = 420;
const PAD = 36;
const DEFAULT_COLORS = ["#2563eb", "#dc2626", "#16a34a", "#9333ea", "#ea580c"];

/** Trace un ou plusieurs graphes de fonctions à partir d'un spec JSON (voir GraphSpec). */
export function FunctionGraph({ spec }: { spec: string }) {
  const parsed = useMemo(() => {
    try {
      const data = JSON.parse(spec) as GraphSpec;
      if (!data.functions || data.functions.length === 0) {
        throw new Error("Aucune fonction à tracer (champ \"functions\" manquant ou vide).");
      }
      return { ok: true as const, data };
    } catch (e) {
      return { ok: false as const, error: e instanceof Error ? e.message : "Spec de graphique invalide" };
    }
  }, [spec]);

  if (!parsed.ok) {
    return (
      <p className="rounded-xl border border-destructive/30 bg-destructive/5 px-3 py-2 text-sm text-destructive">
        Impossible d'afficher ce graphique : {parsed.error}
      </p>
    );
  }

  const { functions, points = [] } = parsed.data;
  const domain = parsed.data.domain ?? [-10, 10];

  const series = useMemo(() => {
    return functions.map((f, i) => {
      try {
        const fn = compileExpression(f.expr);
        return { ...f, color: f.color ?? DEFAULT_COLORS[i % DEFAULT_COLORS.length], data: sample(fn, domain), error: null as string | null };
      } catch (e) {
        return { ...f, color: f.color ?? DEFAULT_COLORS[i % DEFAULT_COLORS.length], data: [], error: e instanceof Error ? e.message : "Expression invalide" };
      }
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [spec]);

  const yRange = useMemo<[number, number]>(() => {
    if (parsed.data.range) return parsed.data.range;
    const finite = series.flatMap((s) => s.data.map((p) => p.y)).filter((y) => Number.isFinite(y));
    if (finite.length === 0) return [-10, 10];
    const min = Math.min(...finite);
    const max = Math.max(...finite);
    const margin = Math.max((max - min) * 0.15, 1);
    return [min - margin, max + margin];
  }, [series, parsed.data.range]);

  const [xMin, xMax] = domain;
  const [yMin, yMax] = yRange;
  const sx = (x: number) => PAD + ((x - xMin) / (xMax - xMin)) * (WIDTH - 2 * PAD);
  const sy = (y: number) => HEIGHT - PAD - ((y - yMin) / (yMax - yMin)) * (HEIGHT - 2 * PAD);

  const errors = series.filter((s) => s.error);

  return (
    <div className="overflow-x-auto rounded-xl border border-border bg-white p-2">
      <svg viewBox={`0 0 ${WIDTH} ${HEIGHT}`} className="w-full" role="img" aria-label="Graphique de fonction">
        {/* grille */}
        {Array.from({ length: 11 }).map((_, i) => {
          const gx = xMin + ((xMax - xMin) * i) / 10;
          const gy = yMin + ((yMax - yMin) * i) / 10;
          return (
            <g key={i} stroke="#e5e7eb" strokeWidth={1}>
              <line x1={sx(gx)} y1={PAD} x2={sx(gx)} y2={HEIGHT - PAD} />
              <line x1={PAD} y1={sy(gy)} x2={WIDTH - PAD} y2={sy(gy)} />
            </g>
          );
        })}
        {/* axes */}
        {yMin <= 0 && yMax >= 0 && (
          <line x1={PAD} y1={sy(0)} x2={WIDTH - PAD} y2={sy(0)} stroke="#111827" strokeWidth={1.5} />
        )}
        {xMin <= 0 && xMax >= 0 && (
          <line x1={sx(0)} y1={PAD} x2={sx(0)} y2={HEIGHT - PAD} stroke="#111827" strokeWidth={1.5} />
        )}
        {/* courbes, coupées aux discontinuités (NaN) */}
        {series.map((s, i) => {
          if (s.error || s.data.length === 0) return null;
          let d = "";
          let drawing = false;
          for (const p of s.data) {
            if (!Number.isFinite(p.y)) {
              drawing = false;
              continue;
            }
            const px = sx(p.x);
            const py = sy(Math.max(yMin, Math.min(yMax, p.y)));
            d += drawing ? ` L ${px},${py}` : ` M ${px},${py}`;
            drawing = true;
          }
          return <path key={i} d={d} fill="none" stroke={s.color} strokeWidth={2.5} />;
        })}
        {/* points marqués */}
        {points.map((p, i) => (
          <g key={i}>
            <circle cx={sx(p.x)} cy={sy(p.y)} r={4} fill="#111827" />
            {p.label ? (
              <text x={sx(p.x) + 6} y={sy(p.y) - 6} fontSize={12} fill="#111827">
                {p.label}
              </text>
            ) : null}
          </g>
        ))}
      </svg>
      <div className="mt-1 flex flex-wrap gap-x-4 gap-y-1 px-2 pb-1">
        {series.map((s, i) => (
          <span key={i} className="inline-flex items-center gap-1.5 text-xs text-muted-foreground">
            <span className="inline-block size-2.5 rounded-full" style={{ backgroundColor: s.color }} />
            {s.label ?? s.expr}
          </span>
        ))}
      </div>
      {errors.length > 0 ? (
        <p className="px-2 pb-2 text-xs text-destructive">
          {errors.map((e) => `"${e.expr}" : ${e.error}`).join(" · ")}
        </p>
      ) : null}
    </div>
  );
}
