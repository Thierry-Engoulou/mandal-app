import { useState } from "react";
import { Choice, Ctrl, PALETTE, Panel, Stat, Verdict } from "./controls";
import { JeuClassement } from "./info1-jeux";
import { JeuCases, clamp } from "./inf7-noyau";

/** Informatique Terminale C et D — chapitres 3 et 4 : dysfonctionnements et protection. */

/* ------------------------------------------------------------------ */
/* Chapitre 3 — Le symptôme et sa cause matérielle                     */
/* ------------------------------------------------------------------ */

const SYMPTOMES = [
  {
    id: "s1",
    texte: "La machine s'éteint toute seule après une heure de travail, jamais avant.",
    cause: "chaleur",
    indice:
      "Le délai. Une heure, c'est le temps qu'il faut à la poussière pour faire monter la température jusqu'au seuil de sécurité du processeur.",
  },
  {
    id: "s2",
    texte: "Aucun voyant, aucun bruit de ventilateur, rien du tout quand on appuie.",
    cause: "alim",
    indice:
      "L'absence totale de signe de vie. Même un processeur mort laisse tourner les ventilateurs : ici, plus rien n'arrive aux composants.",
  },
  {
    id: "s3",
    texte: "L'heure et la date sont à réinitialiser à chaque démarrage.",
    cause: "pile",
    indice:
      "C'est le symptôme signature de la pile de la carte mère. Elle entretient l'horloge quand la machine est débranchée, et elle se vide au bout de quelques années.",
  },
  {
    id: "s4",
    texte: "Une série de bips au lancement, et l'écran reste noir.",
    cause: "ram",
    indice:
      "Les bips sont un code : la machine n'a pas trouvé de mémoire utilisable et ne peut donc rien afficher. Réenfonce les barrettes, ou retire-les une par une.",
  },
  {
    id: "s5",
    texte: "Un grincement régulier, puis des fichiers qui ne s'ouvrent plus.",
    cause: "disque",
    indice:
      "Le bruit. Un disque dur qui grince a ses têtes ou ses roulements en fin de vie. Sauvegarde immédiatement : il ne se répare pas, il se remplace.",
  },
  {
    id: "s6",
    texte: "Des traits de couleur en travers de l'écran, de plus en plus nombreux.",
    cause: "ecran",
    indice:
      "Branche un autre écran : si les traits disparaissent, c'est la dalle ou la nappe. S'ils restent, c'est la carte graphique.",
  },
  {
    id: "s7",
    texte: "La machine redémarre brutalement dès qu'on lance un jeu, jamais en bureautique.",
    cause: "alim",
    indice:
      "Le moment. Le jeu fait monter la demande en courant d'un coup, et le bloc n'arrive pas à suivre : il décroche, et tout redémarre.",
  },
  {
    id: "s8",
    texte: "Les ventilateurs tournent à plein régime en permanence, même au repos.",
    cause: "chaleur",
    indice:
      "La machine se défend contre une chaleur anormale. Souffle la poussière des grilles et du radiateur : c'est la première opération, et souvent la seule nécessaire.",
  },
] as const;

const CAUSES_MAT = [
  { value: "chaleur", label: "Surchauffe, poussière" },
  { value: "alim", label: "Bloc d'alimentation" },
  { value: "pile", label: "Pile de la carte mère" },
  { value: "ram", label: "Mémoire vive" },
  { value: "disque", label: "Disque dur" },
  { value: "ecran", label: "Écran ou carte graphique" },
] as const;

export function CausesMaterielles() {
  const [i, setI] = useState(0);
  const [rep, setRep] = useState<string | null>(null);
  const [mois, setMois] = useState(0);

  const s = SYMPTOMES[i] ?? SYMPTOMES[0];
  const juste = rep === s.cause;

  // Une machine propre tourne autour de 45 °C ; la poussière ajoute environ 2 °C par mois.
  const temp = 45 + mois * 2;
  const seuil = 95;

  return (
    <div className="space-y-4">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-[11px] text-muted-foreground">
          Machine {i + 1} sur {SYMPTOMES.length}
        </p>
        <p className="text-sm font-medium">{s.texte}</p>
      </div>

      <Choice<string>
        label="La cause la plus probable"
        value={rep ?? ""}
        options={CAUSES_MAT.map((c) => ({ value: c.value, label: c.label }))}
        onChange={setRep}
      />

      {rep === null ? (
        <Verdict tone="warn">
          Cherche l&apos;indice décisif dans l&apos;énoncé : un délai, un bruit, un moment précis.
          Ce sont eux qui distinguent deux causes qui donnent le même symptôme.
        </Verdict>
      ) : juste ? (
        <Verdict tone="ok">
          Exact. <span className="font-semibold">L&apos;indice décisif : </span>
          {s.indice}
        </Verdict>
      ) : (
        <Verdict tone="bad">
          Non, c&apos;est « {CAUSES_MAT.find((c) => c.value === s.cause)?.label ?? ""} ». {s.indice}
        </Verdict>
      )}

      <div className="flex gap-2">
        <button
          type="button"
          onClick={() => {
            setI((v) => (v + SYMPTOMES.length - 1) % SYMPTOMES.length);
            setRep(null);
          }}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Précédente
        </button>
        <button
          type="button"
          onClick={() => {
            setI((v) => (v + 1) % SYMPTOMES.length);
            setRep(null);
          }}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Machine suivante
        </button>
      </div>

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">
          Le thermomètre : la poussière s&apos;accumule mois après mois
        </p>
        <Ctrl
          label="Mois sans nettoyage"
          value={mois}
          min={0}
          max={30}
          step={1}
          onChange={setMois}
          display={`${mois} mois`}
          color={temp >= seuil ? PALETTE.red : PALETTE.blue}
        />
        <Panel>
          <Stat
            label="Température du processeur"
            value={`${temp} °C`}
            color={temp >= seuil ? PALETTE.red : temp >= 80 ? PALETTE.orange : PALETTE.green}
          />
          <Stat label="Seuil de coupure" value={`${seuil} °C`} />
        </Panel>
        {temp >= seuil ? (
          <Verdict tone="bad">
            {temp} °C : le processeur a atteint son seuil. Il se bride d&apos;abord — la machine
            rame sans raison apparente — puis la coupure de sécurité éteint tout. C&apos;est le
            scénario de la machine qui s&apos;éteint après une heure de travail : la chaleur met du
            temps à monter, et c&apos;est ce délai qui trahit la cause.
          </Verdict>
        ) : temp >= 80 ? (
          <Verdict tone="warn">
            {temp} °C : encore supportable, mais les ventilateurs tournent déjà fort et la machine
            commence à ralentir sous charge. Un nettoyage maintenant évite la panne.
          </Verdict>
        ) : (
          <Verdict tone="ok">
            {temp} °C : une machine saine. C&apos;est l&apos;état qu&apos;un nettoyage trimestriel
            maintient — et c&apos;est exactement cela, de la maintenance préventive.
          </Verdict>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 3 — Matériel ou logiciel ?                                 */
/* ------------------------------------------------------------------ */

export function DiagnosticDysfonctionnement() {
  return (
    <JeuClassement
      aide="Le test qui sert de frontière : la machine passe-t-elle la séquence de démarrage et charge-t-elle son système ? Si elle n'y arrive pas, cherche d'abord du côté du matériel."
      libelleChoix="Origine du dysfonctionnement"
      options={[
        { value: "mat", label: "Matérielle" },
        { value: "log", label: "Logicielle" },
      ]}
      cas={[
        {
          enonce: "Aucun voyant ne s'allume, aucun ventilateur ne tourne.",
          bonne: "mat",
          pourquoi:
            "La machine ne démarre même pas : aucun logiciel n'a eu le temps de s'exécuter. L'alimentation est en cause.",
        },
        {
          enonce: "Windows démarre, puis affiche un écran bleu quelques secondes après.",
          bonne: "log",
          pourquoi:
            "Le démarrage a réussi : le matériel fonctionne. Un pilote ou une mise à jour est fautif. Attention toutefois : une mémoire vive défaillante donne le même symptôme, et c'est le test de la mémoire qui tranche.",
        },
        {
          enonce: "Une série de bips au lancement, écran noir.",
          bonne: "mat",
          pourquoi:
            "Les bips viennent du BIOS, avant tout chargement de système : c'est un défaut matériel, le plus souvent la mémoire.",
        },
        {
          enonce: "Le traitement de texte se ferme tout seul à chaque ouverture d'un fichier.",
          bonne: "log",
          pourquoi:
            "Un seul logiciel est touché, le reste fonctionne. Réinstalle-le, ou soupçonne le fichier lui-même.",
        },
        {
          enonce: "La machine s'éteint après une heure, toujours.",
          bonne: "mat",
          pourquoi:
            "La régularité du délai désigne la température, donc la poussière et la ventilation.",
        },
        {
          enonce: "L'heure se dérègle à chaque démarrage.",
          bonne: "mat",
          pourquoi: "La pile de la carte mère est vide. Rien à voir avec le système.",
        },
        {
          enonce:
            "Les fichiers du dossier Documents portent des noms bizarres et ne s'ouvrent plus.",
          bonne: "log",
          pourquoi:
            "C'est la signature d'un logiciel malveillant, un rançongiciel. Le matériel va parfaitement bien.",
        },
        {
          enonce: "La machine met huit minutes à démarrer depuis six mois, et le disque grince.",
          bonne: "mat",
          pourquoi:
            "Le bruit est l'indice. Un disque en fin de vie relit sans cesse les mêmes secteurs : c'est ce qui prend tout ce temps.",
        },
        {
          enonce: "Depuis la dernière mise à jour, l'imprimante n'imprime plus rien.",
          bonne: "log",
          pourquoi:
            "Une mise à jour a remplacé ou cassé le pilote. Le matériel n'a pas changé entre-temps, et c'est cette chronologie qui tranche.",
        },
        {
          enonce: "Des traits de couleur traversent l'écran, et ils y sont aussi dans le BIOS.",
          bonne: "mat",
          pourquoi:
            "Visibles dans le BIOS, donc avant tout système : aucun logiciel n'est en cause. C'est la dalle, la nappe ou la carte graphique.",
        },
      ]}
    />
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 3 — Sécuriser une salle de quinze postes                   */
/* ------------------------------------------------------------------ */

const MESURES = [
  {
    id: "goul",
    label: "Goulottes pour les câbles",
    cout: 40,
    protege: "trebuchement",
    note: "Un câble dans le passage finit par être arraché, et avec lui le connecteur de la carte mère.",
  },
  {
    id: "ond",
    label: "Onduleur pour le serveur",
    cout: 180,
    protege: "coupure",
    note: "Il laisse le temps d'éteindre proprement, et il filtre la tension en permanence.",
  },
  {
    id: "para",
    label: "Parasurtenseurs sur les postes",
    cout: 120,
    protege: "foudre",
    note: "En saison des pluies, c'est la mesure qui sauve le plus de cartes mères par franc dépensé.",
  },
  {
    id: "sauv",
    label: "Sauvegarde hebdomadaire sur disque externe",
    cout: 90,
    protege: "perte",
    note: "La seule mesure qui protège les données elles-mêmes. Aucune autre ne les remplace.",
  },
  {
    id: "serr",
    label: "Serrure et registre d'accès",
    cout: 50,
    protege: "vol",
    note: "Le vol de barrettes de mémoire est le sinistre le plus courant dans une salle ouverte.",
  },
  {
    id: "nett",
    label: "Nettoyage trimestriel et filtres aux fenêtres",
    cout: 60,
    protege: "poussiere",
    note: "La poussière est la première cause de panne matérielle sous nos climats.",
  },
  {
    id: "anti",
    label: "Antivirus à jour sur les quinze postes",
    cout: 100,
    protege: "virus",
    note: "Les clés USB passent de main en main : sans antivirus, un poste infecté contamine la salle.",
  },
] as const;

const INCIDENTS = [
  {
    cle: "coupure",
    texte: "Trois coupures de courant pendant les examens",
    degat: "Un poste a perdu son système, deux heures de saisie envolées.",
  },
  { cle: "foudre", texte: "Un orage violent en avril", degat: "Deux cartes mères grillées." },
  {
    cle: "poussiere",
    texte: "La saison sèche et le vent de poussière",
    degat: "Quatre postes s'éteignent après une heure de cours.",
  },
  {
    cle: "trebuchement",
    texte: "Un élève se prend les pieds dans un câble",
    degat: "Un connecteur réseau arraché et un écran tombé.",
  },
  {
    cle: "virus",
    texte: "Une clé USB infectée du cybercafé du coin",
    degat: "Les devoirs de trois classes chiffrés et illisibles.",
  },
  {
    cle: "vol",
    texte: "La salle reste ouverte un week-end",
    degat: "Deux barrettes de mémoire et une souris disparues.",
  },
  {
    cle: "perte",
    texte: "Le disque du poste du professeur lâche",
    degat: "Les notes du trimestre perdues sans retour.",
  },
] as const;

const BUDGET = 400;

export function RisquesPoste() {
  const [prises, setPrises] = useState<string[]>([]);
  const [annee, setAnnee] = useState(false);

  const total = MESURES.filter((m) => prises.includes(m.id)).reduce((s, m) => s + m.cout, 0);
  const reste = BUDGET - total;
  const couverts = MESURES.filter((m) => prises.includes(m.id)).map((m) => m.protege);

  const basculer = (id: string) => {
    const m = MESURES.find((x) => x.id === id);
    if (!m) return;
    if (prises.includes(id)) {
      setPrises(prises.filter((x) => x !== id));
    } else if (total + m.cout <= BUDGET) {
      setPrises([...prises, id]);
    }
  };

  const tenus = INCIDENTS.filter((x) => couverts.includes(x.cle)).length;

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-sm font-medium">
          La salle de quinze postes, telle qu&apos;on te la confie
        </p>
        <p className="mt-1 text-[11px] text-muted-foreground">
          Les câbles traversent le passage. La multiprise porte sept appareils. La fenêtre donne sur
          la cour, poussière comprise. Aucune sauvegarde n&apos;a jamais été faite. La porte
          n&apos;a pas de serrure.
        </p>
      </div>

      <Panel>
        <Stat label="Budget" value={`${BUDGET} × 1000 F`} />
        <Stat
          label="Reste"
          value={`${reste} × 1000 F`}
          color={reste < 60 ? PALETTE.red : PALETTE.green}
        />
      </Panel>

      <div className="grid gap-1.5 sm:grid-cols-2">
        {MESURES.map((m) => {
          const actif = prises.includes(m.id);
          const abordable = actif || total + m.cout <= BUDGET;
          return (
            <button
              key={m.id}
              type="button"
              onClick={() => basculer(m.id)}
              disabled={!abordable}
              className={
                actif
                  ? "rounded-lg border border-emerald-500/50 bg-emerald-500/10 px-2.5 py-2 text-left text-xs"
                  : abordable
                    ? "rounded-lg border border-border bg-background px-2.5 py-2 text-left text-xs hover:bg-secondary/60"
                    : "rounded-lg border border-border bg-background px-2.5 py-2 text-left text-xs opacity-40"
              }
            >
              <span className="font-semibold text-foreground">{m.label}</span>
              <span className="block font-mono text-[10px] text-muted-foreground">
                {m.cout} × 1000 F
              </span>
            </button>
          );
        })}
      </div>

      <button
        type="button"
        onClick={() => setAnnee((v) => !v)}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        {annee ? "Revenir au choix des mesures" : "Faire passer une année scolaire"}
      </button>

      {annee ? (
        <div className="space-y-1.5">
          <div className="space-y-1 rounded-lg border border-border bg-background p-3">
            {INCIDENTS.map((x) => {
              const tenu = couverts.includes(x.cle);
              return (
                <p key={x.cle} className="text-[11px]">
                  <span
                    className="font-semibold"
                    style={{ color: tenu ? PALETTE.green : PALETTE.red }}
                  >
                    {tenu ? "Tenu" : "Sinistre"} —{" "}
                  </span>
                  <span className="font-medium text-foreground">{x.texte}. </span>
                  <span className="text-muted-foreground">
                    {tenu ? (MESURES.find((m) => m.protege === x.cle)?.note ?? "") : x.degat}
                  </span>
                </p>
              );
            })}
          </div>
          {tenus === INCIDENTS.length ? (
            <Verdict tone="ok">
              Les sept incidents absorbés, et dans le budget. Regarde ce que tu as choisi : la
              sauvegarde est la seule mesure qui protège les données elles-mêmes, et elle coûte
              moins qu&apos;un onduleur.
            </Verdict>
          ) : (
            <Verdict tone="warn">
              {tenus} incidents sur {INCIDENTS.length} absorbés. Le budget ne permet pas tout : la
              question d&apos;examen « citer trois risques et la mesure correspondante » attend
              qu&apos;on priorise. Sous nos climats, l&apos;ordre raisonnable est : sauvegarde,
              protection électrique, poussière.
            </Verdict>
          )}
        </div>
      ) : (
        <Verdict tone="warn">
          Choisis tes mesures dans la limite du budget, puis fais passer une année. Tu ne pourras
          pas tout prendre : c&apos;est là que le raisonnement commence.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 4 — Le bloc d'alimentation                                 */
/* ------------------------------------------------------------------ */

const LIGNES_ALIM = [
  {
    v: "12 V",
    couleur: "jaune",
    pour: "Processeur, carte graphique, moteurs des disques et ventilateurs",
  },
  { v: "5 V", couleur: "rouge", pour: "Cartes électroniques des disques, ports USB" },
  { v: "3,3 V", couleur: "orange", pour: "Barrettes de mémoire, chipset, connecteurs d'extension" },
] as const;

export function BlocAlimentation() {
  const [puissance, setPuissance] = useState(450);
  const [gpu, setGpu] = useState(false);
  const [disques, setDisques] = useState(1);

  // Consommations usuelles, en watts.
  const besoin = 120 + (gpu ? 220 : 0) + disques * 12 + 40;
  const marge = puissance - besoin;

  return (
    <div className="space-y-4">
      <div className="rounded-lg border border-border bg-secondary/30 p-3">
        <p className="text-xs font-medium">
          220 V alternatif à la prise → trois tensions continues en sortie
        </p>
        <div className="mt-2 space-y-1">
          {LIGNES_ALIM.map((l) => (
            <p key={l.v} className="text-[11px]">
              <span className="font-mono font-semibold text-foreground">{l.v}</span>
              <span className="text-muted-foreground">
                {" "}
                (fil {l.couleur}) → {l.pour}
              </span>
            </p>
          ))}
        </div>
        <p className="mt-2 text-[11px] text-muted-foreground">
          C&apos;est la ligne 12 V qui porte l&apos;essentiel de la charge : c&apos;est elle
          qu&apos;un bloc trop juste n&apos;arrive plus à tenir.
        </p>
      </div>

      <div className="space-y-2">
        <Ctrl
          label="Puissance du bloc"
          value={puissance}
          min={200}
          max={850}
          step={50}
          onChange={setPuissance}
          display={`${puissance} W`}
          color={marge < 0 ? PALETTE.red : PALETTE.blue}
        />
        <Ctrl
          label="Disques installés"
          value={disques}
          min={1}
          max={6}
          step={1}
          onChange={setDisques}
          display={`${disques}`}
        />
        <Choice<"non" | "oui">
          label="Carte graphique dédiée"
          value={gpu ? "oui" : "non"}
          options={[
            { value: "non", label: "Graphique intégré" },
            { value: "oui", label: "Carte dédiée" },
          ]}
          onChange={(v) => setGpu(v === "oui")}
        />
      </div>

      <Panel>
        <Stat label="Demande de la machine" value={`${besoin} W`} />
        <Stat
          label="Marge disponible"
          value={`${marge} W`}
          color={marge < 0 ? PALETTE.red : marge < 80 ? PALETTE.orange : PALETTE.green}
        />
      </Panel>

      {marge < 0 ? (
        <Verdict tone="bad">
          La machine demande {besoin} W et le bloc n&apos;en fournit que {puissance}. Résultat : des
          redémarrages au hasard, toujours sous charge et jamais au repos. C&apos;est le symptôme
          qu&apos;on prend presque toujours pour un problème de système — et c&apos;est le bloc.
        </Verdict>
      ) : marge < 80 ? (
        <Verdict tone="warn">
          {marge} W de marge seulement. Ça tient, mais de justesse : au premier disque ajouté, ou
          quand le bloc vieillira, la machine se mettra à redémarrer. On prévoit toujours 20 à 30 %
          de marge.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          {marge} W de marge sur une demande de {besoin} W : c&apos;est une configuration saine, et
          il reste de la place pour un disque ou une carte de plus.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 4 — Les neuf combinaisons                                  */
/* ------------------------------------------------------------------ */

const EQUIPEMENTS = [
  { value: "rien", label: "Rien" },
  { value: "reg", label: "Régulateur" },
  { value: "para", label: "Parasurtenseur" },
  { value: "ond", label: "Onduleur" },
] as const;

const EPREUVES = [
  { value: "baisse", label: "Baisse de tension (160 V)" },
  { value: "foudre", label: "Coup de foudre (3000 V)" },
  { value: "coupure", label: "Coupure de deux minutes" },
] as const;

type Eq = "rien" | "reg" | "para" | "ond";
type Ep = "baisse" | "foudre" | "coupure";

const RESULTATS: Record<
  Eq,
  Record<Ep, { tension: string; survit: number; grille: number; mot: string }>
> = {
  rien: {
    baisse: {
      tension: "160 V",
      survit: 0,
      grille: 0,
      mot: "Les quinze postes s'éteignent. Rien ne grille, mais tout le travail non enregistré est perdu, et un système coupé en pleine écriture peut ne plus redémarrer.",
    },
    foudre: {
      tension: "3000 V",
      survit: 3,
      grille: 12,
      mot: "Douze cartes mères grillées. C'est le scénario d'un orage d'avril sur une salle non protégée, et il arrive vraiment.",
    },
    coupure: {
      tension: "0 V",
      survit: 0,
      grille: 0,
      mot: "Extinction immédiate des quinze postes. Deux heures de saisie des notes envolées.",
    },
  },
  reg: {
    baisse: {
      tension: "220 V",
      survit: 15,
      grille: 0,
      mot: "Le régulateur a fait son travail : il relève la tension et les quinze postes continuent de travailler sans s'en apercevoir. C'est sa spécialité.",
    },
    foudre: {
      tension: "3000 V",
      survit: 4,
      grille: 11,
      mot: "Le régulateur ne protège pas des surtensions brèves : il régule, il n'écrête pas. Onze postes perdus.",
    },
    coupure: {
      tension: "0 V",
      survit: 0,
      grille: 0,
      mot: "Il n'a aucune réserve d'énergie. Plus de courant, plus rien à réguler : tout s'éteint.",
    },
  },
  para: {
    baisse: {
      tension: "160 V",
      survit: 2,
      grille: 0,
      mot: "Le parasurtenseur ne relève pas la tension : à 160 V, les blocs d'alimentation décrochent. Rien ne grille, mais presque tout s'éteint.",
    },
    foudre: {
      tension: "220 V écrêté",
      survit: 15,
      grille: 0,
      mot: "Il absorbe la surtension et la dérive vers la terre. Les quinze postes passent l'orage : c'est exactement ce pour quoi il est fait.",
    },
    coupure: {
      tension: "0 V",
      survit: 0,
      grille: 0,
      mot: "Aucune réserve non plus. Tout s'éteint.",
    },
  },
  ond: {
    baisse: {
      tension: "220 V",
      survit: 15,
      grille: 0,
      mot: "L'onduleur régule en permanence : les postes ne voient pas la baisse.",
    },
    foudre: {
      tension: "220 V filtré",
      survit: 15,
      grille: 0,
      mot: "Il filtre et écrête comme un parasurtenseur. Les quinze postes tiennent.",
    },
    coupure: {
      tension: "220 V sur batterie",
      survit: 15,
      grille: 0,
      mot: "Il bascule sur sa batterie en une fraction de seconde. Tu as le temps d'enregistrer et d'éteindre proprement — ce qui est son vrai rôle, car l'autonomie se compte en minutes, pas en heures.",
    },
  },
};

export function EquipementsProtection() {
  const [eq, setEq] = useState<Eq>("rien");
  const [ep, setEp] = useState<Ep>("baisse");
  const [vues, setVues] = useState<string[]>([]);

  const r = RESULTATS[eq][ep];
  const cle = `${eq}-${ep}`;

  const envoyer = () => setVues((v) => (v.includes(cle) ? v : [...v, cle]));

  return (
    <div className="space-y-3">
      <Choice<Eq>
        label="Équipement installé dans la salle"
        value={eq}
        options={EQUIPEMENTS.map((x) => ({ value: x.value, label: x.label }))}
        onChange={setEq}
      />
      <Choice<Ep>
        label="Épreuve envoyée sur la ligne"
        value={ep}
        options={EPREUVES.map((x) => ({ value: x.value, label: x.label }))}
        onChange={setEp}
      />

      <button
        type="button"
        onClick={envoyer}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        Envoyer l&apos;épreuve
      </button>

      {vues.includes(cle) ? (
        <>
          <Panel>
            <Stat label="Tension reçue par les postes" value={r.tension} color={PALETTE.blue} />
            <Stat
              label="Postes encore debout"
              value={`${r.survit} / 15`}
              color={
                r.survit === 15 ? PALETTE.green : r.survit === 0 ? PALETTE.red : PALETTE.orange
              }
            />
          </Panel>
          <div className="flex flex-wrap gap-1">
            {Array.from({ length: 15 }, (_, k) => {
              const etat = k < r.grille ? "grille" : k < r.grille + r.survit ? "ok" : "eteint";
              return (
                <div
                  key={k}
                  title={etat === "grille" ? "grillé" : etat === "ok" ? "fonctionne" : "éteint"}
                  className={
                    etat === "grille"
                      ? "h-7 w-7 rounded border-2 border-rose-500 bg-rose-500/30"
                      : etat === "ok"
                        ? "h-7 w-7 rounded border-2 border-emerald-500 bg-emerald-500/30"
                        : "h-7 w-7 rounded border border-slate-400 bg-secondary"
                  }
                />
              );
            })}
          </div>
          <p className="text-[10px] text-muted-foreground">
            Vert : le poste fonctionne. Gris : éteint, rien de cassé. Rouge : carte mère grillée.
          </p>
          <Verdict tone={r.survit === 15 ? "ok" : r.grille > 0 ? "bad" : "warn"}>{r.mot}</Verdict>
        </>
      ) : (
        <Verdict tone="warn">
          Appuie sur « Envoyer l&apos;épreuve ». Il y a douze combinaisons : essaie-les toutes, et
          cherche le seul appareil qui passe les trois épreuves.
        </Verdict>
      )}

      <Panel>
        <Stat label="Combinaisons essayées" value={`${vues.length} / 12`} />
        <Stat
          label="Verdict"
          value={vues.length === 12 ? "l'onduleur seul passe tout" : "à découvrir"}
          color={vues.length === 12 ? PALETTE.green : PALETTE.ink}
        />
      </Panel>

      {vues.length === 12 ? (
        <Verdict tone="ok">
          Le tableau complet, et c&apos;est la réponse à la question d&apos;examen : le régulateur
          corrige la tension, le parasurtenseur écrête la surtension, et l&apos;onduleur fait les
          deux <strong>et</strong> fournit du courant pendant la coupure. C&apos;est pour cela
          qu&apos;il coûte trois fois plus cher.
        </Verdict>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 4 — Dimensionner l'onduleur                                */
/* ------------------------------------------------------------------ */

export function DimensionnerOnduleur() {
  const [postes, setPostes] = useState(3);
  const [ecrans, setEcrans] = useState(3);
  const [laser, setLaser] = useState(false);
  const [imprime, setImprime] = useState(false);

  // Consommations usuelles en watts, puis conversion en VA avec un facteur de 0,6.
  const watts = postes * 150 + ecrans * 30 + (laser ? 500 : 0);
  const va = Math.round(watts / 0.6);
  const vaMarge = Math.round(va * 1.3);
  const choisi = [600, 850, 1200, 1500, 2000, 3000].find((x) => x >= vaMarge) ?? 3000;

  // L'autonomie chute vite quand la charge approche la capacité.
  const charge = clamp(watts / (choisi * 0.6), 0.05, 1);
  const autonomie = Math.max(1, Math.round(22 / (charge * 3.2)));

  const pointeLaser = laser && imprime;
  const demandePointe = postes * 150 + ecrans * 30 + (pointeLaser ? 1300 : 0);
  const disjoncte = pointeLaser && demandePointe > choisi * 0.6;

  return (
    <div className="space-y-3">
      <Ctrl
        label="Postes à protéger"
        value={postes}
        min={1}
        max={10}
        step={1}
        onChange={setPostes}
        display={`${postes}`}
      />
      <Ctrl
        label="Écrans"
        value={ecrans}
        min={1}
        max={10}
        step={1}
        onChange={setEcrans}
        display={`${ecrans}`}
      />
      <Choice<"non" | "oui">
        label="Imprimante laser branchée sur l'onduleur"
        value={laser ? "oui" : "non"}
        options={[
          { value: "non", label: "Non" },
          { value: "oui", label: "Oui" },
        ]}
        onChange={(v) => {
          setLaser(v === "oui");
          setImprime(false);
        }}
      />

      <Panel>
        <Stat label="Consommation" value={`${watts} W`} />
        <Stat label="Soit en VA" value={`${va} VA`} color={PALETTE.blue} />
      </Panel>
      <Panel>
        <Stat label="Avec 30 % de marge" value={`${vaMarge} VA`} />
        <Stat label="Onduleur à prendre" value={`${choisi} VA`} color={PALETTE.green} />
      </Panel>
      <p className="text-[11px] text-muted-foreground">
        Le calcul en trois temps : on additionne les watts, on divise par 0,6 pour obtenir des{" "}
        <strong>VA</strong> — c&apos;est dans cette unité que les onduleurs sont vendus — puis on
        ajoute 30 % de marge et on prend le modèle immédiatement supérieur.
      </p>

      <Panel>
        <Stat
          label="Autonomie estimée"
          value={`${autonomie} min`}
          color={autonomie < 5 ? PALETTE.orange : PALETTE.green}
        />
        <Stat label="Charge de l'onduleur" value={`${Math.round(charge * 100)} %`} />
      </Panel>

      {laser ? (
        <>
          <button
            type="button"
            onClick={() => setImprime((v) => !v)}
            className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            {imprime ? "Arrêter l'impression" : "Lancer une impression"}
          </button>
          {imprime ? (
            disjoncte ? (
              <Verdict tone="bad">
                Le préchauffage du four appelle près de 1300 W d&apos;un coup : la demande monte à{" "}
                {demandePointe} W, l&apos;onduleur se met en surcharge et coupe tout. Les {postes}{" "}
                postes s&apos;éteignent d&apos;un seul coup, et c&apos;est l&apos;onduleur lui-même
                qui a provoqué la panne.{" "}
                <strong>Une imprimante laser ne se branche jamais sur un onduleur</strong> : on la
                met sur une prise ordinaire, éventuellement avec un parasurtenseur.
              </Verdict>
            ) : (
              <Verdict tone="warn">
                L&apos;onduleur tient l&apos;appel de courant cette fois, parce qu&apos;il est
                largement dimensionné. Mais tu paies un onduleur de {choisi} VA pour protéger une
                imprimante, qui n&apos;a aucun besoin d&apos;être protégée : une impression
                interrompue se relance, un fichier perdu non.
              </Verdict>
            )
          ) : (
            <Verdict tone="warn">
              L&apos;imprimante est branchée. Lance une impression pour voir ce que le préchauffage
              fait à l&apos;onduleur.
            </Verdict>
          )}
        </>
      ) : (
        <Verdict tone="ok">
          {postes} postes et {ecrans} écrans sur un onduleur de {choisi} VA, avec {autonomie}{" "}
          minutes d&apos;autonomie. C&apos;est largement assez : l&apos;onduleur sert à enregistrer
          et à éteindre proprement, pas à continuer le cours.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 4 — Ce qu'un onduleur protège, et ce qu'il ne protège pas  */
/* ------------------------------------------------------------------ */

export function RolesOnduleur() {
  return (
    <JeuCases
      titre="Coche les trois fonctions qu'assure un onduleur, et seulement celles-là."
      attendu={3}
      aide="Pense à ce qu'il contient : des circuits de régulation, un dispositif d'écrêtage, et une batterie."
      cases={[
        {
          id: "c1",
          label: "Fournir du courant pendant une coupure",
          bonne: true,
          pourquoi:
            "Sa batterie prend le relais en une fraction de seconde. C'est sa fonction propre.",
        },
        {
          id: "c2",
          label: "Maintenir la tension quand le réseau baisse",
          bonne: true,
          pourquoi: "Il régule en permanence, comme un régulateur.",
        },
        {
          id: "c3",
          label: "Écrêter les surtensions",
          bonne: true,
          pourquoi: "Il filtre et écrête, comme un parasurtenseur.",
        },
        {
          id: "c4",
          label: "Sauvegarder automatiquement les fichiers",
          bonne: false,
          pourquoi:
            "Il ne touche pas aux données. Il te donne le temps de les enregistrer, c'est tout — et c'est pour cela que la sauvegarde reste une mesure à part.",
        },
        {
          id: "c5",
          label: "Protéger contre les virus",
          bonne: false,
          pourquoi: "C'est un appareil électrique. Aucun rapport avec les logiciels malveillants.",
        },
        {
          id: "c6",
          label: "Faire tourner la salle pendant toute une coupure",
          bonne: false,
          pourquoi:
            "Son autonomie se compte en minutes. Pour durer des heures, il faut un groupe électrogène, qui est un tout autre équipement.",
        },
        {
          id: "c7",
          label: "Refroidir les machines",
          bonne: false,
          pourquoi:
            "Au contraire : un onduleur chauffe, et il a besoin d'être lui-même ventilé et dégagé.",
        },
      ]}
    />
  );
}
