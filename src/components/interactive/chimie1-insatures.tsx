import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict, fmt } from "./controls";

/** Chimie 1ère C, D et E — chapitres 6, 7 et 8 : alcènes, alcynes et polymères. */

function indiceSub(n: number): string {
  const c = "₀₁₂₃₄₅₆₇₈₉";
  return String(n)
    .split("")
    .map((d) => c[Number(d)] ?? d)
    .join("");
}

const RACINES = ["méth", "éth", "prop", "but", "pent", "hex", "hept", "oct"];

function racine(n: number): string {
  return RACINES[n - 1] ?? `C${n}-`;
}

/* ------------------------------------------------------------------ */
/* Chapitre 6 — La géométrie des insaturés                             */
/* ------------------------------------------------------------------ */

type Geom = {
  value: string;
  nom: string;
  formule: string;
  liaisons: 1 | 2 | 3;
  angle: string;
  longueur: number;
  forme: string;
  carbone: string;
  rotation: boolean;
  hParC: number;
};

const GEOM_DEFAUT: Geom = {
  value: "ethane",
  nom: "Éthane",
  formule: "C₂H₆",
  liaisons: 1,
  angle: "109,5°",
  longueur: 154,
  forme: "tétraédrique",
  carbone: "tétragonal",
  rotation: true,
  hParC: 3,
};

const GEOMS: ReadonlyArray<Geom> = [
  GEOM_DEFAUT,
  {
    value: "ethylene",
    nom: "Éthylène",
    formule: "C₂H₄",
    liaisons: 2,
    angle: "120°",
    longueur: 134,
    forme: "plane",
    carbone: "trigonal",
    rotation: false,
    hParC: 2,
  },
  {
    value: "acetylene",
    nom: "Acétylène",
    formule: "C₂H₂",
    liaisons: 3,
    angle: "180°",
    longueur: 120,
    forme: "linéaire",
    carbone: "digonal",
    rotation: false,
    hParC: 1,
  },
];

export function StructureInsatures() {
  const [choix, setChoix] = useState("ethane");
  const [essai, setEssai] = useState(false);
  const g = GEOMS.find((x) => x.value === choix) ?? GEOM_DEFAUT;

  const W = 440;
  const H = 230;
  const cy = 112;
  const xg = 170;
  const xd = 270;

  // directions des hydrogènes selon la géométrie
  const dirs: number[] = g.liaisons === 1 ? [140, 220, 180] : g.liaisons === 2 ? [130, 230] : [180];

  return (
    <div className="space-y-3">
      <Choice
        label="Choisis la molécule"
        value={choix}
        options={GEOMS.map((o) => ({ value: o.value, label: o.nom }))}
        onChange={(v) => {
          setChoix(v);
          setEssai(false);
        }}
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
          {g.nom} — {g.formule}
        </text>

        {Array.from({ length: g.liaisons }).map((_, i) => {
          const dy = (i - (g.liaisons - 1) / 2) * 7;
          return (
            <line
              key={i}
              x1={xg + 16}
              y1={cy + dy}
              x2={xd - 16}
              y2={cy + dy}
              stroke={PALETTE.ink}
              strokeWidth={2.4}
            />
          );
        })}

        {[xg, xd].map((cx, k) => (
          <g key={cx}>
            {dirs.map((a, i) => {
              const sens = k === 0 ? a : 180 - a;
              const r = (sens * Math.PI) / 180;
              const x = cx + 46 * Math.cos(r);
              const y = cy - 46 * Math.sin(r);
              return (
                <g key={i}>
                  <line x1={cx} y1={cy} x2={x} y2={y} stroke={PALETTE.slate} strokeWidth={1.8} />
                  <circle
                    cx={x}
                    cy={y}
                    r={11}
                    fill="#e2e8f0"
                    stroke={PALETTE.gridStrong}
                    strokeWidth={1.4}
                  />
                  <text x={x} y={y + 4} textAnchor="middle" fontSize={10} fill={PALETTE.ink}>
                    H
                  </text>
                </g>
              );
            })}
            <circle cx={cx} cy={cy} r={17} fill="#334155" />
            <text
              x={cx}
              y={cy + 5}
              textAnchor="middle"
              fontSize={13}
              fontWeight={700}
              fill="#ffffff"
            >
              C
            </text>
          </g>
        ))}

        <text x={W / 2} y={cy - 46} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          C—C : {g.longueur} pm
        </text>
        <text
          x={W / 2}
          y={H - 44}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.blue}
        >
          carbone {g.carbone} — angles {g.angle} — molécule {g.forme}
        </text>

        {essai ? (
          <text
            x={W / 2}
            y={H - 18}
            textAnchor="middle"
            fontSize={12}
            fontWeight={700}
            fill={g.rotation ? PALETTE.green : PALETTE.red}
          >
            {g.rotation
              ? "la molécule tourne librement autour de la liaison C—C"
              : "impossible : la liaison multiple bloque la rotation"}
          </text>
        ) : (
          <text x={W / 2} y={H - 18} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
            appuie sur « Essayer de faire tourner »
          </text>
        )}
      </Board>

      <Choice
        value={essai ? "oui" : "non"}
        options={[
          { value: "non", label: "Molécule au repos" },
          { value: "oui", label: "Essayer de faire tourner" },
        ]}
        onChange={(v) => setEssai(v === "oui")}
      />

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Liaisons C—C" value={String(g.liaisons)} color={PALETTE.ink} />
        <Stat label="Longueur" value={`${g.longueur} pm`} color={PALETTE.blue} />
        <Stat label="H par carbone" value={String(g.hParC)} color={PALETTE.slate} />
      </div>

      <Verdict tone="ok">
        154, puis 134, puis 120 pm : plus il y a de liaisons entre deux carbones, plus ils sont
        serrés l&apos;un contre l&apos;autre. La longueur C—H, elle, vaut toujours 110 pm.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 6 — Nommer un alcène ou un alcyne                          */
/* ------------------------------------------------------------------ */

export function NomenclatureAlcene() {
  const [n, setN] = useState(5);
  const [pos, setPos] = useState(2);
  const [type, setType] = useState<"ene" | "yne">("ene");

  const p = Math.min(Math.max(1, pos), n - 1);
  const indiceGauche = p;
  const indiceDroite = n - p;
  const indice = Math.min(indiceGauche, indiceDroite);
  const parLaGauche = indiceGauche <= indiceDroite;

  const suffixe = type === "ene" ? "ène" : "yne";
  const nom = `${racine(n)}-${indice}-${suffixe}`;
  const formule =
    type === "ene"
      ? `C${indiceSub(n)}H${indiceSub(2 * n)}`
      : `C${indiceSub(n)}H${indiceSub(2 * n - 2)}`;

  const W = 440;
  const H = 190;
  const pas = Math.min(56, (W - 90) / Math.max(1, n - 1));
  const x0 = W / 2 - ((n - 1) * pas) / 2;
  const y0 = 104;

  return (
    <div className="space-y-3">
      <Choice
        label="Famille"
        value={type}
        options={[
          { value: "ene" as const, label: "Alcène (double liaison)" },
          { value: "yne" as const, label: "Alcyne (triple liaison)" },
        ]}
        onChange={setType}
      />
      <Panel>
        <Ctrl
          label="Longueur de la chaîne"
          value={n}
          min={2}
          max={8}
          step={1}
          onChange={(v) => {
            setN(v);
            setPos(Math.min(pos, v - 1));
          }}
          display={`${n} carbones`}
        />
        <Ctrl
          label="Position de la liaison multiple"
          value={p}
          min={1}
          max={Math.max(1, n - 1)}
          step={1}
          onChange={setPos}
          display={`entre C${p} et C${p + 1}`}
          color={PALETTE.orange}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        {Array.from({ length: n }).map((_, i) => {
          const x = x0 + i * pas;
          const numero = parLaGauche ? i + 1 : n - i;
          const multiple = i + 1 === p;
          const dans = i + 1 === p || i + 1 === p + 1;
          const traits = multiple ? (type === "ene" ? 2 : 3) : 1;
          return (
            <g key={i}>
              {i < n - 1
                ? Array.from({ length: traits }).map((__, k) => (
                    <line
                      key={k}
                      x1={x + 14}
                      y1={y0 + (k - (traits - 1) / 2) * 6}
                      x2={x + pas - 14}
                      y2={y0 + (k - (traits - 1) / 2) * 6}
                      stroke={multiple ? PALETTE.orange : PALETTE.ink}
                      strokeWidth={2.2}
                    />
                  ))
                : null}
              <circle cx={x} cy={y0} r={14} fill={dans ? PALETTE.orange : "#334155"} />
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
                fill={dans ? PALETTE.orange : PALETTE.slate}
              >
                {numero}
              </text>
            </g>
          );
        })}

        <text x={W / 2} y={28} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          on numérote dans le sens qui donne le plus petit indice au premier carbone de la liaison
        </text>
        <text x={W / 2} y={54} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          gauche : {indiceGauche} · droite : {indiceDroite} · on garde {indice}
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

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Formule brute" value={formule} color={PALETTE.blue} />
        <Stat
          label="Formule générale"
          value={type === "ene" ? "CnH2n" : "CnH2n−2"}
          color={PALETTE.purple}
        />
      </div>

      <Verdict tone="warn">
        {type === "ene"
          ? "Attention : CnH2n est aussi la formule des CYCLANES. Un corps de formule C₅H₁₀ peut être un alcène ou un cyclopentane — c'est la chaîne, ouverte ou fermée, qui les sépare."
          : "Attention : CnH2n−2 est aussi la formule des DIÈNES, qui ont deux doubles liaisons. Un corps de formule C₄H₆ peut être le but-1-yne, le but-2-yne ou le butadiène."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 6 — Reconnaître les isomères Z et E                        */
/* ------------------------------------------------------------------ */

const GROUPES = [
  { value: "h", label: "H", texte: "H" },
  { value: "me", label: "CH₃", texte: "CH₃" },
  { value: "et", label: "C₂H₅", texte: "C₂H₅" },
  { value: "cl", label: "Cl", texte: "Cl" },
] as const;

type GroupeId = (typeof GROUPES)[number]["value"];

function texteGroupe(id: GroupeId): string {
  return GROUPES.find((g) => g.value === id)?.texte ?? "H";
}

export function IsomerieZE() {
  const [hg, setHg] = useState<GroupeId>("me");
  const [bg, setBg] = useState<GroupeId>("h");
  const [hd, setHd] = useState<GroupeId>("me");
  const [bd, setBd] = useState<GroupeId>("h");
  const [bascule, setBascule] = useState(false);

  const hautDroit = bascule ? bd : hd;
  const basDroit = bascule ? hd : bd;

  const gaucheDifferent = hg !== bg;
  const droiteDifferent = hd !== bd;
  const existe = gaucheDifferent && droiteDifferent;

  const z = existe && hg === hautDroit;

  const W = 440;
  const H = 210;
  const cy = 108;
  const xg = 180;
  const xd = 260;

  return (
    <div className="space-y-3">
      <div className="grid gap-2 sm:grid-cols-2">
        <Choice label="Carbone gauche — haut" value={hg} options={[...GROUPES]} onChange={setHg} />
        <Choice label="Carbone gauche — bas" value={bg} options={[...GROUPES]} onChange={setBg} />
        <Choice label="Carbone droit — haut" value={hd} options={[...GROUPES]} onChange={setHd} />
        <Choice label="Carbone droit — bas" value={bd} options={[...GROUPES]} onChange={setBd} />
      </div>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <line
          x1={xg + 14}
          y1={cy - 4}
          x2={xd - 14}
          y2={cy - 4}
          stroke={PALETTE.ink}
          strokeWidth={2.4}
        />
        <line
          x1={xg + 14}
          y1={cy + 4}
          x2={xd - 14}
          y2={cy + 4}
          stroke={PALETTE.ink}
          strokeWidth={2.4}
        />

        {[
          {
            cx: xg,
            dx: -52,
            dy: -34,
            t: texteGroupe(hg),
            col: gaucheDifferent ? PALETTE.red : PALETTE.slate,
          },
          { cx: xg, dx: -52, dy: 34, t: texteGroupe(bg), col: PALETTE.slate },
          {
            cx: xd,
            dx: 52,
            dy: -34,
            t: texteGroupe(hautDroit),
            col: droiteDifferent ? PALETTE.red : PALETTE.slate,
          },
          { cx: xd, dx: 52, dy: 34, t: texteGroupe(basDroit), col: PALETTE.slate },
        ].map((s, i) => (
          <g key={i}>
            <line
              x1={s.cx}
              y1={cy}
              x2={s.cx + s.dx}
              y2={cy + s.dy}
              stroke={s.col}
              strokeWidth={2.2}
            />
            <text
              x={s.cx + s.dx * 1.3}
              y={cy + s.dy * 1.3 + 4}
              textAnchor="middle"
              fontSize={13}
              fontWeight={700}
              fill={s.col}
            >
              {s.t}
            </text>
          </g>
        ))}

        {[xg, xd].map((cx) => (
          <g key={cx}>
            <circle cx={cx} cy={cy} r={14} fill="#334155" />
            <text
              x={cx}
              y={cy + 5}
              textAnchor="middle"
              fontSize={12}
              fontWeight={700}
              fill="#ffffff"
            >
              C
            </text>
          </g>
        ))}

        <text
          x={W / 2}
          y={H - 16}
          textAnchor="middle"
          fontSize={17}
          fontWeight={700}
          fill={existe ? (z ? PALETTE.red : PALETTE.green) : PALETTE.slate}
        >
          {existe
            ? z
              ? "isomère (Z) — zusammen, ensemble"
              : "isomère (E) — entgegen, opposé"
            : "pas de stéréo-isomérie"}
        </text>
      </Board>

      <Choice
        value={bascule ? "oui" : "non"}
        options={[
          { value: "non", label: "Molécule telle quelle" },
          { value: "oui", label: "Retourner le carbone droit" },
        ]}
        onChange={(v) => setBascule(v === "oui")}
      />

      <Verdict tone={existe ? "ok" : "bad"}>
        {existe
          ? "Les deux carbones de la double liaison portent chacun deux groupes DIFFÉRENTS : l'isomérie Z/E existe. Retourne le carbone droit et tu passes à l'autre isomère — un corps distinct, avec ses propres propriétés."
          : `Pas d'isomérie Z/E : le carbone ${!gaucheDifferent ? "gauche" : "droit"} porte deux groupes identiques. Le retourner redonne exactement la même molécule.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 7 — Équilibrer une combustion d'insaturé                   */
/* ------------------------------------------------------------------ */

function demi(num: number): string {
  return num % 2 === 0 ? String(num / 2) : `${num}/2`;
}

export function CombustionInsature() {
  const [n, setN] = useState(3);
  const [type, setType] = useState<"ene" | "yne">("ene");
  const [complete, setComplete] = useState(true);

  const h = type === "ene" ? 2 * n : 2 * n - 2;
  const eau = h / 2;
  const o2num = complete ? 2 * n + eau : eau;
  const formule = `C${indiceSub(n)}H${indiceSub(h)}`;

  const W = 440;
  const H = 150;

  return (
    <div className="space-y-3">
      <Choice
        label="Famille"
        value={type}
        options={[
          { value: "ene" as const, label: "Alcène CnH2n" },
          { value: "yne" as const, label: "Alcyne CnH2n−2" },
        ]}
        onChange={setType}
      />
      <Panel>
        <Ctrl
          label="Nombre de carbones"
          value={n}
          min={2}
          max={8}
          step={1}
          onChange={setN}
          display={formule}
        />
      </Panel>
      <Choice
        value={complete ? "c" : "i"}
        options={[
          { value: "c", label: "Combustion complète" },
          { value: "i", label: "Combustion incomplète" },
        ]}
        onChange={(v) => setComplete(v === "c")}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text
          x={W / 2}
          y={46}
          textAnchor="middle"
          fontSize={15}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {formule} + {demi(o2num)} O₂ →{" "}
          {complete ? `${n > 1 ? n : ""} CO₂` : `${n > 1 ? n : ""} C`} + {eau > 1 ? eau : ""} H₂O
        </text>

        <g fontSize={11} fill={PALETTE.slate}>
          <text x={28} y={84}>
            carbone : {n} à gauche, {n} à droite ✓
          </text>
          <text x={28} y={104}>
            hydrogène : {h} à gauche, {2 * eau} à droite ✓
          </text>
          <text x={28} y={124}>
            oxygène : {o2num} à gauche, {complete ? 2 * n + eau : eau} à droite ✓
          </text>
        </g>

        {complete ? null : <circle cx={376} cy={102} r={24} fill="#1c1917" />}
        {complete ? null : (
          <text x={376} y={106} textAnchor="middle" fontSize={10} fontWeight={700} fill="#ffffff">
            suie
          </text>
        )}
      </Board>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Formule générale"
          value={type === "ene" ? `CnH2n + 3n/2 O₂` : `CnH2n−2 + (3n−1)/2 O₂`}
          color={PALETTE.purple}
        />
        <Stat label="Eau formée" value={`${eau} mol/mol`} color={PALETTE.blue} />
      </div>

      <Verdict tone="ok">
        Ne retiens pas la formule par cœur, retrouve-la : {n} carbones donnent {n} CO₂ ; {h}{" "}
        hydrogènes donnent {eau} H₂O ; ensuite tu comptes les oxygènes de droite et tu divises par
        deux.
      </Verdict>

      <Verdict tone="warn">
        Ces combustions sont très exothermiques, et pourtant on ne brûle ni les alcènes ni les
        alcynes comme combustibles : ils sont bien trop précieux comme matière première des
        plastiques. La seule exception est l&apos;acétylène du chalumeau, dont la flamme dépasse 3
        000 °C.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 7 — Hydrogéner avec Pd ou avec Ni                          */
/* ------------------------------------------------------------------ */

export function HydrogenationCatalyseur() {
  const [cata, setCata] = useState<"pd" | "ni">("pd");
  const [h2, setH2] = useState(0);

  const maxH2 = cata === "pd" ? 1 : 2;
  const ajoute = Math.min(h2, maxH2);
  const bloque = h2 > maxH2;

  const etat = ajoute === 0 ? "alcyne" : ajoute === 1 ? "alcène" : "alcane";
  const formule = ajoute === 0 ? "CH ≡ CH" : ajoute === 1 ? "CH₂ = CH₂" : "CH₃ — CH₃";
  const nom = ajoute === 0 ? "acétylène" : ajoute === 1 ? "éthylène" : "éthane";

  const W = 440;
  const H = 190;
  const traits = ajoute === 0 ? 3 : ajoute === 1 ? 2 : 1;

  return (
    <div className="space-y-3">
      <Choice
        label="Catalyseur dans le réacteur"
        value={cata}
        options={[
          { value: "pd" as const, label: "Palladium Pd (peu actif)" },
          { value: "ni" as const, label: "Nickel Ni (plus actif)" },
        ]}
        onChange={(v) => {
          setCata(v);
          setH2(0);
        }}
      />
      <Ctrl
        label="Molécules de dihydrogène envoyées"
        value={h2}
        min={0}
        max={3}
        step={1}
        onChange={setH2}
        display={`${h2} H₂`}
        color={PALETTE.green}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={W / 2} y={26} textAnchor="middle" fontSize={12} fill={PALETTE.slate}>
          catalyseur : {cata === "pd" ? "palladium" : "nickel"}
        </text>

        {Array.from({ length: traits }).map((_, i) => (
          <line
            key={i}
            x1={186}
            y1={100 + (i - (traits - 1) / 2) * 7}
            x2={254}
            y2={100 + (i - (traits - 1) / 2) * 7}
            stroke={PALETTE.ink}
            strokeWidth={2.4}
          />
        ))}
        {[170, 270].map((cx) => (
          <g key={cx}>
            <circle cx={cx} cy={100} r={17} fill="#334155" />
            <text x={cx} y={105} textAnchor="middle" fontSize={13} fontWeight={700} fill="#ffffff">
              C
            </text>
          </g>
        ))}
        {[0, 1].flatMap((cote) => {
          const cx = cote === 0 ? 170 : 270;
          const sens = cote === 0 ? -1 : 1;
          const nbH = 1 + ajoute;
          const angles = nbH === 1 ? [0] : nbH === 2 ? [40, -40] : [38, 0, -38];
          return angles.map((deg, rang) => {
            const r = (deg * Math.PI) / 180;
            const x = cx + sens * 46 * Math.cos(r);
            const y = 100 - 46 * Math.sin(r);
            const neuf = rang >= nbH - ajoute;
            return (
              <g key={`${cote}-${rang}`}>
                <line
                  x1={cx}
                  y1={100}
                  x2={x}
                  y2={y}
                  stroke={neuf ? PALETTE.green : PALETTE.slate}
                  strokeWidth={1.8}
                />
                <circle
                  cx={x}
                  cy={y}
                  r={11}
                  fill={neuf ? "#dcfce7" : "#e2e8f0"}
                  stroke={neuf ? PALETTE.green : PALETTE.gridStrong}
                  strokeWidth={1.4}
                />
                <text x={x} y={y + 4} textAnchor="middle" fontSize={10} fill={PALETTE.ink}>
                  H
                </text>
              </g>
            );
          });
        })}

        <text
          x={W / 2}
          y={162}
          textAnchor="middle"
          fontSize={15}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {formule}
        </text>
        <text x={W / 2} y={182} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {nom} — {etat}
        </text>
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="H₂ consommés" value={String(ajoute)} color={PALETTE.green} />
        <Stat label="Liaisons C—C" value={String(traits)} color={PALETTE.ink} />
        <Stat label="Produit" value={nom} color={PALETTE.blue} />
      </div>

      <Verdict tone={bloque ? "warn" : "ok"}>
        {bloque
          ? `Le ${cata === "pd" ? "palladium" : "nickel"} ne peut pas aller plus loin : le dihydrogène en trop reste dans le réacteur sans réagir.`
          : cata === "pd"
            ? "Le palladium est un catalyseur peu actif : la réaction s'arrête après l'ouverture de la première liaison π, donc à l'alcène. C₂H₂ + H₂ → C₂H₄."
            : "Le nickel est plus actif : la réaction se poursuit et ouvre les deux liaisons π successivement, jusqu'à l'alcane. C₂H₂ + 2 H₂ → C₂H₆."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 7 — La règle de Markovnikov                                */
/* ------------------------------------------------------------------ */

type Alcene = {
  value: string;
  label: string;
  formule: string;
  hA: number;
  hB: number;
  nomA: string;
  nomB: string;
  produitEau: [string, string];
  produitHCl: [string, string];
};

const ALC_DEFAUT: Alcene = {
  value: "propene",
  label: "Propène",
  formule: "CH₃ — CH = CH₂",
  hA: 1,
  hB: 2,
  nomA: "carbone n° 2",
  nomB: "carbone n° 1",
  produitEau: ["propan-2-ol", "propan-1-ol"],
  produitHCl: ["2-chloropropane", "1-chloropropane"],
};

const ALCENES: ReadonlyArray<Alcene> = [
  ALC_DEFAUT,
  {
    value: "but1ene",
    label: "But-1-ène",
    formule: "CH₃ — CH₂ — CH = CH₂",
    hA: 1,
    hB: 2,
    nomA: "carbone n° 2",
    nomB: "carbone n° 1",
    produitEau: ["butan-2-ol", "butan-1-ol"],
    produitHCl: ["2-chlorobutane", "1-chlorobutane"],
  },
  {
    value: "mbut2ene",
    label: "2-méthylbut-2-ène",
    formule: "(CH₃)₂C = CH — CH₃",
    hA: 0,
    hB: 1,
    nomA: "carbone n° 2",
    nomB: "carbone n° 3",
    produitEau: ["2-méthylbutan-2-ol", "3-méthylbutan-2-ol"],
    produitHCl: ["2-chloro-2-méthylbutane", "2-chloro-3-méthylbutane"],
  },
  {
    value: "ethylene",
    label: "Éthylène (symétrique)",
    formule: "CH₂ = CH₂",
    hA: 2,
    hB: 2,
    nomA: "carbone n° 1",
    nomB: "carbone n° 2",
    produitEau: ["éthanol", "éthanol"],
    produitHCl: ["chloroéthane", "chloroéthane"],
  },
];

export function Markovnikov() {
  const [choix, setChoix] = useState("propene");
  const [reactif, setReactif] = useState<"eau" | "hcl">("eau");
  const a = ALCENES.find((x) => x.value === choix) ?? ALC_DEFAUT;

  const symetrique = a.hA === a.hB;
  const [majeur, mineur] = reactif === "eau" ? a.produitEau : a.produitHCl;
  // l'hydrogène va sur le carbone le plus hydrogéné : c'est B si hB > hA
  const accueilH = a.hB > a.hA ? a.nomB : a.nomA;
  const accueilReste = a.hB > a.hA ? a.nomA : a.nomB;
  const reste = reactif === "eau" ? "le groupe —OH" : "l'atome de chlore";

  const W = 440;
  const H = 210;

  return (
    <div className="space-y-3">
      <Choice
        label="Choisis l'alcène"
        value={choix}
        options={ALCENES.map((o) => ({ value: o.value, label: o.label }))}
        onChange={setChoix}
      />
      <Choice
        label="Composé hydrogéné à additionner"
        value={reactif}
        options={[
          { value: "eau" as const, label: "Eau H—OH" },
          { value: "hcl" as const, label: "Chlorure d'hydrogène H—Cl" },
        ]}
        onChange={setReactif}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text
          x={W / 2}
          y={28}
          textAnchor="middle"
          fontSize={15}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {a.formule}
        </text>

        <rect
          x={30}
          y={48}
          width={176}
          height={72}
          rx={10}
          fill={a.hA >= a.hB ? "#dcfce7" : "#f1f5f9"}
          stroke={a.hA >= a.hB ? PALETTE.green : PALETTE.gridStrong}
          strokeWidth={1.6}
        />
        <text x={118} y={70} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {a.nomA}
        </text>
        <text x={118} y={98} textAnchor="middle" fontSize={22} fontWeight={700} fill={PALETTE.ink}>
          {a.hA} H
        </text>

        <rect
          x={234}
          y={48}
          width={176}
          height={72}
          rx={10}
          fill={a.hB > a.hA ? "#dcfce7" : "#f1f5f9"}
          stroke={a.hB > a.hA ? PALETTE.green : PALETTE.gridStrong}
          strokeWidth={1.6}
        />
        <text x={322} y={70} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {a.nomB}
        </text>
        <text x={322} y={98} textAnchor="middle" fontSize={22} fontWeight={700} fill={PALETTE.ink}>
          {a.hB} H
        </text>

        <text x={W / 2} y={146} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {symetrique
            ? "les deux carbones portent autant d'hydrogènes"
            : `le nouvel hydrogène part sur le ${accueilH} ; ${reste} part donc sur le ${accueilReste}`}
        </text>

        <rect x={30} y={158} width={176} height={42} rx={8} fill="#ecfdf5" />
        <text x={118} y={176} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          produit majoritaire
        </text>
        <text
          x={118}
          y={193}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.green}
        >
          {majeur}
        </text>

        <rect x={234} y={158} width={176} height={42} rx={8} fill="#f1f5f9" />
        <text x={322} y={176} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          {symetrique ? "même produit" : "produit minoritaire"}
        </text>
        <text
          x={322}
          y={193}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.slate}
        >
          {mineur}
        </text>
      </Board>

      <Verdict tone={symetrique ? "warn" : "ok"}>
        {symetrique
          ? "Alcène symétrique : les deux carbones sont identiques, un seul produit est possible. La règle de Markovnikov n'a rien à départager — elle ne sert que sur les alcènes dissymétriques."
          : `Règle de Markovnikov : l'atome d'hydrogène se fixe de préférence sur le carbone LE PLUS HYDROGÉNÉ. Ici le ${accueilH} en porte ${Math.max(a.hA, a.hB)}, contre ${Math.min(a.hA, a.hB)} pour l'autre : c'est lui qui reçoit encore. « Les riches deviennent plus riches. »`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 7 — Le test au dibrome                                     */
/* ------------------------------------------------------------------ */

type Hydro = { value: string; label: string; formule: string; insature: boolean; m: number };

const HYDRO_DEFAUT: Hydro = {
  value: "ethylene",
  label: "Éthylène",
  formule: "C₂H₄",
  insature: true,
  m: 28,
};

const HYDROS: ReadonlyArray<Hydro> = [
  HYDRO_DEFAUT,
  { value: "but1ene", label: "But-1-ène", formule: "C₄H₈", insature: true, m: 56 },
  { value: "acetylene", label: "Acétylène", formule: "C₂H₂", insature: true, m: 26 },
  { value: "ethane", label: "Éthane", formule: "C₂H₆", insature: false, m: 30 },
  { value: "hexane", label: "Hexane", formule: "C₆H₁₄", insature: false, m: 86 },
];

export function TestDibrome() {
  const [choix, setChoix] = useState("ethylene");
  const [mode, setMode] = useState<"test" | "dosage">("test");
  const [mbr, setMbr] = useState(8);
  const h = HYDROS.find((x) => x.value === choix) ?? HYDRO_DEFAUT;

  const nBr = mbr / 160;
  const masseAlcene = nBr * h.m;

  const W = 440;
  const H = 180;

  return (
    <div className="space-y-3">
      <Choice
        label="Hydrocarbure dans le tube"
        value={choix}
        options={HYDROS.map((o) => ({ value: o.value, label: o.label }))}
        onChange={setChoix}
      />
      <Choice
        value={mode}
        options={[
          { value: "test" as const, label: "Test d'identification" },
          { value: "dosage" as const, label: "Mode dosage" },
        ]}
        onChange={setMode}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <path
          d="M160 40 L280 40 L266 150 L174 150 Z"
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <path
          d="M167 94 L273 94 L266 150 L174 150 Z"
          fill={h.insature ? "#f1f5f9" : "#fb923c"}
          opacity={h.insature ? 1 : 0.85}
        />
        <text x={220} y={126} textAnchor="middle" fontSize={12} fontWeight={700} fill={PALETTE.ink}>
          {h.insature ? "incolore" : "orangée"}
        </text>
        <text x={220} y={28} textAnchor="middle" fontSize={12} fill={PALETTE.slate}>
          {h.label} ({h.formule}) + eau de dibrome
        </text>

        <text
          x={220}
          y={170}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={h.insature ? PALETTE.green : PALETTE.orange}
        >
          {h.insature ? "la solution SE DÉCOLORE" : "la couleur RESTE"}
        </text>
      </Board>

      {mode === "dosage" ? (
        <>
          <Ctrl
            label="Masse de dibrome fixée"
            value={mbr}
            min={1}
            max={40}
            step={0.5}
            onChange={setMbr}
            display={`${fmt(mbr, 1)} g`}
            color={PALETTE.orange}
          />
          <div className="grid grid-cols-3 gap-2">
            <Stat label="Moles de Br₂" value={`${fmt(nBr, 4)} mol`} color={PALETTE.orange} />
            <Stat label="Moles d'alcène" value={`${fmt(nBr, 4)} mol`} color={PALETTE.green} />
            <Stat label="Masse d'alcène" value={`${fmt(masseAlcene, 2)} g`} color={PALETTE.blue} />
          </div>
          <Verdict tone="ok">
            Une molécule d&apos;alcène fixe exactement une molécule de dibrome, de masse molaire 2 ×
            80 = 160 g/mol. En pesant le dibrome fixé, on remonte donc directement à la quantité
            d&apos;alcène — et de là à sa masse molaire, donc à sa formule brute.
          </Verdict>
        </>
      ) : (
        <Verdict tone={h.insature ? "ok" : "bad"}>
          {h.insature
            ? "Le dibrome s'additionne sur la liaison multiple et disparaît : la décoloration prouve que l'hydrocarbure est INSATURÉ. C₂H₄ + Br₂ → CH₂Br — CH₂Br."
            : "Rien ne se passe : l'hydrocarbure est SATURÉ. Un alcane ne fait pas d'addition, il ne peut faire que des substitutions — et encore, seulement à la lumière."}
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 8 — Fabriquer un polymère                                  */
/* ------------------------------------------------------------------ */

type Monomere = {
  value: string;
  label: string;
  formule: string;
  motif: string;
  masse: number;
  polymere: string;
  sigle: string;
};

const MONO_DEFAUT: Monomere = {
  value: "ethylene",
  label: "Éthylène",
  formule: "CH₂ = CH₂",
  motif: "— CH₂ — CH₂ —",
  masse: 28,
  polymere: "polyéthylène",
  sigle: "PE",
};

const MONOMERES: ReadonlyArray<Monomere> = [
  MONO_DEFAUT,
  {
    value: "vinyle",
    label: "Chlorure de vinyle",
    formule: "CH₂ = CHCl",
    motif: "— CH₂ — CHCl —",
    masse: 62.5,
    polymere: "polychlorure de vinyle",
    sigle: "PVC",
  },
  {
    value: "styrene",
    label: "Styrène",
    formule: "CH₂ = CH — C₆H₅",
    motif: "— CH₂ — CH(C₆H₅) —",
    masse: 104,
    polymere: "polystyrène",
    sigle: "PS",
  },
  {
    value: "difluoro",
    label: "1,1-difluoroéthylène",
    formule: "CH₂ = CF₂",
    motif: "— CH₂ — CF₂ —",
    masse: 64,
    polymere: "polyfluorure de vinylidène",
    sigle: "PVDF",
  },
];

export function Polymerisation() {
  const [choix, setChoix] = useState("ethylene");
  const [n, setN] = useState(6);
  const m = MONOMERES.find((x) => x.value === choix) ?? MONO_DEFAUT;

  const M = m.masse * n;

  const W = 440;
  const H = 170;
  const visibles = Math.min(n, 7);
  const larg = (W - 60) / visibles;

  return (
    <div className="space-y-3">
      <Choice
        label="Monomère"
        value={choix}
        options={MONOMERES.map((o) => ({ value: o.value, label: o.label }))}
        onChange={setChoix}
      />
      <Ctrl
        label="Nombre de monomères additionnés"
        value={n}
        min={1}
        max={400}
        step={1}
        onChange={setN}
        display={`n = ${n}`}
        color={PALETTE.purple}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={W / 2} y={26} textAnchor="middle" fontSize={13} fill={PALETTE.slate}>
          {n} × {m.formule} → {m.motif.replace(/^— | —$/g, "")} répété n fois
        </text>

        {Array.from({ length: visibles }).map((_, i) => {
          const x = 30 + i * larg;
          return (
            <g key={i}>
              <rect
                x={x}
                y={62}
                width={larg - 6}
                height={46}
                rx={6}
                fill={i % 2 === 0 ? "#dbeafe" : "#eff6ff"}
                stroke={PALETTE.blue}
                strokeWidth={1.2}
              />
              <text
                x={x + (larg - 6) / 2}
                y={90}
                textAnchor="middle"
                fontSize={10}
                fontWeight={700}
                fill={PALETTE.blue}
              >
                motif
              </text>
              {i < visibles - 1 ? (
                <line
                  x1={x + larg - 6}
                  y1={85}
                  x2={x + larg}
                  y2={85}
                  stroke={PALETTE.ink}
                  strokeWidth={2.4}
                />
              ) : null}
            </g>
          );
        })}
        {n > visibles ? (
          <text x={W / 2} y={128} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
            … et {n - visibles} autres motifs, jusqu&apos;à la macromolécule complète
          </text>
        ) : null}

        <text
          x={W / 2}
          y={154}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {m.polymere} ({m.sigle})
        </text>
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Masse du motif" value={`${fmt(m.masse, 1)} g/mol`} color={PALETTE.blue} />
        <Stat label="Indice n" value={String(n)} color={PALETTE.purple} />
        <Stat
          label="Masse du polymère"
          value={M >= 1000 ? `${fmt(M / 1000, 2)} kg/mol` : `${fmt(M, 0)} g/mol`}
          color={PALETTE.green}
        />
      </div>

      <Verdict tone="ok">
        L&apos;indice de polymérisation se calcule toujours de la même façon : n = M(polymère) /
        M(motif). Ici {fmt(M, 0)} / {fmt(m.masse, 1)} = {n}. C&apos;est la seule formule à retenir
        de ce chapitre.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 8 — Du monomère à l'objet                                  */
/* ------------------------------------------------------------------ */

type Objet = {
  value: string;
  label: string;
  polymere: string;
  sigle: string;
  motif: string;
  monomere: string;
  note: string;
};

const OBJ_DEFAUT: Objet = {
  value: "sachet",
  label: "Sachet",
  polymere: "polyéthylène basse densité",
  sigle: "PEBD",
  motif: "— (CH₂ — CH₂) —",
  monomere: "CH₂ = CH₂ (éthylène)",
  note: "Obtenu SOUS HAUTE PRESSION. C'est l'inversion qui surprend : haute pression donne basse densité.",
};

const OBJETS: ReadonlyArray<Objet> = [
  OBJ_DEFAUT,
  {
    value: "casier",
    label: "Casier, règle, jouet",
    polymere: "polyéthylène haute densité",
    sigle: "PEHD",
    motif: "— (CH₂ — CH₂) —",
    monomere: "CH₂ = CH₂ (éthylène)",
    note: "Obtenu À BASSE PRESSION. Même motif que le sachet, mais rigide.",
  },
  {
    value: "tuyau",
    label: "Tuyau, prise électrique",
    polymere: "polychlorure de vinyle",
    sigle: "PVC",
    motif: "— (CH₂ — CHCl) —",
    monomere: "CH₂ = CHCl (chlorure de vinyle)",
    note: "Le chlorure de vinyle vient de l'acétylène : CH ≡ CH + HCl → CH₂ = CHCl, catalysé par HgCl₂ à 200 °C.",
  },
  {
    value: "barquette",
    label: "Barquette d'emballage",
    polymere: "polystyrène",
    sigle: "PS",
    motif: "— (CH₂ — CHC₆H₅) —",
    monomere: "CH₂ = CH — C₆H₅ (styrène)",
    note: "Solide thermoplastique très dur. Il sert à emballer les objets fragiles et comme isolant thermique et phonique.",
  },
];

export function PolymeresUsages() {
  const [choix, setChoix] = useState("sachet");
  const o = OBJETS.find((x) => x.value === choix) ?? OBJ_DEFAUT;

  const W = 440;
  const H = 180;

  return (
    <div className="space-y-3">
      <Choice
        label="Choisis un objet du quotidien"
        value={choix}
        options={OBJETS.map((x) => ({ value: x.value, label: x.label }))}
        onChange={setChoix}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        {[
          { y: 24, titre: "l'objet", valeur: o.label, col: PALETTE.slate },
          { y: 62, titre: "le polymère", valeur: `${o.polymere} (${o.sigle})`, col: PALETTE.blue },
          { y: 100, titre: "son motif", valeur: o.motif, col: PALETTE.purple },
          { y: 138, titre: "le monomère de départ", valeur: o.monomere, col: PALETTE.green },
        ].map((l, i) => (
          <g key={i}>
            <rect x={20} y={l.y} width={400} height={30} rx={6} fill="#f8fafc" />
            <text x={32} y={l.y + 20} fontSize={10} fill={PALETTE.slate}>
              {l.titre}
            </text>
            <text x={408} y={l.y + 20} textAnchor="end" fontSize={12} fontWeight={700} fill={l.col}>
              {l.valeur}
            </text>
          </g>
        ))}
      </Board>

      <Verdict tone="ok">{o.note}</Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 8 — La lampe à carbure                                     */
/* ------------------------------------------------------------------ */

export function CarbureAcetylene() {
  const [masse, setMasse] = useState(70);
  const [impuretes, setImpuretes] = useState(33);
  const [allume, setAllume] = useState(false);

  const M_CAC2 = 64;
  const pur = masse * (1 - impuretes / 100);
  const n = pur / M_CAC2;
  const mGaz = n * 26;
  const vGaz = n * 22.4;
  const vAttendu = (masse / M_CAC2) * 22.4;
  const rendement = vAttendu > 0 ? (vGaz / vAttendu) * 100 : 0;

  const W = 440;
  const H = 210;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Masse de carbure de calcium"
          value={masse}
          min={10}
          max={150}
          step={1}
          onChange={setMasse}
          display={`${masse} g`}
        />
        <Ctrl
          label="Taux d'impuretés"
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
        value={allume ? "oui" : "non"}
        options={[
          { value: "non", label: "Bec éteint" },
          { value: "oui", label: "Allumer le bec" },
        ]}
        onChange={(v) => setAllume(v === "oui")}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill={allume ? "#fffbeb" : "#ffffff"} />
        <text x={W / 2} y={24} textAnchor="middle" fontSize={13} fill={PALETTE.ink}>
          CaC₂ + 2 H₂O → C₂H₂ + Ca(OH)₂
        </text>

        <rect x={74} y={62} width={16} height={46} fill="#93c5fd" />
        <text x={82} y={56} textAnchor="middle" fontSize={10} fill={PALETTE.blue}>
          eau
        </text>
        <circle cx={82} cy={120} r={3} fill="#3b82f6" />
        <circle cx={82} cy={134} r={3} fill="#3b82f6" />

        <path
          d="M46 140 L120 140 L112 190 L54 190 Z"
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <ellipse cx={83} cy={180} rx={22} ry={7} fill="#78716c" />
        <text x={83} y={204} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          carbure de calcium
        </text>

        <path
          d="M120 148 Q 180 148 180 110 L180 86"
          fill="none"
          stroke={PALETTE.slate}
          strokeWidth={2.4}
        />

        <rect
          x={200}
          y={60}
          width={56}
          height={120}
          fill="none"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <rect
          x={202}
          y={178 - Math.min(116, (vGaz / 40) * 116)}
          width={52}
          height={Math.min(116, (vGaz / 40) * 116)}
          fill="#cbd5e1"
          opacity={0.8}
        />
        <text x={228} y={50} textAnchor="middle" fontSize={11} fontWeight={700} fill={PALETTE.ink}>
          C₂H₂
        </text>
        <text x={228} y={198} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {fmt(vGaz, 1)} L
        </text>

        {allume ? (
          <g>
            <path d="M292 150 Q 304 110 316 150 Q 304 136 292 150" fill="#f59e0b" />
            <path d="M298 150 Q 304 124 310 150 Q 304 142 298 150" fill="#fde68a" />
            <text x={304} y={176} textAnchor="middle" fontSize={11} fontWeight={700} fill="#b45309">
              flamme vive
            </text>
            <text x={304} y={194} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
              principe de la lampe à carbure
            </text>
          </g>
        ) : null}

        <text x={340} y={72} fontSize={11} fill={PALETTE.slate}>
          attendu : {fmt(vAttendu, 1)} L
        </text>
        <text x={340} y={94} fontSize={11} fontWeight={700} fill={PALETTE.orange}>
          obtenu : {fmt(vGaz, 1)} L
        </text>
        <text x={340} y={116} fontSize={11} fill={PALETTE.slate}>
          {fmt(rendement, 1)} %
        </text>
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Carbure pur" value={`${fmt(pur, 1)} g`} color={PALETTE.slate} />
        <Stat label="Acétylène formé" value={`${fmt(mGaz, 1)} g`} color={PALETTE.green} />
        <Stat label="Impuretés" value={`${fmt(masse - pur, 1)} g`} color={PALETTE.red} />
      </div>

      <Verdict tone={impuretes > 0 ? "warn" : "ok"}>
        {impuretes > 0
          ? `Avec ${masse} g de carbure à ${impuretes} % d'impuretés, on n'obtient que ${fmt(mGaz, 1)} g d'acétylène au lieu de ${fmt((masse / M_CAC2) * 26, 1)} g. C'est l'écart entre les deux qui, en examen, sert à calculer le taux d'impuretés.`
          : "Carbure pur : une mole de CaC₂ donne une mole d'acétylène. Le gaz obtenu se purifie en le faisant barboter dans une solution de sulfate de cuivre, qui retient les impuretés sulfurées."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 8 — Hydrater, déshydrater                                  */
/* ------------------------------------------------------------------ */

export function DeshydratationAlcool() {
  const [temp, setTemp] = useState(170);
  const [acide, setAcide] = useState<"dilue" | "concentre">("concentre");

  const deshydrate = acide === "concentre" && temp >= 150;
  const hydrate = acide === "dilue" && temp < 100;

  const W = 440;
  const H = 180;

  return (
    <div className="space-y-3">
      <Choice
        label="Acide dans le ballon"
        value={acide}
        options={[
          { value: "dilue" as const, label: "Acide dilué" },
          { value: "concentre" as const, label: "Acide sulfurique concentré" },
        ]}
        onChange={setAcide}
      />
      <Ctrl
        label="Température"
        value={temp}
        min={20}
        max={220}
        step={5}
        onChange={setTemp}
        display={`${temp} °C`}
        color={temp >= 150 ? PALETTE.red : PALETTE.blue}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <rect
          x={26}
          y={52}
          width={160}
          height={56}
          rx={10}
          fill="#eff6ff"
          stroke={PALETTE.blue}
          strokeWidth={1.6}
        />
        <text x={106} y={76} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          alcool
        </text>
        <text x={106} y={96} textAnchor="middle" fontSize={13} fontWeight={700} fill={PALETTE.blue}>
          CH₃ — CH₂ — OH
        </text>

        <rect
          x={254}
          y={52}
          width={160}
          height={56}
          rx={10}
          fill="#ecfdf5"
          stroke={PALETTE.green}
          strokeWidth={1.6}
        />
        <text x={334} y={76} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          alcène + eau
        </text>
        <text
          x={334}
          y={96}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={PALETTE.green}
        >
          CH₂ = CH₂ + H₂O
        </text>

        {deshydrate ? (
          <g>
            <line x1={192} y1={72} x2={246} y2={72} stroke={PALETTE.red} strokeWidth={3} />
            <polygon points="252,72 240,66 240,78" fill={PALETTE.red} />
            <text
              x={219}
              y={60}
              textAnchor="middle"
              fontSize={10}
              fontWeight={700}
              fill={PALETTE.red}
            >
              déshydratation
            </text>
          </g>
        ) : null}
        {hydrate ? (
          <g>
            <line x1={248} y1={92} x2={194} y2={92} stroke={PALETTE.blue} strokeWidth={3} />
            <polygon points="188,92 200,86 200,98" fill={PALETTE.blue} />
            <text
              x={219}
              y={110}
              textAnchor="middle"
              fontSize={10}
              fontWeight={700}
              fill={PALETTE.blue}
            >
              hydratation
            </text>
          </g>
        ) : null}
        {!deshydrate && !hydrate ? (
          <text x={219} y={84} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
            ⇌
          </text>
        ) : null}

        <rect x={26} y={132} width={388} height={14} rx={7} fill="#e2e8f0" />
        <rect
          x={26}
          y={132}
          width={Math.max(4, ((temp - 20) / 200) * 388)}
          height={14}
          rx={7}
          fill={temp >= 150 ? PALETTE.red : PALETTE.blue}
        />
        <line
          x1={26 + (130 / 200) * 388}
          y1={126}
          x2={26 + (130 / 200) * 388}
          y2={152}
          stroke={PALETTE.slate}
          strokeWidth={1.4}
        />
        <text
          x={26 + (130 / 200) * 388}
          y={166}
          textAnchor="middle"
          fontSize={9}
          fill={PALETTE.slate}
        >
          150 °C
        </text>
        <text x={32} y={166} fontSize={9} fill={PALETTE.slate}>
          20 °C
        </text>
        <text x={408} y={166} textAnchor="end" fontSize={9} fill={PALETTE.slate}>
          220 °C
        </text>
      </Board>

      <Verdict tone={deshydrate || hydrate ? "ok" : "warn"}>
        {deshydrate
          ? "Acide sulfurique concentré et forte chaleur : l'eau est arrachée à l'alcool, et il reste l'alcène. C'est la déshydratation, et c'est ainsi qu'on prépare un alcène au laboratoire."
          : hydrate
            ? "Acide dilué et température douce : l'eau s'additionne sur la double liaison et l'alcool se reforme. C'est l'hydratation du chapitre 7, exactement la réaction inverse."
            : "Entre les deux, aucun sens ne l'emporte franchement. Ce sont les CONDITIONS qui décident du sens : acide dilué et douceur d'un côté, acide concentré et 170 °C de l'autre."}
      </Verdict>
    </div>
  );
}
