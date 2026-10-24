import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict, fmt } from "./controls";

/** Chimie 1ère C, D et E — chapitres 16 à 19 : demi-équations, dosages, électrolyse, n.o. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* Chapitre 16 — Construire une demi-équation                          */
/* ------------------------------------------------------------------ */

type Recette = {
  value: string;
  label: string;
  etapes: ReadonlyArray<string>;
  commentaires: ReadonlyArray<string>;
  e0: number;
};

const REC_DEFAUT: Recette = {
  value: "mno4",
  label: "MnO₄⁻ / Mn²⁺",
  e0: 1.51,
  etapes: [
    "MnO₄⁻ → Mn²⁺",
    "MnO₄⁻ → Mn²⁺ + 4 H₂O",
    "MnO₄⁻ + 8 H⁺ → Mn²⁺ + 4 H₂O",
    "MnO₄⁻ + 8 H₃O⁺ → Mn²⁺ + 12 H₂O",
    "MnO₄⁻ + 8 H₃O⁺ + 5e⁻ ⇌ Mn²⁺ + 12 H₂O",
  ],
  commentaires: [
    "1. L'élément principal : un manganèse de chaque côté, c'est déjà fait.",
    "2. L'oxygène, avec des molécules d'eau : 4 O à gauche, on ajoute 4 H₂O à droite.",
    "3. L'hydrogène, avec des ions H⁺ : 8 H à droite, on ajoute 8 H⁺ à gauche.",
    "4. On passe aux ions hydronium : chaque H⁺ devient H₃O⁺, et on compense avec 8 H₂O de l'autre côté.",
    "5. Les charges, avec des électrons : +7 à gauche, +2 à droite, il faut 5 électrons à gauche.",
  ],
};

const RECETTES: ReadonlyArray<Recette> = [
  REC_DEFAUT,
  {
    value: "cr2o7",
    label: "Cr₂O₇²⁻ / Cr³⁺",
    e0: 1.33,
    etapes: [
      "Cr₂O₇²⁻ → 2 Cr³⁺",
      "Cr₂O₇²⁻ → 2 Cr³⁺ + 7 H₂O",
      "Cr₂O₇²⁻ + 14 H⁺ → 2 Cr³⁺ + 7 H₂O",
      "Cr₂O₇²⁻ + 14 H₃O⁺ → 2 Cr³⁺ + 21 H₂O",
      "Cr₂O₇²⁻ + 14 H₃O⁺ + 6e⁻ ⇌ 2 Cr³⁺ + 21 H₂O",
    ],
    commentaires: [
      "1. Deux chromes à gauche, il en faut deux à droite.",
      "2. Sept oxygènes à gauche : on ajoute 7 H₂O à droite.",
      "3. Quatorze hydrogènes à droite : on ajoute 14 H⁺ à gauche.",
      "4. Les 14 H⁺ deviennent 14 H₃O⁺, et on ajoute 14 H₂O à droite.",
      "5. À gauche −2 + 14 = +12, à droite +6 : il faut 6 électrons.",
    ],
  },
  {
    value: "no3",
    label: "NO₃⁻ / NO",
    e0: 0.96,
    etapes: [
      "NO₃⁻ → NO",
      "NO₃⁻ → NO + 2 H₂O",
      "NO₃⁻ + 4 H⁺ → NO + 2 H₂O",
      "NO₃⁻ + 4 H₃O⁺ → NO + 6 H₂O",
      "NO₃⁻ + 4 H₃O⁺ + 3e⁻ ⇌ NO + 6 H₂O",
    ],
    commentaires: [
      "1. Un azote de chaque côté.",
      "2. Trois oxygènes à gauche, un à droite : on ajoute 2 H₂O à droite.",
      "3. Quatre hydrogènes à droite : on ajoute 4 H⁺ à gauche.",
      "4. Les 4 H⁺ deviennent 4 H₃O⁺, et on ajoute 4 H₂O à droite.",
      "5. À gauche −1 + 4 = +3, à droite 0 : il faut 3 électrons.",
    ],
  },
  {
    value: "so4",
    label: "SO₄²⁻ / SO₂",
    e0: 0.17,
    etapes: [
      "SO₄²⁻ → SO₂",
      "SO₄²⁻ → SO₂ + 2 H₂O",
      "SO₄²⁻ + 4 H⁺ → SO₂ + 2 H₂O",
      "SO₄²⁻ + 4 H₃O⁺ → SO₂ + 6 H₂O",
      "SO₄²⁻ + 4 H₃O⁺ + 2e⁻ ⇌ SO₂ + 6 H₂O",
    ],
    commentaires: [
      "1. Un soufre de chaque côté.",
      "2. Quatre oxygènes à gauche, deux à droite : on ajoute 2 H₂O à droite.",
      "3. Quatre hydrogènes à droite : on ajoute 4 H⁺ à gauche.",
      "4. Les 4 H⁺ deviennent 4 H₃O⁺, et on ajoute 4 H₂O à droite.",
      "5. À gauche −2 + 4 = +2, à droite 0 : il faut 2 électrons.",
    ],
  },
];

export function DemiEquation() {
  const [choix, setChoix] = useState("mno4");
  const [etape, setEtape] = useState(1);
  const r = RECETTES.find((x) => x.value === choix) ?? REC_DEFAUT;
  const e = clamp(etape, 1, 5);

  const W = 440;
  const H = 180;

  return (
    <div className="space-y-3">
      <Choice
        label="Couple à équilibrer"
        value={choix}
        options={RECETTES.map((o) => ({ value: o.value, label: o.label }))}
        onChange={(v) => {
          setChoix(v);
          setEtape(1);
        }}
      />
      <Ctrl
        label="Étape de la méthode"
        value={e}
        min={1}
        max={5}
        step={1}
        onChange={setEtape}
        display={`étape ${e} sur 5`}
        color={PALETTE.purple}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text
          x={W / 2}
          y={56}
          textAnchor="middle"
          fontSize={15}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {r.etapes[e - 1] ?? ""}
        </text>

        <foreignObject x={24} y={80} width={392} height={64}>
          <div
            style={{
              fontSize: 12,
              lineHeight: 1.45,
              color: "#334155",
              fontFamily: "system-ui, sans-serif",
            }}
          >
            {r.commentaires[e - 1] ?? ""}
          </div>
        </foreignObject>

        {Array.from({ length: 5 }).map((_, i) => (
          <circle
            key={i}
            cx={176 + i * 22}
            cy={160}
            r={7}
            fill={i < e ? PALETTE.purple : "#e2e8f0"}
          />
        ))}
      </Board>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Potentiel du couple" value={`${fmt(r.e0, 2)} V`} color={PALETTE.orange} />
        <Stat label="Étape" value={`${e} / 5`} color={PALETTE.purple} />
      </div>

      <Verdict tone={e === 5 ? "ok" : "warn"}>
        {e === 5
          ? "Vérifie toujours une dernière fois : les atomes de chaque élément, puis les charges. Une demi-équation fausse ruine tout l'exercice qui suit."
          : "Applique les cinq étapes TOUJOURS dans cet ordre : l'élément principal, l'oxygène avec H₂O, l'hydrogène avec H⁺, le passage aux ions hydronium, puis les charges avec les électrons."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 16 — L'échelle des potentiels, couples non métalliques     */
/* ------------------------------------------------------------------ */

type CoupleRedox = {
  value: string;
  label: string;
  demi: string;
  e0: number;
  couleurOx: string;
  couleurRed: string;
};

export const COUPLES_REDOX: ReadonlyArray<CoupleRedox> = [
  {
    value: "s2o8",
    label: "S₂O₈²⁻ / SO₄²⁻",
    demi: "S₂O₈²⁻ + 2e⁻ ⇌ 2 SO₄²⁻",
    e0: 2.01,
    couleurOx: "incolore",
    couleurRed: "incolore",
  },
  {
    value: "h2o2",
    label: "H₂O₂ / H₂O",
    demi: "H₂O₂ + 2 H₃O⁺ + 2e⁻ ⇌ 4 H₂O",
    e0: 1.77,
    couleurOx: "incolore",
    couleurRed: "incolore",
  },
  {
    value: "mno4",
    label: "MnO₄⁻ / Mn²⁺",
    demi: "MnO₄⁻ + 8 H₃O⁺ + 5e⁻ ⇌ Mn²⁺ + 12 H₂O",
    e0: 1.51,
    couleurOx: "VIOLET",
    couleurRed: "rose très pâle",
  },
  {
    value: "cl2",
    label: "Cl₂ / Cl⁻",
    demi: "Cl₂ + 2e⁻ ⇌ 2 Cl⁻",
    e0: 1.36,
    couleurOx: "jaune-vert",
    couleurRed: "incolore",
  },
  {
    value: "cr2o7",
    label: "Cr₂O₇²⁻ / Cr³⁺",
    demi: "Cr₂O₇²⁻ + 14 H₃O⁺ + 6e⁻ ⇌ 2 Cr³⁺ + 21 H₂O",
    e0: 1.33,
    couleurOx: "ORANGE",
    couleurRed: "vert",
  },
  {
    value: "o2",
    label: "O₂ / H₂O",
    demi: "O₂ + 4 H₃O⁺ + 4e⁻ ⇌ 6 H₂O",
    e0: 1.23,
    couleurOx: "incolore",
    couleurRed: "incolore",
  },
  {
    value: "br2",
    label: "Br₂ / Br⁻",
    demi: "Br₂ + 2e⁻ ⇌ 2 Br⁻",
    e0: 1.07,
    couleurOx: "orangé",
    couleurRed: "incolore",
  },
  {
    value: "no3",
    label: "NO₃⁻ / NO",
    demi: "NO₃⁻ + 4 H₃O⁺ + 3e⁻ ⇌ NO + 6 H₂O",
    e0: 0.96,
    couleurOx: "incolore",
    couleurRed: "incolore",
  },
  {
    value: "fe3",
    label: "Fe³⁺ / Fe²⁺",
    demi: "Fe³⁺ + e⁻ ⇌ Fe²⁺",
    e0: 0.77,
    couleurOx: "rouille",
    couleurRed: "vert très pâle",
  },
  {
    value: "i2",
    label: "I₂ / I⁻",
    demi: "I₂ + 2e⁻ ⇌ 2 I⁻",
    e0: 0.54,
    couleurOx: "BRUN",
    couleurRed: "incolore",
  },
  {
    value: "cu",
    label: "Cu²⁺ / Cu",
    demi: "Cu²⁺ + 2e⁻ ⇌ Cu",
    e0: 0.34,
    couleurOx: "bleu",
    couleurRed: "rouge métallique",
  },
  {
    value: "so4",
    label: "SO₄²⁻ / SO₂",
    demi: "SO₄²⁻ + 4 H₃O⁺ + 2e⁻ ⇌ SO₂ + 6 H₂O",
    e0: 0.17,
    couleurOx: "incolore",
    couleurRed: "incolore",
  },
  {
    value: "s4o6",
    label: "S₄O₆²⁻ / S₂O₃²⁻",
    demi: "S₄O₆²⁻ + 2e⁻ ⇌ 2 S₂O₃²⁻",
    e0: 0.08,
    couleurOx: "incolore",
    couleurRed: "incolore",
  },
  {
    value: "h3o",
    label: "H₃O⁺ / H₂",
    demi: "2 H₃O⁺ + 2e⁻ ⇌ H₂ + 2 H₂O",
    e0: 0,
    couleurOx: "incolore",
    couleurRed: "incolore",
  },
];

const CR_DEFAUT: CoupleRedox = COUPLES_REDOX[2] ?? {
  value: "mno4",
  label: "MnO₄⁻ / Mn²⁺",
  demi: "MnO₄⁻ + 8 H₃O⁺ + 5e⁻ ⇌ Mn²⁺ + 12 H₂O",
  e0: 1.51,
  couleurOx: "VIOLET",
  couleurRed: "rose très pâle",
};

function trouverRedox(v: string): CoupleRedox {
  return COUPLES_REDOX.find((c) => c.value === v) ?? CR_DEFAUT;
}

export function CouplesNonMetalliques() {
  const [sel, setSel] = useState("mno4");
  const c = trouverRedox(sel);

  const W = 440;
  const H = 330;
  // espacement régulier : sur une échelle linéaire, Cl₂ et Cr₂O₇²⁻ se superposeraient
  const rang = new Map(COUPLES_REDOX.map((k, i) => [k.value, i]));
  const y = (v: string) => 40 + (rang.get(v) ?? 0) * 20;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line x1={18} y1={30} x2={18} y2={312} stroke={PALETTE.gridStrong} strokeWidth={1.4} />
        <polygon points="18,24 13,36 23,36" fill={PALETTE.gridStrong} />
        <text
          x={12}
          y={176}
          fontSize={9}
          fontWeight={700}
          fill={PALETTE.slate}
          transform="rotate(-90 12 176)"
          textAnchor="middle"
        >
          pouvoir oxydant croissant
        </text>

        {COUPLES_REDOX.map((k) => {
          const actif = k.value === sel;
          return (
            <g key={k.value}>
              {actif ? (
                <rect x={26} y={y(k.value) - 11} width={212} height={19} rx={5} fill="#fff7ed" />
              ) : null}
              <line
                x1={30}
                y1={y(k.value)}
                x2={46}
                y2={y(k.value)}
                stroke={actif ? PALETTE.orange : PALETTE.gridStrong}
                strokeWidth={actif ? 2.4 : 1.2}
              />
              <text
                x={54}
                y={y(k.value) + 4}
                fontSize={11}
                fontWeight={actif ? 700 : 400}
                fill={actif ? PALETTE.orange : PALETTE.slate}
              >
                {k.label}
              </text>
              <text x={182} y={y(k.value) + 4} fontSize={10} fill={PALETTE.slate}>
                {fmt(k.e0, 2)} V
              </text>
            </g>
          );
        })}

        <rect
          x={244}
          y={40}
          width={182}
          height={132}
          rx={10}
          fill="#f8fafc"
          stroke={PALETTE.orange}
          strokeWidth={1.6}
        />
        <text
          x={335}
          y={62}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.orange}
        >
          {c.label}
        </text>
        <foreignObject x={252} y={72} width={166} height={46}>
          <div
            style={{
              fontSize: 11,
              color: "#0f172a",
              fontFamily: "system-ui, sans-serif",
              lineHeight: 1.35,
            }}
          >
            {c.demi}
          </div>
        </foreignObject>
        <text x={252} y={136} fontSize={10} fill={PALETTE.slate}>
          oxydant : {c.couleurOx}
        </text>
        <text x={252} y={154} fontSize={10} fill={PALETTE.slate}>
          réducteur : {c.couleurRed}
        </text>

        <foreignObject x={244} y={186} width={182} height={120}>
          <div
            style={{
              fontSize: 11,
              color: "#334155",
              fontFamily: "system-ui, sans-serif",
              lineHeight: 1.45,
            }}
          >
            Dans le couple O₂/H₂O l&apos;eau est le RÉDUCTEUR ; dans le couple H₃O⁺/H₂ elle est du
            côté oxydant. L&apos;eau est donc à la fois oxydante et réductrice : on dit qu&apos;elle
            est amphotère, ou ampholyte.
          </div>
        </foreignObject>
      </Board>

      <Choice
        label="Clique sur un couple"
        value={sel}
        options={COUPLES_REDOX.map((k) => ({ value: k.value, label: k.label }))}
        onChange={setSel}
      />

      <Verdict tone="ok">
        Les couleurs ne sont pas un détail : c&apos;est parce que MnO₄⁻ est violet et Mn²⁺
        pratiquement incolore qu&apos;un dosage au permanganate n&apos;a besoin d&apos;aucun
        indicateur. L&apos;oxydant est son propre témoin.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 16 — La réaction sera-t-elle totale ?                      */
/* ------------------------------------------------------------------ */

export function ReactionTotale() {
  const [a, setA] = useState("mno4");
  const [b, setB] = useState("fe3");

  const ca = trouverRedox(a);
  const cb = trouverRedox(b);
  const fort = ca.e0 >= cb.e0 ? ca : cb;
  const faible = ca.e0 >= cb.e0 ? cb : ca;
  const delta = Math.abs(ca.e0 - cb.e0);
  const possible = ca.value !== cb.value;
  const totale = possible && delta > 0.34;
  const reste = possible ? clamp(1 - delta / 0.34, 0, 1) * 100 : 100;

  const W = 440;
  const H = 200;

  return (
    <div className="space-y-3">
      <Panel>
        <Choice
          label="Premier couple"
          value={a}
          options={COUPLES_REDOX.map((k) => ({ value: k.value, label: k.label }))}
          onChange={setA}
        />
        <Choice
          label="Second couple"
          value={b}
          options={COUPLES_REDOX.map((k) => ({ value: k.value, label: k.label }))}
          onChange={setB}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <text x={20} y={28} fontSize={11} fill={PALETTE.slate}>
          différence de potentiel ΔE
        </text>
        <rect x={20} y={36} width={300} height={16} rx={8} fill="#e2e8f0" />
        <rect
          x={20}
          y={36}
          width={clamp((delta / 2) * 300, 0, 300)}
          height={16}
          rx={8}
          fill={totale ? PALETTE.green : PALETTE.orange}
        />
        <line
          x1={20 + (0.34 / 2) * 300}
          y1={30}
          x2={20 + (0.34 / 2) * 300}
          y2={58}
          stroke={PALETTE.red}
          strokeWidth={2}
        />
        <text
          x={20 + (0.34 / 2) * 300}
          y={72}
          textAnchor="middle"
          fontSize={9}
          fontWeight={700}
          fill={PALETTE.red}
        >
          0,34 V
        </text>
        <text
          x={412}
          y={50}
          textAnchor="end"
          fontSize={15}
          fontWeight={700}
          fill={totale ? PALETTE.green : PALETTE.orange}
        >
          {fmt(delta, 2)} V
        </text>

        <path
          d="M150 92 L290 92 L278 182 L162 182 Z"
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <path d="M156 130 L284 130 L278 182 L162 182 Z" fill="#e0f2fe" opacity={0.7} />
        {Array.from({ length: Math.round(reste / 10) }).map((_, i) => (
          <circle
            key={i}
            cx={174 + ((i * 23) % 92)}
            cy={144 + ((i * 17) % 32)}
            r={4}
            fill={PALETTE.red}
            opacity={0.75}
          />
        ))}
        <text
          x={220}
          y={196}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={reste < 8 ? PALETTE.green : PALETTE.red}
        >
          {reste < 8 ? "tout le réactif a disparu" : `il reste du réactif : ${fmt(reste, 0)} %`}
        </text>

        <foreignObject x={300} y={92} width={126} height={96}>
          <div
            style={{
              fontSize: 11,
              color: "#334155",
              fontFamily: "system-ui, sans-serif",
              lineHeight: 1.4,
            }}
          >
            {possible
              ? `${fort.label.split(" / ")[0]} réagit avec ${faible.label.split(" / ")[1]}`
              : "choisis deux couples différents"}
          </div>
        </foreignObject>
      </Board>

      <Verdict tone={totale ? "ok" : possible ? "bad" : "warn"}>
        {!possible
          ? "Les deux couples sont identiques : il n'y a pas de réaction à prévoir."
          : totale
            ? `ΔE = ${fmt(delta, 2)} V, supérieur à 0,34 V : la réaction est TOTALE. Le réactif limitant disparaît complètement, et le point d'équivalence d'un dosage sera net.`
            : `ΔE = ${fmt(delta, 2)} V, inférieur à 0,34 V : la réaction se produit, mais elle n'est pas totale. Il reste toujours un peu de réactif, le changement de teinte est flou, et le dosage n'est pas fiable.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 17 — Qu'est-ce que l'équivalence ?                         */
/* ------------------------------------------------------------------ */

export function PointEquivalence() {
  const [verse, setVerse] = useState(6);
  const c0 = 0.02; // dosante
  const v0 = 20; // à doser, mL
  const cr = 0.05; // à doser
  const veq = (cr * v0) / (5 * c0); // 5 Fe2+ pour 1 MnO4-

  const nDose = Math.max(0, cr * v0 - 5 * c0 * verse);
  const nDosant = Math.max(0, 5 * c0 * verse - cr * v0) / 5;
  const atteint = Math.abs(verse - veq) < 0.4;

  const W = 440;
  const H = 210;
  const hb = (v: number) => clamp((v / (cr * v0)) * 110, 0, 110);

  return (
    <div className="space-y-3">
      <Ctrl
        label="Volume de solution dosante versé"
        value={verse}
        min={0}
        max={20}
        step={0.2}
        onChange={setVerse}
        display={`${fmt(verse, 1)} mL`}
        color={PALETTE.purple}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <text
          x={110}
          y={28}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.green}
        >
          réactif à doser
        </text>
        <rect x={60} y={40} width={100} height={114} fill="#f1f5f9" rx={4} />
        <rect x={60} y={154 - hb(nDose)} width={100} height={hb(nDose)} fill="#86efac" rx={4} />
        <text x={110} y={172} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {fmt(nDose, 3)} mmol
        </text>

        <text
          x={330}
          y={28}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.purple}
        >
          réactif dosant en excès
        </text>
        <rect x={280} y={40} width={100} height={114} fill="#f1f5f9" rx={4} />
        <rect
          x={280}
          y={154 - hb(nDosant * 5)}
          width={100}
          height={hb(nDosant * 5)}
          fill="#c084fc"
          rx={4}
        />
        <text x={330} y={172} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {fmt(nDosant, 3)} mmol
        </text>

        <line
          x1={220}
          y1={36}
          x2={220}
          y2={158}
          stroke={PALETTE.gridStrong}
          strokeWidth={1.4}
          strokeDasharray="4 4"
        />

        <text
          x={W / 2}
          y={196}
          textAnchor="middle"
          fontSize={14}
          fontWeight={700}
          fill={atteint ? PALETTE.red : PALETTE.slate}
        >
          {atteint
            ? "ÉQUIVALENCE — les deux colonnes sont à zéro"
            : verse < veq
              ? "avant l'équivalence : il reste du réactif à doser"
              : "après l'équivalence : le réactif dosant s'accumule"}
        </text>
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Volume versé" value={`${fmt(verse, 1)} mL`} color={PALETTE.purple} />
        <Stat label="Volume à l'équivalence" value={`${fmt(veq, 1)} mL`} color={PALETTE.red} />
        <Stat label="Écart" value={`${fmt(verse - veq, 1)} mL`} color={PALETTE.slate} />
      </div>

      <Verdict tone={atteint ? "ok" : "warn"}>
        {atteint
          ? "C'est le seul instant où les réactifs sont dans les proportions stœchiométriques. Ni l'un ni l'autre n'est en excès : c'est le point d'équivalence, et c'est lui qu'on repère au changement de teinte."
          : verse < veq
            ? "Chaque goutte versée est immédiatement consommée par le réactif à doser, qui est encore présent. C'est pourquoi la couleur disparaît aussitôt."
            : "Le réactif à doser a disparu : plus rien ne consomme ce qu'on verse, et le réactif dosant s'accumule. C'est le moment où la couleur persiste — mais tu as déjà dépassé l'équivalence."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 17 — Monter un dosage                                      */
/* ------------------------------------------------------------------ */

export function MaterielDosage() {
  const [burette, setBurette] = useState<"dosante" | "dosee">("dosante");
  const [prelevement, setPrelevement] = useState<"pipette" | "becher" | "eprouvette">("pipette");
  const [agitation, setAgitation] = useState(true);

  const okBurette = burette === "dosante";
  const okPrel = prelevement === "pipette";
  const tout = okBurette && okPrel && agitation;

  const W = 440;
  const H = 190;

  return (
    <div className="space-y-3">
      <Choice
        label="Que mets-tu dans la burette ?"
        value={burette}
        options={[
          { value: "dosante" as const, label: "La solution dosante" },
          { value: "dosee" as const, label: "La solution à doser" },
        ]}
        onChange={setBurette}
      />
      <Choice
        label="Avec quoi prélèves-tu le volume à doser ?"
        value={prelevement}
        options={[
          { value: "pipette" as const, label: "Pipette jaugée" },
          { value: "becher" as const, label: "Bécher gradué" },
          { value: "eprouvette" as const, label: "Éprouvette" },
        ]}
        onChange={setPrelevement}
      />
      <Choice
        label="Agitateur magnétique"
        value={agitation ? "oui" : "non"}
        options={[
          { value: "oui", label: "En marche" },
          { value: "non", label: "Arrêté" },
        ]}
        onChange={(v) => setAgitation(v === "oui")}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill={tout ? "#f0fdf4" : "#ffffff"} />

        <rect x={126} y={20} width={10} height={140} fill="#94a3b8" />
        <rect
          x={190}
          y={24}
          width={26}
          height={76}
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={1.8}
        />
        <rect
          x={192}
          y={34}
          width={22}
          height={62}
          fill={okBurette ? "#c084fc" : "#86efac"}
          opacity={0.75}
        />
        <polygon
          points="190,100 216,100 208,116 198,116"
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={1.6}
        />
        <path
          d="M172 126 L238 126 L230 166 L180 166 Z"
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={1.8}
        />
        <path
          d="M176 146 L234 146 L230 166 L180 166 Z"
          fill={okBurette ? "#86efac" : "#c084fc"}
          opacity={0.7}
        />
        {agitation ? <rect x={196} y={160} width={18} height={6} rx={3} fill="#475569" /> : null}
        <rect
          x={166}
          y={168}
          width={78}
          height={12}
          rx={4}
          fill={agitation ? "#cbd5e1" : "#e2e8f0"}
        />

        <g fontSize={11}>
          <text x={268} y={46} fill={okBurette ? PALETTE.green : PALETTE.red} fontWeight={700}>
            {okBurette ? "✓ burette correcte" : "✗ burette inversée"}
          </text>
          <text x={268} y={76} fill={okPrel ? PALETTE.green : PALETTE.red} fontWeight={700}>
            {okPrel ? "✓ pipette jaugée" : "✗ volume imprécis"}
          </text>
          <text x={268} y={106} fill={agitation ? PALETTE.green : PALETTE.red} fontWeight={700}>
            {agitation ? "✓ mélange homogène" : "✗ pas d'agitation"}
          </text>
          <text x={268} y={146} fill={PALETTE.slate}>
            {tout ? "le montage est prêt" : "corrige les points en rouge"}
          </text>
        </g>
      </Board>

      <Verdict tone={okBurette ? "ok" : "bad"}>
        {okBurette
          ? "La burette contient la solution dosante : c'est elle dont on contrôle l'ajout goutte à goutte, et dont on lit le volume à l'équivalence."
          : "La burette doit contenir la solution DOSANTE, celle dont on connaît la concentration. La solution à doser est prélevée une fois pour toutes, à la pipette."}
      </Verdict>
      <Verdict tone={okPrel ? "ok" : "bad"}>
        {okPrel
          ? "La pipette jaugée donne un volume précis — bien plus précis qu'un bécher gradué ou une éprouvette."
          : "Un bécher gradué ou une éprouvette ne donnent qu'un volume approximatif. Tout le calcul final repose sur ce volume : il faut une pipette jaugée, munie d'une poire, jamais pipetée à la bouche."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 17 — L'iodométrie et l'empois d'amidon                     */
/* ------------------------------------------------------------------ */

export function Iodometrie() {
  const [verse, setVerse] = useState(0);
  const [amidon, setAmidon] = useState(false);

  const c0 = 0.04; // diiode, mol/L
  const v0 = 20; // mL
  const cr = 0.1; // thiosulfate
  const veq = (2 * c0 * v0) / cr;

  const restant = clamp(1 - verse / veq, 0, 1);
  const visible = amidon ? restant > 0.02 : restant > 0.22;

  const W = 440;
  const H = 190;

  return (
    <div className="space-y-3">
      <Choice
        label="Indicateur coloré"
        value={amidon ? "oui" : "non"}
        options={[
          { value: "non", label: "Sans empois d'amidon" },
          { value: "oui", label: "Avec quelques gouttes d'empois" },
        ]}
        onChange={(v) => setAmidon(v === "oui")}
      />
      <Ctrl
        label="Volume de thiosulfate versé"
        value={verse}
        min={0}
        max={24}
        step={0.2}
        onChange={setVerse}
        display={`${fmt(verse, 1)} mL`}
        color={PALETTE.purple}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={W / 2} y={24} textAnchor="middle" fontSize={12} fill={PALETTE.ink}>
          I₂ + 2 S₂O₃²⁻ → 2 I⁻ + S₄O₆²⁻
        </text>

        <path
          d="M170 46 L270 46 L260 160 L180 160 Z"
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <path
          d="M176 96 L264 96 L260 160 L180 160 Z"
          fill={visible ? (amidon ? "#1e3a8a" : "#92400e") : "#f1f5f9"}
          opacity={visible ? clamp(0.25 + restant, 0.3, 1) : 0.4}
        />

        <text
          x={220}
          y={178}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={visible ? (amidon ? "#1e3a8a" : "#92400e") : PALETTE.slate}
        >
          {visible ? (amidon ? "BLEU FONCÉ" : "brun, de plus en plus pâle") : "incolore"}
        </text>

        <g fontSize={11}>
          <text x={300} y={62} fill={PALETTE.slate}>
            diiode restant
          </text>
          <text x={416} y={62} textAnchor="end" fontWeight={700} fill={PALETTE.ink}>
            {fmt(restant * 100, 0)} %
          </text>
          <text x={300} y={90} fill={PALETTE.slate}>
            équivalence à
          </text>
          <text x={416} y={90} textAnchor="end" fontWeight={700} fill={PALETTE.red}>
            {fmt(veq, 1)} mL
          </text>
          <text x={300} y={118} fill={PALETTE.slate}>
            tu lirais
          </text>
          <text
            x={416}
            y={118}
            textAnchor="end"
            fontWeight={700}
            fill={amidon ? PALETTE.green : PALETTE.orange}
          >
            {amidon ? `${fmt(veq, 1)} mL` : `${fmt(veq * 0.78, 1)} mL`}
          </text>
          <text x={300} y={146} fill={PALETTE.slate}>
            erreur
          </text>
          <text
            x={416}
            y={146}
            textAnchor="end"
            fontWeight={700}
            fill={amidon ? PALETTE.green : PALETTE.red}
          >
            {amidon ? "négligeable" : `${fmt(22, 0)} %`}
          </text>
        </g>
      </Board>

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Relation à l'équivalence" value="C₀V₀ = ½ Cr Vr" color={PALETTE.purple} />
        <Stat
          label="Concentration trouvée"
          value={`${fmt(((amidon ? veq : veq * 0.78) * cr) / (2 * v0), 3)} mol/L`}
          color={amidon ? PALETTE.green : PALETTE.orange}
        />
      </div>

      <Verdict tone={amidon ? "ok" : "bad"}>
        {amidon
          ? "L'amidon donne au diiode une teinte bleu foncé très visible, qui disparaît d'un coup à l'équivalence. C'est ce qui rend ce dosage précis."
          : "Sans empois d'amidon, le virage du brun à l'incolore est à peine perceptible : la solution est déjà très pâle bien avant l'équivalence, et tu t'arrêtes trop tôt. Ajoute l'indicateur et recommence."}
      </Verdict>

      <Verdict tone="warn">
        C&apos;est la différence avec le dosage manganimétrique : le permanganate, violet, se
        suffisait à lui-même. Le diiode, non.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 18 — Forcer une réaction                                   */
/* ------------------------------------------------------------------ */

type Electrolyte = {
  value: string;
  label: string;
  seuil: number;
  anode: string;
  cathode: string;
  bilan: string;
  note: string;
};

const ELEC_DEFAUT: Electrolyte = {
  value: "h2so4",
  label: "Acide sulfurique",
  seuil: 1.7,
  anode: "3 H₂O → ½ O₂ + 2 H₃O⁺ + 2e⁻",
  cathode: "2 H₃O⁺ + 2e⁻ → H₂ + 2 H₂O",
  bilan: "H₂O → H₂ + ½ O₂",
  note: "L'acide n'est pas consommé : son rôle est seulement de rendre la solution conductrice.",
};

const ELECTROLYTES: ReadonlyArray<Electrolyte> = [
  ELEC_DEFAUT,
  {
    value: "naoh",
    label: "Hydroxyde de sodium",
    seuil: 1.7,
    anode: "2 OH⁻ → ½ O₂ + H₂O + 2e⁻",
    cathode: "2 H₂O + 2e⁻ → H₂ + 2 OH⁻",
    bilan: "H₂O → H₂ + ½ O₂",
    note: "Même bilan qu'avec l'acide : acide ou base, l'électrolyse décompose l'eau et l'électrolyte ne sert qu'à conduire.",
  },
  {
    value: "sncl2",
    label: "Chlorure d'étain II",
    seuil: 1.2,
    anode: "2 Cl⁻ → Cl₂ + 2e⁻",
    cathode: "Sn²⁺ + 2e⁻ → Sn",
    bilan: "Sn²⁺ + 2 Cl⁻ → Sn + Cl₂",
    note: "Ici ce sont les ions du SOLUTÉ qui réagissent, et non l'eau. C'est le cas où l'électrolyse transforme vraiment l'électrolyte.",
  },
];

export function Electrolyse() {
  const [choix, setChoix] = useState("h2so4");
  const [tension, setTension] = useState(0.8);
  const [inverse, setInverse] = useState(false);
  const e = ELECTROLYTES.find((x) => x.value === choix) ?? ELEC_DEFAUT;

  const marche = tension >= e.seuil;

  const W = 440;
  const H = 210;
  const xAnode = inverse ? 300 : 140;
  const xCathode = inverse ? 140 : 300;

  return (
    <div className="space-y-3">
      <Choice
        label="Électrolyte"
        value={choix}
        options={ELECTROLYTES.map((o) => ({ value: o.value, label: o.label }))}
        onChange={setChoix}
      />
      <Ctrl
        label="Tension du générateur"
        value={tension}
        min={0}
        max={3}
        step={0.1}
        onChange={setTension}
        display={`${fmt(tension, 1)} V`}
        color={marche ? PALETTE.green : PALETTE.slate}
      />
      <Choice
        label="Branchement"
        value={inverse ? "inv" : "nor"}
        options={[
          { value: "nor", label: "Normal" },
          { value: "inv", label: "Bornes inversées" },
        ]}
        onChange={(v) => setInverse(v === "inv")}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <path
          d="M80 92 L360 92 L344 182 L96 182 Z"
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <path d="M86 118 L354 118 L344 182 L96 182 Z" fill="#bfdbfe" opacity={0.55} />

        <rect x={xAnode - 7} y={76} width={14} height={86} fill="#64748b" />
        <rect x={xCathode - 7} y={76} width={14} height={86} fill="#64748b" />
        <text
          x={xAnode}
          y={68}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.red}
        >
          ANODE (+)
        </text>
        <text
          x={xCathode}
          y={68}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.green}
        >
          CATHODE (−)
        </text>

        {marche
          ? Array.from({ length: 12 }).map((_, i) => (
              <circle
                key={i}
                cx={(i % 2 === 0 ? xAnode : xCathode) + ((i * 11) % 18) - 9}
                cy={110 + ((i * 13) % 56)}
                r={3 + (i % 2) * (i % 2 === 0 ? 1 : 2)}
                fill={i % 2 === 0 ? "#fca5a5" : "#86efac"}
              />
            ))
          : null}

        <foreignObject x={22} y={16} width={396} height={44}>
          <div
            style={{
              fontSize: 11,
              lineHeight: 1.4,
              color: marche ? "#14532d" : "#64748b",
              fontFamily: "system-ui, sans-serif",
            }}
          >
            {marche
              ? `Anode (oxydation) : ${e.anode} — Cathode (réduction) : ${e.cathode}`
              : `Rien ne se passe : il faut atteindre ${fmt(e.seuil, 1)} V pour que les réactions se déclenchent.`}
          </div>
        </foreignObject>

        <text
          x={W / 2}
          y={200}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={marche ? PALETTE.ink : PALETTE.slate}
        >
          {marche ? e.bilan : "—"}
        </text>
      </Board>

      <Verdict tone={marche ? "ok" : "warn"}>
        {marche
          ? `${e.note} Souviens-toi de la règle : il se produit TOUJOURS une oxydation à l'anode et une réduction à la cathode — anode et oxydation commencent toutes deux par une voyelle.`
          : "Les réactions ne se déclenchent qu'à partir de la f.é.m. de l'électrolyseur. En dessous, le générateur a beau être branché, rien ne bouge."}
      </Verdict>

      <Verdict tone="warn">
        Les potentiels permettent de prévoir les réactions aux électrodes, mais à cause du phénomène
        de SURTENSION ces prévisions ne sont pas toujours vérifiées par l&apos;expérience.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 18 — Électrolyser l'eau                                    */
/* ------------------------------------------------------------------ */

export function ElectrolyseEau() {
  const [duree, setDuree] = useState(6);

  const vH2 = duree * 10;
  const vO2 = vH2 / 2;

  const W = 440;
  const H = 230;
  const hMax = 130;
  const hH2 = clamp((vH2 / 120) * hMax, 0, hMax);
  const hO2 = clamp((vO2 / 120) * hMax, 0, hMax);

  return (
    <div className="space-y-3">
      <Ctrl
        label="Durée de l'électrolyse"
        value={duree}
        min={0}
        max={12}
        step={0.5}
        onChange={setDuree}
        display={`${fmt(duree, 1)} min`}
        color={PALETTE.purple}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <path
          d="M70 110 L370 110 L354 200 L86 200 Z"
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <path d="M76 134 L364 134 L354 200 L86 200 Z" fill="#bfdbfe" opacity={0.5} />
        <text x={220} y={194} textAnchor="middle" fontSize={10} fill="#1e3a8a">
          solution d&apos;acide sulfurique (elle ne fait que conduire)
        </text>

        <rect
          x={128}
          y={34}
          width={44}
          height={hMax}
          fill="none"
          stroke={PALETTE.slate}
          strokeWidth={1.8}
        />
        <rect x={130} y={34 + hMax - hO2} width={40} height={hO2} fill="#fca5a5" opacity={0.75} />
        <text x={150} y={24} textAnchor="middle" fontSize={11} fontWeight={700} fill="#b91c1c">
          O₂ — anode (+)
        </text>
        <text x={150} y={216} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {fmt(vO2, 0)} mL
        </text>

        <rect
          x={268}
          y={34}
          width={44}
          height={hMax}
          fill="none"
          stroke={PALETTE.slate}
          strokeWidth={1.8}
        />
        <rect x={270} y={34 + hMax - hH2} width={40} height={hH2} fill="#86efac" opacity={0.75} />
        <text x={290} y={24} textAnchor="middle" fontSize={11} fontWeight={700} fill="#15803d">
          H₂ — cathode (−)
        </text>
        <text x={290} y={216} textAnchor="middle" fontSize={11} fontWeight={700} fill="#15803d">
          {fmt(vH2, 0)} mL
        </text>

        <rect x={150} y={110} width={10} height={70} fill="#64748b" />
        <rect x={290} y={110} width={10} height={70} fill="#64748b" />
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Dihydrogène" value={`${fmt(vH2, 0)} mL`} color={PALETTE.green} />
        <Stat label="Dioxygène" value={`${fmt(vO2, 0)} mL`} color={PALETTE.red} />
        <Stat
          label="Rapport"
          value={vO2 > 0 ? `${fmt(vH2 / vO2, 1)} × ` : "—"}
          color={PALETTE.purple}
        />
      </div>

      <Verdict tone="ok">
        Le bilan est H₂O → H₂ + ½ O₂ : une molécule d&apos;eau donne une molécule de dihydrogène et
        une demi-molécule de dioxygène. Le volume de dihydrogène est donc TOUJOURS le double de
        celui du dioxygène, et cela se voit à l&apos;œil nu sur les deux tubes.
      </Verdict>

      <Verdict tone="warn">
        Pour identifier les gaz : à la cathode, une bûchette enflammée provoque une DÉTONATION —
        c&apos;est le dihydrogène. À l&apos;anode, une bûchette incandescente se RAVIVE — c&apos;est
        le dioxygène.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 18 — Affiner le cuivre                                     */
/* ------------------------------------------------------------------ */

export function AnodeSoluble() {
  const [transfere, setTransfere] = useState(0);
  const [impuretes, setImpuretes] = useState(8);

  const anodeInit = 120;
  const anode = Math.max(10, anodeInit - transfere);
  const cathode = 40 + transfere * (1 - impuretes / 100);
  const boue = transfere * (impuretes / 100);

  const W = 440;
  const H = 252;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Cuivre transféré"
          value={transfere}
          min={0}
          max={100}
          step={2}
          onChange={setTransfere}
          display={`${transfere} g`}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Impuretés du cuivre brut"
          value={impuretes}
          min={0}
          max={25}
          step={1}
          onChange={setImpuretes}
          display={`${impuretes} %`}
          color={PALETTE.red}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <text x={126} y={26} textAnchor="middle" fontSize={11} fontWeight={700} fill={PALETTE.red}>
          ANODE (+) cuivre brut
        </text>
        <text x={126} y={44} textAnchor="middle" fontSize={12} fontWeight={700} fill={PALETTE.ink}>
          {fmt(anode, 0)} g
        </text>
        <text
          x={310}
          y={26}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.green}
        >
          CATHODE (−) cuivre pur
        </text>
        <text x={310} y={44} textAnchor="middle" fontSize={12} fontWeight={700} fill={PALETTE.ink}>
          {fmt(cathode, 0)} g
        </text>

        <path
          d="M60 72 L380 72 L366 200 L74 200 Z"
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <path d="M66 104 L374 104 L366 200 L74 200 Z" fill="#60a5fa" opacity={0.45} />

        <rect x={126 - anode / 14} y={56} width={anode / 7} height={128} fill="#b45309" />
        <rect x={310 - cathode / 14} y={56} width={cathode / 7} height={128} fill="#ea580c" />

        {boue > 1 ? (
          <ellipse cx={126} cy={194} rx={Math.min(44, boue * 2.4)} ry={6} fill="#44403c" />
        ) : null}

        <text x={220} y={222} textAnchor="middle" fontSize={11} fontWeight={700} fill="#1e3a8a">
          la teinte bleue de la solution ne change pas
        </text>
        <text x={220} y={240} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          {boue > 1
            ? `boue anodique au fond de la cuve : ${fmt(boue, 1)} g d'impuretés`
            : "autant d'ions partent de l'anode qu'il en arrive sur la cathode"}
        </text>
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Anode" value={`${fmt(anode, 0)} g`} color={PALETTE.red} />
        <Stat label="Cathode" value={`${fmt(cathode, 0)} g`} color={PALETTE.green} />
        <Stat label="Pureté obtenue" value={`${fmt(100, 0)} %`} color={PALETTE.blue} />
      </div>

      <Verdict tone="ok">
        Anode : Cu → Cu²⁺ + 2e⁻. Cathode : Cu²⁺ + 2e⁻ → Cu. L&apos;équation-bilan s&apos;écrit Cu →
        Cu, et elle ne dit rien — c&apos;est tout le point. Cette électrolyse se résume à un
        TRANSPORT du cuivre de l&apos;anode vers la cathode.
      </Verdict>

      <Verdict tone="warn">
        {impuretes > 0
          ? "Les impuretés ne passent pas en solution : elles tombent au fond de la cuve en boue anodique. Le cuivre qui arrive sur la cathode est donc plus pur que celui qui est parti. C'est le principe de l'affinage industriel."
          : "Avec du cuivre déjà pur, l'opération n'a plus d'intérêt pour l'affinage — mais elle sert alors au revêtement : chromage, nickelage, dorure des bijoux."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 18 — Faire rouiller, ou protéger                           */
/* ------------------------------------------------------------------ */

export function Corrosion() {
  const [eau, setEau] = useState(true);
  const [air, setAir] = useState(true);
  const [sel, setSel] = useState(false);
  const [protection, setProtection] = useState<"aucune" | "peinture" | "zinc" | "cuivre">("aucune");
  const [temps, setTemps] = useState(6);

  const possible = eau && air;
  const facteurSel = sel ? 2.2 : 1;
  const facteurProt =
    protection === "peinture"
      ? 0.15
      : protection === "zinc"
        ? 0
        : protection === "cuivre"
          ? 1.8
          : 1;
  const rouille = possible ? clamp((temps / 12) * facteurSel * facteurProt, 0, 1) : 0;

  const W = 440;
  const H = 200;

  return (
    <div className="space-y-3">
      <div className="grid gap-2 sm:grid-cols-3">
        <Choice
          label="Eau"
          value={eau ? "oui" : "non"}
          options={[
            { value: "oui", label: "Présente" },
            { value: "non", label: "Absente" },
          ]}
          onChange={(v) => setEau(v === "oui")}
        />
        <Choice
          label="Dioxygène de l'air"
          value={air ? "oui" : "non"}
          options={[
            { value: "oui", label: "Présent" },
            { value: "non", label: "Absent" },
          ]}
          onChange={(v) => setAir(v === "oui")}
        />
        <Choice
          label="Chlorure de sodium"
          value={sel ? "oui" : "non"}
          options={[
            { value: "non", label: "Eau douce" },
            { value: "oui", label: "Eau salée" },
          ]}
          onChange={(v) => setSel(v === "oui")}
        />
      </div>
      <Choice
        label="Protection posée sur la pièce"
        value={protection}
        options={[
          { value: "aucune" as const, label: "Aucune" },
          { value: "peinture" as const, label: "Peinture" },
          { value: "zinc" as const, label: "Bloc de zinc" },
          { value: "cuivre" as const, label: "Plaque de cuivre" },
        ]}
        onChange={setProtection}
      />
      <Ctrl
        label="Temps écoulé"
        value={temps}
        min={0}
        max={12}
        step={1}
        onChange={setTemps}
        display={`${temps} mois`}
        color={PALETTE.purple}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill={sel ? "#f0f9ff" : "#ffffff"} />

        <rect x={120} y={76} width={200} height={54} fill="#94a3b8" />
        <rect x={120} y={76} width={200 * rouille} height={54} fill="#c2410c" />
        <text x={220} y={108} textAnchor="middle" fontSize={12} fontWeight={700} fill="#ffffff">
          pièce de fer
        </text>

        {protection === "zinc" ? (
          <g>
            <rect x={120} y={132} width={52} height={20} fill={temps > 4 ? "#a8a29e" : "#cbd5e1"} />
            <text
              x={146}
              y={168}
              textAnchor="middle"
              fontSize={10}
              fontWeight={700}
              fill={PALETTE.slate}
            >
              zinc rongé
            </text>
          </g>
        ) : null}
        {protection === "cuivre" ? (
          <rect x={120} y={132} width={52} height={20} fill="#ea580c" />
        ) : null}
        {protection === "peinture" ? (
          <rect x={118} y={72} width={204} height={6} fill={PALETTE.blue} />
        ) : null}

        <text
          x={220}
          y={56}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={rouille > 0.5 ? PALETTE.red : rouille > 0 ? PALETTE.orange : PALETTE.green}
        >
          {rouille > 0.5
            ? "pièce fortement corrodée"
            : rouille > 0
              ? "la rouille apparaît"
              : "pas de rouille"}
        </text>

        <g fontSize={10} fill={PALETTE.slate}>
          <text x={22} y={180}>
            1. Fe → Fe²⁺ + 2e⁻
          </text>
          <text x={160} y={180}>
            2. Fe²⁺ → Fe³⁺ + e⁻
          </text>
          <text x={300} y={180}>
            3. Fe³⁺ + 3 OH⁻ → Fe(OH)₃
          </text>
        </g>
      </Board>

      <Verdict tone={possible ? (rouille > 0.3 ? "bad" : "ok") : "ok"}>
        {!possible
          ? `Sans ${!eau ? "eau" : "dioxygène"}, pas de corrosion. La rouille exige l'action SIMULTANÉE de l'eau et du dioxygène de l'air : les ions OH⁻ viennent du dioxygène réduit, ½ O₂ + H₂O + 2e⁻ → 2 OH⁻.`
          : protection === "zinc"
            ? "Protection à anode sacrifiée : le zinc, plus réducteur que le fer, joue le rôle d'anode et subit l'oxydation en permanence. La pièce de fer joue le rôle de cathode et reste intacte. C'est la méthode des coques de navires."
            : protection === "cuivre"
              ? "ERREUR : le cuivre est MOINS réducteur que le fer. C'est donc le fer qui se sacrifie pour protéger le cuivre, et la corrosion s'en trouve accélérée. Il faut un métal plus réducteur : zinc ou aluminium."
              : protection === "peinture"
                ? "La peinture isole le métal de l'eau et de l'air. C'est simple et économique, mais la moindre rayure ouvre une brèche."
                : "Sans protection, le fer s'oxyde en profondeur. La rouille est le composé Fe(OH)₃, qui se transforme ensuite en oxyde de fer III."}
      </Verdict>

      {sel ? (
        <Verdict tone="warn">
          Le chlorure de sodium accélère la corrosion. C&apos;est ce qui explique que les régions
          humides et les côtes littorales — Douala, Limbé, Kribi — soient si propices à la rouille.
        </Verdict>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 19 — Qui attire les électrons ?                            */
/* ------------------------------------------------------------------ */

const ELEMENTS = [
  { value: "f", label: "F", en: 4.0 },
  { value: "o", label: "O", en: 3.5 },
  { value: "n", label: "N", en: 3.0 },
  { value: "cl", label: "Cl", en: 3.0 },
  { value: "c", label: "C", en: 2.5 },
  { value: "s", label: "S", en: 2.5 },
  { value: "h", label: "H", en: 2.1 },
  { value: "al", label: "Al", en: 1.5 },
  { value: "mg", label: "Mg", en: 1.2 },
  { value: "na", label: "Na", en: 0.9 },
  { value: "cs", label: "Cs", en: 0.8 },
] as const;

const EL_DEFAUT = ELEMENTS[6];

function trouverElement(v: string) {
  return ELEMENTS.find((e) => e.value === v) ?? EL_DEFAUT;
}

export function Electronegativite() {
  const [g, setG] = useState("h");
  const [d, setD] = useState("cl");

  const a = trouverElement(g);
  const b = trouverElement(d);
  const ecart = b.en - a.en;
  const decal = clamp(ecart / 3.2, -0.45, 0.45);
  const polarisee = Math.abs(ecart) > 0.35;

  const W = 440;
  const H = 190;
  const xg = 140;
  const xd = 300;
  const xDoublet = (xg + xd) / 2 + decal * (xd - xg);

  return (
    <div className="space-y-3">
      <Panel>
        <Choice
          label="Atome de gauche"
          value={g}
          options={ELEMENTS.map((e) => ({ value: e.value, label: e.label }))}
          onChange={setG}
        />
        <Choice
          label="Atome de droite"
          value={d}
          options={ELEMENTS.map((e) => ({ value: e.value, label: e.label }))}
          onChange={setD}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <line x1={xg} y1={96} x2={xd} y2={96} stroke={PALETTE.gridStrong} strokeWidth={2} />
        <circle
          cx={xg}
          cy={96}
          r={26}
          fill={Math.abs(ecart) > 0.35 && ecart > 0 ? "#fecaca" : "#dbeafe"}
          stroke={PALETTE.slate}
          strokeWidth={1.6}
        />
        <text x={xg} y={102} textAnchor="middle" fontSize={16} fontWeight={700} fill={PALETTE.ink}>
          {a.label}
        </text>
        <circle
          cx={xd}
          cy={96}
          r={26}
          fill={Math.abs(ecart) > 0.35 && ecart < 0 ? "#fecaca" : "#dbeafe"}
          stroke={PALETTE.slate}
          strokeWidth={1.6}
        />
        <text x={xd} y={102} textAnchor="middle" fontSize={16} fontWeight={700} fill={PALETTE.ink}>
          {b.label}
        </text>

        <circle cx={xDoublet - 5} cy={96} r={5} fill={PALETTE.purple} />
        <circle cx={xDoublet + 5} cy={96} r={5} fill={PALETTE.purple} />
        <text x={xDoublet} y={74} textAnchor="middle" fontSize={10} fill={PALETTE.purple}>
          doublet
        </text>

        <text x={xg} y={142} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          χ = {a.en.toFixed(1).replace(".", ",")}
        </text>
        <text x={xd} y={142} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          χ = {b.en.toFixed(1).replace(".", ",")}
        </text>

        <text
          x={W / 2}
          y={172}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={polarisee ? PALETTE.red : PALETTE.green}
        >
          {polarisee ? "liaison POLARISÉE" : "liaison non polarisée"}
        </text>
      </Board>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Écart d'électronégativité"
          value={Math.abs(ecart).toFixed(1).replace(".", ",")}
          color={PALETTE.purple}
        />
        <Stat
          label="Le doublet penche vers"
          value={Math.abs(ecart) < 0.1 ? "le milieu" : ecart > 0 ? b.label : a.label}
          color={PALETTE.orange}
        />
      </div>

      <Verdict tone={polarisee ? "warn" : "ok"}>
        {polarisee
          ? `${ecart > 0 ? b.label : a.label} est plus électronégatif : il attire plus fortement les électrons de la liaison. La répartition des charges n'est pas symétrique — c'est la définition d'une liaison polarisée.`
          : "Les deux atomes attirent les électrons avec la même force : le doublet reste au milieu et la liaison n'est pas polarisée."}
      </Verdict>

      <Verdict tone="ok">
        Les éléments les plus électronégatifs sont en HAUT et à DROITE du tableau périodique ; les
        plus électropositifs en BAS et à GAUCHE. L&apos;échelle va de 4 pour le fluor à 0,8 pour le
        césium, et l&apos;électronégativité des gaz rares est nulle.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 19 — Oxydoréduction ou pas ?                               */
/* ------------------------------------------------------------------ */

type EqNo = {
  texte: string;
  no: string;
  redox: boolean;
  oxydant: string;
  reducteur: string;
  explication: string;
};

const EQNO_DEFAUT: EqNo = {
  texte: "2 H₂ + O₂ → 2 H₂O",
  no: "H : 0 → +I   ·   O : 0 → −II",
  redox: true,
  oxydant: "O",
  reducteur: "H",
  explication:
    "L'hydrogène passe de 0 à +I : son n.o. AUGMENTE, c'est le réducteur. L'oxygène passe de 0 à −II : son n.o. DIMINUE, c'est l'oxydant.",
};

const EQUATIONS_NO: ReadonlyArray<EqNo> = [
  EQNO_DEFAUT,
  {
    texte: "2 CuO + C → CO₂ + 2 Cu",
    no: "Cu : +II → 0   ·   C : 0 → +IV",
    redox: true,
    oxydant: "Cu",
    reducteur: "C",
    explication:
      "Le cuivre passe de +II à 0 : son n.o. diminue, il est réduit, c'est l'oxydant. Le carbone passe de 0 à +IV : il est oxydé, c'est le réducteur.",
  },
  {
    texte: "ZnO + 2 HCl → ZnCl₂ + H₂O",
    no: "Zn : +II → +II  ·  O : −II → −II  ·  H : +I → +I  ·  Cl : −I → −I",
    redox: false,
    oxydant: "—",
    reducteur: "—",
    explication:
      "AUCUNE variation de nombre d'oxydation : ce n'est pas une oxydoréduction, malgré l'allure de l'équation.",
  },
  {
    texte: "Fe₂O₃ + 3 CO → 2 Fe + 3 CO₂",
    no: "Fe : +III → 0   ·   C : +II → +IV",
    redox: true,
    oxydant: "Fe",
    reducteur: "C",
    explication:
      "C'est la réaction du haut fourneau : le monoxyde de carbone réduit le minerai de fer. Le fer passe de +III à 0.",
  },
  {
    texte: "SO₃ + H₂O → H₂SO₄",
    no: "S : +VI → +VI  ·  O : −II → −II  ·  H : +I → +I",
    redox: false,
    oxydant: "—",
    reducteur: "—",
    explication:
      "Rien ne bouge : ce n'est pas une oxydoréduction, c'est une simple hydratation de l'oxyde.",
  },
  {
    texte: "H₂S + Cl₂ → 2 HCl + S",
    no: "S : −II → 0   ·   Cl : 0 → −I",
    redox: true,
    oxydant: "Cl",
    reducteur: "S",
    explication:
      "Le soufre passe de −II à 0 : il est oxydé, c'est le réducteur. Le chlore passe de 0 à −I : c'est l'oxydant.",
  },
  {
    texte: "Ag⁺ + Cl⁻ → AgCl",
    no: "Ag : +I → +I   ·   Cl : −I → −I",
    redox: false,
    oxydant: "—",
    reducteur: "—",
    explication: "C'est une précipitation, pas une oxydoréduction : aucun n.o. ne change.",
  },
];

export function RedoxVoieSeche() {
  const [i, setI] = useState(0);
  const [rep, setRep] = useState("");
  const [score, setScore] = useState({ bon: 0, total: 0 });

  const e = EQUATIONS_NO[i % EQUATIONS_NO.length] ?? EQNO_DEFAUT;
  const attendu = e.redox ? "oui" : "non";
  const juste = rep === attendu;

  function repondre(v: string) {
    if (rep) return;
    setRep(v);
    setScore((s) => ({ bon: s.bon + (v === attendu ? 1 : 0), total: s.total + 1 }));
  }

  const W = 440;
  const H = 170;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text
          x={W / 2}
          y={48}
          textAnchor="middle"
          fontSize={16}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {e.texte}
        </text>
        <text x={W / 2} y={76} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {e.no}
        </text>

        {rep ? (
          <g>
            <text
              x={W / 2}
              y={110}
              textAnchor="middle"
              fontSize={13}
              fontWeight={700}
              fill={juste ? PALETTE.green : PALETTE.red}
            >
              {e.redox ? "C'EST UNE OXYDORÉDUCTION" : "CE N'EST PAS UNE OXYDORÉDUCTION"}
            </text>
            {e.redox ? (
              <text x={W / 2} y={136} textAnchor="middle" fontSize={12} fill={PALETTE.slate}>
                oxydant : {e.oxydant} · réducteur : {e.reducteur}
              </text>
            ) : null}
          </g>
        ) : (
          <text x={W / 2} y={120} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
            regarde si au moins un nombre d&apos;oxydation a changé
          </text>
        )}
      </Board>

      <Choice
        label="Est-ce une oxydoréduction ?"
        value={rep}
        options={[
          { value: "oui", label: "Oui" },
          { value: "non", label: "Non" },
        ]}
        onChange={repondre}
      />

      {rep ? <Verdict tone={juste ? "ok" : "bad"}>{e.explication}</Verdict> : null}

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Bonnes réponses"
          value={`${score.bon} / ${score.total}`}
          color={PALETTE.green}
        />
        <Stat label="Équation" value={`n° ${i + 1}`} color={PALETTE.slate} />
      </div>

      <Choice
        value=""
        options={[{ value: "next", label: "Équation suivante" }]}
        onChange={() => {
          setI((k) => k + 1);
          setRep("");
        }}
      />
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 19 — Équilibrer par les nombres d'oxydation                */
/* ------------------------------------------------------------------ */

type Exo = {
  value: string;
  brute: string;
  el1: string;
  d1: number;
  mult1: number;
  el2: string;
  d2: number;
  alpha: number;
  beta: number;
  finale: string;
  fin: string;
};

const EXO_DEFAUT: Exo = {
  value: "h2o",
  brute: "H₂ + O₂ → H₂O",
  el1: "H",
  d1: 1,
  mult1: 1,
  el2: "O",
  d2: -2,
  alpha: 2,
  beta: 1,
  finale: "2 H₂ + O₂ → 2 H₂O",
  fin: "Il ne reste rien à ajuster : les coefficients 2 et 1 suffisent.",
};

const EXOS: ReadonlyArray<Exo> = [
  EXO_DEFAUT,
  {
    value: "c_h2so4",
    brute: "C + H₂SO₄ → CO₂ + SO₂ + H₂O",
    el1: "C",
    d1: 4,
    mult1: 1,
    el2: "S",
    d2: -2,
    alpha: 1,
    beta: 2,
    finale: "C + 2 H₂SO₄ → CO₂ + 2 SO₂ + 2 H₂O",
    fin: "Il reste 4 hydrogènes à gauche : on place 2 H₂O à droite. Vérification des oxygènes : 8 à gauche, 2 + 4 + 2 = 8 à droite.",
  },
  {
    value: "fe2o3",
    brute: "Fe₂O₃ + CO → Fe + CO₂",
    el1: "Fe",
    d1: -3,
    mult1: 2,
    el2: "C",
    d2: 2,
    alpha: 1,
    beta: 3,
    finale: "Fe₂O₃ + 3 CO → 2 Fe + 3 CO₂",
    fin: "Attention : il y a DEUX atomes de fer dans Fe₂O₃, d'où le facteur 2 dans l'équation des coefficients.",
  },
  {
    value: "hno3",
    brute: "HNO₃ + C → CO₂ + NO₂ + H₂O",
    el1: "N",
    d1: -1,
    mult1: 1,
    el2: "C",
    d2: 4,
    alpha: 4,
    beta: 1,
    finale: "4 HNO₃ + C → CO₂ + 4 NO₂ + 2 H₂O",
    fin: "Il reste 4 hydrogènes à gauche : on place 2 H₂O à droite.",
  },
  {
    value: "cuo_nh3",
    brute: "CuO + NH₃ → Cu + H₂O + N₂",
    el1: "Cu",
    d1: -2,
    mult1: 1,
    el2: "N",
    d2: 3,
    alpha: 3,
    beta: 2,
    finale: "3 CuO + 2 NH₃ → 3 Cu + 3 H₂O + N₂",
    fin: "Il reste 6 hydrogènes à gauche : on place 3 H₂O à droite, et les 2 azotes donnent 1 N₂.",
  },
];

export function EquilibrerNo() {
  const [choix, setChoix] = useState("h2o");
  const [etape, setEtape] = useState(1);
  const x = EXOS.find((e) => e.value === choix) ?? EXO_DEFAUT;
  const e = clamp(etape, 1, 4);

  const W = 440;
  const H = 210;

  return (
    <div className="space-y-3">
      <Choice
        label="Équation à équilibrer"
        value={choix}
        options={EXOS.map((o) => ({ value: o.value, label: o.brute.split(" →")[0] ?? o.value }))}
        onChange={(v) => {
          setChoix(v);
          setEtape(1);
        }}
      />
      <Ctrl
        label="Étape"
        value={e}
        min={1}
        max={4}
        step={1}
        onChange={setEtape}
        display={`étape ${e} sur 4`}
        color={PALETTE.purple}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text
          x={W / 2}
          y={40}
          textAnchor="middle"
          fontSize={16}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {e >= 4 ? x.finale : x.brute}
        </text>

        <g fontSize={12} fill={PALETTE.slate}>
          {e >= 2 ? (
            <>
              <text x={30} y={82}>
                Δn.o.({x.el1}) = {x.d1 > 0 ? "+" : "−"}
                {["", "I", "II", "III", "IV", "V", "VI", "VII"][Math.abs(x.d1)] ?? Math.abs(x.d1)}
                {x.mult1 > 1 ? `   (×${x.mult1} atomes)` : ""}
              </text>
              <text x={30} y={106}>
                Δn.o.({x.el2}) = {x.d2 > 0 ? "+" : "−"}
                {["", "I", "II", "III", "IV", "V", "VI", "VII"][Math.abs(x.d2)] ?? Math.abs(x.d2)}
              </text>
            </>
          ) : (
            <text x={30} y={94}>
              1. On écrit les nombres d&apos;oxydation de chaque élément, à gauche et à droite.
            </text>
          )}

          {e >= 3 ? (
            <>
              <text x={30} y={140} fontWeight={700} fill={PALETTE.ink}>
                α × {x.mult1 > 1 ? `${x.mult1} × ` : ""}({x.d1 > 0 ? "+" : ""}
                {x.d1}) + β × ({x.d2 > 0 ? "+" : ""}
                {x.d2}) = 0
              </text>
              <text x={30} y={164} fontWeight={700} fill={PALETTE.purple}>
                α = {x.alpha} et β = {x.beta}
              </text>
            </>
          ) : null}

          {e >= 4 ? (
            <foreignObject x={24} y={176} width={396} height={30}>
              <div style={{ fontSize: 11, color: "#334155", fontFamily: "system-ui, sans-serif" }}>
                {x.fin}
              </div>
            </foreignObject>
          ) : null}
        </g>

        {Array.from({ length: 4 }).map((_, i) => (
          <circle
            key={i}
            cx={360 + i * 20}
            cy={60}
            r={6}
            fill={i < e ? PALETTE.purple : "#e2e8f0"}
          />
        ))}
      </Board>

      <Verdict tone={e >= 4 ? "ok" : "warn"}>
        {e >= 4
          ? "Les électrons perdus sont exactement ceux qui sont gagnés : la somme pondérée des variations de nombre d'oxydation est donc nulle. C'est tout le principe, et il tient en une ligne."
          : "La méthode : écrire les n.o., calculer les variations, poser α·Δn.o.(1) + β·Δn.o.(2) = 0, puis finir l'équilibrage sur les éléments qui n'ont pas changé."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 19 — L'oxydoréduction dans l'industrie                     */
/* ------------------------------------------------------------------ */

type Procede = {
  value: string;
  label: string;
  equation: string;
  no: string;
  oxydant: string;
  reducteur: string;
  usage: string;
  note: string;
  dismutation: boolean;
};

const PROC_DEFAUT: Procede = {
  value: "haut-fourneau",
  label: "Haut fourneau",
  equation: "Fe₂O₃ + 3 CO → 2 Fe + 3 CO₂",
  no: "Fe : +III → 0   ·   C : +II → +IV",
  oxydant: "Fe₂O₃",
  reducteur: "CO",
  usage: "produire la fonte, puis l'acier",
  note: "Dans la nature le fer est oxydé : l'obtenir, c'est le réduire. Le monoxyde de carbone, fabriqué sur place à partir du coke, est le réducteur.",
  dismutation: false,
};

const PROCEDES: ReadonlyArray<Procede> = [
  PROC_DEFAUT,
  {
    value: "aluminothermie",
    label: "Aluminothermie",
    equation: "2 Al + Fe₂O₃ → Al₂O₃ + 2 Fe",
    no: "Al : 0 → +III   ·   Fe : +III → 0",
    oxydant: "Fe₂O₃",
    reducteur: "Al",
    usage: "souder les rails de chemin de fer sur place",
    note: "L'aluminium est un réducteur si puissant qu'il arrache l'oxygène aux autres oxydes. La réaction est si exothermique que le fer produit est liquide.",
    dismutation: false,
  },
  {
    value: "alumine",
    label: "Électrolyse de l'alumine",
    equation: "2 Al₂O₃ → 4 Al + 3 O₂",
    no: "Al : +III → 0   ·   O : −II → 0",
    oxydant: "Al³⁺",
    reducteur: "O²⁻",
    usage: "produire l'aluminium",
    note: "Aucun réducteur chimique ne peut réduire l'aluminium, justement parce qu'il est le plus fort. Seule l'électricité y parvient — d'où les usines installées près des barrages, comme à Édéa.",
    dismutation: false,
  },
  {
    value: "javel",
    label: "Eau de javel",
    equation: "Cl₂ + 2 HO⁻ → ClO⁻ + Cl⁻ + H₂O",
    no: "Cl : 0 → +I   ET   Cl : 0 → −I",
    oxydant: "Cl₂",
    reducteur: "Cl₂",
    usage: "désinfecter l'eau et les surfaces",
    note: "Le même élément est à la fois oxydé et réduit : cette réaction s'appelle une DISMUTATION. Le chlore monte à +I dans ClO⁻ et descend à −I dans Cl⁻.",
    dismutation: true,
  },
];

export function ApplicationsIndustrielles() {
  const [choix, setChoix] = useState("haut-fourneau");
  const [degre, setDegre] = useState(48);
  const [volume, setVolume] = useState(0.25);
  const p = PROCEDES.find((x) => x.value === choix) ?? PROC_DEFAUT;

  const vCl2 = degre * volume;
  const nCl2 = vCl2 / 22.4;
  const concentration = volume > 0 ? nCl2 / volume : 0;

  const W = 440;
  const H = 190;

  return (
    <div className="space-y-3">
      <Choice
        label="Procédé industriel"
        value={choix}
        options={PROCEDES.map((o) => ({ value: o.value, label: o.label }))}
        onChange={setChoix}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text
          x={W / 2}
          y={34}
          textAnchor="middle"
          fontSize={15}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {p.equation}
        </text>
        <text x={W / 2} y={58} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {p.no}
        </text>

        <rect x={30} y={76} width={176} height={46} rx={8} fill="#fef2f2" />
        <text x={118} y={94} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          oxydant — son n.o. diminue
        </text>
        <text x={118} y={113} textAnchor="middle" fontSize={14} fontWeight={700} fill={PALETTE.red}>
          {p.oxydant}
        </text>

        <rect x={234} y={76} width={176} height={46} rx={8} fill="#ecfdf5" />
        <text x={322} y={94} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          réducteur — son n.o. augmente
        </text>
        <text
          x={322}
          y={113}
          textAnchor="middle"
          fontSize={14}
          fontWeight={700}
          fill={PALETTE.green}
        >
          {p.reducteur}
        </text>

        <text
          x={W / 2}
          y={146}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.purple}
        >
          à quoi ça sert : {p.usage}
        </text>
        {p.dismutation ? (
          <text
            x={W / 2}
            y={170}
            textAnchor="middle"
            fontSize={12}
            fontWeight={700}
            fill={PALETTE.orange}
          >
            DISMUTATION — le même élément monte et descend
          </text>
        ) : null}
      </Board>

      <Verdict tone={p.dismutation ? "warn" : "ok"}>{p.note}</Verdict>

      {p.value === "javel" ? (
        <>
          <Panel>
            <Ctrl
              label="Degré chlorométrique"
              value={degre}
              min={6}
              max={120}
              step={2}
              onChange={setDegre}
              display={`${degre} °Chl`}
              color={PALETTE.orange}
            />
            <Ctrl
              label="Volume de solution à préparer"
              value={volume}
              min={0.05}
              max={2}
              step={0.05}
              onChange={setVolume}
              display={`${fmt(volume * 1000, 0)} mL`}
              color={PALETTE.blue}
            />
          </Panel>
          <div className="grid grid-cols-3 gap-2">
            <Stat label="Dichlore nécessaire" value={`${fmt(vCl2, 1)} L`} color={PALETTE.orange} />
            <Stat label="Soit" value={`${fmt(nCl2, 3)} mol`} color={PALETTE.slate} />
            <Stat label="[ClO⁻]" value={`${fmt(concentration, 2)} mol/L`} color={PALETTE.green} />
          </div>
          <Verdict tone="ok">
            Le degré chlorométrique est le volume de dichlore gazeux, mesuré dans les conditions
            normales, utilisé pour préparer UN LITRE de solution. Une mole de dichlore donne une
            mole d&apos;ions hypochlorite : la concentration ne dépend donc que du degré, pas du
            volume préparé.
          </Verdict>
        </>
      ) : null}
    </div>
  );
}
