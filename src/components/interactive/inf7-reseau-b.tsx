import { useState } from "react";
import { Choice, Ctrl, PALETTE, Panel, Stat, Verdict } from "./controls";

/** Informatique Terminale C et D — chapitres 9 et 10 : supports, équipements, adressage. */

/* ------------------------------------------------------------------ */
/* Chapitre 9 — Choisir le support                                     */
/* ------------------------------------------------------------------ */

const SUPPORTS = [
  {
    value: "paire",
    label: "Paire torsadée",
    debit: 1000,
    portee: 100,
    cout: 1,
    expo: "nulle",
  },
  { value: "coax", label: "Câble coaxial", debit: 100, portee: 500, cout: 2, expo: "nulle" },
  { value: "fibre", label: "Fibre optique", debit: 10000, portee: 40000, cout: 6, expo: "nulle" },
  { value: "wifi", label: "Wi-Fi", debit: 300, portee: 50, cout: 2, expo: "forte" },
] as const;

const LOCAUX = [
  {
    id: "l1",
    nom: "Une salle de classe où l'on ne peut percer aucun mur",
    bon: "wifi",
    pourquoi:
      "Sans percement possible, le sans-fil est la seule réponse. Il faudra seulement accepter un débit partagé entre tous les postes.",
  },
  {
    id: "l2",
    nom: "Une salle de montage vidéo, quatre postes qui échangent des fichiers lourds",
    bon: "fibre",
    pourquoi:
      "Le montage vidéo exige un débit qu'aucun autre support ne tient. La fibre coûte cher, mais c'est le seul cas où elle se justifie à l'intérieur d'un bâtiment.",
  },
  {
    id: "l3",
    nom: "Un amphithéâtre de deux cents places, pour que chacun consulte le cours",
    bon: "wifi",
    pourquoi:
      "Deux cents prises réseau sont impensables. Plusieurs bornes Wi-Fi, oui — en acceptant que le débit se partage.",
  },
  {
    id: "l4",
    nom: "Relier deux bâtiments séparés de huit cents mètres",
    bon: "fibre",
    pourquoi:
      "Huit cents mètres : la paire torsadée s'arrête à cent, le coaxial à cinq cents. La fibre est la seule qui franchit la distance, et en plus elle est insensible à la foudre entre les deux bâtiments.",
  },
  {
    id: "l5",
    nom: "Dix postes dans une même salle, budget serré",
    bon: "paire",
    pourquoi:
      "C'est le cas ordinaire, et la paire torsadée est faite pour lui : cent mètres suffisent largement, le gigabit suffit largement, et c'est le support le moins cher.",
  },
  {
    id: "l6",
    nom: "Un bâtiment classé où l'on ne touche ni aux murs ni aux plafonds",
    bon: "wifi",
    pourquoi:
      "Aucune installation permise : le sans-fil, encore. On place les bornes sur des pieds et on les alimente par les prises existantes.",
  },
] as const;

export function SupportsTransmission() {
  const [choix, setChoix] = useState<Record<string, string>>({});
  const [postes, setPostes] = useState(10);

  const bons = LOCAUX.filter((l) => choix[l.id] === l.bon).length;

  return (
    <div className="space-y-3">
      <Ctrl
        label="Postes dans le local"
        value={postes}
        min={2}
        max={30}
        step={1}
        onChange={setPostes}
        display={`${postes}`}
      />

      <div className="space-y-3">
        {LOCAUX.map((l) => {
          const c = choix[l.id];
          const s = SUPPORTS.find((x) => x.value === c);
          const juste = c === l.bon;
          // Le sans-fil partage son débit entre tous les postes ; le filaire le donne à chacun.
          const parPoste = s ? (s.value === "wifi" ? Math.round(s.debit / postes) : s.debit) : 0;
          return (
            <div
              key={l.id}
              className="space-y-1 rounded-lg border border-border bg-background p-2.5"
            >
              <p className="text-xs font-medium">{l.nom}</p>
              <div className="flex flex-wrap gap-1.5">
                {SUPPORTS.map((x) => {
                  const actif = c === x.value;
                  const cls = !actif
                    ? "border-border bg-background text-muted-foreground hover:bg-secondary/60"
                    : juste
                      ? "border-emerald-500/50 bg-emerald-500/10 text-emerald-700"
                      : "border-rose-500/50 bg-rose-500/10 text-rose-700";
                  return (
                    <button
                      key={x.value}
                      type="button"
                      onClick={() => setChoix({ ...choix, [l.id]: x.value })}
                      className={`rounded-lg border px-2 py-1 text-[11px] font-medium ${cls}`}
                    >
                      {x.label}
                    </button>
                  );
                })}
              </div>
              {s ? (
                <>
                  <div className="flex flex-wrap gap-2 text-[10px] text-muted-foreground">
                    <span>
                      Débit par poste :{" "}
                      <span className="font-mono font-semibold text-foreground">
                        {parPoste} Mbit/s
                      </span>
                    </span>
                    <span>
                      Portée :{" "}
                      <span className="font-mono font-semibold text-foreground">
                        {s.portee >= 1000 ? `${s.portee / 1000} km` : `${s.portee} m`}
                      </span>
                    </span>
                    <span>
                      Coût relatif :{" "}
                      <span className="font-mono font-semibold text-foreground">
                        {"×".repeat(s.cout)}
                      </span>
                    </span>
                    <span>
                      Exposition : <span className="font-semibold text-foreground">{s.expo}</span>
                    </span>
                  </div>
                  <p className="text-[11px]" style={{ color: juste ? PALETTE.green : PALETTE.red }}>
                    {juste
                      ? "Bon choix. "
                      : `Plutôt ${SUPPORTS.find((x) => x.value === l.bon)?.label ?? ""}. `}
                    {l.pourquoi}
                  </p>
                </>
              ) : null}
            </div>
          );
        })}
      </div>

      <Panel>
        <Stat label="Locaux bien équipés" value={`${bons} / ${LOCAUX.length}`} />
        <Stat
          label="La question qui tranche"
          value="distance, débit, contrainte"
          color={bons === LOCAUX.length ? PALETTE.green : PALETTE.ink}
        />
      </Panel>

      {bons === LOCAUX.length ? (
        <Verdict tone="ok">
          Les six locaux équipés. Retiens l&apos;ordre des questions : d&apos;abord{" "}
          <strong>quelle distance</strong> — c&apos;est elle qui élimine le plus de candidats — puis{" "}
          <strong>quel débit</strong>, et enfin <strong>quelle contrainte</strong> du bâtiment.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Monte le nombre de postes : le débit du Wi-Fi se divise entre toutes les machines, celui
          d&apos;un câble ne se divise pas. C&apos;est la différence la plus importante entre
          filaire et sans-fil, et celle qu&apos;on oublie le plus souvent.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 9 — Les trois câbles mis à l'épreuve                       */
/* ------------------------------------------------------------------ */

const CABLES = [
  {
    value: "utp",
    label: "Paire torsadée (UTP)",
    limite: 100,
    prix: 0.8,
    sensible: true,
    coupe: [
      "Quatre paires de fils de cuivre, torsadées deux à deux",
      "Une gaine isolante par fil",
      "Une gaine extérieure en PVC",
      "Pas de blindage : c'est le U de UTP, Unshielded",
    ],
  },
  {
    value: "stp",
    label: "Paire torsadée blindée (STP)",
    limite: 100,
    prix: 1.6,
    sensible: false,
    coupe: [
      "Les mêmes quatre paires torsadées",
      "Un blindage métallique autour de chaque paire, ou de l'ensemble",
      "Une gaine extérieure",
      "Le blindage se relie à la terre : c'est lui qui arrête les perturbations",
    ],
  },
  {
    value: "coax",
    label: "Câble coaxial",
    limite: 500,
    prix: 2.2,
    sensible: false,
    coupe: [
      "Une âme centrale en cuivre : c'est elle qui porte le signal",
      "Un isolant diélectrique autour de l'âme",
      "Une tresse métallique, qui sert de blindage et de retour",
      "Une gaine extérieure",
    ],
  },
  {
    value: "fibre",
    label: "Fibre optique",
    limite: 40000,
    prix: 5,
    sensible: false,
    coupe: [
      "Un cœur de verre très pur, d'un cheveu d'épaisseur",
      "Une gaine optique qui réfléchit la lumière vers le cœur",
      "Un revêtement de protection",
      "Une armature et une gaine extérieure",
      "Le signal est de la lumière, pas de l'électricité : aucune perturbation électromagnétique ne l'atteint",
    ],
  },
] as const;

export function CablesReseau() {
  const [distance, setDistance] = useState(80);
  const [perturbation, setPerturbation] = useState(20);
  const [ouvert, setOuvert] = useState<string>("utp");

  const c = CABLES.find((x) => x.value === ouvert) ?? CABLES[0];

  const signal = (cab: (typeof CABLES)[number]) => {
    // Le signal s'affaiblit avec la distance, et tombe à 60 % à la limite du câble.
    const base = 100 - 40 * Math.min(1, distance / cab.limite);
    // Seul un câble non blindé souffre des perturbations, et seulement au-delà de 25 %.
    const penalite = cab.sensible ? Math.max(0, perturbation - 25) * 0.9 : 0;
    return Math.max(0, Math.round(base - penalite));
  };

  return (
    <div className="space-y-3">
      <Ctrl
        label="Distance à couvrir"
        value={distance}
        min={10}
        max={800}
        step={10}
        onChange={setDistance}
        display={`${distance} m`}
      />
      <Ctrl
        label="Perturbations électromagnétiques du lieu"
        value={perturbation}
        min={0}
        max={100}
        step={5}
        onChange={setPerturbation}
        display={
          perturbation < 25
            ? "faibles"
            : perturbation < 60
              ? "moyennes"
              : "fortes (atelier, moteurs)"
        }
        color={perturbation > 60 ? PALETTE.red : PALETTE.blue}
      />

      <div className="space-y-1.5">
        {CABLES.map((cab) => {
          const s = signal(cab);
          const hors = distance > cab.limite;
          return (
            <div key={cab.value} className="space-y-0.5">
              <div className="flex items-baseline justify-between gap-2">
                <button
                  type="button"
                  onClick={() => setOuvert(cab.value)}
                  className={
                    ouvert === cab.value
                      ? "text-xs font-semibold text-primary underline"
                      : "text-xs font-medium text-muted-foreground hover:underline"
                  }
                >
                  {cab.label}
                </button>
                <span className="font-mono text-[11px] font-semibold">
                  {hors ? "hors limite" : `${s} % de signal`}
                </span>
              </div>
              <div className="h-2.5 overflow-hidden rounded-full bg-secondary">
                <div
                  className="h-full rounded-full transition-all"
                  style={{
                    width: `${hors ? 0 : s}%`,
                    background: s > 60 ? PALETTE.green : s > 25 ? PALETTE.orange : PALETTE.red,
                  }}
                />
              </div>
              <p className="text-[10px] text-muted-foreground">
                Limite {cab.limite >= 1000 ? `${cab.limite / 1000} km` : `${cab.limite} m`} ·{" "}
                {(distance * cab.prix).toLocaleString("fr-FR", { maximumFractionDigits: 0 })} × 1000
                F pour {distance} m
              </p>
            </div>
          );
        })}
      </div>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-xs font-semibold">{c.label} — la coupe</p>
        <ol className="mt-1 space-y-0.5">
          {c.coupe.map((x) => (
            <li key={x} className="text-[11px] text-muted-foreground">
              — {x}
            </li>
          ))}
        </ol>
      </div>

      {distance > 100 && distance <= 500 ? (
        <Verdict tone="warn">
          À {distance} m, la paire torsadée est hors jeu : sa limite est de{" "}
          <strong>cent mètres</strong>, et c&apos;est le chiffre à retenir pour l&apos;examen.
          Au-delà, il faut un répéteur, un commutateur intermédiaire, du coaxial, ou de la fibre.
        </Verdict>
      ) : distance > 500 ? (
        <Verdict tone="bad">
          À {distance} m, seule la fibre tient. Le cuivre a tout perdu : l&apos;affaiblissement du
          signal est une loi physique, pas un défaut de fabrication.
        </Verdict>
      ) : perturbation > 60 ? (
        <Verdict tone="warn">
          Avec de fortes perturbations, regarde l&apos;écart entre UTP et STP : seul le premier
          s&apos;effondre. Dans un atelier, près de moteurs ou de néons, c&apos;est le blindage qui
          sauve la liaison — et la fibre, elle, ne sent rien du tout, parce qu&apos;elle transporte
          de la lumière.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          À {distance} m avec peu de perturbations, les quatre câbles passent. C&apos;est donc le
          prix qui décide, et la paire torsadée gagne : c&apos;est pour cela qu&apos;on la trouve
          dans toutes les salles informatiques du pays.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 9 — Placer les équipements                                 */
/* ------------------------------------------------------------------ */

const CAISSE = [
  {
    value: "carte",
    label: "Carte réseau",
    role: "Elle donne à la machine son accès au réseau, et porte son adresse MAC.",
    place: "poste",
  },
  {
    value: "hub",
    label: "Concentrateur (hub)",
    role: "Il recopie tout ce qu'il reçoit vers TOUS ses ports. Simple, et dépassé.",
    place: "central",
  },
  {
    value: "switch",
    label: "Commutateur (switch)",
    role: "Il apprend quelle machine est sur quel port et n'envoie qu'au destinataire.",
    place: "central",
  },
  {
    value: "routeur",
    label: "Routeur",
    role: "Il relie deux réseaux différents et choisit le chemin. C'est lui qui fait sortir du réseau local.",
    place: "sortie",
  },
  {
    value: "modem",
    label: "Modem",
    role: "Il adapte le signal numérique à la ligne de l'opérateur, et inversement.",
    place: "sortie",
  },
  {
    value: "repeteur",
    label: "Répéteur",
    role: "Il réamplifie un signal affaibli pour aller plus loin que la limite du câble.",
    place: "liaison",
  },
] as const;

export function EquipementsReseau() {
  const [central, setCentral] = useState<string | null>(null);
  const [sortie, setSortie] = useState<string | null>(null);
  const [envoi, setEnvoi] = useState<"local" | "internet" | null>(null);

  const trames = central === "hub" ? 4 : central === "switch" ? 1 : 0;

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-sm font-medium">
          Quatre postes, un emplacement central vide, un emplacement de sortie vide
        </p>
      </div>

      <div className="grid gap-2 sm:grid-cols-2">
        <div className="space-y-1">
          <p className="text-xs font-medium text-muted-foreground">Emplacement central</p>
          <div className="flex flex-wrap gap-1.5">
            {CAISSE.filter((x) => x.place === "central").map((x) => (
              <button
                key={x.value}
                type="button"
                onClick={() => setCentral(central === x.value ? null : x.value)}
                className={
                  central === x.value
                    ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
                    : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
                }
              >
                {x.label}
              </button>
            ))}
          </div>
        </div>
        <div className="space-y-1">
          <p className="text-xs font-medium text-muted-foreground">Emplacement de sortie</p>
          <div className="flex flex-wrap gap-1.5">
            {CAISSE.filter((x) => x.place === "sortie").map((x) => (
              <button
                key={x.value}
                type="button"
                onClick={() => setSortie(sortie === x.value ? null : x.value)}
                className={
                  sortie === x.value
                    ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
                    : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
                }
              >
                {x.label}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Le schéma */}
      <svg
        viewBox="0 0 420 200"
        width="100%"
        className="rounded-lg border border-border bg-background"
      >
        {[0, 1, 2, 3].map((k) => {
          const x = 40 + k * 90;
          const actif =
            envoi !== null && (k === 0 || (envoi === "local" && k === 2) || trames === 4);
          return (
            <g key={k}>
              <rect
                x={x - 20}
                y={20}
                width={40}
                height={26}
                rx={3}
                fill={actif ? "#fef3c7" : "#dbeafe"}
                stroke={actif ? "#ca8a04" : "#2563eb"}
                strokeWidth={1.5}
              />
              <text x={x} y={37} textAnchor="middle" fontSize={9} fill="#1e3a8a">
                P{k + 1}
              </text>
              <line
                x1={x}
                y1={46}
                x2={200}
                y2={96}
                stroke={actif ? "#ca8a04" : "#94a3b8"}
                strokeWidth={actif ? 2.4 : 1.4}
              />
            </g>
          );
        })}
        <rect
          x={160}
          y={96}
          width={80}
          height={26}
          rx={4}
          fill={central ? "#dcfce7" : "#f1f5f9"}
          stroke={central ? "#15803d" : "#94a3b8"}
          strokeWidth={1.6}
          strokeDasharray={central ? undefined : "4 3"}
        />
        <text x={200} y={113} textAnchor="middle" fontSize={9} fill="#14532d">
          {central ? (central === "hub" ? "hub" : "switch") : "vide"}
        </text>
        <line x1={200} y1={122} x2={200} y2={150} stroke="#94a3b8" strokeWidth={1.4} />
        <rect
          x={160}
          y={150}
          width={80}
          height={26}
          rx={4}
          fill={sortie ? "#ede9fe" : "#f1f5f9"}
          stroke={sortie ? "#7c3aed" : "#94a3b8"}
          strokeWidth={1.6}
          strokeDasharray={sortie ? undefined : "4 3"}
        />
        <text x={200} y={167} textAnchor="middle" fontSize={9} fill="#4c1d95">
          {sortie ?? "vide"}
        </text>
        <line x1={240} y1={163} x2={330} y2={163} stroke="#94a3b8" strokeWidth={1.4} />
        <text x={370} y={167} textAnchor="middle" fontSize={9} fill="#64748b">
          Internet
        </text>
      </svg>

      <div className="flex flex-wrap gap-1.5">
        <button
          type="button"
          onClick={() => setEnvoi("local")}
          className="rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Envoyer du poste 1 au poste 3
        </button>
        <button
          type="button"
          onClick={() => setEnvoi("internet")}
          className="rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Envoyer du poste 1 vers Internet
        </button>
      </div>

      {envoi === null ? (
        <Verdict tone="warn">
          Place un équipement au centre, puis envoie un message. Essaie le hub, puis le commutateur,
          et compare le nombre de trames qui circulent.
        </Verdict>
      ) : central === null ? (
        <Verdict tone="bad">
          Rien au centre : les quatre postes ne peuvent pas se parler. Une carte réseau par machine
          ne suffit pas — il faut un équipement qui les relie.
        </Verdict>
      ) : envoi === "local" ? (
        central === "hub" ? (
          <Verdict tone="bad">
            Le hub a recopié la trame vers <strong>les quatre ports</strong> : {trames} trames pour
            un seul destinataire. Les postes 2 et 4 reçoivent un message qui ne leur est pas
            destiné, le jettent, et ont consommé de la bande passante pour rien. Pire,
            n&apos;importe qui sur le réseau peut lire le trafic des autres. C&apos;est pour cela
            que le hub a disparu.
          </Verdict>
        ) : (
          <Verdict tone="ok">
            Le commutateur a lu l&apos;adresse MAC du destinataire et envoyé la trame{" "}
            <strong>au seul poste 3</strong> : {trames} trame. Il a appris quelle machine est sur
            quel port, et c&apos;est exactement ce qui le distingue du hub.
          </Verdict>
        )
      ) : sortie === "routeur" ? (
        <Verdict tone="ok">
          Le routeur a reconnu une adresse hors du réseau local et l&apos;a dirigée vers
          l&apos;extérieur. <strong>Seul le routeur sait sortir du réseau local</strong> : ni le hub
          ni le commutateur n&apos;en sont capables, parce qu&apos;ils ne lisent que les adresses
          MAC, pas les adresses IP.
        </Verdict>
      ) : sortie === "modem" ? (
        <Verdict tone="warn">
          Le modem adapte bien le signal à la ligne de l&apos;opérateur, mais il ne décide
          d&apos;aucun chemin : sans routeur, la trame ne sait pas qu&apos;elle doit sortir. En
          pratique, la box de l&apos;opérateur contient les deux dans un même boîtier — c&apos;est
          pourquoi on les confond.
        </Verdict>
      ) : (
        <Verdict tone="bad">
          L&apos;emplacement de sortie est vide : impossible de quitter le réseau local. Place un{" "}
          <strong>routeur</strong>.
        </Verdict>
      )}

      <div className="space-y-1 rounded-lg border border-border bg-background p-3">
        {CAISSE.map((x) => (
          <p key={x.value} className="text-[11px] text-muted-foreground">
            <span className="font-semibold text-foreground">{x.label} — </span>
            {x.role}
          </p>
        ))}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 10 — Quel protocole pour quelle action                     */
/* ------------------------------------------------------------------ */

const ACTIONS = [
  {
    enonce: "Ouvrir une page web dans un navigateur.",
    bon: "HTTP",
    couche: "application",
    pourquoi:
      "HTTP, ou HTTPS quand la liaison est chiffrée. C'est le protocole du web, et seulement du web.",
  },
  {
    enonce: "Envoyer un courrier électronique.",
    bon: "SMTP",
    couche: "application",
    pourquoi:
      "SMTP sert à ENVOYER. On le reconnaît au S de Send dans Simple Mail Transfer Protocol.",
  },
  {
    enonce: "Relever ses courriels depuis son téléphone.",
    bon: "POP3",
    couche: "application",
    pourquoi:
      "POP3 ou IMAP servent à RELEVER. Le couple à retenir : SMTP pour envoyer, POP3 pour recevoir.",
  },
  {
    enonce: "Téléverser les fichiers d'un site vers un serveur.",
    bon: "FTP",
    couche: "application",
    pourquoi: "FTP, File Transfer Protocol : le transfert de fichiers.",
  },
  {
    enonce: "Brancher un portable neuf sur le réseau et le voir obtenir une adresse tout seul.",
    bon: "DHCP",
    couche: "application",
    pourquoi:
      "DHCP distribue automatiquement les adresses IP. Sans lui, il faudrait configurer chaque machine à la main.",
  },
  {
    enonce: "Taper un nom de site et atteindre la bonne machine.",
    bon: "DNS",
    couche: "application",
    pourquoi:
      "Le DNS traduit le nom en adresse IP. Quand il est muet, on atteint les sites par leur adresse mais pas par leur nom — c'est le symptôme caractéristique.",
  },
  {
    enonce: "Garantir que tous les morceaux du fichier arrivent, dans l'ordre et sans perte.",
    bon: "TCP",
    couche: "transport",
    pourquoi:
      "TCP découpe, numérote, vérifie et réordonne. C'est lui qui rend le transfert fiable, et c'est pour cela qu'il est plus lent qu'UDP.",
  },
] as const;

const PROTOS = ["HTTP", "SMTP", "POP3", "FTP", "DHCP", "DNS", "TCP", "IP"] as const;

const PILE = [
  {
    nom: "Application",
    exemple: "HTTP, SMTP, POP3, FTP, DNS, DHCP",
    quoi: "Elle parle le langage du service demandé.",
  },
  {
    nom: "Transport",
    exemple: "TCP, UDP",
    quoi: "Elle découpe en segments et assure (ou non) la fiabilité.",
  },
  {
    nom: "Internet",
    exemple: "IP",
    quoi: "Elle adresse et route les paquets de réseau en réseau.",
  },
  {
    nom: "Accès réseau",
    exemple: "Ethernet, Wi-Fi",
    quoi: "Elle met les bits sur le câble ou dans les ondes.",
  },
] as const;

export function ProtocolesInternet() {
  const [i, setI] = useState(0);
  const [rep, setRep] = useState<string | null>(null);
  const [etape, setEtape] = useState(0);

  const a = ACTIONS[i] ?? ACTIONS[0];
  const juste = rep === a.bon;

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-[11px] text-muted-foreground">
          Action {i + 1} sur {ACTIONS.length}
        </p>
        <p className="text-sm font-medium">{a.enonce}</p>
      </div>

      <Choice<string>
        label="Le protocole à l'œuvre"
        value={rep ?? ""}
        options={PROTOS.map((p) => ({ value: p, label: p }))}
        onChange={setRep}
      />

      {rep === null ? (
        <Verdict tone="warn">
          Demande-toi ce que l&apos;action fait vraiment : afficher une page, envoyer, relever,
          transférer un fichier, distribuer une adresse, traduire un nom ?
        </Verdict>
      ) : juste ? (
        <Verdict tone="ok">Exact. {a.pourquoi}</Verdict>
      ) : (
        <Verdict tone="bad">
          Non, c&apos;est {a.bon}. {a.pourquoi}
        </Verdict>
      )}

      <button
        type="button"
        onClick={() => {
          setI((v) => (v + 1) % ACTIONS.length);
          setRep(null);
          setEtape(0);
        }}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        Action suivante
      </button>

      <div className="space-y-2 border-t border-border pt-3">
        <div className="flex items-center justify-between gap-2">
          <p className="text-xs font-medium text-muted-foreground">
            La descente dans la pile TCP/IP
          </p>
          <button
            type="button"
            onClick={() => setEtape((v) => (v + 1) % (PILE.length + 1))}
            className="rounded-lg border border-border bg-background px-2.5 py-1 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
          >
            {etape === 0
              ? "Faire descendre le message"
              : etape >= PILE.length
                ? "Recommencer"
                : "Couche suivante"}
          </button>
        </div>
        <div className="space-y-1">
          {PILE.map((c, k) => {
            const passee = k < etape;
            const courante = k === etape - 1;
            return (
              <div
                key={c.nom}
                className={
                  courante
                    ? "rounded-lg border-2 border-amber-500 bg-amber-500/10 px-2.5 py-1.5"
                    : passee
                      ? "rounded-lg border border-emerald-500/40 bg-emerald-500/5 px-2.5 py-1.5"
                      : "rounded-lg border border-border bg-background px-2.5 py-1.5"
                }
              >
                <p className="text-xs font-semibold">
                  {c.nom}
                  {passee || courante ? (
                    <span className="ml-2 font-mono text-[10px] text-muted-foreground">
                      + en-tête ajouté
                    </span>
                  ) : null}
                </p>
                <p className="text-[10px] text-muted-foreground">
                  {c.exemple} — {c.quoi}
                </p>
              </div>
            );
          })}
        </div>
        {etape >= PILE.length ? (
          <Verdict tone="ok">
            Le message est sur le câble. Chaque couche a ajouté son en-tête en descendant :
            c&apos;est l&apos;<strong>encapsulation</strong>. À l&apos;arrivée, chaque couche retire
            le sien en remontant. Et {a.bon} travaille dans la couche <strong>{a.couche}</strong>.
          </Verdict>
        ) : null}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 10 — Composer une adresse IP                               */
/* ------------------------------------------------------------------ */

function masqueBits(cidr: number): number[] {
  const o = [0, 0, 0, 0];
  for (let i = 0; i < 4; i++) {
    const b = Math.max(0, Math.min(8, cidr - i * 8));
    o[i] = b === 0 ? 0 : 256 - 2 ** (8 - b);
  }
  return o;
}

export function AdresseIp() {
  const [o, setO] = useState([192, 168, 1, 10]);
  const [cidr, setCidr] = useState(24);
  const [o2, setO2] = useState([192, 168, 2, 20]);

  const m = masqueBits(cidr);
  const reseau = o.map((x, i) => x & (m[i] ?? 0));
  const diffusion = o.map((x, i) => (x & (m[i] ?? 0)) | (255 - (m[i] ?? 0)));
  const hotes = Math.max(0, 2 ** (32 - cidr) - 2);
  const reseau2 = o2.map((x, i) => x & (m[i] ?? 0));
  const memeReseau = reseau.join(".") === reseau2.join(".");

  const bitsReseau = cidr;

  const changer = (i: number, v: number, second = false) => {
    const t = second ? [...o2] : [...o];
    t[i] = Math.max(0, Math.min(255, v));
    if (second) setO2(t);
    else setO(t);
  };

  return (
    <div className="space-y-3">
      <div className="space-y-1.5">
        <p className="text-xs font-medium text-muted-foreground">
          Compose l&apos;adresse, octet par octet
        </p>
        <div className="flex items-center gap-1">
          {o.map((v, i) => {
            const bitsDansOctet = Math.max(0, Math.min(8, bitsReseau - i * 8));
            const partieReseau = bitsDansOctet === 8;
            const partieHote = bitsDansOctet === 0;
            return (
              <div key={i} className="flex items-center gap-1">
                <input
                  type="number"
                  min={0}
                  max={255}
                  value={v}
                  onChange={(e) => changer(i, Number(e.target.value))}
                  className={
                    partieReseau
                      ? "w-16 rounded-lg border-2 border-blue-500 bg-blue-500/10 px-1.5 py-1 text-center font-mono text-sm font-semibold"
                      : partieHote
                        ? "w-16 rounded-lg border-2 border-emerald-500 bg-emerald-500/10 px-1.5 py-1 text-center font-mono text-sm font-semibold"
                        : "w-16 rounded-lg border-2 border-amber-500 bg-amber-500/10 px-1.5 py-1 text-center font-mono text-sm font-semibold"
                  }
                />
                {i < 3 ? <span className="font-mono text-sm">.</span> : null}
              </div>
            );
          })}
        </div>
        <p className="text-[10px] text-muted-foreground">
          <span style={{ color: PALETTE.blue }}>■</span> partie réseau ·{" "}
          <span style={{ color: PALETTE.green }}>■</span> partie hôte ·{" "}
          <span style={{ color: PALETTE.orange }}>■</span> octet partagé entre les deux
        </p>
      </div>

      <Ctrl
        label="Masque de sous-réseau"
        value={cidr}
        min={8}
        max={30}
        step={1}
        onChange={setCidr}
        display={`/${cidr} — ${m.join(".")}`}
      />

      <Panel>
        <Stat label="Adresse du réseau" value={reseau.join(".")} color={PALETTE.blue} />
        <Stat label="Adresse de diffusion" value={diffusion.join(".")} color={PALETTE.purple} />
      </Panel>
      <Panel>
        <Stat
          label="Machines possibles"
          value={hotes.toLocaleString("fr-FR")}
          color={PALETTE.green}
        />
        <Stat label="Bits pour les hôtes" value={`${32 - cidr}`} />
      </Panel>
      <p className="text-[11px] text-muted-foreground">
        Le nombre de machines est <span className="font-mono">2^{32 - cidr} − 2</span> : on retire
        toujours deux adresses, celle du <strong>réseau</strong> et celle de{" "}
        <strong>diffusion</strong>, qui ne peuvent être attribuées à aucune machine.
      </p>

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">
          Une seconde machine : peuvent-elles se parler directement ?
        </p>
        <div className="flex items-center gap-1">
          {o2.map((v, i) => (
            <div key={i} className="flex items-center gap-1">
              <input
                type="number"
                min={0}
                max={255}
                value={v}
                onChange={(e) => changer(i, Number(e.target.value), true)}
                className="w-16 rounded-lg border border-border bg-background px-1.5 py-1 text-center font-mono text-sm"
              />
              {i < 3 ? <span className="font-mono text-sm">.</span> : null}
            </div>
          ))}
        </div>

        <Panel>
          <Stat label="Réseau de la machine 1" value={reseau.join(".")} />
          <Stat label="Réseau de la machine 2" value={reseau2.join(".")} />
        </Panel>

        {memeReseau ? (
          <Verdict tone="ok">
            Oui. Les deux parties réseau sont identiques —{" "}
            <span className="font-mono">{reseau.join(".")}</span> dans les deux cas — donc les
            machines sont sur le même réseau et se parlent <strong>directement</strong>, sans
            routeur.
          </Verdict>
        ) : (
          <Verdict tone="bad">
            Non. <span className="font-mono">{reseau.join(".")}</span> et{" "}
            <span className="font-mono">{reseau2.join(".")}</span> sont deux réseaux différents : il
            leur faut un <strong>routeur</strong> pour communiquer. C&apos;est la justification
            attendue en examen — on compare les parties réseau, pas les adresses.
          </Verdict>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 10 — Les classes d'adresses                                */
/* ------------------------------------------------------------------ */

const ADRESSES = [
  { ip: "10.0.0.5", classe: "A" },
  { ip: "172.16.4.1", classe: "B" },
  { ip: "192.168.1.100", classe: "C" },
  { ip: "127.0.0.1", classe: "A" },
  { ip: "224.0.0.9", classe: "D" },
  { ip: "200.45.12.8", classe: "C" },
  { ip: "130.65.2.3", classe: "B" },
  { ip: "245.1.1.1", classe: "E" },
  { ip: "66.249.64.1", classe: "A" },
] as const;

const CLASSES = [
  { c: "A", min: 1, max: 126, masque: "255.0.0.0", cidr: 8, mot: "de très grands réseaux" },
  { c: "B", min: 128, max: 191, masque: "255.255.0.0", cidr: 16, mot: "des réseaux moyens" },
  { c: "C", min: 192, max: 223, masque: "255.255.255.0", cidr: 24, mot: "de petits réseaux" },
  {
    c: "D",
    min: 224,
    max: 239,
    masque: "—",
    cidr: 0,
    mot: "la diffusion multicast, pas des machines",
  },
  { c: "E", min: 240, max: 255, masque: "—", cidr: 0, mot: "la recherche, réservée" },
] as const;

export function ClassesAdresses() {
  const [i, setI] = useState(0);
  const [rep, setRep] = useState<string | null>(null);

  const a = ADRESSES[i] ?? ADRESSES[0];
  const premier = Number(a.ip.split(".")[0] ?? "0");
  const juste = rep === a.classe;
  const cl = CLASSES.find((x) => x.c === a.classe) ?? CLASSES[0];
  const boucle = premier === 127;

  const octets = a.ip.split(".");
  const hotes = cl.cidr > 0 ? 2 ** (32 - cl.cidr) - 2 : 0;
  const reseau =
    cl.cidr === 8
      ? `${octets[0]}.0.0.0`
      : cl.cidr === 16
        ? `${octets[0]}.${octets[1]}.0.0`
        : cl.cidr === 24
          ? `${octets[0]}.${octets[1]}.${octets[2]}.0`
          : "—";
  const diffusion =
    cl.cidr === 8
      ? `${octets[0]}.255.255.255`
      : cl.cidr === 16
        ? `${octets[0]}.${octets[1]}.255.255`
        : cl.cidr === 24
          ? `${octets[0]}.${octets[1]}.${octets[2]}.255`
          : "—";

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-3 text-center">
        <p className="font-mono text-lg font-bold">
          <span className="rounded bg-amber-400/40 px-1">{octets[0]}</span>.{octets[1]}.{octets[2]}.
          {octets[3]}
        </p>
        <p className="mt-1 text-[11px] text-muted-foreground">
          Seul le premier octet décide de la classe. Les trois autres ne servent à rien ici.
        </p>
      </div>

      {/* La règle graduée de 0 à 255 */}
      <div className="space-y-1">
        <div className="relative h-7 overflow-hidden rounded-lg border border-border">
          {CLASSES.map((c) => (
            <div
              key={c.c}
              className="absolute top-0 flex h-full items-center justify-center text-[10px] font-semibold text-white"
              style={{
                left: `${(c.min / 256) * 100}%`,
                width: `${((c.max - c.min + 1) / 256) * 100}%`,
                background:
                  c.c === "A"
                    ? PALETTE.blue
                    : c.c === "B"
                      ? PALETTE.green
                      : c.c === "C"
                        ? PALETTE.orange
                        : c.c === "D"
                          ? PALETTE.purple
                          : PALETTE.slate,
              }}
            >
              {c.c}
            </div>
          ))}
          <div
            className="absolute top-0 h-full w-0.5 bg-black"
            style={{ left: `${(premier / 256) * 100}%` }}
          />
        </div>
        <div className="flex justify-between text-[9px] text-muted-foreground">
          <span>0</span>
          <span>126</span>
          <span>191</span>
          <span>223</span>
          <span>239</span>
          <span>255</span>
        </div>
      </div>

      <Choice<string>
        label="Classe de cette adresse"
        value={rep ?? ""}
        options={CLASSES.map((c) => ({ value: c.c, label: `Classe ${c.c}` }))}
        onChange={setRep}
      />

      {rep === null ? (
        <Verdict tone="warn">
          Le trait noir sur la règle montre où tombe le premier octet. Les bornes à retenir : A de 1
          à 126, B de 128 à 191, C de 192 à 223, D de 224 à 239, E au-delà.
        </Verdict>
      ) : juste ? (
        <Verdict tone="ok">
          Classe {a.classe} : le premier octet vaut {premier}, donc entre {cl.min} et {cl.max}.
          Cette classe sert à {cl.mot}.
        </Verdict>
      ) : (
        <Verdict tone="bad">
          Non, classe {a.classe} : {premier} tombe entre {cl.min} et {cl.max}.
        </Verdict>
      )}

      {rep !== null && cl.cidr > 0 ? (
        <>
          <Panel>
            <Stat label="Masque par défaut" value={cl.masque} color={PALETTE.blue} />
            <Stat
              label="Machines possibles"
              value={hotes.toLocaleString("fr-FR")}
              color={PALETTE.green}
            />
          </Panel>
          <Panel>
            <Stat label="Adresse du réseau" value={reseau} />
            <Stat label="Adresse de diffusion" value={diffusion} color={PALETTE.purple} />
          </Panel>
        </>
      ) : null}

      {boucle && rep !== null ? (
        <Verdict tone="warn">
          Attention à celle-là : <span className="font-mono">127.0.0.1</span> est bien de classe A
          par son premier octet, mais tout le réseau 127 est <strong>réservé au bouclage</strong>.
          Elle ne désigne jamais qu&apos;une machine : <strong>elle-même</strong>. C&apos;est la
          première adresse qu&apos;on teste au <span className="font-mono">ping</span>, parce
          qu&apos;elle vérifie la pile TCP/IP locale sans rien demander au réseau.
        </Verdict>
      ) : null}

      <button
        type="button"
        onClick={() => {
          setI((v) => (v + 1) % ADRESSES.length);
          setRep(null);
        }}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        Adresse suivante
      </button>
    </div>
  );
}
