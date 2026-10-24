import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict, fmt } from "./controls";

/** Chimie 1ère C, D et E — chapitres 3, 4 et 5 : les alcanes et les cyclanes. */

const NOMS = [
  "méthane",
  "éthane",
  "propane",
  "butane",
  "pentane",
  "hexane",
  "heptane",
  "octane",
  "nonane",
  "décane",
];

const EBULLITION = [-162, -89, -42, -0.5, 36, 69, 98, 126, 151, 174];
const ISOMERES = [1, 1, 1, 2, 3, 5, 9, 18, 35, 75];

function nomAlcane(n: number): string {
  return NOMS[n - 1] ?? `alcane en C${n}`;
}

function indiceSub(n: number): string {
  const c = "₀₁₂₃₄₅₆₇₈₉";
  return String(n)
    .split("")
    .map((d) => c[Number(d)] ?? d)
    .join("");
}

function brute(n: number): string {
  return `C${n > 1 ? indiceSub(n) : ""}H${indiceSub(2 * n + 2)}`;
}

function semiDev(n: number): string {
  if (n === 1) return "CH₄";
  const milieu = Array.from({ length: n - 2 }, () => "CH₂").join(" — ");
  return n === 2 ? "CH₃ — CH₃" : `CH₃ — ${milieu} — CH₃`;
}

/* ------------------------------------------------------------------ */
/* Chapitre 3 — Les trois écritures d'une molécule                     */
/* ------------------------------------------------------------------ */

type Ecriture = "brute" | "semi" | "dev";

export function FamilleAlcanes() {
  const [n, setN] = useState(4);
  const [ecr, setEcr] = useState<Ecriture>("semi");

  const M = 14 * n + 2;
  const etat = n <= 4 ? "gaz" : n <= 16 ? "liquide" : "solide";

  const W = 440;
  const H = 200;
  const pas = Math.min(58, (W - 80) / Math.max(1, n));
  const x0 = W / 2 - ((n - 1) * pas) / 2;

  return (
    <div className="space-y-3">
      <Ctrl
        label="Nombre d'atomes de carbone"
        value={n}
        min={1}
        max={10}
        step={1}
        onChange={setN}
        display={`n = ${n}`}
      />
      <Choice
        label="Écriture affichée"
        value={ecr}
        options={[
          { value: "brute" as Ecriture, label: "Brute" },
          { value: "semi" as Ecriture, label: "Semi-développée" },
          { value: "dev" as Ecriture, label: "Développée" },
        ]}
        onChange={setEcr}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text
          x={W / 2}
          y={26}
          textAnchor="middle"
          fontSize={15}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {nomAlcane(n)}
        </text>

        {ecr === "brute" ? (
          <text
            x={W / 2}
            y={110}
            textAnchor="middle"
            fontSize={34}
            fontWeight={700}
            fill={PALETTE.blue}
          >
            {brute(n)}
          </text>
        ) : ecr === "semi" ? (
          <text x={W / 2} y={110} textAnchor="middle" fontSize={16} fill={PALETTE.ink}>
            {semiDev(n)}
          </text>
        ) : (
          <g>
            {Array.from({ length: n }).map((_, i) => {
              const x = x0 + i * pas;
              const y = 108;
              const hGauche = i === 0;
              const hDroite = i === n - 1;
              return (
                <g key={i}>
                  {i < n - 1 ? (
                    <line
                      x1={x + 11}
                      y1={y}
                      x2={x + pas - 11}
                      y2={y}
                      stroke={PALETTE.ink}
                      strokeWidth={1.8}
                    />
                  ) : null}
                  <text
                    x={x}
                    y={y + 5}
                    textAnchor="middle"
                    fontSize={14}
                    fontWeight={700}
                    fill={PALETTE.ink}
                  >
                    C
                  </text>
                  <g>
                    <g>
                      <line
                        x1={x}
                        y1={y - 10}
                        x2={x}
                        y2={y - 26}
                        stroke={PALETTE.slate}
                        strokeWidth={1.4}
                      />
                      <text x={x} y={y - 30} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
                        H
                      </text>
                    </g>
                  </g>
                  <g>
                    <line
                      x1={x}
                      y1={y + 8}
                      x2={x}
                      y2={y + 24}
                      stroke={PALETTE.slate}
                      strokeWidth={1.4}
                    />
                    <text x={x} y={y + 38} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
                      H
                    </text>
                  </g>
                  {hGauche ? (
                    <g>
                      <line
                        x1={x - 11}
                        y1={y}
                        x2={x - 26}
                        y2={y}
                        stroke={PALETTE.slate}
                        strokeWidth={1.4}
                      />
                      <text
                        x={x - 34}
                        y={y + 4}
                        textAnchor="middle"
                        fontSize={11}
                        fill={PALETTE.slate}
                      >
                        H
                      </text>
                    </g>
                  ) : null}
                  {hDroite ? (
                    <g>
                      <line
                        x1={x + 11}
                        y1={y}
                        x2={x + 26}
                        y2={y}
                        stroke={PALETTE.slate}
                        strokeWidth={1.4}
                      />
                      <text
                        x={x + 34}
                        y={y + 4}
                        textAnchor="middle"
                        fontSize={11}
                        fill={PALETTE.slate}
                      >
                        H
                      </text>
                    </g>
                  ) : null}
                </g>
              );
            })}
          </g>
        )}

        <text x={W / 2} y={H - 12} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {ecr === "brute"
            ? "elle compte les atomes, mais ne dit rien de leur arrangement"
            : ecr === "semi"
              ? "elle montre le squelette carboné : c'est celle qu'on utilise presque toujours"
              : "elle montre toutes les liaisons, y compris avec l'hydrogène"}
        </text>
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Formule brute" value={brute(n)} color={PALETTE.blue} />
        <Stat label="Masse molaire" value={`${M} g/mol`} color={PALETTE.purple} />
        <Stat label="État à 25 °C" value={etat} color={PALETTE.slate} />
      </div>

      <Verdict tone="ok">
        M = 14n + 2 = {14 * n} + 2 = {M} g/mol. Cette formule est le chemin le plus court pour
        retrouver n à partir de la masse molaire : n = (M − 2) / 14.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 3 — Construire et nommer un alcane                         */
/* ------------------------------------------------------------------ */

export function NomenclatureAlcane() {
  const [n, setN] = useState(6);
  const [pos, setPos] = useState(3);
  const [groupe, setGroupe] = useState<"methyle" | "ethyle">("methyle");

  const p = Math.min(Math.max(2, pos), Math.max(2, n - 1));
  // la numérotation part du bout qui donne le plus petit indice
  const indiceGauche = p;
  const indiceDroite = n + 1 - p;
  const indice = Math.min(indiceGauche, indiceDroite);
  const parLaGauche = indiceGauche <= indiceDroite;
  const nom = `${indice}-${groupe === "methyle" ? "méthyl" : "éthyl"}${nomAlcane(n)}`;

  const W = 440;
  const H = 200;
  const pas = Math.min(54, (W - 90) / Math.max(1, n - 1));
  const x0 = W / 2 - ((n - 1) * pas) / 2;
  const y0 = 110;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Longueur de la chaîne principale"
          value={n}
          min={3}
          max={8}
          step={1}
          onChange={(v) => {
            setN(v);
            setPos(Math.min(pos, v - 1));
          }}
          display={`${n} carbones`}
        />
        <Ctrl
          label="Position de la ramification"
          value={p}
          min={2}
          max={Math.max(2, n - 1)}
          step={1}
          onChange={setPos}
          display={`carbone n° ${p}`}
          color={PALETTE.orange}
        />
      </Panel>
      <Choice
        label="Groupe greffé"
        value={groupe}
        options={[
          { value: "methyle" as const, label: "Méthyle —CH₃" },
          { value: "ethyle" as const, label: "Éthyle —C₂H₅" },
        ]}
        onChange={setGroupe}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        {Array.from({ length: n }).map((_, i) => {
          const x = x0 + i * pas;
          const numero = parLaGauche ? i + 1 : n - i;
          const porteur = i + 1 === p;
          return (
            <g key={i}>
              {i < n - 1 ? (
                <line x1={x} y1={y0} x2={x + pas} y2={y0} stroke={PALETTE.ink} strokeWidth={2.2} />
              ) : null}
              <circle cx={x} cy={y0} r={14} fill={porteur ? PALETTE.orange : "#334155"} />
              <text
                x={x}
                y={y0 + 5}
                textAnchor="middle"
                fontSize={12}
                fontWeight={700}
                fill="#ffffff"
              >
                C
              </text>
              <text
                x={x}
                y={y0 + 34}
                textAnchor="middle"
                fontSize={12}
                fontWeight={700}
                fill={numero === indice ? PALETTE.orange : PALETTE.slate}
              >
                {numero}
              </text>
            </g>
          );
        })}

        {(() => {
          const x = x0 + (p - 1) * pas;
          return (
            <g>
              <line
                x1={x}
                y1={y0 - 14}
                x2={x}
                y2={y0 - 48}
                stroke={PALETTE.orange}
                strokeWidth={2.2}
              />
              <rect x={x - 28} y={y0 - 74} width={56} height={26} rx={6} fill={PALETTE.orange} />
              <text
                x={x}
                y={y0 - 56}
                textAnchor="middle"
                fontSize={11}
                fontWeight={700}
                fill="#ffffff"
              >
                {groupe === "methyle" ? "CH₃" : "C₂H₅"}
              </text>
            </g>
          );
        })()}

        <text x={W / 2} y={24} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          numérotation {parLaGauche ? "de la gauche vers la droite" : "de la droite vers la gauche"}{" "}
          — c&apos;est le sens qui donne le plus petit indice
        </text>

        <text
          x={W / 2}
          y={H - 14}
          textAnchor="middle"
          fontSize={18}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {nom}
        </text>
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat
          label="Si on compte à gauche"
          value={`indice ${indiceGauche}`}
          color={PALETTE.slate}
        />
        <Stat
          label="Si on compte à droite"
          value={`indice ${indiceDroite}`}
          color={PALETTE.slate}
        />
        <Stat label="On garde" value={`${indice}`} color={PALETTE.orange} />
      </div>

      <Verdict tone="ok">
        {indiceGauche === indiceDroite
          ? "Les deux sens donnent le même indice : la molécule est symétrique, on peut compter d'un côté ou de l'autre."
          : `La règle du plus petit indice tranche : on garde ${indice}, pas ${Math.max(indiceGauche, indiceDroite)}. Déplace la ramification d'un cran et regarde la numérotation basculer d'un bout à l'autre.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 3 — Compter les isomères                                   */
/* ------------------------------------------------------------------ */

const STRUCTURES: Record<number, ReadonlyArray<{ nom: string; formule: string }>> = {
  4: [
    { nom: "n-butane", formule: "CH₃ — CH₂ — CH₂ — CH₃" },
    { nom: "2-méthylpropane", formule: "CH₃ — CH(CH₃) — CH₃" },
  ],
  5: [
    { nom: "n-pentane", formule: "CH₃ — CH₂ — CH₂ — CH₂ — CH₃" },
    { nom: "2-méthylbutane", formule: "CH₃ — CH(CH₃) — CH₂ — CH₃" },
    { nom: "2,2-diméthylpropane", formule: "C(CH₃)₄" },
  ],
  6: [
    { nom: "n-hexane", formule: "CH₃ — (CH₂)₄ — CH₃" },
    { nom: "2-méthylpentane", formule: "CH₃ — CH(CH₃) — CH₂ — CH₂ — CH₃" },
    { nom: "3-méthylpentane", formule: "CH₃ — CH₂ — CH(CH₃) — CH₂ — CH₃" },
    { nom: "2,2-diméthylbutane", formule: "CH₃ — C(CH₃)₂ — CH₂ — CH₃" },
    { nom: "2,3-diméthylbutane", formule: "CH₃ — CH(CH₃) — CH(CH₃) — CH₃" },
  ],
};

export function IsomeresAlcane() {
  const [n, setN] = useState(5);
  const liste = STRUCTURES[n] ?? [];
  const total = ISOMERES[n - 1] ?? 0;

  const W = 440;
  const H = 40 + Math.max(1, liste.length) * 34;

  return (
    <div className="space-y-3">
      <Ctrl
        label="Nombre d'atomes de carbone"
        value={n}
        min={3}
        max={10}
        step={1}
        onChange={setN}
        display={`${brute(n)} — ${nomAlcane(n)}`}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {liste.length > 0 ? (
          liste.map((s, i) => (
            <g key={s.nom}>
              <rect
                x={14}
                y={18 + i * 34}
                width={W - 28}
                height={28}
                rx={6}
                fill={i % 2 === 0 ? "#f8fafc" : "#f1f5f9"}
              />
              <text x={26} y={37 + i * 34} fontSize={12} fill={PALETTE.ink}>
                {s.formule}
              </text>
              <text
                x={W - 26}
                y={37 + i * 34}
                textAnchor="end"
                fontSize={11}
                fontWeight={700}
                fill={PALETTE.blue}
              >
                {s.nom}
              </text>
            </g>
          ))
        ) : (
          <text x={W / 2} y={H / 2} textAnchor="middle" fontSize={13} fill={PALETTE.slate}>
            {n < 4
              ? "Pas d'isomérie : avec moins de 4 carbones, une seule structure est possible."
              : `Trop nombreux pour être listés ici : ${total} isomères.`}
          </text>
        )}
      </Board>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Formule brute" value={brute(n)} color={PALETTE.blue} />
        <Stat label="Nombre d'isomères" value={String(total)} color={PALETTE.orange} />
      </div>

      <Verdict tone={n >= 7 ? "warn" : "ok"}>
        {n >= 7
          ? `Le nombre d'isomères explose : ${total} pour ${brute(n)}. On ne te demandera jamais de tous les écrire — seulement de savoir qu'ils existent et de trouver les premiers.`
          : "Même formule brute, mêmes atomes, et pourtant des corps différents : températures d'ébullition différentes, indices d'octane différents. C'est l'isomérie de chaîne."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 4 — Les cyclanes et leur stabilité                         */
/* ------------------------------------------------------------------ */

type Cyclane = {
  n: number;
  nom: string;
  angle: number;
  tension: "très forte" | "forte" | "faible" | "nulle";
  note: string;
};

const CYC_DEFAUT: Cyclane = {
  n: 3,
  nom: "cyclopropane",
  angle: 60,
  tension: "très forte",
  note: "60° au lieu de 109,5° : les liaisons sont tordues, la molécule est très réactive et le cycle s'ouvre facilement.",
};

const CYCLANES: ReadonlyArray<Cyclane> = [
  CYC_DEFAUT,
  {
    n: 4,
    nom: "cyclobutane",
    angle: 90,
    tension: "forte",
    note: "90° : encore loin de 109,5°, le cycle reste fragile.",
  },
  {
    n: 5,
    nom: "cyclopentane",
    angle: 108,
    tension: "faible",
    note: "108° : presque la valeur idéale. Le cyclopentane est déjà stable.",
  },
  {
    n: 6,
    nom: "cyclohexane",
    angle: 120,
    tension: "nulle",
    note: "120° sur le papier, mais la molécule n'est pas plane : elle se plisse en « chaise » et retrouve exactement 109,5°. C'est le cyclane le plus stable, et c'est pour cela qu'on le trouve partout dans le pétrole.",
  },
];

export function Cyclanes() {
  const [n, setN] = useState(3);
  const c = CYCLANES.find((x) => x.n === n) ?? CYC_DEFAUT;
  const ecart = Math.abs(c.angle - 109.5);

  const W = 440;
  const H = 210;
  const cx = 150;
  const cy = 108;
  const r = 56;
  const pts = Array.from({ length: c.n }, (_, i) => {
    const a = -Math.PI / 2 + (2 * Math.PI * i) / c.n;
    return { x: cx + r * Math.cos(a), y: cy + r * Math.sin(a) };
  });

  const couleur =
    c.tension === "nulle"
      ? PALETTE.green
      : c.tension === "faible"
        ? "#65a30d"
        : c.tension === "forte"
          ? PALETTE.orange
          : PALETTE.red;

  return (
    <div className="space-y-3">
      <Ctrl
        label="Nombre de carbones dans le cycle"
        value={n}
        min={3}
        max={6}
        step={1}
        onChange={setN}
        display={c.nom}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <polygon
          points={pts.map((p) => `${p.x.toFixed(1)},${p.y.toFixed(1)}`).join(" ")}
          fill="none"
          stroke={couleur}
          strokeWidth={3}
        />
        {pts.map((p, i) => (
          <g key={i}>
            <circle cx={p.x} cy={p.y} r={13} fill="#334155" />
            <text
              x={p.x}
              y={p.y + 4}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill="#ffffff"
            >
              C
            </text>
          </g>
        ))}
        <text x={cx} y={cy + 4} textAnchor="middle" fontSize={13} fontWeight={700} fill={couleur}>
          {c.angle}°
        </text>

        <text x={272} y={44} fontSize={12} fontWeight={700} fill={PALETTE.ink}>
          {c.nom}
        </text>
        <text x={272} y={66} fontSize={11} fill={PALETTE.slate}>
          formule : C{indiceSub(c.n)}H{indiceSub(2 * c.n)}
        </text>
        <text x={272} y={88} fontSize={11} fill={PALETTE.slate}>
          angle du polygone : {c.angle}°
        </text>
        <text x={272} y={110} fontSize={11} fill={PALETTE.slate}>
          angle idéal : 109,5°
        </text>
        <text x={272} y={134} fontSize={12} fontWeight={700} fill={couleur}>
          écart : {fmt(ecart, 1)}°
        </text>

        <rect x={272} y={148} width={150} height={12} rx={6} fill="#e2e8f0" />
        <rect
          x={272}
          y={148}
          width={Math.min(150, (ecart / 50) * 150)}
          height={12}
          rx={6}
          fill={couleur}
        />
        <text x={272} y={176} fontSize={11} fontWeight={700} fill={couleur}>
          tension : {c.tension}
        </text>
      </Board>

      <Verdict tone={c.tension === "nulle" || c.tension === "faible" ? "ok" : "bad"}>
        {c.note}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 4 — Les conformations de l'éthane                          */
/* ------------------------------------------------------------------ */

export function ConformationsEthane() {
  const [theta, setTheta] = useState(60);

  const rad = (theta * Math.PI) / 180;
  const energie = 6 * (1 + Math.cos(3 * rad));
  const decalee = Math.abs((((theta % 120) + 120) % 120) - 60) < 12;
  const eclipsee = Math.min(((theta % 120) + 120) % 120, 120 - (((theta % 120) + 120) % 120)) < 12;

  const W = 440;
  const H = 314;
  const cx = 118;
  const cy = 110;
  const R = 62;

  const avant = [90, 210, 330];
  const arriere = avant.map((a) => a + theta);

  const gx = (t: number) => 236 + (t / 360) * 184;
  const gy = (e: number) => 290 - (e / 12) * 72;
  const courbe = Array.from({ length: 121 }, (_, i) => {
    const t = i * 3;
    return `${i === 0 ? "M" : "L"}${gx(t).toFixed(1)},${gy(6 * (1 + Math.cos((3 * t * Math.PI) / 180))).toFixed(1)}`;
  }).join(" ");

  return (
    <div className="space-y-3">
      <Ctrl
        label="Angle de rotation autour de la liaison C—C"
        value={theta}
        min={0}
        max={360}
        step={5}
        onChange={setTheta}
        display={`${theta}°`}
        color={PALETTE.purple}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={cx} y={26} textAnchor="middle" fontSize={12} fontWeight={700} fill={PALETTE.ink}>
          projection de Newman
        </text>

        <circle cx={cx} cy={cy} r={R} fill="#ffffff" stroke={PALETTE.slate} strokeWidth={2} />
        {arriere.map((a, i) => {
          const r = (a * Math.PI) / 180;
          const x = cx + R * Math.cos(r);
          const y = cy - R * Math.sin(r);
          const x2 = cx + (R + 20) * Math.cos(r);
          const y2 = cy - (R + 20) * Math.sin(r);
          return (
            <g key={`b${i}`}>
              <line x1={x} y1={y} x2={x2} y2={y2} stroke={PALETTE.red} strokeWidth={3} />
              <text
                x={cx + (R + 32) * Math.cos(r)}
                y={cy - (R + 32) * Math.sin(r) + 4}
                textAnchor="middle"
                fontSize={10}
                fill={PALETTE.red}
              >
                H
              </text>
            </g>
          );
        })}
        {avant.map((a, i) => {
          const r = (a * Math.PI) / 180;
          const x = cx + R * Math.cos(r);
          const y = cy - R * Math.sin(r);
          return (
            <g key={`f${i}`}>
              <line x1={cx} y1={cy} x2={x} y2={y} stroke={PALETTE.blue} strokeWidth={3.4} />
              <text
                x={cx + (R + 14) * Math.cos(r)}
                y={cy - (R + 14) * Math.sin(r) + 4}
                textAnchor="middle"
                fontSize={10}
                fill={PALETTE.blue}
              >
                H
              </text>
            </g>
          );
        })}
        <circle cx={cx} cy={cy} r={7} fill="#334155" />

        <text x={cx} y={234} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          bleu : carbone avant — rouge : carbone arrière
        </text>
        <text
          x={cx}
          y={258}
          textAnchor="middle"
          fontSize={14}
          fontWeight={700}
          fill={decalee ? PALETTE.green : eclipsee ? PALETTE.red : PALETTE.slate}
        >
          {decalee ? "DÉCALÉE" : eclipsee ? "ÉCLIPSÉE" : "intermédiaire"}
        </text>

        <text x={328} y={26} textAnchor="middle" fontSize={12} fontWeight={700} fill={PALETTE.ink}>
          énergie (kJ/mol)
        </text>
        <line x1={236} y1={290} x2={426} y2={290} stroke={PALETTE.axis} strokeWidth={1.4} />
        <line x1={236} y1={290} x2={236} y2={208} stroke={PALETTE.axis} strokeWidth={1.4} />
        <path d={courbe} fill="none" stroke={PALETTE.purple} strokeWidth={2.4} />
        <circle cx={gx(theta)} cy={gy(energie)} r={6} fill={PALETTE.purple} />
        <text x={230} y={216} textAnchor="end" fontSize={9} fill={PALETTE.slate}>
          12
        </text>
        <text x={230} y={294} textAnchor="end" fontSize={9} fill={PALETTE.slate}>
          0
        </text>
        <text x={236} y={306} fontSize={9} fill={PALETTE.slate}>
          0°
        </text>
        <text x={420} y={306} textAnchor="end" fontSize={9} fill={PALETTE.slate}>
          360°
        </text>
        <text
          x={328}
          y={198}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.purple}
        >
          {fmt(energie, 1)} kJ/mol
        </text>
      </Board>

      <Verdict tone={decalee ? "ok" : eclipsee ? "bad" : "warn"}>
        {decalee
          ? "Conformation DÉCALÉE : les hydrogènes sont au maximum d'éloignement, leur répulsion est minimale, l'énergie est au plus bas. C'est dans cette position que la molécule passe le plus clair de son temps."
          : eclipsee
            ? "Conformation ÉCLIPSÉE : les hydrogènes de l'avant et de l'arrière se font face, ils se repoussent, l'énergie est au sommet. La molécule ne s'y attarde jamais."
            : "Entre les deux : la molécule tourne librement autour de la liaison simple C—C. Continue de tourner pour atteindre un creux ou un sommet de la courbe."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 4 — Température d'ébullition et ramification               */
/* ------------------------------------------------------------------ */

export function ProprietesAlcanes() {
  const [n, setN] = useState(5);
  const [ram, setRam] = useState(0);

  const base = EBULLITION[n - 1] ?? 0;
  const teb = base - ram * 11;
  const etat = teb < 25 ? "gaz" : teb < 300 ? "liquide" : "solide";

  const W = 440;
  const H = 220;
  const gx = (i: number) => 44 + ((i - 1) / 9) * 356;
  const gy = (t: number) => 190 - ((t + 180) / 380) * 150;

  const courbe = EBULLITION.map((t, i) => `${i === 0 ? "M" : "L"}${gx(i + 1)},${gy(t)}`).join(" ");

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Nombre de carbones"
          value={n}
          min={1}
          max={10}
          step={1}
          onChange={(v) => {
            setN(v);
            setRam(Math.min(ram, Math.max(0, v - 3)));
          }}
          display={nomAlcane(n)}
        />
        <Ctrl
          label="Nombre de ramifications"
          value={ram}
          min={0}
          max={Math.max(0, Math.min(3, n - 3))}
          step={1}
          onChange={setRam}
          display={ram === 0 ? "chaîne droite" : `${ram} ramification(s)`}
          color={PALETTE.orange}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={20} y={22} fontSize={12} fontWeight={700} fill={PALETTE.ink}>
          température d&apos;ébullition des alcanes à chaîne droite
        </text>

        <line x1={44} y1={190} x2={410} y2={190} stroke={PALETTE.axis} strokeWidth={1.4} />
        <line x1={44} y1={190} x2={44} y2={34} stroke={PALETTE.axis} strokeWidth={1.4} />
        <line
          x1={44}
          y1={gy(25)}
          x2={410}
          y2={gy(25)}
          stroke={PALETTE.gridStrong}
          strokeWidth={1}
          strokeDasharray="4 4"
        />
        <text x={414} y={gy(25) + 4} fontSize={9} fill={PALETTE.slate}>
          25 °C
        </text>

        <path d={courbe} fill="none" stroke={PALETTE.blue} strokeWidth={2.4} />
        {EBULLITION.map((t, i) => (
          <circle key={i} cx={gx(i + 1)} cy={gy(t)} r={3} fill={PALETTE.blue} />
        ))}

        <line
          x1={gx(n)}
          y1={gy(base)}
          x2={gx(n)}
          y2={gy(teb)}
          stroke={PALETTE.orange}
          strokeWidth={2}
          strokeDasharray="4 3"
        />
        <circle cx={gx(n)} cy={gy(teb)} r={7} fill={PALETTE.orange} />
        <text
          x={gx(n)}
          y={gy(teb) - 14}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.orange}
        >
          {fmt(teb, 0)} °C
        </text>

        {[-150, -50, 50, 150].map((t) => (
          <g key={t}>
            <line x1={41} y1={gy(t)} x2={47} y2={gy(t)} stroke={PALETTE.axis} strokeWidth={1} />
            <text x={38} y={gy(t) + 3} textAnchor="end" fontSize={8} fill={PALETTE.slate}>
              {t}
            </text>
          </g>
        ))}
        <text x={38} y={204} textAnchor="middle" fontSize={9} fill={PALETTE.slate}>
          1
        </text>
        <text x={410} y={204} textAnchor="middle" fontSize={9} fill={PALETTE.slate}>
          10 carbones
        </text>
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Chaîne droite" value={`${fmt(base, 0)} °C`} color={PALETTE.blue} />
        <Stat label="Avec ramifications" value={`${fmt(teb, 0)} °C`} color={PALETTE.orange} />
        <Stat label="État à 25 °C" value={etat} color={PALETTE.slate} />
      </div>

      <Verdict tone="ok">
        {ram === 0
          ? "Plus la chaîne est longue, plus les molécules se retiennent entre elles, et plus il faut chauffer pour les séparer. C'est pourquoi les quatre premiers alcanes sont des gaz et les suivants des liquides."
          : "Une molécule ramifiée est plus compacte : elle offre moins de surface de contact à ses voisines, qui la retiennent moins. Elle bout donc plus bas, à nombre de carbones égal."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 5 — Équilibrer et doser une combustion                     */
/* ------------------------------------------------------------------ */

function fraction(num: number): string {
  return num % 2 === 0 ? String(num / 2) : `${num}/2`;
}

export function CombustionAlcane() {
  const [n, setN] = useState(4);
  const [complete, setComplete] = useState(true);
  const [vol, setVol] = useState(1);

  const o2 = complete ? (3 * n + 1) / 2 : (n + 1) / 2;
  const co2 = complete ? n : 0;
  const carbone = complete ? 0 : n;
  const h2o = n + 1;

  const vo2 = o2 * vol;
  const vco2 = co2 * vol;
  const vair = 5 * vo2;

  const W = 440;
  const H = 150;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Nombre de carbones de l'alcane"
          value={n}
          min={1}
          max={8}
          step={1}
          onChange={setN}
          display={`${nomAlcane(n)} — ${brute(n)}`}
        />
        <Ctrl
          label="Volume d'alcane brûlé"
          value={vol}
          min={0.5}
          max={20}
          step={0.5}
          onChange={setVol}
          display={`${fmt(vol, 1)} L`}
          color={PALETTE.purple}
        />
      </Panel>
      <Choice
        label="Type de combustion"
        value={complete ? "c" : "i"}
        options={[
          { value: "c", label: "Complète (assez d'air)" },
          { value: "i", label: "Incomplète (air insuffisant)" },
        ]}
        onChange={(v) => setComplete(v === "c")}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text
          x={W / 2}
          y={48}
          textAnchor="middle"
          fontSize={15}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {brute(n)} + {fraction(complete ? 3 * n + 1 : n + 1)} O₂ →{" "}
          {complete ? `${n > 1 ? n : ""} CO₂` : `${n > 1 ? n : ""} C`} + {n + 1 > 1 ? n + 1 : ""}{" "}
          H₂O
        </text>

        <g fontSize={11} fill={PALETTE.slate}>
          <text x={28} y={86}>
            carbone : {n} à gauche, {n} à droite
          </text>
          <text x={28} y={106}>
            hydrogène : {2 * n + 2} à gauche, {2 * (n + 1)} à droite
          </text>
          <text x={28} y={126}>
            oxygène : {fmt(2 * o2, 1)} à gauche, {fmt(2 * co2 + h2o, 1)} à droite
          </text>
        </g>

        {complete ? null : (
          <g>
            <circle cx={360} cy={100} r={26} fill="#1c1917" />
            <text x={360} y={104} textAnchor="middle" fontSize={11} fontWeight={700} fill="#ffffff">
              suie
            </text>
          </g>
        )}
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Dioxygène nécessaire" value={`${fmt(vo2, 1)} L`} color={PALETTE.red} />
        <Stat label="Air nécessaire" value={`${fmt(vair, 0)} L`} color={PALETTE.slate} />
        <Stat
          label={complete ? "CO₂ produit" : "Carbone déposé"}
          value={complete ? `${fmt(vco2, 1)} L` : `${carbone} mol/mol`}
          color={complete ? PALETTE.blue : "#1c1917"}
        />
      </div>

      <Verdict tone={complete ? "ok" : "bad"}>
        {complete
          ? "Combustion complète : tout le carbone part en dioxyde de carbone. L'air contenant 20 % de dioxygène, il en faut cinq fois le volume calculé."
          : "Combustion incomplète : faute de dioxygène, le carbone n'est pas entièrement oxydé et se dépose en suie. Du monoxyde de carbone peut aussi se former — c'est ce qui rend une combustion mal réglée dangereuse en espace clos."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 5 — La chloration du méthane                               */
/* ------------------------------------------------------------------ */

type EtapeCl = { produit: string; nom: string; equation: string };

const ETAPE_DEFAUT: EtapeCl = {
  produit: "CH₃Cl",
  nom: "chlorométhane",
  equation: "CH₄ + Cl₂ → CH₃Cl + HCl",
};

const ETAPES_CL: ReadonlyArray<EtapeCl> = [
  ETAPE_DEFAUT,
  { produit: "CH₂Cl₂", nom: "dichlorométhane", equation: "CH₃Cl + Cl₂ → CH₂Cl₂ + HCl" },
  {
    produit: "CHCl₃",
    nom: "trichlorométhane (chloroforme)",
    equation: "CH₂Cl₂ + Cl₂ → CHCl₃ + HCl",
  },
  {
    produit: "CCl₄",
    nom: "tétrachlorométhane",
    equation: "CHCl₃ + Cl₂ → CCl₄ + HCl",
  },
];

export function ChlorationMethane() {
  const [etape, setEtape] = useState(1);
  const [lumiere, setLumiere] = useState(true);
  const e = ETAPES_CL[etape - 1] ?? ETAPE_DEFAUT;

  const W = 440;
  const H = 200;

  return (
    <div className="space-y-3">
      <Choice
        label="Éclairage du ballon"
        value={lumiere ? "oui" : "non"}
        options={[
          { value: "oui", label: "À la lumière" },
          { value: "non", label: "Dans l'obscurité" },
        ]}
        onChange={(v) => setLumiere(v === "oui")}
      />
      <Ctrl
        label="Étape de la substitution"
        value={etape}
        min={1}
        max={4}
        step={1}
        onChange={setEtape}
        display={`étape ${etape} sur 4`}
        color={PALETTE.green}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill={lumiere ? "#ffffff" : "#1e293b"} />

        <text
          x={W / 2}
          y={34}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={lumiere ? PALETTE.ink : "#94a3b8"}
        >
          {lumiere ? "le dichlore jaune-vert pâlit à vue d'œil" : "rien ne se passe"}
        </text>

        <rect
          x={120}
          y={54}
          width={200}
          height={76}
          rx={10}
          fill={lumiere ? `rgba(190, 220, 90, ${0.75 - 0.17 * etape})` : "rgba(190, 220, 90, 0.75)"}
          stroke={lumiere ? PALETTE.slate : "#475569"}
          strokeWidth={2}
        />
        <text
          x={220}
          y={98}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={lumiere ? PALETTE.ink : "#cbd5e1"}
        >
          {lumiere ? e.produit : "CH₄ + Cl₂"}
        </text>

        {lumiere ? (
          <g>
            <text x={W / 2} y={158} textAnchor="middle" fontSize={13} fill={PALETTE.ink}>
              {e.equation}
            </text>
            <text x={W / 2} y={180} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
              produit : {e.nom}
            </text>
          </g>
        ) : (
          <text x={W / 2} y={168} textAnchor="middle" fontSize={11} fill="#94a3b8">
            sans lumière, la réaction ne démarre pas
          </text>
        )}
      </Board>

      <Verdict tone={lumiere ? "ok" : "bad"}>
        {lumiere
          ? "À chaque étape, un atome d'hydrogène est remplacé par un atome de chlore, et il se forme du chlorure d'hydrogène. C'est une réaction de SUBSTITUTION, la seule que puissent faire les alcanes, qui sont saturés."
          : "Sans lumière, rien. C'est la définition d'une réaction photochimique : la lumière est nécessaire pour l'amorcer. Rallume pour voir la réaction démarrer."}
      </Verdict>

      <Verdict tone="warn">
        L&apos;expérience se fait au-dessus d&apos;eau salée, et non d&apos;eau pure : dans
        l&apos;eau pure le dichlore se dissoudrait, et l&apos;on ne pourrait plus suivre sa
        disparition par la couleur.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 5 — Préparer le méthane au laboratoire                     */
/* ------------------------------------------------------------------ */

export function PreparationMethane() {
  const [masse, setMasse] = useState(18);
  const [impuretes, setImpuretes] = useState(0);
  const [tiede, setTiede] = useState(false);

  const M_CARBURE = 144; // Al4C3 : 4 × 27 + 3 × 12
  const pur = masse * (1 - impuretes / 100);
  const nCarbure = pur / M_CARBURE;
  const nCh4 = 3 * nCarbure;
  const vAttendu = (masse / M_CARBURE) * 3 * 22.4;
  const vObtenu = nCh4 * 22.4;
  const rendement = vAttendu > 0 ? (vObtenu / vAttendu) * 100 : 0;

  const W = 440;
  const H = 200;
  const hauteur = Math.min(94, (vObtenu / 12) * 94);

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Masse de carbure d'aluminium"
          value={masse}
          min={2}
          max={40}
          step={1}
          onChange={setMasse}
          display={`${masse} g`}
        />
        <Ctrl
          label="Taux d'impuretés du carbure"
          value={impuretes}
          min={0}
          max={60}
          step={1}
          onChange={setImpuretes}
          display={`${impuretes} %`}
          color={PALETTE.red}
        />
      </Panel>
      <Choice
        label="Température du bain"
        value={tiede ? "tiede" : "froid"}
        options={[
          { value: "froid", label: "Eau froide" },
          { value: "tiede", label: "Eau tiède" },
        ]}
        onChange={(v) => setTiede(v === "tiede")}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={W / 2} y={24} textAnchor="middle" fontSize={13} fill={PALETTE.ink}>
          Al₄C₃ + 12 H₂O → 4 Al(OH)₃ + 3 CH₄
        </text>

        <path
          d="M60 70 L160 70 L150 160 L70 160 Z"
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <path d="M66 118 L154 118 L150 160 L70 160 Z" fill="#bfdbfe" opacity={0.8} />
        <ellipse cx={110} cy={152} rx={26} ry={7} fill="#78716c" />
        <text x={110} y={182} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          carbure d&apos;aluminium
        </text>

        {Array.from({ length: tiede ? 9 : 4 }).map((_, i) => (
          <circle
            key={i}
            cx={88 + ((i * 29) % 46)}
            cy={76 + ((i * 17) % 34)}
            r={4 + (i % 3)}
            fill={PALETTE.green}
            opacity={0.5}
          />
        ))}

        <rect
          x={250}
          y={56}
          width={54}
          height={104}
          fill="none"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <rect x={252} y={158 - hauteur} width={50} height={hauteur} fill="#86efac" opacity={0.75} />
        <text
          x={277}
          y={44}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.green}
        >
          CH₄
        </text>
        <text x={277} y={180} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {fmt(vObtenu, 2)} L
        </text>

        <text x={330} y={80} fontSize={11} fill={PALETTE.slate}>
          attendu : {fmt(vAttendu, 2)} L
        </text>
        <text x={330} y={102} fontSize={11} fontWeight={700} fill={PALETTE.orange}>
          obtenu : {fmt(vObtenu, 2)} L
        </text>
        <text x={330} y={128} fontSize={11} fill={PALETTE.slate}>
          soit {fmt(rendement, 1)} %
        </text>
        <text x={330} y={152} fontSize={10} fill={tiede ? PALETTE.red : PALETTE.slate}>
          {tiede ? "réaction accélérée" : "réaction lente"}
        </text>
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Carbure pur" value={`${fmt(pur, 1)} g`} color={PALETTE.slate} />
        <Stat label="Méthane formé" value={`${fmt(nCh4, 3)} mol`} color={PALETTE.green} />
        <Stat label="Rendement" value={`${fmt(rendement, 1)} %`} color={PALETTE.orange} />
      </div>

      <Verdict tone={impuretes === 0 ? "ok" : "warn"}>
        {impuretes === 0
          ? "Carbure pur : une mole de Al₄C₃ donne trois moles de méthane, et le volume obtenu est exactement celui qu'annonce le calcul."
          : `Le carbure du commerce contient des impuretés. Ici ${impuretes} % de la masse ne réagit pas : le volume obtenu tombe à ${fmt(rendement, 1)} % du volume attendu. En examen, c'est l'écart entre les deux volumes qui sert à calculer le taux d'impuretés.`}
      </Verdict>

      <Verdict tone="warn">
        Ne confonds pas avec la préparation de l&apos;acétylène, qui part du carbure de CALCIUM :
        CaC₂ + 2 H₂O → C₂H₂ + Ca(OH)₂. Ici c&apos;est le carbure d&apos;ALUMINIUM.
      </Verdict>
    </div>
  );
}
