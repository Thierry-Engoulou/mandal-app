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

/** Simulations du programme de Physique 1ère C et D (APC, 4 modules). */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* Module 1 — Incertitude sur une mesure                               */
/* ------------------------------------------------------------------ */

export function IncertitudeMesure() {
  const [mesure, setMesure] = useState(12.4);
  const [incert, setIncert] = useState(0.3);

  const rel = (incert / mesure) * 100;
  const bas = mesure - incert;
  const haut = mesure + incert;

  const W = 460;
  const H = 180;
  const pad = 40;
  const vmin = 10;
  const vmax = 15;
  const sx = (v: number) => pad + ((v - vmin) / (vmax - vmin)) * (W - 2 * pad);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line x1={pad} y1={100} x2={W - pad} y2={100} stroke={PALETTE.axis} strokeWidth={1.6} />
        {Array.from({ length: 11 }).map((_, i) => {
          const v = vmin + (i * (vmax - vmin)) / 10;
          return (
            <g key={i}>
              <line x1={sx(v)} y1={95} x2={sx(v)} y2={105} stroke={PALETTE.slate} strokeWidth={1} />
              <text x={sx(v)} y={120} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
                {fmt(v, 1)}
              </text>
            </g>
          );
        })}
        <rect
          x={sx(bas)}
          y={84}
          width={Math.max(2, sx(haut) - sx(bas))}
          height={32}
          fill={PALETTE.blue}
          opacity={0.25}
        />
        <line x1={sx(bas)} y1={78} x2={sx(bas)} y2={122} stroke={PALETTE.blue} strokeWidth={2.5} />
        <line
          x1={sx(haut)}
          y1={78}
          x2={sx(haut)}
          y2={122}
          stroke={PALETTE.blue}
          strokeWidth={2.5}
        />
        <line
          x1={sx(mesure)}
          y1={62}
          x2={sx(mesure)}
          y2={128}
          stroke={PALETTE.red}
          strokeWidth={3}
        />
        <text
          x={sx(mesure)}
          y={54}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={PALETTE.red}
        >
          {fmt(mesure, 2)}
        </text>
        <text x={sx(bas)} y={140} textAnchor="middle" fontSize={11} fill={PALETTE.blue}>
          {fmt(bas, 2)}
        </text>
        <text x={sx(haut)} y={140} textAnchor="middle" fontSize={11} fill={PALETTE.blue}>
          {fmt(haut, 2)}
        </text>
        <text x={W / 2} y={166} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          la valeur vraie se trouve quelque part dans la bande bleue
        </text>
      </Board>
      <div className="grid gap-3 sm:grid-cols-2">
        <Ctrl
          label="Valeur mesurée (cm)"
          value={mesure}
          min={10.5}
          max={14.5}
          step={0.05}
          onChange={setMesure}
          color={PALETTE.red}
        />
        <Ctrl
          label="Incertitude absolue Δm (cm)"
          value={incert}
          min={0.01}
          max={1}
          step={0.01}
          onChange={setIncert}
        />
      </div>
      <Panel>
        <Stat
          label="Résultat à écrire"
          value={`${fmt(mesure, 2)} ± ${fmt(incert, 2)} cm`}
          color={PALETTE.red}
        />
        <Stat label="Encadrement" value={`${fmt(bas, 2)} ; ${fmt(haut, 2)}`} color={PALETTE.blue} />
        <Stat label="Incertitude relative" value={`${fmt(rel, 2)} %`} color={PALETTE.purple} />
        <Stat label="Largeur de l'intervalle" value={`${fmt(2 * incert, 2)} cm`} />
      </Panel>
      <Verdict tone={rel < 1 ? "ok" : rel < 5 ? "warn" : "bad"}>
        {rel < 1
          ? "Moins de 1 % : la mesure est précise, on peut garder plusieurs chiffres significatifs."
          : rel < 5
            ? "Entre 1 et 5 % : précision correcte pour un travail pratique au lycée."
            : "Plus de 5 % : la mesure est trop imprécise. Annoncer beaucoup de chiffres après la virgule n'aurait aucun sens."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Module 1 — Loi de Hooke et limite élastique                         */
/* ------------------------------------------------------------------ */

export function LoiHooke() {
  const [k, setK] = useState(20);
  const [F, setF] = useState(3);
  const limite = 0.25; // allongement maximal du domaine elastique, en metres

  const x = F / k;
  const elastique = x <= limite;
  const xAffiche = elastique ? x : limite + (x - limite) * 0.4;

  const W = 460;
  const H = 300;
  const ox = 90;
  const oy = 40;
  const echelle = 420;

  const s = makeScales(200, 230, 0, 0.45, 0, 10, 26);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <rect x={ox - 40} y={oy - 14} width={80} height={10} fill={PALETTE.slate} />
        {Array.from({ length: 12 }).map((_, i) => {
          const y0 = oy + (i * xAffiche * echelle) / 12 + i * 7;
          return (
            <path
              key={i}
              d={`M${ox - 14},${y0} Q${ox + 14},${y0 + 4} ${ox - 14},${y0 + 8}`}
              fill="none"
              stroke={elastique ? PALETTE.blue : PALETTE.red}
              strokeWidth={2.4}
            />
          );
        })}
        <line
          x1={ox}
          y1={oy + xAffiche * echelle + 84}
          x2={ox}
          y2={oy + xAffiche * echelle + 110}
          stroke={PALETTE.ink}
          strokeWidth={2}
        />
        <rect
          x={ox - 24}
          y={oy + xAffiche * echelle + 110}
          width={48}
          height={26}
          fill={PALETTE.slate}
          rx={3}
        />
        <Arrow
          x1={ox}
          y1={oy + xAffiche * echelle + 140}
          x2={ox}
          y2={oy + xAffiche * echelle + 140 + Math.min(70, F * 9)}
          color={PALETTE.red}
          width={3}
        />
        <text
          x={ox + 10}
          y={oy + xAffiche * echelle + 165}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.red}
        >
          F = {fmt(F, 1)} N
        </text>
        <text x={ox - 60} y={oy + 60} fontSize={12} fontWeight={700} fill={PALETTE.blue}>
          Δx
        </text>
        <g transform="translate(240, 40)">
          <rect width={200} height={230} fill="#ffffff" />
          <Grid s={s} step={2} />
          <path
            d={`M${s.sx(0)},${s.sy(0)} L${s.sx(limite)},${s.sy(limite * k)}`}
            stroke={PALETTE.blue}
            strokeWidth={3}
            fill="none"
          />
          <path
            d={`M${s.sx(limite)},${s.sy(limite * k)} Q${s.sx(0.34)},${s.sy(limite * k + 1.4)} ${s.sx(0.43)},${s.sy(limite * k + 1.7)}`}
            stroke={PALETTE.red}
            strokeWidth={3}
            fill="none"
          />
          <line
            x1={s.sx(limite)}
            y1={s.sy(0)}
            x2={s.sx(limite)}
            y2={s.sy(10)}
            stroke={PALETTE.red}
            strokeWidth={1.2}
            strokeDasharray="4 4"
          />
          <circle
            cx={s.sx(Math.min(x, 0.43))}
            cy={s.sy(Math.min(F, 9.8))}
            r={5}
            fill={PALETTE.orange}
          />
          <text x={s.sx(0.02)} y={s.sy(9.4)} fontSize={11} fill={PALETTE.slate}>
            F (N)
          </text>
          <text x={s.sx(0.33)} y={s.sy(0) + 16} fontSize={11} fill={PALETTE.slate}>
            Δx (m)
          </text>
          <text x={s.sx(limite) + 4} y={s.sy(9.4)} fontSize={10} fill={PALETTE.red}>
            limite
          </text>
        </g>
      </Board>
      <div className="grid gap-3 sm:grid-cols-2">
        <Ctrl
          label="Raideur du ressort k (N/m)"
          value={k}
          min={8}
          max={40}
          step={1}
          onChange={(v) => setK(Math.round(v))}
        />
        <Ctrl
          label="Force appliquée F (N)"
          value={F}
          min={0.2}
          max={9.5}
          step={0.1}
          onChange={setF}
          color={PALETTE.red}
        />
      </div>
      <Panel>
        <Stat label="Allongement Δx = F / k" value={`${fmt(x, 3)} m`} color={PALETTE.blue} />
        <Stat label="Soit en centimètres" value={`${fmt(x * 100, 1)} cm`} />
        <Stat
          label="Énergie emmagasinée ½kΔx²"
          value={`${fmt(0.5 * k * x * x, 3)} J`}
          color={PALETTE.purple}
        />
        <Stat
          label="Domaine"
          value={elastique ? "élastique" : "dépassé"}
          color={elastique ? PALETTE.green : PALETTE.red}
        />
      </Panel>
      <Verdict tone={elastique ? "ok" : "bad"}>
        {elastique
          ? "Tant qu'on reste dans le domaine élastique, l'allongement est proportionnel à la force : le graphe est une droite, et le ressort reprend sa forme quand on lâche."
          : "La limite élastique est dépassée. Le graphe n'est plus une droite, la loi de Hooke ne s'applique plus, et le ressort restera déformé. C'est ce qu'on appelle la contrainte du modèle."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Module 2 — Travail d'une force                                      */
/* ------------------------------------------------------------------ */

export function TravailForce() {
  const [F, setF] = useState(50);
  const [deg, setDeg] = useState(30);
  const [d, setD] = useState(8);

  const a = (deg * Math.PI) / 180;
  const W_ = F * d * Math.cos(a);

  const LW = 460;
  const LH = 230;
  const sol = 165;
  const x0 = 70;
  const x1 = x0 + d * 32;

  return (
    <div className="space-y-3">
      <Board width={LW} height={LH}>
        <rect width={LW} height={LH} fill="#ffffff" />
        <line x1={30} y1={sol} x2={LW - 20} y2={sol} stroke={PALETTE.slate} strokeWidth={3} />
        <rect
          x={x0 - 22}
          y={sol - 34}
          width={44}
          height={34}
          fill={PALETTE.slate}
          opacity={0.3}
          stroke={PALETTE.ink}
          strokeWidth={1.5}
        />
        <rect
          x={x1 - 22}
          y={sol - 34}
          width={44}
          height={34}
          fill={PALETTE.blue}
          opacity={0.25}
          stroke={PALETTE.blue}
          strokeWidth={2}
        />
        <Arrow
          x1={x0}
          y1={sol - 17}
          x2={x0 + Math.cos(a) * F * 1.5}
          y2={sol - 17 - Math.sin(a) * F * 1.5}
          color={PALETTE.red}
          width={3}
        />
        <path
          d={`M${x0 + 34},${sol - 17} A34,34 0 0,0 ${x0 + 34 * Math.cos(a)},${sol - 17 - 34 * Math.sin(a)}`}
          fill="none"
          stroke={PALETTE.orange}
          strokeWidth={2}
        />
        <text x={x0 + 42} y={sol - 24} fontSize={12} fontWeight={700} fill={PALETTE.orange}>
          {deg}°
        </text>
        <line x1={x0} y1={sol + 16} x2={x1} y2={sol + 16} stroke={PALETTE.green} strokeWidth={2} />
        <text
          x={(x0 + x1) / 2}
          y={sol + 34}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.green}
        >
          d = {fmt(d, 1)} m
        </text>
        <text
          x={x0 + Math.cos(a) * F * 1.5 + 8}
          y={sol - 17 - Math.sin(a) * F * 1.5}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.red}
        >
          F = {F} N
        </text>
        <text x={LW / 2} y={24} textAnchor="middle" fontSize={13} fontWeight={700}>
          Une caisse tirée sur {fmt(d, 1)} m
        </text>
      </Board>
      <div className="grid gap-3 sm:grid-cols-3">
        <Ctrl
          label="Intensité F (N)"
          value={F}
          min={10}
          max={90}
          step={5}
          onChange={(v) => setF(Math.round(v))}
          color={PALETTE.red}
        />
        <Ctrl
          label="Angle avec le sol"
          value={deg}
          min={0}
          max={180}
          step={5}
          onChange={(v) => setDeg(Math.round(v))}
          display={`${deg}°`}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Déplacement d (m)"
          value={d}
          min={2}
          max={10}
          step={0.5}
          onChange={setD}
          color={PALETTE.green}
        />
      </div>
      <Panel>
        <Stat
          label="Travail W = F·d·cos α"
          value={`${fmt(W_, 1)} J`}
          color={W_ > 0 ? PALETTE.green : W_ < 0 ? PALETTE.red : PALETTE.slate}
        />
        <Stat label="cos α" value={fmt(Math.cos(a), 3)} color={PALETTE.orange} />
      </Panel>
      <Verdict tone={Math.abs(W_) < 0.01 ? "warn" : W_ > 0 ? "ok" : "bad"}>
        {Math.abs(W_) < 0.01
          ? "À 90°, la force est perpendiculaire au déplacement : son travail est nul. C'est le cas du poids quand on marche à plat."
          : W_ > 0
            ? "Le travail est positif : la force aide le mouvement, on dit qu'elle est motrice."
            : "Le travail est négatif : la force s'oppose au mouvement, on dit qu'elle est résistante. C'est le cas des frottements."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Module 2 — Énergie mécanique sur une piste                          */
/* ------------------------------------------------------------------ */

export function EnergieMecanique() {
  const [pos, setPos] = useState(0.1);
  const [frottement, setFrottement] = useState(false);
  const m = 2;
  const g = 10;
  const hMax = 5;

  // piste : h(t) = hMax * (1 - t)^2 pour une descente, puis remontee
  const hauteur = (t: number) => hMax * Math.pow(Math.cos(Math.PI * t), 2) * (1 - 0.35 * t);
  const h = hauteur(pos);
  const emInitiale = m * g * hauteur(0);
  const em = frottement ? emInitiale * (1 - 0.45 * pos) : emInitiale;
  const epp = m * g * h;
  const ec = Math.max(0, em - epp);
  const v = Math.sqrt((2 * ec) / m);

  const W = 460;
  const H = 300;
  const px = (t: number) => 34 + t * (W - 150);
  const py = (hh: number) => 230 - (hh / hMax) * 170;

  let piste = "";
  for (let i = 0; i <= 100; i++) {
    const t = i / 100;
    piste += `${i ? "L" : "M"}${px(t).toFixed(1)},${py(hauteur(t)).toFixed(1)} `;
  }

  const barres = [
    { nom: "Ec", val: ec, col: PALETTE.red },
    { nom: "Epp", val: epp, col: PALETTE.blue },
    { nom: "Em", val: em, col: PALETTE.purple },
  ];
  const maxE = Math.max(emInitiale, 1);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <rect
          x={W - 92}
          y={py(0) - 168}
          width={88}
          height={186}
          fill={PALETTE.grid}
          opacity={0.5}
          rx={6}
        />
        <line
          x1={26}
          y1={py(0)}
          x2={W - 100}
          y2={py(0)}
          stroke={PALETTE.slate}
          strokeWidth={1.2}
          strokeDasharray="5 4"
        />
        <path d={piste} fill="none" stroke={PALETTE.ink} strokeWidth={3} />
        <circle
          cx={px(pos)}
          cy={py(h) - 9}
          r={9}
          fill={PALETTE.orange}
          stroke="#ffffff"
          strokeWidth={2}
        />
        <line
          x1={px(pos)}
          y1={py(h)}
          x2={px(pos)}
          y2={py(0)}
          stroke={PALETTE.blue}
          strokeWidth={1.4}
          strokeDasharray="4 3"
        />
        <text x={px(pos) + 12} y={py(h) - 14} fontSize={12} fontWeight={700} fill={PALETTE.orange}>
          {fmt(v, 1)} m/s
        </text>
        <text
          x={px(pos) - 8}
          y={(py(h) + py(0)) / 2}
          textAnchor="end"
          fontSize={11}
          fill={PALETTE.blue}
        >
          h = {fmt(h, 2)} m
        </text>
        {barres.map((b, i) => (
          <g key={i}>
            <rect
              x={W - 80 + i * 26}
              y={py(0) - (b.val / maxE) * 150}
              width={19}
              height={Math.max(1, (b.val / maxE) * 150)}
              fill={b.col}
              opacity={0.85}
            />
            <text
              x={W - 70 + i * 26}
              y={py(0) + 14}
              textAnchor="middle"
              fontSize={9}
              fill={b.col}
              fontWeight={700}
            >
              {b.nom}
            </text>
          </g>
        ))}
      </Board>
      <Ctrl
        label="Position de la bille sur la piste"
        value={pos}
        min={0}
        max={1}
        step={0.01}
        onChange={setPos}
        color={PALETTE.orange}
      />
      <Choice
        value={frottement ? "oui" : "non"}
        onChange={(v) => setFrottement(v === "oui")}
        options={[
          { value: "non", label: "Sans frottement" },
          { value: "oui", label: "Avec frottement" },
        ]}
      />
      <Panel>
        <Stat label="Énergie cinétique Ec = ½mv²" value={`${fmt(ec, 2)} J`} color={PALETTE.red} />
        <Stat
          label="Énergie potentielle Epp = mgh"
          value={`${fmt(epp, 2)} J`}
          color={PALETTE.blue}
        />
        <Stat label="Énergie mécanique Em" value={`${fmt(em, 2)} J`} color={PALETTE.purple} />
        <Stat label="Vitesse v" value={`${fmt(v, 2)} m/s`} color={PALETTE.orange} />
      </Panel>
      <Verdict tone={frottement ? "warn" : "ok"}>
        {frottement
          ? "Avec frottement, la barre violette diminue au fil de la descente : une partie de l'énergie mécanique part en chaleur. Le système n'est plus conservatif."
          : "Sans frottement, la barre violette ne bouge jamais. L'énergie passe de potentielle à cinétique et inversement, mais leur somme reste constante."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Module 2 — Quantité de chaleur et changements d'état                */
/* ------------------------------------------------------------------ */

export function QuantiteChaleur() {
  const [masse, setMasse] = useState(0.5);
  const [energie, setEnergie] = useState(300);

  const c = 4180; // J/(kg.K) pour l'eau liquide
  const cGlace = 2100;
  const Lf = 334000;
  const Lv = 2260000;

  // on part de la glace a -20 degres
  const q1 = masse * cGlace * 20;
  const q2 = masse * Lf;
  const q3 = masse * c * 100;
  const q4 = masse * Lv;
  const Q = energie * 1000;

  let temp: number;
  let etat: string;
  if (Q < q1) {
    temp = -20 + Q / (masse * cGlace);
    etat = "glace";
  } else if (Q < q1 + q2) {
    temp = 0;
    etat = "fusion";
  } else if (Q < q1 + q2 + q3) {
    temp = (Q - q1 - q2) / (masse * c);
    etat = "eau liquide";
  } else if (Q < q1 + q2 + q3 + q4) {
    temp = 100;
    etat = "vaporisation";
  } else {
    temp = 100;
    etat = "vapeur";
  }

  const W = 460;
  const H = 280;
  const total = q1 + q2 + q3 + q4;
  const s = makeScales(W, H, 0, total / 1000, -30, 120, 34);

  const pts: Array<[number, number]> = [
    [0, -20],
    [q1 / 1000, 0],
    [(q1 + q2) / 1000, 0],
    [(q1 + q2 + q3) / 1000, 100],
    [(q1 + q2 + q3 + q4) / 1000, 100],
  ];
  const d = pts
    .map((p, i) => `${i ? "L" : "M"}${s.sx(p[0]).toFixed(1)},${s.sy(p[1]).toFixed(1)}`)
    .join(" ");

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <Grid s={s} step={25} />
        <path d={d} fill="none" stroke={PALETTE.red} strokeWidth={3} />
        <circle
          cx={s.sx(Math.min(energie, total / 1000))}
          cy={s.sy(temp)}
          r={6}
          fill={PALETTE.orange}
        />
        <text x={s.sx(s.xMin) + 8} y={s.sy(110)} fontSize={11} fill={PALETTE.slate}>
          température (°C)
        </text>
        <text
          x={s.sx(s.xMax) - 8}
          y={s.sy(-26)}
          fontSize={11}
          fill={PALETTE.slate}
          textAnchor="end"
        >
          énergie reçue (kJ)
        </text>
      </Board>
      <div className="grid gap-3 sm:grid-cols-2">
        <Ctrl
          label="Masse d'eau (kg)"
          value={masse}
          min={0.1}
          max={1}
          step={0.05}
          onChange={setMasse}
        />
        <Ctrl
          label="Énergie apportée (kJ)"
          value={energie}
          min={0}
          max={Math.round(total / 1000)}
          step={5}
          onChange={(v) => setEnergie(Math.round(v))}
          color={PALETTE.orange}
        />
      </div>
      <Panel>
        <Stat label="Température atteinte" value={`${fmt(temp, 1)} °C`} color={PALETTE.red} />
        <Stat label="État de l'eau" value={etat} color={PALETTE.blue} />
        <Stat label="Chauffer la glace (×2100)" value={`${fmt(q1 / 1000, 1)} kJ`} />
        <Stat
          label="Faire fondre (L = 334 kJ/kg)"
          value={`${fmt(q2 / 1000, 1)} kJ`}
          color={PALETTE.purple}
        />
        <Stat label="Chauffer l'eau (×4180)" value={`${fmt(q3 / 1000, 1)} kJ`} />
        <Stat
          label="Vaporiser (L = 2260 kJ/kg)"
          value={`${fmt(q4 / 1000, 1)} kJ`}
          color={PALETTE.purple}
        />
      </Panel>
      <Verdict tone={etat === "fusion" || etat === "vaporisation" ? "warn" : "ok"}>
        {etat === "fusion" || etat === "vaporisation"
          ? "La courbe est horizontale : tu continues à chauffer, mais la température ne monte plus. Toute l'énergie sert au changement d'état. C'est la chaleur latente."
          : "La courbe monte : l'énergie sert à élever la température, selon Q = m·c·ΔT. Compare la pente de la glace et celle de l'eau liquide."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Module 3 — Lentille mince                                           */
/* ------------------------------------------------------------------ */

export function LentilleMince() {
  const [f, setF] = useState(3);
  const [objet, setObjet] = useState(-7);
  const [hauteur, setHauteur] = useState(1.5);

  const convergente = f > 0;
  // relation de conjugaison : 1/x' - 1/x = 1/f'
  const denom = objet + f;
  const image = Math.abs(denom) < 1e-6 ? Number.POSITIVE_INFINITY : (f * objet) / denom;
  const gamma = Number.isFinite(image) ? image / objet : Number.NaN;
  const hImage = Number.isFinite(gamma) ? gamma * hauteur : Number.NaN;

  const s = makeScales(460, 300, -12, 12, -4, 4, 24);
  const O = { x: s.sx(0), y: s.sy(0) };

  const rayons: string[] = [];
  if (Number.isFinite(image)) {
    // rayon parallele a l'axe puis passant par F'
    rayons.push(
      `M${s.sx(objet)},${s.sy(hauteur)} L${s.sx(0)},${s.sy(hauteur)} L${s.sx(image)},${s.sy(hImage)}`,
    );
    // rayon passant par le centre optique
    rayons.push(`M${s.sx(objet)},${s.sy(hauteur)} L${s.sx(image)},${s.sy(hImage)}`);
  }

  return (
    <div className="space-y-3">
      <Board width={s.width} height={s.height}>
        <rect width={s.width} height={s.height} fill="#ffffff" />
        <Grid s={s} step={2} />
        <line
          x1={s.sx(0)}
          y1={s.sy(3.4)}
          x2={s.sx(0)}
          y2={s.sy(-3.4)}
          stroke={PALETTE.blue}
          strokeWidth={3}
          opacity={0.6}
        />
        {convergente ? (
          <g stroke={PALETTE.blue} strokeWidth={2.5} fill="none">
            <path
              d={`M${s.sx(0) - 7},${s.sy(3.0)} L${s.sx(0)},${s.sy(3.4)} L${s.sx(0) + 7},${s.sy(3.0)}`}
            />
            <path
              d={`M${s.sx(0) - 7},${s.sy(-3.0)} L${s.sx(0)},${s.sy(-3.4)} L${s.sx(0) + 7},${s.sy(-3.0)}`}
            />
          </g>
        ) : (
          <g stroke={PALETTE.blue} strokeWidth={2.5} fill="none">
            <path
              d={`M${s.sx(0) - 7},${s.sy(3.4)} L${s.sx(0)},${s.sy(3.0)} L${s.sx(0) + 7},${s.sy(3.4)}`}
            />
            <path
              d={`M${s.sx(0) - 7},${s.sy(-3.4)} L${s.sx(0)},${s.sy(-3.0)} L${s.sx(0) + 7},${s.sy(-3.4)}`}
            />
          </g>
        )}
        {[-Math.abs(f), Math.abs(f)].map((v, i) => (
          <g key={i}>
            <circle cx={s.sx(v)} cy={O.y} r={3.5} fill={PALETTE.green} />
            <text
              x={s.sx(v)}
              y={O.y + 18}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill={PALETTE.green}
            >
              {i === 0 ? "F" : "F'"}
            </text>
          </g>
        ))}
        <Arrow
          x1={s.sx(objet)}
          y1={O.y}
          x2={s.sx(objet)}
          y2={s.sy(hauteur)}
          color={PALETTE.red}
          width={3}
        />
        <text
          x={s.sx(objet) - 16}
          y={s.sy(hauteur) - 6}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.red}
        >
          AB
        </text>
        {Number.isFinite(image) && Math.abs(image) <= 12 ? (
          <g>
            <Arrow
              x1={s.sx(image)}
              y1={O.y}
              x2={s.sx(image)}
              y2={s.sy(hImage)}
              color={PALETTE.purple}
              width={3}
            />
            <text
              x={s.sx(image) + 8}
              y={s.sy(hImage) + (hImage > 0 ? -6 : 14)}
              fontSize={12}
              fontWeight={700}
              fill={PALETTE.purple}
            >
              A'B'
            </text>
          </g>
        ) : null}
        {rayons.map((d, i) => (
          <path key={i} d={d} stroke={PALETTE.orange} strokeWidth={1.6} fill="none" opacity={0.9} />
        ))}
        <text x={O.x + 6} y={O.y + 16} fontSize={12} fontWeight={700}>
          O
        </text>
      </Board>
      <Choice
        value={convergente ? "conv" : "div"}
        onChange={(v) => setF(v === "conv" ? Math.abs(f) : -Math.abs(f))}
        options={[
          { value: "conv", label: "Lentille convergente" },
          { value: "div", label: "Lentille divergente" },
        ]}
      />
      <div className="grid gap-3 sm:grid-cols-3">
        <Ctrl
          label="Distance focale |f'| (cm)"
          value={Math.abs(f)}
          min={1}
          max={6}
          step={0.5}
          onChange={(v) => setF(convergente ? v : -v)}
          color={PALETTE.green}
        />
        <Ctrl
          label="Position de l'objet (cm)"
          value={objet}
          min={-11}
          max={-1}
          step={0.5}
          onChange={setObjet}
          color={PALETTE.red}
        />
        <Ctrl
          label="Hauteur de l'objet (cm)"
          value={hauteur}
          min={0.5}
          max={3}
          step={0.1}
          onChange={setHauteur}
        />
      </div>
      <Panel>
        <Stat
          label="Position de l'image"
          value={Number.isFinite(image) ? `${fmt(image, 2)} cm` : "à l'infini"}
          color={PALETTE.purple}
        />
        <Stat
          label="Grandissement γ"
          value={Number.isFinite(gamma) ? fmt(gamma, 2) : "—"}
          color={PALETTE.orange}
        />
        <Stat
          label="Taille de l'image"
          value={Number.isFinite(hImage) ? `${fmt(Math.abs(hImage), 2)} cm` : "—"}
        />
        <Stat
          label="Nature"
          value={
            !Number.isFinite(image)
              ? "pas d'image"
              : `${image > 0 ? "réelle" : "virtuelle"}, ${gamma < 0 ? "renversée" : "droite"}`
          }
          color={PALETTE.blue}
        />
      </Panel>
      <Verdict tone={!Number.isFinite(image) ? "warn" : image > 0 ? "ok" : "warn"}>
        {!Number.isFinite(image)
          ? "L'objet est exactement au foyer F : les rayons sortent parallèles, l'image se forme à l'infini. C'est le réglage d'un projecteur."
          : image > 0
            ? "L'image est réelle : elle se forme de l'autre côté de la lentille et on peut la recevoir sur un écran. Elle est renversée."
            : "L'image est virtuelle : les rayons ne se croisent pas vraiment, on ne peut pas la projeter sur un écran. C'est ce que fait une loupe."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Module 3 — L'œil réduit et l'accommodation                          */
/* ------------------------------------------------------------------ */

export function OeilReduit() {
  const [distance, setDistance] = useState(50);
  const [defaut, setDefaut] = useState<"normal" | "myope" | "hypermetrope">("normal");

  const retine = 1.7; // cm derriere le cristallin
  // distance focale necessaire pour que l'image tombe sur la retine
  const d = distance; // en cm, devant l'oeil
  const fNecessaire = (d * retine) / (d + retine);
  const fMin = defaut === "myope" ? 1.45 : defaut === "hypermetrope" ? 1.62 : 1.5;
  const fMax = defaut === "myope" ? 1.62 : defaut === "hypermetrope" ? 1.78 : 1.7;
  const possible = fNecessaire >= fMin && fNecessaire <= fMax;
  const fReel = clamp(fNecessaire, fMin, fMax);
  // position de l'image : 1/x' = 1/f - 1/d  (distances algebriques simplifiees)
  const imagePos = 1 / (1 / fReel - 1 / d);

  const W = 460;
  const H = 260;
  const cx = 300;
  const cy = 130;
  const k = 42;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <ellipse
          cx={cx + 36}
          cy={cy}
          rx={52}
          ry={48}
          fill="#dbeafe"
          stroke={PALETTE.ink}
          strokeWidth={2}
        />
        <line
          x1={cx}
          y1={cy - 34}
          x2={cx}
          y2={cy + 34}
          stroke={PALETTE.blue}
          strokeWidth={4}
          opacity={0.75}
        />
        <text x={cx - 46} y={cy - 40} fontSize={11} fontWeight={700} fill={PALETTE.blue}>
          cristallin
        </text>
        <path
          d={`M${cx + 86},${cy - 40} A48,48 0 0,1 ${cx + 86},${cy + 40}`}
          stroke={PALETTE.red}
          strokeWidth={4}
          fill="none"
        />
        <text x={cx + 92} y={cy - 44} fontSize={11} fontWeight={700} fill={PALETTE.red}>
          rétine
        </text>
        <line
          x1={20}
          y1={cy}
          x2={W - 20}
          y2={cy}
          stroke={PALETTE.slate}
          strokeWidth={1}
          strokeDasharray="4 4"
        />
        <Arrow
          x1={cx - Math.min(d, 6) * k}
          y1={cy}
          x2={cx - Math.min(d, 6) * k}
          y2={cy - 36}
          color={PALETTE.green}
          width={3}
        />
        <text
          x={cx - Math.min(d, 6) * k - 8}
          y={cy - 42}
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.green}
        >
          objet
        </text>
        <line
          x1={cx - Math.min(d, 6) * k}
          y1={cy - 36}
          x2={cx}
          y2={cy - 36}
          stroke={PALETTE.orange}
          strokeWidth={1.4}
        />
        <line
          x1={cx}
          y1={cy - 36}
          x2={cx + imagePos * 50}
          y2={cy + 16}
          stroke={PALETTE.orange}
          strokeWidth={1.4}
        />
        <line
          x1={cx - Math.min(d, 6) * k}
          y1={cy - 36}
          x2={cx + imagePos * 50}
          y2={cy + 16}
          stroke={PALETTE.orange}
          strokeWidth={1.4}
        />
        <circle
          cx={cx + imagePos * 50}
          cy={cy + 16}
          r={5}
          fill={possible ? PALETTE.green : PALETTE.red}
        />
        <text
          x={cx + imagePos * 50 + 8}
          y={cy + 32}
          fontSize={11}
          fontWeight={700}
          fill={possible ? PALETTE.green : PALETTE.red}
        >
          image
        </text>
      </Board>
      <Choice
        label="Type d'œil"
        value={defaut}
        onChange={setDefaut}
        options={[
          { value: "normal", label: "Œil normal" },
          { value: "myope", label: "Œil myope" },
          { value: "hypermetrope", label: "Œil hypermétrope" },
        ]}
      />
      <Ctrl
        label="Distance de l'objet (cm)"
        value={distance}
        min={8}
        max={200}
        step={1}
        onChange={(v) => setDistance(Math.round(v))}
        color={PALETTE.green}
      />
      <Panel>
        <Stat
          label="Distance focale nécessaire"
          value={`${fmt(fNecessaire, 3)} cm`}
          color={PALETTE.blue}
        />
        <Stat label="Distance focale possible" value={`${fmt(fMin, 2)} à ${fmt(fMax, 2)} cm`} />
        <Stat
          label="Image nette ?"
          value={possible ? "oui" : "non"}
          color={possible ? PALETTE.green : PALETTE.red}
        />
        <Stat label="Vergence 1/f" value={`${fmt(100 / fReel, 1)} δ`} color={PALETTE.purple} />
      </Panel>
      <Verdict tone={possible ? "ok" : "bad"}>
        {possible
          ? "Le cristallin se déforme et place l'image exactement sur la rétine : c'est l'accommodation, et l'élève voit net."
          : defaut === "myope"
            ? "L'œil myope ne peut pas assez aplatir son cristallin : l'image des objets lointains se forme avant la rétine. On corrige avec une lentille divergente."
            : defaut === "hypermetrope"
              ? "L'œil hypermétrope ne bombe pas assez son cristallin : l'image des objets proches se formerait derrière la rétine. On corrige avec une lentille convergente."
              : "L'objet est trop proche : il est en deçà du punctum proximum, situé vers 25 cm pour un œil normal. Recule l'objet."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Module 4 — Générateur, récepteur et point de fonctionnement         */
/* ------------------------------------------------------------------ */

export function PointFonctionnement() {
  const [E, setE] = useState(12);
  const [r, setR] = useState(1.5);
  const [Ep, setEp] = useState(4);
  const [rp, setRp] = useState(2);

  const I = (E - Ep) / (r + rp);
  const U = E - r * I;
  const pFournie = E * I;
  const pUtile = Ep * I;
  const pertes = (r + rp) * I * I;
  const rendement = pFournie > 0 ? (pUtile / pFournie) * 100 : 0;

  const s = makeScales(460, 300, 0, 5, 0, 16, 30);

  return (
    <div className="space-y-3">
      <Board width={s.width} height={s.height}>
        <rect width={s.width} height={s.height} fill="#ffffff" />
        <Grid s={s} step={2} />
        <path
          d={`M${s.sx(0)},${s.sy(E)} L${s.sx(5)},${s.sy(E - 5 * r)}`}
          stroke={PALETTE.blue}
          strokeWidth={3}
          fill="none"
        />
        <path
          d={`M${s.sx(0)},${s.sy(Ep)} L${s.sx(5)},${s.sy(Ep + 5 * rp)}`}
          stroke={PALETTE.red}
          strokeWidth={3}
          fill="none"
        />
        {I >= 0 && I <= 5 ? (
          <g>
            <circle cx={s.sx(I)} cy={s.sy(U)} r={9} fill={PALETTE.green} opacity={0.3} />
            <circle cx={s.sx(I)} cy={s.sy(U)} r={5.5} fill={PALETTE.green} />
            <line
              x1={s.sx(I)}
              y1={s.sy(U)}
              x2={s.sx(I)}
              y2={s.sy(0)}
              stroke={PALETTE.green}
              strokeWidth={1.4}
              strokeDasharray="4 3"
            />
            <line
              x1={s.sx(I)}
              y1={s.sy(U)}
              x2={s.sx(0)}
              y2={s.sy(U)}
              stroke={PALETTE.green}
              strokeWidth={1.4}
              strokeDasharray="4 3"
            />
            <text
              x={s.sx(I) + 10}
              y={s.sy(U) - 10}
              fontSize={12}
              fontWeight={700}
              fill={PALETTE.green}
            >
              ({fmt(I, 2)} A ; {fmt(U, 2)} V)
            </text>
          </g>
        ) : null}
        <text x={s.sx(0.15)} y={s.sy(E) - 8} fontSize={11} fontWeight={700} fill={PALETTE.blue}>
          générateur U = E − r·I
        </text>
        <text
          x={s.sx(3.3)}
          y={s.sy(Ep + 3.3 * rp) + 22}
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.red}
        >
          récepteur U = E' + r'·I
        </text>
        <text x={s.sx(4.6)} y={s.sy(0) + 16} fontSize={11} fill={PALETTE.slate}>
          I (A)
        </text>
        <text x={s.sx(0) + 6} y={s.sy(15.2)} fontSize={11} fill={PALETTE.slate}>
          U (V)
        </text>
      </Board>
      <div className="grid gap-3 sm:grid-cols-2">
        <Ctrl
          label="Force électromotrice E (V)"
          value={E}
          min={6}
          max={15}
          step={0.5}
          onChange={setE}
        />
        <Ctrl
          label="Résistance interne r (Ω)"
          value={r}
          min={0.2}
          max={4}
          step={0.1}
          onChange={setR}
        />
        <Ctrl
          label="Force contre-électromotrice E' (V)"
          value={Ep}
          min={0}
          max={10}
          step={0.5}
          onChange={setEp}
          color={PALETTE.red}
        />
        <Ctrl
          label="Résistance interne r' (Ω)"
          value={rp}
          min={0.2}
          max={4}
          step={0.1}
          onChange={setRp}
          color={PALETTE.red}
        />
      </div>
      <Panel>
        <Stat
          label="Intensité I = (E − E') / (r + r')"
          value={`${fmt(I, 3)} A`}
          color={PALETTE.green}
        />
        <Stat label="Tension U aux bornes" value={`${fmt(U, 2)} V`} color={PALETTE.green} />
        <Stat label="Puissance fournie E·I" value={`${fmt(pFournie, 2)} W`} color={PALETTE.blue} />
        <Stat label="Puissance utile E'·I" value={`${fmt(pUtile, 2)} W`} color={PALETTE.purple} />
        <Stat label="Pertes par effet Joule" value={`${fmt(pertes, 2)} W`} color={PALETTE.red} />
        <Stat label="Rendement" value={`${fmt(rendement, 1)} %`} />
      </Panel>
      <Verdict tone={I > 0 ? "ok" : "bad"}>
        {I > 0
          ? "Le point vert est le point de fonctionnement : c'est le seul couple (I ; U) qui convient aux deux dipôles en même temps. Augmente r et regarde la tension chuter."
          : "La force contre-électromotrice du récepteur dépasse celle du générateur : aucun courant ne circule dans ce sens."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Module 4 — Énergie consommée et facture                             */
/* ------------------------------------------------------------------ */

const APPAREILS = [
  { nom: "Ampoule à filament", p: 100 },
  { nom: "Ampoule LED", p: 9 },
  { nom: "Ventilateur", p: 60 },
  { nom: "Téléviseur", p: 120 },
  { nom: "Réfrigérateur", p: 200 },
  { nom: "Fer à repasser", p: 1000 },
];

export function EnergieElectrique() {
  const [idx, setIdx] = useState(0);
  const [heures, setHeures] = useState(5);
  const [prix, setPrix] = useState(79);

  const app = APPAREILS[idx] ?? { nom: "Ampoule", p: 100 };
  const P = app.p;
  const energieJ = P * heures * 3600;
  const kwh = (P * heures) / 1000;
  const coutJour = kwh * prix;
  const coutMois = coutJour * 30;

  const W = 460;
  const H = 230;
  const pad = 40;
  const maxCout = ((30 * (1000 * 12)) / 1000) * 100;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={W / 2} y={28} textAnchor="middle" fontSize={14} fontWeight={700}>
          {app.nom} — {P} W pendant {heures} h par jour
        </text>
        {APPAREILS.map((a, i) => {
          const c = ((a.p * heures) / 1000) * prix * 30;
          const bw = (W - 2 * pad) / APPAREILS.length;
          const h = Math.min(120, (c / maxCout) * 1200);
          return (
            <g key={i}>
              <rect
                x={pad + i * bw + bw * 0.18}
                y={180 - h}
                width={bw * 0.64}
                height={Math.max(2, h)}
                fill={i === idx ? PALETTE.orange : PALETTE.blue}
                opacity={i === idx ? 0.9 : 0.35}
                rx={3}
              />
              <text
                x={pad + i * bw + bw / 2}
                y={180 - h - 6}
                textAnchor="middle"
                fontSize={9}
                fill={i === idx ? PALETTE.orange : PALETTE.slate}
                fontWeight={700}
              >
                {Math.round(c)}
              </text>
              <text
                x={pad + i * bw + bw / 2}
                y={196}
                textAnchor="middle"
                fontSize={8}
                fill={PALETTE.slate}
              >
                {a.p} W
              </text>
            </g>
          );
        })}
        <line
          x1={pad - 8}
          y1={180}
          x2={W - pad + 8}
          y2={180}
          stroke={PALETTE.axis}
          strokeWidth={1.5}
        />
        <text x={W / 2} y={216} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          coût mensuel en FCFA, pour la même durée d'utilisation
        </text>
      </Board>
      <Choice
        label="Appareil"
        value={String(idx)}
        onChange={(v) => setIdx(Number(v))}
        options={APPAREILS.map((a, i) => ({ value: String(i), label: a.nom }))}
      />
      <div className="grid gap-3 sm:grid-cols-2">
        <Ctrl
          label="Durée par jour (h)"
          value={heures}
          min={0.5}
          max={24}
          step={0.5}
          onChange={setHeures}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Prix du kWh (FCFA)"
          value={prix}
          min={50}
          max={120}
          step={1}
          onChange={(v) => setPrix(Math.round(v))}
        />
      </div>
      <Panel>
        <Stat label="Énergie en joules (E = P·t)" value={`${fmt(energieJ / 1000, 0)} kJ`} />
        <Stat label="Énergie en kilowattheures" value={`${fmt(kwh, 3)} kWh`} color={PALETTE.blue} />
        <Stat label="Coût par jour" value={`${fmt(coutJour, 0)} FCFA`} color={PALETTE.orange} />
        <Stat label="Coût par mois" value={`${fmt(coutMois, 0)} FCFA`} color={PALETTE.red} />
      </Panel>
      <Verdict tone="ok">
        Compare l'ampoule à filament et l'ampoule LED à durée égale : même lumière, onze fois moins
        de puissance. Le fer à repasser, lui, consomme en une heure ce que la LED consomme en
        plusieurs jours.
      </Verdict>
    </div>
  );
}
