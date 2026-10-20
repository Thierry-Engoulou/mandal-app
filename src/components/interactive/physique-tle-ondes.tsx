import { useState } from "react";
import {
  Arrow,
  Board,
  Choice,
  Ctrl,
  PALETTE,
  Panel,
  Stat,
  Verdict,
  curvePath,
  fmt,
  makeScales,
} from "./controls";

/** Simulations du programme de Physique Terminale C et D — modules 3 et 4. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* Chapitre 11 — Charge et décharge d'un condensateur                  */
/* ------------------------------------------------------------------ */

export function CondensateurCharge() {
  const [resistance, setResistance] = useState(10);
  const [capacite, setCapacite] = useState(47);
  const [phase, setPhase] = useState<"charge" | "decharge">("charge");

  const E = 6;
  const tau = resistance * 1e3 * capacite * 1e-6;
  const tMax = 5 * tau;

  const W = 440;
  const H = 230;
  const s = makeScales(W, H, 0, tMax, 0, E * 1.12, 34);

  const u = (t: number) =>
    phase === "charge" ? E * (1 - Math.exp(-t / tau)) : E * Math.exp(-t / tau);
  const uTau = u(tau);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(tMax)}
          y2={s.sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(0)}
          y2={s.sy(E * 1.12)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(E)}
          x2={s.sx(tMax)}
          y2={s.sy(E)}
          stroke={PALETTE.gridStrong}
          strokeWidth={1.2}
          strokeDasharray="6 5"
        />
        <text
          x={s.sx(tMax) - 4}
          y={s.sy(E) - 7}
          textAnchor="end"
          fontSize={10}
          fill={PALETTE.slate}
        >
          E = 6 V
        </text>
        {[1, 2, 3, 4, 5].map((k) => (
          <g key={k}>
            <line
              x1={s.sx(k * tau)}
              y1={s.sy(0)}
              x2={s.sx(k * tau)}
              y2={s.sy(0) + 5}
              stroke={PALETTE.slate}
              strokeWidth={1}
            />
            <text
              x={s.sx(k * tau)}
              y={s.sy(0) + 18}
              textAnchor="middle"
              fontSize={10}
              fill={PALETTE.slate}
            >
              {k}τ
            </text>
          </g>
        ))}
        <path d={curvePath(u, s, 320)} fill="none" stroke={PALETTE.blue} strokeWidth={2.8} />
        <line
          x1={s.sx(tau)}
          y1={s.sy(0)}
          x2={s.sx(tau)}
          y2={s.sy(uTau)}
          stroke={PALETTE.red}
          strokeWidth={1.6}
          strokeDasharray="5 4"
        />
        <circle cx={s.sx(tau)} cy={s.sy(uTau)} r={5} fill={PALETTE.red} />
        <text
          x={s.sx(tau) + 10}
          y={s.sy(uTau) + 22}
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.red}
        >
          {fmt(uTau, 2)} V
        </text>
      </Board>

      <Choice
        value={phase}
        options={[
          { value: "charge", label: "Charge" },
          { value: "decharge", label: "Décharge" },
        ]}
        onChange={setPhase}
      />

      <Panel>
        <Ctrl
          label="Résistance"
          value={resistance}
          min={1}
          max={50}
          step={1}
          onChange={setResistance}
          display={`${fmt(resistance, 0)} kΩ`}
        />
        <Ctrl
          label="Capacité"
          value={capacite}
          min={5}
          max={200}
          step={5}
          onChange={setCapacite}
          display={`${fmt(capacite, 0)} µF`}
          color={PALETTE.purple}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Constante de temps" value={`${fmt(tau, 3)} s`} color={PALETTE.red} />
        <Stat label="Tension à t = τ" value={`${fmt(uTau, 2)} V`} color={PALETTE.blue} />
        <Stat label="Régime établi" value={`${fmt(5 * tau, 2)} s`} />
      </div>

      <Verdict tone="ok">
        {phase === "charge"
          ? `À t = τ, la tension atteint 63 % de E, soit ${fmt(uTau, 2)} V. Multiplie R ou C par deux et la courbe s'étire d'autant.`
          : `À t = τ, il ne reste que 37 % de E, soit ${fmt(uTau, 2)} V. La décharge suit exactement la même constante de temps que la charge.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 12 — Oscillations libres d'un circuit RLC                  */
/* ------------------------------------------------------------------ */

export function CircuitRlc() {
  const [inductance, setInductance] = useState(0.1);
  const [capacite, setCapacite] = useState(10);
  const [resistance, setResistance] = useState(20);

  const L = inductance;
  const C = capacite * 1e-6;
  const R = resistance;
  const Rc = 2 * Math.sqrt(L / C);
  const T0 = 2 * Math.PI * Math.sqrt(L * C);
  const amorti = R / (2 * L);
  const sousCritique = R < Rc;
  const omega = sousCritique ? Math.sqrt(1 / (L * C) - amorti * amorti) : 0;
  const pseudoT = sousCritique && omega > 0 ? (2 * Math.PI) / omega : 0;

  const tMax = 6 * T0;
  const W = 440;
  const H = 240;
  const s = makeScales(W, H, 0, tMax, -6.4, 6.4, 28);

  const u = (t: number) => {
    if (sousCritique) return 6 * Math.exp(-amorti * t) * Math.cos(omega * t);
    const r = Math.sqrt(Math.max(amorti * amorti - 1 / (L * C), 0));
    return 6 * Math.exp(-(amorti - r) * t);
  };
  const env = (t: number) => 6 * Math.exp(-amorti * t);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(tMax)}
          y2={s.sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(-6.4)}
          x2={s.sx(0)}
          y2={s.sy(6.4)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        {sousCritique ? (
          <>
            <path
              d={curvePath(env, s, 260)}
              fill="none"
              stroke={PALETTE.red}
              strokeWidth={1.3}
              strokeDasharray="6 4"
            />
            <path
              d={curvePath((t) => -env(t), s, 260)}
              fill="none"
              stroke={PALETTE.red}
              strokeWidth={1.3}
              strokeDasharray="6 4"
            />
          </>
        ) : null}
        <path d={curvePath(u, s, 420)} fill="none" stroke={PALETTE.blue} strokeWidth={2.6} />
        <text x={W - 24} y={s.sy(0) - 10} textAnchor="end" fontSize={11} fill={PALETTE.slate}>
          tension aux bornes du condensateur
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Inductance"
          value={inductance}
          min={0.02}
          max={0.4}
          step={0.02}
          onChange={setInductance}
          display={`${fmt(inductance, 2)} H`}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Capacité"
          value={capacite}
          min={2}
          max={50}
          step={1}
          onChange={setCapacite}
          display={`${fmt(capacite, 0)} µF`}
        />
        <Ctrl
          label="Résistance"
          value={resistance}
          min={0}
          max={400}
          step={10}
          onChange={setResistance}
          display={`${fmt(resistance, 0)} Ω`}
          color={PALETTE.red}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Période propre T₀" value={`${fmt(T0 * 1000, 2)} ms`} color={PALETTE.blue} />
        <Stat label="Pseudo-période" value={pseudoT > 0 ? `${fmt(pseudoT * 1000, 2)} ms` : "—"} />
        <Stat label="Résistance critique" value={`${fmt(Rc, 0)} Ω`} color={PALETTE.red} />
      </div>

      <Verdict tone={R === 0 ? "ok" : sousCritique ? "warn" : "bad"}>
        {R === 0
          ? `Sans résistance, rien ne se perd : les oscillations durent indéfiniment, de période T₀ = 2π√(LC) = ${fmt(T0 * 1000, 2)} ms.`
          : sousCritique
            ? "Régime pseudo-périodique : le circuit oscille encore, mais l'amplitude décroît en exponentielle. Monte la résistance jusqu'à la valeur critique."
            : "Régime apériodique : la résistance dépasse la valeur critique, la tension revient à zéro sans osciller une seule fois."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 12 — Résonance d'intensité                                 */
/* ------------------------------------------------------------------ */

export function ResonanceRlc() {
  const [resistance, setResistance] = useState(20);
  const [inductance, setInductance] = useState(0.2);
  const [capacite, setCapacite] = useState(5);
  const [frequence, setFrequence] = useState(159);

  const L = inductance;
  const C = capacite * 1e-6;
  const U = 12;
  const omega0 = 1 / Math.sqrt(L * C);
  const N0 = omega0 / (2 * Math.PI);
  const Q = (L * omega0) / resistance;

  const w = 2 * Math.PI * frequence;
  const reactance = L * w - 1 / (C * w);
  const Z = Math.sqrt(resistance * resistance + reactance * reactance);
  const I = U / Z;
  const Imax = U / resistance;
  const phi = (Math.atan2(reactance, resistance) * 180) / Math.PI;

  const nMax = N0 * 3;
  const W = 440;
  const H = 240;
  const s = makeScales(W, H, 0, nMax, 0, Imax * 1.12, 30);

  const courbe = (n: number) => {
    if (n < 1) return NaN;
    const ww = 2 * Math.PI * n;
    const x = L * ww - 1 / (C * ww);
    return U / Math.sqrt(resistance * resistance + x * x);
  };

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(nMax)}
          y2={s.sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(0)}
          y2={s.sy(Imax * 1.12)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(N0)}
          y1={s.sy(0)}
          x2={s.sx(N0)}
          y2={s.sy(Imax)}
          stroke={PALETTE.green}
          strokeWidth={1.4}
          strokeDasharray="5 4"
        />
        <text
          x={s.sx(N0)}
          y={s.sy(Imax) - 8}
          textAnchor="middle"
          fontSize={10}
          fontWeight={700}
          fill={PALETTE.green}
        >
          N₀ = {fmt(N0, 0)} Hz
        </text>
        <path d={curvePath(courbe, s, 420)} fill="none" stroke={PALETTE.blue} strokeWidth={2.6} />
        <line
          x1={s.sx(frequence)}
          y1={s.sy(0)}
          x2={s.sx(frequence)}
          y2={s.sy(I)}
          stroke={PALETTE.red}
          strokeWidth={1.6}
        />
        <circle cx={s.sx(frequence)} cy={s.sy(I)} r={5.5} fill={PALETTE.red} />
        <text x={s.sx(0) + 8} y={H - 10} fontSize={10} fill={PALETTE.slate}>
          intensité efficace en fonction de la fréquence
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Fréquence du générateur"
          value={frequence}
          min={5}
          max={Math.round(nMax)}
          step={1}
          onChange={setFrequence}
          display={`${fmt(frequence, 0)} Hz`}
          color={PALETTE.red}
        />
        <Ctrl
          label="Résistance"
          value={resistance}
          min={5}
          max={120}
          step={5}
          onChange={setResistance}
          display={`${fmt(resistance, 0)} Ω`}
        />
        <Ctrl
          label="Inductance"
          value={inductance}
          min={0.05}
          max={0.5}
          step={0.05}
          onChange={setInductance}
          display={`${fmt(inductance, 2)} H`}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Capacité"
          value={capacite}
          min={1}
          max={20}
          step={1}
          onChange={setCapacite}
          display={`${fmt(capacite, 0)} µF`}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Impédance" value={`${fmt(Z, 1)} Ω`} />
        <Stat label="Intensité" value={`${fmt(I, 3)} A`} color={PALETTE.red} />
        <Stat label="Déphasage" value={`${fmt(phi, 0)}°`} color={PALETTE.purple} />
        <Stat label="Facteur de qualité" value={fmt(Q, 1)} color={PALETTE.green} />
      </div>

      <Verdict tone={Math.abs(frequence - N0) < N0 * 0.03 ? "ok" : "warn"}>
        {Math.abs(frequence - N0) < N0 * 0.03
          ? `Tu es à la résonance : l'impédance se réduit à R, le déphasage s'annule et l'intensité est maximale. La surtension aux bornes de la bobine vaut Q = ${fmt(Q, 1)} fois la tension du générateur.`
          : "Baisse la résistance : le pic devient plus haut et plus étroit, car le facteur de qualité augmente. Le circuit devient alors très sélectif, comme un poste de radio."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 13 — Caractéristique d'un capteur                          */
/* ------------------------------------------------------------------ */

type Capteur = {
  value: string;
  label: string;
  unite: string;
  min: number;
  max: number;
  loi: (x: number) => number;
  lineaire: boolean;
  note: string;
};

const CAPTEUR_PAR_DEFAUT: Capteur = {
  value: "ctn",
  label: "Thermistance CTN",
  unite: "°C",
  min: 0,
  max: 100,
  loi: (t) => 10 * Math.exp(3500 * (1 / (t + 273) - 1 / 298)),
  lineaire: false,
  note: "La résistance chute quand la température monte. La loi est exponentielle, donc très sensible mais pas du tout linéaire.",
};

const CAPTEURS: ReadonlyArray<Capteur> = [
  CAPTEUR_PAR_DEFAUT,
  {
    value: "ldr",
    label: "Photorésistance",
    unite: "lux",
    min: 1,
    max: 1000,
    loi: (e) => 500 / Math.pow(e, 0.8),
    lineaire: false,
    note: "Dans le noir elle vaut des centaines de kilohms, en plein jour quelques centaines d'ohms. Elle est lente mais très bon marché.",
  },
  {
    value: "pt100",
    label: "Sonde platine Pt100",
    unite: "°C",
    min: 0,
    max: 200,
    loi: (t) => 0.1 * (100 + 0.385 * t),
    lineaire: true,
    note: "Celle-ci est linéaire : R = 100 + 0,385·T. L'étalonnage est immédiat, c'est pourquoi on l'emploie en métrologie.",
  },
  {
    value: "jauge",
    label: "Jauge de contrainte",
    unite: "bar",
    min: 0,
    max: 10,
    loi: (p) => 0.12 * (120 + 2.1 * p),
    lineaire: true,
    note: "La résistance augmente proportionnellement à la déformation, donc à la pression. On en monte quatre en pont de Wheatstone.",
  },
];

export function CapteurCaracteristique() {
  const [choix, setChoix] = useState("ctn");
  const c = CAPTEURS.find((x) => x.value === choix) ?? CAPTEUR_PAR_DEFAUT;
  const [entree, setEntree] = useState(25);

  const x = clamp(entree, c.min, c.max);
  const R = c.loi(x);

  const echantillons: number[] = [];
  for (let i = 0; i <= 60; i++) echantillons.push(c.loi(c.min + ((c.max - c.min) * i) / 60));
  const rMax = Math.max(...echantillons) * 1.1;

  const W = 430;
  const H = 230;
  const s = makeScales(W, H, c.min, c.max, 0, rMax, 34);

  // diviseur de tension avec une résistance fixe de 10 kΩ
  const Rfixe = 10;
  const sortie = (5 * Rfixe) / (Rfixe + R);

  return (
    <div className="space-y-3">
      <Choice
        label="Choisis un capteur"
        value={choix}
        options={CAPTEURS.map((o) => ({ value: o.value, label: o.label }))}
        onChange={(v) => {
          setChoix(v);
          const next = CAPTEURS.find((o) => o.value === v);
          if (next) setEntree((next.min + next.max) / 3);
        }}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={s.sx(c.min)}
          y1={s.sy(0)}
          x2={s.sx(c.max)}
          y2={s.sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(c.min)}
          y1={s.sy(0)}
          x2={s.sx(c.min)}
          y2={s.sy(rMax)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <path
          d={curvePath((v) => c.loi(v), s, 300)}
          fill="none"
          stroke={PALETTE.blue}
          strokeWidth={2.6}
        />
        <line
          x1={s.sx(x)}
          y1={s.sy(0)}
          x2={s.sx(x)}
          y2={s.sy(Math.min(R, rMax))}
          stroke={PALETTE.red}
          strokeWidth={1.5}
          strokeDasharray="5 4"
        />
        <circle cx={s.sx(x)} cy={s.sy(Math.min(R, rMax))} r={5.5} fill={PALETTE.red} />
        <text x={s.sx(c.max)} y={s.sy(0) + 19} textAnchor="end" fontSize={10} fill={PALETTE.slate}>
          grandeur d&apos;entrée ({c.unite})
        </text>
        <text x={s.sx(c.min) + 6} y={s.sy(rMax) + 13} fontSize={10} fill={PALETTE.slate}>
          résistance (kΩ)
        </text>
      </Board>

      <Ctrl
        label={`Grandeur mesurée (${c.unite})`}
        value={x}
        min={c.min}
        max={c.max}
        step={(c.max - c.min) / 100}
        onChange={setEntree}
        display={`${fmt(x, 1)} ${c.unite}`}
        color={PALETTE.red}
      />

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Résistance du capteur" value={`${fmt(R, 2)} kΩ`} color={PALETTE.blue} />
        <Stat label="Sortie du diviseur" value={`${fmt(sortie, 2)} V`} color={PALETTE.green} />
        <Stat label="Linéarité" value={c.lineaire ? "linéaire" : "non linéaire"} />
      </div>

      <Verdict tone={sortie > 2.5 ? "ok" : "warn"}>
        {c.note} Avec une résistance fixe de 10 kΩ sous 5 V, la sortie vaut {fmt(sortie, 2)} V, donc
        le comparateur réglé à 2,5 V {sortie > 2.5 ? "a basculé" : "n'a pas encore basculé"}.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 15 — Onde progressive le long d'une corde                  */
/* ------------------------------------------------------------------ */

export function OndeProgressive() {
  const [frequence, setFrequence] = useState(50);
  const [celerite, setCelerite] = useState(15);
  const [temps, setTemps] = useState(0);
  const [marqueur, setMarqueur] = useState(0.36);

  const lambda = celerite / frequence;
  const T = 1 / frequence;
  const k = (2 * Math.PI) / lambda;
  const w = 2 * Math.PI * frequence;

  const xMax = 1.2;
  const W = 440;
  const H = 210;
  const s = makeScales(W, H, 0, xMax, -1.5, 1.5, 28);

  const y = (x: number) => Math.cos(w * temps - k * x);
  const rapport = marqueur / lambda;
  const reste = rapport - Math.floor(rapport);
  const enPhase = reste < 0.06 || reste > 0.94;
  const opposition = Math.abs(reste - 0.5) < 0.06;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(xMax)}
          y2={s.sy(0)}
          stroke={PALETTE.grid}
          strokeWidth={1.2}
        />
        <path d={curvePath(y, s, 420)} fill="none" stroke={PALETTE.blue} strokeWidth={2.6} />
        <line
          x1={s.sx(0)}
          y1={s.sy(-1.4)}
          x2={s.sx(lambda)}
          y2={s.sy(-1.4)}
          stroke={PALETTE.purple}
          strokeWidth={2}
        />
        <text
          x={s.sx(lambda / 2)}
          y={s.sy(-1.4) - 6}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.purple}
        >
          λ = {fmt(lambda * 100, 1)} cm
        </text>
        <circle
          cx={s.sx(0)}
          cy={s.sy(y(0))}
          r={6}
          fill={PALETTE.orange}
          stroke="#ffffff"
          strokeWidth={2}
        />
        <text x={s.sx(0) + 2} y={s.sy(1.42)} fontSize={10} fontWeight={700} fill={PALETTE.orange}>
          source
        </text>
        <circle
          cx={s.sx(marqueur)}
          cy={s.sy(y(marqueur))}
          r={6}
          fill={PALETTE.red}
          stroke="#ffffff"
          strokeWidth={2}
        />
        <line
          x1={s.sx(marqueur)}
          y1={s.sy(-1.1)}
          x2={s.sx(marqueur)}
          y2={s.sy(1.1)}
          stroke={PALETTE.red}
          strokeWidth={1}
          strokeDasharray="4 4"
        />
      </Board>

      <Panel>
        <Ctrl
          label="Fréquence"
          value={frequence}
          min={10}
          max={120}
          step={5}
          onChange={setFrequence}
          display={`${fmt(frequence, 0)} Hz`}
        />
        <Ctrl
          label="Célérité"
          value={celerite}
          min={4}
          max={40}
          step={1}
          onChange={setCelerite}
          display={`${fmt(celerite, 0)} m/s`}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Instant observé"
          value={temps}
          min={0}
          max={2 * T}
          step={T / 40}
          onChange={setTemps}
          display={`${fmt(temps * 1000, 1)} ms`}
        />
        <Ctrl
          label="Position du marqueur"
          value={marqueur}
          min={0}
          max={1.15}
          step={0.01}
          onChange={setMarqueur}
          display={`${fmt(marqueur * 100, 0)} cm`}
          color={PALETTE.red}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Longueur d'onde" value={`${fmt(lambda * 100, 1)} cm`} color={PALETTE.purple} />
        <Stat label="Période" value={`${fmt(T * 1000, 2)} ms`} />
        <Stat label="Distance / λ" value={fmt(rapport, 2)} color={PALETTE.red} />
      </div>

      <Verdict tone={enPhase ? "ok" : opposition ? "ok" : "warn"}>
        {enPhase
          ? "Le marqueur vibre en phase avec la source : leur distance est un multiple entier de λ."
          : opposition
            ? "Le marqueur vibre en opposition de phase avec la source : leur distance vaut un nombre impair de demi-longueurs d'onde."
            : "Déplace le marqueur jusqu'à ce que le rapport distance sur λ tombe sur un entier, ou sur un entier et demi."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 16 — Interférences de deux sources                         */
/* ------------------------------------------------------------------ */

export function InterferencesOndes() {
  const [ecart, setEcart] = useState(4);
  const [lambda, setLambda] = useState(0.8);
  const [sondeX, setSondeX] = useState(1.2);
  const [sondeY, setSondeY] = useState(2.4);

  const W = 420;
  const H = 300;
  const s = makeScales(W, H, -5, 5, -0.6, 6.4, 24);

  const S1 = { x: -ecart / 2, y: 0 };
  const S2 = { x: ecart / 2, y: 0 };
  const d1 = Math.hypot(sondeX - S1.x, sondeY - S1.y);
  const d2 = Math.hypot(sondeX - S2.x, sondeY - S2.y);
  const delta = d2 - d1;
  const n = delta / lambda;
  const reste = Math.abs(n - Math.round(n));
  const ventre = reste < 0.08;
  const noeud = Math.abs(reste - 0.5) < 0.08;
  const nbVentres = 2 * Math.floor(ecart / lambda) + 1;

  // hyperboles d'ordre k : on échantillonne les points où delta = k*lambda
  const lignes: Array<{ k: number; d: string }> = [];
  const kMax = Math.min(Math.floor(ecart / lambda), 12);
  for (let k = -kMax; k <= kMax; k++) {
    const pts: string[] = [];
    for (let i = 0; i <= 70; i++) {
      const yy = (6.4 * i) / 70;
      // on cherche x tel que d2 - d1 = k*lambda, par dichotomie
      let lo = -5;
      let hi = 5;
      const g = (xx: number) =>
        Math.hypot(xx - S2.x, yy - S2.y) - Math.hypot(xx - S1.x, yy - S1.y) - k * lambda;
      if (g(lo) * g(hi) > 0) continue;
      for (let it = 0; it < 32; it++) {
        const mid = (lo + hi) / 2;
        if (g(lo) * g(mid) <= 0) hi = mid;
        else lo = mid;
      }
      const xx = (lo + hi) / 2;
      pts.push(`${s.sx(xx).toFixed(1)},${s.sy(yy).toFixed(1)}`);
    }
    if (pts.length > 3) lignes.push({ k, d: `M${pts.join(" L")}` });
  }

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {lignes.map((l) => (
          <path
            key={l.k}
            d={l.d}
            fill="none"
            stroke={l.k === 0 ? PALETTE.green : PALETTE.blue}
            strokeWidth={l.k === 0 ? 2.4 : 1.6}
            opacity={l.k === 0 ? 1 : 0.55}
          />
        ))}
        {[S1, S2].map((p, i) => (
          <g key={i}>
            <circle cx={s.sx(p.x)} cy={s.sy(p.y)} r={7} fill={PALETTE.orange} />
            <text
              x={s.sx(p.x)}
              y={s.sy(p.y) + 22}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill={PALETTE.orange}
            >
              S{i + 1}
            </text>
          </g>
        ))}
        <line
          x1={s.sx(S1.x)}
          y1={s.sy(S1.y)}
          x2={s.sx(sondeX)}
          y2={s.sy(sondeY)}
          stroke={PALETTE.slate}
          strokeWidth={1}
          strokeDasharray="4 3"
        />
        <line
          x1={s.sx(S2.x)}
          y1={s.sy(S2.y)}
          x2={s.sx(sondeX)}
          y2={s.sy(sondeY)}
          stroke={PALETTE.slate}
          strokeWidth={1}
          strokeDasharray="4 3"
        />
        <circle
          cx={s.sx(sondeX)}
          cy={s.sy(sondeY)}
          r={6}
          fill={PALETTE.red}
          stroke="#ffffff"
          strokeWidth={2}
        />
        <text
          x={s.sx(sondeX) + 11}
          y={s.sy(sondeY) - 9}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.red}
        >
          M
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Écart des sources"
          value={ecart}
          min={1}
          max={8}
          step={0.5}
          onChange={setEcart}
          display={`${fmt(ecart, 1)} cm`}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Longueur d'onde"
          value={lambda}
          min={0.3}
          max={2}
          step={0.1}
          onChange={setLambda}
          display={`${fmt(lambda, 1)} cm`}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Sonde : abscisse"
          value={sondeX}
          min={-4.5}
          max={4.5}
          step={0.05}
          onChange={setSondeX}
          color={PALETTE.red}
        />
        <Ctrl
          label="Sonde : ordonnée"
          value={sondeY}
          min={0.2}
          max={6.2}
          step={0.05}
          onChange={setSondeY}
          color={PALETTE.red}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Différence de marche" value={`${fmt(delta, 2)} cm`} color={PALETTE.red} />
        <Stat label="δ / λ" value={fmt(n, 2)} color={PALETTE.purple} />
        <Stat label="Lignes ventrales" value={String(nbVentres)} color={PALETTE.blue} />
      </div>

      <Verdict tone={ventre ? "ok" : noeud ? "ok" : "warn"}>
        {ventre
          ? "Interférences constructives : δ est un multiple entier de λ, l'amplitude est maximale. M est sur une ligne ventrale."
          : noeud
            ? "Interférences destructives : δ vaut un nombre impair de demi-longueurs d'onde, les deux ondes s'annulent. M est sur une ligne nodale."
            : "Déplace la sonde jusqu'à ce que δ/λ tombe sur un entier, ou sur un entier et demi."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 17 — Fentes de Young                                       */
/* ------------------------------------------------------------------ */

export function FentesYoung() {
  const [a, setA] = useState(0.5);
  const [D, setD] = useState(2);
  const [lambdaNm, setLambdaNm] = useState(633);
  const [blanche, setBlanche] = useState<"mono" | "blanche">("mono");

  const lambda = lambdaNm * 1e-9;
  const i = (lambda * D) / (a * 1e-3);

  const W = 440;
  const H = 200;
  const demi = 0.03; // 3 cm de part et d'autre
  const sx = (x: number) => W / 2 + (x / demi) * (W / 2 - 16);

  function couleurDe(nm: number): string {
    if (nm < 450) return "#6d28d9";
    if (nm < 495) return "#2563eb";
    if (nm < 570) return "#16a34a";
    if (nm < 590) return "#ca8a04";
    if (nm < 620) return "#ea580c";
    return "#dc2626";
  }

  const bandes: Array<{ x: number; op: number; col: string }> = [];
  if (blanche === "mono") {
    const col = couleurDe(lambdaNm);
    for (let x = -demi; x <= demi; x += demi / 190) {
      const phase = (Math.PI * a * 1e-3 * x) / (lambda * D);
      bandes.push({ x, op: Math.cos(phase) ** 2, col });
    }
  } else {
    for (let x = -demi; x <= demi; x += demi / 190) {
      let r = 0;
      let g = 0;
      let b = 0;
      for (let nm = 420; nm <= 680; nm += 20) {
        const lam = nm * 1e-9;
        const phase = (Math.PI * a * 1e-3 * x) / (lam * D);
        const inten = Math.cos(phase) ** 2;
        const c = couleurDe(nm);
        r += inten * parseInt(c.slice(1, 3), 16);
        g += inten * parseInt(c.slice(3, 5), 16);
        b += inten * parseInt(c.slice(5, 7), 16);
      }
      const n = 14;
      const cl = (v: number) => Math.round(clamp((v / n) * 1.5, 0, 255));
      bandes.push({ x, op: 1, col: `rgb(${cl(r)},${cl(g)},${cl(b)})` });
    }
  }

  const largeur = (W - 32) / 190 + 1.2;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#111827" />
        {bandes.map((b, idx) => (
          <rect
            key={idx}
            x={sx(b.x) - largeur / 2}
            y={34}
            width={largeur}
            height={92}
            fill={b.col}
            opacity={b.op}
          />
        ))}
        <line
          x1={W / 2}
          y1={26}
          x2={W / 2}
          y2={134}
          stroke="#ffffff"
          strokeWidth={1}
          strokeDasharray="4 4"
          opacity={0.6}
        />
        <text x={W / 2} y={20} textAnchor="middle" fontSize={10} fill="#e5e7eb">
          frange centrale
        </text>
        {i < demi ? (
          <>
            <line x1={sx(0)} y1={148} x2={sx(i)} y2={148} stroke="#fbbf24" strokeWidth={2} />
            <text
              x={sx(i / 2)}
              y={166}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill="#fbbf24"
            >
              i = {fmt(i * 1000, 2)} mm
            </text>
          </>
        ) : null}
        <text x={W - 10} y={H - 8} textAnchor="end" fontSize={9} fill="#9ca3af">
          écran, 6 cm de large
        </text>
      </Board>

      <Choice
        value={blanche}
        options={[
          { value: "mono", label: "Lumière monochromatique" },
          { value: "blanche", label: "Lumière blanche" },
        ]}
        onChange={setBlanche}
      />

      <Panel>
        <Ctrl
          label="Écart des fentes"
          value={a}
          min={0.1}
          max={2}
          step={0.05}
          onChange={setA}
          display={`${fmt(a, 2)} mm`}
        />
        <Ctrl
          label="Distance de l'écran"
          value={D}
          min={0.5}
          max={4}
          step={0.1}
          onChange={setD}
          display={`${fmt(D, 1)} m`}
          color={PALETTE.purple}
        />
        {blanche === "mono" ? (
          <Ctrl
            label="Longueur d'onde"
            value={lambdaNm}
            min={400}
            max={700}
            step={5}
            onChange={setLambdaNm}
            display={`${fmt(lambdaNm, 0)} nm`}
            color={PALETTE.red}
          />
        ) : null}
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Interfrange i = λD/a"
          value={`${fmt(i * 1000, 2)} mm`}
          color={PALETTE.orange}
        />
        <Stat label="Franges visibles sur 6 cm" value={String(Math.floor(0.06 / i))} />
      </div>

      <Verdict tone="ok">
        {blanche === "mono"
          ? "Rapproche les fentes ou éloigne l'écran : l'interfrange grandit. C'est ainsi qu'on rend les franges mesurables à la règle."
          : "La frange centrale est blanche, car δ = 0 pour toutes les couleurs à la fois. Le violet, de plus courte longueur d'onde, est le plus proche du centre."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 18 — Effet Doppler                                         */
/* ------------------------------------------------------------------ */

export function EffetDoppler() {
  const [vitesse, setVitesse] = useState(120);
  const [frequence, setFrequence] = useState(800);

  const c = 340;
  const avant = (frequence * c) / Math.max(c - vitesse, 1);
  const arriere = (frequence * c) / (c + vitesse);
  const supersonique = vitesse >= c;

  const W = 440;
  const H = 250;
  const cy = 130;
  const xSource = W / 2;
  const pas = 30; // un front tous les 30 px, l'échelle de temps est arbitraire
  const fronts = Array.from({ length: 6 }, (_, i) => {
    const r = (i + 1) * pas;
    const dx = -(i + 1) * pas * (vitesse / c);
    return { r, cx: xSource + dx };
  });

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line x1={14} y1={cy} x2={W - 14} y2={cy} stroke={PALETTE.grid} strokeWidth={1} />
        {fronts.map((f, i) => (
          <circle
            key={i}
            cx={f.cx}
            cy={cy}
            r={f.r}
            fill="none"
            stroke={PALETTE.blue}
            strokeWidth={1.6}
            opacity={0.75 - i * 0.07}
          />
        ))}
        <Arrow x1={xSource} y1={cy} x2={xSource + 34} y2={cy} color={PALETTE.orange} width={2.6} />
        <circle cx={xSource} cy={cy} r={7} fill={PALETTE.orange} stroke="#ffffff" strokeWidth={2} />
        <text
          x={xSource}
          y={H - 14}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.orange}
        >
          source
        </text>
        <circle cx={W - 34} cy={cy} r={6} fill={PALETTE.red} />
        <text
          x={W - 34}
          y={cy + 24}
          textAnchor="middle"
          fontSize={10}
          fontWeight={700}
          fill={PALETTE.red}
        >
          devant
        </text>
        <circle cx={26} cy={cy} r={6} fill={PALETTE.green} />
        <text
          x={26}
          y={cy + 24}
          textAnchor="middle"
          fontSize={10}
          fontWeight={700}
          fill={PALETTE.green}
        >
          derrière
        </text>
        <text x={W / 2} y={22} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          les fronts se serrent devant, s&apos;écartent derrière
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Vitesse de la source"
          value={vitesse}
          min={0}
          max={400}
          step={5}
          onChange={setVitesse}
          display={`${fmt(vitesse, 0)} m/s`}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Fréquence émise"
          value={frequence}
          min={200}
          max={2000}
          step={50}
          onChange={setFrequence}
          display={`${fmt(frequence, 0)} Hz`}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat
          label="Perçue devant"
          value={supersonique ? "—" : `${fmt(avant, 0)} Hz`}
          color={PALETTE.red}
        />
        <Stat label="Émise" value={`${fmt(frequence, 0)} Hz`} />
        <Stat label="Perçue derrière" value={`${fmt(arriere, 0)} Hz`} color={PALETTE.green} />
      </div>

      <Verdict tone={supersonique ? "bad" : "ok"}>
        {supersonique
          ? "La source va plus vite que le son. Elle dépasse ses propres fronts d'onde, qui s'accumulent sur un cône : c'est le bang supersonique."
          : `L'écart entre l'avant et l'arrière atteint ${fmt(avant - arriere, 0)} Hz. C'est exactement ce que tu entends au passage d'une ambulance.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 19 — Niveaux d'énergie de l'hydrogène                      */
/* ------------------------------------------------------------------ */

export function NiveauxHydrogene() {
  const [depart, setDepart] = useState(3);
  const [arrivee, setArrivee] = useState(2);

  const En = (n: number) => -13.6 / (n * n);
  const dE = Math.abs(En(depart) - En(arrivee));
  const lambda = dE > 0 ? (1240 / dE) * 1e-9 : 0;
  const nm = lambda * 1e9;
  const emission = depart > arrivee;

  const domaine = nm < 400 ? "ultraviolet" : nm > 750 ? "infrarouge" : "visible";
  const serie =
    Math.min(depart, arrivee) === 1
      ? "Lyman"
      : Math.min(depart, arrivee) === 2
        ? "Balmer"
        : "Paschen";

  const W = 420;
  const H = 300;
  // 0 eV en haut, -13,6 eV en bas : l'energie croit vers le haut
  const yDe = (n: number) => 26 + (-En(n) / 13.6) * 236;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={46}
          y1={26}
          x2={W - 100}
          y2={26}
          stroke={PALETTE.slate}
          strokeWidth={1.4}
          strokeDasharray="5 4"
        />
        <text x={50} y={18} fontSize={10} fill={PALETTE.slate}>
          0 eV : l&apos;électron est libre, l&apos;atome est ionisé
        </text>
        {[1, 2, 3, 4, 5, 6].map((n) => (
          <g key={n}>
            <line
              x1={46}
              y1={yDe(n)}
              x2={W - 100}
              y2={yDe(n)}
              stroke={n === depart || n === arrivee ? PALETTE.ink : PALETTE.gridStrong}
              strokeWidth={n === depart || n === arrivee ? 2.6 : 1.4}
            />
            {n <= 4 || n === depart || n === arrivee ? (
              <>
                <text
                  x={34}
                  y={yDe(n) + 4}
                  textAnchor="end"
                  fontSize={11}
                  fontWeight={700}
                  fill={n === depart || n === arrivee ? PALETTE.ink : PALETTE.slate}
                >
                  n={n}
                </text>
                <text x={W - 94} y={yDe(n) + 4} fontSize={10} fill={PALETTE.slate}>
                  {fmt(En(n), 2)} eV
                </text>
              </>
            ) : null}
          </g>
        ))}
        {depart !== arrivee ? (
          <Arrow
            x1={W / 2 - 40}
            y1={yDe(depart)}
            x2={W / 2 - 40}
            y2={yDe(arrivee)}
            color={emission ? PALETTE.red : PALETTE.blue}
            width={3}
          />
        ) : null}
        {depart !== arrivee ? (
          <text
            x={W / 2 - 30}
            y={(yDe(depart) + yDe(arrivee)) / 2}
            fontSize={11}
            fontWeight={700}
            fill={emission ? PALETTE.red : PALETTE.blue}
          >
            {emission ? "émission" : "absorption"}
          </text>
        ) : null}
      </Board>

      <Panel>
        <Ctrl
          label="Niveau de départ"
          value={depart}
          min={1}
          max={6}
          step={1}
          onChange={(v) => setDepart(Math.round(v))}
          display={`n = ${fmt(depart, 0)}`}
        />
        <Ctrl
          label="Niveau d'arrivée"
          value={arrivee}
          min={1}
          max={6}
          step={1}
          onChange={(v) => setArrivee(Math.round(v))}
          display={`n = ${fmt(arrivee, 0)}`}
          color={PALETTE.purple}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat
          label="Énergie du photon"
          value={depart === arrivee ? "—" : `${fmt(dE, 2)} eV`}
          color={PALETTE.red}
        />
        <Stat
          label="Longueur d'onde"
          value={depart === arrivee ? "—" : `${fmt(nm, 0)} nm`}
          color={PALETTE.blue}
        />
        <Stat label="Série" value={depart === arrivee ? "—" : serie} />
      </div>

      <Verdict tone={depart === arrivee ? "warn" : "ok"}>
        {depart === arrivee
          ? "Choisis deux niveaux différents : sans changement de niveau, il n'y a ni émission ni absorption."
          : `Transition ${depart} → ${arrivee}, domaine ${domaine}. Pour ioniser l'atome depuis le niveau fondamental il faut 13,60 eV.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 20 — Effet photoélectrique                                 */
/* ------------------------------------------------------------------ */

const METAUX = [
  { value: "cesium", label: "Césium", W0: 1.9 },
  { value: "potassium", label: "Potassium", W0: 2.25 },
  { value: "zinc", label: "Zinc", W0: 4.3 },
  { value: "platine", label: "Platine", W0: 5.6 },
] as const;

export function Photoelectrique() {
  const [metal, setMetal] = useState<string>("cesium");
  const [lambdaNm, setLambdaNm] = useState(400);
  const [intensite, setIntensite] = useState(3);

  const m = METAUX.find((x) => x.value === metal) ?? METAUX[0];
  const W0 = m.W0;
  const E = 1240 / lambdaNm;
  const lambda0 = 1240 / W0;
  const sort = E > W0;
  const Ec = sort ? E - W0 : 0;
  const U0 = Ec;

  const W = 440;
  const H = 230;
  const cathode = 70;
  const anode = W - 70;

  const electrons = sort
    ? Array.from({ length: Math.round(intensite) }, (_, i) => ({
        x: cathode + 20 + ((anode - cathode - 30) * ((i * 37) % 100)) / 100,
        y: 70 + ((i * 53) % 90),
      }))
    : [];

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#f8fafc" />
        <rect
          x={34}
          y={34}
          width={W - 68}
          height={H - 90}
          rx={14}
          fill="#ffffff"
          stroke={PALETTE.slate}
          strokeWidth={1.6}
        />
        <rect x={cathode - 8} y={60} width={10} height={110} fill={PALETTE.slate} />
        <text x={cathode - 3} y={186} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          cathode
        </text>
        <rect x={anode} y={60} width={10} height={110} fill={PALETTE.slate} />
        <text x={anode + 5} y={186} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          anode
        </text>
        {Array.from({ length: 5 }).map((_, i) => (
          <Arrow
            key={i}
            x1={14}
            y1={66 + i * 24}
            x2={cathode - 12}
            y2={76 + i * 24}
            color={lambdaNm < 450 ? "#7c3aed" : lambdaNm < 580 ? "#16a34a" : "#dc2626"}
            width={2}
          />
        ))}
        {electrons.map((e, i) => (
          <g key={i}>
            <circle cx={e.x} cy={e.y} r={5} fill={PALETTE.blue} />
            <text x={e.x} y={e.y + 3} textAnchor="middle" fontSize={8} fill="#ffffff">
              −
            </text>
          </g>
        ))}
        {!sort ? (
          <text
            x={W / 2}
            y={115}
            textAnchor="middle"
            fontSize={13}
            fontWeight={700}
            fill={PALETTE.red}
          >
            aucun électron arraché
          </text>
        ) : null}
      </Board>

      <Choice
        label="Métal de la cathode"
        value={metal}
        options={METAUX.map((o) => ({ value: o.value as string, label: o.label }))}
        onChange={setMetal}
      />

      <Panel>
        <Ctrl
          label="Longueur d'onde"
          value={lambdaNm}
          min={180}
          max={800}
          step={10}
          onChange={setLambdaNm}
          display={`${fmt(lambdaNm, 0)} nm`}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Intensité du faisceau"
          value={intensite}
          min={1}
          max={10}
          step={1}
          onChange={setIntensite}
          display={fmt(intensite, 0)}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Énergie du photon" value={`${fmt(E, 2)} eV`} color={PALETTE.purple} />
        <Stat label="Travail d'extraction" value={`${fmt(W0, 2)} eV`} />
        <Stat
          label="Longueur d'onde seuil"
          value={`${fmt(lambda0, 0)} nm`}
          color={PALETTE.orange}
        />
        <Stat label="Tension d'arrêt" value={sort ? `${fmt(U0, 2)} V` : "—"} color={PALETTE.blue} />
      </div>

      <Verdict tone={sort ? "ok" : "bad"}>
        {sort
          ? `L'effet se produit car λ = ${fmt(lambdaNm, 0)} nm est inférieure au seuil ${fmt(lambda0, 0)} nm. Augmente l'intensité : il sort plus d'électrons, mais leur énergie ne change pas.`
          : `Rien ne sort : λ = ${fmt(lambdaNm, 0)} nm dépasse le seuil ${fmt(lambda0, 0)} nm, donc chaque photon est trop peu énergétique. Augmenter l'intensité n'y changera rien.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 21 — Diffusion Compton                                     */
/* ------------------------------------------------------------------ */

export function DiffusionCompton() {
  const [lambdaPm, setLambdaPm] = useState(50);
  const [theta, setTheta] = useState(60);

  const lambdaC = 2.43;
  const rad = (theta * Math.PI) / 180;
  const decalage = lambdaC * (1 - Math.cos(rad));
  const lambdaPrime = lambdaPm + decalage;
  const relatif = (decalage / lambdaPm) * 100;

  const hc = 1.986e-25;
  const E = hc / (lambdaPm * 1e-12);
  const Eprime = hc / (lambdaPrime * 1e-12);
  const cede = (E - Eprime) / 1.6e-19;

  const W = 420;
  const H = 240;
  const cx = 180;
  const cy = 130;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={cx}
          y1={cy}
          x2={W - 16}
          y2={cy}
          stroke={PALETTE.grid}
          strokeWidth={1}
          strokeDasharray="5 4"
        />
        <Arrow x1={26} y1={cy} x2={cx - 16} y2={cy} color={PALETTE.purple} width={3} />
        <text x={32} y={cy - 12} fontSize={11} fontWeight={700} fill={PALETTE.purple}>
          photon λ
        </text>
        <circle cx={cx} cy={cy} r={9} fill={PALETTE.slate} />
        <text x={cx} y={cy + 4} textAnchor="middle" fontSize={9} fill="#ffffff">
          e⁻
        </text>
        <Arrow
          x1={cx + 14}
          y1={cy}
          x2={cx + 14 + 120 * Math.cos(rad)}
          y2={cy - 120 * Math.sin(rad)}
          color={PALETTE.blue}
          width={3}
        />
        <text
          x={cx + 20 + 120 * Math.cos(rad)}
          y={cy - 120 * Math.sin(rad) - 6}
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.blue}
        >
          λ&apos;
        </text>
        <Arrow
          x1={cx + 14}
          y1={cy}
          x2={cx + 14 + 72 * Math.cos(-rad / 2.2)}
          y2={cy - 72 * Math.sin(-rad / 2.2)}
          color={PALETTE.red}
          width={2.4}
        />
        <text
          x={cx + 20 + 72 * Math.cos(-rad / 2.2)}
          y={cy - 72 * Math.sin(-rad / 2.2) + 16}
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.red}
        >
          électron
        </text>
        <path
          d={`M${cx + 54},${cy} A 40 40 0 0 ${rad > Math.PI ? 1 : 0} ${cx + 14 + 40 * Math.cos(rad)},${cy - 40 * Math.sin(rad)}`}
          fill="none"
          stroke={PALETTE.slate}
          strokeWidth={1.2}
        />
        <text x={cx + 62} y={cy - 16} fontSize={11} fontWeight={700} fill={PALETTE.slate}>
          {fmt(theta, 0)}°
        </text>
      </Board>

      <Panel>
        <Ctrl
          label="Longueur d'onde incidente"
          value={lambdaPm}
          min={5}
          max={600}
          step={5}
          onChange={setLambdaPm}
          display={`${fmt(lambdaPm, 0)} pm`}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Angle de diffusion"
          value={theta}
          min={0}
          max={180}
          step={5}
          onChange={setTheta}
          display={`${fmt(theta, 0)}°`}
          color={PALETTE.blue}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Décalage Δλ" value={`${fmt(decalage, 3)} pm`} color={PALETTE.red} />
        <Stat label="Décalage relatif" value={`${fmt(relatif, 2)} %`} color={PALETTE.orange} />
        <Stat
          label="Longueur d'onde diffusée"
          value={`${fmt(lambdaPrime, 2)} pm`}
          color={PALETTE.blue}
        />
        <Stat label="Énergie cédée à l'électron" value={`${fmt(cede, 0)} eV`} />
      </div>

      <Verdict tone={relatif > 1 ? "ok" : "warn"}>
        {relatif > 1
          ? `Le décalage représente ${fmt(relatif, 2)} % de la longueur d'onde : il est mesurable. C'est pourquoi Compton a travaillé avec des rayons X.`
          : `Le décalage ne pèse que ${fmt(relatif, 3)} % : indétectable. Δλ vaut toujours quelques picomètres, donc il disparaît dès que λ devient grande.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 22 — Décroissance radioactive                              */
/* ------------------------------------------------------------------ */

const NUCLEIDES = [
  { value: "c14", label: "Carbone 14", T: 5730, unite: "ans" },
  { value: "i131", label: "Iode 131", T: 8.02, unite: "jours" },
  { value: "co60", label: "Cobalt 60", T: 5.27, unite: "ans" },
  { value: "ra226", label: "Radium 226", T: 1600, unite: "ans" },
] as const;

export function DecroissanceRadioactive() {
  const [choix, setChoix] = useState<string>("c14");
  const [temps, setTemps] = useState(0);

  const nuc = NUCLEIDES.find((n) => n.value === choix) ?? NUCLEIDES[0];
  const T = nuc.T;
  const lambda = Math.LN2 / T;
  const tMax = 5 * T;
  const t = clamp(temps, 0, tMax);
  const reste = Math.exp(-lambda * t);
  const demiVies = t / T;

  const W = 440;
  const H = 240;
  const s = makeScales(W, H, 0, tMax, 0, 1.1, 32);
  const f = (x: number) => Math.exp(-lambda * x);

  const grille = Array.from({ length: 100 }, (_, i) => i);
  const vivants = Math.round(reste * 100);

  return (
    <div className="space-y-3">
      <Choice
        label="Choisis un noyau radioactif"
        value={choix}
        options={NUCLEIDES.map((n) => ({ value: n.value as string, label: n.label }))}
        onChange={(v) => {
          setChoix(v);
          setTemps(0);
        }}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(tMax)}
          y2={s.sy(0)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        <line
          x1={s.sx(0)}
          y1={s.sy(0)}
          x2={s.sx(0)}
          y2={s.sy(1.1)}
          stroke={PALETTE.axis}
          strokeWidth={1.4}
        />
        {[1, 2, 3, 4].map((k) => (
          <g key={k}>
            <line
              x1={s.sx(k * T)}
              y1={s.sy(0)}
              x2={s.sx(k * T)}
              y2={s.sy(Math.pow(0.5, k))}
              stroke={PALETTE.grid}
              strokeWidth={1}
              strokeDasharray="4 4"
            />
            <line
              x1={s.sx(0)}
              y1={s.sy(Math.pow(0.5, k))}
              x2={s.sx(k * T)}
              y2={s.sy(Math.pow(0.5, k))}
              stroke={PALETTE.grid}
              strokeWidth={1}
              strokeDasharray="4 4"
            />
            <text
              x={s.sx(k * T)}
              y={s.sy(0) + 17}
              textAnchor="middle"
              fontSize={10}
              fill={PALETTE.slate}
            >
              {k}T
            </text>
          </g>
        ))}
        <path d={curvePath(f, s, 320)} fill="none" stroke={PALETTE.blue} strokeWidth={2.8} />
        <line
          x1={s.sx(t)}
          y1={s.sy(0)}
          x2={s.sx(t)}
          y2={s.sy(reste)}
          stroke={PALETTE.red}
          strokeWidth={1.8}
        />
        <circle cx={s.sx(t)} cy={s.sy(reste)} r={6} fill={PALETTE.red} />
        <text
          x={s.sx(t) + 10}
          y={s.sy(reste) - 9}
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.red}
        >
          {fmt(reste * 100, 1)} %
        </text>
      </Board>

      <Board width={W} height={142}>
        <rect width={W} height={142} fill="#ffffff" />
        {grille.map((i) => {
          const col = i % 20;
          const row = Math.floor(i / 20);
          return (
            <circle
              key={i}
              cx={34 + col * 19}
              cy={26 + row * 19}
              r={6}
              fill={i < vivants ? PALETTE.green : PALETTE.grid}
            />
          );
        })}
        <text x={W / 2} y={134} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {vivants} noyaux sur 100 ne se sont pas encore désintégrés
        </text>
      </Board>

      <Ctrl
        label={`Temps écoulé (${nuc.unite})`}
        value={t}
        min={0}
        max={tMax}
        step={tMax / 200}
        onChange={setTemps}
        display={`${fmt(t, T < 100 ? 2 : 0)} ${nuc.unite}`}
        color={PALETTE.red}
      />

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Demi-vie" value={`${fmt(T, 2)} ${nuc.unite}`} color={PALETTE.blue} />
        <Stat label="Demi-vies écoulées" value={fmt(demiVies, 2)} color={PALETTE.purple} />
        <Stat label="Constante λ" value={`${fmt(lambda, 5)} /${nuc.unite}`} />
      </div>

      <Verdict tone="ok">
        Après une demi-vie il reste 50 %, après deux 25 %, après trois 12,5 %. La durée pour passer
        de 100 % à 50 % est la même que pour passer de 50 % à 25 % : c&apos;est ce qui caractérise
        une décroissance exponentielle.
      </Verdict>
    </div>
  );
}
