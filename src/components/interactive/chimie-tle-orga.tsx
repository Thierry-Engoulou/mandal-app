import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict, fmt } from "./controls";

/** Simulations du programme de Chimie Terminale C, D et E — module 1, chimie organique. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* Chapitre 1 — Classe d'un alcool                                     */
/* ------------------------------------------------------------------ */

type Alcool = {
  value: string;
  label: string;
  formule: string;
  nom: string;
  voisins: number;
  classe: "primaire" | "secondaire" | "tertiaire";
  hydrogenes: number;
};

const ALCOOL_DEFAUT: Alcool = {
  value: "ethanol",
  label: "Éthanol",
  formule: "CH₃ — CH₂ — OH",
  nom: "éthanol",
  voisins: 1,
  classe: "primaire",
  hydrogenes: 2,
};

const ALCOOLS: ReadonlyArray<Alcool> = [
  ALCOOL_DEFAUT,
  {
    value: "butan1ol",
    label: "Butan-1-ol",
    formule: "CH₃ — CH₂ — CH₂ — CH₂ — OH",
    nom: "butan-1-ol",
    voisins: 1,
    classe: "primaire",
    hydrogenes: 2,
  },
  {
    value: "propan2ol",
    label: "Propan-2-ol",
    formule: "CH₃ — CHOH — CH₃",
    nom: "propan-2-ol",
    voisins: 2,
    classe: "secondaire",
    hydrogenes: 1,
  },
  {
    value: "butan2ol",
    label: "Butan-2-ol",
    formule: "CH₃ — CHOH — CH₂ — CH₃",
    nom: "butan-2-ol",
    voisins: 2,
    classe: "secondaire",
    hydrogenes: 1,
  },
  {
    value: "mp2ol",
    label: "2-méthylpropan-2-ol",
    formule: "(CH₃)₃C — OH",
    nom: "2-méthylpropan-2-ol",
    voisins: 3,
    classe: "tertiaire",
    hydrogenes: 0,
  },
  {
    value: "mp1ol",
    label: "2-méthylpropan-1-ol",
    formule: "(CH₃)₂CH — CH₂ — OH",
    nom: "2-méthylpropan-1-ol",
    voisins: 1,
    classe: "primaire",
    hydrogenes: 2,
  },
];

function couleurClasse(c: string) {
  return c === "primaire" ? PALETTE.green : c === "secondaire" ? PALETTE.blue : PALETTE.red;
}

export function ClasseAlcool() {
  const [choix, setChoix] = useState("ethanol");
  const a = ALCOOLS.find((x) => x.value === choix) ?? ALCOOL_DEFAUT;

  const W = 440;
  const H = 180;
  const cx = W / 2;
  const cy = 96;

  // les voisins carbonés disposés en éventail sous le carbone fonctionnel
  const angles = a.voisins === 1 ? [200] : a.voisins === 2 ? [205, 335] : [200, 270, 340];

  return (
    <div className="space-y-3">
      <Choice
        label="Choisis un alcool"
        value={choix}
        options={ALCOOLS.map((o) => ({ value: o.value, label: o.label }))}
        onChange={setChoix}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={cx} y={24} textAnchor="middle" fontSize={15} fill={PALETTE.ink}>
          {a.formule}
        </text>

        <line x1={cx} y1={cy} x2={cx} y2={cy - 34} stroke={PALETTE.ink} strokeWidth={2} />
        <circle cx={cx} cy={cy - 44} r={15} fill={PALETTE.orange} />
        <text x={cx} y={cy - 39} textAnchor="middle" fontSize={12} fontWeight={700} fill="#ffffff">
          OH
        </text>

        <circle cx={cx} cy={cy} r={19} fill={couleurClasse(a.classe)} />
        <text x={cx} y={cy + 5} textAnchor="middle" fontSize={14} fontWeight={700} fill="#ffffff">
          C
        </text>

        {angles.map((deg, i) => {
          const r = (deg * Math.PI) / 180;
          const x = cx + 62 * Math.cos(r);
          const y = cy - 62 * Math.sin(r);
          return (
            <g key={i}>
              <line x1={cx} y1={cy} x2={x} y2={y} stroke={PALETTE.slate} strokeWidth={2} />
              <circle cx={x} cy={y} r={13} fill={PALETTE.slate} />
              <text
                x={x}
                y={y + 4}
                textAnchor="middle"
                fontSize={11}
                fontWeight={700}
                fill="#ffffff"
              >
                C
              </text>
            </g>
          );
        })}

        {Array.from({ length: a.hydrogenes }).map((_, i) => {
          const x = cx + (i === 0 ? 50 : -50);
          const y = cy + 44;
          return (
            <g key={`h${i}`}>
              <line x1={cx} y1={cy} x2={x} y2={y} stroke={PALETTE.grid} strokeWidth={1.6} />
              <circle
                cx={x}
                cy={y}
                r={10}
                fill="#ffffff"
                stroke={PALETTE.gridStrong}
                strokeWidth={1.6}
              />
              <text x={x} y={y + 4} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
                H
              </text>
            </g>
          );
        })}

        <text x={cx} y={H - 10} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          en couleur : le carbone fonctionnel, en gris : ses voisins carbonés
        </text>
      </Board>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Voisins carbonés" value={String(a.voisins)} color={PALETTE.slate} />
        <Stat label="Hydrogènes restants" value={String(a.hydrogenes)} />
        <Stat label="Classe" value={a.classe} color={couleurClasse(a.classe)} />
      </div>

      <Verdict tone={a.classe === "tertiaire" ? "bad" : "ok"}>
        {a.classe === "tertiaire"
          ? "Alcool tertiaire : son carbone fonctionnel ne porte plus aucun hydrogène. Il n'y a donc rien à lui retirer, et l'oxydation ménagée est impossible."
          : a.classe === "primaire"
            ? "Alcool primaire : deux hydrogènes restent sur le carbone fonctionnel. Il pourra s'oxyder deux fois, en aldéhyde puis en acide carboxylique."
            : "Alcool secondaire : un seul hydrogène sur le carbone fonctionnel. Il s'oxyde une fois, en cétone, et s'arrête là."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 1 — Oxydation ménagée et tests d'identification            */
/* ------------------------------------------------------------------ */

export function OxydationAlcool() {
  const [classe, setClasse] = useState<"primaire" | "secondaire" | "tertiaire">("primaire");
  const [oxydant, setOxydant] = useState<"defaut" | "exces">("defaut");
  const [reactif, setReactif] = useState<"aucun" | "dnph" | "tollens" | "papier">("aucun");

  const produit =
    classe === "tertiaire"
      ? "aucun produit"
      : classe === "secondaire"
        ? "cétone"
        : oxydant === "defaut"
          ? "aldéhyde"
          : "acide carboxylique";

  const carbonyle = produit === "cétone" || produit === "aldéhyde";
  const dnphPositif = carbonyle;
  const tollensPositif = produit === "aldéhyde";
  const papierPositif = produit === "acide carboxylique";

  const resultat =
    reactif === "aucun"
      ? null
      : reactif === "dnph"
        ? { ok: dnphPositif, texte: dnphPositif ? "précipité jaune orangé" : "rien ne se passe" }
        : reactif === "tollens"
          ? { ok: tollensPositif, texte: tollensPositif ? "miroir d'argent" : "rien ne se passe" }
          : {
              ok: papierPositif,
              texte: papierPositif ? "le papier rougit" : "le papier ne change pas",
            };

  const W = 440;
  const H = 190;
  const reaction = classe !== "tertiaire";

  return (
    <div className="space-y-3">
      <Panel>
        <Choice
          label="Classe de l'alcool"
          value={classe}
          options={[
            { value: "primaire", label: "Primaire" },
            { value: "secondaire", label: "Secondaire" },
            { value: "tertiaire", label: "Tertiaire" },
          ]}
          onChange={setClasse}
        />
        <Choice
          label="Quantité d'oxydant"
          value={oxydant}
          options={[
            { value: "defaut", label: "En défaut" },
            { value: "exces", label: "En excès" },
          ]}
          onChange={setOxydant}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={30} y={32} fontSize={12} fill={PALETTE.slate}>
          dichromate en milieu acide
        </text>
        <rect
          x={30}
          y={44}
          width={120}
          height={70}
          rx={6}
          fill={reaction ? "#16a34a" : "#ea580c"}
          opacity={0.75}
        />
        <text x={90} y={85} textAnchor="middle" fontSize={13} fontWeight={700} fill="#ffffff">
          {reaction ? "vert" : "orange"}
        </text>
        <text x={90} y={132} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {reaction ? "la solution a viré" : "aucun changement"}
        </text>

        <g>
          <line x1={166} y1={79} x2={230} y2={79} stroke={PALETTE.slate} strokeWidth={2} />
          <polygon points="238,79 228,74 228,84" fill={PALETTE.slate} />
        </g>

        <rect
          x={252}
          y={44}
          width={158}
          height={70}
          rx={6}
          fill={reaction ? "#eff6ff" : "#f8fafc"}
          stroke={PALETTE.gridStrong}
          strokeWidth={1.6}
        />
        <text
          x={331}
          y={78}
          textAnchor="middle"
          fontSize={13}
          fontWeight={700}
          fill={reaction ? PALETTE.blue : PALETTE.slate}
        >
          {produit}
        </text>
        <text x={331} y={97} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {produit === "aldéhyde"
            ? "R — CHO"
            : produit === "cétone"
              ? "R — CO — R′"
              : produit === "acide carboxylique"
                ? "R — COOH"
                : "—"}
        </text>
        <text x={331} y={132} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          produit obtenu
        </text>
      </Board>

      <Choice
        label="Teste le produit"
        value={reactif}
        options={[
          { value: "aucun", label: "Aucun test" },
          { value: "dnph", label: "2,4-DNPH" },
          { value: "tollens", label: "Tollens" },
          { value: "papier", label: "Papier pH" },
        ]}
        onChange={setReactif}
      />

      {resultat ? (
        <Verdict tone={resultat.ok ? "ok" : "warn"}>
          Résultat du test : {resultat.texte}.{" "}
          {reactif === "dnph"
            ? "La 2,4-DNPH révèle un groupe carbonyle, aldéhyde ou cétone, sans les distinguer."
            : reactif === "tollens"
              ? "Le réactif de Tollens ne réagit qu'avec les aldéhydes, jamais avec les cétones."
              : "Le papier pH ne rougit que si l'oxydation est allée jusqu'à l'acide carboxylique."}
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Choisis un test pour identifier le produit. Enchaîne-les dans le bon ordre : d&apos;abord
          la 2,4-DNPH, puis Tollens si elle est positive.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 3 — Équilibre d'estérification                             */
/* ------------------------------------------------------------------ */

export function EsterificationEquilibre() {
  const [classe, setClasse] = useState<"primaire" | "secondaire" | "tertiaire">("primaire");
  const [nAcide, setNAcide] = useState(1);
  const [nAlcool, setNAlcool] = useState(1);
  const [temperature, setTemperature] = useState(60);
  const [catalyseur, setCatalyseur] = useState<"non" | "oui">("oui");

  // la constante d'equilibre ne depend que de la classe de l'alcool
  const K = classe === "primaire" ? 4.0 : classe === "secondaire" ? 2.25 : 0.0028;

  // resolution de K = x^2 / ((a-x)(b-x)) par dichotomie sur x
  const a = nAcide;
  const b = nAlcool;
  let lo = 0;
  let hi = Math.min(a, b);
  for (let i = 0; i < 60; i++) {
    const x = (lo + hi) / 2;
    const q = (x * x) / Math.max((a - x) * (b - x), 1e-12);
    if (q < K) lo = x;
    else hi = x;
  }
  const xEq = (lo + hi) / 2;
  const rendement = (xEq / Math.min(a, b)) * 100;

  // le temps n'agit que sur la vitesse : duree indicative pour atteindre l'equilibre
  const vitesse = Math.pow(2, (temperature - 20) / 10) * (catalyseur === "oui" ? 25 : 1);
  const duree = 900 / vitesse;

  const W = 440;
  const H = 230;
  const pad = 34;
  const tMax = Math.max(duree * 3, 1);
  const sx = (t: number) => pad + (t / tMax) * (W - 2 * pad);
  const sy = (n: number) => H - pad - (n / Math.max(a, b, 1)) * (H - 2 * pad);

  const pts: string[] = [];
  for (let i = 0; i <= 120; i++) {
    const t = (tMax * i) / 120;
    const n = xEq * (1 - Math.exp(-t / Math.max(duree / 3, 1e-6)));
    pts.push(`${sx(t).toFixed(1)},${sy(n).toFixed(1)}`);
  }

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line x1={pad} y1={sy(0)} x2={W - pad} y2={sy(0)} stroke={PALETTE.axis} strokeWidth={1.4} />
        <line x1={pad} y1={sy(0)} x2={pad} y2={pad - 6} stroke={PALETTE.axis} strokeWidth={1.4} />
        <line
          x1={pad}
          y1={sy(xEq)}
          x2={W - pad}
          y2={sy(xEq)}
          stroke={PALETTE.red}
          strokeWidth={1.4}
          strokeDasharray="6 5"
        />
        <text
          x={W - pad - 4}
          y={sy(xEq) - 8}
          textAnchor="end"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.red}
        >
          palier : {fmt(xEq, 2)} mol
        </text>
        <polyline points={pts.join(" ")} fill="none" stroke={PALETTE.blue} strokeWidth={2.8} />
        <text x={pad + 6} y={pad + 4} fontSize={11} fill={PALETTE.slate}>
          ester formé (mol)
        </text>
        <text x={W - pad} y={H - 12} textAnchor="end" fontSize={11} fill={PALETTE.slate}>
          temps
        </text>
      </Board>

      <Choice
        label="Classe de l'alcool"
        value={classe}
        options={[
          { value: "primaire", label: "Primaire" },
          { value: "secondaire", label: "Secondaire" },
          { value: "tertiaire", label: "Tertiaire" },
        ]}
        onChange={setClasse}
      />

      <Panel>
        <Ctrl
          label="Acide au départ"
          value={nAcide}
          min={0.5}
          max={3}
          step={0.1}
          onChange={setNAcide}
          display={`${fmt(nAcide, 1)} mol`}
        />
        <Ctrl
          label="Alcool au départ"
          value={nAlcool}
          min={0.5}
          max={3}
          step={0.1}
          onChange={setNAlcool}
          display={`${fmt(nAlcool, 1)} mol`}
          color={PALETTE.purple}
        />
        <Ctrl
          label="Température"
          value={temperature}
          min={20}
          max={100}
          step={5}
          onChange={setTemperature}
          display={`${fmt(temperature, 0)} °C`}
          color={PALETTE.red}
        />
        <Choice
          label="Catalyseur"
          value={catalyseur}
          options={[
            { value: "oui", label: "Avec H₂SO₄" },
            { value: "non", label: "Sans catalyseur" },
          ]}
          onChange={setCatalyseur}
        />
      </Panel>

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Constante K" value={fmt(K, 2)} color={PALETTE.purple} />
        <Stat label="Rendement" value={`${fmt(rendement, 0)} %`} color={PALETTE.red} />
        <Stat label="Temps indicatif" value={duree < 1 ? "< 1 h" : `${fmt(duree, 0)} h`} />
      </div>

      <Verdict tone="ok">
        La température et le catalyseur changent la <strong>pente</strong> de la courbe, donc le
        temps, mais jamais la hauteur du palier. Seul un excès de réactif, visible sur le rendement,
        déplace vraiment l&apos;équilibre.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 5 — Les trois formes d'un acide α-aminé                    */
/* ------------------------------------------------------------------ */

export function AcideAminePh() {
  const [ph, setPh] = useState(6);

  const pK1 = 2.3; // COOH / COO−
  const pK2 = 9.7; // NH3+ / NH2
  const phi = (pK1 + pK2) / 2;

  // fractions des trois formes
  const r1 = Math.pow(10, ph - pK1);
  const r2 = Math.pow(10, ph - pK2);
  const cation = 1;
  const zwit = r1;
  const anion = r1 * r2;
  const tot = cation + zwit + anion;
  const fCat = cation / tot;
  const fZwi = zwit / tot;
  const fAni = anion / tot;
  const charge = fCat * 1 + fAni * -1;

  const W = 440;
  const H = 210;
  const pad = 32;
  const sx = (p: number) => pad + (p / 14) * (W - 2 * pad);
  const barre = (f: number) => Math.max(2, f * 108);

  const dominante = fZwi >= fCat && fZwi >= fAni ? "zwitterion" : fCat > fAni ? "cation" : "anion";

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {[
          { x: 0.22, f: fCat, c: PALETTE.red, t: "cation", s: "R—CH(NH₃⁺)—COOH" },
          { x: 0.5, f: fZwi, c: PALETTE.green, t: "zwitterion", s: "R—CH(NH₃⁺)—COO⁻" },
          { x: 0.78, f: fAni, c: PALETTE.blue, t: "anion", s: "R—CH(NH₂)—COO⁻" },
        ].map((o, i) => (
          <g key={i}>
            <rect
              x={o.x * W - 44}
              y={150 - barre(o.f)}
              width={88}
              height={barre(o.f)}
              rx={4}
              fill={o.c}
              opacity={0.85}
            />
            <text x={o.x * W} y={168} textAnchor="middle" fontSize={12} fontWeight={700} fill={o.c}>
              {o.t}
            </text>
            <text x={o.x * W} y={184} textAnchor="middle" fontSize={9.5} fill={PALETTE.slate}>
              {o.s}
            </text>
            <text
              x={o.x * W}
              y={144 - barre(o.f)}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill={o.c}
            >
              {fmt(o.f * 100, 0)} %
            </text>
          </g>
        ))}
        <line
          x1={pad}
          y1={H - 14}
          x2={W - pad}
          y2={H - 14}
          stroke={PALETTE.axis}
          strokeWidth={1.2}
        />
        {[0, 2, 4, 6, 8, 10, 12, 14].map((p) => (
          <text key={p} x={sx(p)} y={H - 2} textAnchor="middle" fontSize={9} fill={PALETTE.slate}>
            {p}
          </text>
        ))}
        <circle cx={sx(ph)} cy={H - 14} r={5} fill={PALETTE.orange} />
      </Board>

      <Ctrl
        label="pH de la solution"
        value={ph}
        min={0}
        max={14}
        step={0.1}
        onChange={setPh}
        display={fmt(ph, 1)}
        color={PALETTE.orange}
      />

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Forme dominante" value={dominante} color={PALETTE.green} />
        <Stat label="Charge moyenne" value={fmt(charge, 2)} color={PALETTE.purple} />
        <Stat label="Point isoélectrique" value={fmt(phi, 1)} />
      </div>

      <Verdict tone={Math.abs(ph - phi) < 0.4 ? "ok" : "warn"}>
        {Math.abs(ph - phi) < 0.4
          ? `Tu es au point isoélectrique, pH = ${fmt(phi, 1)}. Le zwitterion est très majoritaire et la charge moyenne est pratiquement nulle.`
          : "Déplace le pH jusqu'à rendre la charge moyenne nulle : tu trouveras le point isoélectrique, à mi-chemin entre les deux pKa."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 6 — Chiralité d'un carbone                                 */
/* ------------------------------------------------------------------ */

const GROUPES = ["H", "CH₃", "OH", "COOH", "NH₂", "C₂H₅"] as const;

export function ChiraliteCarbone() {
  const [g1, setG1] = useState("H");
  const [g2, setG2] = useState("CH₃");
  const [g3, setG3] = useState("OH");
  const [g4, setG4] = useState("COOH");

  const liste = [g1, g2, g3, g4];
  const distincts = new Set(liste).size;
  const chiral = distincts === 4;

  const W = 440;
  const H = 230;
  const cx1 = 118;
  const cx2 = 322;
  const cy = 112;

  function dessine(cx: number, miroir: boolean) {
    const places = [
      { dx: 0, dy: -62 },
      { dx: miroir ? 58 : -58, dy: 26 },
      { dx: miroir ? -58 : 58, dy: 26 },
      { dx: 0, dy: 62 },
    ];
    return (
      <g>
        {places.map((p, i) => {
          const g = liste[i] ?? "";
          const x = cx + p.dx;
          const y = cy + p.dy;
          return (
            <g key={i}>
              <line x1={cx} y1={cy} x2={x} y2={y} stroke={PALETTE.slate} strokeWidth={1.8} />
              <circle
                cx={x}
                cy={y}
                r={17}
                fill="#ffffff"
                stroke={PALETTE.gridStrong}
                strokeWidth={1.8}
              />
              <text
                x={x}
                y={y + 4}
                textAnchor="middle"
                fontSize={10.5}
                fontWeight={700}
                fill={PALETTE.ink}
              >
                {g}
              </text>
            </g>
          );
        })}
        <circle cx={cx} cy={cy} r={16} fill={chiral ? PALETTE.red : PALETTE.slate} />
        <text x={cx} y={cy + 5} textAnchor="middle" fontSize={13} fontWeight={700} fill="#ffffff">
          C
        </text>
      </g>
    );
  }

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <line
          x1={W / 2}
          y1={14}
          x2={W / 2}
          y2={H - 28}
          stroke={PALETTE.blue}
          strokeWidth={2}
          strokeDasharray="7 5"
        />
        <text x={W / 2} y={H - 10} textAnchor="middle" fontSize={11} fill={PALETTE.blue}>
          miroir
        </text>
        {dessine(cx1, false)}
        {dessine(cx2, true)}
      </Board>

      <Panel>
        <Choice
          label="Groupe du haut"
          value={g1}
          options={GROUPES.map((g) => ({ value: g as string, label: g }))}
          onChange={setG1}
        />
        <Choice
          label="Groupe de gauche"
          value={g2}
          options={GROUPES.map((g) => ({ value: g as string, label: g }))}
          onChange={setG2}
        />
        <Choice
          label="Groupe de droite"
          value={g3}
          options={GROUPES.map((g) => ({ value: g as string, label: g }))}
          onChange={setG3}
        />
        <Choice
          label="Groupe du bas"
          value={g4}
          options={GROUPES.map((g) => ({ value: g as string, label: g }))}
          onChange={setG4}
        />
      </Panel>

      <div className="grid grid-cols-2 gap-2">
        <Stat
          label="Groupes différents"
          value={`${distincts} sur 4`}
          color={chiral ? PALETTE.red : PALETTE.slate}
        />
        <Stat label="Stéréoisomères" value={chiral ? "2 énantiomères" : "une seule molécule"} />
      </div>

      <Verdict tone={chiral ? "ok" : "warn"}>
        {chiral
          ? "Les quatre groupes sont différents : le carbone est asymétrique et la molécule est chirale. Les deux images ne sont pas superposables, ce sont deux énantiomères."
          : "Deux groupes au moins sont identiques, donc le carbone n'est pas asymétrique. Fais tourner mentalement l'image de droite : elle se superpose à celle de gauche, c'est la même molécule."}
      </Verdict>

      <p className="text-xs text-muted-foreground">
        Rappel : un mélange à parts égales des deux énantiomères s&apos;appelle un mélange
        racémique, et son pouvoir rotatoire est nul. La valeur {fmt(clamp(distincts, 0, 4), 0)}{" "}
        ci-dessus compte les groupes réellement distincts.
      </p>
    </div>
  );
}
