import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict, fmt } from "./controls";
import { JeuClassement } from "./info1-jeux";

/** Informatique 1ère A, C et D — chapitres 8 et 9 : notions d'algorithmique, variables. */

/* ------------------------------------------------------------------ */
/* Chapitre 8 — Reconstituer un algorithme                             */
/* ------------------------------------------------------------------ */

type Ligne = { id: number; texte: string; bloc: "entete" | "declaration" | "corps" };

const LIGNES: ReadonlyArray<Ligne> = [
  { id: 0, texte: "Algorithme : PrixTTC", bloc: "entete" },
  { id: 1, texte: "Constante", bloc: "declaration" },
  { id: 2, texte: "    tva = 0.07 ;", bloc: "declaration" },
  { id: 3, texte: "Variable", bloc: "declaration" },
  { id: 4, texte: "    pu, q, p : réel ;", bloc: "declaration" },
  { id: 5, texte: "Début", bloc: "corps" },
  { id: 6, texte: "    lire(pu, q)", bloc: "corps" },
  { id: 7, texte: "    p ← pu * q", bloc: "corps" },
  { id: 8, texte: "    écrire(p * (1 + tva))", bloc: "corps" },
  { id: 9, texte: "Fin", bloc: "corps" },
];

// l'ordre de présentation, volontairement mélangé
const DESORDRE = [7, 5, 0, 9, 3, 6, 1, 8, 4, 2];

const COULEUR_BLOC = {
  entete: "#ea580c",
  declaration: "#2563eb",
  corps: "#16a34a",
} as const;

const NOM_BLOC = {
  entete: "l'en-tête — il nomme",
  declaration: "les déclarations — elles réservent la place",
  corps: "le corps — il travaille",
} as const;

export function PartiesAlgorithme() {
  const [ordre, setOrdre] = useState<number[]>([]);

  const restantes = DESORDRE.filter((id) => !ordre.includes(id));
  const parId = (id: number) => LIGNES.find((l) => l.id === id);
  const juste = ordre.length === LIGNES.length && ordre.every((id, k) => id === k);

  // diagnostic de la première faute
  let faute = "";
  for (let k = 0; k < ordre.length; k += 1) {
    const id = ordre[k];
    if (id === undefined) break;
    const l = parId(id);
    if (!l) break;
    if (l.bloc === "corps" && l.texte !== "Début") {
      const avant = ordre.slice(0, k).map((x) => parId(x)?.texte ?? "");
      if (!avant.includes("Début") && l.texte !== "Début") {
        faute = `« ${l.texte.trim()} » est une instruction : elle doit se trouver après Début, dans le corps de l'algorithme.`;
        break;
      }
    }
    if (l.bloc === "declaration") {
      const avant = ordre.slice(0, k).map((x) => parId(x)?.texte ?? "");
      if (avant.includes("Début")) {
        faute = `« ${l.texte.trim()} » est une déclaration : on déclare AVANT Début, jamais dans le corps.`;
        break;
      }
    }
    if (l.bloc === "entete" && k > 0) {
      faute = "L'en-tête « Algorithme : … » est toujours la première ligne.";
      break;
    }
  }

  const W = 440;
  const H = 36 + LIGNES.length * 22;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        {ordre.length === 0 ? (
          <text x={220} y={H / 2} textAnchor="middle" fontSize={11} fill={PALETTE.slate}>
            Clique les lignes ci-dessous pour construire l&apos;algorithme.
          </text>
        ) : null}
        {ordre.map((id, k) => {
          const l = parId(id);
          if (!l) return null;
          return (
            <g key={id}>
              <rect
                x={14}
                y={14 + k * 22}
                width={412}
                height={20}
                rx={3}
                fill={COULEUR_BLOC[l.bloc]}
                opacity={0.14}
              />
              <rect x={14} y={14 + k * 22} width={4} height={20} fill={COULEUR_BLOC[l.bloc]} />
              <text
                x={26}
                y={28 + k * 22}
                fontSize={11}
                fontFamily="monospace"
                fill={COULEUR_BLOC[l.bloc]}
              >
                {l.texte}
              </text>
            </g>
          );
        })}
      </Board>

      <div className="flex flex-wrap gap-1.5">
        {restantes.map((id) => {
          const l = parId(id);
          if (!l) return null;
          return (
            <button
              key={id}
              type="button"
              onClick={() => setOrdre([...ordre, id])}
              className="rounded-lg border border-border bg-background px-2.5 py-1.5 font-mono text-[11px] font-medium hover:bg-secondary/60"
            >
              {l.texte.trim()}
            </button>
          );
        })}
      </div>

      <div className="flex gap-2">
        <button
          type="button"
          onClick={() => setOrdre(ordre.slice(0, -1))}
          disabled={ordre.length === 0}
          className={
            ordre.length === 0
              ? "rounded-lg border border-border bg-secondary/40 px-3 py-1.5 text-xs text-muted-foreground/50"
              : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
          }
        >
          Retirer la dernière
        </button>
        <button
          type="button"
          onClick={() => setOrdre([])}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Tout recommencer
        </button>
      </div>

      <Panel>
        <Stat label="Lignes placées" value={`${ordre.length} / ${LIGNES.length}`} />
        <Stat
          label="Structure"
          value={juste ? "correcte" : faute ? "fautive" : "en cours"}
          color={juste ? PALETTE.green : faute ? PALETTE.red : PALETTE.slate}
        />
      </Panel>

      {juste ? (
        <Verdict tone="ok">
          L&apos;algorithme est juste, et les trois blocs se distinguent à leur couleur :{" "}
          {NOM_BLOC.entete}, {NOM_BLOC.declaration}, {NOM_BLOC.corps}.
        </Verdict>
      ) : faute ? (
        <Verdict tone="bad">{faute}</Verdict>
      ) : (
        <Verdict tone="warn">
          Trois questions pour t&apos;orienter : qui ? — l&apos;en-tête. Avec quoi ? — les
          déclarations. Comment ? — le corps, entre Début et Fin.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 8 — Analyser un problème                                   */
/* ------------------------------------------------------------------ */

type Role = "entree" | "traitement" | "sortie";

type Probleme = {
  titre: string;
  grandeurs: ReadonlyArray<{ nom: string; role: Role; note: string }>;
  algo: string;
};

const PROBLEMES: ReadonlyArray<Probleme> = [
  {
    titre: "Calculer le prix toutes taxes comprises d'un achat, avec une TVA de 7 %.",
    grandeurs: [
      {
        nom: "le prix unitaire hors taxe",
        role: "entree",
        note: "L'algorithme ne peut pas le deviner : il faut le lire.",
      },
      {
        nom: "la quantité achetée",
        role: "entree",
        note: "Elle vient de l'utilisateur elle aussi.",
      },
      {
        nom: "le taux de TVA",
        role: "traitement",
        note: "Il vaut 7 % et ne change pas : c'est une constante, pas une entrée. C'est le piège du Probatoire 2017.",
      },
      { nom: "le prix hors taxe", role: "sortie", note: "Il est calculé, puis affiché." },
      { nom: "le prix toutes taxes comprises", role: "sortie", note: "C'est le résultat attendu." },
    ],
    algo: "Constante\n    tva = 0.07 ;\nVariable\n    pu, pht, pttc : réel ;\n    q : entier ;\nDébut\n    lire(pu, q)\n    pht ← pu * q\n    pttc ← pht * (1 + tva)\n    écrire(pht, pttc)\nFin",
  },
  {
    titre: "Calculer la moyenne de trois notes.",
    grandeurs: [
      { nom: "la première note", role: "entree", note: "Lue au clavier." },
      { nom: "la deuxième note", role: "entree", note: "Lue au clavier." },
      { nom: "la troisième note", role: "entree", note: "Lue au clavier." },
      {
        nom: "la somme des notes",
        role: "traitement",
        note: "Elle n'est ni demandée ni affichée : c'est un calcul intermédiaire.",
      },
      { nom: "la moyenne", role: "sortie", note: "C'est ce que l'utilisateur veut lire." },
    ],
    algo: "Variable\n    n1, n2, n3, moy : réel ;\nDébut\n    lire(n1, n2, n3)\n    moy ← (n1 + n2 + n3) / 3\n    écrire(moy)\nFin",
  },
  {
    titre: "Convertir une durée donnée en heures, minutes et secondes, en secondes.",
    grandeurs: [
      { nom: "le nombre d'heures", role: "entree", note: "Donné par l'utilisateur." },
      { nom: "le nombre de minutes", role: "entree", note: "Donné par l'utilisateur." },
      { nom: "le nombre de secondes", role: "entree", note: "Donné par l'utilisateur." },
      {
        nom: "les facteurs 3600 et 60",
        role: "traitement",
        note: "Ce sont des constantes du calcul, pas des données à lire.",
      },
      {
        nom: "la durée totale en secondes",
        role: "sortie",
        note: "Le résultat unique à afficher.",
      },
    ],
    algo: "Variable\n    h, m, s, total : entier ;\nDébut\n    lire(h, m, s)\n    total ← h * 3600 + m * 60 + s\n    écrire(total)\nFin",
  },
  {
    titre: "Dire si un élève est admis, sachant qu'il faut au moins 10 de moyenne.",
    grandeurs: [
      { nom: "la moyenne de l'élève", role: "entree", note: "Seule donnée à lire." },
      {
        nom: "le seuil de 10",
        role: "traitement",
        note: "Une constante du règlement, qui ne se lit pas au clavier.",
      },
      {
        nom: "la comparaison moyenne ≥ 10",
        role: "traitement",
        note: "C'est la décision, le cœur du traitement.",
      },
      {
        nom: "le message « Admis » ou « Ajourné »",
        role: "sortie",
        note: "La seule chose que l'utilisateur voit.",
      },
    ],
    algo: 'Variable\n    moy : réel ;\nDébut\n    lire(moy)\n    Si moy >= 10 alors\n        écrire("Admis")\n    Sinon\n        écrire("Ajourné")\n    Finsi\nFin',
  },
];

const PROBLEME_DEFAUT: Probleme = { titre: "", grandeurs: [], algo: "" };

export function AnalyseProbleme() {
  const [pi, setPi] = useState(0);
  const [rep, setRep] = useState<Record<string, Role>>({});
  const [montre, setMontre] = useState(false);

  const p = PROBLEMES[pi] ?? PROBLEME_DEFAUT;
  const bons = p.grandeurs.filter((g) => rep[g.nom] === g.role).length;
  const complet = p.grandeurs.every((g) => rep[g.nom] !== undefined);
  const tout = complet && bons === p.grandeurs.length;

  const nom = (r: Role) =>
    r === "entree" ? "Entrée" : r === "traitement" ? "Traitement" : "Sortie";

  return (
    <div className="space-y-3">
      <div className="rounded-lg border border-border bg-secondary/30 px-3 py-2.5">
        <p className="text-[11px] text-muted-foreground">
          Problème {pi + 1} sur {PROBLEMES.length}
        </p>
        <p className="text-sm font-medium">{p.titre}</p>
      </div>

      <div className="space-y-2">
        {p.grandeurs.map((g) => {
          const r = rep[g.nom];
          const ok = r === g.role;
          return (
            <div
              key={g.nom}
              className={
                r === undefined
                  ? "rounded-lg border border-border bg-background p-2.5 space-y-1.5"
                  : ok
                    ? "rounded-lg border border-emerald-500/40 bg-emerald-500/5 p-2.5 space-y-1.5"
                    : "rounded-lg border border-rose-500/40 bg-rose-500/5 p-2.5 space-y-1.5"
              }
            >
              <p className="text-xs font-medium">{g.nom}</p>
              <Choice<Role>
                value={r ?? "entree"}
                options={[
                  { value: "entree", label: "Entrée" },
                  { value: "traitement", label: "Traitement" },
                  { value: "sortie", label: "Sortie" },
                ]}
                onChange={(v) => setRep({ ...rep, [g.nom]: v })}
              />
              {r !== undefined && !ok ? (
                <p className="text-[11px] text-rose-700">
                  C&apos;est du {nom(g.role).toLowerCase()} : {g.note}
                </p>
              ) : null}
              {r !== undefined && ok ? (
                <p className="text-[11px] text-muted-foreground">{g.note}</p>
              ) : null}
            </div>
          );
        })}
      </div>

      <ScoreAnalyse bons={bons} total={p.grandeurs.length} />

      {tout ? (
        <Verdict tone="ok">
          Analyse complète. Les entrées deviendront les <code>lire</code>, les sorties les{" "}
          <code>écrire</code>, et le traitement tout ce qui se trouve entre les deux. Tu peux
          maintenant écrire l&apos;algorithme sans réfléchir deux fois.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Une grandeur que l&apos;algorithme ne peut pas deviner est une entrée. Une grandeur que
          l&apos;utilisateur attend est une sortie. Tout le reste — constantes, calculs
          intermédiaires, décisions — est du traitement.
        </Verdict>
      )}

      <div className="flex flex-wrap gap-2">
        <button
          type="button"
          onClick={() => {
            setPi((v) => (v + 1) % PROBLEMES.length);
            setRep({});
            setMontre(false);
          }}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Problème suivant
        </button>
        <button
          type="button"
          onClick={() => setMontre(!montre)}
          disabled={!complet}
          className={
            complet
              ? "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium hover:bg-secondary/60"
              : "rounded-lg border border-border bg-secondary/40 px-3 py-1.5 text-xs text-muted-foreground/50"
          }
        >
          {montre ? "Cacher l'algorithme" : "Voir l'algorithme"}
        </button>
      </div>

      {montre ? (
        <pre className="overflow-x-auto rounded-lg border border-border bg-secondary/30 p-3 font-mono text-[11px] leading-relaxed">
          {p.algo}
        </pre>
      ) : (
        <p className="text-[11px] text-muted-foreground">
          L&apos;algorithme n&apos;apparaît qu&apos;une fois toutes les grandeurs classées : on
          analyse avant d&apos;écrire, jamais l&apos;inverse.
        </p>
      )}
    </div>
  );
}

function ScoreAnalyse({ bons, total }: { bons: number; total: number }) {
  return (
    <Panel>
      <Stat label="Bien classées" value={`${bons} / ${total}`} color={PALETTE.green} />
      <Stat label="À classer" value={`${total}`} />
    </Panel>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 9 — Choisir le bon type                                    */
/* ------------------------------------------------------------------ */

export function ChoixTypes() {
  return (
    <JeuClassement
      libelleChoix="Son type en LDA"
      aide="Deux réflexes : un nombre sur lequel on ne calcule jamais est une chaîne ; et une question à deux réponses seulement est un booléen."
      options={[
        { value: "entier", label: "entier" },
        { value: "reel", label: "réel" },
        { value: "car", label: "caractère" },
        { value: "chaine", label: "chaîne" },
        { value: "bool", label: "booléen" },
      ]}
      cas={[
        {
          enonce: "Le nom et le prénom d'un élève.",
          bonne: "chaine",
          pourquoi: "C'est un texte, donc une chaîne de caractères, entre guillemets.",
        },
        {
          enonce: "L'âge d'un élève en années.",
          bonne: "entier",
          pourquoi: "On ne déclare pas 15,5 ans en état civil : c'est un nombre sans virgule.",
        },
        {
          enonce: "La moyenne annuelle.",
          bonne: "reel",
          pourquoi: "Une moyenne vaut couramment 12,75 : il faut la virgule.",
        },
        {
          enonce: "Un numéro de téléphone camerounais, 6 77 12 34 56.",
          bonne: "chaine",
          pourquoi:
            "On ne calcule jamais avec, il peut commencer par un zéro et il est trop grand : c'est du texte. La règle : un nombre sur lequel on ne calcule pas est une chaîne.",
        },
        {
          enonce: "La lettre de la série : A, C ou D.",
          bonne: "car",
          pourquoi: "Un seul signe, donc un caractère, entre apostrophes et non entre guillemets.",
        },
        {
          enonce: "La réponse à « l'élève est-il admis ? »",
          bonne: "bool",
          pourquoi: "Deux réponses possibles et pas une de plus : vrai ou faux.",
        },
        {
          enonce: "Le nombre d'élèves d'une classe.",
          bonne: "entier",
          pourquoi: "On ne compte pas 32,5 élèves.",
        },
        {
          enonce: "Le prix d'un article en FCFA.",
          bonne: "reel",
          pourquoi:
            "Même si les prix sont souvent ronds, la multiplication par 1,07 de la TVA produit des décimales : on déclare réel.",
        },
        {
          enonce: "La classe « 1ère C ».",
          bonne: "chaine",
          pourquoi: "Il y a un espace, un accent et un chiffre : c'est bien du texte.",
        },
        {
          enonce: "Le caractère '7' saisi au clavier.",
          bonne: "car",
          pourquoi:
            "Attention au piège : '7' entre apostrophes est un caractère, qu'on ne peut pas additionner. 7 sans apostrophes serait un entier.",
        },
        {
          enonce: "Le fait qu'une case à cocher soit cochée ou non.",
          bonne: "bool",
          pourquoi: "Encore un booléen : cochée ou non, rien entre les deux.",
        },
        {
          enonce: "Le matricule d'un élève : 2026-1C-047.",
          bonne: "chaine",
          pourquoi: "Il contient des tirets et des lettres : impossible d'en faire un nombre.",
        },
      ]}
    />
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 9 — Dérouler un algorithme                                 */
/* ------------------------------------------------------------------ */

type Etat = Record<string, string>;

type Programme = {
  nom: string;
  variables: ReadonlyArray<string>;
  lignes: ReadonlyArray<string>;
  etats: ReadonlyArray<Etat>;
  conclusion: string;
  tone: "ok" | "bad";
};

const VIDE = "—";

const PROGRAMMES: ReadonlyArray<Programme> = [
  {
    nom: "Échange sans variable intermédiaire",
    variables: ["a", "b"],
    lignes: ["a ← 3", "b ← 7", "a ← b", "b ← a", "écrire(a, b)"],
    etats: [
      { a: VIDE, b: VIDE },
      { a: "3", b: VIDE },
      { a: "3", b: "7" },
      { a: "7", b: "7" },
      { a: "7", b: "7" },
      { a: "7", b: "7" },
    ],
    conclusion:
      "L'algorithme affiche 7 7 : il n'échange rien. Dès la ligne a ← b, l'ancienne valeur de a — le 3 — a été écrasée, et il n'existe plus nulle part. C'est le casier du vestiaire : une seule chose à la fois.",
    tone: "bad",
  },
  {
    nom: "Échange avec variable intermédiaire",
    variables: ["a", "b", "temp"],
    lignes: ["a ← 3", "b ← 7", "temp ← a", "a ← b", "b ← temp", "écrire(a, b)"],
    etats: [
      { a: VIDE, b: VIDE, temp: VIDE },
      { a: "3", b: VIDE, temp: VIDE },
      { a: "3", b: "7", temp: VIDE },
      { a: "3", b: "7", temp: "3" },
      { a: "7", b: "7", temp: "3" },
      { a: "7", b: "3", temp: "3" },
      { a: "7", b: "3", temp: "3" },
    ],
    conclusion:
      "L'algorithme affiche 7 3 : l'échange est fait. La variable temp a mis le 3 de côté avant qu'il ne soit écrasé, et c'est pour cela qu'elle est indispensable.",
    tone: "ok",
  },
  {
    nom: "Incrémenter : x ← x + 1",
    variables: ["x"],
    lignes: ["x ← 5", "x ← x + 1", "x ← x + 1", "x ← x * 2", "écrire(x)"],
    etats: [{ x: VIDE }, { x: "5" }, { x: "6" }, { x: "7" }, { x: "14" }, { x: "14" }],
    conclusion:
      "x ← x + 1 se lit « prends la valeur actuelle de x, ajoute 1, et remets le résultat dans x ». En mathématiques la ligne serait absurde ; en algorithmique c'est l'instruction la plus utilisée du programme, car c'est elle qui fait avancer les boucles.",
    tone: "ok",
  },
];

const PROGRAMME_DEFAUT: Programme = {
  nom: "",
  variables: [],
  lignes: [],
  etats: [{}],
  conclusion: "",
  tone: "ok",
};

export function TraceVariables() {
  const [pi, setPi] = useState(0);
  const [etape, setEtape] = useState(0);

  const p = PROGRAMMES[pi] ?? PROGRAMME_DEFAUT;
  const maxE = p.lignes.length;
  const e = Math.max(0, Math.min(etape, maxE));
  const etat = p.etats[e] ?? {};
  const fini = e === maxE;

  const W = 440;
  const H = 36 + Math.max(p.lignes.length, p.variables.length + 1) * 24 + 16;
  const colX = 250;
  const largeurCol = (440 - colX - 20) / Math.max(1, p.variables.length);

  return (
    <div className="space-y-3">
      <Choice<string>
        label="Algorithme à dérouler"
        value={String(pi)}
        options={PROGRAMMES.map((q, k) => ({ value: String(k), label: q.nom }))}
        onChange={(v) => {
          setPi(Number(v));
          setEtape(0);
        }}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        {p.lignes.map((l, k) => {
          const faite = k < e;
          const courante = k === e;
          return (
            <g key={k}>
              {courante ? (
                <rect x={14} y={16 + k * 24} width={226} height={22} rx={3} fill="#fef3c7" />
              ) : null}
              <text
                x={22}
                y={31 + k * 24}
                fontSize={11}
                fontFamily="monospace"
                fontWeight={courante ? 700 : 400}
                fill={courante ? "#78350f" : faite ? "#64748b" : "#0f172a"}
              >
                {l}
              </text>
            </g>
          );
        })}

        <line
          x1={colX - 10}
          y1={10}
          x2={colX - 10}
          y2={H - 10}
          stroke="#cbd5e1"
          strokeWidth={1.2}
        />

        {p.variables.map((v, k) => (
          <text
            key={v}
            x={colX + k * largeurCol + largeurCol / 2}
            y={26}
            textAnchor="middle"
            fontSize={11}
            fontFamily="monospace"
            fontWeight={700}
            fill="#2563eb"
          >
            {v}
          </text>
        ))}

        {p.variables.map((v, k) => {
          const val = etat[v] ?? VIDE;
          return (
            <g key={`val-${v}`}>
              <rect
                x={colX + k * largeurCol + 4}
                y={36}
                width={largeurCol - 8}
                height={28}
                rx={4}
                fill={val === VIDE ? "#f1f5f9" : "#dbeafe"}
                stroke={val === VIDE ? "#cbd5e1" : "#2563eb"}
                strokeWidth={1.4}
              />
              <text
                x={colX + k * largeurCol + largeurCol / 2}
                y={55}
                textAnchor="middle"
                fontSize={13}
                fontFamily="monospace"
                fontWeight={700}
                fill={val === VIDE ? "#94a3b8" : "#1e3a8a"}
              >
                {val}
              </text>
            </g>
          );
        })}

        <text x={colX} y={92} fontSize={10} fill={PALETTE.slate}>
          {fini ? "exécution terminée" : `ligne ${e + 1} sur ${maxE}`}
        </text>
      </Board>

      <Ctrl
        label="Avancer ligne par ligne"
        value={e}
        min={0}
        max={maxE}
        step={1}
        onChange={setEtape}
        display={fini ? "fin" : `avant la ligne ${e + 1}`}
        color={PALETTE.purple}
      />

      <div className="flex gap-2">
        <button
          type="button"
          onClick={() => setEtape(Math.max(0, e - 1))}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Revenir
        </button>
        <button
          type="button"
          onClick={() => setEtape(Math.min(maxE, e + 1))}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Ligne suivante
        </button>
      </div>

      {fini ? (
        <Verdict tone={p.tone}>{p.conclusion}</Verdict>
      ) : (
        <Verdict tone="warn">
          Avant de cliquer, prédis la valeur. Une affectation se lit toujours de droite à gauche :
          on calcule ce qui est à droite, puis on le range à gauche en écrasant ce qui s&apos;y
          trouvait.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 9 — div, mod et les opérateurs logiques                    */
/* ------------------------------------------------------------------ */

export function Operateurs() {
  const [a, setA] = useState(17);
  const [b, setB] = useState(5);
  const [p1, setP1] = useState(true);
  const [p2, setP2] = useState(false);

  const q = Math.floor(a / b);
  const r = a - q * b;
  const pair = a % 2 === 0;

  const et = p1 && p2;
  const ou = p1 || p2;
  const nonP1 = !p1;

  const W = 440;
  const H = 170;

  return (
    <div className="space-y-3">
      <Panel>
        <Ctrl
          label="Dividende"
          value={a}
          min={0}
          max={999}
          step={1}
          onChange={setA}
          display={`${a}`}
        />
        <Ctrl
          label="Diviseur"
          value={b}
          min={1}
          max={99}
          step={1}
          onChange={setB}
          display={`${b}`}
          color={PALETTE.green}
        />
      </Panel>

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={220} y={22} textAnchor="middle" fontSize={11} fontWeight={700} fill={PALETTE.ink}>
          La division posée
        </text>

        <text x={60} y={60} fontSize={20} fontFamily="monospace" fill="#0f172a">
          {a}
        </text>
        <line x1={128} y1={40} x2={128} y2={92} stroke="#334155" strokeWidth={1.6} />
        <text x={140} y={60} fontSize={20} fontFamily="monospace" fill="#16a34a">
          {b}
        </text>
        <line x1={128} y1={68} x2={210} y2={68} stroke="#334155" strokeWidth={1.6} />
        <text x={140} y={90} fontSize={20} fontFamily="monospace" fontWeight={700} fill="#2563eb">
          {q}
        </text>
        <text x={60} y={90} fontSize={20} fontFamily="monospace" fontWeight={700} fill="#ea580c">
          {r}
        </text>

        <text x={248} y={50} fontSize={12} fontFamily="monospace" fill="#2563eb">
          {a} div {b} = {q}
        </text>
        <text x={248} y={70} fontSize={10} fill={PALETTE.slate}>
          le quotient, en bleu
        </text>
        <text x={248} y={94} fontSize={12} fontFamily="monospace" fill="#ea580c">
          {a} mod {b} = {r}
        </text>
        <text x={248} y={114} fontSize={10} fill={PALETTE.slate}>
          le reste, en orange
        </text>

        <text x={20} y={134} fontSize={11} fontFamily="monospace" fill="#0f172a">
          {a} = {b} × {q} + {r}
        </text>
        <text x={20} y={156} fontSize={11} fontWeight={700} fill={pair ? "#15803d" : "#b45309"}>
          {a} mod 2 = {a % 2} → {a} est {pair ? "pair" : "impair"}
        </text>
        <text x={248} y={156} fontSize={10} fill={PALETTE.slate}>
          unités : {a} mod 10 = {a % 10}
        </text>
      </Board>

      <Panel>
        <Stat label="Quotient (div)" value={`${q}`} />
        <Stat label="Reste (mod)" value={`${r}`} color={PALETTE.orange} />
        <Stat label="Division réelle" value={`${fmt(a / b, 3)}`} color={PALETTE.purple} />
        <Stat
          label={`${a} est`}
          value={pair ? "pair" : "impair"}
          color={pair ? PALETTE.green : PALETTE.red}
        />
      </Panel>

      <Verdict tone="warn">
        Ne confonds pas <code>div</code> et <code>/</code> : {a} div {b} donne {q}, un entier,
        tandis que {a} / {b} donne {fmt(a / b, 3)}. Et retiens que <code>n mod 2 = 0</code> est la
        façon de tester si un nombre est pair — c&apos;est la question la plus fréquente du
        Probatoire, et elle tient en un mod.
      </Verdict>

      <div className="rounded-lg border border-border bg-background p-3 space-y-2">
        <p className="text-xs font-semibold">Les opérateurs logiques</p>

        <div className="flex flex-wrap gap-1.5">
          <button
            type="button"
            onClick={() => setP1(!p1)}
            className={
              p1
                ? "rounded-lg bg-emerald-600 px-3 py-1.5 text-xs font-semibold text-white"
                : "rounded-lg bg-rose-600 px-3 py-1.5 text-xs font-semibold text-white"
            }
          >
            moyenne ≥ 10 : {p1 ? "vrai" : "faux"}
          </button>
          <button
            type="button"
            onClick={() => setP2(!p2)}
            className={
              p2
                ? "rounded-lg bg-emerald-600 px-3 py-1.5 text-xs font-semibold text-white"
                : "rounded-lg bg-rose-600 px-3 py-1.5 text-xs font-semibold text-white"
            }
          >
            absences &lt; 5 : {p2 ? "vrai" : "faux"}
          </button>
        </div>

        <Panel>
          <Stat
            label="(moyenne ≥ 10) et (absences < 5)"
            value={et ? "vrai" : "faux"}
            color={et ? PALETTE.green : PALETTE.red}
          />
          <Stat
            label="(moyenne ≥ 10) ou (absences < 5)"
            value={ou ? "vrai" : "faux"}
            color={ou ? PALETTE.green : PALETTE.red}
          />
          <Stat
            label="non (moyenne ≥ 10)"
            value={nonP1 ? "vrai" : "faux"}
            color={nonP1 ? PALETTE.green : PALETTE.red}
          />
          <Stat label="Conclusion du conseil" value={et ? "Admis" : "Cas examiné"} />
        </Panel>

        <Verdict tone={et ? "ok" : "warn"}>
          {et
            ? "Les deux conditions sont vraies : le et est vrai, et l'élève est admis sans discussion."
            : ou
              ? "Une seule des deux est vraie : le ou suffirait, mais le et exige les DEUX. C'est toute la différence entre les deux opérateurs."
              : "Aucune des deux n'est vraie : ni le et ni le ou ne passent."}
        </Verdict>
      </div>
    </div>
  );
}
