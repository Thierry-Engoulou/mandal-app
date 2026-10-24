import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict, fmt } from "./controls";
import { JeuClassement } from "./info1-jeux";

/** Informatique 1ère A, C et D — chapitres 4 à 7 : maintenance, pannes, virus, optimisation. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* Chapitre 4 — Corrective ou préventive ?                             */
/* ------------------------------------------------------------------ */

export function TypesMaintenance() {
  return (
    <JeuClassement
      aide="Une seule question à se poser : la panne est-elle déjà là, ou cherche-t-on à l'éviter ?"
      options={[
        { value: "cor", label: "Corrective" },
        { value: "pre", label: "Préventive" },
      ]}
      cas={[
        {
          enonce: "Un écran ne s'allume plus. Tu le remplaces.",
          bonne: "cor",
          pourquoi: "La panne est là, tu rétablis : c'est du correctif.",
        },
        {
          enonce: "Tu dépoussières toutes les salles le premier samedi de chaque trimestre.",
          bonne: "pre",
          pourquoi: "Rien n'est en panne. Tu agis pour que rien ne tombe en panne.",
        },
        {
          enonce: "Un disque dur grince de plus en plus. Tu le remplaces avant qu'il ne meure.",
          bonne: "pre",
          pourquoi:
            "Le disque fonctionne encore : tu interviens avant la défaillance. C'est du préventif, et plus précisément du prévisionnel.",
        },
        {
          enonce: "Tu mets à jour l'antivirus de tous les postes.",
          bonne: "pre",
          pourquoi: "Aucune machine n'est infectée : tu réduis le risque qu'elles le soient.",
        },
        {
          enonce: "Une imprimante bourre. Tu retires la feuille coincée et elle repart.",
          bonne: "cor",
          pourquoi: "Le dysfonctionnement est survenu, tu le corriges.",
        },
        {
          enonce: "Tu remplaces les piles des cartes mères tous les quatre ans, panne ou pas.",
          bonne: "pre",
          pourquoi: "Un échéancier fixé d'avance : c'est du préventif systématique.",
        },
        {
          enonce:
            "Le secrétariat a perdu ses fichiers. Tu les restaures depuis la sauvegarde d'hier.",
          bonne: "cor",
          pourquoi:
            "Le sinistre a eu lieu, tu rétablis. C'est la sauvegarde elle-même qui était du préventif.",
        },
        {
          enonce: "Tu vérifies chaque mois la température des processeurs d'une salle.",
          bonne: "pre",
          pourquoi: "Tu surveilles un indicateur pour agir avant la surchauffe.",
        },
      ]}
    />
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 4 — L'arbre de la maintenance à compléter                  */
/* ------------------------------------------------------------------ */

const ETIQUETTES = [
  { id: "palliative", label: "palliative", famille: "cor", exemple: "un dépannage provisoire" },
  { id: "curative", label: "curative", famille: "cor", exemple: "la réparation définitive" },
  {
    id: "systematique",
    label: "systématique",
    famille: "pre",
    exemple: "selon un échéancier fixé d'avance",
  },
  {
    id: "conditionnelle",
    label: "conditionnelle",
    famille: "pre",
    exemple: "quand un seuil est franchi",
  },
  {
    id: "previsionnelle",
    label: "prévisionnelle",
    famille: "pre",
    exemple: "en extrapolant une tendance pour prévoir la date",
  },
] as const;

type EtiquetteId = (typeof ETIQUETTES)[number]["id"];

const CASES: ReadonlyArray<{ slot: number; attendu: EtiquetteId; x: number; famille: string }> = [
  { slot: 0, attendu: "palliative", x: 14, famille: "cor" },
  { slot: 1, attendu: "curative", x: 96, famille: "cor" },
  { slot: 2, attendu: "systematique", x: 228, famille: "pre" },
  { slot: 3, attendu: "conditionnelle", x: 296, famille: "pre" },
  { slot: 4, attendu: "previsionnelle", x: 364, famille: "pre" },
];

export function ArbreMaintenance() {
  const [pose, setPose] = useState<Record<number, EtiquetteId>>({});
  const [prise, setPrise] = useState<EtiquetteId | null>(null);

  const utilisees = new Set(Object.values(pose));
  const bons = CASES.filter((c) => pose[c.slot] === c.attendu).length;
  const complet = Object.keys(pose).length === CASES.length;

  const poser = (slot: number) => {
    if (prise === null) {
      const actuelle = pose[slot];
      if (actuelle !== undefined) {
        const suite = { ...pose };
        delete suite[slot];
        setPose(suite);
      }
      return;
    }
    setPose({ ...pose, [slot]: prise });
    setPrise(null);
  };

  const derniere = prise !== null ? ETIQUETTES.find((e) => e.id === prise) : undefined;

  const W = 440;
  const H = 230;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <rect x={166} y={14} width={108} height={28} rx={6} fill="#1e293b" />
        <text x={220} y={32} textAnchor="middle" fontSize={10} fontWeight={700} fill="#ffffff">
          LA MAINTENANCE
        </text>

        <line x1={220} y1={42} x2={220} y2={54} stroke={PALETTE.axis} strokeWidth={1.8} />
        <line x1={92} y1={54} x2={324} y2={54} stroke={PALETTE.axis} strokeWidth={1.8} />
        <line x1={92} y1={54} x2={92} y2={66} stroke={PALETTE.axis} strokeWidth={1.8} />
        <line x1={324} y1={54} x2={324} y2={66} stroke={PALETTE.axis} strokeWidth={1.8} />

        <rect x={24} y={66} width={136} height={30} rx={6} fill="#b91c1c" />
        <text x={92} y={85} textAnchor="middle" fontSize={10} fontWeight={700} fill="#ffffff">
          CORRECTIVE
        </text>
        <rect x={256} y={66} width={136} height={30} rx={6} fill="#15803d" />
        <text x={324} y={85} textAnchor="middle" fontSize={10} fontWeight={700} fill="#ffffff">
          PRÉVENTIVE
        </text>

        {CASES.map((c) => {
          const mise = pose[c.slot];
          const etiq = mise !== undefined ? ETIQUETTES.find((e) => e.id === mise) : undefined;
          const bon = mise === c.attendu;
          const fond = mise === undefined ? "#f1f5f9" : bon ? "#dcfce7" : "#fee2e2";
          const trait = mise === undefined ? "#94a3b8" : bon ? "#15803d" : "#b91c1c";
          return (
            <g key={c.slot} onClick={() => poser(c.slot)} style={{ cursor: "pointer" }}>
              <rect
                x={c.x}
                y={126}
                width={60}
                height={48}
                rx={6}
                fill={fond}
                stroke={trait}
                strokeWidth={1.6}
                strokeDasharray={mise === undefined ? "4 3" : undefined}
              />
              <text
                x={c.x + 30}
                y={154}
                textAnchor="middle"
                fontSize={8}
                fontWeight={700}
                fill={mise === undefined ? "#94a3b8" : trait}
              >
                {etiq ? etiq.label : "?"}
              </text>
            </g>
          );
        })}

        <line x1={44} y1={96} x2={44} y2={126} stroke="#b91c1c" strokeWidth={1.4} />
        <line x1={126} y1={96} x2={126} y2={126} stroke="#b91c1c" strokeWidth={1.4} />
        <line x1={258} y1={96} x2={258} y2={126} stroke="#15803d" strokeWidth={1.4} />
        <line x1={326} y1={96} x2={326} y2={126} stroke="#15803d" strokeWidth={1.4} />
        <line x1={394} y1={96} x2={394} y2={126} stroke="#15803d" strokeWidth={1.4} />

        <text x={220} y={204} textAnchor="middle" fontSize={10} fill={PALETTE.slate}>
          {prise === null
            ? "Prends une étiquette ci-dessous, puis clique sur une case."
            : `Tu tiens « ${derniere ? derniere.label : ""} » : clique sur sa case.`}
        </text>
        <text x={220} y={220} textAnchor="middle" fontSize={9} fill={PALETTE.slate}>
          Cliquer sur une case remplie sans rien tenir la vide.
        </text>
      </Board>

      <div className="flex flex-wrap gap-1.5">
        {ETIQUETTES.map((e) => {
          const posee = utilisees.has(e.id);
          return (
            <button
              key={e.id}
              type="button"
              disabled={posee}
              onClick={() => setPrise(e.id)}
              className={
                posee
                  ? "rounded-lg border border-border bg-secondary/40 px-3 py-1.5 text-xs font-medium text-muted-foreground/50"
                  : prise === e.id
                    ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                    : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
              }
            >
              {e.label}
            </button>
          );
        })}
      </div>

      <Panel>
        <Stat label="Cases remplies" value={`${Object.keys(pose).length} / 5`} />
        <Stat label="Bien placées" value={`${bons} / 5`} color={PALETTE.green} />
      </Panel>

      {complet && bons === 5 ? (
        <Verdict tone="ok">
          L&apos;arbre est juste. Retiens la frontière la plus confondue : la{" "}
          <strong>conditionnelle</strong> réagit à un seuil franchi — « le disque dépasse 90 % » —
          tandis que la <strong>prévisionnelle</strong> extrapole une tendance pour prévoir la date
          — « il perd deux secteurs par semaine, il sera mort en avril ».
        </Verdict>
      ) : complet ? (
        <Verdict tone="bad">
          Il reste {5 - bons} étiquette(s) mal placée(s), en rouge. Rappel : la corrective n&apos;a
          que deux branches, palliative et curative ; la préventive en a trois.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Deux branches à gauche, trois à droite. Les deux premières répondent à « la réparation
          est-elle provisoire ou définitive ? », les trois autres à « qu&apos;est-ce qui déclenche
          l&apos;intervention ? ».
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 4 — La maintenance logicielle                              */
/* ------------------------------------------------------------------ */

export function MaintenanceLogicielle() {
  return (
    <JeuClassement
      aide="Trois questions, dans cet ordre : le logiciel était-il en faute ? l'utilisateur veut-il plus ? est-ce l'environnement qui a changé ?"
      options={[
        { value: "cor", label: "Corrective" },
        { value: "evo", label: "Évolutive" },
        { value: "ada", label: "Adaptative" },
      ]}
      cas={[
        {
          enonce: "« Le total de la colonne est faux quand il y a plus de dix lignes. »",
          bonne: "cor",
          pourquoi:
            "Le logiciel devait calculer juste et il calcule faux : c'est un défaut à corriger.",
        },
        {
          enonce: "« On voudrait pouvoir exporter les bulletins en PDF. »",
          bonne: "evo",
          pourquoi: "Rien n'est cassé. L'utilisateur demande une fonctionnalité nouvelle.",
        },
        {
          enonce: "« Depuis que le lycée est passé à Windows 11, le logiciel ne démarre plus. »",
          bonne: "ada",
          pourquoi:
            "Le logiciel n'a aucun défaut et personne ne demande plus : c'est l'environnement qui a bougé.",
        },
        {
          enonce: "« L'application plante quand on clique deux fois de suite sur Enregistrer. »",
          bonne: "cor",
          pourquoi: "Un comportement anormal du logiciel lui-même.",
        },
        {
          enonce: "« Ajoutez l'envoi des notes par SMS aux parents. »",
          bonne: "evo",
          pourquoi:
            "Une capacité nouvelle, qui n'existait pas et que personne n'attendait du logiciel.",
        },
        {
          enonce: "« Le nouveau format de fichier du ministère n'est pas reconnu. »",
          bonne: "ada",
          pourquoi: "Le monde extérieur a changé de format ; on adapte le logiciel pour le suivre.",
        },
        {
          enonce: "« Les accents s'affichent en symboles bizarres dans les noms d'élèves. »",
          bonne: "cor",
          pourquoi: "Le logiciel affiche mal ce qu'il devait afficher correctement.",
        },
        {
          enonce: "« Il faudrait que l'application tourne aussi sur les téléphones Android. »",
          bonne: "ada",
          pourquoi:
            "Même logiciel, mêmes fonctions, nouvelle plateforme : on l'adapte à un nouvel environnement.",
        },
      ]}
    />
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 5 — Protéger une salle informatique                        */
/* ------------------------------------------------------------------ */

type Protection = "rien" | "regulateur" | "parasurtenseur" | "onduleur";

const PROTECTIONS: ReadonlyArray<{
  value: Protection;
  label: string;
  prix: number;
  role: string;
}> = [
  { value: "rien", label: "Aucune", prix: 0, role: "la prise murale, directement" },
  {
    value: "regulateur",
    label: "Régulateur",
    prix: 15000,
    role: "il ramène la tension à sa valeur normale quand elle monte ou descend",
  },
  {
    value: "parasurtenseur",
    label: "Parasurtenseur",
    prix: 8000,
    role: "il absorbe les pointes brutales de tension, la foudre par exemple",
  },
  {
    value: "onduleur",
    label: "Onduleur",
    prix: 60000,
    role: "il contient une batterie et continue d'alimenter la machine pendant la coupure",
  },
];

const PROTECTION_DEFAUT = PROTECTIONS[0] ?? {
  value: "rien" as Protection,
  label: "Aucune",
  prix: 0,
  role: "",
};

type Incident = "baisse" | "foudre" | "coupure";

const INCIDENTS: ReadonlyArray<{ value: Incident; label: string; texte: string }> = [
  {
    value: "baisse",
    label: "Baisse de tension",
    texte: "La tension tombe à 170 V pendant dix minutes.",
  },
  {
    value: "foudre",
    label: "Coup de foudre",
    texte: "Une surtension brutale arrive par la ligne.",
  },
  { value: "coupure", label: "Coupure de 2 min", texte: "Le courant est totalement coupé." },
];

const INCIDENT_DEFAUT = INCIDENTS[0] ?? { value: "baisse" as Incident, label: "", texte: "" };

function resultat(p: Protection, i: Incident): { tone: "ok" | "warn" | "bad"; texte: string } {
  if (i === "baisse") {
    if (p === "regulateur" || p === "onduleur")
      return {
        tone: "ok",
        texte: "La tension est corrigée : les machines continuent normalement.",
      };
    if (p === "parasurtenseur")
      return {
        tone: "bad",
        texte:
          "Le parasurtenseur ne voit rien : il guette les pointes, pas les baisses. Les alimentations chauffent et vieillissent prématurément.",
      };
    return { tone: "bad", texte: "Les alimentations forcent, s'échauffent et s'abîment." };
  }
  if (i === "foudre") {
    if (p === "parasurtenseur" || p === "onduleur")
      return { tone: "ok", texte: "La pointe est absorbée avant d'atteindre les machines." };
    if (p === "regulateur")
      return {
        tone: "warn",
        texte:
          "Le régulateur encaisse mal une pointe aussi brutale : il peut y passer, et parfois les machines avec.",
      };
    return {
      tone: "bad",
      texte: "Alimentations et cartes mères grillées. C'est le pire scénario.",
    };
  }
  if (p === "onduleur")
    return {
      tone: "ok",
      texte:
        "La batterie prend le relais : les élèves enregistrent leur travail et éteignent proprement. Rien n'est perdu.",
    };
  return {
    tone: "bad",
    texte:
      "Extinction brutale. Tout le travail non enregistré est perdu, et le disque dur souffre à chaque arrêt sauvage. Ni le régulateur ni le parasurtenseur ne fournissent de courant.",
  };
}

export function ProtectionElectrique() {
  const [prot, setProt] = useState<Protection>("rien");
  const [inc, setInc] = useState<Incident>("coupure");
  const [postes, setPostes] = useState(6);

  const p = PROTECTIONS.find((q) => q.value === prot) ?? PROTECTION_DEFAUT;
  const i = INCIDENTS.find((q) => q.value === inc) ?? INCIDENT_DEFAUT;
  const r = resultat(prot, inc);
  const cout = p.prix * (prot === "onduleur" ? postes : 1);

  const W = 440;
  const rangees = Math.ceil(postes / 10);
  const H = 46 + rangees * 44 + 44;
  const perdus = r.tone === "bad" ? postes : r.tone === "warn" ? Math.ceil(postes / 2) : 0;

  return (
    <div className="space-y-3">
      <Ctrl
        label="Nombre de postes dans la salle"
        value={postes}
        min={1}
        max={20}
        step={1}
        onChange={setPostes}
        display={`${postes} postes`}
        color={PALETTE.orange}
      />

      <Choice<Protection>
        label="Équipement installé"
        value={prot}
        options={PROTECTIONS.map((q) => ({ value: q.value, label: q.label }))}
        onChange={setProt}
      />

      <Choice<Incident>
        label="Incident envoyé sur la ligne"
        value={inc}
        options={INCIDENTS.map((q) => ({ value: q.value, label: q.label }))}
        onChange={setInc}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={220} y={24} textAnchor="middle" fontSize={11} fontWeight={700} fill={PALETTE.ink}>
          {i.texte}
        </text>

        {Array.from({ length: postes }).map((_, k) => {
          const mort = k < perdus;
          const col = k % 10;
          const row = Math.floor(k / 10);
          const x = 24 + col * 40;
          const y = 46 + row * 44;
          return (
            <g key={k}>
              <rect
                x={x}
                y={y}
                width={30}
                height={24}
                rx={3}
                fill={mort ? "#fee2e2" : "#dcfce7"}
                stroke={mort ? "#b91c1c" : "#15803d"}
                strokeWidth={1.4}
              />
              <text
                x={x + 15}
                y={y + 17}
                textAnchor="middle"
                fontSize={11}
                fontWeight={700}
                fill={mort ? "#b91c1c" : "#15803d"}
              >
                {mort ? "✕" : "✓"}
              </text>
            </g>
          );
        })}

        <text x={24} y={152} fontSize={10} fill={PALETTE.slate}>
          {p.label} — {p.role}
        </text>
        <text
          x={24}
          y={168}
          fontSize={10}
          fontWeight={700}
          fill={perdus > 0 ? "#b91c1c" : "#15803d"}
        >
          {perdus === 0
            ? "aucun poste touché"
            : `${perdus} poste${perdus > 1 ? "s" : ""} touché${perdus > 1 ? "s" : ""}`}
        </text>
      </Board>

      <Panel>
        <Stat label="Coût de l'équipement" value={`${fmt(cout, 0)} FCFA`} />
        <Stat
          label="Postes épargnés"
          value={`${postes - perdus} / ${postes}`}
          color={perdus === 0 ? PALETTE.green : PALETTE.red}
        />
      </Panel>

      <Verdict tone={r.tone}>{r.texte}</Verdict>

      {prot !== "onduleur" ? (
        <p className="text-xs text-muted-foreground">
          Essaie les trois incidents avec chaque équipement. Tu verras qu&apos;un seul des trois
          appareils résiste aux trois : c&apos;est pour cela que c&apos;est presque toujours
          l&apos;onduleur qu&apos;on attend en réponse d&apos;examen.
        </p>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 5 — Diagnostiquer une panne                                */
/* ------------------------------------------------------------------ */

type VerifId =
  | "cable"
  | "voyant"
  | "post"
  | "ecran"
  | "ram"
  | "disque"
  | "antivirus"
  | "pilote"
  | "ventilo";

const VERIFS: ReadonlyArray<{ id: VerifId; label: string }> = [
  { id: "cable", label: "Vérifier le câble d'alimentation et la prise" },
  { id: "voyant", label: "Regarder les voyants et écouter les bips" },
  { id: "post", label: "Observer si la séquence POST passe" },
  { id: "ecran", label: "Tester le câble de l'écran" },
  { id: "ram", label: "Rasseoir les barrettes de mémoire" },
  { id: "disque", label: "Vérifier le disque dur dans le BIOS" },
  { id: "antivirus", label: "Lancer une analyse antivirus" },
  { id: "pilote", label: "Regarder les pilotes manquants" },
  { id: "ventilo", label: "Ouvrir et regarder le ventilateur" },
];

type MachineId = "m1" | "m2" | "m3" | "m4" | "m5" | "m6";

const MACHINES: ReadonlyArray<{
  id: MachineId;
  label: string;
  symptome: string;
  cause: string;
  resultats: Partial<Record<VerifId, string>>;
}> = [
  {
    id: "m1",
    label: "Poste 1",
    symptome: "Rien du tout : aucun voyant, aucun bruit de ventilateur.",
    cause: "Le câble d'alimentation était débranché côté prise murale.",
    resultats: {
      cable: "Le câble est sorti de la prise murale. Rebranché, la machine démarre.",
      voyant: "Aucun voyant, aucun bip : le courant n'arrive pas du tout.",
      post: "Aucune séquence POST : la machine n'est pas alimentée.",
      ecran: "L'écran est correctement branché, mais il n'a rien à afficher.",
    },
  },
  {
    id: "m2",
    label: "Poste 2",
    symptome: "Les ventilateurs tournent, mais l'écran reste noir et la machine bipe.",
    cause: "Une barrette de mémoire vive mal enfoncée.",
    resultats: {
      cable: "Le câble est bon : les ventilateurs tournent, donc le courant arrive.",
      voyant: "Bips courts répétés sans fin. C'est le code de la mémoire vive.",
      post: "Le POST s'arrête au test de la mémoire.",
      ram: "Une barrette était mal enfoncée. Rasseyée, la machine démarre.",
      ecran: "L'écran fonctionne : testé sur un autre poste, il affiche.",
    },
  },
  {
    id: "m3",
    label: "Poste 3",
    symptome: "Le POST passe, puis un message : « no bootable device ».",
    cause: "Le disque dur n'est plus reconnu par le BIOS.",
    resultats: {
      cable: "L'alimentation est bonne.",
      post: "Le POST passe entièrement : le matériel essentiel répond.",
      disque: "Le BIOS ne voit plus le disque dur. Nappe ou disque à remplacer.",
      antivirus: "Impossible de lancer une analyse : aucun système ne démarre.",
    },
  },
  {
    id: "m4",
    label: "Poste 4",
    symptome: "Très lent depuis trois jours, et des raccourcis bizarres sur le bureau.",
    cause: "Une infection virale, probablement arrivée par une clé USB.",
    resultats: {
      post: "Le POST passe, le système démarre : le matériel va bien.",
      antivirus: "Analyse : plusieurs fichiers infectés, et l'antivirus avait été désactivé.",
      disque: "Le disque est reconnu et sain.",
      ventilo: "Le ventilateur est propre et tourne normalement.",
    },
  },
  {
    id: "m5",
    label: "Poste 5",
    symptome: "Plus aucun son depuis une réinstallation de Windows.",
    cause: "Le pilote de la carte son n'a pas été réinstallé.",
    resultats: {
      post: "Le POST passe, tout va bien côté matériel.",
      pilote: "La carte son apparaît avec un point d'exclamation : son pilote manque.",
      antivirus: "Analyse propre : aucun virus.",
    },
  },
  {
    id: "m6",
    label: "Poste 6",
    symptome: "S'éteint seule après une heure de travail, surtout en fin d'après-midi.",
    cause: "La surchauffe, par accumulation de poussière dans le ventilateur.",
    resultats: {
      cable: "L'alimentation est bonne : la machine démarre sans problème.",
      post: "Le POST passe et le système démarre normalement.",
      antivirus: "Analyse propre.",
      ventilo: "Le ventilateur et les grilles sont bouchés de poussière, la machine chauffe.",
    },
  },
];

const MACHINE_DEFAUT = MACHINES[0] ?? {
  id: "m1" as MachineId,
  label: "",
  symptome: "",
  cause: "",
  resultats: {},
};

export function DiagnosticPanne() {
  const [mid, setMid] = useState<MachineId>("m1");
  const [faites, setFaites] = useState<VerifId[]>([]);
  const [montre, setMontre] = useState(false);

  const m = MACHINES.find((q) => q.id === mid) ?? MACHINE_DEFAUT;

  const lancer = (v: VerifId) => {
    if (faites.includes(v)) return;
    setFaites([...faites, v]);
  };

  const trouve = faites.some((v) => {
    const r = m.resultats[v];
    return (
      r !== undefined &&
      (r.includes("Rebranché") ||
        r.includes("Rasseyée") ||
        r.includes("remplacer") ||
        r.includes("infectés") ||
        r.includes("manque") ||
        r.includes("poussière"))
    );
  });

  return (
    <div className="space-y-3">
      <Choice<MachineId>
        label="Machine à diagnostiquer"
        value={mid}
        options={MACHINES.map((q) => ({ value: q.id, label: q.label }))}
        onChange={(v) => {
          setMid(v);
          setFaites([]);
          setMontre(false);
        }}
      />

      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-[11px] text-muted-foreground">Ce que l&apos;utilisateur te dit</p>
        <p className="text-sm font-medium">{m.symptome}</p>
      </div>

      <div className="space-y-1.5">
        <p className="text-xs font-medium text-muted-foreground">
          Tes vérifications — chacune compte, cherche la plus rapide d&apos;abord
        </p>
        <div className="flex flex-wrap gap-1.5">
          {VERIFS.map((v) => (
            <button
              key={v.id}
              type="button"
              onClick={() => lancer(v.id)}
              className={
                faites.includes(v.id)
                  ? "rounded-lg bg-secondary/60 px-2.5 py-1.5 text-[11px] font-medium text-muted-foreground"
                  : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-[11px] font-medium hover:bg-secondary/60"
              }
            >
              {v.label}
            </button>
          ))}
        </div>
      </div>

      {faites.length > 0 ? (
        <div className="space-y-1.5 rounded-lg border border-border bg-background p-3">
          {faites.map((v) => {
            const lib = VERIFS.find((q) => q.id === v)?.label ?? v;
            const res = m.resultats[v];
            return (
              <p key={v} className="text-xs">
                <span className="font-semibold">{lib} — </span>
                {res ?? "Rien d'anormal de ce côté."}
              </p>
            );
          })}
        </div>
      ) : null}

      <Panel>
        <Stat label="Vérifications utilisées" value={`${faites.length}`} />
        <Stat
          label="Cause trouvée"
          value={trouve ? "oui" : "pas encore"}
          color={trouve ? PALETTE.green : PALETTE.slate}
        />
      </Panel>

      {trouve ? (
        <Verdict tone="ok">
          Trouvé en {faites.length} vérification{faites.length > 1 ? "s" : ""}. {m.cause} Recommence
          sur une autre machine en essayant de descendre encore : le but n&apos;est pas de trouver,
          c&apos;est de trouver vite.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Avance dans l&apos;ordre du cours : observer, questionner, vérifier l&apos;évident, puis
          isoler matériel ou logiciel avec la séquence POST. Et une seule hypothèse à la fois.
        </Verdict>
      )}

      <button
        type="button"
        onClick={() => setMontre(!montre)}
        className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
      >
        {montre ? "Cacher la cause" : "Donner la cause"}
      </button>
      {montre ? <Verdict tone="warn">{m.cause}</Verdict> : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 5 — La boîte à outils                                      */
/* ------------------------------------------------------------------ */

type OutilId =
  | "tournevis"
  | "pince"
  | "souffleur"
  | "bracelet"
  | "fer"
  | "etain"
  | "pompe"
  | "multimetre"
  | "antivirus"
  | "cle"
  | "cdsysteme"
  | "pilotes";

const OUTILS: ReadonlyArray<{ id: OutilId; label: string; genre: "materiel" | "logiciel" }> = [
  { id: "tournevis", label: "Tournevis plat et cruciforme", genre: "materiel" },
  { id: "pince", label: "Pince", genre: "materiel" },
  { id: "souffleur", label: "Souffleur", genre: "materiel" },
  { id: "bracelet", label: "Bracelet antistatique", genre: "materiel" },
  { id: "fer", label: "Fer à souder", genre: "materiel" },
  { id: "etain", label: "Étain", genre: "materiel" },
  { id: "pompe", label: "Pompe à dessouder", genre: "materiel" },
  { id: "multimetre", label: "Multimètre", genre: "materiel" },
  { id: "antivirus", label: "Antivirus à jour", genre: "logiciel" },
  { id: "cle", label: "Clé de démarrage amorçable", genre: "logiciel" },
  { id: "cdsysteme", label: "Image du système", genre: "logiciel" },
  { id: "pilotes", label: "Jeu de pilotes", genre: "logiciel" },
];

const MISSIONS: ReadonlyArray<{
  titre: string;
  requis: ReadonlyArray<OutilId>;
  echec: string;
  succes: string;
}> = [
  {
    titre: "Ouvrir une unité centrale et rasseoir une barrette de mémoire.",
    requis: ["tournevis", "bracelet"],
    echec:
      "Sans tournevis tu n'ouvres pas le boîtier ; et sans bracelet antistatique, la décharge de ton corps peut griller la barrette sans que tu sentes rien.",
    succes: "Boîtier ouvert, bracelet au poignet, barrette rasseyée. Travail propre.",
  },
  {
    titre: "Une machine très lente, pleine de raccourcis sur le bureau.",
    requis: ["antivirus"],
    echec: "Sans antivirus à jour, tu ne peux ni confirmer l'infection ni la nettoyer.",
    succes: "Analyse lancée, fichiers infectés mis en quarantaine, clé USB nettoyée aussi.",
  },
  {
    titre: "Une machine qui ne démarre plus du tout sur son disque.",
    requis: ["cle"],
    echec:
      "Sans clé amorçable, tu n'as aucun moyen d'entrer dans la machine pour voir ce qui reste récupérable.",
    succes:
      "Démarrage sur la clé : tu accèdes au disque et tu sauves les fichiers de l'utilisateur.",
  },
  {
    titre: "Vérifier si un bloc d'alimentation sort bien ses tensions.",
    requis: ["multimetre"],
    echec: "Sans multimètre, tu ne fais que deviner. On ne remplace pas une pièce au hasard.",
    succes: "Mesure faite : le 12 V est absent, l'alimentation est bien en cause.",
  },
  {
    titre: "Réinstaller un poste et lui rendre son son et son réseau.",
    requis: ["cdsysteme", "pilotes"],
    echec:
      "L'image du système ne suffit pas : après l'installation, sans les pilotes, la carte son et la carte réseau resteront muettes.",
    succes: "Système réinstallé, pilotes posés, tout fonctionne avant de rendre la machine.",
  },
];

const MISSION_DEFAUT = MISSIONS[0] ?? { titre: "", requis: [], echec: "", succes: "" };

export function BoiteOutils() {
  const [sacoche, setSacoche] = useState<OutilId[]>([]);
  const [mi, setMi] = useState(0);

  const m = MISSIONS[mi] ?? MISSION_DEFAUT;
  const manquants = m.requis.filter((r) => !sacoche.includes(r));
  const pret = manquants.length === 0;

  const bascule = (id: OutilId) =>
    setSacoche((s) => (s.includes(id) ? s.filter((x) => x !== id) : [...s, id]));

  const nomOutil = (id: OutilId) => OUTILS.find((o) => o.id === id)?.label ?? id;

  return (
    <div className="space-y-3">
      <div className="space-y-1.5">
        <p className="text-xs font-medium text-muted-foreground">
          Outils matériels — clique pour les mettre dans la sacoche
        </p>
        <div className="flex flex-wrap gap-1.5">
          {OUTILS.filter((o) => o.genre === "materiel").map((o) => (
            <button
              key={o.id}
              type="button"
              onClick={() => bascule(o.id)}
              className={
                sacoche.includes(o.id)
                  ? "rounded-lg bg-primary px-2.5 py-1.5 text-[11px] font-semibold text-primary-foreground"
                  : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-[11px] font-medium hover:bg-secondary/60"
              }
            >
              {o.label}
            </button>
          ))}
        </div>
      </div>

      <div className="space-y-1.5">
        <p className="text-xs font-medium text-muted-foreground">Outils logiciels</p>
        <div className="flex flex-wrap gap-1.5">
          {OUTILS.filter((o) => o.genre === "logiciel").map((o) => (
            <button
              key={o.id}
              type="button"
              onClick={() => bascule(o.id)}
              className={
                sacoche.includes(o.id)
                  ? "rounded-lg bg-primary px-2.5 py-1.5 text-[11px] font-semibold text-primary-foreground"
                  : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-[11px] font-medium hover:bg-secondary/60"
              }
            >
              {o.label}
            </button>
          ))}
        </div>
      </div>

      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-[11px] text-muted-foreground">
          Intervention {mi + 1} sur {MISSIONS.length}
        </p>
        <p className="text-sm font-medium">{m.titre}</p>
      </div>

      <Panel>
        <Stat label="Outils emportés" value={`${sacoche.length}`} />
        <Stat
          label="Prêt pour cette intervention"
          value={pret ? "oui" : "non"}
          color={pret ? PALETTE.green : PALETTE.red}
        />
      </Panel>

      {pret ? (
        <Verdict tone="ok">{m.succes}</Verdict>
      ) : (
        <Verdict tone="bad">
          Il te manque : {manquants.map(nomOutil).join(", ")}. {m.echec}
        </Verdict>
      )}

      <button
        type="button"
        onClick={() => setMi((v) => (v + 1) % MISSIONS.length)}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        Intervention suivante
      </button>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 6 — Reconnaître les types de virus                         */
/* ------------------------------------------------------------------ */

export function TypesVirus() {
  return (
    <JeuClassement
      aide="Ne regarde pas ce que le programme détruit, regarde comment il se comporte : se propage-t-il seul ? se déguise-t-il ? attend-il quelque chose ?"
      options={[
        { value: "ver", label: "Ver" },
        { value: "troie", label: "Cheval de Troie" },
        { value: "bombe", label: "Bombe logique" },
        { value: "macro", label: "Macrovirus" },
        { value: "espion", label: "Logiciel espion" },
      ]}
      cas={[
        {
          enonce:
            "Il passe d'une machine à l'autre à travers le réseau du lycée, sans que personne n'ouvre quoi que ce soit.",
          bonne: "ver",
          pourquoi: "C'est sa signature : il se propage seul, par le réseau.",
        },
        {
          enonce: "Il arrive déguisé en jeu gratuit et ouvre discrètement une porte à l'attaquant.",
          bonne: "troie",
          pourquoi:
            "Comme le cheval de bois des Grecs : ce qui le caractérise n'est pas ce qu'il détruit, c'est qu'il se déguise.",
        },
        {
          enonce: "Il dort sur la machine depuis trois mois et s'activera le 1er avril.",
          bonne: "bombe",
          pourquoi: "Elle attend une date ou un évènement fixé par son auteur.",
        },
        {
          enonce: "Il se loge dans les macros d'un fichier Excel du secrétariat.",
          bonne: "macro",
          pourquoi: "Il vit dans les macros d'un document bureautique, Word ou Excel.",
        },
        {
          enonce: "Il ne détruit rien : il note ce que tu tapes et l'envoie ailleurs.",
          bonne: "espion",
          pourquoi:
            "Il observe et transmet. L'absence de dégât visible est justement ce qui le rend durable.",
        },
        {
          enonce:
            "Il se déclenche le jour où le nom d'un employé disparaît de la liste du personnel.",
          bonne: "bombe",
          pourquoi:
            "Encore une bombe logique : le déclencheur n'est pas une date mais un évènement précis.",
        },
        {
          enonce:
            "Il se présente comme un utilitaire qui nettoie le disque, et chiffre les fichiers à la place.",
          bonne: "troie",
          pourquoi: "Le déguisement en programme utile est la marque du cheval de Troie.",
        },
      ]}
    />
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 6 — La machine est-elle infectée ?                         */
/* ------------------------------------------------------------------ */

export function MachineInfectee() {
  return (
    <JeuClassement
      aide="Résiste à la tentation de conclure au virus. Cherche d'abord une explication plus simple : disque plein, surchauffe, pilote absent."
      options={[
        { value: "virus", label: "Un virus" },
        { value: "autre", label: "Une autre cause" },
      ]}
      cas={[
        {
          enonce: "Tes dossiers sont devenus des raccourcis sur la clé USB, et ils ont disparu.",
          bonne: "virus",
          pourquoi:
            "C'est la signature la plus connue au Cameroun. Les fichiers ne sont pas perdus : ils sont cachés. Surtout, ne clique sur aucun raccourci.",
        },
        {
          enonce: "La machine est lente, et son disque dur est rempli à 98 %.",
          bonne: "autre",
          pourquoi:
            "Un disque saturé explique à lui seul la lenteur. Nettoie d'abord, et vois si cela suffit.",
        },
        {
          enonce: "L'antivirus se désactive tout seul et refuse de se relancer.",
          bonne: "virus",
          pourquoi:
            "C'est le signe qui ne trompe presque jamais : beaucoup de programmes malveillants commencent par neutraliser l'antivirus.",
        },
        {
          enonce:
            "La machine redémarre toute seule après une heure, et son ventilateur est bouché.",
          bonne: "autre",
          pourquoi: "C'est une surchauffe. Souffle les grilles avant de soupçonner autre chose.",
        },
        {
          enonce: "Des fenêtres de publicité s'ouvrent seules, même sans navigateur ouvert.",
          bonne: "virus",
          pourquoi:
            "Un lancement automatique de programmes que tu n'as pas demandés est une manifestation typique.",
        },
        {
          enonce: "Plus aucun son depuis la réinstallation de Windows la semaine dernière.",
          bonne: "autre",
          pourquoi:
            "Le pilote de la carte son n'a pas été réinstallé. Un périphérique sans pilote est inutilisable, même parfaitement branché.",
        },
        {
          enonce:
            "La mémoire vive est saturée par un programme inconnu qui revient à chaque démarrage.",
          bonne: "virus",
          pourquoi:
            "Saturation de la mémoire, programme inconnu, retour automatique au démarrage : trois signes concordants.",
        },
        {
          enonce:
            "Le document Word du devoir ne s'ouvre plus et affiche des caractères illisibles.",
          bonne: "autre",
          pourquoi:
            "Un seul fichier abîmé est le plus souvent un fichier corrompu — clé retirée pendant l'écriture, coupure de courant. Un virus s'attaque rarement à un seul document.",
        },
      ]}
    />
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 6 — Analyser et nettoyer                                   */
/* ------------------------------------------------------------------ */

type Decision = "attente" | "reparer" | "supprimer" | "quarantaine" | "ignorer";

const DETECTES: ReadonlyArray<{
  nom: string;
  vraiVirus: boolean;
  reparable: boolean;
  recent: boolean;
  commentaire: string;
}> = [
  {
    nom: "autorun.inf (clé USB)",
    vraiVirus: true,
    reparable: false,
    recent: true,
    commentaire:
      "C'est le fichier qui relance le virus à chaque branchement. Rien à sauver dedans.",
  },
  {
    nom: "devoir-maths.docx",
    vraiVirus: true,
    reparable: true,
    recent: true,
    commentaire: "Un macrovirus s'est logé dans le document. Le texte du devoir, lui, est intact.",
  },
  {
    nom: "mandal-outils.exe",
    vraiVirus: false,
    reparable: false,
    recent: false,
    commentaire:
      "Faux positif : c'est un petit utilitaire du lycée, signalé par l'analyse comportementale parce qu'il modifie beaucoup de fichiers.",
  },
  {
    nom: "svch0st.exe (démarrage)",
    vraiVirus: true,
    reparable: false,
    recent: true,
    commentaire:
      "Le nom imite celui d'un vrai programme du système, avec un zéro à la place du o. C'est un cheval de Troie.",
  },
  {
    nom: "photos-rentree.jpg",
    vraiVirus: false,
    reparable: false,
    recent: false,
    commentaire: "Faux positif : une photographie ordinaire, seul exemplaire de la cérémonie.",
  },
];

export function ScanAntivirus() {
  const [aJour, setAJour] = useState(true);
  const [lance, setLance] = useState(false);
  const [dec, setDec] = useState<Record<string, Decision>>({});

  // un antivirus non à jour ne reconnaît pas les menaces récentes
  const visibles = DETECTES.filter((d) => aJour || !d.recent);
  const rates = DETECTES.filter((d) => d.vraiVirus && !aJour && d.recent);

  const bilan = visibles.map((d) => {
    const choix = dec[d.nom] ?? "attente";
    if (choix === "attente")
      return { d, tone: "warn" as const, texte: "En attente de ta décision." };
    if (d.vraiVirus) {
      if (choix === "ignorer")
        return {
          d,
          tone: "bad" as const,
          texte: "Laissé en place : il continue d'agir et de se propager.",
        };
      if (choix === "reparer")
        return d.reparable
          ? {
              d,
              tone: "ok" as const,
              texte: "Désinfecté, et le fichier est conservé. C'était le meilleur choix.",
            }
          : {
              d,
              tone: "warn" as const,
              texte: "Désinfection impossible sur ce fichier : il faut le supprimer ou l'isoler.",
            };
      if (choix === "supprimer")
        return d.reparable
          ? {
              d,
              tone: "warn" as const,
              texte:
                "Menace écartée, mais le devoir est parti avec. Une réparation l'aurait sauvé.",
            }
          : {
              d,
              tone: "ok" as const,
              texte: "Supprimé : rien à sauver dedans, c'était le bon choix.",
            };
      return {
        d,
        tone: "ok" as const,
        texte: "Isolé en quarantaine : il ne peut plus rien faire, et tu peux encore décider.",
      };
    }
    if (choix === "supprimer")
      return {
        d,
        tone: "bad" as const,
        texte:
          "Fichier sain détruit. C'était un faux positif, et il n'y en avait qu'un exemplaire.",
      };
    if (choix === "reparer")
      return {
        d,
        tone: "warn" as const,
        texte: "Il n'y avait rien à réparer : le fichier était sain.",
      };
    if (choix === "quarantaine")
      return {
        d,
        tone: "ok" as const,
        texte: "Isolé sans être détruit : récupérable dès que tu confirmes qu'il est sain.",
      };
    return { d, tone: "ok" as const, texte: "Ignoré à juste titre : le fichier était sain." };
  });

  const degats = bilan.filter((b) => b.tone === "bad").length;
  const traites = bilan.filter((b) => (dec[b.d.nom] ?? "attente") !== "attente").length;

  return (
    <div className="space-y-3">
      <Choice<"oui" | "non">
        label="L'antivirus est-il à jour ?"
        value={aJour ? "oui" : "non"}
        options={[
          { value: "oui", label: "À jour" },
          { value: "non", label: "Pas mis à jour depuis six mois" },
        ]}
        onChange={(v) => {
          setAJour(v === "oui");
          setDec({});
          setLance(false);
        }}
      />

      {!lance ? (
        <button
          type="button"
          onClick={() => setLance(true)}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Lancer l&apos;analyse
        </button>
      ) : (
        <div className="space-y-2">
          {bilan.map((b) => (
            <div
              key={b.d.nom}
              className="rounded-lg border border-border bg-background p-3 space-y-2"
            >
              <p className="font-mono text-xs font-semibold">{b.d.nom}</p>
              <Choice<Decision>
                value={dec[b.d.nom] ?? "attente"}
                options={[
                  { value: "reparer", label: "Réparer" },
                  { value: "supprimer", label: "Supprimer" },
                  { value: "quarantaine", label: "Quarantaine" },
                  { value: "ignorer", label: "Ne rien faire" },
                ]}
                onChange={(v) => setDec({ ...dec, [b.d.nom]: v })}
              />
              <Verdict tone={b.tone}>{b.texte}</Verdict>
              {(dec[b.d.nom] ?? "attente") !== "attente" ? (
                <p className="text-[11px] text-muted-foreground">{b.d.commentaire}</p>
              ) : null}
            </div>
          ))}
        </div>
      )}

      {lance ? (
        <Panel>
          <Stat label="Fichiers détectés" value={`${visibles.length}`} />
          <Stat label="Traités" value={`${traites} / ${visibles.length}`} />
          <Stat
            label="Dégâts"
            value={`${degats}`}
            color={degats > 0 ? PALETTE.red : PALETTE.green}
          />
          <Stat
            label="Menaces non vues"
            value={`${rates.length}`}
            color={rates.length > 0 ? PALETTE.red : PALETTE.green}
          />
        </Panel>
      ) : null}

      {lance && rates.length > 0 ? (
        <Verdict tone="bad">
          Attention : {rates.length} menace{rates.length > 1 ? "s" : ""} n&apos;apparaît même pas
          dans la liste. Un antivirus non mis à jour ne connaît pas les virus de ce mois-ci : sa
          détection repose sur un dictionnaire de signatures, et le sien a six mois de retard.
          Remets-le à jour et relance.
        </Verdict>
      ) : null}

      {lance && aJour ? (
        <Verdict tone="warn">
          Deux des fichiers signalés sont sains : ce sont des faux positifs de l&apos;analyse
          comportementale. C&apos;est pour cela que la quarantaine est le bon réflexe dans le doute
          : elle neutralise sans détruire.
        </Verdict>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 7 — Défragmenter un disque                                 */
/* ------------------------------------------------------------------ */

const NB_BLOCS = 48;
const COULEURS_FICHIERS = ["#2563eb", "#16a34a", "#ea580c", "#7c3aed", "#0f766e", "#be185d"];
const TAILLES = [4, 3, 5, 2, 4, 3];

function etatInitial(): number[] {
  // un disque déjà vécu : trois fichiers entrelacés
  const b = new Array<number>(NB_BLOCS).fill(0);
  const motif = [1, 0, 2, 1, 0, 3, 2, 0, 1, 3, 0, 2, 3, 0, 1, 0, 2, 0, 3, 1, 0, 2, 0, 0];
  for (let k = 0; k < motif.length; k += 1) b[k] = motif[k] ?? 0;
  return b;
}

export function Defragmentation() {
  const [blocs, setBlocs] = useState<number[]>(etatInitial);
  const [ssd, setSsd] = useState(false);
  const [prochain, setProchain] = useState(4);

  const presents = Array.from(new Set(blocs.filter((v) => v > 0))).sort((a, b) => a - b);

  // nombre de morceaux par fichier
  let morceaux = 0;
  for (const f of presents) {
    let dedans = false;
    for (const v of blocs) {
      if (v === f && !dedans) {
        morceaux += 1;
        dedans = true;
      } else if (v !== f) {
        dedans = false;
      }
    }
  }
  const sauts = Math.max(0, morceaux - presents.length);
  const tempsMecanique = 0.4 + sauts * 0.35;
  const temps = ssd ? 0.4 : tempsMecanique;
  const libres = blocs.filter((v) => v === 0).length;

  const ecrire = () => {
    const taille = TAILLES[(prochain - 1) % TAILLES.length] ?? 3;
    if (libres < taille) return;
    const suite = [...blocs];
    let pose = 0;
    for (let k = 0; k < NB_BLOCS && pose < taille; k += 1) {
      if (suite[k] === 0) {
        suite[k] = prochain;
        pose += 1;
      }
    }
    setBlocs(suite);
    setProchain(prochain + 1);
  };

  const supprimer = () => {
    const cible = presents[0];
    if (cible === undefined) return;
    setBlocs(blocs.map((v) => (v === cible ? 0 : v)));
  };

  const defragmenter = () => {
    const pleins = blocs.filter((v) => v > 0).sort((a, b) => a - b);
    const suite = new Array<number>(NB_BLOCS).fill(0);
    for (let k = 0; k < pleins.length; k += 1) suite[k] = pleins[k] ?? 0;
    setBlocs(suite);
  };

  const W = 440;
  const H = 150;
  const col = 12;
  const taille = 32;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {blocs.map((v, k) => {
          const x = 20 + (k % col) * taille;
          const y = 22 + Math.floor(k / col) * taille;
          const couleur =
            v === 0
              ? "#f1f5f9"
              : (COULEURS_FICHIERS[(v - 1) % COULEURS_FICHIERS.length] ?? "#2563eb");
          return (
            <rect
              key={k}
              x={x}
              y={y}
              width={taille - 2}
              height={taille - 2}
              rx={2}
              fill={couleur}
              stroke={v === 0 ? "#cbd5e1" : "none"}
              strokeWidth={1}
            />
          );
        })}
      </Board>

      <Choice<"hdd" | "ssd">
        label="Type de disque"
        value={ssd ? "ssd" : "hdd"}
        options={[
          { value: "hdd", label: "Disque mécanique" },
          { value: "ssd", label: "SSD" },
        ]}
        onChange={(v) => setSsd(v === "ssd")}
      />

      <div className="flex flex-wrap gap-2">
        <button
          type="button"
          onClick={ecrire}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
        >
          Écrire un fichier
        </button>
        <button
          type="button"
          onClick={supprimer}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
        >
          Supprimer le plus ancien
        </button>
        <button
          type="button"
          onClick={defragmenter}
          disabled={ssd}
          className={
            ssd
              ? "rounded-lg border border-border bg-secondary/40 px-3 py-1.5 text-xs font-medium text-muted-foreground/50"
              : "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          }
        >
          Défragmenter
        </button>
        <button
          type="button"
          onClick={() => {
            setBlocs(etatInitial());
            setProchain(4);
          }}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Remettre à zéro
        </button>
      </div>

      <Panel>
        <Stat label="Fichiers" value={`${presents.length}`} />
        <Stat
          label="Morceaux au total"
          value={`${morceaux}`}
          color={sauts > 0 ? PALETTE.red : PALETTE.green}
        />
        <Stat label="Blocs libres" value={`${libres} / ${NB_BLOCS}`} />
        <Stat label="Temps de lecture" value={`${fmt(temps, 2)} s`} color={PALETTE.purple} />
      </Panel>

      {ssd ? (
        <Verdict tone="warn">
          Sur un SSD, le bouton est désactivé — comme le font les systèmes récents. Regarde le temps
          de lecture : il ne bouge pas, quelle que soit la fragmentation, parce qu&apos;un SSD
          n&apos;a pas de tête de lecture à déplacer et accède partout à la même vitesse.
          Défragmenter ne gagnerait rien et userait sa mémoire pour rien.
        </Verdict>
      ) : sauts === 0 ? (
        <Verdict tone="ok">
          Chaque fichier est d&apos;un seul morceau : {morceaux} morceaux pour {presents.length}{" "}
          fichiers. La tête de lecture lit d&apos;une traite, et le temps est au minimum. Écris et
          supprime quelques fichiers pour voir la fragmentation revenir d&apos;elle-même.
        </Verdict>
      ) : (
        <Verdict tone="bad">
          {morceaux} morceaux pour seulement {presents.length} fichiers, soit {sauts} déplacement
          {sauts > 1 ? "s" : ""} de la tête de lecture en trop. Chacun coûte du temps, et c&apos;est
          exactement ce que la défragmentation supprime.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 7 — Partitionner un disque                                 */
/* ------------------------------------------------------------------ */

type Scenario = "reinstall" | "virus" | "panne";

export function Partitionnement() {
  const [tailleC, setTailleC] = useState(120);
  const [ou, setOu] = useState<"C" | "D">("D");
  const [sc, setSc] = useState<Scenario>("reinstall");

  const total = 500;
  const tailleD = total - tailleC;
  const systemeTient = tailleC >= 60;

  const perdu = sc === "panne" ? true : sc === "reinstall" ? ou === "C" : ou === "C";

  const W = 440;
  const H = 130;
  const larg = 400;
  const largC = (tailleC / total) * larg;

  const explication =
    sc === "reinstall"
      ? ou === "C"
        ? "La réinstallation reformate C:. Tes documents y étaient : ils sont effacés avec le système."
        : "On reformate C: pour réinstaller le système, et D: n'est pas touchée. Tes documents sont intacts : c'est tout l'intérêt de la séparation."
      : sc === "virus"
        ? ou === "C"
          ? "Le virus a chiffré le contenu de C:, où se trouvaient tes documents. Ils sont inaccessibles."
          : "Ce virus-là ne s'est attaqué qu'au volume système. Tes documents sur D: ont échappé — mais ce n'est pas une règle : beaucoup de rançongiciels parcourent tous les volumes."
        : "Le disque est mort physiquement. C: et D: étaient deux parties du MÊME disque : les deux disparaissent ensemble. Une partition n'est pas une sauvegarde.";

  return (
    <div className="space-y-3">
      <Ctrl
        label="Taille de la partition système C:"
        value={tailleC}
        min={20}
        max={460}
        step={10}
        onChange={setTailleC}
        display={`${tailleC} Go`}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={220} y={22} textAnchor="middle" fontSize={11} fontWeight={700} fill={PALETTE.ink}>
          Un seul disque physique de {total} Go
        </text>

        <rect
          x={20}
          y={36}
          width={larg}
          height={46}
          rx={4}
          fill="#f1f5f9"
          stroke="#334155"
          strokeWidth={1.6}
        />
        <rect x={20} y={36} width={largC} height={46} fill="#dbeafe" />
        <rect x={20 + largC} y={36} width={larg - largC} height={46} fill="#dcfce7" />
        <line x1={20 + largC} y1={36} x2={20 + largC} y2={82} stroke="#334155" strokeWidth={2} />

        <text
          x={20 + largC / 2}
          y={56}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill="#1e3a8a"
        >
          C:
        </text>
        <text x={20 + largC / 2} y={72} textAnchor="middle" fontSize={9} fill="#1e40af">
          {tailleC} Go — système
        </text>
        <text
          x={20 + largC + (larg - largC) / 2}
          y={56}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill="#14532d"
        >
          D:
        </text>
        <text
          x={20 + largC + (larg - largC) / 2}
          y={72}
          textAnchor="middle"
          fontSize={9}
          fill="#166534"
        >
          {tailleD} Go — données
        </text>

        <text x={20} y={104} fontSize={10} fill={PALETTE.slate}>
          Tes documents sont sur :
        </text>
        <text
          x={160}
          y={104}
          fontSize={11}
          fontWeight={700}
          fill={ou === "C" ? "#1e3a8a" : "#14532d"}
        >
          {ou}:
        </text>
        <text
          x={220}
          y={120}
          textAnchor="middle"
          fontSize={11}
          fontWeight={700}
          fill={perdu ? "#b91c1c" : "#15803d"}
        >
          {perdu ? "DOCUMENTS PERDUS" : "DOCUMENTS INTACTS"}
        </text>
      </Board>

      <Choice<"C" | "D">
        label="Où ranges-tu tes documents ?"
        value={ou}
        options={[
          { value: "C", label: "Sur C:, avec le système" },
          { value: "D", label: "Sur D:, à part" },
        ]}
        onChange={setOu}
      />

      <Choice<Scenario>
        label="Scénario à envoyer sur la machine"
        value={sc}
        options={[
          { value: "reinstall", label: "Réinstaller le système" },
          { value: "virus", label: "Un virus chiffre C:" },
          { value: "panne", label: "Panne mécanique du disque" },
        ]}
        onChange={setSc}
      />

      {!systemeTient ? (
        <Verdict tone="warn">
          Avec seulement {tailleC} Go, C: est trop petite : le système et ses mises à jour vont la
          saturer en quelques mois. Compte au moins 60 à 100 Go pour le volume système.
        </Verdict>
      ) : null}

      <Verdict tone={perdu ? "bad" : "ok"}>{explication}</Verdict>

      {sc !== "panne" ? (
        <p className="text-xs text-muted-foreground">
          Essaie maintenant le troisième scénario, la panne mécanique. C&apos;est celui qui fait
          comprendre la différence entre une partition et une sauvegarde : une vraie sauvegarde est
          sur un <strong>autre support</strong>, et de préférence rangée ailleurs.
        </p>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 7 — Rendre sa vitesse à une machine                        */
/* ------------------------------------------------------------------ */

type OpId = "temp" | "cache" | "corbeille" | "desinstall" | "demarrage" | "antivirus" | "defrag";

const OPERATIONS: ReadonlyArray<{
  id: OpId;
  label: string;
  go: number;
  secondes: number;
  note: string;
}> = [
  {
    id: "temp",
    label: "Vider les fichiers temporaires",
    go: 6,
    secondes: 3,
    note: "Gratuit, rapide, sans risque.",
  },
  {
    id: "cache",
    label: "Vider le cache du navigateur",
    go: 9,
    secondes: 2,
    note: "Souvent plusieurs gigaoctets à lui seul.",
  },
  {
    id: "corbeille",
    label: "Vider la corbeille",
    go: 14,
    secondes: 1,
    note: "Beaucoup d'utilisateurs ne la vident jamais.",
  },
  {
    id: "desinstall",
    label: "Désinstaller les programmes inutilisés",
    go: 22,
    secondes: 6,
    note: "Depuis le panneau de configuration, jamais en supprimant leur dossier.",
  },
  {
    id: "demarrage",
    label: "Désactiver les programmes au démarrage",
    go: 0,
    secondes: 34,
    note: "C'est le plus gros gain sur le temps de démarrage, et il ne libère aucun espace.",
  },
  {
    id: "antivirus",
    label: "Lancer une analyse antivirus",
    go: 2,
    secondes: 9,
    note: "Un virus consomme lui aussi du processeur et de la mémoire.",
  },
  {
    id: "defrag",
    label: "Défragmenter le disque",
    go: 0,
    secondes: 11,
    note: "À ne faire qu'après avoir libéré de l'espace, et seulement sur un disque mécanique.",
  },
];

export function NettoyageDisque() {
  const [faites, setFaites] = useState<OpId[]>([]);

  const capacite = 500;
  const occupeDepart = 470;
  const libere = OPERATIONS.filter((o) => faites.includes(o.id)).reduce((s, o) => s + o.go, 0);
  const occupe = Math.max(40, occupeDepart - libere);
  const taux = occupe / capacite;

  const gagne = OPERATIONS.filter((o) => faites.includes(o.id)).reduce((s, o) => s + o.secondes, 0);
  // défragmenter avant d'avoir libéré de la place ne sert presque à rien
  const defragTot = faites.includes("defrag") && taux > 0.85;
  const demarrage = Math.max(14, 92 - gagne + (defragTot ? 9 : 0));

  const bascule = (id: OpId) =>
    setFaites((s) => (s.includes(id) ? s.filter((x) => x !== id) : [...s, id]));

  const W = 440;
  const H = 120;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={20} y={24} fontSize={11} fontWeight={700} fill={PALETTE.ink}>
          Disque dur — {fmt(occupe, 0)} Go occupés sur {capacite}
        </text>

        <rect
          x={20}
          y={34}
          width={400}
          height={26}
          rx={5}
          fill="#f1f5f9"
          stroke="#cbd5e1"
          strokeWidth={1.2}
        />
        <rect
          x={20}
          y={34}
          width={400 * taux}
          height={26}
          rx={5}
          fill={taux > 0.9 ? "#dc2626" : taux > 0.75 ? "#ca8a04" : "#16a34a"}
        />
        <text x={220} y={52} textAnchor="middle" fontSize={11} fontWeight={700} fill="#ffffff">
          {fmt(taux * 100, 0)} %
        </text>

        <text x={20} y={86} fontSize={11} fontWeight={700} fill={PALETTE.ink}>
          Temps de démarrage
        </text>
        <rect
          x={20}
          y={94}
          width={400}
          height={18}
          rx={4}
          fill="#f1f5f9"
          stroke="#cbd5e1"
          strokeWidth={1.2}
        />
        <rect
          x={20}
          y={94}
          width={400 * clamp(demarrage / 92, 0.05, 1)}
          height={18}
          rx={4}
          fill={demarrage <= 30 ? "#16a34a" : demarrage <= 60 ? "#ca8a04" : "#dc2626"}
        />
        <text x={220} y={108} textAnchor="middle" fontSize={10} fontWeight={700} fill="#ffffff">
          {demarrage} s
        </text>
      </Board>

      <div className="space-y-1.5">
        <p className="text-xs font-medium text-muted-foreground">
          Choisis tes opérations, dans l&apos;ordre que tu veux
        </p>
        <div className="flex flex-wrap gap-1.5">
          {OPERATIONS.map((o) => (
            <button
              key={o.id}
              type="button"
              onClick={() => bascule(o.id)}
              className={
                faites.includes(o.id)
                  ? "rounded-lg bg-primary px-2.5 py-1.5 text-[11px] font-semibold text-primary-foreground"
                  : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-[11px] font-medium hover:bg-secondary/60"
              }
            >
              {o.label}
            </button>
          ))}
        </div>
      </div>

      <Panel>
        <Stat label="Espace libéré" value={`${fmt(libere, 0)} Go`} color={PALETTE.green} />
        <Stat label="Taux de remplissage" value={`${fmt(taux * 100, 0)} %`} />
        <Stat label="Démarrage" value={`${demarrage} s`} color={PALETTE.purple} />
        <Stat label="Opérations faites" value={`${faites.length} / ${OPERATIONS.length}`} />
      </Panel>

      {defragTot ? (
        <Verdict tone="bad">
          Tu as défragmenté alors que le disque est encore rempli à {fmt(taux * 100, 0)} %. Sans
          espace libre pour déplacer les morceaux, l&apos;opération traîne et n&apos;arrange presque
          rien : elle a même coûté du temps. Libère d&apos;abord, défragmente ensuite.
        </Verdict>
      ) : demarrage <= 30 ? (
        <Verdict tone="ok">
          {demarrage} secondes au démarrage : objectif atteint. Remarque lequel des boutons a fait
          la vraie différence — désactiver les programmes au démarrage ne libère pas un seul
          gigaoctet, et c&apos;est pourtant lui qui a le plus accéléré la machine.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Encore {demarrage} secondes. Essaie de descendre sous trente. Deux pistes : l&apos;espace
          disque d&apos;abord, les programmes qui se lancent sans qu&apos;on le leur demande
          ensuite.
        </Verdict>
      )}

      {faites.length > 0 ? (
        <div className="space-y-1 rounded-lg border border-border bg-background p-3">
          {OPERATIONS.filter((o) => faites.includes(o.id)).map((o) => (
            <p key={o.id} className="text-[11px] text-muted-foreground">
              <span className="font-semibold text-foreground">{o.label} — </span>
              {o.note}
            </p>
          ))}
        </div>
      ) : null}
    </div>
  );
}
