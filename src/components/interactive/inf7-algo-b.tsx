import { useState } from "react";
import { Choice, Ctrl, PALETTE, Panel, Stat, Verdict } from "./controls";
import { Cases, Code } from "./inf7-noyau";

/** Informatique Terminale C et D — chapitres 20 et 21 : structures de données et tableaux. */

/* ------------------------------------------------------------------ */
/* Chapitre 20 — Les cinq structures en action                         */
/* ------------------------------------------------------------------ */

export function CinqStructures() {
  const [tableau, setTableau] = useState<number[]>([12, 9, 15]);
  const [liste, setListe] = useState<number[]>([12, 9, 15]);
  const [pile, setPile] = useState<number[]>([12, 9, 15]);
  const [file, setFile] = useState<number[]>([12, 9, 15]);
  const [suivant, setSuivant] = useState(7);
  const [dernier, setDernier] = useState<string | null>(null);

  const ajouter = () => {
    setTableau((t) => (t.length < 6 ? [...t, suivant] : t));
    setListe((l) => [...l, suivant]);
    setPile((p) => [...p, suivant]);
    setFile((f) => [...f, suivant]);
    setSuivant((v) => v + 3);
    setDernier(
      `Valeur ${suivant} ajoutée partout. Le tableau la met dans sa prochaine case libre — et il n'en a que six. La liste s'allonge sans limite. La pile la pose sur le dessus, la file la met en queue.`,
    );
  };

  const retirer = () => {
    const tDernier = tableau[tableau.length - 1];
    const pDernier = pile[pile.length - 1];
    const fPremier = file[0];
    setTableau((t) => t.slice(0, -1));
    setListe((l) => l.slice(0, -1));
    setPile((p) => p.slice(0, -1));
    setFile((f) => f.slice(1));
    setDernier(
      `Le tableau libère sa dernière case (${tDernier ?? "—"}). La pile rend ${pDernier ?? "—"}, le DERNIER entré : c'est le LIFO. La file rend ${fPremier ?? "—"}, le PREMIER entré : c'est le FIFO. Voilà toute la différence entre les deux.`,
    );
  };

  const Boite = ({
    titre,
    vals,
    sousTitre,
    cote,
    couleur,
  }: {
    titre: string;
    vals: ReadonlyArray<number>;
    sousTitre: string;
    cote?: "haut" | "gauche" | undefined;
    couleur: string;
  }) => (
    <div className="space-y-1 rounded-lg border border-border bg-background p-2">
      <p className="text-xs font-semibold" style={{ color: couleur }}>
        {titre}
      </p>
      <div className="flex flex-wrap gap-0.5">
        {vals.length === 0 ? (
          <p className="text-[10px] text-muted-foreground">(vide)</p>
        ) : (
          vals.map((v, i) => {
            const marque =
              (cote === "haut" && i === vals.length - 1) || (cote === "gauche" && i === 0);
            return (
              <div
                key={`${i}-${v}`}
                className={
                  marque
                    ? "flex h-7 w-9 items-center justify-center rounded border-2 font-mono text-[11px] font-bold"
                    : "flex h-7 w-9 items-center justify-center rounded border font-mono text-[11px]"
                }
                style={
                  marque
                    ? { borderColor: couleur, background: `${couleur}25` }
                    : { borderColor: "#cbd5e1" }
                }
              >
                {v}
              </div>
            );
          })
        )}
      </div>
      <p className="text-[10px] text-muted-foreground">{sousTitre}</p>
    </div>
  );

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-1.5">
        <button
          type="button"
          onClick={ajouter}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Ajouter {suivant}
        </button>
        <button
          type="button"
          onClick={retirer}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Retirer un élément
        </button>
      </div>

      <div className="grid gap-2 sm:grid-cols-2">
        <Boite
          titre="1. Tableau"
          vals={tableau}
          sousTitre={`Cases numérotées de 1 à ${tableau.length}, taille maximale 6. ${tableau.length === 6 ? "PLEIN : on ne peut plus rien ajouter." : ""}`}
          couleur={PALETTE.blue}
        />
        <Boite
          titre="2. Liste"
          vals={liste}
          sousTitre="Éléments chaînés : elle grandit et rétrécit sans limite fixée d'avance."
          couleur={PALETTE.green}
        />
        <Boite
          titre="3. Pile — LIFO"
          vals={pile}
          cote="haut"
          sousTitre="On entre et on sort par le même côté, en gras. Le dernier entré sort le premier."
          couleur={PALETTE.orange}
        />
        <Boite
          titre="4. File — FIFO"
          vals={file}
          cote="gauche"
          sousTitre="On entre d'un côté, on sort de l'autre, en gras. Le premier entré sort le premier."
          couleur={PALETTE.purple}
        />
      </div>

      <div className="grid gap-2 sm:grid-cols-2">
        <div className="rounded-lg border border-border bg-background p-2.5">
          <p className="text-xs font-semibold" style={{ color: PALETTE.orange }}>
            La pile de cahiers du professeur
          </p>
          <div className="mt-1 space-y-0.5">
            {[...pile].reverse().map((v, i) => (
              <div
                key={`${i}-${v}`}
                className={
                  i === 0
                    ? "rounded border-2 border-amber-500 bg-amber-500/20 px-2 py-0.5 text-[10px] font-semibold"
                    : "rounded border border-slate-300 px-2 py-0.5 text-[10px]"
                }
              >
                cahier {v} {i === 0 ? "← celui qu'il prend" : ""}
              </div>
            ))}
          </div>
        </div>
        <div className="rounded-lg border border-border bg-background p-2.5">
          <p className="text-xs font-semibold" style={{ color: PALETTE.purple }}>
            La file d&apos;attente au guichet
          </p>
          <div className="mt-1 flex flex-wrap items-center gap-1">
            {file.map((v, i) => (
              <div
                key={`${i}-${v}`}
                className={
                  i === 0
                    ? "rounded border-2 border-violet-500 bg-violet-500/20 px-1.5 py-0.5 text-[10px] font-semibold"
                    : "rounded border border-slate-300 px-1.5 py-0.5 text-[10px]"
                }
              >
                n°{v}
              </div>
            ))}
            <span className="text-[10px] text-muted-foreground">← guichet</span>
          </div>
        </div>
      </div>

      {dernier ? (
        <Verdict tone="ok">{dernier}</Verdict>
      ) : (
        <Verdict tone="warn">
          Ajoute puis retire des éléments, et observe les quatre réagir différemment. Le repère à
          garder : la <strong>pile</strong> se remplit et se vide du <strong>même côté</strong>, la{" "}
          <strong>file</strong> d&apos;un côté puis de l&apos;autre.
        </Verdict>
      )}

      <div className="overflow-x-auto">
        <table className="w-full border-collapse text-[11px]">
          <thead>
            <tr>
              <th className="border border-border bg-secondary/40 px-2 py-1 text-left">
                Structure
              </th>
              <th className="border border-border bg-secondary/40 px-2 py-1">On repère par</th>
              <th className="border border-border bg-secondary/40 px-2 py-1">Les types</th>
            </tr>
          </thead>
          <tbody>
            {[
              ["tableau", "un indice", "tous identiques"],
              ["enregistrement", "un nom de champ", "différents"],
              ["liste", "les chaînons", "identiques"],
              ["pile", "le dessus — LIFO", "identiques"],
              ["file", "le début — FIFO", "identiques"],
            ].map((l) => (
              <tr key={l[0]}>
                <td className="border border-border px-2 py-1 font-semibold">{l[0]}</td>
                <td className="border border-border px-2 py-1 text-center">{l[1]}</td>
                <td className="border border-border px-2 py-1 text-center">{l[2]}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 20 — Manipuler un tableau                                  */
/* ------------------------------------------------------------------ */

export function StructureTableau() {
  const [borneBasse, setBorneBasse] = useState(1);
  const [borneHaute, setBorneHaute] = useState(5);
  const [type, setType] = useState<"entier" | "reel" | "chaine">("reel");
  const [vals, setVals] = useState<Record<number, string>>({});
  const [indice, setIndice] = useState(1);
  const [valeur, setValeur] = useState("12.5");
  const [refus, setRefus] = useState<string | null>(null);
  const [deuxD, setDeuxD] = useState(false);
  const [posGrille, setPosGrille] = useState({ i: 0, j: 0 });

  const taille = Math.max(0, borneHaute - borneBasse + 1);

  const ecrire = () => {
    setRefus(null);
    if (indice < borneBasse || indice > borneHaute) {
      setRefus(
        `Indice ${indice} hors des bornes [${borneBasse}..${borneHaute}]. Le tableau DÉBORDE : en LDA c'est une faute, et dans un vrai programme on écrirait dans la zone de mémoire voisine — celle d'une autre variable, dont la valeur serait silencieusement écrasée. C'est l'une des pannes les plus difficiles à trouver.`,
      );
      return;
    }
    const n = Number(valeur.replace(",", "."));
    if (type === "entier" && (Number.isNaN(n) || !Number.isInteger(n))) {
      setRefus(
        `« ${valeur} » n'est pas un entier. Un tableau d'entiers n'accepte que des entiers : toutes ses cases sont du MÊME type, c'est la définition même du tableau.`,
      );
      return;
    }
    if (type === "reel" && Number.isNaN(n)) {
      setRefus(`« ${valeur} » n'est pas un nombre réel.`);
      return;
    }
    if (type === "chaine" && !Number.isNaN(n) && valeur.trim() !== "") {
      setRefus(`« ${valeur} » est un nombre, et ce tableau attend des chaînes de caractères.`);
      return;
    }
    setVals({ ...vals, [indice]: valeur });
  };

  const affichees = Array.from({ length: taille }, (_, k) => vals[borneBasse + k] ?? "—");

  const avancerGrille = () => {
    setPosGrille((p) => {
      const j = p.j + 1;
      if (j >= 3) return { i: (p.i + 1) % 3, j: 0 };
      return { i: p.i, j };
    });
  };

  return (
    <div className="space-y-3">
      <Choice<"non" | "oui">
        label="Dimensions"
        value={deuxD ? "oui" : "non"}
        options={[
          { value: "non", label: "Une dimension" },
          { value: "oui", label: "Deux dimensions" },
        ]}
        onChange={(v) => setDeuxD(v === "oui")}
      />

      {!deuxD ? (
        <>
          <div className="grid gap-2 sm:grid-cols-2">
            <Ctrl
              label="Borne basse"
              value={borneBasse}
              min={0}
              max={3}
              step={1}
              onChange={setBorneBasse}
              display={`${borneBasse}`}
            />
            <Ctrl
              label="Borne haute"
              value={borneHaute}
              min={3}
              max={8}
              step={1}
              onChange={setBorneHaute}
              display={`${borneHaute}`}
            />
          </div>
          <Choice<"entier" | "reel" | "chaine">
            label="Type des cases"
            value={type}
            options={[
              { value: "entier", label: "entier" },
              { value: "reel", label: "réel" },
              { value: "chaine", label: "chaîne" },
            ]}
            onChange={setType}
          />

          <div className="rounded-lg bg-slate-900 p-2.5">
            <p className="font-mono text-[11px] text-emerald-400">
              notes : tableau[{borneBasse}..{borneHaute}] de {type}
            </p>
            <p className="mt-0.5 font-mono text-[10px] text-slate-500">
              {taille} cases, indices de {borneBasse} à {borneHaute}
            </p>
          </div>

          <Cases
            valeurs={affichees}
            base={borneBasse}
            courant={indice}
            legende={`La case notes[${indice}] est éclairée.`}
          />

          <div className="flex flex-wrap items-end gap-2">
            <label className="space-y-0.5">
              <span className="block text-[11px] font-medium text-muted-foreground">Indice</span>
              <input
                type="number"
                value={indice}
                onChange={(e) => setIndice(Number(e.target.value))}
                className="w-20 rounded border border-border bg-background px-2 py-1 font-mono text-xs"
              />
            </label>
            <label className="flex-1 space-y-0.5">
              <span className="block text-[11px] font-medium text-muted-foreground">Valeur</span>
              <input
                value={valeur}
                onChange={(e) => setValeur(e.target.value)}
                className="w-full rounded border border-border bg-background px-2 py-1 font-mono text-xs"
              />
            </label>
            <button
              type="button"
              onClick={ecrire}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              notes[{indice}] ←
            </button>
          </div>

          {refus ? (
            <>
              <Verdict tone="bad">{refus}</Verdict>
              {indice < borneBasse || indice > borneHaute ? (
                <div className="rounded-lg border border-rose-500/40 bg-rose-500/5 p-2.5">
                  <p className="text-xs font-semibold text-rose-700">La mémoire, vue de près</p>
                  <div className="mt-1 flex flex-wrap gap-0.5">
                    {Array.from({ length: taille + 2 }, (_, k) => {
                      const idx = borneBasse - 1 + k;
                      const dedans = idx >= borneBasse && idx <= borneHaute;
                      const vise = idx === indice;
                      return (
                        <div
                          key={idx}
                          className={
                            vise
                              ? "flex h-9 w-14 flex-col items-center justify-center rounded border-2 border-rose-500 bg-rose-500/25 text-[9px]"
                              : dedans
                                ? "flex h-9 w-14 flex-col items-center justify-center rounded border border-blue-400 bg-blue-500/10 text-[9px]"
                                : "flex h-9 w-14 flex-col items-center justify-center rounded border border-slate-400 bg-secondary text-[9px]"
                          }
                        >
                          <span className="font-mono">[{idx}]</span>
                          <span>{dedans ? "notes" : "autre variable"}</span>
                        </div>
                      );
                    })}
                  </div>
                  <p className="mt-1 text-[10px] text-muted-foreground">
                    En écrivant dans la case rouge, tu écrases une variable qui n&apos;a rien à voir
                    avec ton tableau.
                  </p>
                </div>
              ) : null}
            </>
          ) : (
            <Verdict tone="ok">
              Le tableau porte <strong>un seul nom</strong>, ses cases sont du{" "}
              <strong>même type</strong>, et on y accède par un <strong>indice</strong>. Essaie
              maintenant un indice hors des bornes, ou une valeur du mauvais type.
            </Verdict>
          )}
        </>
      ) : (
        <>
          <div className="rounded-lg bg-slate-900 p-2.5">
            <p className="font-mono text-[11px] text-emerald-400">
              notes : tableau[1..3, 1..3] de réel
            </p>
            <p className="mt-0.5 font-mono text-[10px] text-slate-500">
              3 élèves × 3 matières = 9 cases, accessibles par deux indices
            </p>
          </div>

          <div className="overflow-x-auto">
            <table className="border-collapse text-[11px]">
              <thead>
                <tr>
                  <th className="border border-border bg-secondary/60 px-2 py-1" />
                  {[1, 2, 3].map((j) => (
                    <th
                      key={j}
                      className="border border-border bg-secondary/60 px-3 py-1 font-mono"
                    >
                      j={j}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {[1, 2, 3].map((i) => (
                  <tr key={i}>
                    <th className="border border-border bg-secondary/60 px-2 py-1 font-mono">
                      i={i}
                    </th>
                    {[1, 2, 3].map((j) => {
                      const courant = posGrille.i === i - 1 && posGrille.j === j - 1;
                      return (
                        <td
                          key={j}
                          className={
                            courant
                              ? "border-2 border-amber-500 bg-amber-400/25 px-3 py-1.5 text-center font-mono font-bold"
                              : "border border-border px-3 py-1.5 text-center font-mono"
                          }
                        >
                          {(i * 4 + j).toLocaleString("fr-FR")}
                        </td>
                      );
                    })}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <Code
            lignes={[
              "Pour i de 1 à 3 faire",
              "    Pour j de 1 à 3 faire",
              "        écrire(notes[i, j])",
              "    FinPour",
              "FinPour",
            ]}
            eclairee={2}
          />

          <Panel>
            <Stat
              label="Case courante"
              value={`notes[${posGrille.i + 1}, ${posGrille.j + 1}]`}
              color={PALETTE.blue}
            />
            <Stat label="Tours effectués" value={`${posGrille.i * 3 + posGrille.j + 1} / 9`} />
          </Panel>

          <button
            type="button"
            onClick={avancerGrille}
            className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Tour suivant
          </button>

          <Verdict tone="ok">
            Deux boucles imbriquées : la boucle <strong>extérieure</strong> change de ligne, la
            boucle <strong>intérieure</strong> parcourt toute la ligne. C&apos;est pour cela que{" "}
            <span className="font-mono">j</span> avance trois fois avant que{" "}
            <span className="font-mono">i</span> ne bouge d&apos;un cran — et c&apos;est le
            mécanisme à savoir redessiner.
          </Verdict>
        </>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 20 — Construire un enregistrement                          */
/* ------------------------------------------------------------------ */

const TYPES_LDA = ["chaîne", "entier", "réel", "booléen"] as const;

export function Enregistrement() {
  const [champs, setChamps] = useState<{ nom: string; type: string }[]>([]);
  const [nom, setNom] = useState("");
  const [type, setType] = useState<string>("chaîne");
  const [vals, setVals] = useState<Record<string, string>>({});
  const [essaiTableau, setEssaiTableau] = useState(false);
  const [tabEnr, setTabEnr] = useState(false);

  const ajouter = () => {
    if (nom.trim() === "" || champs.some((c) => c.nom === nom.trim())) return;
    setChamps((c) => [...c, { nom: nom.trim(), type }]);
    setNom("");
  };

  const typesDistincts = new Set(champs.map((c) => c.type)).size;
  const premierAutre = champs.find((c) => c.type !== champs[0]?.type);

  return (
    <div className="space-y-3">
      <div className="rounded-lg bg-slate-900 p-2.5">
        <pre className="font-mono text-[11px] leading-relaxed text-emerald-400">
          {`Type
    Eleve = Enregistrement
${champs.map((c) => `        ${c.nom} : ${c.type} ;`).join("\n") || "        (aucun champ)"}
    FinEnregistrement ;

Variable
    e : Eleve ;`}
        </pre>
      </div>

      <div className="flex flex-wrap items-end gap-2">
        <input
          value={nom}
          onChange={(e) => setNom(e.target.value)}
          placeholder="nom du champ"
          className="flex-1 rounded border border-border bg-background px-2 py-1 font-mono text-xs"
        />
        <button
          type="button"
          onClick={ajouter}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Ajouter le champ
        </button>
      </div>
      <Choice<string>
        label="Type du champ"
        value={type}
        options={TYPES_LDA.map((t) => ({ value: t, label: t }))}
        onChange={setType}
      />
      <div className="flex flex-wrap gap-1">
        {[
          { n: "matricule", t: "chaîne" },
          { n: "nom", t: "chaîne" },
          { n: "age", t: "entier" },
          { n: "moyenne", t: "réel" },
          { n: "boursier", t: "booléen" },
        ].map((x) => (
          <button
            key={x.n}
            type="button"
            onClick={() => {
              setNom(x.n);
              setType(x.t);
            }}
            className="rounded border border-border bg-background px-1.5 py-0.5 font-mono text-[10px] text-muted-foreground hover:bg-secondary/60"
          >
            {x.n} : {x.t}
          </button>
        ))}
      </div>

      {champs.length > 0 ? (
        <div className="space-y-1.5 rounded-lg border border-border bg-background p-2.5">
          <p className="text-xs font-semibold">Remplis la variable e</p>
          {champs.map((c) => (
            <div key={c.nom} className="flex items-center gap-2">
              <span className="w-32 font-mono text-[11px]">e.{c.nom} ←</span>
              <input
                value={vals[c.nom] ?? ""}
                onChange={(e) => setVals({ ...vals, [c.nom]: e.target.value })}
                className="flex-1 rounded border border-border bg-background px-2 py-0.5 font-mono text-[11px]"
              />
              <span className="w-16 text-[10px] text-muted-foreground">{c.type}</span>
            </div>
          ))}
          <p className="text-[10px] text-muted-foreground">
            On accède à chaque champ par le <strong>point</strong> : le nom de la variable, un
            point, le nom du champ.
          </p>
        </div>
      ) : null}

      <Panel>
        <Stat label="Champs définis" value={`${champs.length}`} />
        <Stat
          label="Types distincts"
          value={`${typesDistincts}`}
          color={typesDistincts > 1 ? PALETTE.green : PALETTE.ink}
        />
      </Panel>

      <button
        type="button"
        onClick={() => setEssaiTableau((v) => !v)}
        disabled={champs.length < 2}
        className={
          champs.length < 2
            ? "rounded-lg border border-border bg-background px-3 py-1.5 text-xs text-muted-foreground opacity-40"
            : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        }
      >
        Essayer de ranger les mêmes données dans un tableau
      </button>

      {essaiTableau ? (
        premierAutre ? (
          <div className="space-y-1.5">
            <div className="rounded-lg bg-slate-900 p-2.5">
              <p className="font-mono text-[11px] text-slate-300">
                t : tableau[1..{champs.length}] de {champs[0]?.type ?? "chaîne"}
              </p>
              <p className="font-mono text-[11px] text-emerald-400">
                t[1] ← {vals[champs[0]?.nom ?? ""] || "…"} ✓
              </p>
              <p className="font-mono text-[11px] text-rose-400">
                t[?] ← {vals[premierAutre.nom] || "…"} ✗ type {premierAutre.type} attendu{" "}
                {champs[0]?.type}
              </p>
            </div>
            <Verdict tone="bad">
              Le tableau échoue au premier champ d&apos;un autre type : « {premierAutre.nom} » est
              un {premierAutre.type}, et toutes les cases d&apos;un tableau doivent être du{" "}
              <strong>même type</strong>. C&apos;est exactement pour cela que l&apos;enregistrement
              existe : le tableau groupe le <strong>même</strong>, l&apos;enregistrement groupe le{" "}
              <strong>différent</strong>.
            </Verdict>
          </div>
        ) : (
          <Verdict tone="warn">
            Tous tes champs sont du même type : ici un tableau suffirait. Ajoute un champ{" "}
            <span className="font-mono">age : entier</span> ou{" "}
            <span className="font-mono">moyenne : réel</span> et réessaie.
          </Verdict>
        )
      ) : null}

      <div className="space-y-2 border-t border-border pt-3">
        <button
          type="button"
          onClick={() => setTabEnr((v) => !v)}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          {tabEnr ? "Masquer" : "Construire un tableau d'enregistrements"}
        </button>

        {tabEnr ? (
          <div className="space-y-2">
            <div className="rounded-lg bg-slate-900 p-2.5">
              <p className="font-mono text-[11px] text-emerald-400">
                classe : tableau[1..3] de Eleve
              </p>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full border-collapse text-[11px]">
                <thead>
                  <tr>
                    <th className="border border-border bg-secondary/40 px-2 py-1">indice</th>
                    <th className="border border-border bg-secondary/40 px-2 py-1 font-mono">
                      .matricule
                    </th>
                    <th className="border border-border bg-secondary/40 px-2 py-1 font-mono">
                      .nom
                    </th>
                    <th className="border border-border bg-secondary/40 px-2 py-1 font-mono">
                      .moyenne
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {[
                    ["1", "E101", "MBIDA", "13,5"],
                    ["2", "E102", "NGONO", "15,25"],
                    ["3", "E103", "FOUDA", "9,75"],
                  ].map((l) => (
                    <tr key={l[0]}>
                      {l.map((v, j) => (
                        <td
                          key={`${l[0]}-${j}`}
                          className="border border-border px-2 py-1 text-center font-mono"
                        >
                          {v}
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <Code
              lignes={[
                "classe[2].nom ← « NGONO »",
                "écrire(classe[2].moyenne)",
                "",
                "Pour i de 1 à 3 faire",
                "    écrire(classe[i].nom, « : », classe[i].moyenne)",
                "FinPour",
              ]}
            />
            <Verdict tone="ok">
              Regarde ce tableau : chaque <strong>case du tableau</strong> est une{" "}
              <strong>ligne</strong>, chaque <strong>champ de l&apos;enregistrement</strong> est une{" "}
              <strong>colonne</strong>. C&apos;est trait pour trait une{" "}
              <strong>table de base de données</strong> — et ce n&apos;est pas un hasard : le module
              précédent et celui-ci décrivent la même chose, l&apos;un pour le disque, l&apos;autre
              pour la mémoire.
            </Verdict>
          </div>
        ) : null}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 21 — Parcourir un tableau                                  */
/* ------------------------------------------------------------------ */

const NOTES = [12, 9, 15.5, 7, 18, 11];

export function ParcoursTableau() {
  const [i, setI] = useState(0);
  const [initialise, setInitialise] = useState(true);
  const [borne, setBorne] = useState(NOTES.length);

  const n = NOTES.length;
  // Sans initialisation, l'accumulateur part d'une valeur imprévisible.
  const depart = initialise ? 0 : 4217;
  const vues = NOTES.slice(0, i);
  const somme = vues.reduce((s, v) => s + v, depart);
  const debordement = borne > n;
  const sommeDebord = debordement && i >= n ? somme + 4217 : somme;
  const compte = vues.filter((v) => v >= 10).length;
  const moyenne = i > 0 ? sommeDebord / i : 0;

  return (
    <div className="space-y-3">
      <Code
        lignes={[
          initialise ? "somme ← 0" : "{ somme non initialisée }",
          "nbAdmis ← 0",
          `Pour i de 1 à ${borne} faire`,
          "    somme ← somme + notes[i]",
          "    Si notes[i] >= 10 alors",
          "        nbAdmis ← nbAdmis + 1",
          "    Finsi",
          "FinPour",
          "moyenne ← somme / n",
        ]}
        eclairee={i === 0 ? 0 : 3}
      />

      <Cases
        valeurs={NOTES.map((v) => v.toLocaleString("fr-FR"))}
        base={1}
        courant={i}
        marquees={Array.from({ length: Math.max(0, i - 1) }, (_, k) => k + 1)}
        legende={
          debordement && i > n
            ? `La case [${i}] n'existe pas : le parcours a débordé.`
            : `Case courante : notes[${Math.max(1, i)}].`
        }
      />

      <Panel>
        <Stat
          label="somme"
          value={sommeDebord.toLocaleString("fr-FR", { maximumFractionDigits: 2 })}
          color={initialise ? PALETTE.blue : PALETTE.red}
        />
        <Stat label="nbAdmis" value={`${compte}`} color={PALETTE.green} />
      </Panel>
      <Panel>
        <Stat
          label="moyenne"
          value={i > 0 ? moyenne.toLocaleString("fr-FR", { maximumFractionDigits: 2 }) : "—"}
        />
        <Stat label="Tour" value={`${i} / ${borne}`} />
      </Panel>

      <div className="flex flex-wrap gap-2">
        <button
          type="button"
          onClick={() => setI((v) => Math.max(0, v - 1))}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Tour précédent
        </button>
        <button
          type="button"
          onClick={() => setI((v) => Math.min(borne, v + 1))}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Tour suivant
        </button>
        <button
          type="button"
          onClick={() => setI(0)}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Recommencer
        </button>
      </div>

      <div className="grid gap-2 sm:grid-cols-2">
        <Choice<"oui" | "non">
          label="Initialiser somme à 0"
          value={initialise ? "oui" : "non"}
          options={[
            { value: "oui", label: "Oui" },
            { value: "non", label: "Oublier" },
          ]}
          onChange={(v) => {
            setInitialise(v === "oui");
            setI(0);
          }}
        />
        <Ctrl
          label="Borne du Pour"
          value={borne}
          min={n - 1}
          max={n + 2}
          step={1}
          onChange={(v) => {
            setBorne(v);
            setI(0);
          }}
          display={`i de 1 à ${borne}`}
          color={borne > n ? PALETTE.red : PALETTE.blue}
        />
      </div>

      {!initialise ? (
        <Verdict tone="bad">
          La somme part de 4217, une valeur qui traînait en mémoire. Tous les résultats qui en
          découlent sont faux, et <strong>rien ne le signale</strong> : l&apos;algorithme tourne
          jusqu&apos;au bout et affiche une moyenne de{" "}
          {i > 0 ? moyenne.toLocaleString("fr-FR", { maximumFractionDigits: 2 }) : "—"} au lieu de{" "}
          {(NOTES.reduce((s, v) => s + v, 0) / n).toLocaleString("fr-FR", {
            maximumFractionDigits: 2,
          })}
          . <strong>Initialiser, accumuler, exploiter</strong> — le premier temps n&apos;est pas
          décoratif.
        </Verdict>
      ) : debordement && i > n ? (
        <Verdict tone="bad">
          Le parcours est allé jusqu&apos;à {borne} alors que le tableau n&apos;a que {n} cases. Il
          a lu la mémoire voisine et ajouté 4217 à la somme. La borne d&apos;un{" "}
          <span className="font-mono">Pour</span> doit valoir exactement{" "}
          <span className="font-mono">n</span>, le nombre de cases réellement utilisées.
        </Verdict>
      ) : i === borne && i > 0 ? (
        <Verdict tone="ok">
          Parcours terminé : somme ={" "}
          {sommeDebord.toLocaleString("fr-FR", { maximumFractionDigits: 2 })}, moyenne ={" "}
          {moyenne.toLocaleString("fr-FR", { maximumFractionDigits: 2 })}, {compte} élèves ont la
          moyenne. Et remarque qu&apos;<strong>un seul parcours</strong> a suffi pour les deux
          calculs : c&apos;est le réflexe à prendre.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Avance tour par tour et regarde les accumulateurs monter. Essaie ensuite d&apos;oublier
          l&apos;initialisation, puis de dépasser les bornes.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 21 — La recherche séquentielle                             */
/* ------------------------------------------------------------------ */

const TAB_RECH = [4, 9, 7, 15, 2, 11];

export function RechercheSequentielle() {
  const [cible, setCible] = useState(15);
  const [etape, setEtape] = useState(0);
  const [bonneIncr, setBonneIncr] = useState(true);

  const n = TAB_RECH.length;
  // On déroule la recherche pour en extraire les étapes.
  const pas: { i: number; trouve: boolean; compare: string }[] = [];
  let i = 1;
  let trouve = false;
  pas.push({ i, trouve, compare: "initialisation : trouve ← faux, i ← 1" });
  while (i <= n && !trouve) {
    const v = TAB_RECH[i - 1] ?? 0;
    if (v === cible) {
      trouve = true;
      // Avec l'incrémentation mal placée, i avance même quand on trouve.
      if (!bonneIncr) i += 1;
      pas.push({ i, trouve, compare: `t[${bonneIncr ? i : i - 1}] = ${v} = ${cible} → TROUVÉ` });
    } else {
      i += 1;
      pas.push({ i, trouve, compare: `t[${i - 1}] = ${v} ≠ ${cible} → i passe à ${i}` });
    }
  }
  const PAS_DEFAUT = { i: 1, trouve: false, compare: "" };
  const p = pas[Math.min(etape, pas.length - 1)] ?? PAS_DEFAUT;
  const fini = etape >= pas.length - 1;
  const comparaisons = pas.length - 1;
  const positionAffichee = p.i;
  const positionVraie = TAB_RECH.indexOf(cible) + 1;

  return (
    <div className="space-y-3">
      <Code
        lignes={[
          "trouve ← faux",
          "i ← 1",
          `TantQue (i <= ${n}) et (trouve = faux) faire`,
          `    Si t[i] = ${cible} alors`,
          "        trouve ← vrai",
          bonneIncr ? "    Sinon" : "    Finsi",
          "        i ← i + 1",
          bonneIncr ? "    Finsi" : "",
          "FinTantQue",
        ]}
        eclairee={bonneIncr ? 6 : 6}
        tonEclairee={bonneIncr ? "ok" : "bad"}
      />

      <Cases
        valeurs={TAB_RECH}
        base={1}
        courant={p.trouve && bonneIncr ? p.i : p.i}
        marquees={Array.from({ length: Math.max(0, p.i - 1) }, (_, k) => k + 1)}
        legende={`On cherche ${cible}.`}
      />

      <div className="rounded-lg border border-border bg-background p-2.5">
        <p className="font-mono text-[11px] text-muted-foreground">{p.compare}</p>
      </div>

      <Panel>
        <Stat label="i" value={`${p.i}`} color={PALETTE.blue} />
        <Stat
          label="trouve"
          value={p.trouve ? "vrai" : "faux"}
          color={p.trouve ? PALETTE.green : PALETTE.slate}
        />
      </Panel>
      <Panel>
        <Stat label="Comparaisons faites" value={`${etape}`} />
        <Stat
          label="Comparaisons au total"
          value={`${comparaisons} ${positionVraie === 1 ? "(meilleur cas)" : positionVraie === 0 ? "(pire cas)" : ""}`}
        />
      </Panel>

      <div className="flex flex-wrap gap-2">
        <button
          type="button"
          onClick={() => setEtape((v) => Math.max(0, v - 1))}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Précédent
        </button>
        <button
          type="button"
          onClick={() => setEtape((v) => Math.min(pas.length - 1, v + 1))}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Comparaison suivante
        </button>
        <button
          type="button"
          onClick={() => setEtape(0)}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Recommencer
        </button>
      </div>

      <div className="grid gap-2 sm:grid-cols-2">
        <Choice<string>
          label="Valeur cherchée"
          value={String(cible)}
          options={[
            { value: "4", label: "4 (1re case)" },
            { value: "15", label: "15 (4e case)" },
            { value: "11", label: "11 (dernière)" },
            { value: "99", label: "99 (absente)" },
          ]}
          onChange={(v) => {
            setCible(Number(v));
            setEtape(0);
          }}
        />
        <Choice<"oui" | "non">
          label="Incrémentation dans le Sinon"
          value={bonneIncr ? "oui" : "non"}
          options={[
            { value: "oui", label: "Dans le Sinon" },
            { value: "non", label: "Hors du Sinon" },
          ]}
          onChange={(v) => {
            setBonneIncr(v === "oui");
            setEtape(0);
          }}
        />
      </div>

      {fini ? (
        p.trouve ? (
          !bonneIncr ? (
            <Verdict tone="bad">
              L&apos;algorithme affiche « position {positionAffichee} » alors que {cible} est en{" "}
              <strong>position {positionVraie}</strong>. L&apos;incrémentation s&apos;est exécutée
              aussi au tour où l&apos;on a trouvé, et <span className="font-mono">i</span> désigne
              maintenant la case <strong>suivante</strong>. C&apos;est pour cela qu&apos;elle doit
              rester dans le <strong>Sinon</strong> — et c&apos;est exactement la question 2.3 du
              Baccalauréat 2023.
            </Verdict>
          ) : (
            <Verdict tone="ok">
              Trouvé en {comparaisons} comparaison{comparaisons > 1 ? "s" : ""}, position{" "}
              {positionAffichee} — la bonne. Au moment où le test réussit,{" "}
              <span className="font-mono">i</span> ne bouge pas, puisque l&apos;incrémentation est
              dans le <strong>Sinon</strong>.
            </Verdict>
          )
        ) : (
          <Verdict tone="warn">
            Recherche infructueuse : {comparaisons} comparaisons, c&apos;est-à-dire{" "}
            <strong>n comparaisons</strong>, le pire cas. Et <span className="font-mono">i</span>{" "}
            vaut {p.i}, soit <strong>n + 1</strong> : c&apos;est la signature d&apos;un échec, et
            c&apos;est ce dépassement qui a fait sortir de la boucle.
          </Verdict>
        )
      ) : (
        <Verdict tone="warn">
          Avance comparaison par comparaison. Puis change la valeur cherchée pour voir le meilleur
          cas, le pire cas et l&apos;échec — et déplace l&apos;incrémentation pour voir la position
          devenir fausse.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 21 — Maximum et minimum                                    */
/* ------------------------------------------------------------------ */

const JEUX = [
  { label: "Des notes", vals: [12, 9, 15.5, 7, 18, 11] },
  { label: "Des températures négatives", vals: [-3, -8, -1, -12, -5] },
  { label: "Des altitudes", vals: [-20, 340, -5, 1200, 88] },
] as const;

export function RechercheMax() {
  const [jeu, setJeu] = useState(0);
  const [etape, setEtape] = useState(1);
  const [init, setInit] = useState<"premier" | "zero">("premier");
  const [sens, setSens] = useState<"max" | "min">("max");
  const [suivrePos, setSuivrePos] = useState(false);

  const vals = JEUX[jeu]?.vals ?? JEUX[0].vals;
  const n = vals.length;
  const premier = vals[0] ?? 0;
  const depart = init === "premier" ? premier : 0;

  let courant = depart;
  let pos = init === "premier" ? 1 : 0;
  const histoire: { i: number; courant: number; pos: number; battu: boolean }[] = [
    { i: 1, courant: depart, pos, battu: false },
  ];
  for (let k = 2; k <= n; k++) {
    const v = vals[k - 1] ?? 0;
    const bat = sens === "max" ? v > courant : v < courant;
    if (bat) {
      courant = v;
      pos = k;
    }
    histoire.push({ i: k, courant, pos, battu: bat });
  }

  const H_DEFAUT = { i: 1, courant: depart, pos, battu: false };
  const h = histoire[Math.min(etape, histoire.length) - 1] ?? H_DEFAUT;
  const fini = etape >= n;

  const vraiExtremum = sens === "max" ? Math.max(...vals) : Math.min(...vals);
  const faux = fini && h.courant !== vraiExtremum;

  return (
    <div className="space-y-3">
      <div className="grid gap-2 sm:grid-cols-2">
        <Choice<"max" | "min">
          label="On cherche"
          value={sens}
          options={[
            { value: "max", label: "Le maximum" },
            { value: "min", label: "Le minimum" },
          ]}
          onChange={(v) => {
            setSens(v);
            setEtape(1);
          }}
        />
        <Choice<"premier" | "zero">
          label="Initialisation"
          value={init}
          options={[
            { value: "premier", label: "par tab[1]" },
            { value: "zero", label: "par 0" },
          ]}
          onChange={(v) => {
            setInit(v);
            setEtape(1);
          }}
        />
      </div>
      <Choice<string>
        label="Jeu de valeurs"
        value={String(jeu)}
        options={JEUX.map((x, k) => ({ value: String(k), label: x.label }))}
        onChange={(v) => {
          setJeu(Number(v));
          setEtape(1);
        }}
      />

      <Code
        lignes={[
          init === "premier" ? `${sens} ← tab[1]` : `${sens} ← 0        { l'erreur classique }`,
          ...(suivrePos ? [`pos${sens === "max" ? "Max" : "Min"} ← 1`] : []),
          `Pour i de 2 à ${n} faire`,
          `    Si tab[i] ${sens === "max" ? ">" : "<"} ${sens} alors`,
          `        ${sens} ← tab[i]`,
          ...(suivrePos ? [`        pos${sens === "max" ? "Max" : "Min"} ← i`] : []),
          "    Finsi",
          "FinPour",
        ]}
        eclairee={h.battu ? (suivrePos ? 4 : 4) : 3}
        tonEclairee={init === "zero" ? "bad" : "ok"}
      />

      <Cases
        valeurs={vals.map((v) => v.toLocaleString("fr-FR"))}
        base={1}
        courant={h.i}
        marquees={Array.from({ length: Math.max(0, h.i - 1) }, (_, k) => k + 1)}
      />

      <Panel>
        <Stat
          label={sens}
          value={h.courant.toLocaleString("fr-FR")}
          color={h.battu ? PALETTE.green : faux ? PALETTE.red : PALETTE.blue}
        />
        <Stat
          label={suivrePos ? `position du ${sens}` : "tour"}
          value={suivrePos ? `${h.pos}` : `${h.i} / ${n}`}
        />
      </Panel>

      {h.battu ? (
        <Verdict tone="ok">
          La valeur {h.courant.toLocaleString("fr-FR")} vient de <strong>battre</strong>{" "}
          l&apos;ancien {sens}
          {suivrePos ? `, et la position passe à ${h.pos} dans le même Si` : ""}.
        </Verdict>
      ) : null}

      <div className="flex flex-wrap gap-2">
        <button
          type="button"
          onClick={() => setEtape((v) => Math.max(1, v - 1))}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Précédent
        </button>
        <button
          type="button"
          onClick={() => setEtape((v) => Math.min(n, v + 1))}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Case suivante
        </button>
        <button
          type="button"
          onClick={() => setSuivrePos((v) => !v)}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          {suivrePos ? "Ne plus suivre la position" : "Suivre aussi la position"}
        </button>
      </div>

      {faux ? (
        <Verdict tone="bad">
          L&apos;algorithme répond {h.courant.toLocaleString("fr-FR")} alors que le vrai {sens} est{" "}
          <strong>{vraiExtremum.toLocaleString("fr-FR")}</strong>. En initialisant à 0 sur des
          valeurs {sens === "max" ? "négatives" : "positives"}, aucune ne{" "}
          {sens === "max" ? "dépasse" : "descend sous"} jamais 0 : le 0 reste là, et il
          n&apos;appartient même pas au tableau. C&apos;est <strong>la</strong> faute classique, et
          la correction tient en trois caractères :{" "}
          <span className="font-mono">{sens} ← tab[1]</span>.
        </Verdict>
      ) : fini ? (
        <Verdict tone="ok">
          {sens} = {h.courant.toLocaleString("fr-FR")}
          {suivrePos ? `, en position ${h.pos}` : ""}, en {n - 1} comparaisons. Et remarque la
          boucle : elle commence à <strong>2</strong>, parce que la case 1 a déjà servi
          d&apos;initialisation — la comparer à elle-même ne servirait à rien. Contrairement à la
          recherche séquentielle, il faut ici parcourir <strong>tout</strong> le tableau : on ne
          peut pas savoir qu&apos;on tient le {sens} avant d&apos;avoir tout vu.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Avance case par case. Puis choisis les températures négatives avec une initialisation à 0,
          et regarde l&apos;algorithme se tromper.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 21 — Remplir une trace d'exécution                         */
/* ------------------------------------------------------------------ */

const SCENARIOS = [
  { label: "[4, 9, 7] cherche 9", tab: [4, 9, 7], cible: 9, cas: "cas moyen" },
  { label: "[4, 9, 7] cherche 4", tab: [4, 9, 7], cible: 4, cas: "meilleur cas" },
  { label: "[3, 8, 1] cherche 5", tab: [3, 8, 1], cible: 5, cas: "recherche infructueuse" },
] as const;

export function TraceExecution() {
  const [s, setS] = useState(0);
  const [saisies, setSaisies] = useState<Record<number, { i: string; t: string }>>({});

  const sc = SCENARIOS[s] ?? SCENARIOS[0];
  const n = sc.tab.length;

  // La trace attendue.
  const attendue: { instruction: string; i: string; t: string }[] = [
    { instruction: "trouve ← faux", i: "—", t: "faux" },
    { instruction: "i ← 1", i: "1", t: "faux" },
  ];
  let i = 1;
  let trouve = false;
  while (i <= n && !trouve) {
    const v = sc.tab[i - 1] ?? 0;
    attendue.push({
      instruction: `Si tab[${i}] = ${sc.cible}  (${v} ${v === sc.cible ? "=" : "≠"} ${sc.cible})`,
      i: String(i),
      t: trouve ? "vrai" : "faux",
    });
    if (v === sc.cible) {
      trouve = true;
      attendue.push({ instruction: "trouve ← vrai", i: String(i), t: "vrai" });
    } else {
      i += 1;
      attendue.push({ instruction: "i ← i + 1", i: String(i), t: "faux" });
    }
  }
  attendue.push({
    instruction: trouve ? "sortie : trouve = vrai" : `test de boucle : (${i} ≤ ${n}) faux, on sort`,
    i: String(i),
    t: trouve ? "vrai" : "faux",
  });

  const justes = attendue.filter((a, k) => {
    const sa = saisies[k];
    return sa && sa.i === a.i && sa.t === a.t;
  }).length;
  const complet = justes === attendue.length;

  return (
    <div className="space-y-3">
      <Choice<string>
        label="Scénario"
        value={String(s)}
        options={SCENARIOS.map((x, k) => ({ value: String(k), label: x.label }))}
        onChange={(v) => {
          setS(Number(v));
          setSaisies({});
        }}
      />

      <Code
        lignes={[
          "trouve ← faux",
          "i ← 1",
          `TantQue (i <= ${n}) et (trouve = faux) faire`,
          `    Si tab[i] = ${sc.cible} alors`,
          "        trouve ← vrai",
          "    Sinon",
          "        i ← i + 1",
          "    Finsi",
          "FinTantQue",
        ]}
      />

      <Cases valeurs={sc.tab} base={1} legende={`On cherche ${sc.cible}.`} />

      <div className="overflow-x-auto">
        <table className="w-full border-collapse text-[11px]">
          <thead>
            <tr>
              <th className="border border-border bg-secondary/40 px-2 py-1 text-left">
                Instruction
              </th>
              <th className="border border-border bg-secondary/40 px-2 py-1 font-mono">i</th>
              <th className="border border-border bg-secondary/40 px-2 py-1 font-mono">trouve</th>
            </tr>
          </thead>
          <tbody>
            {attendue.map((a, k) => {
              const sa = saisies[k];
              const okI = sa?.i === a.i;
              const okT = sa?.t === a.t;
              return (
                <tr key={`${k}-${a.instruction}`}>
                  <td className="border border-border px-2 py-1 font-mono">{a.instruction}</td>
                  <td className="border border-border px-1 py-0.5">
                    <input
                      value={sa?.i ?? ""}
                      onChange={(e) =>
                        setSaisies({
                          ...saisies,
                          [k]: { i: e.target.value, t: sa?.t ?? "" },
                        })
                      }
                      placeholder="?"
                      className={
                        sa?.i
                          ? okI
                            ? "w-14 rounded border-2 border-emerald-500 bg-emerald-500/10 px-1 text-center font-mono text-[11px]"
                            : "w-14 rounded border-2 border-rose-500 bg-rose-500/10 px-1 text-center font-mono text-[11px]"
                          : "w-14 rounded border border-border bg-background px-1 text-center font-mono text-[11px]"
                      }
                    />
                  </td>
                  <td className="border border-border px-1 py-0.5">
                    <select
                      value={sa?.t ?? ""}
                      onChange={(e) =>
                        setSaisies({
                          ...saisies,
                          [k]: { i: sa?.i ?? "", t: e.target.value },
                        })
                      }
                      className={
                        sa?.t
                          ? okT
                            ? "w-20 rounded border-2 border-emerald-500 bg-emerald-500/10 px-1 font-mono text-[11px]"
                            : "w-20 rounded border-2 border-rose-500 bg-rose-500/10 px-1 font-mono text-[11px]"
                          : "w-20 rounded border border-border bg-background px-1 font-mono text-[11px]"
                      }
                    >
                      <option value="">?</option>
                      <option value="faux">faux</option>
                      <option value="vrai">vrai</option>
                    </select>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      <Panel>
        <Stat label="Lignes justes" value={`${justes} / ${attendue.length}`} />
        <Stat
          label="Ce scénario est"
          value={sc.cas}
          color={complet ? PALETTE.green : PALETTE.ink}
        />
      </Panel>

      {complet ? (
        <Verdict tone="ok">
          Trace complète et juste.{" "}
          {sc.cas === "recherche infructueuse"
            ? `Remarque que i finit à ${attendue[attendue.length - 1]?.i ?? ""}, soit n + 1 : c'est la signature d'un échec, et c'est ce dépassement qui fait sortir de la boucle.`
            : "Remarque qu'au tour où l'on trouve, i NE BOUGE PAS : l'incrémentation est dans le Sinon, et c'est elle qui garantit la bonne position."}
        </Verdict>
      ) : justes > 0 ? (
        <Verdict tone="warn">
          {justes} ligne{justes > 1 ? "s" : ""} juste{justes > 1 ? "s" : ""}. La règle d&apos;or :
          suis l&apos;algorithme <strong>sans anticiper</strong>, et ne saute{" "}
          <strong>aucun tour</strong>, même s&apos;il paraît évident. La plupart des erreurs de
          trace viennent d&apos;un tour sauté « parce qu&apos;on avait compris ».
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Remplis la trace ligne par ligne. Un tiret pour une variable non encore initialisée.
        </Verdict>
      )}
    </div>
  );
}
