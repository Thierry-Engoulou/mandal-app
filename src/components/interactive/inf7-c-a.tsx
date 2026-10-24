import { useState } from "react";
import { Choice, Ctrl, PALETTE, Panel, Stat, Verdict } from "./controls";
import { Code, Console } from "./inf7-noyau";

/** Informatique Terminale C et D — chapitres 22 et 23 : bases du langage C. */

/* ------------------------------------------------------------------ */
/* Chapitre 22 — Quatre langages, un même programme                    */
/* ------------------------------------------------------------------ */

const LANGAGES = [
  {
    nom: "C",
    mode: "compilé",
    lignes: [
      "#include <stdio.h>",
      "",
      "int main()",
      "{",
      "    int n;",
      '    scanf("%d", &n);',
      '    printf("%d\\n", n * 2);',
      "    return 0;",
      "}",
    ],
  },
  {
    nom: "Pascal",
    mode: "compilé",
    lignes: [
      "program Double;",
      "var n : integer;",
      "begin",
      "    readln(n);",
      "    writeln(n * 2);",
      "end.",
    ],
  },
  {
    nom: "Python",
    mode: "interprété",
    lignes: ["n = int(input())", "print(n * 2)"],
  },
  {
    nom: "Java",
    mode: "compilé puis interprété",
    lignes: [
      "import java.util.Scanner;",
      "",
      "public class Double {",
      "    public static void main(String[] a) {",
      "        Scanner s = new Scanner(System.in);",
      "        int n = s.nextInt();",
      "        System.out.println(n * 2);",
      "    }",
      "}",
    ],
  },
] as const;

const A_CLASSER = [
  { l: "C", m: "compile" },
  { l: "C++", m: "compile" },
  { l: "Pascal", m: "compile" },
  { l: "Python", m: "interprete" },
  { l: "PHP", m: "interprete" },
  { l: "JavaScript", m: "interprete" },
] as const;

export function LangagesProgrammation() {
  const [sel, setSel] = useState(0);
  const [etape, setEtape] = useState(0);
  const [classe, setClasse] = useState<Record<string, string>>({});

  const l = LANGAGES[sel] ?? LANGAGES[0];
  const bons = A_CLASSER.filter((x) => classe[x.l] === x.m).length;

  // Le compilateur avale tout le fichier d'un coup ; l'interpréteur ligne à ligne.
  const nbLignes = l.lignes.filter((x) => x.trim() !== "").length;
  const tempsCompile = 1;
  const tempsInterprete = nbLignes;

  return (
    <div className="space-y-3">
      <Choice<string>
        label="Le même programme — lire un entier et afficher son double"
        value={String(sel)}
        options={LANGAGES.map((x, k) => ({ value: String(k), label: x.nom }))}
        onChange={(v) => {
          setSel(Number(v));
          setEtape(0);
        }}
      />

      <Code lignes={l.lignes} eclairee={etape > 0 ? etape - 1 : -1} />

      <Panel>
        <Stat label="Lignes de code" value={`${nbLignes}`} />
        <Stat label="Mode de traduction" value={l.mode} color={PALETTE.blue} />
      </Panel>

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">La chaîne de traduction</p>
        <div className="grid gap-2 sm:grid-cols-2">
          <div className="space-y-1 rounded-lg border-2 border-blue-500/40 bg-blue-500/5 p-2.5">
            <p className="text-xs font-semibold" style={{ color: PALETTE.blue }}>
              Le compilateur
            </p>
            <p className="text-[11px] text-muted-foreground">
              Il avale <strong>tout le fichier d&apos;un coup</strong> et produit un exécutable
              autonome.
            </p>
            <div className="h-2 overflow-hidden rounded-full bg-secondary">
              <div
                className="h-full rounded-full transition-all"
                style={{ width: etape > 0 ? "100%" : "0%", background: PALETTE.blue }}
              />
            </div>
            <p className="font-mono text-[10px] text-muted-foreground">
              {etape > 0 ? `✓ programme.exe produit en ${tempsCompile} passe` : "en attente"}
            </p>
          </div>
          <div className="space-y-1 rounded-lg border-2 border-orange-500/40 bg-orange-500/5 p-2.5">
            <p className="text-xs font-semibold" style={{ color: PALETTE.orange }}>
              L&apos;interpréteur
            </p>
            <p className="text-[11px] text-muted-foreground">
              Il traduit et exécute <strong>ligne par ligne</strong>, à chaque lancement.
            </p>
            <div className="h-2 overflow-hidden rounded-full bg-secondary">
              <div
                className="h-full rounded-full transition-all"
                style={{
                  width: `${Math.min(100, (etape / Math.max(1, nbLignes)) * 100)}%`,
                  background: PALETTE.orange,
                }}
              />
            </div>
            <p className="font-mono text-[10px] text-muted-foreground">
              ligne {Math.min(etape, nbLignes)} / {nbLignes} — {tempsInterprete} passes au total
            </p>
          </div>
        </div>
        <div className="flex gap-2">
          <button
            type="button"
            onClick={() => setEtape((v) => Math.min(nbLignes, v + 1))}
            className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
          >
            Avancer d&apos;une ligne
          </button>
          <button
            type="button"
            onClick={() => setEtape(0)}
            className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
          >
            Recommencer
          </button>
        </div>
        {etape >= nbLignes && nbLignes > 0 ? (
          <Verdict tone="ok">
            Le compilateur a fini en une seule passe et laissé un <strong>exécutable</strong>, qui
            tournera sans lui et sans le code source. L&apos;interpréteur a fait {nbLignes} passes,
            et il devra les refaire <strong>à chaque lancement</strong>. Voilà pourquoi un programme
            compilé est plus rapide, et pourquoi un programme interprété est plus souple à mettre au
            point.
          </Verdict>
        ) : null}
      </div>

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">Compilé ou interprété ?</p>
        {A_CLASSER.map((x) => {
          const c = classe[x.l];
          const juste = c === x.m;
          return (
            <div key={x.l} className="flex items-center gap-2">
              <span className="w-24 text-[11px] font-medium">{x.l}</span>
              {[
                { v: "compile", t: "compilé" },
                { v: "interprete", t: "interprété" },
              ].map((o) => {
                const actif = c === o.v;
                const cls = !actif
                  ? "border-border bg-background text-muted-foreground hover:bg-secondary/60"
                  : juste
                    ? "border-emerald-500/50 bg-emerald-500/10 text-emerald-700"
                    : "border-rose-500/50 bg-rose-500/10 text-rose-700";
                return (
                  <button
                    key={o.v}
                    type="button"
                    onClick={() => setClasse({ ...classe, [x.l]: o.v })}
                    className={`rounded-lg border px-2 py-0.5 text-[11px] font-medium ${cls}`}
                  >
                    {o.t}
                  </button>
                );
              })}
            </div>
          );
        })}
        <Panel>
          <Stat label="Bien classés" value={`${bons} / ${A_CLASSER.length}`} />
          <Stat
            label="À citer en examen"
            value="C, C++, Java, Python, Pascal"
            color={bons === A_CLASSER.length ? PALETTE.green : PALETTE.ink}
          />
        </Panel>
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 22 — Installer Code::Blocks                               */
/* ------------------------------------------------------------------ */

const ECRANS = [
  {
    titre: "codeblocks.org — rubrique Downloads",
    question: "Quelle version télécharger ?",
    options: [
      { v: "mingw", t: "codeblocks-20.03mingw-setup.exe", bon: true },
      { v: "sans", t: "codeblocks-20.03-setup.exe", bon: false },
    ],
    bonMot:
      "La bonne : le mot mingw dans le nom signifie que le COMPILATEUR est inclus. C'est le seul détail qui compte sur cette page.",
    mauvaisMot:
      "Cette version n'apporte que l'éditeur, sans compilateur. Tu pourras écrire du code, mais pas le compiler.",
  },
  {
    titre: "Contrat de licence",
    question: "Que faire ?",
    options: [
      { v: "accepte", t: "J'accepte", bon: true },
      { v: "refuse", t: "Je refuse", bon: false },
    ],
    bonMot: "Code::Blocks est un logiciel libre : la licence autorise l'usage et la copie.",
    mauvaisMot: "En refusant, l'installation s'arrête là.",
  },
  {
    titre: "Choose Components",
    question: "Quel type d'installation ?",
    options: [
      { v: "full", t: "Full — tous les composants", bon: true },
      { v: "min", t: "Minimal", bon: false },
    ],
    bonMot: "Full installe MinGW, le compilateur. C'est le choix à garder.",
    mauvaisMot:
      "L'installation minimale saute le compilateur, même si tu avais pris la bonne version du fichier.",
  },
  {
    titre: "Choose Install Location",
    question: "Où installer ?",
    options: [
      { v: "defaut", t: "C:\\Program Files\\CodeBlocks", bon: true },
      { v: "bureau", t: "Le Bureau", bon: false },
    ],
    bonMot: "Le dossier proposé convient. On ne change rien sans raison.",
    mauvaisMot:
      "Installer un logiciel sur le Bureau fonctionne, mais le rend fragile : un dossier déplacé par erreur casse tout.",
  },
] as const;

export function InstallerIde() {
  const [ecran, setEcran] = useState(0);
  const [choix, setChoix] = useState<Record<number, string>>({});
  const [installe, setInstalle] = useState(false);
  const [code, setCode] = useState(
    '#include <stdio.h>\n\nint main()\n{\n    printf("Bonjour la Terminale !\\n");\n    return 0;\n}',
  );
  const [compile, setCompile] = useState<string[]>([]);
  const [getchar, setGetchar] = useState(false);

  const e = ECRANS[ecran] ?? ECRANS[0];
  const tousBons = ECRANS.every((x, k) => x.options.find((o) => o.v === choix[k])?.bon);
  const avecCompilateur =
    ECRANS[0]?.options.find((o) => o.v === choix[0])?.bon === true &&
    ECRANS[2]?.options.find((o) => o.v === choix[2])?.bon === true;

  const lancerF9 = () => {
    if (!avecCompilateur) {
      setCompile([
        "> Build and run (F9)",
        "Can't find compiler executable in your configured search path's for GNU GCC Compiler",
        "ERREUR : no compiler found",
      ]);
      return;
    }
    if (!/#include\s*<stdio\.h>/.test(code)) {
      setCompile([
        "> Build and run (F9)",
        "warning: implicit declaration of function 'printf'",
        "undefined reference to `printf'",
      ]);
      return;
    }
    const out = /printf\("([^"]*)"/.exec(code);
    setCompile([
      "> Build and run (F9)",
      "Compiling: main.c",
      "Linking console executable: bin/Debug/projet.exe",
      "Process terminated with status 0 (0 minute(s), 1 second(s))",
      `${(out?.[1] ?? "").replace(/\\n/g, "")}`,
      getchar
        ? "(la console attend une touche — tu peux lire le résultat)"
        : "(la console s'est refermée aussitôt)",
    ]);
  };

  return (
    <div className="space-y-3">
      {!installe ? (
        <>
          <div className="rounded-lg border-2 border-slate-400 bg-secondary/20 p-3">
            <p className="text-xs font-semibold">
              Écran {ecran + 1} sur {ECRANS.length} — {e.titre}
            </p>
            <p className="mt-1 text-[11px] text-muted-foreground">{e.question}</p>
            <div className="mt-2 space-y-1.5">
              {e.options.map((o) => {
                const actif = choix[ecran] === o.v;
                return (
                  <button
                    key={o.v}
                    type="button"
                    onClick={() => setChoix({ ...choix, [ecran]: o.v })}
                    className={
                      actif
                        ? "block w-full rounded-lg border-2 border-primary bg-primary/10 px-2.5 py-1.5 text-left font-mono text-[11px]"
                        : "block w-full rounded-lg border border-border bg-background px-2.5 py-1.5 text-left font-mono text-[11px] text-muted-foreground hover:bg-secondary/60"
                    }
                  >
                    {o.t}
                  </button>
                );
              })}
            </div>
          </div>

          {choix[ecran] ? (
            <Verdict tone={e.options.find((o) => o.v === choix[ecran])?.bon ? "ok" : "warn"}>
              {e.options.find((o) => o.v === choix[ecran])?.bon ? e.bonMot : e.mauvaisMot}
            </Verdict>
          ) : (
            <Verdict tone="warn">Fais ton choix, puis passe à l&apos;écran suivant.</Verdict>
          )}

          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => setEcran((v) => Math.max(0, v - 1))}
              className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            >
              Précédent
            </button>
            {ecran < ECRANS.length - 1 ? (
              <button
                type="button"
                onClick={() => setEcran((v) => v + 1)}
                disabled={!choix[ecran]}
                className={
                  choix[ecran]
                    ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                    : "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground opacity-40"
                }
              >
                Suivant
              </button>
            ) : (
              <button
                type="button"
                onClick={() => setInstalle(true)}
                disabled={!choix[ecran]}
                className={
                  choix[ecran]
                    ? "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
                    : "rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground opacity-40"
                }
              >
                Terminer l&apos;installation
              </button>
            )}
          </div>
        </>
      ) : (
        <>
          <div className="flex flex-wrap items-center gap-2">
            <p className="text-xs font-semibold">
              Code::Blocks — main.c
              <span
                className="ml-2 font-normal"
                style={{ color: avecCompilateur ? PALETTE.green : PALETTE.red }}
              >
                {avecCompilateur ? "compilateur MinGW détecté" : "aucun compilateur"}
              </span>
            </p>
            <button
              type="button"
              onClick={() => {
                setInstalle(false);
                setEcran(0);
                setCompile([]);
              }}
              className="rounded-lg border border-border bg-background px-2 py-0.5 text-[10px] font-medium text-muted-foreground hover:bg-secondary/60"
            >
              Refaire l&apos;installation
            </button>
          </div>

          <textarea
            value={code}
            onChange={(e2) => setCode(e2.target.value)}
            rows={9}
            className="w-full rounded-lg border border-border bg-slate-900 p-3 font-mono text-[11px] text-slate-200"
          />

          <div className="flex flex-wrap gap-2">
            <button
              type="button"
              onClick={lancerF9}
              className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
            >
              Build and run — F9
            </button>
            <button
              type="button"
              onClick={() => {
                setGetchar((v) => !v);
                setCode((c) =>
                  getchar
                    ? c.replace("    getchar();\n", "")
                    : c.replace("    return 0;", "    getchar();\n    return 0;"),
                );
                setCompile([]);
              }}
              className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
            >
              {getchar ? "Retirer getchar();" : "Ajouter getchar(); avant return 0;"}
            </button>
          </div>

          <Console lignes={compile} titre="Build log / Console" />

          {compile.length === 0 ? (
            <Verdict tone="warn">
              Appuie sur F9 : cette touche compile et exécute en une seule fois.
            </Verdict>
          ) : !avecCompilateur ? (
            <Verdict tone="bad">
              « <span className="font-mono">no compiler found</span> » — l&apos;IDE n&apos;a que
              l&apos;éditeur. La cause remonte à l&apos;installation : la version sans{" "}
              <strong>mingw</strong>, ou l&apos;installation <strong>minimale</strong>. La
              réparation : réinstaller avec le fichier{" "}
              <span className="font-mono">mingw-setup</span> et le type <strong>Full</strong>.
              C&apos;est le message que tout le monde rencontre la première fois.
            </Verdict>
          ) : !getchar ? (
            <Verdict tone="warn">
              Le programme a compilé et affiché son message, mais la console{" "}
              <strong>s&apos;est refermée aussitôt</strong>. Ce n&apos;est pas une erreur : le
              programme a fini, donc la fenêtre se ferme. Ajoute{" "}
              <span className="font-mono">getchar();</span> avant le{" "}
              <span className="font-mono">return 0;</span> pour qu&apos;elle attende une touche.
            </Verdict>
          ) : (
            <Verdict tone="ok">
              Compilation réussie, exécution, et la console reste ouverte.{" "}
              {tousBons
                ? "Et tes quatre choix d'installation étaient les bons."
                : "Reprends l'installation si tu veux refaire les quatre bons choix."}
            </Verdict>
          )}
        </>
      )}
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 22 — Remettre un programme dans l'ordre                    */
/* ------------------------------------------------------------------ */

const MORCEAUX = [
  { id: "inc", t: "#include <stdio.h>", rang: 0, role: "les directives au préprocesseur" },
  { id: "def", t: "#define MAJORITE 18", rang: 1, role: "les constantes" },
  { id: "main", t: "int main()", rang: 2, role: "la fonction principale" },
  { id: "ouvre", t: "{", rang: 3, role: "l'ouverture du bloc" },
  { id: "decl", t: "    int age;", rang: 4, role: "les déclarations de variables" },
  { id: "instr", t: '    scanf("%d", &age);', rang: 5, role: "les instructions" },
  { id: "ret", t: "    return 0;", rang: 6, role: "la valeur de retour" },
  { id: "ferme", t: "}", rang: 7, role: "la fermeture du bloc" },
] as const;

const FAUTES = [
  {
    id: "pv",
    label: "Enlever un point-virgule à la ligne 5",
    msg: "main.c:6:5: error: expected ';' before 'scanf'",
    mot: "Remarque la ligne signalée : 6, alors que la faute est à la ligne 5. Le compilateur ne s'aperçoit du point-virgule manquant qu'en lisant la ligne SUIVANTE. Règle d'or : quand le message est incompréhensible, regarde au-dessus.",
  },
  {
    id: "maj",
    label: "Écrire Printf avec une majuscule",
    msg: "main.c:7:5: warning: implicit declaration of function 'Printf'\nundefined reference to `Printf'",
    mot: "Le C distingue les majuscules des minuscules : « Printf » n'existe pas. Le compilateur ne la trouve nulle part, et l'erreur n'apparaît qu'à l'édition de liens — ce qui la rend déroutante.",
  },
  {
    id: "inc",
    label: "Oublier le #include <stdio.h>",
    msg: "main.c:5:5: warning: implicit declaration of function 'scanf'\nundefined reference to `scanf'",
    mot: "Sans stdio.h, printf et scanf n'existent pas : ce sont des fonctions de la bibliothèque d'entrées-sorties standard. Le compilateur devine, puis l'éditeur de liens échoue.",
  },
] as const;

export function StructureProgrammeC() {
  const [ordre, setOrdre] = useState<string[]>([]);
  const [faute, setFaute] = useState<string | null>(null);

  const restants = MORCEAUX.filter((m) => !ordre.includes(m.id));
  const bon =
    ordre.length > 0 && ordre.every((id, k) => MORCEAUX.find((m) => m.id === id)?.rang === k);
  const complet = ordre.length === MORCEAUX.length && bon;
  const premierFaux = ordre.findIndex((id, k) => MORCEAUX.find((m) => m.id === id)?.rang !== k);

  const f = FAUTES.find((x) => x.id === faute);

  return (
    <div className="space-y-3">
      <div className="space-y-1">
        <p className="text-xs font-medium text-muted-foreground">
          Clique les morceaux dans le bon ordre
        </p>
        <div className="flex flex-wrap gap-1">
          {restants.map((m) => (
            <button
              key={m.id}
              type="button"
              onClick={() => setOrdre([...ordre, m.id])}
              className="rounded border border-border bg-background px-1.5 py-0.5 font-mono text-[10px] text-muted-foreground hover:bg-secondary/60"
            >
              {m.t.trim()}
            </button>
          ))}
          {restants.length === 0 ? (
            <span className="text-[10px] text-muted-foreground">(tous placés)</span>
          ) : null}
        </div>
      </div>

      <div className="overflow-x-auto rounded-lg border border-border bg-slate-900 p-3">
        <pre className="font-mono text-[11px] leading-relaxed">
          {ordre.length === 0 ? (
            <span className="text-slate-600">(programme vide)</span>
          ) : (
            ordre.map((id, k) => {
              const m = MORCEAUX.find((x) => x.id === id);
              const place = m?.rang === k;
              return (
                <div
                  key={`${k}-${id}`}
                  className={
                    place
                      ? "-mx-1 px-1 text-slate-300"
                      : "-mx-1 rounded bg-rose-500/25 px-1 text-rose-100"
                  }
                >
                  <span className="mr-2 select-none text-slate-600">
                    {String(k + 1).padStart(2, " ")}
                  </span>
                  {m?.t ?? ""}
                </div>
              );
            })
          )}
        </pre>
      </div>

      <div className="flex gap-2">
        <button
          type="button"
          onClick={() => setOrdre((v) => v.slice(0, -1))}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Retirer le dernier
        </button>
        <button
          type="button"
          onClick={() => setOrdre([])}
          className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
        >
          Tout effacer
        </button>
      </div>

      <Panel>
        <Stat label="Morceaux placés" value={`${ordre.length} / ${MORCEAUX.length}`} />
        <Stat
          label="Dans le bon ordre"
          value={bon ? "oui" : "non"}
          color={bon ? PALETTE.green : PALETTE.red}
        />
      </Panel>

      {premierFaux >= 0 ? (
        <Verdict tone="bad">
          Le morceau n° {premierFaux + 1} n&apos;est pas à sa place. À cet endroit, le compilateur
          attendait <strong>{MORCEAUX.find((m) => m.rang === premierFaux)?.role ?? ""}</strong>.
          {premierFaux === 0
            ? " Les directives #include viennent toujours en tête : sans elles, les fonctions de la bibliothèque n'existent pas encore."
            : " L'ordre des cinq parties est imposé : directives, constantes, fonctions, main, corps."}
        </Verdict>
      ) : complet ? (
        <Verdict tone="ok">
          Programme bien structuré. Les <strong>cinq parties dans l&apos;ordre</strong> : les
          directives au préprocesseur, les constantes, les déclarations de fonctions, la fonction{" "}
          <span className="font-mono">main</span>, et le corps entre accolades. Essaie maintenant
          les trois fautes classiques.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Continue : qu&apos;est-ce qui doit venir en premier dans un fichier C ?
        </Verdict>
      )}

      <div className="space-y-1.5 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">
          Les trois erreurs les plus fréquentes
        </p>
        <div className="flex flex-wrap gap-1.5">
          {FAUTES.map((x) => (
            <button
              key={x.id}
              type="button"
              onClick={() => setFaute(x.id)}
              className={
                faute === x.id
                  ? "rounded-lg bg-rose-600 px-2.5 py-1.5 text-[11px] font-semibold text-white"
                  : "rounded-lg border border-border bg-background px-2.5 py-1.5 text-[11px] font-medium text-muted-foreground hover:bg-secondary/60"
              }
            >
              {x.label}
            </button>
          ))}
        </div>
        {f ? (
          <>
            <Console lignes={f.msg.split("\n")} titre="Build messages" />
            <Verdict tone="bad">{f.mot}</Verdict>
          </>
        ) : null}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 23 — Déclarer des variables                                */
/* ------------------------------------------------------------------ */

const TYPES_C = ["int", "float", "double", "char"] as const;

const MOTS_RESERVES = [
  "int",
  "float",
  "char",
  "double",
  "if",
  "else",
  "for",
  "while",
  "do",
  "return",
  "switch",
  "case",
  "break",
  "void",
];

export function VariablesC() {
  const [type, setType] = useState<string>("int");
  const [nom, setNom] = useState("");
  const [declarees, setDeclarees] = useState<{ nom: string; type: string; val: string }[]>([]);
  const [refus, setRefus] = useState<string | null>(null);
  const [a, setA] = useState(7);
  const [b, setB] = useState(2);
  const [forcer, setForcer] = useState(false);

  const declarer = () => {
    const n = nom.trim();
    setRefus(null);
    if (n === "") return;
    if (/^\d/.test(n)) {
      setRefus(
        `« ${n} » commence par un chiffre : refusé. Un nom de variable commence par une lettre ou un souligné.`,
      );
      return;
    }
    if (/\s/.test(n)) {
      setRefus(
        `« ${n} » contient un espace : refusé. Utilise un souligné : ${n.replace(/\s+/g, "_")}.`,
      );
      return;
    }
    if (/[éèêàùçôîïäëöüÉÈÊÀÙÇ-]/.test(n)) {
      setRefus(
        `« ${n} » contient un accent ou un tiret : refusé. Le C n'accepte que des lettres non accentuées, des chiffres et le souligné.`,
      );
      return;
    }
    if (MOTS_RESERVES.includes(n)) {
      setRefus(
        `« ${n} » est un mot réservé du langage : refusé. Le compilateur l'attend comme mot-clé, pas comme nom de variable.`,
      );
      return;
    }
    if (declarees.some((d) => d.nom === n)) {
      setRefus(`« ${n} » est déjà déclarée. En C, chaque nom ne sert qu'une fois dans un bloc.`);
      return;
    }
    setDeclarees((d) => [...d, { nom: n, type, val: type === "char" ? "'?'" : "?" }]);
    setNom("");
  };

  // Division : entière si les deux opérandes sont entiers.
  const resultatEntier = Math.trunc(a / b);
  const resultatReel = a / b;
  const affiche = forcer ? resultatReel : resultatEntier;
  const perdu = !forcer && resultatReel !== resultatEntier;

  return (
    <div className="space-y-3">
      <div className="flex flex-wrap items-end gap-2">
        <Choice<string>
          label="Type"
          value={type}
          options={TYPES_C.map((t) => ({ value: t, label: t }))}
          onChange={setType}
        />
      </div>
      <div className="flex gap-2">
        <input
          value={nom}
          onChange={(e) => setNom(e.target.value)}
          placeholder="nom de la variable"
          className="flex-1 rounded-lg border border-border bg-background px-2.5 py-1.5 font-mono text-xs"
        />
        <button
          type="button"
          onClick={declarer}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          Déclarer
        </button>
      </div>
      <div className="flex flex-wrap gap-1">
        {["age", "2eNote", "moyenne générale", "moyenne_générale", "int", "prix_total"].map((x) => (
          <button
            key={x}
            type="button"
            onClick={() => setNom(x)}
            className="rounded border border-border bg-background px-1.5 py-0.5 font-mono text-[10px] text-muted-foreground hover:bg-secondary/60"
          >
            {x}
          </button>
        ))}
      </div>

      {refus ? (
        <Verdict tone="bad">{refus}</Verdict>
      ) : declarees.length > 0 ? (
        <Verdict tone="ok">
          Déclaration acceptée. Un nom valide commence par une lettre ou un souligné, ne contient ni
          espace, ni accent, ni tiret, et n&apos;est pas un mot réservé.
        </Verdict>
      ) : (
        <Verdict tone="warn">
          Essaie les exemples : quatre des six seront refusés, et la simulation te dira pourquoi.
        </Verdict>
      )}

      {declarees.length > 0 ? (
        <>
          <Code lignes={declarees.map((d) => `${d.type} ${d.nom};`)} />
          <div className="space-y-1 rounded-lg border border-border bg-background p-2.5">
            <p className="text-xs font-semibold">La mémoire</p>
            <div className="flex flex-wrap gap-1">
              {declarees.map((d, k) => (
                <div
                  key={d.nom}
                  className="rounded border border-blue-400 bg-blue-500/10 px-2 py-1 text-center"
                >
                  <p className="font-mono text-[10px] font-semibold">{d.nom}</p>
                  <p className="font-mono text-[9px] text-muted-foreground">{d.type}</p>
                  <p className="font-mono text-[9px] text-muted-foreground">
                    {d.type === "char" ? "1" : d.type === "double" ? "8" : "4"} octets
                  </p>
                  <p className="font-mono text-[9px] text-muted-foreground">
                    0x{(28672 + k * 4).toString(16)}
                  </p>
                </div>
              ))}
            </div>
            <p className="text-[10px] text-muted-foreground">
              Une variable, c&apos;est <strong>un nom, un type, une adresse et une valeur</strong>.
              Non initialisée, elle contient ce qui traînait là — jamais zéro.
            </p>
          </div>
        </>
      ) : null}

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">Le piège de la division entière</p>
        <div className="grid gap-2 sm:grid-cols-2">
          <Ctrl label="a" value={a} min={1} max={20} step={1} onChange={setA} display={`${a}`} />
          <Ctrl label="b" value={b} min={1} max={9} step={1} onChange={setB} display={`${b}`} />
        </div>
        <Code
          lignes={[
            `int a = ${a}, b = ${b};`,
            "float r;",
            forcer ? "r = (float) a / b;" : "r = a / b;",
          ]}
          eclairee={2}
          tonEclairee={perdu ? "bad" : "ok"}
        />
        <Panel>
          <Stat
            label="r affiche"
            value={affiche.toLocaleString("fr-FR", { maximumFractionDigits: 4 })}
            color={perdu ? PALETTE.red : PALETTE.green}
          />
          <Stat
            label="Résultat mathématique"
            value={resultatReel.toLocaleString("fr-FR", { maximumFractionDigits: 4 })}
          />
        </Panel>
        <button
          type="button"
          onClick={() => setForcer((v) => !v)}
          className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
        >
          {forcer ? "Retirer le (float)" : "Forcer avec (float)"}
        </button>
        {perdu ? (
          <Verdict tone="bad">
            {a} / {b} vaut {resultatReel.toLocaleString("fr-FR", { maximumFractionDigits: 4 })},
            mais <span className="font-mono">r</span> affiche {affiche}. Entre{" "}
            <strong>deux entiers</strong>, le C fait une <strong>division entière</strong> et jette
            le reste — et il le fait <em>avant</em> de ranger le résultat dans le float. Déclarer{" "}
            <span className="font-mono">r</span> en float ne suffit pas : il faut{" "}
            <span className="font-mono">(float) a / b</span>. C&apos;est exactement ce qui arrive au
            calcul d&apos;une moyenne.
          </Verdict>
        ) : (
          <Verdict tone="ok">
            {forcer
              ? "Avec le (float), la division se fait en réel et le reste n'est plus perdu."
              : "Ici la division tombe juste, donc rien ne se voit. Essaie 7 / 2."}
          </Verdict>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 23 — Constantes et adresses                                */
/* ------------------------------------------------------------------ */

export function ConstantesC() {
  const [forme, setForme] = useState<"define" | "const">("define");
  const [essai, setEssai] = useState(false);
  const [avecEt, setAvecEt] = useState(true);
  const [saisie, setSaisie] = useState("17");

  const MEMOIRE = [
    { nom: "age", adresse: "0x7000", val: avecEt ? saisie : "?" },
    { nom: "moyenne", adresse: "0x7004", val: "13.5" },
    { nom: "(zone voisine)", adresse: "0x7008", val: avecEt ? "—" : saisie },
  ];

  return (
    <div className="space-y-3">
      <Choice<"define" | "const">
        label="Forme de la constante"
        value={forme}
        options={[
          { value: "define", label: "#define" },
          { value: "const", label: "const" },
        ]}
        onChange={(v) => {
          setForme(v);
          setEssai(false);
        }}
      />

      <Code
        lignes={
          forme === "define"
            ? [
                "#include <stdio.h>",
                "",
                "#define TVA 0.1925        /* avant le main, sans type, sans ; */",
                "",
                "int main()",
                "{",
                essai
                  ? "    TVA = 0.20;           /* tentative de modification */"
                  : "    float prix = 100000;",
                "    return 0;",
                "}",
              ]
            : [
                "#include <stdio.h>",
                "",
                "int main()",
                "{",
                "    const float TVA = 0.1925;   /* dans le programme, avec type et ; */",
                essai
                  ? "    TVA = 0.20;                 /* tentative de modification */"
                  : "    float prix = 100000;",
                "    return 0;",
                "}",
              ]
        }
        eclairee={essai ? (forme === "define" ? 6 : 5) : -1}
        tonEclairee="bad"
      />

      <button
        type="button"
        onClick={() => setEssai((v) => !v)}
        className="rounded-lg bg-primary px-3 py-1.5 text-xs font-semibold text-primary-foreground"
      >
        {essai ? "Retirer la tentative" : "Essayer de modifier la constante"}
      </button>

      {essai ? (
        <>
          <Console
            lignes={
              forme === "define"
                ? [
                    "> gcc main.c",
                    "main.c:7:9: error: lvalue required as left operand of assignment",
                    "    0.1925 = 0.20;",
                  ]
                : ["> gcc main.c", "main.c:6:9: error: assignment of read-only variable 'TVA'"]
            }
            titre="Compilation"
          />
          <Verdict tone="bad">
            {forme === "define" ? (
              <>
                Le message est déroutant, et c&apos;est très instructif : le préprocesseur a{" "}
                <strong>remplacé TVA par 0.1925</strong> dans tout le fichier <em>avant</em> la
                compilation. Le compilateur voit donc{" "}
                <span className="font-mono">0.1925 = 0.20;</span> — on ne peut pas affecter une
                valeur à un nombre. <span className="font-mono">#define</span> n&apos;est pas une
                variable, c&apos;est un remplacement de texte.
              </>
            ) : (
              <>
                Le message est direct : <strong>« read-only variable »</strong>. Avec{" "}
                <span className="font-mono">const</span>, TVA est une{" "}
                <strong>vraie variable protégée en écriture</strong>, qui existe à l&apos;exécution
                et possède une adresse. Les deux formes refusent la modification, mais pour des
                raisons différentes.
              </>
            )}
          </Verdict>
        </>
      ) : (
        <Verdict tone="warn">
          Essaie de modifier la constante, dans l&apos;une puis l&apos;autre forme : les deux
          refusent, mais les deux messages ne disent pas la même chose.
        </Verdict>
      )}

      <div className="space-y-2 border-t border-border pt-3">
        <p className="text-xs font-medium text-muted-foreground">
          Le &amp; de scanf, vu depuis la mémoire
        </p>
        <Code
          lignes={[
            "int age;",
            avecEt
              ? '    scanf("%d", &age);    /* correct */'
              : '    scanf("%d", age);     /* le & manque */',
          ]}
          eclairee={1}
          tonEclairee={avecEt ? "ok" : "bad"}
        />
        <div className="flex flex-wrap items-end gap-2">
          <label className="space-y-0.5">
            <span className="block text-[11px] font-medium text-muted-foreground">
              Ce que l&apos;utilisateur tape
            </span>
            <input
              value={saisie}
              onChange={(e) => setSaisie(e.target.value)}
              className="w-24 rounded border border-border bg-background px-2 py-1 font-mono text-xs"
            />
          </label>
          <button
            type="button"
            onClick={() => setAvecEt((v) => !v)}
            className="rounded-lg border border-border bg-background px-3 py-1.5 text-xs font-medium text-muted-foreground hover:bg-secondary/60"
          >
            {avecEt ? "Oublier le &" : "Remettre le &"}
          </button>
        </div>

        <div className="flex flex-wrap gap-1">
          {MEMOIRE.map((m) => {
            const touche = m.val === saisie;
            return (
              <div
                key={m.adresse}
                className={
                  touche
                    ? m.nom === "age"
                      ? "rounded border-2 border-emerald-500 bg-emerald-500/15 px-2 py-1 text-center"
                      : "rounded border-2 border-rose-500 bg-rose-500/15 px-2 py-1 text-center"
                    : "rounded border border-slate-300 px-2 py-1 text-center"
                }
              >
                <p className="font-mono text-[10px] font-semibold">{m.nom}</p>
                <p className="font-mono text-[9px] text-muted-foreground">{m.adresse}</p>
                <p className="font-mono text-[11px]">{m.val}</p>
              </div>
            );
          })}
        </div>

        {avecEt ? (
          <Verdict tone="ok">
            Avec le <span className="font-mono">&amp;</span>, scanf reçoit{" "}
            <strong>l&apos;adresse</strong> 0x7000 et écrit {saisie} dans{" "}
            <span className="font-mono">age</span>. Voilà la vraie raison du{" "}
            <span className="font-mono">&amp;</span> : scanf doit savoir <strong>où</strong> ranger
            la valeur, pas quelle est la valeur actuelle. C&apos;est aussi pourquoi printf, qui veut
            seulement <em>lire</em>, n&apos;en a pas besoin.
          </Verdict>
        ) : (
          <Verdict tone="bad">
            Sans le <span className="font-mono">&amp;</span>, scanf reçoit le{" "}
            <strong>contenu</strong> de <span className="font-mono">age</span> — une valeur
            imprévisible — et la prend pour une adresse. Il écrit donc {saisie} n&apos;importe où :
            ici dans la zone voisine. Le programme compile souvent sans erreur, puis produit des
            résultats absurdes ou s&apos;arrête brutalement. C&apos;est l&apos;un des bugs les plus
            déroutants du débutant. <em>L&apos;exception à connaître :</em> pour une chaîne,{" "}
            <span className="font-mono">scanf(&quot;%s&quot;, nom)</span> s&apos;écrit sans{" "}
            <span className="font-mono">&amp;</span>, parce que le nom d&apos;un tableau est déjà
            une adresse.
          </Verdict>
        )}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ */
/* Chapitre 23 — printf et scanf                                       */
/* ------------------------------------------------------------------ */

const VARS = [
  { nom: "age", type: "int", val: 17 },
  { nom: "moyenne", type: "float", val: 13.5 },
  { nom: "initiale", type: "char", val: "M" },
  { nom: "nom", type: "char[]", val: "MBIDA" },
] as const;

function formater(gabarit: string, args: ReadonlyArray<(typeof VARS)[number]>): string {
  let k = 0;
  return gabarit
    .replace(/%(\.\d+)?[dfcs]/g, (spec) => {
      const v = args[k];
      k += 1;
      if (!v) return "(null)";
      const code = spec[spec.length - 1];
      if (code === "d") {
        if (v.type === "float") return "0"; // un float lu en %d donne n'importe quoi
        if (v.type === "char") return String(String(v.val).charCodeAt(0));
        if (v.type === "char[]") return "4198400";
        return String(v.val);
      }
      if (code === "f") {
        const dec = /\.(\d+)/.exec(spec);
        const n = typeof v.val === "number" ? v.val : 0;
        if (v.type === "int") return "0.000000";
        return dec ? n.toFixed(Number(dec[1])) : n.toFixed(6);
      }
      if (code === "c") {
        if (v.type === "char") return String(v.val);
        return "\u0011";
      }
      if (v.type === "char[]") return String(v.val);
      return "(null)";
    })
    .replace(/\\n/g, "\n")
    .replace(/\\t/g, "\t");
}

export function PrintfScanf() {
  const [gabarit, setGabarit] = useState("%s a %.2f de moyenne\\n");
  const [choisies, setChoisies] = useState<string[]>(["nom", "moyenne"]);

  const args = choisies
    .map((n) => VARS.find((v) => v.nom === n))
    .filter((v): v is (typeof VARS)[number] => Boolean(v));

  const nbSpec = (gabarit.match(/%(\.\d+)?[dfcs]/g) ?? []).length;
  const sortie = formater(gabarit, args);
  const manque = nbSpec > args.length;
  const trop = args.length > nbSpec;

  const mauvaisType = gabarit.match(/%(\.\d+)?[dfcs]/g)?.some((spec, k) => {
    const v = args[k];
    if (!v) return false;
    const c = spec[spec.length - 1];
    if (c === "d" && v.type !== "int") return true;
    if (c === "f" && v.type !== "float") return true;
    if (c === "c" && v.type !== "char") return true;
    if (c === "s" && v.type !== "char[]") return true;
    return false;
  });

  return (
    <div className="space-y-3">
      <div className="space-y-1 rounded-lg border border-border bg-background p-2.5">
        <p className="text-xs font-semibold">Les variables déjà remplies</p>
        {VARS.map((v) => (
          <p key={v.nom} className="font-mono text-[11px] text-muted-foreground">
            {v.type} {v.nom} ={" "}
            {v.type === "char" ? `'${v.val}'` : v.type === "char[]" ? `"${v.val}"` : v.val};
          </p>
        ))}
      </div>

      <div className="space-y-1.5">
        <p className="text-xs font-medium text-muted-foreground">Le format</p>
        <input
          value={gabarit}
          onChange={(e) => setGabarit(e.target.value)}
          className="w-full rounded-lg border border-border bg-background px-2.5 py-1.5 font-mono text-xs"
        />
        <div className="flex flex-wrap gap-1">
          {[
            "Age : %d ans\\n",
            "Moyenne : %f\\n",
            "Moyenne : %.2f\\n",
            "%s a %.2f de moyenne\\n",
            "Initiale : %c\\n",
            "Age : %d ans",
            "%d et %d\\n",
          ].map((g) => (
            <button
              key={g}
              type="button"
              onClick={() => setGabarit(g)}
              className="rounded border border-border bg-background px-1.5 py-0.5 font-mono text-[10px] text-muted-foreground hover:bg-secondary/60"
            >
              {g}
            </button>
          ))}
        </div>
      </div>

      <div className="space-y-1">
        <p className="text-xs font-medium text-muted-foreground">
          Les arguments, dans l&apos;ordre des %
        </p>
        <div className="flex flex-wrap gap-1.5">
          {VARS.map((v) => (
            <button
              key={v.nom}
              type="button"
              onClick={() => setChoisies((c) => [...c, v.nom])}
              className="rounded border border-border bg-background px-1.5 py-0.5 font-mono text-[10px] text-muted-foreground hover:bg-secondary/60"
            >
              + {v.nom}
            </button>
          ))}
          <button
            type="button"
            onClick={() => setChoisies((c) => c.slice(0, -1))}
            className="rounded border border-border bg-background px-1.5 py-0.5 text-[10px] font-medium text-muted-foreground hover:bg-secondary/60"
          >
            retirer
          </button>
          <button
            type="button"
            onClick={() => setChoisies([])}
            className="rounded border border-border bg-background px-1.5 py-0.5 text-[10px] font-medium text-muted-foreground hover:bg-secondary/60"
          >
            vider
          </button>
        </div>
        <p className="font-mono text-[11px]">
          printf(&quot;{gabarit}&quot;
          {choisies.length > 0 ? `, ${choisies.join(", ")}` : ""});
        </p>
      </div>

      <Panel>
        <Stat label="Spécificateurs %" value={`${nbSpec}`} />
        <Stat
          label="Arguments fournis"
          value={`${args.length}`}
          color={nbSpec === args.length ? PALETTE.green : PALETTE.red}
        />
      </Panel>

      <Console lignes={sortie.split("\n").filter((x, i, a) => x !== "" || i < a.length - 1)} />

      {manque ? (
        <Verdict tone="bad">
          {nbSpec} spécificateurs pour {args.length} argument{args.length > 1 ? "s" : ""} : printf
          va chercher une valeur qui n&apos;existe pas et affiche n&apos;importe quoi. Le
          compilateur ne dit rien — il fait confiance.
        </Verdict>
      ) : trop ? (
        <Verdict tone="warn">
          Plus d&apos;arguments que de <span className="font-mono">%</span> : les arguments en trop
          sont simplement ignorés. Moins grave, mais le signe que la ligne n&apos;est pas celle
          qu&apos;on croyait écrire.
        </Verdict>
      ) : mauvaisType ? (
        <Verdict tone="bad">
          Un spécificateur ne correspond pas au type de son argument, et regarde le résultat : un{" "}
          <span className="font-mono">float</span> lu en <span className="font-mono">%d</span>{" "}
          affiche 0, un <span className="font-mono">int</span> lu en{" "}
          <span className="font-mono">%f</span> affiche 0.000000, une chaîne lue en{" "}
          <span className="font-mono">%d</span> affiche son adresse.{" "}
          <strong>%d pour un int, %f pour un float, %c pour un char, %s pour une chaîne</strong> —
          il n&apos;y a pas de conversion automatique.
        </Verdict>
      ) : !gabarit.includes("\\n") ? (
        <Verdict tone="warn">
          Pas de <span className="font-mono">\n</span> : l&apos;affichage suivant collera juste
          après, sur la même ligne. Sur dix affichages, tout se retrouve sur une seule ligne
          illisible.
        </Verdict>
      ) : (
        <Verdict tone="ok">
          Format et arguments s&apos;accordent.{" "}
          {gabarit.includes("%.2f")
            ? "Et le %.2f limite à deux décimales : sans le .2, un %f affiche six décimales et une moyenne devient 13.500000."
            : "Essaie %f puis %.2f sur la moyenne, pour voir la différence."}
        </Verdict>
      )}
    </div>
  );
}
