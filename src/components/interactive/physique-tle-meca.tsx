import { useState } from "react";
import {
  Arrow,
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

/** Simulations du programme de Physique Terminale C et D — modules 1 et 2. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/** Suite pseudo-aléatoire déterministe : la figure ne bouge pas d'un rendu à l'autre. */
function bruit(i: number): number {
  const x = Math.sin(i * 12.9898) * 43758.5453;
  return x - Math.floor(x) - 0.5;
}

/* ------------------------------------------------------------------ */
/* Chapitre 1 — Justesse et fidélité                                   */
/* ------------------------------------------------------------------ */

export function JustesseFidelite() {
  const [biais, setBiais] = useState(0);
  const [dispersion, setDispersion] = useState(10);

  const W = 360;
  const H = 300;
  const cx = W / 2;
  const cy = 150;

  const tirs = Array.from({ length: 12 }, (_, i) => ({
    x: cx + biais * 2.2 + bruit(i + 1) * dispersion * 2,
    y: cy + biais * 1.1 + bruit(i + 40) * dispersion * 2,
  }));

  const moyX = tirs.reduce((a, t) => a + t.x, 0) / tirs.length;
  const moyY = tirs.reduce((a, t) => a + t.y, 0) / tirs.length;
  const ecartCentre = Math.hypot(moyX - cx, moyY - cy);
  const etendue = Math.sqrt(
    tirs.reduce((a, t) => a + (t.x - moyX) ** 2 + (t.y - moyY) ** 2, 0) / tirs.length,
  );

  const juste = ecartCentre < 14;
  const fidele = etendue < 16;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {[80, 60, 40, 20].map((r, i) => (
          <circle
            key={r}
            cx={cx}
            cy={cy}
            r={r}
            fill={i % 2 === 0 ? "#f1f5f9" : "#ffffff"}
            stroke={PALETTE.gridStrong}
            strokeWidth={1}
          />
        ))}
        <circle cx={cx} cy={cy} r={4} fill={PALETTE.slate} />
        <text x={cx} y={cy - 92} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          centre = valeur vraie
        </text>
        {tirs.map((t, i) => (
          <circle
            key={i}
            cx={t.x}
            cy={t.y}
            r={5}
            fill={PALETTE.blue}
            opacity={0.75}
            stroke="#ffffff"
            strokeWidth={1.5}
          />
        ))}
        <circle cx={moyX} cy={moyY} r={7} fill="none" stroke={PALETTE.red} strokeWidth={2.5} />
        <text
          x={cx}
          y={cy + 106}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.red}
        >
          cercle rouge : moyenne des 12 mesures
        </text>
        <text x={cx} y={H - 14} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          12 mesures du même objet
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Erreur systématique"
          value={biais}
          min={-25}
          max={25}
          step={1}
          onChange={setBiais}
          display={`${fmt(biais, 0)}`}
          color={PALETTE.red}
        />
        <Ctrl
          label="Erreurs aléatoires"
          value={dispersion}
          min={1}
          max={30}
          step={1}
          onChange={setDispersion}
          display={`${fmt(dispersion, 0)}`}
          color={PALETTE.blue}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Écart de la moyenne au centre"
          value={fmt(ecartCentre, 1)}
          color={PALETTE.red}
        />
        <Stat label="Dispersion des points" value={fmt(etendue, 1)} color={PALETTE.blue} />
      </div>

      <Verdict tone={juste && fidele ? "ok" : juste || fidele ? "warn" : "bad"}>
        {juste && fidele
          ? "Juste et fidèle, donc exact. C'est l'appareil qu'on cherche."
          : !juste && fidele
            ? "Fidèle mais pas juste : les points sont groupés, mais à côté du centre. Il y a une erreur systématique à corriger."
            : juste && !fidele
              ? "Juste mais pas fidèle : la moyenne tombe bien, mais les mesures sont dispersées. Il faut répéter davantage."
              : "Ni juste ni fidèle : il y a à la fois une erreur systématique et de fortes erreurs aléatoires."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 2 — Équations aux dimensions                               */
/* ------------------------------------------------------------------ */

type Formule = {
  value: string;
  label: string;
  expr: string;
  gauche: string;
  droite: string;
  ok: boolean;
  note: string;
};

const FORMULES: ReadonlyArray<Formule> = [
  {
    value: "ec",
    label: "Ec = ½mv²",
    expr: "E_c = ½ m v²",
    gauche: "M L² T⁻²",
    droite: "M × (L T⁻¹)² = M L² T⁻²",
    ok: true,
    note: "Homogène. Le facteur ½ est un nombre pur, il ne compte pas.",
  },
  {
    value: "pendule",
    label: "T = 2π√(ℓ/g)",
    expr: "T = 2π √(ℓ / g)",
    gauche: "T",
    droite: "√(L / (L T⁻²)) = √(T²) = T",
    ok: true,
    note: "Homogène. C'est bien la période du pendule simple.",
  },
  {
    value: "faux",
    label: "T = 2π√(g/ℓ)",
    expr: "T = 2π √(g / ℓ)",
    gauche: "T",
    droite: "√((L T⁻²) / L) = √(T⁻²) = T⁻¹",
    ok: false,
    note: "Non homogène. On obtient l'inverse d'un temps, donc une fréquence, pas une période.",
  },
  {
    value: "rc",
    label: "τ = RC",
    expr: "τ = R C",
    gauche: "T",
    droite: "(M L² T⁻³ I⁻²) × (M⁻¹ L⁻² T⁴ I²) = T",
    ok: true,
    note: "Homogène. Le produit RC est bien une durée, d'où le nom de constante de temps.",
  },
  {
    value: "pression",
    label: "p = ρ g h",
    expr: "p = ρ g h",
    gauche: "M L⁻¹ T⁻²",
    droite: "(M L⁻³) × (L T⁻²) × L = M L⁻¹ T⁻²",
    ok: true,
    note: "Homogène. C'est la pression d'une colonne de liquide.",
  },
  {
    value: "force",
    label: "F = m v²",
    expr: "F = m v²",
    gauche: "M L T⁻²",
    droite: "M × (L T⁻¹)² = M L² T⁻²",
    ok: false,
    note: "Non homogène. On trouve une énergie, pas une force. Il manque une division par une longueur.",
  },
];

export function EquationDimensions() {
  const [choix, setChoix] = useState("ec");
  const f = FORMULES.find((x) => x.value === choix) ?? FORMULES[0];
  if (!f) return null;

  return (
    <div className="space-y-3">
      <Choice
        label="Choisis une relation à tester"
        value={choix}
        options={FORMULES.map((x) => ({ value: x.value, label: x.label }))}
        onChange={setChoix}
      />

      <div className="rounded-xl border border-border bg-white p-4">
        <p className="text-center font-mono text-base font-semibold text-foreground">{f.expr}</p>
        <div className="mt-4 space-y-2 text-sm">
          <div className="flex flex-wrap items-baseline gap-2">
            <span className="text-xs text-muted-foreground">Membre de gauche</span>
            <span className="font-mono font-semibold" style={{ color: PALETTE.blue }}>
              {f.gauche}
            </span>
          </div>
          <div className="flex flex-wrap items-baseline gap-2">
            <span className="text-xs text-muted-foreground">Membre de droite</span>
            <span className="font-mono font-semibold" style={{ color: PALETTE.purple }}>
              {f.droite}
            </span>
          </div>
        </div>
      </div>

      <Verdict tone={f.ok ? "ok" : "bad"}>{f.note}</Verdict>

      <p className="text-xs text-muted-foreground">
        Rappel : une relation homogène peut quand même être fausse, car l&apos;analyse
        dimensionnelle ne contrôle jamais les coefficients numériques.
      </p>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 3 — Champ de gravitation                                   */
/* ------------------------------------------------------------------ */

export function ChampGravitation() {
  const [masse, setMasse] = useState(6); // en 10^24 kg
  const [distance, setDistance] = useState(10); // en 10^6 m

  const G = 6.67e-11;
  const M = masse * 1e24;
  const r = distance * 1e6;
  const champ = (G * M) / (r * r);

  const W = 420;
  const H = 260;
  const cx = 90;
  const cy = H / 2;
  const echelle = 300 / 25; // 25 unités de 10^6 m sur 300 px
  const px = cx + distance * echelle;
  const rayonPlanete = 14 + masse * 1.4;

  const longueurFleche = clamp(champ * 9, 14, 80);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {[5, 10, 15, 20, 25].map((d) => (
          <g key={d}>
            <circle
              cx={cx}
              cy={cy}
              r={d * echelle}
              fill="none"
              stroke={PALETTE.grid}
              strokeWidth={1}
            />
            <text
              x={cx + d * echelle}
              y={H - 8}
              textAnchor="middle"
              fontSize={9}
              fill={PALETTE.slate}
            >
              {d}
            </text>
          </g>
        ))}
        <circle cx={cx} cy={cy} r={rayonPlanete} fill={PALETTE.blue} opacity={0.85} />
        <text x={cx} y={cy + 4} textAnchor="middle" fontSize={11} fontWeight={700} fill="#ffffff">
          M
        </text>
        <line
          x1={cx + rayonPlanete + 4}
          y1={cy}
          x2={px}
          y2={cy}
          stroke={PALETTE.gridStrong}
          strokeWidth={1}
          strokeDasharray="4 4"
        />
        <Arrow x1={px} y1={cy} x2={px - longueurFleche} y2={cy} color={PALETTE.red} width={3} />
        <circle cx={px} cy={cy} r={6} fill={PALETTE.orange} stroke="#ffffff" strokeWidth={2} />
        <text
          x={px}
          y={cy - 18}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.orange}
        >
          m
        </text>
        <text
          x={px - longueurFleche - 6}
          y={cy + 20}
          textAnchor="end"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.red}
        >
          G
        </text>
        <text x={W / 2} y={18} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          distance en millions de mètres
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Masse de la planète (×10²⁴ kg)"
          value={masse}
          min={1}
          max={20}
          step={0.5}
          onChange={setMasse}
          display={fmt(masse, 1)}
        />
        <Ctrl
          label="Distance au centre (×10⁶ m)"
          value={distance}
          min={3}
          max={25}
          step={0.5}
          onChange={setDistance}
          display={fmt(distance, 1)}
          color={PALETTE.orange}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Champ de gravitation" value={`${fmt(champ, 2)} N/kg`} color={PALETTE.red} />
        <Stat
          label="Si on double la distance"
          value={`${fmt(champ / 4, 2)} N/kg`}
          color={PALETTE.slate}
        />
      </div>

      <Verdict tone="ok">
        Le champ est toujours dirigé vers la planète, et il ne dépend pas de la masse qu&apos;on y
        place. Doubler la distance le divise par quatre, car il varie en 1/r².
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 4 — Champ électrique de deux charges                       */
/* ------------------------------------------------------------------ */

export function ChampElectrique() {
  const [q1, setQ1] = useState(2);
  const [q2, setQ2] = useState(-2);
  const [sondeX, setSondeX] = useState(0);
  const [sondeY, setSondeY] = useState(1.5);

  const W = 440;
  const H = 300;
  const s = makeScales(W, H, -5, 5, -3.4, 3.4, 26);

  const A = { x: -2, y: 0 };
  const B = { x: 2, y: 0 };
  const k = 9;

  function champEn(x: number, y: number) {
    let ex = 0;
    let ey = 0;
    for (const [q, c] of [
      [q1, A],
      [q2, B],
    ] as const) {
      const dx = x - c.x;
      const dy = y - c.y;
      const d2 = dx * dx + dy * dy;
      const d = Math.sqrt(d2);
      if (d < 0.25) continue;
      const e = (k * q) / d2;
      ex += (e * dx) / d;
      ey += (e * dy) / d;
    }
    return { ex, ey };
  }

  const { ex, ey } = champEn(sondeX, sondeY);
  const norme = Math.hypot(ex, ey);
  const longueur = clamp(norme * 6, 0, 70);
  const ux = norme > 1e-9 ? ex / norme : 0;
  const uy = norme > 1e-9 ? ey / norme : 0;

  // petites flèches d'orientation réparties sur la grille
  const champs: Array<{ x: number; y: number; ux: number; uy: number }> = [];
  for (let gx = -4; gx <= 4; gx += 1.6) {
    for (let gy = -2.4; gy <= 2.4; gy += 1.6) {
      const c = champEn(gx, gy);
      const n = Math.hypot(c.ex, c.ey);
      if (n < 0.2) continue;
      champs.push({ x: gx, y: gy, ux: c.ex / n, uy: c.ey / n });
    }
  }

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={1} />
        {champs.map((c, i) => (
          <Arrow
            key={i}
            x1={s.sx(c.x)}
            y1={s.sy(c.y)}
            x2={s.sx(c.x) + c.ux * 16}
            y2={s.sy(c.y) - c.uy * 16}
            color={PALETTE.gridStrong}
            width={1.8}
          />
        ))}
        {[
          { c: A, q: q1 },
          { c: B, q: q2 },
        ].map((o, i) => (
          <g key={i}>
            <circle
              cx={s.sx(o.c.x)}
              cy={s.sy(o.c.y)}
              r={14}
              fill={o.q >= 0 ? PALETTE.red : PALETTE.blue}
            />
            <text
              x={s.sx(o.c.x)}
              y={s.sy(o.c.y) + 5}
              textAnchor="middle"
              fontSize={14}
              fontWeight={700}
              fill="#ffffff"
            >
              {o.q >= 0 ? "+" : "−"}
            </text>
          </g>
        ))}
        {longueur > 2 ? (
          <Arrow
            x1={s.sx(sondeX)}
            y1={s.sy(sondeY)}
            x2={s.sx(sondeX) + ux * longueur}
            y2={s.sy(sondeY) - uy * longueur}
            color={PALETTE.purple}
            width={3}
          />
        ) : null}
        <circle
          cx={s.sx(sondeX)}
          cy={s.sy(sondeY)}
          r={5}
          fill={PALETTE.purple}
          stroke="#ffffff"
          strokeWidth={2}
        />
        <text
          x={s.sx(sondeX) + 10}
          y={s.sy(sondeY) + 18}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.purple}
        >
          M
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Charge de gauche"
          value={q1}
          min={-4}
          max={4}
          step={0.5}
          onChange={setQ1}
          color={PALETTE.red}
        />
        <Ctrl
          label="Charge de droite"
          value={q2}
          min={-4}
          max={4}
          step={0.5}
          onChange={setQ2}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Sonde : abscisse"
          value={sondeX}
          min={-4.5}
          max={4.5}
          step={0.1}
          onChange={setSondeX}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Sonde : ordonnée"
          value={sondeY}
          min={-3}
          max={3}
          step={0.1}
          onChange={setSondeY}
          color={PALETTE.purple}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Valeur du champ en M" value={fmt(norme, 2)} color={PALETTE.purple} />
        <Stat
          label="Configuration"
          value={q1 * q2 < 0 ? "charges opposées" : q1 * q2 > 0 ? "même signe" : "une charge nulle"}
        />
      </div>

      <Verdict tone={norme < 0.05 ? "ok" : "warn"}>
        {norme < 0.05
          ? "Tu as trouvé un point où le champ est nul. Les deux contributions s'y annulent exactement."
          : "Le champ part toujours du plus et va vers le moins. Avec deux charges de même signe, cherche le point nul entre elles."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 5 — Force de Laplace                                       */
/* ------------------------------------------------------------------ */

export function ForceLaplace() {
  const [angle, setAngle] = useState(90);
  const [intensite, setIntensite] = useState(3);
  const [champ, setChamp] = useState(0.25);
  const [sens, setSens] = useState<"direct" | "inverse">("direct");

  const longueur = 0.12;
  const rad = (angle * Math.PI) / 180;
  const F = champ * intensite * longueur * Math.sin(rad) * (sens === "direct" ? 1 : -1);

  const W = 420;
  const H = 280;
  const cx = W / 2;
  const cy = 150;
  const demi = 90;

  const fx = Math.cos(rad);
  const fy = Math.sin(rad);
  const ax = cx - demi * fx;
  const ay = cy + demi * fy;
  const bx = cx + demi * fx;
  const by = cy - demi * fy;

  const normeF = Math.abs(F);
  const tailleF = clamp(normeF * 620, 0, 30);
  const entrante = F > 0;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {Array.from({ length: 7 }).map((_, i) => {
          const y = 40 + i * 33;
          return (
            <g key={i}>
              <line x1={34} y1={y} x2={W - 34} y2={y} stroke="#bfdbfe" strokeWidth={1.4} />
              <polygon
                points={`${W - 34},${y} ${W - 44},${y - 4} ${W - 44},${y + 4}`}
                fill="#bfdbfe"
              />
            </g>
          );
        })}
        <text x={40} y={26} fontSize={11} fontWeight={700} fill="#3b82f6">
          champ B
        </text>

        <line
          x1={ax}
          y1={ay}
          x2={bx}
          y2={by}
          stroke={PALETTE.slate}
          strokeWidth={7}
          strokeLinecap="round"
        />
        <Arrow
          x1={sens === "direct" ? ax : bx}
          y1={sens === "direct" ? ay : by}
          x2={sens === "direct" ? bx : ax}
          y2={sens === "direct" ? by : ay}
          color={PALETTE.orange}
          width={3}
        />
        <text
          x={W - 36}
          y={H - 12}
          textAnchor="end"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.orange}
        >
          courant I
        </text>

        {tailleF > 4 ? (
          <g>
            <circle
              cx={cx}
              cy={cy}
              r={tailleF}
              fill="#ffffff"
              stroke={PALETTE.red}
              strokeWidth={3}
            />
            {entrante ? (
              <g stroke={PALETTE.red} strokeWidth={3}>
                <line
                  x1={cx - tailleF * 0.62}
                  y1={cy - tailleF * 0.62}
                  x2={cx + tailleF * 0.62}
                  y2={cy + tailleF * 0.62}
                />
                <line
                  x1={cx + tailleF * 0.62}
                  y1={cy - tailleF * 0.62}
                  x2={cx - tailleF * 0.62}
                  y2={cy + tailleF * 0.62}
                />
              </g>
            ) : (
              <circle cx={cx} cy={cy} r={Math.max(3, tailleF * 0.26)} fill={PALETTE.red} />
            )}
            <text x={cx + 42} y={cy - 34} fontSize={12} fontWeight={700} fill={PALETTE.red}>
              F {entrante ? "entre dans l'écran" : "sort de l'écran"}
            </text>
          </g>
        ) : (
          <g>
            <circle cx={cx} cy={cy} r={9} fill="none" stroke={PALETTE.red} strokeWidth={2.5} />
            <text x={cx + 16} y={cy - 12} fontSize={12} fontWeight={700} fill={PALETTE.red}>
              F = 0
            </text>
          </g>
        )}
      </Board>

      <Panel>
        <Ctrl
          label="Angle entre le fil et B"
          value={angle}
          min={0}
          max={180}
          step={5}
          onChange={setAngle}
          display={`${fmt(angle, 0)}°`}
        />
        <Ctrl
          label="Intensité du courant"
          value={intensite}
          min={0}
          max={8}
          step={0.5}
          onChange={setIntensite}
          display={`${fmt(intensite, 1)} A`}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Champ magnétique"
          value={champ}
          min={0}
          max={0.6}
          step={0.05}
          onChange={setChamp}
          display={`${fmt(champ, 2)} T`}
        />
        <Choice
          label="Sens du courant"
          value={sens}
          options={[
            { value: "direct", label: "Vers la droite" },
            { value: "inverse", label: "Vers la gauche" },
          ]}
          onChange={setSens}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Longueur dans le champ" value="0,12 m" />
        <Stat label="Force de Laplace" value={`${fmt(normeF * 1000, 1)} mN`} color={PALETTE.red} />
      </div>

      <Verdict tone={normeF < 1e-6 ? "warn" : "ok"}>
        {normeF < 1e-6
          ? "Force nulle : le fil est dans la direction du champ, donc sin α = 0. Un fil parallèle à B ne subit rien."
          : `F = B·I·ℓ·sin α = ${fmt(champ, 2)} × ${fmt(intensite, 1)} × 0,12 × ${fmt(Math.abs(Math.sin(rad)), 2)}. La force est perpendiculaire au plan du fil et du champ, donc elle ${entrante ? "entre dans l'écran" : "sort de l'écran"}. Inverse le courant et elle se retourne.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 6 — Bilan des forces sur un plan incliné                   */
/* ------------------------------------------------------------------ */

export function LoisNewton() {
  const [angle, setAngle] = useState(30);
  const [masse, setMasse] = useState(5);
  const [mu, setMu] = useState(0);

  const g = 9.8;
  const rad = (angle * Math.PI) / 180;
  const poids = masse * g;
  const normale = poids * Math.cos(rad);
  const moteur = poids * Math.sin(rad);
  const frottMax = mu * normale;
  const glisse = moteur > frottMax;
  const frott = glisse ? frottMax : moteur;
  const acc = glisse ? (moteur - frottMax) / masse : 0;
  const angleLimite = (Math.atan(mu) * 180) / Math.PI;

  const W = 430;
  const H = 280;
  const ox = 46;
  const oy = 230;
  const largeurMax = 330;
  const hauteurMax = 180;
  const largeur = Math.min(largeurMax, hauteurMax / Math.tan(rad));
  const sommetX = ox + largeur;
  const sommetY = oy - largeur * Math.tan(rad);

  const bloc = { x: ox + (sommetX - ox) * 0.52, y: oy - (oy - sommetY) * 0.52 };
  const ech = 1.5;

  const dirX = Math.cos(rad);
  const dirY = -Math.sin(rad);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <polygon
          points={`${ox},${oy} ${sommetX},${sommetY} ${sommetX},${oy}`}
          fill="#f1f5f9"
          stroke={PALETTE.slate}
          strokeWidth={1.8}
        />
        <line x1={ox} y1={oy} x2={W - 12} y2={oy} stroke={PALETTE.axis} strokeWidth={2} />
        <text x={ox + 42} y={oy - 8} fontSize={12} fontWeight={700} fill={PALETTE.slate}>
          {fmt(angle, 0)}°
        </text>

        <rect
          x={bloc.x - 14}
          y={bloc.y - 24}
          width={28}
          height={20}
          rx={3}
          fill={PALETTE.orange}
          opacity={0.9}
          transform={`rotate(${-angle} ${bloc.x} ${bloc.y - 14})`}
        />

        <Arrow
          x1={bloc.x}
          y1={bloc.y - 14}
          x2={bloc.x}
          y2={bloc.y - 14 + poids * ech}
          color={PALETTE.red}
          width={2.6}
        />
        <text
          x={bloc.x + 6}
          y={bloc.y - 14 + poids * ech}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.red}
        >
          P
        </text>

        <Arrow
          x1={bloc.x}
          y1={bloc.y - 14}
          x2={bloc.x + normale * ech * Math.sin(rad)}
          y2={bloc.y - 14 - normale * ech * Math.cos(rad)}
          color={PALETTE.blue}
          width={2.6}
        />
        <text
          x={bloc.x + normale * ech * Math.sin(rad) + 4}
          y={bloc.y - 14 - normale * ech * Math.cos(rad) - 4}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.blue}
        >
          R
        </text>

        {frott > 0.2 ? (
          <>
            <Arrow
              x1={bloc.x}
              y1={bloc.y - 14}
              x2={bloc.x - dirX * frott * ech}
              y2={bloc.y - 14 - dirY * frott * ech}
              color={PALETTE.green}
              width={2.6}
            />
            <text
              x={bloc.x - dirX * frott * ech - 14}
              y={bloc.y - 14 - dirY * frott * ech - 6}
              fontSize={12}
              fontWeight={700}
              fill={PALETTE.green}
            >
              f
            </text>
          </>
        ) : null}
      </Board>

      <Panel>
        <Ctrl
          label="Angle du plan"
          value={angle}
          min={5}
          max={60}
          step={1}
          onChange={setAngle}
          display={`${fmt(angle, 0)}°`}
        />
        <Ctrl
          label="Masse du bloc"
          value={masse}
          min={1}
          max={20}
          step={0.5}
          onChange={setMasse}
          display={`${fmt(masse, 1)} kg`}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Coefficient de frottement"
          value={mu}
          min={0}
          max={1}
          step={0.05}
          onChange={setMu}
          color={PALETTE.green}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Force motrice m·g·sin α" value={`${fmt(moteur, 1)} N`} color={PALETTE.red} />
        <Stat
          label="Frottement maximal μ·R"
          value={`${fmt(frottMax, 1)} N`}
          color={PALETTE.green}
        />
        <Stat label="Réaction normale" value={`${fmt(normale, 1)} N`} color={PALETTE.blue} />
        <Stat label="Accélération" value={`${fmt(acc, 2)} m/s²`} />
      </div>

      <Verdict tone={glisse ? "ok" : "warn"}>
        {glisse
          ? mu === 0
            ? `Sans frottement, a = g·sin α = ${fmt(acc, 2)} m/s². Change la masse : l'accélération ne bouge pas.`
            : `Le bloc glisse, car la force motrice dépasse le frottement maximal. Il décolle au-delà de ${fmt(angleLimite, 0)}°.`
          : `Le bloc reste immobile : le frottement compense exactement la force motrice. Il se mettra à glisser au-delà de ${fmt(angleLimite, 0)}°.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 7 — Tir d'un projectile                                    */
/* ------------------------------------------------------------------ */

export function TirProjectile() {
  const [v0, setV0] = useState(20);
  const [alpha, setAlpha] = useState(45);

  const g = 10;
  const rad = (alpha * Math.PI) / 180;
  const portee = (v0 * v0 * Math.sin(2 * rad)) / g;
  const fleche = (v0 * v0 * Math.sin(rad) ** 2) / (2 * g);
  const duree = (2 * v0 * Math.sin(rad)) / g;

  const W = 440;
  const H = 280;
  const xMax = 45;
  const yMax = 24;
  const s = makeScales(W, H, 0, xMax, 0, yMax, 30);

  const traj = (x: number) => {
    const c = Math.cos(rad);
    if (Math.abs(c) < 1e-6) return NaN;
    const y = (-g / (2 * v0 * v0 * c * c)) * x * x + x * Math.tan(rad);
    return y < 0 ? NaN : y;
  };

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={5} />
        <path d={curvePath(traj, s, 400)} fill="none" stroke={PALETTE.blue} strokeWidth={2.6} />
        <Arrow
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(0) + Math.cos(rad) * v0 * 2}
          y2={s.sy(0) - Math.sin(rad) * v0 * 2}
          color={PALETTE.orange}
          width={3}
        />
        <text
          x={s.sx(0) + Math.cos(rad) * v0 * 2 + 6}
          y={s.sy(0) - Math.sin(rad) * v0 * 2}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.orange}
        >
          v₀
        </text>
        {portee <= xMax ? (
          <>
            <circle cx={s.sx(portee)} cy={s.sy(0)} r={5} fill={PALETTE.red} />
            <text
              x={s.sx(portee) - 10}
              y={s.sy(0) - 14}
              textAnchor="end"
              fontSize={11}
              fontWeight={700}
              fill={PALETTE.red}
            >
              {fmt(portee, 1)} m
            </text>
          </>
        ) : null}
        {fleche <= yMax ? (
          <>
            <line
              x1={s.sx(portee / 2)}
              y1={s.sy(0)}
              x2={s.sx(portee / 2)}
              y2={s.sy(fleche)}
              stroke={PALETTE.green}
              strokeWidth={1.4}
              strokeDasharray="5 4"
            />
            <circle cx={s.sx(portee / 2)} cy={s.sy(fleche)} r={4.5} fill={PALETTE.green} />
          </>
        ) : null}
      </Board>

      <Panel>
        <Ctrl
          label="Vitesse initiale"
          value={v0}
          min={8}
          max={25}
          step={0.5}
          onChange={setV0}
          display={`${fmt(v0, 1)} m/s`}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Angle de tir"
          value={alpha}
          min={5}
          max={85}
          step={1}
          onChange={setAlpha}
          display={`${fmt(alpha, 0)}°`}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Portée" value={`${fmt(portee, 1)} m`} color={PALETTE.red} />
        <Stat label="Flèche" value={`${fmt(fleche, 1)} m`} color={PALETTE.green} />
        <Stat label="Durée du vol" value={`${fmt(duree, 2)} s`} />
      </div>

      <Verdict tone={Math.abs(alpha - 45) < 2 ? "ok" : "warn"}>
        {Math.abs(alpha - 45) < 2
          ? "À 45°, la portée est maximale. C'est le réglage du lanceur de poids et du javelot."
          : `Essaie ${fmt(90 - alpha, 0)}° : tu obtiendras exactement la même portée. Deux angles complémentaires donnent toujours le même point de chute.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 7 — Déviation d'un électron entre deux plaques             */
/* ------------------------------------------------------------------ */

export function DeviationElectrique() {
  const [tension, setTension] = useState(200);
  const [v0, setV0] = useState(20);
  const [ecart, setEcart] = useState(4);

  const e = 1.6e-19;
  const m = 9.1e-31;
  const longueur = 0.08;
  const d = ecart / 100;
  const v = v0 * 1e6;
  const yS = (e * tension * longueur * longueur) / (2 * m * d * v * v);
  const sort = yS < d / 2;

  const W = 440;
  const H = 260;
  const gauche = 50;
  const plaqueLong = 190;
  const cy = 130;
  const demiEcran = 92;
  const echY = demiEcran / (d / 2);

  const yPix = (x: number) => {
    const yy = (e * tension * x * x) / (2 * m * d * v * v);
    return Math.min(yy * echY, demiEcran);
  };

  const pts: string[] = [];
  for (let i = 0; i <= 40; i++) {
    const x = (longueur * i) / 40;
    const px = gauche + (x / longueur) * plaqueLong;
    const py = cy + yPix(x);
    if (py > cy + demiEcran) break;
    pts.push(`${px.toFixed(1)},${py.toFixed(1)}`);
  }
  const dernier = pts[pts.length - 1];
  const avant = pts[pts.length - 2];

  let ligne = "";
  if (dernier && avant && sort) {
    const [x1, y1] = dernier.split(",").map(Number);
    const [x0, y0] = avant.split(",").map(Number);
    if (x1 !== undefined && y1 !== undefined && x0 !== undefined && y0 !== undefined) {
      const pente = (y1 - y0) / Math.max(x1 - x0, 1e-6);
      const xf = W - 28;
      const yf = Math.min(y1 + pente * (xf - x1), cy + demiEcran + 24);
      ligne = `M${x1},${y1} L${xf},${yf}`;
    }
  }

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <rect
          x={gauche}
          y={cy - demiEcran - 10}
          width={plaqueLong}
          height={10}
          fill={PALETTE.red}
        />
        <rect x={gauche} y={cy + demiEcran} width={plaqueLong} height={10} fill={PALETTE.blue} />
        <text
          x={gauche + 6}
          y={cy - demiEcran - 16}
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.red}
        >
          plaque +
        </text>
        <text
          x={gauche + 6}
          y={cy + demiEcran + 26}
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.blue}
        >
          plaque −
        </text>
        <line
          x1={gauche}
          y1={cy}
          x2={W - 20}
          y2={cy}
          stroke={PALETTE.grid}
          strokeWidth={1}
          strokeDasharray="5 5"
        />
        <line
          x1={W - 26}
          y1={cy - demiEcran - 14}
          x2={W - 26}
          y2={cy + demiEcran + 14}
          stroke={PALETTE.slate}
          strokeWidth={3}
        />
        <text
          x={W - 20}
          y={cy - demiEcran - 20}
          textAnchor="end"
          fontSize={10}
          fill={PALETTE.slate}
        >
          écran
        </text>
        <Arrow x1={14} y1={cy} x2={gauche - 4} y2={cy} color={PALETTE.orange} width={2.6} />
        <text x={12} y={cy - 10} fontSize={11} fontWeight={700} fill={PALETTE.orange}>
          e⁻
        </text>
        <polyline points={pts.join(" ")} fill="none" stroke={PALETTE.purple} strokeWidth={2.8} />
        {ligne ? (
          <path
            d={ligne}
            fill="none"
            stroke={PALETTE.purple}
            strokeWidth={2.2}
            strokeDasharray="7 4"
          />
        ) : null}
      </Board>

      <Panel>
        <Ctrl
          label="Tension entre plaques"
          value={tension}
          min={0}
          max={800}
          step={20}
          onChange={setTension}
          display={`${fmt(tension, 0)} V`}
        />
        <Ctrl
          label="Vitesse d'entrée (×10⁶ m/s)"
          value={v0}
          min={5}
          max={40}
          step={1}
          onChange={setV0}
          display={fmt(v0, 1)}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Écartement des plaques"
          value={ecart}
          min={2}
          max={8}
          step={0.5}
          onChange={setEcart}
          display={`${fmt(ecart, 1)} cm`}
          color={PALETTE.slate}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Déviation à la sortie"
          value={`${fmt(yS * 100, 2)} cm`}
          color={PALETTE.purple}
        />
        <Stat
          label="Limite à ne pas dépasser"
          value={`${fmt(ecart / 2, 2)} cm`}
          color={PALETTE.slate}
        />
      </div>

      <Verdict tone={sort ? "ok" : "bad"}>
        {sort
          ? "L'électron sort des plaques, puis file en ligne droite jusqu'à l'écran, car il n'y a plus de champ après les plaques."
          : "L'électron heurte la plaque : la déviation dépasse la demi-distance. Baisse la tension ou augmente la vitesse d'entrée."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 8 — Satellite en orbite circulaire                         */
/* ------------------------------------------------------------------ */

export function SatelliteOrbite() {
  const [altitude, setAltitude] = useState(800);

  const G = 6.67e-11;
  const MT = 5.97e24;
  const RT = 6.38e6;
  const r = RT + altitude * 1000;
  const v = Math.sqrt((G * MT) / r);
  const T = (2 * Math.PI * r) / v;
  const heures = T / 3600;
  const kepler = (T * T) / (r * r * r);
  const geo = Math.abs(heures - 23.93) < 0.6;

  const W = 400;
  const H = 300;
  const cx = W / 2;
  const cy = H / 2;
  const rTerre = 32;
  const rAff = rTerre + 26 + 84 * Math.pow(Math.min(altitude, 40000) / 40000, 0.42);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <circle
          cx={cx}
          cy={cy}
          r={rAff}
          fill="none"
          stroke={PALETTE.grid}
          strokeWidth={1.6}
          strokeDasharray="6 5"
        />
        <circle cx={cx} cy={cy} r={rTerre} fill={PALETTE.blue} opacity={0.85} />
        <text x={cx} y={cy + 4} textAnchor="middle" fontSize={11} fontWeight={700} fill="#ffffff">
          Terre
        </text>
        <circle
          cx={cx + rAff}
          cy={cy}
          r={7}
          fill={PALETTE.orange}
          stroke="#ffffff"
          strokeWidth={2}
        />
        <Arrow
          x1={cx + rAff}
          y1={cy}
          x2={cx + rAff}
          y2={cy - 34}
          color={PALETTE.green}
          width={2.6}
        />
        <text x={cx + rAff + 8} y={cy - 36} fontSize={11} fontWeight={700} fill={PALETTE.green}>
          v
        </text>
        <Arrow
          x1={cx + rAff}
          y1={cy}
          x2={cx + rAff - Math.min(24, rAff - rTerre - 6)}
          y2={cy}
          color={PALETTE.red}
          width={2.6}
        />
        <text x={cx + rAff + 6} y={cy + 22} fontSize={11} fontWeight={700} fill={PALETTE.red}>
          force
        </text>
        <text x={cx} y={H - 12} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          échelle des altitudes comprimée pour rester lisible
        </text>
      </Board>

      <Ctrl
        label="Altitude du satellite"
        value={altitude}
        min={200}
        max={40000}
        step={100}
        onChange={setAltitude}
        display={`${fmt(altitude, 0)} km`}
        color={PALETTE.orange}
      />

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Vitesse orbitale" value={`${fmt(v / 1000, 2)} km/s`} color={PALETTE.green} />
        <Stat
          label="Période"
          value={heures < 2 ? `${fmt(T / 60, 0)} min` : `${fmt(heures, 2)} h`}
          color={PALETTE.orange}
        />
        <Stat label="Rayon de l'orbite" value={`${fmt(r / 1000, 0)} km`} />
        <Stat label="T² / r³" value={`${fmt(kepler * 1e14, 3)} ×10⁻¹⁴`} color={PALETTE.purple} />
      </div>

      <Verdict tone={geo ? "ok" : "warn"}>
        {geo
          ? "Période de 24 h : c'est l'orbite géostationnaire, vers 35 800 km. Le satellite reste à la verticale du même point, à condition d'être dans le plan équatorial."
          : "Fais varier l'altitude et surveille la dernière case : T²/r³ ne bouge pas. C'est la troisième loi de Kepler. Remarque aussi que plus le satellite monte, plus il ralentit."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 9 — Vecteurs de Fresnel                                    */
/* ------------------------------------------------------------------ */

export function VecteurFresnel() {
  const [a1, setA1] = useState(3);
  const [p1, setP1] = useState(0);
  const [a2, setA2] = useState(4);
  const [p2, setP2] = useState(90);

  const r1 = (p1 * Math.PI) / 180;
  const r2 = (p2 * Math.PI) / 180;
  const sx = a1 * Math.cos(r1) + a2 * Math.cos(r2);
  const sy = a1 * Math.sin(r1) + a2 * Math.sin(r2);
  const amp = Math.hypot(sx, sy);
  const phase = amp < 1e-9 ? 0 : (Math.atan2(sy, sx) * 180) / Math.PI;
  const dephasage = ((p2 - p1 + 540) % 360) - 180;

  const W = 440;
  const H = 230;
  const cx = 110;
  const cy = H / 2;
  const ech = 13;

  const sCourbe = makeScales(W, 150, 0, 4 * Math.PI, -9, 9, 18);
  const f = (t: number) => amp * Math.cos(t + (phase * Math.PI) / 180);
  const f1 = (t: number) => a1 * Math.cos(t + r1);
  const f2 = (t: number) => a2 * Math.cos(t + r2);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <circle cx={cx} cy={cy} r={8 * ech} fill="none" stroke={PALETTE.grid} strokeWidth={1} />
        <line x1={cx - 100} y1={cy} x2={cx + 100} y2={cy} stroke={PALETTE.grid} strokeWidth={1} />
        <line x1={cx} y1={cy - 100} x2={cx} y2={cy + 100} stroke={PALETTE.grid} strokeWidth={1} />
        <Arrow
          x1={cx}
          y1={cy}
          x2={cx + a1 * Math.cos(r1) * ech}
          y2={cy - a1 * Math.sin(r1) * ech}
          color={PALETTE.blue}
          width={2.6}
        />
        <Arrow
          x1={cx}
          y1={cy}
          x2={cx + a2 * Math.cos(r2) * ech}
          y2={cy - a2 * Math.sin(r2) * ech}
          color={PALETTE.green}
          width={2.6}
        />
        {amp > 0.05 ? (
          <Arrow
            x1={cx}
            y1={cy}
            x2={cx + sx * ech}
            y2={cy - sy * ech}
            color={PALETTE.red}
            width={3.4}
          />
        ) : (
          <circle cx={cx} cy={cy} r={9} fill="none" stroke={PALETTE.red} strokeWidth={2.5} />
        )}
        <line
          x1={cx + a1 * Math.cos(r1) * ech}
          y1={cy - a1 * Math.sin(r1) * ech}
          x2={cx + sx * ech}
          y2={cy - sy * ech}
          stroke={PALETTE.green}
          strokeWidth={1.2}
          strokeDasharray="4 4"
        />
        <line
          x1={cx + a2 * Math.cos(r2) * ech}
          y1={cy - a2 * Math.sin(r2) * ech}
          x2={cx + sx * ech}
          y2={cy - sy * ech}
          stroke={PALETTE.blue}
          strokeWidth={1.2}
          strokeDasharray="4 4"
        />
        <text x={240} y={34} fontSize={12} fontWeight={700} fill={PALETTE.blue}>
          vecteur 1
        </text>
        <text x={240} y={54} fontSize={12} fontWeight={700} fill={PALETTE.green}>
          vecteur 2
        </text>
        <text x={240} y={74} fontSize={12} fontWeight={700} fill={PALETTE.red}>
          somme
        </text>
      </Board>

      <Board width={W} height={150}>
        <rect width={W} height={150} fill="#ffffff" />
        <line
          x1={18}
          y1={sCourbe.sy(0)}
          x2={W - 18}
          y2={sCourbe.sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.2}
        />
        <path
          d={curvePath(f1, sCourbe, 300)}
          fill="none"
          stroke={PALETTE.blue}
          strokeWidth={1.6}
          opacity={0.6}
        />
        <path
          d={curvePath(f2, sCourbe, 300)}
          fill="none"
          stroke={PALETTE.green}
          strokeWidth={1.6}
          opacity={0.6}
        />
        <path d={curvePath(f, sCourbe, 300)} fill="none" stroke={PALETTE.red} strokeWidth={2.8} />
      </Board>

      <Panel>
        <Ctrl
          label="Amplitude 1"
          value={a1}
          min={0}
          max={6}
          step={0.5}
          onChange={setA1}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Phase 1"
          value={p1}
          min={-180}
          max={180}
          step={5}
          onChange={setP1}
          display={`${fmt(p1, 0)}°`}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Amplitude 2"
          value={a2}
          min={0}
          max={6}
          step={0.5}
          onChange={setA2}
          color={PALETTE.green}
        />
        <Ctrl
          label="Phase 2"
          value={p2}
          min={-180}
          max={180}
          step={5}
          onChange={setP2}
          display={`${fmt(p2, 0)}°`}
          color={PALETTE.green}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Amplitude somme" value={fmt(amp, 2)} color={PALETTE.red} />
        <Stat label="Phase somme" value={`${fmt(phase, 0)}°`} color={PALETTE.red} />
        <Stat label="Déphasage" value={`${fmt(dephasage, 0)}°`} />
      </div>

      <Verdict tone={amp < 0.05 ? "ok" : "warn"}>
        {amp < 0.05
          ? "Somme nulle : les deux vecteurs sont opposés et de même longueur. Deux oscillations peuvent donc s'annuler totalement."
          : Math.abs(Math.abs(dephasage) - 180) < 6
            ? "Opposition de phase : la somme vaut la différence des amplitudes. Égalise-les pour obtenir zéro."
            : "Place les deux vecteurs en opposition de phase avec la même amplitude, et la somme disparaîtra."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 10 — Pendule élastique                                     */
/* ------------------------------------------------------------------ */

export function PenduleElastique() {
  const [masse, setMasse] = useState(0.2);
  const [raideur, setRaideur] = useState(50);
  const [amplitude, setAmplitude] = useState(5);
  const [temps, setTemps] = useState(0);

  const omega = Math.sqrt(raideur / masse);
  const T = (2 * Math.PI) / omega;
  const A = amplitude / 100;
  const x = A * Math.cos(omega * temps);
  const v = -A * omega * Math.sin(omega * temps);
  const Em = 0.5 * raideur * A * A;
  const Ec = 0.5 * masse * v * v;
  const Ep = Em - Ec;

  const W = 440;
  const H = 150;
  const mur = 30;
  const repos = 230;
  const ech = 1400;
  const bloc = repos + x * ech;

  const sC = makeScales(W, 160, 0, 3 * T, -A * 1.25, A * 1.25, 20);
  const f = (t: number) => A * Math.cos(omega * t);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <rect x={mur - 12} y={30} width={12} height={90} fill={PALETTE.slate} />
        <line x1={mur - 12} y1={120} x2={W - 20} y2={120} stroke={PALETTE.axis} strokeWidth={2} />
        {Array.from({ length: 14 }).map((_, i) => {
          const x1 = mur + ((bloc - 22 - mur) * i) / 14;
          const x2 = mur + ((bloc - 22 - mur) * (i + 1)) / 14;
          return (
            <line
              key={i}
              x1={x1}
              y1={i % 2 === 0 ? 62 : 98}
              x2={x2}
              y2={i % 2 === 0 ? 98 : 62}
              stroke={PALETTE.purple}
              strokeWidth={2}
            />
          );
        })}
        <rect x={bloc - 22} y={58} width={44} height={44} rx={5} fill={PALETTE.orange} />
        <line
          x1={repos}
          y1={44}
          x2={repos}
          y2={116}
          stroke={PALETTE.grid}
          strokeWidth={1.4}
          strokeDasharray="4 4"
        />
        <text x={repos} y={36} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          équilibre
        </text>
      </Board>

      <Board width={W} height={160}>
        <rect width={W} height={160} fill="#ffffff" />
        <line
          x1={18}
          y1={sC.sy(0)}
          x2={W - 18}
          y2={sC.sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.2}
        />
        <path d={curvePath(f, sC, 320)} fill="none" stroke={PALETTE.blue} strokeWidth={2.4} />
        {temps <= 3 * T ? (
          <circle cx={sC.sx(temps)} cy={sC.sy(x)} r={5} fill={PALETTE.red} />
        ) : null}
        <text x={W - 24} y={sC.sy(0) - 8} textAnchor="end" fontSize={10} fill={PALETTE.slate}>
          x(t)
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Masse"
          value={masse}
          min={0.05}
          max={1}
          step={0.05}
          onChange={setMasse}
          display={`${fmt(masse, 2)} kg`}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Raideur du ressort"
          value={raideur}
          min={10}
          max={200}
          step={5}
          onChange={setRaideur}
          display={`${fmt(raideur, 0)} N/m`}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Amplitude de départ"
          value={amplitude}
          min={1}
          max={12}
          step={0.5}
          onChange={setAmplitude}
          display={`${fmt(amplitude, 1)} cm`}
        />
        <Ctrl
          label="Instant observé"
          value={temps}
          min={0}
          max={3 * T}
          step={T / 60}
          onChange={setTemps}
          display={`${fmt(temps, 2)} s`}
          color={PALETTE.red}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Période propre" value={`${fmt(T, 3)} s`} color={PALETTE.blue} />
        <Stat label="Vitesse maximale" value={`${fmt(A * omega, 2)} m/s`} />
        <Stat label="Énergie cinétique" value={`${fmt(Ec * 1000, 1)} mJ`} color={PALETTE.green} />
        <Stat
          label="Énergie potentielle"
          value={`${fmt(Ep * 1000, 1)} mJ`}
          color={PALETTE.purple}
        />
      </div>

      <Verdict tone="ok">
        Change l&apos;amplitude : la période ne bouge pas, l&apos;oscillateur est isochrone. La
        somme des deux énergies reste égale à {fmt(Em * 1000, 1)} mJ à chaque instant.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 10 — Pendule simple                                        */
/* ------------------------------------------------------------------ */

export function PenduleSimple() {
  const [longueur, setLongueur] = useState(1);
  const [masse, setMasse] = useState(0.2);
  const [theta0, setTheta0] = useState(10);

  const g = 9.8;
  const T = 2 * Math.PI * Math.sqrt(longueur / g);
  const rad = (theta0 * Math.PI) / 180;
  const ecart = ((rad - Math.sin(rad)) / Math.sin(rad)) * 100;
  const petit = theta0 <= 10;

  const W = 400;
  const H = 280;
  const ox = W / 2;
  const oy = 34;
  const L = 60 + longueur * 110;
  const Laff = Math.min(L, 196);
  const bx = ox + Laff * Math.sin(rad);
  const by = oy + Laff * Math.cos(rad);
  const rBille = 8 + masse * 11;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line x1={ox - 60} y1={oy} x2={ox + 60} y2={oy} stroke={PALETTE.slate} strokeWidth={4} />
        <line
          x1={ox}
          y1={oy}
          x2={ox}
          y2={oy + Laff + 24}
          stroke={PALETTE.grid}
          strokeWidth={1.2}
          strokeDasharray="5 5"
        />
        <path
          d={`M${ox},${oy + 44} A 44 44 0 0 ${rad > 0 ? 1 : 0} ${ox + 44 * Math.sin(rad)},${oy + 44 * Math.cos(rad)}`}
          fill="none"
          stroke={PALETTE.orange}
          strokeWidth={1.6}
        />
        <text x={ox + 14} y={oy + 60} fontSize={12} fontWeight={700} fill={PALETTE.orange}>
          {fmt(theta0, 0)}°
        </text>
        <line x1={ox} y1={oy} x2={bx} y2={by} stroke={PALETTE.ink} strokeWidth={2} />
        <circle cx={bx} cy={by} r={rBille} fill={PALETTE.blue} />
        <Arrow x1={bx} y1={by} x2={bx} y2={by + 20 + masse * 50} color={PALETTE.red} width={2.4} />
        <text x={bx + 8} y={by + 30 + masse * 50} fontSize={12} fontWeight={700} fill={PALETTE.red}>
          P
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Longueur du fil"
          value={longueur}
          min={0.2}
          max={2}
          step={0.05}
          onChange={setLongueur}
          display={`${fmt(longueur, 2)} m`}
        />
        <Ctrl
          label="Masse de la bille"
          value={masse}
          min={0.05}
          max={1}
          step={0.05}
          onChange={setMasse}
          display={`${fmt(masse, 2)} kg`}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Angle de départ"
          value={theta0}
          min={2}
          max={60}
          step={1}
          onChange={setTheta0}
          display={`${fmt(theta0, 0)}°`}
          color={PALETTE.orange}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Période" value={`${fmt(T, 3)} s`} color={PALETTE.blue} />
        <Stat
          label="Écart entre θ et sin θ"
          value={`${fmt(ecart, 1)} %`}
          color={petit ? PALETTE.green : PALETTE.red}
        />
      </div>

      <Verdict tone={petit ? "ok" : "bad"}>
        {petit
          ? `Petites oscillations : sin θ ≈ θ à ${fmt(ecart, 1)} % près, donc la formule T = 2π√(ℓ/g) est valable. Change la masse : la période ne bouge pas.`
          : `À ${fmt(theta0, 0)}°, l'approximation sin θ ≈ θ s'écarte de ${fmt(ecart, 1)} %. La formule ne vaut plus, et la vraie période est un peu plus longue.`}
      </Verdict>
    </div>
  );
}
