import { useState } from "react";
import { Choice, PALETTE, Panel, Stat, Verdict } from "./controls";
import { JeuClassement } from "./info1-jeux";
import type { Base, Col } from "./inf7-sql-moteur";
import { VueTable, executer } from "./inf7-sql-moteur";

/** Informatique Terminale C et D — chapitre 15 : les fonctions d'un SGBD. */

/* ------------------------------------------------------------------ */
/* Chapitre 15 — Fichiers séparés contre base de données               */
/* ------------------------------------------------------------------ */

const FICHIERS = [
  { nom: "inscriptions.xlsx", service: "Secrétariat", adresse: "Mvog-Ada, Yaoundé" },
  { nom: "notes.xlsx", service: "Censorat", adresse: "Mvog-Ada, Yaoundé" },
  { nom: "cantine.xlsx", service: "Intendance", adresse: "Mvog-Ada, Yaoundé" },
  { nom: "transport.xlsx", service: "Vie scolaire", adresse: "Mvog-Ada, Yaoundé" },
];

const MODELES_HISTO = [
  {
    nom: "Hiérarchique",
    epoque: "années 1960",
    forme: "un arbre : chaque fils n'a qu'un père",
    limite:
      "Impossible de représenter un élève suivi par plusieurs professeurs sans tout dupliquer.",
  },
  {
    nom: "Réseau",
    epoque: "années 1970",
    forme: "un graphe : un fils peut avoir plusieurs pères",
    limite: "Plus souple, mais les chemins d'accès sont figés dans le programme.",
  },
  {
    nom: "Relationnel",
    epoque: "1970, et toujours dominant",
    forme: "des tables reliées par des valeurs communes",
    limite:
      "C'est le modèle du programme, celui de MySQL, d'Access et d'Oracle. On l'interroge en SQL sans savoir où les données sont rangées.",
  },
  {
    nom: "Objet",
    epoque: "années 1990",
    forme: "des objets avec leurs données et leurs méthodes",
    limite: "Pratique pour la programmation, resté marginal en gestion.",
  },
] as const;

export function ModelesBd() {
  const [adresse, setAdresse] = useState("Mvog-Ada, Yaoundé");
  const [fichiers, setFichiers] = useState(FICHIERS);
  const [baseAdresse, setBaseAdresse] = useState("Mvog-Ada, Yaoundé");
  const [note, setNote] = useState(25);
  const [essaiNote, setEssaiNote] = useState(false);
  const [modele, setModele] = useState<string>("Relationnel");

  const majFichiers = () => {
    // Le secrétariat ne met à jour que son propre fichier : c'est tout le problème.
    setFichiers((f) => f.map((x, i) => (i === 0 ? { ...x, adresse } : x)));
    setBaseAdresse(adresse);
  };

  const incoherents = fichiers.filter((f) => f.adresse !== baseAdresse).length;
  const m = MODELES_HISTO.find((x) => x.nom === modele) ?? MODELES_HISTO[2];

  return (
    <div className="space-y-4">
      <div className="space-y-1.5">
        <p className="text-xs font-medium text-muted-foreground">
          L&apos;élève MBIDA déménage. Saisis sa nouvelle adresse au secrétariat.
        </p>
        <div className="flex gap-2">
          <input
            value={adresse}
            onChange={(e) => setAdresse(e.target.value)}
            className="flex-1 rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs"
          />
          <button
            type="button"
            onClick={majFichiers}
            className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Enregistrer
          </button>
        </div>
      </div>

      <div className="grid gap-2 sm:grid-cols-2">
        <div className="space-y-1 rounded-lg border-2 border-rose-500/40 bg-rose-500/5 p-2.5">
          <p className="text-xs font-semibold text-rose-700">À gauche : quatre fichiers séparés</p>
          {fichiers.map((f) => (
            <p key={f.nom} className="text-[10px]">
              <span className="font-mono font-semibold">{f.nom}</span>{" "}
              <span className="text-muted-foreground">({f.service}) — </span>
              <span style={{ color: f.adresse === baseAdresse ? PALETTE.green : PALETTE.red }}>
                {f.adresse}
              </span>
            </p>
          ))}
        </div>
        <div className="space-y-1 rounded-lg border-2 border-emerald-500/40 bg-emerald-500/5 p-2.5">
          <p className="text-xs font-semibold text-emerald-700">À droite : une base de données</p>
          <p className="text-[10px]">
            <span className="font-mono font-semibold">ELEVE.Adresse</span>{" "}
            <span className="text-muted-foreground">
              — une seule fois, pour tous les services :{" "}
            </span>
            <span style={{ color: PALETTE.green }}>{baseAdresse}</span>
          </p>
          <p className="text-[10px] text-muted-foreground">
            Secrétariat, censorat, intendance et vie scolaire lisent la même ligne.
          </p>
        </div>
      </div>

      {incoherents > 0 ? (
        <Verdict tone="bad">
          {incoherents} fichiers sur {fichiers.length} gardent l&apos;ancienne adresse. C&apos;est
          la <strong>redondance</strong> et son conséquence immédiate, l&apos;
          <strong>incohérence</strong>: la même information existe en plusieurs endroits, et il
          suffit d&apos;en oublier un. Dans un an, personne ne saura plus laquelle est la bonne. La
          base, elle, ne stocke l&apos;adresse <strong>qu&apos;une fois</strong>.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Change l&apos;adresse et enregistre : le secrétariat met à jour son fichier, et seulement
          le sien. Regarde ce qui arrive aux trois autres.
        </Verdict>
      )}

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">
          Essaie maintenant d&apos;enregistrer une note de {note} sur 20
        </p>
        <input
          type="number"
          value={note}
          onChange={(e) => {
            setNote(Number(e.target.value));
            setEssaiNote(false);
          }}
          className="w-24 rounded-lg border border-border bg-background px-2 py-1 font-mono text-xs"
        />
        <button
          type="button"
          onClick={() => setEssaiNote(true)}
          className="ml-2 rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Enregistrer la note
        </button>

        {essaiNote ? (
          <div className="grid gap-2 sm:grid-cols-2">
            <div className="rounded-lg border-2 border-rose-500/40 bg-rose-500/5 p-2.5">
              <p className="text-xs font-semibold text-rose-700">Dans le fichier tableur</p>
              <p className="mt-1 font-mono text-[11px]">
                notes.xlsx : {note}
                <span className="ml-1 text-rose-600">✓ accepté</span>
              </p>
              <p className="mt-1 text-[10px] text-muted-foreground">
                Le tableur accepte tout. Rien dans le fichier ne sait qu&apos;une note va de 0 à 20.
              </p>
            </div>
            <div className="rounded-lg border-2 border-emerald-500/40 bg-emerald-500/5 p-2.5">
              <p className="text-xs font-semibold text-emerald-700">Dans la base de données</p>
              <p className="mt-1 font-mono text-[11px]">
                {note >= 0 && note <= 20 ? (
                  <span className="text-emerald-600">✓ 1 ligne insérée</span>
                ) : (
                  <span className="text-rose-600">
                    ✗ ERREUR 3819 — contrainte CHECK (Note BETWEEN 0 AND 20)
                  </span>
                )}
              </p>
              <p className="mt-1 text-[10px] text-muted-foreground">
                La règle est écrite <strong>dans la base</strong>, une fois pour toutes. Aucun
                programme, aucune saisie ne peut la contourner.
              </p>
            </div>
          </div>
        ) : null}
      </div>

      <div className="space-y-2 border-t border-border pt-3">
        <Choice<string>
          label="Les quatre modèles historiques"
          value={modele}
          options={MODELES_HISTO.map((x) => ({ value: x.nom, label: x.nom }))}
          onChange={setModele}
        />
        <div className="rounded-lg border border-border bg-background p-2.5">
          <p className="text-xs font-semibold">
            Modèle {m.nom} <span className="font-normal text-muted-foreground">({m.epoque})</span>
          </p>
          <p className="mt-0.5 text-[11px] text-muted-foreground">
            <span className="font-semibold text-foreground">Forme : </span>
            {m.forme}
          </p>
          <p className="mt-0.5 text-[11px] text-muted-foreground">{m.limite}</p>
        </div>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 15 — Les fonctions d'un SGBD                               */
/* ------------------------------------------------------------------ */

export function FonctionsSgbd() {
  const [separe, setSepare] = useState(false);

  return (
    <div className="space-y-3">
      <JeuClassement
        aide="Quatre familles : définir la structure, manipuler les données, contrôler les accès et la concurrence, protéger et restaurer."
        libelleChoix="Fonction du SGBD"
        options={[
          { value: "def", label: "Définition des données" },
          { value: "man", label: "Manipulation des données" },
          { value: "ctrl", label: "Contrôle et confidentialité" },
          { value: "int", label: "Intégrité et concurrence" },
          { value: "sauv", label: "Sauvegarde et restauration" },
        ]}
        cas={[
          {
            enonce: "Créer la table ELEVE avec ses colonnes et ses types.",
            bonne: "def",
            pourquoi: "On décrit la STRUCTURE : c'est la fonction de définition, le LDD.",
          },
          {
            enonce: "Ajouter un nouvel élève dans la base.",
            bonne: "man",
            pourquoi: "Insérer, modifier, supprimer, interroger : la manipulation, le LMD.",
          },
          {
            enonce: "Empêcher deux secrétaires de modifier la même ligne au même instant.",
            bonne: "int",
            pourquoi:
              "C'est la gestion de la concurrence : le SGBD verrouille la ligne pendant la modification, de sorte qu'aucune des deux écritures ne soit perdue.",
          },
          {
            enonce: "Interdire aux professeurs de voir la colonne des salaires.",
            bonne: "ctrl",
            pourquoi:
              "Confidentialité et droits d'accès : GRANT et REVOKE, le LCD. Chacun ne voit que ce qui le concerne.",
          },
          {
            enonce: "Restaurer la base après une coupure de courant en pleine écriture.",
            bonne: "sauv",
            pourquoi:
              "Le SGBD tient un journal des transactions : il rejoue ou annule ce qui était en cours, et la base retrouve un état cohérent.",
          },
          {
            enonce: "Refuser une note de 25 sur 20.",
            bonne: "int",
            pourquoi:
              "Une contrainte d'intégrité, écrite dans la base et donc impossible à contourner.",
          },
          {
            enonce: "Ajouter une colonne Telephone à une table existante.",
            bonne: "def",
            pourquoi: "ALTER TABLE change la structure : définition.",
          },
          {
            enonce: "Afficher la liste des élèves de Terminale C classés par nom.",
            bonne: "man",
            pourquoi: "Un SELECT : interroger, c'est manipuler.",
          },
          {
            enonce: "Refuser d'affecter un élève à une classe qui n'existe pas.",
            bonne: "int",
            pourquoi:
              "L'intégrité référentielle, assurée par la clé étrangère. C'est la base qui refuse, pas le programme de saisie.",
          },
          {
            enonce:
              "Donner au censeur le droit de modifier les notes, mais pas de supprimer un élève.",
            bonne: "ctrl",
            pourquoi:
              "Des droits accordés opération par opération : GRANT UPDATE sans GRANT DELETE.",
          },
        ]}
      />

      <button
        type="button"
        onClick={() => setSepare((v) => !v)}
        className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
      >
        {separe ? "Masquer" : "Voir le moteur et l'interface travailler séparément"}
      </button>

      {separe ? (
        <div className="space-y-2">
          <div className="rounded-lg border border-border bg-background p-2.5">
            <p className="text-xs font-semibold">
              Une même demande : « donne-moi les élèves de Terminale C »
            </p>
            <ol className="mt-1.5 space-y-1">
              <li className="text-[11px] text-muted-foreground">
                <span className="font-semibold text-foreground">1. L&apos;interface</span> — Access,
                phpMyAdmin, ou un programme — reçoit la demande de l&apos;utilisateur et
                l&apos;écrit en SQL :{" "}
                <span className="font-mono">SELECT Nom FROM ELEVE WHERE NumClasse = 1;</span>
              </li>
              <li className="text-[11px] text-muted-foreground">
                <span className="font-semibold text-foreground">2. Le moteur</span> reçoit le SQL.
                Il vérifie les droits de l&apos;utilisateur, choisit comment lire les données, les
                lit sur le disque, et renvoie le résultat.
              </li>
              <li className="text-[11px] text-muted-foreground">
                <span className="font-semibold text-foreground">3. L&apos;interface</span> met le
                résultat en forme : un tableau, un état imprimable, un graphique.
              </li>
            </ol>
          </div>
          <Verdict tone="ok">
            Un <strong>SGBD</strong> se compose donc de deux parties : le <strong>moteur</strong>,
            qui gère les données et ne se voit jamais, et l&apos;<strong>interface</strong>, qui
            parle à l&apos;utilisateur. MySQL est un moteur, phpMyAdmin une interface. Access
            contient les deux dans un seul logiciel, et c&apos;est ce qui le rend si pratique pour
            apprendre.
          </Verdict>
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 15 — Anatomie d'une table                                  */
/* ------------------------------------------------------------------ */

const BASE_MAGASIN: Base = [
  {
    nom: "MAGASIN",
    cols: [
      { nom: "NumMag", type: "INT", pk: true },
      { nom: "Ville", type: "VARCHAR(30)" },
    ],
    lignes: [
      { NumMag: 1, Ville: "Douala" },
      { NumMag: 2, Ville: "Yaoundé" },
    ],
  },
  {
    nom: "ARTICLE",
    cols: [
      { nom: "Reference", type: "VARCHAR(10)", pk: true },
      { nom: "Designation", type: "VARCHAR(40)" },
      { nom: "Prix", type: "INT" },
      {
        nom: "Note",
        type: "INT",
        check: { min: 0, max: 20, texte: "la note doit être entre 0 et 20" },
      },
      { nom: "NumMag", type: "INT", fk: { table: "MAGASIN", col: "NumMag" } },
    ],
    lignes: [
      { Reference: "A001", Designation: "Marteau", Prix: 3500, Note: 14, NumMag: 1 },
      { Reference: "A002", Designation: "Scie", Prix: 7000, Note: 16, NumMag: 2 },
      { Reference: "A003", Designation: "Clous (boîte)", Prix: 1200, Note: 11, NumMag: 1 },
    ],
  },
];

const FAUTIVES = [
  "INSERT INTO ARTICLE VALUES ('A001', 'Pince', 4000, 12, 1);",
  "INSERT INTO ARTICLE VALUES (NULL, 'Pince', 4000, 12, 1);",
  "INSERT INTO ARTICLE VALUES ('A004', 'Pince', 4000, 12, 9);",
  "INSERT INTO ARTICLE VALUES ('A005', 'Pince', 4000, 25, 1);",
  "INSERT INTO ARTICLE VALUES ('A006', 'Pince', 4000, 15, 2);",
] as const;

export function StructureTable() {
  const [base, setBase] = useState<Base>(BASE_MAGASIN);
  const [designe, setDesigne] = useState<string | null>(null);
  const [journal, setJournal] = useState<{ sql: string; ok: boolean; msg: string }[]>([]);

  const nommer = (c: Col, nomTable: string) => {
    const quoi = c.pk
      ? "une CLÉ PRIMAIRE"
      : c.fk
        ? `une CLÉ ÉTRANGÈRE, qui référence ${c.fk.table}(${c.fk.col})`
        : "un CHAMP ordinaire, ou attribut";
    const detail = c.pk
      ? "Elle identifie chaque enregistrement sans ambiguïté : unique, non vide, et de préférence stable."
      : c.fk
        ? "Elle reprend la clé primaire d'une autre table pour établir le lien. Sa valeur doit exister là-bas."
        : `Son type est ${c.type}${c.check ? `, et une règle de validation impose que ${c.check.texte}` : ""}.`;
    setDesigne(`Dans ${nomTable}, la colonne « ${c.nom} » est ${quoi}. ${detail}`);
  };

  const lancer = (sql: string) => {
    const r = executer(base, sql);
    setBase(r.base);
    setJournal((j) => [...j, { sql, ok: r.ok, msg: r.message }]);
  };

  return (
    <div className="space-y-3">
      <p className="text-xs font-medium text-muted-foreground">
        Clique un en-tête de colonne, ou une ligne
      </p>

      {base.map((t) => (
        <VueTable
          key={t.nom}
          table={t}
          onClicCol={(c) => nommer(c, t.nom)}
          onClicLigne={(i) =>
            setDesigne(
              `Dans ${t.nom}, la ligne ${i + 1} est un ENREGISTREMENT, ou tuple : l'ensemble des valeurs décrivant un même objet du réel. Une table est un ensemble d'enregistrements, et son nombre de colonnes ne change pas d'une ligne à l'autre.`,
            )
          }
        />
      ))}

      {designe ? (
        <Verdict tone="ok">{designe}</Verdict>
      ) : (
        <Verdict tone="warn">
          Les en-têtes soulignés en bleu portent une clé, ceux en italique ambre une clé étrangère.
          Clique-les pour que la simulation les nomme.
        </Verdict>
      )}

      <div className="space-y-1.5 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">
          Essaie d&apos;ajouter des lignes fautives
        </p>
        {FAUTIVES.map((f) => (
          <button
            key={f}
            type="button"
            onClick={() => lancer(f)}
            className="block w-full rounded-lg border border-border bg-background px-2.5 py-1.5 text-left font-mono text-[10px] text-muted-foreground hover:bg-secondary/60"
          >
            {f}
          </button>
        ))}
      </div>

      {journal.length > 0 ? (
        <div className="space-y-1 rounded-lg bg-slate-900 p-3">
          {journal.slice(-5).map((j, k) => (
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

      <Panel>
        <Stat label="Requêtes lancées" value={`${journal.length}`} />
        <Stat
          label="Refusées par une contrainte"
          value={`${journal.filter((j) => !j.ok).length}`}
          color={PALETTE.red}
        />
      </Panel>

      {journal.length >= 4 ? (
        <Verdict tone="ok">
          Quatre refus, quatre contraintes différentes : <strong>PRIMARY KEY</strong> pour le
          doublon, <strong>NOT NULL</strong> pour la clé vide, <strong>FOREIGN KEY</strong> pour le
          magasin inexistant, et la <strong>règle de validation</strong> pour la note de 25.
          C&apos;est la base elle-même qui refuse, sans qu&apos;aucun programme ait eu à vérifier
          quoi que ce soit — et c&apos;est précisément ce qu&apos;un fichier tableur ne sait pas
          faire.
        </Verdict>
      ) : null}
    </div>
  );
}
