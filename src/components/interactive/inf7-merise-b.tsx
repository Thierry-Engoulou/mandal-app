import { useState } from "react";
import { Choice, PALETTE, Panel, Stat, Verdict } from "./controls";

/** Informatique Terminale C et D — chapitre 14 : du MCD au MLD. */

/* ------------------------------------------------------------------ */
/* Chapitre 14 — Clé primaire, clé étrangère                           */
/* ------------------------------------------------------------------ */

const T_CLASSE = [
  { NumClasse: "1", Libelle: "Terminale C", Effectif: "42" },
  { NumClasse: "2", Libelle: "Terminale D", Effectif: "58" },
  { NumClasse: "3", Libelle: "Première C", Effectif: "47" },
];

const T_ELEVE = [
  { Matricule: "E101", Nom: "MBIDA", Prenom: "Jean", NumClasse: "1" },
  { Matricule: "E102", Nom: "NGONO", Prenom: "Alice", NumClasse: "2" },
  { Matricule: "E103", Nom: "MBIDA", Prenom: "Jean", NumClasse: "2" },
];

const INSERTIONS = [
  {
    id: "i1",
    sql: "INSERT INTO ELEVE VALUES ('E102', 'FOUDA', 'Paul', 1);",
    ok: false,
    contrainte: "Violation de contrainte PRIMARY KEY",
    mot: "Le matricule E102 existe déjà. Une clé primaire est unique : la base refuse avant même d'écrire la ligne.",
  },
  {
    id: "i2",
    sql: "INSERT INTO ELEVE VALUES ('E104', 'ATEBA', 'Marie', 7);",
    ok: false,
    contrainte: "Violation de contrainte FOREIGN KEY",
    mot: "La classe numéro 7 n'existe pas dans CLASSE. Une clé étrangère ne peut désigner qu'une ligne qui existe réellement : c'est l'intégrité référentielle.",
  },
  {
    id: "i3",
    sql: "INSERT INTO ELEVE VALUES (NULL, 'BIYA', 'Serge', 2);",
    ok: false,
    contrainte: "Violation de contrainte NOT NULL sur la clé primaire",
    mot: "Une clé primaire ne peut jamais être vide. Si elle l'était, elle n'identifierait plus rien.",
  },
  {
    id: "i4",
    sql: "INSERT INTO ELEVE VALUES ('E104', 'ATEBA', 'Marie', 3);",
    ok: true,
    contrainte: "1 ligne insérée",
    mot: "Matricule inédit, classe existante : la ligne passe. Les deux contraintes sont satisfaites.",
  },
  {
    id: "i5",
    sql: "DELETE FROM CLASSE WHERE NumClasse = 2;",
    ok: false,
    contrainte: "Violation de contrainte FOREIGN KEY",
    mot: "Deux élèves référencent la classe 2. La supprimer laisserait ces élèves pointer vers le vide : la base refuse. Il faut d'abord déplacer ou supprimer les élèves concernés.",
  },
] as const;

export function ClesTables() {
  const [kpClasse, setKpClasse] = useState<string | null>(null);
  const [kpEleve, setKpEleve] = useState<string | null>(null);
  const [lien, setLien] = useState<string | null>(null);
  const [tentee, setTentee] = useState<string | null>(null);

  const okClasse = kpClasse === "NumClasse";
  const okEleve = kpEleve === "Matricule";
  const okLien = lien === "NumClasse";
  const tout = okClasse && okEleve && okLien;

  const ins = INSERTIONS.find((x) => x.id === tentee);

  const Table = ({
    nom,
    lignes,
    cols,
    kp,
    ke,
  }: {
    nom: string;
    lignes: ReadonlyArray<Record<string, string>>;
    cols: ReadonlyArray<string>;
    kp: string | null;
    ke: string | null;
  }) => (
    <div className="space-y-1">
      <p className="text-xs font-semibold">{nom}</p>
      <div className="overflow-x-auto">
        <table className="w-full border-collapse text-[11px]">
          <thead>
            <tr>
              {cols.map((c) => (
                <th
                  key={c}
                  className={
                    c === kp
                      ? "border border-border bg-blue-500/20 px-2 py-1 font-mono font-bold underline"
                      : c === ke
                        ? "border border-border bg-amber-500/20 px-2 py-1 font-mono font-bold italic"
                        : "border border-border bg-secondary/40 px-2 py-1 font-mono"
                  }
                >
                  {c}
                  {c === kp ? " 🔑" : c === ke ? " ↗" : ""}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {lignes.map((l) => (
              <tr key={Object.values(l).join("-")}>
                {cols.map((c) => (
                  <td key={c} className="border border-border px-2 py-1 font-mono">
                    {l[c] ?? ""}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );

  return (
    <div className="space-y-3">
      <Table
        nom="CLASSE"
        lignes={T_CLASSE}
        cols={["NumClasse", "Libelle", "Effectif"]}
        kp={okClasse ? kpClasse : null}
        ke={null}
      />
      <Choice<string>
        label="Clé primaire de CLASSE"
        value={kpClasse ?? ""}
        options={["NumClasse", "Libelle", "Effectif"].map((c) => ({ value: c, label: c }))}
        onChange={setKpClasse}
      />
      {kpClasse !== null && !okClasse ? (
        <p className="text-[11px] text-rose-600">
          Non.{" "}
          {kpClasse === "Libelle"
            ? "Le libellé pourrait se répéter d'une année sur l'autre, et c'est une chaîne longue : mauvais candidat."
            : "L'effectif change tous les jours et se répète d'une classe à l'autre."}{" "}
          La clé primaire doit être <strong>unique, non vide et stable</strong>.
        </p>
      ) : null}

      <Table
        nom="ELEVE"
        lignes={T_ELEVE}
        cols={["Matricule", "Nom", "Prenom", "NumClasse"]}
        kp={okEleve ? kpEleve : null}
        ke={okLien ? lien : null}
      />
      <Choice<string>
        label="Clé primaire de ELEVE"
        value={kpEleve ?? ""}
        options={["Matricule", "Nom", "Prenom", "NumClasse"].map((c) => ({ value: c, label: c }))}
        onChange={setKpEleve}
      />
      {kpEleve !== null && !okEleve ? (
        <p className="text-[11px] text-rose-600">
          Non : regarde les lignes E101 et E103.{" "}
          <strong>Deux élèves portent le même nom et le même prénom.</strong> Seul le matricule les
          distingue.
        </p>
      ) : null}

      <Choice<string>
        label="La colonne qui fait le lien entre les deux tables"
        value={lien ?? ""}
        options={["Matricule", "Nom", "NumClasse", "Libelle"].map((c) => ({ value: c, label: c }))}
        onChange={setLien}
      />
      {lien !== null && !okLien ? (
        <p className="text-[11px] text-rose-600">
          Non. Le lien est la colonne de ELEVE qui reprend la <strong>clé primaire</strong> de
          CLASSE : <span className="font-mono">NumClasse</span>. C&apos;est une{" "}
          <strong>clé étrangère</strong>.
        </p>
      ) : null}

      {tout ? (
        <Verdict tone="ok">
          Les trois désignations sont justes. <span className="font-mono">Matricule</span> est clé
          primaire de ELEVE, <span className="font-mono">NumClasse</span> est clé primaire de CLASSE{" "}
          <strong>et</strong> clé étrangère dans ELEVE. On la note souvent{" "}
          <span className="font-mono">#NumClasse</span> dans un MLD, et le dièse signale exactement
          cela.
        </Verdict>
      ) : null}

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">
          La base met ses contraintes à l&apos;épreuve
        </p>
        <div className="space-y-1">
          {INSERTIONS.map((x) => (
            <button
              key={x.id}
              type="button"
              onClick={() => setTentee(x.id)}
              className={
                tentee === x.id
                  ? "block w-full rounded-lg border-2 border-primary bg-primary/10 px-2.5 py-1.5 text-left font-mono text-[10px]"
                  : "block w-full rounded-lg border border-border bg-background px-2.5 py-1.5 text-left font-mono text-[10px] text-muted-foreground hover:bg-secondary/60"
              }
            >
              {x.sql}
            </button>
          ))}
        </div>

        {ins ? (
          <>
            <div className="rounded-lg bg-slate-900 p-3">
              <p className="font-mono text-[11px] text-slate-300">&gt; {ins.sql}</p>
              <p
                className="mt-1 font-mono text-[11px]"
                style={{ color: ins.ok ? "#4ade80" : "#fb7185" }}
              >
                {ins.ok ? "✓ " : "✗ ERREUR 1062/1452 — "}
                {ins.contrainte}
              </p>
            </div>
            <Verdict tone={ins.ok ? "ok" : "bad"}>{ins.mot}</Verdict>
          </>
        ) : (
          <Verdict tone="warn">
            Lance ces cinq requêtes. Quatre seront refusées, et chaque refus nomme la contrainte
            violée : c&apos;est ainsi qu&apos;une base protège ses données toute seule, sans
            qu&apos;un programme ait à vérifier quoi que ce soit.
          </Verdict>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 14 — Les quatre règles de passage                          */
/* ------------------------------------------------------------------ */

type Card = "(0,1)" | "(1,1)" | "(0,n)" | "(1,n)";

const REGLES = [
  {
    id: "r1",
    nom: "Règle 1 — toute entité devient une table",
    quand: "Toujours",
    quoi: "Chaque entité du MCD devient une table ; son identifiant devient la clé primaire, ses propriétés deviennent les colonnes.",
  },
  {
    id: "r2",
    nom: "Règle 2 — un côté (1,1) ou (0,1) : la clé migre",
    quand: "Au moins un maximum à 1",
    quoi: "L'association disparaît. La clé primaire de l'entité du côté « plusieurs » devient clé étrangère dans la table du côté « un ». Pas de table nouvelle.",
  },
  {
    id: "r3",
    nom: "Règle 3 — les deux côtés à n : une table d'association",
    quand: "Les deux maximums à n",
    quoi: "L'association devient une table à part. Sa clé primaire est composée des deux clés étrangères, et elle reçoit les propriétés portées par l'association.",
  },
  {
    id: "r4",
    nom: "Règle 4 — les propriétés de l'association suivent",
    quand: "L'association porte des propriétés",
    quoi: "Elles vont dans la table d'association si elle existe, sinon dans la table qui reçoit la clé étrangère.",
  },
] as const;

export function PassageMcdMld() {
  const [c1, setC1] = useState<Card>("(1,1)");
  const [c2, setC2] = useState<Card>("(1,n)");
  const [prop, setProp] = useState(false);
  const [regle, setRegle] = useState<string | null>(null);
  const [cote, setCote] = useState<string | null>(null);
  const [mauvaisCote, setMauvaisCote] = useState(false);

  const max1 = c1.includes("n") ? "n" : "1";
  const max2 = c2.includes("n") ? "n" : "1";
  const plusieursAPlusieurs = max1 === "n" && max2 === "n";

  const regleAttendue = plusieursAPlusieurs ? "r3" : "r2";
  // La clé migre dans la table du côté dont le maximum vaut 1.
  const coteAttendu = plusieursAPlusieurs ? "table" : max1 === "1" ? "ELEVE" : "CLASSE";

  const regleOk = regle === regleAttendue;
  const coteOk = cote === coteAttendu;

  const mld = plusieursAPlusieurs
    ? [
        "ELEVE (Matricule, Nom, Prenom)",
        "CLASSE (NumClasse, Libelle)",
        `INSCRIRE (#Matricule, #NumClasse${prop ? ", DateInscription" : ""})`,
      ]
    : max1 === "1"
      ? [
          `ELEVE (Matricule, Nom, Prenom, #NumClasse${prop ? ", DateInscription" : ""})`,
          "CLASSE (NumClasse, Libelle)",
        ]
      : [
          "ELEVE (Matricule, Nom, Prenom)",
          `CLASSE (NumClasse, Libelle, #Matricule${prop ? ", DateInscription" : ""})`,
        ];

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap items-center justify-center gap-2 rounded-lg border border-border bg-background p-3">
        <div className="rounded-lg border-2 border-blue-500 bg-blue-500/10 px-3 py-2">
          <p className="text-xs font-bold">ELEVE</p>
        </div>
        <span className="font-mono text-xs font-bold text-primary">{c1}</span>
        <span className="text-muted-foreground">—</span>
        <div className="rounded-lg border-2 border-amber-500 bg-amber-500/10 px-3 py-2 text-center">
          <p className="text-[11px] font-bold">INSCRIRE</p>
          {prop ? (
            <p className="font-mono text-[9px] text-muted-foreground">DateInscription</p>
          ) : null}
        </div>
        <span className="text-muted-foreground">—</span>
        <span className="font-mono text-xs font-bold text-primary">{c2}</span>
        <div className="rounded-lg border-2 border-blue-500 bg-blue-500/10 px-3 py-2">
          <p className="text-xs font-bold">CLASSE</p>
        </div>
      </div>

      <div className="grid gap-2 sm:grid-cols-2">
        <Choice<Card>
          label="Côté ELEVE"
          value={c1}
          options={(["(0,1)", "(1,1)", "(0,n)", "(1,n)"] as Card[]).map((x) => ({
            value: x,
            label: x,
          }))}
          onChange={(v) => {
            setC1(v);
            setRegle(null);
            setCote(null);
          }}
        />
        <Choice<Card>
          label="Côté CLASSE"
          value={c2}
          options={(["(0,1)", "(1,1)", "(0,n)", "(1,n)"] as Card[]).map((x) => ({
            value: x,
            label: x,
          }))}
          onChange={(v) => {
            setC2(v);
            setRegle(null);
            setCote(null);
          }}
        />
      </div>
      <Choice<"non" | "oui">
        label="L'association porte-t-elle une propriété ?"
        value={prop ? "oui" : "non"}
        options={[
          { value: "non", label: "Non" },
          { value: "oui", label: "DateInscription" },
        ]}
        onChange={(v) => setProp(v === "oui")}
      />

      <Choice<string>
        label="1. Quelle règle s'applique ?"
        value={regle ?? ""}
        options={[
          { value: "r2", label: "Règle 2 — la clé migre" },
          { value: "r3", label: "Règle 3 — table d'association" },
        ]}
        onChange={setRegle}
      />
      {regle !== null ? (
        regleOk ? (
          <p className="text-[11px] text-emerald-600">
            Juste.{" "}
            {plusieursAPlusieurs
              ? "Les deux maximums valent n : aucune clé ne peut migrer, il faut une table à part."
              : `Le côté ${max1 === "1" ? "ELEVE" : "CLASSE"} a un maximum à 1 : la clé peut migrer.`}
          </p>
        ) : (
          <p className="text-[11px] text-rose-600">
            Non. Regarde les <strong>maximums</strong> : {max1} et {max2}.{" "}
            {plusieursAPlusieurs ? "Deux n : règle 3." : "Au moins un 1 : règle 2."} Les minimums, 0
            ou 1, ne décident jamais de la règle — ils décident seulement si la clé étrangère pourra
            être vide.
          </p>
        )
      ) : null}

      <Choice<string>
        label="2. Où la clé doit-elle aller ?"
        value={cote ?? ""}
        options={[
          { value: "ELEVE", label: "Dans ELEVE" },
          { value: "CLASSE", label: "Dans CLASSE" },
          { value: "table", label: "Dans une table d'association" },
        ]}
        onChange={(v) => {
          setCote(v);
          setMauvaisCote(v !== coteAttendu && !plusieursAPlusieurs);
        }}
      />

      <div className="rounded-lg border border-border bg-secondary/20 p-3">
        <p className="mb-1 text-xs font-semibold">Le MLD obtenu</p>
        <pre className="overflow-x-auto font-mono text-[11px] leading-relaxed">
          {mld.join("\n")}
        </pre>
        <p className="mt-1 text-[10px] text-muted-foreground">
          Le dièse marque une clé étrangère. Une clé primaire est soulignée dans un MLD écrit à la
          main.
        </p>
      </div>

      {cote !== null && coteOk ? (
        <Verdict tone="ok">
          {plusieursAPlusieurs
            ? `La table INSCRIRE porte les deux clés étrangères, qui forment ensemble sa clé primaire${prop ? ", et elle reçoit la propriété DateInscription : c'est la règle 4" : ""}. Change une cardinalité en (1,1) et regarde la table disparaître.`
            : `La clé migre dans ${coteAttendu}, c'est-à-dire du côté dont le maximum vaut 1. Passe maintenant les deux côtés à (1,n) : une table d'association apparaîtra.`}
        </Verdict>
      ) : null}

      {mauvaisCote && cote !== null && !coteOk ? (
        <div className="space-y-1.5">
          <Verdict tone="bad">
            La clé est du mauvais côté. Voici ce que cela donnerait concrètement :
          </Verdict>
          <div className="overflow-x-auto rounded-lg border border-rose-500/40 bg-rose-500/5 p-2.5">
            <table className="w-full border-collapse text-[11px]">
              <thead>
                <tr>
                  <th className="border border-border px-2 py-1 font-mono">NumClasse</th>
                  <th className="border border-border px-2 py-1 font-mono">Libelle</th>
                  <th className="border border-border px-2 py-1 font-mono">#Matricule</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td className="border border-border px-2 py-1 font-mono">1</td>
                  <td className="border border-border px-2 py-1">Terminale C</td>
                  <td className="border border-border px-2 py-1 font-mono text-rose-600">
                    E101 … et E105 ? et E112 ?
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <p className="text-[11px] text-muted-foreground">
            Une classe accueille quarante élèves, et une case ne contient qu&apos;une valeur. La clé
            doit migrer <strong>du côté « un »</strong>, jamais du côté « plusieurs » : c&apos;est
            le raisonnement à écrire en copie, et il suffit de se poser cette question-là.
          </p>
        </div>
      ) : null}

      <div className="space-y-1 rounded-lg border border-border bg-background p-3">
        {REGLES.map((r) => (
          <p key={r.id} className="text-[11px] text-muted-foreground">
            <span className="font-semibold text-foreground">{r.nom} </span>({r.quand}) — {r.quoi}
          </p>
        ))}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 14 — Normaliser un MCD                                     */
/* ------------------------------------------------------------------ */

const MCD_DEFECTUEUX = [
  {
    id: "d1",
    titre: "FACTURE avec son montant total",
    mcd: `FACTURE
  NumFacture (id)
  DateFacture
  MontantTotal        ← ?

  FACTURE (1,n) ── CONTENIR ── (0,n) ARTICLE
                     Quantite`,
    defaut: "calcule",
    correction: "Supprimer MontantTotal : il se calcule par SOMME(Quantite × PrixUnitaire).",
    degat:
      "Un article change de prix, ou une ligne est corrigée, et le MontantTotal stocké ne correspond plus à la somme de ses propres lignes. La facture se contredit elle-même, et personne ne sait plus laquelle des deux valeurs croire. C'est le dégât le plus classique, et le plus difficile à réparer après coup.",
  },
  {
    id: "d2",
    titre: "COMMANDE sans identifiant",
    mcd: `COMMANDE
  DateCommande
  Quantite
  (aucun identifiant)

  CLIENT (1,n) ── PASSER ── (1,1) COMMANDE`,
    defaut: "sansid",
    correction: "Ajouter NumCommande comme identifiant.",
    degat:
      "Deux commandes passées le même jour pour la même quantité deviennent indistinguables : impossible d'en annuler une sans annuler l'autre. Et la table n'aura aucune clé primaire, donc aucune protection contre les doublons.",
  },
  {
    id: "d3",
    titre: "Une association qui répète un lien déjà existant",
    mcd: `ELEVE (1,1) ── INSCRIRE ── (1,n) CLASSE
ELEVE (1,1) ── APPARTENIR ── (1,n) CLASSE`,
    defaut: "redondante",
    correction: "Supprimer l'une des deux : elles disent la même chose.",
    degat:
      "La base peut enregistrer qu'un élève est inscrit en Terminale C par la première association et en Terminale D par la seconde. Deux vérités contradictoires sur la même réalité, et aucune contrainte ne les empêche.",
  },
  {
    id: "d4",
    titre: "Une cardinalité impossible",
    mcd: `ELEVE (n,1) ── INSCRIRE ── (1,n) CLASSE`,
    defaut: "cardinalite",
    correction: "Écrire (1,1) : le minimum vient toujours en premier, le maximum ensuite.",
    degat:
      "Ce n'est pas une erreur de conception mais une faute d'écriture, et elle coûte un point sèchement : il n'existe que quatre couples, (0,1), (1,1), (0,n) et (1,n). Ni (n,1) ni (n,n) n'existent.",
  },
  {
    id: "d5",
    titre: "Deux propriétés du même nom",
    mcd: `ELEVE
  Matricule (id)
  Nom

CLASSE
  NumClasse (id)
  Nom          ← ?`,
    defaut: "homonyme",
    correction: "Renommer : NomEleve et LibelleClasse, ou préfixer chaque propriété.",
    degat:
      "Dans une requête qui joint les deux tables, SELECT Nom devient ambigu et le SGBD refuse : « Column 'Nom' in field list is ambiguous ». Il faudra écrire ELEVE.Nom partout, pour toujours.",
  },
  {
    id: "d6",
    titre: "Une propriété non atomique",
    mcd: `CLIENT
  NumClient (id)
  NomComplet
  AdresseComplete     ← ?
  Telephones          ← ?`,
    defaut: "atomique",
    correction:
      "Découper : Nom et Prenom ; Quartier, Rue et Ville ; et une entité TELEPHONE reliée au client, puisqu'il peut en avoir plusieurs.",
    degat:
      "Impossible de chercher tous les clients de Douala, de trier par nom de famille, ou d'appeler le second numéro d'un client. Chaque case doit contenir une seule information : c'est la première forme normale.",
  },
] as const;

const DEFAUTS = [
  { value: "calcule", label: "Attribut calculable" },
  { value: "sansid", label: "Entité sans identifiant" },
  { value: "redondante", label: "Association redondante" },
  { value: "cardinalite", label: "Cardinalité impossible" },
  { value: "homonyme", label: "Deux noms identiques" },
  { value: "atomique", label: "Propriété non atomique" },
] as const;

export function NormaliserMcd() {
  const [k, setK] = useState(0);
  const [rep, setRep] = useState<string | null>(null);
  const [corrige, setCorrige] = useState(false);

  const d = MCD_DEFECTUEUX[k] ?? MCD_DEFECTUEUX[0];
  const juste = rep === d.defaut;
  const trouves = MCD_DEFECTUEUX.length;

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-1.5">
        {MCD_DEFECTUEUX.map((x, i) => (
          <button
            key={x.id}
            type="button"
            onClick={() => {
              setK(i);
              setRep(null);
              setCorrige(false);
            }}
            className={
              i === k
                ? "rounded-lg bg-primary px-2 py-1 text-[11px] font-semibold text-primary-foreground"
                : "rounded-lg border border-border bg-background px-2 py-1 text-[11px] font-medium text-muted-foreground hover:bg-secondary/60"
            }
          >
            MCD {i + 1}
          </button>
        ))}
      </div>

      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-xs font-semibold">{d.titre}</p>
        <pre className="mt-1.5 overflow-x-auto font-mono text-[10px] leading-relaxed text-muted-foreground">
          {d.mcd}
        </pre>
      </div>

      <Choice<string>
        label="Quel est le défaut ?"
        value={rep ?? ""}
        options={DEFAUTS.map((x) => ({ value: x.value, label: x.label }))}
        onChange={setRep}
      />

      {rep === null ? (
        <Verdict tone="warn">
          Passe les six MCD en revue. Les six défauts sont ceux que le correcteur cherche, et aucun
          MCD n&apos;en contient deux.
        </Verdict>
      ) : juste ? (
        <>
          <Verdict tone="ok">
            Défaut repéré. <span className="font-semibold">La correction : </span>
            {d.correction}
          </Verdict>
          <button
            type="button"
            onClick={() => setCorrige((v) => !v)}
            className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            {corrige ? "Masquer le dégât évité" : "Voir le dégât que tu viens d'éviter"}
          </button>
          {corrige ? (
            <div className="rounded-lg border-2 border-rose-500/40 bg-rose-500/5 p-3">
              <p className="text-xs font-semibold text-rose-700">
                Ce que ce MCD aurait causé dans la base
              </p>
              <p className="mt-1 text-[11px] text-muted-foreground">{d.degat}</p>
            </div>
          ) : null}
        </>
      ) : (
        <Verdict tone="bad">
          Non. Regarde encore : le défaut est{" "}
          <strong>{DEFAUTS.find((x) => x.value === d.defaut)?.label ?? ""}</strong>. {d.correction}
        </Verdict>
      )}

      <Panel>
        <Stat label="MCD" value={`${k + 1} / ${trouves}`} />
        <Stat label="Le réflexe" value="une case, une information" color={PALETTE.blue} />
      </Panel>
    </div>
  );
}
