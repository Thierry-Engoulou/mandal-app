import { useState } from "react";
import { Choice, Ctrl, PALETTE, Panel, Stat, Verdict } from "./controls";

/** Informatique Terminale C et D — chapitres 7 et 8 : familles, topologies, architectures. */

/* ------------------------------------------------------------------ */
/* Chapitre 7 — Ce que le réseau fait économiser                       */
/* ------------------------------------------------------------------ */

export function PourquoiReseau() {
  const [relies, setRelies] = useState(0);

  const total = 8;
  const isoles = total - relies;

  // Sans réseau : une imprimante et un abonnement par poste.
  const imprimantes = relies === 0 ? total : isoles + 1;
  const abonnements = relies === 0 ? total : isoles + 1;
  // Transport de fichiers à la clé USB : 4 minutes par échange, 20 échanges par jour.
  const minutesCle = isoles * 20;
  // Une clé qui circule entre machines non protégées contamine tout ce qu'elle touche.
  const infectees = isoles > 1 ? isoles : 0;

  const coutMateriel = imprimantes * 120 + abonnements * 25;
  const coutReseau = relies > 1 ? 85 + relies * 8 : 0;
  const economie = total * 120 + total * 25 - (coutMateriel + coutReseau);

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-sm font-medium">Huit postes, huit imprimantes, huit abonnements</p>
        <p className="mt-1 text-[11px] text-muted-foreground">
          Et une clé USB qui fait le tour de la salle vingt fois par jour pour porter les fichiers
          d&apos;un poste à l&apos;autre.
        </p>
      </div>

      <Ctrl
        label="Postes reliés au commutateur"
        value={relies}
        min={0}
        max={8}
        step={1}
        onChange={setRelies}
        display={`${relies} sur 8`}
        color={relies === 8 ? PALETTE.green : PALETTE.blue}
      />

      <div className="flex flex-wrap gap-1.5">
        {Array.from({ length: total }, (_, k) => (
          <div
            key={k}
            className={
              k < relies
                ? "flex h-9 w-9 items-center justify-center rounded border-2 border-emerald-500 bg-emerald-500/20 text-[10px] font-semibold text-emerald-700"
                : "flex h-9 w-9 items-center justify-center rounded border border-slate-400 bg-secondary text-[10px] text-muted-foreground"
            }
          >
            P{k + 1}
          </div>
        ))}
      </div>
      <p className="text-[10px] text-muted-foreground">
        Vert : relié au réseau. Gris : isolé, avec sa propre imprimante et son propre abonnement.
      </p>

      <Panel>
        <Stat label="Imprimantes nécessaires" value={`${imprimantes}`} color={PALETTE.blue} />
        <Stat label="Abonnements internet" value={`${abonnements}`} color={PALETTE.blue} />
      </Panel>
      <Panel>
        <Stat
          label="Temps perdu à transporter"
          value={`${minutesCle} min / jour`}
          color={minutesCle === 0 ? PALETTE.green : PALETTE.orange}
        />
        <Stat
          label="Machines infectées par la clé"
          value={`${infectees}`}
          color={infectees === 0 ? PALETTE.green : PALETTE.red}
        />
      </Panel>
      <Panel>
        <Stat label="Coût du matériel" value={`${coutMateriel} × 1000 F`} />
        <Stat
          label="Économisé sur l'année"
          value={`${economie} × 1000 F`}
          color={economie > 0 ? PALETTE.green : PALETTE.ink}
        />
      </Panel>

      {relies === 0 ? (
        <Verdictelement
          tone="bad"
          texte="Huit imprimantes, huit abonnements, et six heures et demie par semaine passées à porter une clé USB d'un poste à l'autre. C'est exactement la situation que le réseau vient résoudre."
        />
      ) : relies === total ? (
        <Verdictelement
          tone="ok"
          texte={`Les huit postes partagent une imprimante et un abonnement. Plus de clé USB qui circule, donc plus de contamination par là. Et ${economie} milliers de francs économisés sur l'année, pour un commutateur et huit câbles. Les quatre raisons d'un réseau : partager le matériel, partager les données, partager la connexion, et administrer depuis un seul point.`}
        />
      ) : (
        <Verdictelement
          tone="warn"
          texte={`${relies} postes reliés, ${isoles} encore isolés. Les isolés gardent leur imprimante, leur abonnement, et leur clé USB — c'est-à-dire tout le problème. Un réseau à moitié fait économise peu.`}
        />
      )}
    </div>
  );
}

function Verdictelement({ tone, texte }: { tone: "ok" | "warn" | "bad"; texte: string }) {
  return <Verdict tone={tone}>{texte}</Verdict>;
}

/* ------------------------------------------------------------------ */
/* Chapitre 7 — PAN, LAN, MAN, WAN                                     */
/* ------------------------------------------------------------------ */

const SITUATIONS_ETENDUE = [
  {
    enonce: "Un casque Bluetooth relié au téléphone de son propriétaire.",
    bonne: "pan",
    portee: "quelques mètres",
    pourquoi:
      "Quelques mètres autour d'une personne : c'est un PAN, et comme c'est du sans-fil, un WPAN.",
  },
  {
    enonce: "Les huit postes d'une salle de travaux pratiques, reliés par câbles.",
    bonne: "lan",
    portee: "une salle, un bâtiment",
    pourquoi: "Un seul local : c'est un LAN. Filaire, donc LAN tout court, sans W.",
  },
  {
    enonce: "Les douze agences d'une banque réparties dans Douala.",
    bonne: "man",
    portee: "une ville",
    pourquoi: "À l'échelle d'une ville : MAN, réseau métropolitain.",
  },
  {
    enonce: "Les sites d'une entreprise entre Yaoundé et Garoua.",
    bonne: "wan",
    portee: "un pays, un continent",
    pourquoi: "Plusieurs centaines de kilomètres : WAN, réseau étendu.",
  },
  {
    enonce: "Le réseau de téléphonie mobile d'un opérateur camerounais.",
    bonne: "wan",
    portee: "tout le pays",
    pourquoi: "Il couvre le pays entier : c'est un WAN, et comme il est sans fil, un WWAN.",
  },
  {
    enonce: "Les portables des élèves connectés à la borne Wi-Fi du CDI.",
    bonne: "lan",
    portee: "un bâtiment",
    pourquoi:
      "Un bâtiment en sans-fil : WLAN. La portée décide de la lettre, le support décide du W.",
  },
  {
    enonce: "Une souris sans fil et son ordinateur.",
    bonne: "pan",
    portee: "un mètre",
    pourquoi: "Le plus petit réseau qui existe : un WPAN d'un seul mètre.",
  },
  {
    enonce: "Les campus universitaires de Yaoundé I reliés entre eux dans la ville.",
    bonne: "man",
    portee: "une agglomération",
    pourquoi: "Plusieurs sites d'une même agglomération : MAN.",
  },
  {
    enonce: "Internet.",
    bonne: "wan",
    portee: "la planète",
    pourquoi: "Le plus grand WAN du monde : un réseau de réseaux à l'échelle planétaire.",
  },
  {
    enonce: "Les quinze postes et deux serveurs d'un cybercafé.",
    bonne: "lan",
    portee: "un local",
    pourquoi: "Un local, un commutateur : LAN. Et sa sortie vers Internet passe par un routeur.",
  },
] as const;

const ECHELLES = [
  { value: "pan", label: "PAN", min: 0, max: 10, mot: "quelques mètres" },
  { value: "lan", label: "LAN", min: 10, max: 1000, mot: "un bâtiment" },
  { value: "man", label: "MAN", min: 1000, max: 50000, mot: "une ville" },
  { value: "wan", label: "WAN", min: 50000, max: 20000000, mot: "un pays, le monde" },
] as const;

export function EtendueReseaux() {
  const [i, setI] = useState(0);
  const [rep, setRep] = useState<string | null>(null);
  const [sansFil, setSansFil] = useState(false);

  const s = SITUATIONS_ETENDUE[i] ?? SITUATIONS_ETENDUE[0];
  const juste = rep === s.bonne;
  const e = ECHELLES.find((x) => x.value === (rep ?? s.bonne)) ?? ECHELLES[0];

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-[11px] text-muted-foreground">
          Situation {i + 1} sur {SITUATIONS_ETENDUE.length}
        </p>
        <p className="text-sm font-medium">{s.enonce}</p>
      </div>

      <Choice<string>
        label="Type de réseau"
        value={rep ?? ""}
        options={ECHELLES.map((x) => ({ value: x.value, label: x.label }))}
        onChange={setRep}
      />
      <Choice<"fil" | "sans">
        label="Support"
        value={sansFil ? "sans" : "fil"}
        options={[
          { value: "fil", label: "Filaire" },
          { value: "sans", label: "Sans fil" },
        ]}
        onChange={(v) => setSansFil(v === "sans")}
      />

      {/* La règle graduée des quatre échelles */}
      <div className="space-y-1">
        <div className="flex h-7 overflow-hidden rounded-lg border border-border">
          {ECHELLES.map((x) => (
            <div
              key={x.value}
              className={
                x.value === (rep ?? "")
                  ? "flex flex-1 items-center justify-center bg-primary text-[10px] font-semibold text-primary-foreground"
                  : "flex flex-1 items-center justify-center bg-secondary/40 text-[10px] text-muted-foreground"
              }
              style={{ flexGrow: x.value === "wan" ? 2 : 1 }}
            >
              {x.label}
            </div>
          ))}
        </div>
        <div className="flex justify-between text-[9px] text-muted-foreground">
          <span>1 m</span>
          <span>100 m</span>
          <span>10 km</span>
          <span>1000 km</span>
          <span>la planète</span>
        </div>
      </div>

      <Panel>
        <Stat label="Portée réelle de ce cas" value={s.portee} />
        <Stat
          label="Sigle complet"
          value={rep ? `${sansFil ? "W" : ""}${e.label}` : "—"}
          color={PALETTE.blue}
        />
      </Panel>

      {rep === null ? (
        <Verdict tone="warn">
          Deux questions, dans cet ordre : <strong>quelle portée</strong> — un mètre, un bâtiment,
          une ville, un pays ? — puis <strong>quel support</strong>. La portée donne les trois
          lettres, le sans-fil ajoute le W devant.
        </Verdict>
      ) : juste ? (
        <Verdict tone="ok">
          Exact : {sansFil ? "W" : ""}
          {e.label}. {s.pourquoi}
        </Verdict>
      ) : (
        <Verdict tone="bad">
          Non, c&apos;est un {s.bonne.toUpperCase()}. {s.pourquoi}
        </Verdict>
      )}

      <button
        type="button"
        onClick={() => {
          setI((v) => (v + 1) % SITUATIONS_ETENDUE.length);
          setRep(null);
        }}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        Situation suivante
      </button>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 7 — Internet, intranet, extranet                           */
/* ------------------------------------------------------------------ */

const RESSOURCES = [
  {
    id: "vitrine",
    label: "Le site vitrine de l'entreprise",
    bonne: "internet",
    pourquoi: "Il est fait pour être vu de tous : il est sur internet, en accès public.",
  },
  {
    id: "annuaire",
    label: "L'annuaire téléphonique interne du personnel",
    bonne: "intranet",
    pourquoi:
      "Réservé aux employés, sur le réseau de l'entreprise : intranet. Un fournisseur n'a rien à y faire.",
  },
  {
    id: "catalogue",
    label: "Le catalogue des stocks consultable par les fournisseurs",
    bonne: "extranet",
    pourquoi:
      "Des partenaires extérieurs, mais identifiés : c'est exactement la définition de l'extranet.",
  },
  {
    id: "paie",
    label: "Les bulletins de paie",
    bonne: "intranet",
    pourquoi:
      "Les données les plus sensibles de l'entreprise : intranet, et même avec des droits restreints à l'intérieur.",
  },
  {
    id: "commandes",
    label: "Le portail où les clients grossistes passent leurs commandes",
    bonne: "extranet",
    pourquoi:
      "Des clients identifiés qui accèdent à une partie du système : extranet. S'il était ouvert à tous, ce serait de l'internet.",
  },
  {
    id: "notes",
    label: "La note de service sur les congés",
    bonne: "intranet",
    pourquoi: "Communication interne : intranet.",
  },
  {
    id: "offres",
    label: "Les offres d'emploi publiées par l'entreprise",
    bonne: "internet",
    pourquoi: "Elles n'ont de sens que si tout le monde peut les lire : internet.",
  },
] as const;

const ZONES = [
  { value: "internet", label: "Internet" },
  { value: "intranet", label: "Intranet" },
  { value: "extranet", label: "Extranet" },
] as const;

const VISITEURS: ReadonlyArray<{
  id: string;
  label: string;
  voit: ReadonlyArray<string>;
  mot: string;
}> = [
  {
    id: "public",
    label: "Un passant quelconque",
    voit: ["internet"],
    mot: "Il ne voit que ce qui est public. Tout le reste lui demande une authentification qu'il n'a pas.",
  },
  {
    id: "employe",
    label: "Un employé au siège",
    voit: ["internet", "intranet", "extranet"],
    mot: "Il voit tout : le public, l'interne, et la partie ouverte aux partenaires.",
  },
  {
    id: "agence",
    label: "Un employé d'une agence, par VPN",
    voit: ["internet", "intranet", "extranet"],
    mot: "Le tunnel chiffré le place à l'intérieur du réseau : il accède à l'intranet comme s'il était au siège. C'est tout l'intérêt du VPN.",
  },
  {
    id: "fourn",
    label: "Un fournisseur avec son compte",
    voit: ["internet", "extranet"],
    mot: "Il entre dans l'extranet, pas dans l'intranet. La frontière est là, et c'est elle qu'on demande en examen.",
  },
];

export function InternetIntranetExtranet() {
  const [place, setPlace] = useState<Record<string, string>>({});
  const [visiteur, setVisiteur] = useState<string | null>(null);

  const bons = RESSOURCES.filter((r) => place[r.id] === r.bonne).length;
  const v = VISITEURS.find((x) => x.id === visiteur);

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-sm font-medium">
          Une entreprise camerounaise : un siège, deux agences, des employés, des fournisseurs, et
          le grand public
        </p>
        <p className="mt-1 text-[11px] text-muted-foreground">
          Place chaque ressource dans la bonne zone.
        </p>
      </div>

      <div className="space-y-2">
        {RESSOURCES.map((r) => {
          const p = place[r.id];
          const juste = p === r.bonne;
          return (
            <div key={r.id} className="space-y-1">
              <p className="text-xs font-medium">{r.label}</p>
              <div className="flex flex-wrap gap-1.5">
                {ZONES.map((z) => {
                  const actif = p === z.value;
                  const cls = !actif
                    ? "border-border bg-background text-muted-foreground hover:bg-secondary/60"
                    : juste
                      ? "border-emerald-500/50 bg-emerald-500/10 text-emerald-700"
                      : "border-rose-500/50 bg-rose-500/10 text-rose-700";
                  return (
                    <button
                      key={z.value}
                      type="button"
                      onClick={() => setPlace({ ...place, [r.id]: z.value })}
                      className={`rounded-lg border px-2.5 py-1 text-xs font-medium ${cls}`}
                    >
                      {z.label}
                    </button>
                  );
                })}
              </div>
              {p !== undefined && !juste ? (
                <p className="text-[11px] text-rose-600">
                  Non : {ZONES.find((z) => z.value === r.bonne)?.label ?? ""}. {r.pourquoi}
                </p>
              ) : null}
            </div>
          );
        })}
      </div>

      <Panel>
        <Stat label="Bien placées" value={`${bons} / ${RESSOURCES.length}`} />
        <Stat
          label="La règle"
          value="qui a le droit d'entrer"
          color={bons === RESSOURCES.length ? PALETTE.green : PALETTE.ink}
        />
      </Panel>

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">
          Fais frapper à la porte chaque catégorie de visiteur
        </p>
        <div className="flex flex-wrap gap-1.5">
          {VISITEURS.map((x) => (
            <button
              key={x.id}
              type="button"
              onClick={() => setVisiteur(x.id)}
              className={
                visiteur === x.id
                  ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
                  : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
              }
            >
              {x.label}
            </button>
          ))}
        </div>

        {v ? (
          <>
            <div className="grid gap-1.5 sm:grid-cols-3">
              {ZONES.map((z) => {
                const ouvert = v.voit.includes(z.value);
                return (
                  <div
                    key={z.value}
                    className={
                      ouvert
                        ? "rounded-lg border-2 border-emerald-500 bg-emerald-500/10 p-2 text-center"
                        : "rounded-lg border border-slate-400 bg-secondary/40 p-2 text-center"
                    }
                  >
                    <p className="text-xs font-semibold">{z.label}</p>
                    <p
                      className="text-[10px]"
                      style={{ color: ouvert ? PALETTE.green : PALETTE.red }}
                    >
                      {ouvert ? "accessible" : "refusé"}
                    </p>
                    <div className="mt-1 space-y-0.5">
                      {RESSOURCES.filter((r) => r.bonne === z.value).map((r) => (
                        <p
                          key={r.id}
                          className={
                            ouvert
                              ? "text-[9px] text-foreground"
                              : "text-[9px] text-muted-foreground line-through"
                          }
                        >
                          {r.label}
                        </p>
                      ))}
                    </div>
                  </div>
                );
              })}
            </div>
            <Verdict tone="ok">{v.mot}</Verdict>
          </>
        ) : (
          <Verdict tone="warn">
            Choisis un visiteur : tu verras les trois zones s&apos;ouvrir ou se fermer devant lui.
            C&apos;est la seule chose qui distingue internet, intranet et extranet — non pas la
            technologie, qui est la même, mais <strong>qui a le droit d&apos;entrer</strong>.
          </Verdict>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 8 — Les trois topologies physiques                         */
/* ------------------------------------------------------------------ */

type Topo = "bus" | "etoile" | "anneau";

export function TopologiesPhysiques() {
  const [topo, setTopo] = useState<Topo>("bus");
  const [postes, setPostes] = useState(5);
  const [coupe, setCoupe] = useState<number | null>(null);

  const cable = topo === "bus" ? 10 + postes * 3 : topo === "etoile" ? postes * 12 : postes * 11;
  const materiel = topo === "etoile" ? 85 + postes * 8 : postes * 8;

  // En bus, tout le monde partage le même support : la bande passante par poste s'effondre.
  const debit =
    topo === "bus"
      ? Math.round(100 / postes)
      : topo === "anneau"
        ? Math.round(100 / Math.max(1, postes / 2))
        : 100;

  const tombes = coupe === null ? 0 : topo === "bus" ? postes : topo === "anneau" ? postes : 1;

  const MOTS: Record<Topo, string> = {
    bus: "Un seul câble, et tout le monde y est accroché. Le câble coupé, le réseau entier tombe — et la panne est difficile à localiser, puisque tous les postes se taisent en même temps. C'est le défaut qui l'a fait disparaître des installations neuves.",
    etoile:
      "Chaque poste a son propre câble vers le commutateur. Un câble coupé ne fait tomber qu'un poste, et la panne se localise immédiatement. En revanche, si le commutateur tombe, tout tombe : le point central est le point faible.",
    anneau:
      "Chaque poste est relié à ses deux voisins et le signal circule en boucle. Une coupure brise l'anneau et tout le trafic s'arrête — sauf si l'on double l'anneau, ce qui coûte le double de câble.",
  };

  return (
    <div className="space-y-3">
      <Choice<Topo>
        label="Topologie à construire"
        value={topo}
        options={[
          { value: "bus", label: "Bus" },
          { value: "etoile", label: "Étoile" },
          { value: "anneau", label: "Anneau" },
        ]}
        onChange={(v) => {
          setTopo(v);
          setCoupe(null);
        }}
      />
      <Ctrl
        label="Nombre de postes"
        value={postes}
        min={3}
        max={10}
        step={1}
        onChange={(v) => {
          setPostes(v);
          setCoupe(null);
        }}
        display={`${postes}`}
      />

      <SchemaTopo topo={topo} postes={postes} coupe={coupe} tombes={tombes} />

      <div className="flex flex-wrap gap-1.5">
        {Array.from({ length: topo === "etoile" ? postes : postes - 1 }, (_, k) => (
          <button
            key={k}
            type="button"
            onClick={() => setCoupe(coupe === k ? null : k)}
            className={
              coupe === k
                ? "rounded-lg bg-rose-600 px-2.5 py-1.5 text-xs font-semibold text-white"
                : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            }
          >
            Couper le câble {k + 1}
          </button>
        ))}
      </div>

      <Panel>
        <Stat label="Câble utilisé" value={`${cable} m`} color={PALETTE.blue} />
        <Stat label="Coût du matériel" value={`${materiel} × 1000 F`} />
      </Panel>
      <Panel>
        <Stat
          label="Débit par poste"
          value={`${debit} Mbit/s`}
          color={debit < 25 ? PALETTE.red : debit < 60 ? PALETTE.orange : PALETTE.green}
        />
        <Stat
          label="Postes hors service"
          value={`${tombes} / ${postes}`}
          color={tombes === 0 ? PALETTE.green : tombes === 1 ? PALETTE.orange : PALETTE.red}
        />
      </Panel>

      {coupe !== null ? (
        <Verdict tone={tombes === 1 ? "warn" : "bad"}>{MOTS[topo]}</Verdict>
      ) : topo === "bus" && postes >= 8 ? (
        <Verdict tone="warn">
          {postes} postes sur un seul câble : {debit} Mbit/s par poste seulement. Le support est
          partagé, et plus on ajoute de machines, plus chacune attend son tour. Coupe un câble pour
          voir l&apos;autre défaut du bus.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          Construis la topologie, puis coupe un câble. C&apos;est la réaction à la coupure qui
          distingue les trois, et c&apos;est ce que l&apos;examen demande de comparer.
        </Verdict>
      )}
    </div>
  );
}

function SchemaTopo({
  topo,
  postes,
  coupe,
  tombes,
}: {
  topo: Topo;
  postes: number;
  coupe: number | null;
  tombes: number;
}) {
  const W = 420;
  const H = topo === "etoile" || topo === "anneau" ? 220 : 130;
  const mort = (k: number) =>
    coupe !== null && (topo === "etoile" ? k === coupe : tombes === postes);

  if (topo === "bus") {
    const pas = (W - 60) / Math.max(1, postes - 1);
    return (
      <svg
        viewBox={`0 0 ${W} ${H}`}
        width="100%"
        className="rounded-lg border border-border bg-background"
      >
        <line x1={20} y1={80} x2={W - 20} y2={80} stroke="#334155" strokeWidth={3} />
        <text x={24} y={100} fontSize={9} fill="#64748b">
          bouchon
        </text>
        <text x={W - 52} y={100} fontSize={9} fill="#64748b">
          bouchon
        </text>
        {Array.from({ length: postes - 1 }, (_, k) => {
          const x1 = 30 + k * pas;
          const x2 = 30 + (k + 1) * pas;
          const casse = coupe === k;
          return (
            <line
              key={k}
              x1={x1}
              y1={80}
              x2={x2}
              y2={80}
              stroke={casse ? "#e11d48" : "#2563eb"}
              strokeWidth={casse ? 4 : 3}
              strokeDasharray={casse ? "5 5" : undefined}
            />
          );
        })}
        {Array.from({ length: postes }, (_, k) => {
          const x = 30 + k * pas;
          return (
            <g key={k}>
              <line x1={x} y1={56} x2={x} y2={80} stroke="#94a3b8" strokeWidth={1.5} />
              <rect
                x={x - 14}
                y={32}
                width={28}
                height={24}
                rx={3}
                fill={mort(k) ? "#fee2e2" : "#dbeafe"}
                stroke={mort(k) ? "#e11d48" : "#2563eb"}
                strokeWidth={1.5}
              />
              <text x={x} y={48} textAnchor="middle" fontSize={9} fill="#1e3a8a">
                P{k + 1}
              </text>
            </g>
          );
        })}
      </svg>
    );
  }

  const cx = W / 2;
  const cy = 110;
  const r = 78;
  const pts = Array.from({ length: postes }, (_, k) => {
    const a = (k / postes) * 2 * Math.PI - Math.PI / 2;
    return { x: cx + r * Math.cos(a), y: cy + r * Math.sin(a) };
  });

  return (
    <svg
      viewBox={`0 0 ${W} ${H}`}
      width="100%"
      className="rounded-lg border border-border bg-background"
    >
      {topo === "etoile" ? (
        <>
          <rect
            x={cx - 26}
            y={cy - 12}
            width={52}
            height={24}
            rx={4}
            fill="#dcfce7"
            stroke="#15803d"
            strokeWidth={1.6}
          />
          <text x={cx} y={cy + 4} textAnchor="middle" fontSize={9} fill="#14532d">
            switch
          </text>
          {pts.map((p, k) => {
            const casse = coupe === k;
            return (
              <line
                key={k}
                x1={cx}
                y1={cy}
                x2={p.x}
                y2={p.y}
                stroke={casse ? "#e11d48" : "#2563eb"}
                strokeWidth={casse ? 3.5 : 2}
                strokeDasharray={casse ? "5 5" : undefined}
              />
            );
          })}
        </>
      ) : (
        pts.map((p, k) => {
          const q = pts[(k + 1) % postes];
          if (!q) return null;
          const casse = coupe === k;
          return (
            <line
              key={k}
              x1={p.x}
              y1={p.y}
              x2={q.x}
              y2={q.y}
              stroke={casse ? "#e11d48" : "#ca8a04"}
              strokeWidth={casse ? 3.5 : 2.4}
              strokeDasharray={casse ? "5 5" : undefined}
            />
          );
        })
      )}
      {pts.map((p, k) => (
        <g key={k}>
          <rect
            x={p.x - 14}
            y={p.y - 12}
            width={28}
            height={24}
            rx={3}
            fill={mort(k) ? "#fee2e2" : "#dbeafe"}
            stroke={mort(k) ? "#e11d48" : "#2563eb"}
            strokeWidth={1.5}
          />
          <text x={p.x} y={p.y + 4} textAnchor="middle" fontSize={9} fill="#1e3a8a">
            P{k + 1}
          </text>
        </g>
      ))}
    </svg>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 8 — Ethernet contre le jeton                               */
/* ------------------------------------------------------------------ */

export function TopologiesLogiques() {
  const [methode, setMethode] = useState<"ethernet" | "jeton">("ethernet");
  const [charge, setCharge] = useState(20);
  const [jeton, setJeton] = useState(0);
  const [collision, setCollision] = useState(false);
  const [emetteurs, setEmetteurs] = useState<number[]>([]);

  // Ethernet : il livre presque tout à faible charge, et s'écroule sous les collisions.
  const utileEthernet = Math.round(charge * (1 - 0.75 * (charge / 100) ** 2));
  // Le jeton : il perd un peu de temps à chaque rotation, mais il ne s'écroule jamais.
  const utileJeton = Math.round(charge * 0.78);
  const utile = methode === "ethernet" ? utileEthernet : utileJeton;

  const emettre = (k: number) => {
    if (methode === "jeton") return;
    const nouveaux = emetteurs.includes(k) ? emetteurs.filter((x) => x !== k) : [...emetteurs, k];
    setEmetteurs(nouveaux);
    setCollision(nouveaux.length >= 2);
  };

  return (
    <div className="space-y-3">
      <Choice<"ethernet" | "jeton">
        label="Méthode d'accès au support"
        value={methode}
        options={[
          { value: "ethernet", label: "Ethernet (CSMA/CD)" },
          { value: "jeton", label: "Passage du jeton" },
        ]}
        onChange={(v) => {
          setMethode(v);
          setEmetteurs([]);
          setCollision(false);
        }}
      />

      <div className="flex flex-wrap gap-1.5">
        {[0, 1, 2, 3].map((k) => {
          const actif = methode === "jeton" ? jeton === k : emetteurs.includes(k);
          return (
            <button
              key={k}
              type="button"
              onClick={() => emettre(k)}
              className={
                actif
                  ? collision && methode === "ethernet"
                    ? "rounded-lg border-2 border-rose-500 bg-rose-500/20 px-3 py-2 text-xs font-semibold text-rose-700"
                    : "rounded-lg border-2 border-emerald-500 bg-emerald-500/20 px-3 py-2 text-xs font-semibold text-emerald-700"
                  : "rounded-lg border border-border bg-background px-3 py-2 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
              }
            >
              Poste {k + 1}
              {methode === "jeton" && jeton === k ? " — a le jeton" : ""}
            </button>
          );
        })}
      </div>

      {methode === "jeton" ? (
        <>
          <button
            type="button"
            onClick={() => setJeton((v) => (v + 1) % 4)}
            className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Passer le jeton au suivant
          </button>
          <Verdict tone="ok">
            Un seul poste détient le jeton, et lui seul peut émettre. Les trois autres attendent
            leur tour, même s&apos;ils ont quelque chose à dire.{" "}
            <strong>Aucune collision n&apos;est possible</strong> — c&apos;est la grande qualité de
            la méthode — mais chaque poste perd du temps à attendre le bâton de parole, même quand
            le réseau est désert.
          </Verdict>
        </>
      ) : (
        <>
          <p className="text-[11px] text-muted-foreground">
            Clique deux postes pour les faire émettre en même temps.
          </p>
          {collision ? (
            <div className="space-y-1.5">
              <Verdict tone="bad">
                Collision. Les deux signaux se superposent sur le même support et les deux trames
                sont détruites.
              </Verdict>
              <div className="space-y-1 rounded-lg border border-border bg-background p-3 text-[11px] text-muted-foreground">
                <p>
                  <strong className="text-foreground">1. Écoute</strong> — chaque poste écoute avant
                  d&apos;émettre. C&apos;est le CS de CSMA/CD : <em>Carrier Sense</em>.
                </p>
                <p>
                  <strong className="text-foreground">2. Détection</strong> — les deux ont cru le
                  support libre au même instant. Ils détectent la collision : c&apos;est le CD,{" "}
                  <em>Collision Detection</em>.
                </p>
                <p>
                  <strong className="text-foreground">3. Arrêt</strong> — les deux cessent
                  d&apos;émettre immédiatement.
                </p>
                <p>
                  <strong className="text-foreground">4. Attente aléatoire</strong> — chacun tire un
                  délai <em>au hasard</em>. C&apos;est ce hasard qui évite qu&apos;ils ne
                  recommencent ensemble.
                </p>
                <p>
                  <strong className="text-foreground">5. Reprise</strong> — le premier dont le délai
                  s&apos;écoule réémet, l&apos;autre trouve le support occupé et patiente.
                </p>
              </div>
            </div>
          ) : emetteurs.length === 1 ? (
            <Verdict tone="ok">
              Un seul poste émet : le support est libre, la trame passe tout de suite. C&apos;est
              pour cela qu&apos;Ethernet est imbattable quand le réseau est peu chargé — aucune
              attente, aucun protocole à respecter.
            </Verdict>
          ) : (
            <Verdict tone="warn">
              Fais émettre un poste, puis deux, et regarde ce qui se passe.
            </Verdict>
          )}
        </>
      )}

      <div className="space-y-2 border-t border-border pt-3">
        <Ctrl
          label="Charge du réseau"
          value={charge}
          min={5}
          max={100}
          step={5}
          onChange={setCharge}
          display={`${charge} %`}
        />
        <Panel>
          <Stat
            label="Débit utile en Ethernet"
            value={`${utileEthernet} %`}
            color={methode === "ethernet" ? PALETTE.blue : PALETTE.slate}
          />
          <Stat
            label="Débit utile avec le jeton"
            value={`${utileJeton} %`}
            color={methode === "jeton" ? PALETTE.blue : PALETTE.slate}
          />
        </Panel>
        {utileJeton > utileEthernet ? (
          <Verdict tone="warn">
            À {charge} % de charge, Ethernet ne rend plus que {utileEthernet} % : les collisions se
            multiplient, et le temps passé à recommencer dépasse le temps passé à transmettre. Le
            jeton, lui, tient ses {utileJeton} % — il est lent mais il ne s&apos;écroule jamais.
            C&apos;est la réponse à « quelle méthode pour un réseau très chargé ».
          </Verdict>
        ) : (
          <Verdict tone="ok">
            À {charge} % de charge, Ethernet rend {utileEthernet} % contre {utileJeton} % au jeton :
            il gagne, parce qu&apos;un poste qui a quelque chose à dire le dit tout de suite. Monte
            la charge au-delà de 55 % et regarde la courbe s&apos;inverser.
          </Verdict>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 8 — Poste à poste contre client-serveur                    */
/* ------------------------------------------------------------------ */

export function ArchitecturesReseau() {
  const [archi, setArchi] = useState<"p2p" | "cs">("p2p");
  const [postes, setPostes] = useState(10);
  const [tombe, setTombe] = useState<"rien" | "poste" | "serveur">("rien");
  const [requete, setRequete] = useState(false);

  const serveurMort = archi === "cs" && tombe === "serveur";
  const accessibles =
    archi === "p2p"
      ? tombe === "poste"
        ? postes - 1
        : postes
      : serveurMort
        ? 0
        : tombe === "poste"
          ? postes - 1
          : postes;

  // En poste à poste, chacun gère ses comptes et ses partages : la charge administrative explose.
  const comptes = archi === "p2p" ? postes * postes : postes;
  const admin = archi === "p2p" ? Math.round(postes * 1.5) : 3;

  return (
    <div className="space-y-3">
      <Choice<"p2p" | "cs">
        label="Architecture"
        value={archi}
        options={[
          { value: "p2p", label: "Poste à poste" },
          { value: "cs", label: "Client-serveur" },
        ]}
        onChange={(v) => {
          setArchi(v);
          setTombe("rien");
          setRequete(false);
        }}
      />
      <Ctrl
        label="Nombre de postes"
        value={postes}
        min={3}
        max={30}
        step={1}
        onChange={setPostes}
        display={`${postes}`}
      />
      <Choice<"rien" | "poste" | "serveur">
        label="Faire tomber une machine"
        value={tombe}
        options={
          archi === "cs"
            ? [
                { value: "rien" as const, label: "Rien ne tombe" },
                { value: "poste" as const, label: "Un poste tombe" },
                { value: "serveur" as const, label: "Le serveur tombe" },
              ]
            : [
                { value: "rien" as const, label: "Rien ne tombe" },
                { value: "poste" as const, label: "Un poste tombe" },
              ]
        }
        onChange={setTombe}
      />

      <button
        type="button"
        onClick={() => setRequete((v) => !v)}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        {requete ? "Effacer la demande" : "Demander un fichier depuis le poste 1"}
      </button>

      {requete ? (
        <div className="rounded-lg border border-border bg-background p-3">
          <p className="mb-1 text-xs font-semibold">Chemin de la requête</p>
          {archi === "p2p" ? (
            <p className="font-mono text-[11px] text-muted-foreground">
              Poste 1 → Poste 2 (qui détient le fichier) → Poste 1
              <br />
              <span className="text-foreground">
                Encore faut-il savoir lequel le détient, et qu&apos;il soit allumé.
              </span>
            </p>
          ) : serveurMort ? (
            <p className="font-mono text-[11px] text-rose-600">
              Poste 1 → Serveur … aucune réponse
              <br />
              <span className="font-semibold">Les {postes} postes sont bloqués.</span>
            </p>
          ) : (
            <p className="font-mono text-[11px] text-muted-foreground">
              Poste 1 → Serveur → Poste 1
              <br />
              <span className="text-foreground">
                Un seul endroit à interroger, toujours le même, toujours allumé.
              </span>
            </p>
          )}
        </div>
      ) : null}

      <Panel>
        <Stat
          label="Postes qui travaillent"
          value={`${accessibles} / ${postes}`}
          color={
            accessibles === 0 ? PALETTE.red : accessibles < postes ? PALETTE.orange : PALETTE.green
          }
        />
        <Stat
          label="Comptes à créer"
          value={`${comptes}`}
          color={comptes > 100 ? PALETTE.red : PALETTE.ink}
        />
      </Panel>
      <Panel>
        <Stat label="Heures d'administration par semaine" value={`${admin} h`} />
        <Stat
          label="Coût du serveur"
          value={archi === "cs" ? "450 × 1000 F" : "aucun"}
          color={PALETTE.blue}
        />
      </Panel>

      {serveurMort ? (
        <Verdict tone="bad">
          Le serveur est tombé, et avec lui tout le réseau : plus de fichiers partagés, plus
          d&apos;authentification, plus rien. C&apos;est <strong>le</strong> défaut du
          client-serveur, et la raison pour laquelle on double les serveurs importants et on les met
          sur onduleur. En poste à poste, la même panne n&apos;aurait coûté qu&apos;une machine.
        </Verdict>
      ) : archi === "p2p" && postes > 12 ? (
        <Verdict tone="bad">
          {postes} postes en poste à poste : {comptes} comptes à créer et à maintenir, et {admin}{" "}
          heures d&apos;administration par semaine. Chaque poste gère ses propres utilisateurs et
          ses propres partages. Au-delà d&apos;une dizaine de machines, cette architecture devient
          ingérable — c&apos;est la limite exacte qu&apos;on demande en examen.
        </Verdict>
      ) : archi === "p2p" ? (
        <Verdict tone="ok">
          {postes} postes égaux, chacun à la fois client et serveur. Pas de serveur à acheter,
          installation immédiate : c&apos;est la bonne architecture pour une petite salle. Monte le
          nombre de postes et regarde la charge administrative.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          Un serveur central : {comptes} comptes seulement, {admin} heures d&apos;administration,
          sauvegarde en un seul endroit et droits gérés d&apos;un seul point. Fais maintenant tomber
          le serveur pour voir le prix de cette centralisation.
        </Verdict>
      )}
    </div>
  );
}
