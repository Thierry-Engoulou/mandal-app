import { useState } from "react";
import {
  Board,
  Choice,
  Ctrl,
  Grid,
  Handle,
  PALETTE,
  Panel,
  Stat,
  Verdict,
  fmt,
  linePath,
  makeScales,
} from "./controls";

/** Simulations du programme de 3ème (BEPC) : arithmétique, nombres réels,
 *  calcul, géométrie plane et solides. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

function pgcd(a: number, b: number): number {
  let x = Math.abs(Math.round(a));
  let y = Math.abs(Math.round(b));
  while (y > 0) {
    const r = x % y;
    x = y;
    y = r;
  }
  return x;
}

/* ------------------------------------------------------------------ */
/* 1. PGCD : l'algorithme d'Euclide et le carrelage                    */
/* ------------------------------------------------------------------ */

export function PgcdCarreaux() {
  const [L, setL] = useState(56);
  const [l, setL2] = useState(42);

  const d = pgcd(L, l) || 1;
  const nx = Math.round(L / d);
  const ny = Math.round(l / d);
  const total = nx * ny;
  const ppcm = (L * l) / d;

  const etapes: Array<{ a: number; b: number; q: number; r: number }> = [];
  let a = Math.max(L, l);
  let b = Math.min(L, l);
  let garde = 0;
  while (b > 0 && garde < 20) {
    const q = Math.floor(a / b);
    const r = a - b * q;
    etapes.push({ a, b, q, r });
    a = b;
    b = r;
    garde++;
  }

  const W = 460;
  const H = 300;
  const pad = 30;
  const kx = (W - 2 * pad) / L;
  const ky = (H - 2 * pad - 20) / l;
  const k = Math.min(kx, ky);
  const dessinable = total <= 900;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <rect
          x={pad}
          y={pad}
          width={L * k}
          height={l * k}
          fill={PALETTE.blue}
          opacity={0.08}
          stroke={PALETTE.blue}
          strokeWidth={2}
        />
        {dessinable
          ? Array.from({ length: nx }).map((_, i) =>
              Array.from({ length: ny }).map((__, j) => (
                <rect
                  key={`${i}-${j}`}
                  x={pad + i * d * k}
                  y={pad + j * d * k}
                  width={d * k}
                  height={d * k}
                  fill="none"
                  stroke={PALETTE.blue}
                  strokeWidth={0.7}
                  opacity={0.7}
                />
              )),
            )
          : null}
        <rect
          x={pad}
          y={pad}
          width={d * k}
          height={d * k}
          fill={PALETTE.orange}
          opacity={0.55}
          stroke={PALETTE.orange}
          strokeWidth={1.5}
        />
        <text x={pad + (L * k) / 2} y={pad + l * k + 18} textAnchor="middle" fontSize={12}>
          Longueur {L} cm
        </text>
        <text
          x={pad - 8}
          y={pad + (l * k) / 2}
          textAnchor="end"
          fontSize={12}
          transform={`rotate(-90 ${pad - 8} ${pad + (l * k) / 2})`}
        >
          {l} cm
        </text>
        {!dessinable ? (
          <text x={W / 2} y={H - 12} textAnchor="middle" fontSize={12} fill={PALETTE.red}>
            {total} carreaux : trop nombreux pour être dessinés un par un
          </text>
        ) : null}
      </Board>
      <div className="grid gap-3 sm:grid-cols-2">
        <Ctrl
          label="Longueur de la pièce (cm)"
          value={L}
          min={12}
          max={120}
          step={1}
          onChange={(v) => setL(Math.round(v))}
        />
        <Ctrl
          label="Largeur de la pièce (cm)"
          value={l}
          min={8}
          max={100}
          step={1}
          onChange={(v) => setL2(Math.round(v))}
          color={PALETTE.red}
        />
      </div>
      <Panel>
        <Stat label={`PGCD(${L} ; ${l})`} value={String(d)} color={PALETTE.orange} />
        <Stat label={`PPCM(${L} ; ${l})`} value={String(ppcm)} color={PALETTE.purple} />
        <Stat label="Côté du carreau" value={`${d} cm`} color={PALETTE.orange} />
        <Stat label="Nombre de carreaux" value={`${nx} × ${ny} = ${total}`} color={PALETTE.blue} />
      </Panel>
      <div className="rounded-xl border border-border bg-secondary/30 p-3">
        <p className="mb-1 text-xs font-semibold text-muted-foreground">
          Algorithme d'Euclide, étape par étape
        </p>
        <div className="space-y-0.5 font-mono text-xs text-foreground">
          {etapes.map((e, i) => (
            <p key={i}>
              {e.a} = {e.b} × {e.q} + {e.r}
              {e.r === 0 ? "   ← on s'arrête" : ""}
            </p>
          ))}
        </div>
        <p className="mt-1 text-xs text-muted-foreground">
          Le dernier reste non nul est {d} : c'est le PGCD.
        </p>
      </div>
      <Verdict tone={d === 1 ? "warn" : "ok"}>
        {d === 1
          ? "Ici le PGCD vaut 1 : le seul carreau carré possible mesure 1 cm de côté. Change les dimensions pour trouver un cas plus pratique."
          : `Le carreau orange mesure ${d} cm de côté. C'est le plus grand carreau carré qui remplit la pièce sans aucune coupe.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 2. Racine carrée : le côté d'un carré                               */
/* ------------------------------------------------------------------ */

export function RacineCarree() {
  const [aire, setAire] = useState(20);
  const r = Math.sqrt(aire);
  const bas = Math.floor(r);
  const haut = bas + 1;
  const exact = Number.isInteger(r);

  const W = 440;
  const H = 300;
  const pad = 34;
  const unite = (H - 2 * pad) / 8;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {Array.from({ length: 9 }).map((_, i) => (
          <g key={i} stroke={PALETTE.grid} strokeWidth={1}>
            <line x1={pad + i * unite} y1={pad} x2={pad + i * unite} y2={pad + 8 * unite} />
            <line x1={pad} y1={pad + i * unite} x2={pad + 8 * unite} y2={pad + i * unite} />
          </g>
        ))}
        <rect
          x={pad}
          y={pad + (8 - r) * unite}
          width={r * unite}
          height={r * unite}
          fill={PALETTE.blue}
          opacity={0.25}
          stroke={PALETTE.blue}
          strokeWidth={2.5}
        />
        <line
          x1={pad}
          y1={pad + 8 * unite + 14}
          x2={pad + r * unite}
          y2={pad + 8 * unite + 14}
          stroke={PALETTE.red}
          strokeWidth={2.5}
        />
        <text
          x={pad + (r * unite) / 2}
          y={pad + 8 * unite + 30}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.red}
        >
          côté = {fmt(r, 3)}
        </text>
        <text
          x={pad + (r * unite) / 2}
          y={pad + (8 - r / 2) * unite}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={PALETTE.blue}
        >
          aire = {fmt(aire, 1)}
        </text>
        <line
          x1={pad + bas * unite}
          y1={pad}
          x2={pad + bas * unite}
          y2={pad + 8 * unite}
          stroke={PALETTE.green}
          strokeWidth={2}
          strokeDasharray="5 4"
        />
        <line
          x1={pad + haut * unite}
          y1={pad}
          x2={pad + haut * unite}
          y2={pad + 8 * unite}
          stroke={PALETTE.green}
          strokeWidth={2}
          strokeDasharray="5 4"
        />
        <text
          x={pad + bas * unite}
          y={pad - 8}
          textAnchor="middle"
          fontSize={11}
          fill={PALETTE.green}
        >
          {bas}
        </text>
        <text
          x={pad + haut * unite}
          y={pad - 8}
          textAnchor="middle"
          fontSize={11}
          fill={PALETTE.green}
        >
          {haut}
        </text>
      </Board>
      <Ctrl label="Aire du carré" value={aire} min={1} max={64} step={0.5} onChange={setAire} />
      <Panel>
        <Stat label="Racine carrée" value={fmt(r, 4)} color={PALETTE.red} />
        <Stat
          label="Encadrement"
          value={exact ? "valeur exacte" : `${bas} < √${fmt(aire, 1)} < ${haut}`}
          color={PALETTE.green}
        />
      </Panel>
      <Verdict tone={exact ? "ok" : "warn"}>
        {exact
          ? `${fmt(aire, 0)} est un carré parfait : sa racine carrée, ${fmt(r, 0)}, est un nombre entier.`
          : `Aucun entier ne convient, la racine tombe entre ${bas} et ${haut}. C'est un nombre irrationnel : son écriture décimale ne s'arrête jamais.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 3. Intervalles de ℝ                                                 */
/* ------------------------------------------------------------------ */

export function Intervalles() {
  const [borneA, setA] = useState(-2);
  const [borneB, setB] = useState(3);
  const [fermeA, setFA] = useState(true);
  const [fermeB, setFB] = useState(false);
  const [x, setX] = useState(1);

  const s = makeScales(460, 170, -8, 8, -1, 1, 30);
  const a = Math.min(borneA, borneB);
  const b = Math.max(borneA, borneB);
  const gauche = fermeA ? "[" : "]";
  const droite = fermeB ? "]" : "[";
  const dedans = (x > a || (fermeA && x === a)) && (x < b || (fermeB && x === b));

  return (
    <div className="space-y-3">
      <Board width={s.width} height={s.height}>
        <rect width={s.width} height={s.height} fill="#ffffff" />
        <line
          x1={s.sx(s.xMin)}
          y1={s.sy(0)}
          x2={s.sx(s.xMax)}
          y2={s.sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.6}
        />
        {Array.from({ length: 17 }).map((_, i) => {
          const v = -8 + i;
          return (
            <g key={i}>
              <line
                x1={s.sx(v)}
                y1={s.sy(0) - 5}
                x2={s.sx(v)}
                y2={s.sy(0) + 5}
                stroke={PALETTE.slate}
                strokeWidth={1}
              />
              <text
                x={s.sx(v)}
                y={s.sy(0) + 20}
                textAnchor="middle"
                fontSize={10}
                fill={PALETTE.slate}
              >
                {v}
              </text>
            </g>
          );
        })}
        <line
          x1={s.sx(a)}
          y1={s.sy(0)}
          x2={s.sx(b)}
          y2={s.sy(0)}
          stroke={PALETTE.blue}
          strokeWidth={7}
          opacity={0.45}
        />
        {[
          { v: a, ferme: fermeA, set: setA },
          { v: b, ferme: fermeB, set: setB },
        ].map((bo, i) => (
          <g key={i}>
            <circle
              cx={s.sx(bo.v)}
              cy={s.sy(0)}
              r={7}
              fill={bo.ferme ? PALETTE.blue : "#ffffff"}
              stroke={PALETTE.blue}
              strokeWidth={2.5}
            />
          </g>
        ))}
        <Handle
          x={s.sx(borneA)}
          y={s.sy(0.45)}
          color={PALETTE.blue}
          label="a"
          onDrag={(p) => setA(clamp(Math.round(s.ux(p.x)), -8, 8))}
        />
        <Handle
          x={s.sx(borneB)}
          y={s.sy(0.45)}
          color={PALETTE.purple}
          label="b"
          onDrag={(p) => setB(clamp(Math.round(s.ux(p.x)), -8, 8))}
        />
        <g>
          <line
            x1={s.sx(x)}
            y1={s.sy(0)}
            x2={s.sx(x)}
            y2={s.sy(-0.55)}
            stroke={dedans ? PALETTE.green : PALETTE.red}
            strokeWidth={2}
            strokeDasharray="4 3"
          />
          <circle cx={s.sx(x)} cy={s.sy(0)} r={5} fill={dedans ? PALETTE.green : PALETTE.red} />
          <text
            x={s.sx(x)}
            y={s.sy(-0.75)}
            textAnchor="middle"
            fontSize={12}
            fontWeight={700}
            fill={dedans ? PALETTE.green : PALETTE.red}
          >
            x = {fmt(x, 1)}
          </text>
        </g>
      </Board>
      <div className="grid gap-3 sm:grid-cols-2">
        <Choice
          label="Borne de gauche"
          value={fermeA ? "ferme" : "ouvert"}
          onChange={(v) => setFA(v === "ferme")}
          options={[
            { value: "ferme", label: "[ a inclus" },
            { value: "ouvert", label: "] a exclu" },
          ]}
        />
        <Choice
          label="Borne de droite"
          value={fermeB ? "ferme" : "ouvert"}
          onChange={(v) => setFB(v === "ferme")}
          options={[
            { value: "ferme", label: "b inclus ]" },
            { value: "ouvert", label: "b exclu [" },
          ]}
        />
      </div>
      <Ctrl
        label="Nombre à tester : x"
        value={x}
        min={-8}
        max={8}
        step={0.5}
        onChange={setX}
        color={PALETTE.green}
      />
      <Panel>
        <Stat label="Intervalle" value={`${gauche}${a} ; ${b}${droite}`} color={PALETTE.blue} />
        <Stat
          label="Condition sur x"
          value={`${a} ${fermeA ? "≤" : "<"} x ${fermeB ? "≤" : "<"} ${b}`}
          color={PALETTE.purple}
        />
      </Panel>
      <Verdict tone={dedans ? "ok" : "bad"}>
        {dedans
          ? `${fmt(x, 1)} appartient à l'intervalle ${gauche}${a} ; ${b}${droite}.`
          : `${fmt(x, 1)} n'appartient pas à ${gauche}${a} ; ${b}${droite}. Regarde bien si la borne est un crochet fermé ou ouvert.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 4. Propriété de Thalès                                              */
/* ------------------------------------------------------------------ */

export function Thales() {
  const [t, setT] = useState(0.55);
  const [B, setB] = useState({ x: -3, y: -2.5 });
  const [C, setC] = useState({ x: 4, y: -2.5 });
  const A = { x: 0, y: 3.2 };

  const s = makeScales(440, 340, -6, 6, -4, 4, 26);
  const M = { x: A.x + t * (B.x - A.x), y: A.y + t * (B.y - A.y) };
  const N = { x: A.x + t * (C.x - A.x), y: A.y + t * (C.y - A.y) };

  const d = (p: { x: number; y: number }, q: { x: number; y: number }) =>
    Math.hypot(q.x - p.x, q.y - p.y);
  const AB = d(A, B);
  const AC = d(A, C);
  const BC = d(B, C);

  const snap = (p: { x: number; y: number }) => ({
    x: clamp(Math.round(s.ux(p.x) * 2) / 2, -5.5, 5.5),
    y: clamp(Math.round(s.uy(p.y) * 2) / 2, -3.5, 1),
  });

  return (
    <div className="space-y-3">
      <Board width={s.width} height={s.height}>
        <rect width={s.width} height={s.height} fill="#ffffff" />
        <Grid s={s} />
        <polygon
          points={`${s.sx(A.x)},${s.sy(A.y)} ${s.sx(B.x)},${s.sy(B.y)} ${s.sx(C.x)},${s.sy(C.y)}`}
          fill={PALETTE.slate}
          opacity={0.08}
          stroke={PALETTE.ink}
          strokeWidth={2}
        />
        <line
          x1={s.sx(M.x)}
          y1={s.sy(M.y)}
          x2={s.sx(N.x)}
          y2={s.sy(N.y)}
          stroke={PALETTE.red}
          strokeWidth={3}
        />
        <line
          x1={s.sx(A.x)}
          y1={s.sy(A.y)}
          x2={s.sx(M.x)}
          y2={s.sy(M.y)}
          stroke={PALETTE.blue}
          strokeWidth={4}
          opacity={0.6}
        />
        <line
          x1={s.sx(A.x)}
          y1={s.sy(A.y)}
          x2={s.sx(N.x)}
          y2={s.sy(N.y)}
          stroke={PALETTE.green}
          strokeWidth={4}
          opacity={0.6}
        />
        {[
          { p: A, nom: "A", col: PALETTE.ink },
          { p: M, nom: "M", col: PALETTE.blue },
          { p: N, nom: "N", col: PALETTE.green },
        ].map((o, i) => (
          <g key={i}>
            <circle cx={s.sx(o.p.x)} cy={s.sy(o.p.y)} r={5} fill={o.col} />
            <text
              x={s.sx(o.p.x) + 9}
              y={s.sy(o.p.y) - 7}
              fontSize={13}
              fontWeight={700}
              fill={o.col}
            >
              {o.nom}
            </text>
          </g>
        ))}
        <Handle
          x={s.sx(B.x)}
          y={s.sy(B.y)}
          color={PALETTE.purple}
          label="B"
          onDrag={(p) => setB(snap(p))}
        />
        <Handle
          x={s.sx(C.x)}
          y={s.sy(C.y)}
          color={PALETTE.orange}
          label="C"
          onDrag={(p) => setC(snap(p))}
        />
        <text
          x={(s.sx(M.x) + s.sx(N.x)) / 2}
          y={s.sy(M.y) - 10}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.red}
        >
          (MN) ∥ (BC)
        </text>
      </Board>
      <Ctrl
        label="Position de M sur [AB]"
        value={t}
        min={0.15}
        max={0.9}
        step={0.01}
        onChange={setT}
        display={`${Math.round(t * 100)} %`}
        color={PALETTE.red}
      />
      <Panel>
        <Stat label="AM / AB" value={fmt(t, 3)} color={PALETTE.blue} />
        <Stat label="AN / AC" value={fmt(t, 3)} color={PALETTE.green} />
        <Stat label="MN / BC" value={fmt(t, 3)} color={PALETTE.red} />
        <Stat label="Longueurs" value={`AB=${fmt(AB, 1)} AC=${fmt(AC, 1)} BC=${fmt(BC, 1)}`} />
      </Panel>
      <Verdict tone="ok">
        Déplace M, puis déforme le triangle en tirant B et C. Les trois rapports AM sur AB, AN sur
        AC et MN sur BC restent toujours égaux : c'est exactement la propriété de Thalès.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 5. Trigonométrie dans le triangle rectangle                         */
/* ------------------------------------------------------------------ */

export function TrigoRectangle() {
  const [deg, setDeg] = useState(35);
  const [hyp, setHyp] = useState(10);

  const a = (deg * Math.PI) / 180;
  const oppose = hyp * Math.sin(a);
  const adjacent = hyp * Math.cos(a);

  const W = 460;
  const H = 320;
  const ox = 70;
  const oy = 250;
  const k = Math.min((W - 150) / Math.max(adjacent, 1), (H - 110) / Math.max(oppose, 1), 26);

  const Bx = ox + adjacent * k;
  const By = oy;
  const Cx = Bx;
  const Cy = oy - oppose * k;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <polygon
          points={`${ox},${oy} ${Bx},${By} ${Cx},${Cy}`}
          fill={PALETTE.blue}
          opacity={0.08}
          stroke="none"
        />
        <line x1={ox} y1={oy} x2={Bx} y2={By} stroke={PALETTE.green} strokeWidth={4} />
        <line x1={Bx} y1={By} x2={Cx} y2={Cy} stroke={PALETTE.red} strokeWidth={4} />
        <line x1={ox} y1={oy} x2={Cx} y2={Cy} stroke={PALETTE.blue} strokeWidth={4} />
        <path
          d={`M${Bx - 14},${By} L${Bx - 14},${By - 14} L${Bx},${By - 14}`}
          fill="none"
          stroke={PALETTE.ink}
          strokeWidth={1.6}
        />
        <path
          d={`M${ox + 34},${oy} A34,34 0 0,0 ${ox + 34 * Math.cos(a)},${oy - 34 * Math.sin(a)}`}
          fill="none"
          stroke={PALETTE.orange}
          strokeWidth={2}
        />
        <text x={ox + 42} y={oy - 12} fontSize={13} fontWeight={700} fill={PALETTE.orange}>
          {deg}°
        </text>
        <text x={ox - 10} y={oy + 6} fontSize={14} fontWeight={700}>
          A
        </text>
        <text x={Bx + 8} y={By + 16} fontSize={14} fontWeight={700}>
          B
        </text>
        <text x={Cx + 8} y={Cy - 6} fontSize={14} fontWeight={700}>
          C
        </text>
        <text
          x={(ox + Bx) / 2}
          y={oy + 20}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.green}
        >
          adjacent = {fmt(adjacent, 2)}
        </text>
        <text x={Bx + 12} y={(By + Cy) / 2} fontSize={12} fontWeight={700} fill={PALETTE.red}>
          opposé = {fmt(oppose, 2)}
        </text>
        <text
          x={(ox + Cx) / 2 - 30}
          y={(oy + Cy) / 2 - 10}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.blue}
        >
          hypoténuse = {hyp}
        </text>
      </Board>
      <div className="grid gap-3 sm:grid-cols-2">
        <Ctrl
          label="Angle en A"
          value={deg}
          min={10}
          max={80}
          step={1}
          onChange={(v) => setDeg(Math.round(v))}
          display={`${deg}°`}
          color={PALETTE.orange}
        />
        <Ctrl label="Hypoténuse AC" value={hyp} min={4} max={14} step={0.5} onChange={setHyp} />
      </div>
      <Panel>
        <Stat
          label="cos = adjacent / hypoténuse"
          value={fmt(Math.cos(a), 3)}
          color={PALETTE.green}
        />
        <Stat label="sin = opposé / hypoténuse" value={fmt(Math.sin(a), 3)} color={PALETTE.red} />
        <Stat label="tan = opposé / adjacent" value={fmt(Math.tan(a), 3)} color={PALETTE.purple} />
        <Stat label="cos² + sin²" value={fmt(Math.cos(a) ** 2 + Math.sin(a) ** 2, 3)} />
      </Panel>
      <Verdict tone="ok">
        Retiens les trois mots : CAH, SOH, TOA. Cosinus c'est Adjacent sur Hypoténuse, Sinus c'est
        Opposé sur Hypoténuse, Tangente c'est Opposé sur Adjacent. Change l'angle et vérifie que les
        trois nombres suivent.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 6. Angles inscrits et angle au centre                               */
/* ------------------------------------------------------------------ */

export function AnglesInscrits() {
  const [degA, setDegA] = useState(200);
  const [degB, setDegB] = useState(340);
  const [degM, setDegM] = useState(80);

  const W = 440;
  const H = 340;
  const cx = 220;
  const cy = 175;
  const R = 130;

  const pt = (deg: number) => ({
    x: cx + R * Math.cos((deg * Math.PI) / 180),
    y: cy - R * Math.sin((deg * Math.PI) / 180),
  });
  // M doit rester sur le grand arc, en dehors de la corde [AB]
  const surGrandArc = (deg: number) => {
    const d = ((deg % 360) + 360) % 360;
    if (d <= degA || d >= degB) return d;
    return d - degA < degB - d ? degA - 6 : degB + 6;
  };
  const A = pt(degA);
  const B = pt(degB);
  const M = pt(surGrandArc(degM));
  const M2 = pt(surGrandArc(degM + 55));

  const angleEn = (P: { x: number; y: number }) => {
    const a1 = Math.atan2(A.y - P.y, A.x - P.x);
    const a2 = Math.atan2(B.y - P.y, B.x - P.x);
    let dd = Math.abs((a1 - a2) * (180 / Math.PI));
    if (dd > 180) dd = 360 - dd;
    return dd;
  };
  const inscrit = angleEn(M);
  const inscrit2 = angleEn(M2);
  const centre = angleEn({ x: cx, y: cy });

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <circle cx={cx} cy={cy} r={R} fill="none" stroke={PALETTE.slate} strokeWidth={2} />
        <line x1={cx} y1={cy} x2={A.x} y2={A.y} stroke={PALETTE.orange} strokeWidth={2.5} />
        <line x1={cx} y1={cy} x2={B.x} y2={B.y} stroke={PALETTE.orange} strokeWidth={2.5} />
        <line x1={M.x} y1={M.y} x2={A.x} y2={A.y} stroke={PALETTE.blue} strokeWidth={2.5} />
        <line x1={M.x} y1={M.y} x2={B.x} y2={B.y} stroke={PALETTE.blue} strokeWidth={2.5} />
        <line
          x1={M2.x}
          y1={M2.y}
          x2={A.x}
          y2={A.y}
          stroke={PALETTE.green}
          strokeWidth={1.6}
          strokeDasharray="5 4"
        />
        <line
          x1={M2.x}
          y1={M2.y}
          x2={B.x}
          y2={B.y}
          stroke={PALETTE.green}
          strokeWidth={1.6}
          strokeDasharray="5 4"
        />
        <line
          x1={A.x}
          y1={A.y}
          x2={B.x}
          y2={B.y}
          stroke={PALETTE.ink}
          strokeWidth={1.4}
          strokeDasharray="4 4"
        />
        <circle cx={cx} cy={cy} r={4} fill={PALETTE.ink} />
        <text x={cx + 8} y={cy + 16} fontSize={13} fontWeight={700}>
          O
        </text>
        {[
          { p: A, n: "A", c: PALETTE.red },
          { p: B, n: "B", c: PALETTE.red },
          { p: M2, n: "M'", c: PALETTE.green },
        ].map((o, i) => (
          <g key={i}>
            <circle cx={o.p.x} cy={o.p.y} r={5} fill={o.c} />
            <text x={o.p.x + 9} y={o.p.y - 7} fontSize={13} fontWeight={700} fill={o.c}>
              {o.n}
            </text>
          </g>
        ))}
        <Handle
          x={M.x}
          y={M.y}
          color={PALETTE.blue}
          label="M"
          onDrag={(p) => {
            const ang = (Math.atan2(cy - p.y, p.x - cx) * 180) / Math.PI;
            setDegM(surGrandArc(Math.round((ang + 360) % 360)));
          }}
        />
      </Board>
      <div className="grid gap-3 sm:grid-cols-2">
        <Ctrl
          label="Position de A"
          value={degA}
          min={180}
          max={260}
          step={1}
          onChange={(v) => setDegA(Math.round(v))}
          display={`${degA}°`}
          color={PALETTE.red}
        />
        <Ctrl
          label="Position de B"
          value={degB}
          min={280}
          max={359}
          step={1}
          onChange={(v) => setDegB(Math.round(v))}
          display={`${degB}°`}
          color={PALETTE.red}
        />
      </div>
      <Panel>
        <Stat label="Angle inscrit AMB" value={`${fmt(inscrit, 1)}°`} color={PALETTE.blue} />
        <Stat label="Angle inscrit AM'B" value={`${fmt(inscrit2, 1)}°`} color={PALETTE.green} />
        <Stat label="Angle au centre AOB" value={`${fmt(centre, 1)}°`} color={PALETTE.orange} />
        <Stat label="AOB ÷ AMB" value={fmt(centre / (inscrit || 1), 2)} color={PALETTE.purple} />
      </Panel>
      <Verdict tone={Math.abs(centre / (inscrit || 1) - 2) < 0.05 ? "ok" : "warn"}>
        Déplace M le long du cercle : l'angle inscrit ne change pas, tant que M reste du même côté
        de la corde [AB]. Et il vaut toujours la moitié de l'angle au centre.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 7. Polygones réguliers                                              */
/* ------------------------------------------------------------------ */

export function PolygonesReguliers() {
  const [n, setN] = useState(6);
  const [R, setR] = useState(4);

  const W = 420;
  const H = 320;
  const cx = 210;
  const cy = 165;
  const k = 30;
  const rpx = R * k;

  const sommets = Array.from({ length: n }).map((_, i) => {
    const ang = Math.PI / 2 + (2 * Math.PI * i) / n;
    return { x: cx + rpx * Math.cos(ang), y: cy - rpx * Math.sin(ang) };
  });
  const pts = sommets.map((p) => `${p.x.toFixed(1)},${p.y.toFixed(1)}`).join(" ");

  const angleCentre = 360 / n;
  const angleInterieur = ((n - 2) * 180) / n;
  const cote = 2 * R * Math.sin(Math.PI / n);
  const apotheme = R * Math.cos(Math.PI / n);
  const perimetre = n * cote;
  const aire = (perimetre * apotheme) / 2;

  const noms: Record<number, string> = {
    3: "triangle équilatéral",
    4: "carré",
    5: "pentagone régulier",
    6: "hexagone régulier",
    7: "heptagone régulier",
    8: "octogone régulier",
    9: "ennéagone régulier",
    10: "décagone régulier",
    11: "hendécagone régulier",
    12: "dodécagone régulier",
  };

  const s0 = sommets[0];
  const s1 = sommets[1];

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <circle cx={cx} cy={cy} r={rpx} fill="none" stroke={PALETTE.grid} strokeWidth={1.5} />
        <polygon
          points={pts}
          fill={PALETTE.blue}
          opacity={0.15}
          stroke={PALETTE.blue}
          strokeWidth={2.5}
        />
        {sommets.map((p, i) => (
          <g key={i}>
            <line
              x1={cx}
              y1={cy}
              x2={p.x}
              y2={p.y}
              stroke={PALETTE.slate}
              strokeWidth={1}
              strokeDasharray="4 3"
            />
            <circle cx={p.x} cy={p.y} r={3.5} fill={PALETTE.blue} />
          </g>
        ))}
        {s0 && s1 ? (
          <g>
            <line x1={s0.x} y1={s0.y} x2={s1.x} y2={s1.y} stroke={PALETTE.red} strokeWidth={4} />
            <line
              x1={cx}
              y1={cy}
              x2={(s0.x + s1.x) / 2}
              y2={(s0.y + s1.y) / 2}
              stroke={PALETTE.green}
              strokeWidth={2.5}
            />
          </g>
        ) : null}
        <circle cx={cx} cy={cy} r={4} fill={PALETTE.ink} />
        <text x={cx + 8} y={cy + 16} fontSize={12} fontWeight={700}>
          O
        </text>
        <text
          x={cx}
          y={H - 12}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={PALETTE.blue}
        >
          {noms[n] ?? `polygone à ${n} côtés`}
        </text>
        <text x={14} y={24} fontSize={11} fill={PALETTE.red} fontWeight={700}>
          rouge : un côté
        </text>
        <text x={14} y={40} fontSize={11} fill={PALETTE.green} fontWeight={700}>
          vert : l'apothème
        </text>
      </Board>
      <div className="grid gap-3 sm:grid-cols-2">
        <Ctrl
          label="Nombre de côtés n"
          value={n}
          min={3}
          max={12}
          step={1}
          onChange={(v) => setN(Math.round(v))}
          display={String(n)}
        />
        <Ctrl
          label="Rayon du cercle (cm)"
          value={R}
          min={2}
          max={4.5}
          step={0.1}
          onChange={setR}
          color={PALETTE.green}
        />
      </div>
      <Panel>
        <Stat
          label="Angle au centre (360 / n)"
          value={`${fmt(angleCentre, 1)}°`}
          color={PALETTE.orange}
        />
        <Stat label="Angle intérieur" value={`${fmt(angleInterieur, 1)}°`} color={PALETTE.purple} />
        <Stat label="Longueur d'un côté" value={`${fmt(cote, 2)} cm`} color={PALETTE.red} />
        <Stat label="Apothème" value={`${fmt(apotheme, 2)} cm`} color={PALETTE.green} />
        <Stat label="Périmètre" value={`${fmt(perimetre, 2)} cm`} />
        <Stat label="Aire" value={`${fmt(aire, 2)} cm²`} color={PALETTE.blue} />
      </Panel>
      <Verdict tone="ok">
        Augmente n et regarde le polygone se rapprocher du cercle. L'aire se calcule toujours de la
        même façon : périmètre multiplié par l'apothème, divisé par 2.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 8. Application linéaire et application affine                       */
/* ------------------------------------------------------------------ */

export function ApplicationAffine() {
  const [a, setA] = useState(1.5);
  const [b, setB] = useState(2);
  const [x, setX] = useState(2);

  const s = makeScales(460, 340, -6, 6, -8, 8, 28);
  const y = a * x + b;
  const lineaire = Math.abs(b) < 1e-9;

  return (
    <div className="space-y-3">
      <Board width={s.width} height={s.height}>
        <rect width={s.width} height={s.height} fill="#ffffff" />
        <Grid s={s} />
        <path d={linePath(a, b, s)} stroke={PALETTE.blue} strokeWidth={3} fill="none" />
        <circle cx={s.sx(0)} cy={s.sy(b)} r={5} fill={PALETTE.purple} />
        <text x={s.sx(0) + 10} y={s.sy(b) - 8} fontSize={12} fontWeight={700} fill={PALETTE.purple}>
          b = {fmt(b, 1)}
        </text>
        {y >= s.yMin && y <= s.yMax ? (
          <g>
            <line
              x1={s.sx(x)}
              y1={s.sy(0)}
              x2={s.sx(x)}
              y2={s.sy(y)}
              stroke={PALETTE.red}
              strokeWidth={1.8}
              strokeDasharray="5 4"
            />
            <line
              x1={s.sx(0)}
              y1={s.sy(y)}
              x2={s.sx(x)}
              y2={s.sy(y)}
              stroke={PALETTE.red}
              strokeWidth={1.8}
              strokeDasharray="5 4"
            />
            <circle cx={s.sx(x)} cy={s.sy(y)} r={6} fill={PALETTE.red} />
            <text
              x={s.sx(x) + 10}
              y={s.sy(y) - 10}
              fontSize={12}
              fontWeight={700}
              fill={PALETTE.red}
            >
              ({fmt(x, 1)} ; {fmt(y, 2)})
            </text>
          </g>
        ) : null}
      </Board>
      <div className="grid gap-3 sm:grid-cols-3">
        <Ctrl label="Coefficient a" value={a} min={-3} max={3} step={0.1} onChange={setA} />
        <Ctrl
          label="Ordonnée à l'origine b"
          value={b}
          min={-5}
          max={5}
          step={0.5}
          onChange={setB}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Antécédent x"
          value={x}
          min={-5}
          max={5}
          step={0.5}
          onChange={setX}
          color={PALETTE.red}
        />
      </div>
      <Panel>
        <Stat
          label="L'application"
          value={`f(x) = ${fmt(a, 2)}x ${b < 0 ? "−" : "+"} ${fmt(Math.abs(b), 2)}`}
          color={PALETTE.blue}
        />
        <Stat label={`Image de ${fmt(x, 1)}`} value={fmt(y, 2)} color={PALETTE.red} />
        <Stat label="f(0)" value={fmt(b, 2)} color={PALETTE.purple} />
        <Stat
          label="Sens de variation"
          value={a > 0 ? "croissante" : a < 0 ? "décroissante" : "constante"}
        />
      </Panel>
      <Verdict tone={lineaire ? "ok" : "warn"}>
        {lineaire
          ? "Avec b = 0, la droite passe par l'origine : f est une application linéaire. Doubler x double aussi f(x)."
          : "Tant que b n'est pas nul, la droite ne passe pas par l'origine : f est affine, pas linéaire. Ramène b à 0 pour voir la différence."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 9. Système de deux équations du premier degré                       */
/* ------------------------------------------------------------------ */

export function SystemeEquations() {
  const [a1, setA1] = useState(1);
  const [b1, setB1] = useState(1);
  const [c1, setC1] = useState(5);
  const [a2, setA2] = useState(2);
  const [b2, setB2] = useState(-1);
  const [c2, setC2] = useState(1);

  const s = makeScales(460, 340, -8, 8, -8, 8, 28);
  const det = a1 * b2 - a2 * b1;
  const unique = Math.abs(det) > 1e-9;
  const X = unique ? (c1 * b2 - c2 * b1) / det : Number.NaN;
  const Y = unique ? (a1 * c2 - a2 * c1) / det : Number.NaN;
  const confondues =
    !unique && Math.abs(a1 * c2 - a2 * c1) < 1e-9 && Math.abs(b1 * c2 - b2 * c1) < 1e-9;

  // ax + by = c  ->  y = (c - a x) / b  (ou droite verticale si b = 0)
  const droite = (a: number, b: number, c: number, col: string, key: string) => {
    if (Math.abs(b) < 1e-9) {
      if (Math.abs(a) < 1e-9) return null;
      const xv = c / a;
      return (
        <line
          key={key}
          x1={s.sx(xv)}
          y1={s.sy(s.yMin)}
          x2={s.sx(xv)}
          y2={s.sy(s.yMax)}
          stroke={col}
          strokeWidth={3}
        />
      );
    }
    return (
      <path key={key} d={linePath(-a / b, c / b, s)} stroke={col} strokeWidth={3} fill="none" />
    );
  };

  return (
    <div className="space-y-3">
      <Board width={s.width} height={s.height}>
        <rect width={s.width} height={s.height} fill="#ffffff" />
        <Grid s={s} />
        {droite(a1, b1, c1, PALETTE.blue, "d1")}
        {droite(a2, b2, c2, PALETTE.red, "d2")}
        {unique && X >= s.xMin && X <= s.xMax && Y >= s.yMin && Y <= s.yMax ? (
          <g>
            <circle cx={s.sx(X)} cy={s.sy(Y)} r={8} fill={PALETTE.green} opacity={0.3} />
            <circle cx={s.sx(X)} cy={s.sy(Y)} r={5} fill={PALETTE.green} />
            <text
              x={s.sx(X) + 11}
              y={s.sy(Y) - 9}
              fontSize={13}
              fontWeight={700}
              fill={PALETTE.green}
            >
              ({fmt(X, 2)} ; {fmt(Y, 2)})
            </text>
          </g>
        ) : null}
      </Board>
      <div className="grid gap-3 sm:grid-cols-3">
        <Ctrl label="a (1re équation)" value={a1} min={-5} max={5} step={1} onChange={setA1} />
        <Ctrl label="b (1re équation)" value={b1} min={-5} max={5} step={1} onChange={setB1} />
        <Ctrl label="c (1re équation)" value={c1} min={-10} max={10} step={1} onChange={setC1} />
        <Ctrl
          label="a' (2e équation)"
          value={a2}
          min={-5}
          max={5}
          step={1}
          onChange={setA2}
          color={PALETTE.red}
        />
        <Ctrl
          label="b' (2e équation)"
          value={b2}
          min={-5}
          max={5}
          step={1}
          onChange={setB2}
          color={PALETTE.red}
        />
        <Ctrl
          label="c' (2e équation)"
          value={c2}
          min={-10}
          max={10}
          step={1}
          onChange={setC2}
          color={PALETTE.red}
        />
      </div>
      <Panel>
        <Stat label="Première équation" value={`${a1}x + ${b1}y = ${c1}`} color={PALETTE.blue} />
        <Stat label="Deuxième équation" value={`${a2}x + ${b2}y = ${c2}`} color={PALETTE.red} />
        <Stat
          label="Solution"
          value={
            unique ? `x = ${fmt(X, 2)} ; y = ${fmt(Y, 2)}` : confondues ? "une infinité" : "aucune"
          }
          color={PALETTE.green}
        />
        <Stat label="ab' − a'b" value={fmt(det, 2)} color={PALETTE.purple} />
      </Panel>
      <Verdict tone={unique ? "ok" : confondues ? "warn" : "bad"}>
        {unique
          ? "Les deux droites se croisent en un seul point : ses coordonnées sont le couple solution du système."
          : confondues
            ? "Les deux droites sont confondues : tous les points conviennent, le système a une infinité de solutions."
            : "Les deux droites sont parallèles et distinctes : elles ne se croisent jamais, le système n'a pas de solution."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 10. Section d'une pyramide par un plan parallèle à la base          */
/* ------------------------------------------------------------------ */

export function SectionPyramide() {
  const [k, setK] = useState(0.6);
  const [forme, setForme] = useState<"pyramide" | "cone">("pyramide");

  const W = 440;
  const H = 340;
  const sx = 220;
  const sy = 40;
  const baseY = 280;
  const demi = 130;
  const prof = 32;

  const yk = sy + k * (baseY - sy);
  const demiK = demi * k;
  const profK = prof * k;

  const aireBase = forme === "cone" ? Math.PI * 4 : 16;
  const volBase = forme === "cone" ? (Math.PI * 4 * 9) / 3 : (16 * 9) / 3;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {forme === "pyramide" ? (
          <g>
            <polygon
              points={`${sx - demi},${baseY} ${sx + demi},${baseY} ${sx + demi - 40},${baseY - prof} ${sx - demi - 40},${baseY - prof}`}
              fill={PALETTE.slate}
              opacity={0.18}
              stroke={PALETTE.ink}
              strokeWidth={1.6}
            />
            <line
              x1={sx}
              y1={sy}
              x2={sx - demi}
              y2={baseY}
              stroke={PALETTE.ink}
              strokeWidth={1.8}
            />
            <line
              x1={sx}
              y1={sy}
              x2={sx + demi}
              y2={baseY}
              stroke={PALETTE.ink}
              strokeWidth={1.8}
            />
            <line
              x1={sx}
              y1={sy}
              x2={sx - demi - 40}
              y2={baseY - prof}
              stroke={PALETTE.ink}
              strokeWidth={1.2}
              strokeDasharray="4 3"
            />
            <line
              x1={sx}
              y1={sy}
              x2={sx + demi - 40}
              y2={baseY - prof}
              stroke={PALETTE.ink}
              strokeWidth={1.8}
            />
            <polygon
              points={`${sx - demiK},${yk} ${sx + demiK},${yk} ${sx + demiK - 40 * k},${yk - profK} ${sx - demiK - 40 * k},${yk - profK}`}
              fill={PALETTE.orange}
              opacity={0.5}
              stroke={PALETTE.orange}
              strokeWidth={2.2}
            />
          </g>
        ) : (
          <g>
            <ellipse
              cx={sx}
              cy={baseY}
              rx={demi}
              ry={prof}
              fill={PALETTE.slate}
              opacity={0.18}
              stroke={PALETTE.ink}
              strokeWidth={1.6}
            />
            <line
              x1={sx}
              y1={sy}
              x2={sx - demi}
              y2={baseY}
              stroke={PALETTE.ink}
              strokeWidth={1.8}
            />
            <line
              x1={sx}
              y1={sy}
              x2={sx + demi}
              y2={baseY}
              stroke={PALETTE.ink}
              strokeWidth={1.8}
            />
            <ellipse
              cx={sx}
              cy={yk}
              rx={demiK}
              ry={profK}
              fill={PALETTE.orange}
              opacity={0.5}
              stroke={PALETTE.orange}
              strokeWidth={2.2}
            />
          </g>
        )}
        <line
          x1={sx}
          y1={sy}
          x2={sx}
          y2={baseY}
          stroke={PALETTE.green}
          strokeWidth={1.4}
          strokeDasharray="5 4"
        />
        <circle cx={sx} cy={sy} r={4} fill={PALETTE.ink} />
        <text x={sx + 8} y={sy - 4} fontSize={13} fontWeight={700}>
          S
        </text>
        <text x={sx + demi + 6} y={yk + 4} fontSize={12} fontWeight={700} fill={PALETTE.orange}>
          section
        </text>
        <text x={sx + 8} y={(sy + yk) / 2} fontSize={12} fontWeight={700} fill={PALETTE.green}>
          k = {fmt(k, 2)}
        </text>
      </Board>
      <Choice
        value={forme}
        onChange={setForme}
        options={[
          { value: "pyramide", label: "Pyramide" },
          { value: "cone", label: "Cône de révolution" },
        ]}
      />
      <Ctrl
        label="Hauteur de la coupe (coefficient k)"
        value={k}
        min={0.15}
        max={0.95}
        step={0.01}
        onChange={setK}
        color={PALETTE.orange}
      />
      <Panel>
        <Stat label="Rapport des longueurs" value={`k = ${fmt(k, 2)}`} color={PALETTE.green} />
        <Stat label="Rapport des aires" value={`k² = ${fmt(k * k, 3)}`} color={PALETTE.blue} />
        <Stat
          label="Rapport des volumes"
          value={`k³ = ${fmt(k * k * k, 3)}`}
          color={PALETTE.purple}
        />
        <Stat
          label="Aire de la section"
          value={`${fmt(aireBase * k * k, 2)} cm² sur ${fmt(aireBase, 2)} cm²`}
          color={PALETTE.orange}
        />
        <Stat
          label="Volume de la petite pyramide"
          value={`${fmt(volBase * k * k * k, 2)} cm³ sur ${fmt(volBase, 2)} cm³`}
        />
      </Panel>
      <Verdict tone="ok">
        Le petit solide est une réduction du grand. Les longueurs sont multipliées par k, les aires
        par k au carré et les volumes par k au cube. Mets k à 0,5 : la section fait la moitié en
        longueur, le quart en aire, mais seulement le huitième en volume.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* 11. Développement et factorisation : l'aire d'un rectangle          */
/* ------------------------------------------------------------------ */

export function IdentitesRemarquables() {
  const [a, setA] = useState(4);
  const [b, setB] = useState(2);
  const [type, setType] = useState<"somme" | "difference" | "produit">("somme");

  const W = 420;
  const H = 250;
  const k = 26;
  const largeurFigure = type === "produit" ? (a + b) * k : (a + b) * k;
  const ox = Math.max(50, (W - largeurFigure) / 2);
  const oy = 28;

  const A = a * k;
  const B = b * k;

  const titre =
    type === "somme"
      ? `(a + b)² = a² + 2ab + b²`
      : type === "difference"
        ? `(a − b)² = a² − 2ab + b²`
        : `(a − b)(a + b) = a² − b²`;

  const valeur =
    type === "somme"
      ? (a + b) * (a + b)
      : type === "difference"
        ? (a - b) * (a - b)
        : (a - b) * (a + b);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {type === "somme" ? (
          <g>
            <rect
              x={ox}
              y={oy}
              width={A}
              height={A}
              fill={PALETTE.blue}
              opacity={0.3}
              stroke={PALETTE.blue}
            />
            <rect
              x={ox + A}
              y={oy}
              width={B}
              height={A}
              fill={PALETTE.orange}
              opacity={0.3}
              stroke={PALETTE.orange}
            />
            <rect
              x={ox}
              y={oy + A}
              width={A}
              height={B}
              fill={PALETTE.orange}
              opacity={0.3}
              stroke={PALETTE.orange}
            />
            <rect
              x={ox + A}
              y={oy + A}
              width={B}
              height={B}
              fill={PALETTE.green}
              opacity={0.35}
              stroke={PALETTE.green}
            />
            <text
              x={ox + A / 2}
              y={oy + A / 2 + 5}
              textAnchor="middle"
              fontSize={14}
              fontWeight={700}
              fill={PALETTE.blue}
            >
              a² = {a * a}
            </text>
            <text
              x={ox + A + B / 2}
              y={oy + A / 2}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill={PALETTE.orange}
            >
              ab
            </text>
            <text
              x={ox + A / 2}
              y={oy + A + B / 2 + 4}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill={PALETTE.orange}
            >
              ab
            </text>
            <text
              x={ox + A + B / 2}
              y={oy + A + B / 2 + 4}
              textAnchor="middle"
              fontSize={10}
              fontWeight={700}
              fill={PALETTE.green}
            >
              b²
            </text>
            <text x={ox + (A + B) / 2} y={oy + A + B + 22} textAnchor="middle" fontSize={12}>
              côté a + b = {a + b}
            </text>
          </g>
        ) : type === "difference" ? (
          <g>
            <rect
              x={ox}
              y={oy}
              width={A}
              height={A}
              fill="none"
              stroke={PALETTE.slate}
              strokeWidth={2}
              strokeDasharray="5 4"
            />
            <rect
              x={ox}
              y={oy + B}
              width={A - B}
              height={A - B}
              fill={PALETTE.blue}
              opacity={0.3}
              stroke={PALETTE.blue}
              strokeWidth={2}
            />
            <rect
              x={ox + A - B}
              y={oy}
              width={B}
              height={A}
              fill={PALETTE.red}
              opacity={0.2}
              stroke={PALETTE.red}
            />
            <rect
              x={ox}
              y={oy}
              width={A - B}
              height={B}
              fill={PALETTE.red}
              opacity={0.2}
              stroke={PALETTE.red}
            />
            <text
              x={ox + (A - B) / 2}
              y={oy + B + (A - B) / 2 + 5}
              textAnchor="middle"
              fontSize={13}
              fontWeight={700}
              fill={PALETTE.blue}
            >
              (a − b)² = {(a - b) * (a - b)}
            </text>
            <text x={ox + A / 2} y={oy + A + 22} textAnchor="middle" fontSize={12}>
              grand côté a = {a}, retrait b = {b}
            </text>
          </g>
        ) : (
          <g>
            <rect
              x={ox}
              y={oy}
              width={(a + b) * k}
              height={(a - b) * k}
              fill={PALETTE.purple}
              opacity={0.25}
              stroke={PALETTE.purple}
              strokeWidth={2}
            />
            <text
              x={ox + ((a + b) * k) / 2}
              y={oy + ((a - b) * k) / 2 + 5}
              textAnchor="middle"
              fontSize={14}
              fontWeight={700}
              fill={PALETTE.purple}
            >
              aire = {(a - b) * (a + b)}
            </text>
            <text
              x={ox + ((a + b) * k) / 2}
              y={oy + (a - b) * k + 22}
              textAnchor="middle"
              fontSize={12}
            >
              largeur a + b = {a + b}
            </text>
            <text x={ox - 10} y={oy + ((a - b) * k) / 2} textAnchor="end" fontSize={12}>
              a − b = {a - b}
            </text>
          </g>
        )}
      </Board>
      <Choice
        value={type}
        onChange={setType}
        options={[
          { value: "somme", label: "(a + b)²" },
          { value: "difference", label: "(a − b)²" },
          { value: "produit", label: "(a − b)(a + b)" },
        ]}
      />
      <div className="grid gap-3 sm:grid-cols-2">
        <Ctrl label="a" value={a} min={2} max={7} step={1} onChange={(v) => setA(Math.round(v))} />
        <Ctrl
          label="b"
          value={b}
          min={1}
          max={Math.max(1, a - 1)}
          step={1}
          onChange={(v) => setB(Math.round(v))}
          color={PALETTE.orange}
        />
      </div>
      <Panel>
        <Stat label="Identité" value={titre} color={PALETTE.blue} />
        <Stat label="Résultat avec ces valeurs" value={String(valeur)} color={PALETTE.purple} />
      </Panel>
      <Verdict tone="ok">
        {type === "somme"
          ? `Le grand carré de côté ${a + b} se découpe en quatre morceaux : le carré ${a}², deux rectangles ${a}×${b} et le petit carré ${b}². C'est pour cela qu'on écrit a² + 2ab + b², et jamais a² + b².`
          : type === "difference"
            ? `On part du carré de côté ${a} et on retire deux bandes de largeur ${b}. Comme le coin est retiré deux fois, on le rajoute : a² − 2ab + b².`
            : `Le rectangle de largeur ${a + b} et de hauteur ${a - b} a la même aire que le carré ${a}² privé du carré ${b}².`}
      </Verdict>
    </div>
  );
}
