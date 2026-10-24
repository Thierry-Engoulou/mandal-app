import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict, fmt } from "./controls";

/** Chimie 1ère C, D et E — chapitres 11 et 12 : pétroles, gaz naturels et engrais. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* Chapitre 11 — Explorer un gisement                                  */
/* ------------------------------------------------------------------ */

export function GisementPetrole() {
  const [prof, setProf] = useState(3);
  const [duree, setDuree] = useState(60);
  const [forage, setForage] = useState(2.6);

  const temp = 15 + 30 * prof;
  const assezVieux = duree >= 20;
  const produit = !assezVieux ? "rien" : temp < 60 ? "rien" : temp <= 150 ? "petrole" : "gaz";

  // le réservoir : gaz 2,0–2,5 km, pétrole 2,5–3,4 km, eau en dessous
  const touche = forage < 2.0 ? "roche" : forage < 2.5 ? "gaz" : forage < 3.4 ? "petrole" : "eau";

  const W = 440;
  const H = 290;
  const yKm = (k: number) => 40 + (k / 5) * 170;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Profondeur d'enfouissement"
          value={prof}
          min={0.5}
          max={6}
          step={0.1}
          onChange={setProf}
          display={`${fmt(prof, 1)} km`}
        />
        <Ctrl
          label="Durée d'action de la géothermie"
          value={duree}
          min={1}
          max={200}
          step={1}
          onChange={setDuree}
          display={`${duree} millions d'années`}
          color={PALETTE.purple}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <rect x={16} y={26} width={408} height={yKm(2) - 26} fill="#78716c" />
        <text x={220} y={44} textAnchor="middle" fontSize={10} fontWeight={700} fill="#ffffff">
          ROCHE IMPERMÉABLE — le couvercle qui piège tout
        </text>

        <rect x={16} y={yKm(2)} width={408} height={yKm(2.5) - yKm(2)} fill="#fca5a5" />
        <text
          x={220}
          y={yKm(2.25) + 4}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill="#7f1d1d"
        >
          GAZ NATUREL
        </text>

        <rect x={16} y={yKm(2.5)} width={408} height={yKm(3.4) - yKm(2.5)} fill="#44403c" />
        <text
          x={220}
          y={yKm(2.95) + 4}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill="#fbbf24"
        >
          PÉTROLE BRUT
        </text>

        <rect x={16} y={yKm(3.4)} width={408} height={yKm(5) - yKm(3.4)} fill="#93c5fd" />
        <text
          x={220}
          y={yKm(4.2) + 4}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill="#1e3a8a"
        >
          EAU SALÉE
        </text>

        <line x1={120} y1={16} x2={120} y2={yKm(forage)} stroke="#1e293b" strokeWidth={4} />
        <polygon points="120,6 112,22 128,22" fill="#1e293b" />
        <circle cx={120} cy={yKm(forage)} r={6} fill={PALETTE.orange} />
        <text x={132} y={yKm(forage) + 4} fontSize={10} fontWeight={700} fill={PALETTE.orange}>
          {fmt(forage, 1)} km
        </text>

        <text x={424} y={yKm(0) + 4} textAnchor="end" fontSize={9} fill={PALETTE.slate}>
          0 km
        </text>
        <text x={424} y={yKm(5) + 4} textAnchor="end" fontSize={9} fill={PALETTE.slate}>
          5 km
        </text>

        <rect
          x={16}
          y={226}
          width={408}
          height={52}
          rx={8}
          fill="#f8fafc"
          stroke={PALETTE.gridStrong}
          strokeWidth={1.2}
        />
        <text x={30} y={248} fontSize={11} fill={PALETTE.slate}>
          à {fmt(prof, 1)} km de profondeur : {fmt(temp, 0)} °C, pendant {duree} millions
          d&apos;années
        </text>
        <text
          x={30}
          y={268}
          fontSize={12}
          fontWeight={700}
          fill={produit === "rien" ? PALETTE.red : produit === "gaz" ? "#7f1d1d" : "#b45309"}
        >
          {produit === "rien"
            ? "aucun hydrocarbure ne se forme"
            : produit === "gaz"
              ? "formation de GAZ NATUREL"
              : "formation de PÉTROLE BRUT"}
        </text>
      </Board>

      <Ctrl
        label="Profondeur du forage"
        value={forage}
        min={0.5}
        max={5}
        step={0.1}
        onChange={setForage}
        display={`${fmt(forage, 1)} km`}
        color={PALETTE.orange}
      />

      <div className="grid grid-cols-3 gap-2">
        <Stat label="Température du sous-sol" value={`${fmt(temp, 0)} °C`} color={PALETTE.red} />
        <Stat label="Durée" value={`${duree} Ma`} color={PALETTE.purple} />
        <Stat
          label="Le forage touche"
          value={
            touche === "roche"
              ? "la roche"
              : touche === "gaz"
                ? "le gaz"
                : touche === "petrole"
                  ? "le pétrole"
                  : "l'eau salée"
          }
          color={touche === "petrole" ? "#b45309" : touche === "gaz" ? "#7f1d1d" : PALETTE.slate}
        />
      </div>

      <Verdict tone={produit === "rien" ? "bad" : "ok"}>
        {!assezVieux
          ? "Trop peu de temps : la matière organique n'a pas eu le temps de se transformer. La DURÉE est l'un des trois facteurs, au même titre que la décomposition et la géothermie."
          : temp < 60
            ? "Trop froid : à cette profondeur la géothermie ne suffit pas à transformer la matière organique."
            : produit === "gaz"
              ? "Au-delà de 150 °C, les molécules se cassent en morceaux de plus en plus petits : on obtient du gaz naturel, dont le constituant principal est le méthane."
              : "Entre 60 et 150 °C, la matière organique se transforme en pétrole brut. C'est la fenêtre à pétrole, et c'est pour cela que les gisements se trouvent entre 1 et 4 km."}
      </Verdict>

      <Verdict tone="warn">
        Les trois fluides se rangent par densité : le gaz en haut, le pétrole au milieu, l&apos;eau
        salée en bas. C&apos;est ce qui permet de savoir à quelle profondeur forer.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 11 — La colonne à plateaux                                 */
/* ------------------------------------------------------------------ */

type Coupe = { nom: string; temp: string; usage: string; couleur: string };

const COUPES: ReadonlyArray<Coupe> = [
  {
    nom: "Gaz (C1–C4)",
    temp: "moins de 20 °C",
    usage: "butane, propane domestiques",
    couleur: "#dc2626",
  },
  { nom: "Essences (C5–C10)", temp: "20 à 180 °C", usage: "moteurs à essence", couleur: "#ea580c" },
  {
    nom: "Pétrole lampant",
    temp: "180 à 250 °C",
    usage: "lampes, kérosène avion",
    couleur: "#ca8a04",
  },
  { nom: "Gasoil", temp: "250 à 350 °C", usage: "moteurs diesel", couleur: "#65a30d" },
  {
    nom: "Fuel et huiles",
    temp: "350 à 400 °C",
    usage: "chauffage, lubrifiants",
    couleur: "#0891b2",
  },
  { nom: "Bitumes", temp: "résidu", usage: "revêtement des routes", couleur: "#4338ca" },
];

export function DistillationPetrole() {
  const [legers, setLegers] = useState(50);
  const [debit, setDebit] = useState(1000);

  // répartition : plus le brut est léger, plus les coupes du haut sont grosses
  // profil d'un brut moyen, incliné vers le haut ou vers le bas de la colonne
  const BASE = [0.04, 0.2, 0.12, 0.24, 0.25, 0.15];
  const poids = BASE.map((b, i) => b * Math.exp(((legers - 50) / 45) * ((2.5 - i) / 2.5)));
  const somme = poids.reduce((a, b) => a + b, 0);
  const parts = poids.map((p) => p / somme);

  const W = 440;
  const H = 280;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Richesse du brut en molécules légères"
          value={legers}
          min={10}
          max={90}
          step={1}
          onChange={setLegers}
          display={`${legers} %`}
          color={PALETTE.orange}
        />
        <Ctrl
          label="Débit de brut injecté"
          value={debit}
          min={100}
          max={5000}
          step={100}
          onChange={setDebit}
          display={`${debit} m³/h`}
          color={PALETTE.purple}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <rect
          x={30}
          y={20}
          width={110}
          height={244}
          rx={6}
          fill="#f1f5f9"
          stroke={PALETTE.slate}
          strokeWidth={2}
        />
        {COUPES.map((c, i) => {
          const y = 28 + i * 40;
          return (
            <g key={c.nom}>
              <line
                x1={30}
                y1={y + 32}
                x2={140}
                y2={y + 32}
                stroke={PALETTE.gridStrong}
                strokeWidth={1.2}
              />
              <line x1={140} y1={y + 16} x2={166} y2={y + 16} stroke={c.couleur} strokeWidth={2} />
              <rect x={168} y={y + 4} width={244} height={26} rx={5} fill="#f8fafc" />
              <rect
                x={168}
                y={y + 4}
                width={Math.max(6, (parts[i] ?? 0) * 244)}
                height={26}
                rx={5}
                fill={c.couleur}
                opacity={0.75}
              />
              <text x={176} y={y + 21} fontSize={10} fontWeight={700} fill={PALETTE.ink}>
                {c.nom}
              </text>
              <text
                x={404}
                y={y + 21}
                textAnchor="end"
                fontSize={10}
                fontWeight={700}
                fill={PALETTE.ink}
              >
                {fmt((parts[i] ?? 0) * debit, 0)} m³/h
              </text>
            </g>
          );
        })}

        <text x={85} y={14} textAnchor="middle" fontSize={9} fontWeight={700} fill={PALETTE.blue}>
          FROID
        </text>
        <text x={85} y={276} textAnchor="middle" fontSize={9} fontWeight={700} fill={PALETTE.red}>
          CHAUD — brut injecté vers 350–400 °C
        </text>
      </Board>

      <Verdict tone="ok">
        Chaque plateau condense les molécules dont la température d&apos;ébullition correspond à la
        sienne : c&apos;est la distillation fractionnée. Les coupes obtenues ne sont PAS des corps
        purs, mais des mélanges de corps purs de températures d&apos;ébullition voisines —
        c&apos;est une erreur fréquente en examen.
      </Verdict>

      <Verdict tone="warn">
        {legers >= 65
          ? "Un brut léger donne beaucoup d'essences : c'est le brut le plus cher. Il demande peu de craquage."
          : legers <= 35
            ? "Un brut lourd donne surtout du fuel et du bitume. Or le marché veut des essences : c'est précisément pour cela qu'on fait du craquage après la distillation."
            : "Au Cameroun, cette distillation se fait à la SONARA, à Limbé."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 11 — Améliorer un carburant                                */
/* ------------------------------------------------------------------ */

export function IndiceOctane() {
  const [ram, setRam] = useState(0);
  const [cyclise, setCyclise] = useState(false);

  // heptane linéaire = 0 ; iso-octane (3 ramifications) = 100
  const base = clamp(ram * 32, 0, 100);
  const indice = clamp(base + (cyclise ? 22 : 0), 0, 112);
  const cogne = indice < 60;

  const nom = cyclise
    ? "cyclane obtenu par cyclisation"
    : ram === 0
      ? "n-heptane (chaîne droite)"
      : ram === 1
        ? "2-méthylhexane"
        : ram === 2
          ? "2,3-diméthylpentane"
          : "2,2,4-triméthylpentane (iso-octane)";

  const W = 440;
  const H = 210;

  return (
    <div className="space-y-3">
      <Ctrl
        label="Ramifications ajoutées (isomérisation, reformage)"
        value={ram}
        min={0}
        max={3}
        step={1}
        onChange={setRam}
        display={ram === 0 ? "chaîne droite" : `${ram} ramification(s)`}
        color={PALETTE.orange}
      />
      <Choice
        label="Cyclisation"
        value={cyclise ? "oui" : "non"}
        options={[
          { value: "non", label: "Chaîne ouverte" },
          { value: "oui", label: "Fermer le cycle" },
        ]}
        onChange={(v) => setCyclise(v === "oui")}
      />

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
          {nom}
        </text>

        {cyclise ? (
          <g>
            {Array.from({ length: 6 }).map((_, i) => {
              const a1 = (-90 + 60 * i) * (Math.PI / 180);
              const a2 = (-90 + 60 * (i + 1)) * (Math.PI / 180);
              return (
                <line
                  key={i}
                  x1={130 + 42 * Math.cos(a1)}
                  y1={92 + 42 * Math.sin(a1)}
                  x2={130 + 42 * Math.cos(a2)}
                  y2={92 + 42 * Math.sin(a2)}
                  stroke={PALETTE.ink}
                  strokeWidth={2.4}
                />
              );
            })}
          </g>
        ) : (
          <g>
            {Array.from({ length: 7 }).map((_, i) => {
              const x = 38 + i * 32;
              return (
                <g key={i}>
                  {i < 6 ? (
                    <line
                      x1={x}
                      y1={92}
                      x2={x + 32}
                      y2={92}
                      stroke={PALETTE.ink}
                      strokeWidth={2.4}
                    />
                  ) : null}
                  <circle cx={x} cy={92} r={9} fill="#334155" />
                  {i >= 1 && i <= ram ? (
                    <g>
                      <line
                        x1={x}
                        y1={92}
                        x2={x}
                        y2={62}
                        stroke={PALETTE.orange}
                        strokeWidth={2.2}
                      />
                      <circle cx={x} cy={56} r={9} fill={PALETTE.orange} />
                    </g>
                  ) : null}
                </g>
              );
            })}
          </g>
        )}

        <rect x={282} y={48} width={132} height={14} rx={7} fill="#e2e8f0" />
        <rect
          x={282}
          y={48}
          width={(indice / 112) * 132}
          height={14}
          rx={7}
          fill={cogne ? PALETTE.red : PALETTE.green}
        />
        <text x={348} y={40} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          indice d&apos;octane
        </text>
        <text
          x={348}
          y={84}
          textAnchor="middle"
          fontSize={24}
          fontWeight={700}
          fill={cogne ? PALETTE.red : PALETTE.green}
        >
          {fmt(indice, 0)}
        </text>

        <rect x={282} y={102} width={132} height={56} rx={8} fill={cogne ? "#fef2f2" : "#ecfdf5"} />
        <text
          x={348}
          y={126}
          textAnchor="middle"
          fontSize={12}
          fontWeight={700}
          fill={cogne ? PALETTE.red : PALETTE.green}
        >
          {cogne ? "le moteur COGNE" : "le moteur tourne rond"}
        </text>
        <text x={348} y={146} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          {cogne ? "autoinflammation trop tôt" : "pas d'autoinflammation"}
        </text>

        <text x={W / 2} y={192} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          repères de l&apos;échelle : n-heptane = 0 · iso-octane = 100
        </text>
      </Board>

      <Verdict tone={cogne ? "bad" : "ok"}>
        {cogne
          ? "Une chaîne droite s'enflamme trop facilement : elle prend feu avant que la bougie n'allume, le moteur cogne et s'abîme. C'est le pire des carburants."
          : "Plus la molécule est ramifiée ou cyclique, plus elle résiste à l'autoinflammation, donc plus son indice d'octane est élevé. Isomérisation, cyclisation et reformage servent exactement à cela."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 11 — La bouteille de gaz et la cuisine                     */
/* ------------------------------------------------------------------ */

export function CampingGaz() {
  const [masse, setMasse] = useState(2.3);
  const [volume, setVolume] = useState(20);
  const [fenetre, setFenetre] = useState(true);

  const n = (masse * 1000) / 58;
  const vCo2 = (4 * n * 22.4) / 1000;
  const mEau = (5 * n * 18) / 1000;
  const vO2 = (6.5 * n * 22.4) / 1000;
  const vAir = 5 * vO2;

  const rapport = vAir / Math.max(1, volume);
  const manque = !fenetre && rapport > 1;

  const W = 440;
  const H = 220;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Masse de butane consommée"
          value={masse}
          min={0.2}
          max={6}
          step={0.1}
          onChange={setMasse}
          display={`${fmt(masse, 1)} kg`}
        />
        <Ctrl
          label="Volume de la cuisine"
          value={volume}
          min={8}
          max={80}
          step={1}
          onChange={setVolume}
          display={`${volume} m³`}
          color={PALETTE.slate}
        />
      </Panel>
      <Choice
        label="Aération"
        value={fenetre ? "ouverte" : "fermee"}
        options={[
          { value: "ouverte", label: "Fenêtre ouverte" },
          { value: "fermee", label: "Fenêtre fermée" },
        ]}
        onChange={(v) => setFenetre(v === "ouverte")}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill={manque ? "#fff7ed" : "#ffffff"} />
        <text x={W / 2} y={24} textAnchor="middle" fontSize={12} fill={PALETTE.ink}>
          C₄H₁₀ + 13/2 O₂ → 4 CO₂ + 5 H₂O
        </text>

        <rect x={40} y={116} width={60} height={76} rx={8} fill="#64748b" />
        <rect x={58} y={104} width={24} height={14} rx={4} fill="#475569" />
        <text x={70} y={162} textAnchor="middle" fontSize={10} fontWeight={700} fill="#ffffff">
          butane
        </text>

        <path
          d={
            manque
              ? "M150 150 Q 166 104 182 150 Q 166 132 150 150"
              : "M150 150 Q 166 110 182 150 Q 166 134 150 150"
          }
          fill={manque ? "#fb923c" : "#60a5fa"}
        />
        <text
          x={166}
          y={170}
          textAnchor="middle"
          fontSize={10}
          fontWeight={700}
          fill={manque ? "#b45309" : PALETTE.blue}
        >
          {manque ? "flamme orange" : "flamme bleue"}
        </text>

        <g fontSize={11}>
          <text x={224} y={62} fill={PALETTE.slate}>
            dioxyde de carbone rejeté
          </text>
          <text x={408} y={62} textAnchor="end" fontWeight={700} fill={PALETTE.ink}>
            {fmt(vCo2, 2)} m³
          </text>
          <text x={224} y={88} fill={PALETTE.slate}>
            eau déposée sur les murs
          </text>
          <text x={408} y={88} textAnchor="end" fontWeight={700} fill={PALETTE.blue}>
            {fmt(mEau, 2)} kg
          </text>
          <text x={224} y={114} fill={PALETTE.slate}>
            dioxygène consommé
          </text>
          <text x={408} y={114} textAnchor="end" fontWeight={700} fill={PALETTE.red}>
            {fmt(vO2, 2)} m³
          </text>
          <text x={224} y={140} fill={PALETTE.slate}>
            air nécessaire
          </text>
          <text x={408} y={140} textAnchor="end" fontWeight={700} fill={PALETTE.orange}>
            {fmt(vAir, 1)} m³
          </text>
          <text x={224} y={170} fill={PALETTE.slate}>
            soit, par rapport à la pièce
          </text>
          <text
            x={408}
            y={170}
            textAnchor="end"
            fontWeight={700}
            fill={rapport > 1 ? PALETTE.red : PALETTE.green}
          >
            × {fmt(rapport, 1)}
          </text>
        </g>

        {manque ? (
          <text
            x={W / 2}
            y={204}
            textAnchor="middle"
            fontSize={12}
            fontWeight={700}
            fill={PALETTE.red}
          >
            ⚠ combustion incomplète — du monoxyde de carbone se forme
          </text>
        ) : (
          <text x={W / 2} y={204} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
            l&apos;air contient 20 % de dioxygène, d&apos;où le facteur 5
          </text>
        )}
      </Board>

      <Verdict tone={manque ? "bad" : "ok"}>
        {manque
          ? `Il faudrait ${fmt(vAir, 1)} m³ d'air pour une cuisine de ${volume} m³ seulement, et la fenêtre est fermée. Le dioxygène manque, la combustion devient incomplète, et c'est le monoxyde de carbone qui se forme : inodore, et mortel.`
          : rapport > 1
            ? `Il faut ${fmt(vAir, 1)} m³ d'air, soit plus que le volume de la pièce. Heureusement la fenêtre est ouverte : l'air se renouvelle et la combustion reste complète.`
            : "Le volume de la pièce suffit largement et la combustion est complète. Note tout de même la quantité d'eau déposée sur les murs : c'est elle qui fait moisir les plafonds des cuisines."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 12 — Le sol qui retient, le sol qui lessive                */
/* ------------------------------------------------------------------ */

type Sol = { value: string; label: string; retention: number; note: string };

const SOL_DEFAUT: Sol = {
  value: "sableux",
  label: "Sol sableux",
  retention: 0.25,
  note: "Peu d'argile, peu d'humus : le complexe argilo-humique est presque absent. L'engrais part avec la première pluie.",
};

const SOLS: ReadonlyArray<Sol> = [
  SOL_DEFAUT,
  {
    value: "argileux",
    label: "Sol argileux",
    retention: 0.62,
    note: "L'argile retient bien les éléments fertilisants, mais sans humus le sol se compacte et l'eau circule mal.",
  },
  {
    value: "humifere",
    label: "Sol riche en humus",
    retention: 0.88,
    note: "Argile et humus associés : le complexe argilo-humique est complet. Il retient les éléments et les restitue peu à peu, et il garde au sol une bonne structure.",
  },
];

export function ComplexeArgiloHumique() {
  const [choix, setChoix] = useState("sableux");
  const [pluie, setPluie] = useState(40);
  const [dose, setDose] = useState(100);
  const s = SOLS.find((x) => x.value === choix) ?? SOL_DEFAUT;

  const perteRel = clamp((1 - s.retention) * (pluie / 50), 0, 0.95);
  const perdu = dose * perteRel;
  const retenu = dose - perdu;

  const W = 440;
  const H = 220;

  return (
    <div className="space-y-3">
      <Choice
        label="Type de sol"
        value={choix}
        options={SOLS.map((o) => ({ value: o.value, label: o.label }))}
        onChange={setChoix}
      />
      <Panel>
        <Ctrl
          label="Engrais répandu"
          value={dose}
          min={20}
          max={300}
          step={10}
          onChange={setDose}
          display={`${dose} kg/ha`}
          color={PALETTE.green}
        />
        <Ctrl
          label="Pluie tombée"
          value={pluie}
          min={0}
          max={120}
          step={5}
          onChange={setPluie}
          display={`${pluie} mm`}
          color={PALETTE.blue}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        {Array.from({ length: Math.round(pluie / 8) }).map((_, i) => (
          <line
            key={i}
            x1={34 + ((i * 53) % 376)}
            y1={16 + ((i * 11) % 24)}
            x2={30 + ((i * 53) % 376)}
            y2={34 + ((i * 11) % 24)}
            stroke={PALETTE.blue}
            strokeWidth={1.6}
          />
        ))}

        <rect x={20} y={62} width={400} height={74} fill="#a16207" opacity={0.35} />
        <rect x={20} y={136} width={400} height={44} fill="#93c5fd" opacity={0.5} />
        <text x={30} y={158} fontSize={10} fill="#1e3a8a">
          nappe phréatique
        </text>

        {Array.from({ length: 24 }).map((_, i) => {
          const garde = i < Math.round((retenu / dose) * 24);
          return (
            <circle
              key={i}
              cx={34 + i * 16}
              cy={garde ? 82 + ((i * 7) % 38) : 150 + ((i * 5) % 22)}
              r={5}
              fill={garde ? PALETTE.green : PALETTE.red}
              opacity={0.85}
            />
          );
        })}

        <text x={30} y={56} fontSize={11} fontWeight={700} fill="#78350f">
          sol — complexe argilo-humique : {fmt(s.retention * 100, 0)} %
        </text>

        <rect x={244} y={190} width={176} height={24} rx={6} fill="#ecfdf5" />
        <text
          x={332}
          y={206}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={PALETTE.green}
        >
          retenu : {fmt(retenu, 0)} kg/ha
        </text>
        <rect x={20} y={190} width={176} height={24} rx={6} fill="#fef2f2" />
        <text x={108} y={206} textAnchor="middle" fontSize={11} fontWeight={700} fill={PALETTE.red}>
          lessivé : {fmt(perdu, 0)} kg/ha
        </text>
      </Board>

      <Verdict tone={perteRel > 0.4 ? "bad" : "ok"}>{s.note}</Verdict>
      <Verdict tone="warn">
        {perteRel > 0.4
          ? "L'engrais lessivé est perdu deux fois : pour le planteur, qui l'a payé, et pour la rivière, qu'il pollue. Sur un sol pauvre, on commence par apporter de la matière organique — on amende — avant de fertiliser."
          : "Un sol bien pourvu en complexe argilo-humique retient les éléments et les restitue peu à peu. C'est ce qui permet d'espacer les apports."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 12 — Nourrir une plante                                    */
/* ------------------------------------------------------------------ */

export function RoleNpk() {
  const [azote, setAzote] = useState(70);
  const [phosphore, setPhosphore] = useState(70);
  const [potassium, setPotassium] = useState(70);
  const [secheresse, setSecheresse] = useState(false);

  const hauteur = 30 + (azote / 100) * 82;
  const feuilles = Math.max(0, Math.round((azote / 100) * 8));
  const fruits = Math.max(0, Math.round((phosphore / 100) * 5));
  const vert = azote > 45 ? "#16a34a" : azote > 22 ? "#a3a30f" : "#ca8a04";
  const couche = secheresse && potassium < 50;

  const W = 440;
  const H = 230;
  const sol = 190;
  const cx = 150;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Azote N"
          value={azote}
          min={0}
          max={100}
          step={5}
          onChange={setAzote}
          display={`${azote} %`}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Phosphore P"
          value={phosphore}
          min={0}
          max={100}
          step={5}
          onChange={setPhosphore}
          display={`${phosphore} %`}
          color="#ca8a04"
        />
        <Ctrl
          label="Potassium K"
          value={potassium}
          min={0}
          max={100}
          step={5}
          onChange={setPotassium}
          display={`${potassium} %`}
          color={PALETTE.green}
        />
      </Panel>
      <Choice
        label="Épreuve"
        value={secheresse ? "oui" : "non"}
        options={[
          { value: "non", label: "Saison normale" },
          { value: "oui", label: "Coup de sécheresse" },
        ]}
        onChange={(v) => setSecheresse(v === "oui")}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill={secheresse ? "#fffbeb" : "#ffffff"} />
        <rect x={0} y={sol} width={W} height={H - sol} fill="#a16207" opacity={0.4} />

        <g transform={couche ? `rotate(38 ${cx} ${sol})` : undefined}>
          <line x1={cx} y1={sol} x2={cx} y2={sol - hauteur} stroke={vert} strokeWidth={5} />
          {Array.from({ length: feuilles }).map((_, i) => {
            const y = sol - 14 - (i / Math.max(1, feuilles)) * (hauteur - 20);
            const g = i % 2 === 0;
            return (
              <ellipse
                key={i}
                cx={cx + (g ? -20 : 20)}
                cy={y}
                rx={18}
                ry={7}
                fill={vert}
                opacity={0.85}
                transform={`rotate(${g ? -20 : 20} ${cx + (g ? -20 : 20)} ${y})`}
              />
            );
          })}
          {Array.from({ length: fruits }).map((_, i) => (
            <circle
              key={i}
              cx={cx + (i % 2 === 0 ? -26 : 26)}
              cy={sol - hauteur + 12 + i * 15}
              r={7}
              fill="#dc2626"
            />
          ))}
        </g>

        <g fontSize={11}>
          <text x={254} y={56} fill={PALETTE.slate}>
            croissance, feuillage
          </text>
          <text x={408} y={56} textAnchor="end" fontWeight={700} fill={PALETTE.blue}>
            {azote > 60 ? "bonne" : azote > 30 ? "moyenne" : "faible"}
          </text>
          <text x={254} y={84} fill={PALETTE.slate}>
            floraison, fruits
          </text>
          <text x={408} y={84} textAnchor="end" fontWeight={700} fill="#ca8a04">
            {fruits} fruit{fruits > 1 ? "s" : ""}
          </text>
          <text x={254} y={112} fill={PALETTE.slate}>
            résistance
          </text>
          <text
            x={408}
            y={112}
            textAnchor="end"
            fontWeight={700}
            fill={potassium > 50 ? PALETTE.green : PALETTE.red}
          >
            {potassium > 70 ? "forte" : potassium > 50 ? "correcte" : "faible"}
          </text>
        </g>

        {couche ? (
          <text
            x={330}
            y={160}
            textAnchor="middle"
            fontSize={12}
            fontWeight={700}
            fill={PALETTE.red}
          >
            la plante est couchée
          </text>
        ) : null}
      </Board>

      <Verdict tone={azote < 30 || phosphore < 30 || potassium < 30 ? "bad" : "ok"}>
        {azote < 30
          ? "Manque d'AZOTE : les feuilles jaunissent et la plante reste petite. L'azote assure la croissance et donne un feuillage vert."
          : phosphore < 30
            ? "Manque de PHOSPHORE : la plante pousse bien mais ne donne presque pas de fruits. Le phosphore facilite les échanges énergétiques et favorise la floraison et la fructification."
            : potassium < 30
              ? "Manque de POTASSIUM : la plante tient debout tant que tout va bien, mais le premier coup de sécheresse la couche. Le potassium active la photosynthèse et augmente la résistance."
              : "Les trois éléments sont présents : feuillage fourni, fruits nombreux, plante résistante. Coupe un seul des trois curseurs et regarde ce qui se dégrade — c'est le meilleur moyen de retenir leurs rôles."}
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 12 — Calculer un apport d'engrais                          */
/* ------------------------------------------------------------------ */

export function EngraisNpk() {
  const [tn, setTn] = useState(15);
  const [tp, setTp] = useState(11);
  const [tk, setTk] = useState(20);
  const [me, setMe] = useState(2.5);

  const K_P = 62 / 142;
  const K_K = 78.2 / 94.2;

  const mN = (tn * me) / 100;
  const mP = K_P * tp * (me / 100);
  const mK = K_K * tk * (me / 100);

  const W = 440;
  const H = 230;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Teneur en N"
          value={tn}
          min={0}
          max={30}
          step={1}
          onChange={setTn}
          display={`${tn}`}
          color={PALETTE.blue}
        />
        <Ctrl
          label="Teneur en P₂O₅"
          value={tp}
          min={0}
          max={30}
          step={1}
          onChange={setTp}
          display={`${tp}`}
          color="#ca8a04"
        />
        <Ctrl
          label="Teneur en K₂O"
          value={tk}
          min={0}
          max={30}
          step={1}
          onChange={setTk}
          display={`${tk}`}
          color={PALETTE.green}
        />
        <Ctrl
          label="Masse de l'échantillon"
          value={me}
          min={0.5}
          max={50}
          step={0.5}
          onChange={setMe}
          display={`${fmt(me, 1)} kg`}
          color={PALETTE.purple}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <rect
          x={20}
          y={18}
          width={160}
          height={110}
          rx={10}
          fill="#f8fafc"
          stroke={PALETTE.slate}
          strokeWidth={1.6}
        />
        <rect x={20} y={18} width={160} height={28} rx={10} fill="#166534" />
        <rect x={20} y={36} width={160} height={10} fill="#166534" />
        <text x={100} y={38} textAnchor="middle" fontSize={11} fontWeight={700} fill="#ffffff">
          ENGRAIS
        </text>
        <text x={100} y={82} textAnchor="middle" fontSize={22} fontWeight={700} fill={PALETTE.ink}>
          {tn} – {tp} – {tk}
        </text>
        <text x={100} y={104} textAnchor="middle" fontSize={11} fontWeight={700} fill="#166534">
          N – P₂O₅ – K₂O
        </text>
        <text x={100} y={122} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          pour 100 kg d&apos;engrais
        </text>

        <g fontSize={11}>
          <rect x={198} y={18} width={222} height={56} rx={8} fill="#eff6ff" />
          <text x={208} y={36} fill="#1e3a8a" fontWeight={700}>
            AZOTE — aucune conversion
          </text>
          <text x={208} y={52} fill={PALETTE.slate}>
            m = {tn} × {fmt(me, 1)} / 100
          </text>
          <text x={410} y={66} textAnchor="end" fontSize={15} fontWeight={700} fill={PALETTE.blue}>
            {fmt(mN, 3)} kg
          </text>

          <rect x={198} y={80} width={222} height={66} rx={8} fill="#fef9c3" />
          <text x={208} y={98} fill="#78350f" fontWeight={700}>
            PHOSPHORE — il faut convertir
          </text>
          <text x={208} y={114} fill={PALETTE.slate}>
            2M(P)/M(P₂O₅) = 62/142 = {fmt(K_P, 3)}
          </text>
          <text x={208} y={130} fill={PALETTE.slate}>
            m = {fmt(K_P, 3)} × {tp} × {fmt(me, 1)} / 100
          </text>
          <text x={410} y={142} textAnchor="end" fontSize={15} fontWeight={700} fill="#ca8a04">
            {fmt(mP, 3)} kg
          </text>

          <rect x={198} y={152} width={222} height={66} rx={8} fill="#ecfdf5" />
          <text x={208} y={170} fill="#14532d" fontWeight={700}>
            POTASSIUM — il faut convertir
          </text>
          <text x={208} y={186} fill={PALETTE.slate}>
            2M(K)/M(K₂O) = 78,2/94,2 = {fmt(K_K, 3)}
          </text>
          <text x={208} y={202} fill={PALETTE.slate}>
            m = {fmt(K_K, 3)} × {tk} × {fmt(me, 1)} / 100
          </text>
          <text
            x={410}
            y={214}
            textAnchor="end"
            fontSize={15}
            fontWeight={700}
            fill={PALETTE.green}
          >
            {fmt(mK, 3)} kg
          </text>
        </g>
      </Board>

      <Verdict tone="warn">
        Le piège de l&apos;exercice : le premier nombre est une teneur en AZOTE PUR, les deux autres
        sont des teneurs en OXYDES. Retiens les deux coefficients de conversion, 0,436 pour le
        phosphore et 0,830 pour le potassium : ils te feront gagner cinq minutes le jour de
        l&apos;épreuve.
      </Verdict>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 12 — Choisir le bon engrais                                */
/* ------------------------------------------------------------------ */

type Culture = { value: string; label: string; n: number; p: number; k: number; note: string };

const CULT_DEFAUT: Culture = {
  value: "mais",
  label: "Maïs",
  n: 0.5,
  p: 0.25,
  k: 0.25,
  note: "Le maïs fait beaucoup de tige et de feuille : il est gourmand en azote.",
};

const CULTURES: ReadonlyArray<Culture> = [
  CULT_DEFAUT,
  {
    value: "tomate",
    label: "Tomate",
    n: 0.22,
    p: 0.39,
    k: 0.39,
    note: "La tomate est une culture fruitière : phosphore pour la fructification, potassium pour la résistance.",
  },
  {
    value: "bananier",
    label: "Bananier",
    n: 0.3,
    p: 0.15,
    k: 0.55,
    note: "Le bananier est le plus gros consommateur de potassium de toutes les cultures tropicales.",
  },
];

const FORMULES = [
  { value: "20-10-10", n: 20, p: 10, k: 10 },
  { value: "10-20-20", n: 10, p: 20, k: 20 },
  { value: "15-11-20", n: 15, p: 11, k: 20 },
  { value: "12-12-17", n: 12, p: 12, k: 17 },
] as const;

export function FamillesEngrais() {
  const [cult, setCult] = useState("mais");
  const [sol, setSol] = useState<"sableux" | "argileux" | "humifere">("argileux");
  const [saison, setSaison] = useState<"seche" | "pluies">("seche");
  const [formule, setFormule] = useState("20-10-10");
  const [epandage, setEpandage] = useState<"avant" | "fractionne" | "apres">("fractionne");

  const c = CULTURES.find((x) => x.value === cult) ?? CULT_DEFAUT;
  const f = FORMULES.find((x) => x.value === formule) ?? FORMULES[0];

  const tot = f.n + f.p + f.k;
  const ecart = Math.abs(f.n / tot - c.n) + Math.abs(f.p / tot - c.p) + Math.abs(f.k / tot - c.k);
  const adequation = clamp(1 - ecart / 2, 0, 1);

  const baseLessivage = sol === "sableux" ? 0.45 : sol === "argileux" ? 0.2 : 0.1;
  const facteurSaison = saison === "pluies" ? 1.8 : 1;
  const facteurEpandage = epandage === "avant" ? 1.6 : epandage === "fractionne" ? 0.55 : 1;
  const lessivage = clamp(baseLessivage * facteurSaison * facteurEpandage, 0, 0.85);

  const rendement = adequation * (1 - lessivage) * 100;
  const bon = rendement >= 60;

  const W = 440;
  const H = 170;

  return (
    <div className="space-y-3">
      <div className="grid gap-2 sm:grid-cols-2">
        <Choice
          label="Culture"
          value={cult}
          options={CULTURES.map((o) => ({ value: o.value, label: o.label }))}
          onChange={setCult}
        />
        <Choice
          label="Sol"
          value={sol}
          options={[
            { value: "sableux" as const, label: "Sableux" },
            { value: "argileux" as const, label: "Argileux" },
            { value: "humifere" as const, label: "Riche en humus" },
          ]}
          onChange={setSol}
        />
        <Choice
          label="Saison"
          value={saison}
          options={[
            { value: "seche" as const, label: "Saison sèche" },
            { value: "pluies" as const, label: "Saison des pluies" },
          ]}
          onChange={setSaison}
        />
        <Choice
          label="Épandage"
          value={epandage}
          options={[
            { value: "avant" as const, label: "Avant la pluie" },
            { value: "fractionne" as const, label: "Fractionné" },
            { value: "apres" as const, label: "Après la pluie" },
          ]}
          onChange={setEpandage}
        />
      </div>
      <Choice
        label="Formule NPK choisie"
        value={formule}
        options={FORMULES.map((o) => ({ value: o.value, label: o.value }))}
        onChange={setFormule}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <text x={20} y={28} fontSize={11} fill={PALETTE.slate}>
          adéquation de la formule à la culture
        </text>
        <rect x={20} y={36} width={290} height={14} rx={7} fill="#e2e8f0" />
        <rect x={20} y={36} width={adequation * 290} height={14} rx={7} fill={PALETTE.blue} />
        <text x={408} y={48} textAnchor="end" fontSize={12} fontWeight={700} fill={PALETTE.blue}>
          {fmt(adequation * 100, 0)} %
        </text>

        <text x={20} y={80} fontSize={11} fill={PALETTE.slate}>
          engrais parti dans la rivière
        </text>
        <rect x={20} y={88} width={290} height={14} rx={7} fill="#e2e8f0" />
        <rect x={20} y={88} width={lessivage * 290} height={14} rx={7} fill={PALETTE.red} />
        <text x={408} y={100} textAnchor="end" fontSize={12} fontWeight={700} fill={PALETTE.red}>
          {fmt(lessivage * 100, 0)} %
        </text>

        <text x={20} y={132} fontSize={11} fontWeight={700} fill={PALETTE.ink}>
          rendement final
        </text>
        <rect x={20} y={140} width={290} height={16} rx={8} fill="#e2e8f0" />
        <rect
          x={20}
          y={140}
          width={(rendement / 100) * 290}
          height={16}
          rx={8}
          fill={bon ? PALETTE.green : PALETTE.orange}
        />
        <text
          x={408}
          y={154}
          textAnchor="end"
          fontSize={15}
          fontWeight={700}
          fill={bon ? PALETTE.green : PALETTE.orange}
        >
          {fmt(rendement, 0)} %
        </text>
      </Board>

      <Verdict tone={bon ? "ok" : "bad"}>{c.note}</Verdict>
      <Verdict tone={lessivage > 0.45 ? "bad" : "ok"}>
        {lessivage > 0.45
          ? "Plus de la moitié de l'engrais est lessivée. Essaie de fractionner l'épandage en plusieurs petites doses, et d'éviter de répandre juste avant une averse : l'argent est perdu et la rivière est polluée."
          : "Le lessivage est maîtrisé. Sur un sol pauvre et en saison des pluies, c'est le fractionnement des apports qui fait la différence."}
      </Verdict>
    </div>
  );
}
