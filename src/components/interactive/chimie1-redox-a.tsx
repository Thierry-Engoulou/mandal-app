import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict, fmt } from "./controls";

/** Chimie 1ère C, D et E — chapitres 13, 14 et 15 : oxydoréduction, couples et piles. */

export type CoupleMetal = {
  value: string;
  metal: string;
  ion: string;
  nom: string;
  e0: number;
  n: number;
  M: number;
};

/** Classification électrochimique, du plus oxydant au plus réducteur. */
export const COUPLES_METAUX: ReadonlyArray<CoupleMetal> = [
  { value: "au", metal: "Au", ion: "Au³⁺", nom: "or", e0: 1.5, n: 3, M: 197 },
  { value: "hg", metal: "Hg", ion: "Hg²⁺", nom: "mercure", e0: 0.86, n: 2, M: 200.6 },
  { value: "ag", metal: "Ag", ion: "Ag⁺", nom: "argent", e0: 0.8, n: 1, M: 108 },
  { value: "cu", metal: "Cu", ion: "Cu²⁺", nom: "cuivre", e0: 0.34, n: 2, M: 63.5 },
  { value: "h", metal: "H₂", ion: "H₃O⁺", nom: "dihydrogène", e0: 0, n: 2, M: 2 },
  { value: "pb", metal: "Pb", ion: "Pb²⁺", nom: "plomb", e0: -0.13, n: 2, M: 207 },
  { value: "sn", metal: "Sn", ion: "Sn²⁺", nom: "étain", e0: -0.14, n: 2, M: 118.7 },
  { value: "ni", metal: "Ni", ion: "Ni²⁺", nom: "nickel", e0: -0.23, n: 2, M: 58.7 },
  { value: "fe", metal: "Fe", ion: "Fe²⁺", nom: "fer", e0: -0.44, n: 2, M: 56 },
  { value: "zn", metal: "Zn", ion: "Zn²⁺", nom: "zinc", e0: -0.76, n: 2, M: 65.4 },
  { value: "al", metal: "Al", ion: "Al³⁺", nom: "aluminium", e0: -1.66, n: 3, M: 27 },
  { value: "mg", metal: "Mg", ion: "Mg²⁺", nom: "magnésium", e0: -2.37, n: 2, M: 24.3 },
  { value: "na", metal: "Na", ion: "Na⁺", nom: "sodium", e0: -2.71, n: 1, M: 23 },
];

const COUPLE_DEFAUT: CoupleMetal = COUPLES_METAUX[3] ?? {
  value: "cu",
  metal: "Cu",
  ion: "Cu²⁺",
  nom: "cuivre",
  e0: 0.34,
  n: 2,
  M: 63.5,
};

export function trouverCouple(v: string): CoupleMetal {
  return COUPLES_METAUX.find((c) => c.value === v) ?? COUPLE_DEFAUT;
}

/* ------------------------------------------------------------------ */
/* Chapitre 13 — Quel métal l'acide attaque-t-il ?                     */
/* ------------------------------------------------------------------ */

const METAUX_ACIDE = ["al", "mg", "zn", "fe", "ni", "pb", "cu", "ag", "au"];

export function AcideMetal() {
  const [metal, setMetal] = useState("zn");
  const [acide, setAcide] = useState<"hcl" | "h2so4">("hcl");
  const [buchette, setBuchette] = useState(false);

  const c = trouverCouple(metal);
  const attaque = c.e0 < 0;

  const spectateur = acide === "hcl" ? "Cl⁻" : "SO₄²⁻";
  const equation = attaque
    ? c.n === 2
      ? `${c.metal} + 2 H₃O⁺ → ${c.ion} + H₂ + 2 H₂O`
      : `2 ${c.metal} + 6 H₃O⁺ → 2 ${c.ion} + 3 H₂ + 6 H₂O`
    : "pas de réaction";

  const W = 440;
  const H = 210;

  return (
    <div className="space-y-3">
      <Choice
        label="Métal dans le tube"
        value={metal}
        options={METAUX_ACIDE.map((v) => ({ value: v, label: trouverCouple(v).metal }))}
        onChange={(v) => {
          setMetal(v);
          setBuchette(false);
        }}
      />
      <Choice
        label="Acide versé"
        value={acide}
        options={[
          { value: "hcl" as const, label: "Acide chlorhydrique dilué" },
          { value: "h2so4" as const, label: "Acide sulfurique dilué" },
        ]}
        onChange={setAcide}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <path
          d="M160 46 L280 46 L268 176 L172 176 Z"
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <path d="M167 100 L273 100 L268 176 L172 176 Z" fill="#dbeafe" opacity={0.75} />
        <ellipse cx={220} cy={166} rx={Math.max(6, attaque ? 14 : 26)} ry={6} fill="#9ca3af" />

        {attaque
          ? Array.from({ length: 10 }).map((_, i) => (
              <circle
                key={i}
                cx={190 + ((i * 37) % 60)}
                cy={108 + ((i * 23) % 56)}
                r={3 + (i % 3)}
                fill="#ffffff"
                stroke={PALETTE.slate}
                strokeWidth={1}
              />
            ))
          : null}

        <text x={220} y={34} textAnchor="middle" fontSize={12} fontWeight={700} fill={PALETTE.ink}>
          {c.metal} + {acide === "hcl" ? "HCl" : "H₂SO₄"} dilué
        </text>
        <text
          x={220}
          y={196}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={attaque ? PALETTE.green : PALETTE.red}
        >
          {attaque ? "dégagement gazeux, le métal disparaît" : "rien ne se passe"}
        </text>

        {buchette && attaque ? (
          <g>
            <text x={330} y={70} fontSize={13} fontWeight={700} fill={PALETTE.orange}>
              POP !
            </text>
            <text x={330} y={90} fontSize={10} fill={PALETTE.slate}>
              détonation :
            </text>
            <text x={330} y={104} fontSize={10} fontWeight={700} fill={PALETTE.ink}>
              c&apos;est du dihydrogène
            </text>
          </g>
        ) : null}
      </Board>

      <Choice
        value={buchette ? "oui" : "non"}
        options={[
          { value: "non", label: "Bûchette éteinte" },
          { value: "oui", label: "Approcher la bûchette enflammée" },
        ]}
        onChange={(v) => setBuchette(v === "oui")}
      />

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Couple du métal" value={`${c.ion}/${c.metal}`} color={PALETTE.ink} />
        <Stat
          label="Son potentiel"
          value={`${fmt(c.e0, 2)} V`}
          color={c.e0 < 0 ? PALETTE.green : PALETTE.red}
        />
        <Stat label="Ion spectateur" value={spectateur} color={PALETTE.slate} />
      </div>

      <Verdict tone={attaque ? "ok" : "bad"}>
        {attaque
          ? `${equation}. Le métal cède ses électrons aux ions hydronium, qui se transforment en dihydrogène. Les ions ${spectateur} ne participent à rien : ce sont des ions spectateurs, et c'est pourquoi les deux acides donnent le même résultat.`
          : `L'acide n'attaque pas ${c.nom === "or" ? "l'or" : `le ${c.nom}`}. Son couple est à ${fmt(c.e0, 2)} V, donc AU-DESSUS du couple H₃O⁺/H₂ qui vaut 0 V : le métal est un réducteur trop faible pour céder ses électrons aux ions hydronium. C'est pour cela qu'on fait les bijoux avec ces métaux-là.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 13 — Identifier un ion métallique                          */
/* ------------------------------------------------------------------ */

type IonTest = {
  value: string;
  nom: string;
  formule: string;
  couleurSol: string;
  fillSol: string;
  precipite: string;
  fillPrec: string;
  exces: boolean;
  ammoniac: boolean;
  note: string;
};

const ION_DEFAUT: IonTest = {
  value: "al",
  nom: "ion aluminium",
  formule: "Al³⁺",
  couleurSol: "incolore",
  fillSol: "#f8fafc",
  precipite: "blanc",
  fillPrec: "#f1f5f9",
  exces: true,
  ammoniac: false,
  note: "Al(OH)₃ : soluble dans un excès de soude, INSOLUBLE dans l'ammoniac.",
};

const IONS: ReadonlyArray<IonTest> = [
  ION_DEFAUT,
  {
    value: "zn",
    nom: "ion zinc",
    formule: "Zn²⁺",
    couleurSol: "incolore",
    fillSol: "#f8fafc",
    precipite: "blanc",
    fillPrec: "#f1f5f9",
    exces: true,
    ammoniac: true,
    note: "Zn(OH)₂ : soluble dans un excès de soude ET dans l'ammoniac. C'est l'ammoniac qui le distingue de l'aluminium.",
  },
  {
    value: "mg",
    nom: "ion magnésium",
    formule: "Mg²⁺",
    couleurSol: "incolore",
    fillSol: "#f8fafc",
    precipite: "blanc",
    fillPrec: "#f1f5f9",
    exces: true,
    ammoniac: false,
    note: "Mg(OH)₂ : soluble dans un excès de soude.",
  },
  {
    value: "cu",
    nom: "ion cuivre II",
    formule: "Cu²⁺",
    couleurSol: "bleue",
    fillSol: "#60a5fa",
    precipite: "bleu",
    fillPrec: "#3b82f6",
    exces: false,
    ammoniac: false,
    note: "Cu(OH)₂ : la solution était déjà bleue avant même le test, ce qui suffit presque à conclure.",
  },
  {
    value: "fe2",
    nom: "ion fer II",
    formule: "Fe²⁺",
    couleurSol: "verdâtre très pâle",
    fillSol: "#d1fae5",
    precipite: "vert",
    fillPrec: "#86efac",
    exces: false,
    ammoniac: false,
    note: "Fe(OH)₂ : laissé à l'air, il devient Fe(OH)₃ couleur rouille, par action du dioxygène.",
  },
  {
    value: "fe3",
    nom: "ion fer III",
    formule: "Fe³⁺",
    couleurSol: "rouille",
    fillSol: "#fdba74",
    precipite: "rouille",
    fillPrec: "#c2410c",
    exces: false,
    ammoniac: false,
    note: "Fe(OH)₃ : sa couleur rouille ne laisse aucune ambiguïté.",
  },
];

export function TestsIons() {
  const [idx, setIdx] = useState(0);
  const [etape, setEtape] = useState<"depart" | "soude" | "exces" | "ammoniac">("depart");
  const [reponse, setReponse] = useState("");

  const x = IONS[idx % IONS.length] ?? ION_DEFAUT;
  const dissous = (etape === "exces" && x.exces) || (etape === "ammoniac" && x.ammoniac);

  const juste = reponse === x.value;

  const W = 440;
  const H = 190;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text
          x={W / 2}
          y={24}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          bécher n° {idx + 1} — solution inconnue
        </text>

        <path
          d="M172 44 L268 44 L260 158 L180 158 Z"
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <path
          d="M177 90 L263 90 L260 158 L180 158 Z"
          fill={etape === "depart" || dissous ? x.fillSol : "#ffffff"}
          opacity={0.85}
        />
        {etape !== "depart" && !dissous ? (
          <ellipse cx={220} cy={148} rx={34} ry={10} fill={x.fillPrec} />
        ) : null}

        <text x={220} y={176} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {etape === "depart"
            ? `solution ${x.couleurSol}`
            : dissous
              ? "le précipité s'est DISSOUS"
              : `précipité ${x.precipite}`}
        </text>
      </Board>

      <Choice
        label="Que fais-tu ?"
        value={etape}
        options={[
          { value: "depart" as const, label: "Regarder la couleur" },
          { value: "soude" as const, label: "Ajouter de la soude" },
          { value: "exces" as const, label: "Excès de soude" },
          { value: "ammoniac" as const, label: "Ajouter de l'ammoniac" },
        ]}
        onChange={setEtape}
      />

      <Choice
        label="Annonce l'ion"
        value={reponse}
        options={IONS.map((o) => ({ value: o.value, label: o.formule }))}
        onChange={setReponse}
      />

      {reponse ? (
        <Verdict tone={juste ? "ok" : "bad"}>
          {juste
            ? `Exact : c'était l'${x.nom}, ${x.formule}. ${x.note}`
            : `Non : c'était l'${x.nom}, ${x.formule}. ${x.note}`}
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Les trois précipités BLANCS — aluminium, zinc, magnésium — ne se départagent pas à
          l&apos;œil. Il faut deux tests de plus : l&apos;excès de soude, puis l&apos;ammoniac.
        </Verdict>
      )}

      <Choice
        value=""
        options={[{ value: "new", label: "Changer de bécher" }]}
        onChange={() => {
          setIdx((i) => (i + 1) % IONS.length);
          setEtape("depart");
          setReponse("");
        }}
      />
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 14 — Qui prend, qui donne                                  */
/* ------------------------------------------------------------------ */

type DemiEq = { texte: string; oxydation: boolean; espece: string };

const DEMIS: ReadonlyArray<DemiEq> = [
  { texte: "Zn → Zn²⁺ + 2e⁻", oxydation: true, espece: "Zn" },
  { texte: "Cu²⁺ + 2e⁻ → Cu", oxydation: false, espece: "Cu²⁺" },
  { texte: "Fe → Fe²⁺ + 2e⁻", oxydation: true, espece: "Fe" },
  { texte: "Ag⁺ + e⁻ → Ag", oxydation: false, espece: "Ag⁺" },
  { texte: "2 H₃O⁺ + 2e⁻ → H₂ + 2 H₂O", oxydation: false, espece: "H₃O⁺" },
  { texte: "Al → Al³⁺ + 3e⁻", oxydation: true, espece: "Al" },
  { texte: "Fe²⁺ → Fe³⁺ + e⁻", oxydation: true, espece: "Fe²⁺" },
];

const DEMI_DEFAUT: DemiEq = DEMIS[0] ?? { texte: "Zn → Zn²⁺ + 2e⁻", oxydation: true, espece: "Zn" };

export function OxydantReducteur() {
  const [i, setI] = useState(0);
  const [rep, setRep] = useState("");
  const [score, setScore] = useState({ bon: 0, total: 0 });

  const d = DEMIS[i % DEMIS.length] ?? DEMI_DEFAUT;
  const attendu = d.oxydation ? "oxydation" : "reduction";
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
          y={60}
          textAnchor="middle"
          fontSize={18}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {d.texte}
        </text>

        {rep ? (
          <g>
            <text
              x={W / 2}
              y={100}
              textAnchor="middle"
              fontSize={14}
              fontWeight={700}
              fill={juste ? PALETTE.green : PALETTE.red}
            >
              {d.oxydation ? "OXYDATION" : "RÉDUCTION"}
            </text>
            <text x={W / 2} y={126} textAnchor="middle" fontSize={12} fill={PALETTE.slate}>
              {d.espece} {d.oxydation ? "PERD" : "GAGNE"} des électrons
            </text>
            <text
              x={W / 2}
              y={148}
              textAnchor="middle"
              fontSize={12}
              fontWeight={700}
              fill={PALETTE.blue}
            >
              {d.espece} est donc {d.oxydation ? "un RÉDUCTEUR" : "un OXYDANT"}
            </text>
          </g>
        ) : (
          <text x={W / 2} y={110} textAnchor="middle" fontSize={12} fill={PALETTE.slate}>
            oxydation ou réduction ? regarde de quel côté sont les électrons
          </text>
        )}
      </Board>

      <Choice
        label="Ta réponse"
        value={rep}
        options={[
          { value: "oxydation", label: "Oxydation" },
          { value: "reduction", label: "Réduction" },
        ]}
        onChange={repondre}
      />

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Bonnes réponses"
          value={`${score.bon} / ${score.total}`}
          color={PALETTE.green}
        />
        <Stat label="Question" value={`n° ${i + 1}`} color={PALETTE.slate} />
      </div>

      <Choice
        value=""
        options={[{ value: "next", label: "Demi-équation suivante" }]}
        onChange={() => {
          setI((k) => k + 1);
          setRep("");
        }}
      />

      <Verdict tone="warn">
        Les électrons à DROITE : l&apos;espèce les perd, c&apos;est une oxydation, et l&apos;espèce
        est un réducteur. Les électrons à GAUCHE : l&apos;espèce les capte, c&apos;est une
        réduction, et l&apos;espèce est un oxydant. L&apos;oxydant prend, le réducteur donne.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 14 — Construire un couple                                  */
/* ------------------------------------------------------------------ */

const METAUX_PLONGE = ["zn", "fe", "ni", "pb", "cu", "ag"];

export function CoupleRedox() {
  const [lame, setLame] = useState("zn");
  const [solution, setSolution] = useState("cu");

  const a = trouverCouple(lame);
  const b = trouverCouple(solution);
  const reagit = a.e0 < b.e0 && a.value !== b.value;

  // coefficients pour annuler les électrons
  const k = (a.n * b.n) / pgcdSimple(a.n, b.n);
  const ca = k / a.n;
  const cb = k / b.n;
  const coef = (c: number) => (c === 1 ? "" : `${c} `);

  const W = 440;
  const H = 200;

  return (
    <div className="space-y-3">
      <Panel>
        <Choice
          label="Lame métallique plongée"
          value={lame}
          options={METAUX_PLONGE.map((v) => ({ value: v, label: trouverCouple(v).metal }))}
          onChange={setLame}
        />
        <Choice
          label="Solution d'ions"
          value={solution}
          options={METAUX_PLONGE.map((v) => ({ value: v, label: trouverCouple(v).ion }))}
          onChange={setSolution}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <path
          d="M120 48 L300 48 L288 170 L132 170 Z"
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <path
          d="M127 92 L293 92 L288 170 L132 170 Z"
          fill={b.value === "cu" ? "#93c5fd" : "#e0f2fe"}
          opacity={reagit ? 0.4 : 0.85}
        />

        <rect x={198} y={56} width={22} height={104} fill={reagit ? "#a8a29e" : "#94a3b8"} />
        {reagit ? (
          <rect x={194} y={96} width={30} height={62} fill="#b45309" opacity={0.85} />
        ) : null}
        <text x={209} y={44} textAnchor="middle" fontSize={11} fontWeight={700} fill={PALETTE.ink}>
          {a.metal}
        </text>

        <text x={330} y={70} fontSize={11} fill={PALETTE.slate}>
          E°({a.ion}/{a.metal}) = {fmt(a.e0, 2)} V
        </text>
        <text x={330} y={92} fontSize={11} fill={PALETTE.slate}>
          E°({b.ion}/{b.metal}) = {fmt(b.e0, 2)} V
        </text>
        <text
          x={330}
          y={122}
          fontSize={12}
          fontWeight={700}
          fill={reagit ? PALETTE.green : PALETTE.red}
        >
          {reagit ? "un dépôt se forme" : "rien ne se passe"}
        </text>

        {reagit ? (
          <g fontSize={11}>
            <text x={30} y={186} fill={PALETTE.slate}>
              {a.metal} → {a.ion} + {a.n}e⁻ (oxydation) ×{ca}
            </text>
            <text x={250} y={186} fill={PALETTE.slate}>
              {b.ion} + {b.n}e⁻ → {b.metal} (réduction) ×{cb}
            </text>
          </g>
        ) : (
          <text x={W / 2} y={186} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
            {a.value === b.value
              ? "même métal des deux côtés : il ne peut rien se passer"
              : "le métal plongé est un réducteur trop faible pour cet ion"}
          </text>
        )}
      </Board>

      <Verdict tone={reagit ? "ok" : "bad"}>
        {reagit
          ? `${coef(ca)}${a.metal} + ${coef(cb)}${b.ion} → ${coef(ca)}${a.ion} + ${coef(cb)}${b.metal}. Le métal ${a.nom} cède ses électrons : il est RÉDUCTEUR. L'ion ${b.ion} les capte : il est OXYDANT. Les deux formes d'un même élément constituent un couple, noté oxydant / réducteur.`
          : a.value === b.value
            ? "Un métal ne réagit pas avec ses propres ions : choisis deux éléments différents."
            : `Le couple ${a.ion}/${a.metal} est à ${fmt(a.e0, 2)} V, au-dessus de ${b.ion}/${b.metal} à ${fmt(b.e0, 2)} V. La réaction ne peut pas se faire dans ce sens : inverse la lame et la solution pour la voir se produire.`}
      </Verdict>
    </div>
  );
}

function pgcdSimple(a: number, b: number): number {
  return b === 0 ? a : pgcdSimple(b, a % b);
}

/* ------------------------------------------------------------------ */
/* Chapitre 15 — Construire sa propre pile                             */
/* ------------------------------------------------------------------ */

const METAUX_PILE = ["mg", "al", "zn", "fe", "ni", "sn", "pb", "cu", "ag", "au"];

export function ConstruirePile() {
  const [g, setG] = useState("zn");
  const [d, setD] = useState("cu");
  const [pont, setPont] = useState(true);

  const a = trouverCouple(g);
  const b = trouverCouple(d);
  const negatif = a.e0 <= b.e0 ? a : b;
  const positif = a.e0 <= b.e0 ? b : a;
  const fem = positif.e0 - negatif.e0;
  const marche = pont && a.value !== b.value;

  const W = 440;
  const H = 220;

  return (
    <div className="space-y-3">
      <Panel>
        <Choice
          label="Demi-pile de gauche"
          value={g}
          options={METAUX_PILE.map((v) => ({ value: v, label: trouverCouple(v).metal }))}
          onChange={setG}
        />
        <Choice
          label="Demi-pile de droite"
          value={d}
          options={METAUX_PILE.map((v) => ({ value: v, label: trouverCouple(v).metal }))}
          onChange={setD}
        />
      </Panel>
      <Choice
        label="Pont salin"
        value={pont ? "oui" : "non"}
        options={[
          { value: "oui", label: "En place" },
          { value: "non", label: "Retiré" },
        ]}
        onChange={(v) => setPont(v === "oui")}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        {[
          { x: 48, c: a, cote: "g" },
          { x: 262, c: b, cote: "d" },
        ].map((s) => (
          <g key={s.cote}>
            <rect
              x={s.x}
              y={108}
              width={130}
              height={76}
              fill="#f8fafc"
              stroke={PALETTE.slate}
              strokeWidth={2}
            />
            <rect x={s.x + 2} y={134} width={126} height={48} fill="#dbeafe" opacity={0.7} />
            <rect x={s.x + 54} y={74} width={20} height={94} fill="#94a3b8" />
            <text
              x={s.x + 64}
              y={66}
              textAnchor="middle"
              fontSize={12}
              fontWeight={700}
              fill={PALETTE.ink}
            >
              {s.c.metal}
            </text>
            <text x={s.x + 64} y={200} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
              {s.c.ion} 1 mol/L
            </text>
            <text
              x={s.x + 64}
              y={214}
              textAnchor="middle"
              fontSize={12}
              fontWeight={700}
              fill={s.c.value === negatif.value ? PALETTE.red : PALETTE.green}
            >
              {marche ? (s.c.value === negatif.value ? "pôle −" : "pôle +") : ""}
            </text>
          </g>
        ))}

        {pont ? (
          <path
            d="M112 108 Q 112 62 220 62 Q 328 62 328 108"
            fill="none"
            stroke={PALETTE.purple}
            strokeWidth={6}
            strokeLinecap="round"
          />
        ) : (
          <text
            x={220}
            y={74}
            textAnchor="middle"
            fontSize={11}
            fontWeight={700}
            fill={PALETTE.red}
          >
            pont salin retiré
          </text>
        )}

        <line x1={122} y1={74} x2={122} y2={34} stroke={PALETTE.ink} strokeWidth={2} />
        <line x1={336} y1={74} x2={336} y2={34} stroke={PALETTE.ink} strokeWidth={2} />
        <line x1={122} y1={34} x2={204} y2={34} stroke={PALETTE.ink} strokeWidth={2} />
        <line x1={256} y1={34} x2={336} y2={34} stroke={PALETTE.ink} strokeWidth={2} />
        <circle cx={230} cy={34} r={24} fill="#ffffff" stroke={PALETTE.ink} strokeWidth={2} />
        <text
          x={230}
          y={39}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={marche ? PALETTE.green : PALETTE.slate}
        >
          {marche ? fmt(fem, 2) : "0"}
        </text>
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Pôle négatif" value={marche ? negatif.metal : "—"} color={PALETTE.red} />
        <Stat label="Pôle positif" value={marche ? positif.metal : "—"} color={PALETTE.green} />
        <Stat
          label="Force électromotrice"
          value={marche ? `${fmt(fem, 2)} V` : "0 V"}
          color={PALETTE.purple}
        />
      </div>

      <Verdict tone={marche ? "ok" : "bad"}>
        {!pont
          ? "Sans pont salin, le circuit n'est pas fermé : les charges se déséquilibrent instantanément de part et d'autre et le courant tombe à zéro. Le pont assure le contact entre les deux solutions tout en évitant leur mélange."
          : a.value === b.value
            ? "Deux demi-piles identiques : la différence de potentiel est nulle, donc la pile ne débite pas. Il faut deux métaux différents."
            : `⊖ ${negatif.metal} | ${negatif.ion} ‖ ${positif.ion} | ${positif.metal} ⊕ — la f.é.m. vaut E°(pôle +) − E°(pôle −) = ${fmt(positif.e0, 2)} − (${fmt(negatif.e0, 2)}) = ${fmt(fem, 2)} V. Le pôle négatif est toujours le métal le PLUS réducteur, celui dont le potentiel est le plus bas.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 15 — Lire le tableau des potentiels                        */
/* ------------------------------------------------------------------ */

export function PotentielsStandards() {
  const [a, setA] = useState("zn");
  const [b, setB] = useState("cu");

  const ca = trouverCouple(a);
  const cb = trouverCouple(b);
  const fort = ca.e0 >= cb.e0 ? ca : cb;
  const faible = ca.e0 >= cb.e0 ? cb : ca;
  const delta = Math.abs(ca.e0 - cb.e0);
  const totale = delta > 0.34;

  const W = 440;
  const H = 330;
  // espacement régulier : sur une échelle linéaire, Pb et Sn se superposeraient
  const rang = new Map(COUPLES_METAUX.map((c, i) => [c.value, i]));
  const y = (v: string) => 42 + (rang.get(v) ?? 0) * 21;

  return (
    <div className="space-y-3">
      <Panel>
        <Choice
          label="Premier couple"
          value={a}
          options={COUPLES_METAUX.map((c) => ({ value: c.value, label: `${c.ion}/${c.metal}` }))}
          onChange={setA}
        />
        <Choice
          label="Second couple"
          value={b}
          options={COUPLES_METAUX.map((c) => ({ value: c.value, label: `${c.ion}/${c.metal}` }))}
          onChange={setB}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line x1={220} y1={26} x2={220} y2={322} stroke={PALETTE.gridStrong} strokeWidth={1.4} />
        <text x={300} y={22} fontSize={10} fontWeight={700} fill={PALETTE.axis}>
          E° (V)
        </text>

        {COUPLES_METAUX.map((c) => {
          const actif = c.value === a || c.value === b;
          return (
            <g key={c.value}>
              {actif ? (
                <rect x={118} y={y(c.value) - 11} width={240} height={20} rx={5} fill="#fff7ed" />
              ) : null}
              <line
                x1={206}
                y1={y(c.value)}
                x2={234}
                y2={y(c.value)}
                stroke={actif ? PALETTE.orange : PALETTE.gridStrong}
                strokeWidth={actif ? 2.2 : 1.2}
              />
              <text
                x={200}
                y={y(c.value) + 4}
                textAnchor="end"
                fontSize={11}
                fontWeight={actif ? 700 : 400}
                fill={actif ? PALETTE.orange : PALETTE.slate}
              >
                {c.ion}
              </text>
              <text
                x={240}
                y={y(c.value) + 4}
                fontSize={11}
                fontWeight={actif ? 700 : 400}
                fill={actif ? PALETTE.orange : PALETTE.slate}
              >
                {c.metal}
              </text>
              <text x={300} y={y(c.value) + 4} fontSize={10} fill={PALETTE.slate}>
                {fmt(c.e0, 2)} V
              </text>
            </g>
          );
        })}

        <path
          d={`M196 ${y(fort.value)} C 146 ${y(fort.value)}, 146 ${y(faible.value)}, 236 ${y(faible.value)}`}
          fill="none"
          stroke={PALETTE.red}
          strokeWidth={2.4}
          opacity={0.55}
        />
        <text
          x={120}
          y={(y(fort.value) + y(faible.value)) / 2 + 7}
          fontSize={22}
          fontWeight={700}
          fill={PALETTE.red}
        >
          γ
        </text>

        <text x={366} y={48} fontSize={10} fontWeight={700} fill={PALETTE.slate}>
          oxydant ↑
        </text>
        <text x={366} y={310} fontSize={10} fontWeight={700} fill={PALETTE.slate}>
          réducteur ↓
        </text>
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Oxydant le plus fort" value={fort.ion} color={PALETTE.red} />
        <Stat label="Réducteur le plus fort" value={faible.metal} color={PALETTE.blue} />
        <Stat
          label="ΔE"
          value={`${fmt(delta, 2)} V`}
          color={totale ? PALETTE.green : PALETTE.orange}
        />
      </div>

      <Verdict tone={ca.value === cb.value ? "warn" : "ok"}>
        {ca.value === cb.value
          ? "Choisis deux couples différents pour voir le gamma se tracer."
          : `Un oxydant est d'autant plus fort que son couple a un potentiel ÉLEVÉ ; un réducteur est d'autant plus fort que son couple a un potentiel FAIBLE. Ici ${fort.ion} réagit avec ${faible.metal}.`}
      </Verdict>
      <Verdict tone={totale ? "ok" : "bad"}>
        {totale
          ? `ΔE = ${fmt(delta, 2)} V, donc supérieur à 0,34 V : la réaction est TOTALE. C'est la condition pour qu'un dosage soit fiable.`
          : `ΔE = ${fmt(delta, 2)} V, inférieur à 0,34 V : la réaction est possible mais NON TOTALE. Il restera toujours un peu de réactif.`}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 15 — Suivre la masse des électrodes                        */
/* ------------------------------------------------------------------ */

export function MasseElectrodes() {
  const [g, setG] = useState("fe");
  const [d, setD] = useState("cu");
  const [nElec, setNElec] = useState(0.0875);

  const a = trouverCouple(g);
  const b = trouverCouple(d);
  const negatif = a.e0 <= b.e0 ? a : b;
  const positif = a.e0 <= b.e0 ? b : a;
  const meme = a.value === b.value;

  // nElec : moles d'électrons ayant circulé
  const nNeg = nElec / negatif.n;
  const nPos = nElec / positif.n;
  const dmNeg = -nNeg * negatif.M;
  const dmPos = nPos * positif.M;

  const W = 440;
  const H = 190;
  const ech = 6;

  return (
    <div className="space-y-3">
      <Panel>
        <Choice
          label="Métal 1"
          value={g}
          options={METAUX_PILE.map((v) => ({ value: v, label: trouverCouple(v).metal }))}
          onChange={setG}
        />
        <Choice
          label="Métal 2"
          value={d}
          options={METAUX_PILE.map((v) => ({ value: v, label: trouverCouple(v).metal }))}
          onChange={setD}
        />
      </Panel>
      <Ctrl
        label="Électrons ayant circulé"
        value={nElec}
        min={0}
        max={0.3}
        step={0.0025}
        onChange={setNElec}
        display={`${fmt(nElec, 4)} mol e⁻`}
        color={PALETTE.purple}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <rect x={66} y={40} width={34} height={100} fill="#cbd5e1" />
        <rect
          x={66}
          y={40}
          width={34}
          height={Math.max(0, Math.min(100, Math.abs(dmNeg) * ech))}
          fill="#fecaca"
        />
        <text x={83} y={32} textAnchor="middle" fontSize={12} fontWeight={700} fill={PALETTE.red}>
          {negatif.metal} (pôle −)
        </text>
        <text x={83} y={158} textAnchor="middle" fontSize={13} fontWeight={700} fill={PALETTE.red}>
          {fmt(dmNeg, 2)} g
        </text>
        <text x={83} y={176} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          l&apos;électrode maigrit
        </text>

        <rect x={318} y={40} width={34} height={100} fill="#cbd5e1" />
        <rect
          x={318}
          y={140 - Math.max(0, Math.min(100, dmPos * ech))}
          width={34}
          height={Math.max(0, Math.min(100, dmPos * ech))}
          fill="#bbf7d0"
        />
        <text
          x={335}
          y={32}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={PALETTE.green}
        >
          {positif.metal} (pôle +)
        </text>
        <text
          x={335}
          y={158}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={PALETTE.green}
        >
          +{fmt(dmPos, 2)} g
        </text>
        <text x={335} y={176} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          l&apos;électrode grossit
        </text>

        <g fontSize={11} fill={PALETTE.slate}>
          <text x={136} y={62}>
            {negatif.metal} → {negatif.ion} + {negatif.n}e⁻
          </text>
          <text x={136} y={84}>
            {positif.ion} + {positif.n}e⁻ → {positif.metal}
          </text>
          <text x={136} y={112}>
            n({negatif.metal}) dissous = {fmt(nNeg, 4)} mol
          </text>
          <text x={136} y={132}>
            n({positif.metal}) déposé = {fmt(nPos, 4)} mol
          </text>
        </g>
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Δm pôle négatif" value={`${fmt(dmNeg, 3)} g`} color={PALETTE.red} />
        <Stat label="Δm pôle positif" value={`+${fmt(dmPos, 3)} g`} color={PALETTE.green} />
        <Stat
          label="Électrons échangés"
          value={`${negatif.n} / ${positif.n}`}
          color={PALETTE.purple}
        />
      </div>

      <Verdict tone={meme ? "warn" : negatif.n === positif.n ? "ok" : "bad"}>
        {meme
          ? "Deux fois le même métal : la pile ne débite pas. Choisis deux métaux différents."
          : negatif.n === positif.n
            ? `Les deux demi-équations échangent le même nombre d'électrons : les quantités de matière sont égales, et |Δm₁|/M₁ = |Δm₂|/M₂. C'est le cas simple, celui de la pile Daniell.`
            : `Attention : ${negatif.metal} cède ${negatif.n} électrons mais ${positif.ion} n'en capte que ${positif.n}. Les quantités de matière ne sont PAS égales — il faut repasser par les coefficients de l'équation-bilan. C'est exactement le piège que tend l'examinateur.`}
      </Verdict>
    </div>
  );
}
