import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict, fmt } from "./controls";

/** Informatique 1ère A, C et D — chapitres 1 à 3 : l'ordinateur et son fonctionnement. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* Chapitre 1 — Ranger les périphériques                               */
/* ------------------------------------------------------------------ */

type Famille = "entree" | "sortie" | "stockage";

const PERIPHERIQUES: ReadonlyArray<{
  nom: string;
  bonnes: ReadonlyArray<Famille>;
  note: string;
}> = [
  { nom: "Clavier", bonnes: ["entree"], note: "Tu tapes, l'information entre." },
  { nom: "Souris", bonnes: ["entree"], note: "Elle envoie ta position à la machine." },
  { nom: "Scanner", bonnes: ["entree"], note: "Il fait entrer une image de papier." },
  { nom: "Micro", bonnes: ["entree"], note: "Il fait entrer un son." },
  { nom: "Écran", bonnes: ["sortie"], note: "L'information ressort sous tes yeux." },
  { nom: "Imprimante", bonnes: ["sortie"], note: "L'information ressort sur le papier." },
  { nom: "Haut-parleurs", bonnes: ["sortie"], note: "L'information ressort en son." },
  { nom: "Clé USB", bonnes: ["stockage"], note: "L'information y reste quand tout s'éteint." },
  { nom: "Disque dur", bonnes: ["stockage"], note: "C'est l'armoire de rangement." },
  {
    nom: "Écran tactile",
    bonnes: ["entree", "sortie"],
    note: "Il reçoit tes doigts ET affiche l'image : les deux à la fois.",
  },
  {
    nom: "Modem",
    bonnes: ["entree", "sortie"],
    note: "Il envoie et reçoit : les deux à la fois.",
  },
];

const FAMILLES: ReadonlyArray<{ value: Famille; label: string; couleur: string }> = [
  { value: "entree", label: "Entrée", couleur: "#2563eb" },
  { value: "sortie", label: "Sortie", couleur: "#16a34a" },
  { value: "stockage", label: "Stockage", couleur: "#ca8a04" },
];

const PERIPH_DEFAUT = PERIPHERIQUES[0] ?? { nom: "Clavier", bonnes: ["entree"], note: "" };

export function SchemaFonctionnel() {
  const [i, setI] = useState(0);
  const [choix, setChoix] = useState<Record<string, Famille>>({});

  const p = PERIPHERIQUES[i] ?? PERIPH_DEFAUT;
  const reponse = choix[p.nom];
  const juste = reponse !== undefined && p.bonnes.includes(reponse);
  const faits = Object.keys(choix).length;
  const bons = PERIPHERIQUES.filter((q) => {
    const r = choix[q.nom];
    return r !== undefined && q.bonnes.includes(r);
  }).length;

  const compte = (f: Famille) =>
    PERIPHERIQUES.filter((q) => choix[q.nom] === f && q.bonnes.includes(f)).length;

  const W = 440;
  const H = 240;

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2">
        <p className="text-[11px] text-muted-foreground">Périphérique à ranger</p>
        <p className="text-lg font-semibold">{p.nom}</p>
      </div>

      <Choice<Famille>
        label="Dans quelle famille va-t-il ?"
        value={reponse ?? "entree"}
        options={FAMILLES.map((f) => ({ value: f.value, label: f.label }))}
        onChange={(v) => setChoix({ ...choix, [p.nom]: v })}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <rect
          x={14}
          y={60}
          width={120}
          height={64}
          rx={10}
          fill="#dbeafe"
          stroke="#2563eb"
          strokeWidth={2}
        />
        <text x={74} y={86} textAnchor="middle" fontSize={11} fontWeight={700} fill="#1e3a8a">
          ENTRÉE
        </text>
        <text x={74} y={108} textAnchor="middle" fontSize={16} fontWeight={700} fill="#1e3a8a">
          {compte("entree")}
        </text>

        <rect x={160} y={60} width={120} height={64} rx={10} fill="#1e293b" />
        <text x={220} y={88} textAnchor="middle" fontSize={11} fontWeight={700} fill="#ffffff">
          UNITÉ
        </text>
        <text x={220} y={106} textAnchor="middle" fontSize={11} fontWeight={700} fill="#ffffff">
          CENTRALE
        </text>

        <rect
          x={306}
          y={60}
          width={120}
          height={64}
          rx={10}
          fill="#dcfce7"
          stroke="#16a34a"
          strokeWidth={2}
        />
        <text x={366} y={86} textAnchor="middle" fontSize={11} fontWeight={700} fill="#14532d">
          SORTIE
        </text>
        <text x={366} y={108} textAnchor="middle" fontSize={16} fontWeight={700} fill="#14532d">
          {compte("sortie")}
        </text>

        <rect
          x={160}
          y={160}
          width={120}
          height={56}
          rx={10}
          fill="#fef3c7"
          stroke="#ca8a04"
          strokeWidth={2}
        />
        <text x={220} y={184} textAnchor="middle" fontSize={11} fontWeight={700} fill="#78350f">
          STOCKAGE
        </text>
        <text x={220} y={206} textAnchor="middle" fontSize={16} fontWeight={700} fill="#78350f">
          {compte("stockage")}
        </text>

        <line x1={134} y1={92} x2={152} y2={92} stroke={PALETTE.axis} strokeWidth={2.4} />
        <polygon points="160,92 150,87 150,97" fill={PALETTE.axis} />
        <line x1={280} y1={92} x2={298} y2={92} stroke={PALETTE.axis} strokeWidth={2.4} />
        <polygon points="306,92 296,87 296,97" fill={PALETTE.axis} />
        <line x1={220} y1={124} x2={220} y2={152} stroke={PALETTE.axis} strokeWidth={2.4} />

        <text x={220} y={34} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
          Dans quel sens va l&apos;information ?
        </text>
      </Board>

      <Panel>
        <Stat label="Rangés" value={`${faits} / ${PERIPHERIQUES.length}`} />
        <Stat label="Bien rangés" value={`${bons}`} color={PALETTE.green} />
      </Panel>

      {reponse === undefined ? (
        <Verdict tone="warn">
          Demande-toi dans quel sens va l&apos;information : vers l&apos;unité centrale, c&apos;est
          une entrée ; elle en sort, c&apos;est une sortie ; elle y reste, c&apos;est du stockage.
        </Verdict>
      ) : juste ? (
        <Verdict tone="ok">
          Bien rangé. {p.note}
          {p.bonnes.length > 1 ? " Les deux familles étaient acceptées." : ""}
        </Verdict>
      ) : (
        <Verdict tone="bad">
          Pas celle-là. {p.note} Il fallait répondre{" "}
          {p.bonnes.map((b) => FAMILLES.find((f) => f.value === b)?.label ?? b).join(" ou ")}.
        </Verdict>
      )}

      <div className="flex gap-2">
        <button
          type="button"
          onClick={() => setI((v) => (v + PERIPHERIQUES.length - 1) % PERIPHERIQUES.length)}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Précédent
        </button>
        <button
          type="button"
          onClick={() => setI((v) => (v + 1) % PERIPHERIQUES.length)}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Périphérique suivant
        </button>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 1 — Les unités de mesure                                   */
/* ------------------------------------------------------------------ */

const UNITES = ["hertz", "octet", "pouce", "point par pouce", "bit par seconde"] as const;
type Unite = (typeof UNITES)[number];

const COMPOSANTS: ReadonlyArray<{ nom: string; unite: Unite; exemple: string }> = [
  {
    nom: "Processeur",
    unite: "hertz",
    exemple: "2,5 GHz — des milliards d'opérations par seconde",
  },
  { nom: "Disque dur", unite: "octet", exemple: "500 Go" },
  { nom: "Mémoire vive", unite: "octet", exemple: "4 Go" },
  { nom: "Clé USB", unite: "octet", exemple: "32 Go" },
  { nom: "Écran plat", unite: "pouce", exemple: "15 pouces, mesurés en diagonale" },
  { nom: "Imprimante", unite: "point par pouce", exemple: "600 ppp" },
  { nom: "Scanner", unite: "point par pouce", exemple: "1200 ppp" },
  { nom: "Connexion Internet", unite: "bit par seconde", exemple: "20 Mbit/s" },
];

const COMPOSANT_DEFAUT = COMPOSANTS[0] ?? {
  nom: "Processeur",
  unite: "hertz" as Unite,
  exemple: "",
};

export function UnitesMesure() {
  const [i, setI] = useState(0);
  const [rep, setRep] = useState<Record<string, Unite>>({});
  const [go, setGo] = useState(4);

  const c = COMPOSANTS[i] ?? COMPOSANT_DEFAUT;
  const r = rep[c.nom];
  const juste = r === c.unite;
  const bons = COMPOSANTS.filter((q) => rep[q.nom] === q.unite).length;

  const mo = go * 1024;
  const ko = mo * 1024;
  const octets = ko * 1024;
  const bits = octets * 8;
  const vendu = Math.round(((go * 1000 * 1000 * 1000) / 1024 / 1024 / 1024) * 10) / 10;

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2">
        <p className="text-[11px] text-muted-foreground">Composant</p>
        <p className="text-lg font-semibold">{c.nom}</p>
      </div>

      <Choice<Unite>
        label="Son unité de mesure"
        value={r ?? "hertz"}
        options={UNITES.map((u) => ({ value: u, label: u }))}
        onChange={(v) => setRep({ ...rep, [c.nom]: v })}
      />

      {r === undefined ? (
        <Verdict tone="warn">
          Ces unités ne se devinent pas, elles s&apos;apprennent — et c&apos;est précisément
          pourquoi la question tombe à presque chaque Probatoire.
        </Verdict>
      ) : juste ? (
        <Verdict tone="ok">
          Exact. {c.nom} : {c.unite}. Par exemple {c.exemple}.
        </Verdict>
      ) : (
        <Verdict tone="bad">
          Non. {c.nom} se mesure en {c.unite}. Par exemple {c.exemple}.
        </Verdict>
      )}

      <Panel>
        <Stat
          label="Bonnes réponses"
          value={`${bons} / ${COMPOSANTS.length}`}
          color={PALETTE.green}
        />
        <Stat label="Composant" value={`${i + 1} / ${COMPOSANTS.length}`} />
      </Panel>

      <div className="flex gap-2">
        <button
          type="button"
          onClick={() => setI((v) => (v + COMPOSANTS.length - 1) % COMPOSANTS.length)}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Précédent
        </button>
        <button
          type="button"
          onClick={() => setI((v) => (v + 1) % COMPOSANTS.length)}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Composant suivant
        </button>
      </div>

      <div className="rounded-lg border border-border bg-background p-3 space-y-2">
        <p className="text-xs font-semibold">Convertir les multiples de l&apos;octet</p>
        <Ctrl
          label="Capacité"
          value={go}
          min={1}
          max={1024}
          step={1}
          onChange={setGo}
          display={`${go} Go`}
          color={PALETTE.orange}
        />
        <Panel>
          <Stat label="En mégaoctets" value={`${fmt(mo, 0)} Mo`} />
          <Stat label="En kilooctets" value={`${fmt(ko, 0)} Ko`} />
          <Stat label="En octets" value={`${fmt(octets, 0)}`} />
          <Stat label="En bits" value={`${fmt(bits, 0)}`} color={PALETTE.purple} />
        </Panel>
        <Verdict tone="warn">
          Un disque vendu pour {go} Go par le fabricant — qui compte en base dix — n&apos;en affiche
          que {fmt(vendu, 1)} Go une fois branché, parce que l&apos;ordinateur compte en base deux,
          avec 1 024 et non 1 000.
        </Verdict>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 2 — Ouvrir l'unité centrale                                */
/* ------------------------------------------------------------------ */

type PieceId = "cpu" | "ram" | "disque" | "extension" | "alim" | "ventilo" | "carte";

const PIECES: ReadonlyArray<{
  id: PieceId;
  nom: string;
  role: string;
  unite: string;
  panne: string;
  vital: boolean;
}> = [
  {
    id: "cpu",
    nom: "Le microprocesseur",
    role: "Le cerveau. Il contient l'unité de contrôle, qui organise les travaux, et l'unité arithmétique et logique, qui calcule.",
    unite: "le hertz — 2,5 GHz par exemple",
    panne: "Rien ne démarre : aucun calcul n'est possible sans lui.",
    vital: true,
  },
  {
    id: "ram",
    nom: "La mémoire vive",
    role: "Le plan de travail. Elle conserve les informations traitées pendant la session, et elle est volatile : elle perd tout hors tension.",
    unite: "l'octet — 4 Go par exemple",
    panne: "La machine bipe au démarrage et ne va pas plus loin.",
    vital: true,
  },
  {
    id: "disque",
    nom: "Le disque dur",
    role: "L'armoire de rangement. Lent mais permanent : il garde son contenu hors tension.",
    unite: "l'octet — 500 Go par exemple",
    panne: "Le POST passe, mais aucun système d'exploitation n'est trouvé.",
    vital: false,
  },
  {
    id: "extension",
    nom: "Les connecteurs d'extension",
    role: "Des emplacements de la carte mère qui reçoivent des cartes ajoutant une fonctionnalité : carte graphique, carte son, carte réseau, carte TV.",
    unite: "aucune — on les compte",
    panne: "La fonctionnalité ajoutée disparaît, mais la machine démarre.",
    vital: false,
  },
  {
    id: "alim",
    nom: "Le bloc d'alimentation",
    role: "Il transforme le courant de la prise en tensions utilisables par les composants.",
    unite: "le watt — 450 W par exemple",
    panne: "Aucun voyant, aucun bruit : c'est le premier élément à vérifier.",
    vital: true,
  },
  {
    id: "ventilo",
    nom: "Le ventilateur",
    role: "Il évacue la chaleur du processeur. La poussière est son ennemie.",
    unite: "le tour par minute",
    panne: "La machine chauffe, ralentit, puis s'éteint seule au bout d'un moment.",
    vital: false,
  },
  {
    id: "carte",
    nom: "La carte mère",
    role: "La grande plaque sur laquelle tout se branche, et qui relie le tout par les bus.",
    unite: "aucune — on parle de son format",
    panne: "Rien ne fonctionne : plus rien ne communique.",
    vital: true,
  },
];

const PIECE_DEFAUT = PIECES[0] ?? {
  id: "cpu" as PieceId,
  nom: "Le microprocesseur",
  role: "",
  unite: "",
  panne: "",
  vital: true,
};

export function ComposantsUc() {
  const [sel, setSel] = useState<PieceId>("cpu");
  const [retires, setRetires] = useState<Record<string, boolean>>({});

  const p = PIECES.find((q) => q.id === sel) ?? PIECE_DEFAUT;
  const manqueVital = PIECES.filter((q) => q.vital && retires[q.id]);
  const demarre = manqueVital.length === 0;
  const retire = retires[sel] === true;

  const W = 440;
  const H = 250;
  const op = (id: PieceId) => (retires[id] ? 0.22 : 1);
  const bord = (id: PieceId) => (sel === id ? "#ea580c" : "#334155");
  const ep = (id: PieceId) => (sel === id ? 3 : 1.4);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <g onClick={() => setSel("carte")} style={{ cursor: "pointer" }} opacity={op("carte")}>
          <rect
            x={14}
            y={18}
            width={262}
            height={218}
            rx={8}
            fill="#dcfce7"
            stroke={bord("carte")}
            strokeWidth={ep("carte")}
          />
          <text x={145} y={36} textAnchor="middle" fontSize={10} fontWeight={700} fill="#166534">
            CARTE MÈRE
          </text>
        </g>

        <g onClick={() => setSel("cpu")} style={{ cursor: "pointer" }} opacity={op("cpu")}>
          <rect
            x={36}
            y={54}
            width={76}
            height={76}
            rx={6}
            fill="#334155"
            stroke={bord("cpu")}
            strokeWidth={ep("cpu")}
          />
          <text x={74} y={97} textAnchor="middle" fontSize={12} fontWeight={700} fill="#ffffff">
            CPU
          </text>
        </g>

        <g onClick={() => setSel("ram")} style={{ cursor: "pointer" }} opacity={op("ram")}>
          <rect
            x={136}
            y={54}
            width={18}
            height={104}
            rx={3}
            fill="#1d4ed8"
            stroke={bord("ram")}
            strokeWidth={ep("ram")}
          />
          <rect
            x={160}
            y={54}
            width={18}
            height={104}
            rx={3}
            fill="#1d4ed8"
            stroke={bord("ram")}
            strokeWidth={ep("ram")}
          />
          <text x={157} y={176} textAnchor="middle" fontSize={10} fill={PALETTE.ink}>
            RAM
          </text>
        </g>

        <g
          onClick={() => setSel("extension")}
          style={{ cursor: "pointer" }}
          opacity={op("extension")}
        >
          <rect
            x={196}
            y={64}
            width={62}
            height={12}
            rx={3}
            fill="#b45309"
            stroke={bord("extension")}
            strokeWidth={ep("extension")}
          />
          <rect
            x={196}
            y={84}
            width={62}
            height={12}
            rx={3}
            fill="#b45309"
            stroke={bord("extension")}
            strokeWidth={ep("extension")}
          />
          <rect
            x={196}
            y={104}
            width={62}
            height={12}
            rx={3}
            fill="#b45309"
            stroke={bord("extension")}
            strokeWidth={ep("extension")}
          />
          <text x={227} y={136} textAnchor="middle" fontSize={10} fill={PALETTE.ink}>
            extensions
          </text>
        </g>

        <g onClick={() => setSel("ventilo")} style={{ cursor: "pointer" }} opacity={op("ventilo")}>
          <circle
            cx={74}
            cy={190}
            r={28}
            fill="#0f766e"
            stroke={bord("ventilo")}
            strokeWidth={ep("ventilo")}
          />
          <text x={74} y={194} textAnchor="middle" fontSize={9} fontWeight={700} fill="#ffffff">
            VENTILO
          </text>
        </g>

        <g onClick={() => setSel("disque")} style={{ cursor: "pointer" }} opacity={op("disque")}>
          <rect
            x={296}
            y={26}
            width={128}
            height={58}
            rx={6}
            fill="#78716c"
            stroke={bord("disque")}
            strokeWidth={ep("disque")}
          />
          <text x={360} y={60} textAnchor="middle" fontSize={11} fontWeight={700} fill="#ffffff">
            DISQUE DUR
          </text>
        </g>

        <g onClick={() => setSel("alim")} style={{ cursor: "pointer" }} opacity={op("alim")}>
          <rect
            x={296}
            y={100}
            width={128}
            height={58}
            rx={6}
            fill="#475569"
            stroke={bord("alim")}
            strokeWidth={ep("alim")}
          />
          <text x={360} y={134} textAnchor="middle" fontSize={11} fontWeight={700} fill="#ffffff">
            ALIMENTATION
          </text>
        </g>

        <rect
          x={296}
          y={178}
          width={128}
          height={56}
          rx={6}
          fill={demarre ? "#dcfce7" : "#fee2e2"}
          stroke={demarre ? "#15803d" : "#b91c1c"}
          strokeWidth={1.6}
        />
        <text
          x={360}
          y={200}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={demarre ? "#14532d" : "#7f1d1d"}
        >
          {demarre ? "ELLE DÉMARRE" : "ELLE NE DÉMARRE PAS"}
        </text>
        <text x={360} y={220} textAnchor="middle" fontSize={9} fill={PALETTE.slate}>
          {demarre ? "tout le vital est en place" : "il manque un composant vital"}
        </text>
      </Board>

      <p className="text-xs text-muted-foreground">
        Clique sur un composant du dessin pour le sélectionner.
      </p>

      <div className="rounded-lg border border-border bg-background p-3 space-y-1.5">
        <p className="text-sm font-semibold">{p.nom}</p>
        <p className="text-xs text-muted-foreground">{p.role}</p>
        <Panel>
          <Stat label="Unité de mesure" value={p.unite} />
          <Stat
            label="Vital au démarrage"
            value={p.vital ? "oui" : "non"}
            color={p.vital ? PALETTE.red : PALETTE.green}
          />
        </Panel>
        <p className="text-xs">
          <span className="font-semibold">S&apos;il tombe en panne : </span>
          {p.panne}
        </p>
      </div>

      <button
        type="button"
        onClick={() => setRetires({ ...retires, [sel]: !retire })}
        className={
          retire
            ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        }
      >
        {retire ? `Remettre ${p.nom.toLowerCase()}` : `Retirer ${p.nom.toLowerCase()}`}
      </button>

      {demarre ? (
        <Verdict tone="ok">
          La machine démarre. Retire le processeur, la mémoire vive, l&apos;alimentation ou la carte
          mère, et elle s&apos;arrêtera net : ce sont les quatre composants sans lesquels rien ne se
          passe.
        </Verdict>
      ) : (
        <Verdict tone="bad">
          Rien ne se passe : il manque {manqueVital.map((q) => q.nom.toLowerCase()).join(", ")}.
          {manqueVital.some((q) => q.id === "alim")
            ? " Et sans alimentation, pas même un voyant ne s'allume."
            : ""}
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 2 — Les caractéristiques du processeur                     */
/* ------------------------------------------------------------------ */

export function CaracteristiquesCpu() {
  const [freq, setFreq] = useState(2.5);
  const [bits, setBits] = useState(64);
  const [ram, setRam] = useState(4);

  // temps indicatif d'une tâche : le composant le plus lent commande
  const vitesseCpu = freq * (bits === 64 ? 1 : 0.62);
  const freinRam = ram >= 4 ? 1 : ram >= 2 ? 1.9 : 4.2;
  const secondes = (28 / vitesseCpu) * freinRam;
  const part = clamp(1 / (1 + secondes / 12), 0.04, 1);

  const limite =
    freinRam > 1 ? "la mémoire vive" : bits === 32 ? "le jeu d'instruction" : "le processeur";

  const W = 440;
  const H = 150;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Fréquence"
          value={freq}
          min={0.6}
          max={4.5}
          step={0.1}
          onChange={setFreq}
          display={`${fmt(freq, 1)} GHz`}
        />
        <Ctrl
          label="Mémoire vive"
          value={ram}
          min={1}
          max={32}
          step={1}
          onChange={setRam}
          display={`${ram} Go`}
          color={PALETTE.orange}
        />
      </Panel>

      <Choice<"32" | "64">
        label="Jeu d'instruction"
        value={bits === 64 ? "64" : "32"}
        options={[
          { value: "32", label: "32 bits" },
          { value: "64", label: "64 bits" },
        ]}
        onChange={(v) => setBits(v === "64" ? 64 : 32)}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={220} y={26} textAnchor="middle" fontSize={11} fontWeight={700} fill={PALETTE.ink}>
          La même tâche, sur cette machine
        </text>

        <rect x={30} y={44} width={380} height={28} rx={6} fill="#e2e8f0" />
        <rect
          x={30}
          y={44}
          width={380 * part}
          height={28}
          rx={6}
          fill={secondes < 8 ? "#16a34a" : secondes < 20 ? "#ca8a04" : "#dc2626"}
        />
        <text x={220} y={63} textAnchor="middle" fontSize={12} fontWeight={700} fill="#ffffff">
          {part > 0.3 ? `${fmt(secondes, 1)} s` : ""}
        </text>
        {part <= 0.3 ? (
          <text x={220} y={92} textAnchor="middle" fontSize={12} fontWeight={700} fill="#b91c1c">
            {fmt(secondes, 1)} secondes
          </text>
        ) : (
          <text x={220} y={92} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
            barre pleine = machine instantanée
          </text>
        )}

        <text x={30} y={122} fontSize={11} fill={PALETTE.ink}>
          Ce qui freine le plus ici :
        </text>
        <text x={190} y={122} fontSize={11} fontWeight={700} fill="#b91c1c">
          {limite}
        </text>
      </Board>

      <Panel>
        <Stat label="Fréquence" value={`${fmt(freq, 1)} GHz`} />
        <Stat label="Jeu d'instruction" value={`${bits} bits`} color={PALETTE.purple} />
        <Stat label="Mémoire adressable" value={`${ram} Go`} color={PALETTE.orange} />
        <Stat label="Temps de la tâche" value={`${fmt(secondes, 1)} s`} color={PALETTE.red} />
      </Panel>

      {freinRam > 1 ? (
        <Verdict tone="bad">
          Monte la fréquence autant que tu veux : avec {ram} Go de mémoire vive, la machine rame
          quand même. Un ordinateur ne va jamais plus vite que son composant le plus lent, et
          c&apos;est pour cela qu&apos;ajouter de la mémoire vive est souvent plus efficace que
          changer de processeur.
        </Verdict>
      ) : bits === 32 ? (
        <Verdict tone="warn">
          La mémoire ne freine plus, mais le jeu d&apos;instruction de 32 bits traite deux fois
          moins de données à chaque opération. Passe en 64 bits et regarde la barre.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          Machine équilibrée : c&apos;est maintenant la fréquence du processeur qui commande, et
          rien d&apos;autre ne la retient.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 3 — Les quatre couches                                     */
/* ------------------------------------------------------------------ */

const COUCHES: ReadonlyArray<{ nom: string; detail: string; couleur: string }> = [
  {
    nom: "UTILISATEUR",
    detail: "Toi. Tu cliques sur « Enregistrer » sans savoir ce qui se passe en dessous.",
    couleur: "#ea580c",
  },
  {
    nom: "APPLICATION",
    detail:
      "Word, le navigateur, un jeu. Elle sait ce qu'elle veut — écrire un fichier — mais pas comment parler au disque dur.",
    couleur: "#16a34a",
  },
  {
    nom: "SYSTÈME D'EXPLOITATION",
    detail:
      "Windows, Linux, Android. Le chef d'orchestre : il gère le processeur, la mémoire, les entrées-sorties, la concurrence, les fichiers et le matériel.",
    couleur: "#2563eb",
  },
  {
    nom: "MATÉRIEL",
    detail:
      "Le processeur, la mémoire vive, le disque dur. Il n'obéit qu'à des ordres très précis.",
    couleur: "#b91c1c",
  },
];

const COUCHE_DEFAUT = COUCHES[0] ?? { nom: "UTILISATEUR", detail: "", couleur: "#ea580c" };

export function CouchesSysteme() {
  const [sel, setSel] = useState(0);
  const [etape, setEtape] = useState(0);
  const [sansOs, setSansOs] = useState(false);

  const c = COUCHES[sel] ?? COUCHE_DEFAUT;
  const visibles = sansOs ? COUCHES.filter((_, k) => k !== 2) : COUCHES;
  const maxEtape = sansOs ? 2 : 6;
  const e = clamp(etape, 0, maxEtape);

  // descente 0->3 puis remontée 3->0 ; sans OS, bloqué à l'étape 2
  const niveauActif = e <= 3 ? e : 6 - e;
  const bloque = sansOs && e >= 2;

  const W = 440;
  const H = 230;
  const hauteur = 44;
  const yc = (k: number) => 28 + k * (hauteur + 8);

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        {visibles.map((cc, k) => {
          const indexReel = COUCHES.indexOf(cc);
          const actif = indexReel === (sansOs && niveauActif >= 2 ? 3 : niveauActif);
          return (
            <g key={cc.nom} onClick={() => setSel(indexReel)} style={{ cursor: "pointer" }}>
              <rect
                x={56}
                y={yc(k)}
                width={300}
                height={hauteur}
                rx={8}
                fill={cc.couleur}
                opacity={actif ? 1 : 0.42}
                stroke={indexReel === sel ? PALETTE.ink : "none"}
                strokeWidth={2.4}
              />
              <text
                x={206}
                y={yc(k) + 27}
                textAnchor="middle"
                fontSize={11}
                fontWeight={700}
                fill="#ffffff"
              >
                {cc.nom}
              </text>
            </g>
          );
        })}

        {sansOs ? (
          <text x={372} y={yc(1) + 68} fontSize={10} fontWeight={700} fill="#b91c1c">
            trou
          </text>
        ) : null}

        <text x={30} y={yc(0) + 27} textAnchor="middle" fontSize={16} fill={PALETTE.axis}>
          {e <= 3 ? "↓" : "↑"}
        </text>
        <text x={206} y={H - 10} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          {bloque
            ? "la demande n'a personne à qui parler"
            : e <= 3
              ? "la demande descend vers le matériel"
              : "la réponse remonte vers toi"}
        </text>
      </Board>

      <Ctrl
        label="Suivre une demande « Enregistrer »"
        value={e}
        min={0}
        max={maxEtape}
        step={1}
        onChange={setEtape}
        display={`étape ${e} / ${maxEtape}`}
        color={PALETTE.purple}
      />

      <button
        type="button"
        onClick={() => {
          setSansOs(!sansOs);
          setEtape(0);
        }}
        className={
          sansOs
            ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        }
      >
        {sansOs ? "Remettre le système d'exploitation" : "Retirer le système d'exploitation"}
      </button>

      <div className="rounded-lg border border-border bg-background p-3 space-y-1">
        <p className="text-sm font-semibold">{c.nom}</p>
        <p className="text-xs text-muted-foreground">{c.detail}</p>
      </div>

      {bloque ? (
        <Verdict tone="bad">
          La demande s&apos;arrête là. L&apos;application sait ce qu&apos;elle veut mais ne sait pas
          parler au disque dur, et le matériel n&apos;obéit qu&apos;à des ordres très précis que
          personne ne formule plus. C&apos;est pour cela que le système d&apos;exploitation est le
          premier programme lancé au démarrage, et que sans lui, rien ne fonctionne.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          Chaque couche ne parle qu&apos;à sa voisine. Clique sur une couche pour voir son rôle, et
          fais glisser le curseur pour suivre la demande du haut vers le bas, puis la réponse qui
          remonte.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 3 — Les trois bus                                          */
/* ------------------------------------------------------------------ */

export function BusOrdinateur() {
  const [sens, setSens] = useState<"lire" | "ecrire">("ecrire");
  const [adresse, setAdresse] = useState(42);
  const [donnee, setDonnee] = useState(7);
  const [coupe, setCoupe] = useState<"aucun" | "adresses" | "donnees" | "controle">("aucun");

  const ok = coupe === "aucun";
  const W = 440;
  const H = 250;

  const bus: ReadonlyArray<{
    id: "adresses" | "donnees" | "controle";
    nom: string;
    court: string;
    contenu: string;
    y: number;
    couleur: string;
    manque: string;
  }> = [
    {
      id: "adresses",
      nom: "Bus d'adresses",
      court: "adresses",
      contenu: `case n° ${adresse}`,
      y: 92,
      couleur: "#2563eb",
      manque: "La donnée et l'ordre arrivent, mais personne ne sait OÙ. Rien ne se fait.",
    },
    {
      id: "donnees",
      nom: "Bus de données",
      court: "données",
      contenu: sens === "ecrire" ? `valeur ${donnee}` : "valeur attendue",
      y: 136,
      couleur: "#16a34a",
      manque: "L'adresse et l'ordre arrivent, mais la valeur n'arrive jamais. La case reste vide.",
    },
    {
      id: "controle",
      nom: "Bus de contrôle",
      court: "contrôle",
      contenu: sens === "ecrire" ? "ÉCRIRE" : "LIRE",
      y: 180,
      couleur: "#ea580c",
      manque:
        "L'adresse et la donnée arrivent, mais la mémoire ne sait pas s'il faut lire ou écrire.",
    },
  ];

  const BUS_DEFAUT = bus[0] ?? {
    id: "adresses" as const,
    nom: "",
    court: "",
    contenu: "",
    y: 92,
    couleur: "#2563eb",
    manque: "",
  };
  const coupeInfo = bus.find((b) => b.id === coupe) ?? BUS_DEFAUT;

  return (
    <div className="space-y-3">
      <Choice<"lire" | "ecrire">
        label="Que demande le processeur ?"
        value={sens}
        options={[
          { value: "ecrire", label: "Écrire en mémoire" },
          { value: "lire", label: "Lire la mémoire" },
        ]}
        onChange={setSens}
      />

      <Panel>
        <Ctrl
          label="Adresse visée"
          value={adresse}
          min={0}
          max={255}
          step={1}
          onChange={setAdresse}
          display={`n° ${adresse}`}
        />
        <Ctrl
          label="Valeur à écrire"
          value={donnee}
          min={0}
          max={255}
          step={1}
          onChange={setDonnee}
          display={`${donnee}`}
          color={PALETTE.green}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <rect x={14} y={78} width={76} height={120} rx={8} fill="#334155" />
        <text x={52} y={132} textAnchor="middle" fontSize={11} fontWeight={700} fill="#ffffff">
          CPU
        </text>
        <text x={52} y={150} textAnchor="middle" fontSize={9} fill="#cbd5e1">
          il demande
        </text>

        <rect x={350} y={78} width={76} height={120} rx={8} fill="#1d4ed8" />
        <text x={388} y={126} textAnchor="middle" fontSize={11} fontWeight={700} fill="#ffffff">
          MÉMOIRE
        </text>
        <text x={388} y={144} textAnchor="middle" fontSize={9} fill="#dbeafe">
          elle obéit
        </text>

        <rect x={182} y={98} width={76} height={82} rx={8} fill="#7c3aed" />
        <text x={220} y={134} textAnchor="middle" fontSize={10} fontWeight={700} fill="#ffffff">
          CHIPSET
        </text>
        <text x={220} y={152} textAnchor="middle" fontSize={8} fill="#ede9fe">
          il aiguille
        </text>

        <text x={220} y={34} textAnchor="middle" fontSize={11} fontWeight={700} fill={PALETTE.ink}>
          {sens === "ecrire"
            ? `Écrire ${donnee} dans la case n° ${adresse}`
            : `Lire la case n° ${adresse}`}
        </text>

        {bus.map((b) => {
          const mort = coupe === b.id;
          return (
            <g key={b.id}>
              <line
                x1={90}
                y1={b.y}
                x2={182}
                y2={b.y}
                stroke={mort ? "#cbd5e1" : b.couleur}
                strokeWidth={mort ? 1.6 : 3.4}
                strokeDasharray={mort ? "5 4" : undefined}
              />
              <line
                x1={258}
                y1={b.y}
                x2={350}
                y2={b.y}
                stroke={mort ? "#cbd5e1" : b.couleur}
                strokeWidth={mort ? 1.6 : 3.4}
                strokeDasharray={mort ? "5 4" : undefined}
              />
              {mort ? (
                <>
                  <line
                    x1={126}
                    y1={b.y - 9}
                    x2={144}
                    y2={b.y + 9}
                    stroke="#b91c1c"
                    strokeWidth={2.4}
                  />
                  <line
                    x1={144}
                    y1={b.y - 9}
                    x2={126}
                    y2={b.y + 9}
                    stroke="#b91c1c"
                    strokeWidth={2.4}
                  />
                </>
              ) : (
                <circle cx={135} cy={b.y} r={5} fill={b.couleur} />
              )}
              <text
                x={136}
                y={b.y - 8}
                textAnchor="middle"
                fontSize={8.5}
                fill={mort ? "#94a3b8" : b.couleur}
              >
                {b.court}
              </text>
              <text
                x={304}
                y={b.y - 8}
                textAnchor="middle"
                fontSize={9}
                fill={mort ? "#94a3b8" : b.couleur}
                fontWeight={700}
              >
                {mort ? "coupé" : b.contenu}
              </text>
            </g>
          );
        })}

        <text x={220} y={232} textAnchor="middle" fontSize={9} fill={PALETTE.slate}>
          Chaque bus porte une chose, et une seule.
        </text>
      </Board>

      <Choice<"aucun" | "adresses" | "donnees" | "controle">
        label="Couper un bus pour voir ce qui manque"
        value={coupe}
        options={[
          { value: "aucun", label: "Aucun" },
          { value: "adresses", label: "Adresses" },
          { value: "donnees", label: "Données" },
          { value: "controle", label: "Contrôle" },
        ]}
        onChange={setCoupe}
      />

      {ok ? (
        <Verdict tone="ok">
          Les trois bus travaillent ensemble, et le chipset aiguille entre eux. Pense à la poste :
          l&apos;adresse sur l&apos;enveloppe, la lettre à l&apos;intérieur, et le guichetier qui
          dit s&apos;il s&apos;agit d&apos;un envoi ou d&apos;un retrait.
        </Verdict>
      ) : (
        <Verdict tone="bad">
          {coupeInfo.nom} coupé. {coupeInfo.manque}
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 3 — Le démarrage et la séquence POST                       */
/* ------------------------------------------------------------------ */

type OrganeId = "alim" | "cpu" | "ram" | "clavier" | "video" | "disque";

const ORGANES: ReadonlyArray<{ id: OrganeId; nom: string; bips: string; etape: number }> = [
  { id: "alim", nom: "Alimentation", bips: "aucun son, aucun voyant", etape: 1 },
  { id: "cpu", nom: "Processeur", bips: "les ventilateurs tournent, puis rien", etape: 2 },
  { id: "ram", nom: "Mémoire vive", bips: "bips courts répétés sans fin", etape: 3 },
  { id: "video", nom: "Carte graphique", bips: "un bip long suivi de deux courts", etape: 4 },
  {
    id: "clavier",
    nom: "Clavier",
    bips: "un sifflement continu si une touche est enfoncée",
    etape: 5,
  },
  { id: "disque", nom: "Disque dur", bips: "le POST passe, mais « no bootable device »", etape: 6 },
];

const ETAPES_BOOT: ReadonlyArray<{ titre: string; detail: string }> = [
  { titre: "Machine éteinte", detail: "Appuie sur le bouton pour commencer." },
  { titre: "Mise sous tension", detail: "L'alimentation distribue le courant aux composants." },
  {
    titre: "Le BIOS prend la main",
    detail: "Il est logé sur la carte mère et démarre avant tout le reste.",
  },
  { titre: "POST — test de la mémoire", detail: "Le BIOS compte et vérifie la mémoire vive." },
  {
    titre: "POST — test de l'affichage",
    detail: "La carte graphique est initialisée : c'est là que l'écran s'allume.",
  },
  {
    titre: "POST — test du clavier",
    detail: "Le BIOS vérifie le clavier. Une touche bloquée est signalée ici.",
  },
  {
    titre: "Recherche du disque de démarrage",
    detail: "Le BIOS cherche un système d'exploitation à charger.",
  },
  {
    titre: "Chargement du système d'exploitation",
    detail: "Windows ou Linux prend le relais. Le BIOS a fini son travail.",
  },
];

const ETAPE_DEFAUT = ETAPES_BOOT[0] ?? { titre: "", detail: "" };

export function DemarrageBios() {
  const [etape, setEtape] = useState(0);
  const [debranche, setDebranche] = useState<OrganeId | "rien">("rien");

  const organe = ORGANES.find((o) => o.id === debranche);
  const arret = organe ? organe.etape : 99;
  const e = clamp(etape, 0, ETAPES_BOOT.length - 1);
  const effective = Math.min(e, arret);
  const bloque = e >= arret;

  const info = ETAPES_BOOT[effective] ?? ETAPE_DEFAUT;

  const W = 440;
  const H = 210;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <rect x={120} y={24} width={200} height={128} rx={8} fill="#0f172a" />
        <rect
          x={132}
          y={36}
          width={176}
          height={104}
          rx={4}
          fill={effective === 0 ? "#1e293b" : "#020617"}
        />

        {effective === 0 ? (
          <text x={220} y={94} textAnchor="middle" fontSize={11} fill="#64748b">
            écran éteint
          </text>
        ) : bloque ? (
          <>
            <text x={220} y={80} textAnchor="middle" fontSize={11} fontWeight={700} fill="#f87171">
              ARRÊT
            </text>
            <text x={220} y={100} textAnchor="middle" fontSize={9} fill="#fca5a5">
              {organe ? organe.bips : ""}
            </text>
          </>
        ) : effective >= 7 ? (
          <>
            <text x={220} y={80} textAnchor="middle" fontSize={11} fontWeight={700} fill="#4ade80">
              SYSTÈME CHARGÉ
            </text>
            <text x={220} y={100} textAnchor="middle" fontSize={9} fill="#86efac">
              le bureau s&apos;affiche
            </text>
          </>
        ) : (
          <>
            <text x={144} y={60} fontSize={9} fontFamily="monospace" fill="#4ade80">
              BIOS v2.1 — POST
            </text>
            {effective >= 3 ? (
              <text x={144} y={78} fontSize={9} fontFamily="monospace" fill="#4ade80">
                Memory ....... OK
              </text>
            ) : null}
            {effective >= 4 ? (
              <text x={144} y={94} fontSize={9} fontFamily="monospace" fill="#4ade80">
                Video ........ OK
              </text>
            ) : null}
            {effective >= 5 ? (
              <text x={144} y={110} fontSize={9} fontFamily="monospace" fill="#4ade80">
                Keyboard ..... OK
              </text>
            ) : null}
            {effective >= 6 ? (
              <text x={144} y={126} fontSize={9} fontFamily="monospace" fill="#4ade80">
                Boot device .. search
              </text>
            ) : null}
          </>
        )}

        <circle
          cx={220}
          cy={172}
          r={16}
          fill={effective === 0 ? "#475569" : bloque ? "#b91c1c" : "#16a34a"}
        />
        <text x={220} y={177} textAnchor="middle" fontSize={10} fontWeight={700} fill="#ffffff">
          {effective === 0 ? "off" : "on"}
        </text>

        <text x={220} y={202} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          étape {effective} sur {ETAPES_BOOT.length - 1}
        </text>
      </Board>

      <Ctrl
        label="Avancer dans le démarrage"
        value={e}
        min={0}
        max={ETAPES_BOOT.length - 1}
        step={1}
        onChange={setEtape}
        display={info.titre}
        color={PALETTE.purple}
      />

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm font-semibold">{info.titre}</p>
        <p className="text-xs text-muted-foreground">{info.detail}</p>
      </div>

      <Choice<OrganeId | "rien">
        label="Débrancher un composant avant de démarrer"
        value={debranche}
        options={[
          { value: "rien", label: "Rien" },
          ...ORGANES.map((o) => ({ value: o.id, label: o.nom })),
        ]}
        onChange={(v) => {
          setDebranche(v);
          setEtape(0);
        }}
      />

      {bloque && organe ? (
        <Verdict tone="bad">
          Le POST s&apos;arrête : {organe.nom.toLowerCase()} ne répond pas. Le symptôme est{" "}
          {organe.bips}. Et retiens la règle : si la séquence POST ne passe pas, le système
          d&apos;exploitation n&apos;est pas lancé du tout.
        </Verdict>
      ) : effective >= 7 ? (
        <Verdict tone="ok">
          Tout le POST est passé et le système d&apos;exploitation a pris le relais. Débranche
          maintenant un composant et redémarre : tu verras précisément à quelle étape la machine
          s&apos;arrête, et avec quel code sonore.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Continue d&apos;avancer. Les étapes 3 à 6 sont la séquence POST, pour{" "}
          <em>Power On Self Test</em> : le BIOS teste les composants un par un avant de laisser la
          place au système.
        </Verdict>
      )}
    </div>
  );
}
