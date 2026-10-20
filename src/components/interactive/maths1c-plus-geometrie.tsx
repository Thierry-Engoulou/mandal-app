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
  fmt,
  makeScales,
} from "./controls";

/** Simulations de géométrie et d'algèbre linéaire du programme de 1ère C. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* ch12 — Chaînes, cycles et connexité                                 */
/* ------------------------------------------------------------------ */

const VILLES = [
  { nom: "Douala", x: 70, y: 210 },
  { nom: "Yaoundé", x: 180, y: 180 },
  { nom: "Bafoussam", x: 130, y: 96 },
  { nom: "Bamenda", x: 46, y: 70 },
  { nom: "Garoua", x: 270, y: 70 },
  { nom: "Bertoua", x: 300, y: 184 },
] as const;

export function GrapheChaines() {
  const [aretes, setAretes] = useState<string[]>(["0-1", "1-2", "2-3", "0-2", "1-5"]);
  const [depart, setDepart] = useState(0);

  const cle = (i: number, j: number) => `${Math.min(i, j)}-${Math.max(i, j)}`;
  const presente = (i: number, j: number) => aretes.includes(cle(i, j));

  function basculer(i: number, j: number) {
    const k = cle(i, j);
    setAretes((a) => (a.includes(k) ? a.filter((x) => x !== k) : [...a, k]));
  }

  // parcours en largeur depuis le sommet de depart
  const atteints = new Set<number>([depart]);
  const file = [depart];
  while (file.length > 0) {
    const s = file.shift();
    if (s === undefined) break;
    for (let j = 0; j < VILLES.length; j++) {
      if (!atteints.has(j) && presente(s, j)) {
        atteints.add(j);
        file.push(j);
      }
    }
  }
  const connexe = atteints.size === VILLES.length;

  // degre de chaque sommet
  const degres = VILLES.map((_, i) =>
    VILLES.reduce((n, _v, j) => n + (i !== j && presente(i, j) ? 1 : 0), 0),
  );
  const impairs = degres.filter((d) => d % 2 === 1).length;
  const cycles = aretes.length - VILLES.length + (connexe ? 1 : 2);

  const W = 360;
  const H = 260;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {VILLES.map((v, i) =>
          VILLES.map((w, j) =>
            j > i && presente(i, j) ? (
              <line
                key={`${i}-${j}`}
                x1={v.x}
                y1={v.y}
                x2={w.x}
                y2={w.y}
                stroke={atteints.has(i) && atteints.has(j) ? PALETTE.blue : PALETTE.gridStrong}
                strokeWidth={2.6}
              />
            ) : null,
          ),
        )}
        {VILLES.map((v, i) => (
          <g key={v.nom}>
            <circle
              cx={v.x}
              cy={v.y}
              r={13}
              fill={i === depart ? PALETTE.green : atteints.has(i) ? PALETTE.blue : "#ffffff"}
              stroke={atteints.has(i) ? PALETTE.blue : PALETTE.red}
              strokeWidth={2.4}
            />
            <text
              x={v.x}
              y={v.y + 4}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill={atteints.has(i) ? "#ffffff" : PALETTE.red}
            >
              {degres[i]}
            </text>
            <text
              x={v.x}
              y={v.y - 20}
              textAnchor="middle"
              fontSize={10}
              fill={PALETTE.slate}
              stroke="#ffffff"
              strokeWidth={3}
              paintOrder="stroke"
            >
              {v.nom}
            </text>
          </g>
        ))}
      </Board>

      <div className="space-y-1">
        <p className="text-xs font-medium text-muted-foreground">Ajouter ou enlever une route</p>
        <div className="flex flex-wrap gap-1.5">
          {VILLES.map((v, i) =>
            VILLES.map((w, j) =>
              j > i ? (
                <button
                  key={`${i}-${j}`}
                  type="button"
                  onClick={() => basculer(i, j)}
                  className={
                    presente(i, j)
                      ? "rounded-lg bg-primary px-2 py-1 text-[11px] font-semibold text-primary-foreground"
                      : "rounded-lg border border-border bg-background px-2 py-1 text-[11px] text-muted-foreground"
                  }
                >
                  {v.nom.slice(0, 3)}–{w.nom.slice(0, 3)}
                </button>
              ) : null,
            ),
          )}
        </div>
      </div>

      <Ctrl
        label="Ville de départ"
        value={depart}
        min={0}
        max={VILLES.length - 1}
        step={1}
        onChange={(v) => setDepart(Math.round(v))}
        display={VILLES[Math.round(depart)]?.nom ?? ""}
        color={PALETTE.green}
      />

      <div className="grid grid-cols-3 gap-2">
        <Stat
          label="Villes atteignables"
          value={`${atteints.size} sur ${VILLES.length}`}
          color={connexe ? PALETTE.green : PALETTE.red}
        />
        <Stat label="Nombre de routes" value={String(aretes.length)} color={PALETTE.blue} />
        <Stat label="Sommets de degré impair" value={String(impairs)} color={PALETTE.purple} />
      </div>

      <Verdict tone={connexe ? "ok" : "warn"}>
        {!connexe
          ? `Depuis ${VILLES[depart]?.nom}, on ne peut rejoindre que ${atteints.size} villes : le graphe n'est pas connexe. Les villes entourées de rouge sont dans une autre composante, ajoute une route pour les relier.`
          : impairs === 0
            ? "Le graphe est connexe et tous les degrés sont pairs : il existe un circuit qui emprunte chaque route une fois et une seule, et qui revient au point de départ."
            : impairs === 2
              ? "Le graphe est connexe et exactement deux sommets ont un degré impair : on peut parcourir toutes les routes une seule fois, mais en partant de l'un de ces deux sommets et en arrivant à l'autre."
              : `Le graphe est connexe, et il contient ${Math.max(cycles, 0)} cycle(s) indépendant(s). Avec ${impairs} sommets de degré impair, aucun parcours n'emprunte chaque route une seule fois.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch14 — Les lignes de niveau                                         */
/* ------------------------------------------------------------------ */

export function LignesNiveau() {
  const [type, setType] = useState<"somme" | "rapport" | "scalaire">("somme");
  const [k, setK] = useState(20);

  const A = { x: -2, y: 0 };
  const B = { x: 2, y: 0 };

  const W = 420;
  const H = 280;
  const s = makeScales(W, H, -7, 7, -5, 5, 28);

  // MA^2 + MB^2 = k  ->  cercle de centre I, milieu de AB, de rayon r
  const I = { x: (A.x + B.x) / 2, y: (A.y + B.y) / 2 };
  const AB2 = (B.x - A.x) ** 2 + (B.y - A.y) ** 2;
  const r2Somme = k / 2 - AB2 / 4;
  const rSomme = r2Somme > 0 ? Math.sqrt(r2Somme) : 0;

  // MA / MB = k' (cercle d'Apollonius), k' pris entre 0,3 et 3
  const kp = clamp(k / 10, 0.3, 3);
  const apollonius = Math.abs(kp - 1) > 1e-6;
  const cxA = apollonius ? (A.x - kp * kp * B.x) / (1 - kp * kp) : 0;
  const rA = apollonius ? Math.abs(kp / (1 - kp * kp)) * Math.sqrt(AB2) : 0;

  // MA . MB = k  ->  cercle de centre I et de rayon sqrt(k + AB^2/4)
  const r2Scal = k / 4 + AB2 / 4;
  const rScal = r2Scal > 0 ? Math.sqrt(r2Scal) : 0;

  const unite = s.sx(1) - s.sx(0);

  return (
    <div className="space-y-3">
      <Choice
        label="Ligne de niveau"
        value={type}
        options={[
          { value: "somme", label: "MA² + MB² = k" },
          { value: "rapport", label: "MA / MB = k" },
          { value: "scalaire", label: "MA · MB = k" },
        ]}
        onChange={setType}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={1} />
        {type === "somme" && rSomme > 0 ? (
          <circle
            cx={s.sx(I.x)}
            cy={s.sy(I.y)}
            r={rSomme * unite}
            fill={PALETTE.green}
            fillOpacity={0.08}
            stroke={PALETTE.green}
            strokeWidth={2.6}
          />
        ) : null}
        {type === "rapport" && apollonius ? (
          <circle
            cx={s.sx(cxA)}
            cy={s.sy(0)}
            r={rA * unite}
            fill={PALETTE.purple}
            fillOpacity={0.08}
            stroke={PALETTE.purple}
            strokeWidth={2.6}
          />
        ) : null}
        {type === "rapport" && !apollonius ? (
          <line
            x1={s.sx(I.x)}
            y1={s.sy(-5)}
            x2={s.sx(I.x)}
            y2={s.sy(5)}
            stroke={PALETTE.purple}
            strokeWidth={2.6}
          />
        ) : null}
        {type === "scalaire" && rScal > 0 ? (
          <circle
            cx={s.sx(I.x)}
            cy={s.sy(I.y)}
            r={rScal * unite}
            fill={PALETTE.orange}
            fillOpacity={0.08}
            stroke={PALETTE.orange}
            strokeWidth={2.6}
          />
        ) : null}
        {[
          { p: A, n: "A" },
          { p: B, n: "B" },
          { p: I, n: "I" },
        ].map((o) => (
          <g key={o.n}>
            <circle cx={s.sx(o.p.x)} cy={s.sy(o.p.y)} r={5.5} fill={PALETTE.ink} />
            <text
              x={s.sx(o.p.x)}
              y={s.sy(o.p.y) - 11}
              textAnchor="middle"
              fontSize={12}
              fontWeight={700}
              fill={PALETTE.ink}
              stroke="#ffffff"
              strokeWidth={3}
              paintOrder="stroke"
            >
              {o.n}
            </text>
          </g>
        ))}
      </Board>

      <Ctrl
        label={type === "rapport" ? "Rapport k" : "Valeur de k"}
        value={k}
        min={1}
        max={40}
        step={1}
        onChange={(v) => setK(Math.round(v))}
        display={type === "rapport" ? fmt(kp, 2) : String(k)}
        color={PALETTE.orange}
      />

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Milieu I de [AB]" value={`(${fmt(I.x, 1)} ; ${fmt(I.y, 1)})`} />
        <Stat
          label="Nature de la ligne"
          value={
            type === "rapport"
              ? apollonius
                ? "cercle"
                : "médiatrice de [AB]"
              : type === "somme" && rSomme === 0
                ? "vide ou réduite à I"
                : "cercle"
          }
          color={PALETTE.green}
        />
        <Stat
          label="Rayon"
          value={
            type === "somme"
              ? fmt(rSomme, 3)
              : type === "rapport"
                ? apollonius
                  ? fmt(rA, 3)
                  : "—"
                : fmt(rScal, 3)
          }
          color={PALETTE.purple}
        />
      </div>

      <Verdict tone={type === "rapport" && !apollonius ? "warn" : "ok"}>
        {type === "somme"
          ? "L'ensemble des points M tels que MA² + MB² = k est un cercle centré sur le milieu de [AB]. Baisse k : le cercle se resserre, puis l'ensemble devient vide quand k passe sous AB²/2."
          : type === "rapport" && !apollonius
            ? "Quand le rapport vaut exactement 1, les points à égale distance de A et de B forment la médiatrice de [AB] : une droite, pas un cercle. C'est le seul cas particulier."
            : type === "rapport"
              ? "L'ensemble des points dont le rapport des distances à A et à B est constant est un cercle, appelé cercle d'Apollonius. Il n'est pas centré sur le milieu de [AB]."
              : "L'ensemble des points M tels que le produit scalaire des vecteurs MA et MB vaut k est encore un cercle de centre le milieu de [AB]. Quand k vaut zéro, c'est le cercle de diamètre [AB]."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch15 — Cocyclicité                                                  */
/* ------------------------------------------------------------------ */

export function Cocyclicite() {
  const [angleC, setAngleC] = useState(0.9);
  const [angleD, setAngleD] = useState(2.3);
  const [rayonD, setRayonD] = useState(1);

  const cx = 210;
  const cy = 150;
  const R = 96;

  const A = { x: cx - R * 0.95, y: cy + R * 0.31 };
  const B = { x: cx + R * 0.95, y: cy + R * 0.31 };
  const C = { x: cx + R * Math.cos(angleC), y: cy - R * Math.sin(angleC) };
  const D = {
    x: cx + R * rayonD * Math.cos(angleD),
    y: cy - R * rayonD * Math.sin(angleD),
  };

  function angleEn(P: { x: number; y: number }) {
    const u = { x: A.x - P.x, y: A.y - P.y };
    const v = { x: B.x - P.x, y: B.y - P.y };
    const cosv = (u.x * v.x + u.y * v.y) / (Math.hypot(u.x, u.y) * Math.hypot(v.x, v.y) || 1);
    return (Math.acos(clamp(cosv, -1, 1)) * 180) / Math.PI;
  }

  const aC = angleEn(C);
  const aD = angleEn(D);
  const surLeCercle = Math.abs(rayonD - 1) < 0.02;
  const memeAngle = Math.abs(aC - aD) < 0.6;

  const W = 420;
  const H = 300;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <circle cx={cx} cy={cy} r={R} fill="none" stroke={PALETTE.gridStrong} strokeWidth={1.6} />
        <line x1={A.x} y1={A.y} x2={B.x} y2={B.y} stroke={PALETTE.ink} strokeWidth={2.4} />
        {[
          { P: C, c: PALETTE.blue, n: "C" },
          { P: D, c: memeAngle ? PALETTE.green : PALETTE.red, n: "D" },
        ].map((o) => (
          <g key={o.n}>
            <line x1={o.P.x} y1={o.P.y} x2={A.x} y2={A.y} stroke={o.c} strokeWidth={2} />
            <line x1={o.P.x} y1={o.P.y} x2={B.x} y2={B.y} stroke={o.c} strokeWidth={2} />
            <circle cx={o.P.x} cy={o.P.y} r={6} fill={o.c} />
            <text
              x={o.P.x}
              y={o.P.y - 12}
              textAnchor="middle"
              fontSize={12}
              fontWeight={700}
              fill={o.c}
              stroke="#ffffff"
              strokeWidth={3}
              paintOrder="stroke"
            >
              {o.n}
            </text>
          </g>
        ))}
        {[
          { P: A, n: "A" },
          { P: B, n: "B" },
        ].map((o) => (
          <g key={o.n}>
            <circle cx={o.P.x} cy={o.P.y} r={5.5} fill={PALETTE.ink} />
            <text
              x={o.P.x}
              y={o.P.y + 20}
              textAnchor="middle"
              fontSize={12}
              fontWeight={700}
              fill={PALETTE.ink}
            >
              {o.n}
            </text>
          </g>
        ))}
      </Board>

      <Panel>
        <Ctrl
          label="Position de C sur le cercle"
          value={angleC}
          min={0.35}
          max={2.79}
          step={0.02}
          onChange={setAngleC}
          display={fmt(angleC, 2)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Direction de D"
          value={angleD}
          min={0.35}
          max={2.79}
          step={0.02}
          onChange={setAngleD}
          display={fmt(angleD, 2)}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Distance de D au centre"
          value={rayonD}
          min={0.5}
          max={1.5}
          step={0.02}
          onChange={setRayonD}
          display={fmt(rayonD, 2)}
          color={PALETTE.purple}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Angle en C" value={`${fmt(aC, 1)}°`} color={PALETTE.blue} />
        <Stat
          label="Angle en D"
          value={`${fmt(aD, 1)}°`}
          color={memeAngle ? PALETTE.green : PALETTE.red}
        />
        <Stat
          label="D est-il sur le cercle ?"
          value={surLeCercle ? "oui" : rayonD > 1 ? "non, dehors" : "non, dedans"}
          color={surLeCercle ? PALETTE.green : PALETTE.red}
        />
      </div>

      <Verdict tone={memeAngle ? "ok" : "warn"}>
        {memeAngle
          ? "Les deux angles sont égaux : A, B, C et D sont cocycliques. Déplace C sur le cercle, l'angle en C ne change pas — c'est la propriété de l'angle inscrit."
          : rayonD > 1
            ? "D est à l'extérieur du cercle, et l'angle en D est plus petit que celui en C. Rapproche-le du cercle pour retrouver l'égalité."
            : "D est à l'intérieur du cercle, et l'angle en D est plus grand que celui en C. C'est le critère : quatre points sont cocycliques exactement quand ils voient le même segment sous le même angle, du même côté."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch16 — La symétrie orthogonale                                      */
/* ------------------------------------------------------------------ */

export function SymetrieOrthogonale() {
  const [m, setM] = useState(0.5);
  const [p, setP] = useState(0);
  const [px, setPx] = useState(1);
  const [py, setPy] = useState(3);

  // reflexion de (px, py) par rapport a y = m x + p
  const d = (py - m * px - p) / (1 + m * m);
  const qx = px + 2 * m * d;
  const qy = py - 2 * d;
  const hx = (px + qx) / 2;
  const hy = (py + qy) / 2;

  const W = 420;
  const H = 280;
  const s = makeScales(W, H, -6, 6, -4, 5, 28);

  const triangle = [
    { x: px, y: py },
    { x: px + 1.6, y: py + 0.4 },
    { x: px + 0.6, y: py - 1.4 },
  ];
  const image = triangle.map((t) => {
    const dd = (t.y - m * t.x - p) / (1 + m * m);
    return { x: t.x + 2 * m * dd, y: t.y - 2 * dd };
  });

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={1} />
        <line
          x1={s.sx(-6)}
          y1={s.sy(m * -6 + p)}
          x2={s.sx(6)}
          y2={s.sy(m * 6 + p)}
          stroke={PALETTE.green}
          strokeWidth={2.6}
        />
        <polygon
          points={triangle.map((t) => `${s.sx(t.x)},${s.sy(t.y)}`).join(" ")}
          fill={PALETTE.blue}
          fillOpacity={0.18}
          stroke={PALETTE.blue}
          strokeWidth={2}
        />
        <polygon
          points={image.map((t) => `${s.sx(t.x)},${s.sy(t.y)}`).join(" ")}
          fill={PALETTE.purple}
          fillOpacity={0.18}
          stroke={PALETTE.purple}
          strokeWidth={2}
        />
        <line
          x1={s.sx(px)}
          y1={s.sy(py)}
          x2={s.sx(qx)}
          y2={s.sy(qy)}
          stroke={PALETTE.orange}
          strokeWidth={1.6}
          strokeDasharray="5 4"
        />
        <circle cx={s.sx(hx)} cy={s.sy(hy)} r={4} fill={PALETTE.orange} />
        <circle cx={s.sx(px)} cy={s.sy(py)} r={6} fill={PALETTE.blue} />
        <circle cx={s.sx(qx)} cy={s.sy(qy)} r={6} fill={PALETTE.purple} />
        <text
          x={s.sx(px) + 10}
          y={s.sy(py) - 8}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.blue}
          stroke="#ffffff"
          strokeWidth={3}
          paintOrder="stroke"
        >
          M
        </text>
        <text
          x={s.sx(qx) + 10}
          y={s.sy(qy) - 8}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.purple}
          stroke="#ffffff"
          strokeWidth={3}
          paintOrder="stroke"
        >
          M&apos;
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Axe : pente"
          value={m}
          min={-2}
          max={2}
          step={0.25}
          onChange={setM}
          display={fmt(m, 2)}
          color={PALETTE.green}
        />
        <Ctrl
          label="Axe : ordonnée à l'origine"
          value={p}
          min={-3}
          max={3}
          step={0.5}
          onChange={setP}
          display={fmt(p, 1)}
          color={PALETTE.green}
        />
        <Ctrl
          label="M : abscisse"
          value={px}
          min={-5}
          max={5}
          step={0.5}
          onChange={setPx}
          display={fmt(px, 1)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="M : ordonnée"
          value={py}
          min={-3}
          max={4}
          step={0.5}
          onChange={setPy}
          display={fmt(py, 1)}
          color={PALETTE.blue}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Image M′" value={`(${fmt(qx, 2)} ; ${fmt(qy, 2)})`} color={PALETTE.purple} />
        <Stat
          label="Milieu de [MM′]"
          value={`(${fmt(hx, 2)} ; ${fmt(hy, 2)})`}
          color={PALETTE.orange}
        />
        <Stat
          label="Distance M à l'axe"
          value={fmt(Math.abs(py - m * px - p) / Math.sqrt(1 + m * m), 3)}
        />
      </div>

      <Verdict tone="ok">
        Le point orange, milieu de [MM′], est toujours sur l&apos;axe, et le segment en pointillés
        lui est perpendiculaire : ce sont les deux conditions qui définissent la symétrie
        orthogonale. Remarque aussi que le triangle violet est retourné : une symétrie axiale change
        l&apos;orientation, contrairement à une rotation.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch16 — Expressions analytiques des transformations                  */
/* ------------------------------------------------------------------ */

export function TransformationAnalytique() {
  const [type, setType] = useState<"translation" | "rotation" | "homothetie">("translation");
  const [p1, setP1] = useState(2);
  const [p2, setP2] = useState(1);

  const W = 420;
  const H = 280;
  const s = makeScales(W, H, -6, 6, -4, 5, 28);

  const carre = [
    { x: 1, y: 0.5 },
    { x: 3, y: 0.5 },
    { x: 3, y: 2 },
    { x: 1, y: 2 },
  ];

  function image(t: { x: number; y: number }) {
    if (type === "translation") return { x: t.x + p1, y: t.y + p2 };
    if (type === "rotation") {
      const a = (p1 * Math.PI) / 4;
      return { x: t.x * Math.cos(a) - t.y * Math.sin(a), y: t.x * Math.sin(a) + t.y * Math.cos(a) };
    }
    return { x: p1 * t.x, y: p1 * t.y };
  }

  const images = carre.map(image);
  const ecriture =
    type === "translation"
      ? `x′ = x + ${fmt(p1, 1)}   et   y′ = y + ${fmt(p2, 1)}`
      : type === "rotation"
        ? `x′ = x cos θ − y sin θ   et   y′ = x sin θ + y cos θ,  avec θ = ${fmt((p1 * 180) / 4, 0)}°`
        : `x′ = ${fmt(p1, 2)} x   et   y′ = ${fmt(p1, 2)} y`;

  return (
    <div className="space-y-3">
      <Choice
        label="Transformation"
        value={type}
        options={[
          { value: "translation", label: "Translation" },
          { value: "rotation", label: "Rotation de centre O" },
          { value: "homothetie", label: "Homothétie de centre O" },
        ]}
        onChange={setType}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={1} />
        <polygon
          points={carre.map((t) => `${s.sx(t.x)},${s.sy(t.y)}`).join(" ")}
          fill={PALETTE.blue}
          fillOpacity={0.18}
          stroke={PALETTE.blue}
          strokeWidth={2.2}
        />
        <polygon
          points={images.map((t) => `${s.sx(t.x)},${s.sy(t.y)}`).join(" ")}
          fill={PALETTE.purple}
          fillOpacity={0.18}
          stroke={PALETTE.purple}
          strokeWidth={2.2}
        />
        {carre.map((t, i) => {
          const im = images[i];
          if (!im) return null;
          return (
            <Arrow
              key={i}
              x1={s.sx(t.x)}
              y1={s.sy(t.y)}
              x2={s.sx(im.x)}
              y2={s.sy(im.y)}
              color={PALETTE.orange}
              width={1.3}
              dashed
            />
          );
        })}
        {type !== "translation" ? (
          <circle cx={s.sx(0)} cy={s.sy(0)} r={5} fill={PALETTE.green} />
        ) : null}
      </Board>

      <Panel>
        <Ctrl
          label={
            type === "translation"
              ? "Déplacement horizontal"
              : type === "rotation"
                ? "Angle, en huitièmes de tour"
                : "Rapport k"
          }
          value={p1}
          min={type === "homothetie" ? -2 : -4}
          max={type === "homothetie" ? 2 : 4}
          step={type === "homothetie" ? 0.25 : 1}
          onChange={(v) => setP1(type === "homothetie" ? v : Math.round(v))}
          display={type === "rotation" ? `${fmt((p1 * 180) / 4, 0)}°` : fmt(p1, 2)}
          color={PALETTE.purple}
        />
        {type === "translation" ? (
          <Ctrl
            label="Déplacement vertical"
            value={p2}
            min={-4}
            max={4}
            step={1}
            onChange={(v) => setP2(Math.round(v))}
            display={fmt(p2, 1)}
            color={PALETTE.purple}
          />
        ) : null}
      </Panel>

      <div className="rounded-xl border border-border bg-white p-3 text-center">
        <p className="font-mono text-sm font-semibold text-foreground">{ecriture}</p>
      </div>

      <div className="grid grid-cols-3 gap-2">
        <Stat
          label="Les longueurs sont-elles gardées ?"
          value={type === "homothetie" ? `multipliées par ${fmt(Math.abs(p1), 2)}` : "oui"}
          color={type === "homothetie" ? PALETTE.orange : PALETTE.green}
        />
        <Stat
          label="Points fixes"
          value={
            type === "translation"
              ? p1 === 0 && p2 === 0
                ? "tout le plan"
                : "aucun"
              : "le centre O"
          }
        />
        <Stat
          label="Orientation"
          value={type === "homothetie" && p1 < 0 ? "retournée" : "conservée"}
        />
      </div>

      <Verdict tone="ok">
        {type === "translation"
          ? "Toutes les flèches orange sont parallèles et de même longueur : c'est la signature d'une translation. L'expression analytique ajoute simplement une constante à chaque coordonnée."
          : type === "rotation"
            ? "Chaque point tourne autour de l'origine en gardant sa distance au centre. Les formules font intervenir le cosinus et le sinus de l'angle, et elles conservent toutes les longueurs."
            : "Chaque point s'éloigne ou se rapproche de l'origine dans un rapport constant. Un rapport négatif envoie la figure de l'autre côté du centre, et un rapport de valeur absolue 1 conserve les longueurs."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch18 — Les opérations sur les matrices                              */
/* ------------------------------------------------------------------ */

export function MatriceOperations() {
  const [operation, setOperation] = useState<"somme" | "produit" | "determinant">("somme");
  const [a11, setA11] = useState(2);
  const [a12, setA12] = useState(1);
  const [a21, setA21] = useState(0);
  const [a22, setA22] = useState(3);
  const [b11, setB11] = useState(1);
  const [b12, setB12] = useState(-1);
  const [b21, setB21] = useState(2);
  const [b22, setB22] = useState(1);

  const A: number[][] = [
    [a11, a12],
    [a21, a22],
  ];
  const B: number[][] = [
    [b11, b12],
    [b21, b22],
  ];

  const val = (M: number[][], i: number, j: number) => M[i]?.[j] ?? 0;

  let R: number[][] = [
    [0, 0],
    [0, 0],
  ];
  if (operation === "somme") {
    R = [
      [a11 + b11, a12 + b12],
      [a21 + b21, a22 + b22],
    ];
  } else {
    R = [
      [a11 * b11 + a12 * b21, a11 * b12 + a12 * b22],
      [a21 * b11 + a22 * b21, a21 * b12 + a22 * b22],
    ];
  }
  const BA: number[][] = [
    [b11 * a11 + b12 * a21, b11 * a12 + b12 * a22],
    [b21 * a11 + b22 * a21, b21 * a12 + b22 * a22],
  ];
  const commute =
    Math.abs(val(R, 0, 0) - val(BA, 0, 0)) < 1e-9 &&
    Math.abs(val(R, 0, 1) - val(BA, 0, 1)) < 1e-9 &&
    Math.abs(val(R, 1, 0) - val(BA, 1, 0)) < 1e-9 &&
    Math.abs(val(R, 1, 1) - val(BA, 1, 1)) < 1e-9;

  const detA = a11 * a22 - a12 * a21;

  function Matrice({ M, couleur, titre }: { M: number[][]; couleur: string; titre: string }) {
    return (
      <div className="text-center">
        <p className="mb-1 text-[11px] font-medium text-muted-foreground">{titre}</p>
        <div
          className="inline-grid grid-cols-2 gap-1 rounded-lg border-2 px-2 py-1.5"
          style={{ borderColor: couleur }}
        >
          {[0, 1].map((i) =>
            [0, 1].map((j) => (
              <span
                key={`${i}${j}`}
                className="inline-flex h-7 w-10 items-center justify-center font-mono text-sm font-semibold"
                style={{ color: couleur }}
              >
                {fmt(val(M, i, j), 2)}
              </span>
            )),
          )}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-3">
      <Choice
        label="Opération"
        value={operation}
        options={[
          { value: "somme", label: "A + B" },
          { value: "produit", label: "A × B" },
          { value: "determinant", label: "Déterminant de A" },
        ]}
        onChange={setOperation}
      />

      <div className="flex flex-wrap items-center justify-center gap-4 rounded-xl border border-border bg-white p-3">
        <Matrice M={A} couleur={PALETTE.blue} titre="A" />
        {operation !== "determinant" ? (
          <>
            <span className="text-xl text-muted-foreground">
              {operation === "somme" ? "+" : "×"}
            </span>
            <Matrice M={B} couleur={PALETTE.purple} titre="B" />
            <span className="text-xl text-muted-foreground">=</span>
            <Matrice
              M={R}
              couleur={PALETTE.green}
              titre={operation === "somme" ? "A + B" : "A × B"}
            />
          </>
        ) : (
          <div className="text-center">
            <p className="mb-1 text-[11px] font-medium text-muted-foreground">
              det A = a₁₁ a₂₂ − a₁₂ a₂₁
            </p>
            <p
              className="font-mono text-lg font-bold"
              style={{ color: detA === 0 ? PALETTE.red : PALETTE.green }}
            >
              {fmt(a11, 2)} × {fmt(a22, 2)} − {fmt(a12, 2)} × {fmt(a21, 2)} = {fmt(detA, 2)}
            </p>
          </div>
        )}
      </div>

      <Panel>
        <Ctrl
          label="A : ligne 1, colonne 1"
          value={a11}
          min={-4}
          max={4}
          step={1}
          onChange={(v) => setA11(Math.round(v))}
          display={String(a11)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="A : ligne 1, colonne 2"
          value={a12}
          min={-4}
          max={4}
          step={1}
          onChange={(v) => setA12(Math.round(v))}
          display={String(a12)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="A : ligne 2, colonne 1"
          value={a21}
          min={-4}
          max={4}
          step={1}
          onChange={(v) => setA21(Math.round(v))}
          display={String(a21)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="A : ligne 2, colonne 2"
          value={a22}
          min={-4}
          max={4}
          step={1}
          onChange={(v) => setA22(Math.round(v))}
          display={String(a22)}
          color={PALETTE.blue}
        />
        {operation !== "determinant" ? (
          <>
            <Ctrl
              label="B : ligne 1, colonne 1"
              value={b11}
              min={-4}
              max={4}
              step={1}
              onChange={(v) => setB11(Math.round(v))}
              display={String(b11)}
              color={PALETTE.purple}
            />
            <Ctrl
              label="B : ligne 1, colonne 2"
              value={b12}
              min={-4}
              max={4}
              step={1}
              onChange={(v) => setB12(Math.round(v))}
              display={String(b12)}
              color={PALETTE.purple}
            />
            <Ctrl
              label="B : ligne 2, colonne 1"
              value={b21}
              min={-4}
              max={4}
              step={1}
              onChange={(v) => setB21(Math.round(v))}
              display={String(b21)}
              color={PALETTE.purple}
            />
            <Ctrl
              label="B : ligne 2, colonne 2"
              value={b22}
              min={-4}
              max={4}
              step={1}
              onChange={(v) => setB22(Math.round(v))}
              display={String(b22)}
              color={PALETTE.purple}
            />
          </>
        ) : null}
      </Panel>

      <Verdict tone={operation === "determinant" && detA === 0 ? "bad" : "ok"}>
        {operation === "somme"
          ? "Pour additionner, on ajoute les coefficients un à un, à la même place. Les deux matrices doivent avoir exactement le même format."
          : operation === "produit"
            ? commute
              ? "Ici A × B et B × A donnent le même résultat, mais c'est un hasard : change un coefficient et l'égalité tombe. La multiplication des matrices n'est pas commutative."
              : "Chaque coefficient du produit se calcule ligne par colonne. Vérifie en calculant B × A : tu n'obtiendras pas la même matrice, car la multiplication des matrices n'est pas commutative."
            : detA === 0
              ? "Le déterminant est nul : la matrice n'est pas inversible, et le système linéaire associé n'a pas de solution unique."
              : "Le déterminant n'est pas nul : la matrice est inversible, et le système linéaire associé admet une solution unique."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch18 — Une application linéaire et sa matrice                       */
/* ------------------------------------------------------------------ */

export function ApplicationLineaire() {
  const [a11, setA11] = useState(1);
  const [a12, setA12] = useState(1);
  const [a21, setA21] = useState(0);
  const [a22, setA22] = useState(1);
  const [ux, setUx] = useState(2);
  const [uy, setUy] = useState(1);

  const vx = a11 * ux + a12 * uy;
  const vy = a21 * ux + a22 * uy;
  const det = a11 * a22 - a12 * a21;

  const e1 = { x: a11, y: a21 };
  const e2 = { x: a12, y: a22 };

  const W = 420;
  const H = 300;
  const s = makeScales(W, H, -5, 5, -4, 4, 28);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={1} />
        <polygon
          points={[
            `${s.sx(0)},${s.sy(0)}`,
            `${s.sx(e1.x)},${s.sy(e1.y)}`,
            `${s.sx(e1.x + e2.x)},${s.sy(e1.y + e2.y)}`,
            `${s.sx(e2.x)},${s.sy(e2.y)}`,
          ].join(" ")}
          fill={PALETTE.green}
          fillOpacity={0.12}
          stroke={PALETTE.green}
          strokeWidth={1.6}
        />
        <Arrow
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(e1.x)}
          y2={s.sy(e1.y)}
          color={PALETTE.green}
          width={2.2}
        />
        <Arrow
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(e2.x)}
          y2={s.sy(e2.y)}
          color={PALETTE.green}
          width={2.2}
        />
        <Arrow
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(ux)}
          y2={s.sy(uy)}
          color={PALETTE.blue}
          width={3}
        />
        <Arrow
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(clamp(vx, -5, 5))}
          y2={s.sy(clamp(vy, -4, 4))}
          color={PALETTE.purple}
          width={3}
        />
        <text
          x={s.sx(ux) + 10}
          y={s.sy(uy) - 6}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.blue}
          stroke="#ffffff"
          strokeWidth={3}
          paintOrder="stroke"
        >
          u
        </text>
        <text
          x={s.sx(clamp(vx, -5, 5)) + 10}
          y={s.sy(clamp(vy, -4, 4)) - 6}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.purple}
          stroke="#ffffff"
          strokeWidth={3}
          paintOrder="stroke"
        >
          f(u)
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Matrice : ligne 1, colonne 1"
          value={a11}
          min={-3}
          max={3}
          step={0.5}
          onChange={setA11}
          display={fmt(a11, 1)}
          color={PALETTE.green}
        />
        <Ctrl
          label="Matrice : ligne 1, colonne 2"
          value={a12}
          min={-3}
          max={3}
          step={0.5}
          onChange={setA12}
          display={fmt(a12, 1)}
          color={PALETTE.green}
        />
        <Ctrl
          label="Matrice : ligne 2, colonne 1"
          value={a21}
          min={-3}
          max={3}
          step={0.5}
          onChange={setA21}
          display={fmt(a21, 1)}
          color={PALETTE.green}
        />
        <Ctrl
          label="Matrice : ligne 2, colonne 2"
          value={a22}
          min={-3}
          max={3}
          step={0.5}
          onChange={setA22}
          display={fmt(a22, 1)}
          color={PALETTE.green}
        />
        <Ctrl
          label="Vecteur u : abscisse"
          value={ux}
          min={-4}
          max={4}
          step={0.5}
          onChange={setUx}
          display={fmt(ux, 1)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Vecteur u : ordonnée"
          value={uy}
          min={-3}
          max={3}
          step={0.5}
          onChange={setUy}
          display={fmt(uy, 1)}
          color={PALETTE.blue}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="f(u)" value={`(${fmt(vx, 2)} ; ${fmt(vy, 2)})`} color={PALETTE.purple} />
        <Stat
          label="Déterminant"
          value={fmt(det, 2)}
          color={Math.abs(det) < 1e-9 ? PALETTE.red : PALETTE.green}
        />
        <Stat
          label="Aire du parallélogramme vert"
          value={fmt(Math.abs(det), 2)}
          color={PALETTE.green}
        />
      </div>

      <Verdict tone={Math.abs(det) < 1e-9 ? "bad" : "ok"}>
        {Math.abs(det) < 1e-9
          ? "Le déterminant est nul : les deux colonnes de la matrice sont colinéaires, le parallélogramme s'aplatit, et toute image est écrasée sur une seule droite. L'application n'est pas bijective."
          : "Les deux flèches vertes sont les images des vecteurs de base : ce sont exactement les colonnes de la matrice. Le déterminant mesure l'aire du parallélogramme qu'elles forment, c'est-à-dire le facteur d'agrandissement des aires."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch20 — Représentation paramétrique d'une droite de l'espace         */
/* ------------------------------------------------------------------ */

/** Projection isométrique simple d'un point de l'espace sur le plan de l'écran. */
function iso(x: number, y: number, z: number, ox: number, oy: number, u: number) {
  return {
    X: ox + (x - y) * u * 0.87,
    Y: oy - z * u + (x + y) * u * 0.5,
  };
}

function Repere3D({ ox, oy, u, taille }: { ox: number; oy: number; u: number; taille: number }) {
  const O = iso(0, 0, 0, ox, oy, u);
  const X = iso(taille, 0, 0, ox, oy, u);
  const Y = iso(0, taille, 0, ox, oy, u);
  const Z = iso(0, 0, taille, ox, oy, u);
  return (
    <g>
      <Arrow x1={O.X} y1={O.Y} x2={X.X} y2={X.Y} color={PALETTE.slate} width={1.4} />
      <Arrow x1={O.X} y1={O.Y} x2={Y.X} y2={Y.Y} color={PALETTE.slate} width={1.4} />
      <Arrow x1={O.X} y1={O.Y} x2={Z.X} y2={Z.Y} color={PALETTE.slate} width={1.4} />
      <text x={X.X + 6} y={X.Y + 4} fontSize={11} fill={PALETTE.slate}>
        x
      </text>
      <text x={Y.X - 10} y={Y.Y + 10} fontSize={11} fill={PALETTE.slate}>
        y
      </text>
      <text x={Z.X - 4} y={Z.Y - 8} fontSize={11} fill={PALETTE.slate}>
        z
      </text>
    </g>
  );
}

export function DroiteParametrique() {
  const [dx, setDx] = useState(1.2);
  const [dy, setDy] = useState(-0.6);
  const [dz, setDz] = useState(0.8);
  const [t, setT] = useState(1.4);

  const A = { x: 0.5, y: 0.5, z: 0.5 };
  const W = 400;
  const H = 280;
  const ox = 180;
  const oy = 160;
  const u = 36;

  const pointDe = (s0: number) => ({
    x: A.x + s0 * dx,
    y: A.y + s0 * dy,
    z: A.z + s0 * dz,
  });
  const M = pointDe(t);
  const P0 = pointDe(-1.8);
  const P1 = pointDe(2.8);
  const e0 = iso(P0.x, P0.y, P0.z, ox, oy, u);
  const e1 = iso(P1.x, P1.y, P1.z, ox, oy, u);
  const pA = iso(A.x, A.y, A.z, ox, oy, u);
  const pM = iso(M.x, M.y, M.z, ox, oy, u);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Repere3D ox={ox} oy={oy} u={u} taille={3} />
        <line x1={e0.X} y1={e0.Y} x2={e1.X} y2={e1.Y} stroke={PALETTE.blue} strokeWidth={2.6} />
        <Arrow
          x1={pA.X}
          y1={pA.Y}
          x2={iso(A.x + dx, A.y + dy, A.z + dz, ox, oy, u).X}
          y2={iso(A.x + dx, A.y + dy, A.z + dz, ox, oy, u).Y}
          color={PALETTE.green}
          width={2.4}
        />
        <circle cx={pA.X} cy={pA.Y} r={6} fill={PALETTE.ink} />
        <text x={pA.X - 14} y={pA.Y + 4} fontSize={12} fontWeight={700} fill={PALETTE.ink}>
          A
        </text>
        <circle cx={pM.X} cy={pM.Y} r={6} fill={PALETTE.orange} />
        <text
          x={pM.X + 10}
          y={pM.Y - 6}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.orange}
          stroke="#ffffff"
          strokeWidth={3}
          paintOrder="stroke"
        >
          M
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Vecteur directeur : composante x"
          value={dx}
          min={-2}
          max={2}
          step={0.2}
          onChange={setDx}
          display={fmt(dx, 1)}
          color={PALETTE.green}
        />
        <Ctrl
          label="Vecteur directeur : composante y"
          value={dy}
          min={-2}
          max={2}
          step={0.2}
          onChange={setDy}
          display={fmt(dy, 1)}
          color={PALETTE.green}
        />
        <Ctrl
          label="Vecteur directeur : composante z"
          value={dz}
          min={-2}
          max={2}
          step={0.2}
          onChange={setDz}
          display={fmt(dz, 1)}
          color={PALETTE.green}
        />
        <Ctrl
          label="Paramètre t"
          value={t}
          min={-1.8}
          max={2.8}
          step={0.1}
          onChange={setT}
          display={fmt(t, 1)}
          color={PALETTE.orange}
        />
      </Panel>

      <div className="rounded-xl border border-border bg-white p-3 text-center">
        <p className="font-mono text-xs text-foreground">
          x = {fmt(A.x, 1)} + {fmt(dx, 1)} t &nbsp;·&nbsp; y = {fmt(A.y, 1)} + {fmt(dy, 1)} t
          &nbsp;·&nbsp; z = {fmt(A.z, 1)} + {fmt(dz, 1)} t
        </p>
      </div>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Point M obtenu"
          value={`(${fmt(M.x, 2)} ; ${fmt(M.y, 2)} ; ${fmt(M.z, 2)})`}
          color={PALETTE.orange}
        />
        <Stat
          label="Norme du vecteur directeur"
          value={fmt(Math.hypot(dx, dy, dz), 3)}
          color={PALETTE.green}
        />
      </div>

      <Verdict tone={Math.hypot(dx, dy, dz) < 0.05 ? "bad" : "ok"}>
        {Math.hypot(dx, dy, dz) < 0.05
          ? "Le vecteur directeur est nul : ce n'est plus une droite, tous les points se confondent avec A. Un vecteur directeur doit toujours être non nul."
          : "Fais varier t : le point M balaie toute la droite. Chaque valeur de t donne un point, et un seul. Le vecteur vert, lui, donne la direction, et on peut le remplacer par n'importe lequel de ses multiples sans changer la droite."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch20 — L'équation cartésienne d'un plan                             */
/* ------------------------------------------------------------------ */

export function PlanEquation() {
  const [a, setA] = useState(1);
  const [b, setB] = useState(0);
  const [c, setC] = useState(1);
  const [d, setD] = useState(-2);
  const [mx, setMx] = useState(1);
  const [my, setMy] = useState(1);
  const [mz, setMz] = useState(1);

  const W = 400;
  const H = 280;
  const ox = 180;
  const oy = 150;
  const u = 32;

  const norme = Math.hypot(a, b, c);
  const valeur = a * mx + b * my + c * mz + d;
  const distance = norme > 1e-9 ? Math.abs(valeur) / norme : Number.NaN;
  const dansLePlan = Math.abs(valeur) < 1e-9;

  // un morceau de plan : on prend z en fonction de x et y quand c != 0
  const coins: Array<{ x: number; y: number; z: number }> = [];
  if (Math.abs(c) > 1e-9) {
    for (const [x, y] of [
      [-0.6, -0.6],
      [2.6, -0.6],
      [2.6, 2.6],
      [-0.6, 2.6],
    ] as const) {
      coins.push({ x, y, z: (-d - a * x - b * y) / c });
    }
  }

  const pts = coins.map((p) => iso(p.x, p.y, p.z, ox, oy, u));
  const pM = iso(mx, my, mz, ox, oy, u);
  // le vecteur normal part du centre du morceau de plan, pour ne pas se
  // confondre avec l'axe des z
  const centre = { x: 1, y: 1, z: Math.abs(c) > 1e-9 ? (-d - a - b) / c : 0 };
  const pN0 = iso(centre.x, centre.y, centre.z, ox, oy, u);
  const pN1 = iso(
    centre.x + (2.4 * a) / Math.max(norme, 1e-9),
    centre.y + (2.4 * b) / Math.max(norme, 1e-9),
    centre.z + (2.4 * c) / Math.max(norme, 1e-9),
    ox,
    oy,
    u,
  );

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Repere3D ox={ox} oy={oy} u={u} taille={3} />
        {pts.length === 4 ? (
          <polygon
            points={pts.map((p) => `${p.X},${p.Y}`).join(" ")}
            fill={PALETTE.blue}
            fillOpacity={0.2}
            stroke={PALETTE.blue}
            strokeWidth={2}
          />
        ) : (
          <text x={W / 2} y={30} textAnchor="middle" fontSize={11} fill={PALETTE.red}>
            avec c = 0, le plan est parallèle à l&apos;axe des z
          </text>
        )}
        <Arrow x1={pN0.X} y1={pN0.Y} x2={pN1.X} y2={pN1.Y} color={PALETTE.green} width={2.4} />
        <text
          x={pN1.X + 8}
          y={pN1.Y - 4}
          fontSize={10}
          fontWeight={700}
          fill={PALETTE.green}
          stroke="#ffffff"
          strokeWidth={3}
          paintOrder="stroke"
        >
          normal
        </text>
        <circle cx={pM.X} cy={pM.Y} r={6} fill={dansLePlan ? PALETTE.green : PALETTE.orange} />
        <text
          x={pM.X - 12}
          y={pM.Y + 16}
          fontSize={12}
          fontWeight={700}
          fill={dansLePlan ? PALETTE.green : PALETTE.orange}
          stroke="#ffffff"
          strokeWidth={3}
          paintOrder="stroke"
        >
          M
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="a"
          value={a}
          min={-3}
          max={3}
          step={1}
          onChange={(v) => setA(Math.round(v))}
          display={String(a)}
          color={PALETTE.green}
        />
        <Ctrl
          label="b"
          value={b}
          min={-3}
          max={3}
          step={1}
          onChange={(v) => setB(Math.round(v))}
          display={String(b)}
          color={PALETTE.green}
        />
        <Ctrl
          label="c"
          value={c}
          min={-3}
          max={3}
          step={1}
          onChange={(v) => setC(Math.round(v))}
          display={String(c)}
          color={PALETTE.green}
        />
        <Ctrl
          label="d"
          value={d}
          min={-6}
          max={6}
          step={1}
          onChange={(v) => setD(Math.round(v))}
          display={String(d)}
          color={PALETTE.green}
        />
        <Ctrl
          label="M : x"
          value={mx}
          min={-2}
          max={4}
          step={0.5}
          onChange={setMx}
          display={fmt(mx, 1)}
          color={PALETTE.orange}
        />
        <Ctrl
          label="M : y"
          value={my}
          min={-2}
          max={4}
          step={0.5}
          onChange={setMy}
          display={fmt(my, 1)}
          color={PALETTE.orange}
        />
        <Ctrl
          label="M : z"
          value={mz}
          min={-2}
          max={4}
          step={0.5}
          onChange={setMz}
          display={fmt(mz, 1)}
          color={PALETTE.orange}
        />
      </Panel>

      <div className="rounded-xl border border-border bg-white p-3 text-center">
        <p className="font-mono text-sm font-semibold text-foreground">
          {a}x {b >= 0 ? "+" : "−"} {Math.abs(b)}y {c >= 0 ? "+" : "−"} {Math.abs(c)}z{" "}
          {d >= 0 ? "+" : "−"} {Math.abs(d)} = 0
        </p>
      </div>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Vecteur normal" value={`(${a} ; ${b} ; ${c})`} color={PALETTE.green} />
        <Stat
          label="Valeur en M"
          value={fmt(valeur, 2)}
          color={dansLePlan ? PALETTE.green : PALETTE.orange}
        />
        <Stat label="Distance de M au plan" value={fmt(distance, 3)} color={PALETTE.purple} />
      </div>

      <Verdict tone={dansLePlan ? "ok" : "warn"}>
        {dansLePlan
          ? "La valeur en M est nulle : le point appartient au plan. C'est le seul test à faire, remplacer les coordonnées dans l'équation."
          : "Les trois premiers coefficients de l'équation donnent directement un vecteur normal au plan, dessiné en vert. La distance de M au plan se calcule en divisant la valeur obtenue par la norme de ce vecteur."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch20 — Le projeté orthogonal                                        */
/* ------------------------------------------------------------------ */

export function ProjeteOrthogonal() {
  const [cible, setCible] = useState<"droite" | "plan">("plan");
  const [mx, setMx] = useState(2.4);
  const [my, setMy] = useState(0.6);
  const [mz, setMz] = useState(2.2);

  const W = 400;
  const H = 280;
  const ox = 180;
  const oy = 170;
  const u = 30;

  // la droite : passant par O, de vecteur directeur (1, 1, 0,5)
  const d = { x: 1, y: 1, z: 0.5 };
  const n2 = d.x * d.x + d.y * d.y + d.z * d.z;
  const t = (mx * d.x + my * d.y + mz * d.z) / n2;
  const Hd = { x: t * d.x, y: t * d.y, z: t * d.z };

  // le plan : z = 0
  const Hp = { x: mx, y: my, z: 0 };

  const Hc = cible === "droite" ? Hd : Hp;
  const dist = Math.hypot(mx - Hc.x, my - Hc.y, mz - Hc.z);

  const pM = iso(mx, my, mz, ox, oy, u);
  const pH = iso(Hc.x, Hc.y, Hc.z, ox, oy, u);
  const dA = iso(-0.8 * d.x, -0.8 * d.y, -0.8 * d.z, ox, oy, u);
  const dB = iso(3 * d.x, 3 * d.y, 3 * d.z, ox, oy, u);

  const solPlan = [
    iso(-0.8, -0.8, 0, ox, oy, u),
    iso(3.4, -0.8, 0, ox, oy, u),
    iso(3.4, 3.4, 0, ox, oy, u),
    iso(-0.8, 3.4, 0, ox, oy, u),
  ];

  return (
    <div className="space-y-3">
      <Choice
        label="Projeter sur"
        value={cible}
        options={[
          { value: "plan", label: "le plan z = 0" },
          { value: "droite", label: "une droite" },
        ]}
        onChange={setCible}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {cible === "plan" ? (
          <polygon
            points={solPlan.map((p) => `${p.X},${p.Y}`).join(" ")}
            fill={PALETTE.blue}
            fillOpacity={0.14}
            stroke={PALETTE.blue}
            strokeWidth={1.8}
          />
        ) : null}
        <Repere3D ox={ox} oy={oy} u={u} taille={3} />
        {cible === "droite" ? (
          <line x1={dA.X} y1={dA.Y} x2={dB.X} y2={dB.Y} stroke={PALETTE.blue} strokeWidth={2.6} />
        ) : null}
        <line
          x1={pM.X}
          y1={pM.Y}
          x2={pH.X}
          y2={pH.Y}
          stroke={PALETTE.red}
          strokeWidth={2.4}
          strokeDasharray="6 4"
        />
        <circle cx={pM.X} cy={pM.Y} r={6} fill={PALETTE.orange} />
        <text
          x={pM.X + 10}
          y={pM.Y - 6}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.orange}
          stroke="#ffffff"
          strokeWidth={3}
          paintOrder="stroke"
        >
          M
        </text>
        <circle cx={pH.X} cy={pH.Y} r={6} fill={PALETTE.green} />
        <text
          x={pH.X + 10}
          y={pH.Y + 14}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.green}
          stroke="#ffffff"
          strokeWidth={3}
          paintOrder="stroke"
        >
          H
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="M : x"
          value={mx}
          min={-1}
          max={3.5}
          step={0.2}
          onChange={setMx}
          display={fmt(mx, 1)}
          color={PALETTE.orange}
        />
        <Ctrl
          label="M : y"
          value={my}
          min={-1}
          max={3.5}
          step={0.2}
          onChange={setMy}
          display={fmt(my, 1)}
          color={PALETTE.orange}
        />
        <Ctrl
          label="M : z"
          value={mz}
          min={0}
          max={3.5}
          step={0.2}
          onChange={setMz}
          display={fmt(mz, 1)}
          color={PALETTE.orange}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat
          label="Projeté H"
          value={`(${fmt(Hc.x, 2)} ; ${fmt(Hc.y, 2)} ; ${fmt(Hc.z, 2)})`}
          color={PALETTE.green}
        />
        <Stat label="Distance MH" value={fmt(dist, 3)} color={PALETTE.red} />
        <Stat
          label="Le segment [MH] est"
          value={cible === "plan" ? "vertical, donc normal au plan" : "orthogonal à la droite"}
        />
      </div>

      <Verdict tone="ok">
        {cible === "plan"
          ? "Projeter sur le plan z = 0 revient à effacer la troisième coordonnée. La distance de M au plan est simplement la valeur absolue de son altitude."
          : "Le projeté se calcule avec le produit scalaire : on cherche le réel t tel que le vecteur MH soit orthogonal au vecteur directeur. La distance MH est alors la plus courte distance de M à la droite, et aucun autre point de la droite n'est plus proche."}
      </Verdict>
    </div>
  );
}
