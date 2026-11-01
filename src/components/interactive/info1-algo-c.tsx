import { useState } from "react";
import { Board, Choice, Ctrl, PALETTE, Panel, Stat, Verdict } from "./controls";
import { JeuClassement } from "./info1-jeux";

/** Informatique 1ère A, C et D — chapitre 12 : procédures, fonctions, récursivité. */

function clamp(v: number, lo: number, hi: number) {
  return Math.max(lo, Math.min(hi, v));
}

/* ------------------------------------------------------------------ */
/* Chapitre 12 — Procédure ou fonction ?                               */
/* ------------------------------------------------------------------ */

export function FonctionProcedure() {
  return (
    <JeuClassement
      libelleChoix="Procédure ou fonction ?"
      aide="La question qui tranche : le résultat se récupère-t-il dans une variable ? Si oui, c'est une fonction. Si on l'appelle juste pour qu'il fasse quelque chose, c'est une procédure."
      options={[
        { value: "proc", label: "Procédure" },
        { value: "fonc", label: "Fonction" },
      ]}
      cas={[
        {
          enonce: "Afficher le bulletin d'un élève à l'écran.",
          bonne: "proc",
          pourquoi:
            "Elle agit, elle ne rend rien : on ne récupère pas un bulletin dans une variable.",
        },
        {
          enonce: "Calculer la moyenne de trois notes.",
          bonne: "fonc",
          pourquoi: "On écrit moy ← moyenne(n1, n2, n3) : le résultat se récupère, donc retourner.",
        },
        {
          enonce: "Tester si un entier est pair.",
          bonne: "fonc",
          pourquoi: "Elle renvoie un booléen, vrai ou faux, qu'on utilisera dans un Si.",
        },
        {
          enonce: "Tracer une ligne de tirets pour séparer deux parties d'un affichage.",
          bonne: "proc",
          pourquoi: "Un pur effet à l'écran, aucun résultat à rapporter.",
        },
        {
          enonce: "Trier un tableau de notes dans l'ordre croissant.",
          bonne: "proc",
          pourquoi:
            "Elle modifie le tableau sur place et ne renvoie rien. C'est une procédure, même si elle travaille beaucoup.",
        },
        {
          enonce: "Donner le plus grand élément d'un tableau.",
          bonne: "fonc",
          pourquoi: "Un seul résultat à rapporter : max ← maximum(tab, n).",
        },
        {
          enonce: "Vider l'écran avant d'afficher un nouveau menu.",
          bonne: "proc",
          pourquoi: "Une action, et rien d'autre.",
        },
        {
          enonce: "Calculer le prix toutes taxes comprises d'un achat.",
          bonne: "fonc",
          pourquoi:
            "On écrit p ← prixTTC(7500, 5), et on peut même s'en servir directement dans un Si ou un écrire.",
        },
        {
          enonce: "Demander son mot de passe à l'utilisateur et le renvoyer.",
          bonne: "fonc",
          pourquoi:
            "Elle fait bien quelque chose à l'écran, mais elle rapporte une valeur : c'est le retourner qui décide, pas l'affichage.",
        },
        {
          enonce: "Enregistrer les notes d'une classe dans un fichier.",
          bonne: "proc",
          pourquoi: "Un travail à faire, sans valeur à rapporter.",
        },
      ]}
    />
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 12 — Passer des paramètres                                 */
/* ------------------------------------------------------------------ */

type TypeParam = "chaine" | "reel";

const SOUS_PROG = {
  nom: "afficherEleve",
  formels: [
    { nom: "nom", type: "chaine" as TypeParam },
    { nom: "moy", type: "reel" as TypeParam },
  ],
};

const VALEURS: ReadonlyArray<{ id: string; texte: string; type: TypeParam }> = [
  { id: "v1", texte: '"Thierry"', type: "chaine" },
  { id: "v2", texte: '"Aïssatou"', type: "chaine" },
  { id: "v3", texte: "13.5", type: "reel" },
  { id: "v4", texte: "8", type: "reel" },
];

const VALEUR_DEFAUT = VALEURS[0] ?? { id: "v1", texte: "", type: "chaine" as TypeParam };

export function ProcedureParametres() {
  const [arg1, setArg1] = useState("v1");
  const [arg2, setArg2] = useState("v3");
  const [lance, setLance] = useState(false);

  const a1 = VALEURS.find((v) => v.id === arg1) ?? VALEUR_DEFAUT;
  const a2 = VALEURS.find((v) => v.id === arg2) ?? VALEUR_DEFAUT;
  const f1 = SOUS_PROG.formels[0] ?? { nom: "nom", type: "chaine" as TypeParam };
  const f2 = SOUS_PROG.formels[1] ?? { nom: "moy", type: "reel" as TypeParam };

  const ok1 = a1.type === f1.type;
  const ok2 = a2.type === f2.type;
  const valide = ok1 && ok2;
  const moyenne = Number(a2.texte);
  const admis = Number.isFinite(moyenne) && moyenne >= 10;

  const W = 440;
  const H = 230;

  return (
    <div className="space-y-3">
      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />

        <text x={14} y={22} fontSize={10} fill={PALETTE.slate}>
          La déclaration — ses paramètres sont dits FORMELS : ce sont des noms, pas des valeurs.
        </text>
        <rect x={14} y={30} width={412} height={26} rx={4} fill="#dbeafe" />
        <text x={24} y={47} fontSize={11} fontFamily="monospace" fontWeight={700} fill="#1e3a8a">
          Procédure {SOUS_PROG.nom}({f1.nom} : {f1.type === "chaine" ? "chaîne" : "réel"} ; {f2.nom}{" "}
          : {f2.type === "chaine" ? "chaîne" : "réel"})
        </text>

        <text x={14} y={82} fontSize={10} fill={PALETTE.slate}>
          Ton appel — ses paramètres sont dits EFFECTIFS : ce sont de vraies valeurs.
        </text>
        <rect x={14} y={90} width={412} height={26} rx={4} fill={valide ? "#dcfce7" : "#fee2e2"} />
        <text
          x={24}
          y={107}
          fontSize={11}
          fontFamily="monospace"
          fontWeight={700}
          fill={valide ? "#14532d" : "#7f1d1d"}
        >
          {SOUS_PROG.nom}({a1.texte}, {a2.texte})
        </text>

        <line
          x1={120}
          y1={58}
          x2={120}
          y2={88}
          stroke={ok1 ? "#15803d" : "#b91c1c"}
          strokeWidth={1.8}
          strokeDasharray={ok1 ? undefined : "4 3"}
        />
        <line
          x1={250}
          y1={58}
          x2={250}
          y2={88}
          stroke={ok2 ? "#15803d" : "#b91c1c"}
          strokeWidth={1.8}
          strokeDasharray={ok2 ? undefined : "4 3"}
        />
        <text x={126} y={76} fontSize={9} fill={ok1 ? "#15803d" : "#b91c1c"}>
          {ok1 ? "types d'accord" : "mauvais type"}
        </text>
        <text x={256} y={76} fontSize={9} fill={ok2 ? "#15803d" : "#b91c1c"}>
          {ok2 ? "types d'accord" : "mauvais type"}
        </text>

        <rect x={14} y={132} width={412} height={82} rx={6} fill="#0f172a" />
        {!lance ? (
          <text x={220} y={178} textAnchor="middle" fontSize={11} fill="#64748b">
            écran — clique sur Exécuter l&apos;appel
          </text>
        ) : !valide ? (
          <>
            <text x={30} y={158} fontSize={11} fontFamily="monospace" fill="#f87171">
              Erreur : les paramètres ne correspondent pas.
            </text>
            <text x={30} y={178} fontSize={10} fontFamily="monospace" fill="#fca5a5">
              {f1.nom} attend {f1.type === "chaine" ? "une chaîne" : "un réel"}, {f2.nom} attend{" "}
              {f2.type === "chaine" ? "une chaîne" : "un réel"}.
            </text>
            <text x={30} y={198} fontSize={10} fontFamily="monospace" fill="#fca5a5">
              L&apos;ordre des paramètres compte.
            </text>
          </>
        ) : (
          <>
            <text x={30} y={158} fontSize={11} fontFamily="monospace" fill="#4ade80">
              Élève : {a1.texte.replace(/"/g, "")}
            </text>
            <text x={30} y={178} fontSize={11} fontFamily="monospace" fill="#4ade80">
              Moyenne : {a2.texte}
            </text>
            <text
              x={30}
              y={198}
              fontSize={11}
              fontFamily="monospace"
              fontWeight={700}
              fill={admis ? "#4ade80" : "#fbbf24"}
            >
              {admis ? "Admis" : "Ajourné"}
            </text>
          </>
        )}
      </Board>

      <Choice<string>
        label="Premier paramètre effectif"
        value={arg1}
        options={VALEURS.map((v) => ({ value: v.id, label: v.texte }))}
        onChange={(v) => {
          setArg1(v);
          setLance(false);
        }}
      />

      <Choice<string>
        label="Deuxième paramètre effectif"
        value={arg2}
        options={VALEURS.map((v) => ({ value: v.id, label: v.texte }))}
        onChange={(v) => {
          setArg2(v);
          setLance(false);
        }}
      />

      <button
        type="button"
        onClick={() => setLance(true)}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        Exécuter l&apos;appel
      </button>

      <Panel>
        <Stat
          label="Paramètre nom"
          value={ok1 ? "correct" : "mauvais type"}
          color={ok1 ? PALETTE.green : PALETTE.red}
        />
        <Stat
          label="Paramètre moy"
          value={ok2 ? "correct" : "mauvais type"}
          color={ok2 ? PALETTE.green : PALETTE.red}
        />
      </Panel>

      {!valide ? (
        <Verdict tone="bad">
          L&apos;appel est refusé. Les paramètres effectifs remplacent les formels{" "}
          <strong>dans l&apos;ordre</strong> et avec les <strong>bons types</strong>. Essaie
          d&apos;inverser les deux valeurs : tu obtiendras la même erreur, parce que l&apos;ordre
          compte autant que le type.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          L&apos;appel passe. À l&apos;entrée de la procédure, {f1.nom} vaut {a1.texte} et {f2.nom}{" "}
          vaut {a2.texte} ; à la sortie, les deux disparaissent — ce sont des paramètres, et ils
          n&apos;existent que pendant l&apos;exécution, comme les variables locales.
        </Verdict>
      )}

      <div className="rounded-lg border border-border bg-background p-3 space-y-1">
        <p className="text-xs font-semibold">Une variable locale, en une phrase</p>
        <p className="text-[11px] text-muted-foreground">
          Une variable déclarée à l&apos;intérieur d&apos;un sous-programme naît à l&apos;entrée et
          meurt à la sortie. Le programme principal ne la voit pas — et c&apos;est heureux : un
          autre <code>i</code> ailleurs n&apos;entre pas en conflit avec celui-ci.
        </p>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 12 — La récursivité                                        */
/* ------------------------------------------------------------------ */

type Recursive = "factorielle" | "somme" | "fibonacci";

const DEFS: Record<Recursive, { nom: string; code: string; base: string; formule: string }> = {
  factorielle: {
    nom: "factorielle(n)",
    code: "Fonction factorielle(n : entier) : entier\nDébut\n    Si n = 0 alors\n        retourner 1\n    Sinon\n        retourner n * factorielle(n - 1)\n    Finsi\nFinFonction",
    base: "factorielle(0) = 1",
    formule: "factorielle(n) = n × factorielle(n − 1)",
  },
  somme: {
    nom: "somme(n)",
    code: "Fonction somme(n : entier) : entier\nDébut\n    Si n = 0 alors\n        retourner 0\n    Sinon\n        retourner n + somme(n - 1)\n    Finsi\nFinFonction",
    base: "somme(0) = 0",
    formule: "somme(n) = n + somme(n − 1)",
  },
  fibonacci: {
    nom: "fibonacci(n)",
    code: "Fonction fibonacci(n : entier) : entier\nDébut\n    Si n <= 1 alors\n        retourner n\n    Sinon\n        retourner fibonacci(n-1) + fibonacci(n-2)\n    Finsi\nFinFonction",
    base: "fibonacci(0) = 0 et fibonacci(1) = 1",
    formule: "fibonacci(n) = fibonacci(n − 1) + fibonacci(n − 2)",
  },
};

function calcul(f: Recursive, n: number): number {
  if (f === "factorielle") {
    let r = 1;
    for (let k = 2; k <= n; k += 1) r *= k;
    return r;
  }
  if (f === "somme") return (n * (n + 1)) / 2;
  let a = 0;
  let b = 1;
  if (n === 0) return 0;
  for (let k = 2; k <= n; k += 1) {
    const c = a + b;
    a = b;
    b = c;
  }
  return b;
}

export function Recursivite() {
  const [f, setF] = useState<Recursive>("factorielle");
  const [n, setN] = useState(4);
  const [sansBase, setSansBase] = useState(false);

  const d = DEFS[f];
  const nn = clamp(Math.round(n), 0, 9);

  // pile des appels : descente puis remontée (cas simple, un seul appel par niveau)
  const niveaux: number[] = [];
  if (f === "fibonacci") {
    for (let k = nn; k >= 0; k -= 1) niveaux.push(k);
  } else {
    for (let k = nn; k >= 0; k -= 1) niveaux.push(k);
  }
  const profondeur = sansBase ? 9 : niveaux.length;
  const resultat = calcul(f, nn);

  const chaine =
    f === "factorielle"
      ? Array.from({ length: nn }, (_, k) => nn - k).join(" × ") + (nn === 0 ? "1" : " × 1")
      : f === "somme"
        ? Array.from({ length: nn }, (_, k) => nn - k).join(" + ") + (nn === 0 ? "0" : " + 0")
        : "";

  const W = 440;
  const H = 36 + profondeur * 20;

  return (
    <div className="space-y-3">
      <Choice<Recursive>
        label="Fonction récursive"
        value={f}
        options={[
          { value: "factorielle", label: "Factorielle" },
          { value: "somme", label: "Somme de 1 à n" },
          { value: "fibonacci", label: "Fibonacci" },
        ]}
        onChange={(v) => setF(v)}
      />

      <Ctrl
        label="Valeur de n"
        value={nn}
        min={0}
        max={9}
        step={1}
        onChange={setN}
        display={`n = ${nn}`}
      />

      <Board width={W} height={H}>
        <rect width={W} height={H} fill="#ffffff" />
        <text x={14} y={18} fontSize={10} fill={PALETTE.slate}>
          {sansBase
            ? "La pile des appels, sans cas de base"
            : "La pile des appels : elle descend, puis les résultats remontent"}
        </text>

        {sansBase
          ? Array.from({ length: 9 }).map((_, k) => (
              <g key={k}>
                <rect
                  x={14 + k * 12}
                  y={26 + k * 20}
                  width={380 - k * 12}
                  height={17}
                  rx={3}
                  fill="#fee2e2"
                  stroke="#b91c1c"
                  strokeWidth={1}
                />
                <text
                  x={22 + k * 12}
                  y={39 + k * 20}
                  fontSize={10}
                  fontFamily="monospace"
                  fill="#7f1d1d"
                >
                  {d.nom.replace("n", String(nn - k))}
                  {k === 8 ? "   … la pile continue de grandir sans fin" : ""}
                </text>
              </g>
            ))
          : niveaux.map((v, k) => {
              const estBase = v === 0 || (f === "fibonacci" && v <= 1);
              return (
                <g key={k}>
                  <rect
                    x={14 + k * 12}
                    y={26 + k * 20}
                    width={380 - k * 12}
                    height={17}
                    rx={3}
                    fill={estBase ? "#dcfce7" : "#dbeafe"}
                    stroke={estBase ? "#15803d" : "#2563eb"}
                    strokeWidth={1}
                  />
                  <text
                    x={22 + k * 12}
                    y={39 + k * 20}
                    fontSize={10}
                    fontFamily="monospace"
                    fill={estBase ? "#14532d" : "#1e3a8a"}
                  >
                    {d.nom.replace("n", String(v))}{" "}
                    {estBase
                      ? `= ${calcul(f, v)}  ← cas de base, on arrête`
                      : `= ${v} ${f === "somme" ? "+" : f === "factorielle" ? "×" : "+"} …`}
                  </text>
                </g>
              );
            })}
      </Board>

      <pre className="overflow-x-auto rounded-lg border border-border bg-secondary/30 p-3 font-mono text-[11px] leading-relaxed">
        {sansBase
          ? d.code.replace(/    Si n [^\n]*\n        retourner [^\n]*\n    Sinon\n/, "")
          : d.code}
      </pre>

      <button
        type="button"
        onClick={() => setSansBase(!sansBase)}
        className={
          sansBase
            ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            : "rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        }
      >
        {sansBase ? "Remettre le cas de base" : "Supprimer le cas de base"}
      </button>

      <Panel>
        <Stat
          label="Cas de base"
          value={sansBase ? "absent" : d.base}
          color={sansBase ? PALETTE.red : PALETTE.green}
        />
        <Stat label="Relation" value={d.formule} />
        <Stat
          label="Appels empilés"
          value={sansBase ? "∞" : `${niveaux.length}`}
          color={PALETTE.purple}
        />
        <Stat label="Résultat" value={sansBase ? "jamais" : `${resultat}`} color={PALETTE.orange} />
      </Panel>

      {sansBase ? (
        <Verdict tone="bad">
          Sans cas de base, la fonction s&apos;appelle indéfiniment : la pile grandit jusqu&apos;à
          saturer la mémoire, et la machine arrête le programme. C&apos;est l&apos;équivalent exact
          de la boucle infinie. Toute fonction récursive a donc{" "}
          <strong>deux parties obligatoires</strong> : le cas de base, qu&apos;on sait résoudre sans
          se rappeler, et le cas récursif, qui s&apos;appelle sur un problème{" "}
          <strong>plus petit</strong>.
        </Verdict>
      ) : chaine !== "" ? (
        <Verdict tone="ok">
          La descente atteint le cas de base, puis les résultats remontent :{" "}
          <span className="font-mono">
            {chaine} = {resultat}
          </span>
          .
          {f === "somme"
            ? ` La formule directe donne ${nn} × ${nn + 1} / 2 = ${resultat} : les deux concordent.`
            : ""}
        </Verdict>
      ) : (
        <Verdict tone="ok">
          Fibonacci appelle deux fois par niveau — la vraie pile est donc un arbre, et non la
          colonne simplifiée dessinée ici. C&apos;est pour cela que cette version devient très lente
          dès n = 30 : elle recalcule mille fois les mêmes valeurs.
        </Verdict>
      )}

      <p className="text-[11px] text-muted-foreground">
        En examen, vérifie toujours ta récursivité sur une petite valeur, 3 ou 4. Si la descente
        n&apos;atteint pas le cas de base, l&apos;erreur se voit immédiatement.
      </p>
    </div>
  );
}
