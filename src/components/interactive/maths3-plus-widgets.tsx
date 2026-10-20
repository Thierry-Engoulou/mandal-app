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
  linePath,
  makeScales,
} from "./controls";

/** Simulations complémentaires du programme de Mathématiques de 3ème. */

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

function diviseursDe(n: number): number[] {
  const out: number[] = [];
  for (let d = 1; d <= Math.abs(n); d++) if (n % d === 0) out.push(d);
  return out;
}

/** Écrit « x − 3 » ou « x + 2 » au lieu du disgracieux « x − -2 ». */
function binome(v: number): string {
  if (v === 0) return "x";
  return v > 0 ? `x − ${v}` : `x + ${-v}`;
}

/* ------------------------------------------------------------------ */
/* Chapitre 1 — Diviseurs communs, PGCD et PPCM                        */
/* ------------------------------------------------------------------ */

export function DiviseursCommuns() {
  const [a, setA] = useState(36);
  const [b, setB] = useState(24);
  const [vue, setVue] = useState<"diviseurs" | "multiples">("diviseurs");

  const da = diviseursDe(a);
  const db = diviseursDe(b);
  const communs = da.filter((d) => db.includes(d));
  const g = pgcd(a, b);
  const p = (a * b) / Math.max(g, 1);

  const ma: number[] = [];
  const mb: number[] = [];
  for (let k = 1; k <= 14; k++) ma.push(a * k);
  for (let k = 1; k <= 14; k++) mb.push(b * k);
  const premierCommun = ma.find((m) => mb.includes(m)) ?? p;

  function pastille(valeur: number, surligne: boolean, cle: string) {
    return (
      <span
        key={cle}
        className={
          surligne
            ? "rounded-md px-2 py-1 font-mono text-sm font-bold text-white"
            : "rounded-md px-2 py-1 font-mono text-sm text-muted-foreground"
        }
        style={surligne ? { backgroundColor: PALETTE.green } : { backgroundColor: "#f1f5f9" }}
      >
        {valeur}
      </span>
    );
  }

  return (
    <div className="space-y-3">
      <Choice
        value={vue}
        options={[
          { value: "diviseurs", label: "Diviseurs et PGCD" },
          { value: "multiples", label: "Multiples et PPCM" },
        ]}
        onChange={setVue}
      />

      <Panel>
        <Ctrl
          label="Premier nombre"
          value={a}
          min={2}
          max={60}
          step={1}
          onChange={(v) => setA(Math.round(v))}
          display={String(a)}
        />
        <Ctrl
          label="Second nombre"
          value={b}
          min={2}
          max={60}
          step={1}
          onChange={(v) => setB(Math.round(v))}
          display={String(b)}
          color={PALETTE.purple}
        />
      </Panel>

      {vue === "diviseurs" ? (
        <div className="space-y-2 rounded-xl border border-border bg-white p-3">
          <p className="text-xs font-medium text-muted-foreground">Diviseurs de {a}</p>
          <div className="flex flex-wrap gap-1.5">
            {da.map((d) => pastille(d, communs.includes(d), `a${d}`))}
          </div>
          <p className="pt-1 text-xs font-medium text-muted-foreground">Diviseurs de {b}</p>
          <div className="flex flex-wrap gap-1.5">
            {db.map((d) => pastille(d, communs.includes(d), `b${d}`))}
          </div>
        </div>
      ) : (
        <div className="space-y-2 rounded-xl border border-border bg-white p-3">
          <p className="text-xs font-medium text-muted-foreground">Multiples de {a}</p>
          <div className="flex flex-wrap gap-1.5">
            {ma.map((m) => pastille(m, m === premierCommun, `ma${m}`))}
          </div>
          <p className="pt-1 text-xs font-medium text-muted-foreground">Multiples de {b}</p>
          <div className="flex flex-wrap gap-1.5">
            {mb.map((m) => pastille(m, m === premierCommun, `mb${m}`))}
          </div>
        </div>
      )}

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Diviseurs communs" value={communs.join(" · ")} />
        <Stat label="PGCD" value={String(g)} color={PALETTE.green} />
        <Stat label="PPCM" value={String(p)} color={PALETTE.purple} />
      </div>

      <Verdict tone={g === 1 ? "warn" : "ok"}>
        {g === 1
          ? `${a} et ${b} n'ont que 1 comme diviseur commun : ils sont premiers entre eux, et la fraction ${a}/${b} est déjà irréductible.`
          : `Le plus grand des diviseurs communs vaut ${g}. Vérifie la relation du cours : PGCD × PPCM = ${g} × ${p} = ${g * p}, et ${a} × ${b} = ${a * b}.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 1 — Les deux algorithmes du PGCD                           */
/* ------------------------------------------------------------------ */

export function AlgoEuclide() {
  const [a, setA] = useState(48);
  const [b, setB] = useState(18);
  const [methode, setMethode] = useState<"euclide" | "soustractions">("euclide");

  type Etape = { gauche: number; droite: number; texte: string };
  const etapes: Etape[] = [];
  let x = Math.max(a, b);
  let y = Math.min(a, b);
  let garde = 0;
  if (methode === "euclide") {
    while (y > 0 && garde < 40) {
      const q = Math.floor(x / y);
      const r = x % y;
      etapes.push({ gauche: x, droite: y, texte: `${x} = ${y} × ${q} + ${r}` });
      x = y;
      y = r;
      garde++;
    }
  } else {
    while (x !== y && garde < 60) {
      const grand = Math.max(x, y);
      const petit = Math.min(x, y);
      etapes.push({
        gauche: grand,
        droite: petit,
        texte: `${grand} − ${petit} = ${grand - petit}`,
      });
      x = grand - petit;
      y = petit;
      garde++;
    }
  }
  const resultat = x;

  return (
    <div className="space-y-3">
      <Choice
        label="Méthode"
        value={methode}
        options={[
          { value: "euclide", label: "Divisions d'Euclide" },
          { value: "soustractions", label: "Soustractions successives" },
        ]}
        onChange={setMethode}
      />

      <Panel>
        <Ctrl
          label="Premier nombre"
          value={a}
          min={2}
          max={120}
          step={1}
          onChange={(v) => setA(Math.round(v))}
          display={String(a)}
        />
        <Ctrl
          label="Second nombre"
          value={b}
          min={2}
          max={120}
          step={1}
          onChange={(v) => setB(Math.round(v))}
          display={String(b)}
          color={PALETTE.purple}
        />
      </Panel>

      <div className="rounded-xl border border-border bg-white p-3">
        <ol className="space-y-1.5">
          {etapes.map((e, i) => (
            <li key={i} className="flex items-baseline gap-3">
              <span className="w-6 shrink-0 text-right font-mono text-xs text-muted-foreground">
                {i + 1}
              </span>
              <span className="font-mono text-sm text-foreground">{e.texte}</span>
            </li>
          ))}
        </ol>
        {etapes.length === 0 ? (
          <p className="text-sm text-muted-foreground">Les deux nombres sont déjà égaux.</p>
        ) : null}
      </div>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Nombre d'étapes" value={String(etapes.length)} color={PALETTE.blue} />
        <Stat label="PGCD obtenu" value={String(resultat)} color={PALETTE.green} />
      </div>

      <Verdict tone="ok">
        {methode === "euclide"
          ? "On s'arrête quand le reste devient nul : le PGCD est le dernier diviseur utilisé. Compare le nombre d'étapes avec l'autre méthode, tu verras pourquoi on préfère Euclide."
          : "On remplace à chaque fois le grand nombre par la différence, et on s'arrête quand les deux sont égaux. C'est simple à comprendre, mais bien plus long qu'Euclide."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 1 — Rendre une fraction irréductible                       */
/* ------------------------------------------------------------------ */

export function FractionIrreductible() {
  const [num, setNum] = useState(84);
  const [den, setDen] = useState(126);

  const g = pgcd(num, den);
  const n2 = num / g;
  const d2 = den / g;

  // etapes de simplification par facteurs premiers successifs
  const etapes: string[] = [];
  let n = num;
  let d = den;
  for (const p of [2, 3, 5, 7, 11, 13]) {
    while (n % p === 0 && d % p === 0) {
      etapes.push(`÷ ${p}  →  ${n / p} / ${d / p}`);
      n /= p;
      d /= p;
    }
  }

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Numérateur"
          value={num}
          min={2}
          max={200}
          step={1}
          onChange={(v) => setNum(Math.round(v))}
          display={String(num)}
        />
        <Ctrl
          label="Dénominateur"
          value={den}
          min={2}
          max={200}
          step={1}
          onChange={(v) => setDen(Math.round(v))}
          display={String(den)}
          color={PALETTE.purple}
        />
      </Panel>

      <div className="rounded-xl border border-border bg-white p-4">
        <div className="flex items-center justify-center gap-5">
          <div className="text-center">
            <p className="font-mono text-xl font-semibold text-foreground">{num}</p>
            <div className="my-1 h-px bg-foreground" />
            <p className="font-mono text-xl font-semibold text-foreground">{den}</p>
          </div>
          <span className="text-2xl text-muted-foreground">=</span>
          <div className="text-center">
            <p className="font-mono text-xl font-bold" style={{ color: PALETTE.green }}>
              {n2}
            </p>
            <div className="my-1 h-px" style={{ backgroundColor: PALETTE.green }} />
            <p className="font-mono text-xl font-bold" style={{ color: PALETTE.green }}>
              {d2}
            </p>
          </div>
        </div>
        {etapes.length > 0 ? (
          <ol className="mt-4 space-y-1">
            {etapes.map((e, i) => (
              <li key={i} className="text-center font-mono text-xs text-muted-foreground">
                {e}
              </li>
            ))}
          </ol>
        ) : null}
      </div>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="PGCD du numérateur et du dénominateur"
          value={String(g)}
          color={PALETTE.blue}
        />
        <Stat label="Divisions successives" value={String(etapes.length)} />
      </div>

      <Verdict tone="ok">
        {g === 1
          ? `${num}/${den} était déjà irréductible : le numérateur et le dénominateur sont premiers entre eux, leur PGCD vaut 1.`
          : `${n2}/${d2} est irréductible : son numérateur et son dénominateur n'ont plus aucun diviseur commun. Remarque qu'une seule division par le PGCD, ${g}, donnait le résultat d'un coup, au lieu des ${etapes.length} étapes ci-dessus.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 2 — Les radicaux                                           */
/* ------------------------------------------------------------------ */

export function Radicaux() {
  const [n, setN] = useState(72);

  // n = k^2 * r avec r sans facteur carre
  let k = 1;
  let r = Math.round(n);
  for (let d = 2; d * d <= r; d++) {
    while (r % (d * d) === 0) {
      k *= d;
      r /= d * d;
    }
  }
  const exact = k > 1;
  const valeur = Math.sqrt(n);
  const entier = Number.isInteger(valeur);

  const W = 400;
  const H = 150;
  const cote = clamp(Math.sqrt(n) * 9, 20, 108);

  return (
    <div className="space-y-3">
      <Ctrl
        label="Nombre sous le radical"
        value={n}
        min={2}
        max={200}
        step={1}
        onChange={(v) => setN(Math.round(v))}
        display={String(n)}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <rect
          x={28}
          y={(H - cote) / 2}
          width={cote}
          height={cote}
          fill={PALETTE.blue}
          opacity={0.18}
          stroke={PALETTE.blue}
          strokeWidth={2}
        />
        <text
          x={28 + cote / 2}
          y={(H - cote) / 2 - 8}
          textAnchor="middle"
          fontSize={11}
          fill={PALETTE.blue}
        >
          aire = {n}
        </text>
        <text
          x={28 + cote / 2}
          y={(H + cote) / 2 + 18}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.blue}
        >
          côté = {fmt(valeur, 3)}
        </text>
        <text x={200} y={H / 2 - 10} fontSize={18} fontFamily="Georgia, serif" fill={PALETTE.ink}>
          √{n} = {exact ? `${k}√${r}` : `√${n}`}
        </text>
        <text x={200} y={H / 2 + 16} fontSize={13} fill={PALETTE.slate}>
          ≈ {fmt(valeur, 4)}
        </text>
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Facteur sorti" value={String(k)} color={PALETTE.green} />
        <Stat label="Reste sous le radical" value={String(r)} color={PALETTE.purple} />
        <Stat label="Valeur approchée" value={fmt(valeur, 4)} />
      </div>

      <Verdict tone={entier ? "ok" : exact ? "ok" : "warn"}>
        {entier
          ? `${n} est un carré parfait : sa racine, ${valeur}, est un nombre entier.`
          : exact
            ? `On sort le plus grand carré possible : √${n} = √(${k * k} × ${r}) = ${k}√${r}. C'est la forme la plus simple, et elle reste exacte.`
            : `${n} ne contient aucun facteur carré, donc √${n} ne se simplifie pas. On le laisse tel quel plutôt que d'écrire une valeur approchée.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 2 — Comparer et encadrer des nombres réels                 */
/* ------------------------------------------------------------------ */

export function ComparerReels() {
  const [choix, setChoix] = useState<string>("racine2");
  const [precision, setPrecision] = useState(1);

  const NOMBRES = [
    { value: "racine2", label: "√2", v: Math.SQRT2 },
    { value: "racine10", label: "√10", v: Math.sqrt(10) },
    { value: "pi", label: "π", v: Math.PI },
    { value: "tiers", label: "7/3", v: 7 / 3 },
    { value: "racine50", label: "√50", v: Math.sqrt(50) },
  ] as const;

  const nb = NOMBRES.find((x) => x.value === choix) ?? NOMBRES[0];
  const ETIQUETTES = ["à l'unité", "au dixième", "au centième", "au millième"];
  const pas = Math.pow(10, -precision);
  const bas = Math.floor(nb.v / pas) * pas;
  const haut = bas + pas;

  const W = 440;
  const H = 150;
  const marge = 36;
  // on zoome d'un facteur 10 a chaque decimale gagnee : la fenetre suit l'encadrement
  const demi = 2 * pas;
  const vMin = bas - demi;
  const vMax = haut + demi;
  const sx = (v: number) => marge + ((v - vMin) / (vMax - vMin)) * (W - 2 * marge);
  const graduations = [0, 1, 2, 3, 4, 5].map((i) => bas - demi + i * pas);

  return (
    <div className="space-y-3">
      <Choice
        label="Nombre à encadrer"
        value={choix}
        options={NOMBRES.map((o) => ({ value: o.value as string, label: o.label }))}
        onChange={setChoix}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line x1={marge} y1={82} x2={W - marge} y2={82} stroke={PALETTE.axis} strokeWidth={1.6} />
        {graduations.map((v, i) => (
          <g key={i}>
            <line x1={sx(v)} y1={76} x2={sx(v)} y2={88} stroke={PALETTE.slate} strokeWidth={1.2} />
            <text x={sx(v)} y={104} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
              {fmt(v, precision)}
            </text>
          </g>
        ))}
        <rect
          x={sx(bas)}
          y={66}
          width={Math.max(2, sx(haut) - sx(bas))}
          height={32}
          fill={PALETTE.green}
          opacity={0.25}
        />
        <line x1={sx(bas)} y1={58} x2={sx(bas)} y2={94} stroke={PALETTE.green} strokeWidth={2.4} />
        <line
          x1={sx(haut)}
          y1={58}
          x2={sx(haut)}
          y2={94}
          stroke={PALETTE.green}
          strokeWidth={2.4}
        />
        <circle cx={sx(nb.v)} cy={82} r={6} fill={PALETTE.red} stroke="#ffffff" strokeWidth={2} />
        <text
          x={sx(nb.v)}
          y={50}
          textAnchor="middle"
          fontSize={14}
          fontWeight={700}
          fill={PALETTE.red}
        >
          {nb.label}
        </text>
        <text
          x={W / 2}
          y={132}
          textAnchor="middle"
          fontSize={13}
          fontFamily="Georgia, serif"
          fill={PALETTE.ink}
        >
          {fmt(bas, precision)} &lt; {nb.label} &lt; {fmt(haut, precision)}
        </text>
      </Board>

      <Ctrl
        label="Précision de l'encadrement"
        value={precision}
        min={0}
        max={3}
        step={1}
        onChange={(v) => setPrecision(Math.round(v))}
        display={ETIQUETTES[precision] ?? "à l'unité"}
        color={PALETTE.green}
      />

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Valeur exacte" value={fmt(nb.v, 6)} color={PALETTE.red} />
        <Stat label="Borne basse" value={fmt(bas, precision)} color={PALETTE.green} />
        <Stat label="Amplitude" value={fmt(pas, precision)} />
      </div>

      <Verdict tone="ok">
        Chaque fois que tu gagnes une décimale, l&apos;encadrement devient dix fois plus serré. Et
        remarque que {nb.label} ne tombe jamais exactement sur une borne : c&apos;est bien un nombre
        qui n&apos;a pas d&apos;écriture décimale qui s&apos;arrête.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 2 — Les puissances d'exposant entier relatif               */
/* ------------------------------------------------------------------ */

export function PuissancesRelatives() {
  const [base, setBase] = useState(10);
  const [n, setN] = useState(3);
  const [m, setM] = useState(-5);

  const pn = Math.pow(base, n);
  const pm = Math.pow(base, m);
  const produit = n + m;
  const quotient = n - m;

  function ecrit(v: number): string {
    if (!Number.isFinite(v)) return "—";
    if (Math.abs(v) >= 1e6 || (Math.abs(v) < 1e-4 && v !== 0)) return v.toExponential(3);
    return fmt(v, 6);
  }

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Base"
          value={base}
          min={2}
          max={10}
          step={1}
          onChange={(v) => setBase(Math.round(v))}
          display={String(base)}
        />
        <Ctrl
          label="Premier exposant"
          value={n}
          min={-6}
          max={6}
          step={1}
          onChange={(v) => setN(Math.round(v))}
          display={String(n)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Second exposant"
          value={m}
          min={-6}
          max={6}
          step={1}
          onChange={(v) => setM(Math.round(v))}
          display={String(m)}
          color={PALETTE.purple}
        />
      </Panel>

      <div className="space-y-2 rounded-xl border border-border bg-white p-4">
        <p className="text-center font-mono text-sm text-foreground">
          {base}
          <sup>{n}</sup> = {ecrit(pn)}
          {n < 0 ? `  =  1 / ${base}^${-n}` : ""}
        </p>
        <p className="text-center font-mono text-sm text-foreground">
          {base}
          <sup>{m}</sup> = {ecrit(pm)}
          {m < 0 ? `  =  1 / ${base}^${-m}` : ""}
        </p>
        <div className="my-2 h-px bg-border" />
        <p className="text-center font-mono text-sm font-semibold" style={{ color: PALETTE.green }}>
          {base}
          <sup>{n}</sup> × {base}
          <sup>{m}</sup> = {base}
          <sup>{produit}</sup> = {ecrit(Math.pow(base, produit))}
        </p>
        <p
          className="text-center font-mono text-sm font-semibold"
          style={{ color: PALETTE.orange }}
        >
          {base}
          <sup>{n}</sup> ÷ {base}
          <sup>{m}</sup> = {base}
          <sup>{quotient}</sup> = {ecrit(Math.pow(base, quotient))}
        </p>
      </div>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Exposants additionnés"
          value={`${n} + (${m}) = ${produit}`}
          color={PALETTE.green}
        />
        <Stat
          label="Exposants soustraits"
          value={`${n} − (${m}) = ${quotient}`}
          color={PALETTE.orange}
        />
      </div>

      <Verdict tone="ok">
        Pour multiplier, on <strong>ajoute</strong> les exposants ; pour diviser, on les{" "}
        <strong>soustrait</strong>. Mets un exposant négatif et vérifie la règle qui surprend le
        plus : un exposant négatif donne l&apos;inverse, pas un nombre négatif.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 3 — Développer par le modèle des aires                     */
/* ------------------------------------------------------------------ */

export function DevelopperAires() {
  const [a, setA] = useState(1);
  const [b, setB] = useState(3);
  const [c, setC] = useState(1);
  const [d, setD] = useState(2);

  // (a x + b)(c x + d) = ac x^2 + (ad + bc) x + bd
  const t1 = a * c;
  const t2 = a * d + b * c;
  const t3 = b * d;

  const W = 420;
  const H = 252;
  const x0 = 96;
  const y0 = 42;
  const lx = 150;
  const lb = 92;
  const ly = 110;
  const ld = 62;

  function terme(coef: number, suffixe: string): string {
    if (coef === 0) return "0";
    if (suffixe === "") return String(coef);
    if (coef === 1) return suffixe;
    if (coef === -1) return "−" + suffixe;
    return `${coef}${suffixe}`;
  }

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text
          x={x0 + lx / 2}
          y={y0 - 12}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={PALETTE.blue}
        >
          {terme(a, "x")}
        </text>
        <text
          x={x0 + lx + lb / 2}
          y={y0 - 12}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={PALETTE.blue}
        >
          {b}
        </text>
        <text
          x={x0 - 14}
          y={y0 + ly / 2}
          textAnchor="end"
          fontSize={13}
          fontWeight={700}
          fill={PALETTE.purple}
        >
          {terme(c, "x")}
        </text>
        <text
          x={x0 - 14}
          y={y0 + ly + ld / 2}
          textAnchor="end"
          fontSize={13}
          fontWeight={700}
          fill={PALETTE.purple}
        >
          {d}
        </text>

        <rect
          x={x0}
          y={y0}
          width={lx}
          height={ly}
          fill="#dbeafe"
          stroke={PALETTE.slate}
          strokeWidth={1.4}
        />
        <text
          x={x0 + lx / 2}
          y={y0 + ly / 2 + 5}
          textAnchor="middle"
          fontSize={14}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {terme(t1, "x²")}
        </text>

        <rect
          x={x0 + lx}
          y={y0}
          width={lb}
          height={ly}
          fill="#fef3c7"
          stroke={PALETTE.slate}
          strokeWidth={1.4}
        />
        <text
          x={x0 + lx + lb / 2}
          y={y0 + ly / 2 + 5}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {terme(a * d, "x")}
        </text>

        <rect
          x={x0}
          y={y0 + ly}
          width={lx}
          height={ld}
          fill="#fef3c7"
          stroke={PALETTE.slate}
          strokeWidth={1.4}
        />
        <text
          x={x0 + lx / 2}
          y={y0 + ly + ld / 2 + 5}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {terme(b * c, "x")}
        </text>

        <rect
          x={x0 + lx}
          y={y0 + ly}
          width={lb}
          height={ld}
          fill="#dcfce7"
          stroke={PALETTE.slate}
          strokeWidth={1.4}
        />
        <text
          x={x0 + lx + lb / 2}
          y={y0 + ly + ld / 2 + 5}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {t3}
        </text>

        <text x={W / 2} y={H - 12} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          l&apos;aire totale du grand rectangle est la somme des quatre morceaux
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="a"
          value={a}
          min={1}
          max={5}
          step={1}
          onChange={(v) => setA(Math.round(v))}
          display={String(a)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="b"
          value={b}
          min={1}
          max={8}
          step={1}
          onChange={(v) => setB(Math.round(v))}
          display={String(b)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="c"
          value={c}
          min={1}
          max={5}
          step={1}
          onChange={(v) => setC(Math.round(v))}
          display={String(c)}
          color={PALETTE.purple}
        />
        <Ctrl
          label="d"
          value={d}
          min={1}
          max={8}
          step={1}
          onChange={(v) => setD(Math.round(v))}
          display={String(d)}
          color={PALETTE.purple}
        />
      </Panel>

      <div className="rounded-xl border border-border bg-white p-3 text-center">
        <p className="font-mono text-sm font-semibold text-foreground">
          ({terme(a, "x")} + {b})({terme(c, "x")} + {d}) = {terme(t1, "x²")} + {terme(t2, "x")} +{" "}
          {t3}
        </p>
      </div>

      <Verdict tone={a === c && b === d ? "ok" : "warn"}>
        {a === c && b === d
          ? `Les deux facteurs sont identiques : tu viens de retrouver l'identité remarquable (${terme(a, "x")} + ${b})² = ${terme(t1, "x²")} + ${terme(t2, "x")} + ${t3}.`
          : "Le terme du milieu vient de deux rectangles jaunes, pas d'un seul. C'est l'oubli le plus fréquent quand on développe sans dessin."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 3 — Polynômes : degré, valeur, racine                      */
/* ------------------------------------------------------------------ */

export function Polynomes() {
  const [a, setA] = useState(1);
  const [b, setB] = useState(-3);
  const [c, setC] = useState(2);
  const [x, setX] = useState(1);

  const degre = a !== 0 ? 2 : b !== 0 ? 1 : c !== 0 ? 0 : -1;
  const valeur = a * x * x + b * x + c;
  const racine = Math.abs(valeur) < 1e-9;

  const W = 420;
  const H = 230;
  const s = makeScales(W, H, -4, 5, -5, 7, 28);

  const trace = curvePath((xx) => a * xx * xx + b * xx + c, s);

  function terme(coef: number, suffixe: string, premier: boolean): string {
    if (coef === 0) return "";
    const signe = coef > 0 ? (premier ? "" : " + ") : premier ? "−" : " − ";
    const abs = Math.abs(coef);
    const nombre = abs === 1 && suffixe !== "" ? "" : String(abs);
    return `${signe}${nombre}${suffixe}`;
  }

  const ecriture =
    degre === -1
      ? "P(x) = 0"
      : "P(x) = " +
        [terme(a, "x²", true), terme(b, "x", a === 0), terme(c, "", a === 0 && b === 0)]
          .filter((t) => t !== "")
          .join("");

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={1} />
        <path d={trace} fill="none" stroke={PALETTE.blue} strokeWidth={2.6} />
        <line
          x1={s.sx(x)}
          y1={s.sy(0)}
          x2={s.sx(x)}
          y2={s.sy(clamp(valeur, -5, 7))}
          stroke={PALETTE.red}
          strokeWidth={1.6}
          strokeDasharray="5 4"
        />
        <circle
          cx={s.sx(x)}
          cy={s.sy(clamp(valeur, -5, 7))}
          r={6}
          fill={racine ? PALETTE.green : PALETTE.red}
        />
      </Board>

      <Panel>
        <Ctrl
          label="Coefficient de x²"
          value={a}
          min={-3}
          max={3}
          step={1}
          onChange={(v) => setA(Math.round(v))}
          display={String(a)}
        />
        <Ctrl
          label="Coefficient de x"
          value={b}
          min={-6}
          max={6}
          step={1}
          onChange={(v) => setB(Math.round(v))}
          display={String(b)}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Terme constant"
          value={c}
          min={-6}
          max={6}
          step={1}
          onChange={(v) => setC(Math.round(v))}
          display={String(c)}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Valeur de x"
          value={x}
          min={-4}
          max={5}
          step={0.1}
          onChange={setX}
          display={fmt(x, 1)}
          color={PALETTE.red}
        />
      </Panel>

      <div className="rounded-xl border border-border bg-white p-3 text-center">
        <p className="font-mono text-sm font-semibold text-foreground">{ecriture}</p>
      </div>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Degré" value={degre === -1 ? "aucun" : String(degre)} color={PALETTE.blue} />
        <Stat label={`P(${fmt(x, 1)})`} value={fmt(valeur, 2)} color={PALETTE.red} />
        <Stat
          label="Racine ?"
          value={racine ? "oui" : "non"}
          color={racine ? PALETTE.green : PALETTE.slate}
        />
      </div>

      <Verdict tone={racine ? "ok" : "warn"}>
        {racine
          ? `P(${fmt(x, 1)}) = 0 : ce nombre est une racine du polynôme, et la courbe coupe bien l'axe des abscisses en ce point.`
          : "Déplace x jusqu'à ce que la courbe traverse l'axe horizontal : tu auras trouvé une racine. Le degré, lui, se lit sur le coefficient de plus haut rang non nul."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 3 — Fractions rationnelles et valeurs interdites           */
/* ------------------------------------------------------------------ */

export function FractionRationnelle() {
  const [p, setP] = useState(2);
  const [q, setQ] = useState(-3);
  const [x, setX] = useState(0);

  // (x - p) / (x - q)
  const interdite = Math.abs(x - q) < 1e-9;
  const valeur = interdite ? NaN : (x - p) / (x - q);
  const annule = Math.abs(x - p) < 1e-9;

  const W = 420;
  const H = 150;
  const marge = 34;
  const vMin = -6;
  const vMax = 6;
  const sx = (v: number) => marge + ((v - vMin) / (vMax - vMin)) * (W - 2 * marge);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line x1={marge} y1={76} x2={W - marge} y2={76} stroke={PALETTE.axis} strokeWidth={1.6} />
        {[-6, -4, -2, 0, 2, 4, 6].map((v) => (
          <g key={v}>
            <line x1={sx(v)} y1={70} x2={sx(v)} y2={82} stroke={PALETTE.slate} strokeWidth={1.2} />
            <text x={sx(v)} y={98} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
              {v}
            </text>
          </g>
        ))}
        <g>
          <line x1={sx(q)} y1={48} x2={sx(q)} y2={104} stroke={PALETTE.red} strokeWidth={2.6} />
          <text
            x={sx(q)}
            y={40}
            textAnchor="middle"
            fontSize={11}
            fontWeight={700}
            fill={PALETTE.red}
          >
            interdite
          </text>
        </g>
        <g>
          <circle cx={sx(p)} cy={76} r={6} fill="none" stroke={PALETTE.green} strokeWidth={2.4} />
          <text
            x={sx(p)}
            y={124}
            textAnchor="middle"
            fontSize={11}
            fontWeight={700}
            fill={PALETTE.green}
          >
            s&apos;annule
          </text>
        </g>
        <circle cx={sx(x)} cy={76} r={5} fill={PALETTE.orange} stroke="#ffffff" strokeWidth={2} />
      </Board>

      <Panel>
        <Ctrl
          label="Racine du numérateur"
          value={p}
          min={-5}
          max={5}
          step={1}
          onChange={(v) => setP(Math.round(v))}
          display={String(p)}
          color={PALETTE.green}
        />
        <Ctrl
          label="Racine du dénominateur"
          value={q}
          min={-5}
          max={5}
          step={1}
          onChange={(v) => setQ(Math.round(v))}
          display={String(q)}
          color={PALETTE.red}
        />
        <Ctrl
          label="Valeur de x"
          value={x}
          min={-6}
          max={6}
          step={0.1}
          onChange={setX}
          display={fmt(x, 1)}
          color={PALETTE.orange}
        />
      </Panel>

      <div className="rounded-xl border border-border bg-white p-3 text-center">
        <p className="font-mono text-sm font-semibold text-foreground">
          F(x) = ({binome(p)}) / ({binome(q)})
        </p>
        <p
          className="mt-2 font-mono text-sm"
          style={{ color: interdite ? PALETTE.red : PALETTE.ink }}
        >
          F({fmt(x, 1)}) = {interdite ? "impossible, division par zéro" : fmt(valeur, 3)}
        </p>
      </div>

      <Verdict tone={interdite ? "bad" : annule ? "ok" : "warn"}>
        {interdite
          ? `x = ${q} annule le dénominateur : c'est la valeur interdite. L'ensemble de définition est ℝ privé de ${q}.`
          : annule
            ? `x = ${p} annule le numérateur sans annuler le dénominateur, donc F(${p}) = 0. C'est une racine de la fraction.`
            : "Amène x sur le trait rouge pour voir ce qui se passe, puis sur le cercle vert. Une fraction s'annule quand son numérateur s'annule, jamais quand c'est le dénominateur."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 4 — La balance pour résoudre une équation                  */
/* ------------------------------------------------------------------ */

export function BalanceEquation() {
  const [a, setA] = useState(3);
  const [b, setB] = useState(5);
  const [c, setC] = useState(14);
  const [essai, setEssai] = useState(2);

  // a x + b = c
  const solution = a !== 0 ? (c - b) / a : NaN;
  const gauche = a * essai + b;
  const equilibre = Math.abs(gauche - c) < 1e-9;
  const penche = gauche - c;

  const W = 440;
  const H = 210;
  const cx = W / 2;
  const pivotY = 150;
  const inclinaison = clamp(penche * 3, -16, 16);

  const xg = cx - 120;
  const xd = cx + 120;
  const yg = 86 + inclinaison;
  const yd = 86 - inclinaison;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <polygon
          points={`${cx},${pivotY - 52} ${cx - 22},${pivotY} ${cx + 22},${pivotY}`}
          fill={PALETTE.slate}
        />
        <line
          x1={cx}
          y1={pivotY - 52}
          x2={cx}
          y2={pivotY - 64}
          stroke={PALETTE.slate}
          strokeWidth={4}
        />
        <line
          x1={xg}
          y1={yg}
          x2={xd}
          y2={yd}
          stroke={PALETTE.ink}
          strokeWidth={4}
          strokeLinecap="round"
        />

        <line x1={xg} y1={yg} x2={xg} y2={yg + 26} stroke={PALETTE.slate} strokeWidth={1.6} />
        <rect
          x={xg - 54}
          y={yg + 26}
          width={108}
          height={30}
          rx={5}
          fill={PALETTE.blue}
          opacity={0.85}
        />
        <text x={xg} y={yg + 46} textAnchor="middle" fontSize={13} fontWeight={700} fill="#ffffff">
          {a}x + {b}
        </text>
        <text x={xg} y={yg + 72} textAnchor="middle" fontSize={12} fill={PALETTE.blue}>
          = {fmt(gauche, 2)}
        </text>

        <line x1={xd} y1={yd} x2={xd} y2={yd + 26} stroke={PALETTE.slate} strokeWidth={1.6} />
        <rect
          x={xd - 54}
          y={yd + 26}
          width={108}
          height={30}
          rx={5}
          fill={PALETTE.orange}
          opacity={0.85}
        />
        <text x={xd} y={yd + 46} textAnchor="middle" fontSize={13} fontWeight={700} fill="#ffffff">
          {c}
        </text>

        <text
          x={cx}
          y={24}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={equilibre ? PALETTE.green : PALETTE.slate}
        >
          {equilibre
            ? "la balance est en équilibre"
            : penche > 0
              ? "trop lourd à gauche"
              : "trop lourd à droite"}
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Coefficient de x"
          value={a}
          min={1}
          max={8}
          step={1}
          onChange={(v) => setA(Math.round(v))}
          display={String(a)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Terme ajouté"
          value={b}
          min={-10}
          max={15}
          step={1}
          onChange={(v) => setB(Math.round(v))}
          display={String(b)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Membre de droite"
          value={c}
          min={-10}
          max={40}
          step={1}
          onChange={(v) => setC(Math.round(v))}
          display={String(c)}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Ta valeur de x"
          value={essai}
          min={-6}
          max={12}
          step={0.5}
          onChange={setEssai}
          display={fmt(essai, 1)}
          color={PALETTE.red}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Écart entre les deux plateaux"
          value={fmt(penche, 2)}
          color={equilibre ? PALETTE.green : PALETTE.red}
        />
        <Stat label="Solution exacte" value={fmt(solution, 3)} color={PALETTE.green} />
      </div>

      <Verdict tone={equilibre ? "ok" : "warn"}>
        {equilibre
          ? `x = ${fmt(essai, 2)} équilibre la balance : c'est la solution. Par le calcul : on retranche ${b} des deux côtés, puis on divise par ${a}.`
          : `La balance penche. Retranche ${b} des deux plateaux, puis partage en ${a} parts égales : tu obtiendras x = ${fmt(solution, 3)}.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 4 — Équation produit et équation quotient                  */
/* ------------------------------------------------------------------ */

export function EquationProduit() {
  const [p, setP] = useState(3);
  const [q, setQ] = useState(-2);
  const [mode, setMode] = useState<"produit" | "quotient">("produit");
  const [x, setX] = useState(0);

  const f1 = x - p;
  const f2 = x - q;
  const valeur = mode === "produit" ? f1 * f2 : Math.abs(f2) < 1e-9 ? NaN : f1 / f2;
  const estSolution =
    mode === "produit" ? Math.abs(valeur) < 1e-9 : Math.abs(f1) < 1e-9 && Math.abs(f2) > 1e-9;

  const W = 420;
  const H = 150;
  const marge = 34;
  const sx = (v: number) => marge + ((v + 6) / 12) * (W - 2 * marge);

  return (
    <div className="space-y-3">
      <Choice
        value={mode}
        options={[
          { value: "produit", label: "Équation produit" },
          { value: "quotient", label: "Équation quotient" },
        ]}
        onChange={setMode}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line x1={marge} y1={78} x2={W - marge} y2={78} stroke={PALETTE.axis} strokeWidth={1.6} />
        {[-6, -4, -2, 0, 2, 4, 6].map((v) => (
          <g key={v}>
            <line x1={sx(v)} y1={72} x2={sx(v)} y2={84} stroke={PALETTE.slate} strokeWidth={1.2} />
            <text x={sx(v)} y={100} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
              {v}
            </text>
          </g>
        ))}
        <circle cx={sx(p)} cy={78} r={8} fill={PALETTE.green} opacity={0.85} />
        <text
          x={sx(p)}
          y={54}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.green}
        >
          x = {p}
        </text>
        {mode === "produit" ? (
          <>
            <circle cx={sx(q)} cy={78} r={8} fill={PALETTE.green} opacity={0.85} />
            <text
              x={sx(q)}
              y={54}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill={PALETTE.green}
            >
              x = {q}
            </text>
          </>
        ) : (
          <>
            <line x1={sx(q)} y1={54} x2={sx(q)} y2={104} stroke={PALETTE.red} strokeWidth={2.6} />
            <text
              x={sx(q)}
              y={46}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill={PALETTE.red}
            >
              interdite
            </text>
          </>
        )}
        <circle cx={sx(x)} cy={78} r={5} fill={PALETTE.orange} stroke="#ffffff" strokeWidth={2} />
        <text
          x={W / 2}
          y={132}
          textAnchor="middle"
          fontSize={12}
          fontFamily="Georgia, serif"
          fill={PALETTE.ink}
        >
          {mode === "produit"
            ? `(${binome(p)})(${binome(q)}) = 0`
            : `(${binome(p)}) / (${binome(q)}) = 0`}
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Premier nombre"
          value={p}
          min={-5}
          max={5}
          step={1}
          onChange={(v) => setP(Math.round(v))}
          display={String(p)}
          color={PALETTE.green}
        />
        <Ctrl
          label="Second nombre"
          value={q}
          min={-5}
          max={5}
          step={1}
          onChange={(v) => setQ(Math.round(v))}
          display={String(q)}
          color={mode === "produit" ? PALETTE.green : PALETTE.red}
        />
        <Ctrl
          label="Ta valeur de x"
          value={x}
          min={-6}
          max={6}
          step={0.5}
          onChange={setX}
          display={fmt(x, 1)}
          color={PALETTE.orange}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label={binome(p)} value={fmt(f1, 2)} />
        <Stat label={binome(q)} value={fmt(f2, 2)} />
        <Stat
          label="Résultat"
          value={Number.isNaN(valeur) ? "impossible" : fmt(valeur, 2)}
          color={estSolution ? PALETTE.green : PALETTE.slate}
        />
      </div>

      <Verdict tone={estSolution ? "ok" : "warn"}>
        {mode === "produit"
          ? estSolution
            ? "Un produit est nul dès qu'un seul de ses facteurs l'est. Il y a donc deux solutions, et tu viens d'en trouver une."
            : `Aucun des deux facteurs n'est nul, donc le produit ne l'est pas. Place x sur ${p} ou sur ${q}.`
          : estSolution
            ? "Une fraction s'annule quand son numérateur s'annule, à condition que le dénominateur ne s'annule pas en même temps."
            : `Seul x = ${p} convient, et encore faut-il que ${p} ne soit pas la valeur interdite. Essaie de mettre les deux nombres égaux pour voir le piège.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 6 — Application affine par intervalles                     */
/* ------------------------------------------------------------------ */

export function AffineMorceaux() {
  const [seuil, setSeuil] = useState(30);
  const [forfait, setForfait] = useState(5000);
  const [prixUnite, setPrixUnite] = useState(100);
  const [conso, setConso] = useState(20);

  const prix = (x: number) => (x <= seuil ? forfait : forfait + prixUnite * (x - seuil));
  const aPayer = prix(conso);

  const W = 440;
  const H = 244;
  const xMax = 80;
  const yMax = forfait + prixUnite * (xMax - seuil) * 1.1;
  const s = makeScales(W, H, 0, xMax, 0, yMax, 44);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(xMax)}
          y2={s.sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(0)}
          y2={s.sy(yMax)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        {[0, 20, 40, 60, 80].map((g) => (
          <g key={`gx${g}`}>
            <line
              x1={s.sx(g)}
              y1={s.sy(0)}
              x2={s.sx(g)}
              y2={s.sy(0) + 5}
              stroke={PALETTE.slate}
              strokeWidth={1.1}
            />
            <text
              x={s.sx(g)}
              y={s.sy(0) + 16}
              textAnchor="middle"
              fontSize={9}
              fill={PALETTE.slate}
            >
              {g}
            </text>
          </g>
        ))}
        {[forfait, prix(xMax)].map((v, i) => (
          <g key={`gy${i}`}>
            <line
              x1={s.sx(0) - 5}
              y1={s.sy(v)}
              x2={s.sx(0)}
              y2={s.sy(v)}
              stroke={PALETTE.slate}
              strokeWidth={1.1}
            />
            <text
              x={s.sx(0) - 8}
              y={s.sy(v) + 4}
              textAnchor="end"
              fontSize={9}
              fill={PALETTE.slate}
            >
              {fmt(v, 0)}
            </text>
          </g>
        ))}
        <line
          x1={s.sx(0)}
          y1={s.sy(forfait)}
          x2={s.sx(seuil)}
          y2={s.sy(forfait)}
          stroke={PALETTE.blue}
          strokeWidth={3}
        />
        <line
          x1={s.sx(seuil)}
          y1={s.sy(forfait)}
          x2={s.sx(xMax)}
          y2={s.sy(prix(xMax))}
          stroke={PALETTE.purple}
          strokeWidth={3}
        />
        <line
          x1={s.sx(seuil)}
          y1={s.sy(0)}
          x2={s.sx(seuil)}
          y2={s.sy(prix(seuil))}
          stroke={PALETTE.gridStrong}
          strokeWidth={1.2}
          strokeDasharray="5 4"
        />
        <text
          x={s.sx(seuil)}
          y={s.sy(0) + 30}
          textAnchor="middle"
          fontSize={10}
          fontWeight={700}
          fill={PALETTE.purple}
        >
          seuil : {seuil} Go
        </text>
        <circle cx={s.sx(conso)} cy={s.sy(aPayer)} r={6} fill={PALETTE.red} />
        <line
          x1={s.sx(conso)}
          y1={s.sy(0)}
          x2={s.sx(conso)}
          y2={s.sy(aPayer)}
          stroke={PALETTE.red}
          strokeWidth={1.3}
          strokeDasharray="4 4"
        />
        <text x={s.sx(0) + 6} y={s.sy(yMax) + 14} fontSize={10} fill={PALETTE.slate}>
          prix en FCFA
        </text>
        <text x={s.sx(xMax)} y={s.sy(0) - 8} textAnchor="end" fontSize={10} fill={PALETTE.slate}>
          consommation en Go
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Forfait inclus"
          value={seuil}
          min={5}
          max={60}
          step={5}
          onChange={setSeuil}
          display={`${fmt(seuil, 0)} Go`}
        />
        <Ctrl
          label="Prix du forfait"
          value={forfait}
          min={1000}
          max={15000}
          step={500}
          onChange={setForfait}
          display={`${fmt(forfait, 0)} F`}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Prix du Go en plus"
          value={prixUnite}
          min={0}
          max={400}
          step={25}
          onChange={setPrixUnite}
          display={`${fmt(prixUnite, 0)} F`}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Ta consommation"
          value={conso}
          min={0}
          max={xMax}
          step={1}
          onChange={setConso}
          display={`${fmt(conso, 0)} Go`}
          color={PALETTE.red}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Montant à payer" value={`${fmt(aPayer, 0)} FCFA`} color={PALETTE.red} />
        <Stat
          label="Partie de la courbe"
          value={conso <= seuil ? "constante" : "affine croissante"}
          color={conso <= seuil ? PALETTE.blue : PALETTE.purple}
        />
      </div>

      <Verdict tone="ok">
        Avant le seuil, le prix ne bouge pas : l&apos;application est constante. Après, chaque Go
        coûte {fmt(prixUnite, 0)} FCFA, et la droite remonte avec ce coefficient directeur.
        C&apos;est exactement la forme d&apos;un forfait téléphonique.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 7 — Les diagrammes statistiques                            */
/* ------------------------------------------------------------------ */

export function DiagrammesStats() {
  const [v1, setV1] = useState(8);
  const [v2, setV2] = useState(14);
  const [v3, setV3] = useState(20);
  const [v4, setV4] = useState(10);
  const [type, setType] = useState<"batons" | "circulaire" | "histogramme">("batons");

  const vals = [v1, v2, v3, v4];
  const noms = ["Maths", "Français", "SVT", "Histoire"];
  const total = vals.reduce((a, b) => a + b, 0);
  const couleurs = [PALETTE.blue, PALETTE.green, PALETTE.orange, PALETTE.purple];

  const W = 420;
  const H = 230;
  const maxV = Math.max(...vals, 1);

  let angle = -Math.PI / 2;
  const parts = vals.map((v) => {
    const a0 = angle;
    const a1 = angle + (v / Math.max(total, 1)) * 2 * Math.PI;
    angle = a1;
    return { a0, a1, v };
  });

  function arc(a0: number, a1: number, r: number, cx: number, cy: number) {
    const x0 = cx + r * Math.cos(a0);
    const y0 = cy + r * Math.sin(a0);
    const x1 = cx + r * Math.cos(a1);
    const y1 = cy + r * Math.sin(a1);
    const grand = a1 - a0 > Math.PI ? 1 : 0;
    return `M${cx},${cy} L${x0},${y0} A${r},${r} 0 ${grand} 1 ${x1},${y1} Z`;
  }

  return (
    <div className="space-y-3">
      <Choice
        label="Type de diagramme"
        value={type}
        options={[
          { value: "batons", label: "En bâtons" },
          { value: "histogramme", label: "Histogramme" },
          { value: "circulaire", label: "Circulaire" },
        ]}
        onChange={setType}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {type === "circulaire" ? (
          <g>
            {parts.map((p, i) => (
              <path
                key={i}
                d={arc(p.a0, p.a1, 78, 140, 112)}
                fill={couleurs[i] ?? PALETTE.slate}
                opacity={0.88}
              />
            ))}
            {vals.map((v, i) => (
              <g key={i}>
                <rect
                  x={250}
                  y={44 + i * 28}
                  width={14}
                  height={14}
                  fill={couleurs[i] ?? PALETTE.slate}
                />
                <text x={272} y={56 + i * 28} fontSize={11} fill={PALETTE.ink}>
                  {noms[i]} — {fmt((v / Math.max(total, 1)) * 360, 0)}°
                </text>
              </g>
            ))}
          </g>
        ) : (
          <g>
            <line x1={46} y1={186} x2={W - 24} y2={186} stroke={PALETTE.axis} strokeWidth={1.4} />
            <line x1={46} y1={186} x2={46} y2={30} stroke={PALETTE.axis} strokeWidth={1.4} />
            {vals.map((v, i) => {
              const h = (v / maxV) * 134;
              const largeur = type === "histogramme" ? 82 : 22;
              const x = 64 + i * 86 + (type === "histogramme" ? 0 : 30);
              return (
                <g key={i}>
                  <rect
                    x={x}
                    y={186 - h}
                    width={largeur}
                    height={h}
                    fill={couleurs[i] ?? PALETTE.slate}
                    opacity={0.88}
                  />
                  <text
                    x={x + largeur / 2}
                    y={202}
                    textAnchor="middle"
                    fontSize={10}
                    fill={PALETTE.slate}
                  >
                    {noms[i]}
                  </text>
                  <text
                    x={x + largeur / 2}
                    y={180 - h}
                    textAnchor="middle"
                    fontSize={11}
                    fontWeight={700}
                    fill={PALETTE.ink}
                  >
                    {v}
                  </text>
                </g>
              );
            })}
          </g>
        )}
      </Board>

      <Panel>
        {vals.map((v, i) => (
          <Ctrl
            key={i}
            label={noms[i] ?? ""}
            value={v}
            min={0}
            max={30}
            step={1}
            onChange={(nv) => [setV1, setV2, setV3, setV4][i]?.(Math.round(nv))}
            display={String(v)}
            color={couleurs[i] ?? PALETTE.blue}
          />
        ))}
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Effectif total" value={String(total)} color={PALETTE.blue} />
        <Stat
          label="Angle d'un élève"
          value={`${fmt(360 / Math.max(total, 1), 2)}°`}
          color={PALETTE.purple}
        />
      </div>

      <Verdict tone="ok">
        {type === "circulaire"
          ? `Chaque secteur vaut sa fréquence multipliée par 360°. Vérifie : la somme des quatre angles fait bien 360°.`
          : type === "histogramme"
            ? "Dans un histogramme, c'est l'aire du rectangle qui représente l'effectif, et les barres se touchent car les classes sont contiguës."
            : "Dans un diagramme en bâtons, c'est la hauteur qui compte, et les bâtons restent séparés car les valeurs sont distinctes."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 13 — Coordonnées d'un vecteur                              */
/* ------------------------------------------------------------------ */

export function CoordonneesVecteur() {
  const [ax, setAx] = useState(-2);
  const [ay, setAy] = useState(-1);
  const [bx, setBx] = useState(3);
  const [by, setBy] = useState(2);
  const [cx2, setCx2] = useState(1);
  const [cy2, setCy2] = useState(-3);

  const ux = bx - ax;
  const uy = by - ay;
  const vx = cx2 - ax;
  const vy = cy2 - ay;
  const det = ux * vy - uy * vx;
  const scal = ux * vx + uy * vy;
  const norme = Math.hypot(ux, uy);

  const W = 420;
  const H = 300;
  const s = makeScales(W, H, -6, 6, -5, 5, 26);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={1} />
        <Arrow
          x1={s.sx(ax)}
          y1={s.sy(ay)}
          x2={s.sx(bx)}
          y2={s.sy(by)}
          color={PALETTE.blue}
          width={3}
        />
        <Arrow
          x1={s.sx(ax)}
          y1={s.sy(ay)}
          x2={s.sx(cx2)}
          y2={s.sy(cy2)}
          color={PALETTE.purple}
          width={3}
        />
        <line
          x1={s.sx(ax)}
          y1={s.sy(ay)}
          x2={s.sx(bx)}
          y2={s.sy(ay)}
          stroke={PALETTE.blue}
          strokeWidth={1.2}
          strokeDasharray="4 4"
        />
        <line
          x1={s.sx(bx)}
          y1={s.sy(ay)}
          x2={s.sx(bx)}
          y2={s.sy(by)}
          stroke={PALETTE.blue}
          strokeWidth={1.2}
          strokeDasharray="4 4"
        />
        <text
          x={(s.sx(ax) + s.sx(bx)) / 2}
          y={s.sy(ay) + 16}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.blue}
        >
          {ux}
        </text>
        <text
          x={s.sx(bx) + 10}
          y={(s.sy(ay) + s.sy(by)) / 2}
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.blue}
        >
          {uy}
        </text>
        {[
          { x: ax, y: ay, n: "A", c: PALETTE.ink },
          { x: bx, y: by, n: "B", c: PALETTE.blue },
          { x: cx2, y: cy2, n: "C", c: PALETTE.purple },
        ].map((p, i) => (
          <g key={i}>
            <circle cx={s.sx(p.x)} cy={s.sy(p.y)} r={5} fill={p.c} />
            <text x={s.sx(p.x) + 9} y={s.sy(p.y) - 8} fontSize={12} fontWeight={700} fill={p.c}>
              {p.n}
            </text>
          </g>
        ))}
      </Board>

      <Panel>
        <Ctrl
          label="A : abscisse"
          value={ax}
          min={-5}
          max={5}
          step={1}
          onChange={(v) => setAx(Math.round(v))}
          display={String(ax)}
        />
        <Ctrl
          label="A : ordonnée"
          value={ay}
          min={-4}
          max={4}
          step={1}
          onChange={(v) => setAy(Math.round(v))}
          display={String(ay)}
        />
        <Ctrl
          label="B : abscisse"
          value={bx}
          min={-5}
          max={5}
          step={1}
          onChange={(v) => setBx(Math.round(v))}
          display={String(bx)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="B : ordonnée"
          value={by}
          min={-4}
          max={4}
          step={1}
          onChange={(v) => setBy(Math.round(v))}
          display={String(by)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="C : abscisse"
          value={cx2}
          min={-5}
          max={5}
          step={1}
          onChange={(v) => setCx2(Math.round(v))}
          display={String(cx2)}
          color={PALETTE.purple}
        />
        <Ctrl
          label="C : ordonnée"
          value={cy2}
          min={-4}
          max={4}
          step={1}
          onChange={(v) => setCy2(Math.round(v))}
          display={String(cy2)}
          color={PALETTE.purple}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Coordonnées de AB" value={`(${ux} ; ${uy})`} color={PALETTE.blue} />
        <Stat label="Coordonnées de AC" value={`(${vx} ; ${vy})`} color={PALETTE.purple} />
        <Stat label="Longueur de AB" value={fmt(norme, 3)} />
        <Stat
          label="Déterminant"
          value={String(det)}
          color={det === 0 ? PALETTE.green : PALETTE.slate}
        />
      </div>

      <Verdict tone={det === 0 ? "ok" : scal === 0 ? "ok" : "warn"}>
        {det === 0
          ? "Le déterminant est nul : les deux vecteurs sont colinéaires, donc A, B et C sont alignés."
          : scal === 0
            ? "Le produit scalaire est nul : les deux vecteurs sont orthogonaux, l'angle en A est droit."
            : "Les coordonnées d'un vecteur se lisent en soustrayant : abscisse de l'arrivée moins abscisse du départ. Déplace C jusqu'à annuler le déterminant pour aligner les trois points."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 15 — La droite passant par deux points                     */
/* ------------------------------------------------------------------ */

export function DroiteDeuxPoints() {
  const [ax, setAx] = useState(-3);
  const [ay, setAy] = useState(-1);
  const [bx, setBx] = useState(2);
  const [by, setBy] = useState(3);
  const [m2, setM2] = useState(-0.6);
  const [p2, setP2] = useState(1);

  const verticale = ax === bx;
  const m = verticale ? NaN : (by - ay) / (bx - ax);
  const p = verticale ? NaN : ay - m * ax;

  const paralleles = !verticale && Math.abs(m - m2) < 1e-9;
  const confondues = paralleles && Math.abs(p - p2) < 1e-9;

  const W = 420;
  const H = 300;
  const s = makeScales(W, H, -6, 6, -5, 5, 26);

  const xi = !paralleles && !verticale ? (p2 - p) / (m - m2) : NaN;
  const yi = Number.isFinite(xi) ? m * xi + p : NaN;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={1} />
        <path d={linePath(m2, p2, s)} fill="none" stroke={PALETTE.purple} strokeWidth={2.4} />
        {verticale ? (
          <line
            x1={s.sx(ax)}
            y1={s.sy(-5)}
            x2={s.sx(ax)}
            y2={s.sy(5)}
            stroke={PALETTE.blue}
            strokeWidth={2.8}
          />
        ) : (
          <path d={linePath(m, p, s)} fill="none" stroke={PALETTE.blue} strokeWidth={2.8} />
        )}
        {Number.isFinite(xi) && Math.abs(xi) <= 6 && Math.abs(yi) <= 5 ? (
          <circle
            cx={s.sx(xi)}
            cy={s.sy(yi)}
            r={6}
            fill={PALETTE.red}
            stroke="#ffffff"
            strokeWidth={2}
          />
        ) : null}
        {[
          { x: ax, y: ay, n: "A" },
          { x: bx, y: by, n: "B" },
        ].map((q, i) => (
          <g key={i}>
            <circle cx={s.sx(q.x)} cy={s.sy(q.y)} r={5.5} fill={PALETTE.blue} />
            <text
              x={s.sx(q.x) + 9}
              y={s.sy(q.y) - 8}
              fontSize={12}
              fontWeight={700}
              fill={PALETTE.blue}
              stroke="#ffffff"
              strokeWidth={3}
              paintOrder="stroke"
            >
              {q.n}
            </text>
          </g>
        ))}
      </Board>

      <Panel>
        <Ctrl
          label="A : abscisse"
          value={ax}
          min={-5}
          max={5}
          step={1}
          onChange={(v) => setAx(Math.round(v))}
          display={String(ax)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="A : ordonnée"
          value={ay}
          min={-4}
          max={4}
          step={1}
          onChange={(v) => setAy(Math.round(v))}
          display={String(ay)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="B : abscisse"
          value={bx}
          min={-5}
          max={5}
          step={1}
          onChange={(v) => setBx(Math.round(v))}
          display={String(bx)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="B : ordonnée"
          value={by}
          min={-4}
          max={4}
          step={1}
          onChange={(v) => setBy(Math.round(v))}
          display={String(by)}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Seconde droite : pente"
          value={m2}
          min={-3}
          max={3}
          step={0.1}
          onChange={setM2}
          display={fmt(m2, 1)}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Seconde droite : ordonnée à l'origine"
          value={p2}
          min={-4}
          max={4}
          step={0.5}
          onChange={setP2}
          display={fmt(p2, 1)}
          color={PALETTE.purple}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Coefficient directeur"
          value={verticale ? "non défini" : fmt(m, 3)}
          color={PALETTE.blue}
        />
        <Stat
          label="Ordonnée à l'origine"
          value={verticale ? "—" : fmt(p, 3)}
          color={PALETTE.blue}
        />
        <Stat
          label="Équation de (AB)"
          value={verticale ? `x = ${ax}` : `y = ${fmt(m, 2)}x + ${fmt(p, 2)}`}
        />
        <Stat
          label="Position des deux droites"
          value={confondues ? "confondues" : paralleles ? "parallèles" : "sécantes"}
          color={paralleles ? PALETTE.orange : PALETTE.green}
        />
      </div>

      <Verdict tone={verticale ? "bad" : confondues ? "warn" : paralleles ? "warn" : "ok"}>
        {verticale
          ? "A et B ont la même abscisse : la droite est verticale, son équation s'écrit x = constante et elle n'a pas de coefficient directeur."
          : confondues
            ? "Même pente et même ordonnée à l'origine : les deux droites sont confondues, elles ont une infinité de points communs."
            : paralleles
              ? "Même coefficient directeur mais ordonnées à l'origine différentes : les droites sont parallèles et ne se croisent jamais."
              : `Le coefficient directeur est la différence des ordonnées divisée par celle des abscisses : (${by} − ${ay}) / (${bx} − ${ax}) = ${by - ay} / ${bx - ax} = ${fmt(m, 3)}. Les deux droites se coupent en un seul point.`}
      </Verdict>
    </div>
  );
}
