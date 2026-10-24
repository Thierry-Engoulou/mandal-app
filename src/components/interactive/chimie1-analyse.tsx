import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict, fmt } from "./controls";

/** Chimie 1ère C, D et E — chapitres 1 et 2 : analyse d'un composé organique. */

/* ------------------------------------------------------------------ */
/* Chapitre 1 — Organique ou minéral ?                                 */
/* ------------------------------------------------------------------ */

type Echantillon = {
  value: string;
  label: string;
  formule: string;
  organique: boolean;
  auFeu: string;
  piege?: string;
};

const ECH_DEFAUT: Echantillon = {
  value: "sucre",
  label: "Sucre",
  formule: "C₁₂H₂₂O₁₁",
  organique: true,
  auFeu: "fond, brunit, noircit, puis brûle en laissant du carbone",
};

const ECHANTILLONS: ReadonlyArray<Echantillon> = [
  ECH_DEFAUT,
  {
    value: "huile",
    label: "Huile de palme",
    formule: "chaîne en C₁₆ et C₁₈",
    organique: true,
    auFeu: "fume, noircit et s'enflamme",
  },
  {
    value: "essence",
    label: "Essence",
    formule: "mélange de C₅ à C₁₀",
    organique: true,
    auFeu: "s'enflamme immédiatement, flamme jaune et fumante",
  },
  {
    value: "sel",
    label: "Sel de cuisine",
    formule: "NaCl",
    organique: false,
    auFeu: "ne noircit pas, ne brûle pas, fond vers 800 °C",
  },
  {
    value: "calcaire",
    label: "Calcaire",
    formule: "CaCO₃",
    organique: false,
    auFeu: "se décompose en chaux et en CO₂, sans noircir",
    piege: "Il contient du carbone, et pourtant il est minéral.",
  },
  {
    value: "co2",
    label: "Dioxyde de carbone",
    formule: "CO₂",
    organique: false,
    auFeu: "ne brûle pas : il éteint les flammes",
    piege: "Il contient du carbone, et pourtant il est minéral.",
  },
];

export function OrganiqueMineral() {
  const [choix, setChoix] = useState("sucre");
  const [chauffe, setChauffe] = useState(false);
  const e = ECHANTILLONS.find((x) => x.value === choix) ?? ECH_DEFAUT;

  const W = 440;
  const H = 180;

  return (
    <div className="space-y-3">
      <Choice
        label="Pose un échantillon dans la capsule"
        value={choix}
        options={ECHANTILLONS.map((o) => ({ value: o.value, label: o.label }))}
        onChange={(v) => {
          setChoix(v);
          setChauffe(false);
        }}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text
          x={W / 2}
          y={24}
          textAnchor="middle"
          fontSize={14}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {e.label} — {e.formule}
        </text>

        <ellipse
          cx={W / 2}
          cy={92}
          rx={70}
          ry={20}
          fill={chauffe ? (e.organique ? "#1c1917" : "#e2e8f0") : "#f1f5f9"}
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <text
          x={W / 2}
          y={97}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={chauffe && e.organique ? "#ffffff" : PALETTE.slate}
        >
          {chauffe ? (e.organique ? "résidu noir" : "inchangé") : "échantillon"}
        </text>

        {chauffe ? (
          <g>
            <path
              d={`M${W / 2 - 26} 118 q 8 14 0 26 M${W / 2} 118 q -8 16 0 30 M${W / 2 + 26} 118 q 8 14 0 26`}
              fill="none"
              stroke={PALETTE.orange}
              strokeWidth={3}
              strokeLinecap="round"
            />
            <text x={W / 2} y={166} textAnchor="middle" fontSize={11} fill={PALETTE.orange}>
              on chauffe au bec
            </text>
          </g>
        ) : (
          <text x={W / 2} y={150} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
            appuie sur « Chauffer » pour voir ce qui se passe
          </text>
        )}
      </Board>

      <Choice
        value={chauffe ? "oui" : "non"}
        options={[
          { value: "non", label: "Éteindre" },
          { value: "oui", label: "Chauffer" },
        ]}
        onChange={(v) => setChauffe(v === "oui")}
      />

      {chauffe ? (
        <>
          <Verdict tone={e.organique ? "warn" : "ok"}>
            {e.label} : {e.auFeu}.
          </Verdict>
          <Verdict tone={e.organique ? "ok" : "bad"}>
            {e.organique
              ? "Le résidu noir est du carbone : c'est un composé ORGANIQUE."
              : `Pas de carbone libéré : c'est un composé MINÉRAL.${e.piege ? " " + e.piege : ""}`}
          </Verdict>
        </>
      ) : (
        <Verdict tone="warn">
          Un composé organique est un composé du carbone — à trois exceptions près, que tu
          rencontreras dans cette liste : le dioxyde de carbone, le monoxyde de carbone et les
          carbonates.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 1 — Les quatre caractères                                  */
/* ------------------------------------------------------------------ */

type Caractere = {
  value: string;
  label: string;
  organique: string;
  mineral: string;
  lecon: string;
};

const CAR_DEFAUT: Caractere = {
  value: "chaleur",
  label: "Chauffer",
  organique: "se décompose dès 150 à 300 °C, noircit",
  mineral: "tient jusqu'à 800 °C et au-delà",
  lecon: "Les composés organiques sont THERMIQUEMENT PEU STABLES.",
};

const CARACTERES: ReadonlyArray<Caractere> = [
  CAR_DEFAUT,
  {
    value: "eau",
    label: "Mettre dans l'eau",
    organique: "ne se dissout pas (ou très peu)",
    mineral: "se dissout facilement",
    lecon: "Les composés organiques sont PEU SOLUBLES DANS L'EAU.",
  },
  {
    value: "solvant",
    label: "Mettre dans l'essence",
    organique: "se dissout bien",
    mineral: "ne se dissout pas",
    lecon: "Les composés organiques sont SOLUBLES DANS LES SOLVANTS ORGANIQUES.",
  },
  {
    value: "courant",
    label: "Brancher l'ohmmètre",
    organique: "l'aiguille ne bouge pas",
    mineral: "le courant passe (une fois dissous)",
    lecon: "Les composés organiques NE CONDUISENT PAS LE COURANT : ils ne sont pas ioniques.",
  },
];

export function CaracteresOrganiques() {
  const [test, setTest] = useState("chaleur");
  const c = CARACTERES.find((x) => x.value === test) ?? CAR_DEFAUT;

  const W = 440;
  const H = 190;

  return (
    <div className="space-y-3">
      <Choice
        label="Choisis le test"
        value={test}
        options={CARACTERES.map((o) => ({ value: o.value, label: o.label }))}
        onChange={setTest}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <rect x={16} y={16} width={198} height={158} rx={10} fill="#eff6ff" />
        <text x={115} y={38} textAnchor="middle" fontSize={12} fontWeight={700} fill={PALETTE.blue}>
          SUCRE (organique)
        </text>
        <foreignObject x={26} y={50} width={178} height={110}>
          <div
            style={{
              fontSize: 12,
              color: "#1e3a8a",
              lineHeight: 1.4,
              fontFamily: "system-ui, sans-serif",
            }}
          >
            {c.organique}
          </div>
        </foreignObject>

        <rect x={226} y={16} width={198} height={158} rx={10} fill="#f1f5f9" />
        <text
          x={325}
          y={38}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.slate}
        >
          SEL (minéral)
        </text>
        <foreignObject x={236} y={50} width={178} height={110}>
          <div
            style={{
              fontSize: 12,
              color: "#334155",
              lineHeight: 1.4,
              fontFamily: "system-ui, sans-serif",
            }}
          >
            {c.mineral}
          </div>
        </foreignObject>
      </Board>

      <Verdict tone="ok">{c.lecon}</Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 1 — Les trois tests d'identification des éléments          */
/* ------------------------------------------------------------------ */

type Compose = {
  value: string;
  label: string;
  formule: string;
  c: boolean;
  h: boolean;
  n: boolean;
};

const COMP_DEFAUT: Compose = {
  value: "glucose",
  label: "Glucose",
  formule: "C₆H₁₂O₆",
  c: true,
  h: true,
  n: false,
};

const COMPOSES: ReadonlyArray<Compose> = [
  COMP_DEFAUT,
  { value: "uree", label: "Urée", formule: "CO(NH₂)₂", c: true, h: true, n: true },
  { value: "methane", label: "Méthane", formule: "CH₄", c: true, h: true, n: false },
  { value: "carbone", label: "Carbone pur", formule: "C", c: true, h: false, n: false },
  { value: "sel", label: "Sel de cuisine", formule: "NaCl", c: false, h: false, n: false },
];

type TestEl = "carbone" | "hydrogene" | "azote";

export function TestsElements() {
  const [choix, setChoix] = useState("glucose");
  const [test, setTest] = useState<TestEl>("carbone");
  const x = COMPOSES.find((o) => o.value === choix) ?? COMP_DEFAUT;

  const positif = test === "carbone" ? x.c : test === "hydrogene" ? x.h : x.n;
  const reactif =
    test === "carbone"
      ? "eau de chaux"
      : test === "hydrogene"
        ? "sulfate de cuivre anhydre"
        : "papier pH humide";
  const attendu =
    test === "carbone"
      ? "l'eau de chaux se trouble"
      : test === "hydrogene"
        ? "le sulfate de cuivre blanc devient BLEU"
        : "il se dégage de l'ammoniac, qui bleuit le papier pH";
  const negatif =
    test === "carbone"
      ? "l'eau de chaux reste limpide"
      : test === "hydrogene"
        ? "le sulfate de cuivre reste blanc"
        : "aucun dégagement, le papier ne change pas";

  const W = 440;
  const H = 200;
  const couleur = positif
    ? test === "carbone"
      ? "#e2e8f0"
      : test === "hydrogene"
        ? "#3b82f6"
        : "#60a5fa"
    : test === "hydrogene"
      ? "#ffffff"
      : "#dbeafe";

  return (
    <div className="space-y-3">
      <Choice
        label="Choisis le composé à analyser"
        value={choix}
        options={COMPOSES.map((o) => ({ value: o.value, label: o.label }))}
        onChange={setChoix}
      />
      <Choice
        label="Choisis l'élément à rechercher"
        value={test}
        options={[
          { value: "carbone" as TestEl, label: "Carbone" },
          { value: "hydrogene" as TestEl, label: "Hydrogène" },
          { value: "azote" as TestEl, label: "Azote" },
        ]}
        onChange={setTest}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text
          x={W / 2}
          y={24}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {x.label} ({x.formule}) — réactif : {reactif}
        </text>

        <path
          d="M150 60 L290 60 L270 160 L170 160 Z"
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <path
          d="M158 104 L282 104 L270 160 L170 160 Z"
          fill={couleur}
          stroke="none"
          opacity={0.85}
        />
        <text x={220} y={136} textAnchor="middle" fontSize={11} fontWeight={700} fill={PALETTE.ink}>
          {positif ? "RÉACTION" : "rien"}
        </text>

        <text x={W / 2} y={186} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {positif ? attendu : negatif}
        </text>
      </Board>

      <Verdict tone={positif ? "ok" : "bad"}>
        {positif
          ? `Test POSITIF : ${test === "carbone" ? "le carbone" : test === "hydrogene" ? "l'hydrogène" : "l'azote"} est bien présent dans cet échantillon de ${x.label.toLowerCase()}.`
          : `Test NÉGATIF : cet échantillon de ${x.label.toLowerCase()} ne contient pas cet élément.`}
      </Verdict>

      <Verdict tone="warn">
        Attention : ces trois tests disent seulement QUELS éléments sont présents. Ils ne disent pas
        en quelle proportion — c'est le rôle de l'analyse quantitative.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 1 — De la combustion aux pourcentages                      */
/* ------------------------------------------------------------------ */

export function AnalyseElementaire() {
  const [m, setM] = useState(1.0);
  const [mco2, setMco2] = useState(2.2);
  const [mh2o, setMh2o] = useState(0.9);

  const pc = (3 / 11) * (mco2 / m) * 100;
  const ph = (1 / 9) * (mh2o / m) * 100;
  const po = 100 - pc - ph;
  const coherent = po > -1 && po < 101;

  const W = 440;
  const H = 150;
  const bar = (p: number) => Math.max(0, Math.min(100, p)) * 3.6;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Masse m de l'échantillon brûlé"
          value={m}
          min={0.5}
          max={3}
          step={0.1}
          onChange={setM}
          display={`${fmt(m, 2)} g`}
        />
        <Ctrl
          label="Masse de CO₂ recueillie"
          value={mco2}
          min={0}
          max={8}
          step={0.1}
          onChange={setMco2}
          display={`${fmt(mco2, 2)} g`}
          color={PALETTE.slate}
        />
        <Ctrl
          label="Masse d'eau recueillie"
          value={mh2o}
          min={0}
          max={4}
          step={0.1}
          onChange={setMh2o}
          display={`${fmt(mh2o, 2)} g`}
          color={PALETTE.blue}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={20} y={24} fontSize={12} fontWeight={700} fill={PALETTE.ink}>
          Composition centésimale massique
        </text>

        {[
          { lettre: "C", p: pc, y: 40, col: "#334155" },
          { lettre: "H", p: ph, y: 72, col: PALETTE.blue },
          { lettre: "O", p: Math.max(0, po), y: 104, col: PALETTE.orange },
        ].map((b) => {
          const w = bar(b.p);
          const dedans = w > 76;
          return (
            <g key={b.lettre}>
              <rect x={20} y={b.y} width={w} height={24} fill={b.col} rx={3} />
              <text
                x={dedans ? 28 : 20 + w + 8}
                y={b.y + 17}
                fontSize={11}
                fontWeight={700}
                fill={dedans ? "#ffffff" : b.col}
              >
                {b.lettre} {fmt(b.p, 1)} %
              </text>
            </g>
          );
        })}

        <line x1={20} y1={34} x2={380} y2={34} stroke={PALETTE.gridStrong} strokeWidth={1} />
        <text x={380} y={30} textAnchor="end" fontSize={9} fill={PALETTE.slate}>
          100 %
        </text>
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="% de carbone" value={`${fmt(pc, 1)} %`} color={PALETTE.ink} />
        <Stat label="% d'hydrogène" value={`${fmt(ph, 1)} %`} color={PALETTE.blue} />
        <Stat label="% d'oxygène" value={`${fmt(po, 1)} %`} color={PALETTE.orange} />
      </div>

      <Verdict tone={coherent ? "ok" : "bad"}>
        {coherent
          ? "%C = (3/11) × m(CO₂)/m × 100 — parce que dans 44 g de CO₂ il y a 12 g de carbone. %H = (1/9) × m(H₂O)/m × 100 — parce que dans 18 g d'eau il y a 2 g d'hydrogène. L'oxygène se déduit par différence : on ne le dose jamais directement."
          : "La somme dépasse 100 % : ces masses sont impossibles pour un échantillon de cette masse. Vérifie tes données — c'est exactement le réflexe à avoir en examen."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 2 — Trouver la formule brute                               */
/* ------------------------------------------------------------------ */

function indiceSub(n: number): string {
  const chiffres = "₀₁₂₃₄₅₆₇₈₉";
  if (n <= 1) return "";
  return String(n)
    .split("")
    .map((d) => chiffres[Number(d)] ?? d)
    .join("");
}

export function FormuleBrute() {
  const [pc, setPc] = useState(52.2);
  const [ph, setPh] = useState(13.0);
  const [mm, setMm] = useState(46);

  const po = 100 - pc - ph;
  const x = (pc * mm) / 1200;
  const y = (ph * mm) / 100;
  const z = (po * mm) / 1600;

  const rx = Math.round(x);
  const ry = Math.round(y);
  const rz = Math.round(z);
  const ecart = Math.abs(x - rx) + Math.abs(y - ry) + Math.abs(z - rz);
  const propre = ecart < 0.35 && rx >= 1 && ry >= 1 && po > -0.5;

  const formule = `C${indiceSub(rx)}H${indiceSub(ry)}${rz > 0 ? `O${indiceSub(rz)}` : ""}`;

  const W = 440;
  const H = 160;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Pourcentage de carbone"
          value={pc}
          min={10}
          max={92}
          step={0.1}
          onChange={setPc}
          display={`${fmt(pc, 1)} %`}
        />
        <Ctrl
          label="Pourcentage d'hydrogène"
          value={ph}
          min={1}
          max={25}
          step={0.1}
          onChange={setPh}
          display={`${fmt(ph, 1)} %`}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Masse molaire M"
          value={mm}
          min={16}
          max={200}
          step={1}
          onChange={setMm}
          display={`${fmt(mm, 0)} g/mol`}
          color={PALETTE.purple}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={20} y={26} fontSize={12} fill={PALETTE.slate}>
          12x / %C = y / %H = 16z / %O = M / 100
        </text>

        <text x={20} y={58} fontSize={13} fill={PALETTE.ink}>
          x = %C × M / 1200 = {fmt(x, 2)}
        </text>
        <text x={20} y={82} fontSize={13} fill={PALETTE.blue}>
          y = %H × M / 100 = {fmt(y, 2)}
        </text>
        <text x={20} y={106} fontSize={13} fill={PALETTE.orange}>
          z = %O × M / 1600 = {fmt(z, 2)}
        </text>

        <rect
          x={266}
          y={44}
          width={154}
          height={70}
          rx={10}
          fill={propre ? "#ecfdf5" : "#fef2f2"}
          stroke={propre ? PALETTE.green : PALETTE.red}
          strokeWidth={1.6}
        />
        <text x={343} y={70} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          formule brute
        </text>
        <text
          x={343}
          y={98}
          textAnchor="middle"
          fontSize={22}
          fontWeight={700}
          fill={propre ? PALETTE.green : PALETTE.red}
        >
          {propre ? formule : "—"}
        </text>

        <text x={20} y={140} fontSize={11} fill={PALETTE.slate}>
          %O = 100 − %C − %H = {fmt(po, 1)} %
        </text>
      </Board>

      <Verdict tone={propre ? "ok" : "bad"}>
        {propre
          ? `Les trois résultats tombent sur des entiers : la formule brute est ${formule}. En examen, c'est ce test d'entier qui te confirme que tu n'as pas fait d'erreur de calcul.`
          : "Les résultats ne sont pas entiers : la masse molaire ou les pourcentages ne vont pas ensemble. Un nombre d'atomes ne peut pas être décimal — c'est le signal qu'il faut reprendre les données."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 2 — La formule la plus simple                              */
/* ------------------------------------------------------------------ */

function pgcd(a: number, b: number): number {
  return b === 0 ? a : pgcd(b, a % b);
}

export function FormuleSimple() {
  const [pc, setPc] = useState(40);
  const [ph, setPh] = useState(6.7);
  const [k, setK] = useState(1);

  const po = 100 - pc - ph;
  const nc = pc / 12;
  const nh = ph / 1;
  const no = po / 16;
  const mini = Math.min(nc, nh > 0 ? nh : Infinity, no > 0 ? no : Infinity);

  const rc = nc / mini;
  const rh = nh / mini;
  const ro = no / mini;

  // on cherche le plus petit multiplicateur qui rend les trois entiers
  let mult = 1;
  for (let t = 1; t <= 8; t++) {
    const e =
      Math.abs(rc * t - Math.round(rc * t)) +
      Math.abs(rh * t - Math.round(rh * t)) +
      Math.abs(ro * t - Math.round(ro * t));
    if (e < 0.12) {
      mult = t;
      break;
    }
    mult = t;
  }

  let ec = Math.round(rc * mult);
  let eh = Math.round(rh * mult);
  let eo = Math.round(ro * mult);
  const d = pgcd(pgcd(Math.max(1, ec), Math.max(1, eh)), Math.max(1, eo || eh));
  if (d > 1) {
    ec = Math.round(ec / d);
    eh = Math.round(eh / d);
    eo = Math.round(eo / d);
  }

  const base = `C${indiceSub(ec)}H${indiceSub(eh)}${eo > 0 ? `O${indiceSub(eo)}` : ""}`;
  const brute = `C${indiceSub(ec * k)}H${indiceSub(eh * k)}${eo > 0 ? `O${indiceSub(eo * k)}` : ""}`;
  const masse = (12 * ec + eh + 16 * eo) * k;
  const propre = po > -0.5 && ec >= 1 && eh >= 1 && ec <= 30 && eh <= 60;

  const W = 440;
  const H = 170;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Pourcentage de carbone"
          value={pc}
          min={10}
          max={92}
          step={0.1}
          onChange={setPc}
          display={`${fmt(pc, 1)} %`}
        />
        <Ctrl
          label="Pourcentage d'hydrogène"
          value={ph}
          min={1}
          max={25}
          step={0.1}
          onChange={setPh}
          display={`${fmt(ph, 1)} %`}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Multiplicateur k"
          value={k}
          min={1}
          max={8}
          step={1}
          onChange={setK}
          display={`k = ${fmt(k, 0)}`}
          color={PALETTE.purple}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={20} y={24} fontSize={12} fill={PALETTE.slate}>
          on divise chaque pourcentage par la masse de l&apos;élément
        </text>

        <text x={20} y={52} fontSize={12} fill={PALETTE.ink}>
          C : {fmt(pc, 1)} / 12 = {fmt(nc, 3)}
        </text>
        <text x={20} y={74} fontSize={12} fill={PALETTE.blue}>
          H : {fmt(ph, 1)} / 1 = {fmt(nh, 3)}
        </text>
        <text x={20} y={96} fontSize={12} fill={PALETTE.orange}>
          O : {fmt(po, 1)} / 16 = {fmt(no, 3)}
        </text>
        <text x={20} y={124} fontSize={11} fill={PALETTE.slate}>
          puis on ramène le plus petit à 1 : {fmt(rc, 2)} : {fmt(rh, 2)} : {fmt(ro, 2)}
        </text>

        <rect
          x={254}
          y={40}
          width={166}
          height={104}
          rx={10}
          fill={propre ? "#eff6ff" : "#fef2f2"}
          stroke={propre ? PALETTE.blue : PALETTE.red}
          strokeWidth={1.6}
        />
        <text x={337} y={62} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          formule la plus simple
        </text>
        <text x={337} y={86} textAnchor="middle" fontSize={19} fontWeight={700} fill={PALETTE.ink}>
          {propre ? base : "—"}
        </text>
        <text x={337} y={110} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          avec k = {k} : {propre ? brute : "—"}
        </text>
        <text
          x={337}
          y={132}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.purple}
        >
          M = {propre ? `${fmt(masse, 0)} g/mol` : "—"}
        </text>
      </Board>

      <Verdict tone={propre ? "warn" : "bad"}>
        {propre
          ? `Sans la masse molaire, tu ne peux pas trancher : ${base}, ${`C${indiceSub(ec * 2)}H${indiceSub(eh * 2)}${eo > 0 ? `O${indiceSub(eo * 2)}` : ""}`} et toutes les formules en k × ${base} ont exactement la même composition centésimale. C'est pour cela qu'un énoncé donne toujours M, une densité ou un volume molaire.`
          : "Ces pourcentages ne donnent pas de rapport exploitable. Vérifie que %C + %H ne dépasse pas 100."}
      </Verdict>
    </div>
  );
}
