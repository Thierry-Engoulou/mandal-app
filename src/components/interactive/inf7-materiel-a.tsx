import { useState } from "react";
import { Choice, Ctrl, PALETTE, Panel, Stat, Verdict } from "./controls";
import { JeuClassement } from "./info1-jeux";
import { JeuFiche } from "./inf7-noyau";

/** Informatique Terminale C et D — chapitres 1 et 2 : environnement et fonctionnement. */

/* ------------------------------------------------------------------ */
/* Chapitre 1 — Personnel, d'organisation ou de contrôle-commande ?    */
/* ------------------------------------------------------------------ */

export function TypesSystemes() {
  return (
    <JeuClassement
      aide="Une seule question tranche : ce système sert-il une personne, une organisation, ou une machine ?"
      libelleChoix="Type de système informatique"
      options={[
        { value: "per", label: "Personnel" },
        { value: "org", label: "D'organisation" },
        { value: "cmd", label: "De contrôle-commande" },
      ]}
      cas={[
        {
          enonce: "Le portable sur lequel un élève de Terminale rédige ses exposés.",
          bonne: "per",
          pourquoi: "Une seule personne, ses propres besoins : c'est un système personnel.",
        },
        {
          enonce: "Le serveur du lycée qui conserve les notes et édite les bulletins.",
          bonne: "org",
          pourquoi:
            "Il sert plusieurs services d'un même établissement et fait circuler l'information entre eux.",
        },
        {
          enonce:
            "Le dispositif qui règle la température d'une cuve dans une brasserie et coupe le chauffage tout seul.",
          bonne: "cmd",
          pourquoi:
            "Il pilote un processus physique en temps réel, sans qu'une personne ait à intervenir.",
        },
        {
          enonce: "La box internet d'une famille à Yaoundé.",
          bonne: "per",
          pourquoi:
            "Elle sert un foyer, pas une organisation. Le critère reste : combien de services distincts en dépendent ?",
        },
        {
          enonce: "Le robot qui remplit et bouche les bouteilles d'une chaîne d'embouteillage.",
          bonne: "cmd",
          pourquoi: "Capteurs, actionneurs, temps réel : le modèle même du contrôle-commande.",
        },
        {
          enonce:
            "Le logiciel de gestion des stocks d'une pharmacie, avec sa caisse et ses achats.",
          bonne: "org",
          pourquoi:
            "Plusieurs fonctions de l'entreprise partagent les mêmes données : c'est un système d'organisation.",
        },
        {
          enonce: "Le pilote automatique d'un avion.",
          bonne: "cmd",
          pourquoi:
            "Il agit sur les commandes de vol d'après des mesures, en continu. Une réponse tardive serait une faute.",
        },
        {
          enonce: "Le téléphone sur lequel tu consultes tes messages.",
          bonne: "per",
          pourquoi:
            "Un utilisateur, un appareil : personnel, même s'il est connecté au monde entier.",
        },
        {
          enonce:
            "Le système de la CAMWATER qui enregistre les consommations, édite les factures et suit les paiements.",
          bonne: "org",
          pourquoi:
            "Relevé, facturation, comptabilité : trois services, une même base. C'est un système d'organisation.",
        },
        {
          enonce: "Le régulateur d'un feu tricolore qui adapte les durées au trafic mesuré.",
          bonne: "cmd",
          pourquoi: "Il mesure et il agit immédiatement sur un équipement : contrôle-commande.",
        },
        {
          enonce: "Le poste du secrétariat avec son traitement de texte et son tableur.",
          bonne: "per",
          pourquoi:
            "Le poste en lui-même est personnel. C'est le serveur auquel il se connecte qui relève de l'organisation.",
        },
        {
          enonce: "Le distributeur automatique d'une banque.",
          bonne: "org",
          pourquoi:
            "Il est le guichet avancé du système de l'organisation : il consulte et met à jour les comptes de la banque.",
        },
      ]}
    />
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 1 — Lire une fiche de périphérique                         */
/* ------------------------------------------------------------------ */

const IMPRIMANTES = [
  {
    id: "mat",
    label: "Matricielle",
    ppm: 2,
    dpi: 180,
    cout: 3,
    bruit: "très bruyante",
    note: "Elle frappe le papier : c'est la seule qui imprime des liasses en plusieurs exemplaires, et c'est pour cela qu'on la garde pour les factures à souche.",
  },
  {
    id: "jet",
    label: "Jet d'encre",
    ppm: 10,
    dpi: 1200,
    cout: 60,
    bruit: "silencieuse",
    note: "Excellente en couleur et bon marché à l'achat. Mais la cartouche coûte cher à la page, et elle sèche si l'on imprime rarement.",
  },
  {
    id: "las",
    label: "Laser",
    ppm: 30,
    dpi: 1200,
    cout: 8,
    bruit: "discrète",
    note: "Chère à l'achat, économique à l'usage. C'est le bon choix pour un secrétariat qui imprime des centaines de pages par semaine.",
  },
] as const;

export function FichePeripherique() {
  const [pouces, setPouces] = useState(15.6);
  const [pages, setPages] = useState(500);

  const cm = pouces * 2.54;
  const DEF = IMPRIMANTES[0];

  return (
    <div className="space-y-4">
      <div className="space-y-2">
        <p className="text-xs font-medium text-muted-foreground">
          L&apos;écran : la diagonale se mesure en pouces
        </p>
        <Ctrl
          label="Diagonale de l'écran"
          value={pouces}
          min={10}
          max={32}
          step={0.1}
          onChange={setPouces}
          display={`${pouces.toFixed(1)} pouces`}
        />
        <Panel>
          <Stat label="En centimètres" value={`${cm.toFixed(1)} cm`} color={PALETTE.blue} />
          <Stat label="Un pouce vaut" value="2,54 cm" />
        </Panel>
        <p className="text-[11px] text-muted-foreground">
          La diagonale ne dit rien de la finesse de l&apos;image : celle-là se lit dans la
          résolution, en pixels, et la fluidité dans la fréquence de rafraîchissement, en hertz. Un
          écran de 24 pouces en 1920 × 1080 est moins net qu&apos;un 15 pouces dans la même
          résolution, parce que les mêmes pixels y sont étalés sur plus de surface.
        </p>
      </div>

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">
          Les trois imprimantes pour un même travail
        </p>
        <Ctrl
          label="Pages à imprimer"
          value={pages}
          min={10}
          max={3000}
          step={10}
          onChange={setPages}
          display={`${pages} pages`}
        />

        <div className="overflow-x-auto">
          <table className="w-full border-collapse text-xs">
            <thead>
              <tr>
                <th className="border border-border bg-secondary/40 px-2 py-1 text-left font-medium">
                  Technologie
                </th>
                <th className="border border-border bg-secondary/40 px-2 py-1 text-center font-medium">
                  Vitesse
                </th>
                <th className="border border-border bg-secondary/40 px-2 py-1 text-center font-medium">
                  Résolution
                </th>
                <th className="border border-border bg-secondary/40 px-2 py-1 text-center font-medium">
                  Durée
                </th>
                <th className="border border-border bg-secondary/40 px-2 py-1 text-center font-medium">
                  Coût
                </th>
              </tr>
            </thead>
            <tbody>
              {IMPRIMANTES.map((im) => (
                <tr key={im.id}>
                  <td className="border border-border px-2 py-1 font-semibold">{im.label}</td>
                  <td className="border border-border px-2 py-1 text-center font-mono">
                    {im.ppm} ppm
                  </td>
                  <td className="border border-border px-2 py-1 text-center font-mono">
                    {im.dpi} ppp
                  </td>
                  <td className="border border-border px-2 py-1 text-center font-mono">
                    {Math.round(pages / im.ppm)} min
                  </td>
                  <td className="border border-border px-2 py-1 text-center font-mono">
                    {((pages * im.cout) / 1000).toFixed(1)} k
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <p className="text-[11px] text-muted-foreground">
          Les unités, dans l&apos;ordre : <strong>ppm</strong>, pages par minute, pour la vitesse ;{" "}
          <strong>ppp</strong> — ou <em>dpi</em> — points par pouce, pour la finesse ; et le coût en
          francs pour {pages} pages. Les durées sont des minutes d&apos;impression continue.
        </p>

        {pages >= 1000 ? (
          <Verdict tone="ok">
            À {pages} pages, la laser est imbattable : {Math.round(pages / 30)} minutes contre{" "}
            {Math.round(pages / 2)} pour la matricielle, et le coût le plus bas des trois après la
            matricielle. {IMPRIMANTES[2]?.note ?? DEF.note}
          </Verdict>
        ) : pages <= 100 ? (
          <Verdict tone="warn">
            À {pages} pages seulement, la durée ne décide plus rien : toutes finissent en quelques
            minutes. C&apos;est l&apos;usage qui tranche. {IMPRIMANTES[1]?.note ?? DEF.note}
          </Verdict>
        ) : (
          <Verdict tone="warn">
            Entre 100 et 1000 pages, le choix se joue sur le type de document : couleur et photos
            pour la jet d&apos;encre, volume et texte pour la laser, liasses à souche pour la
            matricielle.
          </Verdict>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 1 — Logiciels de base, d'application, procédures           */
/* ------------------------------------------------------------------ */

export function TypesLogiciels() {
  return (
    <JeuClassement
      aide="Demande-toi d'abord : est-ce que ce logiciel fait marcher la machine, ou est-ce qu'il fait le travail de l'utilisateur ?"
      libelleChoix="Sa catégorie"
      options={[
        { value: "base", label: "Logiciel de base" },
        { value: "std", label: "Application standard" },
        { value: "prog", label: "Progiciel" },
        { value: "spe", label: "Application spécifique" },
        { value: "proc", label: "Procédure" },
      ]}
      cas={[
        {
          enonce: "Il démarre la machine, gère la mémoire et les fichiers, et lance les autres.",
          bonne: "base",
          pourquoi:
            "C'est le système d'exploitation. Les logiciels de base font fonctionner la machine, ils ne font pas le travail de l'utilisateur.",
        },
        {
          enonce: "Il permet de saisir des nombres dans des cellules et de les calculer.",
          bonne: "std",
          pourquoi:
            "Un tableur sert à n'importe quel métier : c'est une application standard, vendue telle quelle.",
        },
        {
          enonce:
            "Acheté tout fait, il gère les ordonnances, les stocks et la caisse d'une pharmacie.",
          bonne: "prog",
          pourquoi:
            "Un progiciel est un produit du commerce, mais destiné à un métier précis. C'est son caractère professionnel et acheté qui le définit.",
        },
        {
          enonce:
            "Écrit sur mesure par un informaticien pour la gestion des inscriptions de ce lycée-là.",
          bonne: "spe",
          pourquoi:
            "Développée pour un seul client et son besoin particulier : application spécifique.",
        },
        {
          enonce: "La note de service qui dit comment sauvegarder les notes chaque vendredi.",
          bonne: "proc",
          pourquoi:
            "Une procédure n'est pas un programme : c'est la règle écrite qui dit qui fait quoi, quand et comment.",
        },
        {
          enonce: "Il traduit les ordres du système vers une imprimante d'une marque donnée.",
          bonne: "base",
          pourquoi:
            "C'est un pilote. Les pilotes et les utilitaires font partie des logiciels de base.",
        },
        {
          enonce: "Il sert à écrire et mettre en page un courrier ou un rapport.",
          bonne: "std",
          pourquoi: "Le traitement de texte est l'application standard par excellence.",
        },
        {
          enonce: "Acheté chez un éditeur, il tient la comptabilité générale d'une entreprise.",
          bonne: "prog",
          pourquoi:
            "Métier précis, produit du commerce : progiciel. S'il avait été écrit sur mesure, ce serait une application spécifique.",
        },
        {
          enonce: "Il compresse un dossier avant de l'envoyer par courrier électronique.",
          bonne: "base",
          pourquoi:
            "Un utilitaire : il ne produit rien pour le métier, il entretient et facilite le fonctionnement de la machine.",
        },
        {
          enonce: "Le mode opératoire affiché près du photocopieur de la salle des professeurs.",
          bonne: "proc",
          pourquoi:
            "Encore une procédure. Retiens qu'un système informatique comprend du matériel, des logiciels, des données, du personnel — et des procédures.",
        },
      ]}
    />
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 2 — Ouvrir le boîtier                                      */
/* ------------------------------------------------------------------ */

const COMPOSANTS = [
  {
    id: "cm",
    label: "Carte mère",
    role: "Elle relie tout le reste : c'est le plan de circulation de la machine.",
    carac: "Format (ATX, microATX, ITX), chipset, type de socket, nombre de connecteurs",
  },
  {
    id: "cpu",
    label: "Processeur",
    role: "Il exécute les instructions. Il calcule, compare, et commande le reste.",
    carac: "Fréquence en gigahertz (GHz), nombre de cœurs, mémoire cache en Mo",
  },
  {
    id: "ram",
    label: "Barrettes de mémoire vive",
    role: "Elles contiennent les programmes et les données en cours d'utilisation. Tout s'efface à l'extinction.",
    carac: "Capacité en gigaoctets (Go), type (DDR4, DDR5), fréquence en MHz",
  },
  {
    id: "dd",
    label: "Disque dur ou SSD",
    role: "Il conserve le système, les logiciels et les fichiers même machine éteinte.",
    carac: "Capacité en gigaoctets ou téraoctets, technologie (HDD ou SSD), vitesse de transfert",
  },
  {
    id: "bus",
    label: "Connecteurs d'extension",
    role: "Ils accueillent les cartes ajoutées : carte graphique, carte réseau, carte son.",
    carac: "Type (PCI Express), nombre de lignes, génération",
  },
  {
    id: "chip",
    label: "Chipset",
    role: "Il organise les échanges entre le processeur, la mémoire et les périphériques.",
    carac: "Référence du modèle, débit supporté, nombre de ports gérés",
  },
  {
    id: "alim",
    label: "Bloc d'alimentation",
    role: "Il transforme le 220 volts alternatif de la prise en basses tensions continues.",
    carac: "Puissance en watts (W), rendement, tensions fournies : 12 V, 5 V, 3,3 V",
  },
] as const;

const FORMATS = [
  { value: "atx", label: "ATX", pci: 7, ram: 4, taille: "30,5 × 24,4 cm" },
  { value: "matx", label: "microATX", pci: 4, ram: 4, taille: "24,4 × 24,4 cm" },
  { value: "itx", label: "mini-ITX", pci: 1, ram: 2, taille: "17 × 17 cm" },
] as const;

export function CarteMere() {
  const [sel, setSel] = useState<string>("cm");
  const [fmt, setFmt] = useState<"atx" | "matx" | "itx">("atx");

  const c = COMPOSANTS.find((x) => x.id === sel) ?? COMPOSANTS[0];
  const f = FORMATS.find((x) => x.value === fmt) ?? FORMATS[0];

  return (
    <div className="space-y-3">
      <p className="text-xs font-medium text-muted-foreground">
        Clique sur un composant pour voir son rôle et ses unités
      </p>
      <div className="flex flex-wrap gap-1.5">
        {COMPOSANTS.map((x) => (
          <button
            key={x.id}
            type="button"
            onClick={() => setSel(x.id)}
            className={
              x.id === sel
                ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
                : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            }
          >
            {x.label}
          </button>
        ))}
      </div>

      <div className="rounded-lg border border-border bg-background p-3">
        <p className="text-sm font-semibold">{c.label}</p>
        <p className="mt-1 text-xs text-muted-foreground">{c.role}</p>
        <p className="mt-2 text-[11px] text-muted-foreground">
          <span className="font-semibold text-foreground">On la décrit par : </span>
          {c.carac}
        </p>
      </div>

      <div className="space-y-2 border-t border-border pt-3">
        <Choice<"atx" | "matx" | "itx">
          label="Format de la carte mère"
          value={fmt}
          options={FORMATS.map((x) => ({ value: x.value, label: x.label }))}
          onChange={setFmt}
        />
        <Panel>
          <Stat label="Dimensions" value={f.taille} />
          <Stat label="Connecteurs PCI Express" value={`${f.pci}`} color={PALETTE.blue} />
        </Panel>
        <Panel>
          <Stat label="Emplacements mémoire" value={`${f.ram}`} color={PALETTE.blue} />
          <Stat label="Mémoire maximale" value={`${f.ram * 32} Go`} color={PALETTE.green} />
        </Panel>
        {fmt === "itx" ? (
          <Verdict tone="warn">
            Un seul connecteur d&apos;extension et deux emplacements mémoire. Le mini-ITX tient dans
            un boîtier minuscule, mais tu ne pourras ajouter qu&apos;une seule carte : si tu mets la
            carte graphique, plus de place pour une carte réseau. C&apos;est tout l&apos;enjeu du
            format : la carte mère décide de ce que la machine pourra devenir.
          </Verdict>
        ) : fmt === "atx" ? (
          <Verdict tone="ok">
            Sept connecteurs, quatre emplacements mémoire : une tour ATX s&apos;agrandit pendant des
            années. C&apos;est le format des machines de bureau et des serveurs d&apos;entrée de
            gamme.
          </Verdict>
        ) : (
          <Verdict tone="ok">
            Le microATX est le compromis le plus courant dans les lycées : quatre connecteurs et
            quatre emplacements mémoire, dans un boîtier qui tient sous le bureau.
          </Verdict>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 2 — Le périphérique qui refuse de fonctionner              */
/* ------------------------------------------------------------------ */

const PANNES_PERIPH = [
  {
    id: "vp",
    label: "Vidéoprojecteur neuf",
    symptome: "Branché en HDMI, il affiche « aucun signal ».",
    verifs: {
      branchement: "Le câble est bien enfoncé des deux côtés.",
      cable: "Testé avec un autre câble : même résultat.",
      gestionnaire: "Aucun point d'exclamation : Windows voit l'écran.",
      pilote: "Le pilote est à jour.",
    },
    cause: "source",
    reponse:
      "Ce n'était pas la machine : le vidéoprojecteur était sur la mauvaise entrée. Avant d'accuser un pilote, vérifie la source sélectionnée sur l'appareil lui-même.",
  },
  {
    id: "imp",
    label: "Imprimante après réinstallation",
    symptome: "Elle était reconnue hier, plus du tout depuis la réinstallation de Windows.",
    verifs: {
      branchement: "Câble USB branché, voyant allumé.",
      cable: "Autre câble : même résultat.",
      gestionnaire: "Un point d'exclamation jaune sur « Périphérique inconnu ».",
      pilote: "Aucun pilote installé pour ce modèle.",
    },
    cause: "pilote",
    reponse:
      "Le point d'exclamation jaune dans le gestionnaire est l'indice décisif : le matériel est vu, mais la machine ne sait pas lui parler. Une réinstallation efface les pilotes installés à la main.",
  },
  {
    id: "son",
    label: "Carte son",
    symptome: "Plus aucun son, alors que rien n'a été touché.",
    verifs: {
      branchement: "Haut-parleurs branchés sur la bonne prise verte.",
      cable: "Testés sur un autre poste : ils fonctionnent.",
      gestionnaire: "Point d'exclamation sur le contrôleur audio.",
      pilote: "Le pilote est signalé comme corrompu.",
    },
    cause: "pilote",
    reponse:
      "Un pilote peut se corrompre après une mise à jour interrompue. Désinstalle-le dans le gestionnaire, puis redémarre : Windows le réinstalle souvent tout seul.",
  },
  {
    id: "sou",
    label: "Souris",
    symptome: "Le pointeur ne bouge plus du tout.",
    verifs: {
      branchement: "Débranchée et rebranchée : rien.",
      cable: "Une autre souris sur le même port fonctionne.",
      gestionnaire: "La souris n'apparaît plus dans la liste.",
      pilote: "Le pilote standard est présent et sain.",
    },
    cause: "materiel",
    reponse:
      "Une autre souris fonctionne sur le même port : le port est bon, le pilote est bon. C'est donc la souris elle-même qui est morte. Le test par substitution est l'outil le plus rapide du dépanneur.",
  },
  {
    id: "res",
    label: "Carte réseau",
    symptome: "Pas de connexion, le câble est pourtant branché.",
    verifs: {
      branchement: "Le voyant du connecteur reste éteint.",
      cable: "Avec un autre câble, le voyant s'allume.",
      gestionnaire: "La carte apparaît normalement, sans avertissement.",
      pilote: "Pilote à jour.",
    },
    cause: "cable",
    reponse:
      "Le voyant éteint est l'indice : il n'y a pas de liaison physique. Et avec un autre câble, il s'allume. Le câble était coupé à l'intérieur de la gaine, ce qui ne se voit pas à l'œil.",
  },
] as const;

const CAUSES = [
  { value: "branchement", label: "Mauvais branchement" },
  { value: "cable", label: "Câble défectueux" },
  { value: "pilote", label: "Pilote absent ou corrompu" },
  { value: "materiel", label: "Périphérique hors service" },
  { value: "source", label: "Réglage de l'appareil lui-même" },
] as const;

type CleVerif = "branchement" | "cable" | "gestionnaire" | "pilote";

const VERIFS: ReadonlyArray<{ cle: CleVerif; label: string }> = [
  { cle: "branchement", label: "Vérifier le branchement" },
  { cle: "cable", label: "Tester un autre câble" },
  { cle: "gestionnaire", label: "Ouvrir le gestionnaire de périphériques" },
  { cle: "pilote", label: "Examiner le pilote" },
];

export function PilotePeripherique() {
  const [i, setI] = useState(0);
  const [faites, setFaites] = useState<CleVerif[]>([]);
  const [rep, setRep] = useState<string | null>(null);

  const p = PANNES_PERIPH[i] ?? PANNES_PERIPH[0];
  const juste = rep === p.cause;

  const changer = (k: number) => {
    setI(k);
    setFaites([]);
    setRep(null);
  };

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-1.5">
        {PANNES_PERIPH.map((x, k) => (
          <button
            key={x.id}
            type="button"
            onClick={() => changer(k)}
            className={
              k === i
                ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
                : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            }
          >
            {x.label}
          </button>
        ))}
      </div>

      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-sm font-medium">{p.symptome}</p>
      </div>

      <div className="space-y-1.5">
        <p className="text-xs font-medium text-muted-foreground">
          Mène tes vérifications dans l&apos;ordre que tu veux
        </p>
        <div className="flex flex-wrap gap-1.5">
          {VERIFS.map((v) => (
            <button
              key={v.cle}
              type="button"
              onClick={() => setFaites((f) => (f.includes(v.cle) ? f : [...f, v.cle]))}
              className={
                faites.includes(v.cle)
                  ? "rounded-lg border border-emerald-500/50 bg-emerald-500/10 px-2.5 py-1.5 text-xs font-medium text-emerald-700"
                  : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
              }
            >
              {v.label}
            </button>
          ))}
        </div>
      </div>

      {faites.length > 0 ? (
        <div className="space-y-1 rounded-lg border border-border bg-background p-3">
          {VERIFS.filter((v) => faites.includes(v.cle)).map((v) => {
            const txt = p.verifs[v.cle];
            const alerte = txt.includes("exclamation") || txt.includes("corrompu");
            return (
              <p key={v.cle} className="text-[11px]">
                <span className="font-semibold text-foreground">{v.label} : </span>
                <span style={{ color: alerte ? PALETTE.red : undefined }}>{txt}</span>
              </p>
            );
          })}
          {faites.includes("gestionnaire") && p.verifs.gestionnaire.includes("exclamation") ? (
            <p className="mt-1 rounded border border-amber-500/40 bg-amber-500/10 px-2 py-1 text-[11px] font-medium text-amber-700">
              ⚠ Gestionnaire de périphériques : un triangle jaune signale que le matériel est
              détecté mais qu&apos;aucun pilote valide ne lui répond.
            </p>
          ) : null}
        </div>
      ) : null}

      <Choice<string>
        label="Ton diagnostic"
        value={rep ?? ""}
        options={CAUSES.map((c) => ({ value: c.value, label: c.label }))}
        onChange={setRep}
      />

      {rep === null ? (
        <Verdict tone="warn">
          Fais au moins deux vérifications avant de te prononcer. Le test par substitution — un
          autre câble, un autre périphérique — tranche plus vite que n&apos;importe quelle
          hypothèse.
        </Verdict>
      ) : juste ? (
        <Verdict tone="ok">Exact. {p.reponse}</Verdict>
      ) : (
        <Verdict tone="bad">
          Non. {CAUSES.find((c) => c.value === p.cause)?.label ?? ""} : {p.reponse}
        </Verdict>
      )}

      <Panel>
        <Stat label="Vérifications menées" value={`${faites.length} / 4`} />
        <Stat label="Cas" value={`${i + 1} / ${PANNES_PERIPH.length}`} />
      </Panel>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 2 — Lire une fiche technique de revendeur                  */
/* ------------------------------------------------------------------ */

const LIGNES_FICHE = [
  {
    id: "l1",
    texte: "Intel Core i5-12400, 2,5 GHz, 6 cœurs",
    compo: "Processeur",
    unite: "gigahertz (GHz) pour la fréquence",
    sens: "Il exécute 2,5 milliards de cycles par seconde, sur six unités de calcul en parallèle. Les cœurs comptent autant que la fréquence : six cœurs à 2,5 GHz valent mieux qu'un seul à 4 GHz pour du montage vidéo.",
  },
  {
    id: "l2",
    texte: "8 Go DDR4 3200 MHz",
    compo: "Mémoire vive",
    unite: "gigaoctet (Go) pour la capacité, mégahertz (MHz) pour la fréquence",
    sens: "Huit gigaoctets de mémoire de travail. C'est elle qui décide combien de logiciels tu peux ouvrir en même temps sans que la machine ralentisse. Tout s'efface à l'extinction.",
  },
  {
    id: "l3",
    texte: "SSD 512 Go NVMe",
    compo: "Mémoire de masse",
    unite: "gigaoctet (Go)",
    sens: "C'est le stockage permanent. Un SSD n'a aucune pièce mobile : il démarre Windows en quelques secondes là où un disque dur classique met une minute. C'est le composant qui change le plus la sensation de rapidité.",
  },
  {
    id: "l4",
    texte: "Écran 15,6 pouces, 1920 × 1080, 60 Hz",
    compo: "Écran",
    unite:
      "pouce pour la diagonale, pixels pour la résolution, hertz (Hz) pour le rafraîchissement",
    sens: "39,6 cm de diagonale, deux millions de pixels, et 60 images par seconde. Les 60 Hz suffisent pour travailler ; les joueurs cherchent 144 Hz.",
  },
  {
    id: "l5",
    texte: "Carte graphique intégrée Intel UHD",
    compo: "Carte graphique",
    unite: "mégaoctets ou gigaoctets de mémoire dédiée",
    sens: "« Intégrée » veut dire qu'elle n'a pas de mémoire propre : elle prend sa part de la mémoire vive. Suffisant pour la bureautique, insuffisant pour le montage vidéo ou les jeux récents.",
  },
  {
    id: "l6",
    texte: "Alimentation 450 W, rendement 80 PLUS",
    compo: "Bloc d'alimentation",
    unite: "watt (W)",
    sens: "450 watts disponibles pour toute la machine. Si l'on ajoute plus tard une carte graphique dédiée, ces 450 W deviendront vite la limite — et la machine redémarrera au hasard sous charge.",
  },
] as const;

const MACHINES = [
  {
    id: "a",
    label: "Machine A",
    cpu: "Core i3, 4 cœurs, 3,6 GHz",
    ram: "16 Go",
    dd: "SSD 256 Go",
    gpu: "intégrée",
  },
  {
    id: "b",
    label: "Machine B",
    cpu: "Core i5, 6 cœurs, 2,5 GHz",
    ram: "8 Go",
    dd: "Disque dur 1 To",
    gpu: "dédiée 4 Go",
  },
] as const;

const USAGES = [
  {
    value: "bur",
    label: "Bureautique",
    gagnante: "a",
    pourquoi:
      "16 Go de mémoire et un SSD : la machine A ouvrira dix onglets et trois classeurs sans broncher, et démarrera en quelques secondes. Pour du texte et du tableur, la carte graphique dédiée de B ne sert à rien.",
  },
  {
    value: "jeu",
    label: "Jeu",
    gagnante: "b",
    pourquoi:
      "La carte graphique dédiée de 4 Go fait toute la différence : une carte intégrée ne tient pas un jeu récent, quelle que soit la mémoire vive. C'est le composant qui décide.",
  },
  {
    value: "mon",
    label: "Montage vidéo",
    gagnante: "b",
    pourquoi:
      "Six cœurs et une carte graphique dédiée : le montage vidéo exploite les deux. Mais le disque dur de B est son point faible — il faudra ajouter un SSD, et les 8 Go de mémoire seront justes.",
  },
] as const;

export function FicheTechnique() {
  const [sel, setSel] = useState<string>("l1");
  const [usage, setUsage] = useState<"bur" | "jeu" | "mon">("bur");
  const [choix, setChoix] = useState<string | null>(null);

  const l = LIGNES_FICHE.find((x) => x.id === sel) ?? LIGNES_FICHE[0];
  const u = USAGES.find((x) => x.value === usage) ?? USAGES[0];

  return (
    <div className="space-y-4">
      <div className="space-y-1.5">
        <p className="text-xs font-medium text-muted-foreground">
          Chaque ligne de la fiche est cliquable
        </p>
        <div className="divide-y divide-border rounded-lg border border-border bg-background">
          {LIGNES_FICHE.map((x) => (
            <button
              key={x.id}
              type="button"
              onClick={() => setSel(x.id)}
              className={
                x.id === sel
                  ? "block w-full bg-primary/10 px-3 py-1.5 text-left font-mono text-[11px] font-semibold text-foreground"
                  : "block w-full px-3 py-1.5 text-left font-mono text-[11px] text-muted-foreground hover:bg-secondary/40"
              }
            >
              {x.texte}
            </button>
          ))}
        </div>
        <div className="rounded-lg border border-border bg-secondary/30 p-3">
          <p className="text-sm font-semibold">{l.compo}</p>
          <p className="mt-0.5 text-[11px] text-muted-foreground">
            <span className="font-semibold text-foreground">Unité : </span>
            {l.unite}
          </p>
          <p className="mt-1.5 text-xs text-muted-foreground">{l.sens}</p>
        </div>
      </div>

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">
          Deux machines au même prix : laquelle prendre ?
        </p>
        <div className="grid gap-2 sm:grid-cols-2">
          {MACHINES.map((m) => (
            <button
              key={m.id}
              type="button"
              onClick={() => setChoix(m.id)}
              className={
                choix === m.id
                  ? "rounded-lg border-2 border-primary bg-primary/10 p-2.5 text-left"
                  : "rounded-lg border border-border bg-background p-2.5 text-left hover:bg-secondary/40"
              }
            >
              <p className="text-xs font-semibold">{m.label}</p>
              <p className="mt-1 font-mono text-[10px] text-muted-foreground">{m.cpu}</p>
              <p className="font-mono text-[10px] text-muted-foreground">Mémoire : {m.ram}</p>
              <p className="font-mono text-[10px] text-muted-foreground">Stockage : {m.dd}</p>
              <p className="font-mono text-[10px] text-muted-foreground">Graphique : {m.gpu}</p>
            </button>
          ))}
        </div>

        <Choice<"bur" | "jeu" | "mon">
          label="Pour quel usage ?"
          value={usage}
          options={USAGES.map((x) => ({ value: x.value, label: x.label }))}
          onChange={setUsage}
        />

        {choix === null ? (
          <Verdict tone="warn">
            Choisis une machine, puis un usage. Il n&apos;y a pas de meilleure machine en soi : il y
            a une machine adaptée à un travail.
          </Verdict>
        ) : choix === u.gagnante ? (
          <Verdict tone="ok">Bon choix. {u.pourquoi}</Verdict>
        ) : (
          <Verdict tone="bad">
            Pour cet usage, c&apos;est l&apos;autre machine. {u.pourquoi}
          </Verdict>
        )}
      </div>

      <div className="border-t border-border pt-3">
        <JeuFiche
          titre="Donne l'unité de chaque caractéristique"
          conclusion="Toutes les unités sont justes. C'est exactement ce qu'on attend d'une question « donner deux caractéristiques et leurs unités »."
          champs={[
            {
              id: "f1",
              label: "Fréquence du processeur",
              options: ["gigahertz", "gigaoctet", "watt"],
              bonne: "gigahertz",
              pourquoi: "Le hertz mesure une fréquence, l'octet une quantité d'information.",
            },
            {
              id: "f2",
              label: "Capacité du disque dur",
              options: ["hertz", "gigaoctet", "pouce"],
              bonne: "gigaoctet",
              pourquoi: "On compte des octets : Go, To. Le pouce mesure une longueur.",
            },
            {
              id: "f3",
              label: "Diagonale de l'écran",
              options: ["pixel", "pouce", "hertz"],
              bonne: "pouce",
              pourquoi: "Un pouce vaut 2,54 cm. Les pixels donnent la résolution, pas la taille.",
            },
            {
              id: "f4",
              label: "Puissance du bloc d'alimentation",
              options: ["volt", "watt", "ampère"],
              bonne: "watt",
              pourquoi:
                "Le watt mesure une puissance. Le volt mesure une tension — 220 V à la prise.",
            },
            {
              id: "f5",
              label: "Vitesse d'une imprimante",
              options: ["points par pouce", "pages par minute", "hertz"],
              bonne: "pages par minute",
              pourquoi:
                "Les points par pouce mesurent la finesse de l'impression, pas sa rapidité.",
            },
          ]}
        />
      </div>
    </div>
  );
}
