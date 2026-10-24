import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict } from "./controls";

/** Chimie 1ère C, D et E — chapitres 9 et 10 : benzène et composés oxygénés. */

/** Sommets d'un hexagone régulier, pointe en haut, numérotés dans le sens horaire. */
function sommets(cx: number, cy: number, r: number) {
  return Array.from({ length: 6 }, (_, i) => {
    const a = (-90 + 60 * i) * (Math.PI / 180);
    return { x: cx + r * Math.cos(a), y: cy + r * Math.sin(a) };
  });
}

/* ------------------------------------------------------------------ */
/* Chapitre 9 — Le nuage délocalisé                                    */
/* ------------------------------------------------------------------ */

export function BenzeneStructure() {
  const [modele, setModele] = useState<"kekule" | "nuage">("kekule");
  const [chlores, setChlores] = useState(false);

  const W = 440;
  const H = 250;
  const r = 52;

  function cycle(cx: number, cy: number, kekule: boolean, decale: boolean) {
    const p = sommets(cx, cy, r);
    return (
      <g>
        {p.map((a, i) => {
          const b = p[(i + 1) % 6] ?? a;
          const doubleIci = kekule && (decale ? i % 2 === 1 : i % 2 === 0);
          return (
            <g key={i}>
              <line x1={a.x} y1={a.y} x2={b.x} y2={b.y} stroke={PALETTE.ink} strokeWidth={2.2} />
              {doubleIci ? (
                <line
                  x1={cx + (a.x - cx) * 0.8}
                  y1={cy + (a.y - cy) * 0.8}
                  x2={cx + (b.x - cx) * 0.8}
                  y2={cy + (b.y - cy) * 0.8}
                  stroke={PALETTE.ink}
                  strokeWidth={2.2}
                />
              ) : null}
            </g>
          );
        })}
        {kekule ? null : (
          <circle
            cx={cx}
            cy={cy}
            r={r * 0.58}
            fill="none"
            stroke={PALETTE.blue}
            strokeWidth={2.6}
          />
        )}
        {chlores
          ? [0, 1].map((k) => {
              const s = p[k] ?? p[0];
              if (!s) return null;
              const dx = (s.x - cx) * 0.46;
              const dy = (s.y - cy) * 0.46;
              return (
                <g key={`cl${k}`}>
                  <line
                    x1={s.x}
                    y1={s.y}
                    x2={s.x + dx}
                    y2={s.y + dy}
                    stroke={PALETTE.green}
                    strokeWidth={2}
                  />
                  <text
                    x={s.x + dx * 1.7}
                    y={s.y + dy * 1.7 + 4}
                    textAnchor="middle"
                    fontSize={12}
                    fontWeight={700}
                    fill={PALETTE.green}
                  >
                    Cl
                  </text>
                </g>
              );
            })
          : null}
      </g>
    );
  }

  const deuxComposes = modele === "kekule" && chlores;

  return (
    <div className="space-y-3">
      <Choice
        label="Modèle de la molécule"
        value={modele}
        options={[
          { value: "kekule" as const, label: "Kekulé (liaisons alternées)" },
          { value: "nuage" as const, label: "Nuage délocalisé" },
        ]}
        onChange={setModele}
      />
      <Choice
        value={chlores ? "oui" : "non"}
        options={[
          { value: "non", label: "Benzène seul" },
          { value: "oui", label: "Poser 2 Cl sur deux carbones voisins" },
        ]}
        onChange={(v) => setChlores(v === "oui")}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        {deuxComposes ? (
          <g>
            {cycle(118, 110, true, false)}
            {cycle(322, 110, true, true)}
            <text
              x={118}
              y={198}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill={PALETTE.red}
            >
              composé n° 1
            </text>
            <text x={118} y={214} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
              les deux Cl sur une liaison DOUBLE
            </text>
            <text
              x={322}
              y={198}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill={PALETTE.red}
            >
              composé n° 2
            </text>
            <text x={322} y={214} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
              les deux Cl sur une liaison SIMPLE
            </text>
            <text
              x={W / 2}
              y={238}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill={PALETTE.red}
            >
              Kekulé prévoit DEUX orthodichlorobenzènes — or l&apos;expérience n&apos;en trouve
              qu&apos;UN
            </text>
          </g>
        ) : (
          <g>
            {cycle(220, 112, modele === "kekule", false)}
            <g fontSize={11} fill={PALETTE.slate}>
              <text x={30} y={56}>
                C—C simple : 154 pm
              </text>
              <text x={30} y={78} fontWeight={700} fill={PALETTE.blue}>
                benzène : 140 pm
              </text>
              <text x={30} y={100}>
                C=C double : 134 pm
              </text>
            </g>
            <text x={W / 2} y={208} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
              {modele === "kekule"
                ? "trois doubles et trois simples alternées"
                : "chaque carbone met en commun un électron : les six sont délocalisés"}
            </text>
            <text
              x={W / 2}
              y={232}
              textAnchor="middle"
              fontSize={12}
              fontWeight={700}
              fill={modele === "kekule" ? PALETTE.red : PALETTE.blue}
            >
              {modele === "kekule"
                ? "les six liaisons ne seraient pas identiques"
                : "les six liaisons sont rigoureusement identiques — c'est le noyau benzénique"}
            </text>
          </g>
        )}
      </Board>

      <Verdict tone={deuxComposes ? "bad" : modele === "nuage" ? "ok" : "warn"}>
        {deuxComposes
          ? "C'est l'expérience qui a tranché : il n'existe qu'un seul orthodichlorobenzène. Le modèle de Kekulé, qui en prévoit deux, est donc insuffisant. Passe au nuage délocalisé et repose les deux chlores."
          : modele === "nuage"
            ? "Avec le nuage délocalisé, les six liaisons sont équivalentes : les deux chlores donnent un seul et même composé, quels que soient les carbones voisins choisis. Le paradoxe disparaît."
            : "La longueur de 140 pm est le premier indice : elle n'est ni celle d'une simple, ni celle d'une double. Pose maintenant deux chlores sur deux carbones voisins pour voir le problème apparaître."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 9 — Ortho, méta, para                                      */
/* ------------------------------------------------------------------ */

const GROUPES_AR = [
  { value: "rien", label: "—", texte: "", prefixe: "" },
  { value: "me", label: "CH₃", texte: "CH₃", prefixe: "méthyl" },
  { value: "no2", label: "NO₂", texte: "NO₂", prefixe: "nitro" },
  { value: "cl", label: "Cl", texte: "Cl", prefixe: "chloro" },
  { value: "oh", label: "OH", texte: "OH", prefixe: "hydroxy" },
] as const;

type GroupeAr = (typeof GROUPES_AR)[number]["value"];

function infoGroupe(id: GroupeAr) {
  return GROUPES_AR.find((g) => g.value === id) ?? GROUPES_AR[0];
}

const MULT = ["", "", "di", "tri", "tétra", "penta", "hexa"];

function nommerAromatique(occupe: ReadonlyArray<GroupeAr>): {
  nom: string;
  locants: number[];
  relation: string;
} {
  const subs = occupe.map((g, i) => ({ pos: i, g })).filter((s) => s.g !== "rien");
  if (subs.length === 0) return { nom: "benzène", locants: [], relation: "" };

  let meilleur: { loc: number[]; map: Array<{ n: number; g: GroupeAr }> } | null = null;
  for (const sens of [1, -1]) {
    for (let depart = 0; depart < 6; depart++) {
      const map = subs.map((s) => ({
        n: (((s.pos - depart) * sens + 6) % 6) + 1,
        g: s.g,
      }));
      const loc = map.map((m) => m.n).sort((a, b) => a - b);
      if (!meilleur) {
        meilleur = { loc, map };
        continue;
      }
      for (let i = 0; i < loc.length; i++) {
        const a = loc[i] ?? 0;
        const b = meilleur.loc[i] ?? 0;
        if (a < b) {
          meilleur = { loc, map };
          break;
        }
        if (a > b) break;
      }
    }
  }
  const choisi = meilleur ?? { loc: [], map: [] };

  const parPrefixe = new Map<string, number[]>();
  for (const m of choisi.map) {
    const p = infoGroupe(m.g).prefixe;
    const l = parPrefixe.get(p) ?? [];
    l.push(m.n);
    parPrefixe.set(p, l);
  }
  const seul = subs.length === 1;
  const morceaux = [...parPrefixe.entries()]
    .sort((a, b) => a[0].localeCompare(b[0], "fr"))
    .map(([p, ls]) => {
      const tri = [...ls].sort((a, b) => a - b);
      if (seul) return p;
      return `${tri.join(",")}-${MULT[tri.length] ?? ""}${p}`;
    });

  let relation = "";
  if (choisi.loc.length === 2) {
    const a = choisi.loc[0] ?? 1;
    const b = choisi.loc[1] ?? 1;
    const ecart = Math.min(b - a, 6 - (b - a));
    relation = ecart === 1 ? "ortho (1,2)" : ecart === 2 ? "méta (1,3)" : "para (1,4)";
  }

  return { nom: `${morceaux.join("-")}benzène`, locants: choisi.loc, relation };
}

export function AromatiquesNomenclature() {
  const [occupe, setOccupe] = useState<GroupeAr[]>(["me", "rien", "rien", "rien", "rien", "rien"]);
  const { nom, relation } = nommerAromatique(occupe);

  const usuel =
    occupe.filter((g) => g !== "rien").length === 1
      ? occupe.includes("me")
        ? "aussi appelé toluène"
        : occupe.includes("oh")
          ? "aussi appelé phénol"
          : ""
      : nom === "1,3,5-trinitrobenzène"
        ? "explosif connu sous le nom de benzite"
        : "";

  const W = 440;
  const H = 240;
  const p = sommets(220, 124, 54);

  function changer(i: number, v: GroupeAr) {
    setOccupe((prev) => prev.map((g, k) => (k === i ? v : g)));
  }

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {p.map((a, i) => {
          const b = p[(i + 1) % 6] ?? a;
          return (
            <line
              key={i}
              x1={a.x}
              y1={a.y}
              x2={b.x}
              y2={b.y}
              stroke={PALETTE.ink}
              strokeWidth={2.2}
            />
          );
        })}
        <circle cx={220} cy={124} r={30} fill="none" stroke={PALETTE.blue} strokeWidth={2.4} />

        {p.map((s, i) => {
          const g = occupe[i] ?? "rien";
          const info = infoGroupe(g);
          const dx = (s.x - 220) * 0.5;
          const dy = (s.y - 124) * 0.5;
          return (
            <g key={`s${i}`}>
              <circle
                cx={s.x}
                cy={s.y}
                r={9}
                fill={g === "rien" ? "#e2e8f0" : PALETTE.orange}
                stroke="#ffffff"
                strokeWidth={1.6}
              />
              <text
                x={s.x}
                y={s.y + 3}
                textAnchor="middle"
                fontSize={8}
                fill={g === "rien" ? PALETTE.slate : "#ffffff"}
              >
                {i + 1}
              </text>
              {g === "rien" ? null : (
                <g>
                  <line
                    x1={s.x}
                    y1={s.y}
                    x2={s.x + dx}
                    y2={s.y + dy}
                    stroke={PALETTE.orange}
                    strokeWidth={2}
                  />
                  <text
                    x={s.x + dx * 1.9}
                    y={s.y + dy * 1.9 + 4}
                    textAnchor="middle"
                    fontSize={12}
                    fontWeight={700}
                    fill={PALETTE.orange}
                  >
                    {info.texte}
                  </text>
                </g>
              )}
            </g>
          );
        })}

        <text
          x={W / 2}
          y={214}
          textAnchor="middle"
          fontSize={17}
          fontWeight={700}
          fill={PALETTE.ink}
        >
          {nom}
        </text>
        <text x={W / 2} y={232} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {relation ? `les deux groupes sont en ${relation}` : usuel || "benzène non substitué"}
        </text>
      </Board>

      <div className="grid gap-1.5 sm:grid-cols-3">
        {occupe.map((g, i) => (
          <Choice
            key={i}
            label={`Carbone ${i + 1}`}
            value={g}
            options={GROUPES_AR.map((o) => ({ value: o.value, label: o.label }))}
            onChange={(v) => changer(i, v)}
          />
        ))}
      </div>

      <Verdict tone="ok">
        Ortho, c&apos;est 1 et 2 ; méta, c&apos;est 1 et 3 ; para, c&apos;est 1 et 4, diamétralement
        opposés. Essaie de fabriquer le TNT : un méthyle, puis trois groupes nitro aux positions 2,
        4 et 6.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 9 — Additionner sur le benzène                             */
/* ------------------------------------------------------------------ */

export function BenzeneAddition() {
  const [reactif, setReactif] = useState<"h2" | "cl2" | "o2">("h2");
  const [temp, setTemp] = useState(25);
  const [pression, setPression] = useState(1);
  const [lumiere, setLumiere] = useState(false);
  const [cata, setCata] = useState(false);

  const okH2 = reactif === "h2" && cata && temp >= 250 && pression >= 40;
  const okCl2 = reactif === "cl2" && lumiere;
  const okO2 = reactif === "o2" && temp >= 500;
  const reagit = okH2 || okCl2 || okO2;

  const equation =
    reactif === "h2"
      ? "C₆H₆ + 3 H₂ → C₆H₁₂ (cyclohexane)"
      : reactif === "cl2"
        ? "C₆H₆ + 3 Cl₂ → C₆H₆Cl₆ (lindane)"
        : "2 C₆H₆ + 15 O₂ → 12 CO₂ + 6 H₂O";

  const W = 440;
  const H = 210;
  const p = sommets(130, 106, 50);

  return (
    <div className="space-y-3">
      <Choice
        label="Réactif"
        value={reactif}
        options={[
          { value: "h2" as const, label: "Dihydrogène H₂" },
          { value: "cl2" as const, label: "Dichlore Cl₂" },
          { value: "o2" as const, label: "Dioxygène O₂" },
        ]}
        onChange={setReactif}
      />
      <Panel>
        <Ctrl
          label="Température"
          value={temp}
          min={25}
          max={600}
          step={25}
          onChange={setTemp}
          display={`${temp} °C`}
          color={PALETTE.red}
        />
        <Ctrl
          label="Pression"
          value={pression}
          min={1}
          max={60}
          step={1}
          onChange={setPression}
          display={`${pression} bar`}
          color={PALETTE.purple}
        />
      </Panel>
      <div className="grid gap-2 sm:grid-cols-2">
        <Choice
          label="Catalyseur (nickel)"
          value={cata ? "oui" : "non"}
          options={[
            { value: "non", label: "Sans" },
            { value: "oui", label: "Avec Ni" },
          ]}
          onChange={(v) => setCata(v === "oui")}
        />
        <Choice
          label="Éclairage"
          value={lumiere ? "oui" : "non"}
          options={[
            { value: "non", label: "Obscurité" },
            { value: "oui", label: "Lumière" },
          ]}
          onChange={(v) => setLumiere(v === "oui")}
        />
      </div>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        {reagit && reactif !== "o2" ? (
          <g>
            {p.map((a, i) => {
              const b = p[(i + 1) % 6] ?? a;
              return (
                <line
                  key={i}
                  x1={a.x}
                  y1={a.y}
                  x2={b.x}
                  y2={b.y}
                  stroke={PALETTE.green}
                  strokeWidth={2.4}
                />
              );
            })}
            <text
              x={130}
              y={110}
              textAnchor="middle"
              fontSize={11}
              fontWeight={700}
              fill={PALETTE.green}
            >
              {reactif === "h2" ? "C₆H₁₂" : "C₆H₆Cl₆"}
            </text>
            <text x={130} y={176} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
              cycle saturé, NON plan
            </text>
          </g>
        ) : (
          <g>
            {p.map((a, i) => {
              const b = p[(i + 1) % 6] ?? a;
              return (
                <line
                  key={i}
                  x1={a.x}
                  y1={a.y}
                  x2={b.x}
                  y2={b.y}
                  stroke={PALETTE.ink}
                  strokeWidth={2.2}
                />
              );
            })}
            <circle cx={130} cy={106} r={28} fill="none" stroke={PALETTE.blue} strokeWidth={2.4} />
            <text x={130} y={176} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
              noyau benzénique intact
            </text>
          </g>
        )}

        <text
          x={300}
          y={58}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={reagit ? PALETTE.green : PALETTE.slate}
        >
          {reagit ? "ÇA RÉAGIT" : "rien ne se passe"}
        </text>
        <foreignObject x={224} y={72} width={190} height={110}>
          <div
            style={{
              fontSize: 11,
              lineHeight: 1.45,
              color: reagit ? "#14532d" : "#64748b",
              fontFamily: "system-ui, sans-serif",
            }}
          >
            {reagit
              ? equation
              : reactif === "h2"
                ? "Pour hydrogéner le benzène il faut du nickel, 250 °C et 40 bars. Le noyau délocalisé est très stable : un alcène, lui, s'hydrogénerait à température ordinaire."
                : reactif === "cl2"
                  ? "L'addition du dichlore exige la LUMIÈRE. Sans elle, le dichlore ferait plutôt une substitution, mais il lui faudrait un catalyseur."
                  : "Il faut atteindre la température d'inflammation. Dans l'air, la combustion du benzène est de toute façon incomplète : elle dégage beaucoup de suie."}
          </div>
        </foreignObject>
      </Board>

      <Verdict tone={reagit ? "ok" : "warn"}>
        {reagit
          ? "Le benzène fixe les trois molécules d'un coup : les additions sur le noyau benzénique se font EN UNE SEULE ÉTAPE. C'est le contraire des substitutions, qui se font par étapes successives."
          : "Le benzène est insaturé mais il donne très peu de réactions d'addition : le nuage délocalisé le rend trop stable. Il faut des conditions sévères pour l'ouvrir."}
      </Verdict>

      <Verdict tone="bad">
        Le benzène est toxique et cancérigène. Au laboratoire, on ne le manipule qu&apos;en petites
        quantités et sous une hotte.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 9 — Substituer sur le benzène                              */
/* ------------------------------------------------------------------ */

type ReacSub = {
  value: string;
  label: string;
  catalyseur: string;
  groupe: string;
  sortant: string;
  produits: ReadonlyArray<string>;
  note: string;
};

const SUB_DEFAUT: ReacSub = {
  value: "br2",
  label: "Dibrome Br₂",
  catalyseur: "FeBr₃",
  groupe: "Br",
  sortant: "HBr",
  produits: ["C₆H₅Br", "C₆H₄Br₂", "C₆H₃Br₃"],
  note: "Le produit majoritaire est le monobromobenzène, accompagné de dérivés polysubstitués.",
};

const REACTIFS_SUB: ReadonlyArray<ReacSub> = [
  SUB_DEFAUT,
  {
    value: "cl2",
    label: "Dichlore Cl₂",
    catalyseur: "FeCl₃, AlCl₃ ou I₂",
    groupe: "Cl",
    sortant: "HCl",
    produits: ["C₆H₅Cl", "C₆H₄Cl₂", "C₆H₃Cl₃"],
    note: "Attention : le MÊME dichlore fait une ADDITION à la lumière, et une SUBSTITUTION avec catalyseur. Lis toujours les conditions.",
  },
  {
    value: "hno3",
    label: "Acide nitrique HNO₃",
    catalyseur: "H₂SO₄ concentré (mélange sulfonitrique)",
    groupe: "NO₂",
    sortant: "H₂O",
    produits: ["C₆H₅NO₂", "C₆H₄(NO₂)₂", "C₆H₃(NO₂)₃"],
    note: "Le mononitrobenzène sert en parfumerie ; le 1,3,5-trinitrobenzène est l'explosif appelé benzite. Le même procédé sur le toluène donne le TNT.",
  },
  {
    value: "ch3cl",
    label: "Chloro­méthane CH₃Cl",
    catalyseur: "AlCl₃",
    groupe: "CH₃",
    sortant: "HCl",
    produits: ["C₆H₅—CH₃", "C₆H₄(CH₃)₂", "C₆H₃(CH₃)₃"],
    note: "C'est la réaction de Friedel et Crafts, ou alkylation. Avec CH₃Cl, elle donne le toluène : voilà comment on le fabrique.",
  },
];

export function BenzeneSubstitution() {
  const [choix, setChoix] = useState("br2");
  const [etape, setEtape] = useState(1);
  const [avecCata, setAvecCata] = useState(true);
  const r = REACTIFS_SUB.find((x) => x.value === choix) ?? SUB_DEFAUT;

  const addition = r.value === "cl2" && !avecCata;
  const produit = addition ? "C₆H₆Cl₆ (lindane)" : (r.produits[etape - 1] ?? r.produits[0] ?? "");

  const W = 440;
  const H = 242;
  const p = sommets(130, 118, 50);
  const nbGroupes = addition ? 6 : etape;

  return (
    <div className="space-y-3">
      <Choice
        label="Réactif"
        value={choix}
        options={REACTIFS_SUB.map((o) => ({ value: o.value, label: o.label }))}
        onChange={(v) => {
          setChoix(v);
          setEtape(1);
        }}
      />
      <Choice
        label={r.value === "cl2" ? "Conditions" : "Catalyseur"}
        value={avecCata ? "oui" : "non"}
        options={[
          { value: "oui", label: `Avec ${r.catalyseur}` },
          {
            value: "non",
            label: r.value === "cl2" ? "Sans, mais à la lumière" : "Sans catalyseur",
          },
        ]}
        onChange={(v) => setAvecCata(v === "oui")}
      />
      {avecCata ? (
        <Ctrl
          label="Étape de substitution"
          value={etape}
          min={1}
          max={3}
          step={1}
          onChange={setEtape}
          display={`${etape} groupe${etape > 1 ? "s" : ""} fixé${etape > 1 ? "s" : ""}`}
          color={PALETTE.orange}
        />
      ) : null}

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        {p.map((a, i) => {
          const b = p[(i + 1) % 6] ?? a;
          return (
            <line
              key={i}
              x1={a.x}
              y1={a.y}
              x2={b.x}
              y2={b.y}
              stroke={addition ? PALETTE.red : PALETTE.ink}
              strokeWidth={2.2}
            />
          );
        })}
        {addition ? null : (
          <circle cx={130} cy={118} r={28} fill="none" stroke={PALETTE.blue} strokeWidth={2.4} />
        )}

        {p.slice(0, nbGroupes).map((s, i) => {
          const dx = (s.x - 130) * 0.46;
          const dy = (s.y - 118) * 0.46;
          return (
            <g key={`g${i}`}>
              <line
                x1={s.x}
                y1={s.y}
                x2={s.x + dx}
                y2={s.y + dy}
                stroke={PALETTE.orange}
                strokeWidth={2}
              />
              <text
                x={s.x + dx * 1.9}
                y={s.y + dy * 1.9 + 4}
                textAnchor="middle"
                fontSize={11}
                fontWeight={700}
                fill={PALETTE.orange}
              >
                {addition ? "Cl" : r.groupe}
              </text>
            </g>
          );
        })}

        <text x={130} y={208} textAnchor="middle" fontSize={13} fontWeight={700} fill={PALETTE.ink}>
          {produit}
        </text>
        <text
          x={130}
          y={226}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={addition ? PALETTE.red : PALETTE.green}
        >
          {addition ? "ADDITION" : "SUBSTITUTION"}
        </text>

        <foreignObject x={228} y={44} width={192} height={182}>
          <div
            style={{
              fontSize: 11,
              lineHeight: 1.45,
              color: "#334155",
              fontFamily: "system-ui, sans-serif",
            }}
          >
            {addition
              ? "Sans catalyseur mais à la lumière, le dichlore s'additionne : le cycle se sature et devient non plan. Le produit est le lindane, un insecticide."
              : `Un hydrogène du cycle est remplacé par ${r.groupe}, et il se forme ${r.sortant}. Le noyau reste intact : on peut recommencer.`}
          </div>
        </foreignObject>
      </Board>

      <Verdict tone={addition ? "bad" : "ok"}>
        {addition ? (REACTIFS_SUB[1]?.note ?? "") : r.note}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 10 — Le laboratoire d'identification                       */
/* ------------------------------------------------------------------ */

type Inconnu = {
  value: string;
  nom: string;
  formule: string;
  famille: "alcool" | "aldehyde" | "cetone";
  dnph: boolean;
  schiff: boolean;
  fehling: boolean;
  tollens: boolean;
};

const INC_DEFAUT: Inconnu = {
  value: "ethanal",
  nom: "éthanal",
  formule: "CH₃ — CHO",
  famille: "aldehyde",
  dnph: true,
  schiff: true,
  fehling: true,
  tollens: true,
};

const INCONNUS: ReadonlyArray<Inconnu> = [
  INC_DEFAUT,
  {
    value: "propanone",
    nom: "propanone (acétone)",
    formule: "CH₃ — CO — CH₃",
    famille: "cetone",
    dnph: true,
    schiff: false,
    fehling: false,
    tollens: false,
  },
  {
    value: "propan2ol",
    nom: "propan-2-ol",
    formule: "CH₃ — CHOH — CH₃",
    famille: "alcool",
    dnph: false,
    schiff: false,
    fehling: false,
    tollens: false,
  },
  {
    value: "propanal",
    nom: "propanal",
    formule: "CH₃ — CH₂ — CHO",
    famille: "aldehyde",
    dnph: true,
    schiff: true,
    fehling: true,
    tollens: true,
  },
  {
    value: "butan2one",
    nom: "butan-2-one",
    formule: "CH₃ — CO — CH₂ — CH₃",
    famille: "cetone",
    dnph: true,
    schiff: false,
    fehling: false,
    tollens: false,
  },
];

type TestOxy = "dnph" | "schiff" | "fehling" | "tollens";

const LIBELLES: Record<TestOxy, { nom: string; positif: string; negatif: string }> = {
  dnph: {
    nom: "2,4-DNPH",
    positif: "précipité JAUNE",
    negatif: "rien, la solution reste limpide",
  },
  schiff: { nom: "Réactif de Schiff", positif: "la solution ROSIT", negatif: "pas de coloration" },
  fehling: {
    nom: "Liqueur de Fehling",
    positif: "précipité ROUGE BRIQUE",
    negatif: "la liqueur reste bleue",
  },
  tollens: {
    nom: "Réactif de Tollens",
    positif: "MIROIR D'ARGENT sur la paroi",
    negatif: "pas de dépôt",
  },
};

export function TestAldehydeCetone() {
  const [idx, setIdx] = useState(0);
  const [faits, setFaits] = useState<TestOxy[]>([]);
  const [reponse, setReponse] = useState<"" | "alcool" | "aldehyde" | "cetone">("");

  const x = INCONNUS[idx % INCONNUS.length] ?? INC_DEFAUT;
  const dernier = faits[faits.length - 1];

  function lancer(t: TestOxy) {
    setFaits((prev) => (prev.includes(t) ? prev : [...prev, t]));
  }

  function nouveau() {
    setIdx((i) => (i + 1) % INCONNUS.length);
    setFaits([]);
    setReponse("");
  }

  const resultat = (t: TestOxy): boolean =>
    t === "dnph" ? x.dnph : t === "schiff" ? x.schiff : t === "fehling" ? x.fehling : x.tollens;

  const minimum = x.famille === "alcool" ? 1 : 2;
  const juste = reponse === x.famille;

  const W = 440;
  const H = 180;
  const couleurTube = !dernier
    ? "#f1f5f9"
    : resultat(dernier)
      ? dernier === "dnph"
        ? "#fde047"
        : dernier === "schiff"
          ? "#f9a8d4"
          : dernier === "fehling"
            ? "#c2410c"
            : "#d4d4d8"
      : dernier === "fehling"
        ? "#3b82f6"
        : "#f1f5f9";

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
          flacon n° {idx + 1} — composé inconnu
        </text>

        <path
          d="M186 42 L254 42 L246 148 L194 148 Z"
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        <path d="M191 92 L249 92 L246 148 L194 148 Z" fill={couleurTube} opacity={0.9} />

        <text x={220} y={166} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          {dernier
            ? `${LIBELLES[dernier].nom} : ${resultat(dernier) ? LIBELLES[dernier].positif : LIBELLES[dernier].negatif}`
            : "aucun test effectué pour l'instant"}
        </text>

        <text x={28} y={54} fontSize={10} fill={PALETTE.slate}>
          tests déjà faits
        </text>
        {faits.map((t, i) => (
          <g key={t}>
            <text x={28} y={76 + i * 20} fontSize={11} fill={PALETTE.ink}>
              {LIBELLES[t].nom}
            </text>
            <text
              x={150}
              y={76 + i * 20}
              textAnchor="end"
              fontSize={11}
              fontWeight={700}
              fill={resultat(t) ? PALETTE.green : PALETTE.red}
            >
              {resultat(t) ? "+" : "−"}
            </text>
          </g>
        ))}
      </Board>

      <Choice
        label="Lance un test"
        value=""
        options={[
          { value: "dnph", label: "2,4-DNPH" },
          { value: "schiff", label: "Schiff" },
          { value: "fehling", label: "Fehling" },
          { value: "tollens", label: "Tollens" },
        ]}
        onChange={(v) => lancer(v as TestOxy)}
      />

      <Choice
        label="Annonce ta réponse"
        value={reponse}
        options={[
          { value: "alcool" as const, label: "C'est un alcool" },
          { value: "aldehyde" as const, label: "C'est un aldéhyde" },
          { value: "cetone" as const, label: "C'est une cétone" },
        ]}
        onChange={setReponse}
      />

      {reponse ? (
        <>
          <Verdict tone={juste ? "ok" : "bad"}>
            {juste
              ? `Exact : c'était du ${x.nom}, de formule ${x.formule}.`
              : `Non : c'était du ${x.nom} (${x.formule}), donc ${x.famille === "alcool" ? "un alcool" : x.famille === "aldehyde" ? "un aldéhyde" : "une cétone"}.`}
          </Verdict>
          <Verdict tone={faits.length <= minimum ? "ok" : "warn"}>
            {faits.length <= minimum
              ? `Tu as conclu en ${faits.length} test${faits.length > 1 ? "s" : ""} : c'est le minimum possible.`
              : `Tu as fait ${faits.length} tests, alors que ${minimum} suffisai${minimum > 1 ? "ent" : "t"}. La 2,4-DNPH d'abord : si elle ne précipite pas, c'est un alcool et c'est fini. Si elle précipite, un seul test de plus — Schiff, Fehling ou Tollens — tranche entre aldéhyde et cétone.`}
          </Verdict>
        </>
      ) : (
        <Verdict tone="warn">
          La 2,4-DNPH révèle le groupe carbonyle, aldéhyde ou cétone indifféremment. Schiff, Fehling
          et Tollens ne répondent qu&apos;aux aldéhydes, parce que seul l&apos;aldéhyde est
          réducteur : il peut encore s&apos;oxyder en acide.
        </Verdict>
      )}

      <Choice
        value=""
        options={[{ value: "new", label: "Changer de flacon" }]}
        onChange={() => nouveau()}
      />

      <div className="grid grid-cols-2 gap-2">
        <Stat label="Tests effectués" value={String(faits.length)} color={PALETTE.slate} />
        <Stat label="Minimum nécessaire" value={String(minimum)} color={PALETTE.green} />
      </div>
      <p className="text-[11px] text-muted-foreground">
        Astuce : commence toujours par la 2,4-DNPH, elle divise le problème en deux.
      </p>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 9 — Pourquoi les alcools bouillent-ils si haut ?           */
/* ------------------------------------------------------------------ */

type Oxygene = {
  value: string;
  label: string;
  formule: string;
  M: number;
  teb: number;
  liaisonH: boolean;
  solubilite: string;
  famille: string;
};

const OXY_PAR_DEFAUT: Oxygene = {
  value: "alcane",
  label: "Propane",
  formule: "CH₃ — CH₂ — CH₃",
  M: 44,
  teb: -42,
  liaisonH: false,
  solubilite: "insoluble",
  famille: "alcane",
};

const OXYGENES: ReadonlyArray<Oxygene> = [
  OXY_PAR_DEFAUT,
  {
    value: "aldehyde",
    label: "Propanal",
    formule: "CH₃ — CH₂ — CHO",
    M: 58,
    teb: 49,
    liaisonH: false,
    solubilite: "assez soluble",
    famille: "aldéhyde",
  },
  {
    value: "cetone",
    label: "Propanone",
    formule: "CH₃ — CO — CH₃",
    M: 58,
    teb: 56,
    liaisonH: false,
    solubilite: "miscible",
    famille: "cétone",
  },
  {
    value: "alcool",
    label: "Propan-1-ol",
    formule: "CH₃ — CH₂ — CH₂ — OH",
    M: 60,
    teb: 97,
    liaisonH: true,
    solubilite: "miscible",
    famille: "alcool",
  },
];

export function ProprietesOxygenes() {
  const [temp, setTemp] = useState(20);
  const [chaine, setChaine] = useState(3);

  const bouillent = OXYGENES.filter((o) => temp >= o.teb);
  // la solubilité d'un alcool s'effondre quand la chaîne s'allonge
  const solubleAlcool = chaine <= 3 ? "miscible" : chaine <= 5 ? "peu soluble" : "insoluble";

  const W = 440;
  const H = 240;
  const larg = 96;

  return (
    <div className="space-y-3">
      <Ctrl
        label="Température du bain"
        value={temp}
        min={-60}
        max={130}
        step={5}
        onChange={setTemp}
        display={`${temp} °C`}
        color={PALETTE.red}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        {OXYGENES.map((o, i) => {
          const x = 14 + i * (larg + 10);
          const bout = temp >= o.teb;
          return (
            <g key={o.value}>
              <text
                x={x + larg / 2}
                y={20}
                textAnchor="middle"
                fontSize={11}
                fontWeight={700}
                fill={PALETTE.ink}
              >
                {o.label}
              </text>
              <text x={x + larg / 2} y={36} textAnchor="middle" fontSize={9} fill={PALETTE.slate}>
                M = {o.M} g/mol
              </text>

              <path
                d={`M${x + 12} 48 L${x + larg - 12} 48 L${x + larg - 18} 150 L${x + 18} 150 Z`}
                fill="#f8fafc"
                stroke={PALETTE.slate}
                strokeWidth={1.6}
              />
              <path
                d={`M${x + 16} 96 L${x + larg - 16} 96 L${x + larg - 18} 150 L${x + 18} 150 Z`}
                fill={bout ? "#fed7aa" : "#dbeafe"}
                opacity={0.8}
              />
              {bout
                ? Array.from({ length: 6 }).map((_, k) => (
                    <circle
                      key={k}
                      cx={x + 28 + ((k * 19) % 46)}
                      cy={60 + ((k * 17) % 34)}
                      r={3 + (k % 2)}
                      fill="#fb923c"
                    />
                  ))
                : null}
              {o.liaisonH && !bout ? (
                <g>
                  <line
                    x1={x + 30}
                    y1={112}
                    x2={x + 48}
                    y2={126}
                    stroke={PALETTE.purple}
                    strokeWidth={1.6}
                    strokeDasharray="3 2"
                  />
                  <line
                    x1={x + 48}
                    y1={126}
                    x2={x + 66}
                    y2={112}
                    stroke={PALETTE.purple}
                    strokeWidth={1.6}
                    strokeDasharray="3 2"
                  />
                  <text
                    x={x + larg / 2}
                    y={142}
                    textAnchor="middle"
                    fontSize={8}
                    fill={PALETTE.purple}
                  >
                    liaison H
                  </text>
                </g>
              ) : null}

              <text
                x={x + larg / 2}
                y={170}
                textAnchor="middle"
                fontSize={11}
                fontWeight={700}
                fill={bout ? PALETTE.orange : PALETTE.blue}
              >
                {bout ? "BOUT" : "liquide"}
              </text>
              <text x={x + larg / 2} y={188} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
                {o.teb} °C
              </text>
              <text x={x + larg / 2} y={206} textAnchor="middle" fontSize={9} fill={PALETTE.slate}>
                {o.famille}
              </text>
            </g>
          );
        })}

        <text x={W / 2} y={230} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          même longueur de chaîne, masses molaires voisines — et pourtant 139 °C d&apos;écart
        </text>
      </Board>

      <Ctrl
        label="Longueur de chaîne de l'alcool"
        value={chaine}
        min={1}
        max={8}
        step={1}
        onChange={setChaine}
        display={`${chaine} carbone${chaine > 1 ? "s" : ""}`}
        color={PALETTE.green}
      />

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Déjà en ébullition" value={`${bouillent.length} / 4`} color={PALETTE.orange} />
        <Stat label="Liaisons hydrogène" value="alcool seul" color={PALETTE.purple} />
        <Stat label="Solubilité dans l'eau" value={solubleAlcool} color={PALETTE.blue} />
      </div>

      <Verdict tone="ok">
        Le groupe —OH d&apos;un alcool s&apos;accroche au —OH de sa voisine : c&apos;est la liaison
        hydrogène. Les molécules se tiennent par la main, et il faut bien plus d&apos;énergie pour
        les séparer. L&apos;aldéhyde et la cétone, eux, n&apos;ont pas d&apos;hydrogène sur
        l&apos;oxygène : ils ne peuvent pas s&apos;accrocher entre eux, et ils bouillent entre les
        deux.
      </Verdict>

      <Verdict tone={chaine <= 3 ? "ok" : "warn"}>
        {chaine <= 3
          ? "Chaîne courte : la tête —OH l'emporte, l'alcool se mélange à l'eau en toutes proportions."
          : `Avec ${chaine} carbones, la queue hydrocarbonée l'emporte sur la tête —OH : l'alcool devient ${solubleAlcool}. C'est la règle à retenir — le plus long des deux l'emporte.`}
      </Verdict>
    </div>
  );
}
