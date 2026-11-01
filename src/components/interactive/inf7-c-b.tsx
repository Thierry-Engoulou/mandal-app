import { useState } from "react";
import { Choice, Ctrl, PALETTE, Panel, Stat, Verdict } from "./controls";
import { Cases, Code, Console } from "./inf7-noyau";

/** Informatique Terminale C et D — chapitres 24 et 25 : structures de contrôle et tableaux en C. */

/* ------------------------------------------------------------------ */
/* Chapitre 24 — if, else if, et le piège du =                         */
/* ------------------------------------------------------------------ */

export function IfElseC() {
  const [moy, setMoy] = useState(18);
  const [abs, setAbs] = useState(2);
  const [cond, setCond] = useState("moy >= 10 && abs < 5");
  const [unSeulEgal, setUnSeulEgal] = useState(false);
  const [pvApres, setPvApres] = useState(false);

  // Évaluation de la condition choisie, sur les valeurs courantes.
  const vraie = (() => {
    if (unSeulEgal) return true; // if (moy = 10) : l'affectation rend 10, donc vrai
    const c = cond.replace(/moy/g, String(moy)).replace(/abs/g, String(abs));
    const et = c.split("&&").map((x) => x.trim());
    const test = (s: string) => {
      const m = /^([\d.]+)\s*(>=|<=|==|!=|>|<)\s*([\d.]+)$/.exec(s);
      if (!m) return false;
      const a = Number(m[1]);
      const b = Number(m[3]);
      const op = m[2];
      if (op === ">=") return a >= b;
      if (op === "<=") return a <= b;
      if (op === ">") return a > b;
      if (op === "<") return a < b;
      if (op === "==") return a === b;
      return a !== b;
    };
    if (c.includes("||")) return c.split("||").some((x) => test(x.trim()));
    return et.every(test);
  })();

  // Avec un point-virgule après le if, le bloc s'exécute toujours.
  const brancheOui = pvApres ? true : vraie;
  const moyApres = unSeulEgal ? 10 : moy;

  const lignes = [
    "#include <stdio.h>",
    "",
    "int main()",
    "{",
    `    float moy = ${moy};`,
    `    int abs = ${abs};`,
    "",
    unSeulEgal ? `    if (moy = 10)${pvApres ? ";" : ""}` : `    if (${cond})${pvApres ? ";" : ""}`,
    "    {",
    '        printf("Admis\\n");',
    "    }",
    "    else",
    "    {",
    '        printf("Refuse\\n");',
    "    }",
    "    return 0;",
    "}",
  ];

  return (
    <div className="space-y-3">
      <div className="grid gap-2 sm:grid-cols-2">
        <Ctrl
          label="moy"
          value={moy}
          min={0}
          max={20}
          step={0.5}
          onChange={setMoy}
          display={moy.toLocaleString("fr-FR")}
        />
        <Ctrl
          label="abs"
          value={abs}
          min={0}
          max={12}
          step={1}
          onChange={setAbs}
          display={`${abs}`}
        />
      </div>

      <Choice<string>
        label="La condition"
        value={cond}
        options={[
          { value: "moy >= 10 && abs < 5", label: "moy >= 10 && abs < 5" },
          { value: "moy >= 10 || abs < 5", label: "moy >= 10 || abs < 5" },
          { value: "moy >= 16", label: "moy >= 16" },
        ]}
        onChange={(v) => {
          setCond(v);
          setUnSeulEgal(false);
        }}
      />

      <Code
        lignes={lignes}
        eclairee={brancheOui ? 9 : 13}
        tonEclairee={brancheOui ? "ok" : "bad"}
      />

      <Panel>
        <Stat
          label="La condition vaut"
          value={unSeulEgal ? "10 → vrai" : vraie ? "vrai" : "faux"}
          color={brancheOui ? PALETTE.green : PALETTE.red}
        />
        <Stat
          label="moy après le if"
          value={moyApres.toLocaleString("fr-FR")}
          color={unSeulEgal ? PALETTE.red : PALETTE.ink}
        />
      </Panel>

      <Console lignes={[brancheOui ? "Admis" : "Refuse", ...(pvApres ? ["Refuse"] : [])]} />

      <div className="flex flex-wrap gap-1.5">
        <button
          type="button"
          onClick={() => {
            setUnSeulEgal((v) => !v);
            setPvApres(false);
          }}
          className={
            unSeulEgal
              ? "rounded-lg bg-rose-600 px-2.5 py-1.5 text-xs font-semibold text-white"
              : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
          }
        >
          Remplacer == par =
        </button>
        <button
          type="button"
          onClick={() => setPvApres((v) => !v)}
          className={
            pvApres
              ? "rounded-lg bg-rose-600 px-2.5 py-1.5 text-xs font-semibold text-white"
              : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
          }
        >
          Mettre un ; après le if
        </button>
      </div>

      {unSeulEgal ? (
        <Verdict tone="bad">
          <span className="font-mono">if (moy = 10)</span> ne compare rien. Il{" "}
          <strong>affecte</strong> 10 à <span className="font-mono">moy</span>, puis juge la valeur
          10 — qui n&apos;est pas zéro, donc vraie. Résultat : le message « Admis » s&apos;affiche{" "}
          <strong>toujours</strong>, quelle que soit la moyenne, et la vraie moyenne de {moy} vient
          d&apos;être <strong>écrasée</strong>. Et le compilateur n&apos;émet{" "}
          <strong>aucune erreur</strong> : c&apos;est ce qui rend cette faute si dangereuse, et
          c&apos;est la première à chercher dans un exercice de correction d&apos;erreurs.
        </Verdict>
      ) : pvApres ? (
        <Verdict tone="bad">
          Le point-virgule a donné au <span className="font-mono">if</span> un corps{" "}
          <strong>vide</strong> : il teste la condition, puis ne fait rien. Le bloc entre accolades
          n&apos;appartient plus au <span className="font-mono">if</span>, il s&apos;exécute{" "}
          <strong>toujours</strong> — et le <span className="font-mono">else</span> qui suit est
          même refusé par le compilateur, puisqu&apos;il n&apos;a plus de{" "}
          <span className="font-mono">if</span> auquel se rattacher. Un seul caractère, et le
          programme ne fait plus du tout ce qu&apos;il dit.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          La branche prise est éclairée dans le code. Trois règles d&apos;écriture : la condition{" "}
          <strong>entre parenthèses</strong>, <strong>jamais de point-virgule</strong> après la
          parenthèse, et le mot <span className="font-mono">else</span> et non « sinon ». Et en C,{" "}
          <span className="font-mono">&amp;&amp;</span> pour le « et »,{" "}
          <span className="font-mono">||</span> pour le « ou ».
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 24 — Le switch                                             */
/* ------------------------------------------------------------------ */

const CASES_MOIS = [
  { v: "1", label: "janvier", jours: "31 jours" },
  { v: "4", label: "avril", jours: "30 jours" },
  { v: "2", label: "février", jours: "28 jours" },
] as const;

const REFUS_SWITCH = [
  {
    id: "interv",
    label: "case 10..12 :",
    msg: "error: expected ':' before '.' token",
    mot: "Un case n'accepte qu'une VALEUR unique et constante, jamais un intervalle. C'est pour cela que les mentions exigent des else if en chaîne.",
  },
  {
    id: "float",
    label: "switch (moyenne) avec un float",
    msg: "error: switch quantity not an integer",
    mot: "L'expression d'un switch doit être entière ou de type char. Un float est refusé, et c'est logique : on ne peut pas énumérer toutes les valeurs réelles.",
  },
  {
    id: "var",
    label: "case n :  avec n une variable",
    msg: "error: case label does not reduce to an integer constant",
    mot: "Un case doit être connu à la compilation : une constante, pas une variable.",
  },
] as const;

export function SwitchC() {
  const [val, setVal] = useState("1");
  const [breaks, setBreaks] = useState<Record<string, boolean>>({
    "1": true,
    "4": true,
    "2": true,
  });
  const [refus, setRefus] = useState<string | null>(null);
  const [compare, setCompare] = useState<"mois" | "mentions">("mois");

  // Avec un break manquant, l'exécution dégringole dans les cas suivants.
  const sortie: string[] = [];
  let actif = false;
  for (const c of CASES_MOIS) {
    if (c.v === val) actif = true;
    if (actif) {
      sortie.push(c.jours);
      if (breaks[c.v]) break;
    }
  }
  if (!actif) sortie.push("Numero de mois invalide");

  const r = REFUS_SWITCH.find((x) => x.id === refus);

  return (
    <div className="space-y-3">
      <Choice<"mois" | "mentions">
        label="Le problème"
        value={compare}
        options={[
          { value: "mois", label: "Les jours d'un mois" },
          { value: "mentions", label: "Les mentions" },
        ]}
        onChange={setCompare}
      />

      {compare === "mois" ? (
        <>
          <Code
            lignes={[
              `    int mois = ${val};`,
              "",
              "    switch (mois)",
              "    {",
              ...CASES_MOIS.flatMap((c) => [
                `        case ${c.v} :`,
                `            printf("${c.jours}\\n");`,
                breaks[c.v] ? "            break;" : "            /* break retiré */",
              ]),
              "        default :",
              '            printf("Numero de mois invalide\\n");',
              "    }",
            ]}
          />

          <Choice<string>
            label="Valeur de mois"
            value={val}
            options={[
              ...CASES_MOIS.map((c) => ({ value: c.v, label: `${c.v} (${c.label})` })),
              { value: "13", label: "13 (hors cas)" },
            ]}
            onChange={setVal}
          />

          <div className="space-y-1">
            <p className="text-xs font-medium text-muted-foreground">Retire les break un par un</p>
            <div className="flex flex-wrap gap-1.5">
              {CASES_MOIS.map((c) => (
                <button
                  key={c.v}
                  type="button"
                  onClick={() => setBreaks({ ...breaks, [c.v]: !breaks[c.v] })}
                  className={
                    breaks[c.v]
                      ? "rounded-lg border border-emerald-500/50 bg-emerald-500/10 px-2.5 py-1 font-mono text-[11px] text-emerald-700"
                      : "rounded-lg border border-rose-500/50 bg-rose-500/10 px-2.5 py-1 font-mono text-[11px] text-rose-700"
                  }
                >
                  case {c.v} : break {breaks[c.v] ? "présent" : "retiré"}
                </button>
              ))}
            </div>
          </div>

          <Console lignes={sortie} />

          {sortie.length > 1 && actif ? (
            <Verdict tone="bad">
              {sortie.length} lignes affichées pour un seul cas. Sans{" "}
              <span className="font-mono">break</span>, l&apos;exécution{" "}
              <strong>dégringole dans les cas suivants</strong> : elle ne s&apos;arrête qu&apos;au
              premier <span className="font-mono">break</span> rencontré, ou à la fin du{" "}
              <span className="font-mono">switch</span>. C&apos;est l&apos;erreur classique, et le
              compilateur ne dit rien.
            </Verdict>
          ) : !actif ? (
            <Verdict tone="warn">
              Aucun <span className="font-mono">case</span> ne correspond : on tombe dans le{" "}
              <span className="font-mono">default</span>, l&apos;équivalent du{" "}
              <span className="font-mono">Autre</span> du LDA. Sans lui, une valeur imprévue ne
              produirait <strong>rien du tout</strong>.
            </Verdict>
          ) : (
            <Verdict tone="ok">
              Un seul message : le <span className="font-mono">break</span> a bien arrêté
              l&apos;exécution. Retire-le pour voir la chute. Et note qu&apos;elle est parfois{" "}
              <em>voulue</em> : des <span className="font-mono">case</span> vides enchaînés groupent
              plusieurs valeurs sur le même traitement, comme les sept mois de 31 jours.
            </Verdict>
          )}
        </>
      ) : (
        <div className="space-y-2">
          <div className="grid gap-2 sm:grid-cols-2">
            <div className="space-y-1 rounded-lg border-2 border-rose-500/40 bg-rose-500/5 p-2.5">
              <p className="text-xs font-semibold text-rose-700">En switch — impossible</p>
              <pre className="font-mono text-[10px] text-muted-foreground">
                {`switch (moy)
{
    case 16..20 : "Tres bien"
    case 14..16 : "Bien"
}`}
              </pre>
              <p className="text-[11px] text-muted-foreground">
                Deux refus en un : <strong>un intervalle</strong> dans un{" "}
                <span className="font-mono">case</span>, et un <strong>float</strong> dans le{" "}
                <span className="font-mono">switch</span>.
              </p>
            </div>
            <div className="space-y-1 rounded-lg border-2 border-emerald-500/40 bg-emerald-500/5 p-2.5">
              <p className="text-xs font-semibold text-emerald-700">En else if — correct</p>
              <pre className="font-mono text-[10px] text-muted-foreground">
                {`if (moy >= 16)
    printf("Tres bien\\n");
else if (moy >= 14)
    printf("Bien\\n");
else
    printf("Ajourne\\n");`}
              </pre>
              <p className="text-[11px] text-muted-foreground">
                Les intervalles passent, et l&apos;ordre du plus exigeant au moins exigeant reste
                capital.
              </p>
            </div>
          </div>
          <Verdict tone="ok">
            La question à se poser, une fois pour toutes :{" "}
            <strong>est-ce que je compare à des valeurs précises, ou à des intervalles ?</strong>{" "}
            Valeurs précises et entières → <span className="font-mono">switch</span>. Intervalles ou
            réels → <span className="font-mono">else if</span> en chaîne.
          </Verdict>
        </div>
      )}

      <div className="space-y-1.5 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">
          Ce que le switch refuse, et pourquoi
        </p>
        <div className="flex flex-wrap gap-1.5">
          {REFUS_SWITCH.map((x) => (
            <button
              key={x.id}
              type="button"
              onClick={() => setRefus(x.id)}
              className={
                refus === x.id
                  ? "rounded-lg bg-rose-600 px-2.5 py-1.5 font-mono text-[10px] font-semibold text-white"
                  : "rounded-lg border border-border bg-background px-2.5 py-1.5 font-mono text-[10px] text-muted-foreground hover:bg-secondary/60"
              }
            >
              {x.label}
            </button>
          ))}
        </div>
        {r ? (
          <>
            <Console lignes={[`> gcc main.c`, r.msg]} titre="Compilation" />
            <Verdict tone="bad">{r.mot}</Verdict>
          </>
        ) : null}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 24 — Traduire les boucles                                  */
/* ------------------------------------------------------------------ */

const TRADUCTIONS = [
  {
    id: "tq",
    lda: ["i ← 1", "TantQue i <= 5 faire", "    écrire(i)", "    i ← i + 1", "FinTantQue"],
    bonne: ["i = 1;", "while (i <= 5)", "{", '    printf("%d ", i);', "    i++;", "}"],
    morceaux: [
      "i = 1;",
      "while (i <= 5)",
      "while (i > 5)",
      "{",
      '    printf("%d ", i);',
      "    i++;",
      "}",
    ],
    attendus: [0, 1, 3, 4, 5, 6],
    sortieLda: "1 2 3 4 5",
  },
  {
    id: "rep",
    lda: ["i ← 1", "Répéter", "    écrire(i)", "    i ← i + 1", "Jusqu'à i > 5"],
    bonne: ["i = 1;", "do", "{", '    printf("%d ", i);', "    i++;", "}", "while (i <= 5);"],
    morceaux: [
      "i = 1;",
      "do",
      "{",
      '    printf("%d ", i);',
      "    i++;",
      "}",
      "while (i <= 5);",
      "while (i > 5);",
    ],
    attendus: [0, 1, 2, 3, 4, 5, 6],
    sortieLda: "1 2 3 4 5",
  },
  {
    id: "pour",
    lda: ["Pour i de 1 à 5 faire", "    écrire(i)", "FinPour"],
    bonne: ["for (i = 1 ; i <= 5 ; i++)", "{", '    printf("%d ", i);', "}"],
    morceaux: [
      "for (i = 1 ; i <= 5 ; i++)",
      "for (i = 1, i <= 5, i++)",
      "{",
      '    printf("%d ", i);',
      "}",
    ],
    attendus: [0, 2, 3, 4],
    sortieLda: "1 2 3 4 5",
  },
] as const;

export function BouclesC() {
  const [k, setK] = useState(0);
  const [choisis, setChoisis] = useState<number[]>([]);
  const [pv, setPv] = useState(false);

  const t = TRADUCTIONS[k] ?? TRADUCTIONS[0];
  const bon = choisis.length === t.attendus.length && choisis.every((x, i) => x === t.attendus[i]);
  const conditionInversee = choisis.some((i) => {
    const m = t.morceaux[i] ?? "";
    return /while \(i > 5\)/.test(m);
  });

  const sortieC = pv
    ? "(boucle infinie : 1 1 1 1 1 …)"
    : conditionInversee
      ? t.id === "rep"
        ? "1"
        : "(rien du tout)"
      : bon
        ? t.sortieLda
        : "(programme incomplet)";

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-1.5">
        {TRADUCTIONS.map((x, i) => (
          <button
            key={x.id}
            type="button"
            onClick={() => {
              setK(i);
              setChoisis([]);
              setPv(false);
            }}
            className={
              i === k
                ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
                : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            }
          >
            {x.id === "tq" ? "TantQue" : x.id === "rep" ? "Répéter" : "Pour"}
          </button>
        ))}
      </div>

      <div className="grid gap-2 sm:grid-cols-2">
        <div className="space-y-1">
          <p className="text-xs font-semibold">L&apos;algorithme en LDA</p>
          <pre className="overflow-x-auto rounded-lg bg-slate-900 p-2.5 font-mono text-[10px] leading-relaxed text-slate-300">
            {t.lda.join("\n")}
          </pre>
          <p className="font-mono text-[10px] text-emerald-600">sortie : {t.sortieLda}</p>
        </div>
        <div className="space-y-1">
          <p className="text-xs font-semibold">Ta traduction en C</p>
          <pre className="min-h-[90px] overflow-x-auto rounded-lg bg-slate-900 p-2.5 font-mono text-[10px] leading-relaxed">
            {choisis.length === 0 ? (
              <span className="text-slate-600">(vide)</span>
            ) : (
              choisis.map((i, j) => {
                const place = t.attendus[j] === i;
                return (
                  <div
                    key={`${j}-${i}`}
                    className={
                      place ? "text-slate-300" : "rounded bg-rose-500/25 px-1 text-rose-100"
                    }
                  >
                    {(t.morceaux[i] ?? "") +
                      (pv && /while \(i <= 5\)$/.test(t.morceaux[i] ?? "") ? "" : "")}
                  </div>
                );
              })
            )}
          </pre>
          <p
            className="font-mono text-[10px]"
            style={{ color: sortieC === t.sortieLda ? PALETTE.green : PALETTE.red }}
          >
            sortie : {sortieC}
          </p>
        </div>
      </div>

      <div className="space-y-1">
        <p className="text-xs font-medium text-muted-foreground">
          Clique les morceaux dans l&apos;ordre
        </p>
        <div className="flex flex-wrap gap-1">
          {t.morceaux.map((m, i) => (
            <button
              key={`${i}-${m}`}
              type="button"
              onClick={() => setChoisis([...choisis, i])}
              className="rounded border border-border bg-background px-1.5 py-0.5 font-mono text-[10px] text-muted-foreground hover:bg-secondary/60"
            >
              {m.trim()}
            </button>
          ))}
        </div>
        <div className="flex flex-wrap gap-2 pt-1">
          <button
            type="button"
            onClick={() => setChoisis((v) => v.slice(0, -1))}
            className="rounded-lg border border-border bg-background px-2.5 py-1 text-[11px] font-medium text-muted-foreground hover:bg-secondary/60"
          >
            Retirer le dernier
          </button>
          <button
            type="button"
            onClick={() => setChoisis([])}
            className="rounded-lg border border-border bg-background px-2.5 py-1 text-[11px] font-medium text-muted-foreground hover:bg-secondary/60"
          >
            Effacer
          </button>
          <button
            type="button"
            onClick={() => setPv((v) => !v)}
            className={
              pv
                ? "rounded-lg bg-rose-600 px-2.5 py-1 text-[11px] font-semibold text-white"
                : "rounded-lg border border-border bg-background px-2.5 py-1 text-[11px] font-medium text-muted-foreground hover:bg-secondary/60"
            }
          >
            {pv ? "Retirer le ; égaré" : "Mettre un ; après le while"}
          </button>
        </div>
      </div>

      {pv ? (
        <Verdict tone="bad">
          <strong>Boucle infinie détectée.</strong> Le point-virgule a donné au{" "}
          <span className="font-mono">while</span> un corps vide : il tourne sur place, et le bloc
          entre accolades n&apos;est jamais atteint. <span className="font-mono">i</span> reste à 1
          pour toujours. Aucun message du compilateur — c&apos;est le programme qui se bloque à
          l&apos;exécution. Remarque que le <span className="font-mono">do … while</span> est le{" "}
          <strong>seul</strong> endroit où un point-virgule après{" "}
          <span className="font-mono">while</span> est correct, et même obligatoire.
        </Verdict>
      ) : conditionInversee ? (
        <Verdict tone="bad">
          Condition non inversée, et les deux programmes cessent aussitôt de dire la même chose : le
          LDA affiche « {t.sortieLda} », le C affiche « {sortieC} ».
          {t.id === "rep" ? (
            <>
              {" "}
              Le <span className="font-mono">Jusqu&apos;à i &gt; 5</span> du LDA dit « sors{" "}
              <strong>quand</strong> c&apos;est vrai », le <span className="font-mono">while</span>{" "}
              du C dit « reste <strong>tant que</strong> c&apos;est vrai ». Il faut donc écrire la{" "}
              <strong>négation</strong> : <span className="font-mono">while (i &lt;= 5);</span>.
              C&apos;est la traduction la plus souvent ratée de l&apos;examen.
            </>
          ) : (
            " La condition d'un while se garde telle quelle : c'est celle du Répéter qu'il faut inverser."
          )}
        </Verdict>
      ) : bon ? (
        <Verdict tone="ok">
          Traduction juste, et les deux sorties concordent : « {t.sortieLda} ».
          {t.id === "pour"
            ? " Et note les séparateurs du for : des POINTS-VIRGULES, jamais des virgules. Avec des virgules, le compilateur refuse."
            : t.id === "rep"
              ? " Le point-virgule après le while final est obligatoire ici, et seulement ici."
              : " Les trois ingrédients sont là : initialisation avant, condition, progression dedans."}
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Construis la traduction morceau par morceau. Le tableau de correspondance :{" "}
          <span className="font-mono">TantQue → while</span>,{" "}
          <span className="font-mono">Répéter → do … while</span>,{" "}
          <span className="font-mono">Pour → for</span>, et{" "}
          <span className="font-mono">i ← i + 1 → i++</span>.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 25 — Le tableau en C et le décalage des indices            */
/* ------------------------------------------------------------------ */

const TAB_C = [12, 9, 15, 7, 18];

export function TableauC() {
  const [depart, setDepart] = useState(0);
  const [strict, setStrict] = useState(true);
  const [memoire, setMemoire] = useState(false);

  const n = TAB_C.length;
  const borne = strict ? n - 1 : n;
  const indices: number[] = [];
  for (let i = depart; i <= borne; i++) indices.push(i);

  const oubliee = depart === 1;
  const fantome = !strict;
  const lues = indices.map((i) => (i >= 0 && i < n ? (TAB_C[i] ?? 0) : 4217));
  const somme = lues.reduce((s, v) => s + v, 0);
  const sommeVraie = TAB_C.reduce((s, v) => s + v, 0);

  return (
    <div className="space-y-3">
      <div className="grid gap-2 sm:grid-cols-2">
        <div className="space-y-1">
          <p className="text-xs font-semibold">En LDA</p>
          <pre className="rounded-lg bg-slate-900 p-2 font-mono text-[10px] leading-relaxed text-slate-300">
            {`tab : tableau[1..${n}] de entier

Pour i de 1 à ${n} faire
    somme ← somme + tab[i]
FinPour`}
          </pre>
          <Cases valeurs={TAB_C} base={1} legende={`Indices de 1 à ${n}.`} />
        </div>
        <div className="space-y-1">
          <p className="text-xs font-semibold">En langage C</p>
          <pre className="rounded-lg bg-slate-900 p-2 font-mono text-[10px] leading-relaxed text-slate-300">
            {`int tab[${n}];

for (i = ${depart} ; i ${strict ? "<" : "<="} ${n} ; i++)
    somme += tab[i];`}
          </pre>
          <Cases valeurs={TAB_C} base={0} legende={`Indices de 0 à ${n - 1}.`} />
        </div>
      </div>

      <div className="grid gap-2 sm:grid-cols-2">
        <Choice<string>
          label="Le parcours commence à"
          value={String(depart)}
          options={[
            { value: "0", label: "i = 0" },
            { value: "1", label: "i = 1" },
          ]}
          onChange={(v) => setDepart(Number(v))}
        />
        <Choice<"strict" | "large">
          label="La condition"
          value={strict ? "strict" : "large"}
          options={[
            { value: "strict", label: `i < ${n}` },
            { value: "large", label: `i <= ${n}` },
          ]}
          onChange={(v) => setStrict(v === "strict")}
        />
      </div>

      <div className="space-y-1 rounded-lg border border-border bg-background p-2.5">
        <p className="text-xs font-semibold">Cases réellement lues</p>
        <div className="flex flex-wrap gap-1">
          {indices.map((i) => {
            const horsBornes = i < 0 || i >= n;
            return (
              <div
                key={i}
                className={
                  horsBornes
                    ? "rounded border-2 border-rose-500 bg-rose-500/20 px-2 py-1 text-center"
                    : "rounded border border-blue-400 bg-blue-500/10 px-2 py-1 text-center"
                }
              >
                <p className="font-mono text-[10px]">tab[{i}]</p>
                <p className="font-mono text-[11px] font-bold">
                  {horsBornes ? "4217" : (TAB_C[i] ?? 0)}
                </p>
              </div>
            );
          })}
        </div>
      </div>

      <Panel>
        <Stat
          label="Somme obtenue"
          value={somme.toLocaleString("fr-FR")}
          color={somme === sommeVraie ? PALETTE.green : PALETTE.red}
        />
        <Stat label="Somme attendue" value={sommeVraie.toLocaleString("fr-FR")} />
      </Panel>

      {oubliee && fantome ? (
        <Verdict tone="bad">
          Les deux fautes à la fois : la case <span className="font-mono">tab[0]</span>, qui vaut{" "}
          {TAB_C[0]}, n&apos;est <strong>jamais lue</strong>, et la case{" "}
          <span className="font-mono">tab[{n}]</span>, qui <strong>n&apos;existe pas</strong>, est
          lue quand même. La somme est doublement fausse. C&apos;est ce qui arrive quand on traduit
          un parcours LDA en C <strong>sans opérer le décalage</strong>.
        </Verdict>
      ) : oubliee ? (
        <Verdict tone="bad">
          En partant de <span className="font-mono">i = 1</span>, la case{" "}
          <span className="font-mono">tab[0]</span> est <strong>oubliée</strong> : la valeur{" "}
          {TAB_C[0]} ne compte pas, et la somme est fausse de {TAB_C[0]}. En C, la{" "}
          <strong>première case porte l&apos;indice 0</strong>, et c&apos;est le réflexe à prendre
          une fois pour toutes.
        </Verdict>
      ) : fantome ? (
        <Verdict tone="bad">
          Avec <span className="font-mono">i &lt;= {n}</span>, la boucle lit{" "}
          <span className="font-mono">tab[{n}]</span>, qui n&apos;existe pas dans un tableau de {n}{" "}
          cases : les indices valides vont de 0 à {n - 1}. Et le C <strong>ne vérifie rien</strong>{" "}
          : il lit la mémoire voisine — ici 4217 — et continue comme si de rien n&apos;était. Dans
          un vrai programme, cela donne un résultat absurde ou le fameux <em>segmentation fault</em>
          . Écris <span className="font-mono">i &lt; n</span>, avec un{" "}
          <strong>inférieur strict</strong>.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          Parcours correct : <span className="font-mono">for (i = 0 ; i &lt; n ; i++)</span>.
          Retiens cette ligne par cœur, c&apos;est elle qui fait la moitié des points de traduction.
          Essaie maintenant les deux variantes fautives.
        </Verdict>
      )}

      <button
        type="button"
        onClick={() => setMemoire((v) => !v)}
        className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
      >
        {memoire ? "Masquer la mémoire" : `Que contient vraiment tab[${n}] ?`}
      </button>

      {memoire ? (
        <div className="space-y-1 rounded-lg border border-rose-500/40 bg-rose-500/5 p-2.5">
          <p className="text-xs font-semibold text-rose-700">La mémoire, octet par octet</p>
          <div className="flex flex-wrap gap-0.5">
            {[...TAB_C, 4217, 0].map((v, i) => (
              <div
                key={i}
                className={
                  i < n
                    ? "w-16 rounded border border-blue-400 bg-blue-500/10 p-1 text-center"
                    : "w-16 rounded border-2 border-rose-500 bg-rose-500/15 p-1 text-center"
                }
              >
                <p className="font-mono text-[9px]">
                  {i < n ? `tab[${i}]` : i === n ? "???" : "???"}
                </p>
                <p className="font-mono text-[10px] font-bold">{v}</p>
                <p className="font-mono text-[8px] text-muted-foreground">
                  0x{(28672 + i * 4).toString(16)}
                </p>
              </div>
            ))}
          </div>
          <p className="text-[11px] text-muted-foreground">
            Le tableau s&apos;arrête à <span className="font-mono">tab[{n - 1}]</span>. Juste après
            commence autre chose : une autre variable, le compteur de la boucle, ou l&apos;adresse
            de retour de la fonction. Écrire là, c&apos;est écraser cela — et c&apos;est pourquoi un
            débordement de tableau peut produire des pannes qui n&apos;ont aucun rapport apparent
            avec le tableau.
          </p>
        </div>
      ) : null}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 25 — La recherche séquentielle en C                        */
/* ------------------------------------------------------------------ */

const TAB_RECH_C = [4, 9, 7, 15, 2];

export function RechercheC() {
  const [cible, setCible] = useState(15);
  const [etape, setEtape] = useState(0);
  const [decalage, setDecalage] = useState(true);
  const [plusUn, setPlusUn] = useState(true);
  const [unEgal, setUnEgal] = useState(false);

  const n = TAB_RECH_C.length;

  // Le déroulé LDA, de 1 à n.
  const pasLda: { i: number; trouve: boolean }[] = [{ i: 1, trouve: false }];
  {
    let i = 1;
    let t = false;
    while (i <= n && !t) {
      if ((TAB_RECH_C[i - 1] ?? 0) === cible) t = true;
      else i += 1;
      pasLda.push({ i, trouve: t });
    }
  }

  // Le déroulé C, de 0 à n-1 — ou mal décalé si l'élève a oublié.
  const base = decalage ? 0 : 1;
  const pasC: { i: number; trouve: boolean }[] = [{ i: base, trouve: false }];
  {
    let i = base;
    let t = false;
    // Avec un seul =, la condition est toujours vraie : on « trouve » dès la première case.
    while (i < n && !t) {
      const v = TAB_RECH_C[i] ?? 4217;
      if (unEgal || v === cible) t = true;
      else i += 1;
      pasC.push({ i, trouve: t });
    }
  }

  const PD = { i: 0, trouve: false };
  const pl = pasLda[Math.min(etape, pasLda.length - 1)] ?? PD;
  const pc = pasC[Math.min(etape, pasC.length - 1)] ?? PD;

  const posLda = pl.trouve ? pl.i : 0;
  const posC = pc.trouve ? pc.i + (plusUn ? 1 : 0) : 0;
  const accord = posLda === posC;
  const fini = etape >= Math.max(pasLda.length, pasC.length) - 1;

  return (
    <div className="space-y-3">
      <Cases
        valeurs={TAB_RECH_C}
        base={1}
        courant={pl.i}
        legende={`On cherche ${cible}. Les indices affichés sont ceux du LDA.`}
      />

      <div className="grid gap-2 sm:grid-cols-2">
        <div className="space-y-1">
          <p className="text-xs font-semibold">LDA</p>
          <pre className="rounded-lg bg-slate-900 p-2 font-mono text-[10px] leading-relaxed text-slate-300">
            {`trouve ← faux
i ← 1
TantQue (i <= ${n}) et (trouve = faux) faire
    Si tab[i] = ${cible} alors
        trouve ← vrai
    Sinon
        i ← i + 1
    Finsi
FinTantQue`}
          </pre>
          <Panel>
            <Stat label="i" value={`${pl.i}`} />
            <Stat
              label="trouve"
              value={pl.trouve ? "vrai" : "faux"}
              color={pl.trouve ? PALETTE.green : PALETTE.slate}
            />
          </Panel>
        </div>
        <div className="space-y-1">
          <p className="text-xs font-semibold">Langage C</p>
          <pre className="rounded-lg bg-slate-900 p-2 font-mono text-[10px] leading-relaxed text-slate-300">
            {`int trouve = 0;
int i = ${base};
while (i < ${n} && trouve == 0)
{
    if (tab[i] ${unEgal ? "=" : "=="} ${cible})
        trouve = 1;
    else
        i++;
}
printf("position %d", i${plusUn ? " + 1" : ""});`}
          </pre>
          <Panel>
            <Stat label="i" value={`${pc.i}`} />
            <Stat
              label="trouve"
              value={pc.trouve ? "1" : "0"}
              color={pc.trouve ? PALETTE.green : PALETTE.slate}
            />
          </Panel>
        </div>
      </div>

      <Panel>
        <Stat
          label="Position annoncée par le LDA"
          value={posLda > 0 ? `${posLda}` : "absente"}
          color={PALETTE.blue}
        />
        <Stat
          label="Position annoncée par le C"
          value={posC > 0 ? `${posC}` : "absente"}
          color={accord ? PALETTE.green : PALETTE.red}
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
          onClick={() => setEtape((v) => Math.min(Math.max(pasLda.length, pasC.length) - 1, v + 1))}
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
            { value: "4", label: "4 (1re)" },
            { value: "15", label: "15 (4e)" },
            { value: "99", label: "99 (absente)" },
          ]}
          onChange={(v) => {
            setCible(Number(v));
            setEtape(0);
          }}
        />
        <div className="flex flex-wrap gap-1.5">
          <button
            type="button"
            onClick={() => {
              setDecalage((v) => !v);
              setEtape(0);
            }}
            className={
              decalage
                ? "rounded-lg border border-emerald-500/50 bg-emerald-500/10 px-2 py-1 text-[11px] font-medium text-emerald-700"
                : "rounded-lg bg-rose-600 px-2 py-1 text-[11px] font-semibold text-white"
            }
          >
            {decalage ? "i = 0 (correct)" : "i = 1 (décalage oublié)"}
          </button>
          <button
            type="button"
            onClick={() => setPlusUn((v) => !v)}
            className={
              plusUn
                ? "rounded-lg border border-emerald-500/50 bg-emerald-500/10 px-2 py-1 text-[11px] font-medium text-emerald-700"
                : "rounded-lg bg-rose-600 px-2 py-1 text-[11px] font-semibold text-white"
            }
          >
            {plusUn ? "affiche i + 1" : "affiche i (sans + 1)"}
          </button>
          <button
            type="button"
            onClick={() => {
              setUnEgal((v) => !v);
              setEtape(0);
            }}
            className={
              !unEgal
                ? "rounded-lg border border-emerald-500/50 bg-emerald-500/10 px-2 py-1 text-[11px] font-medium text-emerald-700"
                : "rounded-lg bg-rose-600 px-2 py-1 text-[11px] font-semibold text-white"
            }
          >
            {unEgal ? "if (tab[i] = x)" : "if (tab[i] == x)"}
          </button>
        </div>
      </div>

      {unEgal ? (
        <Verdict tone="bad">
          Un seul signe égal : <span className="font-mono">if (tab[i] = {cible})</span>{" "}
          <strong>affecte</strong> {cible} à la case <span className="font-mono">tab[i]</span>, puis
          juge la valeur {cible} — non nulle, donc vraie. Le programme « trouve » donc{" "}
          <strong>à la première case</strong>, quelle qu&apos;elle soit, et il a écrasé son contenu
          au passage. Le compilateur ne dit rien. Deux signes égal pour comparer.
        </Verdict>
      ) : !decalage ? (
        <Verdict tone="bad">
          Décalage oublié : en C, <span className="font-mono">i = 1</span> désigne la{" "}
          <strong>deuxième</strong> valeur. La première case,{" "}
          <span className="font-mono">tab[0]</span> = {TAB_RECH_C[0]}, n&apos;est jamais examinée —
          cherche la valeur 4 pour le voir. Les indices du C vont de <strong>0 à n − 1</strong>.
        </Verdict>
      ) : !plusUn && posC > 0 ? (
        <Verdict tone="bad">
          Le <span className="font-mono">+ 1</span> à l&apos;affichage manque : le C annonce la
          position {posC} quand le LDA annonce {posLda}. La machine compte à partir de 0,
          l&apos;utilisateur à partir de 1. L&apos;algorithme est juste, c&apos;est{" "}
          <strong>l&apos;affichage</strong> qui est faux — et cela coûte le même nombre de points.
        </Verdict>
      ) : fini && accord ? (
        <Verdict tone="ok">
          Les deux programmes disent la même chose :{" "}
          {posLda > 0 ? `position ${posLda}` : "valeur absente"}. Les{" "}
          <strong>six transformations</strong> de la traduction : le drapeau devient un{" "}
          <span className="font-mono">int</span> avec 0 et 1 ; <span className="font-mono">i</span>{" "}
          part de 0 ; la condition devient <span className="font-mono">i &lt; n</span> ; le « et »
          devient <span className="font-mono">&amp;&amp;</span> ; les comparaisons prennent{" "}
          <strong>deux signes égal</strong> ; et l&apos;affichage ajoute{" "}
          <span className="font-mono">+ 1</span>. L&apos;incrémentation, elle, reste dans le{" "}
          <span className="font-mono">else</span>, exactement comme en LDA.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Avance comparaison par comparaison et regarde les deux compteurs : l&apos;un part de 1,
          l&apos;autre de 0. Puis introduis les trois erreurs, une par une.
        </Verdict>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 25 — Le chasseur d'erreurs                                 */
/* ------------------------------------------------------------------ */

const PROGRAMMES = [
  {
    id: "p1",
    lignes: [
      "#include <stdio.h>",
      "",
      "int main()",
      "{",
      "    int tab[5] = {4, 8, 1, 9, 3}",
      "    int i, n = 5, somme;",
      "",
      "    for (i = 1 ; i <= n ; i++);",
      "    {",
      "        somme = somme + tab[i]",
      "    }",
      "",
      "    if (somme = 25)",
      '        printf("La somme vaut 25");',
      "",
      "    return 0;",
      "}",
    ],
    erreurs: [
      {
        ligne: 4,
        famille: "syntaxe",
        msg: "main.c:6:5: error: expected ',' or ';' before 'int'",
        quoi: "Point-virgule manquant après l'accolade fermante du tableau. Et remarque bien : le compilateur le signale à la ligne 6, pas à la ligne 5. Il ne s'en aperçoit qu'en lisant la ligne SUIVANTE.",
        fix: "    int tab[5] = {4, 8, 1, 9, 3};",
      },
      {
        ligne: 5,
        famille: "logique",
        msg: "(aucun message)",
        quoi: "somme n'est pas initialisée. En C, une variable non initialisée contient ce qui traînait en mémoire : la somme est fausse dès le départ, et rien ne le signale.",
        fix: "    int i, n = 5, somme = 0;",
      },
      {
        ligne: 7,
        famille: "logique",
        msg: "(aucun message)",
        quoi: "Trois fautes dans la même ligne. Le point-virgule après le for lui donne un corps vide : il tourne à vide, et le bloc s'exécute UNE SEULE FOIS après la boucle, avec i valant 6. Le i = 1 oublie la case tab[0]. Et le i <= n lit tab[5], qui n'existe pas.",
        fix: "    for (i = 0 ; i < n ; i++)",
      },
      {
        ligne: 9,
        famille: "syntaxe",
        msg: "main.c:11:5: error: expected ';' before '}' token",
        quoi: "Point-virgule manquant en fin d'instruction.",
        fix: "        somme = somme + tab[i];",
      },
      {
        ligne: 12,
        famille: "logique",
        msg: "(aucun message)",
        quoi: "Un seul signe égal : le if AFFECTE 25 à somme puis juge 25 vraie. Le message s'affiche toujours, et la vraie somme est écrasée.",
        fix: "    if (somme == 25)",
      },
    ],
  },
  {
    id: "p2",
    lignes: [
      "#include <stdio.h>",
      "",
      "int main()",
      "{",
      "    int a, b;",
      "    float moyenne;",
      "",
      '    printf("Deux notes : ");',
      '    scanf("%d %d", a, b);',
      "",
      "    moyenne = (a + b) / 2;",
      '    Printf("Moyenne : %d\\n", moyenne);',
      "",
      "    return 0;",
      "}",
    ],
    erreurs: [
      {
        ligne: 8,
        famille: "logique",
        msg: "main.c:9:5: warning: format '%d' expects argument of type 'int *'",
        quoi: "Le & manque devant a et b. scanf a besoin de l'ADRESSE pour savoir où ranger ce que l'utilisateur tape ; sans &, il reçoit le contenu — une valeur imprévisible — et écrit n'importe où.",
        fix: '    scanf("%d %d", &a, &b);',
      },
      {
        ligne: 10,
        famille: "logique",
        msg: "(aucun message)",
        quoi: "Division entière : a et b sont des int, donc (a + b) / 2 jette le reste. Avec 13 et 14, la moyenne donne 13 au lieu de 13,5. Il faut forcer : (float)(a + b) / 2.",
        fix: "    moyenne = (float)(a + b) / 2;",
      },
      {
        ligne: 11,
        famille: "syntaxe",
        msg: "main.c:12:5: warning: implicit declaration of function 'Printf'\nundefined reference to `Printf'",
        quoi: "Le C distingue les majuscules des minuscules : la fonction s'appelle printf. Et le %d est faux pour un float : il faut %.2f.",
        fix: '    printf("Moyenne : %.2f\\n", moyenne);',
      },
    ],
  },
] as const;

const FAMILLES_ERR = [
  { value: "syntaxe", label: "Syntaxe" },
  { value: "execution", label: "Exécution" },
  { value: "logique", label: "Logique" },
] as const;

export function ErreursC() {
  const [p, setP] = useState(0);
  const [ligne, setLigne] = useState<number | null>(null);
  const [famille, setFamille] = useState<string | null>(null);
  const [corrigees, setCorrigees] = useState<number[]>([]);

  const prog = PROGRAMMES[p] ?? PROGRAMMES[0];
  const err = prog.erreurs.find((e) => e.ligne === ligne);
  const familleOk = err && famille === err.famille;

  const lignesVues = prog.lignes.map((l, i) => {
    const e = prog.erreurs.find((x) => x.ligne === i);
    if (e && corrigees.includes(i)) return e.fix;
    return l;
  });

  const toutes = corrigees.length === prog.erreurs.length;
  const sommeFausse = p === 0 && !toutes;

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap gap-1.5">
        {PROGRAMMES.map((x, k) => (
          <button
            key={x.id}
            type="button"
            onClick={() => {
              setP(k);
              setLigne(null);
              setFamille(null);
              setCorrigees([]);
            }}
            className={
              k === p
                ? "rounded-lg bg-primary px-2.5 py-1.5 text-xs font-semibold text-primary-foreground"
                : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            }
          >
            Programme {k + 1}
          </button>
        ))}
      </div>

      <div className="overflow-x-auto rounded-lg border border-border bg-slate-900 p-3">
        <pre className="font-mono text-[11px] leading-relaxed">
          {lignesVues.map((l, i) => {
            const estErreur = prog.erreurs.some((x) => x.ligne === i);
            const corrige = corrigees.includes(i);
            return (
              <button
                key={`${i}-${l}`}
                type="button"
                onClick={() => {
                  setLigne(i);
                  setFamille(null);
                }}
                className={`-mx-1 block w-full rounded px-1 text-left ${
                  ligne === i
                    ? "bg-amber-400/25 text-amber-100"
                    : corrige
                      ? "bg-emerald-500/15 text-emerald-200"
                      : estErreur
                        ? "text-slate-400 hover:bg-slate-800"
                        : "text-slate-500 hover:bg-slate-800"
                }`}
              >
                <span className="mr-2 select-none text-slate-600">
                  {String(i + 1).padStart(2, " ")}
                </span>
                {l === "" ? " " : l}
                {corrige ? "   ✓" : ""}
              </button>
            );
          })}
        </pre>
      </div>

      <Panel>
        <Stat label="Erreurs corrigées" value={`${corrigees.length} / ${prog.erreurs.length}`} />
        <Stat
          label="Ligne examinée"
          value={ligne !== null ? `${ligne + 1}` : "—"}
          color={PALETTE.blue}
        />
      </Panel>

      {ligne === null ? (
        <Verdict tone="warn">
          Clique la ligne que tu crois fautive. Attention : le compilateur signale souvent une
          erreur <strong>à la ligne suivante</strong>, et les erreurs de logique ne provoquent{" "}
          <strong>aucun message</strong>.
        </Verdict>
      ) : !err ? (
        <Verdict tone="bad">
          La ligne {ligne + 1} est correcte. Cherche ailleurs — et souviens-toi qu&apos;un
          point-virgule manquant est signalé à la ligne d&apos;après.
        </Verdict>
      ) : (
        <>
          <Console lignes={err.msg.split("\n")} titre="Build messages" />
          <Choice<string>
            label="De quelle famille relève cette erreur ?"
            value={famille ?? ""}
            options={FAMILLES_ERR.map((f) => ({ value: f.value, label: f.label }))}
            onChange={setFamille}
          />
          {famille === null ? (
            <Verdict tone="warn">
              Syntaxe : le compilateur refuse. Exécution : il compile, puis le programme
              s&apos;arrête. Logique : il compile, tourne jusqu&apos;au bout, et donne un résultat
              faux.
            </Verdict>
          ) : familleOk ? (
            <>
              <Verdict tone="ok">
                Famille juste. <span className="font-semibold">Ce qui se passe : </span>
                {err.quoi}
              </Verdict>
              <button
                type="button"
                onClick={() => setCorrigees((v) => (v.includes(err.ligne) ? v : [...v, err.ligne]))}
                className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
              >
                Corriger cette ligne
              </button>
            </>
          ) : (
            <Verdict tone="bad">
              Non : c&apos;est une erreur de{" "}
              <strong>
                {FAMILLES_ERR.find((f) => f.value === err.famille)?.label.toLowerCase() ?? ""}
              </strong>
              .{" "}
              {err.msg.startsWith("(aucun")
                ? "Le compilateur ne dit rien du tout — c'est le signe d'une erreur de logique."
                : "Le compilateur refuse de produire l'exécutable : c'est de la syntaxe."}
            </Verdict>
          )}
        </>
      )}

      {p === 0 ? (
        <div className="space-y-1 rounded-lg border border-border bg-background p-2.5">
          <p className="text-xs font-semibold">Ce que le programme affiche</p>
          <p
            className="font-mono text-[11px]"
            style={{ color: toutes ? PALETTE.green : PALETTE.red }}
          >
            {toutes
              ? "Somme : 25   ✓ (4 + 8 + 1 + 9 + 3 = 25, et le message est vrai)"
              : sommeFausse
                ? "La somme vaut 25   ✗ (affiché quoi qu'il arrive, et somme vient d'être écrasée)"
                : ""}
          </p>
        </div>
      ) : null}

      {toutes ? (
        <Verdict tone="ok">
          Programme réparé. La méthode, à garder : <strong>lire le message</strong> et retenir la
          ligne ; <strong>regarder la ligne indiquée et celle du dessus</strong> ;{" "}
          <strong>corriger la première erreur seulement</strong>, puis recompiler — une faute en
          entraîne souvent dix dans la liste ; et si le programme compile mais répond faux, faire la{" "}
          <strong>trace d&apos;exécution</strong>, ou laisser le débogueur de l&apos;IDE la faire.
        </Verdict>
      ) : null}
    </div>
  );
}
