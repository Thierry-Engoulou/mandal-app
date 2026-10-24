import { useMemo, useState } from "react";
import { Choice, Ctrl, PALETTE, Panel, Stat, Verdict } from "./controls";

/** Informatique Terminale C et D — chapitres 5 et 6 : le tableur. */

/* ================================================================== */
/* Un mini-tableur : grille, références, et les sept fonctions         */
/* ================================================================== */

type Val = number | string | boolean;

const LETTRES = ["A", "B", "C", "D", "E", "F"] as const;

function nomColonne(i: number) {
  return LETTRES[i] ?? "?";
}

function indexColonne(l: string) {
  return LETTRES.indexOf(l as (typeof LETTRES)[number]);
}

/** Grille de valeurs : grille[ligne][colonne], la ligne 0 étant la ligne 1. */
type Grille = ReadonlyArray<ReadonlyArray<Val>>;

function lire(g: Grille, ref: string): Val {
  const m = /^([A-F])(\d+)$/.exec(ref.toUpperCase());
  if (!m) return "#REF!";
  const c = indexColonne(m[1] ?? "");
  const l = Number(m[2] ?? "0") - 1;
  const ligne = g[l];
  if (!ligne || c < 0) return "#REF!";
  return ligne[c] ?? "";
}

function plage(g: Grille, ref: string): { refs: string[]; vals: Val[] } {
  const m = /^([A-F])(\d+):([A-F])(\d+)$/.exec(ref.toUpperCase());
  if (!m) return { refs: [], vals: [] };
  const c1 = indexColonne(m[1] ?? "");
  const l1 = Number(m[2] ?? "0");
  const c2 = indexColonne(m[3] ?? "");
  const l2 = Number(m[4] ?? "0");
  const refs: string[] = [];
  const vals: Val[] = [];
  for (let l = Math.min(l1, l2); l <= Math.max(l1, l2); l++) {
    for (let c = Math.min(c1, c2); c <= Math.max(c1, c2); c++) {
      const r = `${nomColonne(c)}${l}`;
      refs.push(r);
      vals.push(lire(g, r));
    }
  }
  return { refs, vals };
}

function nombres(vals: ReadonlyArray<Val>): number[] {
  return vals.filter((v): v is number => typeof v === "number");
}

/** Le critère d'un NB.SI ou d'un SOMME.SI : ">=10", "<5", "Douala". */
function teste(v: Val, critere: string): boolean {
  const c = critere.trim();
  const ops = [">=", "<=", "<>", ">", "<", "="] as const;
  for (const op of ops) {
    if (c.startsWith(op)) {
      const reste = c.slice(op.length).trim();
      const n = Number(reste);
      if (typeof v === "number" && !Number.isNaN(n)) {
        if (op === ">=") return v >= n;
        if (op === "<=") return v <= n;
        if (op === ">") return v > n;
        if (op === "<") return v < n;
        if (op === "=") return v === n;
        return v !== n;
      }
      if (op === "=") return String(v) === reste;
      if (op === "<>") return String(v) !== reste;
      return false;
    }
  }
  return String(v).toLowerCase() === c.toLowerCase();
}

/* ------------------------------------------------------------------ */
/* Analyse d'une formule                                               */
/* ------------------------------------------------------------------ */

type Jeton = { t: "nb" | "txt" | "ref" | "pl" | "fn" | "op" | "par" | "sep"; v: string };

function decouper(src: string): Jeton[] {
  const out: Jeton[] = [];
  let i = 0;
  while (i < src.length) {
    const c = src[i] ?? "";
    if (c === " ") {
      i++;
      continue;
    }
    if (c === '"') {
      let j = i + 1;
      let s = "";
      while (j < src.length && src[j] !== '"') {
        s += src[j];
        j++;
      }
      out.push({ t: "txt", v: s });
      i = j + 1;
      continue;
    }
    const reste = src.slice(i);
    const mPl = /^([A-Fa-f]\d+:[A-Fa-f]\d+)/.exec(reste);
    if (mPl) {
      out.push({ t: "pl", v: (mPl[1] ?? "").toUpperCase() });
      i += (mPl[1] ?? "").length;
      continue;
    }
    const mFn = /^([A-Za-z]+(?:\.[A-Za-z]+)?)\s*\(/.exec(reste);
    if (mFn) {
      out.push({ t: "fn", v: (mFn[1] ?? "").toUpperCase() });
      i += (mFn[1] ?? "").length;
      continue;
    }
    const mRef = /^([A-Fa-f]\$?\d+|\$[A-Fa-f]\$?\d+)/.exec(reste);
    if (mRef) {
      out.push({ t: "ref", v: (mRef[1] ?? "").toUpperCase().replace(/\$/g, "") });
      i += (mRef[1] ?? "").length;
      continue;
    }
    const mNb = /^(\d+(?:[.,]\d+)?)/.exec(reste);
    if (mNb) {
      out.push({ t: "nb", v: (mNb[1] ?? "").replace(",", ".") });
      i += (mNb[1] ?? "").length;
      continue;
    }
    const mOp = /^(>=|<=|<>|[+\-*/><=])/.exec(reste);
    if (mOp) {
      out.push({ t: "op", v: mOp[1] ?? "" });
      i += (mOp[1] ?? "").length;
      continue;
    }
    if (c === "(" || c === ")") {
      out.push({ t: "par", v: c });
      i++;
      continue;
    }
    if (c === ";") {
      out.push({ t: "sep", v: ";" });
      i++;
      continue;
    }
    out.push({ t: "op", v: c });
    i++;
  }
  return out;
}

type Resultat = { valeur: Val; eclairees: string[]; erreur?: string };

function evaluer(formule: string, g: Grille): Resultat {
  const src = formule.trim();
  const eclairees: string[] = [];

  if (!src.startsWith("=")) {
    return {
      valeur: src,
      eclairees,
      erreur:
        src.length > 0 ? "Sans le signe = en tête, le tableur garde cela comme du texte." : "",
    };
  }

  const jetons = decouper(src.slice(1));
  let p = 0;
  let erreur = "";

  const voir = () => jetons[p];

  function args(): Val[][] {
    // on est juste après un nom de fonction, le '(' suit
    const t = voir();
    if (!t || t.t !== "par" || t.v !== "(") {
      erreur = "Il manque la parenthèse ouvrante de la fonction.";
      return [];
    }
    p++;
    const liste: Val[][] = [];
    let courant: Val[] = [];
    let profondeur = 0;
    while (p < jetons.length) {
      const j = jetons[p];
      if (!j) break;
      if (j.t === "par" && j.v === "(") profondeur++;
      if (j.t === "par" && j.v === ")") {
        if (profondeur === 0) {
          p++;
          liste.push(courant);
          return liste;
        }
        profondeur--;
      }
      if (j.t === "sep" && profondeur === 0) {
        p++;
        liste.push(courant);
        courant = [];
        continue;
      }
      if (j.t === "pl") {
        const { refs, vals } = plage(g, j.v);
        eclairees.push(...refs);
        // une plage brute occupe tout l'argument
        courant = vals;
        p++;
        continue;
      }
      const v = expr();
      courant.push(v);
    }
    erreur = "Il manque la parenthèse fermante.";
    return liste;
  }

  function primaire(): Val {
    const t = voir();
    if (!t) return 0;
    if (t.t === "nb") {
      p++;
      return Number(t.v);
    }
    if (t.t === "txt") {
      p++;
      return t.v;
    }
    if (t.t === "ref") {
      p++;
      eclairees.push(t.v);
      return lire(g, t.v);
    }
    if (t.t === "pl") {
      p++;
      const { refs, vals } = plage(g, t.v);
      eclairees.push(...refs);
      return nombres(vals).reduce((a, b) => a + b, 0);
    }
    if (t.t === "fn") {
      const nom = t.v;
      p++;
      const a = args();
      return appliquer(nom, a);
    }
    if (t.t === "par" && t.v === "(") {
      p++;
      const v = expr();
      const f = voir();
      if (f && f.t === "par" && f.v === ")") p++;
      return v;
    }
    if (t.t === "op" && t.v === "-") {
      p++;
      const v = primaire();
      return typeof v === "number" ? -v : 0;
    }
    p++;
    return 0;
  }

  function terme(): Val {
    let g1 = primaire();
    for (;;) {
      const t = voir();
      if (!t || t.t !== "op" || (t.v !== "*" && t.v !== "/")) return g1;
      p++;
      const d = primaire();
      const a = typeof g1 === "number" ? g1 : 0;
      const b = typeof d === "number" ? d : 0;
      if (t.v === "/" && b === 0) {
        erreur = "Division par zéro : le tableur afficherait #DIV/0!.";
        return "#DIV/0!";
      }
      g1 = t.v === "*" ? a * b : a / b;
    }
  }

  function somme(): Val {
    let g1 = terme();
    for (;;) {
      const t = voir();
      if (!t || t.t !== "op" || (t.v !== "+" && t.v !== "-")) return g1;
      p++;
      const d = terme();
      const a = typeof g1 === "number" ? g1 : 0;
      const b = typeof d === "number" ? d : 0;
      g1 = t.v === "+" ? a + b : a - b;
    }
  }

  function expr(): Val {
    const g1 = somme();
    const t = voir();
    if (t && t.t === "op" && [">=", "<=", "<>", ">", "<", "="].includes(t.v)) {
      p++;
      const d = somme();
      if (typeof g1 === "number" && typeof d === "number") {
        if (t.v === ">=") return g1 >= d;
        if (t.v === "<=") return g1 <= d;
        if (t.v === ">") return g1 > d;
        if (t.v === "<") return g1 < d;
        if (t.v === "=") return g1 === d;
        return g1 !== d;
      }
      if (t.v === "=") return String(g1) === String(d);
      if (t.v === "<>") return String(g1) !== String(d);
      return false;
    }
    return g1;
  }

  function appliquer(nom: string, a: Val[][]): Val {
    const a0 = a[0] ?? [];
    const a1 = a[1] ?? [];
    const a2 = a[2] ?? [];
    const plats = a.flat();

    if (nom === "SOMME") return nombres(plats).reduce((x, y) => x + y, 0);
    if (nom === "PRODUIT") return nombres(plats).reduce((x, y) => x * y, 1);
    if (nom === "MOYENNE") {
      const n = nombres(plats);
      if (n.length === 0) {
        erreur = "MOYENNE sur une plage sans nombre : #DIV/0!.";
        return "#DIV/0!";
      }
      return n.reduce((x, y) => x + y, 0) / n.length;
    }
    if (nom === "SI") {
      const cond = a0[0];
      const vrai = a1[0] ?? "VRAI";
      const faux = a2[0] ?? "FAUX";
      return cond === true || cond === 1 ? vrai : faux;
    }
    if (nom === "RANG") {
      const v = a0[0];
      const ref = nombres(a1);
      const ordre = a2[0];
      if (typeof v !== "number" || ref.length === 0) return "#VALEUR!";
      const tri =
        ordre === undefined || ordre === 0
          ? [...ref].sort((x, y) => y - x)
          : [...ref].sort((x, y) => x - y);
      return tri.indexOf(v) + 1;
    }
    if (nom === "NB.SI") {
      const c = String(a1[0] ?? "");
      return a0.filter((v) => teste(v, c)).length;
    }
    if (nom === "SOMME.SI") {
      const c = String(a1[0] ?? "");
      const cible = a2.length > 0 ? a2 : a0;
      let s = 0;
      a0.forEach((v, k) => {
        if (teste(v, c)) {
          const w = cible[k];
          if (typeof w === "number") s += w;
        }
      });
      return s;
    }
    erreur = `La fonction ${nom} n'est pas au programme de Terminale. Les sept sont SOMME, PRODUIT, MOYENNE, SI, RANG, NB.SI et SOMME.SI.`;
    return "#NOM?";
  }

  const v = expr();
  const sortie: Resultat = { valeur: v, eclairees };
  if (erreur) sortie.erreur = erreur;
  return sortie;
}

/* ------------------------------------------------------------------ */
/* Affichage d'une grille                                             */
/* ------------------------------------------------------------------ */

function Feuille({
  grille,
  colonnes,
  eclairees = [],
  selection,
  onClic,
  bordures = true,
  fusionA1,
  vertical = false,
  retourLigne = false,
}: {
  grille: Grille;
  colonnes: number;
  eclairees?: ReadonlyArray<string>;
  selection?: string | undefined;
  onClic?: ((ref: string) => void) | undefined;
  bordures?: boolean;
  fusionA1?: string | undefined;
  vertical?: boolean;
  retourLigne?: boolean;
}) {
  const bord = bordures ? "border border-border" : "border border-transparent";
  return (
    <div className="overflow-x-auto">
      <table className="border-collapse text-[11px]">
        <thead>
          <tr>
            <th className="w-7 border border-border bg-secondary/60" />
            {Array.from({ length: colonnes }, (_, c) => (
              <th
                key={nomColonne(c)}
                className="min-w-[56px] border border-border bg-secondary/60 px-1.5 py-0.5 font-medium"
              >
                {nomColonne(c)}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {grille.map((ligne, l) => (
            <tr key={`l${l + 1}`}>
              <td className="border border-border bg-secondary/60 px-1 text-center font-medium">
                {l + 1}
              </td>
              {l === 0 && fusionA1 ? (
                <td
                  colSpan={colonnes}
                  className={`${bord} bg-primary/10 px-1.5 py-1 text-center font-semibold`}
                >
                  {fusionA1}
                </td>
              ) : (
                Array.from({ length: colonnes }, (_, c) => {
                  const ref = `${nomColonne(c)}${l + 1}`;
                  const v = ligne[c] ?? "";
                  const chaud = eclairees.includes(ref);
                  const sel = selection === ref;
                  const texte =
                    typeof v === "number"
                      ? v.toLocaleString("fr-FR", { maximumFractionDigits: 6 })
                      : String(v);
                  return (
                    <td
                      key={ref}
                      onClick={onClic ? () => onClic(ref) : undefined}
                      className={`${bord} px-1.5 py-0.5 ${
                        sel ? "outline outline-2 outline-primary" : chaud ? "bg-amber-400/25" : ""
                      } ${typeof v === "number" ? "text-right font-mono" : "text-left"} ${
                        onClic ? "cursor-pointer" : ""
                      } ${
                        vertical && l === 1
                          ? "align-bottom [writing-mode:vertical-rl] [text-orientation:mixed]"
                          : ""
                      } ${retourLigne ? "max-w-[90px] whitespace-normal" : "whitespace-nowrap"}`}
                    >
                      {texte}
                    </td>
                  );
                })
              )}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 5 — Cellule, plage, feuilles du classeur                   */
/* ------------------------------------------------------------------ */

const FEUILLES = [
  { nom: "Trimestre1", b2: 12.5 },
  { nom: "Trimestre2", b2: 14 },
  { nom: "Trimestre3", b2: 11.75 },
] as const;

const CIBLES = ["C3", "A1", "E4", "B5", "D2"] as const;

export function ClasseurFeuille() {
  const [feuille, setFeuille] = useState(0);
  const [cible, setCible] = useState(0);
  const [clic, setClic] = useState<string | null>(null);
  const [coin1, setCoin1] = useState<string | null>(null);
  const [coin2, setCoin2] = useState<string | null>(null);
  const [mode, setMode] = useState<"cellule" | "plage">("cellule");

  const f = FEUILLES[feuille] ?? FEUILLES[0];
  const attendue = CIBLES[cible] ?? "A1";

  const grille: Grille = useMemo(() => {
    const g: Val[][] = [];
    for (let l = 1; l <= 5; l++) {
      const ligne: Val[] = [];
      for (let c = 0; c < 5; c++) {
        if (l === 2 && c === 1) ligne.push(f.b2);
        else ligne.push("");
      }
      g.push(ligne);
    }
    return g;
  }, [f.b2]);

  const sel = mode === "plage" && coin1 && coin2 ? `${coin1}:${coin2}` : (clic ?? undefined);
  const refsPlage =
    mode === "plage" && coin1 && coin2 ? plage(grille, `${coin1}:${coin2}`).refs : [];

  const juste = clic === attendue;

  return (
    <div className="space-y-3">
      <Choice<"cellule" | "plage">
        label="Ce qu'on te demande de désigner"
        value={mode}
        options={[
          { value: "cellule", label: "Une cellule" },
          { value: "plage", label: "Une plage" },
        ]}
        onChange={(v) => {
          setMode(v);
          setClic(null);
          setCoin1(null);
          setCoin2(null);
        }}
      />

      {mode === "cellule" ? (
        <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2">
          <p className="text-sm font-medium">
            Clique sur la cellule <span className="font-mono">{attendue}</span>
          </p>
          <p className="text-[11px] text-muted-foreground">
            La lettre donne la colonne, le chiffre donne la ligne. Toujours dans cet ordre.
          </p>
        </div>
      ) : (
        <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2">
          <p className="text-sm font-medium">
            Clique les deux coins d&apos;une plage, en haut à gauche puis en bas à droite
          </p>
          <p className="text-[11px] text-muted-foreground">
            Une plage s&apos;écrit avec le signe deux-points entre ses deux coins.
          </p>
        </div>
      )}

      <Feuille
        grille={grille}
        colonnes={5}
        selection={sel}
        eclairees={refsPlage}
        onClic={(r) => {
          if (mode === "cellule") {
            setClic(r);
          } else if (coin1 === null || coin2 !== null) {
            setCoin1(r);
            setCoin2(null);
          } else {
            setCoin2(r);
          }
        }}
      />

      <div className="flex flex-wrap gap-1.5">
        {FEUILLES.map((x, k) => (
          <button
            key={x.nom}
            type="button"
            onClick={() => setFeuille(k)}
            className={
              k === feuille
                ? "rounded-t-lg border border-b-0 border-border bg-background px-3 py-1 text-xs font-semibold"
                : "rounded-t-lg border border-border bg-secondary/60 px-3 py-1 text-xs text-muted-foreground hover:bg-secondary"
            }
          >
            {x.nom}
          </button>
        ))}
      </div>

      <Panel>
        <Stat
          label="Zone Nom"
          value={mode === "plage" ? (sel ?? "—") : (clic ?? "—")}
          color={PALETTE.blue}
        />
        <Stat label="Feuille active" value={f.nom} />
      </Panel>

      {mode === "cellule" ? (
        clic === null ? (
          <Verdict tone="warn">
            Repère la colonne {attendue.slice(0, 1)} en haut, la ligne {attendue.slice(1)} à gauche,
            et clique à leur croisement.
          </Verdict>
        ) : juste ? (
          <Verdict tone="ok">
            C&apos;est bien {attendue}. Remarque la <strong>Zone Nom</strong> en haut à gauche :
            elle affiche toujours la référence de la cellule active, et c&apos;est là qu&apos;on lit
            la réponse quand on ne sait plus.
          </Verdict>
        ) : (
          <Verdict tone="bad">
            Tu as cliqué {clic}, on demandait {attendue}. La <strong>lettre d&apos;abord</strong>,
            le chiffre ensuite : {attendue} est à la colonne {attendue.slice(0, 1)}, ligne{" "}
            {attendue.slice(1)}.
          </Verdict>
        )
      ) : coin1 && coin2 ? (
        <Verdict tone="ok">
          Ta plage s&apos;écrit{" "}
          <span className="font-mono">
            {coin1}:{coin2}
          </span>{" "}
          et contient {refsPlage.length} cellules. C&apos;est cette écriture qu&apos;attendent
          SOMME, MOYENNE et toutes les fonctions à plage.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          {coin1
            ? `Premier coin : ${coin1}. Clique maintenant le coin opposé.`
            : "Clique le premier coin."}
        </Verdict>
      )}

      <button
        type="button"
        onClick={() => {
          setCible((v) => (v + 1) % CIBLES.length);
          setClic(null);
        }}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        Autre cellule à trouver
      </button>

      <div className="rounded-lg border border-border bg-background p-3 text-[11px] text-muted-foreground">
        Les trois onglets du bas sont trois <strong>feuilles</strong> d&apos;un même{" "}
        <strong>classeur</strong>. Clique-les : la cellule B2 vaut{" "}
        {FEUILLES.map((x) => `${x.b2.toLocaleString("fr-FR")} dans ${x.nom}`).join(", ")}. Même
        référence, trois valeurs — c&apos;est pourquoi une référence entre feuilles doit préciser la
        feuille : <span className="font-mono">Trimestre1!B2</span>.
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 5 — Mettre en forme un bulletin                            */
/* ------------------------------------------------------------------ */

const BULLETIN_BRUT: Grille = [
  ["BULLETIN DU PREMIER TRIMESTRE", "", "", "", ""],
  ["Matière", "Note sur vingt", "Coefficient", "Note pondérée", "Appréciation du professeur"],
  ["Mathématiques", 14, 6, 84, "Travail sérieux et régulier"],
  ["Physique", 11.5, 5, 57.5, "Peut mieux faire à l'écrit"],
  ["Informatique", 16, 3, 48, "Très bonne maîtrise"],
  ["Français", 12, 3, 36, "Correct"],
];

export function MiseEnFormeCellule() {
  const [bordures, setBordures] = useState(false);
  const [fusion, setFusion] = useState(false);
  const [vertical, setVertical] = useState(false);
  const [retour, setRetour] = useState(false);
  const [apercu, setApercu] = useState(false);

  const outils = [
    { id: "b", label: "Bordures", on: bordures, set: setBordures },
    { id: "f", label: "Fusionner A1:E1", on: fusion, set: setFusion },
    { id: "v", label: "Texte vertical (ligne 2)", on: vertical, set: setVertical },
    { id: "r", label: "Retour à la ligne", on: retour, set: setRetour },
  ] as const;

  const faits = outils.filter((o) => o.on).length;

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-1.5">
        {outils.map((o) => (
          <button
            key={o.id}
            type="button"
            onClick={() => o.set(!o.on)}
            className={
              o.on
                ? "rounded-lg border border-emerald-500/50 bg-emerald-500/10 px-2.5 py-1.5 text-xs font-medium text-emerald-700"
                : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            }
          >
            {o.label}
          </button>
        ))}
        <button
          type="button"
          onClick={() => setApercu((v) => !v)}
          className="rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          {apercu ? "Revenir à la feuille" : "Aperçu avant impression"}
        </button>
      </div>

      <div
        className={
          apercu
            ? "rounded-lg border-2 border-dashed border-slate-400 bg-white p-4 shadow-inner"
            : "rounded-lg border border-border bg-background p-2"
        }
      >
        {apercu ? (
          <p className="mb-2 text-[10px] uppercase tracking-wide text-slate-500">
            Ce qui sortira sur le papier
          </p>
        ) : null}
        <Feuille
          grille={BULLETIN_BRUT}
          colonnes={5}
          bordures={apercu ? bordures : true}
          fusionA1={fusion ? "BULLETIN DU PREMIER TRIMESTRE" : undefined}
          vertical={vertical}
          retourLigne={retour}
        />
      </div>

      <Panel>
        <Stat label="Outils appliqués" value={`${faits} / 4`} />
        <Stat
          label="Lisible à l'impression"
          value={bordures ? "oui" : "non"}
          color={bordures ? PALETTE.green : PALETTE.red}
        />
      </Panel>

      {apercu && !bordures ? (
        <Verdict tone="bad">
          Regarde bien : sur le papier, le tableau a disparu. Les lignes grises que tu vois à
          l&apos;écran sont le <strong>quadrillage</strong>, et le quadrillage ne s&apos;imprime
          pas. Les <strong>bordures</strong>, elles, s&apos;impriment. C&apos;est la différence
          qu&apos;on demande en examen, et c&apos;est celle qu&apos;on découvre toujours trop tard,
          une fois les cent bulletins sortis.
        </Verdict>
      ) : apercu && bordures ? (
        <Verdict tone="ok">
          Avec les bordures, le tableau existe sur le papier.{" "}
          {fusion
            ? "Le titre fusionné est centré sur toute la largeur : c'est à cela que sert la fusion."
            : "Essaie maintenant la fusion : le titre sera centré sur les cinq colonnes au lieu de déborder."}
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Applique les outils, puis demande l&apos;aperçu avant impression. L&apos;écran et le
          papier ne montrent pas la même chose, et c&apos;est tout l&apos;objet de cette simulation.
        </Verdict>
      )}

      <div className="space-y-1 rounded-lg border border-border bg-background p-3 text-[11px] text-muted-foreground">
        <p>
          <strong className="text-foreground">Bordures</strong> — elles s&apos;impriment, le
          quadrillage non.
        </p>
        <p>
          <strong className="text-foreground">Fusion</strong> — plusieurs cellules n&apos;en font
          plus qu&apos;une. Pour un titre, oui ; au milieu d&apos;un tableau de données, jamais : le
          tri et les formules s&apos;y perdent.
        </p>
        <p>
          <strong className="text-foreground">Orientation</strong> — un en-tête long dans une
          colonne étroite tient à la verticale.
        </p>
        <p>
          <strong className="text-foreground">Retour automatique à la ligne</strong> — le texte
          passe à la ligne <em>dans</em> la cellule, et la hauteur de ligne s&apos;ajuste. Sans lui,
          une appréciation longue est coupée net.
        </p>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 5 — Zone d'impression et protection                        */
/* ------------------------------------------------------------------ */

const FEUILLE_LONGUE: Grille = [
  ["BULLETIN", "", "", ""],
  ["Matière", "Note", "Coef", "Pondérée"],
  ["Mathématiques", 14, 6, 84],
  ["Physique", 11.5, 5, 57.5],
  ["Informatique", 16, 3, 48],
  ["Total", "", 17, 189],
  ["Moyenne", 11.12, "", ""],
  ["", "", "", ""],
  ["— calculs intermédiaires —", "", "", ""],
  ["somme coef", 17, "", ""],
  ["somme pondérée", 189, "", ""],
  ["contrôle", "OK", "", ""],
];

export function ZoneImpression() {
  const [zone, setZone] = useState("A1:D12");
  const [orientation, setOrientation] = useState<"portrait" | "paysage">("portrait");
  const [echelle, setEchelle] = useState(100);
  const [protege, setProtege] = useState(false);
  const [deverrouillees, setDeverrouillees] = useState<string[]>([]);
  const [essai, setEssai] = useState<string | null>(null);

  const refs = plage(FEUILLE_LONGUE, zone).refs;
  const lignesImprimees = new Set(refs.map((r) => Number(r.slice(1))));
  const fuite = [9, 10, 11, 12].some((l) => lignesImprimees.has(l));

  const largeurUtile = orientation === "portrait" ? 4 : 6;
  const colonnesZone = /^([A-F])\d+:([A-F])\d+$/.exec(zone);
  const nbCol = colonnesZone
    ? indexColonne(colonnesZone[2] ?? "A") - indexColonne(colonnesZone[1] ?? "A") + 1
    : 4;
  const tientEnLarge = nbCol * (100 / echelle) <= largeurUtile;

  const grilleVue: Grille = FEUILLE_LONGUE.filter((_, l) => lignesImprimees.has(l + 1));

  const essaiFormule = essai !== null && !deverrouillees.includes(essai);

  return (
    <div className="space-y-4">
      <div className="space-y-2">
        <Choice<string>
          label="Zone d'impression"
          value={zone}
          options={[
            { value: "A1:D12", label: "Toute la feuille" },
            { value: "A1:D7", label: "A1:D7 — le bulletin seul" },
            { value: "A2:D6", label: "A2:D6 — le tableau sans titre" },
          ]}
          onChange={setZone}
        />
        <Choice<"portrait" | "paysage">
          label="Orientation"
          value={orientation}
          options={[
            { value: "portrait", label: "Portrait" },
            { value: "paysage", label: "Paysage" },
          ]}
          onChange={setOrientation}
        />
        <Ctrl
          label="Mise à l'échelle"
          value={echelle}
          min={50}
          max={130}
          step={5}
          onChange={setEchelle}
          display={`${echelle} %`}
        />
      </div>

      <div className="rounded-lg border-2 border-dashed border-slate-400 bg-white p-3">
        <p className="mb-2 text-[10px] uppercase tracking-wide text-slate-500">
          Aperçu — page 1, {orientation}, {echelle} %
        </p>
        <div style={{ fontSize: `${Math.max(70, echelle)}%` }}>
          <Feuille grille={grilleVue} colonnes={4} />
        </div>
      </div>

      <Panel>
        <Stat label="Lignes imprimées" value={`${lignesImprimees.size}`} />
        <Stat
          label="Calculs intermédiaires"
          value={fuite ? "ils sortent !" : "exclus"}
          color={fuite ? PALETTE.red : PALETTE.green}
        />
      </Panel>

      {fuite ? (
        <Verdict tone="bad">
          Les lignes de calculs intermédiaires sortent sur le papier. Personne n&apos;a besoin de
          voir « somme coef » et « contrôle » sur un bulletin remis aux parents. Choisis la zone{" "}
          <span className="font-mono">A1:D7</span>.
        </Verdict>
      ) : tientEnLarge ? (
        <Verdict tone="ok">
          La zone est propre et tient sur une page en {orientation}. C&apos;est exactement le
          réglage à décrire en examen :{" "}
          <strong>Mise en page → Zone d&apos;impression → Définir</strong>, puis l&apos;orientation,
          puis l&apos;échelle si nécessaire.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          À {echelle} %, le tableau débordera sur une seconde page. Deux solutions : passer en
          paysage, ou réduire l&apos;échelle. Mieux vaut réduire un peu que couper un tableau en
          deux.
        </Verdict>
      )}

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">
          Protéger la feuille : on déverrouille d&apos;abord, on protège ensuite
        </p>
        <div className="flex flex-wrap gap-1.5">
          {["B3", "B4", "B5"].map((r) => (
            <button
              key={r}
              type="button"
              onClick={() =>
                setDeverrouillees((v) => (v.includes(r) ? v.filter((x) => x !== r) : [...v, r]))
              }
              className={
                deverrouillees.includes(r)
                  ? "rounded-lg border border-emerald-500/50 bg-emerald-500/10 px-2.5 py-1.5 font-mono text-xs text-emerald-700"
                  : "rounded-lg border border-border bg-background px-2.5 py-1.5 font-mono text-xs text-muted-foreground hover:bg-secondary/60"
              }
            >
              Déverrouiller {r}
            </button>
          ))}
          <button
            type="button"
            onClick={() => setProtege((v) => !v)}
            className={
              protege
                ? "rounded-lg bg-rose-600 px-2.5 py-1.5 text-xs font-semibold text-white"
                : "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
            }
          >
            {protege ? "Ôter la protection" : "Protéger la feuille"}
          </button>
        </div>

        <div className="flex flex-wrap gap-1.5">
          {["B3", "D3", "B7"].map((r) => (
            <button
              key={r}
              type="button"
              onClick={() => setEssai(r)}
              className="rounded-lg border border-border bg-background px-2.5 py-1.5 font-mono text-xs text-muted-foreground hover:bg-secondary/60"
            >
              Écrire dans {r}
            </button>
          ))}
        </div>

        {essai === null ? (
          <Verdict tone="warn">
            Déverrouille les cellules de saisie B3, B4 et B5, protège la feuille, puis essaie
            d&apos;écrire dans D3 — qui contient une formule.
          </Verdict>
        ) : !protege ? (
          <Verdict tone="warn">
            La feuille n&apos;est pas protégée : {essai} accepte l&apos;écriture, formule comprise.
            C&apos;est précisément le risque. Protège la feuille et réessaie.
          </Verdict>
        ) : essaiFormule ? (
          <Verdict tone="bad">
            Refusé. « La cellule que vous essayez de modifier se trouve dans une feuille protégée. »{" "}
            {essai} était verrouillée, donc intouchable. La formule est sauve — et c&apos;est tout
            l&apos;intérêt : on confie la feuille à quelqu&apos;un sans craindre qu&apos;il écrase
            un calcul.
          </Verdict>
        ) : (
          <Verdict tone="ok">
            {essai} accepte la saisie : tu l&apos;avais déverrouillée avant de protéger.
            L&apos;ordre compte — toutes les cellules sont verrouillées par défaut, et la protection
            ne fait que rendre ce verrou actif.
          </Verdict>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 6 — La recopie et le dollar                                */
/* ------------------------------------------------------------------ */

const DEVIS: Grille = [
  ["Taux de TVA", 0.1925, "", ""],
  ["Article", "Prix HT", "Quantité", "Total TTC"],
  ["Ordinateur", 250000, 2, ""],
  ["Imprimante", 120000, 1, ""],
  ["Onduleur", 65000, 3, ""],
];

function decalerRef(ref: string, dl: number): string {
  const m = /^(\$?)([A-F])(\$?)(\d+)$/.exec(ref);
  if (!m) return ref;
  const dollarL = m[3] ?? "";
  const ligne = Number(m[4] ?? "1");
  return `${m[1] ?? ""}${m[2] ?? "A"}${dollarL}${dollarL === "$" ? ligne : ligne + dl}`;
}

function recopier(formule: string, dl: number): string {
  return formule.replace(/\$?[A-F]\$?\d+/g, (r) => decalerRef(r, dl));
}

export function ReferencesCellules() {
  const [formule, setFormule] = useState("=B3*C3*(1+B1)");
  const [tire, setTire] = useState(0);
  const [onglet, setOnglet] = useState<string | null>(null);

  const lignes = [0, 1, 2].slice(0, tire + 1);

  return (
    <div className="space-y-4">
      <div className="space-y-1.5">
        <p className="text-xs font-medium text-muted-foreground">
          La formule écrite en D3, puis tirée vers le bas
        </p>
        <input
          value={formule}
          onChange={(e) => setFormule(e.target.value)}
          className="w-full rounded-lg border border-border bg-background px-2.5 py-1.5 font-mono text-xs"
        />
        <div className="flex flex-wrap gap-1.5">
          {["=B3*C3*(1+B1)", "=B3*C3*(1+$B$1)", "=SOMME(B3:B5)"].map((f) => (
            <button
              key={f}
              type="button"
              onClick={() => setFormule(f)}
              className="rounded-lg border border-border bg-background px-2 py-1 font-mono text-[10px] text-muted-foreground hover:bg-secondary/60"
            >
              {f}
            </button>
          ))}
        </div>
      </div>

      <Feuille grille={DEVIS} colonnes={4} eclairees={evaluer(formule, DEVIS).eclairees} />

      <Ctrl
        label="Tirer la poignée de recopie"
        value={tire}
        min={0}
        max={2}
        step={1}
        onChange={setTire}
        display={tire === 0 ? "D3 seule" : `jusqu'en D${3 + tire}`}
      />

      <div className="space-y-1 rounded-lg border border-border bg-background p-3">
        {lignes.map((d) => {
          const f = recopier(formule, d);
          const r = evaluer(f, DEVIS);
          return (
            <p key={`d${3 + d}`} className="font-mono text-[11px]">
              <span className="font-semibold text-foreground">D{3 + d} </span>
              <span className="text-muted-foreground">{f}</span>
              <span className="text-emerald-600">
                {" → "}
                {typeof r.valeur === "number"
                  ? r.valeur.toLocaleString("fr-FR", { maximumFractionDigits: 0 })
                  : String(r.valeur)}
              </span>
            </p>
          );
        })}
      </div>

      {formule.includes("$B$1") ? (
        <Verdict tone="ok">
          Regarde la colonne : <span className="font-mono">B3</span> et{" "}
          <span className="font-mono">C3</span> suivent la descente — elles sont{" "}
          <strong>relatives</strong> — alors que <span className="font-mono">$B$1</span> ne bouge
          pas d&apos;un millimètre. C&apos;est exactement l&apos;effet du dollar, et c&apos;est ce
          qu&apos;il fallait ici : le taux de TVA est le même pour les trois articles.
        </Verdict>
      ) : formule.includes("B1") && tire > 0 ? (
        <Verdict tone="bad">
          La référence au taux a glissé : en D4 la formule va chercher{" "}
          <span className="font-mono">B2</span>, qui contient le mot « Article », et en D5{" "}
          <span className="font-mono">B3</span>, qui contient un prix. Les totaux sont faux. Fige le
          taux : <span className="font-mono">$B$1</span>, ou touche F4.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Tire la poignée et regarde chaque référence se décaler d&apos;une ligne. C&apos;est la{" "}
          <strong>recopie incrémentée</strong>, le terme exact demandé au Baccalauréat 2023.
        </Verdict>
      )}

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">
          La référence entre feuilles : clique un onglet pour l&apos;écrire
        </p>
        <div className="flex flex-wrap gap-1.5">
          {FEUILLES.map((x) => (
            <button
              key={x.nom}
              type="button"
              onClick={() => setOnglet(x.nom)}
              className={
                onglet === x.nom
                  ? "rounded-t-lg border border-b-0 border-border bg-background px-3 py-1 text-xs font-semibold"
                  : "rounded-t-lg border border-border bg-secondary/60 px-3 py-1 text-xs text-muted-foreground hover:bg-secondary"
              }
            >
              {x.nom}
            </button>
          ))}
          <button
            type="button"
            onClick={() => setOnglet("Bilan")}
            className={
              onglet === "Bilan"
                ? "rounded-t-lg border border-b-0 border-border bg-background px-3 py-1 text-xs font-semibold"
                : "rounded-t-lg border border-border bg-secondary/60 px-3 py-1 text-xs text-muted-foreground hover:bg-secondary"
            }
          >
            Bilan
          </button>
        </div>
        <div className="rounded-lg bg-slate-900 p-3">
          <p className="mb-1 text-[10px] uppercase tracking-wide text-slate-500">
            Barre de formule de la feuille Bilan
          </p>
          <p className="font-mono text-[11px] text-emerald-400">
            {onglet === null || onglet === "Bilan" ? "=MOYENNE(" : `=MOYENNE(${onglet}!D7`}
          </p>
        </div>
        {onglet && onglet !== "Bilan" ? (
          <Verdict tone="ok">
            Le tableur a écrit <span className="font-mono">{onglet}!D7</span> tout seul : le{" "}
            <strong>nom de la feuille</strong>, un <strong>point d&apos;exclamation</strong>, la{" "}
            <strong>cellule</strong>. Continue avec les deux autres onglets et tu obtiens la formule
            de l&apos;exercice :{" "}
            <span className="font-mono">=MOYENNE(Trimestre1!D7;Trimestre2!D7;Trimestre3!D7)</span>.
          </Verdict>
        ) : (
          <Verdict tone="warn">
            Clique sur Trimestre1 : tu verras la référence s&apos;écrire sans que tu la tapes.
            C&apos;est ainsi qu&apos;on relie une feuille Bilan aux trois feuilles trimestrielles.
          </Verdict>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 6 — Les sept fonctions                                     */
/* ------------------------------------------------------------------ */

const FEUILLE_FN: Grille = [
  ["Article", "Prix unitaire", "Quantité", "Note", "Ville"],
  ["Ordinateur", 250000, 2, 14, "Douala"],
  ["Imprimante", 120000, 1, 8, "Yaoundé"],
  ["Onduleur", 65000, 3, 16, "Douala"],
  ["Scanner", 90000, 1, 11, "Garoua"],
];

const EXEMPLES_FN = [
  { f: "=SOMME(B2:B5)", quoi: "additionne les quatre prix" },
  { f: "=PRODUIT(B2;C2)", quoi: "multiplie le prix par la quantité" },
  { f: "=MOYENNE(D2:D5)", quoi: "la moyenne des notes" },
  { f: '=SI(D2>10;"ADMIS";"REFUSE")', quoi: "la fonction de décision" },
  { f: "=RANG(D2;D2:D5;0)", quoi: "le rang de la première note, ordre décroissant" },
  { f: '=NB.SI(D2:D5;">=10")', quoi: "compte les notes au moins égales à 10" },
  { f: '=SOMME.SI(C2:C5;">=2";B2:B5)', quoi: "la question du Bac 2024" },
] as const;

export function FonctionsTableur() {
  const [formule, setFormule] = useState('=SOMME.SI(C2:C5;">=2";B2:B5)');

  const res = evaluer(formule, FEUILLE_FN);
  const estSommeSi = /^=\s*SOMME\.SI/i.test(formule.trim());
  const m =
    /^=\s*SOMME\.SI\s*\(\s*([A-F]\d+:[A-F]\d+)\s*;\s*"?([^";]+)"?\s*(?:;\s*([A-F]\d+:[A-F]\d+)\s*)?\)/i.exec(
      formule.trim(),
    );
  const guillemetOublie = estSommeSi && /;\s*[<>=]/.test(formule);

  const plageTest = m?.[1] ?? "";
  const critere = m?.[2] ?? "";
  const plageSomme = m?.[3] ?? "";

  const detail =
    plageTest !== "" && critere !== ""
      ? plage(FEUILLE_FN, plageTest).refs.map((r, k) => {
          const vTest = lire(FEUILLE_FN, r);
          const refSomme = plageSomme !== "" ? (plage(FEUILLE_FN, plageSomme).refs[k] ?? "—") : r;
          const vSomme = refSomme === "—" ? "" : lire(FEUILLE_FN, refSomme);
          return {
            r,
            vTest,
            ok: teste(vTest, critere),
            refSomme,
            vSomme,
          };
        })
      : [];

  return (
    <div className="space-y-3">
      <Feuille grille={FEUILLE_FN} colonnes={5} eclairees={res.eclairees} />

      <div className="space-y-1.5">
        <p className="text-xs font-medium text-muted-foreground">Barre de formule</p>
        <input
          value={formule}
          onChange={(e) => setFormule(e.target.value)}
          className="w-full rounded-lg border border-border bg-background px-2.5 py-1.5 font-mono text-xs"
        />
        <div className="flex flex-wrap gap-1">
          {EXEMPLES_FN.map((x) => (
            <button
              key={x.f}
              type="button"
              onClick={() => setFormule(x.f)}
              title={x.quoi}
              className="rounded-lg border border-border bg-background px-2 py-1 font-mono text-[10px] text-muted-foreground hover:bg-secondary/60"
            >
              {x.f}
            </button>
          ))}
        </div>
      </div>

      <Panel>
        <Stat
          label="Résultat"
          value={
            typeof res.valeur === "number"
              ? res.valeur.toLocaleString("fr-FR", { maximumFractionDigits: 2 })
              : String(res.valeur)
          }
          color={PALETTE.green}
        />
        <Stat label="Cellules lues" value={`${res.eclairees.length}`} />
      </Panel>

      {guillemetOublie ? (
        <Verdict tone="bad">
          Le critère est écrit sans guillemets. Le tableur attend{" "}
          <span className="font-mono">&quot;&gt;=2&quot;</span> : dès qu&apos;un critère contient un
          opérateur, il se met <strong>entre guillemets</strong>. Sans eux, la formule est refusée.
        </Verdict>
      ) : res.erreur ? (
        <Verdict tone="bad">{res.erreur}</Verdict>
      ) : (
        <Verdict tone="ok">
          Les cellules lues par ta formule sont surlignées dans la feuille. Vérifie toujours que ce
          sont bien celles que tu voulais.
        </Verdict>
      )}

      {detail.length > 0 ? (
        <div className="space-y-1.5">
          <p className="text-xs font-medium text-muted-foreground">
            SOMME.SI, décomposé ligne par ligne
          </p>
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-xs">
              <thead>
                <tr>
                  <th className="border border-border bg-secondary/40 px-2 py-1">Cellule testée</th>
                  <th className="border border-border bg-secondary/40 px-2 py-1">Sa valeur</th>
                  <th className="border border-border bg-secondary/40 px-2 py-1">
                    Critère « {critere} »
                  </th>
                  <th className="border border-border bg-secondary/40 px-2 py-1">Cellule sommée</th>
                  <th className="border border-border bg-secondary/40 px-2 py-1">
                    Prise en compte
                  </th>
                </tr>
              </thead>
              <tbody>
                {detail.map((d) => (
                  <tr key={d.r} className={d.ok ? "bg-emerald-500/5" : ""}>
                    <td className="border border-border px-2 py-1 text-center font-mono">{d.r}</td>
                    <td className="border border-border px-2 py-1 text-center font-mono">
                      {String(d.vTest)}
                    </td>
                    <td
                      className="border border-border px-2 py-1 text-center font-semibold"
                      style={{ color: d.ok ? PALETTE.green : PALETTE.red }}
                    >
                      {d.ok ? "vrai" : "faux"}
                    </td>
                    <td className="border border-border px-2 py-1 text-center font-mono">
                      {d.refSomme}
                    </td>
                    <td className="border border-border px-2 py-1 text-right font-mono">
                      {d.ok && typeof d.vSomme === "number"
                        ? d.vSomme.toLocaleString("fr-FR")
                        : "—"}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <p className="text-[11px] text-muted-foreground">
            Le critère est <strong>testé sur la première plage</strong>, la somme est faite sur la{" "}
            <strong>troisième</strong>. Le piège de l&apos;examen est de sommer la colonne testée.
          </p>
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 6 — Construire le bulletin                                 */
/* ------------------------------------------------------------------ */

const LIGNES_BULLETIN = [
  { matiere: "Mathématiques", note: 14, coef: 6 },
  { matiere: "Physique", note: 11.5, coef: 5 },
  { matiere: "Informatique", note: 16, coef: 3 },
  { matiere: "Français", note: 12, coef: 3 },
] as const;

const A_REMPLIR = [
  {
    id: "d3",
    label: "D3 — la note pondérée de la première matière",
    bonnes: ["=B3*C3", "=PRODUIT(B3;C3)"],
    mauvaises: [
      { f: "=B3+C3", pourquoi: "Tu additionnes la note et le coefficient. Il faut multiplier." },
      { f: "=$B$3*$C$3", pourquoi: "Figée, elle donnerait la même valeur sur les quatre lignes." },
    ],
    aide: "La note multipliée par son coefficient, en références relatives pour pouvoir recopier.",
  },
  {
    id: "c7",
    label: "C7 — le total des coefficients",
    bonnes: ["=SOMME(C3:C6)"],
    mauvaises: [
      {
        f: "=SOMME(C3:C7)",
        pourquoi: "La plage inclut la cellule du total elle-même : référence circulaire.",
      },
      { f: "=C3+C4+C5", pourquoi: "Il manque le Français, en ligne 6." },
    ],
    aide: "SOMME sur les quatre coefficients, de la ligne 3 à la ligne 6.",
  },
  {
    id: "d7",
    label: "D7 — le total des notes pondérées",
    bonnes: ["=SOMME(D3:D6)"],
    mauvaises: [
      { f: "=MOYENNE(D3:D6)", pourquoi: "On veut le total, pas la moyenne des pondérées." },
    ],
    aide: "Même chose sur la colonne des notes pondérées.",
  },
  {
    id: "d8",
    label: "D8 — la moyenne générale",
    bonnes: ["=D7/C7"],
    mauvaises: [
      {
        f: "=MOYENNE(B3:B6)",
        pourquoi:
          "C'est la faute classique : cette formule ignore les coefficients et donne 13,38 au lieu de 13,32. Les coefficients ne servent à rien si on les oublie à la fin.",
      },
      {
        f: "=D7/4",
        pourquoi:
          "Diviser par le nombre de matières au lieu du total des coefficients : on obtient 56,88. C'est la seconde faute classique.",
      },
    ],
    aide: "Le total des pondérées divisé par le total des coefficients. Jamais par le nombre de matières.",
  },
  {
    id: "e3",
    label: "E3 — la mention de la matière",
    bonnes: ['=SI(B3>=10;"Acquis";"Non acquis")'],
    mauvaises: [
      {
        f: "=SI(B3>=10;Acquis;Non acquis)",
        pourquoi:
          "Les textes d'un SI se mettent entre guillemets, sans quoi le tableur cherche des noms de cellules.",
      },
    ],
    aide: 'La fonction SI, avec les deux textes entre guillemets : =SI(test;"vrai";"faux")',
  },
  {
    id: "f3",
    label: "F3 — le rang de l'élève dans la classe, formule recopiable",
    bonnes: ["=RANG(D8;$D$8:$D$47;0)"],
    mauvaises: [
      {
        f: "=RANG(D8;D8:D47;0)",
        pourquoi:
          "La plage n'est pas figée : recopiée, elle glisse en D9:D48, puis D10:D49, et chaque élève est classé dans une plage différente. C'est la faute que le correcteur cherche.",
      },
      {
        f: "=RANG($D$8;$D$8:$D$47;0)",
        pourquoi:
          "Le premier argument doit rester relatif : figé, chaque ligne classerait toujours le même élève.",
      },
    ],
    aide: "Premier argument relatif, plage de référence figée avec des dollars, et 0 pour l'ordre décroissant.",
  },
] as const;

export function BulletinNotes() {
  const [i, setI] = useState(0);
  const [saisie, setSaisie] = useState("");
  const [faits, setFaits] = useState<string[]>([]);

  const q = A_REMPLIR[i] ?? A_REMPLIR[0];
  const normalise = (s: string) => s.replace(/\s+/g, "").toUpperCase();
  const juste = q.bonnes.some((b) => normalise(b) === normalise(saisie));
  const connue = q.mauvaises.find((x) => normalise(x.f) === normalise(saisie));

  const totalCoef = LIGNES_BULLETIN.reduce((s, l) => s + l.coef, 0);
  const totalPond = LIGNES_BULLETIN.reduce((s, l) => s + l.note * l.coef, 0);

  const valider = () => {
    if (juste && !faits.includes(q.id)) setFaits([...faits, q.id]);
  };

  return (
    <div className="space-y-3">
      <div className="overflow-x-auto">
        <table className="w-full border-collapse text-[11px]">
          <thead>
            <tr>
              <th className="border border-border bg-secondary/40 px-2 py-1 text-left">Matière</th>
              <th className="border border-border bg-secondary/40 px-2 py-1">B — Note</th>
              <th className="border border-border bg-secondary/40 px-2 py-1">C — Coef</th>
              <th className="border border-border bg-secondary/40 px-2 py-1">D — Pondérée</th>
            </tr>
          </thead>
          <tbody>
            {LIGNES_BULLETIN.map((l, k) => (
              <tr key={l.matiere}>
                <td className="border border-border px-2 py-1">{l.matiere}</td>
                <td className="border border-border px-2 py-1 text-right font-mono">
                  {l.note.toLocaleString("fr-FR")}
                </td>
                <td className="border border-border px-2 py-1 text-right font-mono">{l.coef}</td>
                <td className="border border-border px-2 py-1 text-right font-mono">
                  {faits.includes("d3")
                    ? (l.note * l.coef).toLocaleString("fr-FR")
                    : k === 0
                      ? "D3 ?"
                      : "—"}
                </td>
              </tr>
            ))}
            <tr className="bg-secondary/20 font-semibold">
              <td className="border border-border px-2 py-1">Total</td>
              <td className="border border-border px-2 py-1" />
              <td className="border border-border px-2 py-1 text-right font-mono">
                {faits.includes("c7") ? totalCoef : "C7 ?"}
              </td>
              <td className="border border-border px-2 py-1 text-right font-mono">
                {faits.includes("d7") ? totalPond.toLocaleString("fr-FR") : "D7 ?"}
              </td>
            </tr>
            <tr className="bg-primary/5 font-semibold">
              <td className="border border-border px-2 py-1">Moyenne générale</td>
              <td className="border border-border px-2 py-1" />
              <td className="border border-border px-2 py-1" />
              <td className="border border-border px-2 py-1 text-right font-mono">
                {faits.includes("d8")
                  ? (totalPond / totalCoef).toLocaleString("fr-FR", {
                      maximumFractionDigits: 2,
                    })
                  : "D8 ?"}
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2">
        <p className="text-sm font-medium">{q.label}</p>
      </div>

      <div className="flex gap-2">
        <input
          value={saisie}
          onChange={(e) => setSaisie(e.target.value)}
          placeholder="Écris la formule, en commençant par ="
          className="flex-1 rounded-lg border border-border bg-background px-2.5 py-1.5 font-mono text-xs"
        />
        <button
          type="button"
          onClick={valider}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Valider
        </button>
      </div>

      {saisie.trim() === "" ? (
        <Verdict tone="warn">{q.aide}</Verdict>
      ) : juste ? (
        <Verdict tone="ok">
          Formule juste. Appuie sur Valider : la cellule se remplit dans le bulletin.
        </Verdict>
      ) : connue ? (
        <Verdict tone="bad">{connue.pourquoi}</Verdict>
      ) : !saisie.trim().startsWith("=") ? (
        <Verdict tone="bad">
          Toute formule commence par le signe <span className="font-mono">=</span>. Sans lui, le
          tableur garde ta saisie comme du texte.
        </Verdict>
      ) : (
        <Verdict tone="bad">Ce n&apos;est pas la formule attendue. {q.aide}</Verdict>
      )}

      <Panel>
        <Stat label="Cellules remplies" value={`${faits.length} / ${A_REMPLIR.length}`} />
        <Stat
          label="Moyenne du bulletin"
          value={
            faits.includes("d8")
              ? (totalPond / totalCoef).toLocaleString("fr-FR", { maximumFractionDigits: 2 })
              : "—"
          }
          color={PALETTE.green}
        />
      </Panel>

      <div className="flex gap-2">
        <button
          type="button"
          onClick={() => {
            setI((v) => (v + A_REMPLIR.length - 1) % A_REMPLIR.length);
            setSaisie("");
          }}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Cellule précédente
        </button>
        <button
          type="button"
          onClick={() => {
            setI((v) => (v + 1) % A_REMPLIR.length);
            setSaisie("");
          }}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Cellule suivante
        </button>
      </div>

      {faits.length === A_REMPLIR.length ? (
        <Verdict tone="ok">
          Le bulletin est complet, et tu as évité les deux fautes que le correcteur guette : diviser
          par le nombre de matières au lieu du total des coefficients, et recopier un RANG dont la
          plage n&apos;est pas figée.
        </Verdict>
      ) : null}
    </div>
  );
}
