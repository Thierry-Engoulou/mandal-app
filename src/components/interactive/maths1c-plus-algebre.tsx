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

/** Simulations d'algèbre complémentaires du programme de 1ère C. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/** « 3x » , « −x » , « x » selon le coefficient. */
function coef(c: number, suffixe: string): string {
  if (c === 0) return "0";
  if (suffixe === "") return fmt(c, 2);
  if (c === 1) return suffixe;
  if (c === -1) return "−" + suffixe;
  return fmt(c, 2) + suffixe;
}

/* ------------------------------------------------------------------ */
/* ch01 — Somme, produit et factorisation du trinôme                   */
/* ------------------------------------------------------------------ */

export function SommeProduitRacines() {
  const [a, setA] = useState(1);
  const [b, setB] = useState(-5);
  const [c, setC] = useState(6);

  const delta = b * b - 4 * a * c;
  const deuxRacines = delta > 1e-9;
  const racineDouble = Math.abs(delta) <= 1e-9;
  const x1 = deuxRacines ? (-b - Math.sqrt(delta)) / (2 * a) : -b / (2 * a);
  const x2 = deuxRacines ? (-b + Math.sqrt(delta)) / (2 * a) : -b / (2 * a);
  const somme = -b / a;
  const produit = c / a;

  const W = 420;
  const H = 240;
  const s = makeScales(W, H, -6, 6, -8, 10, 28);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={2} />
        <path
          d={curvePath((x) => a * x * x + b * x + c, s)}
          fill="none"
          stroke={PALETTE.blue}
          strokeWidth={2.6}
        />
        {delta >= -1e-9 ? (
          <>
            <circle cx={s.sx(x1)} cy={s.sy(0)} r={6} fill={PALETTE.green} />
            <circle cx={s.sx(x2)} cy={s.sy(0)} r={6} fill={PALETTE.green} />
            <line
              x1={s.sx(x1)}
              y1={s.sy(0)}
              x2={s.sx(x2)}
              y2={s.sy(0)}
              stroke={PALETTE.green}
              strokeWidth={3}
            />
            <text
              x={(s.sx(x1) + s.sx(x2)) / 2}
              y={s.sy(0) - 12}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill={PALETTE.green}
              stroke="#ffffff"
              strokeWidth={3}
              paintOrder="stroke"
            >
              racines {fmt(x1, 2)} et {fmt(x2, 2)}
            </text>
          </>
        ) : (
          <text
            x={W / 2}
            y={40}
            textAnchor="middle"
            fontSize={12}
            fontWeight={700}
            fill={PALETTE.red}
          >
            la parabole ne coupe pas l&apos;axe des abscisses
          </text>
        )}
      </Board>

      <Panel>
        <Ctrl
          label="a"
          value={a}
          min={-3}
          max={3}
          step={1}
          onChange={(v) => setA(Math.round(v) === 0 ? 1 : Math.round(v))}
          display={String(a)}
        />
        <Ctrl
          label="b"
          value={b}
          min={-8}
          max={8}
          step={1}
          onChange={(v) => setB(Math.round(v))}
          display={String(b)}
          color={PALETTE.purple}
        />
        <Ctrl
          label="c"
          value={c}
          min={-8}
          max={10}
          step={1}
          onChange={(v) => setC(Math.round(v))}
          display={String(c)}
          color={PALETTE.orange}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Discriminant Δ"
          value={fmt(delta, 2)}
          color={delta < 0 ? PALETTE.red : PALETTE.green}
        />
        <Stat label="Racines" value={delta < -1e-9 ? "aucune" : `${fmt(x1, 3)} et ${fmt(x2, 3)}`} />
        <Stat label="Somme S = −b/a" value={fmt(somme, 3)} color={PALETTE.green} />
        <Stat label="Produit P = c/a" value={fmt(produit, 3)} color={PALETTE.purple} />
      </div>

      {delta >= -1e-9 ? (
        <div className="rounded-xl border border-border bg-white p-3 text-center">
          <p className="font-mono text-sm font-semibold text-foreground">
            {coef(a, "x²")} {b >= 0 ? "+" : "−"} {coef(Math.abs(b), "x")} {c >= 0 ? "+" : "−"}{" "}
            {Math.abs(c)} = {a === 1 ? "" : `${a}`}(x − {fmt(x1, 2)})(x − {fmt(x2, 2)})
          </p>
        </div>
      ) : null}

      <Verdict tone={delta < -1e-9 ? "bad" : racineDouble ? "warn" : "ok"}>
        {delta < -1e-9
          ? "Δ est négatif : pas de racine réelle, donc pas de factorisation dans ℝ. Le trinôme garde le signe de a sur tout ℝ."
          : racineDouble
            ? `Δ est nul : une seule racine, ${fmt(x1, 3)}, comptée deux fois. La factorisation s'écrit avec un carré.`
            : `Vérifie sans calculer les racines : leur somme vaut −b/a = ${fmt(somme, 3)} et leur produit c/a = ${fmt(produit, 3)}. C'est souvent le plus rapide pour deviner des racines entières.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch01 — Équations irrationnelles                                     */
/* ------------------------------------------------------------------ */

export function EquationIrrationnelle() {
  const [p, setP] = useState(1);
  const [q, setQ] = useState(2);
  const [r, setR] = useState(1);
  const [k, setK] = useState(0);

  // on resout  racine(p x + q) = r x + k
  const gauche = (x: number) => Math.sqrt(p * x + q);
  const droite = (x: number) => r * x + k;

  // domaine : p x + q >= 0  et  r x + k >= 0
  const bornePx = p !== 0 ? -q / p : Number.NEGATIVE_INFINITY;
  const borneRx = r !== 0 ? -k / r : Number.NEGATIVE_INFINITY;

  // solutions de l'equation elevee au carre : p x + q = (r x + k)^2
  const A = r * r;
  const B = 2 * r * k - p;
  const C = k * k - q;
  const sols: number[] = [];
  if (Math.abs(A) < 1e-9) {
    if (Math.abs(B) > 1e-9) sols.push(-C / B);
  } else {
    const d = B * B - 4 * A * C;
    if (d >= -1e-9) {
      const dd = Math.max(d, 0);
      sols.push((-B - Math.sqrt(dd)) / (2 * A));
      if (dd > 1e-9) sols.push((-B + Math.sqrt(dd)) / (2 * A));
    }
  }
  const retenues = sols.filter(
    (x) => p * x + q >= -1e-9 && r * x + k >= -1e-9 && Math.abs(gauche(x) - droite(x)) < 1e-6,
  );
  const parasites = sols.filter((x) => !retenues.includes(x));

  const W = 420;
  const H = 240;
  const s = makeScales(W, H, -4, 8, -3, 7, 28);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={1} />
        <path
          d={curvePath((x) => (p * x + q >= 0 ? gauche(x) : Number.NaN), s)}
          fill="none"
          stroke={PALETTE.blue}
          strokeWidth={2.8}
        />
        <path d={curvePath(droite, s)} fill="none" stroke={PALETTE.purple} strokeWidth={2.4} />
        {Number.isFinite(bornePx) && bornePx > -4 && bornePx < 8 ? (
          <line
            x1={s.sx(bornePx)}
            y1={s.sy(-3)}
            x2={s.sx(bornePx)}
            y2={s.sy(7)}
            stroke={PALETTE.red}
            strokeWidth={1.4}
            strokeDasharray="5 4"
          />
        ) : null}
        {retenues.map((x, i) => (
          <circle key={`ok${i}`} cx={s.sx(x)} cy={s.sy(droite(x))} r={6} fill={PALETTE.green} />
        ))}
        {parasites.map((x, i) => (
          <g key={`ko${i}`}>
            <circle
              cx={s.sx(x)}
              cy={s.sy(droite(x))}
              r={6}
              fill="none"
              stroke={PALETTE.red}
              strokeWidth={2.4}
            />
            <line
              x1={s.sx(x) - 5}
              y1={s.sy(droite(x)) - 5}
              x2={s.sx(x) + 5}
              y2={s.sy(droite(x)) + 5}
              stroke={PALETTE.red}
              strokeWidth={2}
            />
          </g>
        ))}
      </Board>

      <Panel>
        <Ctrl
          label="sous la racine : coefficient de x"
          value={p}
          min={1}
          max={4}
          step={1}
          onChange={(v) => setP(Math.round(v))}
          display={String(p)}
        />
        <Ctrl
          label="sous la racine : constante"
          value={q}
          min={-4}
          max={6}
          step={1}
          onChange={(v) => setQ(Math.round(v))}
          display={String(q)}
        />
        <Ctrl
          label="à droite : coefficient de x"
          value={r}
          min={-2}
          max={3}
          step={1}
          onChange={(v) => setR(Math.round(v))}
          display={String(r)}
          color={PALETTE.purple}
        />
        <Ctrl
          label="à droite : constante"
          value={k}
          min={-4}
          max={4}
          step={1}
          onChange={(v) => setK(Math.round(v))}
          display={String(k)}
          color={PALETTE.purple}
        />
      </Panel>

      <div className="rounded-xl border border-border bg-white p-3 text-center">
        <p className="font-mono text-sm font-semibold text-foreground">
          √({coef(p, "x")} {q >= 0 ? "+" : "−"} {Math.abs(q)}) = {coef(r, "x")} {k >= 0 ? "+" : "−"}{" "}
          {Math.abs(k)}
        </p>
      </div>

      <div className="grid grid-cols-3 gap-2">
        <Stat
          label="Domaine"
          value={p !== 0 ? `x ≥ ${fmt(bornePx, 2)}` : "ℝ"}
          color={PALETTE.red}
        />
        <Stat
          label="Solutions retenues"
          value={retenues.length ? retenues.map((x) => fmt(x, 3)).join(" · ") : "aucune"}
          color={PALETTE.green}
        />
        <Stat
          label="Solutions parasites"
          value={parasites.length ? parasites.map((x) => fmt(x, 3)).join(" · ") : "aucune"}
          color={PALETTE.red}
        />
      </div>

      <Verdict tone={parasites.length ? "warn" : retenues.length ? "ok" : "bad"}>
        {parasites.length
          ? "Les points barrés en rouge vérifient l'équation élevée au carré, mais pas l'équation de départ : ce sont des solutions parasites. Élever au carré ajoute des solutions, c'est pourquoi il faut toujours vérifier à la fin."
          : retenues.length
            ? "Chaque point vert est une vraie solution : la racine et la droite s'y rencontrent. Note que la courbe bleue n'existe pas à gauche du trait rouge, c'est le domaine de définition."
            : "Les deux courbes ne se rencontrent pas sur le domaine : l'équation n'a pas de solution. Baisse la constante de droite pour faire descendre la droite."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch01 — Polynômes de degré 3                                         */
/* ------------------------------------------------------------------ */

export function PolynomeDegre3() {
  const [r1, setR1] = useState(1);
  const [b, setB] = useState(-1);
  const [c, setC] = useState(-6);
  const [a, setA] = useState(1);

  // P(x) = a (x - r1)(x^2 + b x + c)
  const P = (x: number) => a * (x - r1) * (x * x + b * x + c);
  const delta = b * b - 4 * c;
  const autres: number[] = [];
  if (delta >= -1e-9) {
    const dd = Math.max(delta, 0);
    autres.push((-b - Math.sqrt(dd)) / 2);
    if (dd > 1e-9) autres.push((-b + Math.sqrt(dd)) / 2);
  }

  const W = 420;
  const H = 250;
  const s = makeScales(W, H, -5, 5, -20, 20, 28);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={5} />
        <path d={curvePath(P, s)} fill="none" stroke={PALETTE.blue} strokeWidth={2.6} />
        <circle cx={s.sx(r1)} cy={s.sy(0)} r={7} fill={PALETTE.green} />
        <circle cx={s.sx(-5) + 14} cy={s.sy(20) + 10} r={5} fill={PALETTE.green} />
        <text x={s.sx(-5) + 24} y={s.sy(20) + 14} fontSize={10} fill={PALETTE.slate}>
          racine évidente
        </text>
        <circle cx={s.sx(-5) + 14} cy={s.sy(20) + 26} r={5} fill={PALETTE.orange} />
        <text x={s.sx(-5) + 24} y={s.sy(20) + 30} fontSize={10} fill={PALETTE.slate}>
          racines du trinôme restant
        </text>
        {autres.map((x, i) =>
          Math.abs(x) <= 5 ? (
            <circle key={i} cx={s.sx(x)} cy={s.sy(0)} r={6} fill={PALETTE.orange} />
          ) : null,
        )}
      </Board>

      <Panel>
        <Ctrl
          label="Racine évidente"
          value={r1}
          min={-4}
          max={4}
          step={1}
          onChange={(v) => setR1(Math.round(v))}
          display={String(r1)}
          color={PALETTE.green}
        />
        <Ctrl
          label="Facteur a"
          value={a}
          min={-2}
          max={2}
          step={1}
          onChange={(v) => setA(Math.round(v) === 0 ? 1 : Math.round(v))}
          display={String(a)}
        />
        <Ctrl
          label="Trinôme : coefficient de x"
          value={b}
          min={-6}
          max={6}
          step={1}
          onChange={(v) => setB(Math.round(v))}
          display={String(b)}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Trinôme : constante"
          value={c}
          min={-9}
          max={9}
          step={1}
          onChange={(v) => setC(Math.round(v))}
          display={String(c)}
          color={PALETTE.orange}
        />
      </Panel>

      <div className="rounded-xl border border-border bg-white p-3 text-center">
        <p className="font-mono text-sm font-semibold text-foreground">
          P(x) = {a === 1 ? "" : a === -1 ? "−" : a}(x {r1 >= 0 ? "−" : "+"} {Math.abs(r1)})(x²{" "}
          {b >= 0 ? "+" : "−"} {coef(Math.abs(b), "x")} {c >= 0 ? "+" : "−"} {Math.abs(c)})
        </p>
      </div>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="P(racine évidente)" value={fmt(P(r1), 2)} color={PALETTE.green} />
        <Stat
          label="Δ du trinôme"
          value={fmt(delta, 2)}
          color={delta < 0 ? PALETTE.red : PALETTE.orange}
        />
        <Stat
          label="Nombre de racines"
          value={String(1 + autres.filter((x) => Math.abs(x - r1) > 1e-9).length)}
        />
      </div>

      <Verdict tone={delta < -1e-9 ? "warn" : "ok"}>
        {delta < -1e-9
          ? "Le trinôme n'a pas de racine réelle : le polynôme de degré 3 n'en a qu'une seule. Sa courbe ne traverse l'axe qu'une fois, et c'est toujours au moins une fois pour un degré impair."
          : "La méthode est toujours la même : on cherche une racine évidente, on factorise par (x − racine), puis on résout le trinôme qui reste. Vérifie que P(racine évidente) vaut bien zéro."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch02 — Le pivot de Gauss sur un système 3 × 3                       */
/* ------------------------------------------------------------------ */

export function PivotGauss() {
  const [etape, setEtape] = useState(0);

  type Ligne = [number, number, number, number];
  const depart: Ligne[] = [
    [1, 1, 1, 6],
    [2, -1, 1, 3],
    [1, 2, -1, 2],
  ];

  function combiner(l: Ligne, pivot: Ligne, facteur: number): Ligne {
    return [
      l[0] - facteur * pivot[0],
      l[1] - facteur * pivot[1],
      l[2] - facteur * pivot[2],
      l[3] - facteur * pivot[3],
    ];
  }

  const etats: { lignes: Ligne[]; texte: string }[] = [];
  etats.push({ lignes: depart, texte: "Le système de départ, tel qu'il est posé." });

  const p0 = depart[0] as Ligne;
  const e1: Ligne[] = [
    p0,
    combiner(depart[1] as Ligne, p0, 2),
    combiner(depart[2] as Ligne, p0, 1),
  ];
  etats.push({
    lignes: e1,
    texte: "L₂ ← L₂ − 2 L₁ et L₃ ← L₃ − L₁ : on élimine x des deux dernières lignes.",
  });

  const q1 = e1[1] as Ligne;
  const e2: Ligne[] = [p0, q1, combiner(e1[2] as Ligne, q1, (e1[2] as Ligne)[1] / q1[1])];
  etats.push({
    lignes: e2,
    texte:
      "L₃ ← L₃ − (coefficient) L₂ : on élimine y de la dernière ligne. Le système est triangulaire.",
  });

  const l3 = e2[2] as Ligne;
  const z = l3[3] / l3[2];
  const y = (q1[3] - q1[2] * z) / q1[1];
  const x = (p0[3] - p0[1] * y - p0[2] * z) / p0[0];
  etats.push({
    lignes: e2,
    texte: "Remontée : on lit z sur la dernière ligne, puis y, puis x.",
  });

  const courant = etats[Math.min(etape, etats.length - 1)] ?? etats[0];
  const fini = etape >= etats.length - 1;

  function ecrire(l: Ligne): string {
    const t = (v: number, nom: string, premier: boolean) => {
      if (Math.abs(v) < 1e-9) return "";
      const signe = v > 0 ? (premier ? "" : " + ") : premier ? "−" : " − ";
      const abs = Math.abs(v);
      return `${signe}${abs === 1 ? "" : fmt(abs, 2)}${nom}`;
    };
    const membre =
      t(l[0], "x", true) +
      t(l[1], "y", Math.abs(l[0]) < 1e-9) +
      t(l[2], "z", Math.abs(l[0]) < 1e-9 && Math.abs(l[1]) < 1e-9);
    return `${membre || "0"} = ${fmt(l[3], 2)}`;
  }

  return (
    <div className="space-y-3">
      <div className="space-y-2 rounded-xl border border-border bg-white p-4">
        {(courant?.lignes ?? depart).map((l, i) => (
          <p
            key={i}
            className="text-center font-mono text-sm"
            style={{
              color:
                etape >= 1 && i === 0
                  ? PALETTE.green
                  : etape >= 2 && i === 1
                    ? PALETTE.green
                    : PALETTE.ink,
            }}
          >
            {ecrire(l)}
          </p>
        ))}
      </div>

      <Ctrl
        label="Étape du pivot"
        value={etape}
        min={0}
        max={etats.length - 1}
        step={1}
        onChange={(v) => setEtape(Math.round(v))}
        display={`${etape + 1} sur ${etats.length}`}
        color={PALETTE.purple}
      />

      <Verdict tone={fini ? "ok" : "warn"}>
        {fini
          ? `Le système est résolu : x = ${fmt(x, 2)}, y = ${fmt(y, 2)}, z = ${fmt(z, 2)}. Remplace ces valeurs dans les trois équations de départ pour vérifier.`
          : (courant?.texte ?? "")}
      </Verdict>

      {fini ? (
        <div className="grid grid-cols-3 gap-2">
          <Stat label="x" value={fmt(x, 3)} color={PALETTE.blue} />
          <Stat label="y" value={fmt(y, 3)} color={PALETTE.purple} />
          <Stat label="z" value={fmt(z, 3)} color={PALETTE.orange} />
        </div>
      ) : null}
    </div>
  );
}

/** Les quatre repères d'angle autour d'un cercle trigonométrique. */
function ReperesCercle({ cx, cy, r }: { cx: number; cy: number; r: number }) {
  const marques: Array<{ t: number; nom: string; dx: number; dy: number }> = [
    { t: 0, nom: "0", dx: 16, dy: 14 },
    { t: Math.PI / 2, nom: "π/2", dx: 14, dy: -12 },
    { t: Math.PI, nom: "π", dx: -18, dy: 14 },
    { t: (3 * Math.PI) / 2, nom: "3π/2", dx: 16, dy: 18 },
  ];
  return (
    <g>
      {marques.map((m) => (
        <g key={m.nom}>
          <circle
            cx={cx + r * Math.cos(m.t)}
            cy={cy - r * Math.sin(m.t)}
            r={3}
            fill={PALETTE.slate}
          />
          <text
            x={cx + r * Math.cos(m.t) + m.dx}
            y={cy - r * Math.sin(m.t) + m.dy}
            textAnchor="middle"
            fontSize={10}
            fill={PALETTE.slate}
          >
            {m.nom}
          </text>
        </g>
      ))}
    </g>
  );
}

/* ------------------------------------------------------------------ */
/* ch03 — Résoudre cos x = a, sin x = a, tan x = a                     */
/* ------------------------------------------------------------------ */

export function EquationTrigo() {
  const [fonction, setFonction] = useState<"cos" | "sin" | "tan">("cos");
  const [a, setA] = useState(0.5);

  const W = 300;
  const H = 300;
  const cx = W / 2;
  const cy = H / 2;
  const R = 108;

  const possible = fonction === "tan" ? true : Math.abs(a) <= 1;
  let angles: number[] = [];
  if (fonction === "cos" && possible) {
    const t = Math.acos(clamp(a, -1, 1));
    angles = [t, -t];
  } else if (fonction === "sin" && possible) {
    const t = Math.asin(clamp(a, -1, 1));
    angles = [t, Math.PI - t];
  } else if (fonction === "tan") {
    const t = Math.atan(a);
    angles = [t, t + Math.PI];
  }
  const normalise = (t: number) => ((t % (2 * Math.PI)) + 2 * Math.PI) % (2 * Math.PI);
  const affichees = angles.map(normalise);

  const px = (t: number) => cx + R * Math.cos(t);
  const py = (t: number) => cy - R * Math.sin(t);

  return (
    <div className="space-y-3">
      <Choice
        label="Équation à résoudre"
        value={fonction}
        options={[
          { value: "cos", label: "cos x = a" },
          { value: "sin", label: "sin x = a" },
          { value: "tan", label: "tan x = a" },
        ]}
        onChange={setFonction}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <circle cx={cx} cy={cy} r={R} fill="none" stroke={PALETTE.gridStrong} strokeWidth={1.4} />
        <line
          x1={cx - R - 18}
          y1={cy}
          x2={cx + R + 18}
          y2={cy}
          stroke={PALETTE.axis}
          strokeWidth={1.2}
        />
        <line
          x1={cx}
          y1={cy - R - 18}
          x2={cx}
          y2={cy + R + 18}
          stroke={PALETTE.axis}
          strokeWidth={1.2}
        />

        {fonction === "cos" && possible ? (
          <line
            x1={cx + R * clamp(a, -1, 1)}
            y1={cy - R - 10}
            x2={cx + R * clamp(a, -1, 1)}
            y2={cy + R + 10}
            stroke={PALETTE.orange}
            strokeWidth={2}
            strokeDasharray="5 4"
          />
        ) : null}
        {fonction === "sin" && possible ? (
          <line
            x1={cx - R - 10}
            y1={cy - R * clamp(a, -1, 1)}
            x2={cx + R + 10}
            y2={cy - R * clamp(a, -1, 1)}
            stroke={PALETTE.orange}
            strokeWidth={2}
            strokeDasharray="5 4"
          />
        ) : null}
        {fonction === "tan" ? (
          <>
            <line
              x1={cx + R}
              y1={cy - R - 14}
              x2={cx + R}
              y2={cy + R + 14}
              stroke={PALETTE.gridStrong}
              strokeWidth={1.2}
            />
            <circle cx={cx + R} cy={cy - R * a} r={5} fill={PALETTE.orange} />
          </>
        ) : null}

        <ReperesCercle cx={cx} cy={cy} r={R} />
        {possible
          ? affichees.map((t, i) => (
              <g key={i}>
                <line
                  x1={cx}
                  y1={cy}
                  x2={px(t)}
                  y2={py(t)}
                  stroke={PALETTE.blue}
                  strokeWidth={2.2}
                />
                <circle cx={px(t)} cy={py(t)} r={6} fill={PALETTE.green} />
                <text
                  x={cx + (R + 24) * Math.cos(t)}
                  y={cy - (R + 24) * Math.sin(t) + 4}
                  textAnchor="middle"
                  fontSize={11}
                  fontWeight={700}
                  fill={PALETTE.green}
                  stroke="#ffffff"
                  strokeWidth={3}
                  paintOrder="stroke"
                >
                  {fmt(t, 2)}
                </text>
              </g>
            ))
          : null}
        {!possible ? (
          <text
            x={cx}
            y={cy - R - 28}
            textAnchor="middle"
            fontSize={12}
            fontWeight={700}
            fill={PALETTE.red}
          >
            aucune solution
          </text>
        ) : null}
      </Board>

      <Ctrl
        label="Valeur de a"
        value={a}
        min={fonction === "tan" ? -4 : -1.4}
        max={fonction === "tan" ? 4 : 1.4}
        step={0.05}
        onChange={setA}
        display={fmt(a, 2)}
        color={PALETTE.orange}
      />

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Solutions dans [0 ; 2π["
          value={possible ? affichees.map((t) => `${fmt(t, 3)} rad`).join("  ·  ") : "aucune"}
          color={possible ? PALETTE.green : PALETTE.red}
        />
        <Stat
          label="En degrés"
          value={
            possible ? affichees.map((t) => `${fmt((t * 180) / Math.PI, 1)}°`).join("  ·  ") : "—"
          }
        />
      </div>

      <Verdict tone={possible ? "ok" : "bad"}>
        {!possible
          ? "Le cosinus et le sinus ne sortent jamais de l'intervalle [−1 ; 1] : avec cette valeur de a, l'équation n'a aucune solution."
          : fonction === "cos"
            ? "Les deux solutions sont symétriques par rapport à l'axe horizontal : si x convient, −x convient aussi. L'ensemble complet s'écrit x = ±arccos(a) + 2kπ."
            : fonction === "sin"
              ? "Les deux solutions sont symétriques par rapport à l'axe vertical : si x convient, π − x convient aussi. L'ensemble complet s'écrit x = arcsin(a) + 2kπ ou x = π − arcsin(a) + 2kπ."
              : "La tangente se lit sur la droite verticale à droite du cercle. Les deux solutions sont diamétralement opposées : la période de la tangente est π, et non 2π."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch03 — Réduire a cos x + b sin x                                    */
/* ------------------------------------------------------------------ */

export function AcosBsin() {
  const [a, setA] = useState(3);
  const [b, setB] = useState(4);
  const [c, setC] = useState(2.5);

  const R = Math.hypot(a, b);
  const phi = Math.atan2(b, a);
  const f = (x: number) => a * Math.cos(x) + b * Math.sin(x);

  const possible = R > 1e-9 && Math.abs(c / R) <= 1;
  const t = possible ? Math.acos(clamp(c / R, -1, 1)) : 0;
  const sols = possible
    ? [phi + t, phi - t].map((v) => ((v % (2 * Math.PI)) + 2 * Math.PI) % (2 * Math.PI))
    : [];

  const W = 430;
  const H = 230;
  const s = makeScales(W, H, 0, 2 * Math.PI, -7, 7, 28);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={2} />
        <path d={curvePath(f, s)} fill="none" stroke={PALETTE.blue} strokeWidth={2.8} />
        <line
          x1={s.sx(0)}
          y1={s.sy(c)}
          x2={s.sx(2 * Math.PI)}
          y2={s.sy(c)}
          stroke={PALETTE.orange}
          strokeWidth={2}
          strokeDasharray="5 4"
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(R)}
          x2={s.sx(2 * Math.PI)}
          y2={s.sy(R)}
          stroke={PALETTE.green}
          strokeWidth={1.2}
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(-R)}
          x2={s.sx(2 * Math.PI)}
          y2={s.sy(-R)}
          stroke={PALETTE.green}
          strokeWidth={1.2}
        />
        <text x={s.sx(0) + 70} y={s.sy(R) - 6} fontSize={10} fontWeight={700} fill={PALETTE.green}>
          R = {fmt(R, 3)}
        </text>
        {sols.map((x, i) => (
          <circle key={i} cx={s.sx(x)} cy={s.sy(c)} r={6} fill={PALETTE.green} />
        ))}
      </Board>

      <Panel>
        <Ctrl
          label="a, devant le cosinus"
          value={a}
          min={-6}
          max={6}
          step={0.5}
          onChange={setA}
          display={fmt(a, 1)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="b, devant le sinus"
          value={b}
          min={-6}
          max={6}
          step={0.5}
          onChange={setB}
          display={fmt(b, 1)}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Second membre c"
          value={c}
          min={-7}
          max={7}
          step={0.25}
          onChange={setC}
          display={fmt(c, 2)}
          color={PALETTE.orange}
        />
      </Panel>

      <div className="rounded-xl border border-border bg-white p-3 text-center">
        <p className="font-mono text-sm font-semibold text-foreground">
          {fmt(a, 1)} cos x + {fmt(b, 1)} sin x = {fmt(R, 3)} cos(x − {fmt(phi, 3)})
        </p>
      </div>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="R = √(a² + b²)" value={fmt(R, 4)} color={PALETTE.green} />
        <Stat label="φ = arctan(b/a)" value={`${fmt(phi, 3)} rad`} color={PALETTE.purple} />
        <Stat
          label="Solutions dans [0 ; 2π["
          value={possible ? sols.map((x) => fmt(x, 2)).join(" · ") : "aucune"}
        />
      </div>

      <Verdict tone={possible ? "ok" : "bad"}>
        {possible
          ? `La somme de deux sinusoïdes est encore une sinusoïde, d'amplitude R = ${fmt(R, 3)} et décalée de φ. Une fois cette écriture obtenue, l'équation se résout comme un simple cos X = c/R.`
          : `Le second membre c = ${fmt(c, 2)} sort de l'intervalle [−R ; R], c'est-à-dire [${fmt(-R, 2)} ; ${fmt(R, 2)}]. La courbe ne peut jamais l'atteindre : aucune solution.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch03 — Les inéquations trigonométriques                             */
/* ------------------------------------------------------------------ */

export function InequationTrigo() {
  const [fonction, setFonction] = useState<"cos" | "sin">("cos");
  const [sens, setSens] = useState<"sup" | "inf">("sup");
  const [a, setA] = useState(0.5);

  const W = 300;
  const H = 300;
  const cx = W / 2;
  const cy = H / 2;
  const R = 108;
  const av = clamp(a, -1, 1);

  const f = (t: number) => (fonction === "cos" ? Math.cos(t) : Math.sin(t));
  const dansSolution = (t: number) => (sens === "sup" ? f(t) >= av : f(t) <= av);

  // l'arc solution, echantillonne
  const pas = (2 * Math.PI) / 360;
  const arcs: string[] = [];
  let debut: number | null = null;
  for (let i = 0; i <= 360; i++) {
    const t = i * pas;
    const dedans = i < 360 && dansSolution(t);
    if (dedans && debut === null) debut = t;
    if (!dedans && debut !== null) {
      arcs.push(arcPath(debut, t));
      debut = null;
    }
  }
  if (debut !== null) arcs.push(arcPath(debut, 2 * Math.PI));

  function arcPath(t0: number, t1: number) {
    const x0 = cx + R * Math.cos(t0);
    const y0 = cy - R * Math.sin(t0);
    const x1 = cx + R * Math.cos(t1);
    const y1 = cy - R * Math.sin(t1);
    const grand = t1 - t0 > Math.PI ? 1 : 0;
    return `M${x0},${y0} A${R},${R} 0 ${grand} 0 ${x1},${y1}`;
  }

  const bornes =
    fonction === "cos"
      ? [Math.acos(av), 2 * Math.PI - Math.acos(av)]
      : [Math.asin(av), Math.PI - Math.asin(av)];

  return (
    <div className="space-y-3">
      <Choice
        value={fonction}
        options={[
          { value: "cos", label: "cosinus" },
          { value: "sin", label: "sinus" },
        ]}
        onChange={setFonction}
      />
      <Choice
        value={sens}
        options={[
          { value: "sup", label: "≥ a" },
          { value: "inf", label: "≤ a" },
        ]}
        onChange={setSens}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <circle cx={cx} cy={cy} r={R} fill="none" stroke={PALETTE.gridStrong} strokeWidth={1.4} />
        <line
          x1={cx - R - 18}
          y1={cy}
          x2={cx + R + 18}
          y2={cy}
          stroke={PALETTE.axis}
          strokeWidth={1.2}
        />
        <line
          x1={cx}
          y1={cy - R - 18}
          x2={cx}
          y2={cy + R + 18}
          stroke={PALETTE.axis}
          strokeWidth={1.2}
        />
        {fonction === "cos" ? (
          <line
            x1={cx + R * av}
            y1={cy - R - 12}
            x2={cx + R * av}
            y2={cy + R + 12}
            stroke={PALETTE.orange}
            strokeWidth={2}
            strokeDasharray="5 4"
          />
        ) : (
          <line
            x1={cx - R - 12}
            y1={cy - R * av}
            x2={cx + R + 12}
            y2={cy - R * av}
            stroke={PALETTE.orange}
            strokeWidth={2}
            strokeDasharray="5 4"
          />
        )}
        <ReperesCercle cx={cx} cy={cy} r={R} />
        {arcs.map((d, i) => (
          <path
            key={i}
            d={d}
            fill="none"
            stroke={PALETTE.green}
            strokeWidth={7}
            strokeLinecap="round"
          />
        ))}
        {bornes.map((t, i) => (
          <circle
            key={`b${i}`}
            cx={cx + R * Math.cos(t)}
            cy={cy - R * Math.sin(t)}
            r={5}
            fill="#ffffff"
            stroke={PALETTE.green}
            strokeWidth={2.4}
          />
        ))}
      </Board>

      <Ctrl
        label="Valeur de a"
        value={a}
        min={-1}
        max={1}
        step={0.05}
        onChange={setA}
        display={fmt(a, 2)}
        color={PALETTE.orange}
      />

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Bornes de l'arc"
          value={bornes.map((t) => `${fmt(t, 3)}`).join("  et  ")}
          color={PALETTE.green}
        />
        <Stat
          label="En degrés"
          value={bornes.map((t) => `${fmt((t * 180) / Math.PI, 1)}°`).join("  et  ")}
        />
      </div>

      <Verdict tone="ok">
        L&apos;arc vert est l&apos;ensemble des solutions. On le lit directement sur le cercle : on
        trace la droite qui correspond à a, puis on garde l&apos;arc du bon côté. Les bornes se
        calculent avec arccos ou arcsin, et il faut ensuite ajouter 2kπ pour avoir toutes les
        solutions de ℝ.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* ch04 — Opérations sur les fonctions                                 */
/* ------------------------------------------------------------------ */

export function OperationsFonctions() {
  const [operation, setOperation] = useState<"somme" | "produit" | "quotient" | "composee">(
    "somme",
  );
  const [a, setA] = useState(1);
  const [b, setB] = useState(-1);

  // f(x) = a x + b   et   g(x) = x^2 - 2
  const f = (x: number) => a * x + b;
  const g = (x: number) => x * x - 2;

  const h = (x: number) => {
    if (operation === "somme") return f(x) + g(x);
    if (operation === "produit") return f(x) * g(x);
    if (operation === "quotient") return Math.abs(g(x)) < 1e-6 ? Number.NaN : f(x) / g(x);
    return f(g(x));
  };

  const ecriture =
    operation === "somme"
      ? "(f + g)(x) = f(x) + g(x)"
      : operation === "produit"
        ? "(f × g)(x) = f(x) × g(x)"
        : operation === "quotient"
          ? "(f / g)(x) = f(x) ÷ g(x)"
          : "(f ∘ g)(x) = f(g(x))";

  const domaine =
    operation === "quotient"
      ? "ℝ privé de −√2 et √2, les deux valeurs qui annulent g"
      : "ℝ tout entier, car f et g sont définies partout";

  const W = 420;
  const H = 250;
  const s = makeScales(W, H, -4, 4, -8, 8, 28);

  return (
    <div className="space-y-3">
      <Choice
        label="Opération"
        value={operation}
        options={[
          { value: "somme", label: "f + g" },
          { value: "produit", label: "f × g" },
          { value: "quotient", label: "f / g" },
          { value: "composee", label: "f ∘ g" },
        ]}
        onChange={setOperation}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={2} />
        <path
          d={curvePath(f, s)}
          fill="none"
          stroke={PALETTE.slate}
          strokeWidth={1.8}
          strokeDasharray="5 4"
        />
        <path
          d={curvePath(g, s)}
          fill="none"
          stroke={PALETTE.purple}
          strokeWidth={1.8}
          strokeDasharray="5 4"
        />
        <path d={curvePath(h, s)} fill="none" stroke={PALETTE.blue} strokeWidth={3} />
        <text
          x={W / 2}
          y={s.sy(-8) + 18}
          textAnchor="middle"
          fontSize={10}
          fill={PALETTE.slate}
          stroke="#ffffff"
          strokeWidth={3}
          paintOrder="stroke"
        >
          f en gris, g en violet, le résultat en bleu
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="f : coefficient directeur"
          value={a}
          min={-3}
          max={3}
          step={0.5}
          onChange={setA}
          display={fmt(a, 1)}
        />
        <Ctrl
          label="f : ordonnée à l'origine"
          value={b}
          min={-4}
          max={4}
          step={0.5}
          onChange={setB}
          display={fmt(b, 1)}
        />
      </Panel>

      <div className="rounded-xl border border-border bg-white p-3 text-center">
        <p className="font-mono text-sm text-foreground">
          f(x) = {coef(a, "x")} {b >= 0 ? "+" : "−"} {Math.abs(b)} &nbsp;&nbsp; g(x) = x² − 2
        </p>
        <p className="mt-2 font-mono text-sm font-semibold" style={{ color: PALETTE.blue }}>
          {ecriture}
        </p>
      </div>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Domaine du résultat"
          value={domaine}
          color={operation === "quotient" ? PALETTE.red : PALETTE.green}
        />
        <Stat label="Valeur en x = 1" value={fmt(h(1), 3)} color={PALETTE.blue} />
      </div>

      <Verdict tone={operation === "quotient" ? "warn" : "ok"}>
        {operation === "quotient"
          ? "Pour un quotient, le domaine se réduit : il faut retirer toutes les valeurs qui annulent le dénominateur. C'est la seule des quatre opérations qui change le domaine ici."
          : operation === "composee"
            ? "Pour la composée, on calcule d'abord g(x), puis on applique f au résultat. L'ordre compte : f ∘ g et g ∘ f ne donnent presque jamais la même fonction, essaie de le vérifier sur ton cahier."
            : "Chaque point de la courbe bleue s'obtient en combinant, à la même abscisse, l'ordonnée de f et celle de g. Place-toi en x = 1 et vérifie à la main."}
      </Verdict>
    </div>
  );
}
