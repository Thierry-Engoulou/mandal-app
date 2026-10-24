import { useState } from "react";
import { Choice, PALETTE, Panel, Stat, Verdict } from "./controls";
import { JeuClassement } from "./info1-jeux";
import type { Base } from "./inf7-sql-moteur";
import { VueTable, evaluerCondition, executer } from "./inf7-sql-moteur";

/** Informatique Terminale C et D — chapitres 16 et 17 : le SQL. */

/* ------------------------------------------------------------------ */
/* Une console SQL réutilisable                                        */
/* ------------------------------------------------------------------ */

function ConsoleSql({
  base,
  setBase,
  exemples,
  placeholder,
  avecConfirmation = false,
}: {
  base: Base;
  setBase: (b: Base) => void;
  exemples: ReadonlyArray<{ sql: string; note?: string }>;
  placeholder: string;
  avecConfirmation?: boolean;
}) {
  const [sql, setSql] = useState("");
  const [journal, setJournal] = useState<{ sql: string; ok: boolean; msg: string }[]>([]);
  const [aConfirmer, setAConfirmer] = useState<string | null>(null);
  const [sortie, setSortie] = useState<{
    cols: string[];
    lignes: Record<string, unknown>[];
  } | null>(null);
  const [avert, setAvert] = useState<string | null>(null);

  const lancer = (requete: string, confirme = false) => {
    const r = executer(base, requete, confirme);
    setBase(r.base);
    setJournal((j) => [...j, { sql: requete, ok: r.ok, msg: r.message }]);
    setSortie(r.sortie ? { cols: r.sortie.cols, lignes: r.sortie.lignes } : null);
    setAvert(r.avertissement ?? null);
    if (avecConfirmation && !r.ok && r.avertissement) setAConfirmer(requete);
    else setAConfirmer(null);
  };

  return (
    <div className="space-y-2">
      <div className="flex gap-2">
        <input
          value={sql}
          onChange={(e) => setSql(e.target.value)}
          placeholder={placeholder}
          onKeyDown={(e) => {
            if (e.key === "Enter" && sql.trim() !== "") lancer(sql);
          }}
          className="flex-1 rounded-lg border border-border bg-background px-2.5 py-1.5 font-mono text-xs"
        />
        <button
          type="button"
          onClick={() => sql.trim() !== "" && lancer(sql)}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Exécuter
        </button>
      </div>

      <div className="flex flex-wrap gap-1">
        {exemples.map((x) => (
          <button
            key={x.sql}
            type="button"
            onClick={() => setSql(x.sql)}
            title={x.note ?? ""}
            className="rounded border border-border bg-background px-1.5 py-0.5 font-mono text-[10px] text-muted-foreground hover:bg-secondary/60"
          >
            {x.sql.length > 46 ? `${x.sql.slice(0, 44)}…` : x.sql}
          </button>
        ))}
      </div>

      {aConfirmer ? (
        <div className="space-y-1.5 rounded-lg border-2 border-rose-500/50 bg-rose-500/5 p-2.5">
          <p className="text-[11px] font-semibold text-rose-700">{avert}</p>
          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => lancer(aConfirmer, true)}
              className="rounded-lg bg-rose-600 px-2.5 py-1 text-[11px] font-semibold text-white"
            >
              Je confirme, exécuter quand même
            </button>
            <button
              type="button"
              onClick={() => setAConfirmer(null)}
              className="rounded-lg border border-border bg-background px-2.5 py-1 text-[11px] font-medium text-muted-foreground"
            >
              Annuler
            </button>
          </div>
        </div>
      ) : null}

      {journal.length > 0 ? (
        <div className="max-h-44 space-y-1 overflow-y-auto rounded-lg bg-slate-900 p-3">
          {journal.slice(-8).map((j, k) => (
            <div key={`${k}-${j.sql}`}>
              <p className="font-mono text-[10px] text-slate-300">&gt; {j.sql}</p>
              <p className="font-mono text-[10px]" style={{ color: j.ok ? "#4ade80" : "#fb7185" }}>
                {j.ok ? "✓ " : "✗ "}
                {j.msg}
              </p>
            </div>
          ))}
        </div>
      ) : null}

      {sortie && sortie.cols.length > 0 ? (
        <div className="overflow-x-auto rounded-lg border border-border">
          <table className="w-full border-collapse text-[11px]">
            <thead>
              <tr>
                {sortie.cols.map((c) => (
                  <th key={c} className="border border-border bg-secondary/40 px-2 py-1 font-mono">
                    {c}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {sortie.lignes.length === 0 ? (
                <tr>
                  <td
                    colSpan={sortie.cols.length}
                    className="border border-border px-2 py-2 text-center text-muted-foreground"
                  >
                    aucune ligne
                  </td>
                </tr>
              ) : (
                sortie.lignes.slice(0, 40).map((l, i) => (
                  <tr key={`${i}-${Object.values(l).join("|")}`}>
                    {sortie.cols.map((c) => (
                      <td key={c} className="border border-border px-2 py-1 font-mono">
                        {l[c] === null || l[c] === undefined ? "NULL" : String(l[c])}
                      </td>
                    ))}
                  </tr>
                ))
              )}
            </tbody>
          </table>
          {sortie.lignes.length > 40 ? (
            <p className="px-2 py-1 text-[10px] text-muted-foreground">
              … {sortie.lignes.length - 40} lignes de plus
            </p>
          ) : null}
        </div>
      ) : null}

      {avert && !aConfirmer ? <Verdict tone="bad">{avert}</Verdict> : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 16 — LDD, LMD, LCD                                         */
/* ------------------------------------------------------------------ */

export function SousLangagesSql() {
  const [piege, setPiege] = useState<"alter" | "delete">("alter");

  return (
    <div className="space-y-3">
      <JeuClassement
        aide="La question qui tranche : est-ce que je touche au MEUBLE (la structure), à ce qu'il y a DEDANS (les données), ou aux CLÉS (les droits) ?"
        libelleChoix="Sous-langage"
        options={[
          { value: "ldd", label: "LDD — définition" },
          { value: "lmd", label: "LMD — manipulation" },
          { value: "lcd", label: "LCD — contrôle" },
        ]}
        cas={[
          {
            enonce: "CREATE TABLE ELEVE (…)",
            bonne: "ldd",
            pourquoi: "On fabrique le meuble : définition de données.",
          },
          {
            enonce: "INSERT INTO ELEVE VALUES (…)",
            bonne: "lmd",
            pourquoi: "On remplit un tiroir : manipulation.",
          },
          {
            enonce: "GRANT SELECT ON ELEVE TO prof;",
            bonne: "lcd",
            pourquoi: "On donne une clé : contrôle des données.",
          },
          {
            enonce: "ALTER TABLE ELEVE ADD Telephone VARCHAR(15);",
            bonne: "ldd",
            pourquoi:
              "ALTER change la STRUCTURE — il ajoute un tiroir au meuble. C'est du LDD, même si cela ressemble à une modification.",
          },
          {
            enonce: "UPDATE ELEVE SET Nom = 'MBIDA' WHERE Matricule = 'E101';",
            bonne: "lmd",
            pourquoi:
              "UPDATE change le CONTENU d'une case, pas la structure. C'est là que se joue le piège ALTER / UPDATE.",
          },
          {
            enonce: "DROP TABLE ELEVE;",
            bonne: "ldd",
            pourquoi: "On jette le meuble entier, avec son contenu : structure, donc LDD.",
          },
          {
            enonce: "DELETE FROM ELEVE;",
            bonne: "lmd",
            pourquoi:
              "On vide les tiroirs et on garde le meuble. La table existe encore, vide. C'est le second piège de l'examen.",
          },
          {
            enonce: "SELECT Nom FROM ELEVE WHERE NumClasse = 2;",
            bonne: "lmd",
            pourquoi:
              "Interroger, c'est manipuler. Certains auteurs en font un LID, langage d'interrogation, mais le programme le range dans le LMD.",
          },
          {
            enonce: "REVOKE UPDATE ON NOTES FROM secretaire;",
            bonne: "lcd",
            pourquoi: "On retire une clé : contrôle.",
          },
          {
            enonce: "ALTER TABLE ELEVE DROP COLUMN Telephone;",
            bonne: "ldd",
            pourquoi: "Encore la structure : on enlève un tiroir.",
          },
          {
            enonce: "CREATE DATABASE LYCEE;",
            bonne: "ldd",
            pourquoi: "On construit le bâtiment qui contiendra les meubles.",
          },
          {
            enonce: "COMMIT;",
            bonne: "lcd",
            pourquoi:
              "Valider une transaction relève du contrôle. Certains manuels en font un LCT, langage de contrôle de transaction.",
          },
        ]}
      />

      <div className="space-y-2 border-t border-border pt-3">
        <Choice<"alter" | "delete">
          label="Les deux pièges de l'examen"
          value={piege}
          options={[
            { value: "alter", label: "ALTER contre UPDATE" },
            { value: "delete", label: "DELETE contre DROP" },
          ]}
          onChange={setPiege}
        />
        {piege === "alter" ? (
          <div className="grid gap-2 sm:grid-cols-2">
            <div className="rounded-lg border-2 border-blue-500/40 bg-blue-500/5 p-2.5">
              <p className="font-mono text-[11px] font-semibold">ALTER TABLE — LDD</p>
              <p className="mt-1 text-[11px] text-muted-foreground">
                Il change la <strong>structure</strong> : ajoute une colonne, en retire une, change
                un type. Après un ALTER, la table n&apos;a plus la même forme.
              </p>
              <pre className="mt-1 font-mono text-[10px] text-muted-foreground">
                {`ELEVE avant :  Matricule | Nom
ELEVE après :  Matricule | Nom | Telephone`}
              </pre>
            </div>
            <div className="rounded-lg border-2 border-emerald-500/40 bg-emerald-500/5 p-2.5">
              <p className="font-mono text-[11px] font-semibold">UPDATE — LMD</p>
              <p className="mt-1 text-[11px] text-muted-foreground">
                Il change le <strong>contenu</strong> d&apos;une ou plusieurs cases. La forme de la
                table ne bouge pas d&apos;un millimètre.
              </p>
              <pre className="mt-1 font-mono text-[10px] text-muted-foreground">
                {`avant :  E101 | MBIDA
après :  E101 | MBIDA ESSOMBA`}
              </pre>
            </div>
          </div>
        ) : (
          <div className="grid gap-2 sm:grid-cols-2">
            <div className="rounded-lg border-2 border-emerald-500/40 bg-emerald-500/5 p-2.5">
              <p className="font-mono text-[11px] font-semibold">DELETE FROM — LMD</p>
              <p className="mt-1 text-[11px] text-muted-foreground">
                Il retire des <strong>lignes</strong>. La table reste là, avec ses colonnes et ses
                contraintes. On peut y réinsérer dès la seconde suivante.
              </p>
              <pre className="mt-1 font-mono text-[10px] text-muted-foreground">
                {`DELETE FROM ELEVE;
→ ELEVE existe, 0 ligne`}
              </pre>
            </div>
            <div className="rounded-lg border-2 border-rose-500/40 bg-rose-500/5 p-2.5">
              <p className="font-mono text-[11px] font-semibold">DROP TABLE — LDD</p>
              <p className="mt-1 text-[11px] text-muted-foreground">
                Il efface la <strong>table entière</strong> : structure, données, contraintes,
                index. Il faudra la recréer de zéro.
              </p>
              <pre className="mt-1 font-mono text-[10px] text-muted-foreground">
                {`DROP TABLE ELEVE;
→ ELEVE n'existe plus`}
              </pre>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 16 — Écrire un CREATE TABLE                                */
/* ------------------------------------------------------------------ */

const ENONCES_CREATE = [
  {
    id: "e1",
    enonce:
      "Créer la table CLASSE : NumClasse, entier, clé primaire ; Libelle, chaîne de 30 caractères ; Effectif, entier.",
    attendu: ["CLASSE"],
    indice:
      "CREATE TABLE nom ( colonne TYPE contraintes, … ) — et pas de virgule après la dernière colonne.",
  },
  {
    id: "e2",
    enonce:
      "Créer la table ELEVE : Matricule, chaîne de 10 caractères, clé primaire ; Nom et Prenom, chaînes de 30 ; DateNaissance, une date ; NumClasse, entier, clé étrangère vers CLASSE.",
    attendu: ["CLASSE", "ELEVE"],
    indice:
      "FOREIGN KEY (NumClasse) REFERENCES CLASSE(NumClasse) — et CLASSE doit exister avant ELEVE.",
  },
] as const;

const EXEMPLES_CREATE = [
  { sql: "CREATE TABLE CLASSE (NumClasse INT PRIMARY KEY, Libelle VARCHAR(30), Effectif INT);" },
  {
    sql: "CREATE TABLE ELEVE (Matricule VARCHAR(10) PRIMARY KEY, Nom VARCHAR(30), Prenom VARCHAR(30), DateNaissance DATE, NumClasse INT, FOREIGN KEY (NumClasse) REFERENCES CLASSE(NumClasse));",
  },
  {
    sql: "CREATE TABLE CLASSE (NumClasse INT PRIMARY KEY, Libelle VARCHAR(30), Effectif INT,);",
    note: "la virgule de trop",
  },
  {
    sql: "CREATE TABLE CLASSE (NumClasse INT, Libelle VARCHAR(30));",
    note: "sans clé primaire",
  },
  {
    sql: "CREATE TABLE ELEVE (Matricule VARCHAR(10) PRIMARY KEY, DateNaissance VARCHAR(10));",
    note: "VARCHAR au lieu de DATE",
  },
] as const;

export function CreateTable() {
  const [base, setBase] = useState<Base>([]);
  const [k, setK] = useState(0);

  const e = ENONCES_CREATE[k] ?? ENONCES_CREATE[0];
  const faites = e.attendu.every((n) => base.some((t) => t.nom.toUpperCase() === n));

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-1.5">
        {ENONCES_CREATE.map((x, i) => (
          <button
            key={x.id}
            type="button"
            onClick={() => setK(i)}
            className={
              i === k
                ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
                : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            }
          >
            Énoncé {i + 1}
          </button>
        ))}
        <button
          type="button"
          onClick={() => setBase([])}
          className="rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Vider la base
        </button>
      </div>

      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-xs">{e.enonce}</p>
        <p className="mt-1 font-mono text-[10px] text-muted-foreground">{e.indice}</p>
      </div>

      <ConsoleSql
        base={base}
        setBase={setBase}
        exemples={EXEMPLES_CREATE}
        placeholder="CREATE TABLE …"
      />

      {base.length > 0 ? (
        <div className="space-y-2">
          {base.map((t) => (
            <VueTable key={t.nom} table={t} />
          ))}
          <div className="space-y-0.5 rounded-lg border border-border bg-background p-2.5">
            {base.map((t) => (
              <p key={t.nom} className="font-mono text-[10px] text-muted-foreground">
                {t.nom} (
                {t.cols
                  .map(
                    (c) =>
                      `${c.nom} ${c.type}${c.pk ? " PK" : ""}${c.fk ? ` → ${c.fk.table}` : ""}`,
                  )
                  .join(", ")}
                )
              </p>
            ))}
          </div>
        </div>
      ) : null}

      {faites ? (
        <Verdict tone="ok">
          {e.attendu.join(" et ")} {e.attendu.length > 1 ? "sont créées" : "est créée"}. Les quatre
          fautes que la simulation guette, et que le correcteur guette aussi : la{" "}
          <strong>virgule de trop</strong> après la dernière colonne, la{" "}
          <strong>clé primaire oubliée</strong>, un <strong>VARCHAR là où il fallait DATE</strong>,
          et une <strong>table référencée qui n&apos;existe pas encore</strong>.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Écris la requête, ou clique un exemple pour la charger puis la modifier. Essaie aussi les
          exemples fautifs : le message d&apos;erreur t&apos;indique où regarder.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 16 — ALTER, DELETE, DROP, UPDATE                           */
/* ------------------------------------------------------------------ */

const BASE_LYCEE: Base = [
  {
    nom: "CLASSE",
    cols: [
      { nom: "NumClasse", type: "INT", pk: true },
      { nom: "Libelle", type: "VARCHAR(30)" },
    ],
    lignes: [
      { NumClasse: 1, Libelle: "Terminale C" },
      { NumClasse: 2, Libelle: "Terminale D" },
    ],
  },
  {
    nom: "ELEVE",
    cols: [
      { nom: "Matricule", type: "VARCHAR(10)", pk: true },
      { nom: "Nom", type: "VARCHAR(30)" },
      { nom: "Sexe", type: "VARCHAR(10)" },
      { nom: "NumClasse", type: "INT", fk: { table: "CLASSE", col: "NumClasse" } },
    ],
    lignes: [
      { Matricule: "E101", Nom: "MBIDA", Sexe: "Masculin", NumClasse: 1 },
      { Matricule: "E102", Nom: "NGONO", Sexe: "Féminin", NumClasse: 2 },
      { Matricule: "E103", Nom: "FOUDA", Sexe: "Masculin", NumClasse: 1 },
    ],
  },
  {
    nom: "MATIERE",
    cols: [
      { nom: "CodeMat", type: "VARCHAR(5)", pk: true },
      { nom: "Libelle", type: "VARCHAR(30)" },
      { nom: "Coefficient", type: "INT" },
    ],
    lignes: [
      { CodeMat: "INFO", Libelle: "Informatique", Coefficient: 3 },
      { CodeMat: "MATH", Libelle: "Mathématiques", Coefficient: 6 },
    ],
  },
];

const EXEMPLES_ALTER = [
  { sql: "ALTER TABLE ELEVE ADD Telephone VARCHAR(15);" },
  { sql: "ALTER TABLE ELEVE DROP COLUMN Sexe;" },
  { sql: "ALTER TABLE MATIERE MODIFY Coefficient INT;" },
  { sql: "UPDATE MATIERE SET Coefficient = 4 WHERE CodeMat = 'INFO';" },
  { sql: "DELETE FROM MATIERE WHERE CodeMat = 'MATH';" },
  { sql: "DELETE FROM MATIERE;" },
  { sql: "DROP TABLE MATIERE;" },
  { sql: "DROP TABLE CLASSE;", note: "référencée par ELEVE" },
  { sql: "DELETE FROM CLASSE WHERE NumClasse = 1;", note: "ligne référencée" },
] as const;

export function AlterDrop() {
  const [base, setBase] = useState<Base>(BASE_LYCEE);
  const [historique, setHistorique] = useState<Base[]>([]);

  const changer = (b: Base) => {
    setHistorique((h) => [...h, base]);
    setBase(b);
  };

  const annuler = () => {
    const precedent = historique[historique.length - 1];
    if (precedent) {
      setBase(precedent);
      setHistorique((h) => h.slice(0, -1));
    }
  };

  return (
    <div className="space-y-3">
      <ConsoleSql
        base={base}
        setBase={changer}
        exemples={EXEMPLES_ALTER}
        placeholder="ALTER TABLE … / DELETE FROM … / DROP TABLE …"
        avecConfirmation
      />

      <div className="flex flex-wrap gap-1.5">
        <button
          type="button"
          onClick={annuler}
          disabled={historique.length === 0}
          className={
            historique.length === 0
              ? "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs text-muted-foreground opacity-40"
              : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
          }
        >
          Annuler ma dernière commande
        </button>
        <button
          type="button"
          onClick={() => {
            setBase(BASE_LYCEE);
            setHistorique([]);
          }}
          className="rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Remettre la base d&apos;origine
        </button>
      </div>

      {historique.length > 0 ? (
        <Verdict tone="warn">
          Le bouton « Annuler » n&apos;existe que dans cette simulation.{" "}
          <strong>Un vrai SGBD ne revient pas en arrière</strong> sur un DROP ou un DELETE validé :
          il n&apos;y a ni corbeille ni Ctrl+Z. Seule une sauvegarde faite avant permet de
          récupérer, et c&apos;est pour cela que la sauvegarde est une fonction du SGBD.
        </Verdict>
      ) : null}

      <div className="space-y-2">
        {base.map((t) => (
          <VueTable key={t.nom} table={t} />
        ))}
        {base.length < BASE_LYCEE.length ? (
          <p className="text-[11px] text-rose-600">
            Il manque {BASE_LYCEE.length - base.length} table(s) :{" "}
            {BASE_LYCEE.filter((x) => !base.some((y) => y.nom === x.nom))
              .map((x) => x.nom)
              .join(", ")}
            . Un DROP TABLE efface la structure <strong>et</strong> les données, définitivement.
          </p>
        ) : null}
      </div>

      <Panel>
        <Stat label="Tables dans la base" value={`${base.length}`} />
        <Stat
          label="Lignes au total"
          value={`${base.reduce((s, t) => s + t.lignes.length, 0)}`}
          color={PALETTE.blue}
        />
      </Panel>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 17 — INSERT, UPDATE, DELETE                                */
/* ------------------------------------------------------------------ */

const BASE_VIDE: Base = [
  {
    nom: "ARTICLE",
    cols: [
      { nom: "Reference", type: "VARCHAR(10)", pk: true },
      { nom: "Designation", type: "VARCHAR(40)" },
      { nom: "PrixUnitaire", type: "INT" },
      { nom: "QuantiteStock", type: "INT" },
    ],
    lignes: [],
  },
];

const EXEMPLES_INSERT = [
  { sql: "INSERT INTO ARTICLE VALUES ('A001', 'Ordinateur', 250000, 4);" },
  {
    sql: "INSERT INTO ARTICLE (Reference, Designation, PrixUnitaire, QuantiteStock) VALUES ('A002', 'Imprimante', 120000, 2);",
  },
  { sql: "INSERT INTO ARTICLE VALUES ('A003', Onduleur, 65000, 6);", note: "apostrophes oubliées" },
  {
    sql: "INSERT INTO ARTICLE VALUES ('A004', 'Scanner', 90 000, 3);",
    note: "espace dans le nombre",
  },
  { sql: "INSERT INTO ARTICLE VALUES ('A005', 'Clavier', 8000);", note: "une valeur manquante" },
  { sql: "INSERT INTO ARTICLE VALUES ('A001', 'Souris', 5000, 10);", note: "référence en double" },
  { sql: "UPDATE ARTICLE SET PrixUnitaire = 260000 WHERE Reference = 'A001';" },
  { sql: "UPDATE ARTICLE SET QuantiteStock = QuantiteStock - 1 WHERE Reference = 'A001';" },
  { sql: "UPDATE ARTICLE SET PrixUnitaire = 0;", note: "sans WHERE" },
  { sql: "DELETE FROM ARTICLE WHERE QuantiteStock = 0;" },
  { sql: "DELETE FROM ARTICLE;", note: "sans WHERE" },
] as const;

export function InsertUpdateDelete() {
  const [base, setBase] = useState<Base>(BASE_VIDE);
  const t = base[0];

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-xs font-medium">
          La table ARTICLE t&apos;attend, vide. Remplis-la avec de vrais INSERT.
        </p>
        <p className="mt-1 font-mono text-[10px] text-muted-foreground">
          ARTICLE (Reference VARCHAR(10) PK, Designation VARCHAR(40), PrixUnitaire INT,
          QuantiteStock INT)
        </p>
      </div>

      <ConsoleSql
        base={base}
        setBase={setBase}
        exemples={EXEMPLES_INSERT}
        placeholder="INSERT INTO ARTICLE VALUES (…);"
        avecConfirmation
      />

      {t ? <VueTable table={t} /> : null}

      <div className="space-y-1 rounded-lg border border-border bg-background p-3 text-[11px] text-muted-foreground">
        <p>
          <strong className="text-foreground">Les trois fautes d&apos;INSERT</strong> — une valeur
          texte sans apostrophes, que le moteur prend pour un nom de colonne ; un espace dans un
          nombre, qui casse la syntaxe ; et un nombre de valeurs qui ne correspond pas au nombre de
          colonnes.
        </p>
        <p>
          <strong className="text-foreground">UPDATE et DELETE sans WHERE</strong> — ils touchent{" "}
          <strong>toutes</strong> les lignes. La simulation te prévient et te demande confirmation ;
          un vrai SGBD, lui, exécute sans un mot. Le réflexe du professionnel est d&apos;écrire
          d&apos;abord un SELECT avec la même clause WHERE, pour voir ce qu&apos;on va toucher.
        </p>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 17 — Les SELECT                                            */
/* ------------------------------------------------------------------ */

const BASE_SELECT: Base = [
  {
    nom: "CLASSE",
    cols: [
      { nom: "NumClasse", type: "INT", pk: true },
      { nom: "Libelle", type: "VARCHAR(30)" },
    ],
    lignes: [
      { NumClasse: 1, Libelle: "Terminale C" },
      { NumClasse: 2, Libelle: "Terminale D" },
      { NumClasse: 3, Libelle: "Première C" },
    ],
  },
  {
    nom: "ELEVE",
    cols: [
      { nom: "Matricule", type: "VARCHAR(10)", pk: true },
      { nom: "Nom", type: "VARCHAR(30)" },
      { nom: "Prenom", type: "VARCHAR(30)" },
      { nom: "Sexe", type: "VARCHAR(10)" },
      { nom: "Moyenne", type: "DECIMAL" },
      { nom: "NumClasse", type: "INT", fk: { table: "CLASSE", col: "NumClasse" } },
    ],
    lignes: [
      {
        Matricule: "E101",
        Nom: "MBIDA",
        Prenom: "Jean",
        Sexe: "Masculin",
        Moyenne: 13.5,
        NumClasse: 1,
      },
      {
        Matricule: "E102",
        Nom: "NGONO",
        Prenom: "Alice",
        Sexe: "Féminin",
        Moyenne: 15.25,
        NumClasse: 2,
      },
      {
        Matricule: "E103",
        Nom: "FOUDA",
        Prenom: "Paul",
        Sexe: "Masculin",
        Moyenne: 9.75,
        NumClasse: 1,
      },
      {
        Matricule: "E104",
        Nom: "ATEBA",
        Prenom: "Marie",
        Sexe: "Féminin",
        Moyenne: 11,
        NumClasse: 3,
      },
      {
        Matricule: "E105",
        Nom: "BIYA",
        Prenom: "Serge",
        Sexe: "Masculin",
        Moyenne: 17,
        NumClasse: 2,
      },
    ],
  },
];

const EXEMPLES_SELECT = [
  { sql: "SELECT * FROM ELEVE;" },
  { sql: "SELECT Nom, Prenom FROM ELEVE WHERE NumClasse = 2 ORDER BY Nom ASC;" },
  { sql: "SELECT Nom, Prenom FROM ELEVE WHERE Sexe = 'Féminin';" },
  { sql: "SELECT Nom, Moyenne FROM ELEVE WHERE Moyenne >= 10 ORDER BY Moyenne DESC;" },
  {
    sql: "SELECT Nom, Libelle FROM ELEVE, CLASSE WHERE ELEVE.NumClasse = CLASSE.NumClasse;",
    note: "jointure correcte",
  },
  { sql: "SELECT Nom, Libelle FROM ELEVE, CLASSE;", note: "jointure oubliée" },
  { sql: "SELECT DISTINCT Sexe FROM ELEVE;" },
] as const;

export function RequeteSelect() {
  const [base, setBase] = useState<Base>(BASE_SELECT);

  return (
    <div className="space-y-3">
      <div className="space-y-2">
        {base.map((t) => (
          <VueTable key={t.nom} table={t} />
        ))}
      </div>

      <ConsoleSql
        base={base}
        setBase={setBase}
        exemples={EXEMPLES_SELECT}
        placeholder="SELECT … FROM … WHERE …;"
      />

      <div className="space-y-1 rounded-lg border border-border bg-background p-3 text-[11px] text-muted-foreground">
        <p>
          <strong className="text-foreground">L&apos;ordre des clauses est imposé</strong> : SELECT,
          puis FROM, puis WHERE, puis ORDER BY. Les inverser est une erreur de syntaxe.
        </p>
        <p>
          <strong className="text-foreground">La jointure</strong> — deux tables dans le FROM
          exigent une condition qui les relie dans le WHERE. Lance l&apos;exemple « jointure oubliée
          » : cinq élèves fois trois classes donnent <strong>quinze lignes absurdes</strong>, où
          chaque élève apparaît dans toutes les classes. Sur deux tables de trente lignes, cela
          ferait neuf cents lignes. C&apos;est le <strong>produit cartésien</strong>, et c&apos;est
          la faute la plus coûteuse du SELECT.
        </p>
        <p>
          <strong className="text-foreground">ORDER BY</strong> — ASC pour croissant, qui est la
          valeur par défaut, DESC pour décroissant.
        </p>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 17 — Construire une condition                              */
/* ------------------------------------------------------------------ */

const EMPLOYES = [
  {
    Matricule: "P01",
    Nom: "MBIDA",
    Service: "Comptabilité",
    Salaire: 180000,
    Ville: "Douala",
    Prime: 15000,
  },
  {
    Matricule: "P02",
    Nom: "NGONO",
    Service: "Vente",
    Salaire: 120000,
    Ville: "Yaoundé",
    Prime: null,
  },
  {
    Matricule: "P03",
    Nom: "FOUDA",
    Service: "Vente",
    Salaire: 250000,
    Ville: "Douala",
    Prime: 40000,
  },
  {
    Matricule: "P04",
    Nom: "ATEBA",
    Service: "Technique",
    Salaire: 150000,
    Ville: "Garoua",
    Prime: null,
  },
  {
    Matricule: "P05",
    Nom: "BIYA",
    Service: "Comptabilité",
    Salaire: 200000,
    Ville: "Yaoundé",
    Prime: 25000,
  },
  {
    Matricule: "P06",
    Nom: "MBALLA",
    Service: "Technique",
    Salaire: 150000,
    Ville: "Douala",
    Prime: 10000,
  },
];

const BRIQUES = [
  { t: "Salaire >= 150000", g: "Les salaires d'au moins 150 000 — la borne EST comprise." },
  { t: "Salaire > 150000", g: "Strictement supérieur : ATEBA et MBALLA, à 150 000 pile, sortent." },
  { t: "Salaire BETWEEN 150000 AND 200000", g: "BETWEEN comprend LES DEUX bornes." },
  { t: "Service = 'Vente'", g: "Égalité sur du texte : apostrophes obligatoires." },
  { t: "Service IN ('Vente', 'Technique')", g: "IN remplace une série de OR." },
  { t: "Nom LIKE 'M%'", g: "Commence par M. Le % remplace n'importe quelle suite." },
  { t: "Nom LIKE '%A'", g: "Finit par A." },
  { t: "Prime IS NULL", g: "Aucune prime enregistrée. On n'écrit jamais Prime = NULL." },
  { t: "Prime IS NOT NULL", g: "Une prime existe." },
  { t: "AND", g: "Les deux conditions doivent être vraies." },
  { t: "OR", g: "Une seule suffit." },
  { t: "(", g: "" },
  { t: ")", g: "" },
] as const;

const PIEGES = [
  {
    titre: "La borne comprise",
    a: "Salaire >= 150000",
    b: "Salaire > 150000",
    mot: "Deux employés gagnent exactement 150 000. Avec >= ils sont retenus, avec > ils sortent. Un seul caractère, deux résultats différents — et c'est la même différence entre BETWEEN, qui comprend ses bornes, et une double inégalité stricte.",
  },
  {
    titre: "Les parenthèses avec AND et OR",
    a: "Service = 'Vente' OR Service = 'Technique' AND Ville = 'Douala'",
    b: "(Service = 'Vente' OR Service = 'Technique') AND Ville = 'Douala'",
    mot: "Sans parenthèses, le AND est évalué en premier : la requête rend « tous les vendeurs, plus les techniciens de Douala ». Avec les parenthèses, elle rend « les vendeurs et les techniciens, à condition d'être à Douala ». Ce ne sont pas du tout les mêmes personnes.",
  },
] as const;

export function OperateursSql() {
  const [cond, setCond] = useState("Salaire >= 150000");
  const [piege, setPiege] = useState(0);

  const retenues = EMPLOYES.map((e, i) => ({ e, i })).filter(({ e }) =>
    evaluerCondition(cond, e as unknown as Record<string, string | number | null>),
  );
  const indices = retenues.map((x) => x.i);

  const p = PIEGES[piege] ?? PIEGES[0];
  const nA = EMPLOYES.filter((e) =>
    evaluerCondition(p.a, e as unknown as Record<string, string | number | null>),
  ).length;
  const nB = EMPLOYES.filter((e) =>
    evaluerCondition(p.b, e as unknown as Record<string, string | number | null>),
  ).length;

  return (
    <div className="space-y-3">
      <div className="space-y-1.5">
        <p className="font-mono text-[11px] text-muted-foreground">
          SELECT * FROM EMPLOYE WHERE{" "}
          <span className="font-semibold text-foreground">{cond || "…"}</span>;
        </p>
        <input
          value={cond}
          onChange={(e) => setCond(e.target.value)}
          className="w-full rounded-lg border border-border bg-background px-2.5 py-1.5 font-mono text-xs"
        />
        <div className="flex flex-wrap gap-1">
          {BRIQUES.map((b) => (
            <button
              key={b.t}
              type="button"
              onClick={() => setCond((v) => (v === "" ? b.t : `${v} ${b.t}`))}
              title={b.g}
              className="rounded border border-border bg-background px-1.5 py-0.5 font-mono text-[10px] text-muted-foreground hover:bg-secondary/60"
            >
              {b.t}
            </button>
          ))}
          <button
            type="button"
            onClick={() => setCond("")}
            className="rounded border border-border bg-background px-1.5 py-0.5 text-[10px] font-medium text-muted-foreground hover:bg-secondary/60"
          >
            effacer
          </button>
        </div>
      </div>

      <div className="overflow-x-auto">
        <table className="w-full border-collapse text-[11px]">
          <thead>
            <tr>
              {["Matricule", "Nom", "Service", "Salaire", "Ville", "Prime"].map((c) => (
                <th key={c} className="border border-border bg-secondary/40 px-2 py-1 font-mono">
                  {c}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {EMPLOYES.map((e, i) => (
              <tr key={e.Matricule} className={indices.includes(i) ? "bg-emerald-500/15" : ""}>
                <td className="border border-border px-2 py-1 font-mono">{e.Matricule}</td>
                <td className="border border-border px-2 py-1">{e.Nom}</td>
                <td className="border border-border px-2 py-1">{e.Service}</td>
                <td className="border border-border px-2 py-1 text-right font-mono">
                  {e.Salaire.toLocaleString("fr-FR")}
                </td>
                <td className="border border-border px-2 py-1">{e.Ville}</td>
                <td className="border border-border px-2 py-1 text-right font-mono">
                  {e.Prime === null ? (
                    <span className="text-muted-foreground">NULL</span>
                  ) : (
                    e.Prime.toLocaleString("fr-FR")
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <Panel>
        <Stat
          label="Lignes retenues"
          value={`${retenues.length} / ${EMPLOYES.length}`}
          color={PALETTE.green}
        />
        <Stat
          label="Lignes écartées"
          value={`${EMPLOYES.length - retenues.length}`}
          color={PALETTE.slate}
        />
      </Panel>

      <div className="space-y-2 border-t border-border pt-3">
        <Choice<string>
          label="Les deux pièges"
          value={String(piege)}
          options={PIEGES.map((x, i) => ({ value: String(i), label: x.titre }))}
          onChange={(v) => setPiege(Number(v))}
        />
        <div className="grid gap-2 sm:grid-cols-2">
          <button
            type="button"
            onClick={() => setCond(p.a)}
            className="rounded-lg border border-border bg-background p-2.5 text-left hover:bg-secondary/60"
          >
            <p className="font-mono text-[10px]">{p.a}</p>
            <p className="mt-1 text-[11px] font-semibold" style={{ color: PALETTE.blue }}>
              {nA} ligne{nA > 1 ? "s" : ""}
            </p>
          </button>
          <button
            type="button"
            onClick={() => setCond(p.b)}
            className="rounded-lg border border-border bg-background p-2.5 text-left hover:bg-secondary/60"
          >
            <p className="font-mono text-[10px]">{p.b}</p>
            <p className="mt-1 text-[11px] font-semibold" style={{ color: PALETTE.orange }}>
              {nB} ligne{nB > 1 ? "s" : ""}
            </p>
          </button>
        </div>
        <Verdict tone={nA === nB ? "warn" : "bad"}>{p.mot}</Verdict>
      </div>
    </div>
  );
}
